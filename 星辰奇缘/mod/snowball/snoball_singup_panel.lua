--作者:hzf
--12/27/2016 22:14:11
--功能:打雪仗匹配按钮

SnowBallSingupPanel = SnowBallSingupPanel or BaseClass(BasePanel)
function SnowBallSingupPanel:__init(parent)
	self.Mgr = SnowBallManager.Instance
	self.model = self.Mgr.model
	self.resList = {
		{file = AssetConfig.snowballsignup, type = AssetType.Main},
		{file = AssetConfig.snowballicon, type = AssetType.Dep},
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.OnUpdateListener = function()
		self:OnMatchChange()
	end
	self.OnResultListener = function()
		self:OnMatchChange()
	end
	self.begin_fight = function()
		self.gameObject:SetActive(false)
	end
	self.end_fight = function()
		self.gameObject:SetActive(true)
		-- body
	end
	self.startTime = 0
	self.hasInit = false
end

function SnowBallSingupPanel:__delete()
	EventMgr.Instance:RemoveListener(event_name.match_status_change, self.OnUpdateListener)
	EventMgr.Instance:RemoveListener(event_name.begin_fight, self.begin_fight)
	EventMgr.Instance:RemoveListener(event_name.end_fight, self.end_fight)
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function SnowBallSingupPanel:OnHide()
end

function SnowBallSingupPanel:OnOpen()

end

function SnowBallSingupPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.snowballsignup))
	self.gameObject.name = "SnowBallSingupPanel"

	self.transform = self.gameObject.transform
	self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3.zero
    self.gameObject.transform.localScale = Vector3.one
	self.Button = self.transform:Find("Button"):GetComponent(Button)
	self.start = self.transform:Find("Button/start")
	self.matching = self.transform:Find("Button/matching")
	self.Time = self.transform:Find("Time")
	self.Clock = self.transform:Find("Time/Clock")
	self.ClockText = self.transform:Find("Time/Text"):GetComponent(Text)
	self.InfoButton = self.transform:Find("InfoButton"):GetComponent(Button)

	self.Button.onClick:AddListener(function()
		self:OnButton()
	end)
	self.InfoButton.onClick:AddListener(function()
		self.model:OpenShowPanel()
	end)
	EventMgr.Instance:AddListener(event_name.match_status_change, self.OnUpdateListener)
	EventMgr.Instance:AddListener(event_name.begin_fight, self.begin_fight)
	EventMgr.Instance:AddListener(event_name.end_fight, self.end_fight)
	self:OnMatchChange()
	self.gameObject:SetActive(CombatManager.Instance.isFighting == false)
end

function SnowBallSingupPanel:OnButton()
	if MatchManager.Instance.status == MatchStatus.Normal then
		MatchManager.Instance:Require18303()
	elseif MatchManager.Instance.status == MatchStatus.Matching then
		self.Mgr.model:OpenMatchWindow()
		-- MatchManager.Instance:Require18304()
	end
end

function SnowBallSingupPanel:OnMatchChange()
	if MatchManager.Instance.status == MatchStatus.Normal then
		self:StopCountDown()
	elseif MatchManager.Instance.status == MatchStatus.Matching then
		self:StartCountDown()
		self.Mgr.model:OpenMatchWindow()
	elseif MatchManager.Instance.status == MatchStatus.Matchend then
		self.Mgr.model.match_time = Time.time + 5
	end
	self.start.gameObject:SetActive(MatchManager.Instance.status ~= MatchStatus.Matching)
	self.matching.gameObject:SetActive(MatchManager.Instance.status == MatchStatus.Matching)
	self.Time.gameObject:SetActive(MatchManager.Instance.status == MatchStatus.Matching)
end

function SnowBallSingupPanel:StartCountDown()
	self:StopCountDown()
	-- self.model.match_time = self.startTime
	self.startTime = self.model.match_time
	self.timer = LuaTimer.Add(0,1000, function()
		if BaseUtils.isnull(self.ClockText) then
			return
		end
		self.ClockText.text = BaseUtils.formate_time_gap(math.abs(Time.time - self.startTime), ":", 0, BaseUtils.time_formate.MIN)
	end)
	self.ClockText.gameObject:SetActive(true)
end

function SnowBallSingupPanel:StopCountDown()
	if self.timer ~= nil then
		LuaTimer.Delete(self.timer)
	end
	self.ClockText.gameObject:SetActive(false)
end

function SnowBallSingupPanel:OnResult()
	if MatchManager.Instance.matchResult ~= nil and MatchManager.Instance.matchResult.id == 1000 then
		self.Mgr.model:OpenMatchWindow()
	end
end