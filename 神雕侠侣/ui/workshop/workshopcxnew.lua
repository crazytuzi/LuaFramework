require "ui.dialog"
require "utils.mhsdutils"
require "ui.workshop.workshopequipcell"
require "ui.workshop.workshophelper"
require "utils.log"
local MoneyIconID = 1262
local Gems = {
	{itemid=35195, exp=1},
	{itemid=35196, exp=5},
	{itemid=35197, exp=25}
}

local CrystalnumIntroduce = {
	Color = {2715, 2716, 2717, 2718, 2719, 2720, 2721, 2722},
	Number = {2723, 2724, 2725, 2726, 2727, 2728, 2729 , 2730}
}
local function GetGemUprate(diamondId)
	if diamondId == 35195 then return 1
	elseif diamondId == 35196 then return 5
	elseif diamondId == 35197 then return 25
	else return 0
	end
end
local function ShowStar(equipObj, container)
	local crystalnum = equipObj.crystalnum
	LogInsane("equip stars ="..crystalnum)
	local gemconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(crystalnum)
	if gemconfig.id == -1 then
		return
	end
	container:Clear()
	container:SetEmotionScale(CEGUI.Vector2(0.6, 0.6))
	local stars = gemconfig.stars
	for i = 7,0,-1 do
		local starLevel = stars % (10 ^(i + 1)) / (10 ^ i)
		if starLevel > 0 then
			if crystalnum <= 64 then
				container:AppendEmotion(149 + starLevel)
			else
				container:AppendEmotion(699 + starLevel)
			end
		end
	end
	container:Refresh()
end

local function ShowItemInCell(attr, cell, namewnd)
	if attr then
		local iconManager = GetIconManager()
	--	local attr = item:GetBaseObject()
		namewnd:setText(attr.name)
	--	local itemcolor = MHSD_UTILS.getColourStringByNumber(item:GetNameColour())
		if attr.itemtypeid % 0x10 == 8 then
			local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(attr.id)
			local colorconfig = knight.gsp.item.GetCEquipColorConfigTableInstance():getRecorder(equipConfig.equipcolor);
			namewnd:setProperty("TextColours", colorconfig.colorvalue)
		else
			namewnd:setProperty("TextColours", attr.colour)
		end
	--	namewnd:setProperty("TextColours", attr.colour);
		cell:SetImage(iconManager:GetItemIconByID(attr.icon))
	else
		namewnd:setText("")
		cell:SetImage(nil)
	end
end

local function toStarIntroduce(crystalnum)
	local n
	if crystalnum == 0 then n = 1
	else
		n = crystalnum
	end
	local color = math.floor((n - 1)/ #CrystalnumIntroduce.Number) + 1
	local number = (n - 1) % #CrystalnumIntroduce.Number + 1
	if color <= 0 or color > #CrystalnumIntroduce.Color then
		return ""
	end
	local colorindex = CrystalnumIntroduce.Color[color]
--	print("colorindex="..colorindex)
	local numberindex = CrystalnumIntroduce.Number[number]
--	print(string.format("colorindex=%d, numberindex=%d", colorindex, numberindex))
	local colorstr = MHSD_UTILS.get_resstring(colorindex)
	local numberstr = MHSD_UTILS.get_resstring(numberindex)
	local starstr = MHSD_UTILS.get_resstring(2731)
	
	local ret = string.format("%s%s%s", colorstr, numberstr, starstr)
	return ""
end

WorkshopCxNew = {}

setmetatable(WorkshopCxNew, Dialog)
WorkshopCxNew.__index = WorkshopCxNew

local _instance
function WorkshopCxNew.getInstance()
	print("new Workshopcxnew Instance")
	if not _instance then
		_instance = WorkshopCxNew:new()
	end
	return _instance
end

function WorkshopCxNew:new()
	local self = {}
	self = Dialog:new()
	self.CxItemCells = {}
	self.Longpress_material = nil
	self.m_LinkLabel = nil
	self.PreviewItems = {}
	self.CxProgressing = false
	self.ItemInfo = {}
	self.Material = {}
	self.CxButton = {}
	self.PreviewLevel = 1
	self.PreviewMoney = 0
	setmetatable(self, WorkshopCxNew)
	self:OnCreate()
	return self
end

function WorkshopCxNew.getInstanceOrNot()
	return _instance
end

function WorkshopCxNew.OnItemNumChange(bagid, itemkey, itembaseid)
	if _instance == nil then
		return
	end
	--[[
	if _instance.clickeditem ~= nil then
		for i = 1, #_instance.CxItemCells do
			if _instance.CxItemCells[i] == _instance.clickeditem then
				_instance:SetItemSelectedEx(i)
				break
			end
		end
	end
	]]
	local gemid = _instance.Material.Item:getID()
	LogInsane(string.format("gemid=%d, itembaseid=%d", gemid, itembaseid))
	if gemid ~= 0 and gemid == itembaseid then
		local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
		if not item then
			_instance:ResetGem()
			_instance:RefreshPreview()
		end
		_instance:UpdateMaterial()
		_instance:RefreshCanCxEffect()
		return
	end
end

function WorkshopCxNew:OnCreate()
	Dialog.OnCreate(self)
	self:InitUI()
	self:InitEvent()
	self:InitData()
end

function WorkshopCxNew:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.ItemPane = winMgr:getWindow("workshopcxnew/left")
	self.EffectWnd = winMgr:getWindow("workshopcxnew/effect")
	self.CxButton = CEGUI.Window.toPushButton(winMgr:getWindow("workshopcxnew/right/ok"))
	self.ItemInfo = {}
	local name_prefix = "workshopcxnew/right/part"
	for n = 1, 2 do
		self.ItemInfo[n] = {}
		local infopane = self.ItemInfo[n]
		infopane.Item = CEGUI.Window.toItemCell(winMgr:getWindow(name_prefix..n.."/item"..n))
		infopane.Name = winMgr:getWindow(name_prefix..n.."/name"..n)
		infopane.BaseEffects = {}
		for i= 0, 2 do
			infopane.BaseEffects[i+1] = {}
			infopane.BaseEffects[i+1].Key = winMgr:getWindow(string.format("%s%d/txt%d", name_prefix, n, i))
			infopane.BaseEffects[i+1].Value = winMgr:getWindow(string.format("%s%d/num%d", name_prefix, n, i))
			
		end
	 	infopane.Score = winMgr:getWindow(name_prefix..n.."/num3")
	 	
	 	infopane.StarArea = CEGUI.toRichEditbox(winMgr:getWindow(string.format("%s%d/level%d", name_prefix, n, n)))
	end
	self.Material.CurProgress = CEGUI.Window.toProgressBar(winMgr:getWindow("workshopcxnew/right/bot/progress"))
	
	local addbuttonwnd = winMgr:getWindow("workshopcxnew/right/bot/add")
	local reducebuttonwnd = winMgr:getWindow("workshopcxnew/right/bot/Reduction")
	self.Material.HasNumber = winMgr:getWindow("workshopcxnew/right/bot/num1")
	self.Material.MaxNumber = winMgr:getWindow("workshopcxnew/right/bot/num2")
	self.Material.Item = CEGUI.Window.toItemCell(winMgr:getWindow("workshopcxnew/right/bot/item1"))
	MHSD_UTILS.SetWindowShowtips(self.Material.Item)
	self.Material.Money = CEGUI.Window.toItemCell(winMgr:getWindow("workshopcxnew/right/bot/item2"))
	self.Material.ItemName = winMgr:getWindow("workshopcxnew/right/bot/name1")
	self.Material.MoneyName = winMgr:getWindow("workshopcxnew/right/bot/name2")
	self.Longpress_material = CLongpress2IncrWindow:AddLink(addbuttonwnd, reducebuttonwnd, self.Material.HasNumber, nil)
	self.Material.AddButton = CEGUI.Window.toPushButton(addbuttonwnd)
	self.Material.ReduceButton = CEGUI.Window.toPushButton(reducebuttonwnd)
	self.AllBtn = winMgr:getWindow("workshopcxnew/right/all")
	for i = 1, 6 do
		LogInsane("WorkshopCxNew:NewItem")
		local newItem = Workshopequipcell.new(self.ItemPane, i - 1)
		self.CxItemCells[i] = newItem
	end

	self.previewPanel = winMgr:getWindow("workshopcxnew/right/part2")
	self.blessPanel = winMgr:getWindow("workshopcxnew/right/part3")
	self.blessPanel.goBtn = winMgr:getWindow("workshopcxnew/right/part3")
	self.blessPanel:setVisible(false)
end

function WorkshopCxNew:InitEvent()
	self.Material.HasNumber:subscribeEvent("TextChanged", self.HandleMaterialNumTextChanged, self)
	self.CxButton:subscribeEvent("MouseClick", WorkshopCxNew.HandleCxBtnClicked, self)
	self.AllBtn:subscribeEvent("MouseClick", WorkshopCxNew.HandleRefineAllBtnClicked, self)
	self.blessPanel.goBtn:subscribeEvent("MouseClick", WorkshopCxNew.HandleGoBlessClicked, self)

	for i = 1, #self.CxItemCells do
		self.CxItemCells[i].Frame:subscribeEvent("MouseClick", WorkshopCxNew.HandleItemClicked,self)
	end
    self.m_hItemNumChangeNotify = GetRoleItemManager():InsertLuaItemNumChangeNotify(WorkshopCxNew.OnItemNumChange)
end

function WorkshopCxNew:HandleGoBlessClicked()
	print("WorkshopCxNew HandleGoBlessClicked")
	self:DestroyDialog()

	local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(10528)	
	GetMainCharacter():FlyOrWarkToPos(npcConfig.mapid, npcConfig.xPos, npcConfig.yPos, npcConfig.id)
end

function WorkshopCxNew:HandleRefineAllBtnClicked(e)
	if self.CxProgressing then
		return false
	end
	local ret, code	
	for i = 1, #self.CxItemCells do
		local item = GetRoleItemManager():FindItemByBagAndThisID(self.CxItemCells[i].Item:getID(), knight.gsp.item.BagTypes.EQUIP)
		if item then
			ret, code = self:CanItemCx(item)
			if ret then
				local pEffect = GetGameUIManager():AddUIEffect(self.EffectWnd, MHSD_UTILS.get_effectpath(10391), false)
			    if pEffect then
			    	local notify = CGameUImanager:createNotify(self.OnEffectEnd)
			       	pEffect:AddNotify(notify)
			    	self.CxProgressing = true
			    	return
			    end
				return
			end
		end
	end

	if code == 1 then
        -- if GetChatManager() then
        --     GetChatManager():AddTipsMsg(141487)
        -- end
        self:showQuickBuyCrystalDlg()
        return false
	elseif code == 2 then
        -- if GetChatManager() then
        --     GetChatManager():AddTipsMsg(141450)
        -- end
        self:showQuickBuyMoneyDlg()
        return false
	elseif code == 3 then
		return false
	elseif code == 4 then
		return false
	elseif code then
		local param = std.vector_std__wstring_()
		param:push_back(tostring(code))
        if GetChatManager() then
            GetChatManager():AddTipsMsg(144902, 0, param)
        end
	end
end

function WorkshopCxNew:ResetGem()
	local gemid = Gems[1].itemid
	local gemnum = 0
	for i = 1, #Gems do
		local num = GetRoleItemManager():GetItemNumByBaseID(Gems[i].itemid)
		if num ~= 0 then
			gemnum = num
			gemid = Gems[i].itemid
		--	self.Material.ItemName:setProperty("TextColours", CEGUI.PropertyHelper:uintToString(item:GetNameColour()));
			break
		end		
	end
	local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(gemid)
	self.Material.Item:setID(itemattr.id)
	self.Material.Item:SetImage(GetIconManager():GetItemIconByID(itemattr.icon))
	self.Material.ItemName:setText(itemattr.name)
end

function WorkshopCxNew:InitData()
	for i = 1, #self.CxItemCells do
		local item_local  = WorkshopHelper.ItemList[i]
		if item_local == nil then
		--	print("local item is nil index="..index)
			break
		end
		local newItem = self.CxItemCells[i]
		local roleItemManager = GetRoleItemManager()
		local bagtype = knight.gsp.item.BagTypes.EQUIP
		local item = roleItemManager:FindItemByBagIDAndPos(bagtype, item_local.type)
		if item == nil then
			newItem.Name:setText(MHSD_UTILS.get_resstring(2736)..MHSD_UTILS.get_resstring(item_local.empty_string))
			newItem.Level:setText("")
			newItem.Item:setID(0)
		else
			ShowItemInCell(item:GetBaseObject(), newItem.Item, newItem.Name)
			local equipObj = require "manager.itemmanager".getObject(bagtype, item:GetThisID())-- toEquipObject(item:GetObject())
			if equipObj then
				if equipObj.bNeedRequireself then
					GetNetConnection():send(knight.gsp.item.CItemTips(knight.gsp.item.BagTypes.EQUIP, item:GetThisID()))
					newItem.CrystalNum = math.huge
				else
					newItem.CrystalNum = equipObj.crystalnum
					newItem.CrystalProgress = equipObj.crystalprogress
					newItem.Level:setText(toStarIntroduce(newItem.CrystalNum))
					newItem.Level:setProperty("TextColours",
						MHSD_UTILS.getColourStringByNumber(item:GetNameColour()))
				end
			else
				newItem.Level:setText("")
			end
			newItem.Item:setID(item:GetThisID())
		end
		
	end
	for i = 1, #self.ItemInfo do
	 	self.ItemInfo[i].Score:setText("0")
	 	for j = 1, #self.ItemInfo[i].BaseEffects do
	 		self.ItemInfo[i].BaseEffects[j].Value:setText("0")
	 	end
	end
	self.Material.CurProgress:setProgress(0)
	self.Material.CurProgress:setText(0)
	self.Longpress_material:SetMaxNum(10)
	self.Material.MaxNumber:setText(10)
	self.Longpress_material:SetMinNum(1)
	self.Longpress_material:SetEnableClick(true)
	self.Material.MoneyName:setText(MHSD_UTILS.get_resstring(2636))
	self.Material.Money:SetImage(GetIconManager():GetItemIconByID(MoneyIconID))
	self:ResetGem()
	self.Longpress_material:SetCurNum(1)
	
	for i = 1, #self.CxItemCells do
		if self.CxItemCells[i].Item:getID() ~= 0 then
			self:SetItemSelectedEx(i)
			break
		end
	end
	self:RefreshCanCxEffect()
end

function WorkshopCxNew:SetItemSelectedEx(i)
	local curclicked = self.CxItemCells[i]
	if self.clickeditem and self.clickeditem ~= curclicked then
		self.clickeditem.Frame:setProperty("Image", "set:MainControl9 image:shopcellnormal")
	end
	if self.clickeditem ~= curclicked then
		self.clickeditem = curclicked
		self.clickeditem.Frame:setProperty("Image", "set:MainControl9 image:shopcellchoose")
	end
	self:RefreshPreview()
	self:RefreshClickedItemInfo()
	self:RefreshPreviewItemInfo()
	self:RefreshMaterial()
end

function WorkshopCxNew:RefreshClickedItemInfo()
	if self.clickeditem == nil then
		return
	end
	local itemkey = self.clickeditem.Item:getID()
	local bagid = knight.gsp.item.BagTypes.EQUIP
	local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
	local pobj = require "manager.itemmanager".getObject(bagid, itemkey)
	self:ShowItemInItemInfo(self.ItemInfo[1], item:GetBaseObject(), pobj, false)
	self.ItemInfo[1].Score:setText(GetLuaEquipScore(
		item:GetBaseObject().id, pobj, 
		math.floor(item:GetBaseObject().itemtypeid / 0x10) % 0x10))
end

function WorkshopCxNew:RefreshPreviewItemInfo()
	if self.clickeditem == nil then
		return
	end
	local itemkey = self.clickeditem.Item:getID()
	local bagid = knight.gsp.item.BagTypes.EQUIP
	local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
	local pobj = require "manager.itemmanager".getObject(bagid, itemkey)
	local previewObj = {}
	
	if item then
		for k,v in pairs(pobj) do
			previewObj[k] = v
		end
		local curcrystalnum = self.PreviewLevel
		if curcrystalnum == previewObj.crystalnum then
			local starconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(curcrystalnum + 1)
			if starconfig.id ~= -1 then
				curcrystalnum = curcrystalnum + 1
			end
		end
		previewObj.crystalnum = curcrystalnum
	end
	self:ShowItemInItemInfo(self.ItemInfo[2], item:GetBaseObject(), previewObj, true)
	self.ItemInfo[2].Score:setText(GetLuaEquipScore(
		item:GetBaseObject().id, previewObj, 
		math.floor(item:GetBaseObject().itemtypeid / 0x10) % 0x10))
	self.ItemInfo[2].Score:setProperty("TextColours", "FF33FF33")

	--check if need bless
	self:CheckGoBless()
end

function WorkshopCxNew:ShowItemInItemInfo(showinfo, attr, equipObj, preview)
	ShowItemInCell(attr, showinfo.Item, showinfo.Name)
	local i, item_local = WorkshopHelper.GetLocalItem(attr.itemtypeid)
--	local equipObj = toEquipObject(item:GetObject())
	if equipObj == nil then
		return
	end
	local crystalnum = equipObj.crystalnum
	local starconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(crystalnum)
	local j = 1
	for i=1,#item_local.BaseEffectIDs do
		if j > #showinfo.BaseEffects then
			break
		end
		local effectid = item_local.BaseEffectIDs[i]
	--	local effectval = equipObj:GetBaseEffec(effectid)
		local equip = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(attr.id)
		local effectval = 0
		for i = 0, equip.baseEffect:size() - 1 do
			if effectid == equip.baseEffectType[i] then
			 effectval=equip.baseEffect[i]
			end
		end
		if effectval ~= 0 then
			showinfo.BaseEffects[j].Key:setText(WorkshopHelper.GetAttributeName(effectid))
		--	local oldcolor = showinfo.BaseEffects[j].Value:getProperty("TextColours")
		--	showinfo.BaseEffects[j].Value:setProperty("TextColours", "FFFFFFFF")
			local uprate = 0
			if starconfig.id ~= -1 then
				uprate = starconfig.uprate
			end
			local value
			if uprate > 0 then
			--	local oldcolor = string.format("[colour='%s']", oldcolor)
				if preview then
				local newcolor = string.format("[colour='%x']", 0xFF33FF33)
				value = string.format("%s%s+%d%%",effectval, newcolor, starconfig.uprate)
				else
				value = string.format("%s+%d%%",effectval, starconfig.uprate)
				end
			else
				 value = effectval
			end
		--	LogInsane("value string="..value)
			showinfo.BaseEffects[j].Value:setText(value)
			--
			j = j + 1
		end
	end
	ShowStar(equipObj, showinfo.StarArea)
end

function WorkshopCxNew:RefreshMaterial()
	-- set material icon color
	self:UpdateMaterial()
	-- set cx progress
	self:UpdateProgress()
	-- set money color
	self:UpdateMoney()
end

function WorkshopCxNew:UpdateMaterial()
	local gemid = self.Material.Item:getID()
	local neednum = self.Longpress_material:GetCurNum()
	local hasnum = GetRoleItemManager():GetItemNumByBaseID(gemid)
	self.Material.Item:SetTextUnit(neednum)
	if hasnum >= neednum then
		self.Material.Item:SetTextUnitColor(MHSD_UTILS.get_greencolor())
	else
		self.Material.Item:SetTextUnitColor(MHSD_UTILS.get_redcolor())
	end
end

function WorkshopCxNew:UpdateProgress()
	local item = GetRoleItemManager():FindItemByBagAndThisID(self.clickeditem.Item:getID(), knight.gsp.item.BagTypes.EQUIP)
--	local equipObj = toEquipObject(item:GetObject())
	local equipObj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP, self.clickeditem.Item:getID())
	local crystalnum = equipObj.crystalnum
	local crystalprogress = equipObj.crystalprogress
	local starconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(crystalnum)
	local progress = crystalprogress / starconfig.needexp
	self.Material.CurProgress:setProgress(progress)
	self.Material.CurProgress:setText(string.format("%d/%d", crystalprogress, starconfig.needexp))
end

function WorkshopCxNew:UpdateMoney()
	local hasmoney = GetRoleItemManager():GetPackMoney()
	local needmoney = self.PreviewMoney
	print("chongxing needmoney=" .. needmoney)

	local strBuild = StringBuilder:new()
	local str = nil
	local found = false
	local ids = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyinliang"):getAllID()

    for k,v in pairs(ids) do
		local item = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyinliang"):getRecorder(v)
		if Config.CUR_3RD_LOGIN_SUFFIX == item.platformid then
			found = true
			if needmoney < item.number then
				strBuild:SetNum("parameter1",needmoney)
				str = strBuild:GetString(MHSD_UTILS.get_resstring(3064))
			else
				if item.number == 1000000 then	
	 				strBuild:SetNum("parameter1",  (math.floor(needmoney / 1e4) / 1e2))
				 else
					strBuild:SetNum("parameter1", math.ceil(needmoney/item.number))
				end
				strBuild:SetNum("parameter2",item.company)
				str = strBuild:GetString(MHSD_UTILS.get_resstring(3063))
			end
			break
		end
	end

	if not found then
		local item = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyinliang"):getRecorder(1)
		if needmoney < item.number then
			strBuild:SetNum("parameter1",needmoney)
			str = strBuild:GetString(MHSD_UTILS.get_resstring(3064))
		else
			if item.number == 1000000 then	
 				strBuild:SetNum("parameter1",  (math.floor(needmoney / 1e4) / 1e2))
			 else
				strBuild:SetNum("parameter1", math.ceil(needmoney/item.number))
			end
			strBuild:SetNum("parameter2",item.company)
			str = strBuild:GetString(MHSD_UTILS.get_resstring(3063))
		end
	end

	self.Material.Money:SetTextUnit(str)
	
	strBuild:delete()

	if hasmoney >= needmoney then
		self.Material.Money:SetTextUnitColor(MHSD_UTILS.get_greencolor())
	else
		self.Material.Money:SetTextUnitColor(MHSD_UTILS.get_redcolor())
	end
end

function WorkshopCxNew:RefreshPreview()
	if self.clickeditem == nil then
		print("nil clicked item")
		self.PreviewMoney = 0
		return
	end
	local gemid = self.Material.Item:getID()
	local neednum = self.Longpress_material:GetCurNum()
	local addprogress = neednum * GetGemUprate(gemid)
	if addprogress <= 0 then
		self.PreviewMoney = 0
		return
	end
	local item = GetRoleItemManager():FindItemByBagAndThisID(self.clickeditem.Item:getID(), 
		knight.gsp.item.BagTypes.EQUIP)
	if item == nil then
		self.PreviewMoney = 0
		return
	end
	self.PreviewMoney, self.PreviewLevel = self:GetPreviewData(item, addprogress)
end

function WorkshopCxNew:CheckGoBless()
	local item = GetRoleItemManager():FindItemByBagAndThisID(self.clickeditem.Item:getID(),	knight.gsp.item.BagTypes.EQUIP)
	local equipObj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP, item:GetThisID())

	local curcrystalnum = equipObj.crystalnum
	local curstarconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(curcrystalnum)
	if equipObj.blesslv < curstarconfig.needblesslv then
		self.previewPanel:setVisible(false)
		self.blessPanel:setVisible(true)
	else
		self.blessPanel:setVisible(false)
		self.previewPanel:setVisible(true)
	end
end

function WorkshopCxNew:GetPreviewData(item, add)
	local addprogress = add
	local equipObj = require "manager.itemmanager".getObject(
		knight.gsp.item.BagTypes.EQUIP, item:GetThisID())--toEquipObject(item:GetObject())
	local curcrystalnum = equipObj.crystalnum
	local curprogress = equipObj.crystalprogress
	local starconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(curcrystalnum)
	local money = 0
	for i=0, 999 do
		if starconfig.id == -1 then
		--	print("chong xing config unfound id="..curcrystalnum)
			break
		end
		if addprogress <= 0 then
		--	print("addprogress="..addprogress)
			break
		end
	--	print("i ="..i..",addprogress="..addprogress..", starconfig.needexp="..starconfig.needexp)
		local progressmaybe = curprogress + addprogress
		if progressmaybe >= starconfig.needexp then
			local realadd = starconfig.needexp - curprogress
			if realadd == 0 then
			--	print(string.format("may dead loop needexp=%d, curprogress=%d", starconfig.needexp, curprogress))
				break
			end
			money = money + starconfig.needmoney * realadd
			addprogress = addprogress - realadd
			curcrystalnum = curcrystalnum + 1
			starconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(curcrystalnum)
			curprogress = 0
		else
			money = money + starconfig.needmoney * addprogress
			curprogress = progressmaybe
			break
		end
	end
	if curcrystalnum > 128 then
		curcrystalnum = 128
	end
	return money, curcrystalnum
end

function WorkshopCxNew:HandleMaterialNumTextChanged(e)
	print("WorkshopCxNew:HandleMaterialNumTextChanged")
	self:RefreshPreview()
	self:UpdateMaterial()
	self:UpdateMoney()
	self:RefreshPreviewItemInfo()
	return true
end

function WorkshopCxNew:HandleItemClicked(e)
	LogInsane("WorkshopCxNew::HandleItemClicked")
	if self.CxProgressing then
		LogInsane("you are in progressing, not")
		return false
	end
	local MouseEvenArgs = CEGUI.toMouseEventArgs(e)
	for i = 1, #self.CxItemCells do
		if MouseEvenArgs.window == self.CxItemCells[i].Frame then
			if self.CxItemCells[i].Item:getID() ~= 0 then
				self:SetItemSelectedEx(i)
				return true
			else
				return false
			end
		end
	end
end

function WorkshopCxNew.IsMeetWarning()
	for i = 1, #WorkshopHelper.ItemList do
		local item_local  = WorkshopHelper.ItemList[i]
		local roleItemManager = GetRoleItemManager()
		local bagtype = knight.gsp.item.BagTypes.EQUIP
		local item = roleItemManager:FindItemByBagIDAndPos(bagtype, item_local.type)
		if item then
			for i = 1, #Gems do
				local gemid = Gems[i].itemid
				local gemnum = roleItemManager:GetItemNumByBaseID(gemid)
				if gemnum > 0 then
					local equipObj = toEquipObject(item:GetObject())
					local bNeedRequireData = item:GetObject().bNeedRequireData
					if bNeedRequireData then
						GetNetConnection():send(knight.gsp.item.CItemTips(knight.gsp.item.BagTypes.EQUIP, item:GetThisID()))
					else
						if equipObj then
							local addprogress = GetGemUprate(gemid)
							local hasmoney = GetRoleItemManager():GetPackMoney()
							local needmoney, previewlevel = WorkshopCxNew.GetPreviewData(nil, item, addprogress)
							if hasmoney >= needmoney then
								LogInsane("crystal num="..equipObj.crystalnum)
								local cxconfigCurr = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(equipObj.crystalnum)			
								local cxconfigNext = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(equipObj.crystalnum + 1)			
								if cxconfigNext.id ~= -1 then
									local itemlevel = item:GetBaseObject().level
									if itemlevel >= cxconfigNext.needequiplv and equipObj.blesslv >= cxconfigCurr.needblesslv then
										return 1
									end
								end
							end
						end
					end
				end
			end
		end
	end
	return 0
end

function WorkshopCxNew:CanItemCx(item)
	local gemid = self.Material.Item:getID()
	if gemid == 0 then
		gemid = Gems[0].itemid
	end
	local neednum = 1
	local hasnum = GetRoleItemManager():GetItemNumByBaseID(gemid)
	if hasnum < neednum then
		return false, 1
	end
	local equipObj = toEquipObject(item:GetObject())
	if equipObj == nil then
		return false
	end
	local addprogress = GetGemUprate(gemid)
	local hasmoney = GetRoleItemManager():GetPackMoney()
	local needmoney, previewlevel = self:GetPreviewData(item, addprogress)
	if hasmoney < needmoney then
		return false, 2
	end
	if equipObj.crystalnum == 128 then
		return false, 3
	end

	local cxconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(equipObj.crystalnum)
	
	local tipobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP, item:GetThisID())
	if tipobj.blesslv < cxconfig.needblesslv then
		return false, 4
	end

	cxconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(equipObj.crystalnum + 1)
	if cxconfig.id ~= -1 then
		local itemlevel = item:GetBaseObject().level
		if itemlevel < cxconfig.needequiplv then
			return false, cxconfig.needequiplv
		end
	end

	--[[
	local cxconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(previewlevel)
	if cxconfig.id == -1 then
		return false
	end
	local itemlevel = item:GetBaseObject().level
	if itemlevel < cxconfig.needequiplv then
		LogInsane(string.format("itemlevel %d not suit needlv %d", itemlevel, cxconfig.needequiplv))
		return false
	end
	--]]
	return true
end

function WorkshopCxNew:RefreshCanCxEffect()
	for i = 1, #self.CxItemCells do
		local item = GetRoleItemManager():FindItemByBagAndThisID(self.CxItemCells[i].Item:getID(), knight.gsp.item.BagTypes.EQUIP)
		local mark = self.CxItemCells[i].Mark
		if item and self:CanItemCx(item) then
			if not self.CxItemCells[i].HasEffect then
				GetGameUIManager():AddUIEffect(mark, MHSD_UTILS.get_effectpath(10376), true)
				self.CxItemCells[i].HasEffect = true
			end
		else
			if self.CxItemCells[i].HasEffect then
				GetGameUIManager():RemoveUIEffect(mark)
				self.CxItemCells[i].HasEffect = false
			end
		end
	end
end

function WorkshopCxNew.OnEffectEnd()
	if _instance == nil then
		return
	end
	local self = _instance
	local p = require "protocoldef.knight.gsp.item.crefineallequip":new()
	p.equipitemkey = self.clickeditem.Item:getID()
	require "manager.luaprotocolmanager":send(p)

	_instance.CxProgressing = false
	_instance.Material.AddButton:setMousePassThroughEnabled(false)
    _instance.Material.ReduceButton:setMousePassThroughEnabled(false)
end

function WorkshopCxNew:showQuickBuyMoneyDlg()
	local itemid = 38349
	if GetChatManager() then
		GetChatManager():AddTipsMsg(146309)
    end
	local ybnum = GetDataManager():GetYuanBaoNumber()
	if ybnum >= 600 then
		itemid = 38771
	elseif ybnum >= 100 then
		itemid = 38350
	elseif ybnum < 10 then
        return false
	end
	CGreenChannel:GetSingletonDialogAndShowIt():SetItem(itemid)
end

function WorkshopCxNew:showQuickBuyCrystalDlg()
	local itemid = 35195
	if GetChatManager() then
        GetChatManager():AddTipsMsg(146308)
    end
	local ybnum = GetDataManager():GetYuanBaoNumber()
	if ybnum >= 480 then
		itemid = 38381
	elseif ybnum < 5 then 
		return false 
	end
	CGreenChannel:GetSingletonDialogAndShowIt():SetItem(itemid)
end

function WorkshopCxNew:HandleCxBtnClicked(e)
	if self.clickeditem == nil then
		return true
	end
	if self.CxProgressing then
		return true
	end
	local gemid = self.Material.Item:getID()
	if gemid == 0 then
		gemid = Gems[0].itemid
	end
	local neednum = self.Longpress_material:GetCurNum()
	if neednum <= 0 then
		return false
	end
	local hasnum = GetRoleItemManager():GetItemNumByBaseID(gemid)
	if hasnum < neednum then
      	self:showQuickBuyCrystalDlg()
		return true
	end
	local hasmoney = GetRoleItemManager():GetPackMoney()
	local needmoney = self.PreviewMoney
	if hasmoney < needmoney then
        self:showQuickBuyMoneyDlg()
		return true
	end
	
	local item = GetRoleItemManager():FindItemByBagAndThisID(self.clickeditem.Item:getID(), knight.gsp.item.BagTypes.EQUIP)
	local equipObj = toEquipObject(item:GetObject())
	if equipObj == nil then
		return true
	end
	local cxconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(self.PreviewLevel)
	if cxconfig.id == -1 then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(141673)
        end
		return true
	end
	if equipObj.crystalnum == 128 then 
		GetGameUIManager():AddMessageTipById(146381)
		return true
	end
	if self.PreviewLevel == equipObj.crystalnum then
		cxconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(self.PreviewLevel + 1)
	end

	if cxconfig.id ~= -1 then
		local itemlevel = item:GetBaseObject().level
		if itemlevel < cxconfig.needequiplv then
			local param = std.vector_std__wstring_()
			param:push_back(tostring(cxconfig.needequiplv))
            if GetChatManager() then
                GetChatManager():AddTipsMsg(144902, 0, param)
            end
			return true
		end
	end
	local cxProtocol = knight.gsp.item.CRefineEquipNew(self.clickeditem.Item:getID(), gemid, neednum)
	GetNetConnection():send(cxProtocol)
end

function WorkshopCxNew.GetLayoutFileName()
	return "workshopcxnew.layout"
end

function WorkshopCxNew:DestroyDialog()
	if self.m_LinkLabel then
		self.m_LinkLabel:OnClose()
		self.m_LinkLabel = nil
	else
		self:OnClose()
	end
end

function WorkshopCxNew:OnClose()
	Dialog.OnClose(self)
	_instance.Longpress_material = nil
	_instance.m_LinkLabel = nil
	_instance.PreviewItems = {}
	_instance.CxProgressing = false
    GetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.m_hItemNumChangeNotify)
	_instance = nil
end
--[[function WorkshopCxNew:HandleCloseBtnClick(e)
	print("WorkshopCxNew:HandleCloseBtnClick")
	Dialog.HandleCloseBtnClick(self, e)
	
end]]--
function WorkshopCxNew:SetItemSelected(bagid, itemkey)
	if bagid == knight.gsp.item.BagTypes.EQUIP then
		for i = 1, #self.CxItemCells do
			local cxitemkey = self.CxItemCells[i].Item:getID()
			if cxitemkey ~= 0 and cxitemkey == itemkey then
				self:SetItemSelectedEx(i)
				return true
			end
		end
	end
	return false
end

function WorkshopCxNew:RefreshItemTips(item)
	for i = 1, #self.CxItemCells do
		local itemkey = self.CxItemCells[i].Item:getID()
		if itemkey ~= 0 then
			local cellitem = GetRoleItemManager():FindItemByBagAndThisID(itemkey, knight.gsp.item.BagTypes.EQUIP)
			if cellitem == item then
				ShowItemInCell(item and item:GetBaseObject() or nil, self.CxItemCells[i].Item, self.CxItemCells[i].Name)
				local equipObj = toEquipObject(item:GetObject())
				if equipObj then
					if self.CxItemCells[i].CrystalNum ~= equipObj.crystalnum or self.CxItemCells[i].CrystalProgress ~= equipObj.crystalprogress  then
						if self.CxItemCells[i].CrystalNum ~= math.huge then
							GetGameUIManager():AddUIEffect(self.ItemInfo[1].Item, MHSD_UTILS.get_effectpath(10378), false)
						end
						self.CxItemCells[i].CrystalNum = equipObj.crystalnum
						self.CxItemCells[i].CrystalProgress = equipObj.crystalprogress
					end
					local crystalnum = equipObj.crystalnum
					self.CxItemCells[i].Level:setText(toStarIntroduce(crystalnum))
					self.CxItemCells[i].Level:setProperty("TextColours",
						MHSD_UTILS.getColourStringByNumber(item:GetNameColour()))
				else
					self.CxItemCells[i].Level:setText("")
				end
				break
			end
		end
	end
	if self.clickeditem == nil then
		return
	end
	if self.clickeditem.Item:getID() == item:GetThisID() then
		for i = 1, #self.CxItemCells do
			if self.CxItemCells[i] == self.clickeditem then
				self:SetItemSelectedEx(i)
				break
			end
		end
	end
	self:RefreshCanCxEffect()
	local warninglist = CWaringlistDlg:GetSingleton()
	local pWarning = warninglist:GetWarning(5)
	if pWarning then
		pWarning:RefreshState()
	end
end
return WorkshopCxNew
