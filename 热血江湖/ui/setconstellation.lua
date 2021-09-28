-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_setConstellation = i3k_class("wnd_setConstellation", ui.wnd_base)

local LAYER_CONSTELLATIONITEM = "ui/widgets/xinqingrijixzt"


function wnd_setConstellation:ctor()
	self.constellationChoice = 0
	self.decorateId = 1
end

function wnd_setConstellation:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.confirm_btn:onClick(self, self.onConfirm)
end

function wnd_setConstellation:refresh(decorateId)
	self.decorateId = decorateId
	self:showConstellation()
end

function wnd_setConstellation:showConstellation()
	local widgets = self._layout.vars
	widgets.background:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorateId].chooseConstellationBg))
	widgets.title:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorateId].chooseConstellationTitle))
	widgets.fujin:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorateId].chooseConstellationScroll))
	widgets.close_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorateId].chooseConstellationClose))
	widgets.confirm_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorateId].chooseConstellationSureBtn))
	widgets.sureText:setTextColor(i3k_db_mood_diary_decorate[self.decorateId].chooseConstellationSureColor)
	widgets.sureText:enableOutline(i3k_db_mood_diary_decorate[self.decorateId].chooseConstellationOutlineColor)
	
	widgets.scroll:removeAllChildren()
	local children = widgets.scroll:addChildWithCount(LAYER_CONSTELLATIONITEM, 4, #i3k_db_mood_diary_constellation)
	for i,v in ipairs(children) do
		if i == self.constellationChoice then
			v.vars.tick:show()
		else
			v.vars.tick:hide()
		end
		v.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_constellation[i].constellationIcon))
		v.vars.choose_btn:onClick(self, self.onChooseConstellation,i3k_db_mood_diary_constellation[i].constellationID)
		v.vars.desc:setText(i3k_db_mood_diary_constellation[i].constellationName)
		v.vars.background:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorateId].chooseConstellationContent))
		v.vars.textBg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorateId].chooseConstellationTextBg))
		v.vars.desc:setTextColor(i3k_db_mood_diary_decorate[self.decorateId].chooseConstellationTextColor)
	end
end

function wnd_setConstellation:onChooseConstellation(sender,constellationID)
	if self.constellationChoice == constellationID then	--开始已经选了一个星座了，再点击取消
		for i,v in ipairs(self._layout.vars.scroll:getAllChildren()) do
			if i == constellationID then
				v.vars.tick:hide()
			end
		end
		self.constellationChoice = 0
	else
		for i,v in ipairs(self._layout.vars.scroll:getAllChildren()) do
			if i == self.constellationChoice then
				v.vars.tick:hide()
			end
			if i == constellationID then
				v.vars.tick:show()
			end
		end
		self.constellationChoice = constellationID
	end
end

function wnd_setConstellation:onConfirm(sender)
	if self.constellationChoice == 0 then
		g_i3k_ui_mgr:PopupTipMessage("请选择您的星座")
	else
		i3k_sbean.mood_diary_choose_constellation(self.constellationChoice)
	end
end

function wnd_setConstellation:onCloseUI(sender)
	local fun = (function(ok)
		if ok then
			i3k_sbean.mood_diary_choose_constellation(self.constellationChoice)
		end
	end)
	if self.constellationChoice ~= 0 then
		local desc = "您尚未保存星座，是否保存，点击是退出介面并保存选中介面"
		g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_SetConstellation)
	end
end

function wnd_create(layout)
	local wnd = wnd_setConstellation.new()
	wnd:create(layout)
	return wnd
end
