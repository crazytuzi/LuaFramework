-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_previewone = i3k_class("wnd_previewone",ui.wnd_base)
function wnd_previewone:ctor()
	
end

function wnd_previewone:configure()
	self._layout.vars.globel_btn:onClick(self,self.onClose)
end

function wnd_previewone:refresh(info)
	local widgets = self._layout.vars
	if info then
		widgets.mainTitle:setText(info.UITitle)
		widgets.descText:setText(info.UISlogan)
		self:InitModel(info)
	end
end

function wnd_previewone:InitModel(info)
	local gender = g_i3k_game_context:GetRoleGender()
	local model = self._layout.vars.modelUI
	local moduleId = nil
	if gender == 1 then
		moduleId = info.manModelId
	elseif gender == 2 then
		moduleId = info.womanModelId
	end
	local path = i3k_db_models[moduleId].path
	local uiscale = i3k_db_models[moduleId].uiscale
	model:setSprite(path)
	model:setSprSize(uiscale)
--	local alist = Engine.ActionList()
	for k,v in pairs(info.actions) do
--		alist:AddAction(v, 1)
		model:pushActionList(v,1)
	end
	model:pushActionList("stand",-1)
--	model:playActionList(alist, 1)
	model:playActionList()
end

function wnd_previewone:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_PreviewDetailone)
end

function wnd_create(layout, ...)
	local wnd = wnd_previewone.new()
	wnd:create(layout, ...)
	return wnd
end
