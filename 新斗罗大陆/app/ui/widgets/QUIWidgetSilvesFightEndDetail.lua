--
-- Kumo.Wang
-- Silves战斗详情
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesFightEndDetail = class("QUIWidgetSilvesFightEndDetail", QUIWidget)
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")

local NUMBERS = {"一","二","三"}
QUIWidgetSilvesFightEndDetail.EVENT_CLICK_HEAD = "EVENT_CLICK_HEAD"
QUIWidgetSilvesFightEndDetail.EVENT_CLICK_ONEREPLAY = "EVENT_CLICK_ONEREPLAY"


function QUIWidgetSilvesFightEndDetail:ctor(options)
	local ccbFile = "ccb/Widget_FightEnd_detail_client.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
	}
	QUIWidgetSilvesFightEndDetail.super.ctor(self, ccbFile, callBack, options)
    
    q.setButtonEnableShadow(self._ccbOwner.btn_one_replay)
    
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
    self._originalHeight = self._ccbOwner.node_size:getContentSize().height
end

function QUIWidgetSilvesFightEndDetail:ininGLLayer(glLayerIndex)
    self._glLayerIndex = glLayerIndex or 1
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_fight_num, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_item_left, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_item_right, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_flag_1, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_force_1, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_flag_2, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_force_2, self._glLayerIndex)
   
    for i,v in pairs(self._heroBoxs or {}) do
        if v then
            self._glLayerIndex = v:initGLLayer(self._glLayerIndex)
        end
    end
    for i,v in pairs(self._enemyBoxs or {}) do
        if v then
            self._glLayerIndex = v:initGLLayer(self._glLayerIndex)
        end
    end

    return self._glLayerIndex
end

function QUIWidgetSilvesFightEndDetail:setInfo(info,reportIsShow)
    self._height = self._originalHeight
    self._heroBoxs = {}
    self._enemyBoxs = {}
    self._info = info
    local strSplt = info.strSplit or "第%s场"

	local fightNumStr = string.format(strSplt, NUMBERS[info.index])
	self._ccbOwner.tf_fight_num:setString(fightNumStr)

    if info.isWin ~= nil then
        local LOGO_WIN = QSpriteFrameByPath("ui/Arena/flag_win.png")
        local LOGO_LOSE = QSpriteFrameByPath("ui/Arena/flag_lose.png")
        self._ccbOwner.sp_flag_1:setDisplayFrame(info.isWin and LOGO_WIN or LOGO_LOSE)
        self._ccbOwner.sp_flag_2:setDisplayFrame(info.isWin and LOGO_LOSE or LOGO_WIN)
    else
        self._ccbOwner.sp_flag_1:setVisible(false)
        self._ccbOwner.sp_flag_2:setVisible(false)
    end

    local heroFighter = info.heroFighter or {}
    local heroSoulSpirit= info.heroSoulSpirit or {}
    local heroAlternateFighter = info.heroAlternateFighter or {}
    local heroSubFighter = info.heroSubFighter or {}
    local heroSubFighter2 = info.heroSubFighter2 or {}
    local heroSubFighter3 = info.heroSubFighter3 or {}
    local enemyFighter = info.enemyFighter or {}
    local enemySoulSpirit = info.enemySoulSpirit or {}
    local enemyAlternateFighter = info.enemyAlternateFighter or {}
    local enemySubFighter = info.enemySubFighter or {}
    local enemySubFighter2 = info.enemySubFighter2 or {}
    local enemySubFighter3 = info.enemySubFighter3 or {}

    local heroGodarmList = info.heroGodarmList or {}
    local enemyGodarmList = info.enemyGodarmList or {}

    local nodeHero = self._ccbOwner.node_item_left
    local nodeEnemy = self._ccbOwner.node_item_right
    nodeHero:removeAllChildren()
    nodeEnemy:removeAllChildren()

	local width = 75
    local height = 90
	local scale = 0.6
    -- hero
    local force = 0
    local index1 = 0
    -- local fighter = heroFighter
    for i, fighter in pairs(heroFighter) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        widgetHead:setTeam(1)
        widgetHead:setHeroInfo(fighter)
        widgetHead:initGLLayer()
        nodeHero:addChild(widgetHead)
        local posX = (index1%4)*width
        local posY = math.floor(index1/4)*height
        widgetHead:setPosition(ccp(posX, -posY))
        index1 = index1 + 1
        force = force + (fighter.force or 0)
        self._heroBoxs[index1] = widgetHead
    end
    for i, fighter in pairs(heroSoulSpirit) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        widgetHead:setHeroInfo(fighter)
        widgetHead:setTeam(1)
        widgetHead:initGLLayer()
        nodeHero:addChild(widgetHead)
        local posX = (index1%4)*width
        local posY = math.floor(index1/4)*height
        widgetHead:setPosition(ccp(posX, -posY))
        index1 = index1 + 1
        force = force + (fighter.force or 0)
        self._heroBoxs[index1] = widgetHead
    end
    for i, fighter in pairs(heroGodarmList) do 
        local godarmInfo = string.split(fighter, ";")  
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setHero(fighter.id)
        widgetHead:setTeam(i,false,false,true)
        widgetHead:setStar(fighter.grade)
        widgetHead:showSabc()
        widgetHead:setTeam(1)
        widgetHead:setScale(scale)

        widgetHead:initGLLayer()
        nodeHero:addChild(widgetHead)
        local posX = (index1%4)*width
        local posY = math.floor(index1/4)*height
        widgetHead:setPosition(ccp(posX, -posY))

        force = force + fighter.main_force

        index1 = index1 + 1
        self._heroBoxs[index1] = widgetHead
    end  

    for i, fighter in pairs(heroAlternateFighter) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        widgetHead:setTeam(i, false, true)
        widgetHead:setHeroInfo(fighter)
        widgetHead:initGLLayer()
        nodeHero:addChild(widgetHead)
        local posX = (index1%4)*width
        local posY = math.floor(index1/4)*height
        widgetHead:setPosition(ccp(posX, -posY))
        index1 = index1 + 1
        force = force + (fighter.force or 0)
        self._heroBoxs[index1] = widgetHead
    end
    for i, fighter in pairs(heroSubFighter) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        if info.isAlternateTeam then
            widgetHead:setTeam(3)
        elseif info.isMultiTeam then
            if i == info.teamHeroSkillIndex then
                widgetHead:setSkillTeam(1)
            elseif i == info.teamHeroSkillIndex2 then
                widgetHead:setSkillTeam(2)
            else
                widgetHead:setTeam(2)
            end
        elseif info.isSilvesArena then
            if fighter.actorId == info.teamHeroSubActorId then
                widgetHead:setSkillTeam(1)
            end
        else
            if i == info.teamHeroSkillIndex then
                widgetHead:setSkillTeam(1)
            else
                widgetHead:setTeam(3)
            end
        end
        widgetHead:setHeroInfo(fighter)
        widgetHead:initGLLayer()
        nodeHero:addChild(widgetHead)
		local posX = (index1%4)*width
        local posY = math.floor(index1/4)*height
        widgetHead:setPosition(ccp(posX, -posY))
        index1 = index1 + 1
        force = force + (fighter.force or 0)
        self._heroBoxs[index1] = widgetHead
    end
    for i, fighter in pairs(heroSubFighter2) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        if info.isAlternateTeam then
            widgetHead:setTeam(4)
        elseif i == info.teamHeroSkillIndex2 then
            widgetHead:setSkillTeam(2)
        elseif info.isSilvesArena then
            if fighter.actorId == info.teamHeroSubActorId2 then
                widgetHead:setSkillTeam(2)
            end
        else
            widgetHead:setTeam(4)
        end
        widgetHead:setHeroInfo(fighter)
        widgetHead:initGLLayer()
        nodeHero:addChild(widgetHead)
        local posX = (index1%4)*width
        local posY = math.floor(index1/4)*height
        widgetHead:setPosition(ccp(posX, -posY))
        index1 = index1 + 1
        force = force + (fighter.force or 0)
        self._heroBoxs[index1] = widgetHead
    end
    for i, fighter in pairs(heroSubFighter3) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        if info.isAlternateTeam then
            widgetHead:setTeam(5)
        elseif i == info.teamHeroSkillIndex3 then
            widgetHead:setSkillTeam(3)
        elseif info.isSilvesArena then
            if fighter.actorId == info.teamHeroSubActorId3 then
                widgetHead:setSkillTeam(3)
            end
        else
            widgetHead:setTeam(5)
        end
        widgetHead:setHeroInfo(fighter)
        widgetHead:initGLLayer()
        nodeHero:addChild(widgetHead)
        local posX = (index1%4)*width
        local posY = math.floor(index1/4)*height
        widgetHead:setPosition(ccp(posX, -posY))
        index1 = index1 + 1
        force = force + (fighter.force or 0)
        self._heroBoxs[index1] = widgetHead
    end
    local force, unit = q.convertLargerNumber(tostring(force) or 0)
    self._ccbOwner.tf_force_1:setString(force..unit)

    -- enemy
    local force = 0
    local index2 = 0
    for i, fighter in pairs(enemyFighter) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        widgetHead:setTeam(1)
        widgetHead:setHeroInfo(fighter)
        widgetHead:initGLLayer()
        nodeEnemy:addChild(widgetHead)
        local posX = (index2%4)*width
        local posY = math.floor(index2/4)*height
        widgetHead:setPosition(ccp(posX, -posY))
        index2 = index2 + 1
        force = force + (fighter.force or 0)
        self._enemyBoxs[index2] = widgetHead
    end
    for i, fighter in pairs(enemySoulSpirit) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        widgetHead:setTeam(1)
        widgetHead:setHeroInfo(fighter)
        widgetHead:initGLLayer()
        nodeEnemy:addChild(widgetHead)
        local posX = (index2%4)*width
        local posY = math.floor(index2/4)*height
        widgetHead:setPosition(ccp(posX, -posY))
        index2 = index2 + 1
        force = force + (fighter.force or 0)
        self._enemyBoxs[index2] = widgetHead
    end

    for i, fighter in pairs(enemyGodarmList) do 
        local godarmInfo = string.split(fighter, ";")  
        local widgetHead = QUIWidgetHeroHead.new() 
        widgetHead:setHero(fighter.id)
        widgetHead:setTeam(i,false,false,true)
        widgetHead:setStar(fighter.grade)
        widgetHead:showSabc()
        widgetHead:setTeam(1)
        widgetHead:setScale(scale)
        widgetHead:initGLLayer()
        nodeEnemy:addChild(widgetHead)

        local posX = (index2%4)*width
        local posY = math.floor(index2/4)*height
        widgetHead:setPosition(ccp(posX, -posY))

        force = force + fighter.main_force
        
        index2 = index2 + 1
        self._enemyBoxs[index2] = widgetHead
    end  

    for i, fighter in pairs(enemyAlternateFighter) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        widgetHead:setTeam(i, false, true)
        widgetHead:setHeroInfo(fighter)
        widgetHead:initGLLayer()
        nodeEnemy:addChild(widgetHead)
        local posX = (index2%4)*width
        local posY = math.floor(index2/4)*height
        widgetHead:setPosition(ccp(posX, -posY))
        index2 = index2 + 1
        force = force + (fighter.force or 0)
        self._enemyBoxs[index2] = widgetHead
    end
    for i, fighter in pairs(enemySubFighter) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        if info.isAlternateTeam then
            widgetHead:setTeam(3)
        elseif info.isMultiTeam then
            if i == info.teamEnemySkillIndex then
                widgetHead:setSkillTeam(1)
            elseif i == info.teamEnemySkillIndex2 then
                widgetHead:setSkillTeam(2)
            else
                widgetHead:setTeam(2)
            end
        elseif info.isSilvesArena then
            if fighter.actorId == info.teamEnemySubActorId then
                widgetHead:setSkillTeam(1)
            end
        else
            if i == info.teamEnemySkillIndex then
                widgetHead:setSkillTeam(1)
            else
                widgetHead:setTeam(3)
            end
        end
        widgetHead:setHeroInfo(fighter)
        widgetHead:initGLLayer()
        nodeEnemy:addChild(widgetHead)
		local posX = (index2%4)*width
        local posY = math.floor(index2/4)*height
        widgetHead:setPosition(ccp(posX, -posY))
        index2 = index2 + 1
        force = force + (fighter.force or 0)
        self._enemyBoxs[index2] = widgetHead
    end
    for i, fighter in pairs(enemySubFighter2) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        if info.isAlternateTeam then
            widgetHead:setTeam(4)
        elseif i == info.teamEnemySkillIndex2 then
            widgetHead:setSkillTeam(2)
        elseif info.isSilvesArena then
            if fighter.actorId == info.teamEnemySubActorId2 then
                widgetHead:setSkillTeam(2)
            end
        else
            widgetHead:setTeam(4)
        end
        widgetHead:setHeroInfo(fighter)
        widgetHead:initGLLayer()
        nodeEnemy:addChild(widgetHead)
        local posX = (index2%4)*width
        local posY = math.floor(index2/4)*height
        widgetHead:setPosition(ccp(posX, -posY))
        index2 = index2 + 1
        force = force + (fighter.force or 0)
        self._enemyBoxs[index2] = widgetHead
    end
    for i, fighter in pairs(enemySubFighter3) do   
        local widgetHead = QUIWidgetHeroHead.new()
        widgetHead:setScale(scale)
        if info.isAlternateTeam then
            widgetHead:setTeam(5)
        elseif i == info.teamEnemySkillIndex3 then
            widgetHead:setSkillTeam(3)
        elseif info.isSilvesArena then
            if fighter.actorId == info.teamEnemySubActorId3 then
                widgetHead:setSkillTeam(3)
            end
        else
            widgetHead:setTeam(5)
        end
        widgetHead:setHeroInfo(fighter)
        widgetHead:initGLLayer()
        nodeEnemy:addChild(widgetHead)
        local posX = (index2%4)*width
        local posY = math.floor(index2/4)*height
        widgetHead:setPosition(ccp(posX, -posY))
        index2 = index2 + 1
        force = force + (fighter.force or 0)
        self._enemyBoxs[index2] = widgetHead
    end
    local force, unit = q.convertLargerNumber(tostring(force) or 0)
    self._ccbOwner.tf_force_2:setString(force..unit)

    if index2 > index1 then
        self._height = self._height + height*math.ceil(index2/4)
    else
        self._height = self._height + height*math.ceil(index1/4)
    end

    self._ccbOwner.node_one_replay:setVisible(reportIsShow)
    if reportIsShow then
        local btnHeight = self._ccbOwner.btn_one_replay:getContentSize().height
        self._ccbOwner.node_one_replay:setPositionY(-(self._height + btnHeight / 2))
        self._height = self._height + btnHeight
    end

    for _, head in pairs(self._enemyBoxs) do
        if head and head.getHeroSprite then
            local img = head:getHeroSprite()
            if img then
                img:setScaleX( img:getScaleX() * -1 )
            end
        end
    end
end

function QUIWidgetSilvesFightEndDetail:registerItemBoxPrompt( index, list )
    local heroNum = #self._heroBoxs
    for k, v in pairs(self._heroBoxs) do
        list:registerItemBoxPrompt(index, k, v, nil, handler(self, self.showHeroInfo))
    end
    for k, v in pairs(self._enemyBoxs) do
        list:registerItemBoxPrompt(index, k+heroNum, v, nil, handler(self, self.showEnemyInfo))
    end
    -- if self._ccbOwner.node_one_replay:isVisible() then
    --     -- list:registerItemBoxPrompt(index, 1, self._ccbOwner.btn_one_replay, nil, handler(self, self._onTriggerReplay))
    -- end
end

function QUIWidgetSilvesFightEndDetail:showHeroInfo( x, y, heroHead )
    local actorId = heroHead:getHeroActorID()
    local isSoulSpirit = heroHead:getIsSoulSpirit()
    local unkonwType = heroHead:getHeroType()
    if unkonwType and unkonwType ~= 3 then
        if unkonwType == 1 then
            app.tip:floatTip("该位置未上阵魂师")
        elseif unkonwType == 0 then
            app.tip:floatTip("该位置为隐藏位")
        end
    else
        self:dispatchEvent({name = QUIWidgetSilvesFightEndDetail.EVENT_CLICK_HEAD, actorId = actorId, isHero = true, index = self._info.index, isSoulSpirit = isSoulSpirit})
    end
end

function QUIWidgetSilvesFightEndDetail:showEnemyInfo( x, y, heroHead )
    local actorId = heroHead:getHeroActorID()
    local isSoulSpirit = heroHead:getIsSoulSpirit()
    local unkonwType = heroHead:getHeroType()
    if unkonwType and unkonwType ~= 3 then
        if unkonwType == 1 then
            app.tip:floatTip("该位置未上阵魂师")
        elseif unkonwType == 0 then
            app.tip:floatTip("该位置为隐藏位")
        end
    else
        self:dispatchEvent({name = QUIWidgetSilvesFightEndDetail.EVENT_CLICK_HEAD, actorId = actorId, isHero = false, index = self._info.index, isSoulSpirit = isSoulSpirit})
    end
end

function QUIWidgetSilvesFightEndDetail:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	size.height = self._height+10
	return size
end

function QUIWidgetSilvesFightEndDetail:_onTriggerReplay(event)
    app.sound:playSound("common_cancel")
    self:dispatchEvent({name = QUIWidgetSilvesFightEndDetail.EVENT_CLICK_ONEREPLAY, info = self._info})
end

return QUIWidgetSilvesFightEndDetail

