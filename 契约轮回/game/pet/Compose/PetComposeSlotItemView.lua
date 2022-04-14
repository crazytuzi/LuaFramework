---
--- Created by R2D2.
--- DateTime: 2019/5/9 10:54
---
PetComposeSlotItemView = PetComposeSlotItemView or class("PetComposeSlotItemView", Node)
local this = PetComposeSlotItemView

function PetComposeSlotItemView:ctor(obj, data, index)
    self.transform = obj.transform
    self.data = data
    self.index = index

    self.gameObject = self.transform.gameObject
    self.transform_find = self.transform.Find

    self.abName = "pet"
    self.imageAb = "pet_image"

    self:InitUI()
    self:AddEvent()

    if (self.data) then
        self:RefreshView()
    else
        self:RefreshEmpty()
    end
end

function PetComposeSlotItemView:SetCallBack(callback)
    self.CallBack = callback
end

function PetComposeSlotItemView:dctor()

end

function PetComposeSlotItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "IconBg","Tip","Icon", "Frame", "EP1", "EP2", "EP3", "EP4", "RankText", "q_img", "lock"}
    self:GetChildren(self.nodes)

    self.iconBgImage = GetImage(self.IconBg)
    self.tipImage  = GetImage(self.Tip)
    self.iconImg = GetImage(self.Icon)
    self.frameImg = GetImage(self.Frame)
    self.rankTxt = GetText(self.RankText)
    self.q_img = GetImage(self.q_img)
    --self.nameTxt = GetText(self.NameText)

    self.epImgList = {}
    table.insert(self.epImgList, GetImage(self.EP1))
    table.insert(self.epImgList, GetImage(self.EP2))
    table.insert(self.epImgList, GetImage(self.EP3))
    table.insert(self.epImgList, GetImage(self.EP4))
end

function PetComposeSlotItemView:SetData(data)
    self.data = data

    if (self.data) then
        self:RefreshView()
    else
        self:RefreshEmpty()
    end
end

---置空
function PetComposeSlotItemView:RefreshEmpty()
    self.iconImg.enabled = false
    self.tipImage.enabled = true
    lua_resMgr:SetImageTexture(self, self.iconBgImage, self.imageAb, "Pet_Repalce_Icon_Bg", true)
    lua_resMgr:SetImageTexture(self, self.frameImg, self.imageAb, "Q_Frame_1", true)
    self.rankTxt.text = ""
    SetVisible(self.q_img, false)
    SetVisible(self.lock, false)
    self:SetEvolutionPoint(0, 0)
end

function PetComposeSlotItemView:RefreshView()

    local config = self.data.Config
    local itemCfg = Config.db_item[config.id]

    local abName = "iconasset/" .. GoodIconUtil.GetInstance():GetABNameById(itemCfg.icon)
    lua_resMgr:SetImageTexture(self, self.iconImg, abName, tostring(itemCfg.icon), true)

    lua_resMgr:SetImageTexture(self,self.iconBgImage,"common_image","com_icon_bg_" .. config.quality,true)
    --lua_resMgr:SetImageTexture(self, self.iconBgImage, self.imageAb, "Q_Bg_" .. config.quality, true)
    --lua_resMgr:SetImageTexture(self, self.frameImg, self.imageAb, "Q_Frame_" .. config.quality, true)
    lua_resMgr:SetImageTexture(self, self.q_img, self.imageAb, "q" .. config.quality, true)
    SetVisible(self.frameImg, false)

    self.iconImg.enabled = true
    self.tipImage.enabled = false

    if config.type == 2 then
        self.rankTxt.text = ConfigLanguage.Pet.ActivityType
    else
        self.rankTxt.text = ConfigLanguage.Pet.Rank .. config.order_show
    end

    self:SetEvolutionPoint(config.evolution, self.data.Data.extra)
    SetVisible(self.lock, self.data.Data.bind)
end

function PetComposeSlotItemView:SetEvolutionPoint(count, point)
    for i, v in ipairs(self.epImgList) do
        if (i <= point) then
            v.enabled = true
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint", true)
        elseif (i <= count) then
            v.enabled = true
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint_Gray", true)
        else
            v.enabled = false
        end
    end
end

function PetComposeSlotItemView:AddEvent()
    local function call_back()
        if (self.CallBack) then
            self.CallBack(self)
        end
    end
    AddClickEvent(self.IconBg.gameObject, call_back)
end