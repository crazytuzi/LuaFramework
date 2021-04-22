
local QBattleDialog = import(".QBattleDialog")
local QBattleDialogAutoSkill = class("QBattleDialogAutoSkill", QBattleDialog)

local QUserData = import("...utils.QUserData")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QBattleAutoSkillBox = import(".QBattleAutoSkillBox")

QBattleDialogAutoSkill.BOX_WIDTH = 160
QBattleDialogAutoSkill.MINI_WIDTH = 760
QBattleDialogAutoSkill.SCALE = 0.9
QBattleDialogAutoSkill.MAX_WIDTH = 1120
QBattleDialogAutoSkill.PLACE_HOLD = "PLACE_HOLD"
QBattleDialogAutoSkill.OPEN = "一键开启"
QBattleDialogAutoSkill.CLOSE = "一键关闭"

function QBattleDialogAutoSkill:ctor(owner, options)
	local ccbFile = "Battle_AutoSkill.ccbi"
	if owner == nil then
		owner = {}
	end

	owner.onCastSwitch = handler(self, QBattleDialogAutoSkill.oneClickCastSpell)
    owner.onTriggerClose = handler(self, QBattleDialogAutoSkill._backClickHandler)

	self:setNodeEventEnabled(true)
	QBattleDialogAutoSkill.super.ctor(self, ccbFile, owner)

	local heroes = app.battle:getHeroes()
	local deadHeroes = app.battle:getDeadHeroes()
	local supportSkillHero = app.battle:getSupportSkillHero()
	local supportSkillHero2 = app.battle:getSupportSkillHero2()
	local supportSkillHero3 = app.battle:getSupportSkillHero3()
    local soulSpiritHeros = app.battle:getSoulSpiritHero()

    self._showHeros = {}
    self._showSkills = {}
    self._skillBoxDict = {}
    self._castSwitchOn = true

	-- local teamName = remote.teamManager.INSTANCE_TEAM
	-- local dungeonConfig = app.battle:getDungeonConfig()
	-- if dungeonConfig.teamName ~= nil then
 --        teamName = dungeonConfig.teamName
 --    end
    
 --    local heroIds = remote.teamManager:getActorIdsByKey(teamName)

 --    if app.battle:isPVEMultipleWave() then
 --       heroIds = {}
 --       for k,v in pairs(app.battle:getDungeonConfig().heroInfos) do
 --           table.insert(heroIds,v.actorId)
 --       end
 --    end

 --    local heroIdsTurnover = {}
 --    for _, heroId in ipairs(heroIds) do
 --    	table.insert(heroIdsTurnover, 1, heroId)
 --    end

    -- local count = #heroIdsTurnover
	-- for i, heroId in ipairs(heroIdsTurnover) do
    for i, heroInfo in ipairs(app.battle:getDungeonConfig().heroInfos) do
        -- local heroInfo = remote.herosUtil:getHeroByID(heroId)
        local hero = nil
        for _, actor in ipairs(heroes) do
        	if actor:getActorID(true) == tonumber(heroInfo.actorId) then
        		hero = actor
        		break
        	end
        end
        if hero == nil then
        	for _, actor in ipairs(deadHeroes) do
	        	if actor:getActorID(true) == tonumber(heroInfo.actorId) then
	        		hero = actor
	        		break
	        	end
	        end
        end

  		if hero ~= nil then
            table.insert(self._showHeros, hero)
  			-- self["_hero" .. tostring(count - i + 1)] = hero
  			local skills = {}
  			for _, skill in pairs(hero:getManualSkills()) do
  				table.insert(skills, skill)
  			end
  			 
  			if #skills > 0 then
                self._showSkills[hero:getActorID()] = skills[1]
  				-- self["_skill" .. tostring(count - i + 1)] = skills[1]
  			end
  		end
    end

    -- 常驻4个英雄
    local holdCount = 4 - #self._showHeros
    if holdCount > 0 then
        for i = 1, holdCount do
            table.insert(self._showHeros, QBattleDialogAutoSkill.PLACE_HOLD .. tostring(i))
        end
    end

    if supportSkillHero ~= nil then
        table.insert(self._showHeros, supportSkillHero)
        self._showSkills[supportSkillHero:getActorID()] = supportSkillHero:getFirstManualSkill()
    end

    if supportSkillHero2 ~= nil then
        table.insert(self._showHeros, supportSkillHero2)
        self._showSkills[supportSkillHero2:getActorID()] = supportSkillHero2:getFirstManualSkill()
    end

    if supportSkillHero3 ~= nil then
        table.insert(self._showHeros, supportSkillHero3)
        self._showSkills[supportSkillHero3:getActorID()] = supportSkillHero3:getFirstManualSkill()
    end

    if #soulSpiritHeros > 0 then
        for _, soulSpiritHero in ipairs(soulSpiritHeros) do
            table.insert(self._showHeros, soulSpiritHero)
            self._showSkills[soulSpiritHero:getActorID()] = soulSpiritHero:getFirstManualSkill()
        end
    end

    local index = 0
    for _, actor in ipairs(self._showHeros) do
        local box
        if type(actor) == "table" then
            if actor:isSoulSpirit() then
                box = QBattleAutoSkillBox.new(QBattleAutoSkillBox.TYPE_SOULSPIRIT, nil, handler(self, self.updateOneClickButton))
            elseif actor:isSupportHero() then
                if actor == supportSkillHero then
                    index = 1
                elseif actor == supportSkillHero2 then
                    index = 2
                elseif actor == supportSkillHero3 then
                    index = 3
                end
                box = QBattleAutoSkillBox.new(QBattleAutoSkillBox.TYPE_SUPPORT, index, handler(self, self.updateOneClickButton))
            else
                box = QBattleAutoSkillBox.new(QBattleAutoSkillBox.TYPE_HERO, nil, handler(self, self.updateOneClickButton))
            end
            local actorId = actor:getActorID()
            self._castSwitchOn = box:setHeroInfo(actor, self._showSkills[actorId])
            self._skillBoxDict[actorId] = box
        elseif type(actor) == "string" then
            box = QBattleAutoSkillBox.new(QBattleAutoSkillBox.TYPE_HERO)
            box:setHeroInfo()
            self._skillBoxDict[actor] = box
        end
        box:setPositionY(20)
        self._ccbOwner.autoSkillRoot:addChild(box)
    end

    local preWidth = self._ccbOwner.node_frame_parent:getContentSize().width
    local totalWidth = #self._showHeros * QBattleDialogAutoSkill.BOX_WIDTH
    if totalWidth < QBattleDialogAutoSkill.MINI_WIDTH then
        self._width = QBattleDialogAutoSkill.MINI_WIDTH
    else
        if totalWidth > QBattleDialogAutoSkill.MAX_WIDTH then
            totalWidth = QBattleDialogAutoSkill.MAX_WIDTH
        end
        self._width = totalWidth
        local height = self._ccbOwner.node_frame_parent:getContentSize().height
        self._ccbOwner.node_frame_parent:setContentSize(CCSize(self._width, height))
        self._ccbOwner.bg1:setPreferredSize(CCSize(self._width, height))
        self._ccbOwner.bg2:setPreferredSize(CCSize(self._width, height))
        local height2 = self._ccbOwner.sprite_frontBg:getContentSize().height
        self._ccbOwner.sprite_frontBg:setContentSize(CCSize(self._width * QBattleDialogAutoSkill.SCALE, height2))
    end

    self:_autoLayout()

    if self._castSwitchOn then
        self._ccbOwner.btn_title:setString(QBattleDialogAutoSkill.CLOSE)
    else
        self._ccbOwner.btn_title:setString(QBattleDialogAutoSkill.OPEN)
    end
    local x = self._ccbOwner.frame_btn_close:getPositionX()
    self._ccbOwner.frame_btn_close:setPositionX(x + (self._width - preWidth) / 2)
    self._ccbOwner.frame_tf_title:setString("自动魂技")
end

function QBattleDialogAutoSkill:_autoLayout()
    local count = #self._showHeros
    local realWidth = self._width * QBattleDialogAutoSkill.SCALE
    local width = realWidth / count
    local halfWidth = realWidth / 2

    local posX = -halfWidth + width / 2
    for i = 1, count do
        local actorId
        if type(self._showHeros[i]) == "table" then
            actorId = self._showHeros[i]:getActorID()
        else
            actorId = self._showHeros[i]
        end
        local box = self._skillBoxDict[actorId]
        box:setPositionX(posX)
        posX = posX + width
    end
end

function QBattleDialogAutoSkill:oneClickCastSpell(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn) == false then
        return
    end

	self._castSwitchOn = not self._castSwitchOn
	if self._castSwitchOn then 
        for _, box in pairs(self._skillBoxDict) do
            box:changeAutoSkillState("on")
        end
        self._ccbOwner.btn_title:setString(QBattleDialogAutoSkill.CLOSE)
	else
        for _, box in pairs(self._skillBoxDict) do
            box:changeAutoSkillState("off")
        end
        self._ccbOwner.btn_title:setString(QBattleDialogAutoSkill.OPEN)
	end
end

-- Update text of one-click button if all the switchs are on or off
function QBattleDialogAutoSkill:updateOneClickButton()
	local allOn = true
	local allOff = true
	for _, box in pairs(self._skillBoxDict) do
		if box:getAutoSkillState() == nil then
			-- do nothing, next loop
		elseif box:getAutoSkillState() then
			allOff = false
		else
			allOn = false
		end
	end

	if allOn then
        self._ccbOwner.btn_title:setString(QBattleDialogAutoSkill.CLOSE)
		self._castSwitchOn = true
	elseif allOff then
        self._ccbOwner.btn_title:setString(QBattleDialogAutoSkill.OPEN)
		self._castSwitchOn = false
	end
end

function QBattleDialogAutoSkill:_backClickHandler(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then
        return
    end

    self:close()
end

return QBattleDialogAutoSkill
