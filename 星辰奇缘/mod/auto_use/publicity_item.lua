-- ---------------------------
-- 快速使用-- 公会宣读、公会种花
-- @author zgs
-- ---------------------------
PublicityItem = PublicityItem or BaseClass(BasePanel)

function PublicityItem:__init()
    self.path = "prefabs/ui/autouse/autouse.unity3d"
    self.effectPath = "prefabs/effect/20106.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main}
        ,{file  =  self.effectPath, type  =  AssetType.Main}
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)

    self.dataList = {}
    self.vec3 = Vector3(0, 0, 0.5)
    self.tweening = false
    self.showing = false
    self.step = 0

    self.headData = {afterData = nil}
    self.tailData = nil

    self.effect = nil
end

function PublicityItem:__delete()
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
    end
end

function PublicityItem:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "PublicityItem"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.transform:SetSiblingIndex(2)

    self.lightTransform = self.transform:Find("Main/Light").transform
    self.titleTxt = self.transform:Find("Main/Title/Text"):GetComponent(Text)
    self.btn = self.transform:Find("Main/Button"):GetComponent(Button)
    self.btnTxt = self.btn.gameObject.transform:Find("Text"):GetComponent(Text)
    self.nameTxt = self.transform:Find("Main/Name"):GetComponent(Text)
    self.slotCon = self.transform:Find("Main/Slot").gameObject
    self.ImgShouhuHead = self.transform:Find("Main/ImgShouhuHead").gameObject
    self.slotCon:SetActive(false)
    self.ImgShouhuHead:SetActive(false)
    self:ClearMainAsset()

    self.btn.onClick:AddListener(function() self:OnClickSure() end)
    local close = self.transform:Find("Main/Close"):GetComponent(Button)
    close.gameObject:SetActive(false)
    close.onClick:AddListener(function() self:OnClickClose() end)
    self.itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(self.slotCon, self.itemSlot.gameObject)

    self.gameObject:SetActive(false)

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.name = "Effect"
    self.effect.transform:SetParent(self.btn.gameObject.transform)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, 2, -1000)
    self.effect:SetActive(false)
end

function PublicityItem:ReOpen()
    -- if #self.dataList > 0 then
    --     self.showing = true
    --     self.step = self.step - 1
    --     self.gameObject:SetActive(true)
    --     self:Begin()
    -- end
    if self.headData.afterData then
        self.showing = true
        self.step = self.step - 1
        self.gameObject:SetActive(true)
        self:Begin()
    end
end

function PublicityItem:Hiden()
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

function PublicityItem:Append(data)
    -- if self.showing == false or (self.dataList[self.step] ~= nil and self.dataList[self.step].itemData.base_id ~= data.itemData.base_id) then
    --     table.insert(self.dataList, data)
    -- end

    if self.tailData ~= nil and self.tailData.itemData == data.itemData then
        -- print("-----------")
        if not self.showing then
            if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
                SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
            end
            self.showing = true
            self.gameObject:SetActive(true)
            self:Begin()
        end
        return
    end
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

function PublicityItem:Begin()
    QuestManager.Instance.autoRun = false
    self.effect:SetActive(true)
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
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
        -- QuestManager.Instance.autoRun = true
    else
        if self.autoData.type == nil then
            --道具
            self.slotCon:SetActive(true)
            self.titleTxt.text = self.autoData.title
            self.btnTxt.text = self.autoData.label
            self.itemSlot:SetAll(self.autoData.itemData)
            self.nameTxt.text = ColorHelper.color_item_name(self.autoData.itemData.quality , self.autoData.itemData.name)
        elseif self.autoData.type == AutoUseEumn.types.shouhu then
            --守护
            self.ImgShouhuHead:SetActive(true)
            local sh_data = self.autoData.shData
            self.titleTxt.text = TI18N("招募守护")
            self.btnTxt.text = TI18N("招募")
            self.nameTxt.text = ColorHelper.color_item_name(sh_data.quality , sh_data.alias)
            self.ImgShouhuHead.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head,tostring(sh_data.avatar_id))
        elseif self.autoData.type == AutoUseEumn.types.checkin then
            self.slotCon:SetActive(true)
            self.titleTxt.text = self.autoData.title
            self.btnTxt.text = self.autoData.label
            local cell = DataItem.data_get[self.autoData.itemData[1]]
            local itemdata = ItemData.New()
            itemdata:SetBase(cell)
            itemdata.quantity = self.autoData.itemData[2]
            self.itemSlot:SetAll(itemdata)
            self.nameTxt.text = ColorHelper.color_item_name(cell.quality, cell.name)
        end
    end
end

function PublicityItem:OnClickClose()
    if self.autoData.closeCallback ~= nil then
        self.autoData.closeCallback()
    end
    self:Hiden()
end

function PublicityItem:OnClickSure()
    if self.autoData.callback ~= nil then
        self.autoData.callback()
    end
    if self.headData.afterData ~= nil then
        self.headData.afterData:DeleteMe()
    end
    self:Begin()
end

function PublicityItem:Rotate()
    if self.rotateId == nil then
        self.rotateId = LuaTimer.Add(0, 10, function() self:Loop() end)
    end
end

function PublicityItem:Loop()
    self.lightTransform:Rotate(self.vec3)
end