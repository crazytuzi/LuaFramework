-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--被求婚ui
-------------------------------------------------------

wnd_marry_proposing = i3k_class("wnd_marry_proposing",ui.wnd_base)

function wnd_marry_proposing:ctor()
	self._name = ""
end

function wnd_marry_proposing:configure()
	local widgets = self._layout.vars
	self.cancel = widgets.cancel
	self.cancel:onClick(self, self.closeButton)
	self.okBtn = widgets.ok --同意
	self.okBtn:onClick(self, self.onOkBtn)
	self.desc = widgets.desc
end

function wnd_marry_proposing:refresh(grade)
	self.grade = grade
	local name = ""
	local myTeamLeader = g_i3k_game_context:GetTeamLeader()
	local other = g_i3k_game_context:GetTeamOtherMembersProfile() 
	local otherUesrName = other[1].overview.name
	local id = other[1].overview.id
	if  i3k_db_marry_grade[grade] and i3k_db_marry_grade[grade].marryGradeName then
		name = i3k_db_marry_grade[grade].marryGradeName
	end
	self.desc:setText(i3k_get_string(688,otherUesrName,name))
	self._name = otherUesrName
	self._id = id
end

--1为接受，2为拒绝
function wnd_marry_proposing:onOkBtn(sender)
	i3k_sbean.toMarryResponse(self.grade,1, self._name, self._id)
	g_i3k_ui_mgr:CloseUI(eUIID_Marry_Proposing)
end

function wnd_marry_proposing:closeButton(sender)
	i3k_sbean.toMarryResponse(self.grade,2, self._name, self._id)
	g_i3k_ui_mgr:CloseUI(eUIID_Marry_Proposing)
end

function wnd_create(layout)
	local wnd = wnd_marry_proposing.new()
		wnd:create(layout)
	return wnd
end
