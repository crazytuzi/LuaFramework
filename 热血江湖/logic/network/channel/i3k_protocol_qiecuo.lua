------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------
--发起切磋请求
function i3k_sbean.request_role_single_invite_req(id)
	if g_i3k_game_context:IsBlackListBaned(id) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17732))
		return
	end
	local data = i3k_sbean.role_single_invite_req.new()
	data.roleID = id 
	i3k_game_send_str_cmd(data, "role_single_invite_res")	
end

function i3k_sbean.role_single_invite_res.handler(bean)
	if not bean then
		return
	end
	
	if bean.ok == 1 then
		--成功发起请求
		g_i3k_ui_mgr:CloseUI(eUIID_Wjxx)
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("对方不在线")
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("对方等级不足")
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(654))
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("对方在多人骑乘或双人互动中")
	elseif bean.ok == -5 then
		g_i3k_ui_mgr:PopupTipMessage("对方在副本中")
	elseif bean.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage("自己在报名状态、或者房间")
	elseif bean.ok == -7 then
		g_i3k_ui_mgr:PopupTipMessage("自己在多人骑乘或双人互动中")
	elseif bean.ok == -8 then
		g_i3k_ui_mgr:PopupTipMessage("对方设置了拒绝邀请")
	elseif bean.ok == -9 then
		g_i3k_ui_mgr:PopupTipMessage("邀请不存在")
	elseif bean.ok == -10 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17733))
	else
		g_i3k_ui_mgr:PopupTipMessage("操作失败")
	end
end

--切磋回应
function i3k_sbean.request_role_single_response_req(roleId, accept)
	--切磋回应(-1: 拒绝 -2:正忙 -3:短时间不再接收玩家邀请)
	local data = i3k_sbean.role_single_response_req.new()
	data.accept = accept
	data.inviterID = roleId
	i3k_game_send_str_cmd(data, "role_single_response_res")
end

function i3k_sbean.role_single_response_res.handler(bean, req)
	if bean then
		if req.accept ~= -2 then--不是正忙 的时候移除
			g_i3k_game_context:removeInviteItem(req.inviterID, g_INVITE_TYPE_SOLO)--移除邀请
		end
		if bean.ok == 1 then
			if req.accept ~= -2 then
				g_i3k_ui_mgr:CloseUI(eUIID_MessageBox3)
			end
		else
			g_i3k_ui_mgr:CloseUI(eUIID_MessageBox3)
			if bean.ok == -1 then
				g_i3k_ui_mgr:PopupTipMessage("对方不在线")
			elseif bean.ok == -2 then
				g_i3k_ui_mgr:PopupTipMessage("对方等级不足")
			elseif bean.ok == -3 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(654))
			elseif bean.ok == -4 then
				g_i3k_ui_mgr:PopupTipMessage("对方在多人骑乘或双人互动中")
			elseif bean.ok == -5 then
				g_i3k_ui_mgr:PopupTipMessage("对方在副本中")
			elseif bean.ok == -6 then
				g_i3k_ui_mgr:PopupTipMessage("自己在报名状态、或者房间")
			elseif bean.ok == -7 then
				g_i3k_ui_mgr:PopupTipMessage("自己在多人骑乘或双人互动中")
			elseif bean.ok == -8 then
				g_i3k_ui_mgr:PopupTipMessage("对方设置了拒绝邀请")
			elseif bean.ok == -9 then
				g_i3k_ui_mgr:PopupTipMessage("邀请不存在")
			else
				g_i3k_ui_mgr:PopupTipMessage("操作失败")
			end
		end
	end
end

--收到切磋邀请
function i3k_sbean.role_single_invite_forward.handler(bean)
	if not bean or not bean.inviter then
		return
	end
	local roleData = bean.inviter
	local roleId = roleData.id
	local desc = i3k_get_string(15553,roleData.name,roleData.level)
	if not bean.hide then
		local yes_name = i3k_get_string(1815)
		local no_name = i3k_get_string(1816)
		local acceptFunc = function()
			i3k_sbean.request_role_single_response_req(roleId, 1)
		end
		local refuseFunc = function()
			i3k_sbean.request_role_single_response_req(roleId, -1)
		end
		local busyFunc = function()
			i3k_sbean.request_role_single_response_req(roleId, -2)
		end
		g_i3k_game_context:addInviteItem(g_INVITE_TYPE_SOLO, bean, acceptFunc, refuseFunc, busyFunc, roleId, desc, yes_name, no_name)
		return
	end
	local rtext=i3k_get_string(15554,math.floor(i3k_db_common.qiecuo.refuseTime/60))
	local function callback(isOk,isRadio)
		local accept = 0
		if isOk then
			if isRadio then
				g_i3k_ui_mgr:PopupTipMessage("选择不再接受切磋状态无法确认")
				return
			else
				accept = 1
			end
		else
			if isRadio then
				accept = -3
			else
				accept = -1
			end
		end
		i3k_sbean.request_role_single_response_req(roleId, accept)
	end
	
	local function callbackRadioButton(randioButton,yesButton,noButton)
	end
	local show = g_i3k_game_context:getInviteListSettting(g_INVITE_SET_SOLO)
	if not g_i3k_ui_mgr:ShowMidCustomMessageBox2Ex("同意", "拒绝", desc,rtext, callback,callbackRadioButton, show) then
		i3k_sbean.request_role_single_response_req(roleId, -2)
	end
end

--切磋邀请结果(-1: 拒绝 -2:正忙 )
function i3k_sbean.role_single_invite_result.handler(bean)
	if not bean then
		return
	end
	
	local roleName = bean.roleName
	if bean.result == -1 then
		local tmp_str = string.format("%s拒绝了您的邀请",roleName)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
	elseif bean.result == -2 then
		local tmp_str = string.format("%s现在繁忙",roleName)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
	elseif bean.result == 1 then
		g_i3k_game_context:clearInvites(g_INVITE_TYPE_SOLO)
	end	
end

--切磋结果
function i3k_sbean.single_map_result.handler(bean)
	if not bean then
		return
	end
	
	g_i3k_ui_mgr:OpenUI(eUIID_QieCuoResult)
	g_i3k_ui_mgr:RefreshUI(eUIID_QieCuoResult, bean)	
end
