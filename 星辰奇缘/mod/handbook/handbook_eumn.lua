-- ------------------------------------
-- 幻化收藏册枚举
-- hosr
-- ------------------------------------
HandbookEumn = HandbookEumn or {}

HandbookEumn.TypeName = {
	[1] = TI18N("初级"),
	[2] = TI18N("中级"),
	[3] = TI18N("高级"),
}

HandbookEumn.EffectType = {
	Pet = 1, -- 宠物
	Guard = 2, -- 守护
	Role = 3, -- 角色
	NPC = 4,
}

HandbookEumn.EffectTypeName = {
	[HandbookEumn.EffectType.Pet] = "宠物",
	[HandbookEumn.EffectType.Guard] = "守护",
	[HandbookEumn.EffectType.Role] = "角色",
}

-- 激活状态
HandbookEumn.Status = {
	InActive = 0, -- 未激活
	Active = 1, -- 激活
}