--[[author: lvxiaolong
date: 2013/6/21
function: news warn dialog
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"

NewsWarnDlg = {}
setmetatable(NewsWarnDlg, Dialog)
NewsWarnDlg.__index = NewsWarnDlg 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function NewsWarnDlg.IsShow()
    LogInfo("NewsWarnDlg.IsShow")
    
    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function NewsWarnDlg.getInstance()
	LogInfo("NewsWarnDlg.getInstance")
    if not _instance then
        _instance = NewsWarnDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function NewsWarnDlg.getInstanceAndShow()
	LogInfo("____NewsWarnDlg.getInstanceAndShow")
    if not _instance then
        _instance = NewsWarnDlg:new()
        _instance:OnCreate()
	else
        _instance:RefreshUpdateContent()
		_instance:SetVisible(true)
    end

    return _instance
end

function NewsWarnDlg.getInstanceNotCreate()
    --print("NewsWarnDlg.getInstanceNotCreate")
    return _instance
end

function NewsWarnDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose() 
		_instance = nil
	end
end

function NewsWarnDlg.ToggleOpenClose()
	if not _instance then 
		_instance = NewsWarnDlg:new() 
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

function NewsWarnDlg.GetLayoutFileName()
    return "newswarn.layout"
end

function NewsWarnDlg:OnCreate()
	LogInfo("enter NewsWarnDlg oncreate")

    Dialog.OnCreate(self)
    --self:GetWindow():setModalState(true)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows

    self.m_txtUpdateTime = winMgr:getWindow("NewsWarn/time")
    
    self.m_boxNewsContent = CEGUI.Window.toRichEditbox(winMgr:getWindow("NewsWarn/main") )
    self.m_boxNewsContent:setReadOnly(true)
    self.m_boxNewsContent:setTopAfterLoadFont(true)

    self.m_btnOK = CEGUI.Window.toPushButton(winMgr:getWindow("NewsWarn/btn"))
    self.m_btnOK:subscribeEvent("Clicked", NewsWarnDlg.HandleOKBtnClicked, self)
    
    self:RefreshUpdateContent()

	LogInfo("exit NewsWarnDlg OnCreate")
end

function NewsWarnDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, NewsWarnDlg)
    
    --self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    --self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1

    return self
end


function NewsWarnDlg:HandleOKBtnClicked(args)
    LogInfo("___NewsWarnDlg:HandleOKBtnClicked")
    
    NewsWarnDlg.DestroyDialog()
    return true
end

local NEWS_WARN_INFO_INI = "NewsWarnInfo.ini"

function NewsWarnDlg.GetLatestNewsWarn()
    LogInfo("____NewsWarnDlg.GetLatestNewsWarn")
        
    --first we need to find the newest updateID in the form
    local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.systemsetting.cgengxingonggao")
    local record = tt:getRecorder(1)
	
    if record ~= nil and record.banbenhao ~= nil then
        
        LogInfo("____record.banbenhao: " .. record.banbenhao)
        
        local strIniPath = NEWS_WARN_INFO_INI
        local iniMgr = CIniManager(strIniPath)

        local bExist, strBanbenhao, nullpart1, nullpart2 = false, ""
        bExist, nullpart1, nullpart2, strBanbenhao = iniMgr:GetValueByName("NewsWarnRecord", "banbenhao", "")
        if bExist then
            
            LogInfo("____strBanbenhao: " .. strBanbenhao)
            
            if record.banbenhao > math.floor(tonumber(strBanbenhao)) then
                LogInfo("____NewsWarnDlg.GetLatestNewsWarn: return true")
                iniMgr:WriteValueByName("NewsWarnRecord", "banbenhao", tostring(record.banbenhao))
                return true
            else
                return false
            end
        else
            LogInfo("____NewsWarnDlg.GetLatestNewsWarn: return true")
            iniMgr:WriteValueByName("NewsWarnRecord", "banbenhao", tostring(record.banbenhao))
            return true
        end
    else
        LogInfo("____record==nil or record.banbenhao==nil")
        return false
    end
end

function NewsWarnDlg:RefreshUpdateContent()
    LogInfo("____NewsWarnDlg:RefreshUpdateContent")
    
    local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.systemsetting.cgengxingonggao")
    local firstRecord = tt:getRecorder(1)
    local allIDs = tt:getAllID()
    
    if allIDs == nil or firstRecord == nil then
        LogInfo("____got no record")
        self.m_txtUpdateTime:setText("")
        self.m_boxNewsContent:Clear()
        self.m_boxNewsContent:Refresh()
        return
    end

    self.m_txtUpdateTime:setText(firstRecord.gengxinshijian)

    self.m_boxNewsContent:Clear()
    for k,v in pairs(allIDs) do
        local record = tt:getRecorder(v)
        
        if record ~= nil then
            --self.m_boxNewsContent:AppendText(CEGUI.String(record.content))
            self.m_boxNewsContent:AppendParseText(CEGUI.String(record.content))
            self.m_boxNewsContent:AppendBreak()
        else
            LogInfo("____get nil record")
        end
    end
    self.m_boxNewsContent:Refresh()
    self.m_boxNewsContent:HandleTop()
end


return NewsWarnDlg
