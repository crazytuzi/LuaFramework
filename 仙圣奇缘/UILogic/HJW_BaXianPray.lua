--------------------------------------------------------------------------------------
-- 文件名:	HJW_BaXianPray.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2015-8-6 
-- 版  本:	1.0
-- 描  述:	祭拜上香
-- 应  用:   
---------------------------------------------------------------------------------------
Game_BaXianPray = class("Game_BaXianPray")
Game_BaXianPray.__index = Game_BaXianPray

local Image_God =  nil

function Game_BaXianPray:updateListViewFunc(widget, nIndex)

    local Label_Time = tolua.cast(widget:getChildByName("Label_Time"),"Label")
    local tbCurTime = g_GetServerTime()
    local tbLog = g_BaXianPary:getBaXianLog()[nIndex]
    local nTime = tbCurTime - tbLog.Time
	
	-- echoj("??????????",tbLog)
	
    Label_Time:setText(getPrayTime(nTime))
    -- Label_Time:setText(string.format(_T("%d分钟前"),math.max(0,math.floor(nTime/60))))
    local Label_Name = tolua.cast(widget:getChildByName("Label_Name"),"Label")
    Label_Name:setText(tbLog.Name)

    local Label_ShangLe = widget:getChildByName("Label_ShangLe")
	
	local incense = g_BaXianPary:getActivityBaXianIncense(tbLog.Type)	

    local Label_Type = tolua.cast(widget:getChildByName("Label_Type"),"Label")	
    Label_Type:setText(string.format("[%s]",incense.Desc))
    local tbColor = {ccs.COLOR.WHITE, ccs.COLOR.LIGHT_SKY_BLUE, ccs.COLOR.GOLD}
    g_setTextColor(Label_Type, tbColor[tbLog.Type])
		
    local Label_LingQi = widget:getChildByName("Label_LingQi")
	
    local Label_Value = tolua.cast(widget:getChildByName("Label_Value"),"Label")
    local tbIncense = g_DataMgr:getCsvConfigByOneKey("ActivityFarmIncense", tbLog.Type)
    Label_Value:setText(string.format("+%d", tbIncense.Aura ))
	
    g_AdjustWidgetsPosition({Label_Time,Label_Name,Label_ShangLe, Label_Type,Label_LingQi,Label_Value})
	
end

function Game_BaXianPray:checkData(bCheckMsg)
    if not g_BaXianPary:getBaXianLog() then
		g_BaXianPary:msgidBaxianGodInfoRequest()	
        return false
    end
    return true
end

function Game_BaXianPray:initWnd()

end

local function onClick_Image_God()
    g_WndMgr:showWnd("Game_TipTuDiGong", Enum_StatueType._TaiShangLaoJun)
end

function Game_BaXianPray:openWnd()


	local Image_BaXianPrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_BaXianPrayPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_BaXianPrayPNL:getChildByName("Image_ContentPNL"), "ImageView")
	
	local Image_LogPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_LogPNL"),"ImageView")
	local ListView_Log = tolua.cast(Image_LogPNL:getChildByName("ListView_Log"),"ListViewEx")
	local LuaListView_Log = Class_LuaListView:new()
	local model = ListView_Log:getChildByName("Panel_LogItem")
	LuaListView_Log:setModel(model)
	LuaListView_Log:setListView(ListView_Log)
	LuaListView_Log:setUpdateFunc( handler(self, self.updateListViewFunc))
	self.LuaListView_Log = LuaListView_Log
	
	local imgScrollSlider = self.LuaListView_Log:getScrollSlider()
	if not g_tbScrollSliderXY.LuaListView_Log_X then
		g_tbScrollSliderXY.LuaListView_Log_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.LuaListView_Log_X + 13)

	
	for i=1,3 do
		self:setIncenseInfo(self.rootWidget, i)
	end
	
	
	local nMax = #g_BaXianPary:getBaXianLog()	
    self.LuaListView_Log:updateItems(nMax)

	local Image_BaXianPrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_BaXianPrayPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_BaXianPrayPNL:getChildByName("Image_ContentPNL"), "ImageView")
	
	local Image_SymbolBlueLight = tolua.cast(Image_ContentPNL:getChildByName("Image_SymbolBlueLight"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	
	local Image_SymbolOutside = tolua.cast(Image_ContentPNL:getChildByName("Image_SymbolOutside"), "ImageView")
	
	local Image_SymbolInside = tolua.cast(Image_ContentPNL:getChildByName("Image_SymbolInside"), "ImageView")
	
	local actionRotateTo_SymbolOutside = CCRotateBy:create(45, -360) 
	local actionForever_SymbolOutside = CCRepeatForever:create(actionRotateTo_SymbolOutside)
	Image_SymbolOutside:runAction(actionForever_SymbolOutside)
	
	local actionRotateTo_SymbolInside = CCRotateBy:create(45, 360) 
	local actionForever_SymbolInsidet = CCRepeatForever:create(actionRotateTo_SymbolInside)
	Image_SymbolInside:runAction(actionForever_SymbolInsidet)
	
	Image_God = tolua.cast(Image_ContentPNL:getChildByName("Image_God"), "ImageView")
    g_SetBtn(self.rootWidget, "Image_God", onClick_Image_God, true)
	
	self:updateButtonStatus()
	self:statueExp()
	
end

function Game_BaXianPray:closeWnd()
	-- g_BaXianPary:setOpen(true) 
end

function Game_BaXianPray:updateButtonStatus()
    local tbIncense = g_DataMgr:getCsvConfig("ActivityFarmIncense")
    
	local Image_BaXianPrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_BaXianPrayPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_BaXianPrayPNL:getChildByName("Image_ContentPNL"),"ImageView")
	
    for i=1, 3 do
        local Image_PrayOption = Image_ContentPNL:getChildByName("Image_PrayOption"..i)
        local Button_Pray = Image_PrayOption:getChildByName("Button_Pray")
          
        local tbCurData = tbIncense[i]
		
		if g_Hero:GetFirstOpState(macro_pb.FirstOpType_BaXianIncense) then
			g_SetBtnEnable(Button_Pray, true)
		else
			if i == 1 then
				g_SetBtnEnable(Button_Pray, g_Hero:getKnowledge() >= tbCurData.CostKnowledge)
			else
				g_SetBtnEnable(Button_Pray, g_Hero:getYuanBao() >= tbCurData.CostCoupons)
			end
		end
		local nDailyType = macro_pb.BaXianIncenstTimes 
		local bTimesFull = g_Hero:IsDailyNoticeFull(nDailyType)	
		if bTimesFull then 
			Button_Pray:setBright(false)	
		end
    end 
end


function Game_BaXianPray:setIncenseInfo(widget, nIndex)

	local Image_BaXianPrayPNL = tolua.cast(widget:getChildByName("Image_BaXianPrayPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_BaXianPrayPNL:getChildByName("Image_ContentPNL"),"ImageView")
	
    local Image_PrayOption = Image_ContentPNL:getChildByName("Image_PrayOption"..nIndex)
	local Button_Pray = tolua.cast(Image_PrayOption:getChildByName("Button_Pray"), "Button")
	
	local function onClickPray(pSender, nTag)
		if g_Hero:GetFirstOpState(macro_pb.FirstOpType_BaXianIncense) then --第一次上香是免费的，直接发送请求不需要判断
			self:onClickPrayOption(pSender, nTag)
		else
			local incenseTag = g_BaXianPary:getActivityBaXianIncense(nTag)
			if nIndex == 1 then
				if incenseTag.CostKnowledge > g_Hero:getKnowledge() then
					g_ShowSysTips({text = _T("阅历不够")})
					return
				end
			else
				local gold = incenseTag.CostCoupons
				if not g_CheckYuanBaoConfirm(gold,_T("上香需要花费")..gold.._T("元宝，您的元宝不够是否前往充值？")) then
					return
				end	
			end

			self:onClickPrayOption(pSender, nTag)
		end
	end
	g_SetBtnWithGuideCheck(Button_Pray, nIndex, onClickPray, true)

	local incense = g_BaXianPary:getActivityBaXianIncense(nIndex)	
    
	local Label_Name = tolua.cast(Image_PrayOption:getChildByName("Label_Name"), "Label")
    Label_Name:setText(incense.Desc)
	
	local nGodLevel = g_BaXianPary:getGodLevel()
	local CSV_ActivityBaXianLevel = g_DataMgr:getCsvConfigByOneKey("ActivityBaXianLevel", nGodLevel)
	local nIncenseOptionReward = CSV_ActivityBaXianLevel["IncenseOption"..nIndex.."_Reward"]
	local Image_Reward = tolua.cast(Image_PrayOption:getChildByName("Image_Reward"),"ImageView")
    local Label_Reward = tolua.cast(Image_Reward:getChildByName("Label_Reward"), "Label")
    Label_Reward:setText(string.format(_T("护送奖励+%d"), nIncenseOptionReward/100).."%")
	
	local Image_Aura = tolua.cast(Image_PrayOption:getChildByName("Image_Aura"),"ImageView")
    local Label_Aura = tolua.cast(Image_Aura:getChildByName("Label_Aura"), "Label")
    Label_Aura:setText(string.format(_T("神像灵气+%d"), incense.Aura))
	
	local Image_Prestige = tolua.cast(Image_PrayOption:getChildByName("Image_Prestige"),"ImageView")
    local Label_Prestige = tolua.cast(Image_Prestige:getChildByName("Label_Prestige"), "Label")
    Label_Prestige:setText(string.format(_T("声望+%d"), incense.Prestige))
	
	local Image_NeedMoney = tolua.cast(Image_PrayOption:getChildByName("Image_NeedMoney"),"ImageView")

    local Label_NeedValue = tolua.cast(Image_NeedMoney:getChildByName("Label_NeedValue"), "Label")
    if nIndex == 1 then
        Label_NeedValue:setText(string.format(_T("需消耗%d点阅历值"), incense.CostKnowledge))
    else
        Label_NeedValue:setText(string.format(_T("需消耗%d个元宝"), incense.CostCoupons))
    end
    
end

function Game_BaXianPray:onClickPrayOption(pSender, nTag)
    local nDailyType = macro_pb.BaXianIncenstTimes 
	local bTimesFull = g_Hero:IsDailyNoticeFull(nDailyType)

	local Image_BaXianPrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_BaXianPrayPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_BaXianPrayPNL:getChildByName("Image_ContentPNL"),"ImageView")
    if  bTimesFull then 
		g_ShowSysTips({text = _T("今天已经上香了")})
        return 
    end
	local Image_PrayOption = Image_ContentPNL:getChildByName("Image_PrayOption"..nTag)
    local Image_Icon = tolua.cast(Image_PrayOption:getChildByName("Image_Icon"), "Label")
	self:setCoCosAnimation(Image_Icon)

	g_BaXianPary:InsenceResponseFunc(function()  g_WndMgr:openWnd("Game_BaXianPray") end)
	g_BaXianPary:requestBaXianInsenceRequest(nTag)

end

function Game_BaXianPray:setCoCosAnimation(widget)

	local function ShowTuDiGongAni(armature, userAnimation)
		local function animationEndCall()
			if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationEnd", "IncenseStatue") then
				g_PlayerGuide:showCurrentGuideSequenceNode()
			end
		end
		local armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("IncenseStatue",nil, animationEndCall, 2)
		Image_God:addNode(armature)
		userAnimation:playWithIndex(0)  
	end
		
	local tbBattleStartFrameCallBack = {
		ShowTuDiGongAni = ShowTuDiGongAni,
	}
	
	local armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("Incense", tbBattleStartFrameCallBack, nil, 2)
	widget:addNode(armature)
    userAnimation:playWithIndex(0)  
	
end
--
function Game_BaXianPray:statueExp()
	local Image_BaXianPrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_BaXianPrayPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_BaXianPrayPNL:getChildByName("Image_ContentPNL"),"ImageView")
	local Image_StatueExp = tolua.cast(Image_ContentPNL:getChildByName("Image_StatueExp"),"ImageView")

	local godLevel = g_BaXianPary:getGodLevel()
	local maxLevel = g_BaXianPary:maxBaXianLevel()
	
	local level = godLevel + 1
	if level > maxLevel then 
		level = maxLevel
	end
	local activityLevelExp = g_BaXianPary:getActivityBaXianLevel()
	local nextExp = activityLevelExp[level].FarmExp
	local curExp = g_BaXianPary:getGodExp()
	
	local percent = (curExp / nextExp) * 100
	local ProgressBar_StatueExp = tolua.cast(Image_StatueExp:getChildByName("ProgressBar_StatueExp"),"LoadingBar")
	ProgressBar_StatueExp:setPercent(percent)
	
	if godLevel ==  maxLevel then  curExp = nextExp end
	
	local Label_StatueExp = tolua.cast(Image_StatueExp:getChildByName("Label_StatueExp"),"Label")
	Label_StatueExp:setText(curExp.."/"..nextExp)
	local Label_StatueLevel = tolua.cast(Image_StatueExp:getChildByName("Label_StatueLevel"),"Label")
	Label_StatueLevel:setText(_T("神像等级:")..godLevel.._T("级"))
	
end

function Game_BaXianPray:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_BaXianPrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_BaXianPrayPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_BaXianPrayPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_BaXianPray:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_BaXianPrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_BaXianPrayPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_BaXianPrayPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end

function Game_BaXianPray:ModifyWnd_viet_VIET()
    local function TmpModfy(wnd_P)
        local wnd_C = tolua.cast(wnd_P:getChildAllByName("Label_Name"), "Label")
        wnd_C:setPositionX(-40) 
        wnd_C = tolua.cast(wnd_P:getChildAllByName("Label_Reward"), "Label")
        wnd_C:setPositionX(-95) wnd_C:setFontSize(14)
        wnd_C = tolua.cast(wnd_P:getChildAllByName("Label_Aura"), "Label")
        wnd_C:setPositionX(-95) wnd_C:setFontSize(14)
        wnd_C = tolua.cast(wnd_P:getChildAllByName("Label_Prestige"), "Label")
        wnd_C:setPositionX(-95) wnd_C:setFontSize(14)
        wnd_C = tolua.cast(wnd_P:getChildAllByName("Label_NeedValue"), "Label")
        wnd_C:setPositionX(-95) wnd_C:setFontSize(14)
    end

    local Image_BaXianPrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_BaXianPrayPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_BaXianPrayPNL:getChildByName("Image_ContentPNL"),"ImageView")

    local wnd_P = tolua.cast(Image_ContentPNL:getChildByName("Image_PrayOption1"), "ImageView")
    TmpModfy(wnd_P)
    wnd_P = tolua.cast(Image_ContentPNL:getChildAllByName("Image_PrayOption2"), "ImageView")
    TmpModfy(wnd_P)
    wnd_P = tolua.cast(Image_ContentPNL:getChildAllByName("Image_PrayOption3"), "ImageView")
    TmpModfy(wnd_P)
end