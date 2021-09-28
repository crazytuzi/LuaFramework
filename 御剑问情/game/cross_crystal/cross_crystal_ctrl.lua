require("game/cross_crystal/cross_crystal_data")
require("game/cross_crystal/cross_crystal_info_view")

CrossCrystalCtrl = CrossCrystalCtrl or  BaseClass(BaseController)

local SHUIJING_ID =
{
	0,
	1,
	2,
	3,
}

function CrossCrystalCtrl:__init()
	if CrossCrystalCtrl.Instance ~= nil then
		print_error("[CrossCrystalCtrl] attempt to create singleton twice!")
		return
	end
	CrossCrystalCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = CrossCrystalData.New()
	self.info_view = CrossCrastalInfoView.New(ViewName.CrossCrystalInfoView)
end

function CrossCrystalCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.info_view ~= nil then
		self.info_view:DeleteMe()
		self.info_view = nil
	end

	self:CancelShuiJingBuffCountDown()
	CrossCrystalCtrl.Instance = nil
end

function CrossCrystalCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCShuijingPlayerInfo, "OnSCShuijingPlayerInfo")
	self:RegisterProtocol(SCShuijingTaskInfo, "SetCrossCrystalInfo")
	self:RegisterProtocol(SCNoticeGatherBuffInfo, "OnSCNoticeGatherBuffInfo") --广播采集不中断buff信息
end

function CrossCrystalCtrl:OnSCShuijingPlayerInfo(protocol)
	self.data:SetCrystalInfo(protocol)
	self:StartShuiJingBuffCountDown(protocol.gather_buff_time)
	self.info_view:Flush()
	local fuben_icon_view = FuBenCtrl.Instance:GetFuBenIconView()
	if fuben_icon_view:IsOpen() then
		fuben_icon_view:SetShuijingBuffBubblesText()
	end
end

function CrossCrystalCtrl:OnShuijingBuyBuff()
	local protocol = ProtocolPool.Instance:GetProtocol(CSShuijingBuyBuff)
	protocol:EncodeAndSend()
end

function CrossCrystalCtrl:SetCrossCrystalInfo(protocol)
	self.data:SetCrystalTaskInfo(protocol)
	self.info_view:Flush()
	for k,v in pairs(SHUIJING_ID) do
		if not self.data:GetTaskIsCompelete(v) and self.data:CheckIsComplete(v) then  --已完成但服务端还未记录
			CrossCrystalCtrl.SendShuijingFetchTaskReward(v)  --领取奖励
		end
	end
end

--下发当前场景采集物生成点列表信息
function CrossCrystalCtrl:OnSCGatherGeneraterList(protocol)
	local scene_id = Scene.Instance:GetSceneId()
	if scene_id == FUBEN_SCENE_ID.SHUIJING then  --水晶场景
		self.data:OnSCGatherGeneraterList(protocol.gather_list)
		if self.info_view:IsOpen() then
			self.info_view:GoOutOfSignToGather()
		end
	end
end

--广播采集不中断buff信息
function CrossCrystalCtrl:OnSCNoticeGatherBuffInfo(protocol)
	local role = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if role and role:IsRole() then
		role:ChangeWuDiGather(protocol.is_gather_wudi)
	end
end

----请求采集物生成点列表信息
function CrossCrystalCtrl.SendReqGatherGeneraterList(get_scene_id, scene_key)
	Scene.SendReqGatherGeneraterList(get_scene_id, scene_key)
end

--发送水晶领取奖励
function CrossCrystalCtrl.SendShuijingFetchTaskReward(task_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShuijingFetchTaskReward)
	protocol.task_id = task_id
	protocol:EncodeAndSend()
end

function CrossCrystalCtrl:CancelShuiJingBuffCountDown()
	if self.shuijing_buff_count_down then
		CountDown.Instance:RemoveCountDown(self.shuijing_buff_count_down)
		self.shuijing_buff_count_down = nil
	end
end

function CrossCrystalCtrl:StartShuiJingBuffCountDown(complete_time)
	self:CancelShuiJingBuffCountDown()
	local time = complete_time - TimeCtrl.Instance:GetServerTime()
	if time <= 0 then return end
	self.shuijing_buff_count_down = CountDown.Instance:AddCountDown(time, 1, BindTool.Bind(self.ShuiJingBuffCountDown, self))
end

function CrossCrystalCtrl:ShuiJingBuffCountDown(elapse_time, total_time)
	if Scene.Instance:GetSceneId() ~= FUBEN_SCENE_ID.SHUIJING then
		self:CancelShuiJingBuffCountDown()
	end
	if elapse_time >= total_time then
		self:CancelShuiJingBuffCountDown()
		local main_role = Scene.Instance:GetMainRole()
		main_role:ChangeWuDiGather(0)
	end
end