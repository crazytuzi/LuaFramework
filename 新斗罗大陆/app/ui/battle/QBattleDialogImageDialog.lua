local QBattleDialog = import(".QBattleDialog")
local QBattleDialogImageDialog = class("QBattleDialogImageDialog", QBattleDialog)
local QRichTypewriter = import"...utils.QRichTypewriter"
local prologue_config = import"...tutorial.config.prologue_config"
local QVideoPlayer = import("...video.QVideoPlayer")


local DEFAULT_TYPEWRITER_SPEED = 0.04
function QBattleDialogImageDialog:ctor(options, owner)
    local ccbFile = "Dialog_Newopening.ccbi"
    if owner == nil then
        owner = {}
    end
    owner.click_screen = handler(self, self.onClick)
    owner.jumpToNext = handler(self, self.skipNext)
    QBattleDialogImageDialog.super.ctor(self, ccbFile, owner)
    self._dialog = options.cfg
    self._cfg = prologue_config[options.cfg.dialogs]
    self._context_dialog = owner.context_dialog
    self._tf_name = QRichTypewriter.new(nil,568,{defaultColor = ccc3(255,255,255), defaultSize = 24, stringType = 1, lineSpacing = 2})
    self._tf_name:setAnchorPoint(0,0.5)
    owner.name:addChild(self._tf_name)
    self._tf_word = QRichTypewriter.new(nil,568,{defaultColor = ccc3(255,255,255), defaultSize = 24, stringType = 1, lineSpacing = 2})
    owner.word:addChild(self._tf_word)
    self._tf_word:setAnchorPoint(ccp(0,1)) --设置锚点为0,1保证打字机换行是向下
    self._background = owner.background_img
    self._background:setColor(ccc3(0,0,0))
    self._event_idx = 0
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self:scheduleUpdate_()
    self:registerFunctions()
    self:registerKeys()
    self._pause = false
    self._end_delay = 0
    app.scene:disablePlayBGM()
    self:playNextEvent()
    self._isSkipVideo = false --是否点击视频跳过了
end

function QBattleDialogImageDialog:registerKeys()
    self.key_list = {}
    for idx,cfg in ipairs(self._cfg) do
        if cfg.key then
            self.key_list[cfg.key] = idx
        end
    end
end

function QBattleDialogImageDialog:registerFunctions()
    self.functions = 
    {
        speak = QBattleDialogImageDialog.playString,
        changeBg = QBattleDialogImageDialog.changeBackground,
        hideDialog = QBattleDialogImageDialog.hideTypewriter,
        showDialog = QBattleDialogImageDialog.showTypewriter,
        finish = QBattleDialogImageDialog.playFinish,
        jump = QBattleDialogImageDialog.jumpToKey,
        sound = QBattleDialogImageDialog.playSound,
        music = QBattleDialogImageDialog.playMusic,
        stopMusic = QBattleDialogImageDialog.stopMusic,
        changeBgFadeIn = QBattleDialogImageDialog.fadeInChangeBackground,
        playMp4 = QBattleDialogImageDialog.playMp4,
        playCCBText = QBattleDialogImageDialog.playCCBText,
        delay = QBattleDialogImageDialog.delay,
    }
end

function QBattleDialogImageDialog:playMp4( cfg )
    if not VideoPlayer then
        self:willDoNext()
        self:playNextEvent()
        return
    end
    local sharedFileUtils = CCFileUtils:sharedFileUtils()
    local path = sharedFileUtils:fullPathForFilename(cfg.src)
    if not sharedFileUtils:isFileExist(path) then
        self:willDoNext()
        self:playNextEvent()
        return
    end
    self:pause()
    self._context_dialog:setVisible(false)
    self._ccbOwner.but_skip:setVisible(false)
    local videoPlayer = QVideoPlayer.new()
    videoPlayer:setCompletedCallback(function()
        if self._isSkipVideo then return end
        self._isSkipVideo = true
        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create(0.1))
        arr:addObject(CCCallFunc:create(function()
            videoPlayer:stop()
            self._ccbOwner.but_skip:setVisible(true)
            videoPlayer:removeFromParentAndCleanup(true)
            self._context_dialog:setVisible(not self:isHideTypeWriter())
            self:resume()
            self:playNextEvent()
        end))
        self._ccbNode:runAction(CCSequence:create(arr))
    end)
    videoPlayer:setPosition(ccp(0, 0))
    videoPlayer:setFullScreenEnabled(true)
    videoPlayer:setFileName(cfg.src)
    videoPlayer:setKeepAspectRatioEnabled(true)
    self:addChild(videoPlayer)
    videoPlayer:play()
    self._isSkipVideo = false
end

function QBattleDialogImageDialog:pause()
    self._pause = true
end

function QBattleDialogImageDialog:resume()
    self._pause = false
end

function QBattleDialogImageDialog:changeBackground(cfg)
    -- 这个函数是立刻更换图片 所以只要替换texture就可以了 没有必要新建sprite
    local name = cfg.name
    local src = "res/ui/new_opening/" .. name
    local texture = CCTextureCache:sharedTextureCache():addImage(src)
    if texture then
        self._background:setColor(ccc3(255,255,255))
        self._background:setTexture(texture)
    end
    self._ccbOwner.node_frame:removeAllChildrenWithCleanup()
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
    -- local sprite = CCSprite:create(src)
    -- sprite:setContentSize(self._background:getContentSize())
    -- sprite:setPosition(ccp(self._background:getPositionX(), self._background:getPositionY() ))
    -- self._background:removeFromParentAndCleanup()
    -- self._ccbOwner.p_node:addChild(sprite, -1)
    -- self._background = sprite
end

-- 把打字机内容全部显示
function QBattleDialogImageDialog:showAll()
    self._tf_word:showAll()
end

-- 暂停打字机
function QBattleDialogImageDialog:pauseTypewriter()
    self._tf_word:pause()
end

-- 继续播放打字机
function QBattleDialogImageDialog:resumeTypewriter()
    self._tf_word:resume()
end

function QBattleDialogImageDialog:hideTypewriter()
    self._context_dialog:setVisible(false)
    self._hide_typewriter = true
end

function QBattleDialogImageDialog:showTypewriter()
    self._context_dialog:setVisible(true)
    self._hide_typewriter = false
end

function QBattleDialogImageDialog:isHideTypeWriter()
    return not not self._hide_typewriter
end

-- 播放文本
function QBattleDialogImageDialog:playString(cfg)
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

function QBattleDialogImageDialog:fadeInChangeBackground(cfg)
    local fadeInTime = cfg.fadeIntime or 0.15
    local fadeOutTime = cfg.fadeOuttime or 0.15
    local src = "res/ui/new_opening/" .. cfg.name
    local sprite = CCSprite:create(src)
    sprite:setContentSize(self._background:getContentSize())
    sprite:setPosition(ccp(self._background:getPositionX(), self._background:getPositionY()))
    self._ccbOwner.p_node:addChild(sprite, -1)
    sprite:setOpacity(0)
    self._ccbOwner.node_frame:removeAllChildrenWithCleanup()
    self._ccbOwner.node_frame:setZOrder(-1)

    local right_frame = "res/ui/new_opening/" ..cfg.right_frame or ""
    local left_frame =  "res/ui/new_opening/" ..cfg.left_frame or ""

    if right_frame ~="" and left_frame ~="" then
        local spRightFrame = CCSprite:create(right_frame)
        spRightFrame:setAnchorPoint(ccp(0, 0.5))
        spRightFrame:setPositionX( UI_VIEW_MIN_WIDTH * 0.5 - 2 )
        self._ccbOwner.node_frame:addChild(spRightFrame , -1)

        local spLeftFrame = CCSprite:create(left_frame)
        spLeftFrame:setAnchorPoint(ccp(1, 0.5))
        spLeftFrame:setPositionX( - UI_VIEW_MIN_WIDTH * 0.5 + 2 )
        self._ccbOwner.node_frame:addChild(spLeftFrame, -1)
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
                self:playNextEvent()
            end
        end))
        sprite:runAction(CCSequence:create(arr2))
        makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_frame ,fadeInTime , 255)
    end))
    self._context_dialog:setVisible(false)
    self._background:runAction(CCSequence:create(arr1))
    self:pause()
end

function QBattleDialogImageDialog:loadConfig(idx)
    return self._cfg[idx]
end

function QBattleDialogImageDialog:playFinish(cfg)
    self:finish()
end

function QBattleDialogImageDialog:playNextEvent()
    self._event_idx = self._event_idx + 1
    self:playEvent()
end

function QBattleDialogImageDialog:jumpToKey(cfg)
    self._event_idx = self.key_list[cfg.to]
    self:playEvent()
end

function QBattleDialogImageDialog:playEvent()
    local cfg = self:loadConfig(self._event_idx)
    if not cfg then 
        return
    end
    if cfg.startBuriedPoint then
        app:triggerBuriedPoint(cfg.startBuriedPoint)
    end
    self.functions[cfg.func](self,cfg)
    if cfg.donext then
        self:playNextEvent()
    end
end

function QBattleDialogImageDialog:playMusic(cfg)
    app.sound:playMusic(cfg.src)
end

function QBattleDialogImageDialog:playSound()
    app.sound:playSound(cfg.src)
end

function QBattleDialogImageDialog:skipNext()
    if self._pause then
        return
    end

    self:willDoNext()
    
    if self._tf_word:isPlaying() then
        self._tf_word:showAll()
    end

    local jumpIdx = #self._cfg
    local skipBuriedPoint
    for i = self._event_idx + 1,#self._cfg, 1 do
        local cfg = self:loadConfig(i)
        if cfg.skipKey then
            jumpIdx = i
            if cfg.skipBuriedPoint then
                skipBuriedPoint = cfg.skipBuriedPoint
            end
            break
        end
    end
    if skipBuriedPoint then
        app:triggerBuriedPoint(skipBuriedPoint)
    end
    self._event_idx = math.min(jumpIdx, #self._cfg)
    self:playEvent()
end

function QBattleDialogImageDialog:stopMusic()
    app.sound:stopMusic()
end

function QBattleDialogImageDialog:finish()
    local skip_move = self._dialog == app.battle._victory_dialog and app.battle._force_skip_move 
    self._dialog.finished = true
    --跳过战斗后要直接进入结算界面，如果close会有一瞬间切换到战斗场景，这里不关闭让它盖住战斗场景
    if not skip_move then
        app.scene:enablePlayBGM()
       self:close()
    else
        self:unscheduleUpdate()
        self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
        app.battle:resume()
    end
end

function QBattleDialogImageDialog:close()
    self:unscheduleUpdate()
    self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
    self.super.close(self)
end

function QBattleDialogImageDialog:onClick(event)
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

    self:willDoNext()
    self:playNextEvent()
end

function QBattleDialogImageDialog:willDoNext()
    if self._cur_sound_handle then
        app.sound:stopSound(self._cur_sound_handle)
        self._cur_sound_handle = nil
    end
    self._ccbOwner.text_layer:removeAllChildrenWithCleanup()
    self._charList = nil 
    self._charList_update_left = nil
    self._delay_time = nil
    self._end_delay = 0
    self._context_dialog:setVisible(not self:isHideTypeWriter())
end

function QBattleDialogImageDialog:updateCharList(dt)
    if self._charList == nil or self._charList_update_left == nil then
        return
    end
    self._charList_update_left = self._charList_update_left - dt
    
    if self._charList_update_left <= 0 then
        local char = table.remove(self._charList, 1)
        char:setVisible(true)
        if #self._charList == 0 then
            self._charList = nil
            self._charList_update_left = nil
        else
            self._charList_update_left = DEFAULT_TYPEWRITER_SPEED * 2
        end
    end
end

function QBattleDialogImageDialog:showAllCharList()
    for i,char in ipairs(self._charList) do
        char:setVisible(true)
    end
    self._charList = nil
    self._charList_update_left = nil
end

function QBattleDialogImageDialog:delay(cfg)
    self._delay_time = cfg.time
end

function QBattleDialogImageDialog:playCCBText(cfg)
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
                char = label:getChildren():objectAtIndex(index)
                char:setVisible(false)
                table.insert(charList, char)
            end
        else
            break
        end
    end
    self._charList = charList
    self._charList_update_left = DEFAULT_TYPEWRITER_SPEED * 2

    local sound = cfg.sound
    if sound then
        self._cur_sound_handle = app.sound:playSound(sound)
    end

    self._ccbOwner.text_layer:addChild(ccbNode)
end

function QBattleDialogImageDialog:updateDelay(dt)
    self._delay_time = self._delay_time - dt
    if self._delay_time <= 0 then
        self._delay_time = nil
        self:willDoNext()
        self:playNextEvent()
    end
end

function QBattleDialogImageDialog:_onFrame(dt)
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
    --         self._end_delay = -100
    --         scheduler.performWithDelayGlobal(function()  
    --                 self:onClick()
    --             end, 0)
    --     end
    -- end
end

return QBattleDialogImageDialog