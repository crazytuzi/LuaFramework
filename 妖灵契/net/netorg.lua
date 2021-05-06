module(..., package.seeall)

--GS2C--

function GS2COrgList(pbdata)
	local infos = pbdata.infos
	--todo
	g_OrgCtrl:UpdateOrgList(infos)
end

function GS2CSearchOrg(pbdata)
	local infos = pbdata.infos
	--todo
	g_OrgCtrl:UpdateOrgList(infos)
end

function GS2CApplyJoinOrg(pbdata)
	local flag = pbdata.flag --0代表申请失败，1代表申请成功
	local orgid = pbdata.orgid --公会ID
	--todo
	g_OrgCtrl:OnReceiveApplyJoinOrg(orgid, flag)
end

function GS2CGetOrgInfo(pbdata)
	local info = pbdata.info --公会基本信息
	local meminfo = pbdata.meminfo --成员信息
	--todo
	g_OrgCtrl:OnReceiveOrgInfo(info, meminfo)
end

function GS2COrgMainInfo(pbdata)
	local info = pbdata.info
	--todo
	g_OrgCtrl:OnReceiveOrgMainInfo(info)
end

function GS2COrgMemberInfo(pbdata)
	local infos = pbdata.infos
	local handle_type = pbdata.handle_type --回调处理类型
	--todo
	g_OrgCtrl:OnReceiveMemberList(infos, handle_type)
end

function GS2COrgApplyList(pbdata)
	local infos = pbdata.infos
	local powerlimit = pbdata.powerlimit --战力限制
	local needallow = pbdata.needallow --是否需要审批
	--todo
	g_OrgCtrl:OnReceiveOrgApplyList(infos, powerlimit, needallow)
end

function GS2COrgDealApply(pbdata)
	local pid = pbdata.pid
	local deal = pbdata.deal --1.同意,0.不同意
	--todo
	g_OrgCtrl:OnReceiveOrgDealApply(pid, deal)
end

function GS2CUpdateAimResult(pbdata)
	local result = pbdata.result --1.成功,0.失败
	--todo
end

function GS2CRejectAllApplyResult(pbdata)
	local result = pbdata.result --1.成功,0.失败
	--todo
	g_OrgCtrl:OnReceiveRejectAll(result)
end

function GS2CSetPositionResult(pbdata)
	local pid = pbdata.pid
	local position = pbdata.position
	--todo
	g_OrgCtrl:OnReceiveSetPosition(pid, position)
end

function GS2CDelMember(pbdata)
	local pid = pbdata.pid
	--todo
	g_OrgCtrl:DelMember(pid)
end

function GS2CSpreadOrgResult(pbdata)
	local orgid = pbdata.orgid
	local spread_cd = pbdata.spread_cd --世界宣传cd
	--todo
end

function GS2CInvited2Org(pbdata)
	local pid = pbdata.pid --邀请者id
	local pname = pbdata.pname --邀请者名字
	local org_name = pbdata.org_name --公会名字
	local org_level = pbdata.org_level --公会lv
	local orgid = pbdata.orgid --公会ID
	--todo
	local windowConfirmInfo = {
		msg = string.format("[00FF00]%s[FFFFFF]邀请您加入[00FF00]%s[FFFFFF]公会，是否接受邀请？", pname ,org_name),
		okStr = "接受",
		cancelStr = "拒绝",
		forceConfirm = true,
		okCallback = function()
			netorg.C2GSDealInvited2Org(pid, orgid, COrgCtrl.AgreeApply)
		end,
		cancelCallback = function()
			netorg.C2GSDealInvited2Org(pid, orgid, COrgCtrl.RejectApply)
		end
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function GS2CSetApplyLimitResult(pbdata)
	local result = pbdata.result --1.成功,0.失败
	--todo
	g_OrgCtrl:OnChangeLimit(result)
end

function GS2COrgAim(pbdata)
	local orgid = pbdata.orgid
	local aim = pbdata.aim
	--todo
	g_OrgCtrl:UpdateOrgAim(orgid, aim)
end

function GS2CUpdateFlagID(pbdata)
	local result = pbdata.result --1.成功,0.失败
	--todo
	g_OrgCtrl:OnReceiveChangeFlag(result)
end

function GS2CUpdateOrgInfo(pbdata)
	local info = pbdata.info
	--todo
	g_OrgCtrl:UpdateOrgMainInfo(info)
end

function GS2CRefreshOrgMember(pbdata)
	local mem_info = pbdata.mem_info
	--todo
	g_OrgCtrl:OnUpdateOrgMember(mem_info)
end

function GS2COrgWishList(pbdata)
	local mem_list = pbdata.mem_list
	--todo
	g_OrgCtrl:OnReceiveWishList(mem_list)
end

function GS2COrgRedPacket(pbdata)
	local shape = pbdata.shape --开启红包玩家shape
	local title = pbdata.title --红包标题
	local amount = pbdata.amount --红包总个数
	local remain_gold = pbdata.remain_gold --剩余金币
	local draw_list = pbdata.draw_list --领取信息
	local add_ratio = pbdata.add_ratio --加成概率
	--todo
	COrgRedBagView:ShowView(function (oView)
		oView:RefreshDetail(pbdata)
		end)
end

function GS2CDrawOrgRedPacket(pbdata)
	local idx = pbdata.idx
	local shape = pbdata.shape
	local pid = pbdata.pid
	local gold = pbdata.gold
	local title = pbdata.title
	--todo
	COrgRedBagView:ShowView(function (oView)
		oView:RefreshGet(pbdata)
		end)
end

function GS2CControlRedPacketUI(pbdata)
	local redlist = pbdata.redlist
	--todo
	CMainMenuRedPackedView:ShowView(function (oView)
		oView:AddRedData("org", {redlist})
	end)
end

function GS2COrgLog(pbdata)
	local log_info = pbdata.log_info
	--todo
	g_OrgCtrl:OnGetLog(log_info)
end

function GS2COrgFBBossList(pbdata)
	local boss_list = pbdata.boss_list --boss列表
	local left = pbdata.left --参加剩余次数
	local rest = pbdata.rest --剩余重置次数
	local cost = pbdata.cost --重置花费
	--todo
	g_OrgCtrl:UpdateOrgFBBossList(boss_list, left, rest, cost)
end

function GS2COrgFBBossHpNotify(pbdata)
	local boss_id = pbdata.boss_id
	local hp_max = pbdata.hp_max
	local hp = pbdata.hp
	--todo
	g_OrgCtrl:UpdateOrgFBBossHP(boss_id, hp_max, hp)
end

function GS2COrgOnlineCount(pbdata)
	local online_count = pbdata.online_count
	--todo
	g_OrgCtrl:OnEvent(define.Org.Event.OnlineCount, online_count)
end

function GS2COrgFuBenWarEnd(pbdata)
	local boss_hit = pbdata.boss_hit
	--todo
	local sText = string.format("此次战斗伤害 [f2b51c]%d", boss_hit)
	g_WarCtrl:SetResultValue("desc", sText)
end

function GS2CLeaveOrgTips(pbdata)
	local stip = pbdata.stip
	--todo
	g_OrgCtrl:OnLeaveOrgTips(stip)
end

function GS2CMailResult(pbdata)
	local result = pbdata.result --1.成功,0.失败
	--todo
	g_OrgCtrl:OnSendMailResult(result)
end

function GS2COpenOrgMainUI(pbdata)
	--todo
	if g_WarCtrl:IsWar() then
		return
	end
	COrgMainView:ShowView()
end

function GS2COrgQQAction(pbdata)
	local pid = pbdata.pid
	local action = pbdata.action --1:加入qq群,0:退出
	--todo
	g_QQPluginCtrl:ResetQQGroupInfo()
end


--C2GS--

function C2GSOrgList()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSOrgList", t)
end

function C2GSSearchOrg(text)
	local t = {
		text = text,
	}
	g_NetCtrl:Send("org", "C2GSSearchOrg", t)
end

function C2GSApplyJoinOrg(orgid, flag)
	local t = {
		orgid = orgid,
		flag = flag,
	}
	g_NetCtrl:Send("org", "C2GSApplyJoinOrg", t)
end

function C2GSMultiApplyJoinOrg()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSMultiApplyJoinOrg", t)
end

function C2GSGetOrgInfo(orgid)
	local t = {
		orgid = orgid,
	}
	g_NetCtrl:Send("org", "C2GSGetOrgInfo", t)
end

function C2GSCreateOrg(name, sflag, flagbgid, aim)
	local t = {
		name = name,
		sflag = sflag,
		flagbgid = flagbgid,
		aim = aim,
	}
	g_NetCtrl:Send("org", "C2GSCreateOrg", t)
end

function C2GSOrgMainInfo()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSOrgMainInfo", t)
end

function C2GSOrgMemberList(handle_type)
	local t = {
		handle_type = handle_type,
	}
	g_NetCtrl:Send("org", "C2GSOrgMemberList", t)
end

function C2GSOrgApplyList()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSOrgApplyList", t)
end

function C2GSOrgDealApply(pid, deal)
	local t = {
		pid = pid,
		deal = deal,
	}
	g_NetCtrl:Send("org", "C2GSOrgDealApply", t)
end

function C2GSUpdateAim(aim)
	local t = {
		aim = aim,
	}
	g_NetCtrl:Send("org", "C2GSUpdateAim", t)
end

function C2GSRejectAllApply()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSRejectAllApply", t)
end

function C2GSOrgSetPosition(pid, position)
	local t = {
		pid = pid,
		position = position,
	}
	g_NetCtrl:Send("org", "C2GSOrgSetPosition", t)
end

function C2GSLeaveOrg()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSLeaveOrg", t)
end

function C2GSSpreadOrg(powerlimit)
	local t = {
		powerlimit = powerlimit,
	}
	g_NetCtrl:Send("org", "C2GSSpreadOrg", t)
end

function C2GSKickMember(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("org", "C2GSKickMember", t)
end

function C2GSInvited2Org(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("org", "C2GSInvited2Org", t)
end

function C2GSDealInvited2Org(pid, orgid, flag)
	local t = {
		pid = pid,
		orgid = orgid,
		flag = flag,
	}
	g_NetCtrl:Send("org", "C2GSDealInvited2Org", t)
end

function C2GSSetApplyLimit(powerlimit, needallow)
	local t = {
		powerlimit = powerlimit,
		needallow = needallow,
	}
	g_NetCtrl:Send("org", "C2GSSetApplyLimit", t)
end

function C2GSUpdateFlagID(sflag, flagbgid)
	local t = {
		sflag = sflag,
		flagbgid = flagbgid,
	}
	g_NetCtrl:Send("org", "C2GSUpdateFlagID", t)
end

function C2GSGetAim(orgid)
	local t = {
		orgid = orgid,
	}
	g_NetCtrl:Send("org", "C2GSGetAim", t)
end

function C2GSBanChat(target, flag)
	local t = {
		target = target,
		flag = flag,
	}
	g_NetCtrl:Send("org", "C2GSBanChat", t)
end

function C2GSOrgBuild(build_type)
	local t = {
		build_type = build_type,
	}
	g_NetCtrl:Send("org", "C2GSOrgBuild", t)
end

function C2GSSpeedOrgBuild(gold_coin)
	local t = {
		gold_coin = gold_coin,
	}
	g_NetCtrl:Send("org", "C2GSSpeedOrgBuild", t)
end

function C2GSDoneOrgBuild()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSDoneOrgBuild", t)
end

function C2GSOrgSignReward(idx)
	local t = {
		idx = idx,
	}
	g_NetCtrl:Send("org", "C2GSOrgSignReward", t)
end

function C2GSOrgWishList()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSOrgWishList", t)
end

function C2GSLeaveOrgWishUI()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSLeaveOrgWishUI", t)
end

function C2GSOrgWish(partner_chip)
	local t = {
		partner_chip = partner_chip,
	}
	g_NetCtrl:Send("org", "C2GSOrgWish", t)
end

function C2GSOrgEquipWish(sid)
	local t = {
		sid = sid,
	}
	g_NetCtrl:Send("org", "C2GSOrgEquipWish", t)
end

function C2GSGiveOrgWish(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("org", "C2GSGiveOrgWish", t)
end

function C2GSGiveOrgEquipWish(target)
	local t = {
		target = target,
	}
	g_NetCtrl:Send("org", "C2GSGiveOrgEquipWish", t)
end

function C2GSOpenOrgRedPacket()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSOpenOrgRedPacket", t)
end

function C2GSDrawOrgRedPacket(idx)
	local t = {
		idx = idx,
	}
	g_NetCtrl:Send("org", "C2GSDrawOrgRedPacket", t)
end

function C2GSOrgRedPacket(idx)
	local t = {
		idx = idx,
	}
	g_NetCtrl:Send("org", "C2GSOrgRedPacket", t)
end

function C2GSOrgLog()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSOrgLog", t)
end

function C2GSPromoteOrgLevel()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSPromoteOrgLevel", t)
end

function C2GSOrgRecruit()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSOrgRecruit", t)
end

function C2GSClickSpreadOrg(orgid)
	local t = {
		orgid = orgid,
	}
	g_NetCtrl:Send("org", "C2GSClickSpreadOrg", t)
end

function C2GSOpenOrgFBUI()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSOpenOrgFBUI", t)
end

function C2GSClickOrgFBBoss(bid)
	local t = {
		bid = bid,
	}
	g_NetCtrl:Send("org", "C2GSClickOrgFBBoss", t)
end

function C2GSRestOrgFuBen()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSRestOrgFuBen", t)
end

function C2GSOrgOnlineCount()
	local t = {
	}
	g_NetCtrl:Send("org", "C2GSOrgOnlineCount", t)
end

function C2GSOrgSendMail(content)
	local t = {
		content = content,
	}
	g_NetCtrl:Send("org", "C2GSOrgSendMail", t)
end

function C2GSJoinOrgBySpread(orgid)
	local t = {
		orgid = orgid,
	}
	g_NetCtrl:Send("org", "C2GSJoinOrgBySpread", t)
end

function C2GSOrgQQAction(action)
	local t = {
		action = action,
	}
	g_NetCtrl:Send("org", "C2GSOrgQQAction", t)
end

function C2GSOrgRename(name)
	local t = {
		name = name,
	}
	g_NetCtrl:Send("org", "C2GSOrgRename", t)
end

