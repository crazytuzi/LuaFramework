-- 跨服擂台窗口
-- ljh 20190329

CrossArenaLogWindow = CrossArenaLogWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function CrossArenaLogWindow:__init(model)
    self.model = model

    self.windowId = WindowConfig.WinID.CrossArenaLogWindow
    self.winLinkType = WinLinkType.Single
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.crossarenalogwindow, type = AssetType.Main},
        {file = AssetConfig.crossarena_bg, type = AssetType.Main},
        {file = AssetConfig.crossarena_textures, type = AssetType.Dep},
        {file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    
    self.currIndex = 1
    
    ------------------------------------------------
    
    self.levToggleList = {TI18N("全部等级"), TI18N("1-69级"), TI18N("70-79级"), TI18N("80-89级"), TI18N("90-99级"), TI18N("100级以上")}
    self.levToggleDataList = {[2] = {min = 1, max = 69}, [3] = {min = 70, max = 79}, [4] = {min = 80, max = 89}, [5] = {min = 90, max = 99}, [6] = {min = 100, max = 1000}}
    self.curToggleLevIndex = 1 --即self.levToggleList第一项

    ------------------------------------------------
    self._Update = function() self:Update() end
    self._UpdatePanel1 = function() self:UpdatePanel1() end
    self._UpdatePanel2 = function() self:UpdatePanel2() end
    self._UpdateFight = function() self:UpdateFight() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function CrossArenaLogWindow:__delete()
    self:OnHide()


    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function CrossArenaLogWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.crossarenalogwindow))
    self.gameObject.name = "CrossArenaLogWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    local bgtitle = GameObject.Instantiate(self:GetPrefab(AssetConfig.crossarena_bg))
    UIUtils.AddBigbg(self.mainTransform:FindChild("Bg"), bgtitle)

    if BaseUtils.IsWideScreen() then
        local scaleX = (ctx.ScreenWidth / ctx.ScreenHeight) / (16 / 9)
        bgtitle.transform.localScale = Vector3(scaleX, 1, 1)
        self.mainTransform:FindChild("Title").localScale = Vector3(scaleX, 1, 1)
    end

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    ----------------------------

    self.panel = self.mainTransform:FindChild("Panel").gameObject
    
    self.toggleList = self.panel.transform:Find("TitleCon/ToggleList")
    self.background = self.panel.transform:Find("TitleCon/ToggleList/Background").gameObject
    self.label = self.panel.transform:Find("TitleCon/ToggleList/Label"):GetComponent(Text)
    self.label.text = self.levToggleList[self.curToggleLevIndex]
    self.toggleList:GetComponent(Button).onClick:AddListener(function()
        local open = self.background.activeSelf
        self.background:SetActive(open == false)
        self.classList:SetActive(open == false)
    end)
    self.classList = self.mainTransform:FindChild("ClassList").gameObject
    self.classListBtn = self.mainTransform:Find("ClassList/Button"):GetComponent(Button)
    self.classListBtn.onClick:AddListener(function()
        self.background:SetActive(false)
        self.classList:SetActive(false)
    end)
    self.classListCon = self.mainTransform:FindChild("ClassList/Mask/Scroll")
    self.classListItem = self.mainTransform:FindChild("ClassList/Mask/Scroll"):GetChild(0).gameObject
    self.classListItem:SetActive(false)
    local toggle_setting = {
        axis = BoxLayoutAxis.Y
        ,spacing = 0
        ,Left = 4
        ,Top = 0
    }
    self.toggle_layout = LuaBoxLayout.New(self.classListCon, toggle_setting)
    for i=1,#self.levToggleList do
        local item = GameObject.Instantiate(self.classListItem)
        item.transform:Find("I18NText"):GetComponent(Text).text = self.levToggleList[i]
        item.transform:GetComponent(Button).onClick:AddListener(function()
            self.label.text = item.transform:Find("I18NText"):GetComponent(Text).text
            self.curToggleLevIndex = i
            self.background:SetActive(false)
            self.classList:SetActive(false)
            self:OnToggleUpdateList(self.curDataList)
        end)
        self.toggle_layout:AddCell(item)
    end

    self.maskCon = self.panel.transform:Find("MaskCon")
    self.scrollCon = self.maskCon:Find("ScrollCon")
    self.scrollCon:GetComponent(RectTransform).sizeDelta = Vector2(581, 387)
    self.container = self.scrollCon:Find("Container")
    self.itemConLastY = self.container:GetComponent(RectTransform).anchoredPosition.y
    self.vScroll = self.scrollCon:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.settingData)
    end)
    self.itemList = {}
    for i=1,13 do
        local go = self.container:GetChild(i-1).gameObject
        local item = CombatVedioItem.New(go, self)
        table.insert(self.itemList, item)
    end
    self.singleItemHeight = self.itemList[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.scrollConHeight = self.scrollCon:GetComponent(RectTransform).sizeDelta.y
    self.settingData = {
       item_list = self.itemList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container  --item列表的父容器
       ,single_item_height = self.singleItemHeight --一条item的高度
       ,item_con_last_y = self.itemConLastY --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scrollConHeight--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    ----------------------------
    
    self.panel2 = self.mainTransform:FindChild("Panel2").gameObject

    self.maskCon2 = self.panel2.transform:Find("MaskCon")
    self.scrollCon2 = self.maskCon2:Find("ScrollCon")
    self.scrollCon2:GetComponent(RectTransform).sizeDelta = Vector2(581, 387)
    self.container2 = self.scrollCon2:Find("Container")
    self.itemConLastY2= self.container2:GetComponent(RectTransform).anchoredPosition.y
    self.vScroll2 = self.scrollCon2:GetComponent(ScrollRect)
    self.vScroll2.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.settingData2)
    end)
    self.itemList2 = {}
    for i=1,13 do
        local go = self.container2:GetChild(i-1).gameObject
        local item = CrossArenaLogItem.New(go, self)
        table.insert(self.itemList2, item)
    end
    self.singleItemHeight2 = self.itemList2[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.scrollConHeight2 = self.scrollCon2:GetComponent(RectTransform).sizeDelta.y
    self.settingData2 = {
       item_list = self.itemList2--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.container2  --item列表的父容器
       ,single_item_height = self.singleItemHeight2 --一条item的高度
       ,item_con_last_y = self.itemConLastY2 --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scrollConHeight2--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    ----------------------------
    
    self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup").gameObject   
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end)
    
    ----------------------------

    self.OnOpenEvent:Fire()
    self:ClearMainAsset()
end

function CrossArenaLogWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
    self.model:OpenCrossArenaWindow()
end

function CrossArenaLogWindow:OnShow()
    self:Update()
    -- BaseUtils.dump(self.openArgs)

    if self.openArgs ~= nil then
        
    end

    CombatManager.Instance:Send10748()
    CombatManager.Instance:Send10758(115)
    local roleData = RoleManager.Instance.RoleData
    CrossArenaManager.Instance:Send20715(roleData.id, roleData.platform, roleData.zone_id)

    self:RemoveListener()
    self:AddListener()
end

function CrossArenaLogWindow:OnHide()
	self:RemoveListener()
end

function CrossArenaLogWindow:AddListener()
    CombatManager.Instance.OnKeepLogChange:AddListener(self._UpdatePanel1)
    CombatManager.Instance.OnKuafuGoodChange:AddListener(self._UpdatePanel1)
    CrossArenaManager.Instance.OnUpdateRoomList:AddListener(self._UpdatePanel2)

    EventMgr.Instance:AddListener(event_name.end_fight, self._UpdateFight)
    EventMgr.Instance:AddListener(event_name.begin_fight, self._UpdateFight)
end

function CrossArenaLogWindow:RemoveListener()
    CombatManager.Instance.OnKeepLogChange:RemoveListener(self._UpdatePanel1)
    CombatManager.Instance.OnKuafuGoodChange:RemoveListener(self._UpdatePanel1)
    CrossArenaManager.Instance.OnUpdateRoomList:RemoveListener(self._UpdatePanel2)

    EventMgr.Instance:RemoveListener(event_name.end_fight, self._UpdateFight)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self._UpdateFight)
end

function CrossArenaLogWindow:ChangeTab(index)
    self.currIndex = index
    self:Update()
end

function CrossArenaLogWindow:Update()
    if self.currIndex == 2 then
        self.panel:SetActive(false)
        self.panel2:SetActive(true)
        self:UpdatePanel2()
    else
        self.panel:SetActive(true)
        self.panel2:SetActive(false)
        self:UpdatePanel1()
    end
end

function CrossArenaLogWindow:UpdatePanel1()
    -- 取数据
    local list = {}
    if self.currIndex == 1 then
        list = CombatManager.Instance.WatchLogmodel.kuafuGoodList[115]
    elseif self.currIndex == 3 then
        local temp = CombatManager.Instance.WatchLogmodel.keepList
        for _,v in pairs(temp) do
            if v.combat_type == 115 then
                table.insert(list, v)
            end
        end
    end

    self.background:SetActive(open == false)
    self.classList:SetActive(open == false)

    -- 更新面版
    self.curDataList = list
    if list ~= nil then
        if self.curToggleLevIndex ~= 1 then
            --进行等级筛选
            local minLev = self.levToggleDataList[self.curToggleLevIndex].min
            local maxLev = self.levToggleDataList[self.curToggleLevIndex].max
            local tempList = {}
            for i = 1, #list do
                local temp = list[i]
                if temp.avg_lev >= minLev and temp.avg_lev <= maxLev then
                    table.insert(tempList, temp)
                end
            end
            self.settingData.data_list = tempList
        else
            --不做等级筛选
            self.settingData.data_list = list
        end
    else
        self.settingData.data_list = {}
    end
    if #self.settingData.data_list == 0 then
        --没数据
        self.maskCon.gameObject:SetActive(false)
    else
        self.maskCon.gameObject:SetActive(true)
        BaseUtils.refresh_circular_list(self.settingData)
    end
end

function CrossArenaLogWindow:OnToggleUpdateList(list)
    if list ~= nil then
        if self.curToggleLevIndex ~= 1 and self.currentMain ~= 2 then
            --进行等级筛选
            local minLev = self.levToggleDataList[self.curToggleLevIndex].min
            local maxLev = self.levToggleDataList[self.curToggleLevIndex].max
            local tempList = {}
            for i = 1, #list do
                local temp = list[i]
                if temp.avg_lev >= minLev and temp.avg_lev <= maxLev then
                    table.insert(tempList, temp)
                end
            end
            self.settingData.data_list = tempList
        else
            --不做等级筛选
            self.settingData.data_list = list
        end
    else
        self.settingData.data_list = {}
    end
    if #self.settingData.data_list == 0 then
        --没数据
        self.maskCon.gameObject:SetActive(false)
    else
        self.maskCon.gameObject:SetActive(true)
        BaseUtils.refresh_circular_list(self.settingData)
    end
end

function CrossArenaLogWindow:UpdatePanel2()
    -- 取数据
    local list = self.model.myLogData

    -- 更新面版
    if list ~= nil then
        self.settingData2.data_list = list
    else
        self.settingData2.data_list = {}
    end
    if #self.settingData2.data_list == 0 then
        --没数据
        self.maskCon2.gameObject:SetActive(false)
    else
        self.maskCon2.gameObject:SetActive(true)
        BaseUtils.refresh_circular_list(self.settingData2)
    end
end

function CrossArenaLogWindow:UpdateFight()
    if not BaseUtils.is_null(self.gameObject) then
        local roleData = RoleManager.Instance.RoleData
        if roleData.status == RoleEumn.Status.Fight then
            self.gameObject:SetActive(false)
        else
            self.gameObject:SetActive(true)
        end
    end
end