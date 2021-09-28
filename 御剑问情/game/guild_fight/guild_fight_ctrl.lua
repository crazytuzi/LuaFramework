require("game/guild_fight/guild_fight_view")
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
	self.reward_view = GuildFightRewardView.New()
	self.data = GuildFightData.New()
end

function GuildFightCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.reward_view ~= nil then
		self.reward_view:DeleteMe()
		self.reward_view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	GuildFightCtrl.Instance = nil
end

function GuildFightCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGBGlobalInfoNew, "OnGlobalInfo")
	self:RegisterProtocol(SCGBRoleInfoNew, "OnRoleInfo")

	--公会争霸
	self:RegisterProtocol(CSFetchGuildBattleDailyReward)
	self:RegisterProtocol(SCSendGuildBattleDailyRewardFlag, "OnSCSendGuildBattleDailyRewardFlag")
end

-- 公会争霸 全局信息（广播）
function GuildFightCtrl:OnGlobalInfo(protocol)
	self.data:SetGlobalInfo(protocol)
	self.view:Flush()
	ViewManager.Instance:FlushView(ViewName.FbIconView, "guild_rank")
end

-- 公会争霸 个人信息
function GuildFightCtrl:OnRoleInfo(protocol)
	self.data:SetRoleInfo(protocol)
	self.view:Flush()
	if FuBenCtrl.Instance.fu_ben_icon_view and FuBenCtrl.Instance.fu_ben_icon_view:IsOpen() then
		FuBenCtrl.Instance.fu_ben_icon_view:FlushZhaoJiRemindTimes(self.data:GetRemindZhaojiTimes() or 0)
	end
end

function GuildFightCtrl:OpenView()
	if self.view then
		self.view:Open()
	end
end

function GuildFightCtrl:CloseView()
	self.view:Close()
	local is_finish = GuildFightData.Instance:GetGlobalInfo().is_finish
	if is_finish == 1 then
		self.reward_view:Open()
	end
end

function GuildFightCtrl:OpenRank()
	if self.view:IsOpen() then
		self.view:Flush("open_rank")
	end
end

function GuildFightCtrl:OnSCSendGuildBattleDailyRewardFlag(protocol)
	self.data:SetGuildBattleDailyRewardFlag(protocol)
	if TipsCtrl.Instance:GetGuildWarRewardView():IsOpen() then
		TipsCtrl.Instance:GetGuildWarRewardView():Flush()
	end
	KuafuGuildBattleCtrl.Instance:FlushRewardTip()
	GuildCtrl.Instance:FlushGuildWarView()
end

function GuildFightCtrl:SendGuildWarOperate(op_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFetchGuildBattleDailyReward)
	protocol.op_type = op_type or 0
	protocol:EncodeAndSend()
end

-- 召集召集
function GuildFightCtrl:QiuJiuHandler()
	if self.data:IsCanZhaoJi() then

		local cost = self.data:GetZhaoJiIndexCost() or 0
		local yes_func = function() self:SendGuildSosReq(GUILD_SOS_TYPE.GUILD_SOS_TYPE_GUILD_BATTLE) end
		local describe = string.format(Language.Guild.TuanZhanZhaoji) or ""

		if cost > 0 then
			describe = string.format(Language.Guild.TuanZhanCost, cost) or ""
		end

		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.ZhaoJiTimesZero)
	end
end

function GuildFightCtrl:SendGuildSosReq(sos_type)
	GuildCtrl.Instance:SendSendGuildSosReq(sos_type)
end