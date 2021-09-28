require "Core.Manager.Item.EquipDataManager"



SelectEquipPanelCtrl = { };

-- 装备格子容器管理器

function SelectEquipPanelCtrl:New()
    local o = { };
    setmetatable(o, { __index = self });
    return o;
end

function SelectEquipPanelCtrl:Init(gameObject, index, use_circle)
    self.use_circle = use_circle;
    self.gameObject = gameObject
    self._lockedBg = UIUtil.GetChildByName(self.gameObject, "lockedBg").gameObject;
    self._icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self._icon_quality = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_quality");
    self._numLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "numLabel");
    self._icon_select = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_select");

    self._starIcon = UIUtil.GetChildByName(self.gameObject, "Transform", "starIcon");

    self.kind = index;




    self:SetLock(false);
    self:Selected(false);

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);
    -- self:SetOnClickBtnHandler(nil);

end

function SelectEquipPanelCtrl:SetOnClickBtnHandler(handler)

    self._selectHandler = handler;

end

function SelectEquipPanelCtrl:Selected(v)
    self._icon_select.gameObject:SetActive(v);
end

function SelectEquipPanelCtrl:SetLock(v)
    self.lock = v;
    self._lockedBg:SetActive(v);
end

--[[
--sexp= [0]
--rlv= [0]
--idx= [3]
--slv= [0]
]]
function SelectEquipPanelCtrl:SetData(equip_lv_data)
    self.equip_lv_data = equip_lv_data;

    --  需要获取装备栏里的 对应装备
    local k = self.equip_lv_data.idx - 1;
    local productInfo = EquipDataManager.GetProductByIdx(k);


    self:SetProduct(productInfo);

end

function SelectEquipPanelCtrl:SetProduct(productInfo)

    self._productInfo = productInfo;
    if self._productInfo ~= nil then

        ProductManager.SetIconSprite(self._icon, self._productInfo:GetIcon_id());
        self._icon.gameObject:SetActive(true);

        local am = self._productInfo:GetAm();
        if am > 1 then
            self._numLabel.text = am .. "";
        else
            self._numLabel.text = "";
        end


        local quality = self._productInfo:GetQuality();

        --[[
        if self.use_circle then
        -- self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);
        else
        -- self._icon_quality.spriteName = ProductManager.GetQulitySpriteName(quality);
        end
        ]]
        self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);


        self._icon_quality.gameObject:SetActive(true);

        self:SetLock(false);

        if self._starIcon ~= nil then
            self:UpdateStar();
            self._starIcon.gameObject:SetActive(true);
        end

    else
        self._icon.gameObject:SetActive(false);
        self._numLabel.text = "";
        self._icon_quality.gameObject:SetActive(false);

        self:SetLock(true);

        if self._starIcon ~= nil then
            self._starIcon.gameObject:SetActive(false);
        end

    end

end

function SelectEquipPanelCtrl:UpdateStar()


    local star = self._productInfo:GetStar();

    local icons = { };

    for i = 1, 5 do
        icons[i] = UIUtil.GetChildByName(self._starIcon, "UISprite", "star" .. i);
        icons[i].spriteName = "star2";

        if i <= star then
            icons[i].spriteName = "star3";
            icons[i].gameObject:SetActive(true);
        end

        if star > 5 then
            local ti = star - 5;
            if ti >= i then
                icons[i].spriteName = "star1";
                icons[i].gameObject:SetActive(true);
            end
        end
    end


end

function SelectEquipPanelCtrl:_OnClickBtn()


    if self._selectHandler ~= nil then
        self._selectHandler(self);
    end

end

function SelectEquipPanelCtrl:TryShowEffect()

    if self.effectCtr == nil then
        self.effectCtr = UIEffect:New();
        self.effectCtr:Init(self.gameObject.transform, self._icon, 5, "ui_refining_2");
    end
    self.effectCtr:Play(1);

end


function SelectEquipPanelCtrl:Dispose()

    if self._onClickBtn ~= nil then

        UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
        self._onClickBtn = nil;
    end

    if self.effectCtr then
        self.effectCtr:Dispose();
        self.effectCtr = nil
    end

    self._selectHandler = nil;

    self.use_circle = nil;
    self.gameObject = nil;
    self._lockedBg = nil;
    self._icon = nil;
    self._icon_quality = nil;
    self._numLabel = nil;
    self._icon_select = nil;

    self._starIcon = nil;


end