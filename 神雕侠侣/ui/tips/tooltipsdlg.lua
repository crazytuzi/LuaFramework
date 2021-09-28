local self = {}
self.__index = self
local defaultx = 350
local defaulty = 104
local framex = 360
local framey = 240
local tipswnd = "ItemTips/back"
function self.isPresent()
	local winMgr = CEGUI.WindowManager:getSingleton()
	return winMgr:isWindowPresent(tipswnd)
end

local function GetWindow()
	return self.m_pMainFrame
end

function self.GetTipWindow()
    return GetWindow()
end

local function cegui_absdim(x)
	return CEGUI.UDim(0, x)
end
local EQUIP = 8
local CELL_WIDTH = 77
function self.ResetPosition(attr, m_cellXPos, m_cellYPos)
	local compareequip = false
	if attr.itemtypeid % 0xf == EQUIP then
		compareequip = false
	end

	local tw = GetWindow():getPixelSize().width
	local pw = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width
	local x = m_cellXPos + CELL_WIDTH
	local y = m_cellYPos + CELL_WIDTH

	if compareequip then
		if x + tw > pw then
			x = x - tw - CELL_WIDTH
		elseif x < tw then
			x = tw
		end
	else
		if x + tw > pw then
			x = x - tw - CELL_WIDTH
		end
	end

	local th = GetWindow():getPixelSize().height
	local ph = CEGUI.System:getSingleton():getGUISheet():getPixelSize().height
	if y + th > ph then
		if y > th then
			y = y - th
		else
			y = ph - th
		end
	end

	GetWindow():setPosition(CEGUI.UVector2(cegui_absdim(x), cegui_absdim(y)))
end

function self.SetTipsItem(attr, itemobj, x, y, showbtn, school)
	self.m_pUse:setVisible(false)
    self.m_pDestroy:setVisible(false)
	self.m_pMainFrame:setVisible(true)
	GetGameUIManager():RemoveUIEffect(self.m_pEditBox)

	self.m_pEditBox:Clear();
	-- self.m_pEquipColor:setProperty("Image", "")
	if attr.itemtypeid % 0xf == 8 then
        local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(attr.id)
		local colorconfig = knight.gsp.item.GetCEquipColorConfigTableInstance():getRecorder(equipConfig.equipcolor)

		-- if colorconfig.id ~= -1 then
		-- 	self.m_pEquipColor:setProperty("Image", colorconfig.tipscolor)
		-- end
	end
	self.m_pName:setText(attr.name)
	if attr.itemtypeid % 0x10 == 8 then
		local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(attr.id)
		local colorconfig = knight.gsp.item.GetCEquipColorConfigTableInstance():getRecorder(equipConfig.equipcolor);
		self.m_pName:setProperty("TextColours", colorconfig.colorvalue)
	else
		self.m_pName:setProperty("TextColours", attr.colour)
	end
	self.m_pIcon:setProperty("Image", GetIconManager():GetItemIconPathByID(attr.icon):c_str())

	local maker = require "ui.tips.basemaker"
	maker.make_common(self.m_pEditBox, attr, itemobj, school)
	maker.makedes(self.m_pEditBox, attr)
	self.m_pEditBox:AppendBreak()
	self.m_pEditBox:Refresh()
    local extendheight = self.m_pEditBox:GetExtendSize().height - defaulty
    extendheight = extendheight > 0 and extendheight or 0
	self.m_pEditBox:setSize(CEGUI.UVector2(
		CEGUI.UDim(0, defaultx), 
		CEGUI.UDim(0, defaulty + extendheight + 20)))
    self.m_pMainFrame:setSize(CEGUI.UVector2(CEGUI.UDim(0, framex), CEGUI.UDim(0, framey + extendheight + 10)))
    
    self.ResetPosition(attr, x, y)
    self.m_pEditBox:Refresh()
    self.m_pEditBox:HandleTop()
end
function self.init()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pMainFrame = winMgr:getWindow("ItemTips/back")
	self.m_pEditBox = CEGUI.toRichEditbox(winMgr:getWindow("ItemTips"))
    -- self.m_pEquipColor = winMgr:getWindow("ItemTips/colorimage")
	self.m_pName = winMgr:getWindow("ItemTips/name")
	self.m_pIcon = winMgr:getWindow("ItemTips/icon")
	self.m_pLockIcon = winMgr:getWindow("ItemTips/lockicon")
	self.m_pBindText = winMgr:getWindow("ItemTips/bind")
    self.m_pDestroy = CEGUI.toPushButton(winMgr:getWindow("ItemTips/delete"))
    self.m_pUse = CEGUI.toPushButton(winMgr:getWindow("ItemTips/use"))
end
function self:Exit()
	self = nil
end
return self