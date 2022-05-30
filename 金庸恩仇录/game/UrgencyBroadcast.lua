local UrgencyBroadcast = class("UrgencyBroadcast", function ()
	return display.newNode()
end)
function UrgencyBroadcast:ctor()
	self._broadcastList = {}
	self._waitBroadList = {}
	self._curBroadLblStr = ""
	self._isHasShow = false
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("public/urgency_broadcast.ccbi", proxy, rootnode)
	self:addChild(node)
	self._viewSize = rootnode.view_node:getContentSize()
	self._clippingNode = CCClippingNode:create()
	self._clippingNode:setContentSize(self._viewSize)
	self._clippingNode:setAnchorPoint(cc.p(0.5, 0.5))
	self._clippingNode:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
	local stencil = display.newDrawNode()
	stencil:drawRect({
	x = 0,
	y = 0,
	w = self._clippingNode:getContentSize().width,
	h = self._clippingNode:getContentSize().height
	})
	self._clippingNode:setStencil(stencil)
	self._clippingNode:setInverted(false)
	node:addChild(self._clippingNode)
	self._scheduler = require("framework.scheduler")
	self:initTimeSchedule()
end
function UrgencyBroadcast:setNextBroadcast()
	if self._broadLbl == nil then
		self._broadLbl = ui.newTTFLabelWithOutline({
		text = self._curBroadLblStr,
		size = 26,
		color = display.COLOR_WHITE,
		outlineColor = display.COLOR_BLACK,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT
		})
		self._broadLbl:setPosition(self._viewSize.width + self._broadLbl:getContentSize().width / 2, self._viewSize.height / 2)
		self._clippingNode:addChild(self._broadLbl)
	end
	if self._broadcastList ~= nil and 0 < #self._broadcastList then
		self._curBroadLblStr = self._broadcastList[1]
		self._broadLbl:setString(self._curBroadLblStr)
		dump(self._broadLbl:getContentSize().width)
		self._broadLbl:setPosition(self._viewSize.width + self._broadLbl:getContentSize().width / 2, self._viewSize.height / 2)
		table.remove(self._broadcastList, 1)
	else
		self._curBroadLblStr = ""
		self._broadLbl:setString(self._curBroadLblStr)
		self:setIsShow(false)
	end
end
function UrgencyBroadcast:initTimeSchedule()
	local function updateLblPos()
		if self._broadLbl ~= nil and self._curBroadLblStr ~= "" and self:getParent() ~= nil then
			local posX = self._broadLbl:getPositionX()
			local posY = self._broadLbl:getPositionY()
			self._broadLbl:setPosition(posX - 1, posY)
			if posX < -self._broadLbl:getContentSize().width / 2 then
				self._broadLbl:setPosition(self._viewSize.width, posY)
				self:setNextBroadcast()
			end
		end
	end
	self._schedule = self._scheduler.scheduleGlobal(updateLblPos, 0.01, false)
	local function checkBroadcast()
		if self._waitBroadList ~= nil and #self._waitBroadList > 0 then
			local needRemove = {}
			for i, v in ipairs(self._waitBroadList) do
				if 0 < v.time then
					v.time = v.time - 1
				end
				if 0 >= v.time then
					table.insert(needRemove, i)
					self:addToUrgencyBroadcast({v})
				end
			end
			for i, v in ipairs(needRemove) do
				table.remove(self._waitBroadList, i)
			end
		end
	end
	self._checkSchedule = self._scheduler.scheduleGlobal(checkBroadcast, 1, false)
end
function UrgencyBroadcast:addToUrgencyBroadcast(data)
	dump(data)
	if data ~= nil and type(data) == "table" and #data > 0 then
		for i, v in ipairs(data) do
			local broadData = data[i]
			if 0 < broadData.time then
				table.insert(self._waitBroadList, broadData)
			else
				for j = 1, broadData.broadNum do
					table.insert(self._broadcastList, broadData.string)
				end
			end
		end
	end
	self:checkAndShow()
end
function UrgencyBroadcast:checkIsCanShow()
	if not self._isHasShow then
		if self._broadcastList ~= nil and #self._broadcastList > 0 then
			return true
		else
			return false
		end
	else
		return false
	end
end
function UrgencyBroadcast:cleanList()
	dump("        cleanList   ")
	self._broadcastList = {}
end
function UrgencyBroadcast:setIsShow(isShow)
	self._isHasShow = isShow
	if self._isHasShow then
		self:setNextBroadcast()
	else
		self:runAction(transition.sequence({
		CCFadeOut:create(0.3),
		CCCallFunc:create(function ()
			self:removeFromParentAndCleanup(true)
		end)
		}))
	end
end

function UrgencyBroadcast:getIsHasShow()
	return self._isHasShow
end

function UrgencyBroadcast:checkAndShow()
	if self:checkIsCanShow() then
		self:show()
	end
end

function UrgencyBroadcast:show()
	dump("######### UrgencyBroadcast:show ############")
	PostNotice(NoticeKey.MainMenuScene_UrgencyBroadcast)
end

return UrgencyBroadcast