require("scripts/game/wangchengzhengba/wangchengzhengba_data")
require("scripts/game/wangchengzhengba/wangchengzhengba_view")

WangChengZhengBaCtrl = WangChengZhengBaCtrl or BaseClass(BaseController)

function WangChengZhengBaCtrl:__init()
	if	WangChengZhengBaCtrl.Instance then
		ErrorLog("[WangChengZhengBaCtrl]:Attempt to create singleton twice!")
	end
	WangChengZhengBaCtrl.Instance = self

	self.data = WangChengZhengBaData.New()
	self.view = WangChengZhengBaView.New(ViewDef.WangChengZhengBa)
	require("scripts/game/wangchengzhengba/wangchengzhengba_glory").New(ViewDef.WangChengZhengBa.EmpireGlory)
	require("scripts/game/wangchengzhengba/wangchengzhengba_rule").New(ViewDef.WangChengZhengBa.SiegeRule)
	require("scripts/game/wangchengzhengba/wangchengzhengba_apply").New(ViewDef.WangChengZhengBa.ApplySiege)
	require("scripts/game/wangchengzhengba/wangchengzhengba_rewards").New(ViewDef.WangChengZhengBa.SiegeRewards)

	self:RegisterAllProtocols()
	self:RegisterAllRemind()
end

function WangChengZhengBaCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	if self.reward_view then
		self.reward_view:DeleteMe()
		self.reward_view = nil
	end

	self.data:DeleteMe()
	self.data = nil
	
	WangChengZhengBaCtrl.Instance = nil
end

-----------------------------------------
-- 协议

function WangChengZhengBaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGongChengGuildList, "OnGongChengGuildList")
	self:RegisterProtocol(SCSBKSignUpList, "OnSBKSignUpList")
	self:RegisterProtocol(SCSBKRewardMsg, "OnSBKRewardMsg")
	self:RegisterProtocol(SCSbkBaseMsg, "OnSbkBaseMsg")
	self:RegisterProtocol(SCSbkWarState, "OnSbkWarState")

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.GetWCZBMsg, self))
end

-- 获取攻城行会列表
function WangChengZhengBaCtrl.SendGetGongChengGuildList()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGongChengGuildList)
	protocol.day = 1
	protocol:EncodeAndSend()
end

function WangChengZhengBaCtrl:OnGongChengGuildList(protocol)
	self.data:SetGongChengGuildList(protocol)
	-- self.view:Flush()
end


-- 获取攻城行会奖励
function WangChengZhengBaCtrl.SendGetGongChengGuildReward(reward_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGongChengGuildReward)
	protocol.reward_index = reward_index
	protocol:EncodeAndSend()
end


-- 获取今天报名和明天报名的行会名字
function WangChengZhengBaCtrl.SendGetTodayTomorrowSignUpGuildName()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetTodayTomorrowSignUpGuildName)
	protocol:EncodeAndSend()
end

function WangChengZhengBaCtrl:OnSBKSignUpList(protocol)
	self.data:SetSBKSignUpList(protocol)
	self.view:Flush()
end


-- 报名攻城
function WangChengZhengBaCtrl.SendApplyGongCheng()
	local protocol = ProtocolPool.Instance:GetProtocol(CSApplyGongCheng)
	protocol:EncodeAndSend()
end


-- 请求沙巴克领取奖励的信息
function WangChengZhengBaCtrl.SendGetGongChengGuildRewardMsg()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGongChengGuildRewardMsg)
	protocol:EncodeAndSend()
end

-- 下发沙巴克领取奖励信息
function WangChengZhengBaCtrl:OnSBKRewardMsg(protocol)
	self.data:SetSBKRewardMsg(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.WangChengZBReward)
	-- self.view:Flush()
end


-- 请求沙巴克信息
function WangChengZhengBaCtrl.SendGetSbkMag()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetSbkMag)
	protocol:EncodeAndSend()

	local is_now_gc, is_over_gc = WangChengZhengBaData.GetIsNowGCOpen(true)
	if is_now_gc and WangChengZhengBaData.Instance
		and WangChengZhengBaData.Instance.sbk_base_msg_list then
		WangChengZhengBaData.Instance.sbk_base_msg_list.guild_main_mb_list = {}
	end
end

-- 下发沙巴克基本信息
function WangChengZhengBaCtrl:OnSbkBaseMsg(protocol)
	self.data:SetSbkBaseMsg(protocol)
	self:SendGetSbkRoleVoMsg()
	-- self.view:Flush()
end

function WangChengZhengBaCtrl:SendGetSbkRoleVoMsg()
	local mb_list = self.data and self.data:GetSbkBaseMsg() and self.data:GetSbkBaseMsg().guild_main_mb_list
	if not mb_list then return end

	for k,v in pairs(mb_list) do
		if v.role_name and v.role_name ~= "" then
			BrowseCtrl.SendGetOutLinePlayerInfo(v.role_name, v.role_id, OUT_LINE_SHOW_TYPE.GONG_CHENG)
		end
	end
end

function WangChengZhengBaCtrl:OnSbkRoleVo(vo)
	if not vo then return end
	self.data:SetSbkRoleVo(vo)
	-- self.view:Flush()
end


-- 获取沙巴克城战的状态
function WangChengZhengBaCtrl.SendGetSbkState()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetSbkState)
	protocol:EncodeAndSend()
end

-- 下发沙巴克城战的状态
function WangChengZhengBaCtrl:OnSbkWarState(protocol)
	self.data:SetSbkWarState(protocol)
	-- self.view:Flush()
end


-- 登录获取信息
function WangChengZhengBaCtrl:GetWCZBMsg()
	WangChengZhengBaCtrl.SendGetGongChengGuildList()
	WangChengZhengBaCtrl.SendGetTodayTomorrowSignUpGuildName()
	WangChengZhengBaCtrl.SendGetGongChengGuildRewardMsg()
	WangChengZhengBaCtrl.SendGetSbkMag()
	WangChengZhengBaCtrl.SendGetSbkState()
end



-----------------------------------------
-- 提醒

function WangChengZhengBaCtrl:RegisterAllRemind()
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.WangChengZBReward)
end

-- 获取提醒数
function WangChengZhengBaCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.WangChengZBReward then
		if self.data.sbk_can_get_reward_mark then 
			self.view:OnFlushRemind(self.data.sbk_can_get_reward_mark > 0)
			return self.data.sbk_can_get_reward_mark
		end
		return 0
	end
end