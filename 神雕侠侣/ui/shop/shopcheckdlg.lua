require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

local ShopCheckDialog = {}
setmetatable(ShopCheckDialog, Dialog)
ShopCheckDialog.__index = ShopCheckDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ShopCheckDialog.getInstance()
	LogInfo("enter get ShopCheckDialog instance")
    if not _instance then
        _instance = ShopCheckDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ShopCheckDialog.getInstanceAndShow()
	LogInfo("enter ShopCheckDialog instance show")
    if not _instance then
        _instance = ShopCheckDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set ShopCheckDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ShopCheckDialog.getInstanceNotCreate()
    return _instance
end

function ShopCheckDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy ShopCheckDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------

function ShopCheckDialog.GetLayoutFileName()
    return "shopcheck.layout"
end

function ShopCheckDialog:OnCreate()
	LogInfo("ShopCheckDialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_item = CEGUI.toItemCell(winMgr:getWindow("shopcheck/item"))
    self.m_name = winMgr:getWindow("shopcheck/name")
    self.m_info = winMgr:getWindow("shopcheck/info")
    self.m_price = winMgr:getWindow("shopcheck/num")
    self.m_count = winMgr:getWindow("shopcheck/num1")
    self.m_countprice = winMgr:getWindow("shopcheck/num2")
    
    self.m_btnok = CEGUI.toPushButton(winMgr:getWindow("shopcheck/ok"))
    self.m_btncancel = CEGUI.toPushButton(winMgr:getWindow("shopcheck/cancel"))
    self.m_btnadd = CEGUI.toPushButton(winMgr:getWindow("shopcheck/more"))
    self.m_btnadd10 = CEGUI.toPushButton(winMgr:getWindow("shopcheck/more10"))
    self.m_btnless = CEGUI.toPushButton(winMgr:getWindow("shopcheck/less"))
    
    self.m_btnok:subscribeEvent("Clicked", ShopCheckDialog.ButtonClickOK, self)
    self.m_btncancel:subscribeEvent("Clicked", ShopCheckDialog.DestroyDialog, self)
    self.m_btnadd:subscribeEvent("Clicked", ShopCheckDialog.ButtonClickAdd, self)
    self.m_btnadd10:subscribeEvent("Clicked", ShopCheckDialog.ButtonClickAdd10, self)
    self.m_btnless:subscribeEvent("Clicked", ShopCheckDialog.ButtonClickLess, self)
    
    self.m_pLink = CLongpress2IncrWindow:AddLink(self.m_btnadd, self.m_btnless, self.m_count, nil)
   
    self.m_count:subscribeEvent("TextChanged", ShopCheckDialog.CountNumberChanged, self)
    
    LogInfo("ShopCheckDialog oncreate end")
end

------------------- private: -----------------------------------
function ShopCheckDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ShopCheckDialog)
    return self
end

function ShopCheckDialog:CountNumberChanged()
  local countprice = tonumber(self.m_count:getText()) * tonumber(self.m_price:getText())
  self.m_countprice:setText(tostring(countprice))
  self:SetCountPriceColor()
end

function ShopCheckDialog:SetCountPriceColor()
  local colorReg = MHSD_UTILS.get_whitecolor()
  if GetDataManager():GetYuanBaoNumber() < tonumber(self.m_countprice:getText()) then
    colorReg = MHSD_UTILS.get_redcolor()
  else
    colorReg = MHSD_UTILS.get_greencolor()
  end
  self.m_countprice:setProperty("TextColours", CEGUI.PropertyHelper:colourToString(colorReg))
  
  if self.m_typenum ~= 1 then
    if tonumber(self.m_count:getText()) == self.m_totalnum then
      colorReg = MHSD_UTILS.get_yellowcolor()
      self.m_count:setProperty("TextColours", CEGUI.PropertyHelper:colourToString(colorReg))
    else
      colorReg = MHSD_UTILS.get_whitecolor()
      self.m_count:setProperty("TextColours", CEGUI.PropertyHelper:colourToString(colorReg))
    end
  end
end

function ShopCheckDialog:SetItemInfo(itemid, price, totalnum, type)
  self.m_itemidnum = itemid
  self.m_pricenum = price
  self.m_totalnum = totalnum
  self.m_typenum = type --1 for common shop buy, 2 for limit buy1, 3 for limit buy2
  
  local buynumber = GetDataManager():GetYuanBaoNumber()/price
  self.m_pLink:SetMaxNum(buynumber)
  
  if self.m_totalnum > 0 and self.m_totalnum < buynumber then
    self.m_pLink:SetMaxNum(self.m_totalnum)
  end
  
  local configItem = knight.gsp.item.GetCItemAttrTableInstance()
  self.m_item:setID(itemid)
  self.m_item:SetImage(GetIconManager():GetItemIconByID(configItem:getRecorder(itemid).icon))
  self.m_item:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
  
  self.m_name:setText(configItem:getRecorder(itemid).name)
  self.m_info:setText(configItem:getRecorder(itemid).name)
  self.m_price:setText(tostring(price))
  self.m_count:setText("1")
  self.m_countprice:setText(tostring(price))
  
  self:SetCountPriceColor()
end

function ShopCheckDialog:ButtonClickOK(args)
  if GetDataManager():GetYuanBaoNumber() < tonumber(self.m_countprice:getText()) then
    ChargeDialog.GeneralReqCharge()
    self.DestroyDialog()
    return
  end
  
  if tonumber(self.m_count:getText()) <= 0 then
    self.DestroyDialog()
    return
  end
  
  --common shop buy
  if self.m_typenum == 1 then
    local p = require "protocoldef.knight.gsp.yuanbao.cbuyrmbitembyyuanbao".Create()
    p.npckey = 0
    p.taskid = 0
    p.itemid = self.m_itemidnum
    p.num = tonumber(self.m_count:getText())
    p.bindyb = 0
    LuaProtocolManager.getInstance():send(p)
  end
  
  --limit buy1
  if self.m_typenum == 2 then
    require "ui.binfengift.binfengiftdlg".LimitTimeBuy(self.m_itemidnum, tonumber(self.m_count:getText()))
  end
  
  --limit buy2
  if self.m_typenum == 3 then
    require "ui.shop.shopdlg".LimitTimeBuy(self.m_itemidnum, tonumber(self.m_count:getText()))
  end
  
  self.DestroyDialog()
end

function ShopCheckDialog:ButtonClickAdd(args)
  if tonumber(self.m_count:getText()) == self.m_totalnum and self.m_typenum ~= 1 then
    return
  end
  
  local curcount = tonumber(self.m_count:getText()) + 1
  self.m_count:setText(tostring(curcount))
  
  self:SetCountPriceColor()
end

function ShopCheckDialog:ButtonClickAdd10(args)
  local curcount = tonumber(self.m_count:getText()) + 10
  local countprice = curcount * tonumber(self.m_price:getText())
  
  if curcount > self.m_totalnum  and self.m_typenum ~= 1  then
    curcount = self.m_totalnum
    countprice = curcount * tonumber(self.m_price:getText())
  end
  
  --find proper count
  local myyuanbao = GetDataManager():GetYuanBaoNumber()

  if myyuanbao < countprice then
    local price = tonumber(self.m_price:getText())
    for i=0, curcount do
      if i*price > myyuanbao then
        curcount = i - 1
        break
      end
    end
    countprice = curcount * price
  end
  
  self.m_count:setText(tostring(curcount))
  
  self:SetCountPriceColor()
end

function ShopCheckDialog:ButtonClickLess(args)
  if tonumber(self.m_count:getText()) <= 0 then
    return
  end

  local curcount = tonumber(self.m_count:getText()) - 1
  self.m_count:setText(tostring(curcount))
  
  self:SetCountPriceColor()
end

return ShopCheckDialog
