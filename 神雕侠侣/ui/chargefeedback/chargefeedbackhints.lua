require "ui.dialog"

local ChargeFeedbackHints = {}
setmetatable(ChargeFeedbackHints, Dialog)
ChargeFeedbackHints.__index = ChargeFeedbackHints

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ChargeFeedbackHints.getInstance()
	print("enter get ChargeFeedbackHints dialog instance")
    if not _instance then
        _instance = ChargeFeedbackHints:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ChargeFeedbackHints.getInstanceAndShow()
	print("enter ChargeFeedbackHints dialog instance show")
    if not _instance then
        _instance = ChargeFeedbackHints:new()
        _instance:OnCreate()
	else
		print("set ChargeFeedbackHints dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ChargeFeedbackHints.getInstanceNotCreate()
    return _instance
end

function ChargeFeedbackHints.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function ChargeFeedbackHints.ToggleOpenClose()
	if not _instance then 
		_instance = ChargeFeedbackHints:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

----/////////////////////////////////////////------

function ChargeFeedbackHints.GetLayoutFileName()
    return "lishichongzhifankui.layout"
end

function ChargeFeedbackHints:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ChargeFeedbackHints)

    return self
end

function ChargeFeedbackHints:OnCreate()
	Dialog.OnCreate(self)
end

return ChargeFeedbackHints