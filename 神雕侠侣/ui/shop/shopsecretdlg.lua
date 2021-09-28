require "ui.dialog"
require "utils.mhsdutils"

local ShopSpecialDlg = {}
setmetatable(ShopSpecialDlg, Dialog)
ShopSpecialDlg.__index = ShopSpecialDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ShopSpecialDlg.getInstance()
  print("enter getinstance")
    if not _instance then
        _instance = ShopSpecialDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ShopSpecialDlg.getInstanceAndShow()
  print("enter instance show")
    if not _instance then
        _instance = ShopSpecialDlg:new()
        _instance:OnCreate()
  else
    print("set visible")
    _instance:SetVisible(true)
    end
    return _instance
end

function ShopSpecialDlg.getInstanceNotCreate()
    return _instance
end

function ShopSpecialDlg.DestroyDialog()
  if _instance then
    _instance:OnClose()   
    _instance = nil
    require "ui.shop.shoplabel".DestroyDialog()
  end

end

function ShopSpecialDlg.GetLayoutFileName()
    return "shopspecial.layout"
end

function ShopSpecialDlg:OnCreate()
  Dialog.OnCreate(self)
  local winMgr = CEGUI.WindowManager:getSingleton()
  
  self.refreshCountdown = winMgr:getWindow("shopspecial/count")
  self.refreshCountdown:setText("") 

  self.refresh = CEGUI.Window.toPushButton(winMgr:getWindow("shopspecial/update"))
  self.shouqi = CEGUI.Window.toPushButton(winMgr:getWindow("shopspecial/shouqi"))
  
  self.refresh:setID(1)
  self.refresh:subscribeEvent("Clicked",ShopSpecialDlg.HandleClicked,self)
  self.shouqi:setID(2)
  self.shouqi:subscribeEvent("Clicked",ShopSpecialDlg.HandleClicked,self)
  
  self.aniText = CEGUI.toAnimateText(winMgr:getWindow("shopspecial/info/main"))
  self.aniText:setText(MHSD_UTILS.get_msgtipstring(145669))

  self.feeTxt = winMgr:getWindow("shopspecial/txtinfo/num")
  self.yuanboxSpan = winMgr:getWindow("shopspecial/txtinfo")

  self.bencimianfeiSpan = winMgr:getWindow("shopspecial/free")

  self.jinricishu = winMgr:getWindow("shopspecial/cishu")
  self.jinrimianfei = winMgr:getWindow("shopspecial/mianfeicishu")

  self.mianfeiDaojish = winMgr:getWindow("shopspecial/daojishi/")
  self.mianfeiDaojish:setText("") 
  self.mianfeiDaojishSpan = winMgr:getWindow("shopspecial/daojishi")

  self.duihuanquan = winMgr:getWindow("shopspecial/duihuanjuan")
  self.duihuanquanTxt = winMgr:getWindow("shopspecial/")
  self.duihuanquan:setVisible(false)
  self.duihuanquanTxt:setVisible(false)
  
  self.huang = winMgr:getWindow("shopspecial/huang")
  self.huang:setVisible(false)
  self.huang:setAlwaysOnTop(true)
  
  self.itemcell = {}
  for i = 0,24 do 
    self.itemcell[i] = CEGUI.toItemCell(winMgr:getWindow("shopspecial/back/item" .. i))
    self.itemcell[i]:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
  end

  self.delta = 0
  self.leftFreeTime = 0
  self.leftShopUpdateTime = 0
  self.mode2 = 0
  require("manager.luaprotocolmanager"):send(require("protocoldef.knight.gsp.shenmishop.creqshenmishop"):new())
  self.shouqi:setEnabled(false)

  self:GetWindow():subscribeEvent("WindowUpdate", ShopSpecialDlg.HandleWindowUpdate, self)
    
  math.randomseed(os.time())
end

------------------- private: -----------------------------------
function ShopSpecialDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ShopSpecialDlg)
    return self
end

function ShopSpecialDlg:HandleClicked(args)
  local e = CEGUI.toWindowEventArgs(args)
  local id = e.window:getID()
  if id == 1 then
    self:tryRefresh()
  else
    if not self.items or #self.items <= 0 then 
      self.shouqi:setEnabled(false)
      GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145672),self.nullRefreshConfirm,self,self.nullRefreshReject,self)
    elseif  self.maxFreeTimes > self.freeTimes  and self.leftFreeTime and self.leftFreeTime <=0 then
      self:doShouqi(0) --charge free
    else
      self:tryShouqi()
    end
  end
end

function ShopSpecialDlg:doRefresh()
  require "manager.luaprotocolmanager":send(require("protocoldef.knight.gsp.shenmishop.cupdateshop"):new())
end

function ShopSpecialDlg:doRefreshFree()
  require "manager.luaprotocolmanager":send(require("protocoldef.knight.gsp.shenmishop.cupdateshopfree"):new())
end

function ShopSpecialDlg:doShouqi(args)
  if self.playingTick or  self.delaySetItem then
    return
  end
  if args == 1 or args == 0 then
    if args == 1 then
      local money = GetDataManager():GetYuanBaoNumber()
      if money < 50 then
        GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(145671).msg)
        return
      end
    end
    self.playingTick = 0
  end
end

function ShopSpecialDlg:ChangeHuangPosi()
  if self.itemLength > 1 then
    if not self.huang:isVisible() then
      self.huang:setVisible(true)
    end
    local pos = self.itemcell[math.random(1,self.itemLength) - 1]:getPosition()
    self.huang:setPosition(CEGUI.UVector2(CEGUI.UDim(pos.x.scale,pos.x.offset),CEGUI.UDim(pos.y.scale,pos.y.offset)))
  end
end

function ShopSpecialDlg:SendShouqi()
  require "manager.luaprotocolmanager":send(require("protocoldef.knight.gsp.shenmishop.cgetitem"):new())
end

function ShopSpecialDlg:refreshConfirm()
  self.isrefreshed = true
  self:doRefresh()
  GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function ShopSpecialDlg:shouqiConfirm()
  self.isshouqied = true
  self:doShouqi(1)--need money
  GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function ShopSpecialDlg:tryRefresh()
  if self.leftDuiHuanQuan and self.leftDuiHuanQuan > 0 then
    self:doShouqi(2)--need duihuanqian
  elseif not self.isrefreshed then
    GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145675), self.refreshConfirm,self,self.nullRefreshReject,self)--need money
  else
    self:doRefresh()--need money
  end
end

function ShopSpecialDlg:tryShouqi()
  if not self.isshouqied then
    GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145673), self.shouqiConfirm,self,self.nullRefreshReject,self)--need money
  else
    self:doShouqi(1)--need money
  end
end

function ShopSpecialDlg:run(t)
  self.delta = self.delta + t
  if self.delta >= 1000 then
    self.delta = self.delta - 1000
    if self.leftFreeTime > 1000 then
      self.leftFreeTime = self.leftFreeTime -1000
      self.mianfeiDaojish:setText(string.format("%02d:%02d:%02d",math.floor(self.leftFreeTime / 1000 / 3600 ), math.floor(self.leftFreeTime / 1000 % 3600 / 60  % 100), math.floor(self.leftFreeTime / 1000 % 3600 % 60)))
    elseif self.leftFreeTime > 0 then
      self.leftFreeTime = 0
      self.mianfeiDaojish:setText("00:00:00")
      self:shouqiCooldown()
    end
    if self.leftShopUpdateTime > 1000 then
      self.leftShopUpdateTime = self.leftShopUpdateTime - 1000
      self.refreshCountdown:setText(string.format("%02d:%02d:%02d",math.floor(self.leftShopUpdateTime / 1000 / 3600 ), math.floor(self.leftShopUpdateTime / 1000 % 3600 / 60  % 100), math.floor(self.leftShopUpdateTime / 1000 % 3600 % 60)))
    elseif self.leftShopUpdateTime > 0 then
      self.leftShopUpdateTime = 0
      self.refreshCountdown:setText("00:00:00")
      self:doRefreshFree()
    end
  end

  if self.playingTick then
    if  self.playingTick < 1500 then
      self.playingTick = self.playingTick + t
            if self.mode2%2 == 0 then
                self:ChangeHuangPosi()
            end
            self.mode2 = self.mode2 + 1
    else
            self.mode2 = 0
      self.playingTick = nil
      self.huang:setVisible(false)
      self.SendShouqi() 
    end
  end

  if  self.delaySetItem then
    if  self.delaySetItem <= 1000 then
      self.delaySetItem = self.delaySetItem + t
    else
      self.delaySetItem = nil
      self.huang:setVisible(false)
      self:setCell()
    end
  end

end

function ShopSpecialDlg:shouqiCooldown()
  self:coolingdownVisible(false)
end

function ShopSpecialDlg:yuanbaoVisible(v)
  self.feeTxt:setVisible(v)
  self.yuanboxSpan:setVisible(v)
  self.bencimianfeiSpan:setVisible(not v)
end

function ShopSpecialDlg:coolingdownVisible(v)
  self.jinricishu:setVisible(not v)
  self.jinrimianfei:setVisible(not v)

  self.mianfeiDaojish:setVisible(v)
  self.mianfeiDaojishSpan:setVisible(v)
end

function ShopSpecialDlg:process(freeTimes,maxFreeTimes,leftFreeTime,leftDuiHuanQuan,leftShopUpdateTime,items)
    self.shouqi:setEnabled(true)
  self.jinricishu:setText((maxFreeTimes - freeTimes) .. " / " .. maxFreeTimes)
  self.duihuanquanTxt:setText(leftDuiHuanQuan)
  self.leftDuiHuanQuan = leftDuiHuanQuan
  self.leftShopUpdateTime = leftShopUpdateTime
  self.maxFreeTimes = maxFreeTimes
  self.freeTimes = freeTimes
  if maxFreeTimes > freeTimes then
    self.leftFreeTime = leftFreeTime
    if leftFreeTime > 0 then
      self:yuanbaoVisible(true)
      self:coolingdownVisible(true)
    else
      self:yuanbaoVisible(false)
      self:coolingdownVisible(false)
    end
  else
    self:yuanbaoVisible(true)
    self:coolingdownVisible(false)
  end
  
  if #items <= 0 then
        GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145672),self.nullRefreshConfirm,self,self.nullRefreshReject,self)
        self.shouqi:setEnabled(false)
  else
        self.shouqi:setEnabled(true)
    end

  self.itemLength = #items
  
  local comp = function (a,b)
    return a["itemid"] < b["itemid"]  
  end

  table.sort(items,comp)

  if self.items and items and #self.items > 1 and #items > 1 and #self.items > #items  then
    for i = 1 , #self.items do
      if not items[i] or  self.items[i]["itemid"] ~= items[i]["itemid"] then
        local pos = self.itemcell[i - 1]:getPosition()
        self.huang:setPosition(CEGUI.UVector2(CEGUI.UDim(pos.x.scale,pos.x.offset),CEGUI.UDim(pos.y.scale,pos.y.offset)))
        self.delaySetItem = 0
        self.huang:setVisible(true)
        self.playSucEffect(self.items[i]["itemid"])
        break
      end 
    end
  else
    self:setCell(items)
  end
  self.items = items
end

function ShopSpecialDlg.playSucEffect(id)
  local cfg = require("utils.mhsdutils").getLuaBean("knight.gsp.item.cmysticshopitem",id)
  if not GetPlayRoseEffecstManager() then 
        CPlayRoseEffecst:NewInstance()
   end
  if cfg and cfg.level == 1 and  GetPlayRoseEffecstManager() then
     GetPlayRoseEffecstManager():PlayLevelUpEffect(10419, 0) 
  end
end

function ShopSpecialDlg:setCell(items)
  if not items then
    items = self.items
  end
  for i = 1,25 do
    if i <= #items then
      local item = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(items[i]["itemid"])
      self.itemcell[i-1]:SetImage(GetIconManager():GetImageByID(item.icon))
      self.itemcell[i-1]:setID(item.id)
      self.itemcell[i-1]:SetTextUnit(items[i]["itemcount"])
    else
      self.itemcell[i-1]:SetImage(nil)
      self.itemcell[i-1]:setID(0)
      self.itemcell[i-1]:SetTextUnit("")
    end
  end
end

function ShopSpecialDlg:nullRefreshConfirm()
  self:doRefresh()
  GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function ShopSpecialDlg:nullRefreshReject()
  self.shouqi:setEnabled(true)
  GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function ShopSpecialDlg:HandleWindowUpdate(eventArgs)
  if not self:IsVisible() then return end
  self:run(CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame * 1000)
end

return ShopSpecialDlg
