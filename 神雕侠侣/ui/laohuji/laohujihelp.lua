require "ui.dialog"
local LaohujiHelp = {}

setmetatable(LaohujiHelp, Dialog);
LaohujiHelp.__index = LaohujiHelp;

local _instance;

function LaohujiHelp.getInstance()
	if _instance == nil then
		_instance = LaohujiHelp:new();
		_instance:OnCreate();
	end

	return _instance;
end

function LaohujiHelp.getInstanceNotCreate()
	return _instance;
end

function LaohujiHelp.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		LogInfo("LaohujiHelp DestroyDialog")
	end
end

function LaohujiHelp.getInstanceAndShow()
    if not _instance then
        _instance = LaohujiHelp:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LaohujiHelp.ToggleOpenClose()
	if not _instance then 
		_instance = LaohujiHelp:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function LaohujiHelp.GetLayoutFileName()
	return "laohujihelp.layout";
end

function LaohujiHelp:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, LaohujiHelp);
	return zf;
end

------------------------------------------------------------------------------



return LaohujiHelp