--[[author: lvxiaolong
date: 2013/5/30
function: three exp tip
]]

require "ui.dialog"
require "utils.mhsdutils"


RichExpTipDlg = {}
setmetatable(RichExpTipDlg, Dialog)
RichExpTipDlg.__index = RichExpTipDlg 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

g_bCurInRichExpState = false

function RichExpTipDlg.getInstance()
	LogInfo("RichExpTipDlg.getInstance")
    if not _instance then
        _instance = RichExpTipDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function RichExpTipDlg.getInstanceAndShow()
	LogInfo("RichExpTipDlg.getInstanceAndShow")
    if not _instance then
        _instance = RichExpTipDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function RichExpTipDlg.getInstanceNotCreate()
    --print("RichExpTipDlg.getInstanceNotCreate")
    return _instance
end

function RichExpTipDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose() 
		_instance = nil
	end
end

function RichExpTipDlg.ToggleOpenClose()
	if not _instance then 
		_instance = RichExpTipDlg:new() 
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

function RichExpTipDlg.GetLayoutFileName()
    return "richexp.layout"
end

function RichExpTipDlg:OnCreate()
	LogInfo("enter RichExpTipDlg oncreate")
    
    Dialog.OnCreate(self)
    
	LogInfo("exit RichExpTipDlg OnCreate")
end

function RichExpTipDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, RichExpTipDlg)
    
    self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    --self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1

    return self
end


return RichExpTipDlg
