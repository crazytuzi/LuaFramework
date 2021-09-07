-- -------------------
-- 坐骑枚举
-- hosr
-- -------------------
RideEumn = RideEumn or {}

-- 坐骑技能类型 {"攻击",1}, {"防御",2}, {"效果",3},{"魔攻",4}
RideEumn.SkillType = {
	Attack = 1,
	Defense = 2,
	Effect = 3,
	Magic = 4,
}

-- 坐骑技能作用对象
RideEumn.SkillEffectType = {
	Role = 1, -- 人
	Pet = 2, -- 宠物
}

RideEumn.SkillEffectTypeName = {
	[RideEumn.SkillEffectType.Role] = TI18N("角色"),
	[RideEumn.SkillEffectType.Pet] = TI18N("契约宠物"),
}

RideEumn.SkillLevShow = {
	[1] = "<color='#ffffff'>I</color>",
	[2] = "<color='#ffffff'>II</color>",
	[3] = "<color='#2fc823'>III</color>",
	[4] = "<color='#01c0ff'>IV</color>",
	[5] = "<color='#ff00ff'>V</color>",
	[6] = "<color='#ffa500'>VI</color>",
}

function RideEumn.ColorName(lev, name)
	if lev == 1 or lev == 2 then
		return string.format("<color='#ffffff'>%s</color>", name)
	elseif lev == 3 then
		return string.format("<color='#2fc823'>%s</color>", name)
	elseif lev == 4 then
		return string.format("<color='#01c0ff'>%s</color>", name)
	elseif lev == 5 then
		return string.format("<color='#ff00ff'>%s</color>", name)
	elseif lev == 6 then
		return string.format("<color='#ffa500'>%s</color>", name)
	end
	return name
end