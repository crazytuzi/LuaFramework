---
--- Created by R2D2.
--- DateTime: 2019/4/23 16:48
---
PetGetWayItemView = PetGetWayItemView or class("PetGetWayItemView", Node)
local this = PetGetWayItemView

function PetGetWayItemView:ctor(obj, data)
    self.transform = obj.transform

    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self:InitUI();
end

function PetGetWayItemView:dctor()
    self.callBack = nil
end

function PetGetWayItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "Bg", "Icon", "InfoText", }
    self:GetChildren(self.nodes)

    self.iconImage = GetImage(self.Icon)
    self.titleText = GetText(self.InfoText)

    AddClickEvent(self.Bg.gameObject, handler(self, self.OnItemClick))
end

function PetGetWayItemView:OnItemClick()
    if (self.callBack) then
        self.callBack(self.Data)
    end
end

function PetGetWayItemView:SetData(data, callBack)
    self.Data = data
    self.callBack = callBack

    local key = data[1] .. "@" .. data[2]
    local linkCfg = GetOpenByKey(key)
    local iconTab = string.split(IconConfig[linkCfg.key_str], ":")

    self.titleText.text = string.format(ConfigLanguage.Pet.GetWayCaption, linkCfg.name)
    lua_resMgr:SetImageTexture(self, self.iconImage, iconTab[1], iconTab[2])

end

