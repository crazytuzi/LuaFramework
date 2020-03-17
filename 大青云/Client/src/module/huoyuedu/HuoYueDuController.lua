--[[
HuoYueDuController
   jiayong
   2015年2月2日18:18:18
]]
_G.HuoYueDuController = setmetatable({}, { __index = IController })
HuoYueDuController.name = "HuoYueDuController";
HuoYueDuController.isOutModel = false;
function HuoYueDuController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_HuoYueDu, self, self.OnHuoYueDuResult);
	MsgManager:RegisterCallBack(MsgType.SC_HuoYueDuFinish, self, self.OnHuoYueDuFinishMsg);
	MsgManager:RegisterCallBack(MsgType.SC_HuoYueLevelup, self, self.OnHuoYueLevelUpRewardMsg);
	MsgManager:RegisterCallBack(MsgType.SC_HuoYueDisplayResult, self, self.OnHuoYueDisplayResult);
	--执行保存等级

	HuoYueDuUtil:GetAttrResource();
end

--返回活跃度信息
function HuoYueDuController:OnHuoYueDuResult(msg)
	HuoYueDuModel:SetHuoyueInfo(msg.exp, msg.level);
	HuoYueDuModel:SetmodelId(msg.modelid);
	HuoYueDuModel:ClearHuoYueList();
	for i, info in ipairs(msg.list) do
		HuoYueDuModel:SetHuoyueListinfo(info.id, info.num);
	end
	self:sendNotification(NotifyConsts.HuoYueDuListRefresh);
	-- MainPlayerController:GetPlayer():SetPendantModelId(msg.modelid or 0);
end

--返回活跃度任务完成一次
function HuoYueDuController:OnHuoYueDuFinishMsg(msg)
	HuoYueDuModel:SetHuoyueListinfo(msg.id, msg.num, msg.exp);
	self:sendNotification(NotifyConsts.HuoYueDuListRefresh);
end

--返回活跃度升级结果
function HuoYueDuController:OnHuoYueLevelUpRewardMsg(msg)

	if msg.result == 0 then
		HuoYueDuModel:SetHuoyueInfo(msg.exp, msg.level);
	else
		print("显示仙阶，模型失败")
	end
end

function HuoYueDuController:OnHuoYueDisplayResult(msg)

	if msg.result == 0 then
		HuoYueDuModel:SetmodelId(msg.modelid);
		-- MainPlayerController:GetPlayer():SetPendantModelId(msg.modelid or 0);
	end
end

--客户端请求：活跃度升级
function HuoYueDuController:ReqHuoYueLevelup()

	if self:GetXianjieUpdate() then
		local msg = ReqHuoYueLevelupMsg:new();
		MsgManager:Send(msg);
	else
		print("仙阶经验不足");
	end
end

function HuoYueDuController:IsOpen()
	local openLevel = t_funcOpen[23].open_level;
	return MainPlayerModel.humanDetailInfo.eaLevel >= openLevel;
end

function HuoYueDuController:GetXianjieUpdate()
	if not HuoYueDuUtil:GetMaxModelLevel() then return false end --等级已满返回false
	if not FuncManager:GetFuncIsOpen(FuncConsts.HuoYueDu) then return false end
	local level = math.max(HuoYueDuModel:GetHuoyueLevel(), 1);
	local index = t_xianjielv[level]
	if not index then return; end
	local exp = HuoYueDuModel:GetHuoyueExp();
	if exp >= index.exp then
		return true
	else
		return false
	end
end

function HuoYueDuController:GetXianjieModelId()

	local level = HuoYueDuModel:GetHuoyueLevel()
	if not level then return; end
	local cfg = t_xianjielv[level + 1].title
	if not cfg then return; end
	local msg = ReqHuoYueDisplayMsg:new();
	msg.modelid = cfg
	MsgManager:Send(msg);
end

function HuoYueDuController:ReqChangeXianjieModel(modelLevel)
	local currentUseModelLevel = HuoYueDuModel:GetmodelId()
	if modelLevel == currentUseModelLevel then return end
	local msg = ReqHuoYueDisplayMsg:new();
	msg.modelid = modelLevel
	MsgManager:Send(msg)
end
	