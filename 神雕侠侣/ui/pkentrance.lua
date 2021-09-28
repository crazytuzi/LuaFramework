require "ui.dialog"
require "utils.mhsdutils"


PKEntrance = {}
setmetatable(PKEntrance, Dialog)
PKEntrance.__index = PKEntrance

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function PKEntrance.getInstance()
	LogInfo("enter get pkentrance instance")
    if not _instance then
        _instance = PKEntrance:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function PKEntrance.getInstanceAndShow()
	LogInfo("enter pkentrance instance show")
    if not _instance then
        _instance = PKEntrance:new()
        _instance:OnCreate()
	else
		LogInfo("set pkentrance visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function PKEntrance.getInstanceNotCreate()
    return _instance
end

function PKEntrance.DestroyDialog()
	if _instance then 
		LogInfo("destroy pkentrance")
		_instance:OnClose()
		_instance = nil
	end
end

function PKEntrance.ToggleOpenClose()
	if not _instance then 
		_instance = PKEntrance:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end


function PKEntrance.StartUnlock(x, y)
	local instance = PKEntrance.getInstanceAndShow()	
	instance.m_fTime = 0
	instance.m_startX = x
	instance.m_startY = y
	instance:GetWindow():subscribeEvent("WindowUpdate", PKEntrance.HandleWindowUpdate, instance)	
end
----/////////////////////////////////////////------

function PKEntrance.GetLayoutFileName()
    return "pkenter.layout"
end

function PKEntrance:OnCreate()
	LogInfo("pkentrance oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow("pkenter/btn"))

    -- subscribe event
    self.m_pBtn:subscribeEvent("Clicked", PKEntrance.HandleBtnClicked, self) 

	self.m_endx = self:GetWindow():GetScreenPos().x 
	self.m_endy = self:GetWindow():GetScreenPos().y
	LogInfo("pkentrance oncreate end")

end

------------------- private: -----------------------------------


function PKEntrance:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PKEntrance)
    return self
end

function PKEntrance:HandleBtnClicked(args)
	LogInfo("pkentrance button clicked")
	GetPKManager():RequestStart()	
	return true
end

function PKEntrance:HandleWindowUpdate(args)

	if self.m_fTime then
		self.m_parentPos = self:GetWindow():getParent():GetScreenPos()
		local totalTime = 0.8
		local e = CEGUI.toUpdateEventArgs(args)
		self.m_fTime = self.m_fTime + e.d_timeSinceLastFrame	
		
		if totalTime > self.m_fTime then
			self:GetWindow():setXPosition(CEGUI.UDim(0, self.m_startX - self.m_parentPos.x + (self.m_endx - self.m_startX) * (self.m_fTime / totalTime)))
			self:GetWindow():setYPosition(CEGUI.UDim(0, self.m_startY - self.m_parentPos.y + (self.m_endy - self.m_startY) * (self.m_fTime / totalTime) * (self.m_fTime / totalTime)))
		else
			self:GetWindow():setXPosition(CEGUI.UDim(0, self.m_endx - self.m_parentPos.x))
			self:GetWindow():setYPosition(CEGUI.UDim(0, self.m_endy - self.m_parentPos.y))
			self.m_fTime = nil
			self.m_endx = nil
			self.m_endy = nil
		end
	end
	return true	
end


return PKEntrance
