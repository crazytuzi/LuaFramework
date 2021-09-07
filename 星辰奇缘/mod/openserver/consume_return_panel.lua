ConsumeReturnPanel = ConsumeReturnPanel or BaseClass(BasePanel)

function ConsumeReturnPanel:__init(model,parent)
    self.model = model
    self.name = "ConsumeReturnPanel"
    self.parent = parent

    self.resList = {
        {file = AssetConfig.consume_return_panel, type = AssetType.Main},
        {file = AssetConfig.open_server_charge_bg, type = AssetType.Main},
    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:UpdateWindow()
    end)
    self.OnHideEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        -- self:RemovePetUpdateEvent()
    end)

    self.dataList = nil
    self.timerId = 0

    self.get_campaign_reward_success = function ()
        self:UpdateWindow()
    end

    -- self.petStoreUpdateFun = function ()
    --     self:UpdateStorePet()
    -- end

    -- self.petreleasepanel = nil
    EventMgr.Instance:AddListener(event_name.get_campaign_reward_success, self.get_campaign_reward_success)
    -- EventMgr.Instance:AddListener(event_name.petstore_update, self.petStoreUpdateFun)
end

function ConsumeReturnPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function ConsumeReturnPanel:__delete()

    EventMgr.Instance:RemoveListener(event_name.get_campaign_reward_success, self.get_campaign_reward_success)
    -- EventMgr.Instance:RemoveListener(event_name.petstore_update, self.petStoreUpdateFun)
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
    end
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
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    for k1,v1 in pairs(self.itemStoreDic) do
        for k2,v2 in pairs(v1.imgSlotList) do
            v2:DeleteMe()
        end
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

function ConsumeReturnPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.consume_return_panel))
    self.transform = self.gameObject.transform
	UIUtils.AddUIChild(self.parent, self.gameObject)

    -- self.consumTxt = self.transform:Find("TImage/Text1"):GetComponent(Text)
    -- self.curConsumeText = MsgItemExt.New(self.consumTxt, 250, 17, 21)  --当前已消费
    self.lestTimeText = self.transform:Find("TImage/TBgImage/Text3"):GetComponent(Text) --剩余时间

    self.goRechargeBtn = self.transform:Find("RechargeButton"):GetComponent(Button)
    self.goRechargeBtn.onClick:AddListener(function ()
        self:ClickGoRechargeBtn()
    end)

    self.grid = self.transform:Find("ItemParent/ItemGrid")
    self.itemConsumeReward = self.grid:Find("Item").gameObject
    self.itemConsumeReward:SetActive(false)
    self.gpsLayout = LuaBoxLayout.New(self.grid.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4,scrollRect = self.grid.transform.parent:GetComponent(RectTransform)})
    self.itemStoreDic = {}
    self.effect = BibleRewardPanel.ShowEffect(20118, self.goRechargeBtn.gameObject.transform, Vector3(1.1, 0.8,1), Vector3(-55,22.8,-100))

    UIUtils.AddBigbg(self.transform:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_charge_bg)))
end

--前往充值
function ConsumeReturnPanel:ClickGoRechargeBtn()
     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1})
end

function ConsumeReturnPanel:UpdateWindow()
    self:UpdateConsumeList()
end
function ConsumeReturnPanel:GetDataList()
    local dataList = {}
    local dataItemList = CampaignManager.Instance:GetCampaignDataList(CampaignEumn.Type.OpenServer)
    for i,v in ipairs(dataItemList) do
        local baseData = DataCampaign.data_list[v.id]
        if baseData ~= nil and baseData.index == CampaignEumn.OpenServerType.ConsumeReturn then
            v.baseData = baseData
            table.insert(dataList,v)
        end
    end
    table.sort(dataList,function (a,b)
        return a.baseData.group_index < b.baseData.group_index
    end)
    return dataList
end
--
function ConsumeReturnPanel:UpdateConsumeList()
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
                }
            local imagesListSlot = {}
            for i=1,5 do
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

        itemTaken.thisObj:SetActive(true)
        -- itemTaken.consumeMsg:SetData(string.format("消费达到<color='%s'>%d</color>{assets_2,90002}可领", "#13fc60",itemTaken.dataItem.target_val))
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

        local rewardDataList = {}
        for i,v in ipairs(itemTaken.dataItem.baseData.reward) do
            if #v == 2 then
                table.insert(rewardDataList,v)
            elseif #v == 3 then
                table.insert(rewardDataList,{v[1],v[3]})
            elseif #v == 4 then
                if tonumber(v[1]) == 0 or tonumber(v[1]) == RoleManager.Instance.RoleData.classes then
                    if tonumber(v[2]) == 2 or tonumber(v[2]) == RoleManager.Instance.RoleData.sex then
                        local newT = {}
                        table.insert(newT,v[3])
                        table.insert(newT,v[4])

                        table.insert(rewardDataList,newT)
                    end
                end
            end
        end

        for i=1,5 do
            local itemSlot = itemTaken.imgSlotList[i]
            local itemImg = itemTaken.imgList[i]
            local rewardData = rewardDataList[i]
            if rewardData ~= nil then
                itemImg.gameObject:SetActive(true)
                local base = DataItem.data_get[tonumber(rewardData[1])]
                itemSlot.itemData:SetBase(base)
                itemSlot:SetAll(itemSlot.itemData,  {inbag = false, nobutton = true})
                itemSlot:SetNum(tonumber(rewardData[2]))
            else
                itemImg.gameObject:SetActive(false)
            end
        end

        if i == 1 then
            -- self.curConsumeText.text = string.format("已累计消费:<color='%s'>%d</color>", ColorHelper.color[5],itemTaken.dataItem.value)
            -- self.curConsumeText:SetData(string.format("已累计消费:<color='%s'>%d</color>{assets_2,90002}", ColorHelper.color[5],itemTaken.dataItem.value))
        end
    end

    if self.timerId ~= nil and self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
    end
    local dataT = self.dataList[1].baseData

    local openTime = CampaignManager.Instance.open_srv_time
    local hour = tonumber(os.date("%H",openTime))*3600
    hour = hour + tonumber(os.date("%M",openTime))*60
    hour = hour + tonumber(os.date("%S",openTime))
    local cli_end_time = dataT.cli_end_time[1]
    local endTime = openTime - hour + cli_end_time[2] * 86400 + cli_end_time[3]

    self.timeCount = endTime
    self.timerId = LuaTimer.Add(0, 1000, function()

        if self.timeCount > BaseUtils.BASE_TIME then

            local day,hour,min,second = BaseUtils.time_gap_to_timer(self.timeCount - BaseUtils.BASE_TIME)
            local timeStr = tostring(day)
            if day < 10 then
                timeStr = string.format("0%s",tostring(day))
            end
            if hour < 10 then
                if hour == 0 and (min > 0 or second > 0) then
                    hour = 1
                end
                timeStr = string.format(TI18N("%s天0%s小时"),timeStr,tostring(hour))
            else
                timeStr = string.format(TI18N("%s天%s小时"),timeStr,tostring(hour))
            end
            -- if second < 10 then
            --      timeStr = timeStr.."小时0"..second.."秒"
            -- else
            --     timeStr = timeStr.."小时"..second.."秒"
            -- end

            self.lestTimeText.text = timeStr --BaseUtils.formate_time_gap(self.countDataBefore,":",0,BaseUtils.time_formate.MIN)
        else
            self.lestTimeText.text = TI18N("00天00小时")
            -- self.countDataBefore = 0
            LuaTimer.Delete(self.timerId)
        end
    end)
end

function ConsumeReturnPanel:ClickGetBtn(index)
    local item = self.dataList[index]
    CampaignManager.Instance:Send14001(item.id)
end