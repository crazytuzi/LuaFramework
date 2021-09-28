------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

-- 同步坐骑信息（登录时同步）
--Packet:role_horseinfo
function i3k_sbean.role_horseinfo.handler(bean, res)
	if bean.info then
		g_i3k_game_context:setSteedShowInfo(bean.info.show)
		g_i3k_game_context:setUseSteed(bean.info.inuseHorse)
		g_i3k_game_context:setAllSteedInfo(bean.info.horses)
		g_i3k_game_context:setAllSteedSkills(bean.info.allHorseSkills)
		g_i3k_game_context:setSteedSkillLevelData(bean.info.allHorseSkills)
		g_i3k_game_context:setSteedFightData(bean.info.fightData)
		g_i3k_game_context:setSteedSpiritInfo(bean.info.spirit)
	end
end

-- 驯服坐骑
--Packet:horse_tame_res
function i3k_sbean.tame_steed(steedId, callback)
	local tame = i3k_sbean.horse_tame_req.new()
	tame.hid = steedId
	tame.callback = callback
	i3k_game_send_str_cmd(tame, "horse_tame_res")
end

function i3k_sbean.horse_tame_res.handler(bean, res)
	if bean.info then
		g_i3k_game_context:SetPrePower()
		if res.callback then
			res.callback()
		end
		local useSteedId = g_i3k_game_context:getUseSteed()
		g_i3k_game_context:setSteedInfo(bean.info)
		if useSteedId==0 then
			local showID = i3k_db_steed_cfg[bean.info.id].huanhuaInitId
			g_i3k_game_context:setSteedCurShowID(showID)
			g_i3k_game_context:setUseSteed(bean.info.id)
		end
		g_i3k_game_context:RefreshRideProps()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "setData", bean.info.id)
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkin, "updateSteedNotice")
		g_i3k_game_context:SetTaskDataByTaskType(res.hid, g_TASK_OWN_HORSE)
		DCEvent.onEvent("坐骑驯服" , { ["坐骑ID"] = tostring(res.hid) })
	else
		g_i3k_ui_mgr:PopupTipMessage("驯服  服务器错误资讯"..res.hid)
	end
end

-- 坐骑出征
--Packet:horse_use_res
function i3k_sbean.steed_fight(hid, callback)
	local fight = i3k_sbean.horse_use_req.new()
	fight.hid = hid
	i3k_game_send_str_cmd(fight, "horse_use_res")
end

function i3k_sbean.horse_use_res.handler(bean, req)
	if bean.ok then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:setUseSteed(req.hid)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "setData", req.hid)
		g_i3k_game_context:ShowPowerChange()
	else
		g_i3k_ui_mgr:PopupTipMessage("出战 服务器错误资讯"..req.hid)
	end
end

-- 坐骑洗练
--Packet:horse_enhance_res
function i3k_sbean.practice_steed(hid, lockParts, items, isReplace, callback)
	local practice = i3k_sbean.horse_enhance_req.new()
	practice.hid = hid
	local locks = {}
	for i,v in pairs(lockParts) do
		locks[v] = true
	end
	practice.locks = locks
	practice.items = items
	practice.isReplace = isReplace
	practice.callback = callback
	i3k_game_send_str_cmd(practice, "horse_enhance_res")
end

function i3k_sbean.horse_enhance_res.handler(bean, res)
	if bean.attrs then
		local steedId = res.hid
		local count = 0
		for i,v in pairs(res.locks) do
			count = count + 1
		end
		local cfg = i3k_db_steed_cfg[steedId]
		count = count > #cfg.practiceLockAddExp and #cfg.practiceLockAddExp or count
		local extraExp = count==0 and 0 or cfg.practiceLockAddExp[count]
		local exp = cfg.practiceGetExp + extraExp	
		local info = g_i3k_game_context:getSteedInfoBySteedId(steedId)
		if info then
			local oldLvl = info.enhanceLvl
			info.enhanceExp = info.enhanceExp + exp
			local lvlCfg = i3k_db_steed_lvl[steedId]
			local totalOldExp = 0
			for i,v in ipairs(lvlCfg) do
				if info.enhanceExp>=v.practiceExp then
					if i>oldLvl then
						totalOldExp = totalOldExp + v.practiceExp
						info.enhanceLvl = i
					end
				else
					if info.enhanceLvl>oldLvl then
						info.enhanceExp = info.enhanceExp - totalOldExp
					end
					break
				end
			end
			g_i3k_game_context:setSteedInfo(info)
			if info.enhanceLvl>oldLvl then
				g_i3k_game_context:SetPrePower()
				g_i3k_game_context:RefreshRideProps()
				g_i3k_game_context:ShowPowerChange()
			end
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedPractice, "setExpData", info)
		end
		
		g_i3k_game_context:SetPrePower()
		if res.callback then
			res.callback(res.items)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedPractice, "addAttrs", res.hid, bean.attrs)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedPractice, "refreshNeedItemData")
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "setData",res.hid)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkin, "updateSteedNotice")
		DCEvent.onEvent("坐骑洗练" , { ["坐骑ID"] = tostring(res.hid) })
		if g_i3k_game_context:getAutoType() == g_AUTO_STEED_REFINE then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedPractice, "canAutoRefine", bean.attrs)
			g_i3k_game_context:subAutoCount(1)
			g_i3k_game_context:doWork()
		end
	else
		g_i3k_game_context:stopDoWork()
		g_i3k_ui_mgr:PopupTipMessage("洗练 服务器错误资讯"..res.hid)
	end
end

-- 坐骑洗练替换属性
--Packet:horse_enhancesave_res
function i3k_sbean.replace_attrs(callback,_oldPartTable,needValue)
	local replace = i3k_sbean.horse_enhancesave_req.new()
	replace.callback = callback
	replace._oldPartTable = _oldPartTable
	replace.needValue = needValue
	i3k_game_send_str_cmd(replace, "horse_enhancesave_res")
end

function i3k_sbean.horse_enhancesave_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:setSavePracticeData(res._oldPartTable ,res.needValue)
		
		g_i3k_game_context:ShowPowerChange()
		if res.callback then
			res.callback()
		end
		--modify by lht 19.5.5 坐骑自动洗脸功能，需要自动保存后回调autoDo
	else
		g_i3k_ui_mgr:PopupTipMessage("保存失败，服务器错误资讯")
	end
end

-- 坐骑升星
--Packet:horse_upstar_res
function i3k_sbean.rise_star(hid, star, callback)
	local rise = i3k_sbean.horse_upstar_req.new()
	rise.hid = hid
	rise.star = star
	rise.callback = callback
	i3k_game_send_str_cmd(rise, "horse_upstar_res")
end

function i3k_sbean.horse_upstar_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_game_context:SetPrePower()
		if res.callback then
			res.callback()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedStar, "updateNextNeedItems", res.hid, res.star)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedStar, "riseSuccessed", res.hid, g_i3k_game_context:getSteedInfoBySteedId(res.hid))
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "setData",res.hid)--
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkin, "updateSteedNotice")
		DCEvent.onEvent("坐骑升星" , { ["坐骑ID"] = tostring(res.hid) })
	else
		g_i3k_ui_mgr:PopupTipMessage("升星失败，服务器错误资讯")
	end
end

-- 激活骑术
--Packet:horse_learnskill_res
function i3k_sbean.learn_skill(steedId, skillId, callback)
	local learn = i3k_sbean.horse_learnskill_req.new()
	learn.hid = steedId
	learn.skillID = skillId
	learn.callback = callback
	i3k_game_send_str_cmd(learn, "horse_learnskill_res")
end

function i3k_sbean.horse_learnskill_res.handler(bean, res)
	if bean.ok==1 then
			local allSkill = g_i3k_game_context:getAllSteedSkills()
			allSkill[res.skillID] = true--激活以后为1级 true
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedActSkill, "onSuccess", g_i3k_game_context:getSteedInfoBySteedId(res.hid))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "setData",res.hid)--
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkin, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkill, "setSkillBagInfo")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkill, "setSkillListRedPoint", res.hid)
		DCEvent.onEvent("启动骑术" , { ["骑术ID"] = tostring(res.skillID) })
	else
		g_i3k_ui_mgr:PopupTipMessage("启动骑术 服务器错误资讯:"..res.skillID)
	end
end

--装备骑术
--Packet:horse_setskill_res
function i3k_sbean.use_steed_skill(hid, position, skillID, index)
	local use = i3k_sbean.horse_setskill_req.new()
	use.hid = hid
	use.position = position
	use.skillID = skillID
	use.index = index
	i3k_game_send_str_cmd(use, "horse_setskill_res")
end

function i3k_sbean.horse_setskill_res.handler(bean, res)
	if bean.ok==1 then
		g_i3k_game_context:SetPrePower()
		local info = g_i3k_game_context:getSteedInfoBySteedId(res.hid)
		local oldIndex
		local oldSkillId
		local count = 0
		for i,v in pairs(info.curHorseSkills) do
			count = count + 1
			if v==res.skillID then
				oldIndex = i
			end
		end
		if oldIndex then
			info.curHorseSkills[oldIndex] = info.curHorseSkills[res.position]
		else
			oldSkillId = info.curHorseSkills[res.position]
		end
		info.curHorseSkills[res.position] = res.skillID
		
		g_i3k_game_context:setSteedInfo(info)
		
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkill,"useSteedSkill", info, oldSkillId, res.index)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkill, "setUseData", info)
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "setData",info.id)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkin, "updateSteedNotice")
	else
		g_i3k_ui_mgr:PopupTipMessage("设置骑术 服务器错误资讯:"..res.hid.."  "..res.skillID)
	end
end


-- 升级骑术等级
--Packet:horse_skill_up_level_res
function i3k_sbean.steed_skill_upLevel(skillId,nextLevel ,useProp,data)
	local use = i3k_sbean.horse_skill_up_level_req.new()
	use.skillID = skillId
	use.nextLevel = nextLevel
	use.useProp = useProp
	use.data = data
	i3k_game_send_str_cmd(use, "horse_skill_up_level_res")
end

function i3k_sbean.horse_skill_up_level_res.handler(bean, res)
	if bean.ok>0 then
		g_i3k_game_context:SetPrePower()
		for i,v in ipairs(res.useProp) do 
			local item = g_i3k_db.i3k_db_get_other_item_cfg(v.itemid)
			if item and item.type == UseItemHorseBook then
				g_i3k_game_context:UseHorseBooks(v.itemid, v.itemCount)
			else
			    g_i3k_game_context:UseCommonItem(v.itemid, v.itemCount,AT_UP_LEVEL_HORSE_SKILL)--回调成功后消耗道具
			end
		end
		g_i3k_game_context:setAnySteedSkillLevelData(res.skillID,res.nextLevel)
		g_i3k_game_context:RefreshRideProps()
		g_i3k_game_context:ShowPowerChange()
		--1刷新tips 2刷新骑术界面及红点 3刷新坐骑界面骑术红点 4刷新主界面 坐骑按钮红点
		local needValue = {
			node = res.data.node,
			skillCfg = res.data.skillCfg,
			skillLvl =res.nextLevel,
			index = res.data.index,
			steedId = res.data.steedId,
			types = res.data.types,
		}
		--g_i3k_ui_mgr:RefreshUI(eUIID_steedSkillUpLevel,nil,needValue) --1刷新tips  下一等级
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_steedSkillUpLevel, "playUpLevelEffect", needValue) 
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkill, "setRedPointData", needValue) -- 2刷新骑术界面及红点
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "setData",res.data.steedId)--3刷新坐骑界面骑术红点
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB,  "updateSteedNotice")--4刷新主界面 坐骑按钮红点
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkin, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkill, "setSkillBagInfo")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkill, "setSkillListRedPoint",res.data.steedId)
	else
		g_i3k_ui_mgr:PopupTipMessage("升级骑术 服务器错误资讯:"..bean.ok)
	end
end

-- 更换幻化外形
--Packet:horse_changeshow_res
function i3k_sbean.change_steed_show(showId, steedId, isOnRide)
	local change = i3k_sbean.horse_changeshow_req.new()
	change.showID = showId
	change.steedId = steedId
	change.isOnRide = isOnRide
	i3k_game_send_str_cmd(change, "horse_changeshow_res")
end

function i3k_sbean.horse_changeshow_res.handler(bean, req)
	if bean.ok==1 then
		if req.steedId then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedHuanhua, "setData", req.steedId)
			g_i3k_ui_mgr:RefreshUI(eUIID_Steed, req.steedId)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_MessageBox2)
		g_i3k_ui_mgr:CloseUI(eUIID_SteedSkinTips)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15534))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkin, "updateScroll")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkin, "loadModuleAndName", req.showID)
		if req.isOnRide == 1 then
			local hero = i3k_game_get_player_hero()
			if hero then
				hero:SetRide(true)
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("更换幻化 服务器错误资讯:")
	end
end

-- 激活幻化外形
--Packet:horse_activateshow_res
function i3k_sbean.act_steed_skin(hid, showID, callback)
	local act = i3k_sbean.horse_activateshow_req.new()
	act.hid = hid -- 追加皮肤传参数0
	act.showID = showID
	act.callback = callback
	i3k_game_send_str_cmd(act, "horse_activateshow_res")
end

function i3k_sbean.horse_activateshow_res.handler(bean, req)
	if bean.ok==1 then
		local cfg = i3k_db_steed_huanhua[req.showID]
		if cfg and cfg.actNeedId ~= 0 then
			g_i3k_game_context:UseCommonItem(cfg.actNeedId, cfg.needCount, AT_ACTIVATE_SHOW)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_SteedSkinTips)
		g_i3k_ui_mgr:CloseUI(eUIID_SteedSkinRenew)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkin, "updateScroll")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkin, "loadModuleAndName", req.showID)
		if req.callback then
			req.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("启动幻化 服务器错误资讯:")
	end
end

-- 坐骑解锁洗练属性
function i3k_sbean.horse_enhance_prop_unlock_req_send(hid, index, itemId, count)
	local bean = i3k_sbean.horse_enhance_prop_unlock_req.new()
	bean.hid = hid
	bean.index = index
	bean.itemId = itemId
	bean.count = count
	i3k_game_send_str_cmd(bean, "horse_enhance_prop_unlock_res")
end

function i3k_sbean.horse_enhance_prop_unlock_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseCommonItem(req.itemId, req.count, AT_ENHANCE_HORSE)
		local info = g_i3k_game_context:getSteedInfoBySteedId(req.hid)
		table.insert(info.enhanceAttrs,{id = 0, value = 0})
		g_i3k_game_context:setSteedInfo(info)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedPractice,"updateActivation",info.enhanceAttrs, info.enhanceLvl, true)
		
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedPractice,"updateLeftProp",info.enhanceAttrs)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedPractice,"addActivationProp")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedPractice,"refreshRightProp",info.enhanceAttrs)
	else
		g_i3k_ui_mgr:PopupTipMessage("horse_enhance_prop_unlock_res code:"..res.ok)
	end
end

-- 更新坐骑皮肤时间
function i3k_sbean.horse_show_update.handler(bean)
	g_i3k_game_context:SetPrePower()
	local info = g_i3k_game_context:getSteedShowIDs()
	info[bean.showID] = bean.endTime
	g_i3k_game_context:setSteedShowIDs(info)
	g_i3k_game_context:RefreshRideProps()
	g_i3k_game_context:ShowPowerChange()
end

-- 同步当前使用皮肤
function i3k_sbean.horse_curshow.handler(bean)
	g_i3k_game_context:SetPrePower()
	g_i3k_game_context:setSteedCurShowID(bean.showID)
	g_i3k_game_context:RefreshRideProps()
	g_i3k_game_context:ShowPowerChange()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkin, "updateScroll")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkin, "loadModuleAndName", bean.showID)
end

-----------------骑术书相关------------------
--骑术书存入
function i3k_sbean.goto_horseBook_push(tab, steedId)
	local data = i3k_sbean.horsebook_push_req.new()
	if tab then
		data.items = tab 
	end
	if steedId then
		data.steedId = steedId
	end
	i3k_game_send_str_cmd(data,"horsebook_push_res")
end

function i3k_sbean.horsebook_push_res.handler(res, req)
	if res.ok > 0 then
		for k,v in pairs(req.items) do
			g_i3k_game_context:AddHorseBooks(k, v)
			g_i3k_game_context:UseCommonItem(k, v,AT_HORSE_BOOK_PUSH)
		end
		if req.steedId then
			g_i3k_ui_mgr:CloseUI(eUIID_SteedSkill)
			g_i3k_ui_mgr:OpenUI(eUIID_SteedSkill)
			g_i3k_ui_mgr:RefreshUI(eUIID_SteedSkill, req.steedId , g_i3k_game_context:getSteedInfoBySteedId(req.steedId))
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkill, "openSkillBooksBag")
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "setData",req.steedId)--3刷新坐骑界面骑术红点
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "updateSteedNotice")
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB,  "updateSteedNotice")--4刷新主界面 坐骑按钮红点
		end
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16921))
	end
end

--骑术书取出 
function i3k_sbean.goto_horseBook_pop(tab, steedId)
	local data = i3k_sbean.horsebook_pop_req.new()
	if tab then
		data.books = tab
		data.steedId = steedId
	end
	i3k_game_send_str_cmd(data,"horsebook_pop_res")
end

function i3k_sbean.horsebook_pop_res.handler(res, req)
	if res.ok > 0 then
		local gift = {}
		for i, v in pairs(req.books) do
			g_i3k_game_context:UseHorseBooks(i, v)
			gift = {{id = i, count = v}}
		end
		g_i3k_ui_mgr:CloseUI(eUIID_SteedSkill)
		g_i3k_ui_mgr:OpenUI(eUIID_SteedSkill)
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedSkill, req.steedId , g_i3k_game_context:getSteedInfoBySteedId(req.steedId))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkill, "openSkillBooksBag")
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16922))
		g_i3k_ui_mgr:ShowGainItemInfo(gift)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "setData",req.steedId)--3刷新坐骑界面骑术红点
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Steed, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB,  "updateSteedNotice")--4刷新主界面 坐骑按钮红点
	end
end

-- 坐骑突破
function i3k_sbean.horse_breakthrough(id, nextBreakLvl)
	local data = i3k_sbean.horse_break_req.new()
	data.hid = id
	data.breakLvl = nextBreakLvl
	i3k_game_send_str_cmd(data,"horse_break_res")
end

function i3k_sbean.horse_break_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetPrePower()
		local cfg = i3k_db_steed_breakCfg[req.hid][req.breakLvl]
		local needId1 = cfg.itemId1
		local needCount1 = cfg.itemCount1
		local needId2 = cfg.itemId2
		local needCount2 = cfg.itemCount2
		g_i3k_game_context:UseCommonItem(needId1, needCount1,AT_STEED_BREAK)
		g_i3k_game_context:UseCommonItem(needId2, needCount2,AT_STEED_BREAK)
		g_i3k_ui_mgr:CloseUI(eUIID_SteedBreak)
		g_i3k_game_context:SetSteedBreakInfo(req.hid, req.breakLvl)
		g_i3k_ui_mgr:RefreshUI(eUIID_Steed, req.hid)
		g_i3k_game_context:RefreshRideProps()
		g_i3k_game_context:ShowPowerChange()
	else
		g_i3k_ui_mgr:PopupTipMessage("突破出错")
	end
end

-- 皮肤激活骑战
function i3k_sbean.horse_showfight_requst(showID)
	local data = i3k_sbean.horse_showfight_req.new()
	data.showID = showID
	i3k_game_send_str_cmd(data, "horse_showfight_res")
end

function i3k_sbean.horse_showfight_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1263))
		for i, e in ipairs(i3k_db_steed_fight_base.unlockItems) do
			g_i3k_game_context:UseCommonItem(e.itemID, e.itemCount, AT_HORSE_SHOW_FIGHT_ACTIVE)
		end
		local fightData = g_i3k_game_context:getSteedFightShowIDs()
		fightData[req.showID] = true
		g_i3k_game_context:setSteedFightShowIDs(fightData)
		g_i3k_game_context:updateRideIsCanFight()
		g_i3k_ui_mgr:CloseUI(eUIID_SteedSkinTips)
		g_i3k_ui_mgr:CloseUI(eUIID_SteedFightUnlock)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSkin, "updateSteedFightIconState", req.showID)
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:RefreshRideProps()
		g_i3k_game_context:ShowPowerChange()
		if g_i3k_game_context:GetLevel() >= i3k_db_steed_fight_base.spiritOpenLvl and g_i3k_game_context:getSteedSpiritStar() <= 0 then 
			g_i3k_game_context:setSteedSpiritStar(0)
		end
		g_i3k_game_context:UpdateSteedSpiritShow()
	end
end

-- 马术精通加经验
function i3k_sbean.horse_master_addexp(items, up_lvl, last_exp, isCanUp)
	local data = i3k_sbean.horse_master_addexp_req.new()
	data.items = items
	data.level = up_lvl
	data.exp = last_exp
	data.isCanUp = isCanUp
	i3k_game_send_str_cmd(data, "horse_master_addexp_res")
end

function i3k_sbean.horse_master_addexp_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedFight, "setCanUse", true)
		g_i3k_game_context:setSteedFightLevel(req.level)
		g_i3k_game_context:setSteedFightExp(req.exp)
		for k,v in pairs(req.items) do
			g_i3k_game_context:UseCommonItem(k, v, AT_HORSE_MASTER_ADDEXP)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedFight, "updateItem")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedFight, "updateExp")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedFight, "isShowFree", req.level, req.isCanUp)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedFight, "UpdateSteedRed")
	end
end

-- 马术精通解锁条目
function i3k_sbean.horse_master_unlock(level, index, item)
	local data = i3k_sbean.horse_master_unlock_req.new()
	data.level = level
	data.index = index
	data.item = item
	i3k_game_send_str_cmd(data, "horse_master_unlock_res")
end

function i3k_sbean.horse_master_unlock_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_SteedFightPropUnlock)
		if req.item then
			for i,e in ipairs(req.item) do
				g_i3k_game_context:UseCommonItem(e.itemID, e.itemCount, AT_HORSE_MASTER_UNLOCK)
			end
		end
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:setSteedFightMasters(req.level, req.index)
		g_i3k_game_context:RefreshRideProps()
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedFight, "isShowFree", req.level)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSteedNotice")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedFight, "UpdateSteedRed")
	end
end

----------------------------良驹之灵 began----------------------------
-- 良驹之灵锤炼
function i3k_sbean.horse_spirit_upstar_request(star, items)
	local data = i3k_sbean.horse_spirit_upstar_req.new()
	data.star = star
	data.items = items
	i3k_game_send_str_cmd(data, "horse_spirit_upstar_res")
end

-- 良驹之灵锤炼(ok:协议是否成功, success:概率是否成功)
function i3k_sbean.horse_spirit_upstar_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:SetPrePower()
		for i,e in ipairs(req.items) do
			g_i3k_game_context:UseCommonItem(e.itemID, e.itemCount, AT_HORSE_SPIRIT_UPSTAR)
		end
		if bean.success > 0 then -- 概率成功
			local str = i3k_get_string(1302)
			local beforeRank = g_i3k_game_context:getSteedSpiritRank()
			g_i3k_game_context:setSteedSpiritStar(req.star)
			g_i3k_game_context:setSteedSpiritUpStarTimes(0)
			local cfg = i3k_db_steed_fight_base
			local actionName = cfg.lightAction
			if g_i3k_game_context:getSteedSpiritRank() ~= beforeRank then
				actionName = cfg.levelUpAction
				str = i3k_get_string(1303)
				g_i3k_ui_mgr:OpenUI(eUIID_SteedSpiritUpRank)
				g_i3k_ui_mgr:RefreshUI(eUIID_SteedSpiritUpRank)
			end
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSprite, "loadSpiritModel", actionName)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSprite, "loadSpiritPropScroll")
			g_i3k_ui_mgr:PopupTipMessage(str)
		else
			g_i3k_game_context:addSteedSpiritUpStarTimes()
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1304))
		end
		g_i3k_game_context:RefreshRideProps()
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSprite, "loadSpiritStarInfo")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSprite, "loadSpiritSkillsInfo")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSprite, "UpdateSteedRed")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSteedNotice")
	else
		g_i3k_ui_mgr:PopupTipMessage("良驹之灵锤炼，服务器返回失败")
	end
end

-- 良驹之灵更换形象
function i3k_sbean.horse_spirit_setshow_request(showID)
	local data = i3k_sbean.horse_spirit_setshow_req.new()
	data.showID = showID
	i3k_game_send_str_cmd(data, "horse_spirit_setshow_res")
end

function i3k_sbean.horse_spirit_setshow_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1301))
		g_i3k_game_context:setSteedSpiritCurShowID(req.showID)
		g_i3k_game_context:UpdateSteedSpiritShow()
		g_i3k_ui_mgr:CloseUI(eUIID_SteedSpiritShows)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSprite, "loadSpiritModel")
	else
		g_i3k_ui_mgr:PopupTipMessage("良驹之灵更换形象，服务器返回失败")
	end
end

-- 良驹之灵升阶自动更换形象
function i3k_sbean.horse_spirit_showauto_request(auto)
	local data = i3k_sbean.horse_spirit_showauto_req.new()
	data.auto = auto
	i3k_game_send_str_cmd(data, "horse_spirit_showauto_res")
end

function i3k_sbean.horse_spirit_showauto_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:setSteedSpiritAutoChange(req.auto)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSpiritShows, "loadIsAutoIcon", req.auto == 1)
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器返回失败")
	end
end

-- 良驹之灵隐藏形象
function i3k_sbean.horse_spirit_hide_reqest(hide)
	local data = i3k_sbean.horse_spirit_hide_req.new()
	data.hide = hide
	i3k_game_send_str_cmd(data, "horse_spirit_hide_res")
end

function i3k_sbean.horse_spirit_hide_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:setSteedSpiritIsHide(req.hide)
		g_i3k_game_context:UpdateSteedSpiritShow()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSpiritShows, "loadIsHideIcon", req.hide == 1)
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器返回失败")
	end
end

-- 良驹之灵技能升级(lvl 1:解锁技能)
function i3k_sbean.horse_spirit_skill_lvlup_request(skillID, lvl, items)
	local data = i3k_sbean.horse_spirit_skill_lvlup_req.new()
	data.skillID = skillID
	data.lvl = lvl
	data.items = items
	i3k_game_send_str_cmd(data, "horse_spirit_skill_lvlup_res")
end

function i3k_sbean.horse_spirit_skill_lvlup_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_SteedSpiritSkillUnlock)
		for i, e in ipairs(req.items) do
			g_i3k_game_context:UseCommonItem(e.itemID, e.itemCount, AT_HORSE_SPIRIT_SKILL_LVLUP)
		end
		local dbCfg = i3k_db_steed_fight_spirit_skill[req.skillID]
		if req.lvl == #dbCfg then
			g_i3k_ui_mgr:CloseUI(eUIID_SteedSpiritSkillUp)
		end
		g_i3k_game_context:setSteedSpiritSkillsLvl(req.skillID, req.lvl)
		if req.lvl == 1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1299, dbCfg[req.lvl].skillName))
			g_i3k_game_context:UpdateSteedSpiritSpeed()
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1300))
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSprite, "loadSpiritSkillsInfo")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSprite, "loadSpiritStarInfo")
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedSpiritSkillUp, req.skillID, req.lvl)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSprite, "UpdateSteedRed")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSteedNotice")
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器返回失败")
	end
end

-- 新增良驹之灵形象
function i3k_sbean.horse_spirit_show_add.handler(bean)
	local showID = bean.showID
	if showID then
		if g_i3k_game_context:getSteedSpiritCurShowID() == 0 then --初始外显
			g_i3k_game_context:setSteedSpiritCurShowID(showID)
		end
		g_i3k_game_context:autoChangeSteedSpiritModel(showID)
		g_i3k_game_context:addSteedSpiritShowIDs(showID)
	end
end

-- 解锁良驹之灵追加形象
function i3k_sbean.unlock_steed_add_spirit(showID)
	local data = i3k_sbean.horse_spirit_unlock_req.new()
	data.showID = showID
	i3k_game_send_str_cmd(data, "horse_spirit_unlock_res")
end

function i3k_sbean.horse_spirit_unlock_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseCommonItem(i3k_db_steed_fight_spirit_show[req.showID].needItem, i3k_db_steed_fight_spirit_show[req.showID].needItemCount, AT_UNLOCK_HORSESPIRIT_SHOWS)
		g_i3k_game_context:addSteedSpiritShowIDs(req.showID)
		if g_i3k_game_context:getSteedSpiritCurShowID() == 0 then --初始外显
			g_i3k_game_context:setSteedSpiritCurShowID(req.showID)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_UnlockSteedAddSpirit)
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedSpiritShows)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSprite, "UpdateSteedRed")
	end
end

----------------------------良驹之灵 end----------------------------
----------------------------骑战装备 start----------------------------
-- 登录同步骑战装备
--DBSteedEquip
	--curClothes (map[int32,int32])
	--allSuits (set[int32])
--DBSteedEquipForge
	--lvl int32
	--exp int64
function i3k_sbean.steed_equip_login_sync.handler(res)
	local info = res.info
	g_i3k_game_context:SetSteedEquipData(info.equip)
	g_i3k_game_context:SetSteedForgeData(info.forge) -- 熔炉
	g_i3k_game_context:SetSteedForgeEnergy(info.forgeEnergy) -- 熔炼精华
end

-- 穿骑战装备
function i3k_sbean.dress_steed_equip(equips, callback)
	--self.equips:		map[int32, int32]
	local data = i3k_sbean.dress_steed_equip_req.new()
	data.equips = equips
	data.callback = callback
	i3k_game_send_str_cmd(data, "dress_steed_equip_res")
end

function i3k_sbean.dress_steed_equip_res.handler(res, req)
	if res.ok > 0 then
		local oldPower = g_i3k_game_context:GetSteedEquipFightPower()

		g_i3k_game_context:WearSteedEquip(req.equips)
		g_i3k_game_context:RefreshSteedEquipProp()

		local afterPower = g_i3k_game_context:GetSteedEquipFightPower()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedEquip, "changeBattlePower", afterPower, oldPower)

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedEquip, "updateEquipUI")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedEquip, "updateBagUI")

		--一键装备后打开套装激活界面
		if req.callback then
			req.callback()
		end

		g_i3k_ui_mgr:CloseUI(eUIID_steedEquipPropCmp)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1103))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1104))
	end
end

-- 脱骑战装备
function i3k_sbean.takeoff_steed_equip(parts)
	--self.parts:		set[int32]
	local data = i3k_sbean.takeoff_steed_equip_req.new()
	data.parts = parts
	i3k_game_send_str_cmd(data, "takeoff_steed_equip_res")
end

function i3k_sbean.takeoff_steed_equip_res.handler(res, req)
	if res.ok > 0 then
		local oldPower = g_i3k_game_context:GetSteedEquipFightPower()

		for partID in pairs(req.parts) do
			g_i3k_game_context:UnwearSteedEquip(partID)
		end
		g_i3k_game_context:RefreshSteedEquipProp()

		local afterPower = g_i3k_game_context:GetSteedEquipFightPower()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedEquip, "changeBattlePower", afterPower, oldPower)

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedEquip, "updateEquipUI")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedEquip, "updateBagUI")

		g_i3k_ui_mgr:CloseUI(eUIID_steedEquipPropCmp)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1496))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1647))
	end
end

-- 制作骑战装备
function i3k_sbean.steed_equip_create(lvl, rank, part, times)
	--self.lvl:		int32
	--self.rank:		int32
	--self.part:		int32
	--self.times:		int32
	local data = i3k_sbean.steed_equip_create_req.new()
	data.lvl = lvl
	data.rank = rank
	data.part = part
	data.times = times
	i3k_game_send_str_cmd(data, "steed_equip_create_res")
end

function i3k_sbean.steed_equip_create_res.handler(res, req)
	--self.ok:		int32
	--self.items:		vector[DummyGoods]
	if res.ok > 0 then
		if req.times > 1 then
			g_i3k_ui_mgr:ShowGainItemInfo(res.items)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1648))
			local equipID = res.items[1].id
			-- local count = res.items[1].count -- 1
			g_i3k_ui_mgr:OpenUI(eUIID_steedEquipPropCmp)
			g_i3k_ui_mgr:RefreshUI(eUIID_steedEquipPropCmp, equipID, g_STEED_EQUIP_TIPS_NONE)
		end
		local cfg = g_i3k_db.i3k_db_get_steed_equip_duanzao_cfg(req.lvl, req.rank)
		for _, v in ipairs(cfg.needItems) do
			g_i3k_game_context:UseCommonItem(v.id, v.count * req.times, AT_STEED_EQUIP_CREATE)
		end
		if req.part ~= 0 then
			for _, v in ipairs(cfg.externItem) do
				g_i3k_game_context:UseCommonItem(v.id, v.count * req.times, AT_STEED_EQUIP_CREATE)
			end
		end
		-- TODO 计算熔炼值和熔炉等级并刷新
		g_i3k_game_context:AddSteedStoveValue(cfg.exp * req.times)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_steedEquipMake, "setConsume")
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1649))
	end
end

-- 熔炼骑战装备
function i3k_sbean.steed_equip_destory(equips)
	--self.equips:		map[int32, int32]
	local data = i3k_sbean.steed_equip_destory_req.new()
	data.equips = equips
	i3k_game_send_str_cmd(data, "steed_equip_destory_res")
end

function i3k_sbean.steed_equip_destory_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1650))
		local value = 0
		for k, v in pairs(req.equips) do
			g_i3k_game_context:UseCommonItem(k, v, AT_STEED_EQUIP_DESTORY)
			local equipCfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(k)
			value = value + equipCfg.stoveValue * v
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_steedEquipSale, "clearSelectItem")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_steedEquipSale, "updateBagUI")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_steedEquipSale2, "clearSelectItem")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_steedEquipSale2, "updateBagUI")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedStove, "updateBagUI")
		local items = {{id = g_BASE_ITEM_STEED_EQUIP_SPIRIT, count = value}}
		g_i3k_ui_mgr:ShowGainItemInfo(items)
	end
end

-- 骑战套装激活
function i3k_sbean.steedEquipSuitActive(suitID)
	local data = i3k_sbean.unlock_steed_equip_suit_req.new()
	data.suitID = suitID
	i3k_game_send_str_cmd(data, "unlock_steed_equip_suit_res")
end

function i3k_sbean.unlock_steed_equip_suit_res.handler(res, req)
	if res.ok > 0 then
		local suitID = req.suitID

		local wEquip = g_i3k_game_context:GetSteedWearEquipsData()
		for partID in pairs(wEquip) do
			g_i3k_game_context:UnwearSteedEquip(partID)
		end
		g_i3k_game_context:UpdateSteedAllSuitsData(suitID)
		g_i3k_game_context:RefreshSteedEquipProp()

		local suitCfg = i3k_db_steed_equip_suit[suitID]
		for _, v in ipairs(suitCfg.needItems) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, AT_STEED_EQUIP_SUIT)
		end

		g_i3k_ui_mgr:RefreshUI(eUIID_SteedSuit, suitID)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1651, suitCfg.name))
		g_i3k_ui_mgr:CloseUI(eUIID_SteedSuitActive)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1652))
	end
end

----------------------------骑战装备 end----------------------------
