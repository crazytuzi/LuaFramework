-- Filename: ShowLogoUI.lua
-- Author: fang
-- Date: 2013-11-06
-- Purpose: 该文件用于显示平台要求的logo

module("ShowLogoUI", package.seeall)

local function fnEnterLogin( ... )
    require "script/ui/login/LoginScene"
    LoginScene.enter()
end

function showLogoUI( ... )
    if g_system_type == kBT_PLATFORM_ANDROID then
        jit.off()--关闭luajit
    end
    require "script/utils/extern"
    local scene = CCScene:create()
    CCDirector:sharedDirector():runWithScene(scene)
    performWithDelay(scene, createBg, 1/30)

end

function createBg( ... )
    require "script/Platform"
    Platform.initSDK()
    require "script/GlobalVars"
    require "script/localized/LocalizedUtil"
    require "script/utils/PreFunction"
    
    
    if(BTUtil:getPlatform() == kBT_PLATFORM_IOS ) then
        -- 注册 烧鸡 本地通知 add by chengliang
        require "script/utils/NotificationUtil"
        NotificationUtil.addChickenEnergyNotification_noon()
        NotificationUtil.addChickenEnergyNotification_evening()
    end

    local needPlatformLogo = false
    local logoName = nil
    local bTlogoName = "images/login/bt_logo.png"
    local iosNotNeedLogo = false

    if(type(Platform.getConfig().getLogoLayer) == "function" 
        and Platform.getConfig().getLogoLayer() ~= nil)then
        local logoParam = Platform.getConfig().getLogoLayer()
        if logoParam.needPlatformLogo == true then
            needPlatformLogo = true
        end
        if logoParam.logoName ~= nil then
            logoName = logoParam.logoName
        end
        if logoParam.bTlogoName ~= nil then
            bTlogoName = logoParam.bTlogoName
        end
        if logoParam.scaleFunction == "setAdaptNode" then
            scaleFunction = setAdaptNode
        elseif logoParam.scaleFunction == "setAllScreenNode" then
            scaleFunction = setAllScreenNode
        else
            print("have no scaleFunction")
        end
    else
        print("config.getLogoLayer() == nil \n The platform don't need a splash screen logo")
    end

    local plName = Platform.getPlatformFlag()
    if(Platform.getPlatformFlag() == "Android_az") then
        needPlatformLogo = true
        logoName = "logo/anzhi_logo.png"
        scaleFunction = setAllScreenNode
    elseif(Platform.getPlatformFlag() == "Android_dl") then
        needPlatformLogo = true
        logoName = "logo/dangle_logo.png"
        scaleFunction = setAdaptNode
    elseif(Platform.getPlatformFlag() == "Android_dk") then
        needPlatformLogo = true
        logoName = "logo/baidu_logo.png"
        scaleFunction = setAllScreenNode
    elseif(Platform.getPlatformFlag() == "Android_taobao") then
        needPlatformLogo = true
        logoName = "logo/taobao.jpg"
        scaleFunction = setAllScreenNode
    elseif(Platform.getPlatformFlag() == "Android_pps") then
        needPlatformLogo = true
        logoName = "logo/pps_logo.png"
        scaleFunction = setAllScreenNode
    elseif(Platform.getPlatformFlag() == "Android_kuwo") then
        needPlatformLogo = true
        logoName = "logo/kuwo_logo.png"
        scaleFunction = setAllScreenNode
    elseif(Platform.getPlatformFlag() == "Android_youmi") then
        needPlatformLogo = true
        logoName = "logo/youmi_logo.png"
        scaleFunction = setAllScreenNode
    elseif(Platform.getPlatformFlag() == "Android_sogou") then
        needPlatformLogo = true
        logoName = "logo/sogou_logo.png"
        scaleFunction = setAllScreenNode
    elseif(Platform.getPlatformFlag() == "Android_muzhiwan") then
        needPlatformLogo = true
        logoName = "logo/muzhiwan_logo.png"
        scaleFunction = setAllScreenNode
    elseif(Platform.getPlatformFlag() == "Android_huaqing") then
        needPlatformLogo = true
        logoName = "logo/huaqing_logo.jpg"
        scaleFunction = setAllScreenNode
    elseif(plName == "IOS_91") then
        needPlatformLogo = true
        logoName = "images/logo/91_ios.png"
        scaleFunction = setAllScreenNode
    elseif(plName == "Android_91") then
        needPlatformLogo = true
        logoName = "images/logo/91_android.png"
        scaleFunction = setAllScreenNode
    elseif(plName == "IOS_WF") then
        needPlatformLogo = true
        logoName = "images/logo/weifeng.png"
        scaleFunction = setAllScreenNode
    elseif(plName == "Android_jinshan") then
        needPlatformLogo = true
        logoName = "logo/jinshan_logo.png"
        scaleFunction = setAdaptNode
    elseif(plName == "Android_pptv") then
        needPlatformLogo = true
        logoName = "logo/pptv_logo.png"
        scaleFunction = setAllScreenNode
    elseif(plName == "Android_yyh") then
        needPlatformLogo = true
        logoName = "logo/yyh_logo.png"
        scaleFunction = setAllScreenNode
    elseif(plName == "Android_ck_dianxin") then
        needPlatformLogo = true
        logoName = "logo/ck_dianxin_logo.jpg"
        scaleFunction = setAllScreenNode
    elseif(plName == "Android_ck_liantong") then
        needPlatformLogo = true
        logoName = "logo/ck_liantong_logo.png"
        scaleFunction = setAllScreenNode
    elseif(plName == "Android_ck_yidongMM") then
        needPlatformLogo = true
        logoName = "logo/ck_yidongMM_logo.jpg"
        scaleFunction = setAllScreenNode
    elseif(plName == "Android_c1wan") then
        needPlatformLogo = true
        logoName = "logo/c1wan_logo.png"
        scaleFunction = setAllScreenNode
    elseif(plName == "Android_4399") then
        needPlatformLogo = true
        logoName = "logo/4399_logo.png"
        scaleFunction = setAllScreenNode
    elseif(plName == "Android_xl") then
        needPlatformLogo = true
        logoName = "logo/xl_logo.jpg"
        scaleFunction = setAllScreenNode
    elseif(plName == "Android_yygame") then
        needPlatformLogo = true
        logoName = "logo/yygame.png"
        scaleFunction = setAllScreenNode
    elseif (plName=="Android_gamesky") then
        needPlatformLogo = true
        logoName = "logo/gamesky_logo.jpg"
        scaleFunction = setAllScreenNode
    elseif (plName=="Android_zhangyue") then
        needPlatformLogo = true
        logoName = "logo/zhangyue_logo.png"
        scaleFunction = setAllScreenNode
    elseif (plName=="Android_pipa") then
        needPlatformLogo = true
        logoName = "logo/pipa_logo.png"
        scaleFunction = setAllScreenNode
    elseif (plName=="Android_kuaiwan") then
        needPlatformLogo = true
        logoName = "logo/kuaiwan_logo.png"
        scaleFunction = setAllScreenNode
    else
        print("other Platform")
    end

    if iosNotNeedLogo == true then
        fnEnterLogin()
        return
    end

    local scene = CCScene:create()
    local logoLayer = CCLayerColor:create(ccc4(255, 255, 255, 255))

    local btLogo = createLogoByName(bTlogoName)
    logoLayer:addChild(btLogo)
    setAdaptNode(btLogo)

    local fristLogo, secondLogo
    fristLogo = btLogo

    if(needPlatformLogo)then
        local platformLogo = createLogoByName(logoName)
        logoLayer:addChild(platformLogo)
        if(scaleFunction == nil)then
            scaleFunction = setAllScreenNode
        end
        scaleFunction(platformLogo)
        if(plName == "Android_ck_dianxin"
         or plName == "Android_ck_liantong"
         or plName == "Android_ck_yidongMM")then
            fristLogo = platformLogo
            secondLogo = btLogo
        else
            fristLogo = btLogo
            secondLogo = platformLogo
        end
        secondLogo:setVisible(false)
    end
    fristLogo:setOpacity(0)

    scene:addChild(logoLayer)
    CCDirector:sharedDirector():replaceScene(scene)
    function getAction( fun )
        function removeSelf(node)
            node:removeFromParentAndCleanup(true)
        end
        local actionArray = CCArray:create()
        actionArray:addObject(CCFadeIn:create(0.3))
        actionArray:addObject(CCDelayTime:create(2))
        actionArray:addObject(CCFadeOut:create(0.3))
        actionArray:addObject(CCCallFuncN:create(removeSelf))
        actionArray:addObject(CCCallFunc:create(function ( ... )
            fun()
        end))
        return actionArray
    end
    
    local fun = function( ... )
        if(needPlatformLogo == false)then
            fnEnterLogin()
        else
            local platformAction = getAction(function( ... )
                fnEnterLogin()
            end)
            secondLogo:setVisible(true)
            local seq = CCSequence:create(platformAction)
            secondLogo:runAction(seq)
        end
    end
    local btAction = getAction(fun)
    local seq = CCSequence:create(btAction)
    fristLogo:runAction(seq)
end

function createLogoByName( l_name )
    local logo    = CCSprite:create(l_name)
    logo:setAnchorPoint(ccp(0.5, 0.5))
    logo:setPosition(ccps(0.5, 0.5))

    return logo
end
