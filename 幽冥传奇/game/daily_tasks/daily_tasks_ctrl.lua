require("scripts/game/daily_tasks/daily_tasks_data")
require("scripts/game/daily_tasks/daily_tasks_view")
require("scripts/game/daily_tasks/tasks_view")

--------------------------------------------------------
-- 日常任务(降妖除魔)
--------------------------------------------------------

DailyTasksCtrl = DailyTasksCtrl or BaseClass(BaseController)

function DailyTasksCtrl:__init()
	if	DailyTasksCtrl.Instance then
		ErrorLog("[DailyTasksCtrl]:Attempt to create singleton twice!")
	end
	DailyTasksCtrl.Instance = self
	self.data = DailyTasksData.New()
	self.view = DailyTasksView.New(ViewDef.DailyTasks)
	self.tasks_view = TasksView.New(ViewDef.Tasks)

	self:RegisterAllProtocols()

	-- 上线请求
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))

end

function DailyTasksCtrl:__delete()
	DailyTasksCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

-- 上线请求回调
function DailyTasksCtrl:RecvMainInfoCallBack()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) -- 人物等级
	if level >= GameCond.CondId60.RoleLevel then
		DailyTasksCtrl.Instance:SendDailyTasksReq(1)
	end
end

--登记所有协议
function DailyTasksCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCDailyTasksResult, "OnDailyTasksResult")	--日常除魔
end

----------接收----------

-- 接收日常除魔返回结果(139, 15)
function DailyTasksCtrl:OnDailyTasksResult(protocol)
	self.data:SetData(protocol)
end

----------发送----------

-- 发送日常除魔请求
-- type = 1请求除魔信息 2接受除魔任务 3一键完成 4继续除魔 5刷新星级 6领取奖励
-- 请求类型 1, 2, 3, 5才会返回(139 15) 
function DailyTasksCtrl:SendDailyTasksReq(type, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDailyTasksReq)
	protocol.type = type
	protocol.index = index
	protocol:EncodeAndSend()
end

--------------------
