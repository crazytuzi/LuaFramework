-- -------------------------------
-- 诸神之战8强淘汰赛分组界面
-- hosr
-- -------------------------------
GodsWarFightFinalPanel = GodsWarFightFinalPanel or BaseClass(BasePanel)

function GodsWarFightFinalPanel:__init(parent)
    self.parent = parent
    self.effectPath = "prefabs/effect/20194.unity3d"
	self.resList = {
		{file = AssetConfig.godswarfightfinal, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
		{file = AssetConfig.guildleague_texture, type = AssetType.Dep},
        {file = self.effectPath, type = AssetType.Main},
	}
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.round1List = {}
    self.round2List = {}
    self.round3List = {}

    self.light1List = {}
    self.light2List = {}
    self.light3List = {}

    self.dataList = {}
    self.dataList1 = {}
    self.dataList2 = {}
    self.dataList3 = {}
    self.dataList4 = {}

    self.listener = function() self:Update(true) end
    self.selectListener = function(index) self:ChangeZone(index) end
    self.zone = 1
end

function GodsWarFightFinalPanel:__delete()
	EventMgr.Instance:RemoveListener(event_name.godswar_match_update, self.listener)
	EventMgr.Instance:RemoveListener(event_name.godswar_select_update, self.selectListener)
    for i,v in ipairs(self.round1List) do
        v:DeleteMe()
    end
    self.round1List = nil

    for i,v in ipairs(self.round2List) do
        v:DeleteMe()
    end
    self.round2List = nil

    for i,v in ipairs(self.round3List) do
        v:DeleteMe()
    end
    self.round3List = nil
end

function GodsWarFightFinalPanel:OnShow()
    self:UpdateMyGroup()
	self:ChangeZone(self.zone)
end

function GodsWarFightFinalPanel:OnHide()
end

function GodsWarFightFinalPanel:ClickLook()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_video, {type = 2, group = self.zone})
end

function GodsWarFightFinalPanel:ClickVideo()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_video, {type = 1, group = self.zone})
end

function GodsWarFightFinalPanel:ClickVote()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswar_vote, {zone = self.zone, dataList = self.dataList})
end

function GodsWarFightFinalPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarfightfinal))
    self.gameObject.name = "GodsWarFightFinalPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0, -25)

    self.transform:Find("Main/LookButton"):GetComponent(Button).onClick:AddListener(function() self:ClickLook() end)
    self.transform:Find("Main/VideoButton"):GetComponent(Button).onClick:AddListener(function() self:ClickVideo() end)
    self.transform:Find("Main/VoteButton"):GetComponent(Button).onClick:AddListener(function() self:ClickVote() end)

    self.campaionButton = self.transform:Find("Main/Right/1"):GetComponent(Button)
    self.secondButton = self.transform:Find("Main/Right/3"):GetComponent(Button)

    self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function() GodsWarManager.Instance.model:OpenSelect(1) end)
    self.buttonTxt = self.transform:Find("Main/Button/Text"):GetComponent(Text)

    self.tips = self.transform:Find("Main/Tips"):GetComponent(Text)
    self.tips.text = TI18N("规则说明:\n1.每次参与投票将消耗<color='#249015'>一叠选票</color>\n2.每次对<color='#249015'>即将开启</color>的比赛进行投票\n3.投票后<color='#249015'>无法修改</color>")

    local right = self.transform:Find("Main/Right")
    for i = 1, 8 do
        local effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    	local item = GodsWarFightElimintionItem.New(right:Find("Team1" .. i).gameObject, self, effect)
    	table.insert(self.round1List, item)
    end

    for i = 1, 4 do
        local effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    	local item = GodsWarFightElimintionItem.New(right:Find("Team2" .. i).gameObject, self, effect)
    	table.insert(self.round2List, item)
    end

    for i = 1, 4 do
        local effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    	local item = GodsWarFightElimintionItem.New(right:Find("Team3" .. i).gameObject, self, effect)
    	table.insert(self.round3List, item)
    end

    local light = right:Find("Light")
    for i = 1, 8 do
    	table.insert(self.light1List, light:Find("Team1" .. i).gameObject)
    end

    for i = 1, 4 do
    	table.insert(self.light2List, light:Find("Team2" .. i).gameObject)
    end

    for i = 1, 4 do
    	table.insert(self.light3List, light:Find("Team3" .. i).gameObject)
    end

    EventMgr.Instance:AddListener(event_name.godswar_match_update, self.listener)
	EventMgr.Instance:AddListener(event_name.godswar_select_update, self.selectListener)

    self.finalTxt = self.transform:Find("Main/Right/1/Text"):GetComponent(Text)
    self.thirdTxt = self.transform:Find("Main/Right/3/Text"):GetComponent(Text)
    self.finalTxt.text = TI18N("冠军")
    self.thirdTxt.text = TI18N("季军")

	self:OnShow()
end

function GodsWarFightFinalPanel:ChangeZone(zone)
	self.zone = zone
	self.buttonTxt.text = GodsWarEumn.GroupName(self.zone)
	self:Update()
end

function GodsWarFightFinalPanel:Update(isProto)
    self.finalTxt.text = TI18N("冠军")
    self.thirdTxt.text = TI18N("季军")
	local dataList = {}
    if not isProto and GodsWarEumn.IsFighting() then
        GodsWarManager.Instance:Send17925(self.zone)
    else
        dataList = GodsWarManager.Instance:GetElimintionData(self.zone) or {}
    end
    self.dataList = dataList
    self:FormatList(dataList)

    for i,item in ipairs(self.round1List) do
    	item:SetData(self.dataList1[i], true)
    end

    for i,item in ipairs(self.round2List) do
    	item:SetData(self.dataList2[i], true)
    end

    for i,item in ipairs(self.round3List) do
        if i <= 2 then
            item:SetData(self.dataList4[i], true)
        else
            item:SetData(self.dataList3[i - 2], true)
        end
    end

    self:UpdateProgress()
end

function GodsWarFightFinalPanel:FormatList(list)
    self.dataList1 = {}
    self.dataList2 = {}
    self.dataList3 = {}
    self.dataList4 = {}

    for i,v in ipairs(list) do
        if v.qualification >= GodsWarEumn.Quality.Q8 then
            local key = GodsWarEumn.GroupIndex(v.team_group_64)
            -- table.insert(self.dataList1, v)
            self.dataList1[key] = v
        end
        if v.qualification >= GodsWarEumn.Quality.Q4 then
            -- local key = math.ceil(i / 2)
            local key = GodsWarEumn.GroupIndex2(v.team_group_64)
            self.dataList2[key] = v
        end
        if v.qualification >= GodsWarEumn.Quality.ThirdPlace and v.qualification < GodsWarEumn.Quality.ChampionPlace then
            -- local key = math.ceil(i / 4)
            local key = GodsWarEumn.GroupIndex3(v.team_group_64)
            self.dataList3[key] = v
        end
        if v.qualification >= GodsWarEumn.Quality.ChampionPlace then
            -- local key = math.ceil(i / 4)
            local key = GodsWarEumn.GroupIndex3(v.team_group_64)
            self.dataList4[key] = v
        end
    end
end

function GodsWarFightFinalPanel:UpdateProgress()
	for i,v in ipairs(self.round1List) do
		if v.data == nil then
			self.light1List[i]:SetActive(false)
		else
			if v.data.qualification > GodsWarEumn.Quality.Q8 then
				self.light1List[i]:SetActive(true)
			else
				self.light1List[i]:SetActive(false)
			end
		end
	end

	for i,v in ipairs(self.round2List) do
		if v.data == nil then
			self.light2List[i]:SetActive(false)
		else
			if v.data.qualification >= GodsWarEumn.Quality.ChampionPlace then
				self.light2List[i]:SetActive(true)
			else
				self.light2List[i]:SetActive(false)
			end
		end
	end

	for i,v in ipairs(self.round3List) do
		if v.data == nil then
			self.light3List[i]:SetActive(false)
		else
			if i <= 2 then
                if v.data.qualification == GodsWarEumn.Quality.Champion then
                    self.light3List[i]:SetActive(true)
                    self.finalTxt.text = v.data.name
                    v:ChangeThirdShow(false)
                    self.campaionButton.onClick:RemoveAllListeners()
                    self.campaionButton.onClick:AddListener(function() GodsWarManager.Instance.model:OpenTeam(v.data) end)
                elseif v.data.qualification == GodsWarEumn.Quality.Second then
                    self.light3List[i]:SetActive(false)
                    v:ChangeThirdShow(true)
                else
                    v:ChangeThirdShow(false)
                    self.light3List[i]:SetActive(false)
                end
			elseif i >= 3 and v.data.qualification == GodsWarEumn.Quality.Third then
				self.light3List[i]:SetActive(true)
                self.thirdTxt.text = v.data.name
                self.secondButton.onClick:RemoveAllListeners()
                self.secondButton.onClick:AddListener(function() GodsWarManager.Instance.model:OpenTeam(v.data) end)
			else
				self.light3List[i]:SetActive(false)
			end
		end
	end
end

function GodsWarFightFinalPanel:UpdateMyGroup()
    local my = GodsWarManager.Instance.myData
    if my ~= nil and my.tid ~= 0 then
        -- self.zone = GodsWarEumn.Group(my.lev, my.break_times)
        self.zone = my.lev
    else
        self.zone = GodsWarEumn.Group(RoleManager.Instance.world_lev, RoleManager.Instance.RoleData.lev_break_times)
    end
    self.buttonTxt.text = GodsWarEumn.GroupName(self.zone)
end
