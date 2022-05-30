local SubMapScrollCell = class("SubMapScrollCell", function()
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	return CCTableViewCell:new()
end)

local proxy = CCBProxy:create()
local rootnode = {}
local node = CCBuilderReaderLoad("ccbi/fuben/sub_map_item.ccbi", proxy, rootnode)
local contentSize = rootnode.itemBg:getContentSize()

function SubMapScrollCell:getContentSize()
	return contentSize
end

function SubMapScrollCell:create(param)
	local _itemData = param.itemData
	local _viewSize = param.viewSize
	local _subMapInfo = param.mapInfo
	local _onBtn = param.onBtn
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("ccbi/fuben/sub_map_item.ccbi", proxy, self._rootnode)
	node:setPosition(_viewSize.width / 2, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node)
	local headIcon = ResMgr.getLevelBossIcon(_itemData.baseInfo.icon, _itemData.baseInfo.type)
	local contentSize = self._rootnode.headIcon:getContentSize()
	headIcon:setPosition(contentSize.width / 2, contentSize.height / 2)
	self._rootnode.headIcon:addChild(headIcon, 1, 100)
	
	self._rootnode.okBtn:addHandleOfControlEvent(function()
		if _onBtn then
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
			ResMgr.createMaskLayer()
			_onBtn(self:getIdx())
			ResMgr.removeMaskLayer()
		end
	end,
	CCControlEventTouchUpInside)
	
	self.titleLabel = ui.newTTFLabelWithOutline({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 26,
	color = FONT_COLOR.LEVEL_NAME,
	outlineColor = display.COLOR_BLACK,
	--align = ui.TEXT_ALIGN_LEFT
	})
	
	ResMgr.replaceKeyLableEx(self.titleLabel, self._rootnode, "nameLabel", 0, 0)
	self.titleLabel:align(display.LEFT_TOP)
	
	self:refresh(param)
	return self
end

function SubMapScrollCell:getBtn()
	return self._rootnode.okBtn
end

function SubMapScrollCell:refresh(param)
	local _subMapInfo = param.mapInfo
	local _itemData = param.itemData
	self.titleLabel:setString(_itemData.baseInfo.name)
	local totalLbl = self._rootnode.challenge_total_num_lbl
	local curNumLbl = self._rootnode.challenge_cur_num_lbl
	curNumLbl:setString(tostring(_subMapInfo["1"][tostring(_itemData.baseInfo.id)].cnt))
	totalLbl:setString("/" .. tostring(_itemData.baseInfo.number))
	alignNodesOneByAll({
	self._rootnode.challenge_num_lbl,
	self._rootnode.challenge_cur_num_lbl,
	self._rootnode.challenge_total_num_lbl
	})
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	for i = 1, 3 do
		if i <= _itemData.baseInfo.star then
			self._rootnode["star_" .. i]:setVisible(true)
		else
			self._rootnode["star_" .. i]:setVisible(false)
		end
		self._rootnode["star_" .. i]:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
	end
	self._rootnode.headIcon:removeChildByTag(100)
	local headIcon = ResMgr.getLevelBossIcon(_itemData.baseInfo.icon, _itemData.baseInfo.type)
	headIcon:setPosition(self._rootnode.headIcon:getContentSize().width / 2, self._rootnode.headIcon:getContentSize().height / 2)
	self._rootnode.headIcon:addChild(headIcon, 1, 100)
	if _itemData.star > 0 then
		for i = 1, _itemData.star do
			if i > 3 then
				break
			end
			self._rootnode["star_" .. tostring(i)]:setDisplayFrame(display.newSpriteFrame("submap_star_light.png"))
		end
	end
end

return SubMapScrollCell