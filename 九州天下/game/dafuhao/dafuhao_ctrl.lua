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
	self.is_hide = nil
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
	self:RegisterProtocol(SCMillionaireRankInfo, "OnDaFuHaoRankInfo")	-- 大富豪排行信息
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
	MainUICtrl.Instance:FlushView("dafuhao")
	if not DaFuHaoData.Instance:IsDaFuHaoScene() then
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		TipsCtrl.Instance:DestoryTimeCountDownView()
	else
		self:SetTimeCountDown(self.data:GetFlushDiffTime())
	end
end

-- local next_millionaire_box_refresh_time
function DaFuHaoCtrl:OnMillionaireTimeNotice(protocol)
	local flush_time = protocol.next_millionaire_box_refresh_time
	local diff_time = flush_time - TimeCtrl.Instance:GetServerTime()

	-- next_millionaire_box_refresh_time = protocol.next_millionaire_box_refresh_time

	self.data:SetFlushTime(flush_time)

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	self:SetTimeCountDown(diff_time)
end

function DaFuHaoCtrl:SetTimeCountDown(diff_time)
	if diff_time > 0 and self.data:IsDaFuHaoScene() then
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
		local function diff_time_func (elapse_time, total_time)
			-- if next_millionaire_box_refresh_time - TimeCtrl.Instance:GetServerTime() <= 5 then
			-- 	if self.count_down ~= nil then
			-- 		CountDown.Instance:RemoveCountDown(self.count_down)
			-- 		self.count_down = nil
			-- 	end
			-- 	TipsCtrl.Instance:ShowTimeCountDownView(left_time, Language.Activity.DaFuHaoFlushTime)
			-- 	return
			-- end

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
		if self.count_down ~= nil then
			CountDown.Instance:RemoveCountDown(self.count_down)
			self.count_down = nil
		end
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
	end
end

-- 请求大富豪采集信息
function DaFuHaoCtrl:SendGetGatherInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSMillionaireInfoReq)
	protocol:EncodeAndSend()
end

-- 大富豪信息
function DaFuHaoCtrl:OnDaFuHaoInfo(protocol)
	self.data:SetDaFuHaoInfo(protocol)

	self.view:Flush()
	MainUICtrl.Instance:FlushView("dafuhao")

	local obj = Scene.Instance:GetMainRole()
	if obj then
		obj:SetAttr("millionare_type", protocol.is_millionaire)
	end
	if self.data:IsDaFuHaoScene() and not self.data:IsGatherTimesLimit() then
		if not self.view:IsOpen() then
			MainUICtrl.Instance:SetViewState(false)
			self.view:Open()
		end
		if not self.is_hide then
			MainUICtrl.Instance:SetViewState(false)
		end
		self.is_hide = true
	elseif self.data:IsDaFuHaoScene() and self.data:IsGatherTimesLimit() and self.is_hide then
		MainUICtrl.Instance:SetViewState(true)
		MainUICtrl.Instance:FlushView("dafuhao")
		self.view:Close()
		self.is_hide = false
	end

	GlobalEventSystem:Fire(OtherEventType.DAFUHAO_INFO_CHANGE)


	if self.old_gather_total_times ~= protocol.gather_total_times then
		self.old_gather_total_times = protocol.gather_total_times
		local other_cfg = DaFuHaoData.Instance:GetDaFuHaoOtherCfg()
		if other_cfg then
			local roll_times_list = Split(other_cfg.Turntable_out, "|")
			if roll_times_list and next(roll_times_list) then
				for i = 1, #roll_times_list do
					if self.roll_view:IsOpen() and 1 == protocol.is_turn and self:GetIsTrunComplete() and tonumber(protocol.gather_total_times) ~= tonumber(roll_times_list[i]) then
						self.roll_view:Close()
					end

					if 0 == protocol.is_turn and tonumber(protocol.gather_total_times) == tonumber(roll_times_list[i]) then
						self.roll_view:Open()
						break
					end
				end
			end
		end
	end

	FuBenCtrl.Instance:SetExitArrowState()
end

function DaFuHaoCtrl:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "level" then
		if not self.data:IsShowDaFuHao() or not self.data:GetIsCanGather() then
			return
		end

		if not self.view:IsOpen() then
			self.view:Open()
		end
		MainUICtrl.Instance:SetViewState(false)
		self.is_hide = true

		MainUICtrl.Instance:FlushView("dafuhao")
	end
end

function DaFuHaoCtrl:CloseDaFuHao()
	if self.data:IsDaFuHaoScene() and self.data:IsGatherTimesLimit() and self.is_hide then
		MainUICtrl.Instance:SetViewState(true)
		MainUICtrl.Instance:FlushView("dafuhao")
		self.view:Close()
		self.is_hide = false
	end
end

function DaFuHaoCtrl:GetIsTrunComplete()
	self.roll_view:GetIsTrunComplete()
end

function DaFuHaoCtrl:FlushDaFuHaoView()
	if self.view then
		self.view:Flush()
	end
end

-- 申请大富豪排行信息
function DaFuHaoCtrl:SendDaFuHaoRankInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSMillionaireRankInfo)
	protocol:EncodeAndSend()
end

-- 大富豪排行信息下发
function DaFuHaoCtrl:OnDaFuHaoRankInfo(protocol)
	self.data:SetDaFuHaoRankInfo(protocol)
	self.view:Flush()
end