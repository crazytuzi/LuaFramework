require "ui.dialog"
ShenbingLiqiDlg = {}
setmetatable(ShenbingLiqiDlg, Dialog)
ShenbingLiqiDlg.__index = ShenbingLiqiDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
ShenbingLiqiDlg.LongXueShi = 35081
ShenbingLiqiDlg.MaoYanShi = 35079
ShenbingLiqiDlg.GanLanShi = 35085

function ShenbingLiqiDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = ShenbingLiqiDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ShenbingLiqiDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = ShenbingLiqiDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ShenbingLiqiDlg.getInstanceNotCreate()
    return _instance
end

function ShenbingLiqiDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function ShenbingLiqiDlg.ToggleOpenClose()
	if not _instance then 
		_instance = ShenbingLiqiDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function ShenbingLiqiDlg.GetLayoutFileName()
    return "shenbingliqi.layout"
end
function ShenbingLiqiDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.cell0 = CEGUI.toItemCell(winMgr:getWindow("shenbingliqi/case/line/cell"))	
	self.cellLongXue = CEGUI.toItemCell(winMgr:getWindow("shenbingliqi/case/cell0"))	
	self.cellMaoYan = CEGUI.toItemCell(winMgr:getWindow("shenbingliqi/case/cell1"))	
	self.cellGanLan = CEGUI.toItemCell(winMgr:getWindow("shenbingliqi/case/cell2"))

	self.money = winMgr:getWindow("shenbingliqi/text1")
	self.dazao = CEGUI.Window.toPushButton(winMgr:getWindow("shenbingliqi/button"))
	self.dazao:subscribeEvent("Clicked",ShenbingLiqiDlg.HandleClicked,self)

	local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(ShenbingLiqiDlg.LongXueShi)
	self:AddTip(self.cellLongXue , item)
	
	local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(ShenbingLiqiDlg.MaoYanShi)
	self:AddTip(self.cellMaoYan , item)
	
	local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(ShenbingLiqiDlg.GanLanShi)
	self:AddTip(self.cellGanLan , item)

	local item = GetRoleItemManager():FindItemByBagIDAndPos(knight.gsp.item.BagTypes.EQUIP, 0)
	if item then
		self.cell0:setID(item:GetThisID())
		local attr = item:GetBaseObject()
		local cfg = require("utils.mhsdutils").getLuaBean("knight.gsp.item.cshenbingliqi", attr.id)
		if cfg then
			attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.formerid)
		end
--		item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(item:GetObjectID())
		self.cell0:SetImage(GetIconManager():GetImageByID(attr.icon))
		self.cell0:subscribeEvent("TableClick", ShenbingLiqiDlg.EquipTip,self)
	end

	self.kuang = winMgr:getWindow("shenbingliqi/effect0")
	self.ju = winMgr:getWindow("shenbingliqi/effect1")



end

------------------- private: -----------------------------------
function ShenbingLiqiDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ShenbingLiqiDlg)
    return self
end
function ShenbingLiqiDlg:HandleClicked(args)
    local hasmoney = GetRoleItemManager():GetPackMoney()
    if hasmoney < tonumber(self.money:getText()) then
        GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(120025).msg)
        return
    end
  -- require("manager.luaprotocolmanager"):send(require("protocoldef.knight.gsp.item.creqsuperweapon"):new())
  require("ui.readtimeprogressdlg").Setup(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(145862).msg,1.3,ShenbingLiqiDlg.requestServer)
  if require("ui.readtimeprogressdlg").getInstanceNotCreate() then
    local win =  require("ui.readtimeprogressdlg").getInstanceNotCreate():GetWindow() 
	local ScreenSize = CEGUI.System:getSingleton():getGUISheet():getPixelSize()
	win:setYPosition( CEGUI.UDim(0,630))
  end
  require("ui.readtimeprogressdlg").Start()
  self:playEffect()
end


function ShenbingLiqiDlg.requestServer()
    require("manager.luaprotocolmanager"):send(require("protocoldef.knight.gsp.item.creqsuperweapon"):new())
end


function ShenbingLiqiDlg:AddTip(itemcell,item)
	itemcell:SetImage(GetIconManager():GetImageByID(item.icon))
	itemcell:setID(item.id)
	itemcell:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
    local hasnum = GetRoleItemManager():GetItemNumByBaseID(item.id)
    if hasnum <=0 then
        itemcell:setEnabled(false)
    end
end

local function GetSecondType(typeid)
	local n = math.floor(typeid / 0x10)
	return n % 0x10
end


function ShenbingLiqiDlg:EquipTip(args)
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	local e = CEGUI.toMouseEventArgs(args)
	local pt = e.position
	local itemobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP, id)
	local pItem = GetRoleItemManager():FindItemByBagAndThisID(id, knight.gsp.item.BagTypes.EQUIP)
	local attr = pItem:GetBaseObject()
	local cfg = require("utils.mhsdutils").getLuaBean("knight.gsp.item.cshenbingliqi", attr.id)
	if cfg then
		attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.formerid)
	end
	if not itemobj or itemobj.bNeedRequireself then
		local p = knight.gsp.item.CItemTips(knight.gsp.item.BagTypes.EQUIP, id)
		GetNetConnection():send(p)
	else
		local dlg = CToolTipsDlg:GetSingletonDialog()
		local luadlg = require "ui.tips.tooltipsdlg"
		if not luadlg.isPresent() then
			CToolTipsDlg:GetSingletonDialogAndShowIt()
		end
		luadlg.init()
		luadlg.SetTipsItem(attr, itemobj, pt.x, pt.y, true, self.m_iSchool)
		if not luadlg.m_pMainFrame:isVisible() then
			luadlg.m_pMainFrame:setVisible(true)
		end
	end
end

function ShenbingLiqiDlg:playEffect()
	local effect = GetGameUIManager():AddUIEffect(self.kuang, MHSD_UTILS.get_effectpath(10416), false)
    --[[
	if effect then
		local notify = CGameUImanager:createNotify(self.OnEffectEnd)
		effect:AddNotify(notify)
	else
		GetGameUIManager():AddUIEffect(self.kuang, MHSD_UTILS.get_effectpath(10416), false)
	end
    ]]
end

function ShenbingLiqiDlg.playSucEffect()
	if not GetPlayRoseEffecstManager() then 
        CPlayRoseEffecst:NewInstance()
	 end
	if GetPlayRoseEffecstManager() then
     GetPlayRoseEffecstManager():PlayLevelUpEffect(10418, 0) 
	end
end
function ShenbingLiqiDlg.OnEffectEnd()
	local dlg = require "ui.shenbingliqidlg":getInstanceNotCreate()
	if not dlg then
		return
	end
	GetGameUIManager():AddUIEffect(dlg.ju, MHSD_UTILS.get_effectpath(10415), false)
end

return ShenbingLiqiDlg
