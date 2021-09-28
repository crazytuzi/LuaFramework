-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_petWakenTask3 = i3k_class("wnd_petWakenTask3",ui.wnd_base)
local LAYER_SCLBT = "ui/widgets/jxrw3t"
local BtnType1 = 1;
local BtnType2 = 2;
function wnd_petWakenTask3:ctor()
	self._topDes = {}
	self._items = {};
	self._part1Items = {}
end

function wnd_petWakenTask3:configure(...)
	local widgets	= self._layout.vars
	self.name		= widgets.name;
	self.icon		= widgets.icon;
	self.iconBg		= widgets.iconBg;
	self.stepDes	= widgets.stepDes;
	self.stepBtn	= widgets.stepBtn;
	self.cancelBtn	= widgets.cancelBtn
	self.topDes		= widgets.topDes;
	self.okBtn		= widgets.okBtn
	self.scroll		= widgets.scroll;
	self.taskDes	= widgets.taskDes;
	self.achieveTxt	= widgets.achieveTxt
	for i = 1,3 do
		self._topDes[i]		= widgets["topDes"..i];
	end
	widgets.closeBtn:onClick(self, self.onCloseUI)	
	widgets.cancelBtn:onClick(self, self.onCancelBtn)
end

function wnd_petWakenTask3:refresh(id)
	self:updateDate(id)
	self:updateScroll(id)
end

function wnd_petWakenTask3:onAchieveBtn(sender, btnType)
	if btnType == BtnType1 and self._task then
		if g_i3k_game_context:getFieldPetID() == self._id then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16827))
		else
			if self:isCanAchieve() and self._id > 0 then
				i3k_sbean.awakeTaskSubmitItem(self._id, self._items, self._part1Items)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16834))
			end
		end
	elseif btnType == BtnType2 and self._id > 0 then
		if g_i3k_game_context:getFieldPetID() == self._id then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16827))
		else
			i3k_sbean.awakeTaskFinish(self._id, g_TaskType3)
		end
	end
end	

function wnd_petWakenTask3:onCancelBtn(sender)
	if self._id > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenGiveUp)
		g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenGiveUp, g_TaskType3)
	end
end	

function wnd_petWakenTask3:isCanAchieve()
	local item = self:getItemDate();
	local items = {}
	self._part1Items = {}
	if item then
		for i,e in ipairs(item) do
			local UseCount = g_i3k_game_context:GetCommonItemCanUseCount(e.needItemID)
			if i == 1 then
				local commonId = item.replaceItem1Id
				local commonHave = g_i3k_game_context:GetCommonItemCanUseCount(commonId)
				if commonHave + UseCount < e.needItemCount then
					return false
				end
				table.insert(items, {needItemID = e.needItemID, needItemCount = math.min(e.needItemCount, UseCount)})
				self._part1Items[e.needItemID] = items[#items].needItemCount ~= 0 and items[#items].needItemCount or nil
				table.insert(items, {needItemID = commonId, needItemCount = math.max(0, e.needItemCount - UseCount)})
				self._part1Items[commonId] = items[#items].needItemCount ~= 0 and items[#items].needItemCount or nil
			else
			if e.needItemID > 0 then
				if UseCount >= e.needItemCount then
					table.insert(items, e);
					else
						return false
					end
				end
			end
		end
			self._items = items;
			return true;
	end
	return false;
end	


function wnd_petWakenTask3:getItemDate()
	local task = g_i3k_game_context:getPetWakenTask(self._id)
	if task and task.taskArg and task.taskArg.Arg1 > 0 then
		return i3k_db_pet_waken_item[task.taskArg.Arg1];
	end
	return false;
end

function wnd_petWakenTask3:updateScroll(id)
	local item = self:getItemDate(); 
	if item then
		self.scroll:removeAllChildren()
		local firstItemCountTextNode, firstItemCount, firstItemNeedCount
		for i, e in ipairs(item) do
			if e.needItemID > 0 then
				local node = require(LAYER_SCLBT)()
				local widget = node.vars
				local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.needItemID))
				widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.needItemID,i3k_game_context:IsFemaleRole()))
				widget.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.needItemID))
				if e.needItemID == g_BASE_ITEM_DIAMOND or e.needItemID == g_BASE_ITEM_COIN then
					widget.item_count:setText(needItemCount)
				else
					widget.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.needItemID) .."/".. e.needItemCount)
				end
				widget.tip:setVisible(i == 1)
				widget.tip:setText("优先消耗")
				if i == 1 then
					firstItemCountTextNode = widget.item_count
					firstItemCount = g_i3k_game_context:GetCommonItemCanUseCount(e.needItemID)
					firstItemNeedCount = e.needItemCount
				end
				widget.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.needItemID) >= e.needItemCount))
				widget.bt:onClick(self, self.onItemTips, e.needItemID);
				self.scroll:addItem(node)
			end
			if i == 1 then
				--添加代替道具
				local node = require(LAYER_SCLBT)()
				local widget = node.vars
				local commonId = item.replaceItem1Id
				local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(commonId))
				widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(commonId, i3k_game_context:IsFemaleRole()))
				widget.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(commonId))
				widget.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(commonId))
				local color = g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(commonId) + firstItemCount >= firstItemNeedCount)
				firstItemCountTextNode:setTextColor(color)
				widget.item_count:setTextColor(color)
				widget.tip:show()
				widget.tip:setText("次要消耗")
				widget.bt:onClick(self, self.onItemTips, commonId);
				self.scroll:addItem(node)
				--添加加号
				local node = require(LAYER_SCLBT)()
				local widget = node.vars
				widget.item_icon:hide()
				widget.icon_bg:hide()
				widget.jia:show()
				self.scroll:addItem(node)
			end
		end
	end
end

function wnd_petWakenTask3:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_petWakenTask3:onStepBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenStep)
	g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenStep)
end	

function wnd_petWakenTask3:updateDate(id)
	local cfg_data = g_i3k_db.i3k_db_get_pet_cfg(id);
	local task = g_i3k_game_context:getPetWakenTask(id)
	if cfg_data and task then
		self._id = id;
		self._task = task;
		self.topDes:setText("第三步："..task.taskName);
		self.taskDes:setText(task.teskDes1);
		self.name:setText(cfg_data.name)
		self.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(cfg_data.icon, true))
		self.iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[id].rank))
		for i,e in ipairs(i3k_db_mercenariea_waken_task[id]) do
			self._topDes[i]:setText(e.taskName);
		end
		self:updateTaskState()
	end
end

function wnd_petWakenTask3:updateTaskState()
	if self._task then
		local state = g_i3k_game_context:getPetWakenTaskState(self._id);
		if state == g_TaskState2 then
			self.achieveTxt:setText("完成");
			self.okBtn:onClick(self, self.onAchieveBtn, BtnType2)
		else
			self.achieveTxt:setText("提交");
			self.okBtn:onClick(self, self.onAchieveBtn, BtnType1)	
		end	
	end
end

function wnd_create(layout)
	local wnd = wnd_petWakenTask3.new()
	wnd:create(layout)
	return wnd
end
