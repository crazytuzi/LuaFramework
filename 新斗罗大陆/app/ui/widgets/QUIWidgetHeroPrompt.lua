local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroPrompt = class("QUIWidgetHeroPrompt", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QColorLabel = import("...utils.QColorLabel")

function QUIWidgetHeroPrompt:ctor(options)
    local ccbFile = "ccb/Dialog_Heroxiangqing.ccbi"
    local callBacks = {}
    QUIWidgetHeroPrompt.super.ctor(self, ccbFile, callBacks, options)
  
    self._itemId = options.itemId
    self._itemType = options.itemType
    self._database = QStaticDatabase:sharedDatabase()
    -- local heroConfig = self._database:getCharacterByID(itemId)
    -- self._hero = remote.herosUtil:getHeroByID(self.heroInfo.id)
    -- self.heroDisplay = self._database:getBreakthroughHeroByHeroActorLevel(self.heroInfo.id, 0)
    
    -- self.skillId = self._database:getSkillByActorAndSlot(self.heroInfo.id, self.heroDisplay.skill_id_3)
    -- self.skill = self._database:getSkillByID(self.skillId)

    self:setItemInfo()
    self:setSkillInfo()
end

function QUIWidgetHeroPrompt:setItemInfo()
    local itemConfig = self._database:getItemByID(self._itemId)
    local itemType = ITEM_TYPE.ITEM
    local contentName = "拥有："
    local content = ""
    if self._itemType == ITEM_TYPE.HERO_PIECE then
        local heroId = self._database:getActorIdBySoulId(self._itemId, 0) or 0
        self._heroId = tonumber(heroId)

        local gradeLevel = 0
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        if heroInfo ~= nil then
            gradeLevel = heroInfo.grade+1 or 0
        end

        local info = self._database:getGradeByHeroActorLevel(heroId, gradeLevel) or {}
        local needNum = info.soul_gem_count or 0
        local currentNum = remote.items:getItemsNumByID(self._itemId) or 0
        local heroConfig = self._database:getCharacterByID(heroId)
        if (heroConfig.aptitude == APTITUDE.SS or heroConfig.aptitude == APTITUDE.SSR) and gradeLevel > 0 then
            local godSkillTbl = db:getGodSkillById(heroId)
            local godSkillGrade = heroInfo.godSkillGrade or 1
            local godSkillConfig = godSkillTbl[godSkillGrade+1] or {}
            needNum = godSkillConfig.stunt_num or 0
        end
        if needNum > 0 then
            content = currentNum.."/"..needNum
        else
            content = currentNum
        end
    else
        itemConfig = self._database:getCharacterByID(self._itemId)
        contentName = "类型："
        itemType = ITEM_TYPE.HERO
        content = itemConfig.label or ""
        self._heroId = self._itemId
    end

    local icon = QUIWidgetItemsBox.new()
    self._ccbOwner.node_icon:addChild(icon)
    icon:setGoodsInfo(self._itemId, itemType)

    self._ccbOwner.tf_name:setString(itemConfig.name)
    self._ccbOwner.tf_type_title:setString(contentName)
    self._ccbOwner.tf_type:setString(content or "")
end

function QUIWidgetHeroPrompt:setSkillInfo()
    local skillLevel = 1
    local heroInfo = remote.herosUtil:getHeroByID(self._heroId)
    if heroInfo ~= nil and self._itemType ~= ITEM_TYPE.HERO_PIECE then
        for _, value in pairs(heroInfo.slots) do
            if value.slotId == 3 then
                skillLevel = value.slotLevel
                break 
            end
        end
    end
    local heroDisplay = self._database:getBreakthroughHeroByHeroActorLevel(self._heroId, 0)
    local skillId = self._database:getSkillByActorAndSlot(self._heroId, heroDisplay.skill_id_3)
    local skillInfo = self._database:getSkillByID(tonumber(skillId))
    self._ccbOwner.tf_skill_name:setString(skillInfo.name or "")
    local skillDec = QColorLabel.removeColorSign(skillInfo.description)
    self._ccbOwner.tf_skill:setString(skillDec or "")

    self._assistSkill = self._database:getAssistSkill(self._heroId)
    if self._assistSkil then
        self._ccbOwner.tf_assist_skill_name:setString("融合·"..(self._assistSkill.name or ""))
        local skillDec = QColorLabel.removeColorSign(self._assistSkill.super_skill_postil)
        self._ccbOwner.tf_assist_skill:setString(skillDec or "")
    else
        self._ccbOwner.node_assist_skill:setVisible(false)
        self._ccbOwner.node_bg_long:setContentSize(CCSize(408, 250))
        self._ccbOwner.node_skill:setPositionY(-60)
        self._ccbOwner.node_title:setPositionY(-54)
    end
end

return QUIWidgetHeroPrompt