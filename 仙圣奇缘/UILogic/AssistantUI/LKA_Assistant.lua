--------------------------------------------------------------------------------------
-- 文件吿	LKA_Assistant.lua
-- 牿 板	(C)  深圳市美天互动有限公叿
-- 创建亿  陆奎宿
-- 旿 朿	2014-12-10 10:24
-- 牿 朿	1.0
-- 揿 迿	助手界面
-- 庿 甿  本例子使用一般方法的实现Scene

-----------------------------------------------------------------------------
Game_Assistant = class("Game_Assistant")
Game_Assistant.__index = Game_Assistant



local tbActivityReward = {}

local function getActivityItemIdx(id)
	local idxs = {
		[3] = 1, -- 普通财神副朿
		[4] = 2, -- 高手财神副本
		[5] = 3, -- 普通神仙试炿
		[6] = 4, -- 高手神仙试炼
		[7] = 5, -- 摘仙桿
		[8] = 6, -- 中午世界boss
		[9] = 7, -- 晚上世界boss
	}
	return idxs[id]
end

function Game_Assistant:refreshBubbleNotice()
	local wnd = g_WndMgr:getWnd("Game_Assistant")
	if not wnd then return end
	g_SetBubbleNotify(wnd.Button_Task, g_GetNoticeNum_Assistant_Task(), 60, 50)
	g_SetBubbleNotify(wnd.Button_Reward, g_GetNoticeNum_Assistant_Reward(), 60, 50)
	g_SetBubbleNotify(wnd.Button_ChengJiu, g_GetNoticeNum_Assistant_Achievement(), 60, 50)
end

function Game_Assistant:setImage_ActiveNessPNL()
	if not self.rootWidget then return end 
	local activenessInfo = g_Hero:getActivenessInfo()
	local nCurRewardLv = activenessInfo.nCurRewardLv

	local nMasterLevel = g_Hero:getMasterCardLevel()
	local CSV_ActivityActivenessReward  = g_DataMgr:getCsvConfigByOneKey("ActivityActivenessReward",nCurRewardLv)
		
	local nNeedActiveNess = CSV_ActivityActivenessReward.NeedActiveNess
	if activenessInfo.activeness >= nNeedActiveNess then
		self.BitmapLabel_FuncName:setText(_T("领取礼包"))
		if nNeedActiveNess ~= 0 then
			if not self.Button_Get then return end 
			g_SetBtnEnable(self.Button_Get, true)
		else
			if not self.Button_Get then return end 
			g_SetBtnEnable(self.Button_Get, false)
		end
	else
		if not self.Button_Get then return end 
		g_SetBtnEnable(self.Button_Get, false)
		self.BitmapLabel_FuncName:setText(_T("活跃度不足"))
	end

	--start 20150615 增加等级验证 
	local CSV_ActivityActivenessLvOpen = g_DataMgr:getCsvConfigByOneKey("ActivityActivenessLvOpen", nCurRewardLv)
	local nNeedLevel = CSV_ActivityActivenessLvOpen.AutoOpenLev
	if nMasterLevel < nNeedLevel then
		g_SetBtnEnable(self.Button_Get, false)
		self.BitmapLabel_FuncName:setText(_T("等级不足"))
	end
	--over
	
	local ImageView_AssistantPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_AssistantPNL"), "ImageView")
	local Image_ZhuShouPNL = tolua.cast(ImageView_AssistantPNL:getChildByName("Image_ZhuShouPNL"), "ImageView")
	local Image_ActiveNessPNL = tolua.cast(Image_ZhuShouPNL:getChildByName("Image_ActiveNessPNL"), "ImageView")
	local Label_MyActiveNess = tolua.cast(Image_ActiveNessPNL:getChildByName("Label_MyActiveNess"), "Label")
	local activenessInfo = g_Hero:getActivenessInfo()
	Label_MyActiveNess:setText(tostring(activenessInfo.activeness))
	local lv = 0 
	local nMaxRewardLv = #g_DataMgr:getCsvConfig("ActivityActivenessReward")
	
	if nCurRewardLv <= 3 then
		lv = 1
	elseif nCurRewardLv > nMaxRewardLv - 5 then
		lv = nMaxRewardLv - 6
	else
		lv = nCurRewardLv-2
	end

	local bCanReward = false
	local idx = nil
	for i = 1, 7 do
		local id = lv + i - 1
		local CSV_ActivityActivenessReward = g_DataMgr:getCsvConfigByOneKey("ActivityActivenessReward",id)
		local Image_ActiveNessPNL = tolua.cast(self.Image_ZhuShouPNL:getChildByName("Image_ActiveNessPNL"), "ImageView")
		local Button_Package = tolua.cast(Image_ActiveNessPNL:getChildByName("Button_Package"..i), "Button")

		Button_Package:loadTextureNormal(getAssitantImg(CSV_ActivityActivenessReward.Icon))
		Button_Package:loadTexturePressed(getAssitantImg(CSV_ActivityActivenessReward.Icon))
		Button_Package:setName("Button_Package"..i)
		Button_Package:setTag(id)

		--add by zgj
		Label_NeedActiveNess = tolua.cast(Button_Package:getChildByName("Label_NeedActiveNess"),"Label")
		Label_NeedActiveNess:setText(CSV_ActivityActivenessReward.NeedActiveNess)
		if 0 == CSV_ActivityActivenessReward.NeedActiveNess then
			Button_Package:setVisible(false)
		else
			Button_Package:setVisible(true)
		end
		if activenessInfo.activeness >= CSV_ActivityActivenessReward.NeedActiveNess then
			Label_NeedActiveNess:setColor(ccc3(0,255,0))
		else
			Label_NeedActiveNess:setColor(ccc3(255,0,0))
		end
		-- over

		local function onClick_Button_Package(pSender, nTag)
			local nMasterLevel = g_Hero:getMasterCardLevel()
			local CSV_ActivityActivenessReward = g_DataMgr:getCsvConfigByOneKey("ActivityActivenessReward", nTag)
			local tbActiveNessReward = {}
			local numExp =  (CSV_ActivityActivenessReward.factor / g_BasePercent) * (CSV_ActivityActivenessReward.Exp + CSV_ActivityActivenessReward.ExpInc * ( nMasterLevel - 1 ) )
			table.insert(tbActiveNessReward,
				{
					DropItemType = macro_pb.ITEM_TYPE_COUPONS,
					DropItemID = 0,
					DropItemStarLevel = 5,
					DropItemNum = CSV_ActivityActivenessReward.YuanBao,
					DropItemEvoluteLevel = 0,
				}
			)
			table.insert(tbActiveNessReward,
				{
					DropItemType = macro_pb.ITEM_TYPE_MASTER_EXP,
					DropItemID = 0,
					DropItemStarLevel = 5,
					DropItemNum = math.ceil(numExp),
					DropItemEvoluteLevel = 0,
				}
			)
			if CSV_ActivityActivenessReward.JiangHunShi > 0 then
				table.insert(tbActiveNessReward,
					{
						DropItemType = macro_pb.ITEM_TYPE_SECRET_JIANGHUN,
						DropItemID = 0,
						DropItemStarLevel = 5,
						DropItemNum = CSV_ActivityActivenessReward.JiangHunShi,
						DropItemEvoluteLevel = 0,
					}
				)
			end
			if CSV_ActivityActivenessReward.RefreshToken > 0 then
				table.insert(tbActiveNessReward,
					{
						DropItemType = macro_pb.ITEM_TYPE_SECRET_REFRESH_TOKEN,
						DropItemID = 0,
						DropItemStarLevel = 5,
						DropItemNum = CSV_ActivityActivenessReward.RefreshToken,
						DropItemEvoluteLevel = 0,
					}
				)
			end
			if CSV_ActivityActivenessReward.Coins > 0 then
				table.insert(tbActiveNessReward,
					{
						DropItemType = macro_pb.ITEM_TYPE_GOLDS,
						DropItemID = 0,
						DropItemStarLevel = 5,
						DropItemNum = CSV_ActivityActivenessReward.Coins,
						DropItemEvoluteLevel = 0,
					}
				)
			end
			if CSV_ActivityActivenessReward.Incense > 0 then
				table.insert(tbActiveNessReward,
					{
						DropItemType = macro_pb.ITEM_TYPE_INCENSE,
						DropItemID = 0,
						DropItemStarLevel = 5,
						DropItemNum = CSV_ActivityActivenessReward.Incense,
						DropItemEvoluteLevel = 0,
					}
				)
			end
			local numKnowledge = (CSV_ActivityActivenessReward.factor / g_BasePercent) * ( CSV_ActivityActivenessReward.Knowledge + CSV_ActivityActivenessReward.KnowledgeInc * ( nMasterLevel - 1 ) )
			table.insert(tbActiveNessReward,
				{
					DropItemType = macro_pb.ITEM_TYPE_KNOWLEDGE,
					DropItemID = 0,
					DropItemStarLevel = 5,
					DropItemNum = math.ceil(numKnowledge),
					DropItemEvoluteLevel = 0,
				}
			)
			table.insert(tbActiveNessReward,
				{
					DropItemType = macro_pb.ITEM_TYPE_ESSENCE,
					DropItemID = 0,
					DropItemStarLevel = 5,
					DropItemNum = CSV_ActivityActivenessReward.Essence,
					DropItemEvoluteLevel = 0,
				}
			)
			if CSV_ActivityActivenessReward.HornReward > 0 then
				table.insert(tbActiveNessReward,
					{
						DropItemType = macro_pb.ITEM_TYPE_MATERIAL,
						DropItemID = 12,
						DropItemStarLevel = 1,
						DropItemNum = CSV_ActivityActivenessReward.HornReward,
						DropItemEvoluteLevel = 0,
					}
				)
			end
			if id < nCurRewardLv then
				local tbData = {
					nRewardStatus = Game_RewardBox_Status._HasObtain,
					tbParamentList = tbActiveNessReward,
					updateHeroResourceInfo = nil,
				}
				g_WndMgr:showWnd("Game_RewardBox", tbData)
			else
				local tbData = {
					nRewardStatus = Game_RewardBox_Status._CanNotObtain,
					tbParamentList = tbActiveNessReward,
					updateHeroResourceInfo = nil,
				}
				g_WndMgr:showWnd("Game_RewardBox", tbData)
			end
		end
		g_SetBtnWithEvent(Button_Package, id, onClick_Button_Package, true, true)
		
		if id<nCurRewardLv then
			Button_Package:setBright(false)
		else
			Button_Package:setBright(true)
		end
		if id == nCurRewardLv then
			idx = i
			self.curPackage = Button_Package
		end
	end
	
	if idx then
		local x, y = self.Image_Index:getPositionXY()
		local PackX, PackY = self.curPackage:getPositionXY()
		self.Image_Index:setPosition(ccp(PackX-2, y))
		self.Image_Index:setVisible(true)
	else
		self.Image_Index:setVisible(false)
	end
end

function getFarmNums(level)
	local num = 1
	for i=1,9 do
		local CSV_ActivityAssistant = g_DataMgr:getCsvConfigByOneKey("ActivityFarmFieldOpen", i)
		if level < CSV_ActivityAssistant.AutoOpenLev then
			num = i - 1
			return num
		else
			num = num + 1
		end
	end
	if num > 9 then
		num = 9
	end 
	return num
end

--日常
function Game_Assistant:setListViewItemZhuShou(Panel_ZhuShouItem, nIndex)
	local Button_ZhuShouItem = tolua.cast(Panel_ZhuShouItem:getChildByName("Button_ZhuShouItem"), "Label")
	local Label_Name = tolua.cast(Button_ZhuShouItem:getChildByName("Label_Name"), "Label")
	local Label_Desc = tolua.cast(Button_ZhuShouItem:getChildByName("Label_Desc"), "Label")
	local Label_ActiveNess = tolua.cast(Button_ZhuShouItem:getChildByName("Label_ActiveNess"), "Label")
	local Image_Progress = tolua.cast(Button_ZhuShouItem:getChildByName("Image_Progress"), "ImageView")
	local LoadingBar_Progress = tolua.cast(Image_Progress:getChildByName("LoadingBar_Progress"), "LoadingBar")
	local Label_Progress = tolua.cast(LoadingBar_Progress:getChildByName("Label_Progress"), "Label")
	
	local Image_RewardItem = tolua.cast(Button_ZhuShouItem:getChildByName("Image_RewardItem"), "ImageView")
	local Image_Frame = tolua.cast(Image_RewardItem:getChildByName("Image_Frame"), "ImageView")
	local Image_Icon = tolua.cast(Image_RewardItem:getChildByName("Image_Icon"), "ImageView")
	local tbAssitantItem = g_Hero:getAssistantInfoByIndex(nIndex)
	local nAssistantCsvId = tbAssitantItem.nAssistantCsvId
	local CSV_ActivityAssistant = g_DataMgr:getCsvConfigByOneKey("ActivityAssistant", nAssistantCsvId)
	Label_Name:setText(CSV_ActivityAssistant.AffairsName)
	Label_Desc:setText(CSV_ActivityAssistant.AffairsDesc)
	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		g_AdjustWidgetsPosition({Label_Name, Label_ActiveNess},40)
	end
	Label_ActiveNess:setText(_T("活跃度+")..CSV_ActivityAssistant.ActiveNess)


	local nMaxNum = g_VIPBase:getVipMaxTimes(nAssistantCsvId)
	if common_pb.AssistantType_ZhaoCaiShenFu == nAssistantCsvId then
		nMaxNum = g_Hero:getVIPLevelMaxNumZhaoCai()
	elseif common_pb.AssistantType_YaoYuanZhongZhi == nAssistantCsvId then
		local nums = getFarmNums(g_Hero:getMasterCardLevel())
		nMaxNum = math.max(g_GetOpenFarmNum(),nums)
	end
	
	if tbAssitantItem.nFinishCount >= nMaxNum then
		tbAssitantItem.nFinishCount = nMaxNum
		tbAssitantItem.nProgress = 100
		
	end
	LoadingBar_Progress:setPercent(tbAssitantItem.nProgress)
	Label_Progress:setText(tbAssitantItem.nFinishCount.."/"..nMaxNum)

	Image_Frame:loadTexture(getIconFrame(CSV_ActivityAssistant.StarLevel))
	Image_RewardItem:loadTexture(getFrameBackGround(CSV_ActivityAssistant.StarLevel))
	Image_Icon:loadTexture(getImgByPathRoot(CSV_ActivityAssistant.IconPath, CSV_ActivityAssistant.IconName))
	Image_Icon:setScale(CSV_ActivityAssistant.IconScale/100)
	
	local Button_Function = tolua.cast(Button_ZhuShouItem:getChildByName("Button_Function"), "Button")
	local function onPressed_Button_Function(pSend, nTag)
		local CSV_ActivityAssistant = g_DataMgr:getCsvConfigByOneKey("ActivityAssistant", nTag)
		if CSV_ActivityAssistant.BtnEvent == "Function_Login" then
			-- Do nothing
		elseif CSV_ActivityAssistant.BtnEvent == "Game_Registration1" then
			g_WndMgr:showWnd("Game_Registration1")
		elseif CSV_ActivityAssistant.BtnEvent == "Game_ZhaoCaiFu" then
			g_WndMgr:openWnd("Game_ZhaoCaiFu")
		elseif CSV_ActivityAssistant.BtnEvent == "Game_WorldBoss1" then
			g_WndMgr:openWnd("Game_WorldBoss1")
		elseif CSV_ActivityAssistant.BtnEvent == "Game_Summon" then
			g_WndMgr:openWnd("Game_Summon")
		elseif CSV_ActivityAssistant.BtnEvent == "Game_HuntFate1" then
			-- g_WndMgr:openWnd("Game_HuntFate1")
			g_FateData:requestHuntFateRefresh()
		elseif CSV_ActivityAssistant.BtnEvent == "Game_Ectype" then
			g_WndMgr:openWnd("Game_Ectype")
		elseif CSV_ActivityAssistant.BtnEvent == "Game_Equip1" then
			g_WndMgr:openWnd("Game_Equip1")
		elseif CSV_ActivityAssistant.BtnEvent == "Game_Arena" then
			g_WndMgr:openWnd("Game_Arena")
		elseif CSV_ActivityAssistant.BtnEvent == "Game_QiShu" then
			g_WndMgr:showWnd("Game_QiShu")
		elseif CSV_ActivityAssistant.BtnEvent == "Game_Turntable" then
			g_WndMgr:openWnd("Game_Turntable")
		elseif CSV_ActivityAssistant.BtnEvent == "Game_ActivityFuLuDao_CaiShenDong" then
			g_WndMgr:showWnd("Game_ActivityFuLuDaoSub", g_ActivityCfgID.CaiShenDong)
		elseif CSV_ActivityAssistant.BtnEvent == "Game_ActivityFuLuDao_CangJingGe" then
			g_WndMgr:showWnd("Game_ActivityFuLuDaoSub", g_ActivityCfgID.CangJingGe)
		elseif CSV_ActivityAssistant.BtnEvent == "Game_ActivityFuLuDao_WoLongTan" then
			g_WndMgr:showWnd("Game_ActivityFuLuDaoSub", g_ActivityCfgID.WoLongTan)
		elseif CSV_ActivityAssistant.BtnEvent == "Game_Farm" then
			g_WndMgr:showWnd("Game_Farm")
		elseif CSV_ActivityAssistant.BtnEvent == "Function_BuyEnergy" then
			local times = g_Hero:getBuyEnergyTimes()
			local maxTimes = g_VIPBase:getVipMaxTimes(nTag)
			if times >= maxTimes then
				g_ClientMsgTips:showMsgConfirm(_T("今天已达到购买次数上限"))
				return
			end
			g_buyEnergy(nTag)
		elseif CSV_ActivityAssistant.BtnEvent == "Function_BuyArenaTimes" then
			local types = VipType.VipBuyOpType_ArenaChallegeTimes
			local function onClickConfirm()
				local function serverResponseCall(times)
					local allNum = g_VIPBase:getVipLevelCntNum(types)
					local function animationEndCall()
						g_ShowSysTips({text = _T("成功购买1次天榜竞技场挑战次数\n您还可购买")..allNum-times.._T("次。")})
					end
					--每次增加一次
					g_Hero:addArenaTimes(1)
                    g_ShowRewardMsgConfrim(macro_pb.ITEM_TYPE_ARENA_TIME, 1, animationEndCall)
					
					local nBuyPrice = g_VIPBase:getVipLevelCntGold(types)
					gTalkingData:onPurchase(TDPurchase_Type.TDP_BuyArena, 1, nBuyPrice)	
				end
				g_VIPBase:responseFunc(serverResponseCall)
				g_VIPBase:requestVipBuyTimesRequest(types)
			end
			local maxTimes = g_VIPBase:getVipLevelCntNum(types)
			--已经购买的次数
			local addNum = g_VIPBase:getAddTableByNum(types)
			if addNum >= maxTimes then 
				g_ClientMsgTips:showMsgConfirm(_T("今天已达到购买次数上限"))
				return 
			end
			local nBuyPrice = g_VIPBase:getVipLevelCntGold(types)
			if not g_CheckYuanBaoConfirm(nBuyPrice, _T("购买挑战次数需要")..nBuyPrice.._T("元宝, 您的元宝不足是否前往充值")) then
				return
			end
			g_ClientMsgTips:showConfirm(_T("是否花费")..nBuyPrice.._T("元宝购买1次天榜竞技场挑战次数"), onClickConfirm, nil)
		elseif CSV_ActivityAssistant.BtnEvent == "Game_FarmPray" then
			g_WndMgr:showWnd("Game_FarmPray")
		elseif CSV_ActivityAssistant.BtnEvent == "Game_WorldBoss2" then
			g_WndMgr:openWnd("Game_WorldBoss2")
		elseif CSV_ActivityAssistant.BtnEvent == "Game_BaXuanGuoHai" then
			g_BaXianGuoHaiSystem:InitOnOpenWnd()
		elseif CSV_ActivityAssistant.BtnEvent == "Game_BaXianPray" then
			g_WndMgr:showWnd("Game_BaXianPray")
		elseif CSV_ActivityAssistant.BtnEvent == "Game_DragonPray" then
			g_DragonPray:requestInitInfo()
		elseif CSV_ActivityAssistant.BtnEvent == "Game_GanWu" then
			g_EliminateSystem:RequestInspireCheckData()
		elseif CSV_ActivityAssistant.BtnEvent == "Game_ShangXiang1" then
			g_WndMgr:openWnd("Game_ShangXiang1")
		elseif CSV_ActivityAssistant.BtnEvent == "Game_EctypeJY" then
			g_EctypeJY:requestJYInfo()
		elseif CSV_ActivityAssistant.BtnEvent == "Game_CardDuJie" then
			local nCardID = g_Hero:getBattleCardByIndex(1):getServerId()
			g_WndMgr:openWnd("Game_CardDuJie", nCardID)
		elseif CSV_ActivityAssistant.BtnEvent == "Game_XianMai" then
			g_WndMgr:openWnd("Game_XianMai")
		elseif CSV_ActivityAssistant.BtnEvent == "Game_HuntFate1" then
			-- g_WndMgr:openWnd("Game_HuntFate1")
			g_FateData:requestHuntFateRefresh()
		elseif CSV_ActivityAssistant.BtnEvent == "Game_Social1" then
			g_SALMgr:initSocialApplicationListData(40)
		elseif CSV_ActivityAssistant.BtnEvent == "Game_Equip1" then
			g_WndMgr:openWnd("Game_Equip1")
		end
	end
	g_SetBtnWithEvent(Button_Function, nAssistantCsvId, onPressed_Button_Function, true)
	
	local nLevel = g_Hero:getMasterCardLevel()
	local BitmapLabel_FuncName = tolua.cast(Button_Function:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	BitmapLabel_FuncName:setText(CSV_ActivityAssistant.BtnName)
	if tbAssitantItem.nProgress < 100 and nLevel >= CSV_ActivityAssistant.OpenLevel and tbAssitantItem.bIsOpenToday == true  then
		g_SetBtnEnable(Button_Function, true)
	elseif tbAssitantItem.nFinishCount == nMaxNum then
		BitmapLabel_FuncName:setText(_T("已完成"))
		g_SetBtnEnable(Button_Function, false)
	elseif tbAssitantItem.bIsOpenToday == false then
		BitmapLabel_FuncName:setText(_T("未开放"))
		g_SetBtnEnable(Button_Function, false)
	elseif nLevel < CSV_ActivityAssistant.OpenLevel  then
		BitmapLabel_FuncName:setText(_T("等级不够"))
		g_SetBtnEnable(Button_Function, false)
	end
	local Image_Symbol = tolua.cast(Button_ZhuShouItem:getChildByName("Image_Symbol"), "ImageView")
	local ccSprite = tolua.cast(Image_Symbol:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
end

--奖励
function Game_Assistant:setListViewItemReward(Panel_RewardItem, nIndex)
	local Button_RewardItem = tolua.cast(Panel_RewardItem:getChildByName("Button_RewardItem"), "Button")
	local Label_Name = tolua.cast(Button_RewardItem:getChildByName("Label_Name"), "Label")
	local Label_Desc = tolua.cast(Button_RewardItem:getChildByName("Label_Desc"), "Label")
	local Label_RewardValue = tolua.cast(Button_RewardItem:getChildByName("Label_RewardValue"), "Label")
	local Label_RemainDay = tolua.cast(Button_RewardItem:getChildByName("Label_RemainDay"), "Label")
	local Image_RewardValueIcon = tolua.cast(Button_RewardItem:getChildByName("Image_RewardValueIcon"), "ImageView")
	local Image_RewardItem = tolua.cast(Button_RewardItem:getChildByName("Image_RewardItem"), "ImageView")
	local Image_Frame = tolua.cast(Image_RewardItem:getChildByName("Image_Frame"), "ImageView")
	local Image_Icon = tolua.cast(Image_RewardItem:getChildByName("Image_Icon"), "ImageView")

	local CSV_ActivityReward = tbActivityReward[nIndex][1]
	Label_Name:setText(CSV_ActivityReward.RewardName)
	Label_Desc:setText(CSV_ActivityReward.RewardDesc)

	if CSV_ActivityReward.RewardID == common_pb.RewardType_Coin then
		local CSV_PlayerExp = g_DataMgr:getCsvConfigByOneKey("PlayerExp", g_Hero:getMasterCardLevel())
		Label_RewardValue:setText("×"..CSV_PlayerExp.ZhaoCaiCoins)
	elseif CSV_ActivityReward.RewardID == common_pb.RewardType_AM_Energy or CSV_ActivityReward.RewardID == common_pb.RewardType_PM_Energy then
		Label_RewardValue:setText("×"..g_Hero:getMaxEnergy() / 2)
	else
		Label_RewardValue:setText("×"..CSV_ActivityReward.ShowRewardValue)
	end
	
	local tbReward = g_Hero:getRewardActivate(CSV_ActivityReward.RewardID)
	local Button_Get = tolua.cast(Button_RewardItem:getChildByName("Button_Get"), "ImageView")
	local function onPressed_Button_Get()
		local id = tbReward.reward_id
		local lv = tbReward.reward_lv
		--预加载窗口缓存防止卡顿
		g_WndMgr:getFormtbRootWidget("Game_RewardMsgConfirm")
		g_MsgMgr:requestGainReward(id, lv)
	end
	g_SetBtnWithEvent(Button_Get, nIndex, onPressed_Button_Get, true)
	
	if tbReward then
		g_SetBtnEnable(Button_Get, true)
	else
		g_SetBtnEnable(Button_Get, false)
	end 

	local BitmapLabel_FuncName = tolua.cast(Button_Get:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	BitmapLabel_FuncName:setText(_T("领取"))
	--处理月卡
	Label_RemainDay:setVisible(false)
    if common_pb.RewardType_MonthYuanbao1 == CSV_ActivityReward.RewardID or common_pb.RewardType_MonthYuanbao2 == CSV_ActivityReward.RewardID or common_pb.RewardType_MonthYuanbao3 == CSV_ActivityReward.RewardID then
	    local nRemainDay = tbYueKaDeadline[CSV_ActivityReward.RewardID]["remain_day"] or 0
	    if nRemainDay > 0 then
		    Label_RemainDay:setText(_T("还剩")..nRemainDay.._T("天"))
		    Label_RemainDay:setVisible(true)
	    else
		    Label_Desc:setText(CSV_ActivityReward.RewardDesc)
		    if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		    	Label_Desc:setText(g_stringSize_insert(CSV_ActivityReward.RewardDesc,"\n",22,560))
		    end
			if CSV_ActivityReward.RewardID == 3 then
				local function onPressed_Button_Get()
					local tbParam = {
						OpenType = "PuTongYueKa",
						ListViewIndex = 1
					}
					g_WndMgr:openWnd("Game_ReCharge", tbParam)
				end
				g_SetBtnWithEvent(Button_Get, nIndex, onPressed_Button_Get, true)
			elseif CSV_ActivityReward.RewardID == 4 then
				local function onPressed_Button_Get()
					local tbParam = {
						OpenType = "GaoJiYueKa",
						ListViewIndex = 1
					}
					g_WndMgr:openWnd("Game_ReCharge", tbParam)
				end
				g_SetBtnWithEvent(Button_Get, nIndex, onPressed_Button_Get, true)
			end
		    g_SetBtnEnable(Button_Get, true)
		    BitmapLabel_FuncName:setText(_T("购买"))
	    end
    end
	
	

	Image_Frame:loadTexture(getIconFrame(CSV_ActivityReward.ColorType))
	Image_RewardItem:loadTexture(getFrameBackGround(CSV_ActivityReward.ColorType))
	Image_Icon:loadTexture(getUIImg(CSV_ActivityReward.PackIcon))
	Image_RewardValueIcon:loadTexture(getUIImg(CSV_ActivityReward.ShowRewarIcon))
	
	local Image_Symbol = tolua.cast(Button_RewardItem:getChildByName("Image_Symbol"), "ImageView")
	local ccSprite = tolua.cast(Image_Symbol:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
end

local ENUM_ActivityReward_Type = {
	MonthlyCard1 = 3,
	MonthlyCard2 = 4,
}

function Game_Assistant:updateList(nTag)
	if nTag == 1 then
		local ImageView_AssistantPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_AssistantPNL"), "ImageView")
		local Image_ZhuShouPNL = tolua.cast(ImageView_AssistantPNL:getChildByName("Image_ZhuShouPNL"), "ImageView")
		local Image_ActiveNessPNL = tolua.cast(Image_ZhuShouPNL:getChildByName("Image_ActiveNessPNL"), "ImageView")
		local Label_MyActiveNess = tolua.cast(Image_ActiveNessPNL:getChildByName("Label_MyActiveNess"), "Label")
		local activenessInfo = g_Hero:getActivenessInfo()
		Label_MyActiveNess:setText(tostring(activenessInfo.activeness))
		self.ListView_ZhuShouList:updateItems(g_Hero:getAssistantInfoCount(), self.nLastAdjustIndex or 1)
	elseif nTag == 2 then
		local CSV_ActivityReward = g_DataMgr:getCsvConfig("ActivityReward")
		tbActivityReward = {}
		for k, v in pairs(CSV_ActivityReward) do
            if g_Hero:getMasterCardLevel() >= v[1].OpenLevel then
				if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then
					if k == ENUM_ActivityReward_Type.MonthlyCard1 then
						--donothing
					elseif k == ENUM_ActivityReward_Type.MonthlyCard2 then
						--donothing
					else
						table.insert(tbActivityReward, v)
					end
				else
					table.insert(tbActivityReward, v)
				end
            end
		end
	
		table.sort(tbActivityReward, function(a, b)
			local tbReward = g_Hero:getRewardInfo()
			local flag_a = g_Hero:getRewardActivate(a[1].RewardID)
			local flag_b = g_Hero:getRewardActivate(b[1].RewardID)
			if (flag_a == nil and flag_b == nil) or (flag_a and flag_b) then
				return a[1].SortRank < b[1].SortRank
			end
			if flag_a == nil then
				return false
			else
				return true
			end
		end)
		self.ListView_RewardList:updateItems(#tbActivityReward)
		self:refreshBubbleNotice()
	elseif nTag == 3 then

		if g_AssistantData:getRecordList() == nil then 
			g_AssistantData:requestAchievementInfoRequest()
		else
			setAchievementData()
		end
		
		-- self.ListView_ChengJiuList:updateItems(#achievementCfg)
		self:refreshBubbleNotice()
		
	end
end

function Game_Assistant:FuncTask()
	if self ~= nil then
		self:setImage_ActiveNessPNL()
		self:updateList(1)
	end
end

function Game_Assistant:FuncReward()
	if self ~= nil then
		self:updateList(2)
	end
end

function Game_Assistant:funcChengJiu()
	if self ~= nil then
		self:updateList(3)
	end
end

function Game_Assistant:CreateLeaf()
	local t = {}
	--父节点，起始位置，结束位置，播放次数,间隔时间 ,移动的时间，旋转时间，旋转角度1，反转角度2, 叶子图片类型（1-4)
	t[1] = g_CreateLeaf(self.rootWidget,ccp(1400,800),ccp(2000,0),-1,15)
	t[2] = g_CreateLeaf(self.rootWidget,ccp(2200,1000),ccp(100,-100),-1,20,25,5,-10,10,4,1)
	t[3] = g_CreateLeaf(self.rootWidget,ccp(0,500),ccp(1500,100),-1,25,35,5,-80,80,3,1)
	t[4] = g_CreateLeaf(self.rootWidget,ccp(1500,1000),ccp(100,300),-1,15,45,5,-50,50,2,1)
	t[5] = g_CreateLeaf(self.rootWidget,ccp(10000,800),ccp(500,400),-1,20,35,5,-100,100,4,1)
	t[6] = g_CreateLeaf(self.rootWidget,ccp(2500,1000),ccp(100,300),-1,25,45,5,-50,50,2,1)
	t[7] = g_CreateLeaf(self.rootWidget,ccp(2000,1000),ccp(500,400),-1,15,30,5,-100,100,1,1)
	self.tbTimer_ = t
	g_CreateLeafStatus = 1
end

function Game_Assistant:initWnd()
	--初始化界面的动画
	local function initBackgroundAnimation()
		local wndInstantce = g_WndMgr:getWnd("Game_Assistant")
		if wndInstantce then
			local ImageView_Background = tolua.cast(wndInstantce.rootWidget:getChildByName("ImageView_Background"), "ImageView")
			g_InitBuZhenBackgroundAnimation(ImageView_Background)
		end
	end
	g_Timer:pushTimer(0.05, initBackgroundAnimation)
	self:CreateLeaf()
	
	--initConfig()
	local ImageView_AssistantPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_AssistantPNL"), "ImageView")
	self.Image_ZhuShouPNL = tolua.cast(ImageView_AssistantPNL:getChildByName("Image_ZhuShouPNL"), "ImageView")
	self.Image_RewardPNL = tolua.cast(ImageView_AssistantPNL:getChildByName("Image_RewardPNL"), "ImageView")
	self.Image_ChengJiuPNL = tolua.cast(ImageView_AssistantPNL:getChildByName("Image_ChengJiuPNL"), "ImageView")

    self.Button_Task = tolua.cast(ImageView_AssistantPNL:getChildByName("Button_Task"), "Button")
	self.Button_Reward = tolua.cast(ImageView_AssistantPNL:getChildByName("Button_Reward"), "Button")
    self.Button_ChengJiu = tolua.cast(ImageView_AssistantPNL:getChildByName("Button_ChengJiu"), "Button")

	--按钮组
	local ButtonGroup = ButtonGroup:create()
	self.ButtonGroup = ButtonGroup

	ButtonGroup:PushBack(self.Button_Task,self.Image_ZhuShouPNL ,handler(self, self.FuncTask) , true)
	ButtonGroup:PushBack(self.Button_Reward, self.Image_RewardPNL ,handler(self, self.FuncReward))
	ButtonGroup:PushBack(self.Button_ChengJiu, self.Image_ChengJiuPNL, handler(self, self.funcChengJiu))
	
	local Image_ActiveNessPNL = tolua.cast(self.Image_ZhuShouPNL:getChildByName("Image_ActiveNessPNL"), "ImageView")
	self.Image_Index = tolua.cast(Image_ActiveNessPNL:getChildByName("Image_Index"), "ImageView")
	g_CreateFadeInOutAction(self.Image_Index)
	
	
	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		local Label_MyActiveNessLB = tolua.cast(Image_ActiveNessPNL:getChildByName("Label_MyActiveNessLB"), "Label")
		Label_MyActiveNessLB:setText(g_stringSize_insert(Label_MyActiveNessLB:getStringValue(), "\n", 22, 150))
	end
	
	self.Button_Get = tolua.cast(Image_ActiveNessPNL:getChildByName("Button_Get"), "Button")
	self.BitmapLabel_FuncName = tolua.cast(self.Button_Get:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	local function onPressed_Button_Get()
		--预加载窗口缓存防止卡顿
		g_WndMgr:getFormtbRootWidget("Game_RewardBox")
		--预加载窗口缓存防止卡顿
		g_WndMgr:getFormtbRootWidget("Game_HeroLevelUpAnimation")
		g_MsgMgr:requestAssistantReward()
		self.Button_Get:setTouchEnabled(false)
	end
	g_SetBtnWithEvent(self.Button_Get, 1, onPressed_Button_Get, true)


	local function adjustZhuShouList(Panel_RewardItem, nIndex)
		self.nLastAdjustIndex = nIndex
	end
	
	local ListView_ZhuShouList = tolua.cast(self.Image_ZhuShouPNL:getChildByName("ListView_ZhuShouList"), "ListViewEx")
	local Panel_ZhuShouItem = tolua.cast(ListView_ZhuShouList:getChildByName("Panel_ZhuShouItem"), "Layout")
	self.ListView_ZhuShouList = registerListViewEvent(ListView_ZhuShouList, Panel_ZhuShouItem, handler(self, self.setListViewItemZhuShou), nil, adjustZhuShouList)
	
	local imgScrollSlider = ListView_ZhuShouList:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_ZhuShouList_X then
		g_tbScrollSliderXY.ListView_ZhuShouList_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_ZhuShouList_X - 2)
	
	local ListView_RewardList = tolua.cast(self.Image_RewardPNL:getChildByName("ListView_RewardList"), "ListViewEx")
	local Panel_RewardItem = tolua.cast(ListView_RewardList:getChildByName("Panel_RewardItem"), "Layout")
	self.ListView_RewardList =  registerListViewEvent(ListView_RewardList, Panel_RewardItem, handler(self, self.setListViewItemReward))
	
	local imgScrollSlider = ListView_RewardList:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_RewardList_X then
		g_tbScrollSliderXY.ListView_RewardList_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_RewardList_X - 2)
	
	self:initAchievementWnd(self.rootWidget)
	
	local Image_NPC = tolua.cast(self.rootWidget:getChildByName("Image_NPC"), "ImageView")
	local CCNode_Skeleton = g_CocosSpineAnimation("XiaoXianTong", 1, true)
	CCNode_Skeleton:setScaleX(-1)
	Image_NPC:removeAllNodes()
	Image_NPC:loadTexture(getUIImg("Blank"))
	Image_NPC:addNode(CCNode_Skeleton)	
	g_runSpineAnimation(CCNode_Skeleton, "idle", true)
	
	local ImageView_Background = tolua.cast(self.rootWidget:getChildByName("ImageView_Background"), "ImageView")
	ImageView_Background:loadTexture(getBackgroundPngImg("Buzhen_Main"))
	local ImageView_Prospect1 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect1"), "ImageView")
	ImageView_Prospect1:loadTexture(getBackgroundJpgImg("Buzhen_Prospect1"))
	local ImageView_Prospect2 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect2"), "ImageView")
	ImageView_Prospect2:loadTexture(getBackgroundJpgImg("Buzhen_Prospect2"))
end

function Game_Assistant:showActivenessPackageAni(tbData)
	local function funcAnimationEnd()
		local function funcWndClose()
			self:setImage_ActiveNessPNL()
			if tbData.updateHeroResourceInfo then
				tbData.updateHeroResourceInfo()
			end
		end
		local tbData = {
			nRewardStatus = 1,
			tbParamentList = tbData.tbParamentList,
			updateHeroResourceInfo = funcWndClose,
		}
		g_WndMgr:showWnd("Game_RewardBox", tbData)
	end
	g_AnimationHaloAction(self.curPackage, 1, funcAnimationEnd)
end

function Game_Assistant:closeWnd()
	self.ListView_ZhuShouList:updateItems(0)
	self.ListView_RewardList:updateItems(0)
	self.ListView_ChengJiuList:updateItems(0)
	self.openStatus = nil
	self.ButtonGroup = nil

	if self.tbTimer_ then 
		for i = 1,#self.tbTimer_ do 
			g_Timer:destroyTimerByID(self.tbTimer_[i])
			self.tbTimer_[i] = nil
		end
	end	
	
	local ImageView_Background = tolua.cast(self.rootWidget:getChildByName("ImageView_Background"), "ImageView")
	ImageView_Background:loadTexture(getUIImg("Blank"))
	local ImageView_Prospect1 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect1"), "ImageView")
	ImageView_Prospect1:loadTexture(getUIImg("Blank"))
	local ImageView_Prospect2 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect2"), "ImageView")
	ImageView_Prospect2:loadTexture(getUIImg("Blank"))
end

function Game_Assistant:openWnd(bReq)
	--处理连续点击领取活跃礼包显示错误
	self.Button_Get:setTouchEnabled(true)
	
	if (g_bReturn or bReq == true ) then
		local CurIndex = 0
		if self.ButtonGroup then
			CurIndex = self.ButtonGroup:getButtonCurIndex()
		end
		
		if CurIndex == 1  then
			if g_PlayerGuide:checkIsInGuide() then
				return
			end
		else
			return
		end
	end
	
	self.ButtonGroup:Click(1)
	
	self:refreshBubbleNotice()

	if g_PlayerGuide:checkCurrentGuideSequenceNode("OpenWndAssitant", "Game_Assistant") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
	g_MsgNetWorkWarning:closeNetWorkWarning()
end

--月卡信息
function setYueKaInfo(tbData)
	tbYueKaDeadline = {}
	for k, v in ipairs(tbData) do
		tbYueKaDeadline[common_pb.RewardType_MonthYuanbao1 + k - 1] = v
	end 
end

function resetYueKaInfo()
	tbYueKaDeadline = tbYueKaDeadline or {}
	for k, v in ipairs(tbYueKaDeadline) do
		if remain_day > 0 then
			remain_day = remain_day - 1
		end
	end 
end

function isYuekaEnabled(nIndex)
	return tbYueKaDeadline[nIndex].remain_day ~= 0
end

function Game_Assistant:ModifyWnd_viet_VIET()

end
	