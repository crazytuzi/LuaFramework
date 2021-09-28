------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")
------------------------------------------------------

--多人骑乘
--[[g_MULHORSE_OFFLINE		= -1  --对方已下线
g_MULHORSE_INVALID		= -2  --无效
g_MULHORSE_SELF_FULL	= -3  --自己坐骑已满
g_MULHORSE_OTHER_FULL	= -4  --对方坐骑已满
g_MULHORSE_SELF_RIDE	= -5  --自己已在坐骑上
g_MULHORSE_OTHER_RIDE	= -6  --对方已在坐骑上
g_MULHORSE_SELF_UNRIDE	= -7  --自己没在骑乘状态
g_MULHORSE_OTHER_UNRIDE = -8  --对方没在骑乘状态
g_MULHORSE_TIME_OUT		= -9  --超时
g_MULHORSE_TOO_FAR		= -20 --离得太远
g_MULHORSE_IN_FIGHT		= -21 --战斗状态
g_MULHORSE_LEAD			= -30 --指引状态
g_MULHORSE_BUSY			= -31 --正忙--]]

-- 邀请骑乘协议
function i3k_sbean.mulhorse_invite(roleID)
	if g_i3k_game_context:IsBlackListBaned(roleID) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17732))
		return
	end
	local data = i3k_sbean.mulhorse_invite_req.new()
	data.roleID = roleID
	i3k_game_send_str_cmd(data, "mulhorse_invite_res")
end

function i3k_sbean.mulhorse_invite_res.handler(bean, req)
	if bean.ok == 1 then
		
	else
		g_i3k_game_context:MulHorseErrorCode(bean.ok)
	end
end

-- 接收到骑乘邀请后选择是否同意操作：(0:拒绝， 1:同意)
function i3k_sbean.mulhorse_invitehandle(inviter, accept)
	local data = i3k_sbean.mulhorse_invitehandle_req.new()
	data.inviter = inviter
	data.accept = accept
	i3k_game_send_str_cmd(data, "mulhorse_invitehandle_res")
end

function i3k_sbean.mulhorse_invitehandle_res.handler(bean, req)
	if bean.ok == 1 then
	
	else
		g_i3k_game_context:MulHorseErrorCode(bean.ok)
	end
end

-- 接收到其他玩家骑乘申请后是否同意操作(离得太远，战斗状态，指引状态，忙，0:拒绝， 1:同意)
function i3k_sbean.mulhorse_applyhandle(roleID, accept)
	local data = i3k_sbean.mulhorse_applyhandle_req.new()
	data.roleID = roleID
	data.accept = accept
	i3k_game_send_str_cmd(data, "mulhorse_applyhandle_res")
end

function i3k_sbean.mulhorse_applyhandle_res.handler(bean, req)
	if bean.ok == 1 then
		
	else
		g_i3k_game_context:MulHorseErrorCode(bean.ok)
	end
end

-- 离开多人骑乘请求协议
function i3k_sbean.mulhorse_leave_requst(callBack)
	local data = i3k_sbean.mulhorse_leave_req.new()
	data.callBack = callBack
	i3k_game_send_str_cmd(data, "mulhorse_leave_res")
end

function i3k_sbean.mulhorse_leave_res.handler(bean, req)
	if bean.ok == 1 then
		local hero = i3k_game_get_player_hero()
		hero:SetMulHorseState(false)
		if req.callBack then
			g_i3k_game_context:SetMulHorseCallbackFunc(req.callBack)
		end
	end
end

-- 剔除骑乘成员
function i3k_sbean.mulhorse_kick_requst(roleID)
	local data = i3k_sbean.mulhorse_kick_req.new()
	data.roleID = roleID
	i3k_game_send_str_cmd(data, "mulhorse_kick_res")
end

function i3k_sbean.mulhorse_kick_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(659))
		g_i3k_ui_mgr:CloseUI(eUIID_KickMember)
	end
end

-- 转发其他玩家的骑乘邀请
function i3k_sbean.mulhorse_invite_forward.handler(bean)
	local roleID = bean.roleID
	local msg = i3k_get_string(651, bean.roleName)
	if g_i3k_game_context:IsInLeadMode() then
		i3k_sbean.mulhorse_invitehandle(roleID, g_MULHORSE_LEAD)
		return
	end
	if g_i3k_game_context:IsInFightTime() then
		i3k_sbean.mulhorse_invitehandle(roleID, g_MULHORSE_IN_FIGHT)
		return
	end
	local function callback(isOk)
		if isOk then
			i3k_sbean.mulhorse_invitehandle(roleID, 1) --同意
		else
			i3k_sbean.mulhorse_invitehandle(roleID, 0) --拒绝
		end
	end
	local isEscort = g_i3k_game_context:GetTransportState()
	local isOnRide = g_i3k_game_context:IsOnRide()
	local isBusy = isOnRide or isEscort == 1 or g_i3k_game_context:IsInMissionMode() or g_i3k_game_context:IsInSuperMode() or g_i3k_game_context:IsAutoFight()
	if isBusy or not g_i3k_ui_mgr:ShowCustomMessageBox2("同意", "拒绝", msg, callback) then
		i3k_sbean.mulhorse_invitehandle(roleID, g_MULHORSE_BUSY)
	end
end

-- 通知邀请者前面的邀请结果(result 拒绝，离得太远，战斗状态，指引状态，忙，| 对方已在多人坐骑上，超时)
function i3k_sbean.mulhorse_invite_result.handler(bean)
	local roleID = bean.roleID
	local roleName = bean.roleName
	local result = bean.result
	if result == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(643, roleName))
	elseif result == g_MULHORSE_TOO_FAR then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(640, roleName))
	elseif result == g_MULHORSE_IN_FIGHT or result == g_MULHORSE_LEAD or result == g_MULHORSE_BUSY then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(638, roleName))
	elseif result == g_MULHORSE_OTHER_RIDE then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(663, roleName))
	elseif result == g_MULHORSE_TIME_OUT then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(662))
	end
end

-- 申请多人骑乘
function i3k_sbean.mulhorse_apply(roleID)
	if g_i3k_game_context:IsBlackListBaned(roleID) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17732))
		return
	end
	local data = i3k_sbean.mulhorse_apply_req.new()
	data.roleID = roleID
	i3k_game_send_str_cmd(data, "mulhorse_apply_res")
end

function i3k_sbean.mulhorse_apply_res.handler(bean, req)
	if bean.ok == 1 then

	else
		g_i3k_game_context:MulHorseErrorCode(bean.ok)
	end
end

-- 转发其他玩家的骑乘申请
function i3k_sbean.mulhorse_apply_forward.handler(bean)
	local roleID = bean.roleID
	local msg = i3k_get_string(652, bean.roleName)
	if g_i3k_game_context:IsInLeadMode() then
		i3k_sbean.mulhorse_applyhandle(roleID, g_MULHORSE_LEAD)
		return
	end
	if g_i3k_game_context:IsInFightTime() then
		i3k_sbean.mulhorse_applyhandle(roleID, g_MULHORSE_IN_FIGHT)
		return
	end
	local function callback(isOk)
		if isOk then
			i3k_sbean.mulhorse_applyhandle(roleID, 1) --同意
		else
			i3k_sbean.mulhorse_applyhandle(roleID, 0) --拒绝
		end
	end
	if not g_i3k_ui_mgr:ShowCustomMessageBox2("同意", "拒绝", msg, callback) then
		i3k_sbean.mulhorse_applyhandle(roleID, g_MULHORSE_BUSY)
	end
end

-- 通知申请者前面的申请结果(result 拒绝，离得太远，战斗状态，指引状态，忙|对方坐骑已满，对方已下马，超时)
function i3k_sbean.mulhorse_apply_result.handler(bean)
	local roleID = bean.roleID
	local roleName = bean.roleName
	local result = bean.result
	if result == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(644, roleName))
	elseif result == g_MULHORSE_TOO_FAR then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(640, roleName))
	elseif result == g_MULHORSE_IN_FIGHT or result == g_MULHORSE_LEAD or result == g_MULHORSE_BUSY then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(649, roleName))
	elseif result == g_MULHORSE_OTHER_FULL then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(665))
	elseif result == g_MULHORSE_OTHER_UNRIDE then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(666, roleName))
	elseif result == g_MULHORSE_TIME_OUT then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(662))
	end
end

-- 通知新成员加入多人骑乘
function i3k_sbean.mulhorse_join.handler(bean)
	if g_i3k_game_context:GetRoleId() == bean.roleID then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(661))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(656, bean.roleName))
	end
end

-- 通知有成员离开多人骑乘
function i3k_sbean.mulhorse_leave.handler(bean)
	if g_i3k_game_context:GetRoleId() == bean.roleID then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(660))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(657, bean.roleName))
	end
	g_i3k_ui_mgr:CloseUI(eUIID_KickMember)
end

-- 通知有成员被踢出多人骑乘
function i3k_sbean.mulhorse_kick.handler(bean)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(658))
end
