------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------
-- 合成神兵
function i3k_sbean.goto_weapon_make(id,showModuleID)
	local data = i3k_sbean.weapon_make_req.new()
	data.weaponId = id
	data.showModuleID = showModuleID
	i3k_game_send_str_cmd(data,"weapon_make_res")
end

function i3k_sbean.weapon_make_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetWeaponMakeData(req.weaponId)
		for i=1,4 do
			g_i3k_game_context:SetShenBingUpSkillData(req.weaponId,i,1)
		end
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetModule",req.showModuleID, 1)--1
		--g_i3k_ui_mgr:RefreshUI(eUIID_ShenBing)
		g_i3k_game_context:SetShenbingState(req.weaponId, g_WEAPON_STATE_UNLOCK)
		g_i3k_game_context:SetShenBingAwakeData(req.weaponId)
		local allShenbing ,useShenbing = g_i3k_game_context:GetShenbingData()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetShenbingData",allShenbing ,useShenbing, true)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateIsUse")
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetShenBingUpSkillData",g_i3k_game_context:GetShenbingData())
		for i=1,#i3k_db_shen_bing_talent[req.weaponId] do
			g_i3k_game_context:SetShenBingTalentData(req.weaponId,i,0)
		end
		g_i3k_game_context:SetShenBingAllTalentPointIfHecheng(req.weaponId)
		g_i3k_game_context:SetShenBingCanUseTalentPoint(req.weaponId,i3k_db_shen_bing_talent_init.init_talentPoint_counts[1])
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "talenRedPointState",req.weaponId)
		g_i3k_game_context:SetShenBingUniqueSkillData(req.weaponId,0,0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateRightRedPoint")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateLeftRedPoint")
		g_i3k_game_context:SetTaskDataByTaskType(req.weaponId, g_TASK_OWN_WEAPON)
		--DCAccount.addTag("神兵合成", tostring(req.weaponId))
		--DCAccount.removeTag("拥有神兵", "")
		--DCAccount.addTag("拥有神兵" , tostring(g_i3k_game_context:GetShenBingCount()))
		DCEvent.onEvent("拥有神兵", {["数量"] = g_i3k_game_context:GetShenBingCount()})

		DCEvent.onEvent("神兵合成", { ["神兵ID"] = tostring(req.weaponId) })
	end
end

-----------------------------------
-- 神兵升级
function i3k_sbean.goto_weapon_levelup(id, temp, up_lvl, final_exp, compare_lvl,item)
	local data = i3k_sbean.weapon_levelup_req.new()
	data.weaponId = id
	data.items = temp
	data.lvl = up_lvl
	data.exp = final_exp
	data.compare_lvl = compare_lvl
	--
	if item then
		data.item = item------
		data.__callback = function()------------
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateShenbingUplvlDataItem", data.weaponId)
		end
	end

	i3k_game_send_str_cmd(data,"weapon_levelup_res")
end

function i3k_sbean.weapon_levelup_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "setCanUse", true)
		g_i3k_game_context:SetWeaponUpLevelData(req.weaponId, req.items, req.lvl, req.exp, req.compare_lvl)
		----[[
		if req.item then
			req.__callback()
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetShenbingUplvlData",req.weaponId)
		end
		--]]
		local allShenbing ,useShenbing = g_i3k_game_context:GetShenbingData()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetShenbingDataInfo", allShenbing ,useShenbing, true)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateIsUse")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateRightRedPoint", req.weaponId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateLeftRedPoint", req.weaponId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateShenBingPower")
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetShenBingUpSkillData",g_i3k_game_context:GetShenbingData())

		DCEvent.onEvent("神兵升级", { ["神兵ID"] = tostring(req.weaponId) } )
	end
end

-- 神兵买等级
function i3k_sbean.goto_weapon_buylevel(id, lvl, showModuleID)
	local data = i3k_sbean.weapon_buylevel_req.new()
	data.weaponId = id
	data.level = lvl
	data.showModuleID = showModuleID
	i3k_game_send_str_cmd(data,"weapon_buylevel_res")
end
function i3k_sbean.weapon_buylevel_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetWeaponBuyLevelData(req.weaponId, req.level)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateIsUse")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateShenBingPower")
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetShenBingUpSkillData",g_i3k_game_context:GetShenbingData())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateRightRedPoint", req.weaponId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateLeftRedPoint", req.weaponId)
	end
end
-----------------------------------
-- 神兵升星
function i3k_sbean.goto_weapon_starup(id, starLvl, itemCount, altCount, showModuleID,useShenbing)
	local data = i3k_sbean.weapon_starup_req.new()
	data.weaponId = id
	data.star = starLvl
	data.itemCount = itemCount
	data.altCount = altCount
	data.showModuleID = showModuleID
	data.useShenbing = useShenbing
	i3k_game_send_str_cmd(data,"weapon_starup_res")
end

function i3k_sbean.weapon_starup_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetWeaponStarLevelData(req.weaponId, req.star, req.itemCount, req.altCount)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetModule",req.showModuleID, 2)
		local allShenbing ,useShenbing = g_i3k_game_context:GetShenbingData()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetShenbingDataInfo", allShenbing ,useShenbing, true)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateIsUse")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "onUpStarBtn")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateShenBingPower")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateRightRedPoint", req.weaponId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateLeftRedPoint", req.weaponId)
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateRightUI",g_i3k_game_context:GetShenbingData(),req.weaponId)
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetShenbingUplvlData",req.weaponId)
		g_i3k_game_context:ShowPowerChange()

	end
end

-----------------------------------
-- 选择使用神兵
function i3k_sbean.goto_weapon_select(id,showModuleID, lastWeaponId)
	local data = i3k_sbean.weapon_select_req.new()
	data.weaponId = id
	data.showModuleID = showModuleID
	data.lastWeaponId = lastWeaponId
	i3k_game_send_str_cmd(data,i3k_sbean.weapon_select_res.getName())
end

function i3k_sbean.weapon_select_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetUpAndStar")
		g_i3k_game_context:SetUseShenbing(req.weaponId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetModule",req.showModuleID, 2)
		g_i3k_ui_mgr:RefreshUI(eUIID_ShenBing)
		if g_i3k_db.i3k_db_is_weapon_unique_skill_has_aitrigger(req.weaponId) then
			g_i3k_game_context:setShenBingUniqueTrigger()
		else
			g_i3k_game_context:releaseShenBingUniqueTrigger()
		end
		if req.weaponId ~= 6 then
			g_i3k_game_context:hideWeaponNPC()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateSoulEnergy", g_i3k_game_context:GetSoulEnergy())
		if req.lastWeaponId then
			g_i3k_ui_mgr:PopupTipMessage("切换神兵成功")

			local world = i3k_game_get_world()
			if world and not world._syncRpc then
				local hero = i3k_game_get_player_hero()
				if hero then
					hero:clearWeaponSp()
				end
			end

			local allShenbing = g_i3k_game_context:GetShenbingData()
			if allShenbing[req.weaponId].slvl >= i3k_db_qiling_cfg.weaponStar then
				local info = g_i3k_game_context:getQilingData()
				local qlId = 0
				local lastQlId = 0
				for k,v in pairs(info) do
					if req.weaponId == v.equipWeaponId then
						qlId = k
					end
					if req.lastWeaponId == v.equipWeaponId then
						lastQlId = k
					end
				end
				if qlId == 0 and lastQlId > 0 then
					i3k_sbean.equipQiling(lastQlId, req.weaponId)
				end
			end
		end
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:UpdateTalentProps(nil, true)
		end
	elseif bean.ok == -7 then
		g_i3k_ui_mgr:PopupTipMessage("追踪期间无法切换神兵")
	else
		g_i3k_ui_mgr:PopupTipMessage("切换失败，请稍后重试")
	end
end
-----------------------------------
--神兵升级协议
function i3k_sbean.shen_bing_upSkill(weaponId,skillIndex,level,skillDescId)
	local data =  i3k_sbean.weapon_skill_level_up_req.new()
	data.weaponId = weaponId
	data.skillIndex = skillIndex
	data.level = level
	data.skillDescId = skillDescId
	i3k_game_send_str_cmd(data,"weapon_skill_level_up_res")
end

function i3k_sbean.weapon_skill_level_up_res.handler(bean,req)
	if bean.ok > 0 then
		local upSkillData = g_i3k_game_context:GetShenBingUpSkillData()
		local skill_lvl_before = upSkillData[req.weaponId][req.skillIndex]
		if req.level == #i3k_db_shen_bing_upskill[req.weaponId][req.skillIndex] then
			for i = skill_lvl_before , #i3k_db_shen_bing_upskill[req.weaponId][req.skillIndex] - 1 do
				local id1 = i3k_db_shen_bing_upskill[req.weaponId][req.skillIndex][i + 1].use_id1
				local count1 = i3k_db_shen_bing_upskill[req.weaponId][req.skillIndex][i + 1].use_count1
				local id2 = i3k_db_shen_bing_upskill[req.weaponId][req.skillIndex][i + 1].use_id2
				local count2 = i3k_db_shen_bing_upskill[req.weaponId][req.skillIndex][i + 1].use_count2
				g_i3k_game_context:UseCommonItem(id1,count1,AT_WEAPON_LEVEL_UP)
				g_i3k_game_context:UseCommonItem(id2,count2,AT_WEAPON_LEVEL_UP)
			end
			g_i3k_game_context:SetShenBingUpSkillData(req.weaponId,req.skillIndex,req.level)
			g_i3k_ui_mgr:CloseUI(eUIID_ShenBing_UpSkill)
			g_i3k_ui_mgr:OpenUI(eUIID_ShenBing_UpSkillMax)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetShenBingUpSkillData",g_i3k_game_context:GetShenbingData())
			g_i3k_ui_mgr:RefreshUI(eUIID_ShenBing_UpSkillMax,req.weaponId,req.skillIndex,req.level,req.skillDescId)
		elseif req.level - skill_lvl_before == 1 then
			g_i3k_game_context:SetShenBingUpSkillData(req.weaponId,req.skillIndex,req.level)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing_UpSkill, "upSkillUseCommonItem", req.weaponId,req.skillIndex,req.lvl)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetShenBingUpSkillData",g_i3k_game_context:GetShenbingData())
			g_i3k_ui_mgr:RefreshUI(eUIID_ShenBing_UpSkill,req.weaponId,req.skillDescId,req.skillIndex)
		else
			for i = skill_lvl_before , req.level - 1 do
				local id1 = i3k_db_shen_bing_upskill[req.weaponId][req.skillIndex][i + 1].use_id1
				local count1 = i3k_db_shen_bing_upskill[req.weaponId][req.skillIndex][i + 1].use_count1
				local id2 = i3k_db_shen_bing_upskill[req.weaponId][req.skillIndex][i + 1].use_id2
				local count2 = i3k_db_shen_bing_upskill[req.weaponId][req.skillIndex][i + 1].use_count2
				g_i3k_game_context:UseCommonItem(id1,count1,AT_WEAPON_LEVEL_UP)
				g_i3k_game_context:UseCommonItem(id2,count2,AT_WEAPON_LEVEL_UP)
			end
			g_i3k_game_context:SetShenBingUpSkillData(req.weaponId,req.skillIndex,req.level)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetShenBingUpSkillData",g_i3k_game_context:GetShenbingData())
			g_i3k_ui_mgr:RefreshUI(eUIID_ShenBing_UpSkill,req.weaponId,req.skillDescId,req.skillIndex)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateRightRedPoint", req.weaponId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateLeftRedPoint", req.weaponId)
	end
end
----------------------
--神兵天赋协议

--神兵天赋升级
function i3k_sbean.shen_bing_upTalent(weaponId,talentIndex)
	local data =  i3k_sbean.weapon_talent_level_up_req.new()
	data.weaponId = weaponId
	data.talentIndex = talentIndex
	i3k_game_send_str_cmd(data,"weapon_talent_level_up_res")
end

function i3k_sbean.weapon_talent_level_up_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_game_context:SetShenBingAllTalentPoint(req.weaponId)
		g_i3k_game_context:SetInputShenBingTalent(req.weaponId,req.talentIndex)
		g_i3k_game_context:SetShenBingCanUseTalentPointIfInput(req.weaponId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "setShenbingTalentData")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing_Talent_Info, "refresh",req.weaponId,req.talentIndex)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateRightRedPoint", req.weaponId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateLeftRedPoint", req.weaponId)
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:UpdateWeaponTalentProps()
		end
	end
end

--神兵天赋点购买
function i3k_sbean.shen_bing_buyTalent(weaponId,id1,count1,id2,count2)
	local data =  i3k_sbean.weapon_talent_point_buy_req.new()
	data.weaponId = weaponId
	data.id1 = id1
	data.count1 = count1
	data.id2 = id2
	data.count2 = count2
	i3k_game_send_str_cmd(data,"weapon_talent_point_buy_res")
end

function i3k_sbean.weapon_talent_point_buy_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_game_context:SetShenBingCanUseTalentPointIfBuy(req.weaponId)
		g_i3k_game_context:SetHaveBuyShenBingTalentPointIfBuy(req.weaponId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "setShenbingTalentData")
		local haveBuyPoint = g_i3k_game_context:GetHaveBuyShenBingTalentPoint(req.weaponId)
		local initPoint = i3k_db_shen_bing_talent_init.init_talentPoint_counts[1]
		g_i3k_game_context:UseCommonItem(req.id1,req.count1,AT_WEAPON_TALENT_POINT_BUY)
		g_i3k_game_context:UseCommonItem(req.id2,req.count2,AT_WEAPON_TALENT_POINT_BUY)
		if haveBuyPoint + initPoint == #i3k_db_shen_bing_talent_buy[req.weaponId] then
			g_i3k_ui_mgr:CloseUI(eUIID_ShenBing_Talent_Buy)
			g_i3k_ui_mgr:PopupTipMessage("恭喜已购买所有天赋点")
		else
			g_i3k_ui_mgr:RefreshUI(eUIID_ShenBing_Talent_Buy,req.weaponId,haveBuyPoint)
		end

	end
end

--神兵天赋点重置请求
function i3k_sbean.shen_bing_resetTalent(weaponId)
	local data =  i3k_sbean.weapon_talent_point_reset_req.new()
	data.weaponId = weaponId
	i3k_game_send_str_cmd(data,"weapon_talent_point_reset_res")
end

function i3k_sbean.weapon_talent_point_reset_res.handler(bean,req)
	if bean.ok > 0 then
		local beforeInPutPoint = g_i3k_game_context:GetShenBingAllTalentPoint(req.weaponId)
		local beforeCanUsePoint = g_i3k_game_context:GetShenBingCanUseTalentPoint(req.weaponId)
		g_i3k_game_context:SetShenBingAllTalentPointIfHecheng(req.weaponId)
		local nowCanUsePoint = beforeInPutPoint + beforeCanUsePoint
		g_i3k_game_context:SetShenBingCanUseTalentPoint(req.weaponId,nowCanUsePoint)

		for i=1,#i3k_db_shen_bing_talent[req.weaponId] do
			g_i3k_game_context:SetShenBingTalentData(req.weaponId,i,0)
		end

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "setShenbingTalentData")
		g_i3k_ui_mgr:CloseUI(eUIID_ShenBing_Talent_Reset)
		g_i3k_ui_mgr:PopupTipMessage("重置成功")

		local itemId = i3k_db_shen_bing_talent_init.reset_talent_useId[1]
		local itemCount = i3k_db_shen_bing_talent_init.reset_talent_useCount[1]
		g_i3k_game_context:UseCommonItem(itemId,itemCount,AT_WEAPON_TALENT_POINT_RESET)
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:UpdateWeaponTalentProps()
		end
	end
end

--神兵同步同步新的字段 神兵的ID  神兵特技是否激活，如果激活 该神兵的能量

--打开神兵同步协议
function i3k_sbean.shen_bing_open_syncUniqueSkillSp()
	local data =  i3k_sbean.weapon_sync_req.new()
	i3k_game_send_str_cmd(data,"weapon_sync_res")
end

function i3k_sbean.weapon_sync_res.handler(bean)
	for k,v in pairs(bean.masters) do
		g_i3k_game_context:SetShenBingUniqueSkillData(k,nil,v)
	end
end

---激活神兵特技
function i3k_sbean.shen_bing_activateUniqueSkill(weaponID)
	local data =  i3k_sbean.weapon_uskill_open_req.new()
	data.weaponID = weaponID
	i3k_game_send_str_cmd(data,"weapon_uskill_open_res")
end

function i3k_sbean.weapon_uskill_open_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_game_context:SetShenBingUniqueSkillData(req.weaponID,1,nil)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing_UniqueSkill, "SetActivateShenBingUniqueSkill",req.weaponID)
		g_i3k_ui_mgr:RefreshUI(eUIID_ShenBing_UniqueSkill,req.weaponID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateLeftRedPoint", req.weaponID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateRightRedPoint", req.weaponID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "SetUniqueSkillBtnImg", req.weaponID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "stopAnimation")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateWeaponNotice")
		g_i3k_game_context:setShenBingUniqueTrigger()
		g_i3k_game_context:UpdateWeaponSikillProp()
		if req.weaponID == 5 or req.weaponID == 9 then --彼岸花开启进阶模型
			i3k_sbean.weapon_setform( req.weaponID , g_WEAPON_FORM_ADVANCED )
		end
	end
end

--激活后  获得道具  获得绝技


--神兵熟练度提示协议
function i3k_sbean.role_weapon_master.handler(bean)
	local allShenbing, useShenbing = g_i3k_game_context:GetShenbingData()
	local cfg = i3k_db_shen_bing[useShenbing]
	local maxMastery = i3k_db_shen_bing[useShenbing].proficinecyMax
	local dataList = {}
	dataList.id = useShenbing
	if bean.master >= maxMastery then
		dataList.isFull = true
		g_i3k_game_context:SetShenBingUniqueSkillData(useShenbing,0,maxMastery)
		g_i3k_ui_mgr:OpenUI(eUIID_BattleEquip)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEquip,"onSuperWeaponUnlock")
	else
		local uniqueSkillData = g_i3k_game_context:getShenBingUniqueSkillMasteryByID(useShenbing)
		dataList.exp = bean.master - uniqueSkillData
		dataList.masterExp = bean.master
		g_i3k_game_context:setShenBingUniqueSkillMastery(useShenbing, bean.master)
	end
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleShowExp, g_BATTLE_SHOW_SUPERWEAPON, dataList)
end

-- 开启洞察请求
function i3k_sbean.try_open_insight()
	local bean = i3k_sbean.try_open_insight_req.new()
	i3k_game_send_str_cmd(bean, "try_open_insight_res")
end


-- 开启洞察请求回应
function i3k_sbean.try_open_insight_res.handler(bean, res)
	if bean.ok > 0 then
		i3k_sbean.try_sync_insight()
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("特技在CD中")
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("没有该项特技")
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("需要在世界地图中")
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("没有洞察到资讯，请稍后再来")
	elseif bean.ok == -5 then
		g_i3k_ui_mgr:PopupTipMessage("技能已结束")
	elseif bean.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage("目标位置目前无法传送")
	else
		g_i3k_ui_mgr:PopupTipMessage("开启失败，稍后重试")
	end
end

-- 开启追仇请求
function i3k_sbean.try_open_revenge()
	local bean = i3k_sbean.try_open_revenge_req.new()
	i3k_game_send_str_cmd(bean, "try_open_revenge_res")
end

-- 开启追仇请求回应
function i3k_sbean.try_open_revenge_res.handler(bean, res)
	if bean.ok > 0 then
		i3k_sbean.try_sync_revenge()
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("特技在CD中")
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("没有该项特技")
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("需要在世界地图中")
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("您没有仇人")
	elseif bean.ok == -5 then
		g_i3k_ui_mgr:PopupTipMessage("技能已结束")
	elseif bean.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage("目标位置目前无法传送")
	else
		g_i3k_ui_mgr:PopupTipMessage("开启失败，稍后重试")
	end
end

-- 同步洞察请求
function i3k_sbean.try_sync_insight()
	local bean = i3k_sbean.try_sync_insight_req.new()
	i3k_game_send_str_cmd(bean, "try_sync_insight_res")
end

-- 同步洞察请求回应
function i3k_sbean.try_sync_insight_res.handler(bean, res)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShenshiTongmin,1,bean,res)
end

-- 同步追仇请求
function i3k_sbean.try_sync_revenge()
	local bean = i3k_sbean.try_sync_revenge_req.new()
	i3k_game_send_str_cmd(bean, "try_sync_revenge_res")
end

-- 同步追仇请求回应
function i3k_sbean.try_sync_revenge_res.handler(bean, res)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShenshiTongmin,2,bean,res)
end

-- 洞察传送请求
function i3k_sbean.try_transform_insight(index)
	local bean = i3k_sbean.try_transform_insight_req.new()
	bean.index = index
	i3k_game_send_str_cmd(bean, "try_transform_insight_res")
end

-- 洞察传送请求回应
function i3k_sbean.try_transform_insight_res.handler(bean, res)
	if bean.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenshiTongmin, "onCloseUI")
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("特技在CD中")
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("没有该项特技")
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("需要在世界地图中")
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("您没有仇人")
	elseif bean.ok == -5 then
		g_i3k_ui_mgr:PopupTipMessage("技能已结束")
	elseif bean.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage("目标位置目前无法传送")
	else
		g_i3k_ui_mgr:PopupTipMessage("传送失败，稍后重试")
	end
end

-- 追仇传送请求
function i3k_sbean.try_transform_revenge(index)
	local bean = i3k_sbean.try_transform_revenge_req.new()
	bean.index = index
	i3k_game_send_str_cmd(bean, "try_transform_revenge_res")
end

-- 追仇传送请求回应
function i3k_sbean.try_transform_revenge_res.handler(bean, res)
	if bean.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenshiTongmin, "onCloseUI")
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("特技在CD中")
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("没有该项特技")
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("需要在世界地图中")
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("您没有仇人")
	elseif bean.ok == -5 then
		g_i3k_ui_mgr:PopupTipMessage("技能已结束")
	elseif bean.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage("目标位置目前无法传送")
	else
		g_i3k_ui_mgr:PopupTipMessage("传送失败，稍后重试")
	end
end

function i3k_sbean.weapon_setform( weaponId , form )
	local bean = i3k_sbean.weapon_setform_req.new()
	bean.weaponID = weaponId
	bean.form = form
	i3k_game_send_str_cmd(bean,"weapon_setform_res")
end
function i3k_sbean.weapon_setform_res.handler( bean , res )
	if bean.ok > 0 then
		g_i3k_game_context:SetShenBingUniqueSkillData(res.weaponID,nil,nil,res.form)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing_UniqueSkill, "updateBianhua",res.form)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, 'onChangeShenBingForm')
		local wCfg = i3k_db_shen_bing[res.weaponID]
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5344, wCfg.name, i3k_get_string(res.form+1666)))
	else
		g_i3k_ui_mgr:PopupTipMessage("切换失败，稍后重试")
	end
end

function i3k_sbean.role_weapon_npc.handler(bean , res  )
	local id = bean.npcID
	g_i3k_game_context:setWeaponShowNpcID(id)
	g_i3k_game_context:showWeaponNPC()
end

function i3k_sbean.weaponmap_start( )
	local bean = i3k_sbean.weaponmap_start_req.new()
	i3k_game_send_str_cmd(bean,"weaponmap_start_res")
end
function i3k_sbean.weaponmap_start_res.handler( bean , res )
	if bean.ok > 0 then

	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
	end
end

function i3k_sbean.weapon_wolf_damage_reduction.handler (bean)
	g_i3k_game_context:setWolfData(bean)
end


------------------神兵-器灵-------------------------
function i3k_sbean.role_weaponspirit.handler(res)
	local info = res.spirits
	g_i3k_game_context:setQilingData(info)
	g_i3k_game_context:UpdateQilingProp()
end

-- 激活器灵
function i3k_sbean.activeQiling(id)
	local data = i3k_sbean.weaponspirit_activite_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "weaponspirit_activite_res")
end

function i3k_sbean.weaponspirit_activite_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_Qiling)
		g_i3k_ui_mgr:RefreshUI(eUIID_Qiling, req.id)
	end
end

-- 激活器灵节点(1成功，2失败，<0 错误)
function i3k_sbean.activeQilingPoint(qilingID, pointID, consumes)
	local data = i3k_sbean.weaponspirit_activite_point_req.new()
	data.spiritId = qilingID
	data.pointId = pointID
	data.consumes = consumes
	i3k_game_send_str_cmd(data, "weaponspirit_activite_point_res")
end
function i3k_sbean.weaponspirit_activite_point_res.handler(res, req)
	-- 成功返回1，失败返回2
	local useItem = function (consumes)
		for k, v in ipairs(consumes) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, AT_ACTIVE_QILING_POINT)
		end
	end

	if res.ok == 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1101))
		useItem(req.consumes)
		g_i3k_game_context:activeQiling(req.spiritId, req.pointId)
		g_i3k_ui_mgr:CloseUI(eUIID_QilingActive)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_QilingProp, "initNodes")
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:UpdateQilingProp()
		g_i3k_game_context:ShowPowerChange()
	elseif res.ok == 2 then
		useItem(req.consumes)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1102))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_QilingActive, "refreshConsume")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_QilingProp, "initNodes")
	else
		g_i3k_ui_mgr:PopupTipMessage("其它错误")
	end
end

-- 装备器灵
function i3k_sbean.equipQiling(qilingID, weaponID)
	local data = i3k_sbean.weaponspirit_equip_req.new()
	data.spiritId = qilingID
	data.weaponId = weaponID
	i3k_game_send_str_cmd(data, "weaponspirit_equip_res")
end
function i3k_sbean.weaponspirit_equip_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:equipQiling(req.spiritId, req.weaponId)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1103))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Qiling, "updateScroll")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "initQiling")
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1104))
	end
end

-- 器灵升阶
function i3k_sbean.upRankQiling(qilingID, rank, consumes)
	local data = i3k_sbean.weaponspirit_uprank_req.new()
	data.spiritId = qilingID
	data.rank = rank
	data.consumes = consumes
	i3k_game_send_str_cmd(data, "weaponspirit_uprank_res")
end
function i3k_sbean.weaponspirit_uprank_res.handler(res, req)
	if res.ok > 0 then
		local useItem = function (consumes)
			for k, v in ipairs(consumes) do
				g_i3k_game_context:UseCommonItem(v.id, v.count, AT_QILING_UP_RANK)
			end
		end
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1105))
		useItem(req.consumes)
		g_i3k_game_context:upRankQiling(req.spiritId, req.rank)
		g_i3k_ui_mgr:CloseUI(eUIID_QilingPromote)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_QilingProp, "initNodes")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_QilingProp, "playPromoteAni")
	end
end

-- 器灵技能升级
function i3k_sbean.qilingSkillLevelUp(qilingID, level)
	local data = i3k_sbean.weaponspirit_skill_level_up_req.new()
	data.spiritId = qilingID
	data.level = level
	i3k_game_send_str_cmd(data, "weaponspirit_skill_level_up_res")
end

function i3k_sbean.weaponspirit_skill_level_up_res.handler(res, req)
	if res.ok > 0 then
		local maxRank = i3k_db_qiling_type[req.spiritId].transUpLevel
		local item = i3k_db_qiling_skill[req.spiritId][req.level].consume
		g_i3k_game_context:updateQilingLevel(req.spiritId, req.level)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_QilingProp, "updateSkillRedPoint")
		for k, v in ipairs(item) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, AT_QILING_SKILL_UP_LEVEL)
		end
		if req.level >= i3k_db_qiling_trans[req.spiritId][maxRank].skillUpLevel then
			g_i3k_ui_mgr:CloseUI(eUIID_QilingSkillUpdate)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_QilingProp, "updateSkillMax")
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_QilingSkillUpdate, "updateSkill")
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("升级失败")
	end
end

--神兵觉醒
function i3k_sbean.weapon_awake(weaponID)
	local bean = i3k_sbean.weapon_awake_req.new()
	bean.weaponID = weaponID
	i3k_game_send_str_cmd(bean, 'weapon_awake_res')
	-- i3k_sbean.weapon_awake_res.handler({ok=1}, bean)
end

--神兵觉醒
function i3k_sbean.weapon_awake_res.handler(res, req)
	if res.ok == 1 then
		local cfg = i3k_db_shen_bing_awake[req.weaponID]
		g_i3k_game_context:UseCommonItem(cfg.needItemID, cfg.needItemCount, AT_WEAPON_AWAKE)
		local skillLvls = {}
		for i, v in ipairs(cfg.showSkills) do
			skillLvls[v] = 1
		end
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetShenBingAwakeState(req.weaponID)
		g_i3k_game_context:SetShenBingBingHunLevels(req.weaponID, skillLvls)
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, 'onShenBingAwakeSuccess', req.weaponID)
		i3k_sbean.weapon_setform( req.weaponID , g_WEAPON_FORM_AWAKE )
	else
		g_i3k_ui_mgr:PopupTipMessage("觉醒失败")
	end
end

--神兵兵魂升级
function i3k_sbean.weapon_skill_level_up(weaponID, skillID)
	local bean = i3k_sbean.weapon_awake_skill_lvlup_req.new()
	bean.weaponID = weaponID
	bean.skillID = skillID
	i3k_game_send_str_cmd(bean, 'weapon_awake_skill_lvlup_res')
	-- i3k_sbean.weapon_awake_skill_lvlup_res.handler({ok=1}, bean)
end

function i3k_sbean.weapon_awake_skill_lvlup_res.handler(res, req)
	if res.ok == 1 then
		local skillLvl = g_i3k_game_context:GetBingHunLevel(req.weaponID, req.skillID)
		local nextCfg = i3k_db_shen_bing_bing_hun_skill[req.weaponID][skillLvl + 1]
		local consume = nextCfg.consume
		for i, v in ipairs(consume) do
			g_i3k_game_context:UseCommonItem(v.itemID, v.count, AT_WEAPON_AWAKE_SKILL_LVLUP)
		end
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:UpBingHunLevel(req.weaponID, req.skillID)
		local hero = i3k_game_get_player_hero()
		hero:UpdateTalentProps(nil, true)
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:RefreshUI(eUIID_ShenBingBingHunShengJi)
		g_i3k_ui_mgr:RefreshUI(eUIID_ShenBingBingHun, req.weaponID, false)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, 'RefreshAwakeUI', req.weaponID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenBing, "updateShenBingPower")
	else
		g_i3k_ui_mgr:PopupTipMessage("升级失败")
	end
end

--神兵兵魂技能经验加成
function i3k_sbean.weapon_awake_exp_sync.handler(bean)
	g_i3k_game_context:AddShenbingBinghunSkillExp(bean.exp)
end
--神兵蚩尤破天斧特技
function i3k_sbean.use_weapon_trigskill()
	local bean = i3k_sbean.weapon_uskill_trigskill.new()
	i3k_game_send_str_cmd(bean)
end
function i3k_sbean.update_motivate_time.handler(bean)
	if bean.reduceTime then
		local hero = i3k_game_get_player_hero()
		if hero and hero._superMode.valid then			
			hero._superMode.ticks = hero._superMode.ticks + bean.reduceTime
		end
	end
end
