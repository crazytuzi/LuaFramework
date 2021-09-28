--------------------------------------------------------------------------------------
-- 文件名:	CClientMsgTips.lua.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2014-3-18 21:10
-- 版  本:	1.0
-- 描  述:	通用提示框界面
-- 应  用:  
---------------------------------------------------------------------------------------

local CClientMsgTips = class("CClientMsgTips")
CClientMsgTips.__index = CClientMsgTips

function CClientMsgTips:ctor()
	self.widgetInputNumber = nil;
end


--Game_ConfirmInput控件
function CClientMsgTips:showConfirmInput(szTitle, szHolderText, nMaxLen, onClickConfirm, onClickCancel, szDefaultText)
	local layer = TouchGroup:create()

	local Game_ConfirmInput = GUIReader:shareReader():widgetFromJsonFile("Game_ConfirmInput.json")
	Game_ConfirmInput:setTouchEnabled(true)
	
	local bOnTouchScreenLock = true
	
	local szTitle = szTitle or _T("文字输入")
	local szHolderText = szHolderText or _T("请在这里输入")
	local szDefaultText = szDefaultText or ""
	local nMaxLen = nMaxLen or 20
	
	
	local Image_ConfirmPNL = tolua.cast(Game_ConfirmInput:getChildByName("Image_ConfirmPNL"), "ImageView")
	local Image_Background = tolua.cast(Game_ConfirmInput:getChildByName("Image_Background"), "ImageView")
	
	local Button_Confirm = tolua.cast(Image_ConfirmPNL:getChildByName("Button_Confirm"), "Button")
	local Button_Cancel = tolua.cast(Image_ConfirmPNL:getChildByName("Button_Cancel"), "Button")
	local Label_Title = tolua.cast(Image_ConfirmPNL:getChildByName("Label_Title"), "Label")
	Label_Title:setText(szTitle)
	
	local ImageView_InputBase = tolua.cast(Image_ConfirmPNL:getChildByName("ImageView_InputBase"), "ImageView")
	local TextField_Input = tolua.cast(ImageView_InputBase:getChildByName("TextField_Input"), "TextField")

	TextField_Input:setMaxLengthEnabled(true)
	TextField_Input:setMaxLength(nMaxLen)
	TextField_Input:setPlaceHolder(szHolderText)
	TextField_Input:setText(szDefaultText)
	TextField_Input:setTouchEnabled(true)
	
	local function executeActionEndCall()
		bOnTouchScreenLock = false
	end
	g_CreateUIAppearAnimation_Scale(Image_ConfirmPNL, executeActionEndCall, 1.2, 0.2, Image_Background)
	
	layer:addWidget(Game_ConfirmInput)  
	local tbCurScene = g_pDirector:getRunningScene()
	tbCurScene:addChild(layer, INT_MAX)

    local function onClickCancel(pSender,eventType)
        if eventType ==ccs.TouchEventType.ended then
			local function executeActionEndCall()
				tbCurScene:removeChild(layer, true)
				if onClickCancel then
					onClickCancel()
				end
				bOnTouchScreenLock = false
			end	
			local Image_ConfirmPNL = tolua.cast(pSender:getParent(), "ImageView")
			if Image_ConfirmPNL and Image_ConfirmPNL:isExsit() then
				local Game_ConfirmInput = Image_ConfirmPNL:getParent()
				local Image_Background = tolua.cast(Game_ConfirmInput:getChildByName("Image_Background"), "ImageView")
				g_CreateUIDisappearAnimation_Scale(Image_ConfirmPNL, executeActionEndCall, 1.05, 0.2, Image_Background)
			end
        end
    end 
	Button_Cancel:setTouchEnabled(true)
    Button_Cancel:addTouchEventListener(onClickCancel)
	
	self.ConfirmInputText = ""
    local onClickConfirm = function(pSender,eventType)
        if eventType ==ccs.TouchEventType.ended then		
			local function executeActionEndCall()
				tbCurScene:removeChild(layer, true)
				local Image_ConfirmPNL = tolua.cast(pSender:getParent(), "ImageView")
				local ImageView_InputBase = tolua.cast(Image_ConfirmPNL:getChildByName("ImageView_InputBase"), "ImageView")
				local TextField_Input = tolua.cast(ImageView_InputBase:getChildByName("TextField_Input"), "TextField")
				self.ConfirmInputText = TextField_Input:getStringValue()
				if self.ConfirmInputText == "" then
					self.ConfirmInputText = nil
				end
				
				if onClickConfirm then
					onClickConfirm(self.ConfirmInputText or szHolderText)
				end
				bOnTouchScreenLock = false
			end
			
			if Image_ConfirmPNL and Image_ConfirmPNL:isExsit() then
				local Game_ConfirmInput = Image_ConfirmPNL:getParent()
				local Image_Background = tolua.cast(Game_ConfirmInput:getChildByName("Image_Background"), "ImageView")
				g_CreateUIDisappearAnimation_Scale(Image_ConfirmPNL, executeActionEndCall, 1.05, 0.2, Image_Background)
			end
        end
    end 
	Button_Confirm:setTouchEnabled(true)
    Button_Confirm:addTouchEventListener(onClickConfirm)
end

--新手引导那里要通过窗口获取控件，所以加了一个窗口的确认框
function CClientMsgTips:showConfirmWnd(szText, onClick_Confirm, onClick_Cancel)
	local tbParam = {
		szText = szText,
		onClick_Confirm = onClick_Confirm,
		onClick_Cancel = onClick_Cancel,
	}
	g_WndMgr:showWnd("Game_Confirm", tbParam)
end

function CClientMsgTips:showConfirm(szText, onClick_Confirm, onClick_Cancel)
	--
	self.widgetConfirm = nil
	
	local layer = TouchGroup:create()
	if not self.widgetConfirm then
		self.widgetConfirm = GUIReader:shareReader():widgetFromJsonFile("Game_Confirm.json")
		-- self.widgetConfirm:retain()
		layer:addWidget(self.widgetConfirm) 
	end
		
	local bOnTouchScreenLock = true
	local Image_ConfirmPNL = tolua.cast(self.widgetConfirm:getChildByName("Image_ConfirmPNL"), "ImageView")
	local Button_Confirm = tolua.cast(Image_ConfirmPNL:getChildByName("Button_Confirm"), "Button")
	local Button_Cancel = tolua.cast(Image_ConfirmPNL:getChildByName("Button_Cancel"), "Button")
	local Label_Tile = tolua.cast(Image_ConfirmPNL:getChildByName("Label_Tile"), "Label")
	local Label_Msg = tolua.cast(Image_ConfirmPNL:getChildByName("Label_Msg"), "Label")
	Label_Msg:setText(g_stringSize_insert(szText, "\n", 24, 600))

	local nWidth = Label_Msg:getSize().width + 180
	if nWidth > 700 then
		Image_ConfirmPNL:setSize(CCSizeMake(nWidth, 300))
	end

	local function executeActionEndCall()
		bOnTouchScreenLock = false
	end
	g_CreateUIAppearAnimation_Scale(Image_ConfirmPNL, executeActionEndCall, 1.2, 0.2)
	
     
    local tbCurScene = g_pDirector:getRunningScene()
	tbCurScene:addChild(layer, INT_MAX)
	
	Button_Confirm:setTouchEnabled(true)
    local function onClick_Button_Confirm(pSender, eventType)
        if eventType == ccs.TouchEventType.ended then
			if bOnTouchScreenLock then return end
			bOnTouchScreenLock = true
			g_playSoundEffect("Sound/ButtonClick.mp3")
			local function executeActionEndCall()
				tbCurScene:removeChild(layer, true)
				if onClick_Confirm then
					onClick_Confirm()
				end
				bOnTouchScreenLock = false
			end	
			g_CreateUIDisappearAnimation_Scale(Image_ConfirmPNL, executeActionEndCall, 1.05, 0.2)
        end
    end 
    Button_Confirm:addTouchEventListener(onClick_Button_Confirm)
	
	--取消全局
    Button_Cancel:setTouchEnabled(true)
    local function onClick_Button_Cancel(pSender,eventType)
        if eventType ==ccs.TouchEventType.ended then
			if bOnTouchScreenLock then return end
			bOnTouchScreenLock = true
			g_playSoundEffect("Sound/ButtonClick.mp3")
			local function executeActionEndCall()
				tbCurScene:removeChild(layer, true)
				if onClick_Cancel then
					onClick_Cancel()
				end
				bOnTouchScreenLock = false
			end	
			g_CreateUIDisappearAnimation_Scale(Image_ConfirmPNL, executeActionEndCall, 1.05, 0.2)
        end
    end 
    Button_Cancel:addTouchEventListener(onClick_Button_Cancel)
	
	self.widgetConfirm:setVisible(true)
	self.widgetConfirm:setTouchEnabled(true)
end

function CClientMsgTips:closeConfirm()
    if self.layerConfirm then
       local tbCurScene = g_pDirector:getRunningScene()
       tbCurScene:removeChild(self.layerConfirm, true)
       self.layerConfirm = nil
    end
end

--ShowTip控件
--tbPos传入的世界坐标
--tbString为传入的字符串table，控件会根据tbString的数量伸缩,cccColor不填会使用默认值
--[[  
tbString = 
	{
    	[1] = {"麻花藤", cccColor},
    	[2] = {"该死企鹅还我钱啊", cccColor},
		[3] = {"狗日的腾讯，杀啊", cccColor},
		......
	}
]]--
--anchorType描点类型，1为左下角对齐，2为左上角，3为右上角，4为右下角，5为中心点, 6为右边的中心点, 7为上边中心点,8为左边中心点,9为下边中心点默认值为1
--nOffset描点偏移量，默认为10
function CClientMsgTips:showTip(tbString, tbPos, anchorType)
	if not self.widgetShowTip then
		self.widgetShowTip = GUIReader:shareReader():widgetFromJsonFile("Game_ShowTip.json")
		self.widgetShowTip:retain()
	end

    local rootWidget = self.widgetShowTip:clone()

	if not rootWidget then
		SendError("CClientMsgTips:showTip rootWidget = nil")
		return false
	end

	self.TbTips = self.TbTips or {}
	local tips = CShowTip:new()
	tips:InitTips(rootWidget,tbString, tbPos, anchorType)

	table.insert(self.TbTips, tips)
end

function CClientMsgTips:RemoveTips()
	 local index = #self.TbTips or 0
    if index > 0 then
    	table.remove(self.TbTips, index)
    end
end

function CClientMsgTips:closeTip()
    -- if self.TipLayer then
    --     local tbCurScene = g_pDirector:getRunningScene()      
    --     tbCurScene:removeChild(self.TipLayer, true)
    --     self.TipLayer = nil
    -- end
end

-- function CClientMsgTips:showTalk(strWord, tbPos, anchorType)
--[[
	对话气泡
	local param = {
		text = "要说的文字",x = 0,y= 0 ,anchorType = 1 or 2 
	}
]]
function CClientMsgTips:showTalk(param)
	local nText = param.text or ""
	local x = param.x or 0
	local y = param.y or 0
	local anchorType = param.anchorType or 1
	
	local widget = GUIReader:shareReader():widgetFromJsonFile("Game_ShowTalk.json")
	
	-- if not self.widget then
		-- self.widget = GUIReader:shareReader():widgetFromJsonFile("Game_ShowTalk.json")
		-- self.widget:retain()
	-- end
	
	local layer = TouchGroup:create()
	layer:addWidget(widget)  
	
    local curScene = g_pDirector:getRunningScene()
	curScene:addChild(layer, INT_MAX)
	
	local btnObj = nil
	local pos_x = 0
	local desc = g_stringSize_insert(nText,"\n",20,300)
	--左
	local Button_ContentLeft = tolua.cast(widget:getChildByName("Button_ContentLeft"),"Button")
	Button_ContentLeft:setVisible(true)
	btnObj = Button_ContentLeft

	local Image_Arrow = tolua.cast(Button_ContentLeft:getChildByName("Image_Arrow"),"ImageView")
	Image_Arrow:setPositionY(40)
	--右
	local Button_ContentRight = tolua.cast(widget:getChildByName("Button_ContentRight"),"Button")
	Button_ContentRight:setVisible(false)
	if anchorType == 2 then
		Button_ContentRight:setVisible(true)
		btnObj = Button_ContentRight
		Button_ContentLeft:setVisible(false)
		
		Image_Arrow = tolua.cast(Button_ContentRight:getChildByName("Image_Arrow"),"ImageView")
		Image_Arrow:setPositionY(40)
		pos_x = 270
	end
	
	--上下浮动动画
	g_CreateUpAndDownAnimation(Image_Arrow)
	Label_Speach = tolua.cast(btnObj:getChildByName("Label_Speach"),"Label")
	Label_Speach:setText(desc)

	local ccNodeLabel_Word = tolua.cast(Label_Speach:getVirtualRenderer(),"CCLabelTTF")
	ccNodeLabel_Word:disableShadow(true)	
	
	local tbSize = Label_Speach:getContentSize()
	local contentWidth = tbSize.width + 40
	local contentHeight = tbSize.height + 50
	btnObj:setSize(CCSizeMake(contentWidth,contentHeight))
	btnObj:setPosition(ccp(x,y))
	
	Label_Speach:setPosition(ccp(20 + pos_x,tbSize.height+40))

	
    local function onClickScreen(pSender,eventType)
        if eventType ==ccs.TouchEventType.ended then
			g_playSoundEffect("Sound/ButtonClick.mp3")
			Image_Arrow:stopAllActions()
          	curScene:removeChild(layer,true)
        end
    end 
    widget:addTouchEventListener(onClickScreen)
	widget:setTouchEnabled(true)
	
end

--Game_ConfirmInputNumber控件
function CClientMsgTips:showConfirmInputNumber(strTxt, maxLenNum, onClickConfirm, onClickCancel, defaultValue)

	local layer = TouchGroup:create()
	
	if not self.widgetInputNumber then
		self.widgetInputNumber = GUIReader:shareReader():widgetFromJsonFile("Game_ConfirmInputNumber.json")
		self.widgetInputNumber:setTouchEnabled(true)
		self.widgetInputNumber:retain()
	end
	local Image_ConfirmPNL = tolua.cast(self.widgetInputNumber:getChildByName("Image_ConfirmPNL"), "ImageView")
	local Image_Background = tolua.cast(self.widgetInputNumber:getChildByName("Image_Background"), "ImageView")
	local Label_Msg = tolua.cast(Image_ConfirmPNL:getChildByName("Label_Msg"), "Label")
	Label_Msg:setText(strTxt)
	
	local Image_Input = tolua.cast(Image_ConfirmPNL:getChildByName("Image_Input"), "ImageView")
	local Panel_Text = tolua.cast(Image_Input:getChildByName("Panel_Text"), "Layout")
	local TextField_Input = tolua.cast(Panel_Text:getChildByName("TextField_Input"), "TextField")
	
	if not maxLenNum or maxLenNum == "" or maxLenNum <= 0 then  maxLenNum = 100 end 
	local digits = PrintDigits(maxLenNum * 10)
	TextField_Input:setMaxLength(digits)
	TextField_Input:setPlaceHolder(0)
	 	
	if not defaultValue or defaultValue == "" then
		defaultValue = 0
	end
	TextField_Input:setText(defaultValue)
		
	local function _isNumber(str)
		local bNum = isNumberOrCharacter(str) 
		local num =  tonumber(str)
		if bNum then 
			return 	num > maxLenNum  and maxLenNum or num
		end
		return -1 --这里不会出现 负数和其他字符 -1 表示 输入了被数字 字符
	end
	
	--键盘输入
	local laText = 0
	local function textFieldEvent(pSender, eventType)
		if eventType == ccs.TextFiledEventType.insert_text then
			local str = pSender:getStringValue()
			local number = _isNumber(str)
			if number < 0 then
				pSender:setText(laText)
				g_ShowSysWarningTips({text = _T("请输入正确数字……"),layout = layer,y = 232,x = 620})
				return
			end
			laText = number
			pSender:setText(number)
		end
	end
	TextField_Input:addEventListenerTextField(textFieldEvent)
	
	--加号按钮，减号按钮
	
	local NumberAddType = 0
	local mLoopTimer = false
	local LTimer = 0
	local function longOnChange()
		if (not self.widgetInputNumber) or (not self.widgetInputNumber:isExsit()) then return end
		local Image_ConfirmPNL = tolua.cast(self.widgetInputNumber:getChildByName("Image_ConfirmPNL"), "ImageView")
		local Image_Input = tolua.cast(Image_ConfirmPNL:getChildByName("Image_Input"), "ImageView")
		local Panel_Text = tolua.cast(Image_Input:getChildByName("Panel_Text"), "Layout")
		local TextField_Input_Local = tolua.cast(Panel_Text:getChildByName("TextField_Input"), "TextField")
		local count =tonumber( TextField_Input_Local:getStringValue() )
		LTimer = LTimer + 1
		if NumberAddType == 1 and count < maxLenNum and LTimer >= 20 then
			count = count + 1
			if count == maxLenNum then  mLoopTimer = true end
		elseif NumberAddType == 2 and count > 0 and LTimer >= 20 then
			count = count - 1
			if count == 0 then  mLoopTimer = true end
		end
		TextField_Input_Local:setText(count)  
		return mLoopTimer
	end
		
	local tbBegin = 0;
	local tbSize = 0;

	local function onClickBacknum(pSender, eventType)
		if eventType ==ccs.TouchEventType.began then
			mLoopTimer = false
			LTimer = 0;
			NumberAddType = pSender:getTag()
			
			tbBegin = pSender:getTouchStartPos()
			tbSize = pSender:getSize()
			
			g_Timer:pushLoopTimer(0, longOnChange)
		elseif eventType ==ccs.TouchEventType.moved then
			local tbCur = pSender:getTouchMovePos()
			if(math.abs(tbBegin.x - tbCur.x) >= tbSize.width / 2 or 
				math.abs(tbBegin.y - tbCur.y) >= tbSize.height / 2) then
				mLoopTimer = true
			end
        elseif eventType ==ccs.TouchEventType.ended then
			
			mLoopTimer = true
			
			local Image_Input = pSender:getParent()
			local Panel_Text = tolua.cast(Image_Input:getChildByName("Panel_Text"), "Layout")
			local TextField_Input_Local = tolua.cast(Panel_Text:getChildByName("TextField_Input"), "TextField")
			
          	local count =tonumber( TextField_Input_Local:getStringValue() )
			local tag = pSender:getTag()
			if tag == 1 then 
				if count >= maxLenNum then 
					g_ShowSysWarningTips({text = _T("数目过大……"),layout = layer,y = 232,x = 620})
					return 
				end
				count = count + 1 
			else 
				if count <= 0 then 
					g_ShowSysWarningTips({text = _T("数目已为0……"),layout = layer,y = 232,x = 620})
					return 
				end
				count = count - 1 
			end
			TextField_Input_Local:setText(count)
        end
    end
	
	local Button_Add = tolua.cast(Image_Input:getChildByName("Button_Add"), "Button")
	local Button_Minus = tolua.cast(Image_Input:getChildByName("Button_Minus"), "Button")
	--加减按钮
    Button_Add:setTouchEnabled(true)
    Button_Minus:setTouchEnabled(true)
    Button_Add:setTag(1)
    Button_Minus:setTag(2)
    Button_Add:addTouchEventListener(onClickBacknum)
	Button_Minus:addTouchEventListener(onClickBacknum)
	

	local function executeActionEndCall()
		if g_PlayerGuide:checkCurrentGuideSequenceNode("OpenWnd", "Game_ConfirmInputNumber") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	g_CreateUIAppearAnimation_Scale(Image_ConfirmPNL, executeActionEndCall, 1.2, 0.2, Image_Background)
	
	layer:addWidget(self.widgetInputNumber)  
	local tbCurScene = g_pDirector:getRunningScene()
	tbCurScene:addChild(layer, INT_MAX)

	--取消
	local Button_Cancel = tolua.cast(Image_ConfirmPNL:getChildByName("Button_Cancel"), "Button")
    Button_Cancel:setTouchEnabled(true)
    local function onClickBackcel(pSender,eventType)
        if eventType ==ccs.TouchEventType.ended then
			if (not self.widgetInputNumber) or (not self.widgetInputNumber:isExsit()) then return end
			local Image_ConfirmPNL = tolua.cast(self.widgetInputNumber:getChildByName("Image_ConfirmPNL"), "ImageView")
			local function executeActionEndCall()
				tbCurScene:removeChild(layer, true)
				if onClickCancel then
					onClickCancel()
				end
				if g_PlayerGuide:checkCurrentGuideSequenceNode("CloseWnd", "Game_ConfirmInputNumber") then
					g_PlayerGuide:showCurrentGuideSequenceNode()
				end
			end	
			g_CreateUIDisappearAnimation_Scale(Image_ConfirmPNL, executeActionEndCall, 1.05, 0.2, Image_Background)
        end
    end 
    Button_Cancel:addTouchEventListener(onClickBackcel)

	--确定
	local Button_Confirm = tolua.cast(Image_ConfirmPNL:getChildByName("Button_Confirm"), "Button")
    Button_Confirm:setTouchEnabled(true)
    local function onClickBack(pSender, eventType)
        if eventType == ccs.TouchEventType.ended then
			if (not self.widgetInputNumber) or (not self.widgetInputNumber:isExsit()) then return end
			local Image_ConfirmPNL = tolua.cast(self.widgetInputNumber:getChildByName("Image_ConfirmPNL"), "ImageView")
			local Image_Input = tolua.cast(Image_ConfirmPNL:getChildByName("Image_Input"), "ImageView")
			local Panel_Text = tolua.cast(Image_Input:getChildByName("Panel_Text"), "Layout")
			local TextField_Input_Local = tolua.cast(Panel_Text:getChildByName("TextField_Input"), "TextField")
			local mString =  tonumber( TextField_Input_Local:getStringValue() )

			-- TextField_Input_Local:setPlaceHolder(_T("请输入正确数字……"))
			local function executeActionEndCall()
				tbCurScene:removeChild(layer, true)
				if onClickConfirm then
					onClickConfirm(mString)
				end
			end	
			g_CreateUIDisappearAnimation_Scale(Image_ConfirmPNL, executeActionEndCall, 1.05, 0.2, Image_Background)
			
        end
    end 
    Button_Confirm:addTouchEventListener(onClickBack)

end

--MsgConfirm控件
function CClientMsgTips:showMsgConfirm(szText, funcWndCloseCall)
	local layer = TouchGroup:create()
	if not self.widgetMsgConfirm then
		self.widgetMsgConfirm = GUIReader:shareReader():widgetFromJsonFile("Game_MsgConfirm.json")
		if self.widgetMsgConfirm ~= nil then
			self.widgetMsgConfirm:retain()
		end
	end
		
	local bOnTouchScreenLock = true
	local Image_MsgConfirmPNL = tolua.cast(self.widgetMsgConfirm:getChildByName("Image_MsgConfirmPNL"), "ImageView")
	local Label_Msg = tolua.cast(Image_MsgConfirmPNL:getChildByName("Label_Msg"), "Label")
	Label_Msg:setText(g_stringSize_insert(szText,"\n",21,640))
	
	local nWidth = Label_Msg:getSize().width + 160
	Image_MsgConfirmPNL:setSize(CCSizeMake(nWidth, 180))

	local function executeActionEndCall()
		bOnTouchScreenLock = false
	end
	g_CreateUIAppearAnimation_Scale(Image_MsgConfirmPNL, executeActionEndCall, 1.2, 0.2)

	self.widgetMsgConfirm:removeFromParentAndCleanup(false)

    layer:addWidget(self.widgetMsgConfirm)  
    local tbCurScene = g_pDirector:getRunningScene()
	tbCurScene:addChild(layer, INT_MAX)
	
    local function onTouchScreen(pSender,eventType)
        if eventType ==ccs.TouchEventType.ended then
			if bOnTouchScreenLock then return end
			
			bOnTouchScreenLock = true
			g_playSoundEffect("Sound/ButtonClick.mp3")
			local function executeActionEndCall()
				tbCurScene:removeChild(layer, true)
				if funcWndCloseCall then
					funcWndCloseCall()
				end
				bOnTouchScreenLock = false
			end	
			g_CreateUIDisappearAnimation_Scale(Image_MsgConfirmPNL, executeActionEndCall, 1.05, 0.2)
        end
    end
	self.widgetMsgConfirm:setVisible(true)
	self.widgetMsgConfirm:setTouchEnabled(true)
	self.widgetMsgConfirm:addTouchEventListener(onTouchScreen)
end

--[[
	带感叹号图案的Tips
]]
function CClientMsgTips:showWarning(szText, funcWndCloseCall)
	local layer = TouchGroup:create()
	if not self.widgetWarning then
		self.widgetWarning = GUIReader:shareReader():widgetFromJsonFile("Game_Warning.json")
		self.widgetWarning:retain()
	end
	
	local bOnTouchScreenLock = true
	local Image_WarningPNL = tolua.cast(self.widgetWarning:getChildByName("Image_WarningPNL"), "ImageView")
	
	local Image_Warning = tolua.cast(Image_WarningPNL:getChildByName("Image_Warning"), "ImageView")
	local Label_Msg = tolua.cast(Image_Warning:getChildByName("Label_Msg"), "Label")
	Label_Msg:setText(szText)
	local nWidth = Image_Warning:getSize().width+Label_Msg:getSize().width
	Image_Warning:setPositionX(-(nWidth+24)/2)
	Image_WarningPNL:setSize(CCSizeMake(nWidth+180, 180))
	
	local function executeActionEndCall()
		bOnTouchScreenLock = false
	end
	g_CreateUIAppearAnimation_Scale(Image_WarningPNL, executeActionEndCall, 1.2, 0.2)
	
	layer:addWidget(self.widgetWarning)  
    local tbCurScene = g_pDirector:getRunningScene()
	tbCurScene:addChild(layer, INT_MAX)
	
    local function onTouchScreen(pSender,eventType)
        if eventType ==ccs.TouchEventType.ended then
			if bOnTouchScreenLock then return end
			
			bOnTouchScreenLock = true
			g_playSoundEffect("Sound/ButtonClick.mp3")
			local function executeActionEndCall()
				tbCurScene:removeChild(layer, true)
				if funcWndCloseCall then
					funcWndCloseCall()
				end
				bOnTouchScreenLock = false
			end	
			g_CreateUIDisappearAnimation_Scale(Image_WarningPNL, executeActionEndCall, 1.05, 0.2)
        end
    end
	self.widgetWarning:setVisible(true)
	self.widgetWarning:setTouchEnabled(true)
	self.widgetWarning:addTouchEventListener(onTouchScreen)
end

local function destoryWidget(widget)
	if(widget)then
		widget:release()
		widget = nil
	end
end

function CClientMsgTips:destroy()
	destoryWidget( self.widgetBatFail )
	destoryWidget(self.widgetInputNumber)
	destoryWidget( self.widgetInput)
	destoryWidget( self.widgetBatResult)
	destoryWidget( self.widgetConfirm)
	destoryWidget( self.widgetMsgConfirm)
	destoryWidget( self.widgetWarning)
	destoryWidget( self.widget)
	-- destoryWidget( self.widgetShowTip)
	destoryWidget( self.rootWidget)
end

------------------创建对象
--g_ClientMsgTips = g_ClientMsgTips or CClientMsgTips.new()
g_ClientMsgTips = CClientMsgTips.new()


--MsgTips 处理客户端弹框类
CShowTip = class("CShowTip")
CShowTip.__index = CShowTip

function CShowTip:ctor()
	self.layer = nil
end


function CShowTip:InitTips(rootWidget,tbString, tbPos, anchorType)

	self.layer = TouchGroup:create()

	local layer = self.layer

    layer:addWidget(rootWidget)  
    local tbCurScene = g_pDirector:getRunningScene()
	tbCurScene:addChild(layer, INT_MAX)
	
	local Panel_Content = tolua.cast(rootWidget:getChildByName("Panel_Content"), "Layout")
	local ListView_Tips = tolua.cast(Panel_Content:getChildByName("ListView_Tips"), "ListView")
	ListView_Tips:setTouchEnabled(false)
	local Label_Tip = tolua.cast(ListView_Tips:getChildByName("Label_Tip"), "Label")
	ListView_Tips:setItemModel(Label_Tip)
    ListView_Tips:removeAllItems()
    ListView_Tips:removeAllChildren()
	
	local nWidth = 0
	local nHeight = 0
	local nCount = GetTableLen(tbString)
	if tbString then
		for i = 1, nCount do
			local Label_Tip = tolua.cast(ListView_Tips:pushBackDefaultItem() , "Label")
			Label_Tip:setText(tbString[i][1])
			if i == 1 then
				if tbString[i][2] then
					Label_Tip:setColor(tbString[i][2])
				else
					Label_Tip:setColor(ccc3(255,70,0))
				end
			else
				if tbString[i][2] then
					Label_Tip:setColor(tbString[i][2])
				else
					Label_Tip:setColor(ccc3(255,255,200))
				end
				Label_Tip:setFontSize(21)
			end
			local tbSize = Label_Tip:getContentSize()
			if tbSize.width > nWidth then
				nWidth = tbSize.width
			end
			nHeight = nHeight + tbSize.height
		end
	end
	
	local nBorderWidth = 66
	local nBorderHeight = 50
	local Panel_Content =  tolua.cast(rootWidget:getChildByName("Panel_Content"), "Layout")
	local contentWidth = nWidth+nBorderWidth+4
	local contentHeight = 4*nCount + nHeight + nBorderHeight + 4
	Panel_Content:setSize(CCSizeMake(contentWidth, contentHeight))
	

	--anchorType描点类型，1为左下角对齐，2为左上角，3为右上角，4为右下角，5为中心点, 6为右边的中心点, 7为上边中心点,8为左边中心点,9为下边中心点默认值为1
	--nOffset描点偏移量，默认为10

	if anchorType == 1 then
		if tbPos.x < 20 then
			tbPos.x = 20
		end
		Panel_Content:setPosition(ccp(tbPos.x, tbPos.y))
	elseif anchorType == 2 then
		if tbPos.x < 20 then
			tbPos.x = 20
		end
		Panel_Content:setPosition(ccp(tbPos.x, tbPos.y - contentHeight))
	elseif anchorType == 3 then
		if (1280 - (tbPos.x - contentWidth)) < 20 then
			tbPos.x = 1280 - contentWidth - 20
		end
		Panel_Content:setPosition(ccp(tbPos.x - contentWidth, tbPos.y - contentHeight))
	elseif anchorType == 4 then
		if (1280 - (tbPos.x - contentWidth)) < 20 then
			tbPos.x = 1280 - contentWidth - 20
		end
		Panel_Content:setPosition(ccp(tbPos.x - contentWidth, tbPos.y))
	elseif anchorType == 5 then
		Panel_Content:setPosition(ccp(tbPos.x - contentWidth/2, tbPos.y - contentHeight/2))
	elseif anchorType == 6 then
		if (1280 - (tbPos.x - contentWidth)) < 20 then
			tbPos.x = 1280 - contentWidth - 20
		end
		Panel_Content:setPosition(ccp(tbPos.x - contentWidth, tbPos.y - contentHeight/2))
	elseif anchorType == 7 then
		Panel_Content:setPosition(ccp(tbPos.x - contentWidth/2,  tbPos.y - contentHeight))
	elseif anchorType == 8 then
		if tbPos.x < 20 then
			tbPos.x = 20
		end
		Panel_Content:setPosition(ccp(tbPos.x,  tbPos.y - contentHeight/2))
	elseif anchorType == 9 then
		Panel_Content:setPosition(ccp(tbPos.x - contentWidth/2,  tbPos.y))
	else
		Panel_Content:setPosition(tbPos)
	end
	
	ListView_Tips:setSize(CCSizeMake(nWidth, 4*nCount + nHeight))
	ListView_Tips:setPosition(ccp(nBorderWidth/2, nBorderHeight/2 + 4))
	
    local function onClickScreen(pSender,eventType)
        if eventType ==ccs.TouchEventType.ended then
			g_playSoundEffect("Sound/ButtonClick.mp3")
			if self.layer then
				self.layer:removeFromParentAndCleanup(true)
			end
          	self.layer = nil

          	g_ClientMsgTips:RemoveTips()
        end
    end 
    rootWidget:addTouchEventListener(onClickScreen)
	rootWidget:setTouchEnabled(true)
end


--Game_Confirm控件
Game_Confirm = class("Game_Confirm")
Game_Confirm.__index = Game_Confirm

function Game_Confirm:initWnd()
end

function Game_Confirm:openWnd(tbParam)
	if not tbParam then return end
	self.tbParam = tbParam
	local Image_ConfirmPNL = tolua.cast(self.rootWidget:getChildByName("Image_ConfirmPNL"), "ImageView")
	local Button_Confirm = tolua.cast(Image_ConfirmPNL:getChildByName("Button_Confirm"), "Button")
	local Button_Cancel = tolua.cast(Image_ConfirmPNL:getChildByName("Button_Cancel"), "Button")
	local Label_Tile = tolua.cast(Image_ConfirmPNL:getChildByName("Label_Tile"), "Label")
	local Label_Msg = tolua.cast(Image_ConfirmPNL:getChildByName("Label_Msg"), "Label")
	Label_Msg:setText(g_stringSize_insert(self.tbParam.szText, "\n", 24, 600))
	
	local nWidth = Label_Msg:getSize().width + 180
	if nWidth > 700 then
		Image_ConfirmPNL:setSize(CCSizeMake(nWidth, 300))
	end
	
	Button_Confirm:setTouchEnabled(true)
    local function onClick_Confirm(pSender, eventType)
        if eventType == ccs.TouchEventType.ended then
			local function wndCloseCall()
				if self.tbParam.onClick_Confirm then
					self.tbParam.onClick_Confirm()
				end
			end
			g_WndMgr:closeWnd("Game_Confirm", wndCloseCall)
        end
    end 
    Button_Confirm:addTouchEventListener(onClick_Confirm)
	
	--取消全局
    Button_Cancel:setTouchEnabled(true)
    local function onClick_Cancel(pSender,eventType)
        if eventType ==ccs.TouchEventType.ended then
			local function wndCloseCall()
				if self.tbParam.onClick_Cancel then
					self.tbParam.onClick_Cancel()
				end
			end
			g_WndMgr:closeWnd("Game_Confirm", wndCloseCall)
        end
    end 
    Button_Cancel:addTouchEventListener(onClick_Cancel)
end

function Game_Confirm:closeWnd()
end

function Game_Confirm:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ConfirmPNL = tolua.cast(self.rootWidget:getChildByName("Image_ConfirmPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ConfirmPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_Confirm:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ConfirmPNL = tolua.cast(self.rootWidget:getChildByName("Image_ConfirmPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ConfirmPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end

--------------------------------------------------------------
--系统飘字
--[[
	使用方法
	local param = {
		text = "这个一定要填写",layout = "加载到那个层级 可以不设置",
		ccsColor = "设置颜色 ccc3(0,0,0) 可以不设置",
		x = "",
		y= "",
	}
	g_ShowSysWarningTips(param)
]]
function g_ShowSysTips(param)
	if not param then return end
	
	local text = param.text or _T("没有输入文字")
	local ccsColor = param.ccsColor or ccs.COLOR.WHITE
	local layout = param.layout or g_WndMgr.rootWndMgrLayer
    if layout == nil then return end
	local x = param.x or 640
	local y = param.y or 360
	local fontSize = param.fontSize or 24

	local Image_SysTipPNL = tolua.cast(g_WidgetModel.Image_SysTipPNL:clone(), "ImageView")
    if Image_SysTipPNL == nil then return end
	Image_SysTipPNL:setCascadeOpacityEnabled(true)
	Image_SysTipPNL:setOpacity(0)
	Image_SysTipPNL:setScale(0.25)

	local Label_Warning = tolua.cast(Image_SysTipPNL:getChildByName("Label_Warning"), "Label")
    if Label_Warning == nil then return end
	Label_Warning:setText(text)
	Label_Warning:setFontSize(fontSize)
	g_setTextColor(Label_Warning, ccsColor)
	
	local nContentWidth = Label_Warning:getSize().width
	local nContentHeight = Label_Warning:getSize().height
	Image_SysTipPNL:setSize(CCSizeMake(nContentWidth+100, nContentHeight+50))
	
	Image_SysTipPNL:setPosition(ccp(x,y))
	layout:addChild(Image_SysTipPNL, INT_MAX, 500) 
	
	local function executeCleanupAction()
		Image_SysTipPNL:removeFromParentAndCleanup(true)
	end
	
	local arrAct = CCArray:create()
	local action_FadeTo1 = CCFadeTo:create(0.15, 255)
	local action_ScaleTo1 = CCScaleTo:create(0.15, 1.2)
	local action_Spwan1 = CCSpawn:createWithTwoActions(action_FadeTo1, action_ScaleTo1)
	local action_SpwanEase1 = CCEaseOut:create(action_Spwan1, 3)
	local action_ScaleTo2 = CCScaleTo:create(0.15, 1)
	local action_ScaleTo3 = CCScaleTo:create(0.15, 1.2)
	local action_FadeTo4 = CCFadeTo:create(0.15, 0)
	local action_ScaleTo4 = CCScaleTo:create(0.15, 0.2)
	local action_Spwan4 = CCSpawn:createWithTwoActions(action_FadeTo4, action_ScaleTo4)
	local action_SpwanEase4 = CCEaseOut:create(action_Spwan4, 2)
	arrAct:addObject(action_SpwanEase1)
	arrAct:addObject(action_ScaleTo2)
	arrAct:addObject(CCDelayTime:create(0.5))
	arrAct:addObject(action_ScaleTo3)
	arrAct:addObject(action_SpwanEase4)
	arrAct:addObject(CCCallFuncN:create(executeCleanupAction))
	local actionSequence = CCSequence:create(arrAct)
	Image_SysTipPNL:runAction(actionSequence)
end


local TipsWordTag = 0x88888811
function g_ShowSysTipsWord(param)
	if not param then return end
	
	local text = param.text or _T("没有输入文字")
	local ccsColor = param.ccsColor or ccs.COLOR.WHITE
	local layout = param.layout or g_WndMgr.rootWndMgrLayer
	local x = param.x or 640
	local y = param.y or 360
	local fontSize = param.fontSize or 24
	local sysFunc = param.sysFunc
	
	local pluralLayout = param.pluralLayout
	if not pluralLayout  and layout:getChildByTag(TipsWordTag) ~= nil then
		layout:getChildByTag(TipsWordTag):removeFromParentAndCleanup(true)
	end

	local Label_Warning = Label:create()
	Label_Warning:setText(text)
	Label_Warning:setFontSize(fontSize)
	Label_Warning:setTag(TipsWordTag)
	g_setTextColor(Label_Warning, ccsColor)
	Label_Warning:setPosition(ccp(x,y))
	
	layout:addChild(Label_Warning, INT_MAX, TipsWordTag) 

	local function executeCleanupAction()
		Label_Warning:removeFromParentAndCleanup(true)
		if sysFunc then 
			sysFunc()
		end
	end
	
	local arrAct = CCArray:create()
	local action_FadeTo1 = CCFadeTo:create(0.2, 255)
	local action_ScaleTo1 = CCScaleTo:create(0.2, 1.2)
	local action_Spwan1 = CCSpawn:createWithTwoActions(action_FadeTo1, action_ScaleTo1)
	local action_ScaleTo2 = CCScaleTo:create(0.2, 1)
	local action_MoveBy3 = CCMoveBy:create(0.2,ccp(0, 45))
	local action_FadeOut3 = CCFadeOut:create(0.4)
	local action_Spwan3 = CCSpawn:createWithTwoActions(action_MoveBy3, action_FadeOut3)
	local action_SpwanEase3 = CCEaseOut:create(action_Spwan3, 1)
	arrAct:addObject(action_Spwan1)
	arrAct:addObject(action_ScaleTo2)
	arrAct:addObject(CCDelayTime:create(0.1))
	arrAct:addObject(action_SpwanEase3)
	arrAct:addObject(CCCallFuncN:create(executeCleanupAction))
	local actionSequence = CCSequence:create(arrAct)
	Label_Warning:runAction(actionSequence)
end

		
function g_ShowSysWarningTips(param, fKeepTime)
	local fKeepTime = fKeepTime or 0.5
	if not param then return end
	
	local text = param.text or _T("没有输入文字")
	local ccsColor = param.ccsColor or ccs.COLOR.WHITE
	local layout = param.layout or g_WndMgr.rootWndMgrLayer
	if layout == nil then
		return
	end
	local x = param.x or 640
	local y = param.y or 360
	local fontSize = param.fontSize or 24

	local Image_SysWarningTipPNL = tolua.cast(g_WidgetModel.Image_SysWarningTipPNL:clone(), "ImageView")
	Image_SysWarningTipPNL:setCascadeOpacityEnabled(true)
	Image_SysWarningTipPNL:setOpacity(0)
	Image_SysWarningTipPNL:setScale(0.25)
	
	local Image_Warning = tolua.cast(Image_SysWarningTipPNL:getChildByName("Image_Warning"), "ImageView")
	local Label_Warning = tolua.cast(Image_Warning:getChildByName("Label_Warning"), "Label")
	Label_Warning:setText(text)
	Label_Warning:setFontSize(fontSize)
	g_setTextColor(Label_Warning, ccsColor)
	
	
	local nWidth = Label_Warning:getSize().width
	local nHeight = Label_Warning:getSize().height
	local nContentWidth = Image_Warning:getSize().width+20+nWidth
	Image_Warning:setPositionX(-(nContentWidth)/2)
	
	Image_SysWarningTipPNL:setSize(CCSizeMake(nContentWidth+100, nHeight+40))
	
	Image_SysWarningTipPNL:setPosition(ccp(x,y))
	layout:addChild(Image_SysWarningTipPNL, INT_MAX, 500) 
	
	local function executeCleanupAction()
		Image_SysWarningTipPNL:removeFromParentAndCleanup(true)
	end
	
	local arrAct = CCArray:create()
	local action_FadeTo1 = CCFadeTo:create(0.15, 255)
	local action_ScaleTo1 = CCScaleTo:create(0.15, 1.2)
	local action_Spwan1 = CCSpawn:createWithTwoActions(action_FadeTo1, action_ScaleTo1)
	local action_SpwanEase1 = CCEaseOut:create(action_Spwan1, 3)
	local action_ScaleTo2 = CCScaleTo:create(0.15, 1)
	local action_ScaleTo3 = CCScaleTo:create(0.15, 1.2)
	local action_FadeTo4 = CCFadeTo:create(0.15, 0)
	local action_ScaleTo4 = CCScaleTo:create(0.15, 0.2)
	local action_Spwan4 = CCSpawn:createWithTwoActions(action_FadeTo4, action_ScaleTo4)
	local action_SpwanEase4 = CCEaseOut:create(action_Spwan4, 2)
	arrAct:addObject(action_SpwanEase1)
	arrAct:addObject(action_ScaleTo2)
	arrAct:addObject(CCDelayTime:create(fKeepTime))
	arrAct:addObject(action_ScaleTo3)
	arrAct:addObject(action_SpwanEase4)
	arrAct:addObject(CCCallFuncN:create(executeCleanupAction))
	local actionSequence = CCSequence:create(arrAct)
	Image_SysWarningTipPNL:runAction(actionSequence)
end

--服务端错误弹出的飘字，客户端调试也可以用这个，手机是是不会弹这个的
function g_ShowServerSysTips(param)
	-- if g_Cfg.Platform == kTargetWindows then
	-- 	g_ShowSysWarningTips(param)
	-- else
	-- 	--nil手机上不弹服务端Tips	
	-- end

	g_ShowSysWarningTips(param, 1.5)
	g_MsgNetWorkWarning:closeNetWorkWarning()
end

-- --客户端DeBug使用的飘字
-- function g_ShowDeBugSysTips(param)
	-- if g_Cfg.Platform == kTargetWindows then
		-- g_ShowSysWarningTips(param)
	-- else
		-- g_ShowSysWarningTips(param)
	-- end
-- end

--服务端掉落包提示
function g_ShowDropSysTips(nDropID, nDropSubID, strCsvName, key1, key2)
	local nDropID = nDropID or 0
	local nDropSubID = nDropSubID or 0
	local strCsvName = strCsvName or _T("配置不存在")
	local key1 = key1 or 0
	local key2 = key2 or 0
	
	if g_Cfg.Platform == kTargetWindows then
		if key2 > 0 then
			local strTex = "掉落包ID"..nDropID.."的子包ID"..nDropSubID.."中的配置的脚本"..strCsvName.."中的MainKey"..key1.."和SubKey"..key2.."配置不存在"
			g_ShowSysWarningTips({strTex, layout = curScene, y = 232,x = 620})
		else
			local strTex = "掉落包ID"..nDropID.."的子包ID"..nDropSubID.."中的配置的脚本"..strCsvName.."中的MainKey"..key1.."配置不存在"
			g_ShowSysWarningTips({text = strTex, layout = curScene, y = 232,x = 620})
		end
	else
		--nil手机上不弹服务端Tips	
	end
end

---------------------------------专用 卡牌召唤消耗魂石，魂魄，升星消耗提示和选择----------------
--[[
	带有优先消耗魂魄,优先消耗万能魂石两个选项
]]

Game_ConfirmHunPo = class("Game_ConfirmHunPo")
Game_ConfirmHunPo.__index = Game_ConfirmHunPo

function Game_ConfirmHunPo:initWnd()
end

--[[
	tbParam = {
		txt = "",
		csvCardHunPo = "",--魂魄数据
		btnConfirm = function() end,
	}
]]
function Game_ConfirmHunPo:openWnd(tbParam)
	
	if not tbParam then return end
	
	local itemType = 1
	
	local txt = tbParam.txt
	local btnConfirm = tbParam.btnConfirm
	local btnCancel = tbParam.onClick_Cancel
	local csvCardHunPo = tbParam.csvCardHunPo
	
	local Image_ConfirmHunPoPNL = tolua.cast(self.rootWidget:getChildByName("Image_ConfirmHunPoPNL"), "ImageView")
	
	local Label_Msg = tolua.cast(Image_ConfirmHunPoPNL:getChildByName("Label_Msg"), "Label")
	Label_Msg:setText(g_stringSize_insert(txt, "\n", 24, 600))
	
	local CheckBox_HunPoFirst = tolua.cast(Image_ConfirmHunPoPNL:getChildByName("CheckBox_HunPoFirst"),"CheckBox")	
	local Label_FuncName = tolua.cast(CheckBox_HunPoFirst:getChildByName("Label_FuncName"), "Label")

	
	local CheckBox_WanNengFirst = tolua.cast(Image_ConfirmHunPoPNL:getChildByName("CheckBox_WanNengFirst"),"CheckBox")	
	local Label_FuncName = tolua.cast(CheckBox_WanNengFirst:getChildByName("Label_FuncName"), "Label")
	
	
	local cardHunPoID = csvCardHunPo.ID
	
	local needSum = not csvCardHunPo.NeedNum and csvCardHunPo.StarUpHunPoNum  or csvCardHunPo.NeedNum
	
	
	local GameObjHunPo = g_Hero:getHunPoObj(cardHunPoID)
	local nHaveHunPoNum =  not GameObjHunPo and 0  or GameObjHunPo:getNum() --拥有多少个魂魄
	local nHaveMaterialNum = g_Hero:getItemNumByCsv(csvCardHunPo.ReplaceMaterialID, csvCardHunPo.ReplaceMaterialLevel)
			
	local nReplaceMaxNum = 0
	local nCostHunPoNum = 0
	local CSV_CardBase = g_DataMgr:getCardBaseCsv(cardHunPoID, csvCardHunPo.CardStarLevel)
	local cbgrp = CheckBoxGroup:New()
	cbgrp:PushBack(CheckBox_HunPoFirst, function() 
		echoj("优先消耗魂魄")
		itemType = 1;
		nCostHunPoNum = math.min(nHaveHunPoNum, needSum)
		nReplaceMaxNum = math.min(nHaveMaterialNum, needSum - nCostHunPoNum)
		txt = string.format(_T("消耗%d个%s的魂魄和%d个万能魂石进行召唤, 是否继续?"), nCostHunPoNum, CSV_CardBase.Name, nReplaceMaxNum)
		Label_Msg:setText(g_stringSize_insert(txt, "\n", 24, 600))
	end)
	
	cbgrp:PushBack(CheckBox_WanNengFirst, function() 
		echoj("优先消耗魂石")
		itemType = 2;
		nReplaceMaxNum = math.min(nHaveMaterialNum, csvCardHunPo.ReplaceMaterialMaxNum) --万能魂石
		nCostHunPoNum = math.min(nHaveHunPoNum, needSum - nReplaceMaxNum)	--魂魄
		txt = string.format(_T("消耗%d个%s的魂魄和%d个万能魂石进行召唤, 是否继续?"), nCostHunPoNum, CSV_CardBase.Name, nReplaceMaxNum)
		Label_Msg:setText(g_stringSize_insert(txt, "\n", 24, 600))
	end)
	cbgrp:Check(1)
	
	--确定按钮
    local function onClick_Confirm(pSender, eventType)
        if eventType == ccs.TouchEventType.ended then
			if btnConfirm then btnConfirm(itemType) end
			g_WndMgr:closeWnd("Game_ConfirmHunPo")
        end
    end 
	local Button_Confirm = tolua.cast(Image_ConfirmHunPoPNL:getChildByName("Button_Confirm"), "Button")
	Button_Confirm:setTouchEnabled(true)
    Button_Confirm:addTouchEventListener(onClick_Confirm)
	
	--取消
    local function onClick_Cancel(pSender,eventType)
        if eventType ==ccs.TouchEventType.ended then
			if btnCancel then btnCancel(itemType) end
			g_WndMgr:closeWnd("Game_ConfirmHunPo")
        end
    end 
	local Button_Cancel = tolua.cast(Image_ConfirmHunPoPNL:getChildByName("Button_Cancel"), "Button")
	Button_Cancel:setTouchEnabled(true)
    Button_Cancel:addTouchEventListener(onClick_Cancel)
end

function Game_ConfirmHunPo:closeWnd()
end

function Game_ConfirmHunPo:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ConfirmHunPoPNL = tolua.cast(self.rootWidget:getChildByName("Image_ConfirmHunPoPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ConfirmHunPoPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_ConfirmHunPo:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ConfirmHunPoPNL = tolua.cast(self.rootWidget:getChildByName("Image_ConfirmHunPoPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ConfirmHunPoPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end