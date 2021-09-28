require "utils.mhsdutils"
require "ui.jewelry.ringcell"
require "protocoldef.knight.gsp.item.cdecomposepreview"
require "protocoldef.knight.gsp.item.cdecomposedecoration"
local single = require "ui.singletondialog"

RingDecomposition = {}
setmetatable(RingDecomposition, single)
RingDecomposition.__index = RingDecomposition
function RingDecomposition:OnClose()
	self.m_pRingTable:cleanupNonAutoChildren()
	self.m_pMaterialTable:cleanupNonAutoChildren()
	if self._instance then
		getmetatable(self)._instance = nil
	end
	Dialog.OnClose(self)
end
function RingDecomposition:DestroyDialog()
	local dlg = LabelDlg.getLabelById("jewelry")
	if dlg then
		dlg:OnClose()
	else
		single.DestroyDialog(self)
	end
end

function RingDecomposition.GetLayoutFileName()
    return "ringdecomposition.layout"
end

function RingDecomposition.new()
	LogInfo("RingDecomposition oncreate begin")
	local self = {}
	setmetatable(self, RingDecomposition)
    require"ui.dialog".OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pDecBtn = CEGUI.Window.toPushButton(winMgr:getWindow("ringdecomposition/right/ok1"))
	self.m_pRingTable = CEGUI.Window.toScrollablePane(winMgr:getWindow("ringdecomposition/left/table"))
	self.m_pMaterialTable = CEGUI.Window.toScrollablePane(winMgr:getWindow("ringdecomposition/right/table"))

    -- subscribe event
    self.m_pDecBtn:subscribeEvent("Clicked", RingDecomposition.HandleDecBtnClicked, self) 

	self.m_pDecBtn:setEnabled(false)
	self:InitInfo()
	require "ui.jewelry.label"()
	LogInfo("RingDecomposition oncreate end")
	return self
end

function RingDecomposition:HandleDecBtnClicked(args)
	LogInfo("RingDecomposition button clicked")
	local req = CDecomposeDecoration.Create()
	local i = 1
	for k,v in pairs(self.m_ringList) do
		if v.selected then
			req.decorations[i] = v.key
			local roleItem = GetRoleItemManager():GetBagItem(v.key)
			local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(roleItem:GetObjectID())
			if equipConfig.equipcolor >= 4 then
				GetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(145403), RingDecomposition.HandleDecomposConfirm, self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
				return
			end		
			i = i + 1
		end
	end
	
	LuaProtocolManager.getInstance():send(req)
	return true
end

function RingDecomposition:HandleDecomposConfirm()
	LogInfo("RingDecomposition  HandleDecomposConfirm")
	local req = CDecomposeDecoration.Create()
	local i = 1
	for k,v in pairs(self.m_ringList) do
		if v.selected then
			req.decorations[i] = v.key
			i = i + 1
		end
	end
	LuaProtocolManager.getInstance():send(req)
  	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function RingDecomposition:InitInfo()
	LogInfo("RingDecomposition InitInfo")
	self.m_pRingTable:cleanupNonAutoChildren()
	self.m_pMaterialTable:cleanupNonAutoChildren()
	self.m_ringList = nil
	self.m_ringList = {}
	self.m_materialList = nil
	self.m_materialList = {}

	self:InitRing()
	self.m_pDecBtn:setEnabled(false)
end

function RingDecomposition:InitRing()
	LogInfo("RingDecomposition InitRing")
	
	local ringType = 0x68
	local ringkeys = std.vector_int_()
	GetRoleItemManager():GetItemKeyListByType(ringkeys, ringType)
	local num = ringkeys:size()
	local ringCell = nil
	for i = 0, num - 1 do
		if i % 3 == 0 then
			ringCell = RingCell.CreateNewDlg(self.m_pRingTable)	
			ringCell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, ringCell:GetWindow():getPixelSize().height * math.floor(i / 3) + 1)))
		end
		local item = {}
		item.cell = ringCell.m_pCell[i % 3]		
		item.cell:setVisible(true)
		item.cell:setID(i)
		item.key = ringkeys[i]
		item.light = ringCell.m_pLight[i % 3]
		item.selected = false
		local roleItem = GetRoleItemManager():GetBagItem(ringkeys[i])
		local itemBean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(roleItem:GetObjectID())
		item.cell:SetImage(GetIconManager():GetImageByID(itemBean.icon))
		item.cell:subscribeEvent("TableClick", RingDecomposition.HandleItemSelect, self)
		
		self.m_ringList[i] = item
	end
end

function RingDecomposition:FreshMaterial(materialMap)
	LogInfo("RingDecomposition FreshMaterial")
	self.m_pMaterialTable:cleanupNonAutoChildren()
	self.m_materialList = nil
	self.m_materialList = {}
	local i = 0
	for k,v in pairs(materialMap) do
		if i % 3 == 0 then
			materialCell = RingCell.CreateNewDlg(self.m_pMaterialTable)	
			materialCell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, materialCell:GetWindow():getPixelSize().height * math.floor(i / 3) + 1)))
		end
		local material = {}
		material.cell = materialCell.m_pCell[i % 3]		
		material.cell:setVisible(true)
		material.cell:setID(k)
		local itemBean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(k)
		material.cell:SetImage(GetIconManager():GetImageByID(itemBean.icon))
		material.cell:SetTextUnit(tostring(v))
		material.cell:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
		self.m_materialList[i] = material

		i = i + 1
	end
end

function RingDecomposition:HandleItemSelect(args)
	LogInfo("RingDecomposition HandleItemSelect")
	local e = CEGUI.toMouseEventArgs(args)
	local pt = e.position
	local eventargs = CEGUI.toWindowEventArgs(args)
	local item = self.m_ringList[args.window:getID()]
	if item.selected then
		item.selected = false
		item.light:setVisible(false)
	else
		item.selected = true
		item.light:setVisible(true)
	end
	local req = CDecomposePreview.Create()
	local hasSelect = false
	local i = 1
	for k,v in pairs(self.m_ringList) do
		if v.selected then
			req.decorations[i] = v.key
			i = i + 1
			hasSelect = true
		end
	end
	if hasSelect then
		LuaProtocolManager.getInstance():send(req)
	else
		self.m_pMaterialTable:cleanupNonAutoChildren()
	end
	self.m_pDecBtn:setEnabled(hasSelect)
	local roleItem = GetRoleItemManager():GetBagItem(item.key)
	local tipDlg = CToolTipsDlg:GetSingletonDialogAndShowIt()
	if tipDlg then
		tipDlg:SetTipsItem(roleItem, pt.x, pt.y, true)
	end

	return true
end

return RingDecomposition
