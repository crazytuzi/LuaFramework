require "Core.Module.Common.UIItem"


ChuangGuanAwardItem = class("ChuangGuanAwardItem", UIItem);

function ChuangGuanAwardItem:New()
    self = { };
    setmetatable(self, { __index = ChuangGuanAwardItem });
    return self
end
 

function ChuangGuanAwardItem:UpdateItem(data)
    self.data = data
end

function ChuangGuanAwardItem:Init(gameObject, data)

    self.gameObject = gameObject;

    self.ceng_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "ceng_txt");
    self.cannotGetTip_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "cannotGetTip_txt");

    self.hasGetIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "hasGetIcon");


    self.awardBt = UIUtil.GetChildByName(self.gameObject, "UIButton", "awardBt");

    self.products = { };
    self.productCtrs = { };

    for i = 1, 3 do
        self.products[i] = UIUtil.GetChildByName(self.gameObject, "Transform", "product" .. i);
        self.productCtrs[i] = ProductCtrl:New();
        self.productCtrs[i]:Init(self.products[i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true)

         self.productCtrs[i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);

    end


    self._onClickawardBt = function(go) self:_OnClickawardBt(self) end
    UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickawardBt);


    self.awardBt.gameObject:SetActive(false);
    self.hasGetIcon.gameObject:SetActive(false);

    self:SetData(data);

end

function ChuangGuanAwardItem:_OnClickawardBt()
    XLTInstanceProxy.TryGetChuangGuanAward(self.data.id)
end


function ChuangGuanAwardItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

function ChuangGuanAwardItem:SetLogData(l)

    local len = table.getn(l);
    for i = 1, len do
        local obj = l[i];
        if (self.data.id + 0) ==(obj.id + 0) then
            -- flag
            local flag = obj.flag;
            if flag == 1 then
                self.cannotGetTip_txt.gameObject:SetActive(false);
                self.awardBt.gameObject:SetActive(false);
                self.hasGetIcon.gameObject:SetActive(true);
            end
        end

    end

end

function ChuangGuanAwardItem:SetData(data)

    self.data = data;



    local ceng = data.ceng;
    local first_pass_reward = data.first_pass_reward;
    local t_num = table.getn(first_pass_reward);

    self.ceng_txt.text = LanguageMgr.Get("XLTInstance/ChuangGuanAwardItem/label1", { n = ceng });
    local kind = PlayerManager.GetPlayerKind()
    local n = 1
    for i = 1, t_num do
        local dstr = first_pass_reward[i];
        local drop_arr = string.split(dstr, "_");
        --Warning(tostring(tonumber(drop_arr[1]) == kind) .. "__" .. drop_arr[1])
        if tonumber(drop_arr[1]) == kind then
            local products = ProductInfo:New();
            products:Init( { spId = drop_arr[2] + 0, am = drop_arr[3] + 0 });
            self.productCtrs[n]:SetData(products);
            n = n + 1
        end
--        local products = ProductInfo:New();
--        products:Init( { spId = drop_arr[1] + 0, am = drop_arr[2] + 0 });
--        self.productCtrs[i]:SetData(products);
    end


    -- 这需要判断  是否可以领取
    if self.data.id <= FBMLTItem.hasPassMaxFb_id then

        -- 应 到达 可以 奖励 的情况
        self.cannotGetTip_txt.gameObject:SetActive(false);
        self.awardBt.gameObject:SetActive(true);
    end

end


function ChuangGuanAwardItem:_Dispose()
    self.gameObject = nil;

    UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RemoveDelegate("OnClick");

    for i = 1, 3 do
        self.productCtrs[i]:Dispose()
        self.productCtrs[i] = nil;
        self.products[i] = nil;
    end

    self._onClickawardBt = nil;


    self.gameObject = nil;

    self.ceng_txt = nil;
    self.cannotGetTip_txt = nil;

    self.hasGetIcon = nil;


    self.awardBt = nil;

    self.products = { };
    self.productCtrs = { };



end