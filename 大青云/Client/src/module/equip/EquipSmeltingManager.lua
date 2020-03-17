--[[
	装备熔炼管理器
	2015年10月11日, PM 04:30:47
	wangyanwei
]]
_G.EquipSmeltingManager = {};

--自动熔炼
function EquipSmeltingManager:OnAutoSmelting(item)
	if BagUtil:CheckBetterEquip(item:GetBagType(),item:GetPos()) then
		return;
	end
	local autoState = AutoBattleController:GetAutoHang();
	if not autoState then return end
	local itemCfg = t_equip[item:GetTid()];
	if not itemCfg then return end
	if itemCfg.pos < BagConsts.Equip_WuQi or itemCfg.pos > BagConsts.Equip_JieZhi2 then
		return
	end	
	if EquipModel:GetAutoSmelt() then
		EquipController:OnAotuSmelting(item);
	end
end

--10件侦听
function EquipSmeltingManager:RemindSmelting(itemID)
	if not FuncManager:GetFuncIsOpen(FuncConsts.Smelt) then
		return
	end
	local equipData = t_equip[itemID];
	if not equipData then return end
	if equipData.quality ~= BagConsts.Quality_White then
		return
	end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local bgEquipList = bagVO:GetEquipList();
	local whiteEquipNum = 0;
	for i , equip in pairs(bgEquipList) do
		local id = equip:GetTid();
		local equipCfg = equip:GetCfg();
		if equipCfg and equipCfg.quality == BagConsts.Quality_White then
			whiteEquipNum = whiteEquipNum + 1;
		end
	end
	if whiteEquipNum >= BagConsts.RemindSmeltConsts then
		UIItemGuide:Open(16);
	end
end
