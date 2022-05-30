local data_item_item = require("data.data_item_item")

local SpiritIcon = class("SpiritIcon", function ()
	return display.newNode()
end)

function SpiritIcon:ctor(param)
	display.addSpriteFramesWithFile("ui/ui_spirit.plist", "ui/ui_spirit.png")
	local _id = param.id
	local _resId = param.resId
	local _lv = param.lv or 0
	local _exp = param.exp or 0
	local _bShowName = param.bShowName
	local _bShowNameBg = param.bShowNameBg
	local _bShowLv = param.bShowLv
	local _nameOffsetY = param.offsetY or 0
	local _baseInfo = data_item_item[_resId]
	local bNum = param.bNum
	function self.getResID()
		return _resId
	end
	function self.getID()
		return _id
	end
	function self.getQuality()
		return _baseInfo.quality
	end
	function self.getLV()
		return _lv
	end
	function self.getCurExp()
		return _exp
	end
	local sprite = display.newSprite("#spirit_jy_icon_board.png")
	self:addChild(sprite)
	local _sz = sprite:getContentSize()
	
	function self.getSprite()
		return sprite
	end
	
	if _bShowLv then
		local lvBoard = display.newSprite("#spirit_jy_icon_num.png")
		lvBoard:setPosition(sprite:getContentSize().width - lvBoard:getContentSize().width / 2, lvBoard:getContentSize().height / 2)
		sprite:addChild(lvBoard, 2)
		local lvLabel = ui.newTTFLabelWithOutline({
		text = tostring(_lv),
		font = FONTS_NAME.font_fzcy,
		size = 20,
		align = ui.TEXT_ALIGN_CENTER,
		color = display.COLOR_WHITE,
		outlineColor = display.COLOR_BLACK,
		})
		lvLabel:setPosition(lvBoard:getContentSize().width * 0.4, lvLabel:getContentSize().height * 0.86)
		lvBoard:addChild(lvLabel)
	end
	
	local animSprite = ResMgr.createArma({
	resType = ResMgr.SPIRIT,
	armaName = _baseInfo.icon,
	isRetain = true
	})
	sprite:addChild(animSprite)
	local name = _baseInfo.name
	if _bShowName then
		name = _baseInfo.name
	else
		name = ""
	end
	if bNum and bNum > 1 then
		name = name .. "x" .. bNum
	end
	if _bShowNameBg then
		local nameBg = display.newSprite("#spirit_name_bg.png")
		nameBg:setPosition(_sz.width / 2, nameBg:getContentSize().height / 2 + _nameOffsetY - 3.5)
		self:addChild(nameBg)
	end
	local nameLabel = ui.newTTFLabelWithOutline({
	text = name,
	size = 20,
	font = FONTS_NAME.font_fzcy,
	color = QUALITY_COLOR[_baseInfo.quality or 1],
	outlineColor = display.COLOR_BLACK,
	align = ui.TEXT_ALIGN_CENTER,
	dimensions = cc.size(120, 0)
	})
	self:addChild(nameLabel)
	local szH = _sz.height + nameLabel:getContentSize().height
	self:setContentSize(cc.size(_sz.width, szH))
	self:align(display.CENTER)
	nameLabel:setPosition(_sz.width / 2, nameLabel:getContentSize().height / 2 + _nameOffsetY)
	sprite:setPosition(_sz.width / 2, szH - sprite:getContentSize().height / 2)
	animSprite:setPosition(_sz.width / 2, _sz.height / 2)
end

return SpiritIcon