-- -----------------------------------------
-- 一闷夺宝记录界面
-- hosr
-- -----------------------------------------
LotteryRecordPanel = LotteryRecordPanel or BaseClass(BasePanel)

function LotteryRecordPanel:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.lottery_record, type = AssetType.Main},
        {file = AssetConfig.lottery_res, type = AssetType.Dep},
        {file = AssetConfig.button1, type = AssetType.Dep},
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.listener = function()
        -- self:OnShow()
        self:UpdateData()
    end
    self.currIndex = 1
end

function LotteryRecordPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.lottery_main_update, self.listener)
    EventMgr.Instance:RemoveListener(event_name.lottery_over_update, self.listener)
    if self.tabGroup ~= nil then
      self.tabGroup:DeleteMe()
      self.tabGroup = nil
    end
    if self.rank_item_list ~= nil then 
        for i,v in ipairs(self.rank_item_list) do
            v:DeleteMe()
        end
    end
    self.rank_item_list = nil
end

function LotteryRecordPanel:OnShow()
    if self.openArgs ~= nil then
        self.currIndex = self.openArgs
    end
    self.tabGroup:ChangeTab(self.currIndex)
end

function LotteryRecordPanel:OnHide()
end

function LotteryRecordPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.lottery_record))
    self.gameObject.name = "LotteryRecordPanel"

    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.main.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(0, -30, 0)

    self.tabGroupObj = self.transform:Find("TabButtonGroup").gameObject
    local tabsetting = {
        notAutoSelect = true,
        noCheckRepeat = false,
        perWidth = 120,
        perHeight = 42,
        isVertical = false
    }

    self.nothing = self.transform:Find("Nothing").gameObject
    self.nothing:SetActive(false)
    self.transform:Find("Nothing/Button"):GetComponent(Button).onClick:AddListener(function() self:OnClickJump() end)

    self.Container = self.transform:Find("Scroll/Container")
    self.ScrollCon = self.transform:Find("Scroll")
    self.ScrollConObj = self.ScrollCon.gameObject

    self.rank_item_list = {}
    for i = 1, 11 do
        local go = self.Container:Find(tostring(i)).gameObject
        local item = LotteryRecordItem.New(go, self)
        go:SetActive(false)
        table.insert(self.rank_item_list, item)
    end
    self.single_item_height = self.rank_item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.Container:GetComponent(RectTransform).anchoredPosition.y
    self.scroll_con_height = self.ScrollCon:GetComponent(RectTransform).sizeDelta.y

    self.setting = {
       item_list = self.rank_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.Container  --item列表的父容器
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

    self.vScroll = self.ScrollCon:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting) end)

    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:TabChange(index) end, tabsetting)

    EventMgr.Instance:AddListener(event_name.lottery_main_update, self.listener)
    EventMgr.Instance:AddListener(event_name.lottery_over_update, self.listener)

    self.firstOpenTabThree = true
    self.firstOpenTabSecond = true

    if self.openArgs ~= nil then
        self.currIndex = self.openArgs
    end
    self.tabGroup:ChangeTab(self.currIndex)
end

function LotteryRecordPanel:TabChange(index)
    self.currIndex = index
    if index == 1 then
        self:UpdateData()
    elseif index == 2 then
        if self.firstOpenTabSecond then
            LotteryManager.Instance:Send16901(1)
            self.firstOpenTabSecond = false
        else
            self:UpdateData()
        end
    elseif index == 3 then
        if self.firstOpenTabThree then
            LotteryManager.Instance:Send16907(1)
            self.firstOpenTabThree = false
        else
            self:UpdateData()
        end
    end
end

function LotteryRecordPanel:UpdateData()
    if self.currIndex == 1 then
        self.setting.data_list = LotteryManager.Instance:GetMyJoin()
        -- BaseUtils.dump(self.setting.data_list, "进行中的列表")
    elseif self.currIndex == 2 then
        self.setting.data_list = LotteryManager.Instance:GetMyGet()
        -- BaseUtils.dump(self.setting.data_list, "揭晓的列表")
    elseif self.currIndex == 3 then
        self.setting.data_list = LotteryManager.Instance.recordHistoryTab
        -- BaseUtils.dump(self.setting.data_list, "历史列表")
        table.sort( self.setting.data_list, function(a,b)
            return a.time > b.time
        end)
    end
    BaseUtils.refresh_circular_list(self.setting)


    if #self.setting.data_list > 0 then
        self.nothing:SetActive(false)
        self.ScrollConObj:SetActive(true)
    else
        self.nothing:SetActive(true)
        self.ScrollConObj:SetActive(false)
    end
end

function LotteryRecordPanel:OnClickJump()
    self.parent.tabGroup:ChangeTab(1)
end
