---
--- Created by R2D2.
--- DateTime: 2019/4/25 9:56
---
require("game.pet.Component.UIBlockChecker")

PetEggTipView = PetEggTipView or class("PetEggTipView", BasePanel)

local PetEggTipView = PetEggTipView
local blockChecker

function PetEggTipView:ctor()
    self.abName = "pet"
    self.imageAb = "pet_image"
    self.assetName = "PetEggTipView"
    self.layer = "UI"

    self.use_background = false
    self.show_sidebar = false
    self.Items = {}
    blockChecker = blockChecker or UIBlockChecker()

    PetEggTipView.super.Open(self)
end

function PetEggTipView:dctor()
    blockChecker:dctor()

    if self.PetModle then
        self.PetModle:destroy()
        self.PetModle = nil
    end

    if (self.Items) then
        for _, v in pairs(self.Items) do
            v:destroy()
        end
        self.Items = {}
    end
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function PetEggTipView:LoadCallBack()
    self.nodes = { "Tip", "Tip/LeftBg", "Tip/LeftFrame", "Tip/NameText", "Tip/Model",
                   "Tip/ItemIcon", "Tip/ItemNameText", "Tip/Desc", "Tip/NumText", "Tip/AddBtn", "Tip/MinusBtn",
                   "Tip/ScrollView/Viewport/Content", "Tip/ItemPrefab", "Tip/Selector", "Tip/HatchBtn",
                   "Tip/ScrollView/Viewport"
    }
    self:GetChildren(self.nodes)

    self.layerIndex = LuaPanelManager:GetInstance():GetPanelInLayerIndex(self.layer, self)
    
    self:InitUI()
    self:AddEvent()

    if (self.goodsData) then
        self:SetViewPosition()
        self:RefreshGoods()
        self:RefreshPetList()
    end
    self:SetMask()
end

function PetEggTipView:InitUI()

    self.fullW = self.transform.rect.width
    self.fullH = self.transform.rect.height

    self.SizeW = self.Tip.rect.width
    self.SizeH = self.Tip.rect.height

    blockChecker:InitUI(self.gameObject, self.Tip)
    blockChecker:SetOverBlockCallBack(handler(self, self.OnOverBlock))

    self.petBgImage = GetImage(self.LeftBg)
    self.petFrameImage = GetImage(self.LeftFrame)
    self.nameText = GetText(self.NameText)
    self.goodsIconImage = GetImage(self.ItemIcon)
    self.goodsNameText = GetText(self.ItemNameText)
    self.goodsDescText = GetText(self.Desc)
    self.goodsNumText = GetText(self.NumText)
    self.selectorImage = GetImage(self.Selector)

    self.itemPrefab = self.ItemPrefab.gameObject
    self.itemSize = self.ItemPrefab.sizeDelta

    SetVisible(self.ItemPrefab, false)
end

function PetEggTipView:AddEvent()
    AddButtonEvent(self.AddBtn.gameObject, handler(self, self.OnAddBtn))
    AddButtonEvent(self.MinusBtn.gameObject, handler(self, self.OnMinusBtn))
    AddButtonEvent(self.HatchBtn.gameObject, handler(self, self.OnHatchBtn))
end

function PetEggTipView:SetData(data)
    self.goodsData = data
    if (self.is_loaded) then
        self:SetViewPosition()
        self:RefreshGoods()
        self:RefreshPetList()
    end
end

function PetEggTipView:OnAddBtn()
    if (self.CurrNum < self.goodsData.p_item.num) then
        self.CurrNum = self.CurrNum + 1

        self.goodsNumText.text = tostring(self.CurrNum)
    end
end

function PetEggTipView:OnMinusBtn()
    if (self.CurrNum > 1) then
        self.CurrNum = self.CurrNum - 1

        self.goodsNumText.text = tostring(self.CurrNum)
    end

end

function PetEggTipView:OnHatchBtn()
    GoodsController.GetInstance():RequestUseItem(self.goodsData.p_item.uid, self.CurrNum)
    self:Close()
end

---刷新物品信息
function PetEggTipView:RefreshGoods()

    local abName = "iconasset/" .. GoodIconUtil.GetInstance():GetABNameById(self.goodsData.cfg.icon)
    lua_resMgr:SetImageTexture(self, self.goodsIconImage, abName, tostring(self.goodsData.cfg.icon), true)
    self.goodsNameText.text = self.goodsData.cfg.name
    self.goodsDescText.text = self.goodsData.cfg.desc

    self.CurrNum = self.goodsData.p_item.num
    self.goodsNumText.text = tostring(self.CurrNum)
end

function PetEggTipView:RefreshPetList()
    local data, total = self:GetPetListData()
    local count = #data

    self:CreatePetListItem(count)

    local function call_back(item, data)
        SetParent(self.Selector, item.transform)
        SetAnchoredPosition(self.Selector, 0, 0)
        self.Selector:SetSiblingIndex(1)
        self:RefreshPetModle(data[1][1])
    end

    for i, v in ipairs(data) do
        self.Items[i]:SetData(v, total, call_back)
        SetVisible(self.Items[i], true)
    end

    for i = count + 1, #self.Items do
        SetVisible(self.Items[i], false)
    end

    call_back(self.Items[1], data[1])
end

function PetEggTipView:CreatePetListItem(count)
    local fullH = count * self.itemSize.y
    SetSizeDeltaY(self.Content, fullH)

    self.Items = self.Items or {}
    if count <= #self.Items then
        return
    end

    local baseY = (fullH - self.itemSize.y) * 0.5

    for i = #self.Items + 1, count do
        local tempItem = PetEggItemView(newObject(self.itemPrefab))
        tempItem.transform:SetParent(self.Content)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        SetAnchoredPosition(tempItem.transform, 0, baseY - (i - 1) * self.itemSize.y)
        table.insert(self.Items, tempItem)
    end
end

function PetEggTipView:GetPetListData()
    local config = Config.db_item_gift[self.goodsData.cfg.id]
    local tab = String2Table(config.reward)

    if type(tab[1]) == "number" and type(tab[2]) == "number" then
        tab = tab[3]
    end

    local tab2 = {}
    local totleRate = 0
    for _, v in ipairs(tab) do
        if (type(v) == "table" and v[2] > 0) then
            table.insert(tab2, v)
            totleRate = totleRate + v[2]
        end
    end

    return tab2, totleRate
end

function PetEggTipView:RefreshPetModle(modelId)
    local cfg = Config.db_pet[modelId]
    local imageAb = "pet_image"

    self.nameText.text = string.format("T%s.%s", ChineseNumber(cfg.order_show), cfg.name)
    --lua_resMgr:SetImageTexture(self, self.petBgImage, imageAb, "Q_Bg_" .. cfg.quality, true)
    --lua_resMgr:SetImageTexture(self,self.petBgImage,"common_image","com_icon_bg_" .. cfg.quality,true)
    lua_resMgr:SetImageTexture(self, self.petFrameImage, imageAb, "Q_Frame_" .. cfg.quality, true)
    --SetVisible(self.petFrameImage, false)

    if (self.PetModle) then
        self.PetModle:ReLoadPet(cfg.model)
    else
        self.PetModle = UIPetCamera(self.Model, nil, cfg.model, nil, nil, self.layerIndex)
    end
    ---修正位置
    local located = String2Table(cfg.located)
    local config = {}
    config.offset = { x = located[1] or 0, y = located[2] or 0, z = located[3] or 0 }
    self.PetModle:SetConfig(config)

end

function PetEggTipView:SetViewPosition()
    local startPos = self.goodsData.basePos
    local vpPos = LayerManager:UIWorldToViewportPoint(startPos.x, startPos.y, startPos.z)
    startPos = Vector2(vpPos.x * self.fullW, vpPos.y * self.fullH)
    local posX, posY

    ---零坐标->Tip的为左上角，Screen的为左下角
    posX = math.max(startPos.x - self.SizeW, 0)
    posY = math.max(self.fullH - startPos.y - self.SizeH, 0)

    SetAnchoredPosition(self.Tip, posX, posY)
end

function PetEggTipView:OnOverBlock()
    self:Close()
end

function PetEggTipView:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end
