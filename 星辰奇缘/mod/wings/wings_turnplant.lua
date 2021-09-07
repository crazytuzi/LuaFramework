WingsTurnplant = WingsTurnplant or BaseClass(BaseWindow)

function WingsTurnplant:__init(model)
    self.model = model
    self.name = "WingsTurnplant"

    self.windowId = WindowConfig.WinID.wings_turnplant
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.wings_turnplant, type = AssetType.Main},
        {file = AssetConfig.turnpalte_bg2, type = AssetType.Main},
        {file = AssetConfig.wing_textures, type = AssetType.Dep},
        {file = AssetConfig.notnamedtreasure_textures, type = AssetType.Dep}
    }

    self.effect = {}

    self.count = 0
    self.distance = 0
    self.itemList = {}

    self.isRotating = false

    self.slowListener = function(data) self:DoSlowDown(data) end
    self.updateListener = function() self:ReloadItems() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function WingsTurnplant:__delete()
    self.OnHideEvent:Fire()
    if self.itemList ~= nil then
        for _,item in pairs(self.itemList) do
            if item.iconLoader ~= nil then
                item.iconLoader:DeleteMe()
                item.iconLoader = nil
            end
        end
    end

    if self.itemLoader ~= nil then
        self.itemLoader:DeleteMe()
        self.itemLoader = nil
    end
    if self.pointerLoader ~= nil then
        self.pointerLoader:DeleteMe()
        self.pointerLoader = nil
    end
    if self.effect ~= nil then
        for _,effect in pairs(self.effect) do
            effect:DeleteMe()
        end
        self.effect = nil
    end

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    self.model = nil
end

function WingsTurnplant:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.wings_turnplant))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    local main = t:Find("Main")
    main:Find("Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    local panel = main:Find("Panel")

    local turnplant = main:Find("Turnplate")
    UIUtils.AddBigbg(turnplant:Find("Turnplate"), GameObject.Instantiate(self:GetPrefab(AssetConfig.turnpalte_bg2)))
    self.turnplant = turnplant:Find("Turnplate")
    self.container = turnplant:Find("Container")
    for i=1,4 do
        local tab = {}
        tab.transform = self.container:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.iconLoader = SingleIconLoader.New(tab.transform:Find("Icon").gameObject)
        tab.numText = tab.transform:Find("Num"):GetComponent(Text)
        self.itemList[i] = tab
    end
    self.titleText = turnplant:Find("Title/Text"):GetComponent(Text)
    self.getImage = turnplant:Find("Get"):GetComponent(Image)

    self.itemLoader = SingleIconLoader.New(panel:Find("KeyNum/Image").gameObject)
    self.pointerLoader = SingleIconLoader.New(turnplant:Find("Pointer/OkButton").gameObject)
    self.itemText = panel:Find("KeyNum/Text"):GetComponent(Text)

    self.goBtn = turnplant:Find("Pointer/OkButton"):GetComponent(Button)
    self.numText = turnplant:Find("Pointer/Text"):GetComponent(Text)
    self.getImage.gameObject:SetActive(false)

    self.goBtn.onClick:AddListener(function() self:BeginRolling() end)

    panel:Find("DescText2"):GetComponent(Text).text = TI18N("抽到重复翅膀可获得<color='#00ff00'>灵羽兑换币</color>，可兑换指定外观")
end

function WingsTurnplant:OnInitCompleted()
    -- self:Relocate(0)
    self:SetTurnplatePosition(45)
    self:SetItemsPosition(0)
    self.OnOpenEvent:Fire()
end

function WingsTurnplant:OnOpen()
    self:RemoveListeners()
    WingsManager.Instance.onLottory:AddListener(self.slowListener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.updateListener)

    self.getImage.gameObject:SetActive(false)
    local rotate = false
    local data = nil
    if self.openArgs ~= nil then
        self.group_id = self.openArgs.group_id
        rotate = (self.openArgs.rotate == true)
        data = WingsManager.Instance.data_on11615
        WingsManager.Instance.data_on11615 = nil
    end
    -- self.group_id = 1
    -- self.index = 3

    self:ReloadInfo(self.group_id)
    self:ReloadItems()
    if rotate then
        self:Go()
    end
    if data then
        self:DoSlowDown(data)
    end
end

function WingsTurnplant:RemoveListeners()
    WingsManager.Instance.onLottory:RemoveListener(self.slowListener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.updateListener)
end

function WingsTurnplant:OnHide()
    self:RemoveListeners()
    if self.isRotating then
        self:EndRolling()
        self.isRotating = false
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function WingsTurnplant:ReloadInfo(group_id)
    local group = DataWing.data_group_info[group_id]
    for i,v in ipairs(group.wing_ids) do
    -- for i,v in ipairs(datalist) do
        self.itemList[i].iconLoader:SetSprite(SingleIconType.Item, DataItem.data_get[DataWing.data_base[v[1]].item_id].icon)
    end

    self.titleText.text = string.format(TI18N("%s阶天使赐福"), BaseUtils.NumToChn(group_id))
end

function WingsTurnplant:EndRolling()
    self.tweenId = nil
    self.isRotating = false

    if self.targetData ~= nil then
        if self.targetData.result == 1 then
            self:SetGet(self.targetData.index)
            local index = self.targetData.index
            local group_id = self.group_id
            local wing_id = DataWing.data_group_info[group_id].wing_ids[index][1]
            if #self.targetData.items == 0 then
                LuaTimer.Add(500, function()
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.model_show_window, {wing_id})
                    -- WingsManager.Instance:Send11600()
                end)
            else
                NoticeManager.Instance:FloatTipsByString(self.targetData.msg)
                self:TransformItem({base_id = DataWing.data_base[wing_id].item_id}, self.targetData.items[1])
            end
        else
            -- NoticeManager.Instance:FloatTipsByString(self.targetData.msg)
        end
        self.targetData = nil
    end
end

function WingsTurnplant:BeginRolling()
    if self.isRotating then
        NoticeManager.Instance:FloatTipsByString(TI18N("正在抽取"))
        return
    end

    local groupData = DataWing.data_group_info[self.group_id]
    local base_id = groupData.loss_item[1][1]
    local num = BackpackManager.Instance:GetItemCount(base_id)
    local bool = true
    for _,v in pairs(groupData.wing_ids) do
        bool = bool and (WingsManager.Instance.hasGetIds[v[1]] == nil)
    end
    if bool then
        NoticeManager.Instance:FloatTipsByString(TI18N("恭喜您，当前星级翅膀已集齐{face_1,3}"))
    elseif num < groupData.loss_item[1][2] then
        NoticeManager.Instance:FloatTipsByString(TI18N("物品不足"))
        TipsManager.Instance:ShowItem({gameObject = self.goBtn.gameObject, itemData = DataItem.data_get[base_id]})
    else
        WingsManager.Instance:Send11615(self.group_id, 0)
        self:Go()
    end
end


function WingsTurnplant:Go()
    self.hasOpen = true

    self.isRotating = true
    self.doSlowDown = false
    self.step = 15

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 10, function() self:DoRotation() end)
    end

    self:ShowEffect(20175, self.transform:Find("Main/Turnplant/Pointer"), Vector3(0.95, 0.95, 1), Vector3(0, 0, -400), true)
    self:ShowEffect(20121, nil, nil, nil, false)
    self:ShowButtonEffect(false)
end

function WingsTurnplant:ShowEffect(id, parent, scale, pos, bool)
    if bool then
        if self.effect[id] == nil then
            self.effect[id] = BaseUtils.ShowEffect(id, parent, scale, pos)
        else
            self.effect[id]:SetActive(true)
        end
    else
        if self.effect[id] ~= nil then
            self.effect[id]:SetActive(false)
        end
    end
end

function WingsTurnplant:ShowButtonEffect(bool)
    if bool then
        if self.buttonEffect == nil then
            self.buttonEffect = BaseUtils.ShowEffect(20121, self.transform:Find("Main/Turnplant/Pointer/OkButton"), Vector3(1.7, 1.7, 1), Vector3(0, 0, -400))
        else
            self.buttonEffect.gameObject:SetActive(true)
        end
    else
        if self.buttonEffect ~= nil then
            self.buttonEffect:SetActive(false)
        end
    end
end

function WingsTurnplant:SetItemsPosition(theta)
    local sin = math.sin
    local cos = math.cos
    local pi = math.pi

    local radius = 140
    for i, v in ipairs(self.itemList) do
        v.transform.anchoredPosition = Vector2(radius * cos(2 * pi *(i - 1) / 4 + theta), radius * sin(2 * pi *(i - 1) / 4 + theta))
    end
end

function WingsTurnplant:DoRotation()
    -- self:SetPointerPos(self.step)
    if self.doSlowDown then
        if self.count < self.targetTheta then
            self.count = self.count + self.step *(self.targetTheta - self.count) * 1.2 / self.distance + 0.2
        end
    else
        self.count =(self.count + self.step) % 360
    end
    self:SetTurnplatePosition(self.count - 45)
    -- 角度制
    self:SetItemsPosition(self.count * math.pi / 180)
    -- 弧度制

    if self.targetTheta ~= nil and self.targetTheta ~= 0 and self.count >= self.targetTheta then
        LuaTimer.Delete(self.timerId)
        self.isRotating = false
        self.timerId = nil

        self:EndRolling()
    end
end

function WingsTurnplant:SetTurnplatePosition(theta)
    self.turnplant.localRotation = Quaternion.Euler(0, 0, theta)
end


function WingsTurnplant:DoSlowDown(data)
    local index = data.index
    WingsManager.Instance.data_on11615 = nil
    -- index = index - 3
    if self.timerId ~= nil then
        self.doSlowDown = true
        if index > 2 then
            self.targetTheta = -90 * index + 360 * 3 - 40 + Random.Range(0, 80) + 180
        else
            self.targetTheta = -90 * index + 360 * 4 - 40 + Random.Range(0, 80) + 180
        end
        self.distance = self.targetTheta - self.count
    end

    self.targetData = data
end

function WingsTurnplant:ReloadItems()
    local groupData = DataWing.data_group_info[self.group_id]
    local base_id = groupData.loss_item[1][1]
    self.pointerLoader:SetSprite(SingleIconType.Item, DataItem.data_get[base_id].icon)
    self.itemLoader:SetSprite(SingleIconType.Item, DataItem.data_get[base_id].icon)

    local num = BackpackManager.Instance:GetItemCount(base_id)
    if num < groupData.loss_item[1][2] then
        self.itemText.text = string.format(TI18N("拥有:<color=#ff0000>%s</color>/%s"), num, groupData.loss_item[1][2])
        self.numText.text = string.format("<color=#ff0000>%s</color>/%s", num, groupData.loss_item[1][2])
    else
        self.itemText.text = string.format(TI18N("拥有:%s/%s"), num, groupData.loss_item[1][2])
        self.numText.text = string.format("%s/%s", num, groupData.loss_item[1][2])
    end
    self:ShowEffect(20121, self.goBtn.transform, Vector3(1.8, 1.8, 1.8), Vector3(-1.3, -2.7, -400), num >= groupData.loss_item[1][2] and not self.isRotating)
end

function WingsTurnplant:SetGet(index)
    self.getImage.transform.anchoredPosition = self.itemList[index].transform.anchoredPosition + Vector2(30, -30)
    -- self.getImage.gameObject:SetActive(true)
end

function WingsTurnplant:TransformItem(item1, item2)
    local myData = {}

    myData.item_list = {{},{}}
    myData.item_list[1].item_id = item1.base_id
    myData.item_list[1].type = 1
    myData.item_list[1].bind = 0
    myData.item_list[1].number = 1

    myData.item_list[2].item_id = item2.base_id
    myData.item_list[2].type = 1
    myData.item_list[2].bind = item2.bind
    myData.item_list[2].number = item2.num

    myData.isChange = true
    myData.desc = string.format(TI18N("获得已有翅膀，自动转换为%s"),DataItem.data_get[myData.item_list[2].item_id].name)
    myData.descExtra = TI18N("<color='#ffff00'>翅膀外观</color>奖励")
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.itemsavegetwindow,myData)
end
