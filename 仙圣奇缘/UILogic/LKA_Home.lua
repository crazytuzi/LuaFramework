---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 文件名:	LKA_Home.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2013-1-22 9:37
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------
--创建MainScene类继承CCScene
MainScene = class("MainScene", function() return CCScene:create() end)
MainScene.__index = MainScene
g_bShowFacebook =  false
local nEndPosX = -65
local nEndPosY = 5
g_tbHorizontalBtnPos = {}
g_tbVerticalBtnPos = {}

local tbBottomLeftButtonList = {}
local tbTopRightButtonList = {}

---主城系统飘字
function MainScene:showSystemBroadcast(strText)
    local Image_MainHomeUIPNL = tolua.cast(self.rootLayout:getChildByName("Image_MainHomeUIPNL"),"ImageView")
    local Panel_SystemBrocast = tolua.cast(Image_MainHomeUIPNL:getChildByName("Panel_SystemBrocast"),"Layout")
 --    local Label_SystemBrocast = tolua.cast(Panel_SystemBrocast:getChildByName("Label_SystemBrocast"),"Label")
 --    Label_SystemBrocast:setText(strText)
 --    Label_SystemBrocast:setPosition(ccp(810,20))


	-- g_HomeSystemBroadcast(Label_SystemBrocast)

	g_GameNoticeForm:InitNoticeForm(Panel_SystemBrocast, Image_MainHomeUIPNL)
	
	if Panel_SystemBrocast ~= nil then
		Panel_SystemBrocast:removeFromParentAndCleanup(true)
	end
	
end

function MainScene:shouFunctionsByLevel()

	local Image_MainHomeUIPNL = tolua.cast(self.rootLayout:getChildByName("Image_MainHomeUIPNL"), "ImageView")
	local Button_FuncOpenTip = tolua.cast(Image_MainHomeUIPNL:getChildByName("Button_FuncOpenTip"), "Button")
	
	local tbFunctionOpenLevelInSort = getFunctionOpenLevelCsvNext()
	
	if tbFunctionOpenLevelInSort.OpenLevel > 0 then
		Button_FuncOpenTip:setVisible(true)
		Button_FuncOpenTip:setTouchEnabled(true)
		
		local Button_FunctionIcon = tolua.cast(Button_FuncOpenTip:getChildByName("Button_FunctionIcon"), "Button")
		Button_FunctionIcon:loadTextureNormal(getUIImg(tbFunctionOpenLevelInSort.OpenFuncIcon))
		Button_FunctionIcon:loadTexturePressed(getUIImg(tbFunctionOpenLevelInSort.OpenFuncIcon))
		Button_FunctionIcon:loadTextureDisabled(getUIImg(tbFunctionOpenLevelInSort.OpenFuncIcon))
		
		local Image_Check = tolua.cast(Button_FunctionIcon:getChildByName("Image_Check"), "ImageView")
		Image_Check:loadTexture(getUIImg(tbFunctionOpenLevelInSort.OpenFuncIcon))
		
		local function onClick_Button_FunctionIcon()
			g_ClientMsgTips:showWarning(string.format(_T("%s将在%d级开放, 加油练级哦~亲~！"), tbFunctionOpenLevelInSort.OpenFuncName, tbFunctionOpenLevelInSort.OpenLevel))
		end
		g_SetBtnWithPressImage(Button_FunctionIcon, 1, onClick_Button_FunctionIcon, true, 1)
		
		local Image_FuncName = tolua.cast(Button_FuncOpenTip:getChildByName("Image_FuncName"), "ImageView")
		Image_FuncName:loadTexture(getUIImg(tbFunctionOpenLevelInSort.OpenFuncNamePic))
		local BitmapLabel_OpenLevel = tolua.cast(Button_FuncOpenTip:getChildByName("BitmapLabel_OpenLevel"), "LabelBMFont")
		BitmapLabel_OpenLevel:setText(string.format(_T("Lv.%d"), tbFunctionOpenLevelInSort.OpenLevel))
		
		Button_FunctionIcon:removeAllNodes()
		local armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("FunctionStarEffect", nil, nil, 2, nil, true)
		armature:setPositionXY(0, 0)
		armature:setScale(1.2)
		Button_FunctionIcon:addNode(armature)
		userAnimation:playWithIndex(0)
	else
		Button_FuncOpenTip:setVisible(false)
		Button_FuncOpenTip:setTouchEnabled(false)
	end
	
	local nTopRightButtonOpenCount = 0
	for nButtonIndex = 1, #tbTopRightButtonList do
		local strBtnName = tbTopRightButtonList[nButtonIndex]:getName()
		if not g_CheckFuncCanOpenByWidgetName(strBtnName) then
			tbTopRightButtonList[nButtonIndex]:setPositionX(-70)
			tbTopRightButtonList[nButtonIndex]:setVisible(false)
			tbTopRightButtonList[nButtonIndex]:setTouchEnabled(false)
		else
			if g_CheckNoticeNumByBtnName(strBtnName) then
				tbTopRightButtonList[nButtonIndex]:setPositionX(-180-85*nTopRightButtonOpenCount)
				tbTopRightButtonList[nButtonIndex]:setVisible(true)
				tbTopRightButtonList[nButtonIndex]:setTouchEnabled(true)
				nTopRightButtonOpenCount = nTopRightButtonOpenCount + 1
			else
				tbTopRightButtonList[nButtonIndex]:setPositionX(-70)
				tbTopRightButtonList[nButtonIndex]:setVisible(false)
				tbTopRightButtonList[nButtonIndex]:setTouchEnabled(false)
			end
		end
	end
	
	local nBottomLeftButtonOpenCount = 0
	for nButtonIndex = 1, #tbBottomLeftButtonList do
		local strBtnName = tbBottomLeftButtonList[nButtonIndex]:getName()
		if not g_CheckFuncCanOpenByWidgetName(strBtnName) then
			tbBottomLeftButtonList[nButtonIndex]:setPositionY(50)
			tbBottomLeftButtonList[nButtonIndex]:setVisible(false)
			tbBottomLeftButtonList[nButtonIndex]:setTouchEnabled(false)
		else
			if g_CheckNoticeNumByBtnName(strBtnName) then
				tbBottomLeftButtonList[nButtonIndex]:setPositionY(145+95*nBottomLeftButtonOpenCount)
				tbBottomLeftButtonList[nButtonIndex]:setVisible(true)
				tbBottomLeftButtonList[nButtonIndex]:setTouchEnabled(true)
				nBottomLeftButtonOpenCount = nBottomLeftButtonOpenCount + 1
			else
				tbBottomLeftButtonList[nButtonIndex]:setPositionY(50)
				tbBottomLeftButtonList[nButtonIndex]:setVisible(false)
				tbBottomLeftButtonList[nButtonIndex]:setTouchEnabled(false)
			end
		end
	end
end

function MainScene:refreshHomeStatusBar()
	local Image_Level = tolua.cast(self.Button_PlayerInfo:getChildByName("Image_Level"), "ImageView")
	local Label_Level = tolua.cast(Image_Level:getChildByName("Label_Level"), "Label")
	local CCNode_Level = tolua.cast(Label_Level:getVirtualRenderer(), "CCLabelTTF")
	CCNode_Level:disableShadow(true)
	Label_Level:setText(g_Hero:getMasterCardLevel())
	
	local Image_VIPLevelBase = tolua.cast(self.Button_PlayerInfo:getChildByName("Image_VIPLevelBase"), "ImageView")
	local Image_VIPLevel = tolua.cast(Image_VIPLevelBase:getChildByName("Image_VIPLevel"), "ImageView")
	Image_VIPLevel:loadTexture(getUIImg("VIP"..g_VIPBase:getVIPLevelId()))

	self.ProgressBar_Energy:setPercent(g_Hero:getEnergyPercent())
	self.Label_Energy:setText(g_Hero:getEnergy().."/"..g_Hero:getMaxEnergy())
	
	self.BitmapLabel_TeamStrength:setText(g_Hero:getTeamStrength())
	
	local Image_YuanBao = tolua.cast(self.Button_PlayerInfo:getChildByName("Image_YuanBao"), "ImageView")
	local Label_ResourceValue = tolua.cast(Image_YuanBao:getChildByName("Label_ResourceValue"), "Label")
	Label_ResourceValue:setText(g_Hero:getYuanBaoString())
	
	local Image_TongQian = tolua.cast(self.Button_PlayerInfo:getChildByName("Image_TongQian"), "ImageView")
	local Label_ResourceValue = tolua.cast(Image_TongQian:getChildByName("Label_ResourceValue"), "Label")
	Label_ResourceValue:setText(g_Hero:getCoinsString())
	
    g_HeadBar:refreshHeadBar()
end

function MainScene:initBottomLeftButtonList()

	local Image_MainHomeUIPNL = tolua.cast(self.rootLayout:getChildByName("Image_MainHomeUIPNL"), "ImageView")
	local Image_LeftFunctionPNL = tolua.cast(Image_MainHomeUIPNL:getChildByName("Image_LeftFunctionPNL"), "ImageView")

	--聊天界面按钮
	self.Button_ChatCenter = tolua.cast(Image_LeftFunctionPNL:getChildByName("Button_ChatCenter"), "Button")
	--好友界面按钮
	self.Button_Friend = tolua.cast(Image_LeftFunctionPNL:getChildByName("Button_Friend"), "Button")
	--帮派界面按钮
	self.Button_Group = tolua.cast(Image_LeftFunctionPNL:getChildByName("Button_Group"), "Button")
	--邮件
	self.Button_Mail = tolua.cast(Image_LeftFunctionPNL:getChildByName("Button_Mail"), "Button")
	--转盘
	self.Button_Turntable = tolua.cast(Image_LeftFunctionPNL:getChildByName("Button_Turntable"), "Button")
	
	table.insert(tbBottomLeftButtonList, self.Button_Friend)
	table.insert(tbBottomLeftButtonList, self.Button_Group)
	table.insert(tbBottomLeftButtonList, self.Button_Mail)
	table.insert(tbBottomLeftButtonList, self.Button_Turntable)

	local function onClick_MainHomeButton(pSender, nTag)
		if nTag == 1 then	--聊天
			g_WndMgr:showWnd("Game_ChatCenter")
		elseif nTag == 2 then	--好友
			g_SALMgr:initSocialApplicationListData(40)
		elseif nTag == 3 then	--帮派
			-- local group = 
			g_Guild:openGroupView(true)
			-- group:showWnd()
		elseif nTag == 4 then	--邮件
			g_WndMgr:openWnd("Game_MailBox")
		elseif nTag == 5 then	--爱心转盘
			g_WndMgr:openWnd("Game_Turntable")
		end
    end

	g_SetBtnOpenCheckWithPressImage(self.Button_ChatCenter, 1, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnGuideCheckWithPressImage(self.Button_Friend, 2, onClick_MainHomeButton, true, false, 1, nil, true)
	g_SetBtnGuideCheckWithPressImage(self.Button_Group, 3, onClick_MainHomeButton, true, false, 1, nil, true)
	g_SetBtnGuideCheckWithPressImage(self.Button_Mail, 4, onClick_MainHomeButton, true, false, 1, nil, true)
	g_SetBtnGuideCheckWithPressImage(self.Button_Turntable, 5, onClick_MainHomeButton, true, false, 1, nil, true)
end

-- function MainScene:testAnimation()
	-- local armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("BaTiWu", nil, nil, 1, nil, true)
	-- armature:setPositionXY(640, 360)
	-- armature:setTag(999)
	-- self.rootWidget:addNode(armature, 9999)
	-- userAnimation:playWithIndex(0)
-- end

function MainScene:initTopRightButtonList()

	local Image_MainHomeUIPNL = tolua.cast(self.rootLayout:getChildByName("Image_MainHomeUIPNL"),"ImageView")
	local Image_TopFunctionPNL = tolua.cast(Image_MainHomeUIPNL:getChildByName("Image_TopFunctionPNL"),"ImageView")

	
	self.Button_Ectype = tolua.cast(Image_TopFunctionPNL:getChildByName("Button_Ectype"),"Button")

	self.Button_ChongZhi = tolua.cast(Image_TopFunctionPNL:getChildByName("Button_ChongZhi"),"Button")
	self.Button_Assistant = tolua.cast(Image_TopFunctionPNL:getChildByName("Button_Assistant"),"Button")
	self.Button_ZhaoCai = tolua.cast(Image_TopFunctionPNL:getChildByName("Button_ZhaoCai"),"Button")
	self.Button_HuoDong = tolua.cast(Image_TopFunctionPNL:getChildByName("Button_HuoDong"),"Button")
	self.Button_QianDao = tolua.cast(Image_TopFunctionPNL:getChildByName("Button_QianDao"),"Button")
	self.Button_FirstCharge = tolua.cast(Image_TopFunctionPNL:getChildByName("Button_FirstCharge"),"Button")
	self.Button_OnLineReward = tolua.cast(Image_TopFunctionPNL:getChildByName("Button_OnLineReward"),"Button")
	self.Button_JiaNianHua = tolua.cast(Image_TopFunctionPNL:getChildByName("Button_JiaNianHua"),"Button")
    self.Button_DeBug = tolua.cast(Image_TopFunctionPNL:getChildByName("Button_DeBug"),"Button")
    --self.Button_DeBug:setVisible(false)
   
   	--在线时间用到
   	local Label_CountDown = tolua.cast(self.Button_OnLineReward:getChildByName("Label_CountDown"), "Label")
   	Label_CountDown:setVisible(false)
   	Act_OnlineTime:setOnlineLabel(Label_CountDown)
	
	table.insert(tbTopRightButtonList, self.Button_ChongZhi)
	table.insert(tbTopRightButtonList, self.Button_Assistant)
	table.insert(tbTopRightButtonList, self.Button_ZhaoCai)
	table.insert(tbTopRightButtonList, self.Button_HuoDong)
	table.insert(tbTopRightButtonList, self.Button_QianDao)
	table.insert(tbTopRightButtonList, self.Button_FirstCharge)
	table.insert(tbTopRightButtonList, self.Button_OnLineReward)
	table.insert(tbTopRightButtonList, self.Button_JiaNianHua)
	table.insert(tbTopRightButtonList, self.Button_DeBug)
	
	self.Button_JiaNianHua:loadTextureNormal(getUIImg("BtnJiaNianHua"..g_Hero:getMasterSex()))
	self.Button_JiaNianHua:loadTexturePressed(getUIImg("BtnJiaNianHua"..g_Hero:getMasterSex()))
	self.Button_JiaNianHua:loadTextureDisabled(getUIImg("BtnJiaNianHua"..g_Hero:getMasterSex()))
	local Image_Check = tolua.cast(self.Button_JiaNianHua:getChildByName("Image_Check"), "ImageView")
	Image_Check:loadTexture(getUIImg("BtnJiaNianHua"..g_Hero:getMasterSex()))
	
	local Button_Player = tolua.cast(self.Button_Ectype:getChildByName("Button_Player"), "Button")
	local Image_Check = tolua.cast(Button_Player:getChildByName("Image_Check"), "ImageView")
	Image_Check:loadTexture(getUIImg("Button_Ectype_Player"..g_Hero:getMasterSex()))
	Button_Player:loadTextureNormal(getUIImg("Button_Ectype_Player"..g_Hero:getMasterSex()))
	Button_Player:loadTexturePressed(getUIImg("Button_Ectype_Player"..g_Hero:getMasterSex()))
	Button_Player:loadTextureDisabled(getUIImg("Button_Ectype_Player"..g_Hero:getMasterSex()))
	
    local function onClick_MainHomeButton(pSender, nTag)
		if nTag == 1 then --副本
			g_WndMgr:openWnd("Game_Ectype")
		elseif nTag == 2 then --充值
			g_WndMgr:openWnd("Game_ReCharge")
		elseif nTag == 3 then --小助手
			g_WndMgr:openWnd("Game_Assistant")
		elseif nTag == 4 then --招财
			g_WndMgr:openWnd("Game_ZhaoCaiFu")
		elseif nTag == 5 then --运营活动
			g_WndMgr:openWnd("Game_ActivityCenter")
		elseif nTag == 6 then --签到
			g_WndMgr:showWnd("Game_Registration1")
		elseif nTag == 7 then --首充
			g_WndMgr:showWnd("Game_FirstCharge")
		elseif nTag == 8 then --在线奖励
			g_WndMgr:openWnd("Game_ActivityCenter", common_pb.AOLT_ONLINE)
		elseif nTag == 9 then --嘉年华
			g_WndMgr:openWnd("Game_ServerOpenTask")
		elseif nTag == 100 then	--GM
			if g_Cfg.Platform  == kTargetWindows then --测试代码全放kTargetWindows逻辑下面，严禁修改else的内容
				-- if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() 
					-- --临时功能 在越南测试服中个测试跨服系统 正式服打开
					-- and g_ServerList.ServerIp == "117.103.198.148" then
					
					-- local daySum = g_DataMgr:getGlobalCfgCsv("kuafu_arena_open_day")
					-- if g_Hero:getTotalSysDays() < daySum then 
						-- local txt = string.format(_T("跨服天榜功能需在开服%d天开放"),daySum)
						-- g_ShowSysWarningTips({text = txt})
						-- return 
					-- end
					g_ArenaKuaFuData:requestSelfCrossRank()
				-- else
					-- g_ShowSysWarningTips({text =_T("跨服天榜赛事还未开启,敬请期待!")})
				-- end
			else --GM
				--测试代码全放kTargetWindows逻辑下面，严禁修改else的内容
				if g_Cfg.Debug == true then --如果gm工具实效 不要修改这个地方。修改CDebugCfg.lua 的 Debug 值
					g_WndMgr:showWnd("Game_GMConsole")
				end
			end
		end
    end
	
	g_SetBtnGuideCheckWithPressImage(Button_Player, 1, onClick_MainHomeButton, true, false, 1)
	g_SetBtnGuideCheckWithPressImage(self.Button_Ectype, 1, onClick_MainHomeButton, true, false, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_ChongZhi, 2, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnOpenCheckWithPressImage(self.Button_Assistant, 3, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnOpenCheckWithPressImage(self.Button_ZhaoCai, 4, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnOpenCheckWithPressImage(self.Button_HuoDong, 5, onClick_MainHomeButton, true, false, true, 1, nil, true)	
	g_SetBtnOpenCheckWithPressImage(self.Button_QianDao, 6, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnOpenCheckWithPressImage(self.Button_FirstCharge, 7, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnOpenCheckWithPressImage(self.Button_OnLineReward, 8, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnOpenCheckWithPressImage(self.Button_JiaNianHua, 9, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnOpenCheckWithPressImage(self.Button_DeBug, 100, onClick_MainHomeButton, true, false, true, 1, nil, true)
end

function MainScene:initTopLeftButtonList()
	--状态栏
	local Image_MainHomeUIPNL = tolua.cast(self.rootLayout:getChildByName("Image_MainHomeUIPNL"), "ImageView")
	
	self.Button_PlayerInfo = tolua.cast(Image_MainHomeUIPNL:getChildByName("Button_PlayerInfo"), "Button")
	
	local Image_EnergyBase = tolua.cast(self.Button_PlayerInfo:getChildByName("Image_EnergyBase"), "ImageView")
	
	self.ProgressBar_Energy = tolua.cast(Image_EnergyBase:getChildByName("ProgressBar_Energy"),"LoadingBar")
	
	local Image_TeamStrengthBase = tolua.cast(self.Button_PlayerInfo:getChildByName("Image_TeamStrengthBase"), "ImageView")

	
	self.BitmapLabel_TeamStrength = tolua.cast(Image_TeamStrengthBase:getChildByName("BitmapLabel_TeamStrength"),"LabelBMFont")
	self.Label_Energy = tolua.cast(Image_EnergyBase:getChildByName("Label_Energy"),"Label")
	
	local Button_PlayerIcon = tolua.cast(self.Button_PlayerInfo:getChildByName("Button_PlayerIcon"), "Button")
	local Image_Check = tolua.cast(Button_PlayerIcon:getChildByName("Image_Check"), "ImageView")
	Image_Check:loadTexture(getUIImg("PlayerIcon"..g_Hero:getMasterSex()))
	Button_PlayerIcon:loadTextureNormal(getUIImg("PlayerIcon"..g_Hero:getMasterSex()))
	Button_PlayerIcon:loadTexturePressed(getUIImg("PlayerIcon"..g_Hero:getMasterSex()))
	Button_PlayerIcon:loadTextureDisabled(getUIImg("PlayerIcon"..g_Hero:getMasterSex()))

    local ScrollView_City = tolua.cast(self.rootLayout:getChildByName("ScrollView_City"),"ScrollView")
	local Panel_touchLayout = tolua.cast(ScrollView_City:getChildByName("Panel_touchLayout"), "Layout")
	Panel_touchLayout:setTouchEnabled(true)

	local function Button_PlayerOnclick()
		g_WndMgr:showWnd("Game_HomeFunctionList")
	end
	g_SetBtnWithPressImage(self.Button_PlayerInfo, 1, Button_PlayerOnclick, true, 1)
	g_SetBtnWithPressImage(Button_PlayerIcon, 1, Button_PlayerOnclick, true, 1)
	

	self.fristChatMsg = 0
	
end

--初始化中间按钮功能
function MainScene:initCenterBuildingButtonList()

	
    local Image_MainHomeUIPNL = tolua.cast(self.rootLayout:getChildByName("Image_MainHomeUIPNL"),"ImageView")
    local ScrollView_City = tolua.cast(self.rootLayout:getChildByName("ScrollView_City"),"ScrollView")
    
	self.Button_Building_TianBang = tolua.cast(ScrollView_City:getChildByName("Button_Building_TianBang"),"Button")
	self.Button_SubBuilding_TianBang1 = tolua.cast(self.Button_Building_TianBang:getChildByName("Button_SubBuilding_TianBang1"),"Button")	
	self.Button_SubBuilding_TianBang2 = tolua.cast(self.Button_Building_TianBang:getChildByName("Button_SubBuilding_TianBang2"),"Button")
   
	self.Button_Building_FuLuShan = tolua.cast(ScrollView_City:getChildByName("Button_Building_FuLuShan"),"Button")
    self.Button_Building_ZhaoHuanTai = tolua.cast(ScrollView_City:getChildByName("Button_Building_ZhaoHuanTai"),"Button")
	
	self.Button_Building_LianYaoTa = tolua.cast(ScrollView_City:getChildByName("Button_Building_LianYaoTa"),"Button")
	self.Button_Building_JiHuiSuo = tolua.cast(ScrollView_City:getChildByName("Button_Building_JiHuiSuo"),"Button")
	self.Button_Building_Farm = tolua.cast(ScrollView_City:getChildByName("Button_Building_Farm"),"Button")
	self.Button_Building_WorldBoss = tolua.cast(ScrollView_City:getChildByName("Button_Building_WorldBoss"),"Button")
	self.Button_Building_ShiLianShan = tolua.cast(ScrollView_City:getChildByName("Button_Building_ShiLianShan"),"Button")
	self.Button_Building_JuBaoGe = tolua.cast(ScrollView_City:getChildByName("Button_Building_JuBaoGe"),"Button")
	self.Button_Building_JuXianGe = tolua.cast(ScrollView_City:getChildByName("Button_Building_JuXianGe"),"Button")
	self.Button_Building_LunHuiTa = tolua.cast(ScrollView_City:getChildByName("Button_Building_LunHuiTa"),"Button")

    local function onClick_MainHomeButton(pSender, nTag)
		if nTag == 1 then	--竞技场按钮
			g_WndMgr:openWnd("Game_Arena")
		elseif nTag == 2 then	--福禄山
			g_WndMgr:showWnd("Game_ActivityFuLuDao")
		elseif nTag == 3 then	--召唤台
			g_WndMgr:openWnd("Game_Summon")
		elseif nTag == 4 then	--猎命
			-- g_WndMgr:openWnd("Game_HuntFate1")
			g_FateData:requestHuntFateRefresh()
		elseif nTag == 5 then	--集会所
			if g_PlayerGuide:checkIsInGuide()
				and (
					g_PlayerGuide:checkIsInGuide() == 220
					or g_PlayerGuide:checkIsInGuide() == 232
					or g_PlayerGuide:checkIsInGuide() == 236
				)
			then
				return
			end
			
			g_Guild:openGroupView(false)
			
		elseif nTag == 6 then  --农场
			g_WndMgr:showWnd("Game_Farm")
		elseif nTag == 7 then	--斩仙台
			
		elseif nTag == 8 then 	--试炼山
			g_WndMgr:showWnd("Game_ActivityShiLianShan")
		elseif nTag == 9 then 	--聚宝阁
			g_WndMgr:showWnd("Game_JuBaoGe")
		elseif nTag == 10 then 	--聚仙阁
			g_WndMgr:showWnd("Game_ActivityJuXianGe")
		elseif nTag == 11 then 	--跨服天榜
			if g_LggV:getLanguageVer() == eLanguageVer.LANGUAGE_cht_Taiwan and g_LggV:getLanguageVer() == eLanguageVer.LANGUAGE_zh_AUDIT then
				g_ShowSysWarningTips({text =_T("跨服天榜赛事还未开启,敬请期待!")})
				return
			end
			
			local daySum = g_DataMgr:getGlobalCfgCsv("kuafu_arena_open_day")
			if g_Hero:getTotalSysDays() < daySum then 
				local txt = string.format(_T("跨服天榜功能需在开服%d天开放"),daySum)
				g_ShowSysWarningTips({text = txt})
				return 
			end
			g_ArenaKuaFuData:requestSelfCrossRank()
		elseif nTag == 12 then 	--轮回塔
			--

		end
    end
	
	self.Button_SubBuilding_TianBang1:setAlphaTouchEnable(true)
	self.Button_SubBuilding_TianBang2:setAlphaTouchEnable(true)
	self.Button_Building_FuLuShan:setAlphaTouchEnable(true)
	self.Button_Building_ZhaoHuanTai:setAlphaTouchEnable(true)
	self.Button_Building_LianYaoTa:setAlphaTouchEnable(true)
	self.Button_Building_JiHuiSuo:setAlphaTouchEnable(true)
	self.Button_Building_Farm:setAlphaTouchEnable(true)
	self.Button_Building_WorldBoss:setAlphaTouchEnable(true)
	self.Button_Building_JuBaoGe:setAlphaTouchEnable(true)
	self.Button_Building_JuXianGe:setAlphaTouchEnable(true)
	
	g_SetBtnOpenCheckWithPressImage(self.Button_SubBuilding_TianBang2, 1, onClick_MainHomeButton, true, false, true, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_Building_FuLuShan, 2, onClick_MainHomeButton, true, false, true, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_Building_ZhaoHuanTai, 3, onClick_MainHomeButton, true, false, true, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_Building_LianYaoTa, 4, onClick_MainHomeButton, true, false, true, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_Building_JiHuiSuo, 5, onClick_MainHomeButton, true, false, true, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_Building_Farm, 6, onClick_MainHomeButton, true, false, true, 1)
	
	if g_LggV:getLanguageVer() == eLanguageVer.LANGUAGE_zh_CN or g_LggV:getLanguageVer() == eLanguageVer.LANGUAGE_zh_AUDIT then
		g_SetBtnOpenCheckWithPressImage(self.Button_Building_WorldBoss, 7, onClick_MainHomeButton, false, false, true, 1)
	else
		g_SetBtnOpenCheckWithPressImage(self.Button_Building_WorldBoss, 7, onClick_MainHomeButton, true, false, true, 1)
	end
	
	g_SetBtnOpenCheckWithPressImage(self.Button_Building_ShiLianShan, 8, onClick_MainHomeButton, true, false, true, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_Building_JuBaoGe, 9, onClick_MainHomeButton, true, false, true, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_Building_JuXianGe, 10, onClick_MainHomeButton, true, false, true, 1)
	
    if g_strStandAloneGame == "open" then
        self.Button_SubBuilding_TianBang1:setAlphaTouchEnable(false)
        local Image_FuncName1 = self.Button_Building_TianBang:getChildAllByName("Image_FuncName1")
        Image_FuncName1:setVisible(false)            
    else
        g_SetBtnOpenCheckWithPressImage(self.Button_SubBuilding_TianBang1, 11, onClick_MainHomeButton, true, false, true, 1)
    end
	
	if g_LggV:getLanguageVer() == eLanguageVer.LANGUAGE_zh_CN or g_LggV:getLanguageVer() == eLanguageVer.LANGUAGE_zh_AUDIT then
		local Image_FuncName = tolua.cast(self.Button_Building_LunHuiTa:getChildByName("Image_FuncName"), "ImageView")
		Image_FuncName:setVisible(false)
		g_SetBtnOpenCheckWithPressImage(self.Button_Building_LunHuiTa, 12, onClick_MainHomeButton, false, false, true, 1)
	else
		g_SetBtnOpenCheckWithPressImage(self.Button_Building_LunHuiTa, 12, onClick_MainHomeButton, true, false, true, 1)
	end
	
	local armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("PuBu", nil, nil, 2, nil, true)
	armature:setPositionXY(-195, -140)
	armature:setScale(5)
	self.Button_Building_TianBang:addNode(armature, 999)
	userAnimation:playWithIndex(0)
end

--初始化右下方按钮功能
function MainScene:initBottomRightButtonList()

	
	local Image_MainHomeUIPNL = tolua.cast(self.rootLayout:getChildByName("Image_MainHomeUIPNL"),"ImageView")
	local Image_MainFunctionPNL = tolua.cast(Image_MainHomeUIPNL:getChildByName("Image_MainFunctionPNL"),"ImageView")
	
	self.Button_Container = tolua.cast(Image_MainFunctionPNL:getChildByName("Button_Container"), "Button")
	self.Image_ContainerCover = tolua.cast(Image_MainFunctionPNL:getChildByName("Image_ContainerCover"), "ImageView")
	
	local function Button_ContainerOnclick(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			self:runExpandAction()
			self:addNoticeAnimation_Container()
		end
	end
	self.Button_Container:setTouchEnabled(true)
	self.Button_Container:addTouchEventListener(Button_ContainerOnclick)
	
	local function Image_ContainerCoverOnClick(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			Button_ContainerOnclick(self.Button_Container, ccs.TouchEventType.ended)
		end
	end
	self.Image_ContainerCover:setTouchEnabled(true)
	self.Image_ContainerCover:addTouchEventListener(Image_ContainerCoverOnClick)
	
	
	self.Button_Main_Member = tolua.cast(Image_MainFunctionPNL:getChildByName("Button_Main_Member"),"Button")
	self.Button_Main_Team = tolua.cast(Image_MainFunctionPNL:getChildByName("Button_Main_Team"),"Button")
	self.Button_Main_Equip = tolua.cast(Image_MainFunctionPNL:getChildByName("Button_Main_Equip"),"Button")
	self.Button_Main_Package = tolua.cast(Image_MainFunctionPNL:getChildByName("Button_Main_Package"),"Button")
	self.Button_Main_XianMai = tolua.cast(Image_MainFunctionPNL:getChildByName("Button_Main_XianMai"),"Button")
	self.Button_Main_ShangXiang = tolua.cast(Image_MainFunctionPNL:getChildByName("Button_Main_ShangXiang"),"Button")
	self.Button_Main_QiShu = tolua.cast(Image_MainFunctionPNL:getChildByName("Button_Main_QiShu"),"Button")
	self.Button_Main_YiShou = tolua.cast(Image_MainFunctionPNL:getChildByName("Button_Main_YiShou"),"Button")
	

	local function onClick_MainHomeButton(pSender, nTag)
		if nTag == 1 then	--神仙按钮
			g_WndMgr:showWnd("Game_Card")
		elseif nTag == 2 then	--门派按钮
			g_WndMgr:openWnd("Game_MainUI")
		elseif nTag == 3 then	--装备按钮
			g_WndMgr:openWnd("Game_Equip1")
		elseif nTag == 4 then	--背包按钮
			g_WndMgr:showWnd("Game_Package1")
		elseif nTag == 5 then	--仙脉
			g_WndMgr:openWnd("Game_XianMai")
		elseif nTag == 6 then	--上香
			g_WndMgr:openWnd("Game_ShangXiang1")
		elseif nTag == 7 then	--奇术
			g_WndMgr:showWnd("Game_QiShu")
		elseif nTag == 8 then	--异兽
			local tbData= {}
			tbData.nCardID = g_Hero:getBattleCardByIndex(1):getServerId()
			g_WndMgr:openWnd("Game_CardFate1", tbData)
		end
    end
	
	--从右到左开始数
	table.insert(g_tbHorizontalBtnPos, self.Button_Main_ShangXiang:getPosition())
	table.insert(g_tbHorizontalBtnPos, self.Button_Main_XianMai:getPosition())
	table.insert(g_tbHorizontalBtnPos, self.Button_Main_Package:getPosition())
	table.insert(g_tbHorizontalBtnPos, self.Button_Main_Equip:getPosition())
	table.insert(g_tbHorizontalBtnPos, self.Button_Main_Team:getPosition())
	table.insert(g_tbHorizontalBtnPos, self.Button_Main_Member:getPosition())
	--从下到上开始数
	table.insert(g_tbVerticalBtnPos, self.Button_Main_QiShu:getPosition())
	table.insert(g_tbVerticalBtnPos, self.Button_Main_YiShou:getPosition())
	
	g_SetBtnOpenCheckWithPressImage(self.Button_Main_Member, 1, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnOpenCheckWithPressImage(self.Button_Main_Team, 2, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnOpenCheckWithPressImage(self.Button_Main_Equip, 3, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnOpenCheckWithPressImage(self.Button_Main_Package, 4, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnOpenCheckWithPressImage(self.Button_Main_XianMai, 5, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnOpenCheckWithPressImage(self.Button_Main_ShangXiang, 6, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnOpenCheckWithPressImage(self.Button_Main_QiShu, 7, onClick_MainHomeButton, true, false, true, 1, nil, true)
	g_SetBtnOpenCheckWithPressImage(self.Button_Main_YiShou, 8, onClick_MainHomeButton, true, false, true, 1, nil, true)
	
	self.tbBtnData = {}
	self:setTbHorizontalBtn()
	self:setTbVerticalBtn()
	self:initButtonAction()
end

function MainScene:refreshHomeBubbleNotify()
	g_Hero.bubbleNotify = g_Hero.bubbleNotify or {}
end

--起刷新作用
function MainScene:openWnd()
    if G_Load then

  --   	if(not package.loaded["LuaScripts/Refresh.lua"] )then
		-- require("LuaScripts/Refresh.lua")
		-- end
		-- g_WndMgr:reset(true)
		-- LoadGamWndFile()
		-- g_WndMgr:openWnd("Game_Home")
		-- CCDirector:sharedDirector():replaceScene(mainWnd)


    	G_Load = false
    end

    g_GameNoticeSystem:SendRespondNoticeID()

	self.rootLayout:setIgnoreCheckDis(false)
	self:refreshHomeStatusBar()
	self:shouFunctionsByLevel()

	g_FormMsgSystem:RegisterFormMsg(FormMsg_MainForm_Refresh, handler(self, self.refreshNoticeAnimation))
	if g_Hero.bNoticeDataOK then
		self:refreshNoticeAnimation()
	end
	--同步一下服务器时间
	g_MsgMgr:requestSyncServerTime()

	-----
	g_MapInfo:mapStarInfoRequest()
	
	--openWnd的时候不需要居中，会影响玩家操作，by kakiwang
	--self:setCityToCenter()


	--每次检测主界面公告
	local context = g_GameNoticeSystem:GetFirstGameNotice()
	if context ~= nil then
		g_GameNoticeForm:ShowWinMianNotce(context)
	end
	
	if g_IsNewPlayer then
		-- local TDdata =  CDataEvent:CteateDataEvent()
		-- TDdata:PushDataEvent("Step5", "S") --S or F, Success or Fail
		-- gTalkingData:onEvent(TDEvent_Type.Create, TDdata)
	else
		-- local TDdata =  CDataEvent:CteateDataEvent()
		-- TDdata:PushDataEvent("Step3", "S") --S or F, Success or Fail
		-- gTalkingData:onEvent(TDEvent_Type.EnterGame, TDdata)
	end
	
	if g_bReturn then
		self:showPlayerGuide()
	end
end

function MainScene:closeWnd()
	self.rootLayout:setIgnoreCheckDis(true)
	
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_MainForm_Refresh)
end

local nActionCountHorizontal = 0
function MainScene:runButtonMoveActionHorizontal(objActionButton, tbTargetPos, bIsExpand)
	local actionFadeTo = nil
	if bIsExpand then
		actionFadeTo = CCFadeTo:create(0.15, 255)
	else
		actionFadeTo = CCFadeTo:create(0.15, 0)
	end

	local arrAct = CCArray:create()
	local actionMoveTo = CCMoveTo:create(0.15, tbTargetPos)
	local actionMoveToEase = CCEaseInOut:create(actionMoveTo, 2)
	local actionSpwan = CCSpawn:createWithTwoActions(actionMoveToEase, actionFadeTo)
	arrAct:addObject(actionSpwan)
	if bIsExpand then
		local function executeEndUpAction()
			nActionCountHorizontal = nActionCountHorizontal + 1
			if nActionCountHorizontal == #self.tbBtnData.tbHorizontalBtnPos then
				if g_PlayerGuide:checkCurrentGuideSequenceNode("ActionEventEnd", "Game_Home") then
					g_PlayerGuide:showCurrentGuideSequenceNode()
				end
			end
		end
		arrAct:addObject(CCCallFuncN:create(executeEndUpAction))
	end
	local actionSequence = CCSequence:create(arrAct)
	objActionButton:runAction(actionSequence)
end

local nActionCountVertical = 0
function MainScene:runButtonMoveActionVertical(objActionButton, tbTargetPos, bIsExpand)
	local actionFadeTo = nil
	if bIsExpand then
		actionFadeTo = CCFadeTo:create(0.15, 255)
	else
		actionFadeTo = CCFadeTo:create(0.15, 0)
	end

	local arrAct = CCArray:create()
	local actionMoveTo = CCMoveTo:create(0.15, tbTargetPos)
	local actionMoveToEase = CCEaseInOut:create(actionMoveTo, 2)
	local actionSpwan = CCSpawn:createWithTwoActions(actionMoveToEase, actionFadeTo)
	arrAct:addObject(actionSpwan)
	if bIsExpand then
		local function executeEndUpAction()
			nActionCountVertical = nActionCountVertical + 1
			if nActionCountVertical == #self.tbBtnData.tbVerticalBtnPos then
				if g_PlayerGuide:checkCurrentGuideSequenceNode("ActionEventEnd", "Game_Home") then
					g_PlayerGuide:showCurrentGuideSequenceNode()
				end
			end
		end
		arrAct:addObject(CCCallFuncN:create(executeEndUpAction))
	end
	local actionSequence = CCSequence:create(arrAct)
	objActionButton:runAction(actionSequence)
end

function MainScene:runExpandActionBotton(bIsExpand)
	nActionCountHorizontal = 0
	nActionCountVertical = 0
	if bIsExpand then
		if #self.tbBtnData.tbHorizontalBtnPos > 0 then
			for i = 1, #self.tbBtnData.tbHorizontalBtnPos do
				self:runButtonMoveActionHorizontal(self.tbBtnData.tbHorizontalBtnPos[i].objButton, g_tbHorizontalBtnPos[i], bIsExpand)
			end
		end
		if #self.tbBtnData.tbVerticalBtnPos > 0 then
			for i = 1, #self.tbBtnData.tbVerticalBtnPos do
				self:runButtonMoveActionVertical(self.tbBtnData.tbVerticalBtnPos[i].objButton, g_tbVerticalBtnPos[i], bIsExpand)
			end
		end
	else
		if #self.tbBtnData.tbHorizontalBtnPos > 0 then
			for i = 1, #self.tbBtnData.tbHorizontalBtnPos do
				self:runButtonMoveActionHorizontal(self.tbBtnData.tbHorizontalBtnPos[i].objButton, ccp(nEndPosX, nEndPosY), bIsExpand)
			end
		end
		if #self.tbBtnData.tbVerticalBtnPos > 0 then
			for i = 1, #self.tbBtnData.tbVerticalBtnPos do
				self:runButtonMoveActionVertical(self.tbBtnData.tbVerticalBtnPos[i].objButton, ccp(nEndPosX, nEndPosY), bIsExpand)
			end
		end
	end
end

function MainScene:runExpandActionContainer(bIsExpand, funcActionEndCall)
	if bIsExpand then
		local arrAct = CCArray:create()
		local actionRotateTo = CCRotateTo:create(0.3, -90)
		arrAct:addObject(actionRotateTo)
		local function executeEndUpAction()
			self.bInActionInLock = false
			if funcActionEndCall then
				funcActionEndCall()
			end
		end
		arrAct:addObject(CCCallFuncN:create(executeEndUpAction))
		local actionSequence = CCSequence:create(arrAct)
		self.Button_Container:runAction(actionSequence)
	else
		local arrAct = CCArray:create()
		local actionRotateTo = CCRotateTo:create(0.3, 0)
		arrAct:addObject(actionRotateTo)
		local function executeEndUpAction()
			self.bInActionInLock = false
			if funcActionEndCall then
				funcActionEndCall()
			end
		end
		arrAct:addObject(CCCallFuncN:create(executeEndUpAction))
		local actionSequence = CCSequence:create(arrAct)
		self.Button_Container:runAction(actionSequence)
	end
end

function MainScene:setTbHorizontalBtn()
	self.tbBtnData.tbHorizontalBtnPos = {}
	--从右到左开始数
	self:insertTbBtnData(self.Button_Main_ShangXiang, self.tbBtnData.tbHorizontalBtnPos)
	self:insertTbBtnData(self.Button_Main_XianMai, self.tbBtnData.tbHorizontalBtnPos)
	self:insertTbBtnData(self.Button_Main_Package, self.tbBtnData.tbHorizontalBtnPos)
	self:insertTbBtnData(self.Button_Main_Equip, self.tbBtnData.tbHorizontalBtnPos)
	self:insertTbBtnData(self.Button_Main_Team, self.tbBtnData.tbHorizontalBtnPos)
	self:insertTbBtnData(self.Button_Main_Member, self.tbBtnData.tbHorizontalBtnPos)
end

function MainScene:setTbVerticalBtn()
	self.tbBtnData.tbVerticalBtnPos = {}
	--从下到上开始数
	self:insertTbBtnData(self.Button_Main_QiShu, self.tbBtnData.tbVerticalBtnPos)
	self:insertTbBtnData(self.Button_Main_YiShou, self.tbBtnData.tbVerticalBtnPos)
end

function MainScene:insertTbBtnData(widgetBtn, tbBtnPos)
	local strWidgetName = widgetBtn:getName()
	local isOpen = g_CheckFuncCanOpenByWidgetName(strWidgetName) 
	if isOpen then
		table.insert(tbBtnPos,
			{
				objButton = widgetBtn
			}
		)
		widgetBtn:setVisible(true)
	else
		widgetBtn:setVisible(false)
	end	
end

function MainScene:runExpandAction(funcActionEndCall)
	if self.bInActionInLock then
		return
	end
	
	self.bInActionInLock = true
	if not self.bIsAllReadyExpand then
		self.bIsAllReadyExpand = true
		self:setTbHorizontalBtn()
		self:setTbVerticalBtn()
		self:runExpandActionContainer(self.bIsAllReadyExpand, funcActionEndCall)
		self:runExpandActionBotton(self.bIsAllReadyExpand)
	else
		self.bIsAllReadyExpand = false
		self:runExpandActionContainer(self.bIsAllReadyExpand, funcActionEndCall)
		self:runExpandActionBotton(self.bIsAllReadyExpand)
	end
end

function MainScene:initButtonAction()
	for k,v in ipairs(self.tbBtnData.tbHorizontalBtnPos)do
		v.objButton:setOpacity(0)
		v.objButton:setPosition(ccp(nEndPosX, nEndPosY))
	end
	for k,v in ipairs(self.tbBtnData.tbVerticalBtnPos)do
		v.objButton:setOpacity(0)
		v.objButton:setPosition(ccp(nEndPosX, nEndPosY))
	end

	self.Button_Container:setRotation(0)
end

function MainScene:initWnd(widget)
	--默认不休眠 add by zgj
	if g_Cfg.Platform ~= kTargetWindows then
		local IsPreventSleep = CCUserDefault:sharedUserDefault():getBoolForKey("IsPreventSleep", true)
		ScreenLock:setScreenLockDisabled(IsPreventSleep)
	end

	self.rootLayout = widget
	self:initBottomLeftButtonList()
	self:initBottomRightButtonList()
	self:initCenterBuildingButtonList()
    self:initTopLeftButtonList()
	self:initTopRightButtonList()
	
	local fRate1 = 0.9
	local fRate2 = 0.9
	local fRate3 = 0.8
	local fRate4 = 0.7
	local nWidth1 = math.floor(3195*fRate1)
	local nWidth2 = math.floor(3195*fRate2)
	local nWidth3 = math.floor(3195*fRate3)
	local nWidth4 = math.floor(3195*fRate4)
	local ScrollView_City = tolua.cast(self.rootLayout:getChildByName("ScrollView_City"), "ScrollView")
	local Panel_Inner = tolua.cast(ScrollView_City:getChildByName("Panel_Inner"), "Layout")
	local Button_Building_ShiLianShan = tolua.cast(ScrollView_City:getChildByName("Button_Building_ShiLianShan"),"Button")
	local Panel_City1 = tolua.cast(self.rootLayout:getChildByName("Panel_City1"), "Layout")
	local Panel_City2 = tolua.cast(self.rootLayout:getChildByName("Panel_City2"), "Layout")
	local Panel_City3 = tolua.cast(self.rootLayout:getChildByName("Panel_City3"), "Layout")
	ScrollView_City:setInnerContainerSize(CCSize(3195,720))
	ScrollView_City:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
	ScrollView_City:setTouchEnabled(true)
	ScrollView_City:setAlphaTouchEnable(true)
	
	Panel_Inner:setTouchEnabled(false)
	Panel_City1:setTouchEnabled(false)
	Panel_City2:setTouchEnabled(false)
	Panel_City3:setTouchEnabled(false)
	
	self.nPosInnerX = Panel_Inner:getPositionX()
	self.nPosShiLianShanX = Button_Building_ShiLianShan:getPositionX()
	local function eventListenerScrollView(pSender, eventType)
		if eventType == SCROLLVIEW_EVENT_SCROLLING  then
			local nPosX = pSender:getInnerContainer():getPositionX()
			Panel_Inner:setPositionX(self.nPosInnerX-nPosX*(1-fRate1))
			Button_Building_ShiLianShan:setPositionX(self.nPosShiLianShanX-nPosX*(1-fRate1))
			Panel_City1:setPositionX(math.max(nPosX*fRate2, -nWidth2))
			Panel_City2:setPositionX(math.max(nPosX*fRate3, -nWidth3))
			Panel_City3:setPositionX(math.max(nPosX*fRate4, -nWidth4))
		end
	end

	ScrollView_City:addEventListenerScrollView(eventListenerScrollView)
	
	local fTimeStep = 0
	local fTimeSpace = 0.1
	
	local Image_SkyFrog1 = tolua.cast(Panel_Inner:getChildByName("Image_SkyFrog1"), "ImageView")
	Image_SkyFrog1:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				local ScrollView_City = tolua.cast(wndInstance.rootWidget:getChildByName("ScrollView_City"), "ScrollView")
				local Panel_Inner = tolua.cast(ScrollView_City:getChildByName("Panel_Inner"), "Layout")
				local Image_SkyFrog1 = tolua.cast(Panel_Inner:getChildByName("Image_SkyFrog1"), "ImageView")
				g_CreateCircularMoveX(Image_SkyFrog1, -200, 2000, 455, 40, 0.95, 12, 100, 255, 10)
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_SkyFrog2 = tolua.cast(Panel_Inner:getChildByName("Image_SkyFrog2"), "ImageView")
	Image_SkyFrog2:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				local ScrollView_City = tolua.cast(wndInstance.rootWidget:getChildByName("ScrollView_City"), "ScrollView")
				local Panel_Inner = tolua.cast(ScrollView_City:getChildByName("Panel_Inner"), "Layout")
				local Image_SkyFrog2 = tolua.cast(Panel_Inner:getChildByName("Image_SkyFrog2"), "ImageView")
				g_CreateCircularSwingMove(Image_SkyFrog2, -400, 10, 0, 255)
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_SkyFrog3 = tolua.cast(Panel_Inner:getChildByName("Image_SkyFrog3"), "ImageView")
	Image_SkyFrog3:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				local ScrollView_City = tolua.cast(wndInstance.rootWidget:getChildByName("ScrollView_City"), "ScrollView")
				local Panel_Inner = tolua.cast(ScrollView_City:getChildByName("Panel_Inner"), "Layout")
				local Image_SkyFrog3 = tolua.cast(Panel_Inner:getChildByName("Image_SkyFrog3"), "ImageView")
				g_CreateCircularSwingMove(Image_SkyFrog3, 400, 10, 0, 255)
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_Frog2_1 = tolua.cast(ScrollView_City:getChildByName("Image_Frog2_1"), "ImageView")
	Image_Frog2_1:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				local ScrollView_City = tolua.cast(wndInstance.rootWidget:getChildByName("ScrollView_City"), "ScrollView")
				local Image_Frog2_1 = tolua.cast(ScrollView_City:getChildByName("Image_Frog2_1"), "ImageView")
				g_CreateCircularSwingMove(Image_Frog2_1, -400, 10, 0, 255)
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_Frog2_2 = tolua.cast(ScrollView_City:getChildByName("Image_Frog2_2"), "ImageView")
	Image_Frog2_2:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				local ScrollView_City = tolua.cast(wndInstance.rootWidget:getChildByName("ScrollView_City"), "ScrollView")
				local Image_Frog2_2 = tolua.cast(ScrollView_City:getChildByName("Image_Frog2_2"), "ImageView")
				g_CreateCircularSwingMove(Image_Frog2_2, 400, 10, 0, 255)
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_Frog2_3 = tolua.cast(ScrollView_City:getChildByName("Image_Frog2_3"), "ImageView")
	Image_Frog2_3:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				local ScrollView_City = tolua.cast(wndInstance.rootWidget:getChildByName("ScrollView_City"), "ScrollView")
				local Image_Frog2_3 = tolua.cast(ScrollView_City:getChildByName("Image_Frog2_3"), "ImageView")
				g_CreateCircularSwingMove(Image_Frog2_3, -400, 10, 0, 255)
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_Frog2_4 = tolua.cast(ScrollView_City:getChildByName("Image_Frog2_4"), "ImageView")
	Image_Frog2_4:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				local ScrollView_City = tolua.cast(wndInstance.rootWidget:getChildByName("ScrollView_City"), "ScrollView")
				local Image_Frog2_4 = tolua.cast(ScrollView_City:getChildByName("Image_Frog2_4"), "ImageView")
				g_CreateCircularSwingMove(Image_Frog2_4, 400, 10, 0, 255)
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_Frog2_5 = tolua.cast(ScrollView_City:getChildByName("Image_Frog2_5"), "ImageView")
	Image_Frog2_5:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				local ScrollView_City = tolua.cast(wndInstance.rootWidget:getChildByName("ScrollView_City"), "ScrollView")
				local Image_Frog2_5 = tolua.cast(ScrollView_City:getChildByName("Image_Frog2_5"), "ImageView")
				g_CreateCircularSwingMove(Image_Frog2_5, -400, 10, 0, 255)
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_Frog2_6 = tolua.cast(ScrollView_City:getChildByName("Image_Frog2_6"), "ImageView")
	Image_Frog2_6:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				local ScrollView_City = tolua.cast(wndInstance.rootWidget:getChildByName("ScrollView_City"), "ScrollView")
				local Image_Frog2_6 = tolua.cast(ScrollView_City:getChildByName("Image_Frog2_6"), "ImageView")
				g_CreateCircularSwingMove(Image_Frog2_6, 400, 10, 0, 255)
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_Frog3_1 = tolua.cast(ScrollView_City:getChildByName("Image_Frog3_1"), "ImageView")
	Image_Frog3_1:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				local ScrollView_City = tolua.cast(wndInstance.rootWidget:getChildByName("ScrollView_City"), "ScrollView")
				local Image_Frog3_1 = tolua.cast(ScrollView_City:getChildByName("Image_Frog3_1"), "ImageView")
				g_CreateCircularSwingMove(Image_Frog3_1, -400, 10, 0, 255)
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_Frog3_2 = tolua.cast(ScrollView_City:getChildByName("Image_Frog3_2"), "ImageView")
	Image_Frog3_2:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				local ScrollView_City = tolua.cast(wndInstance.rootWidget:getChildByName("ScrollView_City"), "ScrollView")
				local Image_Frog3_2 = tolua.cast(ScrollView_City:getChildByName("Image_Frog3_2"), "ImageView")
				g_CreateCircularSwingMove(Image_Frog3_2, 400, 10, 0, 255)
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_Frog3_3 = tolua.cast(ScrollView_City:getChildByName("Image_Frog3_3"), "ImageView")
	Image_Frog3_3:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				local ScrollView_City = tolua.cast(wndInstance.rootWidget:getChildByName("ScrollView_City"), "ScrollView")
				local Image_Frog3_3 = tolua.cast(ScrollView_City:getChildByName("Image_Frog3_3"), "ImageView")
				g_CreateCircularSwingMove(Image_Frog3_3, -1000, 16, 0, 255)
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_Frog3_4 = tolua.cast(self.Button_Building_TianBang:getChildByName("Image_Frog3_4"), "ImageView")
	Image_Frog3_4:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				if wndInstance.Button_Building_TianBang then
					local Image_Frog3_4 = tolua.cast(wndInstance.Button_Building_TianBang:getChildByName("Image_Frog3_4"), "ImageView")
					g_CreateCircularSwingMove(Image_Frog3_4, 400, 10, 0, 255)
				end
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_Frog3_5 = tolua.cast(ScrollView_City:getChildByName("Image_Frog3_5"), "ImageView")
	Image_Frog3_5:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				local ScrollView_City = tolua.cast(wndInstance.rootWidget:getChildByName("ScrollView_City"), "ScrollView")
				local Image_Frog3_5 = tolua.cast(ScrollView_City:getChildByName("Image_Frog3_5"), "ImageView")
				g_CreateCircularSwingMove(Image_Frog3_5, -600, 15, 0, 255)
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_Frog4 = tolua.cast(self.Button_Building_TianBang:getChildByName("Image_Frog4"), "ImageView")
	Image_Frog4:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				if wndInstance.Button_Building_TianBang then
					local Image_Frog4 = tolua.cast(wndInstance.Button_Building_TianBang:getChildByName("Image_Frog4"), "ImageView")
					g_CreateCircularSwingMove(Image_Frog4, 400, 10, 0, 255)
				end
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_Frog5 = tolua.cast(self.Button_Building_TianBang:getChildByName("Image_Frog5"), "ImageView")
	Image_Frog5:setOpacity(0)
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				if wndInstance.Button_Building_TianBang then
					local Image_Frog5 = tolua.cast(wndInstance.Button_Building_TianBang:getChildByName("Image_Frog5"), "ImageView")
					g_CreateCircularSwingMove(Image_Frog5, -400, 10, 0, 255)
				end
			end
		end
	)
	fTimeStep = fTimeStep + fTimeSpace
	local Image_People = tolua.cast(ScrollView_City:getChildByName("Image_People"), "ImageView")
	g_Timer:pushTimer(fTimeStep, function()
			local wndInstance = g_WndMgr:getWnd("Game_Home")
			if wndInstance then
				local ScrollView_City = tolua.cast(wndInstance.rootWidget:getChildByName("ScrollView_City"), "ScrollView")
				local Image_People = tolua.cast(ScrollView_City:getChildByName("Image_People"), "ImageView")
				g_CreateCircularMoveXY(Image_People, 160, -50, 3300, 500, 15, 0.98)
			end
		end
	)
	
	--浮空山动画
	local nOffsetY1 = 16
	local nOffsetY2 = 12
	local nOffsetY3 = 9
	local nOffsetY4 = 6
	local fMoveTime1 = 1.4
	local fMoveTime2 = 1.4
	local fMoveTime3 = 1.4
	local fMoveTime4 = 1.4
	local Image_Building14 = tolua.cast(ScrollView_City:getChildByName("Image_Building14"), "ImageView")
	g_CreateUpAndDownAnimation(Image_Building14, fMoveTime3, -nOffsetY3)
	
	local Button_Building_QianCengTa = tolua.cast(ScrollView_City:getChildByName("Button_Building_QianCengTa"), "Button")
	g_CreateUpAndDownAnimation(Button_Building_QianCengTa, fMoveTime1, nOffsetY1)
	
	local Button_Building_WorldBoss = tolua.cast(ScrollView_City:getChildByName("Button_Building_WorldBoss"), "Button")
	g_CreateUpAndDownAnimation(Button_Building_WorldBoss, fMoveTime2, -nOffsetY2)
	
	local Button_Building_JiHuiSuo = tolua.cast(ScrollView_City:getChildByName("Button_Building_JiHuiSuo"), "Button")
	g_CreateUpAndDownAnimation(Button_Building_JiHuiSuo, fMoveTime1, nOffsetY1)
	
	local Button_Building_ZhaoHuanTai = tolua.cast(ScrollView_City:getChildByName("Button_Building_ZhaoHuanTai"), "Button")
	g_CreateUpAndDownAnimation(Button_Building_ZhaoHuanTai, fMoveTime1, -nOffsetY1)

	local Button_Building_JuXianGe = tolua.cast(ScrollView_City:getChildByName("Button_Building_JuXianGe"), "Button")
	g_CreateUpAndDownAnimation(Button_Building_JuXianGe, fMoveTime1, nOffsetY1)

	local Button_Building19 = tolua.cast(ScrollView_City:getChildByName("Button_Building19"), "Button")
	g_CreateUpAndDownAnimation(Button_Building19, fMoveTime2, -nOffsetY2)

	local Image_Building16 = tolua.cast(ScrollView_City:getChildByName("Image_Building16"), "ImageView")
	g_CreateUpAndDownAnimation(Image_Building16, fMoveTime3, nOffsetY3)

	local Button_Building_JuBaoGe = tolua.cast(ScrollView_City:getChildByName("Button_Building_JuBaoGe"), "Button")
	g_CreateUpAndDownAnimation(Button_Building_JuBaoGe, fMoveTime3, -nOffsetY3)
	
	local Image_Building15 = tolua.cast(Panel_City2:getChildByName("Image_Building15"), "ImageView")
	g_CreateUpAndDownAnimation(Image_Building15, fMoveTime4, -nOffsetY4)

	local Image_Building18 = tolua.cast(Panel_City2:getChildByName("Image_Building18"), "ImageView")
	g_CreateUpAndDownAnimation(Image_Building18, fMoveTime4, nOffsetY4)
	
	self:refreshHomeStatusBar()
	g_SALMgr:creat()
	-- local nNum = 1
	-- local function checkDataMsgMgr(fd, bOver)
		-- if nNum == 1 then
			-- g_MsgMgr:requestAssistantRefresh()
		-- elseif nNum == 2 then
			-- g_MsgMgr:requestRewardInfo()
		-- else
			-- --成就
			-- -- g_MsgMgr:requestAchievementRefresh()
		-- end
		-- nNum = nNum + 1
	-- end
	-- g_Timer:pushLimtCountTimer(3, 0.05, checkDataMsgMgr)

    self.classContainer = ScrollView_City:getInnerContainer()
	self.Image_MainHomeUIPNL = tolua.cast(self.rootWidget:getChildByName("Image_MainHomeUIPNL"), "ImageView")
	self:showSystemBroadcast(_T("GM系统公告"))

	--检查在主界面的时候 如果
	g_FormMsgSystem:RegisterFormMsg(FormMsg_GameNotice_NoticeMainWnd, handler(self, self.ShowGameNotic))


    --add wb facebook邀请按钮
	local Button_Facebook = tolua.cast(self.Image_MainHomeUIPNL:getChildAllByName("Button_Facebook"), "Button")
	local Image_VietNam18 = tolua.cast(self.Image_MainHomeUIPNL:getChildAllByName("Image_VietNam18"), "ImageView")
    if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET then
        Button_Facebook:setVisible(g_bShowFacebook)
		Image_VietNam18:setVisible(true)
     else
        Button_Facebook:setVisible(false)
		Image_VietNam18:setVisible(false)
     end
    g_SetBtnWithPressImage(Button_Facebook, 1, onButton_FacebookInviet, true, 1)
end

function onButton_FacebookInviet()
    g_FacebookRewardSys:ShowInviteView()
end

function MainScene:ShowGameNotic()
	local context = g_GameNoticeSystem:GetFirstGameNotice()
	if context ~= nil and self.rootLayout:isVisible() then
		g_GameNoticeForm:ShowWinMianNotce(context.text)
	end
end
--卡牌伙伴
function MainScene:addNoticeAnimation_Member()
	if not g_CheckFuncCanOpenByWidgetName("Button_Main_Member") then
		return 0
	end

	local tbCard = g_Hero:GetCardsList()
	local bRet = nil
	for k, v in pairs(tbCard) do
		bRet = g_CheckCardUpgrade(v)
		if bRet then
			g_addUpgradeGuide(self.Button_Main_Member, ccp(35, -5), nil, true)
			return 1
		end
	end
	g_addUpgradeGuide(self.Button_Main_Member, ccp(35, -5), nil, false)
	return 0
end

function MainScene:addNoticeAnimation_Equip()
	if not g_CheckFuncCanOpenByWidgetName("Button_Main_Equip") then
		return 0
	end

	local tbCard = g_Hero:GetCardsList()
	local bRet = nil
	for k, v in pairs(tbCard) do
		bRet = g_CheckCardEquip(v)
		if bRet then
			g_addUpgradeGuide(self.Button_Main_Equip, ccp(35, -5), nil, true)
			return 1
		end
	end
	
	g_addUpgradeGuide(self.Button_Main_Equip, ccp(35, -5), nil, false)
	return 0
end

function MainScene:addNoticeAnimation_JueXing()
	if not g_CheckFuncCanOpenByWidgetName("Button_Main_XianMai") then
		return 0
	end
	
	if g_CheckJueXing() then
		g_addUpgradeGuide(self.Button_Main_XianMai, ccp(35, -5), nil, true)
		return 1
	end

	g_addUpgradeGuide(self.Button_Main_XianMai, ccp(35, -5), nil, false)
	return 0
end

function MainScene:addNoticeAnimation_QiShu()
	if not g_CheckFuncCanOpenByWidgetName("Button_Main_QiShu") then
		return 0
	end
	
	 if g_CheckQiShu() then
		g_addUpgradeGuide(self.Button_Main_QiShu, ccp(35, -5), nil, true)
		return 1
	end
	
	g_addUpgradeGuide(self.Button_Main_QiShu, ccp(35, -5), nil, false)
    return 0
end

function MainScene:addNoticeAnimation_Fate()
	if not g_CheckFuncCanOpenByWidgetName("Button_Main_YiShou") then
		return 0
	end

	if g_CheckCardFateUpgrade() then
		g_addUpgradeGuide(self.Button_Main_YiShou, ccp(35, -5), nil, true)
		return 1
	end

	g_addUpgradeGuide(self.Button_Main_YiShou, ccp(35, -5), nil, false)
	return 0
end

function MainScene:addNoticeAnimation_ShangXiang()
	if not g_CheckFuncCanOpenByWidgetName("Button_Main_ShangXiang") then
		return 0
	end
	
	if g_CheckShangXiang() then
		g_addUpgradeGuide(self.Button_Main_ShangXiang, ccp(35, -5), nil, true)
		return 1
	end

	g_addUpgradeGuide(self.Button_Main_ShangXiang, ccp(35, -5), nil, false)
	return 0
end

function MainScene:addNoticeAnimation_Container()
    local function setNoticeVisibleState(widgetBtn, bVisible)
        if widgetBtn then
            local CCNode_Notice = widgetBtn:getNodeByTag(1)
            if CCNode_Notice then
                CCNode_Notice:setVisible(bVisible)
            end
        end
    end

    local Image_MainHomeUIPNL = self.rootWidget:getChildByName("Image_MainHomeUIPNL")
    local Image_MainFunctionPNL = Image_MainHomeUIPNL:getChildByName("Image_MainFunctionPNL")
    local Image_ContainerCover = Image_MainFunctionPNL:getChildByName("Image_ContainerCover")
	local Image_Notes_Container = g_SetBubbleNotify(Image_ContainerCover, self.nMaxNotcieCount, 30, 30)
	if not self.bIsAllReadyExpand  then--收起
        if Image_Notes_Container then Image_Notes_Container:setVisible(true) end
        setNoticeVisibleState(self.Button_Main_Member, false)
        setNoticeVisibleState(self.Button_Main_Equip, false)
        setNoticeVisibleState(self.Button_Main_XianMai, false)
		setNoticeVisibleState(self.Button_Main_QiShu, false)
		setNoticeVisibleState(self.Button_Main_ShangXiang, false)
        setNoticeVisibleState(self.Button_Main_YiShou, false)
    else--展开
        if Image_Notes_Container then Image_Notes_Container:setVisible(false) end
        setNoticeVisibleState(self.Button_Main_Member, true)
		 setNoticeVisibleState(self.Button_Main_Equip, true)
		 setNoticeVisibleState(self.Button_Main_XianMai, true)
        setNoticeVisibleState(self.Button_Main_QiShu, true)
		setNoticeVisibleState(self.Button_Main_ShangXiang, false)
        setNoticeVisibleState(self.Button_Main_YiShou, true)
    end
end

--药园
function MainScene:addNoticeAnimation_Farm()
	if not g_CheckFuncCanOpenByWidgetName("Button_Building_Farm") then
		return
	end
	
	if g_FarmData:getFarmRefresh() then
		local Image_FuncName = tolua.cast(self.Button_Building_Farm:getChildByName("Image_FuncName"), "ImageView")
		local Image_FuncName = tolua.cast(Image_FuncName:getChildByName("Image_FuncName"), "ImageView")
		local x = Image_FuncName:getSize().width / 2 + 25
		g_SetBubbleNotify(Image_FuncName, g_CheckFarmByStatusNum(), x, -1)
	end
	
end

-- 猎命
function MainScene:addNoticeAnimation_HuntFate()
	if not g_CheckFuncCanOpenByWidgetName("Button_Building_LianYaoTa") then
		return
	end
	
	local Image_FuncName = tolua.cast(self.Button_Building_LianYaoTa:getChildByName("Image_FuncName"), "ImageView")
	local Image_FuncName = tolua.cast(Image_FuncName:getChildByName("Image_FuncName"), "ImageView")
	local x = Image_FuncName:getSize().width / 2 + 25
	g_SetBubbleNotify(Image_FuncName, g_GetNoticeNum_HuntFate(), x, -1)
end

-- 召唤台
function MainScene:addNoticeAnimation_Summon()
	if not g_CheckFuncCanOpenByWidgetName("Button_Building_ZhaoHuanTai") then
		return
	end
	
	if g_Hero.tabSummonCardInfo then
		local Image_FuncName = tolua.cast(self.Button_Building_ZhaoHuanTai:getChildByName("Image_FuncName"), "ImageView")
		local Image_FuncName = tolua.cast(Image_FuncName:getChildByName("Image_FuncName"), "ImageView")
		local x = Image_FuncName:getSize().width / 2 + 25
		g_SetBubbleNotify(Image_FuncName, g_GetNoticeNum_ZhaoHuanTai(), x, -1)
	end
end

-- 竞技场（天榜）
function MainScene:addNoticeAnimation_TianBang()
	if not g_CheckFuncCanOpenByWidgetName("Button_SubBuilding_TianBang2") then
		return
	end
	
	local Image_FuncName2 = tolua.cast(self.Button_Building_TianBang:getChildByName("Image_FuncName2"), "ImageView")
	local Image_FuncName = tolua.cast(Image_FuncName2:getChildByName("Image_FuncName"), "ImageView")
	local x = Image_FuncName:getSize().width / 2 + 25
	g_SetBubbleNotify(Image_FuncName, g_Hero:getArenaTimes(), x, -1)
end

-- 福禄岛
function MainScene:addNoticeAnimation_FuLuShan()
	if not g_CheckFuncCanOpenByWidgetName("Button_Building_FuLuShan") then
		return
	end
	
	local Image_FuncName = tolua.cast(self.Button_Building_FuLuShan:getChildByName("Image_FuncName"), "ImageView")
	local Image_FuncName = tolua.cast(Image_FuncName:getChildByName("Image_FuncName"), "ImageView")
	local x = Image_FuncName:getSize().width / 2 + 25
	g_SetBubbleNotify(Image_FuncName, g_GetNoticeNum_FuLuDao(), x, -1)
end

-- 试炼山
function MainScene:addNoticeAnimation_ShiLianShan()
	if not g_CheckFuncCanOpenByWidgetName("Button_Building_ShiLianShan") then
		return
	end
	
	local Image_FuncName = tolua.cast(self.Button_Building_ShiLianShan:getChildByName("Image_FuncName"), "ImageView")
	local Image_FuncName = tolua.cast(Image_FuncName:getChildByName("Image_FuncName"), "ImageView")
	local x = Image_FuncName:getSize().width / 2 + 25
	g_SetBubbleNotify(Image_FuncName, g_GetNoticeNum_ShiLianShan(), x, -1)
end

-- 聚仙阁
function MainScene:addNoticeAnimation_JuXianGe()
	if not g_CheckFuncCanOpenByWidgetName("Button_Building_JuXianGe") then
		return
	end
	
	local Image_FuncName = tolua.cast(self.Button_Building_JuXianGe:getChildByName("Image_FuncName"), "ImageView")
	local Image_FuncName = tolua.cast(Image_FuncName:getChildByName("Image_FuncName"), "ImageView")
	local x = Image_FuncName:getSize().width / 2 + 25
	g_SetBubbleNotify(Image_FuncName, g_GetNoticeNum_JuXianGe(), x, -1)
end

-- 聚宝阁
function MainScene:addNoticeAnimation_JuBaoGe()
	if not g_CheckFuncCanOpenByWidgetName("Button_Building_JuBaoGe") then
		return
	end
	
	local Image_FuncName = tolua.cast(self.Button_Building_JuBaoGe:getChildByName("Image_FuncName"), "ImageView")
	local Image_FuncName = tolua.cast(Image_FuncName:getChildByName("Image_FuncName"), "ImageView")
	local x = Image_FuncName:getSize().width / 2 + 25
	g_SetBubbleNotify(Image_FuncName, g_GetNoticeNum_JuBaoGe(), x, -1)
end

-- 小助手
function MainScene:addNoticeAnimation_Assistant()
	if not g_CheckFuncCanOpenByWidgetName("Button_Assistant") then
		return
	end
	
	--助手泡泡
	g_Hero.bubbleNotify = g_Hero.bubbleNotify or {}	
	
	g_SetBubbleNotify(self.Button_Assistant, g_GetNoticeNum_Assistant(), 20, 20, 1.25)
end

-- 运营活动
function MainScene:addNoticeAnimation_ActivityCenter()
	if not g_CheckFuncCanOpenByWidgetName("Button_HuoDong") then
		return
	end

	g_SetBubbleNotify(self.Button_HuoDong, g_GetNoticeNum_ActivityCenter(), 20, 20, 1.25)
end

-- 招财
function MainScene:addNoticeAnimation_ZhaoCai()
	if not g_CheckFuncCanOpenByWidgetName("Button_ZhaoCai") then
		return
	end
	
	g_SetBubbleNotify(self.Button_ZhaoCai, g_GetNoticeNum_ZhaoCai(), 20, 20, 1.25)
end

-- 签到
function MainScene:addNoticeAnimation_QianDao()
	if not g_CheckFuncCanOpenByWidgetName("Button_QianDao") then
		return
	end

	g_SetBubbleNotify(self.Button_QianDao, g_GetNoticeNum_Register(), 20, 20, 1.25)
end

-- 首充礼包
function MainScene:addNoticeAnimation_FirstCharge()
	if not g_CheckFuncCanOpenByWidgetName("Button_FirstCharge") then
		return
	end

	g_SetBubbleNotify(self.Button_FirstCharge, g_GetNoticeNum_FirstCharge(), 20, 20, 1.25)
end

-- 在线奖励
function MainScene:addNoticeAnimation_OnLineReward()
	if not g_CheckFuncCanOpenByWidgetName("Button_OnLineReward") then
		return
	end

	g_SetBubbleNotify(self.Button_OnLineReward, g_GetNoticeNum_OnLineReward(), 20, 20, 1.25)
end

-- 开服狂欢
function MainScene:addNoticeAnimation_JiaNianHua()
	if not g_CheckFuncCanOpenByWidgetName("Button_JiaNianHua") then
		return
	end

	g_SetBubbleNotify(self.Button_JiaNianHua, g_GetNoticeNum_JiaNianHua(), 20, 20, 1.25)
end

-- 聊天
function MainScene:addNoticeAnimation_ChatCenter()
	if not g_CheckFuncCanOpenByWidgetName("Button_ChatCenter") then
		return
	end
	
	g_SetBubbleNotify(self.Button_ChatCenter, g_GetNoticeNum_ChatCenter(), 20, 20, 1.25)
end

-- 好友
function MainScene:addNoticeAnimation_Friend()
	if not g_CheckFuncCanOpenByWidgetName("Button_Friend") then
		return
	end
	
	g_SetBubbleNotify(self.Button_Friend, g_GetNoticeNum_Friend(), 20, 20, 1.25)
end

-- 帮派
function MainScene:addNoticeAnimation_Group()
	if not g_CheckFuncCanOpenByWidgetName("Button_Group") then
		return
	end
	
	if g_Guild.buildingInfo_ and next( g_Guild.buildingInfo_) ~= nil then 
		local num = g_GetNoticeNum_GroupJinXinZhai() +  g_GetNoticeNum_GroupWanBaoLou()
		+ g_GetNoticeNum_GroupShuHuaYuan() + g_GetNoticeNum_GroupSkillBuild(macro_pb.GuildBuildType_Lianshenta)
		+  g_GetNoticeNum_GroupSkillBuild(macro_pb.GuildBuildType_Jingangtang) + g_GetNoticeNum_GroupSkillBuild( macro_pb.GuildBuildType_Shenbingdian)
		+ g_GetNoticeNum_Activity()
		-- echoj("===============================",g_GetNoticeNum_Activity())
		g_SetBubbleNotify(self.Button_Group, num, 20, 20, 1.25) 
	else
		g_SetBubbleNotify(self.Button_Group, g_GetNoticeNum_Group(), 20, 20, 1.25)
	end
end


-- 邮件
function MainScene:addNoticeAnimation_Mail()
	if not g_CheckFuncCanOpenByWidgetName("Button_Mail") then
		return
	end

	g_SetBubbleNotify(self.Button_Mail, g_GetNoticeNum_Mail(), 20, 20, 1.25)
end

-- 爱心转盘
function MainScene:addNoticeAnimation_Turntable()
	if not g_CheckFuncCanOpenByWidgetName("Button_Turntable") then
		return
	end
	g_SetBubbleNotify(self.Button_Turntable, g_GetNoticeNum_Turntable(), 20, 20, 1.25)
end

--跨服天榜
function MainScene:addNoticeAnimation_ArenaKuaFu()
	if not g_CheckFuncCanOpenByWidgetName("Button_SubBuilding_TianBang1") then
		return
	end
	
	if eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() or eLanguageVer.LANGUAGE_zh_AUDIT == g_LggV:getLanguageVer() then
		local Image_FuncName1 = tolua.cast(self.Button_Building_TianBang:getChildByName("Image_FuncName1"), "ImageView")
		local Image_FuncName = tolua.cast(Image_FuncName1:getChildByName("Image_FuncName"), "ImageView")
		local x = Image_FuncName:getSize().width / 2 + 25
		g_SetBubbleNotify(Image_FuncName, 0, x, -1)
	else
		local daySum = g_DataMgr:getGlobalCfgCsv("kuafu_arena_open_day")
		if g_Hero:getTotalSysDays() < daySum then 
			local Image_FuncName1 = tolua.cast(self.Button_Building_TianBang:getChildByName("Image_FuncName1"), "ImageView")
			local Image_FuncName = tolua.cast(Image_FuncName1:getChildByName("Image_FuncName"), "ImageView")
			local x = Image_FuncName:getSize().width / 2 + 25
			g_SetBubbleNotify(Image_FuncName, 0, x, -1)
		else
			local Image_FuncName1 = tolua.cast(self.Button_Building_TianBang:getChildByName("Image_FuncName1"), "ImageView")
			local Image_FuncName = tolua.cast(Image_FuncName1:getChildByName("Image_FuncName"), "ImageView")
			local x = Image_FuncName:getSize().width / 2 + 25
			g_SetBubbleNotify(Image_FuncName, g_GetNoticeNum_ArenaKuaFu(), x, -1)
		end
	end
end

function MainScene:refreshNoticeAnimation()
	g_Hero.bNoticeDataOK = true
	self.nMaxNotcieCount = 0

	--伙伴
	self.nMaxNotcieCount = self.nMaxNotcieCount + self:addNoticeAnimation_Member()
	--装备
	self.nMaxNotcieCount = self.nMaxNotcieCount + self:addNoticeAnimation_Equip()
	--骑术
	self.nMaxNotcieCount = self.nMaxNotcieCount  + self:addNoticeAnimation_QiShu()
	--觉醒
	self.nMaxNotcieCount = self.nMaxNotcieCount  + self:addNoticeAnimation_JueXing()
	--上香
	self.nMaxNotcieCount = self.nMaxNotcieCount  + self:addNoticeAnimation_ShangXiang()
    --异兽
    self.nMaxNotcieCount = self.nMaxNotcieCount  + self:addNoticeAnimation_Fate()
	
	
	--八卦容器
    self:addNoticeAnimation_Container()

	--药园
	self:addNoticeAnimation_Farm()
	--猎命
	self:addNoticeAnimation_HuntFate()
	--召唤台
	self:addNoticeAnimation_Summon()
	--福禄山
	self:addNoticeAnimation_FuLuShan()
	--试炼岛
	self:addNoticeAnimation_ShiLianShan()
	--聚仙阁
	self:addNoticeAnimation_JuXianGe()
	--聚宝阁
	self:addNoticeAnimation_JuBaoGe()
	-- 竞技场（天榜）
	self:addNoticeAnimation_TianBang()
	
	--小助手
	self:addNoticeAnimation_Assistant()
	--运营互动
	self:addNoticeAnimation_ActivityCenter()
	--招财
	self:addNoticeAnimation_ZhaoCai()
	--签到
	self:addNoticeAnimation_QianDao()
	--首充
	self:addNoticeAnimation_FirstCharge()
	--开服狂欢
	self:addNoticeAnimation_OnLineReward()
	--签到
	self:addNoticeAnimation_JiaNianHua()
	
	--聊天
	self:addNoticeAnimation_ChatCenter()
	--好友
	self:addNoticeAnimation_Friend()
	--帮派
	self:addNoticeAnimation_Group()
	--邮件
	self:addNoticeAnimation_Mail()
	--爱心转盘
	self:addNoticeAnimation_Turntable()
	
	--跨服天榜
	self:addNoticeAnimation_ArenaKuaFu()
	
end

-- 右下按钮功能开启Action
function MainScene:showMainButtonOpenAction(widegtGuideBtn, strOpenFuncIcon, funcShowNextGuide)
	if self.Button_Container:getRotation() == 0 then
		self:runExpandAction(funcShowNextGuide)
	else
		local function runExpandActionAgain()
			self:runExpandAction(funcShowNextGuide)
		end
		self:runExpandAction(runExpandActionAgain)
	end
end

function MainScene:centerBuildingPosition(widegtBtn, funcShowNextGuide)	
	local nPosX = widegtBtn:getPositionX()
	if nPosX > 640 then
		nPosX = 640 - nPosX
		local tbSize = self.classContainer:getSize()
		if nPosX < 1280 - tbSize.width then
			nPosX = 1280 - tbSize.width
		end
		self.classContainer:setPositionXY(nPosX, 0)
	else
		nPosX = 0
		self.classContainer:setPositionXY(0, 0)
	end
	
	local fRate1 = 0.9
	local fRate2 = 0.9
	local fRate3 = 0.8
	local fRate4 = 0.7
	local nWidth1 = math.floor(3195*fRate1)
	local nWidth2 = math.floor(3195*fRate2)
	local nWidth3 = math.floor(3195*fRate3)
	local nWidth4 = math.floor(3195*fRate4)
	local ScrollView_City = tolua.cast(self.rootLayout:getChildByName("ScrollView_City"), "ScrollView")
	local Panel_Inner = tolua.cast(ScrollView_City:getChildByName("Panel_Inner"), "Layout")
	local Button_Building_ShiLianShan = tolua.cast(ScrollView_City:getChildByName("Button_Building_ShiLianShan"),"Button")
	local Panel_City1 = tolua.cast(self.rootLayout:getChildByName("Panel_City1"), "Layout")
	local Panel_City2 = tolua.cast(self.rootLayout:getChildByName("Panel_City2"), "Layout")
	local Panel_City3 = tolua.cast(self.rootLayout:getChildByName("Panel_City3"), "Layout")


	Panel_Inner:setPositionX(self.nPosInnerX-nPosX*(1-fRate1))
	Button_Building_ShiLianShan:setPositionX(self.nPosShiLianShanX-nPosX*(1-fRate1))
	Panel_City1:setPositionX(math.max(nPosX*fRate2, -nWidth2))
	Panel_City2:setPositionX(math.max(nPosX*fRate3, -nWidth3))
	Panel_City3:setPositionX(math.max(nPosX*fRate4, -nWidth4))
	
	if funcShowNextGuide then
		funcShowNextGuide()
	end
end

function MainScene:showHomeFunctionOpenAction(strGuideWidgetName, strOpenFuncIcon, funcShowNextGuide)
	local widegtGuideBtn = nil
	if strGuideWidgetName == "Button_Assistant" then	--小助手、仙脉
		widegtGuideBtn = self.Button_Assistant
		if funcShowNextGuide then
			funcShowNextGuide()
		end
		return
	elseif strGuideWidgetName == "Button_ZhaoCai" then	--招财
		widegtGuideBtn = self.Button_ZhaoCai
		if funcShowNextGuide then
			funcShowNextGuide()
		end
		return
	elseif strGuideWidgetName == "Button_Turntable" then	--好友、转盘
		widegtGuideBtn = self.Button_Turntable
		if funcShowNextGuide then
			funcShowNextGuide()
		end
		return
	elseif strGuideWidgetName == "Button_Friend" then	--好友、转盘
		widegtGuideBtn = self.Button_Friend
		if funcShowNextGuide then
			funcShowNextGuide()
		end
		return
	elseif strGuideWidgetName == "Button_Group" then	--帮派
		widegtGuideBtn = self.Button_Group
		if funcShowNextGuide then
			funcShowNextGuide()
		end
		return
	elseif strGuideWidgetName == "Button_JingYingFuBen" then	--招财
		widegtGuideBtn = self.Button_Ectype
		if funcShowNextGuide then
			funcShowNextGuide()
		end
		return
	elseif strGuideWidgetName == "Button_JingJie" then	--渡劫
		widegtGuideBtn = self.Button_Main_Member
		self:showMainButtonOpenAction(widegtGuideBtn, strOpenFuncIcon, funcShowNextGuide)
		return
	elseif strGuideWidgetName == "Button_ChongZhu"
		or strGuideWidgetName == "Button_Strengthen"
		or strGuideWidgetName == "Button_Refine"
		or strGuideWidgetName == "Button_EquipStarUp"
		or strGuideWidgetName == "Button_Main_Equip"
	then	--装备重铸
		widegtGuideBtn = self.Button_Main_Equip
		self:showMainButtonOpenAction(widegtGuideBtn, strOpenFuncIcon, funcShowNextGuide)
		return
	elseif strGuideWidgetName == "Button_Main_XianMai" then	--仙脉
		widegtGuideBtn = self.Button_Main_XianMai
		self:showMainButtonOpenAction(widegtGuideBtn, strOpenFuncIcon, funcShowNextGuide)
		return
	elseif strGuideWidgetName == "Button_Main_ShangXiang" then	--上香
		widegtGuideBtn = self.Button_Main_ShangXiang
		self:showMainButtonOpenAction(widegtGuideBtn, strOpenFuncIcon, funcShowNextGuide)
		return
	elseif strGuideWidgetName == "Button_ZhenFa"
		or strGuideWidgetName == "Button_XinFa"
		or strGuideWidgetName == "Button_ZhanShu"
		or strGuideWidgetName == "Button_Main_QiShu"
	then	--奇术
		widegtGuideBtn = self.Button_Main_QiShu
		self:showMainButtonOpenAction(widegtGuideBtn, strOpenFuncIcon, funcShowNextGuide)
		return
	elseif strGuideWidgetName == "Button_Main_YiShou" then	--异兽
		widegtGuideBtn = self.Button_Main_YiShou
		self:showMainButtonOpenAction(widegtGuideBtn, strOpenFuncIcon, funcShowNextGuide)
		return
	elseif strGuideWidgetName == "Button_Building_LianYaoTa" then	--猎命建筑
		widegtGuideBtn = self.Button_Building_LianYaoTa
		self:centerBuildingPosition(widegtGuideBtn, funcShowNextGuide)
		return
	elseif strGuideWidgetName == "Button_SubBuilding_TianBang1"
		or strGuideWidgetName == "Button_SubBuilding_TianBang2"
	then	--竞技场相关
		widegtGuideBtn = self.Button_Building_TianBang
		self:centerBuildingPosition(widegtGuideBtn, funcShowNextGuide)
		return
	elseif strGuideWidgetName == "Button_Building_Farm" then	--农场建筑
		widegtGuideBtn = self.Button_Building_Farm
		self:centerBuildingPosition(widegtGuideBtn, funcShowNextGuide)
		return
	elseif strGuideWidgetName == "Button_JuBaoGePNL1"
		or strGuideWidgetName == "Button_JuBaoGePNL2"
		or strGuideWidgetName == "Button_Building_JuBaoGe"
	then
		widegtGuideBtn = self.Button_Building_JuBaoGe
		self:centerBuildingPosition(widegtGuideBtn, funcShowNextGuide)
		return
	elseif strGuideWidgetName == "Button_ActivityJuXianGePNL1"
		or strGuideWidgetName == "Button_ActivityJuXianGePNL2"
		or strGuideWidgetName == "Button_Building_JuXianGe"
	then
		widegtGuideBtn = self.Button_Building_JuXianGe
		self:centerBuildingPosition(widegtGuideBtn, funcShowNextGuide)
		return
		elseif strGuideWidgetName == "Button_Building_ShiLianShan"
		or strGuideWidgetName == "Button_ActivityShiLianShanPNL1"
		or strGuideWidgetName == "Button_ActivityShiLianShanPNL2"
		or strGuideWidgetName == "Button_ActivityShiLianShanPNL3"
	then --试炼山建筑
		widegtGuideBtn = self.Button_Building_ShiLianShan
		self:centerBuildingPosition(widegtGuideBtn, funcShowNextGuide)
		return
	elseif strGuideWidgetName == "Button_Building_FuLuShan"
		or strGuideWidgetName == "Button_FuLuDaoActivityPNL1"
		or strGuideWidgetName == "Button_FuLuDaoActivityPNL2"
		or strGuideWidgetName == "Button_FuLuDaoActivityPNL3"
	then --福禄山建筑
		widegtGuideBtn = self.Button_Building_FuLuShan
		self:centerBuildingPosition(widegtGuideBtn, funcShowNextGuide)
		return
	end
	
	cclog("===========没有配置功能引导按钮在主界面的回调函数==============")
end

function MainScene:showMainHomeZoomInAnimation(fMaxScale)
	local arrAct = CCArray:create()
	local action_ScaleTo = CCScaleTo:create(0.15, 1.6)
	local action_MoveTo = CCMoveTo:create(0.15, ccp(640,380))
	local action_Spwan = CCSpawn:createWithTwoActions(action_ScaleTo, action_MoveTo)
	local action_SpwanEase = CCEaseOut:create(action_Spwan, 1)
	arrAct:addObject(action_SpwanEase)
	arrAct:addObject(CCDelayTime:create(0.15))
	local actionSequence = CCSequence:create(arrAct)
	self.Image_MainHomeUIPNL:runAction(actionSequence)
end

function MainScene:showMainHomeZoomOutAnimation()
	local arrAct = CCArray:create()
	local action_ScaleTo = CCScaleTo:create(0.15, 1)
	local action_MoveTo = CCMoveTo:create(0.15, ccp(640,360))
	local action_Spwan = CCSpawn:createWithTwoActions(action_ScaleTo, action_MoveTo)
	local action_SpwanEase = CCEaseOut:create(action_Spwan, 2)
	--arrAct:addObject(CCDelayTime:create(0.15))
	arrAct:addObject(action_SpwanEase)
	local actionSequence = CCSequence:create(arrAct)
	self.Image_MainHomeUIPNL:runAction(actionSequence)
end

local function registerKeypadLayer()
	local pLayer = CCLayer:create()
    pLayer:setKeypadEnabled(true)

    local function KeypadHandler(strEvent)
    	if "backClicked" == strEvent then
			cclog("BACK clicked!"..g_Cfg.Platform )
    	elseif "menuClicked" == strEvent then
    	end
    end

    local filename = "LuaScripts/Refresh"
	package.loaded[filename] = nil
	require(filename)
    pLayer:registerScriptKeypadHandler(KeypadHandler)
    return pLayer
end

function MainScene:showPlayerGuide()
    if(g_nForceGuideMaxID <= 0) then return end

	if g_Hero.nPlayerGuideId > g_nForceGuideMaxID and g_Hero.nPlayerGuideId > 205 then
		if not g_PlayerGuide:checkIsInGuide() then
			local nGuideID, nGuideIndex = g_PlayerGuide:showNextEctypeGuide1()
			if nGuideID > 0 and nGuideIndex > 0 then
				if g_PlayerGuide:setCurrentGuideSequence(nGuideID, nGuideIndex) then
					g_PlayerGuide:showCurrentGuideSequenceNode()
				end
			end
		else
			if (g_PlayerGuide:checkIsInGuide() == 10)
				or (g_PlayerGuide:checkIsInGuide() == 11)
				or (g_PlayerGuide:checkIsInGuide() == 12)
				or (g_PlayerGuide:checkIsInGuide() == 13)
				or (g_PlayerGuide:checkIsInGuide() == 14)
				or (g_PlayerGuide:checkIsInGuide() == 15)
				or (g_PlayerGuide:checkIsInGuide() == 16)
			then
				local nGuideID, nGuideIndex = g_PlayerGuide:showNextEctypeGuide1()
				if nGuideID > 0 and nGuideIndex > 0 then
					if g_PlayerGuide:setCurrentGuideSequence(nGuideID, nGuideIndex) then
						g_PlayerGuide:showCurrentGuideSequenceNode()
					end
				end
			end
		end
		return
	end
	
	local nGuideID, nGuideIndex = g_PlayerGuide:checkServerGuideState()
	if nGuideID == 0 or nGuideIndex == 0 then
		if g_PlayerGuide:checkIsInGuide() and g_PlayerGuide:checkIsInGuide() <= g_nForceGuideMaxID then
			g_PlayerGuide:destroyGuide()
		end
		return
	end
	
	-- local nGuideIdChecked, nGuideIndexChecked = g_PlayerGuide:checkDataLogic(nGuideID, nGuideIndex)
	if g_PlayerGuide:setCurrentGuideSequence(nGuideID, nGuideIndex) then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end

function MainScene:ctor()
    mainWnd = self

    -- 关闭Lua自动回收机制, 以免出现不定时到卡, 交给窗口管理器去调用
    collectgarbage("collect")
    collectgarbage("stop")
    g_LuaMemoryCount = collectgarbage("count") / 1024 -- Lua堆栈的内存, MB

	local function onEnterOrExit(tag)
		if tag == "enter" then
			g_playSoundMusic(g_GameMusic, true)
          --  if g_Cfg.Platform  == kTargetWindows then
				self:addChild(registerKeypadLayer())
           -- end
		self:setCityToCenter()
		self:showPlayerGuide()
		elseif tag == "exit" then

		end
	end
	self:registerScriptHandler(onEnterOrExit)
end

--add by zgj
function MainScene:setCityToCenter()
	local nPosX = -1160
	local fRate1 = 0.9
	local fRate2 = 0.9
	local fRate3 = 0.8
	local fRate4 = 0.7
	local nWidth1 = math.floor(3195*fRate1)
	local nWidth2 = math.floor(3195*fRate2)
	local nWidth3 = math.floor(3195*fRate3)
	local nWidth4 = math.floor(3195*fRate4)
	local ScrollView_City = tolua.cast(self.rootLayout:getChildByName("ScrollView_City"), "ScrollView")
	local Panel_Inner = tolua.cast(ScrollView_City:getChildByName("Panel_Inner"), "Layout")
	local Button_Building_ShiLianShan = tolua.cast(ScrollView_City:getChildByName("Button_Building_ShiLianShan"),"Button")
	local Panel_City1 = tolua.cast(self.rootLayout:getChildByName("Panel_City1"), "Layout")
	local Panel_City2 = tolua.cast(self.rootLayout:getChildByName("Panel_City2"), "Layout")
	local Panel_City3 = tolua.cast(self.rootLayout:getChildByName("Panel_City3"), "Layout")

	self.nPosInnerX = Panel_Inner:getPositionX()
	self.nPosShiLianShanX = Button_Building_ShiLianShan:getPositionX()
	self.classContainer:setPositionX(nPosX)
	Panel_Inner:setPositionX(self.nPosInnerX-nPosX*(1-fRate1))
	Button_Building_ShiLianShan:setPositionX(self.nPosShiLianShanX-nPosX*(1-fRate1))
	Panel_City1:setPositionX(math.max(nPosX*fRate2, -nWidth2))
	Panel_City2:setPositionX(math.max(nPosX*fRate3, -nWidth3))
	Panel_City3:setPositionX(math.max(nPosX*fRate4, -nWidth4))
end

function MainScene:ModifyWnd_viet_VIET()
    local Image_MainHomeUIPNL = tolua.cast(self.rootLayout:getChildByName("Image_MainHomeUIPNL"), "ImageView")
	local Button_PlayerInfo = tolua.cast(Image_MainHomeUIPNL:getChildByName("Button_PlayerInfo"), "Button")
    local Image_ZhanDouLi = tolua.cast(Button_PlayerInfo:getChildAllByName("Image_ZhanDouLi"), "ImageView")
	local BitmapLabel_TeamStrength = tolua.cast(Button_PlayerInfo:getChildAllByName("BitmapLabel_TeamStrength"), "LabelBMFont")
    g_AdjustWidgetsPosition({Image_ZhanDouLi, BitmapLabel_TeamStrength},4)
end