require("game/guild_fight/guild_fight_view")
require("game/guild_fight/guild_fight_view_main")
require("game/guild_fight/guild_fight_data")

GuildFightCtrl = GuildFightCtrl or BaseClass(BaseController)

function GuildFightCtrl:__init()
	if GuildFightCtrl.Instance ~= nil then
		print_error("[GuildFightCtrl] attempt to create singleton twice!")
		return
	end
	GuildFightCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = GuildFightView.New()
	self.data = GuildFightData.New()
end

function GuildFightCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	self:OnClearWorshipBtnTimer()
	GuildFightCtrl.Instance = nil
end

function GuildFightCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGBGlobalInfo, "OnGlobalInfo")
	self:RegisterProtocol(SCGBRoleInfo, "OnRoleInfo")
	self:RegisterProtocol(SCGBBianShenView, "OnBianShenView")
	self:RegisterProtocol(SCGBSendWinnerInfo, "OnWinnerInfo")
	self:RegisterProtocol(SCGBWorshipInfo, "OnWorshipInfo")
	self:RegisterProtocol(SCGBGoldBoxPositionInfo, "OnGoldBoxPositionInfo")
	self:RegisterProtocol(SCGBWorshipActivityInfo, "OnWorshipActivityInfo")
	self:RegisterProtocol(SCGuildBattleRewardInfo, "OnGuildBattelRewardInfo")
end

-- 公会争霸 全局信息（广播）
function GuildFightCtrl:OnGlobalInfo(protocol)
	if protocol.husong_end_time == 0 then
		self:ClearHuSong()
	end
	GuildFightData.Instance:SetGlobalInfo(protocol)
	self:FlushView()
end

-- 公会争霸 个人信息
function GuildFightCtrl:OnRoleInfo(protocol)
	GuildFightData.Instance:SetRoleInfo(protocol)
	Scene.Instance:GetMainRole():SetAttr("special_param", protocol.husong_goods_color)
	self:FlushView()
end

-- 公会争霸变身形象广播
function GuildFightCtrl:OnBianShenView(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if obj then
		obj:SetAttr("special_param", protocol.color)
	end
end

-- 请求开启护盾
function GuildFightCtrl:SendAddHuDunReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGBAddHuDun)
	protocol:EncodeAndSend()
end

-- 提交护送任务
function GuildFightCtrl:SendGBRoleCalcSubmitReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGBRoleCalcSubmitReq)
	protocol:EncodeAndSend()
end

-- 请求上一届公会争霸霸主信息
function GuildFightCtrl:SendGBWinnerInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGBWinnerInfoReq)
	protocol:EncodeAndSend()
end

-- 请求金箱子位置信息
function GuildFightCtrl:SendGoldboxPositionReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGBGoldboxPositionReq)
	protocol:EncodeAndSend()
end

-- 请求膜拜
function GuildFightCtrl:SendWorshipReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGBWorshipReq)
	protocol:EncodeAndSend()
end

-- 返回上一届公会争霸霸主信息
function GuildFightCtrl:OnWinnerInfo(protocol)
	self.data:SetWinnerInfo(protocol)
	ActivityCtrl.Instance.detail_view:GetCampKingListId()
end

-- 玩家膜拜信息
function GuildFightCtrl:OnWorshipInfo(protocol)
	self.data:SetWorshipInfo(protocol)
	--MainUICtrl.Instance.view:Flush("guild_fight_worship")
	local rest_time = protocol.next_worship_timestamp - TimeCtrl.Instance:GetServerTime()

	local count_down = MainUICtrl.Instance:GetGBWorshipCountDown() or 0
	if CountDown.Instance:GetRemainTime(count_down) <= 0 and rest_time > 0 then
		MainUICtrl.Instance:SetGBWorshipCountDown(rest_time)
	end

	MainUICtrl.Instance:ShowGBWorshipCdmask(rest_time > 0)

	local worship_level = GuildFightData.Instance:GetOtherConfig().worship_level_limit
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	
	if worship_level and role_level and role_level >= worship_level then
		MainUICtrl.Instance:ShowGBWorshipBtn(protocol.worship_time < self.data:GetConfig().other[1].worship_time)
	end

	self:OnClearWorshipBtnTimer()
	local addexp_time = protocol.next_addexp_timestamp - TimeCtrl.Instance:GetServerTime()
	self.worship_btn_show = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnWorshipBtnShowTimer, self), addexp_time + 0.1)
end

-- 返回金箱子位置信息
function GuildFightCtrl:OnGoldBoxPositionInfo(protocol)
	self.data:SetGoldBoxPositionInfo(protocol)
	self.view:Flush("goldboxpos")
end

-- 膜拜活动信息
function GuildFightCtrl:OnWorshipActivityInfo(protocol)
	self.data:SetWorshipActivityInfo(protocol)
	
	if protocol.is_open > 0 then
		local worship_level = GuildFightData.Instance:GetOtherConfig().worship_level_limit
		local role_level = GameVoManager.Instance:GetMainRoleVo().level
		if worship_level and role_level and role_level >= worship_level then
			ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.GUILDBATTLE_WORSHIP, ACTIVITY_STATUS.OPEN, protocol.worship_end_timestamp, 0, 0, 0)
		end
	else
		ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.GUILDBATTLE_WORSHIP, ACTIVITY_STATUS.CLOSE, protocol.worship_end_timestamp, 0, 0, 0)
	end
end

--结算奖励信息
function GuildFightCtrl:OnGuildBattelRewardInfo(protocol)
	self.data:SetGuildBattelRewardInfo(protocol)
	self.view:Flush("flush_reward_view")
end

------------------------------------------------------------

function GuildFightCtrl:FlushView()
	if self.view then
		self.view:Flush()
	end
end

function GuildFightCtrl:OpenView()
	if self.view then
		self.view:Open()
	end
end

function GuildFightCtrl:OpenTrackInfoView()
	if self.view then
		self.view:OpenTrackInfoView()
	end
end

function GuildFightCtrl:Close()
	local is_finish = GuildFightData.Instance:GetGlobalInfo().is_finish
	if is_finish == 0 then
		if self.view then
			self.view:Close()
		end
	else
		if self.view then
			self.view:OpenRewardView()
		end
	end
end

function GuildFightCtrl:ClearHuSong()
	local role_list = Scene.Instance:GetObjListByType(SceneObjType.Role)
	if role_list then
		for k,v in pairs(role_list) do
			v:SetAttr("special_param", 0)
		end
	end
end

function GuildFightCtrl:OnWorshipBtnShowTimer()
	MainUICtrl.Instance:ShowGBWorshipBtn(false)
	self:OnClearWorshipBtnTimer()
end

function GuildFightCtrl:OnClearWorshipBtnTimer()
	if nil ~= self.worship_btn_show then
		GlobalTimerQuest:CancelQuest(self.worship_btn_show)
		self.worship_btn_show = nil
	end
end