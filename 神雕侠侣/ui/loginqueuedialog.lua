require "ui.dialog"
require "utils.mhsdutils"

LoginQueueDlg = {}
setmetatable(LoginQueueDlg, Dialog)
LoginQueueDlg.__index = LoginQueueDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LoginQueueDlg.getInstance()
	print("enter get yaoqianshu dialog instance")
    if not _instance then
        _instance = LoginQueueDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function LoginQueueDlg.getInstanceAndShow()
	print("enter yaoqianshu dialog instance show")
    if not _instance then
        _instance = LoginQueueDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set loginqueue dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LoginQueueDlg.getInstanceNotCreate()
    return _instance
end

function LoginQueueDlg.DestroyDialog()
	if _instance then 
		LogInfo("destroy loginqueue dialog")
		_instance:OnClose()
		_instance = nil
	end
end

function LoginQueueDlg.ToggleOpenClose()
	if not _instance then 
		_instance = LoginQueueDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function LoginQueueDlg:RefreshInfo(order, queuelength, minutes)
	if order == -1 then
		-- -1 full
		self.m_pFullTip:setVisible(true)
		self.m_pQueueTitle:setVisible(false)
		self.m_pQueueWaitingTip:setVisible(false)
		self.m_pExceptionReloginTip:setVisible(false)
	else 
		if order == 0 then
			-- 0 prior queue
			self.m_pExceptionReloginTip:setVisible(true)
			self.m_pQueueTitle:setVisible(false)
			self.m_pFullTip:setVisible(false)
			self.m_pQueueWaitingTip:setVisible(true)
			self.m_pRank:setText(tostring(order))
			self.m_pRemainingMinutes:setText(tostring(minutes))
			self.m_pPeopleBehind:setText(tostring(queuelength - order))
		else
			-- normal
			self.m_pQueueTitle:setVisible(true)
			self.m_pQueueWaitingTip:setVisible(true)
			self.m_pFullTip:setVisible(false)
			self.m_pExceptionReloginTip:setVisible(false)
			self.m_pRank:setText(tostring(order))
			self.m_pRemainingMinutes:setText(tostring(minutes))
			self.m_pPeopleBehind:setText(tostring(queuelength - order))
		end
	end
end

----/////////////////////////////////////////------

function LoginQueueDlg.GetLayoutFileName()
    return "signindlg.layout"
end

function LoginQueueDlg:OnCreate()
	print("login queue dialog oncreate begin")
	if GetLoginManager() then
		GetLoginManager():ClearConnections()
	end
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pFullTip = winMgr:getWindow("SignInDlg/main2")

    self.m_pQueueTitle = winMgr:getWindow("SignInDlg/title")

    self.m_pExceptionReloginTip = winMgr:getWindow("SignInDlg/main1")

	self.m_pQueueWaitingTip = winMgr:getWindow("SignInDlg/main") 
	self.m_pRank = winMgr:getWindow("SignInDlg/num1")
	self.m_pRemainingMinutes = winMgr:getWindow("SignInDlg/num2")
	self.m_pPeopleBehind = winMgr:getWindow("SignInDlg/num3")

	self.m_pCancelBtn = winMgr:getWindow("SignInDlg/cancel")


    -- subscribe event
    self.m_pCancelBtn:subscribeEvent("Clicked", LoginQueueDlg.HandleCancelBtnClicked, self) 
end

------------------- private: -----------------------------------


function LoginQueueDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LoginQueueDlg)
    return self
end


function LoginQueueDlg:HandleCancelBtnClicked(args)
	if GetNetConnection() then
		local offCmd = knight.gsp.CUserOffline()
		GetNetConnection():send(offCmd)
	end

	self.DestroyDialog()

	SelectServersDialog.getInstanceAndShow()
	return true
end

return LoginQueueDlg
