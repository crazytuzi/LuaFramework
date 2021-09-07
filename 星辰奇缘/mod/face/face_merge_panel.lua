-- @author 黄耀聪
-- @date 2017年8月28日, 星期一

ChooseMerge = ChooseMerge or {}

ChooseMerge.MergeType =
{
    SmallFace = 1,
    NewFace = 3,
    BigFace = 2,
}

FaceMergePanel = FaceMergePanel or BaseClass(BasePanel)

function FaceMergePanel:__init(model, gameObject,myAssetWrapper,parent)
    self.parent = parent
    self.model = model
    self.gameObject = gameObject
    self.name = "FaceMergePanel"
    self.assetWrapper = myAssetWrapper

    self.fuseId = 200
    self.selectPanelTabList = {}

    self.dataList = {
        {id = 22450, desc = TI18N("合成表情箱子的材料")}
        , {id = 22452, desc = TI18N("合成新春表情的材料")}
        ,{id = 22456, desc = TI18N("合成表情箱子的材料")}
    }

    self.isInited = false
    self.itemListener = function() self:ResetItems() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.showListener = function(data) self:ApplyShow(data) end

    self.isButton = true
    self.isEffectBtn = true
    self.waitTimerId = nil
    self.timerId = nil
    self.effTimerId = nil
    self:InitPanel()
end

function FaceMergePanel:__delete()
    self.OnHideEvent:Fire()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end

    if self.waitTimerId ~= nil then
        LuaTimer.Delete(self.waitTimerId)
        self.waitTimerId = nil
    end

    if self.itemList ~= nil then
        for _,v in ipairs(self.itemList) do
            if v ~= nil then
                v.slot:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.finalLoader1 ~= nil then
        self.finalLoader1:DeleteMe()
        self.finalLoader1 = nil
    end

    if self.finalLoader2 ~= nil then
        self.finalLoader2:DeleteMe()
        self.finalLoader2 = nil
    end

    if self.finalLoader3 ~= nil then
        self.finalLoader3:DeleteMe()
        self.finalLoader3 = nil
    end

    self.gameObject = nil
end

function FaceMergePanel:InitPanel()
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t

    self.itemList = {}
    for i=1,3 do
        local tab = {}
        tab.transform = t:Find("Item" .. i)
        tab.gameObject = tab.transform.gameObject
        tab.addObj = tab.transform:Find("Add").gameObject
        tab.numText = tab.transform:Find("Num/Text"):GetComponent(Text)
        tab.slot = ItemSlot.New()
        NumberpadPanel.AddUIChild(tab.transform:Find("Icon"), tab.slot.gameObject)
        self.itemList[i] = tab

        tab.slot.gameObject:SetActive(false)
    end

    self.finalLoader1 = SingleIconLoader.New(t.transform:Find("TopItem1").gameObject)
    self.finalLoader1:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.face_textures,"Icon1"))
    self.finalButton = t.transform:Find("TopItem1"):GetComponent(Button)
    self.finalButton.onClick:AddListener(function() self:ChooseFinal(ChooseMerge.MergeType.SmallFace) end)
    self.finalSelect1 = t.transform:Find("TopItem1/Select")
    self.finalSelect1.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.face_textures,"SelectCircel")
    -- self.finalSelect1.transform.anchoredPosition = Vector2(0,1)
    self.finalTopItemBg1 = t.transform:Find("Bg/MyBg/TopItemBg1")
    self.finalPoint1 = t.transform:Find("Bg/MyBg/TopItemBg1/PointTo")
    self.finalTextBg1 = t.transform:Find("Bg/MyBg/TopItemBg1/TextBg")
    self.finalText1 = t.transform:Find("Bg/MyBg/TopItemBg1/TextBg/Text"):GetComponent(Text)

    self.finalTopItemBg2 = t.transform:Find("Bg/MyBg/TopItemBg2")
    self.finalLoader2 = SingleIconLoader.New(t.transform:Find("TopItem2").gameObject)
    self.finalLoader2:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.face_textures,"Icon2"))
    self.finalButton2 = t.transform:Find("TopItem2"):GetComponent(Button)
    self.finalButton2.onClick:AddListener(function() self:ChooseFinal(ChooseMerge.MergeType.BigFace) end)
    self.finalSelect2 = t.transform:Find("TopItem2/Select")
    self.finalSelect2.transform.anchoredPosition = Vector2(0,2)
    self.finalSelect2.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.face_textures,"SelectCircel")
    self.finalPoint2 = t.transform:Find("Bg/MyBg/TopItemBg2/PointTo")
    self.finalTextBg2 = t.transform:Find("Bg/MyBg/TopItemBg2/TextBg")
    self.finalText2 = t.transform:Find("Bg/MyBg/TopItemBg2/TextBg/Text"):GetComponent(Text)

    self.finalTopItemBg3 = t.transform:Find("Bg/MyBg/TopItemBg3")
    self.finalLoader3 = SingleIconLoader.New(t.transform:Find("TopItem3").gameObject)
    self.finalLoader3:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.face_textures,"Icon3"))
    self.finalButton3 = t.transform:Find("TopItem3"):GetComponent(Button)
    self.finalButton3.onClick:AddListener(function() self:ChooseFinal(ChooseMerge.MergeType.NewFace) end)
    self.finalSelect3 = t.transform:Find("TopItem3/Select")
    self.finalSelect3.transform.anchoredPosition = Vector2(0,2)
    self.finalSelect3.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.face_textures,"SelectCircel")
    self.finalPoint3 = t.transform:Find("Bg/MyBg/TopItemBg3/PointTo")
    self.finalTextBg3 = t.transform:Find("Bg/MyBg/TopItemBg3/TextBg")
    self.finalText3 = t.transform:Find("Bg/MyBg/TopItemBg3/TextBg/Text"):GetComponent(Text)
    self.finalText3.text = "新春表情合成"

    self.leftCon =  t.transform:Find("LeftIcon")
    self.rightCon =  t.transform:Find("RightIcon")






    self.bottomText = t.transform:Find("BottomText"):GetComponent(Text)
    self.noticeBtnRct = t.transform:Find("Notice"):GetComponent(RectTransform)
    t.transform:Find("Line").gameObject:SetActive(false)

    self.mergeButton = t:Find("Button"):GetComponent(Button)

    self.finalButton.onClick:AddListener(function() self:ShowFinal() end)
    self.mergeButton.onClick:AddListener(function() self:Merge() end)

    self.effectPanel = t.transform:Find("EffectPanel")
    self.effectPanel:Find("Main"):GetComponent(Button).onClick:AddListener(function()
            self:ClickEffectPanel()
        end)
    self.effectPanel.gameObject:SetActive(false)

    --------------------------------------------
    self.selectPanel = self.transform.parent:Find("SelectItemPanel").gameObject
    self:InitSelectPanel()
    self.OnOpenEvent:Fire()
end

function FaceMergePanel:OnAdd()
    -- self:FillItems()
    -- if self.selectPanel == nil then
    --     self.selectPanel = SingleSelectPanel.New(self.model, self.transform.parent.parent)
    -- end
    -- self.selectPanel:Show({ baseIdList = {22450}, })
    self:ShowSelect()
end

function FaceMergePanel:ChooseFinal(index)
    for i=1,3 do
        self["finalSelect" .. i].gameObject:SetActive(i == index)
        self["finalPoint" .. i].gameObject:SetActive(i == index)

        if index == i then

            self["finalTopItemBg" .. i].transform.sizeDelta = Vector2(148,144)
            self["finalLoader" .. i].image.transform.sizeDelta = Vector2(105,105)
            if index == ChooseMerge.MergeType.SmallFace then
                    self["finalLoader" .. i].gameObject.transform.anchoredPosition = Vector2(-125,-104)
                    self.leftCon.transform.anchoredPosition = Vector2(184,158)

                    self.rightCon.transform.anchoredPosition = Vector2(142,159)
                    self.leftCon.transform.localScale = Vector3(-0.8,0.8,1)
                    self.rightCon.transform.localScale = Vector3(-0.8,0.8,1)
                    self["finalTopItemBg1"].transform.anchoredPosition = Vector2(-129,80)

                    self["finalTopItemBg2"].transform.anchoredPosition = Vector2(159,87)
                    self["finalLoader2"].gameObject.transform.anchoredPosition = Vector2(163,-104)

                    self["finalTopItemBg3"].transform.anchoredPosition = Vector2(23,87)
                    self["finalLoader3"].gameObject.transform.anchoredPosition = Vector2(26,-104)
                    self.parent.isUpdateFace = false
                    self.parent.horTabGroup:ChangeTab(1)
                    self.parent.previewContainer.anchoredPosition = Vector2(1.83,0)

            elseif index == ChooseMerge.MergeType.NewFace then
                    self["finalLoader" .. i].gameObject.transform.anchoredPosition = Vector2(0,-104)
                    self.leftCon.transform.anchoredPosition = Vector2(184,158)

                    self.rightCon.transform.anchoredPosition = Vector2(142,159)
                    self.leftCon.transform.localScale = Vector3(-0.8,0.8,1)
                    self.rightCon.transform.localScale = Vector3(-0.8,0.8,1)

                    self["finalTopItemBg3"].transform.anchoredPosition = Vector2(-2,80)

                    self["finalLoader1"].gameObject.transform.anchoredPosition = Vector2(-157,-104)
                    self["finalTopItemBg1"].transform.anchoredPosition = Vector2(-160,87)

                    self["finalTopItemBg2"].transform.anchoredPosition = Vector2(159,87)
                    self["finalLoader2"].gameObject.transform.anchoredPosition = Vector2(163,-104)
                    self.parent.isUpdateFace = false
                    self.parent.horTabGroup:ChangeTab(1)
                    self.parent.previewContainer.anchoredPosition = Vector2(1.83,math.abs(self.parent.previewContainer.sizeDelta.y - (self.parent.previewRectScroll.sizeDelta.y + 135)))
            elseif index == ChooseMerge.MergeType.BigFace then
                   self["finalLoader" .. i].gameObject.transform.anchoredPosition = Vector2(133,-104)
                   self.leftCon.transform.anchoredPosition = Vector2(103,175)

                    self.rightCon.transform.anchoredPosition = Vector2(162,177)
                    self.leftCon.transform.localScale = Vector3(1,1,1)
                    self.rightCon.transform.localScale = Vector3(1,1,1)
                    self["finalTopItemBg2"].transform.anchoredPosition = Vector2(131,80)

                    self["finalLoader1"].gameObject.transform.anchoredPosition = Vector2(-157,-104)
                    self["finalTopItemBg1"].transform.anchoredPosition = Vector2(-160,87)

                    self["finalTopItemBg3"].transform.anchoredPosition = Vector2(-21,87)
                    self["finalLoader3"].gameObject.transform.anchoredPosition = Vector2(-19,-104)
                    self.parent.isUpdateFace = false
                    self.parent.horTabGroup:ChangeTab(2)
            end
            self["finalTextBg" .. i].transform.anchoredPosition = Vector2(0,-79.3)
            self["finalTextBg" .. i].transform.sizeDelta = Vector2(160,35)
            self["finalText" .. i].fontSize = 20

        else
            self["finalLoader" .. i].gameObject.transform.sizeDelta = Vector2(78,78)
            self["finalTopItemBg" .. i].transform.sizeDelta = Vector2(107,105)
            -- self["finalTopItemBg" .. i].transform.anchoredPosition = Vector2(self["finalTopItemBg" .. i].transform.anchoredPosition.x,87)
            self["finalTextBg" .. i].transform.anchoredPosition = Vector2(0,-64)
            self["finalTextBg" .. i].transform.sizeDelta = Vector2(135,28)
            self["finalText" .. i].fontSize = 17
        end
    end
    if index == ChooseMerge.MergeType.SmallFace then

        self.bottomText.text = "集齐<color='#00ff00'>三个</color>表情包子可召唤一个<color='#00ff00'>小表情</color>"
        -- self.bottomText.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-111,-152)
        -- self.noticeBtnRct.anchoredPosition = Vector2(-139,-151)
    elseif index == ChooseMerge.MergeType.BigFace then
        self.bottomText.text = "集齐<color='#00ff00'>三个</color>萌小包有几率召唤一个<color='#00ff00'>大表情</color>"
    elseif index == ChooseMerge.MergeType.NewFace then
        -- self.finalSelect1.gameObject:SetActive(false)
        -- self.finalPoint1.gameObject:SetActive(false)
        -- self.finalSelect2.gameObject:SetActive(false)
        -- self.finalPoint2.gameObject:SetActive(false)
        -- self.finalSelect3.gameObject:SetActive(true)
        -- self.finalPoint3.gameObject:SetActive(true)
        -- self.finalLoader1.image.transform.sizeDelta = Vector2(72,72)
        -- self.finalLoader2.image.transform.sizeDelta = Vector2(78,78)
        -- self.finalTopItemBg1.transform.sizeDelta = Vector2(107,105)
        -- self.finalTopItemBg2.transform.sizeDelta = Vector2(107,105)
        --  self.finalTopItemBg1.transform.anchoredPosition = Vector2(self.finalTopItemBg1.transform.anchoredPosition.x,87)
        -- self.finalTopItemBg2.transform.anchoredPosition = Vector2(self.finalTopItemBg2.transform.anchoredPosition.x,87)
        self.bottomText.text = "集齐<color='#00ff00'>三个</color>新春包子可召唤一个<color='#00ff00'>新春表情</color>"
        -- self.bottomText.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-140,-152)
        -- self.noticeBtnRct.anchoredPosition = Vector2(-167,-151)
    end

    self.fuseId = self.selectPanelTabList[index + (2*(self.parent.currentTabIndexId - 1))].baseId
    self:FillItems()
end

function FaceMergePanel:OnInitCompleted()
    if not self.isInited then
        self:InitPanel()
        self.isInited = true
    end
end

function FaceMergePanel:OnOpen()
    self:RemoveListeners()
    FaceManager.Instance.OnGetShowFace:AddListener(self.showListener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemListener)
    if self.openArgs ~= nil then
        self:ChooseFinal(tonumber(self.openArgs))
    else
        self:ChooseFinal(ChooseMerge.MergeType.SmallFace)
    end
end

function FaceMergePanel:OnHide()
    self:RemoveListeners()
end

function FaceMergePanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemListener)
    FaceManager.Instance.OnGetShowFace:RemoveListener(self.showListener)
end

function FaceMergePanel:Merge()
    if self.isButton == true then
        local cfgData = nil
        for i,v in pairs(DataFuse.data_list) do
            if (v.base_id == self.fuseId) then
                cfgData = v
                break
            end
        end

        local base_id = cfgData.base_id
        local need_num = cfgData.need_num
        local num = BackpackManager.Instance:GetItemCount(base_id)

        if need_num > num then
            NoticeManager.Instance:FloatTipsByString(string.format("%s不足可不能进行合成哟{face_1, 22}",DataItem.data_get[base_id].name))
        else
            self:ShowEffectPanel()
            --  self.isButton = false
            -- -- FuseManager.Instance:Require10607(cfgData.id, 1)
            if self.fuseId == 22450 then
                    self:ShowEffectPanel(1)
            --     FaceManager.Instance:Send10431(1)
            elseif self.fuseId == 22452 then
                    self:ShowEffectPanel(2)
            --     FaceManager.Instance:Send10431(2)
            elseif self.fuseId == 22456 then
                    self:ShowEffectPanel(3)
            end
            self.isButton = false
            -- FuseManager.Instance:Require10607(next_base_id, math.floor(num / need_num))
        end

    end
end

function FaceMergePanel:ShowFinal()
    local cfgData = nil
    for i,v in pairs(DataFuse.data_list) do
        if (v.base_id == self.fuseId) then
            cfgData = v
            break
        end
    end
    local next_base_id = cfgData.next_base_id
    -- TipsManager.Instance:ShowItem({gameObject = self.finalButton.gameObject, itemData = DataItem.data_get[next_base_id]})
end

function FaceMergePanel:FillItems()
    self:HideSelect()

    local cfgData = nil
    for i,v in pairs(DataFuse.data_list) do
        if (v.base_id == self.fuseId) then
            cfgData = v
            break
        end
    end
    local next_base_id = cfgData.next_base_id
    local base_id = cfgData.base_id
    local need_num = cfgData.need_num

    local num = BackpackManager.Instance:GetItemCount(base_id)
    local baseData = BackpackManager.Instance:GetItemBase(base_id)
    local itemData = ItemData.New()
    itemData:SetBase(baseData)

    -- if need_num > num then
    --     NoticeManager.Instance:FloatTipsByString(TI18N("背包里的物品不足以合成"))
    --     for i,item in ipairs(self.itemList) do
    --         item.addObj:SetActive(true)
    --         item.slot.gameObject:SetActive(false)
    --     end
    --     self.finalLoader.gameObject:SetActive(false)
    --     return
    -- end

    for i,item in ipairs(self.itemList) do
        if i <= num then
            item.slot.gameObject:SetActive(true)
            item.slot:SetAll(itemData)
            item.slot.transform:Find("ItemImg"):GetComponent(Image).color = Color.white
            item.numText.text = "<color='#00ff00'>1</color>/1"
        else
            item.slot.gameObject:SetActive(true)
            item.slot:SetAll(itemData)
            item.slot.transform:Find("ItemImg"):GetComponent(Image).color = Color.grey
            item.numText.text = "<color='#ff0000'>0</color>/1"
        end
        item.slot.bgImg.enabled = false
    end
end

function FaceMergePanel:ResetItems()
    -- if self.effTimerId == nil then
    --     self.effTimerId = LuaTimer.Add(600, function()
    --         self.effTimerId = nil
    --         self:ApplyMerge()
    --     end)
    -- end
    -- self:FillItems()
end


function FaceMergePanel:ApplyMerge()

end

function FaceMergePanel:InitSelectPanel()
    local transform = self.selectPanel.transform
    transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:HideSelect() end)
    transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function() self:FillItems() end)

    local container = transform:Find("Main/Scroll/Container")
    local itemCloner = transform:Find("Main/Scroll/Container/Item").gameObject
    itemCloner:SetActive(false)

    for index, value in ipairs(self.dataList) do
        local item = GameObject.Instantiate(itemCloner)
        item:SetActive(true)
        item.transform:SetParent(container)
        item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)

        local tab = {}
        tab.gameObject = item
        tab.nameText = item.transform:Find("NameText"):GetComponent(Text)
        tab.descText = item.transform:Find("DescText"):GetComponent(Text)
        tab.select = item.transform:Find("Select").gameObject
        tab.slot = ItemSlot.New()
        NumberpadPanel.AddUIChild(item.transform:Find("Icon"), tab.slot.gameObject)
        tab.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnSelect(tab) end)

        table.insert(self.selectPanelTabList, tab)
    end
    self.fuseId = 200
    self.selectPanel:SetActive(false)
    self:UpdateSelectPanel()
end

function FaceMergePanel:UpdateSelectPanel()
    for index, value in ipairs(self.dataList) do
        local tab = self.selectPanelTabList[index]
        local baseData = BackpackManager.Instance:GetItemBase(value.id)
        local itemData = ItemData.New()
        itemData:SetBase(baseData)
        itemData.need = 3
        itemData.quantity = BackpackManager.Instance:GetItemCount(value.id)
        tab.slot:SetAll(itemData)
        tab.nameText.text = itemData.name
        tab.descText.text = value.dest
        tab.select:SetActive(false)
        tab.baseId = value.id
    end
end

function FaceMergePanel:OnSelect(tab)
    for index, value in ipairs(self.selectPanelTabList) do
        value.select:SetActive(false)
    end
    tab.select:SetActive(true)
    self.fuseId = tab.baseId
end

function FaceMergePanel:ShowSelect()
    if self.selectPanel ~= nil then
        self.selectPanel:SetActive(true)
        self:UpdateSelectPanel()
    end
end

function FaceMergePanel:HideSelect()
    if self.selectPanel ~= nil then
        self.selectPanel:SetActive(false)
    end
end

function FaceMergePanel:ShowEffectPanel(index)
    self.effectPanel.gameObject:SetActive(true)

    if self.effect_1 ~= nil then
        self.effect_1:SetActive(false)
    end
    if self.effect_2 ~= nil then
        self.effect_2:SetActive(false)
    end
    if self.effect_3 ~= nil then
        self.effect_3:SetActive(false)
    end
    if self.effect_4 ~= nil then
        self.effect_4:SetActive(false)
    end
    if index == 1 then
        if self.effect_1 == nil then
            local fun = function(effectView)
                if BaseUtils.isnull(self.gameObject) then
                    return
                end

                local effectObject = effectView.gameObject
                effectObject.transform:SetParent(self.effectPanel:Find("Main"))
                effectObject.name = "Effect"
                effectObject.transform.localScale = Vector3(1, 1, 1)
                effectObject.transform.localPosition = Vector3(0, 210, -400)

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")

                self.effect_1 = effectView
            end
            self.effect_1 = BaseEffectView.New({effectId = 20016, callback = fun})
        else
            self.effect_1:SetActive(false)
            self.effect_1:SetActive(true)
        end
    elseif index == 2 then
        if self.effect_2 == nil then
            local fun = function(effectView)
                if BaseUtils.isnull(self.gameObject) then
                    return
                end

                local effectObject = effectView.gameObject
                effectObject.transform:SetParent(self.effectPanel:Find("Main"))
                effectObject.name = "Effect"
                effectObject.transform.localScale = Vector3(1, 1, 1)
                effectObject.transform.localPosition = Vector3(234, 117, -400)

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")

                self.effect_2 = effectView
            end
            self.effect_2 = BaseEffectView.New({effectId = 20017, callback = fun})
        else
            self.effect_2:SetActive(false)
            self.effect_2:SetActive(true)
        end
    elseif index == 3 then
        if self.effect_4 == nil then
            local fun = function(effectView)
                if BaseUtils.isnull(self.gameObject) then
                    return
                end

                local effectObject = effectView.gameObject
                effectObject.transform:SetParent(self.effectPanel:Find("Main"))
                effectObject.name = "Effect"
                effectObject.transform.localScale = Vector3(1, 1, 1)
                effectObject.transform.localPosition = Vector3(0,0, -400)

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")

                self.effect_4 = effectView
            end
            self.effect_4 = BaseEffectView.New({effectId = 20446, callback = fun})
        else
            self.effect_4:SetActive(false)
            self.effect_4:SetActive(true)
        end
    end
    self.effectTime = BaseUtils.BASE_TIME
end

function FaceMergePanel:ClickEffectPanel()
    if BaseUtils.BASE_TIME - self.effectTime > 0 then
        if self.isEffectBtn == true then
            self.isEffectBtn = false
            if self.effect_3 == nil then
                local fun = function(effectView)
                    if BaseUtils.isnull(self.gameObject) then
                        return
                    end

                    local effectObject = effectView.gameObject
                    effectObject.transform:SetParent(self.effectPanel:Find("Main"))
                    effectObject.name = "Effect"
                    effectObject.transform.localScale = Vector3(1, 1, 1)
                    effectObject.transform.localPosition = Vector3(0, 0, -400)

                    Utils.ChangeLayersRecursively(effectObject.transform, "UI")

                    self.effect_3 = effectView
                    self.timerId = LuaTimer.Add(600, function() self:HideEffectPanel() end)

                end
                self.effect_3 = BaseEffectView.New({effectId = 20018, callback = fun})

            else
                self.effect_3:SetActive(false)
                self.effect_3:SetActive(true)

                self.timerId = LuaTimer.Add(1000, function() self:HideEffectPanel() end)
            end
        end
    end
end

function FaceMergePanel:HideEffectPanel()
    self.effectPanel.gameObject:SetActive(false)
    if self.fuseId == 22450 then
        FaceManager.Instance:Send10431(1)
    elseif self.fuseId == 22456 then
        FaceManager.Instance:Send10431(4)
    elseif self.fuseId == 22452 then
        FaceManager.Instance:Send10431(2)
    end
end

function FaceMergePanel:ApplyShow(data)
    if self.giftShow == nil then
        self.giftShow = FaceSaveGetPanel.New(self)
    end
    local myData = {}
    myData.item_list = {}
    myData.item_list[1] = data
    self.giftShow:Show(myData)
    self.isEffectBtn = true
    self.isButton = true
end

function FaceMergePanel:CloseGiftShow()
    if self.giftShow ~= nil then
        self.giftShow:DeleteMe()
        self.giftShow = nil
    end
    if self.itemList ~= nil then
        self:FillItems()
    end
end
