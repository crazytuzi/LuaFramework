-- ---------------------------------
-- 分享子界面 区别于ShareMainPanel
-- hosr
-- ---------------------------------
ShareMainPanel =  ShareMainPanel or BaseClass(BasePanel)

function ShareMainPanel:__init(parent)
	self.parent = parent
	self.model = ShareManager.Instance.model

	self.resList = {
		{file = AssetConfig.sharemainpanel, type = AssetType.Main},
		{file = AssetConfig.shareres, type = AssetType.Dep},
	}

    self.listener = function() self:SetData() end
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.tips = {
		TI18N("具体规则："),
		TI18N("1.推广码有效期<color='#ffff00'>24小时</color>，最多<color='#00ff00'>2人</color>使用"),
		TI18N("2.被推广玩家每天正常游戏并达到100活跃度以上时，你可以获得{assets_1, 90026, 30}"),
		TI18N("3.被推广玩家每次进行<color='#ffff00'>充值</color>，都会给你返还一定比例的{assets_2,90026}"),
		TI18N("4.每个推广关系最多可带来<color='#00ff00'>3000</color>{assets_2,90026}"),
		TI18N("5.被推广玩家必须在<color='#00ff00'>20级</color>以前填写推广码绑定推广关系"),
        TI18N("6.被推广玩家在不同等级段通过活跃度贡献红钻有次数限制(40级以下1次，41~50级2次，51~60级3次，61~70级3次，71~80级4次，81~90级5次，91级以上6次)"),
    }

    self.nothingTxt = TI18N("<color='#ffff00'>------当前暂无推广关系------</color>\n1、被推广玩家每天正常游戏并达到一定活跃度以上时，你可获得{assets_1, 90026, 30}\n2、被推广玩家每次<color='#ffff00'>充值</color>，都会给你返还一定比例的{assets_2,90026}\n3、每个推广关系最多可带来<color='#00ff00'>3000</color>{assets_2,90026}\n4、邀请码需要在<color='#00ff00'>20级</color>之前填写\n5、邀请码码有效期为<color='#ffff00'>24小时</color>，每个邀请码最多可供<color='#00ff00'>2人</color>使用")
end

function ShareMainPanel:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    EventMgr.Instance:RemoveListener(event_name.share_info_update, self.listener)
    if self.msgItem ~= nil then
    	self.msgItem:DeleteMe()
    	self.msgItem = nil
    end

    if self.rank_item_list ~= nil then
        for i,v in ipairs(self.rank_item_list) do
            v:DeleteMe()
        end
        self.rank_item_list = nil
    end
end

function ShareMainPanel:OnShow()
    self.cacheMode = CacheMode.Destroy
	self:SetData()
    EventMgr.Instance:AddListener(event_name.share_info_update, self.listener)
    ShareManager.Instance:Send17502()
end

function ShareMainPanel:OnHide()
    EventMgr.Instance:RemoveListener(event_name.share_info_update, self.listener)
end

function ShareMainPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sharemainpanel))
    self.gameObject.name = "ShareMainPanel"

    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(0, -5, 0)

    self.Container = self.transform:Find("Left/Scroll/Container")
    self.ScrollCon = self.transform:Find("Left/Scroll")
    self.scroll = self.ScrollCon.gameObject
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

    self.nothing = self.transform:Find("Left/Nothing").gameObject
    self.nothing:SetActive(false)

    local txt = self.nothing:GetComponent(Text)
    local rect = txt.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(0, 1)
    rect.anchorMin = Vector2(0, 1)
    rect.pivot = Vector2(0, 1)
    rect.anchoredPosition = Vector2(10, -50, 0)

    self.msgItem = MsgItemExt.New(txt, 300, 17)
    self.msgItem:SetData(self.nothingTxt)

    self.transform:Find("Right/Text1"):GetComponent(Text).text = TI18N("我的邀请码")
    self.transform:Find("Right/MyId/Val").gameObject:SetActive(false)
    self.myIdTxt = self.transform:Find("Right/MyId/InputField"):GetComponent(InputField)
    self.myIdRefreshBtn = self.transform:Find("Right/MyId/Refresh"):GetComponent(Button)
    self.myIdCopyBtn = self.transform:Find("Right/MyId/Copy"):GetComponent(Button)
    self.myIdRefreshBtn.onClick:AddListener(function() self:ClickIdRefresh() end)
    self.myIdCopyBtn.onClick:AddListener(function() self:ClickIdCopy() end)

    self.transform:Find("Right/MyLink/Val").gameObject:SetActive(false)
    self.myLinkTxt = self.transform:Find("Right/MyLink/InputField"):GetComponent(InputField)
    self.myLinkTxt.text = "http://t.cn/RcOTaYc"
    self.myLinkRefreshBtn = self.transform:Find("Right/MyLink/Refresh"):GetComponent(Button)
    self.myLinkCopyBtn = self.transform:Find("Right/MyLink/Copy"):GetComponent(Button)
    self.myLinkRefreshBtn.onClick:AddListener(function() self:ClickLinkRefresh() end)
    self.myLinkCopyBtn.onClick:AddListener(function() self:ClickLinkCopy() end)

    local container = self.transform:Find("Right/Container")
    local len = container.childCount
    for i = 1, len do
    	local btn = container:GetChild(i - 1)
    	local index = i
    	btn:GetComponent(Button).onClick:AddListener(function() self:ClickBtn(index) end)
    end

    if self.imgLoader == nil then
        local go = self.transform:Find("Left/ShopBtn/Icon").gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, 90026)

    self.transform:Find("Left/ShopBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickShopBtn() end)
    self.transform:Find("Left/RuleBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickRuleBtn() end)
    self.rule = self.transform:Find("Left/RuleBtn").gameObject
    self.transform:Find("Right/Gift"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.share_bind) end)
    self.gift = self.transform:Find("Right/Gift").gameObject
    self.gift:SetActive(false)
    self.giftRed = self.gift.transform:Find("Red").gameObject
    self.giftRed:SetActive(false)

    self.valTxt = self.transform:Find("Left/ValTxt"):GetComponent(Text)

    if ShareManager.Instance.model.hasClipboard and (Application.platform == RuntimePlatform.IPhonePlayer or Application.platform == RuntimePlatform.Android) then
        self.myIdTxt.enabled = false
        self.myLinkTxt.enabled = false
    else
        self.myIdTxt.enabled = true
        self.myLinkTxt.enabled = true
    end

    self:OnShow()
end

function ShareMainPanel:SetData()
    self.data = ShareManager.Instance.shareData
    if self.data ~= nil then
        if self.data.key == nil then
            self.myIdTxt.text = ""else
            self.myIdTxt.text = tostring(self.data.key)
        end
        self.valTxt.text = string.format(TI18N("今日获得红钻:<color='#248813'>%s</color>"), tostring(self.data.day_score))
    end

    local list = {}
    for k,v in pairs(self.data.shipsTab) do
        table.insert(list, v)
    end
    self.setting.data_list = list
    BaseUtils.refresh_circular_list(self.setting)

    if #list == 0 then
    	self.scroll:SetActive(false)
        self.nothing:SetActive(true)
    else
    	self.scroll:SetActive(true)
        self.nothing:SetActive(false)
    end

    if ShareManager.Instance.shareData.apply_key == "" then
    	self.gift:SetActive(false)
    else
    	self.gift:SetActive(true)
    end

    self.giftRed:SetActive(ShareManager.Instance.model.needRed)
end

function ShareMainPanel:ClickBtn(index)
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

function ShareMainPanel:ClickIdRefresh()
    ShareManager.Instance:Send17501()
end

function ShareMainPanel:ClickIdCopy()
    if ShareManager.Instance.model.hasClipboard and (Application.platform == RuntimePlatform.IPhonePlayer or Application.platform == RuntimePlatform.Android) then
        self.myIdTxt.enabled = false
        Utils.CopyTextToClipboard(self.myIdTxt.text)
        NoticeManager.Instance:FloatTipsByString(TI18N("内容已复制到粘贴板"))
    else
        self.myIdTxt.enabled = true
        self.myIdTxt:ActivateInputField()
    end
end

function ShareMainPanel:ClickLinkRefresh()
end

function ShareMainPanel:ClickLinkCopy()
    if ShareManager.Instance.model.hasClipboard and (Application.platform == RuntimePlatform.IPhonePlayer or Application.platform == RuntimePlatform.Android) then
        self.myLinkTxt.enabled = false
        NoticeManager.Instance:FloatTipsByString(TI18N("内容已复制到粘贴板"))
    else
        self.myLinkTxt.enabled = true
        self.myLinkTxt:ActivateInputField()
    end
end

function ShareMainPanel:ClickShopBtn()
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.share_shop)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {1,1})
    -- local datalist = {}
    -- for i,v in pairs(ShopManager.Instance.model.datalist[2][8]) do
    --     table.insert(datalist, v)
    -- end
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {datalist = datalist, title = TI18N("星钻商城"), extString = ""})
end

function ShareMainPanel:ClickRuleBtn()
    TipsManager.Instance:ShowText({gameObject = self.rule, itemData = self.tips})
end