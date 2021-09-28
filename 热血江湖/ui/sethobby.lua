-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_setHobby = i3k_class("wnd_setHobby", ui.wnd_base)

local LAYER_HOBBIES = "ui/widgets/xinqingrijiaht1"

function wnd_setHobby:ctor()
	self.hobbycnt = 0
	self.hobbies = {}
	self.diyHobbiesForDisplay = {}
	self.decorateId = 1
--	self.diyHobbies = {}
end

function wnd_setHobby:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.sure_btn:onClick(self, self.SetHobby)
end

function wnd_setHobby:refresh(personInfo, decorateId)
	self.hobbies = personInfo.self.hobbies
	self.decorateId = decorateId
--	self.diyHobbies = personInfo.self.diyHobbies
	for k,v in ipairs(personInfo.self.diyHobbies) do
		table.insert(self.diyHobbiesForDisplay, {describe = v, isDisplay = true})
	end
	for i,e in pairs(self.hobbies) do
		if e then
			self.hobbycnt = self.hobbycnt + 1
		end
	end
	self.hobbycnt = self.hobbycnt + #personInfo.self.diyHobbies
	self:showHobbies()
end

function wnd_setHobby:showHobbies(diyHobby)
	local widgets = self._layout.vars
	widgets.background:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorateId].chooseHobbyBg))
	widgets.title:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorateId].chooseHobbyTitle))
	widgets.fujin:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorateId].chooseHobbyScrollBg))
	widgets.close_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorateId].chooseHobbyCloseBtn))
	widgets.sure_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorateId].chooseHobbySureBtn))
	widgets.sureText:setTextColor(i3k_db_mood_diary_decorate[self.decorateId].chooseHobbySureText)
	widgets.sureText:enableOutline(i3k_db_mood_diary_decorate[self.decorateId].chooseHobbySureOutline)
	
	widgets.scroll:removeAllChildren()
	if diyHobby then
--		table.insert(self.diyHobbies, diyHobby)
		table.insert(self.diyHobbiesForDisplay, {describe = diyHobby, isDisplay = true})
		self.hobbycnt = self.hobbycnt + 1
	end
	
	local hobbies = widgets.scroll:addChildWithCount(LAYER_HOBBIES, 3, #i3k_db_mood_diary_hobby + #self.diyHobbiesForDisplay + 1)
	
	for i,e in ipairs(hobbies) do
		e.vars.background:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorateId].chooseHobbyContentBg))
		e.vars.desc:setTextColor(i3k_db_mood_diary_decorate[self.decorateId].chooseHobbyTextColor)
		if i == #i3k_db_mood_diary_hobby + #self.diyHobbiesForDisplay + 1 then	--添加按钮的处理
			e.vars.hobby_item:setVisible(false)
			e.vars.add_btn:onClick(self, self.onAddDiyHobby)
		else
			e.vars.add_hobby:setVisible(false)
			if i <= #i3k_db_mood_diary_hobby then
				if self.hobbies[i] then
					e.vars.tick:show()
				end
				e.vars.desc:setText(i3k_db_mood_diary_hobby[i].hobbyName)
				e.vars.delete_btn:setVisible(false)
			else
				e.vars.desc:setText(self.diyHobbiesForDisplay[i-#i3k_db_mood_diary_hobby].describe)
				e.vars.delete_btn:onClick(self, self.onDeleteDiyHobby, i - #i3k_db_mood_diary_hobby)
				if self.diyHobbiesForDisplay[i-#i3k_db_mood_diary_hobby].isDisplay then
					e.vars.tick:show()
				else
					e.vars.tick:hide()
				end
			end
			e.vars.choose_btn:onClick(self, self.onChooseHobby, i)
		end
	end
end

function wnd_setHobby:onDeleteDiyHobby(sender,index)
	--[[for k,v in ipairs(self.diyHobbies) do
		if v == self.diyHobbiesForDisplay[index].describe then
			table.remove(self.diyHobbies, k)
		end
	end--]]
	table.remove(self.diyHobbiesForDisplay, index)
	self.hobbycnt = self.hobbycnt - 1
	self:showHobbies()
end

function wnd_setHobby:onAddDiyHobby(sender)
	if self.hobbycnt >= i3k_db_mood_diary_cfg.hobbyCount then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17506, i3k_db_mood_diary_cfg.hobbyCount))
	else
		g_i3k_ui_mgr:OpenUI(eUIID_WriteDiyHobby)
		g_i3k_ui_mgr:RefreshUI(eUIID_WriteDiyHobby)
	end
end

function wnd_setHobby:SetHobby(sender)
	local finalDiyHobbies = {}
	for k,v in ipairs(self.diyHobbiesForDisplay) do
		if v.isDisplay then
			table.insert(finalDiyHobbies, v.describe)
		end
	end
	i3k_sbean.mood_diary_set_hobby(self.hobbies, finalDiyHobbies)
end

function wnd_setHobby:onChooseHobby(sender, hobbyID)
	local hobby = self._layout.vars.scroll:getAllChildren()
	if hobbyID <= #i3k_db_mood_diary_hobby then		--系统爱好
		if self.hobbies[hobbyID] then
			hobby[hobbyID].vars.tick:hide()
			self.hobbycnt = self.hobbycnt - 1
			self.hobbies[hobbyID] = nil
		else
			if self.hobbycnt >= i3k_db_mood_diary_cfg.hobbyCount then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17506, i3k_db_mood_diary_cfg.hobbyCount))
			else
				hobby[hobbyID].vars.tick:show()
				self.hobbycnt = self.hobbycnt + 1
				self.hobbies[hobbyID] = true
			end
		end
	else											--自定义爱好
		if hobby[hobbyID].vars.tick:isVisible() then
			hobby[hobbyID].vars.tick:hide()
--			table.remove(self.diyHobbies, hobbyID - #i3k_db_mood_diary_hobby)
			self.diyHobbiesForDisplay[hobbyID - #i3k_db_mood_diary_hobby].isDisplay = false
			self.hobbycnt = self.hobbycnt - 1
		else
			if self.hobbycnt >= i3k_db_mood_diary_cfg.hobbyCount then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17506, i3k_db_mood_diary_cfg.hobbyCount))
			else
				hobby[hobbyID].vars.tick:show()
--				table.insert(self.diyHobbies, hobbyID - #i3k_db_mood_diary_hobby, hobby[hobbyID].vars.desc:getText())
				self.diyHobbiesForDisplay[hobbyID - #i3k_db_mood_diary_hobby].isDisplay = true
				self.hobbycnt = self.hobbycnt + 1
			end
		end
	end
end
	


function wnd_create(layout)
	local wnd = wnd_setHobby.new()
	wnd:create(layout)
	return wnd
end
