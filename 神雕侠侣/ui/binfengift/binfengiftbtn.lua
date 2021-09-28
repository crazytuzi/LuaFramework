--[[author: lvxiaolong
date: 2013/7/1
function: binfen gift button dlg
]]

require "ui.dialog"
require "ui.binfengift.binfengiftdlg"
require "utils.mhsdutils"

local BinfenGiftBtn = {}
setmetatable(BinfenGiftBtn, Dialog)
BinfenGiftBtn.__index = BinfenGiftBtn 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function BinfenGiftBtn.IsShow()
    LogInfo("BinfenGiftBtn.IsShow")
    
    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function BinfenGiftBtn.getInstance()
	LogInfo("BinfenGiftBtn.getInstance")
    if not _instance then
        _instance = BinfenGiftBtn:new()
        _instance:OnCreate()
    end

    return _instance
end

function BinfenGiftBtn.getInstanceAndShow()
	LogInfo("____BinfenGiftBtn.getInstanceAndShow")
    if not _instance then
        _instance = BinfenGiftBtn:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function BinfenGiftBtn.getInstanceNotCreate()
    return _instance
end

function BinfenGiftBtn.DestroyDialog()
	if _instance then
        	if GetGameUIManager():IsWindowHaveEffect(_instance:GetWindow()) then
        	    GetGameUIManager():RemoveUIEffect(_instance:GetWindow())
        	end
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

function BinfenGiftBtn.ToggleOpenClose()
	if not _instance then 
		_instance = BinfenGiftBtn:new() 
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

function BinfenGiftBtn.GetLayoutFileName()
    return "addcashactbtn.layout"
end

function BinfenGiftBtn:OnCreate()
	LogInfo("enter BinfenGiftBtn oncreate")
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

    self.m_btn = CEGUI.Window.toPushButton(winMgr:getWindow("addcashactbtn/btn"))
    self.m_btn:subscribeEvent("Clicked", BinfenGiftBtn.HandleClickeBtn, self)

    self.m_status = 0
    self.m_serverid = 0
    self.m_endTimeReGift = 0
    self.m_endTimeConGift = 0
    self.m_endTimeLSaleAct = 0
    self.m_endTimeDailyTask = 0
    self.m_endTimeAccumulate = 0
  
	LogInfo("exit BinfenGiftBtn OnCreate")
end

function BinfenGiftBtn:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BinfenGiftBtn)
    return self
end

function BinfenGiftBtn:RefreshBaseStateInfo(status, serverid, endTimeReGift, endTimeConGift, endTimeLSaleAct, endTimeDailyTask, endTimeAccumulate)
    LogInfo("____BinfenGiftBtn:RefreshBaseStateInfo")
    
    self.m_status = status
    self.m_serverid = serverid
    self.m_endTimeReGift = endTimeReGift
    self.m_endTimeConGift = endTimeConGift
    self.m_endTimeLSaleAct = endTimeLSaleAct
	self.m_endTimeDailyTask = endTimeDailyTask
	self.m_endTimeAccumulate = endTimeAccumulate
    
    if self.m_status == 1 then  --show effect
        if not GetGameUIManager():IsWindowHaveEffect(self:GetWindow()) then
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
    else    --remove effect
        if GetGameUIManager():IsWindowHaveEffect(self:GetWindow()) then
            GetGameUIManager():RemoveUIEffect(self:GetWindow())
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
end

function BinfenGiftBtn:HandleClickeBtn(args)
    LogInfo("____BinfenGiftBtn:HandleClickeBtn")
    
    require "protocoldef.knight.gsp.yuanbao.copencontinuechargedlg"
    local p = COpenContinueChargeDlg.Create()
    p.flag = 1
    p.page = -1

    if self.m_endTimeReGift > 0 then
        p.page = 1
    elseif self.m_endTimeConGift > 0 then
        p.page = 2
    elseif self.m_endTimeLSaleAct > 0 then
        p.page = 3
	elseif self.m_endTimeDailyTask > 0 then
        p.page = 4
	elseif self.m_endTimeAccumulate > 0 then
        p.page = 5
    end

    if p.page > 0 then
        require "manager.luaprotocolmanager":send(p)
    end
end

function BinfenGiftBtn:SetChargeItems(items, curNum, endTime)
    local dlgBinfenGift = BinfenGiftDlg.getInstanceAndShow()
    dlgBinfenGift:SetLeftTimes(self.m_endTimeReGift, self.m_endTimeConGift, self.m_endTimeLSaleAct, self.m_endTimeDailyTask, self.m_endTimeAccumulate)
    dlgBinfenGift:SetChargeItems(items, curNum, endTime)
end

function BinfenGiftBtn:SetConsumeItems(items, curNum, endTime)
    local dlgBinfenGift = BinfenGiftDlg.getInstanceAndShow()
    dlgBinfenGift:SetLeftTimes(self.m_endTimeReGift, self.m_endTimeConGift, self.m_endTimeLSaleAct, self.m_endTimeDailyTask, self.m_endTimeAccumulate)
    dlgBinfenGift:SetConsumeItems(items, curNum, endTime)
end

function BinfenGiftBtn:SetLimitTimeBuyItems(limittimeitems, curNum, endTime)
    local dlgBinfenGift = BinfenGiftDlg.getInstanceAndShow()
    dlgBinfenGift:SetLeftTimes(self.m_endTimeReGift, self.m_endTimeConGift, self.m_endTimeLSaleAct, self.m_endTimeDailyTask, self.m_endTimeAccumulate)
    dlgBinfenGift:SetLimitTimeBuyItems(limittimeitems, endTime)
end

function BinfenGiftBtn:SetDailyTaskItem(achivelist, endday)
    local dlgBinfenGift = BinfenGiftDlg.getInstanceAndShow()
    dlgBinfenGift:SetLeftTimes(self.m_endTimeReGift, self.m_endTimeConGift, self.m_endTimeLSaleAct, self.m_endTimeDailyTask, self.m_endTimeAccumulate)
    dlgBinfenGift:SetDailyTaskItem(achivelist, endday)
end

function BinfenGiftBtn:SetAccumulateItem(achivelist, days, endday)
    local dlgBinfenGift = BinfenGiftDlg.getInstanceAndShow()
    dlgBinfenGift:SetLeftTimes(self.m_endTimeReGift, self.m_endTimeConGift, self.m_endTimeLSaleAct, self.m_endTimeDailyTask, self.m_endTimeAccumulate)
    dlgBinfenGift:SetAccumulateItem(achivelist, days, endday)
end

return BinfenGiftBtn
