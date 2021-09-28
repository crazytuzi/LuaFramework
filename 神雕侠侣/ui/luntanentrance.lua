require "utils.mhsdutils"
require "ui.dialog"

LunTanEntrance = {}
setmetatable(LunTanEntrance, Dialog)
LunTanEntrance.__index = LunTanEntrance

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;

function LunTanEntrance.IsCurrentPlatformHasForum()
    
    if Config.CUR_3RD_LOGIN_SUFFIX == "w173" or Config.CUR_3RD_LOGIN_SUFFIX == "lahu" then
        return true
    end

    if Config.CUR_3RD_LOGIN_SUFFIX == "lawp" then
        if SDXL.ChannelManager:HasPlatformForum() == 1 then
            return true
        end
    end
    
    return false
end

function LunTanEntrance.getInstance()
    if LunTanEntrance.IsCurrentPlatformHasForum() == false then
        return
    end

	LogInfo("enter get luntanentrance instance")
    if not _instance then
        _instance = LunTanEntrance:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function LunTanEntrance.WantShow()
    if LunTanEntrance.IsCurrentPlatformHasForum() == false then
        return
    end
	if _instance then
		_instance:SetVisible(true)
	end
end

function LunTanEntrance.WantHide()
    if LunTanEntrance.IsCurrentPlatformHasForum() == false then
        return
    end
	if _instance then
		_instance:SetVisible(false)
	end
end

function LunTanEntrance.getInstanceAndShow()
    if LunTanEntrance.IsCurrentPlatformHasForum() == false then
        return
    end

	LogInfo("enter luntanentrance instance show")
    if not _instance then
        _instance = LunTanEntrance:new()
        _instance:OnCreate()
	else
		LogInfo("set luntanentrance visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LunTanEntrance.getInstanceNotCreate()
    return _instance
end

function LunTanEntrance.DestroyDialog()
    if LunTanEntrance.IsCurrentPlatformHasForum() == false then
        return
    end
	if _instance then 
		LogInfo("destroy luntanentrance")
		_instance:OnClose()
		_instance = nil
	end
end

function LunTanEntrance.ToggleOpenClose()
	if not _instance then 
		_instance = LunTanEntrance:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function LunTanEntrance.refreshEffect()
	LogInfo("luntanentrance refresh effect")
	if _instance and ActivityManager.getInstanceNotCreate() then
		if ActivityManager.getInstanceNotCreate():getNeedEffect() then
			if not _instance.m_effect then
				GetGameUIManager():AddUIEffect(_instance:GetWindow(), MHSD_UTILS.get_effectpath(10305))	
				_instance.m_effect = true 
			end
		else
			GetGameUIManager():RemoveUIEffect(_instance:GetWindow())
			_instance.m_effect = nil
		end
	end	

end

----/////////////////////////////////////////------

function LunTanEntrance.GetLayoutFileName()
    return "luntan.layout"
end

function LunTanEntrance:OnCreate()
	LogInfo("luntanentrance oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow("luntan/btn"))

    -- subscribe event
    self.m_pBtn:subscribeEvent("Clicked", LunTanEntrance.HandleBtnClicked, self) 
	--LunTanEntrance.refreshEffect()
	LogInfo("luntanentrance oncreate end")
end

------------------- private: -----------------------------------

function LunTanEntrance:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LunTanEntrance)
    return self
end

function LunTanEntrance:HandleBtnClicked(args)
	LogInfo("luntanentrance button clicked")
	SDXL.ChannelManager:EnterBBS()
	return true
end

return LunTanEntrance
