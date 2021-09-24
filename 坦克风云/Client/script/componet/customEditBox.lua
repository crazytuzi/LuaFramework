customEditBox={}

function customEditBox:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end 

--content:默认显示背景,父容器 textLabel:默认显示文字 editBoxBg:box背景,点击显示 editBoxSize:box大小 priority:优先级 maxLength:文本长度 changeCallback:回调函数,
--需要则返回文本内容 inputFlag:输入类型 inputMode:输入模式 ifNotShowBoxBg:点击是否显示box背景,默认显示
function customEditBox:init(container,textLabel,editBoxBg,editBoxSize,priority,maxLength,changeCallback,inputFlag,inputMode,ifNotShowBoxBg,clickCallback,showLength,position,endCallBack,loginFlag,nocheck)
    ifNotShowBoxBg=true
	local textValue=textLabel:getString()
	if textValue==nil then
		textValue=""
	end
	local function tthandler()
		
    end
	local showStr
	local lastStr
	local loginFlagStr
    local function callBackHandler(fn,eB,str,type)
    	
        str=tostring(str)
		if type==0 then  --开始输入
            if showStr then
                showStr=""
            end
		elseif type==1 then  --检测文本内容变化
			if str==nil then
				textValue=""
			else
				textValue=str
				if changeCallback then
					local txt=changeCallback(fn,eB,str,type)
					if txt then
						textValue=txt
						eB:setText(textValue)
					end
				end
			end
			if G_utfstrlen(tostring(str) or "")>maxLength then
			else
				lastStr=str
			end
            if textValue~="" and inputFlag==CCEditBox.kEditBoxInputFlagPassword then
            	if loginFlag == true then
            		loginFlagStr = textValue
            		self.flagPwd = nil
            	end
                local passwordText=string.gsub(textValue,".","●")
                textLabel:setString(passwordText)
                --textLabel:setString("●●●●●●")
            elseif showStr and showStr~="" then
				textLabel:setString(showStr)
			else
                textLabel:setString(textValue)
			end
		elseif type==2 then --检测文本输入结束
			eB:setVisible(false)
			if textLabel then
				textLabel=tolua.cast(textLabel,"CCLabelTTF")
				if textLabel==nil then
					do return end
				end
				textLabel:setColor(G_ColorWhite)
				for k,v in pairs(GM_Name) do
	                if v == textValue then
	                    textLabel:setColor(G_ColorYellowPro)
	                    do break end
	                end
	            end
			end
			if ifNotShowBoxBg and textLabel then
				textLabel:setVisible(true)
			end
			if G_utfstrlen(tostring(textValue) or "")>maxLength then
				textValue=lastStr or ""
				eB:setText(textValue)
				if textLabel then
					textLabel:setString(textValue)
				end
			end
			if showLength and textLabel then
				if textLabel:getContentSize().width>showLength then
					local textStr=textLabel:getString()
					local strLength=string.len(textStr)
					-- local strLabel=GetTTFLabel("",textLabel.getFontSize(textLabel))
					for i=15,strLength do
						showStr=string.sub(textStr,1,i).."..."
						textLabel:setString(showStr)
						if textLabel:getContentSize().width>showLength then
							break
						end
					end
				end
			end
			if endCallBack then
				endCallBack()
			end
		end
    end

	container:addChild(textLabel,2)

    local winSize=CCEGLView:sharedOpenGLView():getFrameSize()
    local xScale=winSize.width/640
    local yScale=winSize.height/960

	local size
	if editBoxSize then
		size=editBoxSize
	else
		size=CCSizeMake(container:getContentSize().width,container:getContentSize().height)
	end
    --size=CCSizeMake(size.width,size.height*yScale)

    local xBox=LuaCCScale9Sprite:createWithSpriteFrameName(editBoxBg,CCRect(20,20,1,1),tthandler)
	if ifNotShowBoxBg then
		xBox:setOpacity(0)
	end
    local editBox=CCEditBox:createForLua(size,xBox,nil,nil,callBackHandler)
	--editBox:setFont(textLabel.getFontName(textLabel),20)
	if(G_getIphoneType()==G_iphoneX)then
		editBox:setFont(textLabel.getFontName(textLabel),yScale*textLabel.getFontSize(textLabel)/3)
	else
	    editBox:setFont(textLabel.getFontName(textLabel),yScale*textLabel.getFontSize(textLabel)/2)
	end
	editBox:setText(textValue)
	editBox:setAnchorPoint(ccp(0,0))
    editBox:setPosition(ccp(0,0))
    if yScale>1 then
        editBox:setPosition(ccp(5,0))
    end
    if position then
    	editBox:setPosition(position)
    end
	if inputFlag then
		editBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsSentence)
	else
        editBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsSentence)
	end
	if inputMode then
		editBox:setInputMode(inputMode)
	else
		editBox:setInputMode(editBox.kEditBoxInputModeSingleLine)
	end
	if maxLength then
		editBox:setMaxLength(maxLength)
	end
    editBox:setVisible(false)
    container:addChild(editBox,3)
	
    local function tthandler2()
		local isMoved=false
		if clickCallback~=nil then
			isMoved=clickCallback()
		end
		if isMoved~=true then
	        PlayEffect(audioCfg.mouseClick)
	        editBox:setVisible(true)
			-- textValue=textLabel:getString()
            if textLabel:getString()=="" or textLabel:getString()=="0" then
                textValue=textLabel:getString()
            end
            if loginFlag == true then
            	if loginFlagStr and inputFlag==CCEditBox.kEditBoxInputFlagPassword and (not self.flagPwd) then
            		editBox:setText(loginFlagStr)
            	else
            		editBox:setText(textLabel:getString())
            	end
            else
				editBox:setText(textValue)
			end
			if nocheck == true then
				editBox:setText(textLabel:getString() or "")
			end
			if ifNotShowBoxBg then
				textLabel:setVisible(false)
			end
		end
    end
    local touchRect=LuaCCScale9Sprite:createWithSpriteFrameName(editBoxBg,CCRect(10,10,5,5),tthandler2)
	touchRect:ignoreAnchorPointForPosition(false)
	touchRect:setAnchorPoint(ccp(0,0))
	touchRect:setPosition(ccp(0,0))
	if touchSize then
		touchRect:setContentSize(touchSize)
	else
		touchRect:setContentSize(size)
	end
	touchRect:setIsSallow(false)
    touchRect:setTouchPriority(priority)
    touchRect:setOpacity(0)
    container:addChild(touchRect)
	return editBox,textValue,touchRect
end

function customEditBox:utfstrlen(str)
    local len = #str;
    local left = len;
    local cnt = 0;
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
    while left ~= 0 do
        local tmp=string.byte(str,-left);
        local i=#arr;
        while arr[i] do
            if tmp>=arr[i] then 
                left=left-i;
                break;
            end
                i=i-1;
        end
		--[[
        if tmp>=192 then
            cnt=cnt+2;
        else
            cnt=cnt+1;
        end
		]]
        cnt=cnt+1;
    end
    return cnt;
end
