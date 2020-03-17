--[[
寄售行

]]

_G.ConsignmentConsts = {};

-- 寄售行出售时限  /小时
ConsignmentConsts.TimeLimit = {
	[1] = 12,
	[2] = 24,
	[3] = 36,
	[3] = 48,
}
-- 卖
ConsignmentConsts.ConsignmentSell = "ConsignmentSell";
-- 买
ConsignmentConsts.ConsignmentBuy  = "ConsignmentBuy";
-- 赚
ConsignmentConsts.ConsignmentEarn = "ConsignmentEarn"


--层级长度
ConsignmentConsts.layerOnelengh = 2; 
ConsignmentConsts.layerTwolengh = 4;
ConsignmentConsts.layerThreelengh = 4;
ConsignmentConsts.layerFangJulengh = 6;
ConsignmentConsts.layerShiPinlengh = 2;
ConsignmentConsts.layerDaoJulengh = 5;
ConsignmentConsts.layerFabaolengh = 5;
ConsignmentConsts.layerEquiplengh = 11;

-- 背包是否只执行点击
ConsignmentConsts.IsAtUpitemIng = false;

-- 上架时间选项
ConsignmentConsts.UpItemTimeLenght = 4; -- 12 24 48 72