BibleSevendayPanel = BibleSevendayPanel or BaseClass(BasePanel)

function BibleSevendayPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = BibleManager.Instance

    self.resList = {
        {file = AssetConfig.bible_seven_panel, type = AssetType.Main}
    }

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateListener = function() self:UpdateServenDay() end
    self.slotList = {}
    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function BibleSevendayPanel:__delete()
    self.OnHideEvent:Fire()
    for k,v in pairs(self.slotList) do
        v:DeleteMe()
    end
    if self.sevendayLayout ~= nil then
        self.sevendayLayout:DeleteMe()
        self.sevendayLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BibleSevendayPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_seven_panel))
    self.gameObject.name = "SevendayPanel"
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    local panel = self.transform
    self.sevendayObjList = {nil, nil, nil, nil, nil, nil, nil}

    local layoutContainer = panel:Find("SevenDaysPanel/Container")
    self.sevendayLayout = LuaBoxLayout.New(layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.sevendayTemplate = layoutContainer:Find("Item").gameObject
    self.sevendayTemplate:SetActive(false)

    for i=1,7 do
        local obj = GameObject.Instantiate(self.sevendayTemplate)
        obj:SetActive(true)
        obj.name = tostring(i)

        self.sevendayLayout:AddCell(obj)
        obj.transform:Find("DayNoImage/Text"):GetComponent(Text).text = string.format(TI18N("第%s天"),tostring(i))
        obj.transform:Find("Button/Text"):GetComponent(Text).text = TI18N("领 取")
        local itemDic = {
            index = i,
            thisObj = obj,
            btn=obj.transform:Find("Button"):GetComponent(Button),
            btnText = obj.transform:Find("Button/Text"):GetComponent(Text),
            rtObj = obj.transform:Find("ReceivedText").gameObject,
            descText = obj.transform:Find("DescText"):GetComponent(Text),
            riObj1 = obj.transform:Find("RewardItem").gameObject,
            riObj1Image = obj.transform:Find("RewardItem/ribg"),
            riObj2 = obj.transform:Find("RewardItem2").gameObject,
            riObj2Image = obj.transform:Find("RewardItem2/ribg"),
        }
        self.sevendayObjList[i] = itemDic

        self:InitSevendayByIndex(i,itemDic)

        itemDic.btn.onClick:AddListener(function ()
            --点击领取
            --print("七天福利，点击领取"..itemDic.thisObj.name)
            BibleManager.Instance:send14101(itemDic.index, function()
                if self.dailyEffect ~= nil then
                    self.dailyEffect:DeleteMe()
                    self.dailyEffect = nil
                end
            end)
        end)
    end

    self.OnOpenEvent:Fire()
end

function BibleSevendayPanel:OnOpen()
    self:UpdateServenDay()

    self:RemoveListener()
    self.mgr.onUpdateSevenday:AddListener(self.updateListener)
end

function BibleSevendayPanel:OnHide()
    self:RemoveListener()
end

function BibleSevendayPanel:RemoveListener()
    self.mgr.onUpdateSevenday:RemoveListener(self.updateListener)
end

function BibleSevendayPanel:UpdateServenDay()
    BibleManager.Instance.redPointDic[1][2] = false
    self.mgr.onUpdateRedPoint:Fire()

    if BibleManager.Instance.servenDayData ~= nil then
        -- if self:CheckNeedShowSevenDay() == false then
        --     -- self.tabObjList[2]:SetActive(false)
        --     -- self.panelObjList[2]:SetActive(false)
        --     self:CheckRedPoint()
        --     return
        -- end
        for i,v in ipairs(BibleManager.Instance.servenDayData.seven_day) do
            local itemDic = self.sevendayObjList[i]
            if v.rewarded == 0 then
                itemDic.btn.gameObject:SetActive(true)
                itemDic.rtObj:SetActive(false)
            elseif v.rewarded == 1 then
                itemDic.btn.gameObject:SetActive(false)
                itemDic.rtObj:SetActive(true)
            end
        end
        local loginDays = #BibleManager.Instance.servenDayData.seven_day
        for i,v in ipairs(self.sevendayObjList) do
            if i>loginDays then
                --v.btn.interactable = false;
                v.btn.gameObject:SetActive(false)
                v.rtObj:SetActive(false)
            end
        end
        self:CheckRedPoint()
    end
end

function BibleSevendayPanel:CheckRedPoint()
end

function BibleSevendayPanel:InitSevendayByIndex(index,itemDic)
    local dataDay = DataCheckin.data_get_checkin_data[index]
    itemDic.descText.text = dataDay.desc;
    itemDic.btn.gameObject:SetActive(false)
    itemDic.rtObj:SetActive(false)
    local rewardData = BibleManager.ParaseReward(dataDay.reward)
    --Log.Error(#rewardData.." ----------InitSevendayByIndex")
    for i,v in ipairs(rewardData) do
        local img = nil
        if i == 1 then
            img = itemDic.riObj1Image
        else --if i == 2 then
            img = itemDic.riObj2Image
        end
        local slot = ItemSlot.New()
        local itemdata = ItemData.New()
        local cell = v.dataItem
        itemdata:SetBase(cell)
        slot:SetAll(itemdata, {inbag = false, nobutton = true})
        NumberpadPanel.AddUIChild(img.gameObject, slot.gameObject)
        slot:SetNum(v.count)
        table.insert(self.slotList, slot)
        -- for i=1,#cell.effect do
        --     if cell.effect[i].effect_type == 19 then
        --         slot:SetNotips(true)
        --         slot:SetSelectSelfCallback(function() PetManager.Instance.model:show_pet_egg(cell.id) end)
        --     end
        -- end
    end
end