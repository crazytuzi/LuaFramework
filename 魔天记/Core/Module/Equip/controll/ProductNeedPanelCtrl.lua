require "Core.Manager.Item.EquipDataManager"

ProductNeedPanelCtrl = { };

-- 装备格子容器管理器

function ProductNeedPanelCtrl:New()
    local o = { };
    setmetatable(o, { __index = self });
    return o;
end

function ProductNeedPanelCtrl:Init(gameObject)

    self.gameObject = gameObject

    self._icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self._icon_quality = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_quality");

    self.eq_need1_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "eq_need1_txt");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

end

function ProductNeedPanelCtrl:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end 

function ProductNeedPanelCtrl:_OnClickBtn()

    if self._productInfo ~= nil then

        local spid = self._productInfo:GetSpId();
        ProductGetProxy.TryShowGetUI(spid)

    end
end


function ProductNeedPanelCtrl:SetProduct(productInfo, need_num)

    self.enough_num = true;
    self._productInfo = productInfo;
    if self._productInfo ~= nil then

        -- self._icon.mainTexture = UIUtil.GetTexture(EquipDataManager.GetItemTexturePath(self._productInfo:GetIcon_id()));
        ProductManager.SetIconSprite(self._icon, self._productInfo:GetIcon_id());

        self._icon.gameObject:SetActive(true);

        local quality = self._productInfo:GetQuality();

        -- self._icon_quality.spriteName = ProductManager.GetQulitySpriteName(quality);
        self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);
        self._icon_quality.gameObject:SetActive(true);

    else
        self._icon.gameObject:SetActive(false);
        self._icon_quality.gameObject:SetActive(false);

    end

    if productInfo ~= nil then
        local spid = productInfo:GetSpId();
        self.totalInBag = BackpackDataManager.GetProductTotalNumBySpidNotSQ(spid);

        local needAm = productInfo:GetAm();

        if needAm > self.totalInBag then
            self.eq_need1_txt.text = "[ff0000]" .. self.totalInBag  .. "/" .. needAm.. "[-]";
            self.enough_num = false;
            self.need_spid = spid;
        else
            self.eq_need1_txt.text = "[9cff94]" .. self.totalInBag .. "/" .. needAm.. "[-]";
           
        end
    else
        self:SetMaxInfo();
    end

end



function ProductNeedPanelCtrl:SetMaxInfo()
    self.eq_need1_txt.text = "-/-";
end

function ProductNeedPanelCtrl:Dispose()

    UIUtil.GetComponent(self.gameObject.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;

    self.gameObject = nil;
    self._icon = nil;
    self._icon_quality = nil;
    self.eq_need1_txt = nil;
end

