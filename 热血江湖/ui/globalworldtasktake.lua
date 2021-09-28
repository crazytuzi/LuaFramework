module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------

wnd_globalWorldTaskTake = i3k_class("wnd_globalWorldTaskTake", ui.wnd_base)

local SJRWJLT_WIDGET = "ui/widgets/sjrwjlt"


function wnd_globalWorldTaskTake:ctor()
	self.taskID = 0
	self.normalItems = {}
	self.superItems = {}
	self.superItemIsEnough = true
end

function wnd_globalWorldTaskTake:configure()
	local widget = self._layout.vars
	self.normalScroll = widget.normalScroll
	self.superScroll = widget.superScroll
	self.super_icon = widget.super_icon
	self.super_count = widget.super_count
	self.expCount1 = widget.expCount1
	self.expCount2 = widget.expCount2
	widget.closeBtn:onClick(self,self.onCloseUI)
	widget.normalSend:onClick(self, self.onTakeClick, 0)
	widget.superSend:onClick(self, self.onTakeClick, 1)
	widget.super_btn:onClick(self, self.onSuperBtnClick)

end

function wnd_globalWorldTaskTake:onTakeClick(sender, isSpecial)
	local items = self.normalItems
	local id = i3k_db_war_zone_map_task[self.taskID].superItemId
	if isSpecial == 1 then
		if not self.superItemIsEnough then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5777,g_i3k_db.i3k_db_get_common_item_name(id)))
			return
		end
		items = self.superItems
	end
	i3k_sbean.takeGlobalWorldTaskReward(self.taskID, isSpecial, items)
end


function wnd_globalWorldTaskTake:updateRewardData(taskID)
	self.taskID = taskID and taskID or self.taskID
	self.normalItems, self.superItems = g_i3k_db.i3k_db_get_globalWorldTask_rewardLists(self.taskID)
	self:setRewardData(self.normalScroll, self.normalItems, self.expCount1)
	self:setRewardData(self.superScroll, self.superItems, self.expCount2)
	self.super_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_war_zone_map_task[self.taskID].superItemId,i3k_game_context:IsFemaleRole()))
	self.super_count:setText("x"..(i3k_db_war_zone_map_task[self.taskID].superItemCount))

	local id = i3k_db_war_zone_map_task[self.taskID].superItemId
	local have = g_i3k_game_context:GetCommonItemCanUseCount(id)
	local cfg = i3k_db_war_zone_map_task[self.taskID]
	self.superItemIsEnough = have >= cfg.superItemCount
	local color = self.superItemIsEnough and g_i3k_get_green_color() or g_i3k_get_red_color()
	self.super_count:setTextColor(color)
end

function wnd_globalWorldTaskTake:setRewardData(scroll, list, expCount)
	scroll:removeAllChildren()
	for i, e in pairs(list) do
		local id = e.id 
		if id == g_BASE_ITEM_EXP then
			expCount:setText("x"..i3k_get_num_to_show(e.count))
		else
			local _layer = require(SJRWJLT_WIDGET)()
			local widget = _layer.vars
			widget.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
			widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
			widget.item_count:setText("x"..e.count)
			widget.suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(id))
			--widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
			--widget.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
			widget.item_btn:onClick(self, self.onItemInfo, id)
			scroll:addItem(_layer)
		end
		
	end
end


function wnd_globalWorldTaskTake:onItemInfo(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

function wnd_globalWorldTaskTake:onSuperBtnClick()
	local id = i3k_db_war_zone_map_task[self.taskID].superItemId
	if id then
		g_i3k_ui_mgr:ShowCommonItemInfo(id)
	end
end


function wnd_create(layout)
	local wnd = wnd_globalWorldTaskTake.new();
		wnd:create(layout);
	return wnd;
end