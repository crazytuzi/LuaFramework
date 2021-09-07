-- @author zyh
-- @date 2017年7月10日

SevendayOther = SevendayOther or BaseClass(BasePanel)

function SevendayOther:__init(model, parent ,parentTable)

    self.model = model
    self.parent = parent
    self.parentTable = parentTable
    self.name = "SevendayOther"
    self.mgr = SevendayManager.Instance

    self.resList = {
        {file = AssetConfig.sevenday_other, type = AssetType.Main},
        {file = AssetConfig.sevenday_textures, type = AssetType.Dep},
        {file = AssetConfig.masquerade_textures, type = AssetType.Dep},
        {file = AssetConfig.sevenday_other_bg,type = AssetType.Main}
    }

    self.updateItemStatusListener = function() self:UpdateItemListStatus() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.effectList = {}

    self.updateScrollBarListener = function() self:UpdateScrollBar() end

    self.extra = {inbag = false, nobutton = true}
    self.scrollRectLength = 0
    self.tabList = {}
    self.scrollBarIndex = 0
    self.myBorder = 5
    self.scrollRectOffect = 54
    self.scrollBarOffect = 3.5

    self.hasGotList = {}

    self.lastTab = nil
end

function SevendayOther:__delete()

    self.OnHideEvent:Fire()

    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end

    for i,v in ipairs(self.tabList) do
        if v.layout ~= nil then
            v.layout:DeleteMe()
            v.layout = nil
        end

        if v.rewardList ~= nil then
            for k,v in pairs(v.rewardList) do
                v:DeleteMe()
            end
            v.rewardList = nil
        end

        if v.effectList ~= nil then
            for k,v in pairs(v.effectList) do
                v:DeleteMe()
            end
            v.effectList = nil
        end
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SevendayOther:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sevenday_other))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t


    self.container = t:Find("ScrollLayer/Container")
    self.cloner = t:Find("ScrollLayer/Cloner").gameObject
    self.scrollTrans = t:Find("ScrollLayer")
    self.scrollRectLay = t:Find("ScrollLayer"):GetComponent(ScrollRect)
    self.scrollRectLay.onValueChanged:AddListener(function(value) self:OnValueChanged(value) end)
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 10, border = self.myBorder})
    self.scrollRect = t:Find("ScrollLayer/Container/ProgBarBg")
    self.progBar = t:Find("ScrollLayer/Container/ProgBarBg/ProgBar")
    self.progBar.anchoredPosition = Vector2(5.34,-3.5)
    self.lineTemplate = t:Find("ScrollLayer/Container/ProgBarBg/LineTemplate")
    self.lineNotice = t:Find("ScrollLayer/Container/ProgBarBg/Notice")
    self.lineText = t:Find("ScrollLayer/Container/ProgBarBg/Notice/Text"):GetComponent(Text)

    self.bigBg = t:Find("Bg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.sevenday_other_bg))
    UIUtils.AddBigbg(self.bigBg, bigObj)
    bigObj.transform.anchoredPosition = Vector2(0, 0)

    self:UpdateItemList()
end

function SevendayOther:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SevendayOther:OnOpen()
    local model = self.model
    self:RemoveListeners()
    self:AddListeners()
    self:UpdateScrollBar()

    -- self.updateListener()
end

function SevendayOther:UpdateItemList()
    local totalNum = DataGoal.data_get_complete[#DataGoal.data_get_complete].count
    for i,v in ipairs(DataGoal.data_get_complete) do
        local tab = {}
        local go = GameObject.Instantiate(self.cloner)
        local template = GameObject.Instantiate(self.lineTemplate)
        -- go.transform:GetComponent(Button).onClick:AddListener(function() self:ChangeTab(go) end)
        template.transform:SetParent(self.scrollRect.transform)
        template.transform.localScale = Vector3(1, 1, 1)
        template.transform.localPosition = Vector3.zero

        template.transform.anchoredPosition = Vector2(0,- ((i-1) * (self.myBorder + self.cloner.transform.sizeDelta.y/2) + i * self.cloner.transform.sizeDelta.y/2))

        template.transform:Find("Image/Text"):GetComponent(Text).text = v.count


        tab.go = go
        local finishNum = self.parentTable.model:GetFinishTargetNum()
        tab.count = v.count
        tab.titleText = go.transform:Find("WelfareCon/I18N_Title"):GetComponent(Text)
        tab.titleText.text = string.format("目标进度达到%s(<color='#13fc60'>%s</color>/%s)",v.count,finishNum,v.count)

        tab.scrollTrans = go.transform:Find("WelfareCon/ScrollLayer"):GetComponent(ScrollRect)
        tab.container = go.transform:Find("WelfareCon/ScrollLayer/Container")
        tab.layout = LuaBoxLayout.New(tab.container,{axis = BoxLayoutAxis.X,cspacing = 0,border = 5})
        tab.btn = go.transform:Find("WelfareCon/Button"):GetComponent(Button)
        tab.btn.onClick:AddListener(function() self:ApplyTabBtn(i) end)
        tab.hasGet = go.transform:Find("WelfareCon/ReceivedText")
        tab.notBtn = go.transform:Find("WelfareCon/NotButton")




        if finishNum < DataGoal.data_get_complete[i].count and self.hasGotList[i] ~= true then
            tab.btn.gameObject:SetActive(false)
        else

        end

        tab.rewardList = {}
        tab.effectList = {}
        for i,v in ipairs(v.item_reward) do
            local itemSlot = ItemSlot.New()
            local Num = v[2]
            local Id = v[1]
            local itemData = DataItem.data_get[Id]
            itemSlot:SetAll(itemData,self.extra)
            itemSlot:SetNum(Num)
            table.insert(tab.rewardList,itemSlot)
            tab.layout:AddCell(itemSlot.gameObject)

            if itemData.quality >= 4 then
                local effect = nil
                effect = BibleRewardPanel.ShowEffect(20223, itemSlot.gameObject.transform, Vector3(1, 1, 1), Vector3(32,0, -400))
                effect:SetActive(true)

                table.insert(tab.effectList,effect)
            end
        end


        if tab.layout.panelRect.sizeDelta.x < 290 then
            tab.scrollTrans.movementType = ScrollRect.MovementType.Clamped
            tab.scrollTrans.enabled = false
        else
            tab.scrollTrans.movementType = ScrollRect.MovementType.Elastic
            tab.scrollTrans.enabled = true
        end
        self.layout:AddCell(tab.go.gameObject)
        table.insert(self.tabList,tab)
    end

    self.lineNotice.gameObject.transform:SetSiblingIndex(self.progBar.gameObject.transform.parent.childCount - 1);
    self.cloner.gameObject:SetActive(false)
    self.lineTemplate.gameObject:SetActive(false)

    local length = (#DataGoal.data_get_complete - 0.5)  * self.cloner.transform.sizeDelta.y + (#DataGoal.data_get_complete - 1) * self.myBorder + self.scrollRectOffect
    self.scrollRect.transform:GetComponent(RectTransform).sizeDelta = Vector2(30.5,length)
    self.scrollRectLength = self.scrollRect:GetComponent(RectTransform).sizeDelta.y
end

function SevendayOther:UpdateScrollBar()
    local finishNum = self.model:GetFinishTargetNum()

    local distance = 0
    local lastNum = 0
    local distanceNum = 0
    for i,v in ipairs(DataGoal.data_get_complete) do
        if finishNum < v.count then
            self.scrollBarIndex = i
            distance = finishNum - lastNum
            distanceNum = v.count - lastNum
            break
        end
        lastNum = v.count
    end

    local distanceLength = 0
    if self.scrollBarIndex == 1 then
        distanceLength = self.cloner.transform.sizeDelta.y/2 * (distance / distanceNum)
    else
        distanceLength = (self.cloner.transform.sizeDelta.y + self.myBorder) * (distance / distanceNum)
    end
    -- print("==============================================================================================进度条的长度")
    -- print(distanceLength)
    -- print(distance / distanceNum)
    -- print()

    -- local length = ((self.scrollBarIndex-1) * (self.myBorder + self.cloner.transform.sizeDelta.y/2) + (self.scrollBarIndex - 1) * self.cloner.transform.sizeDelta.y/2) + distanceLength - self.scrollBarOffect
    local length = 0
    if self.scrollBarIndex > 1 then
        length = (self.scrollBarIndex-2) * (self.myBorder + self.cloner.transform.sizeDelta.y/2) + (self.scrollBarIndex - 1) * self.cloner.transform.sizeDelta.y/2 + distanceLength - self.scrollBarOffect
    else
        length = distanceLength - self.scrollBarOffect
    end


    self.progBar:GetComponent(RectTransform).sizeDelta = Vector2(20,length)
    self.lineNotice.transform.anchoredPosition = Vector2(0,-length)
    self.lineText.text = finishNum


    self:HasGoList()
    self:UpdateItemListStatus()

end


function SevendayOther:OnHide()
    self:RemoveListeners()
end


function SevendayOther:RemoveListeners()
    SevendayManager.Instance.onUpdateOther:RemoveListener(self.updateScrollBarListener)
    EventMgr.Instance:RemoveListener(event_name.seven_day_target_upgrade,self.updateScrollBarListener)
end


function SevendayOther:AddListeners()
    SevendayManager.Instance.onUpdateOther:AddListener(self.updateScrollBarListener)
    EventMgr.Instance:AddListener(event_name.seven_day_target_upgrade,self.updateScrollBarListener)
end

-- function SevendayOther:ChangeTab(obj)
--     if self.lastTab ~= nil then
--         self.lastTab.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.sevenday_textures, "ItemBg")
--         self.lastTab.transform:Find("WelfareCon/Angle"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.sevenday_textures, "NormalAngle")
--         self.lastTab.transform:Find("WelfareCon/TitleBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.sevenday_textures, "TitleBg")
--     end

--     local scrollRectImage = obj.transform:GetComponent(Image)
--     local angleImage = obj.transform:Find("WelfareCon/Angle"):GetComponent(Image)
--     local titleBgImage = obj.transform:Find("WelfareCon/TitleBg"):GetComponent(Image)
--     scrollRectImage.sprite = self.assetWrapper:GetSprite(AssetConfig.sevenday_textures, "ScrollRectSelect")
--     angleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.sevenday_textures, "SelectAngle")
--     titleBgImage.sprite = self.assetWrapper:GetSprite(AssetConfig.sevenday_textures, "SelectTitleBg")
--     self.lastTab = obj

-- end

function SevendayOther:ApplyTabBtn(index)


    SevendayManager.Instance:send10241(DataGoal.data_get_complete[index].count)
end


function SevendayOther:HasGoList()
    if self.model.complete_list ~= nil then
        for i = 1, #DataGoal.data_get_complete do
            local cfgData = DataGoal.data_get_complete[i]
            local hasNotGet = true --还没有领取这个位置的奖励
            for k, v in pairs(self.model.complete_list) do
                if v.count == cfgData.count then
                    hasNotGet = false --已经领取了
                    self.hasGotList[i] = true
                    break
                end
            end
        end
    end
end

function SevendayOther:UpdateItemListStatus()
    for i,v in ipairs(self.tabList) do
        local finishNum = self.parentTable.model:GetFinishTargetNum()
        if finishNum >= DataGoal.data_get_complete[i].count and self.hasGotList[i] ~= true then
            v.btn.gameObject:SetActive(true)
            v.hasGet.gameObject:SetActive(false)
            v.notBtn.gameObject:SetActive(false)
        elseif finishNum < DataGoal.data_get_complete[i].count then
            v.btn.gameObject:SetActive(false)
            v.hasGet.gameObject:SetActive(false)
            v.notBtn.gameObject:SetActive(true)
        else
            v.btn.gameObject:SetActive(false)
            v.hasGet.gameObject:SetActive(true)
            v.notBtn.gameObject:SetActive(false)
        end

        v.titleText.text = string.format("目标进度达到%s(<color='#13fc60'>%s</color>/%s)",v.count,finishNum,v.count)
    end

end

function SevendayOther:OnValueChanged(value)

     local Top = (value.y-1)*(self.scrollRectLay.content.sizeDelta.y - 350)
     local Bot = Top - 300

     for i,v in ipairs(self.tabList) do
       local ay = v.go.transform.anchoredPosition.y
       local sy = v.go.transform.sizeDelta.y

       if ay-sy>Top or ay < Bot then
            for k,v2 in pairs(v.effectList) do
                v2:SetActive(false)
            end

       else
           for k,v2 in pairs(v.effectList) do
                v2:SetActive(true)
            end
       end
     end

end


