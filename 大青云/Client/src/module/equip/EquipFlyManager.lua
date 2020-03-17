--[[
换装飞图标
lizhuangzhuang
2014年11月26日14:59:56
]]
_G.classlist['EquipFlyManager'] = 'EquipFlyManager'
_G.EquipFlyManager = {};
EquipFlyManager.objName = 'EquipFlyManager'
--物品交换时调用
function EquipFlyManager:OnEquipSwap(srcBag,srcPos,dstBag,dstPos)
	if srcBag ~= BagConsts.BagType_Bag then
		return;
	end
	if dstBag == BagConsts.BagType_Bag then
		return;
	end
	local bagVO = BagModel:GetBag(srcBag);
	if not bagVO then return; end
	local srcItem = bagVO:GetItemByPos(srcPos);
	if not srcItem then return; end
	if BagUtil:GetItemShowType(srcItem:GetTid()) ~= BagConsts.ShowType_Equip then
		return;
	end
	if dstBag == BagConsts.BagType_Role then
		self:FlyToRole(srcPos,dstPos);
	end
	if dstBag == BagConsts.BagType_Horse then
		self:FlyToHorse(srcPos,dstPos);
	end
	if dstBag == BagConsts.BagType_MingYu then
		self:FlyToMingYu(srcPos,dstPos);
	end
	if dstBag == BagConsts.BagType_Armor then
		self:FlyToArmor(srcPos,dstPos);
	end
	if dstBag == BagConsts.BagType_MagicWeapon then
		self:FlyToMagicWeapon(srcPos,dstPos);
	end
	if dstBag == BagConsts.BagType_LingQi then
		self:FlyToLingQi(srcPos,dstPos);
	end
end
_G.classlist['FlyVO'] = 'FlyVO'
--向人身上飞
function EquipFlyManager:FlyToRole(srcPos,dstPos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local srcItem = bagVO:GetItemByPos(srcPos);
	if not srcItem then return; end
	local srcUIItem = UIBag:GetItemAtPos(srcPos,true);
	local dstUIItem = UIRoleBasic:GetItemAtPos(dstPos);
	if not dstUIItem then return; end
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	flyVO.url = BagUtil:GetItemIcon(srcItem:GetTid());
	if srcUIItem then
		flyVO.startPos = UIManager:PosLtoG(srcUIItem,0,0);
	else
		local func = FuncManager:GetFunc(FuncConsts.Bag);
		if not func then return; end
		flyVO.startPos = func:GetBtnGlobalPos();
	end
	flyVO.endPos = UIManager:PosLtoG(dstUIItem,1,1);
	flyVO.time = 0.5;
	flyVO.onComplete = function()
		local effPos = UIManager:PosLtoG(dstUIItem,20,20);
		UIEffectManager:PlayEffect(ResUtil:GetBagOpenBombEffect(),effPos);
	end
	FlyManager:FlyIcon(flyVO);
end

--向坐骑飞
function EquipFlyManager:FlyToHorse(srcPos,dstPos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local srcItem = bagVO:GetItemByPos(srcPos);
	if not srcItem then return; end
	local srcUIItem = UIBag:GetItemAtPos(srcPos,true);
	local dstUIItem = UIMountBasic:GetItemAtPos(dstPos);
	if not dstUIItem then return; end
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	flyVO.url = BagUtil:GetItemIcon(srcItem:GetTid());
	if srcUIItem then
		flyVO.startPos = UIManager:PosLtoG(srcUIItem,0,0);
	else
		local func = FuncManager:GetFunc(FuncConsts.Bag);
		if not func then return; end
		flyVO.startPos = func:GetBtnGlobalPos();
	end
	flyVO.endPos = UIManager:PosLtoG(dstUIItem,1,1);
	flyVO.time = 0.5;
	flyVO.onComplete = function()
		local effPos = UIManager:PosLtoG(dstUIItem,20,20);
		UIEffectManager:PlayEffect(ResUtil:GetBagOpenBombEffect(),effPos);
	end
	FlyManager:FlyIcon(flyVO);
end

--向玉佩飞
function EquipFlyManager:FlyToMingYu(srcPos,dstPos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local srcItem = bagVO:GetItemByPos(srcPos);
	if not srcItem then return; end
	local srcUIItem = UIBag:GetItemAtPos(srcPos,true);
	local dstUIItem = UIMingYu:GetItemAtPos(dstPos);
	if not dstUIItem then return; end
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	flyVO.url = BagUtil:GetItemIcon(srcItem:GetTid());
	if srcUIItem then
		flyVO.startPos = UIManager:PosLtoG(srcUIItem,0,0);
	else
		local func = FuncManager:GetFunc(FuncConsts.Bag);
		if not func then return; end
		flyVO.startPos = func:GetBtnGlobalPos();
	end
	flyVO.endPos = UIManager:PosLtoG(dstUIItem,1,1);
	flyVO.time = 0.5;
	flyVO.onComplete = function()
		local effPos = UIManager:PosLtoG(dstUIItem,20,20);
		UIEffectManager:PlayEffect(ResUtil:GetBagOpenBombEffect(),effPos);
	end
	FlyManager:FlyIcon(flyVO);
end

--向宝甲飞
function EquipFlyManager:FlyToArmor(srcPos,dstPos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local srcItem = bagVO:GetItemByPos(srcPos);
	if not srcItem then return; end
	local srcUIItem = UIBag:GetItemAtPos(srcPos,true);
	local dstUIItem = UIArmor:GetItemAtPos(dstPos);
	if not dstUIItem then return; end
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	flyVO.url = BagUtil:GetItemIcon(srcItem:GetTid());
	if srcUIItem then
		flyVO.startPos = UIManager:PosLtoG(srcUIItem,0,0);
	else
		local func = FuncManager:GetFunc(FuncConsts.Bag);
		if not func then return; end
		flyVO.startPos = func:GetBtnGlobalPos();
	end
	flyVO.endPos = UIManager:PosLtoG(dstUIItem,1,1);
	flyVO.time = 0.5;
	flyVO.onComplete = function()
		local effPos = UIManager:PosLtoG(dstUIItem,20,20);
		UIEffectManager:PlayEffect(ResUtil:GetBagOpenBombEffect(),effPos);
	end
	FlyManager:FlyIcon(flyVO);
end

--向神兵飞
function EquipFlyManager:FlyToMagicWeapon(srcPos,dstPos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local srcItem = bagVO:GetItemByPos(srcPos);
	if not srcItem then return; end
	local srcUIItem = UIBag:GetItemAtPos(srcPos,true);
	local dstUIItem = UIMagicWeapon:GetItemAtPos(dstPos);
	if not dstUIItem then return; end
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	flyVO.url = BagUtil:GetItemIcon(srcItem:GetTid());
	if srcUIItem then
		flyVO.startPos = UIManager:PosLtoG(srcUIItem,0,0);
	else
		local func = FuncManager:GetFunc(FuncConsts.Bag);
		if not func then return; end
		flyVO.startPos = func:GetBtnGlobalPos();
	end
	flyVO.endPos = UIManager:PosLtoG(dstUIItem,1,1);
	flyVO.time = 0.5;
	flyVO.onComplete = function()
		local effPos = UIManager:PosLtoG(dstUIItem,20,20);
		UIEffectManager:PlayEffect(ResUtil:GetBagOpenBombEffect(),effPos);
	end
	FlyManager:FlyIcon(flyVO);
end

--向灵器飞
function EquipFlyManager:FlyToLingQi(srcPos,dstPos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local srcItem = bagVO:GetItemByPos(srcPos);
	if not srcItem then return; end
	local srcUIItem = UIBag:GetItemAtPos(srcPos,true);
	local dstUIItem = UILingQi:GetItemAtPos(dstPos);
	if not dstUIItem then return; end
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	flyVO.url = BagUtil:GetItemIcon(srcItem:GetTid());
	if srcUIItem then
		flyVO.startPos = UIManager:PosLtoG(srcUIItem,0,0);
	else
		local func = FuncManager:GetFunc(FuncConsts.Bag);
		if not func then return; end
		flyVO.startPos = func:GetBtnGlobalPos();
	end
	flyVO.endPos = UIManager:PosLtoG(dstUIItem,1,1);
	flyVO.time = 0.5;
	flyVO.onComplete = function()
		local effPos = UIManager:PosLtoG(dstUIItem,20,20);
		UIEffectManager:PlayEffect(ResUtil:GetBagOpenBombEffect(),effPos);
	end
	FlyManager:FlyIcon(flyVO);
end
