--2017/8/18
--ljh
--坐骑染色
RideDyeWindow  =  RideDyeWindow or BaseClass(BaseWindow)

function RideDyeWindow:__init(model)
    self.name = "RideDyeWindow"
    self.model = model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.ridedyewindow, type  =  AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        ,{file = AssetConfig.ride_texture,type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20260), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        , {file = AssetConfig.ridebg, type = AssetType.Dep}

        -- , {file = AssetConfig.rightbg2023_bigbg, type = AssetType.Dep}
        -- , {file = AssetConfig.rightbg2031_bigbg, type = AssetType.Dep}
        -- , {file = AssetConfig.rightbg2038_bigbg, type = AssetType.Dep}
        -- , {file = AssetConfig.rightbg2045_bigbg, type = AssetType.Dep}
        -- , {file = AssetConfig.rightbg2051_bigbg, type = AssetType.Dep}
        -- , {file = AssetConfig.rightbg2057_bigbg, type = AssetType.Dep}
        -- , {file = AssetConfig.rightbg2063_bigbg, type = AssetType.Dep}
        -- , {file = AssetConfig.rightbg2070_bigbg, type = AssetType.Dep}
        -- , {file = AssetConfig.rightbg2070_bigbg, type = AssetType.Dep}
    }

    --遍历染色表将右边需要加载的大图放入resList
    local cfg = DataMount.data_ride_dye
    for _, v in pairs(cfg) do
        table.insert(self.resList, {file = string.format(AssetConfig.rightbg_bigbg, v.base_id), type = AssetType.Dep})
    end

    self.windowId = WindowConfig.WinID.ridedyewindow

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.isInit = false

    local setting = {
        name = "RideDyeWindow"
        ,orthographicSize = 0.85
        ,width = 328
        ,height = 341
        ,offsetY = -0.4
    }
    self.leftModelData = nil
    self.leftModelPreview = nil
    self.leftPreviewComposite = PreviewComposite.New(nil, setting, {})
    self.leftPreviewComposite:BuildCamera(true)

    self.rightModelData = nil
    self.rightModelPreview = nil
    self.rightPreviewComposite = PreviewComposite.New(nil, setting, {})
    self.rightPreviewComposite:BuildCamera(true)

    self.leftTimeIdPlayAction = nil
    self.leftTimeIdPlayIdleAction = nil
    self.rightTimeIdPlayAction = nil
    self.rightTimeIdPlayIdleAction = nil
    self.curRightData = nil
    self.sliderTweenIdList = {0, 0, 0, 0, 0}
    self.leftSliderFenmuList = {0, 0, 0, 0, 0}
    self.recommendValList = {0, 1, 1.05, 1.1, 1.2}
    self.playEffectFinish = true
    self.effectTimeId = 0
    self.guideScript = nil
    self.saveFinishLocationTweenId = 0
    self.saveFinishAlphaTweenId = 0
    self.saveFinishLeftAlphaTweenId = 0
    self.isClickWash = false
    self.toggleWashManual = 0
    self.active = false

    self.OnClickWash = function()
        self:OnWash()
    end
    self.OnPriceBack = function()
        self:OnPrice()
    end
    self.onUpdateItem = function()
        self:UpdateCost()
    end
    self.onUpdateOne = function()
        self:UpdateView()
    end

    self.onUpdateDye = function(data)
        if #data > 0 then
            if data[1] == 1 then
                if #data > 2 then
                    self:UpdateTmpAttr(data[2], data[3])
                end
            elseif data[1] == 2 then
                self:PlaySaveFinish()

                if self.dye_id ~= nil then
                    LuaTimer.Add(500, function()
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.getride, { val = self.dye_id })
                    end)
                end
            end
        end
    end

    self.saveFinishLocationTweened = function()
        self.RightConNotData.gameObject:SetActive(true)
        self.RightCon.gameObject:SetActive(false)
        self.LeftCon:GetComponent(CanvasGroup).alpha = 1
        self.RightCon:GetComponent(CanvasGroup).alpha = 1
        self.RightCon:GetComponent(RectTransform).anchoredPosition = Vector2(197.5, 0)
    end
    return self
end

function RideDyeWindow:OnHide()
    if self.leftTimeIdPlayIdleAction ~= nil then LuaTimer.Delete(self.leftTimeIdPlayIdleAction) end
    if self.leftTimeIdPlayAction ~= nil then LuaTimer.Delete(self.leftTimeIdPlayAction) end

    if self.rightTimeIdPlayIdleAction ~= nil then LuaTimer.Delete(self.rightTimeIdPlayIdleAction) end
    if self.rightTimeIdPlayAction ~= nil then LuaTimer.Delete(self.rightTimeIdPlayAction) end

    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.onUpdateItem)
    RideManager.Instance.OnUpdateRide:Remove(self.onUpdateOne)
    RideManager.Instance.OnUpdateDye:Remove(self.onUpdateDye)

    Tween.Instance:Cancel(self.saveFinishLocationTweenId)
    Tween.Instance:Cancel(self.saveFinishAlphaTweenId)
    Tween.Instance:Cancel(self.saveFinishLeftAlphaTweenId)
end

function RideDyeWindow:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.transformation_id = self.openArgs[1]
        if  #self.openArgs > 1 then
            self.active = self.openArgs[2]
        end
    end
    local assetPath = string.format(AssetConfig.rightbg_bigbg, self.transformation_id)

    -- print(self.transformation_id)
    local sprite = self.assetWrapper:GetSprite(assetPath, "RightBg" .. self.transformation_id)
    if not sprite then 
        assetPath = string.format(AssetConfig.rightbg_bigbg, 2023)
        sprite = self.assetWrapper:GetSprite(assetPath, "RightBg2023")  --默认2023
    end
    self.RightConNotDataImage.sprite = sprite
    self.RightConNotDataImage:SetNativeSize()


    self:UpdateView()

    RideManager.Instance.OnUpdateRide:Add(self.onUpdateOne)
    RideManager.Instance.OnUpdateDye:Add(self.onUpdateDye)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.onUpdateItem)
end

function RideDyeWindow:__delete()
    if self.washItemSolt ~= nil then
        self.washItemSolt:DeleteMe()
        self.washItemSolt = nil
    end

    if self.rightConSprite ~= nil then
        self.rightConSprite.sprite = nil
    end

    if self.leftConSprite ~= nil then
        self.leftConSprite.sprite = nil
    end

    if self.BtnWashBuyBtn ~= nil then
        self.BtnWashBuyBtn:DeleteMe()
        self.BtnWashBuyBtn = nil
    end
    self.curRightData = nil
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.onUpdateItem)
    RideManager.Instance.OnUpdateRide:Remove(self.onUpdateOne)
    RideManager.Instance.OnUpdateDye:Remove(self.onUpdateDye)

    Tween.Instance:Cancel(self.saveFinishLocationTweenId)
    Tween.Instance:Cancel(self.saveFinishAlphaTweenId)
    Tween.Instance:Cancel(self.saveFinishLeftAlphaTweenId)

    if self.leftTimeIdPlayIdleAction ~= nil then LuaTimer.Delete(self.leftTimeIdPlayIdleAction) end
    if self.leftTimeIdPlayAction ~= nil then LuaTimer.Delete(self.leftTimeIdPlayAction) end

    if self.rightTimeIdPlayIdleAction ~= nil then LuaTimer.Delete(self.rightTimeIdPlayIdleAction) end
    if self.rightTimeIdPlayAction ~= nil then LuaTimer.Delete(self.rightTimeIdPlayAction) end
    if self.leftPreviewComposite ~= nil then
        self.leftPreviewComposite:DeleteMe()
        self.leftPreviewComposite = nil
    end

    if self.rightPreviewComposite ~= nil then
        self.rightPreviewComposite:DeleteMe()
        self.rightPreviewComposite = nil
    end

    self.OnOpenEvent:RemoveAll()
    self.isInit = false
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RideDyeWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ridedyewindow))
    self.gameObject:SetActive(false)
    self.gameObject.name = "RideDyeWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.transform = self.gameObject.transform
    -- self.transform:GetComponent(RectTransform).localPosition = Vector3.zero
    self.MainCon = self.transform:Find("MainCon")
    local closeBtn = self.MainCon:Find("CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseRideDyeWindow()
    end)
    self.gameObject:SetActive(true)

    self.leftConSprite = self.MainCon:Find("TopCon/LeftCon/ModelPanel/Mask/Bg"):GetComponent(Image)
    self.rightConSprite = self.MainCon:Find("TopCon/RightCon/ModelPanel/Mask/Bg"):GetComponent(Image)
    self.leftConSprite.sprite = self.assetWrapper:GetSprite(AssetConfig.ridebg,"RideBg")
    self.rightConSprite.sprite = self.assetWrapper:GetSprite(AssetConfig.ridebg,"RideBg")
    self.leftConSprite.color = Color.white

    --左边逻辑
    self.TopCon = self.MainCon:Find("TopCon")
    self.LeftCon = self.TopCon:Find("LeftCon")
    self.LeftModelCon = self.LeftCon:Find("ModelPanel")
    self.LeftPreview = self.LeftModelCon:Find("Preview")


    --右边逻辑
    self.RightCon = self.TopCon:Find("RightCon")
    self.RightSaveEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20260)))
    self.RightSaveEffect.transform:SetParent(self.RightCon)
    self.RightSaveEffect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.RightSaveEffect.transform, "UI")
    -- self.RightSaveEffect.transform.localScale = Vector3(0.9, 1.05, 1)
    self.RightSaveEffect.transform.localScale = Vector3(1, 1, 1)
    self.RightSaveEffect.transform.localPosition = Vector3(0, -19, -400)
    self.RightSaveEffect:SetActive(false)

    self.RightConNotData = self.TopCon:Find("RightConNotData")
    self.RightConNotDataImage = self.TopCon:Find("RightConNotData/Image"):GetComponent(Image)
    self.RightConNotDataText = self.TopCon:Find("RightConNotData/Text"):GetComponent(Text)
    self.RightConNotData.gameObject:SetActive(true)
    self.RightCon.gameObject:SetActive(false)
    self.RightModelCon = self.RightCon:Find("ModelPanel")
    self.RightPreview = self.RightModelCon:Find("Preview")

    --底部逻辑
    self.BottomCon = self.MainCon:Find("BottomCon")
     self.bottomText = self.BottomCon:Find("DyeNoActiveInfoPanel/Text"):GetComponent(Text)
    self.BottomTipsBtn = self.BottomCon:Find("RightCon/DescButton"):GetComponent(Button)
    self.BottomTipsBtn.gameObject:SetActive(false)
    self.BtnReplace = self.BottomCon:Find("RightCon/BtnReplace"):GetComponent(Button)
    self.BtnWash = self.BottomCon:Find("RightCon/BtnWash"):GetComponent(Button)
    self.ItemNumText = self.BottomCon:Find("RightCon/SlotCon/ItemNumText"):GetComponent(Text)
    self.ItemNameText = self.BottomCon:Find("RightCon/SlotCon/ItemName"):GetComponent(Text)

    self.washItemSolt = ItemSlot.New()
    UIUtils.AddUIChild(self.BottomCon:Find("RightCon/SlotCon/SlotCon").gameObject, self.washItemSolt.gameObject)

    -- self.BtnWashBuyBtn = BuyButton.New(self.BtnWash, TI18N("洗 髓"), WindowConfig.WinID.pet_wash, false)
    -- self.BtnWashBuyBtn:Show()
    self.BtnWash.onClick:AddListener(function()
        self:OnWash()
    end)


    --注册监听
    self.BtnReplace.onClick:AddListener(function()
        local dyeData = self.model:GetDyeData(self.transformation_id)
        -- BaseUtils.dump(dyeData, "dyeData")
        if dyeData ~= nil and #dyeData.cache_dye_list > 0 then
            RideManager.Instance:Send17023(self.transformation_id, self.dye_id, self.model.cur_ridedata.index)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("暂无可替换染色"))
        end
    end)
    -- self.BtnWash.onClick:AddListener(function() end)
    self.BottomTipsBtn.onClick:AddListener(function()
        local tipsData = { TI18N("使用<color='#ffff00'>星辰精华</color>进行洗髓，会出现以下效果：")
            ,TI18N("1.改变宠物的资质和技能")
            ,TI18N("2.有几率<color='#00ff00'>变异</color>，变异后洗髓有几率变回普通宠物")
            ,TI18N("3.变异后可能附带<color='#ffff00'>额外技能</color>")
            ,TI18N("4.变异后可能出现资质最大值<color='#ffff00'>突破基础上限</color>")
            ,TI18N("5.使用<color='#ffff00'>苏醒仙泉</color>洗髓必定使宠物<color='#ffff00'>发生变异</color>")
            ,TI18N("6.使用<color='#ffff00'>仙灵卷轴</color>洗髓必定使变异宠<color='#ffff00'>保持变异</color>")
            ,TI18N("7.洗髓一定次数后将会触发<color='#ffff00'>多技能保底</color>（必定获得4技能，且变异宠物不生效）")
            ,TI18N("8.当天内洗髓每消耗一定量的星辰精华，将会获得一张<color='#ffff00'>仙灵卷轴</color>")
            ,TI18N("9.专有技能<color='#ffff00'>不会</color>被学习技能/洗髓<color='#00ff00'>替换掉</color>，会一直存在")
        }
        TipsManager.Instance:ShowText({gameObject = self.BottomTipsBtn.gameObject, itemData = tipsData})
    end)

    self.isInit = true

    self:OnShow()
end

--洗练按钮点击监听
function RideDyeWindow:OnWash()
    if self.transformation_id == nil then
        return
    end

    -- self.BtnWashBuyBtn:Freeze()
    self.isClickWash = true
    RideManager.Instance:Send17022(self.transformation_id)
end

--更新
function RideDyeWindow:UpdateView()
    if self.transformation_id == nil then
        return
    end

    self:UpdateLeft()
    self:UpdateCost()
    self.BtnReplace.gameObject:SetActive(false)

    local dyeData = self.model:GetDyeData(self.transformation_id)
    if dyeData ~= nil and #dyeData.cache_dye_list > 0 then
        self.dye_id = dyeData.cache_dye_list[1].dye_id
        self.base_id = self.model.cur_ridedata.mount_base_id
        self:UpdateRight()
    end

    if self.active then
        self.BottomCon:Find("RightCon").gameObject:SetActive(true)
        self.BottomCon:Find("DyeNoActiveInfoPanel").gameObject:SetActive(false)
    else
        self.BottomCon:Find("RightCon").gameObject:SetActive(false)
        self.BottomCon:Find("DyeNoActiveInfoPanel").gameObject:SetActive(true)
        self.bottomText.text = DataMount.data_ride_dye[self.transformation_id].ridedesc
    end
end

--更新左边
function RideDyeWindow:UpdateLeft()
    --模型
    self:UpdateLeftModel()
end

--更新消耗
function RideDyeWindow:UpdateCost()
    if self.transformation_id == nil then
        return
    end
    --更新星辰精华
    local cost = DataMount.data_ride_dye[self.transformation_id].dye_cost[1]
    local itembase = BackpackManager.Instance:GetItemBase(cost[1])
    local watchItemData = ItemData.New()
    watchItemData:SetBase(itembase)
    self.washItemSolt:SetAll(watchItemData)
    local neednum = cost[2]
    local num = BackpackManager.Instance:GetItemCount(cost[1])
    self.ItemNumText.text = string.format("%s/%s", num, neednum)
    if num < neednum then
        self.ItemNumText.color = Color.red
    else
        self.ItemNumText.color = Color.green
    end
    -- self.BtnWashBuyBtn:Layout({[cost[1]] = {need = neednum}}, self.OnClickWash , nil, { antofreeze = false})

    -- self.BottomTipsBtn.gameObject.gameObject:SetActive(true)
    local data_ride_data = DataMount.data_ride_data[self.transformation_id]
    if data_ride_data ~= nil then
        -- self.RightConNotDataText.text = string.format(TI18N("使用%s个<color='#ffff00'>%s</color>可对%s进行<color='#00ff00'>染色</color>"), neednum, watchItemData.name, data_ride_data.name)
        self.RightConNotDataText.text = TI18N("每次<color='#ffff00'>染色</color>可获得<color='#00ff00'>神秘颜色</color>")
    end
end

--播放保存成功效果
function RideDyeWindow:PlaySaveFinish()
    -- self.BtnWashBuyBtn:Set_btn_txt(TI18N("染 色"))
    self.BtnReplace.gameObject:SetActive(false)
    local time = 0.3
    Tween.Instance:Cancel(self.saveFinishLocationTweenId)
    Tween.Instance:Cancel(self.saveFinishAlphaTweenId)
    Tween.Instance:Cancel(self.saveFinishLeftAlphaTweenId)
    self.saveFinishLeftAlphaTweenId = Tween.Instance:ValueChange(1, 0, time, nil, LeanTweenType.linear, function(val)
        self.LeftCon:GetComponent(CanvasGroup).alpha = val
    end).id
    self.saveFinishAlphaTweenId = Tween.Instance:ValueChange(1, 0.5, time, nil, LeanTweenType.linear, function(val)
        self.RightCon:GetComponent(CanvasGroup).alpha = val
    end).id
    self.saveFinishLocationTweenId = Tween.Instance:ValueChange(197.5, -197.5, time, self.saveFinishLocationTweened, LeanTweenType.linear, function(val)
        self.RightCon:GetComponent(RectTransform).anchoredPosition = Vector2(val, 0)
    end).id
end

--更新右边
function RideDyeWindow:UpdateRight()
    -- self.BtnWashBuyBtn:ReleaseFrozon()
    --更新底部消耗
    self:UpdateCost()
    self.BtnReplace.gameObject:SetActive(true)

    --特效
    if self.isClickWash then
        self.RightSaveEffect:SetActive(false)
        self.RightSaveEffect:SetActive(true)
        if self.effectTimeId ~= 0 then
            LuaTimer.Delete(self.effectTimeId)
            self.effectTimeId = 0
        end
        self.effectTimeId = LuaTimer.Add(1000, function()
            if self.isInit == false then
                return
            end
            self.RightSaveEffect:SetActive(false)
        end)
        self.isClickWash = false
    end

    local cost = DataMount.data_ride_dye[self.transformation_id].dye_cost[1]
    local neednum = cost[2]
    local num = BackpackManager.Instance:GetItemCount(cost[1])
    -- if num >= neednum then
    --     self.BtnWashBuyBtn:Set_btn_txt(TI18N("继续染色"))
    -- else
    --     self.BtnWashBuyBtn:Set_btn_txt(TI18N("染 色"))
    -- end

    self.RightConNotData.gameObject:SetActive(false)
    self.RightCon.gameObject:SetActive(true)

    self:UpdateRightModel()
end

-------------------模型逻辑
--更新左边模型
function RideDyeWindow:UpdateLeftModel()
    local base_id = self.model:GetTransformationDye(self.transformation_id)
    local _scale = DataMount.data_ride_data[base_id].scale / 100 
    local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = _scale, effects = {}}
    table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val = base_id })

    self:LoadLeftpreview(self.LeftPreview, data)
end

function RideDyeWindow:LoadLeftpreview(modelPreview, data)
    if not BaseUtils.sametab(data, self.leftModelData) then
        self.leftModelData = data
        self.leftModelPreview = modelPreview
        local leftModelData = BaseUtils.copytab(self.leftModelData)
        self.leftPreviewComposite:Reload(data, function(composite) self:LoadedLeftPreview(composite) end)
    else
        self.leftModelPreview = modelPreview
        local rawImage = self.leftPreviewComposite.rawImage
        rawImage.transform:SetParent(self.leftModelPreview)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
    end
end

function RideDyeWindow:LoadedLeftPreview(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.leftModelPreview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.Euler(-10,0,0)
    composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    if self.leftTimeIdPlayIdleAction ~= nil then LuaTimer.Delete(self.leftTimeIdPlayIdleAction) end
    -- self.leftTimeIdPlayIdleAction = LuaTimer.Add(0, 15000, function() self:PlayLeftIdleAction() end)
    -- self:showmodeleffectlist()
end

function RideDyeWindow:PlayLeftIdleAction()
    if self.leftTimeIdPlayAction == nil and self.leftPreviewComposite ~= nil and self.leftPreviewComposite.tpose ~= nil and self.leftModelData ~= nil then
        local animationData = DataAnimation.data_npc_data[self.leftModelData.animationId]
        self.leftPreviewComposite:PlayMotion(FighterAction.Idle)
    end
end

--更新左边模型
function RideDyeWindow:UpdateRightModel()
    local _scale = DataMount.data_ride_data[self.dye_id].scale / 100 
    local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = _scale, effects = {}}
    table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val = self.dye_id })

    self:LoadRightpreview(self.RightPreview, data)
end

function RideDyeWindow:LoadRightpreview(modelPreview, data)
    if not BaseUtils.sametab(data, self.rightModelData) then
        self.rightModelData = data
        self.rightModelPreview = modelPreview
        local rightModelData = BaseUtils.copytab(self.rightModelData)
        self.rightPreviewComposite:Reload(data, function(composite) self:LoadedRightPreview(composite) end)
    else
        self.rightModelPreview = modelPreview
        local rawImage = self.rightPreviewComposite.rawImage
        rawImage.transform:SetParent(self.rightModelPreview)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
    end
end

function RideDyeWindow:LoadedRightPreview(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.rightModelPreview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.Euler(-10,0,0)
    composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
    if self.rightTimeIdPlayIdleAction ~= nil then LuaTimer.Delete(self.rightTimeIdPlayIdleAction) end
    -- self.rightTimeIdPlayIdleAction = LuaTimer.Add(0, 20000, function() self:PlayRightIdleAction() end)
    -- self:showmodeleffectlist()
end

function RideDyeWindow:PlayRightIdleAction()
    if self.rightTimeIdPlayAction == nil and self.rightPreviewComposite ~= nil and self.rightPreviewComposite.tpose ~= nil and self.rightModelData ~= nil then
        local animationData = DataAnimation.data_npc_data[self.rightModelData.animationId]
        self.rightPreviewComposite:PlayMotion(FighterAction.Idle)
    end
end

function RideDyeWindow:UpdateTmpAttr(base_id, dye_id)
    if self.transformation_id == nil then
        return
    end

    self.dye_id = dye_id
    self.base_id = base_id

    self:UpdateRight()
end