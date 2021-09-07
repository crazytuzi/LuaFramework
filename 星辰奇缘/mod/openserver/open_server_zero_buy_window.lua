-- @author hze
-- @date #18/03/15#

OpenServerZeroBuyWindow = OpenServerZeroBuyWindow or BaseClass(BaseWindow)

function OpenServerZeroBuyWindow:__init(model)
self.model = model
    self.windowId =WindowConfig.WinID.zero_buy_win
    self.name = "OpenServerZeroBuyWindow"
    self.mgr = OpenServerManager.Instance
    -- self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.open_server_zero_buy, type = AssetType.Main}
        ,{file = AssetConfig.open_server_zero_buybg, type = AssetType.Main}
        ,{file = AssetConfig.open_server_zero_buybg1, type = AssetType.Main}
        ,{file = AssetConfig.open_server_zero_buybg2, type = AssetType.Main}
        ,{file = AssetConfig.open_server_zero_buybg3, type = AssetType.Main}
        ,{file = AssetConfig.open_server_zero_texture, type = AssetType.Dep}

        -- , {path = AssetConfigXX.open_server_rank_window_bg, type = AssetType.Prefab}
        -- , {path = AssetConfig.zero_buy_title_1, type = AssetType.Prefab}
        -- , {path = AssetConfig.zero_buy_title_2, type = AssetType.Prefab}
        -- , {path = AssetConfig.zero_buy_title_3, type = AssetType.Prefab}
        -- ,{path = AssetConfig.SevenDayBg1, type = AssetType.Prefab}
        -- ,{path = AssetConfig.SevenDayBg2, type = AssetType.Prefab}
    }

    self.loss =
    {
        [1] = {90026, 288},
        [2] = {90002, 888},
        [3] = {90002, 1888}
    }

    self._updateModel = function() self:UpdateModel() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    -- self.onUpdateEvent = function() self:UpdateButton() self:UpdateTime() end

    -- self.rewardParentList = {}

    -- self.rewardDataList = {}
    -- self.effectList = {}
    -- self.previewEffect = nil
    -- self.leftTime = {}
    self.loaders = {}
    self.icon_list = {23083, 52016, 29062}


    self.BigBgList = {}
    self.tabList = {}
    self.rewardList = {}
    self.rewardObjList = {}

    self.currentselect = 1
    self.timeDesc = TI18N("领取剩余时间：")

    self.zeroText = 888


end

function OpenServerZeroBuyWindow:__delete()
    -- self.mgr.onUpdateZeroBuy:Remove(self.onUpdateEvent)

    if self.rewardObjList ~= nil then
        for i,v in pairs(self.rewardObjList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.rewardObjList = nil
    end

    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.bigBg1 ~= nil then
        GameObject.DestroyImmediate(self.bigBg1)
        self.bigBg1 = nil
    end
    if self.bigBg2 ~= nil then
        GameObject.DestroyImmediate(self.bigBg2)
        self.bigBg2 = nil
    end
    if self.bigBg3 ~= nil then
        GameObject.DestroyImmediate(self.bigBg3)
        self.bigBg3 = nil
    end

    if self.previewEffect ~= nil then
        self.previewEffect:DeleteMe()
        self.previewEffect = nil
    end

    if self.btnEffect ~= nil then
        self.btnEffect:DeleteMe()
        self.btnEffect = nil
    end


    for k, v in pairs(self.loaders) do
        v:DeleteMe()
    end
    self.loaders = nil


    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function OpenServerZeroBuyWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_zero_buy))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = t

    local Main = t:Find("Main")

    self.left = Main:Find("Left")

    for i = 1,3 do
        self.BigBgList[i] = Main:Find(string.format("BackGroundBg/BigBgTitle%d",i))
    end

    UIUtils.AddBigbg(Main:Find("BackGroundBg/BigBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_zero_buybg)))
    UIUtils.AddBigbg(self.BigBgList[1], GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_zero_buybg1)))
    UIUtils.AddBigbg(self.BigBgList[2], GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_zero_buybg2)))
    UIUtils.AddBigbg(self.BigBgList[3], GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_zero_buybg3)))

    self.closeBtn = Main:Find("Close"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.rewardContainer = Main:Find("RewardArea/Left")
    self.ItemLayout = LuaGridLayout.New(self.rewardContainer.gameObject,{column = 3,cspacing = 2,rspacing = 26,cellSizeX = 64,cellSizeY = 64})

    self.timeText = Main:Find("TimeText"):GetComponent(Text)
    -- self.timeText:GetComponent(RectTransform).anchoredPosition = Vector2(-150, -185)

    self.btn = Main:Find("Button"):GetComponent(Button)
    self.btn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(TI18N("未达到领取等级")) end)
    self.btnSprite = Main:Find("Button/Image"):GetComponent(Image)

    self.currencySprite = self.transform:Find("Main/RewardArea/Right/Currency"):GetComponent(Image)
    self.valueSprite = self.transform:Find("Main/RewardArea/Right/Value"):GetComponent(Image)
    self.giftPackSprite = self.transform:Find("Main/RewardArea/Right/GiftPack"):GetComponent(Image)

    self.btnText = Main:Find("Button/Text"):GetComponent(Text)

    self.previewModel = Main:Find("PreviewArea/Model")
    self.previewEffectTrans = Main:Find("PreviewArea/Effect")

    self.ItemIcon = Main:Find("PreviewArea/Item"):GetComponent(Image)

    self.timeFormatString1 = TI18N("活动剩余时间:<color='%s'>%s天%s时%s分</color>")
    self.timeFormatString2 = TI18N("活动剩余时间:<color='%s'>%s时%s分%s秒</color>")
    self.timeFormatString3 = TI18N("活动剩余时间:<color='%s'>%s分%s秒</color>")
    self.timeFormatString4 = TI18N("活动剩余时间:<color='%s'>%s秒</color>")
    self.timeFormatString5 = TI18N("活动已结束")

    self.leftContainer = self.left:Find("Container")
    self.tabLayout = LuaBoxLayout.New(self.leftContainer.gameObject, {axis = BoxLayoutAxis.Y, spacing = 5, border = 5})
    self.tabCloner = self.left:Find("BaseItem").gameObject

    self.tabData = BaseUtils.copytab(DataCampZeroBuy.data_get_bag_list)

    for i,v in ipairs(self.tabData) do
        if self.tabList[i] == nil then
            local obj = GameObject.Instantiate(self.tabCloner)
            self.tabLayout:AddCell(obj)
            obj.name = tostring(i)
            obj.transform:SetParent(self.leftContainer)
            obj.transform.localScale = Vector3.one
            obj.transform:Find("Normal/Text"):GetComponent(Text).text = v.name
            obj.transform:Find("Select/Text"):GetComponent(Text).text = v.name

            local tab = {}
            tab.obj = obj
            tab.normal = obj.transform:Find("Normal").gameObject
            tab.select = obj.transform:Find("Select").gameObject
            tab.red = obj.transform:Find("Notify").gameObject
            tab.icon = obj.transform:Find("Icon"):GetComponent(Image)
            obj.transform:GetComponent(Button).onClick:RemoveAllListeners()
            obj.transform:GetComponent(Button).onClick:AddListener(function() self:ChangeTab(i) end)
            self.tabList[i] = tab
        end
    end
    self.tabCloner:SetActive(false)

    for i,v in pairs(self.tabList) do
        v.red:SetActive(false)
    end
end

function OpenServerZeroBuyWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
    -- self.mgr.onUpdateZeroBuy:Remove(self.onUpdateEvent)
    -- self.mgr.onUpdateZeroBuy:Add(self.onUpdateEvent)
    -- self:UpdateReward()
end

function OpenServerZeroBuyWindow:OnOpen()
    self:RemoveListeners()
    OpenServerManager.Instance.onZeroBuyDataEvent:AddListener(self._updateModel)
    OpenServerManager.Instance:send20441()

    self:ChangeTab(1)
    self:CalculateTime()

    self.model.lastArgs = self.openArgs[1] or self.model.lastArgs

    self.campId = self.model.lastArgs


end

function OpenServerZeroBuyWindow:OnHide()
    self:RemoveListeners()

    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end

    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil
    end

end

function OpenServerZeroBuyWindow:RemoveListeners()
    OpenServerManager.Instance.onZeroBuyDataEvent:RemoveListener(self._updateModel)
end

function OpenServerZeroBuyWindow:ChangeTab(index)


    local stateList = {false,false,false}
    stateList[index] = true

    if self.tabList[index] ~= nil then
        for k,v in pairs(self.tabList) do
            v.normal:SetActive(not stateList[k])
            v.select:SetActive(stateList[k])
            self.BigBgList[k].gameObject:SetActive(stateList[k])
            -- self:SetSprite(self.icon_list[k],v.icon)
        end
    end

    self.currentselect = index

    self:UpdateTotle()
    self:UpdateModel()

end


function OpenServerZeroBuyWindow:UpdateModel()
    self:UpdateRed()
    self.zerobuyData = self.model.zerobuydata

    if self.zerobuyData[self.currentselect] == nil then return end
    local data = self.zerobuyData[self.currentselect].list
    if next(data) == nil then return end

    if data[1].status == 0 or data[1].status == 1 then
        if  self.currentselect ~= 1  then
            self.timeDesc = TI18N("抢购剩余时间:")
        else
            self.timeDesc = TI18N("领取剩余时间:")
        end
    elseif data[1].status == 2 then
        self.timeDesc = TI18N("活动剩余时间:")
    end

    if self.btnEffect ~= nil then
        self.btnEffect:SetActive(false)
    end
    --更新按钮状态
    if data[1].status == 1 then  -- 第一阶段可领取或可购买
        if self.currentselect == 1 then
            if RoleManager.Instance.RoleData.lev >= 40 then
                if self.btnEffect == nil then
                    self.btnEffect = BaseUtils.ShowEffect(20053, self.btn.gameObject.transform, Vector3(2.2, 0.8, 1), Vector3(-70, -17.3, -100))
                else
                    self.btnEffect:SetActive(false)
                    self.btnEffect:SetActive(true)
                end
                -- 免费领取
                self.btnSprite.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_zero_texture, "FreeGet")
                self.btn.onClick:RemoveAllListeners()
                self.btn.onClick:AddListener(function()
                    OpenServerManager.Instance:send20442(self.currentselect, 1)
                end)
            else
                self.btnSprite.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_zero_texture, "Lev40Get")
                self.btn.onClick:RemoveAllListeners()
                self.btn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(TI18N("未达到领取等级")) end)
            end
            self.timeText.gameObject:SetActive(true)
        else
            self.timeText.gameObject:SetActive(true)
            -- 立刻抢购
            self.btnSprite.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_zero_texture, "PanicBuy")

            self.btn.onClick:RemoveAllListeners()
            self.btn.onClick:AddListener(function()
                    local cdata = NoticeConfirmData.New()
                    cdata.type = ConfirmData.Style.Normal
                    cdata.content = string.format(TI18N("是否确认花费<color=#ffff00>%s</color>钻石立即抢购？"),self.zeroText)
                    cdata.sureLabel = TI18N("确 认")
                    cdata.cancalLabel = TI18N("取 消")
                    cdata.sureCallback = function() OpenServerManager.Instance:send20442(self.currentselect, 1) end
                    NoticeManager.Instance:ConfirmTips(cdata)
            end)
        end
    elseif data[1].status == 2 then
        if self.currentselect == 1 then
            self.btnSprite.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_zero_texture, "Geted")
            self.btn.onClick:RemoveAllListeners()
            self.btn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(TI18N("已领取")) end)
        else
            self.btnSprite.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_zero_texture, "Buyed")
            self.btn.onClick:RemoveAllListeners()
            self.btn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(TI18N("已购买")) end)

        end
    end
    self.btnSprite:SetNativeSize()
end


function OpenServerZeroBuyWindow:UpdateRed()
    if RoleManager.Instance.RoleData.lev >= 40 then
        self.tabList[1].red:SetActive(OpenServerManager.Instance.zeroBuyRedPoint)
    else
        self.tabList[1].red:SetActive(false)
    end
end

function OpenServerZeroBuyWindow:UpdateTime()

    local nowTime = BaseUtils.BASE_TIME
    local beginTimeData = DataCampaign.data_list[self.campId].cli_start_time[1]
    local endTimeData = DataCampaign.data_list[self.campId].cli_end_time[1]

    local beginTime = CampaignManager.Instance.open_srv_time
    local endTime = beginTime + endTimeData[2] * 24 * 60 * 60 + beginTimeData[3]

    local d,h,m,s = BaseUtils.time_gap_to_timer(endTime - nowTime)

    if BaseUtils.BASE_TIME < endTime then
        d,h,m,s = BaseUtils.time_gap_to_timer(endTime - BaseUtils.BASE_TIME)
        if d ~= 0 then
            self.timeText.text = string.format(self.timeFormatString1, "#00ff00", tostring(d), tostring(h), tostring(m))
        elseif h ~= 0 then
            self.timeText.text = string.format(self.timeFormatString2, "#00ff00", tostring(h), tostring(m), tostring(s))
        elseif m ~= 0 then
            self.timeText.text = string.format(self.timeFormatString3, "#00ff00", tostring(m), tostring(s))
        else
            self.timeText.text = string.format(self.timeFormatString4, "#00ff00", tostring(s))
        end
    else
        self.timeText.text = self.timeFormatString5
    end
end


function OpenServerZeroBuyWindow:UpdateTotle()
    self:UpdateReward()
    self:UpdatePreview()
    self:UpdateEffect()
end


function OpenServerZeroBuyWindow:UpdateReward()

    local key = string.format("%s_%s_%s_%s", self.currentselect, 1, 2, 0)
    if DataCampZeroBuy.data_get_reward_list[key] == nil then
        key = string.format("%s_%s_%s_%s", self.currentselect, 1 , RoleManager.Instance.RoleData.sex, 0)
    end
    local rewardList = DataCampZeroBuy.data_get_reward_list[key].reward

    for i = 1,6 do
        if self.rewardObjList[i] == nil then
            local rechargePackSlot = RechargePackItem.New()
            self.rewardObjList[i] = rechargePackSlot
            self.ItemLayout:AddCell(rechargePackSlot.slot.gameObject)
        end

        local itemData = DataItem.data_get[rewardList[i][1]]
        self.rewardObjList[i].slot:SetAll(itemData,{inbag = false, nobutton = true})
        self.rewardObjList[i].slot:SetNum(rewardList[i][3])
        -- self.rewardObjList[i].slot.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_zero_texture, "ItemSlotdi")
        self.rewardObjList[i].slot.transform:Find("QualityBg").gameObject:SetActive(false)
        self.rewardObjList[i].slot.transform:Find("ItemImg").sizeDelta = Vector2(48,48)
        if rewardList[i][4] == 1 then
            self.rewardObjList[i]:ShowEffect(true,2)
        end
    end


    --  --更新右边栏
    -- key = string.format("%s_%s_%s_%s", self.currentselect, 2, 2, 0)
    -- if DataCampZeroBuy.data_get_reward_list[key] == nil then
    --     key = string.format("%s_%s_%s_%s", self.currentselect, 2 , RoleManager.Instance.RoleData.sex, 0)
    -- end
    -- print(key)
    -- local loss = DataCampZeroBuy.data_get_reward_list[key].reward

    self.currencySprite.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..self.loss[self.currentselect][1])
    self.valueSprite.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_zero_texture, "NumGet"..self.loss[self.currentselect][2])
    self.zeroText = self.loss[self.currentselect][2]

    if self.currentselect == 1 then
        self.giftPackSprite.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_zero_texture, "Reddiamond")
    else
        self.giftPackSprite.sprite = self.assetWrapper:GetSprite(AssetConfig.open_server_zero_texture, "Bluediamond")
    end

    self.valueSprite:SetNativeSize()
    self.giftPackSprite:SetNativeSize()
end

function OpenServerZeroBuyWindow:UpdateEffect()
    --20469  20473
    if self.previewEffect ~= nil then
        self.previewEffect:DeleteMe()
        self.previewEffect = nil
    end
    if self.currentselect == 1 then
        if self.previewEffect == nil then
            self.previewEffect = BaseUtils.ShowEffect(20473, self.previewEffectTrans, Vector3(0.5, 0.5, 1), Vector3(8, 14, 0))
        end
    elseif self.currentselect == 2 then
        if self.previewEffect == nil then
            self.previewEffect = BaseUtils.ShowEffect(20473, self.previewEffectTrans, Vector3(0.5, 0.5, 1), Vector3(8, 14, -400))
        end
    elseif self.currentselect == 3 then
        if self.previewEffect == nil then
            self.previewEffect = BaseUtils.ShowEffect(20469, self.previewEffectTrans, Vector3(0.6, 0.7, 1), Vector3(8, 51, 0))
        end
    end
end

function OpenServerZeroBuyWindow:UpdatePreview()
    self.ItemIcon.gameObject:SetActive(false)
    if self.currentselect == 1 then
        local petData = DataPet.data_pet[10010] --跟据ID，取模型数据(雪狐)
        local modelData = {type = PreViewType.Pet, skinId = petData.skin_id_0, modelId = petData.model_id, animationId = petData.animation_id, scale = petData.scale / 100, effects = petData.effects_0}
        self:SetPreview(modelData)
    elseif self.currentselect == 2 then
        self.previewModel.gameObject:SetActive(false)
        self.ItemIcon.gameObject:SetActive(true)

        if self.timer == nil then
            self.timer = LuaTimer.Add(0, 20, function() self:FloatSlot() end)
        end
    elseif self.currentselect == 3 then
        local unitData = {{50040,51040},{50041,51041}}  --女,男
        local _looks = {}
        for _,v in pairs(unitData[RoleManager.Instance.RoleData.sex + 1]) do
            local myData = DataFashion.data_base[v]
            table.insert(_looks, {looks_str = "", looks_type = myData.type, looks_val = myData.model_id, looks_mode = myData.texture_id})
        end
        local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = _looks}
        self:SetPreview(modelData)
    end
end

function OpenServerZeroBuyWindow:SetPreview(modelData)
    local callback = function(composite)
        self:SetRawImage(composite)
    end

    local setting = {
        name = "ZeroBuyView"
        ,orthographicSize = 0.45
        ,width = 194
        ,height = 257
        ,offsetX = 0
        ,offsetY = -0.4
    }




    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function OpenServerZeroBuyWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.previewModel)
    rawImage.transform.localPosition = Vector3(6, 37.26, 300)
    rawImage.transform.localScale = Vector3(1,1,1)
    composite.tpose.transform.localRotation = Quaternion.Euler(350,350,0)
    self.previewModel.gameObject:SetActive(true)
end

function OpenServerZeroBuyWindow:SetSprite(iconid, img)
    local id = img.gameObject:GetInstanceID()
    if self.loaders[id] == nil then
        self.loaders[id] = SingleIconLoader.New(img.gameObject)
    end
    self.loaders[id]:SetSprite(SingleIconType.Item, iconid)
    img.gameObject:SetActive(true)
end

function OpenServerZeroBuyWindow:FloatSlot()
    self.counter = (self.counter or 0) + 1
    self.ItemIcon.transform.anchoredPosition = Vector2(22.6, -22.2 + 10 * math.sin(self.counter / 9))
end

function OpenServerZeroBuyWindow:CalculateTime()
    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil
    end

    self.timerId1 = LuaTimer.Add(0,1000,function() self:UpdateTime() end)
end
