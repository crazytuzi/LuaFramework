--------------------------------------------------------------------------------------
-- 文件名:	g_Botton.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	陆奎安
-- 日  期:	2013-3-4 9:37
-- 版  本:	1.0
-- 描  述:	通用Game_RewardBox控件设置函数
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

function setCloseBtn(layerout, callback, szName)
    szName = szName or "Button_Return"
	local btnName = tolua.cast(layerout:getChildByName(szName),"Button")
	btnName:setTouchEnabled(true)
	local function onClickReturn(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			layerout:setVisible(false)
			if callback then
				callback()
			end
		end
	end
	btnName:addTouchEventListener(onClickReturn)
end

--设置是否响应事件
function g_SetBtnTouch(widgetBtn, bEnabled)
	widgetBtn:setTouchEnabled(bEnabled)
end

--设置灰化
function g_SetBtnBright(widgetBtn, bEnabled)
	widgetBtn:setBright(bEnabled)
end

--设置点击放大
function g_SetBtnPressAction(widgetBtn, bEnabled)
	widgetBtn:setPressedActionEnabled(bEnabled)
end

--启用正常，禁用同时灰化
function g_SetBtnEnable(widgetBtn, bEnabled)
	g_SetBtnTouch(widgetBtn, bEnabled)
	g_SetBtnBright(widgetBtn, bEnabled)
end

--启用正常，禁用并灰化，点击放大
function g_SetBtnEnableAndPress(widgetBtn, bEnabled)
	g_SetBtnTouch(widgetBtn, bEnabled)
	g_SetBtnPressAction(widgetBtn, bEnabled)
	g_SetBtnBright(widgetBtn, bEnabled)
end

g_SetBtnTable = {}
function g_SetBtn(rootWidget, strName, funcEndCallBack, bEnabled, bMuteSound, nTag, widgetBtn)
	local btn = widgetBtn or rootWidget:getChildAllByName(strName)
	local nTag = nTag or 0
	
	g_SetBtnEnable(btn,bEnabled)
	if nTag then btn:setTag(nTag) end

	if not funcEndCallBack then return end
	g_SetBtnTable[btn] = g_SetBtnTable[btn] or {}
	g_SetBtnTable[btn].callback = funcEndCallBack

	btn:addTouchEventListener(function(pSender, eventType)
        if eventType == ccs.TouchEventType.ended then
			local nTag = pSender:getTag()
			if g_SetBtnTable[pSender] and g_SetBtnTable[pSender].callback then
				g_SetBtnTable[pSender].callback(pSender, nTag)
			end
			
        end
    end)
	if bMuteSound then btn:setEnablePlaySound(false) end
	return btn
end

function g_SetBtnWithEvent(widgetBtn, nTag, funcEndCallBack, bEnabled, bPressable)
	if nTag then
		widgetBtn:setTag(nTag)
	end
	local bEnabled = bEnabled or false
	widgetBtn:setTouchEnabled(bEnabled)
	widgetBtn:setBright(bEnabled)
	if bPressable then
		widgetBtn:setPressedActionEnabled(bPressable)
	end
	
	widgetBtn:addTouchEventListener(function(pSender,eventType)
        if eventType == ccs.TouchEventType.ended then
			local nTag = pSender:getTag()
			funcEndCallBack(pSender, nTag)
        end
    end)
end

local fLastClickTime = 0
local function checkNextGuideInBtnEvent(pSender, funcPressCall, bLockEvent, bNeedCheckQualify)
	if g_PlayerGuide:checkIsInGuide() then
		if bNeedCheckQualify then
			if (API_GetCurrentTime() - fLastClickTime) < 0.5 then
				return
			else
				fLastClickTime = API_GetCurrentTime()
			end
		end
		
		if g_PlayerGuide:checkCurrentGuideSequenceNode("ButtonEnded", pSender:getName()) then
			if not g_IsGuideWidgetInLock then
				g_IsGuideWidgetInLock = true
				local nTag = pSender:getTag()
				funcPressCall(pSender, nTag)
				g_PlayerGuide:showCurrentGuideSequenceNode()
			end
		else
			if bLockEvent then
				if not g_IsGuideWidgetInLock then
					g_IsGuideWidgetInLock = true
					local nTag = pSender:getTag()
					funcPressCall(pSender, nTag)
				else
					cclog("=============按钮已经点过被引导锁住================")
				end
			else
				local nTag = pSender:getTag()
				funcPressCall(pSender, nTag)
			end
		end
	else
		local nTag = pSender:getTag()
		funcPressCall(pSender, nTag)
	end
end

local function checkNextGuideInBtnEventFree(pSender, funcPressCall)
	if g_PlayerGuide:checkIsInGuide() then
		if g_PlayerGuide:checkCurrentGuideSequenceNode("ButtonEnded", pSender:getName()) then
			if not g_IsGuideWidgetInLock then
				g_IsGuideWidgetInLock = true
				local nTag = pSender:getTag()
				funcPressCall(pSender, nTag)
				g_PlayerGuide:showCurrentGuideSequenceNode()
			end
		else
			local nTag = pSender:getTag()
			funcPressCall(pSender, nTag)
		end
	else
		local nTag = pSender:getTag()
		funcPressCall(pSender, nTag)
	end
end

--注册FunctionOpenLevel的事件函数
function g_SetBtnWithOpenCheck(widgetBtn, nTag, funcPressCall, bEnabled, bPressable, bCascade)
	if nTag then
		widgetBtn:setTag(nTag)
	end
	widgetBtn:setTag(nTag)
	widgetBtn:setTouchEnabled(bEnabled)
	widgetBtn:setBright(bEnabled)
	if bPressable then
		widgetBtn:setPressedActionEnabled(bPressable)
	end
	widgetBtn:setCascadeOpacityEnabled(bCascade)

	if not funcPressCall then return end
	widgetBtn:addTouchEventListener(function(pSender,eventType)
        if eventType == ccs.TouchEventType.ended then
			local WidgetName = pSender:getName()
			if g_CheckFuncCanOpenByWidgetName(WidgetName) then
				checkNextGuideInBtnEvent(pSender, funcPressCall, nil, nil)
			else
				local nOpenLevel = getFunctionOpenLevelCsvByStr(WidgetName).OpenLevel
				local strOpenFuncName = getFunctionOpenLevelCsvByStr(WidgetName).OpenFuncName
				local nOpenVipLevel = getFunctionOpenLevelCsvByStr(WidgetName).OpenVipLevel
				if nOpenLevel <= 200 then
					if nOpenVipLevel >= 1 then
						g_ShowSysWarningTips({text = string.format(_T("%s将在%d级开放, 加油练级哦~亲~！\n或在VIP等级达到VIP%d后开放~"), strOpenFuncName, nOpenLevel, nOpenVipLevel)})
					else
						g_ShowSysWarningTips({text = string.format(_T("%s将在%d级开放, 加油练级哦~亲~！"), strOpenFuncName, nOpenLevel)})
					end
				else
					g_ShowSysWarningTips({text =_T("功能暂未开放敬请期待...")})
				end
			end
        end
    end)
end

--注册附带新手引导检测的事件函数
function g_SetBtnWithGuideCheck(widgetBtn, nTag, funcPressCall, bEnabled, bPressable, bLockEvent, bNeedCheckQualify)
	if nTag then
		widgetBtn:setTag(nTag)
	end
	widgetBtn:setTouchEnabled(bEnabled)
	widgetBtn:setBright(bEnabled)
	if bPressable then
		widgetBtn:setPressedActionEnabled(bPressable)
	end

	widgetBtn:addTouchEventListener(function(pSender, eventType)
        if eventType == ccs.TouchEventType.ended then
			checkNextGuideInBtnEvent(pSender, funcPressCall, bLockEvent, bNeedCheckQualify)
        end
    end)
end

--注册回调函数，并设置按钮点击动作
function g_SetBtnAndPressWithString(rootWidget, strName, funcEndCallBack, bEnabled, nTag)
	local btn = tolua.cast(rootWidget:getChildAllByName(strName),"Button")
	local nTag = nTag or 0
	
	g_SetBtnEnableAndPress(btn,bEnabled)
	if nTag then btn:setTag(nTag) end
	btn:addTouchEventListener(function(pSender,eventType)
        if eventType == ccs.TouchEventType.ended then
			local nTag = pSender:getTag()
			funcEndCallBack(nTag)
        end
    end)
	
	return btn
end

function g_SetButtonEnabled(widget, bEnabled, strFuncName, bIsFuncNameDiabledWhite)
	if not widget then return end
	if bEnabled then
		widget:setTouchEnabled(true)
		widget:setBright(true)
		if strFuncName then
			local BitmapLabel_FuncName = tolua.cast(widget:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
			local Label_FuncName = tolua.cast(widget:getChildByName("Label_FuncName"), "Label")
			local color = ccs.COLOR.WHITE
			if BitmapLabel_FuncName then
				g_setTextColor(BitmapLabel_FuncName,color);	--白色
				BitmapLabel_FuncName:setText(strFuncName)
			elseif Label_FuncName then
				g_setTextColor(Label_FuncName,color);	--白色
				Label_FuncName:setText(strFuncName)
			end
		end
	else
		widget:setTouchEnabled(false)
		widget:setBright(false)
		local BitmapLabel_FuncName = tolua.cast(widget:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
		local Label_FuncName = tolua.cast(widget:getChildByName("Label_FuncName"), "Label")
		if strFuncName then
			if BitmapLabel_FuncName then
				if bIsFuncNameDiabledWhite then
					g_setTextColor(BitmapLabel_FuncName,ccs.COLOR.WHITE);	--白色
				else
					g_setTextColor(BitmapLabel_FuncName, ccs.COLOR.RED) --红色
				end
				BitmapLabel_FuncName:setText(strFuncName)
			elseif Label_FuncName then
				if bIsFuncNameDiabledWhite then
					g_setTextColor(Label_FuncName,ccs.COLOR.WHITE);	--白色
				else
					g_setTextColor(Label_FuncName,ccs.COLOR.RED)--红色
				end
				Label_FuncName:setText(strFuncName)
			end
		end
	end
end

--bActionBack 如果是true表示不回缩 否则回缩
function g_SetButtonFilter(Button_Filter,TB_Filter, bActionBack)
	if not Button_Filter then
		return
	end

	local Button_FilterBG = tolua.cast(Button_Filter:getChildAllByName("Button_Filter_BackGround"),"Button")
	local Panel_Filter = tolua.cast(Button_Filter:getChildAllByName("Panel_Filter"),"Layout")
    local nActionStatus = 0
    local nPosY = 0
    local function FilterActionGoBack()
	    local function moveToTargetCallBack2()
		    Panel_Filter:setVisible(false)
		    nActionStatus = 0
	    end
	    local moveAction2 = CCMoveBy:create(0.2, ccp(0,nPosY))
	    local actionMoveToEasing = CCEaseOut:create(moveAction2,1.2)
	    local arrAct = CCArray:create()
	    arrAct:addObject(actionMoveToEasing)	
	    arrAct:addObject(CCCallFuncN:create(moveToTargetCallBack2))
	    local actionArry = CCSequence:create(arrAct)
	    Panel_Filter:runAction(actionArry)
    end

	local FilterItemSize = g_WidgetModel.Button_FilterItem:getContentSize()
	local Panel_FilterSize = Panel_Filter:getContentSize()
    Panel_Filter:removeAllChildren()
	Panel_Filter:setVisible(false)

    local func = TB_Filter[2]
    local tbText = TB_Filter[1]
	local Label_FuncName = tolua.cast(Button_Filter:getChildAllByName("Label_FuncName"), "Label")
    Label_FuncName:setText(tbText[1])
    local function onClickSubWidget(pSender,eventType)
        if eventType == ccs.TouchEventType.ended then
            local nTag = pSender:getTag()
            Label_FuncName:setText(tbText[nTag])
            if func then
                func(nTag)
            end
            if not bActionBack  then
               FilterActionGoBack()
            end
        end
    end
	for k,v in ipairs(TB_Filter[1]) do
		local Panel_RewardItemsRow = g_WidgetModel.Button_FilterItem:clone()
		local Label_FuncItemName = tolua.cast(Panel_RewardItemsRow:getChildAllByName("Label_FuncItemName"),"Label")
		Label_FuncItemName:setText(v)
		Panel_RewardItemsRow:setTouchEnabled(true)
		Panel_RewardItemsRow:setTag(k)
		if TB_Filter[2] then
			Panel_RewardItemsRow:addTouchEventListener(onClickSubWidget)
		end
	
		nPosY = (FilterItemSize.height + 8)*(#TB_Filter[1]-k)
		Panel_RewardItemsRow:setPosition(ccp(Panel_FilterSize.width/2,nPosY))
		Panel_Filter:addChild(Panel_RewardItemsRow)
	end
	nPosY = (FilterItemSize.height + 8)*(#TB_Filter[1]) + 2
	
	local function moveToTargetCallBack1()
		nActionStatus = 1
	end
	local function moveToTargetCallBack2()
		Panel_Filter:setVisible(false)
		nActionStatus = 0
	end
	
	local function FilterAction(tag)
		local arrAct = CCArray:create()
		if nActionStatus == 0 then
			Panel_Filter:setVisible(true)
			local moveAction1 = CCMoveBy:create(0.2, ccp(0,-nPosY))
			local actionMoveToEasing = CCEaseOut:create(moveAction1,1.2)
			arrAct = CCArray:create()
			arrAct:addObject(actionMoveToEasing)	
			arrAct:addObject(CCCallFuncN:create(moveToTargetCallBack1))
			nActionStatus = 1
		elseif nActionStatus == 1 then
			local moveAction2 = CCMoveBy:create(0.2, ccp(0,nPosY))
			local actionMoveToEasing = CCEaseOut:create(moveAction2,1.2)
			arrAct:addObject(actionMoveToEasing)	
			arrAct:addObject(CCCallFuncN:create(moveToTargetCallBack2))
			nActionStatus = 0
		end
		local actionArry = CCSequence:create(arrAct)
		Panel_Filter:runAction(actionArry)
	end
	Button_FilterBG:setTouchEnabled(true)
	Button_FilterBG:setTag(0)
	Button_FilterBG:addTouchEventListener(function(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			local nTag = Button_FilterBG:getTag()
			FilterAction(nTag)
		end
	end)
end

--注册按钮带点击高亮
g_PressImage = {}
function g_SetBtnWithPressImage(widgetBtn, nTag, funcPressCall, bEnabled, nBlendType, nAlpha)
	local nBlendType = nBlendType or 4
	local nAlpha = nAlpha or 255
	if nTag then
		widgetBtn:setTag(nTag)
	end
	widgetBtn:setTouchEnabled(bEnabled)
	widgetBtn:setBright(bEnabled)
	
	local Image_Check = tolua.cast(widgetBtn:getChildByName("Image_Check"), "ImageView")
	if Image_Check then
		Image_Check:setVisible(false)
		Image_Check:setOpacity(nAlpha)
		local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(), "CCSprite")
		g_SetBlendFuncSprite(ccSpriteCheck, nBlendType)
	end
	
	if not funcPressCall then return end
	g_PressImage[widgetBtn] = g_PressImage[widgetBtn] or {}
	g_PressImage[widgetBtn].CallBack = funcPressCall

	widgetBtn:addTouchEventListener(function(pSender, eventType)
		if eventType == ccs.TouchEventType.began then
			if Image_Check then 
				Image_Check:setVisible(true)
			end
		elseif eventType == ccs.TouchEventType.ended then
			if Image_Check then 
				Image_Check:setVisible(false)
			end
			local nTag = pSender:getTag()
			if g_PressImage[pSender] and g_PressImage[pSender].CallBack then
				g_PressImage[pSender].CallBack(pSender, nTag)
			end
			
		elseif eventType == ccs.TouchEventType.canceled then
			if Image_Check then 
				Image_Check:setVisible(false)
			end
        end
    end)
end

--注册FunctionOpenLevel的事件函数, 并且带Image_Check高亮
function g_SetBtnOpenCheckWithPressImage(widgetBtn, nTag, funcPressCall, bEnabled, bPressable, bCascade, nBlendType, nAlpha, bNeedCheckQualify)
	if widgetBtn == nil then return end
	
	local nBlendType = nBlendType or 4
	local nAlpha = nAlpha or 255
	
	if nTag then
		widgetBtn:setTag(nTag)
	end
	widgetBtn:setTag(nTag)
	widgetBtn:setTouchEnabled(bEnabled)
	widgetBtn:setBright(bEnabled)
	widgetBtn:setCascadeOpacityEnabled(bCascade)
	if bPressable then
		widgetBtn:setPressedActionEnabled(bPressable)
	end
	
	local Image_Check = tolua.cast(widgetBtn:getChildByName("Image_Check"), "ImageView")
	if Image_Check then
		Image_Check:setVisible(false)
		Image_Check:setOpacity(nAlpha)
		local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(), "CCSprite")
		g_SetBlendFuncSprite(ccSpriteCheck, nBlendType)
	end

	if not funcPressCall then return end
	widgetBtn:addTouchEventListener(function(pSender,eventType)
		if eventType == ccs.TouchEventType.began then
			Image_Check:setVisible(true)
        elseif eventType == ccs.TouchEventType.ended then
			Image_Check:setVisible(false)
			local WidgetName = pSender:getName()
			if g_CheckFuncCanOpenByWidgetName(WidgetName) then
				checkNextGuideInBtnEvent(pSender, funcPressCall, nil, bNeedCheckQualify)
			else
				local nOpenLevel = getFunctionOpenLevelCsvByStr(WidgetName).OpenLevel
				local strOpenFuncName = getFunctionOpenLevelCsvByStr(WidgetName).OpenFuncName
				local nOpenVipLevel = getFunctionOpenLevelCsvByStr(WidgetName).OpenVipLevel
				if nOpenLevel <= 200 then
					if nOpenVipLevel >= 1 then
						g_ShowSysWarningTips({text = string.format(_T("%s将在%d级开放, 加油练级哦~亲~！\n或在VIP等级达到VIP%d后开放~"), strOpenFuncName, nOpenLevel, nOpenVipLevel)})
					else
						g_ShowSysWarningTips({text = string.format(_T("%s将在%d级开放, 加油练级哦~亲~！"), strOpenFuncName, nOpenLevel)})
					end
				else
					g_ShowSysWarningTips({text =_T("功能暂未开放敬请期待...")})
				end
			end
		elseif eventType == ccs.TouchEventType.canceled then
			Image_Check:setVisible(false)
        end
    end)
end

--注册附带新手引导检测的事件函数, 并且带Image_Check高亮
g_GuideCheckWithPressImage = {}
function g_SetBtnGuideCheckWithPressImage(widgetBtn, nTag, funcPressCall, bEnabled, bPressable, nBlendType, nAlpha, bNeedCheckQualify)
	local nBlendType = nBlendType or 4
	local nAlpha = nAlpha or 255
	
	if nTag then
		widgetBtn:setTag(nTag)
	end
	widgetBtn:setTouchEnabled(bEnabled)
	widgetBtn:setBright(bEnabled)
	if bPressable then
		widgetBtn:setPressedActionEnabled(bPressable)
	end
	
	local Image_Check = tolua.cast(widgetBtn:getChildByName("Image_Check"), "ImageView")
	if Image_Check then
		Image_Check:setVisible(false)
		Image_Check:setOpacity(nAlpha)
		local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(), "CCSprite")
		g_SetBlendFuncSprite(ccSpriteCheck, nBlendType)
	end

	if not funcPressCall then return end
	g_GuideCheckWithPressImage[widgetBtn] = g_GuideCheckWithPressImage[widgetBtn] or {}
	g_GuideCheckWithPressImage[widgetBtn].Callback = funcPressCall

	widgetBtn:addTouchEventListener(function(pSender, eventType)
		if eventType == ccs.TouchEventType.began then
			Image_Check:setVisible(true)
		elseif eventType == ccs.TouchEventType.ended then
			Image_Check:setVisible(false)
			if g_GuideCheckWithPressImage[pSender] and g_GuideCheckWithPressImage[pSender].Callback then
				checkNextGuideInBtnEvent(pSender, g_GuideCheckWithPressImage[pSender].Callback, nil, bNeedCheckQualify)
			end
			
		elseif eventType == ccs.TouchEventType.canceled then
			Image_Check:setVisible(false)
        end
    end)
end


--widgetBtn 注册长按事件控件
--onPressingEvent 长按一段时间后触发的回调函数
--onPressedEvent 在长按判定时间之前松开的点击函数
--onCleanUpEvent 结束后的清理函数，比如关闭Tip
function g_SetBtnWithPressingEvent(widgetBtn, nTag, onPressingEvent, onPressedEvent, onCleanUpEvent, bEnabled, fDelayTime)
	local fDelayTime = fDelayTime or g_PressingEventDelayTime
	
	if nTag then
		widgetBtn:setTag(nTag)
	end
	local bEnabled = bEnabled or false
	widgetBtn:setTouchEnabled(bEnabled)
	widgetBtn:setBright(bEnabled)

	local fBeginTime = 0
	local nTimerId = nil
	widgetBtn:addTouchEventListener(function(pSender,eventType)
        if eventType == ccs.TouchEventType.began then
			local function onDelayEvent()
				if onPressingEvent then
					local nTag = pSender:getTag()
					onPressingEvent(pSender, nTag)
				end
				nTimerId = nil
			end
			nTimerId = g_Timer:pushTimer(fDelayTime, onDelayEvent)
		elseif eventType == ccs.TouchEventType.moved then
			local ccpTouchPos = pSender:getTouchMovePos()
			if not pSender:hitTest(ccpTouchPos) then
				if nTimerId then
					g_Timer:destroyTimerByID(nTimerId)
					nTimerId = nil
				else
					if onCleanUpEvent then
						local nTag = pSender:getTag()
						onCleanUpEvent(pSender, nTag)
					end
				end	
			end
		elseif eventType == ccs.TouchEventType.canceled then
			if nTimerId then
				g_Timer:destroyTimerByID(nTimerId)
				nTimerId = nil
			else
				if onCleanUpEvent then
					local nTag = pSender:getTag()
					onCleanUpEvent(pSender, nTag)
				end
			end
		elseif eventType == ccs.TouchEventType.ended then
			if nTimerId then
				g_Timer:destroyTimerByID(nTimerId)
				if onPressedEvent then
					local nTag = pSender:getTag()
					onPressedEvent(pSender, nTag)
				end
				nTimerId = nil
			else
				if onCleanUpEvent then
					local nTag = pSender:getTag()
					onCleanUpEvent(pSender, nTag)
				else
					if onPressedEvent then
						local nTag = pSender:getTag()
						onPressedEvent(pSender, nTag)
					end
				end
			end
        end
    end)
end

function g_SetBtnWithPressingEventAndGuide(widgetBtn, nTag, onPressingEvent, onPressedEvent, onCleanUpEvent, bEnabled, fDelayTime)
	local fDelayTime = fDelayTime or g_PressingEventDelayTime
	
	if nTag then
		widgetBtn:setTag(nTag)
	end
	local bEnabled = bEnabled or false
	widgetBtn:setTouchEnabled(bEnabled)
	widgetBtn:setBright(bEnabled)

	local fBeginTime = 0
	local nTimerId = nil
	widgetBtn:addTouchEventListener(function(pSender,eventType)
        if eventType == ccs.TouchEventType.began then
			local function onDelayEvent()
				if onPressingEvent then
					local nTag = pSender:getTag()
					onPressingEvent(pSender, nTag)
				end
				nTimerId = nil
			end
			nTimerId = g_Timer:pushTimer(fDelayTime, onDelayEvent)
		elseif eventType == ccs.TouchEventType.moved then
			local ccpTouchPos = pSender:getTouchMovePos()
			if not pSender:hitTest(ccpTouchPos) then
				if nTimerId then
					g_Timer:destroyTimerByID(nTimerId)
					nTimerId = nil
				else
					if onCleanUpEvent then
						local nTag = pSender:getTag()
						onCleanUpEvent(pSender, nTag)
					end
				end	
			end
		elseif eventType == ccs.TouchEventType.canceled then
			if nTimerId then
				g_Timer:destroyTimerByID(nTimerId)
				nTimerId = nil
			else
				if onCleanUpEvent then
					local nTag = pSender:getTag()
					onCleanUpEvent(pSender, nTag)
				end
			end
		elseif eventType == ccs.TouchEventType.ended then
			if nTimerId then
				g_Timer:destroyTimerByID(nTimerId)
				checkNextGuideInBtnEventFree(pSender, onPressedEvent)
				nTimerId = nil
			else
				if onCleanUpEvent then
					local nTag = pSender:getTag()
					onCleanUpEvent(pSender, nTag)
				else
					checkNextGuideInBtnEventFree(pSender, onPressedEvent)
				end
			end
        end
    end)
end

function g_SetBtnWithPressingEventAndImage(widgetBtn, nTag, onPressingEvent, onPressedEvent, onCleanUpEvent, bEnabled, fDelayTime, nAlpha)
	local fDelayTime = fDelayTime or g_PressingEventDelayTime
	
	if nTag then
		widgetBtn:setTag(nTag)
	end
	local bEnabled = bEnabled or false
	widgetBtn:setTouchEnabled(bEnabled)
	widgetBtn:setBright(bEnabled)
	
	local nAlpha = nAlpha or 255
	local Image_Check = tolua.cast(widgetBtn:getChildByName("Image_Check"), "ImageView")
	if Image_Check then
		Image_Check:setVisible(false)
		Image_Check:setOpacity(nAlpha)
		g_SetBlendFuncWidget(Image_Check, 1)
	end

	local fBeginTime = 0
	local nTimerId = nil
	widgetBtn:addTouchEventListener(function(pSender,eventType)
        if eventType == ccs.TouchEventType.began then
			Image_Check:setVisible(true)
			local function onDelayEvent()
				if onPressingEvent then
					local nTag = pSender:getTag()
					onPressingEvent(pSender, nTag)
				end
				nTimerId = nil
			end
			nTimerId = g_Timer:pushTimer(fDelayTime, onDelayEvent)
		elseif eventType == ccs.TouchEventType.moved then
			local ccpTouchPos = pSender:getTouchMovePos()
			if not pSender:hitTest(ccpTouchPos) then
				if nTimerId then
					g_Timer:destroyTimerByID(nTimerId)
					nTimerId = nil
				else
					if onCleanUpEvent then
						local nTag = pSender:getTag()
						onCleanUpEvent(pSender, nTag)
					end
				end	
			end
		elseif eventType == ccs.TouchEventType.canceled then
			Image_Check:setVisible(false)
			if nTimerId then
				g_Timer:destroyTimerByID(nTimerId)
				nTimerId = nil
			else
				if onCleanUpEvent then
					local nTag = pSender:getTag()
					onCleanUpEvent(pSender, nTag)
				end
			end
		elseif eventType == ccs.TouchEventType.ended then
			Image_Check:setVisible(false)
			if nTimerId then
				g_Timer:destroyTimerByID(nTimerId)
				if onPressedEvent then
					local nTag = pSender:getTag()
					onPressedEvent(pSender, nTag)
				end
				nTimerId = nil
			else
				if onCleanUpEvent then
					local nTag = pSender:getTag()
					onCleanUpEvent(pSender, nTag)
				else
					if onPressedEvent then
						local nTag = pSender:getTag()
						onPressedEvent(pSender, nTag)
					end
				end
			end
        end
    end)
end

function g_SetBtnWithPressingEventAndOpenCheck(widgetBtn, nTag, onPressingEvent, onPressedEvent, onCleanUpEvent, bEnabled, fDelayTime)
	local fDelayTime = fDelayTime or g_PressingEventDelayTime
	
	if nTag then
		widgetBtn:setTag(nTag)
	end
	local bEnabled = bEnabled or false
	widgetBtn:setTouchEnabled(bEnabled)
	widgetBtn:setBright(bEnabled)

	local fBeginTime = 0
	local nTimerId = nil
	widgetBtn:addTouchEventListener(function(pSender,eventType)
        if eventType == ccs.TouchEventType.began then
			local function onDelayEvent()
				if onPressingEvent then
					local nTag = pSender:getTag()
					onPressingEvent(pSender, nTag)
				end
				nTimerId = nil
			end
			nTimerId = g_Timer:pushTimer(fDelayTime, onDelayEvent)
		elseif eventType == ccs.TouchEventType.moved then
			local ccpTouchPos = pSender:getTouchMovePos()
			if not pSender:hitTest(ccpTouchPos) then
				if nTimerId then
					g_Timer:destroyTimerByID(nTimerId)
					nTimerId = nil
				else
					if onCleanUpEvent then
						local nTag = pSender:getTag()
						onCleanUpEvent(pSender, nTag)
					end
				end	
			end
		elseif eventType == ccs.TouchEventType.canceled then
			if nTimerId then
				g_Timer:destroyTimerByID(nTimerId)
				nTimerId = nil
			else
				if onCleanUpEvent then
					local nTag = pSender:getTag()
					onCleanUpEvent(pSender, nTag)
				end
			end
		elseif eventType == ccs.TouchEventType.ended then
			if nTimerId then
				g_Timer:destroyTimerByID(nTimerId)
				if onPressedEvent then
					local WidgetName = pSender:getName()
					if g_CheckFuncCanOpenByWidgetName(WidgetName) then
						checkNextGuideInBtnEvent(pSender, onPressedEvent, nil, nil)
					else
						local nOpenLevel = getFunctionOpenLevelCsvByStr(WidgetName).OpenLevel
						local strOpenFuncName = getFunctionOpenLevelCsvByStr(WidgetName).OpenFuncName
						local nOpenVipLevel = getFunctionOpenLevelCsvByStr(WidgetName).OpenVipLevel
						if nOpenLevel <= 200 then
							if nOpenVipLevel >= 1 then
								g_ShowSysWarningTips({text = string.format(_T("%s将在%d级开放, 加油练级哦~亲~！\n或在VIP等级达到VIP%d后开放~"), strOpenFuncName, nOpenLevel, nOpenVipLevel)})
							else
								g_ShowSysWarningTips({text = string.format(_T("%s将在%d级开放, 加油练级哦~亲~！"), strOpenFuncName, nOpenLevel)})
							end
						else
							g_ShowSysWarningTips({text =_T("功能暂未开放敬请期待...")})
						end
					end
				end
				nTimerId = nil
			else
				if onCleanUpEvent then
					local nTag = pSender:getTag()
					onCleanUpEvent(pSender, nTag)
				else
					if onPressedEvent then
						local WidgetName = pSender:getName()
						if g_CheckFuncCanOpenByWidgetName(WidgetName) then
							checkNextGuideInBtnEvent(pSender, onPressedEvent, nil, nil)
						else
							local nOpenLevel = getFunctionOpenLevelCsvByStr(WidgetName).OpenLevel
							local strOpenFuncName = getFunctionOpenLevelCsvByStr(WidgetName).OpenFuncName
							local nOpenVipLevel = getFunctionOpenLevelCsvByStr(WidgetName).OpenVipLevel
							if nOpenLevel <= 200 then
								if nOpenVipLevel >= 1 then
									g_ShowSysWarningTips({text = string.format(_T("%s将在%d级开放, 加油练级哦~亲~！\n或在VIP等级达到VIP%d后开放~"), strOpenFuncName, nOpenLevel, nOpenVipLevel)})
								else
									g_ShowSysWarningTips({text = string.format(_T("%s将在%d级开放, 加油练级哦~亲~！"), strOpenFuncName, nOpenLevel)})
								end
							else
								g_ShowSysWarningTips({text =_T("功能暂未开放敬请期待...")})
							end
						end
					end
				end
			end
        end
    end)
end