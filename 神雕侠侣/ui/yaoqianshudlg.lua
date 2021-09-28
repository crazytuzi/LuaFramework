require "ui.dialog"
require "utils.mhsdutils"

YaoQianShuDlg = {}
setmetatable(YaoQianShuDlg, Dialog)
YaoQianShuDlg.__index = YaoQianShuDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function YaoQianShuDlg.getInstance()
	print("enter get yaoqianshu dialog instance")
    if not _instance then
        _instance = YaoQianShuDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function YaoQianShuDlg.getInstanceAndShow()
	print("enter yaoqianshu dialog instance show")
    if not _instance then
        _instance = YaoQianShuDlg:new()
        _instance:OnCreate()
	else
		print("set yaoqianshu dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function YaoQianShuDlg.getInstanceNotCreate()
    return _instance
end

function YaoQianShuDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function YaoQianShuDlg.ToggleOpenClose()
	if not _instance then 
		_instance = YaoQianShuDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function YaoQianShuDlg.RefreshTime()
	YaoQianShuEntrance.RefreshTime()
	if YaoQianShuDlg.getInstanceNotCreate() then
		local time = GetYaoQianShuManager():getCountDown()
		local self = YaoQianShuDlg.getInstanceNotCreate()
		if time > 0 then
			local hour = math.floor(time / 3600)
			local min = math.floor((time %3600) / 60)
			local second = math.floor(time % 60)
			if hour > 0 then
				self.m_pFreeBtn:setText(string.format("%02d:%02d:%02d", hour, min, second))
			else
				self.m_pFreeBtn:setText(string.format("%02d:%02d", min, second))
			end

			self.m_pFreeBtn:setEnabled(false)
		else
			self.m_pFreeBtn:setText(MHSD_UTILS.get_resstring(2698))	
            self.m_pFreeBtn:setEnabled(true)
		end	
	end
end


----/////////////////////////////////////////------

function YaoQianShuDlg.GetLayoutFileName()
    return "yaoqianshu.layout"
end

function YaoQianShuDlg:OnCreate()
	print("yaoqianshu dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pFreeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("yaoqianshu/ok"))
    self.m_pCloseBtn = CEGUI.Window.toPushButton(winMgr:getWindow("yaoqianshu/closed"))
    self.m_pFreeRemain = winMgr:getWindow("yaoqianshu/info2/txt1")
	self.m_pEffectWnd = winMgr:getWindow("yaoqianshu/treesprite/effect")


    -- subscribe event
    self.m_pFreeBtn:subscribeEvent("Clicked", YaoQianShuDlg.HandleFreeBtnClicked, self) 
    self.m_pCloseBtn:subscribeEvent("Clicked", YaoQianShuDlg.HandleCloseBtnClicked, self) 

	self.m_pFreeBtn:setText(MHSD_UTILS.get_resstring(2698))	

	self:RefreshInfo()


	print("yaoqianshu dialog oncreate end")
end

------------------- private: -----------------------------------


function YaoQianShuDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, YaoQianShuDlg)
    return self
end

function YaoQianShuDlg:RefreshInfo()
	if YaoQianShuEntrance.getInstanceNotCreate() then
		local unpayremaintimes = YaoQianShuEntrance.getInstanceNotCreate().m_iUnpayRemainTimes

		if unpayremaintimes then
			if unpayremaintimes > 0  then
				local strbuilder = StringBuilder:new()	
				strbuilder:SetNum("parameter1", unpayremaintimes)
				self.m_pFreeRemain:setText(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144830)))	
				strbuilder:delete()
			else
				self.m_pFreeBtn:setEnabled(false)
				self.m_pFreeRemain:setText(MHSD_UTILS.get_resstring(2700))
			end
		end
	end
end

function YaoQianShuDlg:HandleCloseBtnClicked(args)
	print("yaoqianshudlg closebtn clicked")
	YaoQianShuDlg.DestroyDialog()
	return true
end

function YaoQianShuDlg:HandleFreeBtnClicked(args)
	print("yaoqianshudlg freebtn clicked")
	GetYaoQianShuManager():request(1, 0)
	return true
end

return YaoQianShuDlg
