require"Lang"
UISettings = { }

local function setSwitch()
    local image_base_music = ccui.Helper:seekNodeByName(UISettings.Widget, "image_base_music")
    local image_base_sound = ccui.Helper:seekNodeByName(UISettings.Widget, "image_base_sound")
    local btn_music = image_base_music:getChildByName("btn_open")
    local btn_sound = image_base_sound:getChildByName("btn_open")
    if dp.musicSwitch then
        btn_music:setTitleText(Lang.ui_settings1)
    else
        btn_music:setTitleText(Lang.ui_settings2)
    end
    if dp.soundSwitch then
        btn_sound:setTitleText(Lang.ui_settings3)
    else
        btn_sound:setTitleText(Lang.ui_settings4)
    end
end

function UISettings.init()
    local btn_close = ccui.Helper:seekNodeByName(UISettings.Widget, "btn_close")
    local image_base_music = ccui.Helper:seekNodeByName(UISettings.Widget, "image_base_music")
    local image_base_sound = ccui.Helper:seekNodeByName(UISettings.Widget, "image_base_sound")
    local image_base_notice = ccui.Helper:seekNodeByName(UISettings.Widget, "image_base_notice")
    local image_base_back_0 = ccui.Helper:seekNodeByName(UISettings.Widget, "image_base_back_0")
    local image_base_back = ccui.Helper:seekNodeByName(UISettings.Widget, "image_base_back")
    if SDK.getChannel() == "y2game" or SDK.getChannel() == "iosy2game" or SDK.getChannel() == "iosy2gamenew" or SDK.getDeviceInfo().packageName == "com.doupo.zhuoyi.zy" then
        image_base_back:getChildByName("text_back"):setString(Lang.ui_settings5)
    end
    local btn_music = image_base_music:getChildByName("btn_open")
    local btn_sound = image_base_sound:getChildByName("btn_open")
    local btn_notice = image_base_notice:getChildByName("btn_open")
    local btn_cdk = image_base_back_0:getChildByName("btn_open")
    local btn_back = image_base_back:getChildByName("btn_open")
    if SDK.getChannel() == "y2game" or SDK.getChannel() == "iosy2game" or SDK.getChannel() == "iosy2gamenew" or SDK.getDeviceInfo().packageName == "com.doupo.zhuoyi.zy" then
        btn_back:setTitleText(Lang.ui_settings6)
    end
    btn_close:setPressedActionEnabled(true)
    btn_music:setPressedActionEnabled(true)
    btn_sound:setPressedActionEnabled(true)
    btn_notice:setPressedActionEnabled(true)
    btn_cdk:setPressedActionEnabled(true)
    btn_back:setPressedActionEnabled(true)

    if IOS_PREVIEW then
        image_base_back_0:hide()
        image_base_music:setPositionY(401)
        image_base_sound:setPositionY(307.33)
        image_base_notice:setPositionY(213.67)
        image_base_back:setPositionY(120)
    end

    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_music then
                dp.musicSwitch = not dp.musicSwitch
                if dp.musicSwitch then
                    AudioEngine.resumeMusic()
                    if not AudioEngine.isMusicPlaying() then
                        AudioEngine.playMusic("sound/bg_music.mp3", true)
                    end
                else
                    AudioEngine.pauseMusic()
                end
                setSwitch()
                cc.UserDefault:getInstance():setStringForKey("musicSwitch", dp.musicSwitch and "1" or "0")
            elseif sender == btn_sound then
                dp.soundSwitch = not dp.soundSwitch
                setSwitch()
                cc.UserDefault:getInstance():setStringForKey("soundSwitch", dp.soundSwitch and "1" or "0")
            elseif sender == btn_notice then
                cc.JNIUtils:showGameNotice(dp.NOTICE_URL)
            elseif sender == btn_back then
                if SDK.getChannel() == "y2game" or SDK.getChannel() == "iosy2game" or SDK.getChannel() == "iosy2gamenew" or SDK.getDeviceInfo().packageName == "com.doupo.zhuoyi.zy" then
                    SDK.doUserCenter("no param")
                else
                    UIManager.popScene()
                    dp.Logout()
                    UIHomePage.hideMore()
                    if device.platform == "android" then
                        SDK.doLogout("no param")
                    end
                end
            elseif sender == btn_cdk then
                UIManager.pushScene("ui_settings_hint")
            end
        end
    end
    btn_close:addTouchEventListener(onBtnEvent)
    btn_music:addTouchEventListener(onBtnEvent)
    btn_sound:addTouchEventListener(onBtnEvent)
    btn_notice:addTouchEventListener(onBtnEvent)
    btn_cdk:addTouchEventListener(onBtnEvent)
    btn_back:addTouchEventListener(onBtnEvent)
end

function UISettings.setup()
    setSwitch()
end

function UISettings.free()

end
