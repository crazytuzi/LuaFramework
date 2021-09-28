-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_diaryContent = i3k_class("wnd_diaryContent", ui.wnd_base)

local labelText = "在此处输入您想发布的心情，最多可输入80个字"

function wnd_diaryContent:ctor()
	self.moodDiary = {}
	self.isWrite = false
end

function wnd_diaryContent:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.sure_btn:onClick(self, self.onPublish)
	widgets.input_label:setMaxLength(i3k_db_mood_diary_cfg.wordLimit)
	widgets.input_label:addEventListener(function(eventType)
		if eventType == "began" then
			local curText = widgets.label:getText()
			if curText ~= labelText then
				widgets.input_label:setText(curText)
			end
		elseif eventType == "ended" then
		    local text = widgets.input_label:getText()
			if text ~= "" then
				widgets.label:setText(text)
				widgets.input_label:setText("")
				self.isWrite = true
			else
				widgets.label:setText(labelText)
				self.isWrite = false
			end
	    end
	end)
end

function wnd_diaryContent:onPublish(sender)
	if not self.isWrite then
		g_i3k_ui_mgr:PopupTipMessage("日记的内容不能为空")
		return
	end
	local text = self._layout.vars.label:getText()
	local length = i3k_get_utf8_len(text)
	if length > i3k_db_mood_diary_cfg.wordLimit then
		g_i3k_ui_mgr:PopupTipMessage("字数超过限制")
		return
	end
	if self.moodDiary.dayWirteCnt >= i3k_db_mood_diary_cfg.perDayCount then
		g_i3k_ui_mgr:PopupTipMessage("每天只能发10条日记")
		return
	end
	if self.moodDiary.totalDiariesCnt >= i3k_db_mood_diary_cfg.allCount then
		g_i3k_ui_mgr:PopupTipMessage("日记总条数超过限制")
		return
	end
	i3k_sbean.mood_diary_wirte_diary(text)
end

function wnd_diaryContent:refresh(moodDiary)
	self.moodDiary = moodDiary
	self._layout.vars.background:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[moodDiary.curDecorate].writeBackGround))
	self._layout.vars.sure_btn:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[moodDiary.curDecorate].writeDiaryBtn))
	self._layout.vars.close_btn:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[moodDiary.curDecorate].writeDiaryBtn))
	self._layout.vars.sureText:setTextColor(i3k_db_mood_diary_decorate[moodDiary.curDecorate].normalBtnColor)
	self._layout.vars.cancelText:setTextColor(i3k_db_mood_diary_decorate[moodDiary.curDecorate].normalBtnColor)
	self._layout.vars.sureText:enableOutline(i3k_db_mood_diary_decorate[moodDiary.curDecorate].normalTextColor)
	self._layout.vars.cancelText:enableOutline(i3k_db_mood_diary_decorate[moodDiary.curDecorate].normalTextColor)
	self._layout.vars.label:setTextColor(i3k_db_mood_diary_decorate[moodDiary.curDecorate].writeTextColor)
	self._layout.vars.label:setText(labelText)
	self._layout.vars.scrollIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[moodDiary.curDecorate].wndScrollIcon))
end

function wnd_create(layout)
	local wnd = wnd_diaryContent.new()
	wnd:create(layout)
	return wnd
end
