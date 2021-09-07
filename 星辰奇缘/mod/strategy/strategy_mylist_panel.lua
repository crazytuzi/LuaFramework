-- @author 黄耀聪
-- @date 2016年7月6日

StrategyMylistPanel = StrategyMylistPanel or BaseClass(BasePanel)

function StrategyMylistPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "StrategyMylistPanel"
    self.mgr = StrategyManager.Instance

    self.resList = {
        {file = AssetConfig.strategy_list_panel, type = AssetType.Main},
    }

    self.cellObjList = {}
    self.datalist = {}

    self.selectData = {
        {name = TI18N("默认顺序"), order = self.mgr.orderType.Default},
        {name = TI18N("时间排序↓"), order = self.mgr.orderType.Time},
        {name = TI18N("时间排序↑"), order = self.mgr.orderType.TimeUp},
    }

    self.lastPositionY = 0
    self.reloadListener = function(order, type, page)
        if model.currentOrder == order and type == self.type then
            self:ReloadList(page)
        end
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function StrategyMylistPanel:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function StrategyMylistPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    local model = self.model
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.strategy_list_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.rankTypeBtn = t:Find("InfoArea/SelectCombox/Main"):GetComponent(Button)
    self.rankUpObj = t:Find("InfoArea/SelectCombox/Main/Normal").gameObject
    self.rankDownObj = t:Find("InfoArea/SelectCombox/Main/Select").gameObject
    self.rankTypeText = t:Find("InfoArea/SelectCombox/Main/Text"):GetComponent(Text)

    self.selectCombox = SelectCombox.New(t:Find("InfoArea/SelectCombox").gameObject, self.selectData, function(index) self:SelectComboxCallback(index) end)
    self.collectBtn = t:Find("InfoArea/Collection"):GetComponent(Button)
    self.uploadBtn = t:Find("InfoArea/Upload"):GetComponent(Button)
    self.publicBtn = t:Find("InfoArea/Public"):GetComponent(Button)

    self.scroll = t:Find("Bg/ScrollLayer"):GetComponent(ScrollRect)
    self.container = t:Find("Bg/ScrollLayer/Container")
    self.cloner = t:Find("Bg/ScrollLayer/Cloner").gameObject
    self.nothing = t:Find("Bg/ScrollLayer/None").gameObject

    self.nothingBtn = t:Find("Bg/ScrollLayer/None/Button"):GetComponent(Button)

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, border = 5})
    self.cloner:SetActive(false)

    self.uploadBtn.onClick:AddListener(function() self:OnUpload() end)
    self.collectBtn.onClick:AddListener(function()
        self.collectBtn.gameObject:SetActive(false)
        self.publicBtn.gameObject:SetActive(true)
        self.type = 1
        model.type = 1
        for k,v in pairs(self.cellObjList) do
            v.no_label = true
        end

        model.currentOrder = self.mgr.orderType.Default
        model:AskMyList(model.currentOrder, model.type, 1)
        self:ReloadList(1)

        -- self.scroll.onValueChanged:Invoke({0, 1})
        self.container.anchoredPosition = Vector2(0, 0)
        self.scroll.onValueChanged:Invoke({0,1})
    end)

    self.publicBtn.onClick:AddListener(function()
        self.publicBtn.gameObject:SetActive(false)
        self.collectBtn.gameObject:SetActive(true)
        self.type = 0
        model.type = 0
        for k,v in pairs(self.cellObjList) do
            v.no_label = false
        end

        model.currentOrder = self.mgr.orderType.Default
        model:AskMyList(model.currentOrder, model.type, 1)
        self:ReloadList(1)

        -- self.scroll.onValueChanged:Invoke({0, 1})
        self.container.anchoredPosition = Vector2(0, 0)
        self.scroll.onValueChanged:Invoke({0,1})
    end)
    for i=1,10 do
        local obj = GameObject.Instantiate(self.cloner)
        self.cellObjList[i] = StrategyListItem.New(model, obj)
        obj.name = tostring(i)
        self.layout:AddCell(obj)
        obj:SetActive(false)
    end

    self.publicBtn.gameObject:SetActive(false)
    self.container.sizeDelta = Vector2(0, 0)

    self.setting_data = {
       item_list = self.cellObjList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.container:GetComponent(RectTransform).anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll:GetComponent(RectTransform).sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.scroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting_data) end)
    -- self.scroll.onValueChanged:AddListener(function(data) self:OnRequest(data) end)
    self.nothingBtn.onClick:AddListener(function() self.mgr.onChangeTab:Fire(100) end)

    -- self.rankTypeBtn.onClick:AddListener(function() self:OnChangeRankType() end)
    -- self.rankTypeText.text = "时间排序"
end

function StrategyMylistPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function StrategyMylistPanel:OnOpen()
    local model = self.model
    self:RemoveListeners()
    self.mgr.onUpdateMyList:AddListener(self.reloadListener)
    model.type = 0

    model.currentOrder = self.mgr.orderType.Default
    model:AskMyList(model.currentOrder, model.type, 1)
    self:ReloadList(1)

    -- self.scroll.onValueChanged:Invoke({0, 1})
    self.container.anchoredPosition = Vector2(0, 0)
    self.scroll.onValueChanged:Invoke({0,1})
end

function StrategyMylistPanel:OnHide()
    self:RemoveListeners()
end

function StrategyMylistPanel:RemoveListeners()
    self.mgr.onUpdateMyList:RemoveListener(self.reloadListener)
end

function StrategyMylistPanel:ReloadList(page)
    local model = self.model
    local roleData = RoleManager.Instance.RoleData


    -- print(model.currentOrder)
    -- print(model.myOrderList[model.currentOrder])
    -- print(self.type)
    -- print(model.myOrderList[model.currentOrder][self.type])
    if model.myOrderList[model.currentOrder][model.type][page] ~= nil then
        self.datalist = {}
        for _,page in pairs(model.myOrderList[model.currentOrder][model.type]) do
            for _,v in pairs(page.list) do
                table.insert(self.datalist, v)
            end
        end
        if model.type == 0 then
            for k,v in pairs(model.draftTab) do
                table.insert(self.datalist, {name = v.name, time = v.lastEditTime, content = v.content, role_name = roleData.name, role_id = roleData.id, platform = roleData.platform, zone_id = roleData.zone_id, isDraft = true, id = k, order = -1})
            end
        end
        -- BaseUtils.dump(self.datalist)
        -- print(self.mgr.orderCmp[model.currentOrder])
        table.sort(self.datalist, self.mgr.orderCmp)
        self.setting_data.data_list = self.datalist
        BaseUtils.refresh_circular_list(self.setting_data)

        self.scroll.onValueChanged:Invoke({0, 1})
        self.container.anchoredPosition = Vector2(0, self.lastPositionY)
        self.scroll.onValueChanged:Invoke({0,1 - self.lastPositionY / self.container.sizeDelta.y})
    end

    self.nothing:SetActive(#self.datalist == 0)
end

function StrategyMylistPanel:OnRequest(data)
    local model = self.model
    self.lastPosition = self.lastPosition or 1
    if self.lastPosition >= 0.5 and data[2] < 0.5 then
        self.lastPositionY = self.container.anchoredPosition.y
        -- self.mgr:send16600(self.model.currentOrder, self.type, math.ceil((#self.datalist + 1) / model.itemNumPerTime), model.itemNumPerTime)
        model:AskMyList(model.currentOrder, model.type, math.ceil((#self.datalist + 1) / model.itemNumPerTime))
    end
    self.lastPosition = data[2]
end

function StrategyMylistPanel:SelectComboxCallback(index)
    local model = self.model
    model.currentOrder = self.selectData[index].order
    model:AskMyList(model.currentOrder, model.type, 1)
    self:ReloadList(1)
end

function StrategyMylistPanel:OnUpload()
    if RoleManager.Instance.RoleData.lev >= 50 then
        self.mgr.onChangeTab:Fire(100)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("50级后再来分享攻略吧{face_1,18}"))
    end
end

function StrategyMylistPanel:OnChangeRankType()
    local model = self.model
    local index = 2
    if model.currentOrder == self.mgr.orderType.TimeUp then
        index = 1
    end
    model.currentOrder = self.selectData[index].order
    model:AskList(model.currentOrder, model.type, 1)
    self:ReloadList(1)
    self.rankDownObj:SetActive(model.currentOrder == self.mgr.orderType.TimeUp)
    self.rankUpObj:SetActive(model.currentOrder ~= self.mgr.orderType.TimeUp)
end


