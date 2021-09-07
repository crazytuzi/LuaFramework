-- -----------------------------------------
-- 一闷夺宝道具展示界面
-- hosr
-- -----------------------------------------
LotteryShowPanel = LotteryShowPanel or BaseClass(BasePanel)

function LotteryShowPanel:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.lottery_show, type = AssetType.Main},
        {file = AssetConfig.lottery_res, type = AssetType.Dep},
        {file = AssetConfig.button1, type = AssetType.Dep},
        {file = AssetConfig.guidegirl2, type = AssetType.Dep},
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.objList = {}
    self.itemTab = {}
    self.filterTypes = {
        [1] = TI18N("宠物"),
        [2] = TI18N("坐骑"),
        [3] = TI18N("外观"),
        [4] = TI18N("珍宝")
    }--暂时没有XX商品，请查看其它类别

    self.txtYs = {
        [0] = 270,
        [1] = 240,
        [2] = 210,
        [3] = 180,
        [4] = 150,
        [5] = 120,
        [6] = 90,
        [7] = 60,
        [8] = 30,
        [9] = 0
    }
    self.freshTime = 5
    self.timerId = 0
    self.curJoinMemNum = 0
    self.tweeenHistoryDataIndex = 9
    self.tweenHistoryItemIndex = 0
    self.listener = function() self:Update() end
    self.updateFocus = function(idx) self:UpdateFocus(idx) end
    self.tweenHistory = false
    self.hasInit = false
    self.curFilterType = 0
end

function LotteryShowPanel:__delete()
    self.tweenHistory = false
    self.hasInit = false
    self:stop_timer()
    if self.msgItem ~= nil then
        self.msgItem:DeleteMe()
        self.msgItem = nil
    end
    EventMgr.Instance:RemoveListener(event_name.lottery_main_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.lottery_focus_update, self.updateFocus)

    for i,v in ipairs(self.itemTab) do
    	v:DeleteMe()
    end
    self.itemTab = nil
end



function LotteryShowPanel:OnShow()
    self.index = self.openArgs or 0
    self:Update()
    if self.index > 0 then
        LotteryManager.Instance:RefreshData(self.index)
    end
end

function LotteryShowPanel:OnHide()
    self:stop_timer()
end

function LotteryShowPanel:Update()
    self:SortData(self.curFilterType)
    self:SetData(true)
    self:UpdateTime()
    self:UpdateHistory()
end

--filterType传过滤了II型，0为不过滤
function LotteryShowPanel:SortData(filterType)
    self.dataList = LotteryManager.Instance:GetListData(self.index, filterType)
    self.dataList = BaseUtils.BubbleSort(self.dataList, function(a, b)
        if a.focus == b.focus then
            if a.rare == b.rare then
                return a.pos > b.pos
            else
                return a.rare > b.rare
            end
        else
            return a.focus > b.focus
        end
    end)
end

function LotteryShowPanel:UpdateFocus(idx)
    if self.itemTab ~= nil then
        for k, v in pairs(self.itemTab) do
            if v.data.idx == idx then
                v:SetFocusState()
            end
        end
        self:SortData(self.curFilterType)
        self:SetData(false)
    end
end

function LotteryShowPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.lottery_show))
    self.gameObject.name = "LotteryShowPanel"

    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.main.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(0, -10, 0)

    local right = self.transform:Find("Right")
    self.time = right:Find("Time"):GetComponent("Text")
    self.txtDesc = right:Find("TxtDesc"):GetComponent("Text")
    self.nothing = right:Find("Nothing").gameObject
    right:Find("Nothing/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidegirl2, "GuideGirl2")
    self.msgItem = MsgItemExt.New(right:Find("Nothing/Talk/Text"):GetComponent(Text), 185, 16, 20)
    self.msgItem:SetData(TI18N("选择心仪的宝贝，试试手气，赢取开门红！{face_1,29}"))

    self.scrollObj = right:Find("Scroll").gameObject
    right:Find("Scroll"):GetComponent("Button").onClick:AddListener(function()
        self.parent:OnSwitchTab(2, 3)
    end)
    self.vScroll = right:Find("Scroll"):GetComponent(ScrollRect)
    self.rightContainer = right:Find("Scroll/Container").gameObject
    self.rightContainerRect = self.rightContainer:GetComponent(RectTransform)
    self.item_list = {}
    for i=1,11 do
        local go = right:Find(string.format("Scroll/Container/%s",i)).gameObject
        local item = LotteryHistoryItem.New(go, self)
        table.insert(self.item_list, item)
    end
    self.single_item_height = self.item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = self.scrollObj.transform:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.rightContainer.transform :GetComponent(RectTransform).anchoredPosition.y
    self.setting_data = {
       item_list = self.item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.rightContainer.transform  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.vScroll.onValueChanged:AddListener(function()
        -- BaseUtils.on_value_change(self.setting_data)
    end)

    local left = self.transform:Find("Left")
    self.nothingLeft = left:Find("Nothing")
    self.leftContainer = left:Find("Scroll/Container").gameObject
    self.baseItem =  self.leftContainer.transform:GetChild(0).gameObject
    self.baseItem = GameObject.Instantiate(self.baseItem).gameObject
    self.baseItem.transform:SetParent(self.leftContainer.transform)
    self.baseItem:SetActive(false)
    self.leftContainerRect = self.leftContainer:GetComponent(RectTransform)

    for i = 1, 1 do
        table.insert(self.objList, self.leftContainer.transform:GetChild(i - 1).gameObject)
    end

    --累计参与人次
    local NumberCon = right:Find("MemeberCon"):Find("NumberCon")
    self.NumTxtCon1 = NumberCon:Find("Img0"):Find("TxtCon").gameObject
    self.NumTxtCon2 = NumberCon:Find("Img1"):Find("TxtCon").gameObject
    self.NumTxtCon3 = NumberCon:Find("Img2"):Find("TxtCon").gameObject
    self.NumTxtCon4 = NumberCon:Find("Img3"):Find("TxtCon").gameObject
    self.NumTxtCon5 = NumberCon:Find("Img4"):Find("TxtCon").gameObject
    self.NumTxtCon6 = NumberCon:Find("Img5"):Find("TxtCon").gameObject
    self.NumTxtCon7 = NumberCon:Find("Img6"):Find("TxtCon").gameObject
    self.NumTxtCon8 = NumberCon:Find("Img7"):Find("TxtCon").gameObject

    self.toggleGroup= left:FindChild("ToggleGroup").gameObject
    self.Toggle0 = self.toggleGroup.transform:FindChild("Toggle1"):GetComponent(Toggle)
    self.Toggle1 = self.toggleGroup.transform:FindChild("Toggle2"):GetComponent(Toggle)
    self.Toggle2 = self.toggleGroup.transform:FindChild("Toggle3"):GetComponent(Toggle)
    self.Toggle3 = self.toggleGroup.transform:FindChild("Toggle4"):GetComponent(Toggle)
    self.Toggle4 = self.toggleGroup.transform:FindChild("Toggle5"):GetComponent(Toggle)
    self.toTxt1 = self.Toggle0.transform:FindChild("Text"):GetComponent(Text)
    self.toTxt2 = self.Toggle1.transform:FindChild("Text"):GetComponent(Text)
    self.toTxt3 = self.Toggle2.transform:FindChild("Text"):GetComponent(Text)
    self.toTxt4 = self.Toggle3.transform:FindChild("Text"):GetComponent(Text)
    self.toTxt5 = self.Toggle4.transform:FindChild("Text"):GetComponent(Text)
    self.Toggle0.isOn = true

    self.Toggle0.onValueChanged:AddListener(function() self:OnToggle(0) end)
    self.Toggle1.onValueChanged:AddListener(function() self:OnToggle(1) end)
    self.Toggle2.onValueChanged:AddListener(function() self:OnToggle(2) end)
    self.Toggle3.onValueChanged:AddListener(function() self:OnToggle(3) end)
    self.Toggle4.onValueChanged:AddListener(function() self:OnToggle(4) end)

    self.toTxt1.text = TI18N("全部")
    self.toTxt2.text = self.filterTypes[1]
    self.toTxt3.text = self.filterTypes[2]
    self.toTxt4.text = self.filterTypes[3]
    self.toTxt5.text = self.filterTypes[4]

    EventMgr.Instance:AddListener(event_name.lottery_main_update, self.listener)
    EventMgr.Instance:AddListener(event_name.lottery_focus_update, self.updateFocus)
    self.hasInit = true
    self:OnShow()
end

function LotteryShowPanel:OnToggle(toggleIndex)
    self.curFilterType = toggleIndex
    self:SortData(self.curFilterType)
    self:SetData(false)
end

function LotteryShowPanel:SetData(tweenProg)
    self.rightContainerRect.anchoredPosition = Vector2.zero
    local count = 0
    local dataLen = 0
    for i,data in ipairs(self.dataList) do
        count = i
        local item = self.itemTab[i]
        if item == nil then
            local obj = self:GetItem(i)
            item = LotteryShowItem.New(obj, self)
            table.insert(self.itemTab, item)
        end
        item:SetData(data, tweenProg)
        item.gameObject:SetActive(true)
        dataLen = dataLen + 1
    end

    if dataLen == 0 then
        if self.curFilterType == 0 then
            self.nothingLeft:Find("Text"):GetComponent(Text).text = TI18N("当前不在活动时间内，请留意公告")
        else
            self.nothingLeft:Find("Text"):GetComponent(Text).text = string.format(TI18N("暂时没有%s商品，请查看其它类别"), self.filterTypes[self.curFilterType])
        end
        self.nothingLeft.gameObject:SetActive(true)
    else
        self.nothingLeft.gameObject:SetActive(false)
    end

    for i=1, #self.objList do
        self.objList[i].name = tostring(i)
    end

    local h = math.ceil(count / 3) * 230
    self.leftContainerRect.sizeDelta = Vector2(500, h)

    count = count + 1
    for i = count, #self.objList do
        self.objList[i]:SetActive(false)
    end

    self:start_timer()

    if self.curJoinMemNum <= LotteryManager.Instance.totalJoinMemNum*13 and LotteryManager.Instance.totalJoinMemNum*13 > 0 then
        self.curJoinMemNum = LotteryManager.Instance.totalJoinMemNum*13 --Random.Range(100000, 999999)
        local one = math.floor(self.curJoinMemNum/10000000)
        local two = math.floor((self.curJoinMemNum - one*10000000)/1000000)
        local three = math.floor((self.curJoinMemNum - one*10000000 - two*1000000)/100000)
        local four = math.floor((self.curJoinMemNum - one*10000000 - two*1000000 - three*100000)/10000)
        local five = math.floor((self.curJoinMemNum - one*10000000 - two*1000000 - three*100000 - four*10000)/1000)
        local six = math.floor((self.curJoinMemNum - one*10000000 - two*1000000 - three*100000 - four*10000 - five*1000)/100)
        local seven = math.floor((self.curJoinMemNum - one*10000000 - two*1000000 - three*100000 - four*10000 - five*1000 - six*100)/10)
        local eight  = self.curJoinMemNum - one*10000000 - two*1000000 - three*100000 - four*10000 - five*1000 - six*100 - seven*10
        --播下累计参与人次
        self:TweenJoinMemberNum(self.NumTxtCon1, one)
        self:TweenJoinMemberNum(self.NumTxtCon2, two)
        self:TweenJoinMemberNum(self.NumTxtCon3, three)
        self:TweenJoinMemberNum(self.NumTxtCon4, four)
        self:TweenJoinMemberNum(self.NumTxtCon5, five)
        self:TweenJoinMemberNum(self.NumTxtCon6, six)
        self:TweenJoinMemberNum(self.NumTxtCon7, seven)
        self:TweenJoinMemberNum(self.NumTxtCon8, eight)
    end
end

function LotteryShowPanel:GetItem(i)
	local obj = self.objList[i]
	if obj == nil then
		obj = GameObject.Instantiate(self.baseItem).gameObject
		obj.name = "Item"
		obj.transform:SetParent(self.leftContainer.transform)
		obj.transform.localScale = Vector3.one
        obj:GetComponent(RectTransform).localPosition = Vector3(0, 0, 0)
		obj:GetComponent(RectTransform).anchoredPosition = Vector2(169 * ((i-1) % 3), -230 * ((math.ceil(i / 3)-1)))
		obj:SetActive(true)
		table.insert(self.objList, obj)
	end
    return obj
end

function LotteryShowPanel:UpdateTime()
    local statr_str = os.date("%Y.%m.%d", LotteryManager.Instance.startTime)
    local end_str = os.date("%Y.%m.%d", LotteryManager.Instance.endTime)
    self.time.text = string.format(TI18N("活动时间:\n<color='#00ff00'>%s 9:30~23:30 %s</color>"), TI18N("每周六、日"), TI18N("开启"))

    local str = ""
    local str2 = ""
    local tempData = LotteryManager.Instance.timeList[1]
    if tempData ~= nil then
        local hour = tempData.hour_start >= 10 and tempData.hour_start or string.format("0%s", tempData.hour_start)
        local min = tempData.min_start >= 10 and tempData.min_start or string.format("0%s", tempData.min_start)
        str = string.format("%s:%s", hour, min)
        hour = tempData.hour_end >= 10 and tempData.hour_end or string.format("0%s", tempData.hour_end)
        min = tempData.min_end >= 10 and tempData.min_end or string.format("0%s", tempData.min_end)
        str = string.format("%s-%s:%s", str, hour, min)
    end
    tempData = LotteryManager.Instance.timeList[2]
    if tempData ~= nil then
        local hour = tempData.hour_start >= 10 and tempData.hour_start or string.format("0%s", tempData.hour_start)
        local min = tempData.min_start >= 10 and tempData.min_start or string.format("0%s", tempData.min_start)
        str2 = string.format("%s:%s", hour, min)
        hour = tempData.hour_end >= 10 and tempData.hour_end or string.format("0%s", tempData.hour_end)
        min = tempData.min_end >= 10 and tempData.min_end or string.format("0%s", tempData.min_end)
        str2 = string.format("%s-%s:%s", str2, hour, min)
    end
    self.txtDesc.text = string.format("%s %s", str, str2)
end

function LotteryShowPanel:UpdateHistory()
    local list = LotteryManager.Instance.historyTab
    if #list == 0 then
        self.nothing:SetActive(true)
        self.scrollObj:SetActive(false)
    else
        self.nothing:SetActive(false)
        self.scrollObj:SetActive(true)

        self.setting_data.data_list = list

        if #self.setting_data.data_list > 8 then
            if self.tweenHistory == false then
                self.tweenHistory = true
                BaseUtils.refresh_circular_list(self.setting_data)
                --开始装逼的滚
                if #self.setting_data.data_list < #self.item_list then
                    self.tweenHistoryItemIndex = #self.setting_data.data_list
                else
                    self.tweenHistoryItemIndex = #self.item_list
                end
                self:DoTweenHistory()
            end
        else
            BaseUtils.refresh_circular_list(self.setting_data)
        end
    end
end

-----历史记录列表滚的效果
function LotteryShowPanel:DoTweenHistory()
    local delayTime = Random.Range(3, 6)
    -- local delayTime = Random.Range(2, 5)
    LuaTimer.Add(delayTime*1000, function() self:TweenHistoryList() end)
end

function LotteryShowPanel:TweenHistoryList()
    if self.hasInit == false then
        return
    end
    if self.tweenHistoryItemIndex <= 0 then
        self.tweenHistoryItemIndex = #self.item_list
    end
    local lastItem = self.item_list[self.tweenHistoryItemIndex]
    if self.tweeenHistoryDataIndex > #self.setting_data.data_list then
        self.tweeenHistoryDataIndex = 1
    end
    local data = self.setting_data.data_list[self.tweeenHistoryDataIndex]
    local itemHeight = lastItem.transform:GetComponent(RectTransform).sizeDelta.y
    lastItem:update_my_self(data, self.tweeenHistoryDataIndex)
    lastItem.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0, itemHeight)
    local tweenSpeed = 1
    for i=1,#self.item_list do
        local item = self.item_list[i]
        local newY = item.transform:GetComponent(RectTransform).anchoredPosition.y - itemHeight
        Tween.Instance:MoveLocalY(item.gameObject, newY, tweenSpeed, nil, LeanTweenType.linear)
    end
    self.tweeenHistoryDataIndex = self.tweeenHistoryDataIndex + 1
    self.tweenHistoryItemIndex = self.tweenHistoryItemIndex - 1
    self:DoTweenHistory()
end

-----累计参与人次播效果
function LotteryShowPanel:TweenJoinMemberNum(con, num)
    local tweenSpeed = 2-num*0.1
    local newY = self.txtYs[num]
    Tween.Instance:MoveLocalY(con, newY, tweenSpeed, nil, LeanTweenType.linear)
end

-----计时器逻辑
function LotteryShowPanel:start_timer()
    self:stop_timer()
    self.time_count = 0
    self.timerId = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
end

function LotteryShowPanel:stop_timer()
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
        self.timerId = 0
    end
end

function LotteryShowPanel:timer_tick()
    if BaseUtils.BASE_TIME > LotteryManager.Instance.startTime and BaseUtils.BASE_TIME < LotteryManager.Instance.endTime then
        self.time_count = self.time_count + 1
        if self.time_count > 0 and self.time_count%self.freshTime == 0 then
            LotteryManager.Instance:RefreshData(self.index)
        end
    else
        self.time.text = TI18N("活动未开启")
        self:stop_timer()
        return
    end

    local leftTime = LotteryManager.Instance.endTime - BaseUtils.BASE_TIME
    local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(leftTime)
    my_hour = my_date*24 + my_hour
    my_hour = my_hour >= 10 and my_hour or string.format("0%s", my_hour)
    my_minute = my_minute >= 10 and my_minute or string.format("0%s", my_minute)
    my_second = my_second >= 10 and my_second or string.format("0%s", my_second)
    -- 距离结束还剩：X天X小时X分X秒    48:00:00
    self.time.text = string.format("%s <color='#13fc60'>%s:%s:%s</color>", TI18N("活动剩余"), my_hour, my_minute, my_second)
end