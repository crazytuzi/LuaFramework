CrossServerData = CrossServerData or BaseClass()

CrossServerData.CS_TYPE_T = {
	ACTIVITY_TYPE.KF_ONEVONE,
	ACTIVITY_TYPE.KF_MINING,
	ACTIVITY_TYPE.KF_FISHING,
}
CrossServerData.LAST_CROSS_TYPE = 0

-- 跨服是否屏蔽界面
CrossServerCloseView = {
	[ViewName.SevenLoginGiftView] = true,
	[ViewName.Ranking] = true,
	[ViewName.Market] = true,
	[ViewName.Scoiety ] = true,
	[ViewName.Guild] = true,
	-- [ViewName.GuildRedPacket] = true,
	-- [ViewName.ArenaActivityView] = true,
	[ViewName.Answer] = true,
	[ViewName.Welfare] = true,
	[ViewName.OffLineExp] = true,
	[ViewName.OnLineReward] = true,
	[ViewName.FuBen] = true,
	[ViewName.FriendRec] = true,
	[ViewName.InviteView] = true,
	[ViewName.BlackView] = true,
	[ViewName.FriendListView] = true,
	[ViewName.GiftRecord] = true,
	[ViewName.FriendDeleteView] = true,
	[ViewName.ApplyView] = true,
	[ViewName.Activity] = true,
	[ViewName.ActivityDetail] = true,
	[ViewName.GuildFight] = true,
	[ViewName.DaFuHao] = true,
	[ViewName.DaFuHaoRoll] = true,
	[ViewName.FBInfoView] = true,
	[ViewName.Treasure] = true,
	[ViewName.TreasureReward] = true,
	[ViewName.Marriage] = true,
	[ViewName.WeddingEnterView] = true,
	[ViewName.WeddingInviteView] = true,
	[ViewName.Church] = true,
	[ViewName.Wedding] = true,
	[ViewName.MarryMe] = true,
	-- [ViewName.YangFishView] = true,
	-- [ViewName.YuLeView] = true,
	-- [ViewName.FishPondListView] = true,
	-- [ViewName.BeStealRecordView] = true,
	-- [ViewName.HarvestRecordView] = true,
	[ViewName.MiningView] = true,
	[ViewName.MiningRecordListView] = true,
	[ViewName.MiningSelectedView] = true,
	[ViewName.MiningTargetView] = true,
	[ViewName.SeaRewardView] = true,
	[ViewName.SeaSelectedView] = true,
	[ViewName.MiningRewardView] = true,
	-- [ViewName.TipsSpiritAptitudeView] = true,
	-- [ViewName.TipsSpiritInviteView] = true,
	-- [ViewName.TipsSpiritHomeSendView] = true,
	-- [ViewName.TipsSpiritHomeHarvestView] = true,
	-- [ViewName.TipsSpiritHomePreviewView] = true,
	-- [ViewName.TipsSpiritHomeConfirmView] = true,
	-- [ViewName.TipsEneterCommonSceneView] = true,
	-- [ViewName.TipsCompleteChapterView] = true,
	[ViewName.Boss] = true,
	-- [ViewName.TipsSpiritExpBuyBuffView] = true,
	[ViewName.VipView] = true,
	[ViewName.Camp] = true,
}

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

	self.role_uuid = 0
	self.is_go_back = false
end

function CrossServerData:__delete()
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
function CrossServerData:SetRoleUUId(uuid)
	self.role_uuid = uuid
end

function CrossServerData:GetRoleUUId()
	return self.role_uuid
end

-- 跨服中是否允许打开
function CrossServerData:CheckCanOpenInCross(view_name)
	if CrossServerCloseView[view_name] then
		return false, Language.Common.CantOpenInCross
	else
		return true
	end
	-- if view_name ~= ViewName.Main
	-- 	and view_name ~= ViewName.Chat
	-- 	and view_name ~= ViewName.Setting
	-- 	and view_name ~= ViewName.FBFailFinishView
	-- 	and view_name ~= ViewName.FBVictoryFinishView
	-- 	and view_name ~= ViewName.CrossCrystalInfoView
	-- 	and view_name ~= ViewName.ReviveView
	-- 	and view_name ~= ViewName.Unlock
	-- 	and view_name ~= ViewName.FishingView
	-- 	and view_name ~= ViewName.FishingRankView
	-- 	and view_name ~= ViewName.KuafuTaskRecordView
	-- 	and view_name ~= ViewName.Map
	-- 	and view_name ~= ViewName.BuffPandectTips then
	-- 		return false, Language.Common.CantOpenInCross
	-- end
	-- return true
end

function CrossServerData:SetIsGoBack(value)
	self.is_go_back = value
end

function CrossServerData:GetIsGoBack()
	return self.is_go_back
end