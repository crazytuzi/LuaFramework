module(..., package.seeall)

--GS2C--

function GS2COnlineStatus(pbdata)
	local onlinestatus = pbdata.onlinestatus
	--todo
	g_FriendCtrl:SetOnlineState(onlinestatus)
end

function GS2CLoginFriend(pbdata)
	local friend_chat_list = pbdata.friend_chat_list
	local black_list = pbdata.black_list
	local friend_onlinestatus_list = pbdata.friend_onlinestatus_list
	--todo
	g_FriendCtrl:InitFriend(friend_onlinestatus_list)
	g_FriendCtrl:InitOnlineState(friend_onlinestatus_list)
	g_FriendCtrl:InitBlackList(black_list)
end

function GS2CAddFriend(pbdata)
	local profile_list = pbdata.profile_list
	--todo
	for i = 1, #profile_list do
		profile_list[i] = g_NetCtrl:DecodeMaskData(profile_list[i], "friend")
	end
	g_FriendCtrl:AddFriendList(profile_list)
end

function GS2CDelFriend(pbdata)
	local pid_list = pbdata.pid_list
	--todo
	g_FriendCtrl:DelFriendList(pid_list)
end

function GS2CAckChatTo(pbdata)
	local pid = pbdata.pid
	local message_id = pbdata.message_id
	--todo
end

function GS2CChatFrom(pbdata)
	local pid = pbdata.pid
	local msg = pbdata.msg
	local message_id = pbdata.message_id
	--todo
	netfriend.C2GSAckChatFrom(pid, message_id)
	g_TalkCtrl:AddMsg(pid, msg, message_id)
end

function GS2CRecommendFriends(pbdata)
	local recommend_friend_list = pbdata.recommend_friend_list
	--todo
	g_FriendCtrl:SetRecommendFriends(recommend_friend_list)
end

function GS2CStrangerProfile(pbdata)
	local profile_list = pbdata.profile_list
	--todo
	g_FriendCtrl:AddStranger(profile_list)
end

function GS2CFriendShield(pbdata)
	local pid_list = pbdata.pid_list
	--todo
	g_FriendCtrl:AddBlackFriend(pid_list)
end

function GS2CFriendUnshield(pbdata)
	local pid_list = pbdata.pid_list
	--todo
	g_FriendCtrl:DelBlackFriend(pid_list)
end

function GS2CSendDocument(pbdata)
	local doc = pbdata.doc
	local parlist = pbdata.parlist
	local ph_url = pbdata.ph_url
	local equip = pbdata.equip
	local is_charm = pbdata.is_charm --是否点过赞
	--todo
	if doc.pid == g_AttrCtrl.pid then
		local oView = CFriendMainView:GetView()
		if oView and oView:GetActive() then
			oView:ShowInfoPage(doc, parlist, equip, ph_url, is_charm)
		else
			CFriendMainView:ShowView(function (oView)
				oView:ShowInfoPage(doc, parlist, equip, ph_url, is_charm)
			end)
		end
		g_FriendCtrl:OnEvent(define.Friend.Event.UpdateDoc, pbdata)
	else
		CFriendInfoView:ShowView(function (oView)
			oView:SetData(doc, parlist, equip, ph_url, is_charm)
		end)
	end
end

function GS2CFriendSetting(pbdata)
	local setting = pbdata.setting
	--todo
	g_FriendCtrl:UpdateFriendSeting(setting)
end

function GS2CApplyList(pbdata)
	local pidlist = pbdata.pidlist
	--todo
	g_FriendCtrl:UpdateApplyList(pidlist)
end

function GS2CFriendDegree(pbdata)
	local pid = pbdata.pid
	local degree = pbdata.degree
	--todo
	g_FriendCtrl:UpdateFriendInfo(pid, "friend_degree", degree)
end

function GS2CFriendGrade(pbdata)
	local pid = pbdata.pid
	local grade = pbdata.grade
	--todo
	g_FriendCtrl:UpdateFriendInfo(pid, "grade", grade)
end

function GS2CApplyProfile(pbdata)
	local profile_list = pbdata.profile_list
	--todo
	g_FriendCtrl:UpdateApplyInfo(profile_list)
end

function GS2CSearchFriend(pbdata)
	local unit = pbdata.unit
	--todo
	local proinfo = g_NetCtrl:DecodeMaskData(unit.pro, "friend")
	proinfo.labal = unit.labal
	proinfo.addr = unit.addr
	g_FriendCtrl:ShowSearchResult({proinfo})
end

function GS2CSysFriendChat(pbdata)
	local msg = pbdata.msg
	--todo
	
end

function GS2CNearbyFriend(pbdata)
	local profile_list = pbdata.profile_list
	--todo
	local list = {}
	for _, unit in ipairs(profile_list) do
		local proinfo = g_NetCtrl:DecodeMaskData(unit.pro, "friend")
		proinfo.labal = unit.labal
		proinfo.addr = unit.addr
		table.insert(list, proinfo)
	end
	g_FriendCtrl:ShowRecommandResult(list)
end

function GS2CSendFriendPartnerInfo(pbdata)
	local par = pbdata.par
	--todo
	CPartnerLinkView:ShowView(function (oView)
		oView:Refresh(par)
	end)
end

function GS2CSendFriendEquipInfo(pbdata)
	local pid = pbdata.pid
	local item = pbdata.item
	--todo
	g_WindowTipCtrl:SetWindowItemTipsEquipItemInfo(CItem.New(item), {isLink = true,})
end

function GS2CSendSimpleInfo(pbdata)
	local frdlist = pbdata.frdlist
	--todo
	g_FriendCtrl:UpdateSimpleInfo(frdlist)
end


--C2GS--

function C2GSQueryFriendProfile(pid_list)
	local t = {
		pid_list = pid_list,
	}
	g_NetCtrl:Send("friend", "C2GSQueryFriendProfile", t)
end

function C2GSQueryFriendApply(pid_list)
	local t = {
		pid_list = pid_list,
	}
	g_NetCtrl:Send("friend", "C2GSQueryFriendApply", t)
end

function C2GSChatTo(pid, msg, message_id)
	local t = {
		pid = pid,
		msg = msg,
		message_id = message_id,
	}
	g_NetCtrl:Send("friend", "C2GSChatTo", t)
end

function C2GSAckChatFrom(pid, message_id)
	local t = {
		pid = pid,
		message_id = message_id,
	}
	g_NetCtrl:Send("friend", "C2GSAckChatFrom", t)
end

function C2GSApplyAddFriend(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("friend", "C2GSApplyAddFriend", t)
end

function C2GSAgreeApply(pidlist)
	local t = {
		pidlist = pidlist,
	}
	g_NetCtrl:Send("friend", "C2GSAgreeApply", t)
end

function C2GSDelApply(pidlist)
	local t = {
		pidlist = pidlist,
	}
	g_NetCtrl:Send("friend", "C2GSDelApply", t)
end

function C2GSDeleteFriend(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("friend", "C2GSDeleteFriend", t)
end

function C2GSFindFriend(pid, name)
	local t = {
		pid = pid,
		name = name,
	}
	g_NetCtrl:Send("friend", "C2GSFindFriend", t)
end

function C2GSFriendShield(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("friend", "C2GSFriendShield", t)
end

function C2GSFriendUnshield(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("friend", "C2GSFriendUnshield", t)
end

function C2GSEditDocument(doc)
	local t = {
		doc = doc,
	}
	g_NetCtrl:Send("friend", "C2GSEditDocument", t)
end

function C2GSTakeDocunment(pid)
	local t = {
		pid = pid,
	}
	g_NetCtrl:Send("friend", "C2GSTakeDocunment", t)
end

function C2GSFriendSetting(setting)
	local t = {
		setting = setting,
	}
	g_NetCtrl:Send("friend", "C2GSFriendSetting", t)
end

function C2GSRecommendFriends(plist)
	local t = {
		plist = plist,
	}
	g_NetCtrl:Send("friend", "C2GSRecommendFriends", t)
end

function C2GSBroadcastList(plist)
	local t = {
		plist = plist,
	}
	g_NetCtrl:Send("friend", "C2GSBroadcastList", t)
end

function C2GSNearByFriend()
	local t = {
	}
	g_NetCtrl:Send("friend", "C2GSNearByFriend", t)
end

function C2GSSetPhoto(url)
	local t = {
		url = url,
	}
	g_NetCtrl:Send("friend", "C2GSSetPhoto", t)
end

function C2GSSetShowPartner(parlist)
	local t = {
		parlist = parlist,
	}
	g_NetCtrl:Send("friend", "C2GSSetShowPartner", t)
end

function C2GSGetShowPartnerInfo(parid, target)
	local t = {
		parid = parid,
		target = target,
	}
	g_NetCtrl:Send("friend", "C2GSGetShowPartnerInfo", t)
end

function C2GSSetShowEquip(show)
	local t = {
		show = show,
	}
	g_NetCtrl:Send("friend", "C2GSSetShowEquip", t)
end

function C2GSGetEquipDesc(pid, pos)
	local t = {
		pid = pid,
		pos = pos,
	}
	g_NetCtrl:Send("friend", "C2GSGetEquipDesc", t)
end

function C2GSSimpleFriendList(pidlist)
	local t = {
		pidlist = pidlist,
	}
	g_NetCtrl:Send("friend", "C2GSSimpleFriendList", t)
end

