require "ui.dialog"
local ShijuezhenDlg = {}

setmetatable(ShijuezhenDlg, Dialog);
ShijuezhenDlg.__index = ShijuezhenDlg;

local _instance;

local LEVEL_NUM = 10

function ShijuezhenDlg.getInstance()
	if _instance == nil then
		_instance = ShijuezhenDlg:new();
		_instance:OnCreate();
	end

	return _instance;
end

function ShijuezhenDlg.getInstanceNotCreate()
	return _instance;
end

function ShijuezhenDlg.DestroyDialog()
	if _instance then
		_instance:resetList()
		_instance:OnClose();
		_instance = nil;
		LogInfo("ShijuezhenDlg DestroyDialog")
	end
end

function ShijuezhenDlg.getInstanceAndShow()
	print("ShijuezhenDlg getInstanceAndShow")
    if not _instance then
        _instance = ShijuezhenDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ShijuezhenDlg.ToggleOpenClose()
	if not _instance then 
		_instance = ShijuezhenDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ShijuezhenDlg.GetLayoutFileName()
	return "shijuezhen.layout";
end

function ShijuezhenDlg:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, ShijuezhenDlg);
	return zf;
end

-------------------------------------------------------------------------------

function ShijuezhenDlg:OnCreate()
	LogInfo("ShijuezhenDlg OnCreate begin")
	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_startBtn = winMgr:getWindow("shijuezhen/go")
	self.m_panelCtn = CEGUI.Window.toScrollablePane(winMgr:getWindow("shijuezhen/back"))
	self.m_panelCtn:EnableHorzScrollBar(true)
	
	self.m_startBtn:subscribeEvent("MouseClick", self.HandleStartClicked, self)
	
	self.m_cfg = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cshijuezhenconf")

	local Cell = require "ui.shijuezhen.shijuezhencell"
	self.m_panels = {}
	for i=1,LEVEL_NUM do
		local panel = {}
		panel = Cell.CreateNewDlg(self.m_panelCtn, i)
		panel.pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, panel.m_width * (i - 1) + 1), CEGUI.UDim(0,0)))
		local c = self.m_cfg:getRecorder(i)
		panel.m_descText:setText(c.stagename)
		local path = GetIconManager():GetImagePathByID(tonumber(c.bosshead)):c_str()
    	panel.m_headImage:setProperty("Image", path)
		panel.m_nameText:setText(c.bosstitle)

		self.m_panels[i] = panel
	end
	self.m_panels[LEVEL_NUM].m_arrow:setVisible(false)
	self.m_currLevel = 0

	LogInfo("ShijuezhenDlg OnCreate finish")
end

function ShijuezhenDlg:SetData( proto )
	LogInfo("ShijuezhenDlg SetData")

	self.m_currLevel = proto.curlevel + 1
	self.m_leftTime = proto.lefttimes
	self.m_statistics = proto.statistics
	for k,v in pairs(self.m_statistics) do
		print(k,v)
	end
	for i,v in ipairs(self.m_panels) do
		v.m_numText:setText(self.m_statistics[i].."%")
		v.m_pozhen:setVisible(i < self.m_currLevel)
	end
end

function ShijuezhenDlg:HandleStartClicked()
	local msg = MHSD_UTILS.get_msgtipstring(146463)
	msg = string.gsub(msg, "%$parameter1%$", "1")
	msg = string.gsub(msg, "%$parameter2%$", self.m_cfg:getRecorder(1).stagename)
	GetMessageManager():AddConfirmBox(eConfirmNormal,msg,self.StartBattle,self,
		CMessageManager.HandleDefaultCancelEvent,CMessageManager)
end

function ShijuezhenDlg:StartBattle()
	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
	local p = require "protocoldef.knight.gsp.task.shijuezhen.cshijuestartbattle":new()
	require "manager.luaprotocolmanager":send(p)	
end

function ShijuezhenDlg:resetList()
	if self.m_panelCtn then
		self.m_panelCtn:cleanupNonAutoChildren()
		self.m_panels = {}
	end
end

return ShijuezhenDlg