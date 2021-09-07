-- -------------------------------------
-- 分享推广主界面
-- hosr
-- -------------------------------------
ShareMainWindow = ShareMainWindow or BaseClass(BaseWindow)

function ShareMainWindow:__init(model)
	self.model = model
    self.name = "ShareMainWindow"
    self.windowId = WindowConfig.WinID.share_main

	self.resList = {
		{file = AssetConfig.sharemainwindow, type = AssetType.Main},
		{file = AssetConfig.shareres, type = AssetType.Dep},
	}

    self.listener = function() self:SetData() end
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.tips = {
        TI18N("1.推广码有效期<color='#ffff00'>24小时</color>，最多<color='#00ff00'>2个人</color>使用"),
        TI18N("2.被推广玩家每天正常游戏并达到一定活跃度以上时，你可以获得<color='#00ff00'>30</color>{assets_2,90026}"),
        TI18N("3.被推广玩家每次进行<color='#ffff00'>充值</color>，都会给你返还一定比例的{assets_2,90026}"),
        TI18N("4.每个推广关系最多可带来<color='#00ff00'>3000</color>{assets_2,90026}"),
        TI18N("5.被推广玩家必须在20级以前填写推广码绑定推广关系"),
    }
end

function ShareMainWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.share_info_update, self.listener)
    if self.rank_item_list ~= nil then
        for i,v in ipairs(self.rank_item_list) do
            v:DeleteMe()
        end
        self.rank_item_list = nil
    end
end

function ShareMainWindow:OnShow()
    self.cacheMode = CacheMode.Destroy
	self:SetData()
    EventMgr.Instance:AddListener(event_name.share_info_update, self.listener)
end

function ShareMainWindow:OnHide()
    EventMgr.Instance:RemoveListener(event_name.share_info_update, self.listener)
end

function ShareMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sharemainwindow))
    self.gameObject.name = "ShareMainWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self.model:CloseMain() end)

    self.Container = self.transform:Find("Main/Left/Scroll/Container")
    self.ScrollCon = self.transform:Find("Main/Left/Scroll")
    self.rank_item_list = {}
    local len = self.Container.childCount
    for i = 1, len do
        local go = self.Container:GetChild(i - 1).gameObject
        local item = ShareRankItem.New(go, self)
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

    self.nothing = self.transform:Find("Main/Left/Nothing").gameObject

    self.transform:Find("Main/Right/Text1"):GetComponent(Text).text = TI18N("我的推广ID")
    self.transform:Find("Main/Right/MyId/Val").gameObject:SetActive(false)
    self.myIdTxt = self.transform:Find("Main/Right/MyId/InputField"):GetComponent(InputField)
    self.myIdRefreshBtn = self.transform:Find("Main/Right/MyId/Refresh"):GetComponent(Button)
    self.myIdCopyBtn = self.transform:Find("Main/Right/MyId/Copy"):GetComponent(Button)
    self.myIdRefreshBtn.onClick:AddListener(function() self:ClickIdRefresh() end)
    self.myIdCopyBtn.onClick:AddListener(function() self:ClickIdCopy() end)

    self.transform:Find("Main/Right/MyLink/Val").gameObject:SetActive(false)
    self.myLinkTxt = self.transform:Find("Main/Right/MyLink/InputField"):GetComponent(InputField)
    self.myLinkTxt.text = "http://xcqy.kkk5.com/"
    self.myLinkRefreshBtn = self.transform:Find("Main/Right/MyLink/Refresh"):GetComponent(Button)
    self.myLinkCopyBtn = self.transform:Find("Main/Right/MyLink/Copy"):GetComponent(Button)
    self.myLinkRefreshBtn.onClick:AddListener(function() self:ClickLinkRefresh() end)
    self.myLinkCopyBtn.onClick:AddListener(function() self:ClickLinkCopy() end)

    local container = self.transform:Find("Main/Right/Container")
    local len = container.childCount
    for i = 1, len do
    	local btn = container:GetChild(i - 1)
    	local index = i
    	btn:GetComponent(Button).onClick:AddListener(function() self:ClickBtn(index) end)
    end

    self.transform:Find("Main/Left/ShopBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickShopBtn() end)
    self.transform:Find("Main/Left/RuleBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickRuleBtn() end)
    self.rule = self.transform:Find("Main/Left/RuleBtn").gameObject

    self.valTxt = self.transform:Find("Main/Left/ValTxt"):GetComponent(Text)

    self:OnShow()
end

function ShareMainWindow:SetData()
    self.data = ShareManager.Instance.shareData
    if self.data ~= nil then
        self.myIdTxt.text = self.data.key
        self.valTxt.text = string.format(TI18N("今日获得红钻:<color='#00ff00'>%s</color>"), 0)
    end

    local list = {}
    for k,v in pairs(self.data.shipsTab) do
        table.insert(list, v)
    end
    self.setting.data_list = list
    BaseUtils.refresh_circular_list(self.setting)

    if #list == 0 then
        self.nothing:SetActive(true)
    else
        self.nothing:SetActive(false)
    end
end

function ShareMainWindow:ClickBtn(index)
    if index == 1 then
        self.model:TOWeChat()
    elseif index == 2 then
        self.model:TOWeChatTimeline()
    elseif index == 3 then
        self.model:TOQQ()
    elseif index == 4 then
        self.model:TOWeibo()
    end
end

function ShareMainWindow:ClickIdRefresh()
    ShareManager.Instance:Send17501()
end

function ShareMainWindow:ClickIdCopy()
    self.myIdTxt:ActivateInputField()
end

function ShareMainWindow:ClickLinkRefresh()
end

function ShareMainWindow:ClickLinkCopy()
    self.myLinkTxt:ActivateInputField()
end

function ShareMainWindow:ClickShopBtn()
    self.cacheMode = CacheMode.Visible
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.share_shop)
    local datalist = {}
    for i,v in pairs(ShopManager.Instance.model.datalist[2][8]) do
        table.insert(datalist, v)
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {datalist = datalist, title = TI18N("星钻商城"), extString = ""})
end

function ShareMainWindow:ClickRuleBtn()
    TipsManager.Instance:ShowText({gameObject = self.rule, itemData = self.tips})
end