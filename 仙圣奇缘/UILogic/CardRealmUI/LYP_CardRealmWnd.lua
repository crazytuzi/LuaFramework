--------------------------------------------------------------------------------------
-- 文件名:	LYP_CardRealmWnd.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	yupingli
-- 日  期:	2014-11-06 9:54
-- 版  本:	1.0
-- 描  述:	伙伴渡劫界面
-- 应  用:
---------------------------------------------------------------------------------------
Game_CardDuJie = class("Game_CardDuJie")
Game_CardDuJie.__index = Game_CardDuJie
--是增加卡魂或者是减少
local HANDLE_TYPE = {
	T_MINUMS = 1,
	T_ADD = 2,
}
--是否可以渡劫等状态
-- local STATUS_TYPE = {
	-- NOT_COINS = 1,--铜钱不足
	-- NEED_ITEM = 2,--修炼花费
	-- MAX_REALM = 3,--境界已满
	-- NOT_ITEM = 4,--材料不足
	-- START_DUJIE = 5,--点击渡劫
	-- NOT_DUJIE_LEVEL = 6,--渡劫需要
-- } 

local nNotSuggestLevelSpace = 6
g_ListView_SoulList_Index = 1

function Game_CardDuJie:initWnd()
	g_ListView_SoulList_Index = 1
end

function Game_CardDuJie:openWnd(nCardID)
	
	g_CardRealmData:setAddExpRemove()
	
	if not g_bReturn then
		if not nCardID then nCardID =  g_Hero:getBattleCardByIndex(1):getServerId() end
	end
	
    --自动勾选
	self:registerOtherBtnEvent(nCardID)
    self.openUpdateFlagSoulList = false
	g_CardRealmData:cardRealmInit()

	if nCardID then  
		self.nCardID = nCardID 
		--伙伴
		self:registerPageView()
		--卡魂列表
		self:registerListView()
		--加载所有的卡牌
		g_Hero:SetCardFlagPV(1)
		local nCurCardIndex = g_Hero:GetCardIndexByIDPV(self.nCardID)
		self.LuaPageView_Card:setCurPageIndex(nCurCardIndex)
		self.LuaPageView_Card:updatePageView(g_Hero:GetCardAmmountForPV())
	end
	
	--渡劫按钮
	self:registerBtnJinJie()
	
	if g_bReturn then
		self:setCardRealmInfo()
	end
end

function Game_CardDuJie:closeWnd()
	if self.tbSubMsg then
		local tbCard = g_Hero:getCardObjByServID(self.tbSubMsg.upgarde_cardid)
		if tbCard then 
			tbCard:setReleamProp(self.tbSubMsg.upgarde_card_realm_lv, self.tbSubMsg.upgarde_card_realm_exp)
		end
		self.tbSubMsg = nil
	end
	
	if self.LuaPageView_Card then
		self.LuaPageView_Card:ReleaseItemModle()
	end
	self.LuaPageView_Card = nil
	-- self.LuaPageView_Card:removeAllPages()
	if self.nTimerId5 then 
		g_Timer:destroyTimerByID(self.nTimerId5)
		self.nTimerId5 = nil
	end
	if self.nTimerId6 then 
		g_Timer:destroyTimerByID(self.nTimerId6)
		self.nTimerId6 = nil
	end
	
	self.rootWidget:stopAllActions()
	self.rootWidget:removeAllNodes()
	
	local Image_CardInfoPNL = self.rootWidget:getChildByName("Image_CardInfoPNL")
	local Image_ConsumeAnimationPNL = Image_CardInfoPNL:getChildByName("Image_ConsumeAnimationPNL")
	Image_ConsumeAnimationPNL:removeAllNodes()
	Image_ConsumeAnimationPNL:stopAllActions()
	
	g_CardRealmData:setAddExpRemove()
	
	g_CardRealmData:cardRealmInit()
	
end

--伙伴境界进阶
function Game_CardDuJie:processMsgBackRealm(tbSubMsg)
	if not tbSubMsg then return end
	self.tbSubMsg = tbSubMsg
	
	local function animationOver()
		local wndInstance = g_WndMgr:getWnd("Game_CardDuJie")
		if wndInstance and wndInstance.tbSubMsg then
			local tbCard = g_Hero:getCardObjByServID(wndInstance.tbSubMsg.upgarde_cardid)
			if tbCard then
				--再进度动画播放完后 设置最新境界等级和经验
				tbCard:setReleamProp(wndInstance.tbSubMsg.upgarde_card_realm_lv, wndInstance.tbSubMsg.upgarde_card_realm_exp)
				wndInstance.tbSubMsg = nil
				
				if tbCard:IsNeedDujie() then
					local tbParams = {tbCardTarget = tbCard}
					g_ShowUpgradeEventAnimation(2, 3, tbParams, handler(g_Hero, g_Hero.showTeamStrengthGrowAnimation), nil)
				else
					g_Hero:showTeamStrengthGrowAnimation()
					if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationEnd", "YuanShenConsume") then
						g_PlayerGuide:showCurrentGuideSequenceNode()
					end
				end
			end
			
			wndInstance:setCardRealmInfo()
			wndInstance.bShowAnimation = nil
		end
	end
	local fShowSecs = self:createRealmDynamicLoadingBar(animationOver)
	
	self.bShowAnimation = true
	
	local Image_CardInfoPNL = self.rootWidget:getChildByName("Image_CardInfoPNL")
	local Image_ConsumeAnimationPNL = Image_CardInfoPNL:getChildByName("Image_ConsumeAnimationPNL")
	self.nTimerId6 = g_ShowCardConsumeAnimation(Image_ConsumeAnimationPNL, nil, fShowSecs*1.08, nil, nil)
end


function Game_CardDuJie:createRealmDynamicLoadingBar( animationOver)
	local tbCardInfo = g_Hero:getCardObjByServID(self.nCardID)
	if not tbCardInfo then return end
	local function setLoadingBarInfo(tbCardInfo,nAddExp,cccWidgetColor)
		if not self.rootWidget then return end 
		local Image_PropInfoPNL = tolua.cast(self.rootWidget:getChildByName("Image_PropInfoPNL"),"ImageView")
		local Image_LevelInfoPNL = tolua.cast(Image_PropInfoPNL:getChildByName("Image_LevelInfoPNL"),"ImageView")
		local Image_UpgradeDetailPNL = tolua.cast(Image_PropInfoPNL:getChildByName("Image_UpgradeDetailPNL"),"ImageView")
	
		local cccWidgetColor = cccWidgetColor or g_getColor(ccs.COLOR.WHITE)
		local nNewRealmLevel = tbCardInfo:getNewRealmLvByAddExp(nAddExp)
		
		local nNewRealmPrecent = tbCardInfo:getNewRealmExpPercentByAddExp(nAddExp)
	
		local CSV_RealmLevelNew = g_DataMgr:getCardRealmLevelCsv(nNewRealmLevel)
		local CSV_RealmLevelLast = g_DataMgr:getCardRealmLevelCsv(nNewRealmLevel-1)
		
		local nNewRealmExp = tbCardInfo:getRealmExp() + nAddExp - CSV_RealmLevelLast.RealmPointsMax
		local nNewRealmExpMax = CSV_RealmLevelNew.RealmPointsMax - CSV_RealmLevelLast.RealmPointsMax
		
		local Label_HPMaxSource = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Label_HPMaxSource"),"Label")
		Label_HPMaxSource:setText(tbCardInfo:getRealmHPMaxByNewLv(nNewRealmLevel))
		Label_HPMaxSource:setColor(cccWidgetColor)
		
		local Label_ForcePointsSource = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Label_ForcePointsSource"),"Label")
		Label_ForcePointsSource:setText(tbCardInfo:getRealmForcePointsByNewLv(nNewRealmLevel))
		Label_ForcePointsSource:setColor(cccWidgetColor)
		
		local Label_MagicPointsSource = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Label_MagicPointsSource"),"Label")
		Label_MagicPointsSource:setText(tbCardInfo:getRealmMagicPointsByNewLv(nNewRealmLevel))
		Label_MagicPointsSource:setColor(cccWidgetColor)
	
		local Label_SkillPointsSource = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Label_SkillPointsSource"),"Label")
		Label_SkillPointsSource:setText(tbCardInfo:getRealmSkillPointsByNewLv(nNewRealmLevel))
		Label_SkillPointsSource:setColor(cccWidgetColor)
		
		local Label_SourceLevel = tolua.cast(Image_LevelInfoPNL:getChildByName("Label_SourceLevel"),"Label")
		Label_SourceLevel:setText(tbCardInfo:getRealmNameWithSuffixByNewLv(nNewRealmLevel))
		
		local Image_Exp = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Image_Exp"),"ImageView")
		local LoadingBar_Exp = tolua.cast(Image_Exp:getChildByName("LoadingBar_Exp"),"LoadingBar")
		LoadingBar_Exp:setPercent(nNewRealmPrecent)
		
		local Label_ExpPercent = tolua.cast(LoadingBar_Exp:getChildByName("Label_ExpPercent"),"Label")
		Label_ExpPercent:setText(nNewRealmPrecent.."%")
		
		local Label_JingJieDian = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Label_JingJieDian"),"Label")
		Label_JingJieDian:setText( string.format( _T("境界经验 %d/%d"), nNewRealmExp, nNewRealmExpMax)  )
	end

	local function setToOver(bClose)
		local addExps = g_CardRealmData:getAddExp()
		setLoadingBarInfo(tbCardInfo,addExps, g_getColor(ccs.COLOR.WHITE))
		g_CardRealmData:cardRealmInit()
		if animationOver then
			animationOver()
			animationOver = nil
		end
		if g_PlayerGuide:checkCurrentGuideSequenceNode("ActionEventEnd", "Game_CardDuJie") then
			cclog("=================ActionEventEnd====================")
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	local addExps = g_CardRealmData:getAddExp()
	local nRealmExpPercent = tbCardInfo:getRealmExpPercent()
	local nNewRealmLevel = tbCardInfo:getNewRealmLvByAddExp(addExps)
	local nNewRealmExpPercent = tbCardInfo:getNewRealmExpPercentByAddExp(addExps)
	
	local fSpeed = 0.25
	local nAddLevel = nNewRealmLevel - tbCardInfo:getRealmLevel()
	local fShowSecs = 0
	if nAddLevel == 0 then
		fShowSecs = (nNewRealmExpPercent - nRealmExpPercent)*fSpeed/100
	elseif nAddLevel == 1 then
		fShowSecs = (100 - nRealmExpPercent)*fSpeed/100 + nNewRealmExpPercent*fSpeed/100
	elseif nAddLevel >= 2 then
		fShowSecs = (100 - nRealmExpPercent)*fSpeed/100 + (nAddLevel-1)*fSpeed + nNewRealmExpPercent*fSpeed/100
	end
	
	
	local nRealmFullNeedExp = tbCardInfo:getRealmFullNeedExp()
	
	local nAddExpEeveryStep = math.min(addExps,nRealmFullNeedExp) / (fShowSecs * (1 / g_Cfg.fFps))
	local nAddExp = 0
	local function showDynamicLoadingBar(fShowSecs, bTimerIsEnd)
		nAddExp = nAddExp + nAddExpEeveryStep
		if (bTimerIsEnd) then
			setToOver()
		else
			setLoadingBarInfo(tbCardInfo, nAddExp, g_getColor(ccs.COLOR.LIME_GREEN))
		end
	end
	self.nTimerId5 = g_Timer:pushLimtCountTimer(math.ceil((1/g_Cfg.fFps)*fShowSecs), 1/(1/g_Cfg.fFps), showDynamicLoadingBar)
	-- g_pushLimtCountTimer(1/(1/g_Cfg.fFps), math.ceil((1/g_Cfg.fFps)*fShowSecs), showDynamicLoadingBar, self.rootWidget)
	return fShowSecs
end


function Game_CardDuJie:setCardRealmInfo(flag)
	
	local tbCardInfo = g_Hero:getCardObjByServID(self.nCardID)
	if not tbCardInfo then return end 
	
	local Image_CardInfoPNL = tolua.cast(self.rootWidget:getChildByName("Image_CardInfoPNL"),"ImageView")

	local Label_Name = tolua.cast(Image_CardInfoPNL:getChildByName("Label_Name"),"Label")
	Label_Name:setText(tbCardInfo:getNameWithSuffix(Label_Name))
	
	local AtlasLabel_StarLevel = tolua.cast(Image_CardInfoPNL:getChildByName("AtlasLabel_StarLevel"),"LabelAtlas")
	AtlasLabel_StarLevel:setStringValue(tbCardInfo:getStarLevelStrValue())
	
	local Image_SymbolBlueLight = tolua.cast(Image_CardInfoPNL:getChildByName("Image_SymbolBlueLight"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	
	local Image_PropInfoPNL = tolua.cast(self.rootWidget:getChildByName("Image_PropInfoPNL"),"ImageView")
	local Image_LevelInfoPNL = tolua.cast(Image_PropInfoPNL:getChildByName("Image_LevelInfoPNL"),"ImageView")
	local Image_UpgradeDetailPNL = tolua.cast(Image_PropInfoPNL:getChildByName("Image_UpgradeDetailPNL"),"ImageView")
	
	--境界升级前的属性--------------------------------------
	--当前境界名称
	local Label_SourceLevel = tolua.cast(Image_LevelInfoPNL:getChildByName("Label_SourceLevel"),"Label")
	Label_SourceLevel:setText(tbCardInfo:getRealmNameWithSuffix(Label_SourceLevel))

	local nRealmHPMax = tbCardInfo:getCardRealmParam().realm_hpmax_moduls * tbCardInfo:getRealmHPMax() / g_BasePercent
	local Label_HPMaxSource = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Label_HPMaxSource"),"Label")
	Label_HPMaxSource:setText("+"..math.ceil(nRealmHPMax))
	--武力
	local nRealmForcePoints = tbCardInfo:getCardRealmParam().realm_forcepoints_moduls * tbCardInfo:getRealmForcePoints() / g_BasePercent
	local Label_ForcePointsSource = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Label_ForcePointsSource"),"Label")
	Label_ForcePointsSource:setText(math.ceil(nRealmForcePoints))
	
	--法术
	local nRealmMagicPoints = tbCardInfo:getCardRealmParam().realm_magicpoints_moduls * tbCardInfo:getRealmMagicPoints() / g_BasePercent
	local Label_MagicPointsSource = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Label_MagicPointsSource"),"Label")
	Label_MagicPointsSource:setText(math.ceil(nRealmMagicPoints))
	
	--绝技
	local nRealmSkillPoints = tbCardInfo:getCardRealmParam().realm_skillpoints_moduls * tbCardInfo:getRealmSkillPoints() / g_BasePercent 
	local Label_SkillPointsSource = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Label_SkillPointsSource"),"Label")
	Label_SkillPointsSource:setText(math.ceil(nRealmSkillPoints))
	
	--境界升级后的属性--------------------------------------
	local nNewLev, nNewExpPercent = g_CardRealmData:getAddExpToNextRealmLv(tbCardInfo)
	
	local ccsColorIndex = ccs.COLOR.WHITE
	if nNewLev > tbCardInfo:getRealmLevel() or tbCardInfo:IsNeedDujie() then
		ccsColorIndex = ccs.COLOR.BRIGHT_GREEN
	end

	local tbSoul = g_CardRealmData:getSelectSoul()
	
	local ccsRealmExpColor = ccs.COLOR.WHITE
	if GetTableLen(tbSoul) > 0 then
		ccsRealmExpColor = ccs.COLOR.BRIGHT_GREEN
	end

	local Image_Exp = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Image_Exp"),"ImageView")
	local LoadingBar_Exp = tolua.cast(Image_Exp:getChildByName("LoadingBar_Exp"),"LoadingBar")
	LoadingBar_Exp:setPercent(nNewExpPercent)
	local Label_ExpPercent = tolua.cast(LoadingBar_Exp:getChildByName("Label_ExpPercent"),"Label")
	Label_ExpPercent:setText(nNewExpPercent.."%")
	g_setTextColor(Label_ExpPercent, ccsRealmExpColor)
	
	local nFullExp = 0   
	self.nNeedMoney = 0
	local money = 0
	for key ,value in pairs(tbSoul) do 
		local csvSoul = g_DataMgr:getCardSoulCsv(g_CardRealmData:getSelectSoulID(key),g_CardRealmData:getSelectSoulStar(key))
		local need = csvSoul.AddNeedMoney * value
		money = money + need
	end
	local realmFatherLevel = g_DataMgr:getCsvConfigByOneKey("CardRealmLevel",tbCardInfo:getRealmLevel()).RealmFatherLevel
	self.nNeedMoney = realmFatherLevel * money
	
	local nCurExp = tbCardInfo:getRealmExp() + g_CardRealmData:getAddExp()
	if nNewLev > 1 then
		nCurExp = nCurExp - tbCardInfo:getCardRealmLevelCsvByNewLv(nNewLev-1).RealmPointsMax
		nFullExp = tbCardInfo:getCardRealmLevelCsvByNewLv(nNewLev).RealmPointsMax - tbCardInfo:getCardRealmLevelCsvByNewLv(nNewLev-1).RealmPointsMax
    else
        nFullExp =  tbCardInfo:getCardRealmLevelCsvByNewLv(1).RealmPointsMax
	end

	local Label_JingJieDian = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Label_JingJieDian"),"Label")
	-- Label_JingJieDian:setText("境界经验 "..nCurExp.."/"..nFullExp)
	Label_JingJieDian:setText( string.format( _T("境界经验 %d/%d"), nCurExp, nFullExp) )
	g_setTextColor(Label_JingJieDian, ccsRealmExpColor)

	local Button_JinJie = tolua.cast(Image_PropInfoPNL:getChildByName("Button_JinJie"),"Button")
	local Label_TargetLevel = tolua.cast(Image_LevelInfoPNL:getChildByName("Label_TargetLevel"),"Label")
	local Label_HPMaxTarget = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Label_HPMaxTarget"),"Label")
	local Label_ForceTarget = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Label_ForceTarget"),"Label")
	local Label_MagicPercentTarget = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Label_MagicPercentTarget"),"Label")
	local Label_SkillPointsTarget = tolua.cast(Image_UpgradeDetailPNL:getChildByName("Label_SkillPointsTarget"),"Label")
	
	local newLv = nNewLev
	self.IsNeedDujie = nil
	if tbCardInfo:IsNeedDujie() then
		self.IsNeedDujie = true
		newLv = math.min(nNewLev + 1, g_DataMgr:getCardRealmLevelCsvMaxLevel())
	end
	Label_TargetLevel:setText(tbCardInfo:getRealmNameWithSuffixByNewLv(newLv, Label_TargetLevel))
	local hp = tbCardInfo:getCardRealmParam().realm_hpmax_moduls * tbCardInfo:getRealmHPMaxByNewLv(newLv) / g_BasePercent
	Label_HPMaxTarget:setText("+"..math.ceil(hp))
	g_setTextColor(Label_HPMaxTarget, ccsColorIndex)
	--武力
	local force = tbCardInfo:getCardRealmParam().realm_forcepoints_moduls * tbCardInfo:getRealmForcePointsByNewLv(newLv) / g_BasePercent
	Label_ForceTarget:setText(math.ceil(force))
	g_setTextColor(Label_ForceTarget, ccsColorIndex)
	--法术
	local magic = tbCardInfo:getCardRealmParam().realm_magicpoints_moduls * tbCardInfo:getRealmMagicPointsByNewLv(newLv) / g_BasePercent
	Label_MagicPercentTarget:setText(math.ceil(magic))
	g_setTextColor(Label_MagicPercentTarget, ccsColorIndex)
	--绝技
	local skill = tbCardInfo:getCardRealmParam().realm_skillpoints_moduls * tbCardInfo:getRealmSkillPointsByNewLv(newLv) / g_BasePercent 
	Label_SkillPointsTarget:setText(math.ceil(skill))
	g_setTextColor(Label_SkillPointsTarget, ccsColorIndex)
	
	--渡劫消耗
	local BitmapLabel_NeedMoney = tolua.cast(Button_JinJie:getChildByName("BitmapLabel_NeedMoney"),"LabelBMFont")
	BitmapLabel_NeedMoney:setText(tostring(self.nNeedMoney))
	g_SetLabelRed(BitmapLabel_NeedMoney, self.nNeedMoney > g_Hero:getCoins())
	
	local Image_Coins =  tolua.cast(Button_JinJie:getChildByName("Image_Coins"),"ImageView")
	g_adjustWidgetsRightPosition({BitmapLabel_NeedMoney,Image_Coins})
	
	local Image_Check = tolua.cast(Button_JinJie:getChildByName("Image_Check"), "ImageView")
	local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSpriteCheck, 4)
	Button_JinJie:stopAllActions()
	
	local Image_CardMaterialListPNL = tolua.cast(self.rootWidget:getChildByName("Image_CardMaterialListPNL"),"ImageView")
	local Image_Tip = tolua.cast(Image_CardMaterialListPNL:getChildByName("Image_Tip"), "ImageView")

	local pointX = 5
	local point = ccp(0.5,0.5)
	local text = ""
	local bEnbale,bVisible = false,false

	local normal = "Btn_Common1"
	local pressed = "Btn_Common1_Press"
	local disabled = "Btn_Common1_Disabled"
	local ImageCheckFlag = false
	local LuaListViewSoulListFlag = false
	if not self.IsNeedDujie then
		if self.nNeedMoney > g_Hero:getCoins() then
			text = _T("铜钱不足")
			pointX = -160
			point = ccp(0,0.5)
			bEnbale, bVisible = false, true
		elseif g_Hero:getDescendSoulListCount() < 1 then
			text = _T("材料不足")
			LuaListViewSoulListFlag = true
		else
			text = _T("修炼花费")
			pointX = -160
			point = ccp(0,0.5)
			bEnbale, bVisible = true,true
			if GetTableLen(tbSoul) > 0 then
				ImageCheckFlag = true
				normal = "Btn_CommonYellow1"
				pressed = "Btn_CommonYellow1_Press"
				disabled = "Btn_CommonYellow1_Disabled"
			end
		end
	else
		LuaListViewSoulListFlag = true
		local bStatus, strStatusCode = g_CheckCardRealmUp(tbCardInfo)
		if strStatusCode == "CanDuJie" then
			text = _T("点击渡劫")
			bEnbale,bVisible = true,false
			ImageCheckFlag = true
			normal = "Btn_CommonYellow1"
			pressed = "Btn_CommonYellow1_Press"
			disabled = "Btn_CommonYellow1_Disabled"
		elseif strStatusCode == "CanNotDuJie" then --等级不足
			text =  string.format( _T("渡劫需要%d级"),tbCardInfo:getCardRealmLevelCsvNextLev().NeedLevel)
		elseif strStatusCode == "RealmIsMax" then --境界满级
			text = _T("境界已满")
		else
			LuaListViewSoulListFlag = false
		end
	end

	if not flag then  flag = LuaListViewSoulListFlag end
	self:setSoulListItems(flag)
	
	if LuaListViewSoulListFlag then 
		Image_Tip:setVisible(true)
		self.LuaListView_SoulList:updateItems(0)
	else
		Image_Tip:setVisible(g_Hero:getDescendSoulListCount()<1)
	end
	
	--卡魂重置和自动勾选的状态
	self:AutoPickCardOrResetStatus(false)
	
	local BitmapLabel_FuncName = tolua.cast(Button_JinJie:getChildByName("BitmapLabel_FuncName"),"LabelBMFont")
	BitmapLabel_FuncName:setText(text)
	BitmapLabel_FuncName:setPositionX(pointX)
	BitmapLabel_FuncName:setAnchorPoint(point)
	
	Button_JinJie:setTouchEnabled(bEnbale)
	Button_JinJie:setBright(bEnbale)
	Image_Coins:setVisible(bVisible)
	BitmapLabel_NeedMoney:setVisible(bVisible)
	
	Image_Check:setVisible(ImageCheckFlag)
	if ImageCheckFlag then g_CreateFadeInOutAction(Image_Check, 0.75, 100, 0.5) end 
	
	Button_JinJie:loadTextureNormal(getUIImg(normal))
	Button_JinJie:loadTexturePressed(getUIImg(pressed))
	Button_JinJie:loadTextureDisabled(getUIImg(disabled))
end

--卡魂重置和自动勾选的状态
function Game_CardDuJie:AutoPickCardOrResetStatus(nFlag)
	if (not self.rootWidget) or (not self.rootWidget:isExsit()) then return end
	local Image_CardMaterialListPNL = tolua.cast(self.rootWidget:getChildByName("Image_CardMaterialListPNL"),"ImageView")
	local Label_RealmPoints = tolua.cast(Image_CardMaterialListPNL:getChildByName("Label_RealmPoints"),"Label")
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_RealmPoints:setFontSize(18)
	end
	
	local Label_RealmPointsLB = tolua.cast(Image_CardMaterialListPNL:getChildByName("Label_RealmPointsLB"),"Label")
	Label_RealmPointsLB:setText(tostring(g_CardRealmData:getAddExp()))
	
	local Button_AutoPickCard = tolua.cast(Image_CardMaterialListPNL:getChildByName("Button_AutoPickCard"),"Button")
	local Button_Reset = tolua.cast(Image_CardMaterialListPNL:getChildByName("Button_Reset"),"Button")
	local Image_Check = tolua.cast(Button_AutoPickCard:getChildByName("Image_Check"), "ImageView")
	local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSpriteCheck, 4)
	Button_AutoPickCard:stopAllActions()

	local normal = "Btn_Common1"
	local pressed = "Btn_Common1_Press"
	local disabled = "Btn_Common1_Disabled"
	local flag = false
	if self.IsNeedDujie or g_Hero:getDescendSoulListCount() < 1 
		or g_CardRealmData:resetNextFullExp(self.nCardID,g_CardRealmData:getAddExp()) then
	else
		normal = "Btn_CommonYellow1"
		pressed = "Btn_CommonYellow1_Press"
		disabled = "Btn_CommonYellow1_Disabled"
		flag = true
	end
	
	Image_Check:setVisible(flag)
	
	Button_AutoPickCard:loadTextureNormal(getUIImg(normal))
	Button_AutoPickCard:loadTexturePressed(getUIImg(pressed))
	Button_AutoPickCard:loadTextureDisabled(getUIImg(disabled))
	g_SetButtonEnabled(Button_AutoPickCard, flag)
	g_SetButtonEnabled(Button_Reset, nFlag)
	if flag then g_CreateFadeInOutAction(Image_Check, 0.75, 100, 0.5) end
end

--[[
	自动勾选
]]
function Game_CardDuJie:registerOtherBtnEvent(nCardID)
	local Image_CardMaterialListPNL = self.rootWidget:getChildByName("Image_CardMaterialListPNL")
	local Button_Reset = Image_CardMaterialListPNL:getChildByName("Button_Reset")
	local Button_AutoPickCard = Image_CardMaterialListPNL:getChildByName("Button_AutoPickCard")
	local Image_Check = tolua.cast(Button_AutoPickCard:getChildByName("Image_Check"), "ImageView")
	
	local function onClickReset(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			g_CardRealmData:cardRealmInit()
			self:setCardRealmInfo()
			
		end
	end
	Button_Reset:setTouchEnabled(true)
	Button_Reset:addTouchEventListener(onClickReset)
	
	local function statefunc()
		self:registerListView()
		self:setCardRealmInfo()
		g_SetButtonEnabled(Button_AutoPickCard, false)
		g_SetButtonEnabled(Button_Reset, true)
		Image_Check:setVisible(false)
	end

	local tbCardInfo = g_Hero:getCardObjByServID(nCardID)
	if not tbCardInfo then return end
	
	--自动勾选
	local function onClickAuto(pSender, nTag)
		g_CardRealmData:cardRealmInit()
		self.openUpdateFlagSoulList = false
		for i = 1, g_Hero:getDescendSoulListCount() do
			local tbCardSoul = g_Hero:getDescendSoulByIndex(i)
			local CSV_CardSoul = tbCardSoul:getCsvBase()

			local serverId = tbCardSoul.nServerID
			local soulNum = tbCardSoul:getNum()
			local csvSoul = g_DataMgr:getCardSoulCsv(CSV_CardSoul.ID,CSV_CardSoul.StarLevel)
			for num = 1,soulNum do 
				-- and 加入条件是 魂魄等于要大于渡劫等级 减少玩家损失
				-- 先注释掉
				-- if  serverId  > 0 and (csvSoul.Level + nNotSuggestLevelSpace) >= tbCardInfo:getRealmMainLev() then
				if  serverId  > 0 then 
					g_CardRealmData:setSelectSoul(serverId,num)
					g_CardRealmData:setSelectSoulStar(serverId,CSV_CardSoul.StarLevel)
					g_CardRealmData:setSelectSoulID(serverId,CSV_CardSoul.ID)
					g_CardRealmData:setAddExp(CSV_CardSoul.AddRealmPoints)
					
					if g_CardRealmData:resetNextFullExp(self.nCardID,g_CardRealmData:getAddExp()) 
						or GetTableLen(g_CardRealmData:getSelectSoul()) == macro_pb.MAX_UPGRADE_REALM_GOD_NUM then 
						statefunc()
						return 
					end
			
				end
			end
			
			-- 先注释掉
			-- if GetTableLen(g_CardRealmData:getSelectSoul()) <= 0 then 
				-- g_ShowSysTips({text = _T("剩下的元神等级过低,请手动勾选")})
				-- return 
			-- end
			
			if i >= g_Hero:getDescendSoulListCount() then 
				statefunc()
				return 
			end
		end
	end
	g_SetBtnWithGuideCheck(Button_AutoPickCard, 1, onClickAuto, true, nil, nil, true)
end

function Game_CardDuJie:soulStarLevelFlat(tbCardInfo,func)
	for key ,value in pairs(g_CardRealmData:getSelectSoul()) do  
		local csvSoul = g_DataMgr:getCardSoulCsv(g_CardRealmData:getSelectSoulID(key),g_CardRealmData:getSelectSoulStar(key))
		local lv = csvSoul.Level
		if lv + nNotSuggestLevelSpace < tbCardInfo:getRealmMainLev() then 
			g_ClientMsgTips:showConfirm( _T("您勾选的一些元神等级过低会消耗更多的铜钱，是否继续？"), function() 
				if func then 
					func()
				end
			end)
			return true
		end
	end
	return false
end

function Game_CardDuJie:registerBtnJinJie()
	local Image_PropInfoPNL = tolua.cast(self.rootWidget:getChildByName("Image_PropInfoPNL"),"ImageView")
	local Button_JinJie = tolua.cast(Image_PropInfoPNL:getChildByName("Button_JinJie"),"Button")
	
	local function onClickJinJie(pSender, nTag)
		if self.bShowAnimation then return end
		local tbCardInfo = g_Hero:getCardObjByServID(self.nCardID)
		if not tbCardInfo then return end

		if self.IsNeedDujie then
			local needLevel = tbCardInfo:getCardRealmLevelCsvNextLev().NeedLevel
			if tbCardInfo:getLevel() < needLevel then
				g_ClientMsgTips:showMsgConfirm( string.format( _T("伙伴需要达到%s级才有能力渡劫"), tbCardInfo:getCardRealmLevelCsvNextLev().NeedLevel) )
				return
			end
			g_WndMgr:showWnd("Game_DuJieSelectHelper",self.nCardID)
		else
			if GetTableLen( g_CardRealmData:getSelectSoul()) < 1 then
				local nMaterialCount = g_Hero:getDescendSoulListCount()
				if nMaterialCount < 1 then
					g_ClientMsgTips:showMsgConfirm(_T("修炼当前境界所需的元神数量不足。"))
				else
					g_ClientMsgTips:showMsgConfirm( _T("请先勾选境界修炼所需吞噬的元神！"))
				end
			else
			
				local function requestFunc()
					--先判断是否铜钱足够再 请求
					if g_CheckMoneyConfirm(self.nNeedMoney) then 
						g_CardRealmData:requestCardReleam(self.nCardID, g_CardRealmData:getSelectSoul())
					end
				end
				if not self:soulStarLevelFlat(tbCardInfo,requestFunc) then 
					requestFunc()
				end
			end
		end
	end

	g_SetBtnWithGuideCheck(Button_JinJie, 1, onClickJinJie, true, nil, nil, true)
end

function Game_CardDuJie:registerPageView()
	--增加page view效果
	local function setCardImgInfo(Panel_CardPage, nIndex)
		local nCardID = g_Hero:GetCardIDByIndexPV(nIndex)
		if nCardID == nil then return end

		local tbCard = g_Hero:getCardObjByServID(nCardID)
		if tbCard == nil then return end

		local CSV_CardBase = tbCard:getCsvBase()
		if CSV_CardBase == nil then return end
		if Panel_CardPage and Panel_CardPage:isExsit() then
			local Panel_Card = tolua.cast(Panel_CardPage:getChildByName("Panel_Card"), "Layout")
			if Panel_Card and Panel_Card:isExsit() then 
				local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"), "ImageView")
				local CCNode_Skeleton = g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, 1)
				Image_Card:removeAllNodes()
				Image_Card:loadTexture(getUIImg("Blank"))
				Image_Card:setPositionXY(CSV_CardBase.Pos_X*Panel_Card:getScale()/0.6, CSV_CardBase.Pos_Y*Panel_Card:getScale()/0.6)
				Image_Card:addNode(CCNode_Skeleton)
				g_runSpineAnimation(CCNode_Skeleton, "idle", true)
			end
		end
	end

	local function turningFunction(Panel_CardPage, nIndex)
		g_CurrentPageViewCardIndex = nIndex
		self.nCardID = g_Hero:GetCardIDByIndexPV(self.LuaPageView_Card:getCurPageIndex())
		g_CardRealmData:cardRealmInit()
		self:setCardRealmInfo()
		
	end
	
	if (not self.rootWidget) or (not self.rootWidget:isExsit()) then return end
	local Image_CardInfoPNL = tolua.cast(self.rootWidget:getChildByName("Image_CardInfoPNL"),"ImageView")
	
	local Button_ForwardPage = tolua.cast(Image_CardInfoPNL:getChildByName("Button_ForwardPage"),"Button")
	local Button_NextPage = tolua.cast(Image_CardInfoPNL:getChildByName("Button_NextPage"),"Button")
	
	local LuaPageView_Card = Class_LuaPageView.new()
	LuaPageView_Card:registerUpdateFunction(setCardImgInfo)
	LuaPageView_Card:registerClickEvent(turningFunction)
	
	local PageView_Card = tolua.cast(Image_CardInfoPNL:getChildByName("PageView_Card"),"PageView")
	PageView_Card:setBounceEnabled(true)
	PageView_Card:setClippingEnabled(true)
	
	local Panel_CardPage = tolua.cast(PageView_Card:getChildByName("Panel_CardPage"),"Layout")
	
	LuaPageView_Card:setModel(Panel_CardPage, Button_ForwardPage, Button_NextPage, 0.5, 0.5)
	LuaPageView_Card:setPageView(PageView_Card)

	self.LuaPageView_Card = LuaPageView_Card
end

function Game_CardDuJie:registerListView()
	--元神列表
	local Image_CardMaterialListPNL = self.rootWidget:getChildByName("Image_CardMaterialListPNL")
	local ListView_SoulList = tolua.cast(Image_CardMaterialListPNL:getChildByName("ListView_SoulList"),"ListViewEx")

	local function onUpdateSoulListView(Panel_SoulListItem, nIndex)
		local tbCardSoul = g_Hero:getDescendSoulByIndex(nIndex)
		if tbCardSoul == nil or next(tbCardSoul) == nil then 
			cclog("卡魂数据为空"..nIndex) 
			return 
		end
		if tbCardSoul.nServerID <= 0 then 
			cclog("元神ID 有为零的")
			return
		end
		
		local CSV_CardSoul = tbCardSoul:getCsvBase()
		local soulNum = tbCardSoul:getNum()
		
		local Button_SoulListItem = Panel_SoulListItem:getChildByName("Button_SoulListItem")
		
		local LabelAtlas_Profession= tolua.cast(Button_SoulListItem:getChildByName("AtlasLabel_Profession"),"LabelAtlas")
		LabelAtlas_Profession:setValue(CSV_CardSoul.Profession)
		
		local Image_SoulIcon = tolua.cast(Button_SoulListItem:getChildByName("Image_SoulIcon"),"ImageView")
		Image_SoulIcon:loadTexture(getFrameBackGround(CSV_CardSoul.StarLevel))
		
		local Image_Icon = tolua.cast(Image_SoulIcon:getChildByName("Image_Icon"),"ImageView")
		Image_Icon:loadTexture(getIconImg(CSV_CardSoul.SpineAnimation))
		
		local Image_Frame = tolua.cast(Image_SoulIcon:getChildByName("Image_Frame"),"ImageView")
		Image_Frame:loadTexture(getIconFrame(CSV_CardSoul.StarLevel))
		
		local Image_Cover = tolua.cast(Image_SoulIcon:getChildByName("Image_Cover"),"ImageView")
		Image_Cover:loadTexture(getFrameCoverSoul(CSV_CardSoul.StarLevel))
		
		local Image_SoulType = tolua.cast(Image_SoulIcon:getChildByName("Image_SoulType"), "ImageView")
		if CSV_CardSoul.Class < 5 then
			Image_SoulType:loadTexture(getUIImg("Image_SoulTag_"..CSV_CardSoul.StarLevel.."_"..CSV_CardSoul.FatherLevel))
		else
			Image_SoulType:loadTexture(getEctypeIconResource("FrameEctypeNormalChar", CSV_CardSoul.StarLevel))
		end
		
		--拥有的数量
		local Label_HaveNum = tolua.cast(Image_SoulIcon:getChildByName("Label_HaveNum"),"Label")
		Label_HaveNum:setText(soulNum)
		
		local Label_Name = tolua.cast(Button_SoulListItem:getChildByName("Label_Name"),"Label")
		Label_Name:setText(CSV_CardSoul.Name.." ".._T("Lv.")..CSV_CardSoul.Level)
		g_SetWidgetColorBySLev(Label_Name, CSV_CardSoul.StarLevel)

		if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
			Label_Name:setFontSize(16)
		end
		
		local Label_AddExp = tolua.cast(Button_SoulListItem:getChildByName("Label_AddExp"),"Label")
		Label_AddExp:setText(string.format( _T("境界经验 +%d"),CSV_CardSoul.AddRealmPoints) )
		
		--选择那个元神多少个元神
		self:soulHandle(Button_SoulListItem,tbCardSoul,soulNum)
		Button_SoulListItem:setTouchEnabled(false)
	end
	
	local function onAdjustSoulListView(Panel_SoulListItem, nIndex)
		g_ListView_SoulList_Index = nIndex
	end
	
	local Panel_SoulListItem = ListView_SoulList:getChildByName("Panel_SoulListItem")
	self.LuaListView_SoulList = registerListViewEvent(ListView_SoulList, Panel_SoulListItem, onUpdateSoulListView, 0, onAdjustSoulListView)
	
	local imgScrollSlider = ListView_SoulList:getScrollSlider()
	local x = imgScrollSlider:getPositionX()
	imgScrollSlider = imgScrollSlider:setPositionX(x+4)
	
end

local function setBtnEnabledByBright(btn,flag)
	btn:setTouchEnabled(flag)
	btn:setBright(flag)
end

--[[
	增加或者是减少要消耗的元神
	@param Button_SoulListItem 模板对象
	@param tbCardSoul 元神数据
	@param flag 如果自动勾选了 为false 把增加，减少按钮禁止
]]
function Game_CardDuJie:soulHandle(Button_SoulListItem,tbCardSoul,soulNumAll)
	if not tbCardSoul then return end 
	local CSV_CardSoul = tbCardSoul:getCsvBase()
	
	local nServerID = tbCardSoul.nServerID 
	local soulNum = tbCardSoul:getNum() or 0
	local selectNum = 0
	if g_CardRealmData:getSelectSoul(nServerID) then selectNum = g_CardRealmData:getSelectSoul(nServerID) end
	
	local Button_Minus = tolua.cast(Button_SoulListItem:getChildByName("Button_Minus"),"Button")
	local Button_Add = tolua.cast(Button_SoulListItem:getChildByName("Button_Add"),"Button")

	local Label_AddNum = tolua.cast(Button_SoulListItem:getChildByName("Label_AddNum"),"Label")
	Label_AddNum:setText(selectNum)
	Label_AddNum:setColor(g_getColor(ccs.COLOR.WHITE))
	local minusFlag = false 	--减号按钮是否要灰化和禁用
	local addFlag = true 	--加号按钮是否要灰化和禁用
	if selectNum > 0 or selectNum == soulNum then  
		Label_AddNum:setColor(g_getColor(ccs.COLOR.LIME_GREEN))
		minusFlag = true
		addFlag = true
	end
	if g_CardRealmData:resetNextFullExp(self.nCardID,g_CardRealmData:getAddExp()) then  
		addFlag = false
	end
	if g_CardRealmData:getSelectSoul(nServerID)~= nil then
		if g_CardRealmData:getSelectSoul(nServerID) >= soulNumAll then
			addFlag = false
		end
	end
	
	setBtnEnabledByBright(Button_Minus,minusFlag)
	setBtnEnabledByBright(Button_Add,addFlag)
	local flag = true --是否要刷新元神列表 和是否要显示元神列表
	local function onClick(pSender, eventType)
        if eventType == ccs.TouchEventType.ended then
			if nServerID <= 0 then  cclog("元神 Serverid出现为零了") return  end
			local Button_SoulListItem = pSender:getParent()
			if not Button_SoulListItem then return end
			local Label_AddNum = tolua.cast(Button_SoulListItem:getChildByName("Label_AddNum"),"Label")
			local Button_Minus = tolua.cast(Button_SoulListItem:getChildByName("Button_Minus"),"Button")
			local Button_Add = tolua.cast(Button_SoulListItem:getChildByName("Button_Add"),"Button")
			local nTag = pSender:getTag()
			if nTag == HANDLE_TYPE.T_MINUMS then 
			
				if selectNum > 0 then 
					selectNum = selectNum - 1
					g_CardRealmData:setMinusExp(CSV_CardSoul.AddRealmPoints)
				end
				if selectNum == 0 then 
					Label_AddNum:setColor(g_getColor(ccs.COLOR.WHITE))
					setBtnEnabledByBright(Button_Add,true)
					setBtnEnabledByBright(Button_Minus,false)
				end
				if not g_CardRealmData:resetNextFullExp(self.nCardID, g_CardRealmData:getAddExp())  then 
					if not self.openUpdateFlagSoulList then 
						self.openUpdateFlagSoulList = true
						flag =false
					end
				end
			elseif nTag == HANDLE_TYPE.T_ADD then 
				if selectNum ~= soulNum then  
					selectNum = selectNum + 1
					Label_AddNum:setColor(g_getColor(ccs.COLOR.LIME_GREEN))
					g_CardRealmData:setAddExp(CSV_CardSoul.AddRealmPoints)
					self.openUpdateFlagSoulList = false
				end
				setBtnEnabledByBright(Button_Minus,true)
				flag = true
			end
			
			Label_AddNum:setText(selectNum)
			
			if nServerID > 0 then 
				--选择了多少个元神
				g_CardRealmData:setSelectSoul(nServerID,selectNum)
				g_CardRealmData:setSelectSoulStar(nServerID,CSV_CardSoul.StarLevel)
				g_CardRealmData:setSelectSoulID(nServerID,CSV_CardSoul.ID)
			end
			
			if  g_CardRealmData:getSelectSoul(nServerID) == 0 then 
				g_CardRealmData:setSelectSoul(nServerID,nil)
				g_CardRealmData:setSelectSoulStar(nServerID,nil)
				g_CardRealmData:setSelectSoulID(nServerID,nil)
			end
			
			if selectNum == soulNum then  
				flag = false
			end
			
			self:setCardRealmInfo(flag)

        end
    end
	
	Button_Minus:addTouchEventListener(onClick)	
	Button_Minus:setTag(HANDLE_TYPE.T_MINUMS)

	Button_Add:addTouchEventListener(onClick)
	Button_Add:setTag(HANDLE_TYPE.T_ADD)
	
end

function Game_CardDuJie:setSoulListItems(flag)
	if g_CardRealmData:resetNextFullExp(self.nCardID,g_CardRealmData:getAddExp()) or not flag then
		g_ListView_SoulList_Index = g_ListView_SoulList_Index or 1
		self.LuaListView_SoulList:updateItems(g_Hero:getDescendSoulListCount(), g_ListView_SoulList_Index)
	end
end

