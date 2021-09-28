CrossServerData = CrossServerData or BaseClass()

CrossServerData.CS_TYPE_T = {
	ACTIVITY_TYPE.KF_ONEVONE,
	ACTIVITY_TYPE.KF_MINING,
	ACTIVITY_TYPE.KF_FISHING,
	}
CrossServerData.LAST_CROSS_TYPE = 0

function CrossServerData:__init()
	if CrossServerData.Instance then
		ErrorLog("[CrossServerData] attempt to create singleton twice!")
		return
	end
	CrossServerData.Instance = self
	self.cs_info = {
		cross_activity_type = 0,
		login_server_ip = 0,
		login_server_port = 0,
		pname = "",
		login_time = 0,
		login_str = "",
		anti_wallow = 0,
		server = 0,
	}
	self.is_manual_disconnect = false  -- 是否为手动断线

	self.role_id = 0
	self.server_day = 0
end

function CrossServerData:__delete()
	self.cs_info = nil
	CrossServerData.Instance = nil
end

-- 检查是否为跨服类型
function CrossServerData:CheckIsKfType(act_type)
	for k,v in pairs(CrossServerData.CS_TYPE_T) do
		if v == act_type then
			return true
		end
	end
	return false
end

-- 是否有跨服活动开启
function CrossServerData:HasKfOpen()
	for k,v in pairs(CrossServerData.CS_TYPE_T) do
		local act_statu = ActivityData.Instance:GetActivityStatuByType(v) or {}
		if act_statu.status == ACTIVITY_STATUS.OPEN then
			return true
		end
	end
	return false
end

function CrossServerData:SetCrossInfo(info)
	if not info then return end
	for k,v in pairs(info) do
		self.cs_info[k] = v
	end
end

function CrossServerData:GetCrossInfo(info)
	return self.cs_info
end

-- 设置为手动断线
function CrossServerData:SetDisconnectGameServer()
	self.is_manual_disconnect = true
end

-- 是否主动退出副本
function CrossServerData:SetLeaveCrossFbState(value)
	self.leave_fb_state = value
end

function CrossServerData:GetLeaveCrossFbState()
	local switch = self.leave_fb_state
	self.leave_fb_state = false
	return switch
end

-- 是否是手动断线
function CrossServerData:GetIsManualDisconnect()
	local switch = self.is_manual_disconnect
	self.is_manual_disconnect = false
	return switch
end

-- 得到当前跨服活动的ID
function CrossServerData:GetCurrentActType()
	return self.cs_info.cross_activity_type
end

--记录进入跨服前的唯一id
function CrossServerData:SetRoleId(role_id)
	self.role_id = role_id
end

function CrossServerData:GetRoleId()
	return self.role_id
end

--记录进入跨服当前服开服天数
function CrossServerData:SetServerDay(server_day)
	self.server_day = server_day
end

function CrossServerData:GetServerDay()
	return self.server_day
end

-- 跨服中是否允许打开
function CrossServerData:CheckCanOpenInCross(view_name)
	if view_name == ViewName.Ranking
		or view_name == ViewName.Market
		or view_name == ViewName.Guild
		or view_name == ViewName.GuildRedPacket
		or view_name == ViewName.ArenaActivityView
		or view_name == ViewName.Answer
		or view_name == ViewName.Welfare
		or view_name == ViewName.OffLineExp
		or view_name == ViewName.OnLineReward
		or view_name == ViewName.FuBen
		or view_name == ViewName.FriendRec
		or view_name == ViewName.InviteView
		or view_name == ViewName.BlackView
		or view_name == ViewName.FriendListView
		or view_name == ViewName.GiftRecord
		or view_name == ViewName.FriendDeleteView
		or view_name == ViewName.ApplyView
		or view_name == ViewName.Activity
		or view_name == ViewName.ActivityDetail
		or view_name == ViewName.GuildFight
		or view_name == ViewName.DaFuHao
		or view_name == ViewName.DaFuHaoRoll
		or view_name == ViewName.FBInfoView
		or view_name == ViewName.Treasure
		or view_name == ViewName.TreasureReward
		or view_name == ViewName.Marriage
		or view_name == ViewName.WeddingEnterView
		or view_name == ViewName.WeddingInviteView
		or view_name == ViewName.Church
		or view_name == ViewName.Wedding
		or view_name == ViewName.MarryMe
		or view_name == ViewName.YangFishView
		or view_name == ViewName.YuLeView
		or view_name == ViewName.FishPondListView
		or view_name == ViewName.BeStealRecordView
		or view_name == ViewName.HarvestRecordView
		or view_name == ViewName.MiningView
		or view_name == ViewName.MiningRecordListView
		or view_name == ViewName.MiningSelectedView
		or view_name == ViewName.MiningTargetView
		or view_name == ViewName.SeaRewardView
		or view_name == ViewName.SeaSelectedView
		or view_name == ViewName.MiningRewardView
		or view_name == ViewName.TipsSpiritAptitudeView
		or view_name == ViewName.TipsSpiritInviteView
		or view_name == ViewName.TipsSpiritHomeSendView
		or view_name == ViewName.TipsSpiritHomeHarvestView
		or view_name == ViewName.TipsSpiritHomePreviewView
		or view_name == ViewName.TipsSpiritHomeConfirmView
		or view_name == ViewName.TipsEneterCommonSceneView
		or view_name == ViewName.TipsCompleteChapterView
		or view_name == ViewName.Boss
		or view_name == ViewName.VipView
		or view_name == ViewName.TipsSpiritExpBuyBuffView
		or view_name == ViewName.TipsPortraitView
		or view_name == ViewName.LittlePetView
		or view_name == ViewName.HuanZhuangShopView
		or view_name == ViewName.TipsDayOpenTrailerView
		or view_name == ViewName.OneYuanSnatchView then

		return false, Language.Common.CantOpenInCross
	else
		return true
	end
	-- if view_name ~= ViewName.Main
	-- 	and view_name ~= ViewName.Chat
	-- 	and view_name ~= ViewName.Setting
	-- 	and view_name ~= ViewName.FBFailFinishView
	-- 	and view_name ~= ViewName.FBVictoryFinishView
	-- 	and view_name ~= ViewName.FBFinishStarView
	-- 	and view_name ~= ViewName.FuBenFinishStarNextView
	-- 	and view_name ~= ViewName.CrossCrystalInfoView
	-- 	and view_name ~= ViewName.ReviveView
	-- 	and view_name ~= ViewName.Unlock
	-- 	and view_name ~= ViewName.BuffPandectTips
	-- 	and view_name ~= ViewName.KuafuTaskRecordView
	-- 	and view_name ~= ViewName.Map then
	-- 		return false, Language.Common.CantOpenInCross
	-- end
	-- return true
end