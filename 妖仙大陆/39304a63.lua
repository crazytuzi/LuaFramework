local _M = {}
_M.__index = _M

local Util          = require 'Zeus.Logic.Util'
local NumInputUI = require 'Zeus.UI.XmasterCommon.NumInputUI'
local ItemDetail = require "Zeus.UI.XmasterBag.ItemDetailMenu"
local ItemModel = require 'Zeus.Model.Item'
local AuctionModel = require 'Zeus.Model.Auction'

local self = {}

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


local function SetFee(self)
     
    local persent = GlobalHooks.DB.GetGlobalConfig('Consignment.Fee') * 0.01
    local minFee = GlobalHooks.DB.GetGlobalConfig('Consignment.MinFee')

    local detail =  self.item.detail
    local price = math.max(math.floor(detail.static.Price * self.item_num * persent),minFee)

    local goldNum
    if self.item.detail.equip == nil then
        goldNum = self.lb_price_num3
    else
        goldNum = self.lb_commission_num
    end

    goldNum.Text = price
    if price <= ItemModel.GetGold() then
        goldNum.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Default)
    else
        goldNum.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Red)
    end
end

local function SetNum(self,needRefresh)
    if self.item.detail.equip == nil then
        self.ti_number.Input.Text = self.item_num
        if needRefresh then
            
            
            
            
            
            
            
        end
        self.ti_enter_num1.Input.Text = self.item_price
        self.lb_price_num1.Text = self.item_num * self.item_price
    else
        self.ti_enter_num.Input.Text = self.item_price
    end
    SetFee(self)
end

local function showNumInput(self)
    local numUI = NumInputUI.Create(0)
    self.menu:AddSubMenu(numUI.menu)
    numUI.cvs_numberbox.X = self.cvs_sell.X + self.cvs_num_box.X
    numUI.cvs_numberbox.Y = self.cvs_sell.Y + self.cvs_num_box.Y

    numUI:SetValue(1,999999999,1,function(value)
        self.item_price = value
        SetNum(self,false)
    end)
end 

local function showNumInput1(self)
    local numUI = NumInputUI.Create(0)
    self.menu:AddSubMenu(numUI.menu)
    numUI.cvs_numberbox.X = self.cvs_sell.X + self.cvs_num_box.X
    numUI.cvs_numberbox.Y = self.cvs_sell.Y + self.cvs_num_box.Y

    numUI:SetValue(1,999999999,1,
    function(value)
        self.item_price = value
        SetNum(self,false)
    end,
    function(value)
        self.item_price = value
        SetNum(self,true)
    end)
end 

local function SelectItemShow(self,it)
    self.container:SetSelectItem(it,it.Num)
    self.item = it.LastItemData
    local detail = it.LastItemData.detail
    

    if self.compEquip ~= nil then
        self.compEquip = nil
        self.cvs_left:RemoveAllChildren(true)
        self.cvs_left.Visible = false
    end
    if detail.equip == nil then
        self.cvs_information_material.Visible = true
        self.cvs_information_equip.Visible = false
        self.handle_material = ItemDetail.SetConsignmentItemUI(self.handle_material,self.cvs_information_material,self.item)
    else 
        self.cvs_information_material.Visible = false
        self.cvs_information_equip.Visible = true
        self.handle_equip  = ItemDetail.SetConsignmentItemUI(self.handle_equip,self.cvs_information_equip,self.item)

        local detail = self.item.detail
        local userdata = DataMgr.Instance.UserData
        local cmpItem = userdata.RoleEquipBag:GetItemAt(detail.itemSecondType)
        if cmpItem ==nil then 
            self.btn_compare.Visible = false
        else
            self.btn_compare.Visible = true
        end
    end

    self.item_num =  1
    local lb_price1 = self.menu:FindChildByEditName("lb_price1",true)
    local ib_price3 = self.menu:FindChildByEditName("ib_price3",true)
    local lb_commission = self.menu:FindChildByEditName("lb_commission",true)
    local ib_price5 = self.menu:FindChildByEditName("ib_price5",true)
    if detail.static.SalePrice and detail.static.SalePrice ~= -1 then
        lb_price1.Y = 88 + 35
        ib_price3.Y = 88 + 35
        lb_commission.Y = 123 + 35
        ib_price5.Y =  124+ 35
        self.lb_price_num1.Y = 92 + 35
        self.lb_price_num3.Y = 125 + 35
        
        self.lb_saleconfine.Visible = true               
        self.item_price = detail.static.SalePrice
        self.default_price = self.item_price
    else
        lb_price1.Y = 88 
        ib_price3.Y = 88 
        lb_commission.Y = 123 
        ib_price5.Y =  124
        self.lb_price_num1.Y = 92 
        self.lb_price_num3.Y = 125    
        self.lb_saleconfine.Visible = false
        self.item_price = 11
        self.default_price = self.item_price
    end
    SetNum(self,true)
end

local function SelectFirstItemShow(self)
    local first_itshow = self.container:FindFirstDataItemShow()
    if first_itshow and first_itshow.LastItemData then
        SelectItemShow(self,first_itshow)
        return true
    else
        return false
  end
end

local function SubscribAuctionItem(self)
    local params = {
        index = self.item.Index,
        num = self.item_num,
        price = self.item_price * self.item_num,
        global = 0,
        isAnonymous = 0,
        id = ""
    }

    AuctionModel.RequestSubscribItem(params, function()
        self.need_refresh = true
        EventManager.Fire('Event.UI.ConsignmentUIMain.RefreshAuction',{})
        
        if params.num == self.item.Num and not SelectFirstItemShow(self) then
            Close(self)
        end
    end)
end

local MAXCOLUMN = 5


local ui_names = 
{
    {name = 'btn_close'},
    {name = 'cvs_num_box'},
    {name = 'cvs_sell'},
    {name = 'sp_invite_all'},
    {name = 'cvs_item1'},
    {name = 'tbt_gou'},
    {name = 'cvs_left'},
    
    {name = 'cvs_information_equip'},
    {name = 'btn_compare',click = function(self)
        if self.compEquip ~= nil then
            self.compEquip = nil
            self.cvs_left:RemoveAllChildren(true)
            self.cvs_left.Visible = false
        else
            local detail = self.item.detail
            local userdata = DataMgr.Instance.UserData
            local cmpItem = userdata.RoleEquipBag:GetItemAt(detail.itemSecondType)
            local cmpdetail = ItemModel.GetLocalCompareDetail(detail.itemSecondType)
            if cmpItem~= nil then
                self.compEquip = ItemDetail.CreateWithMiniXmlInside(0,self.cvs_left)
                self.compEquip:setEquip(cmpdetail)
                self.compEquip.equip.Visible = true
                self.cvs_left.Visible = true
            end
        end


    end},
    {name = 'btn_sell',click = SubscribAuctionItem},
    {name = 'ti_enter_num'},
    {name = 'btn_number',click = function (self)
        showNumInput(self)
    end},
    {name = 'lb_commission_num'},
    
    {name = 'cvs_information_material'},
    {name = 'btn_sell1',click = SubscribAuctionItem},
    {name = 'btn_less',click = function(self)
        if self.item_num > 1 then
            self.item_num = self.item_num - 1
            SetNum(self,false)
        end
    end},
    {name = 'btn_plus',click = function(self)
        if self.item_num < self.item.Num then
            self.item_num = self.item_num + 1
            SetNum(self,false)
        end

    end},
    {name = 'btn_max',click = function(self)
        self.item_num = self.item.Num
        SetNum(self,false)
    end},
    {name = 'btn_number1',click = function(self)
        showNumInput1(self)
    end},
    {name = 'ti_number'},
    {name = 'ti_enter_num1'},
    {name = 'lb_price_num1'},
    {name = 'lb_price_num3'},
    {name = 'lb_saleconfine'},
}


local function BagInit(self)
  self.container = HZItemsContainer.New()
  self.container.CellSize = HZItemShow.SelectSizeToBodySize(self.cvs_item1.Size2D) 
    self.container.IsShowLockUnlock = true

  self.container:OpenSelectMode(false,false,nil,function (con,it)
    if not it.LastItemData then return end

    if not it.IsSelected then
      SelectItemShow(self,it)
    end
  end)

    local rolebag = DataMgr.Instance.UserData.RoleBag
    self.container.ItemPack = rolebag
    self.container:AddItemShowInitHandle('itshow',function (con,it)
        if it.LastItemData then
            Util.ItemshowExt(it,it.LastItemData.detail,it.LastItemData.IsEquip)
        end
    end)
    local s = self.cvs_item1.Size2D

    local max_rows = math.floor(rolebag.MaxLimitSize / MAXCOLUMN)
    if rolebag.MaxLimitSize % MAXCOLUMN ~= 0 then
        max_rows = max_rows + 1
    end

    local function OnUpdate(gx,gy,node)

        node.Visible = true
        self.container:SetItemShowParent(node, gy * MAXCOLUMN + gx + 1)
    end

  if self.sp_invite_all.Rows <= 0 then
    local cellW = self.sp_invite_all.Width / MAXCOLUMN
    self.sp_invite_all:Initialize(cellW, s.y, max_rows, MAXCOLUMN, self.cvs_item1, OnUpdate,function() end)
  else
    self.sp_invite_all.Rows = max_rows
  end
  
end

function _M.Notify(status,userdata,self)
    
    
    
    
    
    
end


local function OnEnter()
    self.need_refresh = nil
    DataMgr.Instance.UserData:AttachLuaObserver(self.menu.Tag,self)
    self.Notify(UserData.NotiFyStatus.ALL, DataMgr.Instance.UserData,self)

    self.tbt_gou.IsChecked = false
    local filter = ItemPack.FilterInfo.New()
    filter.CheckHandle = function (it)
        return it.detail.canAuction == 1
    end
    self.container.Filter = filter

    self.item_num =  1
    self.item_price = 1
      
    if not SelectFirstItemShow(self) then
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ITEM,'noAutionItem'))
        Close(self)
    end

end

local function OnExit()
    self.container.Filter = nil
    DataMgr.Instance.UserData:DetachLuaObserver(self.menu.Tag)
    if self.need_refresh then
      EventManager.Fire('Event.UI.ConsignmentUIMain.RefreshBuy',{})
    end
end

local function InitComponent(tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/consignment/sell.gui.xml',tag)

    initControls(self.menu, ui_names, self)
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)

    self.menu:SubscribOnDestory(function()
        self = nil
    end)

    self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
        	self.menu:Close()
    	end
    end
    
    self.minPricePer = 0.01 * tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "Consignment.Advertisement.minPercent"})[1].ParamValue)
    self.maxPricePer = 0.01 * tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "Consignment.Advertisement.maxPercent"})[1].ParamValue)

    BagInit(self)

    self.ti_number.Input.characterLimit = 9
    self.ti_number.Input.contentType = UnityEngine.UI.InputField.ContentType.IntegerNumber
    self.ti_number.TextSprite.Anchor = TextAnchor.L_C
    self.ti_number.event_endEdit = function (sender,txt)
        local num = tonumber(txt) 
        if not num or num < 1 then
            num = 1
        elseif num > self.item.Num then
            num = self.item.Num
        end

        self.item_num = num
        SetNum(self,false)
    end

    self.ti_enter_num1.Input.characterLimit = 9
    self.ti_enter_num1.Input.contentType = UnityEngine.UI.InputField.ContentType.IntegerNumber
    self.ti_enter_num1.TextSprite.Anchor = TextAnchor.L_C
    self.ti_enter_num1.event_endEdit = function (sender,txt)
        local num = tonumber(txt) 
        if not num or num < 1 then
            num = 1
        end

        self.item_price = num
        SetNum(self,true)
    end

    self.ti_enter_num.Input.characterLimit = 9
    self.ti_enter_num.TextSprite.Anchor = TextAnchor.L_C
    self.ti_enter_num.Input.contentType = UnityEngine.UI.InputField.ContentType.IntegerNumber
    self.ti_enter_num.event_endEdit = function (sender,txt)
        local num = tonumber(txt) 
        if not num or num < 1 then
            num = 1
        end

        self.item_price = num
        SetNum(self,false)
    end
    self.cvs_left.Enable = false
    self.cvs_num_box.Visible = false

    return self.menu
end


local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(tag, params)
    return self
end

return {Create = Create}
