ActivityBottomItem = class("ActivityBottomItem");

function ActivityBottomItem:New()
    self = { };
    setmetatable(self, { __index = ActivityBottomItem });
    return self
end



function ActivityBottomItem:Init(gameObject, av_index)
    self.gameObject = gameObject
    self.av_index = av_index;

    self.efIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "efIcon");
    self.box = UIUtil.GetChildByName(self.gameObject, "UISprite", "box");
    self.hasGetIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "hasGetIcon");

    self.bgbt = UIUtil.GetChildByName(self.gameObject, "UIButton", "bgbt");


    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.bgbt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);


end

function ActivityBottomItem:_OnClickBtn()

    if self.canGetProduct then

        ActivityProxy.TryGetActivityAv(self.av);

    else
        -- 不能获取活跃度，那么就显示 奖励物品信息
        local product_id = ActivityDataManager.Get_activity_reward(self.av_index);
        local proInfo = ProductManager.GetProductInfoById(product_id)

        ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = proInfo, type = ProductCtrl.TYPE_FROM_OTHER });

    end

end

function ActivityBottomItem:UpInfo(id, curr_av, av)

    self.activity_id = id;

    self.av = av;
    self.hasGetIcon.gameObject:SetActive(false);
    ColorDataManager.SetGray(self.box);

    if curr_av >= av then
        self.efIcon.gameObject:SetActive(true);
        self.canGetProduct = true;
        ColorDataManager.UnSetGray(self.box);

    else
        self.efIcon.gameObject:SetActive(false);
        self.canGetProduct = false;
    end

    local hasGet = ActivityDataManager.GethasGetrr(self.activity_id, av);

    if hasGet then
        self.canGetProduct = false;
        ColorDataManager.SetGray(self.box);
        self.efIcon.gameObject:SetActive(false);
        self.hasGetIcon.gameObject:SetActive(true);
    end

end

function ActivityBottomItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

function ActivityBottomItem:Dispose()

    UIUtil.GetComponent(self.bgbt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;

    self.gameObject = nil;

    self.av_index = nil;

    self.efIcon = nil;
    self.box = nil;
    self.hasGetIcon = nil;

    self.bgbt = nil;

    self._onClickBtn = nil;

end