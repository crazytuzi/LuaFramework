---
--- Created by R2D2.
--- DateTime: 2019/4/13 16:19
---
PetReplaceItemView = PetReplaceItemView or class("PetReplaceItemView", Node)
local this = PetReplaceItemView

function PetReplaceItemView:ctor(obj, data)
    self.transform = obj.transform
    self.data = data

    self.gameObject = self.transform.gameObject
    self.transform_find = self.transform.Find

    self.abName = "pet"
    self.imageAb = "pet_image"

    self:InitUI()
    self:AddEvent()

    if (self.data) then
        self:RefreshView()
    end
end

function PetReplaceItemView:SetCallBack(callback)
    self.CallBack = callback
end

function PetReplaceItemView:dctor()

end

function PetReplaceItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "Bg", "EP1", "EP2", "EP3", "EP4", "Icon", "Frame", "State", "RankText", "NameText", }
    self:GetChildren(self.nodes)

    self.iconImg = GetImage(self.Icon)
    self.frameImg = GetImage(self.Frame)
    self.stateImg = GetImage(self.State)
    self.rankTxt = GetText(self.RankText)
    self.nameTxt = GetText(self.NameText)

    self.epImgList = {}
    table.insert(self.epImgList, GetImage(self.EP1))
    table.insert(self.epImgList, GetImage(self.EP2))
    table.insert(self.epImgList, GetImage(self.EP3))
    table.insert(self.epImgList, GetImage(self.EP4))
end

function PetReplaceItemView:SetData(data)
    self.data = data

    if (self.data) then
        self:RefreshView()
    end
end

function PetReplaceItemView:RefreshView()

    lua_resMgr:SetImageTexture(self, self.iconImg, self.imageAb, "pet_" .. self.data.Config.model, true)
    lua_resMgr:SetImageTexture(self, self.frameImg, self.imageAb, "Q_Frame_" .. self.data.Config.quality, true)

    if self.data.IsInBag then
        self.stateImg.enabled = false
    else
        lua_resMgr:SetImageTexture(self, self.stateImg, self.imageAb, self.data.IsFighting and "Battle_Txt" or "Assist_Txt")
        self.stateImg.enabled = true
    end
    self.rankTxt.text = self.data.Config.order_show .. "Stage"
    self.nameTxt.text = self.data.Config.name

    self:SetEvolutionPoint(self.data.Config.evolution, 0)
end

function PetReplaceItemView:SetEvolutionPoint(count, point)
    for i, v in ipairs(self.epImgList) do
        if (i <= point) then
            v.enabled = true
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint_Little");
        elseif (i <= count) then
            v.enabled = true
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint_Little_Gray");
        else
            v.enabled = false
        end
    end
end

function PetReplaceItemView:AddEvent()
    local function call_back()
        if (self.CallBack) then
            self.CallBack(self)
        end
    end
    AddClickEvent(self.Bg.gameObject, call_back)
end