local CPaTaView = class("CPaTaView", CViewBase)

function CPaTaView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/pata/PaTaView.prefab", cb)
	--self.m_ExtendClose = "Black"
	--self.m_GroupName = "main"
end

local AniConfig = 
{
	fight_distance = 250,
	fight_distance_max = 300,
	run_speed = 300,
	down_speed = 150,
}

local Ani = 
{
	[1] = { starttime = 0, endtime = 0.2, 
			hero  = {from = {-260, -40, 0 }, to = { -200, -40, 0}, action = "run", rotate = -90} ,
			enemy = {from = {70, -45, 0 }, to = { 70, -45, 0},  action = "idleCity",rotate = 0} },
	[2] = { starttime = 0.2, endtime = 9.5, 
			hero  = {from = {-200, -40, 0 }, to = { -200, -40, 0}, action = "attack1", rotate = -90} ,
			enemy = {from = {70, -45, 0 }, to = { 70, -45, 0},  action = "attack1", rotate = 90} },
	[3] = { starttime = 9.5, endtime = 11.5, 
			hero  = {from = {-200, -40, 0 }, to = { -800, -40, 0}, action = "run", rotate = 90} ,
			enemy = {from = {70, -25, 0 }, to = { 70, -25, 0},  action = "die",rotate = 90, loop = false} },	
	[4] = { starttime = 11.5, endtime = 12.5, 
			hero  = {from = {-420, -40, 0 }, to = { -420, -40, 0}, action = "run", rotate = -90, visible = false} ,
			enemy = {from = {70, -45, 0 }, to = { 70, -45, 0},  action = "idleCity",rotate = 0, visible = false} },				
	[5] = { starttime = 12.5, endtime = 13, 
			hero  = {from = {-420, -40, 0 }, to = { -400, -40, 0}, action = "run", rotate = -45,} ,
			enemy = {from = {70, -45, 0 }, to = { 70, -45, 0},  action = "idleCity",rotate = 0, visible = false} },							
	[6] = { starttime = 13, endtime = 14, 
			hero  = {from = {-400, -40, 0 }, to = { -585, -40, 0}, action = "run", rotate = 30} ,
			enemy = {from = {70, -45, 0 }, to = { 70, -45, 0},  action = "idleCity",rotate = 0, visible = false} },							
	[7] = { starttime = 14, endtime = 15, 
			hero  = {from = {-585, -40, 0 }, to = { -260, -40, 0}, action = "run", rotate = -90} ,
			enemy = {from = {70, -45, 0 }, to = { 70, -45, 0},  action = "idleCity",rotate = 0,} },										
}			

function CPaTaView.OnCreateView(self)
	self.m_RankBtn = self:NewUI(1, CBox)
	self.m_RankBtn.m_RedDot = self.m_RankBtn:NewUI(1, CSprite)

	self.m_ExchangeBtn = self:NewUI(2, CBox)
	self.m_ExchangeBtn.m_RedDot = self.m_ExchangeBtn:NewUI(1, CSprite)

	self.m_ResetBtn = self:NewUI(3, CBox)
	self.m_ResetBtn.m_RedDot = self.m_ResetBtn:NewUI(1, CSprite)

	self.m_WipeOutBtn = self:NewUI(4, CBox)
	self.m_WipeOutBtn.m_RedDot = self.m_WipeOutBtn:NewUI(1, CSprite)

	self.m_MonsterActorTexture = self:NewUI(5, CActorTexture)

	self.m_PlayerActorTexture = self:NewUI(6, CActorTexture)

	self.m_CloseBtn = self:NewUI(7, CButton)
	self.m_AwardFloorLabel = self:NewUI(8, CLabel)
	self.m_LeastPowerLabel = self:NewUI(9, CLabel)
	self.m_AwardScrollView = self:NewUI(10, CScrollView)
	self.m_AwardGrid = self:NewUI(11, CGrid)
	self.m_AwardCloneBox = self:NewUI(12, CItemTipsBox)
	self.m_BackBtn = self:NewUI(13, CButton)	

	self.m_FightBtn = self:NewUI(22, CBox)
	self.m_WipeOutTipsLabel = self:NewUI(23, CLabel)
	self.m_Container = self:NewUI(24, CWidget)
	self.m_OpenEffectBox = self:NewUI(25, CBox)
	self.m_BgScrollView = self:NewUI(26, CScrollView)
	self.m_WrapContent = self:NewUI(27, CWrapContent)
	self.m_BgCloneBox = self:NewUI(28, CBox)
	self.m_WipeOutBtnMask = self:NewUI(29, CBox)

	self.m_TipsBtn = self:NewUI(30, CButton)

	self.m_ScrollPage = self:NewUI(31, CFactoryPartScroll)
	self.m_AdjustWidget = self:NewUI(32, CWidget)
	self.m_PageGrid = self:NewUI(33, CGrid)

	self.m_CurLevel = 1
	self.m_MaxLevel = 1
	self.m_FriendInfo = {}
	self.m_AwardCloneBoxList = {}

	self.m_AniMainTimer = nil
	self.m_AniElaspTime = 0
	self.m_AniIndex = 0
	self.m_AniCurWipeLevel = 1
	self.m_IsAniEnd = true
	self.m_BgMoveOffset = 0
	self.m_BgCloneBoxList = {}

	self.m_OpenTimerList = {}
	self.m_IsOpenAni = nil

	self.m_MyProcressList = {}

	UITools.ResizeToRootSize(self.m_Container)
	self:InitContent()

end

function CPaTaView.SetLevel(self, curLv, maxLv, info)
	self.m_CurLevel = curLv
	self.m_MaxLevel = maxLv
	self.m_FriendInfo = info or {}
	self:RefreshAll()
	if g_PataCtrl.m_WipeOutRewardList then
		CPaTaWipeView:ShowView(function(oView)
			oView:ShowWipeOutEnd(g_PataCtrl.m_CurLevel)
		end)
	end
end

function CPaTaView.InitContent(self)
	self.m_BgCloneBox:SetActive(false)
	self.m_AwardCloneBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_FightBtn:AddUIEvent("click", callback(self, "OnFight"))
	self.m_RankBtn:AddUIEvent("click", callback(self, "OnShowRank"))
	self.m_ExchangeBtn:AddUIEvent("click", callback(self, "OnExchange"))
	self.m_ResetBtn:AddUIEvent("click", callback(self, "OnReset"))
	self.m_WipeOutBtn:AddUIEvent("click", callback(self, "OnWipeOut"))
	self.m_TipsBtn:AddHelpTipClick("pata_main")

	g_PataCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlPataEvent"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMapEvent"))

	self.m_PlayerActorTexture:ChangeShape(g_AttrCtrl.model_info.shape, g_AttrCtrl.model_info, nil, nil, nil)

	self.m_BgScrollView:SetDepth(self:GetDepth() - 1)

	--重新调整扫荡动画时间
	self:InitWipeOutData()
	self:InitValue()
	self:InitOpenEffect()
	self:StartOpenEffect()

	self:InitScrollPage()
	--self:DelayCall(0, callback(self, "StartOpenEffect"))
end

function CPaTaView.OnClose(self)
	self.m_IsAniEnd = true
	self:StopWipeOutAni()
	CViewBase.OnClose(self)
end

function CPaTaView.OnShowRank(self)
	g_RankCtrl:OpenRank(define.Rank.RankId.Pata)
end

function CPaTaView.OnExchange(self)
	g_NpcShopCtrl:OpenShop(define.Store.Page.MedalShop)
end

function CPaTaView.OnFight(self, floor)
	local args = 
	{
		msg = "是否发起挑战？\n(可邀请好友伙伴助战3次)",
		okStr = "开始挑战",
		okCallback = function ( )
			g_PataCtrl:CtrlC2GSPataInvite()
		end,
		cancelStr = "邀请好友",
		cancelCallback = function ( )
			g_PataCtrl:PaTaReadyFight()
		end,	
		rTopCloseCallback = function ()
			-- nothing
		end,
		noCancelCbTouchOut = true,
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
end

function CPaTaView.OnReset(self)
	if g_PataCtrl.m_ResetCount > 0 then
		local args = 
		{
			msg = "重置后将从第一层重新开始挑战！是否重置",
			okCallback = function ( )
					g_PataCtrl:PaTaReset()
				end,
			okStr = "确定",
			cancelStr = "取消",
		}
		g_WindowTipCtrl:SetWindowConfirm(args)
	else
		g_NotifyCtrl:FloatMsg("今日重置次数已使用完，明天再尝试吧。")
	end
end

function CPaTaView.OnWipeOut(self)
	g_PataCtrl:PaTaEnterWipeOutView()
end

function CPaTaView.RefreshAll(self)
	local level = self.m_CurLevel
	if level > CPataCtrl.MaxLevel then
		level = CPataCtrl.MaxLevel
	end

	self:RefreshAward(level)
	
	self:ScrollPageSetData()
	--扫荡状态
	if g_PataCtrl:IsWipeOuting() then
		--重置背景	
		--self:SetMyProcress(self.m_AniCurWipeLevel, true)	
		self:ResetBg()			
		self:HideAllActor()
		self:PlayWipeAni()
		--self:SetProcressDragMaskContentActive(true)	
	else					
		--self:SetMyProcress(level)
		self.m_ScrollPage:OnCenterIndex(self:GetMainFloor(level))
		self:StopWipeOutAni()		
		--重置背景
		self:ResetBg()			
		--self:SetProcressDragMaskContentActive(false)	
	end

	self.m_ResetBtn.m_RedDot:SetActive(g_PataCtrl.m_ResetCount > 0)
	self:RefreshFirstReward()
	self:RefreshWipeOutBtn()
end

function CPaTaView.OnCtrlPataEvent( self, oCtrl )
	if oCtrl.m_EventID == define.PaTa.Event.WipeOutBegin then
		self.m_CurLevel = g_PataCtrl.m_CurLevel
		self.m_MaxLevel = g_PataCtrl.m_MaxLevel
		self:InitWipeOutData()
		self:RefreshAll()
	elseif oCtrl.m_EventID == define.PaTa.Event.WipeOutEnd then
		if g_PataCtrl.m_WipeOutRewardList and CPaTaWipeView:GetView() == nil then
			CPaTaWipeView:ShowView(function(oView)
				oView:ShowWipeOutEnd(g_PataCtrl.m_CurLevel)
			end)
		end
		self.m_CurLevel = g_PataCtrl.m_CurLevel
		self.m_MaxLevel = g_PataCtrl.m_MaxLevel
		self:RefreshAll()		
	elseif oCtrl.m_EventID == define.PaTa.Event.FirstReWard then
		self:RefreshFirstReward()
	end
end

function CPaTaView.OnCtrlMapEvent( self, oCtrl )
	if oCtrl.m_EventID == define.Map.Event.MapLoadDone then
		if g_TeamCtrl:IsInTeam() then
			self:CloseView()
		end
	end
end

function CPaTaView.PlayWipeAni(self)
	if self.m_AniMainTimer then
		Utils.DelTimer(self.m_AniMainTimer)
		self.m_AniMainTimer = nil
	end

	self.m_WipeOutTipsLabel:SetActive(true)
	self.m_WipeOutBtnMask:SetActive(true)	

	self.m_AniIndex = self.m_AniIndex + 1
	if self.m_AniIndex > #Ani then
		self.m_AniIndex = 1
		self.m_AniCurWipeLevel = self.m_AniCurWipeLevel + 1
		if g_PataCtrl:GetWipdOutEndlevel() <= self.m_AniCurWipeLevel then
			self:StopWipeOutAni()
		end
	elseif self.m_AniIndex == #Ani and self.m_AniCurWipeLevel < 100 then
		--每次播放最后一段动画的时候，调整背景位置
		self:ResetBg(self.m_AniCurWipeLevel + 1)	
	end

	self.m_BgMoveOffset = 0
	local t =  Ani[self.m_AniIndex]
	self.m_IsAniEnd = false	

	self.m_AniElaspTime = t.endtime - t.starttime	

	self:RefreshAward(self.m_AniCurWipeLevel)
	self:SetMyProcress(self.m_AniCurWipeLevel, true)

	self.m_PlayerActorTexture:SetActive(true)
	self.m_PlayerActorTexture:OnPlay(t.hero.action)
	self.m_PlayerActorTexture:SetRotate(t.hero.rotate)
	self.m_PlayerActorTexture:SetLocalPos(Vector3.New(t.hero.from[1], t.hero.from[2], t.hero.from[3]))

	self.m_MonsterActorTexture:SetActive(true)
	local monsterId
	--播放最后一段动画，显示下一层的怪物
	if self.m_AniIndex == #Ani and self.m_AniCurWipeLevel < 100 then
		monsterId = g_PataCtrl:GetFloorMonsterId(self.m_AniCurWipeLevel + 1)
	else
		monsterId = g_PataCtrl:GetFloorMonsterId(self.m_AniCurWipeLevel)
	end

	if monsterId then
		self.m_MonsterActorTexture:ChangeShape(monsterId, nil, nil, nil, nil)
	end	
	self.m_MonsterActorTexture:OnPlay(t.enemy.action, t.enemy.loop)
	self.m_MonsterActorTexture:SetRotate(t.enemy.rotate)

	if t.hero.visible ~= nil then
		self.m_PlayerActorTexture:SetLocalScale(Vector3.New(0.01, 0.01, 0.01))
	else
		self.m_PlayerActorTexture:SetLocalScale(Vector3.New(1, 1, 1))
	end

	if t.enemy.visible ~= nil then		
		self.m_MonsterActorTexture:SetLocalScale(Vector3.New(0.01, 0.01, 0.01))
	else	
		self.m_MonsterActorTexture:SetLocalScale(Vector3.New(1, 1, 1))
	end

	self.m_MonsterActorTexture:SetLocalPos(Vector3.New(t.enemy.from[1], t.enemy.from[2], t.enemy.from[3]))
	self.m_AniMainTimer = Utils.AddTimer(callback(self, "AniUpdate"), 0.05, 0)
end

function CPaTaView.AniUpdate(self, dt)
	if Utils.IsNil(self) then
		return false
	end
	self.m_AniElaspTime = self.m_AniElaspTime - dt
	if self.m_IsAniEnd == false then
		self:AniPosCheck(dt)
		self:AniBgCheck(dt)
	else
		return false
	end

	if self.m_AniElaspTime < 0 then
		self.m_AniElaspTime = 0	
		self:PlayWipeAni()
		return false
	else
		return true
	end
end

function CPaTaView.StopWipeOutAni(self)
	if self.m_AniMainTimer then
		Utils.DelTimer(self.m_AniMainTimer)
		self.m_AniMainTimer = nil
	end
	self.m_PlayerActorTexture:SetActive(false)
	self.m_MonsterActorTexture:SetActive(false)
	self.m_WipeOutTipsLabel:SetActive(false)
	self.m_WipeOutBtnMask:SetActive(false)	
	self.m_IsAniEnd = true
end

function CPaTaView.AniPosCheck(self, dt)
	if self.m_IsAniEnd == true or Utils.IsNil(self.m_PlayerActorTexture) then
		return
	end
	local t = Ani[self.m_AniIndex] 
	if t then
		local heroPos = self.m_PlayerActorTexture:GetLocalPos()
		local tPos = t.hero.to[1]
		if heroPos.x ~= tPos then			
			local speed = math.abs(t.hero.to[1] - t.hero.from[1]) / (t.endtime - t.starttime)	
			local offset = speed * dt
			local d = 0
			if heroPos.x < tPos then
				d = (heroPos.x + offset ) >  tPos and tPos or  (heroPos.x + offset )
			else
				d = (heroPos.x - offset ) <  tPos and tPos or  (heroPos.x - offset )
			end			
			self.m_PlayerActorTexture:SetLocalPos(Vector3.New( d , heroPos.y, heroPos.z ))
		end
	end
end

function CPaTaView.Destroy(self)
	if self.m_AniMainTimer then
		Utils.DelTimer(self.m_AniMainTimer)
		self.m_AniMainTimer = nil
	end	
	if self.m_OpenTimerList and next(self.m_OpenTimerList) then
		for k, v in pairs(self.m_OpenTimerList) do
			Utils.DelTimer(v)
			v = nil
		end
	end	
	g_DialogueAniCtrl:SetCacheProto(false)
	CViewBase.Destroy(self)
end

function CPaTaView.InitValue(self)
	self.m_WrapContent:SetCloneChild(self.m_BgCloneBox, 
		function(oChild)
			oChild.m_FloorLabel = oChild:NewUI(1, CLabel)
			oChild.m_PlayerFloorActorTexture = oChild:NewUI(2, CActorTexture)
			oChild.m_MonsterFloorActorTexture = oChild:NewUI(3, CActorTexture)
			oChild.m_FindBtn = oChild:NewUI(4, CBox)	
			oChild.m_BgTexture = oChild:NewUI(5, CTexture)
			oChild.m_FloorOneTextrue = oChild:NewUI(6, CTexture)
			oChild.m_PlayerFloorActorTexture:SetUVRect(UnityEngine.Rect.New(0 , 0.05, 1, 1))
			oChild.m_MonsterFloorActorTexture:SetUVRect(UnityEngine.Rect.New(0 , 0.05, 1, 1))
			return oChild
		end)
	self.m_WrapContent:SetRefreshFunc(function(oChild, dData)
		if dData then
			if dData.floor == 1 then
				oChild.m_FloorLabel:SetActive(false)
				oChild.m_FloorOneTextrue:SetActive(true)
			else
				oChild.m_FloorLabel:SetActive(true)
				oChild.m_FloorOneTextrue:SetActive(false)
			end
	
			oChild.m_FindBtn:AddUIEvent("click", callback(self, "OnFight", dData.floor - 1))
			if dData.floor == self.m_CurLevel + 1 or 
				(self.m_CurLevel > g_PataCtrl.MaxLevel and dData.floor == self.m_CurLevel) then
				oChild.m_PlayerFloorActorTexture:SetActive(true)
				oChild.m_MonsterFloorActorTexture:SetActive(true)
				g_GuideCtrl:AddGuideUI("pata_monster_texture", oChild.m_FindBtn)
				oChild.m_PlayerFloorActorTexture:ChangeShape(g_AttrCtrl.model_info.shape, g_AttrCtrl.model_info, nil, nil, nil)

				local monsterId = g_PataCtrl:GetFloorMonsterId(self.m_CurLevel)
				if monsterId then
					oChild.m_MonsterFloorActorTexture:ChangeShape(monsterId, nil, nil , nil, nil)
				end	
				table.insert(self.m_BgCloneBoxList, oChild)		

				if g_PataCtrl:IsWipeOuting() then					
					oChild.m_PlayerFloorActorTexture:SetActive(false)
					oChild.m_MonsterFloorActorTexture:SetActive(false)
				end

				if self.m_CurLevel > g_PataCtrl.MaxLevel then
					oChild.m_MonsterFloorActorTexture:SetActive(false)
				end
				oChild.m_MonsterFloorActorTexture:OnPlay("idleCity", false)
			else

				oChild.m_PlayerFloorActorTexture:SetActive(false)
				oChild.m_MonsterFloorActorTexture:SetActive(false)		

				table.insert(self.m_BgCloneBoxList, oChild)		
			end
			oChild.m_FloorLabel:SetText(string.format("第%d层", (dData.floor - 1) ))
			local bgIndx = (dData.floor - 1) % 10
			if bgIndx == 0 then
				bgIndx =5
			end
			oChild:SetActive(true)

		else			
			oChild:SetActive(false)
		end
	end)
end

function CPaTaView.SetPataData(self, lData)
	self.m_WrapContent:SetData(lData, true)
end

function CPaTaView.ResetBg(self, curWipeLv)
	local data = {}
	local curWipeLevel = curWipeLv or g_PataCtrl:GetCurWipeOutLevelAndTime()
	local canWipeLevel = g_PataCtrl:GetWipdOutEndlevel()
	local max = 1 

	if g_PataCtrl:IsWipeOuting() then
		max = canWipeLevel + 2
	else
		max = self.m_MaxLevel + 2
	end

	if max > 101 then
		max = 101
	elseif max < 4 then		
		max = 4
	end
	 for i = 1, max do
		local d = {floor = i}
		table.insert(data, d)
	end

	local posY = 0
	local MoveLevel = 1
	if g_PataCtrl:IsWipeOuting() then
		MoveLevel = curWipeLevel 	
	else
		MoveLevel = self.m_CurLevel
	end


	self.m_BgCloneBoxList = {}
	self:SetPataData(data)
	self.m_BgScrollView:ResetPosition()		

	local offset = 0
	local h = self.m_Container:GetHeight()
	offset = ( h - 750)/2

	if MoveLevel >= CPataCtrl.MaxLevel then
		posY = 98 * 468 + 312
		self.m_WrapContent:MoveRelative(Vector3.New(0, posY, 0))
		if self.m_ReSetBgTimer then
			Utils.DelTimer(self.m_ReSetBgTimer)
			self.m_ReSetBgTimer = nil
		end
		local warp = function ()
			self.m_BgScrollView:MoveRelative(Vector3.New(0, 332 - offset, 0))
		end		
		self.m_ReSetBgTimer = Utils.AddTimer(warp, 0, 0)
	else
		posY = (MoveLevel - 1) * 468 + 312 - offset
		self.m_WrapContent:MoveRelative(Vector3.New(0, posY, 0))
	end
end

function CPaTaView.HideAllActor(self )
	if self.m_BgCloneBoxList and next(self.m_BgCloneBoxList) then
		for i = 1, #self.m_BgCloneBoxList do
			local child = self.m_BgCloneBoxList[i]
			if child.m_PlayerFloorActorTexture then
				child.m_PlayerFloorActorTexture:SetActive(false)
			end
			if child.m_MonsterFloorActorTexture then
				child.m_MonsterFloorActorTexture:SetActive(false)
			end
		end
	end
end

function CPaTaView.AniBgCheck(self, dt)
	if self.m_AniIndex == 4 or self.m_AniIndex == 5 or self.m_AniIndex == 6 then
		local t1 = Ani[4] 
		local t2 = Ani[4] 
		local t3 = Ani[6]
		local maxTime = (t3.endtime - t1.starttime)
		local posY = 468 / maxTime
		posY = posY * dt
		
		--每段动画移动的最大高度
		local perMax = 468 
		if self.m_AniIndex == 4 then
			perMax = perMax * (t1.endtime - t1.starttime) / maxTime
		elseif self.m_AniIndex == 5 then
			perMax = perMax * (t2.endtime - t2.starttime) / maxTime
		else
			perMax = perMax * (t3.endtime - t3.starttime) / maxTime
		end

		if self.m_BgMoveOffset + posY > perMax then
			posY = perMax - self.m_BgMoveOffset
		else
			self.m_BgMoveOffset = self.m_BgMoveOffset + posY
		end

		if posY ~= 0 then
			self.m_BgScrollView:MoveRelative(Vector3.New(0, posY, 0))
		end		
	end
end

function CPaTaView.InitWipeOutData(self)
	if g_PataCtrl:IsWipeOuting() then
		local wipeOutLevel, wipeOutime = g_PataCtrl:GetCurWipeOutLevelAndTime()
		self.m_AniCurWipeLevel = wipeOutLevel
		wipeOutime = wipeOutime % 15
		local time = 0 
		for i = 1, #Ani do
			local aniTime = Ani[i].endtime - Ani[i].starttime
			if time + aniTime >= wipeOutime then
				self.m_AniIndex = i	- 1					
				break
			else
				time = time + aniTime
			end
		end
		--如果处于楼梯过程，则直接跳到最后一个阶段
		if self.m_AniIndex == 3 or self.m_AniIndex == 4 or self.m_AniIndex == 5 then
			self.m_AniIndex = 6
		end
	end
end

function CPaTaView.RefreshFirstReward(self)
	if next(self.m_MyProcressList) then
		for i = 1, 5 do
			local oChild = self.m_MyProcressList[i]
			if oChild and not Utils.IsNil(oChild) then
				for _i = 1, 4 do
					local floor = (i - 1) * 20 + 5 * _i
					local oBtn = oChild.m_RewardTable[_i]
					if oBtn and not Utils.IsNil(oBtn) then
						local status = g_PataCtrl:IsHaveFirstReward(floor)
						if status == 1 then
							oBtn:SetSpriteName(string.format("pic_pt_baoxiang_guan_%d", i))
							oBtn:SetActive(true)
							oBtn.Tween.enabled = true					
						elseif status == 2 then
							oBtn:SetSpriteName(string.format("pic_pt_baoxiang_kai_%d", i))							
							oBtn:SetActive(true)
							oBtn.Tween.enabled = false
							oBtn:SetLocalRotation(Quaternion.identity)
						else
							oBtn:SetSpriteName(string.format("pic_pt_baoxiang_guan_%d", i))
							oBtn:SetActive(true)		
							oBtn.Tween.enabled = false
							oBtn:SetLocalRotation(Quaternion.identity)
						end
					end

				end
			end
		end
	end
end

function CPaTaView.RefreshWipeOutBtn(self)
	local canWipe = false
	local pataData = data.tollgatedata.PATA[self.m_CurLevel]
	if pataData then
		if g_AttrCtrl:GetTotalPower() >= pataData.recpower then
			canWipe = true
		end		
	end

	if g_PataCtrl:IsWipeOuting() or not canWipe or self.m_CurLevel == self.m_MaxLevel then
		self.m_WipeOutBtn.m_RedDot:SetActive(false)
	else
		self.m_WipeOutBtn.m_RedDot:SetActive(true)
	end
end

function CPaTaView.RefreshAward(self, level)
	self.m_AwardFloorLabel:SetText(string.format("第%d层", level))
	local pataData = data.tollgatedata.PATA[level]
	if pataData then

		if g_AttrCtrl:GetTotalPower() >= pataData.recpower then
			self.m_LeastPowerLabel:SetText(string.format("[019B71]%d", pataData.recpower))
		else
			self.m_LeastPowerLabel:SetText(string.format("[B82D0C]%d", pataData.recpower))
		end							
	end

	--没关奖励设置
	local reward = g_PataCtrl:GetPassRewardListByLevel(level)
	if next(reward) ~= nil then
		self.m_AwardGrid:SetActive(true)
		if next(self.m_AwardCloneBoxList) ~= nil then
			for k, v in ipairs(self.m_AwardCloneBoxList) do
				v:SetActive(false)
			end
		end				
		for i = 1, #reward do
			local oBox = self.m_AwardCloneBoxList[i]
			if not oBox then
				oBox = self.m_AwardCloneBox:Clone()
				self.m_AwardGrid:AddChild(oBox)
				table.insert(self.m_AwardCloneBoxList, oBox)
			end
			oBox:SetActive(true)
			local config = {isLocal = true,}
			oBox:SetItemData(reward[i].sid, reward[i].count, nil, config)			
		end
		self.m_AwardGrid:Reposition()
	else
		self.m_AwardGrid:SetActive(false)
	end
end

function CPaTaView.InitOpenEffect(self)
	local oBox = self.m_OpenEffectBox
	oBox.m_BgTexture = oBox:NewUI(1, CTexture)
	oBox.m_EffectMen = oBox:NewUI(2, CBox)
	oBox.m_EffectHuo1 = oBox:NewUI(3, CBox)
	oBox.m_EffectHuo2 = oBox:NewUI(4, CBox)
	oBox.m_EffectKaiMen = oBox:NewUI(5, CBox)
	oBox.m_EffectLeiDian = oBox:NewUI(6, CBox)
	oBox.m_EffectBaoGuang = oBox:NewUI(7, CBox)
	oBox.m_MoveWidget = oBox:NewUI(8, CBox)


end

function CPaTaView.StartOpenEffect(self)
	-- if true then
	-- 	return
	-- end
	if self.m_OpenTimerList and next(self.m_OpenTimerList) then
		for k, v in pairs(self.m_OpenTimerList) do
			Utils.DelTimer(v)
			v = nil
		end
	end

	self.m_OpenEffectBox.m_EffectMen:SetActive(false)
	self.m_OpenEffectBox.m_EffectLeiDian:SetActive(false)
	self.m_OpenEffectBox.m_EffectBaoGuang:SetActive(false)
	self.m_OpenEffectBox.m_EffectKaiMen:SetActive(false)
	self.m_OpenEffectBox:SetActive(false)

	if g_PataCtrl.m_IsClickOpen == false then
		return 
	end
	self.m_IsOpenAni = true
	g_DialogueAniCtrl:SetCacheProto(true)

	self.m_OpenEffectBox:SetActive(true)
	self.m_OpenEffectBox.m_BgTexture:SetActive(true)
	self.m_OpenEffectBox.m_EffectHuo1:SetActive(true)
	self.m_OpenEffectBox.m_EffectHuo2:SetActive(true)
	self.m_OpenEffectBox.m_MoveWidget:SetLocalPos(Vector3.New(0, 0, 0))
	self.m_RootW, self.m_RootH = UITools.GetRootSize()
	self.m_RootH = self.m_RootH / 4
	self.m_OpenTimerList[1] = Utils.AddTimer(callback(self, "EffectActive", self.m_OpenEffectBox.m_EffectMen, true), 0 , 2.2)
	self.m_OpenTimerList[2] = Utils.AddTimer(callback(self, "EffectActive", self.m_OpenEffectBox.m_EffectLeiDian, true), 0 , 0)
	self.m_OpenTimerList[3] = Utils.AddTimer(callback(self, "EffectActive", self.m_OpenEffectBox.m_EffectBaoGuang, true), 0 , 3.5)
	self.m_OpenTimerList[4] = Utils.AddTimer(callback(self, "EffectActive", self.m_OpenEffectBox.m_BgTexture, false), 0 , 3.6)
	self.m_OpenTimerList[5] = Utils.AddTimer(callback(self, "EffectActive", self.m_OpenEffectBox, false), 0 , 4)
	self.m_OpenTimerList[6] = Utils.AddTimer(callback(self, "EffectCameraPushStepOne"), 0 , 2)
	self.m_OpenTimerList[7] = Utils.AddTimer(callback(self, "EffectMoveStepOne"), 0 , 2)
	self.m_OpenTimerList[8] = Utils.AddTimer(callback(self, "EffectActive", self.m_OpenEffectBox.m_EffectHuo1, false), 0 , 2.2)
	self.m_OpenTimerList[9] = Utils.AddTimer(callback(self, "EffectActive", self.m_OpenEffectBox.m_EffectHuo2, false), 0 , 2.2)
end

function CPaTaView.EffectActive(self, obj, b1, b2)
	if obj then
		obj:SetActive(b1)
	end
end

function CPaTaView.EffectCameraPushStepOne(self)
	local oUICam = g_CameraCtrl:GetUICamera()
	self.m_CameraAction1 = CActionFloat.New(oUICam, 0.2, "SetOrthographicSize", 1, 0.9)
	self.m_CameraAction1:SetEndCallback(callback(self, "EffectCameraPushStepTwo"))
	g_ActionCtrl:AddAction(self.m_CameraAction1)
end

function CPaTaView.EffectCameraPushStepTwo(self)
	local oUICam = g_CameraCtrl:GetUICamera()
	self.m_CameraAction2 = CActionFloat.New(oUICam, 1.3, "SetOrthographicSize", 0.9, 0.5)
	self.m_CameraAction2:SetEndCallback(callback(oUICam, "SetOrthographicSize", 1))
	g_ActionCtrl:AddAction(self.m_CameraAction2)
end

function CPaTaView.EffectMoveStepOne(self)
	self.m_EffectMove1 = CActionVector.New(self.m_OpenEffectBox.m_MoveWidget, 0.2, "SetLocalPos", Vector3.New(0, 0, 0), Vector3.New(118, (self.m_RootH) * 0.1 , 0))
	self.m_EffectMove1:SetEndCallback(callback(self, "EffectMoveStepTwo"))
	g_ActionCtrl:AddAction(self.m_EffectMove1)
end

function CPaTaView.EffectMoveStepTwo(self)
	g_PataCtrl.m_IsClickOpen = false
	self.m_EffectMove2 = CActionVector.New(self.m_OpenEffectBox.m_MoveWidget, 1.3, "SetLocalPos", Vector3.New(118, (self.m_RootH) * 0.1 , 0), Vector3.New(118, (self.m_RootH) * 0.9, 0))
	self.m_EffectMove2:SetEndCallback(callback(self, "OpenEffectEnd"))
	g_ActionCtrl:AddAction(self.m_EffectMove2)
end

function CPaTaView.OpenEffectEnd(self)
	self.m_IsOpenAni = false
	local oView = CPaTaWipeView:GetView()
	if oView then
		oView.m_Container:SetActive(true)
	end	
	g_GuideCtrl:TriggerCheck("view")	
	g_DialogueAniCtrl:SetCacheProto(false)
end

function CPaTaView.InitScrollPage(self)
	self.m_MyProcressList = {}
	local oPart = self.m_ScrollPage	
	self.m_ScrollPage:SetPartSize(1, 1)
	local function factory(oClone, dData)
		if dData then
			local w, h = self.m_AdjustWidget:GetSize()	
			local offset = (w - 80) / 4				
			local oBox = oClone:Clone()	
			if oBox and not Utils.IsNil(oBox) then
				oBox.m_MyIconSpr = oBox:NewUI(1, CSprite)
				oBox.m_MyIconSpr:SetSpriteName("pic_map_avatar_" .. g_AttrCtrl.model_info.shape)		
				oBox.m_LabelTable = {}
				for i = 1, 5 do
					oBox.m_LabelTable[i] = oBox:NewUI(i + 1, CLabel)
					if i == 1 then
						oBox.m_LabelTable[i]:SetText(tostring((dData.idx - 1) * 20 + 1))
					else
						oBox.m_LabelTable[i]:SetText(tostring((dData.idx - 1) * 20 + 5 * (i -1)))
					end												
					local x = (-w /2) + 45  + (i - 1) * offset
					oBox.m_LabelTable[i]:SetLocalPos(Vector3.New(x, 65, 0))
				end
				oBox.m_RewardTable = {}
				for i = 1, 4 do
					local oBtn = oBox:NewUI(8 + i, CButton)
					local floor = (dData.idx - 1) * 20 + 5 * i
					oBtn:SetName(string.format("fist_%d", floor))
					oBtn.Tween = oBtn:GetComponent(classtype.TweenRotation)
					local x = (-w /2) + 45  + i * offset
					oBtn:SetLocalPos(Vector3.New(x, 5, 0))
					local status = g_PataCtrl:IsHaveFirstReward(floor)
					if status == 1 then
						oBtn:SetSpriteName(string.format("pic_pt_baoxiang_guan_%d", dData.idx))
						oBtn:SetActive(true)
						oBtn.Tween.enabled = true					
					elseif status == 2 then
						oBtn:SetSpriteName(string.format("pic_pt_baoxiang_kai_%d", dData.idx))							
						oBtn:SetActive(true)
						oBtn.Tween.enabled = false
						oBtn:SetLocalRotation(Quaternion.identity)
					else
						oBtn:SetSpriteName(string.format("pic_pt_baoxiang_guan_%d", dData.idx))
						oBtn:SetActive(true)		
						oBtn.Tween.enabled = false
						oBtn:SetLocalRotation(Quaternion.identity)
					end
					oBox.m_RewardTable[i] = oBtn
					oBtn:AddUIEvent("click", callback(self, "OnClickFirstReward", floor))
				end						
				oBox.m_ProgressSprite = oBox:NewUI(8, CSprite)
				oBox.m_ProgressSprite:SetSpriteName(string.format("pic_pt_jindu_bg_%d", dData.idx))
				oBox.m_ProgressSprite:SetWidth(w - 50)
				oBox.m_MyProcress = oBox:NewUI(13, CBox)
				oBox.m_MaskContent = oBox:NewUI(14, CBox)
				oBox.m_MyLabel = oBox:NewUI(15, CLabel)
				oBox.m_MaskContent:SetActive(g_PataCtrl:IsWipeOuting())
				oBox.m_MaskContent:SetSize(w, h)
				oBox:SetActive(true)
				self.m_MyProcressList[dData.idx] = oBox
				if self.m_MaxPage ~= 0 and self.m_MaxPage == dData.idx then
					Utils.AddTimer(callback(self, "DelaySetProcess"), 0 ,0)
				end		
				return oBox
			end				
		end
	end
	self.m_ScrollPage:SetFactoryFunc(factory)
	Utils.AddTimer(callback(self, "DelayInitScrollPage"), 0, 0)
end

function CPaTaView.ScrollPageSetData(self)
	self.m_MaxPage = 0
	local function data()
		local t = {}
		self.m_MaxPage = self:GetMainFloor(self.m_MaxLevel)
		for i= 1, self.m_MaxPage do
			table.insert(t, {idx = i})
		end			
		return t
	end
	self.m_ScrollPage:SetDataSource(data)
	self.m_ScrollPage:RefreshAll()

	local function cb()
		local level = self.m_CurLevel
		if level > CPataCtrl.MaxLevel then
			level = CPataCtrl.MaxLevel
		end
		--扫荡状态
		if g_PataCtrl:IsWipeOuting() then
			self:SetMyProcress(self.m_AniCurWipeLevel, true)		
			self.m_ScrollPage:OnCenterIndex(self:GetMainFloor(self.m_AniCurWipeLevel))
		else			
			self:SetMyProcress(level)		
			self.m_ScrollPage:OnCenterIndex(self:GetMainFloor(level))		
		end
	end

	Utils.AddTimer(cb, 0, 0.1)
end

function CPaTaView.OnClickFirstReward(self, floor)
	CPaTaWipeView:ShowView(function(oView)
		oView:ShowFirstReward(floor)
	end)
end

function CPaTaView.SetMyProcress(self, level, jump)
	local w, h = self.m_AdjustWidget:GetSize()	
	local offset = (w - 80) / 19	
	local offset2 = (w - 80) / 4	
	if level > 100 then
		level = 100
	end
	if next(self.m_MyProcressList) then
		local main = self:GetMainFloor(level)
		local sub = level % 20
		if sub == 0 then
			sub = 20
		end
		for i = 1, 5 do
			if self.m_MyProcressList[i] and not Utils.IsNil(self.m_MyProcressList[i].m_MyProcress) and 
				not Utils.IsNil(self.m_MyProcressList[i].m_MyLabel) then
				if i == main then
					self.m_MyProcressList[i].m_MyProcress:SetActive(true)
					local x
					if sub % 5 == 0 then
						x = (-w /2) + 45  + (sub / 5) * offset2
					else
						x = (-w /2) + 0 + sub * offset
					end				
					self.m_MyProcressList[i].m_MyProcress:SetLocalPos(Vector3.New(x, 40, 0))
					self.m_MyProcressList[i].m_MyLabel:SetText(tostring(level))
				else
					self.m_MyProcressList[i].m_MyProcress:SetActive(false)
				end
				if sub == 1 and jump then
					self.m_ScrollPage:OnCenterIndex(main, true)
				end	
			end		
		end
	end
end

--获取所在大层
function CPaTaView.GetMainFloor(self, level)
	local main = 1
	if level < 21 then
		main = 1
	elseif level < 41 then
		main = 2
	elseif level < 61 then
		main = 3
	elseif level < 81 then
		main = 4
	else
		main = 5
	end
	return main
end

function CPaTaView.SetProcressDragMaskContentActive(self, b)
	if next(self.m_MyProcressList) then
		for i = 1, 5 do
			if self.m_MyProcressList[i] then
				local content = self.m_MyProcressList[i].m_MaskContent
				if content and not Utils.IsNil(content) then
					content:SetActive(b)
				end				
			end
		end
	end
end

function CPaTaView.DelaySetProcess(self)
	if g_PataCtrl:IsWipeOuting() then
		--重置背景	
		self:SetMyProcress(self.m_AniCurWipeLevel, true)	

		self:SetProcressDragMaskContentActive(true)	
	else								
		self:SetMyProcress(self.m_CurLevel)		
		self:SetProcressDragMaskContentActive(false)	
	end	
end

function CPaTaView.DelayInitScrollPage(self)
	if Utils.IsNil(self) then
		return
	end
	local w, h = self.m_AdjustWidget:GetSize()	
	self.m_PageGrid:SetCellSize(w + 10, 485)
	self.m_PageGrid:Reposition()
	self.m_PageGrid:ReActive()
end

return CPaTaView