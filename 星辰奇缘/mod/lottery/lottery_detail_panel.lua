-- --------------------------------------------
-- 一闷夺宝详情界面
-- hosr
-- --------------------------------------------
LotteryDetailPanel = LotteryDetailPanel or BaseClass(BasePanel)

function LotteryDetailPanel:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.lottery_detail, type = AssetType.Main},
        {file = AssetConfig.lottery_res, type = AssetType.Dep},
    }

    self.myNumCurPage = 1

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.onUpdateMyNum = function(dat)
        self:UpdateMyNumPage(dat)
    end
end

function LotteryDetailPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.lottery_my_num_update, self.onUpdateMyNum)

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
end

function LotteryDetailPanel:OnShow()
    self.data = self.openArgs
    self:SetData()
    self.tabGroup:ChangeTab(1)
end

function LotteryDetailPanel:OnHide()
end

function LotteryDetailPanel:Close()
    self.model:CloseDetail()
end

function LotteryDetailPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.lottery_detail))
    self.gameObject.name = "LotteryDetailPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    local top = self.transform:Find("Main/Top")
    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(top:Find("Slot").gameObject, self.slot.gameObject)

    self.name = top:Find("Name"):GetComponent(Text)
    self.number = top:Find("Number/Val"):GetComponent(Text)
    self.lucky = top:Find("Lucky/Val"):GetComponent(Text)
    self.time = top:Find("Time/Val"):GetComponent(Text)
    self.winner = top:Find("Winner/Val"):GetComponent(Text)

    self.tabGroupObj = top:Find("TabButtonGroup").gameObject
    local setting = {
        notAutoSelect = true,
        noCheckRepeat = false,
        perWidth = 120,
        perHeight = 42,
        isVertical = false
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:TabChange(index) end, setting)

    self.panel1 = self.transform:Find("Main/Panel1").gameObject
    self.panel1Trans = self.panel1.transform
    self.myJoin =  self.panel1Trans:Find("MyJoin"):GetComponent(Text)
    self.leftArrowBtn = self.panel1Trans:FindChild("LeftArrowCon"):GetComponent(Button)
    self.rightArrowBtn = self.panel1Trans:FindChild("RightArrowCon"):GetComponent(Button)
    self.ItemPage = self.panel1Trans:Find("Scroll/Container/ItemPage")
    self.MyNumItemList = {}
    for i=1, 36 do
        table.insert(self.MyNumItemList, self.ItemPage:FindChild(tostring(i)):GetComponent(Text))
        self.MyNumItemList[i].text = ""
    end

    self.panel2 = self.transform:Find("Main/Panel2").gameObject
    self.panel2Trans = self.panel2.transform
    self.desc1 = self.panel2Trans:Find("Container/Desc1"):GetComponent(Text)
    self.desc1Rect = self.desc1.gameObject:GetComponent(RectTransform)

    self.desc1.text = TI18N("·奖品满足其总参与人次时，即进入<color='#13fc60'>3分钟</color>的倒计时揭晓阶段。\n·倒计时结束时截取最后<color='#13fc60'>20条</color>所有奖品的参与记录。\n·根据<color='#13fc60'>20条</color>真实参与记录的时间求合，除以本奖品所需总人次，所得余数即是本奖品本期<color='#13fc60'>幸运号码</color>。")

    self.desc2Rect = self.panel2Trans:Find("Container/Desc2"):GetComponent(RectTransform)
    self.DescTimeTotalTitle = self.panel2Trans:Find("Container/Desc2/DescI18N"):GetComponent(Text)
    self.DescTimeTotal = self.panel2Trans:Find("Container/Desc2/DescTimeTotal"):GetComponent(Text)
    self.DescManNum = self.panel2Trans:Find("Container/Desc2/DescManNum"):GetComponent(Text)
    self.DescLeft = self.panel2Trans:Find("Container/Desc2/DescLeft"):GetComponent(Text)

    --抽号规则底部的gameObject
    self.desc3Rect = self.panel2Trans:Find("Container/Desc3"):GetComponent(RectTransform)
    self.desc3Tips = self.panel2Trans:Find("Container/Desc3/Desc"):GetComponent(Text)
    self.desc3ItemCon = self.panel2Trans:Find("Container/Desc3/Detail")
    self.desc3ItemList = {}
    for i=1, 20 do
        local item = self.desc3ItemCon:Find(tostring(i))
        table.insert(self.desc3ItemList, item)
    end

    self.leftArrowBtn.onClick:AddListener(function()
        self:TurnToLeftPage()
    end)
    self.rightArrowBtn.onClick:AddListener(function()
        self:TurnToRightPage()
    end)

    self:OnShow()

    EventMgr.Instance:AddListener(event_name.lottery_my_num_update, self.onUpdateMyNum)
end

function LotteryDetailPanel:SetData()
    self.itemData = ItemData.New()
    self.itemData:SetBase(BaseUtils.copytab(DataItem.data_get[self.data.item_id]))
    self.itemData.quantity = self.data.item_count
    self.slot:SetAll(self.itemData)

    self.DescTimeTotalTitle.text = string.format("%s%s  /  %s  =   %s", #self.data.history_list, TI18N("条记录时间总和"), TI18N("总需人次"), TI18N("结果取余数"))
    self.DescTimeTotal.text = tostring(self.data.num_sum)
    self.DescManNum.text = tostring(self.data.times_sum)
    self.DescLeft.text = self:GetNumber(self.data.lucky_num)

    self.name.text = ColorHelper.color_item_name(self.itemData.quality, self.itemData.name)
    self.number.text = tostring(self.data.idx)
    self.lucky.text = self:GetNumber(self.data.lucky_num)
    if self.data.role_name ~= "" then
        self.time.text = os.date("%m/%d %H:%M", self.data.time)
    else
        self.time.text = TI18N("进行中")
    end
    local tempStr = self.data.role_name == "" and TI18N("暂无") or self.data.role_name
    self.winner.text = tempStr

    self:UpdateExtractItemList()
end

function LotteryDetailPanel:TabChange(index)
    if index == 1 then
        self.panel2:SetActive(false)
        self.panel1:SetActive(true)
        LotteryManager:Send16906(self.data.idx, 1)
    elseif index == 2 then
        self.panel1:SetActive(false)
        self.panel2:SetActive(true)

        LotteryManager.Instance:Send16901(1)
    end
end

-----------------我的号码逻辑
--我的号码，左翻页
function LotteryDetailPanel:TurnToLeftPage()
    if self.myNumCurPageData.page_now > 0 then
        LotteryManager:Send16906(self.data.idx, self.myNumCurPageData.page_now-1)
    end
end

--我的号码，右翻页
function LotteryDetailPanel:TurnToRightPage()
    if self.myNumCurPageData.page_now < self.myNumCurPageData.page_sum then
        LotteryManager:Send16906(self.data.idx, self.myNumCurPageData.page_now+1)
    end
end

--更新我的号码页
function LotteryDetailPanel:UpdateMyNumPage(dat)
    self.myNumCurPageData = dat
    self.leftArrowBtn.gameObject:SetActive(true)
    self.rightArrowBtn.gameObject:SetActive(true)

    if self.myNumCurPageData.page_now == 1 then
        --没左
        self.leftArrowBtn.gameObject:SetActive(false)
        self.rightArrowBtn.gameObject:SetActive(true)
    end
    if self.myNumCurPageData.page_now == self.myNumCurPageData.page_sum then
        --没右
        self.leftArrowBtn.gameObject:SetActive(true)
        self.rightArrowBtn.gameObject:SetActive(false)
    end
    if self.myNumCurPageData.page_sum == 1 then
        --只有一页的情况
        self.leftArrowBtn.gameObject:SetActive(false)
        self.rightArrowBtn.gameObject:SetActive(false)
    end
    if self.myNumCurPageData.page_sum == 0 then
        --没有数据，我未参与
        self.leftArrowBtn.gameObject:SetActive(false)
        self.rightArrowBtn.gameObject:SetActive(false)
        self.panel1Trans:Find("Scroll").gameObject:SetActive(false)
        self.panel1Trans:Find("Nothing").gameObject:SetActive(true)
    else
        self.panel1Trans:Find("Scroll").gameObject:SetActive(true)
        self.panel1Trans:Find("Nothing").gameObject:SetActive(false)
        --我已经参与
        for i=1,#self.MyNumItemList do
            local tempDat = self.myNumCurPageData.num_list[i]
            if tempDat ~= nil then
                local tempStr = tostring(tempDat.num)
                if tempDat.num < 10 then
                    tempStr = string.format("0000%s", tempStr)
                elseif tempDat.num < 100 then
                    tempStr = string.format("000%s", tempStr)
                elseif tempDat.num < 1000 then
                    tempStr = string.format("00%s", tempStr)
                elseif tempDat.num < 10000 then
                    tempStr = string.format("0%s", tempStr)
                end
                self.MyNumItemList[i].text = tempStr
            else
                self.MyNumItemList[i].text = ""
            end
        end
    end
end

-------------------------抽号规格逻辑
function LotteryDetailPanel:UpdateExtractItemList()
    self.desc3Tips.text = string.format("%s%s=%s", #self.data.history_list, TI18N("条记录时间总和"), tostring(self.data.num_sum))

    if #self.data.history_list == 0 or self.data.role_name == "" then
        self.panel2Trans:Find("Container/Desc2").gameObject:SetActive(false)
        self.panel2Trans:Find("Container/Desc3").gameObject:SetActive(false)
        self.desc3ItemCon.gameObject:SetActive(false)
    else
        self.panel2Trans:Find("Container/Desc2").gameObject:SetActive(true)
        self.panel2Trans:Find("Container/Desc3").gameObject:SetActive(true)
        for i=1,#self.desc3ItemList do
            self.desc3ItemList[i].gameObject:SetActive(false)
        end
        self.desc3ItemCon.gameObject:SetActive(true)
        for i=1,#self.data.history_list do
            local tempData = self.data.history_list[i]
            local dataBase = DataItem.data_get[tempData.item_id]
            local timeStr = os.date("%H:%M:%S", tempData.time)
            local item = self.desc3ItemList[i]
            item.gameObject:SetActive(true)
            item:Find("Text1"):GetComponent(Text).text = timeStr
            item:Find("Text2"):GetComponent(Text).text = tostring(tempData.num)
            item:Find("Text3"):GetComponent(Text).text = tempData.role_name
            item:Find("Text4"):GetComponent(Text).text = ColorHelper.color_item_name(dataBase.quality, dataBase.name)
            item:Find("Text5"):GetComponent(Text).text = tostring(tempData.count)
        end

        --自适应下高宽
        local newPanelHeight = 216
        local newDescHeight = 104
        local newDetailHeight = 50
        if #self.data.history_list > 0 then
            local itemsHeight = 28*#self.data.history_list
            newDescHeight = newDescHeight + itemsHeight
            newDetailHeight = newDetailHeight + itemsHeight
            newPanelHeight = newPanelHeight + newDetailHeight + 55
            self.panel2Trans:Find("Container/Desc3").gameObject:SetActive(true)
        end
        self.panel2Trans:Find("Container"):GetComponent(RectTransform).sizeDelta = Vector2(570, newPanelHeight)
        self.panel2Trans:Find("Container/Desc3"):GetComponent(RectTransform).sizeDelta = Vector2(545, newDescHeight)
        self.desc3ItemCon:GetComponent(RectTransform).sizeDelta = Vector2(540, newDetailHeight)
    end
end


function LotteryDetailPanel:GetNumber(num)
    if num == 0 then
        return "--"
    end
    local list = StringHelper.ConvertStringTable(tostring(num))
    local need = 5 - #list
    local before = ""
    for i= 1, need do
        before = before .. "0"
    end
    return before .. tostring(num)
end