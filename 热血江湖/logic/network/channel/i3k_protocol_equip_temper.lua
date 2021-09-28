------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")
------------------------------------------------------

--装备锤炼解锁
function i3k_sbean.equip_smelting_unlock(eid, guid, pos)
	local bean = i3k_sbean.equip_smelting_unlock_req.new()
	bean.eid = eid
	bean.guid = guid
	bean.pos = pos
	i3k_game_send_str_cmd(bean, i3k_sbean.equip_smelting_unlock_res.getName())
end

function i3k_sbean.equip_smelting_unlock_res.handler(bean, req)
	if bean.props and next(bean.props) then
		local consume = g_i3k_db.i3k_db_get_equip_temper_unlock_consume_by_id(req.eid)
		for k, v in pairs(consume) do
			g_i3k_game_context:UseCommonItem(v.itemId, v.count, AT_EQUIP_TEMPER)
		end
		local props = bean.props
		g_i3k_game_context:SetEquipTemperProps(req.pos, props)
		g_i3k_game_context:ClearTempEquipProps()--清空临时属性
		g_i3k_ui_mgr:RefreshUI(eUIID_EquipTemper)
	else
		g_i3k_ui_mgr:PopupTipMessage("解锁失败")
	end
end

--装备锤炼百炼
function i3k_sbean.equip_smelting(eid, guid, pos, lockProps)
	local bean  = i3k_sbean.equip_smelting_req.new()
	bean.eid = eid
	bean.guid = guid
	bean.pos = pos
	bean.lockProps = lockProps
	i3k_game_send_str_cmd(bean, i3k_sbean.equip_smelting_res.getName())
end

function i3k_sbean.equip_smelting_res.handler(bean, req)
	if bean.props and next(bean.props) then
		local consume = {}
		for i,v in ipairs(i3k_db_equip_temper_base.bailianConsume) do
			table.insert(consume, v)
		end
		if req.lockProps and next(req.lockProps) then
			local lockConsume = i3k_db_equip_temper_base.lockConsume[#req.lockProps]
			table.insert(consume, lockConsume)
		end
		for k, v in pairs(consume) do
			g_i3k_game_context:UseCommonItem(v.itemId, v.count, AT_EQUIP_TEMPER)
		end
		local props = bean.props
		g_i3k_game_context:SetTempEquipBaiLianProps(props)
		g_i3k_game_context:GetUserCfg():SetDefaultBaiLianPartID(req.pos)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTemperWash, "setWashProp", props)--TODO 看是否可以通过重新刷新
	else
		g_i3k_ui_mgr:PopupTipMessage("百炼失败")
	end
end

--装备百炼锤炼保存
function i3k_sbean.equip_smelting_save(eid, guid, pos, isClose)
	local bean = i3k_sbean.equip_smelting_save_req.new()
	bean.eid = eid
	bean.guid = guid
	bean.pos = pos
	bean.isclose = isClose
	i3k_game_send_str_cmd(bean, i3k_sbean.equip_smelting_save_res.getName())
end

function i3k_sbean.equip_smelting_save_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:MoveTempEquipBaiLianPropsToFormal(req.pos)
		g_i3k_game_context:GetUserCfg():SetDefaultBaiLianPartID(0)
		if req.isclose then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTemperWash, "onCloseUI")
		else
			g_i3k_ui_mgr:RefreshUI(eUIID_EquipTemperWash)
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_EquipTemper)
	else
		g_i3k_ui_mgr:PopupTipMessage("百炼保存失败")
	end
end

--装备千锤
function i3k_sbean.equip_hammer(eid, guid, pos)
	local bean = i3k_sbean.equip_hammer_req.new()
	bean.eid = eid
	bean.guid = guid
	bean.pos = pos
	i3k_game_send_str_cmd(bean, i3k_sbean.equip_hammer_res.getName())
end

function i3k_sbean.equip_hammer_res.handler(bean, req)
	if bean.props and next(bean.props) then
		local consume = i3k_db_equip_temper_base.qianchuiConsume
		for k, v in pairs(consume) do
			g_i3k_game_context:UseCommonItem(v.itemId, v.count, AT_EQUIP_TEMPER)
		end
		local props = bean.props
		g_i3k_game_context:SetTempEquipQianChuiProps(props, req.pos)
		g_i3k_ui_mgr:RefreshUI(eUIID_EquipTemper)
	else
		g_i3k_ui_mgr:PopupTipMessage("千锤失败")
	end
end

--装备千锤保存 --最后一个参数是是否是关闭的时候残存的 关闭的时候保存 要清空这个界面
function i3k_sbean.equip_hammer_save(eid, guid, pos, isclose)
	local bean = i3k_sbean.equip_hammer_save_req.new()
	bean.eid = eid
	bean.guid = guid
	bean.pos = pos
	bean.isclose = isclose
	i3k_game_send_str_cmd(bean, i3k_sbean.equip_hammer_save_res.getName())
end


function i3k_sbean.equip_hammer_save_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:MoveTempEquipQianChuiPropsToFormal(req.pos)
		if req.isclose then
			g_i3k_game_context:ClearTempEquipProps()--如果是正常关闭 提示完用户之后清空临时属性
			g_i3k_game_context:ResetDefaultTemperSelectEquip()--重置默认选择的装备位
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTemper,"onCloseUI")
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTemper, "onSaveSuccess")
	else
		g_i3k_ui_mgr:PopupTipMessage("千锤保存失败")
	end
end

--装备锤炼技能解锁
function i3k_sbean.equip_hammer_skill_unlock(eid, guid, pos, skillPos, skillID, lvl)
	local bean = i3k_sbean.equip_hammer_skill_unlock_req.new()
	bean.eid = eid
	bean.guid = guid
	bean.pos = pos
	bean.skillPos= skillPos
	bean.skillID = skillID
	bean.lvl = lvl
	i3k_game_send_str_cmd(bean, i3k_sbean.equip_hammer_skill_unlock_res.getName())
end

function i3k_sbean.equip_hammer_skill_unlock_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetEquipTemperSkill(req.pos, req.skillID, req.lvl)
		local activeConsume = i3k_db_equip_temper_skill[req.skillID][req.lvl].activeConsume
		for k, v in pairs(activeConsume) do
			g_i3k_game_context:UseCommonItem(v.itemId, v.count, AT_EQUIP_TEMPER)
		end
		g_i3k_game_context:UpdateTemperPropAndForce()--刷新战力 解锁的技能可能会提升属性
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTemperSkillActive, "onCloseUI")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTemperSkillUp, "onCloseUI")
		g_i3k_ui_mgr:RefreshUI(eUIID_EquipTemper)
	else
		g_i3k_ui_mgr:PopupTipMessage("技能解锁失败")
	end
end

-- 激活武器祝福回应(role_active_weapon_bless)
function i3k_sbean.weaponbless_state.handler(bean)
	if bean.success == 1 then
		local hero = i3k_game_get_player_hero()
		hero:onWeaponBlessRelease()
	end
end

--同步玩家武器祝福层数
function i3k_sbean.role_sync_weaponbless_curlvl.handler(bean)
	local hero = i3k_game_get_player_hero()
	hero:SyncWeaponBlessState(bean.isactive, bean.curlvl)
end

--周围玩家更新武器祝福状态
function i3k_sbean.nearby_role_update_weaponbless.handler(bean)
	--self.roleID:		int32	
	--self.skillID:		int32	
	--self.isactive:		int32	
	--self.curlvl:		int32	
end
function i3k_sbean.role_weaponbless_state.handler(bean)
	local hero = i3k_game_get_player_hero()
	if hero then
		if bean.state == 1 then
			hero:ShowInfo(hero, eEffectID_Dodge.style, i3k_get_string(17907))
		elseif bean.state == 2 then
			hero:ShowInfo(hero, eEffectID_Dodge.style, i3k_get_string(17908))
		end
	end
end
