require "ui.dialog"
require "utils.mhsdutils"

local XingXiaZhangYiBtn = {}

setmetatable(XingXiaZhangYiBtn, Dialog)
XingXiaZhangYiBtn.__index = XingXiaZhangYiBtn

XingXiaZhangYiBtn.iconShow = 0

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function XingXiaZhangYiBtn.getInstance()
    if not _instance then
        _instance = XingXiaZhangYiBtn:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function XingXiaZhangYiBtn.getInstanceAndShow()
    if not _instance then
        _instance = XingXiaZhangYiBtn:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function XingXiaZhangYiBtn.getInstanceNotCreate()
    return _instance
end

function XingXiaZhangYiBtn.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function XingXiaZhangYiBtn.ToggleOpenClose()
	if not _instance then 
		_instance = XingXiaZhangYiBtn:new() 
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

function XingXiaZhangYiBtn.GetLayoutFileName()
    return "xingxiazhangyibtn.layout"
end

function XingXiaZhangYiBtn:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow("xingxiazhangyibtn/button"))

    -- subscribe event
    self.m_pBtn:subscribeEvent("Clicked", XingXiaZhangYiBtn.HandleBtnClicked, self) 

end

------------------- private: -----------------------------------

function XingXiaZhangYiBtn:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, XingXiaZhangYiBtn)
    return self
end

function XingXiaZhangYiBtn:HandleBtnClicked(args)
  	GetMessageManager():AddConfirmBox(eConfirmNormal,
  		MHSD_UTILS.get_msgtipstring(tonumber(146181)),
  		XingXiaZhangYiBtn.HandleTransferClicked,
  		self,
  		CMessageManager.HandleDefaultCancelEvent,
  		CMessageManager)
	return true
end

function XingXiaZhangYiBtn:HandleTransferClicked()

	GetMessageManager():CloseConfirmBox(eConfirmNormal, false);
	
	local sb = StringBuilder:new()
	sb:SetNum("parameter1", "70")
	local tipMsg = sb:GetString(MHSD_UTILS.get_msgtipstring(145848))
	sb:delete()

	if GetDataManager():GetMainCharacterLevel() < 70 then
		GetGameUIManager():AddMessageTip(tipMsg)
	else
		GetMainCharacter():FlyOrWarkToPos(1013, 100, 117, -1)
	end	

	return true 
end

return XingXiaZhangYiBtn
