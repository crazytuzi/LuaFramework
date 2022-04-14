require('game.vipfree.RequireVipFree')
VipFreeController = VipFreeController or class("VipFreeController",BaseController)
local VipFreeController = VipFreeController

function VipFreeController:ctor()
	VipFreeController.Instance = self
	self.model = VipFreeModel:GetInstance()
	self:AddEvents()
	self:RegisterAllProtocal()
end

function VipFreeController:dctor()
end

function VipFreeController:GetInstance()
	if not VipFreeController.Instance then
		VipFreeController.new()
	end
	return VipFreeController.Instance
end

function VipFreeController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = ""
    -- self:RegisterProtocal(35025, self.RequestLoginVerify)
end

function VipFreeController:AddEvents()
	
	local function call_back()
		local act_id1 = OperateModel.GetInstance():GetActIdByType(self.model.first_type)
		if OperateModel.GetInstance():IsActOpenByTime(act_id1) then
			lua_panelMgr:GetPanelOrCreate(VipFreePanel):Open()
		else
			Notify.ShowText("Event has ended")
		end
	end
	GlobalEvent:AddListener(VipFreeEvent.OpenVipFreePanel, call_back)

	local function call_back()
		local act_id1 = OperateModel.GetInstance():GetActIdByType(self.model.first_type)
		local act_id2 = OperateModel.GetInstance():GetActIdByType(self.model.charge_type)
		local act_info1 = OperateModel.GetInstance():GetActInfo(act_id1)
		local act_info2 = OperateModel.GetInstance():GetActInfo(act_id2)
		local show_reddot = false
		if act_info1 then
			for _, task in pairs(act_info1.tasks) do
				local rewardcfg = OperateModel:GetInstance():GetRewardConfig(act_id1, task.id)
				local reqs = (rewardcfg and rewardcfg.reqs or "{}")
				reqs = String2Table(string.format("{%s}", reqs))
				if task.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH and self.model:CheckReqs(reqs) then
					show_reddot = true
					break
				end
			end
		end
		if not show_reddot and act_info2 then
			local viplevel = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
			local tasks = act_info2.tasks
			local mutex_ids = {}
			for i=1, #tasks do
				local task = tasks[i]
				local rewardcfg = OperateModel.GetInstance():GetRewardConfig(act_id2, task.id)
				local reqs = String2Table(rewardcfg.reqs)
				local mutex_id = self.model:GetMutex(reqs)
				if task.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
					mutex_ids[mutex_id] = true
				end
			end
			for i=1, #tasks do
				local task = tasks[i]
				local rewardcfg = OperateModel.GetInstance():GetRewardConfig(act_id2, task.id)
				if not mutex_ids[task.id] then
					if viplevel>=4 then
						if string.find(rewardcfg.reqs, "{vip,4}") then
							if task.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
								show_reddot = true
								break
							end
						end
					else
						if not string.find(rewardcfg.reqs, "{vip,4}") then
							if task.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
								show_reddot = true
								break
							end
						end
					end
				end
			end
		end
		GlobalEvent:Brocast(MainEvent.ChangeRedDot, "vipfree", show_reddot)
	end
	GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, call_back)
	GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, call_back)

	local function call_back()
		local act_id1 = OperateModel.GetInstance():GetActIdByType(self.model.first_type)
		local act_id2 = OperateModel.GetInstance():GetActIdByType(self.model.charge_type)
		OperateController.GetInstance():Request1700006(act_id1)
		OperateController.GetInstance():Request1700006(act_id2)
	end
	GlobalEvent:AddListener(EventName.CrossDayAfter, call_back)
end

-- overwrite
function VipFreeController:GameStart()
	
end



