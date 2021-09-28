local _M = {}
_M.__index = _M

local Leaderboard = require "Zeus.Model.Leaderboard"
local Util = require "Zeus.Logic.Util"
local TreeView = require "Zeus.Logic.TreeView"
local cjson = require"cjson"
local MountModel = require "Zeus.Model.Mount"
local ServerTime = require "Zeus.Logic.ServerTime"

local serial = 0

local iconImgID = { 30, 34, 27, 28, 25 }
local function SetProIconImg(icon,pro)
	Util.HZSetImage(icon, "#dynamic_n/land/land.xml|land|" .. iconImgID[tonumber(pro)], false, LayoutStyle.IMAGE_STYLE_BACK_4, 8)
end

local function SetGuildName(label, name, show)
	if show then
		if name and name ~= "" then
			label.Text = Util.GetText(TextConfig.Type.LEADERBOARD, "guildName", name)
		else
			label.Text = Util.GetText(TextConfig.Type.LEADERBOARD, "noGuildName")
		end
		label.Visible = true
	else
		label.Visible = false
	end
end

local function Release3DModel(self)
	if self.model ~= nil then
        GameObject.Destroy(self.model.obj)
        IconGenerator.instance:ReleaseTexture(self.model.key)
	end
	self.model = nil
end

local function ResetPetModelPos(key,data)
	IconGenerator.instance:SetRotate(key, Vector3.New(10, 180, 0))
    IconGenerator.instance:SetCameraParam(key, 0.1, 20, 2)
    if data == "pet_bailong_01" then
    	IconGenerator.instance:SetModelPos(key, Vector3.New(0.0, -0.5, 1.8))
    elseif data == "pet_bifang_01" then
    	IconGenerator.instance:SetModelPos(key, Vector3.New(0.0, -0.3, 1.5))
    elseif data == "pet_xiaotian_01" then
    	IconGenerator.instance:SetModelPos(key, Vector3.New(0.0, -1, 6))
    elseif data == "pet_huli_01" then
    	IconGenerator.instance:SetModelPos(key, Vector3.New(0.0, -0.5, 3.8))
    elseif data == "pet_ziyu_01" then
    	IconGenerator.instance:SetModelPos(key, Vector3.New(0.0, -1.3, 3))
    elseif data == "pet_xiaoji_01" then
    	IconGenerator.instance:SetModelPos(key, Vector3.New(0.0, -0.5, 3.5))
    elseif data == "pet_dieyao_01" then
    	IconGenerator.instance:SetModelPos(key, Vector3.New(0.0, -1.5, 5.0))
    elseif data == "pet_daowuren_01" then
    	IconGenerator.instance:SetModelPos(key, Vector3.New(0.0, -1.2, 4.0))
    else
    	IconGenerator.instance:SetModelPos(key, Vector3.New(0.0, -0.5, 1.5))
    end
end

local function ShowPet3DModel(self, parent, data)
	local modelFile = "/res/unit/pet/"..data..".assetbundles"
	if self.model == nil or (self.model.avatarMode ~= (data == nil)) then
		Release3DModel(self)
		local obj, key = GameUtil.Add3DModelLua(parent, modelFile, {}, nil, 0, true)
	    
	    	ResetPetModelPos(key,data)
	    

		obj.transform.sizeDelta = UnityEngine.Vector2.New(parent.Height, parent.Height)
		local rawImage = obj:GetComponent("UnityEngine.UI.RawImage")
		rawImage.raycastTarget = false

		self.model = {}
		self.model.obj = obj
		self.model.key = key
	else
		
		
		
			GameUtil.Change3DModelLua(self.model.key, modelFile, {}, 0)
		    
		    	ResetPetModelPos(self.model.key,data)
		    
		
		
	end
	self.model.avatarMode = data == nil
end

local function ShowRide3DModel(self, parent, modelFile, avatars, filter)
	if self.model == nil or (self.model.avatarMode ~= (modelFile == nil)) then
		Release3DModel(self)
		local obj, key = GameUtil.Add3DModelLua(parent, modelFile, avatars, nil, filter, true)
	    
    		IconGenerator.instance:SetCameraParam(key, 0.1, 100, 2.8)
    		if modelFile == "/res/unit/mount/mnt_xianjian_01.assetbundles" then
    			IconGenerator.instance:SetModelPos(key, Vector3.New(1.0, -1.5, 10))
    			IconGenerator.instance:SetRotate(key, Vector3.New(17, 220, 17))
    		elseif modelFile == "/res/unit/mount/mnt_lingbaohulu_01.assetbundles" then
    			IconGenerator.instance:SetModelPos(key, Vector3.New(0.0, -3, 10))
    			IconGenerator.instance:SetRotate(key, Vector3.New(0, 225, 0))
    		else
    			IconGenerator.instance:SetModelPos(key, Vector3.New(0.0, -2.0, 7))
    			IconGenerator.instance:SetRotate(key, Vector3.New(0, 225, 0))
    		end
	    

		obj.transform.sizeDelta = UnityEngine.Vector2.New(parent.Height, parent.Height)
		local rawImage = obj:GetComponent("UnityEngine.UI.RawImage")
		
		rawImage.raycastTarget = false

		self.model = {}
		self.model.obj = obj
		self.model.key = key
	else
		
		
		
			GameUtil.Change3DModelLua(self.model.key, modelFile, avatars, filter)
		    
    			IconGenerator.instance:SetCameraParam(self.model.key, 0.1, 100, 2.8)
    			if modelFile == "/res/unit/mount/mnt_xianjian_01.assetbundles" then
    				IconGenerator.instance:SetModelPos(self.model.key, Vector3.New(1.0, -1.5, 10))
    				IconGenerator.instance:SetRotate(self.model.key, Vector3.New(17, 220, 17))
    			elseif modelFile == "/res/unit/mount/mnt_lingbaohulu_01.assetbundles" then
    				IconGenerator.instance:SetModelPos(self.model.key, Vector3.New(0.0, -3, 10))
    				IconGenerator.instance:SetRotate(self.model.key, Vector3.New(0, 225, 0))
    			else
    				IconGenerator.instance:SetModelPos(self.model.key, Vector3.New(0.0, -2.0, 7))
    				IconGenerator.instance:SetRotate(self.model.key, Vector3.New(0, 225, 0))
    			end
		    
		
		
	end
	self.model.avatarMode = modelFile == nil
end

local function ShowActor3DModel(self, parent, modelFile, avatars, filter)
	if self.model == nil or (self.model.avatarMode ~= (modelFile == nil)) then
		Release3DModel(self)
		local obj, key = GameUtil.Add3DModelLua(parent, modelFile, avatars, nil, filter, true)
	    
			IconGenerator.instance:SetModelPos(key, Vector3.New(0, -1.1, 3.5))
    		IconGenerator.instance:SetCameraParam(key, 0.3, 10, 2)
	    

		obj.transform.sizeDelta = UnityEngine.Vector2.New(parent.Height, parent.Height)
		local rawImage = obj:GetComponent("UnityEngine.UI.RawImage")
		rawImage.raycastTarget = false

		self.model = {}
		self.model.obj = obj
		self.model.key = key
	else
		
		
		
			GameUtil.Change3DModelLua(self.model.key, modelFile, avatars, filter)
		    IconGenerator.instance:SetLoadOKCallback(self.model.key, function (k)
				IconGenerator.instance:SetModelPos(self.model.key, Vector3.New(0, -1.1, 3.5))
    			IconGenerator.instance:SetCameraParam(self.model.key, 0.3, 10, 2)
		    end)
		
		
	end
	self.model.avatarMode = modelFile == nil
end

local function OnCellSelected(self)
	local data = self.listData[self.seletedIndex]
	if self.boardtype == Leaderboard.LBType.GUILD_LEVEL or self.boardtype == Leaderboard.LBType.GUILD_WAR 
						or self.boardtype == Leaderboard.LBType.GUILD_BOSS_GUILD_T or self.boardtype == Leaderboard.LBType.GUILD_BOSS_GUILD_Y then
		Leaderboard.RequestGuildInfo(data.contents[2], function(gdata)
			
			MenuBaseU.SetImageBox(self.infoCvs, "ib_guild_sign", "static_n/guild/"..gdata.guildIcon..".png", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
			
			MenuBaseU.SetLabelText(self.infoCvs, "lb_name", data.contents[4], 0, 0)
			
			MenuBaseU.SetLabelText(self.infoCvs, "lb_lead_name", gdata.guildMaster, GameUtil.GetProColor(gdata.guildMasterPro), 0)
			
			MenuBaseU.SetLabelText(self.infoCvs, "lb_level_number", tostring(gdata.guildLevel), 0, 0)
			
			MenuBaseU.SetLabelText(self.infoCvs, "lb_number_number", gdata.curMember..'/'..gdata.maxMember, 0, 0)
			
			MenuBaseU.SetLabelText(self.infoCvs, "lb_guild_pay", tostring(gdata.fund), 0, 0)
			
			local noticeTb = self.infoCvs:FindChildByEditName("tb_notice", true)
			noticeTb.UnityRichText = gdata.notice
			
			local guildInfobtn = self.infoCvs:FindChildByEditName("btn_look", true)
			guildInfobtn.Visible = false
			
			
			
			local addGuildbtn = self.infoCvs:FindChildByEditName("btn_ask", true)
			addGuildbtn.Visible = not DataMgr.Instance.UserData.Guild
			addGuildbtn.TouchClick = function(sender)
				local GuildModel = require "Zeus.Model.Guild"
				GuildModel.joinGuildRequest(gdata.guildId, function(msg)
					local tips = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.LEADERBOARD, "GuildTips1")
					GameAlertManager.Instance:ShowNotify(tips)
				end)
			end
		end)
	elseif self.boardtype == Leaderboard.LBType.RIDE then
		local v = MountModel.GetSkinDataById(tonumber(data.contents[7]))
		
		MenuBaseU.SetLabelText(self.infoCvs, "lb_human_name", data.contents[4], GameUtil.GetProColor(data.contents[3]), 0)
		
		local nameTb = self.infoCvs:FindChildByEditName("tb_rdpt_name", true)
		nameTb.TextComponent.Anchor = TextAnchor.C_C
		nameTb.UnityRichText = string.format("<a><f color='%x'>%s</f></a>", 0xffea9160, v.SkinName)
		
		local fightPower = data.contents[6]
		self.infoCvs:FindChildByEditName("lb_power", true).Text = tostring(fightPower)
		
		local modelCvs = self.infoCvs:FindChildByEditName("cvs_picture", true)
		local modelFile
		modelFile = "/res/unit/mount/"..v.ModelFile..".assetbundles"
		ShowRide3DModel(self, modelCvs, modelFile, {}, 0)
		
		local playerInfobtn = self.infoCvs:FindChildByEditName("btn_look", true)
		playerInfobtn.TouchClick = function(sender)
			GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIVSPlayer, 0, data.contents[2])
		end
	elseif self.boardtype == Leaderboard.LBType.PET then
		
		MenuBaseU.SetLabelText(self.infoCvs, "lb_human_name", data.contents[4], GameUtil.GetProColor(data.contents[3]), 0)
		
		local nameTb = self.infoCvs:FindChildByEditName("tb_rdpt_name", true)
		nameTb.TextComponent.Anchor = TextAnchor.C_C
		nameTb.UnityRichText = string.format("<a><f color='%x'>%s</f></a>", Util.GetQualityColorARGB(data.contents[3]), data.contents[5])
		
		local fightPower = data.contents[6]
		self.infoCvs:FindChildByEditName("lb_power", true).Text = tostring(fightPower)
		
		local modelCvs = self.infoCvs:FindChildByEditName("cvs_picture", true)
		ShowPet3DModel(self, modelCvs, data.contents[7])
		
		local playerInfobtn = self.infoCvs:FindChildByEditName("btn_look", true)
		playerInfobtn.TouchClick = function(sender)
			GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIVSPlayer, 0, data.contents[2])
		end
	else
		
		MenuBaseU.SetLabelText(self.infoCvs, "lb_name", data.contents[4], GameUtil.GetProColor(data.contents[3]), 0)
		
		local lvtb = self.infoCvs:FindChildByEditName("tb_level", true)
		lvtb.TextComponent.Anchor = TextAnchor.C_C
		local lvText = Util.GetText(TextConfig.Type.PUBLICCFG, 'LongLv.n', data.contents[5])
		if self.boardtype == Leaderboard.LBType.LEVEL then
			
			if tonumber(data.contents[7]) > 0 then
				local uplvStr, uplvArgb = Util.GetUpLvTextAndColorARGB(tonumber(data.contents[7]))
				lvtb.UnityRichText = string.format("<a><f color='%x'>%s</f><f color='%x'>%s</f></a>", uplvArgb, uplvStr, Util.GetQualityColorARGB(GameUtil.Quality_Default), lvText)
			else
				lvtb.UnityRichText = string.format("<a><f color='%x'>%s</f></a>", Util.GetQualityColorARGB(GameUtil.Quality_Default), lvText)
			end
		else
			
			lvtb.UnityRichText = string.format("<a><f color='%x'>%s</f></a>", Util.GetQualityColorARGB(GameUtil.Quality_Default), lvText)
		end
		
		self.infoCvs:FindChildByEditName("lb_power", true).Text = tostring(data.contents[6])
		
		local proIcon = self.infoCvs:FindChildByEditName("ib_job", true)
		SetProIconImg(proIcon,data.contents[3])
		
		local modelCvs = self.infoCvs:FindChildByEditName("cvs_picture", true)
		local filter = bit.lshift(1,  GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))
		ShowActor3DModel(self, modelCvs, nil, data.avatars, filter)
		
		local playerInfobtn = self.infoCvs:FindChildByEditName("btn_look", true)
		playerInfobtn.TouchClick = function(sender)
			GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIVSPlayer, 0, data.contents[2])
		end
		local addFriendbtn = self.infoCvs:FindChildByEditName("btn_friend", true)
		addFriendbtn.TouchClick = function(sender)
			local FriendModel = require "Zeus.Model.Friend"
			FriendModel.friendApplyRequest(data.contents[2], function()
				local tips = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.LEADERBOARD, "FriendTips1")
				GameAlertManager.Instance:ShowNotify(string.format(tips, data.contents[4]))
			end)
		end
	end
	self.pan:RefreshShowCell()
end

local function RefreshCellData(self, cell, data, index)
	
	
	local rank = tonumber(data.contents[1])
	local rankIcon = cell:FindChildByEditName("ib_123", true)
	local rankLabel = cell:FindChildByEditName("lb_rank", true)
    local rankLimit = GlobalHooks.DB.GetGlobalConfig('RankList.Limit')
	if rank == 0 then
		rankIcon.Visible = false
		rankLabel.Visible = false
		if self.myData == data then
			rankLabel.Visible = true
			rankLabel.Text = '>'..rankLimit
		end
	elseif rank <= 3 then
		rankIcon.Visible = true
		rankLabel.Visible = false
		local rImg = XmdsUISystem.CreateLayoutFroXmlKey("#dynamic_n/dynamic_new/solo/solo.xml|solo|"..rank, LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
		rankIcon.Layout = rImg
	else
		rankIcon.Visible = false
		rankLabel.Visible = true
		if self.myData == data and rank > rankLimit then
			rankLabel.Text = '>'..rankLimit
		else
			rankLabel.Text = tostring(rank)
		end
	end
	
	
	local tbt = cell:FindChildByEditName("tbt_list", true)
	if tbt ~= nil then
		tbt.IsChecked = self.seletedIndex == index
		tbt.TouchClick = function(sender)
			self.seletedIndex = index
			OnCellSelected(self)
		end
	end

	local lb_guild_boss = cell:FindChildByEditName("lb_guild_boss", true)
	lb_guild_boss.Visible = self.boardtype == Leaderboard.LBType.GUILD_BOSS_GUILD_T or self.boardtype == Leaderboard.LBType.GUILD_BOSS_GUILD_Y

	if self.boardtype >= Leaderboard.LBType.FIGHTPOWER_ALL and self.boardtype <= Leaderboard.LBType.FIGHTPOWER_5 then
		MenuBaseU.SetLabelText(cell, "lb_name", data.contents[4], GameUtil.GetProColor(data.contents[3]), 0)
		MenuBaseU.SetVisibleUENode(cell, "cvs_power", false)
		MenuBaseU.SetVisibleUENode(cell, "lb_number", true)
		
		MenuBaseU.SetImageBox(cell, "ib_icon", "static_n/hud/target/"..data.contents[3]..".png", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
		
		local lvLabel = cell:FindChildByEditName("ib_rank_num", true)
		lvLabel.Text = data.contents[5]
		
		local string = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.LEADERBOARD, "Fp")
		MenuBaseU.SetLabelText(cell, "lb_number", string..tostring(data.contents[6]), 0, 0)
		
		local proIcon = cell:FindChildByEditName("ib_mark", true)
		SetProIconImg(proIcon,data.contents[3])
		proIcon.Visible = false
		
		local lb_guild = cell:FindChildByEditName("lb_guild", true)
		SetGuildName(lb_guild, data.contents[7], true)
	elseif self.boardtype == Leaderboard.LBType.GUILD_LEVEL or self.boardtype == Leaderboard.LBType.GUILD_WAR 
							or self.boardtype == Leaderboard.LBType.GUILD_BOSS_GUILD_T or self.boardtype == Leaderboard.LBType.GUILD_BOSS_GUILD_Y then
		MenuBaseU.SetLabelText(cell, "lb_name", data.contents[4], 0, 0)
		MenuBaseU.SetVisibleUENode(cell, "cvs_power", false)
		MenuBaseU.SetVisibleUENode(cell, "lb_number", true)
		MenuBaseU.SetVisibleUENode(cell, "ib_mark", false)
		MenuBaseU.SetVisibleUENode(cell, "ib_rank_back", false)
		MenuBaseU.SetVisibleUENode(cell, "ib_rank_num", false)
		
		MenuBaseU.SetImageBox(cell, "ib_icon", "static_n/guild/"..data.contents[3]..".png", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
		
		local gdlvStr = ""
		if self.boardtype == Leaderboard.LBType.GUILD_LEVEL then
			gdlvStr = Util.GetText(TextConfig.Type.LEADERBOARD, "guild_level", data.contents[5])
		elseif self.boardtype == Leaderboard.LBType.GUILD_WAR then
			gdlvStr = Util.GetText(TextConfig.Type.LEADERBOARD, "guild_war_score", data.contents[6])
		elseif Leaderboard.LBType.GUILD_BOSS_GUILD_T or Leaderboard.GUILD_BOSS_GUILD_Y then
			gdlvStr = Util.GetText(TextConfig.Type.LEADERBOARD, "guildBoss_score", Util.NumberToShow(data.contents[6]))
			lb_guild_boss.Text = Util.GetText(TextConfig.Type.LEADERBOARD, "guildBoss_time", ServerTime.GetCDStrCut(tonumber(data.contents[7])))
		end
		MenuBaseU.SetLabelText(cell, "lb_number", gdlvStr, 0, 0)
		local lb_guild = cell:FindChildByEditName("lb_guild", true)
		SetGuildName(lb_guild, "", false)
	elseif self.boardtype == Leaderboard.LBType.RIDE then
		MenuBaseU.SetLabelText(cell, "lb_name", data.contents[4], GameUtil.GetProColor(data.contents[3]), 0)
		MenuBaseU.SetVisibleUENode(cell, "cvs_power", false)
		MenuBaseU.SetVisibleUENode(cell, "lb_number", true)
		
		MenuBaseU.SetImageBox(cell, "ib_icon", "static_n/hud/target/"..data.contents[3]..".png", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
		
		local lvLabel = cell:FindChildByEditName("ib_rank_num", true)
		lvLabel.Text = data.contents[5]
		
		local rdpfStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.LEADERBOARD, "riderFp")
		rdpfStr = string.format(rdpfStr.."%d", data.contents[6])
		MenuBaseU.SetLabelText(cell, "lb_number", rdpfStr, 0, 0)
		
  		local v = MountModel.GetSkinDataById(tonumber(data.contents[7]))
		MenuBaseU.SetVisibleUENode(cell, "ib_mark", true)
		MenuBaseU.SetImageBox(cell, "ib_mark", "dynamic_n/mount_icon/"..v.Icon..".png", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
		local lb_guild = cell:FindChildByEditName("lb_guild", true)
		SetGuildName(lb_guild, data.contents[8], true)
	elseif self.boardtype == Leaderboard.LBType.PET then
		MenuBaseU.SetLabelText(cell, "lb_name", data.contents[4], GameUtil.GetProColor(data.contents[3]), 0)
		MenuBaseU.SetVisibleUENode(cell, "cvs_power", false)
		MenuBaseU.SetVisibleUENode(cell, "lb_number", true)
		
		MenuBaseU.SetImageBox(cell, "ib_icon", "static_n/hud/target/"..data.contents[3]..".png", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
		
		local lvLabel = cell:FindChildByEditName("ib_rank_num", true)
		lvLabel.Text = data.contents[11]
		
		local ptpfStr = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.LEADERBOARD, "petFp")
		ptpfStr = string.format(ptpfStr.."%d", data.contents[6])
		MenuBaseU.SetLabelText(cell, "lb_number", ptpfStr, 0, 0)
		
		MenuBaseU.SetVisibleUENode(cell, "ib_mark", true)
		MenuBaseU.SetImageBox(cell, "ib_mark", "static_n/hud/target/"..data.contents[9]..".png", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
		local lb_guild = cell:FindChildByEditName("lb_guild", true)
		SetGuildName(lb_guild, data.contents[13], true)
	else
		MenuBaseU.SetLabelText(cell, "lb_name", data.contents[4], GameUtil.GetProColor(data.contents[3]), 0)
		MenuBaseU.SetVisibleUENode(cell, "cvs_power", false)
		MenuBaseU.SetVisibleUENode(cell, "lb_number", true)
		
		MenuBaseU.SetImageBox(cell, "ib_icon", "static_n/hud/target/"..data.contents[3]..".png", LayoutStyle.IMAGE_STYLE_BACK_4, 8)
		
		local lvLabel = cell:FindChildByEditName("ib_rank_num", true)
		lvLabel.Text = data.contents[5]
		
		local proIcon = cell:FindChildByEditName("ib_mark", true)
		SetProIconImg(proIcon,data.contents[3])
		proIcon.Visible = false
		local lvLabel = cell:FindChildByEditName("lb_number", true)

		local lb_guild = cell:FindChildByEditName("lb_guild", true)
		SetGuildName(lb_guild, data.contents[8], true)

		if self.boardtype == Leaderboard.LBType.LEVEL then
			
			local lvText = Util.GetText(TextConfig.Type.PUBLICCFG, 'LongLv.n', data.contents[5])
			if tonumber(data.contents[7]) > 0 then
				local uplvStr, uplvRgba = Util.GetUpLvTextAndColorRGBA(tonumber(data.contents[7]))
				lvLabel.SupportRichtext = true
				lvLabel.FontColor = GameUtil.RGBA2Color(uplvRgba)
				lvLabel.Text = string.format(uplvStr.."<color=#%x> %s</color>", Util.GetQualityColorRGBA(GameUtil.Quality_Default), lvText)
			else
				lvLabel.Text = string.format("<color=#%x>%s</color>", Util.GetQualityColorRGBA(GameUtil.Quality_Default), lvText)
			end
		elseif self.boardtype == Leaderboard.LBType.ARENA then
			
			lvLabel.Text = Util.GetText(TextConfig.Type.LEADERBOARD,'arena_score', data.contents[7])
		elseif self.boardtype == Leaderboard.LBType.ARENA_5V5 then
			
			lvLabel.Text = Util.GetText(TextConfig.Type.LEADERBOARD,'trial_score', data.contents[7])
		elseif self.boardtype == Leaderboard.LBType.MELEE or self.boardtype == Leaderboard.LBType.MELEE_LAST_SEASON then
			
			lvLabel.Text = Util.GetText(TextConfig.Type.LEADERBOARD,'melee_score', data.contents[7])
		elseif self.boardtype == Leaderboard.LBType.HP then
			
			lvLabel.Text = Util.GetText(TextConfig.Type.LEADERBOARD,'shuxing_hp', data.contents[7])
		elseif self.boardtype == Leaderboard.LBType.Phy then
			
			lvLabel.Text = Util.GetText(TextConfig.Type.LEADERBOARD,'shuxing_Phy', data.contents[7])
		elseif self.boardtype == Leaderboard.LBType.Mag then
			
			lvLabel.Text = Util.GetText(TextConfig.Type.LEADERBOARD,'shuxing_Mag', data.contents[7])
		elseif self.boardtype == Leaderboard.LBType.XIANYUAN then
			
			lvLabel.Text = Util.GetText(TextConfig.Type.LEADERBOARD,'xianyuan_score', data.contents[7])
		elseif self.boardtype == Leaderboard.LBType.DEMONTOWER then
			
			lvLabel.Text = Util.GetText(TextConfig.Type.LEADERBOARD,'demontower_lv', data.contents[7])
		elseif self.boardtype == Leaderboard.LBType.GEM then
			
			lvLabel.Text = Util.GetText(TextConfig.Type.LEADERBOARD,'gem_level', data.contents[7])
		elseif self.boardtype == Leaderboard.LBType.GUILD_BOSS_PERSONAL_T or self.boardtype == Leaderboard.LBType.GUILD_BOSS_PERSONAL_Y then
			
			lvLabel.Text = Util.GetText(TextConfig.Type.LEADERBOARD,'guildBoss_score', Util.NumberToShow(data.contents[8]))
			SetGuildName(lb_guild, data.contents[7], true)
		end
	end
end

local function RequestList(self, lbtype)
	self.boardtype = lbtype
	local season = -1
	if lbtype == Leaderboard.LBType.MELEE then
		season = 1
	elseif lbtype == Leaderboard.LBType.MELEE_LAST_SEASON then
		season = 0
		lbtype = Leaderboard.LBType.MELEE
	end
	Leaderboard.RequestLeaderBoard(lbtype, season, function(data)
		
		
		
		self.menu.Visible = true
		self.listData = data.s2c_lists
		self.myData = data.s2c_myData
		if self.listData ~= nil then
		    self.seletedIndex = 1
		    
		    self.menu:SetVisibleUENode("sp_mid_sp", self.listData ~= nil)
		    
		    self.menu:SetVisibleUENode("cvs_mine", self.myData ~= nil)
		    self.pan = self.menu.mRoot:FindChildByEditName("sp_mid_sp", true)--(self.myData ~= nil and "sp_mid_sp" or "sp_mid_sp2", true)
		    local cell = self.menu.mRoot:FindChildByEditName("cvs_mid_list", true)
		    cell.Visible = false
		    self.pan:Initialize(
		        cell.Width + 0, 
		        cell.Height + 0, 
		        #self.listData,
		        1,
		        cell, 
		        function(x, y, cell)
					local index = y + 1
					local data = self.listData[index]
					RefreshCellData(self, cell, data, index)
				end,
		        function() end)

			
			if self.boardtype == Leaderboard.LBType.GUILD_LEVEL or self.boardtype == Leaderboard.LBType.GUILD_WAR 
				or self.boardtype == Leaderboard.LBType.GUILD_BOSS_GUILD_T or self.boardtype == Leaderboard.LBType.GUILD_BOSS_GUILD_Y then
				self.infoCvs = self.menu:FindChildByEditName("cvs_guild", true)
				self.menu:SetVisibleUENode("cvs_guild", true)
				self.menu:SetVisibleUENode("cvs_mount&pet", false)
				self.menu:SetVisibleUENode("cvs_others", false)
			elseif self.boardtype == Leaderboard.LBType.RIDE or self.boardtype == Leaderboard.LBType.PET then
				self.infoCvs = self.menu:FindChildByEditName("cvs_mount&pet", true)
				self.menu:SetVisibleUENode("cvs_guild", false)
				self.menu:SetVisibleUENode("cvs_mount&pet", true)
				self.menu:SetVisibleUENode("cvs_others", false)
			else
				self.infoCvs = self.menu:FindChildByEditName("cvs_others", true)
				self.menu:SetVisibleUENode("cvs_guild", false)
				self.menu:SetVisibleUENode("cvs_mount&pet", false)
				self.menu:SetVisibleUENode("cvs_others", true)
			end

			
			OnCellSelected(self)
		else
			self.menu:SetVisibleUENode("sp_mid_sp", false)
		    
		    self.menu:SetVisibleUENode("ib_line", false)
			self.menu:SetVisibleUENode("cvs_mid_list", false)
			self.menu:SetVisibleUENode("cvs_guild", false)
			self.menu:SetVisibleUENode("cvs_mount&pet", false)
			self.menu:SetVisibleUENode("cvs_others", false)
		end

		if self.myData ~= nil and self.myData.contents[1] ~= nil then
			
			local myInfo = self.menu:FindChildByEditName("cvs_mine", true)
			myInfo.Visible = true
			RefreshCellData(self, myInfo, self.myData, 0)
		else
			self.menu:SetVisibleUENode("cvs_mine", false)
		end

		if self.callBack then
			self.callBack:DynamicInvoke()
		end
		self.callBack = nil
	end)
end

local function OnExit(self)
	Release3DModel(self)
end

local function OnEnter(self)

end

local function GetClassify(typekey)
	local json = Util.GetJsonText(TextConfig.Type.LEADERBOARD,typekey)
	if not json then
		return nil
	else
		return cjson.decode(json)
	end
end

local function InitClassify(self, index)
	local root = math.floor(index/10)
	local sub = index%10
	local classify = GetClassify("sub_"..root.."_"..sub).classify

	for i=1,#self.classifyCan do
		self.classifyCan[i].Visible = i <= #classify
		if i <= #classify then
			local classifyChild = GetClassify(classify[i])
			self.classifyCan[i].Text = classifyChild.title
			self.classifyCan[i].UserTag = classifyChild.tag
		end
	end
	
	Util.InitMultiToggleButton(function(sender)
    		RequestList(self, sender.UserTag)
       	end, self.classifyCan[1], self.classifyCan)
end

local function CreatTreeView(self)
	local sp_type = self.menu.mRoot:FindChildByEditName("sp_type", true)
	local cvs_typename = self.menu.mRoot:FindChildByEditName("cvs_typename", true)
	local tbt_subtype = self.menu.mRoot:FindChildByEditName("tbt_subtype", true)

	local subValues = {}
    local subValueChild = {8,4,3}
    self.treeView = TreeView.Create(#subValueChild,0,sp_type.Size2D,TreeView.MODE_SINGLE) 
    local function rootCreateCallBack(index,node)
        node.Enable = true
        local lb_title = node:FindChildByEditName("lb_typename", false)
        lb_title.Text = Util.GetText(TextConfig.Type.LEADERBOARD,"roottitle_"..index)
    end
    local function rootClickCallBack(node,visible)
        local tbt_open = node:FindChildByEditName("tbt_open",false)
        tbt_open.IsChecked = visible
        if visible == true then
        	XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('zuobiaoqian')
        end
    end
    local rootValue = TreeView.CreateRootValue(cvs_typename,#subValueChild,rootCreateCallBack,rootClickCallBack)

    self.subNodeList = {}
    local function subClickCallback(rootIndex,subIndex,node)

    end
    local function subCreateCallback(rootIndex,subIndex,node)
        node.UserTag = rootIndex*10+subIndex
        node.Enable = true
        node.IsChecked = false
        local classify = GetClassify("sub_"..rootIndex.."_"..subIndex)
        node.Text = classify.title
        table.insert(self.subNodeList, node)
    end

    for i=1,#subValueChild do
    	subValues[i] = TreeView.CreateSubValue(i,tbt_subtype,subValueChild[i], subClickCallback, subCreateCallback)
    end
    self.treeView:setValues(rootValue,subValues)
    sp_type:AddNormalChild(self.treeView.view)
    
    Util.InitMultiToggleButton( function(sender)
    	InitClassify(self, sender.UserTag)
       	end , nil, self.subNodeList)
end

local function getTreeIndex(self, param)
	param = tonumber(param)
	local root = 1
	local sub = 1
	if param == Leaderboard.LBType.LEVEL then
		sub = 2
	elseif param == Leaderboard.LBType.HP or param == Leaderboard.LBType.Phy or param == Leaderboard.LBType.Mag then
		sub = 3
	elseif param == Leaderboard.LBType.GEM then
		sub = 4
	elseif param == Leaderboard.LBType.RIDE then
		sub = 5
	elseif param == Leaderboard.LBType.PET then
		sub = 6
	elseif param == Leaderboard.LBType.XIANYUAN then
		sub = 7
	elseif param == Leaderboard.LBType.DEMONTOWER then
		sub = 8
	elseif param == Leaderboard.LBType.GUILD_LEVEL then
		root = 2
	elseif param == Leaderboard.LBType.GUILD_WAR then
		root = 2
		sub = 2
	elseif param == Leaderboard.LBType.GUILD_BOSS_PERSONAL_T or param == Leaderboard.LBType.GUILD_BOSS_PERSONAL_Y then
		root = 2
		sub = 3
	elseif param == Leaderboard.LBType.GUILD_BOSS_GUILD_T or param == Leaderboard.LBType.GUILD_BOSS_GUILD_Y then
		root = 2
		sub = 4
	elseif param == Leaderboard.LBType.ARENA then
		root = 3
	elseif param == Leaderboard.LBType.ARENA_5V5 then
		root = 3
		sub = 2
	elseif param == Leaderboard.LBType.MELEE then
		root = 3
		sub = 3
	end
	return root, sub
end

local function getIndex(self, root, sub)
	local index = 1
	if root == 1 then
		index = sub
	elseif root == 2 then
		index = sub+8
	elseif root == 3 then
		index = sub+12
	end
	return index
end

local function OnLoad(self, callBack)
	self.callBack = callBack
	local root, sub = getTreeIndex(self, self.menu.ExtParam)
	self.treeView:selectNode(root,sub,true)
	local index = getIndex(self, root, sub)
	self.subNodeList[index].IsChecked = true
end

local function InitCompnent(self)
	
	local backBtn = self.menu.mRoot:FindChildByEditName("btn_back", true)
	if backBtn ~= nil then
		backBtn.TouchClick = function(sender)
			self.menu:Close()
		end
	end

	
	local closeBtn = self.menu.mRoot:FindChildByEditName("btn_close", true)
	if closeBtn ~= nil then
		closeBtn.TouchClick = function(sender)
			self.menu:Close()
		end
	end
	
	self.sp_title = self.menu.mRoot:FindChildByEditName("sp_title", true)
	self.cvs_item = self.menu.mRoot:FindChildByEditName("cvs_item", true)
	self.cvs_item.Visible = false
	self.classifyCan = {}
	for i=1,6 do
		self.classifyCan[i] = self.menu.mRoot:FindChildByEditName("tbt_classify"..i, true)
	end
	CreatTreeView(self)

    self.menu:SubscribOnLoad(function(callback)
    	OnLoad(self, callback)
    end)
    self.menu:SubscribOnEnter(function()
    	OnEnter(self)
    end)
    self.menu:SubscribOnExit(function()
    	OnExit(self)
    end)
    self.menu:SubscribOnDestory(function()
    	self = nil
    end)

    MountModel.InitSkinList()
end

local function Init(self)
	self.menu = LuaMenuU.Create("xmds_ui/rank/rank_list.gui.xml", GlobalHooks.UITAG.GameUILeaderboard)
	self.menu.ShowType = UIShowType.HideBackHud
	serial = serial + 1
	self.serial = serial
	InitCompnent(self)
	return self.menu
end

local function Create(params)
	local self = {}
	setmetatable(self, _M)
	self.params = params
	Init(self)
	return self
end

return {Create = Create}
