local data_item_nature = require("data.data_item_nature")
local data_item_item = require("data.data_item_item")

local BaseEquipInfoLayer = class("BaseEquipInfoLayer", function()
	return require("utility.ShadeLayer").new()
end)

function BaseEquipInfoLayer:initSuit()
	self.suitInfo = require("game.Equip.EquipSuitInfo").new({
	curId = self.resId,
	itemType = self.itemType
	})
	self.suitInfo:setAnchorPoint(0.5, 1)
	self._rootnode.taozhuang_node:addChild(self.suitInfo)
	local maxOff = 470 + self.suitInfo:getHeight()
	self.scrollBg:setContentSize(cc.size(display.width, maxOff))
	self.scrollBg:setContentOffset(cc.p(0, -150), false)
	self.contentContainer:setPosition(display.cx, maxOff)
end

function BaseEquipInfoLayer:ctor(param)
	local id = param.id
	local confirmFunc = param.confirmFunc
	local _baseInfo = data_item_item[id]
	self.itemType = param.itemType
	if _baseInfo.Suit == nil then
		boardSize = cc.size(640, 620)
	else
		boardSize = cc.size(display.width, 850)
	end
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	local bgNode = CCBuilderReaderLoad("equip/equip_comon_info.ccbi", self._proxy, self._rootnode, self, boardSize)
	bgNode:setPosition(display.cx, display.cy - bgNode:getContentSize().height / 2)
	self:addChild(bgNode, 1)
	local coProxy = CCBProxy:create()
	self.contentContainer = CCBuilderReaderLoad("equip/equip_comon_content.ccbi", coProxy, self._rootnode, self, CCSizeMake(640, 620))
	self.contentNode = display.newNode()
	self.contentNode:addChild(self.contentContainer)
	self.contentNode:setPosition(display.cx, 0)
	self.scrollBg = CCScrollView:create()
	bgNode:addChild(self.scrollBg)
	self.scrollBg:setContainer(self.contentNode)
	self.scrollBg:setPosition(0, 80)
	self.scrollBg:setViewSize(cc.size(display.width, boardSize.height - 150))
	local maxOff = 800
	self.scrollBg:setContentSize(cc.size(display.width, maxOff))
	self.scrollBg:setDirection(kCCScrollViewDirectionVertical)
	self.scrollBg:setContentOffset(cc.p(0, -maxOff / 2 + 55), false)
	self.scrollBg:ignoreAnchorPointForPosition(true)
	self.scrollBg:updateInset()
	self.contentContainer:setPosition(display.width / 2, maxOff)
	self._rootnode.titleLabel:setString(common:getLanguageString("@EquitInfo"))
	self._rootnode.titleLabel:setString(common:getLanguageString("@EquitInfo"))
	self.resId = id
	self.baseInfo = _baseInfo
	local isSuit = _baseInfo.Suit
	if isSuit == nil then
		self.scrollBg:setTouchEnabled(false)
	else
		self.scrollBg:setTouchEnabled(true)
		self:initSuit()
	end
	
	for i = 1, _baseInfo.quality do
		local starnode = self._rootnode[string.format("star%d", i)]
		if starnode ~= nil then
			starnode:setVisible(true)
		end
	end
	
	local path = ResMgr.getLargeImage(_baseInfo.bicon, ResMgr.EQUIP)
	self._rootnode.skillImage:setDisplayFrame(display.newSprite(path):getDisplayFrame())
	self._rootnode.changeBtn:setVisible(false)
	self._rootnode.takeOffBtn:setVisible(false)
	self._rootnode.xiLianBtn:setVisible(false)
	self._rootnode.qiangHuBtn:setVisible(false)
	self._rootnode.closeBtn:setVisible(true)
	
	--¹Ø±Õ
	self._rootnode.closeBtn:addHandleOfControlEvent(function(sender, event)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
		if confirmFunc ~= nil then
			confirmFunc()
		end
	end,
	CCControlEventTouchUpInside)
	
	local function refresh()
		self._rootnode.tag_card_bg:setDisplayFrame(display.newSprite("#item_card_bg_" .. _baseInfo.quality .. ".png"):getDisplayFrame())
		local arr_nature = _baseInfo.arr_nature
		local index = 1
		if arr_nature ~= nil then
			for i, v in ipairs(arr_nature) do
				local nature = data_item_nature[v]
				local str = nature.nature
				if nature.type == 1 then
					str = str .. string.format(": +%d", _baseInfo.arr_value[i])
				else
					str = str .. string.format(": +%d%%", _baseInfo.arr_value[i] / 100)
				end
				self._rootnode["basePropLabel_" .. tostring(index)]:setString(str)
				index = index + 1
			end
		end
		self._rootnode.curLvLabel:setString("0")
	end
	
	self._rootnode.descLabel:setString(_baseInfo.describe)
	self._rootnode.cardName:setString(_baseInfo.name)
	
	local nameLabel = ui.newTTFLabelWithShadow({
	text = _baseInfo.name,
	font = FONTS_NAME.font_haibao,
	size = 30,
	align = ui.TEXT_ALIGN_CENTER,
	color = NAME_COLOR[_baseInfo.quality],
	shadowColor = display.COLOR_BLACK,
	})
	nameLabel:align(display.CENTER)
	ResMgr.replaceKeyLableEx(nameLabel, self._rootnode, "itemNameLabel", 0, 0)
	
	local progressNode = self._rootnode.progressNode
	if param.curNum and param.limitNum and progressNode then
		local curNumLabel = self._rootnode.curNum
		local maxNumLabel = self._rootnode.maxNum
		curNumLabel:setString(tostring(param.curNum))
		maxNumLabel:setString("/" .. tostring(param.limitNum))
		progressNode:setVisible(true)
		progressNode:setPositionX(progressNode:getPositionX() + nameLabel:getContentSize().width / 2 + (curNumLabel:getContentSize().width + maxNumLabel:getContentSize().width) / 2)
	else
		progressNode:setVisible(false)
	end
	refresh()
end

return BaseEquipInfoLayer