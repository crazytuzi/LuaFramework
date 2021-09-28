--------------------------------------------------------------------------------------
-- 文件名:	GameSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	陆奎安
-- 日  期:	2013-1-22 9:37
-- 版  本:	1.0
-- 描  述:	系统界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------
Game_System1 = class("Game_System1")
Game_System1.__index = Game_System1
g_bShowFacebookShare = false
--
local function onButton_FacebookShare()
    g_FacebookRewardSys:ShowShareView()	
end

local function loginOutUC()
    if g_Cfg.Platform == kTargetAndroid then
		if UCManager:getInstance():checkLogined() then
            UCManager:getInstance():loginOut()
        end
	end		
end

local function setButton_Sleep(Button_Sleep, bPreventSleep)
	local Image_FuncIcon = tolua.cast(Button_Sleep:getChildByName("Image_FuncIcon"),"ImageView")
	Image_FuncIcon:getChildByName("Image_Mute"):setVisible(bPreventSleep)
	if g_Cfg.Platform ~= kTargetWindows then
		ScreenLock:setScreenLockDisabled(bPreventSleep)
	end
end

local function setButton_Sound(Button_Sound, IsMuteSoundEffet)
	local Image_FuncIcon = tolua.cast(Button_Sound:getChildByName("Image_FuncIcon"),"ImageView")
	Image_FuncIcon:getChildByName("Image_Mute"):setVisible(IsMuteSoundEffet)
	if IsMuteSoundEffet then
		if g_Cfg.Platform == kTargetWindows then
			--Windos设置音量功能无
		else
			SimpleAudioEngine:sharedEngine():setEffectsVolume(0)
		end
	else
		if g_Cfg.Platform == kTargetWindows then
			--Windos设置音量功能无
		else
			SimpleAudioEngine:sharedEngine():setEffectsVolume(1)
		end
	end
end

local function setButton_Music(Button_Music, IsMuteSoundMusic)
	local Image_FuncIcon = tolua.cast(Button_Music:getChildByName("Image_FuncIcon"),"ImageView")
	Image_FuncIcon:getChildByName("Image_Mute"):setVisible(IsMuteSoundMusic)
	if IsMuteSoundMusic then
		if g_Cfg.Platform == kTargetWindows then
			SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
		else
			SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0)
		end
	else
		if g_Cfg.Platform == kTargetWindows then
			SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
		else
			SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(1)
		end
	end
end

function Game_System1:initWnd()
	local Image_SystemPNL =  tolua.cast(self.rootWidget:getChildByName("Image_SystemPNL"),"ImageView")
	local Image_ContentPNL =  tolua.cast(Image_SystemPNL:getChildByName("Image_ContentPNL"),"ImageView")
	
	local Button_Sleep =  tolua.cast(Image_ContentPNL:getChildByName("Button_Sleep"),"Button")
    Button_Sleep:setTouchEnabled(true)
    local function onClickSleep(pSender,eventType)
        if eventType ==ccs.TouchEventType.ended then
		    local IsPreventSleep = CCUserDefault:sharedUserDefault():getBoolForKey("IsPreventSleep", false)
            CCUserDefault:sharedUserDefault():setBoolForKey("IsPreventSleep", not IsPreventSleep)
            setButton_Sleep(Button_Sleep, not IsPreventSleep)
        end
    end 
    Button_Sleep:addTouchEventListener(onClickSleep)  

	local Button_Sound =  tolua.cast(Image_ContentPNL:getChildByName("Button_Sound"),"Button") 
	Button_Sound:setTouchEnabled(true)
    local function onClickSound(pSender,eventType)
        if eventType == ccs.TouchEventType.ended then
            local IsMuteSoundEffet = CCUserDefault:sharedUserDefault():getBoolForKey("IsMuteSoundEffet", false)
            CCUserDefault:sharedUserDefault():setBoolForKey("IsMuteSoundEffet", not IsMuteSoundEffet)
            setButton_Sound(Button_Sound, not IsMuteSoundEffet)	
        end
    end 
    Button_Sound:addTouchEventListener(onClickSound)

	local Button_Music =  tolua.cast(Image_ContentPNL:getChildByName("Button_Music"),"Button") 
    Button_Music:setTouchEnabled(true)
    local function onClickMusic(pSender,eventType)
        if eventType ==ccs.TouchEventType.ended then
			local IsMuteSoundMusic = CCUserDefault:sharedUserDefault():getBoolForKey("IsMuteSoundMusic", false)
			CCUserDefault:sharedUserDefault():setBoolForKey("IsMuteSoundMusic", not IsMuteSoundMusic)
			setButton_Music(Button_Music, not IsMuteSoundMusic)
        end
    end 
    Button_Music:addTouchEventListener(onClickMusic)

	local Button_SwitchServer =  tolua.cast(Image_ContentPNL:getChildByName("Button_SwitchServer"),"Button") 
    Button_SwitchServer:setTouchEnabled(true)
    local function onClickLoginOut(pSender,eventType)
        if eventType ==ccs.TouchEventType.ended then
			 g_GamePlatformSystem:OnClickGameLoginOut()
        end
    end 
    Button_SwitchServer:addTouchEventListener(onClickLoginOut)
	
	local Button_Logout =  tolua.cast(Image_ContentPNL:getChildByName("Button_Logout"),"Button") 
    Button_Logout:setTouchEnabled(true)
    local function onClickLoginOut(pSender,eventType)
        if eventType == ccs.TouchEventType.ended then
			g_GamePlatformSystem:OnClickGameLoginOut()
        end
    end 
    Button_Logout:addTouchEventListener(onClickLoginOut)

	local Button_AboutUs =  tolua.cast(Image_ContentPNL:getChildByName("Button_AboutUs"),"Button") 
	Button_AboutUs:setTouchEnabled(true)
    local function onClick_AboutUs(pSender,eventType)
        if eventType == ccs.TouchEventType.ended then
			if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_zh_CN or g_LggV.LanguageVer == eLanguageVer.LANGUAGE_zh_AUDIT then
				g_WndMgr:showWnd("Game_AboutUs")
			end
        end
    end 
    Button_AboutUs:addTouchEventListener(onClick_AboutUs)

    if g_strAndroidTS == "open" then
        local ScrollView_FunctionList = tolua.cast(Image_ContentPNL:getChildByName("ScrollView_FunctionList"),"ScrollView")
        local Label_QQ1 = tolua.cast(ScrollView_FunctionList:getChildByName("Label_QQ1"),"Label")
        Label_QQ1:setText("客服电话：4006668223")
        if g_bVersionAndroid_0_0_ == "jinli_1.0.1" then
            Label_QQ1:setText("")
        end
    end
end

--显示主界面的伙伴详细介绍界面
function Game_System1:openWnd()
	local Image_SystemPNL =  tolua.cast(self.rootWidget:getChildByName("Image_SystemPNL"),"ImageView")
	local Image_ContentPNL =  tolua.cast(Image_SystemPNL:getChildByName("Image_ContentPNL"),"ImageView")
	
	local IsPreventSleep = CCUserDefault:sharedUserDefault():getBoolForKey("IsPreventSleep", false)
	local Button_Sleep =  tolua.cast(Image_ContentPNL:getChildByName("Button_Sleep"),"Button")
	local Image_FuncIcon_Sleep = tolua.cast(Button_Sleep:getChildByName("Image_FuncIcon"),"ImageView")
	Image_FuncIcon_Sleep:getChildByName("Image_Mute"):setVisible(IsPreventSleep)
	
	local IsMuteSoundEffet = CCUserDefault:sharedUserDefault():getBoolForKey("IsMuteSoundEffet", false)
	local Button_Sound =  tolua.cast(Image_ContentPNL:getChildByName("Button_Sound"),"Button") 
	local Image_FuncIcon_Sound = tolua.cast(Button_Sound:getChildByName("Image_FuncIcon"),"ImageView")
	Image_FuncIcon_Sound:getChildByName("Image_Mute"):setVisible(IsMuteSoundEffet)
	
	local IsMuteSoundMusic = CCUserDefault:sharedUserDefault():getBoolForKey("IsMuteSoundMusic", false)
	local Button_Music =  tolua.cast(Image_ContentPNL:getChildByName("Button_Music"),"Button") 
	local Image_FuncIcon_Music = tolua.cast(Button_Music:getChildByName("Image_FuncIcon"),"ImageView")
	Image_FuncIcon_Music:getChildByName("Image_Mute"):setVisible(IsMuteSoundMusic)
	
	local Label_ServerName = tolua.cast(Image_ContentPNL:getChildByName("Label_ServerName"), "Label")
	Label_ServerName:setText(string.format(_T("当前服务器：%s"), g_ServerList:GetLocalName()))
    if g_strStandAloneGame == "open" then
        Label_ServerName:setVisible(false)
        local Button_SwitchServer =  tolua.cast(Image_ContentPNL:getChildByName("Button_SwitchServer"),"Button") 
        Button_SwitchServer:setVisible(false)
        local Button_Logout =  tolua.cast(Image_ContentPNL:getChildByName("Button_Logout"),"Button")
        Button_Logout:setVisible(false)
    end
end

function Game_System1:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_SystemPNL = tolua.cast(self.rootWidget:getChildByName("Image_SystemPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_SystemPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_System1:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_SystemPNL = tolua.cast(self.rootWidget:getChildByName("Image_SystemPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_SystemPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end

function Game_System1:ModifyWnd_viet_VIET()
	local Image_SystemPNL =  tolua.cast(self.rootWidget:getChildByName("Image_SystemPNL"),"ImageView")
	local Image_ContentPNL =  tolua.cast(Image_SystemPNL:getChildByName("Image_ContentPNL"),"ImageView")
    local Button_FacebookShare = tolua.cast(Image_ContentPNL:getChildAllByName("Button_FacebookShare"), "Button")
    if g_bShowFacebookShare == false then
        Button_FacebookShare:setVisible(false)
        return
    end

    Button_FacebookShare:setVisible(g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET)
    g_SetBtnWithPressImage(Button_FacebookShare, 1, onButton_FacebookShare, true, 1)
    if g_FacebookRewardSys and g_FacebookRewardSys.bShare == true then
        Button_FacebookShare:setTouchEnabled(false)
        g_SetBtnBright(Button_FacebookShare, false)
    end

end

function Game_System1:OnFacebookShare()
    if g_FacebookRewardSys and g_FacebookRewardSys.bShare == true then
        Button_FacebookShare:setTouchEnabled(false)
        g_SetBtnBright(Button_FacebookShare, false)
    end
end