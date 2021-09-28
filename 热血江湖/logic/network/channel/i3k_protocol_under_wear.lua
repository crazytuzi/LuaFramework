------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

---------------------------------内甲系统----------------------------------------------

-----同步内甲信息--(返回内甲不同状态及信息)
function i3k_sbean.role_armor_info.handler(bean)
	if g_i3k_game_context then
		g_i3k_game_context:setUnderWearData(bean.armor.curArmor,bean.armor.allArmors , bean.armor.runeBag,bean.armor.curResetTalentTimes, bean.runeLangLvls,bean.armor.hideEffect,bean.armor.castIngots)
	end
	return true;
end

--屏蔽自己内甲特效
function i3k_sbean.hide_self_armor_effect(isHide)
	local bean = i3k_sbean.armor_effecthide_req.new()
	bean.hide = isHide and 1 or 0
	i3k_game_send_str_cmd(bean,i3k_sbean.armor_effecthide_res.getName())	
end
function i3k_sbean.armor_effecthide_res.handler( bean )
	if bean.ok == 1 then
		g_i3k_game_context:setArmorHideEffect(not g_i3k_game_context:getArmorHideEffect())
		local hero = i3k_game_get_player_hero()
		hero:SetArmorEffectHide(g_i3k_game_context:getArmorHideEffect())
		hero:ChangeArmorEffect()
	end
end

--内甲解锁
function i3k_sbean.undweWear_unlock(id,item)
	local bean = i3k_sbean.unlock_armor_type_req.new()
	bean.type = id
	bean.item = item
	i3k_game_send_str_cmd(bean, i3k_sbean.unlock_armor_type_res.getName())
end

function i3k_sbean.unlock_armor_type_res.handler(res, req)
	if res.ok >0 then
		for i,v in ipairs(req.item) do
			g_i3k_game_context:UseCommonItem(v.itemid, v.itemCount,AT_UNLOCK_ARMOR_TYPE)--回调成功后消耗道具
		end
		g_i3k_game_context:setAnyUnderWearAnyData(req.type,"unlocked",1)--设置对应id内甲解锁字段为true
		g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear)
		--解锁后播放动作
		g_i3k_ui_mgr:PopupTipMessage("锻造成功")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear, "updateModulePlay",req.type)
	else
		g_i3k_ui_mgr:PopupTipMessage("锻造请求，返回失败"..res.ok)
	end
end

--内甲升级
function i3k_sbean.goto_underWear_levelup(wearTag, temp, level, exp, compare_lvl, layer)
	local data = i3k_sbean.armor_up_level_req.new()
	data.type = wearTag
	data.items = temp
	data.level = level
	data.exp = exp
	data.compare_lvl = compare_lvl
	data.layer = layer
	i3k_game_send_str_cmd(data, i3k_sbean.armor_up_level_res.getName())
end


function i3k_sbean.armor_up_level_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_update, "setCanUse", true)
		for k,v in pairs(req.items) do
			g_i3k_game_context:UseCommonItem(k, v,AT_ARMOR_LEVEL_UP)--回调成功后消耗道具
		end
		local nameStr
		local levelStr
		local stageStr
		if i3k_db_under_wear_update[req.type][req.level] then
			g_i3k_game_context:setAnyUnderWearAnyData(req.type,"level",req.level)
			g_i3k_game_context:setAnyUnderWearAnyData(req.type,"exp",req.exp)
		else
			g_i3k_game_context:setAnyUnderWearAnyData(req.type,"level",req.level-1)
			g_i3k_game_context:setAnyUnderWearAnyData(req.type,"exp",req.exp)
		end
		levelStr = g_i3k_game_context:getAnyUnderWearAnyData(req.type,"level")
		stageStr = g_i3k_game_context:getAnyUnderWearAnyData(req.type,"rank")
		if stageStr ==0 then
			stageStr =1
		end
		nameStr = i3k_db_under_wear_upStage[req.type][stageStr].stageName
		local tab = {underwear_name = nameStr ,underwear_level =levelStr ,underwear_stage = stageStr }

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_update, "setData" ,req.type, tab)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_update, "setTrrData" ,req.type, tab)
		g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear)
		if req.compare_lvl.isUpLvl then
			g_i3k_game_context:setArmorUpLevel(req.type,req.level)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("升级请求，返回失败"..bean.ok)
	end
end

--内甲装备
function i3k_sbean.equipArmor(wearTag,tab)
	local data = i3k_sbean.armor_change_req.new()
	data.type = wearTag
	data.tab = tab
	i3k_game_send_str_cmd(data, i3k_sbean.armor_change_res.getName())
end

function i3k_sbean.armor_change_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:setNowUnderWeariD(req.type,req.tab)
		--装备后播放动作
		g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear, "updateModulePlay",req.type)
	else
		g_i3k_ui_mgr:PopupTipMessage("装备请求，返回失败"..bean.ok)
	end
end

--内甲升阶
function i3k_sbean.upStageArmor(wearTag,nextRank,items,auto)
	local data = i3k_sbean.armor_uprank_req.new()
	data.type = wearTag
	data.nextRank = nextRank
	data.items = items
	data.auto = auto
	i3k_game_send_str_cmd(data, i3k_sbean.armor_uprank_res.getName())
end

function i3k_sbean.armor_uprank_res.handler(bean, req)
	--1,成功 2，失败
	if bean.ok ==1 then
		--需要知道当前品阶 把增加值 记录上
		g_i3k_game_context:setArmorWishPoint(req.type,req.nextRank -1,bean.ok)
		if req.auto then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_upStage, "onStopUpStage")
		end
		for i,v in ipairs(req.items) do
			g_i3k_game_context:UseCommonItem(v.itemid, v.itemcount,AT_ARMOR_UPRANK)--回调成功后消耗道具
		end
		g_i3k_game_context:setAnyUnderWearAnyData(req.type,"rank",req.nextRank)
		local levelStr = g_i3k_game_context:getAnyUnderWearAnyData(req.type,"level")
		local nameStr = i3k_db_under_wear_upStage[req.type][req.nextRank].stageName
		local tab = {underwear_name = nameStr ,underwear_level =levelStr ,underwear_stage = req.nextRank }
		g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear)
		g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_upStage ,req.type ,tab)

		--战力修改
		local hero = i3k_game_get_player_hero()
		hero:ArmorStageUp(req.type,req.nextRank)
		hero:OnPowerChangeByArmor()

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear, "updateModule", req.type, req.nextRank)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_upStage, "updateModule", req.type, req.nextRank)
		g_i3k_ui_mgr:PopupTipMessage("升阶成功")
	elseif bean.ok == 2 then
		for i,v in ipairs(req.items) do
			g_i3k_game_context:UseCommonItem(v.itemid, v.itemcount,AT_ARMOR_UPRANK)--回调成功后消耗道具
		end
		--需要知道当前品阶 把增加值 记录上
		g_i3k_game_context:setArmorWishPoint(req.type,req.nextRank -1,bean.ok)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_upStage, "updateWishData")
		if req.auto then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_upStage, "onUpStage")
		end
		g_i3k_ui_mgr:PopupTipMessage("升阶失败，祝福值增加")
	else
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_upStage, "canStopUpStage")--判断是否为自动 并将按钮状态置回
		g_i3k_ui_mgr:PopupTipMessage("升阶请求，返回失败"..bean.ok)
		if req and  req.type and req.nextRank then
			local levelStr = g_i3k_game_context:getAnyUnderWearAnyData(req.type,"level")
			local nameStr = i3k_db_under_wear_upStage[req.type][req.nextRank].stageName
			local tab = {underwear_name = nameStr ,underwear_level =levelStr ,underwear_stage = req.nextRank-1 }
			g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_upStage ,req.type ,tab)
		end
	end
end

--内甲天赋
function i3k_sbean.upTalent(wearTag,tab,talentId)
	local data = i3k_sbean.armor_add_talent_req.new()
	data.type = wearTag
	data.talentId = talentId
	data.tab = tab
	i3k_game_send_str_cmd(data, i3k_sbean.armor_add_talent_res.getName())
end

function i3k_sbean.armor_add_talent_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:setArmorUseTalentPoint(req.type , req.talentId , 1)
		g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_Talent ,req.type,req.tab )
		g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_Talent_Point,req.type,req.tab ,req.talentId)
		--todo
		local hero = i3k_game_get_player_hero()
		g_i3k_game_context:SetPrePower()
		local talentPoint = g_i3k_game_context:getAnyUnderWearAnyData(req.type,"talentPoint")
		local talentPointData = {}
		for i,v in pairs(talentPoint) do
			table.insert(talentPointData,i,v)
		end

		hero:ArmorPutTalent(req.type, req.talentId, talentPointData[req.talentId])
		g_i3k_game_context:ShowPowerChange()
		hero:UpdateArmorProps()
	else
		g_i3k_ui_mgr:PopupTipMessage("升天赋请求，返回失败"..bean.ok)
	end
end

--内甲天赋重置
function i3k_sbean.upResetTalent(wearTag,tab,prop)
	local data = i3k_sbean.reset_talent_point_req.new()
	data.type = wearTag
	data.tab = tab
	data.prop = prop
	i3k_game_send_str_cmd(data, i3k_sbean.reset_talent_point_res.getName())
end

function i3k_sbean.reset_talent_point_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:UseCommonItem(req.prop.itemid, req.prop.itemcount,AT_ARMOR_RESET_TALENT)--回调成功后消耗道具
		g_i3k_game_context:setResetTalentPoint(req.type)
		g_i3k_ui_mgr:RefreshUI(eUIID_Under_Wear_Talent ,req.type,req.tab )
		g_i3k_ui_mgr:PopupTipMessage("成功重置所有天赋")
		local curArmor = g_i3k_game_context:getUnderWearData()
		if curArmor == req.type then
			g_i3k_game_context:SetPrePower()
			local hero = i3k_game_get_player_hero()
			hero:ResetArmorTalent()
			g_i3k_game_context:ShowPowerChange()
			hero:UpdateArmorProps()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("重置天赋请求，返回失败"..bean.ok)
	end
end

--符文存入（背包到符文背包）
function i3k_sbean.pushRune(itemTab)
	local data = i3k_sbean.rune_push_req.new()
	if itemTab then
		data.runes = itemTab
	end
	i3k_game_send_str_cmd(data, i3k_sbean.rune_push_res.getName())
end

function i3k_sbean.rune_push_res.handler(bean, req)
	if bean.ok == 1 then
		for k,v in pairs(req.runes) do  --k id  v count
			g_i3k_game_context:setRuneBagAddData(k ,v,true)
			--g_i3k_game_context:UseCommonItem(k, v)
			g_i3k_game_context:UseBagMiscellaneous(k,v)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "changeRedPoint")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "upgradeLangRed")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "setData")
	else
		g_i3k_ui_mgr:PopupTipMessage("符文存入请求，返回失败"..bean.ok)
	end
end

--符文提取（符文背包到背包）
function i3k_sbean.popRune(itemTab)
	local data = i3k_sbean.rune_pop_req.new()
	if itemTab then
		data.runes = itemTab
	end
	i3k_game_send_str_cmd(data, i3k_sbean.rune_pop_res.getName())
end

function i3k_sbean.rune_pop_res.handler(bean, req)
	if bean.ok == 1 then
		for k,v in pairs(req.runes) do  --k id  v count
			g_i3k_game_context:setRuneBagSubData(k ,v,true)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "upgradeLangRed")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "setData") --右侧界面刷新
	else
		g_i3k_ui_mgr:PopupTipMessage("符文提取请求，返回失败"..bean.ok)
	end
end

--符文插槽解锁
function i3k_sbean.runeSoltUnlock(wearTag ,slotTag ,item)
	local data = i3k_sbean.solt_group_unlock_req.new()
	data.type = wearTag
	data.soltGroupIndex = slotTag
	data.item = item
	i3k_game_send_str_cmd(data, i3k_sbean.solt_group_unlock_res.getName())
end

function i3k_sbean.solt_group_unlock_res.handler(bean, req)
	if bean.ok == 1 then
		for i,v in ipairs(req.item) do
			g_i3k_game_context:UseCommonItem(v.itemid, v.itemCount,AT_SOLT_GROUP_UNLOCK)--回调成功后消耗道具
		end
		g_i3k_game_context:setSoltGroupData(req.type,req.soltGroupIndex) --设置插槽解锁数据

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "setSlotData",req.soltGroupIndex)
		g_i3k_ui_mgr:PopupTipMessage("解锁成功")

	else
		g_i3k_ui_mgr:PopupTipMessage("符文插槽解锁请求，返回失败"..bean.ok)
	end
end

--符文镶嵌/卸载 ->runeId ==0 --前四个位需要参数，第五位为是卸载标记 后两个标记 是否为替换镶嵌
function i3k_sbean.runeToSoltEquip(wearTag ,soltGroupIndex ,soltIndex ,runeId ,runeEquipId ,bool ,id)
	local data = i3k_sbean.solt_push_rune_req.new()
	data.type = wearTag
	data.soltGroupIndex = soltGroupIndex
	data.soltIndex = soltIndex
	data.runeId = runeId
	data.runeEquipId = runeEquipId
	data.bool = bool
	data.id = id
	i3k_game_send_str_cmd(data, i3k_sbean.solt_push_rune_res.getName())
end

function i3k_sbean.solt_push_rune_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:setRuneSoltData(req.type,req.soltGroupIndex,req.soltIndex,req.runeId,req.runeEquipId ,req.bool,req.id ,true) --设置装备数据
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "updateWearRunesData",req.soltGroupIndex) --左侧界面刷新
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "setData") --右侧界面刷新
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "upgradeLangRed")
		
		local hero = i3k_game_get_player_hero()
		g_i3k_game_context:SetPrePower()
		local runeTab = g_i3k_game_context:getAnyUnderWearAnyData(req.type,"soltGroupData")
		hero:ArmorRune(req.type, i3k_clone(runeTab))--第二个参数是全部的符文table
		hero:UpdateArmorProps()
		g_i3k_game_context:ShowPowerChange()
	else
		g_i3k_ui_mgr:PopupTipMessage("符文镶嵌请求，返回失败"..bean.ok)
	end
	g_i3k_ui_mgr:CloseUI(eUIID_Under_Wear_Rune_Equip)
end


--符文许愿
function i3k_sbean.runeWish(runes,item)
	local data = i3k_sbean.rune_wish_req.new()
	data.runes = runes
	data.item = item
	i3k_game_send_str_cmd(data, i3k_sbean.rune_wish_res.getName())
end

function i3k_sbean.rune_wish_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:ShowGainItemInfo(bean.runes)--弹出奖励 items = {[1] = {id = 66023 ,count = 10}}
		g_i3k_game_context:UseCommonItem(req.item.itemid, req.item.count,AT_RUNE_WISH)--道具消耗
		for k,v in pairs(req.runes) do
			g_i3k_game_context:setRuneBagSubData(k ,v,false)  ----真正刷新符文背包实际数据
		end
		for k,v in pairs(bean.runes) do
			g_i3k_game_context:setRuneBagAddData(v.id ,v.count,false)  ----真正刷新符文背包实际数据
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "setRuneBagWishData",1) --右侧界面刷新(许愿模式)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "wishRefresh")	--符文许愿界面清空
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "upgradeLangRed")
	else
		g_i3k_ui_mgr:PopupTipMessage("符文许愿请求，返回失败"..bean.ok)
	end
end

--符文之语镶嵌
--self.type:		int32
	--self.soltGroupIndex:		int32
	--self.langId:		int32
function i3k_sbean.runeLangPush(wearTag,soltGroupIndex,langId,slotData,LangData,LangIndex) --当前内甲id，当前插槽id，当前符文之语id,当前插槽内符文集合，当前符文之语集合

	local data = i3k_sbean.lang_push_rune_req.new()
	data.type = wearTag
	data.soltGroupIndex = soltGroupIndex
	data.langId = langId
	data.slotData = slotData
	data.LangData = LangData
	data.LangIndex = LangIndex
	i3k_game_send_str_cmd(data, i3k_sbean.lang_push_rune_res.getName())
end

function i3k_sbean.lang_push_rune_res.handler(bean, req)
	if bean.ok == 1 then
		for i,v in ipairs(req.slotData) do
			if v ~=0 then
				g_i3k_game_context:setRuneBagAddData(v ,1,false)
			end
		end
		for i,v in pairs(req.LangData) do
			g_i3k_game_context:setRuneBagSubData(v ,1,false)
			g_i3k_game_context:setRuneSoltData(req.type,req.soltGroupIndex,i,v,v ,true,v,false) --设置装备数据
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune_Lang, "setState",req.LangIndex)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "updateWearRunesData",req.soltGroupIndex) --左侧界面刷新
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "setData")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "upgradeLangRed")
		g_i3k_ui_mgr:PopupTipMessage("成功替换")

		local hero = i3k_game_get_player_hero()
		g_i3k_game_context:SetPrePower()
		local runeTab = g_i3k_game_context:getAnyUnderWearAnyData(req.type,"soltGroupData")
		hero:ArmorRune(req.type, i3k_clone(runeTab))--第二个参数是全部的符文table
		hero:UpdateArmorProps()
		g_i3k_game_context:ShowPowerChange()
	else
		g_i3k_ui_mgr:PopupTipMessage("符文之语镶嵌请求，返回失败"..bean.ok)
	end
end


--玩家内甲虚弱状态(协议修改，返回0和数值)
function i3k_sbean.role_armorweak_update.handler(bean)
	local hero = i3k_game_get_player_hero()
	if bean.weak ~= 0 then
		hero:AttachArmorWeakEffect()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateNeijiaWeek", bean.weak)
	else
		hero:DetachArmorWeakEffect()
	end
end


--进地图同步内甲信息
function i3k_sbean.role_armor.handler(bean)
	local hero = i3k_game_get_player_hero()
	hero:SyncArmorData(bean.armorVal, bean.freeze, bean.weak)
end

--内甲值更新
function i3k_sbean.role_armorval_update.handler(bean)
	local hero = i3k_game_get_player_hero()
	hero:UpdateArmorValue(bean.armorVal)
end

--内甲冻结状态更新
function i3k_sbean.role_armorfreeze_update.handler(bean)
	local hero = i3k_game_get_player_hero()
	hero:SetArmorFreeze(bean.freeze)
end

function i3k_sbean.rune_upgradeReq(runeLangId, nextLvl, items)
	local bean = i3k_sbean.rune_upgrade_req.new()
	bean.runeID = runeLangId
	bean.nextLvl = nextLvl
	bean.items = items
	i3k_game_send_str_cmd(bean, i3k_sbean.rune_upgrade_res.getName())
end

function i3k_sbean.rune_upgrade_res.handler(res, req)
	if res.ok > 0 then
		local cfg = i3k_db_rune_lang_upgrade[req.runeID][req.nextLvl]
		for i,v in ipairs(req.items) do
			g_i3k_game_context:subRuneBag(v, cfg.expendNum)
		end
		
		local hero = i3k_game_get_player_hero()
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:setRuneLangLevel(req.runeID, req.nextLvl)
		hero:UpdateArmorProps()
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune_Lang, "setRuneData", req.runeID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune_Lang, "setRuneLangItemName",req.runeID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "updateLangLabel",req.runeID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune_Lang,"updateListUpRed",req.runeID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune_Lang,"checkCanLangActivate")
		g_i3k_ui_mgr:PopupTipMessage(string.format("%s成功升到%s阶", cfg.name, cfg.lvlName))
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("升阶失败，尴尬"))
	end
end
-- 消耗符文提升铸锭经验
function i3k_sbean.useRuneAddExpReq(langId, runeId, num)
	local bean = i3k_sbean.cast_ingot_use_rune_req.new()
	bean.langId = langId
	bean.runeId = runeId
	bean.num = num
	i3k_game_send_str_cmd(bean, i3k_sbean.cast_ingot_use_rune_res.getName())
end
function i3k_sbean.cast_ingot_use_rune_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FuYuZhuDing, "onAddSuccess", req)
		local hero = i3k_game_get_player_hero()
		g_i3k_game_context:SetPrePower()
		hero:UpdateArmorProps()
		g_i3k_game_context:ShowPowerChange()
	else
		print("失败")
	end
end
