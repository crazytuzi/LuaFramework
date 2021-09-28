local Dialog = require "ui.dialog"
local SingletonDialog = require "ui.singletondialog"

------------------------ BattlePetListCell --------------------------
local BattlePetListCell = {}
setmetatable(BattlePetListCell, Dialog)
BattlePetListCell.__index = BattlePetListCell

function BattlePetListCell.CreateCell(wParent, prefix)
	local inst = {}
	setmetatable(inst, BattlePetListCell)
	inst:OnCreate(wParent, prefix)
	return inst
end

function BattlePetListCell.GetLayoutFileName()
	return "pethuanchongcell.layout"
end

function BattlePetListCell:OnCreate(wParent, prefix)
	Dialog.OnCreate(self, wParent, prefix)
	self.m_Prefix = prefix
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_wIcon = winMgr:getWindow(tostring(prefix) .. "pethuanchongcell/back/item/icon")
	self.m_wInBattle = winMgr:getWindow(tostring(prefix) .. "pethuanchongcell/back/mark")
	self.m_wName = winMgr:getWindow(tostring(prefix) .. "pethuanchongcell/back/name")
	self.m_wLevel = winMgr:getWindow(tostring(prefix) .. "pethuanchongcell/back/info")
	self.m_wBack = winMgr:getWindow(tostring(prefix) .. "pethuanchongcell/back")

	self.m_wBack:subscribeEvent("MouseClick", BattlePetListCell.HandleClicked, self)
end

function BattlePetListCell:HandleClicked(args)
	if self.m_CallBack then
		self.m_CallBack.fun(self.m_CallBack.t, self)
	end
end

function BattlePetListCell:SetCallback(fun, t)
	if fun then
		self.m_CallBack = {}
		self.m_CallBack.fun = fun
		self.m_CallBack.t = t
	else
		self.m_CallBack = nil
	end
end

function BattlePetListCell:SetPetInfo(info)
	self.m_PetInfo = self.m_PetInfo or {}
	self.m_PetInfo.key = info.key or self.m_PetInfo.key or nil
	self.m_PetInfo.name = info.name or self.m_PetInfo.name or ""
	self.m_PetInfo.level = info.level or self.m_PetInfo.level or ""
	self.m_PetInfo.icon = info.icon or self.m_PetInfo.icon or ""
	self.m_PetInfo.inbattle = info.inbattle or self.m_PetInfo.inbattle or false
	self.m_PetInfo.selected = info.selected or self.m_PetInfo.selected or false
	self.m_PetInfo.used = info.used or self.m_PetInfo.used or false

	self.m_wName:setText(self.m_PetInfo.name)
	self.m_wLevel:setText(self.m_PetInfo.level)
	self.m_wIcon:setProperty("Image", self.m_PetInfo.icon)
	self.m_wInBattle:setVisible(self.m_PetInfo.inbattle)
	if self.m_PetInfo.selected then
		self.m_wBack:setProperty("Image", "set:MainControl9 image:shopcellchoose")
	else
		self.m_wBack:setProperty("Image", "set:MainControl9 image:shopcellnormal")
	end
	if self.m_PetInfo.used then
		self.m_wBack:setProperty("Image", "set:MainControl9 image:shopcelldisable")
	end
end

function BattlePetListCell:GetPetInfo()
	return self.m_PetInfo
end

------------------------ BattlePetSummonDlg --------------------------
BattlePetSummonDlg = {}
setmetatable(BattlePetSummonDlg, Dialog)
BattlePetSummonDlg.__index = BattlePetSummonDlg

BattlePetSummonDlg.UsedPets = {}

local _instance
function BattlePetSummonDlg.getInstance()
    if not _instance then
        _instance = BattlePetSummonDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function BattlePetSummonDlg.getInstanceAndShow()
    if not _instance then
        _instance = BattlePetSummonDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function BattlePetSummonDlg.getInstanceNotCreate()
    return _instance
end

function BattlePetSummonDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function BattlePetSummonDlg.ToggleOpenClose()
	if not _instance then 
		_instance = BattlePetSummonDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function BattlePetSummonDlg.new()
	local inst = {}
	setmetatable(inst, BattlePetSummonDlg)
	return inst
end

function BattlePetSummonDlg.GetLayoutFileName()
    return "petexchangechange.layout"
end

function BattlePetSummonDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_wList = CEGUI.Window.toScrollablePane(winMgr:getWindow("petexchangechange/back/petlist"))
	self.m_wSummon = CEGUI.Window.toPushButton(winMgr:getWindow("petexchangechange/zhaohuan"))
	self.m_wSummon:setEnabled(false)

	self.m_wSummon:subscribeEvent("Clicked", BattlePetSummonDlg.HandleSummonClicked, self)

	self:InitData()
end

function BattlePetSummonDlg:InitData()
	self.m_PetCellList = {}
	self.m_SelectKey = 0
	local num = GetDataManager():GetPetNum()
	for i=1, num do
		local pet = GetDataManager():getPet(i)
		local info = {}
		local shapeid = pet:GetShapeID()
		local headshape = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(shapeid)
		info.key = pet.key
		info.name = pet:GetPetNameTextColour() .. pet.name
		info.level = tostring(pet:getAttribute(knight.gsp.attr.AttrType.LEVEL)) .. MHSD_UTILS.get_resstring(2397)
		info.icon = GetIconManager():GetImagePathByID(headshape.headID):c_str()
		if GetDataManager():GetBattlePetID() == pet.key then
			info.inbattle = true
			self.m_PetKey = pet.key
			BattlePetSummonDlg.UsedPets[self.m_PetKey] = true
		else
			info.inbattle = false
		end
		if BattlePetSummonDlg.UsedPets[pet.key] then
			info.used = true
		else
			info.used = false
		end
		local cell = BattlePetListCell.CreateCell(self.m_wList, tostring(pet.key))
		cell:SetCallback(BattlePetSummonDlg.HandleCellClicked, self)
		cell:SetPetInfo(info)
		cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0 ,0), CEGUI.UDim(0, (i - 1) * cell:GetWindow():getPixelSize().height + 1)))
		self.m_PetCellList[pet.key] = cell
	end
end

function BattlePetSummonDlg:HandleCellClicked(cell)
	local oldcell = self.m_PetCellList[self.m_SelectKey]
	if oldcell then
		local info = oldcell:GetPetInfo()
		info.selected = false
		oldcell:SetPetInfo(info)
	end
	local info = cell:GetPetInfo()
	info.selected = true
	cell:SetPetInfo(info)
	self.m_SelectKey = info.key
	self.m_wSummon:setEnabled(not info.used)
end

function BattlePetSummonDlg:HandleSummonClicked(args)
	if self.m_SelectKey ~= 0 then
		GetBattleManager():SetSummonID(self.m_SelectKey)
		GetBattleManager():SendBattleCommand(0, eSummonOperate)
		
		if self.m_PetKey then
			BattlePetSummonDlg.UsedPets[self.m_PetKey] = true
		end	
	end
end

function BattlePetSummonDlg.EndBattle()
	BattlePetSummonDlg.UsedPets = {}
end

return BattlePetSummonDlg
