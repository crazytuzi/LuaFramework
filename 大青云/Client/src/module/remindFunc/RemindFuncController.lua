--[[
    Created by IntelliJ IDEA.
    功能开启提醒，显示在游戏右下角的
    User: Hongbin Yang
    Date: 2016/8/26
    Time: 15:06
   ]]

_G.RemindFuncController = setmetatable({}, { __index = IController });

RemindFuncController.name = "RemindFuncController";

RemindFuncController.remindList = {};

function RemindFuncController:ExecRemindFunc(id, ...)
	local rf = self.remindList[id];
	if not rf then return; end
	rf:SetArgs(...);
	rf:Execute();
end

function RemindFuncController:ExecRemindOnEnterGame()
	for k, v in pairs(self.remindList) do
		if v:IsCheckOnEnterGame() then
			v:Execute();
		end
	end
end

function RemindFuncController:ExecRemindOnFuncOpen(funcID)
	for k, v in pairs(self.remindList) do
		if v:GetFuncId() == funcID and v:IsCheckOnFuncOpen() then
			v:Execute();
		end
	end
end

function RemindFuncController:ExecRemindOnNewItemInBag(newItemID)
	for k, v in pairs(self.remindList) do
		if v:IsCheckOnNewItemInBag() then
			if v:CheckNewItem(newItemID) then
				v:DoExec();
			end
		end
	end
	self:RemoveFailPreshow(newItemID);
end

function RemindFuncController:RemoveFailPreshow(newItemID)
	newItemID = newItemID or 0;
	--检测下现在已经开启的是否都符合条件
	local showList = RemindFuncManager.showList;
	for k, v in pairs(showList) do
		local id = v;
		local base = self.remindList[id];
		--开启了，并且检查背包新物品，并且检测弹出失败 才执行
		if base:GetIsOpening() and
				base:IsCheckOnNewItemInBag() and
				base:CheckNewItem(newItemID) and
				not self.remindList[id]:ExecFunc() then
			RemindFuncManager:RemovePreshow(id);
		end
	end
end

function RemindFuncController:AutoRemoveFailPreshowById(id)
	local rf = self.remindList[id];
	if not rf then return; end
	for k, v in pairs(rf.checkNewItemList) do
		self:RemoveFailPreshow(v);
	end
end

function RemindFuncController:ForceToShow(id)
	RemindFuncManager:AddToShow(id);
end

function RemindFuncController:AddRemindFunc(id, remindFunc)
	self.remindList[id] = remindFunc;
end

function RemindFuncController:InitRemindFunc()
	for k, v in pairs(t_funcremind) do
		local rf = RemindFuncBase:new();
		rf.id = toint(v.id);
		rf:Init();
		self:AddRemindFunc(rf.id, rf);
	end
end

function RemindFuncController:OnEnterGame()
	self:InitRemindFunc();
	self:SetOnClickConfirmFunc();
	self:SetExecFunc();
	--执行上线检查提示
	self:ExecRemindOnEnterGame();
end

function RemindFuncController:SetOnClickConfirmFunc()
	self.remindList[RemindFuncConsts.RFC_SmithingResp]:SetOnClickConfirm(function(base) return self:OnClickConfirmSmithingResp(base); end);
	self.remindList[RemindFuncConsts.RFC_NewTianShenUsed]:SetOnClickConfirm(function(base) return self:OnClickConfirmNewTianShenUsed(base); end);
end

function RemindFuncController:OnClickConfirmSmithingResp(base)
	if not base:GetArgs() then return; end
	FuncManager:OpenFunc(base:GetFuncId(), false, base:GetArgs()[1], base:GetArgs()[2]);
end

function RemindFuncController:OnClickConfirmNewTianShenUsed(base)
	UITianshenBag:Show();
end

function RemindFuncController:SetExecFunc()
	self.remindList[RemindFuncConsts.RFC_SmithingUpStar]:SetExecFunc(function(base) return self:CheckSmithingUpStar(base); end);
	self.remindList[RemindFuncConsts.RFC_SmithingInlay]:SetExecFunc(function(base) return self:CheckSmithingInlay(base); end);
	self.remindList[RemindFuncConsts.RFC_SmithingWash]:SetExecFunc(function(base) return self:CheckSmithingWash(base); end);
	self.remindList[RemindFuncConsts.RFC_SmithingResp]:SetExecFunc(function(base) return self:CheckSmithingResp(base); end);
	self.remindList[RemindFuncConsts.RFC_SmithingDecomp]:SetExecFunc(function(base) return self:CheckSmithingDecomp(base); end);
	self.remindList[RemindFuncConsts.RFC_FuMoActivity]:SetExecFunc(function(base) return self:CheckFuMoActivity(base); end);
	self.remindList[RemindFuncConsts.RFC_FuMoLvUp]:SetExecFunc(function(base) return self:CheckFuMoLvUp(base); end);
	self.remindList[RemindFuncConsts.RFC_MountUpStar]:SetExecFunc(function(base) return self:CheckMountUpStar(base); end);
	self.remindList[RemindFuncConsts.RFC_XuanBing]:SetExecFunc(function(base) return self:CheckXuanBing(base); end);
	self.remindList[RemindFuncConsts.RFC_BaoJia]:SetExecFunc(function(base) return self:CheckBaoJia(base); end);
	self.remindList[RemindFuncConsts.RFC_MingYu]:SetExecFunc(function(base) return self:CheckMingYu(base); end);

	self.remindList[RemindFuncConsts.RFC_TianShenActivity]:SetExecFunc(function(base) return self:CheckTianShenActivity(base); end);
	self.remindList[RemindFuncConsts.RFC_TianShenLvUp]:SetExecFunc(function(base) return self:CheckTianShenLvUp(base); end);
	self.remindList[RemindFuncConsts.RFC_TianShenUpStar]:SetExecFunc(function() return self:CheckTianShenUpStar(); end);
	self.remindList[RemindFuncConsts.RFC_XingTuLv]:SetExecFunc(function(base) return self:CheckXingTuLv(base); end);

	self.remindList[RemindFuncConsts.RFC_SkillLvUp]:SetExecFunc(function(base) return self:CheckSkillLvUp(base); end);

	self.remindList[RemindFuncConsts.RFC_CaveBossOpen]:SetExecFunc(function(base) return self:CheckCaveBossOpen(base); end);
	self.remindList[RemindFuncConsts.RFC_DanYaoHeCheng]:SetExecFunc(function(base) return self:CheckDanYaoHeCheng(base); end);
	self.remindList[RemindFuncConsts.RFC_WaterDungeon]:SetExecFunc(function(base) return self:CheckWaterDungeon(base); end);
	self.remindList[RemindFuncConsts.RFC_WaterDungeon_Free]:SetExecFunc(function(base) return self:CheckWaterDungeonFree(base); end);

	self.remindList[RemindFuncConsts.RFC_NewTianShenUsed]:SetExecFunc(function(base) return self:CheckNewTianShenUsed(base); end);
	self.remindList[RemindFuncConsts.RFC_NewTianShenLvUp]:SetExecFunc(function(base) return self:CheckNewTianShenLvUp(base); end);
	self.remindList[RemindFuncConsts.RFC_NewTianShenUpStar]:SetExecFunc(function(base) return self:CheckNewTianShenUpStar(base); end);
end

function RemindFuncController:CheckSmithingUpStar(base)
	return EquipUtil:IsHaveEquipCanStarUpByCount(RemindFuncConditionUtil:GetPropToInt(base:GetId()));
end

function RemindFuncController:CheckSmithingInlay()
	return EquipUtil:IsHaveGemCanIn() or EquipUtil:IsHaveGemCanLvUp();
end

function RemindFuncController:CheckSmithingWash(base)
	if base:HasCondition() and not RemindFuncConditionUtil:IsItemEnoughByItemID(base:GetId()) then
		return false;
	end
	return EquipUtil:IsHaveEquipCanWash();
end

function RemindFuncController:CheckSmithingResp(base)
	local args = base:GetArgs()
	if not args then
		return false
	end
	return EquipUtil:HasEquipCanAccpetResp(base:GetArgs()[1], base:GetArgs()[2]);
end

function RemindFuncController:CheckSmithingDecomp()
	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
	if bag:GetFreeSize() <= 5 then
		return true;
	end
	return false;
end

function RemindFuncController:CheckFuMoActivity()
	local result, i = FumoUtil:isCanUpMap();
	if result and i == 1 then
		return true;
	end
	return false;
end

function RemindFuncController:CheckFuMoLvUp()
	local result, i = FumoUtil:isCanUpMap();
	if result and i == 2 then
		return true;
	end
	return false;
end

--坐骑是否够点一次进阶的
function RemindFuncController:CheckMountLvUp()
	return MountController:GetMountUpdate();
end

--坐骑能否直接升级一星
function RemindFuncController:CheckMountUpStar(base)
	if base:HasCondition() and not RemindFuncConditionUtil:IsItemEnoughByItemID(base:GetId()) then
		return false;
	end
	return MountUtil:CheckCanLvUpToNextStar();
end

function RemindFuncController:CheckXuanBing()
	return StoveController:IsCanProgress(StovePanelView.XUANBING);
end

function RemindFuncController:CheckBaoJia()
	return StoveController:IsCanProgress(StovePanelView.BAOJIA);
end

function RemindFuncController:CheckMingYu()
	return StoveController:IsCanProgress(StovePanelView.MINGYU);
end

function RemindFuncController:CheckTianShenActivity()
	return TianShenModel:GetTianshenActive();
end

function RemindFuncController:CheckTianShenLvUp(base)
	if base:HasCondition() and not RemindFuncConditionUtil:IsItemEnoughByItemID(base:GetId()) then
		return false;
	end
	return TianShenModel:GetTianshenUpdata();
end

function RemindFuncController:CheckTianShenUpStar()
	return TianShenModel:GetTianshenStarUpdata();
end

function RemindFuncController:CheckXingTuLv(base)
	if base:HasCondition() and not RemindFuncConditionUtil:IsPlayerInfoEnough(base:GetId()) then
		return false;
	end
	return XingtuModel:IsHaveCanLvUp();
end

function RemindFuncController:CheckSkillLvUp(base)
	return SkillFunc:CheckCanLvlUp();
end

function RemindFuncController:CheckCaveBossOpen()
	--已经在地宫中则不弹出
	if UnionDiGongModel:GetIsAtUnionActivity() then return false; end
	return UnionDiGongModel:HasCanFightBoss();
end

function RemindFuncController:CheckDanYaoHeCheng()
	return true;
end

function RemindFuncController:CheckWaterDungeon()
	return DungeonUtils:CheckWaterDungeonEnterLevel() and WaterDungeonModel:GetDayPayTime() > 0 and WaterDungeonModel:GetDayFreeTime() <= 0;
end
function RemindFuncController:CheckWaterDungeonFree()
	return DungeonUtils:CheckWaterDungeonEnterLevel() and WaterDungeonModel:GetDayFreeTime() > 0;
end

function RemindFuncController:CheckNewTianShenUsed(base)
	if not base:GetArgs() then return; end
	return NewTianshenUtil:IsBetterCard(base:GetArgs()[1])
end

function RemindFuncController:CheckNewTianShenLvUp()
	return NewTianshenUtil:IsHaveTianshenCanLvUpTwo();
end

function RemindFuncController:CheckNewTianShenUpStar()
	return NewTianshenUtil:IsHaveTianshenCanStarUpThree();
end