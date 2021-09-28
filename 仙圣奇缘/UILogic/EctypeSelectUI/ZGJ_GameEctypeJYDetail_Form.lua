--------------------------------------------------------------------------------------
-- 文件名:	Class_Fate.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	周光剑
-- 日  期:	2015-6-30
-- 版  本:	1.0
-- 描  述:	精英副本Form
-- 应  用:  
---------------------------------------------------------------------------------------

Game_EctypeJYDetail = class("Game_EctypeJYDetail")
Game_EctypeJYDetail.__index = Game_EctypeJYDetail

local function onClick_Button_EnterBattle(pSender, nTag)
	local wndInstance = g_WndMgr:getWnd("Game_EctypeJYDetail")
	if wndInstance then
		if wndInstance.tbJY.NeedEnergy > g_Hero:getEnergy() then
			g_ClientMsgTips:showMsgConfirm(_T("您的体力不足, 请稍后再试。"))
			return
		end
		
		if wndInstance.tbJY.OpenLevel > g_Hero:getMasterCardLevel() then
			g_ClientMsgTips:showMsgConfirm(string.format(_T("您需要%d级才能挑战该副本"), wndInstance.tbJY.OpenLevel))
			return
		end
		
		local types = VipType.VIP_TYPE_JY_ENCRYPT
		local addNum = g_VIPBase:getAddTableByNum(types)
		
		local tbStar = g_Hero:getEctypePassStar(wndInstance.tbJY.EctypeID)
		if wndInstance.nFightNum >= wndInstance.tbJY.MaxFightNums + addNum then
			g_ClientMsgTips:showMsgConfirm(string.format(_T("您挑战次数已满")))
			return
		end
		
		-- 客户端不判断背包 by kakiwang
		--if g_Hero:checkReportNumFull() then return end
		g_EctypeJY:setCurAttackJY(wndInstance.tbJY.EctypePage, wndInstance.tbJY.Index)
		g_EctypeJY:requestAttackJY()
	end
end

local function onClick_DropItemModel(pSender, nTag)
	local wndInstance = g_WndMgr:getWnd("Game_EctypeJYDetail")
	if wndInstance then
		local CSV_DropItem = wndInstance.tbDropItemList[nTag]
		if CSV_DropItem == nil then
			return
		end
		g_ShowDropItemTip(CSV_DropItem)
	end
end

function Game_EctypeJYDetail:setDropItem(widget, index)
	local itemModel = g_CloneDropItemModel(self.tbDropItemList[index])
	widget:removeAllChildren()
	if itemModel then
		itemModel:setPositionXY(50,55)
		itemModel:setScale(0.8)
		widget:addChild(itemModel)
		g_SetBtnWithEvent(itemModel, index, onClick_DropItemModel, true)
	end
end

function Game_EctypeJYDetail:initWnd(rootWidget, tbData)
	if not tbData then return end
	local Image_EctypeJingYingDetailPNL = self.rootWidget:getChildByName("Image_EctypeJingYingDetailPNL")
	self.Label_EctypeName = tolua.cast(Image_EctypeJingYingDetailPNL:getChildByName("Label_EctypeName"),"Label")
	self.Label_FightNums = tolua.cast(Image_EctypeJingYingDetailPNL:getChildByName("Label_FightNums"),"Label")
	self.Label_NeedEnergy = tolua.cast(Image_EctypeJingYingDetailPNL:getChildByName("Label_NeedEnergy"),"Label")
	self.ListView_DropItem = tolua.cast(Image_EctypeJingYingDetailPNL:getChildByName("ListView_DropItem"),"ListViewEx")
	self.Panel_DropItem = self.ListView_DropItem:getChildByName("Panel_DropItem")
	self.Button_EnterBattle = tolua.cast(Image_EctypeJingYingDetailPNL:getChildByName("Button_EnterBattle"),"Button")
	
	self.Button_SaoDang = tolua.cast(Image_EctypeJingYingDetailPNL:getChildByName("Button_SaoDang"),"Button")

	local Image_ExpReward = Image_EctypeJingYingDetailPNL:getChildByName("Image_ExpReward")
	self.Label_Exp = tolua.cast(Image_ExpReward:getChildByName("Label_Exp"),"Label")
	local Image_MoneyReward = Image_EctypeJingYingDetailPNL:getChildByName("Image_MoneyReward")
	self.Label_Coins = tolua.cast(Image_MoneyReward:getChildByName("Label_Coins"),"Label")
	local Image_KnowledgeReward = Image_EctypeJingYingDetailPNL:getChildByName("Image_KnowledgeReward")
	self.Label_Knowledge = tolua.cast(Image_KnowledgeReward:getChildByName("Label_Knowledge"),"Label")

	g_SetBtnWithEvent(self.Button_EnterBattle, nil, onClick_Button_EnterBattle, true)
	

	
	self.LuaListview = registerListViewEvent(self.ListView_DropItem, self.Panel_DropItem, handler(self,self.setDropItem))

	self.Button_AddTimes = tolua.cast(Image_EctypeJingYingDetailPNL:getChildByName("Button_AddTimes"),"Button")
	local function onClickAddNum(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then 
			cclog("增加上限")
			local types = VipType.VIP_TYPE_JY_ENCRYPT
			
			local allNum = g_VIPBase:getVipLevelCntNum(types)
			local addNum = g_VIPBase:getAddTableByNum(types)
			if addNum >= allNum then 
					g_ShowSysTips({text=_T("您今日")..self.tbJY.EctypeName.._T("副本的购买次数已用完\n下一VIP等级可以增加购买次数上限")})
				return 
			end

			local gold = g_VIPBase:getVipLevelCntGold(types)
			if not g_CheckYuanBaoConfirm(gold, _T("您的元宝不足是否前往充值")) then
				return
			end
			local str = _T("是否花费")..gold.._T("元宝购买1次")..self.tbJY.EctypeName.._T("副本？")
			g_ClientMsgTips:showConfirm(str, function() 
				local function serverResponseCall(times)	
					local addNum = g_VIPBase:getAddTableByNum(types)
					self.nFightNum = g_EctypeJY:getAttackNum(self.tbJY.EctypePage, self.tbJY.Index) 
					self.Label_FightNums:setText(self.nFightNum.."/"..self.tbJY.MaxFightNums + times)
					self.Label_FightNums:setColor(ccc3(0, 255, 0))
					self.Button_EnterBattle:setBright(true)
					self.Button_EnterBattle:setTouchEnabled(true)
					g_ShowSysTips({text=_T("成功购买1次")..self.tbJY.EctypeName.._T("副本\n您还可购买")..allNum - times.._T("次。")})
					
					gTalkingData:onPurchase(TDPurchase_Type.TDP_JY_DEATAIL_ECTYPE_NUM,1,gold)	
				
				end
				g_VIPBase:responseFunc(serverResponseCall)
				g_VIPBase:requestJingYingEncryptBuyRequest(self.tbJY.EctypePage, self.tbJY.Index)
				g_AdjustWidgetsPosition({self.Label_FightNums, self.Button_AddTimes},-20)
			end)
		end
	end
	self.Button_AddTimes:setTouchEnabled(true)
	self.Button_AddTimes:addTouchEventListener(onClickAddNum)

	if tbData then
		self.tbJY = tbData
		local Panel_Card = Image_EctypeJingYingDetailPNL:getChildByName("Panel_Card")
		self.Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"), "ImageView")
		self.Image_Card:removeAllNodes()
		self.Image_Card:loadTexture(getUIImg("Blank"))
		self.Image_Card:setPositionXY(self.tbJY.Pos_X, self.tbJY.Pos_Y)

		--android 崩溃
		-- g_CocosSpineAnimationAsync(nil, self.Image_Card, self.tbJY.BossPotrait, 1 , "idle")

		local spine = g_CocosSpineAnimation(self.tbJY.BossPotrait, 1)
		if spine then
			self.Image_Card:addNode(spine)
			g_runSpineAnimation(spine, "idle", true)
		end

		self.Label_EctypeName:setText(self.tbJY.EctypeName)
		self.Label_NeedEnergy:setText(self.tbJY.NeedEnergy)
		self.Label_Exp:setText(self.tbJY.ShowExp)
		self.Label_Coins:setText(self.tbJY.ShowCoins)
		self.Label_Knowledge:setText(self.tbJY.ShowKnowledge)
		self.tbDropItemList = g_EctypeJY:getReward(self.tbJY.EctypePage, self.tbJY.Index)
		self.LuaListview:updateItems(#self.tbDropItemList)
	end

	local Image_BuZhen = tolua.cast(Image_EctypeJingYingDetailPNL:getChildByName("Image_BuZhen"), "ImageView")
	local Button_BuZhen = tolua.cast(Image_BuZhen:getChildByName("Button_BuZhen"), "ImageView")
	local function onClick_Button_BuZhen(pSender, nTag)
		g_WndMgr:showWnd("Game_BattleBuZhen")
	end
	g_SetBtnWithPressImage(Button_BuZhen, 1, onClick_Button_BuZhen, true, 1)
end

function Game_EctypeJYDetail:openWnd()
	--需要刷新挑战次数
	--if g_bReturn then return end
	if not self.tbJY then return end
	
	g_VIPBase:setJYPageIdPageIndex(self.tbJY.EctypePage, self.tbJY.Index)
	
	local types = VipType.VIP_TYPE_JY_ENCRYPT
	local addNum = g_VIPBase:getAddTableByNum(types)
	self.nFightNum = g_EctypeJY:getAttackNum(self.tbJY.EctypePage, self.tbJY.Index) 
	
	self.Label_FightNums:setText(self.nFightNum.."/"..self.tbJY.MaxFightNums + addNum)
	if self.nFightNum >= self.tbJY.MaxFightNums  + addNum then
		self.Label_FightNums:setColor(ccc3(255, 0, 0))
		self.Button_EnterBattle:setBright(false)
		self.Button_EnterBattle:setTouchEnabled(false)
	else
		self.Label_FightNums:setColor(ccc3(0, 255, 0))
	end
	
	g_AdjustWidgetsPosition({self.Label_FightNums, self.Button_AddTimes},-20)
	--小于一星的时候不开启扫荡
	local starNum = g_EctypeJY:getStarNum(self.tbJY.EctypePage, self.tbJY.Index)
	if starNum < 1 then 
		self.Button_SaoDang:setVisible(false)
		self.Button_SaoDang:setTouchEnabled(false)
	else
		local function saoDangFunc(pSender, nTag)
			if nTag < 3 then
				g_ShowSysTips({text = _T("三星通关方可开启深渊副本的扫荡功能")})
			else
				g_SaoDangData:eliteEctypSaoDang(self.tbJY.EctypePage, self.tbJY.Index)
				g_EctypeJY:setCurAttackJY(self.tbJY.EctypePage, self.tbJY.Index)
				g_EctypeJY:setDirty(true)
			end
		end
	
		self.Button_SaoDang:setVisible(true)
		self.Button_SaoDang:setTouchEnabled(false)
		g_SetBtnWithOpenCheck(self.Button_SaoDang, starNum, saoDangFunc, true)
	end
end

function Game_EctypeJYDetail:closeWnd()
	-- body
end

function Game_EctypeJYDetail:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_EctypeJingYingDetailPNL = tolua.cast(self.rootWidget:getChildByName("Image_EctypeJingYingDetailPNL"), "ImageView")
	--local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_EctypeJingYingDetailPNL, funcWndOpenAniCall, 1.05, 0.2)
end

function Game_EctypeJYDetail:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_EctypeJingYingDetailPNL = tolua.cast(self.rootWidget:getChildByName("Image_EctypeJingYingDetailPNL"), "ImageView")
	--local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_EctypeJingYingDetailPNL, funcWndCloseAniCall, 1.05, 0.2)
end

function Game_EctypeJYDetail:ModifyWnd_viet_VIET()
    local Label_NeedEnergyLB = tolua.cast(self.rootWidget:getChildAllByName("Label_NeedEnergyLB"), "Label")
    local Label_NeedEnergy = tolua.cast(self.rootWidget:getChildAllByName("Label_NeedEnergy"), "Label")
    g_AdjustWidgetsPosition({Label_NeedEnergyLB, Label_NeedEnergy},1)

    local Label_FightNumsLB = tolua.cast(self.rootWidget:getChildAllByName("Label_FightNumsLB"), "Label")
    local Label_FightNums = tolua.cast(self.rootWidget:getChildAllByName("Label_FightNums"), "Label")
    local Button_AddTimes = tolua.cast(self.rootWidget:getChildAllByName("Button_AddTimes"), "Button")
    g_AdjustWidgetsPosition({Label_FightNumsLB, Label_FightNums, Button_AddTimes},1)

end