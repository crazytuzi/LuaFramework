require "ui.dialog"
GuMuMiJingDlg = {}
setmetatable(GuMuMiJingDlg, Dialog)
GuMuMiJingDlg.__index = GuMuMiJingDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function GuMuMiJingDlg.getInstance()
    if not _instance then
        _instance = GuMuMiJingDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function GuMuMiJingDlg.getInstanceAndShow()
    if not _instance then
        _instance = GuMuMiJingDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function GuMuMiJingDlg.getInstanceNotCreate()
    return _instance
end

function GuMuMiJingDlg.DestroyDialog()
	if _instance then 
		_instance:GetAward(nil,3)
		_instance:OnClose()		
		_instance = nil
		require("ui.gumumijing.gumumijingbtn").DestroyDialog()
	end
end

function GuMuMiJingDlg.ToggleOpenClose()
	if not _instance then 
		_instance = GuMuMiJingDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function GuMuMiJingDlg.GetLayoutFileName()
    return "gumumijing.layout"
end
function GuMuMiJingDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.hongbao = CEGUI.Window.toPushButton(winMgr:getWindow("gumumijing/right/imagebutton"))
	self.baoxiang = CEGUI.Window.toPushButton(winMgr:getWindow("gumumijing/right/imagebutton1"))
	self.downcount = winMgr:getWindow("gumumijing/right/text4")

	self.hongbao:subscribeEvent("Clicked",GuMuMiJingDlg.GetAward,self)
	self.baoxiang:subscribeEvent("Clicked",GuMuMiJingDlg.GetAward,self)

	self.closebutton = CEGUI.Window.toPushButton(winMgr:getWindow("gumumijing/close"))
	self.closebutton:subscribeEvent("Clicked",GuMuMiJingDlg.GetAward,self)


	self.hongbao:setID(1)
	self.baoxiang:setID(2)
	self.closebutton:setID(3)





end

------------------- private: -----------------------------------
function GuMuMiJingDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, GuMuMiJingDlg)
    return self
end

function GuMuMiJingDlg:GetAward(args,type3)
	local p = require("protocoldef.knight.gsp.activity.gumumijing.cdrawaward"):new()
	if args then
		local id = CEGUI.toWindowEventArgs(args).window:getID()
		if id == 3 then
			self.DestroyDialog()
			return
		end
		p.awardtype = id
		CEGUI.toWindowEventArgs(args).window:setEnabled(false)
	else
		p.awardtype = 3
	end
	require("manager.luaprotocolmanager"):send(p)
end
 

function GuMuMiJingDlg:setDownCountText(args)
	self.downcount:setText(args) 
end



return GuMuMiJingDlg
