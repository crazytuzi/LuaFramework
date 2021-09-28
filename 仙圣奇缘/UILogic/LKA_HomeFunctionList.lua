--------------------------------------------------------------------------------------
-- 文件名:	Game_HomeFunctionList.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_HomeFunctionList = class("Game_HomeFunctionList")
Game_HomeFunctionList.__index = Game_HomeFunctionList

function Game_HomeFunctionList:updateWnd()
	local Image_HomeFunctionListPNL = tolua.cast(self.rootWidget:getChildByName("Image_HomeFunctionListPNL"),"ImageView")
	local Image_PlayerInfoPNL = tolua.cast(Image_HomeFunctionListPNL:getChildByName("Image_PlayerInfoPNL"),"ImageView")
	local ListView_ResourceInfo = tolua.cast(Image_PlayerInfoPNL:getChildByName("ListView_ResourceInfo"),"ListView")
	
	local Image_ResourceInfoPNL1 = tolua.cast(ListView_ResourceInfo:getChildByName("Image_ResourceInfoPNL1"),"ImageView")
	local Button_Energy = tolua.cast(Image_ResourceInfoPNL1:getChildByName("Button_Energy"),"Button")
	local Button_YuanBao = tolua.cast(Image_ResourceInfoPNL1:getChildByName("Button_YuanBao"),"Button")
	local Button_TongQian = tolua.cast(Image_ResourceInfoPNL1:getChildByName("Button_TongQian"),"Button")
	
	
	local Image_ResourceInfoPNL2 = tolua.cast(ListView_ResourceInfo:getChildByName("Image_ResourceInfoPNL2"),"ImageView")
	local Button_XueShi = tolua.cast(Image_ResourceInfoPNL2:getChildByName("Button_XueShi"),"Button")
	local Button_DragonBall = tolua.cast(Image_ResourceInfoPNL2:getChildByName("Button_DragonBall"),"Button")
	local Button_Prestige = tolua.cast(Image_ResourceInfoPNL2:getChildByName("Button_Prestige"),"Button")
	
	local Image_ResourceInfoPNL3 = tolua.cast(ListView_ResourceInfo:getChildByName("Image_ResourceInfoPNL3"),"ImageView")
	local Button_Incense = tolua.cast(Image_ResourceInfoPNL3:getChildByName("Button_Incense"),"Button")
	local Button_Elements = tolua.cast(Image_ResourceInfoPNL3:getChildByName("Button_Elements"),"Button")
	local Button_JiangHunShi = tolua.cast(Image_ResourceInfoPNL3:getChildByName("Button_JiangHunShi"),"Button")
	
	local Image_ResourceInfoPNL4 = tolua.cast(ListView_ResourceInfo:getChildByName("Image_ResourceInfoPNL4"),"ImageView")
	local Button_RefreshToken = tolua.cast(Image_ResourceInfoPNL4:getChildByName("Button_RefreshToken"),"Button")
	local Button_FriendPoints = tolua.cast(Image_ResourceInfoPNL4:getChildByName("Button_FriendPoints"),"Button")
	
	local Label_ResourceValue_Energy = tolua.cast(Button_Energy:getChildByName("Label_ResourceValue"),"Label")
	local Label_ResourceValue_YuanBao = tolua.cast(Button_YuanBao:getChildByName("Label_ResourceValue"),"Label")
	local Label_ResourceValue_TongQian = tolua.cast(Button_TongQian:getChildByName("Label_ResourceValue"),"Label")
	
	local Label_ResourceValue_XueShi = tolua.cast(Button_XueShi:getChildByName("Label_ResourceValue"),"Label")
	local Label_ResourceValue_DragonBall = tolua.cast(Button_DragonBall:getChildByName("Label_ResourceValue"),"Label")
	local Label_ResourceValue_Prestige = tolua.cast(Button_Prestige:getChildByName("Label_ResourceValue"),"Label")
	
	local Label_ResourceValue_Incense = tolua.cast(Button_Incense:getChildByName("Label_ResourceValue"),"Label")
	local Label_ResourceValue_Elements = tolua.cast(Button_Elements:getChildByName("Label_ResourceValue"),"Label")
	local Label_ResourceValue_JiangHunShi = tolua.cast(Button_JiangHunShi:getChildByName("Label_ResourceValue"),"Label")
	
	local Label_ResourceValue_RefreshToken = tolua.cast(Button_RefreshToken:getChildByName("Label_ResourceValue"),"Label")
	local Label_ResourceValue_FriendPoints = tolua.cast(Button_FriendPoints:getChildByName("Label_ResourceValue"),"Label")
	
	
	Label_ResourceValue_Energy:setText(g_Hero:getEnergyString().."/"..g_Hero:getMaxEnergy())
	Label_ResourceValue_YuanBao:setText(g_Hero:getYuanBaoString())
	Label_ResourceValue_TongQian:setText(g_Hero:getCoinsString())
	
	Label_ResourceValue_XueShi:setText(g_Hero:getKnowledgeString())
	Label_ResourceValue_DragonBall:setText(g_Hero:getDragonBallString())
	Label_ResourceValue_Prestige:setText(g_Hero:getPrestigeString())
	
	Label_ResourceValue_Incense:setText(g_Hero:getIncenseString())
	Label_ResourceValue_Elements:setText(g_Hero:getEssenceString())
	Label_ResourceValue_JiangHunShi:setText(g_Hero:getJiangHunShi())
	
	Label_ResourceValue_RefreshToken:setText(g_Hero:getRefreshToken())
	Label_ResourceValue_FriendPoints:setText(g_Hero:getFriendPoints())
	
	local Label_RoleID = tolua.cast(Image_HomeFunctionListPNL:getChildByName("Label_RoleID"),"Label")
	Label_RoleID:setText(string.format(_T("角色Id:%d"), g_MsgMgr:getZoneUin()))
	
	local function onShowTip(btn)
		g_SetBtnWithPressingEvent(btn, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	end
	
	onShowTip(Button_Energy)
	onShowTip(Button_YuanBao)
	onShowTip(Button_TongQian)
	onShowTip(Button_XueShi)
	onShowTip(Button_DragonBall)
	onShowTip(Button_Prestige)
	onShowTip(Button_Incense)
	onShowTip(Button_Elements)
	onShowTip(Button_JiangHunShi)
	onShowTip(Button_RefreshToken)
	onShowTip(Button_FriendPoints)
	
	
	local Button_AddResource_Energy = tolua.cast(Button_Energy:getChildByName("Button_AddResource"),"Button")
	local function onClick_Button_AddResource_Energy(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			g_buyEnergy()
		end
	end
	Button_AddResource_Energy:addTouchEventListener(onClick_Button_AddResource_Energy)
	Button_AddResource_Energy:setTouchEnabled(true)
	
	local Button_AddResource_YuanBao = tolua.cast(Button_YuanBao:getChildByName("Button_AddResource"),"Button")
	local function onClick_Button_AddResource_YuanBao(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			g_WndMgr:openWnd("Game_ReCharge")
		end
	end
	Button_AddResource_YuanBao:addTouchEventListener(onClick_Button_AddResource_YuanBao)
	Button_AddResource_YuanBao:setTouchEnabled(true)
	
	local Button_AddResource_TongQian = tolua.cast(Button_TongQian:getChildByName("Button_AddResource"),"Button")
	local function onClick_Button_AddResource_TongQian(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			g_WndMgr:openWnd("Game_ZhaoCaiFu")
		end
	end
	Button_AddResource_TongQian:addTouchEventListener(onClick_Button_AddResource_TongQian)
	Button_AddResource_TongQian:setTouchEnabled(true)
end

function Game_HomeFunctionList:initWnd()
	local Image_HomeFunctionListPNL = tolua.cast(self.rootWidget:getChildByName("Image_HomeFunctionListPNL"),"ImageView")
	local Image_FunctionListPNL = tolua.cast(Image_HomeFunctionListPNL:getChildByName("Image_FunctionListPNL"),"ImageView")
	self.Button_Assistant = tolua.cast(Image_FunctionListPNL:getChildByName("Button_Assistant"),"Button")
	self.Button_ZhaoCai = tolua.cast(Image_FunctionListPNL:getChildByName("Button_ZhaoCai"),"Button")
	self.Button_HuoDong = tolua.cast(Image_FunctionListPNL:getChildByName("Button_HuoDong"),"Button")
	self.Button_QianDao = tolua.cast(Image_FunctionListPNL:getChildByName("Button_QianDao"),"Button")
	self.Button_FirstCharge = tolua.cast(Image_FunctionListPNL:getChildByName("Button_FirstCharge"),"Button")
	self.Button_FirstCharge:setVisible(false)
	self.Button_OnLineReward = tolua.cast(Image_FunctionListPNL:getChildByName("Button_OnLineReward"),"Button")
	self.Button_JiaNianHua = tolua.cast(Image_FunctionListPNL:getChildByName("Button_JiaNianHua"),"Button")
	self.Button_Mail = tolua.cast(Image_FunctionListPNL:getChildByName("Button_Mail"),"Button")
	self.Button_Turntable = tolua.cast(Image_FunctionListPNL:getChildByName("Button_Turntable"),"Button")
    self.Button_GongGao = tolua.cast(Image_FunctionListPNL:getChildByName("Button_GongGao"),"Button")
    self.Button_Setting = tolua.cast(Image_FunctionListPNL:getChildByName("Button_Setting"),"Button")
	
	self.Button_JiaNianHua:loadTextureNormal(getUIImg("BtnJiaNianHua"..g_Hero:getMasterSex()))
	self.Button_JiaNianHua:loadTexturePressed(getUIImg("BtnJiaNianHua"..g_Hero:getMasterSex()))
	self.Button_JiaNianHua:loadTextureDisabled(getUIImg("BtnJiaNianHua"..g_Hero:getMasterSex()))
	local Image_Check = tolua.cast(self.Button_JiaNianHua:getChildByName("Image_Check"), "ImageView")
	Image_Check:loadTexture(getUIImg("BtnJiaNianHua"..g_Hero:getMasterSex()))
	
	local tbButtonList = {}
	table.insert(tbButtonList, self.Button_Assistant)
	table.insert(tbButtonList, self.Button_ZhaoCai)
	table.insert(tbButtonList, self.Button_HuoDong)
	table.insert(tbButtonList, self.Button_QianDao)
	table.insert(tbButtonList, self.Button_FirstCharge)
	table.insert(tbButtonList, self.Button_OnLineReward)
	table.insert(tbButtonList, self.Button_JiaNianHua)
	table.insert(tbButtonList, self.Button_Mail)
	table.insert(tbButtonList, self.Button_Turntable)
	table.insert(tbButtonList, self.Button_GongGao)
	table.insert(tbButtonList, self.Button_Setting)

    local function onClick_MainHomeButton(pSender, nTag)
		if nTag == 1 then --小助手
			g_WndMgr:openWnd("Game_Assistant")
		elseif nTag == 2 then --招财
			g_WndMgr:openWnd("Game_ZhaoCaiFu")
		elseif nTag == 3 then --运营活动
			g_WndMgr:openWnd("Game_ActivityCenter")
		elseif nTag == 4 then --签到
			g_WndMgr:showWnd("Game_Registration1")
		elseif nTag == 5 then --首充
			g_WndMgr:showWnd("Game_FirstCharge")
		elseif nTag == 6 then --在线奖励
			g_WndMgr:openWnd("Game_ActivityCenter", common_pb.AOLT_ONLINE)
		elseif nTag == 7 then --嘉年华
			g_WndMgr:openWnd("Game_ServerOpenTask")
		elseif nTag == 8 then --邮件
			g_WndMgr:openWnd("Game_MailBox")
		elseif nTag == 9 then --爱心转盘
			g_WndMgr:openWnd("Game_Turntable")
		elseif nTag == 10 then --公告按钮
			g_WndMgr:showWnd("Game_Notice")
			local function downloadCallback(pSend, bSucc, szText, nStatus, szError)
				if bSucc then 
					local fuc = loadstring(szText) 
					fuc()
					g_WndMgr:showWnd("Game_Notice")
				end
				pSend:release() 
			end
		elseif nTag == 11 then --系统按钮
			g_WndMgr:showWnd("Game_System1")
		end
    end 
	
	g_SetBtnOpenCheckWithPressImage(self.Button_Assistant, 1, onClick_MainHomeButton, true, false, false, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_ZhaoCai, 2, onClick_MainHomeButton, true, false, false, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_HuoDong, 3, onClick_MainHomeButton, true, false, false, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_QianDao, 4, onClick_MainHomeButton, true, false, false, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_FirstCharge, 5, onClick_MainHomeButton, true, false, false, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_OnLineReward, 6, onClick_MainHomeButton, true, false, false, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_JiaNianHua, 7, onClick_MainHomeButton, true, false, false, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_Mail, 8, onClick_MainHomeButton, true, false, false, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_Turntable, 9, onClick_MainHomeButton, true, false, false, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_GongGao, 10, onClick_MainHomeButton, true, false, false, 1)
	g_SetBtnOpenCheckWithPressImage(self.Button_Setting, 11, onClick_MainHomeButton, true, false, false, 1)
	
	local nButtonOpenCount = 1
	for nButtonIndex = 1, #tbButtonList do

		local strBtnName = "LKA"

		if tbButtonList[nButtonIndex] then
			strBtnName = tbButtonList[nButtonIndex]:getName()
		end
		
		if not g_CheckFuncCanOpenByWidgetName(strBtnName) then
			tbButtonList[nButtonIndex]:setPositionX(400)
			tbButtonList[nButtonIndex]:setPositionY(-70)
			tbButtonList[nButtonIndex]:setVisible(false)
			tbButtonList[nButtonIndex]:setTouchEnabled(false)
		else
			if g_CheckFuncCanOpenByWidgetName(strBtnName) then
				local nRow = math.ceil(nButtonOpenCount/6) - 1
				local nColumn = math.mod(nButtonOpenCount-1, 6)
				tbButtonList[nButtonIndex]:setPositionX(-400+160*nColumn)
				tbButtonList[nButtonIndex]:setPositionY(70-140*nRow)
				tbButtonList[nButtonIndex]:setVisible(true)
				tbButtonList[nButtonIndex]:setTouchEnabled(true)
				nButtonOpenCount = nButtonOpenCount + 1
			else
				tbButtonList[nButtonIndex]:setPositionX(400)
				tbButtonList[nButtonIndex]:setPositionY(-70)
				tbButtonList[nButtonIndex]:setVisible(false)
				tbButtonList[nButtonIndex]:setTouchEnabled(false)
			end
		end
	end
end

function Game_HomeFunctionList:openWnd(tbData)
	self:userInfoShow()
	self:updateWnd()
end

--主角信息描述
function Game_HomeFunctionList:userInfoShow()
 
 	local Image_HomeFunctionListPNL = tolua.cast(self.rootWidget:getChildByName("Image_HomeFunctionListPNL"),"ImageView")
	
	local tbCardLeader = g_Hero:getBattleCardByIndex(1)
	if not tbCardLeader then return end
	--玩家名称
	local Label_MasterName = tolua.cast(Image_HomeFunctionListPNL:getChildByName("Label_MasterName"),"Label")
	Label_MasterName:setText(tbCardLeader:getNameWithSuffix(Label_MasterName))
	
	--玩家等级
	local Label_MasterLevel = tolua.cast(Image_HomeFunctionListPNL:getChildByName("Label_MasterLevel"),"Label")
	Label_MasterLevel:setText(string.format(_T("Lv.%d"), tbCardLeader:getLevel()))
	  
	local Label_MasterExpLB = tolua.cast(Image_HomeFunctionListPNL:getChildByName("Label_MasterExpLB"),"Label")
	--玩家经验
	local Label_MasterExp = tolua.cast(Image_HomeFunctionListPNL:getChildByName("Label_MasterExp"),"Label")
	Label_MasterExp:setText(tbCardLeader:getExp())
	
	local Label_MasterExpMax = tolua.cast(Image_HomeFunctionListPNL:getChildByName("Label_MasterExpMax"),"Label")
	Label_MasterExpMax:setText("/"..tbCardLeader:getMaxExp())
	
	g_AdjustWidgetsPosition({Label_MasterName,Label_MasterLevel},10)
	g_AdjustWidgetsPosition({Label_MasterLevel,Label_MasterExpLB},30)
	g_AdjustWidgetsPosition({Label_MasterExpLB,Label_MasterExp,Label_MasterExpMax})
end


function Game_HomeFunctionList:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_HomeFunctionListPNL = tolua.cast(self.rootWidget:getChildByName("Image_HomeFunctionListPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_HomeFunctionListPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
	mainWnd:showMainHomeZoomInAnimation()
end

function Game_HomeFunctionList:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_HomeFunctionListPNL = tolua.cast(self.rootWidget:getChildByName("Image_HomeFunctionListPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local function actionEndCall()
		if funcWndCloseAniCall then
			funcWndCloseAniCall()
		end
		mainWnd:showMainHomeZoomOutAnimation()
	end
	g_CreateUIDisappearAnimation_Scale(Image_HomeFunctionListPNL, actionEndCall, 1.05, 0.15, Image_Background)
end