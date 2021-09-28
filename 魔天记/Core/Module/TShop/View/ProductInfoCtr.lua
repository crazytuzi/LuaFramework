ProductInfoCtr = class("ProductInfoCtr");

function ProductInfoCtr:New()
    self = { };
    setmetatable(self, { __index = ProductInfoCtr });
    return self;
end

function ProductInfoCtr:Init(transform, data)
    self.transform = transform;
    self.data = data;

    self.icon = UIUtil.GetChildByName(self.transform, "UISprite", "icon");
    self.quality = UIUtil.GetChildByName(self.transform, "UISprite", "quality");
    self.mIcon = UIUtil.GetChildByName(self.transform, "UISprite", "mIcon");
    self.lockedBg = UIUtil.GetChildByName(self.transform, "UISprite", "lockedBg");
    self.selectIcon = UIUtil.GetChildByName(self.transform, "UISprite", "selectIcon");

    self.nametxt = UIUtil.GetChildByName(self.transform, "UILabel", "nametxt");
    self.duihuanElseTimetxt = UIUtil.GetChildByName(self.transform, "UILabel", "duihuanElseTimetxt");
    self.priceTxt = UIUtil.GetChildByName(self.transform, "UILabel", "priceTxt");

    self.lockedBg.gameObject:SetActive(false);
    self.selectIcon.gameObject:SetActive(false);

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.transform.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);


end

function ProductInfoCtr:SetClickHandler(hd, target)

    self.clickHd = hd;
    self.clickHdTarget = target;

end

function ProductInfoCtr:_OnClickBtn()

    if self.clickHd ~= nil then
        self.clickHd(self.clickHdTarget, self);
    end

end

function ProductInfoCtr:SetSelect(v)
    self.selectIcon.gameObject:SetActive(v);
end

function ProductInfoCtr:SetData(info)

    self.curr_info = info;

    self.transform.gameObject:SetActive(false);

    if info ~= nil then

        local procf = ProductManager.GetProductById(info.product_id);

        local quality = procf.quality;
        local icon_id = procf.icon_id;


        ProductManager.SetIconSprite(self.icon, icon_id);
       -- self.quality.spriteName = ProductManager.GetQulitySpriteName(quality);
        self.quality.color = ColorDataManager.GetColorByQuality(quality);

        local elseT = info.num;
        local price = info.price;

        local hasbuyInfo = ShopDataManager.GetHasBuyProduct(info.id, info.product_id);
        if hasbuyInfo ~= nil then
            elseT = elseT - hasbuyInfo.t;
        end


        if elseT >= 0 then
            self.duihuanElseTimetxt.text = LanguageMgr.Get("tshop/ProductInfoCtr/elseTime") .. elseT;

        end

        local condition = ShopDataManager.CheckChange(TShopPanel.curr_type, info.product_id);

        if condition.rank_condition ~= nil then
            self.duihuanElseTimetxt.text = condition.rank_condition;
            self.lockedBg.gameObject:SetActive(true);
        elseif condition.lev_condition ~= nil then
            self.duihuanElseTimetxt.text = condition.lev_condition;
            self.lockedBg.gameObject:SetActive(true);

        elseif elseT <= 0 then
            -- 已经卖完
            self.duihuanElseTimetxt.text = LanguageMgr.Get("tshop/ShopDataManager/tip_nsell");
        end


        self.nametxt.text = procf.name;
        self.priceTxt.text = "" .. price;

        self.mIcon.spriteName = TShopNotes.Icons[TShopPanel.curr_type];

        self.transform.gameObject:SetActive(true);
    end

end




function ProductInfoCtr:Dispose()
    UIUtil.GetComponent(self.transform.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");


     self.transform = nil;
    self.data = nil;

    self.icon = nil;
    self.quality = nil;
    self.mIcon = nil;
    self.lockedBg = nil;
    self.selectIcon = nil;

    self.nametxt = nil;
    self.duihuanElseTimetxt = nil;
    self.priceTxt = nil;

end
