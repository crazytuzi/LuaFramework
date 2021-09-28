local Helper = require 'Zeus.Logic.Helper'
local Util   = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local ItemDetail = require "Zeus.UI.XmasterBag.ItemDetailMenu"
local AuctionModel = require 'Zeus.Model.Auction'
local ChatModel     = require 'Zeus.Model.Chat'
local ChatUtil      = require "Zeus.UI.Chat.ChatUtil"
local NumInputUI = require 'Zeus.UI.XmasterCommon.NumInputUI'

local _M = {}
_M.__index = _M

local function Close(self)
  self.menu:Close()  
end



local function initControls(view, names, tbl)
  for i = 1, #names, 1 do
    local ui = names[i]
    local ctrl = view:FindChildByEditName(ui.name, true)
    if (ctrl) then
      tbl[ui.name] = ctrl
      if (ui.click) then
        ctrl.event_PointerClick = function()
        ui.click(tbl)
      end
    end
  end
end
end


local function OnEnter(self)
  
end

local function OnExit(self)
  
  self.cvs_mid:RemoveAllChildren(true)
  self.cvs_right:RemoveAllChildren(true)
  self.cvs_left:RemoveAllChildren(true)
  if self._exitcb then 
    self._exitcb()
  end
end

local function OnDestory(self)
  
end

local function SetExitCallback(self,cb)
  self._exitcb = cb 
end

local ui_names = 
{
  {name = 'cvs_bg'},
  {name = 'cvs_left'},
  {name = 'cvs_right'},
  {name = 'cvs_mid'}
}


local function InitComponent(self,tag,param)
	
	self.menu = LuaMenuU.Create('xmds_ui/consignment/coordinate.gui.xml',tag)
  
  Util.CreateHZUICompsTable(self.menu,ui_names,self)

  self.menu:SubscribOnExit(function ()
    OnExit(self)
    end)
  self.menu:SubscribOnEnter(function ()
    OnEnter(self)
    end)
  self.menu:SubscribOnDestory(function ()
    OnDestory(self)
    end)
  self.cvs_bg.TouchClick = function()
  Close(self)
end

  
  

end

function _M.Createtest(tag, parent, buttons, callback)
  local ret = { }
  setmetatable(ret, _M)
  ret.menu = XmdsUISystem.CreateFromFile("xmds_ui/bag/miniitem_info_detailed.gui.xml")
  initControls(ret.menu, ui_names, ret)
  initMiniMaterial(ret)
  ret.cvs_information_detailed:AddChild(ret.material)
  initMiniEquipment(ret)
  ret.cvs_information_detailed:AddChild(ret.equip)
  ret.eventItemDetail = EventItemDetail.Create(3)
  if(buttons) then
    ret:setButtons(buttons,callback)
  end







if (parent) then
  parent:AddChild(ret.menu)
end
return ret
end

local function SetFee(self)
     
    local persent = GlobalHooks.DB.GetGlobalConfig('Consignment.Fee') * 0.01
    local minFee = GlobalHooks.DB.GetGlobalConfig('Consignment.MinFee')
    local price = math.max(math.floor(self.detail.static.Price * persent),minFee)
    self.lb_commission_num.Text = price
    if price <= ItemModel.GetGold() then
        self.lb_commission_num.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Default)
    else
        self.lb_commission_num.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Red)
    end
end

local function SetNum(self)
    self.ti_enter_num.Input.Text = self.auctionData.diamond
    SetFee(self)
end

local function showNumInput(self)
    local numUI = NumInputUI.Create(0)
    self.menu:AddSubMenu(numUI.menu)
    local data = ItemModel.GetLocalCompareDetail(self.detail.itemSecondType)
    if self.detail.equip ~= nil and data then
      numUI.cvs_numberbox.X = self.cvs_right.X + self.cvs_num_box.X
      numUI.cvs_numberbox.Y = self.cvs_right.Y + self.cvs_num_box.Y
    else
      numUI.cvs_numberbox.X = self.cvs_mid.X + self.cvs_num_box.X
      numUI.cvs_numberbox.Y = self.cvs_mid.Y + self.cvs_num_box.Y
    end
    numUI:SetValue(1,999999999,1,function(value)
        self.auctionData.diamond = value
        SetNum(self)
    end)
end 

local  ui_auction_names = 
{
  {name = 'lb_player_name'},
  {name = 'lb_price_num'},
  {name = 'lb_notice'},
  {name = 'ib_bg2'},
  {name = 'btn_private',click = function (self)
    
    
  end},
  {name = 'btn_buy',click = function (self)
    
    local p = {id = self.detail.id, global = 0}
    local diamond = ItemModel.GetDiamond()
    if diamond < self.auctionData.diamond then
       local tips = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PUBLICCFG, "notEnoughDiamond")
	   GameAlertManager.Instance:ShowNotify(tips)
        return
    else
      local Content = Util.GetText(TextConfig.Type.SHOP, "goumaiyuanbao",self.auctionData.diamond,self.detail.static.Name)
      local OK = Util.GetText(TextConfig.Type.SHOP, "OK")
      local Cancel = Util.GetText(TextConfig.Type.SHOP, "Cancel")
      GameAlertManager.Instance:ShowAlertDialog(
           AlertDialog.PRIORITY_NORMAL,
                Content,OK,Cancel,nil,
                function()
                       AuctionModel.RequestBuyAuctionItem(p,function ()
                      
                      end)
                           
                  EventManager.Fire("Event.UI.ConsignmentUIMain.RefreshBuy",{})
                  Close(self)  
                end ,
                nil
           )      
    end
      
  end},
  {name = 'btn_publicity',click = function (self)
    
    AuctionModel.RequestConsignmentEquipmentId({global = 0, id = self.detail.id},function (param)
      local  text = Util.GetText(TextConfig.Type.ITEM,'propaganda',ChatUtil.AddItemByData(nil,self.detail))
    
      ChatModel.chatMessageRequest(ChatModel.ChannelState.Channel_world,text, "", function (param)
        self.menu:Close()
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ITEM,'sendmessage'))
      end)
      EventManager.Fire("Event.PublistimesAdd", {index = self.detail.index})
    end)  
  end},
  {name = 'btn_not_sell',click = function (self)
    
    local content = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.ITEM, "unSubscrib")
      GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, nil, nil, nil, function() 
        AuctionModel.RequestUnSubscribItem({global = 0, id = self.detail.id},function ()
          local tips = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.ITEM, "goodsUnder")
          GameAlertManager.Instance:ShowNotify(tips)
          EventManager.Fire("Event.UI.ConsignmentUIMain.RefreshAuction",{})
          Close(self)
        end)
      end, nil)
  end},
  {name = 'btn_back',click = function (self)
    
    local content = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.ITEM, "subscribBack")
      GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, nil, nil, nil, function() 
        AuctionModel.RequestUnSubscribItem({global = 0, id = self.detail.id},function ()
          local tips = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.ITEM, "goodsBack")
          GameAlertManager.Instance:ShowNotify(tips)
          EventManager.Fire("Event.UI.ConsignmentUIMain.RefreshAuction",{})
          Close(self)
        end)
      end, nil)
  end},
  {name = 'btn_resale',click = function (self)
     local params = {
        index = 0,
        num = self.auctionData.num,
        price = self.auctionData.diamond,
        global = 0,
        isAnonymous = 0,
        id = self.detail.id
    }
    AuctionModel.RequestSubscribItem(params, function()
      EventManager.Fire("Event.UI.ConsignmentUIMain.RefreshAuction",{})
      Close(self)
    end)
  end},
  {name = 'cvs_sell'},
  {name = 'cvs_resell'},
  {name = 'btn_number',click = function (self)
        showNumInput(self)
    end},
  {name = 'ti_enter_num'},
  {name = 'lb_commission_num'},
  {name = 'cvs_num_box'},
}

local function PublistimesText(self,times)
  local freeTimes = 1
  local moneyText = ""
  local goldTimes = GlobalHooks.DB.Find("Parameters", {ParamName = "Consignment.Advertisement.goldNum"})[1].ParamValue
  local goldCost = GlobalHooks.DB.Find("Parameters", {ParamName = "Consignment.Advertisement.gold"})[1].ParamValue
  local diamondCost = GlobalHooks.DB.Find("Parameters", {ParamName = "Consignment.Advertisement.diamond"})[1].ParamValue
  if times < freeTimes then
    moneyText=Util.GetText(TextConfig.Type.SHOP, "bencifree")
  elseif times < (freeTimes + goldTimes) then
    moneyText=Util.GetText(TextConfig.Type.SHOP, "feiyong",goldCost)
  else 
    moneyText=Util.GetText(TextConfig.Type.SHOP, "youxianxiaofei",diamondCost)
    self.ib_bg2.Height = 625
  end
  return moneyText
end


local function Set(self,detail,auctionData,uitype,func)
  self.detail = detail
  self.auctionData = auctionData
  local  node
  local  lvTextNode
  local bag_data = DataMgr.Instance.UserData.RoleBag
  local vItem = bag_data:MergerTemplateItem(detail.static.Code)

  if detail.equip ~= nil then
    local data = ItemModel.GetLocalCompareDetail(detail.itemSecondType)
    local  parent = self.cvs_mid
    if data then 
      parent = self.cvs_right
      self.cvs_mid.Enable = false
      self.cvs_left.Enable = true
      self.cvs_right.Enable = true

      local compEquip = ItemDetail.CreateWithBagUI(0,self.cvs_left)
      compEquip:setEquip(data)
      compEquip.equip.Visible = true
    else
      self.cvs_mid.Enable = true
      self.cvs_left.Enable = false
      self.cvs_right.Enable = false
    end
    node = XmdsUISystem.CreateFromFile("xmds_ui/consignment/information_equip.gui.xml")
    
    self.item = ItemDetail.SetConsignmentItemUI(nil,node,{detail = detail,Num = vItem and vItem.Num or 0})
    parent:AddChild(node)

    lvTextNode =  self.item.equipCtrl.lb_level
    print("DataMgr.Instance.UserData.Pro " .. Util.GetProTxt(DataMgr.Instance.UserData.Pro))
    if Util.GetProTxt(DataMgr.Instance.UserData.Pro) ~= detail.static.Pro then
      self.item.equipCtrl.lb_profession.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Red)
    end
  else 
    node = XmdsUISystem.CreateFromFile("xmds_ui/consignment/information_material.gui.xml")
    self.cvs_mid:AddChild(node)
    self.item = ItemDetail.SetConsignmentItemUI(nil,node,{detail = detail,Num = vItem and vItem.Num or 0})

    self.cvs_mid.Enable = true
    self.cvs_left.Enable = false
    self.cvs_right.Enable = false

    self.lb_quantity_num = node:FindChildByEditName('lb_quantity_num',true)
    self.lb_quantity_num.Text = '' .. auctionData.num

    lvTextNode = self.item.materialCtrl.lb_uselevel
  end

  local self_lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
  if self_lv < detail.static.LevelReq then
    lvTextNode.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Red)
  end

  initControls(node,ui_auction_names,self)
  self.lb_player_name.Text = auctionData.name
  self.lb_player_name.FontColorRGBA = GameUtil.GetProColor(auctionData.pro)
  self.lb_price_num.Text = '' .. auctionData.diamond
  local diamond = ItemModel.GetDiamond()
  if diamond < auctionData.diamond then
    self.lb_price_num.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Red)
  end
  self.lb_notice.Visible = false
  print("uitype " .. uitype)
  if uitype == 0 then 
    self.cvs_sell.Visible = true
    self.cvs_resell.Visible = false
    self.btn_private.Visible = false
    self.btn_buy.Visible = true
    self.btn_back.Visible = false
    self.btn_publicity.Visible = false
    self.btn_not_sell.Visible = false
    self.btn_resale.Visible = false
    self.ib_bg2.Height = 582
  elseif uitype == 2 then 
    self.cvs_sell.Visible = true
    self.cvs_resell.Visible = false
    self.btn_private.Visible = false
    self.btn_buy.Visible = false
    self.btn_publicity.Visible = false
    self.btn_not_sell.Visible = false
    self.btn_back.Visible = true
    self.btn_resale.Visible = false
  elseif uitype == 3 then 
    self.cvs_sell.Visible = false
    self.cvs_resell.Visible = true
    self.btn_private.Visible = false
    self.btn_buy.Visible = false
    self.btn_publicity.Visible = false
    self.btn_not_sell.Visible = false
    self.btn_back.Visible = true
    self.btn_resale.Visible = true
    if self.detail.static.SalePrice and self.detail.static.SalePrice ~= -1 then
      self.lb_notice.Visible = true
      self.lb_notice.Text = Util.GetText(TextConfig.Type.SHOP, "changeprice",self.detail.static.SalePrice)
    end
    self.ti_enter_num.Input.characterLimit = 9
    self.ti_enter_num.Input.contentType = UnityEngine.UI.InputField.ContentType.IntegerNumber
    self.ti_enter_num.TextSprite.Anchor = TextAnchor.L_C
    self.ti_enter_num.event_endEdit = function (sender,txt)
        local num = tonumber(txt) 
        if not num or num < 1 then
            num = 1
        end

        self.item_price = num
        SetNum(self)
    end
    SetNum(self)
  else 
    self.cvs_sell.Visible = true
    self.cvs_resell.Visible = false
    self.btn_private.Visible = false
    self.btn_buy.Visible = false
    self.btn_back.Visible = false
    self.btn_publicity.Visible = true
    self.btn_not_sell.Visible = true
    self.btn_resale.Visible = false
    self.lb_notice.Visible = true
    self.lb_notice.Text=PublistimesText(self,self.detail.publishTimes)
  end

end


local function Create(tag,param)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag,param)
  return ret
end

_M.Set = Set
_M.Create = Create



return _M
