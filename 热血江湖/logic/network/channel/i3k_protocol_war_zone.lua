------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------
local ErrorCode = {
	[-201] = 5738,
	[-202] = 5739,
	[-203] = 5740,
	[-204] = 5741,
	[-205] = 5742,
	[-206] = 5743,
	[-207] = 5744,
	[-208] = 5745,
	[-1]	= 5591,
	[-2]	= 5592,
	[-3]	= 5593,
	[-4]	= 5594,
}

--错误码提示
local function ErrorCodeTips(result)
	if ErrorCode[result] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(ErrorCode[result]))
	end
end

-- 进入黄金海岸
function i3k_sbean.global_world_enter(mapID)
	if i3k_check_resources_downloaded(mapID) then
		local data = i3k_sbean.global_world_enter_req.new()
		data.mapID = mapID
		i3k_game_send_str_cmd(data, "global_world_enter_res")
	end
end

function i3k_sbean.global_world_enter_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:ClearFindWayStatus()
	else
		ErrorCodeTips(bean.ok)
	end
end

-- 同步地图信息
function i3k_sbean.global_world_sync()
	local data = i3k_sbean.global_world_sync_req.new()
	i3k_game_send_str_cmd(data, "global_world_sync_res")
end

function i3k_sbean.global_world_sync_res.handler(bean)
	if bean.ok == 1 then
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_WarZoneLine, bean.worlds)
	else
		ErrorCodeTips(bean.ok)
	end
end

-- 切换分线
function i3k_sbean.global_world_change(mapID, line)
	local data = i3k_sbean.global_world_change_req.new()
	data.mapID = mapID
	data.line = line
	i3k_game_send_str_cmd(data, "global_world_change_res")
end

function i3k_sbean.global_world_change_res.handler(bean)
	if bean.ok == 1 then
		g_i3k_game_context:ClearFindWayStatus()
	else
		if bean.ok == -2 then
			i3k_sbean.global_world_sync()
		end
		ErrorCodeTips(bean.ok)
	end
end

-------------------------卡片-----------------------

-- 登陆同步黄金海岸角色卡片信息
function i3k_sbean.global_world_login_sync.handler(bean)
	--self.card:		DBGlobalWorldCard	
	--self.card2DayUseCount:		map[int32, int32]	
	--self.card2DaySectDrawCount:		map[int32, int32]	
	--self.daySectDonateCount:		int32
	g_i3k_game_context:SetWarZoneCardInfo(bean)	
end

function i3k_sbean.global_world_role_card_sync.handler(bean)
	g_i3k_game_context:WarZoneCardSync(bean)
end

--卡片日志
function i3k_sbean.global_world_log(logType, callBack)
	local data = i3k_sbean.global_world_log_req.new()
	data.type = logType
	data.callBack = callBack
	i3k_game_send_str_cmd(data, "global_world_log_res")
end

function i3k_sbean.global_world_log_res.handler(bean, req)
	--self.event:		int8	
	--self.cards:		vector[int32]	
	--self.timestamp:		int32	
	--self.arg1:		int32	
	--self.arg2:		int32	
	--self.strArg1:		string	
	--self.strArg2:		string	
	g_i3k_game_context:SetWarZoneCardLog(bean.log, req.type)
	if req.callBack then
		req.callBack()
	end
end

--卡片使用
function i3k_sbean.global_world_card_operation(type, cardID)
	--self.type:		int8	
	--self.cardID:		int32	
	local  data = i3k_sbean.global_world_card_operation_req.new()
	data.type = type
	data.cardID = cardID
	i3k_game_send_str_cmd(data, "global_world_card_operation_res")
end 

function i3k_sbean.global_world_card_operation_res.handler(bean, req)
	if bean.ok == 1 then
		if req.type == g_WAR_ZONE_CARD_GIVE_UP then
			g_i3k_game_context:SetWarZoneCardInvalid(req.cardID)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5775))
		elseif req.type == g_WAR_ZONE_CARD_ACTIVATION then
			g_i3k_game_context:SetWarZonePersonalCardUse(req.cardID)
			g_i3k_game_context:WarZoneCardSetData(req.cardID)
			--g_i3k_ui_mgr:OpenUI(eUIID_WarZoneCardShow)
			--g_i3k_ui_mgr:RefreshUI(eUIID_WarZoneCardShow, req.cardID)
			g_i3k_ui_mgr:PopupTipMessage(i3k_db.i3k_db_get_card_tip(req.cardID))
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WarZoneCard, "updateCardItem", req.cardID, req.type)
		if bean.drops and table.nums(bean.drops) > 0 then
			g_i3k_ui_mgr:ShowGainItemInfo(bean.drops)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WarZoneCard, "updateRed")
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5730))
		--ErrorCodeTips(bean.ok)
	end
end

--帮派卡片捐赠
function i3k_sbean.global_world_card_sect_donate(cardID)
	local data = i3k_sbean.global_world_card_sect_donate_req.new()
	data.cardID = cardID
	i3k_game_send_str_cmd(data, "global_world_card_sect_donate_res")
end

function i3k_sbean.global_world_card_sect_donate_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetWarZonePersonalCardUse(req.cardID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WarZoneCard, "updateCardItem", req.cardID)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5731))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WarZoneCard, "updateRed")
	else
		ErrorCodeTips(bean.ok)
	end
end

--帮派卡池
function i3k_sbean.global_world_sect_panel(callBack, isGetData)
	local  data = i3k_sbean.global_world_sect_panel_req.new()
	data.callBack = callBack
	data.isGetData = isGetData
	i3k_game_send_str_cmd(data, "global_world_sect_panel_res")
end

function i3k_sbean.global_world_sect_panel_res.handler(bean, req)
	g_i3k_game_context:SetWarZoneFactionCardPool(bean.card2Inventory)
	if table.nums(bean.card2Inventory) > 0 or req.isGetData then
		if req.callBack then
			req.callBack()
		end
	else 
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5732))
	end
end

--帮派卡领取
function i3k_sbean.global_world_sect_drawcard(cardID)
	local data = i3k_sbean.global_world_sect_drawcard_req.new()
	data.cardID = cardID
	i3k_game_send_str_cmd(data, "global_world_sect_drawcard_res")
end

function i3k_sbean.global_world_sect_drawcard_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetWarZoneFactionCardGet(req.cardID)
		g_i3k_game_context:WarZoneCardSetData(req.cardID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WarZoneCard, "updateFactionItem", req.cardID)
		if bean.drops and table.nums(bean.drops) > 0 then
			g_i3k_ui_mgr:ShowGainItemInfo(bean.drops)
		end
		g_i3k_ui_mgr:PopupTipMessage(i3k_db.i3k_db_get_card_tip(req.cardID))
	else
		ErrorCodeTips(bean.ok)
	end
	i3k_sbean.global_world_sect_panel(function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WarZoneCard, "updateFactionItem", req.cardID)
	end, true)
end

--道具领卡
function i3k_sbean.global_world_use_card_box(id)
	local data = i3k_sbean.global_world_use_card_box_req.new()
	data.id = id
	data.count = 1
	i3k_game_send_str_cmd(data, "global_world_use_card_box_res")
end

function i3k_sbean.global_world_use_card_box_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseItemData(req.id, req.count,nil,AT_USE_WAR_ZONE_CARD_ITEM)
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(req.id)
		if cfg then
			g_i3k_ui_mgr:OpenUI(eUIID_WarZoneCardShow)
			g_i3k_ui_mgr:RefreshUI(eUIID_WarZoneCardShow, cfg.args1, true)
		end
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5734))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5735))
	end
end

--卡的通知
function i3k_sbean.global_world_notice_card_drop.handler(bean)
	if bean.addOrRemove == 0 then
		g_i3k_game_context:onSyncWarZoneCardTip(bean.id)
		if not g_i3k_ui_mgr:GetUI(eUIID_Loading) and not g_i3k_ui_mgr:GetUI(eUIID_WarZoneCardGetShow) then
			g_i3k_logic:OpenWarZoneCardGetShow(bean.id)
		end
		local cfg = i3k_db_war_zone_map_card[bean.id]
		if cfg then
			local grade = i3k_db_war_zone_map_cfg.cardGrade
			g_i3k_ui_mgr:PopupTipMessage("获得" ..i3k_get_string(grade[cfg.grade].tipDesc) .. cfg.name)
		end
	end
end
