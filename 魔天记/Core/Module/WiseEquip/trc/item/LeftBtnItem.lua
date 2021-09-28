local LeftBtnItem = class("LeftBtnItem")

function LeftBtnItem:New(transform)
    self = { };
    setmetatable(self, { __index = LeftBtnItem });
    self:Init(transform)
    return self;
end


function LeftBtnItem:Init(transform)

    self.transform = transform;

    self._select = UIUtil.GetChildByName(self.transform, "UISprite", "icon_select");
    self.icon = UIUtil.GetChildByName(self.transform, "UISprite", "icon");
    self.lockedBg = UIUtil.GetChildByName(self.transform, "UISprite", "lockedBg");
    self.icon_quality = UIUtil.GetChildByName(self.transform, "UISprite", "icon_quality");
end

function LeftBtnItem:SetSelect(v)

    self._select.gameObject:SetActive(v);

end


function LeftBtnItem:SetProduct(info)
    self._productInfo = info;

    if self._productInfo == nil then
        self.lockedBg.gameObject:SetActive(true);

        self.icon_quality.gameObject:SetActive(false);
        self.icon.gameObject:SetActive(false);

    else

        self.lockedBg.gameObject:SetActive(false);

        self.icon_quality.gameObject:SetActive(true);
        self.icon.gameObject:SetActive(true);

        local icon_id = self._productInfo:GetIcon_id();
        ProductManager.SetIconSprite(self.icon, icon_id);

        local quality = self._productInfo:GetQuality();
        self.icon_quality.color = ColorDataManager.GetColorByQuality(quality);

    end

end


function LeftBtnItem:Show()
    self.transform.gameObject:SetActive(true);
end

function LeftBtnItem:Hide()
    self.transform.gameObject:SetActive(false);
end

function LeftBtnItem:Dispose()

    self.transform = nil;

end


return LeftBtnItem;

