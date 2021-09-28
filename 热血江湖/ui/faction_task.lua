-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_task = i3k_class("wnd_faction_task", ui.wnd_base)

local LAYER_BPRWT = "ui/widgets/bprwt"
local LAYER_BPRWT2 = "ui/widgets/bprwt2"
local LAYER_BPRWT2F = "ui/widgets/bprwt2f"

local time_label = nil

local _DESC_STR = nil
local _DESC_STR2 = nil

--帮派任务完成上限
local faction_task_max_count = i3k_db_common.faction.faction_task_max_count

function wnd_faction_task:ctor()
	self._task_bank_data = {}
	self._task_timer = nil
	self._dragon_timer = {}--龙穴计时
	self.dayRefreshTimes = 0
	self.weekFinishTime = 0
	self.score = 0
end

function wnd_faction_task:onShow()

end

function wnd_faction_task:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI, function ()
		self:onHide()
	end)
	self.scrollIcon = self._layout.vars.scrollIcon
	self.task_bank_btn = self._layout.vars.task_bank_btn
	self.task_bank_btn:onTouchEvent(self,self.onTaskBank)
	self.task_bank_btn:stateToPressed(true)
	self.share_btn = self._layout.vars.share_btn
	self.share_btn:onTouchEvent(self,self.onShare)

	self.canGetTask = self._layout.vars.unfinished_btn
	self.canGetTask:onTouchEvent(self,self.onCanGetTask)
	self.canGetTask:stateToPressed()
	local canGetDesc = self._layout.vars.canGetDesc
	self.finished_btn = self._layout.vars.finished_btn
	self.finished_btn:onTouchEvent(self,self.onfinished)

	local finish_desc = self._layout.vars.finish_desc
	self.refresh_btn = self._layout.vars.refresh_btn
	self.refresh_btn:hide()

	self.getAward_btn = self._layout.vars.getAward_btn
	self.getAward_btn:hide()
	self.reset_btn = self._layout.vars.reset_btn
	self.reset_btn:show()
	self.task_count = self._layout.vars.task_count
	self.task_count_bg = self._layout.vars.task_count_bg
	self.moneyRoot = self._layout.vars.moneyRoot
	self.moneyCount = self._layout.vars.moneyCount
	self.free_label = self._layout.vars.free_label
	self.scroll = self._layout.vars.scroll
	_DESC_STR = self._layout.vars.desc_str
	_DESC_STR2 = self._layout.vars.quick_des
	self.share_point = self._layout.vars.share_point 
	self.share_point:hide()
	
	self.get_award_point = self._layout.vars.get_award_point 
	self.get_award_point:hide()
	self._layout.vars.dragon_task:onClick(self, self.onDragonTask)
end

function wnd_faction_task:refresh()
	self:updateGetAwardPoint()
end 

function wnd_faction_task:onTaskBank(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self:onHide()
		self.share_btn:stateToNormal(true)
		self.task_bank_btn:stateToPressed(true)
		self._layout.vars.dragon_task:stateToNormal(true)
		local data = i3k_sbean.sect_task_sync_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_task_sync_res.getName())
	end
end



function wnd_faction_task:updateTitleDesc(count,dayRefreshCount)
	local tmp_str = string.format("今日已完成：%s/%s",count,faction_task_max_count)
	self.task_count:setText(tmp_str)
	self.task_count:show()
	self.task_count_bg:show()
	self.moneyRoot:show()

	dayRefreshCount = dayRefreshCount + 1
	local money_count = 0
	if i3k_db_common.faction.reset_count[dayRefreshCount] then
		money_count = i3k_db_common.faction.reset_count[dayRefreshCount]
	else
		local _index = #i3k_db_common.faction.reset_count
		money_count = i3k_db_common.faction.reset_count[_index]
	end
	self.moneyCount:setText(money_count)
	self.free_label:hide()
end

function wnd_faction_task:onItemTips(sender,tag)
	--if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:ShowCommonItemInfo(tag)
	--end
end

function wnd_faction_task:updateTaskBankData(_data,my_id,my_name,currentRoleID,currentGuid,currentTaskID,currentTaskValue)
	if not _data then
		return
	end
	self:onHide()
	_DESC_STR:setText("每日免费刷新时间：17：00；每日重置并刷新任务时间：5：00。")
	_DESC_STR2:setText(i3k_get_string(17497,g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_FACTION).needActivity))
	self.canGetTask:show()
	self.finished_btn:show()
	self.getAward_btn:hide()
	self.share_point:hide()
	self.refresh_btn:hide()
	self.reset_btn:show()
	self.reset_btn:onTouchEvent(self,self.onReset)
	self._layout.vars.dragonNode:hide()
	self.scrollIcon:show()
	self.moneyRoot:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_DIAMOND, g_i3k_game_context:IsFemaleRole()))
	self:updateTitleDesc(g_i3k_game_context:getFactionTaskFinishCount(),g_i3k_game_context:getFactionTaskRefreshCount())
	local width = self.scroll:getContentSize().width
	self.scroll:setContainerSize(width,0)
	self.scroll:removeAllChildren()
	self._task_bank_data = {}
	local roleLvl = g_i3k_game_context:GetLevel()
	local level_cfg = g_i3k_db.i3k_db_get_level_cfg(roleLvl)
	local _index = 0
	for k,v in ipairs(_data) do
		_index = _index + 1
		local taskID = v.taskId
		local guid = v.sid
		local _layer = require(LAYER_BPRWT)()
		local darkRoot = _layer.vars.darkRoot
		darkRoot:show()
		local highRoot = _layer.vars.highRoot
		highRoot:hide()
		local fail_mark = _layer.vars.fail_mark
		fail_mark:hide()
		local share_mark = _layer.vars.share_mark
		share_mark:hide()
		local globel_btn = _layer.vars.globel_btn
		local get_btn = _layer.vars.get_btn
		get_btn:hide()
		local taskIcon = _layer.vars.taskIcon
		local _cfg_data = g_i3k_db.i3k_db_get_faction_task_cfg(taskID)
		taskIcon:setImage(g_i3k_db.i3k_db_get_icon_path(_cfg_data.icon))
		local taskName = _layer.vars.taskName
		taskName:setText(_cfg_data.name)
		local task_desc_label = _layer.vars.task_desc_label
		task_desc_label:hide()
		local tmp_index = 0
		if _cfg_data.exp ~= 0 then
			tmp_index = 1
			local tmp_image = string.format("image%s",tmp_index)
			local image = _layer.vars[tmp_image]
			local tmp_icon = string.format("icon%s",tmp_index)
			local icon = _layer.vars[tmp_icon]
			local tmp_count = string.format("count%s",tmp_index)
			local count = _layer.vars[tmp_count]
			image:show()
			image:onClick(self,self.onItemTips,g_BASE_ITEM_EXP)
			icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_EXP,i3k_game_context:IsFemaleRole()))
			count:show()
			local tmp_str = string.format("x%s",level_cfg.factionTaskExp * _cfg_data.exp)
			count:setText(tmp_str)
			local cotribution = string.format("x%s",_cfg_data.contribution)
			local factionContribution = i3k_db_kungfu_vip[g_i3k_game_context:GetVipLevel()].factionContribution
			if factionContribution > 1 then
				cotribution = string.format("x%s(双倍)",_cfg_data.contribution*factionContribution)
			end
			 _layer.vars.cotribution:setText(cotribution)
			_layer.vars.image4:onClick(self,self.onItemTips,g_BASE_ITEM_SECT_MONEY) 
		end
		for i= tmp_index+1, 3 do
			local tmp_image = string.format("image%s",i)
			local image = _layer.vars[tmp_image]
			local tmp_icon = string.format("icon%s",i)
			local icon = _layer.vars[tmp_icon]
			local tmp_count = string.format("count%s",i)
			local count = _layer.vars[tmp_count]
			if _cfg_data then
				local tmp_id =  string.format("awardID%s",i - tmp_index)
				local awardID = _cfg_data[tmp_id]
				local tmp_count = string.format("awardCount%s",i - tmp_index)
				local awardCount = _cfg_data[tmp_count]
				if awardID and awardCount and awardID ~= 0 then
					image:show()
					image:onClick(self,self.onItemTips,awardID)
					image:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(awardID))
					icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(awardID,i3k_game_context:IsFemaleRole()))
					count:show()
					local tmp_str = string.format("x%s",awardCount)
					count:setText(tmp_str)
				else
					image:hide()
					count:hide()
				end
			end
		end
		for i=1,5 do
			local tmp_star = string.format("star%s",i)
			local star = _layer.vars[tmp_star]
			if i  > _cfg_data.starLvl then
				star:hide()
			else
				star:show()
			end
		end
		local finish_mark = _layer.vars.finish_mark
		finish_mark:hide()

		local is_starting = _layer.vars.is_starting

		--判断是否正在进行的任务，
		local is_now_task = false
		if my_id == currentRoleID and currentGuid == guid then
			is_now_task = true
		end
		local is_finished = false
		local current_task_cfg =g_i3k_db.i3k_db_get_faction_task_cfg(currentTaskID)
		if current_task_cfg then
			is_finished = g_i3k_game_context:IsTaskFinished(current_task_cfg.type,current_task_cfg.arg1,current_task_cfg.arg2,currentTaskValue)
		end
		local go_btn = _layer.vars.go_btn
		local goLabel = _layer.vars.goLabel
		local task_count = _layer.vars.task_count
		task_count:hide()
		go_btn:setTag(_index)
		go_btn:onTouchEvent(self,self.onGet)
		goLabel:setText("接取")

		local quick_root = _layer.vars.quick_finish_root
		local accept_btn = _layer.vars.accept_btn
		local quick_btn = _layer.vars.quick_finish_btn
		local quick_lable = _layer.vars.quick_lable
		local quick_item_icon = _layer.vars.quick_item
		local quick_item_suo = _layer.vars.quick_suo
		local quick_item_count = _layer.vars.quick_count
		local cfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_FACTION)
		accept_btn:setTag(_index)
		quick_btn:setTag(_index)
		if g_i3k_game_context:isCanQuickFinishTask(g_QUICK_FINISH_TASK_TYPE_FACTION,taskID) then
			go_btn:hide()--隐藏原来的接取按钮 用新的
			quick_root:show()
			accept_btn:onTouchEvent(self, self.onGet)
			quick_btn:onClick(self, self.onQuickFinishTask, g_QUICK_FINISH_TASK_TYPE_FACTION)
			quick_lable:setText("接取")
			quick_item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.needItemId))
			quick_item_suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(cfg.needItemId))
			quick_item_count:setText('x'..cfg.needItemCount)
		else
			quick_root:hide()
		end
		is_starting:hide()
		local effect1 = _layer.vars.effect1
		effect1:hide()
		local effect2 = _layer.vars.effect2
		effect2:hide()
		if is_now_task then
			darkRoot:hide()
			highRoot:show()
			is_starting:show()
			go_btn:setVisible(not quick_root:isVisible())
			go_btn:onTouchEvent(self,self.onGiveUp)
			goLabel:setText("放弃")
			if quick_root:isVisible() then
				quick_lable:setText("放弃")
				accept_btn:onTouchEvent(self, self.onGiveUp)
			end
			if is_finished then
				get_btn:onTouchEvent(self,self.onFinishTask)
				get_btn:setTag(_index)
				quick_root:hide()
				get_btn:show()
				go_btn:hide()
				effect1:show()
				effect2:show()
			end
		end
		self._task_bank_data[_index] = {taskID = taskID, roleID = my_id, guid = guid, roleName = my_name, isNowTask = is_now_task }
		self.scroll:addItem(_layer)
	end
end

function wnd_faction_task:onGiveUp(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local tag = sender:getTag()
		local roleID = self._task_bank_data[tag].roleID
		local taskID = self._task_bank_data[tag].taskID
		local guid = self._task_bank_data[tag].guid
		local data = i3k_sbean.sect_task_cancel_req.new()
		data.ownerId = roleID
		data.sid = guid
		data.taskId = taskID

		i3k_game_send_str_cmd(data,i3k_sbean.sect_task_cancel_res.getName())
	end
end

function wnd_faction_task:onGet(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local count  = g_i3k_game_context:getFactionTaskFinishCount()
		if count >= faction_task_max_count then
			g_i3k_ui_mgr:PopupTipMessage("今日完成帮派任务次数已满，不可再接取")
			return
		end
		local tmp_roleId = g_i3k_game_context:getFactionTaskRoleId()
		if tmp_roleId then
			g_i3k_ui_mgr:PopupTipMessage("您当前有帮派任务正在进行中")
			return
		end
		local my_id = g_i3k_game_context:GetRoleId()
		local tag = sender:getTag()
		local roleID = self._task_bank_data[tag].roleID
		local taskID = self._task_bank_data[tag].taskID
		local guid = self._task_bank_data[tag].guid
		local roleName = self._task_bank_data[tag].roleName
		local punish_time = g_i3k_game_context:getShareTaskPunishTime()
		local time_count = i3k_db_common.faction.share_task_punish_time
		local serverTime = i3k_game_get_time()
		serverTime = i3k_integer(serverTime)
		if my_id ~= roleID then
			if punish_time ~= 0 then
				if punish_time + time_count > serverTime then
					g_i3k_ui_mgr:PopupTipMessage("您放弃了共用任务，需要等待一段时间才可继续接取共用任务")
					return
				else
					g_i3k_game_context:setShareTaskPunishTime(0)
				end
			end
		end
		-- g_i3k_ui_mgr:InvokeUIFunction(eUIID_Battle,"showTaskReceveAnimation")
		g_i3k_ui_mgr:OpenUI(eUIID_BattleTXAcceptTask)
		local data = i3k_sbean.sect_task_receive_req.new()
		data.ownerId = roleID
		data.sid = guid
		data.taskID = taskID
		data.roleName = roleName
		i3k_game_send_str_cmd(data,i3k_sbean.sect_task_receive_res.getName())
	end
end

function wnd_faction_task:onFinishTask(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local tag = sender:getTag()
		local roleID = self._task_bank_data[tag].roleID
		local taskID = self._task_bank_data[tag].taskID
		local guid = self._task_bank_data[tag].guid
		local data = i3k_sbean.sect_task_finish_req.new()
		local is_enough = g_i3k_game_context:isBagEnoughFactionTaskAward(taskID)
		if is_enough then
			data.ownerId = roleID
			data.sid = guid
			data.taskID = taskID
			i3k_game_send_str_cmd(data,i3k_sbean.sect_task_finish_res.getName())
			-- g_i3k_ui_mgr:InvokeUIFunction(eUIID_Battle,"showTaskFinishAnimation")
			g_i3k_ui_mgr:OpenUI(eUIID_BattleTXAcceptTask)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
		end
	end
end

function wnd_faction_task:onQuickFinishTask(sender, taskType)
	local tag = sender:getTag()
	local quick_cfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(taskType)
	if g_i3k_game_context:GetCommonItemCanUseCount(quick_cfg.needItemId) >= quick_cfg.needItemCount then
		if taskType == g_QUICK_FINISH_TASK_TYPE_FACTION then
			local count  = g_i3k_game_context:getFactionTaskFinishCount()
			if count >= faction_task_max_count then
				g_i3k_ui_mgr:PopupTipMessage("今日完成帮派任务次数已满，不可再接取")
				return
			end
			local data = self._task_bank_data[tag]
			local tmp_roleId = g_i3k_game_context:getFactionTaskRoleId()
			if tmp_roleId and not data.isNowTask then
				g_i3k_ui_mgr:PopupTipMessage("您当前有帮派任务正在进行中")
				return
			end
			local bean = i3k_sbean.sect_quick_finish_task_req.new()
			bean.ownerId = data.roleID
			bean.sid = data.guid
			bean.taskID = data.taskID
			i3k_game_send_str_cmd(bean,i3k_sbean.sect_quick_finish_task_res.getName())
		elseif taskType == g_QUICK_FINISH_TASK_TYPE_LONGXUE then
			if tag == 0 then
				g_i3k_ui_mgr:PopupTipMessage("任务已经失败")
				return
			end
			local task = g_i3k_game_context:GetAcceptDragonHoleTask()
			local _, isGot = g_i3k_game_context:isAcceptDragonHoleTask(tag)
			local isAccept = false
			if next(task) then
				for i, v in ipairs(task) do
					if v.id == tag then
						isAccept = true
						break
					end
				end
			end
			if not isAccept then
				if #task >= i3k_db_dragon_hole_cfg.maxTaskOnce then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16981))
				elseif self.weekFinishTime + #task >= i3k_db_dragon_hole_cfg.maxTaskWeekly then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16981))
				elseif g_i3k_game_context:GetLevel() < i3k_db_dragon_hole_cfg.level then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16971))
				elseif not g_i3k_db.i3k_db_is_in_dragon_task_time() then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16980))
				elseif isGot then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16977))
				else
					local bean = i3k_sbean.dragon_hole_quick_finish_task_req.new()
					bean.taskId = tag
					i3k_game_send_str_cmd(bean,i3k_sbean.dragon_hole_quick_finish_task_res.getName())
				end
			else
				local bean = i3k_sbean.dragon_hole_quick_finish_task_req.new()
				bean.taskId = tag
				i3k_game_send_str_cmd(bean,i3k_sbean.dragon_hole_quick_finish_task_res.getName())
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17498, g_i3k_db.i3k_db_get_common_item_name(quick_cfg.needItemId)))
	end
end

function wnd_faction_task:onReset(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local dayRefreshCount = g_i3k_game_context:getFactionTaskRefreshCount()
		if dayRefreshCount >= g_MAX_REFRESH_TIMES then
			g_i3k_ui_mgr:PopupTipMessage("本日刷新次数已满")
			return 
		end 
		local money_count = 0
		if i3k_db_common.faction.reset_count[dayRefreshCount + 1] then
			money_count = i3k_db_common.faction.reset_count[dayRefreshCount + 1]
		else
			local _index = #i3k_db_common.faction.reset_count
			money_count = i3k_db_common.faction.reset_count[_index]
		end

		if g_i3k_game_context:GetDiamondCanUse(false) < money_count then
			g_i3k_ui_mgr:PopupTipMessage("元宝不足，操作失败")
			return
		end
		
		local fun = (function(ok)
			if ok then
				local count  = g_i3k_game_context:getFactionTaskFinishCount()
				if count >= faction_task_max_count then
					local fun = (function(ok)
						if ok then
							local data = i3k_sbean.sect_task_reset_req.new()
							i3k_game_send_str_cmd(data,i3k_sbean.sect_task_reset_res.getName())
						end
					end)
					g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(596),fun)
					return 
				end
				local data = i3k_sbean.sect_task_reset_req.new()
				i3k_game_send_str_cmd(data,i3k_sbean.sect_task_reset_res.getName())
			end
		end)
		local desc = i3k_get_string(15164,money_count,g_MAX_REFRESH_TIMES - dayRefreshCount )
		g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
	end
end
-----------------------------------------------------------
function wnd_faction_task:onShare(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self.share_btn:stateToPressed(true)
		self.task_bank_btn:stateToNormal(true)
		self._layout.vars.dragon_task:stateToNormal(true)
		local data = i3k_sbean.sect_share_task_sync_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_share_task_sync_res.getName())
	end
end

function wnd_faction_task:onRefresh(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self:onHide()
		local data = i3k_sbean.sect_share_task_sync_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_share_task_sync_res.getName())
	end
end


function wnd_faction_task:updateTaskShareData(_data,my_id,currentRoleID,currentGuid, currentTaskID,currentTaskValue,receiveTime,roleName)
	if not _data then
		return
	end
	self:onHide()
	self.canGetTask:show()
	self.finished_btn:show()
	self:updateTitleDesc(g_i3k_game_context:getFactionTaskFinishCount(),g_i3k_game_context:getFactionTaskRefreshCount())
	_DESC_STR:setText("")
	_DESC_STR2:setText("")
	self.share_btn:stateToPressed(true)
	self.task_bank_btn:stateToNormal(true)
	self._layout.vars.dragon_task:stateToNormal(true)
	self.getAward_btn:hide()
	self.share_point:hide()
	self.refresh_btn:show()
	self.refresh_btn:onTouchEvent(self,self.onRefresh)
	self.reset_btn:hide()
	self.free_label:show()
	self.task_count_bg:show()
	
	self.moneyRoot:hide()
	local tmp = {}
	local roleLvl = g_i3k_game_context:GetLevel()
	local level_cfg = g_i3k_db.i3k_db_get_level_cfg(roleLvl)
	if currentRoleID and currentRoleID ~= my_id then
		tmp.task = {}
		local temp = {}
		temp.taskId = currentTaskID
		temp.sid = currentGuid
		table.insert(tmp.task,temp)
		tmp.ownerId = currentRoleID
		tmp.ownerName = roleName
		tmp.receiveTime = receiveTime
	end
	if tmp.task then
		table.insert(_data,1,tmp)
	end
	self._layout.vars.dragonNode:hide()
	self.scrollIcon:show()
	self.scroll:removeAllChildren()
	local width = self.scroll:getContentSize().width
	self.scroll:setContainerSize(width,0)
	self._task_bank_data = {}

	local _index = 0

	for k,v in pairs(_data) do
		local roleID = v.ownerId
		local roleName = v.ownerName
		for a,b in pairs(v.task) do
			_index = _index + 1

			local taskID = b.taskId
			local guid = b.sid
			local _layer = require(LAYER_BPRWT)()
			local fail_mark = _layer.vars.fail_mark
			fail_mark:hide()

			local share_mark = _layer.vars.share_mark
			share_mark:hide()
			local darkRoot = _layer.vars.darkRoot
			darkRoot:show()
			local highRoot = _layer.vars.highRoot
			highRoot:hide()
			local task_desc_label = _layer.vars.task_desc_label
			task_desc_label:hide()
			local get_btn = _layer.vars.get_btn
			get_btn:hide()

			local globel_btn = _layer.vars.globel_btn
			local taskIcon = _layer.vars.taskIcon
			local _cfg_data = g_i3k_db.i3k_db_get_faction_task_cfg(taskID)
			taskIcon:setImage(i3k_db_icons[_cfg_data.icon].path)
			local taskName = _layer.vars.taskName
			taskName:setText(_cfg_data.name)
			local tmp_index = 0
			if _cfg_data.exp ~= 0 then
				tmp_index = 1
				local tmp_image = string.format("image%s",tmp_index)
				local image = _layer.vars[tmp_image]
				local tmp_icon = string.format("icon%s",tmp_index)
				local icon = _layer.vars[tmp_icon]
				local tmp_count = string.format("count%s",tmp_index)
				local count = _layer.vars[tmp_count]
				image:show()
				image:onClick(self,self.onItemTips,g_BASE_ITEM_EXP)
				icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_EXP,i3k_game_context:IsFemaleRole()))
				count:show()
				local tmp_str = string.format("×%s",level_cfg.factionTaskExp * _cfg_data.exp)
				count:setText(tmp_str)
				local cotribution = string.format("x%s",_cfg_data.contribution)
				local factionContribution = i3k_db_kungfu_vip[g_i3k_game_context:GetVipLevel()].factionContribution
				if factionContribution > 1 then
					cotribution = string.format("x%s(双倍)",_cfg_data.contribution*factionContribution)
				end
			 	_layer.vars.cotribution:setText(cotribution)
			end
			for i=1 + tmp_index, 3 do
				local tmp_image = string.format("image%s",i)
				local image = _layer.vars[tmp_image]
				local tmp_icon =  string.format("icon%s",i)
				local icon = _layer.vars[tmp_icon]
				local tmp_count = string.format("count%s",i)
				local count = _layer.vars[tmp_count]
				if _cfg_data then
					local tmp_id = string.format("awardID%s",i - tmp_index)
					local awardID = _cfg_data[tmp_id]
					local tmp_count = string.format("awardCount%s",i - tmp_index)
					local awardCount = _cfg_data[tmp_count]
					if awardID and awardCount ~= 0 then
						image:show()
						image:onClick(self,self.onItemTips,awardID)
						image:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(awardID))
						icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(awardID,i3k_game_context:IsFemaleRole()))
						count:show()
						local tmp_str = string.format("×%s",awardCount)
						count:setText(tmp_str)
					else
						image:hide()
						count:hide()
					end
				end
			end

			for i=1,5 do
				local tmp_star =  string.format("star%s",i)
				local star = _layer.vars[tmp_star]
				if i  > _cfg_data.starLvl then
					star:hide()
				else
					star:show()
				end
			end
			local finish_mark = _layer.vars.finish_mark
			finish_mark:hide()
			local is_starting = _layer.vars.is_starting

			--判断是否正在进行的任务，
			local is_now_task = false
			if roleID == currentRoleID and currentGuid == guid then
				is_now_task = true
			end
			local is_finished = false
			local curren_task_cfg = g_i3k_db.i3k_db_get_faction_task_cfg(currentTaskID)
			if curren_task_cfg then
				is_finished = g_i3k_game_context:IsTaskFinished(curren_task_cfg.type,curren_task_cfg.arg1,curren_task_cfg.arg2,currentTaskValue)
			end
			local go_btn = _layer.vars.go_btn
			local goLabel = _layer.vars.goLabel
			local task_count = _layer.vars.task_count
			task_count:hide()
			go_btn:setTag(_index)

			local quick_root = _layer.vars.quick_finish_root
			local accept_btn = _layer.vars.accept_btn
			local quick_btn = _layer.vars.quick_finish_btn
			local quick_lable = _layer.vars.quick_lable
			local quick_item_icon = _layer.vars.quick_item
			local quick_item_suo = _layer.vars.quick_suo
			local quick_item_count = _layer.vars.quick_count
			local cfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_FACTION)
			accept_btn:setTag(_index)
			quick_btn:setTag(_index)
			if g_i3k_game_context:isCanQuickFinishTask(g_QUICK_FINISH_TASK_TYPE_FACTION, taskID) then
				go_btn:hide()
				quick_root:show()
				accept_btn:onTouchEvent(self, self.onGet)
				quick_btn:onClick(self, self.onQuickFinishTask, g_QUICK_FINISH_TASK_TYPE_FACTION)
				quick_lable:setText("接取")
				quick_item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.needItemId))
				quick_item_suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(cfg.needItemId))
				quick_item_count:setText('x'..cfg.needItemCount)
			else
				quick_root:hide()
			end
			local effect1 = _layer.vars.effect1
			effect1:hide()
			local effect2 = _layer.vars.effect2
			effect2:hide()
			if is_now_task then
				local serverTime = i3k_game_get_time()
				serverTime = i3k_integer(serverTime)
				local have_time = i3k_db_common.faction.share_task_time 
				go_btn:setVisible(not quick_root:isVisible())
				if quick_root:isVisible() then
					quick_lable:setText("放弃")
					accept_btn:onTouchEvent(self, self.onGiveUp)
				end
				if serverTime >= have_time + receiveTime then
					is_starting:show()
					go_btn:onTouchEvent(self,self.onGiveUp)
					goLabel:setText("放弃")
				else
					go_btn:onTouchEvent(self,self.onGiveUp)
					goLabel:setText("放弃")
					if is_finished then
						--go_btn:onTouchEvent(self,self.onFinishTask)
						quick_root:hide()
						get_btn:onTouchEvent(self,self.onFinishTask)
						get_btn:show()
						get_btn:setTag(_index)
						--goLabel:setText("完成")
						go_btn:hide()
						effect1:show()
						effect2:show()
					end
					is_starting:show()
					task_count:show()
					time_label = task_count
					local last_time = have_time + receiveTime - serverTime
					task_count:setText(self:getTimeStrType(last_time))
					time_label:setTextColor(g_i3k_get_cond_color(last_time > _FACTION_TIME_MARK ))
					if not self._task_timer then
						self._task_timer = i3k_game_timer_faction_task.new()
					end
					self._task_timer:onTest()
				end
			else
				go_btn:onTouchEvent(self,self.onGet)
				goLabel:setText("接取")
				is_starting:hide()
			end
			self._task_bank_data[_index] = {taskID = taskID,roleID = roleID,guid = guid,roleName = roleName, isNowTask = is_now_task}
			self.scroll:addItem(_layer)
		end
	end
	local punish_time = g_i3k_game_context:getShareTaskPunishTime()

	if not self._task_timer and punish_time ~= 0 then
		self._task_timer = i3k_game_timer_faction_task.new()
		self._task_timer:onTest()
		self:setShareTaskTime()
	end


end

function wnd_faction_task:getTimeStrType(TimeCount)
	local h = math.modf(TimeCount/3600)
	local m = math.modf((TimeCount - h*3600)/60)
	local s = TimeCount - h*3600 - m*60
	if string.len(h) == 1 then
		h = string.format("%s%s",0,h)
	end
	if string.len(m) == 1 then
		m = string.format("%s%s",0,m)
	end
	if string.len(s) == 1 then
		s = string.format("%s%s",0,s)
	end
	return string.format("%s:%s:%s",h,m,s)
end

function wnd_faction_task:setShareTaskTime()
	local _,_a,receiveTime = g_i3k_game_context:getFactionTaskIdValueTime()
	if time_label and receiveTime then
		local serverTime = i3k_game_get_time()
		serverTime = i3k_integer(serverTime)
		local have_time = i3k_db_common.faction.share_task_time
		local last_time = have_time + receiveTime - serverTime
		if last_time > 0  then
			local tmp_str = self:getTimeStrType(last_time)
			time_label:setText(tmp_str)
			time_label:setTextColor(g_i3k_get_cond_color(last_time > _FACTION_TIME_MARK ))
		else
			--time_label:setText("任务失败")
			time_label = nil
			-- local currentTaskID,currentTaskValue,receiveTime,roleName = g_i3k_game_context:getFactionTaskIdValueTime()
			-- self:updateTaskShareData(g_i3k_game_context:getFactionShareTaskData(),g_i3k_game_context:GetRoleId(),g_i3k_game_context:getFactionTaskRoleId(),g_i3k_game_context:getFactionTaskGuid(),
			-- currentTaskID,currentTaskValue,receiveTime,roleName)
			local data = i3k_sbean.sect_share_task_sync_req.new()
			i3k_game_send_str_cmd(data,i3k_sbean.sect_share_task_sync_res.getName())
			return true
		end
	end

	local punish_time = g_i3k_game_context:getShareTaskPunishTime()
	local time_count = i3k_db_common.faction.share_task_punish_time
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)

	if punish_time ~= 0 then
		if punish_time + time_count > serverTime then
			local last_time = time_count + punish_time - serverTime
			local tmp_str = self:getTimeStrType(last_time)
			tmp_str = string.format("惩罚时间:%s",tmp_str)
			_DESC_STR:setText(tmp_str)
		else
			g_i3k_game_context:setShareTaskPunishTime(0)
		end
	end


end

function wnd_faction_task:onCanGetTask(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self:onHide()
		self.share_btn:stateToNormal(true)
		self.share_btn:show()
		self.task_bank_btn:stateToPressed(true)
		self.task_bank_btn:show()
		self._layout.vars.dragon_task:stateToNormal(true)
		self._layout.vars.dragon_task:show()
		self.canGetTask:stateToPressed()
		self.finished_btn:stateToNormal()
		local currentTaskID,currentTaskValue = g_i3k_game_context:getFactionTaskIdValueTime()
		self:updateTaskBankData(g_i3k_game_context:getFactionTaskBankData(),g_i3k_game_context:GetRoleId(),g_i3k_game_context:GetRoleName(),
		g_i3k_game_context:getFactionTaskRoleId(),g_i3k_game_context:getFactionTaskGuid(),currentTaskID,currentTaskValue)
	end
end

--------------------------------------------------------
function wnd_faction_task:onfinished(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self:onHide()
		self.share_btn:hide()
		self.task_bank_btn:hide()
		self._layout.vars.dragon_task:hide()
		self.canGetTask:stateToNormal()
		self.finished_btn:stateToPressed()
		local data = i3k_sbean.sect_finish_task_sync_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_finish_task_sync_res.getName())
	end
end

function wnd_faction_task:onGetAward(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sect_task_done_rewards_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_task_done_rewards_res.getName())
	end
end

function wnd_faction_task:updateShareTaskAwardPoint()
	self.share_point:setVisible(g_i3k_game_context:GetFactionShareTaskPoint())
	
	if not g_i3k_game_context:GetFactionShareTaskPoint() then
		self.getAward_btn:disableWithChildren()
	else
		self.getAward_btn:enableWithChildren()
	end
end 

function wnd_faction_task:updateGetAwardPoint()
	self.get_award_point:setVisible(g_i3k_game_context:GetFactionShareTaskPoint())
end 

function wnd_faction_task:updateFinishTaskData(_data,my_id)
	_DESC_STR:setText("每日免费刷新时间：17：00；每日重置并刷新任务时间：5：00。")
	self.getAward_btn:show()
	self.getAward_btn:onTouchEvent(self,self.onGetAward)
	self.refresh_btn:hide()
	self:updateShareTaskAwardPoint()
	self.reset_btn:hide()
	self._layout.vars.dragonNode:hide()
	self.moneyRoot:hide()
	self.free_label:hide()
	local share_lvl = i3k_db_common.faction.task_stars[1]
	self.task_count:hide()
	self.task_count_bg:hide()
	self.scrollIcon:show()
	local width = self.scroll:getContentSize().width
	self.scroll:setContainerSize(width,0)
	self.scroll:removeAllChildren()
	self._task_bank_data = {}
	local roleLvl = g_i3k_game_context:GetLevel()
	local level_cfg = g_i3k_db.i3k_db_get_level_cfg(roleLvl)
	for k,v in pairs(_data) do
		local taskID = v.taskID
		local guid = k
		local share = v.shared
		local _layer = require(LAYER_BPRWT)()
		local share_mark = _layer.vars.share_mark
		share_mark:hide()
		local fail_mark = _layer.vars.fail_mark
		fail_mark:hide()
		local darkRoot = _layer.vars.darkRoot
		darkRoot:show()
		local highRoot = _layer.vars.highRoot
		highRoot:hide()
		local task_desc_label = _layer.vars.task_desc_label
		task_desc_label:hide()
		local get_btn = _layer.vars.get_btn
		get_btn:hide()
		local globel_btn = _layer.vars.globel_btn
		local taskIcon = _layer.vars.taskIcon
		local _cfg_data =  g_i3k_db.i3k_db_get_faction_task_cfg(taskID)

		taskIcon:setImage(i3k_db_icons[_cfg_data.icon].path)
		local taskName = _layer.vars.taskName
		taskName:setText(_cfg_data.name)
		local tmp_index = 0
		if _cfg_data.exp ~= 0 then
			tmp_index = 1
			local tmp_image = string.format("image%s",tmp_index)
			local image = _layer.vars[tmp_image]
			local tmp_icon = string.format("icon%s",tmp_index)
			local icon = _layer.vars[tmp_icon]
			local tmp_count = string.format("count%s",tmp_index)
			local count = _layer.vars[tmp_count]
			image:show()
			image:onClick(self,self.onItemTips,g_BASE_ITEM_EXP)
			icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_EXP,i3k_game_context:IsFemaleRole()))
			count:show()
			local tmp_str = string.format("×%s",level_cfg.factionTaskExp * _cfg_data.exp)
			count:setText(tmp_str)
			local cotribution = string.format("x%s",_cfg_data.contribution)
			local factionContribution = i3k_db_kungfu_vip[g_i3k_game_context:GetVipLevel()].factionContribution
			if factionContribution > 1 then
				cotribution = string.format("x%s(双倍)",_cfg_data.contribution*factionContribution)
			end
			_layer.vars.cotribution:setText(cotribution)
		end
		for i=1 + tmp_index, 3 do
			local tmp_image =  string.format("image%s",i)
			local image = _layer.vars[tmp_image]
			local tmp_icon = string.format("icon%s",i)
			local icon = _layer.vars[tmp_icon]
			local tmp_count = string.format("count%s",i)
			local count = _layer.vars[tmp_count]
			if _cfg_data then
				local tmp_id =  string.format("awardID%s",i - tmp_index)
				local awardID = _cfg_data[tmp_id]
				local tmp_count = string.format("awardCount%s",i - tmp_index)
				local awardCount = _cfg_data[tmp_count]
				if awardID and awardCount and awardID ~= 0 then
					image:show()
					image:onClick(self,self.onItemTips,awardID)
					image:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(awardID))
					icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(awardID,i3k_game_context:IsFemaleRole()))
					count:show()
					local tmp_str = string.format("×%s",awardCount)
					count:setText(tmp_str)
				else
					image:hide()
					count:hide()
				end
			end
		end

		for i=1,5 do
			local tmp_star = string.format("star%s",i)
			local star = _layer.vars[tmp_star]
			if i  > _cfg_data.starLvl then
				star:hide()
			else
				star:show()
			end
		end

		local finish_mark = _layer.vars.finish_mark
		finish_mark:hide()

		local is_starting = _layer.vars.is_starting
		is_starting:hide()

		local go_btn = _layer.vars.go_btn
		local goLabel = _layer.vars.goLabel
		local task_count = _layer.vars.task_count

		local is_share = false -- 是否已共享
		if share == 1 then
			is_share = true
		end
		local share_count = v.count
		local max_count = i3k_db_common.faction.share_task_count

		if _cfg_data.starLvl >= share_lvl then
			if not is_share then
				local tmp_str = string.format("剩余次数：%s/%s",share_count,max_count)
				local tmp = {tag = guid,tmp_str = tmp_str}
				go_btn:show()
				go_btn:onClick(self,self.onShareTask,tmp)
				go_btn:setTag(guid)
				--goLabel:setText("共用至帮派")
				task_count:hide()
			else
				--goLabel:setText("已共用")
				task_count:show()
				local tmp_str = string.format("剩余次数：%s/%s",share_count,max_count)
				task_count:setText(tmp_str)
				share_mark:show()
				go_btn:hide()
			end
		else
			go_btn:hide()
			task_count:hide()
			task_desc_label:show()
			task_desc_label:setText(i3k_get_string(17293))
		end
		self._task_bank_data[guid] = {taskID = taskID,roleID = my_id }
		self.scroll:addItem(_layer)
	end
end


function wnd_faction_task:onShareTask(sender,info)
	
	local tag = sender:getTag()
	local data = i3k_sbean.sect_task_issuance_req.new()
	data.sid = tag
	data.updateInfo = info
	i3k_game_send_str_cmd(data,i3k_sbean.sect_task_issuance_res.getName())
	
end

function wnd_faction_task:updateShareTaskInfo(info)
	local allLayer = self.scroll:getAllChildren()
	
	for i,v in ipairs(allLayer) do
		if v.vars.go_btn:getTag() == info.tag then
			v.vars.go_btn:hide()
			v.vars.task_count:show()
			v.vars.task_count:setText(info.tmp_str)
			v.vars.share_mark:show()
		end
	end
end

--龙穴任务
function wnd_faction_task:onDragonTask(sender)
	i3k_sbean.dragon_hole_task_sync()
end

function wnd_faction_task:updateDrangonHoleTask(info)
	g_i3k_game_context:setDragonTaskScore(info.score)
	self._dragon_timer = {}
	_DESC_STR:setText(i3k_get_string(16970, i3k_db_dragon_hole_cfg.refreshTime[1], i3k_db_dragon_hole_cfg.refreshTime[2]))
	_DESC_STR2:setText(i3k_get_string(18148, g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_LONGXUE).needActivity))
	self.dayRefreshTimes = info.dayRefreshTimes
	self.weekFinishTime = info.weekFinishTime
	self.score = info.score
	self.scrollIcon:hide()
	self._layout.vars.dragonNode:show()
	self._layout.vars.faction_point:setText(info.sectScore)
	self._layout.vars.my_point:setText(info.score)
	self._layout.vars.rule_desc:hide()
	self.canGetTask:hide()
	self.finished_btn:hide()
	self._layout.vars.task_count:setText(string.format("本周已完成：%s/%s", info.weekFinishTime, i3k_db_dragon_hole_cfg.maxTaskWeekly))
	self._layout.vars.scroll2:removeAllChildren()
	self.share_btn:stateToNormal(true)
	self.task_bank_btn:stateToNormal(true)
	self._layout.vars.dragon_task:stateToPressed(true)
	if not info then
		return
	end
	self.getAward_btn:hide()
	self.share_point:hide()
	self.refresh_btn:hide()
	self.reset_btn:show()
	self.free_label:hide()
	self.moneyRoot:show()
	self.moneyCount:show()
	self.moneyRoot:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_dragon_hole_cfg.refreshItemId, g_i3k_game_context:IsFemaleRole()))
	self.moneyRoot:onClick(self, self.onItemTips, i3k_db_dragon_hole_cfg.refreshItemId)
	self._layout.vars.awardBtn:onClick(self, self.onAwardBtn)
	
	self._layout.vars.rule_scroll:removeAllChildren()
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		local textNode = require("ui/widgets/ggt1")()
		textNode.vars.text:setText(i3k_get_string(16976, g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_LONGXUE).needActivity))
		ui._layout.vars.rule_scroll:addItem(textNode)
		g_i3k_ui_mgr:AddTask(self, {textNode}, function(ui)
			local textUI = textNode.vars.text
			local size = textNode.rootVar:getContentSize()
			local height = textUI:getInnerSize().height
			local width = size.width
			height = size.height > height and size.height or height
			textNode.rootVar:changeSizeInScroll(ui._layout.vars.rule_scroll, width, height, true)
		end, 1)
	end, 1)
	
	local needCount = 0
	if self.dayRefreshTimes + 1 > #i3k_db_dragon_hole_cfg.refreshItemCount then
		needCount = i3k_db_dragon_hole_cfg.refreshItemCount[#i3k_db_dragon_hole_cfg.refreshItemCount]
	else
		needCount = i3k_db_dragon_hole_cfg.refreshItemCount[self.dayRefreshTimes + 1]
	end
	self.moneyCount:setText("x"..needCount)
	self.reset_btn:onClick(self, self.onRefreshDragonTask, {id = i3k_db_dragon_hole_cfg.refreshItemId, count = needCount, time = self.dayRefreshTimes + 1})
	
	local finished = {}
	local unfinished = {}
	for k, v in ipairs(g_i3k_game_context:GetAcceptDragonHoleTask()) do
		local cfg = g_i3k_db.i3k_db_get_dragon_task_cfg(v.id)
		local isFinished = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, v.value)
		if isFinished then
			finished[v.id] = true
		else
			unfinished[v.id] = true
		end
	end
	self:addDragonTaskItem(finished, true)
	self:addDragonTaskItem(unfinished, true)
	self:addDragonTaskItem(info.curTaskLib, false)
	if table.nums(self._dragon_timer) > 0 then
		self:setDragonTaskTime()
	end
end

function wnd_faction_task:addDragonTaskItem(taskList, isAccept)
	for k, v in pairs(taskList) do
		local _cfg_data = g_i3k_db.i3k_db_get_dragon_task_cfg(k)
		local currentTask, got= g_i3k_game_context:isAcceptDragonHoleTask(k)
		local isCanQuickFinishTask = g_i3k_game_context:isCanQuickFinishTask(g_QUICK_FINISH_TASK_TYPE_LONGXUE, k)
		local currentTaskValue = currentTask.value
		local isHaveDone = false
		local isValid
		if isAccept and got then
			isValid = g_i3k_db.i3k_db_is_valid_dragon_task(currentTask.receiveTime)
			local isFinished = g_i3k_game_context:IsTaskFinished(_cfg_data.type, _cfg_data.arg1, _cfg_data.arg2, currentTaskValue)
			if isValid and isFinished then
				isHaveDone = true
			end
		end
		local _layer = require((not isHaveDone and isCanQuickFinishTask) and LAYER_BPRWT2F or LAYER_BPRWT2)()
		_layer.vars.taskIcon:setImage(g_i3k_db.i3k_db_get_icon_path(_cfg_data.icon))
		_layer.vars.taskName:setText(_cfg_data.name)
		--积分
		--_layer.vars.image1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path())
		_layer.vars.image1:show()
		_layer.vars.image1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(66896))
		_layer.vars.image1:onClick(self, self.onItemTips, 66896)
		_layer.vars.icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(66896, g_i3k_game_context:IsFemaleRole()))
		local ctype = g_i3k_game_context:GetRoleType()
		local tmp_str = string.format("x%s", _cfg_data.partRate[ctype] * _cfg_data.awardPoint)
		_layer.vars.count1:setText(tmp_str)
		--龙晶
		local awardCount = _cfg_data.dragonCrystal
		_layer.vars.image3:show()
		_layer.vars.image3:onClick(self, self.onItemTips, 67400)
		_layer.vars.count3:show()
		_layer.vars.count3:setText("x"..awardCount)
		--铜钱
		local awardID = _cfg_data.awardID1
		local awardCount = _cfg_data.awardCount1
		_layer.vars.image2:show()
		_layer.vars.image2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(awardID))
		_layer.vars.image2:onClick(self, self.onItemTips, awardID)
		_layer.vars.icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(awardID, g_i3k_game_context:IsFemaleRole()))
		_layer.vars.count2:show()
		_layer.vars.count2:setText("x"..awardCount)
		--星星
		for i=1,5 do
			local star = _layer.vars["star"..i]
			if i  > _cfg_data.starLvl then
				star:hide()
			else
				star:show()
			end
		end
		local go_btn = _layer.vars.go_btn
		local quick_finish_btn = _layer.vars.quick_finish_btn
		local goLabel = _layer.vars.goLabel
		local get_btn = _layer.vars.get_btn
		local task_count = _layer.vars.task_count
		local effect1 = _layer.vars.effect1
		local effect2 = _layer.vars.effect2
		_layer.vars.fail_mark:hide()
		task_count:hide()
		effect1:hide()
		effect2:hide()
		if get_btn then
			get_btn:hide()
		end
		go_btn:onClick(self, self.acceptDragonHoleTask, k)
		if quick_finish_btn then
			quick_finish_btn:setTag(k)
			quick_finish_btn:onClick(self, self.onQuickFinishTask, g_QUICK_FINISH_TASK_TYPE_LONGXUE)
		end
		goLabel:setText("接取")
		_layer.vars.is_starting:hide()
		if got and isAccept then
			_layer.vars.darkRoot:hide()
			_layer.vars.highRoot:show()
			currentTaskValue = currentTask.value
			if isHaveDone and isValid then
				get_btn:onClick(self, self.onFinishDragonTask, k)
				get_btn:show()
				go_btn:hide()
				effect1:show()
				effect2:show()
				_layer.vars.is_starting:hide()
			else
				go_btn:onClick(self, self.abandonDragonHoleTask, k)
				goLabel:setText("放弃")
				_layer.vars.is_starting:show()
				if isValid then
					task_count:show()
					task_count:setText(self:getTimeStrType(isValid))
					if not (self._dragon_timer and self._dragon_timer[k]) then
						local timeCounter = i3k_game_timer_faction_task.new()
						timeCounter:onTest()
						self._dragon_timer[k] = {timeCounter = timeCounter, label = task_count}
					end
				else
					_layer.vars.fail_mark:show()
					if quick_finish_btn then
						quick_finish_btn:setTag(0)
					end
				end
			end
		end
		self._layout.vars.scroll2:addItem(_layer)
	end
end

function wnd_faction_task:acceptDragonHoleTask(sender, id)
	local task = g_i3k_game_context:GetAcceptDragonHoleTask()
	local _, isGot = g_i3k_game_context:isAcceptDragonHoleTask(id)
	if #task >= i3k_db_dragon_hole_cfg.maxTaskOnce then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16981))
	elseif self.weekFinishTime + #task >= i3k_db_dragon_hole_cfg.maxTaskWeekly then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16981))
	elseif g_i3k_game_context:GetLevel() < i3k_db_dragon_hole_cfg.level then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16971))
	elseif not g_i3k_db.i3k_db_is_in_dragon_task_time() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16980))
	elseif isGot then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16977))
	else
		local isClose = false
		if #task == i3k_db_dragon_hole_cfg.maxTaskOnce - 1 or self.weekFinishTime + #task == i3k_db_dragon_hole_cfg.maxTaskWeekly - 1 then
			isClose = true
		end
		i3k_sbean.dragon_hole_task_take(id, isClose)
	end
end

function wnd_faction_task:abandonDragonHoleTask(sender, id)
	local callback = function (isOk)
		if isOk then
			i3k_sbean.dragon_hole_task_giveup(id)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16973), callback)
end

function wnd_faction_task:onFinishDragonTask(sender, id)
	--判断时效
	if not g_i3k_db.i3k_db_is_in_dragon_task_time() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16980))
		i3k_sbean.dragon_hole_task_sync()
	else
		i3k_sbean.dragon_hole_task_reward(id)
	end
end

function wnd_faction_task:onRefreshDragonTask(sender, item)
	if  g_i3k_game_context:GetLevel() < i3k_db_dragon_hole_cfg.level then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16971))
	elseif g_i3k_game_context:GetCommonItemCanUseCount(item.id) < item.count then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16972))
	elseif not g_i3k_db.i3k_db_is_in_dragon_task_time() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16980))
	else
		if g_i3k_game_context:IsExcNeedShowTip(g_DRAGON_TASK_REFRESH) then
			g_i3k_ui_mgr:OpenUI(eUIID_Today_Tip)
			g_i3k_ui_mgr:RefreshUI(eUIID_Today_Tip, g_DRAGON_TASK_REFRESH, item)
		else 	
	       i3k_sbean.dragon_hole_task_refresh(item)
		end
	end
end

function wnd_faction_task:setDragonTaskTime()
	local dragon_timer = self._dragon_timer
	for k, v in pairs(dragon_timer) do
		local acceptTask, isGot = g_i3k_game_context:isAcceptDragonHoleTask(k)
		if isGot then
			local leftTime = g_i3k_db.i3k_db_is_valid_dragon_task(acceptTask.receiveTime)
			if leftTime then
				v.label:setText(self:getTimeStrType(leftTime))
			else
				self._dragon_timer[k] = nil
				i3k_sbean.dragon_hole_task_sync()
			end
		else
			self._dragon_timer[k] = nil
		end
	end
end

function wnd_faction_task:onAwardBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_DragonHoleAward)
	g_i3k_ui_mgr:RefreshUI(eUIID_DragonHoleAward)
end


function wnd_faction_task:onHide()
	if self._task_timer then
		self._task_timer:CancelTimer()
		time_label = nil
		self._task_timer = nil
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_faction_task.new();
		wnd:create(layout, ...);

	return wnd;
end



local TIMER = require("i3k_timer");
i3k_game_timer_faction_task = i3k_class("i3k_game_timer_faction_task", TIMER.i3k_timer);

function i3k_game_timer_faction_task:Do(args)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionTask,"setShareTaskTime")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionTask,"setDragonTaskTime")
end

function i3k_game_timer_faction_task:onTest()
	local logic = i3k_game_get_logic()
	if logic then
		self._timer = logic:RegisterTimer(i3k_game_timer_faction_task.new(1000));

	end
end

function i3k_game_timer_faction_task:CancelTimer()
	local logic = i3k_game_get_logic();
	if logic and self._timer then
		logic:UnregisterTimer(self._timer);
	end
end
