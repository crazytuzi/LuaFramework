module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_fiveTrans = i3k_class("wnd_fiveTrans", ui.wnd_base)

local TYPE_TRANS =  1 -- 接取中，需要完成五转，无提交道具类型
local TYPE_COMMIT = 2 -- 接取中，不需要五转，有提交道具
local TYPE_UNKNOW = 3 -- 未接取  灰色
local TYPE_DONE   = 4 -- 完成状态


local TASK_STATE_DONE           = 0 -- 完成
local TASK_STATE_UNFINISHED 	= 1 -- 类型1，任务未完成
local TASK_STATE_SUBTASK_UNDONE = 2 -- 前提条件未完成
local TASK_STATE_ITEMS 			= 3	-- 所需提交物品不足

local TASK_STATE_TEXT =
{
	[TASK_STATE_UNFINISHED] 	= i3k_get_string(1368), -- "任务未完成",
	[TASK_STATE_SUBTASK_UNDONE] = i3k_get_string(1369), -- "前提条件未完成",
	[TASK_STATE_ITEMS] 			= i3k_get_string(1370), -- "所需提交物品不足",
}

local str_finished = i3k_get_string(1371)  -- 已完成
local str_unfinished = i3k_get_string(1372) -- 未完成

function wnd_fiveTrans:ctor()

end

function wnd_fiveTrans:configure()
	self._layout.vars.close:onClick(self,self.onCloseUI)
end

function wnd_fiveTrans:onShow()
	self._CONFIG =
	{
		[TYPE_TRANS]   = { ui = "ui/widgets/wzzlt2", func = wnd_fiveTrans.setUI_typeTrans},
		[TYPE_COMMIT]  = { ui = "ui/widgets/wzzlt3", func = wnd_fiveTrans.setUI_typeCommit},
		[TYPE_UNKNOW]  = { ui = "ui/widgets/wzzlt1", func = wnd_fiveTrans.setUI_typeUnknow},
		[TYPE_DONE]    = { ui = "ui/widgets/wzzlt1", func = wnd_fiveTrans.setUI_typeDone},
	}
end

function wnd_fiveTrans:refresh()
	self:updateScroll()
end

function wnd_fiveTrans:updateScroll()
	local fiveTrans = g_i3k_game_context:getFiveTrans()
	local curLevel = fiveTrans.level + 1 -- TODO
	local scroll = self._layout.vars.scroll
	self._scrollPercent = scroll:getListPercent()
	scroll:removeAllChildren()
	if curLevel > #i3k_db_five_trans then
		local ui = require("ui/widgets/wzzlt4")() -- 圆满 加在最前面
		scroll:addItem(ui)
	end
	for i, v in ipairs(i3k_db_five_trans) do
		if i == curLevel and curLevel ~= #i3k_db_five_trans + 1 then
			local ui = require("ui/widgets/wzzlt1")()
			self:setUI_typeUnknow(i, ui)
			scroll:addItem(ui)
		end
		local ui = self:getScrollItem(i)
		scroll:addItem(ui)
	end
	scroll:jumpToListPercent(self._scrollPercent)
end

-- private method 当前正在执行的类型，只有2种可能
function wnd_fiveTrans:getDoingStateType(index)
	local cfg = i3k_db_five_trans[index]
	assert(cfg ~= nil, "index "..index.." cfg not found")

	if cfg.isNeedFiveTrans == 0 then
		return TYPE_COMMIT
	end

	return TYPE_TRANS
end

-- 根据当前处在哪个等级，返回对应的类型
function wnd_fiveTrans:getCurStateType(index)
	local fiveTrans = g_i3k_game_context:getFiveTrans()
	local curLevel = fiveTrans.level + 1 -- TODO
	if curLevel == index then -- 当前的任务
		return self:getDoingStateType(index)
	end
	if index < curLevel then -- 完成的
		return TYPE_DONE
	end

	if curLevel < index then -- 未完成的任务
		return TYPE_UNKNOW
	end
end

function wnd_fiveTrans:getScrollItem(index)
	local type = self:getCurStateType(index)
	local uiName = self._CONFIG[type].ui
	local ui = require(uiName)()
	local func = self._CONFIG[type].func
	func(self, index, ui)

	return ui
end

-- wzzlt2
function wnd_fiveTrans:setUI_typeTrans(index, ui)
	local cfg = i3k_db_five_trans[index]
	local subTaskName = g_i3k_db.i3k_db_get_sub_task_last_task_name(cfg.subTaskID)
	local taskfinished = g_i3k_game_context:getSubLineTaskIsFinishedByID(cfg.subTaskID)
	local str1 = taskfinished and str_finished or str_unfinished
	local text1 = i3k_get_string(1373, subTaskName)..str1

	local transfromLvl = g_i3k_game_context:GetTransformLvl()
	local str2 = transfromLvl >= cfg.isNeedFiveTrans and str_finished or str_unfinished
	local text2 = i3k_get_string(1374, cfg.isNeedFiveTrans)..str2
	-- ui.vars.taskName:setText(cfg.name)
	ui.vars.des1:setText(text1)
	ui.vars.des1:setTextColor(g_i3k_get_cond_color(taskfinished))
	ui.vars.img1:setImage(taskfinished and g_i3k_db.i3k_db_get_icon_path(6145) or g_i3k_db.i3k_db_get_icon_path(6144))
	ui.vars.des2:setText(text2)
	ui.vars.des2:setTextColor(g_i3k_get_cond_color(transfromLvl >= 5))
	ui.vars.img2:setImage(transfromLvl >= 5 and g_i3k_db.i3k_db_get_icon_path(6145) or g_i3k_db.i3k_db_get_icon_path(6144))
	local data = {index = index, done = ((not (transfromLvl >= 5) or not taskfinished) and TASK_STATE_UNFINISHED) }
	ui.vars.finish:onClick(self, self.onFinishTask, data)
end

-- wzzlt1
function wnd_fiveTrans:setUI_typeUnknow(index, ui)
	local cfg = i3k_db_five_trans[index]
	ui.vars.taskName:setText(cfg.name)

	ui.vars.des:setText(cfg.desc)
	local fiveTrans = g_i3k_game_context:getFiveTrans()
	ui.vars.doneImg:setVisible(fiveTrans.level >= index)
	if fiveTrans.level >= index then
		ui.vars.taskName:setTextColor("FFCC440E")
		ui.vars.des:setTextColor("FFFF4901")
	end
	ui.vars.iconBase:setImage(fiveTrans.level >= index and g_i3k_db.i3k_db_get_icon_path(6142) or g_i3k_db.i3k_db_get_icon_path(6143))
	if #cfg.rewards == 0 then -- 配置的头像个数大于0
		ui.vars.bgRoot:hide()
	else
		local iconID = g_i3k_db.i3k_db_get_five_trans_headicon(index)
		ui.vars.bgRoot:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(iconID))
		ui.vars.headIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(iconID))
		ui.vars.count:setText("x"..cfg.rewardCount)
		ui.vars.headBtn:onClick(self, self.onItemTips, iconID)
		ui.vars.lock:setVisible(iconID > 0)
	end
end

-- wzzlt3
function wnd_fiveTrans:setUI_typeCommit(index, ui)
	local cfg = i3k_db_five_trans[index]
	ui.vars.acceptBtn:onClick(self, self.onAcceptTask, index)
	ui.vars.acceptBtn:setVisible(not g_i3k_game_context:getSubLineTaskIsAccepted(cfg.subTaskID))
	local subTaskName = g_i3k_db.i3k_db_get_sub_task_last_task_name(cfg.subTaskID)
	local taskfinished = g_i3k_game_context:getSubLineTaskIsFinishedByID(cfg.subTaskID)
	local str1 = taskfinished and str_finished or str_unfinished
	local text1 = i3k_get_string(1373, subTaskName)..str1
	ui.vars.img1:setImage(taskfinished and g_i3k_db.i3k_db_get_icon_path(6145) or g_i3k_db.i3k_db_get_icon_path(6144))
	ui.vars.des:setText(text1)
	ui.vars.des:setTextColor(g_i3k_get_cond_color(taskfinished))
	local itemsCondition = true
	for i = 1, 3 do
		local itemCfg = cfg.commitItems[i]
		if itemCfg then
			ui.vars["bg"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemCfg.id))
			ui.vars["icon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemCfg.id))
			ui.vars["lock"..i]:setVisible(itemCfg.id > 0)
			local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(itemCfg.id)
			if math.abs(itemCfg.id) == g_BASE_ITEM_COIN then
				ui.vars["count"..i]:setText(i3k_get_num_to_show(itemCfg.count))
			else
				ui.vars["count"..i]:setText(i3k_get_num_to_show(haveCount).."/"..i3k_get_num_to_show(itemCfg.count))
			end

			ui.vars["count"..i]:setTextColor(g_i3k_get_cond_color(haveCount >= itemCfg.count))
			if haveCount < itemCfg.count then
				itemsCondition = false
			end
			ui.vars["btn"..i]:onClick(self, self.onItemTips, itemCfg.id)
		else
			ui.vars["bg"..i]:hide()
		end
	end
	local done = nil
	if not itemsCondition then
		done = TASK_STATE_ITEMS
	end
	if not taskfinished then
		done = TASK_STATE_SUBTASK_UNDONE
	end

	local data = {index = index, done = done }
	ui.vars.finishBtn:onClick(self, self.onFinishTask, data)
end


-- wzzlt1
function wnd_fiveTrans:setUI_typeDone(index, ui)
	local cfg = i3k_db_five_trans[index]
	ui.vars.taskName:setText(cfg.name)
	ui.vars.des:setText(cfg.desc)
	local fiveTrans = g_i3k_game_context:getFiveTrans()
	ui.vars.doneImg:setVisible(fiveTrans.level >= index)
	if fiveTrans.level >= index then
		ui.vars.taskName:setTextColor("FFCC440E")
		ui.vars.des:setTextColor("FFFF4901")
	end
	ui.vars.iconBase:setImage(fiveTrans.level >= index and g_i3k_db.i3k_db_get_icon_path(6142) or g_i3k_db.i3k_db_get_icon_path(6143))
	if #cfg.rewards == 0 then -- 配置的头像个数大于0
		ui.vars.bgRoot:hide()
	else
		local iconID = g_i3k_db.i3k_db_get_five_trans_headicon(index)
		ui.vars.bgRoot:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(iconID))
		ui.vars.headIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(iconID))
		ui.vars.count:setText("x"..cfg.rewardCount)
		ui.vars.headBtn:onClick(self, self.onItemTips, iconID)
	end
end

function wnd_fiveTrans:popUpErrorMessage(id)
	local text = TASK_STATE_TEXT[id]
	if text then
		g_i3k_ui_mgr:PopupTipMessage(text)
	end
end

-- 完成任务
function wnd_fiveTrans:onFinishTask(sender, data)
	-- g_i3k_ui_mgr:PopupTipMessage("index"..index)
	if data.done and data.done ~= TASK_STATE_DONE then
		self:popUpErrorMessage(data.done)
		return
	end

	local iconID = g_i3k_db.i3k_db_get_five_trans_headicon(data.index)
	local count = i3k_db_five_trans[data.index].rewardCount
	if iconID then
		local item = {}
		item[iconID] = count
		local enough = g_i3k_game_context:IsBagEnough(item)
		if not enough then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16372))
			return
		end
	end
	i3k_sbean.fiveTransUpLevel(data.index)
end


-- 接取任务
function wnd_fiveTrans:onAcceptTask(sender, index)
	local cfg = i3k_db_five_trans[index]
	local callback = function()
		g_i3k_game_context:addSubLineData(cfg.subTaskID, 1, 0, 0)
		local isexit = g_i3k_game_context:AddTaskToDataList(g_i3k_db.i3k_db_get_subline_task_hash_id(cfg.subTaskID))
		if not isexit then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateSublineTask", cfg.subTaskID, 1)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_fiveTrans)
		g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1375))
	end

	i3k_sbean.branch_task_receive(cfg.subTaskID, true, callback)
end

function wnd_fiveTrans:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_create(layout, ...)
	local wnd = wnd_fiveTrans.new();
		wnd:create(layout, ...);
	return wnd;
end
