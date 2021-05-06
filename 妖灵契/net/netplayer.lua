module(..., package.seeall)

--GS2C--

function GS2CPropChange(pbdata)
	local role = pbdata.role
	--todo
	local dDecode = g_NetCtrl:DecodeMaskData(role, "role")
	g_AttrCtrl:UpdateAttr(dDecode)
end

function GS2CServerGradeInfo(pbdata)
	local server_grade = pbdata.server_grade
	local days = pbdata.days
	--todo
	local dAttr = {server_grade=server_grade, days=days}
	g_AttrCtrl:UpdateAttr(dAttr)
end

function GS2CGetPlayerInfo(pbdata)
	local grade = pbdata.grade
	local name = pbdata.name
	local model_info = pbdata.model_info
	local school = pbdata.school
	local team_id = pbdata.team_id
	local team_size = pbdata.team_size --队伍成员数量
	local pid = pbdata.pid
	local org_id = pbdata.org_id
	local org_name = pbdata.org_name
	local org_level = pbdata.org_level
	local org_pos = pbdata.org_pos
	local in_war = pbdata.in_war --1.在战斗,0:不在战斗
	local style = pbdata.style --0.默认样式 1.不显示PK
	local school_branch = pbdata.school_branch
	local show_id = pbdata.show_id --靓号ID
	--todo
	if CPlayerInfoView:GetView() ~= nil then
		CPlayerInfoView:CloseView()
	end
	CPlayerInfoView:ShowView(function(oView)
			oView:SetPlayerInfo(pbdata)
		end)
end

function GS2CGetSecondProp(pbdata)
	local prop_info = pbdata.prop_info
	--todo
end

function GS2CPlayerItemInfo(pbdata)
	local pid = pbdata.pid
	local itemdata = pbdata.itemdata
	--todo
	printc("GS2CPlayerItemInfo")
	g_LinkInfoCtrl:RefreshItemInfo(pid, itemdata)
end

function GS2CUpvotePlayer(pbdata)
	local succuss = pbdata.succuss --0-失败，1-成功
	local target_pid = pbdata.target_pid --目标pid
	--todo
	g_RankCtrl:OnReceiveLike(succuss, target_pid)
end

function GS2CPlayerTop4Partner(pbdata)
	local info_list = pbdata.info_list
	--todo
	g_RankCtrl:OnReceivePowerDetail(info_list)
end

function GS2CTodayInfo(pbdata)
	local info = pbdata.info --当日信息
	--todo
	local todyInfo = g_NetCtrl:DecodeMaskData(info, "todyInfo")
	g_AnLeiCtrl:CtrlGS2CTodayInfo(todyInfo)
	g_ChapterFuBenCtrl:OnReceiveUpdateEnergyBuytime(todyInfo)
	g_WelfareCtrl:OnReceiveFreeEnergy(todyInfo)
end

function GS2COpenPkTipsWnd(pbdata)
	--todo
	g_GuideCtrl:ShowSoloPKGuide()
end

function GS2CInitRoleNameResult(pbdata)
	local result = pbdata.result
	--todo
	if result == 1 then
		local oView = CDialogueAniView:GetView()
		if oView then
			oView:ShowReNameBox(false)
		end
		g_DialogueAniCtrl:ResumeStoryAni()
	else
		g_DialogueAniCtrl.m_ReqName = false	
	end
end

function GS2CGamePushSetting(pbdata)
	local game_push = pbdata.game_push
	--todo
	for _, v in pairs(game_push) do
		g_SysSettingCtrl:SetPushSetting(v.type, v.value)
	end
end

function GS2CGameShare(pbdata)
	local game_share = pbdata.game_share
	--todo
	g_AttrCtrl:UpdateGameShare(game_share)
end

function GS2CShapeList(pbdata)
	local shapes = pbdata.shapes --索引列表
	--todo
	g_AttrCtrl:SetSkinList(shapes)
end


--C2GS--

function C2GSGetPlayerInfo(pid, style)
	local t = {
		pid = pid,
		style = style,
	}
	g_NetCtrl:Send("player", "C2GSGetPlayerInfo", t)
end

function C2GSPlayerItemInfo(pid, itemid)
	local t = {
		pid = pid,
		itemid = itemid,
	}
	g_NetCtrl:Send("player", "C2GSPlayerItemInfo", t)
end

function C2GSChangeSchool(school_branch)
	local t = {
		school_branch = school_branch,
	}
	g_NetCtrl:Send("player", "C2GSChangeSchool", t)
end

function C2GSUpvotePlayer(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("player", "C2GSUpvotePlayer", t)
end

function C2GSRename(rename)
	local t = {
		rename = rename,
	}
	g_NetCtrl:Send("player", "C2GSRename", t)
end

function C2GSPlayerPK(target_id)
	local t = {
		target_id = target_id,
	}
	g_NetCtrl:Send("player", "C2GSPlayerPK", t)
end

function C2GSWatchWar(target_id)
	local t = {
		target_id = target_id,
	}
	g_NetCtrl:Send("player", "C2GSWatchWar", t)
end

function C2GSLeaveWatchWar()
	local t = {
	}
	g_NetCtrl:Send("player", "C2GSLeaveWatchWar", t)
end

function C2GSPlayerTop4Partner(target_pid)
	local t = {
		target_pid = target_pid,
	}
	g_NetCtrl:Send("player", "C2GSPlayerTop4Partner", t)
end

function C2GSInitRoleName(name)
	local t = {
		name = name,
	}
	g_NetCtrl:Send("player", "C2GSInitRoleName", t)
end

function C2GSGamePushSetting(type, value)
	local t = {
		type = type,
		value = value,
	}
	g_NetCtrl:Send("player", "C2GSGamePushSetting", t)
end

function C2GSGameShare(type)
	local t = {
		type = type,
	}
	g_NetCtrl:Send("player", "C2GSGameShare", t)
end

function C2GSChangeShape(shape)
	local t = {
		shape = shape,
	}
	g_NetCtrl:Send("player", "C2GSChangeShape", t)
end

