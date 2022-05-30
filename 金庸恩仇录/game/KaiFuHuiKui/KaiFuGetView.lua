require("game.Biwu.BiwuFuc")
local KaiFuGetView = class("KaiFuGetView", function ()
	return require("utility.ShadeLayer").new()
end)
function KaiFuGetView:ctor(param)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("nbhuodong/kaifukuanghuan_seven_getpopup.ccbi", proxy, self._rootnode)
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.closeBtn:addHandleOfControlEvent(function (eventName, sender)
		self:removeFromParent()
	end,
	CCControlEventTouchUpInside)
	if param._type == KUANGHUAN_TYPE.KAIFU then
		self._rootnode.huodong_title_2:setVisible(false)
	else
		self._rootnode.huodong_title_0:setVisible(false)
		self._rootnode.huodong_title_2:setVisible(true)
		local jieriType = 1
		if param._type == KUANGHUAN_TYPE.CHUNJIE then
			jieriType = game.player:getAppOpenData().seven_day
		end
		local titleSprite = display.newSprite("ui/ui_jieri7tian/" .. JieRi_head_name[jieriType] .. "_7day_title.png")
		self._rootnode.huodong_title_2:setDisplayFrame(titleSprite:getDisplayFrame())
	end
	if param.type == 2 then
		self._rootnode.titlelabel:setString(common:getLanguageString("@SelectThisHero"))
		self._rootnode.loginLabel_1:setString(common:getLanguageString("@LoginContinuePresent"))
		self._rootnode.loginLabel_2:setString(common:getLanguageString("@HighestKinga"))
	else
		self._rootnode.titlelabel:setString(common:getLanguageString("@SelectThisBook"))
		if param._type == KUANGHUAN_TYPE.CHUNJIE then
			self._rootnode.loginLabel_1:setString(common:getLanguageString("@LoginContinuePresent2"))
		else
			self._rootnode.loginLabel_1:setString(common:getLanguageString("@LoginContinuePresent1"))
		end
		self._rootnode.loginLabel_2:setString(common:getLanguageString("@HighestKinga1"))
	end
	self._checkBox = {}
	self:setUpView(param)
end
function KaiFuGetView:setUpView(param)
	local boardWidth = self._rootnode.itemview:getContentSize().width
	local boardHeight = self._rootnode.itemview:getContentSize().height
	for k, v in pairs(param.itemData) do
		local item = require("game.KaiFuHuiKui.KaiFuCell").new()
		local itemView = item:create({
		index = index,
		viewSize = CCSizeMake(boardWidth, boardHeight),
		itemData = v,
		discription = param.discription[k],
		confirmFunc = showBuyBox
		})
		itemView:setPosition((boardWidth / 4 - 10) * (k - 1) + 25, 30)
		self._rootnode.itemview:addChild(itemView)
		self:createCheckBox(item, k, itemView)
	end
	for index = 1, 4 do
		self._rootnode["dis_" .. index]:setString("")
	end
	for k, v in pairs(param.itemData) do
		self._rootnode["dis_" .. k]:setString(param.discription[k])
	end
	self._rootnode.submitbtn:addHandleOfControlEvent(function (eventName, sender)
		if self._selectIndex then
			if param.commitFuc then
				param.commitFuc(self._selectIndex)
				self:removeFromParent()
			end
		else
			dump("erro!!! please input selectIndex")
		end
	end,
	CCControlEventTouchUpInside)
end
local selectTag = display.newSprite("#kaifu_duigou.png")
selectTag:setAnchorPoint(cc.p(0, 0))
selectTag:retain()
function KaiFuGetView:createCheckBox(baseView, index, itemView)
	local baseBng = display.newSprite("#kaifu_duigou_bg.png")
	baseBng:setPosition(baseView:getContentSize().width / 2, 0)
	baseView:addChild(baseBng)
	self._checkBox[index] = baseBng
	addTouchListener(baseBng, function (sender, eventType)
		if eventType == EventType.began then
		elseif eventType == EventType.ended then
			for k, v in pairs(self._checkBox) do
				v:removeAllChildren()
			end
			baseBng:addChild(selectTag)
			self._selectIndex = index
		elseif eventType == EventType.cancel then
		end
	end)
	addTouchListener(baseView, function (sender, eventType)
		if eventType == EventType.began then
			for k, v in pairs(self._checkBox) do
				v:removeAllChildren()
			end
			baseBng:addChild(selectTag)
			self._selectIndex = index
		elseif eventType == EventType.ended then
		elseif eventType == EventType.cancel then
		end
	end)
end

return KaiFuGetView