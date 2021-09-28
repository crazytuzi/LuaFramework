require("game/setting/setting_data")
require("game/setting/setting_view")
require("game/setting/unlock_view")

local SHOW_LIMIT_LEVEL = 130
SettingCtrl = SettingCtrl or BaseClass(BaseController)
function SettingCtrl:__init()
	if SettingCtrl.Instance then
		print_error("[SettingCtrl] Attemp to create a singleton twice !")
	end

	SettingCtrl.Instance = self
	self.data = SettingData.New()
	self.view = SettingView.New(ViewName.Setting)
	self.unlock_view = UnlockView.New(ViewName.Unlock)
	self:RegisterAllProtocols()
	self.is_close = false
	self.time_record = 0
	self.opreat_time = 0

	self.is_func_open = false				--是否在功能开启中

	Runner.Instance:AddRunObj(self, 8)
	-- 监听游戏设置改变
	self:BindGlobalEvent(
		SettingEventType.CLOSE_BG_MUSIC,
		BindTool.Bind1(self.OnCloseBGMusic, self))
	self:BindGlobalEvent(
		SettingEventType.CLOSE_SOUND_EFFECT,
		BindTool.Bind1(self.OnCloseSoundEffect, self))

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
	self:BindGlobalEvent(SettingEventType.AUTO_LUCK_SCREEN, BindTool.Bind1(self.OnGuaJiSettingChange, self))

	self:BindGlobalEvent(FinishedOpenFun, BindTool.Bind(self.FinishedOpenFun, self))
end

function SettingCtrl:MainuiOpenCreate()
	-- self:AddTimer()
end

function SettingCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if nil ~= self.unlock_view then
		self.unlock_view:DeleteMe()
		self.unlock_view = nil
	end

	if SettingCtrl.Instance ~= nil then
		SettingCtrl.Instance = nil
	end
	self:RemoveTimer()
	Runner.Instance:RemoveRunObj(self)
end

function SettingCtrl:OnGuaJiSettingChange(value)
	self.data:SetNeedLuckView(value)
	if value then
		self:AddTimer()
	else
		self:RemoveTimer()
	end
end

-- 添加定时器
function SettingCtrl:AddTimer()
	if self.time_quest then return end
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.LayoutRunQuest, self), 1)
	self.time_record = 0
	self.opreat_time = 0
end

-- 移除定时器
function SettingCtrl:RemoveTimer()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	self.time_record = 0
	self.opreat_time = 0
end

function SettingCtrl:LayoutRunQuest()
	self.time_record = UnityEngine.Time.unscaledTime
	if  self.opreat_time > 0
		and not UnityEngine.Debug.isDebugBuild  -- 加上此制是为了不影响开发
		and PlayerData.Instance:GetRoleVo().level >= 131
		and self.time_record - self.opreat_time >= GameEnum.Lock_Time
		and not FunctionGuide.Instance:GetIsGuide() then

		-- ViewManager.Instance:CloseAll()
		self:RemoveTimer()
		self.unlock_view:Open()
		-- local main_fight_state = MainUICtrl.Instance:GetFightToggleState()
		-- self.data:SetFightToggleState(not main_fight_state)
		-- if not main_fight_state then
		-- 	self:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, true)
		-- end
		local brightness = DeviceTool.GetScreenBrightness()
		self.data:SetScreenBright(brightness)
		if brightness > 0.3 then
			DeviceTool.SetScreenBrightness(0.3)
		end
	end
end

function SettingCtrl:GmOpenUnLockView()
	ViewManager.Instance:CloseAll()
	self.unlock_view:Open()

	local main_fight_state = MainUICtrl.Instance:GetFightToggleState()
	self.data:SetFightToggleState(not main_fight_state)
	if not main_fight_state then
		self:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, true)
	end
end


function SettingCtrl:SetIsClose(is_close)
	self.is_close = is_close
end

--设置是否在功能开启中
function SettingCtrl:FinishedOpenFun(state)
	self.is_func_open = state
end

function SettingCtrl:Update(now_time, elapse_time)
	--如果在引导中或者在功能开启中就不自动关闭菜单栏
	if FunctionGuide.Instance:GetIsGuide() or self.is_func_open then
		return
	end

	if UnityEngine.Input.GetMouseButtonDown(0) then
		self.key_down = true
		self.key_up = false
	end
	if UnityEngine.Input.GetMouseButtonUp(0) then
		self.key_up = true
		self.key_down = false
	end
	if not self.key_up and self.key_down then
		self.opreat_time = UnityEngine.Time.unscaledTime
	end
	if UnityEngine.Input.touchCount > 0 then
		self.opreat_time = UnityEngine.Time.unscaledTime
	end

	if self.opreat_time > 0 and UnityEngine.Time.unscaledTime - self.opreat_time > 20 and GameNet.Instance:IsGameServerConnected() then
		self:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false, true)
	end
end

function SettingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCHotkeyInfoAck, "OnHotkeyInfoAck")
	self:RegisterProtocol(SCUpdateNoticeInfo, "OnUpdateNoticeInfo")
end

function SettingCtrl:OnHotkeyInfoAck(protocol)
	self.data:FixBugOnFirstRecv(protocol.set_data_list)
	self.data:OnSettingInfo(protocol.set_data_list)
end

function SettingCtrl:OnUpdateNoticeInfo(protocol)
	self.data:OnUpdateNoticeInfo(protocol)
	local state = SettingData.Instance:GetRedPointState()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()

	if not IS_ON_CROSSSERVER
		and not UnityEngine.Debug.isDebugBuild  -- 加上此制是为了不影响开发（每次上线都会弹出这个面板好烦）
		and state
		and main_role_vo.level > SHOW_LIMIT_LEVEL and not IS_AUDIT_VERSION then
		ViewManager.Instance:Open(ViewName.Setting, TabIndex.setting_notice)
	end

	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.Setting)
end

function SettingCtrl:SendHotkeyInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSHotkeyInfoReq)
	protocol:EncodeAndSend()
end

function SettingCtrl:SendChangeHotkeyReq(index, value, t_type)
	index, value = SettingData.Instance:FixBugOnSend(index, value)
	local protocol = ProtocolPool.Instance:GetProtocol(CSChangeHotkeyReq)
	protocol.index = index or 0
	protocol.type = t_type or 1
	protocol.item_id = value or 0
	protocol:EncodeAndSend()
end

-- 发送领取奖励请求
function SettingCtrl:SendUpdateNoticeFetchReward()
	local protocol = ProtocolPool.Instance:GetProtocol(CSUpdateNoticeFetchReward)
	protocol:EncodeAndSend()
end

function SettingCtrl:OnCloseBGMusic(value)
	if value then
		AudioService.Instance:SetMusicVolume(0.0)
	else
		AudioService.Instance:SetMusicVolume(1.0)
	end
end

function SettingCtrl:OnCloseSoundEffect(value)
	if value then
		AudioService.Instance:SetSFXVolume(0.0)
		AudioService.Instance:SetVoiceVolume(0.0)
	else
		AudioService.Instance:SetSFXVolume(1.0)
		AudioService.Instance:SetVoiceVolume(1.0)
	end
end

function SettingCtrl:SendRequest(list)
	local url_str = GLOBAL_CONFIG.param_list.gm_report_url
	if url_str == nil or url_str == "" then
		url_str = "http://api.ug14.youyannet.com/client/gm/report"
	end

	url_str = url_str .. "?" ..
	"zone_id=" .. list.zone_id ..
	"&server_id=" .. list.server_id ..
	"&user_id=" .. list.user_id ..
	"&role_id=" .. list.role_id ..
	"&role_name=" .. list.role_name ..
	"&role_level=" .. list.role_level ..
	"&role_gold=" .. list.role_gold ..
	"&role_scene=" .. list.role_scene ..
	"&issue_type=" .. list.issue_type ..
	"&issue_subject=" .. list.issue_subject ..
	"&issue_content=" .. list.issue_content
	local call_back = function(url, is_succ, data)
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.Setting.SublimtedComplete)
	end
	HttpClient:Request(url_str, call_back)
end
