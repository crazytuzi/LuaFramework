---
--- Created by R2D2.
--- DateTime: 2019/4/25 15:22
---

PetEggItemView = PetEggItemView or class("PetEggItemView", Node)
local this = PetEggItemView

function PetEggItemView:ctor(obj, data)
    self.transform = obj.transform

    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self:InitUI();
end

function PetEggItemView:dctor()
    self.callBack = nil
end

function PetEggItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "Bg", "Icon", "Frame", "InfoText", "RateText" }
    self:GetChildren(self.nodes)

    self.iconImage = GetImage(self.Icon)
    self.frameImage = GetImage(self.Frame)
    self.infoText = GetText(self.InfoText)
    self.rateText = GetText(self.RateText)

    ---策划决定不要显示掉率，先隐藏之
    SetVisible(self.RateText, false)

    AddClickEvent(self.Bg.gameObject, handler(self, self.OnItemClick))
end

function PetEggItemView:OnItemClick()
    if (self.callBack) then
        self.callBack(self, self.Data)
    end
end

function PetEggItemView:SetData(data, totalRate, callBack)
    self.Data = data
    self.callBack = callBack

    local cfg = Config.db_pet[data[1][1]]
    local itemCfg = Config.db_item[data[1][1]]

    local iconAbName = "iconasset/" .. GoodIconUtil.GetInstance():GetABNameById(itemCfg.icon)
    local imageAb = "pet_image"

    lua_resMgr:SetImageTexture(self, self.iconImage, iconAbName, tostring(itemCfg.icon), true)
    lua_resMgr:SetImageTexture(self, self.frameImage, imageAb, "Q_Frame_" .. cfg.quality, true)
    self.infoText.text = string.format("T%s.%s", ChineseNumber(cfg.order_show), cfg.name)
    self.rateText.text = string.format("%.2f%%", data[2] * 100 / totalRate)
end

