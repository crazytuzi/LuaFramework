require "ui.dialog"
PointTip = {}
setmetatable(PointTip, Dialog)
PointTip.__index = PointTip

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function PointTip.getInstance()
    if not _instance then
        _instance = PointTip:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function PointTip.getInstanceAndShow()
    if not _instance then
        _instance = PointTip:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function PointTip.getInstanceNotCreate()
    return _instance
end

function PointTip.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function PointTip.ToggleOpenClose()
	if not _instance then 
		_instance = PointTip:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function PointTip.GetLayoutFileName()
    return "quackxiuxingtips.layout"
end
function PointTip:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.name = winMgr:getWindow("quackxiuxingtips/name")
	self.info = winMgr:getWindow("quackxiuxingtips/info")


end

------------------- private: -----------------------------------
function PointTip:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PointTip)
    return self
end
function PointTip:HandleClicked(args)
    local id = CEGUI.toWindowEventArgs(args).window:getID()
end
function PointTip.SetTip(id)
	if not id then return end
	self = PointTip.getInstanceAndShow()
	if not self then return self end
	local cfg = require("manager.beanconfigmanager").getInstance():GetTableByName("knight.gsp.npc.cxiakepracticevalueconfig"):getRecorder(id)
	if not cfg then return  self end
	self.name:setText(cfg.pointName)
	self.info:setText(cfg.pointTips)
	return self
end

return PointTip
