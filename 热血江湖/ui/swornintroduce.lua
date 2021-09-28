module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_swornIntroduce = i3k_class("wnd_swornIntroduce", ui.wnd_base)

local BONUSTEXT = {5397, 5444, 5445}
local RULETEXT =
{
	{title = i3k_get_string(5449), desc = i3k_get_string(5395, i3k_db_sworn_system.openLvl)},
	{title = i3k_get_string(5450), desc = i3k_get_string(5396)},
	{title = i3k_get_string(5451), desc = i3k_get_string(5447)},
	{title = i3k_get_string(5452), desc = i3k_get_string(5448)},
}

function wnd_swornIntroduce:ctor()
	
end

function wnd_swornIntroduce:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	widgets.moveToNpcBtn:onClick(self, self.moveToNpc)
	for k = 1, 3 do
		widgets["bonus_btn"..k]:onTouchEvent(self, self.onBonusBtn, k)
		widgets["bonus_icon"..k]:hide()
		widgets["bonus_text"..k]:setText(i3k_get_string(BONUSTEXT[k]))
	end
	for i = 1, 4 do
		widgets["title_btn"..i]:onClick(self, self.changeDescription, i)
		widgets["title_text"..i]:setText(RULETEXT[i].title)
	end
end

function wnd_swornIntroduce:refresh()
	self:changeDescription(nil, 1)
end

function wnd_swornIntroduce:changeDescription(sender, index)
	for i = 1, 4 do
		self._layout.vars["title_btn"..i]:stateToNormal()
		self._layout.vars["title_text"..i]:setTextColor("ff90e9ff")
		self._layout.vars["title_num"..i]:setTextColor("ff90e9ff")
	end
	self._layout.vars["title_btn"..index]:stateToPressed()
	self._layout.vars["title_text"..index]:setTextColor("ff9f3c22")
	self._layout.vars["title_num"..index]:setTextColor("fffdff62")
	self._layout.vars.scroll:removeAllChildren()
	local textNode = require("ui/widgets/jiebaijst1")()
	textNode.vars.content:setText(RULETEXT[index].desc)
	self._layout.vars.scroll:addItem(textNode)
	g_i3k_ui_mgr:AddTask(self, {textNode}, function(ui)
		local textUI = textNode.vars.content
		local size = textNode.rootVar:getContentSize()
		local height = textUI:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		textNode.rootVar:changeSizeInScroll(ui._layout.vars.scroll, width, height, true)
	end, 1)
end

function wnd_swornIntroduce:onBonusBtn(sender, eventType, index)
	if eventType == ccui.TouchEventType.began then
		self._layout.vars["bonus_icon"..index]:show()
	elseif eventType == ccui.TouchEventType.moved then
	else
		self._layout.vars["bonus_icon"..index]:hide()
	end
end

function wnd_create(layout)
	local wnd = wnd_swornIntroduce.new()
	wnd:create(layout)
	return wnd
end

function wnd_swornIntroduce:moveToNpc(sender)
	g_i3k_game_context:gotoSwornNpc()
	g_i3k_logic:OpenBattleUI()
end