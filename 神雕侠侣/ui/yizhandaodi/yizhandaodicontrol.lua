require "ui.dialog"

YiZhanDaoDiLookDlg = {}
setmetatable(YiZhanDaoDiLookDlg, Dialog)
YiZhanDaoDiLookDlg.__index = YiZhanDaoDiLookDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function YiZhanDaoDiLookDlg.getInstance()
	-- print("enter get YiZhanDaoDiLookDlg dialog instance")
    if not _instance then
        _instance = YiZhanDaoDiLookDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function YiZhanDaoDiLookDlg.getInstanceAndShow()
	-- print("enter YiZhanDaoDiLookDlg dialog instance show")
    if not _instance then
        _instance = YiZhanDaoDiLookDlg:new()
        _instance:OnCreate()
	else
		-- print("set YiZhanDaoDiLookDlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function YiZhanDaoDiLookDlg.getInstanceNotCreate()
    return _instance
end

function YiZhanDaoDiLookDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function YiZhanDaoDiLookDlg.ToggleOpenClose()
	if not _instance then 
		_instance = YiZhanDaoDiLookDlg:new() 
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

function YiZhanDaoDiLookDlg.GetLayoutFileName()
    return "yizhandaodicell.layout"
end

function YiZhanDaoDiLookDlg:OnCreate()
	-- print("YiZhanDaoDiLookDlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pLook = winMgr:getWindow("Yizhandaodilook/button")
	self.m_pLeave  = winMgr:getWindow("Yizhandaodilook/button1")

    -- subscribe event
	self:GetWindow():subscribeEvent("WindowUpdate", YiZhanDaoDiLookDlg.HandleWindowUpdate, self)
	self.m_pLook:subscribeEvent("MouseClick", YiZhanDaoDiLookDlg.HandleLookBtnClicked, self)
	self.m_pLeave:subscribeEvent("MouseClick", YiZhanDaoDiLookDlg.HandleLeaveBtnClicked, self)

	-- print("YiZhanDaoDiLookDlg dialog oncreate end")
end

------------------- private: -----------------------------------

function YiZhanDaoDiLookDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, YiZhanDaoDiLookDlg)
    return self
end

function YiZhanDaoDiLookDlg:HandleLookBtnClicked(arg)
	local CRequestRankList = require "protocoldef.knight.gsp.ranklist.crequestranklist"
	local req = CRequestRankList.Create()
	req.ranktype = 36
	LuaProtocolManager.getInstance():send(req)
end

function YiZhanDaoDiLookDlg:HandleLeaveBtnClicked(arg)
	local s = MHSD_UTILS.get_msgtipstring(145730)
	GetMessageManager():AddConfirmBox(eConfirmNormal, s, YiZhanDaoDiLookDlg.HandleConfirmOK, self, CMessageManager.HandleDefaultCancelEvent, CMessageManager)
end

function YiZhanDaoDiLookDlg:HandleConfirmOK(arg)
	local CLeave = require "protocoldef.knight.gsp.activity.yzdd.cleave"
	local req = CLeave.Create()
	LuaProtocolManager.getInstance():send(req)
	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function YiZhanDaoDiLookDlg:HandleWindowUpdate(arg)
	if GetScene():GetMapID() ~= 1569 then
		YiZhanDaoDiLookDlg.DestroyDialog()
	end
end

return YiZhanDaoDiLookDlg
