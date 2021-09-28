require "utils.mhsdutils"
PetChipCell = {}

setmetatable(PetChipCell, Dialog)
PetChipCell.__index = PetChipCell
local prefix = 0
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function PetChipCell.CreateNewDlg(pParentDlg)
	LogInfo("enter PetChipCell.CreateNewDlg")
	local newDlg = PetChipCell:new()
	newDlg:OnCreate(pParentDlg)

    return newDlg
end



----/////////////////////////////////////////------

function PetChipCell.GetLayoutFileName()
    return "petchipcell.layout"
end

function PetChipCell:OnCreate(pParentDlg)
	LogInfo("enter PetChipCell oncreate")
	prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pColor = winMgr:getWindow(tostring(prefix) .. "petchipcell/color")
	self.m_pName = winMgr:getWindow(tostring(prefix) .. "petchipcell/name")
	self.m_pNum1 = winMgr:getWindow(tostring(prefix) .. "petchipcell/num1")
	self.m_pNum2 = winMgr:getWindow(tostring(prefix) .. "petchipcell/num2")
	self.m_pLightBack = winMgr:getWindow(tostring(prefix) .. "petchipcell/light")
	self.m_pWnd = winMgr:getWindow(tostring(prefix) .. "petchipcell/back") 
	self.m_pIcon = winMgr:getWindow(tostring(prefix) .. "petchipcell/icon") 

	self:setSelect(false)
	LogInfo("exit PetChipCell OnCreate")
end

------------------- public: -----------------------------------

function PetChipCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PetChipCell)

    return self
end

function PetChipCell:Init(cur, id)
	self.m_iID = id
	self.m_pIcon:getGeometryBuffer():setRenderEffect(CGameUImanager:createXPRenderEffect(id, PetChipDlg.performPostRenderFunctions))
	local petChip = knight.gsp.pet.GetCPetchipTableInstance():getRecorder(self.m_iID)
	local petId = petChip.petid

	local petStar = knight.gsp.pet.GetCPetstarsTableInstance():getRecorder(petChip.petcolor)
	self.m_pColor:setProperty("Image", "set:MainControl7 image:" .. tostring(petStar.color))

	local petInfo = knight.gsp.pet.GetCPetAttrTableInstance():getRecorder(petChip.petid)
	self.m_pName:setText(GetPetNameTextColourByStar(petChip.petcolor) .. petInfo.name .. MHSD_UTILS.get_resstring(2969))
	self.m_pNum1:setText(tostring(cur))
	self.m_pNum2:setText(tostring(petChip.neednum))
	
	local pData = knight.gsp.pet.GetCPetAttrTableInstance():getRecorder(petId)
	local shapeid = pData.modelid
	if self.m_pSprite then 
		if self.m_pSprite:GetModelID() ~= shapeid then
			self.m_pSprite:SetModel(shapeid)
		end
	else
		self.m_pSprite = CUISprite:new(shapeid)
	end

	local pt = self.m_pIcon:GetScreenPosOfCenter()
	local wndHeight = self.m_pIcon:getPixelSize().height
	local loc = XiaoPang.CPOINT(pt.x, pt.y+wndHeight/3.0)
	self.m_pSprite:SetUILocation(loc)
	self.m_pSprite:SetUIDirection(XiaoPang.XPDIR_BOTTOMRIGHT)

	self.m_pWnd:removeEvent("MouseClick")
	self.m_pWnd:subscribeEvent("MouseClick", PetChipDlg.HandleChipSelect, PetChipDlg.getInstance())
	self.m_pWnd:setID(self.m_iID)
end

function PetChipCell:setSelect(b)
	if b then
		self.m_pLightBack:setVisible(true)
	else
		self.m_pLightBack:setVisible(false)
	end
end

function PetChipCell:DeleteSprite()
	if self.m_pSprite then
		self.m_pSprite:delete()
		self.m_pSprite = nil
	end
	self.m_pIcon:getGeometryBuffer():setRenderEffect(nil)
end

function PetChipCell:DrawSprite()
	if self.m_pIcon:isVisible() and self.m_pIcon:getEffectiveAlpha() > 0.95 and self.m_pSprite then
		local pt = self.m_pIcon:GetScreenPosOfCenter()
		local wndHeight = self.m_pIcon:getPixelSize().height
		local loc = XiaoPang.CPOINT(pt.x, pt.y+wndHeight/3.0)
		self.m_pSprite:SetUILocation(loc)
		self.m_pSprite:RenderUISprite()
	end
end

return PetChipCell
