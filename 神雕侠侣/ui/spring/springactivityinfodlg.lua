require "ui.dialog"

SpringActivityInfoDlg = {}
setmetatable(SpringActivityInfoDlg, Dialog)
SpringActivityInfoDlg.__index = SpringActivityInfoDlg 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function SpringActivityInfoDlg.getInstance()
    if not _instance then
        _instance = SpringActivityInfoDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function SpringActivityInfoDlg.getInstanceAndShow()
    if not _instance then
        _instance = SpringActivityInfoDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function SpringActivityInfoDlg.getInstanceNotCreate()
    return _instance
end

function SpringActivityInfoDlg.DestroyDialog()
	if _instance then
		_instance:OnClose() 
		_instance = nil
	end
end

function SpringActivityInfoDlg.ToggleOpenClose()
	if not _instance then 
		_instance = SpringActivityInfoDlg:new() 
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

function SpringActivityInfoDlg.GetLayoutFileName()
    return "springfestivalinfo.layout"
end

function SpringActivityInfoDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SpringActivityInfoDlg)

    return self
end

function SpringActivityInfoDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows

    self.m_txtInfo = CEGUI.Window.toRichEditbox(winMgr:getWindow("springfestivalinfo/back/info"))
    self.m_btnClose = CEGUI.Window.toPushButton(winMgr:getWindow("springfestivalinfo/close"))

    self.m_btnClose:subscribeEvent("Clicked", SpringActivityInfoDlg.DestroyDialog, self)

end

function SpringActivityInfoDlg:SetInfo(id)
    local activityInfo = 
        BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cspringentrance"):getRecorder(tonumber(id))
    self.m_txtInfo:Clear()
    self.m_txtInfo:AppendParseText(CEGUI.String(activityInfo.info))
    self.m_txtInfo:Refresh()
    self.m_txtInfo:HandleTop()
end


return SpringActivityInfoDlg
