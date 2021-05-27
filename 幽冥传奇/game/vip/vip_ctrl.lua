require("scripts/game/vip/vip_view")
require("scripts/game/vip/vip_data")
require("scripts/game/vip/vip_boss_view")
require("scripts/game/vip/vip_boss_win_view")
require("scripts/game/vip/vip_boss_lose_view")
require("scripts/game/vip/vip_tip_view")

-- VIP
VipCtrl = VipCtrl or BaseClass(BaseController)

function VipCtrl:__init()
	if VipCtrl.Instance ~= nil then
		ErrorLog("[VipCtrl] Attemp to create a singleton twice !")
	end
	VipCtrl.Instance = self

	self.vip_view = VipView.New(ViewDef.Vip)
	self.vip_boss_view = VipBossView.New(ViewDef.VipBoss)
	self.vip_boss_win_view = VipBossWinView.New(ViewDef.VipBossWin)
	self.vip_boss_lose_view = VipBossLoseView.New(ViewDef.VipBossLose)
	self.vip_tip_view = VipTipView.New(ViewDef.VipTip)

	self.vip_data = VipData.New()

	self:RegisterAllProtocols()
	self:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.GetAllVipInfo))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.VipWelfare)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.SVip)

	self.need_open_tip = false -- 是否需要打开vip升级提示
end

function VipCtrl:__delete()
	if self.vip_view then
		self.vip_view:DeleteMe()
		self.vip_view = nil
	end

	if self.vip_boss_view then
		self.vip_boss_view:DeleteMe()
		self.vip_boss_view = nil
	end

	if self.vip_boss_win_view then
		self.vip_boss_win_view:DeleteMe()
		self.vip_boss_win_view = nil
	end

	if self.vip_boss_lose_view then
		self.vip_boss_lose_view:DeleteMe()
		self.vip_boss_lose_view = nil
	end

	if self.vip_data then
		self.vip_data:DeleteMe()
		self.vip_data = nil
	end

	VipCtrl.Instance = nil
end

function VipCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.VipWelfare then
		return self.vip_data:GetVipWelfareRemindNum()
	-- elseif remind_name == RemindName.SVip then
	-- 	return SVipData.GetRemindNum()
	end
	return 0
end

function VipCtrl.GetAllVipInfo()
	VipCtrl.SentVipInfoReq()
	VipCtrl.SentVIPLevRewardsFlagReq()
end

function VipCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCIssueVIPInfo, "OnIssueVIPInfo")
	self:RegisterProtocol(SCGetVIPLevRewardFlag, "OnGetVIPLevRewardFlag")
	self:RegisterProtocol(SCVipBossGuanInfo, "OnVipBossGuanInfo")
end

function VipCtrl:OnIssueVIPInfo(protocol)
	local old_vip_lv = VipData.Instance:GetVipLevel()
	self.vip_data:SetIssueVIPInfo(protocol)

	if self.need_open_tip then
		if old_vip_lv < protocol.vip_lev then
			ViewManager.Instance:OpenViewByDef(ViewDef.VipTip)
		end
	else
		self.need_open_tip = true
	end

	RemindManager.Instance:DoRemind(RemindName.VipWelfare)
	RemindManager.Instance:DoRemind(RemindName.SVip)
end

function VipCtrl:OnGetVIPLevRewardFlag(protocol)
	self.vip_data:SetVIPLevRewardFlag(protocol)

	self.vip_view:Flush(0, "vip_reward_flush")
	RemindManager.Instance:DoRemind(RemindName.VipWelfare)
end

function VipCtrl:OnVipBossGuanInfo(protocol)
	local guan_info = VipData.Instance:GetVipBossGuanInfo()
	local cfg = VipChapterConfig or {}
	local consume = cfg.consumeCharm or 100
	
	local is_enter_copy = (self.boss_timer ~= nil) or (guan_info.count - protocol.count) == consume
	if is_enter_copy then
		-- 已进入vip_boss副本

		local is_challenge_success = (protocol.guan_num - guan_info.guan_num) == 1
		if is_challenge_success then
			-- 挑战成功

			if self.boss_timer then
				GlobalTimerQuest:CancelQuest(self.boss_timer)
				self.boss_timer = nil
			end
			if self.vip_boss_die then
				self.vip_boss_die:StopTimeDowner()
				self.vip_boss_die = nil
			end
			ViewManager.Instance:OpenViewByDef(ViewDef.VipBossWin)
		else
			local boss_cfg_list = cfg.Chapters and cfg.Chapters[guan_info.guan_num + 1] or {}
			local boss_cfg = boss_cfg_list.boss or {}
			local live_time = boss_cfg.liveTime or 30 -- boss挑战时间

			local callback = function ()
				-- 挑战失败
				local fuben_id = FubenData.Instance:GetFubenId()
				FubenCtrl.OutFubenReq(fuben_id)
				ViewManager.Instance:OpenViewByDef(ViewDef.TrialLose)
				self.boss_timer = nil

				-- 主动退出副本时,需在这里清理VipBoss倒计时显示
				if self.vip_boss_die then
					self.vip_boss_die:StopTimeDowner()
					self.vip_boss_die = nil
				end
			end
			
			self:OnVipBossDie(live_time)
			self.boss_timer = GlobalTimerQuest:AddDelayTimer(callback, live_time)
		end
	end

	self.vip_data:SetVipBossGuanInfo(protocol)
end

-- VipBoss倒计时显示
function VipCtrl:OnVipBossDie(time)
	if self.vip_boss_die ~= nil then return end

	local count_down_callback =  function (elapse_time, total_time, view) 
			local num = total_time - math.floor(elapse_time)
			if num <= 0 then
				view:StopTimeDowner()
				self.vip_boss_die = nil
			end
		end

	self.vip_boss_die = UiInstanceMgr.Instance:AddTimeLeaveView(time, count_down_callback, "vip_boss_tip")
end

-- 获取vip_boss挑战计时器
-- 用于 "判断是否处于vip_boss挑战" 和 "放弃vip_boss挑战"
function VipCtrl:GetVipBossTimer()
	return self.boss_timer
end

-- 获取vip信息请求 返回 SCIssueVIPInfo
function VipCtrl:SentVipInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetVIPInfoReq)
	protocol:EncodeAndSend()
end

-- 获取vip奖励请求
function VipCtrl:SentVipRewardsReq(level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetVIPRewardsReq)
	protocol.lev_reward = level or 0
	protocol:EncodeAndSend()
end

-- 获取vip等级奖励标记
function VipCtrl:SentVIPLevRewardsFlagReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetVIPLevRewardsFlagReq)
	protocol:EncodeAndSend()
end

-- 进入vip场景打宝
function VipCtrl:SentEnterVIPSceneEarnTreasuerReq(scene_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEnterVIPSceneEarnTreasuerReq)
	protocol.scene_type = scene_type or 0
	protocol:EncodeAndSend()
end

-- 请求挑战vip关卡
function VipCtrl.SentSChallengeVipBoss()
	local protocol = ProtocolPool.Instance:GetProtocol(CSChallengeVipBossReq)
	protocol:EncodeAndSend()
end

