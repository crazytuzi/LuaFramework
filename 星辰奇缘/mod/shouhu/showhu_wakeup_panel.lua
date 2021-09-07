--author:zzl
--time:2016/11/3
--守护

ShouhuWakeUpPanel= ShouhuWakeUpPanel or BaseClass(BasePanel)

function ShouhuWakeUpPanel:__init(parent)
    self.parent = parent
    self.model = parent.model
    self.resList = {
        {file = AssetConfig.shouhu_wakeup_panel, type = AssetType.Main}
        -- ,{file = AssetConfig.shouhu_wakeup_big_bg, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = AssetConfig.shouhu_texture, type = AssetType.Dep}
        ,{file = AssetConfig.attr_icon, type = AssetType.Dep}

        ,{file = string.format(AssetConfig.effect, 20200), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}--最近需要激活的星位

        ,{file = string.format(AssetConfig.effect, 20201), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20202), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20203), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20204), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20205), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20206), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20207), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20208), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20218), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20219), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20220), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20161), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20210), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}


        ,{file = string.format(AssetConfig.effect, 20211), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }
    self.pointEffectUnActiveGreen = nil
    self.pointEffectUnActiveBlue = nil
    self.pointEffectUnActivePurple = nil
    self.pointEffectUnActiveOrange = nil
    self.pointEffectActivingGreen = nil  -- 20201
    self.pointEffectActivingBlue = nil  -- 20202
    self.pointEffectActivingPurple = nil  -- 20203
    self.pointEffectActivingOrange = nil  -- 20204
    self.pointEffectActivedGreenList = nil  -- 20205
    self.pointEffectActivedBlueList = nil  -- 20206
    self.pointEffectActivedPurpleList = nil  -- 20207
    self.pointEffectActivedOrangeList = nil  -- 20208

    self.pointEffect20218 = nil
    self.pointEffect20219 = nil
    self.pointEffect20220 = nil
    self.pointEffect20210 = nil
    self.pointEffect20211 = nil
    self.hasInit = false
    self.MapTransformList = nil
    self.MapPoint = nil
    self.GridLinesX = nil
    self.mapQualityName = {TI18N("绿"), TI18N("蓝"), TI18N("紫"), TI18N("橙"), TI18N("红")}
    --绿  蓝  紫  橙
    self.greenPos = {1, 2, 3, 4}
    self.bluePos = {1, 2, 3, 4, 5}
    self.purplePos = {1, 2, 3, 4, 5, 6}
    self.orangePos = {1, 2, 3, 4, 5, 6, 7}
    self.lastSelectMapType = 0
    self.rightConditionList = nil
    self.timerId = 0
    self.chargeTimerId = 0
    self.switchMapTimerId = 0
    self.playNextUnActiveTimerId = 0
    self.playStoneActiveTimerId = 0
    self.playMapPointTimerId = 0
    self.rotateTimerId = 0
    self.hideRewardTimerId = 0
    self.Bottomstate = 3
    self.curData = nil
    self.lastData = nil
    self.lastSocketData = nil
    self.curSocketData = nil
    self.curChargeStarIndex = 0
    self.ConditionAttrItemList = nil
    self.advanceRightSlot = nil
    self.OnUpdateListener = function(data)
        self:UpdateSocketBack(data)
    end
    self.OnPlayLightListener = function(data)
        if self.hasInit == false then
            return
        end
        if data.op_code > 1 then
            self.ChargeRewardImg.gameObject:SetActive(true)
            self.ImgRewardTxt.text = string.format("X%s", data.op_code)
            self:PlayChargeRewardEffect() -- 播放多倍奖励特效
            if self.hideRewardTimerId ~= 0 then
                LuaTimer.Delete(self.hideRewardTimerId)
                self.hideRewardTimerId = 0
            end
            self.hideRewardTimerId = LuaTimer.Add(3000, function()
                LuaTimer.Delete(self.hideRewardTimerId)
                self.hideRewardTimerId = 0
                self.ChargeRewardImg.gameObject:SetActive(false)
            end)
        else
            self.ChargeRewardImg.gameObject:SetActive(false)
        end
    end
    self.OnHideEvent:AddListener(function()
        if self.pointEffectUnActiveGreen ~= nil then
            self.pointEffectUnActiveGreen:SetActive(false)
        end
        if self.pointEffectUnActiveBlue ~= nil then
            self.pointEffectUnActiveBlue:SetActive(false)
        end
        if self.pointEffectUnActivePurple ~= nil then
            self.pointEffectUnActivePurple:SetActive(false)
        end
        if self.pointEffectUnActiveOrange ~= nil then
            self.pointEffectUnActiveOrange:SetActive(false)
        end
    end)
    self.OnOpenEvent:AddListener(function()

    end)

    self.downFun = function(go)
        if self.hasInit then
            if math.floor(go.transform:GetComponent(RectTransform).anchoredPosition.y) <= -2 then
                Tween.Instance:MoveLocalY(go, 2, 0.4, function() self.upFun(go) end, LeanTweenType.linear)
            end
        end
    end

    self.upFun = function(go)
        if self.hasInit then
            if math.ceil(go.transform:GetComponent(RectTransform).anchoredPosition.y) >= 2 then
                Tween.Instance:MoveLocalY(go, -2, 0.4, function() self.downFun(go) end, LeanTweenType.linear)
            end
        end
    end

    self.hasInit = false
    return self
end

function ShouhuWakeUpPanel:__delete()
    self.hasInit = false
    EventMgr.Instance:RemoveListener(event_name.shouhu_wakeup_update, self.OnUpdateListener)
    EventMgr.Instance:RemoveListener(event_name.shouhu_wakeup_point_light, self.OnPlayLightListener)
    if self.btnchargeImage ~= nil then
        BaseUtils.ReleaseImage(self.btnchargeImage)
    end
    --self.ChargeCon:FindChild("RightCon"):FindChild("BtnCharge"):GetComponent(Image).sprite = nil
    if self.MapPoint ~= nil then
        for _,v in pairs(self.MapPoint) do
            for _,point in pairs(v) do
                if point ~= nil and point.transform:FindChild("ImgLine") ~= nil then
                    point.transform:FindChild("ImgLine"):GetComponent(Image).sprite = nil
                end
            end
        end
    end
    if self.ConditionAttrItemList ~= nil then
        for _,item in pairs(self.ConditionAttrItemList) do
            item.transform:Find("ImgIcon"):GetComponent(Image).sprite = nil
        end
    end
    if self.rightConditionList ~= nil then
        for _,item in pairs(self.rightConditionList) do
            item.transform:Find("Img1"):GetComponent(Image).sprite = nil
        end
    end
    if self.activeSlot ~= nil  then
        self.activeSlot:DeleteMe()
        self.activeSlot = nil
    end
    if self.advancedSlot ~= nil  then
        self.advancedSlot:DeleteMe()
        self.advancedSlot = nil
    end
    if self.chargeSlot ~= nil  then
        self.chargeSlot:DeleteMe()
        self.chargeSlot = nil
    end
    self.curChargeStarIndex = 0
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
    if self.chargeTimerId ~= 0 then
        LuaTimer.Delete(self.chargeTimerId)
        self.chargeTimerId = 0
    end
    if self.switchMapTimerId ~= 0 then
        LuaTimer.Delete(self.switchMapTimerId)
        self.switchMapTimerId = 0
    end
    if self.playNextUnActiveTimerId ~= 0 then
        LuaTimer.Delete(self.playNextUnActiveTimerId)
        self.playNextUnActiveTimerId = 0
    end
    if self.playStoneActiveTimerId ~= 0 then
        LuaTimer.Delete(self.playStoneActiveTimerId)
        self.playStoneActiveTimerId = 0
    end
    if self.playMapPointTimerId ~= 0 then
        LuaTimer.Delete(self.playMapPointTimerId)
        self.playMapPointTimerId = 0
    end
    if self.rotateTimerId ~= 0 then
        LuaTimer.Delete(self.rotateTimerId)
        self.rotateTimerId = 0
    end
    if self.hideRewardTimerId ~= 0 then
        LuaTimer.Delete(self.hideRewardTimerId)
        self.hideRewardTimerId = 0
    end
    if self.advanceRightSlot ~= nil then
        self.advanceRightSlot:DeleteMe()
        self.advanceRightSlot = nil
    end
    self.OnHideEvent:DeleteMe()
    self.OnHideEvent = nil
    self.OnOpenEvent:DeleteMe()
    self.OnOpenEvent = nil
    self.pointEffectUnActiveGreen = nil
    self.pointEffectUnActiveBlue = nil
    self.pointEffectUnActivePurple = nil
    self.pointEffectUnActiveOrange = nil
    self.pointEffectActivingGreen = nil  -- 20201
    self.pointEffectActivingBlue = nil  -- 20202
    self.pointEffectActivingPurple = nil  -- 20203
    self.pointEffectActivingOrange = nil  -- 20204

    self.pointEffectActivedGreenList = nil
    self.pointEffectActivedBlueList = nil
    self.pointEffectActivedPurpleList = nil
    self.pointEffectActivedOrangeList = nil

    self.pointEffect20218 = nil
    self.pointEffect20219 = nil
    self.pointEffect20220 = nil
    self.pointEffect20210 = nil
    self.pointEffect20211 = nil
    self.rightConditionList = nil
    self.secBg.sprite = nil
    self.greenPos = nil
    self.bluePos = nil
    self.purplePos = nil
    self.orangePos = nil
    self.GridLinesX = nil
    self.curData = nil
    self.lastData = nil
    self.lastSocketData = nil
    self.curSocketData = nil
    self.ConditionAttrItemList = nil
    self.advanceRightSlot = nil
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self.MapTransformList = nil
    self.MapPoint = nil
    self:AssetClearAll()
end

function ShouhuWakeUpPanel:InitPanel()
    -- 星阵tab
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_wakeup_panel))
    self.gameObject.name = "ShouhuWakeUpPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.mainObj, self.gameObject)
    self.mainCon = self.transform:FindChild("Main")
    self.CloseOpen = self.mainCon:FindChild("CloseOpen")
    self.OpenCon = self.mainCon:FindChild("OpenCon")
    self.secBg = self.OpenCon:FindChild("ImgSecBg"):GetComponent(Image)
    -- self.secBg.sprite = self.assetWrapper:GetSprite(AssetConfig.shouhu_wakeup_big_bg, "ShouhuWakeUpbg")
    self.secBg.gameObject:SetActive(false)
    self.TopCon = self.OpenCon:FindChild("TopCon")
    self.PointsBg = self.TopCon:FindChild("PointsBg")
    self.RightConTitleTxt = self.TopCon:FindChild("RightCon"):FindChild("ImgTitle"):FindChild("Text"):GetComponent(Text)
    self.nextGradeBtn = self.TopCon:FindChild("RightCon/NextGrade"):GetComponent(Button)
    self.rightConditionList = {}
    for i = 1, 7 do
        local condtion = self.TopCon:FindChild("RightCon"):FindChild("ConditionConActive"):FindChild(string.format("Condition%s", i))
        condtion.anchoredPosition = Vector2(0,(125-36*i))
        local conItem = self:CreateConditionItem(condtion)
        table.insert(self.rightConditionList, conItem)
    end

    self.ConditionConAdvanced = self.TopCon:FindChild("RightCon"):FindChild("ConditionConAdvanced").gameObject
    self.ConditionConActive = self.TopCon:FindChild("RightCon"):FindChild("ConditionConActive").gameObject
    self.ConditionConFullLev = self.TopCon:FindChild("RightCon"):FindChild("ConditionConFullLev").gameObject
    self.ConditionConCharge = self.TopCon:FindChild("RightCon"):FindChild("ConditionConCharge").gameObject
    self.ConditionTxtGrowth = self.TopCon:FindChild("RightCon"):FindChild("ConditionConCharge"):FindChild("TxtGrowth"):GetComponent("Text")
    self.ConditionTxtGrowthVal = self.TopCon:FindChild("RightCon"):FindChild("ConditionConCharge"):FindChild("TxtGrowthVal"):GetComponent("Text")
    self.ConditionMaskCon = self.TopCon:FindChild("RightCon"):FindChild("ConditionConCharge"):FindChild("MaskCon")
    self.ConditionScrollCon = self.ConditionMaskCon:FindChild("ScrollCon")
    self.ConditionContainer = self.ConditionScrollCon:FindChild("Container")
    self.ConditionAttrItem = self.ConditionContainer:FindChild("AttrItem").gameObject
    self.ConditionAttrItem.gameObject:SetActive(false)
    self.ConditionConCharge:SetActive(false)
    self.ConditionConAdvanced:SetActive(false)
    self.ConditionConActive:SetActive(false)
    self.ConditionConFullLev:SetActive(false)
    self.ConditionAttrItemList = {}

    self.TxtTile = self.TopCon:FindChild("TitleBg"):FindChild("TxtTile"):GetComponent(Text)
    self.SwitchMapEffectCon = self.TopCon:FindChild("Map0")
    self.MapPoint = {}
    self.MapTransformList = {}
    for i=1, 4 do
        table.insert(self.MapTransformList, self.TopCon:FindChild(string.format("Map%s", i)))
    end

    self.BottomCon = self.OpenCon:FindChild("BottomCon")
    self.ActiveCon = self.BottomCon:FindChild("ActiveCon")
    self.BtnActive = self.ActiveCon:FindChild("RightCon"):FindChild("BtnActive"):GetComponent(Button)
    local activeSlotCon = self.ActiveCon:FindChild("RightCon"):FindChild("SlotCon").gameObject
    self.activeSlot = self:CreateSlot(activeSlotCon)

    self.AdvancedCon = self.BottomCon:FindChild("AdvancedCon")
    self.BtnAdvanced = self.AdvancedCon:FindChild("RightCon"):FindChild("BtnAdvanced"):GetComponent(Button)
    local advancedSlotCon = self.AdvancedCon:FindChild("RightCon"):FindChild("SlotCon").gameObject
    self.advancedSlot = self:CreateSlot(advancedSlotCon)

    self.FullLevCon = self.BottomCon:FindChild("FullLevCon")

    self.ChargeCon = self.BottomCon:FindChild("ChargeCon")
    self.ChargeConGrid = self.ChargeCon:FindChild("LeftCon")
    self.ChargeConGridBtn = self.ChargeCon:FindChild("ImgChargeBtn"):GetComponent(Button)
    local effectBar = self:GetEffect(self.ChargeConGrid:FindChild("GridCon"):FindChild("ImgBar"):FindChild("EffectCon"), 20161)
    effectBar.transform.localPosition = Vector3(0, 0, -400)
    effectBar.gameObject:SetActive(true)
    self.ChargeImgBarRect = self.ChargeConGrid:FindChild("GridCon"):FindChild("ImgBar"):GetComponent(RectTransform)
    self.ChargeImgBarRectX = self.ChargeConGrid:FindChild("GridCon"):FindChild("ImgBar"):GetComponent(RectTransform).anchoredPosition.x
    self.GridLinesX = {}
    for i=1,10 do
        table.insert(self.GridLinesX, self.ChargeConGrid:FindChild("GridCon"):FindChild(string.format("ImgLine%s", i)):GetComponent(RectTransform).anchoredPosition.x)
    end
    self.ChargeRewardImg = self.ChargeConGrid:FindChild("GridCon"):FindChild("ImgReward")
    self.ImgRewardTxt = self.ChargeRewardImg:FindChild("Text"):GetComponent(Text)
    self.ImgRewardTxt.text = ""
    local chargeSlotCon = self.ChargeCon:FindChild("RightCon"):FindChild("SlotCon").gameObject
    self.chargeSlot = self:CreateSlot(chargeSlotCon)
    self.BtnCharge = self.ChargeCon:FindChild("RightCon"):FindChild("BtnCharge"):GetComponent(Button)

    self.BtnActive.onClick:AddListener(function()
        --检查道具够不够
        local tempQuality = self.curData.quality == self.model.wakeUpMaxQuality and self.model.wakeUpMaxQuality - 1 or self.curData.quality --达到最大
        local wakeUpActiveCostData = DataShouhu.data_guard_wakeup_active[string.format("%s_%s", self.curData.base_id, tempQuality)]
        local base_id = wakeUpActiveCostData.cost[1][1]
        local hasNum = BackpackManager.Instance:GetItemCount(base_id)
        local needNum = wakeUpActiveCostData.cost[1][2]
        if needNum > hasNum then
            local base_data = DataItem.data_get[base_id]
            local info = {itemData = base_data, gameObject = self.BtnActive.gameObject}
            TipsManager.Instance:ShowItem(info)
        end
        ShouhuManager.Instance:request10913(self.curData.base_id)
    end)
    self.BtnCharge.onClick:AddListener(function()
        if self.ChargeProgBarEnough then
            NoticeManager.Instance:FloatTipsByString(TI18N("能量已满，请点击能量条激活"))
            return
        end

        --检查道具够不够
        local nextWakeUpCfgData = DataShouhu.data_guard_wakeup[string.format("%s_%s_%s", self.curData.base_id, self.curChargeStarIndex, self.curData.quality)]
        if nextWakeUpCfgData ~= nil then
            local base_id = nextWakeUpCfgData.cost[1][1]
            local hasNum = BackpackManager.Instance:GetItemCount(base_id)
            local needNum = nextWakeUpCfgData.cost[1][2]
            if needNum > hasNum then
                local base_data = DataItem.data_get[base_id]
                local info = {itemData = base_data, gameObject = self.BtnCharge.gameObject}
                TipsManager.Instance:ShowItem(info)
            end
        end
        ShouhuManager.Instance:request10914(self.curData.base_id, self.curChargeStarIndex)
    end)
    self.BtnAdvanced.onClick:AddListener(function()
        --检查道具够不够
        --可以进阶，显示进阶容器
        local upgradeCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", self.curData.base_id, self.curData.quality+1)]
        local base_id = upgradeCfgData.cost[1][1]
        local hasNum = BackpackManager.Instance:GetItemCount(base_id)
        local needNum = upgradeCfgData.cost[1][2]
        if needNum > hasNum then
            local base_data = DataItem.data_get[base_id]
            local info = {itemData = base_data, gameObject = self.BtnAdvanced.gameObject}
            TipsManager.Instance:ShowItem(info)
        end
        ShouhuManager.Instance:request10915(self.curData.base_id)
    end)
    self.ChargeConGridBtn.onClick:AddListener(function()
        if self.ChargeProgBarEnough then
            ShouhuManager.Instance:request10914(self.curData.base_id, self.curChargeStarIndex)
        end
    end)
    self.hasInit = true

    EventMgr.Instance:AddListener(event_name.shouhu_wakeup_update, self.OnUpdateListener)
    EventMgr.Instance:AddListener(event_name.shouhu_wakeup_point_light, self.OnPlayLightListener)
    if self.parent.last_selected_item ~= nil then
        self:UpdateContent(self.parent.last_selected_item.data)
    end

    self.rotateTimerId = LuaTimer.Add(0, 20, function()
        self.PointsBg:Rotate(Vector3(0, 0, -0.5))
    end)

    self.nextGradeBtn.onClick:AddListener(function() self:ShowNext() end)
end

function ShouhuWakeUpPanel:UpdateContent(data)
    if self.hasInit == false then
        return
    end
    if data.war_id == nil then
        self.CloseOpen.gameObject:SetActive(true)
        self.OpenCon.gameObject:SetActive(false)
        return
    else
        self.CloseOpen.gameObject:SetActive(false)
        self.OpenCon.gameObject:SetActive(true)
    end
    self.curData = data
    self:UpdateSocketBack(self.model.wakeUpDataSocketDic[data.base_id])
    -- ShouhuManager.Instance:request10916(data.base_id)
end

--根据协议更新面板显示
function ShouhuWakeUpPanel:UpdateSocketBack(socketData)
    if self.hasInit == false then
        return
    end

    self.curSocketData = socketData
    self.ActiveCon.gameObject:SetActive(false)
    self.ChargeCon.gameObject:SetActive(true)
    self.AdvancedCon.gameObject:SetActive(false)
    self.TxtTile.text = ColorHelper.color_item_name(self.curData.quality, string.format("%s%s%s", self.curData.alias, self.mapQualityName[self.curData.quality], TI18N("阶魂石")))

    --找到最近未激活的星位
    self.curChargeStarIndex = 0
    local upgradeNeedNum = self.model:GetWakeUpNeedPointNum(self.curData)
    if upgradeNeedNum >= #self.curSocketData.aroused then
        for i=1,upgradeNeedNum do
            if self.curSocketData.aroused[i] ~= nil then
                if self.curSocketData.aroused[i].lev < self.curData.quality then
                    self.curChargeStarIndex = i
                    break
                end
            else
                self.curChargeStarIndex = i
                break
            end
        end
    end

    --设置底部和右部状态
    self.Bottomstate = 3
    if self.curSocketData.active < self.curData.quality then
        --激活
        self.Bottomstate = 1
    else
        if self.curSocketData.aroused[upgradeNeedNum] == nil or self.curSocketData.aroused[upgradeNeedNum].lev < self.curData.quality then
            self.Bottomstate = 2 --充能
        else
            self.Bottomstate = 3 --进阶
        end
    end
    if self.curData.quality == self.model.wakeUpMaxQuality then
        self.Bottomstate = 4 --已经达到最大等级
    end

    --同个守护，星阵阶数不同，则说明进阶了，播放阵位进阶切换特效
    if self.curData ~= nil and self.lastData ~= nil  and self.lastData.base_id == self.curData.base_id and self.lastData.quality ~= self.curData.quality then
        self:PlayLightEffect(self.lastData.quality, 0, function()
            self:UpdateMap(self.curData.quality)
            self.model:CloseShouhuMainUI()
            local cfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", self.curData.base_id, self.curData.quality)]
            BaseUtils.dump(cfgData, "升阶")
            if cfgData ~= nil and cfgData.model ~= 0 and cfgData.skin ~= 0 and cfgData.animation ~= 0 then
                local baseData = DataShouhu.data_guard_base_cfg[self.curData.base_id]
                local args = {}
                args.data = {skin = cfgData.skin , model = cfgData.model , animation = cfgData.animation, quality = self.curData.quality, base_id = self.lastData.base_id , lastData = self.lastData}
                args.name = ColorHelper.color_item_name(self.curData.quality, baseData.alias)
                args.callback = function()
                    ShouhuManager.Instance.model:OpenShouhuMainUI()
                end
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guardianWakeupLook, args)
            else
                local baseData = DataShouhu.data_guard_base_cfg[self.curData.base_id]
                local args = {}
                args.data = {skin = baseData.paste_id , model = baseData.res_id , animation = baseData.animation_id, quality = self.curData.quality, base_id = self.lastData.base_id, lastData = self.lastData}
                args.name = ColorHelper.color_item_name(self.curData.quality, baseData.alias)
                args.callback = function()
                    ShouhuManager.Instance.model:OpenShouhuMainUI()
                end
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guardianWakeupLook, args)
            end
        end)
    else
        self:UpdateMap(self.curData.quality)
    end

    self:SwitchBottomState(self.Bottomstate)
    self:SwitchRightState(self.Bottomstate)

    self.lastData = self.curData
    self.lastSocketData = self.curSocketData

    self.nextGradeBtn.gameObject:SetActive(DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", self.curData.base_id, self.curData.quality + 1)] ~= nil)
end

--根据传入的星阵类型，设置星阵数据
function ShouhuWakeUpPanel:UpdateMap(argType)
    local mapType = argType == self.model.wakeUpMaxQuality and self.model.wakeUpMaxQuality - 1 or argType
    self:HideActiveEffect()
    if self.MapTransformList[self.lastSelectMapType] ~= nil and self.lastSelectMapType ~= mapType then
        self.MapTransformList[self.lastSelectMapType].gameObject:SetActive(false)
    end
    local mapTrans = self.MapTransformList[mapType]
    if self.MapPoint[mapType] == nil then
        self.MapPoint[mapType] = {}
        self.MapPoint[mapType][100] = mapTrans:FindChild("ImgBigStone")
        Tween.Instance:MoveLocalY(self.MapPoint[mapType][100].gameObject, -2, 0.4, function() self.downFun(self.MapPoint[mapType][100].gameObject) end, LeanTweenType.linear)
        self.MapPoint[mapType][99] = mapTrans:FindChild("PointCon")
        self.MapPoint[mapType][0] = mapTrans:FindChild("PointCon"):FindChild("ImgStartCon")
        self.MapPoint[mapType][0]:GetComponent(Button).onClick:AddListener(function()
            self:OnClickPoint(mapType, 0)
        end)
        local pointNum = mapType + 4
        if pointNum > self.model.wakeUpMaxPoint then
            pointNum = self.model.wakeUpMaxPoint
        end
        for i=1, pointNum do
            self.MapPoint[mapType][i] = mapTrans:FindChild("PointCon"):FindChild(string.format("ImgPoint%s", i))
            self.MapPoint[mapType][i]:FindChild("PointStateCon"):GetComponent(Button).onClick:AddListener(function()
                self:OnClickPoint(mapType, i)
            end)
        end
    end

    local tempQuality = self.curData.quality == self.model.wakeUpMaxQuality and self.model.wakeUpMaxQuality - 1 or self.curData.quality

    local attrData = self.model:GetGuardWakeupUpgrade(self.curData.base_id, tempQuality)

    local tempStr = KvData.attr_name[attrData.attr]
    if attrData.attr == 43 then
        tempStr = TI18N("治疗")
    end
    self:SetPointProp(self.MapPoint[mapType][0], string.format(TI18N("<color='#ffff00'>角色%s+%s</color>"), tempStr, attrData.val))

    if self.playMapPointTimerId ~= 0 then
        LuaTimer.Delete(self.playMapPointTimerId)
        self.playMapPointTimerId = 0
    end

    if self.lastSocketData ~= nil and self.lastSocketData.base_id == self.curSocketData.base_id and self.lastSocketData.active < self.curSocketData.active  then
        --同一只守护，前后激活等级不同，则说明刚激活过
        --刚激活过
        self.MapPoint[mapType][99].gameObject:SetActive(false)
        for i=1,mapType+4 do
            self.MapPoint[mapType][i].gameObject:SetActive(false)
        end
        mapTrans.gameObject:SetActive(true)
        self:PlayStoneActiveEffect(mapTrans)
        if self.playStoneActiveTimerId ~= 0 then
            LuaTimer.Delete(self.playStoneActiveTimerId)
            self.playStoneActiveTimerId = 0
        end
        local tickTime = 0
        self.playStoneActiveTimerId = LuaTimer.Add(0, 500, function()
            tickTime = tickTime + 500
            if tickTime == 1500 then
                self.MapPoint[mapType][100].gameObject:SetActive(false)
                local tempPosition = self.MapPoint[mapType][0]:GetComponent(RectTransform).anchoredPosition
                self.pointEffect20211.transform.localPosition = Vector3(tempPosition.x, tempPosition.y, -400)
            end
            if tickTime == 2500 then
                if self.playStoneActiveTimerId ~= 0 then
                    LuaTimer.Delete(self.playStoneActiveTimerId)
                    self.playStoneActiveTimerId = 0
                end
                self.pointEffect20211:SetActive(false)
                self.MapPoint[mapType][99].gameObject:SetActive(true)
                --播放地图装逼出现
                local countIndex = mapType+4
                self.timer_id = LuaTimer.Add(0, 100, function()
                    if countIndex <= 0 then --停止
                        if self.playMapPointTimerId ~= 0 then
                            LuaTimer.Delete(self.playMapPointTimerId)
                            self.playMapPointTimerId = 0
                        end
                    else
                        self.MapPoint[mapType][countIndex].gameObject:SetActive(true)
                        countIndex = countIndex - 1
                    end
                end)
            end
        end)
    else
        mapTrans.gameObject:SetActive(true)
        --设置第一个阵点，如果品阶和配置一样，则是第一个阵法
        for i=1,mapType+4 do
            self.MapPoint[mapType][i].gameObject:SetActive(true)
        end
        if self.curData.quality == self.model.wakeUpMaxQuality then
            --达到最大
            self.MapPoint[mapType][99].gameObject:SetActive(true)
            self.MapPoint[mapType][100].gameObject:SetActive(false)
        elseif self.curSocketData.active < self.curData.quality then
            --需要激活
            self.MapPoint[mapType][99].gameObject:SetActive(false)
            self.MapPoint[mapType][100].gameObject:SetActive(true)
        else
            --无需激活
            self.MapPoint[mapType][99].gameObject:SetActive(true)
            self.MapPoint[mapType][100].gameObject:SetActive(false)
        end
    end
    self.lastSelectMapType = mapType

    --设置其他阵点
    local points = self.MapPoint[mapType]
    local tempQuality = self.curData.quality == self.model.wakeUpMaxQuality and self.model.wakeUpMaxQuality - 1 or self.curData.quality
    for i=1,#points do
        if self.curSocketData.aroused[i] ~= nil then
            if self.curSocketData.aroused[i].lev < tempQuality then
                self:SetPointState(points[i], false) --未激活
                self:SetLineColor(points[i]:FindChild("ImgLine"):GetComponent(Image), self.curData.quality, true) --未激活
            else
                self:SetPointState(points[i], true) --已激活
                self:SetLineColor(points[i]:FindChild("ImgLine"):GetComponent(Image), self.curData.quality, false) --已激活
                self:PlayActivedEffect(points[i], mapType, i)--播放已激活特效
            end
        else
            self:SetPointState(points[i], false) --未激活
            self:SetLineColor(points[i]:FindChild("ImgLine"):GetComponent(Image), self.curData.quality, true) --未激活
        end
        local wakeUpCfgData = DataShouhu.data_guard_wakeup[string.format("%s_%s_%s", self.curData.base_id, i, tempQuality)]
        if wakeUpCfgData ~= nil then
            -- print(self.model:KeepPointNum(wakeUpCfgData.showGrowth/1000))
            self:SetPointProp(points[i], string.format("%s%s", TI18N("成长"), self.model:KeepPointNum(wakeUpCfgData.showGrowth/1000))) --设置 星点的属性加成状态
        end
    end

    local doCheckPlayUnActiveFunc = function()
        local unActiveIndex = self.curChargeStarIndex
        if self.curData.quality == self.model.wakeUpMaxQuality then
            unActiveIndex = 100
        end
        if self.curChargeStarIndex == 0 then
            if self.Bottomstate == 3 then --进阶
                self:PlayUnActiveEffect(points[unActiveIndex], mapType)--播放未激活特效
            else
                self:HideUnActiveEffect()
            end
        else
            self:PlayUnActiveEffect(points[unActiveIndex], mapType)--播放未激活特效
        end
    end

    if self.lastData ~= nil and self.lastData.base_id == self.curData.base_id then
        --检查充能能量进度是否有变化
        local doPlayEffect = false
        local doPlayEffectIndex = 0
        if self.lastSocketData ~= nil and self.curSocketData ~= nil then
            if #self.lastSocketData.aroused == #self.curSocketData.aroused then
                for i = 1, #self.curSocketData.aroused do
                    local tempLastData = self.lastSocketData.aroused[i]
                    local tempCurData = self.curSocketData.aroused[i]
                    if tempLastData.lev ~= tempCurData.lev then
                        doPlayEffect = true
                        doPlayEffectIndex = i
                        break
                    end
                end
            end
        end
        if doPlayEffect and doPlayEffectIndex ~= 0 then
            self:PlayLightEffect(self.curData.quality, doPlayEffectIndex)

            local cfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", self.curData.base_id, self.curData.quality)]
            if cfgData ~= nil and cfgData.model ~= 0 and cfgData.skin ~= 0 and cfgData.animation ~= 0 then
                local baseData = DataShouhu.data_guard_base_cfg[self.curData.base_id]
                local args = {}
                args.data = {skin = cfgData.skin , model = cfgData.model , animation = cfgData.animation, quality = self.curData.quality, curChargeStarIndex = self.curChargeStarIndex, base_id = self.curData.base_id , curData = self.curData, lastData = self.lastData}
                args.name = ColorHelper.color_item_name(self.curData.quality, baseData.alias)
                args.callback = function()
                    ShouhuManager.Instance.model:OpenShouhuMainUI()
                end
                self.model:OpenGetWakeUpLookPointWindow(args)
            else
                local baseData = DataShouhu.data_guard_base_cfg[self.curData.base_id]
                local args = {}
                args.data = {skin = baseData.paste_id , model = baseData.res_id , animation = baseData.animation_id, quality = self.curData.quality, curChargeStarIndex = self.curChargeStarIndex, base_id = self.curData.base_id, curData = self.curData, lastData = self.lastData}
                args.name = ColorHelper.color_item_name(self.curData.quality, baseData.alias)
                args.callback = function()
                    ShouhuManager.Instance.model:OpenShouhuMainUI()
                end
                self.model:OpenGetWakeUpLookPointWindow(args)
            end

            if self.playNextUnActiveTimerId ~= 0 then
                LuaTimer.Delete(self.playNextUnActiveTimerId)
                self.playNextUnActiveTimerId = 0
            end
            self.playNextUnActiveTimerId = LuaTimer.Add(1200, function()
                LuaTimer.Delete(self.playNextUnActiveTimerId)
                self.playNextUnActiveTimerId = 0
                doCheckPlayUnActiveFunc()
            end)
        else
            if self.playNextUnActiveTimerId == 0 then
                doCheckPlayUnActiveFunc()
            end
        end
    else
        doCheckPlayUnActiveFunc()
    end
end

--点击星位弹出tips
function ShouhuWakeUpPanel:OnClickPoint(mapType, pointIndex)
    local tempQuality = self.curData.quality == self.model.wakeUpMaxQuality and self.model.wakeUpMaxQuality - 1 or self.curData.quality
    local args = {base_id = self.curData.base_id, quality = tempQuality, pointIndex = pointIndex}
    self.model:OpenWakeupPointTips(args)
end

--播放星点亮成功特效
function ShouhuWakeUpPanel:PlayLightEffect(quality, pointIndex, callBack)
    if self.hasInit == false then
        return
    end
    --播放激活特效
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
    end

    self:PlayActivingEffect(self.MapPoint[quality][pointIndex], quality)
    self.timerId = LuaTimer.Add(1200, function()
        if self.pointEffectActivingGreen ~= nil then
            self.pointEffectActivingGreen:SetActive(false)
        end
        if self.pointEffectActivingBlue ~= nil then
            self.pointEffectActivingBlue:SetActive(false)
        end
        if self.pointEffectActivingPurple ~= nil then
            self.pointEffectActivingPurple:SetActive(false)
        end
        if self.pointEffectActivingOrange ~= nil then
            self.pointEffectActivingOrange:SetActive(false)
        end
        if callBack ~= nil then
            callBack()
        end
    end)
end

--传入状态切换右边条件显示
function ShouhuWakeUpPanel:SwitchRightState(state)
    self.ConditionConCharge:SetActive(false)
    self.ConditionConAdvanced:SetActive(false)
    self.ConditionConActive:SetActive(false)
    self.ConditionConFullLev:SetActive(false)
    if state == 1 then
        --未激活
        for i=1, #self.rightConditionList do
            self.rightConditionList[i].gameObject:SetActive(false)
        end
        self.RightConTitleTxt.text = TI18N("激活条件")
        local tempQuality = self.curData.quality == self.model.wakeUpMaxQuality and self.model.wakeUpMaxQuality - 1 or self.curData.quality --达到最大
        local condCfgData = DataShouhu.data_guard_wakeup_active[string.format("%s_%s", self.curData.base_id, tempQuality)]

        if condCfgData ~= nil then
            for i = 1, #condCfgData.condition do
                local tempData = condCfgData.condition[i]
                local okBool, conStr = self.model:PackWakeUpCondition(tempData.label, tempData.op, tempData.val[1])
                local item = self.rightConditionList[i]
                if okBool then
                    item.transform:FindChild("Img1"):GetComponent(Image).sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.basecompress_textures,"MapMyPoint") --绿灯
                else
                    item.transform:FindChild("Img1"):GetComponent(Image).sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures,"RedPoint") --红灯
                end
                item.txt.text = conStr
                item.gameObject:SetActive(true)
            end
        end
        self.ConditionConActive:SetActive(true)
    elseif state == 2 then
        --充能
        self.RightConTitleTxt.text = TI18N("星位效果")
        self.ConditionConCharge:SetActive(true)

        local growthVal = 0
        local baseData = DataShouhu.data_guard_base_cfg[self.curData.base_id]
        local levCfgData = DataShouhu.data_guard_lev_prop[string.format("%s_%s", self.curData.base_id, self.curData.sh_lev)]
        local wakeUpCfgData = DataShouhu.data_guard_wakeup[string.format("%s_%s_%s", self.curData.base_id, self.curChargeStarIndex, self.curData.quality)]
        if wakeUpCfgData ~= nil then
            growthVal = wakeUpCfgData.growth/1000
        end
        if self.curData.quality > baseData.quality then
            local lastCfgData = DataShouhu.data_guard_wakeup[string.format("%s_%s_%s", self.curData.base_id, self.curChargeStarIndex, self.curData.quality - 1)]
            if lastCfgData ~= nil then
                growthVal = growthVal - lastCfgData.growth/1000
            end
        end

        local rightAttrList = {}
        if levCfgData ~= nil and wakeUpCfgData ~= nil then
            for j = 1, #levCfgData.extra_attrs do
                rightAttrList[levCfgData.extra_attrs[j].attr] = levCfgData.extra_attrs[j].val*growthVal
            end

        end

        self.ConditionTxtGrowth.text = string.format(TI18N("守护成长：<color='#ed7f45'>%s</color>"), self.model:get_growth(self.curData))

        local tempVal = 0
        if self.curChargeStarIndex > 1 then
            local lastWakeUpCfgData = DataShouhu.data_guard_wakeup[string.format("%s_%s_%s", self.curData.base_id, self.curChargeStarIndex - 1, self.curData.quality)]
            tempVal =  wakeUpCfgData.showGrowth/1000 - lastWakeUpCfgData.showGrowth/1000
        else
            tempVal =  growthVal
        end

        self.ConditionTxtGrowthVal.text = self.model:KeepPointNum(tempVal)

        local tempData = self.curData --self.lastData
        if tempData == nil then
            tempData = self.curData
        end
        local list = {
            [2] =  {name = 1, val = tempData.sh_attrs_list.hp_max, icon = "AttrIcon1"} --生命上限
            ,[3] = {name = 6, val = tempData.sh_attrs_list.phy_def, icon = "AttrIcon6"} --物防
            ,[4] = {name = 7, val = tempData.sh_attrs_list.magic_def, icon = "AttrIcon7"} --魔防
            ,[5] = {name = 3, val = tempData.sh_attrs_list.atk_speed, icon = "AttrIcon3"} --攻击速度
        }
        if tempData.classes == 1 or tempData.classes == 3 or tempData.classes == 4 then
            list[1] = {name = 4, val = tempData.sh_attrs_list.phy_dmg, icon = "AttrIcon4"} --物攻
        -- elseif tempData.classes == 5 then
        --     list[1] = {name = 43, val = tempData.sh_attrs_list.heal_val, icon = "AttrIcon1"} --治疗加强
        else
            list[1] = {name = 5, val = tempData.sh_attrs_list.magic_dmg, icon = "AttrIcon5"} --魔攻
        end

        for i = 1, #self.ConditionAttrItemList do
            self.ConditionAttrItemList[i].gameObject:SetActive(false)
        end

        local newH = 30*#list
        local rect = self.ConditionContainer.transform:GetComponent(RectTransform)
        rect.sizeDelta = Vector2(182, newH)
        for i = 1, #list do
            local data = list[i]
            local item = self.ConditionAttrItemList[i]
            if item == nil then
                item = self:CreateAttrItem(i)
                table.insert(self.ConditionAttrItemList, item)
            end
            item.gameObject:SetActive(true)
            self:SetAttrItem(item, data, rightAttrList[data.name])
        end
    elseif state == 3 then
        --进阶
        self.RightConTitleTxt.text = TI18N("进阶效果")
        local TxtEffect1 = self.ConditionConAdvanced.transform:FindChild("TxtEffect1"):GetComponent(Text)
        local TxtEffect2 = self.ConditionConAdvanced.transform:FindChild("TxtEffect2"):GetComponent(Text)
        local TxtEffect3 = self.ConditionConAdvanced.transform:FindChild("TxtEffect3"):GetComponent(Text)
        local SkillIcon = self.ConditionConAdvanced.transform:FindChild("SkillCon").gameObject
        local SlotCon = self.ConditionConAdvanced.transform:FindChild("SkillCon"):FindChild("TopCon"):FindChild("SlotCon")
        local TxtSkillName = self.ConditionConAdvanced.transform:FindChild("SkillCon"):FindChild("TopCon"):FindChild("TxtSkillName"):GetComponent(Text)
        local TxtSkillDesc = self.ConditionConAdvanced.transform:FindChild("TxtSkillDesc"):GetComponent(Text)

        local tempQuality = self.curData.quality == self.model.wakeUpMaxQuality and self.model.wakeUpMaxQuality - 1 or self.curData.quality
        local roleAttr = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", self.curData.base_id, tempQuality+1)].role_attrs
        local attrData = self.model:GetGuardWakeupUpgrade(self.curData.base_id, tempQuality)
        -- for k, v in pairs(roleAttr) do
        --     if v.classes == RoleManager.Instance.RoleData.classes or v.classes == 0 then
        --         attrData = v
        --         break
        --     end
        -- end

        TxtEffect1.text = string.format(TI18N("1、人物属性加成\n   <color='#ffff00'>%s+%s</color>"), KvData.attr_name[attrData.attr], attrData.val)
        TxtEffect2.text = string.format(TI18N("2、%s品阶\n   <color='#ffff00'>%s→%s</color>"), self.curData.name, self.model.wakeUpQualityName[tempQuality], self.model.wakeUpQualityName[tempQuality+1])

        local upgradeCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", self.curData.base_id, self.model.wakeUpMaxQuality)]
        local skillId = 0
        for k, v in pairs(upgradeCfgData.qualitySkills) do
            if v[2] == tempQuality+1 then
                skillId = v[1]
                break
            end
        end
        if skillId > 0 then
            TxtEffect3.text = string.format(TI18N("3、%s习得新技能"), self.curData.name)
            if self.advanceRightSlot == nil then
                self.advanceRightSlot = SkillSlot.New()
                UIUtils.AddUIChild(SlotCon, self.advanceRightSlot.gameObject)
                self.advanceRightSlot.gameObject:SetActive(true)
            end
            local skillData = DataSkill.data_skill_guard[string.format("%s_1", skillId)]
            self.advanceRightSlot:SetAll(Skilltype.shouhuskill, {id = skillData.id, icon = skillData.icon, quality = upgradeCfgData[2]})
            TxtSkillName.text = skillData.name
            TxtSkillDesc.text = skillData.desc
            SkillIcon:SetActive(true)
        else
            TxtEffect3.text = ""
            SkillIcon:SetActive(false)
        end
         self.ConditionConAdvanced:SetActive(true)

    elseif state == 4 then
        --已达到最大
        self.ConditionConFullLev:SetActive(true)
    end
end

--传入状态切换底部
function ShouhuWakeUpPanel:SwitchBottomState(state)
    self.ActiveCon.gameObject:SetActive(false)
    self.AdvancedCon.gameObject:SetActive(false)
    self.ChargeCon.gameObject:SetActive(false)
    self.FullLevCon.gameObject:SetActive(false)
    if state == 1 then
        --未激活，显示激活容器
        local tempQuality = self.curData.quality == self.model.wakeUpMaxQuality and self.model.wakeUpMaxQuality - 1 or self.curData.quality
        local wakeUpActiveCostData = DataShouhu.data_guard_wakeup_active[string.format("%s_%s", self.curData.base_id, tempQuality)]
        self.ActiveCon.gameObject:SetActive(true)
        local base_id = wakeUpActiveCostData.cost[1][1]
        local itemData = DataItem.data_get[base_id] --设置数据
        self:SetSlotData(self.activeSlot, itemData)
        self.ActiveCon = self.BottomCon:FindChild("ActiveCon")
        self.ActiveCon:FindChild("RightCon"):FindChild("SlotCon"):FindChild("TxtName"):GetComponent(Text).text = ColorHelper.color_item_name(itemData.quality, itemData.name)
        local hasNum = BackpackManager.Instance:GetItemCount(base_id)
        local needNum = wakeUpActiveCostData.cost[1][2]
        self.activeSlot:SetNum(hasNum, needNum)
    elseif state == 2 then
        --已激活，未能进阶，显示充能容器
        self.ChargeCon.gameObject:SetActive(true)
        self.ChargeRewardImg.gameObject:SetActive(false)

        local curPointData = self.curSocketData.aroused[self.curChargeStarIndex]
        local curPointSocketExp = 0
        if curPointData ~= nil then
            curPointSocketExp = curPointData.exp
        end

        local nextWakeUpCfgData = DataShouhu.data_guard_wakeup[string.format("%s_%s_%s", self.curData.base_id, self.curChargeStarIndex, self.curData.quality)]
        if nextWakeUpCfgData == nil then
            return --已满级
        end

        local curWakeUpCfgData = nil
        if self.curSocketData.aroused[self.curChargeStarIndex] ~= nil then
            curWakeUpCfgData = DataShouhu.data_guard_wakeup[string.format("%s_%s_%s", self.curData.base_id, self.curChargeStarIndex, self.curSocketData.aroused[self.curChargeStarIndex].lev)]
        end
        local fenzi = 0
        if curWakeUpCfgData ~= nil then
            fenzi = curPointSocketExp - curWakeUpCfgData.need_exp
        else
            fenzi = curPointSocketExp - 0
        end
        local fenmu = 0
        if curWakeUpCfgData ~= nil then
            fenmu = nextWakeUpCfgData.need_exp - curWakeUpCfgData.need_exp
        else
            fenmu = nextWakeUpCfgData.need_exp - 0
        end
        if fenmu == 0 then
            fenmu = fenzi
        end
        -- self.ChargeImgBarRect.sizeDelta = Vector2((fenzi/fenmu)*235, self.ChargeImgBarRect.rect.height)
        self.btnchargeImage = self.ChargeCon:FindChild("RightCon"):FindChild("BtnCharge"):GetComponent(Image)
        self.btnchargeImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.ChargeCon:FindChild("RightCon/BtnCharge/Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
        self.BtnCharge.enabled = false
        local barEffectFuncEnd = function()
            self:PlayChargeProgBarEffect(false)
            self.ChargeCon:FindChild("RightCon"):FindChild("BtnCharge"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.ChargeCon:FindChild("RightCon/BtnCharge/Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
            if fenzi >= fenmu then -- 播放充能满条特效
                if curPointSocketExp >= nextWakeUpCfgData.need_exp then
                    self.ChargeCon:FindChild("RightCon"):FindChild("BtnCharge"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                    self.ChargeCon:FindChild("RightCon/BtnCharge/Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
                    self:PlayChargeProgBarEffect(true)
                end
            end
            self.BtnCharge.enabled = true
        end
        local endWidth = (fenzi/fenmu)*235
        if endWidth > self.ChargeImgBarRect.rect.width then
            SoundManager.Instance:Play(241)
            self:PlayChargeStoneEffect(self.MapPoint[self.lastSelectMapType][self.curChargeStarIndex])
            Tween.Instance:ValueChange(self.ChargeImgBarRect.rect.width, endWidth, 1, barEffectFuncEnd, LeanTweenType.linear, function(v)
                            self.ChargeImgBarRect.sizeDelta = Vector2(v, self.ChargeImgBarRect.rect.height)
                        end)
        else
            self.ChargeImgBarRect.sizeDelta = Vector2(endWidth, self.ChargeImgBarRect.rect.height)
            barEffectFuncEnd()
        end


        local base_id = nextWakeUpCfgData.cost[1][1]
        local itemData = DataItem.data_get[base_id] --设置数据
        self:SetSlotData(self.chargeSlot, itemData)
        self.ChargeCon:FindChild("RightCon"):FindChild("SlotCon"):FindChild("TxtName"):GetComponent(Text).text = ColorHelper.color_item_name(itemData.quality, itemData.name)
        local hasNum = BackpackManager.Instance:GetItemCount(base_id)
        local needNum = nextWakeUpCfgData.cost[1][2]
        self.chargeSlot:SetNum(hasNum, needNum)
    elseif state == 3 then
        --可以进阶，显示进阶容器
        local upgradeCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", self.curData.base_id, self.curData.quality+1)]
        self.AdvancedCon.gameObject:SetActive(true)
        local base_id = upgradeCfgData.cost[1][1]
        local itemData = DataItem.data_get[base_id] --设置数据
        self:SetSlotData(self.advancedSlot, itemData)
        self.AdvancedCon:FindChild("RightCon"):FindChild("SlotCon"):FindChild("TxtName"):GetComponent(Text).text = ColorHelper.color_item_name(itemData.quality, itemData.name)
        local hasNum = BackpackManager.Instance:GetItemCount(base_id)
        local needNum = upgradeCfgData.cost[1][2]
        self.advancedSlot:SetNum(hasNum, needNum)

        local txtCon1 = self.AdvancedCon:FindChild("LeftCon"):FindChild("TxtCondition1").gameObject
        local txtCon2 = self.AdvancedCon:FindChild("LeftCon"):FindChild("TxtCondition2").gameObject
        local txtCon3 = self.AdvancedCon:FindChild("LeftCon"):FindChild("TxtCondition3").gameObject

        local fullLev = false
        if self.curData.quality == self.model.wakeUpMaxQuality then
            fullLev = true
            if #self.curSocketData.aroused == 8 then
                for i = 1, #self.curSocketData.aroused do
                    if self.curSocketData.aroused[i].lev < self.curData.quality then
                        fullLev = false
                    end
                end
            end
        end
        if fullLev then
            --已满级
            txtCon1:SetActive(false)
            txtCon2:SetActive(false)
            txtCon3:SetActive(true)
        else
            txtCon1:SetActive(true)
            txtCon2:SetActive(false)
            txtCon3:SetActive(false)
        end
    elseif state == 4 then
        --已达到最大等级
        self.FullLevCon.gameObject:SetActive(true)
    end
end

--设置星的状态
function ShouhuWakeUpPanel:SetPointState(point, state)
    local ImgOpen = point:FindChild("PointStateCon"):FindChild("ImgOpen").gameObject
    local ImgClose = point:FindChild("PointStateCon"):FindChild("ImgClose").gameObject
    ImgOpen:SetActive(state)
    ImgClose:SetActive(not state)
end

--设置星的属性描述
function ShouhuWakeUpPanel:SetPointProp(point, descStr)
    if descStr ~= "" then
        point:FindChild("ImgProp").gameObject:SetActive(true)
        local propTxt = point:FindChild("ImgProp"):FindChild("Text"):GetComponent(Text)
        propTxt.text = descStr
    else
        point:FindChild("ImgProp").gameObject:SetActive(false)
    end
end

function ShouhuWakeUpPanel:CreateSlot(slotCon)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slotCon.transform)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end

--设置宝石道具各自数据
function ShouhuWakeUpPanel:SetSlotData(slot, itemData)
    local cell = ItemData.New()
    cell:SetBase(itemData)
    slot:SetAll(cell, nil)
end

--创建一个conditionItem
function ShouhuWakeUpPanel:CreateConditionItem(conTras)
    local item = {}
    item.transform = conTras
    item.gameObject = conTras.gameObject
    item.txt = conTras:FindChild("TxtCondition"):GetComponent(Text)
    item.img = item.transform:FindChild("Img1"):GetComponent(Image)
    item.txt.text = ""
    return item
end

--影藏所有激活特效
function ShouhuWakeUpPanel:HideActiveEffect()
    if self.pointEffectActivedGreenList ~= nil then
        for k, v in pairs(self.pointEffectActivedGreenList) do
            v:SetActive(false)
        end
    end
    if self.pointEffectActivedBlueList ~= nil then
        for k, v in pairs(self.pointEffectActivedBlueList) do
            v:SetActive(false)
        end
    end
    if self.pointEffectActivedPurpleList ~= nil then
        for k, v in pairs(self.pointEffectActivedPurpleList) do
            v:SetActive(false)
        end
    end
    if self.pointEffectActivedOrangeList ~= nil then
        for k, v in pairs(self.pointEffectActivedOrangeList) do
            v:SetActive(false)
        end
    end
end

function ShouhuWakeUpPanel:HideActivingEffect()
    if self.pointEffectActivedGreenList ~= nil then
        for k, v in pairs(self.pointEffectActivedGreenList) do
            v:SetActive(false)
        end
    end
    if self.pointEffectActivedBlueList ~= nil then
        for k, v in pairs(self.pointEffectActivedBlueList) do
            v:SetActive(false)
        end
    end
    if self.pointEffectActivedPurpleList ~= nil then
        for k, v in pairs(self.pointEffectActivedPurpleList) do
            v:SetActive(false)
        end
    end
    if self.pointEffectActivedOrangeList ~= nil then
        for k, v in pairs(self.pointEffectActivedOrangeList) do
            v:SetActive(false)
        end
    end
end

function ShouhuWakeUpPanel:HideUnActiveEffect()
    if self.pointEffectUnActiveGreen ~= nil then
     self.pointEffectUnActiveGreen:SetActive(false)
    end
    if self.pointEffectUnActiveBlue ~= nil then
        self.pointEffectUnActiveBlue:SetActive(false)
    end
    if self.pointEffectUnActivePurple ~= nil then
        self.pointEffectUnActivePurple:SetActive(false)
    end
    if self.pointEffectUnActiveOrange ~= nil then
        self.pointEffectUnActiveOrange:SetActive(false)
    end
end

--播放大宝石激活特系
function ShouhuWakeUpPanel:PlayStoneActiveEffect(trans)
    if self.pointEffect20211 == nil then
        self.pointEffect20211 = self:GetEffect(trans, 20211)
    else
        self:SetEffectTrans(trans, self.pointEffect20211)
    end
    self.pointEffect20211:SetActive(false)
    self.pointEffect20211:SetActive(true)
end

--设置下一个需要激活的星位上面的特效
function ShouhuWakeUpPanel:PlayUnActiveEffect(trans, mapType)
    local effect = nil
    if mapType == 1 then
        if self.pointEffectUnActiveGreen == nil then
            self.pointEffectUnActiveGreen = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20200)))
        end
        effect = self.pointEffectUnActiveGreen
    elseif mapType == 2 then
        if self.pointEffectUnActiveBlue == nil then
            self.pointEffectUnActiveBlue = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20200)))
        end
        effect = self.pointEffectUnActiveBlue
    elseif mapType == 3 then
        if self.pointEffectUnActivePurple == nil then
            self.pointEffectUnActivePurple = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20200)))
        end
        effect = self.pointEffectUnActivePurple
    elseif mapType == 4 then
        if self.pointEffectUnActiveOrange == nil then
            self.pointEffectUnActiveOrange = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20200)))
        end
        effect = self.pointEffectUnActiveOrange
    end

    if trans ~= effect.transform.parent then
        effect:SetActive(false)
    end
    self:SetEffectTrans(trans, effect)
    -- effect.transform.localPosition = Vector3(4.5, 0, -400)
    effect:SetActive(true)

end

--设置星位激活那一刻出现播放的特效
function ShouhuWakeUpPanel:PlayActivingEffect(trans, mapType)
    local effect = nil
    if mapType == 1 then
        if self.pointEffectActivingGreen == nil then
            self.pointEffectActivingGreen = self:GetEffect(trans, 20201)
        end
        effect = self.pointEffectActivingGreen
    elseif mapType == 2 then
        if self.pointEffectActivingBlue == nil then
            self.pointEffectActivingBlue = self:GetEffect(trans, 20202)
        end
        effect = self.pointEffectActivingBlue
    elseif mapType == 3 then
        if self.pointEffectActivingPurple == nil then
            self.pointEffectActivingPurple = self:GetEffect(trans, 20203)
        end
        effect = self.pointEffectActivingPurple
    elseif mapType == 4 then
        if self.pointEffectActivingOrange == nil then
            self.pointEffectActivingOrange = self:GetEffect(trans, 20204)
        end
        effect = self.pointEffectActivingOrange
    end
    effect:SetActive(false)
    self:SetEffectTrans(trans, effect)
    effect:SetActive(true)
    return effect
end

--传入星阵索引和星位索引获取对应的星位激活特效
function ShouhuWakeUpPanel:PlayActivedEffect(trans, mapType, starIndex)
    if mapType == 1 then
        if self.pointEffectActivedGreenList == nil then
            self.pointEffectActivedGreenList = {}
        end
        if self.pointEffectActivedGreenList[starIndex] == nil then
            local effect = self:GetEffect(trans, 20205)
            self.pointEffectActivedGreenList[starIndex] = effect
        end
        self.pointEffectActivedGreenList[starIndex]:SetActive(true)
    elseif mapType == 2 then
        if self.pointEffectActivedBlueList == nil then
            self.pointEffectActivedBlueList = {}
        end
        if self.pointEffectActivedBlueList[starIndex] == nil then
            local effect = self:GetEffect(trans, 20206)
            self.pointEffectActivedBlueList[starIndex] = effect
        end
        self.pointEffectActivedBlueList[starIndex]:SetActive(true)
    elseif mapType == 3 then
        if self.pointEffectActivedPurpleList == nil then
            self.pointEffectActivedPurpleList = {}
        end
        if self.pointEffectActivedPurpleList[starIndex] == nil then
            local effect = self:GetEffect(trans, 20207)
            self.pointEffectActivedPurpleList[starIndex] = effect
        end
        self.pointEffectActivedPurpleList[starIndex]:SetActive(true)
    elseif mapType == 4 then
        if self.pointEffectActivedOrangeList == nil then
            self.pointEffectActivedOrangeList = {}
        end
        if self.pointEffectActivedOrangeList[starIndex] == nil then
            local effect = self:GetEffect(trans, 20208)
            self.pointEffectActivedOrangeList[starIndex] = effect
        end
        self.pointEffectActivedOrangeList[starIndex]:SetActive(true)
    end
end

--设置充能进度条满条特效显示状态
function ShouhuWakeUpPanel:PlayChargeProgBarEffect(state)
    self.ChargeProgBarEnough = state
    if self.pointEffect20219 == nil then
        self.pointEffect20219 = self:GetEffect(self.ChargeConGrid, 20219)
    end
    self.pointEffect20219.transform.localPosition = Vector3(-120, -8, -400)
    self.pointEffect20219:SetActive(state)
end

--充能的时候，宝石上面播一下聚气特效：20210
function ShouhuWakeUpPanel:PlayChargeStoneEffect(trans)
    if self.pointEffect20210 == nil then
        self.pointEffect20210 = self:GetEffect(trans, 20210)
    else
        self:SetEffectTrans(trans, self.pointEffect20210)
    end
    self.pointEffect20210:SetActive(false)
    -- self.pointEffect20210:SetActive(true)
end

--触发多倍，充能进度条的倍数
function ShouhuWakeUpPanel:PlayChargeRewardEffect()
    if self.pointEffect20220 == nil then
        self.pointEffect20220 = self:GetEffect(self.ChargeRewardImg, 20220)
    end
    self.pointEffect20220.transform.localPosition = Vector3(0, 0, -400)
    self.pointEffect20220:SetActive(false)
    self.pointEffect20220:SetActive(true)
    if self.chargeTimerId ~= 0 then
        LuaTimer.Delete(self.chargeTimerId)
    end
    self.chargeTimerId = LuaTimer.Add(1200, function()
        self.pointEffect20220:SetActive(false)
    end)
end

--播放星阵进阶特效
function ShouhuWakeUpPanel:PlaySwitchMapEffect(state)
    if self.pointEffect20218 == nil then
        self.pointEffect20218 = self:GetEffect(self.SwitchMapEffectCon, 20218)
        self.pointEffect20218.transform.localPosition = Vector3(0, -24, -400)
    end
    self.pointEffect20218:SetActive(state)
end

--传入特效id获取一个特效
function ShouhuWakeUpPanel:GetEffect(trans, effectId)
    local effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, effectId)))
    self:SetEffectTrans(trans, effect)
    effect:SetActive(false)
    return effect
end

--设置特效所在的trans
function ShouhuWakeUpPanel:SetEffectTrans(trans, effect)
    effect.transform:SetParent(trans)
    effect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effect.transform, "UI")
    effect.transform.localScale = Vector3(1, 1, 1)
    effect.transform.localPosition = Vector3(0, 0, -400)
end

--创建充能效果属性item
function ShouhuWakeUpPanel:CreateAttrItem(index)
    local item = {}
    item.gameObject = GameObject.Instantiate(self.ConditionAttrItem)
    item.transform = item.gameObject.transform
    item.transform:SetParent(self.ConditionAttrItem.transform.parent)
    item.transform.localScale = Vector3.one

    item.ImgIcon = item.transform:Find("ImgIcon"):GetComponent(Image)
    item.AttrTxt = item.transform:Find("AttrTxt"):GetComponent(Text)
    item.AttrTxt2 = item.transform:Find("AttrTxt2"):GetComponent(Text)
    item.index = index

    local newY = -27*(index - 1)
    local rect = item.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(0, newY)
    return item
end

function ShouhuWakeUpPanel:SetAttrItem(item, data, val)
    item.transform:Find("ImgIcon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, data.icon)
    if val == nil then
        local nameStr = KvData.attr_name[data.name]
        if data.name == 43 then
            nameStr = TI18N("治疗")
        end
        item.AttrTxt.text = string.format("%s: <color='#c7f9ff'>%s</color>", nameStr, Mathf.Round(data.val))
        item.AttrTxt2.text = tostring(Mathf.Round(data.val*1) - data.val)
    else
        item.AttrTxt.text = string.format("%s: <color='#c7f9ff'>%s</color>", KvData.attr_name[data.name], Mathf.Round(data.val))
        item.AttrTxt2.text = tostring(Mathf.Round(val))
    end
end


--设置线路颜色
function ShouhuWakeUpPanel:SetLineColor(line, quality, grey)
    if grey then
        --灰色
        line.sprite = self.assetWrapper:GetSprite(AssetConfig.shouhu_texture, "LineGrey")
    else
        line.sprite = self.assetWrapper:GetSprite(AssetConfig.shouhu_texture, string.format("Line%s", quality))
    end
end

function ShouhuWakeUpPanel:ShowNext()
    local baseData = DataShouhu.data_guard_base_cfg[self.curData.base_id]
    local cfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", self.curData.base_id, self.curData.quality + 1)]
    local args = {}
    if cfgData == nil or cfgData.model == 0 then
        args.data = {skin = baseData.paste_id , model = baseData.res_id , animation = baseData.animation_id, quality = self.curData.quality + 1, base_id = self.curData.base_id, lastData = self.curData}
    else
        args.data = {skin = cfgData.skin , model = cfgData.model , animation = cfgData.animation, quality = cfgData.quality, base_id = self.lastData.base_id , lastData = self.curData}
    end
    args.name = ColorHelper.color_item_name(self.curData.quality + 1, baseData.alias)
    args.isNext = true
    args.callback = function()
        ShouhuManager.Instance.model:OpenShouhuMainUI()
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guardianWakeupLook, args)
end