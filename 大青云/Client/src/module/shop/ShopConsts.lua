--[[
商店相关常量
hoahu
2014年11月4日10:32:06
]]

_G.ShopConsts = {};

--商店类型
ShopConsts.T_Consumable = 1;--随身商店
ShopConsts.T_BindMoney  = 2;--绑元商店
ShopConsts.T_Money      = 3;--元宝商店
ShopConsts.T_Honor      = 4;--荣誉商店
ShopConsts.T_LinZhi     = 5;--灵值商店
ShopConsts.T_Vplan      = 6;--V计划商店
ShopConsts.T_JiFen      = 7;--极限挑战积分商店
ShopConsts.T_Gongxun    = 8;--功勋商店
ShopConsts.T_Tehui      = 9;--特惠商店
ShopConsts.T_Exchange   = 10;--兑换商店
ShopConsts.T_XmasExchange   = 11;--圣诞兑换商店
ShopConsts.T_ChouJiang  = 12;--抽奖积分兑换商店
ShopConsts.T_InterSScene  = 13;--跨服商店
ShopConsts.T_DifficultyJiFen  = 14;--跨服商店
ShopConsts.T_Zhenxi  = 15;--珍稀商店
ShopConsts.T_Babel= 16; --积分商城
ShopConsts.T_Guild	 = 80
ShopConsts.T_Back = 999 --购回
--商店显示类型
ShopConsts.ST_Consumable = 1;--随身商店
ShopConsts.ST_BindMoney = 2;--绑元商店
ShopConsts.ST_Money = 3;-- 商城  推荐
ShopConsts.ST_Honor = 5;---荣誉商店
ShopConsts.ST_LinZhi = 6; -- 灵值商店
ShopConsts.ST_Vplan = 7; -- V计划商店
ShopConsts.ST_JiFen = 7;--极限挑战积分商店
ShopConsts.ST_Gongxun = 9; -- 功勋商店
ShopConsts.ST_Tehui = 10; -- 特惠商店
ShopConsts.ST_Exchange = 11; -- 兑换商店
ShopConsts.ST_XmasExchange = 12; -- 圣诞兑换商店
ShopConsts.ST_ChouJiang = 13; -- 抽奖积分兑换商店
ShopConsts.ST_InterSScene  = 14;--跨服商店
ShopConsts.ST_DifficultyJiFen  = 15;--跨服商店
ShopConsts.ST_Zhenxi  = 16;--珍稀商店
ShopConsts.ST_Guild	 = 17 --宗派商店
ShopConsts.ST_Babel= 18; --积分商城


------------------
-- 随身商店一页显示的物品数目
ShopConsts.NumIn1Page = 10;


------造成玩家不能购买的瓶颈原因
ShopConsts.ReasonBag = 1;
ShopConsts.ReasonDayLimit = 2;
ShopConsts.ReasonAfford = 3;
------造成玩家不能购买的原因与原因描述对应
ShopConsts.MaxBuyMap = {
	[ShopConsts.ReasonBag]      = StrConfig['shop202'],
	[ShopConsts.ReasonDayLimit] = StrConfig['shop203'],
	[ShopConsts.ReasonAfford]   = StrConfig['shop204']
}

--------商城显示item
ShopConsts.ShowItemlist = {	ShopConsts.ST_Tehui, -- 推荐商店
							ShopConsts.ST_Money, -- 绑元商店
							ShopConsts.ST_BindMoney, -- 绑元商店
						}


-- 购买确认面板：默认购买数策略定义
ShopConsts.Policy_MaxPile = 1 -- 最大叠加
ShopConsts.Policy_Single = 2 -- 单个购买