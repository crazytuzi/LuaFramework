require"Lang"
require "widgetmanager"
require "ActionManager"

UIManager = { }

local widget_name = nil
local garbage = { }

function UIManager.init()
    UIManager.screenSize = cc.Director:getInstance():getVisibleSize()
    UIManager.screenOrigin = cc.Director:getInstance():getVisibleOrigin()
    UIManager.gameScene = cc.Scene:create()
    UIManager.gameLayer = cc.Layer:create()
    UIManager.uiLayer = nil
    UIManager.loadingLayer = nil
    UIManager.dialogLayer = nil
    UIManager.gameScene:addChild(UIManager.gameLayer)
    WidgetManager.create("ui_loading")
end

function UIManager.free()
    widget_name = nil
end

function UIManager.purgeCachedData()
    UIManager.gameScene:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create( function()
        -- cc.Director:getInstance():getTextureCache():removeAllTextures()
        cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        cc.CharTextureCache:getInstance():removeUnused()
        -- cc.Director:getInstance():purgeCachedData()
        -- cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
        collectgarbage("collect")
        printInfo("LUA MEMORY %f", collectgarbage("count"))
    end )))
end

function UIManager.showScreen(uiJsonName1, uiJsonName2, uiJsonName3, uiJsonName4)
    if UIManager.uiLayer then
        if UIManager.uiLayer:getChildByName("ui_fight_main") and UITalkFly.layer then
            -- cclog("show fly")
            UITalkFly.fShow()
        end
        local childs = UIManager.uiLayer:getChildren()
        for i = 1, #childs do
            if childs[i] then
                local class = WidgetManager.getClass(childs[i]:getName())
                UIManager.uiLayer:removeChild(childs[i], false)
                if class and class.free then
                    class.free()
                end
            end
        end
        widget_name = ""
    end
    UIManager.uiLayer = cc.Layer:create()
    UIManager.showWidget(uiJsonName1, uiJsonName2, uiJsonName3, uiJsonName4)
    UIManager.gameLayer:removeAllChildren()
    UIManager.gameLayer:addChild(UIManager.uiLayer)
    local function onEnter(aWidgetName)
        local tempWidget = WidgetManager.getClass(aWidgetName)
        if tempWidget and tempWidget.onEnter then
            tempWidget.onEnter()
        end
    end
    if uiJsonName1 ~= nil then
        onEnter(uiJsonName1)
    end
    if uiJsonName2 ~= nil then
        onEnter(uiJsonName2)
    end
    if uiJsonName3 ~= nil then
        onEnter(uiJsonName3)
    end
    if uiJsonName4 ~= nil then
        onEnter(uiJsonName4)
    end
    UIManager.loadingLayer = nil
end

function UIManager.showWidget(aWidgetName1, aWidgetName2, aWidgetName3, aWidgetName4)

    UIManager.popAllScene(true)
    local function replaceWidget(aWidgetName)
        local ui_widget = WidgetManager.create(aWidgetName)
        if ui_widget then
            local prev_uiWidget = UIManager.uiLayer:getChildByTag(ui_widget:getTag())
            if prev_uiWidget then
                local class = WidgetManager.getClass(prev_uiWidget:getName())
                UIManager.uiLayer:removeChild(prev_uiWidget, false)
                if class and class.free then
                    class.free()
                end
            end
            UIManager.uiLayer:addChild(ui_widget)
        end
    end



    if widget_name == nil then
        widget_name = ""
    end
    local temp = ""
    if aWidgetName1 ~= nil then
        temp = temp .. aWidgetName1
    end
    if aWidgetName2 ~= nil then
        temp = temp .. aWidgetName2
    end
    if aWidgetName3 ~= nil then
        temp = temp .. aWidgetName3
    end
    if aWidgetName4 ~= nil then
        temp = temp .. aWidgetName4
    end
    if temp ~= widget_name then

        local colorImg = ccui.ImageView:create()
        colorImg:loadTexture("image/black_shine.png")
        colorImg:setScale(6)
        colorImg:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
        UIManager.gameLayer:addChild(colorImg, 100000)

        if aWidgetName1 ~= nil then
            replaceWidget(aWidgetName1)
        end
        if aWidgetName2 ~= nil then
            replaceWidget(aWidgetName2)
        end
        if aWidgetName3 ~= nil then
            replaceWidget(aWidgetName3)
        end
        if aWidgetName4 ~= nil then
            replaceWidget(aWidgetName4)
        end
        widget_name = temp

        local LayerColor
        local function splashAction()
            if LayerColor then
                UIManager.gameLayer:removeChild(LayerColor, true)
            end
            if not UIGuidePeople.guideFlag then
                ActionManager.UIScreen_SplashAction()
            end
        end
        local function fadeCallback()
            UIManager.gameLayer:removeChild(colorImg, true)
            LayerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 200))
            UIManager.gameLayer:addChild(LayerColor, 100000)
            LayerColor:runAction(cc.Sequence:create(cc.FadeTo:create(0.1, 0), cc.CallFunc:create(splashAction)))
        end
        colorImg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.06, 1), cc.CallFunc:create(fadeCallback)))

    end

    UIManager.purgeCachedData()
end

function UIManager.hideWidget(jsonFileName)
    local class = WidgetManager.getClass(jsonFileName)
    if class and class.Widget:getParent() then
        UIManager.uiLayer:removeChild(class.Widget, false)
        if class.free then
            class.free()
        end
        local _fileNames = utils.stringSplit(widget_name, jsonFileName)
        widget_name = ""
        if _fileNames then
            for key, obj in pairs(_fileNames) do
                widget_name = widget_name .. obj
            end
        end
    end
end

local sceneMap, isPoping = nil, false

local function cleanGarbage()
    if #garbage > 0 then
        UIManager.popScene(garbage[1])
        table.remove(garbage, 1)
    end
end

local function getCloneClass(_widgetName)
    local _className = ""
    local _fileNmes = utils.stringSplit(_widgetName, "_")
    if _fileNmes then
        for _k, _o in pairs(_fileNmes) do
            if _o == "ui" then
                _className = _className .. string.upper(_o)
            else
                _className = _className ..(string.upper(string.sub(_o, 1, 1)) .. string.sub(_o, 2))
            end
        end
    end
    cclog("----------->>>  clone table name = " .. _className)
    return require(_className)
end

local function isCloneClass(_widgetName)
    local _fileNmes = utils.stringSplit(_widgetName, "_")
    if _fileNmes and _fileNmes[#_fileNmes] == "clone" then
        _fileNmes = nil
        return true
    end
end

local function popScene(_flag)
    local class = nil
    if not tolua.isnull(sceneMap[#sceneMap]) then
        local _rootWidget = sceneMap[#sceneMap]:getChildren()[1]
        if _rootWidget and sceneMap[#sceneMap] ~= UIShopRecruitTen.Widget then
            _rootWidget:setScale(dp.DIALOG_SCALE)
        end

        if isCloneClass(sceneMap[#sceneMap]:getName()) then
            class = getCloneClass(sceneMap[#sceneMap]:getName())
        else
            class = WidgetManager.getClass(sceneMap[#sceneMap]:getName())
        end
        UIManager.uiLayer:removeChild(sceneMap[#sceneMap])
    end
    sceneMap[#sceneMap] = nil
    if #sceneMap == 0 then
        sceneMap = nil
    end
    if class then
        if class.free then
            class.free()
        end
        if _flag then
            UIManager.gameLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),
            cc.CallFunc:create( function() WidgetManager.delete(class) end)))
        else
            WidgetManager.delete(class)
        end
    end
    isPoping = false
    UIManager.purgeCachedData()
    cleanGarbage()
end

function UIManager.pushScene(jsonFileName, isAction, scaleTo)
    UIGuidePeople.isPushScene = not isAction
    local ui_widget = WidgetManager.create(jsonFileName)
    local function pushSceneAction(_cloneClass)
        if isPoping and sceneMap then
            if sceneMap and sceneMap[#sceneMap]:getChildren()[1] then
                sceneMap[#sceneMap]:getChildren()[1]:stopAllActions()
            end
            popScene(true)
        end
        if sceneMap == nil then
            sceneMap = { }
        end
        if UIManager.uiLayer:getChildByTag(10000 + #sceneMap) ~= ui_widget then
            sceneMap[#sceneMap + 1] = ui_widget
            UIManager.uiLayer:addChild(ui_widget, #sceneMap + 2, 10000 + #sceneMap)
        end
        local class = _cloneClass and _cloneClass or WidgetManager.getClass(jsonFileName)
        if class and class.onEnter then
            class.onEnter()
        end
        if not isAction then
            ActionManager.PopUpWindow_SplashAction(ui_widget:getChildren()[1], scaleTo)
        end
    end
    pushSceneAction()
    --[[
    if ui_widget and not ui_widget:getParent() then
        pushSceneAction()
    elseif ui_widget:getParent() then
        ui_widget = ui_widget:clone()
        ui_widget:setName(jsonFileName .. "_clone")
        local cloneClass = getCloneClass(ui_widget:getName())
        if cloneClass then
            cloneClass.Widget = ui_widget
            if cloneClass.init then
                cloneClass.init()
            end
            if cloneClass.setup then
                cloneClass.setup()
            end
        end
        pushSceneAction(cloneClass)
    end
    --]]
end

function UIManager.replaceScene(jsonFileName)
    popScene(true)
    UIManager.pushScene(jsonFileName, true)
end

function UIManager.popScene(_flag, _callBack)
    if isPoping then
        if not _flag then
            table.insert(garbage, false)
        else
            table.insert(garbage, _flag)
        end
        return
    end
    if UIManager.uiLayer and sceneMap then
        UIGuidePeople.isPushScene = false
        isPoping = true
        local _rootWidget = sceneMap[#sceneMap]:getChildren()[1]
        if (not _flag) and _rootWidget and sceneMap[#sceneMap] ~= UIShopRecruitTen.Widget then
            _rootWidget:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.1), cc.CallFunc:create( function()
                popScene()
                if _callBack then
                    _callBack()
                end
            end )))
        else
            popScene(true)
        end
    end
end

function UIManager.popAllScene(_flag)
    if sceneMap then
        local size = #sceneMap
        for i = 1, size do
            if i == size and(not _flag) then
                UIManager.popScene()
            else
                popScene(true)
            end
        end
    end
end

function UIManager.getPopWindowCount()
    if sceneMap then
        return #sceneMap
    else
        return 0
    end
end

function UIManager.showLoading()
    if not UIManager.loadingLayer then
        local widgetLoading = WidgetManager.create("ui_loading")
        if widgetLoading == nil then
            cclog("not found ui_loading")
            return
        end
        UIManager.loadingLayer = cc.Layer:create()
        UIManager.loadingLayer:addChild(widgetLoading)
        UIManager.gameLayer:addChild(UIManager.loadingLayer)
    end
end

function UIManager.hideLoading()
    if UIManager.loadingLayer then
        UIManager.loadingLayer:removeAllChildren()
        UIManager.gameLayer:removeChild(UIManager.loadingLayer, true)
        UIManager.loadingLayer = nil
    end
end

function UIManager.showToast(msg, isFit, _callbackFunc)
    local toast_bg = ccui.ImageView:create()
    toast_bg:loadTexture("image/toast_bg.png")

    local text = ccui.Text:create()
    text:setFontName(dp.FONT)
    text:setString(msg)
    text:setFontSize(20)
    text:setTextColor(cc.c4b(255, 255, 255, 255))

    toast_bg:addChild(text)
    if isFit then
        toast_bg:ignoreContentAdaptWithSize(false)
        toast_bg:setContentSize(cc.size(text:getAutoRenderSize().width + 20, text:getAutoRenderSize().height + 10))
    end
    text:setPosition(cc.p(toast_bg:getContentSize().width / 2, toast_bg:getContentSize().height / 2))
    toast_bg:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    UIManager.gameLayer:addChild(toast_bg, 100)
    toast_bg:retain()
    local function hideToast()
        if toast_bg then
            UIManager.gameLayer:removeChild(toast_bg, true)
            cc.release(toast_bg)
        end
        if _callbackFunc then
            _callbackFunc()
        end
    end
    toast_bg:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, 30)), cc.DelayTime:create(1), cc.CallFunc:create(hideToast)))
end

function UIManager.splashVideo()
    local layout = ccui.Layout:create()
    layout:setTouchEnabled(true)
    layout:setContentSize(UIManager.screenSize)
    layout:setTag(-10001)
    local videoPlayer, _isEnterGameing = nil, false
    local enterGame = function()
        if _isEnterGameing then
            return
        end
        _isEnterGameing = true
        UIManager.gameLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create( function()
            if videoPlayer then
                videoPlayer:removeFromParent()
                videoPlayer = nil
                layout:removeFromParent()
                layout = nil
            end

            UIManager.uiLayer:removeAllChildren()
            -- local function callBackFunc()
            -- 	UIManager.uiLayer:removeAllChildren()
            UIManager.showScreen("ui_name")
            -- end
            -- UIFightMain.setData(FightTaskData.Fight_INIT_DATA,nil,dp.FightType.FIGHT_FIRST,callBackFunc)
            -- UIFightMain.loading()
            _videoPlayerFlag = nil
        end )))
    end
    if (not SHOW_VIDEO) or device.platform == "windows" then
        enterGame()
    else
        AudioEngine.stopMusic(true)
        require "cocos.ui.experimentalUIConstants"
        videoPlayer = ccexp.VideoPlayer:create()
        videoPlayer:setTag(-10000)
        local di = SDK.getDeviceInfo()

        local videoPath = "data/doupovideo.mp4"
--        if di.packageName == "com.y2game.doupocangqiong" then
--            videoPath = "brushlist/data/doupovideo.mp4"
--        end
        videoPlayer:setFileName(videoPath)
        local deviceSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
        videoPlayer:setContentSize(deviceSize)
        local isVideoPlaying = false
        videoPlayer:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
        videoPlayer:setTouchEnabled(true)
        videoPlayer:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended and isVideoPlaying then
                videoPlayer:stop()
                enterGame()
            end
        end )
        videoPlayer:setKeepAspectRatioEnabled(true)
        if UIManager.uiLayer then
            local childs = UIManager.uiLayer:getChildren()
            for i = 1, #childs do
                if childs[i] then
                    local class = WidgetManager.getClass(childs[i]:getName())
                    if class and class.free then
                        class.free()
                    end
                end
            end
        end
        UIManager.uiLayer = cc.Layer:create()
        UIManager.gameLayer:removeAllChildren()
        UIManager.gameLayer:addChild(UIManager.uiLayer)
        UIManager.loadingLayer = nil
        local title = ccui.Text:create()
        title:setVisible(false)
        title:setString(Lang.uimanager1)
        title:setFontSize(32)
        title:setPosition(cc.p(UIManager.screenSize.width / 2, title:getContentSize().height))
        UIManager.uiLayer:addChild(title, 10)
        videoPlayer:addEventListener( function(sener, eventType)
            if eventType == ccexp.VideoPlayerEvent.PLAYING then
                if device.platform == "android" then
                    videoPlayer:setFullScreenEnabled(true)
                end
                if not tolua.isnull(title) and not isVideoPlaying then
                    title:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create( function()
                        isVideoPlaying = true
                        title:setVisible(true)
                    end )))
                end
                -- end
            elseif eventType == ccexp.VideoPlayerEvent.PAUSED then
                if device.platform == "android" then
                    if isVideoPlaying then
                        videoPlayer:stop()
                        enterGame()
                    else
                        videoPlayer:play()
                    end
                else
                    UIManager.videoPlayer = videoPlayer
                end
            elseif eventType == ccexp.VideoPlayerEvent.STOPPED then
            elseif eventType == ccexp.VideoPlayerEvent.COMPLETED then
                enterGame()
            end
        end )
        -- UIManager.uiLayer:addChild(videoPlayer)
        UIManager.gameScene:addChild(layout, 20000)
        UIManager.gameScene:addChild(videoPlayer, 20000)

        videoPlayer:play()
        if device.platform == "android" then
            UIManager.uiLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create( function()
                if not isVideoPlaying then
                    videoPlayer:setFullScreenEnabled(true)
                end
            end )))
        end
    end
end

function UIManager.flushWidget(uiItem)
    if uiItem.Widget and uiItem.Widget:getParent() then
        if not uiItem.isFlush then
            uiItem.isFlush = true
        end
        if uiItem == UIFightTask then
            UIFightTask.onEnter()
        else
            uiItem.setup()
        end
    end
end
