------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------
--选择技能上战
function i3k_sbean.goto_skill_select(slotId, skillId, skillPreFlag)
	local data = i3k_sbean.skill_select_req.new()
	data.slotId = slotId
	data.skillId = skillId
	if skillPreFlag then
		data.skillPreFlag = skillPreFlag
	end
	i3k_game_send_str_cmd(data,"skill_select_res")
end

function i3k_sbean.skill_select_res.handler(bean, req)
	if bean.ok == 1 then
		local allSkill, useSkill = g_i3k_game_context:GetRoleSkills()
		if useSkill[req.slotId] ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(572))
		end

		g_i3k_game_context:SetRoleSelectSkillData(req.slotId, req.skillId)

		if req.skillPreFlag then
			if req.skillPreFlag == g_CHANGE_SKILL_FAST then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_SkillPreset,"selectSkillCB")
			elseif req.skillPreFlag == g_CHANGE_SKILL_PASSIVE then
				local passiveSkill = g_i3k_game_context:GetRolePassiveSkills()
				for i,v in ipairs(useSkill) do
					if passiveSkill[v] then
						g_i3k_game_context:checkSkillPassive()
						return
					end
				end
				g_i3k_game_context:checkSkillPrePassive()
			end
		end
	end
end

--技能升级
function i3k_sbean.goto_skill_levelup(skillId, level, needItem, auto,unique)
	local data = i3k_sbean.skill_levelup_req.new()
	data.skillId = skillId
	data.level = level
	data.needItem = needItem
	data.auto = auto
	data.unique = unique
	i3k_game_send_str_cmd(data,"skill_levelup_res")
end

function i3k_sbean.skill_levelup_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()
		if req.unique then---绝技
			g_i3k_game_context:SetUniqueSkillUpLevelData(req.skillId, req.level, req.needItem, req.auto)
			DCEvent.onEvent("绝技升级", { skillID = tostring(req.skillId)})
		else
			g_i3k_game_context:SetSkillUpLevelData(req.skillId, req.level, req.needItem, req.auto)
			DCEvent.onEvent("武功升级", { skillID = tostring(req.skillId)})
		end

		g_i3k_game_context:ShowPowerChange()
		g_i3k_game_context:LeadCheck()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_UpSkillTips, "palyAct")
	end

end

--技能升界
function i3k_sbean.goto_skill_enhance(skillId, level, needItem,unique)
	local data = i3k_sbean.skill_enhance_req.new()
	data.skillId = skillId
	data.level = level
	data.needItem = needItem
	data.unique = unique
	i3k_game_send_str_cmd(data,"skill_enhance_res")
end

function i3k_sbean.skill_enhance_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()

		if req.unique then---绝技
			g_i3k_game_context:SetUniqueSkillUpStateData(req.skillId, req.level, req.needItem)
		else
			g_i3k_game_context:SetSkillUpStateData(req.skillId, req.level, req.needItem)
		end

		g_i3k_game_context:ShowPowerChange()
	end
end

--技能解锁
function i3k_sbean.goto_skill_unlock(skillId, index)
	local data = i3k_sbean.skill_unlock_req.new()
	data.skillId = skillId
	if index then
		data.index = index
	end
	i3k_game_send_str_cmd(data,"skill_unlock_res")
end

function i3k_sbean.skill_unlock_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()

		if req.index then
			g_i3k_ui_mgr:OpenUI(eUIID_SkillFuncPrompt)---技能解锁提示
			g_i3k_ui_mgr:RefreshUI(eUIID_SkillFuncPrompt,req.skillId)
		end

		local skillID = req.skillId
		local index = req.index
		local allSkill = g_i3k_game_context:GetRoleSkills()
		local lv = 0
		if  allSkill[skillID] then
			lv = allSkill[skillID].lvl
		end
		lv = lv + 1
		if lv ~= 0 then
			if not i3k_db_skill_datas[skillID][lv] then
				return
			end
			local useMoney = i3k_db_skill_datas[skillID][lv].needCoin
			local itemid = i3k_db_skill_datas[skillID][lv].needItemID
			local itemCount = i3k_db_skill_datas[skillID][lv].needItemNum
			g_i3k_game_context:UseCommonItem(1,useMoney)
			g_i3k_game_context:UseCommonItem(itemid,itemCount)
		end

		g_i3k_game_context:SetRoleSkillLevel(skillID,lv)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SkillLy, "onUpdateLayer", skillID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SkillLy, "ChangeSkillClickFuc")

		if lv == g_i3k_game_context:GetLevel() then
			g_i3k_ui_mgr:CloseUI(eUIID_UpSkillTips)
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_UpSkillTips, "onStateTips", skillID)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_UpSkillTips, "onSkillTips", skillID)
		end
		local role_type = g_i3k_game_context:GetRoleType()
		local base_skills = i3k_db_generals[role_type].skills
		local _index  = 0
		for k,v in pairs(base_skills) do
			if v == skillID then
				_index = k
				break
			end
		end
		--发送使用技能的协议
		if _index ~= 0 then
			i3k_sbean.goto_skill_select(_index, skillID)
		end
		if index then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "unlockSuccessed", index, skillID)
		end
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSkillNotice")
	end
end

-------------------------------绝技相关协议----------------------------------
-----装备绝技
function i3k_sbean.goto_uniqueskill_select(skillId, skillPreFlag)
	local data = i3k_sbean.uniqueskill_set_req.new()
	data.skillID = skillId
	if skillPreFlag then
		data.skillPreFlag = skillPreFlag
	end
	i3k_game_send_str_cmd(data,"uniqueskill_set_res")
end

function i3k_sbean.uniqueskill_set_res.handler(bean, req)

	if bean.ok == 1 then
		local role_unique_skill,use_uniqueSkill = g_i3k_game_context:GetRoleUniqueSkills()
		if use_uniqueSkill ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(572))
		end
		g_i3k_game_context:SetRoleSelectUniqueSkillData(req.skillID)
		if req.skillPreFlag then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SkillPreset,"selectSkillCB")
		end
	else---没有此绝技/当前装备的就是此绝技
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(721))
	end
end


--道具技能
function i3k_sbean.bag_useitemskill_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_game_context:UseCommonItem(res.itemId, 1,AT_USE_ITEM_SKILL)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleSkillItem)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"checkShowSkillItem")
	end
end

-- 进地图同步玩家技能CD(key: skillID, value: 剩余多少ms结束)
function i3k_sbean.role_skills_cooldown.handler(bean)
	local hero = i3k_game_get_player_hero()
	for i,v in pairs(bean.cds) do
		if hero then
			hero:SetSkillCoolTick(i, v);
		end
	end
end

-- 同步技能预设请求
function i3k_sbean.role_skill_preset.handler(bean)
	g_i3k_game_context:setSkillPresetData(bean.skillPreset)
	g_i3k_game_context:setSpiritsPresetData(bean.spritsPreset)
end

-- 保存技能预设请求
function i3k_sbean.save_skill_preset_res.handler(bean,req)
	local desc
	if bean.ok > 0 then

		desc = i3k_get_string(724)--"保存技能预设成功"

		local preSkill = i3k_sbean.DBSkillPreset.new()
		preSkill.skillPreset = req.skills
		preSkill.skillPresetName = req.name
		preSkill.diySkill = req.diyskill
		preSkill.uniqueSkill = req.uniqueSkill

		local preData = g_i3k_game_context:getSkillPresetData()
		if preData[req.index] then
			desc = i3k_get_string(725)--"成功替换技能预设"
			preData[req.index] = preSkill
		else
			table.insert(preData, preSkill)
		end

		g_i3k_ui_mgr:CloseUI(eUIID_PreName)
		g_i3k_ui_mgr:RefreshUI(eUIID_SkillSet,req.index)

		if req.diySkillType == g_DIY_TYPE_BORROW then
			local msg = i3k_get_string(726) --"存储已成功,但目前自创武功是借用的,预设中的自创武功位置是为空"
			g_i3k_ui_mgr:ShowMessageBox1(msg, callback)
		end

	elseif bean.ok == -1 then
		desc = i3k_get_string(732) --技能预设已达到上限
	elseif bean.ok == -2 then
		desc = i3k_get_string(733) --未持有当前武功
	elseif bean.ok == -3 then
		desc = i3k_get_string(734) --名称含有敏感字符
	end
	g_i3k_ui_mgr:PopupTipMessage(desc)
end

-- 保存气功预设请求
function i3k_sbean.save_spirits_preset_res.handler(bean,req)
	--self._pname_ = "save_spirits_preset_res"
	--self.ok:		int32
	local desc
	if bean.ok > 0 then
		desc = i3k_get_string(724) --"保存气功预设成功"
		local preSpirits = i3k_sbean.DBSpiritsPreset.new()
		preSpirits.spiritsPreset = req.spirits
		preSpirits.spiritsPresetName = req.name

		local preData = g_i3k_game_context:getSpiritsPresetData()
		if preData[req.index] then
			desc = i3k_get_string(725) --"成功替换气功预设"
			preData[req.index] = preSpirits
		else
			table.insert(preData, preSpirits)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_PreName)
		g_i3k_ui_mgr:RefreshUI(eUIID_SpiritsSet,req.index)
	elseif bean.ok == -1 then
		desc = i3k_get_string(732) --"气功预设已达到上限"
	elseif bean.ok == -2 then
		desc = i3k_get_string(733) --"未持有当前气功"
	elseif bean.ok == -3 then
		desc = i3k_get_string(734) --"名称含有敏感字元"
	end
	g_i3k_ui_mgr:PopupTipMessage(desc)
end

-- 删除技能预设请求
function i3k_sbean.delete_skill_preset_res.handler(bean,req)
	if bean.ok > 0 then
		local preData = g_i3k_game_context:getSkillPresetData()
		table.remove(preData,req.index)
		g_i3k_ui_mgr:RefreshUI(eUIID_SkillSet,1)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(735)) --成功删除技能预设
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(736)) --删除技能预设失败
	end
end

-- 删除气功预设请求
function i3k_sbean.delete_spirits_preset_res.handler(bean,req)
	if bean.ok > 0 then
		local preData = g_i3k_game_context:getSpiritsPresetData()
		table.remove(preData,req.index)
		g_i3k_ui_mgr:RefreshUI(eUIID_SpiritsSet,1)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(735)) --成功删除气功预设
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(736)) --删除气功预设失败
	end
end

function i3k_sbean.change_skill_preset(index,isFast)
	local data = i3k_sbean.change_skill_preset_req.new()
	data.index = index
	data.isFast = isFast
	i3k_game_send_str_cmd(data,i3k_sbean.change_skill_preset_res.getName())
end

-- 使用技能预设请求
function i3k_sbean.change_skill_preset_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(737)) --"成功更换技能预设"
		local preData = i3k_clone(g_i3k_game_context:getSkillPresetData()[req.index])
		if preData then
			if preData.skillPreset and #preData.skillPreset ~= 0 then
				local role_all_skill = g_i3k_game_context:GetRoleSkills()
				g_i3k_game_context:SetRoleSkills(role_all_skill,preData.skillPreset)
				for k,v in pairs(preData.skillPreset) do
					g_i3k_game_context:SetRoleSelectSkillData(k,v)
				end
			end

			if preData.uniqueSkill and preData.uniqueSkill ~= 0 then
				local uniqueSkillsCfg,useUniqueSkillID = g_i3k_game_context:GetRoleUniqueSkills()
				g_i3k_game_context:SetRoleUniqueSkills(uniqueSkillsCfg,preData.uniqueSkill)
				g_i3k_game_context:SetRoleSelectUniqueSkillData(preData.uniqueSkill)
			end

			if preData.diySkill and preData.diySkill ~= 0 then
				local diySkillData,borrowSkillData = i3k_clone(g_i3k_game_context:getDiySkillAndBorrowSkill())
				g_i3k_game_context:setDiySkillAndBorrowSkill(diySkillData,nil)
				local diyCfg = diySkillData[preData.diySkill]
				local id = diyCfg.id
				local t = {}
				t[id] = diyCfg
				g_i3k_game_context:setCreateKungfuSkillIcon(diyCfg.iconId)
				g_i3k_game_context:setCurrentSkillID(id)
				g_i3k_game_context:setCreateKungfuData(t)
				g_i3k_game_context:setCurrentSkillGradeId(diyCfg.diySkillData.gradeId)
				g_i3k_game_context:refreshDiySkillInBattle({skillPos=preData.diySkill})
			end
			if req.isFast then
				g_i3k_game_context:setSkillPresetTime(i3k_game_get_time())
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_SkillPreset,"selectSkillCB")
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"updateAllSkills")
			else
				--g_i3k_ui_mgr:RefreshUI(eUIID_SkillLy)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_SkillLy, "updatePreSkill")
			end
		end

	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(738)) --预设更换失败
	end
end

function i3k_sbean.change_spirits_preset(index,isFast)
	local data = i3k_sbean.change_spirits_preset_req.new()
	data.index = index
	data.isFast = isFast
	i3k_game_send_str_cmd(data,i3k_sbean.change_spirits_preset_res.getName())
end

-- 使用气功预设请求
function i3k_sbean.change_spirits_preset_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(737)) --"成功更换预设"
		local preData = i3k_clone(g_i3k_game_context:getSpiritsPresetData()[req.index])
		if preData then
			if preData.spiritsPreset and #preData.spiritsPreset ~= 0 then
				g_i3k_game_context:CleanUseXinfaData()
				for _,v in ipairs(preData.spiritsPreset) do
					g_i3k_game_context:SetUseXinfa(v)
				end
			end

			if req.isFast then
				g_i3k_game_context:setSpiritsPresetTime(i3k_game_get_time())
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_SkillPreset,"selectSkillCB")
			else
				g_i3k_ui_mgr:RefreshUI(eUIID_XinFa)
			end
			local role_all_skill,role_all_skill_use = g_i3k_game_context:GetRoleSkills()
			local passiveSkill = g_i3k_game_context:GetRolePassiveSkills()
			for i,v in ipairs(role_all_skill_use) do
				if passiveSkill[v] then
					return
				end
			end
			g_i3k_game_context:checkSkillPrePassive()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(738)) --预设更换失败
	end
end

-- 保存技能预设请求
function i3k_sbean.save_all_skill_preset(preData)
	local data =  i3k_sbean.save_all_skill_preset_req.new()
	data.skills = preData
	i3k_game_send_str_cmd(data,i3k_sbean.save_all_skill_preset_res.getName())
end

function i3k_sbean.save_all_skill_preset_res.handler(bean,req)
	if bean.ok > 0 then
		if req.skills then
			g_i3k_game_context:setSkillPresetData(req.skills)
		end
	end
end

----------------------------经脉系统-------------------------------------
--刷新脉象
function i3k_sbean.resetPulse(meridianId, items)
	local data =  i3k_sbean.meridian_refresh_holebuff_req.new()
	data.meridianId = meridianId;
	data.items = items;
	i3k_game_send_str_cmd(data,i3k_sbean.meridian_refresh_holebuff_res.getName())
end

function i3k_sbean.meridian_refresh_holebuff_res.handler(bean,req)
	if bean.ok > 0 then
		for i,e in ipairs(req.items) do
			g_i3k_game_context:UseCommonItem(e.id, e.count, AT_REFRESH_HOLE_BUFF)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_MeridianResetPulse)
		g_i3k_game_context:resetMeridianPulse(req.meridianId, bean.holes)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Meridian,"resetPulse", bean.holes)
	end
end

--冲穴
function i3k_sbean.dashHole(meridianId, items, isMuti)
	local data =  i3k_sbean.meridian_break_hole_req.new()
	data.meridianId = meridianId;
	data.items = items;
	data.isMuti = isMuti;
	i3k_game_send_str_cmd(data,i3k_sbean.meridian_break_hole_res.getName())
end

function i3k_sbean.meridian_break_hole_res.handler(bean,req)
	if bean.ok > 0 then
		for i,e in ipairs(req.items) do
			g_i3k_game_context:UseCommonItem(e.id, e.count, AT_BREAK_HOLE)
		end
		g_i3k_game_context:addMeridianEnergy(req.meridianId, bean.addEnergy)
		if req.isMuti == 1 then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Meridian,"updatePoint", bean.addEnergy, true)
		else
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Meridian,"updatePoint", bean.addEnergy, false)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Meridian, "updateMeridianScroll")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Meridian,"updateItemScroll")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Meridian,"PotentiaRed")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Meridian,"setMeridianPotentialScroll")
	end
end

--潜能升级
function i3k_sbean.meridianPotentialUp(meridianId, potentialId, level)
	local data =  i3k_sbean.meridian_potential_uplevel_req.new()
	data.meridianId = meridianId
	data.potentialId = potentialId
	data.level = level
	i3k_game_send_str_cmd(data,i3k_sbean.meridian_potential_uplevel_res.getName())
end

function i3k_sbean.meridian_potential_uplevel_res.handler(res,req)
	if res.ok > 0 then
		local cfg = i3k_db_meridians.potentia[req.potentialId][req.level]
		for i,v in ipairs(cfg.needItem) do
			if v.id > 0 then
				g_i3k_game_context:UseCommonItem(v.id,v.count,AT_POTENIAL_UPLEVEL)
			end
		end
		g_i3k_game_context:changPotentialValue(req.potentialId)
		if req.level == 1 then
			g_i3k_ui_mgr:PopupTipMessage(string.format("恭喜您%s潜能启动", cfg.name))
		else
			g_i3k_ui_mgr:PopupTipMessage(string.format("恭喜您%s潜能升级", cfg.name))
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MeridianPotentialUp, "updateUI")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MeridianPotential, "updateScrollItem")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Meridian, "updatePotentialScroll")
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:UpdateMeridianProp()
			local lastCfg = i3k_db_meridians.potentia[req.potentialId][req.level-1]
			if cfg.combatValue > lastCfg.combatValue then
				local nowpower = math.modf(hero:Appraise())
				g_i3k_ui_mgr:PopupPowerChange(nowpower,cfg.combatValue - lastCfg.combatValue)
			end
		end
	end
end

-- 登陆同步经脉，潜能


function i3k_sbean.role_potentials.handler(bean)
	g_i3k_game_context:setMeridians(bean.meridians)
	g_i3k_game_context:setMeridianPotential(bean.potential or {})
end


-- -----------五转之路-------------
-- 登陆同步
function i3k_sbean.role_transform_road.handler(res)
	g_i3k_game_context:setFiveTrans(res.transformRoad)
end

-- 升级五转之路 level 是下一个等级，初始为0
function i3k_sbean.fiveTransUpLevel(level)
	local data =  i3k_sbean.transform_road_uplevel_req.new()
	data.level = level
	i3k_game_send_str_cmd(data, "transform_road_uplevel_res")
end
function i3k_sbean.transform_road_uplevel_res.handler(res, req)
	if res.ok > 0 then
		local cfg = i3k_db_five_trans[req.level]
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1376, cfg.name))
		g_i3k_game_context:setFiveTransLevel(req.level)
		local index = req.level
		local iconID = g_i3k_db.i3k_db_get_five_trans_headicon(index)
		local count = i3k_db_five_trans[index].rewardCount
		if iconID then
			local gifts = {[1] = {id = iconID, count = count}}
			g_i3k_ui_mgr:ShowGainItemInfo(gifts)
		end

		-- 消耗道具
		for k, v in ipairs(cfg.commitItems) do
			g_i3k_game_context:UseCommonItem(v.id, v.count)
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_fiveTrans)
	else
		g_i3k_ui_mgr:PopupTipMessage("失败 req.level ="..req.level)
	end
end

-- 选择天命轮
function i3k_sbean.selectDestinyRoll(id)
	local data =  i3k_sbean.transform_road_use_lifewheel_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "transform_road_use_lifewheel_res")
end
function i3k_sbean.transform_road_use_lifewheel_res.handler(res, req)
	if res.ok > 0 then

	else
		g_i3k_ui_mgr:PopupTipMessage("失败")
	end
end

-- 重置天命轮
function i3k_sbean.resetDestinyRoll()
	local data =  i3k_sbean.transform_road_reset_lifewheel_req.new()
	i3k_game_send_str_cmd(data, "transform_road_reset_lifewheel_res")
end
function i3k_sbean.transform_road_reset_lifewheel_res.handler(res, req)
	if res.ok > 0 then

	else
		g_i3k_ui_mgr:PopupTipMessage("失败")
	end
end

-- DBSkillFormula
--     ├──dayExp (int32)
--     ├──exp (int32)
--     ├──level (int32)
--     ├──rank (int32)
--     └──skills (map[int32,int32])
-- 武诀   登陆同步
function i3k_sbean.login_sync_skill_formula.handler(res, req)
	local data = res.data
	g_i3k_game_context:setWujueData(data)
end

function i3k_sbean.useWujueExpItems(items)
	local data = i3k_sbean.use_skill_formula_exp_item_req.new()
	data.items = items
	i3k_game_send_str_cmd(data, "use_skill_formula_exp_item_res")
end

function i3k_sbean.use_skill_formula_exp_item_res.handler(res, req)
	if res.ok > 0 then
		local exp = 0
		for k, v in pairs(req.items) do
			g_i3k_game_context:UseCommonItem(k, v, AT_USE_SKILL_FORMULA_EXP_ITEM)
			exp = exp + i3k_db_new_item[k].args1 * v
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WujueUseItems, "RefreshLeftCounts")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WujueUseItems, "setIsWaitingProtocol", false)
		g_i3k_game_context:addWujueExp(exp, false)
	else
		g_i3k_ui_mgr:PopupTipMessage("使用失败")
	end
end

function i3k_sbean.wujueUpRank(rank)
	local data = i3k_sbean.skill_formula_up_rank_req.new()
	data.rank = rank
	i3k_game_send_str_cmd(data, "skill_formula_up_rank_res")
end

function i3k_sbean.skill_formula_up_rank_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_db.i3k_db_wujue_consume_items(i3k_db_wujue_break[req.rank].consumes, AT_SKILL_FORMULA_UP_RANK)
		g_i3k_game_context:setWujueRank(req.rank)
		if req.rank == #i3k_db_wujue_break then
			g_i3k_ui_mgr:OpenUI(eUIID_WujueBreakFull)
			g_i3k_ui_mgr:RefreshUI(eUIID_WujueBreakFull)
			g_i3k_ui_mgr:CloseUI(eUIID_WujueBreak)
		else
			g_i3k_ui_mgr:RefreshUI(eUIID_WujueBreak)
		end
		local data = g_i3k_game_context:getWujueData()
		local preLevel = data.level
		data.level,data.exp = g_i3k_db.i3k_db_get_wujue_level_exp(data.level, data.exp)
		if data.level > preLevel then
			g_i3k_game_context:SetPrePower()
			local hero = i3k_game_get_player_hero()
			hero:UpdateWuJueProp()
			g_i3k_game_context:ShowPowerChange()
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_Wujue)
		g_i3k_logic:ShowSuccessAnimation(g_BREAK_SUCCESS_ANIMATION)
	else
		g_i3k_ui_mgr:PopupTipMessage("突破失败"..res.ok)
	end
end

function i3k_sbean.wujueUpSkill(skillId, level)
	local data = i3k_sbean.skill_formula_skill_level_up_req.new()
	data.skillId = skillId
	data.level = level
	i3k_game_send_str_cmd(data, "skill_formula_skill_level_up_res")
end

function i3k_sbean.skill_formula_skill_level_up_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_db.i3k_db_wujue_consume_items(i3k_db_wujue_skill[req.skillId][req.level].needItems, AT_SKILL_FORMULA_SKILL_LEVEL_UP)
		g_i3k_game_context:setWujueSkillLevel(req.skillId, req.level)
		if req.level == 1 then
			g_i3k_ui_mgr:CloseUI(eUIID_WujueSkillActive)
			g_i3k_ui_mgr:OpenUI(eUIID_WujueSkillUpLevel)
			g_i3k_ui_mgr:RefreshUI(eUIID_WujueSkillUpLevel, req.skillId)
			g_i3k_logic:ShowSuccessAnimation(g_ACTIVE_SUCCESS_ANIMATION)
		elseif req.level == #i3k_db_wujue_skill[req.skillId] then
			g_i3k_ui_mgr:CloseUI(eUIID_WujueSkillUpLevel)
			g_i3k_ui_mgr:OpenUI(eUIID_WujueSkillFull)
			g_i3k_ui_mgr:RefreshUI(eUIID_WujueSkillFull, req.skillId)
			g_i3k_logic:ShowSuccessAnimation(g_UPLEVEL_SUCCESS_ANIMATION)
		else
			g_i3k_ui_mgr:RefreshUI(eUIID_WujueSkillUpLevel, req.skillId)
			g_i3k_logic:ShowSuccessAnimation(g_UPLEVEL_SUCCESS_ANIMATION)
		end
		g_i3k_game_context:SetPrePower()
		local hero = i3k_game_get_player_hero()
		hero:UpdateWuJueProp()
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:RefreshUI(eUIID_Wujue)
	else
		g_i3k_ui_mgr:PopupTipMessage("技能升级失败")
	end
end

function i3k_sbean.unlock_wujue()
	local bean = i3k_sbean.skill_formula_open_req.new()
	i3k_game_send_str_cmd(bean, "skill_formula_open_res")
end

function i3k_sbean.skill_formula_open_res.handler(bean)
	if bean.ok > 0 then
		g_i3k_game_context:SetPrePower()
		g_i3k_ui_mgr:CloseUI(eUIID_WuJueKQ)
		g_i3k_game_context:initWujueData()
		g_i3k_logic:OpenWujueUI()
		local hero = i3k_game_get_player_hero()
		hero:UpdateWuJueProp()
		g_i3k_game_context:ShowPowerChange()
	else
		g_i3k_ui_mgr:PopupTipMessage("开启失败")
	end
end
--武决潜魂升级
function i3k_sbean.wujue_soul_up_lvl(soulId)
	local bean = i3k_sbean.skill_formula_hidden_soul_uplvl_req.new()
	bean.type = soulId
	i3k_game_send_str_cmd(bean, "skill_formula_hidden_soul_uplvl_res")
end
function i3k_sbean.skill_formula_hidden_soul_uplvl_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetPrePower()
		local soulId = req.type
		local curLvl = g_i3k_game_context:getWujueSoulLvl(soulId)
		g_i3k_game_context:setWujueSoulLvl(soulId, curLvl + 1)
		local hero = i3k_game_get_player_hero()
		hero:UpdateWuJueProp()
		g_i3k_game_context:ShowPowerChange()
		local consumes = i3k_db_wujue_soul[soulId][curLvl + 1].needItems
		g_i3k_db.i3k_db_wujue_consume_items(consumes)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Wujue, "updateSkills")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Wujue, "setRedPoint")
		g_i3k_ui_mgr:RefreshUI(eUIID_WujueSoulSkill, soulId)
		local state = g_i3k_db.i3k_db_get_wujue_soul_state(soulId, curLvl)
		if state == g_WUJUE_SOUL_STATE_UNLOCK then
			g_i3k_logic:ShowSuccessAnimation(g_ACTIVE_SUCCESS_ANIMATION)
		elseif state == g_WUJUE_SOUL_STATE_UP_RANK then
			g_i3k_logic:ShowSuccessAnimation(g_UPLEVEL_SUCCESS_ANIMATION)
		end
	end
end
--技能全部升级
function i3k_sbean.goto_all_skill_levelup(skills,needItem,uniqueSkill)
	local data = i3k_sbean.skill_multi_levelup_req.new()
	data.skills = skills
	data.needItem = needItem
	data.uniqueSkill = uniqueSkill
	i3k_game_send_str_cmd(data,"skill_multi_levelup_res")
end
function i3k_sbean.skill_multi_levelup_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_game_context:SetPrePower()
		for k,v in pairs(req.skills) do
			if req.uniqueSkill[k] then---绝技
				g_i3k_game_context:SetRoleUniqueSkillLevel(k, v)
			else
				g_i3k_game_context:SetRoleSkillLevel(k, v)
			end
		end
		for k,v in pairs(req.needItem) do
			g_i3k_game_context:UseCommonItem(k, v,AT_SKILL_LEVEL_UP)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SkillLy, "onUpdateLayer")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSkillNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updatePetNotice")
		g_i3k_game_context:ShowPowerChange()
		g_i3k_game_context:LeadCheck()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_UpSkillTips, "palyAct")
	else
		g_i3k_ui_mgr:PopupTipMessage("升级失败")
	end
end
