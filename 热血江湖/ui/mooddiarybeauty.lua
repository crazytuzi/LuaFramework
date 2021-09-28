-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_moodDiary_beauty = i3k_class("wnd_moodDiary_beauty", ui.wnd_base)

local WIDGET = "ui/widgets/xinqingrijimht"

function wnd_moodDiary_beauty:ctor()
	--self._choose = 1
	self.moodDiary = {}
end

function wnd_moodDiary_beauty:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_moodDiary_beauty:refresh(moodDiary)
	self.moodDiary = moodDiary
	self:updateAllBeauty()
end

function wnd_moodDiary_beauty:updateAllBeauty()
	self._layout.vars.scroll:removeAllChildren()
	for k, v in ipairs(i3k_db_mood_diary_decorate) do
		local node = require(WIDGET)()
		node.vars.name:setText(v.name)
		node.vars.bgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank(v.unlockItemId))
		node.vars.icon:onClick(self, self.changeDecoration, k)
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.unlockItemId, g_i3k_game_context:IsFemaleRole()))
		local id = (self.moodDiary and self.moodDiary.curDecorate) or g_i3k_game_context:getMoodDiaryDecorate()
		node.vars.usingIcon:setVisible(id == v.id)
		node.vars.isOwned:setText(g_i3k_game_context:isHaveMoodDiaryDecorate(v.id) and "已拥有" or "未拥有")
		self._layout.vars.scroll:addItem(node)
	end
end

function wnd_moodDiary_beauty:changeDecoration(sender, id)
	if i3k_db_mood_diary_decorate[id].unlockItemId ~= 0 then
		g_i3k_ui_mgr:ShowCommonItemInfo(i3k_db_mood_diary_decorate[id].unlockItemId)
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_MoodDiary, "changeDecorate", id)
	--self:onCloseUI()
end

function wnd_moodDiary_beauty:onHide()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_MoodDiary, "changeDecorateId")
end

function wnd_create(layout)
	local wnd = wnd_moodDiary_beauty.new()
	wnd:create(layout)
	return wnd
end
