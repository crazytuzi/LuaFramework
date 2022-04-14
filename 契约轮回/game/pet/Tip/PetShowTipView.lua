---
--- Created by R2D2.
--- DateTime: 2019/4/18 17:24
---
require("game.pet.BaseInfo.PetBaseValueView")
require("game.pet.BaseInfo.PetBaseAttributeView")
require("game.pet.BaseInfo.PetBaseInbornAttributeView")
require("game.pet.BaseInfo.PetBaseSkillView")

require("game.pet.Component.UIBlockChecker")

PetShowTipView = PetShowTipView or class("PetShowTipView", BasePanel)
local PetShowTipView = PetShowTipView

local baseValueView = PetBaseValueView()
local baseAttributeView = PetBaseAttributeView()
local inbornAttributeView = PetBaseInbornAttributeView()
local skillView = PetBaseSkillView()
local blockChecker

function PetShowTipView:ctor()
    self.abName = "pet"
    self.imageAb = "pet_image"
    self.assetName = "PetShowTipView"
    self.layer = "UI"

    self.use_background = false
    self.show_sidebar = false

    blockChecker = blockChecker or UIBlockChecker()

    PetShowTipView.super.Open(self)
end

function PetShowTipView:dctor()
    blockChecker:dctor()

    if self.PetModle then
        self.PetModle:destroy()
        self.PetModle = nil
    end

    if (baseValueView) then
        baseValueView:destroy()
    end

    if (baseAttributeView) then
        baseAttributeView:destroy()
    end

    if (inbornAttributeView) then
        inbornAttributeView:destroy()
    end

    if (skillView) then
        skillView:destroy()
    end

    baseValueView = PetBaseValueView()
    baseAttributeView = PetBaseAttributeView()
    inbornAttributeView = PetBaseInbornAttributeView()
    skillView = PetBaseSkillView()

    if (self.epImageList) then
        for _, value in pairs(self.epImageList) do
            value = nil
        end
        self.epImageList = nil
    end

    if self.itemicon then
        self.itemicon:destroy()
    end
end

function PetShowTipView:LoadCallBack()
    self.nodes = { "Tip", "Tip/Btns/DecomposeBtn", "Tip/Btns/AssistBtn", "Tip/Btns/BattleBtn", "Tip/Btns/MarketBtn",
                   "Tip/Btns/DownMarketBtn","Tip/Btns/ModifyBtn","Tip/Btns/RefuseBtn","Tip/Btns/BuyBtn",
    "Tip/LeftBg", "Tip/LeftFrame", "Tip/NoEvolution", "Tip/Corner", "Tip/Overdue",
    "Tip/NameText", "Tip/QualityName", "Tip/Model", "Tip/EP/EP1", "Tip/EP/EP2", "Tip/EP/EP3", "Tip/EP/EP4",

    "Tip/AttrView/Damage", "Tip/AttrView/Grade", "Tip/AttrView/Score",

    "Tip/AttrView/BaseAttr/BTitle1", "Tip/AttrView/BaseAttr/BTitle2", "Tip/AttrView/BaseAttr/BTitle3",
    "Tip/AttrView/BaseAttr/BTitle4", "Tip/AttrView/BaseAttr/BTitle5", "Tip/AttrView/BaseAttr/BTitle6",
    "Tip/AttrView/BaseAttr/Slider1", "Tip/AttrView/BaseAttr/Slider2", "Tip/AttrView/BaseAttr/Slider3",
    "Tip/AttrView/BaseAttr/Slider4", "Tip/AttrView/BaseAttr/Slider5", "Tip/AttrView/BaseAttr/Slider6",
    "Tip/AttrView/BaseAttr/Slider1/ForeGround1", "Tip/AttrView/BaseAttr/Slider2/ForeGround2",
    "Tip/AttrView/BaseAttr/Slider3/ForeGround3", "Tip/AttrView/BaseAttr/Slider4/ForeGround4",
    "Tip/AttrView/BaseAttr/Slider5/ForeGround5", "Tip/AttrView/BaseAttr/Slider6/ForeGround6",
    "Tip/AttrView/BaseAttr/Value1", "Tip/AttrView/BaseAttr/Value2", "Tip/AttrView/BaseAttr/Value3",
    "Tip/AttrView/BaseAttr/Value4", "Tip/AttrView/BaseAttr/Value5", "Tip/AttrView/BaseAttr/Value6",

    "Tip/AttrView/InbornAttr/ItemPrefab", "Tip/AttrView/InbornAttr/ItemParent",

    "Tip/AttrView/Skills/SkillIcon1", "Tip/AttrView/Skills/Lock1", "Tip/AttrView/Skills/SkillLevel1",
    "Tip/AttrView/Skills/SkillTitle1", "Tip/AttrView/Skills/SkillLockTip1",
    "Tip/AttrView/Skills/SkillIcon2", "Tip/AttrView/Skills/Lock2", "Tip/AttrView/Skills/SkillLevel2",
    "Tip/AttrView/Skills/SkillTitle2", "Tip/AttrView/Skills/SkillLockTip2",
    "Tip/AttrView/Skills/SkillIcon3", "Tip/AttrView/Skills/Lock3", "Tip/AttrView/Skills/SkillLevel3",
    "Tip/AttrView/Skills/SkillTitle3", "Tip/AttrView/Skills/SkillLockTip3",
                   "Tip/buyPanel",
                   "Tip/buyPanel/price","Tip/buyPanel/Count_Group/reduce_btn","Tip/buyPanel/Count_Group/max_btn","Tip/buyPanel/iconParent",
                   "Tip/buyPanel/Count_Group/plus_btn","Tip/buyPanel/allPrice",  "Tip/buyPanel/Count_Group/num",
                   "Tip/buyPanel/buyName","Tip/buyPanel/buyPanelBg","Tip/buyPanel/upShlefBuyBtn",
    }
    self:GetChildren(self.nodes)
    self.buyName = GetText(self.buyName)
    self.price = GetText(self.price)
    self.allPrice = GetText(self.allPrice)
    --self.layerIndex = LuaPanelManager:GetInstance():GetPanelInLayerIndex(self.layer, self)

    self:InitUI()
    self:AddEvent()

    if (self.CurrPetData) then
        self:RefreshView()
    end

    if self.is_need_setBuyInfo  then
        self:SetBuyInfo(self.buyItemId)
    end
end


function PetShowTipView:InitUI()

    self.fullSize = self.transform.sizeDelta
    self.SizeW = self.Tip.sizeDelta.x + self.AssistBtn.sizeDelta.x
    self.SizeH = self.Tip.sizeDelta.y

    --if (PetModel:GetInstance().fight_order == self.CurrPetData.Config.order) then
    --    blockChecker:InitUI(self.gameObject, self.Tip, self.BattleBtn, self.DecomposeBtn)
    --else
    --    blockChecker:InitUI(self.gameObject, self.Tip, self.AssistBtn, self.BattleBtn, self.DecomposeBtn)
    --end
    blockChecker:InitUI(self.gameObject, self.Tip)
    blockChecker:SetOverBlockCallBack(handler(self, self.OnOverBlock))

    self.petBgImage = GetImage(self.LeftBg)
    self.petFrameImage = GetImage(self.LeftFrame)
    self.nameText = GetText(self.NameText)
    self.qualityNameImage = GetImage(self.QualityName)
    self.noEvolutionImage = GetImage(self.NoEvolution)
    self.cornerImage = GetImage(self.Corner)
    self.overdueImage = GetImage(self.Overdue)

    self.epImageList = {}
    table.insert(self.epImageList, GetImage(self.EP1))
    table.insert(self.epImageList, GetImage(self.EP2))
    table.insert(self.epImageList, GetImage(self.EP3))
    table.insert(self.epImageList, GetImage(self.EP4))

    baseValueView:InitUI(self.Grade, self.Score, self.Damage)
    SetVisible(self.Grade, false)

    baseAttributeView:AddItem(self.BTitle1, self.Slider1, self.ForeGround1, self.Value1)
    baseAttributeView:AddItem(self.BTitle2, self.Slider2, self.ForeGround2, self.Value2)
    baseAttributeView:AddItem(self.BTitle3, self.Slider3, self.ForeGround3, self.Value3)
    baseAttributeView:AddItem(self.BTitle4, self.Slider4, self.ForeGround4, self.Value4)
    baseAttributeView:AddItem(self.BTitle5, self.Slider5, self.ForeGround5, self.Value5)
    baseAttributeView:AddItem(self.BTitle6, self.Slider6, self.ForeGround6, self.Value6)

    inbornAttributeView:InitUI(self.ItemPrefab, self.ItemParent, nil)

    skillView:AddItem(self.SkillIcon1, self.Lock1, self.SkillLevel1, self.SkillTitle1, self.SkillLockTip1)
    skillView:AddItem(self.SkillIcon2, self.Lock2, self.SkillLevel2, self.SkillTitle2, self.SkillLockTip2)
    skillView:AddItem(self.SkillIcon3, self.Lock3, self.SkillLevel3, self.SkillTitle3, self.SkillLockTip3)


end

function PetShowTipView:AddEvent()
    AddButtonEvent(self.BattleBtn.gameObject, handler(self, self.OnBattle))
    AddButtonEvent(self.AssistBtn.gameObject, handler(self, self.OnAssist))
    AddButtonEvent(self.DecomposeBtn.gameObject, handler(self, self.OnDecompose))
    AddButtonEvent(self.MarketBtn.gameObject, handler(self, self.OnMarket)) --上架
    AddButtonEvent(self.DownMarketBtn.gameObject, handler(self, self.OnDownMarket)) --下架
    AddButtonEvent(self.ModifyBtn.gameObject, handler(self, self.OnModify)) --修改
    AddButtonEvent(self.RefuseBtn.gameObject, handler(self, self.OnRefuse)) --拒绝
    AddButtonEvent(self.BuyBtn.gameObject, handler(self, self.OnBuy))

    local function call_back()
        local item = MarketModel:GetInstance().selectGoodItem
        local type = 1
        local uid = item.uid
        local num = 1
        local price = item.price
        MarketController:GetInstance():RequeseBuyItem(type,uid,num,price)
        self:Close()
    end
    AddButtonEvent(self.upShlefBuyBtn.gameObject,call_back)


    local function call_back()  --减数量

    end

    AddButtonEvent(self.reduce_btn.gameObject,call_back)

    local function call_back()  --加数量

    end
    AddButtonEvent(self.plus_btn.gameObject,call_back)


    local function call_back()  --最大数量

    end

    AddButtonEvent(self.max_btn.gameObject,call_back)

end

---上架
function PetShowTipView:OnMarket()
    if self.UpShelf_click_call_back then
        self.UpShelf_click_call_back(self.call_back_param)
    end
    self:Close()
end
--下架
function PetShowTipView:OnDownMarket()
    if self.DownShelf_Click_call_back then
        self.DownShelf_Click_call_back(self.Down_call_back_param)
    end
    self:Close()
end
--修改
function PetShowTipView:OnModify()
    if self.Modify_Click_call_back then
        self.Modify_Click_call_back(self.Modify_call_back_param)
    end
    self:Close()
end
--拒绝
function PetShowTipView:OnRefuse()
    if self.Refuse_Click_call_back then
        self.Refuse_Click_call_back(self.Refuse_call_back_param)
    end
    self:Close()
end
function PetShowTipView:OnBuy()
    if self.Buy_Click_call_back then
        self.Buy_Click_call_back(self.Buy_call_back_param)
    end
    self:Close()
end


function PetShowTipView:SetBuyInfo(itemId)
    self.buyItemId = itemId
    if not self.is_loaded then
        self.is_need_setBuyInfo = true
        return
    end
    self:CreateBuyInfo()
end

function PetShowTipView:CreateBuyInfo()
    local param = {}
    param["item_id"] = self.buyItemId
    param["model"] = MarketModel:GetInstance()
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.iconParent)
    end
    self.itemicon:SetIcon(param)
    local colorNum = Config.db_item[self.buyItemId].color
    local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(colorNum), Config.db_item[self.buyItemId].name)
    self.buyName.text = str
    local item = MarketModel:GetInstance().selectGoodItem
    self.price.text = item.price
    self.allPrice.text = item.price
end

---出战
function PetShowTipView:OnBattle()
    --if (PetModel:GetInstance():CheckFightCondition(self.CurrPetData.Config, true)) then
    --    PetController:GetInstance():RequestPetSet(self.CurrPetData.Data.uid, 1)
    --    PetModel:SaveRequestPetSetValue(1)
    --    self:Close()
    --end
    self:CheckCondition(1)
end

---助战
function PetShowTipView:OnAssist()
    --if (PetModel:GetInstance():CheckFightCondition(self.CurrPetData.Config, true)) then
    --    PetController:GetInstance():RequestPetSet(self.CurrPetData.Data.uid, 0)
    --    PetModel:SaveRequestPetSetValue(0)
    --    self:Close()
    --end
    self:CheckCondition(0)

end

function PetShowTipView:CheckCondition(value)
    if (PetModel:GetInstance():CheckFightCondition(self.CurrPetData.Config, true)) then
        local extraCheck, slotPetName, extra, backItemStr = self:CheckInSlotPet()

        local function call_back()
            PetController:GetInstance():RequestPetSet(self.CurrPetData.Data.uid, value)
            PetModel:SaveRequestPetSetValue(value)
            self:Close()
        end

        if (extraCheck) then
            call_back()
        else
            local str = string.format(ConfigLanguage.Pet.ChangeBetterPetWithEvolution, slotPetName, extra, backItemStr)
            Dialog.ShowTwo("Tip", str, "Confirm", call_back, nil, "Cancel", nil, nil)
        end
    end
end

function PetShowTipView:CheckInSlotPet()
    local slotPet = PetModel:GetInstance():GetBattlePetByOrder(self.CurrPetData.Config.order)
    if slotPet == nil or slotPet.Data.extra <= 0 then
        return true
    end

    local extra = slotPet.Data.extra
    local items = {}
    local result = {}

    for i = 1, extra do
        local cfgKey = slotPet.Config.order .. "@" .. i
        local tempCfg = Config.db_pet_evolution[cfgKey]
        local tab = String2Table(tempCfg.cost)

        for _, v in ipairs(tab) do
            if items[v[1]] then
                items[v[1]] = items[v[1]] + v[2]
            else
                items[v[1]] = v[2]
            end
        end
    end

    for i, v in pairs(items) do
        local tempItemCfg = Config.db_item[i]
        local name = tempItemCfg.name
        table.insert(result, string.format("<color=#%s>%s * %s</color>", ColorUtil.GetColor(tempItemCfg.color), name, v))
    end

    local backItemStr = table.concat(result, " , ")
    local slotPetName = PetModel:GetInstance():GeneratePetDescribe(slotPet.Config)
    return false, slotPetName, extra, backItemStr

end

function PetShowTipView:OnDecompose()
    if (self.CurrPetData.Config.quality >= PetModel.DecomposeQualityDivide) then
        Dialog.ShowTwo("Tip", ConfigLanguage.Pet.DecomposeOneHighQuality, "Confirm", handler(self, self.ReqDecompose), nil, "Cancel", nil, nil)
    else
        self:ReqDecompose()
    end
end

function PetShowTipView:ReqDecompose()
    local uid = self.CurrPetData.Data.uid
    PetController:GetInstance():RequestDecomposePet({ uid })
    self:Close()
end

function PetShowTipView:SetData(pItem, tipType, pos, UpShelf_click_call_back, call_back_param)

    local itemVpPos = LayerManager:UIWorldToViewportPoint(pos.x, pos.y, pos.z)

	local data
    if type(pItem) == "table" then
        local config = Config.db_pet[pItem.id]
        data = {["Data"] = pItem, ["Config"] = config,
            ["IsActive"] = true, ["ItemVpPos"] = itemVpPos }
    else
        local config = Config.db_pet[pItem]
        data = {["Config"] = config, ["IsActive"] = false, ["ItemVpPos"] = itemVpPos }
    end

    self.tipType = tipType
    self.CurrPetData = data
    self.UpShelf_click_call_back = UpShelf_click_call_back
    self.call_back_param = call_back_param

    if (self.is_loaded) then
        self:RefreshView()
    end
end

function PetShowTipView:SetDownShelfCB(ShelfCB,call_back_param)
    self.DownShelf_Click_call_back = ShelfCB
    self.Down_call_back_param = call_back_param
end

function PetShowTipView:SetModifyCB(ModifyCB,call_back_param)
    self.Modify_Click_call_back = ModifyCB
    self.Modify_call_back_param = call_back_param
end

function PetShowTipView:SetRefuseCB(refuseCB,call_back_param)
    self.Refuse_Click_call_back = refuseCB
    self.Refuse_call_back_param = call_back_param
end
function PetShowTipView:SetBuyCB(BuyCB,call_back_param)
    self.Buy_Click_call_back = BuyCB
    self.Buy_call_back_param = call_back_param
end




--function PetShowTipView:SetData(data, isShowTip)
--    self.CurrPetData = data
--    self.isShowTip = isShowTip
--    if (self.is_loaded) then
--        self:RefreshView()
--    end
--end
function PetShowTipView:RefreshView()
    if self.CurrPetData.Config.type == 2 then
        self.nameText.text = string.format("%s.%s", ConfigLanguage.Pet.ActivityType, self.CurrPetData.Config.name)
    else
        self.nameText.text = string.format("T%s.%s", ChineseNumber(self.CurrPetData.Config.order_show), self.CurrPetData.Config.name)
    end

    lua_resMgr:SetImageTexture(self, self.qualityNameImage, self.imageAb, "Q_Name_" .. self.CurrPetData.Config.quality, true)
    --lua_resMgr:SetImageTexture(self, self.petBgImage, self.imageAb, "Q_Bg_" .. self.CurrPetData.Config.quality, true)
    lua_resMgr:SetImageTexture(self, self.petFrameImage, self.imageAb, "Q_Frame_" .. self.CurrPetData.Config.quality, true)

    local count = self.CurrPetData.Config.evolution
    local point = self.CurrPetData.Data and self.CurrPetData.Data.extra or 0

    for i, v in ipairs(self.epImageList) do
        if (i <= point) then
            v.enabled = true
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint", true);
        elseif (i <= count) then
            v.enabled = true
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint_Gray", true);
        else
            v.enabled = false
        end
    end

    self.noEvolutionImage.enabled = count <= 0

    ---有时限的
    if self.CurrPetData.Data and self.CurrPetData.Data.etime and self.CurrPetData.Data.etime > 0 then
        local serverTime = TimeManager.Instance:GetServerTime()
        if (self.CurrPetData.Data.etime <= serverTime) then
            self.overdueImage.enabled = true
        else
            self.overdueImage.enabled = false
        end
    else
        self.overdueImage.enabled = false
    end

    if (self.PetModle) then
        self.PetModle:ReLoadPet(self.CurrPetData.Config.model)
    else
        self.PetModle = UIPetCamera(self.Model, nil, self.CurrPetData.Config.model, nil, nil, nil)
    end
    ---修正位置
    local located = String2Table(self.CurrPetData.Config.located)
    local config = {}
    config.offset = { x = located[1] or 0, y = located[2] or 0, z = located[3] or 0 }
    self.PetModle:SetConfig(config)

    baseValueView:RefreshView(self.CurrPetData)
    baseAttributeView:RefreshView(self.CurrPetData)
    inbornAttributeView:RefreshView(self.CurrPetData)
    skillView:RefreshView(self.CurrPetData)

    self:RefreshTipType()
    self:SetViewPosition()
end

function PetShowTipView:RefreshTipType()

    if self.tipType == PetModel.TipType.PetEgg then
        self.cornerImage.enabled = false
        SetVisible(self.DecomposeBtn, false)
        SetVisible(self.AssistBtn, false)
        SetVisible(self.BattleBtn, false)
        SetVisible(self.MarketBtn, false)
        SetVisible(self.DownMarketBtn,false)
        SetVisible(self.ModifyBtn,false)
        SetVisible(self.buyPanel, false)
        SetVisible(self.RefuseBtn, false)
        SetVisible(self.BuyBtn, false)
        blockChecker:SetBlock(self.Tip)
    elseif self.tipType == PetModel.TipType.PetMarket then --上架
        self.cornerImage.enabled = false
        SetVisible(self.DecomposeBtn, false)
        SetVisible(self.AssistBtn, false)
        SetVisible(self.BattleBtn, false)
        SetVisible(self.DownMarketBtn,false)
        SetVisible(self.ModifyBtn,false)
        SetVisible(self.MarketBtn, true)
        SetVisible(self.buyPanel, false)
        SetVisible(self.RefuseBtn, false)
        SetVisible(self.BuyBtn, false)
        blockChecker:SetBlock(self.Tip, self.MarketBtn)
    elseif self.tipType == PetModel.TipType.DownMarket then --下架
        self.cornerImage.enabled = false
        SetVisible(self.DecomposeBtn, false)
        SetVisible(self.AssistBtn, false)
        SetVisible(self.BattleBtn, false)
        SetVisible(self.DownMarketBtn,true)
        SetVisible(self.ModifyBtn,true)
        SetVisible(self.MarketBtn, false)
        SetVisible(self.buyPanel, false)
        SetVisible(self.RefuseBtn, false)
        SetVisible(self.BuyBtn, false)
        blockChecker:SetBlock(self.Tip, self.DownMarketBtn,self.ModifyBtn)
    elseif self.tipType == PetModel.TipType.buyMarket then --购买
        self.cornerImage.enabled = false
        SetVisible(self.DecomposeBtn, false)
        SetVisible(self.AssistBtn, false)
        SetVisible(self.BattleBtn, false)
        SetVisible(self.DownMarketBtn,false)
        SetVisible(self.ModifyBtn,false)
        SetVisible(self.MarketBtn, false)
        SetVisible(self.buyPanel, true)
        SetVisible(self.BuyBtn, false)
        blockChecker:SetBlock(self.Tip, self.buyPanelBg)
    elseif self.tipType == PetModel.TipType.DesBuyMarket then --指定交易购买
        self.cornerImage.enabled = false
        SetVisible(self.DecomposeBtn, false)
        SetVisible(self.AssistBtn, false)
        SetVisible(self.BattleBtn, false)
        SetVisible(self.DownMarketBtn,false)
        SetVisible(self.ModifyBtn,false)
        SetVisible(self.MarketBtn, false)
        SetVisible(self.buyPanel, false)
        SetVisible(self.RefuseBtn, true)
        SetVisible(self.BuyBtn, true)
        blockChecker:SetBlock(self.Tip, self.RefuseBtn,self.BuyBtn)
    else

        local isOverdue = false
        if (self.CurrPetData.Data.etime > 0) then
            local serverTime = TimeManager.Instance:GetServerTime()
            isOverdue = serverTime >= self.CurrPetData.Data.etime
        end
        ---过期限的
        if (isOverdue) then
            SetVisible(self.DecomposeBtn, true)
            SetVisible(self.AssistBtn, false)
            SetVisible(self.BattleBtn, false)
            SetVisible(self.MarketBtn, false)
            SetVisible(self.buyPanel, false)
            SetVisible(self.RefuseBtn, false)
            SetVisible(self.BuyBtn, false)
            SetVisible(self.DownMarketBtn,false)
            SetVisible(self.ModifyBtn,false)
            blockChecker:SetBlock(self.Tip, self.DecomposeBtn)
        else
            local order = PetModel:GetInstance().fight_order
            local isBattleOrder = (order == self.CurrPetData.Config.order)

            SetVisible(self.DecomposeBtn, true)
            SetVisible(self.AssistBtn, not isBattleOrder)
            SetVisible(self.BattleBtn, true)
            SetVisible(self.MarketBtn, false)
            SetVisible(self.buyPanel, false)
            SetVisible(self.RefuseBtn, false)
            SetVisible(self.BuyBtn, false)
            SetVisible(self.DownMarketBtn,false)
            SetVisible(self.ModifyBtn,false)
            if (isBattleOrder) then
                blockChecker:SetBlock(self.Tip, self.BattleBtn, self.DecomposeBtn)
            else
                blockChecker:SetBlock(self.Tip, self.AssistBtn, self.BattleBtn, self.DecomposeBtn)
            end
        end

        self:RefreshCorner()
    end
end

function PetShowTipView:RefreshCorner()

    local cornerPos = self.Tip:InverseTransformPoint(self.Score.position)
    cornerPos.x = cornerPos.x + self.Score.sizeDelta.x + 12
    SetLocalPosition(self.Corner, cornerPos.x, cornerPos.y, 0)

    local isOk = PetModel:GetInstance():CheckFightCondition(self.CurrPetData.Config, false)

    if (isOk) then
        local p = PetModel:GetInstance():GetOnBattlePetByOrder(self.CurrPetData.Config.order)
        if (p) then
            local v = self.CurrPetData.Data.score - p.score

            if (v == 0) then
                self:SetCornerImage(0)
            else
                v = v / math.abs(v)
                self:SetCornerImage(v)
            end
        else
            self:SetCornerImage(1)
        end
    else
        self:SetCornerImage(3)
    end
end

function PetShowTipView:OnOverBlock()
    self:Close()
end

function PetShowTipView:SetViewPosition()  
    local size = self.Tip.sizeDelta
    local area, screenPos = blockChecker:GetArea(size, self.CurrPetData.ItemVpPos)
    local pivot = self.Tip.pivot
    ---Rect相对位移
    local baseOffset = Vector2(pivot.x * self.fullSize.x, pivot.y * self.fullSize.y)

    local pos = screenPos - baseOffset - Vector2(area.x * size.x * pivot.x, area.y * size.y * pivot.y)

    SetAnchoredPosition(self.Tip, pos.x, pos.y)
end

-- function PetShowTipView:SetViewPosition()

--     local startPos = Vector2(self.fullSize.x * self.CurrPetData.ItemVpPos.x, self.fullSize.y * self.CurrPetData.ItemVpPos.y)
--     local posX, posY
--     local margins = 50

--     ---零坐标->Tip的为左上角，Screen的为左下角
--     posX = math.max(startPos.x - self.SizeW, margins)
--     posY = math.min(self.fullSize.y - startPos.y - self.SizeH, -margins)

--     ---避免UI底部超出屏幕
--     if (self.SizeH - posY) >= self.fullSize.y then
--         posY = -margins
--     end

--     SetAnchoredPosition(self.Tip, posX, posY)
-- end

function PetShowTipView:SetCornerImage(state)
    if (state == 0) then
        self.cornerImage.enabled = false
    else
        self.cornerImage.enabled = true
        if (state == 1) then
            lua_resMgr:SetImageTexture(self, self.cornerImage, self.imageAb, "Corner_Up")
        elseif state == -1 then
            lua_resMgr:SetImageTexture(self, self.cornerImage, self.imageAb, "Corner_Down")
        elseif state == 3 then
            lua_resMgr:SetImageTexture(self, self.cornerImage, self.imageAb, "Corner_Stop")
        else
            self.cornerImage.enabled = false
        end
    end
end