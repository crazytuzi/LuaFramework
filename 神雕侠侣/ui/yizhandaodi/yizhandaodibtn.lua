require "ui.dialog"
require "utils.mhsdutils"

local YiZhanDaoDiBtn = {}

setmetatable(YiZhanDaoDiBtn, Dialog)
YiZhanDaoDiBtn.__index = YiZhanDaoDiBtn

YiZhanDaoDiBtn.iconShow = 0

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function YiZhanDaoDiBtn.getInstance()
    if not _instance then
        _instance = YiZhanDaoDiBtn:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function YiZhanDaoDiBtn.getInstanceAndShow()
    if not _instance then
        _instance = YiZhanDaoDiBtn:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function YiZhanDaoDiBtn.getInstanceNotCreate()
    return _instance
end

function YiZhanDaoDiBtn.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function YiZhanDaoDiBtn.ToggleOpenClose()
	if not _instance then 
		_instance = YiZhanDaoDiBtn:new() 
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

function YiZhanDaoDiBtn.GetLayoutFileName()
    return "yizhandaodibtn.layout"
end

function YiZhanDaoDiBtn:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow("yizhandaodibtn/button"))

    -- subscribe event
    self.m_pBtn:subscribeEvent("Clicked", YiZhanDaoDiBtn.HandleBtnClicked, self) 

end

------------------- private: -----------------------------------

function YiZhanDaoDiBtn:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, YiZhanDaoDiBtn)
    return self
end

function YiZhanDaoDiBtn:HandleBtnClicked(args)
  	GetMessageManager():AddConfirmBox(eConfirmNormal,
  		MHSD_UTILS.get_msgtipstring(tonumber(145780)),
  		YiZhanDaoDiBtn.HandleTransferClicked,
  		self,
  		CMessageManager.HandleDefaultCancelEvent,
  		CMessageManager)
	return true
end

function YiZhanDaoDiBtn:HandleTransferClicked()

	GetMessageManager():CloseConfirmBox(eConfirmNormal, false);
	
	local sb = StringBuilder:new()
	sb:SetNum("parameter1", "30")
	local tipMsg = sb:GetString(MHSD_UTILS.get_msgtipstring(145848))
	sb:delete()

	if GetDataManager():GetMainCharacterLevel() < 30 then
		GetGameUIManager():AddMessageTip(tipMsg)
	else
		local CAgreeDrawRole = require "protocoldef.knight.gsp.faction.cagreedrawrole"
		local req = CAgreeDrawRole.Create()
		req.agree = 1
		req.flag = 5
		LuaProtocolManager.getInstance():send(req)
	end

	return true 
end

return YiZhanDaoDiBtn
