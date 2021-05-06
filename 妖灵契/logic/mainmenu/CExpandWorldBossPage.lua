local CExpandWorldBossPage = class("CExpandWorldBossPage", CPageBase)

function CExpandWorldBossPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CExpandWorldBossPage.OnInitPage(self)
	self.m_ShowGroup = self:NewUI(1, CWidget)
	self.m_HideGroup = self:NewUI(2, CWidget)
	self.m_HideBtn = self:NewUI(3, CButton)
	self.m_ShowBtn = self:NewUI(4, CButton)
	self.m_QuitBtn = self:NewUI(5, CButton)
	self.m_FightBtn = self:NewUI(6, CButton)
	self.m_BuffGird = self:NewUI(7, CGrid)
	--self.m_BuffBox = self:NewUI(8, CBox)
	self.m_NumberGrid = self:NewUI(9, CGrid)
	self.m_NumberSprite = self:NewUI(10, CSprite)
	self.m_NumberBgSprite = self:NewUI(11, CSprite)
	self.m_ReviveBtn = self:NewUI(12, CButton)
	self.m_BossBg = self:NewUI(13, CSprite)
	self.m_HpSlider = self:NewUI(14, CSlider)
	self.m_BossSprite = self:NewUI(15, CSprite)
	self.m_PlayerRankBox = self:NewUI(16, CBox)
	self.m_PlayerRankBox.m_RankLabel = self.m_PlayerRankBox:NewUI(1, CLabel)
	self.m_PlayerRankBox.m_ScoreLabel = self.m_PlayerRankBox:NewUI(2, CLabel)
	self.m_RankBox = self:NewUI(17, CBox)
	self.m_WrapContent = self:NewUI(18, CWrapContent)
	self.m_LeftTimeLabel = self:NewUI(19, CLabel)
	self.m_HideRankBtn = self:NewUI(20, CButton)
	self.m_ShowRankBtn = self:NewUI(21, CButton)
	self.m_RankWidget = self:NewUI(22, CWidget)
	self.m_RewardBtn = self:NewUI(23, CButton)
	self.m_ZheZhaoSpr = self:NewUI(24, CSprite)
	self:InitContent()
end

function CExpandWorldBossPage.InitContent(self)
	self.m_NumberBgTween = self.m_NumberBgSprite:GetComponent(classtype.TweenAlpha)
	self.m_CountDownTimer = nil
	self.m_NumberSpriteArr = {}
	self.m_NumberGrid:SetActive(false)
	self.m_NumberSprite:SetActive(false)
	self.m_NumberBgSprite:SetActive(false)
	self.m_ReviveBtn:SetActive(false)
	self.m_ZheZhaoSpr:SetActive(false)
	self.m_LastUpdateTime = -1	

	self.m_RankBox:SetActive(false)
	self.m_WrapContent:SetCloneChild(self.m_RankBox, 
		function(oBox)
			oBox.m_RankLabel = oBox:NewUI(1, CLabel)
			oBox.m_NameLabel = oBox:NewUI(2, CLabel)
			oBox.m_ScoreLabel = oBox:NewUI(3, CLabel)
			return oBox
		end)
	self.m_WrapContent:SetRefreshFunc(function(oBox, dData)
		if dData then
			oBox.m_PID = dData.pid
			if dData.rank > 0 and dData.rank <= 50 then
				oBox.m_RankLabel:SetText(tostring(dData.rank))
			else
				oBox.m_RankLabel:SetText("榜外")
			end
			oBox.m_NameLabel:SetText(dData.name)
			oBox.m_ScoreLabel:SetText(dData.hit)
			oBox:SetActive(true)
		else
			oBox:SetActive(false)
		end
	end)

	self.m_HideBtn:AddUIEvent("click", callback(self, "OnSetActive", false, true))
	self.m_ShowBtn:AddUIEvent("click", callback(self, "OnSetActive", true, true))
	self.m_QuitBtn:AddUIEvent("click", callback(self, "OnQuit"))
	self.m_FightBtn:AddUIEvent("click", callback(self, "OnFight"))
	self.m_ReviveBtn:AddUIEvent("click", callback(self, "OnReviveBtn"))
	self.m_HideRankBtn:AddUIEvent("click", function () self.m_RankWidget:SetActive(false) end)
	self.m_ShowRankBtn:AddUIEvent("click", function () self.m_RankWidget:SetActive(true) end)
	self.m_RewardBtn:AddUIEvent("click", callback(self, "OnReward"))
	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChatCtrlEvent"))
	g_ActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnActivityEvent"))
	g_StateCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnStateEvent"))

	self:InitBuffGrid()
	self:RefreshAll(true)
	self:RefreshHP()
	self:RefreshRank()
	self:RefreshLeftTime()
	self:RefreshState()
	self:RefreshBossShape()
end

function CExpandWorldBossPage.OnActivityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Activity.Event.WorldBossHP then
		self:RefreshHP()
		--self:RefreshRank()
	elseif oCtrl.m_EventID == define.Activity.Event.WolrdBossScene then
		self:RefreshState()
		self:RefreshLeftTime()
		self:RefreshRank()
		self:RefreshAll(true)
		self:RefreshHP()
		self:RefreshBossShape()
	elseif oCtrl.m_EventID == define.Activity.Event.WorldBossRank then
		self:RefreshRank()
	elseif oCtrl.m_EventID == define.Activity.Event.WolrdBossShape then
		self:RefreshBossShape()
	end
end

function CExpandWorldBossPage.OnChatCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.ChatBoxExpan then
		local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
		if isHide then
			self:OnSetActive(false)
		end
	end
end

function CExpandWorldBossPage.OnStateEvent(self, oCtrl)
	self:RefreshState(oCtrl.m_EventData)
	self:RefreshBuff()
end

function CExpandWorldBossPage.InitBuffGrid(self)
	self.m_BuffGird:InitChild(function (obj, idx)
 		local oBox = CBox.New(obj)
		oBox:SetActive(true)
		oBox.m_BuffSprite = oBox:NewUI(1, CSprite)
		oBox.m_BuffLabel = oBox:NewUI(2, CLabel)
		oBox.m_BuySprtie = oBox:NewUI(3, CSprite)
		oBox.m_CostLabel = oBox:NewUI(4, CLabel)
		oBox.m_BuySprtie:SetActive(false)
 		return oBox
 	end)
	local bufflist = data.worldbossdata.BUFF
	bufflist = table.dict2list(bufflist, "buff")

	for i,oBox in ipairs(self.m_BuffGird:GetChildList()) do
		local d = bufflist[i]
		if d then
			oBox.m_Buff = d.buff
			oBox.m_Cost = d.cost
			oBox.m_State = d.state
			local dBuff = data.buffdata.DATA[oBox.m_Buff]
			if dBuff then
				oBox.m_BuffSprite:SpriteBuff(dBuff.icon)
				oBox.m_BuffLabel:SetText(d.name)
				oBox.m_CostLabel:SetText(oBox.m_Cost)
				oBox:AddUIEvent("click", callback(self, "OnBuffBox"))
				oBox:AddUIEvent("longpress", callback(self, "OnLongPressBuffBox"))
			end
		end
	end
	self:RefreshBuff()
end

function CExpandWorldBossPage.RefreshBuff(self)
	for i,oBox in ipairs(self.m_BuffGird:GetChildList()) do
		local state = g_StateCtrl:GetState(oBox.m_State)
		if state then
			oBox.m_BuySprtie:SetActive(true)
		else
			oBox.m_BuySprtie:SetActive(false)
		end
	end
end

function CExpandWorldBossPage.OnBuffBox(self, oBox)
	local statedata = g_StateCtrl:GetState(1005)
	local bGray = statedata and g_ActivityCtrl:InWorldBossFB()
	if bGray then
		g_NotifyCtrl:FloatMsg("死亡状态不可购买")
	elseif g_AttrCtrl.coin < oBox.m_Cost then
		g_NotifyCtrl:FloatMsg("您的金币不足")
		g_NpcShopCtrl:ShowGold2CoinView()
	else
		local buffdata = data.buffdata.DATA
		local buff = buffdata[oBox.m_Buff]
		local windowConfirmInfo = {
			msg	= string.format("是否花费%d金币购买【%s】? \n 效果：%s", oBox.m_Cost, buff.name, buff.desc),
			okCallback = function ()				
				nethuodong.C2GSBuyBossBuff(oBox.m_Buff)
			end,
			okStr = "是",
			cancelStr = "否",			
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	end
end

function CExpandWorldBossPage.OnLongPressBuffBox(self, oBox, bPress)
	if bPress then
		local buffdata = data.buffdata.DATA
		local buff = buffdata[oBox.m_Buff]
		g_WindowTipCtrl:SetWindowItemTipsWindow(buff.name, {buff.desc},
		{widget = oBox, side = enum.UIAnchor.Side.TopRight, offset = Vector2.New( 0, -10)})
	end
end

function CExpandWorldBossPage.OnSetActive(self, b, isClick)	
	self.m_ShowGroup:SetActive(b)
	self.m_HideGroup:SetActive(not b)
	if isClick == true and b == true then
		local oView = CMainMenuView:GetView()
		if oView and oView.m_LB and oView.m_LB.m_ChatBox then
			oView.m_LB.m_ChatBox:OnPull()
		end
	end	
end

function CExpandWorldBossPage.OnQuit(self, obj)
	nethuodong.C2GSLeaveWorldBossScene()
end

function CExpandWorldBossPage.OnFight(self, obj)
	local statedata = g_StateCtrl:GetState(1005)
	local bGray = statedata and g_ActivityCtrl:InWorldBossFB()
	if bGray then
		g_NotifyCtrl:FloatMsg("死亡状态不可挑战")
	else
		nethuodong.C2GSFindWorldBoss()
	end
end

function CExpandWorldBossPage.OnReviveBtn(self)
	nethuodong.C2GSBossRemoveDeadBuff()
end

function CExpandWorldBossPage.RefreshAll(self, isStart)
	local isHide = g_ChatCtrl.m_MainMenuChatBoxExpan == nil and true or g_ChatCtrl.m_MainMenuChatBoxExpan
	if isStart then
		self:OnSetActive(true, true)
	else
		self:OnSetActive(not isHide, false)
	end
end

function CExpandWorldBossPage.RefreshHP(self)
	local dInfo = g_ActivityCtrl:GetWolrdBossInfo()
	self.m_HpSlider:SetValue(dInfo.percent)
	local sText = string.format("%d%%",math.floor(dInfo.percent*100))
	self.m_HpSlider:SetSliderText(sText)
end

function CExpandWorldBossPage.RefreshRank(self)
	local bossInfo = g_ActivityCtrl:GetWolrdBossInfo()
	local lRank = bossInfo["rank"] 
	local dMyRank = bossInfo["myrank"] 
	if lRank and #lRank > 0 then
		self.m_WrapContent:SetData(lRank, true)
	end
	if dMyRank then
		local oBox = self.m_PlayerRankBox
		if dMyRank.rank and dMyRank.rank > 0 and dMyRank.rank <= 50 then
			oBox.m_RankLabel:SetText(tostring(dMyRank.rank).."  我的积分  ".. (dMyRank.hit or 0))
		else
			oBox.m_RankLabel:SetText("榜外  我的积分  ".. (dMyRank.hit or 0))
		end
		oBox.m_ScoreLabel:SetText(dMyRank.hit or 0)
	end
end

function CExpandWorldBossPage.RefreshLeftTime(self)
	if g_ActivityCtrl:InWorldBossFB() then
		local wolrdBossLeftTime = g_ActivityCtrl:GetWolrdBossLeftTimeText()
		if wolrdBossLeftTime == nil then
			self:OnQuit()
		else
			if self.m_WorldBossTimerID == nil then
				self.m_WorldBossTimerID = Utils.AddTimer(callback(self, "RefreshLeftTime"), 1, 0)
			end
			self.m_LeftTimeLabel:SetText("剩余时间"..wolrdBossLeftTime)
			return true
		end
	end
	self.m_WorldBossTimerID = nil
	return false
end

function CExpandWorldBossPage.RefreshBossShape(self)
	local bossInfo = g_ActivityCtrl:GetWolrdBossInfo()
	if bossInfo and bossInfo["shape"] then
		self.m_BossSprite:SpriteBossAvatar(bossInfo["shape"])
	else
		nethuodong.C2GSOpenBossUI()
	end
end

function CExpandWorldBossPage.RefreshState(self, stateInfo)
	if stateInfo and type(stateInfo) == "table" and stateInfo.state_id and stateInfo.state_id ~= 1005 then
		return
	end
	local oHero = g_MapCtrl:GetHero()
	local statedata = g_StateCtrl:GetState(1005)
	local bGray = statedata and g_ActivityCtrl:InWorldBossFB()
	local function refresh()		
		if bGray then
			if oHero then
				oHero:PlayAnim("die")
			end
			self:SetReviveTime(statedata["time"])
		else
			if oHero then
				if oHero.m_Actor.m_CurState == "run" then
				else
					oHero:PlayAnim("idleCity")
				end
			end
			self:OnTimeUP()
		end
		g_CameraCtrl:SetGrayScene(bGray)
	end
	if oHero then
		refresh()
	else
		self:DelayCall(0.1, "RefreshState")
	end
end

function CExpandWorldBossPage.SetReviveTime(self, endtime)
	self.m_EndTime = endtime
	if self.m_CountDownTimer then
		Utils.DelTimer(self.m_CountDownTimer)
		self.m_CountDownTimer = nil
	end
	if not self.m_CountDownTimer then
		self.m_CountDownTimer = Utils.AddTimer(callback(self, "CountDown"), 0, 0)
	end
end

function CExpandWorldBossPage.CountDown(self)
	if g_ActivityCtrl:InWorldBossFB() then
		local iTime = self.m_EndTime - g_TimeCtrl:GetTimeS()
		if iTime > 0 then
			self:UpdateTimeSprite(iTime)
			return true
		else
			self:OnTimeUP()
			return false
		end
	else
		self:OnTimeUP()
		return false
	end
end

function CExpandWorldBossPage.OnTimeUP(self)
	self:DelTimer()
	self.m_NumberGrid:SetActive(false)
	self.m_NumberSprite:SetActive(false)
	self.m_NumberBgSprite:SetActive(false)
	self.m_ReviveBtn:SetActive(false)
	self.m_ZheZhaoSpr:SetActive(false)
end

function CExpandWorldBossPage.DelTimer(self)
	if self.m_CountDownTimer ~= nil then
		Utils.DelTimer(self.m_CountDownTimer)
		self.m_CountDownTimer = nil
	end
end

function CExpandWorldBossPage.UpdateTimeSprite(self, iValue)
	self.m_NumberGrid:SetActive(true)
	self.m_NumberBgSprite:SetActive(true)
	self.m_ReviveBtn:SetActive(true)
	self.m_ZheZhaoSpr:SetActive(true)
	local bossInfo = g_ActivityCtrl:GetWolrdBossInfo()
	if bossInfo["dead_cost"] and bossInfo["dead_cost"] > 0 then
		self.m_ReviveBtn:SetText(string.format("#w2%d复活",  bossInfo["dead_cost"]))
	else
		self.m_ReviveBtn:SetText("立即复活")
	end
	if self.m_LastUpdateTime == iValue then
		return
	end
	self.m_LastUpdateTime = iValue
	if iValue < 10 then
		self.m_NumberBgTween.enabled = true
	else
		self.m_NumberBgTween.enabled = false
		self.m_NumberBgSprite:SetColor(Color.white)
	end
	local sList = self:GetNumList(iValue)
	for i,v in ipairs(sList) do
		if self.m_NumberSpriteArr[i] == nil then
			self.m_NumberSpriteArr[i] = self.m_NumberSprite:Clone()
			self.m_NumberGrid:AddChild(self.m_NumberSpriteArr[i])
		end
		self.m_NumberSpriteArr[i]:SetSpriteName("shuzi_jishi" .. v)
		self.m_NumberSpriteArr[i]:SetActive(true)
	end
	local startCount = #sList + 1
	for i = startCount, #self.m_NumberSpriteArr do
		self.m_NumberSpriteArr[i]:SetActive(false)
	end
	self.m_NumberGrid:Reposition()
end

function CExpandWorldBossPage.GetNumList(self, iValue)
	local sList = {}
	local str = tostring(iValue)
	local len = string.len(str)
	for i = 1, len do
		table.insert(sList, string.sub(str, i, i))
	end
	return sList
end

function CExpandWorldBossPage.OnReward(self, oBtn)
	CWorldBossRewardView:ShowView(function (oView)
		local bossInfo = g_ActivityCtrl:GetWolrdBossInfo()
		oView:SetBoss(bossInfo["bigboss"])
	end)
end

return CExpandWorldBossPage