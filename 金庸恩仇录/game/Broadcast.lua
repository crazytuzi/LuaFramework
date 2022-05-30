Broad_getHeroData = {
heroName = "",
type = 0,
star = 0
}
Broad_heroLevelUpData = {
heroName = "",
type = 0,
class = 0,
star = 0
}
local c = cc

local Broadcast = class("Broadcast", function()
	return display.newNode()
end)

function Broadcast:getBroadList()
	GameRequest.Broadcast.getBroadcastList({
	callback = function(data)
		self._hasGetList = true
		if data["0"] ~= 0 then
			local data_guangbo_guangbo = require("data.data_guangbo_guangbo")
			self._allBroadcastList = data_guangbo_guangbo
		else
			self._allBroadcastList = data["1"]
		end
		self:createRandomBroadList()
		self:setNextBroadcast()
		self:reqCurBList()
		self:reqEditBList()
	end
	})
end

function Broadcast:reqCurBList()
	GameRequest.Broadcast.updateList({
	callback = function(data)
		GameModel.updateData(data["5"])
		if data["0"] ~= "" then
			dump(data["0"])
		elseif GameStateManager.currentState > GAME_STATE.STATE_LOGO then
			game.urgencyBroadcast:addToUrgencyBroadcast(data["2"])
			self:addBroadStrFromSever(data)
			local mailTip = data["4"]
			if mailTip ~= nil then
				game.player:setMailTip(mailTip)
				PostNotice(NoticeKey.MAIL_TIP_UPDATE)
			end
		end
	end
	})
end

local timeCounttor = 0
function Broadcast:keepEditList(contentTable)
	contentTable = contentTable[1]
	if contentTable.weight == 3 then
		table.insert(self._bufferBStr, {contentTable})
		dump("普通公告")
	else
		table.insert(self._bufferBStrWeight, contentTable)
		table.sort(self._bufferBStrWeight, function(a, b)
			return a.weight < b.weight
		end)
		dump("优先级为23的")
	end
end

function Broadcast:checkBroadcast()
	timeCounttor = timeCounttor + 1
	if self.eidtcastList ~= nil then
		local needRemove = {}
		for i, v in pairs(self.eidtcastList) do
			v.endT = v.endT - 1
			if v.endT < 0 then
				table.remove(self.eidtcastList, i)
				dump("时间结束 公告移除")
			elseif timeCounttor % v.time == 0 then
				local contentStr = v.str
				if contentStr ~= nil then
					self:keepEditList({v})
				end
			end
		end
	end
end

function Broadcast:reqEditBList()
	local function initBIBroadList(List)
		dump("-----------------公告-------------------")
		dump(List)
		dump("-----------------公告-------------------")
		for k, v in pairs(List) do
			local ret = {}
			ret.str = v.content
			ret.time = v.rate
			ret.weight = v.weight
			ret.color = cc.c3b(255, 255, 255)
			ret.endT = v.endTime - self._serverTime
			table.insert(self.eidtcastList, ret)
		end
	end
	GameRequest.Broadcast.getBIBroadcastList({
	callback = function(data)
		if data["0"] == "" then
			dump(data["1"])
			self._serverTime = data["2"]
			initBIBroadList(data["1"])
		end
	end,
	serverId = game.player.m_serverID,
	channelId = CSDKShell.getChannelID()
	})
end

function Broadcast:getColorByType(param)
	local color
	if param.color ~= nil then
		if type(param.color) == "table" then
			color = cc.c3b(param.color[1], param.color[2], param.color[3])
		else
			color = cc.c3b(0, 0, 0)
		end
	elseif param.type == -1 then
		local star = ResMgr.getCardData(1).star[param.star + 1] or 1
		color = QUALITY_COLOR[star]
	else
		color = NAME_COLOR[param.star]
	end
	return color
end

function Broadcast:createBroadStrByParam(param)
	self._broadLbl:removeAllChildrenWithCleanup(true)
	self._broadLbl:setContentSize(cc.size(0, 0))
	for _, v in pairs(param) do
		local lbl = CCLabelTTF:create(v.str, FONTS_NAME.font_fzcy, 19)
		lbl:setColor(v.color)
		lbl:setAnchorPoint(cc.p(0, 0.58))
		lbl:setPosition(self._broadLbl:getContentSize().width, 0)
		self._broadLbl:addChild(lbl)
		self._broadLbl:setContentSize(cc.size(self._broadLbl:getContentSize().width + lbl:getContentSize().width, lbl:getContentSize().height))
	end
end

function Broadcast:createBroadParamByData(param)
	if param.color == nil then
	end
	local data = param.data
	local contentStr = {}
	local broadItem = self:getBroadItemById(param.id)
	local strList = string.split(broadItem.Content, "%s")
	for i, v in pairs(data) do
		if i < #data then
			table.insert(strList, i * 2, data[i].value)
		end
	end
	if #strList > #data + 1 then
		table.insert(strList, #strList, data[#data].value)
	elseif #data > 0 then
		table.insert(strList, data[#data].value)
	end
	for i, v in pairs(strList) do
		if i % 2 == 0 then
			local color = self:getColorByType(data[i / 2]) or cc.c3b(0, 0, 0)
			table.insert(contentStr, {str = v, color = color})
		else
			local color = cc.c3b(0, 0, 0)
			if param.color ~= nil then
				color = cc.c3b(param.color[1], param.color[2], param.color[3])
			end
			table.insert(contentStr, {str = v, color = color})
		end
	end
	return contentStr
end

function Broadcast:addBroadStrFromSever(data)
	if self._bufferBStr == nil then
		self._bufferBStr = {}
	end
	if self._waitBroadcastList == nil then
		self._waitBroadcastList = {}
	end
	for i, v in pairs(data["1"]) do
		if data["1"][i].time > 0 then
			table.insert(self._waitBroadcastList, data["1"][i])
		else
			local contentStr = self:createBroadParamByData(data["1"][i])
			if contentStr ~= nil then
				table.insert(self._bufferBStr, contentStr)
			end
		end
	end
end

function Broadcast:createRandomBroadList()
	self._canRandomBroadList = {}
	for k, v in pairs(self._allBroadcastList) do
		if v.type == 3 then
			local strParam = {}
			local color = cc.c3b(0, 0, 0)
			if v.color ~= nil and type(v.color) == "table" then
				color = cc.c3b(v.color[1], v.color[2], v.color[3])
			end
			table.insert(strParam, {
			str = v.Content,
			color = color
			})
			table.insert(self._canRandomBroadList, strParam)
		end
	end
	dump(self._canRandomBroadList)
end

function Broadcast:getRandomBroadcast()
	local index = math.random(1, #self._canRandomBroadList)
	return self._canRandomBroadList[index]
end

function Broadcast:setNextBroadcast()
	local strParam = {}
	if self._bufferBStrWeight ~= nil and #self._bufferBStrWeight > 0 then
		strParam = {
		self._bufferBStrWeight[1]
		}
		table.remove(self._bufferBStrWeight, 1)
	elseif self._bufferBStr ~= nil and 0 < #self._bufferBStr then
		strParam = self._bufferBStr[1]
		table.remove(self._bufferBStr, 1)
	else
		strParam = self:getRandomBroadcast()
	end
	if self._broadLbl == nil then
		self:initBroadcastLbl()
	end
	self:createBroadStrByParam(strParam)
end

function Broadcast:initBroadcastLbl()
	local clippingNode = CCClippingNode:create()
	clippingNode:setContentSize(self._viewSize)
	local stencil = display.newRect(cc.rect(0, 0, self._viewSize.width, self._viewSize.height))
	clippingNode:setStencil(stencil)
	clippingNode:setInverted(false)
	self:addChild(clippingNode)
	self._broadLbl = display.newNode()
	self._broadLbl:setPosition(clippingNode:getContentSize().width, clippingNode:getContentSize().height / 2)
	clippingNode:addChild(self._broadLbl)
end

function Broadcast:initTimeSchedule()
	local function updateLblPos()
		if self._broadLbl ~= nil then
			local posX = self._broadLbl:getPositionX()
			local posY = self._broadLbl:getPositionY()
			self._broadLbl:setPosition(posX - 1, posY)
			if posX < -self._broadLbl:getContentSize().width then
				self._broadLbl:setPosition(self._viewSize.width, posY)
				self:setNextBroadcast()
			end
		end
	end
	self.scheduler = require("framework.scheduler")
	self._schedule = self.scheduler.scheduleGlobal(updateLblPos, 0.01, false)
	local function checkBroadcast()
		if self._waitBroadcastList ~= nil and #self._waitBroadcastList > 0 then
			local needRemove = {}
			for i, v in pairs(self._waitBroadcastList) do
				if 0 < v.time then
					v.time = v.time - 1
				end
				if 0 >= v.time then
					table.insert(needRemove, i)
					local contentStr = self:createBroadParamByData(v)
					if contentStr ~= nil then
						table.insert(self._bufferBStr, contentStr)
					end
				end
			end
			for i, v in pairs(needRemove) do
				table.remove(self._waitBroadcastList, i)
			end
		end
		self:checkBroadcast()
	end
	self._checkSchedule = self.scheduler.scheduleGlobal(checkBroadcast, 1, false)
end

function Broadcast:getBroadItemById(id)
	local item
	for _, v in pairs(self._allBroadcastList) do
		if v.id == id then
			item = v
			break
		end
	end
	return item
end

function Broadcast:showPlayerGetHero()
	local item = self:getBroadItemById(1)
	local data = {}
	table.insert(data, {
	value = game.player:getPlayerName(),
	type = -1,
	star = game.player.m_class
	})
	table.insert(data, {
	value = Broad_getHeroData.heroName,
	type = Broad_getHeroData.type,
	star = Broad_getHeroData.star
	})
	local paramData = {
	color = item.color,
	data = data,
	id = item.id,
	string = item.Content,
	type = item.type
	}
	local contentStr = self:createBroadParamByData(paramData)
	if #self._bufferBStr > 0 then
		table.insert(self._bufferBStr, 1, contentStr)
	else
		table.insert(self._bufferBStr, contentStr)
	end
end

function Broadcast:showPlayerGetPet(petName, star)
	local item = self:getBroadItemById(6)
	local data = {}
	table.insert(data, {
	value = game.player:getPlayerName(),
	type = -1,
	star = game.player.m_class
	})
	table.insert(data, {
	value = petName,
	type = 1,
	star = star
	})
	local paramData = {
	color = item.color,
	data = data,
	id = item.id,
	string = item.Content,
	type = item.type
	}
	local contentStr = self:createBroadParamByData(paramData)
	if #self._bufferBStr > 0 then
		table.insert(self._bufferBStr, 1, contentStr)
	else
		table.insert(self._bufferBStr, contentStr)
	end
end

function Broadcast:showPlayerGetSkill(skillName, star)
	local item = self:getBroadItemById(7)
	local data = {}
	table.insert(data, {
	value = game.player:getPlayerName(),
	type = -1,
	star = game.player.m_class
	})
	table.insert(data, {
	value = skillName,
	type = 1,
	star = star
	})
	local paramData = {
	color = item.color,
	data = data,
	id = item.id,
	string = item.Content,
	type = item.type
	}
	local contentStr = self:createBroadParamByData(paramData)
	if #self._bufferBStr > 0 then
		table.insert(self._bufferBStr, 1, contentStr)
	else
		table.insert(self._bufferBStr, contentStr)
	end
end

function Broadcast:showHeroLevelUp()
	local item = self:getBroadItemById(2)
	local data = {}
	table.insert(data, {
	value = game.player:getPlayerName(),
	type = -1,
	star = game.player.m_class
	})
	table.insert(data, {
	value = Broad_heroLevelUpData.heroName,
	type = Broad_heroLevelUpData.type,
	star = Broad_heroLevelUpData.star
	})
	table.insert(data, {
	value = Broad_heroLevelUpData.class,
	color = {
	item.arr_color[1] or 153,
	item.arr_color[2] or 255,
	item.arr_color[3] or 0
	}
	})
	local paramData = {
	color = item.color,
	data = data,
	id = item.id,
	string = item.Content,
	type = item.type
	}
	local contentStr = self:createBroadParamByData(paramData)
	if 0 < #self._bufferBStr then
		table.insert(self._bufferBStr, 1, contentStr)
	else
		table.insert(self._bufferBStr, contentStr)
	end
end

function Broadcast:ctor()
	self:setTag(777777)
	self:setNodeEventEnabled(true)
	self._viewSize = cc.size(display.width * 0.798, 30)
	self._bufferBStr = {}
	self.eidtcastList = {}
	self._waitBroadcastList = {}
	self._bufferBStrWeight = {}
	self._hasGetList = false
	self:setAnchorPoint(cc.p(0.5, 0))
end

function Broadcast:onEnter()
	dump("enterenterenterenterenterenterenterenterenterenter")
	if not self._hasGetList then
		self:getBroadList()
	end
	self:initTimeSchedule()
end

function Broadcast:onExit()
	
	dump("exitexitexitexitexitexitexitexitexitexitexitexit")
	
	if self._schedule ~= nil then
		self.scheduler.unscheduleGlobal(self._schedule)
	end
	if self._checkSchedule ~= nil then
		self.scheduler.unscheduleGlobal(self._checkSchedule)
	end
end

function Broadcast:reSet(node)
	if node ~= nil then
		if self:getParent() ~= nil then
			self:removeFromParent(false)
		else
			self:setNodeEventEnabled(false)
			self._scriptEventListeners_ = nil
			self._baseNodeEventListener_ = nil
			self:setNodeEventEnabled(true)
		end
		node:addChild(self)
	end
end

return Broadcast