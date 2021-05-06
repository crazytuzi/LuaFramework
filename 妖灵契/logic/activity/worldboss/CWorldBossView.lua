local CWorldBossView = class("CWorldBossView", CViewBase)



function CWorldBossView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/worldboss/WorldBossView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_GroupName = "main"
	self.m_OpenEffect = "Scale"
end

function CWorldBossView.Test(self)
		local t = {
			hp_max= 999, hp=544, state=1,daycnt=1, lefttime=10,bosshape=507,killer="谁",daycnt=1,
			myrank={pid=1000, name="myrank", hit=1000, shape=140},
			ranklist = {},
		}
		for i = 1, 20 do
			table.insert(t.ranklist, {pid=i, name="rank"..tostring(i), hit=100+i, shape=140})
		end
		nethuodong.GS2CBossMain(t)
end

function CWorldBossView.OnCreateView(self)
	self.m_FightBtn = self:NewUI(1, CButton)
	self.m_HpSlider = self:NewUI(2, CSlider)
	self.m_RankPart = self:NewUI(3, CWorldBossRankPart)
	self.m_CloseBtn = self:NewUI(4, CButton)
	self.m_TimeLabel = self:NewUI(5, CLabel)
	self.m_BossTexture = self:NewUI(7, CTexture)
	self.m_KillerLabel = self:NewUI(9, CLabel)
	self.m_AliveLabel = self:NewUI(10, CLabel)
	self.m_TipBtn = self:NewUI(11, CButton)
	self.m_RewardBtn = self:NewUI(12, CButton)
	self.m_RefreshBtn = self:NewUI(13, CButton)
	self.m_AirSprite = self:NewUI(16, CSprite)
	self.m_AirLabel = self:NewUI(17, CLabel)

	self.m_Bigboss = nil
	self.m_Timer = nil
	self:InitContent()
end

function CWorldBossView.InitContent(self)
	self.m_RefreshBtn:SetActive(false)
	g_ActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnActivityEvent"))
	self.m_FightBtn:AddUIEvent("click", callback(self, "OnFight"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_TipBtn:AddHelpTipClick("shijieboss")
	self.m_RewardBtn:AddUIEvent("click", callback(self, "OnReward"))
	-- self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnRefresh"))
	self:RefreshHP()
	if not self.m_RefreshTimer then
		self.m_RefreshTimer = Utils.AddTimer(callback(self, "OnRefresh"), 10, 10)
	end

	self.m_TextureData = {
		[509] = {w=1107, h=539, x = -75,},
		[1015] = {w=735, h=540, x = -75,},
		[1100] = {w=872, h=509, x = -75,},
		[1501] = {w=622, h=514, x = -75,},
		[1512] = {w=1221, h=504, x = -33,},
	}
end

function CWorldBossView.OnActivityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Activity.Event.WorldBossHP then
		self:RefreshHP()
	end
end

function CWorldBossView.OnRefresh(self)
	nethuodong.C2GSOpenBossUI()
	return true
end

function CWorldBossView.OnReward(self, oBtn)
	CWorldBossRewardView:ShowView(function (oView)
		oView:SetBoss(self.m_Bigboss)
	end)
end

function CWorldBossView.RefreshHP(self)
	local dInfo = g_ActivityCtrl:GetWolrdBossInfo()
	self.m_HpSlider:SetValue(dInfo.percent)
	-- local sText = string.format("%d/%d(%d%%)", dInfo.hp, dInfo.hp_max, math.floor(dInfo.percent*100))
	local sText = string.format("%d%%",math.floor(dInfo.percent*100))
	self.m_HpSlider:SetSliderText(sText)
end

function CWorldBossView.OnFight(self)
	if g_TeamCtrl:IsJoinTeam() then
		g_NotifyCtrl:FloatMsg("组队状态下禁止操作，请先离队")
		return
	end
	nethuodong.C2GSEnterBossWar()
	self:CloseView()
end

function CWorldBossView.SetRankData(self, lDatas, dMyRank)
	self.m_RankPart:SetRankData(lDatas, dMyRank)
end

function CWorldBossView.SetBoss(self, iShape, iAlive, bigboss)
	self.m_Bigboss = bigboss
	local path = string.format("Texture/WorldBoss/pic_boss_%d.png", iShape)
	self.m_BossTexture:LoadPath(path, function ()
		self.m_BossTexture:SetSize(self.m_TextureData[iShape].w, self.m_TextureData[iShape].h)
		self.m_BossTexture:SetLocalPos(Vector3.New(self.m_TextureData[iShape].x, 0, 0))
	end)
	self:SetAlive(iAlive)
	self:SetAirSpritePos(iShape)
	self:SetAirLabel()
end

function CWorldBossView.SetAlive(self, iAlive)
	local bAlive = iAlive ~= 1
	self.m_BossTexture:SetGrey(bAlive)
	self.m_AliveLabel:SetActive(bAlive)
	if bAlive then
		self.m_FightBtn:SetText("已击杀")
		self.m_FightBtn:AddUIEvent("click", function ()
			g_NotifyCtrl:FloatMsg("Boss已击杀")
		end)
	end
end

function CWorldBossView.SetAirSpritePos(self, iShape)
	local pos = data.worldbossdata.AIRPOS[iShape].pos
	self.m_AirSprite:SetLocalPos(pos)
end

function CWorldBossView.SetAirLabel(self)
	local value = self.m_HpSlider:GetValue()
	local statusdescs = data.worldbossdata.STATUSDESC
	local txt = "不服来战"
	if value >= 0.7 then
		txt = table.randomvalue(statusdescs[1].air)
	elseif value >= 0.3 then
		txt = table.randomvalue(statusdescs[2].air)
	elseif value > 0 then
		txt = table.randomvalue(statusdescs[3].air)
	elseif value == 0 then
		txt = table.randomvalue(statusdescs[4].air)
	end
	self.m_AirLabel:SetText(txt)
end

function CWorldBossView.SetKillerName(self, sName)
	self.m_KillerName = sName
	if sName and #sName > 0 then
		self.m_KillerLabel:SetText("击杀者:"..sName)
	else
		self.m_KillerLabel:SetText("")
	end
end

function CWorldBossView.SetTime(self, iLefTime)
	self.m_LeftTime = iLefTime

	if not self.m_Timer then
		local function update(dt)
			if Utils.IsNil(self) then
				self.m_Timer = nil
				return
			end
			if self.m_KillerName and #self.m_KillerName > 0 then
				self.m_TimeLabel:SetText("")
				self.m_Timer = nil
				return
			end
			self.m_LeftTime = self.m_LeftTime - dt
			if self.m_LeftTime < 0 then
				self.m_TimeLabel:SetText("活动结束")
				self.m_Timer = nil
			else
				local t = g_TimeCtrl:GetTimeInfo(self.m_LeftTime)
				self.m_TimeLabel:SetText(string.format("剩余时间:%d时%d分%d秒", t.hour, t.min, t.sec))
				return true
			end
		end
		self.m_Timer = Utils.AddTimer(update, 0.05, 0)
	end
end

function CWorldBossView.CloseView(self)
	nethuodong.C2GSCloseBossUI()
	CViewBase.CloseView(self)
end

function CWorldBossView.ShowWarResult(cls, oCmd)
	if oCmd.win then
		CWorldBossResultView:ShowView(function(oView)
			oView:SetWarID(oCmd.war_id)
			oView:SetWin(true)
			oView:SetDelayCloseView()
		end)
	else
		CWorldBossResultView:ShowView(function(oView)
			oView:SetWarID(oCmd.war_id)
			oView:SetWin(false)
			oView:SetDelayCloseView()
		end)
	end
end
return CWorldBossView