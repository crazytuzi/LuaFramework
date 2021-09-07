require("game/guild_mijing/guild_mijing_data")
require("game/guild_mijing/guild_mijing_fight_view")

GuildMijingCtrl = GuildMijingCtrl or  BaseClass(BaseController)

function GuildMijingCtrl:__init()
	if GuildMijingCtrl.Instance ~= nil then
		print_error("[GuildMijingCtrl] attempt to create singleton twice!")
		return
	end
	GuildMijingCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = GuildMijingData.New()
	self.mijing_fight_veiw = GuildMijingFightView.New(ViewName.GuildMijingFightView)
end

function GuildMijingCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.mijing_fight_veiw ~= nil then
		self.mijing_fight_veiw:DeleteMe()
		self.mijing_fight_veiw = nil
	end

	GuildMijingCtrl.Instance = nil
end

function GuildMijingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGuildFBInfo, "OnGuildFBInfo")
	self:RegisterProtocol(SCGuildFBGuardPos, "OnGuildFBGuardPos")
	self:RegisterProtocol(SCGuildFbStatus, "OnGuildFbStatus")
end

function GuildMijingCtrl:OnGuildFBInfo(protocol)
	local guild_fb_data = {}
	guild_fb_data.notify_reason = protocol.notify_reason
	guild_fb_data.curr_wave =  protocol.curr_wave
	guild_fb_data.next_wave_time =  protocol.next_wave_time
	guild_fb_data.wave_enemy_count =  protocol.wave_enemy_count
	guild_fb_data.wave_enemy_max =  protocol.wave_enemy_max
	guild_fb_data.is_pass =  protocol.is_pass
	guild_fb_data.is_finish =  protocol.is_finish
	guild_fb_data.hp = protocol.hp
	guild_fb_data.max_hp = protocol.max_hp
	guild_fb_data.kick_role_time = protocol.kick_role_time
	if SceneType.GuildMiJingFB ~= Scene.Instance:GetSceneType() then
		return
	end
	self.data:SetGuildMiJingSceneInfo(guild_fb_data)
	self.mijing_fight_veiw:Flush("mijing_info", {[guild_fb_data.notify_reason] = guild_fb_data})
end

function GuildMijingCtrl:OnGuildFBGuardPos(protocol)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), protocol.pos_x, protocol.pos_y, 1, 1)
end

--仙盟试炼状态下发
function GuildMijingCtrl:OnGuildFbStatus(protocol)
	local open_times = protocol.open_times
	local finish_timestamp = protocol.finish_timestamp

	local time = finish_timestamp - TimeCtrl.Instance:GetServerTime()
	local openstatus = 0

	if finish_timestamp == 0 and open_times == 0 then
		openstatus = 0  							--活动还未开启
		ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.GUILD_SHILIAN, ACTIVITY_STATUS.CLOSE, finish_timestamp)
	elseif time > 0 then
		openstatus = 1 								--活动正在开启
		ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.GUILD_SHILIAN, ACTIVITY_STATUS.OPEN, finish_timestamp) -- 设置准备以显示倒计时
		if Scene.Instance:GetSceneType() == SceneType.GuildMiJingFB then
			Scene.Instance:GetSceneLogic():OpenActivitySceneCd(ACTIVITY_TYPE.GUILD_SHILIAN)
		end
	elseif finish_timestamp == 0 and open_times == 1 then
		openstatus = 2 								--活动已经结束
		ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.GUILD_SHILIAN, ACTIVITY_STATUS.CLOSE, finish_timestamp)
	end
	GuildCtrl.Instance:FlushMiJing(openstatus)
end

-- 获取守卫位置
function GuildMijingCtrl.SendGetGuildFBGuardPos()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildFBGuardPos)
	send_protocol:EncodeAndSend()
end

-- 仙盟秘境开启请求
function GuildMijingCtrl.SendGuildFbStartReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildFbStartReq)
	send_protocol:EncodeAndSend()
end

--仙盟秘境进入请求
function GuildMijingCtrl.SendGuildFbEnterReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGuildFbEnterReq)
	send_protocol:EncodeAndSend()
end