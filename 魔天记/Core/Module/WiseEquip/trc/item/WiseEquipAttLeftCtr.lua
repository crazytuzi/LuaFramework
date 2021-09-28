local WiseEquipAttLeftCtr = class("WiseEquipAttLeftCtr")

local WiseEquipAttItem = require "Core.Module.WiseEquip.trc.item.WiseEquipAttItem"

function WiseEquipAttLeftCtr:New()
    self = { };
    setmetatable(self, { __index = WiseEquipAttLeftCtr });

    return self;
end


function WiseEquipAttLeftCtr:Init(transform)

    self.transform = transform;

    self.pro = UIUtil.GetChildByName(self.transform, "Transform", "pro");
    self.product = UIUtil.GetChildByName(self.pro, "Transform", "product");
    self.addicon = UIUtil.GetChildByName(self.pro, "Transform", "addicon");

    self.txt_ntitle = UIUtil.GetChildByName(self.pro, "UILabel", "txt_ntitle");
    self.txt_tip = UIUtil.GetChildByName(self.pro, "UILabel", "txt_tip");
    self.txt_noneProtip = UIUtil.GetChildByName(self.pro, "UILabel", "txt_noneProtip");

    self.txt_btLabel = UIUtil.GetChildByName(self.transform, "UILabel", "txt_btLabel");

    self.attList = UIUtil.GetChildByName(self.transform, "Transform", "attList");

    self.attListCtrs = { };
    local star_y = 122
    for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
        local tf = UIUtil.GetChildByName(self.attList, "Transform", "item" .. i);

        Util.SetLocalPos(tf, -263, star_y, 0);
        self.attListCtrs[i] = WiseEquipAttItem:New();
        self.attListCtrs[i]:Init(tf, self, WiseEquipAttItem.TYPE_FOR_LEFT)

        star_y = star_y - 58;
    end

    self.productCtr = ProductCtrl:New();
    self.productCtr:Init(self.product, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true)


end

function WiseEquipAttLeftCtr:GetItem(index)
    return self.attListCtrs[index];
end 

function WiseEquipAttLeftCtr:SetData(selectEq)

    self.data = selectEq;

    self.productCtr:SetData(selectEq);

    if self.data ~= nil then
        local name = self.data:GetName();
        local lv = self.data:GetLevel();
        local quality = self.data:GetQuality();

        self.txt_ntitle.text = ColorDataManager.GetColorTextByQuality(quality, name .. "  Lv." .. lv);

        self.addicon.gameObject:SetActive(false);
        self.txt_ntitle.gameObject:SetActive(true);
        self.txt_noneProtip.gameObject:SetActive(false);
        self.txt_tip.gameObject:SetActive(false);

        self:Uptxt_tip()
    else
        self.addicon.gameObject:SetActive(true);
        self.txt_ntitle.gameObject:SetActive(false);
        self.txt_noneProtip.gameObject:SetActive(true);
        self.txt_tip.gameObject:SetActive(false);

    end

    for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
        self.attListCtrs[i]:SetData(self.data, i)
    end
    -- 目前尚未装备仙兵，建议从日常玩法中获得

end

local sort = table.sort

-- 如果本对象的装备  在背包中找到 基础属性的战斗力 比 本对象高的话， 显示提示
function WiseEquipAttLeftCtr:Uptxt_tip()

    local m_f = self.data:GetFight()
    local m_kind = self.data:GetKind();

    local me = HeroController:GetInstance();
    local my_info = me.info;
    local my_lv = my_info.level;

    local eqs_in_bag = BackpackDataManager.GetProductsByTypes2(ProductManager.type_1, m_kind);

    for key, value in pairs(eqs_in_bag) do
        local r_lv = value:GetReq_lev();
        if my_lv >= r_lv then
            local t_f = value:GetFight();
            if t_f > m_f then
                self.txt_tip.gameObject:SetActive(true);
                return;
            end
        end

    end

end

function WiseEquipAttLeftCtr:SetbtLabelActive(v)
    self.txt_btLabel.gameObject:SetActive(v);
end



function WiseEquipAttLeftCtr:Show()
    self.transform.gameObject:SetActive(true);
end

function WiseEquipAttLeftCtr:Hide()
    self.transform.gameObject:SetActive(false);
end

function WiseEquipAttLeftCtr:Dispose()

    self.productCtr:Dispose();
    self.productCtr = nil;

    for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
        self.attListCtrs[i]:Dispose();
        self.attListCtrs[i] = nil;
    end

    self.attListCtrs = nil;
    self.transform = nil;


end


return WiseEquipAttLeftCtr;

