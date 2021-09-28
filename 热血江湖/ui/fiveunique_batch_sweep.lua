-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_fiveUnique_batch_sweep = i3k_class("wnd_fiveUnique_batch_sweep", ui.wnd_base)

local WIDGET_XGT = "ui/widgets/wjxgt"
local RowitemCount = 5 --每行个数

function wnd_fiveUnique_batch_sweep:ctor()
	self.state = 1
	self.times = 0
	self.info = {}
	self.isSelect = {}
end

function wnd_fiveUnique_batch_sweep:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
end

function wnd_fiveUnique_batch_sweep:refresh(info, floor)
	self.info = info
	self.times = i3k_db_climbing_tower_args.maxattackTimes + info.dayTimesBuy - info.dayTimesUsed
	local widget = self._layout.vars
	for i = 1, #i3k_db_climbing_tower do
		widget["titleBtn"..i]:onClick(self, self.changeState, i)
		widget["titleText"..i]:setText(i3k_db_climbing_tower[i].name)
	end
	self:setButtons(1)
	widget.batchBtn:onClick(self, self.onBatchSweepBtn, floor)
end

function wnd_fiveUnique_batch_sweep:changeState(sender, state)
	if state ~= self.state then
		self.state = state
		self:setButtons(state)
	end
end

function wnd_fiveUnique_batch_sweep:setButtons(state)
	for i = 1, #i3k_db_climbing_tower do
		self._layout.vars["titleBtn"..i]:stateToNormal(true)
	end
	self._layout.vars["titleBtn"..state]:stateToPressed(true)
	self._layout.vars.scroll:removeAllChildren()
	local history = self.info.history[self.state]
	if history then
		local children = self._layout.vars.scroll:addChildWithCount(WIDGET_XGT, RowitemCount, history)
		for k, v in ipairs(children) do
			v.vars.lvlLabel:setText(string.format("第%s关", k))
			v.vars.btn:setTag(k)
			if self:isChallenged(k) then
				v.vars.btn:disableWithChildren()
				v.vars.sharder:disableWithChildren()
				v.vars.selected:hide()
			else
				v.vars.btn:enableWithChildren()
				v.vars.btn:onClick(self, self.select, v)
				if self:isSelected(k) then
					v.vars.selected:show()
				else
					v.vars.selected:hide()
					v.vars.sharder:enableWithChildren()
				end
			end
		end
	end
end

function wnd_fiveUnique_batch_sweep:select(sender, node)
	local index = sender:getTag()
	if self:isSelected(index) then
		self:cancel(index, node)
	else
		self:press(index, node)
	end
end

function wnd_fiveUnique_batch_sweep:isSelected(index)
	if self.isSelect[self.state] and self.isSelect[self.state][index] then
		return true
	else
		return false
	end
end

function wnd_fiveUnique_batch_sweep:isChallenged(index)
	local finish = self.info.finishFloors
	if finish[self.state] and finish[self.state][index] then
		return true
	else
		return false
	end
end

function wnd_fiveUnique_batch_sweep:press(index, node)
	if self.times > 0 then
		self.times = self.times - 1
	else
		g_i3k_ui_mgr:PopupTipMessage("次数不足")
		return false
	end
	if not self.isSelect[self.state] then
		self.isSelect[self.state] = {}
	end
	self.isSelect[self.state][index] = true
	node.vars.selected:show()
end

function wnd_fiveUnique_batch_sweep:cancel(index, node)
	self.isSelect[self.state][index] = nil
	node.vars.selected:hide()
	self.times = self.times + 1
end

function wnd_fiveUnique_batch_sweep:onBatchSweepBtn(sender, floor)
	local vit = g_i3k_game_context:GetVit()
	local needVit = 0
	for i = 1, 5 do
		if self.isSelect[i] and next(self.isSelect[i]) then
			for k, v in pairs(self.isSelect[i]) do
				local l_fbId = i3k_db_climbing_tower_datas[i][k].fbID
				needVit = i3k_db_climbing_tower_fb[l_fbId].enterConsume + needVit
			end
		end
	end
	if needVit > 0 then
		if needVit > vit then
			g_i3k_ui_mgr:PopupTipMessage("体力不足")
		else
			local floors = {}
			for k, v in pairs(self.isSelect) do
				for i, j in pairs(v) do
					local obj = i3k_sbean.TowerSweepReqInfo.new()
					obj.groupId = k
					obj.floor = i
					table.insert(floors, obj)
				end
			end
			i3k_sbean.tower_new_sweep(floors, needVit, floor)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("请先选择关卡")
	end
end

function wnd_create(layout)
	local wnd = wnd_fiveUnique_batch_sweep.new();
	wnd:create(layout);
	return wnd;
end
