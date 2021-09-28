require "ui.dialog"
require "utils.mhsdutils"
LoginRewardEntranceDlg = {}
setmetatable(LoginRewardEntranceDlg, Dialog)
LoginRewardEntranceDlg.__index = LoginRewardEntranceDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function LoginRewardEntranceDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = LoginRewardEntranceDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function LoginRewardEntranceDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = LoginRewardEntranceDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LoginRewardEntranceDlg.getInstanceNotCreate()
    return _instance
end

function LoginRewardEntranceDlg.DestroyDialog()
	if _instance then 
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

function LoginRewardEntranceDlg.ToggleOpenClose()
	if not _instance then 
		_instance = LoginRewardEntranceDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function LoginRewardEntranceDlg.GetLayoutFileName()
    return "loginrewardentrance.layout"
end

local EFFECT_ID = 10305
function LoginRewardEntranceDlg:OnCreate()
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
	self.bt = CEGUI.Window.toPushButton(winMgr:getWindow("loginrewardentrance/Btn"))
	self.bt:subscribeEvent("Clicked",LoginRewardEntranceDlg.HandleClicked,self)
--		self:GetWindow():setXPosition(CEGUI.UDim(self:GetWindow():getXPosition().scale,self:GetWindow():getXPosition().offset - 100))
end

------------------- private: -----------------------------------
function LoginRewardEntranceDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, LoginRewardEntranceDlg)
    return self
end
function LoginRewardEntranceDlg:HandleClicked(args)
	require "ui.loginreward.loginrewarddlg":getInstanceAndShow()
end
function LoginRewardEntranceDlg:process()
	local winMgr = CEGUI.WindowManager:getSingleton()
	if require("ui.loginreward.loginrewarddlg").hasShow then
		GetGameUIManager():AddUIEffect(winMgr:getWindow("loginrewardentrance/Btn/Geffect"), MHSD_UTILS.get_effectpath(EFFECT_ID))
		if CDeviceInfo:GetDeviceType() == 3 then
			local sizeMem = CDeviceInfo:GetTotalMemSize()
			if sizeMem <= 1024 then
				if self.m_ani then
					self.m_ani:start()
				end
			end
		end
	else
		GetGameUIManager():RemoveUIEffect((winMgr:getWindow("loginrewardentrance/Btn/Geffect")))
        if CDeviceInfo:GetDeviceType() == 3 then
			local sizeMem = CDeviceInfo:GetTotalMemSize()
			if sizeMem <= 1024 then
				if self.m_ani then
					self.m_ani:stop()
				end
			end
		end
	end
end
return LoginRewardEntranceDlg
