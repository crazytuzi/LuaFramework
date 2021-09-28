require "Core.Manager.Item.EquipDataManager"
local EquipQualityEffect = require "Core.Module.Common.EquipQualityEffect"

EquipPanelCtrl = { };

-- 装备格子容器管理器

function EquipPanelCtrl:New()
    local o = { };
    setmetatable(o, { __index = self });
    return o;
end

function EquipPanelCtrl:Init(gameObject, index, ext_data)

    self.gameObject = gameObject
    self.ext_data = ext_data;

     self._eqQualityspecEffect = EquipQualityEffect:New();

    self._lockedBg = UIUtil.GetChildByName(self.gameObject, "UISprite", "lockedBg");

    self._icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self.lvBg = UIUtil.GetChildByName(self.gameObject, "UISprite", "lvBg");

    self._icon_quality = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_quality");
    self._numLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "numLabel");
    self._icon_select = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_select");

    self.suitFat = UIUtil.GetChildByName(self.gameObject, "UISprite", "suitFat");

    self._gemIcon = UIUtil.GetChildByName(self.gameObject, "Transform", "gemIcon");
    self._starIcon = UIUtil.GetChildByName(self.gameObject, "Transform", "starIcon");


    self.npoint = UIUtil.GetChildByName(self.gameObject, "UISprite", "npoint");
    self._numLabel.text = "";

    self.eq_slv = 0;
    self.eq_rlv = 0;
    self.eq_star = 0;
    self.suit_lev = 0;

    if self.suitFat ~= nil then
        self.suitFat.gameObject:SetActive(false);
    end

    self.showStar = true;
    self.showGem = true;
    self:SetShowGem(false);
    self:SetShowStar(false);

    self.kind = index;

    self:SetLock(false);
    self:Selected(false);

    self:SetNpointV(false);


end


function EquipPanelCtrl:SetNpointV(v)

    if self.npoint ~= nil then
        self.npoint.gameObject:SetActive(v);
    end


end



function EquipPanelCtrl:SetOnClickBtnHandler(handler, hd_target)

    self._selectHandler = handler;
    self._selectHandlerTarget = hd_target;

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);
end

function EquipPanelCtrl:Selected(v)
    self.selected = v;
    self._icon_select.gameObject:SetActive(v);
end

function EquipPanelCtrl:SetLock(v)
    self.lock = v;
    self._lockedBg.gameObject:SetActive(v);

    if v then

        local my_info = HeroController:GetInstance().info;
        local my_career = my_info:GetCareer();

        local bag_eq = BackpackDataManager.GetFixMyEqByTypeAndKind(ProductManager.type_1, self.kind, my_career);
        local len = table.getn(bag_eq);

        if len == 0 then
            self._lockedBg.spriteName = "addIcon";
        else
            self._lockedBg.spriteName = "add1";
        end

    end

end

function EquipPanelCtrl:SetData(equip_lv_data, useKey)
    self.equip_lv_data = equip_lv_data;

    --  需要获取装备栏里的 对应装备
    local productInfo = EquipDataManager.GetProductByIdx(self.equip_lv_data.idx - 1);

    local value = equip_lv_data[useKey];


    if equip_lv_data ~= nil then

        if equip_lv_data["slv"] ~= nil then
            self.eq_slv = equip_lv_data["slv"];
        end

        if equip_lv_data["rlv"] ~= nil then
            self.eq_rlv = equip_lv_data["rlv"];
        end

        if equip_lv_data["suit_lev"] ~= nil then
            self.suit_lev = equip_lv_data["suit_lev"];
        end

    end

    if useKey == "slv" then
        -- 强化 -- 现在的 附灵
        if productInfo ~= nil then
            productInfo:UpAttribute(value);
        end

    elseif useKey == "rlv" then
        -- 精炼
        if productInfo ~= nil then
            productInfo:UpAttribute(value);
        end

    elseif useKey == "star" then
        -- 星级（神器）
        value = 0;
        self.eq_star = 0;

    elseif useKey == "plv" then
        -- 新 强化
        value = 0;
        self.eq_star = 0;

    elseif useKey == "suit_lev" then

        value = self.suit_lev;
    end

    if value == nil then
        value = 0;
    end

    if self.suitFat ~= nil then
        self.suitFat.gameObject:SetActive(false);
    end

    --[[
    if productInfo ~= nil then
        log(" useKey "..useKey.." value "..value.." name "..productInfo:GetName());
    end 
  ]]

    if value > 0 then

        if useKey == "suit_lev" then

            self._numLabel.text = "";
            self:SetlvBgActive(false);

            if self.suitFat ~= nil then
                self.suitFat.gameObject:SetActive(true);

                if value == 1 then
                    self.suitFat.spriteName = "huanjie";

                elseif value == 2 then
                    self.suitFat.spriteName = "shengmin";
                end

            end

        else
            self._numLabel.text = "" .. value;
            self:SetlvBgActive(true);

        end


    else
        self._numLabel.text = "";
        self:SetlvBgActive(false);
    end

    self:SetProduct(productInfo);

    self:UpdateGem();
    self:UpdateStar();

end

function EquipPanelCtrl:SetDataForNewEquipStrong(equipStrongData, kind)
    local productInfo = EquipDataManager.GetProductByIdx(kind - 1);
    self:SetProduct(productInfo);

    self._gemIcon.gameObject:SetActive(false);
    self._starIcon.gameObject:SetActive(false);

    local st_lv = NewEquipStrongManager.GetEquipStrongDataByIdx(kind).level;

    if st_lv > 0 then
        self._numLabel.text = "" .. st_lv;
        self:SetlvBgActive(true);

    else
        self._numLabel.text = "";
        self:SetlvBgActive(false);
    end

     if self.suitFat ~= nil then
        self.suitFat.gameObject:SetActive(false);
    end
end


function EquipPanelCtrl:SetShowGem(v)
    if (self.showGem ~= v) then
        self.showGem = v;
        self:UpdateGem();
    end

end

function EquipPanelCtrl:SetShowStar(v)
    if (self.showStar ~= v) then
        self.showStar = v;
        self:UpdateStar();
    end

end



function EquipPanelCtrl:UpdateStar()

    if self._starIcon then

        self._starIcon.gameObject:SetActive(false);
        if self._productInfo ~= nil then
            self._starIcon.gameObject:SetActive(self.showStar);
            if self.showStar then
                self._numLabel.text = "";
                -- self.lvBg.gameObject:SetActive(false);
                self:SetlvBgActive(false);

                local star = self._productInfo:GetStar();
                self.eq_star = star;

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
        end
    end

end

function EquipPanelCtrl:SetlvBgActive(v)
    if self.lvBg ~= nil then
        self.lvBg.gameObject:SetActive(v);
    end
end

function EquipPanelCtrl:UpdateGem()
    if self._gemIcon then

        self._gemIcon.gameObject:SetActive(self.showGem);
        if self.showGem then
            self._numLabel.text = "";
            self:SetlvBgActive(false);

            local gemData = GemDataManager.GetSlotData(self.equip_lv_data.idx);
            for i = 1, 4 do
                local ico = UIUtil.GetChildByName(self._gemIcon, "UISprite", "gem" .. i);
                if gemData[i] and gemData[i] > 0 then
                    local cfg = ConfigManager.GetProductById(gemData[i]);
                    ProductManager.SetIconSprite(ico, cfg["icon_id"]);
                else
                    ico.atlas = nil;
                    ico.spriteName = "";
                end
            end
        end
    end
end

function EquipPanelCtrl:GetProduct()
    return self._productInfo;
end

function EquipPanelCtrl:TryCheckEqQualityspecEffect(info)

    

    if info ~= nil then
        local quality = info:GetQuality();
        local type = info:GetType();

        local ef_key = type.."_"..quality;

        if self.old_ef_key ~= ef_key then
           self._eqQualityspecEffect:TryCheckEquipQualityEffect(self.gameObject.transform, self._icon_quality, type, quality);
           self.old_ef_key = ef_key;
        end 

    else
    self._eqQualityspecEffect:StopEffect();
    end

end

function EquipPanelCtrl:SetProduct(productInfo)

    self._productInfo = productInfo;

    self:TryCheckEqQualityspecEffect(productInfo)

    if self._productInfo ~= nil then

        local icon_id = self._productInfo:GetIcon_id();


        if self._icon == nil then
            self._icon = UIUtil.GetChildByName(self.gameObject, "UITexture", "icon");
        end

        ProductManager.SetIconSprite(self._icon, icon_id);

        self._icon.gameObject:SetActive(true);

        local quality = self._productInfo:GetQuality();

        if self.ext_data ~= nil then

            local iconType = self.ext_data.iconType;

            if self.ext_data.iconType == ProductCtrl.IconType_circle then
                -- self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);
                self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);
            elseif self.ext_data.iconType == ProductCtrl.IconType_rectangle then
                -- self._icon_quality.spriteName = ProductManager.GetQulitySpriteName(quality);
                self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);
            end

        end

        self._icon_quality.gameObject:SetActive(true);

        self:SetLock(false);

    else
        self._icon.gameObject:SetActive(false);
        self._numLabel.text = "";
        self:SetlvBgActive(false);
        self._icon_quality.gameObject:SetActive(false);

        self:SetLock(true);

    end

end



function EquipPanelCtrl:_OnClickBtn()

    if self._selectHandler ~= nil then
        if self._selectHandlerTarget ~= nil then
            self._selectHandler(self._selectHandlerTarget, self);
        else
            self._selectHandler(self);
        end

    end

end


function EquipPanelCtrl:Dispose()


    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");

     if (self._eqQualityspecEffect) then
        self._eqQualityspecEffect:Dispose()
        self._eqQualityspecEffect = nil
    end

    self.gameObject = nil;
    self._lockedBg = nil;
    self._icon = nil;
    self._icon_quality = nil;
    self._numLabel = nil;
    self._icon_select = nil;

    self._onClickBtn = nil;

end

