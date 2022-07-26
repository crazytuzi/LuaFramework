require"Lang"

UIActivation = {}

UIActivation.uiRoot = nil
UIActivation.uiText = nil
UIActivation.uiOKOK = nil
UIActivation.uiGoto = nil
UIActivation.uiCode = nil
UIActivation.uiLogo = nil
UIActivation.uiInfo = nil

function UIActivation.init()
end

function UIActivation.setup()
	local channel = SDK.getChannel()
	UIActivation.uiRoot = ccui.Helper:seekNodeByName(UIActivation.Widget, "image_hint")
	UIActivation.uiText = ccui.Helper:seekNodeByName(UIActivation.Widget, "text_title")
	UIActivation.uiGoto = ccui.Helper:seekNodeByName(UIActivation.Widget, "btn_ok")
	UIActivation.uiOKOK = ccui.Helper:seekNodeByName(UIActivation.Widget, "btn_cancel")
	UIActivation.uiLogo = ccui.Helper:seekNodeByName(UIActivation.Widget, "image_canal")
	UIActivation.uiInfo = ccui.Helper:seekNodeByName(UIActivation.Widget, "text_info")
	if channel == "360" then
		UIActivation.uiLogo:loadTexture("ui/jh_360.png")
		UIActivation.uiInfo:setString(Lang.ui_activation1)
	elseif channel == "baidu" then
		UIActivation.uiLogo:loadTexture("ui/jh_baidu.png")
		UIActivation.uiInfo:setString(Lang.ui_activation2)
	elseif channel == "oppo" then
		UIActivation.uiLogo:loadTexture("ui/jh_oppo.png")
		UIActivation.uiInfo:setString(Lang.ui_activation3)
	elseif channel == "uc" then
		UIActivation.uiLogo:loadTexture("ui/jh_jiuyou.png")
		UIActivation.uiInfo:setString(Lang.ui_activation4)
	elseif channel == "xiaomi" then
		UIActivation.uiLogo:loadTexture("ui/jh_xiaomi.png")
		UIActivation.uiInfo:setString(Lang.ui_activation5)
	elseif channel == "y2game" then
		UIActivation.uiLogo:loadTexture("ui/jh_y2.png")
		UIActivation.uiInfo:setString(Lang.ui_activation6)
		UIActivation.uiGoto:setVisible(false)
		local xGoto = UIActivation.uiGoto:getPositionX()
		local xOKOK = UIActivation.uiOKOK:getPositionX()
		UIActivation.uiOKOK:setPositionX((xGoto+xOKOK)/2)
	end
	UIActivation.uiGoto:setPressedActionEnabled(true)
	UIActivation.uiOKOK:setPressedActionEnabled(true)
	local function onTouch(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == UIActivation.uiOKOK then
				local code = UIActivation.uiCode:getText()
				local s,e = code:find("^%a+$")
				if s == 1 and e <= 20 then
					UILogin.activationCode = code
					UIManager.popScene(true)
					UILogin.doLoginOurServer()
				else
					UIManager.showToast(Lang.ui_activation7)
				end
			elseif sender == UIActivation.uiGoto then
				if channel == "360" then
					cc.JNIUtils:browserUrl("http://ka.u.360.cn/id-8700")
				elseif channel == "baidu" then
					cc.JNIUtils:browserUrl("http://duokoo.baidu.com/agame/?R=666&uid=C7623F6BAFF97B8255C9931212A13965%3AFG%3D1&v=2&netFlag=cmnet&dkfrc=15&usid=522F5EE8C76C4FA525B7D5503495A121&pageid=Oxos2yrt&r=derslk2u0l4bo6r&dkfr=game_ah5_home&pos=aghm_chan#P7:tckt?id=3037&pos=aolg_tcks_0")
				elseif channel == "oppo" then
					utils.PromptDialog(nil,Lang.ui_activation8)
				elseif channel == "uc" then
					cc.JNIUtils:browserUrl("http://u.9game.cn/eyjFJZRQ")
				elseif channel == "xiaomi" then
					utils.PromptDialog(nil,Lang.ui_activation9)
				elseif channel == "y2game" then
					--nop
				end
			end
		end
	end
	UIActivation.uiGoto:addTouchEventListener(onTouch)
	UIActivation.uiOKOK:addTouchEventListener(onTouch)
	if UIActivation.uiText then
		UIActivation.uiCode = cc.EditBox:create(UIActivation.uiText:getContentSize(), cc.Scale9Sprite:create())
		UIActivation.uiCode:setPosition(UIActivation.uiText:getPosition())
		UIActivation.uiCode:setPlaceHolder(Lang.ui_activation10)
		UIActivation.uiCode:setMaxLength(20)
		UIActivation.uiCode:setText(UILogin.activationCode and UILogin.activationCode or "")
		UIActivation.uiRoot:addChild(UIActivation.uiCode,1)
		UIActivation.uiText:removeFromParent()
	end
end

function UIActivation.free()
	UIActivation.uiRoot = nil
	UIActivation.uiText = nil
	UIActivation.uiOKOK = nil
	UIActivation.uiGoto = nil
	--UIActivation.uiCode = nil --!!!Fix uiCode nil
	UIActivation.uiLogo = nil
	UIActivation.uiInfo = nil
end
