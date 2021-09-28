------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------

g_HOT_SPRING_NOT_OPEN				= -1  --活动没开
g_HOT_SPRING_NO_ENOUGH_CNT			= -2  --没有次数
g_HOT_SPRING_NOT_NEARBY				= -3  --距离不够
g_HOT_SPRING_BEUSED_ROLE_NO_CNT		= -4  --被使用的人没有次数
g_HOT_SPRING_DAY_MAX_CNT			= -5  --当日最大次数
g_HOT_SPRING_IN_DOUBLE_ACT			= -6  --自己已经在双人状态
g_HOT_SPRING_OTHER_IN_DOUBLE_ACT 	= -7  --别人在双人状态
g_HOT_SPRING_REFUSE 				= -8  --拒绝
g_HOT_SPRING_BUSY					= -9  --正忙
g_HOT_SRPING_CANCLE					= -10 --对方取消邀请
g_HOT_SRPING_TIMEOUT				= -11 --邀请超时
g_HOT_SPRING_MY_WEEKLY_NO_CNT		= -12 --自己没有周次数
g_HOT_SPRING_OTHER_WEEKLY_NO_CNT	= -13 --对方没有周次数
g_HOT_SPRING_WAS_BANED_INTER_ACT	= -14 --被对方拉黑并且禁止互动了
local function dealError (bean)
	---1 活动没开   -2没有次数  -3距离不够  -4被使用的人没有次数   -5当日最大次数
	if bean.ok == g_HOT_SPRING_NOT_OPEN then
		g_i3k_ui_mgr:PopupTipMessage("活动没开")
	elseif bean.ok == g_HOT_SPRING_NO_ENOUGH_CNT then
		g_i3k_ui_mgr:PopupTipMessage("没有次数")
	elseif bean.ok == g_HOT_SPRING_NOT_NEARBY then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3172))
	elseif bean.ok == g_HOT_SPRING_BEUSED_ROLE_NO_CNT then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3162))
	elseif bean.ok == g_HOT_SPRING_DAY_MAX_CNT then
		g_i3k_ui_mgr:PopupTipMessage("当日最大次数")
	elseif bean.ok == g_HOT_SRPING_CANCLE then
		g_i3k_ui_mgr:PopupTipMessage("对方取消了邀请")
	elseif bean.ok == g_HOT_SRPING_TIMEOUT then
		g_i3k_ui_mgr:PopupTipMessage("邀请已经超时")
	elseif bean.ok == g_HOT_SPRING_OTHER_IN_DOUBLE_ACT then
		g_i3k_ui_mgr:PopupTipMessage("对方正在双人互动状态")
	elseif bean.ok == g_HOT_SPRING_MY_WEEKLY_NO_CNT then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17286))
	elseif bean.ok == g_HOT_SPRING_OTHER_WEEKLY_NO_CNT then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17287))
	elseif bean.ok == g_HOT_SPRING_WAS_BANED_INTER_ACT then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17733))
	elseif bean.ok == 0 then
		g_i3k_ui_mgr:PopupTipMessage("操作失败")
	end

end
--泡温泉使用单人动作 (actType   1=调戏   2=肥皂  3=搓澡)
function i3k_sbean.request_hot_spring_use_single_act_req(actType, beUseRid,callback)
	local data = i3k_sbean.hot_spring_use_single_act_req.new()
	data.actType = actType
	data.beUseRid = beUseRid
	data.callback = callback
	i3k_game_send_str_cmd(data, "hot_spring_use_single_act_res")
end

function i3k_sbean.hot_spring_use_single_act_res.handler(bean,req)
    --<field name="ok" type="int32"/>
	dealError(bean)
	if bean.ok == 1 then
		if req.callback then
			req.callback()
		end

		local hero = i3k_game_get_player_hero()
		local alist = {}

		if req.actType == 1 then
			if hero:IsInWater() then
                table.insert(alist, {actionName = i3k_db_spring.common.tiaoxiAct1, actloopTimes = 1})
			else
                table.insert(alist, {actionName = i3k_db_spring.common.tiaoxiAct2, actloopTimes = 1})
			end
		elseif req.actType == 2 then
			if hero:IsInWater() then
                table.insert(alist, {actionName = i3k_db_spring.common.feizaoAct1, actloopTimes = 1})
			else
				table.insert(alist, {actionName = i3k_db_spring.common.feizaoAct2, actloopTimes = 1})
			end
		elseif req.actType == 3 then
			if hero:IsInWater() then
                table.insert(alist, {actionName = i3k_db_spring.common.cuozaoAct1, actloopTimes = 1})
			else
                table.insert(alist, {actionName = i3k_db_spring.common.cuozaoAct2, actloopTimes = 1})
			end
		end
		if hero:IsInWater() then
            table.insert(alist, {actionName = i3k_db_spring.common.waterIdle, actloopTimes = -1})
		else
            table.insert(alist, {actionName = i3k_db_spring.common.landIdle, actloopTimes = -1})
		end

		hero:PlayActionList(alist, 1)
	end
end

--泡温泉使用双人动作 (actType  1=船  2=伞)
function i3k_sbean.request_hot_spring_use_double_act_req(actType, beUsedRid, name)
	if g_i3k_game_context:IsBlackListBaned(beUsedRid) then
		g_i3k_game_context:PopupTipMessage(17732)
		return
	end
	local data = i3k_sbean.hot_spring_use_double_act_req.new()
	data.actType = actType
	data.beUsedRid = beUsedRid
	data.name = name
	i3k_game_send_str_cmd(data, "hot_spring_use_double_act_res")
end

function i3k_sbean.hot_spring_use_double_act_res.handler(bean, req)
	dealError(bean)
	if bean.ok == 1 then
		g_i3k_ui_mgr:ShowSpringInvite("取消邀请",i3k_get_string(3183, req.name),false, function  ()
			g_i3k_ui_mgr:CloseUI(eUIID_SpringInvite)
			i3k_sbean.request_hot_spring_cancel_invite(req.beUsedRid)
		end)
	end
end

--温泉祝福 1全服 2帮派
function i3k_sbean.request_hot_spring_use_buff_req(buffType,callback)
	local data = i3k_sbean.hot_spring_use_buff_req.new()
	data.buffType = buffType
	data.callback = callback
	i3k_game_send_str_cmd(data, "hot_spring_use_buff_res")
end

function i3k_sbean.hot_spring_use_buff_res.handler(bean, req)
	dealError(bean)
	if bean.ok == 1 then
		if req.callback then
			req.callback()
		end
	end
end

--同步泡温泉的次数
function i3k_sbean.hot_spring_sync_cnt.handler(bean)
	g_i3k_game_context:setSpringData(bean)
end
--泡温泉周围玩家开始单人动作
function i3k_sbean.hot_spring_nearby_start_single_act.handler(bean)
	--self.actType:		int32
	--self.actRid:		int32
	--self.actRname:		string
	--self.beusedRie:		int32
	--self.beusedRname:		string
	 --(actType   1=调戏   2=肥皂  3=搓澡)
	local world = i3k_game_get_world()
	if world then
		local targetEntity = world:GetEntity(eET_Player, bean.actRid)
		if targetEntity then
			local beusedEntity = world:GetEntity(eET_Player, bean.beusedRie)
			if beusedEntity then
				local p1 = targetEntity._curPos;
				local p2 = beusedEntity._curPos;
				local rot_y = i3k_vec3_angle1(p2,p1,{ x = 1, y = 0, z = 0 });
				targetEntity:SetFaceDir(0, rot_y, 0);
			end

			local targetSpringPos = g_i3k_game_context:getSpringPos(targetEntity._curPosE)

			local alist = {}
			if bean.actType == 1 then
				if targetSpringPos == SPRING_TYPE_WATER then
                    table.insert(alist, {actionName = i3k_db_spring.common.tiaoxiAct1, actloopTimes = 1})
				else
                    table.insert(alist, {actionName = i3k_db_spring.common.tiaoxiAct2, actloopTimes = 1})
				end
			elseif bean.actType == 2 then
				if targetSpringPos == SPRING_TYPE_WATER then
                    table.insert(alist, {actionName = i3k_db_spring.common.feizaoAct1, actloopTimes = 1})
				else
                    table.insert(alist, {actionName = i3k_db_spring.common.feizaoAct2, actloopTimes = 1})
				end
			elseif bean.actType == 3 then
				if targetSpringPos == SPRING_TYPE_WATER then
                    table.insert(alist, {actionName = i3k_db_spring.common.cuozaoAct1, actloopTimes = 1})
				else
                    table.insert(alist, {actionName = i3k_db_spring.common.cuozaoAct2, actloopTimes = 1})
				end
			end

			if targetSpringPos == SPRING_TYPE_WATER then
                table.insert(alist, {actionName = i3k_db_spring.common.waterIdle, actloopTimes = -1})
			else
                table.insert(alist, {actionName = i3k_db_spring.common.landIdle, actloopTimes = -1})
			end
			targetEntity:PlayActionList(alist, 1)
		end
	end
end

--温泉buff推送
function i3k_sbean.hot_spring_buff_sync.handler(bean)
	g_i3k_game_context:setSpringBuff(bean)
end

--使用buff提示
function i3k_sbean.hot_spring_use_buff_tip.handler (bean)
	--self.buffType:		int32 1 世界 2帮派
	--self.useRid:		int32
	--self.useRname:		string
	--self.sectId:		int32
	--self.buffValue:		int32
	if bean.buffType == 1 then
		--世界祝福
		local str = i3k_get_string(3155, bean.useRname, (bean.buffValue / 100))
		g_i3k_ui_mgr:PopupTipMessage(str)
		g_i3k_game_context:ShowSysMessage(str,"温泉",0,0)
	elseif bean.buffType == 2 then
		--帮派祝福
		local str = i3k_get_string(3156, bean.useRname, bean.sectName, (bean.buffValue / 100))
		g_i3k_ui_mgr:PopupTipMessage(str)
		if g_i3k_game_context:GetFactionSectId() ~= 0 and g_i3k_game_context:GetSectName() == bean.sectName then
			local message = {}
			message.time = i3k_game_get_time()
			message.type = global_sect
			message.fromName = "温泉"

			message.isSectSpring = true
			message.iconId = 2426
			message.fromId = 2
			message.bwType = 0
			message.msgType = 0

			message.msg = str
			g_i3k_game_context:SetChatData(message,global_sect)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Chat, "receiveNewMsg", message)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "receiveNewMsg", message)
		end
	end
end

---------------------------------------------------------------------
--泡温泉双人动作请求
function i3k_sbean.hot_spring_double_act_forward.handler(bean)
	local roleID = bean.useRid
	local roleName = bean.useRname
	local actType = bean.type
	local msg = i3k_get_string(3184, roleName)
	local function callback(isOk)
		if isOk then
			local hero = i3k_game_get_player_hero()
			if hero and hero._behavior:Test(eEBMove) then
				g_i3k_ui_mgr:PopupTipMessage("移动中不能进行双人互动")
				return
			end
			i3k_sbean.request_hot_spring_double_act_answer_req(roleID, roleName, actType, 1) --同意
		else
			i3k_sbean.request_hot_spring_double_act_answer_req(roleID, roleName, actType, g_HOT_SPRING_REFUSE) --拒绝
		end
		g_i3k_ui_mgr:CloseUI(eUIID_SpringInvite)
	end
	if not g_i3k_ui_mgr:ShowSpringInvite("同意邀请",msg, true, callback) then
		i3k_sbean.request_hot_spring_double_act_answer_req(roleID, roleName, actType, g_HOT_SPRING_BUSY)
	end
end

--泡温泉使用双人动作应答 (answer 1=同意   -8=拒绝)
function i3k_sbean.request_hot_spring_double_act_answer_req(useRid, useRname, actType, answer)
	local data = i3k_sbean.hot_spring_double_act_answer_req.new()
	data.answer = answer
	data.useRid = useRid
	data.useRname = useRname
	data.actType = actType
	i3k_game_send_str_cmd(data, "hot_spring_double_act_answer_res")
end

function i3k_sbean.hot_spring_double_act_answer_res.handler(bean)
	dealError(bean)
end

--泡温泉双人动作应答推送
function i3k_sbean.hot_spring_double_act_answer_forward.handler(bean)
	g_i3k_ui_mgr:CloseUI(eUIID_SpringInvite)
	local isOk = bean.ok
	if isOk == 1 then
		g_i3k_game_context:UseCommonItem(i3k_db_spring.common.costItem,1,AT_SPRING_USE_DOUBLEACT)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpringAct,"setDoubleActNum")
	end
	local roleName = bean.beusedRname
	if isOk == g_HOT_SPRING_BUSY then
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s正忙", roleName))
	elseif isOk == g_HOT_SPRING_REFUSE then
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s拒绝了你的邀请", roleName))
	elseif isOk == g_HOT_SPRING_OTHER_IN_DOUBLE_ACT then
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s正在双人互动状态", roleName))
	elseif isOk == g_HOT_SPRING_NOT_NEARBY then
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s距离太远", roleName))
	end
end

-- 取消双人互动
function i3k_sbean.hot_spring_cancel_double_act(callBack)
	local data = i3k_sbean.hot_spring_cancel_double_act_req.new()
	data.callBack = callBack
	--i3k_log("hot_spring_cancel_double_act_req"..g_i3k_game_context:GetRoleId())
	i3k_game_send_str_cmd(data, "hot_spring_cancel_double_act_res")
end

function i3k_sbean.hot_spring_cancel_double_act_res.handler(bean, req)
	if bean.ok == 1 then
		if req.callBack then
			req.callBack()
		end
	end
end

--取消双人互动邀请
function i3k_sbean.request_hot_spring_cancel_invite(beUseRid)
	local data = i3k_sbean.hot_spring_cancel_invite.new()
	data.beUseRid = beUseRid
	i3k_game_send_str_cmd(data)
end

--取消双人互动邀请推送
function i3k_sbean.hot_spring_cancel_invite_forward.handler (bean)
	local useRid = bean.useRid
	g_i3k_ui_mgr:CloseUI(eUIID_SpringInvite)
	g_i3k_ui_mgr:PopupTipMessage("对方取消了邀请")
end

--同步温泉周入场次数
function i3k_sbean.hot_spring_week_enter_cnt.handler(bean)
	g_i3k_game_context:setSpringWeeklyTimes(bean.cnt)
end
--获取温泉祝福榜
function i3k_sbean.query_spring_buff_rank(rank_type)
	local bean = i3k_sbean.hot_spring_buff_rank_req.new()
	bean.rankType = rank_type
	i3k_game_send_str_cmd(bean,i3k_sbean.hot_spring_buff_rank_res.getName())
end
function i3k_sbean.hot_spring_buff_rank_res.handler(res,req)
	if res then
		g_i3k_ui_mgr:OpenUI(eUIID_SpringBuffRank)
		g_i3k_ui_mgr:RefreshUI(eUIID_SpringBuffRank,res)
	end
end
