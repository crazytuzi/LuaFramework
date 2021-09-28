knight_gsp_item = {}

function knight_gsp_item.SExchangeSuc_Lua_Process(p)
	print("knight_gsp_item.SExchangeSuc_Lua_Process")
	local proto = KnightClient.toSExchangeSuc(p)
	if proto.flag == 8 then
		local FestivalShopDlg = require "ui.festivalshop.festivalshopdlg"
		FestivalShopDlg.score = proto.number
		FestivalShopDlg.getInstanceAndShow()
		FestivalShopDlg.getInstance():RefreshScore()
	else   -- return to C++ process 
		return true 
	end 
end

function knight_gsp_item.SPreviewRefineEquip_Lua_Process(p)
	print("knight_gsp_item.SPreviewRefineEquip_Lua_Process")
	local proto = KnightClient.toSPreviewRefineEquip(p)
	local workshopcx = require "ui.workshop.workshopcxnew"
	local instance = workshopcx.getInstance()
	if instance == nil then 
		print("Not found workshopcx instance")
		return
	end
	local previewObj = EquipObject()
	local data = GNET.Marshal.OctetsStream(proto.tips)
	previewObj:MakeTips(data)
	instance.PreviewItems[proto.itemkey] = previewObj
	if instance.clickeditem == nil then
		return
	end
	if instance.clickeditem.Item:getID() == proto.itemkey then
		local item = GetItemManager():FindItemByBagAndThisID(proto.itemkey, knight.gsp.item.BagTypes.EQUIP)
		if item then
		instance:MakeItemBaseEffects(item, instance.PreviewItem, true)
		end
	end
	return true
end

function knight_gsp_item.SItemTips_Lua_Process(p)
	if GetRoleItemManager() == nil then
	--	print("RoleItemManager uninit")
		return
	end
	local proto = KnightClient.toSItemTips(p)
	--print(string.format("SItemTips bagid=%d, itemkey=%d",proto.bagid, proto.itemkey))
	local data = GNET.Marshal.OctetsStream(proto.tips)
	
	local im = require "manager.itemmanager".push_data(proto.bagid, proto.itemkey, proto.tips)
	
	local pItem = GetRoleItemManager():FindItemByBagAndThisID(proto.itemkey, proto.bagid)
	if pItem == nil then
	--	print("tips item not found")
		return
	end
	if pItem:GetBaseObject().itemtypeid % 0x100 ~= 0x68 then
		pItem:GetObject():MakeTips(data)
	end

	pItem:GetObject():SetNeedRequireData(false)
	if proto.bagid == knight.gsp.item.BagTypes.EQUIP then
		pItem:UpdateEquipColor()
	end
	local tooltips = CToolTipsDlg:GetSingleton()
	if tooltips then
		local tipitem = tooltips:GetToolTipsItem()
		if tipitem == pItem then
			tooltips:RefreshTips()
		end
	end			
    Tip.Item.CTipsMaker:RefreshVisibleTipsData();	
	local warninglist = CWaringlistDlg:GetSingleton()
	local pWarning = warninglist:GetWarning(5)
	if pWarning then
		tolua.cast(pWarning, "CWorkshopCxWarning"):RefreshItemTips(pItem)
	end
	local wslabel = require "ui.workshop.workshoplabel"
	--print("finding workshop label")
	if wslabel then 
		--print("found!!")
		wslabel:RefreshItemTips(pItem)
	end
	if proto.bagid == knight.gsp.item.BagTypes.EQUIP then
		CMainPackDlg:GetSingleton():UpdateEquipTotalScore()
	end
	local blessDlg = require "ui.workshop.workshopzhufu"
	if blessDlg:getInstanceNotCreate() then
		blessDlg:getInstanceNotCreate():InitData()
		blessDlg:getInstanceNotCreate():RefreshEquipInfo()
		blessDlg:getInstanceNotCreate():RefreshStuffInfo()
	end
	print("SItemTips_Lua_Process finish "..tostring(proto.itemkey))
	return true
end
function knight_gsp_item.SAddItem_Lua_Process(p)
  local dlg = require "ui.item.depot":getInstanceOrNot()
  if dlg then
    local proto = KnightClient.toSAddItem(p)
    dlg:AddItem(proto)
  end
  return true
end
function knight_gsp_item.SGetBagInfo_Lua_Process(p)
  local dlg = require "ui.item.depot":getInstanceOrNot()
  if dlg then
    dlg:SetVisible(true)
    local proto = KnightClient.toSGetBagInfo(p)
    dlg:RefreshBag(proto)
  end
  return true
end

function knight_gsp_item.SModItemNum_Lua_Process(p)
  local dlg = require "ui.item.depot":getInstanceOrNot()
  if dlg then
    local proto = KnightClient.toSModItemNum(p)
    dlg:ModItemNum(proto)
  end
  return true
end

function knight_gsp_item.SModItemPos_Lua_Process(p)
  local dlg = require "ui.item.depot":getInstanceOrNot()
  if dlg then
    local proto = KnightClient.toSModItemPos(p)
    dlg:ModItemPos(proto)
  end
  return true
end

function knight_gsp_item.SRemoveItem_Lua_Process(p)
  local dlg = require "ui.item.depot":getInstanceOrNot()
  if dlg then
    local proto = KnightClient.toSRemoveItem(p)
    dlg:RemoveItem(proto)
  end
  return true
end

function knight_gsp_item.SRefreshBagCapacity_Lua_Process(p)
  local proto = KnightClient.toSRefreshBagCapacity(p)
  if proto.bagid == knight.gsp.item.BagTypes.DEPOT then
    local dlg = require "ui.item.depot":getInstanceOrNot()
    if dlg then
      dlg:RefreshDepotCapacity(proto.capacity)
    end
  end
  return true
end

return knight_gsp_item