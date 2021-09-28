------------------------------------------------------
module(..., package.seeall)

local require = require
require("i3k_sbean")
--[[
<strchannel name="S2C">
<packet name="transform_active_res">
激活幻形
<field name="ok" type="int32"/>
</packet>
<packet name="transform_set_res">
设置当前幻形
<field name="ok" type="int32"/>
</packet>
<packet name="transform_use_res">
使用当前幻形
<field name="ok" type="int32"/>
</packet>
<!--  gmap 发往客户端的相关协议  -->
</strchannel>
<strchannel name="C2S">
<packet name="transform_active_req">
激活幻形
<field name="transformID" type="int32"/>
</packet>
<packet name="transform_set_req">
设置当前幻形
<field name="transformID" type="int32"/>
</packet>
<packet name="transform_use_req">
使用当前幻形(use 1:使用 0:取消使用)
<field name="use" type="int32"/>
</packet>]]

--激活幻形
function i3k_sbean.bag_metamorphosis_activation(id)
	local data = i3k_sbean.transform_active_req.new()
	data.itemID = id
	i3k_game_send_str_cmd(data, "transform_active_res")
end

--使用幻形
function i3k_sbean.metamorphosis_use(state)
	local data = i3k_sbean.transform_use_req.new()
	data.use = state
	i3k_game_send_str_cmd(data, "transform_use_res")
end

--设置当前幻形
function i3k_sbean.metamorphosis_set(id)
	local data = i3k_sbean.transform_set_req.new()
	data.transformID = id
	i3k_game_send_str_cmd(data, "transform_set_res")
end


function i3k_sbean.transform_set_res.handler(bean, req)
	if bean.ok >0 then
		local hero = i3k_game_get_player_hero()
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetWearMetamorphosisData(req.transformID)
		if hero then
			hero:UpdateMetamorphosisProps()
		end
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionDress, "updateRolePower")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionDress, "updateIsShowFashion")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateAllSkills")
		local use =  g_i3k_game_context:GetMetamorphosisState()
		if use == 1 then
			if hero then
				local id =  i3k_db_metamorphosis[req.transformID].changeID
				hero:MissionMode(true, id, 0)
			end
		end	
	end
end

--激活幻形
function i3k_sbean.transform_active_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:SetUseMetamorphosisData(req.itemID)
	end
end


function i3k_sbean.transform_use_res.handler(bean, req)
	if bean.ok >0 then	
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1571))
	else		
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1572))
		
	end
end

