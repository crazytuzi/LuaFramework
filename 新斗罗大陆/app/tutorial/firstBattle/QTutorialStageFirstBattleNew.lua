local QTutorialStage = import("..QTutorialStage")
local QTutorialStageFirstBattle = class("QTutorialStageFirstBattle", QTutorialStage)
local QTutorialPhaseInFirstBattle = import(".QTutorialPhaseInFirstBattleNew")
local QUIViewController = import("...ui.QUIViewController")
local QRichTypewriter = import"...utils.QRichTypewriter"
local QVideoPlayer = import("...video.QVideoPlayer")

local DEFAULT_TYPEWRITER_SPEED = 0.04
function QTutorialStageFirstBattle:setClickCallBack(callback)
    self._click_callback = function() 
                                self:willDoNext() 
                                callback()
                            end
end

function QTutorialStageFirstBattle:_createPhases()
    table.insert(self._phases, QTutorialPhaseInFirstBattle.new(self))
    self._phaseCount = table.nums(self._phases)
end

function QTutorialStageFirstBattle:start()
    local owner = {}
    local proxy = CCBProxy:create()
    owner.click_screen = handler(self, self.onClick)
    owner.jumpToNext = handler(self, self.skipNextClick)
    self._ccbNode = CCBuilderReaderLoad("Dialog_Newopening.ccbi", proxy, owner)
    self._ccbOwner = owner
    self._ccbProxy = proxy
    self._ccbNode:setPosition(ccp(display.cx,display.cy))
    self._context_dialog = owner.context_dialog
    self._tf_name = QRichTypewriter.new(nil,568,{defaultColor = ccc3(255,255,255), defaultSize = 24, stringType = 1, lineSpacing = 2})
    self._tf_name:setAnchorPoint(0,0.5)
    owner.name:addChild(self._tf_name)
    self._tf_word = QRichTypewriter.new(nil,568,{defaultColor = ccc3(255,255,255), defaultSize = 24, stringType = 1, lineSpacing = 2})
    owner.word:addChild(self._tf_word)
    self._tf_word:setAnchorPoint(ccp(0,1)) --设置锚点为0,1保证打字机换行是向下

    app.tutorialNode:addChild(self._ccbNode)
    self._colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 255), display.width, display.height)
    app.tutorialNode:addChild(self._colorLayer, -1)
    --layer:setPosition(ccp(-display.cx,display.cy))

    self._background = owner.background_img
    self._background:setZOrder(-2)
    self._background:setColor(ccc3(0,0,0))
    CalculateBattleUIPosition(self._ccbOwner.but_skip)
    self._ccbBackground = nil

    self._pause = false 
    self._end_delay = 0
    self.super.start(self)
    self._isSkipVideo = false --是否点击视频跳过了
end

function QTutorialStageFirstBattle:skipNextClick()
    if self._pause then
        return
    end
    
    self:willDoNext()
    
    if self._tf_word:isPlaying() then
        self._tf_word:showAll()
    end

    if self._skip_callback then
        self._skip_callback()
    end
end

function QTutorialStageFirstBattle:setSkipCallback(callback)
    self._skip_callback = callback
end

function QTutorialStageFirstBattle:ended() 
    local stage = app.tutorial:getStage()
    stage.forced = 1
    app.tutorial:setStage(stage)
    app.tutorial:setFlag(stage)
    self._ccbNode:removeFromParentAndCleanup()
    self._colorLayer:removeFromParentAndCleanup()
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_PAGE, uiClass="QUIPageMainMenu"})
end

function QTutorialStageFirstBattle:updateDelay(dt)
    self._delay_time = self._delay_time - dt
    if self._delay_time <= 0 then
        self._delay_time = nil
        self._click_callback()
    end
end

function QTutorialStageFirstBattle:visit(dt)
    self.super.visit(self,dt)
    if self._pause then
        return
    end

    if self._delay_time then
        self:updateDelay(dt)
        return
    end

    self:updateCharList(dt)
    self._tf_word:visit(dt)

    -- if (not self._tf_word:isPlaying()) and (not (self._charList_update_left and self._charList)) then
    --     self._end_delay = self._end_delay + dt
    --     if self._end_delay >= 2 then
    --         self:onClick()
    --     end
    -- end
end

-- 播放文本
function QTutorialStageFirstBattle:playString(cfg)
    local name = cfg.name
    local str = cfg.word
    local speed = cfg.speed or DEFAULT_TYPEWRITER_SPEED
    if speed == 0 then
        speed = nil
    end
    local sound = cfg.sound
    self._tf_name:setString(name)
    self._tf_word:setString(str,speed)
    if sound then
        self._cur_sound_handle = app.sound:playSound(sound)
    end
end

function QTutorialStageFirstBattle:playMp4( cfg )
    if not VideoPlayer then
        self._click_callback()
        return
    end
    local sharedFileUtils = CCFileUtils:sharedFileUtils()
    local path = sharedFileUtils:fullPathForFilename(cfg.src)
    if not sharedFileUtils:isFileExist(path) then
        self._click_callback()
        return
    end
    self:pause()
    self._context_dialog:setVisible(false)
    self._ccbOwner.but_skip:setVisible(false)

    local videoPlayer = QVideoPlayer.new()
    videoPlayer:setCompletedCallback(function()
        if self._isSkipVideo then
            return
        end
        self._isSkipVideo = true
        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create(0.1))
        arr:addObject(CCCallFunc:create(function()
            videoPlayer:stop()
            videoPlayer:removeFromParentAndCleanup(true)
            self._ccbOwner.but_skip:setVisible(true)
            self._context_dialog:setVisible(not self:isHideTypeWriter())
            self:resume()
            self._click_callback()  
        end))
        self._ccbNode:runAction(CCSequence:create(arr))  
    end)
    videoPlayer:setPosition(ccp(-display.cx, -display.cy))
    videoPlayer:setFullScreenEnabled(true)
    videoPlayer:setKeepAspectRatioEnabled(true)
    videoPlayer:setFileName(cfg.src)
    self._ccbNode:addChild(videoPlayer)
    videoPlayer:play()
    self._isSkipVideo = false
end

-- 把打字机内容全部显示
function QTutorialStageFirstBattle:showAll()
    self._tf_word:showAll()
end

-- 暂停
function QTutorialStageFirstBattle:pause()
    self._pause = true
end

function QTutorialStageFirstBattle:resume()
    self._pause = false
end

-- 暂停打字机
function QTutorialStageFirstBattle:pauseTypewriter()
    self._tf_word:pause()
end

-- 继续播放打字机
function QTutorialStageFirstBattle:resumeTypewriter()
    self._tf_word:resume()
end

function QTutorialStageFirstBattle:hideTypewriter()
    self._context_dialog:setVisible(false)
    self._hide_typewriter = true
end

function QTutorialStageFirstBattle:showTypewriter()
    self._context_dialog:setVisible(true)
    self._hide_typewriter = false
end

function QTutorialStageFirstBattle:isHideTypeWriter()
    return not not self._hide_typewriter
end

function QTutorialStageFirstBattle:playCCB(cfg)
    if self._ccbBackground then
        self._ccbBackground:removeFromParentAndCleanup()
        self._ccbBackground = nil
    end
    local owner = {}
    local proxy = CCBProxy:create()
    self._ccbBackground = CCBuilderReaderLoad(cfg.name, proxy, owner)
    -- if owner.fca_view then
    --     local is_loop = cfg.loop == nil and true or cfg.loop
    --     owner.fca_view:stopAnimation()
    --     owner.fca_view:playAnimation("animation", is_loop)
    -- end
    self._ccbBackground:setPosition(ccp(-display.cx, -display.cy))
    self._ccbOwner.p_node:addChild(self._ccbBackground, -1)
    CalculateUIBgSize(self._ccbBackground , 1280)    
    CalculateBattleUIPosition(self._ccbBackground , false)    
end

local function setAllCascadeOpacityEnabled(node)
    node:setCascadeOpacityEnabled(true)
    local children = node:getChildren()
    if children == nil then
        return
    end
    local i = 0
    local len = children:count()
    for i = 0, len - 1, 1 do
        local child = tolua.cast(children:objectAtIndex(i), "CCNode")
        setAllCascadeOpacityEnabled(child)
    end
end

function QTutorialStageFirstBattle:fadeInPlayCCB(cfg)
    local fadeInTime = cfg.fadeIntime or 0.15
    local fadeOutTime = cfg.fadeOuttime or 0.15
    local owner = {}
    local proxy = CCBProxy:create()
    local owner = {}
    local proxy = CCBProxy:create()
    local ccbBackground = CCBuilderReaderLoad(cfg.name, proxy, owner)
    if owner.fca_view then
        local is_loop = cfg.loop == nil and true or cfg.loop
        owner.fca_view:stopAnimation()
        owner.fca_view:playAnimation("animation", is_loop)
    end
    ccbBackground:setPosition(ccp(-display.cx, -display.cy))
    self._ccbOwner.p_node:addChild(ccbBackground, -1)
    setAllCascadeOpacityEnabled(ccbBackground)
    setAllCascadeOpacityEnabled(self._ccbBackground)
    ccbBackground:setOpacity(0)
    CalculateUIBgSize(ccbBackground , 1280)    
    CalculateBattleUIPosition(ccbBackground , false)    
    local arr = CCArray:create()
    arr:addObject(CCFadeOut:create(fadeOutTime))
    arr:addObject(CCCallFunc:create(function()
        self._ccbBackground:removeFromParent()
        self._ccbBackground = ccbBackground
        local newArr = CCArray:create()
        newArr:addObject(CCFadeIn:create(fadeInTime))
        newArr:addObject(CCCallFunc:create(function()   
                                        if cfg.finishDoNext then
                                            self._click_callback()
                                        end
                                    end))
        ccbBackground:runAction(CCSequence:create(newArr))
    end))
    arr:addObject(CCFadeIn:create(fadeInTime))
    self._ccbBackground:runAction(CCSequence:create(arr))
end

function QTutorialStageFirstBattle:changeBackground(cfg)
    -- 这个函数是立刻更换图片 所以只要替换texture就可以了 没有必要新建sprite
    if self._ccbBackground then
        self._ccbBackground:removeFromParentAndCleanup()
        self._ccbBackground = nil
    end
    local name = cfg.name
    local src = "res/ui/new_opening/" .. name
    local texture = CCTextureCache:sharedTextureCache():addImage(src)
    if texture then
        self._background:setColor(ccc3(255,255,255))
        self._background:setTexture(texture)
    end
    local right_frame = "res/ui/new_opening/" ..cfg.right_frame or ""
    local left_frame =  "res/ui/new_opening/" ..cfg.left_frame or ""
    self._ccbOwner.node_frame:removeAllChildrenWithCleanup()

    if right_frame ~="" and left_frame ~="" then
        local spRightFrame = CCSprite:create(right_frame)
        spRightFrame:setAnchorPoint(ccp(0, 0.5))
        spRightFrame:setPositionX( UI_VIEW_MIN_WIDTH * 0.5 - 2 )
        self._ccbOwner.node_frame:addChild(spRightFrame)

        local spLeftFrame = CCSprite:create(left_frame)
        spLeftFrame:setAnchorPoint(ccp(1, 0.5))
        spLeftFrame:setPositionX( - UI_VIEW_MIN_WIDTH * 0.5 + 2 )
        self._ccbOwner.node_frame:addChild(spLeftFrame)
    end
    -- local sprite = CCSprite:create(src)
    -- sprite:setContentSize(self._background:getContentSize())
    -- sprite:setPosition(ccp(self._background:getPositionX(), self._background:getPositionY() ))
    -- self._background:removeFromParentAndCleanup()
    -- self._ccbOwner.p_node:addChild(sprite, -1)
    -- self._background = sprite
end

function QTutorialStageFirstBattle:fadeInChangeBackground(cfg)
    if self._ccbBackground then
        self._ccbBackground:removeFromParentAndCleanup()
        self._ccbBackground = nil
    end
    local fadeInTime = cfg.fadeIntime or 0.15
    local fadeOutTime = cfg.fadeOuttime or 0.15
    local src = "res/ui/new_opening/" .. cfg.name


    local sprite = CCSprite:create(src)
    sprite:setContentSize(self._background:getContentSize())
    sprite:setPosition(ccp(self._background:getPositionX(), self._background:getPositionY()))
    self._ccbOwner.p_node:addChild(sprite, -5)
    sprite:setOpacity(0)

    self._ccbOwner.node_frame:removeAllChildrenWithCleanup()
    self._ccbOwner.node_frame:setZOrder(-1)

    local right_frame = "res/ui/new_opening/" ..cfg.right_frame or ""
    local left_frame =  "res/ui/new_opening/" ..cfg.left_frame or ""

    if right_frame ~="" and left_frame ~="" then
        local spRightFrame = CCSprite:create(right_frame)
        spRightFrame:setAnchorPoint(ccp(0, 0.5))
        spRightFrame:setPositionX( UI_VIEW_MIN_WIDTH * 0.5 - 2 )
        self._ccbOwner.node_frame:addChild(spRightFrame)

        local spLeftFrame = CCSprite:create(left_frame)
        spLeftFrame:setAnchorPoint(ccp(1, 0.5))
        spLeftFrame:setPositionX( - UI_VIEW_MIN_WIDTH * 0.5 + 2 )
        self._ccbOwner.node_frame:addChild(spLeftFrame)
    end
    makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_frame ,0 , 0)



    local arr1 = CCArray:create()
    arr1:addObject(CCScaleTo:create(0,2,2))
    arr1:addObject(CCFadeOut:create(fadeOutTime))
    arr1:addObject(CCCallFunc:create(function()
        local arr2 = CCArray:create()
        arr2:addObject(CCFadeIn:create(fadeInTime))
        arr2:addObject(CCCallFunc:create(function()
            --self._ccbOwner.node_frame:removeAllChildrenWithCleanup()
            self._context_dialog:setVisible(not self:isHideTypeWriter())
            self._background:removeFromParentAndCleanup()
            self._background = sprite
            self:resume()
            if cfg.finishDoNext then
                self._click_callback()
            end
        end))
        sprite:runAction(CCSequence:create(arr2))
        makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_frame ,fadeInTime , 255)
    end))
    
    self._context_dialog:setVisible(false)
    self._background:runAction(CCSequence:create(arr1))
    self:pause()
end

function QTutorialStageFirstBattle:playMusic(cfg)
    app.sound:playMusic(cfg.src)
end

function QTutorialStageFirstBattle:playSound()
    app.sound:playSound(cfg.src)
end

function QTutorialStageFirstBattle:stopMusic()
    app.sound:stopMusic()
end

function QTutorialStageFirstBattle:willDoNext()
    if self._cur_sound_handle then
        app.sound:stopSound(self._cur_sound_handle)
        self._cur_sound_handle = nil
    end
    if not self._ccbOwner.text_layer then
        return
    end
    self._ccbOwner.text_layer:removeAllChildrenWithCleanup()
    self._charList = nil 
    self._charList_update_left = nil
    self._in_charlist_finish_delay = false
    self._delay_time = nil
    self._end_delay = 0
    self._context_dialog:setVisible(not self:isHideTypeWriter())
end

function QTutorialStageFirstBattle:updateCharList(dt)
    if self._charList == nil or self._charList_update_left == nil then
        return
    end
    self._charList_update_left = self._charList_update_left - dt
    if self._charList_update_left <= 0 then
        local char = table.remove(self._charList, 1)
        char:setVisible(true)
        if #self._charList == 0 then
            local donext = self._charList.cfg.finishDoNext
            local delay_time = self._charList.cfg.finish_delay or 2
            self._charList = nil
            self._charList_update_left = nil
            if donext then
                self._in_charlist_finish_delay = true
                scheduler.performWithDelayGlobal(function()
                    if self._in_charlist_finish_delay == true then
                        self._click_callback()
                    end
                end, delay_time)
            end
        else
            self._charList_update_left = DEFAULT_TYPEWRITER_SPEED * 2
        end
    end
end

function QTutorialStageFirstBattle:showAllCharList()
    for i,char in ipairs(self._charList) do
        char:setVisible(true)
    end
    self._charList = nil
    self._charList_update_left = nil
end

function QTutorialStageFirstBattle:playCCBText(cfg)
    local owner = {}
    local proxy = CCBProxy:create()
    local ccbNode = CCBuilderReaderLoad(cfg.src, proxy, owner)

    local charList = {}
    self._context_dialog:setVisible(false)
    local i = 0
    while true do
        i = i + 1
        local label = owner["text_"..i]
        if label then
            for index = 0, (label:getChildrenCount() - 1) do
                local char = label:getChildren():objectAtIndex(index)
                char:setVisible(false)
                table.insert(charList, char)
            end
        else
            break
        end
    end
    charList.cfg = cfg
    self._charList = charList
    self._charList_update_left = DEFAULT_TYPEWRITER_SPEED * 2

    local sound = cfg.sound
    if sound then
        self._cur_sound_handle = app.sound:playSound(sound)
    end

    self._ccbOwner.text_layer:addChild(ccbNode)
end

function QTutorialStageFirstBattle:fadeOutScene(time, value, endCallback)
    setAllCascadeOpacityEnabled(self._ccbOwner.p_node)
    local arr = CCArray:create()
    arr:addObject(CCFadeTo:create(time,value * 255))
    arr:addObject(CCCallFunc:create(function()
        endCallback()
    end))
    self._ccbOwner.p_node:runAction(CCSequence:create(arr))
end

function QTutorialStageFirstBattle:delay(cfg)
    self._delay_time = cfg.time
end

function QTutorialStageFirstBattle:onClick()
    if self._pause then
        return
    end

    if self._delay_time then
        return
    end

    if self._tf_word:isPlaying() then
        self._tf_word:showAll()
        return
    end

    if self._charList_update_left and self._charList then
        self:showAllCharList()
        return
    end

    if self._click_callback then
        self._click_callback()
    end
end

return QTutorialStageFirstBattle