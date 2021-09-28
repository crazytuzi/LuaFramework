-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_petTask = i3k_class("wnd_petTask",ui.wnd_base)

local LAYER_RWT = "ui/widgets/rwt"
local _SELECT_PET_ICON = 706
local _AUTO_PET_ICON = 707

function wnd_petTask:ctor()
	self.scrollIndex = nil
end

function wnd_petTask:configure()
	local widget = self._layout.vars
	local main_btn = self._layout.vars.main_btn
	self.item = self._layout.vars.item
	self.expCount = self._layout.vars.expCount



	self.petTrs_btn = self._layout.vars.petchs


	--self.mainTrs_btn:hide()
	self.petTrs_btn:hide()


	self._layout.vars.close_btn:onClick(self,self.onCloseUI)

	local petRoot = self._layout.vars.petRoot
	local otherRoot = self._layout.vars.otherRoot
	local weaponRoot = self._layout.vars.weaponRoot
	local zhixianRoot = self._layout.vars.zhixianRoot

	self.task_tag_desc = self._layout.vars.task_tag_desc


	self._allRoot = {otherRoot = otherRoot,weaponRoot = weaponRoot,petRoot = petRoot,zhixianRoot = zhixianRoot}
	self._allBtn = {main_btn = main_btn,weapon_btn = weapon_btn,pet_btn = pet_btn,zhixian_btn = zhixian_btn}
	self.scroll = self._layout.vars.scroll

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



	self.loadingBarLabel = self._layout.vars.loadingBarLabel
	self.loadingBar = self._layout.vars.loadingBar

	self.taskName3 = self._layout.vars.taskName3
	self.taskTagDesc2 = self._layout.vars.taskTagDesc2

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
end

function wnd_petTask:refresh(id)
	self._petID = id
	self:updateAllPetData()
	self:updatePetTaskData()
end

function wnd_petTask:updateAllPetData(isOK)
	self.scroll:removeAllChildren()
	local all_data = g_i3k_game_context:GetPetTask()
	local count = 0
	self._pet = {}
	for k,v in ipairs(i3k_db_mercenaries) do
		local friend_lvl = g_i3k_game_context:getPetFriendLvl(k)
		if friend_lvl == 0 then
			friend_lvl = 1
		end
		local taskID,value = g_i3k_game_context:getPetTskIdAndValueById(k)
		--self.item:setVisible(false)
		--self.pet_desc1:setVisible(false)
		if taskID and taskID ~= 0 then
			--self.item:setVisible(true)
			--self.pet_desc1:setVisible(true)
			if i3k_db_suicong_relation[k][friend_lvl+ 1] then
				count = count + 1
				local name = v.name
				local _layer = require(LAYER_RWT)()
				local pet_icon = _layer.vars.pet_icon
				local pet_desc = _layer.vars.pet_desc
				local xinfaBg = _layer.vars.xinfaBg
				local select_icon = _layer.vars.select_icon
				local finish_icon = _layer.vars.finish_icon

				local pet_task_cfg = g_i3k_db.i3k_db_get_pet_task_cfg(taskID)
				local arg1 = pet_task_cfg.arg1
				local arg2 = pet_task_cfg.arg2
				local taskType = pet_task_cfg.type
				local task_name = pet_task_cfg.name
				local starLvl = pet_task_cfg.starLvl
				--local is_ok = g_i3k_game_context:IsTaskFinished(taskType,arg1,arg2,value)
				local is_ok = g_i3k_game_context:GetBagItemCanUseCount(arg1) >= arg2
				if is_ok then
					finish_icon:show()
				else
					finish_icon:hide()
				end
				for i=1,3 do
					local tmp_star = string.format("star%s",i)
					local star = _layer.vars[tmp_star]
					if starLvl >=i then
						star:show()
					else
						star:hide()
					end
				end
				select_icon:hide()
				local level_value = g_i3k_game_context:getPetLevel(k)
				local level_label = _layer.vars.level_label
				local tmp_str = string.format("%s级",level_value)
				if level_value == 0 then
					tmp_str = i3k_get_string(427);
				end
				level_label:setText(tmp_str)
				local select1_btn = _layer.vars.select1_btn
				local iconId = v.icon;
				if g_i3k_game_context:getPetWakenUse(k) then
					iconId = i3k_db_mercenariea_waken_property[k].headIcon;
				end
				pet_icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId,true))
				pet_desc:setText(name)
				local task_name_label = _layer.vars.task_name_label
				task_name_label:setText(task_name)
				select1_btn:setTag(count)
				select1_btn:onClick(self,self.onSelectPetTask, count)
				if count == 1 then
					if not self._petID or isOK then
						self._petID = k
					end
				end
				if self._petID and k == self._petID then
					xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(_SELECT_PET_ICON))
					select_icon:show()
				else
					xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(_AUTO_PET_ICON))
				end
				if v.isOpen ~= 0 then--根据配置的isOpen来控制随从的显示
					self._pet[count] = {id = k,xinfaBg = xinfaBg,select_icon = select_icon}
					self.scroll:addItem(_layer)
				end
			end
		end
	end
	self:updatePetTaskData()
	if self.scrollIndex then
		self.scroll:jumpToListPercent(self.scrollIndex)
	end
	if count == 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_PetTask)
		g_i3k_ui_mgr:PopupTipMessage("今日的宠物喂养次数已用尽")
	end
end

function wnd_petTask:updatePetTaskData()
	local id = self._petID
	local taskID,value = g_i3k_game_context:getPetTskIdAndValueById(id)
	local pet_task_cfg = g_i3k_db.i3k_db_get_pet_task_cfg(taskID)
	if not pet_task_cfg then
		return
	end
	local arg1 = pet_task_cfg.arg1
	local arg2 = pet_task_cfg.arg2
	local arg3 = pet_task_cfg.arg3
	local arg4 = pet_task_cfg.arg4
	local arg5 = pet_task_cfg.arg5
	local taskType = pet_task_cfg.type
	local friend_value = pet_task_cfg.firendValue
	local task_name = pet_task_cfg.name
	local task_desc = pet_task_cfg.getTaskDesc
	local friend_lvl = g_i3k_game_context:getPetFriendLvl(id)
	if friend_lvl == 0 then
		friend_lvl = 1
	end
	local friend_exp = g_i3k_game_context:getPetFriendExp(id)
	local need_exp = 0
	if not i3k_db_suicong_relation[self._petID][friend_lvl + 1] then
		need_exp = i3k_db_suicong_relation[self._petID][friend_lvl].needCount
	else
		need_exp = i3k_db_suicong_relation[self._petID][friend_lvl+1].needCount
	end
	self.expCount:setText(friend_exp .. "/" .. need_exp)
	local _temp_desc = i3k_get_string(37,i3k_db_mercenaries[id].name,i3k_db_suicong_relation[self._petID][friend_lvl].level)
	self.cur_level:setText(_temp_desc)
	--提示
	--local desc = self._layout.vars.dasd
	local isHave = g_i3k_game_context:IsHavePet(id)
	--desc:setText("每个随从每日可完成5个合修任务")
	self.loadingBar2:setPercent(friend_exp/need_exp*100)
	self.pet_task_lable:setText("立即前往")
	self.add_value:setText(i3k_get_string(26,friend_value))
	self.tqNum:setText(pet_task_cfg.coinnum)
	local times = g_i3k_game_context:GetDailyCompleteTask(self._petID)
	self.taskName2:setText(i3k_get_string(674, task_name, i3k_db_common.petBackfit.petTaskMax - times, i3k_db_common.petBackfit.petTaskMax))
	self.petTaskDesc:setText(task_desc)
	if taskType == g_TASK_USE_ITEM_AT_POINT or taskType == g_TASK_USE_ITEM then
		self.pet_desc2:hide()
		self.pet_desc1:show()
		self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(arg1))
		self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(arg1,i3k_game_context:IsFemaleRole()))
		self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(arg1))
		self.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(arg1)))
		local have_count = g_i3k_game_context:GetCommonItemCanUseCount(arg1)
		if taskType == g_TASK_USE_ITEM then
			--self.get_label:show()
			local get_way = g_i3k_db.i3k_db_get_common_item_source(arg1)
			--self.get_label:setText(get_way)
			self.item_icon:onTouchEvent(self,self.onTips,arg1)
		end
		if have_count >= arg2 then
			self.go_btn2:setTag(id)
			self.go_btn2:onClick(self,self.onFInishPetTask, id)
			self.go_btn2:show()
			self.completedBtn:hide()
			self.pet_task_lable:setText("喂养")
			local tmp_str = string.format("<c=green>%s/%s</c>",arg2,arg2)
			self.item_count:setText(tmp_str)
		else
			local tmp_str = string.format("<c=red>%s/%s</c>",have_count,arg2)
			self.item_count:setText(tmp_str)
			self.go_btn2:hide()
			self.completedBtn:show()
		end
	else
		self.pet_desc2:show()
		self.pet_desc1:hide()
		local is_ok = g_i3k_game_context:IsTaskFinished(taskType,arg1,arg2,value)
		local desc = g_i3k_db.i3k_db_get_task_desc(taskType,arg1,arg2,value,is_ok)

		if is_ok  then
			self.go_btn2:setTag(id)
			self.go_btn2:onClick(self,self.onFInishPetTask, id)
			self.go_btn2:show()
			self.completedBtn:hide()
			self.pet_task_lable:setText("喂养")
		else
			self.completedBtn:show()
			self.go_btn2:setTag(taskType)
			self.go_btn2:onClick(self,self.onGotoSuicongTaskPosition)
			self.go_btn2:show()
			local needValue
			if taskType == g_TASK_KILL then
				self.petTrs_btn:show()
				--local tmp_data,_tmp_data = g_i3k_game_context:getCacheSpawnNpcResourData()
				self._pet_point = g_i3k_db.i3k_db_get_monster_pos(arg1);
				self._pet_mapID = g_i3k_db.i3k_db_get_monster_map_id(arg1);
				needValue = {flage = 3, mapId = self._pet_mapID, areaId = arg1, pos = self._pet_point}
			elseif taskType == g_TASK_COLLECT then
				self.petTrs_btn:show()
				--local tmp_data,_tmp_data = g_i3k_game_context:getCacheSpawnNpcResourData()
				self._pet_point = g_i3k_db.i3k_db_get_res_pos(arg1);
				self._pet_mapID = g_i3k_db.i3k_db_get_res_map_id(arg1);
				needValue = {flage = 2, mapId = self._pet_mapID, areaId = arg1, pos = self._pet_point}
			elseif taskType == g_TASK_USE_ITEM_AT_POINT then
				local pos = {x=arg3,y=arg4,z=arg5}
				self._pet_point = pos
			elseif taskType == g_TASK_NPC_DIALOGUE then
				self.petTrs_btn:show()
				--local tmp_data,_tmp_data = g_i3k_game_context:getCacheSpawnNpcResourData()
				self._pet_point = g_i3k_db.i3k_db_get_npc_pos(arg1);
				self._pet_mapID = g_i3k_db.i3k_db_get_npc_map_id(arg1);
				self._pet_point = self:getRandomPos(arg1)
				needValue = {flage = 1, mapId = self._pet_mapID, areaId = arg1, pos = self._pet_point}
			elseif taskType == g_TASK_GET_TO_FUBEN then
				self._pet_mapID = arg1
			else
				self.go_btn2:hide()
			end
			self.petTransferData = needValue
			self.petTrs_btn:onClick(self,self.transferToPoint,needValue)
		end
		if self.petTrs_btn:isVisible() then
			desc = string.format("%s  <c=green><u>传送</u></c>",desc)
		end
		self.pet_task_tag:setText(desc)
	end
	self.completedDesc:setText("元宝喂养")
	self.completedBtn:onClick(self, self.onCompletedBtn, {taskID = taskID, id = id})
end

function wnd_petTask:onFInishPetTask(sender, id)
	local taskID = g_i3k_game_context:getPetTskIdAndValueById(id)
	local pet_task_cfg = g_i3k_db.i3k_db_get_pet_task_cfg(taskID)
	if pet_task_cfg then
		local taskType = pet_task_cfg.type
		local arg1 = pet_task_cfg.arg1
		local arg2 = pet_task_cfg.arg2
		local personname = i3k_db_mercenaries[id].name
		local task_name = pet_task_cfg.name
		if taskType == g_TASK_USE_ITEM then
			local data = i3k_sbean.pettask_submititem_req.new()
			data.taskCat = TASK_CATEGORY_PET
			data.ItemId = arg1
			data.ItemCount = arg2
			data.taskId = taskID
			data.petId = id
			i3k_game_send_str_cmd(data,i3k_sbean.pettask_submititem_res.getName())
		--[[else
			local callfunc = function()
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"playTaskFinishEffect")
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onUpdateBatterEquipShow")
			end
			local data = i3k_sbean.ptask_reward_req.new()
			data.petId = id
			data.taskId = taskID
			data.__callback = callfunc
			i3k_game_send_str_cmd(data,i3k_sbean.ptask_reward_res.getName())]]
		end
	end
end

function wnd_petTask:transferToPoint(sender,needValue)
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
		local descText = i3k_get_string(1491,needName, 1)
		local function callback(isOk)
			if isOk then
				local hero = i3k_game_get_player_hero()
				hero:StopMove(true);
				if needValue.flage == 1 then
					local areaId = g_i3k_db.i3k_db_getNpcAreaId_By_npcId(areaId,mapId)
					i3k_sbean.transToNpc(mapId, areaId)
				elseif needValue.flage == 2 then
					local mineId = i3k_db_res_map[areaId].resPosId
					if mineId then
						i3k_sbean.transToMinePoint(mapId,mineId)
					end
				elseif needValue.flage == 3 then
					local haveMonsterArea = i3k_db_dungeon_base[mapId].areas
					for i,v in pairs(haveMonsterArea) do
						local monsterPointTable = i3k_db_spawn_area[v].spawnPoints
						for j,k in pairs(monsterPointTable) do
							local pointCfg = i3k_db_spawn_point[k]
							local monsterId = pointCfg.monsters[1]
							if monsterId == areaId then
								i3k_sbean.transToMonster(mapId, k)
								break;
							end
						end
					end
				end
				g_i3k_logic:OpenBattleUI()
				--g_i3k_ui_mgr:CloseUI(eUIID_Task)
			end
		end
		if g_i3k_game_context:IsTransNeedItem() then
			g_i3k_ui_mgr:ShowMessageBox2(descText, callback)
		else
			callback(true)
		end
	end
end

function wnd_petTask:onGotoSuicongTaskPosition(sender)
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
end

function wnd_petTask:onSelectPetTask(sender,count)
	local tag = sender:getTag()
	self.scrollIndex = self.scroll:getListPercent()
	local id = self._pet[count].id
	self._petID = id
	for k,v in pairs(self._pet) do
		if v.id == id then
			v.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(_SELECT_PET_ICON))
			v.select_icon:show()
		else
			v.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(_AUTO_PET_ICON))
			v.select_icon:hide()
		end
	end
	self:updatePetTaskData()
end

function wnd_petTask:onCompletedBtn(sender, info)
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

function wnd_petTask:onTips(sender,eventType,id)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:ShowCommonItemInfo(id)
	end
end

function wnd_create(layout)
	local wnd = wnd_petTask.new()
		wnd:create(layout)
	return wnd
end
