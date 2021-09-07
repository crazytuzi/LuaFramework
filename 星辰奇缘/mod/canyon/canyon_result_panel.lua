-- 峡谷之巅-结算
-- @author hze
-- @date 2018/08/01

CanyonResultPanel = CanyonResultPanel or BaseClass(BasePanel)
function CanyonResultPanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.canyon_result_panel, type = AssetType.Main}
		,{file = AssetConfig.canyonbig, type = AssetType.Dep}
		,{file = AssetConfig.guildleague_texture, type = AssetType.Dep}
		,{file = AssetConfig.hero_textures, type = AssetType.Dep}
	}
	self.OnOpenEvent:Add(function() self:OnOpen() end)
	self.OnHideEvent:Add(function() self:OnHide() end)

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

function CanyonResultPanel:__delete()
	self.OnHideEvent:Fire()
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function CanyonResultPanel:OnHide()

end

function CanyonResultPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.canyon_result_panel))
	self.gameObject.name = "CanyonResultPanel"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
	self.bgPanel = self.transform:Find("bgPanel")
	self.Main = self.transform:Find("Main")
	self.result = self.transform:Find("Main/result"):GetComponent(Image)
	self.IconL = self.transform:Find("Main/IconL"):GetComponent(Image)
	self.IconR = self.transform:Find("Main/IconR"):GetComponent(Image)
	self.LCrystal = self.transform:Find("Main/LCrystal")
	self.Lcry = {
		[1] = self.transform:Find("Main/LCrystal/bcry1"):GetComponent(Image),
		[2] = self.transform:Find("Main/LCrystal/bcry2"):GetComponent(Image),
		[3] = self.transform:Find("Main/LCrystal/bcry3"):GetComponent(Image)
	}
	self.RCrystal = self.transform:Find("Main/RCrystal")
	self.Rcry = {
		[1] = self.transform:Find("Main/RCrystal/bcry1"):GetComponent(Image),
		[2] = self.transform:Find("Main/RCrystal/bcry2"):GetComponent(Image),
		[3] = self.transform:Find("Main/RCrystal/bcry3"):GetComponent(Image)
	}
	self.Button = self.transform:Find("Main/Button"):GetComponent(Button)
	self.InfoButton = self.transform:Find("Main/InfoButton"):GetComponent(Button)
	self.Button.onClick:AddListener(function()
		self.model:CloseResultpanel()
		if CanYonManager.Instance.is_win == 1 then 
			local data = NoticeConfirmData.New()
	        data.type = ConfirmData.Style.Sure
	        data.content = TI18N("恭喜获得峡谷之巅胜利！<color='#ffff00'>胜利宝箱</color>预计一分钟后出现，请耐心等待<color='#ffff00'>胜利者</color>的奖励吧{face_1,3}")
	        data.sureLabel = TI18N("确定")
	        NoticeManager.Instance:ConfirmTips(data)
	    end
	end)
	self.InfoButton.onClick:AddListener(function()
		self.model:CloseResultpanel()
		self.model:OpenMemberFightInfoRankPanel()
	end)

	self.transform:Find("Main/bg"):GetComponent(Image).sprite = self.assetWrapper:GetTextures(AssetConfig.canyonbig , "GuildLeague2")
	self.transform:Find("Main/Title"):GetComponent(Image).sprite = self.assetWrapper:GetTextures(AssetConfig.canyonbig , "GuildLEague3")
	local sprite = self.assetWrapper:GetTextures(AssetConfig.canyonbig , "GuildLeague1")
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
end

function CanyonResultPanel:OnInitCompleted()
    self.assetWrapper:ClearMainAsset()
    self.OnOpenEvent:Fire()
end

function CanyonResultPanel:OnOpen()
    self:SetData()
end

function CanyonResultPanel:SetData()
	local data = CanYonManager.Instance.fightinfolist
	
	if IS_DEBUG then
		BaseUtils.dump(data,string.format( "结算数据---%s:",RoleManager.Instance.RoleData.name))
	end

	local fullmember = 0
	local fullwin = 0
	local fullcannon = 0
	local fulldefend = 0
	local selfremain = 0
	local otherremain = 0

	for k,v in pairs(data) do
		fullmember = fullmember + v.member_num
		fullwin = fullwin + v.win
		fullcannon = fullcannon + v.attacked_unit
		fulldefend = fulldefend + v.guarded_unit
		if CanYonManager.Instance.self_side == v.side_id then
			selfremain = v.remain_unit
		else
			otherremain = v.remain_unit
		end
	end

	local result = self.keytoresult[string.format("%s_%s", selfremain, otherremain)]
	if result == nil then 
		if CanYonManager.Instance.is_win == 1 then
			result = "win2" 
		elseif CanYonManager.Instance.is_win == 2 then 
			result = "lose2"
		end
	end


	self.RScore.gameObject:SetActive(false)
	self.LScore.gameObject:SetActive(false)
	
	self.result.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , result)
	
	for k,v in pairs(data) do
		if v.side_id == 1 then
			self.LName.text = CanYonEumn.CampNames[1]
			self.LNumText.text = string.format("%d/%d",v.remain_num,v.member_num)
			self.LNum.sizeDelta = Vector2(144*v.remain_num/v.member_num, 13)
			self.LWinText.text = tostring(v.win)
			self.LWin.sizeDelta = Vector2(144*v.win/fullwin, 13)
			self.LCannonText.text = tostring(v.attacked_unit)
			self.LCannon.sizeDelta = Vector2(144*v.attacked_unit/fullcannon, 13)
			self.LDefendText.text = tostring(v.guarded_unit)
			self.LTower.sizeDelta = Vector2(144*v.guarded_unit/fulldefend, 13)

			for i=1,3-v.remain_unit do
				self.Lcry[i].gameObject:SetActive(false)
			end
		else
			self.RName.text = CanYonEumn.CampNames[2]
			self.RNumText.text = string.format("%d/%d",v.remain_num,v.member_num)
			self.RNum.sizeDelta = Vector2(144*v.remain_num/v.member_num, 13)
			self.RWinText.text = tostring(v.win)
			self.RWin.sizeDelta = Vector2(144*v.win/fullwin, 13)
			self.RCannonText.text = tostring(v.attacked_unit)
			self.RCannon.sizeDelta = Vector2(144*v.attacked_unit/fullcannon, 13)
			self.RDefendText.text = tostring(v.guarded_unit)
			self.RTower.sizeDelta = Vector2(144*v.guarded_unit/fulldefend, 13)

			for i=1,3-v.remain_unit do
				self.Rcry[i].gameObject:SetActive(false)
			end
		end
	end
end