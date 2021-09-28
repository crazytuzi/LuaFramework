--------------------------------------------------------------------------------------
-- 文件名:	Game_SelectGameLevel1.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	yupingli
-- 日  期:	2015-3-7 19:37
-- 版  本:	1.0
-- 描  述:	界面
-- 应  用:   
---------------------------------------------------------------------------------------
Game_SelectGameLevel1 = class("Game_SelectGameLevel1")
Game_SelectGameLevel1.__index = Game_SelectGameLevel1

local nFightNum = 0
local nMaxFightNums = 0

function Game_SelectGameLevel1:setEcytpeIcon()
	if not self.nCurrentEctypeCsvID then return end
	if not self.rootWidget then return end
	
	local CSV_MapEctype = g_DataMgr:getMapEctypeCsv(self.nCurrentEctypeCsvID)
    local nStarLev = CSV_MapEctype.MonsterStarLevel
	
	local ImageView_SelectGameLevelPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_SelectGameLevelPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(ImageView_SelectGameLevelPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Image_InfoPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_InfoPNL"), "ImageView")
	
    local Image_MonsterIconBack =  tolua.cast(Image_InfoPNL:getChildByName("Image_MonsterIconBack"), "ImageView") 
    Image_MonsterIconBack:loadTexture(getEctypeIconResource("FrameEctypeBack", nStarLev))

    local Image_MonsterIconFrame = tolua.cast(Image_MonsterIconBack:getChildByName("Image_MonsterIconFrame"), "ImageView")
    Image_MonsterIconFrame:loadTexture(getEctypeIconResource("FrameEctype", nStarLev))

    local Image_Icon = tolua.cast(Image_MonsterIconBack:getChildByName("Image_Icon"), "ImageView") 
    Image_Icon:loadTexture(getIconImg(CSV_MapEctype.BossPotrait) )

    local Label_EctypeName = tolua.cast(Image_InfoPNL:getChildByName("Label_EctypeName"), "Label") 
    Label_EctypeName:setText(CSV_MapEctype.EctypeName)

    local Label_NeedEnergy = tolua.cast(Image_InfoPNL:getChildByName("Label_NeedEnergy"), "Label") 
    Label_NeedEnergy:setText(CSV_MapEctype.NeedEnergy)

	self.Image_InfoPNL = Image_InfoPNL

	
    local Label_FightNums = tolua.cast(Image_InfoPNL:getChildByName("Label_FightNums"), "Label") 
    local tbStarRecord = g_Hero:getEctypePassStar(CSV_MapEctype.EctypeID)
    local nFightNum = 0 
    if tbStarRecord then
        nFightNum = tbStarRecord.attack_num
    end


	local Button_AddTimes = tolua.cast(Image_InfoPNL:getChildByName("Button_AddTimes"),"Button")
	
	
	g_VIPBase:setCommonEncryptid(self.nCurrentEctypeCsvID)
	local VIPNum = g_VIPBase:getAddTableByNum(VipType.VIP_TYPE_COMMON_ENCRYPT)
	local maxFightNum = CSV_MapEctype.MaxFightNums + VIPNum
    Label_FightNums:setText(string.format("%d/%d", nFightNum,maxFightNum))
	
	g_AdjustWidgetsPosition({Label_FightNums,Button_AddTimes},-18)
	
    local Image_MonsterIconChar = tolua.cast(Image_MonsterIconBack:getChildByName("Image_MonsterIconChar"), "ImageView")  
    if(CSV_MapEctype.IsBoss == 1)then --为boss		
        Image_MonsterIconChar:loadTexture(getEctypeIconResource("FrameEctypeBossChar", CSV_MapEctype.MonsterStarLevel) )
	else	
        Image_MonsterIconChar:loadTexture(getEctypeIconResource("FrameEctypeNormalChar", CSV_MapEctype.MonsterStarLevel) )
	end
	
	local Obj_EctypeSub = g_EctypeListSystem:GetEctypeSuyBySubID(self.nCurrentMapCsvID, self.nCurrentEctypeCsvID)
	if Obj_EctypeSub then
		local AtlasLabel_StarRecord = tolua.cast(Image_MonsterIconBack:getChildByName("AtlasLabel_StarRecord"), "LabelAtlas")
		AtlasLabel_StarRecord:setStringValue(Obj_EctypeSub:GetStarStringValue())
	end
	
	local Label_NeedEnergyLB = tolua.cast(Image_InfoPNL:getChildByName("Label_NeedEnergyLB"), "Label") 
	local Label_FightNumsLB = tolua.cast(Image_InfoPNL:getChildByName("Label_FightNumsLB"), "Label") 
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		
		Label_NeedEnergyLB:setFontSize(18)
		Label_NeedEnergy:setFontSize(18)
		Label_FightNumsLB:setFontSize(18)
		Label_FightNums:setFontSize(18)

		g_AdjustWidgetsPosition({Label_NeedEnergyLB, Label_NeedEnergy, Label_FightNumsLB, Label_FightNums},10)
	end
	
	
end

function Game_SelectGameLevel1:set_Button_GameLevel(nEctypeSubLevelType)
	local CSV_MapEctype = g_DataMgr:getMapEctypeCsv(self.nCurrentEctypeCsvID)
	local nSubEctypeID = CSV_MapEctype["SubEctype"..nEctypeSubLevelType]
	
	local ImageView_SelectGameLevelPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_SelectGameLevelPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(ImageView_SelectGameLevelPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Button_GameLevel = tolua.cast(Image_ContentPNL:getChildByName("Button_GameLevel"..nEctypeSubLevelType), "ImageView")

	local Image_InfoPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_InfoPNL"), "ImageView")
	local Button_AddTimes = tolua.cast(Image_InfoPNL:getChildByName("Button_AddTimes"),"Button")
	
	local Label_FightNums = tolua.cast(Image_InfoPNL:getChildByName("Label_FightNums"), "Label") 
	
	local ectypeName = CSV_MapEctype.EctypeName
	
	local function onClickAddNum(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then 
			g_VIPBase:setCommonEncryptid(self.nCurrentEctypeCsvID)
			local VIPNum = g_VIPBase:getAddTableByNum(VipType.VIP_TYPE_COMMON_ENCRYPT)
			local nNum = g_VIPBase:getVipLevelCntNum(VipType.VIP_TYPE_COMMON_ENCRYPT)
			if VIPNum >= nNum then 
				g_ShowSysTips({text=_T("您今日[")..ectypeName.._T("]副本的购买次数已用完\n下一VIP等级可以增加购买次数上限")})
				return
			end
			
			local gold = g_VIPBase:getVipLevelCntGold(VipType.VIP_TYPE_COMMON_ENCRYPT)
			if not g_CheckYuanBaoConfirm(gold,_T("购买[")..ectypeName.._T("]副本需要花费")..gold.._T("元宝，您的元宝不够是否前往充值？")) then
				return
			end
			
			local str = _T("是否花费")..gold.._T("元宝购买1次[")..ectypeName.._T("]副本？")
			g_ClientMsgTips:showConfirm(str, function() 
				local function sellEctypeNumFunc(times)
					
					local tbStarRecord = g_Hero:getEctypePassStar(CSV_MapEctype.EctypeID)
					local nFightNum = 0 
					if tbStarRecord then
						nFightNum = tbStarRecord.attack_num
					end
					
					g_VIPBase:setCommonEncryptid(self.nCurrentEctypeCsvID)
					-- local VIPNum = g_VIPBase:getAddTableByNum(VipType.VIP_TYPE_COMMON_ENCRYPT)
					local maxFightNum = CSV_MapEctype.MaxFightNums + times
					Label_FightNums:setText(string.format("%d/%d", nFightNum,maxFightNum))
					
					g_AdjustWidgetsPosition({Label_FightNums,Button_AddTimes},-18)
					g_ShowSysTips({text=_T("成功购买1次[")..ectypeName.._T("]副本\n您还可购买")..nNum - times.._T("次。")})
					
					gTalkingData:onPurchase(TDPurchase_Type.TDP_COMMON_ECTYPE_NUM, 1 ,gold)	
				
				end
				g_VIPBase:responseFunc(sellEctypeNumFunc)
				g_VIPBase:requestCommonEncryptBuyRequest(self.nCurrentEctypeCsvID)
			end)
		end
	end
	Button_AddTimes:setTouchEnabled(true)
	Button_AddTimes:addTouchEventListener(onClickAddNum)
	g_AdjustWidgetsPosition({Label_FightNums,Button_AddTimes},-18)
	--战斗按钮
	local Button_StartBattle = tolua.cast(Button_GameLevel:getChildByName("Button_StartBattle"), "Button")
	-- Button_StartBattle:setTouchEnabled(true)
	Button_StartBattle:setTag(nSubEctypeID)
	Button_StartBattle.subLevelType = nEctypeSubLevelType

	local function onClick_Button_StartBattle(sender, eventType)
		if(eventType == ccs.TouchEventType.ended)then
			local nSubEctypeID = sender:getTag()
			local CSV_MapEctypeSub = g_DataMgr:getMapEctypeSubCsv(nSubEctypeID)
			local CSV_MapEctype = g_DataMgr:getMapEctypeCsv(CSV_MapEctypeSub.EctypeID)
			if(CSV_MapEctype.NeedEnergy > g_Hero:getEnergy() )then
				g_ClientMsgTips:showMsgConfirm(_T("您的体力不足, 请稍后再试。"))
				return
			end
			
			if( CSV_MapEctype.OpenLevel > g_Hero:getMasterCardLevel() )then
				g_ClientMsgTips:showMsgConfirm(string.format(_T("您需要%d级才能挑战该副本"), CSV_MapEctype.OpenLevel))
				return
			end

			local tbStar = g_Hero:getEctypePassStar(CSV_MapEctype.EctypeID)
			
			g_VIPBase:setCommonEncryptid(self.nCurrentEctypeCsvID)
			local VIPNum = g_VIPBase:getAddTableByNum(VipType.VIP_TYPE_COMMON_ENCRYPT)
			local maxFightNum = CSV_MapEctype.MaxFightNums + VIPNum
			
			if tbStar and maxFightNum <= tbStar.attack_num then
				g_ClientMsgTips:showMsgConfirm(string.format(_T("您挑战次数已满")))
				return
			end
			
			-- if(bSendBattleFlag)then
				-- return
			-- end
			
			if( g_Hero:getDialogTalkID() < nSubEctypeID)then --说明未对话
				g_Hero:setDialogTalkID(CSV_MapEctypeSub.DialogueID )
			else
				g_Hero:setDialogTalkID(nil)
			end
		
			g_MsgMgr:requestBattleInfo(nSubEctypeID)

			-- bSendBattleFlag = true
			-- local function resetBattleFlag()
				-- bSendBattleFlag = nil
			-- end
			-- g_Timer:pushTimer(1, resetBattleFlag)
		end
	end

	Button_StartBattle:addTouchEventListener(onClick_Button_StartBattle)		

	local tbSubEctypeInfo = g_DataMgr:getMapEctypeSubCsv(nSubEctypeID)
	
	
	-- 胜利条件说明
    if self.Image_InfoPNL then 
		local Label_Tips = tolua.cast(self.Image_InfoPNL:getChildByName("Label_Tips"), "Label") 
		Label_Tips:setText(tbSubEctypeInfo.WinDec)
	end
	
	local nExp = tbSubEctypeInfo.ShowExp
	local nMoney =  tbSubEctypeInfo.ShowCoins
	--设置经验
	local Image_ExpReward = tolua.cast(Button_GameLevel:getChildByName("Image_ExpReward"), "ImageView")
	local Label_Exp = tolua.cast(Image_ExpReward:getChildByName("Label_Exp"), "Label")
	Label_Exp:setText(string.format("%d", nExp))
	--设置金钱
	local Image_MoneyReward = tolua.cast(Button_GameLevel:getChildByName("Image_MoneyReward"), "ImageView")
	local Label_Coins = tolua.cast(Image_MoneyReward:getChildByName("Label_Coins"), "Label")
	Label_Coins:setText(string.format("%d", nMoney))
	--提示文字

	--设置难度星星
	local AtlasLabel_StarRecordSub = tolua.cast(Button_GameLevel:getChildByName("AtlasLabel_StarRecordSub"), "LabelAtlas")
	if AtlasLabel_StarRecordSub ~= nil then
		local Obj_EctypeSub = g_EctypeListSystem:GetEctypeSuyBySubID(self.nCurrentMapCsvID, self.nCurrentEctypeCsvID)
		if Obj_EctypeSub ~= nil then
			AtlasLabel_StarRecordSub:setStringValue(EctypeStarString[1][Obj_EctypeSub:GetDegreeStarCount(nEctypeSubLevelType)])
		end
	end
	
	local Button_SaoDang = tolua.cast(Button_GameLevel:getChildByName("Button_SaoDang"), "Button")
	local BitmapLabel_FuncName = tolua.cast(Button_SaoDang:getChildByName("BitmapLabel_FuncName"),"LabelBMFont")
	local BitmapLabel_FuncNameBattle = tolua.cast(Button_StartBattle:getChildByName("BitmapLabel_FuncName"),"LabelBMFont")
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		BitmapLabel_FuncName:setScale(0.8)
		BitmapLabel_FuncNameBattle:setScale(0.8)
	end
	
	local tbStar = g_Hero:getEctypePassStar(self.nCurrentEctypeCsvID)
	
	local btnBattle, btnSaoDang = false, false
	local uiImg = nil
	
	local Image_Mask = Button_GameLevel:getChildByName("Image_Mask")
	Image_Mask:setVisible(false)
	
	if nEctypeSubLevelType > 1 then -- 副本难度是高手及高手以上
		if not tbStar then -- 无星级记录
			cclog("==================AAAAAAA================")
			Image_Mask:setVisible(true)
			btnBattle,btnSaoDang = false,false
		else
		   local nStar = tbStar.star + 1
		   if nEctypeSubLevelType == nStar then --新开启的难度
				Button_StartBattle:setPositionX(360)
				btnBattle,btnSaoDang = true,false
				uiImg1 = "CommonYellow3"
	
		   elseif nEctypeSubLevelType < nStar then --已打过的副本
				Button_StartBattle:setPositionX(418)
				Button_SaoDang:setPositionX(308)
				btnBattle,btnSaoDang = true,true
				uiImg1 = "Common2"
		   else --未开启的副本
				Image_Mask:setVisible(true)
				btnBattle,btnSaoDang = false,false
		   end
		end   
	else
		if not tbStar then
			Button_StartBattle:setPositionX(360)
			btnBattle,btnSaoDang = true,false
			uiImg1 = "CommonYellow3"
		else
			Button_StartBattle:setPositionX(418)
			Button_SaoDang:setPositionX(308)
			btnBattle,btnSaoDang = true,true
			uiImg1 = "Common2"
		end        
	end
	
	local normal = getUIImg("Btn_"..uiImg1)
	local selected = getUIImg("Btn_"..uiImg1.."_Press")
	local disabled = getUIImg("Btn_"..uiImg1.."_Disabled")
	Button_StartBattle:loadTextures(normal,selected,disabled)
	
	Button_SaoDang:setVisible(btnSaoDang)
	Button_SaoDang:setTouchEnabled(btnSaoDang)
	
	--扫荡按钮
	local function onClick_Button_SaoDang(pSender, nTag)
		g_SaoDangData:commonEctypSaoDang(nTag, self.nCurrentEctypeCsvID)
	end
	g_SetBtnWithOpenCheck(Button_SaoDang, nSubEctypeID, onClick_Button_SaoDang, btnSaoDang)
	
	Button_StartBattle:setVisible(btnBattle)
	Button_StartBattle:setTouchEnabled(btnBattle)
	
	local Obj_EctypeSub = g_EctypeListSystem:GetEctypeSuyBySubID(self.nCurrentMapCsvID, self.nCurrentEctypeCsvID)
	if Obj_EctypeSub ~= nil then
		self.tbLuaListView[nEctypeSubLevelType]:updateItems(Obj_EctypeSub:GetRewardCountByType(nEctypeSubLevelType))
	end
end

function Game_SelectGameLevel1:init_Button_GameLevel(nEctypeSubLevelType)
	local ImageView_SelectGameLevelPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_SelectGameLevelPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(ImageView_SelectGameLevelPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Button_GameLevel = tolua.cast(Image_ContentPNL:getChildByName("Button_GameLevel"..nEctypeSubLevelType), "ImageView")
	if not Button_GameLevel then return end
	
	local function onClick_DropItemModel(pSender, nTag)
		local Obj_EctypeSub = g_EctypeListSystem:GetEctypeSuyBySubID(self.nCurrentMapCsvID, self.nCurrentEctypeCsvID)
		if Obj_EctypeSub == nil then
			return
		end
		
		local CSV_DropItem = Obj_EctypeSub:GetRewardItemByType(math.mod(nTag, 10), math.floor(nTag/10))
		if CSV_DropItem == nil then
			return
		end
		g_ShowDropItemTip(CSV_DropItem)
	end
	
	local function onUpdateDropItemList(Panel_DropItem, nIndex)
		local Obj_EctypeSub = g_EctypeListSystem:GetEctypeSuyBySubID(self.nCurrentMapCsvID, self.nCurrentEctypeCsvID)
		if Obj_EctypeSub == nil then
			return
		end
		
		local CSV_DropItem = Obj_EctypeSub:GetRewardItemByType(nEctypeSubLevelType, nIndex)
		if CSV_DropItem == nil then
			return
		end
		
		Panel_DropItem:removeAllChildren()
		local itemModel = g_CloneDropItemModel(CSV_DropItem)
		if itemModel then
			itemModel:setPositionXY(50,55)
			itemModel:setScale(0.8)
			Panel_DropItem:addChild(itemModel)
			g_SetBtnWithEvent(itemModel, nIndex*10+nEctypeSubLevelType, onClick_DropItemModel, true)
		end
	end

	local ListView_DropItem = tolua.cast(Button_GameLevel:getChildByName("ListView_DropItem"), "ListViewEx")
	local Panel_DropItem = tolua.cast(ListView_DropItem:getChildByName("Panel_DropItem"), "Layout")
	local LuaListView_DropItem = Class_LuaListView:new()
    LuaListView_DropItem:setListView(ListView_DropItem)
	LuaListView_DropItem:setModel(Panel_DropItem)
	LuaListView_DropItem:setUpdateFunc(onUpdateDropItemList)
	
	self.tbLuaListView[nEctypeSubLevelType] = LuaListView_DropItem
end

function Game_SelectGameLevel1:initWnd()
	self.tbLuaListView = {}
	for nEctypeSubLevelType = 1, 3 do
        self:init_Button_GameLevel(nEctypeSubLevelType)
    end
end

function Game_SelectGameLevel1:closeWnd()
end 

--选择游戏副本难度
function Game_SelectGameLevel1:openWnd(tbParam)
	cclog("===========打开Game_SelectGameLevel1界面===========")
	--[[
		在扫荡结束后 关闭扫荡界面会刷新 本页面 
		这个时候 self.nCurrentEctypeCsvID 为空
	]]
	if not tbParam then 
		self:setEcytpeIcon()
		return 
	end
	
	self.nCurrentMapCsvID = tbParam.nMapCsvID
	self.nCurrentEctypeCsvID = tbParam.nEctypeCsvID
	
	self:setEcytpeIcon()
	
	local nIndex = self.nCurrentMapCsvID or 1
	if nIndex > 3 then nIndex = 3 end
    --设置普通的
    for nEctypeSubLevelType = 1, nIndex do
        self:set_Button_GameLevel(nEctypeSubLevelType)
    end
	
	local ImageView_SelectGameLevelPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_SelectGameLevelPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(ImageView_SelectGameLevelPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Image_BuZhen = tolua.cast(Image_ContentPNL:getChildByName("Image_BuZhen"), "ImageView")
	local Button_BuZhen = tolua.cast(Image_BuZhen:getChildByName("Button_BuZhen"), "ImageView")
	local function onClick_Button_BuZhen(pSender, nTag)
		g_WndMgr:showWnd("Game_BattleBuZhen")
	end
	g_SetBtnWithPressImage(Button_BuZhen, 1, onClick_Button_BuZhen, true, 1)
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("OpenWndSelectGameLevel", "Game_SelectGameLevel") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end

function Game_SelectGameLevel1:showWndOpenAnimation(funcWndOpenAniCall)
	local ImageView_SelectGameLevelPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_SelectGameLevelPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(ImageView_SelectGameLevelPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_SelectGameLevel1:showWndCloseAnimation(funcWndCloseAniCall)
	local ImageView_SelectGameLevelPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_SelectGameLevelPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(ImageView_SelectGameLevelPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end