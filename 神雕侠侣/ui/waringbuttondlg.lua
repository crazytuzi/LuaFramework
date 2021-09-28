require "ui.dialog"
require "utils.mhsdutils"
WaringButtonDlg = {}
setmetatable(WaringButtonDlg, Dialog)
WaringButtonDlg.__index = WaringButtonDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function WaringButtonDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = WaringButtonDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function WaringButtonDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = WaringButtonDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end
function WaringButtonDlg.getInstanceNotCreate()
    return _instance
end

function WaringButtonDlg.DestroyDialog()
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

function WaringButtonDlg.ToggleOpenClose()
	if not _instance then 
		_instance = WaringButtonDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function WaringButtonDlg.GetLayoutFileName()
    return "waringbutton.layout"
end
local EFFECT_ID = 10305
function WaringButtonDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pWaringlist = CEGUI.Window.toPushButton(winMgr:getWindow("waringbutton"))	
    self.m_pWaringlist:subscribeEvent("Clicked", WaringButtonDlg.clickHandler, self) 
	
    if CDeviceInfo:GetDeviceType() == 3 then
		local sizeMem = CDeviceInfo:GetTotalMemSize()
		if sizeMem <= 1024 then
			local aniMan = CEGUI.AnimationManager:getSingleton()
			aniMan:loadAnimationsFromXML("example.xml")
			local animation = aniMan:getAnimation("flash")
			self.m_ani = aniMan:instantiateAnimation(animation)
			self.m_ani:setTargetWindow(self:GetWindow())
            self.m_ani:start()
		end
	else
		GetGameUIManager():AddUIEffect(self.m_pMainFrame, MHSD_UTILS.get_effectpath(EFFECT_ID))
	end
end

------------------- private: -----------------------------------
function WaringButtonDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, WaringButtonDlg)
	self.m_bIsVisibleBeforeBattle = false
	self.m_bIsVisibleBeforeEnchou = false
    return self
end

function WaringButtonDlg:StartBattle()
	self.m_bIsVisibleBeforeBattle = false
	if self:IsVisible() then
		self.m_bIsVisibleBeforeBattle = true
		self:SetVisible(false)
	end 
end
function WaringButtonDlg:EndBattle()
	if self.m_bIsVisibleBeforeBattle then
		self.m_bIsVisibleBeforeBattle = false 
		self:SetVisible(true)
	end 
end

function WaringButtonDlg:StartEnchou()
	self.m_bIsVisibleBeforeEnchou = false
	if self:IsVisible() then
		self.m_bIsVisibleBeforeEnchou = true
		self:SetVisible(false)
		print("cccccc",WaringButtonDlg.getInstanceNotCreate(),WaringButtonDlg.getInstanceNotCreate():IsVisible())

	end 
end
function WaringButtonDlg:EndEnchou()
	print("WaringButtonDlgEndEnchou",debug.getinfo(2).name,debug.getinfo(2).namewhat,debug.getinfo(2).nups,debug.getinfo(2).short_src)
	print("cccccc3",self.m_bIsVisibleBeforeEnchou)
	if self.m_bIsVisibleBeforeEnchou then
		self.m_bIsVisibleBeforeEnchou = false 
		self:SetVisible(true)
			print("cccccceee",WaringButtonDlg.getInstanceNotCreate(),WaringButtonDlg.getInstanceNotCreate():IsVisible())

	end 
end


function WaringButtonDlg:clickHandler(args)
	if self.m_pWaringlist then
		if CWaringlistDlg:GetSingleton():IsVisible() then
			CWaringlistDlg:GetSingleton():SetVisible(false)
		else
			CWaringlistDlg:GetSingleton():SetVisible(true)
		end
	end
	return true
end
function WaringButtonDlg.CSetVisible(args)
	if args == true and WaringButtonDlg.getInstance() then
		WaringButtonDlg.getInstance():SetVisible(args)
	elseif args == false and WaringButtonDlg.getInstanceNotCreate() then
		WaringButtonDlg.getInstanceNotCreate():SetVisible(args)
	end
end
return WaringButtonDlg
