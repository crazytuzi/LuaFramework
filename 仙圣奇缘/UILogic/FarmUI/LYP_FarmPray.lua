--------------------------------------------------------------------------------------
-- 文件名:	Game_FarmPray.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	yupingli
-- 日  期:	2014-11-21 19:37
-- 版  本:	1.0
-- 描  述:	土地公上香
-- 应  用:   
---------------------------------------------------------------------------------------
Game_FarmPray = class("Game_FarmPray")
Game_FarmPray.__index = Game_FarmPray


local Image_God = nil
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

function Game_FarmPray:setCoCosAnimation(widget)
	local armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("Incense", tbBattleStartFrameCallBack, nil, 2)
	widget:addNode(armature)
    userAnimation:playWithIndex(0)  
end

function Game_FarmPray:setIncenseInfo(widget, nIndex)

	local Image_PrayPNL = tolua.cast(widget:getChildByName("Image_PrayPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_PrayPNL:getChildByName("Image_ContentPNL"),"ImageView")
	
    local Image_PrayOption = Image_ContentPNL:getChildByName("Image_PrayOption"..nIndex)
	local Button_Pray = tolua.cast(Image_PrayOption:getChildByName("Button_Pray"), "Button")
	 
	local function onClickPrayOption(pSender, nTag)
		if g_Hero:GetFirstOpState(macro_pb.FirstOpType_FarmIncense) then --第一次上香是免费的，直接发送请求不需要判断
			self:onClickPrayOption(pSender, nTag)
		else
			local tbCurData = self.csvIncense[nTag]
			if i == 1 then
			  if g_Hero:getKnowledge() >= tbCurData.CostKnowledge then 
				g_ClientMsgTips:showMsgConfirm(_T("阅历不足，无法祭拜土地公了"))
				return 
			  end
			else
				local txt = string.format(_T("祭拜土地公需要%d元宝, 您的元宝不足是否前往充值"),tbCurData.CostCoupons)
				if not g_CheckYuanBaoConfirm(tbCurData.CostCoupons, txt) then
					return
				end
			end   
			self:onClickPrayOption(pSender, nTag)
		end
	end

	g_SetBtnWithGuideCheck(Button_Pray, nIndex, onClickPrayOption, true)

    local tbCurData = self.csvIncense[nIndex]
    if not tbCurData then return  end
    self.tbName = self.tbName or {}
	
    local Label_Name = tolua.cast(Image_PrayOption:getChildByName("Label_Name"), "Label")
    Label_Name:setText(tbCurData.Desc)
    self.tbName[nIndex] = tbCurData.Desc
	
	local Image_Aura = tolua.cast(Image_PrayOption:getChildByName("Image_Aura"),"ImageView")
    local Label_Aura = tolua.cast(Image_Aura:getChildByName("Label_Aura"), "Label")
    Label_Aura:setText(string.format(_T("土地灵气+%d"), tbCurData.Aura))
	
	local Image_Prestige = tolua.cast(Image_PrayOption:getChildByName("Image_Prestige"),"ImageView")
    local Label_Prestige = tolua.cast(Image_Prestige:getChildByName("Label_Prestige"), "Label")
    Label_Prestige:setText(string.format(_T("声望+%d"), tbCurData.Prestige))
	
	local Image_NeedMoney = tolua.cast(Image_PrayOption:getChildByName("Image_NeedMoney"),"ImageView")
    local Label_NeedValue = tolua.cast(Image_NeedMoney:getChildByName("Label_NeedValue"), "Label")
    if nIndex == 1 then
        Label_NeedValue:setText(string.format(_T("需消耗%d点阅历值"), tbCurData.CostKnowledge))
    else
        Label_NeedValue:setText(string.format(_T("需消耗%d个元宝"), tbCurData.CostCoupons))
    end
	--需要修改
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		-- Label_PresidentName:setPositionX(Label_PresidentNameLB:getSize().width)
		local x = -90
		local size = 17
		Label_Name:setPositionX(-34)
		Label_Name:setFontSize(21)
		Label_Aura:setPositionX(x)
		Label_Aura:setFontSize(size)
		Label_Prestige:setPositionX(x)
		Label_Prestige:setFontSize(size)
		Label_NeedValue:setPositionX(x)
		Label_NeedValue:setFontSize(size)
	end
	
    g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_FARM_INCENSELOG_NOTIFY, handler(self, self.logRespone) )
    g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_FARM_INCENSE_RESPONSE, handler(self, self.incenseRespone) )

	
	
    
end

function Game_FarmPray:logRespone(tbMsg)
    local msg = zone_pb.IncenseLogNotify()
	msg:ParseFromString(tbMsg.buffer)
    cclog(tostring(msg))

    for i =1, #msg.log_list do
		local tbCurLog = msg.log_list[i]
		local tbData = {}
		tbData.Time = tbCurLog.Time
		tbData.Name = tbCurLog.Name
		tbData.Type = tbCurLog.Type
		self.tbIncenseLog[i] = tbData
	end

	local function sortLog(one, two)
		return one.Time > two.Time
	end
	table.sort(self.tbIncenseLog, sortLog)
	
	if g_WndMgr:getWnd("Game_FarmPray") and g_WndMgr:isVisible("Game_FarmPray") then
		g_WndMgr:getWnd("Game_FarmPray"):openWnd()
	else
		g_WndMgr:showWnd("Game_FarmPray", true)
	end
end

function Game_FarmPray:incenseRespone(tbMsg)
    local msg = zone_pb.IncenseResponse()
	msg:ParseFromString(tbMsg.buffer)
    cclog(tostring(msg))
    
	local logs = msg.log --当次的log返回
	local t = {}
	t.Time = logs.Time
	t.Name = logs.Name
	t.Type = logs.Type
	self.tbIncenseLog[#self.tbIncenseLog + 1] = t

	local function sortLog(one, two)
		return one.Time > two.Time
	end
	table.sort(self.tbIncenseLog, sortLog)
	
    g_Hero:setPrestige(msg.updated_prestige)
    g_Hero:setKnowledge(msg.updated_knowledge)

	local farm = g_FarmData:getFarmRefresh()
	
    local incense_aura = msg.updated_aura - farm.field_exp
    farm.field_exp = msg.updated_aura
    farm.incense_times = msg.incense_times

	g_ShowSysTips({text = string.format(_T("上香成功，土地公增加了%d点灵气"), incense_aura) })
	
	--上香成功 付费点
	local yuanBao = g_Hero:getYuanBao() - msg.updated_coupons
	if yuanBao > 0 then
		local itemType = nil
		if msg.incense_type == 2 then 
			itemType = TDPurchase_Type.TDP_WorshipStorax 
		elseif msg.incense_type == 3 then 
			itemType = TDPurchase_Type.TDP_WorshipSkyTimber 
		end
		gTalkingData:onPurchase(itemType, 1, yuanBao)
	end

	g_Hero:setYuanBao(msg.updated_coupons)
	
	self:initView()
end
	-- 时间格式化规则：
	 -- 时间≤60分钟时，显示的时间为“分钟”
	-- 60分钟＜时间＜24小时，显示的时间转换成“小时”
	-- 时间≥24小时，显示的时间转换成“天”
function Game_FarmPray:updateListViewFunc(widget, nIndex)
    local Label_Time = tolua.cast(widget:getChildByName("Label_Time"),"Label")
    local tbCurTime = g_GetServerTime()
    local tbLog = self.tbIncenseLog[nIndex]
	
    local nTime = tbCurTime - tbLog.Time
	
    Label_Time:setText(getPrayTime(nTime))
    local Label_Name = tolua.cast(widget:getChildByName("Label_Name"),"Label")
    Label_Name:setText(tbLog.Name)

    local Label_ShangLe = widget:getChildByName("Label_ShangLe")
    local Label_Type = tolua.cast(widget:getChildByName("Label_Type"),"Label")
    Label_Type:setText(string.format("[%s]",self.tbName[tbLog.Type]) )
    local tbColor = {ccs.COLOR.WHITE, ccs.COLOR.LIGHT_SKY_BLUE, ccs.COLOR.GOLD}
    g_setTextColor(Label_Type, tbColor[tbLog.Type])
    local Label_LingQi = widget:getChildByName("Label_LingQi")
    local Label_Value = tolua.cast(widget:getChildByName("Label_Value"),"Label")
    local tbIncense = self.csvIncense[tbLog.Type]
    Label_Value:setText(string.format("+%d", tbIncense.Aura ))

    g_AdjustWidgetsPosition({Label_Time,Label_Name,Label_ShangLe, Label_Type,Label_LingQi,Label_Value })
end

local function onClick_Image_God()
    g_WndMgr:showWnd("Game_TipTuDiGong", Enum_StatueType._TuDiGong)
end

function Game_FarmPray:initWnd()
	self.tbIncenseLog = {}
	self.csvIncense = g_DataMgr:getCsvConfig("ActivityFarmIncense")
	if not self.rootWidget then return end
	for i=1, 3 do
		self:setIncenseInfo(self.rootWidget, i)
	end

	local Image_PrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_PrayPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_PrayPNL:getChildByName("Image_ContentPNL"),"ImageView")
	
	local Image_LogPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_LogPNL"),"ImageView")

	-- local ListView_Log = tolua.cast(Image_LogPNL:getChildByName("ListView_Log"),"ListViewEx")
	-- local LuaListView_Log = Class_LuaListView:new()
	
	-- local model = ListView_Log:getChildByName("Panel_LogItem")
	-- LuaListView_Log:setModel(model)
	-- LuaListView_Log:setListView(ListView_Log)
	-- LuaListView_Log:setUpdateFunc( handler(self, self.updateListViewFunc))
	-- self.LuaListView_Log = LuaListView_Log
	
	-- local imgScrollSlider = ListView_Log:getScrollSlider()
	-- if not g_tbScrollSliderXY.ListView_Log_X then
		-- g_tbScrollSliderXY.ListView_Log_X = imgScrollSlider:getPositionX()
	-- end
	-- imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_Log_X + 13)

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
end

function Game_FarmPray:onClickPrayOption(pSender, nTag)
    local nDailyType = macro_pb.Incense_Times 
	local bTimesFull = g_Hero:IsDailyNoticeFull(nDailyType)
	if  bTimesFull then  return   end
	if not self.rootWidget then return end
	local Image_PrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_PrayPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_PrayPNL:getChildByName("Image_ContentPNL"),"ImageView")

	local Image_PrayOption = Image_ContentPNL:getChildByName("Image_PrayOption"..nTag)
    local Image_Icon = tolua.cast(Image_PrayOption:getChildByName("Image_Icon"), "Label")
	self:setCoCosAnimation(Image_Icon)
	
    local requestIncense = zone_pb.IncenseRequest()
    requestIncense.incense_type = nTag
    requestIncense.incense_logid = #self.tbIncenseLog
    
	g_MsgMgr:sendMsg(msgid_pb.MSGID_FARM_INCENSE_REQUEST, requestIncense)
end



function Game_FarmPray:checkData(bCheckMsg)
    if not bCheckMsg then
        local requestIncenseLog = zone_pb.IncenseLogRequest()
        requestIncenseLog.incense_logid = #self.tbIncenseLog
        g_MsgMgr:sendMsg(msgid_pb.MSGID_FARM_INCENSELOG_REQUEST, requestIncenseLog)
        return false
    end
    return true
end

function Game_FarmPray:updateButtonStatus()
	if not self.rootWidget then return end
	local Image_PrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_PrayPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_PrayPNL:getChildByName("Image_ContentPNL"),"ImageView")
	
    for i=1, 3 do
        local Image_PrayOption = Image_ContentPNL:getChildByName("Image_PrayOption"..i)
        local Button_Pray = Image_PrayOption:getChildByName("Button_Pray")
          
        local tbCurData = self.csvIncense[i]
		if g_Hero:GetFirstOpState(macro_pb.FirstOpType_BaXianIncense) then
			g_SetBtnEnable(Button_Pray, true)
		else
			if i == 1 then
				g_SetBtnEnable(Button_Pray, g_Hero:getKnowledge() >= tbCurData.CostKnowledge)
			else
				g_SetBtnEnable(Button_Pray, g_Hero:getCoins() >= tbCurData.CostCoupons)
			end
		end
		
		local nDailyType = macro_pb.Incense_Times 
		local bTimesFull = g_Hero:IsDailyNoticeFull(nDailyType)
		if bTimesFull then 
			Button_Pray:setBright(false)
		end
		
    end 
end


function Game_FarmPray:initView()
	if not self.rootWidget then return end
	
	local Image_PrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_PrayPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_PrayPNL:getChildByName("Image_ContentPNL"),"ImageView")
	
	local Image_LogPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_LogPNL"),"ImageView")

	local ListView_Log = tolua.cast(Image_LogPNL:getChildByName("ListView_Log"),"ListViewEx")
	local LuaListView_Log = Class_LuaListView:new()
	
	local model = ListView_Log:getChildByName("Panel_LogItem")
	LuaListView_Log:setModel(model)
	LuaListView_Log:setListView(ListView_Log)
	LuaListView_Log:setUpdateFunc( handler(self, self.updateListViewFunc))
	self.LuaListView_Log = LuaListView_Log
	
	local imgScrollSlider = ListView_Log:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_Log_X then
		g_tbScrollSliderXY.ListView_Log_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_Log_X + 13)

	self:updateButtonStatus()


    local nMax = #self.tbIncenseLog
    self.LuaListView_Log:updateItems(nMax)
	

	local Image_PrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_PrayPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_PrayPNL:getChildByName("Image_ContentPNL"),"ImageView")
	
    local tbFarm = g_FarmData:getFarmRefresh()
	local nLevel = g_DataMgr:getActivityFarmLevelByExp(tbFarm.field_exp)
	
	local Image_StatueExp = tolua.cast(Image_ContentPNL:getChildByName("Image_StatueExp"),"ImageView")
	local ProgressBar_StatueExp = tolua.cast(Image_StatueExp:getChildByName("ProgressBar_StatueExp"),"LoadingBar")
	 
	local Label_StatueExp = tolua.cast(Image_StatueExp:getChildByName("Label_StatueExp"),"Label")
	local Label_StatueLevel = tolua.cast(Image_StatueExp:getChildByName("Label_StatueLevel"),"Label")
	 local tbFarmConfig = g_DataMgr:getCsvConfigByOneKey("ActivityFarmLevel", nLevel)
	if tbFarmConfig then
        Label_StatueExp:setText(string.format("%d/%d", tbFarm.field_exp, tbFarmConfig.FarmExp))
		local bar = (tbFarm.field_exp / tbFarmConfig.FarmExp) * 100
		ProgressBar_StatueExp:setPercent(bar)
    else
        Label_StatueExp:setText(string.format("%d/%d", tbFarm.field_exp, tbFarm.field_exp))
		local bar = (tbFarm.field_exp / tbFarm.field_exp) * 100
		ProgressBar_StatueExp:setPercent(bar)
    end
	
	Label_StatueLevel:setText(string.format(_T("神像等级: %d级"),nLevel))
end

function Game_FarmPray:openWnd()
	self:initView()
end

function Game_FarmPray:closeWnd()

end

function Game_FarmPray:showWndOpenAnimation(funcWndOpenAniCall)
	if not self.rootWidget then return end
	local Image_PrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_PrayPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_PrayPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_FarmPray:showWndCloseAnimation(funcWndCloseAniCall)
	if not self.rootWidget then return end
	local Image_PrayPNL = tolua.cast(self.rootWidget:getChildByName("Image_PrayPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_PrayPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end