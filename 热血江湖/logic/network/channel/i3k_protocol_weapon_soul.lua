------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

--登录时同步武魂信息
function i3k_sbean.role_weaponsoul.handler(bean)
	g_i3k_game_context:SetWeaponSoul(bean.weaponSoul)
end

--武魂方位升级
function i3k_sbean.weaponSoulLvlup(partID, toLvl, consumeItem)
	local data = i3k_sbean.weaponsoul_lvlup_req.new()
	data.partID = partID
	data.toLvl = toLvl
	data.consumeItem = consumeItem
	i3k_game_send_str_cmd(data,"weaponsoul_lvlup_res")
end

function i3k_sbean.weaponsoul_lvlup_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetWeaponSoulUpLvlData(req.partID, req.toLvl, req.consumeItem)
	end
end

--武魂升阶
function i3k_sbean.weaponSoulGradeUp(toGrade, consumeItem)
	local data = i3k_sbean.weaponsoul_gradeup_req.new()
	data.toGrade = toGrade
	data.consumeItem = consumeItem
	i3k_game_send_str_cmd(data,"weaponsoul_gradeup_res")
end

function i3k_sbean.weaponsoul_gradeup_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetWeaponSoulUpGradelData(req.toGrade, req.consumeItem)
	end
end

--隐藏形象
function i3k_sbean.weaponSoulHide(hide)
	local data = i3k_sbean.weaponsoul_hide_req.new()
	data.hide = hide
	i3k_game_send_str_cmd(data,"weaponsoul_hide_res")
end

function i3k_sbean.weaponsoul_hide_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetWeaponSoulCurHide(req.hide);
		g_i3k_game_context:AttachWeaponSoul();
	end
end

--设置升阶自动变更形象
function i3k_sbean.weaponSoulShowAuto(auto)
	local data = i3k_sbean.weaponsoul_showauto_req.new()
	data.auto = auto
	i3k_game_send_str_cmd(data,"weaponsoul_showauto_res")
end

function i3k_sbean.weaponsoul_showauto_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetAutoChangeShow(req.auto)
	end
end

--变更形象
function i3k_sbean.weaponSoulShowSet(showID)
	local data = i3k_sbean.weaponsoul_showset_req.new()
	data.showID = showID
	i3k_game_send_str_cmd(data,"weaponsoul_showset_res")
end

function i3k_sbean.weaponsoul_showset_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:CloseUI(eUIID_MartialSoulSkin)
		g_i3k_game_context:ChangeSoulModel(req.showID)
	end
end

--解锁追加形象
function i3k_sbean.weaponSoulUnlock(soul)
	local data = i3k_sbean.weaponsoul_unlockshow_req.new()
	data.showID = soul.id
	data.consumeItem = soul.data
	i3k_game_send_str_cmd(data,"weaponsoul_unlockshow_res")
end

function i3k_sbean.weaponsoul_unlockshow_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:UseCommonItem(req.consumeItem.needItemID, req.consumeItem.needItemCount, AT_WEAPON_SOUL_UNLOCK_SHOW)
		g_i3k_ui_mgr:CloseUI(eUIID_MartialSoulSkinUnlock)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MartialSoul, "updateAddSkinPoint")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MartialSoulSkin, "loadSkinScroll")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MartialSoulSkin, "updateFuncBtn")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MartialSoulSkin, "updateAddSkinRed")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateMartialSoulRed")
	end
end

--新增武魂形象
function i3k_sbean.weaponsoul_show_add.handler(bean)
	local showID = bean.showID
	if showID then
		local cfg = i3k_db_martial_soul_display[showID]
		if cfg.diaplayType == 1 and g_i3k_game_context:GetWeaponSoulCurShow() == 0 then --初始外显
			g_i3k_game_context:SetWeaponSoulCurShow(showID)
		end
		g_i3k_game_context:AutoChangeModel(showID)
		g_i3k_game_context:AddWeaponSoulShows(showID)
	end
end

------------------------------------星耀--------------------------------------------------
-- 设置当前星耀
function i3k_sbean.SetCurStar(starID)
	local data = i3k_sbean.weaponsoul_curstar_req.new()
	data.starID = starID;
	i3k_game_send_str_cmd(data,"weaponsoul_curstar_res")
end

function i3k_sbean.weaponsoul_curstar_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetCurStar(req.starID)
		g_i3k_game_context:SetCurStarData()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarDish, "changeStar")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarDish, "leftData", req.starID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarFlare, "leftData", req.starID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarDish, "updateCatalog", true)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarDish, "updateMartialSoulRed")
	end
end

--激活星耀
function i3k_sbean.StarActivate(pos)
	local data = i3k_sbean.weaponsoul_staractivate_req.new()
	data.pos = pos
	i3k_game_send_str_cmd(data,"weaponsoul_staractivate_res")
end

function i3k_sbean.weaponsoul_staractivate_res.handler(bean,req)
	if bean.ok == 1 then
		local stars =  g_i3k_game_context:GetCanActivateStar();
		g_i3k_ui_mgr:OpenUI(eUIID_StarActivate)
		g_i3k_ui_mgr:RefreshUI(eUIID_StarActivate, stars)
		g_i3k_game_context:SetActiveStars(stars)
		g_i3k_game_context:SetCurStarData()
		local count = #stars;
		if count and count > 0 then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarDish, "jumpToCatalog", stars[count])
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("当前服务器没有可启动星耀")
	end
end

--快速激活星耀
function i3k_sbean.StarQuickActivate(starID, needItem)
	local data = i3k_sbean.weaponsoul_quickactivate_req.new()
	data.starID = starID
	data.needItem = needItem
	i3k_game_send_str_cmd(data,"weaponsoul_quickactivate_res")
end

function i3k_sbean.weaponsoul_quickactivate_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetActiveStar(req.starID)
		local data = i3k_db_star_soul[req.starID];
		for i, e in ipairs(req.needItem) do
			g_i3k_game_context:UseCommonItem(e.needItemID, e.needItemCount, AT_WEAPON_SOUL_QUICK_ACTIVATE)
		end	
		g_i3k_game_context:SetActiveTimes(data.rank)
		g_i3k_ui_mgr:CloseUI(eUIID_StarLock)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1152))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarFlare, "leftData", req.starID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarDish, "updateCatalog", true)
		g_i3k_game_context:SetCurStarData()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1135))
	end
end

--方位重置
function i3k_sbean.StarPartReset(partID, shapeLock, colorLock, needItem)
	local data = i3k_sbean.weaponsoul_partreset_req.new()
	data.partID = partID;
	data.shapeLock = shapeLock;
	data.colorLock = colorLock;
	data.needItem = needItem;
	i3k_game_send_str_cmd(data,"weaponsoul_partreset_res")
end

function i3k_sbean.weaponsoul_partreset_res.handler(bean,req)
	if bean.balls then
		for i, e in ipairs(req.needItem) do
			g_i3k_game_context:UseCommonItem(e.needItemID, e.needItemCount, AT_WEAPON_SOUL_PART_RESET)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarShape, "updateNeedItem")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarShape, "updatePart", bean.balls)
	end
end

--保存方位重置
function i3k_sbean.StarSaveReset(partID, shape)
	local data = i3k_sbean.weaponsoul_savereset_req.new()
	data.partID = partID 
	data.shape = shape
	i3k_game_send_str_cmd(data,"weaponsoul_savereset_res")
end

function i3k_sbean.weaponsoul_savereset_res.handler(bean,req)
	if bean.ok == 1 then
		local arg = { partID = req.partID, shape = req.shape};
		g_i3k_game_context:SetPartShape(arg)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarShape, "savePart", req.shape)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarDish, "updatePartWidget", arg)
	end
end

--放弃方位重置
function i3k_sbean.StarQuitReset(partID)
	local data = i3k_sbean.weaponsoul_quitreset_req.new()
	data.partID = partID
	i3k_game_send_str_cmd(data,"weaponsoul_quitreset_res")
end

function i3k_sbean.weaponsoul_quitreset_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:ClearPartCahce(req.partID)
	end
end

function i3k_sbean.weaponsoul_mustset(partId, targetId)
	local bean = i3k_sbean.weaponsoul_partmustreset_req.new()
	bean.partID = partId
	bean.target = targetId
	i3k_game_send_str_cmd(bean, "weaponsoul_partmustreset_res")
end

function i3k_sbean.weaponsoul_partmustreset_res.handler(res, req)
	if res.balls then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1739))
		g_i3k_ui_mgr:CloseUI(eUIID_StarShapeConfirm)
		local arg = { partID = req.partID, shape = res.balls};
		g_i3k_game_context:SetPartShape(arg)
		local arg2 = {part = req.partID, startInfo = res.balls}
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarShape, "onMustChangeSucceed", arg2)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_StarDish, "updatePartWidget", arg)
		-- g_i3k_ui_mgr:RefreshUI(eUIID_StarShape, arg2)
	end
end
function i3k_sbean.god_star_levelup(level)
	local bean = i3k_sbean.god_star_levelup_req.new()
	bean.level = level + 1
	i3k_game_send_str_cmd(bean, "god_star_levelup_res")
end
function i3k_sbean.god_star_levelup_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetWeaponSoulGodStarLvl(req.level)
		g_i3k_game_context:SetPrePower()
		local hero = i3k_game_get_player_hero()
		hero:UpdateShenDouProp()
		g_i3k_game_context:ShowPowerChange()
		local cfg = i3k_db_matrail_soul_shen_dou_level[req.level]
		for i, v in ipairs(cfg.consume) do
			g_i3k_game_context:UseCommonItem(v.id, v.count)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ShenDou, "onShenDouLevelUp", req.level - 1)
	end
end
function i3k_sbean.god_star_skill_levelup(skillId, level)
	local bean = i3k_sbean.god_star_skill_levelup_req.new()
	bean.skillId = skillId
	bean.level = level
	i3k_game_send_str_cmd(bean, "god_star_skill_levelup_res")
end
function i3k_sbean.god_star_skill_levelup_res.handler(res, req)
	if res.ok > 0 then
		if req.level == 1 then
			g_i3k_logic:ShowSuccessAnimation("active")
		end
		local cfg = i3k_db_matrail_soul_shen_dou_xing_shu[req.skillId][req.level]
		for i,v in ipairs(cfg.consume) do
			g_i3k_game_context:UseCommonItem(v.id, v.count)
		end
		g_i3k_game_context:SetWeaponSoulGodStarSkillLvl(req.skillId, req.level)
		g_i3k_ui_mgr:CloseUI(eUIID_ShenDouSmallSkillUp)
		g_i3k_ui_mgr:CloseUI(eUIID_ShenDouBigSkillUp)
		g_i3k_ui_mgr:CloseUI(eUIID_ShenDouSmallSkillActive)
		g_i3k_ui_mgr:CloseUI(eUIID_ShenDouBigSkillActive)
		if #i3k_db_matrail_soul_shen_dou_xing_shu[req.skillId] == req.level then
			g_i3k_ui_mgr:OpenUI(eUIID_ShenDouSkillMax)
			g_i3k_ui_mgr:RefreshUI(eUIID_ShenDouSkillMax, req.skillId)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1732))
		else
			if req.level ~= 1 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1731))
				if next(i3k_db_matrail_soul_shen_dou_xing_shu[req.skillId][req.level].needXinShu) then--小星数
					g_i3k_ui_mgr:OpenUI(eUIID_ShenDouSmallSkillUp)
					g_i3k_ui_mgr:RefreshUI(eUIID_ShenDouSmallSkillUp, req.skillId)
				else
					g_i3k_ui_mgr:OpenUI(eUIID_ShenDouBigSkillUp)
					g_i3k_ui_mgr:RefreshUI(eUIID_ShenDouBigSkillUp, req.skillId)
				end
			end
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_ShenDou)
		g_i3k_game_context:SetPrePower()
		local hero = i3k_game_get_player_hero()
		hero:UpdateShenDouProp()
		hero:UpdateStarSoulProp()
		hero:UpdateMartialSoulProp()
		g_i3k_game_context:ShowPowerChange()
	end
end
