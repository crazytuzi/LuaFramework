require ("game/dafuhao/dafuhao_data")
require ("game/dafuhao/dafuhao_view")
require ("game/dafuhao/dafuhao_roll_view")
require ("game/dafuhao/dafuhao_info_view")

DaFuHaoCtrl = DaFuHaoCtrl or BaseClass(BaseController)

function DaFuHaoCtrl:__init()
	if 	DaFuHaoCtrl.Instance ~= nil then
		print("[DaFuHaoCtrl] attempt to create singleton twice!")
		return
	end
	DaFuHaoCtrl.Instance = self
	self.view = DaFuHaoView.New(ViewName.DaFuHao)
	self.data = DaFuHaoData.New()
	self.roll_view = DaFuHaoRollView.New(ViewName.DaFuHaoRoll)
	self:RegisterAllProtocols()

	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))

	self.old_gather_total_times = -1

	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
end

function DaFuHaoCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.roll_view then
		self.roll_view:DeleteMe()
		self.roll_view = nil
	end

	DaFuHaoCtrl.Instance = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.scene_load_enter then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end

	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function DaFuHaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTurnTableReward, "OnTurnTableRewardInfo") 	-- 幸运转盘奖励结果
	self:RegisterProtocol(SCTurnTableInfo, "OnTurnTableInfo") -- 转盘信息
	self:RegisterProtocol(SCMillionaireInfo, "OnDaFuHaoInfo") -- 大富豪信息
	self:RegisterProtocol(SCTurnTableMillionaireView, "OnTurnTableMillionaire")
	self:RegisterProtocol(SCMillionaireTimeNotice, "OnMillionaireTimeNotice") -- 宝箱刷新时间
end

-- 幸运转盘活动信息
function DaFuHaoCtrl:OnTurnTableInfo(protocol)
	self.data:SetTurnTableInfo(protocol)
end

-- 幸运转盘奖励结果
function DaFuHaoCtrl:OnTurnTableRewardInfo(protocol)
	if protocol.type == GameEnum.TURNTABLE_OPERA_TYPE then
		self.data:SetTurnTableRewardInfo(protocol)
	end
end

function DaFuHaoCtrl:OnChangeScene()
	if not DaFuHaoData.Instance:IsDaFuHaoScene() then
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		TipsCtrl.Instance:DestoryTimeCountDownView()
	else
		self:SetTimeCountDown(self.data:GetFlushDiffTime())

		FuBenCtrl.Instance:SetMonsterClickCallBack(BindTool.Bind(self.OnClickBossIcon, self))
		self.view:Flush("boss")
	end
end

function DaFuHaoCtrl:OnMillionaireTimeNotice(protocol)
	local flush_time = protocol.next_millionaire_box_refresh_time
	local diff_time = flush_time - TimeCtrl.Instance:GetServerTime()

	self.data:SetFlushTime(flush_time)
	self.data:SetBossFlushData(protocol)

	self:RemoveCountDown()

	self:SetTimeCountDown(diff_time)

	self.view:Flush("boss")
end

function DaFuHaoCtrl:SetTimeCountDown(diff_time)
	if diff_time > 0 and self.data:IsDaFuHaoScene() then
		self:RemoveCountDown()
		local function diff_time_func (elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 5 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				TipsCtrl.Instance:ShowTimeCountDownView(left_time, Language.Activity.DaFuHaoFlushTime)
				return
			end
		end
		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	else
		self:RemoveCountDown()
	end
end

-- 幸运转盘活动操作请求
function DaFuHaoCtrl:SendTurnTableOperaReq(opera_type, is_roll)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTurnTableReq)
	protocol.opera_type = opera_type or 0
	protocol.is_roll = is_roll or 0
	protocol:EncodeAndSend()
end

function DaFuHaoCtrl:OnTurnTableMillionaire(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		obj:SetAttr("millionare_type", protocol.is_millionaire)
		if obj:IsMainRole() then
           self.view:Flush()
		end
	end
end

-- 请求大富豪采集信息
function DaFuHaoCtrl:SendGetGatherInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSMillionaireInfoReq)
	protocol:EncodeAndSend()
end

-- 使用冰冻技能
function DaFuHaoCtrl:SendUseSkillReq(target_obj_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMillionaireUseFrozenSkill)
	protocol.target_obj_id = target_obj_id or 0
	protocol:EncodeAndSend()
end

-- 大富豪信息
function DaFuHaoCtrl:OnDaFuHaoInfo(protocol)
	self.data:SetDaFuHaoInfo(protocol)

	self.view:Flush()

	local obj = Scene.Instance:GetMainRole()
	if obj then
		obj:SetAttr("millionare_type", protocol.is_millionaire)
	end

	GlobalEventSystem:Fire(OtherEventType.DAFUHAO_INFO_CHANGE)

	if self.roll_view:IsOpen() and 1 == protocol.is_turn and self:GetIsTrunComplete() and protocol.gather_total_times ~= 10 then
		self.roll_view:Close()
	end

	if self.old_gather_total_times ~= protocol.gather_total_times then
		self.old_gather_total_times = protocol.gather_total_times
		if 0 == protocol.is_turn and 10 == protocol.gather_total_times then
			self.roll_view:Open()
		end
	end

	-- FuBenCtrl.Instance:SetExitArrowState()
end

function DaFuHaoCtrl:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "level" then
		if not self.data:IsShowDaFuHao() then
			return
		end

		if not self.view:IsOpen() then
			self.view:Open()
		end
		MainUICtrl.Instance:SetViewState(false)
		self.is_hide = true
	end
end

function DaFuHaoCtrl:CloseDaFuHao()
	-- if self.data:IsDaFuHaoScene() and self.data:IsGatherTimesLimit() and self.is_hide then
	-- 	MainUICtrl.Instance:SetViewState(true)
	-- 	MainUICtrl.Instance:FlushView("dafuhao")
	-- 	self.view:Close()
	-- 	self.is_hide = false
	-- end
end

function DaFuHaoCtrl:GetIsTrunComplete()
	return self.roll_view:GetIsTrunComplete()
end

function DaFuHaoCtrl:FlushDaFuHaoView()
	if self.view then
		self.view:Flush()
	end
end

function DaFuHaoCtrl:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function DaFuHaoCtrl:OnClickBossIcon()
	local info = self.data:GetBossFlushData()
	if nil == next(info) then return end

	local boss_flush_time = math.floor(info.next_millionaire_boss_refresh_time - TimeCtrl.Instance:GetServerTime())
	if boss_flush_time > 0 then 
        TipsCtrl.Instance:ShowSystemMsg(Language.ShengXiao.BossBotFlush,3)
		return 
	end

	local boss_id = DaFuHaoData.Instance:GetBossID()
	local x, y = GuajiCtrl.Instance:GetMonsterPos(boss_id)

	if x and y then
		self:MoveToPosOperateFight(x, y)
	end
end

function DaFuHaoCtrl:MoveToPosOperateFight(x, y)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	local scene_id = Scene.Instance:GetSceneId()
	local boss_id = DaFuHaoData.Instance:GetBossID()
	MoveCache.param1 = boss_id
	GuajiCache.monster_id = boss_id
	MoveCache.end_type = MoveEndType.FightByMonsterId

	local scene_id = Scene.Instance:GetSceneId()
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(scene_id, x, y, 3, 0)
end