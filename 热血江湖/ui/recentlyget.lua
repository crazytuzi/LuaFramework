------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_recently_get = i3k_class("wnd_recently_get",ui.wnd_base)

local WIDGET = "ui/widgets/huodejilvt"
local WIDGET_ACTIVITY = "ui/widgets/huodejilvt1"
local REWARD_STATE = 1
local ACTIVITY_STATE = 2

function wnd_recently_get:ctor()
	self._state = REWARD_STATE
end
function wnd_recently_get:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.reward_btn:onClick(self, self.onRewardBtnClick)
	widgets.activity_btn:onClick(self, self.onActivityBtnClick)
	widgets.reward_btn:stateToPressed()
	widgets.activity_btn:stateToNormal()
	widgets.reward_btn:setVisible(true)
	widgets.activity_btn:setVisible(true)
end

function wnd_recently_get:refresh(info)
	local widgets = self._layout.vars
	widgets.title_text:setText(i3k_get_string(18641))
	widgets.tips:setText(i3k_get_string(18643))
	widgets.reward_btn:stateToPressed()
	widgets.activity_btn:stateToNormal()
	local haveRecord = (info and next(info)) ~= nil
	widgets.tips:setVisible(not haveRecord)
	widgets.scroll:setVisible(haveRecord)
	if haveRecord then
		widgets.scroll:removeAllChildren()
		table.sort(info, function(a,b) return a.getTime > b.getTime end)
		for i, v in ipairs(info) do
			self:AddItem(v.getId, v.getNum, v.getTime)
		end
	end
end
function wnd_recently_get:AddItem(id, count, time)
	self._state = REWARD_STATE
			local ui = require(WIDGET)()
			local vars = ui.vars
	vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(id))
	vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	vars.icon:onClick(self, self.onItemInfo, id)
	vars.nameCount:setText(g_i3k_db.i3k_db_get_common_item_name(id)..'x'..count)
	vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	vars.time:setText(g_i3k_get_YearAndDayAndTime(time))
	self._layout.vars.scroll:addItem(ui)
		end

--展示转盘抽奖最近获得
function wnd_recently_get:showLotteryGet(info)
	local widgets = self._layout.vars
	widgets.reward_btn:setVisible(false)
	widgets.activity_btn:setVisible(false)
	widgets.title_text:setText(i3k_get_string(18641))
	widgets.tips:setText(i3k_get_string(18643))
	widgets.scroll:removeAllChildren()
	local haveRecord = (info and next(info)) ~= nil
	widgets.tips:setVisible(not haveRecord)
	table.sort(info, function(a,b) return a.time * 10000 + a.id > b.time * 10000 + b.id end)
	for i,v in ipairs(info) do
		self:AddItem(v.id, v.num, v.time)
	end
end

function wnd_recently_get:onItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end
function wnd_recently_get:onRewardBtnClick(sender)
	if self._state == REWARD_STATE then
		return
	end
	i3k_sbean.item_history_sync()
end
function wnd_recently_get:onActivityBtnClick(sender)
	if self._state == ACTIVITY_STATE then
		return
	end
	i3k_sbean.activity_history_sync()
end
function wnd_recently_get:addActivityItems(info)
	local widgets = self._layout.vars
	widgets.reward_btn:stateToNormal()
	widgets.activity_btn:stateToPressed()
	widgets.title_text:setText(i3k_get_string(18642))
	widgets.tips:setText(i3k_get_string(18644))
	self._state = ACTIVITY_STATE
	widgets.scroll:removeAllChildren()
	widgets.tips:setVisible(table.nums(info) == 0)
	table.sort(info, function(a, b) return a.time > b.time end)
	for k, v in pairs(info) do
		local ui = require(WIDGET_ACTIVITY)()
		local name = self:getNameByType(v.type)
		ui.vars.name:setText(name)
		ui.vars.time:setText(g_i3k_get_YearMonthAndDayTime(v.time))
		widgets.scroll:addItem(ui)
	end
end
function wnd_recently_get:getNameByType(id)
	local name = ""
	for k, v in ipairs(i3k_db_schedule.cfg) do
		if v.id == id then
			name = v.name
			break
		end
	end
	return name
end
-------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_recently_get.new()
	wnd:create(layout,...)
	return wnd
end
