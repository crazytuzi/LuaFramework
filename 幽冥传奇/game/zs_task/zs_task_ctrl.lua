require("scripts/game/zs_task/zs_task_view")
require("scripts/game/zs_task/zs_task_data")
require("scripts/game/zs_task/zs_task_tip")

ZsTaskCtrl = ZsTaskCtrl or BaseClass(BaseController)

function ZsTaskCtrl:__init()
	if ZsTaskCtrl.Instance ~= nil then
		ErrorLog("[ZsTaskCtrl] attempt to create singleton twice!")
		return
	end
	ZsTaskCtrl.Instance = self

	self.view = ZsTaskView.New(ViewDef.ZsTaskView)
	self.data = ZsTaskData.New()
	self.task_tip = ZsTaskTipView.New()

	-- self.gift_type = 1

	self:RegisterAllEvents()
end

function ZsTaskCtrl:__delete()
	ZsTaskCtrl.Instance = nil

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if nil ~= self.task_tip then
		self.task_tip:DeleteMe()
		self.task_tip = nil
	end
end

function ZsTaskCtrl:RegisterAllEvents()
	self:RegisterProtocol(SCTaskGiftData, "OnTaskGiftData")

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ZsTask)
end

-- 小任务请求奖励
function ZsTaskCtrl:SendSmallAwardReq(gift_type)
    local protocol = ProtocolPool.Instance:GetProtocol(CSTaskGiftSmallReq)
    protocol.gift_index = gift_type
    protocol:EncodeAndSend()
end

-- 大任务请求奖励
function ZsTaskCtrl:SendBigAwardReq()
    local protocol = ProtocolPool.Instance:GetProtocol(CSTaskGiftBigReq)
    protocol:EncodeAndSend()
end

function ZsTaskCtrl:OnTaskGiftData(protocol)
	self.data:SetTaskGiftData(protocol)

	if protocol.big_task > 1 and protocol.big_task <= #TaskGoodGiftConfig.task and (self.gift_type and self.gift_type ~= protocol.big_task) then
		self.view:Close()
		self:OpenTaskTip()
	end

	self.gift_type = protocol.big_task

	RemindManager.Instance:DoRemind(RemindName.ZsTask)
end

function ZsTaskCtrl:OpenTaskTip()
	self.task_tip:Open()
end

function ZsTaskCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.ZsTask then
		return self.data:GetRemindIcon()
	end
	
end