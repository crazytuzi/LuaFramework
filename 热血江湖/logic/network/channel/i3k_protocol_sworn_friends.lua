------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

--local utils = require("logic/module/utility")
local errorString =
{
	[0] = i3k_get_string(5385),
	[-1] = i3k_get_string(5376),
	[-2] = i3k_get_string(5377),
	[-3] = i3k_get_string(5378, i3k_db_sworn_system.openLvl),
	[-4] = i3k_get_string(5379),
	[-5] = i3k_get_string(5380),
	[-6] = i3k_get_string(5381),
	[-7] = i3k_get_string(5382),
	[-8] = i3k_get_string(5384),
	[-9] = i3k_get_string(5385),
	[-10] = i3k_get_string(5385),
	[-11] = i3k_get_string(5386),
	[-12] = i3k_get_string(5387),
	[-13] = i3k_get_string(5388),
	[-14] = i3k_get_string(5389),
	[-15] = i3k_get_string(5426),
}

--登陆同步
function i3k_sbean.login_sync_sworn.handler(res)
	g_i3k_game_context:changeSwornFriends(true)
end

--开始创建结拜
function i3k_sbean.create_sworn_start()
	local data = i3k_sbean.create_sworn_start_req.new()
	i3k_game_send_str_cmd(data, "create_sworn_start_res")
end

function i3k_sbean.create_sworn_start_res.handler(res, req)
	if res.ok > 0 then
		
	elseif errorString[res.ok] then
		g_i3k_ui_mgr:PopupTipMessage(errorString[res.ok])
	end
end

--结拜生日信息收集推送
function i3k_sbean.sworn_birthday_sign_push.handler(res)--打开生日UI
	g_i3k_ui_mgr:CloseUI(eUIID_SwornDate)
	g_i3k_ui_mgr:OpenUI(eUIID_SwornDate)
	g_i3k_ui_mgr:RefreshUI(eUIID_SwornDate, res.isJoin, nil, res.oldMember)
end

--登记结拜生日
function i3k_sbean.sworn_sign_birthday(isJoin, bir)
	--<field name="birthday" type="int32"/>
	local data = i3k_sbean.sworn_sign_birthday_req.new()
	data.isJoin = isJoin
	data.birthday = bir
	i3k_game_send_str_cmd(data, "sworn_sign_birthday_res")
end

function i3k_sbean.sworn_sign_birthday_res.handler(res, req)
	if res.ok > 0 then
		if req.isJoin > 0 then
			g_i3k_game_context:changeSwornFriends(true)
			g_i3k_ui_mgr:CloseUI(eUIID_SwornDate)
			g_i3k_game_context:SetUseItemData(i3k_db_sworn_system.expendPropId, 1, nil, AT_JOIN_SWORN)
			g_i3k_ui_mgr:OpenUI(eUIID_SwornAnim)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5416))
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SwornDate, "setCollectBtnState", false)
		end
	elseif errorString[res.ok] then
		g_i3k_ui_mgr:PopupTipMessage(errorString[res.ok])
	end
end

--修改结拜生日
function i3k_sbean.sworn_change_birthday(birthday)
	--<field name="birthday" type="int32"/>
	local data = i3k_sbean.sworn_change_birthday_req.new()
	data.birthday = birthday
	i3k_game_send_str_cmd(data, "sworn_change_birthday_res")
end

function i3k_sbean.sworn_change_birthday_res.handler(res, req)
	if res.ok > 0 then
		local callback = function(data, roleData)
			g_i3k_ui_mgr:OpenUI(eUIID_SwornDate)
			g_i3k_ui_mgr:RefreshUI(eUIID_SwornDate, 0, data)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SwornDate, "setCollectBtnState", false)
		end
		i3k_sbean.sworn_sync(callback)
	elseif errorString[res.ok] then
		g_i3k_ui_mgr:PopupTipMessage(errorString[res.ok])
	end
end

--结拜生日信息推送
function i3k_sbean.sworn_birthday_push.handler(res)--流程2
	--self.birthday:		map[int32, SwornRoleData]
	g_i3k_ui_mgr:CloseUI(eUIID_SwornDate)
	g_i3k_ui_mgr:OpenUI(eUIID_SetSwornPrefix)
	g_i3k_ui_mgr:RefreshUI(eUIID_SetSwornPrefix, res.birthday)
end

--结束创建结拜
function i3k_sbean.create_sworn_end(prefix)
	--<field name="prefix" type="string"/>
	local data = i3k_sbean.create_sworn_end_req.new()
	data.prefix = prefix
	i3k_game_send_str_cmd(data, "create_sworn_end_res")
end

function i3k_sbean.create_sworn_end_res.handler(res, req)
	if res.ok > 0 then
		
	elseif errorString[res.ok] then
		g_i3k_ui_mgr:PopupTipMessage(errorString[res.ok])
	end
end

--结拜结束推送
function i3k_sbean.sworn_end_push.handler(res)--结拜成功
	--<field name="prefix" type="string"/>
	g_i3k_game_context:SetUseItemData(i3k_db_sworn_system.expendPropId, 1, nil, AT_JOIN_SWORN)
	g_i3k_game_context:changeSwornFriends(true)
	g_i3k_ui_mgr:CloseUI(eUIID_SetSwornPrefix)
	g_i3k_ui_mgr:OpenUI(eUIID_SwornAnim)
end

--结拜添加角色
function i3k_sbean.sworn_add_role()
	local data = i3k_sbean.sworn_add_role_req.new()
	i3k_game_send_str_cmd(data, "sworn_add_role_res")
end

function i3k_sbean.sworn_add_role_res.handler(res, req)
	if res.ok > 0 then
		
	elseif errorString[res.ok] then
		g_i3k_ui_mgr:PopupTipMessage(errorString[res.ok])
	end
end

--结拜踢出角色
function i3k_sbean.sworn_kick_role(roleId, reason)
	--self.roleId:		int32	
	--self.reason:		int32	
	local data = i3k_sbean.sworn_kick_role_req.new()
	data.roleId = roleId
	data.reason = reason
	i3k_game_send_str_cmd(data, "sworn_kick_role_res")
end

function i3k_sbean.sworn_kick_role_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_SwornKick)
	elseif errorString[res.ok] then
		g_i3k_ui_mgr:PopupTipMessage(errorString[res.ok])
	end
end

--结拜同步
function i3k_sbean.sworn_sync(callback)
	local data = i3k_sbean.sworn_sync_req.new()
	data.callback = callback
	i3k_game_send_str_cmd(data, "sworn_sync_res")
end

function i3k_sbean.sworn_sync_res.handler(res, req)
	--self.data:		SwornTransformData	
	--self.roleData:		DBRoleSworn	
	if res.data and res.roleData then
		if req.callback then
			req.callback(res.data, res.roleData)
		end
	end
end

--修改结拜前缀
function i3k_sbean.sworn_change_prefix(prefix, count)
	--<field name="prefix" type="string"/>
	local data = i3k_sbean.sworn_change_prefix_req.new()
	data.prefix = prefix
	data.count = count
	i3k_game_send_str_cmd(data, "sworn_change_prefix_res")
end

function i3k_sbean.sworn_change_prefix_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseCommonItem(-g_BASE_ITEM_DIAMOND, req.count, AT_SWORN_CHANGE_PREFIX)
		g_i3k_ui_mgr:CloseUI(eUIID_SwornChangeName)
		local callback = function(data, roleData)
			g_i3k_logic:OpenSwornModifyUI(data, roleData)
		end
		i3k_sbean.sworn_sync(callback)
	elseif errorString[res.ok] then
		g_i3k_ui_mgr:PopupTipMessage(errorString[res.ok])
	end
end

--修改结拜后缀
function i3k_sbean.sworn_change_suffix(suffix, count)
	--<field name="suffix" type="string"/>
	local data = i3k_sbean.sworn_change_suffix_req.new()
	data.suffix = suffix
	data.count = count
	i3k_game_send_str_cmd(data, "sworn_change_suffix_res")
end

function i3k_sbean.sworn_change_suffix_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseCommonItem(g_BASE_ITEM_DIAMOND, req.count, AT_SWORN_CHANGE_SUFFIX)
		g_i3k_ui_mgr:CloseUI(eUIID_SwornChangeName)
		local callback = function(data, roleData)
			g_i3k_logic:OpenSwornModifyUI(data, roleData)
		end
		i3k_sbean.sworn_sync(callback)
	elseif errorString[res.ok] then
		g_i3k_ui_mgr:PopupTipMessage(errorString[res.ok])
	end
end

--领取结拜活跃奖励
function i3k_sbean.sworn_activity_reward_take(activity)
	--<field name="activity" type="int32"/>
	local data = i3k_sbean.sworn_activity_reward_take_req.new()
	data.activity = activity
	i3k_game_send_str_cmd(data, "sworn_activity_reward_take_res")
end

function i3k_sbean.sworn_activity_reward_take_res.handler(res, req)
	if res.ok > 0 then
		local items = {}
		for k, v in pairs(res.drops) do
			table.insert(items, {id = k, count = v})
		end
		g_i3k_ui_mgr:ShowGainItemInfo(items)
		local callback = function(data, roleData)
			g_i3k_ui_mgr:RefreshUI(eUIID_SwornModify, data, roleData)
			g_i3k_game_context:forwardSync(data, roleData)
		end
		i3k_sbean.sworn_sync(callback)
	elseif errorString[res.ok] then
		g_i3k_ui_mgr:PopupTipMessage(errorString[res.ok])
	end
end

--一键招募
function i3k_sbean.one_key_summond_sworn_friends()
	local data = i3k_sbean.one_key_summond_sworn_member.new()
	i3k_game_send_str_cmd(data)
end

--退出结拜
function i3k_sbean.sworn_leave()
	local data = i3k_sbean.sworn_leave_req.new()
	i3k_game_send_str_cmd(data, "sworn_leave_res")
end

function i3k_sbean.sworn_leave_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:changeSwornFriends(false)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5405))
	elseif errorString[res.ok] then
		g_i3k_ui_mgr:PopupTipMessage(errorString[res.ok])
	end
end

--结拜解散推送
function i3k_sbean.sworn_leave_push.handler(res)
	g_i3k_game_context:changeSwornFriends(false)
end

--退出结拜操作通知
function i3k_sbean.sworn_step_early_end_push.handler(res)
	if res.roleId == g_i3k_game_context:GetRoleId() then
		g_i3k_game_context:changeSwornFriends(false)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5405))
	end
	--self.roleId:		int32	
	--self.errorCode:		int32	
end

--助战领奖
function i3k_sbean.sworn_help_map_reward_take(times)
	local data = i3k_sbean.sworn_help_map_reward_take_req.new()
	data.times = times
	i3k_game_send_str_cmd(data, "sworn_help_map_reward_take_res")
end

function i3k_sbean.sworn_help_map_reward_take_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo({{id = i3k_db_sworn_system.helpFightRewardId, count = req.times}})
		local callback = function(data, roleData)
			g_i3k_ui_mgr:OpenUI(eUIID_SwornModify)
			g_i3k_ui_mgr:RefreshUI(eUIID_SwornModify, data, roleData)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SwornModify, "onCallBtn", nil)
		end
		i3k_sbean.sworn_sync(callback)
	elseif errorString[res.ok] then
		g_i3k_ui_mgr:PopupTipMessage(errorString[res.ok])
	end
end

--登陆同步角色结拜存储
function i3k_sbean.login_sync_sworn_role_data.handler(res)
	for k, v in pairs(res.data.dayPublicMapHelpTimes) do
		g_i3k_game_context:addDungeonEnterTimes(k, v)
	end
	for k, v in pairs(res.data.dayNpcMapHelpTimes) do
		g_i3k_game_context:addNpcDungeonEnterTimes(k, v)
	end
end

--同步结拜助战完成次数
function i3k_sbean.login_sync_sworn_help_times.handler(res)
	for k, v in pairs(res.mapTimes.npcMapTimes) do
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_ZHENGYIZHIXIN_2, k, v)
		g_i3k_game_context:addNpcDungeonEnterTimes(k, v)
	end
	for k, v in pairs(res.mapTimes.publicMapTimes) do
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_GROUP, k, v)
		g_i3k_game_context:addDungeonEnterTimes(k, v)
	end
end

--结拜退出操作
function i3k_sbean.sworn_step()
	local data = i3k_sbean.sworn_step_end.new()
	data.errorCode = 0
	i3k_game_send_str_cmd(data)
end

--结拜退出操作推送
function i3k_sbean.sworn_step_early_end_push.handler(res)
	g_i3k_ui_mgr:CloseUI(eUIID_SwornDate)
	g_i3k_ui_mgr:CloseUI(eUIID_SetSwornPrefix)
end
--修改结拜寄语
function i3k_sbean.change_sworn_message(msg)
	local data = i3k_sbean.set_gift_string_req.new()
	data.giftString = msg
	i3k_game_send_str_cmd(data, "set_gift_string_res")
end
function i3k_sbean.set_gift_string_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseDiamond(i3k_db_sworn_system.msgChangeCost)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16940))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_JinLanPu, 'changeMsg', req.giftString)
		g_i3k_ui_mgr:CloseUI(eUIID_JinLanChangeMessage)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5030))
	end
end
--获取金兰谱
function i3k_sbean.get_sworn_card(ID, ours, owner)
	local data = i3k_sbean.sworn_card_sync_req.new()
	data.id = ID
	data.ours = ours
	data.owner = owner
	i3k_game_send_str_cmd(data, "sworn_card_sync_res")
end

function i3k_sbean.sworn_card_sync_res.handler(res, req)
	g_i3k_ui_mgr:OpenAndRefresh(eUIID_JinLanPu, res.card, req.ours, req.owner)
end

--点赞金兰谱
function i3k_sbean.sworn_card_like(ID)
	local data = i3k_sbean.sworn_card_sign_req.new()
	data.id = ID
	i3k_game_send_str_cmd(data, "sworn_card_sign_res")
end
function i3k_sbean.sworn_card_sign_res.handler(res)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16908))
		g_i3k_game_context:UseCommonItem(i3k_db_sworn_system.likeNeedItem, 1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_JinLanPu, "updateText")
	else
		g_i3k_ui_mgr:PopupTipMessage("点赞失败，错误码："..res.ok)	--
	end
end
--领取金兰任务奖励
function i3k_sbean.get_achi_reward(_,_, arg)
	local data = i3k_sbean.finish_achievement_task_req.new()
	data.id = arg.id
	data.acp = arg.acp
	i3k_game_send_str_cmd(data, "finish_achievement_task_res")
end
function i3k_sbean.finish_achievement_task_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5523, req.acp))	
		g_i3k_game_context:syncData(function()
			g_i3k_ui_mgr:RefreshUI(eUIID_JinLanAchievement)
		end)
	else
		g_i3k_ui_mgr:PopupTipMessage("获取奖励失败，错误码:"..res.ok)
	end
end
--领取金兰成就奖励
function i3k_sbean.get_achi_point_reward(Point, items)
	local data = i3k_sbean.take_achievement_point_reward_req.new()
	data.point = Point
	data.items = items
	i3k_game_send_str_cmd(data, "take_achievement_point_reward_res")
end
function i3k_sbean.take_achievement_point_reward_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:syncData(function()
			g_i3k_ui_mgr:RefreshUI(eUIID_JinLanAchievement)
		end)
		g_i3k_ui_mgr:ShowGainItemInfo(req.items)
	else
		g_i3k_ui_mgr:PopupTipMessage("获取奖励失败，错误码："..res.ok)
	end
end
--金兰任务成就活跃度红点推送
function i3k_sbean.sworn_point.handler()
	g_i3k_game_context.push = true
end
--[[
--把被转发的回调转发到目标回调，并且从被转发的回调的第一个参数中获取字段作为目标回调的参数
--#1 转发的目标回调 #2 要获取的被转发回调第一个参数的所有字段
--returns 被转发的回调
local function fw(cb, ...)
	local names = {...}
	local forwardFunciton = function(data)
		local fields = {}
		for _, v in ipairs(names) do
			table.insert(fields, utils.switchNil(data[v]))
		end
		if cb then
			return cb(utils.rcsReturn(fields, 1))
		end
	end
	return forwardFunciton
end
--获取请求对象
--#1 请求协议名称 #2 请求数据表 
local function feed(protocal, form)
	local req = i3k_sbean[protocal].new()
	for k, v in pairs(form) do
		req[k] = v
	end
	return req
end
--使用通用响应逻辑（即只使用回调作为响应）,如果回调不返回-1则继续给静态响应函数处理
--如果存在转发字段，则提取响应对应的字段作为回调的参数，否则使用响应本身作为回调参数
--#1 请求协议名称 #2 请求数据表 #3 响应协议名称 #4 响应回调，如果返回-1则不调用静态响应函数 #5 转发字段
function i3k_sbean.shoot(reqName, form, resName, cb, ...)
	local req = feed(reqName, form)
	local fields = {...}
	if #fields > 0 then 
		req.general_handler_callback = fw(cb, ...)
	else
		req.general_handler_callback = cb
	end
	local staticHandler = i3k_sbean[resName].handler
	i3k_sbean[resName].handler = function(res, sendReq)
		local callStaticHandler = true
		if sendReq.general_handler_callback then
			if sendReq.general_handler_callback(res) == -1 then
				callStaticHandler = false
			end
		end
		if callStaticHandler then
			sendReq.general_handler_callback = nil
			if staticHandler then staticHandler(res, sendReq) end
		end
		i3k_sbean[resName].handler = staticHandler or function() end	--清理请求回调
	end
	i3k_game_send_str_cmd(req, resName)
end

	--]]
