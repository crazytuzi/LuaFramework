-- 历练双倍点充能面板
-- xhs 20180110
ExerciseDoubleWindow = ExerciseDoubleWindow or BaseClass(BasePanel)

function ExerciseDoubleWindow:__init(model)
    self.model = model
    self.name = "ExerciseDoubleWindow"
    self.resList = {
        {file = AssetConfig.exercise_double_window , type = AssetType.Main}
        ,{file = AssetConfig.normalbufficon, type = AssetType.Dep}
    }
    self.itemId = 23836

    self.updateItem = function ()
        self:SetData()
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function ExerciseDoubleWindow:OnInitCompleted()
end

function ExerciseDoubleWindow:__delete()
    self.OnHideEvent:Fire()
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end
    if self.itemData ~= nil then
        self.itemData:DeleteMe()
        self.itemData = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ExerciseDoubleWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exercise_double_window))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.content = self.transform:Find("Main/Content")

    self.content:Find("DescText"):GetComponent(Text).text = TI18N("·完成<color='#ffff00'>悬赏任务</color>和<color='#ffff00'>野外挂机</color>时消耗点数获得<color='#00ff00'>双倍历练</color>\n·<color='#ffff00'>悬赏任务</color>每次消耗<color='#00ff00'>4</color>点，<color='#ffff00'>挂野</color>每次消耗<color='#00ff00'>1</color>点")

    local icon = self.content:Find("DescImage/Icon"):GetComponent(Image)
    icon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "exercise_double")
    icon.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(32, 32)

    self.point = self.content:Find("DescImage/Text"):GetComponent(Text)

    self.buyBtn = self.content:Find("BuyBtn"):GetComponent(Button)
    self.useBtn = self.content:Find("UseBtn"):GetComponent(Button)

    self.buyBtn.onClick:AddListener(function()
        local type = MarketManager.Instance.model:CheckGoldOrSliverItem(self.itemId)
        if type == 1 then 
            MarketManager.Instance:send12421({{base_id = self.itemId, num = 1}})
        elseif type == 2 then 
            MarketManager.Instance:send12422({{base_id = self.itemId, num = 1}})
        end
    end)

    self.useBtn.onClick:AddListener(function()
        local itemDic = BackpackManager.Instance.itemDic
        for id,item in pairs(itemDic) do
            if item.base_id == self.itemId then
                BackpackManager.Instance:Send10315(id, 1)
                break
            end
        end
    end)

    self.itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(self.content:Find("ItemSlot"), self.itemSlot.gameObject)
    local itemBaseData = BackpackManager.Instance:GetItemBase(self.itemId)
    self.itemData = ItemData.New()
    self.itemData:SetBase(itemBaseData)
    self.itemData.need = 1
end

function ExerciseDoubleWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ExerciseDoubleWindow:OnShow()
    self:AddListeners()
    self:SetData()
end

function ExerciseDoubleWindow:OnHide()
    self:RemoveListeners()
end

function ExerciseDoubleWindow:AddListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change,self.updateItem)
end

function ExerciseDoubleWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change,self.updateItem)
end


function ExerciseDoubleWindow:OnClickClose()
    self.model:CloseExerciseDouble()
end


function ExerciseDoubleWindow:SetData()
    self.itemData.quantity = BackpackManager.Instance:GetItemCount(self.itemId)
    self.itemSlot:SetAll(self.itemData, { nobutton = true })
    self.point.text = string.format(TI18N("历练双倍点数 剩余：%s"), SkillManager.Instance.sq_double)
    if self.itemData.quantity > 0 then
        self.buyBtn.gameObject:SetActive(false)
        self.useBtn.gameObject:SetActive(true)
    else
        self.buyBtn.gameObject:SetActive(true)
        self.useBtn.gameObject:SetActive(false)
    end
end
