local CTravelGameView = class("CTravelGameView", CViewBase)

CTravelGameView.Status = {	
	Stop = 0,
	Watch = 1,
	Start = 2,
}

CTravelGameView.Card = {
	Hide = 0, --反面
	Show = 1, --正面
}

CTravelGameView.GridCount = 16 --个字总数

function CTravelGameView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Travel/TravelGameView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Shelter"
end

function CTravelGameView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_CountLabel = self:NewUI(3, CLabel)
	self.m_TravelHelpBtn = self:NewUI(4, CButton)
	self.m_CardGrid = self:NewUI(5, CGrid)
	self.m_CardBox = self:NewUI(6, CBox)
	self.m_LeftLabel = self:NewUI(7, CLabel)
	self.m_LeftTimeLabel = self:NewUI(8, CLabel)
	self.m_ScoreLabel = self:NewUI(9, CLabel)
	self.m_CoinLabel = self:NewUI(10, CLabel)
	self.m_StartBox = self:NewUI(11, CBox)
	self.m_StartBox.m_SelectBtn = self.m_StartBox:NewUI(1, CButton)
	self.m_StartBox.m_UnSelectBtn = self.m_StartBox:NewUI(2, CSprite)

	self:InitContent()
	--通知服务器打开游历界面
	nettravel.C2GSFirstOpenTraderUI()
end

function CTravelGameView.InitContent(self)
	self.m_Status = CTravelGameView.Status.Stop
	self.m_First = nil
	self.m_Second = nil
	self.m_IsCardBoxAnim = false
	self.m_CardBox:SetActive(false)
	self.m_TravelHelpBtn:AddHelpTipClick("travel_adventure")
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_StartBox.m_SelectBtn:AddUIEvent("click", callback(self, "OnStartBtn"))
	self.m_StartBox.m_UnSelectBtn:AddUIEvent("click", callback(self, "OnStartBtn"))

	g_TravelCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTravelCtrl"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrl"))
	self:RefreshViewInfo()
	self:InitCardGrid()
	self:RefreshCardGrid()
end

function CTravelGameView.OnAttrCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshScore()
	end
end

function CTravelGameView.OnTravelCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Travel.Event.CardInfo then
		self:RefreshViewInfo()
	elseif oCtrl.m_EventID == define.Travel.Event.CardGrid then
		self:RefreshCardGrid()
	end
end

function CTravelGameView.OnClose(self)
	if self.m_Status ~= CTravelGameView.Status.Stop then
		local args = 
			{
				msg = "该场游戏已经开始，退出后则以当前积分获取奖励，是否继续退出？",
				okCallback = function ( )
					nettravel.C2GSStopTravelCard()
					end,
				okStr = "确定",
				cancelStr = "取消",
			}
		g_WindowTipCtrl:SetWindowConfirm(args)
	else
		CViewBase.OnClose(self)
	end
end

function CTravelGameView.CloseView(self)
	self:KillAllTween()
	nettravel.C2GSStopTravelCard()
	g_TravelCtrl:SetTravelGameRedDot(false)
	CViewBase.CloseView(self)
end

function CTravelGameView.SetTravelGameResult(self, bResult)
	if bResult then
		g_NotifyCtrl:FloatMsg("游戏胜利")
	else
		g_NotifyCtrl:FloatMsg("游戏结束")
	end
end

function CTravelGameView.OnStartBtn(self, oBtn)
	if self.m_PlayCount >= 2 then
		g_NotifyCtrl:FloatMsg("仅可进行2次奇遇玩法，请期待下次触发奇遇商人")
	elseif g_AttrCtrl.coin < self.m_StartCost then
		g_NotifyCtrl:FloatMsg("您的金币不足")
		g_NpcShopCtrl:ShowGold2CoinView()
	else
		nettravel.C2GSStartTravelCard()
	end
end

function CTravelGameView.RefreshViewInfo(self)
	local info = g_TravelCtrl:GetShowCardInfo()
	if not info then
		return
	end
	self.m_Status = info.status
	self.m_PlayCount = info.play_count or 0
	self.m_WatchSecs = info.watch_secs or 0
	self.m_StartCost = info.start_cost or 0
	self.m_EndTime = info.end_time or 0 --观看和开始的结束时间戳,0-为开始
	self.m_ServerTime = info.server_time or 0
	self:ResetView()
end

function CTravelGameView.ResetView(self)
	self:ClearTimer()
	self:RefreshScore()
	self:RefreshBtn()
	self.m_CountLabel:SetText(string.format("本轮奇遇任务剩余次数：%d", 2 - self.m_PlayCount))
	if self.m_Status == CTravelGameView.Status.Stop then
		self.m_IsCardBoxAnim = false
		self.m_LeftLabel:SetText("观看时间：")
		self.m_LeftTimeLabel:SetText(g_TimeCtrl:GetLeftTime(self.m_WatchSecs, true))
		self:KillAllTween()
	else
		self:RefreshLeftTime()
	end
end

function CTravelGameView.KillAllTween(self)
	if self.m_CardGrid and self.m_CardGrid:GetCount() > 0 then
		for i,oCardBox in ipairs(self.m_CardGrid:GetChildList()) do
			if oCardBox.m_Sequence then
				DOTween.DOKill(oCardBox.m_Transform, false)
			end
			oCardBox:SetLocalRotation(Quaternion.Euler(0, 0, 0))
			oCardBox.m_Status = 0
			oCardBox.m_MaskSprite:SetActive(oCardBox.m_Status == CTravelGameView.Card.Hide)
			oCardBox.m_ShapeSprite:SetActive(oCardBox.m_Status == CTravelGameView.Card.Show)
		end
	end
end

function CTravelGameView.ClearTimer(self)
	if self.m_LeftTimer then
		Utils.DelTimer(self.m_LeftTimer)
		self.m_LeftTimer = nil
	end
	if self.m_WatchTimer then
		Utils.DelTimer(self.m_WatchTimer)
		self.m_WatchTimer= nil
	end
end

function CTravelGameView.RefreshBtn(self)
	local bFull = self.m_PlayCount == 5
	if self.m_Status ~= CTravelGameView.Status.Stop then
		self.m_StartBox:SetActive(false)
		self.m_CoinLabel:SetActive(false)
	elseif self.m_Status == CTravelGameView.Status.Stop then
		self.m_StartBox:SetActive(true)
		self.m_StartBox.m_UnSelectBtn:SetActive(bFull)
		self.m_StartBox.m_SelectBtn:SetActive(not bFull)
		self.m_CoinLabel:SetActive(true)
		self.m_CoinLabel:SetActive(not bFull)	
	end
end

function CTravelGameView.RefreshLeftTime(self)
	if self.m_Status == CTravelGameView.Status.Stop then
		return
	end
	local end_time = self.m_EndTime
	local server_time = self.m_ServerTime
	if self.m_Status == CTravelGameView.Status.Watch then
		self.m_LeftLabel:SetText("观看时间：")
		self:WatchAnim((end_time - server_time) / CTravelGameView.GridCount * 2)
	elseif self.m_Status == CTravelGameView.Status.Start then
		self.m_LeftLabel:SetText("剩余时间：")
	end
	if end_time > 0 and server_time > 0 then
	local time = end_time - server_time
		local function countdown()
			if Utils.IsNil(self) then
				return 
			end
			if time >= 0 then
				self.m_LeftTimeLabel:SetText(g_TimeCtrl:GetLeftTime(time, true))
				time = time - 1
				return true
			end
		end
		self.m_LeftTimer = Utils.AddTimer(countdown, 1, 0)
	end
end

function CTravelGameView.RefreshScore(self)
	self.m_Score = g_AttrCtrl.travel_score
	self.m_ScoreLabel:SetText(self.m_Score)
	local color = "FFFCE1"
	if g_AttrCtrl.coin < self.m_StartCost then
		color = "FF0000"
	end
	self.m_CoinLabel:SetText(string.format("#w1[%s]%d", color, self.m_StartCost))
end

function CTravelGameView.InitCardGrid(self)
	self.m_CardGrid:Clear()
	local cardGrid = g_TravelCtrl:GetShowCardGrid()
	for i,v in ipairs(cardGrid) do
		local oCardBox = self.m_CardBox:Clone()
		oCardBox:SetActive(true)
		oCardBox.m_Idx = i
		oCardBox.m_ShapeSprite = oCardBox:NewUI(2, CSprite)
		oCardBox.m_MaskSprite = oCardBox:NewUI(3, CSprite)
		oCardBox.m_MaskSprite:SetActive(true)
		oCardBox:AddUIEvent("click", callback(self, "OnCardBox"))
		self.m_CardGrid:AddChild(oCardBox)
	end
	self.m_CardGrid:Reposition()
end

function CTravelGameView.RefreshCardGrid(self)
	self.m_SessionLock = false
	local cardGrid = g_TravelCtrl:GetShowCardGrid()	
	for i,oCardBox in ipairs(self.m_CardGrid:GetChildList()) do
		oCardBox.m_Pos = cardGrid[i].pos or 0
		oCardBox.m_Shape = cardGrid[i].shape
		oCardBox.m_ShapeSprite:SpriteAvatarBig(oCardBox.m_Shape)
		if oCardBox.m_Status and oCardBox.m_Status ~= cardGrid[i].status then
			oCardBox.m_Status = cardGrid[i].status or 0
			if oCardBox.m_Status == CTravelGameView.Card.Show then
				self:ShowCardShape(oCardBox)
			elseif oCardBox.m_Status == CTravelGameView.Card.Hide then
				self:HideCardShape(oCardBox)
			end
		else
			oCardBox.m_Status = cardGrid[i].status or 0
			oCardBox.m_MaskSprite:SetActive(oCardBox.m_Status == CTravelGameView.Card.Hide)
			oCardBox.m_ShapeSprite:SetActive(oCardBox.m_Status == CTravelGameView.Card.Show)
		end
	end
end

function CTravelGameView:GetShowCardGrid(self)
	local grid = {}
	local cardGrid = g_TravelCtrl:GetShowCardGrid()
	if cardGrid then
		for i=1,CTravelGameView.GridCount do
			grid[i] = cardGrid[i] or {}
		end
	else
		for i=1,CTravelGameView.GridCount do
			grid[i] = {}
		end
	end
	return grid
end

function CTravelGameView.WatchAnim(self, interval)
	local animDic = {}
	for i,oCardBox in ipairs(self.m_CardGrid:GetChildList()) do
		if not animDic[oCardBox.m_Shape] then
			animDic[oCardBox.m_Shape] = {}
		end
		table.insert(animDic[oCardBox.m_Shape], oCardBox)
	end

	local animList = {}
	for k,v in pairs(animDic) do
		table.insert(animList, v)
	end
	local idx = 1
	local function anim()
		if Utils.IsNil(self) then
			return
		end
		local lCardBox = animList[idx]
		if lCardBox then
			for i,oCardBox in ipairs(lCardBox) do
				self:WatchAnimShow(oCardBox, interval)
			end
			idx = idx + 1
			return true
		else
			return false
		end
	end
	self.m_WatchTimer = Utils.AddTimer(anim, interval, 0)
end

function CTravelGameView.WatchAnimShow(self, oCardBox, interval)
	if Utils.IsNil(oCardBox) then
		return
	end
	interval = interval / 2
	oCardBox.m_Sequence = DOTween.Sequence(oCardBox.m_Transform)
	oCardBox.m_MaskSprite:SetActive(true)
	oCardBox.m_ShapeSprite:SetActive(false)
	local tween1  = DOTween.DOLocalRotate(oCardBox.m_Transform, Vector3.New(0, 90, 0), interval)
	DOTween.Append(oCardBox.m_Sequence, tween1)
	DOTween.OnComplete(tween1, function ()
		oCardBox.m_MaskSprite:SetActive(false)
		oCardBox.m_ShapeSprite:SetActive(true)
	end)

	local tween2  = DOTween.DOLocalRotate(oCardBox.m_Transform, Vector3.New(0, 180, 0), interval)
	DOTween.Insert(oCardBox.m_Sequence, interval , tween2)

	local tween3  = DOTween.DOLocalRotate(oCardBox.m_Transform, Vector3.New(0, 90, 0), interval)
	DOTween.Insert(oCardBox.m_Sequence, interval * 2 , tween3)
	DOTween.OnComplete(tween3, function ()
		oCardBox.m_MaskSprite:SetActive(true)
		oCardBox.m_ShapeSprite:SetActive(false)
	end)

	local tween4  = DOTween.DOLocalRotate(oCardBox.m_Transform, Vector3.New(0, 0, 0), interval)
	DOTween.Insert(oCardBox.m_Sequence, interval * 3 , tween4)
	DOTween.OnComplete(tween4, function ()
		oCardBox:SetLocalRotation(Quaternion.Euler(0, 0, 0))
	end)
end

function CTravelGameView.OnCardBox(self, oCardBox)
	if self.m_SessionLock then
		return
	end
	if not oCardBox.m_MaskSprite:GetActive() then
		return
	end
	if self.m_Status == CTravelGameView.Status.Start and not self.m_IsCardBoxAnim then
		self:ShowCardShape(oCardBox)
	end
end

function CTravelGameView.ShowCardShape(self, oCardBox)
	self.m_IsCardBoxAnim = true
	local interval = tonumber(data.globaldata.GLOBAL.travel_game_card_speed.value)
	if oCardBox.m_Sequence then
		DOTween.DOKill(oCardBox.m_Transform, false)
	end
	oCardBox.m_Sequence = DOTween.Sequence(oCardBox.m_Transform)
	local tween1  = DOTween.DOLocalRotate(oCardBox.m_Transform, Vector3.New(0, 90, 0), interval)
	DOTween.Append(oCardBox.m_Sequence, tween1)
	DOTween.OnComplete(tween1, function ()
		oCardBox.m_Status = CTravelGameView.Card.Show
		oCardBox.m_MaskSprite:SetActive(false)
		oCardBox.m_ShapeSprite:SetActive(true)
	end)

	local tween2  = DOTween.DOLocalRotate(oCardBox.m_Transform, Vector3.New(0, 180, 0), interval)
	DOTween.Insert(oCardBox.m_Sequence, interval , tween2)
	DOTween.OnComplete(tween2, function ()
		self.m_IsCardBoxAnim = false
		nettravel.C2GSShowTravelCard(oCardBox.m_Pos)
		self.m_SessionLock = true
	end)
end

function CTravelGameView.HideCardShape(self, oCardBox)
	self.m_IsCardBoxAnim = true
	local interval = tonumber(data.globaldata.GLOBAL.travel_game_card_speed.value)
	if oCardBox.m_Sequence then
		DOTween.DOKill(oCardBox.m_Transform, false)
	end
	oCardBox.m_Sequence = DOTween.Sequence(oCardBox.m_Transform)
	local tween1  = DOTween.DOLocalRotate(oCardBox.m_Transform, Vector3.New(0, 90, 0), interval)
	DOTween.Append(oCardBox.m_Sequence, tween1)
	DOTween.OnComplete(tween1, function ()
		oCardBox.m_MaskSprite:SetActive(true)
		oCardBox.m_ShapeSprite:SetActive(false)
	end)

	local tween2  = DOTween.DOLocalRotate(oCardBox.m_Transform, Vector3.New(0, 0, 0), interval)
	DOTween.Insert(oCardBox.m_Sequence, interval , tween2)
	DOTween.OnComplete(tween2, function ()
		self.m_IsCardBoxAnim = false
	end)
end

return CTravelGameView