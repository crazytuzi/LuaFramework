-- @author 黄耀聪
-- @date 2017年5月16日

ClosenessRank = ClosenessRank or BaseClass(BasePanel)

function ClosenessRank:__init(parent)
    self.parent = parent
    self.name = "ClosenessRank"

    self.resList = {
        { file = AssetConfig.inti_macy_rank, type = AssetType.Main }
        ,{ file = AssetConfig.rank_textures, type = AssetType.Dep }
        ,{ file = AssetConfig.playerkilltexture, type = AssetType.Dep }
    }
    self.hasInit = false
    self.itemList = { }
    self.updateFun =
    function()
        self:UpdateRank()
    end
    self.OnOpenEvent:AddListener( function() self:OnOpen() end)
    self.OnHideEvent:AddListener( function() self:OnHide() end)
end

function ClosenessRank:__delete()
    self.OnHideEvent:Fire()
    self.hasInit = false
    if self.itemList ~= nil then
        for _, v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    self:AssetClearAll()
end

function ClosenessRank:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.inti_macy_rank))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t
    self.transform.localPosition = Vector3(0, 0, -401)
    t:Find("Panel"):GetComponent(Button).onClick:AddListener( function() self:Hiden() end)

    local main = t:Find("Main")

    self.scroll = main:Find("Scroll"):GetComponent(ScrollRect)
    self.container = main:Find("Scroll/Container")
    self.nothing = main:Find("Scroll/Nothing")

    for i = 1, 10 do
        self.itemList[i] = ClosenessRankItem.New(self.container:GetChild(i - 1).gameObject, self.rankType)
        self.itemList[i].assetWrapper = self.assetWrapper
    end

    self.setting_data = {
        item_list = self.itemList
        ,
        data_list = { }-- 数据列表
        ,
        item_con = self.container-- item列表的父容器
        ,
        single_item_height = 80
        ,
        item_con_last_y = 0-- 父容器改变时上一次的y坐标
        ,
        scroll_con_height = self.scroll.transform.sizeDelta.y
        ,
        item_con_height = 0-- item列表的父容器高度
        ,
        scroll_change_count = 0-- 父容器滚动累计改变值
        ,
        data_head_index = 0-- 数据头指针
        ,
        data_tail_index = 0-- 数据尾指针
        ,
        item_head_index = 0-- item列表头指针
        ,
        item_tail_index = 0-- item列表尾指针
    }

    self.scroll.onValueChanged:AddListener( function() BaseUtils.on_value_change(self.setting_data) end)
    main:Find("Notice").anchoredPosition = Vector2(-130, 27)
    self.hasInit = true
end

function ClosenessRank:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ClosenessRank:OnOpen()
    self:RemoveListeners()
    self.rankType = WorldLevManager.Instance.CurRankType
    if self.openArgs ~= nil then 
        self.rankType = self.openArgs
    end
    EventMgr.Instance:AddListener(event_name.intimacy_update, self.updateFun)
    EventMgr.Instance:AddListener(event_name.campaign_rank_update, self.updateFun)
    self:UpdateRank()
    local TxtTitle = self.transform:Find("Main/Title/Text"):GetComponent(Text);
    local TxtScore = self.transform:Find("Main/Head/Score"):GetComponent(Text);
    local TxtTips = self.transform:Find("Main/Tips"):GetComponent(Text);
    TxtTitle.text, TxtScore.text, TxtTips.text = self:GetTitleDesc()
end
function ClosenessRank:UpdateRank()
    self.setting_data.data_list = WorldLevManager.Instance:GetLenRankDataByType(self.rankType, 50) or { }

    BaseUtils.refresh_circular_list(self.setting_data)

    if self.nothing ~= nil then
        self.nothing.gameObject:SetActive(#self.setting_data.data_list == 0)
    end
end

function ClosenessRank:OnHide()
    self:RemoveListeners()
end

function ClosenessRank:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.intimacy_update, self.updateFun)
    EventMgr.Instance:RemoveListener(event_name.campaign_rank_update, self.updateFun)
end

function ClosenessRank:GetTitleDesc()
    local str, str2, str3 = nil
    if self.rankType == CampaignEumn.CampaignRankType.Constellation then
        str = TI18N("十二星座")
        str2 = TI18N("积分")
        str3 = TI18N("积分")
    elseif self.rankType == CampaignEumn.CampaignRankType.Intimacy then
        str = TI18N("亲密度排行")
        str2 = TI18N("亲密度")
    elseif self.rankType == CampaignEumn.CampaignRankType.Pet then
        str = TI18N("宠物排行")
        str2 = TI18N("评分")
    elseif self.rankType == CampaignEumn.CampaignRankType.PlayerKill then
        str = TI18N("星辰擂台")
        str2 = TI18N("段位")
    elseif self.rankType == CampaignEumn.CampaignRankType.Weapon then
        str = TI18N("装备评分")
        str2 = TI18N("评分")
    elseif self.rankType == CampaignEumn.CampaignRankType.Weapon2 then
        str = TI18N("装备评分")
        str2 = TI18N("评分")
    elseif self.rankType == CampaignEumn.CampaignRankType.WorldChampion then
        str = TI18N("武道大会")
        str2 = TI18N("段位")
    elseif self.rankType == CampaignEumn.CampaignRankType.Wing then
        str = TI18N("翅膀排行")
        str2 = TI18N("评分")
    elseif self.rankType == CampaignEumn.CampaignRankType.Treasure then
        str = TI18N("寻宝排行")
        str2 = TI18N("评分")
    elseif self.rankType == CampaignEumn.CampaignRankType.ConSume then
        str = TI18N("累消排行")
        str2 = TI18N("累消额")
    else
        str = TI18N("排行榜")
        str2 = TI18N("评分")
    end
    str3 = DataCampaignRank.data_rank_list[self.rankType].rank_tips
    return str, str2, str3
end