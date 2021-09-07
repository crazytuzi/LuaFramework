-- 跨服擂台窗口
-- ljh 20190329

CrossArenaWindow = CrossArenaWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function CrossArenaWindow:__init(model)
    self.model = model

    self.windowId = WindowConfig.WinID.crossarenawindow
    -- self.winLinkType = WinLinkType.Single
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
        {file = AssetConfig.crossarenawindow, type = AssetType.Main},
        {file = AssetConfig.crossarena_bg, type = AssetType.Main},
        {file = AssetConfig.crossarena_textures, type = AssetType.Dep},
        {file = AssetConfig.crossarena2_textures, type = AssetType.Dep},
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------

    ------------------------------------------------

    ------------------------------------------------
    self._Update = function() self:Update() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function CrossArenaWindow:__delete()
    self:OnHide()


    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function CrossArenaWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.crossarenawindow))
    self.gameObject.name = "CrossArenaWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    local bgtitle = GameObject.Instantiate(self:GetPrefab(AssetConfig.crossarena_bg))
    UIUtils.AddBigbg(self.mainTransform:FindChild("Bg"), bgtitle)

    if BaseUtils.IsWideScreen() then
        local scaleX = (ctx.ScreenWidth / ctx.ScreenHeight) / (16 / 9)
        bgtitle.transform.localScale = Vector3(scaleX, 1, 1)
        self.mainTransform:FindChild("Title").localScale = Vector3(scaleX, 1, 1)
    else
        local scaleY = (ctx.ScreenHeight/ ctx.ScreenWidth) / (9 / 16)
        bgtitle.transform.localScale = Vector3(1, scaleY, 1)
    end

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.mainTransform:FindChild("RoomButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickRoomButton() end)
    self.mainTransform:FindChild("MatchButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickMatchButton() end)
    self.mainTransform:FindChild("LogButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickLogButton() end)


    self.noTips = self.mainTransform.transform:Find("List/NoTips")
    self.noTipsText = self.noTips:Find("Text"):GetComponent(Text)

    self.maskCon = self.mainTransform.transform:Find("List/MaskCon")
    self.scrollCon = self.maskCon:Find("ScrollCon")
    -- self.scrollCon:GetComponent(RectTransform).sizeDelta = Vector2(581, 387)
    self.container = self.scrollCon:Find("Container")
    self.itemConLastY = self.container:GetComponent(RectTransform).anchoredPosition.y
    self.vScroll = self.scrollCon:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.settingData)
    end)
    self.itemList = {}
    for i = 0, self.container.childCount -1 do
        local go = self.container:GetChild(i).gameObject
        local item = CrossArenaWindowFriendItem.New(go, self)
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

    self.tabGroupObj = self.mainTransform:FindChild("List/TabButtonGroup").gameObject   
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end)

    ----------------------------

    self.OnOpenEvent:Fire()
    self:ClearMainAsset()
end

function CrossArenaWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function CrossArenaWindow:OnShow()
    self:Update()
    -- BaseUtils.dump(self.openArgs)

    if self.openArgs ~= nil then
        
    end

    CrossArenaManager.Instance:Send20723()
    CrossArenaManager.Instance:Send20724()
    -- StarChallengeManager.Instance.OnUpdateList:AddListener(self._Update)
end

function CrossArenaWindow:OnHide()
	-- StarChallengeManager.Instance.OnUpdateList:RemoveListener(self._Update)
end

function CrossArenaWindow:Update()
    
end

function CrossArenaWindow:UpdateList()
    local function sort(a,b)
        if a.online > b.online then
            return true
        elseif a.online < b.online then
            return false
        else
            return false
        end
    end

    local list = {}
    if self.currIndex == 1 then
        list = FriendManager.Instance:GetSortFriendList()
    elseif self.currIndex == 2 then
        for i, v in pairs(self.model.battleFriendList) do
            table.insert(list, v)
        end
        table.sort(list, sort)
    elseif self.currIndex == 3 then
        for i, v in pairs(self.model.fcFriendList) do
            table.insert(list, v)
        end
        table.sort(list, sort)
    end

    self.settingData.data_list = list
    
    if #list == 0 then
        self.noTips.gameObject:SetActive(true)
        self.maskCon.gameObject:SetActive(false)

        if self.currIndex == 1 then
            self.noTipsText.text = TI18N("暂时没有在线好友")
        elseif self.currIndex == 2 then
            self.noTipsText.text = TI18N("暂无最近交手的玩家")
        elseif self.currIndex == 3 then
            self.noTipsText.text = TI18N("暂无系统推荐对手")
        end
    else
        self.noTips.gameObject:SetActive(false)
        self.maskCon.gameObject:SetActive(true)
    end
        
    BaseUtils.refresh_circular_list(self.settingData)
end

function CrossArenaWindow:ChangeTab(index)
    self.currIndex = index
    self:UpdateList()
end

function CrossArenaWindow:OnClickRoomButton()
    self:OnClickClose()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.crossarenaroomlistwindow)
end

function CrossArenaWindow:OnClickMatchButton()
    NoticeManager.Instance:FloatTipsByString(TI18N("敬请期待{face_1,3}"))
end

function CrossArenaWindow:OnClickLogButton()
    self:OnClickClose()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.crossarenalogwindow)
end
