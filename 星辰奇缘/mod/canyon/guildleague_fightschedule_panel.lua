-- 冠军联赛对阵赛程列表面板
-- 赛季赛程
-- 2016年09月26日
GuildLeagueFightSchedulePanel = GuildLeagueFightSchedulePanel or BaseClass(BasePanel)

function GuildLeagueFightSchedulePanel:__init(parent, Main)
    self.model = model
    self.Mgr = GuildLeagueManager.Instance
    self.parent = parent
    self.Main = Main
    self.name = "GuildLeagueFightSchedulePanel"
    self.EffectPath = "prefabs/effect/20194.unity3d"
    self.Titletimer = nil
    self.resList = {
        {file = AssetConfig.guildleague_fightschedule_panel, type = AssetType.Main},
        {file = self.EffectPath, type = AssetType.Main},
        {file = AssetConfig.guildleague_texture, type = AssetType.Dep},
        {file = AssetConfig.guild_totem_icon, type = AssetType.Dep},
        {file = AssetConfig.blue_light, type = AssetType.Dep},

    }
    self.effectList = {}
    self.LineGroup = {
        ["11"] = {"1", "2", "17"},
        ["12"] = {"3", "4", "17"},
        ["13"] = {"5", "6", "18"},
        ["14"] = {"7", "8", "18"},
        ["15"] = {"9", "10", "19"},
        ["16"] = {"11", "12", "19"},
        ["17"] = {"13", "14", "20"},
        ["18"] = {"15", "16", "20"},
        ["19"] = {"1", "2", "17"},
        ["110"] = {"3", "4", "17"},
        ["111"] = {"5", "6", "18"},
        ["112"] = {"7", "8", "18"},
        ["113"] = {"9", "10", "19"},
        ["114"] = {"11", "12", "19"},
        ["115"] = {"13", "14", "20"},
        ["116"] = {"15", "16", "20"},
        ["21"] = {"21", "25"},
        ["22"] = {"22", "25"},
        ["23"] = {"23", "26"},
        ["24"] = {"24", "26"},
        ["25"] = {"21", "25"},
        ["26"] = {"22", "25"},
        ["27"] = {"23", "26"},
        ["28"] = {"24", "26"},
        ["31"] = {"27", "29"},
        ["32"] = {"28", "29"},
        ["33"] = {"27", "29"},
        ["34"] = {"28", "29"},
        ["41"] = {"29"},
        ["42"] = {"29"}
    }
    self.dataupdate = function()
        self:UpdateRed()
        self:OnDataUpdate()
    end
    self.kingteamupdate = function()
        self:UpdateRed()
        self:UpdateKingPanel()
    end
    self.data = {}
    self.TabList = {}
    self.failed = {}
    self.index1 = 1
    self.index2 = 1
    self.index3 = 1
    self.openguess = false
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildLeagueFightSchedulePanel:OnOpen()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
    local openarg = self.openArgs
    self.openArgs = nil
    if openarg ~= nil then
        if openarg[1] ~= nil then
            self.DropDownList1:ChangeTab(openarg[1])
        end
        if openarg[2] ~= nil and openarg[2] ~= self.index2 then
            self.DropDownList2:ChangeTab(openarg[2])
        end
    else
        self.DropDownList1:ChangeTab(self.index1)
    end
end

function GuildLeagueFightSchedulePanel:OnHide()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function GuildLeagueFightSchedulePanel:__delete()
    self.Mgr.LeagueFightScheduleUpdate:RemoveListener(self.dataupdate)
    self.Mgr.LeagueKingGuildUpdate:RemoveListener(self.kingteamupdate)
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GuildLeagueFightSchedulePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleague_fightschedule_panel))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.bg = self.transform:Find("bg")
    self.TxtImage = self.transform:Find("TxtImage")
    self.DescText = self.transform:Find("DescText")

    self.Rank = self.transform:Find("Rank")
    self.Headbar = self.transform:Find("Rank/Headbar")
    self.MaskScroll = self.transform:Find("Rank/MaskScroll")
    self.ListCon = self.transform:Find("Rank/MaskScroll/ListCon")
    self.NoIMG = self.transform:Find("Rank/NoIMG").gameObject

    self.BaseItem = self.transform:Find("Rank/MaskScroll/ListCon/Item1")

    self.TabMaskScroll = self.transform:Find("MaskScroll")
    self.Desc = self.transform:Find("Desc")
    self.BaseButton = self.transform:Find("MaskScroll/Button").gameObject
    self.TabButtonGroup = self.transform:Find("MaskScroll/TabButtonGroup")

    self.AliveEffect = GameObject.Instantiate(self:GetPrefab(self.EffectPath))
    self.AliveEffect.transform:SetParent(self.transform)
    self.AliveEffect.transform.localScale = Vector3(1.7, 0.6, 1)
    self.AliveEffect.transform.localPosition = Vector3(-52.8, -14.6, -1000)
    Utils.ChangeLayersRecursively(self.AliveEffect.transform, "UI")
    self.AliveEffect:SetActive(false)

    self.KingPanel = self.transform:Find("KingPanel")
    self.Desc:Find("Text"):GetComponent(Text).text = TI18N("1.冠军赛采用<color='#ffff00'>1v1</color>淘汰赛制\n2.<color='#ffff00'>决赛</color>和<color='#ffff00'>季军赛</color>将在冠军联赛第4周<color='#ffff00'>周一21：30</color>举行")
    self:InitKingPanel()
    self:InitList()
    -- self.tabgroup = TabGroup.New(self.TabButtonGroup.gameObject, function (tab) self:OnTabChange(tab) end, {notAutoSelect = true})
    self.tabgroup = TabGroup.New(self.TabButtonGroup.gameObject, function (tab) self:OnTabChange(tab) end, {noCheckRepeat = true})
    self:InitDropDownList()
    self.Mgr.LeagueFightScheduleUpdate:AddListener(self.dataupdate)
    self.Mgr.LeagueKingGuildUpdate:AddListener(self.kingteamupdate)
    local openarg = self.openArgs
    self.openArgs = nil
    if openarg ~= nil then
        if openarg[1] ~= nil and openarg[1] ~= self.index1 then
            self.DropDownList1:ChangeTab(openarg[1])
        end
        if openarg[2] ~= nil and openarg[2] ~= self.index2 then
            self.DropDownList2:ChangeTab(openarg[2])
        end
    end
    if self.index1 ~= 1 then
        self.Mgr:Require17606(self.index1, self.index2)
    else
        self.Mgr:Require17623(self.index2)
    end
end

function GuildLeagueFightSchedulePanel:OnSwitch1(index)
    -- if self.index1 == index then
    --     return
    -- end
    self.index1 = index
    if self.index1 == 1 then
        self:UpdateKingPanel()
        self.Mgr:Require17623(self.index2)
        self.Rank.gameObject:SetActive(false)
        self.KingPanel.gameObject:SetActive(true)
        self.TabMaskScroll.gameObject:SetActive(false)
        self.Desc.gameObject:SetActive(true)
    else
        self.Rank.gameObject:SetActive(true)
        self.KingPanel.gameObject:SetActive(false)
        self.TabMaskScroll.gameObject:SetActive(true)
        self.Desc.gameObject:SetActive(false)
        self.Mgr:Require17606(self.index1, self.index2)
    end
end

function GuildLeagueFightSchedulePanel:OnSwitch2(index)
    if self.index2 == index then
        return
    end
    self.index2 = index
    if self.index1 == 1 then
        self:UpdateKingPanel()
        self.Mgr:Require17623(self.index2)
        self.Rank.gameObject:SetActive(false)
        self.KingPanel.gameObject:SetActive(true)
        self.TabMaskScroll.gameObject:SetActive(false)
        self.Desc.gameObject:SetActive(true)
    else
        self.Rank.gameObject:SetActive(true)
        self.KingPanel.gameObject:SetActive(false)
        self.TabMaskScroll.gameObject:SetActive(true)
        self.Desc.gameObject:SetActive(false)
        self.Mgr:Require17606(self.index1, self.index2)
    end
end

function GuildLeagueFightSchedulePanel:OnTabChange(index)
    self.index3 = index
    self:ReloadList()
end

function GuildLeagueFightSchedulePanel:UpdatePanel()
end

function GuildLeagueFightSchedulePanel:ReloadTabBtn()
    print("重载tab")
    self.tabgroup:Init()
end

function GuildLeagueFightSchedulePanel:OnDataUpdate()
    self.data = self.Mgr.fight_schedule_info
    -- BaseUtils.dump(self.data, "整理后的数据")
    self.TabList = {}
    for k,v in pairs(self.data) do
        table.insert(self.TabList, k)
    end
    table.sort(self.TabList, function(a, b) return a>b end)
    -- BaseUtils.dump(self.TabList, "标签的数据")
    local num = self.TabButtonGroup.childCount
    for i = 0, num-1 do
        local go = self.TabButtonGroup:GetChild(0)
        if go ~= nil then
            GameObject.DestroyImmediate(go.gameObject)
        end
    end
    for i,v in ipairs(self.TabList) do
        local btn = GameObject.Instantiate(self.BaseButton)
        btn.transform:SetParent(self.TabButtonGroup)
        btn.transform.localScale = Vector3.one
        btn:SetActive(true)
        local data
        for k,v in pairs(self.data[v]) do
            data = v[1]
            break
        end

        btn.transform:Find("Normal/Text"):GetComponent(Text).text = string.format("周%s %s月%s日", data.week, data.month, data.day)
        btn.transform:Find("Select/Text"):GetComponent(Text).text = string.format("周%s %s月%s日", data.week, data.month, data.day)
    end
    self:ReloadTabBtn()
end

function GuildLeagueFightSchedulePanel:InitList()
    self.item_list = {}
    self.item_con = self.ListCon
    self.item_con_last_y = self.item_con:GetComponent(RectTransform).anchoredPosition.y
    self.single_item_height = self.BaseItem:GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = self.MaskScroll:GetComponent(RectTransform).sizeDelta.y
    local num = self.Mgr.guild_LeagueInfo.season_id
    for i=1,10 do
        local go = self.item_con:GetChild(i-1).gameObject
        local item = GuildLeagueFightScheduleItem.New(go, self)
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
    -- self.setting_data.data_list = list
    -- BaseUtils.refresh_circular_list(self.setting_data)
end


function GuildLeagueFightSchedulePanel:ReloadList()
    local key = self.TabList[self.index3]
    if key == nil then
        -- print("key值找不到")
        self.NoIMG:SetActive(true)
        self.setting_data.data_list = {}
        BaseUtils.refresh_circular_list(self.setting_data)
        return
    end
    local list = self.data[key]
    if list == nil then
        -- print("数据找不到")
        self.NoIMG:SetActive(true)
        self.setting_data.data_list = {}
        BaseUtils.refresh_circular_list(self.setting_data)
        return
    end
    local temp = {}
    for k,v in pairs(list) do
        table.insert(temp, v)
    end
    self.setting_data.data_list = temp
    -- BaseUtils.dump(temp)
    self.NoIMG:SetActive(#temp <=0)
    BaseUtils.refresh_circular_list(self.setting_data)
end

function GuildLeagueFightSchedulePanel:InitDropDownList()
    self.index1 = self.Mgr.guild_LeagueInfo.grade
    self.index2 = self.Mgr.guild_LeagueInfo.season_id
    self.SwitchButton2 = self.transform:Find("SwitchButton2")
    self.SwitchButton1 = self.transform:Find("SwitchButton1")

    local Con = self.SwitchButton2:Find("List/MaskScroll/ListCon")
    local baseitem = Con:GetChild(0)
    for i=2, self.Mgr.guild_LeagueInfo.season_id do
        local btn = GameObject.Instantiate(baseitem.gameObject)
        btn.transform:SetParent(Con)
        btn.transform:Find("I18NText"):GetComponent(Text).text = string.format(TI18N("第%s赛季"), tostring(BaseUtils.NumToChn(i)))
        -- btn.transform:Find("I18NText"):GetComponent(Text).text = string.format(TI18N("第%s赛季"), tostring(BaseUtils.NumToChn(self.Mgr.guild_LeagueInfo.season_id)))
        btn.transform.localScale = Vector3.one
        btn.transform.anchoredPosition = Vector2(0, -24+(i-1)*-40)
    end
    Con.sizeDelta = Vector2(160, self.index2*40)
    self.DropDownList2 = DropDownList.New(self.SwitchButton2.gameObject, function(index) self:OnSwitch2(index) end, {notAutoSelect = false, defaultindex = self.index2})

    self.DropDownList1 = DropDownList.New(self.SwitchButton1.gameObject, function(index) self:OnSwitch1(index) end, {notAutoSelect = false, defaultindex = self.index1})

end

function GuildLeagueFightSchedulePanel:InitKingPanel()
    self.nokingImg = self.transform:Find("KingPanel/NoIMG").gameObject
    self.Map = self.transform:Find("KingPanel/Map").gameObject
    self.transform:Find("KingPanel/Map/Light"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.blue_light, "blue_light")
    self.LLine = self.transform:Find("KingPanel/Map/LeftLine")
    self.RLine = self.transform:Find("KingPanel/Map/RightLine")
    self.GuessButton = self.transform:Find("KingPanel/Map/GuessButton"):GetComponent(Button)
    self.GuessButton.onClick:AddListener(function()
        if self.openguess then
            GuildLeagueManager.Instance.model:OpenGuessWindow()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("竞猜将在<color='#ffff00'>8进4</color>比赛时开启"))
        end
    end)
    self.transform:Find("KingPanel/Map/LiveButton"):GetComponent(Button).onClick:AddListener(function()
        GuildLeagueManager.Instance:Require17627()
    end)
    self.memberList = {}
    for i=1, 2 do
        local parent = self.transform:Find("KingPanel/Map/LGroup")
        if i == 2 then
            parent = self.transform:Find("KingPanel/Map/RGroup")
        end
        for child = 1, 8 do
            local item = parent:GetChild(child-1)
            local index = (i-1)*8+child
            self.memberList[index] = {}
            self.memberList[index].trans = item
            self.memberList[index].Text = item:Find("Text"):GetComponent(Text)
            self.memberList[index].button = item:GetComponent(Button)
        end
    end

end

function GuildLeagueFightSchedulePanel:UpdateKingPanel()
    self:ClearKingPanel()
    if self.Mgr.kingGuildData ~= nil and next(self.Mgr.kingGuildData) ~= nil and next(self.Mgr.kingGuildData.guild) ~= nil then
        for i,v in ipairs(self.Mgr.kingGuildData.guild) do
            self.memberList[i].Text.text = v.name
            self.memberList[i].Text.color = Color(0.19, 0.35, 0.68)
            if GuildManager.Instance.model.my_guild_data ~= nil and GuildManager.Instance.model.my_guild_data.Name == v.name then
                self.memberList[i].Text.text = string.format("<color='#ffff00'>%s</color>", v.name)
            end
            self.memberList[i].button.onClick:RemoveAllListeners()
            self.memberList[i].button.onClick:AddListener(function()
                -- BaseUtils.dump(v)
                self:LookGuild(v, i)
            end)
        end
        local light = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "line2")
        for i=1, 4 do
            local resultdata = self.Mgr.kingGuildData[i]
            if resultdata == nil then
                resultdata = {}
            end
            if i == 1 and #resultdata > 0 then
                self.openguess = true
            end
            if i == 2 then
                for _, guildindex in pairs(resultdata) do
                    if self.effectList[guildindex] == nil then
                        local go = GameObject.Instantiate(self.AliveEffect)
                        go.transform:SetParent(self.memberList[guildindex].trans)
                        go.transform.localScale = Vector3(1, 1, 1)
                        go.transform.localPosition = Vector3(0, 0, -380)
                        Utils.ChangeLayersRecursively(self.AliveEffect.transform, "UI")
                        go:SetActive(true)
                        self.effectList[guildindex] = go
                    end
                end
            end
            if next(resultdata) ~= nil and #resultdata == math.pow(2,4-i) then
                for i=1, 16 do
                    if not table.containValue(resultdata, i) then
                        self.failed[i] = true
                        self.memberList[i].trans:GetComponent(Image).color = Color(0.55, 0.55, 0.55)
                        self.memberList[i].Text.color = ColorHelper.DefaultButton4
                        if self.effectList[i] ~= nil then
                            GameObject.DestroyImmediate(self.effectList[i])
                            self.effectList[i] = nil
                        end
                    end
                end
            end
            for _, guildindex in pairs(resultdata) do
                local pow = math.pow(2, i-1)
                local subindex = math.ceil(guildindex/pow)
                local line = string.format("%s%s", tostring(i), tostring(subindex))
                local linedata = self.LineGroup[line]
                local Lineimg = nil
                if guildindex < 9 then
                    for _, str in ipairs(linedata) do
                        self.LLine:Find(str):GetComponent(Image).sprite = light
                    end
                    -- Lineimg = self.LLine:Find(line):GetComponent(Image)

                else
                    -- Lineimg = self.RLine:Find(line):GetComponent(Image)
                    for _, str in ipairs(linedata) do
                        self.RLine:Find(str):GetComponent(Image).sprite = light
                    end
                end
            end
            if i == 4 and resultdata[1] ~= nil then
                for k,v in pairs(self.Mgr.kingGuildData.phasedata[i]) do
                    if v.season_consecutive_win == 4 then

                        self.transform:Find("KingPanel/Map/1/Text"):GetComponent(Text).text = v.name
                        self.transform:Find("KingPanel/Map/1"):GetComponent(Button).onClick:RemoveAllListeners()
                        self.transform:Find("KingPanel/Map/1"):GetComponent(Button).onClick:AddListener(function()
                            self:LookGuild(v)
                        end)
                    elseif v.season_consecutive_win >= 3 then
                        if self.effectList[v.index] ~= nil then
                            GameObject.DestroyImmediate(self.effectList[v.index])
                            self.effectList[v.index] = nil
                            self.memberList[v.index].trans:GetComponent(Image).color = Color(0.55, 0.55, 0.55)
                            self.memberList[v.index].Text.color = ColorHelper.DefaultButton4
                            self.failed[v.index] = true
                        end
                        self.transform:Find("KingPanel/Map/2/Text"):GetComponent(Text).text = v.name
                        self.transform:Find("KingPanel/Map/2"):GetComponent(Button).onClick:RemoveAllListeners()
                        self.transform:Find("KingPanel/Map/2"):GetComponent(Button).onClick:AddListener(function()
                            self:LookGuild(v)
                        end)
                    elseif v.season_consecutive_win == 2 and v.is_win == 1 then
                        self.transform:Find("KingPanel/Map/3/Text"):GetComponent(Text).text = v.name
                        self.transform:Find("KingPanel/Map/3"):GetComponent(Button).onClick:RemoveAllListeners()
                        self.transform:Find("KingPanel/Map/3"):GetComponent(Button).onClick:AddListener(function()
                            self:LookGuild(v)
                        end)
                    end
                end
            end
        end
        self.Map:SetActive(true)
        self.nokingImg:SetActive(false)
    else
        self.Map:SetActive(false)
        self.nokingImg:SetActive(true)
    end
end

function GuildLeagueFightSchedulePanel:LookGuild(data, index)
    print("观看公会数据："..data.name)
    if self.failed[index] == true then
        NoticeManager.Instance:FloatTipsByString(TI18N("该公会已战败，无法查看"))
        return
    end
    self.Mgr:Require17624(data.guild_id, data.platform, data.zone_id, self.index2)
end

function GuildLeagueFightSchedulePanel:ClearKingPanel()
    for i=1,16 do
        self.memberList[i].Text.text = ""
        self.memberList[i].button.onClick:RemoveAllListeners()
        self.memberList[i].trans:GetComponent(Image).color = Color.white
    end
    local str = {
        [1] = TI18N("冠军"),
        [2] = TI18N("亚军"),
        [3] = TI18N("季军"),
    }
    for i=1,3 do
        self.transform:Find(string.format("KingPanel/Map/%s/Text", i)):GetComponent(Text).text = str[i]
        self.transform:Find(string.format("KingPanel/Map/%s", i)):GetComponent(Button).onClick:RemoveAllListeners()
    end
    for k,v in pairs(self.effectList) do
        if not BaseUtils.isnull(v) then
            GameObject.DestroyImmediate(v)
        end
    end
    self.failed = {}
    self.effectList = {}
    local LImg = self.LLine:GetComponentsInChildren(Image, true)
    local RImg = self.RLine:GetComponentsInChildren(Image, true)
    local unlight = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "line1")
    for k,v in pairs(LImg) do
        v.sprite = unlight
    end
    for k,v in pairs(RImg) do
        v.sprite = unlight
    end
end

function GuildLeagueFightSchedulePanel:UpdateRed()
    self.GuessButton.gameObject.transform:Find("red").gameObject:SetActive(self.Mgr:CheckCanGuess())
    self.transform:Find("KingPanel/Map/LiveButton/red").gameObject:SetActive(self.Mgr.guild_LeagueInfo ~= nil and self.Mgr.guild_LeagueInfo.cur_phase > 4 and self.Mgr.currstatus == 2)

end