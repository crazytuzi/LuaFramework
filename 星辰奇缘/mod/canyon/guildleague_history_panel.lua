--作者:hzf
--16-10-26 下06时08分02秒
--功能:历史战绩

GuildLeagueHistoryPanel = GuildLeagueHistoryPanel or BaseClass(BasePanel)
function GuildLeagueHistoryPanel:__init(model)
	self.model = model
    self.Mgr = GuildLeagueManager.Instance
    self.EffectPath = "prefabs/effect/20221.unity3d"
	self.resList = {
		{file = AssetConfig.guildleague_history_panel, type = AssetType.Main}
        ,{file = self.EffectPath, type = AssetType.Main}
        ,{file = AssetConfig.guildleaguebig, type = AssetType.Dep}
        ,{file = AssetConfig.guild_totem_icon, type = AssetType.Dep}
        ,{file = AssetConfig.guildleague_texture, type = AssetType.Dep}
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
	self.result2Text = {
		[1] = TI18N("败"),
        [2] = TI18N("胜"),
		[3] = TI18N("平"),
	}
	self.ItemList = {}
end

function GuildLeagueHistoryPanel:__delete()
    self.pingsprite = nil
    self.winsprite = nil
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function GuildLeagueHistoryPanel:OnHide()

end

function GuildLeagueHistoryPanel:OnOpen()

end

function GuildLeagueHistoryPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleague_history_panel))
	self.gameObject.name = "GuildLeagueHistoryPanel"

	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
	-- self.transform.localScale = Vector3.one
	self.transform.localPosition = Vector3(0,0,-400)
	self.Panel = self.transform:Find("Panel")
	self.Panel:GetComponent(Button).onClick:AddListener(function()
		self.model:CloseHistoryPanel()
	end)
	self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
		self.model:CloseHistoryPanel()
	end)
    self.transform:Find("Main/OKButton"):GetComponent(Button).onClick:AddListener(function()
        self.model:CloseHistoryPanel()
    end)

    self.pingsprite = self.assetWrapper:GetTextures(AssetConfig.guildleague_texture , "ping")
    self.winsprite = self.assetWrapper:GetTextures(AssetConfig.guildleague_texture , "up")
	self.Main = self.transform:Find("Main")
    self.OddsTxt = self.transform:Find("Main/Top/Text"):GetComponent(Text)
    self.OddsTxt.transform:GetComponent(RectTransform).sizeDelta = Vector2(400, 30)
    self.OddsTxt.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-2, -34.8)
    -- self.OddsTxt.alignment = 3
    self.OddsTxt.text = ""
    self.transform:Find("Main/Top"):GetComponent(Image).sprite = self.assetWrapper:GetTextures(AssetConfig.guildleaguebig , "GuildLeague1")
    self.totem1 = self.transform:Find("Main/Top/totem1"):GetComponent(Image)
    self.totem2 = self.transform:Find("Main/Top/totem2"):GetComponent(Image)
    self.name1 = self.transform:Find("Main/Top/neame1"):GetComponent(Text)
    self.name2 = self.transform:Find("Main/Top/neame2"):GetComponent(Text)

    self.Lbar = self.transform:Find("Main/bar/Lbar")
    self.Rbar = self.transform:Find("Main/bar/Rbar")
    self.LrateText = self.transform:Find("Main/bar/Lbar/rateText"):GetComponent(Text)
    self.RrateText = self.transform:Find("Main/bar/Rbar/rateText"):GetComponent(Text)

    self.LMaskScroll = self.transform:Find("Main/LMaskScroll")
	self.RMaskScroll = self.transform:Find("Main/RMaskScroll")
    self.LList = self.transform:Find("Main/LMaskScroll/List")
	self.RList = self.transform:Find("Main/RMaskScroll/List")
	self.Item = self.transform:Find("Main/Item")

    self.NoticeEffect = GameObject.Instantiate(self:GetPrefab(self.EffectPath))
    self.NoticeEffect.transform:SetParent(self.Lbar)
    self.NoticeEffect.transform.localScale = Vector3.one
    self.NoticeEffect.transform.localPosition = Vector3(0,0, -400)
    Utils.ChangeLayersRecursively(self.NoticeEffect.transform, "UI")
    self.NoticeEffect:SetActive(true)

	self.data = self.openArgs
    self:PraseData()
	self:InitList()
end

function GuildLeagueHistoryPanel:InitList()

    self.LListlayout = LuaBoxLayout.New(self.LList.gameObject, {axis = BoxLayoutAxis.Y, spacing = 0})
    self.RListlayout = LuaBoxLayout.New(self.RList.gameObject, {axis = BoxLayoutAxis.Y, spacing = 0})
    for i,v in ipairs(self.Ldata) do
        local item = GameObject.Instantiate(self.Item)
        item.transform:Find("name1"):GetComponent(Text).text = self.Lguild.name
        item.transform:Find("name2"):GetComponent(Text).text = v.names[1].name
        item.transform:Find("result"):GetComponent(Text).text = self.result2Text[v.is_win]
        local bgicon = item.transform:Find("resultbg"):GetComponent(Image)
        bgicon.sprite = self.winsprite
        if v.is_win == 1 then
            BaseUtils.SetGrey(bgicon, true)
        end
        if v.is_win == 3 then
            bgicon.sprite = self.pingsprite
        end
        self.LListlayout:AddCell(item.gameObject)
    end
    for i,v in ipairs(self.Rdata) do
        local item = GameObject.Instantiate(self.Item)
        item.transform:Find("name1"):GetComponent(Text).text = self.Rguild.name
        item.transform:Find("name2"):GetComponent(Text).text = v.names[1].name
        item.transform:Find("result"):GetComponent(Text).text = self.result2Text[v.is_win]
        local bgicon = item.transform:Find("resultbg"):GetComponent(Image)
        bgicon.sprite = self.winsprite
        if v.is_win == 1 then
            BaseUtils.SetGrey(bgicon, true)
        end
        if v.is_win == 3 then
            bgicon.sprite = self.pingsprite
        end
        self.RListlayout:AddCell(item.gameObject)
    end
end

function GuildLeagueHistoryPanel:PraseData()
    self.Ldata = {}
    self.Rdata = {}
    self.Lguild = self.data.gid[1]
    self.Rguild = self.data.gid[2]
    local matchlist = {}
    local Lunknow = true
    local Runknow = true
    for k,v in pairs(self.data.guild_league_alliance) do
        if v.is_win ~= 0 and matchlist[v.match_id] == nil then
            matchlist[v.match_id] = {}
        end
        if Lunknow and v.gids[1].guild_id == self.Lguild.guild_id and v.gids[1].platform == self.Lguild.g_platform and v.gids[1].zone_id == self.Lguild.g_zone_id then
            Lunknow = false
            self.Lguild.totem = v.totems[1].totem
            self.Lguild.name = v.names[1].name
        end
        if Runknow and v.gids[1].guild_id == self.Rguild.guild_id and v.gids[1].platform == self.Rguild.g_platform and v.gids[1].zone_id == self.Rguild.g_zone_id then
            Runknow = false
            self.Rguild.totem = v.totems[1].totem
            self.Rguild.name = v.names[1].name
        end
        if v.is_win ~= 0 then
            table.insert(matchlist[v.match_id], v)
        end
    end
    for k,v in pairs(matchlist) do
        if v[1].gids[1].guild_id == self.Lguild.guild_id and v[1].gids[1].platform == self.Lguild.g_platform and v[1].gids[1].zone_id == self.Lguild.g_zone_id then
            table.insert(self.Ldata, v[2])
        elseif v[1].gids[1].guild_id == self.Rguild.guild_id and v[1].gids[1].platform == self.Rguild.g_platform and v[1].gids[1].zone_id == self.Rguild.g_zone_id then
            table.insert(self.Rdata, v[2])
        elseif v[2].gids[1].guild_id == self.Lguild.guild_id and v[2].gids[1].platform == self.Lguild.g_platform and v[2].gids[1].zone_id == self.Lguild.g_zone_id then
            table.insert(self.Ldata, v[1])
        elseif v[2].gids[1].guild_id == self.Rguild.guild_id and v[2].gids[1].platform == self.Rguild.g_platform and v[2].gids[1].zone_id == self.Rguild.g_zone_id then
            table.insert(self.Rdata, v[1])
        end
    end
    table.sort( self.Ldata, function(a, b) return a.phase > b.phase end)
    table.sort( self.Rdata, function(a, b) return a.phase > b.phase end)
    self:InitTopInfo()
end

function GuildLeagueHistoryPanel:InitTopInfo()
    self.name1.text = string.format("<color='#23f0f7'>%s</color>", self.Lguild.name)
    self.name2.text = string.format("<color='#ff6a3b'>%s</color>", self.Rguild.name)
    self.totem1.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(self.Lguild.totem))
    self.totem2.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(self.Rguild.totem))
    local Lrate = self.Mgr:GetRate(self.Lguild.guild_id, self.Lguild.g_platform, self.Lguild.g_zone_id)
    local Rrate = self.Mgr:GetRate(self.Rguild.guild_id, self.Rguild.g_platform, self.Rguild.g_zone_id)
    local Lval = Lrate/(Lrate+Rrate)
    local Rval = Rrate/(Lrate+Rrate)
    local odds1 = 0
    local odds2 = 0
    if Lrate > 100 or Rrate > 100 then
        self.LrateText.text = tostring(Mathf.Round(Lval*100)).."%"
        self.RrateText.text = tostring(Mathf.Round(Rval*100)).."%"
        self.Lbar.sizeDelta = Vector2(559.5*Lval, 21)
        self.Rbar.sizeDelta = Vector2(559.5*Rval, 21)
        odds1 = Mathf.Round(Rval*100)/50
        odds2 = Mathf.Round(Lval*100)/50
    else
        self.LrateText.text = "50%"
        self.RrateText.text = "50%"
        self.Lbar.sizeDelta = Vector2(559.5*0.5, 21)
        self.Rbar.sizeDelta = Vector2(559.5*0.5, 21)
        odds1 = 1
        odds2 = 1
    end
    odds1 = odds1 > 1.7 and 1.7 or odds1
    odds2 = odds2 > 1.7 and 1.7 or odds2
    odds1 = odds1 < 0.3 and 0.3 or odds1
    odds2 = odds2 < 0.3 and 0.3 or odds2
    odds1 = (odds1*100)%10 > 0 and odds1 or string.format("%s%s", odds1, 0)
    odds2 = (odds2*100)%10 > 0 and odds2 or string.format("%s%s", odds2, 0)
    self.OddsTxt.text = string.format(TI18N("赔率：<color='#23f0f7'>%s</color>       支持率       赔率：<color='#23f0f7'>%s</color>"), odds1, odds2)
    self.NoticeEffect.transform.localPosition = Vector3(self.Lbar.sizeDelta.x, 0, -400)
end