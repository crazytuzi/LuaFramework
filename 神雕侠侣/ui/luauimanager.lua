require "ui.dialog"

LuaUIManager = {m_UIDialog = {}}
LuaUIManager.__index = LuaUIManager

local _instance = nil
function LuaUIManager.getInstance()
	if not _instance then
		_instance = LuaUIManager:new()
	end
	
	return _instance
end

function LuaUIManager.Exit()
	if _instance then
		_instance:RemoveAllDialog()
	end
	ActivityManager.Destroy()
	VipManager.Destroy()
	FormationManager.Destroy()
	package.loaded["ui.xiake.xiake_manager"] = nil;
	require "ui.xiake.xiake_manager";
	package.loaded["ui.faction.factiondatamanager"] = nil
	require "ui.faction.factiondatamanager"
	package.loaded["manager.itemmanager"] = nil
	require "manager.itemmanager"
	require "ui.camp.campvsmessage"
	CampVSMessage.Destroy()
	local luadlg = require "ui.tips.tooltipsdlg"
	if luadlg then
		luadlg:Exit()
	end

	require "ui.specialeffect.specialeffectmanager"
	SpecialEffectManager.Destroy()
	require "ui.skill.wulinmijimanager".Destroy()
	
	require "ui.drawrole.drawrolemanager".Destroy()
	require "ui.buttons.buttonmanager".Destroy()
end

function LuaUIManager:new()
	local self = {}
	setmetatable(self, LuaUIManager)
	return self
end

function LuaUIManager:AddDialog(window, dialog)
	if window then
		print(" add a dialog", window)
		self.m_UIDialog[window] = dialog
	end
end

function LuaUIManager:RemoveAllDialog()
	local temp = {}
	for k,v in pairs(self.m_UIDialog) do
		table.insert(temp, k)
	end
	for i,v in ipairs(temp) do
		local dlg = self.m_UIDialog[v]
		if dlg then
			dlg:DestroyDialog()
		end
	end
	LuaUIManager.m_UIDialog = {}
end

function LuaUIManager:RemoveUIDialog(window)
	print("remove dialog", window)
	self.m_UIDialog[window] = nil
end

return LuaUIManager
