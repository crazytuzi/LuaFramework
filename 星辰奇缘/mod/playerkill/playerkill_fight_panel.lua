-- -------------------------------
-- 英雄擂台对战界面
-- hosr
-- -------------------------------

PlayerkillFightPanel = PlayerkillFightPanel or BaseClass(BasePanel)

function PlayerkillFightPanel:__init(parent)
	self.parent = parent
	self.effectStarFlyInPath = string.format(AssetConfig.effect, 20313)
	self.effectStarFlyOutPath = string.format(AssetConfig.effect, 20314)
	self.effectFlagPath = string.format(AssetConfig.effect, 20315)
	self.effect3WinPath = string.format(AssetConfig.effect, 20316)
	self.effectUpgradePath = string.format(AssetConfig.effect, 20317)
	self.effectMatchingPath = string.format(AssetConfig.effect, 20318)

	self.resList = {
		{file = AssetConfig.playerkillfight, type = AssetType.Main},
		{file = AssetConfig.playerkilltexture, type = AssetType.Dep},
		{file = AssetConfig.playkillicon, type = AssetType.Dep},
		{file = AssetConfig.playkillbgcycle, type = AssetType.Dep},
		{file = AssetConfig.playkillbgflag, type = AssetType.Dep},
		{file = AssetConfig.wingsbookbg, type = AssetType.Dep},
		{file = self.effectStarFlyInPath, type = AssetType.Dep},
		{file = self.effectStarFlyOutPath, type = AssetType.Dep},
		{file = self.effectFlagPath, type = AssetType.Dep},
		{file = self.effect3WinPath, type = AssetType.Dep},
		{file = self.effectUpgradePath, type = AssetType.Dep},
		{file = self.effectMatchingPath, type = AssetType.Dep},
        {file = AssetConfig.rolebgstand, type = AssetType.Dep},
	}
    self.isshow = false
    self.isfirst = true

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

	self.starsList = {}
	self.winList = {}

	self.matchPanel = nil

	-- 倒计时计数
	self.count = 0

	self.matchShowListener = function() self:MatchShow() end
	self.matchCancelListener = function() self:MatchCancel() end
	self.matchSuccessListener = function() self:MatchSuccess() end
	self.dataListener = function() self:Update() end
	self.statusListener = function() self:UpdateBtn() end

	self.beginFight = function() self:OnBeginFight() end

end

function PlayerkillFightPanel:__delete()
	self:OnHide()
	self:EndTime()

	if self.starsList ~= nil then
		for i,v in ipairs(self.starsList) do
			v:DeleteMe()
		end
		self.starsList = {}
	end

	if self.winList ~= nil then
		for i,v in ipairs(self.winList) do
			v:DeleteMe()
		end
		self.winList = {}
	end

	if self.GiftPreview ~= nil then
		self.GiftPreview:DeleteMe()
		self.GiftPreview = nil
	end

	if self.previewComp ~= nil then
		self.previewComp:DeleteMe()
		self.previewComp = nil
	end

	if self.cycleIcon ~= nil then
		self.cycleIcon.sprite = nil
		self.cycleIcon = nil
	end

	if self.matchPanel ~= nil then
		self.matchPanel:DeleteMe()
		self.matchPanel = nil
	end

	EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFight)
    PlayerkillManager.Instance.OnMatchShow:Remove(self.matchShowListener)
    PlayerkillManager.Instance.OnMatchCancel:Remove(self.matchCancelListener)
    PlayerkillManager.Instance.OnMatchSuccess:Remove(self.matchSuccessListener)
    PlayerkillManager.Instance.OnDataUpdate:Remove(self.dataListener)
    PlayerkillManager.Instance.OnStatusUpdate:Remove(self.statusListener)
end

function PlayerkillFightPanel:OnShow()
    self.isshow = true
	self:Update()
end

function PlayerkillFightPanel:OnHide()
	PlayerkillManager.Instance.currData = BaseUtils.copytab(self.baseData)

	if self.data ~= nil then 
		PlayerkillManager.Instance.curr_lev = self.data.rank_lev
		PlayerkillManager.Instance.curr_star = self.data.star
	end

	self.isshow = false
    if self.shakeID ~= nil then
        Tween.Instance:Cancel(self.shakeID)
        self.shakeID = nil
    end
    local status = PlayerkillManager.Instance.matchStatus
    if not self.parent.ishow and status == PlayerkillEumn.MatchStatus.Matching then
        PlayerkillManager.Instance:Send19302()
    end
	if self.effectMatching ~= nil then
		self.effectMatching:SetActive(false)
	end
	if self.effectStarFly ~= nil then
		self.effectStarFly:SetActive(false)
	end
	if self.effectUpgrade ~= nil then
		self.effectUpgrade:SetActive(false)
	end

	if self.showEffect1 ~= nil then
		self.showEffect1:DeleteMe()
		self.showEffect1 = nil
	end

	if self.showEffect2 ~= nil then
		self.showEffect2:DeleteMe()
		self.showEffect2 = nil
	end

	if self.showEffect3 ~= nil then
		self.showEffect3:DeleteMe()
		self.showEffect3 = nil
	end

	if self.showEffect4 ~= nil then
		self.showEffect4:DeleteMe()
		self.showEffect4 = nil
	end
	if self.showEffect5 ~= nil then
		self.showEffect5:DeleteMe()
		self.showEffect5 = nil
	end
end

function PlayerkillFightPanel:InitPanel()
    self.isshow = true
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.playerkillfight))
    self.gameObject.name = "PlayerkillFightPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.main)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.rewardObj = self.transform:Find("Reward").gameObject
    self.rewardTime = self.transform:Find("Reward/Time"):GetComponent(Text)
    self.transform:Find("Reward/Name/Text"):GetComponent(Text).text = TI18N("晋级宝箱")
    self.preview = self.transform:Find("Reward/Preview").gameObject
    self.transform:Find("Reward/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.transform:Find("Reward/Preview"):GetComponent(Button).onClick:AddListener(function() self:ShowReward() end)
    self.redPoint = self.transform:Find("Reward/Name/Red").gameObject

    self.cycleObj = self.transform:Find("Cycle").gameObject
    self.cycleTitle = self.transform:Find("Cycle/Title/Text"):GetComponent(Text)
    self.cycleName = self.transform:Find("Cycle/Name/Text"):GetComponent(Text)
    self.cycleIcon = self.transform:Find("Cycle/Icon"):GetComponent(Image)
    self.cycleIconObj = self.cycleIcon.gameObject
    self.transform:Find("Cycle/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.playkillbgcycle, "PlayKillBgCycle")
    self.transform:Find("Flag"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.playkillbgflag, "PlayKillBgFlag")

    self.statusObj = self.transform:Find("Cycle/Status").gameObject
    self.statusTxt = self.statusObj:GetComponent(Text)
    self.timeObj = self.transform:Find("Cycle/Time").gameObject
    self.timeTxt = self.timeObj:GetComponent(Text)

    local stars = self.transform:Find("Cycle/Stars")
    for i = 1, 5 do
    	local item = PlayerkillStarItem.New(stars:GetChild(i - 1), self)
    	local index = i
    	item.index = index
    	table.insert(self.starsList, item)
    end
    self.starsObj = stars.gameObject
    self.starSingleObj = self.transform:Find("Cycle/StarSingle").gameObject
    self.starSingleVal = self.transform:Find("Cycle/StarSingle/Val"):GetComponent(Text)

    local flag = self.transform:Find("Flag")
    self.flagObj = flag.gameObject
    self.flagTitle = flag:Find("Title"):GetComponent(Text)
    self.flagDesc = flag:Find("Desc"):GetComponent(Text)
    -- self.flagDesc.text = TI18N("连续取得3场胜利可额外获得1")
    local wins = flag:Find("Scroe")
    self.winsObj = wins.gameObject
    for i = 1, 3 do
    	local item = PlayerkillWinItem.New(wins:GetChild(i - 1), self)
    	table.insert(self.winList, item)
    end
    self.rankTxt = flag:Find("Score"):GetComponent(Text)
    self.rankTxtObj = self.rankTxt.gameObject

    local score = self.transform:Find("Score")
    self.currRate = score:Find("Win1"):GetComponent(Text)
    self.allRate = score:Find("Win2"):GetComponent(Text)
    self.currCount = score:Find("Count1"):GetComponent(Text)
    self.allCount = score:Find("Count2"):GetComponent(Text)
    self.currMax = score:Find("Max1"):GetComponent(Text)
    self.allMax = score:Find("Max2"):GetComponent(Text)
    self.scoreText2 = score:Find("Text2"):GetComponent(Text)
    self.scoreText2.text = TI18N("上赛季")

    local desc = self.transform:Find("Desc")
    desc:Find("Text"):GetComponent(Text).text = TI18N("活动开放时间：")
    self.descContent = desc:Find("Content"):GetComponent(Text)
    self.descContent.text = TI18N("每周二、四、六\n<color='#ffff00'>17:00~17:30、19:00~19:30</color>两场\n匹配次数最多累积8次")
    self.descTimes = desc:Find("Times"):GetComponent(Text)
    self.button = desc:Find("Button").gameObject
    self.button:GetComponent(Button).onClick:AddListener(function() self:ClickMatch() end)
    self.buttonTxt = desc:Find("Button/Text"):GetComponent(Text)
    self.buttonIcon = desc:Find("Button/Image").gameObject

    self.GiftPreview = GiftPreview.New(self.transform.parent.parent.gameObject)
    self.matchPanel = PlayerkillMatchShow.New(self.transform:Find("PlaykillMatchPanel").gameObject, self)
    self.transform:Find("PlaykillMatchPanel/Item1/Bg2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgstand, "RoleStandBottom")
    self.transform:Find("PlaykillMatchPanel/Item2/Bg2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgstand, "RoleStandBottom")

    PlayerkillManager.Instance.OnMatchShow:Add(self.matchShowListener)
    PlayerkillManager.Instance.OnMatchCancel:Add(self.matchCancelListener)
    PlayerkillManager.Instance.OnMatchSuccess:Add(self.matchSuccessListener)
    PlayerkillManager.Instance.OnDataUpdate:Add(self.dataListener)
    PlayerkillManager.Instance.OnStatusUpdate:Add(self.statusListener)

    self.effectStarFly = GameObject.Instantiate(self:GetPrefab(self.effectStarFlyInPath))
    self.effectStarFly.transform:SetParent(stars.transform)
    Utils.ChangeLayersRecursively(self.effectStarFly.transform, "UI")
    self.effectStarFly.transform.localScale = Vector3.one
    self.effectStarFly.transform.localPosition = Vector3(115, 54, -400)
    self.effectStarFly:SetActive(false)

    self.effectUpgrade = GameObject.Instantiate(self:GetPrefab(self.effectUpgradePath))
    self.effectUpgrade.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effectUpgrade.transform, "UI")
    self.effectUpgrade.transform.localScale = Vector3.one
    self.effectUpgrade.transform.localPosition = Vector3(0, 57, -400)
    self.effectUpgrade:SetActive(false)

    self.effectMatching = GameObject.Instantiate(self:GetPrefab(self.effectMatchingPath))
    self.effectMatching.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effectMatching.transform, "UI")
    self.effectMatching.transform.localScale = Vector3.one
    self.effectMatching.transform.localPosition = Vector3(235, 95, -400)
    self.effectMatching:SetActive(false)
    self:OnShow()
end

function PlayerkillFightPanel:Update()
	if not self.isshow then
		self:UpdateStatus()
		return
	end

	self.data = PlayerkillManager.Instance.myData
	if self.data == nil then return end
    self:ShakeIcon()
	if self.data.season_join_times == 0 then
		self.currRate.text = "--"
	else
		local rate = math.ceil((self.data.season_win_times / self.data.season_join_times) * 100)
		self.currRate.text = string.format("%s%%", rate)
	end
	if self.data.last_join_times == 0 then
		self.allRate.text = "--"
	else
		local allRate = math.ceil((self.data.last_win_times / self.data.last_join_times) * 100)
		self.allRate.text = string.format("%s%%", allRate)
	end
	self.currCount.text = tostring(self.data.season_join_times)
	self.allCount.text = tostring(self.data.last_join_times)
	self.currMax.text = tostring(self.data.season_lasted_win)
	self.allMax.text = tostring(self.data.last_lasted_win)

	self.descTimes.text = string.format(TI18N("剩余次数:<color='#ffff9a'>%s/%s</color>"), self.data.max_joins - self.data.join_times, self.data.max_joins)

	self:UpdateBtn()

	self.baseData = DataRencounter.data_info[self.data.rank_lev]
	if self.baseData == nil then
		self.cycleTitle.text = TI18N("未知")
		self.cycleName.text = TI18N("未知")
	else
		self.cycleTitle.text = string.format(TI18N("%s%s（%s阶）"), self.baseData.rencounter, self.baseData.title, self.data.rank_lev)
		self.cycleName.text = string.format(TI18N("%s擂台"), PlayerkillEumn.LevName[self.data.rank_lev])
	end

	self.rewardTime.text = PlayerkillEumn.GetTime()

	if self.isfirst then
		self.isfirst = false
		-- 初始化
		if PlayerkillManager.Instance.currData == nil then
			PlayerkillManager.Instance.currData = BaseUtils.copytab(self.baseData)
		end
		if PlayerkillManager.Instance.curr_lev == nil then
			PlayerkillManager.Instance.curr_lev = self.data.rank_lev
		end
		if PlayerkillManager.Instance.curr_star == nil then
			PlayerkillManager.Instance.curr_star = self.data.star
		end

		self:UpdataFlag()
		self:UpdateCycle()
		self:UpdateStar()
		self:UpdateStatus()
		self:UpdatePreview()

		self:Update()
	else
		if PlayerkillManager.Instance.curr_lev == 0 or PlayerkillManager.Instance.curr_lev == nil then
			PlayerkillManager.Instance.currData = BaseUtils.copytab(self.baseData)
			PlayerkillManager.Instance.curr_lev = self.data.rank_lev
			PlayerkillManager.Instance.curr_star = self.data.star

			self:UpdataFlag()
			self:UpdateCycle()
			self:UpdateStar()
			self:UpdateStatus()
			self:UpdatePreview()
		else
			if PlayerkillManager.Instance.curr_lev < self.data.rank_lev then
				if self.data.star == 1 then
					-- 进阶后，3连胜加星
					self:UpdataFlag(true)
					self:ShowEffect1()
				elseif self.data.star == 0 then
					-- 加星,3连胜，进阶
					if self:Is3Win() then
						self:UpdataFlag(true)
						self:ShowEffect2()
					else
						self:ShowEffect5()
					end
				end
			elseif PlayerkillManager.Instance.curr_lev == self.data.rank_lev then
				local change = self.data.star - PlayerkillManager.Instance.curr_star
				if change == 1 then
					-- 加星
					self:ShowEffect3()
				elseif change == 2 then
					-- 加星,3连胜,加星
					self:UpdataFlag(true)
					self:ShowEffect4()
				else
					PlayerkillManager.Instance.currData = BaseUtils.copytab(self.baseData)
					PlayerkillManager.Instance.curr_lev = self.data.rank_lev
					PlayerkillManager.Instance.curr_star = self.data.star

					self:UpdataFlag()
					self:UpdateCycle()
					self:UpdateStar()
					self:UpdateStatus()
					self:UpdatePreview()
				end
			else
				PlayerkillManager.Instance.currData = BaseUtils.copytab(self.baseData)
				PlayerkillManager.Instance.curr_lev = self.data.rank_lev
				PlayerkillManager.Instance.curr_star = self.data.star

				self:UpdataFlag()
				self:UpdateCycle()
				self:UpdateStar()
				self:UpdateStatus()
				self:UpdatePreview()
			end
		end
	end
end

function PlayerkillFightPanel:UpdateAllAfterShow()
	PlayerkillManager.Instance.currData = BaseUtils.copytab(self.baseData)
	PlayerkillManager.Instance.curr_lev = self.data.rank_lev
	PlayerkillManager.Instance.curr_star = self.data.star

	if self.showEffect1 ~= nil then
		self.showEffect1:DeleteMe()
		self.showEffect1 = nil
	end

	if self.showEffect2 ~= nil then
		self.showEffect2:DeleteMe()
		self.showEffect2 = nil
	end

	if self.showEffect3 ~= nil then
		self.showEffect3:DeleteMe()
		self.showEffect3 = nil
	end

	if self.showEffect4 ~= nil then
		self.showEffect4:DeleteMe()
		self.showEffect4 = nil
	end

	if self.showEffect5 ~= nil then
		self.showEffect5:DeleteMe()
		self.showEffect5 = nil
	end

	self:UpdataFlag()
	self:UpdateCycle()
	self:UpdateStatus()
	self:UpdateStar(true)
	self:UpdatePreview()
end

function PlayerkillFightPanel:UpdateCycle()
	self.cycleIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.playkillicon, string.format("Lev%s", PlayerkillManager.Instance.curr_lev))
end

function PlayerkillFightPanel:UpdataFlag(is3Win)
	if PlayerkillManager.Instance.curr_lev == 6 then
		self.flagTitle.text = TI18N("神殿排名")
		self.winsObj:SetActive(false)
		self.rankTxtObj:SetActive(true)
		if self.data.rank > 100 then
			self.rankTxt.text = "100+"
		else
			self.rankTxt.text = self.data.rank
		end
	else
		self.winsObj:SetActive(true)
		self.rankTxtObj:SetActive(false)
		local val = self.data.win_lasted_times % 3
		if is3Win then
			val = 3
		end
        self.flagTitle.text = string.format(TI18N("连胜场次:<color='#ffff9a'>(%s/3)</color>"), val)
		for i,v in ipairs(self.winList) do
			if i <= val then
				v:LightUp(true)
			else
				v:LightUp(false)
			end
		end
	end
end

function PlayerkillFightPanel:UpdateStar(isAll)
	if self.data.rank_lev == 6 then
		self.starsObj:SetActive(false)
		self.starSingleObj:SetActive(true)
		self.starSingleVal.text = string.format("x%s", PlayerkillManager.Instance.curr_star)
	else
		local star = PlayerkillManager.Instance.currData.star - 1
		self.starsObj:SetActive(true)
		self.starSingleObj:SetActive(false)
		local posList = PlayerkillEumn.StarPos[star]
		for i,v in ipairs(self.starsList) do
			local pos = posList[i]
			if pos == nil then
				v.gameObject:SetActive(false)
			else
				v:SetPos(pos)
                v.gameObject:SetActive(true)
            end

            if i <= PlayerkillManager.Instance.curr_star then
                v:LightUp(true, isAll)
			else
				v:LightUp(false, isAll)
			end
		end
	end
end

-- 表现辅助用
function PlayerkillFightPanel:UpdateStarNoLightUp()
	if self.data.rank_lev == 6 then
		self.starsObj:SetActive(false)
		self.starSingleObj:SetActive(true)
		self.starSingleVal.text = string.format("x%s", self.data.star)
	else
		local star = self.baseData.star - 1
		self.starsObj:SetActive(true)
		self.starSingleObj:SetActive(false)
		local posList = PlayerkillEumn.StarPos[star]
		for i,v in ipairs(self.starsList) do
			v:LightUp(false, true)
			local pos = posList[i]
			if pos == nil then
				v.gameObject:SetActive(false)
			else
				v:SetPos(pos)
                v.gameObject:SetActive(true)
            end
		end
	end
end

function PlayerkillFightPanel:ClickMatch()
	local status = PlayerkillManager.Instance.matchStatus
    if status == PlayerkillEumn.MatchStatus.Matching then
    	PlayerkillManager.Instance:Send19302()
    else
    	PlayerkillManager.Instance:Send19301()
    end
end

function PlayerkillFightPanel:MatchShow()
	self:UpdateStatus()
end

function PlayerkillFightPanel:MatchCancel()
	self:UpdateStatus()
end

function PlayerkillFightPanel:MatchSuccess()
	self:UpdateStatus()
end

function PlayerkillFightPanel:UpdateBtn()
	if PlayerkillManager.Instance.status ~= PlayerkillEumn.Status.Running then
		local hour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
		if hour < 17 then
			self.buttonTxt.text = TI18N("17:00开启")
		elseif hour < 19 then
			self.buttonTxt.text = TI18N("19:00开启")
		else
			self.buttonTxt.text = TI18N("未开启")
		end
        self.buttonIcon:SetActive(false)
        self.buttonTxt.gameObject.transform.anchoredPosition3D = Vector2(0, 0, 0)
    else
        self.buttonIcon:SetActive(true)
		self.buttonTxt.gameObject.transform.anchoredPosition3D = Vector2(14, 0, 0)
		self.buttonTxt.text = TI18N("开始匹配")
	end
end

function PlayerkillFightPanel:UpdateStatus()
	local status = PlayerkillManager.Instance.matchStatus
    if status == PlayerkillEumn.MatchStatus.None then
		self.rewardObj:SetActive(true)
		self.flagObj:SetActive(true)
		self.effectMatching:SetActive(false)
		if self.data.rank_lev == 6 then
			self.starSingleObj:SetActive(true)
			self.starSingleVal.text = string.format("x%s", self.data.star)
		else
			self.starsObj:SetActive(true)
		end
		if self.matchPanel ~= nil then
			self.matchPanel:Cancel()
		end
    	self.statusObj:SetActive(false)
    	self.timeObj:SetActive(false)
    	self:EndTime()
    	self:UpdateBtn()
    	if self.matchPanel ~= nil then
    		self.matchPanel:Hide()
    	end
    elseif status == PlayerkillEumn.MatchStatus.Matching then
		self.rewardObj:SetActive(false)
		self.flagObj:SetActive(false)
		self.starsObj:SetActive(false)
		self.starSingleObj:SetActive(false)
		self.effectMatching:SetActive(true)
		if self.matchPanel ~= nil then
			self.matchPanel:Show()
		end
    	self.statusObj:SetActive(true)
    	self.timeObj:SetActive(true)
    	self.statusTxt.text = TI18N("匹配中")
    	-- 匹配时间
    	self.timeTxt.text = "<color='#ffff9a'>00:00</color>"
    	self.buttonTxt.text = TI18N("取消匹配")
    	self:MatchTime()
    elseif status == PlayerkillEumn.MatchStatus.MatchSuccess then
		self.rewardObj:SetActive(false)
		self.flagObj:SetActive(false)
		self.starsObj:SetActive(false)
		self.starSingleObj:SetActive(false)
		self.effectMatching:SetActive(false)
		if self.matchPanel ~= nil then
			self.matchPanel:Success()
		end
    	self.statusObj:SetActive(true)
    	self.timeObj:SetActive(true)
    	self.statusTxt.text = TI18N("匹配成功")
    	self.buttonTxt.text = TI18N("匹配成功")
    	-- 倒计时5秒
    	self.timeTxt.text = "<color='#ffff9a'>5</color>"
    	self:BeginTime()
    end
end

-- 匹配时间
function PlayerkillFightPanel:MatchTime()
	EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFight)
	self:EndTime()
	self.timeId = LuaTimer.Add(0, 1000, function() self:LoopTimeMatch() end)
end

-- 开始倒计时
function PlayerkillFightPanel:BeginTime()
	self:EndTime()
	self.count = 5
	self.timeId = LuaTimer.Add(0, 1000, function() self:LoopTimeBegin() end)
end

function PlayerkillFightPanel:LoopTimeMatch()
	local seconds = math.floor(os.time() - PlayerkillManager.Instance.matchStartTime)
	self.timeTxt.text = string.format("<color='#ffff9a'>%s</color>", BaseUtils.formate_time_gap(seconds, ":", 0, BaseUtils.time_formate.MIN))
end

function PlayerkillFightPanel:LoopTimeBegin()
	if self.count < 0 then
		self:EndTime()
		PlayerkillManager.Instance.matchStatus = PlayerkillEumn.MatchStatus.None
		self:UpdateStatus()
		return
	end
	self.timeTxt.text = string.format("<color='#ffff9a'>%s</color>", tostring(self.count))
    self.timeTxt.gameObject.transform.localScale = Vector3.one*4
    Tween.Instance:Scale(self.timeTxt.gameObject, Vector3(1,1,1), 0.7, function() end, LeanTweenType.easeOutElastic)
	self.count = self.count - 1
end

function PlayerkillFightPanel:EndTime()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end

function PlayerkillFightPanel:OnBeginFight()
	EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFight)
	self:EndTime()
	PlayerkillManager.Instance.matchStatus = PlayerkillEumn.MatchStatus.None
	self.parent:Close()
end

function PlayerkillFightPanel:UpdatePreview()
	self.redPoint:SetActive(self:CanGetReward())

	local group = PlayerkillEumn.GetSelfGroup()
    local reward = DataRencounter.data_reward[string.format("%s_%s", group, self.data.rank_lev+1)]
    local nonext = false
    if reward == nil then
        nonext = true
        reward = DataRencounter.data_reward[string.format("%s_%s", group, self.data.rank_lev)]
    end

    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "PlayerkillFight"
        ,orthographicSize = 0.3
        ,width = 200
        ,height = 200
        ,offsetY = -0.15
        ,noDrag = true
    }
    local baseData = DataUnit.data_unit[reward.model_baseid]
    local modelData = {type = PreViewType.Npc, skinId = baseData.skin, modelId = baseData.res, animationId = baseData.animation_id, scale = 1}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function PlayerkillFightPanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.identity
    composite.tpose.transform:Rotate(Vector3(352, 37, 355))
    local Transition = rawImage.transform:GetComponent(TransitionButton) or rawImage:AddComponent(TransitionButton)
    local btn = rawImage.transform:GetComponent(Button) or rawImage:AddComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() self:ShowReward() end)
    self.preview:SetActive(true)
end

function PlayerkillFightPanel:CanGetReward()
	local can = false
	if self.data.has_get_rank < self.data.rank_lev then
		can = true
	end
	return can
end

function PlayerkillFightPanel:ShowReward()
	local group = PlayerkillEumn.GetSelfGroup()
    local nextreward = DataRencounter.data_reward[string.format("%s_%s", group, self.data.rank_lev + 1)]
    local nextBaseData = DataRencounter.data_info[self.data.rank_lev + 1]
    local reward = DataRencounter.data_reward[string.format("%s_%s", group, self.data.rank_lev)]
    if self:CanGetReward() then
        PlayerkillManager.Instance.model:OpenReward(reward)
    else
        if nextreward == nil then
            nextreward = DataRencounter.data_reward[string.format("%s_%s", group, self.data.rank_lev)]
            NoticeManager.Instance:FloatTipsByString(TI18N("你已领取了全部晋级宝箱"))
            return
        end

	    local name = string.format("%s-%s", nextBaseData.rencounter, nextBaseData.title)
	    self.GiftPreview:Show({reward = nextreward.stage_item, text = string.format(TI18N("首次晋级<color='#00ff00'>%s</color>奖励"), name), autoMain = true})
	end
end

function PlayerkillFightPanel:ShakeIcon()
    if self.shakeID == nil then
        self.cycleIconObj.transform.anchoredPosition3D = Vector3(0, -18, 0)
        self.shakeID = Tween.Instance:MoveLocalY(self.cycleIconObj, -8, 1.5, nil, LeanTweenType.linear):setLoopPingPong().id
    end
end

-- 是否3连胜
function PlayerkillFightPanel:Is3Win()
	if PlayerkillManager.Instance.curr_lev < 6 and self.data.win_lasted_times > 0 and self.data.win_lasted_times % 3 == 0 then
		return true
	end
	return false
end

-- 是否添加星星
function PlayerkillFightPanel:IsAddStar()
	if PlayerkillManager.Instance.curr_star ~= 0 and PlayerkillManager.Instance.curr_star < self.data.star then
		return true
	end
	return false
end

-- 是否进阶
function PlayerkillFightPanel:IsUpgrade()
	if PlayerkillManager.Instance.curr_lev ~= 0 and PlayerkillManager.Instance.curr_lev < self.data.rank_lev then
		return true
	end
	return false
end

function PlayerkillFightPanel:ShowEffect1()
	if self.showEffect1 == nil then
		self.showEffect1 = PlayerkillEffectShow1.New(self)
	end
	self.showEffect1:Show()
end

function PlayerkillFightPanel:ShowEffect2()
	if self.showEffect2 == nil then
		self.showEffect2 = PlayerkillEffectShow2.New(self)
	end
	self.showEffect2:Show()
end

function PlayerkillFightPanel:ShowEffect3()
	if self.showEffect3 == nil then
		self.showEffect3 = PlayerkillEffectShow3.New(self)
	end
	self.showEffect3:Show()
end

function PlayerkillFightPanel:ShowEffect4()
	if self.showEffect4 == nil then
		self.showEffect4 = PlayerkillEffectShow4.New(self)
	end
	self.showEffect4:Show()
end

function PlayerkillFightPanel:ShowEffect5()
	if self.showEffect5 == nil then
		self.showEffect5 = PlayerkillEffectShow5.New(self)
	end
	self.showEffect5:Show()
end