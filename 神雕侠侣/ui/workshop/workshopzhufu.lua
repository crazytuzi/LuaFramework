require "ui.dialog"
require "ui.workshop.workshopequipcell"
require "ui.workshop.workshophelper"

local WorkshopZhufuDlg = {}

setmetatable(WorkshopZhufuDlg, Dialog);
WorkshopZhufuDlg.__index = WorkshopZhufuDlg;

local _instance;
local MoneyIconID = 1262
local stuffID = 37541


local BlessState = { CanBless = 0, NoEquip = 1, LackChongxing = 2, LackDuanZao = 3, 
					 LackStone = 4, LackMoney = 5, MaxLevel = 6 }
local BlessMessage = {}
BlessMessage[BlessState.NoEquip] = 146337
BlessMessage[BlessState.LackChongxing] = 146340
BlessMessage[BlessState.LackDuanZao] = 146339
BlessMessage[BlessState.LackStone] = 146341
BlessMessage[BlessState.LackMoney] = 146342
BlessMessage[BlessState.MaxLevel] = 146338


function WorkshopZhufuDlg.getInstance()
	if _instance == nil then
		_instance = WorkshopZhufuDlg:new();
		_instance:OnCreate();
	end

	return _instance;
end

function WorkshopZhufuDlg.getInstanceNotCreate()
	return _instance;
end

function WorkshopZhufuDlg.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		LogInfo("WorkshopZhufuDlg DestroyDialog")
	end
end

function WorkshopZhufuDlg.getInstanceAndShow()
    if not _instance then
        _instance = WorkshopZhufuDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function WorkshopZhufuDlg.ToggleOpenClose()
	if not _instance then 
		_instance = WorkshopZhufuDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function WorkshopZhufuDlg.GetLayoutFileName()
	return "workshopzhufu.layout";
end

function WorkshopZhufuDlg:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, WorkshopZhufuDlg);

	return zf;
end

function WorkshopZhufuDlg.getBlessConfig( id )
	return BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cequipbless"):getRecorder(id)
end

------------------------------------------------------------------------------

function WorkshopZhufuDlg:OnCreate()
	LogInfo("WorkshopZhufuDlg OnCreate ")
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.equipPanel = winMgr:getWindow("workshopzhufu/left");
	self.EffectWnd = winMgr:getWindow("workshopzhufu/effect")
	
	self.itemCells = {}
	for i = 1, 6 do
		LogInsane("WorkshopZhufuDlg:NewItem")
		local newItem = Workshopequipcell.new(self.equipPanel, i - 1)
		self.itemCells[i] = newItem
		newItem.Frame:subscribeEvent("MouseClick", WorkshopZhufuDlg.HandleItemClicked, self)
		--move mark a little lefttop
		local posx = newItem.Mark:getXPosition()
		posx.offset = posx.offset - 10
		newItem.Mark:setXPosition(posx)
		local posy = newItem.Mark:getYPosition()
		posy.offset = posy.offset - 10
		newItem.Mark:setYPosition(posy)
	end

	self.currInfoWnd = {}
	self.currInfoWnd.equipCell = CEGUI.toItemCell(winMgr:getWindow("workshopzhufu/right/part1/item1"))
	self.currInfoWnd.equipName = winMgr:getWindow("workshopzhufu/right/part1/name1")
	self.currInfoWnd.blessLv = winMgr:getWindow("workshopzhufu/right/part1/level1")
	self.currInfoWnd.chongxing = winMgr:getWindow("workshopzhufu/right/part1/num0")
	self.currInfoWnd.duanzao = winMgr:getWindow("workshopzhufu/right/part1/num1")
	self.currInfoWnd.xiangqian = winMgr:getWindow("workshopzhufu/right/part1/num2")

	self.nextInfoWnd = {}
	self.nextInfoWnd.equipCell = CEGUI.toItemCell(winMgr:getWindow("workshopzhufu/right/part2/item2"))
	self.nextInfoWnd.equipName = winMgr:getWindow("workshopzhufu/right/part2/name2")
	self.nextInfoWnd.blessLv = winMgr:getWindow("workshopzhufu/right/part2/level2")
	self.nextInfoWnd.chongxing = winMgr:getWindow("workshopzhufu/right/part2/num0")
	self.nextInfoWnd.duanzao = winMgr:getWindow("workshopzhufu/right/part2/num1")
	self.nextInfoWnd.xiangqian = winMgr:getWindow("workshopzhufu/right/part2/num2")

	self.needStuffWnd = {}
	self.needStuffWnd.stuffCell = CEGUI.toItemCell(winMgr:getWindow("workshopzhufu/right/bot/item1"))
	self.needStuffWnd.moneyCell = CEGUI.toItemCell(winMgr:getWindow("workshopzhufu/right/bot/item2"))
	self.needStuffWnd.moneyCell:SetImage(GetIconManager():GetItemIconByID(MoneyIconID))
	self.needStuffWnd.stuffName = winMgr:getWindow("workshopzhufu/right/bot/name1")
	self.needStuffWnd.moneyName = winMgr:getWindow("workshopzhufu/right/bot/name2")
	self.needStuffWnd.moneyName:setText(MHSD_UTILS.get_resstring(2636))
	local itemconfig = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(stuffID)
	self.needStuffWnd.stuffName:setText(itemconfig.name)
	self.needStuffWnd.stuffCell:SetImage(GetIconManager():GetItemIconByID(itemconfig.icon))

	self.blessBtn = winMgr:getWindow("workshopzhufu/right/ok")
	self.blessBtn:subscribeEvent("MouseClick", self.HandleBlessBtnClicked, self)

	self:InitData()

	--init ui
	self.currInfoWnd.chongxing:setText("0")
	self.currInfoWnd.duanzao:setText("0")
	self.currInfoWnd.xiangqian:setText("0")

	self.nextInfoWnd.chongxing:setText("0")
	self.nextInfoWnd.duanzao:setText("0")
	self.nextInfoWnd.xiangqian:setText("0")


	WorkshopHelper.ShowItemInCell(nil, self.currInfoWnd.equipCell, self.currInfoWnd.equipName)
	WorkshopHelper.ShowItemInCell(nil, self.nextInfoWnd.equipCell, self.nextInfoWnd.equipName)

	--select first equip
	for i = 1, #self.itemCells do
		if self.itemCells[i].Item:getID() ~= 0 then
			self:SetItemSelected(i)
			break
		end
	end

	self:RefreshCanBlessEffect()

	self.m_hItemNumChangeNotify = GetRoleItemManager():InsertLuaItemNumChangeNotify(WorkshopZhufuDlg.OnItemNumChange)

	LogInfo("WorkshopZhufuDlg OnCreate finish")
end

function WorkshopZhufuDlg:InitData()
	for i = 1, #self.itemCells do

		local equipCfg  = WorkshopHelper.ItemList[i]
		if equipCfg == nil then break end
		local curEquipWnd = self.itemCells[i]
		local bagtype = knight.gsp.item.BagTypes.EQUIP
		local item = GetRoleItemManager():FindItemByBagIDAndPos(bagtype, equipCfg.type)

		if item == nil then --cell without equip
			curEquipWnd.Name:setText(MHSD_UTILS.get_resstring(2736)..MHSD_UTILS.get_resstring(equipCfg.empty_string))
			curEquipWnd.Item:setID(0)
		else --fill equip
			WorkshopHelper.ShowItemInCell(item:GetBaseObject(), curEquipWnd.Item, curEquipWnd.Name)
			
			local equipObj = require "manager.itemmanager".getObject(bagtype, item:GetThisID())
			if equipObj then
				if equipObj.bNeedRequireself then --require tips info
					GetNetConnection():send(knight.gsp.item.CItemTips(knight.gsp.item.BagTypes.EQUIP, item:GetThisID()))
					curEquipWnd.CrystalNum = math.huge
					curEquipWnd.equipLevel = 0
					curEquipWnd.blessLevel = 0
				else --set data
					curEquipWnd.CrystalNum = equipObj.crystalnum
					curEquipWnd.equipLevel = item:GetBaseObject().level
					curEquipWnd.blessLevel = equipObj.blesslv
				end
			end
			curEquipWnd.Item:setID(item:GetThisID())
		end
		curEquipWnd.Level:setText("")
		
	end
end

function WorkshopZhufuDlg:RefreshCanBlessEffect()
	for i = 1, 6 do
		v = self.itemCells[i]
		local mark = v.Mark
		if self:CanBless(v) == BlessState.CanBless then
			if not v.HasEffect then
				GetGameUIManager():AddUIEffect(mark, MHSD_UTILS.get_effectpath(10460), true)
				v.HasEffect = true
			end
		elseif v.HasEffect then
			GetGameUIManager():RemoveUIEffect(mark)
			v.HasEffect = false
		end
	end
end

function WorkshopZhufuDlg.OnItemNumChange(bagid, itemkey, itembaseid)
	if _instance == nil then
		return
	end

	if stuffID == itembaseid then
		_instance:RefreshStuffInfo()
		_instance:RefreshCanBlessEffect()
		return
	end
end

function WorkshopZhufuDlg:HandleItemClicked(e)
	if self.blessProgressing then return end
	
	local MouseEvenArgs = CEGUI.toMouseEventArgs(e)
	for i = 1, #self.itemCells do
		if MouseEvenArgs.window == self.itemCells[i].Frame then
			if self.itemCells[i].Item:getID() ~= 0 then
				self:SetItemSelected(i)
				return true
			else
				return false
			end
		end
	end
end

function WorkshopZhufuDlg:SetItemSelected(i)
	local curclicked = self.itemCells[i]
	if self.clickeditem and self.clickeditem ~= curclicked then
		self.clickeditem.Frame:setProperty("Image", "set:MainControl9 image:shopcellnormal")
	end
	if self.clickeditem ~= curclicked then
		self.clickeditem = curclicked
		self.clickeditem.Frame:setProperty("Image", "set:MainControl9 image:shopcellchoose")
	end

	self:RefreshEquipInfo()
	self:RefreshStuffInfo()
end

function WorkshopZhufuDlg:RefreshStuffInfo()
	local config = self.getBlessConfig(self.clickeditem.blessLevel)
	--stuff
	local neednum = config.coststone
	local hasnum = GetRoleItemManager():GetItemNumByBaseID(stuffID)
	self.needStuffWnd.stuffCell:SetTextUnit(neednum)
	if hasnum >= neednum then
		self.needStuffWnd.stuffCell:SetTextUnitColor(MHSD_UTILS.get_greencolor())
	else
		self.needStuffWnd.stuffCell:SetTextUnitColor(MHSD_UTILS.get_redcolor())
	end

	--money
	local needMoney = config.costmoney
	local hasMoney = GetRoleItemManager():GetPackMoney()
	self.needStuffWnd.moneyCell:SetTextUnit(WorkshopHelper.GetMoneyString(needMoney))
	if hasMoney >= needMoney then
		self.needStuffWnd.moneyCell:SetTextUnitColor(MHSD_UTILS.get_greencolor())
	else
		self.needStuffWnd.moneyCell:SetTextUnitColor(MHSD_UTILS.get_redcolor())
	end
end

function WorkshopZhufuDlg:RefreshEquipInfo(  )
	print("WorkshopZhufuDlg RefreshEquipInfo")
	local itemkey = self.clickeditem.Item:getID()
	local bagid = knight.gsp.item.BagTypes.EQUIP
	local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)

	WorkshopHelper.ShowItemInCell(item:GetBaseObject(), self.currInfoWnd.equipCell, self.currInfoWnd.equipName)
	WorkshopHelper.ShowItemInCell(item:GetBaseObject(), self.nextInfoWnd.equipCell, self.nextInfoWnd.equipName)

	local currConfig = self.getBlessConfig(self.clickeditem.blessLevel)
	self.currInfoWnd.blessLv:setText(currConfig.equipnametext)
	self.currInfoWnd.blessLv:setProperty("TextColours", currConfig.textcolor)
	self.currInfoWnd.chongxing:setText(currConfig.extrapercent.."%")
	self.currInfoWnd.duanzao:setText(tostring(currConfig.extrarefinelv))
	self.currInfoWnd.xiangqian:setText(tostring(currConfig.gemhole))

	local nextConfig = self.getBlessConfig(currConfig.nextblesslv)
	if not nextConfig then
		nextConfig = currConfig
	end
	self.nextInfoWnd.blessLv:setText(nextConfig.equipnametext)
	self.nextInfoWnd.blessLv:setProperty("TextColours", nextConfig.textcolor)
	self.nextInfoWnd.chongxing:setText(nextConfig.extrapercent.."%")
	self.nextInfoWnd.duanzao:setText(tostring(nextConfig.extrarefinelv))
	self.nextInfoWnd.xiangqian:setText(tostring(nextConfig.gemhole))

	self:SetUpgradeColor(self.nextInfoWnd.chongxing, currConfig.extrapercent, nextConfig.extrapercent)
	self:SetUpgradeColor(self.nextInfoWnd.duanzao, currConfig.extrarefinelv, nextConfig.extrarefinelv)
	self:SetUpgradeColor(self.nextInfoWnd.xiangqian, currConfig.gemhole, nextConfig.gemhole)
end

function WorkshopZhufuDlg:SetUpgradeColor( wnd, curr, next )
	if tonumber(curr) < tonumber(next) then
		wnd:setProperty("TextColours", "FF33FF33")
	else
		wnd:setProperty("TextColours", "FFFFFFFF")
	end
end

function WorkshopZhufuDlg:CanBless(item)
	item = item or self.clickeditem
	if not item or not item.blessLevel then -- no equip selected
		return BlessState.NoEquip		
	end
	local config = self.getBlessConfig(item.blessLevel)
	if item.CrystalNum < config.needstarlv then
		print("WorkshopZhufuDlg LackChongxing")
		local starconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(config.needstarlv)
		return BlessState.LackChongxing, starconfig.describe
	end
	if item.equipLevel < config.needequiplv then
		print("WorkshopZhufuDlg LackDuanZao")
		return BlessState.LackDuanZao, tostring(config.needequiplv)
	end
	if GetRoleItemManager():GetItemNumByBaseID(stuffID) < config.coststone then
		print("WorkshopZhufuDlg LackStone")
		return BlessState.LackStone
	end
	if GetRoleItemManager():GetPackMoney() < config.costmoney then
		print("WorkshopZhufuDlg LackMoney")
		return BlessState.LackMoney
	end
	if config.nextblesslv == -1 then
		return BlessState.MaxLevel
	end
	return BlessState.CanBless
end

function WorkshopZhufuDlg.OnProcessTimeUp()
	if not _instance then return end
	local self = _instance
	print("WorkshopZhufuDlg bless "..tostring(self.clickeditem.Item:getID()))
	local p = require "protocoldef.knight.gsp.item.creqequipbless":new()
	p.equipkey = self.clickeditem.Item:getID()
	require "manager.luaprotocolmanager":send(p)

end

function WorkshopZhufuDlg.OnSuccessEffectEnd()
	if not _instance then return end
	local self = _instance
	if self.tmpLevel == 1 then
		require "ui.workshop.workshoplabel".Show(3, 3, 0)
		for i,v in ipairs(self.itemCells) do
			if v == self.clickeditem then
				local xq = require "ui.workshop.workshopxqnew".getInstance()
				xq:SetClickedItem(i)
				xq:PlayUnlockEffect(5)
				WorkshopZhufuDlg.DestroyDialog()
				return
			end
		end
	elseif self.tmpLevel == 9 then
		require "ui.workshop.workshoplabel".Show(3, 3, 0)
		for i,v in ipairs(self.itemCells) do
			if v == self.clickeditem then
				local xq = require "ui.workshop.workshopxqnew".getInstance()
				xq:SetClickedItem(i)
				xq:PlayUnlockEffect(6)
				WorkshopZhufuDlg.DestroyDialog()
				return
			end
		end
	end
	self.tmpLevel = nil
	self.blessProgressing = false
end

function WorkshopZhufuDlg:OnBlessSuccess()
	self.tmpLevel = self.clickeditem.blessLevel + 1
	local pEffect = GetGameUIManager():AddUIEffect(self.EffectWnd, MHSD_UTILS.get_effectpath(10447), false)
	local notify = CGameUImanager:createNotify(self.OnSuccessEffectEnd)
	pEffect:AddNotify(notify)
end

function WorkshopZhufuDlg:HandleBlessBtnClicked( )
	local result, param = self:CanBless()
	local messageid = BlessMessage[result]
	if result == BlessState.CanBless then
		print("WorkshopZhufuDlg CanBless")
		CReadTimeProgressBarDlg:GetSingletonDialogAndShowIt():StartWithLuaCallback("", 1, WorkshopZhufuDlg.OnProcessTimeUp)
		self.blessProgressing = true
	elseif param then
		local sb = StringBuilder:new()
		sb:Set("parameter1", param)
		local str = sb:GetString(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(messageid).msg)
		GetGameUIManager():AddMessageTip(str, false)
		sb:delete()
	else
		GetGameUIManager():AddMessageTipById(messageid)
	end
end

return WorkshopZhufuDlg