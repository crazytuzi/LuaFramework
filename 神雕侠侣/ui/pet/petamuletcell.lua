PetAmuletCell = {}

setmetatable(PetAmuletCell, Dialog)
PetAmuletCell.__index = PetAmuletCell
local id = 0
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function PetAmuletCell.CreateNewDlg(pParentDlg, id)
	LogInfo("enter PetAmuletCell.CreateNewDlg")
	local newDlg = PetAmuletCell:new()
	newDlg:OnCreate(pParentDlg, id)

    return newDlg
end

----/////////////////////////////////////////------

function PetAmuletCell.GetLayoutFileName()
    return "petskillhufucell.layout"
end

function PetAmuletCell:OnCreate(pParentDlg, id)
	LogInfo("enter PetAmuletCell oncreate")
    Dialog.OnCreate(self, pParentDlg, id)

    self.m_id = id

    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_itemcell = CEGUI.toItemCell(winMgr:getWindow(tostring(id) .. "petskillhufucell/item"))
	self.m_amuletName = winMgr:getWindow(tostring(id) .. "petskillhufucell/name1")
	self.m_amuletEffect = winMgr:getWindow(tostring(id) .. "petskillhufucell/name")
	self.m_back = winMgr:getWindow(tostring(id).."petskillhufucell/back")

	self.m_amuletName:setMousePassThroughEnabled(true)
	self.m_amuletEffect:setMousePassThroughEnabled(true)
	
	self.pWnd = self:GetWindow()
	self.m_select = false

	-- self.m_itemcell:setID(161)
	-- require "utils.mhsdutils".SetWindowShowtips(self.m_itemcell)

	LogInfo("exit PetAmuletCell OnCreate")
end

------------------- public: -----------------------------------

function PetAmuletCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PetAmuletCell)

    return self
end

function PetAmuletCell:SetData( amuletid, itemkey )
	self.m_amuletid = amuletid
	self.m_itemkey = itemkey
	local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(amuletid)
	local record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cpetamulet"):getRecorder(amuletid);
	
	self.m_itemcell:SetImage(GetIconManager():GetItemIconByID(itembean.icon))
	self.m_amuletName:setText(record.amuletname)
	self.m_amuletEffect:setText(record.descrip)

	local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, knight.gsp.item.BagTypes.BAG)
	self.m_itemcell:setUserData(item)
	local ItemCellType_Item = 1
	self.m_itemcell:SetCellTypeMask(ItemCellType_Item)

	self.m_itemcell:subscribeEvent("TableClick", CGameItemTable.HandleShowTootips, CGameItemTable)
	self.m_itemcell:subscribeEvent("TableClick", self.HandleShowTootips, self)
end

function PetAmuletCell:HandleShowTootips()
	--hide two btn
	local dlg = CToolTipsDlg:GetSingletonDialog()
	local winMgr = CEGUI.WindowManager:getSingleton()
	local btn1 = winMgr:getWindow("ItemTips/delete")
	local btn2 = winMgr:getWindow("ItemTips/use")
	if btn1 and btn2 then
		btn1:setVisible(false)
		btn2:setVisible(false)
	end
end

function PetAmuletCell:ToggleSelectState()
	if self.m_select then
		self.m_select = false
		self.m_back:setProperty("Image", "set:MainControl9 image:shopcellnormal")
	else
		self.m_select = true
		self.m_back:setProperty("Image", "set:MainControl9 image:shopcellchoose")
	end
end

function PetAmuletCell:UnSelect()
	self.m_select = true
	self:ToggleSelectState()
end
return PetAmuletCell
