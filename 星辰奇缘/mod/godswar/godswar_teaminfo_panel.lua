-- ----------------------------
-- 诸神之战  战队信息面板
-- hosr
-- ----------------------------

GodsWarTeamInfoPanel = GodsWarTeamInfoPanel or BaseClass(BasePanel)

function GodsWarTeamInfoPanel:__init(parent)
    self.model = GodsWarManager.Instance.model
	self.parent = parent
    self.effectPath = "prefabs/effect/20009.unity3d"
    self.effect = nil

	self.resList = {
		{file = AssetConfig.godswarteaminfo, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
		{file = self.effectPath, type = AssetType.Main},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.itemList = {}
    self.currItem = nil
    self.editing = false
    self.effectPosList = {
    	Vector3(-226, 156, -80),
    	Vector3(0, 156, -80),
    	Vector3(226, 156, -80),
    	Vector3(-226, 70, -80),
    	Vector3(0, 70, -80),
    	Vector3(226, 70, -80),
    	Vector3(-226, -10, -80),
	}
end

function GodsWarTeamInfoPanel:__delete()
	for i,v in ipairs(self.itemList) do
		v:DeleteMe()
	end
	self.itemList = nil
end

function GodsWarTeamInfoPanel:OnShow()
	self:Update()
end

function GodsWarTeamInfoPanel:OnHide()
end

function GodsWarTeamInfoPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarteaminfo))
    self.gameObject.name = "GodsWarTeamInfoPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0, -20)

    self.title = self.transform:Find("Title/Name"):GetComponent(Text)
    self.titleRect = self.title.gameObject:GetComponent(RectTransform)

    self.rename = self.transform:Find("Title/Name/Button").gameObject
    self.rename:GetComponent(Button).onClick:AddListener(function() self.model:OpenRename() end)

    local container = self.transform:Find("Container")
    container:GetComponent(Button).onClick:AddListener(function() self:ClickContainer() end)
    local len = container.childCount
    for i = 1, len do
    	local item = GodsWarTeamInfoItem.New(container:GetChild(i - 1).gameObject, self, i)
    	table.insert(self.itemList, item)
    end

    self.quit = self.transform:Find("Info/QuitBtn")
    self.quitTxt = self.quit:Find("Text"):GetComponent(Text)
    self.quitImg = self.quit:GetComponent(Image)
    self.quit:GetComponent(Button).onClick:AddListener(function() self:ClickQuit() end)

    self.transform:Find("Info/Title1/Text"):GetComponent(Text).text = TI18N("战队口号")
    self.notice = self.transform:Find("Info/Title1/Button").gameObject
    self.notice:GetComponent(Button).onClick:AddListener(function() GodsWarManager.Instance.model:OpenNotice() end)

    self.tips = self.transform:Find("Tips").gameObject
	self.tips:SetActive(true)
    -- self.tips:GetComponent(Text).text = TI18N(""1.可任意选取<color='#ffff00'>5名成员组队</color>参加比赛\n2.正式比赛中，<color='#ffff00'>少于4人</color>的队伍将直接放弃资格"")

    self.desc = self.transform:Find("Info/Desc"):GetComponent(Text)

    self.status = self.transform:Find("Info/Status"):GetComponent(Text)
    self.point = self.transform:Find("Info/Point"):GetComponent(Text)

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect:SetActive(false)
    self.effect.name = "HoldEffect"
    self.effect.transform:SetParent(self.transform)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, 70, -80)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")

    self.gameObject:SetActive(true)

    self:OnShow()
end

function GodsWarTeamInfoPanel:Update()
	self.data = GodsWarManager.Instance.myData
	self.title.text = self.data.name
	self.desc.text = self.data.declaration

	self.titleRect.sizeDelta = Vector2(self.title.preferredWidth + 10, 30)
	self.titleRect.anchoredPosition = Vector2(40, 0)

	self:UpdateStatus()
	self:UpdateMember()
	self:UpdateButton()
end

function GodsWarTeamInfoPanel:UpdateStatus()
	local qualification = GodsWarManager.Instance.myData.qualification
	local status = GodsWarManager.Instance.status
	local team_group = GodsWarManager.Instance.myData.team_group_256

	print("qualification = " .. qualification)
	print("status = " .. status)

	local add = 0
	local plus = 0
	local str = "<color='#ff0000'>准备中</color>"
	if status < GodsWarEumn.Step.Publicity then
		-- if qualification == GodsWarEumn.Quality.Create then
		-- 	str = "<color='#ff0000'>未报名</color>"
		-- elseif qualification == GodsWarEumn.Quality.Sign then
		-- 	str = "<color='#00ff00'>已报名</color>"
		-- end
		str = "<color='#00ff00'>已报名</color>"
	elseif status == GodsWarEumn.Step.Publicity then
		if qualification <= GodsWarEumn.Quality.Sign then
			if team_group == 0 then
				str = "<color='#00ff00'>未入围</color>"
			else
				str = "<color='#00ff00'>小组赛</color>"
			end
		else
			str = "<color='#00ff00'>小组赛</color>"
		end
	elseif status > GodsWarEumn.Step.Publicity and qualification < GodsWarEumn.Quality.Q256 then
		str = "<color='#ff0000'>未入围</color>"
	elseif status > GodsWarEumn.Step.Publicity and status <= GodsWarEumn.Step.Audition7 and qualification == GodsWarEumn.Quality.Q256 then
		str = "<color='#00ff00'>小组赛</color>"
	elseif (status <= GodsWarEumn.Step.Elimination32 and qualification == GodsWarEumn.Quality.Q64) then
		str = "<color='#00ff00'>淘汰赛</color>"
	elseif (status <= GodsWarEumn.Step.Elimination16 and qualification == GodsWarEumn.Quality.Q32) then
		str = "<color='#00ff00'>淘汰赛</color>"
	elseif (status <= GodsWarEumn.Step.Elimination8 and qualification == GodsWarEumn.Quality.Q16) then
		str = "<color='#00ff00'>淘汰赛</color>"
	elseif (status <= GodsWarEumn.Step.Elimination4 and qualification == GodsWarEumn.Quality.Q8) then
		str = "<color='#00ff00'>淘汰赛</color>"
	elseif (status <= GodsWarEumn.Step.Semifinal and qualification == GodsWarEumn.Quality.Q4) then
		str = "<color='#00ff00'>淘汰赛</color>"
	elseif (status <= GodsWarEumn.Step.Thirdfinal and qualification == GodsWarEumn.Quality.ThirdPlace) then
		str = "<color='#00ff00'>淘汰赛</color>"
	elseif (status <= GodsWarEumn.Step.Final and qualification == GodsWarEumn.Quality.ChampionPlace) then
		str = "<color='#00ff00'>淘汰赛</color>"
	elseif status >= GodsWarEumn.Step.Final then
		if qualification == GodsWarEumn.Quality.Champion then
			str = "<color='#00ff00'>冠军</color>"
		elseif qualification == GodsWarEumn.Quality.Second then
			str = "<color='#00ff00'>亚军</color>"
		end
	elseif status >= GodsWarEumn.Step.Thirdfinal then
		if qualification == GodsWarEumn.Quality.Third then
			str = "<color='#00ff00'>季军</color>"
		elseif qualification == GodsWarEumn.Quality.Fourth then
			str = "<color='#00ff00'>殿军</color>"
		end
	else
		str = "<color='#ff0000'>已淘汰</color>"
		plus = 1
	end

	if qualification == GodsWarEumn.Quality.Q32 then
		add = 1
	elseif qualification == GodsWarEumn.Quality.Q16 then
		add = 2
	elseif qualification == GodsWarEumn.Quality.Q8 then
		add = 3
	elseif qualification == GodsWarEumn.Quality.Q4 then
		add = 4
	elseif qualification == GodsWarEumn.Quality.ThirdPlace then
		add = 4
		plus = 1
	elseif qualification == GodsWarEumn.Quality.ChampionPlace then
		add = 5
	elseif qualification == GodsWarEumn.Quality.Champion then
		add = 6
	elseif qualification == GodsWarEumn.Quality.Second then
		add = 5
		plus = 1
	elseif qualification == GodsWarEumn.Quality.Third then
		add = 5
		plus = 1
	elseif qualification == GodsWarEumn.Quality.Fourth then
		add = 4
		plus = 2
	end

	self.point.text = string.format(TI18N("战绩:<color='#00ff00'>%s胜%s负</color>"), self.data.win_times + add, self.data.loss_times + plus)
	self.status.text = string.format(TI18N("状态:%s"), str)

	if GodsWarManager.Instance:IsSelfCaptin() then
		self.notice:SetActive(true)
		if status >= GodsWarEumn.Step.Publicity then
			self.rename:SetActive(false)
		else
			self.rename:SetActive(true)
		end
	else
		self.notice:SetActive(false)
		self.rename:SetActive(false)
	end
end

function GodsWarTeamInfoPanel:UpdateMember()
	table.sort(self.data.members, function(a,b)
		if a.position == b.position then
			return a.tid < b.tid
		else
			return a.position < b.position
		end
	end)

	local count = 0
	for i = 1, 7 do
		local data = self.data.members[i]
		local item = self.itemList[i]
		item:SetData(data)
		item.gameObject:SetActive(true)
		count = count + 1
	end

	count = count + 1
	for i = count, #self.itemList do
		self.itemList[i].gameObject:SetActive(false)
	end

	if self.currItem == nil then
		self:Select(self.itemList[1])
	else
		self:Select(self.currItem)
	end
end

function GodsWarTeamInfoPanel:ClickQuit()
	local is04 = true
	if GodsWarManager.Instance:IsSelfCaptin() then
		if self.currItem ~= nil and not self.currItem.isSelf then
			is04 = false
		end
	end

    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.sureLabel = TI18N("确定")
    confirmData.cancelLabel = TI18N("取消")
	if is04 then
	    confirmData.sureCallback = function() GodsWarManager.Instance:Send17904() end
		if GodsWarManager.Instance:IsSelfCaptin() then
			confirmData.content = TI18N("您真的要解散战队么？我们舍不得呀{face_1,21}")
		else
			confirmData.content = TI18N("您真的要退出战队么？我们舍不得呀{face_1,21}")
		end
	else
		local d = self.currItem.data
	    confirmData.sureCallback = function() GodsWarManager.Instance:Send17909(d.tid, d.platform, d.zone_id) end
	    confirmData.content = string.format(TI18N("是否确认将<color='#ffff00'>%s</color>请离战队？"), d.name)
	end
	NoticeManager.Instance:ConfirmTips(confirmData)
end

function GodsWarTeamInfoPanel:Select(item)
	if self.currItem ~= nil then
		self.currItem:Select(false)
		if self.editing then
			local d1 = self.currItem.data
			local d2 = item.data
			if d1 ~= d2 and item.editing then
				GodsWarManager.Instance:Send17914(d1.tid, d1.platform, d1.zone_id, d2.tid, d2.platform, d2.zone_id)
			end
			self:QuitEditorMode()
		end
	end
	self.currItem = item
	self.currItem:Select(true)

	-- 队长才能操作
	if GodsWarManager.Instance:IsSelfCaptin() then
		self:UpdateButton()
	end
end

function GodsWarTeamInfoPanel:UpdateButton()
	if self.currItem == nil then
		return
	end

	if GodsWarManager.Instance:IsSelfCaptin() then
		if self.currItem.isSelf then
			self.quitTxt.text = TI18N("解散战队")
		else
			self.quitTxt.text = TI18N("请离战队")
		end
	else
		self.quitTxt.text = TI18N("离开战队")
	end
end

function GodsWarTeamInfoPanel:Down(item)
	if not GodsWarManager.Instance:IsSelfCaptin() and not item.isSelf then
		return
	end

	local func = function()
		if self.effect ~= nil then
			self.effect:SetActive(true)
			self.effect.transform.localPosition = self.effectPosList[item.index]
		end
	end

	if self.effectTime ~= nil then
		LuaTimer.Delete(self.effectTime)
		self.effectTime = nil
	end
	self.effectTime = LuaTimer.Add(200, func)
end

function GodsWarTeamInfoPanel:Up(item)
	if not GodsWarManager.Instance:IsSelfCaptin() and not item.isSelf then
		return
	end

	if self.effectTime ~= nil then
		LuaTimer.Delete(self.effectTime)
		self.effectTime = nil
	end

	if self.effect ~= nil then
		self.effect:SetActive(false)
	end
end

function GodsWarTeamInfoPanel:Hold(item)
	if not GodsWarManager.Instance:IsSelfCaptin() and not item.isSelf then
		return
	end

	if self.effect ~= nil then
		self.effect:SetActive(false)
	end

	self:EnterEditorMode()
end

-- 编辑模式
function GodsWarTeamInfoPanel:EnterEditorMode()
	self.editing = true
	for i,v in ipairs(self.itemList) do
		if v.data ~= nil and v.data.position ~= self.currItem.data.position and v.data.position ~= 1 then
			v:EnterEditor()
		end
	end
end

function GodsWarTeamInfoPanel:QuitEditorMode()
	self.editing = false
	for i,v in ipairs(self.itemList) do
		v:QuitEditor()
	end
end

function GodsWarTeamInfoPanel:ClickContainer()
	if GodsWarManager.Instance:IsSelfCaptin() and self.editing then
		self:QuitEditorMode()
	end
end