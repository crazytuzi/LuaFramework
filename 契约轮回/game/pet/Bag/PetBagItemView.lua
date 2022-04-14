---
--- Created by  R2D2
--- DateTime: 2019/4/18 10:06
---
PetBagItemView = PetBagItemView or class("PetBagItemView", BaseItem)
local this = PetBagItemView

function PetBagItemView:ctor(parent_node, layer)
    self.abName = "pet"
    self.imageAb = "pet_image"
    self.assetName = "PetBagItemView"
    self.layer = layer

    self.events = {}
    self.isSelected = false
    PetBagItemView.super.Load(self)
end

function PetBagItemView:dctor()
    GlobalEvent:RemoveTabListener(self.events)

    if (self.epImgList) then
        for key, value in pairs(self.epImgList) do
            value = nil
        end
        self.epImgList = nil
    end
end

function PetBagItemView:LoadCallBack()
    self.nodes = {
        "Bg",
        "Content",
        "Content/Bg2",
        "Content/Icon",
        "Content/Frame",
        "Content/Corner",
        "Content/EP1",
        "Content/EP2",
        "Content/EP3",
        "Content/EP4",
        "Content/RankText",
        "Content/Selector",
        "Content/q_img",
        "Content/lock",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    self:RefreshView()
end

function PetBagItemView:InitUI()
    self.iconBg = GetImage(self.Bg2)
    self.iconImg = GetImage(self.Icon)
    self.frameImg = GetImage(self.Frame)
    self.cornerImg = GetImage(self.Corner)
    self.rankTxt = GetText(self.RankText)
    self.selectorImg = GetImage(self.Selector)
    self.q_img = GetImage(self.q_img)

    self.epImgList = {}
    table.insert(self.epImgList, GetImage(self.EP1))
    table.insert(self.epImgList, GetImage(self.EP2))
    table.insert(self.epImgList, GetImage(self.EP3))
    table.insert(self.epImgList, GetImage(self.EP4))
end

function PetBagItemView:AddEvent()
    local function call_back()
        if (self.CallBack and self.data) then
            self.CallBack(self)
        end
    end
    AddClickEvent(self.Bg.gameObject, call_back)
end

function PetBagItemView:SetData(data, callback, disableState)
    self.data = data
    self.CallBack = callback
    self.disableState = disableState

    if self.is_loaded then
        self:RefreshView()
    end
end

function PetBagItemView:SetSelect(isSelected)
    self.isSelected = isSelected
    if (self.selectorImg) then
        self.selectorImg.enabled = self.isSelected
    end
end

function PetBagItemView:RefreshView()
    if (self.data) then
        SetVisible(self.Content.gameObject, true)
        self:RefreshPet()

        if (self.disableState) then
            self.cornerImg.enabled = false
        else
            self:RefreshState()
        end
        self.selectorImg.enabled = self.isSelected
    else
        SetVisible(self.Content.gameObject, false)
    end
end

function PetBagItemView:RefreshPet()
    local itemCfg = Config.db_item[self.data.Config.id]
    local abName = "iconasset/" .. GoodIconUtil.GetInstance():GetABNameById(itemCfg.icon)
    lua_resMgr:SetImageTexture(self, self.iconImg, abName, tostring(itemCfg.icon), true)
    --lua_resMgr:SetImageTexture(self, self.iconImg, self.imageAb, self.data.Config.pic, true)
    --lua_resMgr:SetImageTexture(self, self.iconBg, self.imageAb, "Q_Bg_" .. self.data.Config.quality, true)
    lua_resMgr:SetImageTexture(self,self.iconBg,"common_image","com_icon_bg_" .. itemCfg.color, true)
    --lua_resMgr:SetImageTexture(self, self.frameImg, self.imageAb, "Q_Frame_" .. self.data.Config.quality, true)
    lua_resMgr:SetImageTexture(self, self.q_img, self.imageAb, "q" .. self.data.Config.quality, true)
    SetVisible(self.frameImg, false)

    if (self.data.Config.type == 2) then
        self.rankTxt.text = ConfigLanguage.Pet.ActivityType
    else
        self.rankTxt.text = self.data.Config.order_show .. ConfigLanguage.Pet.Rank
    end

    for i, v in ipairs(self.epImgList) do
        if (i <= self.data.Data.extra) then
            v.enabled = true
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint_Little", true)
        elseif (i <= self.data.Config.evolution) then
            v.enabled = true
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint_Little_Gray", true)
        else
            v.enabled = false
        end
    end
    SetVisible(self.lock, self.data.Data.bind)
end

function PetBagItemView:RefreshState()
    local isOK = PetModel:GetInstance():CheckFightCondition(self.data.Config, false)

    ---有时限的
    if self.data.Data.etime > 0 then
        local serverTime = TimeManager.Instance:GetServerTime()
        if (self.data.Data.etime <= serverTime) then
            self:SetState(3)
            return
        end
    end

    if (isOK) then
        local p = PetModel:GetInstance():GetOnBattlePetByOrder(self.data.Config.order)
        if (p) then
            local v = self.data.Data.score - p.score

            if (v == 0) then
                self:SetState(0)
            else
                v = v / math.abs(v)
                self:SetState(v)
            end
        else
            self:SetState(1)
        end
    else
        self:SetState(3)
    end
end

--- 1 = up, -1 = down, 3 = stop, other = hide
function PetBagItemView:SetState(state)
    if (state == 0) then
        self.cornerImg.enabled = false
    else
        self.cornerImg.enabled = true
        if (state == 1) then
            lua_resMgr:SetImageTexture(self, self.cornerImg, self.imageAb, "Corner_Up")
        elseif state == -1 then
            lua_resMgr:SetImageTexture(self, self.cornerImg, self.imageAb, "Corner_Down")
        elseif state == 3 then
            lua_resMgr:SetImageTexture(self, self.cornerImg, self.imageAb, "Corner_Stop")
        else
            self.cornerImg.enabled = false
        end
    end
end
