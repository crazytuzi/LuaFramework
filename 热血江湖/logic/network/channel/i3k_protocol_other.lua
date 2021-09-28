------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")


-----------------------------------发送消息的响应-------------------------------
function i3k_sbean.world_msg_send_req(msg)
	local send = i3k_sbean.msg_send_req.new()

	send.type = global_world
	send.id = g_i3k_game_context:GetRoleId()
	send.msg = msg
	send.gsName = i3k_game_get_server_name(i3k_game_get_login_server_id())
	i3k_game_send_str_cmd(send, i3k_sbean.msg_send_res.getName())
end

function i3k_sbean.msg_send_res.handler(bean, res)
	local result = bean.ok
	if result == 1 and res then
		local function startWith(msg, str)
			local signLetter = string.sub(msg, 1, #str)
			return str == signLetter
		end
		if res.isShareJinlanCard then 
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16910)) 
			g_i3k_ui_mgr:CloseUI(eUIID_JinLanShare)
		end
		if startWith(res.msg, "#ROLL") then
			g_i3k_game_context:setRollSendTime(i3k_game_get_time())
			if res.type == 6 then
				local needItemId = i3k_db_common.chat.spanNeedId
				g_i3k_game_context:UseCommonItem(needItemId,1,AT_USE_CHAT_ITEM)
				g_i3k_ui_mgr:CloseUI(eUIID_SpanTips)
				local cfg = g_i3k_game_context:GetUserCfg()
  				if res.isTips then
  					if res.isTips == 0 then
  						cfg:SetIsSpanTips(0)
  					end
  				end
			end
		elseif res.type == 4 then
			g_i3k_game_context:SetPriviteSendTime(i3k_game_get_time())--os.time())
			local priviteChatUI = g_i3k_ui_mgr:GetUI(eUIID_PriviteChat)
			if priviteChatUI then
				local editBox = priviteChatUI:GetChildByVarName("editBox")
				if editBox then
					editBox:setText("")
				end
			end
		else
			if res.type == 1 then
				if res.msg == "@#i3k" then
					g_i3k_ui_mgr:OpenUI(eUIID_GMEntrance)
					g_i3k_ui_mgr:RefreshUI(eUIID_GMEntrance)
					g_i3k_game_context:setBackstageBtn(true)
				else
					local index = string.find(res.msg, "@#settime")
					local index2 = string.find(res.msg, "@#settimeoffset")
					if index or index2 then
						i3k_sbean.world_msg_send_req("@#showtimeoffset")
					end
					if res.isRoom then
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15340))
					end
					g_i3k_game_context:SetWorldSendTime(i3k_game_get_time())
					if string.sub(res.msg,0,2)~="@#" then
						local needItemId = i3k_db_common.chat.worldNeedId                   --消耗大喇叭
						if not res.isShowLove then
							g_i3k_game_context:UseCommonItem(needItemId,1,AT_USE_CHAT_ITEM)
						end
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_Chat, "updatelb")
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_AnswerQuestions, "updatelb")
					end
				end
			elseif res.type == 2 then
				g_i3k_game_context:SetSectSendTime(i3k_game_get_time())
			elseif res.type == 3 then
				g_i3k_game_context:SetTeamSendTime(i3k_game_get_time())
			elseif res.type == 6 then
				g_i3k_game_context:SetSpanSendTime(i3k_game_get_time())
				g_i3k_ui_mgr:CloseUI(eUIID_SpanTips)
				local cfg = g_i3k_game_context:GetUserCfg()
  				if res.isTips then
  					if res.isTips == 0 then
  						cfg:SetIsSpanTips(0)
  					end
  				end
				if string.sub(res.msg,0,2)~="@#" then
					local needItemId = i3k_db_common.chat.spanNeedId
					if not res.isShowLove then
						g_i3k_game_context:UseCommonItem(needItemId,1,AT_USE_CHAT_ITEM)
					end
				end
			end
			local chatUI = g_i3k_ui_mgr:GetUI(eUIID_Chat)
			if chatUI then
				local editBox = chatUI:GetChildByVarName("editBox")
				if editBox then
					editBox:setText("")
				end
			end
		end
		if res.callback then
			res.callback()
		end
	else
		local mapType = i3k_game_get_map_type()
		if mapType ~= g_FIELD then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(764))
			return
		end
		--if g_i3k_game_context:GetPrivateChatUIOpenState() then
		if result == -1 then
			g_i3k_ui_mgr:PopupTipMessage("您已被禁言")
		elseif  result == -2 then
			g_i3k_ui_mgr:PopupTipMessage("所需道具不足")
		elseif  result == -3 then
			g_i3k_ui_mgr:PopupTipMessage("处于聊天冷却时间中，请稍后重试")
		elseif  result == -4 then
			g_i3k_ui_mgr:PopupTipMessage("您的好友当前不线上，无法发送消息")
		elseif  result == -5 then
			g_i3k_ui_mgr:PopupTipMessage("私聊物件将您加入黑名单，无法聊天")
		elseif  result == -6 then
			g_i3k_ui_mgr:PopupTipMessage("处在错误区域")
		elseif  result == -7 then
			g_i3k_ui_mgr:PopupTipMessage("VIP等级不足")
		elseif  result == -8 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3021))
		elseif result == -9 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3048))
		elseif result == -10 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(978))
		elseif result == -11 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(981))
		elseif result == -100 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1324))
		elseif result == -14 then
			g_i3k_ui_mgr:PopupTipMessage("此类消息不支援跨服发送")
		elseif result == -404 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1566))
		else
			g_i3k_ui_mgr:PopupTipMessage("消息发送失败")
		end

	end
end


-- 进入大地图传送点响应
--Packet:waypoint_enter_res
function i3k_sbean.waypoint_enter_res.handler(bean,req)
	local is_ok = bean.ok
	if is_ok == 1 then
		if req.__callback then
			req.__callback()
		end
		local mId, value = g_i3k_game_context:getMainTaskIdAndVlaue()
		local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(mId)
		if main_task_cfg.type == g_TASK_GATE_POINT and main_task_cfg.arg1 == req.wid and value ~= 1 then
			g_i3k_game_context:setMainTaskIdAndValue(mId,req.wid)
		end
		g_i3k_game_context:SetTaskDataByTaskType(req.wid, g_TASK_GATE_POINT)
	end
	g_i3k_game_context:SetTransferState(false)
end

--PK模式切换
--Packet:set_attackmode_req
function i3k_sbean.set_attackmode(mode)---0:和平,1:自由,2:善恶,3:帮派
	local bean = i3k_sbean.set_attackmode_req.new()
	bean.mode = mode;
	i3k_game_send_str_cmd(bean,i3k_sbean.set_attackmode_res.getName())
end

--Packet:set_attackmode_res
function i3k_sbean.set_attackmode_res.handler(bean, req)
	local nflag = bean.ok;
	local mode = req.mode;
	if nflag == 1 then
		local logic = i3k_game_get_logic();
		if logic then
			local player = logic:GetPlayer();
			if player then
				local hero = player:GetHero()
				local world = logic:GetWorld();
				if hero and world then
					hero:SetPVPStatus(mode)
					world:UpdatePKState(hero, mode);
					local selEntity = logic._selectEntity;
					if selEntity then
						if selEntity:GetEntityType() ~= eET_NPC then
							logic:SwitchSelectEntity(nil)
							hero:UpdateAlives()
							logic:SwitchSelectEntity(selEntity)
							if hero._onTargetChanged then
								hero._onTargetChanged(selEntity);
							end
						end

					end
					local MercenaryCount =  player:GetMercenaryCount()
					for i = 1,MercenaryCount do
						local mercenary = player:GetMercenary(i);
						if mercenary then
							world:UpdatePKState(mercenary, mode);
							mercenary:ClsEnmities()
						end
					end
					g_i3k_ui_mgr:CloseUI(eUIID_PKMode);
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5765))
				end
			end
		end
	end
	return true;
end
--太玄碑文数量变化
function i3k_sbean.role_stele_card.handler(bean)
	g_i3k_game_context:updateSteleCard(bean.card)
end
-- 请求挖矿的响应协议
--Packet:role_mine_req
function i3k_sbean.role_mine(cfgID, RoleID)
	local bean = i3k_sbean.role_mine_req.new()
	bean.mineId = cfgID
	bean.mineInstance = RoleID
	i3k_game_send_str_cmd(bean,i3k_sbean.role_mine_res.getName())
end
-- 请求挖矿的响应协议
--Packet:role_mine_res
function i3k_sbean.role_mine_res.handler(bean, res)
	if bean.ok == 1 then
		-- local mineID = tonumber(res.mineInstance)
		-- local logic = i3k_game_get_logic();
		-- local world = logic:GetWorld();
		-- local player = logic:GetPlayer();
		-- local hero = player:GetHero();
		-- if world then
		-- 	hero:SetDigStatus(2)
		-- 	local mine = world._ResourcePoints[mineID]
		-- 	if mine and mine._gcfg then
		-- 		local action = mine._gcfg.Action;
		-- 		if action then
		-- 			hero:Play(action, -1);
		-- 		end
		-- 		mine:playCollectedAction()
		-- 		if mine._gcfg.bToolexpend == 1 then
		-- 			g_i3k_game_context:UseCommonItem(mine._gcfg.nTool,1,AT_TRY_START_MINE)
		-- 		end
		-- 	end
		-- end
		local mineID = tonumber(res.mineInstance)
		local logic = i3k_game_get_logic()
		local world = logic:GetWorld()
		local mine = world._ResourcePoints[mineID]
		if mine and mine._gcfg then
			if mine._gcfg.bToolexpend == 1 then
				g_i3k_game_context:UseCommonItem(mine._gcfg.nTool, 1, AT_TRY_START_MINE)
			end
		end
	elseif bean.ok == -101 then
		local tmp_str = i3k_get_string(773)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
	elseif bean.ok == -102 then
		local tmp_str = i3k_get_string(774)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
	elseif bean.ok == -103 then
		local tmp_str = i3k_get_string(775,i3k_db_faction_rob_flag.faction_rob_flag.faction_role_lvl)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
	elseif bean.ok == -104 then
		local tmp_str = i3k_get_string(776,i3k_db_faction_rob_flag.faction_rob_flag.faction_join_lvl)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
	elseif bean.ok == -105 then
		local tmp_time = i3k_db_faction_rob_flag.faction_rob_flag.faction_rob_join_time
		tmp_time = tmp_time /(60*60)
		tmp_time = string.format("%s小时",tmp_time)
		local tmp_str = i3k_get_string(777,tmp_time)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
	elseif bean.ok == -106 then
		local tmp_str = i3k_get_string(778)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
	elseif bean.ok == -107 then
		local tmp_str = i3k_get_string(779)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
	elseif bean.ok == -108 then
		local tmp_str = i3k_get_string(780,i3k_db_faction_rob_flag.faction_rob_flag.faction_rob_count)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
	elseif bean.ok == -201 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(843))
	elseif bean.ok == -202 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(844))
	elseif bean.ok == -301 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(886))
	elseif bean.ok == -302 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(887))
	elseif bean.ok == -303 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(888))
	elseif bean.ok == -304 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15341))
		g_i3k_game_context:NotCanMineralStela()
	elseif bean.ok == -305 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(890))
	end
end

-- 转职
function i3k_sbean.role_transform_res.handler(bean,req)
	local is_ok = bean.ok
	if is_ok == 1 then
		g_i3k_game_context:SetPrePower()
		local lvl = tonumber(req.tlvl)
		local _type = tonumber(req.bwType)

		local roletype = g_i3k_game_context:GetRoleType()
		local _t = i3k_db_zhuanzhi[roletype][lvl][_type]

		local skill1 = _t.skill1
		local skill2 = _t.skill2
		--更新数据
		if skill1 ~= 0 then
			g_i3k_game_context:SetRoleSkillLevel(skill1,1)
		end
		if skill2 ~= 0 then
			g_i3k_game_context:SetRoleSkillLevel(skill2,1)
		end
		g_i3k_game_context:SetTransformLvl(lvl)
		g_i3k_game_context:SetTransformBWtype(_type)
		g_i3k_game_context:UpdateSubLineTaskValue(g_TASK_TRANSFER,lvl)
		g_i3k_game_context:UpdateMainTaskValue(g_TASK_TRANSFER, lvl)

		g_i3k_game_context:checkSubLineTaskIsLock()

		local hero = i3k_game_get_player_hero()
		if hero then
			hero:InitSkills(false)
			hero:UpdateProfessionProps();
			hero:SetBWType(req.bwType)
		end
		--转职消耗物品刷新
		for i=1,2 do
			local tempid = "item"..i.."ID"
			local itemid =_t[tempid]
			local tempCount ="item"..i.."Count"
			local itemCount = _t[tempCount]
			g_i3k_game_context:UseCommonItem(itemid,itemCount,AT_TRANSFORM)
		end
		--转职成功提示
		local new_job_name = i3k_db_zhuanzhi[roletype][lvl][_type].name;
		g_i3k_ui_mgr:OpenUI(eUIID_TransfromAnimate)
		g_i3k_ui_mgr:RefreshUI(eUIID_TransfromAnimate, new_job_name)
		--battle页面
		g_i3k_game_context:ReCheckAllBatterEquip()
		g_i3k_game_context:ShowPowerChange()
		g_i3k_game_context:LeadCheck(eLTEventTransLvlChange);
		g_i3k_game_context:PlotCheck(eLTEventTransLvlChange);
		local iconShow, redShow = g_i3k_game_context:TestBagShowState()
		g_i3k_game_context:OnBagShowStateChangedHandler(iconShow, redShow)
	end
end

function i3k_sbean.checkin_sync()
	local data = i3k_sbean.checkin_sync_req.new()
	i3k_game_send_str_cmd(data,"checkin_sync_res")
end

function i3k_sbean.checkin_sync_res.handler(bean,req)
	local info = bean.info
	if info then
		local finishedDays = info.finishedDays
		local checkinId = info.checkinId
		local monthCfg = i3k_db_sign[checkinId]
		local canCheckIn = info.canCheckIn
		--g_i3k_ui_mgr:OpenUI(eUIID_SignIn)
		--g_i3k_ui_mgr:RefreshUI(eUIID_SignIn,finishedDays,checkinId,monthCfg,canCheckIn)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli,"updateSingInInfo",finishedDays,checkinId,monthCfg,canCheckIn, bean.additional)
	end
end

function i3k_sbean.checkin_take_res.handler(bean,req)
	local is_ok = bean.ok
	if is_ok > 0 then
		if is_ok == 2 then
			if req.__solarTermCallback then
				req.__solarTermCallback()
			end
		else
		if req.__callback then
			req.__callback()
			end
		end
		--local ui = g_i3k_ui_mgr:InvokeUIFunction(eUIID_SignIn,"updateDesc",req.times)
		--g_i3k_game_context:SetSignInData(req.times)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli,"hideQianDaoRedPoint")
--		g_i3k_game_context:RemoveFuliRedPointCount(1)
	end
end

function i3k_sbean.checkin_take_additional_res.handler(bean,req)
	local is_ok = bean.ok
	if is_ok > 0 then
		if req.__callback then
			req.__callback()
		end
		--[[g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli,"updateQianDaoRedPoint",false)
		g_i3k_game_context:RemoveFuliRedPointCount(1)--]]
	end
end

-- --月卡领取
-- function i3k_sbean.take_month_card_reward()
-- 	local data = i3k_sbean.take_monthly_card_reward_req.new()
-- 	i3k_game_send_str_cmd(data,"take_monthly_card_reward_res")
-- end
--
-- function i3k_sbean.take_monthly_card_reward_res.handler(res)
-- 	if res.ok > 0  then
-- 		g_i3k_game_context:SetMonthlyCardIsAward(1)
-- 		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli,"updateMonthCardInfo")
-- 		local items = i3k_db_month_card_award[5].awardItems
-- 		local tmp_items = {}
-- 		for k,v in ipairs(items) do
-- 			if v[1] ~= 0 and v[2] ~= 0 then
-- 				local tmp = {id = v[1],count = v[2]}
-- 				table.insert(tmp_items,tmp)
-- 			end
--
-- 		end
-- 		g_i3k_ui_mgr:ShowGainItemInfo(tmp_items)
-- 	end
-- end


--每日体力

function i3k_sbean.take_daily_vit(vitId)
	local data = i3k_sbean.take_daily_vit_reward_req.new()
	data.vitId = vitId
	i3k_game_send_str_cmd(data,"take_daily_vit_reward_res")
end

function i3k_sbean.take_daily_vit_reward_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fuli,"updateVitInfo",0)
		local items = i3k_db_month_card_award[req.vitId].awardItems
		local tmp_items = {}
		for k,v in ipairs(items) do
			if v[1] ~= 0 and v[2] ~= 0 then
				local tmp = {id = v[1],count = v[2]}
				table.insert(tmp_items,tmp)
			end

		end
		g_i3k_ui_mgr:ShowGainItemInfo(tmp_items)
	end
end


function i3k_sbean.role_revive_other()
	local bean = i3k_sbean.role_revive_other_req.new()
	i3k_game_send_str_cmd(bean, "role_revive_other_res")
end
function i3k_sbean.role_revive_other_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseDrugTime(i3k_integer(i3k_game_get_time())) --复活点复活药瓶冷却
		g_i3k_ui_mgr:CloseUI(eUIID_PlayerRevive)
		local hero = i3k_game_get_player_hero()
		local serverTime = i3k_game_get_time()
		g_i3k_game_context:SetReviveTickLine(serverTime)
		hero:SetDeadState(false)
	end
end

--单机本原地复活pos值为nil
function i3k_sbean.role_revive.handler(bean, req)
	local revivePos = bean.pos
	local world = i3k_game_get_world();
	local player = i3k_game_get_player()
	g_i3k_ui_mgr:CloseUI(eUIID_PlayerRevive)
	local hero = i3k_game_get_player_hero()
	local onHookValid = g_i3k_game_context:GetSuperOnHookValid()
	if hero._AutoFight and not onHookValid then
		g_i3k_game_context:SetAutoFight(false)
	end
	if onHookValid then
		g_i3k_game_context:SetAutoFight(true)
	end
	player:ResetCameraEntity()
	if revivePos then
		hero:SetPos(revivePos)
	end
	hero:OnRevive(revivePos, 1, 0)
	hero:UpdateHP(bean.curHP)
	if not world._syncRpc then
		if hero._tmpSp then
			hero:UpdateProperty(ePropID_sp, 1, hero._tmpSp * 0.5, true, false,true);
		end
	end
end

function i3k_sbean.role_revive_insitu(useStone)
	local data = i3k_sbean.role_revive_insitu_req.new()
	data.useStone = useStone
	i3k_game_send_str_cmd(data, "role_revive_insitu_res")
end

-- 原地复活响应
function i3k_sbean.role_revive_insitu_res.handler(bean,req)
	if bean.ok == 1 then
		local hero = i3k_game_get_player_hero()
		g_i3k_ui_mgr:CloseUI(eUIID_PlayerRevive)
		g_i3k_game_context:UseCommonItem(g_BASE_ITEM_DIAMOND, g_i3k_game_context:GetReviveCost(), AT_REVIVE_IN_SITU)
		if not g_i3k_db.i3k_db_get_is_pve_maptype() then -- PVE地图类型复活次数不加一
			g_i3k_game_context:AddRevieTimes()
		end
	end
end

-- 安全点复活
function i3k_sbean.role_revive_safe()
	local data = i3k_sbean.role_revive_safe_req.new()
	i3k_game_send_str_cmd(data, "role_revive_safe_res")
end

function i3k_sbean.role_revive_safe_res.handler(bean)
	if bean.ok ~= 1 then
		g_i3k_ui_mgr:PopupTipMessage("安全区域复活失败~")
	end
end

-- 帮派驻地安全点复活
function i3k_sbean.role_sect_zone_revive_safe()
	local data = i3k_sbean.role_sect_zone_revive_safe_req.new()
	i3k_game_send_str_cmd(data, "role_sect_zone_revive_safe_res")
end

function i3k_sbean.role_sect_zone_revive_safe_res.handler(bean)
	if bean.ok ~= 1 then
		g_i3k_ui_mgr:PopupTipMessage("帮派驻地安全区域复活失败~~")
	end
end
--------------------------------同步世界地图分线状态----------------------------------------------
function i3k_sbean.sync_worldline()
	local bean = i3k_sbean.worldline_sync_req.new()
	i3k_game_send_str_cmd(bean,"worldline_sync_res")
end

function i3k_sbean.worldline_sync_res.handler(res, req)--(curLine: 从1开始)curLine,count
	g_i3k_ui_mgr:OpenUI(eUIID_WorldLine)
	g_i3k_ui_mgr:RefreshUI(eUIID_WorldLine, res.curLine,res.count)
end

--- 切换当前地图分线(line: 从0开始)

function i3k_sbean.change_worldline(line)
	local bean = i3k_sbean.worldline_change_req.new()
	bean.line = line
	i3k_game_send_str_cmd(bean,"worldline_change_res")
end

function i3k_sbean.worldline_change_res.handler(res, req)--(curLine: 从1开始)curLine,count
	if res.ok > 0 then
		local logic = i3k_game_get_logic();
		local world
		local mapid = 0
		local mapname = ""
		if logic then
			world = logic:GetWorld();
			mapid = world._cfg.id
			mapname = world._cfg.name
		end
		if req.line == 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(519,mapname, "争夺分"))
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(519,mapname,req.line))
		end
		--i3k_sbean.sync_worldline()
		g_i3k_ui_mgr:CloseUI(eUIID_WorldLine)
	elseif res.ok == -1 then -- 要切换线的人数已满
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(850, req.line))
	end
end

-- 七日留存活动领取奖励
function i3k_sbean.rmactivity_akereward(pos, cfg)
	local data = i3k_sbean.rmactivity_takereward_req.new()
	data.id = pos
	data.cfg = cfg
	i3k_game_send_str_cmd(data,"rmactivity_takereward_res")
end

function i3k_sbean.rmactivity_takereward_res.handler(bean, req)
	if bean.ok > 0 then
		if req.id == 2 then
			req.id = 3
		end
		g_i3k_game_context:SetKeepActivityData(req.id, req.cfg)
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

-- 传家宝同步

function i3k_sbean.role_heirloom_info.handler( bean, req )
	g_i3k_game_context:setHeirloomData(bean.heirloom )
end

-- 擦拭传家宝
function i3k_sbean.wipeHeirloom(colorSeq)
	local data = i3k_sbean.heirloom_wipe_req.new()
	data.colorSeq = colorSeq
	i3k_game_send_str_cmd(data,"heirloom_wipe_res")
end

function i3k_sbean.heirloom_wipe_res.handler( bean, req )
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("强化成功")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OpenArtufact,"callback")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance, "updateKeepUI")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OpenArtufact1, "updateArtifactInfo")
		g_i3k_game_context:RefreshBagIsFull()
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("前置条件不满足")
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("完美度已达最大值")
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("强化次数已用完")
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("传家宝已领取")
	elseif bean.ok == -5 then
		g_i3k_ui_mgr:PopupTipMessage("完美度不足")
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败，稍后重试")
	end
end

-- 传家宝取出
function i3k_sbean.getHeirloom()
	local data = i3k_sbean.heirloom_takeout_req.new()
	i3k_game_send_str_cmd(data,"heirloom_takeout_res")
end

function i3k_sbean.heirloom_takeout_res.handler( bean, req )
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("装备成功，可在装备栏查看")
		g_i3k_game_context:setHeirloomOpen()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_KeepActivity,"callback")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance, "updateKeepUI")
		--i3k_sbean.setHeirloomdisplay(1)
		--i3k_sbean.weapondisplay_select(g_HEIRHOOM_SHOW_TYPE)
		g_i3k_game_context:RefreshBagIsFull()
		g_i3k_game_context:setCurWeaponShowType(g_HEIRHOOM_SHOW_TYPE)
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:setWeaponShowType(g_HEIRHOOM_SHOW_TYPE)
			hero:changeWeaponShowType()
		end
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("前置条件不满足")
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("完美度已达最大值")
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("擦拭次数已用完")
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("传家宝已领取")
	elseif bean.ok == -5 then
		g_i3k_ui_mgr:PopupTipMessage("完美度不足")
	else
		g_i3k_ui_mgr:PopupTipMessage("装备失败，稍后重试")
	end
end

--[[function i3k_sbean.setHeirloomdisplay(value)
	local data = i3k_sbean.set_heirloom_display_req.new()
	data.display = value
	i3k_game_send_str_cmd(data,"set_heirloom_display_res",value)
end

function i3k_sbean.set_heirloom_display_res.handler(bean, req )
	if bean.ok > 0 then
		g_i3k_game_context:setHeirloomDisPlay(req.display)
		local hero = i3k_game_get_player_hero()
		local pid = 1
		local usefashion = g_i3k_game_context:get_hero_skin_info(hero);
		g_i3k_game_context:needShowHeirloom( req.display , hero)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "updateRecover")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy, "updateRecover")
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy2, "updateRecover")
	end
end--]]

-- 锁定强化序号
function i3k_sbean.lookHeirloom(value)
	local data = i3k_sbean.look_strength_heirloom_req.new()
	data.index = value;
	i3k_game_send_str_cmd(data,"look_strength_heirloom_res")
end

function i3k_sbean.look_strength_heirloom_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:setCurStrengthIndex(req.index)
		g_i3k_ui_mgr:OpenUI(eUIID_ArtifactStrengthSelect)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArtifactStrengthSelect, req.index)
	end
end

-- 强化传家宝
function i3k_sbean.strengthHeirloom(value, percent, consume)
	local data = i3k_sbean.strength_heirloom_req.new()
	data.doubleCost = value;
	data.percent = percent;
	data.consume = consume;
	i3k_game_send_str_cmd(data,"strength_heirloom_res")
end

function i3k_sbean.strength_heirloom_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("精炼成功")
		if req.doubleCost == 0 then
			g_i3k_game_context:UseVit(i3k_db_chuanjiabao_strength.cfg.needVit, AT_HEIRLOOM_STRENGTH)
		else
			g_i3k_game_context:UseCommonItem(req.consume.id, req.consume.count, AT_HEIRLOOM_STRENGTH)
		end
		g_i3k_game_context:setStrengthPercent(req.percent);
		g_i3k_ui_mgr:CloseUI(eUIID_ArtifactStrengthSelect);
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_OpenArtufact, "strength")
		g_i3k_game_context:setStrengthPropIndex(bean.ok)
	end
end

-- 设置 同步随从自动使用血池
function i3k_sbean.syncPetCanUsePool(canUse)
	local data = i3k_sbean.sync_pet_can_use_pool.new()
	data.canUsePool = canUse
	i3k_game_send_str_cmd(data)
end

-- function i3k_sbean.sync_pet_can_use_pool_res.handler(bean,req)
-- 	local bValue = bean.ok == 1 and true or false
-- 	g_i3k_game_context:setUsercfgUsePetPool(bValue)
-- end

function i3k_sbean.syncAutoSaleEquip(auto)
	local data = i3k_sbean.sync_auto_sale_equip.new()
	data.autoSaleEquip = auto and 1 or 0
	i3k_game_send_str_cmd(data)
end

function i3k_sbean.syncAutoSaleDrug(auto)
	local data = i3k_sbean.sync_auto_sale_drug.new()
	data.autoSaleDrug = auto and 1 or 0
	i3k_game_send_str_cmd(data)
end

-- 设置 同步留言板请求协议
function i3k_sbean.sync_bill_bord()
	local data = i3k_sbean.sync_message_board_req.new()
	i3k_game_send_str_cmd(data,"sync_message_board_res")
end

function i3k_sbean.sync_message_board_res.handler(bean,req)
	g_i3k_ui_mgr:OpenUI(eUIID_BillBoard)
	g_i3k_ui_mgr:RefreshUI(eUIID_BillBoard,bean.msgs,bean.hasNewMsg)
	i3k_sbean.sync_marriage_bespeak(true)
end

-- 设置 添加留言请求协议
function i3k_sbean.add_bill_board(side,msgId,content,time,anonymous,isrewrite,cost,cost_type)
	local data = i3k_sbean.add_message_board_req.new()
	data.side = side
	data.msgId = msgId
	data.content = content
	data.time = time
	data.anonymous = anonymous
	data.isrewrite = isrewrite
	data.cost = cost
	data.cost_type = cost_type
	i3k_game_send_str_cmd(data,"add_message_board_res")
end

function i3k_sbean.add_message_board_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_game_context:UseCommonItem(-req.cost_type, req.cost, AT_ADD_MESSAGE_BOARD)
		g_i3k_ui_mgr:CloseUI(eUIID_BillBoard_CL)
		g_i3k_ui_mgr:CloseUI(eUIID_BillBoard_Editor)
		i3k_sbean.sync_bill_bord()
	end
	if bean.ok == -4 then
		if req.cost_type == g_BASE_ITEM_DIAMOND then
			g_i3k_ui_mgr:PopupTipMessage("您所持有的元宝不足，不能发布布告")
		end
		if req.cost_type == g_BASE_ITEM_COIN then
			g_i3k_ui_mgr:PopupTipMessage("您所持有的铜钱不足，不能发布布告")
		end
		i3k_sbean.sync_bill_bord()
	end
	if bean.ok == -7 then
		g_i3k_ui_mgr:CloseUI(eUIID_BillBoard_CL)
		g_i3k_ui_mgr:PopupTipMessage("您的布告中有遮罩字元，请重新输入")
	end
	if bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("该板块已被其他玩家使用")
		i3k_sbean.sync_bill_bord()
		g_i3k_ui_mgr:CloseUI(eUIID_BillBoard_CL)
		g_i3k_ui_mgr:CloseUI(eUIID_BillBoard_Editor)
	end
end

function i3k_sbean.comment_bill_board(side,msgId,comment,sendtime)
	local data = i3k_sbean.comment_message_board_req.new()
	data.side = side
	data.msgId = msgId
	data.comment = comment
	data.sendtime = sendtime
	i3k_game_send_str_cmd(data,"comment_message_board_res")
end

function i3k_sbean.comment_message_board_res.handler(bean,req)
	if  bean.ok > 0  then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BillBoard,"set_count",req.side,req.msgId,req.comment)
	else
		g_i3k_ui_mgr:PopupTipMessage("您今日的评价次数已达10次，请明日再来")
	end
end

function i3k_sbean.change_message_board(side,msgId,anonymous,content,sendtime)
	local data = i3k_sbean.change_message_board_content_req.new()
	data.side = side
	data.msgId = msgId
	data.anonymous = anonymous
	data.content = content
	data.sendtime = sendtime
	i3k_game_send_str_cmd(data,"change_message_board_content_res")
end

function i3k_sbean.change_message_board_content_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_BillBoard_Revise)
		i3k_sbean.sync_bill_bord()
	elseif bean.ok == -7 then
		g_i3k_ui_mgr:PopupTipMessage("您的布告中有遮罩字元，请重新输入")
	end

end

function i3k_sbean.exchange_goods(npcId, exchangeId, exchangeCnt)
	local data =  i3k_sbean.batch_exchange_item_req.new()
	data.npcId = npcId
	data.exchangeId = exchangeId
    data.exchangeCnt = exchangeCnt
	local cfg = i3k_db_npc_exchange[data.exchangeId]
	local gainItems = {}
	local flag = true
	for i = 1 , 3 do
		gainItems[i] = cfg["get_goods_id" .. i]
	end
	for _, v in ipairs(gainItems) do
		if not g_i3k_db.i3k_db_prop_gender_qualify(v) then
			flag = false
		end
	end
	if not flag then
		local callfunction = function(ok)
			if ok then
				i3k_game_send_str_cmd(data,"batch_exchange_item_res")
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(50068), callfunction)
		return
	end
	i3k_game_send_str_cmd(data,"batch_exchange_item_res")
end

function i3k_sbean.batch_exchange_item_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_NPC, req.npcId)
		g_i3k_game_context:SetRecordExchangeTimes(req.exchangeId, req.exchangeCnt)
		local id = req.exchangeId
		g_i3k_game_context:UseCommonItem(i3k_db_npc_exchange[id].require_goods_id1, req.exchangeCnt * i3k_db_npc_exchange[id].require_goods_count1, AT_ITEM_EXCHANGE)
		g_i3k_game_context:UseCommonItem(i3k_db_npc_exchange[id].require_goods_id2, req.exchangeCnt * i3k_db_npc_exchange[id].require_goods_count2, AT_ITEM_EXCHANGE)
		g_i3k_game_context:UseCommonItem(i3k_db_npc_exchange[id].require_goods_id3, req.exchangeCnt * i3k_db_npc_exchange[id].require_goods_count3, AT_ITEM_EXCHANGE)
		g_i3k_ui_mgr:RefreshUI(eUIID_npcExchange)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DigitalCollection, "updatewizardScroll")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DigitalCollection, "showGetItem", req.exchangeId, req.exchangeCnt)
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("您距离NPC太远")
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("您兑换所需的道具不足")
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("您的背包空间不足")
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("您今日的兑换次数已满,请您明日再来")
	elseif bean.ok == -5 then
		g_i3k_ui_mgr:PopupTipMessage("该NPC不提供该种道具的兑换")
	end
end

function i3k_sbean.exchange_item_times.handler(bean, res)
	if bean.times then
		g_i3k_game_context:SyncRecordExchangeTimes(bean.times)
		g_i3k_game_context:SyncCollectExchangeInfo(bean.collects)
	end
end

-- 燃放烟花
function i3k_sbean.playFirework(id)
	local data = i3k_sbean.play_firework_req.new()
	data.fireworkID = id
	i3k_game_send_str_cmd(data,"play_firework_res")
end

function i3k_sbean.play_firework_res.handler(bean, res)
	if bean.ok == 1 then
		g_i3k_game_context:UseCommonItem(res.fireworkID, 1,AT_PLAY_FIREWORK)
		g_i3k_game_context:playFirework(res.fireworkID)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end

-- 播放烟花特效的广播协议
function i3k_sbean.notify_play_firework.handler(bean, res)
	g_i3k_game_context:playFirework(bean.fireworkID)
	-- g_i3k_game_context:setFireworkRollNotice(bean.roleName, bean.mapID, bean.fireworkID)
end

--武勋商城
function i3k_sbean.feat_gambleshopsync_res.handler(res, req)
	if res.info then
		g_i3k_ui_mgr:OpenUI(eUIID_MartialFeatShop)
		g_i3k_ui_mgr:RefreshUI(eUIID_MartialFeatShop,res.info, req.shopId)
	else
		g_i3k_ui_mgr:PopupTipMessage("打开错误")
	end
end

function i3k_sbean.feat_gambleshoprefresh_res.handler(res, req)
	local info = res.info
	if info then
		if req.callback then
			req.callback()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MartialFeatShop,"setData",res.info)
	else
		g_i3k_ui_mgr:PopupTipMessage("刷新失败，请重试")
	end
end

function i3k_sbean.feat_gambleshopbuy_res.handler(res, req)
	if res.ok then
		if req.callback then
			req.callback()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MartialFeatShop,"ShowBoughtIcon")
		g_i3k_ui_mgr:OpenUI(eUIID_MartialFeatShopTip)
		g_i3k_ui_mgr:RefreshUI(eUIID_MartialFeatShopTip,res.ok[1])
	else
		g_i3k_ui_mgr:PopupTipMessage("购买失败")
	end
end

--NPC传送
function i3k_sbean.npc_transfrom(npcID)
	local data = i3k_sbean.npc_transfrom_req.new()
	data.transfromId = npcID
	i3k_game_send_str_cmd(data,"npc_transfrom_res")
end

function i3k_sbean.npc_transfrom_res.handler(res,req)
	if res.ok > 0 then
		for k, v in pairs(i3k_db_npc_transfer) do
			if k == req.transfromId then
				g_i3k_game_context:UseCommonItem(v.needItemID, v.needItemCount, AT_NPC_TRANSFER)
				break
			end
		end
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("您今日温泉次数已用完")
	end
end

function i3k_sbean.role_chat_room.handler(bean)
	-- if bean.roomID then
	-- 	g_i3k_game_context:SetOnlineVoiceRoomId(bean.roomID)
	-- 	if i3k_game_get_map_type() ~= g_PRINCESS_MARRY then
	-- 	g_i3k_logic:OpenOnlineVoice()
	-- 	end
	-- end
end

--宠物神兵评价
function i3k_sbean.socialmsg_pageinfoReq(themeType, themeId, tag, pageNo, len, notClear)
	local bean = i3k_sbean.socialmsg_pageinfo_req.new()
	bean.themeType = themeType
	bean.themeId = themeId
	bean.tag = tag
	bean.pageNo = pageNo
	bean.len = len
	bean.notClear = notClear
	i3k_game_send_str_cmd(bean,"socialmsg_pageinfo_res")
end

function i3k_sbean.socialmsg_pageinfo_res.handler(res, req)
	if not req or not res then
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_Evaluation_weaponPet)
	if #res.comments == 0 then
		if not req.notClear then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Evaluation_weaponPet,"clearScroll")
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Evaluation_weaponPet,"isEndPage", true)
		req.pageNo = req.pageNo - 1
		req.pageNo = req.pageNo <= 0 and 1 or req.pageNo
	end
	g_i3k_ui_mgr:RefreshUI(eUIID_Evaluation_weaponPet, req)
	if #res.comments ~= 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Evaluation_weaponPet,"updateEvaluationContent",res.comments or {})
	end

end

function i3k_sbean.socialmsg_sendReq(serverId, serverName, themeType, themeId, comment)
	local bean = i3k_sbean.socialmsg_send_req.new()
	bean.serverId = serverId
	bean.serverName	= serverName
	bean.themeType = themeType
	bean.themeId = themeId
	bean.comment = comment
	i3k_game_send_str_cmd(bean,"socialmsg_send_res")
end

function i3k_sbean.socialmsg_send_res.handler(res, req)
	if res.commonId > 0 then
		g_i3k_ui_mgr:PopupTipMessage("评价成功")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Evaluation_weaponPet, "updateCurrPage")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Evaluation_weaponPet, "clearEditbox")
	elseif res.commonId == -2 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15387, i3k_db_common.evaluation.evaluationCnt))
	elseif res.commonId == -3 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3048))
	end
end

function i3k_sbean.socialmsg_likeReq(serverId, serverName, themeType, themeId, commentId)
	local bean = i3k_sbean.socialmsg_like_req.new()
	bean.serverId = serverId
	bean.serverName = serverName
	bean.themeType = themeType
	bean.themeId = themeId
	bean.commentId = commentId
	i3k_game_send_str_cmd(bean,"socialmsg_like_res")
end

function i3k_sbean.socialmsg_like_res.handler(res, req)
	if res.ok > 0 then

	elseif res.ok == -1 then
		return g_i3k_ui_mgr:PopupTipMessage("此评论不存在")
	elseif res.ok == -2 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15389, i3k_db_common.evaluation.praise))
	end
	if res.ok ~= 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Evaluation_weaponPet, "updateCurrPage")
	end
end

function i3k_sbean.socialmsg_dislikeReq(serverId, serverName, themeType, themeId, commentId)
	local bean = i3k_sbean.socialmsg_dislike_req.new()
	bean.serverId = serverId
	bean.serverName = serverName
	bean.themeType = themeType
	bean.themeId = themeId
	bean.commentId = commentId
	i3k_game_send_str_cmd(bean,"socialmsg_dislike_res")
end

function i3k_sbean.socialmsg_dislike_res.handler(res, req)
	if res.ok > 0 then

	elseif res.ok == -1 then
		return g_i3k_ui_mgr:PopupTipMessage("此评论不存在")
	elseif res.ok == -2 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15390, i3k_db_common.evaluation.disdain))
	end
	if res.ok ~= 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Evaluation_weaponPet, "updateCurrPage")
	end
end

--使用激活码
function i3k_sbean.use_regression_code(text)
	local bean = i3k_sbean.use_regression_code_req.new()
	bean.code = text
	i3k_game_send_str_cmd(bean, "use_regression_code_res")
end

function i3k_sbean.use_regression_code_res.handler(bean, req)
	local info = g_i3k_game_context:getRoleReturnInfo()
	if bean.ok > 0 then
		local itemData = {}
		for k, v in ipairs(i3k_db_role_return.reward) do
			table.insert(itemData,{id = v.id, count = v.count})
		end
		g_i3k_ui_mgr:OpenUI(eUIID_UseItemGainMoreItems)
		g_i3k_ui_mgr:RefreshUI(eUIID_UseItemGainMoreItems, itemData)
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("对方名单已满，请换其他绑定角色")
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3132))
	elseif info.regressionReward > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4119))
	elseif info.regressionReward == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4116))
	elseif bean.ok == -100 then
		g_i3k_ui_mgr:PopupTipMessage("超时")
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("对方条件不满足")
	elseif bean.ok == 0 then
		if i3k_db_role_return.common.limit_lvl > g_i3k_game_context:GetLevel() then
			g_i3k_ui_mgr:PopupTipMessage("等级不足")
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("召回码错误")
	end
end

--领取积分奖励
function i3k_sbean.get_score_reward(itemId, callback)
	local bean = i3k_sbean.get_score_reward_req.new()
	bean.id = itemId
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "get_score_reward_res")
end

function i3k_sbean.get_score_reward_res.handler(bean, req)
	if bean.ok > 0 then
		if req.callback then
			req.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

--同步召回信息
function i3k_sbean.sync_regression(callback)
	local bean = i3k_sbean.sync_regression_req.new()
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "sync_regression_res")
end

function i3k_sbean.sync_regression_res.handler(bean, req)
	if bean then
		g_i3k_game_context:setRoleReturnInfo(bean)
		if req.callback then
			req.callback()
		end
	end
end

--回归单人副本
function i3k_sbean.single_npc_map_start(mapId)
	local bean = i3k_sbean.single_npc_map_start_req.new()
	bean.mapId = mapId
	i3k_game_send_str_cmd(bean, "single_npc_map_start_res")
end

function i3k_sbean.single_npc_map_start_res.handler(bean, req)
	if bean.ok > 0 then

	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4117))
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:OpenUI(eUIID_HuoBanCopy)
		g_i3k_ui_mgr:RefreshUI(eUIID_HuoBanCopy, req.mapId)
	end
end

--领取回归登陆奖励
function i3k_sbean.take_regression_login_gift(day, callback)
	local bean = i3k_sbean.take_regression_login_gift_req.new()
	bean.day = day
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "take_regression_login_gift_res")
end

function i3k_sbean.take_regression_login_gift_res.handler(bean, req)
	if bean.ok > 0 then
		if req.callback then
			req.callback()
		end
	end
end

function i3k_sbean.buy_regression_daily_discount(day, callback)
	local bean = i3k_sbean.buy_regression_daily_discount_req.new()
	bean.day = day
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "buy_regression_daily_discount_res")
end

function i3k_sbean.buy_regression_daily_discount_res.handler(bean, req)
	if bean.ok > 0 then
		if req.callback then
			req.callback()
		end
	end
end

--同步是否为老玩家
function i3k_sbean.role_is_regression.handler(bean)
	if bean.regressionLogin then
		g_i3k_game_context:setIsRoleReturn(bean.regressionLogin)
	end
end

--开心对对碰祈福
function i3k_sbean.pray_words_req()
	local bean = i3k_sbean.happy_mstching_take_word_req.new()
	i3k_game_send_str_cmd(bean,"happy_mstching_take_word_res")
end

function i3k_sbean.happy_mstching_take_word_res.handler(res, req)
	if res.ok > 0 then
		local id = res.itemId
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(id)
		if cfg then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15577, cfg.name))
		end
	elseif res.ok == -1 then
		--背包满了
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15574))
	elseif res.ok == -2 then
		--祈福次数满了
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15573))
	else
		g_i3k_ui_mgr:PopupTipMessage("祈福失败")
	end
end

--开心对对碰打开兑换界面
function i3k_sbean.open_exchange_words_req()
	local bean = i3k_sbean.happy_mstching_open_exchange_req.new()
	i3k_game_send_str_cmd(bean,"happy_mstching_open_exchange_res")
end

function i3k_sbean.happy_mstching_open_exchange_res.handler(res, req)
	if next(res.lastTimes) then
		g_i3k_ui_mgr:OpenUI(eUIID_ExchangeWords)
		g_i3k_ui_mgr:RefreshUI(eUIID_ExchangeWords, res.lastTimes)
	end
end

--开心对对碰兑换文字
function i3k_sbean.exchange_words_req(rewardId)
	local bean = i3k_sbean.happy_mstching_take_reward_req.new()
	bean.rewardId = rewardId
	i3k_game_send_str_cmd(bean,"happy_mstching_take_reward_res")
end

function i3k_sbean.happy_mstching_take_reward_res.handler(res, req)
	if res.ok > 0 then
		local cfg = i3k_db_schedule.cfg
		local mapID = g_SCHEDULE_COMMON_MAPID
		for _, v in ipairs(cfg or {}) do
			if v.typeNum == g_SCHEDULE_TYPE_HAPPY_MATCH then
				mapID = v.mapID
				break
			end
		end
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_HAPPY_MATCH, mapID)

		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15580))
		g_i3k_ui_mgr:CloseUI(eUIID_ExchangeWords)
	elseif res.ok == -2 then
		--兑换次数满了
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15581))
	elseif res.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15582))
	else
		g_i3k_ui_mgr:PopupTipMessage("兑换文字失败")
	end
end

--碎片回收同步协议
function i3k_sbean.openDebrisRecycle(itemID, kind)
	local cfg = i3k_db_debrisRecycle[itemID]
	if cfg then
		-- assert(cfg ~= nil, "itemID is not find in db debrisRecycle  ".. itemID)
	local bean = i3k_sbean.fragment_recycle_sync_req.new()
	bean.kind = kind
	bean.cfg = cfg
	i3k_game_send_str_cmd(bean,"fragment_recycle_sync_res")
	end
end

function i3k_sbean.fragment_recycle_sync_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_DebrisRecycle)
	    g_i3k_ui_mgr:RefreshUI(eUIID_DebrisRecycle, req.kind, req.cfg, res.log)
	else
	    g_i3k_ui_mgr:PopupTipMessage("同步出错")
	end
end


--碎片回收请求
function i3k_sbean.debrisRecycle_req(order, itemOrder, itemId, itemCount, coinCost)
	local bean = i3k_sbean.fragment_recycle_req.new()
	bean.id = order
	bean.wantReward = itemOrder
	bean.itemId = itemId
	bean.itemCount = itemCount
	bean.coinCost = coinCost
	i3k_game_send_str_cmd(bean,"fragment_recycle_res")
end

function i3k_sbean.fragment_recycle_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DebrisRecycle, "showGetItem")
		g_i3k_game_context:UseCommonItem(req.itemId, req.itemCount, AT_FRAGMENT_RECYCLE)
		g_i3k_game_context:UseCommonItem(g_BASE_ITEM_COIN, req.coinCost, AT_FRAGMENT_RECYCLE)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DebrisRecycle, "updateLeftTimes")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DebrisRecycle, "showLeftTimes")
	else
	    g_i3k_ui_mgr:PopupTipMessage("碎片回收失败")
	end
end

--清除某个类型的buff药
function i3k_sbean.buffdrug_remove_req(buffID, buffType)
	local bean = i3k_sbean.buffdrug_clear_req.new()
	bean.type = buffType
	bean.buffID = buffID
	i3k_game_send_str_cmd(bean, "buffdrug_clear_res")
end

function i3k_sbean.buffdrug_clear_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_BuffDrugRemove)
		g_i3k_ui_mgr:PopupTipMessage("成功清除buff药")
	else
		g_i3k_ui_mgr:PopupTipMessage("清除buff药失败")
	end
end

-----------------国庆节活动协议START---------------------
--同步加油信息
function i3k_sbean.sync_national_activity(isDownFlag, isUpFlag)
	local bean = i3k_sbean.sync_oil_req.new()
	bean.isDownFlag = isDownFlag
	bean.isUpFlag = isUpFlag
	i3k_game_send_str_cmd(bean, "sync_oil_res")
end

function i3k_sbean.sync_oil_res.handler(res, req)
	g_i3k_ui_mgr:OpenUI(eUIID_NationalRaiseFlag)

	g_i3k_ui_mgr:RefreshUI(eUIID_NationalRaiseFlag, {luckyRole = res.luckyRole, score = res.score, reward = res.reward, lastTime = res.lastTime, allscore = res.allscore, dayOilTimes = res.dayOilTimes})
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_NationalRaiseFlag, "refreshLogInfo", res.history)
	g_i3k_game_context:setNationalCheerTimes(res.dayOilTimes)

	if req.isDownFlag then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_NationalRaiseFlag, "playDownFlagAni")
	end

	if req.isUpFlag then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_NationalRaiseFlag, "playUpFlagAni", res.allscore)
	end
end

--角色加油
function i3k_sbean.role_add_oil(times, consumeID, callback)
	local bean = i3k_sbean.role_oil_req.new()
	bean.times = times
	bean.consumeID = consumeID
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "role_oil_res")
end

function i3k_sbean.role_oil_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18557))
		g_i3k_game_context:UseCommonItem(req.consumeID, req.times * i3k_db_national_activity_cfg.consume_item_num, AT_NATIONAL_OIL)  --reason
		g_i3k_game_context:useNationalCheerTimes(req.times)
		if req.callback then
			req.callback()
		end
	else
		i3k_sbean.sync_national_activity()
		g_i3k_ui_mgr:PopupTipMessage("加油失败")
	end
end

--领取加油奖励
function i3k_sbean.take_oil_reward(score, gifts, callback)
	local bean = i3k_sbean.take_oil_reward_req.new()
	bean.score = score
	bean.gifts = gifts
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "take_oil_reward_res")
end

function i3k_sbean.take_oil_reward_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo(req.gifts)
		if req.callback then
			req.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

--查看加油排行榜
function i3k_sbean.sync_oil_rank(myScore)
	local bean = i3k_sbean.oil_rank_req.new()
	bean.myScore = myScore
	i3k_game_send_str_cmd(bean, "oil_rank_res")
end

function i3k_sbean.oil_rank_res.handler(res, req)
	g_i3k_ui_mgr:OpenUI(eUIID_NationalCheerRank)
	g_i3k_ui_mgr:RefreshUI(eUIID_NationalCheerRank, {ranks = res.ranks, selfRank = res.selfRank, selfScore = req.myScore})
end
-----------------国庆节活动协议END---------------------

-----------------查询坐骑排行START---------------------

---获取排行
function i3k_sbean.check_steed_rank(horseId, fightPower)
	local bean = i3k_sbean.single_horse_rank_req.new()
	bean.horseId = horseId
	bean.fightPower = fightPower
	i3k_game_send_str_cmd(bean, "single_horse_rank_res")
end

function i3k_sbean.single_horse_rank_res.handler(res, req)
	if res.ok > 0 then
		if req then
		g_i3k_ui_mgr:OpenUI(eUIID_SteedRank)
	    g_i3k_ui_mgr:RefreshUI(eUIID_SteedRank, {count = res.maxCount, selfRank = res.selfRank, allPlayers = res.rankRoles, id = req.horseId, horseInfo = res.horses, power = req.fightPower})
		end
	elseif res.ok == -102 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16812))
	end
end

---获取单个玩家坐骑信息
--[[function i3k_sbean.check_player_steedInfo(rid, horseId)
	local bean = i3k_sbean.query_single_horseoverview_req.new()
	bean.rid = rid
	bean.horseId = horseId
	i3k_game_send_str_cmd(bean, "query_single_horseoverview_res")
end

function i3k_sbean.query_single_horseoverview_res.handler(res, req)
	g_i3k_ui_mgr:OpenUI(eUIID_CheckSteedInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_CheckSteedInfo, res.horses)
end]]
-----------------查询坐骑排行END---------------------

--聊天框
function i3k_sbean.role_chat_box_syncReq(openHave)
	local bean = i3k_sbean.role_chat_box_sync_req.new()
	bean.openHave = openHave
	i3k_game_send_str_cmd(bean, "role_chat_box_sync_res")
end

function i3k_sbean.role_chat_box_sync_res.handler(res, req)
	g_i3k_ui_mgr:OpenUI(eUIID_ChatBubble)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChatBubble, res.currId,res.chatBoxIds, req.openHave)
end

function i3k_sbean.bag_usechatboxitemReq(itemID, count)
	local bean = i3k_sbean.bag_usechatboxitem_req.new()
	bean.itemID = itemID
	bean.count = count
	i3k_game_send_str_cmd(bean, "bag_usechatboxitem_res")
end

function i3k_sbean.bag_usechatboxitem_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseCommonItem(req.itemID, req.count, AT_ROLE_USE_CHAT_BOX_ITEM)
		i3k_sbean.role_chat_box_syncReq(true)
	end
end

function i3k_sbean.role_chat_box_changeReq(chatBoxId)
	local bean = i3k_sbean.role_chat_box_change_req.new()
	bean.chatBoxId = chatBoxId
	i3k_game_send_str_cmd(bean, "role_chat_box_change_res")
end

function i3k_sbean.role_chat_box_change_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setChatBubbleCurrId(req.chatBoxId)
		g_i3k_ui_mgr:PopupTipMessage("使用成功")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ChatBubble,"updateCurrUseingItem", req.chatBoxId)
	end
end

function i3k_sbean.teleport_spawnmonsterReq(pointID)
	local bean = i3k_sbean.teleport_spawnmonster_req.new()
	bean.pointID = pointID
	i3k_game_send_str_cmd(bean, "teleport_spawnmonster_res")
end

function i3k_sbean.teleport_spawnmonster_res.handler(res,req)
	if res.ok > 0 then
		local needId = i3k_db_common.activity.transNeedItemId
		g_i3k_game_context:UseTrans(needId, 1, AT_TELEPORT_SPAWN_MONSTER)
		releaseSchedule()
	end
end

-------------圣诞贺卡 START-------------------
--同步圣诞许愿
function i3k_sbean.christmas_cards_sync(isUpdateWish)
	local bean = i3k_sbean.christmas_cards_sync_req.new()
	bean.isUpdateWish = isUpdateWish
	i3k_game_send_str_cmd(bean, "christmas_cards_sync_res")
end

function i3k_sbean.christmas_cards_sync_res.handler(res, req)
	if res.ok > 0 then
		if req.isUpdateWish then
			g_i3k_game_context:UpdateMyChristmasCardInfo(res.wishUpdateTime, res.overview)
		else
			g_i3k_ui_mgr:OpenUI(eUIID_ChristmasWish)
			g_i3k_ui_mgr:RefreshUI(eUIID_ChristmasWish, res.wishUpdateTime, res.overview, g_TYPE_Edit)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16927))
	end
end

--圣诞许愿
function i3k_sbean.christmas_cards_wish(wishText, background)
	local bean = i3k_sbean.christmas_cards_wish_req.new()
	bean.text = wishText
	bean.background = background
	i3k_game_send_str_cmd(bean, "christmas_cards_wish_res")
end

function i3k_sbean.christmas_cards_wish_res.handler(res, req)
	if res.ok > 0 then
		if g_i3k_game_context:GetMyChristmasCardInfo().wishUpdateTime > 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16940))
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16928))
		end

		local isUpdateWish = true
		i3k_sbean.christmas_cards_sync(isUpdateWish)

		g_i3k_ui_mgr:CloseUI(eUIID_ChristmasWish)
	elseif res.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16929))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16930))
	end
end

--同步圣诞愿望列表
function i3k_sbean.christmas_cards_get_list()
	local bean = i3k_sbean.christmas_cards_get_list_req.new()
	i3k_game_send_str_cmd(bean, "christmas_cards_get_list_res")
end

function i3k_sbean.christmas_cards_get_list_res.handler(res, req)
	g_i3k_ui_mgr:OpenUI(eUIID_ChristmasWishesList)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChristmasWishesList, res.list)
end

--扔砖/送花
function i3k_sbean.christmas_cards_comment(sendRid, sendType)
	local bean = i3k_sbean.christmas_cards_comment_req.new()
	bean.sendRid = sendRid
	bean.sendType = sendType
	i3k_game_send_str_cmd(bean, "christmas_cards_comment_res")
end

function i3k_sbean.christmas_cards_comment_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ChristmasWish, "setCommentCnt", req.sendType)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16931, i3k_db_christmas_wish_cfg.day_max_comment))
	end
end
-------------圣诞贺卡 END-------------------


--新年红包
function i3k_sbean.new_year_red_packet_getReq(npcID)
	local bean = i3k_sbean.new_year_red_packet_get_req.new()
	bean.npcID = npcID
	i3k_game_send_str_cmd(bean, "new_year_red_packet_get_res")
end

function i3k_sbean.new_year_red_packet_get_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:addNewYearRedGetNpcid(req.npcID)
		local currTime = g_i3k_get_GMTtime(i3k_game_get_time())
		local db = i3k_db_newYear_red
		local rLvl = g_i3k_game_context:GetLevel()
		for i,v in ipairs(db.gift) do
			if currTime < v.date + 86400 and v.date < currTime then
				if rLvl > 70 or g_i3k_game_context:GetVipLevel() > 0 then
					g_i3k_ui_mgr:ShowGainItemInfo(v.rewards70Up)
				else
					g_i3k_ui_mgr:ShowGainItemInfo(v.rewards70)
				end
				break
			end
		end

		for k,v in pairs(i3k_db_schedule.cfg) do
			if v.typeNum == g_SCHEDULE_TYPE_NEW_YEAR_RED then
				g_i3k_game_context:ChangeScheduleActivity(v.typeNum,v.mapID)
				break
			end
		end
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17474))
	end
end

function i3k_sbean.new_year_red_packet_sync_taked_npc.handler(bean)
	g_i3k_game_context:setNewYearRedGetNpcid(bean.npcIDs)
end

-------------新春福袋 START-------------------
-- 同步春节福袋
function i3k_sbean.new_year_pack_sync(callback)
	local bean = i3k_sbean.new_year_pack_sync_req.new()
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "new_year_pack_sync_res")
end

function i3k_sbean.new_year_pack_sync_res.handler(res, req)
	if res.info then
		if req.callback then
			req.callback(res.info)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("新春福袋活动已结束")
	end
end

-- 春节福袋打开
function i3k_sbean.new_year_pack_take(id, callback)
	local bean = i3k_sbean.new_year_pack_take_req.new()
	bean.id = id
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "new_year_pack_take_res")
end

function i3k_sbean.new_year_pack_take_res.handler(res, req)
	if res.ok > 0 then
		if req.callback then
			req.callback()
		end
		local rewards = {}
		for k, v in pairs(res.drops) do
			table.insert(rewards, {id = k, count = v})
		end
		g_i3k_ui_mgr:ShowGainItemInfo(rewards)
	else
		g_i3k_ui_mgr:PopupTipMessage("打开失败")
	end
end
-------------新春福袋 END-------------------

-- 每日挂签
function i3k_sbean.divination_state_sync(callback)
	local bean = i3k_sbean.divination_state_sync_req.new()
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "divination_sync_res")
end

function i3k_sbean.divination_sync_res.handler(res, req)
	if req.callback then
		req.callback()
	end

	g_i3k_game_context:setDivinationInfo(res)
	-- 有挂签ID分为两个状态 未领奖和已领奖  如果有ID 次数大于hasreward就是未领奖 如果等于就是已领奖
	if res.fortuneId ~= nil and res.fortuneId > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_DivinationReward)
		g_i3k_ui_mgr:RefreshUI(eUIID_DivinationReward, res)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_Divination)
		g_i3k_ui_mgr:RefreshUI(eUIID_Divination)
	end
end

--占卜
function i3k_sbean.conduct_divination(callback)
	local bean = i3k_sbean.conduct_divination_req.new()
	bean.callback = callback
	bean.divinationCount = g_i3k_game_context:getDivinationCount()
	i3k_game_send_str_cmd(bean, "divination_info_res")
end

function i3k_sbean.divination_info_res.handler(res, req)
	if res.fortuneId ~= nil and res.fortuneId > 0 then
		if req.callback then
			req.callback()
		end

		local info = i3k_db_Divinationcfg
		g_i3k_game_context:UseCommonItem(info.coinType, info.coinNum, AT_DIVINATION_COST)
		g_i3k_ui_mgr:OpenUI(eUIID_DivinationReward)
		g_i3k_ui_mgr:RefreshUI(eUIID_DivinationReward, res)
	else
		g_i3k_ui_mgr:PopupTipMessage("占卜失败")
	end
end

function i3k_sbean.receive_divination_reward(callback)
	local bean = i3k_sbean.receive_divination_reward_req.new()
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "divination_reward_res")
end

function i3k_sbean.divination_reward_res.handler(res, req)
	if res.fortuneId ~= nil and res.fortuneId > 0 then

		local info = i3k_db_DivinationLuckyID[res.fortuneId]
		if info == nil then return end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DivinationReward, "changeDefineBtnGray")
		local items = {}

		for i, v in ipairs(info.DivinationTextID) do
			local id = i3k_db_DivinationTextID[v].RewardID

			local flag = false

			for	_,n in ipairs(items) do
				if n.id == id then
					n.count = n.count + i3k_db_DivinationTextID[v].RewardNum
					flag = true
				end
			end

			if not flag then
				table.insert(items, {id = id, count = i3k_db_DivinationTextID[v].RewardNum})
			end
		end

		g_i3k_ui_mgr:ShowGainItemInfo(items)
		local cfg = i3k_db_schedule.cfg
		local mapID = g_SCHEDULE_COMMON_MAPID
		for _, v in ipairs(cfg or {}) do
			if v.typeNum == g_SCHEDULE_TYPE_DIVINATION then
				mapID = v.mapID
				break
			end
		end
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_DIVINATION, mapID)
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

------------每日挂签 END-------------------

------------天命轮相关-----------------
function i3k_sbean.fiveTransform_choose_attr(id)
	local bean = i3k_sbean.transform_road_use_lifewheel_req.new()
	bean.id = id
	i3k_game_send_str_cmd(bean, "transform_road_use_lifewheel_res")
end

function i3k_sbean.transform_road_use_lifewheel_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DestinyRoll, "afterChoose", req.id)
	end
end

function i3k_sbean.fiveTransform_reset_attr()
	local bean = i3k_sbean.transform_road_reset_lifewheel_req.new()
	i3k_game_send_str_cmd(bean, "transform_road_reset_lifewheel_res")
end

function i3k_sbean.transform_road_reset_lifewheel_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DestinyRoll, "afterReset")
	end
end

--飞鸽传书发送
function i3k_sbean.send_kite(kiteId, msg)
	local bean = i3k_sbean.send_kite_req.new()
	bean.kiteId = kiteId
	bean.msg = msg
	bean.gsName = i3k_game_get_server_name(i3k_game_get_login_server_id())
	i3k_game_send_str_cmd(bean, "send_kite_res")
end

function i3k_sbean.send_kite_res.handler(res, req)
	if res.ok > 0 then
		if req then
			local pigeonPost = i3k_db_pigeon_post.itemInfo[req.kiteId]
			g_i3k_game_context:UseBaseItem(pigeonPost.currencyType, pigeonPost.currencyCount, AT_PIGEON_POST_SEND)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_PigeonPostSend)
		g_i3k_ui_mgr:PopupTipMessage("发送成功")
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17173))
	elseif res.ok == -404 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1566))
	else
		g_i3k_ui_mgr:PopupTipMessage("发送失败")
	end
end

--同步单人闯关
function i3k_sbean.single_explore_sync(id)
	local bean = i3k_sbean.single_explore_sync_req.new()
	bean.id = id
	i3k_game_send_str_cmd(bean, "single_explore_sync_res")
end

function i3k_sbean.single_explore_sync_res.handler(res, req)
	g_i3k_ui_mgr:OpenUI(eUIID_SingleChallenge)
	g_i3k_ui_mgr:RefreshUI(eUIID_SingleChallenge, req.id, res.singleExplore)
end

--进入单人闯关
function i3k_sbean.single_explore_start(exploreId, enterGroup, curNpcMapGroup)
	local bean = i3k_sbean.single_explore_start_req.new()
	bean.exploreId = exploreId
	bean.enterGroup = enterGroup
	bean.curNpcMapGroup = curNpcMapGroup
	i3k_game_send_str_cmd(bean, "single_explore_start_res")
end

function i3k_sbean.single_explore_start_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setSingleChallengeInfo(req.exploreId, req.curNpcMapGroup)
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_SINGLE_CHALLENGE, req.exploreId)
	elseif res.ok == -1 then  --超过每天可进最大次数
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(71))
	end
end

--单人闯关目标进度推送
function i3k_sbean.justice_map_target_info.handler(res)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFuben, "updateSingleChallengePercent", res.targetIndex, res.value)
end

-------------势力声望--------------------
-- 同步
function i3k_sbean.role_forcefame_info.handler(res, req)
	local fame = res.fame -- 声望值
	local tasks = res.tasks -- 任务，势力npc随机的一个任务[组，]
	local donate = res.donate -- 捐赠，每组里选3个物品可以捐赠
	g_i3k_game_context:syncPowerRep(fame, tasks, donate)
end

-- 任务状态之前不是0，1,2吗。我加了一个3状态，表示领过任务奖励
-- 接取势力声望任务
function i3k_sbean.takePowerReqTask(npcID)
	local data = i3k_sbean.forcefame_take_req.new()
	data.npcId = npcID
	i3k_game_send_str_cmd(data, "forcefame_take_res")
end
function i3k_sbean.forcefame_take_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("成功接受任务")
		g_i3k_ui_mgr:CloseUI(eUIID_PowerReputationTask)
		local taskGroupID = g_i3k_db.i3k_db_power_rep_get_task_groupID(req.npcId)
		local info = g_i3k_game_context:getPowerRep()
		local taskID = info.tasks[taskGroupID].id
		g_i3k_game_context:receivePowerRepTask(taskGroupID, taskID)

		local powerSide = g_i3k_db.i3k_db_power_rep_get_type_by_npcid(req.npcId)
		g_i3k_logic:ChangePowerRepNpcTitleVisible(req.npcId, false) -- 设置地图上npc头顶信息的显隐
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
	else
		g_i3k_ui_mgr:PopupTipMessage("接受任务失败")
	end
end


-- 完成势力声望任务
function i3k_sbean.finishPowerReqTask(groupId, id)
	local data = i3k_sbean.forcefame_finish_req.new()
	data.groupId = groupId
	data.id = id
	i3k_game_send_str_cmd(data, "forcefame_finish_res")
end
function i3k_sbean.forcefame_finish_res.handler(res, req)
	if res.ok > 0 then
		-- g_i3k_ui_mgr:PopupTipMessage("任务完成")
		g_i3k_ui_mgr:OpenUI(eUIID_BattleTXFinishTask)
		local hash = g_i3k_db.i3k_db_get_power_rep_task_hash_id(req.groupId, req.id)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "removeTaskItem", hash)
		local taskCfg = i3k_db_power_reputation_task[req.groupId][req.id]
		local rate = g_i3k_game_context:getPowerRepAddRepRate(taskCfg.powerSide)
		local powerRepCount = math.floor(taskCfg.rewardRep * rate / 10000 )
		g_i3k_game_context:addPowerRep(taskCfg.powerSide, powerRepCount)
		g_i3k_game_context:setPowerRepTaskState(hash, 3)   -- 接取1， 0未接取，2完成，3领过奖了

		local t = {}
		for k, v in ipairs(taskCfg.rewards) do
			table.insert(t, v)
		end
		local itemID = g_i3k_db.i3k_db_power_rep_get_itemID(taskCfg.powerSide)
		table.insert(t, {id = 1000, count = taskCfg.exp}) -- 经验
		table.insert(t, {id = itemID, count = powerRepCount })
		if #(t) ~= 0 then
			g_i3k_ui_mgr:ShowGainItemInfo(t) -- 需要在套一层table
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("任务完成失败")
	end
end


-- 势力声望捐赠
function i3k_sbean.powerReqDonate(forceId, order, num, id)
	local data = i3k_sbean.forcefame_donate_req.new()
	data.forceId = forceId
	data.order = order
	data.num = num
	data.id = id
	i3k_game_send_str_cmd(data, "forcefame_donate_res")
end

function i3k_sbean.forcefame_donate_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("捐赠成功")
		g_i3k_ui_mgr:CloseUI(eUIID_UseItems)
		g_i3k_game_context:UseCommonItem(req.id, req.num, AT_COMMIT_POWER_REP)
		local tempInfo = g_i3k_game_context:getPowerRepUselessInfo()
		g_i3k_game_context:addPowerRepCommit(tempInfo.powerSide, req.order, req.num)
		local cfg = i3k_db_power_reputation_commit[tempInfo.powerSide][req.order]
		local rate = g_i3k_game_context:getPowerRepAddRepRate(tempInfo.powerSide)
		local powerRepCount = math.floor(cfg.reputation * rate / 10000) * req.num
		g_i3k_game_context:addPowerRep(tempInfo.powerSide, powerRepCount)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PowerReputationCommit, "setUI", tempInfo.powerSide)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PowerReputationCommit, "updateItemsCount", req.id)

		local t = {}
		local itemID = g_i3k_db.i3k_db_power_rep_get_itemID(tempInfo.powerSide)
		table.insert(t, {id = itemID, count = powerRepCount })
		if #(t) ~= 0 then
			g_i3k_ui_mgr:ShowGainItemInfo(t) -- 需要在套一层table
		end
	end
end
---------------------------------
-- 登陆同步
function i3k_sbean.role_festival_info.handler(res)
	g_i3k_game_context:setRoleFestivalInfo(res.gifts, res.belss)
end

-- 十全十美礼盒--结婚可以领取的礼盒
function i3k_sbean.getMarriageGift(id)
	local data = i3k_sbean.festival_takegift_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "festival_takegift_res")
end
function i3k_sbean.festival_takegift_res.handler(res, req)
	if res.ok > 0 then
		local cfg = i3k_db_activity_perfect[req.id]
		g_i3k_game_context:setRoleFestivalGifts(req.id)
		g_i3k_ui_mgr:ShowGainItemInfo({{id = cfg.itemID, count = cfg.itemCount}}) -- 需要在套一层table
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Marry_Marryed_Yinyuan, "checkGiftRedPoint")
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

-- 世界祝福
function i3k_sbean.getMarriageBlessGift(id, guid)
	local data = i3k_sbean.festival_bless_req.new()
	data.id = id
	data.guid = guid
	i3k_game_send_str_cmd(data, "festival_bless_res")
end
function i3k_sbean.festival_bless_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("祝福成功")
		g_i3k_game_context:addRoleFestivalBless(g_activity_show_world)
		local cfg = i3k_db_activity_world[req.id].rewards
		local t = {{id = cfg.itemID, count = cfg.itemCount}, {id = 1000, count = cfg.exp}, {id = 43, count = cfg.lilian} }
		local gets = {}
		local count = 0
		for k, v in ipairs(t) do
			if v.id ~= 0 and v.count ~= 0 then
				table.insert(gets, v)
				count = count + 1
			end
		end
		if count ~= 0 then
			g_i3k_ui_mgr:ShowGainItemInfo(gets)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_ShowLoveWish)
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("已经祝福过了")
	else
		g_i3k_ui_mgr:PopupTipMessage("祝福失败")
	end
end
---------------------------------
--充值获得折扣礼包购买权
function i3k_sbean.discount_buy_power_sync()
	local data = i3k_sbean.paydiscountgift_sync_req.new()
	data.id = g_DYNAMIC_ACTIVITY_TYPE
	i3k_game_send_str_cmd(data, "paydiscountgift_sync_res")
end

function i3k_sbean.paydiscountgift_sync_res.handler(res, req)	
	if res.ok > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_DisCountBuyPower)
		g_i3k_ui_mgr:RefreshUI(eUIID_DisCountBuyPower, res.info)
	end
end

function i3k_sbean.discount_buy_power_reward(info)
	local data = i3k_sbean.paydiscountgift_take_req.new()
	data.effectiveTime = info.time
	data.id = info.id
	data.payLevel = info.level
	data.info = info
	i3k_game_send_str_cmd(data, "paydiscountgift_take_res")
end

function i3k_sbean.paydiscountgift_take_res.handler(res, req)
	if res.ok > 0 then
		local info = req.info
		local oldGifts = info.gifts
		local gifts = {}
	
		for _, v in pairs(oldGifts) do
			table.insert(gifts, {id = v.id, count = v.count})
		end
	
		g_i3k_ui_mgr:ShowGainItemInfo(gifts)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DisCountBuyPower, "seBuyBtState", info.scollIndex)
		g_i3k_game_context:UseCommonItem(-g_BASE_ITEM_DIAMOND, info.cost, AT_DISCOUNT_BUY_POWER_GIFT)
	end
end
--end

-------------------
--同步登科有礼信息
function i3k_sbean.admission_sync_info(isFirstOpen)
	local data = i3k_sbean.admission_sync_info_req.new()
	data.isFirstOpen = isFirstOpen
	i3k_game_send_str_cmd(data, "admission_sync_info_res")
end

function i3k_sbean.admission_sync_info_res.handler(res, req)
	--self.dayTimes:		int32	
	--self.actStartTime:		int32	
	--self.rewardTimes:		map[int32, int32]	
	g_i3k_ui_mgr:OpenUI(eUIID_PassExamGift)
	g_i3k_ui_mgr:RefreshUI(eUIID_PassExamGift, res.info, req.isFirstOpen)
end

--卜算
function i3k_sbean.admission_conduct(item)
	local data = i3k_sbean.admission_conduct_req.new()
	data.item = item
	i3k_game_send_str_cmd(data, "admission_conduct_res")
end

function i3k_sbean.admission_conduct_res.handler(res, req)
	local rewardID = res.rewardId
	if rewardID > 0 then
		local item = req.item
		g_i3k_game_context:UseCommonItem(item.id, item.count, "")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PassExamGift, "playDiceAction", rewardID)
		local cfg = i3k_db_schedule.cfg
		local mapID = g_SCHEDULE_COMMON_MAPID
		for _, v in ipairs(cfg or {}) do
			if v.typeNum == g_SCHEDULE_TYPE_PASS_EXAM_GIGT then
				mapID = v.mapID
				break
			end
		end
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_PASS_EXAM_GIGT, mapID)
	else
		g_i3k_ui_mgr:PopupTipMessage("卜算失败")
	end
end

-- 每周限时宝箱同步数据
--[[
DBRoleWeekTreasureBox
    ├──lastRefreshTime (int32)
    └──logs map[int32, DBRoleWeekTreasureBoxLog]
       DBRoleWeekTreasureBoxLog
        ├──logCnt (int32)
        ├──isFinish (int32)
        ├──rewardTime (int32)
        ├──isTakedReward (int32)
        └──leftTakeCnt (int32)
]]
function i3k_sbean.week_treasure_box_sync.handler(res)
	--self.log:		DBRoleWeekTreasureBox
	local logs = res.log.logs

	local oldData = g_i3k_game_context:GetWeekLimitData()
	if next(oldData) then
		for k, v in pairs(logs) do
			local isFinish = oldData[k].isFinish
			if v.isFinish == 1 and v.isFinish ~= isFinish then
				if i3k_game_get_map_type() == g_FIELD then
					if not g_i3k_ui_mgr:GetUI(eUIID_WeekBoxGetTips) then
						g_i3k_ui_mgr:OpenUI(eUIID_WeekBoxGetTips)
						g_i3k_ui_mgr:RefreshUI(eUIID_WeekBoxGetTips, k, v)
					end
				else
					g_i3k_game_context:SetIsShowGetBoxTips(true)
					g_i3k_game_context:SetBoxTipsData({boxID = k, boxData = v})
				end
			end
		end
	end
	g_i3k_game_context:SetWeekLimitData(logs)
end

-- 领取宝箱
function i3k_sbean.week_treasure_box_take(taskID)
	--self.taskID:		int32	
	local data = i3k_sbean.week_treasure_box_take_req.new()
	data.taskID = taskID
	i3k_game_send_str_cmd(data, "week_treasure_box_take_res")
end

function i3k_sbean.week_treasure_box_take_res.handler(res, req)
	--self.ok:		int32	
	--self.drops:		map[int32, int32]	
	if res.ok > 0 then
		g_i3k_game_context:UpdateWeekLimitData(req.taskID)
		g_i3k_ui_mgr:RefreshUI(eUIID_KeepActivity, false)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance, "updateKeepUI")

		local rewards = {}
		for k, v in pairs(res.drops) do
			table.insert(rewards, {id = k, count = v})
		end
		g_i3k_ui_mgr:ShowGainItemInfo(rewards)
	elseif res.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(43))
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end
function i3k_sbean.lingqian_sync.handler(bean)
	g_i3k_game_context:SetLingQianUseCount(bean.useCnt)
end
function i3k_sbean.lingqian_get_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_game_context:AddLingQianUseCount(req.id)
		g_i3k_ui_mgr:RefreshUI(eUIID_LingQianQiFuDialog)
		g_i3k_ui_mgr:OpenUI(eUIID_LingQianAnimation)
		g_i3k_ui_mgr:RefreshUI(eUIID_LingQianAnimation, res.dropID)
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_LING_QIAN, req.npcID)
	else
		g_i3k_ui_mgr:PopupTipMessage("祈福失败")
	end
end
--同步摇一摇
function i3k_sbean.money_tree_open(moneyTreeId)
	local data = i3k_sbean.money_tree_open_req.new()
	data.moneyTreeId = moneyTreeId
	i3k_game_send_str_cmd(data, "money_tree_open_res")
end

function i3k_sbean.money_tree_open_res.handler(res, req)
	--打开ui
	--DBRoleMoneyTree
		--self.moneyTreeId:		int32	
		--self.dayCnt:		int32	
		--self.lastGetTime:		int32	
		--self.totalGetCnt:		int32	
		--self.addUpRewards:		vector[int32]
	g_i3k_ui_mgr:OpenUI(eUIID_ShakeTree)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShakeTree, res.moneyTree)
end

--每日摇一摇
function i3k_sbean.money_tree_shake(moneyTreeId, npcID)
	local data = i3k_sbean.money_tree_shake_req.new()
	data.moneyTreeId = moneyTreeId
	data.npcID = npcID
	data.callback = callback
	i3k_game_send_str_cmd(data, "money_tree_shake_res")
end

function i3k_sbean.money_tree_shake_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_SHAKE_TREE, req.npcID)

		local rewards = res.rewards
		local moneyTreeId = req.moneyTreeId

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShakeTree, "playShakeAction")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShakeTree, "setUIBtnState", false)
		local co = g_i3k_coroutine_mgr:StartCoroutine(function()
			g_i3k_coroutine_mgr.WaitForSeconds(2) --播完特效再弹奖励面板
			g_i3k_ui_mgr:ShowGainItemInfo_safe(rewards)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShakeTree, "setUIBtnState", true)
			i3k_sbean.money_tree_open(moneyTreeId)
			g_i3k_coroutine_mgr:StopCoroutine(co)
			co = nil
		end)
	end
end

--领取累积奖励
function i3k_sbean.money_tree_get_add_up(moneyTreeId, addUpCnt, rewards)
	local data = i3k_sbean.money_tree_get_add_up_req.new()
	data.moneyTreeId = moneyTreeId
	data.addUpCnt = addUpCnt
	data.rewards = rewards
	i3k_game_send_str_cmd(data, "money_tree_get_add_up_res")
end

function i3k_sbean.money_tree_get_add_up_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:ShowGainItemInfo_safe(req.rewards)
		i3k_sbean.money_tree_open(req.moneyTreeId)
	end
end
function i3k_sbean.item_history_sync()
	local bean = i3k_sbean.item_history_sync_req.new()
	i3k_game_send_str_cmd(bean, "item_history_sync_res")
end
function i3k_sbean.item_history_sync_res.handler(bean)
	g_i3k_ui_mgr:OpenUI(eUIID_RecentlyGet)
	g_i3k_ui_mgr:RefreshUI(eUIID_RecentlyGet, bean.history)
end
function i3k_sbean.activity_history_sync()
	local bean = i3k_sbean.schdule_log_sync_req.new()
	i3k_game_send_str_cmd(bean, "schdule_log_sync_res")
end
function i3k_sbean.schdule_log_sync_res.handler(res, req)
	g_i3k_ui_mgr:OpenUI(eUIID_RecentlyGet)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_RecentlyGet, "addActivityItems", res.logs)
end
--宝石转化
function i3k_sbean.gem_exchange(gemID, toID, cost)
	local bean = i3k_sbean.gem_trans_req.new()
	bean.gemID = gemID
	bean.toID = toID
	bean.cost = cost
	i3k_game_send_str_cmd(bean, "gem_trans_res")
end
function i3k_sbean.gem_trans_res.handler(bean, req)	
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18072))
		g_i3k_game_context:UseCommonItem(req.gemID, 1, AT_USE_ITEM_GEM_EXCHANGE)
		for _, v in ipairs(req.cost) do
			if v.id ~= 0 and v.count ~= 0 then
				g_i3k_game_context:UseCommonItem(v.id, v.count, AT_USE_ITEM_GEM_EXCHANGE)
			end
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_GemExchangeShow)
	end
end
--end
--cpr复活
function i3k_sbean.role_revive_cpr()
	local bean = i3k_sbean.role_revive_cpr_req.new()
	i3k_game_send_str_cmd(bean, "role_revive_cpr_res")
end
function i3k_sbean.role_revive_cpr_res.handler(res, req)	
	if res.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_PlayerRevive)
		g_i3k_game_context:AddCprReviveTimes()
	end
end
----------------图鉴--------------------
-- 登陆同步卡包信息
function i3k_sbean.role_card_packet.handler(res)
	local startLevel = i3k_db_cardPacket.startLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel >= startLevel then
		local info = res.info
		g_i3k_game_context:setCardPacketInfo(info)
	end
end
-- 卡牌解锁推送
function i3k_sbean.card_unlock_push.handler(res)
	local startLevel = i3k_db_cardPacket.startLevel
	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel >= startLevel then
		local id = res.id
		local cardID = id
		local cfg = g_i3k_db.i3k_db_cardPacket_get_card_cfg(cardID)
		g_i3k_logic:OpenCardPacketPushUnlockUI(cardID)
		g_i3k_game_context:unlockCard(id)
		g_i3k_game_context:refreshCardPacketProps()
	end
end
-- 使用卡牌道具, 解锁卡牌
function i3k_sbean.useCardItem(id, needItems, itemID)
	local data = i3k_sbean.card_item_use_req.new()
	data.id = itemID
	data.cardID = id
	data.needItems = needItems
	i3k_game_send_str_cmd(data, "card_item_use_res")
end
function i3k_sbean.card_item_use_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("解锁卡牌成功")
		g_i3k_ui_mgr:CloseUI(eUIID_CardPacketUnlock)
		g_i3k_ui_mgr:CloseUI(eUIID_CardPacketShow)
		for k, v in ipairs(req.needItems) do
			g_i3k_game_context:UseCommonItem(v.id, v.count)
		end
		g_i3k_game_context:unlockCard(req.cardID)
		g_i3k_game_context:refreshCardPacketProps()
		g_i3k_ui_mgr:RefreshUI(eUIID_CardPacket)
	else
		g_i3k_ui_mgr:PopupTipMessage("卡牌id："..req.cardID.."，解锁卡牌失败"..res.ok)
	end
end
--  解锁卡背
function i3k_sbean.unlockCardBack(id, needItems)
	local data = i3k_sbean.card_back_unlock_req.new()
	data.id = id
	data.needItems = needItems
	i3k_game_send_str_cmd(data, "card_back_unlock_res")
end
function i3k_sbean.card_back_unlock_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("解锁卡背成功")
		for k, v in ipairs(req.needItems) do
			g_i3k_game_context:UseCommonItem(v.id, v.count)
		end
		g_i3k_game_context:unlockCardBack(req.id)
		g_i3k_ui_mgr:CloseUI(eUIID_CardPacketUnlock)
		g_i3k_ui_mgr:RefreshUI(eUIID_CardPacketBack)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CardPacket, "updateCardBackRed")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CardPacket, "updateRightRedPoint")
	else
		g_i3k_ui_mgr:PopupTipMessage("卡背id："..req.id.."，解锁卡背失败"..res.ok)
	end
end
--  选择卡背
function i3k_sbean.selectCardBack(id)
	local data = i3k_sbean.card_back_select_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "card_back_select_res")
end
function i3k_sbean.card_back_select_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("更换卡背成功")
		g_i3k_game_context:setCurCardBack(req.id)
		g_i3k_ui_mgr:RefreshUI(eUIID_CardPacketBack)
	end
end
-------------------------------------
----收藏兑换
function i3k_sbean.collect_exchange_item(npcId, exchangeId, cb)
	local bean = i3k_sbean.collect_exchange_item_req.new()
	bean.npcId = npcId
	bean.exchangeId = exchangeId
	bean.cb = cb
	i3k_game_send_str_cmd(bean, "collect_exchange_item_res")
end
function i3k_sbean.collect_exchange_item_res.handler(res, req)
	if res.ok > 0 then
		if req.cb then
			req.cb(req.npcId, req.exchangeId)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("收藏失败")
	end
end
function i3k_sbean.cancel_collect_exchange_item(npcId, exchangeId, cb)
	local bean = i3k_sbean.cancel_collect_exchange_item_req.new()
	bean.npcId = npcId
	bean.exchangeId = exchangeId
	bean.cb = cb
	i3k_game_send_str_cmd(bean, "cancel_collect_exchange_item_res")
end
function i3k_sbean.cancel_collect_exchange_item_res.handler(res, req)
	if res.ok > 0 then
		if req.cb then
			req.cb(req.npcId, req.exchangeId)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("取消失败")
	end
end
---------------新转盘抽奖---------
function i3k_sbean.newluckyroll_sync()
	local bean = i3k_sbean.newluckyroll_sync_req.new()
	i3k_game_send_str_cmd(bean, "newluckyroll_sync_res")
end
function i3k_sbean.newluckyroll_sync_res.handler(bean)
	if bean.ok > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_LotteryNew)
		g_i3k_ui_mgr:RefreshUI(eUIID_LotteryNew, bean.infos)
	end
end
function i3k_sbean.newluckyroll_play(infos, isSingle)
	local bean = i3k_sbean.newluckyroll_play_req.new()
	bean.effectiveTime = infos.effectiveTime
	bean.id = infos.cfg.id
	bean.mutiplay = isSingle and 0 or 1
	bean.infos = infos
	i3k_game_send_str_cmd(bean, "newluckyroll_play_res")
end
function i3k_sbean.newluckyroll_play_res.handler(bean, req)
	if bean.ok > 0 then
		-- bean.rewards
		local info = req.infos
		local cfg = info.cfg
		local isMutiply = req.mutiplay == 1
		g_i3k_game_context:UseCommonItem(cfg.cost, isMutiply and cfg.mutiCost or cfg.singleCost)
		info.playTimes = info.playTimes + (isMutiply and cfg.mutiTimes or 1)
		g_i3k_ui_mgr:RefreshUI(eUIID_LotteryNew, info)
		local getItemName = g_i3k_db.i3k_db_get_common_item_name(cfg.giftex.id)
		local getItemCount = cfg.giftex.count * (isMutiply and cfg.mutiTimes or 1)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5908, getItemName, getItemCount))		
 		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LotteryNew, "wrapRewardToShow", bean.rewards)
	end
end
function i3k_sbean.sync_invitation_settings_info.handler(bean)
	g_i3k_game_context:syncInviteListSetting(bean)
end
function i3k_sbean.set_invite_list_setting(type, hide)
	local bean = i3k_sbean.invitation_relevant_settings_req.new()
	bean.inviteType = type
	bean.hide = hide
	i3k_game_send_str_cmd(bean, "invitation_relevant_settings_res")
end
function i3k_sbean.invitation_relevant_settings_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:updateInviteListSetting(req.inviteType)
		g_i3k_ui_mgr:RefreshUI(eUIID_InviteSetting, "updateState")
	end
end
---鬼岛驭灵
--碎片交换请求
function i3k_sbean.ghost_island_exchange(costId, costCount, targetId)
	local bean = i3k_sbean.ghost_island_exchange_req.new()
	bean.costId = costId
	bean.costCount = costCount
	bean.targetId = targetId
	i3k_game_send_str_cmd(bean, "ghost_island_exchange_res")
end
function i3k_sbean.ghost_island_exchange_res.handler(res, req)
	if res.ok == 1 then --等待
		g_i3k_game_context:SetSpiritsDataInExchanging(req)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpriteFragmentExchange, "UpdateExchangeType")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpriteFragmentExchange, "openFastClickCheck")
	elseif res.ok == 2 then	--立即成功
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18622))
		g_i3k_game_context:SetSpiritsDataOnExchangeComplete(req)
		g_i3k_ui_mgr:RefreshUI(eUIID_SpriteFragmentExchange, {targetId = 0, costId = 0})
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpriteFragmentBag, "showDataByIndex", 2)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CatchSpiritTask, "updateCatchCount")
	else
		g_i3k_game_context:SetSpiritsIsExchangeComplete(g_SPIRIT_STATE_FAIL)
	end
end
--取消碎片交换请求
function i3k_sbean.ghost_island_exchange_cancle()
	local bean = i3k_sbean.ghost_island_exchange_cancle_req.new()
	i3k_game_send_str_cmd(bean, "ghost_island_exchange_cancle_res")
end
function i3k_sbean.ghost_island_exchange_cancle_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetSpritesDataSwapaLastTime(0)
		g_i3k_game_context:SetSpiritsInExchangeData(0, 0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpriteFragmentExchange, "UpdateExchangeType")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpriteFragmentExchange, "openFastClickCheck")
	end
end
--炼化请求
function i3k_sbean.ghost_island_artifice(debrisId)
	local bean = i3k_sbean.ghost_island_artifice_req.new()
	bean.debrisId = debrisId
	i3k_game_send_str_cmd(bean, "ghost_island_artifice_res")
end
function i3k_sbean.ghost_island_artifice_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:ResetSpiritsBag()
		g_i3k_game_context:UpdateLianHuaNum(-1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpriteFragmentBag, "onLianHuaCompelte")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CatchSpiritTask, "updateCatchCount")
	end
end
--打开界面同步信息
function i3k_sbean.ghost_island_info()
	local bean = i3k_sbean.ghost_island_info_req.new()
	i3k_game_send_str_cmd(bean, "ghost_island_info_res")
end
function i3k_sbean.ghost_island_info_res.handler(res, req)
	g_i3k_game_context:SetSpiritsData(res.info)
	g_i3k_ui_mgr:OpenUI(eUIID_SpriteFragmentBag)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpriteFragmentBag)
end
--驭灵召唤
function i3k_sbean.send_ghost_spirit_summoned(pointId)
	local bean = i3k_sbean.ghost_spirit_summoned.new()
	bean.pointId = pointId
	i3k_game_send_str_cmd(bean)
end
--学习驭灵和天眼技能 1 御灵2天眼
function i3k_sbean.ghost_island_learn_skill(id)
	local bean = i3k_sbean.ghost_island_learn_skill_req.new()
	bean.id = id
	i3k_game_send_str_cmd(bean, "ghost_island_learn_skill_res")
end
function i3k_sbean.ghost_island_learn_skill_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setGhostSkillState(req.id)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LearnCatchSpiritSkills, "updateSkills")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LearnCatchSpiritSkills, "learnSkillSuccess")
		--[[g_i3k_ui_mgr:OpenUI(eUIID_CatchSpiritAnimate)
		g_i3k_ui_mgr:RefreshUI(eUIID_CatchSpiritAnimate)--]]
	end
end
----离线经验设置当天是否隐藏---
function i3k_sbean.hide_offlineexp_display(hide)
	local bean = i3k_sbean.hide_offlineexp_display_req.new()
	bean.hide = hide
	i3k_game_send_str_cmd(bean, "hide_offlineexp_display_res")
end
function i3k_sbean.hide_offlineexp_display_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:setIsHideOfflineExp(req.hide)
	end
end


-----------新节日活动-------------------

----登录同步
function i3k_sbean.time_limit_task_login_sync.handler(bean, req)
	g_i3k_game_context:syncLoginNewFestivalTaskInfo(bean.tasks)
end

--领取任务
function i3k_sbean.new_festival_time_limi_task_take(npcID)
	local data = i3k_sbean.time_limit_task_take_req.new()
	data.id = npcID
	i3k_game_send_str_cmd(data, "time_limit_task_take_res")
end

function i3k_sbean.time_limit_task_take_res.handler(bean, req)
	if bean.id > 0 then
 		local npcId = req.id
		local taskId = bean.id
		g_i3k_game_context:receiveNewFestivalTask(npcId, taskId)
		g_i3k_ui_mgr:OpenUI(eUIID_FestivalTaskAccept)
		g_i3k_ui_mgr:RefreshUI(eUIID_FestivalTaskAccept, npcId, taskId)
	else
		g_i3k_ui_mgr:PopupTipMessage("任务接受失败")
	end
end
--开启任务
function i3k_sbean.new_festival_time_limi_task_start(npcID)
	local data = i3k_sbean.time_limit_task_start_req.new()
	data.id = npcID
	i3k_game_send_str_cmd(data, "time_limit_task_start_res") 
end

function i3k_sbean.time_limit_task_start_res.handler(bean, req)
	if bean.ok > 0 then
	   	g_i3k_ui_mgr:PopupTipMessage("成功接受任务")

		g_i3k_game_context:StartNewFestivalTask(req.id)
		g_i3k_logic:ChangePowerRepNpcTitleVisible(req.id, false)
		g_i3k_ui_mgr:CloseUI(eUIID_FestivalTaskAccept)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "updateTaskInfo")
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_NEW_FESTIVAL, 0)
	else
		g_i3k_ui_mgr:PopupTipMessage("任务接受失败")
	end
end

--完成任务
function i3k_sbean.new_festival_time_limit_task_finish(npcId)
	local data = i3k_sbean.time_limit_task_finish_req.new()
	data.id = npcId
	i3k_game_send_str_cmd(data, "time_limit_task_finish_res")
end

function i3k_sbean.time_limit_task_finish_res.handler(bean, req)
	if bean.ok > 0 then 
		g_i3k_ui_mgr:PopupTipMessage("任务完成")
		g_i3k_ui_mgr:OpenUI(eUIID_BattleTXFinishTask)

		local taskInfo = g_i3k_game_context:getNewFestival_task(req.id)
		local hash = g_i3k_db.i3k_db_get_new_festival_task_hash_id(taskInfo.id)
		
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask, "removeTaskItem", hash)
		
		g_i3k_game_context:setNewFestivalTaskState(hash, req.id, 3)   -- 接取1， 0未接取，2完成，3领过奖了
		g_i3k_game_context:AddFinishTaskRewards(taskInfo.id)   
	end
end

--节日活动信息同步
function i3k_sbean.new_festival_activity_sync_req(openUi)
	local data = i3k_sbean.festival_activity_sync_req.new()
	data.show = openUi
	i3k_game_send_str_cmd(data, "festival_activity_sync_res")
end

function i3k_sbean.festival_activity_sync_res.handler(bean, req)
	g_i3k_game_context:syncLoginNewFestivalPersonInfo(bean.roleInfo)  
	g_i3k_game_context:SetNewFestivalActiveServerScore(bean.worldScore) 
	
	if req.show then 
		g_i3k_ui_mgr:OpenUI(eUIID_FestivalActivityUI)
		g_i3k_ui_mgr:RefreshUI(eUIID_FestivalActivityUI)
	end
end

--节日活动捐赠
function   i3k_sbean.new_festival_activity_donate(commitItems)
	local data = i3k_sbean.festival_activity_donate_req.new()
	data.items = commitItems
	data.roleScore =  g_i3k_game_context:GetNewFestivalActivePersonScore()  
	data.wordScore = g_i3k_game_context:GetNewFestivalActiveServerScore()  
	i3k_game_send_str_cmd(data, "festival_activity_donate_res")
end

function i3k_sbean.festival_activity_donate_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18993))
		local addScore = 0
		for k,v in pairs(req.items) do
			local info = i3k_db_new_festival_commit_Items[k]
			addScore = addScore + v * info.commitValue
			g_i3k_game_context:UseBagMiscellaneous(info.itemId, v)
		end
		local wordScore = req.wordScore
		local roleScore = req.roleScore
		local maxValue = i3k_db_new_festival_info.maxCommitVallue
		wordScore = wordScore + addScore
		wordScore = maxValue > wordScore and wordScore or maxValue
		roleScore = roleScore + addScore
		g_i3k_game_context:SetNewFestivalActivePeronScore(roleScore)  
		g_i3k_game_context:SetNewFestivalActiveServerScore(wordScore)  
		g_i3k_ui_mgr:RefreshUI(eUIID_FestivalActivityUI)
		g_i3k_ui_mgr:CloseUI(eUIID_FestivalTaskCommit)

		-- g_i3k_game_context:CheckSpecialShowNpc()

	end
end

--个人积分奖励
function   i3k_sbean.festival_activity_role_reward(score, rewards)
	local data = i3k_sbean.festival_activity_role_reward_req.new()
	data.score = score
	data.rewards = rewards
	i3k_game_send_str_cmd(data, "festival_activity_role_reward_res")
end

function i3k_sbean.festival_activity_role_reward_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:SetNewFestivalActivePersonReward(req.score)  
		g_i3k_game_context:AddReveivedRewards_Person(req.rewards) 
		g_i3k_ui_mgr:RefreshUI(eUIID_FestivalActivityUI)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18998))
	end
	
end

--世界积分奖励
function   i3k_sbean.festival_activity_world_reward(score, rewards)
	local data = i3k_sbean.festival_activity_world_reward_req.new()
	data.score = score
	data.rewards = rewards
	i3k_game_send_str_cmd(data, "festival_activity_world_reward_res")
end

function i3k_sbean.festival_activity_world_reward_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:SetNewFestivalActiveServerReward(req.score)  
		g_i3k_game_context:AddReveivedRewards_Person(req.rewards) 
		g_i3k_ui_mgr:RefreshUI(eUIID_FestivalActivityUI)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18998))
	end
end

--同步圣诞树积分信息
function i3k_sbean.festival_activity_score_push.handler(bean, req)
	g_i3k_game_context:SetNewFestivalActiveServerScore(bean.score)
	g_i3k_game_context:CheckSpecialShowNpc()
end
-----------新节日活动 END-------------------=======

