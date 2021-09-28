-- --------------------------------------------------------------------------------------
-- -- 文件名:	HJW_HuntFate.lua
-- -- 版  权:	(C)深圳美天互动科技有限公司
-- -- 创建人:	
-- -- 日  期:	2014-04-08 4:37
-- -- 版  本:	1.0
-- -- 描  述:	
-- -- 应  用:  
-- ---------------------------------------------------------------------------------------

Game_HuntFate1 = class("Game_HuntFate1")
Game_HuntFate1.__index = Game_HuntFate1

local npcName = {
	_T("小师妹"),
	_T("鬼谷子"),
	_T("张道陵"),
	_T("姜子牙"),
	_T("太二真人"),
}
local test_X = {240,430,630,850,1050}
local tbSprite = {}
function Game_HuntFate1:initWnd()

	--单个猎妖
	g_FormMsgSystem:RegisterFormMsg(FormMsg_HuntFate_Info,handler(self,self.oneHuntFate))
	--一键猎妖
	g_FormMsgSystem:RegisterFormMsg(FormMsg_HuntFate_OneKeyHuntFate,handler(self,self.oneKeyHuntFate))
	--单个出售
	g_FormMsgSystem:RegisterFormMsg(FormMsg_HuntFate_OneSell,handler(self,self.oneSell))
	
	--一键出售
	g_FormMsgSystem:RegisterFormMsg(FormMsg_HuntFate_OneKeySell,handler(self,self.oneKeySellUpdate))
	--一键拾取
	g_FormMsgSystem:RegisterFormMsg(FormMsg_HuntFate_OneKeyHarvest,handler(self,self.oneKeyPickupUpdate))
	--单个拾取
	g_FormMsgSystem:RegisterFormMsg(FormMsg_HuntFate_OneHarvest,handler(self,self.oneHarvestUpate))
	
	--狂暴猎妖
	g_FormMsgSystem:RegisterFormMsg(FormMsg_HuntFate_FolieHuntFate,handler(self,self.RageHuntRequest))
	--元宝八连抽
	g_FormMsgSystem:RegisterFormMsg(FormMsg_HuntFate_YuanBaoHuntFate,handler(self,self.YangBaoHuntFate))
	

	self.armature = nil;
	self.objBox  = nil;
	self.checkBox_ = {};
	
	self.Summon_FateShape = nil
	
	self.nHuntFateStep = 0
		
	local rootWidget = self.rootWidget
	
	self.Image_Fate = tolua.cast(rootWidget:getChildByName("Image_Fate"),"ImageView")
	self.Image_CoverPNL = tolua.cast(rootWidget:getChildByName("Image_CoverPNL"),"ImageView")
	self.Image_FateBase = tolua.cast(rootWidget:getChildByName("Image_FateBase"),"ImageView")
	self.Image_FateBack = tolua.cast(rootWidget:getChildByName("Image_FateBack"),"ImageView")
	self.Image_Name = tolua.cast(rootWidget:getChildByName("Image_Name"),"ImageView")
	self.Label_Name = tolua.cast(self.Image_Name:getChildByName("Label_Name"),"Label")
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		self.Label_Name:setFontSize(16)
	end
	--初始时隐藏猎妖Iocn 再 单个猎妖的时候 会显示并更新
	self.Image_Fate:setVisible(false)
	self.Image_Name:setVisible(false)

	
	--猎妖的旋转动画
	self:initRotatActionView()
	--创建 8个猎妖位
	self:saveHuntFateItemByImage()
	
	local ImageView_HuntFateOptionPNL = tolua.cast(rootWidget:getChildByName("ImageView_HuntFateOptionPNL"),"ImageView")
	
	local Image_SummonTip = tolua.cast(self.rootWidget:getChildByName("Image_SummonTip"),"ImageView")
	g_CreateScaleInOutAction(Image_SummonTip)

	local function onClickSelect(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			
			local nOptionIndex = pSender:getTag()
			
			local CheckBox_HuntOption = tolua.cast(ImageView_HuntFateOptionPNL:getChildByName("CheckBox_HuntOption"..nOptionIndex),"CheckBox")
			if CheckBox_HuntOption:getSelectedState() then 
				self:onTouchScreen()
			else
				local types = 1
				local nIndex = g_FateData:getNpcStatsByIndex()
				if nOptionIndex >= 4 then types = 2 end
				local txt = string.format(_T("我正在休息呢，去找【%s】帮忙吧！"), npcName[nIndex])
				g_ClientMsgTips:showTalk({ text = txt, x = test_X[nOptionIndex], y = 120 , anchorType = types})
			end
			
		end
	end

	for nOptionIndex = 1,5 do
		local CheckBox_HuntOption = tolua.cast(ImageView_HuntFateOptionPNL:getChildByName("CheckBox_HuntOption"..nOptionIndex),"CheckBox")
		CheckBox_HuntOption:setTouchEnabled(false)
		
		local Image_ClickCover = tolua.cast(CheckBox_HuntOption:getChildByName("Image_ClickCover"), "ImageView")
		Image_ClickCover:setTag(nOptionIndex)
		Image_ClickCover:setTouchEnabled(true)
		Image_ClickCover:addTouchEventListener(onClickSelect)

		table.insert(self.checkBox_, CheckBox_HuntOption)
		
		self:checkBoxSelectedState(CheckBox_HuntOption, nil)
	end
	
	local CheckBox_HuntOption1 = tolua.cast(ImageView_HuntFateOptionPNL:getChildByName("CheckBox_HuntOption1"),"CheckBox")
	self:checkBoxSelectedState(CheckBox_HuntOption1, nil)
	
end

function Game_HuntFate1:openWnd()
	self.count = 1
	--在点击单个猎妖时没有报妖兽放入妖兽框时的情况 隐藏图案
	-- if self.Image_Fate or self.Image_Name then 
		-- self.Image_Fate:setVisible(false)
		-- self.Image_Name:setVisible(false)
	-- end
	
	self.rootWidget:stopAllActions()
	self.rootWidget:removeAllNodes()
	
	self.clickSenderIndex = 0

	local function resetAnimationState()
		self.nHuntFateStep = 0
	end
	local fateList = g_FateData:getAllTableFateList()
	for key,value in pairs(fateList) do
		if value.id ~= 0 then 
			local id = value.id
			local lv = value.lv
			local info = g_FateData:getCardFateInfo(id,lv)
			self:refreshSlotByIndex(key,info,resetAnimationState,nil)
			self.clickSenderIndex = key
		end
	end
	
	local function pickupCover()
		if not self.warning then 
			self.warning =  Layout:create()
		end
		self.warning:setSize(CCSize(1280,720))
		local function pickupCreate(pSender,eventType)
			if eventType == ccs.TouchEventType.ended then
				--收取 
				if self.nHuntFateStep == 2 then --收取 
					self:cleanCenterLightAni(true,nil,function() 
						self.warning:removeFromParentAndCleanup(false)
						self.warning = nil
					end)
				end
			end
		end
		self.warning:setTouchEnabled(true)
		self.warning:addTouchEventListener(pickupCreate)
		self.rootWidget:addChild(self.warning,INT_MAX)
	end
	self.pickupCover = pickupCover
	
	local function onClick_Image_CoverPNL(pSender, nTag)
		local wndInstance = g_WndMgr:getWnd("Game_HuntFate1")
		if wndInstance then		
			wndInstance:onTouchScreen()
		
		end
	end
	local Image_CoverPNL = tolua.cast(self.rootWidget:getChildByName("Image_CoverPNL"),"ImageView")
	g_SetBtnWithGuideCheck(Image_CoverPNL, nil, onClick_Image_CoverPNL, true)
	
	self:oneKeyfunction() --一键功能
	self:pickup()
	
	self:RageHunt()
	--元宝八连抽
	self:EightcontinuousHunt()

	local Button_Fate = tolua.cast(self.rootWidget:getChildByName("Button_Fate"),"Button")
	--妖兽界面
	local function onClick_Button_Fate(pSender, nTag)
		g_WndMgr:openWnd("Game_CardFate1",{})
	end
	g_SetBtnWithPressImage(Button_Fate, 1, onClick_Button_Fate, true, 1)
	
	local Button_YaoShouBook = tolua.cast(self.rootWidget:getChildByName("Button_YaoShouBook"),"Button")
	--妖兽图鉴
	local function onClick_Button_YaoShouBook(pSender, nTag)
		g_WndMgr:showWnd("Game_YaoShouBook",{})
	end
	g_SetBtnWithPressImage(Button_YaoShouBook, 1, onClick_Button_YaoShouBook, true, 1)
	
	--猎妖师
	local nIndex = g_FateData:getNpcStatsByIndex()
	local ImageView_HuntFateOptionPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_HuntFateOptionPNL"),"ImageView")
	local CheckBox_HuntOption = tolua.cast(ImageView_HuntFateOptionPNL:getChildByName("CheckBox_HuntOption"..nIndex),"CheckBox")
	self:checkBoxSelectedState(CheckBox_HuntOption, nil)
	self:freeOfChargeHuntFate()
	
end

function Game_HuntFate1:closeWnd()
	-- self.count = 1 
	self.huntList_ = nil
	self.clickSenderIndex = nil

	if self.armature  then 
		self.armature:removeFromParentAndCleanup(true)
		self.armature  = nil
	end
	
	g_FateData:removeCoverFate()

	if self.rootWidget:getChildByTag(0x88888811) then
		self.rootWidget:getChildByTag(0x88888811):removeFromParentAndCleanup(true)
	end	

	g_FormMsgSystem:UnRegistFormMsg(FormMsg_HuntFate_Info)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_HuntFate_OneKeyHuntFate)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_HuntFate_OneSell)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_HuntFate_OneKeySell)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_HuntFate_OneKeyHarvest)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_HuntFate_OneHarvest)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_HuntFate_FolieHuntFate)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_HuntFate_YuanBaoHuntFate)
end

--初始 界面 猎命盘子的旋转
function Game_HuntFate1:initRotatActionView()
	
	local rootWidget = self.rootWidget
	if not rootWidget then return end 
	
	local Image_BaGuaPNL = tolua.cast(rootWidget:getChildByName("Image_BaGuaPNL"),"ImageView")
	Image_BaGuaPNL:setVisible(true)
	
	local Image_BaGuaLightPNL = tolua.cast(rootWidget:getChildByName("Image_BaGuaLightPNL"),"ImageView")
	Image_BaGuaLightPNL:setVisible(true)
	
	local Image_BaGuaLightL = tolua.cast(Image_BaGuaLightPNL:getChildByName("Image_BaGuaLightL"),"ImageView")
	Image_BaGuaLightL:setOpacity(150)
	
	local Image_BaGuaLightR = tolua.cast(Image_BaGuaLightPNL:getChildByName("Image_BaGuaLightR"),"ImageView")
	Image_BaGuaLightR:setOpacity(150)
	
	local ccSpriteBaGuaLightL = tolua.cast(Image_BaGuaLightL:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSpriteBaGuaLightL, 2)
	
	local ccSpriteBaGuaLightR = tolua.cast(Image_BaGuaLightR:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSpriteBaGuaLightR, 2)
	
	local Image_FateBase = tolua.cast(rootWidget:getChildByName("Image_FateBase"),"ImageView")
	self:rotateAction(Image_FateBase, 45, 360)
	
	local Image_CompassBaseCirclePNL = tolua.cast(rootWidget:getChildByName("Image_CompassBaseCirclePNL"),"ImageView")
	self:rotateAction(Image_CompassBaseCirclePNL, 45, -360)
	
	local Image_SlotPNL = tolua.cast(rootWidget:getChildByName("Image_SlotPNL"),"ImageView")
	local coverY = -360
	local slotY = 360
	for i = 1,8 do 
		if i > 4 then coverY = 360;slotY = -360 end
		local Image_Slot = tolua.cast(Image_SlotPNL:getChildByName("Image_Slot"..i),"ImageView")
		self:rotateAction(Image_Slot, 45, slotY)
		
		local Image_Cover = tolua.cast(Image_SlotPNL:getChildByName("Image_Cover"..i),"ImageView")
		self:rotateAction(Image_Cover, 45, coverY)
	end

end

function Game_HuntFate1:onTouchScreen()
	g_playSoundEffect("Sound/ButtonClick.mp3")
	
	if self.nHuntFateStep == 0 then 
	
		local fateList = g_FateData:getAllTableFateList()
		local leng = #fateList
		for key = 1,leng do
			local value = g_FateData:getAloneFateList(key)
			if not value then return end
			
			if key == leng and value.id > 0 then 
				local txt = _T("妖兽已装满，请先拾取")
				g_ClientMsgTips:showMsgConfirm(txt)	
				return 
			end
			
			if value.id == 0 then
				local nType = macro_pb.HuntFateTimes
				local daily = g_Hero:IsDailyNoticeFull(nType)
				
				local nIndex = g_FateData:getNpcStatsByIndex()
				
				local txt =  string.format(_T("猎妖需要消耗%d铜钱, 您的铜钱不足是否进行招财？"), g_FateData:getFateGlobalCfgCsv(nIndex))
				if not g_CheckMoneyConfirm(g_FateData:getFateGlobalCfgCsv(nIndex), txt) then 
					return 
				end
				
				--拥有的异兽数
				local fateNum = g_Hero:getFateUnDressedAmmount()
				local fateMaxNum = g_VIPBase:getVipValue("FateMaxNum")
				if fateNum >= fateMaxNum then 
					g_ShowSysTips({text=_T("妖兽背包已经满了，请清理后再猎妖")})
					return
				end
				g_FateData:requestHuntFateHunt(nIndex)
				self.clickSenderIndex  = key
				self.pickupCover()
				break
			end
		end
	end
end
	
--------------begin---------以下是一些动画 或 动作--------------------------------

--旋转动画
function Game_HuntFate1:rotateAction(obj, x, y )
	local actionForever = CCRepeatForever:create( CCRotateBy:create(x, y) )
	obj:runAction(actionForever)
end

--
function Game_HuntFate1:checkBoxSelectedState(objCheckBox, bShowSusTips,nIndex)

	if self.armature  then 
		self.armature:removeFromParentAndCleanup(true)
		self.armature  = nil
	end
	
	if self.objBox then
		g_setImgShader(self.objBox:getVirtualRenderer(),pszGreyFragSource) --灰化
		self.objBox:setScale(1)
		self.objBox:setSelectedState(false)
	end
	
	--姜子牙猎妖
	local Button_SummonJiangZiYa = tolua.cast(self.rootWidget:getChildByName("Button_SummonJiangZiYa"),"Button")
	Button_SummonJiangZiYa:setVisible(true)
	if nIndex and nIndex == 4 then --姜子牙猎妖
		Button_SummonJiangZiYa:setVisible(false)
	end
	
	local armature,userAnimation = g_CreateCoCosAnimation("HuntFate_Cursor",nil,2)
	armature:setPosition(ccp(50,110))
	objCheckBox:addNode(armature)
	
	userAnimation:playWithIndex(0)

	self.armature = armature
	
	objCheckBox:setScale(1.1)
	objCheckBox:setSelectedState(true)
	g_setImgShader(objCheckBox:getVirtualRenderer(),pszNormalFragSource)

	self.objBox = objCheckBox
	
	if bShowSusTips then
		local tbWorldPos = objCheckBox:getWorldPosition()	
		local param = {
			text = string.format(_T("偶遇猎妖师%s"),npcName[nIndex]),
			layout = self.rootWidget,
			ccsColor = g_TbColorType[nIndex],
			fontSize = 24,
			x = tbWorldPos.x,
			y = tbWorldPos.y + 160
		}
		g_ShowSysTipsWord(param)
	end
	
end



---------endl--------以上是一些动画 或 动作----------
	
--多个刷新妖兽槽图标的函数
function Game_HuntFate1:refreshSlotByRange(key, value, funcEndCallBack, bIsOnceHunt)
	if not self.rootWidget then return end 
	local function refreshSlotByTimer()
		self:refreshSlotByIndex(key,value,funcEndCallBack,bIsOnceHunt)
	end
	local times = 0.2 * (key - 1)
	local actionDelay = CCDelayTime:create(times)
	local action1 = sequenceAction({actionDelay,CCCallFuncN:create(refreshSlotByTimer)})
	self.rootWidget:runAction(action1)
end

--[[
	刷新妖兽槽 妖兽图案
]]
function Game_HuntFate1:refreshSlot(bIsOnceHunt)
	local fateList = g_FateData:getAllTableFateList()
	local function resetAnimationState()
		self.nHuntFateStep = 0
	end
	
	local Image_SlotPNL = tolua.cast(self.rootWidget:getChildByName("Image_SlotPNL"),"ImageView")
	if bIsOnceHunt then
		for key,value in pairs(fateList) do		
			if value.id ~= 0 and self.clickSenderIndex == key then
				local id = value.id
				local lv = value.lv
				local info = g_FateData:getCardFateInfo(id,lv)
				self:refreshSlotByIndex(key,info,resetAnimationState,bIsOnceHunt)
				break;
			end
		end
	else
		--一键猎妖
		for key, value in pairs(fateList) do
			local Image_FatePos = tolua.cast(Image_SlotPNL:getChildByName("Image_FatePos"..key),"ImageView")
			local Image_HuntFateItem = tolua.cast(Image_FatePos:getChildByName("Image_HuntFateItem"..key),"ImageView")
			if value.id ~= 0 and Image_HuntFateItem:isVisible() == false then
				local cardFate = g_FateData:getCardFateInfo(value.id,value.lv)
				self:refreshSlotByRange(key, cardFate, resetAnimationState, bIsOnceHunt)
			end
		end
	end
end

--拾取妖兽时刷新玻璃球的函数
function Game_HuntFate1:cleanCenterFate(bIsOnceHunt,selcetType)

	self.Image_Fate:setVisible(false)
	self.Image_Name:setVisible(false)
	
	--猎妖师 --
	local nIndex = g_FateData:getNpcStatsByIndex()
	self.Image_CoverPNL:loadTexture(getUIImg("FateFrame"..nIndex))
	self.Image_FateBase:loadTexture(getUIImg("FateBase"..nIndex))
	self.Image_FateBack:loadTexture(getUIImg("FateBack"..nIndex))
	if not selcetType then --单独选择猎妖师的时候 不需要执行这个函数
		self:refreshSlot(bIsOnceHunt)
	end
end

--拾取妖兽时妖兽本身的一些动画
function Game_HuntFate1:cleanCenterFateAni(bIsOnceHunt)
	local wndInstance = g_WndMgr:getWnd("Game_HuntFate1")
	if wndInstance and wndInstance.rootWidget then 
	
		local function executeEndUpAction()
			g_SetBlendFuncSprite(wndInstance.Summon_FateShape, 2)
			wndInstance:cleanCenterFate(bIsOnceHunt)
		end
		
		-- tbHuntFate.Summon_FateShape:setVisible(true)
		if not wndInstance.Summon_FateShape then return end 
		
		local FateShape6 = CCFadeTo:create(0.35,255)
		local FateShape8 = CCFadeTo:create(0.2,0)
		local times = CCDelayTime:create(0.2)
		local timesTow = CCDelayTime:create(0.4)
		local func = CCCallFuncN:create(executeEndUpAction)
		local action = sequenceAction({times,FateShape6,func,timesTow,FateShape8})
		wndInstance.Summon_FateShape:runAction(action)
	end
end

--拾取妖兽时播放的闪光特效
function Game_HuntFate1:cleanCenterLightAni(bIsOnceHunt, funcSuccessiveHunt, funcEndCallBack)

	if self.nHuntFateStep ~= 2 then return end
	self.nHuntFateStep = 3
	
	self.rootWidget:stopAllActions()
	
	local function setZOrderRayInSide()
		g_SetBlendFuncSprite(tbSprite[1], 3)
		tbSprite[1]:setZOrder(101)
	end
	local spawn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.2,255), CCScaleTo:create(0.2,0))
	local spawm2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,9.12),CCFadeTo:create(0.35,255))
	local action_RayInSide = {
		spawn,CCCallFuncN:create(setZOrderRayInSide),spawm2,
		CCScaleTo:create(0.4,1),CCFadeTo:create(0.2,0)
	}
	
	local function setZOrderRayOutSide()
		g_SetBlendFuncSprite(tbSprite[2], 3)
		tbSprite[2]:setZOrder(102)		
	end
	local spawn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.2, 255),CCScaleTo:create(0.2,0))
	local spawn2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,4.56),CCFadeTo:create(0.35,255))
	local action_RayOutSide = {
		spawn,CCCallFuncN:create(setZOrderRayOutSide),spawn2,
		CCScaleTo:create(0.4, 1),CCFadeTo:create(0.2,0)
	}
	
	local spawn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.2,0),CCScaleTo:create(0.2,0))
	local action_ExplodeOutSide = { spawn }
	
	local spawn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.2,0),CCScaleTo:create(0.2,0))
	local action_ExplodeInSide = { spawn }

	local function setZOrderCrossLightHorizontal()
		tbSprite[5]:setZOrder(85)
	end	
	local spawn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.2,0),CCScaleTo:create(0.2,0,1.44))
	local spawn2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,5.13,1.44),CCFadeTo:create(0.35, 255))
	local action_CrossLightHorizontal = {
		spawn,CCCallFuncN:create(setZOrderCrossLightHorizontal),spawn2,
		CCScaleTo:create(0.4, 0)
	}

	local function setZOrderCrossLightVertical()
		tbSprite[6]:setZOrder(86)
	end
	
	local spawn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.2,0),CCScaleTo:create(0.2,0,1.44))
	local spawn2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,2.57,1.44),CCFadeTo:create(0.35, 255))
	local action_CrossLightVertical = {
		spawn,CCCallFuncN:create(setZOrderCrossLightVertical),spawn2,
		CCScaleTo:create(0.4, 0),
	}
	local function setZOrderCircleInSideSmall()
		tbSprite[7]:setZOrder(87)
	end
	local spawn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.2,0), CCScaleTo:create(0.2,0))
	local spawn2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,1.04),CCFadeTo:create(0.35,255))
	local action_CircleInSideSmall = {
		spawn,CCCallFuncN:create(setZOrderCircleInSideSmall),spawn2,
		CCScaleTo:create(0.4,0.54),CCFadeTo:create(0.2, 0)
	}

	local function setZOrderCircleOutSideBig()
		tbSprite[8]:setZOrder(88)
	end
	local spawn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.2,0),CCScaleTo:create(0.2,0))
	local spawn2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,1.45),CCFadeTo:create(0.35, 255))
	local action_CircleOutSideBig = {
		spawn,CCCallFuncN:create(setZOrderCircleOutSideBig),spawn2,
		CCScaleTo:create(0.4,0.754),CCFadeTo:create(0.2,0)
	}
	local function setZOrderCircleOutSideSmall()
		tbSprite[9]:setZOrder(89)
	end
	local spawn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.2,0),CCScaleTo:create(0.2,0))
	local spawn2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35, 1.36),CCFadeTo:create(0.35, 255))
	local action_CircleOutSideSmall = {
		spawn,CCCallFuncN:create(setZOrderCircleOutSideSmall),spawn2,
		CCScaleTo:create(0.4,0.71),CCFadeTo:create(0.2, 0)
	}
	
	local function executeSuccessiveHunt()
		if funcSuccessiveHunt then funcSuccessiveHunt() end
	end
	local function executeCleanupAction()
		if funcEndCallBack then funcEndCallBack() end
		local wndInstance = g_WndMgr:getWnd("Game_HuntFate1")
		if wndInstance and wndInstance.rootWidget then 
			wndInstance.rootWidget:removeAllNodes()
			
			wndInstance.nHuntFateStep = 0
			wndInstance.Summon_FateShape = nil
		end
		--拾取妖兽时播放的闪光特效结束
		if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationEnd", "cleanCenterLightAni") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	local action_RootWidget = {
		CCDelayTime:create(0.2),CCCallFuncN:create(executeSuccessiveHunt),CCDelayTime:create(0.95),
		CCCallFuncN:create(executeCleanupAction)
	}

	local action = {
		action_RayInSide,action_RayOutSide,action_ExplodeOutSide,
		action_ExplodeInSide,action_CrossLightHorizontal,action_CrossLightVertical,
		action_CircleInSideSmall,action_CircleOutSideBig,action_CircleOutSideSmall,
		action_RootWidget
	}
	
	for i = 1, #tbSprite do 
		if tbSprite[i] then 
			tbSprite[i]:runAction( sequenceAction( action[i] ) )
		end
	end
	
	self.rootWidget:runAction(sequenceAction(action[10]))
	if bIsOnceHunt then
		self:cleanCenterFateAni(bIsOnceHunt)
	end
	--拾取妖兽时播放的闪光特效开始 时
	if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationStart", "cleanCenterLightAni") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end

-- --妖兽出现时刷新玻璃球的函数
function Game_HuntFate1:showCenterFate(CSV_CardFate)
	local wndInstance = g_WndMgr:getWnd("Game_HuntFate1")
	if wndInstance and wndInstance.rootWidget then 
		wndInstance.Image_Fate:setVisible(true)
		wndInstance.Image_Fate:setPosition(ccp(640+CSV_CardFate.OffsetX, 395+CSV_CardFate.OffsetY))
		wndInstance.Image_Fate:loadTexture(getIconImg(CSV_CardFate.Animation))
		wndInstance.Image_Name:setVisible(true)
		wndInstance.Label_Name:setText(CSV_CardFate.Name)
		g_SetWidgetColorBySLev(wndInstance.Label_Name, CSV_CardFate.ColorType)
		wndInstance.Image_CoverPNL:loadTexture(getUIImg("FateFrame"..CSV_CardFate.ColorType))
		wndInstance.Image_FateBase:loadTexture(getUIImg("FateBase"..CSV_CardFate.ColorType))
		wndInstance.Image_FateBack:loadTexture(getUIImg("FateBack"..CSV_CardFate.ColorType))
	end
end

--妖兽出现时妖兽本身的一些动画 id 
function Game_HuntFate1:showCenterFateAni(CSV_CardFate)
	local wndInstance = g_WndMgr:getWnd("Game_HuntFate1")
	if wndInstance and wndInstance.rootWidget then 

		wndInstance.Summon_FateShape = CCSprite:create(getIconImg(CSV_CardFate.Animation))
		if not wndInstance.Summon_FateShape then return  end
		
		g_SetBlendFuncSprite(wndInstance.Summon_FateShape,3)

		wndInstance.Summon_FateShape:setPosition(ccp(640+CSV_CardFate.OffsetX, 395+CSV_CardFate.OffsetY))
		wndInstance.Summon_FateShape:setOpacity(0)
		wndInstance.Summon_FateShape:setScale(0.3)
			
		wndInstance.Image_Fate:setPosition(ccp(640,410))
		wndInstance.Image_Fate:setOpacity(0)
		wndInstance.Image_Fate:setScale(0.3)

		local function repeatFateIconShape()
			g_SetBlendFuncSprite(wndInstance.Summon_FateShape,1)
			local actionForever_FateShape = {
				CCFadeTo:create(1.7,255),
				CCFadeTo:create(1.7,0)
			}
			local action = CCRepeatForever:create(sequenceAction(actionForever_FateShape))
			wndInstance.Summon_FateShape:runAction(action)
		end
		
		local spawn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.35,255),CCScaleTo:create(0.35,0.8))
		local action_FateShape = sequenceAction({
			CCDelayTime:create(0.35),spawn,CCFadeTo:create(0.35,0),CCCallFuncN:create(repeatFateIconShape)
		})
		
		local function showCenterFateFuncN()
			self:showCenterFate(CSV_CardFate)
		end
		local spawn = CCSpawn:createWithTwoActions(CCFadeTo:create(0.35,255),CCScaleTo:create(0.35,0.8))
		local action_Fate = sequenceAction({
			CCDelayTime:create(0.35),CCCallFuncN:create(showCenterFateFuncN),spawn
		})
		wndInstance.rootWidget:addNode(wndInstance.Summon_FateShape,91)
		wndInstance.Summon_FateShape:runAction(action_FateShape)
		wndInstance.Image_Fate:runAction(action_Fate)		
	end
end

--妖兽出现时播放的闪光特效
function Game_HuntFate1:showCenterLightAni(bIsOnceHunt, funcEndCallBack)

	local wndInstance = g_WndMgr:getWnd("Game_HuntFate1")		
	if wndInstance and wndInstance.rootWidget then 
		if wndInstance.nHuntFateStep ~= 0 then return end
		wndInstance.nHuntFateStep = 1
	
		wndInstance.rootWidget:stopAllActions()
		wndInstance.rootWidget:removeAllNodes()
		
		g_playSoundEffect("Sound/Ani_RewardStart.mp3")
				
		local Summon_RayInSide = CCSprite:create(getCocoAnimationImg("UpgradeEvent_Light2_1"))
		local Summon_RayOutSide = CCSprite:create(getCocoAnimationImg("UpgradeEvent_Light2_2")) 
		local Summon_ExplodeOutSide = CCSprite:create(getCocoAnimationImg("Summon_Explode1"))
		local Summon_ExplodeInSide = CCSprite:create(getCocoAnimationImg("Summon_Explode1"))
		
		local Summon_CrossLightHorizontal = CCSprite:create(getCocoAnimationImg("Summon_CrossLightBig"))
		local Summon_CrossLightVertical = CCSprite:create(getCocoAnimationImg("Summon_CrossLightBig"))
		local Summon_CircleInSideSmall = CCSprite:create(getCocoAnimationImg("Summon_CircleOutSideBig1"))
		local Summon_CircleOutSideBig = CCSprite:create(getCocoAnimationImg("Summon_CircleOutSideBig1"))
		local Summon_CircleOutSideSmall = CCSprite:create(getCocoAnimationImg("Summon_CircleOutSideSmall1"))
		
		tbSprite = {
			Summon_RayInSide , 
			Summon_RayOutSide, 
			Summon_ExplodeOutSide, 
			Summon_ExplodeInSide,
			Summon_CrossLightHorizontal,
			Summon_CrossLightVertical,
			Summon_CircleInSideSmall,
			Summon_CircleOutSideBig ,
			Summon_CircleOutSideSmall,
		}
	
		local function resetRayInSide()
			g_SetBlendFuncSprite(tbSprite[1], 4)
			tbSprite[1]:setZOrder(6)		
		end
		
		local function repeatRayInSide()
			local actionRotateBy_RayInSide = CCRotateBy:create(15,360)
			local actionForever_RayInSide = CCRepeatForever:create(actionRotateBy_RayInSide)
			tbSprite[1]:runAction(actionForever_RayInSide)
		end
		
		local spawn = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,1.14),CCFadeTo:create(0.35, 255))
		local spawn2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,2.736),CCFadeTo:create(0.35, 255))
		local action_RayInSide = {
			CCScaleTo:create(0.21,4.56),spawn,
			CCCallFuncN:create(resetRayInSide),spawn2,
			CCCallFuncN:create(repeatRayInSide)
		}
		
		local function resetRayOutSide()
			g_SetBlendFuncSprite(tbSprite[2], 4)
			tbSprite[2]:setZOrder(7)		
		end

		local function repeatRayOutSide()
			local actionRotateBy_RayOutSide = CCRotateBy:create(15,-360)
			local actionForever_RayOutSide = CCRepeatForever:create(actionRotateBy_RayOutSide)
			tbSprite[2]:runAction(actionForever_RayOutSide)
		end
		
		local spawnRayOutSide = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,1.14),CCFadeTo:create(0.35, 255))
		local spawnRayOutSide3 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,2.736),CCFadeTo:create(0.35, 255))
		local action_RayOutSide = {
			CCScaleTo:create(0.21, 4.56),spawnRayOutSide,CCCallFuncN:create(resetRayOutSide),
			spawnRayOutSide3,CCCallFuncN:create(repeatRayOutSide)
		}

		local function resetCrossLightHorizontal()
			tbSprite[5]:setZOrder(31)
		end
		local function repeatCrossLightHorizontal()
			local action_CrossLightHorizontal = {
				CCFadeTo:create(1,200),CCFadeTo:create(1,255)
			}
			local sequence = sequenceAction(action_CrossLightHorizontal)
			local action = CCRepeatForever:create(sequence)
			tbSprite[5]:runAction(action)
		end
		
		local spawn = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,2.565, 1.44),CCFadeTo:create(0.35, 255))
		local spawn2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,5.13, 1.44), CCFadeTo:create(0.35, 255))
		local action_CrossLightHorizontal = {
			CCScaleTo:create(0.35,10.26,1.44),spawn,CCCallFuncN:create(resetCrossLightHorizontal),
			spawn2,CCCallFuncN:create(repeatCrossLightHorizontal)
		}
		
		local function resetCrossLightVertical()
			tbSprite[6]:setZOrder(32)
		end
		local function repeatCrossLightVertical()
			local action_CrossLightVertical = {
				CCFadeTo:create(1,200),CCFadeTo:create(1,255),
			}
			local sequence = sequenceAction(action_CrossLightVertical)
			local action = CCRepeatForever:create(sequence)
			tbSprite[6]:runAction(action)
		end
		local spawn = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,1.285, 1.44),CCFadeTo:create(0.35, 255))
		local spawn2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,2.57, 1.44),CCFadeTo:create(0.35, 255))
		local action_CrossLightVertical = {
			CCScaleTo:create(0.35,5.14, 1.44),CCCallFuncN:create(resetCrossLightVertical),spawn,
			spawn2,CCCallFuncN:create(repeatCrossLightVertical)
		}
		
		local function resetExplodeOutSide()
			tbSprite[3]:setZOrder(33)
		end
		local function repeatExplodeOutSide()
			local actionRotateBy_ExplodeOutSide = CCRotateBy:create(15,-360)
			local actionForever_ExplodeOutSide = CCRepeatForever:create(actionRotateBy_ExplodeOutSide)
			tbSprite[3]:runAction(actionForever_ExplodeOutSide)
		end
		local spawn = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,2.05),CCFadeTo:create(0.35, 255))
		local spawn2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,0.64),CCFadeTo:create(0.35, 0))
		local spawn3 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,1.28),CCFadeTo:create(0.35, 255))
		local action_ExplodeOutSide = {
			CCEaseIn:create(spawn,5),CCEaseOut:create(spawn2,5),
			CCCallFuncN:create(resetExplodeOutSide),
			spawn3,CCCallFuncN:create(repeatExplodeOutSide)
		}

		local function resetExplodeInSide()
			g_SetBlendFuncSprite(tbSprite[4],2)
			tbSprite[4]:setZOrder(94)		
		end
		local function repeatExplodeInSide()
			local actionRotateBy_ExplodeInSide = CCRotateBy:create(15,-360)
			local actionForever_ExplodeInSide = CCRepeatForever:create(actionRotateBy_ExplodeInSide)
			tbSprite[4]:runAction(actionForever_ExplodeInSide)
		end
		local spawn = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,1.71),CCFadeTo:create(0.35, 255))
		local spawn2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,0.535),CCFadeTo:create(0.35, 0))
		local spawn3 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,1.07),CCFadeTo:create(0.35, 255))
		local action_ExplodeInSide = {
			CCEaseIn:create(spawn,5),CCEaseOut:create(spawn2,5),
			CCCallFuncN:create(resetExplodeInSide),spawn3,
			CCCallFuncN:create(repeatExplodeInSide)
		}
		
		local function resetCircleInSideSmall()
			tbSprite[7]:setZOrder(95)
		end
		local function repeatCircleInSideSmall()
			local actionRotateBy_CircleInSideSmall = CCRotateBy:create(15,-360)
			local actionForever_CircleInSideSmall = CCRepeatForever:create(actionRotateBy_CircleInSideSmall)
			tbSprite[7]:runAction(actionForever_CircleInSideSmall)
		end

		local spawn = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,1.33),CCFadeTo:create(0.35,255))
		local spawn2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,0.415),CCFadeTo:create(0.35, 150))
		local spawn3 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,0.83),CCFadeTo:create(0.35, 255))
		local action_CircleInSideSmall = {
			CCEaseIn:create(spawn,5),CCEaseOut:create(spawn2,5),
			CCCallFuncN:create(resetCircleInSideSmall),spawn3,
			CCCallFuncN:create(repeatCircleInSideSmall)
		}

		local function resetCircleOutSideBig()
			tbSprite[8]:setZOrder(36)
		end
		local function repeatCircleOutSideBig()
			local actionRotateBy_CircleOutSideBig = CCRotateBy:create(15,360)
			local actionForever_CircleOutSideBig = CCRepeatForever:create(actionRotateBy_CircleOutSideBig)
			tbSprite[8]:runAction(actionForever_CircleOutSideBig)
		end
		
		local spawn = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,1.86),CCFadeTo:create(0.35,255))
		local spawn2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,0.58),CCFadeTo:create(0.35,150))
		local spawn3 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,1.16), CCFadeTo:create(0.35, 255))

		local action_CircleOutSideBig = {
			CCEaseIn:create(spawn,5),CCEaseOut:create(spawn2,5),
			CCCallFuncN:create(resetCircleOutSideBig),spawn3,
			CCCallFuncN:create(repeatCircleOutSideBig)
		}

		local function resetCircleOutSideSmall()
			tbSprite[9]:setZOrder(37)
		end
		local function repeatCircleOutSideSmall()
			local actionRotateBy_CircleOutSideSmall = CCRotateBy:create(15,-360)
			local actionForever_CircleOutSideSmall = CCRepeatForever:create(actionRotateBy_CircleOutSideSmall)
			tbSprite[9]:runAction(actionForever_CircleOutSideSmall)
		end
		local spawn = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,1.74),CCFadeTo:create(0.35,255))
		local spawn2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.35,0.545),CCFadeTo:create(0.35,150))
		local spawn3 = CCSpawn:createWithTwoActions( CCScaleTo:create(0.35,1.09),CCFadeTo:create(0.35,255))

		local action_CircleOutSideSmall = {
			CCEaseIn:create(spawn,5),CCEaseOut:create(spawn2,5),
			CCCallFuncN:create(resetCircleOutSideSmall),spawn3,
			CCCallFuncN:create(repeatCircleOutSideSmall),
		}

		local typeNum = {3,3,4,4,1,1,1,1,1}
		local opacity = {255,255,0,0,255,255,0,0,0}
		local tbAction = {
			action_RayInSide,action_RayOutSide,action_ExplodeOutSide,
			action_ExplodeInSide,action_CrossLightHorizontal,action_CrossLightVertical,
			action_CircleInSideSmall,action_CircleOutSideBig,action_CircleOutSideSmall
		}
		local z = {101,102,83,84,31,32,88,89,90}

		for key,value in ipairs(tbSprite) do
			local sprite = value
			g_SetBlendFuncSprite(sprite,typeNum[key])
			sprite:setPosition(ccp(640,395))
			if key == 5 or key == 6 then
				if key == 5 then 
					sprite:setRotation(90)	
				end
				sprite:setScaleX(0)
				sprite:setScaleY(1.44)
			else
				sprite:setScale(0)
			end
			sprite:setOpacity(opacity[key])
			wndInstance.rootWidget:addNode(sprite,z[key])
			sprite:runAction(sequenceAction(tbAction[key]))
		end
		
		local function setCanCloseWnd()
			self.nHuntFateStep = 2
			
			if funcEndCallBack then
				funcEndCallBack()
			end
			--妖兽出现时播放的闪光特效
			if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationEnd", "showCenterLightAni") then
				g_PlayerGuide:showCurrentGuideSequenceNode()
			end
		end
		-- setCanCloseWnd()
		local action = sequenceAction({
			CCDelayTime:create(1.05),CCCallFuncN:create(setCanCloseWnd)
		})
		wndInstance.rootWidget:runAction(action)
		
		if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationStart", "showCenterLightAni") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
end

--刷新妖兽槽图标的函数 -- Image_HuntFateItem:retain()
function Game_HuntFate1:refreshSlotByIndex(nSlotIndex, tbSlotFateItem, funcEndCallBack, bIsOnceHunt)

	local Image_SlotPNL = tolua.cast(self.rootWidget:getChildByName("Image_SlotPNL"), "ImageView")
	local Image_FatePos = tolua.cast(Image_SlotPNL:getChildByName("Image_FatePos"..nSlotIndex), "ImageView")
	local Image_HuntFateItem = tolua.cast(Image_FatePos:getChildByName("Image_HuntFateItem"..nSlotIndex), "ImageView")
	Image_HuntFateItem:setVisible(true)
	Image_HuntFateItem:setOpacity(255)
	Image_HuntFateItem:loadTexture(getFateBaseAImg(tbSlotFateItem.ColorType))

	local Image_Frame = tolua.cast(Image_HuntFateItem:getChildByName("Image_Frame"),"ImageView")
	Image_Frame:loadTexture(getFateFrameImg(tbSlotFateItem.ColorType))
	
	local Panel_FateItem = tolua.cast(Image_HuntFateItem:getChildByName("Panel_FateItem"), "Layout")
	Panel_FateItem:setClippingEnabled(true)
	Panel_FateItem:setRadius(92)
	
	local Image_Fate = tolua.cast(Panel_FateItem:getChildByName("Image_Fate"),"ImageView")
	Image_Fate:setPosition(ccp(96+tbSlotFateItem.OffsetX, 96+tbSlotFateItem.OffsetY))
	Image_Fate:loadTexture(getIconImg(tbSlotFateItem.Animation))
	
	local Label_Level = tolua.cast(Image_HuntFateItem:getChildByName("Label_Level"),"Label")
	Label_Level:setText(_T("Lv.")..tbSlotFateItem.Level)
	g_SetWidgetColorBySLev(Label_Level, tbSlotFateItem.ColorType)
	
	--播放妖兽槽的妖兽出现的动画
	if not nSlotIndex then nSlotIndex = 1 end

	local Image_AnimationPos = tolua.cast(Image_SlotPNL:getChildByName("Image_AnimationPos"..nSlotIndex),"ImageView")
	g_AnimationHaloAction(Image_AnimationPos, 1,funcEndCallBack)
	
	-- g_MsgNetWorkWarning:closeNetWorkWarning();
	
	--一键猎妖的时候出现什么品质的猎妖师
	local ImageView_HuntFateOptionPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_HuntFateOptionPNL"),"ImageView")
	if bIsOnceHunt == false and self.huntList_[self.count] then
		local npcStatus = self.huntList_[self.count]
		local tNpcStatus = {}
		for key = 1, #npcStatus do
			tNpcStatus[key] = npcStatus[key]
		end
		g_FateData:setTableNpcStatus(tNpcStatus)
		
		self.count = self.count + 1
		--猎妖结束
		if self.count > #self.huntList_ then 
			self.count = 1 
			self.huntList_ = {}
			g_MsgNetWorkWarning:closeNetWorkWarning();
		end
		--猎妖师
		local nIndex = g_FateData:getNpcStatsByIndex()
		local CheckBox_HuntOption = tolua.cast(ImageView_HuntFateOptionPNL:getChildByName("CheckBox_HuntOption"..nIndex),"CheckBox")
		self:checkBoxSelectedState(CheckBox_HuntOption, true,nIndex)
		
		self.Image_CoverPNL:loadTexture(getUIImg("FateFrame"..nIndex))
		self.Image_FateBase:loadTexture(getUIImg("FateBase"..nIndex))
		self.Image_FateBack:loadTexture(getUIImg("FateBack"..nIndex))
	elseif bIsOnceHunt == true then
		local nIndex = g_FateData:getNpcStatsByIndex()
		local CheckBox_HuntOption = tolua.cast(ImageView_HuntFateOptionPNL:getChildByName("CheckBox_HuntOption"..nIndex),"CheckBox")
		self:checkBoxSelectedState(CheckBox_HuntOption, true, nIndex)
	end
	
end

--一键猎妖的特效
function Game_HuntFate1:quickHuntAni()
	local bIsOnceHunt = false 
	local function quickHuntAutoClean()
		local function quickHuntEndAction()
			self:refreshSlot(bIsOnceHunt)
		end
		self:cleanCenterLightAni(bIsOnceHunt, quickHuntEndAction)
	end
	self:showCenterLightAni(bIsOnceHunt, quickHuntAutoClean)
end

-- --一键拾取 ，卖出，猎妖
function Game_HuntFate1:oneKeyfunction()
	local rootWidget = self.rootWidget
	if not rootWidget then return end 
	--一键猎妖
	local Button_AutoHunt = tolua.cast(rootWidget:getChildByName("Button_AutoHunt"),"Button")
	--一键拾取 
	local Button_AutoPick = tolua.cast(rootWidget:getChildByName("Button_AutoPick"),"Button")
	--一键卖出 
	local Button_AutoSell = tolua.cast(rootWidget:getChildByName("Button_AutoSell"),"Button")
	--姜子牙猎妖
	local Button_SummonJiangZiYa = tolua.cast(rootWidget:getChildByName("Button_SummonJiangZiYa"),"Button")

	local function onClickAutoPick(pSender, nTag)
		local fateNum = g_Hero:getFateUnDressedAmmount()
		local fateMaxNum = g_VIPBase:getVipValue("FateMaxNum")
		if fateNum >= fateMaxNum then 
			g_ShowSysTips({text=_T("妖兽背包已经满了，请清理后再猎妖")})
			return
		end
		--没有妖兽拾取了
		if not g_FateData:canHarvestFateData() then return end 

		g_FateData:requestHuntFateAutoPick()
	end
	g_SetBtnWithPressImage(Button_AutoPick, 1, onClickAutoPick, true, 1)

	local function onClickAutoSell(pSender, nTag)
		--没有灰色妖兽出售了
		if not g_FateData:canSellFateData() then return end 
		g_FateData:requestHuntFateAutoSell()
		
	end
	g_SetBtnWithPressImage(Button_AutoSell, 1, onClickAutoSell, true, 1)

	local function onClickAutoHunt(pSender, nTag)

		-- if not g_FateData:compassFateMax() then 
			-- local txt = "封印罗盘已满，请先拾取妖兽"
			-- g_ClientMsgTips:showMsgConfirm(txt)		
			-- return 
		-- end 

		--拥有的异兽数量
		-- if not self:PackageMax() then return end 
		
		local nIndex = g_FateData:getNpcStatsByIndex()
		local nType = macro_pb.HuntFateTimes

		local daily = g_Hero:IsDailyNoticeFull(nType)
		if daily then
			local txt = string.format( _T("猎妖需要消耗%d铜钱, 您的铜钱不足是否进行招财？"),g_FateData:getFateGlobalCfgCsv(nIndex))
			if not g_CheckMoneyConfirm(g_FateData:getFateGlobalCfgCsv(nIndex), txt) then
				return
			end
		end
		
		if g_FateData:canSellFateData() then 
			g_FateData:requestHuntFateAutoSell()
		elseif g_FateData:canHarvestFateData() then 
			--拥有的异兽数量
			if not self:PackageMax() then return end 
			g_FateData:requestHuntFateAutoPick()
		else
			--拥有的异兽数量
			if not self:PackageMax() then return end 
			g_FateData:requestHuntFateAutoHunt()
		end
	end
	g_SetBtnWithPressImage(Button_AutoHunt, 1, onClickAutoHunt, true, 1)

	local types = VipType.VipBuyOpType_HuntJiangziyaTimes

	local function onClick(pSender, nTag)
		local fateList = g_FateData:getAllTableFateList()
		local leng = #fateList
		for key = 1,leng do
			local value = g_FateData:getAloneFateList(key)
			if not value then
				return
			end

			if key == leng and value.id > 0 then 
				local txt = _T("妖兽已装满，请先拾取")
				g_ClientMsgTips:showMsgConfirm(txt)	
				return 
			end
			
			if value.id == 0 then
                --拥有的异兽数量
				if not self:PackageMax() then return end
                local allNum = g_VIPBase:getVipLevelCntNum(types)
				local nNum = g_VIPBase:getAddTableByNum(types)
				if nNum >= allNum then 
					g_ShowSysTips({text=_T("您今日姜子牙的召唤次数已用完，下一VIP等级可以增加更多的召唤次数")})
					return 
				end

                --召唤姜子牙代币ID
                local fate_token_id = g_DataMgr:getGlobalCfgCsv("hunt_fate_danchou_token_id")
                --召唤姜子牙代币星级
                local fate_token_starlevel = g_DataMgr:getGlobalCfgCsv("hunt_fate_danchou_token_starlevel")
                --召唤姜子牙消耗代币数量
                local fate_token_num = g_DataMgr:getGlobalCfgCsv("hunt_fate_danchou_token_num")
                local nTokenNum = 0
                local strTokenName = "无"
                local strTokenIcon = "无"
                local objItemToken = g_Hero:getItemByCsv(fate_token_id, fate_token_starlevel)  --玩家代币
                if objItemToken ~= "无此道具" then
                    nTokenNum = objItemToken:getNum()     --代币数量
                    strTokenName = objItemToken:getName() --代币昵称
                end

                local str
                if nTokenNum >= fate_token_num then
				    str = string.format(_T("是否消耗%d个%s召唤姜子牙？"), fate_token_num, strTokenName)    	
                else
                    local gold = g_VIPBase:getVipLevelCntGold(types)
                    if not g_CheckYuanBaoConfirm(gold,_T("召唤姜子牙需要花费")..gold.._T("元宝，您的元宝不够是否前往充值？")) then
					    return
				    end
                    str = _T("是否花费")..gold.._T("元宝召唤姜子牙？")
                end				
				g_ClientMsgTips:showConfirm(str, function() 
					local function summonJiangZiYaFunc(tiems)
						g_ShowSysTips({text = _T("成功召唤1次姜子牙，您还可召唤")..allNum-tiems.._T("次。")})
						gTalkingData:onPurchase(TDPurchase_Type.TDP_HUNT_FATE_JIANGZIYA,1,gold)
					end
					g_VIPBase:responseFunc(summonJiangZiYaFunc)
					g_VIPBase:requestVipBuyTimesRequest(types)
					
					g_FateData:setTableNpcStatus({0,0,1,0})
					
					local nIndex = g_FateData:getNpcStatsByIndex()
					local ImageView_HuntFateOptionPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_HuntFateOptionPNL"),"ImageView")
					local CheckBox_HuntOption = tolua.cast(ImageView_HuntFateOptionPNL:getChildByName("CheckBox_HuntOption"..nIndex),"CheckBox")
	
					self:checkBoxSelectedState(CheckBox_HuntOption, false, nIndex)
					self.clickSenderIndex  = key
					self.pickupCover()
				end)		
				break
			end
		end
	end
	g_SetBtnWithOpenCheck(Button_SummonJiangZiYa, 1, onClick, true)
end

function Game_HuntFate1:saveHuntFateItemByImage()
	local Image_SlotPNL = tolua.cast(self.rootWidget:getChildByName("Image_SlotPNL"),"ImageView")
	for i = 1,8 do
		local Image_FatePos = tolua.cast(Image_SlotPNL:getChildByName("Image_FatePos"..i),"ImageView")
		local Image_HuntFateItem = tolua.cast(g_WidgetModel.Image_HuntFateItem:clone(),"ImageView")
		Image_HuntFateItem:setName("Image_HuntFateItem"..i)
		Image_HuntFateItem:setVisible(false)
		Image_HuntFateItem:setPosition(ccp(0,0))
		Image_FatePos:addChild(Image_HuntFateItem)
	end
end


--单个拾取
function Game_HuntFate1:pickup()
	local fateList = g_FateData:getAllTableFateList()
	local Image_SlotPNL = tolua.cast(self.rootWidget:getChildByName("Image_SlotPNL"),"ImageView")
	for key, value in pairs(fateList) do
		local Image_Slot = tolua.cast(Image_SlotPNL:getChildByName("Image_Slot"..key),"ImageView")
		local function onClickPickup(pSender, nTag)
			if value.id == 0 then 
				--g_ClientMsgTips:showMsgConfirm("此位置没有妖兽，去猎一个吧！")	
				return 
			end
			self.clickSenderIndex = nTag
			local fate = g_FateData:getCardFateInfo(value.id,value.lv)
			if fate.ColorType == 1 then 
				--出售
				g_FateData:requestHuntFateSell(nTag)
			else 
				--拥有的异兽数理
				if not self:PackageMax() then return end 
				--拾取
				g_FateData:requestHuntFatePick(nTag)
			end
		end
		g_SetBtnWithGuideCheck(Image_Slot, key, onClickPickup, true)
	end
end



--[[
	免费 猎妖次数 每天5次
]]
function Game_HuntFate1:freeOfChargeHuntFate()
	local nType = macro_pb.HuntFateTimes
	local daily = g_Hero:IsDailyNoticeFull(nType)
	local ImageView_HuntFateOptionPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_HuntFateOptionPNL"),"ImageView")
	for i = 1, 5 do
		local Image_NeedMoney = tolua.cast(ImageView_HuntFateOptionPNL:getChildByName("Image_NeedMoney"..i),"ImageView")
		local Label_NeedMoney = tolua.cast(Image_NeedMoney:getChildByName("Label_NeedMoney"),"Label")
		local txt = g_FateData:getFateGlobalCfgCsv(i)
		if not daily then 
			txt = _T("免费")
		end
		Label_NeedMoney:setText(txt)
	end
end
-- ------------以下-----服务器数据返回后的数据界面更新-----------------------------
--单个猎命刷新
function Game_HuntFate1:oneHuntFate(param)
	
	local id = param.id
	local nLevel = param.nLevel
	local npcStatus = param.npcStatus
	
	local cardFate = g_FateData:getCardFateInfo(id,nLevel)

	local cardFateName = cardFate.Name or ""
	
	--先使用上一次偶遇到的猎妖师
	local nIndex = g_FateData:getNpcStatsByIndex()
	local tbWorldPos = self.checkBox_[nIndex]:getWorldPosition()	
	local param = {
		text = npcName[nIndex].._T("帮您捕获妖兽")..cardFateName,
		layout = self.rootWidget,
		ccsColor = g_TbColorType[cardFate.ColorType],
		fontSize = 24,
		x = tbWorldPos.x,
		y = tbWorldPos.y + 160
	}
	g_ShowSysTipsWord(param)

	--再保存最新一次遇到的猎妖师
	local tNpcStatus = {}
	for key, value in ipairs(npcStatus) do
		tNpcStatus[key] = value
	end
	g_FateData:setTableNpcStatus(tNpcStatus)
	
	self:freeOfChargeHuntFate()
	
	self:showCenterLightAni(true)

	self:showCenterFateAni(cardFate)

end

--一键猎妖
function Game_HuntFate1:oneKeyHuntFate(huntList)
	if next(huntList) == nil then
		SendError("==oneKeyHuntFate==服务器数据下发妖兽数据为空==")
		g_MsgNetWorkWarning:closeNetWorkWarning()
		return
	end
	self:freeOfChargeHuntFate()
	self.huntList_ = huntList
	self:quickHuntAni()

end

--单个出售
function Game_HuntFate1:oneSell(param)
	local nIndex = param.nIndex
	local addGold = param.addGold
	local wndInstance = g_WndMgr:getWnd("Game_HuntFate1")
	if wndInstance and wndInstance.rootWidget  then
		local Image_SlotPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_SlotPNL"), "ImageView")
		local Image_FatePos = tolua.cast(Image_SlotPNL:getChildByName("Image_FatePos"..nIndex), "ImageView")
		local Image_HuntFateItem = tolua.cast(Image_FatePos:getChildByName("Image_HuntFateItem"..nIndex),"ImageView")
		local Image_AnimationPos = tolua.cast(Image_SlotPNL:getChildByName("Image_AnimationPos"..nIndex),"ImageView")
		g_FateData:failureAnimation(wndInstance.rootWidget, Image_AnimationPos, Image_HuntFateItem, funcCallBack)
		g_MsgNetWorkWarning:closeNetWorkWarning()
	end
end

--一键出售
function Game_HuntFate1:oneKeySellUpdate(indexList)
	local wndInstance = g_WndMgr:getWnd("Game_HuntFate1")
	if wndInstance and wndInstance.rootWidget  then
		local Image_SlotPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_SlotPNL"), "ImageView")

		for key = 1,#indexList do
			local value = indexList[key]
			local fateList = g_FateData:getAloneFateList(value)
			if not fateList then return end 
			local id = fateList.id 
			if id > 0 then 
				local cardFate = g_FateData:getCardFateInfo(id,fateList.lv)
				if cardFate.ColorType == 1 then
					g_FateData:setAloneFateList(value,0,0)
					--出售动画
					local Image_FatePos = tolua.cast(Image_SlotPNL:getChildByName("Image_FatePos"..value), "ImageView")
					local Image_HuntFateItem = tolua.cast(Image_FatePos:getChildByName("Image_HuntFateItem"..value),"ImageView")
					
					g_MsgNetWorkWarning:closeNetWorkWarning()
	
					local Image_AnimationPos = tolua.cast(Image_SlotPNL:getChildByName("Image_AnimationPos"..value),"ImageView")
					g_FateData:failureAnimation(wndInstance.rootWidget, Image_AnimationPos, Image_HuntFateItem,  function() 
						-- g_MsgNetWorkWarning:closeNetWorkWarning()
						-- echoj("出售完成==========================")
					end )
					
				end
			end
		end	

	end
end

--一键拾取
function Game_HuntFate1:oneKeyPickupUpdate(indexList)
	if not self.rootWidget then return end 
	local Image_SlotPNL = tolua.cast(self.rootWidget:getChildByName("Image_SlotPNL"), "ImageView")
	local listNum = #indexList
	for j = 1,listNum do 
		local i = indexList[j]
		local fateList = g_FateData:getAloneFateList(i)
		if fateList then 
			local id = fateList.id 
			local nLevel = fateList.lv
			if id > 0 then
				local Image_FatePos = tolua.cast(Image_SlotPNL:getChildByName("Image_FatePos"..i), "ImageView")
				local Image_HuntFateItem = tolua.cast(Image_FatePos:getChildByName("Image_HuntFateItem"..i),"ImageView")
				Image_HuntFateItem:setVisible(false)
				
				g_FateData:setAloneFateList(i,0,0)
				
				local cardFate = g_FateData:getCardFateInfo(id,nLevel)
				local param = {
					widget = self.rootWidget,key = i,cardFate = cardFate
				}
				g_FateData:moveToAnimation(param)
			end
		end	
	end
	
end

-- 单个拾取
function Game_HuntFate1:oneHarvestUpate(nIndex)

	local Image_SlotPNL = tolua.cast(self.rootWidget:getChildByName("Image_SlotPNL"), "ImageView")
	local Image_FatePos = tolua.cast(Image_SlotPNL:getChildByName("Image_FatePos"..nIndex), "ImageView")
	local Image_HuntFateItem = tolua.cast(Image_FatePos:getChildByName("Image_HuntFateItem"..nIndex),"ImageView")
	Image_HuntFateItem:setVisible(false)

	local fateList = g_FateData:getAloneFateList(nIndex)
	if not fateList then return end
	
	local id = fateList.id
	local nLevel = fateList.lv
	if id == 0 or nLevel == 0 then return end

	local cardFate = g_FateData:getCardFateInfo(id,nLevel)
	
	local param = { widget = self.rootWidget,key = nIndex,cardFate = cardFate}
	g_FateData:moveToAnimation(param)
	g_FateData:setAloneFateList(nIndex,0,0)
end

--狂暴猎妖
function Game_HuntFate1:RageHunt()
	local rootWidget = self.rootWidget
	local Button_RageHunt = tolua.cast(rootWidget:getChildByName("Button_RageHunt"),"Button")

	local function onClickAutoPick(pSender, nTag)
	
		--拥有的异兽数量
		if not self:PackageMax() then return end 
		
		g_FateData:requestCritHuntFate()
	end
	g_SetBtnOpenCheckWithPressImage(Button_RageHunt, 1, onClickAutoPick, true)
	
end

--元宝八连抽
function Game_HuntFate1:EightcontinuousHunt()

	local rootWidget = self.rootWidget
	local Button_YuanBaoHunt = tolua.cast(rootWidget:getChildByName("Button_YuanBaoHunt"),"Button")
	
	local function onClickAutoPick(pSender, nTag)
		if g_FateData:canSellFateData() then 
			g_FateData:requestHuntFateAutoSell()
		elseif g_FateData:canHarvestFateData() then 
			--拥有的异兽数理
			if not self:PackageMax() then return end 
			g_FateData:requestHuntFateAutoPick()
		else
			-- echoj("元宝抽")
            --拥有的异兽数理
			if not self:PackageMax() then return end
            --元宝八连代币ID
            local fate_balian_token_id = g_DataMgr:getGlobalCfgCsv("hunt_fate_balianchou_token_id")
            --元宝八连代币星级
            local fate_balian_token_starlevel = g_DataMgr:getGlobalCfgCsv("hunt_fate_balianchou_token_starlevel")
            --元宝八连消耗代币数量
            local fate_balian_token_num = g_DataMgr:getGlobalCfgCsv("hunt_fate_balianchou_token_num")
            local nTokenNum = 0
            local strTokenName = "无"
            local strTokenIcon = "无"
            local objItemToken = g_Hero:getItemByCsv(fate_balian_token_id, fate_balian_token_starlevel)  --玩家代币
            if objItemToken ~= "无此道具" then
                nTokenNum = objItemToken:getNum()     --代币数量
                strTokenName = objItemToken:getName() --代币昵称
            end
			
            local str
            if nTokenNum >= fate_balian_token_num then
                str = string.format(_T("是否消耗%d个%s进行八连猎妖？"), fate_balian_token_num, strTokenName)        
            else
                local gold = g_DataMgr:getGlobalCfgCsv("hunt_fate_balianchou_gold_cost")
                if not g_CheckYuanBaoConfirm(gold,_T("元宝八连抽需要花费")..gold.._T("元宝，您的元宝不够是否前往充值？")) then
				    return
			    end
                str = _T("是否花费")..gold.._T("元宝八连抽？")
            end 
	
			g_ClientMsgTips:showConfirm(str, function() 
				g_FateData:requestHuntFate8YuanBao()
			end)
		end
	end
	g_SetBtnOpenCheckWithPressImage(Button_YuanBaoHunt, 1, onClickAutoPick, true)
end

function Game_HuntFate1:RageHuntRequest(data)
	local wndInstance = g_WndMgr:getWnd("Game_HuntFate1")
	if wndInstance and wndInstance.rootWidget then 

		local function updateFateCover(cardFate)
			wndInstance.Image_Name:setVisible(true)
			wndInstance.Label_Name:setText(cardFate.Name)
			g_SetWidgetColorBySLev(wndInstance.Label_Name, cardFate.ColorType)
			wndInstance.Image_CoverPNL:loadTexture(getUIImg("FateFrame"..cardFate.ColorType))
			wndInstance.Image_FateBase:loadTexture(getUIImg("FateBase"..cardFate.ColorType))
			wndInstance.Image_FateBack:loadTexture(getUIImg("FateBack"..cardFate.ColorType))

			--先使用上一次偶遇到的猎妖师
			local nIndex = g_FateData:getNpcStatsByIndex()
			local tbWorldPos = self.checkBox_[nIndex]:getWorldPosition()	
			local param = {
				text = npcName[nIndex].._T("帮您捕获妖兽")..cardFate.Name,
				layout = wndInstance.rootWidget,
				ccsColor = g_TbColorType[cardFate.ColorType],
				fontSize = 24,
				x = tbWorldPos.x,
				y = tbWorldPos.y + 160
			}
			g_ShowSysTipsWord(param)
	
			local ImageView_HuntFateOptionPNL = tolua.cast(wndInstance.rootWidget:getChildByName("ImageView_HuntFateOptionPNL"),"ImageView")
			local CheckBox_HuntOption = tolua.cast(ImageView_HuntFateOptionPNL:getChildByName("CheckBox_HuntOption"..nIndex),"CheckBox")
			wndInstance:checkBoxSelectedState(CheckBox_HuntOption, nil, nIndex)
			
		end
		
		local function endlFunc()
			wndInstance.Image_Name:setVisible(false)
			wndInstance:cleanCenterLightAni(true)
			wndInstance:freeOfChargeHuntFate()
		end
		
		wndInstance:showCenterLightAni(true)
		local param = {
			rootWidget = wndInstance.rootWidget, 
			image = wndInstance.Image_CoverPNL, 
			updateCover = updateFateCover, 
			endlFunc = endlFunc,
			data = data,
		}
		g_FateData:folieFate(param)
		--猎妖师
		local nIndex = g_FateData:getNpcStatsByIndex()
		local ImageView_HuntFateOptionPNL = tolua.cast(wndInstance.rootWidget:getChildByName("ImageView_HuntFateOptionPNL"),"ImageView")
		local CheckBox_HuntOption = tolua.cast(ImageView_HuntFateOptionPNL:getChildByName("CheckBox_HuntOption"..nIndex),"CheckBox")
		wndInstance:checkBoxSelectedState(CheckBox_HuntOption, nil, nIndex)
		
	end
end

function Game_HuntFate1:YangBaoHuntFate(huntList)
	if next(huntList) == nil then
		SendError("==YangBaoHuntFate==服务器数据下发妖兽数据为空==")
		g_MsgNetWorkWarning:closeNetWorkWarning()
		return
	end
	self.huntList_ = huntList
	self:quickHuntAni()
end

function Game_HuntFate1:PackageMax()
	--拥有的异兽数
	local fateNum = g_Hero:getFateUnDressedAmmount()
	local fateMaxNum = g_VIPBase:getVipValue("FateMaxNum")
	if fateNum >= fateMaxNum then 
		g_ShowSysTips({text=_T("妖兽背包已经满了，请清理后再猎妖")})
		return false
	end
	return true
end

