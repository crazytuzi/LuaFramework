------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")
--------------------------------------------------------
--[[
i3k_sbean.DBRoleHideWeapon = i3k_class("DBRoleHideWeapon")
function i3k_sbean.DBRoleHideWeapon:ctor()
	--self.curWeapon:		int32
	--self.nextChangeHWeaponTrigTime:		int32
	--self.weapons:		map[int32, DBHideWeapon]
	--self.padding:		int32
end

i3k_sbean.DBHideWeapon = i3k_class("DBHideWeapon")
function i3k_sbean.DBHideWeapon:ctor()
	--self.rankValue:		int32
	--self.level:		int32
	--self.exp:		int32
	--self.aSkillLevel:		int32
	--self.slots:		vector[int32]
	--self.skillLib:		map[int32, int32]
	--self.fightPower:		int32
	--self.skin:		DBHWSkinInfo	
	--self.padding:		int32
end

i3k_sbean.DBHWSkinInfo = i3k_class("DBHWSkinInfo")
function i3k_sbean.DBHWSkinInfo:ctor()
	--self.curSkin:		int32	
	--self.skinLib:		set[int32]	
end
--]]

-- 暗器同步
function i3k_sbean.hideweapon_login_sync.handler(res)
	local info = res.info
	g_i3k_game_context:syncHideWeaponInfo(info)
end

--暗器技能UI表现协议
--<field name="wid" type="int32"/>  暗器ID
--<field name="type" type="int32"/> 类型1攻击者 2是受击者
function i3k_sbean.hideweapon_skill_damage.handler(res)
	if res.wid > 0 then
		local hideWeaponCfg = g_i3k_db.i3k_db_get_one_anqi_skill_base_cfg(res.wid)
		--打开悬浮ui
		g_i3k_ui_mgr:OpenUI(eUIID_HideWeaponBattle)
		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeaponBattle, res.wid, res.type, res.curSkin)
	end
end

-- 暗器激活
function i3k_sbean.hideweapon_make(wid, info)
	local data = i3k_sbean.hideweapon_make_req.new()
	data.wid = wid
	data.info = info
	i3k_game_send_str_cmd(data, "hideweapon_make_res")
end

function i3k_sbean.hideweapon_make_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("启动成功")

		local data = i3k_sbean.DBHideWeapon.new()
		data.rankValue = 0
		data.level = 1
		data.exp = 0
		data.aSkillLevel = 1
		data.slots = {0, 0, 0}
		data.skillLib = g_i3k_db.i3k_db_get_anqi_init_skillLib(req.wid)  -- 被动技能id对应的等级, 改成，初始是个空table，取不到的等级默认为1级
		local skinData = i3k_sbean.DBHWSkinInfo.new()
		skinData.curSkin = 0
		skinData.skinLib = {}
		data.skin = skinData

		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:setHideWeapon(req.wid, data)
		g_i3k_game_context:UseCommonItem(req.info.id, req.info.count, AT_MAKE_HIDEWEAPON)

		g_i3k_game_context:refreshHideWeaponProp()
		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeapon)
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HideWeapon, "setUnlockModule")
	end
end

-- 更换暗器
function i3k_sbean.hideweapon_change(wid)
	local data = i3k_sbean.hideweapon_change_req.new()
	data.wid = wid
	i3k_game_send_str_cmd(data, "hideweapon_change_res")
end

function i3k_sbean.hideweapon_change_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("装备成功")
		g_i3k_game_context:equipHideWeapon(req.wid)
		g_i3k_game_context:refreshHideWeaponProp()
		g_i3k_game_context:refreshAnqiSkillInBattle()
		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeapon)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HideWeapon, "setResponseModule")
	else
		g_i3k_ui_mgr:PopupTipMessage("装备失败")
	end
end

-- 暗器升品
function i3k_sbean.hideweapon_rankup(wid, items)
	local data = i3k_sbean.hideweapon_rankup_req.new()
	data.wid = wid
	data.items = items
	i3k_game_send_str_cmd(data, "hideweapon_rankup_res")
end

function i3k_sbean.hideweapon_rankup_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("升品成功")
		for k, v in pairs(req.items) do
			g_i3k_game_context:UseCommonItem(k, v, AT_HIDEWEAPON_UPRANK)
		end
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:addHideWeaponRankValue(req.wid)
		g_i3k_game_context:refreshHideWeaponProp()
		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeapon)
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HideWeapon, "setResponseModule")
	else
		g_i3k_ui_mgr:PopupTipMessage("升品失败")
	end
end

-- 暗器升级
function i3k_sbean.hideweapon_levelup(wid, items)
	local data = i3k_sbean.hideweapon_levelup_req.new()
	data.wid = wid
	data.items = items
	i3k_game_send_str_cmd(data, "hideweapon_levelup_res")
end

function i3k_sbean.hideweapon_levelup_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("升级成功")
		local total = 0
		for k, v in pairs(req.items) do
			g_i3k_game_context:UseCommonItem(k, v, AT_HIDEWEAPON_LEVEL_UP)
			local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(k)
			local perExp = itemCfg.args1
			total = total + v * perExp
		end
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:addHideWeaponExp(req.wid, total)
		g_i3k_game_context:refreshHideWeaponProp()
		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeapon)
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HideWeapon, "setResponseModule")
	else
		g_i3k_ui_mgr:PopupTipMessage("升级失败")
	end
end

-- 暗器主动技能升级
function i3k_sbean.hideweapon_askill_levelup(wid, cost)
	local data = i3k_sbean.hideweapon_askill_levelup_req.new()
	data.wid = wid
	data.cost = cost
	i3k_game_send_str_cmd(data, "hideweapon_askill_levelup_res")
end

function i3k_sbean.hideweapon_askill_levelup_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("升级成功")
		for _, v in ipairs(req.cost) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, AT_HIDEWEAPON_ASKILL_LEVEL_UP)
		end
		g_i3k_game_context:SetPrePower()

		g_i3k_game_context:SetHideWeaponActiveSkillLvl(req.wid)
		g_i3k_game_context:refreshHideWeaponProp()

		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeapon)

		local maxSkillLevel = #i3k_db_anqi_common.levelLimit
		local skillLvl = g_i3k_game_context:GetHideWeaponActiveSkillLvl(req.wid)
		if skillLvl >= maxSkillLevel then
			g_i3k_ui_mgr:CloseUI(eUIID_HideWeaponActiveSkill)
			g_i3k_ui_mgr:OpenUI(eUIID_HideWeaponActiveSkillLock)
			g_i3k_ui_mgr:RefreshUI(eUIID_HideWeaponActiveSkillLock, req.wid, true)
		else
			g_i3k_ui_mgr:RefreshUI(eUIID_HideWeaponActiveSkill, req.wid)
		end
		
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HideWeapon, "setResponseModule")
	else
		g_i3k_ui_mgr:PopupTipMessage("升级失败")
	end
end

-- 暗器被动技能升级
function i3k_sbean.hideweapon_pskill_levelup(wid, skillID, cost)
	local data = i3k_sbean.hideweapon_pskill_levelup_req.new()
	data.wid = wid
	data.skillID = skillID
	data.cost = cost
	i3k_game_send_str_cmd(data, "hideweapon_pskill_levelup_res")
end

function i3k_sbean.hideweapon_pskill_levelup_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("升级成功")
		for _, v in ipairs(req.cost) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, AT_HIDEWEAPON_PSKILL_LEVEL_UP)
		end
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:UpdatetSkillLib(req.wid, req.skillID)

		g_i3k_game_context:refreshHideWeaponProp()

		local info = {wid = req.wid, skillID = req.skillID}
		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeaponPassiveSkill, info)

		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeapon)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HideWeapon, "setResponseModule")
	else
		g_i3k_ui_mgr:PopupTipMessage("升级失败")
	end
end

-- 暗器更换被动技能
function i3k_sbean.hideweapon_pskill_select(wid, index, skillID)
	local data = i3k_sbean.hideweapon_pskill_select_req.new()
	data.wid = wid
	data.index = index
	data.skillID = skillID
	i3k_game_send_str_cmd(data, "hideweapon_pskill_select_res")
end

function i3k_sbean.hideweapon_pskill_select_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("更换成功")
		local wid = req.wid
		local newIndex = req.index
		local newSkillID = req.skillID

		g_i3k_game_context:SetPrePower()

		local skillSlot = g_i3k_game_context:GetSkillSlot(wid)

		local oldSkillID = skillSlot[newIndex]

		--如果需要替换的技能已经在槽里了，记录槽的位置
		local oldIndex = 0
		for index, skillID in ipairs(skillSlot) do
			if skillID == newSkillID then
				oldIndex = index
				break
			end
		end

		skillSlot[newIndex] = newSkillID
		if oldIndex ~= 0 then
			skillSlot[oldIndex] = oldSkillID
			if oldSkillID == newSkillID then
				skillSlot[oldIndex] = 0
			end
		end

		local nowSkill = g_i3k_db.i3k_db_get_anqi_now_skill(wid)
		local sortSkill = g_i3k_db.i3k_db_sort_anqi_skill(nowSkill)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HideWeaponPassiveSkill, "updateSkillSlot", sortSkill)

		g_i3k_game_context:refreshHideWeaponProp()
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeapon)
	else
		g_i3k_ui_mgr:PopupTipMessage("更换失败")
	end
end

-- 暗器皮肤解锁
function i3k_sbean.hideweapon_skin_unLock(weaponID, skinID, cost)
	local data = i3k_sbean.hideweapon_skin_unLock_req.new()
	data.weaponID = weaponID
	data.skinID = skinID
	data.cost = cost
	i3k_game_send_str_cmd(data, "hideweapon_skin_unLock_res")
end

function i3k_sbean.hideweapon_skin_unLock_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("启动成功")
		for _, v in pairs(req.cost) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, AT_HIDEWEAPON_UNLOCK_SKIN)
		end
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetAnqiCurSkin(req.weaponID, req.skinID)
		g_i3k_game_context:UpdateAnqiSkinLib(req.weaponID, req.skinID)
		g_i3k_game_context:refreshHideWeaponProp()
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeaponHuanhua, req.weaponID)
		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeapon)
		g_i3k_ui_mgr:CloseUI(eUIID_HideWeaponHuanhuaUnlock)
	end
end

-- 暗器更换皮肤
function i3k_sbean.hideweapon_change_skin(weaponID, skinID)
	local data = i3k_sbean.hideweapon_change_skin_req.new()
	data.weaponID = weaponID
	data.skinID = skinID
	i3k_game_send_str_cmd(data, "hideweapon_change_skin_res")
end

function i3k_sbean.hideweapon_change_skin_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetAnqiCurSkin(req.weaponID, req.skinID)
		local skinIDTbl = g_i3k_db.i3k_db_get_anqi_skinID_by_anqiID(req.weaponID)
		local skinID = skinIDTbl[1]
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HideWeaponHuanhua, "setBtnState", req.weaponID, skinID)
		g_i3k_ui_mgr:RefreshUI(eUIID_HideWeapon)
	end
end
