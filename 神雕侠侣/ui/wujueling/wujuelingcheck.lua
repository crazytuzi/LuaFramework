--[[author: lvxiaolong
date: 2013/6/19
function: wujueling check dialog
]]

require "ui.dialog"
require "utils.mhsdutils"
require "protocoldef.knight.gsp.task.cwujuelingvote"

WujuelingCheckDlg = {}
setmetatable(WujuelingCheckDlg, Dialog)
WujuelingCheckDlg.__index = WujuelingCheckDlg 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance
local maxTimeDisplayWJLCheck = 10

function WujuelingCheckDlg.IsShow()
    LogInfo("WujuelingCheckDlg.IsShow")
    
    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function WujuelingCheckDlg.getInstance()
	LogInfo("WujuelingCheckDlg.getInstance")
    if not _instance then
        _instance = WujuelingCheckDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function WujuelingCheckDlg.getInstanceAndShow()
	LogInfo("WujuelingCheckDlg.getInstanceAndShow")
    if not _instance then
        _instance = WujuelingCheckDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    _instance.m_fLeftTime = maxTimeDisplayWJLCheck
    return _instance
end

function WujuelingCheckDlg.getInstanceNotCreate()
    --print("WujuelingCheckDlg.getInstanceNotCreate")
    return _instance
end

function WujuelingCheckDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose() 
		_instance = nil
	end
end

function WujuelingCheckDlg.ToggleOpenClose()
	if not _instance then 
		_instance = WujuelingCheckDlg:new() 
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

function WujuelingCheckDlg.GetLayoutFileName()
    return "wujuelingcheck.layout"
end

function WujuelingCheckDlg:OnCreate()
	LogInfo("enter WujuelingCheckDlg oncreate")

    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows

    self.m_txtWndCtDown = winMgr:getWindow("wujuelingcheck/time")
    self:GetWindow():subscribeEvent("WindowUpdate", WujuelingCheckDlg.HandleWindowUpdate, self)
    self.m_fLeftTime = maxTimeDisplayWJLCheck
    
    self.m_btnYes = CEGUI.Window.toPushButton(winMgr:getWindow("wujuelingcheck/yes"))
    self.m_btnYes:subscribeEvent("Clicked", WujuelingCheckDlg.HandleYesBtnClicked, self)
    
    self.m_btnNo = CEGUI.Window.toPushButton(winMgr:getWindow("wujuelingcheck/no"))
    self.m_btnNo:subscribeEvent("Clicked", WujuelingCheckDlg.HandleNoBtnClicked, self)
    
    self.m_riEditBoxTitleMsg = CEGUI.Window.toRichEditbox(winMgr:getWindow("wujuelingcheck/txt"))

	LogInfo("exit WujuelingCheckDlg OnCreate")
end

function WujuelingCheckDlg:SetLevel(level)
    LogInfo("____WujuelingCheckDlg:SetLevel")
    
    if not level then
        return
    end

    local strbuilder = StringBuilder:new()
    local strMsg = ""
    strbuilder:SetNum("parameter1", level)
    strMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144985))
    
    self.m_riEditBoxTitleMsg:Clear()
    self.m_riEditBoxTitleMsg:AppendParseText(CEGUI.String(strMsg))
    self.m_riEditBoxTitleMsg:Refresh()
    
    strbuilder:delete()
end

function WujuelingCheckDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, WujuelingCheckDlg)
    
    --self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    --self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1

    return self
end

function WujuelingCheckDlg:HandleWindowUpdate(eventArgs)
    
    self.m_fLeftTime = self.m_fLeftTime or maxTimeDisplayWJLCheck
    
    self.m_fLeftTime = self.m_fLeftTime - CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame
    if self.m_fLeftTime > 0 then
        self.m_txtWndCtDown:setText(tostring(1+math.floor(self.m_fLeftTime)))
    else
        
        self.m_fLeftTime = maxTimeDisplayWJLCheck
        WujuelingCheckDlg.DestroyDialog()
    end

    return true

end


function WujuelingCheckDlg:HandleYesBtnClicked(args)
    LogInfo("___WujuelingCheckDlg:HandleYesBtnClicked")
    
    local wujuelingVoteAction = CWuJueLingVote.Create()
	wujuelingVoteAction.result = 0
	LuaProtocolManager.getInstance():send(wujuelingVoteAction)

    WujuelingCheckDlg.DestroyDialog()

    return true
end

function WujuelingCheckDlg:HandleNoBtnClicked(args)
    LogInfo("___WujuelingCheckDlg:HandleNoBtnClicked")
    
    local wujuelingVoteAction = CWuJueLingVote.Create()
	wujuelingVoteAction.result = 1
	LuaProtocolManager.getInstance():send(wujuelingVoteAction)

    WujuelingCheckDlg.DestroyDialog()

    return true
end


return WujuelingCheckDlg
