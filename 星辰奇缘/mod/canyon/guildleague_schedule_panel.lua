-- 冠军联赛赛程面板
GuildLeagueSchedulePanel = GuildLeagueSchedulePanel or BaseClass(BasePanel)

function GuildLeagueSchedulePanel:__init(parent, Main)
    self.model = model
    self.Mgr = GuildLeagueManager.Instance
    self.parent = parent
    self.Main = Main
    self.name = "GuildLeagueSchedulePanel"
    self.Titletimer = nil
    self.resList = {
        {file = AssetConfig.guildleague_schedule_panel, type = AssetType.Main},
        {file = AssetConfig.guildleague_texture, type = AssetType.Dep},
        {file = AssetConfig.blue_light, type = AssetType.Dep},
        -- {file = AssetConfig.guildleaguebig, type = AssetType.Dep},

    }
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildLeagueSchedulePanel:OnOpen()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
end

function GuildLeagueSchedulePanel:OnHide()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function GuildLeagueSchedulePanel:__delete()
    if self.preview ~= nil then
        self.preview:DeleteMe()
    end
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GuildLeagueSchedulePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleague_schedule_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = t

    self.transform:Find("Light"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.blue_light, "blue_light")
    -- self.transform:Find("icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guildleaguebig, "GuildLeaguebig")
    self.guessButton = self.transform:Find("Button"):GetComponent(Button)
    self.TipsText = self.transform:Find("Tips/Text"):GetComponent(Text)
    self.Right = self.transform:Find("Right")
    self.transform:Find("Right/Map/Light"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.blue_light, "blue_light")
    self.FirstText = self.transform:Find("Right/Map/1/Text"):GetComponent(Text)
    self.SecondText = self.transform:Find("Right/Map/2/Text"):GetComponent(Text)
    self.ThirdText = self.transform:Find("Right/Map/3/Text"):GetComponent(Text)
    self.L1Text = self.transform:Find("Right/Map/L1/Text"):GetComponent(Text)
    self.L2Text = self.transform:Find("Right/Map/L2/Text"):GetComponent(Text)
    self.L3Text = self.transform:Find("Right/Map/L3/Text"):GetComponent(Text)
    self.L4Text = self.transform:Find("Right/Map/L4/Text"):GetComponent(Text)
    self.R4Text = self.transform:Find("Right/Map/R4/Text"):GetComponent(Text)
    self.R3Text = self.transform:Find("Right/Map/R3/Text"):GetComponent(Text)
    self.R2Text = self.transform:Find("Right/Map/R2/Text"):GetComponent(Text)
    self.R1Text = self.transform:Find("Right/Map/R1/Text"):GetComponent(Text)

    self.LL = self.transform:Find("Right/Map/LL")
    self.ll1 = self.transform:Find("Right/Map/LL/1")
    self.ll2 = self.transform:Find("Right/Map/LL/2")
    self.ll3 = self.transform:Find("Right/Map/LL/3")
    self.ll4 = self.transform:Find("Right/Map/LL/4")
    self.ll5 = self.transform:Find("Right/Map/LL/5")
    self.ll6 = self.transform:Find("Right/Map/LL/6")
    self.ll7 = self.transform:Find("Right/Map/LL/7")
    self.ll8 = self.transform:Find("Right/Map/LL/8")
    self.ll9 = self.transform:Find("Right/Map/LL/9")
    self.ll10 = self.transform:Find("Right/Map/LL/10")
    self.ll11 = self.transform:Find("Right/Map/LL/11")
    self.ll12 = self.transform:Find("Right/Map/LL/12")
    self.ll13 = self.transform:Find("Right/Map/LL/13")

    self.RL = self.transform:Find("Right/Map/RL")
    self.rl1 = self.transform:Find("Right/Map/RL/1")
    self.rl2 = self.transform:Find("Right/Map/RL/2")
    self.rl3 = self.transform:Find("Right/Map/RL/3")
    self.rl4 = self.transform:Find("Right/Map/RL/4")
    self.rl5 = self.transform:Find("Right/Map/RL/5")
    self.rl6 = self.transform:Find("Right/Map/RL/6")
    self.rl7 = self.transform:Find("Right/Map/RL/7")
    self.rl8 = self.transform:Find("Right/Map/RL/8")
    self.rl9 = self.transform:Find("Right/Map/RL/9")
    self.rl10 = self.transform:Find("Right/Map/RL/10")
    self.rl11 = self.transform:Find("Right/Map/RL/11")
    self.rl12 = self.transform:Find("Right/Map/RL/12")
    self.rl13 = self.transform:Find("Right/Map/RL/13")

    self.Rank = self.transform:Find("Right/Rank")
    self.Headbar = self.transform:Find("Right/Rank/Headbar")

    self.MaskScroll = self.transform:Find("Right/Rank/MaskScroll")
    self.ListCon = self.transform:Find("Right/Rank/MaskScroll/ListCon")

    self.BaseItem = self.transform:Find("Right/Rank/MaskScroll/ListCon/Item1")

    self.Rank = self.transform:Find("Right/Rank/MaskScroll/ListCon/Item1/Rank")
    self.RankIcon = self.transform:Find("Right/Rank/MaskScroll/ListCon/Item1/RankIcon")
    self.GuildName = self.transform:Find("Right/Rank/MaskScroll/ListCon/Item1/GuildName")
    self.Score = self.transform:Find("Right/Rank/MaskScroll/ListCon/Item1/Score")
    self.SvrName = self.transform:Find("Right/Rank/MaskScroll/ListCon/Item1/SvrName")
    self.LeaderName = self.transform:Find("Right/Rank/MaskScroll/ListCon/Item1/LeaderName")
    self.Member = self.transform:Find("Right/Rank/MaskScroll/ListCon/Item1/Member")
    self.Up = self.transform:Find("Right/Rank/MaskScroll/ListCon/Item1/Up")
    self.Text = self.transform:Find("Right/Rank/MaskScroll/ListCon/Item1/Up/Text")
    self.Down = self.transform:Find("Right/Rank/MaskScroll/ListCon/Item1/Down")
    self.Text = self.transform:Find("Right/Rank/MaskScroll/ListCon/Item1/Down/Text")
    self:InitRankList()
end

function GuildLeagueSchedulePanel:InitRankList()
    if self.Mgr.guild_LeagueInfo == nil then
        return
    end
    local list = {{},{},{},{},{},{},{},{},{},{},{}}
    self.item_list = {}
    self.item_con = self.ListCon
    self.item_con_last_y = self.item_con:GetComponent(RectTransform).anchoredPosition.y
    self.single_item_height = self.BaseItem:GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = self.MaskScroll:GetComponent(RectTransform).sizeDelta.y
    local num = self.Mgr.guild_LeagueInfo.season_id
    for i=1,7 do
        local go = self.item_con:GetChild(i-1).gameObject
        local item = GuildLeagueScheduleItem.New(go, self)
        table.insert(self.item_list, item)
    end
    self.setting_data = {
       item_list = self.item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.item_con  --item列表的父容器
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
    self.vScroll = self.MaskScroll:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.setting_data.data_list = list
    BaseUtils.refresh_circular_list(self.setting_data)
end

function GuildLeagueSchedulePanel:UpdataList()
    self.setting_data.data_list = list
    BaseUtils.refresh_circular_list(self.setting_data)
end