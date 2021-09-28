require "Core.Module.TShop.View.ProductSelectCtrl"

require "Core.Module.NumInput.NumInputModule"

ShopRightPanelCtr = class("ShopRightPanelCtr");

function ShopRightPanelCtr:New()
    self = { };
    setmetatable(self, { __index = ShopRightPanelCtr });
    return self
end


function ShopRightPanelCtr:Init(gameObject)
    self.gameObject = gameObject;

    self.btnduihuan = UIUtil.GetChildByName(self.gameObject, "UIButton", "btnduihuan");

    self.btn_add = UIUtil.GetChildByName(self.gameObject, "UIButton", "btn_add");
    self.btn_sub = UIUtil.GetChildByName(self.gameObject, "UIButton", "btn_sub");

    self.selectProduct = UIUtil.GetChildByName(self.gameObject, "Transform", "selectProduct");
    self.momeyPanel1 = UIUtil.GetChildByName(self.gameObject, "Transform", "momeyPanel1");
    self.momeyPanel2 = UIUtil.GetChildByName(self.gameObject, "Transform", "momeyPanel2");
    self.txtnumIpnut = UIUtil.GetChildByName(self.gameObject, "Transform", "txtnumIpnut");
    self.txtnumIpnutLabel = UIUtil.GetChildByName(self.txtnumIpnut, "UILabel", "Label");

    self.momeyPanel2_btn_add = UIUtil.GetChildByName(self.momeyPanel2, "UIButton", "btn_add");

    self.txtmsg = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtmsg");

    self.selectProductCtr = ProductSelectCtrl:New();
    self.selectProductCtr:Init(self.selectProduct);

    MessageManager.AddListener(ShopProItem, ShopProItem.MESSAGE_PRODUCT_SELECT, ShopRightPanelCtr.ProductSelect, self);

     self._onClickmomeyPanel2_btn_add = function(go) self:_OnClickmomeyPanel2_btn_add(self) end
    UIUtil.GetComponent(self.momeyPanel2_btn_add, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickmomeyPanel2_btn_add);

    self._onClickbtn_add = function(go) self:_OnClickbtn_add(self) end
    UIUtil.GetComponent(self.btn_add, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtn_add);

    self._onClickbtn_sub = function(go) self:_OnClickbtn_sub(self) end
    UIUtil.GetComponent(self.btn_sub, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtn_sub);

    self._onClickbtnduihuan = function(go) self:_OnClickbtnduihuan(self) end
    UIUtil.GetComponent(self.btnduihuan, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtnduihuan);

    self._onClicktxtnumIpnut = function(go) self:_OnClicktxtnumIpnut(self) end
    UIUtil.GetComponent(self.txtnumIpnut, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClicktxtnumIpnut);

    self.txtmsg.gameObject:SetActive(false);
    self.txtnumIpnutLabel.text = "1";

  
    MessageManager.AddListener(PlayerManager, PlayerManager.OhterInfoChg, ShopRightPanelCtr.MoneyChange, self);
end

function ShopRightPanelCtr:_OnClicktxtnumIpnut()

    local res = { };
    res.hd = ShopRightPanelCtr.NumberKeyHandler;
    res.confirmHandler = ShopRightPanelCtr._ConfirmHandler;

    res.hd_target = self;
    res.x = 370;
    res.y = 0;
    res.label = self.txtnumIpnutLabel
    ModuleManager.SendNotification(NumInputNotes.OPEN_NUMINPUT, res);
end


function ShopRightPanelCtr:NumberKeyHandler(v)


    local res = v.."";

    self.txtnumIpnutLabel.text = res;
    self:UpPrices();
end

function ShopRightPanelCtr:_ConfirmHandler(v)

   if v == "0" then
     v = "1";
   end

    self.curr_v = v;
    local b = self:CheckCanBuy(self.curr_v);


    if not b.eb then
        self.curr_v = b.v;
    end

    
    self.txtnumIpnutLabel.text = "" .. self.curr_v;
    self:UpPrices();

end


function ShopRightPanelCtr:_OnClickmomeyPanel2_btn_add()
  
   ModuleManager.SendNotification(MallNotes.SHOW_MONEY_GET_PANEL)
end

function ShopRightPanelCtr:_OnClickbtn_add()

    self.curr_v = self.txtnumIpnutLabel.text + 1;

    local b = self:CheckCanBuy(self.curr_v);

    if b.eb then
        if self.curr_v <= self.else_num then
            self.txtnumIpnutLabel.text = "" .. self.curr_v;
        end

        self:UpPrices();
    end

end

function ShopRightPanelCtr:_OnClickbtn_sub()

    self.curr_v = self.txtnumIpnutLabel.text - 1;

    local b = self:CheckCanBuy(self.curr_v);

    if self.curr_v > 0 then
        self.txtnumIpnutLabel.text = "" .. self.curr_v;
    end
    self:UpPrices();

end

function ShopRightPanelCtr:UpPrices()

    local total_ltxtvalue1 = UIUtil.GetChildByName(self.momeyPanel1, "UILabel", "ltxtvalue");
    local mIcon1 = UIUtil.GetChildByName(self.momeyPanel1, "UISprite", "micon");

    local total_ltxtvalue2 = UIUtil.GetChildByName(self.momeyPanel2, "UILabel", "ltxtvalue");
    local mIcon2 = UIUtil.GetChildByName(self.momeyPanel2, "UISprite", "micon");

    local tstr = self.txtnumIpnutLabel.text;

    if tstr == "" then
        tstr = "1";
    end

    local price = self.currInfo.price;
    local num = tstr + 0;
    local tprice = num * price;
    total_ltxtvalue1.text = "" .. tprice;


    local my_num = ShopDataManager.GetMyThings(TShopPanel.curr_type);
    total_ltxtvalue2.text = "" .. my_num;

    mIcon1.spriteName = TShopNotes.Icons[TShopPanel.curr_type];
    mIcon2.spriteName = TShopNotes.Icons[TShopPanel.curr_type];

end


function ShopRightPanelCtr:CheckCanBuy(num, needSetNum)

    local res = { };


    if self.else_num <= 0 then
        local procf = ProductManager.GetProductById(self.currInfo.product_id);
        MsgUtils.ShowTips("tshop/ShopRightPanelCtr/tip_3", { n = procf.name });
        res.eb = false;
        res.v = 1;
        return res;
    end

    ------------------------------------------------------------------------------------------------

    local condition = ShopDataManager.CheckChange(TShopPanel.curr_type, self.currInfo.product_id);

    if condition.tip ~= nil then
        MsgUtils.ShowTips(nil, nil, nil, condition.tip);
        res.eb = false;
        res.v = 1;
        return res;
    end

    -------------------------------------------------------------------------------------------------

    num = num + 0;

    local price = self.currInfo.price;
    local tprice = num * price;

    local my_num = ShopDataManager.GetMyThings(TShopPanel.curr_type);

   
    if my_num < tprice then
        local dcf = ProductManager.GetProductById(self.req_item);
        -- 金钱不足
        MsgUtils.ShowTips("tshop/ShopRightPanelCtr/tip_2", { n = dcf.name });

        -- 需要设置 可以购买 上限

        res.eb = false;
        res.v = math.floor(my_num / price);
       
        if res.v < 1 then
            res.v = 1;
        end
        self.curr_v=res.v;

        --------------------------------------------------------------------------------------------------
        if self.else_num < num then
            -- 兑换数量不足
            MsgUtils.ShowTips("tshop/ShopRightPanelCtr/tip_4");

            -- 需要设置 可以购买 上限
           
            res.eb = false;
            res.v = self.else_num;

            if res.v > self.curr_v then
               res.v = self.curr_v;
            end

            return res;
        end

        ------------------------------------------------------------------------------------------


        return res;

    end

    ----------------------------------------------------------------
    if self.else_num < num then
        -- 兑换数量不足
        MsgUtils.ShowTips("tshop/ShopRightPanelCtr/tip_4");

        -- 需要设置 可以购买 上限
        
        res.eb = false;
        res.v = self.else_num;

        if res.v < 1 then
        res.v = 1;
        end
        return res;
    end

    -------------------------------------------------------------

    res.eb = true;
    res.v = 1;
    return res;
end

--[[
主界面暂时提交了一版. 大家的入口如果没有了的话
先暂时用MainUIPanel:_OnKeyCode快捷键作系统入口.
如果配置正式入口的.找策划尚文在系统按钮开放表里面配置入口信息.
然后在MainUISystemPanel:OnItemClick 里对应的id写发送的事件即可.
]]


function ShopRightPanelCtr:_OnClickbtnduihuan()

    local num = self.txtnumIpnutLabel.text + 0;

    if num > 0 then
        TShopProxy.TryExchange(self.currInfo.id, self.currInfo.product_id, num);
    else
        MsgUtils.ShowTips("tshop/ShopRightPanelCtr/tip_1");
    end


end


function ShopRightPanelCtr:UpProductSelect()
   
   if self.currInfo ~= nil then
     self:ProductSelect(self.currInfo)
   end
end


function ShopRightPanelCtr:ProductSelect(info)

    self.currInfo = info;
    self.req_item = self.currInfo.req_item;

    self.else_num = self.currInfo.num;
    local hasbuyInfo = ShopDataManager.GetHasBuyProduct(info.id, info.product_id);
    if hasbuyInfo ~= nil then
        self.else_num = self.else_num - hasbuyInfo.t;
    end


    self.txtnumIpnutLabel.text = "1";
    self.selectProductCtr:SetInfo(info)

    self:UpPrices();
end

function ShopRightPanelCtr:MoneyChange()
     
     if self.currInfo ~= nil then
      self:UpPrices()
     end
    
    
end




function ShopRightPanelCtr:Dispose()
    MessageManager.RemoveListener(ShopProItem, ShopProItem.MESSAGE_PRODUCT_SELECT, ShopRightPanelCtr.ProductSelect);

    self._onClickbtn_add = nil;
    UIUtil.GetComponent(self.btn_add, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self._onClickbtn_sub = nil;
    UIUtil.GetComponent(self.btn_sub, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self._onClickbtnduihuan = nil;
    UIUtil.GetComponent(self.btnduihuan, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self._onClicktxtnumIpnut = nil;
    UIUtil.GetComponent(self.txtnumIpnut, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self._onClickmomeyPanel2_btn_add = nil;
    UIUtil.GetComponent(self.momeyPanel2_btn_add, "LuaUIEventListener"):RemoveDelegate("OnClick");


  
    MessageManager.RemoveListener(PlayerManager, PlayerManager.OhterInfoChg, ShopRightPanelCtr.MoneyChange)



     self.gameObject = nil;

    self.btnduihuan = nil;

    self.btn_add = nil;
    self.btn_sub = nil;

    self.selectProduct = nil;
    self.momeyPanel1 = nil;
    self.momeyPanel2 = nil;
    self.txtnumIpnut = nil;
    self.txtnumIpnutLabel = nil;

    self.txtmsg = nil;

    self.selectProductCtr:Dispose()
    self.selectProductCtr=nil;

    


end