require "ui.dialog"
require "ui.spring.springentrancedlg"

SpringEntranceBtn = {

--0:display, 1:display and have effect
m_status = -1,
}

setmetatable(SpringEntranceBtn, Dialog)
SpringEntranceBtn.__index = SpringEntranceBtn 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function SpringEntranceBtn.IsShow()
    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function SpringEntranceBtn.getInstance()
    if not _instance then
        _instance = SpringEntranceBtn:new()
        _instance:OnCreate()
    end

    return _instance
end

function SpringEntranceBtn.getInstanceAndShow()
    if not _instance then
        _instance = SpringEntranceBtn:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function SpringEntranceBtn.getInstanceNotCreate()
    return _instance
end

function SpringEntranceBtn.DestroyDialog()
	if _instance then
        if GetGameUIManager():IsWindowHaveEffect(_instance:GetWindow()) then
            GetGameUIManager():RemoveUIEffect(_instance:GetWindow())
        end
		_instance:OnClose() 
		_instance = nil
	end
end

function SpringEntranceBtn.ToggleOpenClose()
	if not _instance then 
		_instance = SpringEntranceBtn:new() 
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

function SpringEntranceBtn.GetLayoutFileName()
    return "springfestivalentrance.layout"
end

function SpringEntranceBtn:OnCreate()
    Dialog.OnCreate(self)
    --self:GetWindow():setModalState(true)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows

    self.m_btn = CEGUI.Window.toPushButton(winMgr:getWindow("springfestivalentrance/button"))
    self.m_btn:subscribeEvent("Clicked", SpringEntranceBtn.HandleClickeBtn, self)
end

function SpringEntranceBtn:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SpringEntranceBtn)

    return self
end

function SpringEntranceBtn:HandleClickeBtn(args)
    local dlgSpringEntrance = SpringEntranceDlg.getInstanceAndShow()
    
    return true
end


return SpringEntranceBtn
