local Dialog = require "ui.dialog"
local FirstChargeDlg = require "ui.firstchargedlg"
local ChargeDialog = require "ui.chargedialog"

FirstChargeBtn = {}
setmetatable(FirstChargeBtn, Dialog)
FirstChargeBtn.__index = FirstChargeBtn

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FirstChargeBtn.getInstance()
	LogInfo("FirstChargeBtn getinstance")
    if not _instance then
        _instance = FirstChargeBtn:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function FirstChargeBtn.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = FirstChargeBtn:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function FirstChargeBtn.getInstanceNotCreate()
    return _instance
end

function FirstChargeBtn.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function FirstChargeBtn.ToggleOpenClose()
	if not _instance then 
		_instance = FirstChargeBtn:new() 
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

function FirstChargeBtn.GetLayoutFileName()
    return "addcashmorebtn.layout"
end

function FirstChargeBtn:OnCreate()
	LogInfo("enter FirstChargeBtn oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_ChargeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("addcashmorebtn/go"))

    -- subscribe event
	self.m_ChargeBtn:subscribeEvent("Clicked", FirstChargeBtn.HandleChargeBtnClick, self) 

    --init settings
end

function FirstChargeBtn:RefreshByChargeState(state, flag)
	self.m_ChargeState = state
	self.m_ChargeFlag = flag

	self.m_ChargeBtn:setProperty("HoverImage", "set:MainControl46 image:chongzhidalibtn")
	self.m_ChargeBtn:setProperty("NormalImage", "set:MainControl46 image:chongzhidalibtn")
	self.m_ChargeBtn:setProperty("PushedImage", "set:MainControl46 image:chongzhidalibtn")
	self.m_ChargeBtn:setProperty("DisabledImage", "set:MainControl46 image:chongzhidalibtn")

	if self.m_ChargeState==1 then
		GetGameUIManager():AddUIEffect(self:GetWindow(), MHSD_UTILS.get_effectpath(10305))
	elseif self.m_ChargeState==2 and self.m_ChargeFlag==0 then
        FirstChargeBtn.DestroyDialog()
    elseif self.m_ChargeState==2 and self.m_ChargeFlag==1 then
    	self.m_ChargeBtn:setProperty("HoverImage", "set:MainControl46 image:chongzhifanbeibtn")
		self.m_ChargeBtn:setProperty("NormalImage", "set:MainControl46 image:chongzhifanbeibtn")
		self.m_ChargeBtn:setProperty("PushedImage", "set:MainControl46 image:chongzhifanbeibtn")
		self.m_ChargeBtn:setProperty("DisabledImage", "set:MainControl46 image:chongzhifanbeibtn")
	end
end
------------------- private: -----------------------------------


function FirstChargeBtn:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FirstChargeBtn)

    return self
end


function FirstChargeBtn:HandleChargeBtnClick(args)
	if self.m_ChargeState~=2 then
		FirstChargeDlg.getInstanceAndShow():InitByState(self.m_ChargeState)
    elseif self.m_ChargeState==2 and self.m_ChargeFlag==1 then
    	ChargeDialog.GeneralReqCharge()
	end
end


return FirstChargeBtn
