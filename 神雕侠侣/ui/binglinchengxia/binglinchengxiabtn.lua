require "ui.dialog"
require "utils.mhsdutils"

local BingLinChengXiaBtn = {}

setmetatable(BingLinChengXiaBtn, Dialog)
BingLinChengXiaBtn.__index = BingLinChengXiaBtn

BingLinChengXiaBtn.iconShow = 0

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function BingLinChengXiaBtn.getInstance()
    if not _instance then
        _instance = BingLinChengXiaBtn:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function BingLinChengXiaBtn.getInstanceAndShow()
    if not _instance then
        _instance = BingLinChengXiaBtn:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function BingLinChengXiaBtn.getInstanceNotCreate()
    return _instance
end

function BingLinChengXiaBtn.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function BingLinChengXiaBtn.ToggleOpenClose()
	if not _instance then 
		_instance = BingLinChengXiaBtn:new() 
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

function BingLinChengXiaBtn.GetLayoutFileName()
    return "binglinchengxiabtn.layout"
end

function BingLinChengXiaBtn:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow("binglinchengxiabtn/button"))

    -- subscribe event
    self.m_pBtn:subscribeEvent("Clicked", BingLinChengXiaBtn.HandleBtnClicked, self) 

    self:HandleBtnClicked()

end

------------------- private: -----------------------------------

function BingLinChengXiaBtn:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BingLinChengXiaBtn)
    return self
end

function BingLinChengXiaBtn:HandleBtnClicked(args)
  	GetMessageManager():AddConfirmBox(eConfirmNormal,
  		MHSD_UTILS.get_msgtipstring(tonumber(145858)),
  		BingLinChengXiaBtn.HandleTransferClicked,
  		self,
  		CMessageManager.HandleDefaultCancelEvent,
  		CMessageManager)
	return true
end

function BingLinChengXiaBtn:HandleTransferClicked()
	
	GetMessageManager():CloseConfirmBox(eConfirmNormal, false);
	
	local sb = StringBuilder:new()
	sb:SetNum("parameter1", "50")
	local tipMsg = sb:GetString(MHSD_UTILS.get_msgtipstring(145848))
	sb:delete()

	if GetDataManager():GetMainCharacterLevel() < 50 then
		GetGameUIManager():AddMessageTip(tipMsg)
	else
		local CAgreeDrawRole = require "protocoldef.knight.gsp.faction.cagreedrawrole"
		local req = CAgreeDrawRole.Create()
		req.agree = 1
		req.flag = 7
		LuaProtocolManager.getInstance():send(req)
	end

	return true 
end


return BingLinChengXiaBtn
