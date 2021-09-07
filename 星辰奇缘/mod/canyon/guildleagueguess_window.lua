--作者:hzf
--10/25/2016 21:42:06
--功能:公会联赛竞猜

GuildLeagueGuessWindow = GuildLeagueGuessWindow or BaseClass(BaseWindow)
function GuildLeagueGuessWindow:__init(model)
	self.model = model
	self.Mgr = GuildLeagueManager.Instance
    self.EffectPath = "prefabs/effect/20053.unity3d"
    self.LineEffectPath = "prefabs/effect/20221.unity3d"
	self.resList = {
		{file = AssetConfig.guildleagueguesswindow, type = AssetType.Main},
        {file = self.EffectPath, type = AssetType.Main},
        {file = self.LineEffectPath, type = AssetType.Main},
		{file = AssetConfig.guildleague_texture, type = AssetType.Dep},
        {file = AssetConfig.guild_totem_icon, type = AssetType.Dep},
		{file = AssetConfig.blue_light, type = AssetType.Dep},
        {file = AssetConfig.bible_daily_gfit_bg2, type = AssetType.Dep},
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.LineGroup = {
        ["21"] = {"1", "2", "9"},
        ["22"] = {"3", "4", "9"},
        ["23"] = {"5", "6", "10"},
        ["24"] = {"7", "8", "10"},
        ["25"] = {"1", "2", "9"},
        ["26"] = {"3", "4", "9"},
        ["27"] = {"5", "6", "10"},
        ["28"] = {"7", "8", "10"},
        ["31"] = {"11", "12"},
        ["32"] = {"13", "14"},
        ["33"] = {"11", "12"},
        ["34"] = {"13", "14"},
        ["41"] = {"15"},
        ["42"] = {"15"},
    }
    self.roundNum = {
        [1] = 4,
        [2] = 4,
        [3] = 2,
        [4] = 2,
    }
    self.failed = {}
    self.effectList = {}
    self.canguess = false
    self.selectround = 1
    self.kingteamupdate = function()
        if self.Mgr.kingGuildData[1] == nil or #self.Mgr.kingGuildData[1] ~= 8 then
            NoticeManager.Instance:FloatTipsByString("竞猜将在<color='#ffff00'>8进4</color>比赛时开启")
            self.model:CloseGuessWindow()
            return
        end
        self:UpdatePanel()
    end
    self.UpdateSlot = function() self:InitSlot() end
    self.guessSelect = {}
	self.hasInit = false
end

function GuildLeagueGuessWindow:__delete()
    if self.slot ~= nil then
        self.slot:DeleteMe()
    end
    self.slot = nil
    self.yessprite = nil
    self.nosprite = nil
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.UpdateSlot)
    self.Mgr.LeagueKingGuildUpdate:RemoveListener(self.kingteamupdate)
    self.Mgr.guessDataUpdate:RemoveListener(self.kingteamupdate)
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function GuildLeagueGuessWindow:__DoClickPanel()
    self.gameObject.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
        self:CheckClose()
    end)
end

function GuildLeagueGuessWindow:OnHide()

end

function GuildLeagueGuessWindow:OnOpen()

end

function GuildLeagueGuessWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleagueguesswindow))
	self.gameObject.name = "GuildLeagueGuessWindow"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
    self.transform.localPosition = Vector3(0, 0, -444)
	self.Panel = self.transform:Find("Panel")
    self.MaskPanel = self.transform:Find("MaskPanel")
	self.Main = self.transform:Find("Main")
	self.Title = self.transform:Find("Main/Title")
	self.Text = self.transform:Find("Main/Title/Text"):GetComponent(Text)
	self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function()
        self:CheckClose()
    end)
	self.Con = self.transform:Find("Main/Con")
	self.KingPanel = self.transform:Find("Main/Con/KingPanel")
	self.NoIMG = self.transform:Find("Main/Con/KingPanel/NoIMG")
	self.Text = self.transform:Find("Main/Con/KingPanel/NoIMG/Text"):GetComponent(Text)
	self.Map = self.transform:Find("Main/Con/KingPanel/Map")
	self.Light = self.transform:Find("Main/Con/KingPanel/Map/Light")
	self.Cup = self.transform:Find("Main/Con/KingPanel/Map/Cup")
	self.LGroup = self.transform:Find("Main/Con/KingPanel/Map/LGroup")

	self.RGroup = self.transform:Find("Main/Con/KingPanel/Map/RGroup")

	self.LeftLine = self.transform:Find("Main/Con/KingPanel/Map/LeftLine")

	self.RightLine = self.transform:Find("Main/Con/KingPanel/Map/RightLine")

	self.L41 = self.transform:Find("Main/Con/KingPanel/Map/L41")
	self.L42 = self.transform:Find("Main/Con/KingPanel/Map/L42")
	self.R41 = self.transform:Find("Main/Con/KingPanel/Map/R41")
	self.R42 = self.transform:Find("Main/Con/KingPanel/Map/R42")
	self.Result = self.transform:Find("Main/Con/KingPanel/Map/Result")
    local canvasgroup = self.Result:GetComponentsInChildren(CanvasGroup, true)
    for k,v in pairs(canvasgroup) do
        v.blocksRaycasts = false
    end

    self.Lbar = self.transform:Find("Main/Con/SelectPanel/bar/Lbar")
    self.Rbar = self.transform:Find("Main/Con/SelectPanel/bar/Rbar")
    self.OddsTxt = self.transform:Find("Main/Con/SelectPanel/bar/textbg/Text"):GetComponent(Text)
    self.OddsTxt.transform:GetComponent(RectTransform).sizeDelta = Vector2(400, 30)
    -- self.OddsTxt.alignment = 3
    self.OddsTxt.text = ""
    -- self.OddsTxt.text = "    赔率：1.7    支持率     赔率：0.3"
    self.LrateText = self.transform:Find("Main/Con/SelectPanel/bar/Lbar/rateText"):GetComponent(Text)
    self.RrateText = self.transform:Find("Main/Con/SelectPanel/bar/Rbar/rateText"):GetComponent(Text)
    self.LButton = self.transform:Find("Main/Con/SelectPanel/LButton"):GetComponent(Button)
    self.RButton = self.transform:Find("Main/Con/SelectPanel/RButton"):GetComponent(Button)
    self.selectButton = self.transform:Find("Main/Con/SelectPanel/SelectButton"):GetComponent(Button)
    self.SelectPanel = self.transform:Find("Main/Con/SelectPanel")
    self.transform:Find("Main/Con/SelectPanel"):GetComponent(Button).onClick:AddListener(function()
        self.transform:Find("Main/Con/SelectPanel").gameObject:SetActive(false)
    end)
    self.transform:Find("Main/Con/SelectPanel/CloseButton"):GetComponent(Button).onClick:AddListener(function()
        self.transform:Find("Main/Con/SelectPanel").gameObject:SetActive(false)
    end)


	self.Button = self.transform:Find("Main/Con/KingPanel/Button"):GetComponent(Button)
    self.Button.onClick:AddListener(function()
        self:DoGuess()
    end)

    self.transform:Find("Main/Con/KingPanel/rewardButton"):GetComponent(Button).onClick:AddListener(function()
        self:ShowReward()
    end)

    self.yessprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "guessyes")
    self.nosprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "guessno")
    self.NoticeEffect = GameObject.Instantiate(self:GetPrefab(self.EffectPath))
    self.NoticeEffect.transform:SetParent(self.transform)
    self.NoticeEffect.transform.localScale = Vector3(1.7, 0.6, 1)
    self.NoticeEffect.transform.localPosition = Vector3(-52.8, -14.6, -1000)
    Utils.ChangeLayersRecursively(self.NoticeEffect.transform, "UI")
    self.NoticeEffect:SetActive(false)

    self.LineEffect = GameObject.Instantiate(self:GetPrefab(self.LineEffectPath))
    self.LineEffect.transform:SetParent(self.Lbar)
    self.LineEffect.transform.localScale = Vector3(1.7, 0.6, 1)
    self.LineEffect.transform.localPosition = Vector3(-52.8, -14.6, -1000)
    Utils.ChangeLayersRecursively(self.LineEffect.transform, "UI")
    self.LineEffect:SetActive(true)

    self.transform:Find("Main/Con"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_daily_gfit_bg2, "DailyGiftBigBg")
    if self.Mgr.guild_LeagueInfo ~= nil and self.Mgr.guild_LeagueInfo.season_id ~= nil then
        self.Mgr:Require17623(self.Mgr.guild_LeagueInfo.season_id)
    end
    self.Mgr:Require17625()
	self:UpdatePanel()
    self.Mgr.LeagueKingGuildUpdate:AddListener(self.kingteamupdate)
    self.Mgr.guessDataUpdate:AddListener(self.kingteamupdate)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.UpdateSlot)
    self:InitSlot()
    self.transform:Find("Main/Con/KingPanel/Map/desc").anchoredPosition = Vector2(-251.7, -161.1)
    self.transform:Find("Main/Con/KingPanel/Map/desc").sizeDelta = Vector2(276, 120)
    self.transform:Find("Main/Con/KingPanel/Map/desc/Text"):GetComponent(Text).text = "规则说明：\n1.每次参与竞猜将消耗<color='#00ff00'>1张竞猜券</color>\n2.每次对<color='#00ff00'>即将开启</color>的比赛进行竞猜\n3.参与竞猜公会之后将<color='#00ff00'>无法修改</color>\n4.奖励将在活动结束后，通过<color='#ffff00'>邮件</color>发放"
    self.GiftPreview = MultiItemPanel.New(self.gameObject)
end

function GuildLeagueGuessWindow:UpdatePanel()
    if self.Mgr.kingGuildData == nil then
        return
    elseif self.Mgr.kingGuildData[1] == nil or #self.Mgr.kingGuildData[1] ~= 8 then
        -- NoticeManager.Instance:FloatTipsByString("竞猜将在<color='#ffff00'>8进4</color>比赛时开启")
        -- self.model:CloseGuessWindow()
        return
    end
    self.transform:Find("Main/Con/KingPanel/Map/3/Text"):GetComponent(Text).text = TI18N("未开始")
    self.transform:Find("Main/Con/KingPanel/Map/4/Text"):GetComponent(Text).text = TI18N("未开始")
	self.nokingImg = self.transform:Find("Main/Con/KingPanel/NoIMG").gameObject
    self.transform:Find("Main/Con/KingPanel/Map/Light"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.blue_light, "blue_light")
    self.LLine = self.transform:Find("Main/Con/KingPanel/Map/LeftLine")
    self.RLine = self.transform:Find("Main/Con/KingPanel/Map/RightLine")
    -- self.GuessButton = self.transform:Find("Main/Con/KingPanel/Map/GuessButton"):GetComponent(Button)
    self.memberList = {}
    for i=1, 2 do
        local parent = self.transform:Find("Main/Con/KingPanel/Map/LGroup")
        if i == 2 then
            parent = self.transform:Find("Main/Con/KingPanel/Map/RGroup")
        end
        for child = 1, 4 do
            local item = parent:GetChild(child-1)
            local index = (i-1)*4+child
            self.memberList[index] = {}
            self.memberList[index].trans = item
            self.memberList[index].Text = item:Find("Text"):GetComponent(Text)
            self.memberList[index].button = item:GetComponent(Button)
        end
    end
    local light = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "line2")

    for i=1, 4 do
        if self.Mgr.kingGuildData.phasedata[i] ~= nil then
            table.sort(self.Mgr.kingGuildData.phasedata[i], function(a,b) return a.index < b.index end)
        end
    end

    if self.Mgr.kingGuildData ~= nil and self.Mgr.kingGuildData.phasedata[1] ~= nil and next(self.Mgr.kingGuildData.phasedata[1]) ~= nil then
        for i,v in ipairs(self.Mgr.kingGuildData.phasedata[1]) do
            self.memberList[math.ceil(v.index/2)].Text.text = v.name
            self.memberList[math.ceil(v.index/2)].button.onClick:RemoveAllListeners()
            self.memberList[math.ceil(v.index/2)].button.onClick:AddListener(function()
                self:LookGuild(v, v.index)
            end)
        end

        if self.Mgr.kingGuildData.phasedata[2] ~= nil and next(self.Mgr.kingGuildData.phasedata[2]) ~= nil and self.Mgr.kingGuildData.phasedata[2][1].is_win ~= 0 then
            for i,v1 in ipairs(self.Mgr.kingGuildData.phasedata[1]) do
                local has = false
                for i,v2 in ipairs(self.Mgr.kingGuildData.phasedata[2]) do
                    if v1.index == v2.index then
                        has = true
                    end
                end
                self.failed[v1.index] = not has
            end
            for i,v in ipairs(self.Mgr.kingGuildData.phasedata[2]) do
                local index = math.ceil(v.index/4)
                local go = self.Result:Find("G2/2"..tostring(index))
                go:Find("MainButton"):GetComponent(Button).enabled = false
                if go:Find("Label"):GetComponent(Text).text == v.name then

                else

                end
                if v.index < 9 then
                    local strindex = "2"..tostring(math.ceil(v.index/2))
                    local parent = self.LeftLine
                    local strdata = self.LineGroup[strindex]
                    for k,v in pairs(strdata) do
                        parent:Find(v):GetComponent(Image).sprite = light
                    end
                else
                    local strindex = "2"..tostring(math.ceil(v.index/2))
                    local parent = self.RightLine
                    local strdata = self.LineGroup[strindex]
                    for k,v in pairs(strdata) do
                        parent:Find(v):GetComponent(Image).sprite = light
                    end
                end
            end
        end
        if self.Mgr.kingGuildData ~= nil and self.Mgr.kingGuildData.phasedata[2] ~= nil and next(self.Mgr.kingGuildData.phasedata[2]) ~= nil then
            for i=1,4 do
                self.Result:Find("G2/2"..tostring(i)):Find("Label"):GetComponent(Text).text = self.Mgr.kingGuildData.phasedata[2][i].name
            end
        end
        if self.Mgr.kingGuildData ~= nil and self.Mgr.kingGuildData.phasedata[3] ~= nil and next(self.Mgr.kingGuildData.phasedata[3]) ~= nil then
            for i,v1 in ipairs(self.Mgr.kingGuildData.phasedata[2]) do
                local has = false
                for i,v2 in ipairs(self.Mgr.kingGuildData.phasedata[3]) do
                    if v1.index == v2.index then
                        has = true
                    end
                end
                self.failed[v1.index] = not has
            end
            for i=1,2 do
                self.Result:Find("G3/3"..tostring(i)):Find("Label"):GetComponent(Text).text = self.Mgr.kingGuildData.phasedata[3][i].name
            end
        end
        if self.Mgr.kingGuildData ~= nil and self.Mgr.kingGuildData.phasedata[4] ~= nil and next(self.Mgr.kingGuildData.phasedata[4]) ~= nil then
            for i,v1 in ipairs(self.Mgr.kingGuildData.phasedata[3]) do
                local has = false
                for i,v2 in ipairs(self.Mgr.kingGuildData.phasedata[4]) do
                    if v1.index == v2.index then
                        has = true
                    end
                end
                self.failed[v1.index] = not has
            end
            for k,v in pairs(self.Mgr.kingGuildData.phasedata[4]) do
                if v.is_win ~= 0 then
                    if v.season_consecutive_win >= 4 then
                        self.Result:Find("G4/1"):Find("Label"):GetComponent(Text).text = v.name
                    elseif v.season_consecutive_win >= 3 then
                        self.Result:Find("G4/2"):Find("Label"):GetComponent(Text).text = v.name
                    elseif v.season_consecutive_win == 2 and v.is_win == 1 then
                        self.Result:Find("G4/3"):Find("Label"):GetComponent(Text).text = v.name
                        if v.index > 8 then
                            self.transform:Find("Main/Con/KingPanel/Map/R41"):GetComponent(Image).sprite = light
                            self.transform:Find("Main/Con/KingPanel/Map/M4"):GetComponent(Image).sprite = light
                        else
                            self.transform:Find("Main/Con/KingPanel/Map/L41"):GetComponent(Image).sprite = light
                            self.transform:Find("Main/Con/KingPanel/Map/M4"):GetComponent(Image).sprite = light
                        end
                    end
                end
            end
        end
        self:InitDropButton()
    end

    -- BaseUtils.dump(self.Mgr.kingGuildData, "ashdusdsdsads")
    for i=2, 4 do
        local resultdata = self.Mgr.kingGuildData[i]
        if resultdata == nil then
            resultdata = {}
        end

        for _, guildindex in pairs(resultdata) do
            local pow = math.pow(2, i-1)
            local subindex = math.ceil(guildindex/pow)
            local line = string.format("%s%s", tostring(i), tostring(subindex))
            local linedata = self.LineGroup[line]
            local Lineimg = nil
            if guildindex < 9 then
                for _, str in ipairs(linedata) do
                    self.LeftLine:Find(str):GetComponent(Image).sprite = light
                end
                -- Lineimg = self.LLine:Find(line):GetComponent(Image)

            else
                -- Lineimg = self.RLine:Find(line):GetComponent(Image)
                for _, str in ipairs(linedata) do
                    self.RightLine:Find(str):GetComponent(Image).sprite = light
                end
            end
        end
        if i == 4 and resultdata[1] ~= nil then
            for k,v in pairs(self.Mgr.kingGuildData.phasedata[i]) do
                if v.season_consecutive_win == 4 then

                   if v.index > 8 then

                   else

                   end
                elseif v.season_consecutive_win >= 3 then
                    -- if v.index > 8 then
                    --     self.transform:Find("Main/Con/KingPanel/Map/R41"):GetComponent(Image).sprite = light
                    --     self.transform:Find("Main/Con/KingPanel/Map/M4"):GetComponent(Image).sprite = light
                    -- else
                    --     self.transform:Find("Main/Con/KingPanel/Map/L41"):GetComponent(Image).sprite = light
                    --     self.transform:Find("Main/Con/KingPanel/Map/M4"):GetComponent(Image).sprite = light
                    -- end
                elseif v.season_consecutive_win == 2 and v.is_win == 1 then
                    -- self.transform:Find("KingPanel/Map/3/Text"):GetComponent(Text).text = v.name
                    -- self.transform:Find("KingPanel/Map/3"):GetComponent(Button).onClick:RemoveAllListeners()
                    -- self.transform:Find("KingPanel/Map/3"):GetComponent(Button).onClick:AddListener(function()
                    --     self:LookGuild(v)
                    -- end)
                end
            end
        end
    end
end

function GuildLeagueGuessWindow:InitDropButton()
    if self.Mgr.kingGuildData == nil or self.Mgr.guessData == nil then
        return
    end
	self.GuessBtn2 = {}
	self.GuessBtn3 = {}
	self.GuessBtn4 = {}
    --第一轮
    self.canguess = false
    self:InitRound1()
    self:InitRound2()
    self:InitRound3()
    if self.canguess then
        self.transform:Find("Main/Con/KingPanel/Button/Text"):GetComponent(Text).text = TI18N("参与竞猜")
        self.transform:Find("Main/Con/KingPanel/Button/Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
        self.transform:Find("Main/Con/KingPanel/Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    else
        self.guessSelect = {}
        self.transform:Find("Main/Con/KingPanel/Button/Text"):GetComponent(Text).text = TI18N("已竞猜")
        if self.Mgr.currstatus ~= 0 then
            self.transform:Find("Main/Con/KingPanel/Button/Text"):GetComponent(Text).text = TI18N("竞猜关闭")
        end
        self.transform:Find("Main/Con/KingPanel/Button/Text"):GetComponent(Text).color = ColorHelper.DefaultButton4
        self.transform:Find("Main/Con/KingPanel/Button"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    end
end

function GuildLeagueGuessWindow:OnGuess(round, group, index, data)
	print(string.format("轮：%s 组：%s 索引：%s", round, group, index))
    self.selectround = round
    if round == 4 and group == 1 then
        local secondindex
        if index == 2 then
            secondindex = 1
        elseif index == 1 then
            secondindex = 2
        end
        self.Result:Find("G4/2"):Find("Label"):GetComponent(Text).text = data[secondindex].name
    end
    local key = string.format("%s_%s", round, group)
    self.guessSelect[key] = {guild_id = data[index].guild_id, platform = data[index].platform, zone_id = data[index].zone_id}
    local num = 0
    for k,v in pairs(self.guessSelect) do
        num = num + 1
    end
    if self.roundNum[round] == num and self.Button.transform:Find("Effect") == nil then
        local effectgo = GameObject.Instantiate(self.NoticeEffect)
        effectgo.transform:SetParent(self.Button.transform)
        effectgo.name = "Effect"
        effectgo.transform.localScale = Vector3(1.85, 0.68, 1)
        effectgo.transform.localPosition = Vector3(-57, -16, -380)
        Utils.ChangeLayersRecursively(effectgo.transform, "UI")
        effectgo:SetActive(true)
    elseif self.Button.transform:Find("Effect") ~= nil then
        GameObject.DestroyImmediate(self.Button.transform:Find("Effect").gameObject)

    end
end

function GuildLeagueGuessWindow:LookGuild(data, index)
    print("观看公会数据："..data.name)
    if self.failed[index] == true then
        NoticeManager.Instance:FloatTipsByString(TI18N("该公会已战败，无法查看"))
        return
    end
    self.Mgr:Require17624(data.guild_id, data.platform, data.zone_id, self.Mgr.guild_LeagueInfo.season_id)
end


function GuildLeagueGuessWindow:LoadGuessData()
    if self.Mgr.guessData ~= nil then

    end
end

function GuildLeagueGuessWindow:DoGuess()
    if self.Mgr.currstatus ~= 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动已经开始，无法参与本轮竞猜"))
        return
    end
    if self.canguess == false then
        NoticeManager.Instance:FloatTipsByString(TI18N("已经完成本轮冠军联赛竞猜"))
        return
    end
    if self.guessSelect == nil or next(self.guessSelect) == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请先选择你认为会获胜的公会"))
        return
    end
    local temp = {}
    for k,v in pairs(self.guessSelect) do
        table.insert(temp, v)
    end
    if self.roundNum[self.selectround] ~= #temp then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前还有<color='#ffff00'>未选择</color>公会的竞猜场次，请全部选择后参与竞猜"))
        return
    end
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("参与竞猜将消耗<color='#00ff00'>1张竞猜券</color>，确定参与后<color='#ffff00'>无法修改</color>已选择的公会，确定要<color='#00ff00'>参与竞猜</color>吗？")
    data.sureLabel = TI18N("参与")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function()
        self.Mgr:Require17626(temp)
        if self.Button.transform:Find("Effect") ~= nil then
            GameObject.DestroyImmediate(self.Button.transform:Find("Effect").gameObject)
        end
    end
    NoticeManager.Instance:ConfirmTips(data)
end

function GuildLeagueGuessWindow:InitSlot()
    if self.slot == nil then
        local parent = self.transform:Find("Main/Con/KingPanel/Need/Slot").gameObject
        local slot = ItemSlot.New()
        local info = ItemData.New()
        local base = DataItem.data_get[21704]
        info:SetBase(base)
        local extra = {inbag = false, nobutton = true}
        slot:SetAll(info, extra)
        self.slot = slot
        UIUtils.AddUIChild(parent,slot.gameObject)
        itemicon = slot.gameObject
    end
    local has = BackpackManager.Instance:GetItemCount(21704)
    local NeedText = self.transform:Find("Main/Con/KingPanel/Need/needtext"):GetComponent(Text)
    if has < 1 then
        NeedText.text = string.format("<color='#ff0000'>%s</color>/1", has)
    else
        NeedText.text = string.format("<color='#00ff00'>%s</color>/1", has)
    end
    NeedText.gameObject:SetActive(true)

end

function GuildLeagueGuessWindow:ShowReward()
    -- local temp = {}
    -- for k,v in pairs(DataGuildLeague.data_guess_reward) do
    --     for kk,vv in pairs(v.items) do
    --         temp[vv[1]] = vv[2]
    --     end
    -- end
    -- local reward = {}
    -- for k,v in pairs(temp) do
    --     table.insert(reward, {base_id = k,num = v})
    -- end
    -- -- local rewardlist = {list = {title = TI18N("参与将有机会获得"), items = temp}}
    -- local rewardlist = {list = {{title = TI18N("参与将有机会获得"), items = reward}}}
    -- self.GiftPreview:Show(rewardlist)
    -- if self.GiftPreview.transform ~= nil then
    --     self.GiftPreview.transform.localPosition = Vector3(0, 0, -800)
    -- end
    TipsManager.Instance:ShowText({gameObject = self.transform:Find("Main/Con/KingPanel/rewardButton").gameObject, itemData = {
            TI18N("1.奖励将根据对战双方公会竞猜<color='#ffff00'>支持率</color>发放"),
            TI18N("2.支持率<color='#ffff00'>越低</color>的公会获胜，猜对的玩家奖励<color='#ffff00'>越丰厚</color>"),
            TI18N("3.一轮比赛猜对胜利公会<color='#ffff00'>越多</color>，奖励<color='#ffff00'>越丰厚</color>"),
            TI18N("4.猜对玩家将获得<color='#00ff00'>银币</color>奖励，奖励将在当轮活动结束后<color='#ffff00'>邮件</color>发放"),

            }})
end

function GuildLeagueGuessWindow:InitRound1()
    if self.Mgr.kingGuildData.phasedata[1] ~= nil and #self.Mgr.kingGuildData.phasedata[1] ~= 0 then
        for i=1, 4 do
            local go = self.Result:Find("G2/2"..tostring(i)).gameObject
            table.insert(self.GuessBtn2, go)
            table.sort(self.Mgr.kingGuildData.phasedata[1], function(a,b) return a.index < b.index end)
            local guild1 = self.Mgr.kingGuildData.phasedata[1][(i-1)*2+1]
            local guild2 = self.Mgr.kingGuildData.phasedata[1][(i-1)*2+2]
            local data = {guild1, guild2}
            local selected = false
            if self.Mgr.guessData ~= nil and self.Mgr.guessData[5] ~= nil and next(self.Mgr.guessData[5]) ~= nil and (self.Mgr.kingGuildData.phasedata[2] == nil or next(self.Mgr.kingGuildData.phasedata[2]) == nil) then
                for k,v in pairs(self.Mgr.guessData[5]) do
                    if v.guild_id == guild1.guild_id and v.zone_id == guild1.zone_id and v.zone_id == guild1.zone_id then
                        selected = true
                        go.transform:Find("Label"):GetComponent(Text).text = guild1.name
                        go.transform:Find("red").gameObject:SetActive(false)
                        break
                    elseif v.guild_id == guild2.guild_id and v.zone_id == guild2.zone_id and v.zone_id == guild2.zone_id then
                        selected = true
                        go.transform:Find("Label"):GetComponent(Text).text = guild2.name
                        go.transform:Find("red").gameObject:SetActive(false)
                        break
                    end
                end
            elseif self.Mgr.kingGuildData.phasedata[2] ~= nil and next(self.Mgr.kingGuildData.phasedata[2]) ~= nil then
                go.transform:Find("Label"):GetComponent(Text).text = self.Mgr.kingGuildData.phasedata[2][i].name
                if self.Mgr.guessData[5] ~= nil then
                    for k,v in pairs(self.Mgr.guessData[5]) do
                        if v.guild_id == guild1.guild_id and v.zone_id == guild1.zone_id and v.zone_id == guild1.zone_id then
                            if v.bingo == 1 then
                                self.memberList[math.ceil(guild1.index/2)].trans:Find("icon"):GetComponent(Image).sprite = self.yessprite
                            elseif v.bingo == 2 then
                                self.memberList[math.ceil(guild1.index/2)].trans:Find("icon"):GetComponent(Image).sprite = self.nosprite
                            end
                            self.memberList[math.ceil(guild1.index/2)].trans:Find("icon").gameObject:SetActive(true)
                            break
                        elseif v.guild_id == guild2.guild_id and v.zone_id == guild2.zone_id and v.zone_id == guild2.zone_id then
                            if v.bingo == 1 then
                                self.memberList[math.ceil(guild2.index/2)].trans:Find("icon"):GetComponent(Image).sprite = self.yessprite
                            elseif v.bingo == 2 then
                                self.memberList[math.ceil(guild2.index/2)].trans:Find("icon"):GetComponent(Image).sprite = self.nosprite
                            end
                            self.memberList[math.ceil(guild2.index/2)].trans:Find("icon").gameObject:SetActive(true)
                            break
                        end
                    end
                end
            end
            -- local dropbtn = DropDownButton.New(go, function(index) self:OnGuess(2, i, index, data) end, {autoselect = false, tab = {guild1.name, guild2.name}})
            if self.Mgr.guessData ~= nil and self.Mgr.guessData[5] ~= nil and next(self.Mgr.guessData[5]) ~= nil or (self.Mgr.kingGuildData.phasedata[2] ~= nil and #self.Mgr.kingGuildData.phasedata[2] ~= 0 and self.Mgr.kingGuildData.phasedata[2][1].is_win ~= 0) then
                go.transform:Find("MainButton"):GetComponent(Button).enabled = false
                go.transform:Find("red").gameObject:SetActive(false)
            else
                self.canguess = true and self.Mgr.currstatus == 0
                if not selected and self.Mgr.currstatus ~= 0 then
                    go.transform:Find("Label"):GetComponent(Text).text = TI18N("已结束竞猜")
                end
                if not selected and self.Mgr.currstatus == nil then
                    go.transform:Find("Label"):GetComponent(Text).text = TI18N("未开始")
                end
                -- dropbtn:Init()
                go.transform:Find("MainButton"):GetComponent(Button).onClick:RemoveAllListeners()
                go.transform:Find("MainButton"):GetComponent(Button).onClick:AddListener(function()
                    self:OpenSelectPanel(guild1, guild2, go.transform:Find("Label"):GetComponent(Text), {2, i})
                end)
                go.transform:Find("MainButton"):GetComponent(Button).enabled = true and self.Mgr.currstatus == 0
                go.transform:Find("red").gameObject:SetActive(true and self.Mgr.currstatus == 0)
            end

        end
    end
end

function GuildLeagueGuessWindow:InitRound2()
    -- 第二轮
    if self.Mgr.kingGuildData.phasedata[2] ~= nil and #self.Mgr.kingGuildData.phasedata[2] ~= 0 then
        for i=1, 2 do
            local go = self.Result:Find("G3/3"..tostring(i)).gameObject
            table.insert(self.GuessBtn3, go)
            table.sort(self.Mgr.kingGuildData.phasedata[2], function(a,b) return a.index < b.index end)
            local guild1 = self.Mgr.kingGuildData.phasedata[2][(i-1)*2+1]
            local guild2 = self.Mgr.kingGuildData.phasedata[2][(i-1)*2+2]
            local data = {guild1, guild2}
            local selected = false
            if self.Mgr.guessData ~= nil and self.Mgr.guessData[6] ~= nil and (self.Mgr.kingGuildData.phasedata[3] == nil or next(self.Mgr.kingGuildData.phasedata[3]) == nil)  then
                for k,v in pairs(self.Mgr.guessData[6]) do
                    if v.guild_id == guild1.guild_id and v.zone_id == guild1.zone_id and v.zone_id == guild1.zone_id then
                        selected = true
                        go.transform:Find("Label"):GetComponent(Text).text = guild1.name
                        go.transform:Find("red").gameObject:SetActive(false)
                        break
                    elseif v.guild_id == guild2.guild_id and v.zone_id == guild2.zone_id and v.zone_id == guild2.zone_id then
                        selected = true
                        go.transform:Find("Label"):GetComponent(Text).text = guild2.name
                        go.transform:Find("red").gameObject:SetActive(false)
                        break
                    end
                end
            elseif self.Mgr.kingGuildData.phasedata[3] ~= nil and next(self.Mgr.kingGuildData.phasedata[3]) ~= nil and self.Mgr.kingGuildData.phasedata[3][1].is_win ~= 0 then
                go.transform:Find("Label"):GetComponent(Text).text = self.Mgr.kingGuildData.phasedata[3][i].name
                self:OnCurrRound(2)
                if self.Mgr.guessData[6] ~= nil then
                    for k,v in pairs(self.Mgr.guessData[6]) do
                        if v.guild_id == guild1.guild_id and v.zone_id == guild1.zone_id and v.zone_id == guild1.zone_id then
                            if v.bingo == 1 then
                                self.GuessBtn2[math.ceil(guild1.index/4)].transform:Find("ArrowBtn"):GetComponent(Image).sprite = self.yessprite
                            elseif v.bingo == 2 then
                                self.GuessBtn2[math.ceil(guild1.index/4)].transform:Find("ArrowBtn"):GetComponent(Image).sprite = self.nosprite
                            end
                            self.GuessBtn2[math.ceil(guild1.index/4)].transform:Find("ArrowBtn").gameObject:SetActive(true)
                            break
                        elseif v.guild_id == guild2.guild_id and v.zone_id == guild2.zone_id and v.zone_id == guild2.zone_id then
                            if v.bingo == 1 then
                                self.GuessBtn2[math.ceil(guild2.index/4)].transform:Find("ArrowBtn"):GetComponent(Image).sprite = self.yessprite
                            elseif v.bingo == 2 then
                                self.GuessBtn2[math.ceil(guild2.index/4)].transform:Find("ArrowBtn"):GetComponent(Image).sprite = self.nosprite
                            end
                            self.GuessBtn2[math.ceil(guild2.index/4)].transform:Find("ArrowBtn").gameObject:SetActive(true)
                            break
                        end
                    end
                end
            end
            if self.Mgr.guessData ~= nil and self.Mgr.guessData[6] ~= nil and next(self.Mgr.guessData[6]) ~= nil or (self.Mgr.kingGuildData.phasedata[3] ~= nil and #self.Mgr.kingGuildData.phasedata[3] ~= 0 and self.Mgr.kingGuildData.phasedata[3][1].is_win ~= 0) then
                    go.transform:Find("MainButton"):GetComponent(Button).enabled = false
                go.transform:Find("red").gameObject:SetActive(false)
            elseif guild1 ~= nil and guild2 ~= nil then
                if not selected and self.Mgr.currstatus ~= 0 then
                    go.transform:Find("Label"):GetComponent(Text).text = TI18N("已结束竞猜")
                end
                if not selected and self.Mgr.currstatus == nil then
                    go.transform:Find("Label"):GetComponent(Text).text = TI18N("未开始")
                end
                -- local dropbtn = DropDownButton.New(go, function(index) self:OnGuess(3, i, index, data) end, {autoselect = false, tab = {guild1.name, guild2.name}})
                -- dropbtn:Init()
                go.transform:Find("MainButton"):GetComponent(Button).onClick:RemoveAllListeners()
                go.transform:Find("MainButton"):GetComponent(Button).onClick:AddListener(function()
                    self:OpenSelectPanel(guild1, guild2, go.transform:Find("Label"):GetComponent(Text), {3, i})
                end)
                go.transform:Find("MainButton"):GetComponent(Button).enabled = true and self.Mgr.currstatus == 0
                self.canguess = true and self.Mgr.currstatus == 0
                go.transform:Find("red").gameObject:SetActive(true and self.Mgr.currstatus == 0)
            else
                go.transform:Find("MainButton"):GetComponent(Button).enabled = false
                go.transform:Find("Label"):GetComponent(Text).text = TI18N("未开始")
            end
        end
    else
        for i=1, 2 do
            local go = self.Result:Find("G3/3"..tostring(i)).gameObject
            go.transform:Find("MainButton"):GetComponent(Button).enabled = false
            go.transform:Find("Label"):GetComponent(Text).text = TI18N("未开始")
        end
    end
end

function GuildLeagueGuessWindow:InitRound3()
    --第三轮
    if self.Mgr.kingGuildData.phasedata[3] ~= nil and #self.Mgr.kingGuildData.phasedata[3] ~= 0 then
        local go = self.Result:Find("G4/1").gameObject
        table.sort(self.Mgr.kingGuildData.phasedata[3], function(a,b) return a.index < b.index end)
        local guild1 = self.Mgr.kingGuildData.phasedata[3][1]
        local guild2 = self.Mgr.kingGuildData.phasedata[3][2]
        local data = {guild1, guild2}
        local selected = false
        local isend = false
        local secondindex
        if self.Mgr.guessData ~= nil and self.Mgr.guessData[7] ~= nil and not (self.Mgr.kingGuildData.phasedata[4] ~= nil and next(self.Mgr.kingGuildData.phasedata[4]) ~= nil and self.Mgr.kingGuildData.phasedata[4][1].is_win ~= 0) then
            for k,v in pairs(self.Mgr.guessData[7]) do
                if v.guild_id == guild1.guild_id and v.zone_id == guild1.zone_id and v.zone_id == guild1.zone_id then
                    selected = true
                    secondindex = 2
                    go.transform:Find("Label"):GetComponent(Text).text = guild1.name
                    go.transform:Find("red").gameObject:SetActive(false)

                    break
                elseif v.guild_id == guild2.guild_id and v.zone_id == guild2.zone_id and v.zone_id == guild2.zone_id then
                    selected = true
                    secondindex = 1
                    go.transform:Find("Label"):GetComponent(Text).text = guild2.name
                    go.transform:Find("red").gameObject:SetActive(false)

                    break
                end
            end
        elseif self.Mgr.kingGuildData.phasedata[4] ~= nil and next(self.Mgr.kingGuildData.phasedata[4]) ~= nil and self.Mgr.kingGuildData.phasedata[4][1].is_win ~= 0 then
            -- go.transform:Find("Label"):GetComponent(Text).text = self.Mgr.kingGuildData.phasedata[4][1].name
            selected = true
            self:OnCurrRound(3)
            if self.Mgr.guessData[7] ~= nil then
                for k,v in pairs(self.Mgr.guessData[7]) do
                    if v.guild_id == guild1.guild_id and v.zone_id == guild1.zone_id and v.zone_id == guild1.zone_id then
                        if v.bingo == 1 then
                            self.GuessBtn3[math.ceil(guild1.index/8)].transform:Find("ArrowBtn"):GetComponent(Image).sprite = self.yessprite
                        elseif v.bingo == 2 then
                            self.GuessBtn3[math.ceil(guild1.index/8)].transform:Find("ArrowBtn"):GetComponent(Image).sprite = self.nosprite
                        end
                        isend = v.bingo == 1 or v.bingo == 2
                        self.GuessBtn3[math.ceil(guild1.index/8)].transform:Find("ArrowBtn").gameObject:SetActive(true)
                        break
                    elseif v.guild_id == guild2.guild_id and v.zone_id == guild2.zone_id and v.zone_id == guild2.zone_id then
                        if v.bingo == 1 then
                            self.GuessBtn3[math.ceil(guild2.index/8)].transform:Find("ArrowBtn"):GetComponent(Image).sprite = self.yessprite
                        elseif v.bingo == 2 then
                            self.GuessBtn3[math.ceil(guild2.index/8)].transform:Find("ArrowBtn"):GetComponent(Image).sprite = self.nosprite
                        end
                        isend = v.bingo == 1 or v.bingo == 2
                        self.GuessBtn3[math.ceil(guild2.index/8)].transform:Find("ArrowBtn").gameObject:SetActive(true)
                        break
                    end
                end
            end
        end
        -- self.GuessBtn4[1] = DropDownButton.New(go, function(index) self:OnGuess(4, 1, index, data) end, {autoselect = false, tab = {guild1.name, guild2.name}})
        -- self.GuessBtn4[1]:Init()
        go.transform:Find("MainButton"):GetComponent(Button).onClick:RemoveAllListeners()
        go.transform:Find("MainButton"):GetComponent(Button).onClick:AddListener(function()
            self:OpenSelectPanel(guild1, guild2, go.transform:Find("Label"):GetComponent(Text), {4, 1})
        end)
        if selected then
            if not isend and secondindex ~= nil then
                self.Result:Find("G4/2"):Find("Label"):GetComponent(Text).text = data[secondindex].name
            end
            self.Result:Find("G4/1"):Find("MainButton"):GetComponent(Button).enabled = false
            self.Result:Find("G4/2"):Find("MainButton"):GetComponent(Button).enabled = false
            self.Result:Find("G4/3"):Find("MainButton"):GetComponent(Button).enabled = false
            go.transform:Find("red").gameObject:SetActive(false)
            self.Result:Find("G4/3").transform:Find("red").gameObject:SetActive(false)
        else
            go.transform:Find("MainButton"):GetComponent(Button).enabled = true and self.Mgr.currstatus == 0
            go.transform:Find("red").gameObject:SetActive(true and self.Mgr.currstatus == 0)
            self.Result:Find("G4/3").transform:Find("MainButton"):GetComponent(Button).enabled = true and self.Mgr.currstatus == 0
            self.Result:Find("G4/3").transform:Find("red").gameObject:SetActive(true and self.Mgr.currstatus == 0)
            self.canguess = true and self.Mgr.currstatus == 0
            if not selected and self.Mgr.currstatus ~= 0 then
                go.transform:Find("Label"):GetComponent(Text).text = TI18N("已结束竞猜")
                self.Result:Find("G4/2"):Find("Label"):GetComponent(Text).text = TI18N("已结束竞猜")
                self.Result:Find("G4/3"):Find("Label"):GetComponent(Text).text = TI18N("已结束竞猜")
            end
            if not selected and self.Mgr.currstatus == nil then
                go.transform:Find("Label"):GetComponent(Text).text = TI18N("未开始")
                self.Result:Find("G4/2"):Find("Label"):GetComponent(Text).text = TI18N("未开始")
                self.Result:Find("G4/3"):Find("Label"):GetComponent(Text).text = TI18N("未开始")
            end
        end
        if (self.Mgr.guessData ~= nil and self.Mgr.guessData[7] ~= nil and next(self.Mgr.guessData[7]) ~= nil) or (self.Mgr.kingGuildData.phasedata[4] ~= nil and #self.Mgr.kingGuildData.phasedata[4] ~= 0 and self.Mgr.kingGuildData.phasedata[4][1].is_win ~= 0) then
        end

        local temp = {}
        for k,v in pairs(self.Mgr.kingGuildData.phasedata[2]) do
            if v.index ~= guild1.index and v.index ~= guild2.index then
                table.insert(temp, v)
            end
        end
        table.sort(temp, function(a,b) return a.index < b.index end)
        local Fguild1 = temp[1]
        local Fguild2 = temp[2]
        local Fdata = temp
        local go = self.Result:Find("G4/3").gameObject
        selected = false
        if self.Mgr.guessData ~= nil and self.Mgr.guessData[7] ~= nil and not (self.Mgr.kingGuildData.phasedata[4] ~= nil and next(self.Mgr.kingGuildData.phasedata[4]) ~= nil and self.Mgr.kingGuildData.phasedata[4][1].is_win ~= 0) then
            for k,v in pairs(self.Mgr.guessData[7]) do
                if v.guild_id == Fguild1.guild_id and v.zone_id == Fguild1.zone_id and v.zone_id == Fguild1.zone_id then
                    selected = true
                    go.transform:Find("Label"):GetComponent(Text).text = Fguild1.name
                    -- if v.bingo == 1 then

                    -- elseif v.bingo == 2 then
                    --     go.transform:Find("ArrowBtn").gameObject:SetActive(true)
                    --     go.transform:Find("ArrowBtn"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ExamWrongIcon")
                    -- end
                    break
                elseif v.guild_id == Fguild2.guild_id and v.zone_id == Fguild2.zone_id and v.zone_id == Fguild2.zone_id then
                    selected = true
                    go.transform:Find("Label"):GetComponent(Text).text = Fguild2.name
                    -- if v.bingo == 1 then
                    --     go.transform:Find("ArrowBtn").gameObject:SetActive(true)
                    --     go.transform:Find("ArrowBtn"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ExamRightIcon")
                    -- elseif v.bingo == 2 then
                    --     go.transform:Find("ArrowBtn").gameObject:SetActive(true)
                    --     go.transform:Find("ArrowBtn"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ExamWrongIcon")
                    -- end
                    break
                end
            end
        end
        -- self.GuessBtn4[3] = DropDownButton.New(go, function(index) self:OnGuess(3, 3, index, Fdata) end, {autoselect = false, tab = {Fguild1.name, Fguild2.name}})
        -- self.GuessBtn4[3]:Init()
        go.transform:Find("MainButton"):GetComponent(Button).onClick:RemoveAllListeners()
        go.transform:Find("MainButton"):GetComponent(Button).onClick:AddListener(function()
            self:OpenSelectPanel(Fguild1, Fguild2, go.transform:Find("Label"):GetComponent(Text), {3, 3})
        end)
        if self.Mgr.guessData ~= nil and self.Mgr.guessData[7] ~= nil and next(self.Mgr.guessData[7]) ~= nil or (self.Mgr.kingGuildData.phasedata[4] ~= nil and #self.Mgr.kingGuildData.phasedata[4] ~= 0 and self.Mgr.kingGuildData.phasedata[4][1].is_win ~= 0) then
            if not selected and self.Mgr.currstatus ~= 0 then
                go.transform:Find("Label"):GetComponent(Text).text = TI18N("已结束竞猜")
                self.Result:Find("G4/2"):Find("Label"):GetComponent(Text).text = TI18N("已结束竞猜")
                self.Result:Find("G4/3"):Find("Label"):GetComponent(Text).text = TI18N("已结束竞猜")
            end
            if not selected and self.Mgr.currstatus == nil then
                go.transform:Find("Label"):GetComponent(Text).text = TI18N("未开始")
                self.Result:Find("G4/2"):Find("Label"):GetComponent(Text).text = TI18N("未开始")
                self.Result:Find("G4/3"):Find("Label"):GetComponent(Text).text = TI18N("未开始")
            end
        end
        self.transform:Find("Main/Con/KingPanel/Map/3/Text"):GetComponent(Text).text = Fguild1.name
        self.transform:Find("Main/Con/KingPanel/Map/3"):GetComponent(Button).onClick:AddListener(function()
            self:LookGuild(Fguild1, Fguild1.index)
        end)
        self.transform:Find("Main/Con/KingPanel/Map/4/Text"):GetComponent(Text).text = Fguild2.name
        self.transform:Find("Main/Con/KingPanel/Map/4"):GetComponent(Button).onClick:AddListener(function()
            self:LookGuild(Fguild2, Fguild2.index)
        end)

    else
        for i=1,3 do
            local go = self.Result:Find("G4/"..tostring(i)).gameObject
            go.transform:Find("MainButton"):GetComponent(Button).enabled = false
            go.transform:Find("Label"):GetComponent(Text).text = TI18N("未开始")
        end
    end
end

function GuildLeagueGuessWindow:OpenSelectPanel(data1, data2, Label, ext)
    local data = {data1, data2}
    local Lrate = self.Mgr:GetRate(data1.guild_id, data1.platform, data1.zone_id)
    local Rrate = self.Mgr:GetRate(data2.guild_id, data2.platform, data2.zone_id)
    local Lval = Lrate/(Lrate+Rrate)
    local Rval = Rrate/(Lrate+Rrate)
    local odds1 = 0
    local odds2 = 0
    if Lrate > 100 or Rrate > 100 then
        self.LrateText.text = tostring(Mathf.Round(Lval*100)).."%"
        self.RrateText.text = tostring(Mathf.Round(Rval*100)).."%"
        self.Lbar.sizeDelta = Vector2(401.5*Lval, 21)
        self.Rbar.sizeDelta = Vector2(401.5*Rval, 21)
        odds1 = Mathf.Round(Rval*100)/50
        odds2 = Mathf.Round(Lval*100)/50
    else
        self.LrateText.text = "50%"
        self.RrateText.text = "50%"
        self.Lbar.sizeDelta = Vector2(401.5*0.5, 21)
        self.Rbar.sizeDelta = Vector2(401.5*0.5, 21)
        odds1 = 1
        odds2 = 1
    end
    odds1 = odds1 > 1.7 and 1.7 or odds1
    odds2 = odds2 > 1.7 and 1.7 or odds2
    odds1 = odds1 < 0.3 and 0.3 or odds1
    odds2 = odds2 < 0.3 and 0.3 or odds2
    odds1 = (odds1*100)%10 > 0 and odds1 or string.format("%s%s", odds1, 0)
    odds2 = (odds2*100)%10 > 0 and odds2 or string.format("%s%s", odds2, 0)
    self.OddsTxt.text = string.format(TI18N("赔率：<color='#23f0f7'>%s</color>    支持率     赔率：<color='#23f0f7'>%s</color>"), odds1, odds2)
    self.LineEffect.transform.localPosition = Vector3(self.Lbar.sizeDelta.x, 0, -300)
    local Lselect = self.LButton.transform:Find("select").gameObject
    local Rselect = self.RButton.transform:Find("select").gameObject
    local currselectindex = nil
    local changed = false
    Lselect:SetActive(false)
    Rselect:SetActive(false)
    self.LButton.onClick:RemoveAllListeners()
    self.LButton.onClick:AddListener(function()
        Lselect:SetActive(true)
        Rselect:SetActive(false)
        if currselectindex ~= 1 then
            changed = true
        end
        currselectindex = 1
        -- self:OnGuess(ext[1], ext[2], 1, data)
    end)
    self.LButton.transform:Find("Text"):GetComponent(Text).text = data1.name
    self.LButton.transform:Find("icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(data1.totem))

    self.RButton.onClick:RemoveAllListeners()
    self.RButton.onClick:AddListener(function()
        Rselect:SetActive(true)
        Lselect:SetActive(false)
        if currselectindex ~= 2 then
            changed = true
        end
        currselectindex = 2
    end)
    if Label.text == data1.name then
        Lselect:SetActive(true)
        currselectindex = 1
    elseif Label.text == data2.name then
        Rselect:SetActive(true)
        currselectindex = 2
    end
    self.RButton.transform:Find("Text"):GetComponent(Text).text = data2.name
    self.RButton.transform:Find("icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(data2.totem))

    self.selectButton.onClick:RemoveAllListeners()
    self.selectButton.onClick:AddListener(function()
        if changed and currselectindex ~= nil then
            self:OnGuess(ext[1], ext[2], currselectindex, data)
            Label.text = data[currselectindex].name
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("你已选择<color='#ffff00'>%s</color>公会，全部选择后可以参与竞猜"), data[currselectindex].name))
            Label.transform.parent:Find("red").gameObject:SetActive(false)
        end
        if currselectindex == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("请先选择你支持的公会"))
            return
        end
        self.SelectPanel.gameObject:SetActive(false)
    end)
    self.SelectPanel.gameObject:SetActive(true)
end

function GuildLeagueGuessWindow:CheckClose()
    if next(self.guessSelect) == nil then
        self.model:CloseGuessWindow()
    else
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("您当前选择了公会但没有进行竞猜。确定<color='#ffff00'>不保存</color>竞猜选择直接离开？")
        data.sureLabel = TI18N("离开")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            self.model:CloseGuessWindow()
        end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

function GuildLeagueGuessWindow:OnCurrRound(index)
    if index == 2 then
        for i,v in ipairs(self.memberList) do
            v.trans:Find("icon").gameObject:SetActive(false)
        end
    elseif index == 3 then
        for i,v in ipairs(self.memberList) do
            v.trans:Find("icon").gameObject:SetActive(false)
        end
        for i=1,4 do
            self.Result:Find("G2/2"..tostring(i)):Find("ArrowBtn").gameObject:SetActive(false)
        end
    end
end