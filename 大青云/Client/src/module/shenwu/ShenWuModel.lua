--[[
神武 model
haohu
2015年12月25日16:36:03
]]

_G.ShenWuModel = Module:new()

-- -- 等阶 0为未激活,刚激活时1级
-- ShenWuModel.level = 10
-- -- 星级 0~9
-- ShenWuModel.star = 0
-- -- 已用成功石数
-- ShenWuModel.useStoneNum = 2
-- -- 升星成功率
-- ShenWuModel.starRate = 500

-- 等阶 -1 为功能未开启，或刚登陆未收到服务器更新数据，0为未激活,刚激活时1级
ShenWuModel.level = -1
-- 星级 0~9
ShenWuModel.star = 0
-- 已用成功石数
ShenWuModel.useStoneNum = 0
-- 升星成功率
ShenWuModel.starRate = 0

function ShenWuModel:GetLevel()
	return self.level
end

function ShenWuModel:SetLevel(lvl)
	if self.level ~= lvl then
		local oldLvl = self.level
		self.level = lvl
		self:sendNotification( NotifyConsts.ShenWuLevel, {lvl = lvl, oldLvl = oldLvl} )
		if oldLvl > -1 then
			self:OnLevelUp()
		end
	end
end

function ShenWuModel:GetStar()
	return self.star
end

function ShenWuModel:SetStar(star)
	if self.star ~= lvl then
		local oldStar = self.star
		self.star = star
		self:sendNotification( NotifyConsts.ShenWuStar, {star = star, oldStar = oldStar} )
	end
end

function ShenWuModel:GetUseStoneNum()
	return self.useStoneNum
end

function ShenWuModel:SetUseStoneNum(num)
	if self.useStoneNum ~= num then
		local oldNum = self.useStoneNum
		self.useStoneNum = num
		self:sendNotification( NotifyConsts.ShenWuStone, {num = num, oldNum = oldNum} )
	end
end

function ShenWuModel:GetStarRate()
	return self.starRate
end

function ShenWuModel:SetStarRate(starRate)
	if self.starRate ~= starRate then
		local oldStarRate = self.starRate
		self.starRate = starRate
		self:sendNotification( NotifyConsts.ShenWuStarRate, {starRate = starRate, oldStarRate = oldStarRate} )
	end
end

function ShenWuModel:IsActive()
	return self.level > 0
end

function ShenWuModel:IsFull()
	return self.level >= ShenWuConsts:GetMaxLevel()
end

function ShenWuModel:IsStarUp()
	return self.level > 0 and self.star + 1 < ShenWuConsts:GetMaxStar()
end

function ShenWuModel:IsLevelUp()
	if self.level == 0 then
		return true
	end
	if self.level == ShenWuConsts:GetMaxLevel() then
		return false
	end
	if self.star + 1 == ShenWuConsts:GetMaxStar() then
		return true
	end
	return false
end

function ShenWuModel:GetShenWuSkills()
	local skills = {}
	for skillId, skillVO in pairs(SkillModel.skillList) do
		local cfg = skillVO:GetCfg()
		if cfg.showtype == SkillConsts.ShowType_ShenWuPassive then 
			table.push( skills, skillId )
		end
	end
	return skills
end

--------------------------------------------------------------------------------------------------------
function ShenWuModel:OnLevelUp()
	UIShenWu:Hide()
	UIShenWuShow:Show()
end
