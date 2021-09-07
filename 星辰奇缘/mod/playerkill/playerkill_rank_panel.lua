-- ------------------------------
-- 英雄擂台排行界面
-- hosr
-- ------------------------------
PlayerkillRankPanel = PlayerkillRankPanel or BaseClass(BasePanel)

function PlayerkillRankPanel:__init(parent)
	self.parent = parent
	self.resList = {
		{file = AssetConfig.playerkillrank, type = AssetType.Main}
	}

    self.setting = {
        noCheckRepeat = true,
        notAutoSelect = true,
    }
    self.subindex = 2
    local rankname, rankindex = PlayerkillEumn.GetRankTypeName(RoleManager.Instance.RoleData.lev, RoleManager.Instance.RoleData.lev_break_times)
    self.subindex = rankindex
    self.slotList = {}


    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.onUpdateRank = function() xpcall(function() self:UpdateRank(true) end,
                function() end ) end
    -- self.onUpdateRank = function() self:UpdateRank(true) end
end

function PlayerkillRankPanel:__delete()
    PlayerkillManager.Instance.OnRankUpdate:Remove(self.onUpdateRank)
  	if self.tabGroup ~= nil then
		self.tabGroup:DeleteMe()
		self.tabGroup = nil
  	end

    if self.rank_item_list ~= nil then
        for i,v in ipairs(self.rank_item_list) do
            v:DeleteMe()
        end
        self.rank_item_list = {}
    end

    if self.slotList ~= nil then
        for i,v in ipairs(self.slotList) do
            v:DeleteMe()
        end
        self.slotList = {}
    end
end

function PlayerkillRankPanel:OnShow()
    self.tabGroup:ChangeTab(1)
end

function PlayerkillRankPanel:OnHide()
end

function PlayerkillRankPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.playerkillrank))
    self.gameObject.name = "PlayerkillRankPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.main)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero


    self.selectBtn = self.transform:Find("SelectBtn").gameObject
    self.selectBtn:GetComponent(Button).onClick:AddListener(function() self:ShowBest() end)
    self.selectTxt = self.transform:Find("SelectBtn/Name"):GetComponent(Text)

    self.TipsClose = self.transform:Find("TipsClose"):GetComponent(Button)
    self.TipsSelectButton = self.transform:Find("TipsSelectButton").gameObject
    self.TipsListbg = self.transform:Find("TipsList")
    self.ListCon = self.transform:Find("TipsList/Mask/List")

    self.Nothing = self.transform:Find("Nothing").gameObject

    self.TipsClose.onClick:AddListener(function()
        self.TipsClose.gameObject:SetActive(false)
        self.TipsListbg.gameObject:SetActive(false)
    end)

    for i,v in ipairs(PlayerkillEumn.RankTypeName) do
        local btn = GameObject.Instantiate(self.TipsSelectButton)
        btn.transform:SetParent(self.ListCon)
        btn.transform.localScale = Vector3.one
        btn.transform.anchoredPosition3D = Vector3(0, -30-(i-2)*40, 0)
        btn.transform:Find("Text"):GetComponent(Text).text = v
        btn.gameObject:SetActive(i ~= 1)
        btn.transform:GetComponent(Button).onClick:AddListener(function()
            self.selectTxt.text = v
            self.subindex = i
            self.TipsClose.gameObject:SetActive(false)
            self.TipsListbg.gameObject:SetActive(false)
            self:Update()
        end)
        if self.subindex == i then
            self.selectTxt.text = v
        end
    end
    self.ListCon.sizeDelta = Vector2(100, (#PlayerkillEumn.RankTypeName-1) * 40)

    local left = self.transform:Find("Left")
    left:Find("Title/Text"):GetComponent(Text).text = TI18N("当前成绩")
    left:Find("Text"):GetComponent(Text).text = TI18N("本赛季参与了擂台竞技\n根据成绩可领取:")
    self.time = left:Find("Time"):GetComponent(Text)
    self.containerRect = left:Find("Content"):GetComponent(RectTransform)
    self.contentRect = left:Find("Content/Text"):GetComponent(RectTransform)
    self.contentTxt = left:Find("Content/Text"):GetComponent(Text)
    self.contentVal = left:Find("Content/Val"):GetComponent(Text)
    self.contentValRect = left:Find("Content/Val"):GetComponent(RectTransform)

    local reward = left:Find("Reward")
    self.rewardRect = reward:GetComponent(RectTransform)
    for i = 1, 3 do
        local slot = ItemSlot.New()
        UIUtils.AddUIChild(reward:GetChild(i - 1).gameObject, slot.gameObject)
        table.insert(self.slotList, slot)
    end

    self.button = left:Find("Button").gameObject
    self.button:GetComponent(Button).onClick:AddListener(function() PlayerkillManager.Instance:Send19304() end)

    self.Container = self.transform:Find("Right/Scroll/Container")
    self.ScrollCon = self.transform:Find("Right/Scroll")
    self.rank_item_list = {}
    local len = self.Container.childCount
    for i = 1, len do
        local go = self.Container:GetChild(i - 1).gameObject
        local item = PlayerkillRankItem.New(go, self)
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

    self.myItem = PlayerkillRankItem.New(self.transform:Find("Right/OutRankItem"), self)

    self.tabGroup = TabGroup.New(self.transform:Find("TabButtonGroup").gameObject, function(index) self:ChangeTab(index) end, self.setting)

    self:OnShow()
    PlayerkillManager.Instance.OnRankUpdate:Add(self.onUpdateRank)
end

function PlayerkillRankPanel:ChangeTab(index)
    if index == 1 then
        self.index = 1
    elseif index == 2 then
        self.index = 3
    elseif index == 3 then
        self.index = 2
    end
    -- self.index = index
    -- self.subindex = 1
    self.selectTxt.text = PlayerkillEumn.RankTypeName[self.subindex]
    self:Update()
end

function PlayerkillRankPanel:Update()
    self.myData = BaseUtils.copytab(PlayerkillManager.Instance.myData)

    self.time.text = PlayerkillEumn.GetTime()

    self.baseData = DataRencounter.data_info[self.myData.rank_lev]
    self.contentTxt.text = string.format(TI18N("%s%s"), self.baseData.rencounter, self.baseData.title, tostring(self.myData.rank_lev))
    self.contentVal.text = string.format("x%s", self.myData.star)
    local w1 = self.contentTxt.preferredWidth
    local w2 = self.contentVal.preferredWidth
    local w = w1 + w2 + 20
    self.contentRect.sizeDelta = Vector2(w1, 30)
    self.contentRect.anchoredPosition3D = Vector3(w1/2, 0, 0)
    self.contentValRect.sizeDelta = Vector2(w2, 30)
    self.containerRect.sizeDelta = Vector2(w, 30)
    self.containerRect.anchoredPosition = Vector3(0, 66, 0)

    local group = PlayerkillEumn.GetSelfGroup()
    local reward = DataRencounter.data_reward[string.format("%s_%s", group, self.myData.rank_lev)]
    if reward == nil then
        reward = {}
        reward.season_item = {}
    end
    local count = 0
    for i,slot in ipairs(self.slotList) do
        local item = reward.season_item[i]
        if item ~= nil then
            count = count + 1
            local dat = ItemData.New()
            dat:SetBase(DataItem.data_get[tonumber(item[1])])
            dat.quantity = tonumber(item[2])
            slot:SetAll(dat, {nobutton = true})
            slot.gameObject:SetActive(true)
        else
            slot.gameObject:SetActive(false)
        end
    end

    self.rewardRect.sizeDelta = Vector2(count * 64 + 10, 64)
    self.rewardRect.anchoredPosition = Vector3(0, -78, 0)

    self:UpdateRank()
end

function PlayerkillRankPanel:UpdateRank(isProto)
    if not self.parent.ishow and self.setting == nil or self.setting.item_list == nil or BaseUtils.isnull(self.setting.item_list[1]) then
        return
    end

    if not isProto and PlayerkillManager.Instance.status == PlayerkillEumn.Status.Running then
        self.setting.data_list = {}
        PlayerkillManager.Instance:Send19303(self.index, self.subindex)
    else
        self.setting.data_list = PlayerkillManager.Instance:GetRankData(self.index, self.subindex)
    end
    BaseUtils.refresh_circular_list(self.setting)
    self.Nothing:SetActive(#self.setting.data_list < 1)
    local role = RoleManager.Instance.RoleData
    local myrank = 0
    for k,v in pairs(self.setting.data_list) do
        if v.plat == role.platform and v.zone_id == role.zone_id and v.rid == role.id then
            myrank = k
        end
    end
    self.myData.classes = role.classes
    self.myData.sex = role.sex
    self.myData.name = role.name
    self.myData.plat = role.platform
    self.myData.zone_id = role.zone_id
    self.myItem:update_my_self(self.myData, myrank)
end

function PlayerkillRankPanel:ShowBest()
    self.TipsClose.gameObject:SetActive(true)
    self.TipsListbg.gameObject:SetActive(true)
    -- PlayerkillManager.Instance:Send19304()
    self.TipsListbg:SetAsLastSibling()
end