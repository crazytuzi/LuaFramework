require("game/guild/guild_bonfire/guild_bonfire_data")
require("game/guild/guild_bonfire/guild_bonfire_view")

GuildBonfireCtrl = GuildBonfireCtrl or  BaseClass(BaseController)

function GuildBonfireCtrl:__init()
	if GuildBonfireCtrl.Instance ~= nil then
		print_error("[GuildBonfireCtrl] attempt to create singleton twice!")
		return
	end
	GuildBonfireCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = GuildBonfireData.New()
	self.view = GuildBonfireView.New()
end

function GuildBonfireCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	GuildBonfireCtrl.Instance = nil
end

function GuildBonfireCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGuildBonfireStatus, "OnGuildBonfireStatus")
end

function GuildBonfireCtrl:Open(gather_obj)
	self.view:Open(gather_obj)
end
function GuildBonfireCtrl:OnGuildBonfireStatus(protocol)
	local open_times = protocol.open_times
	local finish_timestamp = protocol.finish_timestamp

	local time = finish_timestamp - TimeCtrl.Instance:GetServerTime()
	local openstatus = 0

	if finish_timestamp == 0 and open_times == 0 then
		openstatus = 0  							--活动还未开启
		-- ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.GUILD_BONFIRE, ACTIVITY_STATUS.CLOSE, finish_timestamp)
	elseif time > 0 then
		openstatus = 1 								--活动正在开启
		-- ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.GUILD_BONFIRE, ACTIVITY_STATUS.OPEN, finish_timestamp) -- 设置准备以显示倒计时
	elseif finish_timestamp == 0 and open_times == 1 then
		openstatus = 2 								--活动已经结束
		-- ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.GUILD_BONFIRE, ACTIVITY_STATUS.CLOSE, finish_timestamp)
	end

	if self.view:IsOpen() then
		self.view:Flush()
	end

	GuildCtrl.Instance:FlushBonFire(openstatus)

	if MainUICtrl.Instance.view then
		MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.GUILD_GODDESS, {openstatus == 1})
	end
end

-- 仙盟篝火开启请求
function GuildBonfireCtrl.SendGuildBonfireStartReq()
	if Scene.Instance:GetMainRole():GetIsFlying() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NotBonfireDesc)
		return
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildBonfireStartReq)
	send_protocol:EncodeAndSend()
end

-- 仙盟篝火前往请求
function GuildBonfireCtrl.SendGuildBonfireGotoReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildBonfireGotoReq)
	send_protocol:EncodeAndSend()
end

-- 仙盟篝火添加木材请求
function GuildBonfireCtrl:SendGuildBonfireAddMucaiReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildBonfireAddMucaiReq)
	send_protocol:EncodeAndSend()
end
