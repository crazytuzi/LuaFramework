------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")
------------------------------------------------------

--相依相偎 错误码
local ErrorCode = {
	[g_HUG_ERROR] 					= "服务器返回错误",
	[g_HUG_OFFLINE]					= "对方已下线",
	[g_HUG_INVALID]					= "无效，错误状态",
	[g_HUG_SELF_STATE]				= "自己已在相依相偎状态",
	[g_HUG_OTHER_STATE]				= "对方已在相依相偎状态",
	[g_HUG_SELF_RIDE]				= "自己已在坐骑上",
	[g_HUG_OTHER_RIDE]				= "对方在骑乘状态",
	[g_HUG_TIME_OUT]				= "邀请超时",
	[g_HUG_Dead]					= "对方已经死亡",
	[g_HUG_MULROLE_TEAM]			= "对方在多人活动中，不能双人互动",
	[g_HUG_TOO_FAR]					= "对方离得太远",
	[g_HUG_NOT_STAYWITH]			= "对方不在双人互动状态",
	[g_HUG_LEVEL]					= i3k_get_string(17057, i3k_db_common.hugMode.openLvl),
	[g_HUG_NOT_FRIEND] 				= "对方没有添加您为好友",
	[g_HUG_MEMEDA] 					= "对方正处于么么哒状态",
	[g_HUG_REFUSE] 					= "对方拒绝了您的邀请",
	[g_HUG_IN_FIGHT]				= "对方正处于战斗状态",
	[g_HUG_LEAD]					= "对方正处于指引状态",
	[g_HUG_BUSY]					= "对方正在忙碌中",
	[g_HUG_FISH]					= "对方正在钓鱼",
	[g_HUG_METAMORPHOSIS]			= i3k_get_string(1570),
}

--错误码提示
local function GetHugErrorCode(result)
	if ErrorCode[result] then
		g_i3k_ui_mgr:PopupTipMessage(ErrorCode[result])
	else
		g_i3k_ui_mgr:PopupTipMessage("无效错误码")
	end
end

-- 相依相偎邀请
function i3k_sbean.staywith_invite(roleID)
	local data = i3k_sbean.staywith_invite_req.new()
	data.roleID = roleID
	i3k_game_send_str_cmd(data, "staywith_invite_res")
end

function i3k_sbean.staywith_invite_res.handler(bean, req)
	if bean.ok == 1 then
		
	else
		GetHugErrorCode(bean.ok)
	end
end

-- 接收到相依相偎邀请后选择是否同意操作：(:离得太远， :战斗状态，:指引状态，:忙，:拒绝， :同意)
function i3k_sbean.staywith_invitehandle(inviter, accept)
	local data = i3k_sbean.staywith_invitehandle_req.new()
	data.inviter = inviter
	data.accept = accept
	i3k_game_send_str_cmd(data, "staywith_invitehandle_res")
end

function i3k_sbean.staywith_invitehandle_res.handler(bean, req)
	if bean.ok == 1 then
	
	else
		GetHugErrorCode(bean.ok)
	end
end

-- 取消相依相偎请求
function i3k_sbean.staywith_leave(callBack)
	local data = i3k_sbean.staywith_leave_req.new()
	data.callBack = callBack
	i3k_game_send_str_cmd(data, "staywith_leave_res")
end

function i3k_sbean.staywith_leave_res.handler(bean, req)
	if bean.ok == 1 then
		if req.callBack then
			req.callBack()
		end
	end
end

-- 转发其他玩家的相依相偎邀请
function i3k_sbean.staywith_invite_forward.handler(bean)
	local roleID = bean.roleID
	local msg = bean.roleName.."邀请你相依相偎，是否同意？"
	local rtext = i3k_get_string(17033,math.floor(i3k_db_common.qiecuo.refuseTime/60))
	if g_i3k_game_context:IsInLeadMode() then
		i3k_sbean.staywith_invitehandle(roleID, g_HUG_LEAD)
		return
	end
	if not g_i3k_game_context:GetFriendsDataByID(roleID) then
		i3k_sbean.staywith_invitehandle(roleID, g_HUG_NOT_FRIEND)
		return
	end
	if g_i3k_game_context:IsInFightTime() then
		i3k_sbean.staywith_invitehandle(roleID, g_HUG_IN_FIGHT)
		return
	end
	if g_i3k_game_context:IsInRoom() then
		i3k_sbean.staywith_invitehandle(roleID, g_HUG_MULROLE_TEAM)
		return
	end
	local function callback(isOk,isRadio)
		if isOk then
			if isRadio then
				g_i3k_ui_mgr:PopupTipMessage("选择不再接受互动状态无法确认")
			else
				g_i3k_ui_mgr:CloseUI(eUIID_MessageBox3)
				i3k_sbean.staywith_invitehandle(roleID, 1) --同意
			end
		else
			if isRadio then
				i3k_sbean.staywith_invitehandle(roleID, 2) --拒绝
			else
				i3k_sbean.staywith_invitehandle(roleID, 0) --拒绝
			end
			g_i3k_ui_mgr:CloseUI(eUIID_MessageBox3)
		end
	end
	local isEscort = g_i3k_game_context:GetTransportState()
	local roleGender = g_i3k_game_context:GetRoleGender()
	local isBusy = isEscort == 1 or g_i3k_game_context:IsInMissionMode() or g_i3k_game_context:IsInSuperMode() or g_i3k_game_context:IsAutoFight()
	if isBusy or not g_i3k_ui_mgr:ShowMidCustomMessageBox2Ex("同意", "拒绝", msg, rtext, callback) then
		i3k_sbean.staywith_invitehandle(roleID, g_HUG_BUSY)
	end
end

-- 通知邀请者前面的邀请结果(result :拒绝，:离得太远， :战斗状态，:指引状态，:忙，| :对方已在多人坐骑上，:超时)
function i3k_sbean.staywith_invite_result.handler(bean)
	local result = bean.result
	local roleID = bean.roleID
	local roleName = bean.roleName
	if result == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(643, roleName))
	elseif result == g_HUG_TOO_FAR then
		g_i3k_ui_mgr:PopupTipMessage(roleName.."距离太远无法一起相依相偎")
	elseif result == g_HUG_IN_FIGHT or result == g_HUG_LEAD or result == g_HUG_BUSY then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(638, roleName))
	elseif result == g_HUG_OTHER_RIDE then
		g_i3k_ui_mgr:PopupTipMessage(string.format("邀请失败%s%s",roleName,"已在相依相偎状态"))
	elseif result == g_HUG_TIME_OUT then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(662))
	end
end

-- 通知相依相偎解散
function i3k_sbean.staywith_dissolve.handler(bean)
	g_i3k_ui_mgr:PopupTipMessage("您已经脱离了相依相偎状态")
end

-- 通知新成员加入相依相偎
function i3k_sbean.staywith_join.handler(bean)
	local roleID = bean.roleID
	local roleName = bean.roleName
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17050,roleName))
end

-- 么么哒
function i3k_sbean.staywith_memeda(callBack)
	local data = i3k_sbean.staywith_memeda_req.new()
	data.callBack = callBack
	i3k_game_send_str_cmd(data, "staywith_memeda_res")
end

function i3k_sbean.staywith_memeda_res.handler(bean, req)
	if bean.ok == 1 then
		
	else
		GetHugErrorCode(bean.ok) 
	end
end

-- 广播周围玩家么么哒
function i3k_sbean.nearby_role_memeda.handler(bean)
	local world = i3k_game_get_world();
	if world then
		local entityPlayer = world:GetEntity(eET_Player, bean.rid);
		if entityPlayer and entityPlayer._hugMode and entityPlayer._linkHugChild then
			if not entityPlayer._isStarKiss and entityPlayer._linkHugChild then
				entityPlayer:RmvAiComp(eAType_MOVE)
				entityPlayer:isStarMemeda(true);
				entityPlayer:PlayHugAction(entityPlayer, i3k_db_common.hugMode.kiss, i3k_db_common.hugMode.pickUpStand);
				entityPlayer._linkHugChild:PlayHugAction(entityPlayer._linkHugChild, i3k_db_common.hugMode.kissed, i3k_db_common.hugMode.pickedUpStand);
			else
				g_i3k_ui_mgr:PopupTipMessage("您正在处于么么哒状态")
			end
		end
	end
end

