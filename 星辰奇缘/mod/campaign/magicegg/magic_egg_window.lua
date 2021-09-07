MagicEggWindow = MagicEggWindow or BaseClass(BaseWindow)

function MagicEggWindow:__init(model)
    self.model = model
    self.windowId =WindowConfig.WinID.magicegg_window
    self.name = "MagicEggWindow"
    self.resList = {
        {file = AssetConfig.magicegg, type = AssetType.Main}
        ,{file = AssetConfig.magiceggbg2, type = AssetType.Main}
        ,{file = AssetConfig.magiceggdesc, type = AssetType.Main}
        ,{file = AssetConfig.textures_campaign, type = AssetType.Dep}
        ,{file = AssetConfig.textures_magicegg, type = AssetType.Dep}
        ,{file = AssetConfig.anniversary_textures, type = AssetType.Dep}
    }
    self.cacheMode = CacheMode.Visible

    self.curindex = 1
    self.maxIndex = 3--#self.model.previewData

    self.itemSlotList = {}
    self.rewardSlot = nil
    self.extra = {inbag = false, nobutton = true}

    self.petId = 20021


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MagicEggWindow:__delete()
    self:OnHide()

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.itemSlotList ~= nil then
     for i,v in ipairs(self.itemSlotList) do
         v:DeleteMe()
     end
     self.itemSlotList = nil
   end

   if self.ItemLayout  ~= nil then
      self.ItemLayout:DeleteMe()
          self.ItemLayout  = nil
    end

    if self.explainText ~= nil then
        self.explainText:DeleteMe()
        self.explainText = nil
    end
end


function MagicEggWindow:OnInitCompleted()
    self:ClearMainAsset()
end

function MagicEggWindow:OnOpen()
    if self.openArgs ~= nil then
        self.campId = self.openArgs[1]
    end
    self:SetItemContainer()
    self:OnRectScroll(0)
    self:CheckReward()
    self:UpdatePreview()

    self.timeId = LuaTimer.Add(50,function() self.ItemContainer.anchoredPosition = Vector2(-10,0) end)

end

function MagicEggWindow:OnHide()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end

    if self.timeId ~= nil then
        LuaTimer.Delete(self.timeId)
        self.timeId = nil
    end
end


function MagicEggWindow:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.magicegg))
    self.gameObject.name = self.name

    self.gameObject.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseWindow() end)

    local Main = self.gameObject.transform:Find("Main")
    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

    self.closeBtn = Main:Find("Close"):GetComponent(Button)
    self.Bigbg = Main:Find("BigBg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.magiceggbg2))
    UIUtils.AddBigbg(self.Bigbg,bigObj)
    bigObj.transform.anchoredPosition = Vector2 (0,0)

    local tModel = Main:Find("Model")
    self.model_preview = tModel:Find("Preview").gameObject
    self.model_preview.transform.anchoredPosition = Vector2(0,-50)
    self.model_preview:SetActive(false)

    self.camp = Main:Find("Camp")
     local bigObjcamp = GameObject.Instantiate(self:GetPrefab(AssetConfig.magiceggdesc))
     UIUtils.AddBigbg(self.camp,bigObjcamp)
     bigObjcamp.transform.anchoredPosition = Vector2 (0,0)

    self.explain = Main:Find("Explain/Text"):GetComponent(Text)

    Main:Find("Explain/des").anchoredPosition = Vector2(-162,55.4)

    self.explainText = MsgItemExt.New(self.explain,373, 16, 10)
    self.explainText:SetData(TI18N("<color='#ffff00'>【领取】</color>每日可领取一只鸿福兔纸\n<color='#FBA301'>【培养】</color>当天达到<color='#ffff00'>30级</color>即可进化瑞兔送福\n<color='#7FFF00'>【开启】</color>瑞兔送福可在每晚<color='#ffff00'>21:00-23:00</color>进行开启,\n    幸运儿将有几率获得终极大奖"))

    self.scrollRect = Main:Find("Reward/ScrollRect"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function(value)
        self:OnRectScroll(value)
    end)


    self.ItemContainer = Main:Find("Reward/ScrollRect/Container")
    self.ItemLayout = LuaBoxLayout.New(self.ItemContainer.gameObject, {axis = BoxLayoutAxis.X, cspacing = 20,border = 7})

    self.btn1 = Main:Find("Button1"):GetComponent(Button)

    self.btn2 = Main:Find("Button2"):GetComponent(Button)
    self.btn2.onClick:AddListener(function() self:LookLuckyDog()  end)

    self.closeBtn.onClick:AddListener(function()  self.model:CloseWindow() end)
    --LuaTimer.Add(200,function() self:OnRectScroll(0) end)
    self:OnOpen()
end



function MagicEggWindow:CheckReward()
    self.btn1.onClick:RemoveAllListeners()
    self.btn1.onClick:AddListener(function ()
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                SceneManager.Instance.sceneElementsModel:Self_PathToTarget("32043_1")
                --32025_1
                self.model:CloseWindow()
                WindowManager.Instance:CloseWindowById(WindowConfig.WinID.campaign_uniwin)
             end)
end


function MagicEggWindow:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "LuckyDog"
        ,orthographicSize = 0.75
        ,width = 341
        ,height = 341
        ,offsetY = -0.46
    }

    --请求服务器得到的信息
    local myData = SceneManager.Instance:MyData()
    --self.curindex
    --local data = self.model.previewData
    local data = {1,2,3}

    local petData = DataPet.data_pet[self.petId] --跟据ID，取模型数据
    local modelData = {type = PreViewType.Pet, skinId = petData.skin_id_2, modelId = petData.model_id2, animationId = petData.animation_id, scale = petData.scale / 90, effects = petData.effects_2}

    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback,setting,modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()

end

function MagicEggWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.model_preview.transform)
    rawImage.transform.localPosition = Vector3(0,0,0)
    rawImage.transform.localScale = Vector3(1,1,1)
    composite.tpose.transform.localRotation = Quaternion.Euler(0, 345, 0)
    self.model_preview:SetActive(true)
end


function MagicEggWindow:SetItemContainer()
    self.ItemLayout:ReSet()
    local data = CampaignManager.Instance.ItemFilter(DataCampaign.data_list[self.campId].rewardgift)
    for i,v in ipairs(data) do
        local id = v[1]
        local itemData = DataItem.data_get[id]
        local rechargePackSlot = self.itemSlotList[i]
        if rechargePackSlot == nil then
            rechargePackSlot = RechargePackItem.New()
        end
        rechargePackSlot.slot:SetAll(itemData,self.extra)
        rechargePackSlot.slot:SetNum(v[2])

        if v[3] == 1 then
            rechargePackSlot:ShowEffect(true,1)
        end

        self.itemSlotList[i] = rechargePackSlot
        self.ItemLayout:AddCell(rechargePackSlot.slot.gameObject)
    end
    -- for j = #data + 1, #self.itemSlotList then
    --     self.itemSlotList[j].slot.gameObject:SetActive(false)
    -- end
end


function MagicEggWindow:OnRectScroll(value)
    local Top = 280
    local Bot = 0
    for k,v in pairs(self.itemSlotList) do
        local ax = v.slot.transform.anchoredPosition.x + self.ItemContainer.anchoredPosition.x
        local state = nil
        if ax  < Bot or ax > Top then
            state = false
        else
            state = true
        end
        -- if v.slot.transform:FindChild("Effect") ~= nil then
        --     v.slot.transform:FindChild("Effect").gameObject:SetActive(state)
        -- end
        if v.effect ~= nil then
            v.effect:SetActive(state)
        end
    end
end


function MagicEggWindow:LookLuckyDog()
   -- MagicEggManager.Instance.model:OpenLuckyDogWindow()

   WindowManager.Instance:OpenWindowById(WindowConfig.WinID.luckydogwindow)
end
