--[[
装备常量
lizhuangzhuang
2014年11月14日11:07:59
]]

_G.EquipConsts = {};

--可强化的装备类型
EquipConsts.EquipStrenType = {
	BagConsts.Equip_WuQi,BagConsts.Equip_HuJian,BagConsts.Equip_YiFu,BagConsts.Equip_Toukui,
	BagConsts.Equip_KuZi,BagConsts.Equip_XieZi,BagConsts.Equip_HuShou,BagConsts.Equip_XiangLian,
	BagConsts.Equip_ShiPin,BagConsts.Equip_JieZhi1,BagConsts.Equip_JieZhi2};

-- 强化套装数量
EquipConsts.StrenEquipNum = 11

--装备最大强化等级
EquipConsts.StrenMaxLvl = 24;
--强化星星的最大等级
EquipConsts.StrenMaxStar = 12;

--卓越孔的最大等级
EquipConsts.SuperHoleMaxLvl = 10;

--强化升星符ID
EquipConsts.itemLvlUpId = 140633080;
--极致升星符ID
EquipConsts.itemJZLvlUpId = 140633108;
--升星+15卷轴ID
EquipConsts.itemLvlUp15Id = 140633109;

--卓越属性库最大数量
function EquipConsts:SuperLibMaxNum()
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	return t_lvup[level].maxSuperLib;
end

--默认卓越孔数量
function EquipConsts:DefaultSuperNum(quality)
	if quality >= BagConsts.Quality_Purple then
		return "1-5";
	end
	return "";
end

--默认新卓越数量
function EquipConsts:DefaultNewSuperNum(quality)
	local cfg = t_zhuoyuenum[quality];
	if not cfg then
		return "";
	end
	if cfg.num > 0 then
		return cfg.num;
	end
	return "";
end

EquipConsts.QualityConsts = 
{
	[1] = BagConsts.Quality_White,
	[2] = BagConsts.Quality_Blue,
	[3] = BagConsts.Quality_Purple,
}

--开卓越孔道具
function EquipConsts:GetSuperHoleItem()
	if self.superHoleItem and self.superHoleItem>0 then
		return self.superHoleItem;
	end
	local t = split(t_consts[123].param,",");
	self.superHoleItem = toint(t[1]);
	self.superHoleItemNum = toint(t[2]);
	return self.superHoleItem;
end

--开卓越孔道具数量
function EquipConsts:GetSuperHoleItemNum()
	if self.superHoleItemNum and self.superHoleItemNum>0 then
		return self.superHoleItemNum;
	end
	local t = split(t_consts[123].param,",");
	self.superHoleItem = toint(t[1]);
	self.superHoleItemNum = toint(t[2]);
	return self.superHoleItemNum;
end