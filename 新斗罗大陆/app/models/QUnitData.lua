-- 根据策划配置量表生成魂师、魂灵、暗器的数据类


local QUnitData = class("QUnitData")
local QActorProp = import(".QActorProp")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QSoulSpiritProp = import(".QSoulSpiritProp")

QUnitData.TYPE_HERO = 1
QUnitData.TYPE_MOUNT = 2
QUnitData.TYPE_SOUL = 3
QUnitData.TYPE_GODARM = 4


function QUnitData:ctor(options)
	--options :{ utype , data} 
	-- utype : hero \ mount \soulSpirit
	-- data ：策划配置的本地数据表
	self.utype = options.utype
	--QPrintTable(options.data)

	if options.utype == QUnitData.TYPE_HERO then
		self:initHeroData(options.data)
	elseif  options.utype == QUnitData.TYPE_MOUNT then
		self:initMountData(options.data)
	elseif  options.utype == QUnitData.TYPE_SOUL then
		self:initSoulSpiritData(options.data)
    elseif  options.utype == QUnitData.TYPE_GODARM then
        self:initGodArmData(options.data)
	end
end

function QUnitData:initHeroData(data)
	local target_id = data.character_id 
    local character = db:getCharacterByID(target_id)
    self.actorId = target_id
    self.godSkillGrade =  0
    if character and character.aptitude == APTITUDE.SS then
       self.godSkillGrade = data.hero_god_skill_level or 1
    end         
    self.skinId =  0
    self.level = data.hero_level or 1
    self.breakthrough = data.hero_breakthrough
    self.grade = data.hero_grade
    self.equipments = self:initEquipment(target_id,data)
    self.slots = self:initSkill(target_id,data)
    self.gemstones = self:initGemstone(target_id,data)
    self.spars = self:initSpar(target_id,data)
    self.artifact = self:initArtifact(target_id,data)
    self.magicHerbs = self:initMagicHerb(target_id,data)
    local uiModel = QActorProp.new()
    uiModel:setHeroInfo(self, {})
    self.uiModel = uiModel 
    self.force = uiModel:getBattleForce(true)  
end


function QUnitData:initMountData(data)
	local target_id = data.character_id 
    self.actorId = target_id
    self.zuoqi = self:initMount(target_id,data)
    self.grade =  data.star
    self.uiModel = {id=target_id ,level = data.enhance,grade = data.star}
end


function QUnitData:initSoulSpiritData(data)
	local target_id = data.character_id 
    self.actorId = target_id
    self.soulSpiritId = target_id
    self.grade =  data.star 
    self.uiModel = {id = target_id ,level = data.enhance ,grade = data.star}
    self.soulSpirit= self:initSoulSpirit(target_id,data)
end

function QUnitData:initGodArmData(data)
    local target_id = data.character_id 
    self.actorId = target_id
    self.godarmId = target_id
    self.grade =  data.star 
    self.uiModel = {id = target_id ,level = data.enhance ,grade = data.star}
    self.godarm= self:initGodArm(target_id,data)
end

--hero_jewelry_breakthrough  备注 饰品突破后饰品id会改变
--hero_equip_enhance
--hero_jewelry_enhance
--hero_equip_enchant
--hero_jewelry_enchant
function QUnitData:initEquipment(heroId,cardInfo)
    local characterInfo = db:getCharacterByID(heroId)
    local breakConfig = db:getBreakthroughByTalentLevel(characterInfo.talent,cardInfo.hero_breakthrough) --突破配置表
    local equipments = {}
    table.insert(equipments,{level=cardInfo.hero_equip_enhance or 0,itemId=breakConfig.weapon,enhance_exp = 0,enchants=cardInfo.hero_equip_enchant or 0})
    table.insert(equipments,{level=cardInfo.hero_equip_enhance or 0,itemId=breakConfig.clothes,enhance_exp = 0,enchants=cardInfo.hero_equip_enchant or 0})
    table.insert(equipments,{level=cardInfo.hero_equip_enhance or 0,itemId=breakConfig.bracelet,enhance_exp = 0,enchants=cardInfo.hero_equip_enchant or 0})
    table.insert(equipments,{level=cardInfo.hero_equip_enhance or 0,itemId=breakConfig.shoes,enhance_exp = 0,enchants=cardInfo.hero_equip_enchant or 0})
    table.insert(equipments,{level=cardInfo.hero_jewelry_enhance or 0,itemId=breakConfig.jewelry1,enhance_exp = 0,enchants=cardInfo.hero_jewelry_enchant or 0})
    table.insert(equipments,{level=cardInfo.hero_jewelry_enhance or 0,itemId=breakConfig.jewelry2,enhance_exp = 0 ,enchants=cardInfo.hero_jewelry_enchant or 0})

    return equipments
end

--hero_skill_level
function QUnitData:initSkill(heroId,cardInfo)
    local breakHeroConfig = db:getBreakthroughHeroByActorId(heroId) --突破数值表
    local skills = {}
    local index = 1
    if breakHeroConfig ~= nil then
        for _,value in pairs(breakHeroConfig) do
            if tonumber(value.breakthrough_level) <= tonumber(cardInfo.hero_breakthrough) then
                for i=1,3 do
                    local slotId = value["skill_id_"..i]
                    if slotId ~= nil then
                        local slotInfo = db:getSkillByActorAndSlot(heroId,slotId)
                        if slotInfo then
                            skills[index] = {}
                            skills[index].slotId = slotId
                            skills[index].slotLevel = cardInfo.hero_skill_level
                            --skills[index].info = {slotLevel = cardInfo.hero_skill_level}
                            local skillId = QStaticDatabase:sharedDatabase():getSkillByActorAndSlot(heroId, slotId)
                            --skills[index].skillId = skillId
                            index = index + 1
                        end
                    end                
                end

                local slotId = value.skill_id_4
                if slotId ~= nil then
                    local slotInfo = db:getSkillByActorAndSlot(heroId,slotId)
                    if slotInfo then
                        skills[index] = {}
                        skills[index].slotId = slotId
                        skills[index].slotLevel = cardInfo.hero_skill_level
                        --skills[index].info = {slotLevel = cardInfo.hero_skill_level}
                        local skillId = QStaticDatabase:sharedDatabase():getSkillByActorAndSlot(heroId, slotId)
                        --skills[index].skillId = skillId
                        index = index + 1
                    end
                end
            end
        end
    end

    return skills
end

--stone_id_1
--stone_enhance_1
--stone_breakthrough_1
function QUnitData:initGemstone(heroId,cardInfo)
    local gemstones = {}
    local gemstonesList = string.split(cardInfo.stone_id_1, ";")
    local index_ = 1
    for _,id in pairs(gemstonesList) do
        table.insert(gemstones,{itemId= id or 0,level=cardInfo.stone_enhance_1 or 0, craftLevel = cardInfo.stone_breakthrough_1 or 0 ,sid = index_})
        index_ = index_ + 1
    end
    return gemstones
end

--liushi_id
--spar_star_1
--spar_enhance_1
function QUnitData:initSpar(heroId,cardInfo)
    local spars = {}
    local sparsList = string.split(cardInfo.liushi_id, ";")

    for _,id in pairs(sparsList) do
        table.insert(spars,{itemId= id or 0,level= cardInfo.spar_enhance_1 or 0, grade = cardInfo.spar_star_1 or 0})
    end
    return spars
end

--artifact_level
--artifact_star
function QUnitData:initArtifact(heroId,cardInfo)
    local artifactProp = {}
    local character= db:getCharacterByID(heroId)
    if character.artifact_id ~= nil then
        local skillConfig = db:getArtifactSkillConfigById(character.artifact_id) or {}
        local skills = {}
        for _, config in ipairs(skillConfig) do
            if config.skill_order <= cardInfo.artifact_star then
                skills[config.skill_order] = { skillId = config.skill_id , skillLevel = config.skill_level }
            end
        end
        artifactProp ={ artifactLevel = cardInfo.artifact_level , artifactBreakthrough = cardInfo.artifact_star , artifactSkillList = skills  }
    end
    --QPrintTable(artifactProp)
    return artifactProp
end

--magic_herb_id
--magic_herb_star
--magic_herb_level
function QUnitData:initMagicHerb(heroId,cardInfo)
    local magicHerbs = {}
    local magicHerbsList = string.split(cardInfo.magic_herb_id, ";")
    for _,id in pairs(magicHerbsList) do
        table.insert(magicHerbs,{itemId= id or 0,level= cardInfo.magic_herb_level or 0, grade = cardInfo.magic_herb_star or 0})
    end
    return magicHerbs
end

function QUnitData:initMount(id,cardInfo)
    local mountInfo = {}
    mountInfo = {zuoqiId = id,enhanceLevel = cardInfo.enhance ,grade = cardInfo.star}
    local character = db:getCharacterByID(id)
    --给ss暗器添加附属暗器
    if character and character.aptitude == APTITUDE.SS then
        local wearZuoqiInfo ={ zuoqiId = id , grade = cardInfo.wear_anqi_star , superZuoqiId = id}
        mountInfo.wearZuoqiInfo = wearZuoqiInfo
    end
    return mountInfo
end

function QUnitData:initSoulSpirit(id,cardInfo)
    local soulSpiritInfo = {}
    soulSpiritInfo= {zuoqiId = id,enhanceLevel = cardInfo.enhance ,grade = cardInfo.star}
    return soulSpiritInfo
end

function QUnitData:initGodArm(id,cardInfo)
    local godarmInfo = {}
    godarmInfo= {id = id,enhanceLevel = cardInfo.enhance ,grade = cardInfo.star}
    return godarmInfo
end

return QUnitData