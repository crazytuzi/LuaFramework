GuildDragonRank = GuildDragonRank or BaseClass(BasePanel)

function GuildDragonRank:__init(model, parent)
    self.model = model
    self.parent = parent

    self.resList = {
        {file = AssetConfig.guilddragon_rank, type = AssetType.Main},
        {file = AssetConfig.rank_textures, type = AssetType.Dep},
    }

    self.rankTitleString = {
        {TI18N("排名"), TI18N("名称"), TI18N("职业"), TI18N("公会")},
        {TI18N("排名"), TI18N("公会"), TI18N("等级"), TI18N("会长")},
    }

    self.personList = {}
    self.updateListener = function(index) if index == self.index then self:Update(index) end end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildDragonRank:__delete()
    self.OnHideEvent:Fire()
    if self.titleLoader ~= nil then
        self.titleLoader:DeleteMe()
        self.titleLoader = nil
    end
    if self.personList ~= nil then
        for _,person in pairs(self.personList) do
            person:DeleteMe()
        end
        self.personList = nil
    end
    if self.myItem ~= nil then
        self.myItem:DeleteMe()
        self.myItem = nil
    end
    if self.personLayout ~= nil then
        self.personLayout:DeleteMe()
        self.personLayout = nil
    end
end

function GuildDragonRank:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddragon_rank))
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform.anchoredPosition3D = Vector3.zero
    local t = self.transform
    self.personItem = t:Find("Cloner").gameObject
    local container = t:Find("Scroll/Container")
    self.personLayout = LuaBoxLayout.New(container, {axis = BoxLayoutAxis.Y, cspacing = 0})
    self.personList[1] = GuildDragonPerson.New(self.model, self.personItem, self.assetWrapper)
    self.personLayout:AddCell(self.personItem)
    for i=2,15 do
        self.personList[i] = GuildDragonPerson.New(self.model, GameObject.Instantiate(self.personItem), self.assetWrapper)
        self.personLayout:AddCell(self.personList[i].gameObject)
    end
    self.nothingObj = t:Find("Nothing").gameObject
    self.personScroll = t:Find("Scroll"):GetComponent(ScrollRect)
    self.myItem = GuildDragonPerson.New(self.model, t:Find("MyScore").gameObject, self.assetWrapper)

    self.titleList = {}
    for i=1,4 do
        self.titleList[i] = t:Find("Title"):GetChild(i - 1):GetComponent(Text)
    end
    self.titleLoader = SingleIconLoader.New(t:Find("Title"):GetChild(4).gameObject)
    self.titleLoader:SetSprite(SingleIconType.Item, 90054)

    self.personSetting = {
       item_list = self.personList
       ,data_list = {} --数据列表
       ,item_con = container  --item列表的父容器
       ,single_item_height = self.personItem.transform.sizeDelta.y --一条item的高度
       ,item_con_last_y = container.anchoredPosition.y ---父容器改变时上一次的y坐标
       ,scroll_con_height = self.personScroll.transform.rect.height --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.personScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.personSetting) end)
end

function GuildDragonRank:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildDragonRank:OnOpen()
    self:RemoveListeners()
    GuildDragonManager.Instance.updateRankEvent:AddListener(self.updateListener)
    -- GuildDragonManager.Instance:send20507(23, "local", 1)

    self.index = self.openArgs or 1
    self:ChangeTitle(self.index)
    self:Update(self.index)
    self:CheckUpdateTimer()
end

function GuildDragonRank:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function GuildDragonRank:RemoveListeners()
    GuildDragonManager.Instance.updateRankEvent:RemoveListener(self.updateListener)
end

function GuildDragonRank:Update(index)
    if index ~= self.index or index == nil then
        return
    end
    self:UpdateMyself(index)
    local datalist = {}
    for i,v in ipairs(self.model.rank_list[index] or {}) do
        if i <= 100 then
            table.insert(datalist, v)
        end
    end
    self.personSetting.data_list = datalist
    BaseUtils.refresh_circular_list(self.personSetting)

    self.nothingObj:SetActive(next(self.personSetting.data_list) == nil)
end

function GuildDragonRank:CheckUpdateTimer()
    local delay = 30
    if IS_DEBUG then
        delay = 10
    end
    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, delay * 1000, function() GuildDragonManager.Instance:send20502(self.index, 100) end)
    end
end

function GuildDragonRank:ChangeTitle(index)
    for i,title in ipairs(self.titleList) do
        title.text = self.rankTitleString[index][i]
    end
end

function GuildDragonRank:UpdateMyself(index)
    local roleData = RoleManager.Instance.RoleData
    local guildData = GuildManager.Instance.model.my_guild_data
    local myData = nil
    if index == 1 then
        myData = {id = roleData.id, platform = roleData.platform, zone_id = roleData.zone_id, rank_index = 0, rank_type = 1, sex = roleData.sex, classes = roleData.classes, guild_name = guildData.Name, target_name = roleData.name, lev = roleData.lev, point = (self.model.myData or {}).point or 0}
        for i,data in ipairs(self.model.rank_list[1] or {}) do
            if i <= 100 and data.id == myData.id and data.platform == myData.platform and data.zone_id == myData.zone_id then
                myData = data
                break
            end
        end
    else
        myData = {id = guildData.LeaderRid, platform = guildData.LeaderPlatform, zone_id = guildData.LeaderZoneId, rank_index = 0, rank_type = 2, sex = guildData.LeaderSex, classes = guildData.LeaderClasses, guild_name = guildData.Name, target_name = guildData.LeaderName, lev = guildData.Lev, point = 0}
        for i,data in ipairs(self.model.rank_list[2] or {}) do
            if i <= 100 and data.guild_name == guildData.Name then
                myData = data
                break
            end
        end
    end
    self.myItem:SetData(myData)
end
