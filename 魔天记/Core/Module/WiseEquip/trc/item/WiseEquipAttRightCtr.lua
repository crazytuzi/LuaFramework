local WiseEquipAttRightCtr = class("WiseEquipAttRightCtr")

local WiseEquipAttItem = require "Core.Module.WiseEquip.trc.item.WiseEquipAttItem"

function WiseEquipAttRightCtr:New()
    self = { };
    setmetatable(self, { __index = WiseEquipAttRightCtr });

    return self;
end


function WiseEquipAttRightCtr:Init(transform)

    self.transform = transform;

    self.hasPro = UIUtil.GetChildByName(self.transform, "Transform", "hasPro");
    self.nonePro = UIUtil.GetChildByName(self.transform, "Transform", "nonePro");
    self.nonePro_label = UIUtil.GetChildByName(self.nonePro, "UILabel", "label");

    self.pro = UIUtil.GetChildByName(self.hasPro, "Transform", "pro");
    self.product = UIUtil.GetChildByName(self.pro, "Transform", "product");

    self.txt_ntitle = UIUtil.GetChildByName(self.pro, "UILabel", "txt_ntitle");


    self.txt_btLabel = UIUtil.GetChildByName(self.hasPro, "UILabel", "txt_btLabel");

    self.attList = UIUtil.GetChildByName(self.hasPro, "Transform", "attList");
   
    self.attListCtrs = { };
    for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
        local tf = UIUtil.GetChildByName(self.attList, "Transform", "item" .. i);
        self.attListCtrs[i] = WiseEquipAttItem:New();
        self.attListCtrs[i]:Init(tf, self,WiseEquipAttItem.TYPE_FOR_RIGHT)
    end

    self.productCtr = ProductCtrl:New();
    self.productCtr:Init(self.product, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true)

    self.nonePro_label.text= LanguageMgr.Get("WiseEquip/WiseEquipAttRightCtr/label1");
end



function WiseEquipAttRightCtr:GetItem(index)
  return  self.attListCtrs[index];
end 

function WiseEquipAttRightCtr:UpData()
   self:SetData(self.data)
end

function WiseEquipAttRightCtr:SetData(selectEq)

    self.data = selectEq;

    self.productCtr:SetData(selectEq);

    if self.data ~= nil then
        local name = self.data:GetName();
        local lv = self.data:GetLevel();
        local quality = self.data:GetQuality();

        self.txt_ntitle.text = ColorDataManager.GetColorTextByQuality(quality, name .. "  Lv." .. lv);

        self.hasPro.gameObject:SetActive(true);
        self.nonePro.gameObject:SetActive(false);



        self.txt_ntitle.gameObject:SetActive(true);

        for i = 1, EquipDataManager.WISEEQUIPATTLIST_NUM do
            self.attListCtrs[i]:SetData(self.data, i)
        end


    else
        self.hasPro.gameObject:SetActive(false);
        self.nonePro.gameObject:SetActive(true);

    end



end



function WiseEquipAttRightCtr:SetbtLabelActive(v)
    self.txt_btLabel.gameObject:SetActive(v);
end



function WiseEquipAttRightCtr:Show()
    self.transform.gameObject:SetActive(true);
end

function WiseEquipAttRightCtr:Hide()
    self.transform.gameObject:SetActive(false);
end

function WiseEquipAttRightCtr:Dispose()

    self.productCtr:Dispose();
    self.productCtr = nil;

    for i = 1,EquipDataManager.WISEEQUIPATTLIST_NUM do
        self.attListCtrs[i]:Dispose();
        self.attListCtrs[i] = nil;
    end

    self.attListCtrs = nil;
    self.transform = nil;


end


return WiseEquipAttRightCtr;

