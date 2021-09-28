require "utils.mhsdutils"
require "ui.dialog"

ActivityEntrance = {}
setmetatable(ActivityEntrance, Dialog)
ActivityEntrance.__index = ActivityEntrance

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ActivityEntrance.getInstance()
	LogInfo("enter get activityentrance instance")
    if not _instance then
        _instance = ActivityEntrance:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ActivityEntrance.getInstanceAndShow()
	LogInfo("enter activityentrance instance show")
    if not _instance then
        _instance = ActivityEntrance:new()
        _instance:OnCreate()
	else
		LogInfo("set activityentrance visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ActivityEntrance.getInstanceNotCreate()
    return _instance
end

function ActivityEntrance.DestroyDialog()
	if _instance then 
		LogInfo("destroy activityentrance")
		if CDeviceInfo:GetDeviceType() == 3 then
			local sizeMem = CDeviceInfo:GetTotalMemSize()
			if sizeMem <= 1024 then
				if _instance.m_ani then
					local aniMan = CEGUI.AnimationManager:getSingleton()
					aniMan:destroyAnimationInstance(_instance.m_ani)
					_instance.m_ani = nil
				end
			end
		end
		_instance:OnClose()
		_instance = nil
	end
end

function ActivityEntrance.ToggleOpenClose()
	if not _instance then 
		_instance = ActivityEntrance:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ActivityEntrance.refreshEffect()
	LogInfo("activityentrance refresh effect")
	if _instance and ActivityManager.getInstanceNotCreate() then
		if ActivityManager.getInstanceNotCreate():getNeedEffect() then
			if not _instance.m_effect then
				GetGameUIManager():AddUIEffect(_instance:GetWindow(), MHSD_UTILS.get_effectpath(10305))	
				_instance.m_effect = true 
				if CDeviceInfo:GetDeviceType() == 3 then
					local sizeMem = CDeviceInfo:GetTotalMemSize()
					if sizeMem <= 1024 then
						if _instance.m_ani then
							_instance.m_ani:start()
						end
					end
				end
			end
		else
			GetGameUIManager():RemoveUIEffect(_instance:GetWindow())
			_instance.m_effect = nil
			if CDeviceInfo:GetDeviceType() == 3 then
				local sizeMem = CDeviceInfo:GetTotalMemSize()
				if sizeMem <= 1024 then
					if _instance.m_ani then
						_instance.m_ani:stop()
					end
				end
			end
		end
	end	

end

----/////////////////////////////////////////------

function ActivityEntrance.GetLayoutFileName()
    return "activitybtn.layout"
end

function ActivityEntrance:OnCreate()
	LogInfo("activityentrance oncreate begin")
    Dialog.OnCreate(self)

	if CDeviceInfo:GetDeviceType() == 3 then
		local sizeMem = CDeviceInfo:GetTotalMemSize()
		if sizeMem <= 1024 then
			local aniMan = CEGUI.AnimationManager:getSingleton()
			aniMan:loadAnimationsFromXML("example.xml")
			local animation = aniMan:getAnimation("flash")
			self.m_ani = aniMan:instantiateAnimation(animation)
			self.m_ani:setTargetWindow(self:GetWindow())
		end
	end
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow("activitybtn/btn"))

    -- subscribe event
    self.m_pBtn:subscribeEvent("Clicked", ActivityEntrance.HandleBtnClicked, self) 
	ActivityEntrance.refreshEffect()
	LogInfo("activityentrance oncreate end")
end

------------------- private: -----------------------------------


function ActivityEntrance:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ActivityEntrance)
    return self
end

function ActivityEntrance:HandleBtnClicked(args)
	LogInfo("activityentrance button clicked")
	GetNetConnection():send(knight.gsp.task.activelist.CRefreshActivityListFinishTimes())
	return true
end


return ActivityEntrance
