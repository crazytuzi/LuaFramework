-- 修改：20171024 黄耀聪 去掉重复的timerid删除操作

DragonBoatConsmRtnPanel = DragonBoatConsmRtnPanel or BaseClass(BasePanel)

function DragonBoatConsmRtnPanel:__init(model,parent)
    self.model = model
    self.name = "DragonBoatConsmRtnPanel"
    self.parent = parent

    self.resList = {
        {file = AssetConfig.dragonboat_consumertn_panel, type = AssetType.Main}
        --,{file = AssetConfig.dragonboat_topbg, type = AssetType.Main}
        -- ,{file = AssetConfig.base_textures, type = AssetType.Dep}
        ,{file = AssetConfig.dragonboat_topimage1, type = AssetType.Dep}
        ,{file = AssetConfig.dragonboat_topimage2, type = AssetType.Dep}
        ,{file = AssetConfig.open_server_textures, type = AssetType.Dep}

    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:UpdateWindow()
    end)
    self.OnHideEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        -- self:RemovePetUpdateEvent()
        self:OnHide()
    end)

    self.campaignGroup = nil
    self.dataList = nil
    self.timerId = 0

    --货币符号图标
    self.giftItemIcon = {}

    self.get_campaign_reward_success = function ()
        self:UpdateWindow()
    end

    -- self.petreleasepanel = nil
    EventMgr.Instance:AddListener(event_name.campaign_change, self.get_campaign_reward_success)
    -- EventMgr.Instance:AddListener(event_name.petstore_update, self.petStoreUpdateFun)
end
function DragonBoatConsmRtnPanel:OnHide()
    if self.timerId ~= nil and self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function DragonBoatConsmRtnPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function DragonBoatConsmRtnPanel:__delete()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.get_campaign_reward_success)
    -- EventMgr.Instance:RemoveListener(event_name.petstore_update, self.petStoreUpdateFun)
    for i,v in ipairs(self.itemStoreDic) do
        if v.thisObj ~= nil then
            -- v.consumeMsg:DeleteMe()
            v.effect:DeleteMe()
            for i,vv in ipairs(v.imgSlotList) do
                vv:DeleteMe()
            end

            -- v.descText:DeleteMe()
        end
    end
    -- if self.curConsumeText ~= nil then
    --     self.curConsumeText:DeleteMe()
    -- end

    for k,v in pairs(self.giftItemIcon) do
        v:DeleteMe()
    end
    self.giftItemIcon = {}

    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    for k1,v1 in pairs(self.itemStoreDic) do
        for k2,v2 in pairs(v1.imgSlotList) do
            v2:DeleteMe()
        end
        for i,vv in ipairs(v1.effectList) do
            vv:DeleteMe()
        end
    end

    if self.Txt1 ~= nil then
        BaseUtils.ReleaseImage(self.Txt1)
        self.Txt1 = nil
    end

    if self.Txt2 ~= nil then
        BaseUtils.ReleaseImage(self.Txt2)
        self.Txt2 = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end

    self:AssetClearAll()
    -- self:RemovePetUpdateEvent()
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    self.gameObject = nil
    self.model = nil
end

function DragonBoatConsmRtnPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dragonboat_consumertn_panel))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)

    local timePanel = self.transform:Find("TImage")
    timePanel:GetComponent(RectTransform).anchoredPosition = Vector2(0,-145)
    self.lestTimeText = self.transform:Find("TImage/TBgImage/Text3"):GetComponent(Text) --剩余时间
    --等会看
    -- self.goRechargeBtn = self.transform:Find("RechargeButton"):GetComponent(Button)
    -- self.goRechargeBtn.onClick:AddListener(function ()
    --     self:ClickGoRechargeBtn()
    -- end)
    -- self.effect = BibleRewardPanel.ShowEffect(20118, self.goRechargeBtn.gameObject.transform, Vector3(1.1, 0.8,1), Vector3(-55,22.8,-100))

    self.transform:Find("LineImage").gameObject:SetActive(false)


    self.transform:Find("ItemParent"):GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChange() end)

    self.grid = self.transform:Find("ItemParent/ItemGrid")
    self.itemConsumeReward = self.grid:Find("Item").gameObject
    self.itemConsumeReward:SetActive(false)
    self.gpsLayout = LuaBoxLayout.New(self.grid.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4,scrollRect = self.grid.transform.parent:GetComponent(RectTransform)})
    self.itemStoreDic = {}

    UIUtils.AddBigbg(self.transform:Find("Bg/Panel"), GameObject.Instantiate(self:GetPrefab(self.bg)))
    self.Txt1 = self.transform:Find("Bg/Txt1"):GetComponent(Image)
    self.Txt1.sprite = self.assetWrapper:GetSprite(AssetConfig.dragonboat_topimage1,"WarmerTxt1")
    self.Txt1:SetNativeSize()
    self.Txt1.transform.anchoredPosition = Vector2(-75,12)

    self.Txt2 = self.transform:Find("Bg/Txt2"):GetComponent(Image)
    self.Txt2.sprite = self.assetWrapper:GetSprite(AssetConfig.dragonboat_topimage2,"WarmerTxt2")
    self.Txt2:SetNativeSize()
    self.Txt2.transform.anchoredPosition = Vector2(39,-36)

end

--前往充值
-- function DragonBoatConsmRtnPanel:ClickGoRechargeBtn()
--      WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
-- end

function DragonBoatConsmRtnPanel:UpdateWindow()
    self:UpdateConsumeList()
end

--获取活动表数据中 累消部分的数据
function DragonBoatConsmRtnPanel:GetDataList()
    local dataList = {}
    for i,v in ipairs(self.campaignGroup.sub) do
        table.insert(dataList,v)
    end
    table.sort(dataList,function (a,b)
        return a.target_val < b.target_val
        -- return a.baseData.group_index < b.baseData.group_index
    end)
    return dataList
end

--刷新累消奖励列表
function DragonBoatConsmRtnPanel:UpdateConsumeList()
    for i,v in ipairs(self.itemStoreDic) do
        if v.thisObj ~= nil then
            v.thisObj:SetActive(false)
        end
    end
    self.dataList = self:GetDataList()
    for i=1,#self.dataList do
        local itemTaken = self.itemStoreDic[i]
        local data = self.dataList[i]
        -- BaseUtils.dump(data,"self.model.petlist[i]")
        if itemTaken == nil then
            local obj = GameObject.Instantiate(self.itemConsumeReward)
            obj.name = tostring(i)

            self.gpsLayout:AddCell(obj)
            local imagesList = {
                      obj.transform:Find("Image1"):GetComponent(Image)
                    , obj.transform:Find("Image2"):GetComponent(Image)
                    , obj.transform:Find("Image3"):GetComponent(Image)
                    , obj.transform:Find("Image4"):GetComponent(Image)
                    , obj.transform:Find("Image5"):GetComponent(Image)
                    , obj.transform:Find("Image6"):GetComponent(Image)
                }
            local imagesListSlot = {}
            for i=1,6 do
                local slot = ItemSlot.New()
                local info = ItemData.New()
                -- local base = DataItem.data_get[tonumber(rewardData[1])]
                -- info:SetBase(base)
                local extra = {inbag = false, nobutton = true}
                slot:SetAll(info, extra)
                NumberpadPanel.AddUIChild(imagesList[i].gameObject, slot.gameObject)
                slot:ShowBg(false)
                table.insert(imagesListSlot,slot)
            end
            local itemDic = {
                index = i,
                thisObj = obj,
                dataItem = data,
                isLock = false,
                -- nobtn=obj.transform:Find("NoButton"), --未达成
                getbtn=obj.transform:Find("GetButton"):GetComponent(Button), --领取
                got = obj.transform:Find("Got").gameObject,
                consumeText = obj.transform:Find("Slider/Gold"):GetComponent(Text),
                slider = obj.transform:Find("Slider"):GetComponent(Slider),
                imgList = imagesList, --img list
                imgSlotList = imagesListSlot, --slot list
                -- condition = obj.transform:Find("Condition")
                effectList = {}
            }
            -- itemDic.consumeMsg = MsgItemExt.New(itemDic.consumeText, 227, 17, 20)
            self.itemStoreDic[i] = itemDic
            itemTaken = itemDic

            local fun = function(effectView)
                local effectObject = effectView.gameObject

                effectObject.transform:SetParent(itemDic.getbtn.transform)
                effectObject.transform.localScale = Vector3(1.6, 0.75, 1)
                effectObject.transform.localPosition = Vector3(-52, -17, -200)
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                effectObject:SetActive(true)
            end
            itemDic.effect = BaseEffectView.New({effectId = 20053, time = nil, callback = fun})

            itemDic.getbtn.onClick:AddListener(function ()
                self:ClickGetBtn(i)
            end)
        end
        itemTaken.dataItem = data

        --显示条件
        -- itemTaken.condition:Find("GoldNum").text = string.format("%d", itemTaken.dataItem.target_val)
        -- -----------------------处理货币 图标 --------Start
        -- local condIcon = itemTaken.condition:Find("Icon"):GetComponent(Image)
        -- if GlobalEumn.CostTypeIconName[KvData.assets[gold]] == nil then
        --     local id = condIcon.gameObject:GetInstanceID()
        --     if self.giftItemIcon[id] == nil then
        --         self.giftItemIcon[id] = SingleIconLoader.New(condIcon.gameObject)
        --     end
        --         self.giftItemIcon[id]:SetSprite(SingleIconType.Item, DataItem.data_get[KvData.assets[gold]].icon)
        -- else
        --     condIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[KvData.assets[gold]])
        -- end
        -----------------------处理货币 图标 --------End

        itemTaken.thisObj:SetActive(true)
        -- itemTaken.consumeMsg:SetData(string.format("消费达到<color='%s'>%d</color>{assets_2,90002}可领", "#13fc60",itemTaken.dataItem.target_val))
        -- 各部件 根据不同状态 显示or掩藏
        if itemTaken.dataItem.status == 0 then
            itemTaken.got:SetActive(false)
            itemTaken.getbtn.gameObject:SetActive(false)
            itemTaken.slider.gameObject:SetActive(true)

            itemTaken.slider.value = itemTaken.dataItem.value / itemTaken.dataItem.target_val
            itemTaken.consumeText.text = string.format("%d/%d",itemTaken.dataItem.value,itemTaken.dataItem.target_val)
        elseif itemTaken.dataItem.status == 1 then
            itemTaken.got:SetActive(false)
            itemTaken.getbtn.gameObject:SetActive(true)
            itemTaken.slider.gameObject:SetActive(false)
        elseif itemTaken.dataItem.status == 2 then
            itemTaken.got:SetActive(true)
            itemTaken.getbtn.gameObject:SetActive(false)
            itemTaken.slider.gameObject:SetActive(false)
        end

        local rewardDataList = CampaignManager.ItemFilter(DataCampaign.data_list[data.id].reward)
        -- BaseUtils.dump(itemTaken.dataItem.baseData.reward,"itemTaken.dataItem.baseData.reward")

        -- for _,v in ipairs(DataCampaign.data_list[data.id].reward) do
        --     if #v == 2 then
        --         table.insert(rewardDataList,v)
        --     elseif #v == 3 then
        --         table.insert(rewardDataList,{v[1],v[3]})
        --     elseif #v == 4 then
        --         if tonumber(v[1]) == 0 or tonumber(v[1]) == RoleManager.Instance.RoleData.classes then
        --             if tonumber(v[2]) == 2 or tonumber(v[2]) == RoleManager.Instance.RoleData.sex then
        --                 local newT = {}
        --                 table.insert(newT,v[3])
        --                 table.insert(newT,v[4])

        --                 table.insert(rewardDataList,newT)

        --             end
        --         end
        --     elseif #v == 6 then
        --         local it = {}
        --         for k=1,6 do
        --             it[k] = tonumber(v[k])
        --         end
        --         local bool_1_2 = it[1] == 0 and it[2] == 0
        --         local bool_1_2 = RoleManager.Instance.RoleData.lev >= it[1] and RoleManager.Instance.RoleData.lev <= it[2]
        --         local bool_2 = it[3] == 0 or it[3] == RoleManager.Instance.RoleData.classes
        --         local bool_3 = it[4] == 2 or it[4] == RoleManager.Instance.RoleData.sex
        --         if (bool_1_2 or bool_1_2) and bool_2 and bool_3 then
        --             local newT = {}
        --             table.insert(newT,v[5])
        --             table.insert(newT,v[6])
        --             table.insert(rewardDataList,newT)
        --             -- print(string.format(ColorHelper.DefaultStr,tostring(i).."获得一个Icon"))
        --         end
        --     end
        -- end

        --筛选带特效的 Item 的 ID
        local tbStr = DataCampaign.data_list[data.id].cond_desc
        local tbItem = nil
        if tbStr ~= "" then
            local tb = BaseUtils.unserialize(tbStr) -- 加特效的ID
            -- BaseUtils.dump(tb,"--------------------")
            tbItem = {}
            for kx,vx in pairs(tb) do
                tbItem[vx] = kx
            end
        end

        for c=1,6 do
            local itemSlot = itemTaken.imgSlotList[c]
            local itemImg = itemTaken.imgList[c]
            local rewardData = rewardDataList[c]

            if rewardData ~= nil then
                itemImg.gameObject:SetActive(true)
                local itemId = tonumber(rewardData[1])
                local base = DataItem.data_get[itemId]
                itemSlot.itemData:SetBase(base)
                itemSlot:SetAll(itemSlot.itemData,  {inbag = false, nobutton = true})
                itemSlot:SetNum(tonumber(rewardData[2]))

                --筛选表中指定Item 加包围特效
                local eff = itemImg.transform:Find("Effect")
                if eff ~= nil then
                    eff.gameObject:SetActive(true)
                end
                if tbItem ~= nil and tbItem[itemId] ~= nil and eff == nil then
                    --加特效
                    local e = BibleRewardPanel.ShowEffect(20223, itemImg.transform,Vector3(1, 1, 1), Vector3(0, 0, -400))
                     -- Vector3(1.1, 1.1, 1), Vector3(-4, -60, -400))
                    table.insert(itemTaken.effectList, e)
                end
            else
                itemImg.gameObject:SetActive(false)
            end
        end

        -- if i == 1 then
            -- self.curConsumeText.text = string.format("已累计消费:<color='%s'>%d</color>", ColorHelper.color[5],itemTaken.dataItem.value)
            -- self.curConsumeText:SetData(string.format("已累计消费:<color='%s'>%d</color>{assets_2,90002}", ColorHelper.color[5],itemTaken.dataItem.value))
        -- end
    end

    self:OnValueChange()


    if self.timerId ~= nil and self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
    end

    self:CalculateTime()




end


function DragonBoatConsmRtnPanel:OnValueChange()
    local w = self.grid.sizeDelta.y
    local y = self.grid.anchoredPosition.y
    for id,tab in ipairs(self.itemStoreDic) do

        local tr = tab.thisObj.transform
        if (-y > tr.anchoredPosition.y -15) and (tr.anchoredPosition.y  > -y - 270 + 69) then --344) then
            if tab.effect ~= nil then
                tab.effect:SetActive(true)
            end
            if nil ~= tab.effectList and #tab.effectList > 0 then
                for _,v in ipairs(tab.effectList) do
                    v:SetActive(true)
                end
            end
            -- if tab.data.quality > 3 or id == 1 then
            --     if tab.effect == nil then
            --         tab.effect = BibleRewardPanel.ShowEffect(20223, tab.slot.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
            --     else
            --         tab.effect:SetActive(true)
            --     end
            -- else
            --     if tab.effect ~= nil then
            --         tab.effect:SetActive(false)
            --     end
            -- end
        else
            if tab.effect ~= nil then
                tab.effect:SetActive(false)
            end
            if nil ~= tab.effectList and #tab.effectList > 0 then
                for _,v in ipairs(tab.effectList) do
                    v:SetActive(false)
                end
            end
        end
    end
end


--获得奖励按钮
function DragonBoatConsmRtnPanel:ClickGetBtn(index)
    local item = self.dataList[index]
    CampaignManager.Instance:Send14001(item.id)
end



function DragonBoatConsmRtnPanel:CalculateTime()
    local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))

    local beginTime = nil
    local endTime = nil
    -- local time = DataCampaign.data_list[3].day_time[1]
    local time1 = DataCampaign.data_list[self.dataList[1].id].cli_start_time[1]
    local time2 = DataCampaign.data_list[self.dataList[1].id].cli_end_time[1]
    beginTime = tonumber(os.time{year = time1[1], month = time1[2], day = time1[3], hour = time1[4], min = time1[5], sec = time1[6]})
    endTime = tonumber(os.time{year = time2[1], month = time2[2], day = time2[3], hour = time2[4], min = time2[5], sec = time2[6]})

    self.timestamp = 0

    if baseTime <= endTime and baseTime >= beginTime then
      self.timestamp = endTime - baseTime
    end

    self.timerId = LuaTimer.Add(0, 1000, function() self:TimeLoop() end)
end

function DragonBoatConsmRtnPanel:TimeLoop()
    if self.timestamp > 0 then
        local h = math.floor(self.timestamp / 3600)
        local mm = math.floor((self.timestamp - (h * 3600)) / 60 )
        local ss = math.floor(self.timestamp - (h * 3600) - (mm * 60))
        self.lestTimeText.text = h .. "时" .. mm .. "分" .. ss .. "秒"
        self.timestamp = self.timestamp - 1
    else
        self:EndTime()
    end
end

function DragonBoatConsmRtnPanel:EndTime()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end
