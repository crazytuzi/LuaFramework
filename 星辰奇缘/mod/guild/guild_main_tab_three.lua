GuildMainTabThree = GuildMainTabThree or BaseClass(BasePanel)

function GuildMainTabThree:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.guild_main_tab3, type = AssetType.Main}
        ,{file = AssetConfig.guild_activity_bg, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = AssetConfig.guild_activity_icon, type = AssetType.Dep}
        , {file = AssetConfig.guild_second_bg, type = AssetType.Dep}
    }

    self.fight_status_update = function()
        if self.has_init == false then
            return
        end
        if self.fuli_item_list ~= nil then
            -- BaseUtils.dump(self.fuli_item_list,"----------------self.fuli_item_list---------------")
            for i=1,#self.fuli_item_list do
                local item = self.fuli_item_list[i]
                local state = false
                if item.data.id == 1002 then --公会战
                    state = GuildfightManager.Instance:IsGuildFightStart()
                elseif item.data.id == 1007 then --公会精英战
                    state = GuildFightEliteManager.Instance:checkRedPoint()
                    -- print(state)
                elseif item.data.id == 1008 then -- 冠军联赛
                    state = GuildLeagueManager.Instance:CheckRed()
                elseif item.data.id == 1009 then
                    state = GuildSiegeManager.Instance.model.status ~= GuildSiegeEumn.Status.Disactive and GuildSiegeManager.Instance:IsMyGuildIn()
                elseif item.data.id == 1010 then
                    state = GuildDungeonManager.Instance.model:CheckRedPonint()
                elseif item.data.id == 1011 then
                    state = GuildAuctionManager.Instance:CheckRedPonint()
                elseif item.data.id == 1012 then
                    state = GuildDragonManager.Instance:CheckRedPoint()
                elseif item.data.id == 1013 then
                    state = (TruthordareManager.Instance.model.openState == 1 )
                end

                if RoleManager.Instance.RoleData.lev < 65 then
                    state = false
                end
                item.ImgPoint:SetActive(state)
            end
        end
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)

    return self
end

function GuildMainTabThree:__delete()
    if self.fuli_item_list ~= nil then
        for k, v in pairs(self.fuli_item_list) do
            v.ImgIcon.sprite = nil
        end
    end
    EventMgr.Instance:RemoveListener(event_name.guild_fight_status_update, self.fight_status_update)
    EventMgr.Instance:RemoveListener(event_name.guildfight_elite_acitveinfo_change, self.fight_status_update)
    EventMgr.Instance:RemoveListener(event_name.guildfight_elite_leaderinfo_change, self.fight_status_update)
    GuildAuctionManager.Instance.OnGoodsUpdate:Remove(self.fight_status_update)

    self.has_init = false
    self.fuli_item_list = nil

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function GuildMainTabThree:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_main_tab3))
    self.gameObject.name = "GuildMainTabThree"
    self.transform = self.gameObject.transform

    UIUtils.AddUIChild(self.parent.mainObj, self.gameObject)

    self.activity_ImgTopBg = self.transform:FindChild("ImgTopBg")
    local obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_activity_bg))
    UIUtils.AddBigbg(self.activity_ImgTopBg:FindChild("ImgWord"), obj)
    obj.transform:SetAsFirstSibling()

    local go = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_second_bg))
    UIUtils.AddBigbg(self.transform:FindChild("ImgTopBg"):FindChild("Con"), go)
    go.transform.localScale = Vector3(1.38, 1.38, 1)

    self.activity_ImgTopBg.gameObject:SetActive(false)

    self.activity_scroll_rect = self.transform:FindChild("MaskLayer"):FindChild("ScrollLayer")
    self.scrollRect = self.activity_scroll_rect:GetComponent(ScrollRect)
    self.activity_layout_con = self.activity_scroll_rect:FindChild("LayoutLayer")
    self.originWfItem = self.activity_layout_con:FindChild("Item").gameObject
    self.originWfItem.gameObject:SetActive(false)

    self.has_init = true

    -- GuildManager.Instance:request11146()
    -- AgendaManager.Instance:Require12000()

    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()

    EventMgr.Instance:AddListener(event_name.guild_fight_status_update, self.fight_status_update)
    EventMgr.Instance:AddListener(event_name.guildfight_elite_acitveinfo_change, self.fight_status_update)
    EventMgr.Instance:AddListener(event_name.guildfight_elite_leaderinfo_change, self.fight_status_update)
    GuildAuctionManager.Instance.OnGoodsUpdate:Add(self.fight_status_update)
end

function GuildMainTabThree:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildMainTabThree:OnOpen()
    self.fight_status_update()
    self:init_left_view()
end

function GuildMainTabThree:init_left_view()
    if self.has_init == false then
        return
    end
    self.activity_ImgTopBg.gameObject:SetActive(true)


    GuildManager.Instance:request11120()
    if GuildSiegeManager.Instance.model.status == 0 then
        GuildSiegeManager.Instance:send19101()
    end
    self:update_fuli()
end

----------item逻辑
function GuildMainTabThree:update_fuli()
    if self.has_init == false then
        return
    end

    if self.fuli_item_list == nil then
        self.fuli_item_list = {}
    else
        for i=1, #self.fuli_item_list do
            local it = self.fuli_item_list[i]
            it.go:SetActive(false)
        end
    end

    local lev_sort = function(a, b)
        return a.rank > b.rank --根据lev从小到大排序
    end

    table.sort(DataGuild.data_get_activity_data, lev_sort)

    local index = 1
    for i=1,#DataGuild.data_get_activity_data do
        local v= DataGuild.data_get_activity_data[i]
        if  v.id ~= 1005 and v.id ~= 1006 and v.world_lev <= RoleManager.Instance.world_lev then
            local item = self.fuli_item_list[index]
            if item == nil then
                item = self:create_guild_activity_item(self.originWfItem, index)
                table.insert(self.fuli_item_list, item)
            end
            self:set_activity_data(item, v)
            index = index + 1
        end
    end

    --这里做高度设置


    self.fight_status_update()
end

--公会活动item
function GuildMainTabThree:create_guild_activity_item(_origin_item, index)
    local item = {}

    item.go = GameObject.Instantiate(_origin_item)
    item.transform = item.go.transform
    item.go:SetActive(true)
    item.transform:SetParent(_origin_item.transform.parent)
    item.transform.localPosition = Vector3(0, 0, 0)
    item.transform.localScale = Vector3(1, 1, 1)

    local newY = -45 + (math.ceil(index/2)-1)*-95
    local newX = 184
    if (index%2) == 0 then
        newX = 546
    end
    local rect = item.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(newX, newY)

    item.ImgIconCon = item.transform:FindChild("ImgIconCon")
    item.ImgIcon = item.ImgIconCon:FindChild("ImgIcon"):GetComponent(Image)
    item.TxtGuildName = item.transform:FindChild("TxtGuildName"):GetComponent(Text)
    item.TxtGuildDesc = item.transform:FindChild("TxtGuildDesc"):GetComponent(Text)
    item.BtnJoin = item.transform:FindChild("BtnJoin"):GetComponent(Button)
    item.ImgPoint = item.transform:FindChild("ImgPoint").gameObject
    item.TxtJoin = item.transform:FindChild("TxtJoin").gameObject
    item.TxtJoin:SetActive(false)
    local on_click = function(g)
        if item.data.lev <= self.parent.model.my_guild_data.Lev then
            print(item.data.id)
            if item.data.id == 1001 then --公会任务
                if RoleManager.Instance.RoleData.lev >= 20 then
                    -- 等级达到条件，当天还有领取次数，操作参加按钮
                    self.parent.model:CloseMainUI()
                    AgendaManager.Instance.model:SpecialDaily(1013)
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("提升到20级才可领取公会任务哦"))
                end
            elseif item.data.id == 1002 then --公会战
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_fight_window)
            elseif item.data.id == 1003 then
                --公会强盗
                GuildManager.Instance:request11128() --请求进入公会领地
            elseif item.data.id == 1005 then

                if mod_guild.question_notify_data ~= nil and mod_guild.question_notify_data.type ~= 0 then
                    GuildManager.Instance:request11128() --请求进入公会领地
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("每天晚上20:00开启"))
                end
            elseif item.data.id == 1006 then
                if mod_guild.question_notify_data ~= nil and mod_guild.question_notify_data.type ~= 0 then
                    GuildManager.Instance:request11128() --请求进入公会领地
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("每天晚上20:00开启"))
                end
            elseif item.data.id == 1007 then --公会精英 战
                if GuildManager.Instance.model.my_guild_data.Lev >= 2 then --2级以上
                    if GuildManager.Instance.model.my_guild_data.MemNum >= 50 then
                        if GuildManager.Instance.model.my_guild_data.create_time >= 259200  then
                            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guildfightelite_window)
                        else
                            NoticeManager.Instance:FloatTipsByString(TI18N("由于本公会创建时间<3天，无法参加本次公会英雄战"))
                        end
                    else
                        NoticeManager.Instance:FloatTipsByString(TI18N("由于本公会总人数<50人，无法参加本次公会英雄战"))
                    end
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("由于本公会等级<2级，无法参加本次公会英雄战"))
                end
            elseif item.data.id == 1008 then --冠军联赛
                if RoleManager.Instance.world_lev >= 80 and RoleManager.Instance.RoleData.lev >= 70 then
                    GuildLeagueManager.Instance.model:OpenWindow()
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开放，敬请期待"))
                end
            elseif item.data.id == 1009 then -- 公会攻城战
                self:OnGuildSiege()
            elseif item.data.id == 1010 then -- 公会副本
                self:OnGuildDungeon()
            elseif item.data.id == 1011 then -- 公会副本
                GuildAuctionManager.Instance.model:OpenWindow()
            elseif item.data.id == 1012 then -- 公会魔龙
                GuildDragonManager.Instance:Enter()
            elseif item.data.id == 1013 then -- 真心话大冒险
                local truthState = TruthordareManager.Instance.model.openState
                if truthState == 1 then
                    if RoleManager.Instance.RoleData.lev >= 30 then
                        WindowManager.Instance:CloseCurrentWindow()
                        ChatManager.Instance.model:ShowChatWindow({MsgEumn.ChatChannel.Guild})
                    else
                        NoticeManager.Instance:FloatTipsByString(TI18N("提升到30级才可参加该活动哦"))
                    end
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开放，敬请期待"))
                end
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开放，敬请期待"))
        end
    end


    item.BtnJoin.onClick:AddListener(on_click)

    return item
end

function GuildMainTabThree:OnGuildSiege()
    if GuildSiegeManager.Instance.model.canOpenPanel ~= 1 then
        NoticeManager.Instance:FloatTipsByString(GuildSiegeManager.Instance.model.msg)
        return
    end

    if GuildSiegeManager.Instance:IsMyGuildIn() then
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.guildwindow)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_siege_castle_window)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开放，敬请期待"))
    end
end

function GuildMainTabThree:OnGuildDungeon()
    if RoleManager.Instance.RoleData.lev >= 65 then
        local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
        local currentHour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
        if currentWeek == 0 then currentWeek = 7 end
        if currentWeek >= 1 and currentWeek <= 6 and currentHour >= 11 and currentHour < 23 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guilddungeonwindow)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("开启时间为周一~周六11:00~23:00"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("提升到65级才可参与英雄副本哦"))
    end
end

function GuildMainTabThree:set_activity_data(item, data)
    item.data = data

    item.ImgIcon.sprite  = self.assetWrapper:GetSprite(AssetConfig.guild_activity_icon, tostring(data.id))
    item.ImgIcon.gameObject.transform.sizeDelta = Vector2(64, 64)
    -- item.ImgIcon:SetNativeSize()

    item.TxtGuildName.text = data.name
    item.TxtGuildDesc.text = data.explanation
    -- item.BtnJoin
    if item.data.id == 1002 then
        -- item.BtnJoin.gameObject:SetActive(true)
    elseif item.data.id == 1001 then
        --检查下 当天公会任务次数已满，按钮屏蔽显示成  已完成
        local cfg_data = DataAgenda.data_list[1013]
        local left_time = 0
        if cfg_data ~= nil then
            left_time = cfg_data.max_try - cfg_data.engaged
        end
        if left_time > 0 then
            item.BtnJoin.gameObject:SetActive(true)
            item.TxtJoin:SetActive(false)
        else
            item.BtnJoin.gameObject:SetActive(false)
            item.TxtJoin:SetActive(true)
            item.TxtJoin.transform:GetComponent(Text).text = string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("已完成"))
        end
    elseif item.data.id == 1003 then
        item.BtnJoin.gameObject:SetActive(true)
        item.TxtJoin:SetActive(false)
    end

    item.go:SetActive(true)
end