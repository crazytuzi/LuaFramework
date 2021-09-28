------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/network/channel/i3k_channel")
--元宝类型
FINGOT_TYPE = -1
BINGOT_TYPE = 1

-----------------------------------------------------------

---------------------------自创武功---------------------------------

-- 获取初始自创技能数据
function i3k_sbean.getDiySkillSync(t, gradeId, freshType, typeNum, skillIndex)  --freshType 1 预设请求 2 预设保存请求 3 预设改变请求   --typeNum 点击类型 --skillindex -- 位置
	local data = i3k_sbean.diyskill_sync_req.new()
	data.value = t
	data.gradeId = gradeId
	data.freshType = freshType
	data.typeNum = typeNum
	data.skillIndex = skillIndex
	i3k_game_send_str_cmd(data,i3k_sbean.diyskill_sync_res.getName())
end
function i3k_sbean.diyskill_sync_res.handler(bean,res)
	if not bean.diySkill then
		return
	end
	local diySkillData = bean.diySkill.diySkillData
	local diySkillShare = bean.diySkill.diySkillShare
	local isOpenPKH = res.value -- 是否开启破控幻

	local equipSkillID = 0
	local equipSkillData = nil
	local equipSkillIconID = 0
	local equipSkillGradeId = nil
	if diySkillData.curSkillId == 0 then
		if diySkillData.borrowDiySkill and next(diySkillData.borrowDiySkill) then
			equipSkillID = 1
			equipSkillData = {}
			equipSkillData[equipSkillID] = diySkillData.borrowDiySkill
			equipSkillIconID = diySkillData.borrowDiySkill.iconId
			equipSkillGradeId = diySkillData.borrowDiySkill.diySkillData.gradeId
		end
	else
		equipSkillID = diySkillData.curSkillId
		equipSkillData = diySkillData.diySkills
		equipSkillIconID = diySkillData.diySkills[diySkillData.curSkillId].iconId
		equipSkillGradeId = diySkillData.diySkills[diySkillData.curSkillId].diySkillData.gradeId
	end

	g_i3k_game_context:setCreateKungfuSkillIcon(equipSkillIconID)
	g_i3k_game_context:setCurrentSkillID(equipSkillID) -- 通过这个ID，索引下面的那个表，找到技能的数据
	g_i3k_game_context:setCurrentSkillGradeId(equipSkillGradeId)
	g_i3k_game_context:setCreateKungfuData(equipSkillData)

	local tmp = {}
	tmp.skillPos = equipSkillID
	g_i3k_game_context:refreshDiySkillInBattle(tmp)

	g_i3k_game_context:setDiySkillAndBorrowSkill(diySkillData.diySkills, diySkillData.borrowDiySkill)

	if not res.freshType or res.freshType == g_SKILLPRE_DIY_FRESHTYPE_FORGET then
		g_i3k_ui_mgr:OpenUI(eUIID_CreateKungfu)
		g_i3k_ui_mgr:RefreshUI(eUIID_CreateKungfu,diySkillData,isOpenPKH,diySkillShare)
		g_i3k_ui_mgr:RefreshUI(eUIID_CreateKungfuSuccess,nil,nil,diySkillData)
		if res.gradeId ~= nil then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_CreateKungfu,"showModel",i3k_db_kungfu_args.successAction,i3k_get_string(481,i3k_db_create_kungfu_score[res.gradeId].name,i3k_db_create_kungfu_score[res.gradeId].desc));
		end
		if res.freshType == g_SKILLPRE_DIY_FRESHTYPE_FORGET then
			g_i3k_game_context:changeDiyPre()
		end
	elseif res.freshType == g_SKILLPRE_DIY_FRESHTYPE_PRE then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"openSkillPreSet",res.typeNum,res.skillIndex)
	elseif res.freshType == g_SKILLPRE_DIY_FRESHTYPE_CHANGE then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(572))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SkillPreset,"selectSkillCB")
	elseif res.freshType == g_SKILLPRE_DIY_FRESHTYPE_SET then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SkillLy,"goSkillSetUI")
	end
end

-- 创建武功 new
function i3k_sbean.createDiySkill(wudao,myData,pkh,my_diySkillShare)
	local data = i3k_sbean.diyskill_create_req.new()
	data.params = wudao
	data.trends = {}
	if pkh and next(pkh) then
		for k,v in ipairs(pkh) do
			if v ~= 0 then
				data.trends[k+6] = 0
			end
		end
	end
	data.myData = myData
	data.my_diySkillShare = my_diySkillShare
	i3k_game_send_str_cmd(data, i3k_sbean.diyskill_create_res.getName())
end
function i3k_sbean.diyskill_create_res.handler(bean,req)
	local diySkill = bean.diySkill
	if diySkill == nil then
		g_i3k_ui_mgr:PopupTipMessage("创建武功失败")
		return
	end
	local myDataa = req.myData
	local my_diySkillShare = req.my_diySkillShare
	local gradeId = diySkill.gradeId
	local exp = i3k_db_create_kungfu_score[gradeId].exp
	local is_ok = g_i3k_game_context:isDiySkillLevelUp(exp,myDataa)
	if is_ok then
		g_i3k_game_context:removeTmpKungfuData()
	end
	i3k_sbean.getDiySkillSync()
	g_i3k_game_context:diySkillCreate(diySkill,myDataa,my_diySkillShare)
	DCEvent.onEvent("创建帮派自创武功")
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_KONGFU, g_SCHEDULE_COMMON_MAPID)
end


-- 遗忘技能
function i3k_sbean.diySkill_discard_skill(id,bValue)
	local data = i3k_sbean.diyskill_discard_req.new()
	data.skillPos = id
	data.value = bValue
	i3k_game_send_str_cmd(data,i3k_sbean.diyskill_discard_res.getName())
end
function i3k_sbean.diyskill_discard_res.handler(bean,res)
	--local t = bean
	if bean.ok == 1 then
		g_i3k_ui_mgr:CloseUI(eUIID_KungfuFull)
		g_i3k_ui_mgr:CloseUI(eUIID_KungfuDetail)
		g_i3k_game_context:setDiscardDiyPos(res.skillPos)
		i3k_sbean.getDiySkillSync(res.value,nil,g_SKILLPRE_DIY_FRESHTYPE_FORGET)
	end
end

-- 修改技能，保存
function i3k_sbean.diySkill_sava_skill(iconId,name, gradeId)
	local data = i3k_sbean.diyskill_save_req.new()
	data.iconId = iconId
	data.name = name
	data.gradeId = gradeId
	i3k_game_send_str_cmd(data,i3k_sbean.diyskill_save_res.getName())
end
function i3k_sbean.diyskill_save_res.handler(bean,res)
	if bean.ok == 1 then
		i3k_sbean.getDiySkillSync(false, res.gradeId)
		g_i3k_ui_mgr:CloseUI(eUIID_CreateKungfuSuccess)
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_CreateKungfu,"onShowData")

	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(321))
	end
end

-- 购买创建武功次数
function i3k_sbean.diyskill_buytimes(times, needMoney)
	local data = i3k_sbean.diyskill_buytimes_req.new()
	data.times = times
	data.needMoney = needMoney
	i3k_game_send_str_cmd(data, i3k_sbean.diyskill_buytimes_res.getName())
end
function i3k_sbean.diyskill_buytimes_res.handler(bean,res)
	if bean.ok == 1 then
		g_i3k_game_context:UseDiamond(res.needMoney, false,AT_DIY_SKILL_BUY_TIMES)
		i3k_sbean.getDiySkillSync()
		g_i3k_ui_mgr:CloseUI(eUIID_KungfuBuyCount)
	else
		g_i3k_ui_mgr:PopupTipMessage("购买创建次数失败"..bean.ok)
	end
end


-- 装备自创技能
function i3k_sbean.diyskill_selectuse(pos,freshType)
	local data = i3k_sbean.diyskill_selectuse_req.new()
	data.skillPos = pos
	data.freshType = freshType
	i3k_game_send_str_cmd(data,i3k_sbean.diyskill_selectuse_res.getName())
end
function i3k_sbean.diyskill_selectuse_res.handler(bean,res)
	if bean.ok == 1 then
		g_i3k_ui_mgr:CloseUI(eUIID_KungfuDetail)
		i3k_sbean.getDiySkillSync(true,nil,res.freshType)
		-- 在战斗场景中装备这个技能
		g_i3k_game_context:refreshDiySkillInBattle(res)
	end
end

-- 卸下自创武功
function i3k_sbean.diySkill_canceluse(pos)
	local data = i3k_sbean.diyskill_canceluse_req.new()
	data.skillPos = pos
	i3k_game_send_str_cmd(data,i3k_sbean.diyskill_canceluse_res.getName())
end
function i3k_sbean.diyskill_canceluse_res.handler(bean,res)
	if bean.ok  == 1 then
		g_i3k_ui_mgr:CloseUI(eUIID_KungfuDetail)
		i3k_sbean.getDiySkillSync(true)
	end
end

-- 解锁空槽
function i3k_sbean.diySkill_unlock()
	local data = i3k_sbean.diyskill_unlock_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.diyskill_unlock_res.getName())
end
function i3k_sbean.diyskill_unlock_res.handler(bean,res)
	if bean.ok == 1 then
		g_i3k_ui_mgr:CloseUI(eUIID_KungfuFull)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(315))
		i3k_sbean.getDiySkillSync(true)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(525))
	end
end


--  自创武功分享
function i3k_sbean.shareDiySkill(pos)
	local data = i3k_sbean.diyskill_share_req.new()
	data.skillPos = pos
	i3k_game_send_str_cmd(data,i3k_sbean.diyskill_share_res.getName())
end
function i3k_sbean.diyskill_share_res.handler(bean,res)
	if bean.ok == 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(521))
		i3k_sbean.getDiySkillSync(true)
		g_i3k_ui_mgr:CloseUI(eUIID_KungfuDetail)
	elseif bean.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(522))
	elseif bean.ok == -42 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(523))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(524))
	end
end

-- 自创武功取消分享
function i3k_sbean.cancelShareDiySkill(pos)
	local data = i3k_sbean.diyskill_cancelshare_req.new()
	data.skillPos = pos
	i3k_game_send_str_cmd(data,i3k_sbean.diyskill_cancelshare_res.getName())
end
function i3k_sbean.diyskill_cancelshare_res.handler(bean,res)
	if bean.ok == 1 then
		g_i3k_ui_mgr:CloseUI(eUIID_KungfuDetail)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(526))
		i3k_sbean.getDiySkillSync()
	else
		g_i3k_ui_mgr:PopupTipMessage("取消分享失败"..bean.ok)
	end
end

-- 自创武功借用
function i3k_sbean.borrowDiySkill(skillId, roleId)
	local data = i3k_sbean.diyskill_borrow_req.new()
	data.roleId = roleId
	data.skillId = skillId
--	data.clanId = g_i3k_game_context:GetCurrentClanId()
	i3k_game_send_str_cmd(data,i3k_sbean.diyskill_borrow_res.getName())
end
function i3k_sbean.diyskill_borrow_res.handler(bean,res)
	if bean.ok  == 1 then
		local borrowSkill = bean.diyskill -- 借用到的技能
		local t = {}
		t[borrowSkill.id] = {}
		t[borrowSkill.id] = borrowSkill
		g_i3k_game_context:setCurrentSkillID(borrowSkill.id)
		g_i3k_game_context:setCreateKungfuData(t)
		local tmp = {}
		tmp.skillPos = borrowSkill.id
		g_i3k_game_context:refreshDiySkillInBattle(tmp)

		i3k_sbean.getDiySkillSync()
		g_i3k_ui_mgr:CloseUI(eUIID_KungfuDetail)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(527))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(528))
	end
end


-- 自创武功炫耀
function i3k_sbean.showOffDiySkill(c,p)
	local data = i3k_sbean.diyskill_flaunt_req.new()
	data.channel = c
	data.skillPos = p
	i3k_game_send_str_cmd(data,i3k_sbean.diyskill_flaunt_res.getName())
end
function i3k_sbean.diyskill_flaunt_res.handler(bean,res)
	if bean.ok == 1 then
		--消耗大喇叭
		if res.channel== 1 then
			local needItemId = i3k_db_common.chat.worldNeedId
			g_i3k_game_context:UseCommonItem(needItemId,1,AT_USE_CHAT_ITEM)
		end
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(529))
	else
		g_i3k_ui_mgr:PopupTipMessage("炫耀失败"..bean.ok)
	end
end

--
----工坊同步
function i3k_sbean.product_data_sync(index1,index2,index3) -- index3 Pagenum
	local role_lvl = g_i3k_game_context:GetLevel()
	if role_lvl < i3k_db_producetion_args.open_lvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(587,i3k_db_producetion_args.open_lvl))
		return
	end
	local data = i3k_sbean.produce_workshopsync_req.new()
	if index1 then
		data.index1 = index1
	end
	if index2 then
		data.index2 = index2
	end
	if index3 then
		data.index3 = index3
	end
	i3k_game_send_str_cmd(data,i3k_sbean.produce_workshopsync_res.getName())
end

function i3k_sbean.produce_workshopsync_res.handler(res,req)
	local produceRecipes = res.syncInfo
	local fusionfurnaceOpened = res.fusionfurnaceOpened  --炼化炉开启标志
	local fusionPoint = res.fusionPoint  --炼化剩余点数
	local fusionedItemCnt = res.fusionedItemCnt  --今日已炼化物品数量

	g_i3k_game_context:SetProductionSplit(produceRecipes.splitSP)
	g_i3k_game_context:SetProdunctionLvl(produceRecipes.produceLvl)
	g_i3k_game_context:SetProdunctionExp(produceRecipes.produceExp)
	g_i3k_game_context:SetProdunctionTImes(produceRecipes.dayBuyTimes)
	g_i3k_game_context:SetRecycleRemainPoint(fusionPoint)
	g_i3k_game_context:SetRecycleCanOpen(fusionfurnaceOpened)
	g_i3k_game_context:SetRecycledItemCnt(fusionedItemCnt)

	if produceRecipes.recipes then
		local data = {}
		for k,v in pairs(produceRecipes.recipes) do
			table.insert(data,v)
		end

		g_i3k_game_context:setProductionRecipes(data)
		g_i3k_ui_mgr:OpenUI(eUIID_Production)
		if req.index1 and req.index2 then
			g_i3k_ui_mgr:RefreshUI(eUIID_Production,req.index1,req.index2)
		elseif req.index3 then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production,"freshPage",req.index3)
		else
			g_i3k_ui_mgr:RefreshUI(eUIID_Production)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("宗门生产资讯错误")
	end
end

----使用卷轴   废弃
-- function i3k_sbean.product_use_juanzhou(args)
-- 	local data =i3k_sbean.produce_createnewrecipe_req.new()
-- 	data.reelID = args.reelID
-- 	i3k_game_send_str_cmd(data,i3k_sbean.produce_createnewrecipe_res.getName())
-- end
--
-- function i3k_sbean.produce_createnewrecipe_res.handler(res,req)
-- 	local ok = res.ok
-- 	if ok > 0 then
-- 		g_i3k_game_context:UseCommonItem(req.reelID,1,AT_USE_ITEM_AS_RECIPEREEL)
-- 		g_i3k_ui_mgr:PopupTipMessage("配方使用成功")
-- 	else
-- 		g_i3k_ui_mgr:PopupTipMessage("配方使用失败")
-- 	end
-- end
--
----制造
function i3k_sbean.produnce_create(recipeID,recType)
	local data = i3k_sbean.produce_produce_req.new()
	data.recipeID = recipeID
	data.recipeType = recType
	i3k_game_send_str_cmd(data,i3k_sbean.produce_produce_res.getName())
end
--
local production_namelist = {"武器制造","防具制造","饰品制造","神兵制造","随从制造","药品制造","杂物制造"}
function i3k_sbean.produce_produce_res.handler(res,req)
	local is_up_lvl = false
	if res.ok > 0 then

		local recipeID = req.recipeID
		local cfg = i3k_db_productioninfo[recipeID]
		--local data = g_i3k_game_context:getClanDetailData()
		for k,v in ipairs(cfg.production_cost) do

			if v.ItemID ~= 0 then
				g_i3k_game_context:UseCommonItem(v.ItemID,v.ItemCount,AT_CLAN_PRODUCE)
			end

		end
		local produceLvl = g_i3k_game_context:GetProdunctionLvl()
		local produceExp = g_i3k_game_context:GetProdunctionExp()

		local cfglvl = i3k_db_clan_production_up_lvl
		local cfg1 = cfglvl[produceLvl]
		local cfg2 = cfglvl[produceLvl]
		if produceLvl < #cfglvl then
			cfg2 = cfglvl[produceLvl+1]
		end
		local tempExp = produceExp + cfg.exp_get
		while tempExp >= cfg2.exp_count do
			if cfg1.level == cfg2.level then
				tempExp = cfg2.exp_count
				break;
			else
				tempExp = tempExp - cfg2.exp_count
				produceLvl = produceLvl + 1
				is_up_lvl = true
				cfg1 = cfglvl[produceLvl]
				cfg2 = cfglvl[produceLvl]
				if produceLvl < #cfglvl then
					cfg2 = cfglvl[produceLvl+1]
				end
			end
		end
		produceExp = tempExp

		g_i3k_game_context:SetProdunctionLvl(produceLvl)
		g_i3k_game_context:SetProdunctionExp(produceExp)
		--g_i3k_game_context:setClanDetailData(data)
		g_i3k_ui_mgr:PopupTipMessage("成功生产了物品~~~")

		if production_namelist[req.recipeType] then
		    local eventID = production_namelist[req.recipeType]
		    local map = {}
		    map[eventID] = tostring(req.recipeID)
			DCEvent.onEvent("生产系统" , map)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production, "productionSuccess",is_up_lvl)
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_PRODUCT, g_SCHEDULE_COMMON_MAPID)
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15515))
	else
		g_i3k_ui_mgr:PopupTipMessage("生产失败")
	end

end
--
----装备分解
function i3k_sbean.produce_fenjie(equipid,equipGuid)
	local data = i3k_sbean.produce_split_req.new()
	data.equipid = equipid
	data.equipGuid = equipGuid
	i3k_game_send_str_cmd(data,i3k_sbean.produce_split_res.getName())
end

function i3k_sbean.produce_split_res.handler(res,req)
	if res.ok > 0 then

		g_i3k_game_context:DelBagEquip(req.equipid, req.equipGuid,AT_CLAN_SPLIT)
		local cfg =  g_i3k_db.i3k_db_get_common_item_cfg(req.equipid)
		if cfg then
			if cfg.SeparationCost >0 then
				g_i3k_game_context:RemoveProductionSplit(cfg.SeparationCost,AT_CLAN_SPLIT_SP_BUY)
			end
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production, "seperationSuccess")
		g_i3k_ui_mgr:PopupTipMessage("成功分解了物品~")

		DCEvent.onEvent("生产分解" , { equipID = tostring(req.equipid) })
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_RESOLVE, g_SCHEDULE_COMMON_MAPID)
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15516))
	else
		g_i3k_ui_mgr:PopupTipMessage("您的背包已满分解失败")
	end
end

----购买能量
function i3k_sbean.produce_by_split(times)
	local data = i3k_sbean.produce_splitspbuy_req.new()
	data.times = times
	i3k_game_send_str_cmd(data,i3k_sbean.produce_splitspbuy_res.getName())
end

function i3k_sbean.produce_splitspbuy_res.handler(res,req)
	if res.ok > 0 then

		local DMoney
		if req.times <= #i3k_db_clan_separation.cost_money then
			DMoney = i3k_db_clan_separation.cost_money[req.times]
		else
			DMoney = i3k_db_clan_separation.cost_money[#i3k_db_clan_separation.cost_money]
		end
		g_i3k_game_context:SetProdunctionTImes(req.times)
		g_i3k_game_context:UseDiamond(DMoney,false,AT_CLAN_SPLIT_SP_BUY)
		g_i3k_ui_mgr:PopupTipMessage("能量购买成功")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production, "setTitleAttribute")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production, "setProductionLevel3")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandProduce, "updateNeedData")
		g_i3k_ui_mgr:CloseUI(eUIID_ProductionBuyTimes)
	else
		g_i3k_ui_mgr:PopupTipMessage("购买失败")
	end
end

function i3k_sbean.role_add_splitsp.handler(bean)
	if bean then
		--local data = g_i3k_game_context:getClanDetailData()
		--data.clanData.splitSP = data.clanData.splitSP + bean.splitsp
		--g_i3k_game_context:setClanDetailData(data)
		g_i3k_game_context:AddProductionSplit(bean.splitsp)

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production, "setTitleAttribute")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production, "updateSeperationLayer")
		if not i3k_dataeye_itemtype(bean.reason) then
			DCItem.get(g_BASE_ITEM_SPLITSP, "生产分解能量", bean.splitsp, bean.reason)
		end
	end
end

--装备精炼 -- costItem --消耗的道具 --pos -- 如果是身上的穿部位，不是穿0
function i3k_sbean.refine_equip(id,guid,pos,costItem,original,isFree)
	local data = i3k_sbean.equip_refine_req.new()
	data.id = id
	data.guid = guid
	data.pos = pos
	data.costItem = costItem
	data.original = original
	data.isFree = isFree
	i3k_game_send_str_cmd(data,i3k_sbean.equip_refine_res.getName())
end

function i3k_sbean.equip_refine_res.handler(res,req)
	if res.props then
		local equipcfg =  g_i3k_db.i3k_db_get_equip_item_cfg(req.id)
		g_i3k_ui_mgr:PopupTipMessage("精炼成功")
		g_i3k_game_context:UseCommonItem(req.costItem, 1,AT_EQUIP_REFINE)
		local itemId = equipcfg.refineItemId
		local itemCount = equipcfg.refineItemCount
		g_i3k_game_context:UseCommonItem(itemId, itemCount,AT_EQUIP_REFINE)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production,"updateOneEquipRefineItems",req.id)
		local item = {}
		local itemID = req.id
		local eventId = "装备精炼"
		item["装备ID"] = tostring(itemID)
		DCEvent.onEvent(eventId, item)
		g_i3k_ui_mgr:OpenUI(eUIID_RefineTip)
		g_i3k_ui_mgr:RefreshUI(eUIID_RefineTip,req, res.props, req.isFree)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RefineTip,"UpdateLab",req.original,res.props,req.costItem)
		
	else
		g_i3k_ui_mgr:PopupTipMessage("精炼失败")
	end
end
--精炼的二次确定保存
function i3k_sbean.refine_equip_save(id, guid, pos, newProps,isFree)
	local data = i3k_sbean.equip_refine_save_req.new()
	data.id = id
	data.guid = guid
	data.pos = pos
	data.newProps = newProps
	data.isFree = isFree
	i3k_game_send_str_cmd(data,i3k_sbean.equip_refine_save_res.getName())
end
function i3k_sbean.equip_refine_save_res.handler(res,req)
	if res.ok > 0 then
		if req.pos == 0 then
			g_i3k_game_context:UpdateBagEquipProperty(req.id,req.guid,req.newProps)
		else
			g_i3k_game_context:UpdateWearEquipProperty(req.pos,req.newProps)
		end
		if req.isFree  then
			g_i3k_game_context:UpdateBagEquipFreeType(req.id,req.guid)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production,"updateEquipListSuo",req.id,req.guid)
		end
		local equipcfg =  g_i3k_db.i3k_db_get_equip_item_cfg(req.id)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production,"updateEquipProperty",req.newProps,equipcfg.levelReq)
	end
end
--请求炼化
function i3k_sbean.produce_fusion(consumeItems, remainPoints, needItemCnt)
	local data = i3k_sbean.produce_fusion_req.new()
	data.consumeItems = consumeItems
	data.remainPoints = remainPoints
	data.needItemCnt = needItemCnt
	i3k_game_send_str_cmd(data,i3k_sbean.produce_fusion_res.getName())
end

function i3k_sbean.produce_fusion_res.handler(bean, res)
	if bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("背包空间已满")
	elseif bean.ok > 0 then
		local consume_count = 0
		for k,v in pairs(res.consumeItems) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, AT_PRODUCE_FUSION)
			consume_count = consume_count + v.count
		end

		local recycledItemCnt = g_i3k_game_context:GetRecycledItemCnt()
		g_i3k_game_context:SetRecycledItemCnt(recycledItemCnt + consume_count)
		g_i3k_game_context:UseCommonItem(i3k_db_clan_recycle_base_info.recycle_need_itemId, res.needItemCnt, AT_PRODUCE_FUSION)  --消耗生产能量改为消耗道具

		local gainItems = bean.produces

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production, "playStoveFireAni", "fire")
		if next(gainItems) then
			local co = g_i3k_coroutine_mgr:StartCoroutine(function()
				g_i3k_coroutine_mgr.WaitForSeconds(1.2) --播完特效再弹奖励面板
				g_i3k_ui_mgr:ShowGainItemInfo(gainItems)
				g_i3k_coroutine_mgr:StopCoroutine(co)
				co = nil
			end)
		end
		g_i3k_game_context:SetRecycleRemainPoint(res.remainPoints)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production, "setTitleAttribute")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production,"setRecycleData")
	else
		g_i3k_ui_mgr:PopupTipMessage("炼化失败")
	end
end


--请求开启炼化功能
function i3k_sbean.produce_fusion_open(openType, itemTb)
	local data = i3k_sbean.produce_fusion_open_req.new()
	data.type = openType
	data.itemTb = itemTb
	i3k_game_send_str_cmd(data,i3k_sbean.produce_fusion_open_res.getName())
end

function i3k_sbean.produce_fusion_open_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetRecycleCanOpen(res.ok)
		if next(req.itemTb) then
			for k,v in pairs(req.itemTb) do
				g_i3k_game_context:UseCommonItem(v.id, v.count, AT_ACT_FUSION_FURNACE)
			end
		end
		g_i3k_ui_mgr:CloseUI(eUIID_RecycleOpen)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15503))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Production, "openRecycleFun")
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15504))
	end
end
