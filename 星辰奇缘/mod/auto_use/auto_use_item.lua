-- ---------------------------
-- 快速使用--道具
-- hosr
-- ---------------------------
AutoUseItem = AutoUseItem or BaseClass(BasePanel)

function AutoUseItem:__init()
    self.path = "prefabs/ui/autouse/autouse.unity3d"
    self.effectPath = "prefabs/effect/20106.unity3d"
    self.resList = {
        { file = self.path, type = AssetType.Main }
        ,{ file = AssetConfig.guard_head, type = AssetType.Dep }
        ,{ file = self.effectPath, type = AssetType.Main }
    }

    self.OnOpenEvent:Add( function() self:OnShow() end)

    -- self.dataList = {}
    self.vec3 = Vector3(0, 0, 0.5)
    self.tweening = false
    self.showing = false
    self.step = 0

    self.headData = { afterData = nil }
    self.tailData = nil

    self.effect = nil
end

function AutoUseItem:__delete()
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end
end

function AutoUseItem:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "AutoUseItem"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.transform:SetSiblingIndex(1)

    self.main = self.transform:Find("Main")
    self.lightTransform = self.transform:Find("Main/Light").transform
    self.titleTxt = self.transform:Find("Main/Title/Text"):GetComponent(Text)
    self.btn = self.transform:Find("Main/Button"):GetComponent(Button)
    self.btnTxt = self.btn.gameObject.transform:Find("Text"):GetComponent(Text)
    self.nameTxt = self.transform:Find("Main/Name"):GetComponent(Text)
    self.slotCon = self.transform:Find("Main/Slot").gameObject
    self.imgTxtBack = self.transform:Find("Main/Image")
    self.ImgShouhuHead = self.transform:Find("Main/ImgShouhuHead").gameObject
    self.slotCon:SetActive(false)
    self.ImgShouhuHead:SetActive(false)

    self.btn.onClick:AddListener( function() self:OnClickSure() end)
    local close = self.transform:Find("Main/Close"):GetComponent(Button)
    close.gameObject:SetActive(false)
    close.onClick:AddListener( function() self:OnClickClose() end)
    self.itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(self.slotCon, self.itemSlot.gameObject)

    self.gameObject:SetActive(false)

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.name = "Effect"
    self.effect.transform:SetParent(self.btn.gameObject.transform)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, 2, -800)
    self.effect:SetActive(false)

    self:ClearMainAsset()
end

function AutoUseItem:ReOpen()
    -- if #self.dataList > 0 then
    if self.headData.afterData then
        self.showing = true
        self.step = self.step - 1
        self.gameObject:SetActive(true)
        self:Begin()
    end
end

function AutoUseItem:Hiden()
    if self.guideLevGift then
        TipsManager.Instance:HideGuide()
    end
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
    if self.rotateId ~= nil then
        LuaTimer.Delete(self.rotateId)
        self.rotateId = nil
    end
    self.tweening = false
    self.showing = false
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
end

function AutoUseItem:Clean()
    self:Hiden()
    -- self.dataList = {}
    self.step = 0

    while self.headData.afterData ~= nil do
        local data = self.headData.afterData.afterData
        self.headData.afterData:ChainBreakage()
        self.headData.afterData = data
    end
end

function AutoUseItem:Append(data)
    -- table.insert(self.dataList, data)

    data:ChainBreakage()

    if self.headData.afterData == nil then
        self.headData.afterData = data
        data.preData = self.headData
        self.tailData = data
    else
        self.tailData.afterData = data
        data.preData = self.tailData
        self.tailData = data
    end

    data.inChain = true

    if not self.showing then
        if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
            SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
        end
        self.showing = true
        self.gameObject:SetActive(true)
        self:Begin()
    end
end

function AutoUseItem:Begin()
    self.effect:SetActive(true)
    if RoleManager.Instance.RoleData.lev < 15 then
        QuestManager.Instance.autoRun = false
        if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
            SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
        end
    end
    if not self.tweening then
        self.tweening = true
        self:Rotate()
    end
    self.step = self.step + 1
    -- self.autoData = self.dataList[self.step]
    self.autoData = self.headData.afterData

    self.slotCon:SetActive(false)
    self.ImgShouhuHead:SetActive(false)
    if self.autoData == nil then
        self:Hiden()
        -- self.dataList = {}
        self.tailData = nil
        self.headData.afterData = nil
        self.step = 0
        QuestManager.Instance.autoRun = true
    else
        self.guideLevGift = false
        if self.autoData.type == nil then
            -- 道具
            self.slotCon:SetActive(true)
            self.titleTxt.text = self.autoData.title
            self.btnTxt.text = self.autoData.label
            self.itemSlot:SetAll(self.autoData.itemData, { nobutton = true })
            self.nameTxt.text = ColorHelper.color_item_name(self.autoData.itemData.quality, self.autoData.itemData.name)
            if self.autoData.itemData.base_id == 22510 then
                -- 10级大礼包
                self.guideLevGift = true
                TipsManager.Instance:ShowGuide( { gameObject = self.btn.gameObject, data = TI18N("领取<color='#ffff00'>等级礼包</color>啦"), forward = TipsEumn.Forward.Left })
            end
        elseif self.autoData.type == AutoUseEumn.types.shouhu then
            -- 守护
            self.ImgShouhuHead:SetActive(true)
            local sh_data = self.autoData.shData
            self.titleTxt.text = TI18N("招募守护")
            self.btnTxt.text = TI18N("招募")
            self.nameTxt.text = ColorHelper.color_item_name(sh_data.quality, sh_data.alias)
            self.ImgShouhuHead.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(sh_data.avatar_id))
        elseif self.autoData.type == AutoUseEumn.types.checkin then
            self.slotCon:SetActive(true)
            self.titleTxt.text = self.autoData.title
            self.btnTxt.text = self.autoData.label
            local cell = DataItem.data_get[self.autoData.itemData[1]]
            local itemdata = ItemData.New()
            itemdata:SetBase(cell)
            itemdata.quantity = self.autoData.itemData[2]
            self.itemSlot:SetAll(itemdata, { nobutton = true })
            self.nameTxt.text = ColorHelper.color_item_name(cell.quality, cell.name)
        elseif self.autoData.type == AutoUseEumn.types.guide_glory then
            self.slotCon:SetActive(true)
            self.titleTxt.text = self.autoData.title
            self.btnTxt.text = self.autoData.label
            self.nameTxt.text = self.autoData.name
            local cell = DataItem.data_get[self.autoData.itemId]
            local itemdata = ItemData.New()
            itemdata:SetBase(cell)
            itemdata.quantity = self.autoData.quality or 1
            self.itemSlot.noTips = true
            self.itemSlot:SetAll(itemdata, { })
        end

        local www = self.nameTxt.preferredWidth;
        local aa, bb = math.modf(www / 110);
        if bb > 0 then
            aa = aa + 1
        end
        local nameH =(aa - 1) * 20;
        self.nameTxt.transform.sizeDelta = Vector2(110, 30 + nameH);
        self.imgTxtBack.sizeDelta = Vector2(116, 30 + nameH);
        self.main.sizeDelta = Vector2(124, 160 + nameH);
        self.btn.transform.anchoredPosition = Vector2(62, -133.2 - nameH);
    end
end

function AutoUseItem:OnClickClose()
    if self.autoData.closeCallback ~= nil then
        self.autoData.closeCallback()
    end
    self:Hiden()
end

function AutoUseItem:OnClickSure()
    if self.autoData.callback ~= nil then
        self.autoData.callback()
    end
    if self.headData.afterData ~= nil then
        self.headData.afterData:DeleteMe()
    end
    self:Begin()

    if self.guideLevGift and self:CheckGuide() then
        -- LuaTimer.Add(5500, function() GuideManager.Instance:Start(10006) end)
        GuideManager.Instance:GuideImprove()
    end
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.sell_gold)
end

function AutoUseItem:Rotate()
    if self.rotateId == nil then
        self.rotateId = LuaTimer.Add(0, 10, function() self:Loop() end)
    end
end

function AutoUseItem:Loop()
    self.lightTransform:Rotate(self.vec3)
end

function AutoUseItem:CheckGuide()
    local quest = QuestManager.Instance:GetQuest(10170)
    if quest ~= nil and quest.finish == 1 then
        return true
    end

    local quest1 = QuestManager.Instance:GetQuest(22170)
    if quest1 ~= nil and quest1.finish == 1 then
        return true
    end
    return false
end