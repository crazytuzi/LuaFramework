require "ui.dialog"
require "utils.mhsdutils"


RongLianDlg = {}
setmetatable(RongLianDlg, Dialog)
RongLianDlg.__index = RongLianDlg

local _instance
function RongLianDlg.getInstance()
	print("new RongLianDlg Instance")
	if not _instance then
		_instance = RongLianDlg:new()
	end
	return _instance
end

function RongLianDlg.getInstanceOrNot()
	return _instance
end

function RongLianDlg.GetLayoutFileName()
	return "rongliandlg.layout"
end

function RongLianDlg.DestroyDialog()
	LogInfo("DestroyDialog")
	if _instance then
		_instance:OnClose()
		_instance = nil
	end
	LogInfo("DestroyDialog over")
end

function RongLianDlg:new()
	local self = {}
	self  = Dialog:new()
	self.m_iSelected = 1
	self.TAB_NUM = 4
	self.recoinNum = 0
	self.m_pItems = {}
	setmetatable(self, RongLianDlg)
	self:OnCreate()
	return self
end

function RongLianDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_pName = winMgr:getWindow("RongLianDlg/Name/name")
	self.m_pIntro = winMgr:getWindow("RongLianDialog/Back/com")
	
	self.m_pRecoin = CEGUI.Window.toPushButton(winMgr:getWindow("RongLianDialog/Back/up/btn"))
	self.m_pRecoin:subscribeEvent("Clicked", self.HandleRecoinBtn, self)
	self.m_pRecoin:setEnabled(false)

	self.m_pResult = CEGUI.Window.toItemCell(winMgr:getWindow("RongLianDialog/Back/up/out"))
	self.m_pResult:subscribeEvent("TableClick",CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
	self.m_pResult:setID(0)
	self.m_pRecoinItem = {}
	for i=1, 4 do
		self.m_pRecoinItem[i] = CEGUI.Window.toItemCell(winMgr:getWindow("RongLianDialog/Back/up/item" .. tostring(i-1)))
		self.m_pRecoinItem[i]:subscribeEvent("TableClick",self.HandleRecoinItemClicked, self)
		self.m_pRecoinItem[i]:setID(-1)
		self.m_pRecoinItem[i].num = 0
		self.m_pRecoinItem[i].id = -1
		self.m_pRecoinItem[i].tabID = 0
	end 

	for i=1, 25 do
		self.m_pItems[i] = CEGUI.Window.toItemCell(winMgr:getWindow("RongLianDlg//i" .. tostring(i)))
		self.m_pItems[i].no = i
		self.m_pItems[i].id = -1
		self.m_pItems[i]:setID(0)
		self.m_pItems[i]:subscribeEvent("TableClick",CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
		
		self.m_pItems[i]:subscribeEvent("TableDoubleClick", self.HandleItemDoubleClick, self)
	end

	self.m_pTabs = {}
	for i=1, self.TAB_NUM do 
		self.m_pTabs[i] = CEGUI.Window.toGroupButton(winMgr:getWindow("RongLianDlg/tab" .. tostring(i)))
		self.m_pTabs[i]:setID(i)
		self.m_pTabs[i]:subscribeEvent("SelectStateChanged",self.HandleTabClicked, self)
		-- self.m_pTabs[i].data = {}
		self.m_pTabs[i].items = {}
		self.m_pTabs[i].itemKinds = 0

		if i == 1 then
			self.m_pTabs[i]:setSelected(true)
		else
			self.m_pTabs[i]:setSelected(false)
		end
	end

	
	self.m_pTidy = CEGUI.Window.toPushButton(winMgr:getWindow("RongLianDlg/tidy"))
	self.m_pTidy:subscribeEvent("Clicked", self.HandleTidyBtn,self)
	-- self.m_pShop = CEGUI.Window.toPushButton(winMgr:getWindow("RongLianDlg/tidy1"))
	-- self.m_pShop:setEnabled(false)
 
	self.m_pMoney = winMgr:getWindow("RongLianDlg/Back3")
	self.m_pNeedMoney = winMgr:getWindow("RongLianDlg/cost1")

	local money = GetRoleItemManager():GetPackMoney()
	if money < 10000 then
		self.m_pMoney:setText(tostring(money),0xFFFF0000)
	else
		self.m_pMoney:setText(tostring(money))
	end

	self.m_pNeedMoney:setText(tostring(10000))
	-- self.m_pYuanBao:setText(tostring(GetDataManager():GetYuanBaoNumber()))

	self:Init()
end

function RongLianDlg:GetPackData()
	LogInfo("GetPackData begin")
	local tbl  = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cronglianpermissionitem")
	local bagtype = knight.gsp.item.BagTypes.BAG
	local capacity = GetRoleItemManager():GetBagCapacity(bagtype)
	local pagenum = 25
	local page = math.floor(capacity/pagenum)
	local num_kind = 0
	local temp = {}
	for i=1, capacity do
		local bagItem = GetRoleItemManager():FindItemByBagIDAndPos(bagtype, i-1)
		if bagItem ~= nil then
			-- print("@@ ", bagItem:GetThisID(), "  ", bagItem:GetNum(), " ",bagItem:GetBaseObject().id)
			local key = bagItem:GetBaseObject().id
			if tbl:getRecorder(key) ~= nil then
				num_kind = num_kind + 1
				local t = {}
				t.item = bagItem:GetBaseObject()
				t.num = bagItem:GetNum()
				t.id = bagItem:GetThisID()
				table.insert(temp, t)
				-- self.m_pTabs[index].itemKinds = self.m_pTabs[index].itemKinds + 1
			end
		end
	end

	table.sort(temp, function (v1, v2)
		local attr1 = v1.item 
		local attr2 = v2.item 
		return attr1.id < attr2.id
	end)

	print("num_kind: ", num_kind)

	for i=1, num_kind do
		local idx = math.ceil(i/pagenum)
		table.insert(self.m_pTabs[idx].items,i - (idx-1)*25, temp[i])
		self.m_pTabs[idx].itemKinds = self.m_pTabs[idx].itemKinds + 1
		print("TAB ",idx," : ",self.m_pTabs[idx].itemKinds)
	end

	LogInfo("GetPackData end")
end

function RongLianDlg:Init()
	-- body
	LogInfo("RongLianDlg:Init begin")

	self:GetPackData()

	self:RefreshItemData(1)

	LogInfo("RongLianDlg:Init end")
end

function RongLianDlg:RefreshItemData(tabId)
	-- body
	LogInfo("RefreshItemData begin")
	local tab = self.m_pTabs[tabId]
	local itemNum = tab.itemKinds
	local items = tab.items

	if itemNum == 0 then 
		return 
	end

	for i=1, itemNum do 
		local t = items[i].item
		local n = items[i].num
		self.m_pItems[i]:SetImage(GetIconManager():GetImageByID(t.icon))
		self.m_pItems[i]:SetTextUnit(tostring(n))  
		self.m_pItems[i]:setID(t.id)
		self.m_pItems[i].num = n
		self.m_pItems[i].id = items[i].id	
	end

	LogInfo("RefreshItemData end")
end

function RongLianDlg:CleanAllItems()
	for i=1, 25 do
		local id = self.m_pItems[i]:getID()
		if id ~= 0 then
			self.m_pItems[i]:Clear()
			self.m_pItems[i]:setID(0)
			self.m_pItems[i].num = 0
			self.m_pItems[i].id = -1
		end
	end
end

function RongLianDlg:HandleTabClicked(args)
	-- body
	self.m_iSelected = self.m_pTabs[1]:getSelectedButtonInGroup():getID()

	self:CleanAllItems()

	self:RefreshItemData(self.m_iSelected)
	
	LogInfo("RongLianDlg:HandleTabClicked end")
end

function RongLianDlg:HandleItemDoubleClick(args)
	LogInfo("RongLianDlg:HandleItemDoubleClick begin")
	
	local e = CEGUI.toWindowEventArgs(args)
	local itemWindow = CEGUI.Window.toItemCell(e.window)
	local id = itemWindow:getID()
	if id == 0 then 
		return 
	end

	local tabId = self.m_iSelected
	local num =  itemWindow.num 
	local item_id = itemWindow.id
	local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(id)

	local emptyItem = nil

	if self.m_pResult:getID() > 0 then
		self.m_pResult:Clear()
		self.m_pResult:setID(0)
	end

	if self.recoinNum > 1 then
		self.m_pRecoin:setEnabled(true)
		if self.recoinNum == 4 then
			GetGameUIManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(145945))
 			return
		end
	else
		self.m_pRecoin:setEnabled(false)
	end

	for i=1, 4 do
		if self.m_pRecoinItem[i].num == 0 then
			emptyItem = self.m_pRecoinItem[i] 
			break
		end
	end
	if emptyItem == nil then
		return
	end

	-- self:travse(self.m_pTabs[tabId].items, self.m_pTabs[tabId].itemKinds)

	table.remove(self.m_pTabs[tabId].items, itemWindow.no)

	self.m_pTabs[tabId].itemKinds = self.m_pTabs[tabId].itemKinds - 1
	-- self:travse(self.m_pTabs[tabId].items, self.m_pTabs[tabId].itemKinds)
	itemWindow:Clear()
	itemWindow:setID(0)
	itemWindow.num = 0
	itemWindow.id = -1
	-- print("AFTER REMOVE: ", itemWindow:getID())
	emptyItem:SetImage(GetIconManager():GetImageByID(item.icon))
	emptyItem:SetTextUnit(tostring(num))
	emptyItem:setID(item.id)		
	emptyItem.tabID = tabId
	emptyItem.num = num
	emptyItem.id = item_id
	self.recoinNum = self.recoinNum + 1

	if self.recoinNum > 1 then 
		self.m_pRecoin:setEnabled(true)
	end

	LogInfo("RongLianDlg:HandleItemDoubleClick end")
end

function RongLianDlg:travse(tab,num)
	local items = tab 
	print("TOTAL: ", num)
	for i=1, num do
		print("ID ", i," : ",items[i].id, "key: ", items[i].item.id, " N: ", items[i].num)
	end
end

function  RongLianDlg:HandleRecoinBtn()
	-- body
	if self.m_pResult:getID() ~= 0 then
		self.m_pResult:Clear()
		self.m_pResult:setID(0)
	end

	if GetRoleItemManager():GetPackMoney() < 10000 then
		GetGameUIManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(146120))
		return
	end

	local p = require "protocoldef.knight.gsp.item.cmeltitem":new()
	local u = require "protocoldef.rpcgen.knight.gsp.item.meltiteminfo"
	for i=1, 4 do
		if self.m_pRecoinItem[i].num > 0 then
			local t = u:new()
			t.itemkey = self.m_pRecoinItem[i].id
			t.itemnum = self.m_pRecoinItem[i].num
			table.insert(p.items, t)
		end
	end

	LuaProtocolManager.getInstance():send(p)
	
	self.recoinNum = 0
	for i=1, 4 do
		local item = self.m_pRecoinItem[i]
		if item.num > 0 then
			item.num = 0
			item.tabID = 0
			item.id = 0
			item:setID(-1)
			item:Clear()
		end
	end
	self.m_pRecoin:setEnabled(false)
	self.m_pMoney:setText(tostring(GetRoleItemManager():GetPackMoney()))

end

function RongLianDlg:HandleRecoinItemClicked(args)
	-- body
	LogInfo("RongLianDlg:HandleRecoinItemClicked begin")
	local e = CEGUI.toWindowEventArgs(args)
	local itemWindow = CEGUI.Window.toItemCell(e.window)
	if itemWindow.tabID == 0 then
		return
	end

	local tab =   self.m_iSelected 
	local num = itemWindow.num
	local id = itemWindow.id
	local key = itemWindow:getID()
	local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(key)

	itemWindow:Clear()
	itemWindow:setID(-1)
	itemWindow.num = 0
	itemWindow.id = 0
	itemWindow.tabID = 0
	self.recoinNum = self.recoinNum - 1


	if self.recoinNum < 2 then 
		self.m_pRecoin:setEnabled(false)
	else
		self.m_pRecoin:setEnabled(true)
	end

	local tabId = self.m_iSelected
	self:travse(self.m_pTabs[tabId].items, self.m_pTabs[tabId].itemKinds)

	local it = {}
	it.item = item
	it.num = num
	it.id = id

	if self.m_pTabs[tab].itemKinds < 25 then
		self.m_pTabs[tab].itemKinds = self.m_pTabs[tab].itemKinds + 1
		table.insert(self.m_pTabs[tab].items, self.m_pTabs[tab].itemKinds ,it)
	else
		for i=1,self.TAB_NUM do 
			if  self.m_pTabs[i].itemKinds < 25 then
				self.m_pTabs[i].itemKinds = self.m_pTabs[i].itemKinds + 1
				table.insert(self.m_pTabs[i].items, self.m_pTabs[i].itemKinds, it)
				break
			end
		end 
	end

	self:CleanAllItems()
	self:RefreshItemData(tab)
	LogInfo("RongLianDlg:HandleRecoinItemClicked end")
end

function RongLianDlg:FindIDByItemKey(itemkey)
	-- body
	local bagtype = knight.gsp.item.BagTypes.BAG
	local capacity = GetRoleItemManager():GetBagCapacity(bagtype)
	for i=1, capacity do
		local bagItem = GetRoleItemManager():FindItemByBagIDAndPos(bagtype, i-1)
		if bagItem ~= nil then
			if itemkey == bagItem:GetBaseObject().id then
				return bagItem:GetThisID()
			end
		end
	end
end


function RongLianDlg:IsPermitedItem(itemkey)
	-- body
	local tbl  = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cronglianpermissionitem")
	if tbl:getRecorder(itemkey) ~= nil then
		return true
	end
	return false
end

function RongLianDlg:ShowMeltResult(itemkey, itemnum)
	print("IN ShowMeltResult: ", itemkey, " ", itemnum)
	
	local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(itemkey)
	
	self.m_pResult:SetImage(GetIconManager():GetImageByID(item.icon))
	self.m_pResult:SetTextUnit(tostring(itemnum))
	self.m_pResult:setID(1)

	local money = GetRoleItemManager():GetPackMoney()
	if money < 10000 then
		self.m_pMoney:setText(tostring(money),0xFFFF0000)
	else
		self.m_pMoney:setText(tostring(money))
	end
	
	LogInfo("RongLianDlg:ShowMeltResult end")
end

function RongLianDlg:HandleTidyBtn()
	LogInfo("RongLianDlg:HandleTidyBtn begin")
	
	if self.recoinNum > 0 then
		GetGameUIManager():AddMessageTip(MHSD_UTILS.get_msgtipstring(146369))
		return
	end

	for i=1, self.TAB_NUM do
		local num = self.m_pTabs[i].itemKinds
		if num > 0 then
			print("TAB: ", i, " ", num)
			self.m_pTabs[i].itemKinds = 0	
			local items = self.m_pTabs[i].items
			for j=1, num do
				table.remove(self.m_pTabs[i].items[j])
			end
		end
	end

	self:GetPackData()

	self:CleanAllItems()
	self:RefreshItemData(self.m_iSelected)

	LogInfo("RongLianDlg:HandleTidyBtn end")
end

return RongLianDlg