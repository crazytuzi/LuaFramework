--[[
******奇遇玩法主界面*******

	-- by quanhuan
	-- 2016/3/14
	
]]

local AdventureHomeLayer = class("AdventureHomeLayer",BaseLayer)
local HeadMoveSpeed = 577

function AdventureHomeLayer:ctor(data)

    self.flickData = nil
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.youli.homeLayer")
end

function AdventureHomeLayer:initUI( ui )

	self.super.initUI(self, ui)

    self.panel_touch = TFDirector:getChildByPath(ui, "homeMap")
    self.panel_touch:setVisible(true)
    self.panel_touch:setTouchEnabled(true)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.youli,{HeadResType.BAOZI,HeadResType.YUELI,HeadResType.SYCEE}) 
    self.generalHead:setVisible(true)

    local bgSize = self.panel_touch:getContentSize()
    local uiSize = self.ui:getContentSize()
    local bgPos = self.panel_touch:getPosition()
    self.panelLimitSize = {}
    self.panelLimitSize.minX = uiSize.width/2 - bgSize.width/2
    self.panelLimitSize.maxX = bgSize.width/2 - uiSize.width/2
    self.panelLimitSize.minY = uiSize.height/2 - bgSize.height/2 - self.generalHead:getContentSize().height
    self.panelLimitSize.maxY = bgSize.height/2 - uiSize.height/2
    self.panelLimitSize.middleX = uiSize.width/2
    self.panelLimitSize.middleY = uiSize.height/2

    self.randomEventIcon = TFDirector:getChildByPath(ui, "btn_random")
    self.randomEventIcon:setVisible(false)
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/taskFlg.xml")
    local effect = TFArmature:create("taskFlg_anim")        
    self.randomEventIcon:addChild(effect) 
    effect:setVisible(true)
    effect:playByIndex(0, -1, -1, -1)
    self.randomEventEffect = effect

    self.mainEventIcon = TFDirector:getChildByPath(ui, "btn_zhuxian")
    self.mainEventIcon:setVisible(false)
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/taskFlg.xml")
    local effect = TFArmature:create("taskFlg_anim")        
    self.mainEventIcon:addChild(effect) 
    effect:setVisible(true)
    effect:playByIndex(1, -1, -1, -1)
    self.randomEventEffect = effect

    self.otherPlayerOn = TFDirector:getChildByPath(ui, "panel_otherplayer")
    self.otherPlayerOff = TFDirector:getChildByPath(ui, "panel_wenhao")

    self.headModel = TFDirector:getChildByPath(ui, "btn_otherHead")
    self.headModel:setVisible(false)


    self.btn_myHead = TFDirector:getChildByPath(ui, "btn_myHead")
    self.btn_myHead:setVisible(true)
    self.btn_myHead:setTouchEnabled(false)
    self.btn_myHead:setZOrder(2)
    self:refreshMyInfo()

    self.imgRandomGuide = TFDirector:getChildByPath(ui,"imgRandomGuide")
    self.imgRandomGuide:setTouchEnabled(true)
    self.imgMainGuide = TFDirector:getChildByPath(ui,"imgMainGuide")
    self.imgMainGuide:setTouchEnabled(true)

    self.btn_shop = TFDirector:getChildByPath(ui, "btn_shop")
    self.btn_shanu = TFDirector:getChildByPath(ui, "btn_shanu")
    self.btn_chapter = TFDirector:getChildByPath(ui, "btn_chapter")    
    self.btn_buzheng = TFDirector:getChildByPath(ui, "btn_buzheng")
    self.btn_chouren = TFDirector:getChildByPath(ui, "btn_chouren")  
    self.btn_goods = TFDirector:getChildByPath(ui, "btn_goods")  


    --设置家的位置
    local uiContentSize = self.ui:getContentSize()
    local homeXY = {}
    homeXY.x = -localizable.youli_home_xy.x
    homeXY.y = -localizable.youli_home_xy.y
    self.panel_touch:setPosition(homeXY)
    self.btn_myHead:setPosition(localizable.youli_home_xy)


    self.oldScale = self.btn_myHead:getScale()

end


function AdventureHomeLayer:removeUI()
	self.super.removeUI(self)
end

function AdventureHomeLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
    self:refreshOtherPlayerInfo()
end

function AdventureHomeLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)
    TFAudio.stopMusic()
    TFAudio.playMusic("sound/bgmusic/youli_bgm.mp3", true)    
    if self.generalHead then
        self.generalHead:registerEvents()
    end

    --监听玩家信息刷新事件
    self.refreshHomeLayerCallBack = function (event)
        self:refreshOtherPlayerInfo()
        self:refreshRandomEvent()
    end
    TFDirector:addMEGlobalListener(AdventureManager.refreshHomeLayer, self.refreshHomeLayerCallBack)

    self.fightEndMessageCallBack = function (event)
        AdventureManager:requestHomeLayerData()
    end
    TFDirector:addMEGlobalListener(AdventureManager.fightEndMessage, self.fightEndMessageCallBack)

    self.updateMissionCallBack = function ( event )
        self:refreshMainEvent()
        self:onAttackCompeleteHandle(event);
    end
    TFDirector:addMEGlobalListener(MissionManager.EVENT_UPDATE_MISSION, self.updateMissionCallBack)

    --监听玩家信息刷新事件
    self.otherPlayerCallBack = function (event)
        self:refreshOtherPlayerInfo()        
    end
    TFDirector:addMEGlobalListener(AdventureManager.refreshOtherPlayerInfo, self.otherPlayerCallBack)

    --监听随机事件
    self.refreshRandomEventCallBack = function (event)
        self:refreshRandomEvent()
    end
    TFDirector:addMEGlobalListener(AdventureManager.refreshRandomEvent, self.refreshRandomEventCallBack)

    --监听大地图对话完成
    self.talkEndMessageCallBack = function (event)
        if self.isMainEventMessage then
            local currMission = AdventureMissionManager:getCurrMission()
            if currMission then
                self:showMainEventDetailsByMissionId(currMission.id)
            end
        else
            local cutDown,eventId = AdventureManager:getRandomEventInfo()
            local mission = AdventureRandomEventData:getInfoById(eventId)
            if mission then
                if mission:checkIsTalk() then
                    --send message for talk end
                    AdventureManager:requestEventComplete(eventId)
                else
                    self:showRandomEventDetailsByMissionId(eventId)
                end
            else
                print('cannot find the event by id = ',eventId)
            end
        end        
    end
    TFDirector:addMEGlobalListener(AdventureManager.talkEndMessage, self.talkEndMessageCallBack)

    --滑动事件监听，切换装备
    function onTouchBegin(widget,pos,offset)
        self.touchBeginPos = pos
        self.flickData = nil
        self.isTouchMove = true
        print("onTouchBegin = ",pos)
    end

    function onTouchMove(widget,pos,offset)
        self.isTouchMove = true

        local Dx = pos.x - self.touchBeginPos.x
        local Dy = pos.y - self.touchBeginPos.y

        if self.flickData == nil then
            self.flickData = {}
            self.flickData.pos = pos
            self.flickData.time = os.clock()*1000
            if self.flickTimer then
                TFDirector:removeTimer(self.flickTimer)
                self.flickTimer = nil
            end            
        end

        self:moveMapPosition(self.panel_touch:getPositionX() + Dx, self.panel_touch:getPositionY() + Dy)
        self.touchBeginPos = pos
    end

    function onTouchEnd(widget,pos)
        
        local state = 1--1.click 2.flick 3.dragMove

        if self.flickData then
            local dTime = os.clock()*1000 - self.flickData.time
            local dx = pos.x - self.flickData.pos.x
            local dy = pos.y - self.flickData.pos.y
            -- toastMessage('dTime = '..dTime)

            local checkTime = 300
            if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
                checkTime = 90
            end

            if math.abs(dx) > 15 or math.abs(dy) > 15 then
                if dTime < checkTime then
                    state = 2
                else
                    state = 3
                end
            end
        end

        if state == 1 then
            --click
            self.isTouchMove = false
            self:touchAndMoveHeadIcon(pos)
        elseif state == 2 then
            --flick
            local dTime = os.clock()*1000 - self.flickData.time
            local dx = pos.x - self.flickData.pos.x
            local dy = pos.y - self.flickData.pos.y
            local k,speedx,speedy            
            if dx == 0 then
                speedy = dy
            elseif dy == 0 then
                speedx = dx
            else
                k = dy/dx
                if math.abs(dy) > math.abs(dx) then
                    speedy = dy
                else
                    speedx = dx
                end
            end
            if speedx then
                speedx = speedx*99/dTime
            end
            if speedy then
                speedy = speedy*99/dTime
            end
            self.flickData = nil
            self:flickMove(speedx, speedy, k) 
        end        
        self.flickData = nil
    end    

    self.panel_touch:addMEListener(TFWIDGET_TOUCHBEGAN, onTouchBegin)
    self.panel_touch:addMEListener(TFWIDGET_TOUCHMOVED, onTouchMove)
    self.panel_touch:addMEListener(TFWIDGET_TOUCHENDED, onTouchEnd)
    self.panel_touch:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickInBgMap),1)
    self.panel_touch.logic = self

    self.randomEventIcon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickRandomEvent))
    self.randomEventIcon.logic = self
    self.imgRandomGuide:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickRandomEvent))
    self.imgRandomGuide.logic = self

    self.mainEventIcon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickMainEvent))
    self.mainEventIcon.logic = self
    self.imgMainGuide:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickMainEvent))
    self.imgMainGuide.logic = self

    self.btn_shop:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onShopClick))
    self.btn_shop.logic = self

    self.btn_shanu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onShaLuBtnClick))
    self.btn_shanu.logic = self

    self.btn_chapter:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnChapterClick))
    self.btn_chapter.logic = self

    self.btn_buzheng:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onArmyBtnClick))
    self.btn_buzheng.logic = self

    self.btn_chouren:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onChouRenBtnClick))
    self.btn_chouren.logic = self

    self.btn_goods:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onGoodsBtnClick))
    self.btn_goods.logic = self

    self.registerEventCallFlag = true 
end

function AdventureHomeLayer:removeEvents()

    self.super.removeEvents(self)

    TFAudio.stopMusic()
    TFAudio.playMusic("sound/bgmusic/home.mp3", true)

	if self.generalHead then
        self.generalHead:removeEvents()
    end
 	
    if self.flickTimer then
        TFDirector:removeTimer(self.flickTimer)
        self.flickTimer = nil 
    end

    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end

    if self.otherPlayerCallBack then
        TFDirector:removeMEGlobalListener(AdventureManager.refreshOtherPlayerInfo, self.otherPlayerCallBack)    
        self.otherPlayerCallBack = nil
    end

    if self.updateMissionCallBack then
        TFDirector:removeMEGlobalListener(MissionManager.EVENT_UPDATE_MISSION, self.updateMissionCallBack) 
        self.updateMissionCallBack = nil
    end

    if self.refreshHomeLayerCallBack then
        TFDirector:removeMEGlobalListener(AdventureManager.refreshHomeLayer, self.refreshHomeLayerCallBack)
        self.refreshHomeLayerCallBack = nil
    end

    if self.refreshRandomEventCallBack then
        TFDirector:removeMEGlobalListener(AdventureManager.refreshRandomEvent, self.refreshRandomEventCallBack)
        self.refreshRandomEventCallBack = nil
    end

    if self.talkEndMessageCallBack then
        TFDirector:removeMEGlobalListener(AdventureManager.talkEndMessage, self.talkEndMessageCallBack)
        self.talkEndMessageCallBack = nil
    end

    if self.fightEndMessageCallBack then
        TFDirector:removeMEGlobalListener(AdventureManager.fightEndMessage, self.fightEndMessageCallBack)
        self.fightEndMessageCallBack = nil
    end


    if self.screenMoveTween then
        TFDirector:killTween(self.screenMoveTween)
        self.screenMoveTween = nil
    end  
    if self.headMoveTween then
        TFDirector:killTween(self.headMoveTween)
        self.headMoveTween = nil
    end
    if self.headScaleTween then
        TFDirector:killTween(self.headScaleTween)
        self.headScaleTween = nil
    end    

    self.registerEventCallFlag = nil  
end

function AdventureHomeLayer:dispose()

	self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
    
end

function AdventureHomeLayer:startMoveScreen(sender, callback)
    self.isTouchMove = true
    local _parent = sender:getParent()
    local wordPos = _parent:convertToWorldSpaceAR(sender:getPosition())
    local screenSize = self.ui:getContentSize()
    local screenMiddlePosX = self.ui:getPositionX() + screenSize.width/2
    local screenMiddlePosY = self.ui:getPositionY() + screenSize.height/2

    local desX = self.panel_touch:getPositionX() + screenMiddlePosX - wordPos.x
    local desY = self.panel_touch:getPositionY() + screenMiddlePosY - wordPos.y

    desX,desY = self:checkBgPosition(desX,desY)

    if desX ~= self.panel_touch:getPositionX() or desY ~= self.panel_touch:getPositionY() then
        self.screenMoveTween = 
        {
            target = self.panel_touch,
            {
                duration = 0.2,
                x = desX,
                y = desY,
                onUpdate = function() 
                    self:refreshGuideIcon()
                end,
                onComplete = function() 
                    if self.screenMoveTween then
                        TFDirector:killTween(self.screenMoveTween)
                        self.screenMoveTween = nil
                    end
                    self:refreshGuideIcon()
                    if callback then
                        callback()
                    end
                end
            }
        }
        TFDirector:toTween(self.screenMoveTween)   
    else
        if callback then
            callback()
        end
    end
end

function AdventureHomeLayer:startMoveHeadIcon(sender,pos,speed, callback)
    
    self.moveEndCallBack = callback
    local _parent = sender:getParent()
    local wordPos = _parent:convertToWorldSpaceAR(sender:getPosition())
    self.lastWordPos = wordPos
    if self.headMoveTween then
        TFDirector:killTween(self.headMoveTween)
        self.headMoveTween = nil
    end

    if self.headScaleTween then
        self.btn_myHead:setScale(self.oldScale)
        TFDirector:killTween(self.headScaleTween)
        self.headScaleTween = nil
    end    
    self.headMoveTween = 
    {
        target = sender,
        -- repeated = -1,
        {
            duration = speed,
            x = pos.x,
            y = pos.y,
            onComplete = function() 
                if self.headMoveTween then
                    TFDirector:killTween(self.headMoveTween)
                    self.headMoveTween = nil
                end
                if self.headScaleTween then
                    self.btn_myHead:setScale(self.oldScale)
                    TFDirector:killTween(self.headScaleTween)
                    self.headScaleTween = nil
                end
                if self.moveEndCallBack then
                    self.moveEndCallBack()
                end
            end,
            onUpdate = function() 
                self:headMove() 
            end
        }
    }
    self.headScaleTween = 
    {
        target = sender,
        repeated = -1,
        {
            duration = 0.15,
            scale = self.oldScale+0.1,
        },
        {
            duration = 0.15,
            scale = self.oldScale,
        }
    }
    TFDirector:toTween(self.headMoveTween)
    TFDirector:toTween(self.headScaleTween)
end

function AdventureHomeLayer:headMove()
    local _parent = self.btn_myHead:getParent()
    local wordPos = _parent:convertToWorldSpaceAR(self.btn_myHead:getPosition())


    local Dx = wordPos.x - self.lastWordPos.x
    local Dy = wordPos.y - self.lastWordPos.y

    local currMapX = self.panel_touch:getPositionX()
    local currMapY = self.panel_touch:getPositionY()
    local moveMapX = currMapX
    local moveMapY = currMapY

    if (Dx < 0 and wordPos.x < self.panelLimitSize.middleX) or (Dx > 0 and wordPos.x > self.panelLimitSize.middleX) then
        --向左移动 并且过半屏 或者向右移动且过半屏
        -- print('向左移动 并且过半屏 或者向右移动且过半屏')
        moveMapX = currMapX - Dx
    end

    if (Dy < 0 and wordPos.y < self.panelLimitSize.middleY) or (Dy > 0 and wordPos.y > self.panelLimitSize.middleY) then
        --向下移动 并且过半屏 或者向上移动且过半屏
        -- print('向下移动 并且过半屏 或者向上移动且过半屏')
        moveMapY = currMapY - Dy
    end
    -- print('self.isTouchMove = ',self.isTouchMove)
-- print('moveMapX = ',moveMapX)
        -- print('currMapX = ',currMapX)
    if (not self.isTouchMove) and (moveMapX ~= currMapX or moveMapY ~= currMapY) then
        self:moveMapPosition(moveMapX,moveMapY)
    end
    self.lastWordPos = _parent:convertToWorldSpaceAR(self.btn_myHead:getPosition())
end

function AdventureHomeLayer:checkBgPosition( posX, posY )
    local checkX = posX
    local checkY = posY

    if checkX < self.panelLimitSize.minX then
        checkX = self.panelLimitSize.minX
    elseif checkX > self.panelLimitSize.maxX then
        checkX = self.panelLimitSize.maxX
    end

    if checkY < self.panelLimitSize.minY then
        checkY = self.panelLimitSize.minY
    elseif checkY > self.panelLimitSize.maxY then
        checkY = self.panelLimitSize.maxY
    end
    return checkX,checkY
end

function AdventureHomeLayer:refreshMainEvent()
    
    local currMission = AdventureMissionManager:getCurrMission()

    self.imgMainGuide:setVisible(false)
    self.mainEventIcon:setVisible(false)
    if currMission then
        local pos = stringToNumberTable(currMission.coordinate, ",")
        local cutDown,eventId = AdventureManager:getRandomEventInfo()
        if (eventId and eventId ~= 0) and self.randomEventIcon:isVisible() then
            local eventTemplete = AdventureRandomEventData:getInfoById(eventId)
            local currPos1 = eventTemplete:getCoordinate()
            local currPos2 = self.randomEventIcon:getPosition()
            if currPos1.x == currPos2.x and currPos1.y == currPos2.y then
                pos[1] = pos[1] + 50
            end
        end
        self.mainEventIcon:setVisible(true)
        self.mainEventIcon:setPosition(ccp(pos[1],pos[2]))
        self:refreshGuideIcon()
    end    
end

function AdventureHomeLayer:refreshGuideIcon()
    self.imgMainGuide:setVisible(false)
    if self:checkInScreen(self.mainEventIcon) == false then
        self.imgMainGuide:setVisible(true)
        local posX,posY,rotate = self:getGuideIconInfo(self.mainEventIcon)
        -- print('posX = ',posX)
        -- print('posY = ',posY)
        self.imgMainGuide:setPosition(ccp(posX,posY)) 
        local imgArrow = TFDirector:getChildByPath(self.imgMainGuide,"imgArrow")           
        imgArrow:setRotation(rotate)
    end

    self.imgRandomGuide:setVisible(false)
    if self:checkInScreen(self.randomEventIcon) == false then
        self.imgRandomGuide:setVisible(true)
        local posX,posY,rotate = self:getGuideIconInfo(self.randomEventIcon)
        -- print("posX",posX)
        -- print("posY",posY)
        self.imgRandomGuide:setPosition(ccp(posX,posY))            
        local imgArrow = TFDirector:getChildByPath(self.imgRandomGuide,"imgArrow")           
        imgArrow:setRotation(rotate)
    end
end

function AdventureHomeLayer.onClickMainEvent( btn )
    local self = btn.logic

    local headPos = self.btn_myHead:getPosition()
    local eventPos = self.mainEventIcon:getPosition()

    if eventPos.x > headPos.x then 
        eventPos.x = eventPos.x - 50
    else
        eventPos.x = eventPos.x + 50
    end
    if eventPos.y > headPos.y then 
        eventPos.y = eventPos.y - 50
    else
        eventPos.y = eventPos.y + 50
    end

    local ds = math.sqrt(math.pow((eventPos.x - headPos.x),2) + math.pow((eventPos.y - headPos.y),2))
    local speedTime = ds/HeadMoveSpeed

    if self:checkInScreen(self.btn_myHead) == false then
        speedTime = ds/(HeadMoveSpeed*2)
    end

    local function callback()
        --显示主线任务详细
        self.mainIconCallBackCount = self.mainIconCallBackCount + 1
        if self.mainIconCallBackCount >= 2 then
            local currMission = AdventureMissionManager:getCurrMission()
            local reqiure_level = currMission.reqiure_level or 0
            -- print('-------------------------currMission = ',currMission)
            if currMission.function_open == 0 then
                toastMessage(localizable.youli_not_open)
                return
            end
            if MainPlayer:getLevel() < reqiure_level then
                toastMessage(stringUtils.format(localizable.youli_reqiure_level, reqiure_level))
                return
            end
            if currMission and MissionManager:checkIsFirstTimeInMission(currMission.id) then
                if MissionManager:isHaveTipInMissionForYouli(currMission.id,AdventureManager.MapTalkIndex) then
                    self.isMainEventMessage = true
                    MissionManager:showTipForMission(currMission.id,AdventureManager.MapTalkIndex,AdventureManager.talkEndMessage)                
                else
                    --show details
                    self:showMainEventDetailsByMissionId(currMission.id)
                end
            end
        end
    end
    self.mainIconCallBackCount = 0
    self:startMoveScreen(self.mainEventIcon,callback)
    self:startMoveHeadIcon(self.btn_myHead, eventPos,speedTime,callback)
end

function AdventureHomeLayer:showMainEventDetailsByMissionId( missionId )
    AdventureManager:openAdventureMissionDetailLayer(missionId)
end

function AdventureHomeLayer:refreshRandomEvent()
    local cutDown,eventId = AdventureManager:getRandomEventInfo()
    self.randomEventIcon:setVisible(false)
    self.randomEventTimer = nil

    if eventId and eventId ~= 0 then
        -- 存在随机事件
        print('eventId = ',eventId)
        self.randomEventIcon:setVisible(true)
        local eventTemplete = AdventureRandomEventData:getInfoById(eventId)        
        local pos = eventTemplete:getCoordinate()

        local currMission = AdventureMissionManager:getCurrMission()
        if currMission then
            local currPos1 = stringToNumberTable(currMission.coordinate, ",")            
            local currPos2 = self.mainEventIcon:getPosition()
            if currPos2.x == currPos1[1] and currPos2.y == currPos1[2] then
                pos.x = pos.x + 50
            end
        end
        self.randomEventIcon:setPosition(ccp(pos.x,pos.y))
        self.randomEventIcon.eventId = eventId
        self:refreshGuideIcon()
    elseif cutDown then
        --存在随机事件倒计时
        if cutDown == 0 then
            AdventureManager:requestHomeLayerData(AdventureManager.refreshRandomEvent)
        else
            self.randomEventTimer = cutDown
        end
    end
end

function AdventureHomeLayer.onClickRandomEvent( btn )
    local eventId = btn.eventId
    local self = btn.logic

    -- toastMessage('点击了随机事件')
    local headPos = self.btn_myHead:getPosition()
    local eventPos = self.randomEventIcon:getPosition()
    local ds = math.sqrt(math.pow((eventPos.x - headPos.x),2) + math.pow((eventPos.y - headPos.y),2))
    local speedTime = ds/HeadMoveSpeed
    if eventPos.x > headPos.x then 
        eventPos.x = eventPos.x - 50
    else
        eventPos.x = eventPos.x + 50
    end
    if eventPos.y > headPos.y then 
        eventPos.y = eventPos.y - 50
    else
        eventPos.y = eventPos.y + 50
    end
    if self:checkInScreen(self.btn_myHead) == false then
        speedTime = ds/(HeadMoveSpeed*2)
    end

    local function callback()
        self.randomIconCallBackCount = self.randomIconCallBackCount + 1
        if self.randomIconCallBackCount >= 2 then
            local cutDown,eventId = AdventureManager:getRandomEventInfo()
            local mission = AdventureRandomEventData:getInfoById(eventId)
            if mission then
                self.isMainEventMessage = false
                if mission:checkIsTalk() then                    
                    MissionManager:showTipForMission(eventId,AdventureManager.MapTalkIndex,AdventureManager.talkEndMessage)
                elseif MissionManager:isHaveTipInMissionForYouli(mission.id,AdventureManager.MapTalkIndex) then
                    MissionManager:showTipForMission(mission.id,AdventureManager.MapTalkIndex,AdventureManager.talkEndMessage)                
                else
                    self:showRandomEventDetailsByMissionId(eventId)
                end
            else
                print('cannot find the event by id = ',eventId)
            end
        end
    end
    self.randomIconCallBackCount = 0
    self:startMoveScreen(self.randomEventIcon,callback)
    self:startMoveHeadIcon(self.btn_myHead, eventPos,speedTime,callback)    
end

function AdventureHomeLayer:showRandomEventDetailsByMissionId( missionId )
    AdventureManager:openAdventureRandomDetailLayer(missionId)
end

function AdventureHomeLayer:refreshOtherPlayerInfo()

    local cutDown,opponent = AdventureManager:getOtherPlayerInfo()
    self.otherPlayerCutDown = nil
    if cutDown then
        -- 需要显示倒计时
        if self.otherPlayerMoveHead then
            for k,v in pairs(self.otherPlayerMoveHead) do
                v:setVisible(false)
            end
        end
        self.otherPlayerOn:setVisible(false)
        self.otherPlayerOff:setVisible(true)
        local txtCutDown = TFDirector:getChildByPath(self.otherPlayerOff,"txt_freshtime")
        local min = math.floor(cutDown/60)
        local sec = math.mod(cutDown,60)
        txtCutDown:setText(string.format("%02d:%02d",min,sec))

        local btnWenhao = TFDirector:getChildByPath(self.otherPlayerOff,"wenhao")
        btnWenhao:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickOtherPlayerTime))
        btnWenhao.logic = self

        if cutDown == 0 then
            --请求数据
            AdventureManager:requestHomeLayerData(AdventureManager.refreshOtherPlayerInfo)
        else
            --显示刷新倒计时
            self.otherPlayerCutDown = cutDown
        end
    else
        -- 需要显示玩家头像
        self.otherPlayerOn:setVisible(true)
        self.otherPlayerOff:setVisible(false)
        self.otherPlayerMoveHead = self.otherPlayerMoveHead or {}
        for i=1,3 do
            local headFrame = TFDirector:getChildByPath(self.otherPlayerOn, "otherFrame_"..i)
            local headIcon = TFDirector:getChildByPath(self.otherPlayerOn, "otherhead_"..i)
            -- if i ~= 1 then
                Public:addFrameImg(headIcon,opponent[i].headPicFrame,true)
            -- end
            local RoleIcon = RoleData:objectByID(opponent[i].icon)
            headIcon:setTexture(RoleIcon:getIconPath())

            headFrame:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickOtherPlayerHead))
            headFrame.logic = self
            headFrame.idx = i


            --大地图上面的头像
            local headMoveIcon = nil
            if self.otherPlayerMoveHead[i] == nil then
                headMoveIcon = self.headModel:clone()
                self.headModel:getParent():addChild(headMoveIcon)
                self.otherPlayerMoveHead[i] = headMoveIcon
            else
                headMoveIcon = self.otherPlayerMoveHead[i]
            end
            
            local imgHead = TFDirector:getChildByPath(headMoveIcon, "img_myHeadIcon")

            local RoleIcon = RoleData:objectByID(opponent[i].icon)
            imgHead:setTexture(RoleIcon:getIconPath())
            local txtName = TFDirector:getChildByPath(headMoveIcon, "txt_myName")
            Public:addFrameImg(imgHead,opponent[i].headPicFrame,true)
            if i == 1 then                
                txtName:setText(localizable.shalu_nearby_txt1)
            else
                txtName:setText(opponent[i].name)                
            end
            headMoveIcon:setVisible(true)
            local pos = AdventureManager:getOtherPlayerInfoPos(opponent[i].id)
            headMoveIcon:setPosition(pos)
            headMoveIcon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickOtherPlayerHead))
            headMoveIcon.logic = self
            headMoveIcon.idx = i
        end
    end
end

function AdventureHomeLayer.onClickOtherPlayerHead( btn )
    local self = btn.logic
    local idx = btn.idx
    local cutDown,opponent = AdventureManager:getOtherPlayerInfo()
    local function callBack( playerId )
        AlertManager:close()
        local function screenMoveEnd()
            self.otherPlayerCallBackCount = self.otherPlayerCallBackCount + 1
            if self.otherPlayerCallBackCount >= 2 then
                AdventureManager:openShaluVsLayer(playerId,AdventureManager.fightType_0)
            end
        end
        local headPos = self.btn_myHead:getPosition()
        local eventPos = self.otherPlayerMoveHead[idx]:getPosition()
        if eventPos.x > headPos.x then 
            eventPos.x = eventPos.x - 50
        else
            eventPos.x = eventPos.x + 50
        end
        if eventPos.y > headPos.y then 
            eventPos.y = eventPos.y - 50
        else
            eventPos.y = eventPos.y + 50
        end

        self.otherPlayerCallBackCount = 0
        self:startMoveScreen(self.otherPlayerMoveHead[idx],screenMoveEnd)
        self:startMoveHeadIcon(self.btn_myHead, eventPos,0.4,screenMoveEnd)   
    end
    AdventureManager:openShaNuLayer( opponent[idx].id,callBack)
end

function AdventureHomeLayer.onClickOtherPlayerTime( btn )
    local cost = ConstantData:objectByID("Kill.CancelRefreshCD.Gold").value or 0
    local msg = stringUtils.format(localizable.youli_text19, cost)
    CommonManager:showOperateSureLayer(
        function()
            if MainPlayer:isEnoughSycee( cost , true) then
                AdventureManager:requestResetPlayerTime()
            end
        end,
        function()
            AlertManager:close()
        end,
        {
        title = localizable.smritiMain_tips,
        msg = msg,
        }
    )
end

function AdventureHomeLayer.onClickInBgMap( btn )
    local self = btn.logic

    -- if self.headMoveTween then
    --     TFDirector:killTween(self.headMoveTween)
    --     self.headMoveTween = nil
    --     
    -- end

end

function AdventureHomeLayer:setDataReady()

    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end

    self:refreshOtherPlayerInfo()
    self:refreshRandomEvent()
    self:refreshMainEvent()

    self.countDownTimer = TFDirector:addTimer(1000, -1, nil, function () 
        --玩家刷新倒计时
        if self.otherPlayerCutDown then
            local txtCutDown = TFDirector:getChildByPath(self.otherPlayerOff,"txt_freshtime")
            local min = math.floor(self.otherPlayerCutDown/60)
            local sec = math.mod(self.otherPlayerCutDown,60)
            txtCutDown:setText(string.format("%02d:%02d",min,sec))
            if self.otherPlayerCutDown == 0 then
                AdventureManager:requestHomeLayerData(AdventureManager.refreshOtherPlayerInfo)
            else
                self.otherPlayerCutDown = self.otherPlayerCutDown - 1
            end
        end

        if self.randomEventTimer then
            if self.randomEventTimer == 0 then
                AdventureManager:requestHomeLayerData(AdventureManager.refreshRandomEvent)
            else
                self.randomEventTimer = self.randomEventTimer - 1
            end
        end
        --随机事件倒计时
    end)
end

function AdventureHomeLayer:refreshMyInfo()
    local imgHead = TFDirector:getChildByPath(self.btn_myHead, "img_myHeadIcon")
    local txtName = TFDirector:getChildByPath(self.btn_myHead, "txt_myName")

    imgHead:setTexture(MainPlayer:getHeadPath())
    txtName:setText(MainPlayer:getPlayerName())

    -- Public:addFrameImg(imgHead, MainPlayer:getHeadPicFrameId(), true)
end

function AdventureHomeLayer:checkInScreen( sender )
    
    if sender:isVisible() == false then
        --如果不存在sender
        return true
    end
    local _parent = sender:getParent()    
    local wordPos = _parent:convertToWorldSpaceAR(sender:getPosition())
    local senderSize = sender:getContentSize()
    local uiSize = self.ui:getContentSize()

    local minY = 0---senderSize.height/2 + 20
    local maxY = uiSize.height - self.generalHead:getContentSize().height-- + (senderSize.height/2 - 20)
    local minX = 0
    local maxX = uiSize.width

    if ((wordPos.x >= minX and wordPos.x <= maxX) and (wordPos.y >= minY and wordPos.y <= maxY)) then
        return true
    end
    return false    
end

function AdventureHomeLayer:getGuideIconInfo(desSender)

    local _parent = desSender:getParent()    
    local wordPos = _parent:convertToWorldSpaceAR(desSender:getPosition())

    local uiSize = self.ui:getContentSize()
    local currPos = {x = uiSize.width/2, y = uiSize.height/2}

    local k = (wordPos.y - currPos.y)/(wordPos.x - currPos.x)
    local b = currPos.y - (currPos.x*k)

    local rotate = math.atan(k)*180/math.pi
    local generalHeadSize = self.generalHead:getContentSize()   

    --右边边距
    local otherHeadSize = self.otherPlayerOff:getContentSize()
    local rightMargin = self.otherPlayerOff:getPositionX() - otherHeadSize.width/2

    --下边边距
    local btnSize = self.btn_chapter:getContentSize()
    local buttomMargin = self.btn_chapter:getPositionY() + btnSize.height/2
    

    rotate = 90 - rotate
    local x,y
    local topY = uiSize.height - (50 + generalHeadSize.height)
    local bottomY = 50 + buttomMargin
    local leftX = 50
    local rightX = rightMargin - 50 

    local function calculation(x,y)
        if x then
            y = k*x + b
        else
            x = (y - b)/k
        end
        return x,y
    end

    if wordPos.x == uiSize.width/2 then
        if wordPos.y >= uiSize.height/2 then
            x = wordPos.x
            y = topY
        else
            x = wordPos.x
            y = bottomY
        end
    elseif wordPos.x > uiSize.width/2 then
        if wordPos.y >= uiSize.height/2 then
            x,y = calculation(rightX,nil)
            if y > topY then
                x,y = calculation(nil,topY)
            end
        else
            x,y = calculation(rightX,nil)
            if y < bottomY then
                x,y = calculation(nil,bottomY)
            end
        end
    else
        rotate = rotate + 180
        if wordPos.y >= uiSize.height/2 then
            x,y = calculation(leftX,nil)
            if y > topY then
                x,y = calculation(nil,topY)
            end
        else
            x,y = calculation(leftX,nil)
            if y < bottomY then
                x,y = calculation(nil,bottomY)
            end
        end
    end
    x = x - uiSize.width/2
    y = y - uiSize.height/2
    return x,y,rotate
end

function AdventureHomeLayer.onShopClick( btn )
    -- local self = btn.logic
    AdventureManager:openAdventureMallLayer()
end

function AdventureHomeLayer.onShaLuBtnClick( btn )
    -- print('----------onShaLuBtnClick---------------')
    AdventureManager:requestAdventureMassacre()
end

function AdventureHomeLayer.onBtnChapterClick( btn )
    AdventureManager:openMissLayer()
end

function AdventureHomeLayer:flickMove(speedx, speedy, k)
    -- print('--------------------->>>>>speedx = ',speedx)
    -- print('--------------------->>>>>speedy = ',speedy)
    -- print('--------------------->>>>>k = ',k)

    if self.flickTimer then
        TFDirector:removeTimer(self.flickTimer)
        self.flickTimer = nil
    end
    local b
    if k == nil then
        if speedx then
            --x 方向移动
            self.flickTimer = TFDirector:addTimer(66, -1,nil,
                    function ()
                        if math.abs(speedx) <= 1 then
                            TFDirector:removeTimer(self.flickTimer)
                            self.flickTimer = nil 
                        else
                            local pos = self.panel_touch:getPosition()
                            local desX = pos.x + speedx
                            local desY = pos.y
                            -- print('flickMove-----nil----------------speedx')
                            self:moveMapPosition(desX, desY)
                            speedx = speedx/2
                        end
                    end)
        else
            --y 方向移动
            self.flickTimer = TFDirector:addTimer(66, -1,nil,
                    function ()
                        if math.abs(speedy) <= 1 then
                            TFDirector:removeTimer(self.flickTimer)
                            self.flickTimer = nil 
                        else
                            local pos = self.panel_touch:getPosition()
                            local desX = pos.x
                            local desY = pos.y + speedy
                            -- print('flickMove-----nil----------------speedy')
                            self:moveMapPosition(desX, desY)
                            speedy = speedy/2
                        end
                    end)
        end
    else
        local currPos = self.panel_touch:getPosition()
        local b = currPos.y - currPos.x * k
        if speedx then
            -- print('flickTimer')
            self.flickTimer = TFDirector:addTimer(66, -1,nil,
                    function ()
                        -- print('---------speedx------- = ',speedx)
                        if math.abs(speedx) <= 1 then
                            TFDirector:removeTimer(self.flickTimer)
                            self.flickTimer = nil
                        else
                            -- print('flickMove--------------------speedx')
                            local pos = self.panel_touch:getPosition()
                            local desX = pos.x + speedx
                            local desY = k*desX + b   
                            self:moveMapPosition(desX, desY)                                                     
                            speedx = speedx/2
                        end
                    end)
        else
            self.flickTimer = TFDirector:addTimer(66, -1,nil,
                    function ()
                        if math.abs(speedy) <= 1 then
                            TFDirector:removeTimer(self.flickTimer)
                            self.flickTimer = nil 
                        else
                            -- print('flickMove--------------------speedy')
                            local pos = self.panel_touch:getPosition()
                            local desY = pos.y + speedy
                            local desX = (desY - b)/k
                            self:moveMapPosition(desX, desY)                                                     
                            speedy = speedy/2
                        end
                    end)
        end
    end   
end

function AdventureHomeLayer:moveMapPosition( x,y )
    local desX, desY = self:checkBgPosition( x, y )
    local lastPos = self.panel_touch:getPosition()
    self.panel_touch:setPosition(ccp(desX, desY))
    -- print('---------------------moveMapPosition-----x = '..x.." y = "..y)
    self:refreshGuideIcon()
end

function AdventureHomeLayer.onArmyBtnClick( btn )
    local self = btn.logic
    -- print('self.panel_touch = ', self.panel_touch:isVisible())
    -- print('self.panel_touch = ', self.panel_touch:getPosition())
    -- print('imgRandomGuide = ', self.imgRandomGuide:isVisible())
    -- print('imgRandomGuide = ', self.imgRandomGuide:getPosition())

    ZhengbaManager:openArmyLayer(EnumFightStrategyType.StrategyType_DOUBLE_1, true)
end

function AdventureHomeLayer.onChouRenBtnClick( btn )
    AdventureManager:openAdventureEnemyLayer()
end

function AdventureHomeLayer:touchAndMoveHeadIcon( pos )
    local movePos = {}
    local headPos = self.btn_myHead:getPosition()
    local uiSize = self.ui:getContentSize()
    movePos.x = pos.x - uiSize.width/2
    movePos.y = pos.y - uiSize.height/2
    movePos.x = movePos.x - self.panel_touch:getPositionX()
    movePos.y = movePos.y - self.panel_touch:getPositionY()
    print('pospospos = ',movePos)

    if self.clickAnim == nil then
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/clickAnim.xml")
        local effect = TFArmature:create("clickAnim_anim")        
        effect:setZOrder(1)
        self.panel_touch:addChild(effect) 
        effect:setVisible(false)
        self.clickAnim = effect
    end
    local bgSize = self.panel_touch:getContentSize()
    self.clickAnim:playByIndex(0, -1, -1, 0)
    self.clickAnim:setPosition(ccp(movePos.x + bgSize.width/2, movePos.y + bgSize.height/2))
    self.clickAnim:setVisible(true)


    local ds = math.sqrt(math.pow((movePos.x - headPos.x),2) + math.pow((movePos.y - headPos.y),2))
    local speedTime = ds/HeadMoveSpeed
    if self:checkInScreen(self.btn_myHead) == false then
        speedTime = ds/(HeadMoveSpeed*2)
    end
    self:startMoveHeadIcon(self.btn_myHead,movePos,speedTime)
end

function AdventureHomeLayer:onAttackCompeleteHandle(event)
    local missionId                = event.data[1].missionId;
    local isFirstTimesPass         = event.data[1].isFirstTimesPass;
    local isFirstTimesToStarLevel3 = event.data[1].isFirstTimesToStarLevel3;

    local mission = AdventureMissionManager:getMissionById(missionId);

    -- print('event.data = ',event.data)
    --首次胜利，判断：开放下一关卡
    if isFirstTimesPass then
        local nextMission = AdventureMissionManager:getNextMissionById(mission.map_id,mission.difficulty,missionId);

        if nextMission == nil then
            local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.youli.AdventureMissionSkipLayer",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);        
            layer:loadData(mission.map_id,mission.difficulty, true);     
            AlertManager:show();  
        end
    end
end

function AdventureHomeLayer.onGoodsBtnClick( btn )
    local self = btn.logic
    BagManager:ShowBagLayerByButtonIndex(4)  
end

return AdventureHomeLayer