CharacterPropertyMini = {}
setmetatable(CharacterPropertyMini, Dialog)
CharacterPropertyMini.__index = CharacterPropertyMini

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local ARMS = 0
local CUFF = 1
local ADORN = 2
local LORICAE = 3
local WAISTBAND = 4
local BOOT = 5
local TIRE = 6
local KITBAG= 7
local EYEPATCH = 8
local RESPIRATOR = 9
local JEWELRY = 6
function CharacterPropertyMini.getInstance()
	LogInfo("enter get characterpropertymini instance")
    if not _instance then
        _instance = CharacterPropertyMini:new()
        _instance:OnCreate()
    end
    
    return _instance
end
local function GetSecondType(typeid)
	local n = math.floor(typeid / 0x10)
	return n % 0x10
end
function CharacterPropertyMini.getInstanceAndShow()
	LogInfo("enter characterpropertymini instance show")
    if not _instance then
        _instance = CharacterPropertyMini:new()
        _instance:OnCreate()
	else
		LogInfo("set characterpropertymini visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CharacterPropertyMini.getInstanceNotCreate()
    return _instance
end

function CharacterPropertyMini.DestroyDialog()
	if _instance then 
		LogInfo("destroy characterpropertymini")
		if _instance.m_pSprite then
			_instance.m_pSprite:delete()
			_instance.m_pSprite = nil
		end
		_instance.m_pSpriteWnd:getGeometryBuffer():setRenderEffect(nil)
		_instance:OnClose()
		_instance = nil
	end
end

function CharacterPropertyMini.ToggleOpenClose()
	if not _instance then 
		_instance = CharacterPropertyMini:new() 
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

function CharacterPropertyMini.GetLayoutFileName()
    return "characterpropertymini.layout"
end

function CharacterPropertyMini:OnCreate()
	LogInfo("characterpropertymini oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pName = winMgr:getWindow("characterpropertymini/Back/name")
	self.m_pLevel = winMgr:getWindow("characterpropertymini/Back/level")
	self.m_pID = winMgr:getWindow("characterpropertymini/Back/id")
	self.m_pScore = winMgr:getWindow("characterpropertymini/point")
	self.m_pJewelryScore = winMgr:getWindow("characterpropertymini/ring")
	self.m_pSchool = winMgr:getWindow("characterpropertymini/Back/school")
	self.m_pEquip = {}
	self.m_pEquip[ADORN] = CEGUI.toItemCell(winMgr:getWindow("characterpropertymini/adorn")) 			--椤归�
	self.m_pEquip[ARMS] = CEGUI.toItemCell(winMgr:getWindow("characterpropertymini/arms")) 				--姝��
	self.m_pEquip[CUFF] = CEGUI.toItemCell(winMgr:getWindow("characterpropertymini/cuff"))  			--�よ�
	self.m_pEquip[WAISTBAND] = CEGUI.toItemCell(winMgr:getWindow("characterpropertymini/waistband")) 	--�板甫
	self.m_pEquip[TIRE] = CEGUI.toItemCell(winMgr:getWindow("characterpropertymini/tire"))  			--澶撮グ
	self.m_pEquip[KITBAG] = CEGUI.toItemCell(winMgr:getWindow("characterpropertymini/kitbag"))  		--��グ
	self.m_pEquip[LORICAE] = CEGUI.toItemCell(winMgr:getWindow("characterpropertymini/loricae"))  		--���
	self.m_pEquip[BOOT] = CEGUI.toItemCell(winMgr:getWindow("characterpropertymini/boot"))  			--���
	self.m_pEquip[EYEPATCH] = CEGUI.toItemCell(winMgr:getWindow("characterpropertymini/mask")) 			--�㈤グ
	self.m_pEquip[RESPIRATOR] = CEGUI.toItemCell(winMgr:getWindow("characterpropertymini/mask1"))  		--�㈤グ
	self.m_pSpriteWnd = winMgr:getWindow("characterpropertymini/spriteBack")
	self.m_pEffectWnd = winMgr:getWindow("characterpropertymini/point1")
	
	self.m_pEquip[CUFF]:SetBackGroundImage("BaseControl","Cuff")
	self.m_pEquip[ADORN]:SetBackGroundImage("BaseControl","Accessories")
	self.m_pEquip[LORICAE]:SetBackGroundImage("BaseControl","Armour")
	self.m_pEquip[ARMS]:SetBackGroundImage("BaseControl","Weapon")
	self.m_pEquip[TIRE]:SetBackGroundImage("BaseControl","Head")
	self.m_pEquip[KITBAG]:SetBackGroundImage("BaseControl","Back")
	self.m_pEquip[BOOT]:SetBackGroundImage("BaseControl","Shoe")
	self.m_pEquip[WAISTBAND]:SetBackGroundImage("BaseControl","Belt")
	self.m_pEquip[EYEPATCH]:SetBackGroundImage("BaseControl","Mask")
	self.m_pEquip[RESPIRATOR]:SetBackGroundImage("BaseControl","Mask")	

    -- subscribe event
	for i = 0, 9 do
	--	require "utils.mhsdutils".SetEquipWindowShowtips(self.m_pEquip[i])
		self.m_pEquip[i]:subscribeEvent("TableClick", CharacterPropertyMini.HandleItemClick, self)
	end

	self.m_pSpriteWnd:getGeometryBuffer():setRenderEffect(CGameUImanager:createXPRenderEffect(0, CharacterPropertyMini.performPostRenderFunctions))
	LogInfo("characterpropertymini oncreate end")

	self.m_pName:subscribeEvent("MouseClick", CharacterPropertyMini.HandleNameClicked, self)
end

------------------- private: -----------------------------------


function CharacterPropertyMini:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CharacterPropertyMini)
    return self
end

function CharacterPropertyMini:Init(roleid, rolename, shape, level, school, totalscorenosuse, baginfo, tips, footprint)
	LogInfo("characterpropertymini init")
	self.m_pID:setText(tostring(roleid))
	self.roleid = roleid
	self.m_pName:setText(rolename)
	self.m_pLevel:setText(tostring(level))
	self.m_pSchool:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(school).name)
	self.m_iSchool = school
	local totalscore = 0
	local jewelryscore = 0
	if self.m_pSprite then
		if self.m_pSprite:GetModelID() ~= shape then
			self.m_pSprite:SetModel(shape)
		end
	else
		self.m_pSprite = CUISprite:new(shape)
	end
	local pt = self.m_pSpriteWnd:GetScreenPosOfCenter()
	local wndHeight = self.m_pSpriteWnd:getPixelSize().height
	local loc = XiaoPang.CPOINT(pt.x, pt.y + wndHeight / 3.0)
	self.m_pSprite:SetUILocation(loc)
	self.m_pSprite:SetUIDirection(XiaoPang.XPDIR_BOTTOM)
	
	self.m_bagInfo = baginfo
	self.m_tips = tips
	self.m_ids = {}

	for i, v in pairs(baginfo.items) do
	--	local item = CRoleItem()
	--	item:SetItemBaseData(v.id, 8)
		local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(v.id)
		self.m_pEquip[v.position]:setID(v.key)
		self.m_pEquip[v.position]:SetImage(GetIconManager():GetItemIconByID(itemattr.icon))
		self.m_ids[v.key] = v.id

		if v.position == ARMS then
			self.m_pSprite:SetSpriteComponent(eSpriteWeapon, v.id)
		end

		local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(v.id)
        local equipColor = equipConfig.equipcolor
		local colorconfig = knight.gsp.item.GetCEquipColorConfigTableInstance():getRecorder(equipColor)
		GetGameUIManager():AddUIEffect(self.m_pEquip[v.position],colorconfig.effectshow)

		--tolua.cast(item:GetObject(), "EquipObject")
		if GetSecondType(itemattr.itemtypeid) ~= JEWELRY then
			local data = GNET.Marshal.OctetsStream(self.m_tips[v.key])
			--equipObject:MakeTips(data)
			local equipObject = require "manager.octets2table.equip"(data)
			totalscore = totalscore + GetLuaEquipScore(v.id, equipObject,  GetSecondType(itemattr.itemtypeid)) --item:GetEquipScore()
		else
			local data = GNET.Marshal.OctetsStream(self.m_tips[v.key])
			local itemobj = require "protocoldef.rpcgen.knight.gsp.item.decorationtipsoctets":new()
			itemobj:unmarshal(data)
			jewelryscore = jewelryscore + GetLuaEquipScore(v.id, itemobj,  GetSecondType(itemattr.itemtypeid), school)
		end
	end
	self.m_pScore:setText(MHSD_UTILS.get_resstring(1637) .. tostring(totalscore))
	self.m_pJewelryScore:setText(MHSD_UTILS.get_resstring(3000) .. tostring(jewelryscore))

	local fpConfig = knight.gsp.game.GetCfootprintTableInstance():getRecorder(footprint)
	GetGameUIManager():AddUIEffect(self.m_pEffectWnd, fpConfig.effectpath, true)
end

function CharacterPropertyMini.performPostRenderFunctions(id)
	if _instance and _instance.m_pSpriteWnd then
		if _instance.m_pSpriteWnd:isVisible() and _instance.m_pSpriteWnd:getEffectiveAlpha() > 0.95 and _instance.m_pSprite then
			local pt = _instance.m_pSpriteWnd:GetScreenPosOfCenter()
			local wndHeight = _instance.m_pSpriteWnd:getPixelSize().height
			local loc = XiaoPang.CPOINT(pt.x, pt.y + wndHeight / 3.0)
			_instance.m_pSprite:SetUILocation(loc)
			_instance.m_pSprite:RenderUISprite()
		end
	end	
end

function CharacterPropertyMini:HandleItemClick(args)
	LogInfo("characterpropertymini handle item click")
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local pt = e.position
	if self.m_tips[id] then
		local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(self.m_ids[id])
		local data = GNET.Marshal.OctetsStream(self.m_tips[id])
		local pobj
		if GetSecondType(attr.itemtypeid) ~= JEWELRY then
			local data = GNET.Marshal.OctetsStream(self.m_tips[id])
			--equipObject:MakeTips(data)
			pobj = require "manager.octets2table.equip"(data)
		else
			local data = GNET.Marshal.OctetsStream(self.m_tips[id])
			pobj = require "protocoldef.rpcgen.knight.gsp.item.decorationtipsoctets":new()
			pobj:unmarshal(data)
		end
		local dlg = CToolTipsDlg:GetSingletonDialog()
		local luadlg = require "ui.tips.tooltipsdlg"
		if not luadlg.isPresent() then
			CToolTipsDlg:GetSingletonDialogAndShowIt()
		end
		luadlg.init()
		luadlg.SetTipsItem(attr, pobj, pt.x, pt.y, true, self.m_iSchool)
		if not luadlg.m_pMainFrame:isVisible() then
			luadlg.m_pMainFrame:setVisible(true)
		end
		--[[
		local item = CRoleItem()
		item:SetItemBaseData(self.m_ids[id], 8)
		local equipObject = tolua.cast(item:GetObject(), "EquipObject")
		local data = GNET.Marshal.OctetsStream(self.m_tips[id])
		equipObject:MakeTips(data)
		local tipDlg = CToolTipsDlg:GetSingletonDialogAndShowIt()
		if tipDlg then
			tipDlg:SetTipsItem(item, pt.x, pt.y, true)
		end
		--]]
	end
end
function CharacterPropertyMini:HandleNameClicked(args)
	local p = require "protocoldef.knight.gsp.creqoldname":new()
	p.roleid = 	self.roleid  
	require "manager.luaprotocolmanager":send(p)
	return true
end


return CharacterPropertyMini
