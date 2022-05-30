require("data.data_url")

local UserLogin = class("UserLogin", function ()
	return display.newLayer("UserLogin")
end)

function UserLogin:ctor(param)
	self:loadRes()
	self:setUpView(param)
end

function UserLogin:setUpView(param)
	if game.player.oldUid ==nil or game.player.oldUid=="" then
		game.player.oldUid = game.player.m_uid
	end
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
	local closeBtn = cc.ui.UIPushButton.new(btnCloseRes)
	closeBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			closeBtn:setScale(1.2)
			return true
		elseif event.name == "ended" then
			closeBtn:setScale(1)
			self:close()
		end
	end)
	closeBtn:pos(mainBngSize.width - 30, mainBngSize.height - 30)
	closeBtn:addTo(mainBng):setAnchorPoint(cc.p(0.5, 0.5))
	local innerSize = innnerBng:getContentSize()
	local confirmBtn = display.newSprite("ui/new_btn/ui_controlbtn06.png")
	confirmBtn:setPosition(cc.p(innerSize.width * 0.2, innerSize.height * 0.2))
	confirmBtn:setAnchorPoint(cc.p(0.5, 0.5))
	confirmBtn:setTouchEnabled(true)
	innnerBng:addChild(confirmBtn)
	confirmBtn:setTouchEnabled(true)
	confirmBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			confirmBtn:setScale(1.2)
			return true
		elseif event.name == "ended" then
			if self._editBox ~= nil and self._editBox:getText() ~= "" then
				game.player.m_uid = "Custom__"..self._editBox:getText()
				game.player._CustomAcc = self._editBox:getText()
			end
			self:close()
		end
	end)
	local menuTitle = ui.newTTFLabel({
	text = "账号登录"
	})
	confirmBtn:addChild(menuTitle)
	menuTitle:setPosition(ccp(confirmBtn:getContentSize().width * 0.5, confirmBtn:getContentSize().height * 0.5))
	local cancelBtn = display.newSprite("ui/new_btn/ui_controlbtn06.png")
	cancelBtn:setPosition(cc.p(innerSize.width * 0.8, innerSize.height * 0.2))
	cancelBtn:setAnchorPoint(cc.p(0.5, 0.5))
	cancelBtn:setTouchEnabled(true)
	innnerBng:addChild(cancelBtn)
	cancelBtn:setTouchEnabled(true)
	cancelBtn:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			cancelBtn:setScale(1.2)
			return true
		elseif event.name == "ended" then
			--什么都不做
			if game.player.oldUid~=nil and game.player.oldUid~="" then
				game.player.m_uid = game.player.oldUid
				game.player._CustomAcc = ""
			end
			--show_tip_label(game.player.m_uid)
			self:close()
		end
	end)
	local menuTitle = ui.newTTFLabel({
	text = "设备登录"
	})
	cancelBtn:addChild(menuTitle)
	menuTitle:setPosition(ccp(cancelBtn:getContentSize().width * 0.5, cancelBtn:getContentSize().height * 0.5))
	
	local rowAll = {}
	local rowOneTable = {}
	
	local lvTTF_1 = ResMgr.createOutlineMsgTTF({
	text = "可自定义账号来登录游戏，旧号点设备登录：",
	color = white,
	outlineColor = black,
	size = size
	})
	local lvTTF_2 = ResMgr.createOutlineMsgTTF({
	text = "例如手机号前缀：18911122333_huangdz123",
	color = white,
	outlineColor = black,
	size = size
	})
	local lvTTF_3 = ResMgr.createOutlineMsgTTF({
	text = "登录没有密码验证，不要将账号告诉他人！",
	color = white,
	outlineColor = black,
	size = size
	})
	local lvTTF_4 = ResMgr.createOutlineMsgTTF({
	text = "登录账号：",
	color = ccc3(255, 0, 0),
	outlineColor = red,
	size = size
	})
	
	local row1Table = {
	lvTTF_1
	}
	local row2Table = {
	lvTTF_2
	}
	local row3Table = {
	lvTTF_3
	}
	local row4Table = {
	lvTTF_4
	}
	rowAll = {row1Table, row2Table,row3Table,row4Table}
	
	local heightRate = {
	0.85,
	0.7,
	0.55,
	0.4
	}
	
	for row = 1, #rowAll do
		local node = ResMgr.getArrangedNode(rowAll[row])
		node:setPosition(10.5, heightRate[row] * innnerBng:getContentSize().height)
		innnerBng:addChild(node)
	end
	
	self._editBox = ui.newEditBox({
	image = "#win_base_inner_bg_black.png",
	size = cc.size(300, 35),
	x = innnerBng:getContentSize().width*0.55,
	y = innnerBng:getContentSize().height*0.45
	})
	self._editBox:setFont("fonts/FZCuYuan-M03S.ttf", 22)
	self._editBox:setFontColor(ccc3(255, 255, 0))
	self._editBox:setMaxLength(40)
	self._editBox:setPlaceHolder("点我输入账号")
	self._editBox:setPlaceholderFont("fonts/FZCuYuan-M03S.ttf", 22)
	self._editBox:setPlaceholderFontColor(ccc3(255, 255, 255))
	self._editBox:setReturnType(1)
	self._editBox:setInputMode(0)
	if game.player._CustomAcc ~= nil and game.player._CustomAcc~="" then
		self._editBox:setText(game.player._CustomAcc)
	end
	innnerBng:addChild(self._editBox)
end

function UserLogin:createMask()
	local winSize = CCDirector:sharedDirector():getWinSize()
	local mask = CCLayerColor:create()
	mask:setContentSize(winSize)
	mask:setColor(ccc3(0, 0, 0))
	mask:setOpacity(150)
	mask:setAnchorPoint(cc.p(0, 0))
	mask:setTouchEnabled(true)
	self:addChild(mask)
end

function UserLogin:loadRes()
	display.addSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
end

function UserLogin:releaseRes()
	display.removeSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
	display.removeSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.removeSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
end

function UserLogin:close()
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	self:releaseRes()
	self:removeFromParent()
end

return UserLogin