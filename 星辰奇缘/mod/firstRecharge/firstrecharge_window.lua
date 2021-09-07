--首充
-- @author zgs
FirstRechargeWindow = FirstRechargeWindow or BaseClass(BaseWindow)

function FirstRechargeWindow:__init(model)
    self.model = model
    self.name = "FirstRechargeWindow"

    self.windowId = WindowConfig.WinID.firstrecharge_window

    self.resList = {
        {file = AssetConfig.firstrecharge_window, type = AssetType.Main}
        ,{file  =  AssetConfig.FashionBg, type  =  AssetType.Dep}
    }
    
    self.OnOpenEvent:AddListener(function()
      self:OnOpen()
    end)

    self.OnHideEvent:AddListener(function()
      self:OnHide()
    end)

    self.slotList = {}
    self.effTimerId = nil
end

function FirstRechargeWindow:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function FirstRechargeWindow:__delete()
    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.slotList ~= nil then
        for _,v in pairs(self.slotList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.slotList = nil
    end
    if self.effect2 ~= nil then
        self.effect2:DeleteMe()
        self.effect2 = nil
    end
    if self.previewComposite ~= nil then
        self.previewComposite:DeleteMe()
        self.previewComposite = nil
    end
    if self.lbg ~= nil then
        self.lbg.sprite = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
    self.model = nil
end

function FirstRechargeWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.firstrecharge_window))
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
                self:OnClickClose()
            end)

    self.leftContent = self.transform:Find("Main/Content/LImageMask")
    self.lbg = self.leftContent:Find("ImageBg"):GetComponent(Image)
    self.lbg.gameObject:SetActive(false)
    self.lbg.sprite = self.assetWrapper:GetSprite(AssetConfig.FashionBg, "FashionBg") --左边的底图，动态去获取
    self.lbg.gameObject:SetActive(true)
    self.animalName = self.leftContent:Find("AnimalText"):GetComponent(Text)
    self.animalDesc = self.leftContent:Find("DescText"):GetComponent(Text)
    self.detailBtn = self.leftContent:Find("AnimalText/Detail"):GetComponent(Button)
    -- self.animalName.alignment = 1
    -- self.animalName.verticalOverflow = 1
    self.animalName.text = ""

    self.leftDesc = self.leftContent:Find("DescBg/DescText"):GetComponent(Text)
    self.leftDesc.text = DataCampaign.data_list[1].content
    local rt = self.leftDesc.gameObject:GetComponent(RectTransform)
    rt.offsetMin = Vector2(10,-10)
    rt.offsetMax = Vector2(-10,0)
    self.modelParent = self.leftContent:Find("ModelParent")
    self.modelParentBtn = self.modelParent:GetComponent(Button)

    self.rightContent = self.transform:Find("Main/Content/RImageMask")
    self.item1 = self.rightContent:Find("Item1")
    self.item1Parent = self.item1:Find("Image")

    local fun = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.item1Parent)
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(-31, -23, -400)
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        effectObject:SetActive(true)
    end
    self.effect = BaseEffectView.New({effectId = 20053, time = nil, callback = fun})


    self.textItem1 = self.item1:Find("Text"):GetComponent(Text)
    self.item2 = self.rightContent:Find("Item2")
    self.item2Parent = self.item2:Find("Image")
    self.textItem2 = self.item2:Find("Text"):GetComponent(Text)
    self.item3 = self.rightContent:Find("Item3")
    self.item3Parent = self.item3:Find("Image")
    self.textItem3 = self.item3:Find("Text"):GetComponent(Text)
    self.item4 = self.rightContent:Find("Item4")
    self.item4Parent = self.item4:Find("Image")
    self.textItem4 = self.item4:Find("Text"):GetComponent(Text)
    self.item5 = self.rightContent:Find("Item5")
    self.item5Parent = self.item5:Find("Image")
    self.textItem5 = self.item5:Find("Text"):GetComponent(Text)
    self.item6 = self.rightContent:Find("Item6")
    self.item6Parent = self.item6:Find("Image")
    self.textItem6 = self.item6:Find("Text"):GetComponent(Text)
    self.itemDic = {
         [1] = {[1] = self.item1Parent,[2] = self.textItem1}
        ,[2] = {[1] = self.item2Parent,[2] = self.textItem2}
        ,[3] = {[1] = self.item3Parent,[2] = self.textItem3}
        ,[4] = {[1] = self.item4Parent,[2] = self.textItem4}
        ,[5] = {[1] = self.item5Parent,[2] = self.textItem5}
        ,[6] = {[1] = self.item6Parent,[2] = self.textItem6}
    }

    self.goRechargeBtn = self.rightContent:Find("Button"):GetComponent(Button)
    self.goRechargeBtn.onClick:AddListener(function()
                self:OnClickGoRechargeBtn()
            end)

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
    self.effTimerId = LuaTimer.Add(1000, 3000, function()
        self.goRechargeBtn.gameObject.transform.localScale = Vector3(1.2,1.1,1)
        Tween.Instance:Scale(self.goRechargeBtn.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
    end)

    self.getRewardBtn = self.rightContent:Find("GetButton"):GetComponent(Button)
    self.getRewardBtn.onClick:AddListener(function()
                self:OnClickGetRewardButton()
            end)
    local fun2 = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.getRewardBtn.transform)
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(-50, 28, -400)
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        effectObject:SetActive(true)
    end
    self.effect2 = BaseEffectView.New({effectId = 20118, time = nil, callback = fun2})
    self.getRewardBtn.gameObject:SetActive(false)

    self.hadGetBtn = self.rightContent:Find("HadGetButton"):GetComponent(Button)
    self.hadGetBtn.gameObject:SetActive(false)

    self.gotoReturnBtn = self.rightContent:Find("I18NText/Button"):GetComponent(Button)
    self.gotoReturnBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 2}) end)

    self:InitItems()
    self:InitModel(10000)
end
--初始化首充奖励的物品
function FirstRechargeWindow:InitItems()
    -- body
    for i,v in ipairs(self.itemDic) do
        local dataItemDic = self.model:GetDataItem(i)  --读表取数据

        local slot = self.slotList[i]
        if slot == nil then
            slot = ItemSlot.New()
            self.slotList[i] = slot
        end
        local itemdata = ItemData.New()
        local cell = dataItemDic.baseData
        itemdata:SetBase(cell)
        slot:SetAll(itemdata, {inbag = false, nobutton = true})
        NumberpadPanel.AddUIChild(v[1].gameObject, slot.gameObject)
        slot:SetNum(dataItemDic.count)
        v[2].text = cell.name --显示物品名称
        if cell.id == 20097 then
            self.animalName.text = cell.name
            self.animalDesc.text = TI18N("强力法群攻宝宝")
            self.detailBtn.onClick:RemoveAllListeners()
            self.detailBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {3, 10000}) end)
        end
    end
end

--初始化模型
function FirstRechargeWindow:InitModel(id)
    local petData = DataPet.data_pet[id] --跟据ID，取模型数据

    local data = {type = PreViewType.Pet, skinId = petData.skin_id_0, modelId = petData.model_id, animationId = petData.animation_id, scale = petData.scale / 100, effects = petData.effects_0}

    local setting = {
        name = "FirstRechargeModelView"
        ,orthographicSize = 1
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }

    local fun = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.modelParent)
        rawImage.transform.localPosition = Vector3(10, 20, 0)
        rawImage.transform.localScale = Vector3(1.5, 1.5, 1.5)
        --rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        --composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    end

    if self.previewComposite == nil then
        self.previewComposite = PreviewComposite.New(fun, setting, data)
    end

    local dataItemDic = self.model:GetDataItem(1)  --读表取数据

    local itemdata = ItemData.New()
    local cell = dataItemDic.baseData
    itemdata:SetBase(cell)
    self.modelParentBtn.onClick:RemoveAllListeners()
    self.modelParentBtn.onClick:AddListener(function() TipsManager.Instance:ShowItem({gameObject = self.modelParent.gameObject, itemData = itemdata, {inbag = false, nobutton = true}}) end)
end

--点击前往充值
function FirstRechargeWindow:OnClickGoRechargeBtn()
    -- body
    --print("前往充值")
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
end

function FirstRechargeWindow:OnClickGetRewardButton()
    -- body
    FirstRechargeManager.Instance:send14001(self.rewardItem.id)
end

function FirstRechargeWindow:UpdateWindow()
    -- body
    self.rewardItem = (((CampaignManager.Instance.campaignTree[CampaignEumn.Type.FirstRecharge] or {})[1] or {}).sub or {})[1]
    --Log.Error(self.rewardItem)
    if self.rewardItem ~= nil then
        if self.rewardItem.status == 0 then
            self.goRechargeBtn.gameObject:SetActive(true)
            self.getRewardBtn.gameObject:SetActive(false)
            self.hadGetBtn.gameObject:SetActive(false)
        elseif self.rewardItem.status == 1 then
            self.goRechargeBtn.gameObject:SetActive(false)
            self.getRewardBtn.gameObject:SetActive(true)
            self.hadGetBtn.gameObject:SetActive(false)
        else
            self.goRechargeBtn.gameObject:SetActive(false)
            self.getRewardBtn.gameObject:SetActive(false)
            self.hadGetBtn.gameObject:SetActive(true)
        end
    end

end

function FirstRechargeWindow:OnClickClose()
    self.model:CloseMain()
end


