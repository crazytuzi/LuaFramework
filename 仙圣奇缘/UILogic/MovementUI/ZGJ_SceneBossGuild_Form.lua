--------------------------------------------------------------------------------------
-- 文件名:	Class_Fate.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	周光剑
-- 日  期:	2015-6-30
-- 版  本:	1.0
-- 描  述:	精英副本Form
-- 应  用:  
---------------------------------------------------------------------------------------

Game_SceneBossGuild = class("Game_SceneBossGuild")
Game_SceneBossGuild.__index = Game_SceneBossGuild

function Game_SceneBossGuild:setCDBar(nTime)
	self.Image_DeadCD = self.rootWidget:getChildByName("Image_DeadCD")
	g_CDBar:register(self.Image_DeadCD, VipType.VipBuyOpType_GuildSceneBossCD, nTime, function ()
			g_RoleSystem:clearCD()
		end)
end

function Game_SceneBossGuild:setBlock(bFlag)
	self.Image_Block:setVisible(bFlag)
	g_RoleSystem:setBlocked(bFlag)
end

function Game_SceneBossGuild:setBossInfo(tbMonster)
	if not tbMonster.bInit then
		tbMonster.bInit = true
		self.Label_Name:setText(tbMonster.szName)
		self.Image_StarLevel:loadTexture(getIconStarLev(tbMonster.nStarLevel or 5))
		self.Image_Icon:loadTexture(getIconImg(tbMonster.szPainting))
		g_AdjustWidgetsPosition({self.Label_Name, self.Label_DeadFlag}, 10)
		
		local function onClick_Image_Head(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				local CSV_ActivityWorldBoss = g_DataMgr:getCsvConfigByOneKey("ActivityWorldBoss", tbMonster.nWorldBossCfgId)
				g_WndMgr:openWnd("Game_CardHandBook", CSV_ActivityWorldBoss.HunPoRewardID)
			end
		end
		self.Image_Head:setTouchEnabled(true)
		self.Image_Head:addTouchEventListener(onClick_Image_Head)
	end
	self.Label_Hp:setText(tbMonster.nHp.."/"..tbMonster.nMaxHp)
	self.ProgressBar_Hp:setPercent(tbMonster.nHp / tbMonster.nMaxHp * 100)

	self.Label_DeadFlag:setVisible(false)
	if tbMonster.nHp <= 0 then
		--self.Button_YueLiGuWu:setTouchEnabled(false)
		--self.Button_YuanBaoGuWu:setTouchEnabled(false)
		self.Label_DeadFlag:setVisible(true)
		g_RoleSystem:bossDead()
	end
	
	local CSV_ActivityWorldBoss = g_DataMgr:getCsvConfigByOneKey("ActivityWorldBoss", tbMonster.nWorldBossCfgId)
	local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(CSV_ActivityWorldBoss.HunPoRewardID)
	local Button_FengYinGuildGuide = tolua.cast(self.rootWidget:getChildByName("Button_FengYinGuildGuide"), "Button")
	g_RegisterGuideTipButton(Button_FengYinGuildGuide, nil, nil, CSV_ActivityWorldBoss.HunPoRewardID)
end

function Game_SceneBossGuild:setRankInfo(tb)
	self.Image_DamgeRank:setVisible(true)
	if tb.tbRank then
		for k, v in ipairs(tb.tbRank) do
			if k > 5 then
				break
			end
			local Label_Rank = tolua.cast(self.Image_DamgeRank:getChildByName("Label_Rank"..k), "Label")
			Label_Rank:setVisible(true)
			Label_Rank:setText(k.." "..v.name)
			local Label_Damage = tolua.cast(Label_Rank:getChildByName("Label_Damage"), "Label")
			local nSortDamagePrecent = math.floor(v.damage/tb.nBossHp * 10000)
			local strDamagePrecent = string.format("%.2f", nSortDamagePrecent/100)
			Label_Damage:setText(v.damage.."("..strDamagePrecent.."%)")
		end
		for i = #tb.tbRank+1, 5 do
			local Label_Rank = tolua.cast(self.Image_DamgeRank:getChildByName("Label_Rank"..i), "Label")
			Label_Rank:setVisible(false)
		end
	end
	if tb.nMyDamege then
		local Label_Damage = tolua.cast(self.Image_DamgeRank:getChildByName("Label_Damage"), "Label")
		local nSortDamagePrecent = math.floor(tb.nMyDamege/tb.nBossHp * 10000)
		local strDamagePrecent = string.format("%.2f", nSortDamagePrecent/100)
		self.Label_MyDamage:setText(_T("您对Boss造成的伤害为")..tb.nMyDamege.."("..strDamagePrecent.."%)")
	end

end

function Game_SceneBossGuild:onClickRank(widget, eventType)
	if ccs.TouchEventType.ended == eventType then
		g_WBSystem:showRankList()
	end
end

function Game_SceneBossGuild:onClickFloor(widget, eventType)
	if ccs.TouchEventType.ended == eventType then
		local pos = widget:getTouchEndPos()
		pos.x = pos.x - self.Image_Floor:getPositionX()
		g_RoleSystem:myMove(pos)
		
		if g_PlayerGuide:checkCurrentGuideSequenceNode("ActionEventStart", "Game_SceneBossGuild") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
end

function Game_SceneBossGuild:onCheckBox_AutoFight(widget, eventType)
	if ccs.CheckBoxEventType.selected == eventType then
		g_FormMsgSystem:PostFormMsg(FormMsg_Movement_Cursor, {bVisible = false} )
		g_RoleSystem:setAutoFight(true)
	else
		g_RoleSystem:setAutoFight(false)
	end
end

function Game_SceneBossGuild:onCheckBox_HidePlayer(widget, eventType)
	if ccs.CheckBoxEventType.selected == eventType then
		g_RoleSystem:setHidePlayer(true)
	else
		g_RoleSystem:setHidePlayer(false)
	end
end

function Game_SceneBossGuild:onCheckBox_AutoReborn(widget, eventType)
	if ccs.CheckBoxEventType.selected == eventType then
		local str = _T("勾选自动复活将会使用元宝自动复活，是否自动？")
		g_ClientMsgTips:showConfirm(str, function () g_WBSystem:setAutoReborn(true) end, function () widget:setSelectedState(false) end)
	else
		g_WBSystem:setAutoReborn(false)
	end
end

function Game_SceneBossGuild:onClickCheckBox_Image(widget, eventType)
	if ccs.TouchEventType.ended == eventType then
		local checkBox = widget:getParent()
		--cclog(tolua.type(checkBox))
		checkBox:guidReleaseUpEvent()
	end
end

function Game_SceneBossGuild:refreshGuWu()
	local nYueli = g_WBSystem:getGuWu(macro_pb.GUILD_SCENE_BOSS_TYPE, COST.YueLi)
	if 0 == nYueli then
		self.Label_AttackBuff_YueLi:setText("")
	else
		self.Label_AttackBuff_YueLi:setText(_T("攻击 +").." "..(10*nYueli).."%")
	end
	local nYuanBao = g_WBSystem:getGuWu(macro_pb.GUILD_SCENE_BOSS_TYPE, COST.YuanBao)
	if 0 == nYuanBao then
		self.Label_AttackBuff_YuanBao:setText("")
	else
		self.Label_AttackBuff_YuanBao:setText(_T("攻击 +").." "..(10*nYuanBao).."%")
	end
end

function Game_SceneBossGuild:initGuWu()
	local function onClick_Button_ZhenRong(pSender, nTag)
		g_WndMgr:showWnd("Game_BattleBuZhen")
	end
	self.Button_ZhenRong = tolua.cast(self.rootWidget:getChildByName("Button_ZhenRong"), "Button")
	g_SetBtnWithPressingEventAndImage(self.Button_ZhenRong, 1, nil, onClick_Button_ZhenRong, nil, true, 0.25)
	
	local function onClickYueLi(widget, nTag)
		local cost = g_WBSystem:getGuWuCost(macro_pb.GUILD_SCENE_BOSS_TYPE, COST.YueLi)
		if cost > g_Hero:getKnowledge() then
			g_ShowSysTips({text = _T("阅历不足")})
			return
		end
		g_WBSystem:requestGuWu(macro_pb.GUILD_SCENE_BOSS_TYPE, false)
	end
	self.Button_YueLiGuWu = tolua.cast(self.rootWidget:getChildAllByName("Button_YueLiGuWu"), "Button")
	g_SetBtnWithPressingEventAndImage(self.Button_YueLiGuWu, 1, g_OnShowTip, onClickYueLi, g_OnCloseTip, true, 0.25)
	self.Label_AttackBuff_YueLi = tolua.cast(self.Button_YueLiGuWu:getChildByName("Label_AttackBuff"), "Label")

	local function onClickYuanBao(widget, nTag)
		local cost = g_WBSystem:getGuWuCost(macro_pb.GUILD_SCENE_BOSS_TYPE, COST.YuanBao)
		if not g_CheckYuanBaoConfirm(cost, _T("元宝鼓舞需要消耗")..cost.._T("元宝, 您的元宝不足是否前往充值")) then
			return
		end
		g_WBSystem:requestGuWu(macro_pb.GUILD_SCENE_BOSS_TYPE, true)
	end
	self.Button_YuanBaoGuWu = tolua.cast(self.rootWidget:getChildAllByName("Button_YuanBaoGuWu"), "Button")
	g_SetBtnWithPressingEventAndImage(self.Button_YuanBaoGuWu, 1, g_OnShowTip, onClickYuanBao, g_OnCloseTip, true, 0.25)
	self.Label_AttackBuff_YuanBao = tolua.cast(self.Button_YuanBaoGuWu:getChildByName("Label_AttackBuff"), "Label")

end

function Game_SceneBossGuild:initWnd()
	-- 请求离开战斗以免卡住
	g_MsgMgr:sendMsg(msgid_pb.MSGID_MOVE_EXIT_BOSS_FIGHT)
	
	g_RoleSystem:init(self.rootWidget)
	
	--元宝鼓舞
	self:initGuWu()

	self.Image_Background = self.rootWidget:getChildAllByName("Image_Background")
	self.Image_Floor = self.rootWidget:getChildAllByName("Image_Floor")

	self.Image_Floor:setTouchEnabled(true)
	self.Image_Floor:addTouchEventListener(handler(self, self.onClickFloor))
	self.Image_Block = self.Image_Floor:getChildByName("Image_Block")
	self.Image_Block:setZOrder(9999)


	--boss信息相关
	self.Image_BossInfoPNL = self.rootWidget:getChildAllByName("Image_BossInfoPNL")
	self.Image_Head = tolua.cast(self.Image_BossInfoPNL:getChildAllByName("Image_Head"), "ImageView")
	self.Image_Icon = tolua.cast(self.Image_Head:getChildAllByName("Image_Icon"), "ImageView")
	self.Image_StarLevel = tolua.cast(self.Image_BossInfoPNL:getChildAllByName("Image_StarLevel"), "ImageView")
	self.Label_Name = tolua.cast(self.Image_BossInfoPNL:getChildAllByName("Label_Name"), "Label")
	self.ProgressBar_Hp = tolua.cast(self.Image_BossInfoPNL:getChildAllByName("ProgressBar_Hp"), "LoadingBar")
	self.Label_Hp = tolua.cast(self.Image_BossInfoPNL:getChildAllByName("Label_Hp"), "Label")
	self.Label_DeadFlag = tolua.cast(self.Image_BossInfoPNL:getChildAllByName("Label_DeadFlag"), "Label")
	self.Label_DeadFlag:setVisible(false)
	
	self.Image_RefreshCountPNL = self.rootWidget:getChildByName("Image_RefreshCountPNL")
	self.Label_RefreshRemainTime = tolua.cast(self.Image_RefreshCountPNL:getChildAllByName("Label_RefreshRemainTime"), "Label")
	local csv = g_DataMgr:getCsvConfig_FirstKeyData("GuildActivity", macro_pb.GAT_SCENE_BOSS)--g_DataMgr:getCsvConfigByTwoKey("ActivityBase", macro_pb.GUILD_SCENE_BOSS_TYPE, 1)
	local nStartHour, nStartMin = csv.StarTimeH, csv.StarTimeM
	local nEndHour, nEndMin = csv.EndTimeH, csv.EndTimeM
	local tbServerTime = SecondsToTable(g_GetServerTime())
	self.nOpenTime = (nStartHour - 8) * 60 * 60 + nStartMin * 60 + (tbServerTime.hour - tbServerTime.hour % 24) * 60 * 60
	self.nEndTime = (nEndHour - 8) * 60 * 60 + nEndMin * 60 + (tbServerTime.hour - tbServerTime.hour % 24) * 60 * 60
	self:setRefreshTime()
	self.nTimerID_Game_SceneBossGuild_1 = g_Timer:pushLoopTimer(1, handler(self, self.setRefreshTime))



	self.Image_DamgeRank = self.rootWidget:getChildAllByName("Image_DamgeRank")
	self.Image_DamgeRank:setVisible(false)
	self.Label_MyDamage = tolua.cast(self.Image_DamgeRank:getChildByName("Label_MyDamage"), "Label")

	self.Image_DamgeRank:setTouchEnabled(true)
	self.Image_DamgeRank:addTouchEventListener(handler(self, self.onClickRank))

	self.CheckBox_AutoFight = tolua.cast(self.rootWidget:getChildAllByName("CheckBox_AutoFight"), "CheckBox")
	local Image_FuncName = self.CheckBox_AutoFight:getChildAllByName("Image_FuncName")
	Image_FuncName:setTouchEnabled(true)
	Image_FuncName:addTouchEventListener(handler(self, self.onClickCheckBox_Image))
	self.CheckBox_AutoFight:addEventListenerCheckBox(handler(self, self.onCheckBox_AutoFight))

	self.CheckBox_HidePlayer = tolua.cast(self.rootWidget:getChildAllByName("CheckBox_HidePlayer"), "CheckBox")
	local Image_FuncName = self.CheckBox_HidePlayer:getChildAllByName("Image_FuncName")
	Image_FuncName:setTouchEnabled(true)
	Image_FuncName:addTouchEventListener(handler(self, self.onClickCheckBox_Image))
	self.CheckBox_HidePlayer:addEventListenerCheckBox(handler(self, self.onCheckBox_HidePlayer))

	self.CheckBox_ZiDongFuHuo = tolua.cast(self.rootWidget:getChildAllByName("CheckBox_ZiDongFuHuo"), "CheckBox")
	local Image_FuncName = self.CheckBox_ZiDongFuHuo:getChildAllByName("Image_FuncName")
	Image_FuncName:setTouchEnabled(true)
	Image_FuncName:addTouchEventListener(handler(self, self.onClickCheckBox_Image))
	self.CheckBox_ZiDongFuHuo:addEventListenerCheckBox(handler(self, self.onCheckBox_AutoReborn))
	

	--注册消息
	g_FormMsgSystem:RegisterFormMsg(FormMsg_WorldBoss2_BossInfo, handler(self, self.setBossInfo))
	g_FormMsgSystem:RegisterFormMsg(FormMsg_WorldBoss2_Rank, handler(self, self.setRankInfo))
	g_FormMsgSystem:RegisterFormMsg(FormMsg_WorldBoss2_Block, handler(self, self.setBlock))
	g_FormMsgSystem:RegisterFormMsg(FormMsg_WorldBoss2_CD, handler(self, self.setCDBar))
	g_FormMsgSystem:RegisterFormMsg(FormMsg_WorldBoss2_GuWu, handler(self, self.refreshGuWu))
	g_FormMsgSystem:RegisterFormMsg(FormMsg_WorldBoss2_ClearCD, handler(self, self.clearCD))
	--g_FormMsgSystem:RegisterFormMsg(FormMsg_Movement_Cursor, handler(self, self.setCursor))
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local Image_Texture1 = tolua.cast(Image_Background:getChildByName("Image_Texture1"), "ImageView")
	Image_Texture1:loadTexture(getBackgroundJpgImg("JiHuiSuo"))
	local Image_Texture2 = tolua.cast(Image_Background:getChildByName("Image_Texture2"), "ImageView")
	Image_Texture2:loadTexture(getBackgroundJpgImg("JiHuiSuo"))
	
	local Image_Floor = tolua.cast(self.rootWidget:getChildByName("Image_Floor"), "ImageView")
	local Image_Texture1 = tolua.cast(Image_Floor:getChildByName("Image_Texture1"), "ImageView")
	Image_Texture1:loadTexture(getBackgroundPngImg("WorldBoss1"))
	local Image_Texture2 = tolua.cast(Image_Floor:getChildByName("Image_Texture2"), "ImageView")
	Image_Texture2:loadTexture(getBackgroundPngImg("WorldBoss1"))
end

function Game_SceneBossGuild:checkData()
	if not g_WBSystem:isInit(macro_pb.GUILD_SCENE_BOSS_TYPE) then
		-- 进入之前先向服务端请求离开场景以免卡住
		g_MsgMgr:sendMsg(msgid_pb.MSGID_MOVE_EXIT_BOSS_FIGHT)
		g_RoleSystem:requestExit()
		g_RoleSystem:requestEnter(macro_pb.SceneType_GuildBoss)
		g_WBSystem:requestEnterWB(macro_pb.GUILD_SCENE_BOSS_TYPE)
		return false
	end
	return true
end

function Game_SceneBossGuild:openWnd()
	if g_Guild:getGuildID() <= 0 then
		g_WndMgr:closeWnd("Game_SceneBossGuild")
	end
end

function Game_SceneBossGuild:closeWnd()
	g_RoleSystem:requestExit()
	g_RoleSystem:destroy()
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_WorldBoss2_Block)
	g_CDBar:unRegister(VipType.VipBuyOpType_SceneBossDeadCD)
	g_Timer:destroyTimerByID(self.nTimerID_Game_SceneBossGuild_1)
	self.nTimerID_Game_SceneBossGuild_1 = nil

	g_WBSystem:setAutoReborn(false)

	g_FormMsgSystem:UnRegistFormMsg(FormMsg_WorldBoss2_BossInfo)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_WorldBoss2_Rank)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_WorldBoss2_Block)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_WorldBoss2_CD)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_WorldBoss2_GuWu)
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local Image_Texture1 = tolua.cast(Image_Background:getChildByName("Image_Texture1"), "ImageView")
	Image_Texture1:loadTexture(getUIImg("Blank"))
	local Image_Texture2 = tolua.cast(Image_Background:getChildByName("Image_Texture2"), "ImageView")
	Image_Texture2:loadTexture(getUIImg("Blank"))
	
	local Image_Floor = tolua.cast(self.rootWidget:getChildByName("Image_Floor"), "ImageView")
	local Image_Texture1 = tolua.cast(Image_Floor:getChildByName("Image_Texture1"), "ImageView")
	Image_Texture1:loadTexture(getUIImg("Blank"))
	local Image_Texture2 = tolua.cast(Image_Floor:getChildByName("Image_Texture2"), "ImageView")
	Image_Texture2:loadTexture(getUIImg("Blank"))

	--优化因窗口缓存
	self.CheckBox_AutoFight:setSelectedState(false)
	self.CheckBox_HidePlayer:setSelectedState(false)
	self.CheckBox_ZiDongFuHuo:setSelectedState(false)

	g_WBSystem:reset()
end

function Game_SceneBossGuild:setRefreshTime()
	if not g_WndMgr:getWnd("Game_SceneBossGuild") then return true end
	
	local tbServerTime = SecondsToTable(g_GetServerTime())
	local nTime2 = self.nEndTime - g_GetServerTime()
	if nTime2 <= 0 then
		self.nOpenTime = self.nOpenTime + 86400
		self.nEndTime = self.nEndTime + 86400
		-- self.Button_YueLiGuWu:setTouchEnabled(false)
		-- self.Button_YuanBaoGuWu:setTouchEnabled(false)
	end
	local nTime1 = self.nOpenTime - g_GetServerTime()
	if nTime1 <= 0 then
		self.Image_RefreshCountPNL:setVisible(false)
		self.Image_BossInfoPNL:setVisible(true)
		-- g_Timer:destroyTimerByID(self.nTimerID_Game_SceneBossGuild_1)
		-- self.nTimerID_Game_SceneBossGuild_1 = nil
	else
		self.Image_RefreshCountPNL:setVisible(true)
		self.Image_BossInfoPNL:setVisible(false)
		self.Label_RefreshRemainTime:setText(TimeTableToStr(SecondsToTable(nTime1),":"))
	end
end

function Game_SceneBossGuild:clearCD()
	if g_WBSystem:getAutoReborn() and self.Image_DeadCD:isVisible() then
		self.bOpen = true
		local nType = VipType.VipBuyOpType_GuildSceneBossCD
		local gold = g_VIPBase:getVipLevelCDGold(nType)
		if not g_CheckYuanBaoConfirm(gold,_T("您的元宝不足是否前往充值")) then
			return
		end
		g_VIPBase:responseFunc(function ()
				self.Image_DeadCD:setVisible(false)
				g_CDBar:unRegister(VipType.VipBuyOpType_GuildSceneBossCD)
				g_RoleSystem:clearCD()
				--z自动复活
				gTalkingData:onPurchase(TDPurchase_Type.TDP_WORLD_BOSS_Auto_Life,1,gold)	
				
			end)
		g_VIPBase:requestVipBuyTimesRequest(nType)
		return
	end
end

function Game_SceneBossGuild:ModifyWnd_viet_VIET()
    local Label_RefreshRemainTimeLB = self.rootWidget:getChildAllByName("Label_RefreshRemainTimeLB")
	local Label_RefreshRemainTime = self.rootWidget:getChildAllByName("Label_RefreshRemainTime")
	Label_RefreshRemainTimeLB:setPositionX(-(Label_RefreshRemainTimeLB:getSize().width+Label_RefreshRemainTime:getSize().width)/2)
    g_AdjustWidgetsPosition({Label_RefreshRemainTimeLB, Label_RefreshRemainTime},5)

    local CheckBox_AutoFight = self.rootWidget:getChildAllByName("CheckBox_AutoFight")
	local CheckBox_ZiDongFuHuo = self.rootWidget:getChildAllByName("CheckBox_ZiDongFuHuo")
	CheckBox_ZiDongFuHuo:setPositionX(CheckBox_AutoFight:getPositionX() + 220)
	local CheckBox_HidePlayer = self.rootWidget:getChildAllByName("CheckBox_HidePlayer")
	CheckBox_HidePlayer:setPositionX(CheckBox_ZiDongFuHuo:getPositionX() + 200)
end
