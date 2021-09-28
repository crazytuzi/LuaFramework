require "utils.mhsdutils"
require "ui.dialog"

ActivityDlgInfoCell = {}
setmetatable(ActivityDlgInfoCell, Dialog)
ActivityDlgInfoCell.__index = ActivityDlgInfoCell

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ActivityDlgInfoCell.getInstance()
	LogInfo("enter get ActivityDlgInfoCell instance")
    if not _instance then
        _instance = ActivityDlgInfoCell:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ActivityDlgInfoCell.getInstanceAndShow()
	LogInfo("enter ActivityDlgInfoCell instance show")
    if not _instance then
        _instance = ActivityDlgInfoCell:new()
        _instance:OnCreate()
	else
		LogInfo("set ActivityDlgInfoCell visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ActivityDlgInfoCell.getInstanceNotCreate()
    return _instance
end

function ActivityDlgInfoCell.DestroyDialog()
	if _instance then 
		LogInfo("destroy ActivityDlgInfoCell")
		_instance:OnClose()
		_instance = nil
	end
end

function ActivityDlgInfoCell.ToggleOpenClose()
	if not _instance then 
		_instance = ActivityDlgInfoCell:new() 
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

function ActivityDlgInfoCell.GetLayoutFileName()
    return "activitydlginfocell.layout"
end

function ActivityDlgInfoCell:OnCreate()
	LogInfo("ActivityDlgInfoCell oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pInfo = CEGUI.Window.toRichEditbox(winMgr:getWindow("activitydlginfocell/main"))
	self.m_pCloseBtn = CEGUI.Window.toPushButton(winMgr:getWindow("activitydlginfocell/closed"))

    -- subscribe event
    self.m_pCloseBtn:subscribeEvent("Clicked", ActivityDlgInfoCell.HandleCloseBtnClicked, self) 

	self.m_pInfo:setTopAfterLoadFont(true)
	LogInfo("ActivityDlgInfoCell oncreate end")
end

------------------- private: -----------------------------------


function ActivityDlgInfoCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ActivityDlgInfoCell)
    return self
end

function ActivityDlgInfoCell:setInfo(id,str)
	LogInfo("ActivityDlgInfoCell set info")
    if id then
        local record = knight.gsp.task.GetCTaskListTableInstance():getRecorder(id)
        self.m_pInfo:Clear()
        self.m_pInfo:AppendParseText(CEGUI.String(record.specinfo))
        self.m_pInfo:Refresh()
        self.m_pInfo:HandleTop()
    elseif str then
        self.m_pInfo:Clear()
        self.m_pInfo:AppendParseText(CEGUI.String(str))
        self.m_pInfo:Refresh()
        self.m_pInfo:HandleTop()
    end
end

function ActivityDlgInfoCell:HandleCloseBtnClicked(args)
	LogInfo("ActivityDlgInfoCell Handle close button clicked")
	ActivityDlgInfoCell.DestroyDialog()	
end

return ActivityDlgInfoCell
