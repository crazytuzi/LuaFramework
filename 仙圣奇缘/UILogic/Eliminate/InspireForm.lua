 --------------------------------------------------------------------------------------
-- 文件名: InspireForm.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 
-- 日  期:   
-- 版  本:    感悟系统界面
-- 描  述:    
-- 应  用:  收到FormMsg_InspireForm_Eliminate 消除爆炸的元素－》添加新元素 －》刷新最新的元素
---------------------------------------------------------------------------------------

Game_GanWu = class("Game_GanWu")
Game_GanWu.__index = Game_GanWu

--暂定
local nRow = 7
local nCol = 7

--坐标偏移 6个像素
xfile_Inspire = 6

function Game_GanWu:ctor()
	--单个格子的属性
	--左上角第一个格子的坐标	
	self.px 	= 0	
	self.py 	= 0
	self.wide   = 0
	self.height = 0
	self.wgtmodle = nil

	--消除的元素列表
	self.tbWgtElem = {}

	--技能按钮组
	self.tbBtnSkill = {}

	--选择的技能下标
	self.nSelect = 0

	--表现
	self.InspireShow = nil

	self.anitag = 0xff0818

	self.Ignore =  CCUserDefault:sharedUserDefault():getBoolForKey("GanWuIgnore", false)

	--感悟log
	self.InspireForm = InspireLogForm.new()

end


function Game_GanWu:initWnd()



	local wgt = self.rootWidget:getChildByName("Button_Element11")
	if wgt ~= nil then
		self.wgtmodle = wgt:clone()
		self.wgtmodle:retain()
		self.wgtmodle:setVisible(true)

		self.px = 430
		self.py = 595
		self.wide = wgt:getSize().width
		self.height = wgt:getSize().height

		wgt:setVisible(false)
		
	else
		error(" 感悟的消除窗口 不存在")
	end
	
	g_FormMsgSystem:RegisterFormMsg(FormMsg_InspireForm_Eliminate, handler(self, self.OnMsgInspireFormEliminate))

	g_FormMsgSystem:RegisterFormMsg(FormMsg_InspireForm_ComparisonColor, handler(self, self.OnMsgInspireFormComparisonColor))

	-- g_FormMsgSystem:RegisterFormMsg(FormMsg_InspireForm_OpenWnd, handler(self, self.OnMsgOpenWnd))

	cclog("=================Game_GanWu:initWnd===============")
	
	local Button_GanWuGuide = tolua.cast(self.rootWidget:getChildByName("Button_GanWuGuide"), "Button")
	g_RegisterGuideTipButton(Button_GanWuGuide, nil)
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getBackgroundJpgImg("ShangXiang"))
	
	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		local CheckBox_IgnoreConfirm = tolua.cast(self.rootWidget:getChildByName("CheckBox_IgnoreConfirm"), "CheckBox")
		local Label_FuncName = tolua.cast(CheckBox_IgnoreConfirm:getChildByName("Label_FuncName"), "Label")
		Label_FuncName:setText(g_stringSize_insert(Label_FuncName:getStringValue(), "\n", 24, 200))
	end
	
	

end


function Game_GanWu:GetPoint()
	return self.px, self.py
end


function Game_GanWu:GetSize()
	return self.wide, self.height
end


function Game_GanWu:CloneMoudle()
	-- local wgt = tolua.cast(self.wgtmodle:clone(), "Button")
	return self.wgtmodle
end


function Game_GanWu:openWnd()
	local LogPNL = self.rootWidget:getChildByName("Image_LogPNL")
	self.InspireForm:InitListView(LogPNL)

	self.InspireForm:ShowLogList()

	-- g_EliminateSystem:RequestInspireCheckData()
	--创建消除的格子
	self:CreateElement()

	--创建技能组
	self:CreateSkillGroup()

	self:ShowInspireform()
end


function Game_GanWu:ShowInspireform()
	self.nSelect = 0

	local eleNode = g_EliminateSystem:RandomEliminate()
	if eleNode == nil then --死局
		g_EliminateSystem:ResetRequestInspireDate()
	 return
	end

	local indexA, indexB = eleNode:RandomEliminate()
	local nindex = 0
	local wgt = nil
	local wgtMask = nil
	for i=1, nRow do
		for j=1, nCol do
			nindex = g_EliminateSystem:GetIndex(i, j)
			wgt = self.rootWidget:getChildByTag(nindex)
			if wgt ~= nil then
				wgtMask = wgt:getChildAllByName("Image_Mask")
		
				if nindex == indexA or nindex == indexB then
					wgtMask:setVisible(true)
			 		g_SetBlendFuncWidget(wgtMask, 4)
			 		LandRActionButton(wgtMask)
				else
					wgtMask:setVisible(false)
				end
			end
			
		end
	end

	self:RefeshSkillGroup()

	self:RefeshInspireBtn()

	self:RefreshInspireCost()

	local function OnClickCheckBox(pSender, eventType)
		self.Ignore = (eventType == ccs.CheckBoxEventType.selected)
		CCUserDefault:sharedUserDefault():setBoolForKey("GanWuIgnore", self.Ignore)
	end

	--
	local checkbox = tolua.cast(self.rootWidget:getChildByName("CheckBox_IgnoreConfirm"), "CheckBox")
	checkbox:addEventListenerCheckBox(OnClickCheckBox)
	checkbox:setSelectedState(self.Ignore)
	
	self:addGanWuNumView()
	
end


function Game_GanWu:closeWnd()
	if self.wgtmodle and self.wgtmodle:isExsit() then
		self.wgtmodle:release()
		self.wgtmodle = nil
	end
	self.InspireForm:Release()
	g_EliminateSystem:SaveEliminateLog()
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_InspireForm_Eliminate)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_InspireForm_ComparisonColor)
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getUIImg("Blank"))
end


function Game_GanWu:CreateElement()
	local wgttag = nil	
	for i=1, nRow do
		for j=1, nCol do
			wgttag = self.rootWidget:getChildByTag(g_EliminateSystem:GetIndex(i, j))
			if wgttag ~= nil then
				wgttag:removeFromParentAndCleanup(true)
				wgttag = nil
			end

			local elem = g_EliminateSystem:GetElementByIndex(i,j)
			if elem == nil or self.wgtmodle == nil then
				error("感悟消除数据出错")
			end

			local Button_Element = tolua.cast(self.wgtmodle:clone(), "Button")
			Button_Element:loadTextureNormal(getXianMaiImg("Element"..elem:GetColor()))
			Button_Element:loadTexturePressed(getXianMaiImg("Element"..elem:GetColor().."_Press"))

			-- local ptx =	self.px + (j-1)*self.wide + (j-1)*xfile_Inspire --从第二个开始偏移

			-- local pty = self.py - (i-1)*self.height - (i-1)*xfile_Inspire --从第二个开始偏移
			local ptx, pty = self:GetWgtPoint(i, j)

			Button_Element:setPosition(ccp(ptx, pty))

			local wgtMask = Button_Element:getChildAllByName("Image_Mask")
			wgtMask:setVisible(false)
			--每个窗口的颜色值存在对应子窗口wgtMask中 在对比的时候逻辑判断
			wgtMask:setTag(elem:GetColor())
			
			local tag = g_EliminateSystem:GetIndex(i, j)
			g_SetBtnWithPressingEvent(Button_Element, tag, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
			
			self.rootWidget:addChild(Button_Element)
		end
	end
end

local function onClick_Button_XiaoChuSkill(pSend, nTag)
	--服务器枚举从0开始
	cclog("======Game_GanWu:OnClickSkillBtn========="..nTag)
	g_EliminateSystem:SetCurSkill(nTag)
	
	local wndInstance = g_WndMgr:getWnd("Game_GanWu")
	if wndInstance then
		wndInstance:RefeshSkillGroup()
	end
end

function Game_GanWu:CreateSkillGroup()	
	self.tbBtnSkill = {}
	local wgt = self.rootWidget:getChildByName("Image_SkillPNL")
	if wgt ~= nil then
		local btn = nil
		local StrBtn = nil
		for i=1, 5 do
			StrBtn = "Button_XiaoChuSkill"..i
			btn = tolua.cast(wgt:getChildByName(StrBtn), "Button")
			btn:setTag(i)
			if btn ~= nil then
				g_SetBtnWithPressingEvent(btn, i, g_OnShowTip, onClick_Button_XiaoChuSkill, g_OnCloseTip, true, 0.25)
				table.insert(self.tbBtnSkill, btn)
			end
		end
	end
end


function Game_GanWu:RefeshSkillGroup()
	local check = nil
	local enible = nil
	local itag = 0
	local btn  = nil
	local Image_skill = nil
	for k, v  in ipairs(self.tbBtnSkill)do
		itag = v:getTag()

		check = v:getChildByName("Image_Check")

		Image_skill = v:getChildByName("Image_SkillIcon")

		check:setVisible(itag == g_EliminateSystem:GetCurSkillIndex())

		
		enable = g_EliminateSystem:GetSkillStateByIndex(itag)

		btn  = tolua.cast(v, "Button")
		btn:setCascadeColorEnabled(true)
		if not enable then
			g_setImgShader(Image_skill, pszGreyFragSource)
		else
			g_setImgShader(Image_skill, pszNormalFragSource)
		end

		btn:setTouchEnabled(enable)
	end
end

function Game_GanWu:CreateShowNode()

	-- --技能界面刷新
	local check = nil
	for k, v  in ipairs(self.tbBtnSkill)do
		check = v:getChildByName("Image_Check")
		check:setVisible(false)
	end

	--播放动画前 隐藏高亮
	local wgt = nil
	local wgtMask = nil
	for i=1, nRow do
		for j=1, nCol do
			nindex = g_EliminateSystem:GetIndex(i, j)
			wgt = self.rootWidget:getChildByTag(nindex)
			if wgt ~= nil then
				wgtMask = wgt:getChildAllByName("Image_Mask")
				wgtMask:setVisible(false)
			end
			
		end
	end

	self.InspireShow = nil

	if  g_EliminateSystem:GetCurSkillType() < macro_pb.I_S_I_BA_ZHE then

		self.InspireShow = SkillShowBase.new()

		cclog("======Game_GanWu:CreateShowNode==========-1")

	elseif g_EliminateSystem:GetCurSkillType() == macro_pb.I_S_I_BA_ZHE or
		 g_EliminateSystem:GetCurSkillType()   == macro_pb.I_S_I_DOU_ZHUAN or 
		 g_EliminateSystem:GetCurSkillType()   == macro_pb.I_S_I_LIAN_SUO then

		self.InspireShow = SkillShowDel.new()

		cclog("======Game_GanWu:CreateShowNode=========="..macro_pb.I_S_I_BA_ZHE)

	elseif g_EliminateSystem:GetCurSkillType() == macro_pb.I_S_I_DIAN_DAO then

		self.InspireShow = SkillShowUpdate.new()
		cclog("======Game_GanWu:CreateShowNode=========="..macro_pb.I_S_I_DIAN_DAO)

	elseif g_EliminateSystem:GetCurSkillType() == I_S_I_AUTO_Eliminate then

		self.InspireShow = SkillShowDelandAnd.new()
		cclog("======Game_GanWu:CreateShowNode=========="..I_S_I_AUTO_Eliminate)
		
	end

	if self.InspireShow ~= nil then
		self.InspireShow:InitWgt(self.rootWidget, self)
		self.InspireShow:ShowNode()
	end
end


function Game_GanWu:RefeshInspireBtn()
	local btnTongqian = tolua.cast(self.rootWidget:getChildAllByName("Button_TongQianGanWu"), "Button")
	local btnyuanbao  = tolua.cast(self.rootWidget:getChildAllByName("Button_YuanBaoGanWu"), "Button")
	g_SetBtnWithPressingEventAndGuide(btnTongqian, 1, g_OnShowTip, handler(self, self.OnClickTongBtn), g_OnCloseTip, true, 0.25)
	g_SetBtnWithPressingEventAndGuide(btnyuanbao, 1, g_OnShowTip, handler(self, self.OnClickYuanbaoBtn), g_OnCloseTip, true, 0.25)
end


function Game_GanWu:RefreshInspireCost()
	local image_Btnpnl = self.rootWidget:getChildByName("Image_BtnPNL")

	local tong = image_Btnpnl:getChildByName("Image_NeedMoney")
	local LabTong = tolua.cast(tong:getChildByName("BitmapLabel_NeedMoney"), "LabelBMFont")

	yuanbao = image_Btnpnl:getChildByName("Image_NeedYuanBao")
	local LabYuanbao = tolua.cast(yuanbao:getChildByName("BitmapLabel_NeedYuanBao"), "LabelBMFont")

	LabTong:setText(""..g_EliminateSystem:GetNeedTongQian())
	LabYuanbao:setText(""..g_EliminateSystem:GetNeedYuanBao())

	g_SetLabelRed(LabTong, g_Hero:getCoins() < g_EliminateSystem:GetNeedTongQian())
	g_SetLabelRed(LabYuanbao, g_Hero:getYuanBao() < g_EliminateSystem:GetNeedYuanBao())
end


function Game_GanWu:OnClickTongBtn(pSender, nTag)


	local useCount = g_Hero:getDailyNoticeByType(macro_pb.DT_GanWu)	
	local num = g_VIPBase:getAddTableByNum(VipType.VipBuyOpType_GanWuCnt)	
	if g_DataMgr:getGlobalCfgCsv("ganwu_number") + num - useCount <= 0 then 
		g_ShowSysTips({text = _T("感悟次数已经使用完了")})
		return 
	end

    --第一个技能免费消除
    if g_EliminateSystem:GetNeedTongQian() == 0 then
		 g_EliminateSystem:RequestInspire(false)
		 return true
	end

	local szstr = _T("铜钱感悟需要消耗")..g_EliminateSystem:GetNeedTongQian().._T("铜钱,您的铜钱不足是否进行招财?")
	if g_CheckMoneyConfirm(g_EliminateSystem:GetNeedTongQian(), szstr) then
		g_EliminateSystem:RequestInspire(false)
	end

	return true
end


function Game_GanWu:OnClickYuanbaoBtn(pSender, nTag)
		
	local useCount = g_Hero:getDailyNoticeByType(macro_pb.DT_GanWu)	
	local num = g_VIPBase:getAddTableByNum(VipType.VipBuyOpType_GanWuCnt)	
	if g_DataMgr:getGlobalCfgCsv("ganwu_number") + num - useCount <= 0 then 
		g_ShowSysTips({text = _T("感悟次数已经使用完了")})
		return 
	end
	 --第一个技能免费消除
    if g_EliminateSystem:GetNeedYuanBao() == 0 then
		 g_EliminateSystem:RequestInspire(true)
		 return true
	end

	if self.Ignore then
		local szstr = _T("元宝感悟需要消耗")..g_EliminateSystem:GetNeedYuanBao().._T("元宝,您的元宝不足是否进行充值?")
		if g_CheckYuanBaoConfirm(g_EliminateSystem:GetNeedYuanBao(), szstr) then
			g_EliminateSystem:RequestInspire(true)
		end
		 return true
	end

	local szstr = _T("元宝感悟需要消耗")..g_EliminateSystem:GetNeedYuanBao().._T(" 元宝,您的元宝不足是否进行充值?")
	if g_CheckYuanBaoConfirm(g_EliminateSystem:GetNeedYuanBao(), szstr) then
		local function onClickConfirm()

			g_EliminateSystem:RequestInspire(true)
			
		end
		local function onClickCancel()
			
		end
		szstr = _T("是否消耗")..g_EliminateSystem:GetNeedYuanBao().._T("元宝进行元宝感悟?")
		g_ClientMsgTips:showConfirm(szstr, onClickConfirm, onClickCancel)
	end

	return true
end


function Game_GanWu:GetWgtPoint(row, col)
	local ptx =	self.px + (col-1)*self.wide + (col-1)*xfile_Inspire --从第二个开始偏移

	local pty = self.py - (row-1)*self.height - (row-1)*xfile_Inspire --从第二个开始偏移

	return ptx, pty
end


function Game_GanWu:OnMsgInspireFormEliminate()
	cclog("=================Game_GanWu:OnMsgInspireFormEliminate========================")
	if self == nil then return end

	self:CreateShowNode()

	local Attribute  = g_EliminateSystem:GetAttribute()
	if Attribute ~= nil then
		cclog("===============Attribute  = g_EliminateSystem:GetAttribute()=============")
		--飘字
		local tbWorldPos = 0
		local btnTongqian = tolua.cast(self.rootWidget:getChildAllByName("Button_TongQianGanWu"), "Button")
		local btnyuanbao  = tolua.cast(self.rootWidget:getChildAllByName("Button_YuanBaoGanWu"), "Button")

		if Attribute:isCoupons() then
			tbWorldPos = btnyuanbao:getPosition()
		else
			tbWorldPos = btnTongqian:getPosition()
		end

		local color = Attribute:GetMultNum()
		if color < 1 then color = 1 end
		if color > 6 then color = 6 end


		if Attribute:GetInc_incense() > 0 then
			local param = {
				text = _T("感悟获得").." "..Attribute:GetInc_incense().." ".._T("点香贡"),
				layout = self.rootWidget,
				ccsColor = g_TbColorType[color],
				fontSize = 24,
				x = VisibleRect:center().x,
				y = VisibleRect:center().y - 250
			}
			g_ShowSysTipsWord(param)
			-- echoj("感悟获得", param)
			g_EliminateSystem:InsertElimnateLog(color, param.text)
		end
		
		
		self:CritecalAction()
	end
	
end


function Game_GanWu:CritecalAction()
	local Attribute  = g_EliminateSystem:GetAttribute()
--暴击动画
	if Attribute:GetMultNum() > 1 then
		local tagwgt = self.rootWidget:getChildByTag(self.anitag)
		if tagwgt ~= nil then
			tagwgt:removeFromParentAndCleanup(true)
		end

		local armature,userAnimation = g_CreateCoCosAnimationWithCallBacks("GanWuCritical",nil, nil, 2, nil, false)
		armature:setTag(self.anitag)
		armature:setPosition(VisibleRect:center())

		--设置当前暴击数
		local LayerNumBone = armature:getBone("LayerNum1")
		local Critical_Num = "GanWuCritical_Number"..Attribute:GetMultNum()..".png"
		local Critical = CCSkin:createWithSpriteFrameName(Critical_Num)
		LayerNumBone:addDisplay(Critical,0)
		LayerNumBone:changeDisplayWithIndex(0, true)

		mainWnd:addChild(armature, 11111)

		userAnimation:playWithIndex(0)

		cclog("===============消除倍速================="..Attribute:GetMultNum())
	end
end


function Game_GanWu:OnMsgInspireFormComparisonColor()
	cclog("============Game_GanWu:OnMsgInspireFormComparisonColor===============")
	if self == nil then return end
	-- local bError = false
	-- local nindex = 0
	-- local wgt = nil
	-- local ncolor = -1
	-- local element = nil

	-- for row=1 , nRow do

	-- 	for col=1, nCol do
	-- 		nindex = g_EliminateSystem:GetIndex(row, col)
	-- 		wgt = self.rootWidget:getChildByTag(nindex)
	-- 		local wgtMask = wgt:getChildByName("Image_Mask")
	-- 		ncolor = wgtMask:getTag()

	-- 		element = g_EliminateSystem:GetElementByIndex(row, col)

	-- 		if element:GetColor() ~= ncolor then
	-- 			bError = true
	-- 			break
	-- 		end
	-- 	end
	-- end

	-- if bError then
	-- 	cclog("Game_GanWu:OnMsgInspireFormComparisonColor 对比颜色值出错＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝")
	-- 	cclog("窗口的颜色值==========")
	-- 	local testStr = "\n"
	-- 	for row1=1 , nRow do
	-- 		for col1=1, nCol do
	-- 			nindex = g_EliminateSystem:GetIndex(row1, col1)
	-- 			wgt = self.rootWidget:getChildByTag(nindex)
	-- 			local wgtMask = wgt:getChildByName("Image_Mask")
	-- 			ncolor = wgtMask:getTag()
	-- 			testStr = testStr.." "..ncolor
	-- 		end
	-- 		testStr = testStr.."\n"
	-- 	end
	-- 	cclog(testStr)

	-- 	cclog("系统颜色值===========")
	-- 	testStr = "\n"
	-- 	for row2=1 , nRow do
	-- 		for col2=1, nCol do
	-- 			element = g_EliminateSystem:GetElementByIndex(row2, col2)
	-- 			ncolor = element:GetColor()
	-- 			testStr = testStr.." "..ncolor
	-- 		end
	-- 		testStr = testStr.."\n"
	-- 	end
	-- 	cclog(testStr)

	-- 	return 
	-- end

	-- --直接调用剩下的流程
	cclog("===========此界面是没有自动消除的元素了啊========消除一回合结束======================")
	-- g_EliminateSystem:RandomEliminate()

--刷新界面
	self:ShowInspireform()
	
	
end


function Game_GanWu:OnMsgOpenWnd()
	cclog("=======================Game_GanWu:OnMsgOpenWnd=============================")
	if self == nil then return false end
	--创建消除的格子
	self:CreateElement()

	--创建技能组
	self:CreateSkillGroup()

	self:ShowInspireform()

	return true
end

function Game_GanWu:ModifyWnd_viet_VIET()
    local Label_FuncName = tolua.cast(self.rootWidget:getChildAllByName("Label_FuncName"), "Label")
    local text = Label_FuncName:getStringValue()
    Label_FuncName:setText(g_stringSize_insert(text, '\n', 28, 250))

    if self.InspireForm then 
        self.InspireForm:ModifyWnd_viet_VIET()
    end

end

function Game_GanWu:addGanWuNumView()
	
	local function onAddGanWuNum(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
		 
			local vipType = VipType.VipBuyOpType_GanWuCnt
			--购买的次数上限
			local allNum = g_VIPBase:getVipLevelCntNum(vipType)
			--已经购买的次数
			local num = g_VIPBase:getAddTableByNum(vipType)
			if num >= allNum then 
				g_ShowSysTips({text=_T("今天已达到购买次数上限\n提升VIP等级可以增加每天购买次数上限")})
				return 
			end
			
			--每次购买需要消耗的元宝	
			local cost = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_GanWuCnt)
	
			if not g_CheckYuanBaoConfirm(cost, string.format(_T("购买感悟次数需要消耗%d元宝, 您的元宝不足是否前往充值?"),cost)) then
				return
			end
			
			local str = string.format(_T("购买感悟次数需要花费%d元宝, 是否确认购买?"),cost)
			g_ClientMsgTips:showConfirm(str, function() 
				local function serverResponseCall(tiems)	
					
					local wndInstance = g_WndMgr:getWnd("Game_GanWu")
					if wndInstance and wndInstance.rootWidget then
					
						local useCount = g_Hero:getDailyNoticeByType(macro_pb.DT_GanWu)	
						--感悟额外购买次数
						local BitmapLabel_GanWuRemainNum = tolua.cast(wndInstance.rootWidget:getChildAllByName("BitmapLabel_GanWuRemainNum"), "LabelBMFont")
						BitmapLabel_GanWuRemainNum:setText((g_DataMgr:getGlobalCfgCsv("ganwu_number") + tiems - useCount))
						local Button_AddTimes = tolua.cast(wndInstance.rootWidget:getChildAllByName("Button_AddTimes"), "Button")
						g_adjustWidgetsRightPosition({BitmapLabel_GanWuRemainNum,Button_AddTimes},-20)
							
						g_ShowSysTips({text = _T("成功购买1次感悟次数")})
						
						gTalkingData:onPurchase(TDPurchase_Type.TDP_BUY_ELIMINATE_COUNT,1,cost)	
					end
				end
				g_VIPBase:responseFunc(serverResponseCall)
				g_VIPBase:requestVipBuyTimesRequest(VipType.VipBuyOpType_GanWuCnt)
			end)
		end
	end
		--增加感悟次数
	local Button_AddTimes = tolua.cast(self.rootWidget:getChildAllByName("Button_AddTimes"), "Button")
	Button_AddTimes:setTouchEnabled(true)
	Button_AddTimes:addTouchEventListener(onAddGanWuNum)
	
	local useCount = g_Hero:getDailyNoticeByType(macro_pb.DT_GanWu)	
	
	local num = g_VIPBase:getAddTableByNum(VipType.VipBuyOpType_GanWuCnt)	
	local BitmapLabel_GanWuRemainNum = tolua.cast(self.rootWidget:getChildAllByName("BitmapLabel_GanWuRemainNum"), "LabelBMFont")
	BitmapLabel_GanWuRemainNum:setText(g_DataMgr:getGlobalCfgCsv("ganwu_number") + num - useCount)
	
	local Image_GanWuRemainNum2 = tolua.cast(self.rootWidget:getChildAllByName("Image_GanWuRemainNum2"), "ImageView")
	
	-- g_adjustWidgetsRightPosition({Image_GanWuRemainNum2,BitmapLabel_GanWuRemainNum,Button_AddTimes},-6)
	g_adjustWidgetsRightPosition({BitmapLabel_GanWuRemainNum,Button_AddTimes},-10)
	
end

