--作者:hzf
--09/24/2016 22:00:39
--功能:联赛单场结算

GuildLeagueResultCountWindow = GuildLeagueResultCountWindow or BaseClass(BasePanel)
function GuildLeagueResultCountWindow:__init(model)
	self.model = model
	self.Mgr = GuildLeagueManager.Instance
	self.resList = {
		{file = AssetConfig.guildleague_count_panel, type = AssetType.Main}
		,{file = AssetConfig.guildleaguebig, type = AssetType.Dep}
		,{file = AssetConfig.guildleague_texture, type = AssetType.Dep}
		,{file = AssetConfig.guild_totem_icon, type = AssetType.Dep}
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
	self.keytoresult = {
		["3_0"] = "win1",
		["2_0"] = "win1",
		["1_0"] = "win1",
		["3_1"] = "win2",
		["3_2"] = "win2",
		["2_1"] = "win2",
		["2_3"] = "lose2",
		["1_2"] = "lose2",
		["1_3"] = "lose2",
		["0_1"] = "lose1",
		["0_3"] = "lose1",
		["0_2"] = "lose1",
	}
	self.keytoScore = {
		["3_0"] = 3,
		["2_0"] = 3,
		["1_0"] = 3,
		["3_1"] = 2,
		["3_2"] = 2,
		["2_1"] = 2,
		["2_3"] = 0,
		["1_2"] = 0,
		["1_3"] = 0,
		["0_1"] = -1,
		["0_3"] = -1,
		["0_2"] = -1,
	}
end

function GuildLeagueResultCountWindow:__delete()
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function GuildLeagueResultCountWindow:OnHide()

end

function GuildLeagueResultCountWindow:OnOpen()

end

function GuildLeagueResultCountWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleague_count_panel))
	self.gameObject.name = "GuildLeagueResultCountWindow"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
	self.bgPanel = self.transform:Find("bgPanel")
	self.Main = self.transform:Find("Main")
	self.result = self.transform:Find("Main/result"):GetComponent(Image)
	self.IconL = self.transform:Find("Main/IconL"):GetComponent(Image)
	self.IconR = self.transform:Find("Main/IconR"):GetComponent(Image)
	self.LCrystal = self.transform:Find("Main/LCrystal")
	-- self.gcry = self.transform:Find("Main/LCrystal/gcry")
	-- self.gcry = self.transform:Find("Main/LCrystal/gcry")
	-- self.gcry = self.transform:Find("Main/LCrystal/gcry")
	self.Lcry = {
		[1] = self.transform:Find("Main/LCrystal/bcry1"):GetComponent(Image),
		[2] = self.transform:Find("Main/LCrystal/bcry2"):GetComponent(Image),
		[3] = self.transform:Find("Main/LCrystal/bcry3"):GetComponent(Image)
	}
	self.RCrystal = self.transform:Find("Main/RCrystal")
	-- self.gcry = self.transform:Find("Main/RCrystal/gcry")
	-- self.gcry = self.transform:Find("Main/RCrystal/gcry")
	-- self.gcry = self.transform:Find("Main/RCrystal/gcry")
	self.Rcry = {
		[1] = self.transform:Find("Main/RCrystal/bcry1"):GetComponent(Image),
		[2] = self.transform:Find("Main/RCrystal/bcry2"):GetComponent(Image),
		[3] = self.transform:Find("Main/RCrystal/bcry3"):GetComponent(Image)
	}
	self.Button = self.transform:Find("Main/Button"):GetComponent(Button)
	self.InfoButton = self.transform:Find("Main/InfoButton"):GetComponent(Button)
	self.Button.onClick:AddListener(function()
		self.model:CloseResultCountWindow()
	end)
	self.InfoButton.onClick:AddListener(function()
		self.model:CloseResultCountWindow()
		if self.Mgr.guild_LeagueInfo.grade == 1 then
			self.model:OpenWindow({2,1,self.Mgr.guild_LeagueInfo.season_id})
		else
			self.model:OpenWindow({1})
		end
	end)

	self.transform:Find("Main/bg"):GetComponent(Image).sprite = self.assetWrapper:GetTextures(AssetConfig.guildleaguebig , "GuildLeague2")
	self.transform:Find("Main/Title"):GetComponent(Image).sprite = self.assetWrapper:GetTextures(AssetConfig.guildleaguebig , "GuildLEague3")
	local sprite = self.assetWrapper:GetTextures(AssetConfig.guildleaguebig , "GuildLeague1")
	self.transform:Find("Main/bgGroup/1"):GetComponent(Image).sprite = sprite
	self.transform:Find("Main/bgGroup/2"):GetComponent(Image).sprite = sprite
	self.transform:Find("Main/bgGroup/3"):GetComponent(Image).sprite = sprite
	self.transform:Find("Main/bgGroup/4"):GetComponent(Image).sprite = sprite
	self.transform:Find("Main/bgGroup/5"):GetComponent(Image).sprite = sprite

	self.LSlider = self.transform:Find("Main/LSlider")
	self.LNum = self.transform:Find("Main/LSlider/Num")
	self.LWin = self.transform:Find("Main/LSlider/Win")
	self.LCannon = self.transform:Find("Main/LSlider/Cannon")
	self.LTower = self.transform:Find("Main/LSlider/Tower")

	self.RSlider = self.transform:Find("Main/RSlider")
	self.RNum = self.transform:Find("Main/RSlider/Num")
	self.RWin = self.transform:Find("Main/RSlider/Win")
	self.RCannon = self.transform:Find("Main/RSlider/Cannon")
	self.RTower = self.transform:Find("Main/RSlider/Tower")

	self.StaticText = self.transform:Find("Main/StaticText"):GetComponent(Text)

	self.LName = self.transform:Find("Main/LName"):GetComponent(Text)
    self.LScore = self.transform:Find("Main/LScore"):GetComponent(Text)
    self.LNumText = self.transform:Find("Main/LNumText"):GetComponent(Text)
    self.LWinText = self.transform:Find("Main/LWinText"):GetComponent(Text)
    self.LCannonText = self.transform:Find("Main/LCannonText"):GetComponent(Text)
    self.LDefendText = self.transform:Find("Main/LDefendText"):GetComponent(Text)

    self.RScore = self.transform:Find("Main/RScore"):GetComponent(Text)
    self.RName = self.transform:Find("Main/RName"):GetComponent(Text)
    self.RNumText = self.transform:Find("Main/RNumText"):GetComponent(Text)
    self.RWinText = self.transform:Find("Main/RWinText"):GetComponent(Text)
    self.RCannonText = self.transform:Find("Main/RCannonText"):GetComponent(Text)
    self.RDefendText = self.transform:Find("Main/RDefendText"):GetComponent(Text)


    local data = GuildLeagueManager.Instance.fightInfo
    if self.openArgs ~= nil then
		self:SetData(self.openArgs)
    else
		self:SetData(data)
	end
end

function GuildLeagueResultCountWindow:SetData(data)
	BaseUtils.dump(data, "联赛数据啊啊啊啊啊啊啊啊")
	local fullmember = 0
	local fullwin = 0
	local fullcannon = 0
	local fulldefend = 0
	local selfremain = 0
	local otherremain = 0
	local selfdata = {}
	local otherdata = {}
	for k,v in pairs(data) do
		fullmember = fullmember + v.member_num
		fullwin = fullwin + v.win
		fullcannon = fullcannon + v.attacked_unit
		fulldefend = fulldefend + v.guarded_unit
		if GuildManager.Instance.model.my_guild_data.GuildId == v.gids[1].guild_id and GuildManager.Instance.model.my_guild_data.PlatForm == v.gids[1].platform and GuildManager.Instance.model.my_guild_data.ZoneId == v.gids[1].zone_id then
			selfremain = v.remain_unit
			selfdata = v
		else
			otherdata = v
			otherremain = v.remain_unit
		end

		-- if GuildLeagueManager.Instance.my_guild_side == v.side then
		-- 	selfremain = v.remain_unit
		-- else
		-- 	otherremain = v.remain_unit
		-- end
	end
	local result = self.keytoresult[string.format("%s_%s", selfremain, otherremain)]
	local selfscore = self.keytoScore[string.format("%s_%s", selfremain, otherremain)]
	local otherscore = self.keytoScore[string.format("%s_%s", otherremain, selfremain)]
	if data.is_win == 3 then
		result = "tide"
	end
	if result == nil then
		if selfremain > otherremain then
			result = "win2"
		elseif selfremain < otherremain then
			result = "lose2"
		else
			result = "tide"
		end
	end
	if selfscore == nil then
		selfscore = 1
	end
	if otherscore == nil then
		otherscore = 1
	end
	if selfdata.grade == 1 and result == "tide" then
		if selfdata.is_win == 1 then
			result = "win2"
		else
			result = "lose2"
		end
	end
	if selfdata.grade == 1 then
		self.RScore.gameObject:SetActive(false)
		self.LScore.gameObject:SetActive(false)
	end
	self.result.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , result)
	for k,v in pairs(data) do
		if v.side == 1 then
			local serverName = ""
		    for k, vv in pairs(DataServerList.data_server_name) do
		        if vv.platform == v.gids[1].platform and vv.zone_id == v.gids[1].zone_id then
		            serverName = vv.platform_name
		            break
		        end
		    end
			self.LName.text = string.format("%s\n%s", v.names[1].name, serverName)
			-- self.LName.text = string.format("%s\n<size=16>%s</size>", v.names[1].name, serverName)
			self.IconL.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , v.totems[1].totem)
			self.LNumText.text = tostring(v.member_num)
			self.LNum.sizeDelta = Vector2(144*v.member_num/fullmember, 13)
			self.LWinText.text = tostring(v.win)
			self.LWin.sizeDelta = Vector2(144*v.win/fullwin, 13)
			self.LCannonText.text = tostring(v.attacked_unit)
			self.LCannon.sizeDelta = Vector2(144*v.attacked_unit/fullcannon, 13)
			self.LDefendText.text = tostring(v.guarded_unit)
			self.LTower.sizeDelta = Vector2(144*v.guarded_unit/fulldefend, 13)
			if GuildManager.Instance.model.my_guild_data.GuildId == v.gids[1].guild_id and GuildManager.Instance.model.my_guild_data.PlatForm == v.gids[1].platform and GuildManager.Instance.model.my_guild_data.ZoneId == v.gids[1].zone_id then
				if selfscore > 0 then
					self.LScore.text = string.format(TI18N("+%s积分"), selfscore)
				else
					self.LScore.text = string.format(TI18N("%s积分"), selfscore)
				end
			else
				if otherscore > 0 then
					self.LScore.text = string.format(TI18N("+%s积分"), otherscore)
				else
					self.LScore.text = string.format(TI18N("%s积分"), otherscore)
				end
			end
			for i=1,3-v.remain_unit do
				self.Lcry[i].gameObject:SetActive(false)
			end
		else
			self.IconR.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , v.totems[1].totem)
			local serverName = ""
		    for k, vv in pairs(DataServerList.data_server_name) do
		        if vv.platform == v.gids[1].platform and vv.zone_id == v.gids[1].zone_id then
		            serverName = vv.platform_name
		            break
		        end
		    end
			self.RName.text = string.format("%s\n%s", v.names[1].name, serverName)
			-- self.RName.text = string.format("%s\n<size=16>%s</size>", v.names[1].name, serverName)
			self.RScore.text = tostring(v.movability)
			self.RNumText.text = tostring(v.member_num)
			self.RNum.sizeDelta = Vector2(144*v.member_num/fullmember, 13)
			self.RWinText.text = tostring(v.win)
			self.RWin.sizeDelta = Vector2(144*v.win/fullwin, 13)
			self.RCannonText.text = tostring(v.attacked_unit)
			self.RCannon.sizeDelta = Vector2(144*v.attacked_unit/fullcannon, 13)
			self.RDefendText.text = tostring(v.guarded_unit)
			self.RTower.sizeDelta = Vector2(144*v.guarded_unit/fulldefend, 13)
			for i=1,3-v.remain_unit do
				self.Rcry[i].gameObject:SetActive(false)
			end
			if GuildManager.Instance.model.my_guild_data.GuildId == v.gids[1].guild_id and GuildManager.Instance.model.my_guild_data.PlatForm == v.gids[1].platform and GuildManager.Instance.model.my_guild_data.ZoneId == v.gids[1].zone_id then
				if selfscore > 0 then
					self.RScore.text = string.format(TI18N("+%s积分"), selfscore)
				else
					self.RScore.text = string.format(TI18N("%s积分"), selfscore)
				end
			else
				if otherscore > 0 then
					self.RScore.text = string.format(TI18N("+%s积分"), otherscore)
				else
					self.RScore.text = string.format(TI18N("%s积分"), otherscore)
				end
			end
		end
	end
end