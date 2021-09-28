require "ui.dialog"

CampLeaderDlg = {}
setmetatable(CampLeaderDlg, Dialog)
CampLeaderDlg.__index = CampLeaderDlg
CampLeaderDlg.perPage = 10

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function CampLeaderDlg.getInstance()
	-- print("enter get campleaderdlg dialog instance")
    if not _instance then
        _instance = CampLeaderDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function CampLeaderDlg.getInstanceAndShow()
	-- print("enter campleaderdlg dialog instance show")
    if not _instance then
        _instance = CampLeaderDlg:new()
        _instance:OnCreate()
	else
		-- print("set campleaderdlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CampLeaderDlg.getInstanceNotCreate()
    return _instance
end

function CampLeaderDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function CampLeaderDlg.ToggleOpenClose()
	if not _instance then 
		_instance = CampLeaderDlg:new() 
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

function CampLeaderDlg.GetLayoutFileName()
    return "campleaderdlg.layout"
end

function CampLeaderDlg:OnCreate()
	-- print("campleaderdlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pChange = CEGUI.Window.toPushButton(winMgr:getWindow("campleaderdlg/change"))
    self.m_pMoney = CEGUI.Window.toPushButton(winMgr:getWindow("campleaderdlg/change1"))
	self.m_pList = CEGUI.Window.toScrollablePane(winMgr:getWindow("campleaderdlg/back/list"))

    -- subscribe event
    self.m_pChange:subscribeEvent("Clicked", CampLeaderDlg.HandleChangeText, self) 
    self.m_pMoney:subscribeEvent("Clicked", CampLeaderDlg.HandleChangeMoney, self) 
	self.m_pList:subscribeEvent("NextPage", CampLeaderDlg.HandleNextPage, self)

	-- print("campleaderdlg dialog oncreate end")
end

------------------- private: -----------------------------------

function CampLeaderDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CampLeaderDlg)
	self.m_cells = {}
	self.m_list = nil
	self.m_page = 1
    return self
end

function CampLeaderDlg:HandleChangeText(args)
	local dlg = require "ui.camp.campsaydlg"
	dlg.getInstanceAndShow()
end

function CampLeaderDlg:HandleChangeMoney(args)
	local CReqFoundInfo = require "protocoldef.knight.gsp.campleader.creqfoundinfo"
	local req = CReqFoundInfo.Create()
	LuaProtocolManager.getInstance():send(req)
end

function CampLeaderDlg:RefreshList(list)
	self.m_list = list
	self.m_page = 1
	local dlgcell = require "ui.camp.campleaderdlgcell"
	self.m_pChange:setEnabled(false)
--	self.m_pMoney:setEnabled(false)
	for k,v in pairs(self.m_cells) do
		v:OnClose()
	end
	self.m_cells = {}
	local y = 1
	local shapeTable = knight.gsp.npc.GetCNpcShapeTableInstance()
	for i,v in ipairs(list) do
		if i <= CampLeaderDlg.perPage then
			local cell = dlgcell.CreateNewDlg(self.m_pList, v.roleid)
			local shape = shapeTable:getRecorder(v.shape)
			local icon = GetIconManager():GetImagePathByID(shape.headID):c_str()
			cell:SetInfo(icon, v.name, v.factionname, v.vote, "", v.mes, v.returnmoney)
			self.m_cells[v.roleid] = cell
			y = cell.m_pWnd:getPixelSize().height*(i-1)+1
			cell.m_pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,1),CEGUI.UDim(0,y)))

			if GetDataManager():GetMainCharacterID() == v.roleid then
				self.m_pChange:setEnabled(true)
--				self.m_pMoney:setEnabled(true)
			end
		end
	end
end

function CampLeaderDlg:HandleNextPage(args)
	local dlgcell = require "ui.camp.campleaderdlgcell"
	local shapeTable = knight.gsp.npc.GetCNpcShapeTableInstance()
	local s = self.m_page*CampLeaderDlg.perPage
	local e = (self.m_page+1)*CampLeaderDlg.perPage
	if #self.m_list > s then
		for i,v in ipairs(self.m_list) do
			if i > s and i <= e then
				local cell = dlgcell.CreateNewDlg(self.m_pList, v.roleid)
				local shape = shapeTable:getRecorder(v.shape)
				local icon = GetIconManager():GetImagePathByID(shape.headID):c_str()
				cell:SetInfo(icon, v.name, v.factionname, v.vote, "", v.mes, v.returnmoney)
				self.m_cells[v.roleid] = cell
				local y = cell.m_pWnd:getPixelSize().height*(i-1)+1
				cell.m_pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,1),CEGUI.UDim(0,y)))

				if GetDataManager():GetMainCharacterID() == v.roleid then
					self.m_pChange:setEnabled(true)
--					self.m_pMoney:setEnabled(true)
				end
			end
		end
		self.m_page = self.m_page + 1
	end
end

return CampLeaderDlg
