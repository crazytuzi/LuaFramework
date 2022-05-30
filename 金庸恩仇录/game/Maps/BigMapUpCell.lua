local MAX_ZORDER = 11
local bigMapUpCellSize

local BigMapUpCell = class("BigMapUpCell", function(cellData)
	return CCTableViewCell:new()
end)

function BigMapUpCell:getContentSize()
	if not bigMapUpCellSize then
		local sprite = display.newSprite("#bigmap_top_small_bg1.png")
		bigMapUpCellSize = cc.size(sprite:getContentSize().width, sprite:getContentSize().height)
		sprite:removeSelf()
	end
	return bigMapUpCellSize
end

function BigMapUpCell:ctor()
	self._iconBg = display.newSprite()
	self._iconBg:setPosition(self._iconBg:getContentSize().width / 2, self._iconBg:getContentSize().height / 2)
	self:addChild(self._iconBg)
	local dimensions_vn = cc.size(80, 100)
	local align_vn = ui.TEXT_ALIGN_CENTER
	local v_aling_vn = ui.TEXT_VALIGN_BOTTOM
	self._mapName = ui.newTTFLabelWithOutline({
	text = "",
	font = FONTS_NAME.font_fzcy,
	size = 22,
	color = cc.c3b(137, 137, 137),
	x = self._iconBg:getContentSize().width / 2,
	y = self._iconBg:getContentSize().height / 2 + 1,
	outlineColor = display.COLOR_BLACK,
	align = align_vn,
	dimensions = dimensions_vn,
	valign = v_aling_vn
	})
	self._highLightFrame = display.newSprite("#bigmap_highlight_frame.png")
	self._highLightFrame:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self:addChild(self._highLightFrame)
	self._highLightFrame:setVisible(false)
	self._iconBg:addChild(self._mapName)
	self._lockFrame = display.newSprite("#bigmap_top_small_unlock.png")
	self._lockFrame:setPosition(self._highLightFrame:getPosition())
	self:addChild(self._lockFrame)
	self._lockFrame:setVisible(false)
	self._redTipNode = display.newSprite("#toplayer_mail_tip.png")
	self._redTipNode:setPosition(self:getContentSize().width - self._redTipNode:getContentSize().width / 2, self._redTipNode:getContentSize().height / 2)
	self:addChild(self._redTipNode)
	self._redTipNode:setScale(0.5)
	self._redTipNode:setVisible(false)
end

function BigMapUpCell:create(param)
	local _itemData = param.itemData
	local _viewSize = param.viewSize
	local _idx = param.idx
	local redTip = param.redTip
	self._unLockListener = param.unLockListener
	self:refresh(param)
	self._iconBg:setPosition(self._iconBg:getContentSize().width / 2, _viewSize.height / 2 - 13)
	self._mapName:setPosition(self._iconBg:getContentSize().width / 2, self._iconBg:getContentSize().height / 2 + 5)
	if redTip == 1 then
		self._redTipNode:setVisible(true)
	else
		self._redTipNode:setVisible(false)
	end
	return self
end
function BigMapUpCell:refresh(param)
	--dump(param)
	local _itemData = param.itemData
	local _idx = param.idx
	local _choose = param.choose
	local _bLock = param.bLock
	self._curUnLock = param.curUnLock or false
	self._iconBg:setDisplayFrame(display.newSpriteFrame(_itemData.icon .. ".png"))
	self._mapName:setString(_itemData.name)
	if _choose then
		self._mapName:setColor(display.COLOR_WHITE)
		self._highLightFrame:setVisible(true)
		self:setColor(cc.c3b(255, 255, 255))
	else
		self._mapName:setColor(cc.c3b(137, 137, 137))
		self._highLightFrame:setVisible(false)
		self:setColor(cc.c3b(100, 100, 100))
	end
	if _bLock then
		self._lockFrame:setVisible(true)
	else
		self._lockFrame:setVisible(false)
	end
	if self._curUnLock then
		self._curUnLock = false
		dump(self._unLockListener)
		if self._unLockListener ~= nil then
			self._unLockListener()
		end
		local effect = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "kaiqidaguankadonghua",
		isRetain = false,
		finishFunc = function()
		end
		})
		effect:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
		self:addChild(effect, MAX_ZORDER)
	end
	local redTip = param.redTip
	if redTip == 1 then
		self._redTipNode:setVisible(true)
	else
		self._redTipNode:setVisible(false)
	end
end

function BigMapUpCell:touch(param)
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	dump(param)
end

function BigMapUpCell:runEnterAnim(delayTime)
end

function BigMapUpCell:onTap(x, y)
	--dump("ontttttttttt")
	display.replaceScene(require("game.SubMap.SubMap").new(), "fade", 0.5, display.COLOR_WHITE)
end

function BigMapUpCell:checkButton(x, y)
	return nil
end

return BigMapUpCell