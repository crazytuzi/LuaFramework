require "ui.dialog"
GumumijingTime = {}
setmetatable(GumumijingTime, Dialog)
GumumijingTime.__index = GumumijingTime

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function GumumijingTime.getInstance()
    if not _instance then
        _instance = GumumijingTime:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function GumumijingTime.getInstanceAndShow()
    if not _instance then
        _instance = GumumijingTime:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function GumumijingTime.getInstanceNotCreate()
    return _instance
end

function GumumijingTime.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function GumumijingTime.ToggleOpenClose()
	if not _instance then 
		_instance = GumumijingTime:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function GumumijingTime.GetLayoutFileName()
    return "gumumijingtime.layout"
end
function GumumijingTime:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

	self.time = winMgr:getWindow("gumumijingtime/right/text4")
    self.tick = 0
	
end

------------------- private: -----------------------------------
function GumumijingTime:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, GumumijingTime)
    return self
end
function GumumijingTime:HandleClicked(args)

end

function GumumijingTime:getTimeLeft()
	if not GumumijingTime.left then
		require "ui.activity.activitymanager"
		GumumijingTime.left = ActivityManager.getInstance().m_timeLeft[160]
	end
	return GumumijingTime.left
end

function GumumijingTime:setTimeLeft()
	GumumijingTime.left = GumumijingTime.left - 1
end

function GumumijingTime:setDownCountText(args)
		self.time:setText(args) 
end

function GumumijingTime:run(delta)
    self.tick = self.tick + delta
    if self.tick > 1000 then
        self.tick = self.tick - 1000
        local foo
        if self:getTimeLeft() > 1 then
            foo = string.format("%02d:%02d:%02d",math.floor(self:getTimeLeft()  / 3600 ), math.floor(self:getTimeLeft()  % 3600 / 60  % 100), math.floor(self:getTimeLeft() % 3600 % 60))
            self:setTimeLeft()
            self:setDownCountText(foo)
        else
            foo = "00:00:00"
            self.DestroyDialog()
        end
    end
end

return GumumijingTime
