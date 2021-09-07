-- 冠军联赛排行面板
GuildLeagueRankPanel = GuildLeagueRankPanel or BaseClass(BasePanel)

function GuildLeagueRankPanel:__init(parent, Main)
    self.model = model
    self.Mgr = GuildLeagueManager.Instance
    self.parent = parent
    self.Main = Main
    self.name = "GuildLeagueRankPanel"
    self.Titletimer = nil
    self.resList = {
        {file = AssetConfig.guildleague_rank_panel, type = AssetType.Main},
        {file = AssetConfig.guildleague_texture, type = AssetType.Dep},
        {file = AssetConfig.guildleague_levicon, type = AssetType.Dep},
        {file = AssetConfig.blue_light, type = AssetType.Dep},
        -- {file = AssetConfig.guildleaguebig, type = AssetType.Dep},

    }
    self.data = {}
    self.index1 = 1
    self.index2 = 1
    self.rank_item_list = {}
    self.setting_data = {}
    self.icon = nil
    self.gradeDesc = {
        [1] = TI18N("预选赛甲级小组前2名可晋级"),
        [2] = TI18N("晋级<color='#ff00ff'>冠军联赛</color>：小组<color='#ffff00'>前2名</color>\n保级<color='#ffff00'>甲级联赛</color>：小组<color='#ffff00'>后2名</color>"),
        [3] = TI18N("晋级<color='#ffff00'>甲级联赛</color>：小组<color='#ffff00'>前2名</color>\n保级<color='#01c0ff'>乙级联赛</color>：小组<color='#ffff00'>后2名</color>"),
        [4] = TI18N("晋级<color='#01c0ff'>乙级联赛</color>：小组<color='#ffff00'>第1名</color>\n保级<color='#13fc60'>丙级联赛</color>：小组<color='#ffff00'>后3名</color>")
    }
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.sortfunc = function(a, b)
        -- if a.season_score > b.season_score then
        --     return true
        -- elseif a.season_score == b.season_score and a.total_win > b.total_win  then
        --     return true
        -- elseif a.season_score == b.season_score and a.total_win == b.total_win and a.ld_id < b.ld_id then
        --     return true
        -- else
        --     return false
        -- end
        return a.rank < b.rank
    end
    self.Updatefunc = function() self:Update() end
end

function GuildLeagueRankPanel:OnOpen()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end

    self.index1 = 2
    if self.Mgr.guild_LeagueInfo ~= nil and self.Mgr.guild_LeagueInfo.grade ~= nil then
        self:OnSwitch1(self.Mgr.guild_LeagueInfo.grade)
    else
        self:OnSwitch1(self.index1)
    end

    self.Mgr.LeagueRankUpdate:AddListener(self.Updatefunc)
end

function GuildLeagueRankPanel:OnHide()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end

    self.Mgr.LeagueRankUpdate:RemoveListener(self.Updatefunc)
end

function GuildLeagueRankPanel:__delete()

    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GuildLeagueRankPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleague_rank_panel))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)

    self.transform:Find("Light"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.blue_light, "blue_light")

    self.icon = self.transform:Find("icon"):GetComponent(Image)
    self.bg = self.transform:Find("bg")
    self.TxtImage = self.transform:Find("TxtImage")
    self.TopDescText = self.transform:Find("TopDescText"):GetComponent(Text)
    self.TopDescText.text = TI18N("<color='#ffff00'>预选赛</color>后按小组排名晋级")
    self.DescText = self.transform:Find("DescText"):GetComponent(Text)
    self.SwitchButton2 = self.transform:Find("SwitchButton2")
    self.SwitchButton1 = self.transform:Find("SwitchButton1")

    self.Rank = self.transform:Find("Rank")
    self.Headbar = self.transform:Find("Rank/Headbar")
    self.MaskScroll = self.transform:Find("Rank/MaskScroll")
    self.ListCon = self.transform:Find("Rank/MaskScroll/ListCon")
    self.NoIMG = self.transform:Find("Rank/NoIMG").gameObject

    for i=1, self.ListCon.childCount do
        local go = self.ListCon.transform:GetChild(i - 1).gameObject
        local item = GuildLeagueRankItem.New(go, self)
        table.insert(self.rank_item_list, item)
    end
    self.single_item_height = self.ListCon.transform:GetChild(0):GetComponent(RectTransform).sizeDelta.y
    self.height_height = self.MaskScroll:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.ListCon:GetComponent(RectTransform).anchoredPosition.y

    self.setting_data = {
       item_list = self.rank_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.ListCon  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.height_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.MaskScroll:GetComponent(ScrollRect).onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)

    self:InitDropDownList()
    self.index1 = 2
    if self.Mgr.guild_LeagueInfo ~= nil and self.Mgr.guild_LeagueInfo.grade ~= nil then
        self:OnSwitch1(self.Mgr.guild_LeagueInfo.grade)
    else
        self:OnSwitch1(self.index1)
    end
    self:OnOpen()
end

function GuildLeagueRankPanel:OnSwitch1(index)
    -- if self.index1 == index then
    --     return
    -- end
    if index < 1 then
        index = 2
    end
    self.index1 = index

    self.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_levicon, string.format("lev%s", index))
    self.DescText.text = self.gradeDesc[index]
    self.Mgr:Require17620(self.index1, 1)
end

function GuildLeagueRankPanel:OnSwitch2(index)
    if self.index2 == index then
        return
    end
    self.index2 = index
    -- self.Mgr:Require17606(self.index1, self.index2)
end

function GuildLeagueRankPanel:InitDropDownList()
    self.index1 = self.Mgr.guild_LeagueInfo.grade
    self.index2 = self.Mgr.guild_LeagueInfo.season_id
    self.SwitchButton2 = self.transform:Find("SwitchButton2")
    self.SwitchButton1 = self.transform:Find("SwitchButton1")

    local Con = self.SwitchButton2:Find("List/MaskScroll/ListCon")
    local baseitem = Con:GetChild(0)
    for i=2, self.index2 do
        local btn = GameObject.Instantiate(baseitem.gameObject)
        btn.transform:SetParent(Con)
        btn.transform.localScale = Vector3.one
        btn.transform.anchoredPosition = Vector2(0, -24+(i-1)*40)
    end
    Con.sizeDelta = Vector2(160, self.index2*40)
    -- self.DropDownList2 = DropDownList.New(self.SwitchButton2.gameObject, function(index) self:OnSwitch2(index) end, {notAutoSelect = false, defaultindex = self.index2})
    self.SwitchButton2.gameObject:SetActive(false)

    self.DropDownList1 = DropDownList.New(self.SwitchButton1.gameObject, function(index) self:OnSwitch1(index) end, {notAutoSelect = false, defaultindex = self.index1})

end

function GuildLeagueRankPanel:Update()
    self.setting_data.data_list = self.Mgr.leagueRankData.guild_league_summary
    self.NoIMG:SetActive(self.Mgr.leagueRankData.guild_league_summary == nil or next(self.Mgr.leagueRankData.guild_league_summary) == nil)
    table.sort(self.setting_data.data_list, self.sortfunc)
    BaseUtils.refresh_circular_list(self.setting_data)
end