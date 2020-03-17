--[[
背包常量
lizhuangzhuang
2014年7月31日22:05:08
]]

_G.BagConsts = {};

--背包定义
BagConsts.BagType_None = -1;  --不再任何背包中,目前只有任一界面显示一个图标的时候使用
BagConsts.BagType_Bag = 0;  --背包
BagConsts.BagType_Role = 1; --身上装备栏
BagConsts.BagType_Storage = 2; --仓库
BagConsts.BagType_Horse = 3;
BagConsts.BagType_RoleItem = 4;--人身上道具
BagConsts.BagType_LingShou = 5;--灵兽装备
BagConsts.BagType_LingShouHorse = 6;--灵兽坐骑装备
-- BagConsts.BagType_LingZhenZhenYan = 7;--灵阵阵眼
BagConsts.BagType_MingYu = 8;--玉佩
BagConsts.BagType_Armor = 9;--宝甲
BagConsts.BagType_MagicWeapon = 10;--神兵
BagConsts.BagType_LingQi = 11;--灵器 法宝
BagConsts.BagType_RELIC = 12 --圣物
BagConsts.BagType_Tianshen = 13 --天神卡背包
BagConsts.BagType_QiZhan = 108;--骑战拓展 (废弃)
BagConsts.BagType_TianshenUI = 1008 --用于天神界面拖拽
-- BagConsts.BagType_ShenLing = 109;--神灵拓展(废弃)

--绑定状态(显示状态,不同于服务器发过来的状态)
BagConsts.Bind_None = -1;--无,不显示
BagConsts.Bind_GetBind = 0;--获取绑定
BagConsts.Bind_UseUnBind = 1;--使用后不绑定
BagConsts.Bind_UseBind = 2;--使用后绑定
BagConsts.Bind_Bind = 3;--已绑定

--显示分类
BagConsts.ShowType_All = 1;--所有
BagConsts.ShowType_Equip = 2;--装备
BagConsts.ShowType_Consum = 3;--消耗品
BagConsts.ShowType_Task = 4;--任务
BagConsts.ShowType_Other = 5;--其他

--物品品质
BagConsts.Quality_White  = 0;
BagConsts.Quality_Blue   = 1;
BagConsts.Quality_Purple = 2;
BagConsts.Quality_Orange = 3;
BagConsts.Quality_Red	 = 4;
BagConsts.Quality_Green1 = 5;
BagConsts.Quality_Green2 = 6;
BagConsts.Quality_Green3 = 7;

--物品子类
BagConsts.SubT_Recover = 1;--恢复药
BagConsts.SubT_YaoDan = 11;--妖丹
BagConsts.SubT_Wing = 13;--翅膀
BagConsts.SubT_EquipGroup = 14;--套装道具
BagConsts.SubT_TeshuLijinfu = 15;--特殊绑元符
BagConsts.SubT_Box = 16;--宝箱
BagConsts.SubT_XueChi = 20;--血池
BagConsts.SubT_Hallows = 23;--圣器宝石
BagConsts.SubT_Ring = 21;--戒指
BagConsts.SubT_Relic = 31 --圣物
BagConsts.SubT_Tianshenka = 32 --天神卡
BagConsts.SubT_TianshenJY = 33 --天神经验
BagConsts.SubT_FabaoBook = 26;--法宝技能书
BagConsts.SubT_EquipGem = 5;--装备宝石


-- 获取装备品质名字
function BagConsts:GetEquipProduct(num)
	if num == self.Quality_White then 
		return StrConfig["bagProduct1"];
	end
	if num == self.Quality_Blue then 
		return StrConfig["bagProduct2"];
	end
	if num == self.Quality_Purple then 
		return StrConfig["bagProduct3"];
	end
	if num == self.Quality_Orange then 
		return StrConfig["bagProduct4"];
	end
	if num == self.Quality_Red then 
		return StrConfig["bagProduct5"];
	end
	if num == self.Quality_Green1 then
		return StrConfig["bagProduct6"];
	end
	if num == self.Quality_Green2 then 
		return StrConfig["bagProduct7"];
	end
	if num == self.Quality_Green3 then 
		return StrConfig["bagProduct8"];
	end
	return "";
end

--背包默认容量
function BagConsts:GetBagDefaultSize(type)
	if type == BagConsts.BagType_Role then
		return 11;
	elseif type == BagConsts.BagType_Bag then
		return t_consts[1].val1;
	elseif type == BagConsts.BagType_Storage then
		return t_consts[1].val2;
	elseif type == BagConsts.BagType_Horse then
		return 4;
	elseif type == BagConsts.BagType_RoleItem then
		return 1;
	elseif type == BagConsts.BagType_RELIC then
		return 3
	elseif type == BagConsts.BagType_Tianshen then
		return 200
	elseif type == BagConsts.BagType_LingShou then
		return 4;
	elseif type == BagConsts.BagType_LingShouHorse then
		return 4;
	elseif type == BagConsts.BagType_QiZhan then
		return 9;
	elseif type == BagConsts.BagType_MingYu then
		return 4;
	elseif type == BagConsts.BagType_Armor then
		return 4;
	elseif type == BagConsts.BagType_MagicWeapon then
		return 4;
	elseif type == BagConsts.BagType_LingQi then
		return 4;
	end
	return;
end

--背包总容量
function BagConsts:GetBagTotalSize(type)
	if type == BagConsts.BagType_Role then
		return 11;
	end
	if type == BagConsts.BagType_Horse then
		return 4;
	end
	if type == BagConsts.BagType_RELIC then
		return 3
	end
	if type == BagConsts.BagType_Tianshen then
		return 200
	end
	if type == BagConsts.BagType_RoleItem then
		return 1;
	end
	if type == BagConsts.BagType_LingShou then
		return 4;
	end
	if type == BagConsts.BagType_LingShouHorse then
		return 4;
	end
	-- if type == BagConsts.BagType_LingZhenZhenYan then
	-- 	return 9;
	-- end
	if type == BagConsts.BagType_QiZhan then
		return 9;
	end
	-- if type == BagConsts.BagType_ShenLing then
	-- 	return 9;
	-- end
	if type == BagConsts.BagType_MingYu then
		return 4;
	end
	if type == BagConsts.BagType_Armor then
		return 4;
	end
	if type == BagConsts.BagType_MagicWeapon then
		return 4;
	end
	if type == BagConsts.BagType_LingQi then
		return 4;
	end

	local defaultSize = self:GetBagDefaultSize(type);
	local cfg = nil;
	if type == BagConsts.BagType_Bag then
		cfg = t_packetcost;
	elseif type == BagConsts.BagType_Storage then
		cfg = t_storagecost;
	end
	if not cfg then return defaultSize; end
	local openNum = 0;
	for id,v in ipairs(cfg) do
		if id > openNum then
			openNum = id;
		end
	end
	return defaultSize + openNum;
end

--用时间开启的格子上限
function BagConsts:GetBagTimeSize(type)
	local defaultSize = self:GetBagDefaultSize(type);
	local cfg = nil;
	if type == BagConsts.BagType_Bag then
		cfg = t_packetcost;
	elseif type == BagConsts.BagType_Storage then
		cfg = t_storagecost;
	end
	if not cfg then return 0; end
	local num = 0;
	for id,v in ipairs(cfg) do
		if id>num and v.autoTime>0 then
			num = id;
		end
	end
	return defaultSize + num;
end

--菜单操作
BagConsts.Oper_Store = 1;--存入
BagConsts.Oper_UnStore = 2;--取出
BagConsts.Oper_Use = 3;--使用
BagConsts.Oper_BatchUse = 4;--批量使用
BagConsts.Oper_Split = 5;--拆分
BagConsts.Oper_Equip = 6;--装备
BagConsts.Oper_UnEquip = 7;--取下装备
BagConsts.Oper_Compound = 8;--合成
BagConsts.Oper_Show = 9;--展示
BagConsts.Oper_Destroy = 10;--摧毁
BagConsts.Oper_Sell = 11;--出售
BagConsts.Oper_EquipWing = 12;--装备翅膀
BagConsts.Oper_EquipRelic = 13--装备圣物
BagConsts.Oper_RelicUp = 14 --圣物升级
BagConsts.Oper_CardCom = 15 --天神卡合成
--所有操作
BagConsts.AllOper = {BagConsts.Oper_Store,BagConsts.Oper_UnStore,BagConsts.Oper_Use,BagConsts.Oper_BatchUse,BagConsts.Oper_Split,
						BagConsts.Oper_Equip,BagConsts.Oper_UnEquip,BagConsts.Oper_CardCom,
						BagConsts.Oper_EquipWing,BagConsts.Oper_EquipRelic,BagConsts.Oper_RelicUp,
						BagConsts.Oper_Compound,BagConsts.Oper_Show,BagConsts.Oper_Destroy,BagConsts.Oper_Sell};


--获取操作的名字
function BagConsts:GetOperName(oper)
	if oper == BagConsts.Oper_Store then
		return StrConfig["bag11"];
	elseif oper == BagConsts.Oper_UnStore then
		return StrConfig["bag12"];
	elseif oper == BagConsts.Oper_Use then
		return StrConfig["bag13"];
	elseif oper == BagConsts.Oper_BatchUse then
		return StrConfig["bag1"];
	elseif oper == BagConsts.Oper_Split then
		return StrConfig["bag14"];
	elseif oper == BagConsts.Oper_Equip then
		return StrConfig["bag15"];
	elseif oper == BagConsts.Oper_UnEquip then
		return StrConfig["bag16"];
	elseif oper == BagConsts.Oper_Compound then
		return StrConfig["bag17"];
	elseif oper == BagConsts.Oper_Show then
		return StrConfig["bag18"];
	elseif oper == BagConsts.Oper_Destroy then
		return StrConfig["bag19"];
	elseif oper == BagConsts.Oper_Sell then
		return StrConfig["bag20"];
	elseif oper == BagConsts.Oper_EquipWing then
		return StrConfig["bag15"];
	elseif oper == BagConsts.Oper_EquipRelic then
		return StrConfig["bag64"];
	elseif oper == BagConsts.Oper_RelicUp then
		return StrConfig["bag65"];
	elseif oper == BagConsts.Oper_CardCom then
		return StrConfig['bag66']
	end
end

--装备类型常量
BagConsts.Equip_WuQi = 0;--武器
BagConsts.Equip_HuJian = 1;--护肩
BagConsts.Equip_YiFu = 2;--衣服
BagConsts.Equip_Toukui = 3;--头盔  --changer:hoxudong
BagConsts.Equip_KuZi = 4;--裤子
BagConsts.Equip_XieZi = 5;--鞋子
BagConsts.Equip_HuShou = 6;--护手
BagConsts.Equip_XiangLian = 7;--项链
BagConsts.Equip_ShiPin = 8;--饰品
BagConsts.Equip_JieZhi1 = 9;--戒指1
BagConsts.Equip_JieZhi2 = 10;--戒指2
BagConsts.Equip_ShiZhuang = 11;--时装
--坐骑装备
BagConsts.Equip_H_AnJu = 20;
BagConsts.Equip_H_JiangSheng = 21;
BagConsts.Equip_H_TouShi = 22;
BagConsts.Equip_H_DengJu = 23;
--灵兽装备
BagConsts.Equip_L_XiangQuan = 30;
BagConsts.Equip_L_KaiJia = 31;
BagConsts.Equip_L_HuWan = 32;
BagConsts.Equip_L_TouShi = 33;
--灵兽坐骑装备
BagConsts.Equip_LH_ZhuangJiao = 40;
BagConsts.Equip_LH_TieTi = 41;
BagConsts.Equip_LH_MaBian = 42;
BagConsts.Equip_LH_XiongJia = 43;
--灵阵阵眼
BagConsts.Equip_LZ_ZhenYan0 = 50000;
BagConsts.Equip_LZ_ZhenYan1 = 50001;
BagConsts.Equip_LZ_ZhenYan2 = 50002;
BagConsts.Equip_LZ_ZhenYan3 = 50003;
BagConsts.Equip_LZ_ZhenYan4 = 50004;
BagConsts.Equip_LZ_ZhenYan5 = 50005;
BagConsts.Equip_LZ_ZhenYan6 = 50006;
BagConsts.Equip_LZ_ZhenYan7 = 50007;
BagConsts.Equip_LZ_ZhenYan8 = 50008;
--灵阵阵眼预留10个，下一个装备从80开始吧
--骑战阵眼 80-89
BagConsts.Equip_QZ_ZhenYan0 = 80;
BagConsts.Equip_QZ_ZhenYan1 = 81;
BagConsts.Equip_QZ_ZhenYan2 = 82;
BagConsts.Equip_QZ_ZhenYan3 = 83;
BagConsts.Equip_QZ_ZhenYan4 = 84;
BagConsts.Equip_QZ_ZhenYan5 = 85;
BagConsts.Equip_QZ_ZhenYan6 = 86;
BagConsts.Equip_QZ_ZhenYan7 = 87;
BagConsts.Equip_QZ_ZhenYan8 = 88;
--神灵阵眼 90-109
BagConsts.Equip_SL_ZhenYan0 = 90;
BagConsts.Equip_SL_ZhenYan1 = 91;
BagConsts.Equip_SL_ZhenYan2 = 92;
BagConsts.Equip_SL_ZhenYan3 = 93;
BagConsts.Equip_SL_ZhenYan4 = 94;
BagConsts.Equip_SL_ZhenYan5 = 95;
BagConsts.Equip_SL_ZhenYan6 = 96;
BagConsts.Equip_SL_ZhenYan7 = 97;
BagConsts.Equip_SL_ZhenYan8 = 98;
--玉佩
BagConsts.Equip_MY_0 = 55;
BagConsts.Equip_MY_1 = 56;
BagConsts.Equip_MY_2 = 57;
BagConsts.Equip_MY_3 = 58;
--神兵
BagConsts.Equip_SB_0 = 60;
BagConsts.Equip_SB_1 = 61;
BagConsts.Equip_SB_2 = 62;
BagConsts.Equip_SB_3 = 63;
--宝甲
BagConsts.Equip_BJ_0 = 65;
BagConsts.Equip_BJ_1 = 66;
BagConsts.Equip_BJ_2 = 67;
BagConsts.Equip_BJ_3 = 68;
--法宝 灵器
BagConsts.Equip_LQ_0 = 70;
BagConsts.Equip_LQ_1 = 71;
BagConsts.Equip_LQ_2 = 72;
BagConsts.Equip_LQ_3 = 73;
--神兵兵魂 150-169
BagConsts.Equip_SB_Hun0 = 150;
BagConsts.Equip_SB_Hun1 = 151;
BagConsts.Equip_SB_Hun2 = 152;
BagConsts.Equip_SB_Hun3 = 153;
BagConsts.Equip_SB_Hun4 = 154;
BagConsts.Equip_SB_Hun5 = 155;
BagConsts.Equip_SB_Hun6 = 156;
BagConsts.Equip_SB_Hun7 = 157;
BagConsts.Equip_SB_Hun8 = 158;
--圣物
BagConsts.Equip_Relic_0 = 201
BagConsts.Equip_Relic_1 = 202
BagConsts.Equip_Relic_2 = 203
--物品拖拽类型
BagConsts.Drag_Item = 1000;
BagConsts.Drag_Item_Wing = 1001;
BagConsts.Drag_E_WuQi = 2000;
BagConsts.Drag_E_HuJian = 2001;
BagConsts.Drag_E_YiFu = 2002;
BagConsts.Drag_E_YaoDai = 2003;
BagConsts.Drag_E_KuZi = 2004;
BagConsts.Drag_E_XieZi = 2005;
BagConsts.Drag_E_HuShou = 2006;
BagConsts.Drag_E_XiangLian = 2007;
BagConsts.Drag_E_ShiPin = 2008;
BagConsts.Drag_E_JieZhi1 = 2009;
BagConsts.Drag_E_JieZhi2 = 2010;
BagConsts.Drag_E_ShiZhuang = 2011;
BagConsts.Drag_Item_Shengqi = 2012
BagConsts.Drag_Item_Tianshen = 2013
BagConsts.Drag_Tianshen = 2014
--坐骑
BagConsts.Drag_E_H_AnJu = 2020;
BagConsts.Drag_E_H_JiangSheng = 2021;
BagConsts.Drag_E_H_TouShi = 2022;
BagConsts.Drag_E_H_DengJu = 2023;
--灵兽
BagConsts.Drag_E_L_XiangQuan = 2030;
BagConsts.Drag_E_L_KaiJia = 2031;
BagConsts.Drag_E_L_HuWan = 2032;
BagConsts.Drag_E_L_TouShi = 2033;
--灵兽坐骑
BagConsts.Drag_E_LH_ZhuangJiao = 2040;
BagConsts.Drag_E_LH_TieTi = 2041;
BagConsts.Drag_E_LH_MaBian = 2042;
BagConsts.Drag_E_LH_XiongJia = 2043;
--灵阵阵眼
BagConsts.Drag_E_LZ_ZhenYan0 = 2050;
BagConsts.Drag_E_LZ_ZhenYan1 = 2051;
BagConsts.Drag_E_LZ_ZhenYan2 = 2052;
BagConsts.Drag_E_LZ_ZhenYan3 = 2053;
BagConsts.Drag_E_LZ_ZhenYan4 = 2054;
BagConsts.Drag_E_LZ_ZhenYan5 = 2055;
BagConsts.Drag_E_LZ_ZhenYan6 = 2056;
BagConsts.Drag_E_LZ_ZhenYan7 = 2057;
BagConsts.Drag_E_LZ_ZhenYan8 = 2058;
--灵阵阵眼预留20个，下一个从2070开始吧
----骑战阵眼 70-89
BagConsts.Drag_E_QZ_ZhenYan0 = 2070;
BagConsts.Drag_E_QZ_ZhenYan1 = 2071;
BagConsts.Drag_E_QZ_ZhenYan2 = 2072;
BagConsts.Drag_E_QZ_ZhenYan3 = 2073;
BagConsts.Drag_E_QZ_ZhenYan4 = 2074;
BagConsts.Drag_E_QZ_ZhenYan5 = 2075;
BagConsts.Drag_E_QZ_ZhenYan6 = 2076;
BagConsts.Drag_E_QZ_ZhenYan7 = 2077;
BagConsts.Drag_E_QZ_ZhenYan8 = 2078;
---神灵阵眼 90-109
BagConsts.Drag_E_SL_ZhenYan0 = 2090;
BagConsts.Drag_E_SL_ZhenYan1 = 2091;
BagConsts.Drag_E_SL_ZhenYan2 = 2092;
BagConsts.Drag_E_SL_ZhenYan3 = 2093;
BagConsts.Drag_E_SL_ZhenYan4 = 2094;
BagConsts.Drag_E_SL_ZhenYan5 = 2095;
BagConsts.Drag_E_SL_ZhenYan6 = 2096;
BagConsts.Drag_E_SL_ZhenYan7 = 2097;
BagConsts.Drag_E_SL_ZhenYan8 = 2098;
--灵兽战印
BagConsts.Drag_S_Item = 3000;
BagConsts.Drag_Wuxing_Item = 4000;
--所有拖拽类型
BagConsts.AllDragType = {
				BagConsts.Drag_Item,BagConsts.Drag_Item_Wing,BagConsts.Drag_Item_Shengqi,
				BagConsts.Drag_E_WuQi,BagConsts.Drag_E_HuJian,BagConsts.Drag_E_YiFu,BagConsts.Drag_E_YaoDai,BagConsts.Drag_E_KuZi,BagConsts.Drag_E_XieZi,
				BagConsts.Drag_E_HuShou,BagConsts.Drag_E_XiangLian,BagConsts.Drag_E_ShiPin,BagConsts.Drag_E_JieZhi1,
				BagConsts.Drag_E_JieZhi2,BagConsts.Drag_E_ShiZhuang,
				BagConsts.Drag_E_H_AnJu,BagConsts.Drag_E_H_JiangSheng,BagConsts.Drag_E_H_TouShi,BagConsts.Drag_E_H_DengJu,
				BagConsts.Drag_E_L_XiangQuan,BagConsts.Drag_E_L_KaiJia,BagConsts.Drag_E_L_HuWan,BagConsts.Drag_E_L_TouShi,
				BagConsts.Drag_E_LH_ZhuangJiao,BagConsts.Drag_E_LH_TieTi,BagConsts.Drag_E_LH_MaBian,BagConsts.Drag_E_LH_XiongJia,
				BagConsts.Drag_E_LZ_ZhenYan0,BagConsts.Drag_E_LZ_ZhenYan1,BagConsts.Drag_E_LZ_ZhenYan2,BagConsts.Drag_E_LZ_ZhenYan3,BagConsts.Drag_E_LZ_ZhenYan4,
				BagConsts.Drag_E_LZ_ZhenYan5,BagConsts.Drag_E_LZ_ZhenYan6,BagConsts.Drag_E_LZ_ZhenYan7,BagConsts.Drag_E_LZ_ZhenYan8,
				BagConsts.Drag_E_QZ_ZhenYan0,BagConsts.Drag_E_QZ_ZhenYan1,BagConsts.Drag_E_QZ_ZhenYan2,BagConsts.Drag_E_QZ_ZhenYan3,BagConsts.Drag_E_QZ_ZhenYan4,
				BagConsts.Drag_E_QZ_ZhenYan5,BagConsts.Drag_E_QZ_ZhenYan6,BagConsts.Drag_E_QZ_ZhenYan7,BagConsts.Drag_E_QZ_ZhenYan8,
				BagConsts.Drag_E_SL_ZhenYan0,BagConsts.Drag_E_SL_ZhenYan1,BagConsts.Drag_E_SL_ZhenYan2,BagConsts.Drag_E_SL_ZhenYan3,BagConsts.Drag_E_SL_ZhenYan4,
				BagConsts.Drag_E_SL_ZhenYan5,BagConsts.Drag_E_SL_ZhenYan6,BagConsts.Drag_E_SL_ZhenYan7,BagConsts.Drag_E_SL_ZhenYan8};

--获取装备位名字
function BagConsts:GetEquipName(type)
	if type == BagConsts.Equip_WuQi then
		return StrConfig['commonEquipName1'];
	elseif type == BagConsts.Equip_HuJian then
		return StrConfig['commonEquipName2'];
	elseif type == BagConsts.Equip_YiFu then
		return StrConfig['commonEquipName3'];
	elseif type == BagConsts.Equip_Toukui then
		return StrConfig['commonEquipName4'];
	elseif type == BagConsts.Equip_KuZi then
		return StrConfig['commonEquipName5'];
	elseif type == BagConsts.Equip_XieZi then
		return StrConfig['commonEquipName6'];
	elseif type == BagConsts.Equip_HuShou then
		return StrConfig['commonEquipName7'];
	elseif type == BagConsts.Equip_XiangLian then
		return StrConfig['commonEquipName8'];
	elseif type == BagConsts.Equip_ShiPin then
		return StrConfig['commonEquipName9'];
	elseif type == BagConsts.Equip_JieZhi1 then
		return StrConfig['commonEquipName10'];
	elseif type == BagConsts.Equip_JieZhi2 then
		return StrConfig['commonEquipName11'];
	elseif type == BagConsts.Equip_ShiZhuang then
		return StrConfig['commonEquipName12'];
	elseif type == BagConsts.Equip_H_AnJu then
		return StrConfig['commonEquipName21'];
	elseif type == BagConsts.Equip_H_JiangSheng then
		return StrConfig['commonEquipName22'];
	elseif type == BagConsts.Equip_H_TouShi then
		return StrConfig['commonEquipName23'];
	elseif type == BagConsts.Equip_H_DengJu then
		return StrConfig['commonEquipName24'];
	elseif type == BagConsts.Equip_L_XiangQuan then
		return StrConfig['commonEquipName31'];
	elseif type == BagConsts.Equip_L_KaiJia then
		return StrConfig['commonEquipName32'];
	elseif type == BagConsts.Equip_L_HuWan then
		return StrConfig['commonEquipName33'];
	elseif type == BagConsts.Equip_L_TouShi then
		return StrConfig['commonEquipName34'];
	elseif type == BagConsts.Equip_LH_ZhuangJiao then
		return StrConfig['commonEquipName41'];
	elseif type == BagConsts.Equip_LH_TieTi then
		return StrConfig['commonEquipName42'];
	elseif type == BagConsts.Equip_LH_MaBian then
		return StrConfig['commonEquipName43'];
	elseif type == BagConsts.Equip_LH_XiongJia then
		return StrConfig['commonEquipName44'];
	elseif type == BagConsts.Equip_LZ_ZhenYan0 then
		return StrConfig['commonEquipName50'];
	elseif type == BagConsts.Equip_LZ_ZhenYan1 then
		return StrConfig['commonEquipName51'];
	elseif type == BagConsts.Equip_LZ_ZhenYan2 then
		return StrConfig['commonEquipName52'];
	elseif type == BagConsts.Equip_LZ_ZhenYan3 then
		return StrConfig['commonEquipName53'];
	elseif type == BagConsts.Equip_LZ_ZhenYan4 then
		return StrConfig['commonEquipName54'];
	elseif type == BagConsts.Equip_LZ_ZhenYan5 then
		return StrConfig['commonEquipName55'];
	elseif type == BagConsts.Equip_LZ_ZhenYan6 then
		return StrConfig['commonEquipName56'];
	elseif type == BagConsts.Equip_LZ_ZhenYan7 then
		return StrConfig['commonEquipName57'];
	elseif type == BagConsts.Equip_LZ_ZhenYan8 then
		return StrConfig['commonEquipName58'];		
	elseif type == BagConsts.Equip_QZ_ZhenYan0 then
		return StrConfig['commonEquipName60'];
	elseif type == BagConsts.Equip_QZ_ZhenYan1 then
		return StrConfig['commonEquipName61'];
	elseif type == BagConsts.Equip_QZ_ZhenYan2 then
		return StrConfig['commonEquipName62'];
	elseif type == BagConsts.Equip_QZ_ZhenYan3 then
		return StrConfig['commonEquipName63'];
	elseif type == BagConsts.Equip_QZ_ZhenYan4 then
		return StrConfig['commonEquipName64'];
	elseif type == BagConsts.Equip_QZ_ZhenYan5 then
		return StrConfig['commonEquipName65'];
	elseif type == BagConsts.Equip_QZ_ZhenYan6 then
		return StrConfig['commonEquipName66'];
	elseif type == BagConsts.Equip_QZ_ZhenYan7 then
		return StrConfig['commonEquipName67'];
	elseif type == BagConsts.Equip_QZ_ZhenYan8 then
		return StrConfig['commonEquipName68'];
	elseif type == BagConsts.Equip_SL_ZhenYan0 then
		return StrConfig['commonEquipName70'];
	elseif type == BagConsts.Equip_SL_ZhenYan1 then
		return StrConfig['commonEquipName71'];
	elseif type == BagConsts.Equip_SL_ZhenYan2 then
		return StrConfig['commonEquipName72'];
	elseif type == BagConsts.Equip_SL_ZhenYan3 then
		return StrConfig['commonEquipName73'];
	elseif type == BagConsts.Equip_SL_ZhenYan4 then
		return StrConfig['commonEquipName74'];
	elseif type == BagConsts.Equip_SL_ZhenYan5 then
		return StrConfig['commonEquipName75'];
	elseif type == BagConsts.Equip_SL_ZhenYan6 then
		return StrConfig['commonEquipName76'];
	elseif type == BagConsts.Equip_SL_ZhenYan7 then
		return StrConfig['commonEquipName77'];
	elseif type == BagConsts.Equip_SL_ZhenYan8 then
		return StrConfig['commonEquipName78'];
	elseif type == BagConsts.Equip_SB_Hun0 then
		return StrConfig['commonEquipName109'];
	elseif type == BagConsts.Equip_SB_Hun1 then
		return StrConfig['commonEquipName110'];
	elseif type == BagConsts.Equip_SB_Hun2 then
		return StrConfig['commonEquipName111'];
	elseif type == BagConsts.Equip_SB_Hun3 then
		return StrConfig['commonEquipName112'];
	elseif type == BagConsts.Equip_SB_Hun4 then
		return StrConfig['commonEquipName113'];
	elseif type == BagConsts.Equip_SB_Hun5 then
		return StrConfig['commonEquipName114'];
	elseif type == BagConsts.Equip_SB_Hun6 then
		return StrConfig['commonEquipName115'];
	elseif type == BagConsts.Equip_SB_Hun7 then
		return StrConfig['commonEquipName116'];
	elseif type == BagConsts.Equip_SB_Hun8 then
		return StrConfig['commonEquipName117'];
	elseif type == BagConsts.Equip_MY_0 then
		return StrConfig['commonEquipName200'];
	elseif type == BagConsts.Equip_MY_1 then
		return StrConfig['commonEquipName201'];
	elseif type == BagConsts.Equip_MY_2 then
		return StrConfig['commonEquipName202'];
	elseif type == BagConsts.Equip_MY_3 then
		return StrConfig['commonEquipName203'];
	elseif type == BagConsts.Equip_SB_0 then
		return StrConfig['commonEquipName300'];
	elseif type == BagConsts.Equip_SB_1 then
		return StrConfig['commonEquipName301'];
	elseif type == BagConsts.Equip_SB_2 then
		return StrConfig['commonEquipName302'];
	elseif type == BagConsts.Equip_SB_3 then
		return StrConfig['commonEquipName303'];
	elseif type == BagConsts.Equip_BJ_0 then
		return StrConfig['commonEquipName400'];
	elseif type == BagConsts.Equip_BJ_1 then
		return StrConfig['commonEquipName401'];
	elseif type == BagConsts.Equip_BJ_2 then
		return StrConfig['commonEquipName402'];
	elseif type == BagConsts.Equip_BJ_3 then
		return StrConfig['commonEquipName403'];
	elseif type == BagConsts.Equip_LQ_0 then
		return StrConfig['commonEquipName500'];
	elseif type == BagConsts.Equip_LQ_1 then
		return StrConfig['commonEquipName501'];
	elseif type == BagConsts.Equip_LQ_2 then
		return StrConfig['commonEquipName502'];
	elseif type == BagConsts.Equip_LQ_3 then
		return StrConfig['commonEquipName503'];
	end

end

--根据格子位置获取坐骑装备类型
function BagConsts:GetHorseEquipNameByPos(pos)
	local type = 20 + pos;
	return self:GetEquipName(type);
end

--根据格子位置获取灵兽准备类型
function BagConsts:GetLingShouEquipNameByPos(pos)
	local type = 30 + pos;
	return self:GetEquipName(type);
end

--根据格子位置获取灵兽坐骑准备类型
function BagConsts:GetLingShouHorseEquipNameByPos(pos)
	local type = 40 + pos;
	return self:GetEquipName(type);
end

-- --根据格子位置获取灵阵阵眼准备类型
-- function BagConsts:GetLingZhenZhenYanEquipNameByPos(pos)
-- 	local type = 50 + pos;
-- 	return self:GetEquipName(type);
-- end

--根据格子位置获取骑战魔灵准备类型
function BagConsts:GetQiZhanZhenYanEquipNameByPos(pos)
	local type = 70 + pos;
	return self:GetEquipName(type);
end

--根据格子位置获取神兵兵魂准备类型
function BagConsts:GetShenBingHunEquipNameByPos(pos)
	local type = 150 + pos;
	return self:GetEquipName(type);
end

--根据格子位置获取玉佩装备类型
function BagConsts:GetMingYuEquipNameByPos(pos)
	local type = BagConsts.Equip_MY_0 + pos;
	return self:GetEquipName(type);
end

--根据格子位置获取宝甲装备类型
function BagConsts:GetArmorEquipNameByPos(pos)
	local type = BagConsts.Equip_BJ_0 + pos;
	return self:GetEquipName(type);
end

--根据格子位置获取玉佩装备类型
function BagConsts:GetMagicWeaponEquipNameByPos(pos)
	local type = BagConsts.Equip_SB_0 + pos;
	return self:GetEquipName(type);
end

--根据格子位置获取灵气 法宝装备类型
function BagConsts:GetLingQiEquipNameByPos(pos)
	local type = BagConsts.Equip_LQ_0 + pos;
	return self:GetEquipName(type);
end

--物品使用错误类型(客户端校验)
BagConsts.Error_Use = -1;--不可使用
BagConsts.Error_Sex = -2;--性别不符
BagConsts.Error_Prof = -3;--职业不符
BagConsts.Error_Level = -4;--等级不足
BagConsts.Error_HorseLevel = -5;--坐骑等级不足
BagConsts.Error_CD = -6;--物品CD中
-- BagConsts.Error_RealmLevel = -7;--境界等级不足
BagConsts.Error_Equip = -8;--装备不可穿戴
BagConsts.Error_LingShouLevel = -9;--灵兽等级不足
BagConsts.Error_HorseLingShouLevel = -10;--灵兽坐骑等级不足
-- BagConsts.Error_LingZhenLevel = -11;--灵阵等级不足
BagConsts.Error_QiZhanLevel = -12;--骑战等级不足
-- BagConsts.Error_ShenLingLevel = -13;--神灵等级不足
BagConsts.Error_MagicWeaponLevel = -14;--神兵等阶不足
BagConsts.Error_LingQiLevel = -15;--法宝等阶不足
BagConsts.Error_MingYuLevel = -16;--命玉等阶不足
BagConsts.Error_ArmorLevel = -17;--宝甲等阶不足
--物品错误提示
function BagConsts:GetErrorTips(type)
	if type == BagConsts.Error_Use then
		return StrConfig["bagerror1"];
	elseif type == BagConsts.Error_Sex then
		return StrConfig["bagerror2"];
	elseif type == BagConsts.Error_Prof then
		return StrConfig["bagerror3"];
	elseif type == BagConsts.Error_Level then
		return StrConfig["bagerror4"];
	elseif type == BagConsts.Error_HorseLevel then
		return StrConfig["bagerror5"];
	elseif type == BagConsts.Error_CD then
		return StrConfig["bagerror6"];
	-- elseif type == BagConsts.Error_RealmLevel then
	-- 	return StrConfig["bagerror7"];
	elseif type == BagConsts.Error_Equip then
		return StrConfig["bagerror8"];
	elseif type == BagConsts.Error_LingShouLevel then
		return StrConfig["bagerror9"]
	elseif type == BagConsts.Error_HorseLingShouLevel then
		return StrConfig["bagerror10"]
	-- elseif type == BagConsts.Error_LingZhenLevel then
	-- 	return StrConfig["bagerror11"]
	elseif type == BagConsts.Error_QiZhanLevel then
		return StrConfig["bagerror12"]
	-- elseif type == BagConsts.Error_ShenLingLevel then
	-- 	return StrConfig["bagerror13"]
	elseif type == BagConsts.Error_MagicWeaponLevel then
		return StrConfig["bagerror14"]
	elseif type == BagConsts.Error_LingQiLevel then
		return StrConfig["bagerror15"]
	elseif type == BagConsts.Error_MingYuLevel then
		return StrConfig["bagerror16"]
	elseif type == BagConsts.Error_ArmorLevel then
		return StrConfig["bagerror17"]
	end
	return "";
end

--获取绑定状态名
function BagConsts:GetBindName(bind)
	if bind == BagConsts.Bind_None then
		return StrConfig["bag100"];
	elseif bind == BagConsts.Bind_GetBind then
		return StrConfig["bag101"];
	elseif bind == BagConsts.Bind_UseUnBind then
		return StrConfig["bag102"];
	elseif bind == BagConsts.Bind_UseBind then
		return StrConfig["bag103"];
	elseif bind == BagConsts.Bind_Bind then
		return StrConfig["bag104"];
	end
	return StrConfig["bag100"];
end

--快速装备背包格子数量
BagConsts.Equip_Quick_Count = 5;

--白色大于几件后提示熔炼
BagConsts.RemindSmeltConsts = 10;