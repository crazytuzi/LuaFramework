--[[author: lvxiaolong
date: 2013/8/6
function: quick team button dlg
]]

require "ui.dialog"

require "utils.mhsdutils"

--require "manager.beanconfigmanager"

g_curQTeamServiceID = -1

QuickTeamBtn = {
m_timePassed = -1,
m_flyTime = -1,
m_posStart = nil,
m_posEnd = nil,
m_stateFly = false,
}
setmetatable(QuickTeamBtn, Dialog)
QuickTeamBtn.__index = QuickTeamBtn 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function QuickTeamBtn.IsShow()
    LogInfo("QuickTeamBtn.IsShow")
    
    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function QuickTeamBtn.getInstance()
	LogInfo("QuickTeamBtn.getInstance")
    if not _instance then
        _instance = QuickTeamBtn:new()
        _instance:OnCreate()
    end

    return _instance
end

function QuickTeamBtn.getInstanceAndShow()
	LogInfo("____QuickTeamBtn.getInstanceAndShow")
    if not _instance then
        _instance = QuickTeamBtn:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function QuickTeamBtn.getInstanceNotCreate()
    --print("QuickTeamBtn.getInstanceNotCreate")
    return _instance
end

function QuickTeamBtn.DestroyDialog()
	if _instance then
		_instance:OnClose() 
		_instance = nil
	end
end

function QuickTeamBtn.ToggleOpenClose()
	if not _instance then 
		_instance = QuickTeamBtn:new() 
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

function QuickTeamBtn.GetLayoutFileName()
    return "quickteambtn.layout"
end

function QuickTeamBtn:OnCreate()
	LogInfo("enter QuickTeamBtn oncreate")

    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows

    self.m_btn = CEGUI.Window.toPushButton(winMgr:getWindow("quickteambtn/btn"))
    self.m_btn:subscribeEvent("Clicked", QuickTeamBtn.HandleClickeBtn, self)
    
    self:GetWindow():subscribeEvent("WindowUpdate", QuickTeamBtn.HandleWindowUpdate, self)

	LogInfo("exit QuickTeamBtn OnCreate")
end

function QuickTeamBtn:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, QuickTeamBtn)
    
    --self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    --self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1

    return self
end

function QuickTeamBtn:HandleWindowUpdate(eventArgs)
    --[[LogInfo("____QuickTeamBtn:HandleWindowUpdate")
    
    if self.m_stateFly then
        print("____self.m_timePassed: " .. self.m_timePassed .. " self.m_flyTime: " .. self.m_flyTime)
        print("____self.m_posStart.x: " .. self.m_posStart.x .. " self.m_posStart.y: " .. self.m_posStart.y)
        print("____self.m_posEnd.x: " .. self.m_posEnd.x .. " self.m_posEnd.y: " .. self.m_posEnd.y)
    end]]

    if not self.m_stateFly or self.m_timePassed < 0 or self.m_flyTime <= 1 or self.m_posStart == nil or self.m_posEnd == nil then
        return true
    end
    
    self.m_timePassed = self.m_timePassed + CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame * 1000
    local rateTime = self.m_timePassed/self.m_flyTime

    if rateTime > 1 then
        self:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,self.m_posEnd.x),CEGUI.UDim(0,self.m_posEnd.y)))
        self.m_stateFly = false
    end
    
    local xDirChange = 0
    local yDirChange = 0
    local totalDX = self.m_posEnd.x - self.m_posStart.x
    local totalDY = self.m_posEnd.y - self.m_posStart.y
    if totalDX > 1 then
        xDirChange = 1
    elseif totalDX < -1 then
        xDirChange = -1
    end
    if totalDY > 1 then
        yDirChange = 1
    elseif totalDY < -1 then
        yDirChange = -1
    end

    local curX = self.m_posEnd.x
    local curY = self.m_posEnd.y
    if xDirChange ~= 0 then
        curX = self.m_posStart.x + rateTime * totalDX
    end
    if yDirChange ~= 0 then
        curY = self.m_posStart.y + rateTime * totalDY
    end
    
    self:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,curX),CEGUI.UDim(0,curY)))

    return true

end

function QuickTeamBtn:StartFly(flyTime, posStart, posEnd)
    LogInfo("____QuickTeamBtn:StartFly")

    if not posEnd then
        posEnd = {}
        posEnd.x = self:GetWindow():GetScreenPos().x
        posEnd.y = self:GetWindow():GetScreenPos().y
    end
    
    if flyTime and flyTime > 0 and posStart and posEnd then
        self.m_timePassed = 0
        self.m_flyTime = flyTime
        self.m_posStart = posStart
        self.m_posEnd = posEnd
        self.m_stateFly = true
    else
        self.m_timePassed = -1
        self.m_flyTime = -1
        self.m_posStart = nil
        self.m_posEnd = nil
        self.m_stateFly = false
    end
    
end

function QuickTeamBtn:HandleClickeBtn(args)
    LogInfo("____QuickTeamBtn:HandleClickeBtn")
    
    if self.m_stateFly then
        return true
    end

    QuickTeamDlg.ToggleOpenClose()
    QuickTeamBtn.DestroyDialog()

    return true
end


return QuickTeamBtn
