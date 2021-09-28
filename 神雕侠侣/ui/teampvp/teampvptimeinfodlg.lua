require "ui.dialog"
TeampvpTimeInfoDlg = {}
setmetatable(TeampvpTimeInfoDlg, Dialog)
TeampvpTimeInfoDlg.__index = TeampvpTimeInfoDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function TeampvpTimeInfoDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = TeampvpTimeInfoDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function TeampvpTimeInfoDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = TeampvpTimeInfoDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function TeampvpTimeInfoDlg.getInstanceNotCreate()
    return _instance
end

function TeampvpTimeInfoDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function TeampvpTimeInfoDlg.ToggleOpenClose()
	if not _instance then 
		_instance = TeampvpTimeInfoDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function TeampvpTimeInfoDlg.GetLayoutFileName()
    return "teampvptimeinfo.layout"
end
function TeampvpTimeInfoDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.time1 = winMgr:getWindow("teampvptimeinfo/back/time0")
	self.time2 = winMgr:getWindow("teampvptimeinfo/back/time1")
	self.time3 = winMgr:getWindow("teampvptimeinfo/back/time2")
	self.time4 = winMgr:getWindow("teampvptimeinfo/back/time3")

	self.time1:setText("")
	self.time2:setText("")
	self.time3:setText("")
	self.time4:setText("")

end

------------------- private: -----------------------------------
function TeampvpTimeInfoDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeampvpTimeInfoDlg)
    return self
end
function TeampvpTimeInfoDlg:HandleClicked(args)

end
function TeampvpTimeInfoDlg:Process(f,s,t,l)
	self.time1:setText(f)
	self.time2:setText(s)
	self.time3:setText(t)
	self.time4:setText(l)
end
return TeampvpTimeInfoDlg
