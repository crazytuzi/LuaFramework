-------------------------------------------------------
module(..., package.seeall)

local require = require;
local ui = require("ui/base");

-------------------------------------------------------
wnd_task = i3k_class("wnd_task", ui.wnd_base)
--任务类型

local LAYER_RWT = "ui/widgets/rwt"
local LAYER_ZXRWT ="ui/widgets/zxrwt"
local LAYER_SJWT = "ui/widgets/sjrwt1" --赏金任务任务条目

local _SELECT_PET_ICON = 706
local _AUTO_PET_ICON = 707
local PEACE_LINE = 1
local BATTLE_LINE = 2

function wnd_task:ctor()
	self._taskID = nil
	self._taskType = nil
	self._petid = {}
	self.subui = {}
	self._petID = nil
	self._main_point = nil
	self._main_mapID = nil
	self._weapon_point = nil
	self._weapon_mapID = nil
	self._pet_point = nil
	self._pet_mapID = nil
	self._subline_point = nil
	self._subline_mapID = nil

	self._allRoot = {}
	self._allBtn = {}
	self._btnState = 1
end

function wnd_task:configure(...)

	--主线按钮
	local main_btn = self._layout.vars.main_btn
	main_btn:onClick(self,self.onMainTask)
	main_btn:stateToPressed()
	--神兵按钮


	local weapon_btn = self._layout.vars.weapon_btn
	weapon_btn:onClick(self,self.onWeaponTask)
	self.item = self._layout.vars.item
	self.expCount = self._layout.vars.expCount
	--支线按钮
	local zhixian_btn = self._layout.vars.zhixian_btn
	zhixian_btn:onClick(self,self.onSubLineTask)
	--姻缘
	local mrg_btn = self._layout.vars.mrg_btn
	mrg_btn:onClick(self, self.onMrgTask)
	--赏金按钮
	local shangJinBtn = self._layout.vars.shangJinBtn
	shangJinBtn:onClick(self, self.onShangJinTask)
	self.mrgTrs_btn = self._layout.vars.mrgTrs_btn
	self.mrgGoBtn = self._layout.vars.mrgGoBtn

	self._layout.vars.abandonBtn:onClick(self, self.AbandonTask)
	self._layout.vars.zxAbandon:onClick(self, self.AbandonTask)
	self._layout.vars.zxTipBtn:onClick(self, self.FriendshipTips)

	self.go_btn = self._layout.vars.go_btn
	--self.go_btn:onClick(self,self.onGoBtn)

	self.mainTrs_btn = self._layout.vars.mainchs
	self.weaponTrs1_btn = self._layout.vars.weaponchs1
	self.weaponTrs2_btn = self._layout.vars.weaponchs2
	self.zhixianTrs_btn = self._layout.vars.petchs2

	self.mainTrs_btn:hide()
	self.weaponTrs1_btn:hide()
	self.weaponTrs2_btn:hide()
	self.zhixianTrs_btn:hide()

	self._layout.vars.close_btn:onClick(self,self.onCloseUI)

	local mrgRoot = self._layout.vars.mrgRoot
	local otherRoot = self._layout.vars.otherRoot
	local weaponRoot = self._layout.vars.weaponRoot
	local zhixianRoot = self._layout.vars.zhixianRoot
	local shangJinRoot = self._layout.vars.shangJinRoot

	self.task_tag_desc = self._layout.vars.task_tag_desc


	self._allRoot = {otherRoot = otherRoot,weaponRoot = weaponRoot,mrgRoot = mrgRoot,zhixianRoot = zhixianRoot, shangJinRoot = shangJinRoot}
	self._allBtn = {main_btn 	= main_btn,
					weapon_btn 	= weapon_btn,
					zhixian_btn = zhixian_btn, 
					mrg_btn 	= mrg_btn, 
					swords_btn 	= self._layout.vars.swordsmanBtn,
					shangJinBtn = shangJinBtn
					}
	self.scroll = self._layout.vars.scroll
	self.shangJinScroll = self._layout.vars.shangJinScroll

	self.taskPartName = self._layout.vars.taskPartName

	self.taskPartDesc = self._layout.vars.taskPartDesc
	self.taskName = self._layout.vars.taskName
	self.taskTagDesc = self._layout.vars.taskTagDesc
	self.needLevel = self._layout.vars.needLevel
	self.levelValue = self._layout.vars.levelValue
	self.item5Icon = self._layout.vars.item5Icon
	self.item5Count = self._layout.vars.item5Count
	self.item6Icon = self._layout.vars.item6Icon
	self.item6Count = self._layout.vars.item6Count
	self.item7Icon = self._layout.vars.item7Icon
	self.item7Count = self._layout.vars.item7Count

	self.item1Icon = self._layout.vars.item1Icon
	self.item1Count = self._layout.vars.item1Count
	self.item2Icon = self._layout.vars.item2Icon
	self.item2Count = self._layout.vars.item2Count
	self.item3Icon = self._layout.vars.item3Icon
	self.item3Count = self._layout.vars.item3Count
	self.item4Icon = self._layout.vars.item4Icon
	self.item4Count = self._layout.vars.item4Count

	self.item1Root = self._layout.vars.item1Root
	self.item2Root = self._layout.vars.item2Root
	self.item3Root = self._layout.vars.item3Root
	self.item4Root = self._layout.vars.item4Root

	self.loadingBarLabel = self._layout.vars.loadingBarLabel
	self.loadingBar = self._layout.vars.loadingBar

	self.taskName3 = self._layout.vars.taskName3
	self.taskTagDesc2 = self._layout.vars.taskTagDesc2

	self.go_btn3 = self._layout.vars.go_btn3
	self.weapon_btn_lable = self._layout.vars.weapon_btn_lable

	self.needLevel2 = self._layout.vars.needLevel2
	self.levelValue2 = self._layout.vars.levelValue2
	self.weaponTaskTag = self._layout.vars.weaponTaskTag
	self.tagRoot1 = self._layout.vars.tagRoot1
	self.tagRoot = self._layout.vars.tagRoot
	self.weaponTaskTag2 = self._layout.vars.weaponTaskTag2
	self.shenbing_module = self._layout.vars.shenbing_module

	self.itemName = self._layout.vars.itemName
	self.itemBg = self._layout.vars.itemBg
	self.itemIcon = self._layout.vars.itemIcon
	--self.get_label = self._layout.vars.get_label
	self.completedBtn = self._layout.vars.completedBtn
	self.completedDesc = self._layout.vars.completedDesc

	self.add_value = self._layout.vars.add_value
	self.tqNum = self._layout.vars.tqNum

	self.cur_level = self._layout.vars.cur_level
	self.loadingBar2 = self._layout.vars.loadingBar2

	self.taskName2 = self._layout.vars.taskName2
	self.petTaskDesc = self._layout.vars.petTaskDesc
	self.go_btn2 = self._layout.vars.go_btn2
	self.pet_task_lable = self._layout.vars.pet_task_lable

	self.pet_desc1 = self._layout.vars.pet_desc1
	self.pet_desc2 = self._layout.vars.pet_desc2

	self.item_bg = self._layout.vars.item_bg
	self.item_icon = self._layout.vars.item_icon
	self.item_name = self._layout.vars.item_name
	self.item_count = self._layout.vars.item_count

	self.pet_task_tag = self._layout.vars.pet_task_tag
	--self.get_label:hide()
	self._layout.vars.quick_des:setText(i3k_get_string(17503,g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_SHENBING).needActivity))
	--侠客按钮
	self._layout.vars.swordsmanBtn:onClick(self, self.onSwordsmanTask)
end

function wnd_task:AbandonTask(sender)
	if self._btnState == 1 then --主线
		local mId,mValue = g_i3k_game_context:getMainTaskIdAndVlaue()
		i3k_sbean.mtask_quit(mId)
	elseif self._btnState == 2 then --神兵
	elseif self._btnState == 4 then --支线
		local groupId = sender:getTag()
		local data = g_i3k_game_context:getSubLineIdAndValueBytype(groupId)
		if data.state == 1 then
			i3k_sbean.branch_task_quit(groupId, data.id)
		else
			g_i3k_ui_mgr:PopupTipMessage("该任务还未领取")
		end
	end
end

function wnd_task:FriendshipTips(sender)
	if self._btnState == 1 then --主线
		local mId = g_i3k_game_context:getMainTaskIdAndVlaue()
		local cfg = g_i3k_db.i3k_db_get_main_task_cfg(mId)
		g_i3k_ui_mgr:PopupTipMessage(cfg.taskTips)
	elseif self._btnState == 2 then
	end
end

function wnd_task:transferToPoint(sender,needValue)
	local hero = i3k_game_get_player_hero()
	if hero then
		local isFight = hero:IsInFightTime()
		local isEscort = g_i3k_game_context:GetTransportState()
		if isFight and isEscort==1 then
			g_i3k_ui_mgr:PopupTipMessage("运镖且战斗状态下不能传送")
			return;
		end
	end
	local mapId = needValue.mapId
	local areaId = needValue.areaId
	local needId = i3k_db_common.activity.transNeedItemId
	local itemCount = g_i3k_game_context:GetBagMiscellaneousCanUseCount(needId)
	local needName = g_i3k_db.i3k_db_get_common_item_name(needId)
	-- if itemCount<1 then
	if not g_i3k_game_context:CheckCanTrans(needId, 1) then
		local tips = string.format("%s", "所需物品数量不足,请步行前往")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	else
		if g_i3k_game_context:IsTransNeedItem() then
			local descText = i3k_get_string(1491,needName, 1)
			local func1 = function(isOk) 
				if isOk then
					g_i3k_game_context:TransportCallBack(mapId, areaId, needValue.flage)
					g_i3k_ui_mgr:CloseUI(eUIID_Task)
				end
			end
			local fun2 = function()
				g_i3k_ui_mgr:ShowMessageBox2(descText, func1)
			end
			if g_i3k_game_context:CheckMulHorse(fun2,true) then
			else
				fun2()
			end
			
		else
			local func = function()
				g_i3k_game_context:TransportCallBack(mapId, areaId, needValue.flage)
			end
			g_i3k_game_context:CheckMulHorse(func,true)
			g_i3k_ui_mgr:CloseUI(eUIID_Task)
		end
	end
end

function wnd_task:onGotoTaskPosition(sender, args)
	g_i3k_game_context:GoingToDoTask(args.type , args.cfg, args.otherId)
	g_i3k_ui_mgr:CloseUI(eUIID_Task)
end

function wnd_task:onGotoMrgTaskPosition(sender)

end

function wnd_task:onGotoweaponTaskPosition(sender)
	if self._weapon_point then
		if self._weaponTransData then
			local isCan = g_i3k_game_context:doTransport(self._weaponTransData)
			if not isCan then
				g_i3k_game_context:SeachPathWithMap(self._weapon_mapID,self._weapon_point,TASK_CATEGORY_WEAPON,nil,self._weaponTransData)
			end
		else
			g_i3k_game_context:SeachPathWithMap(self._weapon_mapID,self._weapon_point,TASK_CATEGORY_WEAPON)
		end
--		g_i3k_game_context:SeachBestPathWithMap(self._weapon_mapID,self._weapon_point,TASK_CATEGORY_WEAPON)
	end
	g_i3k_logic:OpenBattleUI()
	g_i3k_ui_mgr:CloseUI(eUIID_Task)
end

function wnd_task:onGotoSuicongTaskPosition(sender)
	if g_i3k_game_context:GetDailyCompleteTask() == i3k_db_common.petBackfit.petTaskMax then
		g_i3k_ui_mgr:PopupTipMessage("今日的宠物喂养次数已用尽")
		return
	end
	local taskType = sender:getTag()
	if taskType == g_TASK_GET_TO_FUBEN then
		g_i3k_logic:OpenDungeonUI(false,self._pet_mapID)
	else
		if self._pet_point then
			g_i3k_game_context:SetAutoFight(false)
--			g_i3k_game_context:SeachBestPathWithMap(self._pet_mapID,self._pet_point,TASK_CATEGORY_PET,self._petID)
			g_i3k_game_context:SeachPathWithMap(self._pet_mapID,self._pet_point,TASK_CATEGORY_PET,self._petID,self.petTransferData)
		end
		g_i3k_logic:OpenBattleUI()
	end
	g_i3k_ui_mgr:CloseUI(eUIID_Task)
end

function wnd_task:onGotoSubLineTaskPosition(sender,groupId)
	local data = g_i3k_game_context:getSubLineIdAndValueBytype(groupId)
	local id = data.id
	local cfg = g_i3k_db.i3k_db_get_subline_task_cfg(groupId,id)
	if not cfg then
		g_i3k_ui_mgr:CloseUI(eUIID_Task)
		return
	end
	if cfg.conditionType == 1 and g_i3k_game_context:GetLevel() < cfg.conditionValue then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16861,cfg.conditionValue))
	end
	local taskType = cfg.type
	if data.state == 0 then
		if g_i3k_game_context:CheckTransformationTaskState(cfg.effectIdList) and not g_i3k_game_context:IsInMetamorphosisMode() then
			g_i3k_ui_mgr:PopupTipMessage("请先完成当前变身任务")
			return
		end
		local npcID = cfg.getTaskNpcID
		if npcID == 0 then
			g_i3k_game_context:GetSubLineTaskDialogue(groupId,id)
		else
			local point = self:getRandomPos(npcID)
			g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(npcID), point, TASK_CATEGORY_SUBLINE,groupId,self.subtaskTransData)
		end
		--g_i3k_logic:OpenBattleUI()
	elseif data.state >= 1 then
		if taskType == g_TASK_GET_TO_FUBEN then
			g_i3k_logic:OpenDungeonUI(false,self._subline_mapID)
		elseif taskType == g_TASK_CLEARANCE_ACTIVITYPAD then
			g_i3k_logic:OpenShiLianUI()
		elseif taskType == g_TASK_PERSONAL_ARENA then
			g_i3k_logic:OpenArenaUI()
		elseif taskType == g_TASK_JOIN_FACTION then
			g_i3k_logic:OpenFactionUI()
		else
			if self._subline_point then
				g_i3k_game_context:SeachPathWithMap(self._subline_mapID,self._subline_point,TASK_CATEGORY_SUBLINE,groupId,self.subtaskTransData)
			end
			--g_i3k_logic:OpenBattleUI()
		end
	end
	g_i3k_ui_mgr:CloseUI(eUIID_Task)
end

function wnd_task:onShow()

end

function wnd_task:allRootHide()
	for k,v in pairs(self._allRoot) do
		v:hide()
	end
end

function wnd_task:rootShow(sroot)
	self:allRootHide()--更新是否可以点击
	self._allRoot[sroot]:show()
end

function wnd_task:allBtnNormal()
	for k,v in pairs(self._allBtn) do
		v:stateToNormal(true)
	end
end

function wnd_task:btnToPressed(btn)
	self:allBtnNormal()--更新按下状态
	self._allBtn[btn]:stateToPressed(true)
end

function wnd_task:onMainTask(sender)
	if g_i3k_game_context:GetIsGlodCoast() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
		return 
	end
	if self._btnState ~= 1 then
		self:rootShow("otherRoot")
		self:btnToPressed("main_btn")
		self:updateMainTaskData()
		self._btnState = 1
	end
end

function wnd_task:onWeaponTask(sender)
	if g_i3k_game_context:GetIsGlodCoast() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
		return 
	end
	if self._btnState ~= 2 then

		local dayLoopCount = g_i3k_game_context:getWeaponDayLoopCount()
		if i3k_db_common.weapontask.Ctasktimes <= dayLoopCount then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(207))
			return
		end
		self._btnState = 2
		self:rootShow("weaponRoot")
		self:btnToPressed("weapon_btn")
		self:updateWeaponData()
	end
end

function wnd_task:onSubLineTask(sender)
	if g_i3k_game_context:GetIsGlodCoast() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
		return 
	end
	if self._btnState ~= 4 then
		local data = g_i3k_game_context:getSubLineTask()
		local count = 0
		for k,v in pairs(data) do
			if v.id ~= 0 then
				if v.state == 0 and i3k_db_subline_task[k][v.id].isHide == 1 then
				else
				count = count+1
				end
			end
		end
		if count == 0 then
			g_i3k_ui_mgr:PopupTipMessage("当前没有支线任务")
		else
			self._btnState = 4
			self:rootShow("zhixianRoot")
			self:btnToPressed("zhixian_btn")
			self:updateSubLineScroll()
		end
	end
end

function wnd_task:onMrgTask(sender)
	if g_i3k_game_context:GetIsGlodCoast() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
		return 
	end
	if self._btnState ~= 5 then
		local data = g_i3k_game_context:GetMarriageTaskData()
		if data.open == 0 and g_i3k_game_context:getMarryRoleId() > 0 then
			self:openMrgUI()
		elseif data.id <= 0 then
			g_i3k_ui_mgr:PopupTipMessage("当前没有姻缘任务")
		else
			self:openMrgUI()
		end
	end
end
--赏金任务页签按钮
function wnd_task:onShangJinTask(sender)
	if self._btnState ~= 6 then
		local data = g_i3k_game_context:GetGlobalWorldTaskSortData()
		if next(data) then
			self:updateShangJinTaskData()
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5599))
		end
	end
end
--更新赏金任务内容
function wnd_task:updateShangJinTaskData( ... )
	self._btnState = 6
	self:rootShow("shangJinRoot")
	self:btnToPressed("shangJinBtn")
	self.shangJinScroll:removeAllChildren()
	local data = g_i3k_game_context:GetGlobalWorldTaskSortData()
	for k,v in ipairs(data) do
		local item = require(LAYER_SJWT)()
		local cfg = i3k_db_war_zone_map_task[v.id]
		item.vars.taskTitle:setText(cfg.taskName) 
		item.vars.taskIcon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.taskIcon))
		local roleLevel = g_i3k_game_context:GetLevel()
		--任务状态
		local isComplete = v.taskStatus == g_GLOBAL_WORLD_TASK_COMPLETE		--已完成
		if isComplete then
			item.vars.goBtn:disableWithChildren()
			item.vars.goLabel:setText("已完成")
		end
		local canTake = v.isReward == g_GLOBAL_WORLD_TASK_CANTAKE and isComplete		--可领取
		item.vars.complete:setVisible(canTake)
		item.vars.take:setVisible(canTake)
		if canTake then
			item.vars.take:onClick(self, self.onTakeBtnClick, v.id)
		end
		if cfg.isLuanDou == g_GOLD_COAST_PEACE then
			item.vars.root:setImage(g_i3k_db.i3k_db_get_icon_path(103))
			item.vars.taskTitle:setTextColor(g_i3k_get_blue_color())
			item.vars.isLuanDou:setText(i3k_get_string(5578))--和平分线专属任务
		else
			item.vars.root:setImage(g_i3k_db.i3k_db_get_icon_path(104))
			item.vars.taskTitle:setTextColor(g_i3k_get_purple_color())
			item.vars.isLuanDou:setText(i3k_get_string(5579))--乱斗分线专属任务
		end
		--任务前往
		--local mapID = isLuanDou and i3k_db_war_zone_map_type[BATTLE_LINE].mapID or i3k_db_war_zone_map_type[PEACE_LINE].mapID
		item.vars.goBtn:onClick(self, self.onGoBtnClick, {type = TASK_CATEGORY_GLOBALWORLD, cfg = cfg, id = v.id})
		--任务内容
		local isFinish = canTake or isComplete
		item.vars.taskName:setText(g_i3k_db.i3k_db_get_task_desc(cfg.type, cfg.arg1, cfg.arg2, v.curValue, isFinish, nil, false))
		--任务奖励
		local exp = i3k_db_exp[roleLevel].globalWorldTask * cfg.expNomalValue
		item.vars.count1:setText("x"..i3k_get_num_to_show(exp))
		self:setSJTaskRewardData(item.vars, 2, v.id, v.awardCount1)
		self:setSJTaskRewardData(item.vars, 3, v.id, v.awardCount2)
		self.shangJinScroll:addItem(item)
	end
	self.taskPartName:setText(i3k_get_string(5602))
end
function wnd_task:onTakeBtnClick(sender, id)
	g_i3k_ui_mgr:OpenUI(eUIID_GlobalWorldTaskTake)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_GlobalWorldTaskTake,"updateRewardData", id)
end
function wnd_task:onGoBtnClick(sender, args)
	local monsterMapId = g_i3k_db.i3k_db_GlobalWorldTask_GetTarget_MapID(args.cfg)
	--根据自己的位置做提示
	local mapType = i3k_game_get_map_type()
	if mapType == g_FIELD then 				--在大地图中	
		if i3k_db_war_zone_map_fb[monsterMapId] then
			g_i3k_logic:OpenEnterWarZone()
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5581))
			return
		end
	elseif mapType == g_GOLD_COAST then 	--在黄金海岸中
		if monsterMapId ~= g_i3k_game_context:GetWorldMapID() then
			if i3k_db_war_zone_map_fb[monsterMapId] then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5600))
				return
			else	
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5601))
				return
			end
		end
	end
	g_i3k_game_context:GoingToDoTask(TASK_CATEGORY_GLOBALWORLD, args.cfg, args.id)
	g_i3k_ui_mgr:CloseUI(eUIID_Task)
	--g_i3k_game_context:IntoWarZone(mapID)
end
--设置赏金任务奖励内容
function wnd_task:setSJTaskRewardData(widget, itemIndex, taskId, itemCount)
	local cfg = i3k_db_war_zone_map_task[taskId]
	local root = "image"..itemIndex
	local icon = "icon"..itemIndex
	local count = "count"..itemIndex
	local suo = "lock"..itemIndex
	local tip = "tips"..itemIndex
	if id ~= 0 then
		local index = itemIndex - 1
		widget[root]:show()
		--local comCfg = g_i3k_db.i3k_db_get_common_item_cfg(task.itemId2)
		--local grade = comCfg.rank
		--widget[icon]:setImage(g_i3k_get_icon_frame_path_by_rank(grade))
		local rtype = g_i3k_game_context:GetRoleType()
		local tmp_item = string.format("awardIds%s",index)
		local itemid = cfg[tmp_item][rtype]
		local itemCount = cfg["awardCount"..index]
		widget[icon]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid, i3k_game_context:IsFemaleRole()))
		widget[root]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
		widget[count]:setText("x"..itemCount)
		widget[suo]:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(itemid))
		widget[tip]:onTouchEvent(self, self.onTips,{id = itemid, close = false})
	else
		widget[root]:hide()
	end
end

function wnd_task:onGoBtn(sender, args)
	local main_cfg = args.cfg
	if args.category == TASK_CATEGORY_MAIN then
		if main_cfg.nextid == 0 and g_i3k_game_context:GetTransformBWtype() == 0 then
			return g_i3k_ui_mgr:PopupTipMessage("完成二转任务才能领取奖励")
		end
	end
	local npcID = main_cfg.finishTaskNpcID
	if npcID == 0 then
		g_i3k_game_context:OpenFinishTaskDialogue(main_cfg, args.category)
	else
		local point = self:getRandomPos(npcID)
		g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(npcID), point, args.category,nil,self.mainTransfer)
	end

	g_i3k_ui_mgr:CloseUI(eUIID_Task)
end

--[[function wnd_task:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Task)
end--]]

function wnd_task:updateMainTaskData(id,taskType)
	self._btnState = 1
	self.scrollIndex = nil
	self:rootShow("otherRoot")
	self:btnToPressed("main_btn")
	self.mainTrs_btn:hide()

	local mId,mValue,state = g_i3k_game_context:getMainTaskIdAndVlaue()
	local value = 0
	if not id or not taskType then
		id = mId
		value = mValue
		self._taskID = id
	else
		value = mValue
	end
	local main_cfg = g_i3k_db.i3k_db_get_main_task_cfg(id)
	local desc = main_cfg.getTaskDesc
	local arg1 = main_cfg.arg1
	local arg2 = main_cfg.arg2
	local arg3 = main_cfg.arg3
	local arg4 = main_cfg.arg4
	local arg5 = main_cfg.arg5
	local tm_task_type = main_cfg.type
	local NPCID = main_cfg.finishTaskNpcID
	local imgID = main_cfg.imgPathID
	local is_ok = g_i3k_game_context:IsTaskFinished(tm_task_type,arg1,arg2,value)
	is_ok = g_i3k_game_context:TaskItemIsEnough(tm_task_type, is_ok, arg1, arg2)

	local specailDesc = g_i3k_db.i3k_db_get_task_specialized_desc(main_cfg,is_ok)
	local tmp_desc = is_ok and g_i3k_db.i3k_db_get_task_finish_reward_desc(main_cfg) or g_i3k_db.i3k_db_get_task_desc(tm_task_type,arg1,arg2,value, is_ok,specailDesc)
	if imgID>0 then
		self._layout.vars.dtImg:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
	end
	if main_cfg.abandonTask == 0 or state == 0 then
		self._layout.vars.abandonBtn:hide()
	end
	if main_cfg.taskTips == "0.0" then
		self._layout.vars.zxTipBtn:hide()
	end
	self.mainTransfer = nil
	if state >= 1 and is_ok then
		if self._main_mapID and self._main_point then
			local needValue = {flage = 3, mapId = self._main_mapID, areaId = arg1, pos = self._main_point}
			self.mainTransfer = needValue
			self.mainTrs_btn:show()
			self.mainTrs_btn:onClick(self,self.transferToPoint,needValue)
		else
			if NPCID ~= 0 then
				--寻径Npc交任务
				local point = g_i3k_db.i3k_db_get_npc_pos(NPCID);
				local mapID = g_i3k_db.i3k_db_get_npc_map_id(NPCID);
				point = self:getRandomPos(NPCID)
				local needValue = {flage = 1, mapId = mapID, areaId = NPCID, pos = point}
				self.mainTransfer = needValue
				self.mainTrs_btn:show()
				self.mainTrs_btn:onClick(self,self.transferToPoint,needValue)
			end
		end
		self.go_btn:onClick(self,self.onGoBtn,{cfg = main_cfg, category = TASK_CATEGORY_MAIN})
	elseif state >= 1 then
		local needValue = nil
		self.go_btn:onClick(self,self.onGotoTaskPosition, {type =  TASK_CATEGORY_MAIN, cfg = main_cfg})
		if tm_task_type == g_TASK_KILL then
			self.mainTrs_btn:show()
			--local tmp_data,_tmp_data = g_i3k_game_context:getCacheSpawnNpcResourData()
			local isNormal = true
			self._main_point, self._main_mapID, isNormal = g_i3k_db.i3k_db_checkMainTaskKillTarget(main_cfg)
			if isNormal then
				needValue = {flage = 3, mapId = self._main_mapID, areaId = arg1, pos = self._main_point}
			end
		elseif tm_task_type == g_TASK_COLLECT then
			self.mainTrs_btn:show()
			--local tmp_data ,_tmp_data= g_i3k_game_context:getCacheSpawnNpcResourData()
			self._main_point = g_i3k_db.i3k_db_get_res_pos(main_cfg.arg1)
			self._main_mapID = g_i3k_db.i3k_db_get_res_map_id(main_cfg.arg1)
			needValue = {flage = 2, mapId = self._main_mapID, areaId = arg1, pos = self._main_point}
		elseif tm_task_type == g_TASK_USE_ITEM_AT_POINT then
			local pos = {x=arg3,y=arg4,z=arg5}
			self._main_point = pos
			self._main_mapID = arg2
		elseif tm_task_type == g_TASK_NEW_NPC_DIALOGUE then
			self.mainTrs_btn:show()
			--local tmp_data ,_tmp_data= g_i3k_game_context:getCacheSpawnNpcResourData()
			self._main_point = g_i3k_db.i3k_db_get_npc_pos(arg1);
			self._main_mapID = g_i3k_db.i3k_db_get_npc_map_id(arg1);
			self._main_point = self:getRandomPos(arg1)
			needValue = {flage = 1, mapId = self._main_mapID, areaId = arg1, pos = self._main_point}
		elseif tm_task_type == g_TASK_GET_TO_FUBEN then
			self._main_mapID = arg1
			self.go_btn:show()
		elseif tm_task_type ==	g_TASK_CLEARANCE_ACTIVITYPAD then --通关活动本
			self._main_mapID = arg1
			self.go_btn:show()
		elseif tm_task_type ==	g_TASK_PERSONAL_ARENA  then	--参与个人竞技场
			self.go_btn:show()
		elseif tm_task_type == 	g_TASK_SHAPESHIFTING then	--护送NPC
			self.go_btn:show()
			local pos = {x=arg4,y=arg5,z=arg6}
			self._main_point = pos
			self._main_mapID = arg3
		elseif tm_task_type == g_TASK_CONVOY then--运送物件
			self.go_btn:show()
			local pos = {x=arg3,y=arg4,z=arg5}
			self._main_point = pos
			self._main_mapID = arg2
		elseif tm_task_type == g_TASK_ANSWER_PROBLEME then --回答问题
			self.go_btn:show()
			self._main_point = g_i3k_db.i3k_db_get_npc_pos(arg1);
			self._main_mapID = g_i3k_db.i3k_db_get_npc_map_id(arg1);
		elseif tm_task_type == g_TASK_USE_ITEM then
			self.go_btn:hide()
		elseif tm_task_type == g_TASK_ANY_MOMENT_DUNGEON then--通关随时副本
			self.go_btn:show()
			local pos = i3k_db_at_any_moment[arg1].position
			self._main_point = {x = pos[1], y = pos[2],z = pos[3]}
			self._main_mapID = i3k_db_at_any_moment[arg1].mapId
		end
		self.mainTransfer = needValue
		if needValue then
			self.mainTrs_btn:onClick(self,self.transferToPoint,needValue)
		else
			self.mainTrs_btn:hide()
		end
	else
		self.go_btn:hide()
	end
	self.needLevel:setText("需要等级")
	self.item5Icon:hide()
	self.item5Count:hide()
	self.item6Icon:hide()
	self.item6Count:hide()

	self.item1Root:hide()
	self.item2Root:hide()
	self.item3Root:hide()
	self.item4Root:hide()
	-------------------------数据-----------------------------
	local main_cfg = g_i3k_db.i3k_db_get_main_task_cfg(id)
	local partName = main_cfg.sectionName
	local partDesc =  main_cfg.sectionDesc
	local _taskName = main_cfg.name
	local taskDesc = main_cfg.taskDesc
	local taskType = main_cfg.type
	if taskType ~= 5 then
		self.needLevel :hide()
		self.levelValue:hide()
	else
		self.levelValue:setText(main_cfg.arg1)
		self.needLevel:show()
		self.levelValue:show()
	end
	self.item7Icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_EXP,i3k_game_context:IsFemaleRole()))
	self.item7Count:setText(main_cfg.awardExp)
	local item_t = {}
	local item_count = 0
	local my_type = g_i3k_game_context:GetRoleType()
	for i=1,4 do
		local tmp_item = string.format("awardItem%s",i)
		local awardItem = main_cfg[tmp_item]
		local itemid = awardItem[my_type]
		if itemid and itemid ~= 0 then
			local tmp_count = string.format("awardItem%sCount",i)
			local awardItemCount = main_cfg[tmp_count]
			local t = {}
			t.itemid = itemid
			t.count = awardItemCount
			table.insert(item_t,t)
		end
	end

	local vars = self._layout.vars
	local prestr
	for k, v in ipairs(item_t) do
		if v.itemid == g_BASE_ITEM_DIAMOND then
			self.item5Icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemid,i3k_game_context:IsFemaleRole()))
			self.item5Count:setText(v.count)
			self.item5Icon:show()
			self.item5Count:show()
		elseif v.itemid == g_BASE_ITEM_COIN then
			self.item6Icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemid,i3k_game_context:IsFemaleRole()))
			self.item6Count:setText(v.count)
			self.item6Icon:show()
			self.item6Count:show()
		else
			item_count = item_count + 1
			if item_count > 4 then
				break
			end
			prestr = "item"..item_count

			self[prestr.."Icon"]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemid,i3k_game_context:IsFemaleRole()))
			self[prestr.."Count"]:setText(v.count)
			self[prestr.."Root"]:show()
			self[prestr.."Root"]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.itemid))
			self[prestr.."Icon"]:onTouchEvent(self,self.onTips,{id = v.itemid, close = false})
			vars["zhusuo"..item_count]:setVisible(v.itemid > 0)
		end
	end
	if self.mainTrs_btn:isVisible() then
		tmp_desc = string.format("%s  <c=green><u>传送</u></c>",tmp_desc)
	end
	self.task_tag_desc:setText(tmp_desc)
	self.taskPartName:setText(partName)
	self.taskPartDesc:setText(partDesc)
	self.taskName:setText(_taskName)
	self.taskTagDesc:setText(taskDesc)
	local count = main_cfg.index
	local total = main_cfg.total
	local tmp_str = string.format("完成进度%s/%s",count,total)
	self.loadingBarLabel:setText(tmp_str)
	self.loadingBar:setPercent(math.modf(count/total*100))
end

function wnd_task:openMrgUI()
	local data = g_i3k_game_context:GetMarriageTaskData()
	self._btnState = 5
	self:rootShow("mrgRoot")
	self._layout.vars.mrg_red:hide()
	if data.open > 0 then
		self._layout.vars.mrgOpenRoot:hide()
		self._layout.vars.mrgTaskRoot:show()
		self:updateMrgData()
	else
		self._layout.vars.mrgOpenRoot:show()
		self._layout.vars.mrgTaskRoot:hide()
		self:updateNotOpenMrgData()
	end
end

function wnd_task:onGotoMrgTaskNpc(sender)
	g_i3k_game_context:GotoOpenMrgTaskNpc()
	g_i3k_ui_mgr:CloseUI(eUIID_Task)
end

function wnd_task:updateNotOpenMrgData()
	self:btnToPressed("mrg_btn")
	self.taskPartName:setText("姻缘任务")
	local npcID = i3k_db_marryTaskCfg.openTasnNpc
	local pos  = g_i3k_db.i3k_db_get_npc_pos(npcID)
	local mapId = g_i3k_db.i3k_db_get_npc_map_id(npcID)
	self._layout.vars.go_btn2:onClick(self,self.onGotoMrgTaskNpc)
end

function wnd_task:updateMrgData( )
	self._btnState = 5
	self.scrollIndex = nil

	self:btnToPressed("mrg_btn")
	self._layout.vars.mrgAbandonBtn:hide()
	self._layout.vars.mrgTrs_btn:hide()
	self.taskPartName:setText("姻缘任务")

	local data = g_i3k_game_context:GetMarriageTaskData()

	local main_cfg = g_i3k_db.i3k_db_marry_task(data.id, data.groupID)
	local desc = main_cfg.getTaskDesc
	local arg1 = main_cfg.arg1
	local arg2 = main_cfg.arg2
	local arg3 = main_cfg.arg3
	local arg4 = main_cfg.arg4
	local arg5 = main_cfg.arg5

	local value = data.value
	local state = data.state

	local tm_task_type = main_cfg.type
	local NPCID = main_cfg.finishTaskNpcID
	local is_ok = g_i3k_game_context:IsTaskFinished(tm_task_type,arg1,arg2, value)
	is_ok = g_i3k_game_context:TaskItemIsEnough(main_cfg.type, is_ok, arg1, arg2)

	local specailDesc = g_i3k_db.i3k_db_get_task_specialized_desc(main_cfg,is_ok)
	local tmp_desc = is_ok and g_i3k_db.i3k_db_get_task_finish_reward_desc(main_cfg) or g_i3k_db.i3k_db_get_task_desc(tm_task_type,arg1,arg2,value, is_ok,specailDesc)

	local ui = self._layout.vars
	ui.mrgItemP:hide()
	ui.mrgTalkP:show()
	self.mainTransfer = nil
	if state >= 1 and is_ok then
		if NPCID ~= 0 then
			--寻径Npc交任务
			local point = g_i3k_db.i3k_db_get_npc_pos(NPCID);
			local mapID = g_i3k_db.i3k_db_get_npc_map_id(NPCID);
			point = self:getRandomPos(NPCID)
			local needValue = {flage = 1, mapId = mapID, areaId = NPCID, pos = point}
			self.mainTransfer = needValue
			self.mrgTrs_btn:show()
			self.mrgTrs_btn:onClick(self,self.transferToPoint,needValue)
		end
		self.mrgGoBtn:onClick(self,self.onGoBtn, {cfg = main_cfg, category = i3k_get_MrgTaskCategory()})
	elseif state >= 1 then
		local needValue = nil
		self.mrgGoBtn:onClick(self,self.onGotoTaskPosition, {type = i3k_get_MrgTaskCategory(), cfg = main_cfg, otherId = data.groupID})
		if tm_task_type == g_TASK_KILL then
			self.mrgTrs_btn:show()
			local isNormal = true
			self._main_point, self._main_mapID, isNormal = g_i3k_db.i3k_db_checkMainTaskKillTarget(main_cfg)
			if isNormal then
				needValue = {flage = 3, mapId = self._main_mapID, areaId = arg1, pos = self._main_point}
			end
		elseif tm_task_type == g_TASK_COLLECT then
			self.mrgTrs_btn:show()
			self._main_point = g_i3k_db.i3k_db_get_res_pos(main_cfg.arg1)
			self._main_mapID = g_i3k_db.i3k_db_get_res_map_id(main_cfg.arg1)
			needValue = {flage = 2, mapId = self._main_mapID, areaId = arg1, pos = self._main_point}
		elseif tm_task_type == g_TASK_USE_ITEM_AT_POINT then
			local pos = {x=arg3,y=arg4,z=arg5}
			self._main_point = pos
			self._main_mapID = arg2
		elseif tm_task_type == g_TASK_NEW_NPC_DIALOGUE then
			self.mrgTrs_btn:show()
			self._main_point = g_i3k_db.i3k_db_get_npc_pos(arg1);
			self._main_mapID = g_i3k_db.i3k_db_get_npc_map_id(arg1);
			self._main_point = self:getRandomPos(arg1)
			needValue = {flage = 1, mapId = self._main_mapID, areaId = arg1, pos = self._main_point}
		elseif tm_task_type == g_TASK_GET_TO_FUBEN then
			self._main_mapID = arg1
			self.mrgGoBtn:show()
		elseif tm_task_type == g_TASK_USE_ITEM then
			ui.mrgItemP:show()
			ui.mrgTalkP:hide()

			ui.mrgTFrame:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(arg1))
			ui.mrgTIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(arg1,i3k_game_context:IsFemaleRole()))
			ui.mrgTItemName:setText(g_i3k_db.i3k_db_get_common_item_name(arg1))
			ui.mrgTItemName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(arg1)))
			local have_count = g_i3k_game_context:GetCommonItemCanUseCount(arg1)
			local tmp_str
			if have_count >= arg2 then
				self.mrgGoBtn:show()
				tmp_str = string.format("<c=green>%s/%s</c>",have_count,arg2)
			else
				tmp_str = string.format("<c=red>%s/%s</c>",have_count,arg2)
				self.mrgGoBtn:hide()
			end
			ui.mrgTNum:setText(tmp_str)
			ui.mrgTFrame:onTouchEvent(self,self.onTips,{id = arg1, close = true})
		elseif tm_task_type ==	g_TASK_CLEARANCE_ACTIVITYPAD then --通关活动本
			self._main_mapID = arg1
			self.mrgGoBtn:show()
		elseif tm_task_type ==	g_TASK_PERSONAL_ARENA  then	--参与个人竞技场
			self.mrgGoBtn:show()
		elseif tm_task_type == 	g_TASK_SHAPESHIFTING then	--护送NPC
			self.mrgGoBtn:show()
			local pos = {x=arg4,y=arg5,z=arg6}
			self._main_point = pos
			self._main_mapID = arg3
		elseif tm_task_type == g_TASK_CONVOY then--运送物件
			self.mrgGoBtn:show()
			local pos = {x=arg3,y=arg4,z=arg5}
			self._main_point = pos
			self._main_mapID = arg2
		elseif tm_task_type == g_TASK_ANSWER_PROBLEME then --回答问题
			self.mrgGoBtn:show()
			self._main_point = g_i3k_db.i3k_db_get_npc_pos(arg1);
			self._main_mapID = g_i3k_db.i3k_db_get_npc_map_id(arg1);
		end
		self.mainTransfer = needValue
		if needValue then
			self.mrgTrs_btn:onClick(self,self.transferToPoint,needValue)
		else
			self.mrgTrs_btn:hide()
		end
	else
		self.mrgGoBtn:hide()
	end

	-------------------------数据-----------------------------
	local _taskName = main_cfg.name
	local taskDesc = main_cfg.taskDesc
	local taskType = main_cfg.type

	-- self.item7Icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_EXP,i3k_game_context:IsFemaleRole()))
	-- self.item7Count:setText(main_cfg.awardExp)
	local item_t = g_i3k_game_context:getMrgTaskAward(main_cfg)

	local index = 1
	for k, v in pairs(item_t) do
		local r = string.format("mrgItem%d",index)

		ui[r]:show()
		ui[r]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(k))
		ui[r.."Icon"]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(k,i3k_game_context:IsFemaleRole()))
		ui[r.."Num"]:setText(v)
		ui[r.."Icon"]:onTouchEvent(self,self.onTips,{id = k, close = false})
		ui[r.."Name"]:setText(g_i3k_db.i3k_db_get_common_item_name(k))
		ui["ynsuo"..index]:setVisible(k > 0)
		index = index + 1
	end
	if self.mrgTrs_btn:isVisible() then
		tmp_desc = string.format("%s  <c=green><u>传送</u></c>",tmp_desc)
	end

	ui.mrgTdesc:setText(tmp_desc)
	ui.mrgTaskDesc:setText(taskDesc)
	ui.mrgTaskName:setText(_taskName)

	ui.mrgValue:setText(string.format("姻缘值：%d", main_cfg.lovers))
	--ui.mrgGod:setText("x".. main_cfg.addGold)
	local ratio = 0
	if data.groupID ~= 0 then
		ratio = i3k_db_marry_seriesTask[data.groupID][data.id].awardExp
	else
		ratio = i3k_db_marry_loopTask[data.id].awardExp
	end
	local exp = i3k_db_exp[g_i3k_game_context:GetLevel()].mrgTaskExp
	ui.expIcon:setVisible(true)
	ui.mrgExp:setText(string.format( exp * ratio))
	local count = main_cfg.index
	local total = main_cfg.total
	local cnt = 0
	if data.groupID ~= 0 then
		cnt = #i3k_db_marry_seriesTask[data.groupID]
	else
		cnt = i3k_db_marryTaskCfg.loopTaskCnt
	end
	--local tmp_str = string.format("%d/%d",main_cfg.id,cnt)
	--ui.mrgPrecent:setText(tmp_str)
	--ui.loadingBar3:setPercent(math.modf(main_cfg.id/cnt*100))
end

function wnd_task:updateWeaponData(id,taskType)
	self._btnState = 2
	self.scrollIndex = nil
	self:rootShow("weaponRoot")
	self:btnToPressed("weapon_btn")

	self.weaponTrs1_btn:hide()
	self.weaponTrs2_btn:hide()
	local value1,value2 = g_i3k_game_context:getWeaponTaskArgsCountAndArgs()
	local values = {value1,value2}
	local id ,loop = g_i3k_game_context:getWeaponTaskIdAndLoopType()
	self.taskPartName:setText("神兵任务")
	self.needLevel2:hide()
	self.levelValue2:hide()
	local weapon_cfg = g_i3k_db.i3k_db_get_weapon_task_cfg(id,loop)
	local weaponId	 = weapon_cfg.weaponId
	self:SetModule(weaponId)
	local name = weapon_cfg.name
	local desc = weapon_cfg.getTaskDesc

	local type1 = weapon_cfg.type1
	local arg11 = weapon_cfg.arg11
	local arg12 = weapon_cfg.arg12
	local type2 = weapon_cfg.type2
	local arg21 = weapon_cfg.arg21
	local arg22 = weapon_cfg.arg22

	local itemid = weapon_cfg.awardItemid
	local itemCount = weapon_cfg.awardItemCount
	local item_name = g_i3k_db.i3k_db_get_common_item_name(itemid)
	self.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
	self.itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	self._layout.vars.sbsuo:setVisible(itemid > 0)
	local tmp_str = string.format("%s×%s",item_name,itemCount)
	self.itemName:setText(tmp_str)
	self.itemName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
	self.taskName3:setText(name)
	self.taskTagDesc2:setText(desc)
	self.weapon_btn_lable:setText("立即前往")
	self.itemIcon:onTouchEvent(self,self.onTips,{id = itemid, close = false})
--	self.go_btn3:onClick(self,self.onWeaponTaskGo)
	self.go_btn3:onClick(self,self.onGotoweaponTaskPosition)
	local needValue = nil
	self._weaponTransData = nil

	local quick_item = self._layout.vars.quick_item
	local quick_item_suo = self._layout.vars.quick_item_suo
	local quick_item_count = self._layout.vars.quick_item_count
	local quick_btn = self._layout.vars.quick_btn
	local cfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_SHENBING)
	if g_i3k_game_context:isCanQuickFinishTask(g_QUICK_FINISH_TASK_TYPE_SHENBING, id) then
		quick_item:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.needItemId))
		quick_item_suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(cfg.needItemId))
		quick_item_count:setText('x'..cfg.needItemCount)
		quick_btn:onClick(self, self.onQuickFinishTask)
		quick_btn:setTag(id)
		quick_btn:show()
		quick_item:show()
	else
		quick_btn:hide()
		quick_item:hide()
	end

	if type1 == 0 then
		self.tagRoot:show()
		self.tagRoot1:hide()
		local is_ok = g_i3k_game_context:IsTaskFinished(type2,arg21,arg22,values[2])
		local tagDesc2 = g_i3k_db.i3k_db_get_task_desc(type2,arg21,arg22,values[2],is_ok)

		if is_ok then
			self.go_btn3:onClick(self,self.onFinishWeaponTask)
			self.weapon_btn_lable:setText("完成")
		else
			self.go_btn3:onClick(self,self.onGotoweaponTaskPosition)
			if type2 == g_TASK_KILL then
				self.weaponTrs2_btn:show()
				--local tmp_data,_tmp_data = g_i3k_game_context:getCacheSpawnNpcResourData()
				self._weapon_point = g_i3k_db.i3k_db_get_monster_pos(arg21);
				self._weapon_mapID = g_i3k_db.i3k_db_get_monster_map_id(arg21);
				needValue = {flage = 3, mapId = self._weapon_mapID, areaId = arg21, pos = self._weapon_point}
			elseif type2 == g_TASK_COLLECT then
				self.weaponTrs2_btn:show()
				--local tmp_data,_tmp_data = g_i3k_game_context:getCacheSpawnNpcResourData()
				self._weapon_point = g_i3k_db.i3k_db_get_res_pos(arg21);
				self._weapon_mapID = g_i3k_db.i3k_db_get_res_map_id(arg21);
				needValue = {flage = 2, mapId = self._weapon_mapID, areaId = arg21, pos = self._weapon_point}
			elseif type2 == g_TASK_NPC_DIALOGUE then
				self.weaponTrs2_btn:show()
				--local tmp_data,_tmp_data = g_i3k_game_context:getCacheSpawnNpcResourData()
				self._weapon_point = g_i3k_db.i3k_db_get_npc_pos(arg21);
				self._weapon_mapID = g_i3k_db.i3k_db_get_npc_map_id(arg21);
				self._weapon_point = self:getRandomPos(arg21)
				needValue = {flage = 1, mapId = self._weapon_mapID, areaId = arg21, pos = self._weapon_point}
			elseif type2 == g_TASK_USE_ITEM then
				self.go_btn3:setTag(2)
				self.go_btn3:onClick(self,self.onWeaponUseItem)
			else
				self.go_btn3:hide()
			end
			self._weaponTransData  = needValue
			self.weaponTrs2_btn:onClick(self,self.transferToPoint,needValue)
		end

		if self.weaponTrs2_btn:isVisible() then
			tagDesc2 = string.format("%s  <c=green><u>传送</u></c>",tagDesc2)
		end
		self.weaponTaskTag2:setText(tagDesc2)
	elseif type2 == 0 then
		local is_ok = g_i3k_game_context:IsTaskFinished(type1,arg11,arg12,values[1])
		local tagDesc = g_i3k_db.i3k_db_get_task_desc(type1,arg11,arg12,values[1],is_ok)

		self.tagRoot:show()
		self.tagRoot1:hide()
		if is_ok then
			self.go_btn3:onClick(self,self.onFinishWeaponTask)
			self.weapon_btn_lable:setText("完成")
		else
			self.go_btn3:onClick(self,self.onGotoweaponTaskPosition)
			if type1 == g_TASK_KILL then
				self.weaponTrs2_btn:show()
				--local tmp_data,_tmp_data = g_i3k_game_context:getCacheSpawnNpcResourData()
				self._weapon_point = g_i3k_db.i3k_db_get_monster_pos(arg11);
				self._weapon_mapID = g_i3k_db.i3k_db_get_monster_map_id(arg11);
				needValue = {flage = 3, mapId = self._weapon_mapID, areaId = arg11, pos = self._weapon_point}
			elseif type1 == g_TASK_COLLECT then
				self.weaponTrs2_btn:show()
				--local tmp_data,_tmp_data = g_i3k_game_context:getCacheSpawnNpcResourData()
				self._weapon_point = g_i3k_db.i3k_db_get_res_pos(arg11);
				self._weapon_mapID = g_i3k_db.i3k_db_get_res_map_id(arg11);
				needValue = {flage = 2, mapId = self._weapon_mapID, areaId = arg11, pos = self._weapon_point}
			elseif type1 == g_TASK_NPC_DIALOGUE then
				self.weaponTrs2_btn:show()
				--local tmp_data,_tmp_data = g_i3k_game_context:getCacheSpawnNpcResourData()
				self._weapon_point = g_i3k_db.i3k_db_get_npc_pos(arg11);
				self._weapon_mapID = g_i3k_db.i3k_db_get_npc_map_id(arg11);
				self._weapon_point = self:getRandomPos(arg11)
				needValue = {flage = 1, mapId = self._weapon_mapID, areaId = arg11, pos = self._weapon_point}
			elseif type1 == g_TASK_USE_ITEM then
				self.go_btn3:setTag(1)
				self.go_btn3:onClick(self,self.onWeaponUseItem)
			else
				self.go_btn3:hide()
			end
			self._weaponTransData  = needValue
			self.weaponTrs2_btn:onClick(self,self.transferToPoint,needValue)
		end
		if self.weaponTrs2_btn:isVisible() then
			tagDesc = string.format("%s  <c=green><u>传送</u></c>",tagDesc)
		end
		self.weaponTaskTag2:setText(tagDesc)
	else
		self.tagRoot:show()
		self.tagRoot1:show()
		local is_ok1 = g_i3k_game_context:IsTaskFinished(type1,arg11,arg12,values[1])
		local tagDesc = g_i3k_db.i3k_db_get_task_desc(type1,arg11,arg12,values[1],is_ok1)

		local is_ok2 = g_i3k_game_context:IsTaskFinished(type2,arg21,arg22,values[2])
		local tagDesc2= g_i3k_db.i3k_db_get_task_desc(type2,arg21,arg22,values[2],is_ok2)

		if is_ok1 and is_ok2 then
			self.go_btn3:onClick(self,self.onFinishWeaponTask)
			self.weapon_btn_lable:setText("完成")
		else
			if not is_ok2 then
				self.go_btn3:onClick(self,self.onGotoweaponTaskPosition)
				if type2 == g_TASK_KILL then
					self.weaponTrs2_btn:show()
					--local tmp_data,_tmp_data = g_i3k_game_context:getCacheSpawnNpcResourData()
					self._weapon_point = g_i3k_db.i3k_db_get_monster_pos(arg21);
					self._weapon_mapID = g_i3k_db.i3k_db_get_monster_map_id(arg21);
					needValue = {flage = 3, mapId = self._weapon_mapID, areaId = arg21, pos = self._weapon_point}
				elseif type2 == g_TASK_COLLECT then
					self.weaponTrs2_btn:show()
					--local tmp_data ,_tmp_data= g_i3k_game_context:getCacheSpawnNpcResourData()
					self._weapon_point = g_i3k_db.i3k_db_get_res_pos(arg21);
					self._weapon_mapID = g_i3k_db.i3k_db_get_res_map_id(arg21);
					needValue = {flage = 2, mapId = self._weapon_mapID, areaId = arg21, pos = self._weapon_point}
				elseif type2 == g_TASK_NPC_DIALOGUE then
					self.weaponTrs2_btn:show()
					--local tmp_data,_tmp_data = g_i3k_game_context:getCacheSpawnNpcResourData()
					self._weapon_point = g_i3k_db.i3k_db_get_npc_pos(arg21);
					self._weapon_mapID = g_i3k_db.i3k_db_get_npc_map_id(arg21);
					self._weapon_point = self:getRandomPos(arg21)
					needValue = {flage = 1, mapId = self._weapon_mapID, areaId = arg21, pos = self._weapon_point}
				elseif type2 == g_TASK_USE_ITEM then
					self.go_btn3:setTag(2)
					self.go_btn3:onClick(self,self.onWeaponUseItem)
				else
					self.go_btn3:hide()
				end
				self._weaponTransData  = needValue
				self.weaponTrs2_btn:onClick(self,self.transferToPoint,needValue)
			end
			if not is_ok1 then
				self.go_btn3:onClick(self,self.onGotoweaponTaskPosition)
				if type1 == g_TASK_KILL then
					self.go_btn3:show()
					self.weaponTrs1_btn:show()
					--local tmp_data,_tmp_data = g_i3k_game_context:getCacheSpawnNpcResourData()
					self._weapon_point = g_i3k_db.i3k_db_get_monster_pos(arg11);
					self._weapon_mapID = g_i3k_db.i3k_db_get_monster_map_id(arg11);
					needValue = {flage = 3, mapId = self._weapon_mapID, areaId = arg11, pos = self._weapon_point}
				elseif type1 == g_TASK_COLLECT then
					self.go_btn3:show()
					self.weaponTrs1_btn:show()
					--local tmp_data ,_tmp_data= g_i3k_game_context:getCacheSpawnNpcResourData()
					self._weapon_point = g_i3k_db.i3k_db_get_res_pos(arg11);
					self._weapon_mapID = g_i3k_db.i3k_db_get_res_map_id(arg11);
					needValue = {flage = 2, mapId = self._weapon_mapID, areaId = arg11, pos = self._weapon_point}
				elseif type1 == g_TASK_NPC_DIALOGUE then
					self.go_btn3:show()
					self.weaponTrs1_btn:show()
					--local tmp_data,_tmp_data = g_i3k_game_context:getCacheSpawnNpcResourData()
					self._weapon_point = g_i3k_db.i3k_db_get_npc_pos(arg11);
					self._weapon_mapID = g_i3k_db.i3k_db_get_npc_map_id(arg11);
					self._weapon_point = self:getRandomPos(arg11)
					needValue = {flage = 1, mapId = self._weapon_mapID, areaId = arg11, pos = self._weapon_point}
				elseif type1 == g_TASK_USE_ITEM then
					self.go_btn3:show()
					self.go_btn3:setTag(1)
					self.go_btn3:onClick(self,self.onWeaponUseItem)
				else
					self.go_btn3:hide()
				end
				self._weaponTransData  = needValue
			 self.weaponTrs1_btn:onClick(self,self.transferToPoint,needValue)
			end
		end
		if self.weaponTrs1_btn:isVisible() then
			tagDesc = string.format("%s  <c=green><u>传送</u></c>",tagDesc)
		end
		if self.weaponTrs2_btn:isVisible() then
			tagDesc2 = string.format("%s  <c=green><u>传送</u></c>",tagDesc2)
		end
		self.weaponTaskTag:setText(tagDesc)
		self.weaponTaskTag2:setText(tagDesc2)
	end
	local vars = self._layout.vars
	vars.quick_des:setVisible(vars.go_btn3:isVisible() or vars.quick_btn:isVisible())
end

function wnd_task:onWeaponUseItem(sender)
		local _type = sender:getTag()
		local id ,loop = g_i3k_game_context:getWeaponTaskIdAndLoopType()
		local weapon_cfg = g_i3k_db.i3k_db_get_weapon_task_cfg(id,loop)
		local type1 = weapon_cfg.type1
		local arg11 = weapon_cfg.arg11
		local arg12 = weapon_cfg.arg12

		local type2 = weapon_cfg.type2
		local arg21 = weapon_cfg.arg21
		local arg22 = weapon_cfg.arg22
		if _type == 1 then
			local data = i3k_sbean.task_submititem_req.new()
			data.taskCat = TASK_CATEGORY_WEAPON
			data.ItemId = arg11
			data.ItemCount = arg12
			data.petId = 0
			i3k_game_send_str_cmd(data,i3k_sbean.task_submititem_res.getName())
		elseif _type == 2 then
			local data = i3k_sbean.task_submititem_req.new()
			data.taskCat = TASK_CATEGORY_WEAPON
			data.ItemId = arg11
			data.ItemCount = arg22
			data.petId = 0
			i3k_game_send_str_cmd(data,i3k_sbean.task_submititem_res.getName())
		end
end

function wnd_task:onWeaponTaskGo(sender)
end
function wnd_task:onFinishWeaponTask(sender)
	local id ,loop = g_i3k_game_context:getWeaponTaskIdAndLoopType()
	local weapon_cfg = g_i3k_db.i3k_db_get_weapon_task_cfg(id,loop)
	local itemid = weapon_cfg.awardItemid
	local count =  weapon_cfg.awardItemCount
	local tmp = {[itemid] = count}
	local is_enough = g_i3k_game_context:IsBagEnough(tmp)
	if is_enough then
		local callfunc = function()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"playTaskFinishEffect")
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onUpdateBatterEquipShow")
			g_i3k_ui_mgr:CloseUI(eUIID_Task)
		end
		local data = i3k_sbean.wtask_reward_req.new()
		data.taskId = id
		data.__callback = callfunc
		i3k_game_send_str_cmd(data,i3k_sbean.wtask_reward_res.getName())
	else
		g_i3k_ui_mgr:PopupTipMessage("背包已满无法完成任务")
	end
end

function wnd_task:SetModule(weaponId)
	local ID
	if weaponId == -1 then
		ID = math.floor(math.random(1,#i3k_db_shen_bing))
	else
		ID = weaponId
	end
	if not i3k_db_shen_bing[ID] then
		return ;
	end
	local id = i3k_db_shen_bing[ID].showModuleID
	local path = i3k_db_models[id].path
	local uiscale = i3k_db_models[id].uiscale
	self.shenbing_module:setSprite(path)
	self.shenbing_module:setSprSize(uiscale)
	self.shenbing_module:playAction("stand")
end

----支线任务--
function wnd_task:onFinishSubLineTask(sender)
	local groupid = sender:getTag()
	local data = g_i3k_game_context:getSubLineIdAndValueBytype(groupid)
	local id = data.id
	local cfg = g_i3k_db.i3k_db_get_subline_task_cfg(groupid,id)
	local arg1 = cfg.arg1
	local arg2 = cfg.arg2
	g_i3k_game_context:taskSubItem(TASK_CATEGORY_SUBLINE,arg1,arg2)
	g_i3k_ui_mgr:CloseUI(eUIID_Task)
end

function wnd_task:onSubLineGoto(sender, groupid)
	-- local groupid = sender:getTag()
	local data = g_i3k_game_context:getSubLineIdAndValueBytype(groupid)
	local id = data.id
	if not id or id == 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_Task)
		return
	end
	if self._subline_mapID and self._subline_point then
		g_i3k_game_context:SeachPathWithMap(self._subline_mapID,self._subline_point,TASK_CATEGORY_SUBLINE,groupid,self.subtaskTransData)
	else
		local cfg = g_i3k_db.i3k_db_get_subline_task_cfg(groupid,id)
		local npcID = cfg.finishTaskNpcID
		if npcID == 0 then
			g_i3k_game_context:FinishSubLineTaskDialogue(groupid,id,g_i3k_game_context:isBagEnoughSubLineTaskAward(groupid,id),g_i3k_game_context:getSublineTaskAward(groupid,id))
		else
			local point = self:getRandomPos(npcID)
			g_i3k_game_context:SeachPathWithMap(g_i3k_db.i3k_db_get_npc_map_id(npcID), point, TASK_CATEGORY_SUBLINE,groupid,self.subtaskTransData)
		end
	end
	g_i3k_ui_mgr:CloseUI(eUIID_Task)
end

function wnd_task:onSelectSubLineTask(sender)
	local groupId = sender:getTag()
	self.selectedGroupId = groupId
	self:updateSubLineData(groupId)
end

function wnd_task:updateSubLineScroll()
	self._btnState = 4
	self:rootShow("zhixianRoot")
	self:btnToPressed("zhixian_btn")
	self.taskPartName:setText("支线任务")
	local scroll2 = self._layout.vars.scroll2
	scroll2:removeAllChildren()
	self.subui = {}
	local data = g_i3k_game_context:getSubLineTask()
	local index=0
	local jumptoIndex = 1
	local selflvl = g_i3k_game_context:GetLevel()
	for k,v in pairs(data) do
		if v.id ~= 0 then
			local cfg = g_i3k_db.i3k_db_get_subline_task_cfg(k, v.id)
			if not(v.id == 1 and v.state == 0 and cfg.isHide == 1) then
			index = index+1
			local widgets = require(LAYER_ZXRWT)()
			local xinfaBg = widgets.vars.xinfaBg
			local pet_desc = widgets.vars.pet_desc
			local select_icon = widgets.vars.select_icon
			local btn = widgets.vars.select1_btn
			btn:setTag(k)
			btn:onClick(self,self.onSelectSubLineTask)
			local tm_task_type = cfg.type
			local arg1 = cfg.arg1
			local arg2 = cfg.arg2
			local is_ok = g_i3k_game_context:IsTaskFinished(tm_task_type,arg1,arg2,v.value)
			local str = ""
			if v.state == 0 then
				if cfg.conditionType == 1 and selflvl < cfg.conditionValue then
					str = string.format("<c=hlred>(%s级接取)</c>",cfg.conditionValue)
				else
					str = "<c=qblue>(可接取)</c>"
				end
			elseif v.state >= 1 and not is_ok then
				str = "<c=purple>(进行中)</c>"
			elseif v.state >= 1 and is_ok then
				str = "<c=green>(可交付)</c>"
			end
			local cfg = g_i3k_db.i3k_db_get_subline_task_cfg(k,v.id)
			local desc = cfg.prename .. cfg.name .. str
			pet_desc:setText(desc)

			self.subui[index] = {id = k,xinfaBg = xinfaBg,select_icon = select_icon}
			xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(_AUTO_PET_ICON))
			select_icon:hide()

			if self.selectedGroupId then
				if k == self.selectedGroupId then
					xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(_SELECT_PET_ICON))
					select_icon:show()
					jumptoIndex = index
				end
			end
			scroll2:addItem(widgets)
			end
		end
	end
	scroll2:jumpToChildWithIndex(jumptoIndex)
	if self.subui and self.subui[jumptoIndex] then
		self:updateSubLineData(self.subui[jumptoIndex].id)
	end
end

function wnd_task:updateSubLineData(groupId)
	if not groupId or groupId == 0 then
		return;
	end
	for k,v in ipairs(self.subui)do
		if groupId == v.id then
			v.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(_SELECT_PET_ICON))
			v.select_icon:show()
		else
			v.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(_AUTO_PET_ICON))
			v.select_icon:hide()
		end
	end
	local data = g_i3k_game_context:getSubLineIdAndValueBytype(groupId)
	local taskId = data.id
	if taskId == 0 then
		self:updateSubLineScroll()
		return
	end
	local value = data.value
	local cfg = g_i3k_db.i3k_db_get_subline_task_cfg(groupId,taskId)
	local tm_task_type = cfg.type
	local arg1 = cfg.arg1
	local arg2 = cfg.arg2
	local arg3 = cfg.arg3
	local arg4 = cfg.arg4
	local arg5 = cfg.arg5
	local is_ok = g_i3k_game_context:IsTaskFinished(tm_task_type,arg1,arg2,value)
	is_ok = g_i3k_game_context:TaskItemIsEnough(tm_task_type, is_ok, arg1, arg2)

	local NPCID = cfg.finishTaskNpcID
	local taskName4 = self._layout.vars.taskName4
	local taskTagDesc4 = self._layout.vars.petTaskDesc2
	local task_tag_desc = self._layout.vars.pet_task_tag2
	local go_btn4 = self._layout.vars.go_btn4
	local pet_task_lable2 = self._layout.vars.pet_task_lable2
	local pet_desc4 = self._layout.vars.pet_desc4
	local pet_desc3 = self._layout.vars.pet_desc3

	if cfg.abandonTask == 0 or data.state == 0 then
		self._layout.vars.zxAbandon:hide()
	else
		self._layout.vars.zxAbandon:show()
	end
	self._layout.vars.zxAbandon:setTag(groupId)
	pet_desc4:show()
	pet_desc3:hide()
	go_btn4:show()
	self.zhixianTrs_btn:show()
	taskName4:setText(cfg.name)
	taskTagDesc4:setText(cfg.taskDesc)
	self.subtaskTransData =	nil
	if data.state >= 1 and is_ok then
		pet_task_lable2:setText("完成")
		self.zhixianTrs_btn:hide()
		self._subline_mapID = nil
		self._subline_point = nil
			if NPCID ~= 0 then
				--寻径Npc交任务
				local point = g_i3k_db.i3k_db_get_npc_pos(NPCID);
				local mapID = g_i3k_db.i3k_db_get_npc_map_id(NPCID);
				point = self:getRandomPos(NPCID)
				local needValue = {flage = 1, mapId = mapID, areaId = NPCID, pos = point}
				self.subtaskTransData = needValue
				self.zhixianTrs_btn:onClick(self,self.transferToPoint,needValue)
				self.zhixianTrs_btn:show()
			end
		go_btn4:onClick(self,self.onSubLineGoto, groupId)
		if taskType == g_TASK_USE_ITEM then
			go_btn4:onClick(self,self.onFinishSubLineTask)
		end
	elseif data.state >= 1 then
		pet_task_lable2:setText("立即前往")
		local needValue = nil
		go_btn4:onClick(self,self.onGotoSubLineTaskPosition,groupId)
		if tm_task_type == g_TASK_KILL then
			local isNormal = true
			self._subline_point, self._subline_mapID, isNormal = g_i3k_db.i3k_db_checkMainTaskKillTarget(cfg);
			if isNormal then
				needValue = {flage = 3, mapId = self._subline_mapID, areaId = arg1, pos = self._subline_point}
			end
		elseif tm_task_type == g_TASK_COLLECT then
			self._subline_point = g_i3k_db.i3k_db_get_res_pos(arg1);
			self._subline_mapID = g_i3k_db.i3k_db_get_res_map_id(arg1);
			needValue = {flage = 2, mapId = self._subline_mapID, areaId = arg1, pos = self._subline_point}
		elseif tm_task_type == g_TASK_NEW_NPC_DIALOGUE then
			self._subline_point = g_i3k_db.i3k_db_get_npc_pos(arg1);
			self._subline_mapID = g_i3k_db.i3k_db_get_npc_map_id(arg1);
			self._subline_point = self:getRandomPos(arg1)
			needValue = {flage = 1, mapId = self._subline_mapID, areaId = arg1, pos = self._subline_point}
		elseif tm_task_type == g_TASK_USE_ITEM_AT_POINT then
			local pos = {x=arg3,y=arg4,z=arg5}
			self._subline_point = pos
			self._subline_mapID = arg2
			self.zhixianTrs_btn:hide()
		elseif tm_task_type == g_TASK_GET_TO_FUBEN then
			self.zhixianTrs_btn:hide()
			self._subline_mapID = arg1
		elseif tm_task_type ==	g_TASK_CLEARANCE_ACTIVITYPAD then --通关活动本
			self.zhixianTrs_btn:hide()
			self._subline_mapID = arg1
		elseif tm_task_type ==	g_TASK_PERSONAL_ARENA  then	--参与个人竞技场
			self.zhixianTrs_btn:hide()
		elseif tm_task_type == g_TASK_JOIN_FACTION then
			self.zhixianTrs_btn:hide()
		elseif tm_task_type == g_TASK_USE_ITEM then
			self.zhixianTrs_btn:hide()
			go_btn4:hide()
			pet_desc4:hide()
			pet_desc3:show()
			local item_bg2 = self._layout.vars.item_bg2
			local item_name2 =self._layout.vars.item_name2
			local item_icon2 = self._layout.vars.item_icon2
			local item_count2 = self._layout.vars.item_count2

			item_bg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(arg1))
			item_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(arg1,i3k_game_context:IsFemaleRole()))
			item_name2:setText(g_i3k_db.i3k_db_get_common_item_name(arg1))
			item_name2:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(arg1)))
			local have_count = g_i3k_game_context:GetCommonItemCanUseCount(arg1)
			local tmp_str = string.format("<c=red>%s/%s</c>",have_count,arg2)
			if have_count >= arg2 then
				tmp_str = string.format("<c=green>%s/%s</c>",have_count,arg2)
			end
			item_count2:setText(tmp_str)
			item_icon2:onTouchEvent(self,self.onTips,{id = arg1, close = true})
		elseif tm_task_type == g_TASK_TRANSFER then
			if i3k_game_get_map_type() == g_FIELD then
				local now_mapID =  g_i3k_game_context:GetWorldMapID()
				local targetMaps = g_i3k_db.i3k_db_get_all_npcs_map_id_by_funcId(TASK_FUNCTION_TRANSFER)
				self._subline_mapID,self._subline_point = g_i3k_db.i3k_db_find_nearest_map(now_mapID,targetMaps)
				local npcId = g_i3k_db.i3k_db_get_npc_id_by_pos(self._subline_mapID,self._subline_point)
				self._subline_point = self:getRandomPos(npcId)
				needValue = {flage = 1, mapId = self._subline_mapID, areaId = npcId, pos = self._subline_point}
			end
		elseif tm_task_type == g_TASK_ANY_MOMENT_DUNGEON then
			local pos = i3k_db_at_any_moment[arg1].position
			self._subline_point = {x = pos[1], y = pos[2],z = pos[3]}
			self._subline_mapID = i3k_db_at_any_moment[arg1].mapId
			needValue = {flage = 6, mapId = self._subline_mapID, areaId = self._subline_mapID, pos = self._subline_point}
		else
			self.zhixianTrs_btn:hide()
			go_btn4:hide()
		end
		if needValue then
			self.subtaskTransData = needValue
			self.zhixianTrs_btn:onClick(self,self.transferToPoint,needValue)
		end
	end
	if data.state == 0 then
		pet_task_lable2:setText("立即前往")
		go_btn4:onClick(self,self.onGotoSubLineTaskPosition,groupId)
		if cfg.getTaskNpcID ~= 0 then
			arg1 = cfg.getTaskNpcID
			tm_task_type = g_TASK_NPC_DIALOGUE
			self._subline_point = g_i3k_db.i3k_db_get_npc_pos(arg1);
			self._subline_mapID = g_i3k_db.i3k_db_get_npc_map_id(arg1);
			self._subline_point = self:getRandomPos(arg1)
			local needValue = {flage = 1, mapId = self._subline_mapID, areaId = arg1, pos = self._subline_point}
			self.subtaskTransData = needValue
			self.zhixianTrs_btn:onClick(self,self.transferToPoint,needValue)
			self.zhixianTrs_btn:show()
			go_btn4:show()
			pet_desc4:show()
			pet_desc3:hide()
		else
			self.zhixianTrs_btn:hide()
		end
	end
	--任务描述部分
	local tmp_desc = is_ok and g_i3k_db.i3k_db_get_subline_task_finish_reward_desc(groupId,taskId) or g_i3k_db.i3k_db_get_task_desc(tm_task_type,arg1,arg2,value, is_ok,nil)
	if self.zhixianTrs_btn:isVisible() then
		tmp_desc = string.format("%s  <c=green><u>传送</u></c>",tmp_desc)
	end
	task_tag_desc:setText(tmp_desc)

	----奖励部分---
	local item5Icon2 = self._layout.vars.item5Icon2
	local item5Count2 = self._layout.vars.item5Count2
	local item6Icon2 = self._layout.vars.item6Icon2
	local item6Count2 = self._layout.vars.item6Count2

	item5Icon2:hide()
	item5Count2:hide()
	item6Icon2:hide()
	item6Count2:hide()

	-------------------------数据-----------------------------
	local item7Icon2 = self._layout.vars.item7Icon2
	local item7Count2 = self._layout.vars.item7Count2
	item7Icon2:hide()
	item7Count2:hide()
	if cfg.awardExp > 0 then
		item7Icon2:show()
		item7Count2:show()
		item7Icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_EXP, g_i3k_game_context:IsFemaleRole()))
		item7Count2:setText(cfg.awardExp)
	end
	local item_t = {}
	local item_count = 0
	local rtype = g_i3k_game_context:GetRoleType()

	for i=1,4 do
		local tmp_item = string.format("awardItem%s",i)
		local itemid = cfg[tmp_item][rtype]
		if itemid and itemid ~= 0 then
			local tmp_count = string.format("awardItem%sCount",i)
			local awardItemCount = cfg[tmp_count]
			local t = {}
			t.itemid = itemid
			t.count = awardItemCount
			table.insert(item_t,t)
		end
	end

	local vars = self._layout.vars
	local prestr
	vars.item1Root2:hide()
	vars.item2Root2:hide()
	vars.item3Root2:hide()
	vars.item4Root2:hide()
	for k, v in ipairs(item_t) do
		if v.itemid == g_BASE_ITEM_DIAMOND then
			item5Icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemid, g_i3k_game_context:IsFemaleRole()))
			item5Count2:setText(v.count)
			item5Icon2:show()
			item5Count2:show()
		elseif v.itemid == g_BASE_ITEM_COIN then
			item6Icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemid, g_i3k_game_context:IsFemaleRole()))
			item6Count2:setText(v.count)
			item6Icon2:show()
			item6Count2:show()
		else
			item_count = item_count + 1
			if item_count > 4 then
				break
			end
			prestr = "item"..item_count

			vars[prestr.."Icon2"]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemid, g_i3k_game_context:IsFemaleRole()))
			vars[prestr.."Count2"]:setText(v.count)
			vars[prestr.."Root2"]:show()
			vars[prestr.."Root2"]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.itemid))
			vars[prestr.."Icon2"]:onTouchEvent(self,self.onTips,{id = v.itemid, close = false})
			vars["zhisuo"..item_count]:setVisible(v.itemid > 0)

		end
	end
end

function wnd_task:refresh(taskId,taskType,petId)
	self._taskID = taskId
	self._taskType = taskType
	self._petID = petId
	--[[if g_i3k_game_context:getMarryRoleId() == 0 then
		self._layout.vars.mrg_red:hide()
		self._layout.vars.mrg_btn:hide()
	end--]]
	self:checkMrgRed()
	if self._taskID and self._taskID > 0 and self._taskType then
		if self._taskType == TASK_CATEGORY_MAIN then
			self:updateMainTaskData( self._taskID,self._taskType)
		elseif self._taskType == TASK_CATEGORY_WEAPON then
			self:updateWeaponData(self._taskID,self._taskType)
		elseif self._taskType == TASK_CATEGORY_SWORDSMAN then
			self:onSwordsmanTask()
		elseif self._taskType == i3k_get_MrgTaskCategory() then
			self:openMrgUI()
		elseif self._taskType > 1000 then
			self.selectedGroupId = math.floor(taskType/1000)
			self:updateSubLineScroll()
		end
	else
		self:updateMainTaskData()
	end
end
function wnd_task:checkMrgRed()
	local data = g_i3k_game_context:GetMarriageTaskData()
	if data.id <= 0 then
		self._layout.vars.mrg_red:hide()
	end
end
function wnd_task:initShangJinData()
	self:checkMrgRed()
	self:updateShangJinTaskData()
end

function wnd_task:onTips(sender,eventType,args)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:ShowCommonItemInfo(args.id)
		if args.close then
			g_i3k_ui_mgr:CloseUI(eUIID_Task)
		end
	end
end

function wnd_task:onCompletedBtn(sender, info)
	local cfg = g_i3k_db.i3k_db_get_pet_task_cfg(info.taskID)
	local needDiamond = cfg.needDiamond
	local desc = i3k_get_string(610, needDiamond)
	local callback = function (isOk)
		if isOk then
			local data = i3k_sbean.ptask_reward_req.new()
			data.petId = info.id
			data.taskId = info.taskID
			data.isdiamond = 1
			data.needDiamond = needDiamond
			i3k_game_send_str_cmd(data,i3k_sbean.ptask_reward_res.getName())
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
end

function wnd_task:onPetTaskGo(sender)
end

function wnd_task:doTransport(array)
	local needId = i3k_db_common.activity.transNeedItemId
	local itemCount = g_i3k_game_context:GetBagMiscellaneousCanUseCount(needId)
	local hero = i3k_game_get_player_hero()
	local isFight = hero and hero:IsInFightTime()
	local isEscort = g_i3k_game_context:GetTransportState()
	if itemCount>0 and array and not (isFight and isEscort==1) then
		local mapID = array.mapId
		local cur_mapId = g_i3k_game_context:GetWorldMapID()
		if cur_mapId ~= mapID then
			g_i3k_ui_mgr:OpenUI(eUIID_transportProcessBar)
			g_i3k_ui_mgr:RefreshUI(eUIID_transportProcessBar,3,array,true)
			return true;
		end
	end
	return false;
end

function wnd_task:getRandomPos(NPCID)
	local mapId = g_i3k_db.i3k_db_get_npc_map_id(NPCID)
	local areaId = g_i3k_db.i3k_db_getNpcAreaId_By_npcId(NPCID,mapId)
	local angle = i3k_db_npc_area[areaId].dir.y
	local angle = i3k_db_npc_area[areaId].dir.y
	angle = math.pi * 2 - math.rad(angle)
	local a = math.random(angle-math.pi*3/8, angle+math.pi*3/8)
	local x = math.cos(a)*2.7
	local z = math.sin(a)*2.7
	local pos = g_i3k_db.i3k_db_get_npc_pos(NPCID)
	local newpos = {}
	newpos.x = pos.x+x
	newpos.y = pos.y
	newpos.z = pos.z+z
	return newpos
end

function wnd_task:onQuickFinishTask(sender)
	local taskID = sender:getTag()
	i3k_sbean.quick_finish_weapon_task(taskID)
end

function wnd_task:onSwordsmanTask(sender)
	if g_i3k_game_context:GetIsGlodCoast() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
		return 
	end
	if self._btnState ~= 6 then
		local taskId = g_i3k_game_context:getSwordsmanCircleTask()
		if taskId and taskId ~= 0 then
			self._btnState = 6
			self:rootShow("zhixianRoot")
			self:btnToPressed("swords_btn")
			self:updateSwordsmanScroll()
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18331))
		end
	end
end
function wnd_task:updateSwordsmanScroll()
	self._btnState = 6
	self:rootShow("zhixianRoot")
	self:btnToPressed("swords_btn")
	self._layout.vars.taskPartName:setText(i3k_get_string(18345))
	self._layout.vars.scroll2:removeAllChildren()
	local taskId, value, state = g_i3k_game_context:getSwordsmanCircleTask()
	local node = require(LAYER_ZXRWT)()
	node.vars.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(_SELECT_PET_ICON))
	node.vars.select_icon:show()
	node.vars.select1_btn:onClick(self, self.onSelectSwordsmanTask, taskId)
	local cfg = i3k_db_swordsman_circle_tasks[taskId]
	local is_ok = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, value)
	local str = ""
	if state == 0 then
		str = "<c=qblue>(可接取)</c>"
	elseif state >= 1 and not is_ok then
		str = "<c=purple>(进行中)</c>"
	elseif state >= 1 and is_ok then
		str = "<c=green>(可交付)</c>"
	end
	local desc = cfg.prename .. cfg.name .. str
	node.vars.pet_desc:setText(desc)
	self._layout.vars.scroll2:addItem(node)
	self:updateSwordsmanTask()
end
function wnd_task:onSelectSwordsmanTask(sender, taskId)
	self:updateSwordsmanTask()
end
function wnd_task:updateSwordsmanTask()
	local taskId, value, state = g_i3k_game_context:getSwordsmanCircleTask()
	local cfg = i3k_db_swordsman_circle_tasks[taskId]
	local isFinish = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, value)
	self._layout.vars.taskName4:setText(cfg.name)
	self._layout.vars.petTaskDesc2:setText(cfg.taskDesc)
	self._layout.vars.go_btn4:onClick(self, self.gotoSwordsmanTask)
	self._layout.vars.pet_desc3:hide()
	self._layout.vars.pet_desc4:show()
	self._layout.vars.pet_task_tag2:setText(g_i3k_db.i3k_db_get_task_desc(cfg.type, cfg.arg1, cfg.arg2, value, isFinish, nil))
	self._layout.vars.zxAbandon:show()
	self._layout.vars.zxAbandon:onClick(self, self.onAbandonSwordsmanTask, taskId)
	if state == 1 and isFinish then
		self._layout.vars.pet_task_lable2:setText("完成")
	elseif state == 1 then
		self._layout.vars.pet_task_lable2:setText("立即前往")
		if cfg.type == g_TASK_USE_ITEM then
			self._layout.vars.go_btn4:hide()
			self._layout.vars.pet_desc4:hide()
			self._layout.vars.pet_desc3:show()
			self._layout.vars.item_bg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(cfg.arg1))
			self._layout.vars.item_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.arg1, g_i3k_game_context:IsFemaleRole()))
			self._layout.vars.item_name2:setText(g_i3k_db.i3k_db_get_common_item_name(cfg.arg1))
			self._layout.vars.item_name2:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(cfg.arg1)))
			local have_count = g_i3k_game_context:GetCommonItemCanUseCount(cfg.arg1)
			local tmp_str = string.format("<c=red>%s/%s</c>", have_count, cfg.arg2)
			if have_count >= cfg.arg2 then
				tmp_str = string.format("<c=green>%s/%s</c>", have_count, cfg.arg2)
			end
			self._layout.vars.item_count2:setText(tmp_str)
			self._layout.vars.item_icon2:onTouchEvent(self, self.onTips, {id = cfg.arg1, close = true})
		end
	else
		self._layout.vars.pet_task_lable2:setText("立即前往")
	end
	local item5Icon2 = self._layout.vars.item5Icon2
	local item5Count2 = self._layout.vars.item5Count2
	local item6Icon2 = self._layout.vars.item6Icon2
	local item6Count2 = self._layout.vars.item6Count2
	item5Icon2:hide()
	item5Count2:hide()
	item6Icon2:hide()
	item6Count2:hide()
	self._layout.vars.item7Icon2:hide()
	self._layout.vars.item7Count2:hide()
	if cfg.awardExp > 0 then
		self._layout.vars.item7Icon2:show()
		self._layout.vars.item7Count2:show()
		self._layout.vars.item7Icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_EXP, g_i3k_game_context:IsFemaleRole()))
		self._layout.vars.item7Count2:setText(cfg.awardExp)
	end
	local item_t = {}
	local item_count = 0
	local rtype = g_i3k_game_context:GetRoleType()
	for i = 1, 4 do
		local tmp_item = string.format("awardItem%s",i)
		local itemid = cfg[tmp_item][rtype]
		if itemid and itemid ~= 0 then
			local tmp_count = string.format("awardItem%sCount",i)
			local awardItemCount = cfg[tmp_count]
			local t = {}
			t.itemid = itemid
			t.count = awardItemCount
			table.insert(item_t,t)
		end
	end
	local vars = self._layout.vars
	local prestr
	vars.item1Root2:hide()
	vars.item2Root2:hide()
	vars.item3Root2:hide()
	vars.item4Root2:hide()
	for k, v in ipairs(item_t) do
		if v.itemid == g_BASE_ITEM_DIAMOND then
			item5Icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemid, g_i3k_game_context:IsFemaleRole()))
			item5Count2:setText(v.count)
			item5Icon2:show()
			item5Count2:show()
		elseif v.itemid == g_BASE_ITEM_COIN then
			item6Icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemid, g_i3k_game_context:IsFemaleRole()))
			item6Count2:setText(v.count)
			item6Icon2:show()
			item6Count2:show()
		else
			item_count = item_count + 1
			if item_count > 4 then
				break
			end
			prestr = "item"..item_count
			vars[prestr.."Icon2"]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemid, g_i3k_game_context:IsFemaleRole()))
			vars[prestr.."Count2"]:setText(v.count)
			vars[prestr.."Root2"]:show()
			vars[prestr.."Root2"]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.itemid))
			vars[prestr.."Icon2"]:onTouchEvent(self, self.onTips,{id = v.itemid, close = false})
			vars["zhisuo"..item_count]:setVisible(v.itemid > 0)
		end
	end
end
function wnd_task:gotoSwordsmanTask(sender)
	local taskId, value, state = g_i3k_game_context:getSwordsmanCircleTask()
	local cfg = i3k_db_swordsman_circle_tasks[taskId]
	local isFinish = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, value)
	if state == 1 and isFinish then
		local npcID = cfg.finishTaskNpcID
		if npcID == 0 then
			g_i3k_game_context:OpenFinishTaskDialogue(cfg, TASK_CATEGORY_SWORDSMAN)
		else
			local point1 = g_i3k_db.i3k_db_get_npc_pos(npcID);
			local mapID = g_i3k_db.i3k_db_get_npc_map_id(npcID);
			local point = g_i3k_game_context:getNPCRandomPos(npcID)
			local needValue = {flage = 1, mapId = mapID, areaId = npcID, pos = point, npcPos = point1}
			local isCan = g_i3k_game_context:doTransport(needValue)
			if not isCan then
				g_i3k_game_context:SeachPathWithMap(mapID, point, TASK_CATEGORY_SWORDSMAN, nil, needValue)
			end
		end
	elseif state == 1 then
		g_i3k_game_context:GoingToDoTask(TASK_CATEGORY_SWORDSMAN, cfg, nil)
	else
		if g_i3k_game_context:CheckTransformationTaskState(cfg.effectIdList) and not g_i3k_game_context:IsInMetamorphosisMode() then
			g_i3k_ui_mgr:PopupTipMessage("请先完成当前变身任务")
			return
		end
		if cfg.getTaskNpcID == 0 then
			g_i3k_game_context:OpenGetTaskDialogue(cfg, TASK_CATEGORY_SWORDSMAN)
		else
			local point1 = g_i3k_db.i3k_db_get_npc_pos(cfg.getTaskNpcID)
			local mapID = g_i3k_db.i3k_db_get_npc_map_id(cfg.getTaskNpcID)
			local point = g_i3k_game_context:getNPCRandomPos(cfg.getTaskNpcID)
			local needValue = {flage = 1, mapId = mapID, areaId = cfg.getTaskNpcID, pos = point, npcPos = point1}
			local isCan = g_i3k_game_context:doTransport(needValue)
			if not isCan then
				g_i3k_game_context:SeachPathWithMap(mapID, point, taskType, nil, needValue)
			end
		end
	end
end
function wnd_task:onAbandonSwordsmanTask(sender, id)
	if i3k_db_swordsman_circle_tasks[id].canGiveUp == 1 then
		local taskId = id
		local _, value, state = g_i3k_game_context:getSwordsmanCircleTask()
		local cfg = i3k_db_swordsman_circle_tasks[taskId]
		local isFinish = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, value)
		if isFinish then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18328))
		else
			local callback = function (isOk)
				if isOk then
					i3k_sbean.friend_circle_cancel_task(taskId)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18293), callback)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18294))
	end
end
function wnd_create(layout,...)
	local wnd = wnd_task.new()
	wnd:create(layout,...)
	return wnd
end
