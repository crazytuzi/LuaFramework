require "Core.Module.Common.Panel"
require "Core.Module.Common.CoinBar"
require "Core.Module.Mall.View.Item.SubMallVIPPanel"
require "Core.Module.Mall.View.Item.SubMallPanel"
local MallVipPanel = require "Core.Module.Mall.View.Item.MallVipPanel"
require "Core.Module.Mall.View.Item.MallCharge"
--require "Core.Module.Mall.View.Item.MallVipInfo"
require "Core.Module.Mall.View.Item.SubGongXunCoinPanel"

MallPanel = class("MallPanel", Panel);




function MallPanel:New()
    self = { };
    setmetatable(self, { __index = MallPanel });
    self._panenIndex = 1
    return self
end


function MallPanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self._coinBar = CoinBar:New(self._trsCoinBar)
--    self._vipInfo = MallVipInfo:New(self._trsVipInfo)
    self._panels = { }
    self._panels[1] = SubMallPanel:New(self._trsMall)
    self._panels[2] = SubMallVIPPanel:New(self._trsVipMall)
    self._panels[3] = MallCharge:New(self._trsCharge)
    self._panels[4] = MallVipPanel:New(self._trsVip)
    self._panels[5] = SubGongXunCoinPanel:New(self._trsGongXunCoin)
end

function MallPanel:_Opened()
    -- self:UpdatePanel()
    --self:_UpdateVipTips()
end

function MallPanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btnMall = UIUtil.GetChildInComponents(btns, "btnMall");
    self._btnVipMall = UIUtil.GetChildInComponents(btns, "btnVipMall");
    self._btnGongXunCoin = UIUtil.GetChildInComponents(btns, "btnGongXunCoin");
    self._btnCharge = UIUtil.GetChildInComponents(btns, "btnCharge");
    self._btnVip = UIUtil.GetChildInComponents(btns, "btnVip");
    self._btnVipTips = UIUtil.GetChildByName(self._btnVip, "UISprite", "imgMsg");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self._trsMall = UIUtil.GetChildByName(self._trsContent, "Transform", "trsMall");
    self._trsVipMall = UIUtil.GetChildByName(self._trsContent, "Transform", "trsVipMall");
    self._trsCharge = UIUtil.GetChildByName(self._trsContent, "Transform", "trsCharge");
    self._trsInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsInfo");
    self._trsCoinBar = UIUtil.GetChildByName(self._trsContent, "CoinBar")
    self._trsVip = UIUtil.GetChildByName(self._trsContent, "Transform", "trsVip");
    self._trsGongXunCoin = UIUtil.GetChildByName(self._trsContent, "Transform", "trsGongXunCoin");
--    self._trsVipInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsVipInfo");

    local imgs = UIUtil.GetComponentsInChildren(self._trsInfo, "UISprite")
    self._imgIcon = UIUtil.GetChildInComponents(imgs, "icon")
    self._imgQuality = UIUtil.GetChildInComponents(imgs, "quality")
    self._imgCoinIcon1 = UIUtil.GetChildInComponents(imgs, "coinIcon1")
    self._imgCoinIcon2 = UIUtil.GetChildInComponents(imgs, "coinIcon2")

    local txts = UIUtil.GetComponentsInChildren(self._trsInfo, "UILabel")
    self._txtName = UIUtil.GetChildInComponents(txts, "name")
    self._txtType = UIUtil.GetChildInComponents(txts, "type")
    self._txtDes = UIUtil.GetChildInComponents(txts, "des")
    self._txtPrice = UIUtil.GetChildInComponents(txts, "price")
    self._txtLevel = UIUtil.GetChildInComponents(txts, "level")
    self._txtCoin = UIUtil.GetChildInComponents(txts, "myCoin")
    self._btnBuy = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnbuy");
    self._toggles = { }
    self._toggles[1] = UIUtil.GetComponent(self._btnMall, "UIToggle")
    self._toggles[2] = UIUtil.GetComponent(self._btnVipMall, "UIToggle")

    self._toggles[3] = UIUtil.GetComponent(self._btnCharge, "UIToggle")
    self._toggles[4] = UIUtil.GetComponent(self._btnVip, "UIToggle")
    self._toggles[5] = UIUtil.GetComponent(self._btnGongXunCoin, "UIToggle")

    self._goReduce = UIUtil.GetChildByName(self._trsInfo, "reduce").gameObject
    self._goAdd = UIUtil.GetChildByName(self._trsInfo, "add").gameObject
    self._inputCount = UIUtil.GetChildByName(self._trsInfo, "UILabel", "count")
end

function MallPanel:_InputCallBack()
    if ((self._inputCount.text == "") or(tonumber(self._inputCount.text) < 0)) then
        self._buyCount = 1
    else
        self._buyCount = tonumber(self._inputCount.text)
        self:_CheckBuyCount()
    end

    self:_SetBuyCount()
end

function MallPanel:_SetBuyCount()
    self._inputCount.text = tostring(self._buyCount)
    self._txtPrice.text = tostring(self._selectData.np * self._buyCount)
end

function MallPanel:_InitListener()
    self._onClickInput = function(go) self:_OnClickInput(self) end
    UIUtil.GetComponent(self._inputCount.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickInput);
    self._onClickBtnMall = function(go) self:_OnClickBtnMall(self) end
    UIUtil.GetComponent(self._btnMall, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnMall);


    self._onClickBtnGongXunCoin = function(go) self:_OnClickBtnGongXunCoin(self) end
    UIUtil.GetComponent(self._btnGongXunCoin, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGongXunCoin);


    self._onClickBtnVipMall = function(go) self:_OnClickBtnVipMall(self) end
    UIUtil.GetComponent(self._btnVipMall, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnVipMall);
    self._onClickBtnCharge = function(go) self:_OnClickBtnCharge(self) end
    UIUtil.GetComponent(self._btnCharge, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCharge);
    self._onClickBtnVip = function(go) self:_OnClickBtnVip(self) end
    UIUtil.GetComponent(self._btnVip, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnVip);
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtnbuy = function(go) self:_OnClickBtnbuy(self) end
    UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnbuy);

    self._onClickBtnAdd = function(go) self:_OnClickBtnAdd(self) end
    UIUtil.GetComponent(self._goAdd, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAdd);
    self._onClickBtnReduce = function(go) self:_OnClickBtnReduce(self) end
    UIUtil.GetComponent(self._goReduce, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReduce);
    --MessageManager.AddListener(VIPManager, VIPManager.VipChange, MallPanel._UpdateVipTips, self)
    --MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, MallPanel._UpdateVipTips, self)

    MessageManager.AddListener(PlayerManager, PlayerManager.OhterInfoChg, self.MyChange, self);

end

function MallPanel:_UpdateVipTips()
    self._btnVipTips.enabled = VIPManager.HasVipTips()
end

function MallPanel:_OnClickInput()
    local res = { };
    res.hd = MallPanel._NumberKeyHandler;
    res.confirmHandler = MallPanel._ConfirmHandler;
    res.hd_target = self;
    res.x = 445;
    res.y = 55;
    res.label = self._inputCount

    ModuleManager.SendNotification(NumInputNotes.OPEN_NUMINPUT, res);
end

function MallPanel:_ConfirmHandler(v)

    self._buyCount = tonumber(v)
    self:_CheckBuyCount()
    self:_SetBuyCount()
end

function MallPanel:_NumberKeyHandler(v)

    self._buyCount = tonumber(v)
    self:_SetBuyCount()
end

function MallPanel:_OnClickBtnAdd()

    self._buyCount = self._buyCount + 1
    self:_CheckBuyCount()
    self:_SetBuyCount()
end

function MallPanel:_OnClickBtnReduce()

    self._buyCount = self._buyCount - 1
    self:_CheckBuyCount()
    self:_SetBuyCount()
end

function MallPanel:_CheckBuyCount()
    if (self._selectData.st ~= 0) then
        if (self._buyCount > self._selectData.sn) then
            self._buyCount = self._selectData.sn
        end
    end
    local money = 0
    if (self._selectData.ri == SpecialProductId.Gold) then
        money = MoneyDataManager.Get_gold()
    elseif self._selectData.ri == SpecialProductId.BGold then
        money = MoneyDataManager.Get_bgold() + MoneyDataManager.Get_gold()
    elseif self._selectData.ri == SpecialProductId.GongXunCoin then
        money = PlayerManager.spend
    end

    if (self._selectData.np * self._buyCount > money) then
        if (self._selectData.ri == SpecialProductId.Gold) then
            MoneyDataManager.ShowGoldNotEnoughTip()
        elseif self._selectData.ri == SpecialProductId.BGold then
            MoneyDataManager.ShowBGoldNotEnoughTip()
        end
        self._buyCount = math.floor(money / self._selectData.np)
    end

    if (self._buyCount < 1) then
        self._buyCount = 1
    end


end

function MallPanel:_OnClickBtnMall()
    self:ChangePanel(1)
end

function MallPanel:_OnClickBtnVipMall()
    LogHttp.SendOperaLog("超值限购")
    self:ChangePanel(2)
    self:ResetsVIPSrollview()
end

function MallPanel:_OnClickBtnGongXunCoin()
    LogHttp.SendOperaLog("功勋商城")
    self:ChangePanel(5)
end

function MallPanel:_OnClickBtnCharge()
    LogHttp.SendOperaLog("充值")
    self:ChangePanel(3)
end
function MallPanel:_OnClickBtnVip()
    LogHttp.SendOperaLog("VIP")
    self:ChangePanel(4)
end

MallPanel.MESSAGE_MALLPANEL_CLOSE = "MESSAGE_MALLPANEL_CLOSE";

function MallPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(MallNotes.CLOSE_MALLPANEL)

    MessageManager.Dispatch(MallPanel, MallPanel.MESSAGE_MALLPANEL_CLOSE);

end

function MallPanel:_OnClickBtnbuy()
    if (tonumber(self._buyCount) > 0) then
        local buyFun = function() MallProxy.SendBuyMallItem(self._selectData.id, tonumber(self._buyCount)) end

        if self._selectData.ri == SpecialProductId.GongXunCoin then

            -- local num = self._selectData.np * self._buyCount;
            --  local pn = self._selectData.configData.name;
            buyFun();

        else
            if (self._selectData.ri == SpecialProductId.Gold) then
                MsgUtils.UseGoldConfirm(self._selectData.np * self._buyCount, nil, "common/goldBuy"
                , { num = self._selectData.np * self._buyCount, pn = self._selectData.configData.name }, buyFun, nil, nil)
            else
                MsgUtils.UseBDGoldConfirm(self._selectData.np * self._buyCount, nil, "common/bgoldBuy"
                , { num = self._selectData.np * self._buyCount, pn = self._selectData.configData.name }, buyFun, nil, nil)
            end

        end






        --  MsgUtils.UseBDGoldConfirm(cost, self, "common/goldBuy"
        --     , { num = cost, pn = na }, buyfunc, nil, nil)
        -- MallProxy.SendBuyMallItem(self._selectData.id, tonumber(self._buyCount))
    end
end

function MallPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    self._coinBar:Dispose();
    self._coinBar = nil
--    self._vipInfo:Dispose();
--    self._vipInfo = nil
    for k, v in ipairs(self._panels) do
        v:Dispose()
    end
    self._panels = nil

    MallProxy.SetMallKind(1)
    MallManager.SetCurrentSelectItemInfo(nil)
    MallManager.ResetItemDatas()

    if (self._updateNote and self._updateNote ~= "") then
        ModuleManager.SendNotification(self._updateNote)
    end
end

function MallPanel:_DisposeListener()
    UIUtil.GetComponent(self._inputCount.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickInput = nil;
    UIUtil.GetComponent(self._btnMall, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnMall = nil;
    UIUtil.GetComponent(self._btnVipMall, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnVipMall = nil;
    UIUtil.GetComponent(self._btnCharge, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnCharge = nil;
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnbuy = nil;

    UIUtil.GetComponent(self._btnGongXunCoin, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnGongXunCoin = nil;


    UIUtil.GetComponent(self._goAdd, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAdd = nil;
    UIUtil.GetComponent(self._goReduce, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnReduce = nil;

    MessageManager.RemoveListener(PlayerManager, PlayerManager.OhterInfoChg, self.MyChange, self);


    --MessageManager.RemoveListener(VIPManager, VIPManager.VipChange, MallPanel._UpdateVipTips)
    --MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, MallPanel._UpdateVipTips)
end

function MallPanel:_DisposeReference()
    self._btnMall = nil;
    self._btnVipMall = nil;
    self._btnCharge = nil;
    self._btn_close = nil;
    self._btnbuy = nil;

    self._trsMall = nil;
    self._trsVipMall = nil;
    self._trsCharge = nil;
    self._trsInfo = nil;

    self._inputCount = nil
    self._toggles = nil
end
function MallPanel:OpenPanel(to)
    self._panenIndex = to
end
function MallPanel:UpdatePanel()
    self:ChangePanel(self._panenIndex)
    self._toggles[self._panenIndex].value = true

end

function MallPanel:ChangePanel(to, otherInfo, updateNote)

    if (updateNote) then
        self._updateNote = updateNote
    end
    for i = 1, table.getCount(self._panels) do
        if i == to then
            self._panels[i]:SetEnable(true, self)
            self._toggles[i].value = true
        else
            self._panels[i]:SetEnable(false)
        end
    end
    self._trsInfo.gameObject:SetActive(to == 1 or to == 2 or to == 5)
--    self._vipInfo:SetEnable(to == 3 or to == 4)

    self._panenIndex = to
    self:UpdateMallSubPanel(otherInfo)

--    if to == 3 or to == 4 then
--        self._vipInfo:InitData()
--    end
end

function MallPanel:UpdateMallSubPanel(otherInfo)
    if (self._panels[self._panenIndex]) then
        self._panels[self._panenIndex]:UpdatePanel(otherInfo)
    end
end
function MallPanel:MyChange()

    self:UpdateSelectItemInfo()
end

function MallPanel:UpdateSelectItemInfo()
    self._selectData = MallManager.GetCurrentSelectItemInfo();
    if self._selectData == nil then
      return;
    end 
    ProductManager.SetIconSprite(self._imgIcon, self._selectData.configData.icon_id)
    self._txtName.text = self._selectData.configData.name
    self._txtName.color = ColorDataManager.GetColorByQuality(self._selectData.configData.quality)
    self._imgQuality.color = ColorDataManager.GetColorByQuality(self._selectData.configData.quality)
    self._txtDes.text = self._selectData.configData.desc
    self._txtType.text = ProductManager.GetProductKindName(self._selectData.configData["kind"], self._selectData.configData["type"])
    self._txtPrice.text = self._selectData.np;

       local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;
    if my_lv >=self._selectData.configData.req_lev then
       self._txtLevel.text = "[b2c5ff]"..tostring(self._selectData.configData.req_lev).."[-]";
    else
       self._txtLevel.text = "[ff0000]".. tostring(self._selectData.configData.req_lev).."[-]";
    end 

   

    if (self._selectData.ri == SpecialProductId.Gold) then
        self._txtCoin.text = MoneyDataManager.Get_gold() .. ""
        self._imgCoinIcon1.spriteName = "xianyu"
        self._imgCoinIcon2.spriteName = "xianyu"

    elseif self._selectData.ri == SpecialProductId.BGold then
        self._txtCoin.text = MoneyDataManager.Get_bgold() .. ""
        self._imgCoinIcon1.spriteName = "bangdingxianyu"
        self._imgCoinIcon2.spriteName = "bangdingxianyu"

    elseif self._selectData.ri == SpecialProductId.GongXunCoin then

        self._txtCoin.text = PlayerManager.spend .. ""
        self._imgCoinIcon1.spriteName = "xiuwei"
        self._imgCoinIcon2.spriteName = "xiuwei"

    end
    self._buyCount = MallManager.GetCurrentBuyCount()
    self._inputCount.text = tostring(self._buyCount)
end

function MallPanel:ResetsSrollview()
    if (self._panels[1]) then
        self._panels[1]:ResetScrollView()
    end
end


function MallPanel:ResetsVIPSrollview()
    if (self._panels[2]) then
        self._panels[2]:ResetScrollView()
    end
end
