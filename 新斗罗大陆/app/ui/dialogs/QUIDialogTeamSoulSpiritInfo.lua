-- @Author: zhouxiaoshu
-- @Date:   2019-07-02 10:51:37
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-03 23:44:56

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTeamSoulSpiritInfo = class("QUIDialogTeamSoulSpiritInfo", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QColorLabel = import("...utils.QColorLabel")
local QRichText = import("...utils.QRichText")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetTeamSoulSpiritSkillInfo = import("..widgets.QUIWidgetTeamSoulSpiritSkillInfo")

local QUIWidgetTeamSoulSpiritInfo = import("..widgets.QUIWidgetTeamSoulSpiritInfo")


function QUIDialogTeamSoulSpiritInfo:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_add_buff.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
	}
	QUIDialogTeamSoulSpiritInfo.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true

    self._isCollegeTeam = options.isCollegeTeam or false
    self._chapterId = options.chapterId
    self._isMockBattle = options.isMockBattle or false

    self._ccbOwner.node_right_center:setVisible(false)
    self._ccbOwner.frame_tf_title:setString("魂灵")
    local mainTeam = options.mainTeam or {}
    local helpTeam = {}
    for _,acotrId in pairs(options.helpTeam1 or {}) do
        table.insert(helpTeam, acotrId)
    end
    for _,acotrId in pairs(options.helpTeam2 or {}) do
        table.insert(helpTeam, acotrId)
    end
    for _,acotrId in pairs(options.helpTeam3 or {}) do
        table.insert(helpTeam, acotrId)
    end
    self._soulSpiritIdList = options.soulSpiritId or {}
    local soulSpiritId = self._soulSpiritIdList[1]
    if soulSpiritId then
        self._ccbOwner.node_empty:setVisible(false)
        self._ccbOwner.node_have:setVisible(true)

    	local soulSpiritConfig = db:getCharacterByID(soulSpiritId)

    	-- local rateStr, mainRate = remote.soulSpirit:getFightCoefficientByAptitude(soulSpiritConfig.aptitude)

        self._allProp = {}
    	local helpRate = #mainTeam*0.25
    	local prop = {hp = 0, attack = 0, magic_armor = 0, physical_armor = 0, hit = 0, dodge = 0, block = 0, crit = 0, haste = 0, 
    		physical_penetration = 0, magic_penetration = 0, crit_reduce_rating = 0, physical_damage_percent_attack = 0, 
    		physical_damage_percent_beattack_reduce = 0, magic_damage_percent_attack = 0, magic_damage_percent_beattack_reduce = 0}
    	
    	for _,acotrId in pairs(helpTeam) do
    		local heroModel = nil

            if self._isMockBattle then
                heroModel = remote.mockbattle:getCardUiInfoById(acotrId)
            elseif self._isCollegeTeam then
                heroModel = remote.collegetrain:getHeroModelById(self._chapterId,acotrId)
             else
                heroModel = remote.herosUtil:createHeroPropById(acotrId)
            end
            if heroModel then
        		prop.hp = prop.hp + heroModel:getMaxHp()
        		prop.attack = prop.attack + heroModel:getMaxAttack()
        		prop.magic_armor = prop.magic_armor + heroModel:getMaxArmorMagic()
        		prop.physical_armor = prop.physical_armor + heroModel:getMaxArmorPhysical()
        		prop.hit = prop.hit + heroModel:getMaxHit()
        		prop.dodge = prop.dodge + heroModel:getMaxDodge()
        		prop.block = prop.block + heroModel:getMaxBlock()
        		prop.crit = prop.crit + heroModel:getMaxCrit()
        		prop.haste = prop.haste + heroModel:getMaxHaste()
                prop.physical_penetration = prop.physical_penetration + heroModel:getMaxPhysicalPenetration()
                prop.magic_penetration = prop.magic_penetration + heroModel:getMaxMagicPenetration()
                prop.crit_reduce_rating = prop.crit_reduce_rating + heroModel:getMaxCriReduce()
                prop.physical_damage_percent_attack = prop.physical_damage_percent_attack + heroModel:getPhysicalDamagePercentAttack()
                prop.physical_damage_percent_beattack_reduce = prop.physical_damage_percent_beattack_reduce + heroModel:getPhysicalDamagePercentBeattackReduceTotal()
                prop.magic_damage_percent_attack = prop.magic_damage_percent_attack + heroModel:getMagicDamagePercentAttack()
                prop.magic_damage_percent_beattack_reduce = prop.magic_damage_percent_beattack_reduce + heroModel:getMagicDamagePercentBeattackReduceTotal()
            end
    	end
    	
    	prop.hp = prop.hp * helpRate
    	prop.attack = prop.attack * helpRate
    	prop.magic_armor = prop.magic_armor * helpRate
    	prop.physical_armor = prop.physical_armor * helpRate
    	prop.hit = prop.hit * helpRate
    	prop.dodge = prop.dodge * helpRate
    	prop.block = prop.block * helpRate
    	prop.crit = prop.crit * helpRate
    	prop.haste = prop.haste * helpRate
        prop.physical_penetration = prop.physical_penetration * helpRate
        prop.magic_penetration = prop.magic_penetration * helpRate
        prop.crit_reduce_rating = prop.crit_reduce_rating * helpRate
        prop.physical_damage_percent_attack = prop.physical_damage_percent_attack * helpRate
        prop.physical_damage_percent_beattack_reduce = prop.physical_damage_percent_beattack_reduce * helpRate
        prop.magic_damage_percent_attack = prop.magic_damage_percent_attack * helpRate
        prop.magic_damage_percent_beattack_reduce = prop.magic_damage_percent_beattack_reduce * helpRate
    	
    	for _,acotrId in pairs(mainTeam) do
    		local heroModel = nil
            if self._isCollegeTeam then
                heroModel = remote.collegetrain:getHeroModelById(self._chapterId,acotrId)
            elseif self._isMockBattle then
                heroModel = remote.mockbattle:getCardUiInfoById(acotrId)
            else
                heroModel = remote.herosUtil:createHeroPropById(acotrId)             
            end            
            if heroModel then
        		prop.hp = prop.hp + heroModel:getMaxHp()
        		prop.attack = prop.attack + heroModel:getMaxAttack()
        		prop.magic_armor = prop.magic_armor + heroModel:getMaxArmorMagic()
        		prop.physical_armor = prop.physical_armor + heroModel:getMaxArmorPhysical()
        		prop.hit = prop.hit + heroModel:getMaxHit()
        		prop.dodge = prop.dodge + heroModel:getMaxDodge()
        		prop.block = prop.block + heroModel:getMaxBlock()
        		prop.crit = prop.crit + heroModel:getMaxCrit()
        		prop.haste = prop.haste + heroModel:getMaxHaste()
                prop.physical_penetration = prop.physical_penetration + heroModel:getMaxPhysicalPenetration()
                prop.magic_penetration = prop.magic_penetration + heroModel:getMaxMagicPenetration()
                prop.crit_reduce_rating = prop.crit_reduce_rating + heroModel:getMaxCriReduce()
                prop.physical_damage_percent_attack = prop.physical_damage_percent_attack + heroModel:getPhysicalDamagePercentAttack()
                prop.physical_damage_percent_beattack_reduce = prop.physical_damage_percent_beattack_reduce + heroModel:getPhysicalDamagePercentBeattackReduceTotal()
                prop.magic_damage_percent_attack = prop.magic_damage_percent_attack + heroModel:getMagicDamagePercentAttack()
                prop.magic_damage_percent_beattack_reduce = prop.magic_damage_percent_beattack_reduce + heroModel:getMagicDamagePercentBeattackReduceTotal()
            end
    	end


        self._allProp = prop

    	-- self._ccbOwner.tf_name_1:setString("生命")
     --    -- self._ccbOwner.tf_value_1:setString("+"..math.floor(prop.hp*mainRate))
    	-- self._ccbOwner.tf_value_1:setString("无敌")
    	-- self._ccbOwner.tf_name_2:setString("攻击")
    	-- self._ccbOwner.tf_value_2:setString("+"..math.floor(prop.attack*mainRate))
    	-- self._ccbOwner.tf_name_3:setString("命中")
    	-- self._ccbOwner.tf_value_3:setString("+"..math.floor(prop.hit*mainRate))
    	-- self._ccbOwner.tf_name_4:setString("闪避")
    	-- self._ccbOwner.tf_value_4:setString("+"..math.floor(prop.dodge*mainRate))
     --    self._ccbOwner.tf_name_5:setString("物理防御")
     --    self._ccbOwner.tf_value_5:setString("+"..math.floor(prop.physical_armor*mainRate))
     --    self._ccbOwner.tf_name_6:setString("法术防御")
     --    self._ccbOwner.tf_value_6:setString("+"..math.floor(prop.magic_armor*mainRate))
     --    self._ccbOwner.tf_name_7:setString("物理穿透")
     --    self._ccbOwner.tf_value_7:setString("+"..math.floor(prop.physical_penetration*mainRate))
     --    self._ccbOwner.tf_name_8:setString("法术穿透")
     --    self._ccbOwner.tf_value_8:setString("+"..math.floor(prop.magic_penetration*mainRate))
    	-- self._ccbOwner.tf_name_9:setString("格挡")
    	-- self._ccbOwner.tf_value_9:setString("+"..math.floor(prop.block*mainRate))
    	-- self._ccbOwner.tf_name_10:setString("暴击")
    	-- self._ccbOwner.tf_value_10:setString("+"..math.floor(prop.crit*mainRate))
    	-- self._ccbOwner.tf_name_11:setString("攻速")
    	-- self._ccbOwner.tf_value_11:setString("+"..math.floor(prop.haste*mainRate))
     --    self._ccbOwner.tf_name_12:setString("抗暴")
     --    self._ccbOwner.tf_value_12:setString("+"..math.floor(prop.crit_reduce_rating*mainRate))
     --    self._ccbOwner.tf_name_13:setString("物理加伤")
     --    self._ccbOwner.tf_value_13:setString("+"..string.format("%.1f%%", prop.physical_damage_percent_attack*mainRate*100))
     --    self._ccbOwner.tf_name_14:setString("物理减伤")
     --    self._ccbOwner.tf_value_14:setString("+"..string.format("%.1f%%", prop.physical_damage_percent_beattack_reduce*mainRate*100))
     --    self._ccbOwner.tf_name_15:setString("法术加伤")
     --    self._ccbOwner.tf_value_15:setString("+"..string.format("%.1f%%", prop.magic_damage_percent_attack*mainRate*100))
     --    self._ccbOwner.tf_name_16:setString("法术减伤")
     --    self._ccbOwner.tf_value_16:setString("+"..string.format("%.1f%%", prop.magic_damage_percent_beattack_reduce*mainRate*100))

     --    self._ccbOwner.node_skill_1:removeAllChildren()
     --    self._ccbOwner.node_skill_2:removeAllChildren()
     --    self._ccbOwner.tf_title_skill:setVisible(false)
    	-- local soulSpirit = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
     --    if self._isCollegeTeam then
     --        soulSpirit = remote.collegetrain:getSpritInfoById(self._chapterId,soulSpiritId)
     --    end
     --    local soulSpirit = nil
     --    if self._isCollegeTeam then
     --        soulSpirit = remote.collegetrain:getSpritInfoById(self._chapterId,soulSpiritId)
     --        heroModel = remote.collegetrain:getHeroModelById(self._chapterId,acotrId)
     --    elseif self._isMockBattle then
     --        soulSpirit = remote.mockbattle:getCardUiInfoById(soulSpiritId)
     --    else
     --        soulSpirit = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)           
     --    end       

    	-- local gradeConfig = db:getGradeByHeroActorLevel(soulSpirit.id, soulSpirit.grade)
    	-- if gradeConfig then
     --        local skillId1 = string.split(gradeConfig.soulspirit_pg, ":")
     --        local skillId2 = string.split(gradeConfig.soulspirit_dz, ":")
     --        local skillConfig1 = db:getSkillByID(tonumber(skillId1[1]))
     --        if skillConfig1 ~= nil then
     --            local describe = "##e"..skillConfig1.name.."：##n"..(skillConfig1.description or "")
     --            describe = QColorLabel.replaceColorSign(describe)
     --    		describe = string.gsub(describe, "\n", "  ")
     --            local richText = QRichText.new(describe, 760, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
     --            richText:setAnchorPoint(ccp(0, 1))
     --            self._ccbOwner.node_skill_1:addChild(richText)
     --        end

     --        local skillConfig2 = db:getSkillByID(tonumber(skillId2[1]))
     --        if skillConfig2 ~= nil then
     --            local describe = "##e"..skillConfig2.name.."：##n"..(skillConfig2.description or "")
     --            describe = QColorLabel.replaceColorSign(describe)
     --    		describe = string.gsub(describe, "\n", "  ")
     --            local richText = QRichText.new(describe, 760, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
     --            richText:setAnchorPoint(ccp(0, 1))
     --            self._ccbOwner.node_skill_2:addChild(richText)
     --        end
     --    end

      --   local tipDesc1 = "魂灵战斗属性=上阵主力英雄属性x"..rateStr
      --   local tipDesc2 = "魂灵战斗属性影响魂灵的普攻和魂技，魂灵技能只有上阵时有效"
     	-- self._ccbOwner.tf_rule_1:setString(tipDesc1)
     	-- self._ccbOwner.tf_rule_2:setString(tipDesc2)
        self:initListView()
    else
        self._ccbOwner.node_empty:setVisible(true)
        self._ccbOwner.node_have:setVisible(false)
    end

    if self._isMockBattle then
        self._ccbOwner.node_rule:setVisible(false)
    end

end

function QUIDialogTeamSoulSpiritInfo:initListView()
    if not self._skillListView then
        local cfg = {
            renderItemCallBack = handler(self,self.renderFunHandler),
            ignoreCanDrag = true,
            enableShadow = false,
            totalNumber = #self._soulSpiritIdList,
        }  
        self._skillListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._skillListView:refreshData()
    end
end

function QUIDialogTeamSoulSpiritInfo:renderFunHandler(list, index, info)
    local isCacheNode = true
    local soulSpiritId = self._soulSpiritIdList[index]
    local item = list:getItemFromCache()

    if not item then
        item = QUIWidgetTeamSoulSpiritInfo.new()
        isCacheNode = false
    end
    info.item = item
    item:setInfo(index,soulSpiritId,self._allProp,self._isCollegeTeam, self._chapterId,self._isMockBattle)
    info.size = item:getContentSize()
    return isCacheNode
end

function QUIDialogTeamSoulSpiritInfo:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogTeamSoulSpiritInfo:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
    if event ~= nil then
        app.sound:playSound("common_cancel")
    end
	self:playEffectOut()
end

function QUIDialogTeamSoulSpiritInfo:_onTriggerRule(e)
    if e ~= nil then
        app.sound:playSound("common_small")
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritHelp", options = {}}, {isPopCurrentDialog = false})
end

function QUIDialogTeamSoulSpiritInfo:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogTeamSoulSpiritInfo