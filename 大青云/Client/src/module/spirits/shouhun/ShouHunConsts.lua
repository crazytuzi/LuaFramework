--[[
灵兽魂魄 constants
2016年1月14日15:22:35
haohu
]]

_G.ShouHunConsts = {}

-- 魂魄id = { t_wuhun属性key, 属性类型 }
ShouHunConsts.config = {
	[1] = {
		cfgKey = "prop_attack",
		attrType = enAttrType.eaGongJi,
		name = StrConfig["shouhun1"],
	},
	[2] = {
		cfgKey = "prop_defend",
		attrType = enAttrType.eaFangYu,
		name = StrConfig["shouhun2"],
	},
	[3] = {
		cfgKey = "prop_hp",
		attrType = enAttrType.eaMaxHp,
		name = StrConfig["shouhun3"],
	},
	[4] = {
		cfgKey = "prop_critical",
		attrType = enAttrType.eaBaoJi,
		name = StrConfig["shouhun4"],
	},
	[5] = {
		cfgKey = "prop_defcri",
		attrType = enAttrType.eaRenXing,
		name = StrConfig["shouhun5"],
	},
	[6] = {
		cfgKey = "prop_dodge",
		attrType = enAttrType.eaShanBi,
		name = StrConfig["shouhun6"],
	},
	[7] = {
		cfgKey = "prop_hit",
		attrType = enAttrType.eaMingZhong,
		name = StrConfig["shouhun7"],
	}
}

ShouHunConsts.MaxShouHunNum = getTableLen( ShouHunConsts.config )

ShouHunConsts.maxLevel = nil
function ShouHunConsts:GetMaxLevel()
	if not ShouHunConsts.maxLevel then
		local maxLevel = 0
		for _, cfg in pairs(t_lingshousoul) do
			maxLevel = math.max( maxLevel, cfg.level )
		end
		ShouHunConsts.maxLevel = maxLevel
	end
	return ShouHunConsts.maxLevel
end

ShouHunConsts.maxStar = nil
function ShouHunConsts:GetMaxStar()
	if not ShouHunConsts.maxStar then
		local maxStar = 0
		for _, cfg in pairs(t_lingshousoul) do
			if cfg.level == 1 then
				maxStar = maxStar + 1
			end
		end
		ShouHunConsts.maxStar = maxStar
	end
	return ShouHunConsts.maxStar
end

ShouHunConsts.AttrName = {
	[enAttrType.eaGongJi]    = StrConfig['lunpan14'],
	[enAttrType.eaFangYu]    = StrConfig['lunpan15'],
	[enAttrType.eaMingZhong] = StrConfig['lunpan16'],
	[enAttrType.eaShanBi]    = StrConfig['lunpan17'],
	[enAttrType.eaBaoJi]     = StrConfig['lunpan18'],
	[enAttrType.eaRenXing]   = StrConfig['lunpan19'],
	[enAttrType.eaMaxHp]     = StrConfig['lunpan20'],
}