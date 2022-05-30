local YabiaoSpeedUpCommitPopup = class("YabiaoSpeedUpCommitPopup", function()
	return display.newLayer("YabiaoSpeedUpCommitPopup")
end)

function YabiaoSpeedUpCommitPopup:ctor(param)
	self:loadRes()
	self:setUpView(param)
end

function YabiaoSpeedUpCommitPopup:setUpView(param)
	self._disStr = param.disStr
	self:createMask()
	local mainBng = display.newScale9Sprite("#win_base_bg2.png", 0, 0, cc.size(display.width * 0.8, display.width * 0.5)):pos(display.cx, display.cy):addTo(self)
	local mainBngSize = mainBng:getContentSize()
	local innnerBng = display.newScale9Sprite("#win_base_inner_bg_light.png", 0, 0, cc.size(mainBngSize.width * 0.96, mainBngSize.width * 0.48)):pos(mainBngSize.width / 2, mainBngSize.height / 2 - 25):addTo(mainBng)
	local btnCloseRes = {
	normal = "#win_base_close.png",
	pressed = "#win_base_close.png",
	disabled = "#win_base_close.png"
	}
	
	--πÿ±’
	local closeBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = "#win_base_close.png",
	handle = function()
		self:close()
	end
	})
	closeBtn:align(display.CENTER, mainBngSize.width - 30, mainBngSize.height - 30)
	closeBtn:addTo(mainBng)
	
	local innerSize = innnerBng:getContentSize()
	--»∑»œ
	local confirmBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = "ui/new_btn/ui_controlbtn06.png",
	handle = function()
		if param.confirmFunc then
			param.confirmFunc()
		end
		self:close()
	end
	})
	confirmBtn:align(display.CENTER, innerSize.width * 0.2, innerSize.height * 0.2)
	confirmBtn:addTo(innnerBng)
	
	local menuTitle = ui.newBMFontLabel({
	text = common:getLanguageString("@Confirm1"),
	font = "fonts/font_button_red.fnt"
	})
	menuTitle:align(display.CENTER, confirmBtn:getContentSize().width / 2, confirmBtn:getContentSize().height/2)
	confirmBtn:bgAddChild(menuTitle)
	
	local cancelBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = "ui/new_btn/ui_controlbtn06.png",
	handle = function()
		if param.cancelFun then
			param.cancelFun()
		end
		self:close()
	end
	})
	cancelBtn:align(display.CENTER, innerSize.width * 0.8, innerSize.height * 0.2)
	cancelBtn:addTo(innnerBng)
	
	menuTitle = ui.newBMFontLabel({
	text = common:getLanguageString("@Cancel1"),
	font = "fonts/font_button_red.fnt"
	})
	menuTitle:align(display.CENTER, cancelBtn:getContentSize().width / 2, cancelBtn:getContentSize().height/2)
	cancelBtn:bgAddChild(menuTitle)
	
	local label_01 = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@IsCost"),
	size = 20,
	color = cc.c3b(92, 38, 1),
	shadowColor = FONT_COLOR.BLACK,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	local label_02 = ui.newTTFLabelWithShadow({
	text = param.cost,
	size = 20,
	color = cc.c3b(6, 129, 18),
	shadowColor = FONT_COLOR.BLACK,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	local icon = display.newSprite("#icon_gold.png")
	local label_03 = ui.newTTFLabelWithShadow({
	text = self._disStr,
	size = 20,
	color = cc.c3b(92, 38, 1),
	shadowColor = FONT_COLOR.BLACK,
	align = ui.TEXT_ALIGN_CENTER,
	font = FONTS_NAME.font_fzcy
	})
	label_01:align(display.LEFT_CENTER, innerSize.width * 0.12 - 35, innerSize.height * 0.8)
	label_02:align(display.LEFT_CENTER, label_01:getContentSize().width + label_01:getPositionX() + 10, innerSize.height * 0.8)
	icon:setPosition(label_02:getContentSize().width + label_02:getPositionX() + 10, innerSize.height * 0.75)
	label_03:align(display.LEFT_CENTER, icon:getContentSize().width + icon:getPositionX() + 10, innerSize.height * 0.8)
	if self._disStr == common:getLanguageString("@zhaohuanjbc") then
		local offset = 30
		label_01:align(display.LEFT_CENTER, innerSize.width * 0.12 - offset, innerSize.height * 0.8)
		label_02:align(display.LEFT_CENTER, label_01:getContentSize().width + label_01:getPositionX() + 40 - offset, innerSize.height * 0.8)
		icon:setPosition(label_02:getContentSize().width + label_02:getPositionX() + 40 - offset, innerSize.height * 0.75)
		label_03:align(display.LEFT_CENTER, icon:getContentSize().width + icon:getPositionX() + 40 - offset, innerSize.height * 0.8)
	end
	innnerBng:addChild(label_01)
	innnerBng:addChild(label_02)
	innnerBng:addChild(icon)
	innnerBng:addChild(label_03)
	icon:setAnchorPoint(cc.p(0, 0))
end

function YabiaoSpeedUpCommitPopup:createMask()
	local winSize = CCDirector:sharedDirector():getWinSize()
	local mask = CCLayerColor:create()
	mask:setContentSize(winSize)
	mask:setColor(cc.c3b(0, 0, 0))
	mask:setOpacity(150)
	mask:setAnchorPoint(cc.p(0, 0))
	mask:setTouchEnabled(true)
	self:addChild(mask)
end

function YabiaoSpeedUpCommitPopup:loadRes()
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
end

function YabiaoSpeedUpCommitPopup:releaseRes()
	display.removeSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.removeSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
end

function YabiaoSpeedUpCommitPopup:close()
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	self:releaseRes()
	self:removeSelf()
	--self:removeFromParent()
end

return YabiaoSpeedUpCommitPopup