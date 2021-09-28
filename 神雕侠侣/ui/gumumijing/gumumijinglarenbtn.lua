require "ui.dialog"
GumumijingLarenBtn = {}
setmetatable(GumumijingLarenBtn, Dialog)
GumumijingLarenBtn.__index = GumumijingLarenBtn

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function GumumijingLarenBtn.getInstance()
    if not _instance then
        _instance = GumumijingLarenBtn:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function GumumijingLarenBtn.getInstanceAndShow()
    if not _instance then
        _instance = GumumijingLarenBtn:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function GumumijingLarenBtn.getInstanceNotCreate()
    return _instance
end

function GumumijingLarenBtn.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function GumumijingLarenBtn.ToggleOpenClose()
	if not _instance then 
		_instance = GumumijingLarenBtn:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function GumumijingLarenBtn.CheckInMap(id)
	if tonumber(id) >= 1570 and tonumber(id) <= 1576 then
		return true
	end
	return false
end

function GumumijingLarenBtn:Changmap(id)
	if GumumijingLarenBtn.CheckInMap(id) then
		require("ui.gumumijing.gumumijingtime").getInstanceAndShow()
		self.DestroyDialog()
	else
		require("ui.gumumijing.gumumijingtime").DestroyDialog()
	end
end

function GumumijingLarenBtn.CheckAndOpen()
	require "ui.activity.activitymanager"
	if  ActivityManager.getInstance():isOpened(160) and ActivityManager.getInstance():isInTime(160) then
		GumumijingLarenBtn.getInstanceAndShow()
	else
		GumumijingLarenBtn.DestroyDialog()
	end
--	GumumijingLarenBtn.getInstanceAndShow()
end




function GumumijingLarenBtn.GetLayoutFileName()
    return "gumumijingbtn.layout"
end
function GumumijingLarenBtn:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.btn = winMgr:getWindow("gumumijingbtn/button")
	self.btn:subscribeEvent("Clicked",self.HandleClicked,self)
end

------------------- private: -----------------------------------
function GumumijingLarenBtn:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, GumumijingLarenBtn)
    return self
end
function GumumijingLarenBtn:HandleClicked(args)
	local s = MHSD_UTILS.get_msgtipstring(145793)
	GetMessageManager():AddConfirmBox(eConfirmNormal,s, GumumijingLarenBtn.GumuConfirm, GumumijingLarenBtn,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
end

function GumumijingLarenBtn:GumuConfirm(args)
  local p = require "protocoldef.knight.gsp.faction.cagreedrawrole" : new()
  p.agree = 1
  p.flag = 6
  require "manager.luaprotocolmanager":send(p)
  GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function GumumijingLarenBtn.process(args)
	if args == 1 then
		if not GetBattleManager():IsInBattle() then
			GumumijingLarenBtn.getInstanceAndShow()
		else
			GumumijingLarenBtn.reShow = 1
		end
	else
		GumumijingLarenBtn.DestroyDialog()
	end

end
return GumumijingLarenBtn
