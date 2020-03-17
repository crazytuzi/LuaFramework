--[[
帮派副本：地宫炼狱 常量类
2015年1月9日14:45:14
haohu
]]

_G.UnionHellConsts = {};

-- 地宫炼狱挑战结果界面倒计时时间
UnionHellConsts.ResultPanelTime = 10

-- 地宫炼狱层层数
local numStratum
function UnionHellConsts:GetNumStratum()
	if not numStratum then
		numStratum = _G.getTableLen( _G.t_guildHell )
	end
	return numStratum
end

-- 地宫炼狱层数文本对应关系
UnionHellConsts.StratumTxtMap = {
	[1]  = StrConfig['unionhell101'],
	[2]  = StrConfig['unionhell102'],
	[3]  = StrConfig['unionhell103'],
	[4]  = StrConfig['unionhell104'],
	[5]  = StrConfig['unionhell105'],
	[6]  = StrConfig['unionhell106'],
	[7]  = StrConfig['unionhell107'],
	[8]  = StrConfig['unionhell108'],
	[9]  = StrConfig['unionhell109'],
	[10] = StrConfig['unionhell110'],
	[11] = StrConfig['unionhell111'],
	[12] = StrConfig['unionhell112'],
	[13] = StrConfig['unionhell113'],
	[14] = StrConfig['unionhell114'],
	[15] = StrConfig['unionhell115'],
	[16] = StrConfig['unionhell116'],
	[17] = StrConfig['unionhell117'],
	[18] = StrConfig['unionhell118'],
	[19] = StrConfig['unionhell119'],
	[20] = StrConfig['unionhell120'],
	[21] = StrConfig['unionhell121'],
	[22] = StrConfig['unionhell122'],
	[23] = StrConfig['unionhell123'],
	[24] = StrConfig['unionhell124'],
	[25] = StrConfig['unionhell125'],
	[26] = StrConfig['unionhell126'],
	[27] = StrConfig['unionhell127'],
	[28] = StrConfig['unionhell128'],
	[29] = StrConfig['unionhell129'],
	[30] = StrConfig['unionhell130'],
	[31] = StrConfig['unionhell131'],
	[32] = StrConfig['unionhell132'],
	[33] = StrConfig['unionhell133'],
	[34] = StrConfig['unionhell134'],
	[35] = StrConfig['unionhell135'],
	[36] = StrConfig['unionhell136'],
	[37] = StrConfig['unionhell137'],
	[38] = StrConfig['unionhell138'],
	[39] = StrConfig['unionhell139'],
	[40] = StrConfig['unionhell140'],
	[41] = StrConfig['unionhell141'],
	[42] = StrConfig['unionhell142'],
	[43] = StrConfig['unionhell143'],
	[44] = StrConfig['unionhell144'],
	[45] = StrConfig['unionhell145'],
	[46] = StrConfig['unionhell146'],
	[47] = StrConfig['unionhell147'],
	[48] = StrConfig['unionhell148'],
	[49] = StrConfig['unionhell149'],
	[50] = StrConfig['unionhell150'],
}