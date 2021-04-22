--
-- Author: zxs
-- 战斗对战信息
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAgainstRecordDetail = class("QUIWidgetAgainstRecordDetail", QUIWidget)
local QScrollView = import("...views.QScrollView")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")


function QUIWidgetAgainstRecordDetail:ctor(options)
	local ccbFile = "ccb/Widget_StormArena_battlerecordinfo.ccbi"
	local callbacks = {}
	QUIWidgetAgainstRecordDetail.super.ctor(self, ccbFile, callbacks, options)

    self._options = options
end

function QUIWidgetAgainstRecordDetail:onEnter()
    self:initScrollView()
    self:setInfo(self._options)
end

function QUIWidgetAgainstRecordDetail:onExit()
end

function QUIWidgetAgainstRecordDetail:initScrollView()
    local sheetSize1 = self._ccbOwner.sheet_layout1:getContentSize()
    local sheetSize2 = self._ccbOwner.sheet_layout2:getContentSize()
    self._scrollView1 = QScrollView.new(self._ccbOwner.node_sheet1, sheetSize1, {bufferMode = 1, nodeAR = ccp(0.5, 0.5), sensitiveDistance = 10})
    self._scrollView1:setVerticalBounce(false)

    self._scrollView2 = QScrollView.new(self._ccbOwner.node_sheet2, sheetSize2, {bufferMode = 1, nodeAR = ccp(0.5, 0.5), sensitiveDistance = 10})
    self._scrollView2:setVerticalBounce(false)
end

function QUIWidgetAgainstRecordDetail:setInfo(options)
    local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
    cache:addSpriteFramesWithFile("ui/StormArena.plist") 

    local LOGO_WIN = QSpriteFrameByPath("ui/Arena/flag_win.png")
    local LOGO_LOSE = QSpriteFrameByPath("ui/Arena/flag_lose.png")
    self._ccbOwner.sprite_flag_left:setDisplayFrame(options.isWin and LOGO_WIN or LOGO_LOSE)
    self._ccbOwner.sprite_flag_right:setDisplayFrame(options.isWin and LOGO_LOSE or LOGO_WIN)
    self._ccbOwner.tf_team:setString(string.format("第%s队",options.index))

    local heroFighter = options.heroFighter or {}
    local heroSubFighter = options.heroSubFighter or {}
    local heroSoulSpirit= options.heroSoulSpirit or {}
    local enemyFighter = options.enemyFighter or {}
    local enemySubFighter = options.enemySubFighter or {}
    local enemySoulSpirit = options.enemySoulSpirit or {}
    local heroGodarmList = options.heroGodarmList or {}
    local enemyGodarmList = options.enemyGodarmList or {}

    local totalWidth = 0
    local scale = 0.5
    local offsetX = 0
    local height = 16

    local force = 0
    local index = 0
    for i, fighter in pairs(heroFighter) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        widgetHead:setTeam(1)
        widgetHead:setHeroInfo(fighter)

        local width = widgetHead:getContentSize().width*scale+8
        local height = widgetHead:getContentSize().height*scale
        widgetHead:setPosition(ccp(index*width+offsetX+width/2, -height/2-10))
        widgetHead:initGLLayer()
        self._scrollView1:addItemBox(widgetHead)

        index = index + 1
        totalWidth = totalWidth + width
        force = force + (fighter.force or 0)
    end
    for i, fighter in pairs(heroSoulSpirit) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        widgetHead:setTeam(1)
        widgetHead:setHeroInfo(fighter)

        local width = widgetHead:getContentSize().width*scale+8
        local height = widgetHead:getContentSize().height*scale
        widgetHead:setPosition(ccp(index*width+offsetX+width/2, -height/2-10))
        widgetHead:initGLLayer()
        self._scrollView1:addItemBox(widgetHead)

        index = index + 1
        totalWidth = totalWidth + width
        force = force + (fighter.force or 0)
    end
    for i, fighter in pairs(heroGodarmList) do 
        local godarmInfo = string.split(fighter, ";")  
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setHero(godarmInfo[1])
        widgetHead:setTeam(i,false,false,true)
        widgetHead:setStar(godarmInfo[2])
        widgetHead:showSabc()
        widgetHead:setTeam(1)
        widgetHead:setScale(scale)

        local width = widgetHead:getContentSize().width*scale+8
        local height = widgetHead:getContentSize().height*scale
        widgetHead:setPosition(ccp(index*width+offsetX+width/2, -height/2-10))
        widgetHead:initGLLayer()
        self._scrollView1:addItemBox(widgetHead)

        index = index + 1
        totalWidth = totalWidth + width
        local godarmForce = remote.godarm:getGodarmbattleForce(tonumber(godarmInfo[1]),tonumber(godarmInfo[2]))
        force = force + godarmForce
    end    

    for i, fighter in pairs(heroSubFighter) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        widgetHead:setTeam(2)
        widgetHead:setHeroInfo(fighter)

        local width = widgetHead:getContentSize().width*scale+8
        local height = widgetHead:getContentSize().height*scale
        widgetHead:setPosition(ccp(index*width+offsetX+width/2, -height/2-10))
        widgetHead:initGLLayer()
        self._scrollView1:addItemBox(widgetHead)

        index = index + 1
        totalWidth = totalWidth + width
        
        force = force + (fighter.force or 0)
    end
    self._scrollView1:setRect(0, -60, 0, totalWidth)
    local force,unit = q.convertLargerNumber(tostring(force) or 0)
    self._ccbOwner.tf_force_left:setString(force..(unit or ""))

    local force = 0
    local index = 0
    local totalWidth = 0
    for i, fighter in pairs(enemyFighter) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        widgetHead:setTeam(1)
        widgetHead:setHeroInfo(fighter)

        local width = widgetHead:getContentSize().width*scale+8
        local height = widgetHead:getContentSize().height*scale
        widgetHead:setPosition(ccp(index*width+offsetX+width/2, -height/2-10))
        widgetHead:initGLLayer()
        self._scrollView2:addItemBox(widgetHead)

        index = index + 1
        totalWidth = totalWidth + width
        force = force + (fighter.force or 0)
    end
    for i, fighter in pairs(enemySoulSpirit) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        widgetHead:setTeam(1)
        widgetHead:setHeroInfo(fighter)

        local width = widgetHead:getContentSize().width*scale+8
        local height = widgetHead:getContentSize().height*scale
        widgetHead:setPosition(ccp(index*width+offsetX+width/2, -height/2-10))
        widgetHead:initGLLayer()
        self._scrollView2:addItemBox(widgetHead)

        index = index + 1
        totalWidth = totalWidth + width
        force = force + (fighter.force or 0)
    end

    for i, fighter in pairs(enemyGodarmList) do 
        local godarmInfo = string.split(fighter, ";")  
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setHero(godarmInfo[1])
        widgetHead:setTeam(i,false,false,true)
        widgetHead:setStar(godarmInfo[2])
        widgetHead:showSabc()
        widgetHead:setTeam(1)
        widgetHead:setScale(scale)

        local width = widgetHead:getContentSize().width*scale+8
        local height = widgetHead:getContentSize().height*scale
        widgetHead:setPosition(ccp(index*width+offsetX+width/2, -height/2-10))
        widgetHead:initGLLayer()
        self._scrollView2:addItemBox(widgetHead)

        index = index + 1
        totalWidth = totalWidth + width
        
        local godarmForce = remote.godarm:getGodarmbattleForce(tonumber(godarmInfo[1]),tonumber(godarmInfo[2]))
        force = force + godarmForce
    end   

    for i, fighter in pairs(enemySubFighter) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        widgetHead:setTeam(2)
        widgetHead:setHeroInfo(fighter)

        local width = widgetHead:getContentSize().width*scale+8
        local height = widgetHead:getContentSize().height*scale
        widgetHead:setPosition(ccp(index*width+offsetX+width/2, -height/2-10))
        widgetHead:initGLLayer()
        self._scrollView2:addItemBox(widgetHead)

        index = index + 1
        totalWidth = totalWidth + width
        force = force + (fighter.force or 0)
    end
    self._scrollView2:setRect(0, -60, 0, totalWidth)
    local force,unit = q.convertLargerNumber(tostring(force) or 0)
    self._ccbOwner.tf_force_right:setString(force..(unit or ""))
end

return QUIWidgetAgainstRecordDetail