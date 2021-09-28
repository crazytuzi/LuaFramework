local Dialog = require "ui.dialog"
local SDZhaJiLable = require "ui.sdzhaji.sdzhajilable"

local SDZhaJiEntranceBtn = {}

setmetatable(SDZhaJiEntranceBtn, Dialog)
SDZhaJiEntranceBtn.__index = SDZhaJiEntranceBtn 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function SDZhaJiEntranceBtn.IsShow()
    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function SDZhaJiEntranceBtn.getInstance()
    if not _instance then
        _instance = SDZhaJiEntranceBtn:new()
        _instance:OnCreate()
    end

    return _instance
end

function SDZhaJiEntranceBtn.getInstanceAndShow()
    if not _instance then
        _instance = SDZhaJiEntranceBtn:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function SDZhaJiEntranceBtn.getInstanceNotCreate()
    return _instance
end

function SDZhaJiEntranceBtn.DestroyDialog()
	if _instance then
        if GetGameUIManager():IsWindowHaveEffect(_instance:GetWindow()) then
            GetGameUIManager():RemoveUIEffect(_instance:GetWindow())
        end
		_instance:OnClose() 
		_instance = nil
	end
end

function SDZhaJiEntranceBtn.ToggleOpenClose()
	if not _instance then 
		_instance = SDZhaJiEntranceBtn:new() 
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

function SDZhaJiEntranceBtn.GetLayoutFileName()
    return "shendiaozhajibtn.layout"
end

function SDZhaJiEntranceBtn:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_btn = CEGUI.Window.toPushButton(winMgr:getWindow("shendiaozhajibtn/button"))
    self.m_btn:subscribeEvent("Clicked", SDZhaJiEntranceBtn.HandleClickeBtn, self)
end

function SDZhaJiEntranceBtn:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SDZhaJiEntranceBtn)

    return self
end

function SDZhaJiEntranceBtn:HandleClickeBtn(args)
    SDZhaJiLable.Show(1)
    return true
end


return SDZhaJiEntranceBtn
