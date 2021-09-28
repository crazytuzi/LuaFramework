require "utils.mhsdutils"
PetListCell = {}

setmetatable(PetListCell, Dialog)
PetListCell.__index = PetListCell
local prefix = 0
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function PetListCell.CreateNewDlg(pParentDlg, id)
	print("enter PetListCell.CreateNewDlg")
	local newDlg = PetListCell:new()
	newDlg:OnCreate(pParentDlg, id)

    return newDlg
end

----/////////////////////////////////////////------

function PetListCell.GetLayoutFileName()
    return "petlistcell.layout"
end

function PetListCell:OnCreate(pParentDlg, id)
	print("enter PetListCell oncreate")
	prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pHead = winMgr:getWindow(tostring(prefix) .. "petlistcell/back/item/icon")
	self.m_pName = winMgr:getWindow(tostring(prefix) .. "petlistcell/back/name")
	self.m_pLevel = winMgr:getWindow(tostring(prefix) .. "petlistcell/back/info")
	self.m_pWnd = winMgr:getWindow(tostring(prefix) .. "petlistcell/back")
	self.m_pBattleMark = winMgr:getWindow(tostring(prefix) .. "petlistcell/back/mark")

	self.m_pBattleMark:setVisible(false)
	if id then 
		self.id = id
		self.m_pWnd:setID(id)	
	end
	print("exit PetListCell OnCreate")
end

------------------- public: -----------------------------------

function PetListCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PetListCell)

    return self
end

function PetListCell:SetEmpty()
	self.m_pHead:setProperty("Image", "set:MainControl image:Head")
	self.m_pName:setText(MHSD_UTILS.get_resstring(2970) .. tostring(self.id))
	self.m_pLevel:setVisible(false)
	self.m_pBattleMark:setVisible(false)
	self.m_pWnd:removeEvent("MouseClick")
end

function PetListCell:SetLock()
	self.m_pHead:setProperty("Image", "set:BaseControl image:PetSkillLock")
	self.m_pName:setText(MHSD_UTILS.get_resstring(2971))
	self.m_pLevel:setVisible(false)
	self.m_pWnd:removeEvent("MouseClick")
	self.m_pWnd:subscribeEvent("MouseClick", PetPropertyDlg.HandleUnlock, PetPropertyDlg.getInstance())
end

function PetListCell:SetSelected(bSelected)
	if not bSelected then
		self.m_pWnd:setProperty("Image", "set:MainControl9 image:shopcellnormal")
	else
		self.m_pWnd:setProperty("Image", "set:MainControl9 image:shopcellchoose")
	end
end

--infotype = 1属性，2冲星
function PetListCell:SetInfo(petInfo, infotype)
	infotype = infotype or 1
	local shapeid = petInfo:GetShapeID()
	local headshape = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(shapeid)
	local path = GetIconManager():GetImagePathByID(headshape.headID):c_str()
	self.m_pHead:setProperty("Image", path)
	self.m_pName:setText(petInfo:GetPetNameTextColour() .. petInfo.name)

	if GetDataManager():GetBattlePetID() == petInfo.key then
		self.m_pBattleMark:setVisible(true)
	else
		self.m_pBattleMark:setVisible(false)
	end
	self.m_pWnd:removeEvent("MouseClick")
	if 1 == infotype then
		self.m_pLevel:setText(tostring(petInfo:getAttribute(knight.gsp.attr.AttrType.LEVEL)) .. MHSD_UTILS.get_resstring(2397))
		self.m_pWnd:subscribeEvent("MouseClick", PetPropertyDlg.HandlePetSelect, PetPropertyDlg.getInstance())
	elseif 2 == infotype then
		local starconfig = knight.gsp.pet.GetCPetstarsTableInstance():getRecorder(petInfo.starId)
		self.m_pLevel:setText(starconfig.xianshi)
		self.m_pWnd:subscribeEvent("MouseClick", PetStarDlg.HandlePetSelect, PetStarDlg.getInstance())
	elseif 3 == infotype then
		self.m_pLevel:setText(tostring(petInfo:getAttribute(knight.gsp.attr.AttrType.LEVEL)) .. MHSD_UTILS.get_resstring(2397))
		self.m_pWnd:subscribeEvent("MouseClick", PetTrainDlg.HandlePetClicked, PetTrainDlg.getInstance())
		self.m_pWnd:setID(petInfo.key)
	end
end

return PetListCell
