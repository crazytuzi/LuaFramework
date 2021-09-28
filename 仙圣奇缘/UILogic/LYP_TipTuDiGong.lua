--------------------------------------------------------------------------------------
-- 文件名:	Game_TipTuDiGong.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	yupingli
-- 日  期:	2015-1-6 19:37
-- 版  本:	1.0
-- 描  述:	土地公tip界面
-- 应  用:   
---------------------------------------------------------------------------------------
Game_TipTuDiGong = class("Game_TipTuDiGong")
Game_TipTuDiGong.__index = Game_TipTuDiGong

Enum_StatueType = {
	_TuDiGong = 1,
	_TaiShangLaoJun = 2,
}

function Game_TipTuDiGong:initWnd(widget)
end 


--显示主界面的伙伴详细介绍界面
function Game_TipTuDiGong:openWnd(types)
	local types = types or Enum_StatueType._TuDiGong 
	
	local Image_TipTuDiGongPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipTuDiGongPNL"), "ImageView")
	--头像
	local Image_TuDiGongBase = tolua.cast(Image_TipTuDiGongPNL:getChildByName("Image_TuDiGongBase"), "ImageView")
	local Image_TuDiGong = tolua.cast(Image_TuDiGongBase:getChildByName("Image_TuDiGong"), "ImageView")
	--祭拜名称
	local Label_Name = tolua.cast(Image_TipTuDiGongPNL:getChildByName("Label_Name"), "Label")
	--等级
	local Label_LevelLB = tolua.cast(Image_TipTuDiGongPNL:getChildByName("Label_LevelLB"), "Label")
	local Label_Level = tolua.cast(Label_LevelLB:getChildByName("Label_Level"), "Label")
	
	--灵气
	local Label_ExpLB = tolua.cast(Image_TipTuDiGongPNL:getChildByName("Label_ExpLB"), "Label")
	local Label_Exp = tolua.cast(Label_ExpLB:getChildByName("Label_Exp"), "Label")
	local Label_ExpMax = tolua.cast(Label_ExpLB:getChildByName("Label_ExpMax"), "Label")
	
	--冷却时间
	local Label_CoolDownLB = tolua.cast(Image_TipTuDiGongPNL:getChildByName("Label_CoolDownLB"), "Label")
	local Label_CoolDown = tolua.cast(Image_TipTuDiGongPNL:getChildByName("Label_CoolDown"), "Label")
	
	--冷却时间下一等级
	local Label_CoolDownNextLB = tolua.cast(Image_TipTuDiGongPNL:getChildByName("Label_CoolDownNextLB"), "Label")
	local Label_CoolDownNext = tolua.cast(Image_TipTuDiGongPNL:getChildByName("Label_CoolDownNext"), "Label")
	
	--增益描述
	local Label_IncreasePercentLB = tolua.cast(Image_TipTuDiGongPNL:getChildByName("Label_IncreasePercentLB"), "Label")
	local Label_IncreasePercent = tolua.cast(Image_TipTuDiGongPNL:getChildByName("Label_IncreasePercent"), "Label")
	
	--增益描述
	local Label_IncreasePercentNextLB = tolua.cast(Image_TipTuDiGongPNL:getChildByName("Label_IncreasePercentNextLB"), "Label")
	local Label_IncreasePercentNext = tolua.cast(Image_TipTuDiGongPNL:getChildByName("Label_IncreasePercentNext"), "Label")
	
	if types == Enum_StatueType._TuDiGong then 
		Image_TuDiGong:loadTexture(getFarmImg("PrayGod"))
		Label_Name:setText(_T("土地公"))
		local tbFarm = g_FarmData:getFarmRefresh()
		local nLevel = g_DataMgr:getActivityFarmLevelByExp(tbFarm.field_exp)
		Label_Level:setText(tostring(nLevel).._T("级"))
		
		local CSV_ActivityFarmLevel = g_DataMgr:getActivityFarmLevelCsv(nLevel)
		local CSV_ActivityFarmLevelNext = g_DataMgr:getActivityFarmLevelCsv(nLevel+1)
		if CSV_ActivityFarmLevel then
			Label_Exp:setText(tostring(tbFarm.field_exp))
			Label_ExpMax:setText("/"..tostring(CSV_ActivityFarmLevel.FarmExp))
		else
			Label_Exp:setText(tostring(tbFarm.field_exp))
			Label_ExpMax:setText("/"..tostring(tbFarm.field_exp))
		end
		Label_Exp:setPositionX(Label_ExpLB:getSize().width)
		g_AdjustWidgetsPosition({Label_Exp, Label_ExpMax})
		Label_CoolDownLB:setText(_T("药田冷却时间:").." ")
		Label_CoolDown:setText(tostring(CSV_ActivityFarmLevel.CoolDown).._T("分钟"))
		Label_IncreasePercentLB:setText(_T("土地祝福提高作物产出:").." ")
		Label_IncreasePercent:setText((CSV_ActivityFarmLevel.IncreasePercent/100).."%")
		g_AdjustWidgetsPosition({Label_CoolDownLB, Label_CoolDown})
		g_AdjustWidgetsPosition({Label_IncreasePercentLB, Label_IncreasePercent})
		
		Label_CoolDownNextLB:setText(_T("药田冷却时间:").." ")
		Label_CoolDownNext:setText(tostring(CSV_ActivityFarmLevelNext.CoolDown).._T("分钟"))
		Label_IncreasePercentNextLB:setText(_T("土地祝福提高作物产出:").." ")
		Label_IncreasePercentNext:setText((CSV_ActivityFarmLevelNext.IncreasePercent/100).."%")
		g_AdjustWidgetsPosition({Label_CoolDownNextLB, Label_CoolDownNext})
		g_AdjustWidgetsPosition({Label_IncreasePercentNextLB, Label_IncreasePercentNext})
	elseif types == Enum_StatueType._TaiShangLaoJun then
		Image_TuDiGong:loadTexture(getBaXianGuoHai("Image_God"))
		Label_Name:setText(_T("太上老君"))
		
		local nLevel = g_BaXianPary:getGodLevel()
		Label_Level:setText(tostring(nLevel).._T("级"))

		local maxLevel = g_BaXianPary:maxBaXianLevel()
		local nextLevel = nLevel + 1
		if nextLevel > maxLevel then  nextLevel = maxLevel end
		
		local CSV_ActivityBaXianLevel = g_DataMgr:getActivityBaXianLevelCsv(nLevel)
		local CSV_ActivityBaXianLevelNext = g_DataMgr:getActivityBaXianLevelCsv(nextLevel)
		
		local curExp = g_BaXianPary:getGodExp()
		
		local activityLevelExp = g_BaXianPary:getActivityBaXianLevel()
		local nextExp = activityLevelExp[nextLevel].FarmExp
		if nLevel ==  maxLevel then  curExp = nextExp end
		Label_Exp:setText(curExp)
		Label_ExpMax:setText("/"..nextExp)
		Label_Exp:setPositionX(Label_ExpLB:getSize().width)
		g_AdjustWidgetsPosition({Label_Exp, Label_ExpMax})
		
		Label_CoolDownLB:setText(_T("护送所需时间:").." ")
		Label_CoolDown:setText(CSV_ActivityBaXianLevel.IncenseOption1_ConvoyTime.._T("分钟").."、"..CSV_ActivityBaXianLevel.IncenseOption2_ConvoyTime.._T("分钟").."、"..CSV_ActivityBaXianLevel.IncenseOption3_ConvoyTime.._T("分钟"))
		Label_IncreasePercentLB:setText(_T("护送奖励增益:").." ")
		Label_IncreasePercent:setText((CSV_ActivityBaXianLevel.IncenseOption1_Reward/100).."%、"..(CSV_ActivityBaXianLevel.IncenseOption2_Reward/100).."%、"..(CSV_ActivityBaXianLevel.IncenseOption3_Reward/100).."%")
		g_AdjustWidgetsPosition({Label_CoolDownLB, Label_CoolDown})
		g_AdjustWidgetsPosition({Label_IncreasePercentLB, Label_IncreasePercent})
		
		Label_CoolDownNextLB:setText(_T("护送所需时间:").." ")
		Label_CoolDownNext:setText(0)
		Label_CoolDownNext:setText(CSV_ActivityBaXianLevelNext.IncenseOption1_ConvoyTime.._T("分钟").."、"..CSV_ActivityBaXianLevelNext.IncenseOption2_ConvoyTime.._T("分钟").."、"..CSV_ActivityBaXianLevelNext.IncenseOption3_ConvoyTime.._T("分钟"))
		Label_IncreasePercentNextLB:setText(_T("护送奖励增益:").." ")
		Label_IncreasePercentNext:setText((CSV_ActivityBaXianLevelNext.IncenseOption1_Reward/100).."%、"..(CSV_ActivityBaXianLevelNext.IncenseOption2_Reward/100).."%、"..(CSV_ActivityBaXianLevelNext.IncenseOption3_Reward/100).."%")
		g_AdjustWidgetsPosition({Label_CoolDownNextLB, Label_CoolDownNext})
		g_AdjustWidgetsPosition({Label_IncreasePercentNextLB, Label_IncreasePercentNext})
	end
	
end

function Game_TipTuDiGong:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipTuDiGongPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipTuDiGongPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipTuDiGongPNL, funcWndOpenAniCall, 1.05, 0.2)
end

function Game_TipTuDiGong:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipTuDiGongPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipTuDiGongPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipTuDiGongPNL, funcWndCloseAniCall, 1.05, 0.2)
end