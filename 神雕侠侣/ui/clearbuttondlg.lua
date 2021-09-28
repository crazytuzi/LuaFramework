require "ui.dialog"
require "utils.mhsdutils"


ClearButtonDlg = {}
setmetatable(ClearButtonDlg, Dialog)
ClearButtonDlg.__index = ClearButtonDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local totalTime = 1
function ClearButtonDlg.getInstance()
	LogInfo("enter get clearbuttondlg instance")
    if not _instance then
        _instance = ClearButtonDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ClearButtonDlg.getInstanceAndShow()
	LogInfo("enter clearbuttondlg instance show")
    if not _instance then
        _instance = ClearButtonDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set clearbuttondlg visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ClearButtonDlg.getInstanceNotCreate()
    return _instance
end

function ClearButtonDlg.DestroyDialog()
	if _instance then 
		LogInfo("destroy clearbuttondlg")
		_instance:OnClose()
		_instance = nil
	end
end

function ClearButtonDlg.ToggleOpenClose()
	if not _instance then 
		_instance = ClearButtonDlg:new() 
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

function ClearButtonDlg.GetLayoutFileName()
    return "clearbutton.layout"
end

function ClearButtonDlg:OnCreate()
	LogInfo("clearbuttondlg oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pImage = winMgr:getWindow("clearbutton/button")
	self.m_pWnd = winMgr:getWindow("clearbutton")
    -- subscribe event
    self.m_pWnd:subscribeEvent("MouseClick", ClearButtonDlg.HandleBtnClicked, self) 
    self.m_pWnd:subscribeEvent("WindowUpdate", ClearButtonDlg.HandleWindowUpdate, self) 
	self.m_time = 0
	self:GetWindow():setTopMost(true)
	
	LogInfo("clearbuttondlg oncreate end")
end

------------------- private: -----------------------------------


function ClearButtonDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ClearButtonDlg)
    return self
end

function ClearButtonDlg:HandleBtnClicked(args)
	LogInfo("clearbuttondlg button clicked")
	self:startUnlock()
	ClearButtonDlg.DestroyDialog()
	return true
end

function ClearButtonDlg:HandleWindowUpdate(args)
	local e = CEGUI.toUpdateEventArgs(args)
	self.m_time = self.m_time + e.d_timeSinceLastFrame
	if self.m_time > totalTime then
		self:startUnlock()
		ClearButtonDlg.DestroyDialog()	
	end
end

function ClearButtonDlg:setGuideID(id)
	self.m_iGuideId = id
	local record = knight.gsp.task.GetCArrowEffectTableInstance():getRecorder(id)
	if record.id ~= -1 then
		self.m_pImage:setProperty("Image", record.imagename)	
	end
end

function ClearButtonDlg:startUnlock()
	LogInfo("clearbuttondlg start unlock")
	local record = knight.gsp.task.GetCArrowEffectTableInstance():getRecorder(self.m_iGuideId)
    local winMgr = CEGUI.WindowManager:getSingleton()
	if record.usebutton ~= "0" then
		if winMgr:isWindowPresent(record.usebutton) then
			pWnd = winMgr:getWindow(record.usebutton)
			if MainControl.getInstanceNotCreate() then
                if MainControl.getInstanceNotCreate():IsInMainControl(pWnd) then
                    MainControl.getInstanceNotCreate():StartUnlock(self.m_pImage:GetScreenPos().x, self.m_pImage:GetScreenPos().y)
                end
			end
		else
			if self.m_iGuideId == 30037 then
				YaoQianShuEntrance.StartUnlock(self.m_pImage:GetScreenPos().x, self.m_pImage:GetScreenPos().y)
			end
            if self.m_iGuideId == 30038 then
                PKEntrance.StartUnlock(self.m_pImage:GetScreenPos().x, self.m_pImage:GetScreenPos().y);
            end
		end
	end
	
end

return ClearButtonDlg
