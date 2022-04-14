---
--- Created by R2D2.
--- DateTime: 2019/5/8 19:17
---

PetComposeItemView = PetComposeItemView or class("PetComposeItemView", Node)
local this = PetComposeItemView

function PetComposeItemView:ctor(obj, data)
    self.transform = obj.transform
    self.data = data

    self.gameObject = self.transform.gameObject
    self.transform_find = self.transform.Find

    self.abName = "pet"
    self.imageAb = "pet_image"

    self.model = PetModel.GetInstance()
    self.events = {}
    self:InitUI()
    self:AddEvent()

    if (self.data) then
        self:RefreshView()
    end
end

function PetComposeItemView:SetCallBack(callback)
    self.CallBack = callback
end

function PetComposeItemView:dctor()
    if(self.epImgList) then
        for _, value in pairs(self.epImgList) do
            value = nil
        end
        self.epImgList = nil
    end
    if self.reddot then
        self.reddot:destroy()
        self.reddot = nil
    end
    self.model:RemoveTabListener(self.events)
    self.events = nil
end

function PetComposeItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "Bg", "IconBg", "Icon", "Frame", "EP1", "EP2", "EP3", "EP4", "RankText", "NameText", "q_img", "lock"}
    self:GetChildren(self.nodes)

    self.iconBgImage = GetImage(self.IconBg)
    self.iconImg = GetImage(self.Icon)
    self.frameImg = GetImage(self.Frame)
    self.rankTxt = GetText(self.RankText)
    self.nameTxt = GetText(self.NameText)
    self.q_img = GetImage(self.q_img)

    self.epImgList = {}
    table.insert(self.epImgList, GetImage(self.EP1))
    table.insert(self.epImgList, GetImage(self.EP2))
    table.insert(self.epImgList, GetImage(self.EP3))
    table.insert(self.epImgList, GetImage(self.EP4))
end

function PetComposeItemView:SetData(data, petConfig)
    self.data = data
    self.Config = petConfig

    if self.data and self.Config then
        self:RefreshView()
    end
end

function PetComposeItemView:RefreshView()
    local itemCfg = Config.db_item[self.Config.id]
    local abName = "iconasset/" .. GoodIconUtil.GetInstance():GetABNameById(itemCfg.icon)
    lua_resMgr:SetImageTexture(self, self.iconImg, abName, tostring(itemCfg.icon), true)

    --lua_resMgr:SetImageTexture(self, self.iconBgImage, self.imageAb, "Q_Bg_" .. self.Config.quality, true)
    lua_resMgr:SetImageTexture(self,self.iconBgImage,"common_image","com_icon_bg_" .. itemCfg.color,true)
    --lua_resMgr:SetImageTexture(self, self.frameImg, self.imageAb, "Q_Frame_" .. self.Config.quality, true)
    SetVisible(self.frameImg, false)
    lua_resMgr:SetImageTexture(self,self.q_img, self.imageAb, string.format('q%s', self.Config.quality),true)

    if self.Config.type == 2 then
        self.rankTxt.text = ConfigLanguage.Pet.ActivityType
    else
        self.rankTxt.text = ConfigLanguage.Pet.Rank .. self.Config.order_show
    end

    self.nameTxt.text = self.Config.name
    ---self.data 在不同的地方传的值不一致，要做判断
    local point = self.data.Data  and self.data.Data.extra or 0
    self:SetEvolutionPoint(self.Config.evolution, point)
    if self.lock then
        SetVisible(self.lock, self.data.Data.bind)
    end
    self:ShowRedDot()
end

function PetComposeItemView:SetEvolutionPoint(count, point)
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

function PetComposeItemView:AddEvent()
    local function call_back()
        if (self.CallBack) then
            self.CallBack(self)
        end
    end
    AddClickEvent(self.Bg.gameObject, call_back)

    local function call_back()
        self:ShowRedDot()
    end
    self.events[#self.events+1] = self.model:AddListener(PetEvent.Pet_Model_ComposePetEvent, call_back)
end

function PetComposeItemView:ShowRedDot()
    local costTab = self.data.cost
    if not costTab then
        return
    end
    local pet_id, need_count = costTab[1][1], costTab[1][2]
    local can_compose = self.model:HasEnoughPets(pet_id, need_count, self.data.level)

    if can_compose then
        if not self.reddot then
            self.reddot = RedDot(self.transform)
            SetLocalPosition(self.reddot.transform, 113, 29)
        end
        SetVisible(self.reddot, true)
    else
        if self.reddot then
            SetVisible(self.reddot, false)
        end
    end
end