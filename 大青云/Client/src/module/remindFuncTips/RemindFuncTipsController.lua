--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/10/5
    Time: 12:33
   ]]

_G.RemindFuncTipsController = setmetatable({}, { __index = IController });

RemindFuncTipsController.name = "RemindFuncTipsController";

RemindFuncTipsController.remindList = {};

function RemindFuncTipsController:ForceExecOnFuncOpen(funcId)
	for k, v in pairs(self.remindList) do
		if v:GetFuncId() == funcId and v:GetEnabled() then
--			self:ShowTip(v:GetId()) -- todo 屏蔽这个功能开启的时候的强制弹出
		end
	end
end

function RemindFuncTipsController:ExecRemindOnNewItemInBag(newItemID)
	for k, v in pairs(self.remindList) do
		self:ExecRemindFunc(v:GetId());
	end
end

function RemindFuncTipsController:ExecRemindFunc(id)
	local frame = self.remindList[id];
	if not frame then return; end
	frame:Execute();
end

function RemindFuncTipsController:AddRemindFunc(id, remindFunc)
	self.remindList[id] = remindFunc;
end

function RemindFuncTipsController:InitRemindFunc()
	for k, v in pairs(t_funcremindtips) do
		local frame = RemindFuncTipsFrame:new();
		frame.id = toint(v.id);
		frame:Init();
		self:AddRemindFunc(frame:GetId(), frame);
	end
end

function RemindFuncTipsController:OnEnterGame()
	self:InitRemindFunc();
	self:SetExecFunc();
end

function RemindFuncTipsController:ShowTip(id)
	if not self.remindList[id] then return; end
	RemindFuncTipsView:ShowTip(self.remindList[id]);
end

function RemindFuncTipsController:SetExecFunc()
	self.remindList[RemindFuncTipsConsts.RFTC_XiuWei]:SetExecFunc(function(base) return self:CheckXiuWei(base); end);
	self.remindList[RemindFuncTipsConsts.RFTC_Babel]:SetExecFunc(function(base) return self:CheckBabel(base); end);
	self.remindList[RemindFuncTipsConsts.RFTC_WorldBoss]:SetExecFunc(function(base) return self:CheckWorldBoss(base); end);
	self.remindList[RemindFuncTipsConsts.RFTC_Exp_Dungeon]:SetExecFunc(function(base) return self:CheckExpDungeon(base); end);
	self.remindList[RemindFuncTipsConsts.RFTC_Team_Exp]:SetExecFunc(function(base) return self:CheckTeamExp(base); end);
	self.remindList[RemindFuncTipsConsts.RFTC_DominateRoute]:SetExecFunc(function(base) return self:CheckDominateRoute(base); end);
	self.remindList[RemindFuncTipsConsts.RFTC_XianYuanCave]:SetExecFunc(function(base) return self:CheckXianYuanCave(base); end);
	self.remindList[RemindFuncTipsConsts.RFTC_Smithing_Collection]:SetExecFunc(function(base) return self:CheckSmithingCollection(base); end);
end

function RemindFuncTipsController:CheckXiuWei(base)
	if XiuweiPoolModel:GetXiuwei() >= 6000 then
		return true;
	end
	return false;
end

function RemindFuncTipsController:CheckBabel(base)--神装收集 废弃
	if not UIMainFunc:GetTopVisible() then return false; end
	local lv = MainPlayerModel.humanDetailInfo.eaLevel;
	if lv >= 95 and lv <= 145 then
		if BabelModel.babelData.num > 0 then
			if BabelModel:CheckGetEquipsOverSelfEquipsQuality() then
				return true;
			end
		end
	end
	return false;
end

function RemindFuncTipsController:CheckWorldBoss(base)--世界boss，废弃
	if not UIMainFunc:GetTopVisible() then return false; end
	--已经在地宫中则不弹出
	if UnionDiGongModel:HasCanFightBoss() then
		if UnionDiGongModel:GetIsAtUnionActivity() then return false; end
		return true;
	end
	if WorldBossUtils:IsHaveWorldBossCanAtt() then
		return true
	end
	if WorldBossUtils:IsHaveFieldBossCanAtt() then
		return true
	end
	return false;
end

function RemindFuncTipsController:CheckExpDungeon(base) --经验副本
	if not UIMainFunc:GetTopVisible() then return false; end
	local lv = MainPlayerModel.humanDetailInfo.eaLevel;
	if (lv >= 75 and lv <= 83) or (lv >= 85 and lv <= 93) then
		local timeAvailable = WaterDungeonModel:GetDayFreeTime()
		if timeAvailable > 0 then
			return true;
		end
	end
	return false
end

function RemindFuncTipsController:CheckTeamExp(base) --组队天神，废弃
	if not UIMainFunc:GetTopVisible() then return false; end
	local lv = MainPlayerModel.humanDetailInfo.eaLevel;
	if lv >= 98 and lv <= 110 then
		local enterNum = TimeDungeonModel:GetEnterNum()
		if enterNum > 0 then
			return true;
		end
	end
	return false
end

function RemindFuncTipsController:CheckDominateRoute(base)--剧情副本
	if not UIMainFunc:GetTopVisible() then return false; end
	local lv = MainPlayerModel.humanDetailInfo.eaLevel;
	if lv >= 55 and lv <= 100 then
		local enterNum = DominateRouteModel:OnGetEnterNum()
		if enterNum > 0 then
			return true;
		end
	end
	return false
end

function RemindFuncTipsController:CheckXianYuanCave(base)--打宝地宫
	if not UIMainFunc:GetTopVisible() then return false; end
	local lv = MainPlayerModel.humanDetailInfo.eaLevel;
	if lv >= 93 and lv <= 170 then
		local leftMin = XianYuanUtil:GetLeftTime();
		if leftMin >= 30 then
			local lv = MainPlayerModel.humanDetailInfo.eaLevel;
			if RemindFuncTipsModel.xianYuanCaveShowLevel == -1 then
				RemindFuncTipsModel.xianYuanCaveShowLevel = lv;
			end
			if lv - RemindFuncTipsModel.xianYuanCaveShowLevel >= 2 then
				RemindFuncTipsModel.xianYuanCaveShowLevel = lv;
				return true;
			end
		end
	end
	return false
end

function RemindFuncTipsController:CheckSmithingCollection(base)--神装收集
	if not UIMainFunc:GetTopVisible() then return false; end
	local lv = MainPlayerModel.humanDetailInfo.eaLevel;
	if lv >= 90 and lv <= 150 then
		if SmithingModel:IsEquipCollectCanOperate1() then
			return true;
		end
	end
	return false
end