require "ui.dialog"
require "utils.mhsdutils"


YaoQianShuEntrance = {}
setmetatable(YaoQianShuEntrance, Dialog)
YaoQianShuEntrance.__index = YaoQianShuEntrance

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function YaoQianShuEntrance.getInstance()
	print("enter get yaoqianshuentrance instance")
    if not _instance then
        _instance = YaoQianShuEntrance:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function YaoQianShuEntrance.getInstanceAndShow()
	print("enter yaoqianshuentrance instance show")
    if not _instance then
        _instance = YaoQianShuEntrance:new()
        _instance:OnCreate()
	else
		print("set yaoqianshuentrance visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function YaoQianShuEntrance.getInstanceNotCreate()
    return _instance
end

function YaoQianShuEntrance.DestroyDialog()
	YaoQianShuDlg.DestroyDialog()
	if _instance then 
		print("destroy yaoqianshuentrance")
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

function YaoQianShuEntrance.ToggleOpenClose()
	if not _instance then 
		_instance = YaoQianShuEntrance:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end


function YaoQianShuEntrance.RefreshEffect()
	if YaoQianShuEntrance.getInstanceNotCreate()  then
		YaoQianShuEntrance.getInstanceNotCreate():refresh()
	end
end

function YaoQianShuEntrance.HandleSRspMoneyTree(cd_time, unpayremaintimes, payremaintimes, yuanbao, takemoneysuc)
	print("yaoqianshuentrance handle rspmoneytree")
	GetYaoQianShuManager():setCountDown(cd_time / 1000)
	if unpayremaintimes <= 0 then
		GetYaoQianShuManager():setNoMoreTimes(true)
	end
	if _instance then
		if takemoneysuc == 1 and YaoQianShuDlg.getInstanceNotCreate() then
			GetGameUIManager():AddUIEffect(YaoQianShuDlg.getInstanceNotCreate().m_pEffectWnd , MHSD_UTILS.get_effectpath(10373), false)
		end	
		_instance:RefreshInfo(cd_time, unpayremaintimes, payremaintimes, yuanbao)	
	end
end

function YaoQianShuEntrance.RefreshTime()
	if _instance then
		local time = GetYaoQianShuManager():getCountDown()
		if time > 0 then
			local hour = math.floor(time / 3600)
			local min = math.floor((time %3600) / 60)
			local second = math.floor(time % 60)
			if hour > 0 then
				_instance.m_pTime:setText(string.format("%02d:%02d:%02d", hour, min, second))
			else
				_instance.m_pTime:setText(string.format("%02d:%02d", min, second))
			end
		else
			_instance.m_pTime:setText(MHSD_UTILS.get_resstring(2936))
		end	
	end
end


function YaoQianShuEntrance.StartUnlock(x, y)
	local instance = YaoQianShuEntrance.getInstanceAndShow()	
	instance.m_fTime = 0
	instance.m_startX = x
	instance.m_startY = y
	instance:GetWindow():subscribeEvent("WindowUpdate", YaoQianShuEntrance.HandleWindowUpdate, instance)	
end

function YaoQianShuEntrance.setVisible(b)
	if _instance then
		_instance:SetVisible(b)
	end
end

----/////////////////////////////////////////------

function YaoQianShuEntrance.GetLayoutFileName()
    return "yaoqianshuentrance.layout"
end

function YaoQianShuEntrance:OnCreate()
	print("yaoqianshuentrance oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow("yaoqianshuentrance/btn"))
	self.m_pTime = winMgr:getWindow("yaoqianshuentrance/time")

    -- subscribe event
    self.m_pBtn:subscribeEvent("Clicked", YaoQianShuEntrance.HandleBtnClicked, self) 

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

	self:refresh() 
	self.m_endx = self:GetWindow():GetScreenPos().x 
	self.m_endy = self:GetWindow():GetScreenPos().y

	GetYaoQianShuManager():request(0, 0)
	print("yaoqianshuentrance oncreate end")

end

------------------- private: -----------------------------------


function YaoQianShuEntrance:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, YaoQianShuEntrance)
    return self
end

function YaoQianShuEntrance:HandleBtnClicked(args)
	print("yaoqainshuentrance button clicked")
	YaoQianShuDlg.getInstanceAndShow()
	return true
end

--play effect
function YaoQianShuEntrance:refresh()
	print("yaoqianshuentrance refresh")
	local effectOn = GetYaoQianShuManager():getEffectEnabel()
	if not effectOn then
		GetGameUIManager():RemoveUIEffect(self:GetWindow())
		if CDeviceInfo:GetDeviceType() == 3 then
			local sizeMem = CDeviceInfo:GetTotalMemSize()
			if sizeMem <= 1024 then
				if self.m_ani then
					self.m_ani:stop()
				end
			end
		end
	elseif not GetGameUIManager():IsWindowHaveEffect(self:GetWindow())  then
		self.m_pTime:setText(MHSD_UTILS.get_resstring(2936))
		GetGameUIManager():AddUIEffect(self:GetWindow(), MHSD_UTILS.get_effectpath(10305))

		if CDeviceInfo:GetDeviceType() == 3 then
			local sizeMem = CDeviceInfo:GetTotalMemSize()
			if sizeMem <= 1024 then
				if self.m_ani then
					self.m_ani:start()
				end
			end
		end
	end
end

function YaoQianShuEntrance:HandleWindowUpdate(args)

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


function YaoQianShuEntrance:RefreshInfo(cd_time, unpayremaintimes, payremaintimes, yuanbao)
	self.m_iUnpayRemainTimes = unpayremaintimes
	if YaoQianShuDlg.getInstanceNotCreate() then
		YaoQianShuDlg.getInstanceNotCreate():RefreshInfo()
	end

end
return YaoQianShuEntrance
