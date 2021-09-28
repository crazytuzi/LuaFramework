require "ui.dialog"

ContactServiceDialog = {}
setmetatable(ContactServiceDialog, Dialog)
ContactServiceDialog.__index = ContactServiceDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ContactServiceDialog.getInstance()
	LogInfo("ContactServiceDialog getinstance")
    if not _instance then
        _instance = ContactServiceDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ContactServiceDialog.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = ContactServiceDialog:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ContactServiceDialog.getInstanceNotCreate()
    return _instance
end

function ContactServiceDialog.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function ContactServiceDialog.ToggleOpenClose()
	if not _instance then 
		_instance = ContactServiceDialog:new() 
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

function ContactServiceDialog.GetLayoutFileName()
    return "messageboxtokefu.layout"
end

function ContactServiceDialog:OnCreate()
	LogInfo("enter ContactServiceDialog oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_Info = {}
    self.m_Info["91"] = winMgr:getWindow("MessageBoxtokefu/91")
    self.m_Info["pp"] = winMgr:getWindow("MessageBoxtokefu/pp")
    self.m_Info["app"] = winMgr:getWindow("MessageBoxtokefu/app")

	self.m_CloseBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MessageBoxtokefu/closed"))
	self.m_CSOnLine = CEGUI.Window.toPushButton(winMgr:getWindow("MessageBoxtokefu/closed1"))

    -- subscribe event
	self.m_CloseBtn:subscribeEvent("Clicked", ContactServiceDialog.HandleCloseBtnClick, self) 
	self.m_CSOnLine:subscribeEvent("Clicked", ContactServiceDialog.HandleCSOnLineBtnClick, self)

    --init settings
	require "config"
	for k,v in pairs(self.m_Info) do
		v:setVisible(false)
	end
	local hasService = false
	for k,v in pairs(self.m_Info) do
		if Config.CUR_3RD_PLATFORM == k then
			v:setVisible(true)
			hasService = true
		end
	end
	-- 如果没有指定的联系客服界面，默认显示PP的
	if hasService == false then
		winMgr:getWindow("MessageBoxtokefu/pp"):setVisible(true)
	end

	self.m_CSOnLine:setVisible(false)
	if Config.CUR_3RD_PLATFORM == "tiger" then
		self.m_CSOnLine:setVisible(true)
	end
end

------------------- private: -----------------------------------


function ContactServiceDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ContactServiceDialog)

    return self
end

function ContactServiceDialog:HandleCSOnLineBtnClick(args)
	SDXL.ChannelManager:EnterCustomerService()
end

function ContactServiceDialog:HandleCloseBtnClick(args)
	ContactServiceDialog.DestroyDialog()
end	

return ContactServiceDialog
