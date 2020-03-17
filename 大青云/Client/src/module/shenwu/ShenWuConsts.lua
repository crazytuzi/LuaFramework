--[[
神武 constants
haohu
2015年12月25日16:36:03
]]

_G.ShenWuConsts = {}

ShenWuConsts.stoneId = 140649404
-- 默认显示的武器id
ShenWuConsts.defaultWuQi = {
	[1] = 220012100,
	[2] = 220012200,
	[3] = 220012300,
	[4] = 220012400,
}

function ShenWuConsts:GetDefaultWuQi()
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	return ShenWuConsts.defaultWuQi[prof]
end

-- 最高等级
function ShenWuConsts:GetMaxLevel()
	local maxLevel = 0
	for lvl, _ in pairs(t_shenwu) do
		maxLevel = math.max(maxLevel, lvl)
	end
	return maxLevel
end

-- 最高星级
function ShenWuConsts:GetMaxStar(lvl)
	return 10
end

function ShenWuConsts:GetStoneRate()
	local cfg = t_item[self.stoneId]
	if not cfg then return 0 end
	return cfg.use_param_1
end

ShenWuConsts.Attrs = {"att", "absatt", "cri", "hit", "shenwei" }

ShenWuConsts.AttrNames = {
	["att"] = StrConfig['shenwu15'],
	["absatt"] = StrConfig['shenwu20'],
	["cri"]  = StrConfig['shenwu19'],
	["hit"] = StrConfig['shenwu18'],
	["shenwei"] = StrConfig['shenwu26'],
}

ShenWuConsts.freeSkillGroupDic = nil
function ShenWuConsts:GetFreeSkillGroupDic()
	if not self.freeSkillGroupDic then
		self.freeSkillGroupDic = {}
		local skills = ShenWuUtils:GetSkill(1)
		for _, skillId in pairs(skills) do
			local cfg = skillId and t_passiveskill[skillId]
			local skillGroup = cfg and cfg.group_id
			if skillGroup then
				self.freeSkillGroupDic[skillGroup] = true
			end
		end
	end
	return self.freeSkillGroupDic
end