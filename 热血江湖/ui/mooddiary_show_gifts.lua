-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_moodDiary_show_gifts = i3k_class("wnd_moodDiary_show_gifts", ui.wnd_base)

local XXT = "ui/widgets/xinqingrijixxt"

function wnd_moodDiary_show_gifts:ctor()
	self.moodDiary = {}
	self.state = 1 -- 1表示送出，2表示收到
end

function wnd_moodDiary_show_gifts:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
end

function wnd_moodDiary_show_gifts:refresh(moodDiary)
	self.moodDiary = moodDiary
	local widget = self._layout.vars
	local decorateCfg = i3k_db_mood_diary_decorate[self.moodDiary.curDecorate]
	widget.scrollBg:setImage(g_i3k_db.i3k_db_get_icon_path(decorateCfg.wndScrollIcon))
	widget.background:setImage(g_i3k_db.i3k_db_get_icon_path(decorateCfg.showGiftBg))
	widget.close:setNormalImage(g_i3k_db.i3k_db_get_icon_path(decorateCfg.showGiftClose))
	widget.title:setImage(g_i3k_db.i3k_db_get_icon_path(decorateCfg.showGiftTitle))
	widget.underLine:setImage(g_i3k_db.i3k_db_get_icon_path(decorateCfg.showGiftUnderline))
	widget.popularity:setText(moodDiary.popularity)
	widget.popularity:setTextColor(decorateCfg.showGiftPopColor)
	widget.curLabel:setTextColor(decorateCfg.showGiftPopColor)
	self:updateGiftScroll()
	self._layout.vars.sendBtn:onClick(self, self.onChangeState, 1)
	self._layout.vars.receiveBtn:onClick(self, self.onChangeState, 2)
end

function wnd_moodDiary_show_gifts:onChangeState(sender, state)
	self.state = state
	self:updateGiftScroll()
end

function wnd_moodDiary_show_gifts:updateGiftScroll()
	local widget = self._layout.vars
	local decorateCfg = i3k_db_mood_diary_decorate[self.moodDiary.curDecorate]

	local gifts = {}
	if self.state == 1 then
		gifts = self.moodDiary.sendLogs
		widget.sendBtn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(decorateCfg.showGiftPagePress))
		widget.receiveBtn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(decorateCfg.showGiftPage))
		widget.sendText:setTextColor(decorateCfg.showGiftPagePressColor)
		widget.sendText:enableOutline(decorateCfg.showGiftPageContourPressColor)
		widget.receiveText:setTextColor(decorateCfg.showGiftPageColor)
		widget.receiveText:enableOutline(decorateCfg.showGiftPageContourColor)
	else
		gifts = self.moodDiary.receiveLogs
		widget.sendBtn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(decorateCfg.showGiftPage))
		widget.receiveBtn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(decorateCfg.showGiftPagePress))
		widget.sendText:setTextColor(decorateCfg.showGiftPageColor)
		widget.sendText:enableOutline(decorateCfg.showGiftPageContourColor)
		widget.receiveText:setTextColor(decorateCfg.showGiftPagePressColor)
		widget.receiveText:enableOutline(decorateCfg.showGiftPageContourPressColor)
	end

	widget.scroll:removeAllChildren()
	for k, v in ipairs(gifts) do
		local node = require(XXT)()
		local text = ""

		local color1 = decorateCfg.showGiftTextColor
		local color2 = decorateCfg.showGiftNameColor
		local name = v.overview.name
		local count = v.cnt
		local itemName = g_i3k_db.i3k_db_get_common_item_name(v.itemID)

		if self.state == 1 then
			text = i3k_get_string(17204, color1, color2, name, color1, count, itemName)
		else
			text = i3k_get_string(17205, color2, name, color1, count, itemName)
		end
		node.vars.des:setText(text)
		node.vars.pop:setImage(g_i3k_db.i3k_db_get_icon_path(decorateCfg.showGiftPop))
		node.vars.time:setText(g_i3k_get_YearAndDayAndTime(v.time))
		node.vars.time:setTextColor(decorateCfg.showGiftTimeColor)
		self._layout.vars.scroll:addItem(node)
	end
	if next(gifts) then
		widget.noneGifts:hide()
	else
		widget.noneGifts:show()
		widget.noneGifts:setImage(g_i3k_db.i3k_db_get_icon_path(decorateCfg.showGiftNoneIcon))
		local text = ""
		if self.state == 1 then
			text = i3k_get_string(17203)
		else
			text = i3k_get_string(17202)
		end
		widget.noneText:setTextColor(decorateCfg.showGiftNoneText)
		widget.noneText:setText(text)
	end
end

function wnd_create(layout)
	local wnd = wnd_moodDiary_show_gifts.new()
	wnd:create(layout)
	return wnd
end
