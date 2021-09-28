--------------------------------------------------------------------------------------
-- 文件名:	HJW_Dialogue.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:
-- 日  期:	2014-11-20 15:07
-- 版  本:	1.0
-- 描  述:	
-- 应  用:
---------------------------------------------------------------------------------------
Game_Dialogue = class("Game_Dialogue")
Game_Dialogue.__index = Game_Dialogue

local SPEAK ={
	common = 1,-- 普通对话框
	roundnessReflectOn = 2,-- 圆形思考对话框
	squareReflectOn = 3,-- 方形思考对话框
	shout = 4,-- 大喊对话框
} 

local SPEAKER_TYPE = {
	captain = 1, --左边 队长
	notCaptain = 2, --左边 非队长
	leftNPC = 3, --左边 非队长
	rightMonsterNPC = 4, --右边 非队长
}
local ContextSequence = 1
local dialogueEvent = 0

-- function Game_Dialogue:checkData()
-- end

function Game_Dialogue:initWnd()
	cclog("==============Game_Dialogue:initWnd()=========")
end

function Game_Dialogue:openWnd(tbParam)
	if not tbParam then return end
	self.rootWidget = tolua.cast(self.rootWidget, "Layout")
	local Image_DialogueLeftPNL = tolua.cast(self.rootWidget:getChildByName("Image_DialogueLeftPNL"),"ImageView")
	Image_DialogueLeftPNL:setVisible(false)
	
	local Image_DialogueRightPNL = tolua.cast(self.rootWidget:getChildByName("Image_DialogueLeftPNL"),"ImageView")
	Image_DialogueRightPNL:setVisible(false)
	local dialogueID = 1
	
	self.func_ = nil 
	if tbParam then 
		dialogueID = tbParam.dialogueID 
		dialogueEvent = tbParam.dialogueEvent
		self.func_ = tbParam.speakEndFunc
	end
	self.rootWidget:setBackGroundColorOpacity(tbParam.alpha)
	
	local cvsDialogue = g_DialogueData:getDlogueCvs(dialogueID)

	ContextSequence = g_DialogueData:oneValueKeyEvent(cvsDialogue,dialogueEvent)
	local cvsData = cvsDialogue[ContextSequence]
	if not cvsDialogue[ContextSequence] then 
		-- Dialogue表中key2没有连贯
		ContextSequence = g_DialogueData:continueOnTo(cvsDialogue,ContextSequence)
		cvsData = cvsDialogue[ContextSequence]
	end
	
	if dialogueEvent == cvsData.DialogueEvent then 
		self:showPNL(cvsData)
	else
		if self.func_ then self.func_() end 
		g_WndMgr:hideWnd("Game_Dialogue")
	end
	
	local function onCilckEscap(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			--"跳过当前剧情"
			ContextSequence = #cvsDialogue
			if self.func_ then self.func_() end 
			g_WndMgr:hideWnd("Game_Dialogue")
		end
	end
	local Button_Escape = tolua.cast(self.rootWidget:getChildByName("Button_Escape"),"Button")
	Button_Escape:setTouchEnabled(true)
	Button_Escape:addTouchEventListener(onCilckEscap)
	local Label_FuncName = tolua.cast(Button_Escape:getChildByName("Label_FuncName"), "Button")
	Label_FuncName:setTouchEnabled(true)
	Label_FuncName:addTouchEventListener(onCilckEscap)
	
	
	local fLastClickTime = API_GetCurrentTime()

	local function pickupCreate(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			
			g_playSoundEffect("Sound/ButtonClick.mp3")
			
			if g_PlayerGuide:checkIsInGuide() and (API_GetCurrentTime() - fLastClickTime) < 0.2 then
				cclog("=====checkNextGuideInBtnEvent======Click Too Fast")
				return
			else
				fLastClickTime = API_GetCurrentTime()
			end
			
			--当前对话结束
			local cvsDialogueNum = g_DialogueData:dialogueContextSequence(dialogueID)
			if ContextSequence >= cvsDialogueNum then
				if self.func_ then self.func_() end 
				ContextSequence = 1
				g_WndMgr:hideWnd("Game_Dialogue")
				return 
			end
			
			ContextSequence = ContextSequence + 1
			local cvsData = cvsDialogue[ContextSequence]
			if not cvsDialogue[ContextSequence] then 
				-- Dialogue表中key2没有连贯
				ContextSequence = g_DialogueData:continueOnTo(cvsDialogue,ContextSequence)
				cvsData = cvsDialogue[ContextSequence]
			end
			--
			if dialogueEvent ~= cvsData.DialogueEvent then 
				if self.func_ then self.func_() end 
				g_WndMgr:hideWnd("Game_Dialogue")
				return 
			end
			
			self:showPNL(cvsData)
		end
	end
	self.rootWidget:setTouchEnabled(true)
	self.rootWidget:addTouchEventListener(pickupCreate)
	
end

function Game_Dialogue:removeSpineWnd(widget)
    local Panel_Card =tolua.cast( widget:getChildByName("Panel_Card"),"Layout")
	local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"), "ImageView")
	Image_Card:removeAllNodes()
end

function Game_Dialogue:closeWnd()
	local rootWidget = self.rootWidget
	local Image_DialogueRightPNL = tolua.cast(rootWidget:getChildByName("Image_DialogueRightPNL"), "ImageView")
	local Image_DialogueLeftPNL = tolua.cast(rootWidget:getChildByName("Image_DialogueLeftPNL"), "ImageView")

    self:removeSpineWnd(Image_DialogueRightPNL)
    self:removeSpineWnd(Image_DialogueLeftPNL)  
end

--[[
	隐藏上一次
]]
function Game_Dialogue:showCardSpeak(widget,cvsData,flag)
	if not cvsData then cclog("配置表获取失败 为空") return end 
	widget:setVisible(true)
		--人物 动画
	local Panel_Card =tolua.cast( widget:getChildByName("Panel_Card"),"Layout")
	Panel_Card:setVisible(true)

	local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"), "ImageView")
	Image_Card:setVisible(true)
	Image_Card:loadTexture(getUIImg("Blank"))
	Image_Card:removeAllNodes()
	
	local spine = cvsData.SpineAnimation 
	if SPEAKER_TYPE.captain == cvsData.SpeakerType then 
		local cvsPlay = g_DataMgr:getPlayerCreateCsv(g_Hero:getMasterSex())
		local nCardID = cvsPlay.CardID 
		local starLev = cvsPlay.StarLevel 
		local CSV_CardBase = g_DataMgr:getCardBaseCsv(nCardID, starLev)
		spine = CSV_CardBase.SpineAnimation 
	end
	
	if spine ~= "" or spine ~= nil then 
		local CCNode_Skeleton = g_CocosSpineAnimation(spine, 1,true)
		if not flag then  g_RevertObject(CCNode_Skeleton) end
		Image_Card:setPositionXY(cvsData.SpineX, cvsData.SpineY)
		Image_Card:addNode(CCNode_Skeleton)
		
		local nCardHeight = math.max(180, math.min(360, cvsData.CardHeight))
		local nOffsetY = ((nCardHeight - 180)/180)*108
		Panel_Card:setPositionY(72-nOffsetY)
		g_runSpineAnimation(CCNode_Skeleton, "idle", true)
	end
	--4 种对话框
	for i = 1,4 do 
		local Button_SpeakContent = tolua.cast(widget:getChildByName("Button_SpeakContent"..i), "Button")
		Button_SpeakContent:setVisible(false)
	end
	
	local dialogueBoxType = cvsData.DialogueBoxType
	
	local Button_SpeakContent = tolua.cast(widget:getChildByName("Button_SpeakContent"..dialogueBoxType), "Button")
	Button_SpeakContent:setPositionXY(cvsData.DialogueX,cvsData.DialogueY)
	Button_SpeakContent:setVisible(true)
	
	local nTxt = cvsData.Context
	--对话文本
	local Label_Speach = tolua.cast(Button_SpeakContent:getChildByName("Label_Speach"), "Label")
	Label_Speach:setText(nTxt)
	
	local CCNode_Tips = tolua.cast(Label_Speach:getVirtualRenderer(), "CCLabelTTF")
	CCNode_Tips:disableShadow(true)

	if dialogueBoxType == SPEAK.common then --普通对话框
	
		Button_SpeakContent:setAnchorPoint(ccp(0.0,0.0))
		--动画浮动箭头
		local Image_Arrow = tolua.cast(Button_SpeakContent:getChildByName("Image_Arrow"), "ImageView")
		Image_Arrow:stopAllActions()
		Image_Arrow:setPositionY(50)
		g_CreateUpAndDownAnimation(Image_Arrow)
		
		--人物名称
		local Image_Name = tolua.cast(Button_SpeakContent:getChildByName("Image_Name"), "ImageView")
		local Label_Name = tolua.cast(Image_Name:getChildByName("Label_Name"), "Label")
		local CCNode_Tips = tolua.cast(Label_Name:getVirtualRenderer(), "CCLabelTTF")
		CCNode_Tips:disableShadow(true)
		
		if SPEAKER_TYPE.captain == cvsData.SpeakerType then 
			Label_Name:setText(g_Hero:getMasterNameSuffix())
		else
			Label_Name:setText(cvsData.Name)
		end

	-- elseif dialogueBoxType == SPEAK.roundnessReflectOn then --圆形思考对话框

	elseif dialogueBoxType == SPEAK.squareReflectOn then --方形思考对话框
	
		Button_SpeakContent:setAnchorPoint(ccp(0.0,0.0))
		
	-- elseif dialogueBoxType == SPEAK.shout then --大喊对话框

	end
	
	self:actionSpeak(Button_SpeakContent)
end
--对话框动画
function Game_Dialogue:actionSpeak(speakImage)
	speakImage:setScale(0.0)
	local scaleToOne = CCScaleTo:create(0.15,1.1)
	local scaleToTwo = CCScaleTo:create(0.15,1)
	local action = sequenceAction({scaleToOne,scaleToTwo})
	speakImage:runAction(action)
	
end

--左边 对话框 人物
function Game_Dialogue:dialogueLeftPNL(cvsData)

	local rootWidget = self.rootWidget
	local Image_DialogueRightPNL = tolua.cast(rootWidget:getChildByName("Image_DialogueRightPNL"), "ImageView")
	Image_DialogueRightPNL:setVisible(false)
	local Image_DialogueLeftPNL = tolua.cast(rootWidget:getChildByName("Image_DialogueLeftPNL"), "ImageView")
	self:showCardSpeak(Image_DialogueLeftPNL,cvsData,true)
	
end

--右边 对话框 人物
function Game_Dialogue:dialogueRightPNL(cvsData)
	local rootWidget = self.rootWidget
	local Image_DialogueLeftPNL = tolua.cast(rootWidget:getChildByName("Image_DialogueLeftPNL"), "ImageView")
	Image_DialogueLeftPNL:setVisible(false)
	local Image_DialogueRightPNL = tolua.cast(rootWidget:getChildByName("Image_DialogueRightPNL"), "ImageView")
	self:showCardSpeak(Image_DialogueRightPNL,cvsData,false)
end

function Game_Dialogue:showPNL(cvsData)
	if not cvsData then return end 
	--对话位置 类型
	if  SPEAKER_TYPE.captain == cvsData.SpeakerType then 
		self:dialogueLeftPNL(cvsData)
	elseif SPEAKER_TYPE.notCaptain == cvsData.SpeakerType then  
		self:dialogueLeftPNL(cvsData)
	elseif SPEAKER_TYPE.leftNPC == cvsData.SpeakerType then 
		self:dialogueRightPNL(cvsData)
	elseif SPEAKER_TYPE.rightMonsterNPC == cvsData.SpeakerType  then  
		self:dialogueRightPNL(cvsData)
	end

end

