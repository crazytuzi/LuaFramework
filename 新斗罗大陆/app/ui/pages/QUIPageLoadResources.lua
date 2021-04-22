
local QUIPage = import(".QUIPage")
local QUIPageLoadResources = class("QUIPageLoadResources", QUIPage)

local QUIWidgetLoadBar = import("..widgets.QUIWidgetLoadBar")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRectUiMask = import("...ui.battle.QRectUiMask")
local QBaseLoader = import("...loader.QBaseLoader")


function QUIPageLoadResources:ctor(options)
    if options ~= nil then
        self._dungeonConfig = options.dungeon
    end
    --local loadConfig = self:_getLoadConfig() --循环测试加载背景
    local loadConfig = self:_getLoadConfig()
    local ccbFile = loadConfig.base_map or "ccb/Page_Login_yilidan_wjb.ccbi"
    local right_frame = loadConfig.right_frame or ""
    local left_frame = loadConfig.left_frame or ""



    QUIPageLoadResources.super.ctor(self, ccbFile, nil, options)
    self._view2 = CCNode:create()
    self._view:addChild(self._view2)
    self._view2:setVisible(false)

    CalculateBattleUIPosition(self:getView())



    self._backTouchLayer = CCLayerColor:create(ccc4(0, 0, 0, 255), display.width, display.height)
    self._backTouchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._backTouchLayer:setTouchSwallowEnabled(true)
    self._backTouchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            return true
        elseif event.name == "moved" then
            
        elseif event.name == "ended" then
            
        elseif event.name == "cancelled" then
            
        end
    end)
    self._backTouchLayer:setTouchEnabled(true)

    self._view:addChild(self._backTouchLayer, -1)


    local dis_offside = display.ui_width - UI_VIEW_MIN_WIDTH
    dis_offside = dis_offside * 0.5
    dis_offside = math.ceil(dis_offside)
    if right_frame ~= "" then
        local _spRightFrame = CCSprite:create(right_frame)
        if _spRightFrame then
            _spRightFrame:setAnchorPoint(ccp(0, 0.5))
            _spRightFrame:setPositionX( display.ui_width  - dis_offside - 2 )
            _spRightFrame:setPositionY( display.height * 0.5 )
            self._view:addChild(_spRightFrame,-1)
        end
    end

    if left_frame ~= "" then
        local _spLeftFrame = CCSprite:create(left_frame)
        if _spLeftFrame then
            _spLeftFrame:setAnchorPoint(ccp(1, 0.5))
            _spLeftFrame:setPositionY( display.height * 0.5  + 2)
            _spLeftFrame:setPositionX(dis_offside)
            self._view:addChild(_spLeftFrame,-1)
        end
    end


    self._bar = QUIWidgetLoadBar.new()
    self._ccbOwner.progress:addChild(self._bar)
    self._bar:setPercentVisible(false)
    self._bar:setTipVisible(true)
    CalculateUIBgSize(self._ccbOwner.progress , 1280)
    -- game tips, maximum 10 tips @qinyuanji
    self._gameTipsText = {}
    math.randomseed(q.OSTime()) 
    -- rawGameTips = nil --测试用 gametips_universal
    if self._dungeonConfig then
        local rawGameTips = QStaticDatabase.sharedDatabase():getGameTipsByID(self._dungeonConfig.id)
        if rawGameTips then
            for i = 1, 10 do
                local gametip = rawGameTips["gametips_" .. tostring(i)]
                if gametip ~= nil then
                    table.insert(self._gameTipsText, gametip)
                else 
                    break
                end
            end
            if #self._gameTipsText == 0 then
                self._bar:setTip("")
            else
                self._randomIndex = math.random(#self._gameTipsText)
                self:_setRandomeTips()
            end
        else
            -- 量表中缺省，从默认量表gametips_universal中读取
            -- math.randomseed(q.OSTime())
            local rawGameTips = QStaticDatabase.sharedDatabase():getGameTipsByLevel(remote.user.level)
            -- print("QUIPageLoadResources:ctor ===> ", remote.user.level)
            -- printTable(rawGameTips, "#")
            if rawGameTips ~= nil then
                local index = math.random(#rawGameTips)
                self._bar:setTip(rawGameTips[index].universal_tips)
            else
                self._bar:setTip("")
            end
        end
    else
        -- 量表中缺省，从默认量表gametips_universal中读取
        -- math.randomseed(q.OSTime())
        local rawGameTips = QStaticDatabase.sharedDatabase():getGameTipsByLevel(remote.user.level)
        -- print("QUIPageLoadResources:ctor ===> ", remote.user.level)
        -- printTable(rawGameTips, "#")
        if rawGameTips ~= nil then
            local index = math.random(#rawGameTips)
            self._bar:setTip(rawGameTips[index].universal_tips)
        else
            self._bar:setTip("")
        end
    end

    -- self:_setBarPercent(0)
    self._bar:setPercent(0)

    set_replay_pseudo_id(0)

    -- Start loading resources
    -- @qinyuanji, accept a loader object to do load stuff, this class is only for display
    self._loader = options.loader
    self._loader:addEventListener(QBaseLoader.PROGRESSING, handler(self, self._onProgressing))
    self._loader:addEventListener(QBaseLoader.END, handler(self, self._onFinish))
    self._loader:start()
    if CCNode.wakeup then
        self._bar:wakeup()
    end

    if self._gameTips ~= nil and #self._gameTipsText > 0 then
        local config = QStaticDatabase:sharedDatabase():getConfiguration()
        self._tipSwitchingId = scheduler.scheduleGlobal(handler(self, QUIPageLoadResources._onTipSwitching), config.TIPS and config.TIPS.value or 2)
    end

    -- 角标
    if self._ccbOwner.sp_ad then
        self._ccbOwner.sp_ad:setVisible(false)
        local cornerMark = loadConfig.corner_mark
        if cornerMark then
            local spriteFrame = QSpriteFrameByPath(cornerMark)
            if spriteFrame then
                self._ccbOwner.sp_ad:setDisplayFrame(spriteFrame)
                self._ccbOwner.sp_ad:setVisible(true)
            end
        end
    end
end

function QUIPageLoadResources:viewWillDisappear()
    QUIPageLoadResources.super.viewWillDisappear(self)
    if self._loader then 
        self._loader:removeAllEventListeners() 
        self._loader = nil
    end
end

function QUIPageLoadResources:_getLoadConfig1() 
    local config = QStaticDatabase.sharedDatabase():getGameLoad()
    local index_ = app:getUserData():getUserValueForKey("Load_Rescore_Index") or "1"
    local gameload = {}
    print("show loading  index 1============="..index_)
    local i = 0
    for _, value in pairs(config) do
        i = i + 1
        print("show loading  index 2============="..i)
        if i == tonumber(index_) then
            gameload = value
            app:getUserData():setUserValueForKey("Load_Rescore_Index", tostring(i + 1))
            print("show loading  index 3============="..index_)
            return gameload
        end
    end
    
    print("_getLoadConfig1   to    end")

    return self:_getLoadConfig()
end


function QUIPageLoadResources:_getLoadConfig() 
    local openServerTime = remote.user:getPropForKey("openServerTime") -- 服务器开服时间，单位毫秒
    local currentServerTime = q.serverTime() -- 当前时间，单位秒
    local openDays = (currentServerTime * 1000 - openServerTime) / 1000 / 60 / 60 / 24
    local playerLevel = remote.user.level or 20 -- TODO, login loader can't know the level before login

    local config = QStaticDatabase.sharedDatabase():getGameLoad()
    local probabilityAll = 0
    local probabilityList = {}
    local fistLoad = {}
    for _, value in pairs(config) do
        if not db:checkHeroShields(value.ID, SHIELDS_TYPE.GAME_LOAD) then
            if value.dungeon_id and self._dungeonConfig then
                print("QUIPageLoadResources:_getLoadConfig() ", value.dungeon_id, self._dungeonConfig.id)
                if self._dungeonConfig.id == value.dungeon_id then
                    return value
                end
            end

            local isLevel = false
            local isTime = false

            if value.end_time then
                if value.end_time >= openDays and (not value.star_time or value.star_time <= openDays)then
                    isTime = true
                end
            else
                isTime = true
            end
            
            if value.level_max then
                if value.level_max >= playerLevel and (not value.level_min or value.level_min <= playerLevel)then
                    isLevel = true
                end
            else
                isLevel = true
            end

            if isTime and isLevel and value.probability and value.probability > 0 then
                probabilityList[#probabilityList+1] = {config = value, min = probabilityAll, max = probabilityAll + value.probability}
                probabilityAll = probabilityAll + value.probability
            end

            if q.isEmpty(fistLoad) then
                fistLoad = value
            end
        end
    end
    
    if probabilityAll == 0 then
        return fistLoad
    end

    local randomIndex = math.random(0, probabilityAll)
    local gameload = {}
    for _, value in ipairs(probabilityList) do
        if randomIndex >= value.min and randomIndex < value.max then
            gameload = value.config
            break
        end
    end

    return gameload
end

function QUIPageLoadResources:_onProgressing(event)
    -- self:_setBarPercent(event.percent/100)
    if event and event.percent then
        self._bar:setPercent(event.percent/100)
    end
end

function QUIPageLoadResources:_onFinish( ... )
    if self._tipSwitchingId ~= nil then
        scheduler.unscheduleGlobal(self._tipSwitchingId)
        self._tipSwitchingId = nil
    end

    if self._loader then 
        self._loader:removeAllEventListeners() 
        self._loader = nil
    end
end

-- switch tips intermittently @qinyuanji
function QUIPageLoadResources:_onTipSwitching(dt)
    self:_setRandomeTips()
 end

-- update game tips text and center the tips @qinyuanji
function QUIPageLoadResources:_setRandomeTips()
    self._bar:setTip(self._gameTipsText[self._randomIndex])   
    self._randomIndex = ((self._randomIndex == #self._gameTipsText) and 1) or self._randomIndex + 1
end

return QUIPageLoadResources
