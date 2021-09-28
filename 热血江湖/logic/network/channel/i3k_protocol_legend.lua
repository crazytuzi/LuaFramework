------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------

-- 同步打造界面信息打造
function i3k_sbean.legend_sync()
	local bean = i3k_sbean.legend_sync_req.new()
	i3k_game_send_str_cmd(bean, "legend_sync_res")
end

-- 同步打造界面信息打造(equip:当前正在打造的装备, legends:当前打造出来的属性)
function i3k_sbean.legend_sync_res.handler(bean)
	-- g_i3k_ui_mgr:OpenUI(eUIID_MakeLegendEquip)
	-- g_i3k_ui_mgr:RefreshUI(eUIID_MakeLegendEquip, bean.equip, bean.legends)
	g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
	g_i3k_ui_mgr:OpenUI(eUIID_LegendEquip)
	g_i3k_ui_mgr:RefreshUI(eUIID_LegendEquip, bean.equip, bean.legends)
end

-- 打造传世装备
function i3k_sbean.legend_make(id, guid, costItem, oldLegends)
	local data = i3k_sbean.legend_make_req.new()
	data.id = id
	data.guid = guid
	data.costItem = costItem
	data.oldLegends = oldLegends
	i3k_game_send_str_cmd(data, "legend_make_res")
end

function i3k_sbean.legend_make_res.handler(bean, req)
	if bean.legends then
		g_i3k_game_context:UseCommonItem(req.costItem, 1, AT_MAKE_LEGEND_COST)
		g_i3k_game_context:DelBagEquip(req.id, req.guid, AT_MAKE_LEGEND_COST)
		-- g_i3k_ui_mgr:InvokeUIFunction(eUIID_MakeLegendEquip, "updateRightComparDetail", bean.legends)
		-- g_i3k_ui_mgr:InvokeUIFunction(eUIID_MakeLegendEquip, "updateNeedItem")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LegendEquip, "playMakeSuccess", req.id, req.guid, req.oldLegends, bean.legends, bean.giftReward)
	else
		g_i3k_ui_mgr:PopupTipMessage("打造失败")
	end
end

-- 放弃传世装备属性
function i3k_sbean.legend_quit()
	local data = i3k_sbean.legend_quit_req.new()
	i3k_game_send_str_cmd(data, "legend_quit_res")
end

function i3k_sbean.legend_quit_res.handler(bean, req)
	if bean.ok == 1 then
		-- g_i3k_ui_mgr:CloseUI(eUIID_LegendEquip)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LegendEquip, "saveOrQuitCallback")
	end
end

-- 保存传世装备属性
function i3k_sbean.legend_save()
	local data = i3k_sbean.legend_save_req.new()
	i3k_game_send_str_cmd(data, "legend_save_res")
end

function i3k_sbean.legend_save_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:PopupTipMessage("保存成功")
		-- g_i3k_ui_mgr:CloseUI(eUIID_LegendEquip)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_LegendEquip, "saveOrQuitCallback")
	end
end


---------------装备淬锋----------------------
function i3k_sbean.equipSharpen(id, guid, pos, locks, isFlying)
	local data = i3k_sbean.equip_quench_req.new()
	data.id = id
	data.guid = guid
	data.pos = pos
	data.lockedproppos = locks
	data.isFlying = isFlying
	i3k_game_send_str_cmd(data, "equip_quench_res")
end
function i3k_sbean.equip_quench_res.handler(bean, req)
	if bean.props then
		if req.isFlying then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlyingEquipSharpen, "setSharpenScroll", bean.props)
		else
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipSharpen, "setSharpenScroll", bean.props)
		end
		local cfg = g_i3k_db.i3k_db_get_equip_item_cfg(req.id)
		local consume = g_i3k_db.i3k_db_get_equip_sharpen_need_items(cfg.partID, #req.lockedproppos)
		for i, v in ipairs(consume) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, AT_EQUIP_QUENCH)
		end
		if req.isFlying then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlyingEquipSharpen, "setConsumeData")
		else
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipSharpen, "gengxinUi")
		end
	end
end
-- 装备淬锋保存
function i3k_sbean.saveEquipSharpen(id, guid, pos, isFlying)
	local data = i3k_sbean.equip_quench_save_req.new()
	data.id = id
	data.guid = guid
	data.pos = pos
	data.isFlying = isFlying
	i3k_game_send_str_cmd(data, "equip_quench_save_res")
end
function i3k_sbean.equip_quench_save_res.handler(bean, req)
	if bean.ok > 0 then
	g_i3k_ui_mgr:PopupTipMessage("保存成功")
	-- 更新客户端中新装备的属性
		if req.isFlying then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlyingEquipSharpen, "savaSharpenCallback", req.id, req.guid)
		else
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipSharpen, "savaSharpenCallback", req.id, req.guid)
		end
	end
end
