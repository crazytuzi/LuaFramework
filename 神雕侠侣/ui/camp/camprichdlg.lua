require "ui.dialog"

CampRichDlg = {}
setmetatable(CampRichDlg, Dialog)
CampRichDlg.__index = CampRichDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function CampRichDlg.getInstance()
	print("enter get camprich dialog instance")
    if not _instance then
        _instance = CampRichDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function CampRichDlg.getInstanceAndShow()
	print("enter camprich dialog instance show")
    if not _instance then
        _instance = CampRichDlg:new()
        _instance:OnCreate()
	else
		print("set camprich dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CampRichDlg.getInstanceNotCreate()
    return _instance
end

function CampRichDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function CampRichDlg.ToggleOpenClose()
	if not _instance then 
		_instance = CampRichDlg:new() 
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

function CampRichDlg.GetLayoutFileName()
    return "camprich.layout"
end

function CampRichDlg:OnCreate()
	print("camprich dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pImage = CEGUI.Window.toPushButton(winMgr:getWindow("camprich/image"))

    -- subscribe event
	self.m_pImage:subscribeEvent("MouseClick", CampRichDlg.HandleImageClicked, self)

	print("camprich dialog oncreate end")
end

------------------- private: -----------------------------------


function CampRichDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CampRichDlg)
    return self
end

function CampRichDlg:HandleImageClicked(args)
	GetGameUIManager():AddMessageTipById(145752)
	return true
end

return CampRichDlg
