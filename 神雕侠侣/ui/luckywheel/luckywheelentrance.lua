require "ui.dialog"

local LuckyWheelEntrance = {}
setmetatable(LuckyWheelEntrance, Dialog)
LuckyWheelEntrance.__index = LuckyWheelEntrance

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LuckyWheelEntrance.getInstance()
	print("enter get LuckyWheelEntrance dialog instance")
    if not _instance then
        _instance = LuckyWheelEntrance:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function LuckyWheelEntrance.getInstanceAndShow()
	print("enter LuckyWheelEntrance dialog instance show")
    if not _instance then
        _instance = LuckyWheelEntrance:new()
        _instance:OnCreate()
	else
		print("set LuckyWheelEntrance dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LuckyWheelEntrance.getInstanceNotCreate()
    return _instance
end

function LuckyWheelEntrance.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function LuckyWheelEntrance.ToggleOpenClose()
	if not _instance then 
		_instance = LuckyWheelEntrance:new() 
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

function LuckyWheelEntrance.GetLayoutFileName()
    return "zhuanzhuanlebtn.layout"
end

function LuckyWheelEntrance:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LuckyWheelEntrance)

    return self
end

function LuckyWheelEntrance:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_btn = CEGUI.Window.toPushButton(winMgr:getWindow("zhuanzhuanlebtn/btn"))
	self.m_btn:subscribeEvent("Clicked", self.HandleBtnClick, self)
end

function LuckyWheelEntrance:HandleBtnClick()
	local req = require("protocoldef.knight.gsp.activity.dazhuanpan.czhuanpaninfo").Create()
	LuaProtocolManager.getInstance():send(req)
end

function LuckyWheelEntrance:setEffect()
	if not GetGameUIManager():IsWindowHaveEffect(self.m_btn) then
        GetGameUIManager():AddUIEffect(self.m_btn, MHSD_UTILS.get_effectpath(10305))
    end 
end

return LuckyWheelEntrance