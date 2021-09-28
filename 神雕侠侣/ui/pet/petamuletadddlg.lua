require "ui.pet.petamuletcell"

PetAmuletAddDlg = {}

setmetatable(PetAmuletAddDlg, Dialog);
PetAmuletAddDlg.__index = PetAmuletAddDlg;

local _instance;

function PetAmuletAddDlg.getInstance()
	if _instance == nil then
		_instance = PetAmuletAddDlg:new();
		_instance:OnCreate();
	end

	return _instance;
end

function PetAmuletAddDlg.getInstanceNotCreate()
	return _instance;
end

function PetAmuletAddDlg.DestroyDialog()
	if _instance then
		_instance:resetList()
		_instance:OnClose();
		_instance = nil;
		LogInfo("PetAmuletAddDlg DestroyDialog")
	end
end

function PetAmuletAddDlg.getInstanceAndShow()
    if not _instance then
        _instance = PetAmuletAddDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function PetAmuletAddDlg.ToggleOpenClose()
	if not _instance then 
		_instance = PetAmuletAddDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetAmuletAddDlg.GetLayoutFileName()
	return "petskillhufuadd.layout";
end

function PetAmuletAddDlg:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, PetAmuletAddDlg);
	return zf;
end

------------------------------------------------------------------------------

function PetAmuletAddDlg:OnCreate()
	LogInfo("PetAmuletAddDlg OnCreate begin")
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_panel = winMgr:getWindow("petskillhufuadd/main/scroll")
	self.m_okBtn = winMgr:getWindow("petskillhufuadd/ok")
	self.m_cancelBtn = winMgr:getWindow("petskillhufuadd/cancel")

	self.m_okBtn:subscribeEvent("MouseClick", self.HandleOkClicked, self)
	self.m_cancelBtn:subscribeEvent("MouseClick", self.HandleCancelClicked, self)

	self.m_cells = {}

	self:GetWindow():setAlwaysOnTop(true)

	LogInfo("PetAmuletAddDlg OnCreate finish")
end

function PetAmuletAddDlg:PushAmulets( list )
	for i = #self.m_cells + 1, #list do
		local cell = PetAmuletCell.CreateNewDlg(self.m_panel, i)
		self.m_cells[i] = cell
		cell.pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0,cell.pWnd:getPixelSize().height * (i - 1) + 1)))
		cell.m_back:subscribeEvent("MouseClick", PetAmuletAddDlg.HandleCellClicked, self)
		cell.m_itemcell:subscribeEvent("MouseClick", PetAmuletAddDlg.HandleCellClicked, self)
		cell.m_back:setID(i)
		cell.m_itemcell:setID(i)
	end
	for i,v in ipairs(self.m_cells) do
		v:SetVisible(false)
	end
	for i,v in ipairs(list) do
		self.m_cells[i]:SetVisible(true)
		self.m_cells[i]:SetData(v.petamuletid, v.itemkey)
		self.m_cells[i].itemkey = v.itemkey
	end
end

function PetAmuletAddDlg:SetPetId( petid )
	self.m_petid = petid
end

function PetAmuletAddDlg:HandleCellClicked( args )
	local e = CEGUI.toWindowEventArgs(args)
	local cellid = e.window:getID()

	for i,v in ipairs(self.m_cells) do
		v:UnSelect()
	end
	self.m_cells[cellid]:ToggleSelectState()

end

function PetAmuletAddDlg:resetList()
	if self.m_panel then
		self.m_panel:cleanupNonAutoChildren()
		self.m_cells = {}
	end
end

function PetAmuletAddDlg:HandleOkClicked()
	for i,v in ipairs(self.m_cells) do
		if v.m_select then
			local p = knight.gsp.item.CUseItem(v.itemkey, 1, self.m_petid)
			GetNetConnection():send(p)
			PetAmuletAddDlg.DestroyDialog()
			return
		end
	end
	PetAmuletAddDlg.DestroyDialog()
end

function PetAmuletAddDlg:HandleCancelClicked()
	PetAmuletAddDlg.DestroyDialog()
end

return PetAmuletAddDlg