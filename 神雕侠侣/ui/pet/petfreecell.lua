require "utils.mhsdutils"
PetFreeCell = {}


setmetatable(PetFreeCell, Dialog)
PetFreeCell.__index = PetFreeCell
local prefix = 0
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function PetFreeCell.CreateNewDlg(pParentDlg)
	LogInfo("enter PetFreeCell.CreateNewDlg")
	local newDlg = PetFreeCell:new()
	newDlg:OnCreate(pParentDlg)

    return newDlg
end



----/////////////////////////////////////////------

function PetFreeCell.GetLayoutFileName()
    return "petchipcell1.layout"
end

function PetFreeCell:OnCreate(pParentDlg)
	LogInfo("enter PetFreeCell oncreate")
	prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pName = winMgr:getWindow(tostring(prefix) .. "petchipcell1/name")
	self.m_pLightBack = winMgr:getWindow(tostring(prefix) .. "petchipcell1/light")
	self.m_pWnd = winMgr:getWindow(tostring(prefix) .. "petchipcell1/back") 
	self.m_pIcon = winMgr:getWindow(tostring(prefix) .. "petchipcell1/icon") 
	self.m_pLevel = winMgr:getWindow(tostring(prefix) .. "petchipcell1/level")

	self:setSelect(false)
	LogInfo("exit PetFreeCell OnCreate")
end

------------------- public: -----------------------------------

function PetFreeCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PetFreeCell)

    return self
end

function PetFreeCell:Init(petInfo)
	self.m_iID = petInfo.key
	self.m_pIcon:getGeometryBuffer():setRenderEffect(CGameUImanager:createXPRenderEffect(petInfo.key, PetChipDlg.performPostRenderFunctions))
	self.m_pName:setText(petInfo:GetPetNameTextColour() .. petInfo.name)	
	self.m_pLevel:setText(tostring(petInfo:getAttribute(knight.gsp.attr.AttrType.LEVEL)) .. MHSD_UTILS.get_resstring(2397))

	local shapeid = petInfo:GetShapeID()
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

function PetFreeCell:setSelect(b)
	if b then
		self.m_pLightBack:setVisible(true)
	else
		self.m_pLightBack:setVisible(false)
	end
end

function PetFreeCell:DeleteSprite()
	if self.m_pSprite then
		self.m_pSprite:delete()
		self.m_pSprite = nil
	end
	self.m_pIcon:getGeometryBuffer():setRenderEffect(nil)
end

function PetFreeCell:DrawSprite()
	if self.m_pIcon:isVisible() and self.m_pIcon:getEffectiveAlpha() > 0.95 and self.m_pSprite then
		local pt = self.m_pIcon:GetScreenPosOfCenter()
		local wndHeight = self.m_pIcon:getPixelSize().height
		local loc = XiaoPang.CPOINT(pt.x, pt.y+wndHeight/3.0)
		self.m_pSprite:SetUILocation(loc)
		self.m_pSprite:RenderUISprite()
	end
end

return PetFreeCell
