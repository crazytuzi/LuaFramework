require("ComLogic.LogicDefine")
require("Config.HeroModel")
require("Config.PetModel")
require("Config.ZhenshouModel")

-- 战斗数据统计
StatisticsManager = {}
local self = StatisticsManager

function StatisticsManager.getDefaultData(unit)
    if type(unit) == type(0) then
        return self.data.Hero[unit]
    end
    -- 数据结构
	local defaultData = {
		ModelId = unit.HeroModelId,
		LargePic = unit.LargePic,
		Step = unit.Step,
		TotalHp = unit.TotalHp,
        Name = unit.NpcName,
		Damage = 0,
		Heal = 0,
		HP = 0,
		BeHit = 0, -- 承受伤害值
		Buff = {   -- buff次数统计
            BanAct = 0, -- 眩晕
            BanRA = 0, -- 沉默
            BanNA = 0, -- 麻痹
            HPDOT = 0, -- 流血
            Freeze = 0, -- 冰冻
		}
	}

    -- 侠客
    if HeroModel.items[unit.HeroModelId] then
        self.data.Hero[unit.idx] = self.data.Hero[unit.idx] or defaultData
        return self.data.Hero[unit.idx]
    -- 外功
    elseif PetModel.items[unit.HeroModelId] then
        self.data.Pet[unit.idx] = self.data.Pet[unit.idx] or defaultData
        return self.data.Pet[unit.idx]
    -- 珍兽
    elseif ZhenshouModel.items[unit.HeroModelId] then
        self.data.Zhenshou[unit.idx] = self.data.Zhenshou[unit.idx] or defaultData
        return self.data.Zhenshou[unit.idx]
    end

    return defaultData
end

function StatisticsManager.new()
	self.data = {}
end

-- 初始化数据
function StatisticsManager.reset(heroList, petList, zhenshouList)
	self.data = {}
    self.data.Hero = {}
    self.data.Pet = {}
    self.data.Zhenshou = {}

	-- 填充初始数据
	for i, unit in ipairs(heroList or {}) do
		self.damageStatistics(heroList, 0)
	end
    for i, unit in ipairs(petList or {}) do
        self.damageStatistics(unit, 0)
    end
    for i, unit in ipairs(zhenshouList or {}) do
        self.damageStatistics(unit, 0)
    end
end


-- 统计承受伤害
function StatisticsManager.behitStatistics(unit, value)
	local tmpData = self.getDefaultData(unit)

	tmpData.BeHit = tmpData.BeHit + value
end

-- 统计特殊buff次数
function StatisticsManager.buffStatistics(unit, buff)
	local tmpData = self.getDefaultData(unit)
    local buffModel = BuffModel.items[buff]
    if not buffModel then return end

	-- 眩晕
	if buffModel.stateEnum == ld.BuffState.eBanAct then
        tmpData.Buff.BanAct = tmpData.Buff.BanAct + 1
    -- 沉默
    elseif buffModel.stateEnum == ld.BuffState.eBanRA then
        tmpData.Buff.BanRA = tmpData.Buff.BanRA + 1
    -- 麻痹
    elseif buffModel.stateEnum == ld.BuffState.eBanNA then
        tmpData.Buff.BanNA = tmpData.Buff.BanNA + 1
    -- 流血
    elseif buffModel.stateEnum == ld.BuffState.eHPDOT then
        tmpData.Buff.HPDOT = tmpData.Buff.HPDOT + 1
    -- 冰冻
    elseif buffModel.stateEnum == ld.BuffState.eFreeze then
        tmpData.Buff.Freeze = tmpData.Buff.Freeze + 1
	end
end

-- 伤害统计
function StatisticsManager.damageStatistics(unit, value)
	local tmpData = self.getDefaultData(unit)

	tmpData.Damage = tmpData.Damage + value
end

-- 治疗统计
function StatisticsManager.healStatistics(unit, value)
	local tmpData = self.getDefaultData(unit)

	tmpData.Heal = tmpData.Heal + math.abs(value)
end

-- 侠客最后血量
function StatisticsManager.life(unit)
	local tmpData = self.getDefaultData(unit)

	tmpData.HP = unit.HP
end

-- 返回统计数据
function StatisticsManager.getStatisticsData()
	return clone(self.data)
end

return StatisticsManager
