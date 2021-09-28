--------------------------------------------------------------------------------------
-- 文件名:	WorldBossWnd.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	陆奎安
-- 日  期:	2013-3-4 9:37
-- 版  本:	1.0
-- 描  述:	召唤界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------
Game_WorldBossGuild = class("Game_WorldBossGuild")
Game_WorldBossGuild.__index = Game_WorldBossGuild


function Game_WorldBossGuild:checkTime(tbAct)
    -- local nCurTime = g_GetServerHour()*60 +g_GetServerMin()
    -- local list = string.split(tbAct.StarTime, ":");
    -- local nBegin = tonumber(list[1])*60 + tonumber(list[2])
    -- list = string.split(tbAct.EndTime, ":");
    -- local nEnd = tonumber(list[1])*60 + tonumber(list[2])
    -- if nCurTime >= nBegin and nCurTime <= nEnd then
    --     return true
    -- else
    --     return false
    -- end
    return self.monster_type ~= 0
end

function Game_WorldBossGuild:initWnd()
	local Button_Challenge = tolua.cast(self.rootWidget:getChildByName("Button_Challenge"),"Button")
	--冷却时间
	local Image_CoolTime = tolua.cast(Button_Challenge:getChildByName("Image_CoolTime"),"ImageView")
	local BitmapLabel_FuncName = tolua.cast(Button_Challenge:getChildByName("BitmapLabel_FuncName"),"Label")
	--------------挑战按钮--------------
    local function onClickBuChallenge(pSender, nTag)
		if self.bSendMsgFlag then return end

		if self.bChallengeColdDown then
			local types = VipType.VipBuyOpType_GuildWorldBossCD
			local gold = g_VIPBase:getVipLevelCDGold(types)
			if not g_CheckYuanBaoConfirm(gold,_T("清除冷却时间需要花费")..gold.._T("元宝，您的元宝不够是否前往充值？")) then
				return
			end
			
			local str = _T("是否花费")..gold.._T("元宝清除冷却时间？")
			g_ClientMsgTips:showConfirm(str, function() 
				local function f()
					self.bChallengeColdDown = false
					g_ShowSysTips({text = _T("冷却时间清除成功")})
					
					gTalkingData:onPurchase(TDPurchase_Type.TDP_WORLD_BOSS_REMOVE_CD,1,gold)	
				
					--删除定时器
					if self.nTimerID_Game_WorldBossGuild_1 then
						g_Timer:destroyTimerByID(self.nTimerID_Game_WorldBossGuild_1)
						self.nTimerID_Game_WorldBossGuild_1 = nil
					end
					
					local Image_CoolTime = tolua.cast(Button_Challenge:getChildByName("Image_CoolTime"),"ImageView")
					Image_CoolTime:setVisible(false)
					BitmapLabel_FuncName:setVisible(true)
					self.nWaitTime = nil
				end
				g_VIPBase:responseFunc(f)
				g_VIPBase:requestVipBuyTimesRequest(types)
			end)
			
			return
		end

		if self.nWaitTime then
			g_ClientMsgTips:showMsgConfirm(_T("Boss即将刷新，请耐心等待"))
			return
		end

		local tbAct = g_DataMgr:getCsvConfig_FirstKeyData("ActivityBase", 7)
		if not tbAct then return false end

		local function setFlag()
		   self.bSendMsgFlag = true
		   local function resetFlag()
			   self.bSendMsgFlag = nil
		   end
		   self.nTimerID_Game_WorldBossGuild_2 = g_Timer:pushTimer(2, resetFlag)
		end
		if self:checkTime(tbAct) then
			g_MsgNetWorkWarning:showWarningText()
			g_WBSystem:requestAttack(macro_pb.GUILD_WORLD_BOSS_TYPE)
			--g_MsgMgr:requestActivity(macro_pb.ActivityType_AMBoss)
			self.missionId = macro_pb.ActivityType_AMBoss
			setFlag()
		else
			tbAct = g_DataMgr:getCsvConfig_FirstKeyData("ActivityBase", 8)
			if not tbAct then return false end
			if self:checkTime(tbAct) then
				g_MsgNetWorkWarning:showWarningText()
				g_MsgMgr:requestActivity(self.bossTag)
				self.missionId = self.bossTag
				setFlag()
			else
				g_ClientMsgTips:showMsgConfirm(_T("不在活动时间内"))
			end
		end
    end

	g_SetBtnWithGuideCheck(Button_Challenge, 1, onClickBuChallenge, true)

	local types = VipType.VipBuyOpType_WorldBossDeadCD
	self.nColdDownTime =  g_VIPBase:getVipLevelCD(types)

    self.nMaxCount = g_DataMgr:getCsvConfig_FirstKeyData("GuildActivity", 2)["MaxTimes"]
	
	-- add by zgj
	self:initGuWu()
	g_FormMsgSystem:RegisterFormMsg(FormMsg_WorldBoss1_GuWu, handler(self, self.refreshGuWu))
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getSceneImg("GuildWar"))
end

function Game_WorldBossGuild:getChallengeCount()
    return g_Hero:getDailyNoticeByType(macro_pb.DT_GUILD_WORLD_BOSS)
end

function Game_WorldBossGuild:refreshChallengeCount()
	local nChallengeCount = self.nMaxCount - self:getChallengeCount()
	local Button_Challenge = tolua.cast(self.rootWidget:getChildByName("Button_Challenge"),"Button")
	local Label_FuncMsg = tolua.cast(Button_Challenge:getChildByName("Label_FuncMsg"),"Label")
	Label_FuncMsg:setText(_T("剩余挑战次数").." "..self:getChallengeCount().."/"..self.nMaxCount)
end

local function setCoolTime(Label_CoolTime, nTime)
    local nHour = math.floor(nTime/3600)
    local nMin = math.floor((nTime - nHour*3600)/60)
    local nSec = math.mod(nTime, 60)
    local szText= string.format("%02d:%02d", nMin, nSec)
    Label_CoolTime:setText(szText)
end

function Game_WorldBossGuild:refreshBossAttendTime(boss_left_hp)
	boss_left_hp = boss_left_hp or 0
	
	local nChallengeCount = self:getChallengeCount()
	local Button_Challenge = tolua.cast(self.rootWidget:getChildByName("Button_Challenge"),"Button")
	
	--挑战次数
	local Label_ChallengeTime = tolua.cast(self.rootWidget:getChildByName("Label_ChallengeTime"),"Label")
	Label_ChallengeTime:setText(_T("挑战次数").." "..nChallengeCount.."/"..self.nMaxCount)
	
	-- local Button_AddTimes = tolua.cast(Label_ChallengeTime:getChildByName("Button_AddTimes"),"Button")
	
	-- local function onClickAddTimes(pSender,eventType)
	-- 	if eventType == ccs.TouchEventType.ended then 	
	-- 		local gold = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_WorldBossTimes)
	-- 		local allNum = g_VIPBase:getVipLevelCntNum(VipType.VipBuyOpType_WorldBossTimes)
	-- 		local addNum = g_VIPBase:getAddTableByNum(VipType.VipBuyOpType_WorldBossTimes)
	-- 		if addNum >= allNum then 
	-- 			g_ShowSysTips({text=_T("您今日斩仙台的购买次数已用完\n下一VIP等级可以增加购买次数上限")})
	-- 			return
	-- 		end
			
	-- 		if not g_CheckYuanBaoConfirm(gold,_T("购买斩仙台次数需要花费")..gold.._T("元宝，您的元宝不够是否前往充值？")) then
	-- 			return
	-- 		end
			
	-- 		local str = _T("是否花费")..gold.._T("元宝购买1次斩仙台？")
	-- 		g_ClientMsgTips:showConfirm(str, function() 
	-- 			local function sellBossNumFunc(times)
	-- 				local CSV_ActivityBase = g_DataMgr:getCsvConfig_FirstKeyData("ActivityBase", 7)
	-- 				self.nMaxCount = CSV_ActivityBase.MaxTimes + times
	-- 				Label_ChallengeTime:setText(_T("挑战次数").." "..nChallengeCount.."/"..self.nMaxCount)
	-- 				g_ShowSysTips({text = _T("成功购买1次斩仙台挑战次数\n您还可购买")..allNum-times.._T("次。")})
					
					
	-- 				local nWidth1 = Label_ChallengeTime:getSize().width
	-- 				local nWidth2 = Button_AddTimes:getSize().width
	-- 				Button_AddTimes:setPositionX(nWidth1-20)
	-- 				Label_ChallengeTime:setPositionX(640-(nWidth1 + nWidth2 - 60)/2)
					
	-- 				Button_Challenge:setTouchEnabled(true)
	-- 				Button_Challenge:setBright(true)
	-- 			end
	-- 			g_VIPBase:responseFunc(sellBossNumFunc)
	-- 			g_VIPBase:requestVipBuyTimesRequest(VipType.VipBuyOpType_WorldBossTimes)
	-- 		end)
	-- 	end
	-- end
	
	-- Button_AddTimes:setTouchEnabled(true)
	-- Button_AddTimes:addTouchEventListener(onClickAddTimes)
	
	-- local nWidth1 = Label_ChallengeTime:getSize().width
	-- -- local nWidth2 = Button_AddTimes:getSize().width
	-- -- Button_AddTimes:setPositionX(nWidth1-20)
	-- Label_ChallengeTime:setPositionX(640-(nWidth1 + nWidth2 - 60)/2)
	--冷却时间
	local Image_CoolTime = tolua.cast(Button_Challenge:getChildByName("Image_CoolTime"),"ImageView")
	local Label_CoolTime = tolua.cast(Image_CoolTime:getChildByName("Label_CoolTime"),"Label")
	local BitmapLabel_FuncName = tolua.cast(Button_Challenge:getChildByName("BitmapLabel_FuncName"),"Label")
   	
	if self.nWaitTime then
        setCoolTime(Label_CoolTime, self.nWaitTime)
		Image_CoolTime:setVisible(true)
		--冷却时间
		local cooldown = SecondsToTable(self.nWaitTime)
		Label_CoolTime:setText(TimeTableToStr(cooldown,":",true))
		BitmapLabel_FuncName:setVisible(false)
    else
		-- 挑战次数
		Image_CoolTime:setVisible(false)
		BitmapLabel_FuncName:setVisible(true)
    end    
	
	local btnEnabled = boss_left_hp > 0 and nChallengeCount < self.nMaxCount
	Button_Challenge:setTouchEnabled(btnEnabled)
	Button_Challenge:setBright(btnEnabled)
	
	local Panel_Card = tolua.cast(self.rootWidget:getChildByName("Panel_Card"),"Layout")
	local Image_DeadFlag = tolua.cast(Panel_Card:getChildByName("Image_DeadFlag"),"ImageView")
	local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"),"ImageView")
	if boss_left_hp <= 0 then
		Image_DeadFlag:setVisible(true)
		Image_Card:setColor(ccc3(150,150,150))
	else
		Image_DeadFlag:setVisible(false)
		Image_Card:setColor(ccc3(255,255,255))
	end
end


function Game_WorldBossGuild:refreshWorldBossWnd(tbMsg)
	local tbBossInfo = tbMsg.sort_damage_lst or {}
	local boss_left_hp = tbMsg.boss_left_hp
	local monster_type = tbMsg.boss_monster_type
    local Panel_Card = tolua.cast(self.rootWidget:getChildByName("Panel_Card"),"Layout")
	local Image_DamgeRank = tolua.cast(self.rootWidget:getChildByName("Image_DamgeRank"),"ImageView")
    self.monster_type = monster_type
	if not monster_type or monster_type == 0 then   
        Image_DamgeRank:setVisible(false)
        self:setPanelCard()
        Panel_Card:setVisible(false)
		return
    else
        Panel_Card:setVisible(true)
        Image_DamgeRank:setVisible(true)
	end
    self.nLastChallenge = tbMsg.last_atk_time 
	local self_damage = tbMsg.self_damage
	
	local CSV_ActivityWorldBoss = g_DataMgr:getCsvConfigByOneKey("ActivityWorldBoss", tbMsg.boss_id)
	local CSV_MonsterBase = g_DataMgr:getMonsterBaseCsv(monster_type)

    --排名
    Image_DamgeRank:setTouchEnabled(true)
    Image_DamgeRank:addTouchEventListener(self:registerClickShowRank())
	
	local Image_NameBack = tolua.cast(Panel_Card:getChildByName("Image_NameBack"),"ImageView")
	local Label_Name = tolua.cast(Image_NameBack:getChildByName("Label_Name"),"Label")
	Label_Name:setText(CSV_MonsterBase.Name)
	g_SetCardNameColorByEvoluteLev(Label_Name, CSV_ActivityWorldBoss.EvoluteLevel)
	
	local Image_StarLevel = tolua.cast(Image_NameBack:getChildByName("Image_StarLevel"),"ImageView")
	Image_StarLevel:loadTexture(getIconStarLev(CSV_ActivityWorldBoss.StarLevel))

	local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"),"ImageView")
	local CCNode_Skeleton = g_CocosSpineAnimation(CSV_MonsterBase.SpineAnimation, 1)
	Image_Card:removeAllNodes()
	Image_Card:loadTexture(getUIImg("Blank"))
	Image_Card:setPositionXY(CSV_MonsterBase.Pos_X*Panel_Card:getScale()/0.6, CSV_MonsterBase.Pos_Y*Panel_Card:getScale()/0.6)
	Image_Card:setSize(CCSize(CSV_MonsterBase.CardWidth, CSV_MonsterBase.CardHeight))
	Image_Card:addNode(CCNode_Skeleton)
	g_runSpineAnimation(CCNode_Skeleton, "idle", true)
	
	local function onClick_Image_Card(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			g_WndMgr:openWnd("Game_CardHandBook", CSV_ActivityWorldBoss.HunPoRewardID)
		end
	end
	Image_Card:setTouchEnabled(true)
	Image_Card:addTouchEventListener(onClick_Image_Card)
	Image_Card:setColor(ccc3(150,150,150))

	local nDamagePrecet = math.floor(self_damage/tbMsg.boss_max_hp * 10000)
	local strDamagePrecent = string.format("%.2f", nDamagePrecet/100)
	local Label_MyDamage = tolua.cast(Image_DamgeRank:getChildByName("Label_MyDamage"),"Label")
	Label_MyDamage:setText(_T("您对Boss造成的伤害为")..self_damage.."("..strDamagePrecent.."%)")

	for i=1,5 do
		local Label_Rank = tolua.cast(Image_DamgeRank:getChildByName("Label_Rank"..i),"Label")
		if tbBossInfo[i] then
			Label_Rank:setVisible(true)
			Label_Rank:setText(i.." "..tbBossInfo[i].name)
			local Label_Damage = tolua.cast(Label_Rank:getChildByName("Label_Damage"),"Label")
			local nSortDamagePrecent = math.floor(tbBossInfo[i].damage/tbMsg.boss_max_hp * 10000)
			local strDamagePrecent = string.format("%.2f", nSortDamagePrecent/100)
			Label_Damage:setText(_T("伤害")..tbBossInfo[i].damage.."("..strDamagePrecent.."%)")
		else
			Label_Rank:setVisible(false)
		end
	end
	
	self.boss_left_hp = boss_left_hp

    self.tbData = {}
    self.tbData.nBossMaxHp = tbMsg.boss_max_hp
    self.tbData.nMax = tbMsg.max_rank
    self.tbData.nWorldBossCfgId = tbMsg.boss_id
    local tbBossRankInfo = {}
    for i=1, #tbBossInfo do
        table.insert(tbBossRankInfo, tbBossInfo[i])
    end

    self.tbData.tbBossRankInfo = tbBossRankInfo
    tbMsg = nil

    if self.nMaxCount > self:getChallengeCount() then
        local nCurTime = g_GetServerTime() 
        if nCurTime - self.nLastChallenge < self.nColdDownTime then
            self.bChallengeColdDown = true
            self.nWaitTime = self.nColdDownTime - (nCurTime - self.nLastChallenge)
        else
            self.bChallengeColdDown = nil
        end
    end
    self:setPanelCard()
	
	local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(CSV_ActivityWorldBoss.HunPoRewardID)
	local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_CardHunPo.ID, CSV_CardHunPo.CardStarLevel)
		
	local Image_RewardItem1 = tolua.cast(self.rootWidget:getChildByName("Image_RewardItem1"), "ImageView")
	Image_RewardItem1:loadTexture(getFrameBackGround(CSV_CardHunPo.CardStarLevel))
	local Image_Icon = tolua.cast(Image_RewardItem1:getChildByName("Image_Icon"),"ImageView")
	Image_Icon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation))
	local Image_Cover = tolua.cast(Image_RewardItem1:getChildByName("Image_Cover"),"ImageView")
	Image_Cover:loadTexture(getFrameCoverHunPo(CSV_CardHunPo.CardStarLevel))
	local Image_Frame = tolua.cast(Image_RewardItem1:getChildByName("Image_Frame"),"ImageView")
	Image_Frame:loadTexture(getIconFrame(CSV_CardHunPo.CardStarLevel))
	
	local function onClickTipItem1(pSender, nTag)
		local CSV_DropItem = {
			DropItemType = 5,
			DropItemID = CSV_CardHunPo.ID,
			DropItemStarLevel = CSV_CardHunPo.CardStarLevel,
			DropItemNum = "N",
			DropItemEvoluteLevel = 0,
		}
		g_ShowDropItemTip(CSV_DropItem)
	end
	g_SetBtnWithEvent(Image_RewardItem1, 1, onClickTipItem1, true)
	
	local Image_RewardItem2 = tolua.cast(self.rootWidget:getChildByName("Image_RewardItem2"), "ImageView")
	local function onClickTipItem2(pSender, nTag)
		local CSV_DropItem = {
			DropItemType = macro_pb.ITEM_TYPE_GOLDS,
			DropItemID = 0,
			DropItemStarLevel = 5,
			DropItemNum = _T("大量"),
			DropItemEvoluteLevel = 0,
		}
		g_ShowDropItemTip(CSV_DropItem)
	end
	g_SetBtnWithEvent(Image_RewardItem2, 1, onClickTipItem2, true)
	
	local Image_RewardItem3 = tolua.cast(self.rootWidget:getChildByName("Image_RewardItem3"), "ImageView")
	local function onClickTipItem3(pSender, nTag)
		local CSV_DropItem = {
			DropItemType = macro_pb.ITEM_TYPE_PRESTIGE,
			DropItemID = 0,
			DropItemStarLevel = 5,
			DropItemNum = _T("若干"),
			DropItemEvoluteLevel = 0,
		}
		g_ShowDropItemTip(CSV_DropItem)
	end
	g_SetBtnWithEvent(Image_RewardItem3, 1, onClickTipItem3, true)
	
	local Button_ShenXianShiLianGuildGuide = tolua.cast(self.rootWidget:getChildByName("Button_ShenXianShiLianGuildGuide"), "Button")
	g_RegisterGuideTipButton(Button_ShenXianShiLianGuildGuide, nil, nil, CSV_ActivityWorldBoss.HunPoRewardID)
end

function Game_WorldBossGuild:setPanelCard()
    local Panel_Card = self.rootWidget:getChildByName("Panel_Card")
    if self.nWaitTime then
        if self.bChallengeColdDown then
            Panel_Card:setVisible(true)
        else
            Panel_Card:setVisible(false)
        end
		
		local Button_Challenge = tolua.cast(self.rootWidget:getChildByName("Button_Challenge"),"Button")
		local Image_CoolTime = tolua.cast(Button_Challenge:getChildByName("Image_CoolTime"),"Button")
        local Label_CoolTime = tolua.cast(Image_CoolTime:getChildByName("Label_CoolTime"),"Label")
        local function showWaitTime(ft, bOver)
			if not g_WndMgr:getWnd("Game_WorldBossGuild") then return true end
            self.nWaitTime = self.nWaitTime - 1
            if bOver then
                if self.bChallengeColdDown then
                    self.nWaitTime = nil
                    self.bChallengeColdDown = nil
                    Panel_Card:setVisible(true)
                    self:refreshBossAttendTime(self.boss_left_hp)
                else
                    self:refreshChallengeCount()
                    self.bossTag = nil
                    --self:checkData()
                    self.nWaitTime = nil
                end

                self.nTimerID_Game_WorldBossGuild_1 = nil
            else
                setCoolTime(Label_CoolTime, self.nWaitTime)
            end
        end

        self.nTimerID_Game_WorldBossGuild_1 = g_Timer:pushLimtCountTimer(self.nWaitTime, 1, showWaitTime)
        setCoolTime(Label_CoolTime, self.nWaitTime)
    else
        Panel_Card:setVisible(true)
    end
end

function Game_WorldBossGuild:registerClickShowRank()
    local function onClickShowRank(pSender, eventType)
        if eventType == ccs.TouchEventType.ended then
            g_WndMgr:showWnd("Game_WorldBossRank", self.tbData)
        end
    end

    return onClickShowRank
end

function Game_WorldBossGuild:requestBossInfo(tag)
	self.bossTag = tag or self.bossTag
	g_MsgMgr:requestBossInfo()
end

function Game_WorldBossGuild:closeWnd()
    self.tbData = nil
    self.bossTag = nil
    self.nWaitTime = nil

	g_Timer:destroyTimerByID(self.nTimerID_Game_WorldBossGuild_1)
	self.nTimerID_Game_WorldBossGuild_1 = nil
	self.bChallengeColdDown = nil
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getUIImg("Blank"))

	g_WBSystem:reset()
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_WorldBoss1_GuWu)
end

function Game_WorldBossGuild:checkData()
   	if not g_WBSystem:isInit(macro_pb.GUILD_WORLD_BOSS_TYPE) then
		g_WBSystem:requestEnterWB(macro_pb.GUILD_WORLD_BOSS_TYPE)
		return false
	end
	return true
end

--显示主界面的伙伴详细介绍界面
function Game_WorldBossGuild:openWnd(tbData)
	if g_Guild:getGuildID() <= 0 then
		g_WndMgr:closeWnd("Game_WorldBossGuild")
	end
    self.bSendMsgFlag = nil
	if(tbData)then
		self:refreshWorldBossWnd(tbData)
	end

    self:refreshBossAttendTime(self.boss_left_hp)
end


function Game_WorldBossGuild:updateChallengeColdDown()
	 self.nLastChallenge =  g_GetServerTime() 
end

function Game_WorldBossGuild:refreshGuWu()
	local nYueli = g_WBSystem:getGuWu(macro_pb.GUILD_WORLD_BOSS_TYPE, COST.YueLi)
	if 0 == nYueli then
		self.Label_AttackBuff_YueLi:setText("")
	else
		self.Label_AttackBuff_YueLi:setText(_T("攻击 +").." "..10*nYueli.."%")
	end
	local nYuanBao = g_WBSystem:getGuWu(macro_pb.GUILD_WORLD_BOSS_TYPE, COST.YuanBao)
	if 0 == nYuanBao then
		self.Label_AttackBuff_YuanBao:setText("")
	else
		self.Label_AttackBuff_YuanBao:setText(_T("攻击 +").." "..10*nYuanBao.."%")
	end
end

--鼓舞 add by zgj 
function Game_WorldBossGuild:initGuWu()
	local function onClick_Button_ZhenRong(pSender, nTag)
		g_WndMgr:showWnd("Game_BattleBuZhen")
	end
	self.Button_ZhenRong = tolua.cast(self.rootWidget:getChildByName("Button_ZhenRong"), "Button")
	g_SetBtnWithPressingEventAndImage(self.Button_ZhenRong, 1, nil, onClick_Button_ZhenRong, nil, true, 0.25)
	
	local function onClickYueLi(pSender, nTag)
		local cost = g_WBSystem:getGuWuCost(macro_pb.GUILD_WORLD_BOSS_TYPE, COST.YueLi)
		if cost > g_Hero:getKnowledge() then
			g_ShowSysTips({text = _T("阅历不足")})
			return 
		end
		g_WBSystem:requestGuWu(macro_pb.GUILD_WORLD_BOSS_TYPE, false)
	end
	self.Button_YueLiGuWu = tolua.cast(self.rootWidget:getChildByName("Button_YueLiGuWu"), "Button")
	g_SetBtnWithPressingEventAndImage(self.Button_YueLiGuWu, 1, g_OnShowTip, onClickYueLi, g_OnCloseTip, true, 0.25)
	self.Label_AttackBuff_YueLi = tolua.cast(self.Button_YueLiGuWu:getChildByName("Label_AttackBuff"), "Label")

	local function onClickYuanBao(pSender, nTag)
		local cost = g_WBSystem:getGuWuCost(macro_pb.GUILD_WORLD_BOSS_TYPE, COST.YuanBao)
		if not g_CheckYuanBaoConfirm(cost, _T("元宝鼓舞需要消耗")..cost.._T("元宝, 您的元宝不足是否前往充值")) then
			return false
		end
		g_WBSystem:requestGuWu(macro_pb.GUILD_WORLD_BOSS_TYPE, true)
	end
	self.Button_YuanBaoGuWu = tolua.cast(self.rootWidget:getChildByName("Button_YuanBaoGuWu"), "Button")
	g_SetBtnWithPressingEventAndImage(self.Button_YuanBaoGuWu, 1, g_OnShowTip, onClickYuanBao, g_OnCloseTip, true, 0.25)
	self.Label_AttackBuff_YuanBao = tolua.cast(self.Button_YuanBaoGuWu:getChildByName("Label_AttackBuff"), "Label")
end