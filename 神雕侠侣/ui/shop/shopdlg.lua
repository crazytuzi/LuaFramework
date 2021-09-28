require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

local ShopDialog = {}
setmetatable(ShopDialog, Dialog)
ShopDialog.__index = ShopDialog

--**** fix bug for cpp call from <GreenChannel.cpp> *******
ShopcheckDlg = {}
function ShopcheckDlg.BuyRMBItemByYuanbao(p1, p2, itemid, num, p5)
  local p = require "protocoldef.knight.gsp.yuanbao.cbuyrmbitembyyuanbao".Create()
  p.npckey = 0
  p.taskid = 0
  p.itemid = itemid
  p.num = num
  p.bindyb = 0
  LuaProtocolManager.getInstance():send(p)
end
--**** fix bug for cpp call from <GreenChannel.cpp> *******

function ShopDialog.GetTimeDetails(seconds)
    seconds = seconds - GetServerTime()/1000
    if seconds <= 0 then
      return 0, 0, 0, 0
    end
    
    local days = math.floor(seconds/(3600*24))
    local leftHourSec = seconds - days*3600*24
  
    local hours = math.floor(leftHourSec/3600)
    local leftMinSec = leftHourSec - hours*3600
    
    local mins = math.floor(leftMinSec/60)
    local secs = math.floor(leftMinSec - mins*60)

    if days < 0 then
        days = 0
    end
    if hours < 0 then
        hours = 0
    end
    if mins < 0 then
        mins = 0
    end
    if secs < 0 then
        secs = 0
    end

    return days, hours, mins, secs
end

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ShopDialog.getInstance()
	LogInfo("enter get ShopDialog instance")
    if not _instance then
        _instance = ShopDialog:new()
        _instance:OnCreate()
    end
    return _instance
end

function ShopDialog.getInstanceAndShow()
	LogInfo("enter ShopDialog instance show")
    if not _instance then
        _instance = ShopDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set ShopDialog visible")
		_instance:SetVisible(true)
    end
    return _instance
end

function ShopDialog.getInstanceNotCreate()
    return _instance
end

function ShopDialog.DestroyDialog()
	if _instance then 
		if _instance.m_scriptNumber then
			GetDataManager().EventBindYuanBaoNumberChange:RemoveScriptFunctor(_instance.m_scriptNumber)
		end
		LogInfo("destroy ShopDialog")
		_instance:OnClose()
		_instance = nil
        require "ui.shop.shoplabel".DestroyDialog()
	end
end

----/////////////////////////////////////////------
function ShopDialog.GetLayoutFileName()
    return "shopdialog.layout"
end

function ShopDialog:OnCreate()
	LogInfo("ShopDialog oncreate begin")
    Dialog.OnCreate(self)

    self.m_qianghuaWnds = {}
    self.m_gongnengWnds = {}
    self.m_xianshiWnds = {}

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_main_pane = winMgr:getWindow("shop/main")
    
    --tips
    self.m_tips = CEGUI.toAnimateText(winMgr:getWindow("shop/info/main"))
    self.m_tips:setText(MHSD_UTILS.get_msgtipstring(144843))
    
    --gonggao
    self.m_pBroadText = CEGUI.toAutoScrollStaticText(winMgr:createWindow("TaharezLook/AutoScrollStaticText"))
    self.m_pBroadText:setSize(CEGUI.UVector2(CEGUI.UDim(0, 526), CEGUI.UDim(0, 30)))
    self.m_pBroadText:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 296), CEGUI.UDim(0, 48)))
    self.m_pBroadText:setProperty("BackgroundEnabled", "False")
    self.m_pBroadText:setProperty("FrameEnabled", "False")
    self.m_pBroadText:setProperty("TextColours", "FFFFE600")
    self.m_pBroadText:setMousePassThroughEnabled(true)
    self.m_pBroadText:setAlwaysOnTop(true)
    self.m_pBroadText:SetStopAtEdge(false)
    self.m_pMainFrame:addChildWindow(self.m_pBroadText)
    
    self.m_Broaditer = 0
    self.m_Broadids = std.vector_int_()
    knight.gsp.item.GetCItemShopGongGaoTableInstance():getAllID(self.m_Broadids)
    local broad = knight.gsp.item.GetCItemShopGongGaoTableInstance():getRecorder(self.m_Broadids[self.m_Broaditer])
    self.m_pBroadText:setText(broad.GongGao)
    
    --chongzhi
    self.m_btnChongzhi = CEGUI.Window.toPushButton(winMgr:getWindow("shop/buy"))
    self.m_btnChongzhi:subscribeEvent("Clicked", ShopDialog.HandleShop_buyBtnClicked, self)

    --yuanbao
    self.m_yuanbao = winMgr:getWindow("shop/txt/num1")
    self.FreshYuanbao()
    self.m_scriptNumber = GetDataManager().EventBindYuanBaoNumberChange:InsertScriptFunctor(ShopDialog.FreshYuanbao)
    
    --group buttons
    self.m_qianghuaGroupBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("shop/main/label1"))
    self.m_qianghuaGroupBtn:setID(1)
    self.m_qianghuaGroupBtn:setSelected(true)
    self.m_gongnengGroupBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("shop/main/label2"))
    self.m_gongnengGroupBtn:setID(2)
    self.m_xianshiGroupBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("shop/main/label7"))
    self.m_xianshiGroupBtn:setID(3)
    
    --left time
    self.m_lefttime = winMgr:getWindow("shop/lefttime")
    self.m_lefttime:setVisible(false)
    
    --hide not used
    winMgr:getWindow("shop/main/label7"):setVisible(false)
    winMgr:getWindow("shop/main/label8"):setVisible(false)
    
    self.m_curIndex = 1
    
    --set items
    local config = knight.gsp.item.GetCItemShopTableInstance()
    local ids = std.vector_int_()
    config:getAllID(ids)
    local qianghuaitems = {}
    local gongnengitems = {}
    for index = 0, ids:size()-1, 1 do
        local item = config:getRecorder(ids[index])
        if item.sellkind == "1" then
          table.insert(qianghuaitems, item)
        end
        if item.sellkind == "2" then
          table.insert(gongnengitems, item)
        end
    end
    
    local sortfunc = function (a,b)
      return tonumber(a.sortnum) < tonumber(b.sortnum)
    end
    
    table.sort(qianghuaitems, sortfunc)
    table.sort(gongnengitems, sortfunc)
   
    self:InsertItems(qianghuaitems, 1)
    self:InsertItems(gongnengitems, 2)
    
    self.m_qianghuaGroupBtn:subscribeEvent("SelectStateChanged", ShopDialog.HandleGroupSelectChange, self)
    self.m_gongnengGroupBtn:subscribeEvent("SelectStateChanged", ShopDialog.HandleGroupSelectChange, self)
    self.m_xianshiGroupBtn:subscribeEvent("SelectStateChanged", ShopDialog.HandleGroupSelectChange, self)
    self:GetWindow():subscribeEvent("WindowUpdate", ShopDialog.HandleWindowUpdate, self)
    
    LogInfo("ShopDialog oncreate end")
end

------------------- private: -----------------------------------
function ShopDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ShopDialog)
    return self
end

function ShopDialog:HandleShop_buyBtnClicked(args)
    ChargeDialog.GeneralReqCharge()
    return true
end

function ShopDialog.FreshYuanbao()
  if _instance ~= nil then
    local yuanbaonum = GetDataManager():GetYuanBaoNumber()
    _instance.m_yuanbao:setProperty("TextColours", MHSD_UTILS.getColourStringByNumber(GetMoneyColor(yuanbaonum)))
    _instance.m_yuanbao:setText(tostring(yuanbaonum))
  end
end

function ShopDialog:InsertItems(items, index)
  LogInfo("ShopDialog:InsertItems")
  if index == 1 then
     self.m_qianghuaWnds = {}
  end
  if index == 2 then
     self.m_gongnengWnds = {}
  end
  
  local winMgr = CEGUI.WindowManager:getSingleton()
  local configItem = knight.gsp.item.GetCItemAttrTableInstance()
  
  for i=1, #items do
    local perfix = tostring(index) .. tostring(i)
    local itemid = items[i].id
    
    local cellWnd = winMgr:loadWindowLayout("shopcelldialog.layout", perfix)
    cellWnd:setID(itemid)
    if index == 1 then
      table.insert(self.m_qianghuaWnds, cellWnd)
    end
    if index == 2 then
      table.insert(self.m_gongnengWnds, cellWnd)
      cellWnd:setVisible(false)
    end
    self.m_main_pane:addChildWindow(cellWnd)

    --set selectable
    cellWnd:subscribeEvent("MouseClick", ShopDialog.HandleProductCellClicked, self)
    
    --price
    local price = winMgr:getWindow(perfix .. "shopcell/num1")
    price:setMousePassThroughEnabled(true)
    price:setText(tostring(items[i].needyuanbao))
    
    --yuanjia
    local yuanjia = winMgr:getWindow(perfix .. "shopcell/yuanjia")
    yuanjia:setMousePassThroughEnabled(true)
    local yuanbaolabel = winMgr:getWindow(perfix .. "shopcell/num2")
    if items[i].yuanjia == 0 then
      yuanjia:setVisible(false)
    else
      yuanbaolabel:setText(tostring(items[i].yuanjia))
    end
    
    --mark
    local mark = winMgr:getWindow(perfix .. "shopcell/mark")
    mark:setMousePassThroughEnabled(true)
    if items[i].cuxiao == 0 then
        mark:setVisible(false)
    elseif items[i].cuxiao == 1 then
        mark:setProperty("Image", "set:MainControl9 image:percent")
    elseif items[i].cuxiao == 2 then
        mark:setProperty("Image", "set:MainControl9 image:Hot")
    elseif items[i].cuxiao == 3 then
        mark:setProperty("Image", "set:MainControl9 image:New")
    elseif items[i].cuxiao == 4 then
        mark:setProperty("Image", "set:MainControl9 image:Num")
    end
    
    --set name
    local namelabel = winMgr:getWindow(perfix .. "shopcell/name")
    namelabel:setText(configItem:getRecorder(itemid).name)
    namelabel:setProperty("TextColours", configItem:getRecorder(itemid).colour)
    namelabel:setMousePassThroughEnabled(true)
    
    --set item
    local item = CEGUI.toItemCell(winMgr:getWindow(perfix .. "shopcell/item"))
    item:setID(itemid)
    item:SetImage(GetIconManager():GetItemIconByID(configItem:getRecorder(itemid).icon))
    item:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
    item:subscribeEvent("TableClick", ShopDialog.HandleProductCellClicked, self)
    
    --set buy button
    local btn = CEGUI.toPushButton(winMgr:getWindow(perfix .. "shopcell/buy"))
    local price = items[i].needyuanbao
    local buyfunc = function()
      require "ui.shop.shopcheckdlg".getInstanceAndShow():SetItemInfo(itemid, price, 0, 1)
    end
    btn:subscribeEvent("Clicked", buyfunc, self)
    
    --hide not used
    winMgr:getWindow(perfix .. "shopcell/vip"):setVisible(false)
    
    --set position
    local y = math.floor((i-1)/2) * cellWnd:getSize().y.offset
    local x = 0
    if math.mod(i, 2) == 0 then
        x = 0.5
    end
    cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(x, 0), CEGUI.UDim(0, y)))
  end
end

function ShopDialog:HandleProductCellClicked(args)
  LogInfo("ShopDialog:HandleProductCellClicked")
  local mouseArgs = CEGUI.toMouseEventArgs(args)
  local itemid = mouseArgs.window:getID()
  local wnd = nil
  
  for i=1, #self.m_qianghuaWnds do
    if itemid == self.m_qianghuaWnds[i]:getID() then
      wnd = self.m_qianghuaWnds[i]
      self.m_qianghuaWnds[i]:setProperty("Image", "set:MainControl9 image:shopcellchoose")
    else
      self.m_qianghuaWnds[i]:setProperty("Image", "set:MainControl9 image:shopcellnormal")
    end
  end
  
  for i=1, #self.m_gongnengWnds do
    if itemid == self.m_gongnengWnds[i]:getID() then
      wnd = self.m_gongnengWnds[i]
      self.m_gongnengWnds[i]:setProperty("Image", "set:MainControl9 image:shopcellchoose")
    else
      self.m_gongnengWnds[i]:setProperty("Image", "set:MainControl9 image:shopcellnormal")
    end
  end
  
  for i=1, #self.m_xianshiWnds do
    if itemid == self.m_xianshiWnds[i]:getID() then
      wnd = self.m_xianshiWnds[i]
      self.m_xianshiWnds[i]:setProperty("Image", "set:MainControl9 image:shopcellchoose")
    else
      self.m_xianshiWnds[i]:setProperty("Image", "set:MainControl9 image:shopcellnormal")
    end
  end
  
  if wnd ~= nil then
    local configItem = knight.gsp.item.GetCItemAttrTableInstance()
    self.m_tips:setText(configItem:getRecorder(itemid).destribe)
  end

end

function ShopDialog:SetIndex(index)
  self.m_qianghuaGroupBtn:setSelected(false)
  self.m_gongnengGroupBtn:setSelected(false)
  self.m_xianshiGroupBtn:setSelected(false)
  
  if index == 1 then
    self.m_qianghuaGroupBtn:setSelected(true)
  elseif index == 2 then
    self.m_gongnengGroupBtn:setSelected(true)
  elseif index == 3 then
    self.m_xianshiGroupBtn:setSelected(true)
  end
  
end

function ShopDialog:ChangeIndex(index)
  if index == 3 then
    self.m_lefttime:setVisible(true)
  else
    self.m_lefttime:setVisible(false)
  end
  
  --hide all
  for i=1, #self.m_qianghuaWnds do
    self.m_qianghuaWnds[i]:setVisible(false)
  end
  for i=1, #self.m_gongnengWnds do
    self.m_gongnengWnds[i]:setVisible(false)
  end
  for i=1, #self.m_xianshiWnds do
    self.m_xianshiWnds[i]:setVisible(false)
  end
  
  if index == 1 then
    for i=1, #self.m_qianghuaWnds do
      self.m_qianghuaWnds[i]:setVisible(true)
    end
  elseif index == 2 then
    for i=1, #self.m_gongnengWnds do
      self.m_gongnengWnds[i]:setVisible(true)
    end
  elseif index == 3 then
    for i=1, #self.m_xianshiWnds do
      self.m_xianshiWnds[i]:setVisible(true)
    end
  end
end

function ShopDialog:HandleGroupSelectChange(args)
  LogInfo("ShopDialog HandleGroupSelectChange.")
  self.m_curIndex = CEGUI.toWindowEventArgs(args).window:getID()
  self:ChangeIndex(self.m_curIndex)
end

function ShopDialog:SetLimitTimeBuyData(data, lefttime)
	LogInfo("ShopDialog:SetLimitTimeBuyData")
  local winMgr = CEGUI.WindowManager:getSingleton()
  for k, v in pairs(self.m_xianshiWnds) do
    winMgr:destroyWindow(v)
    self.m_main_pane:removeChildWindow(v)
  end
	self.m_xianshiWnds = {}
	
	if data == nil then
	 return
	end
	
	local isEmpty = 0
	for k,v in pairs(data) do
	 isEmpty = 1
	 break
	end
	
	if isEmpty == 0 then
	 return
	end
	
	self.m_lefttimenum = lefttime/1000
	self.m_xianshiGroupBtn:setVisible(true)
  local winMgr = CEGUI.WindowManager:getSingleton()
  local configItem = knight.gsp.item.GetCItemAttrTableInstance()
  
  local index = 1
  for k,v in pairs(data) do
    local perfix = "3" .. tostring(k)
    local itemid = v.itemid
    
    local cellWnd = winMgr:loadWindowLayout("shopcelldialog.layout", perfix)
    cellWnd:setID(itemid)
    table.insert(self.m_xianshiWnds, cellWnd)
    cellWnd:setVisible(false)
    self.m_main_pane:addChildWindow(cellWnd)

    --set selectable
    cellWnd:subscribeEvent("MouseClick", ShopDialog.HandleProductCellClicked, self)
    
    --price
    local price = winMgr:getWindow(perfix .. "shopcell/num1")
    price:setMousePassThroughEnabled(true)
    price:setText(tostring(v.price))
    
    --yuanjia
    local yuanjia = winMgr:getWindow(perfix .. "shopcell/yuanjia")
    yuanjia:setMousePassThroughEnabled(true)
    local yuanbaolabel = winMgr:getWindow(perfix .. "shopcell/num2")
    local itemShopInfo = knight.gsp.item.GetCItemShopTableInstance():getRecorder(itemid)
    if itemShopInfo and itemShopInfo.id > 0 and itemShopInfo.needyuanbao and itemShopInfo.needyuanbao ~= v.price then
      yuanbaolabel:setText(tostring(itemShopInfo.needyuanbao))
    else
      yuanjia:setVisible(false)
    end
    
    --mark
    local mark = winMgr:getWindow(perfix .. "shopcell/mark")
    mark:setMousePassThroughEnabled(true)
    mark:setVisible(false)
    
    --set name
    local namelabel = winMgr:getWindow(perfix .. "shopcell/name")
    namelabel:setText(configItem:getRecorder(itemid).name)
    namelabel:setProperty("TextColours", configItem:getRecorder(itemid).colour)
    namelabel:setMousePassThroughEnabled(true)
    
    --set item
    local item = CEGUI.toItemCell(winMgr:getWindow(perfix .. "shopcell/item"))
    item:setID(itemid)
    item:SetImage(GetIconManager():GetItemIconByID(configItem:getRecorder(itemid).icon))
    item:SetTextUnit(v.canbuyitemnum)
    item:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
    item:subscribeEvent("TableClick", ShopDialog.HandleProductCellClicked, self)
    
    --set buy button
    local btn = CEGUI.toPushButton(winMgr:getWindow(perfix .. "shopcell/buy"))
    local price = v.price
    local buyfunc = function()
      require "ui.shop.shopcheckdlg".getInstanceAndShow():SetItemInfo(itemid, price, v.canbuyitemnum, 3)
    end
    btn:subscribeEvent("Clicked", buyfunc, self)
    if v.canbuyitemnum == 0 then
      btn:setEnabled(false)
    end
    
    --hide not used
    winMgr:getWindow(perfix .. "shopcell/vip"):setVisible(false)
    
    --set position
    local y = math.floor((index-1)/2) * cellWnd:getSize().y.offset
    local x = 0
    if math.mod(index, 2) == 0 then
        x = 0.5
    end
    cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(x, 0), CEGUI.UDim(0, y)))
    index = index + 1
  end
  
  if self.m_curIndex == 3 then
    self:SetIndex(3)
  end
  
end

function ShopDialog.LimitTimeBuy(itemid, num)   
    require "protocoldef.knight.gsp.yuanbao.cbuylimittimeitem"
    local p = CBuyLimittimeItem.Create()
    p.itemid = itemid
    p.itemnum = num
    p.flag = 3 --from shop buy
    require "manager.luaprotocolmanager":send(p)
end

function ShopDialog:HandleWindowUpdate(eventArgs)
    if self.m_pBroadText:GetTextEndTime() > 0 then
      self.m_Broaditer = self.m_Broaditer + 1
      if self.m_Broaditer >= self.m_Broadids:size() then
        self.m_Broaditer = 0
      end
      
      local broad = knight.gsp.item.GetCItemShopGongGaoTableInstance():getRecorder(self.m_Broadids[self.m_Broaditer])
      self.m_pBroadText:setText(broad.GongGao)
    end
    
    if self.m_lefttimenum == nil then
      return
    end
    
    self.m_lefttimenum = self.m_lefttimenum - CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame
    local leftSeconds = math.floor(self.m_lefttimenum)
    local days, hours, mins, secs = ShopDialog.GetTimeDetails(leftSeconds)

    local strbuilder = StringBuilder:new()  
    if days > 0  or hours > 0 or mins > 0 then
      strbuilder:SetNum("parameter1", days)
      strbuilder:SetNum("parameter2", hours)
      strbuilder:SetNum("parameter3", mins)
      self.m_lefttime:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2959)))
    elseif secs > 0 then
      strbuilder:SetNum("parameter1", secs)
      self.m_lefttime:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2960)))
    else
        self.m_lefttime:setText(MHSD_UTILS.get_resstring(2961))
    end
    strbuilder:delete()
end

return ShopDialog
