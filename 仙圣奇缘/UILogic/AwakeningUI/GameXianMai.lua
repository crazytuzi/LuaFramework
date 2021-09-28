--------------------------------------------------------------------------------------
-- 文件名:	Game_XianMai.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  
---------------------------------------------------------------------------------------

Game_XianMai = class("Game_XianMai")
Game_XianMai.__index = Game_XianMai

GAME_XIANMAI_NOT_ACTIVATE = 0 --未激活
GAME_XIANMAI_ACTIVATE = 1;--激活
GAME_XIANMAI_FULL_ACTIVATE = 127;--全激活

local nLevel = 2

local tbElementText = {_T("金"), _T("木"), _T("水"), _T("火"), _T("土"), _T("风"),_T("雷")}
local tbLabelName = {_T("生命"),_T("物攻"),_T("物防"),_T("法攻"),_T("法防"),_T("绝攻"),_T("绝防")}
local tbLabel = {
	"Label_HP",				--生命
	"Label_PhyAttack",		--物攻
	"Label_PhyDefence",		--物防
	"Label_MagAttack",		--法攻
	"Label_MagDefence",		--法防
	"Label_SkillAttack",	--绝攻
	"Label_SkillDefence",	--绝防
}

playerXianMai = g_DataMgr:getCsvConfig("PlayerXianMai") 

--突破后属性
local tbEvoluteValue ={
	"EvoluteHP",			--生命
	"EvolutePhyAttack",	--物攻
	"EvolutePhyDefence",	--物防
	"EvoluteMagAttack",	--法攻
	"EvoluteMagDefence",	--法防
	"EvoluteSkillAttack",--绝攻
	"EvoluteSkillDefence",--绝防
}

--激活后的属性
local tbActivateValue={
	"ActivateHP",
	"ActivatePhyAttack",
	"ActivatePhyDefence",
	"ActivateMagAttack",
	"ActivateMagDefence",
	"ActivateSkillAttack",
	"ActivateSkillDefence",
}

--请求消除的序号
function Game_XianMai:requestElementClearRequest(msg)
	cclog("========requestElementClearRequest=======")
	local rootMsg = zone_pb.ElementClearRequest()

	for i,v in ipairs(msg) do
		tb_idex = {}
		tb_idex.row = v[1]
		tb_idex.col = v[2]
		-- cclog("v1:"..v[1].."v2:"..v[2])
		table.insert(rootMsg.index, tb_idex)
	end
	
	g_MsgMgr:sendMsg(msgid_pb.MSGID_ELEMENT_CLEAR_REQUEST, rootMsg)
end

function Game_XianMai:setSkillButton(index)
	if not self.rootWidget then return end 
	local Image_SkillPNL = tolua.cast(self.rootWidget:getChildByName("Image_SkillPNL"),"ImageView")
	local Button_XiaoChuSkill = tolua.cast(Image_SkillPNL:getChildByName("Button_XiaoChuSkill"..index),"Button")
	local Image_Locker = tolua.cast(Button_XiaoChuSkill:getChildByName("Image_Locker"),"ImageView")
	-- local Button_ZhanShuIcon = tolua.cast(Button_XiaoChuSkill:getChildByName("Button_ZhanShuIcon"),"ImageView")
	-- local BitmapLabel_OpenLevel = tolua.cast(Button_XiaoChuSkill:getChildByName("BitmapLabel_OpenLevel"),"LabelBMFont")
	
	local Image_SkillIcon = tolua.cast(Button_XiaoChuSkill:getChildByName("Image_SkillIcon"),"ImageView")
	local Label_FuncNum = tolua.cast(Image_SkillIcon:getChildByName("Label_FuncNum"),"Label")
	
	local CSV_PlayerXianMaiSkill = g_DataMgr:getCsvConfigByOneKey("PlayerXianMaiSkill",index)
	local status = false
	if g_Hero:getMasterCardLevel() < CSV_PlayerXianMaiSkill.RealeaseLevel then
		Image_Locker:setVisible(true)
	else
		Image_Locker:setVisible(false)
		status = true
	end
	local  tbXianmaiSkillNum =  g_XianMaiInfoData:getTbXianmaiSkillNum(index)
	local text =  "x"..tbXianmaiSkillNum
	Label_FuncNum:setText(text)

	if tbXianmaiSkillNum <= 0  then
		g_SetXianMaiNameColor(Label_FuncNum, 9)
	else
		g_SetXianMaiNameColor(Label_FuncNum, 1)
	end
	
	if tbXianmaiSkillNum <= 0 or g_Hero:getMasterCardLevel() < CSV_PlayerXianMaiSkill.RealeaseLevel  then
		Button_XiaoChuSkill:setTouchEnabled(false)
	else
		Button_XiaoChuSkill:setTouchEnabled(true)
	end
end




function Game_XianMai:initSkillButton()
	if not self.rootWidget then return end 
	
	local Image_SkillPNL = tolua.cast(self.rootWidget:getChildByName("Image_SkillPNL"),"ImageView")

	for nIndex = 1,5 do
		local Button_XiaoChuSkill = tolua.cast(Image_SkillPNL:getChildByName("Button_XiaoChuSkill"..nIndex),"Button")
		self:setSkillButton(nIndex)
		local function onPressed_Button_XiaoChuSkill(pSender, nTag)
			local nXianMaiLev = g_XianMaiInfoData:getXianmaiLevel()
			local CSV_PlayerXianMai = playerXianMai[nXianMaiLev]
			local CSV_PlayerXianMaiSkill = g_DataMgr:getCsvConfigByOneKey("PlayerXianMaiSkill",nTag)
			if g_Hero:getEssence() >= CSV_PlayerXianMai.NeedElementCoreNum then
				if nTag == 1 then
					g_XiaoChu:itemOneKeyClear()
				else
					g_XiaoChu:XianMaiSkillRequest(nTag)
				end
			else
				
				local txt = string.format( _T("使用%s技能需要消耗%d点灵力值"), CSV_PlayerXianMaiSkill.Name,CSV_PlayerXianMai.NeedElementCoreNum)
				-- g_ShowSysWarningTips({text= "使用"..CSV_PlayerXianMaiSkill.Name.."技能需要消耗"..CSV_PlayerXianMai.NeedElementCoreNum.."点灵力值"})
				g_ShowSysWarningTips({text= txt })
			end		
		end
		
		local function onPressing_Button_XiaoChuSkill(pSender, nTag)
			g_WndMgr:showWnd("Game_TipXiaoChuSkill", nTag)
		end
		
		local function onCleanUp_Button_XiaoChuSkill(pSender, nTag)
			g_WndMgr:closeWnd("Game_TipXiaoChuSkill")
		end
		g_SetBtnWithPressingEvent(Button_XiaoChuSkill, nIndex, onPressing_Button_XiaoChuSkill, onPressed_Button_XiaoChuSkill, onCleanUp_Button_XiaoChuSkill, true, 0.25)
	end
end

function Game_XianMai:initWnd(widget)
	if not self.rootWidget then return end 
	local Button_Elements1 = tolua.cast(self.rootWidget:getChildByName("Button_Elements1"),"Button")
	g_SetBtnWithPressingEvent(Button_Elements1, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)

	--元素激活响应
	local order = msgid_pb.MSGID_ELEMENT_ACTIVE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.elementActiveResponse))	

	--一键激活响应
	local order = msgid_pb.MSGID_ONEKEY_ACTIVE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.onekeyActiveResponse))	
	
	--仙脉突破响应
	local order = msgid_pb.MSGID_XIANMAI_BREACH_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.xianmaiBreachResponse))

	self:initSkillButton()
	
	self.Button_Element11 = tolua.cast(self.rootWidget:getChildByName("Button_Element11"), "Button")
	self.Button_Element11:setVisible(false)
	
	
	local Image_ElementPanelPNL = tolua.cast(self.rootWidget:getChildByName("Image_ElementPanelPNL"), "ImageView")
	self.ScrollView_Element = tolua.cast(Image_ElementPanelPNL:getChildByName("ScrollView_Element"), "ScrollView")
	self.ScrollView_Element:setTouchEnabled(false)

	--动画在播放时不能退出 20150618 by zgj
	self.onClickButton_Return = true
		
	local function onBtnClose(pSender,eventType)
		if eventType == ccs.TouchEventType.ended and g_XiaoChu.b_actionEnd then
			g_WndMgr:closeWnd("Game_XianMai")
		end
	end
	
	local BtnClose = tolua.cast(self.rootWidget:getChildByName("Button_Return"),"Button")
	BtnClose:setTouchEnabled(true)
	BtnClose:addTouchEventListener(onBtnClose)
	
	local Button_JueXingGuide = tolua.cast(self.rootWidget:getChildByName("Button_JueXingGuide"), "Button")
	g_RegisterGuideTipButton(Button_JueXingGuide, nil, 0.8)
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getBackgroundJpgImg("XianMai"))
end

function Game_XianMai:openWnd()
	if not self.rootWidget then return end 
	if g_bReturn then return end
	-- g_MsgMgr:ignoreCheckWaitTime(true)
	self.tbTiemrID_ = {}
	self.nLevel = g_XianMaiInfoData:getXianmaiLevel() --仙脉等级
	self.essence = g_Hero:getEssence() --灵力
	self.activateInfo = g_XianMaiInfoData:getActiveInfo() --是否激活
	self.tbElementList = g_XianMaiInfoData:getTbElementList() --元素

	playerXianMai = g_DataMgr:getCsvConfig("PlayerXianMai") or {}
	if self.nLevel > #playerXianMai then self.nLevel = #playerXianMai end
	
	self:essenceNum(self.essence)
	self:activate()
	--突破按钮和一键激活按钮 回调事件
	self:evoluteAndQuickActivate()
	--三消小游戏
	 self:eliminateGame()
	--拥有的元素数值
	self:elementNumValue()
	--仙脉等级
	local Image_XianMaiPNL = tolua.cast(self.rootWidget:getChildByName("Image_XianMaiPNL"),"ImageView")
	local Label_XianMaiName = tolua.cast(Image_XianMaiPNL:getChildByName("Label_XianMaiName"),"Label")
	Label_XianMaiName:setText(string.format(_T("%s Lv.%d"), playerXianMai[self.nLevel].Name, self.nLevel))
	g_SetXianMaiNameColor(Label_XianMaiName, playerXianMai[self.nLevel].ColorType)
	
	local Image_GuideArea2 = tolua.cast(self.rootWidget:getChildByName("Image_GuideArea2"), "ImageView")
	if g_PlayerGuide:checkIsInGuide() then
		local function onClickGuide(pSender, nTag)
			Image_GuideArea2:setTouchEnabled(false)
		end
		g_SetBtnWithGuideCheck(Image_GuideArea2, 1, onClickGuide, true, nil, nil, nil)
	else
		Image_GuideArea2:setTouchEnabled(false)
	end
	for i=1,5 do
		self:setSkillButton(i)
	end
	
end

function Game_XianMai:closeWnd()
	self.nLevel = nil
	self.essence = nil
	self.activateInfo = nil
	self.tbElementList = nil

	g_MsgMgr:ignoreCheckWaitTime(nil)

	g_Timer:destroyTimerByID(self.gTimerIdPush)
	self.gTimerIdPush = nil	
	
	if self.tbTiemrID_ then 
		for i = 1,#self.tbTiemrID_ do
			g_Timer:destroyTimerByID(self.tbTiemrID_[i])
			self.tbTiemrID_[i] = nil
		end
	end
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getUIImg("Blank"))
	
	local Image_XianMaiPNL = tolua.cast(self.rootWidget:getChildByName("Image_XianMaiPNL"),"ImageView")
	Image_XianMaiPNL:removeAllNodes()	
	
end

function Game_XianMai:essenceNum(nNum)
	g_Hero:setEssence(nNum)
	if not self.rootWidget then return end
	local Button_Elements1 = tolua.cast(self.rootWidget:getChildByName("Button_Elements1"),"Button")
	local Label_ElementsNum = tolua.cast(Button_Elements1:getChildByName("Label_ElementsNum"),"Label")
	Label_ElementsNum:setText(g_Hero:getEssenceString())
end

function Game_XianMai:blowUpByShrink(widget)

	local actionScaleTo1 = CCScaleTo:create(0.3, 1.0)
	local actionScaleTo2 = CCScaleTo:create(0.3, 0.7)
	local action = sequenceAction({actionScaleTo1,actionScaleTo2})
	widget:runAction(action)
	
end
--三消 小游戏
function Game_XianMai:eliminateGame()

	local param = {
		widget = self.ScrollView_Element,
		Element = self.Button_Element11,
		func = function(upDateEssence, upDateEleinfo) 
			local wndInstance = g_WndMgr:getWnd("Game_XianMai")
			if wndInstance and wndInstance.rootWidget then
				wndInstance:essenceNum(upDateEssence)
				local rootWidget = wndInstance.rootWidget
				--各个元素的拥有数量 数据顺序分别为 金，木，水，火，土，风，雷
				local Image_XueMaiPNL = tolua.cast(rootWidget:getChildByName("Image_XueMaiPNL"),"ImageView")
				for key, value in ipairs(upDateEleinfo) do
					local Button_XueMai = tolua.cast(Image_XueMaiPNL:getChildByName("Button_XueMai"..value.index+1),"Button")
					local nElementNum = self.tbElementList[value.index+1]
					if Button_XueMai then
						local function UpdateElement()
							local Image_XueMai = tolua.cast(Button_XueMai:getChildByName("Image_XueMai"),"ImageView")
							self:blowUpByShrink(Image_XueMai)
							
							local Label_Num = tolua.cast(Button_XueMai:getChildByName("Label_Num"),"Label")
							local tiemrId = g_CreatePropDynamic(Label_Num, 0.3, nElementNum, value.update_num, "%d", g_getColor(ccs.COLOR.LIME_GREEN), g_getColor(ccs.COLOR.WHITE))	
							table.insert(self.tbTiemrID_,tiemrId)
						end
						self.tbElementList = g_XianMaiInfoData:setTbElementList(value.index+1,value.update_num)
					
						local armature,userAnimation = g_CreateCoCosAnimationWithCallBacks("XianMaiGetYuanSu", nil, UpdateElement, 5)
					
						local tbWorldPos = Button_XueMai:getWorldPosition()
						armature:setPosition(tbWorldPos)
						rootWidget:addNode(armature, 100)
						userAnimation:playWithIndex(0)	
						
					end
				end
				wndInstance:activate()
				
			end
		end, 
	}
	g_XiaoChu:Open(param)
end

--[[
	拥有的元素数量
]]
function Game_XianMai:elementNumValue(tbElement)
	local function onPressing_Button_XueMai(pSender, nTag)
		g_WndMgr:showWnd("Game_TipYuanSu", nTag)
	end
	
	local function onCleanUp_Button_XueMai(pSender, nTag)
		g_WndMgr:closeWnd("Game_TipYuanSu")
	end
	--各个元素的拥有数量 数据顺序分别为 金，木，水，火，土，风，雷
	local Image_XueMaiPNL = tolua.cast(self.rootWidget:getChildByName("Image_XueMaiPNL"),"ImageView")
	for nIndex = 1,7 do 
		local Button_XueMai = tolua.cast(Image_XueMaiPNL:getChildByName("Button_XueMai"..nIndex),"Button")		
		g_SetBtnWithPressingEvent(Button_XueMai, nIndex, onPressing_Button_XueMai, nil, onCleanUp_Button_XueMai, true, 0.0)
		
		local Label_Num = tolua.cast(Button_XueMai:getChildByName("Label_Num"),"Label")
		Label_Num:setText(self.tbElementList[nIndex])
	end
end

--[[

]]
function Game_XianMai:activate()
	local rootWidget = self.rootWidget
	if not rootWidget then return end
	local function onClickEvoluteXianMai(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			local nIndex = pSender:getTag()
			playerXianMai = g_DataMgr:getCsvConfig("PlayerXianMai") or {}
			if self.nLevel > #playerXianMai then cclog("神识等级已达到最高等级") return end
			
			local nNum = playerXianMai[self.nLevel].NeedElementNum
			local allNum = self.tbElementList[nIndex]
			if allNum < nNum then
				local elementName = tbElementText[nIndex]
				 
				-- local nText = elementName.."灵核不足，需要"..nNum.."个"..elementName.."灵核激活"..elementName.."属性的灵脉"
				local nText =  string.format( _T("%s灵核不足，需要%d个%s灵核激活%s属性的灵脉"),elementName,nNum,elementName,elementName)
				g_ClientMsgTips:showMsgConfirm(nText)
				return 
			end
			
			self:requestElementActiveRequest(nIndex)
		end
	end
	
	--各个元素的拥有数量 数据顺序分别为 金，木，水，火，土，风，雷
	local Image_XianMaiPNL = tolua.cast(rootWidget:getChildByName("Image_XianMaiPNL"),"ImageView")
	for i = 1,7 do 
		local Button_XianMai = tolua.cast(Image_XianMaiPNL:getChildByName("Button_XianMai"..i),"Button")
		Button_XianMai:setTag(i)
		--激活数值
		local Image_Prop = tolua.cast(Button_XianMai:getChildByName("Image_Prop"),"ImageView")
		--元素图案
		local Image_XueMai = tolua.cast(Button_XianMai:getChildByName("Image_XueMai"),"ImageView")
		--可激活
		local Image_AddTip = tolua.cast(Button_XianMai:getChildByName("Image_AddTip"),"ImageView")	
		local Image_TipFalse = tolua.cast(Button_XianMai:getChildByName("Image_TipFalse"),"ImageView")	
		Image_TipFalse:setVisible(false)
		local getBits = API_GetBitsByPos(self.activateInfo,i)
		if getBits == GAME_XIANMAI_NOT_ACTIVATE then --还没有激活
			local flage = false
			Image_Prop:setVisible(false)
			Image_TipFalse:setVisible(true)
			--激活所需消耗
			if self.tbElementList[i] >= playerXianMai[self.nLevel].NeedElementNum then
				g_CreateScaleInOutAction(Image_AddTip)
				flage = true
				
				Image_TipFalse:setVisible(false)
			end
			
			Image_AddTip:setVisible(flage)
			Button_XianMai:setTouchEnabled(true)
			Button_XianMai:addTouchEventListener(onClickEvoluteXianMai)
			Image_XueMai:setVisible(false)
			
		elseif getBits == GAME_XIANMAI_ACTIVATE then --激活了
			Image_AddTip:setVisible(false)
			Button_XianMai:setTouchEnabled(false)
			Image_XueMai:setVisible(true)
			Image_Prop:setVisible(true)
			
	
		end
	end

end

function Game_XianMai:evoluteAndQuickActivate()
	local rootWidget = self.rootWidget
	if not rootWidget then return end
	local Image_XianMaiPNL = tolua.cast(rootWidget:getChildByName("Image_XianMaiPNL"),"ImageView")
	local Image_XueMaiPNL = tolua.cast(rootWidget:getChildByName("Image_XueMaiPNL"),"ImageView")
	local function onClickEvolute(pSender, nTag)
	playerXianMai = g_DataMgr:getCsvConfig("PlayerXianMai") or {}
		if self.nLevel >=  #playerXianMai then cclog("神识等级达到最高等级") return  end
		if self.activateInfo ~= GAME_XIANMAI_FULL_ACTIVATE then 
			g_ClientMsgTips:showMsgConfirm( _T("需要7个灵脉都激活后方可突破神识") )
			return
		end
		
		g_MsgNetWorkWarning:showWarningText(true)
		
		self:requestXianmaiBreachResponse()
	end	
	--突破
	local Button_Evolute = tolua.cast(Image_XianMaiPNL:getChildByName("Button_Evolute"),"Button")
	self.Button_Evolute = Button_Evolute
	g_SetBtnWithGuideCheck(self.Button_Evolute, 1, onClickEvolute, true)
	local flag = false
	
	if self.nLevel < #playerXianMai and  g_CheckXianMai() == STATE_TYPE.TYPE_BREAK then   
		flag = true
	end
	g_addUpgradeGuide(self.Button_Evolute, ccp(60, 20), nil,flag)
	
	local function onClickQuickActivate(pSender, nTag)
	playerXianMai = g_DataMgr:getCsvConfig("PlayerXianMai") or {}
		if self.nLevel > #playerXianMai then cclog("神识等级达到最高等级") return  end
		local needNum = playerXianMai[self.nLevel].NeedElementNum
		local falge = true
		for i = 1,7 do
			local getBits = API_GetBitsByPos(self.activateInfo,i)
			if self.tbElementList[i] < needNum  then --某一个元素数量不足 
				falge = false
			else --元素数量足够的情况	
				if getBits == GAME_XIANMAI_NOT_ACTIVATE then --某一个没有激活
					self:requestOnekeyActiveResponse()
					return
				end
			end
		end
		
		if not falge then 
			g_ClientMsgTips:showMsgConfirm( _T("激活灵脉所需的灵核数量不足") )
			return 
		end
		if self.activateInfo == GAME_XIANMAI_FULL_ACTIVATE then 
			g_ClientMsgTips:showMsgConfirm( _T("所有灵脉都已成功激活, 请先突破神识") )
			return 
		end
		self:requestOnekeyActiveResponse()
	end	
	--一键激活
	local Button_QuickActivate = tolua.cast(Image_XianMaiPNL:getChildByName("Button_QuickActivate"),"Button")
	g_SetBtnWithGuideCheck(Button_QuickActivate, 1, onClickQuickActivate, true)
	--初始状态
	for key,value in pairs(tbLabel) do
		self:addProperty(key)			
	end
end


function Game_XianMai:addProperty(nIndex,flag)
	local rootWidget = self.rootWidget
	if not rootWidget then return end
	local Image_XianMaiPNL = tolua.cast(rootWidget:getChildByName("Image_XianMaiPNL"),"ImageView")
	local Button_XianMai = tolua.cast(Image_XianMaiPNL:getChildByName("Button_XianMai"..nIndex),"Button")

	local getBits = API_GetBitsByPos(self.activateInfo,nIndex)
	
	--初始突破数据 取当前等级的
	local strEName = tbEvoluteValue[nIndex]
	local initEvoluteVlaue = playerXianMai[self.nLevel][strEName]
	--初始激活数据 取当前等级的
	local strAName = tbActivateValue[nIndex]
	local initActivateVlaue = playerXianMai[self.nLevel][strAName]
	
	local playerNum = initEvoluteVlaue
	local addNum = 0
	if self.nLevel > 1 and getBits == GAME_XIANMAI_NOT_ACTIVATE then
		playerNum = initEvoluteVlaue
		local playerValue = playerXianMai[self.nLevel - 1][strAName]
		addNum = playerValue
	end
	
	if getBits == GAME_XIANMAI_ACTIVATE then --激活元素成功
		playerNum = playerNum 
		addNum = initActivateVlaue
	end
	
	local label = tolua.cast(Image_XianMaiPNL:getChildByName(tbLabel[nIndex]),"Label")

	if flag then 
		local txt = nil
		local strAName = tbActivateValue[nIndex]	
		local nextLv = self.nLevel - 1
		local nextValue =  0
		if nextLv > 0 then nextValue = tonumber(playerXianMai[nextLv][strAName]) end
		local countPlayer = playerNum + nextValue
		label:setColor(ccc3(35,220,55))
		local nNum = initActivateVlaue - nextValue
		local tiemrId = g_Timer:pushLimtCountTimer(nNum,0,function(f,falge)
			countPlayer = countPlayer + 1
			txt = tbLabelName[nIndex].."+"..countPlayer
			label:setText(txt)
			if falge then 
				label:setColor(ccc3(255,255,255)) 
				label:setText(tbLabelName[nIndex].."+"..playerNum + addNum)
			end
		end)
		table.insert(self.tbTiemrID_,tiemrId)
	else
		--先攻值
		local initiative = playerXianMai[self.nLevel].Initiative
		local Label_Initiative = tolua.cast(Image_XianMaiPNL:getChildByName("Label_Initiative"),"Label")
	
		Label_Initiative:setText( _T("先攻").."+"..initiative)

		label:setColor(ccc3(255,255,255))
		label:setText(tbLabelName[nIndex].."+"..playerNum+addNum)

		local strAName = tbActivateValue[nIndex]	
		local nextLv = self.nLevel - 1
		local nextActivateValue =  0
		if nextLv > 0 then nextActivateValue = tonumber(playerXianMai[nextLv][strAName]) end
		
		if not nextActivateValue then nextActivateValue = 0 end
		local Image_Prop = tolua.cast(Button_XianMai:getChildByName("Image_Prop"),"ImageView")
		local BitmapLabel_PropValue = tolua.cast(Image_Prop:getChildByName("BitmapLabel_PropValue"),"LabelBMFont")
		BitmapLabel_PropValue:setText("+"..initActivateVlaue - nextActivateValue)
		
		local Image_XianMaiPropChar = tolua.cast(Image_Prop:getChildByName("Image_XianMaiPropChar"),"ImageView")
		--需要修改
		if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
			Image_XianMaiPropChar:setPositionX(20)
			BitmapLabel_PropValue:setPositionX(Image_XianMaiPropChar:getPositionX())
		end
	end
	
	if nIndex == 1 then
		--更新一次
		--仙脉等级
		local Image_XianMaiPNL = tolua.cast(rootWidget:getChildByName("Image_XianMaiPNL"),"ImageView")
		local Label_XianMaiName = tolua.cast(Image_XianMaiPNL:getChildByName("Label_XianMaiName"),"Label")
		Label_XianMaiName:setText(string.format(_T("%s Lv.%d"), playerXianMai[self.nLevel].Name, self.nLevel))
		g_SetXianMaiNameColor(Label_XianMaiName, playerXianMai[self.nLevel].ColorType)
	end
end


--请求激活元素
function Game_XianMai:requestElementActiveRequest(nIndex)
	local rootMsg = zone_pb.ElementActiveRequest()
	rootMsg.index = nIndex - 1
	g_MsgMgr:sendMsg(msgid_pb.MSGID_ELEMENT_ACTIVE_REQUEST, rootMsg)
end

--激活元素成功
function Game_XianMai:elementActiveResponse(tbMsg)
	cclog("---------Game_XianMai:elementActiveResponse----")
	cclog("----激活元素成功----")
	local rootMsg = zone_pb.ElementActiveResponse()
	rootMsg:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(rootMsg)
	cclog(msgInfo)
	local nIndex = rootMsg.index + 1;	--元素的下标
	local update_num = rootMsg.update_num;	--元素数量
	local active_info =rootMsg.active_info; -- 激活信息
	
	local wndInstance = g_WndMgr:getWnd("Game_XianMai")
	if  wndInstance then 
		local rootWidget = wndInstance.rootWidget
		local Image_XianMaiPNL = tolua.cast(rootWidget:getChildByName("Image_XianMaiPNL"),"ImageView")
		local Image_XueMaiPNL = tolua.cast(rootWidget:getChildByName("Image_XueMaiPNL"),"ImageView")
		
		local Button_XianMai = tolua.cast(Image_XianMaiPNL:getChildByName("Button_XianMai"..nIndex),"Button")
		local armature,userAnimation = g_CreateCoCosAnimationWithCallBacks("XianMaiActivate", nil, nil, 5)
		armature:setPositionY(5)
		Button_XianMai:addNode(armature)
		userAnimation:playWithIndex(0)	
		local Image_Prop = tolua.cast(Button_XianMai:getChildByName("Image_Prop"),"ImageView")	
		Image_Prop:setVisible(true)
		local Image_XueMai = tolua.cast(Button_XianMai:getChildByName("Image_XueMai"),"ImageView")
		Image_XueMai:setVisible(true)
		--可激活
		local Image_AddTip = tolua.cast(Button_XianMai:getChildByName("Image_AddTip"),"ImageView")
		self.activateInfo = g_XianMaiInfoData:setActiveInfo(self.activateInfo,nIndex,1)
		local getBits = API_GetBitsByPos(self.activateInfo,nIndex)
		if getBits == GAME_XIANMAI_ACTIVATE then 
			Image_AddTip:setVisible(false)
			Button_XianMai:setTouchEnabled(false)
			--更新 元素数量
			self.tbElementList = g_XianMaiInfoData:setTbElementList(nIndex,update_num)
			local Button_XueMai = tolua.cast(Image_XueMaiPNL:getChildByName("Button_XueMai"..nIndex),"Button")
			local Label_Num = tolua.cast(Button_XueMai:getChildByName("Label_Num"),"Label")
			Label_Num:setText(update_num)
			wndInstance:addProperty(nIndex,true)
		end
		
		g_Hero:refreshTeamMemberAddProps()
		
		g_addUpgradeGuide(wndInstance.Button_Evolute, ccp(60, 20), nil, g_CheckXianMai() == STATE_TYPE.TYPE_BREAK)
	end
end

--请求一键激活元素
function Game_XianMai:requestOnekeyActiveResponse()
	g_MsgMgr:sendMsg(msgid_pb.MSGID_ONEKEY_ACTIVE_REQUEST)
end

--一键激活元素成功
function Game_XianMai:onekeyActiveResponse(tbMsg)
	cclog("---------Game_XianMai:elementActiveResponse----")
	local rootMsg = zone_pb.OnekeyActiveResponse()
	rootMsg:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(rootMsg)
	cclog(msgInfo)
	
	local active_info = rootMsg.active_info;	--新激活元素
	local eleinfo = rootMsg.eleinfo 					--元素的信息
	self.activateInfo = active_info
	
	local rootWidget = self.rootWidget
	if not rootWidget then return end 
	local Image_XianMaiPNL = tolua.cast(rootWidget:getChildByName("Image_XianMaiPNL"),"ImageView")
	local Image_XueMaiPNL = tolua.cast(rootWidget:getChildByName("Image_XueMaiPNL"),"ImageView")
	local nNum = playerXianMai[self.nLevel].NeedElementNum
	for key,value in ipairs(eleinfo) do
		local nIndex = value.index + 1
		local Button_XianMai = tolua.cast(Image_XianMaiPNL:getChildByName("Button_XianMai"..nIndex),"Button")
		local Image_Prop = tolua.cast(Button_XianMai:getChildByName("Image_Prop"),"ImageView")	
		
		--可激活
		local Image_AddTip = tolua.cast(Button_XianMai:getChildByName("Image_AddTip"),"ImageView")
		local Image_XueMai = tolua.cast(Button_XianMai:getChildByName("Image_XueMai"),"ImageView")
		local updateNum = value.update_num
		local getBits = API_GetBitsByPos(active_info,nIndex)
		if getBits == GAME_XIANMAI_ACTIVATE and self.tbElementList[nIndex] >= nNum then
			local function animaitonOver()
				g_MsgNetWorkWarning:closeNetWorkWarning()
			end
			local armature,userAnimation = g_CreateCoCosAnimationWithCallBacks("XianMaiActivate", nil, animaitonOver, 5)	
			Button_XianMai:addNode(armature)
			userAnimation:playWithIndex(0)	
			self.activateInfo = g_XianMaiInfoData:setAllByActiveInfo(active_info)
			Image_XueMai:setVisible(true)
			--更新 元素数量 Image_XueMai
			self.tbElementList = g_XianMaiInfoData:setTbElementList(nIndex,updateNum)
			local Button_XueMai = tolua.cast(Image_XueMaiPNL:getChildByName("Button_XueMai"..nIndex),"Button")
			local Label_Num = tolua.cast(Button_XueMai:getChildByName("Label_Num"),"Label")
			Label_Num:setText(updateNum)
			Image_AddTip:setVisible(false)
			Button_XianMai:setTouchEnabled(false)
			
			self:addProperty(nIndex,true)
			
			Image_Prop:setVisible(true)
		elseif updateNum < nNum  then 
			Image_XueMai:setVisible(false)
		end
	end
	
	g_Hero:refreshTeamMemberAddProps()
	
	g_addUpgradeGuide(self.Button_Evolute, ccp(60, 20), nil, g_CheckXianMai() == STATE_TYPE.TYPE_BREAK)
	local function guideAnimationEndEvent()
		if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationEnd", "XianMaiActivate") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	self.gTimerIdPush = g_Timer:pushTimer(0.8, guideAnimationEndEvent)
end

--请求仙脉突破
function Game_XianMai:requestXianmaiBreachResponse()
	g_MsgMgr:sendMsg(msgid_pb.MSGID_XIANMAI_BREACH_REQUEST)
end

--仙脉突破响应
function Game_XianMai:xianmaiBreachResponse(tbMsg)
	local rootMsg = zone_pb.XianmaiBreachResponse()
	rootMsg:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(rootMsg)
	cclog(msgInfo)

	local xianmai_lv = rootMsg.xianmai_lv --仙脉等级
	
	local wndInstance = g_WndMgr:getWnd("Game_XianMai")
	if wndInstance then
		local player = playerXianMai[wndInstance.nLevel]
		if not player then return end
		
		local curPlayer = playerXianMai[xianmai_lv]
		local playerValue = player.Initiative
		local count = curPlayer.Initiative - player.Initiative
		
		wndInstance.activateInfo = g_XianMaiInfoData:setAllByActiveInfo(0)
		wndInstance.nLevel = g_XianMaiInfoData:setXianmaiLevel(xianmai_lv)
		
		local rootWidget = wndInstance.rootWidget
		if not rootWidget or not rootWidget:isExsit() then return end 
		local Image_XianMaiPNL = tolua.cast(rootWidget:getChildByName("Image_XianMaiPNL"),"ImageView")
		
		local function animaitonOver()
			local Label_Initiative = tolua.cast(Image_XianMaiPNL:getChildByName("Label_Initiative"),"Label")
			if not Label_Initiative or not Label_Initiative:isExsit() then return end
			Label_Initiative:setColor(ccc3(35,220,55))
			g_Timer:pushLimtCountTimer(count,0.2,function(f,falg)
				if not g_WndMgr:getWnd("Game_XianMai") then return true end
				playerValue = playerValue + 1
				if not Label_Initiative or not Label_Initiative:isExsit() then
					g_MsgNetWorkWarning:closeNetWorkWarning()
					return
				end

				Label_Initiative:setText( _T("先攻").."+"..playerValue)
				if falg then 
					Label_Initiative:setColor(ccc3(255,255,255))
					Label_Initiative:setText( _T("先攻").."+"..curPlayer.Initiative)
					g_MsgNetWorkWarning:closeNetWorkWarning()
					
				end
			end)
			for i = 1,7 do 
				local Button_XianMai = tolua.cast(Image_XianMaiPNL:getChildByName("Button_XianMai"..i),"Button")	
				local armature,userAnimation = g_CreateCoCosAnimation("XianMaiEvolute", function() 
					wndInstance:activate()
				end, 5)	
				Button_XianMai:addNode(armature)
				userAnimation:playWithIndex(0)	
				wndInstance:addProperty(i,true)
			end
			
		
		end
		
		local function animaitonDisppear()
			g_Hero:refreshTeamMemberAddProps()
		end
		g_ShowCardConsumeAnimation(Image_XianMaiPNL,nil,nil,animaitonDisppear,animaitonOver)
		g_addUpgradeGuide(wndInstance.Button_Evolute, ccp(60, 20), nil, g_CheckXianMai() == STATE_TYPE.TYPE_BREAK)
	end
	
	
	local function guideAnimationEndEvent()
		if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationEnd", "XianMaiEvolute") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	self.gTimerIdPush = g_Timer:pushTimer(3.6, guideAnimationEndEvent)
end

--[[
	return nNum 还没有激活的可以激活 的总数
	return nNum 可以进阶了 为 1
]]
function Game_XianMai:bitsByPosActivate()
	local nNum = 0
    local activateInfo = g_XianMaiInfoData:getActiveInfo()
    local nLevel = g_XianMaiInfoData:getXianmaiLevel() --仙脉等级
    local tbElementList = g_XianMaiInfoData:getTbElementList() --元素
	for i = 1,7 do
		local getBits = API_GetBitsByPos(activateInfo,i)
		if getBits == GAME_XIANMAI_NOT_ACTIVATE then --还没有激活
			local needNum = playerXianMai[nLevel].NeedElementNum
			if tbElementList[i] < needNum  then --某一个元素数量不足 
			else
				nNum = nNum + 1
			end
		end
	end

	if nNum > 0 then
		return nNum
	end
	playerXianMai = g_DataMgr:getCsvConfig("PlayerXianMai") or {} 
	if nNum == 0 and nLevel < #playerXianMai  then 
		nNum = 1
	end
	
	return nNum
end

function Game_XianMai:ModifyWnd_viet_VIET()
	local rootWidget = self.rootWidget
	if not rootWidget or not rootWidget:isExsit() then return end 
	local Image_XianMaiPNL = tolua.cast(rootWidget:getChildByName("Image_XianMaiPNL"),"ImageView")
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		local Label_HP = tolua.cast(Image_XianMaiPNL:getChildByName("Label_HP"),"Label")
		local Label_PhyAttack = tolua.cast(Image_XianMaiPNL:getChildByName("Label_PhyAttack"),"Label")
		local Label_MagAttack = tolua.cast(Image_XianMaiPNL:getChildByName("Label_MagAttack"),"Label")
		local Label_SkillAttack = tolua.cast(Image_XianMaiPNL:getChildByName("Label_SkillAttack"),"Label")		
		local size = -180
		Label_HP:setPositionX(size)
		Label_PhyAttack:setPositionX(size)
		Label_MagAttack:setPositionX(size)
		Label_SkillAttack:setPositionX(size)
		
		local Label_Initiative = tolua.cast(Image_XianMaiPNL:getChildByName("Label_Initiative"),"Label")
		local Label_PhyDefence = tolua.cast(Image_XianMaiPNL:getChildByName("Label_PhyDefence"),"Label")
		local Label_MagDefence = tolua.cast(Image_XianMaiPNL:getChildByName("Label_MagDefence"),"Label")
		local Label_SkillDefence = tolua.cast(Image_XianMaiPNL:getChildByName("Label_SkillDefence"),"Label")
		local size = 0
		Label_Initiative:setPositionX(size)
		Label_PhyDefence:setPositionX(size)
		Label_MagDefence:setPositionX(size)
		Label_SkillDefence:setPositionX(size)		
	end
end