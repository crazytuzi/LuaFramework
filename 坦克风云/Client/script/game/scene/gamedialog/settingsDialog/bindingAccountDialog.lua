--require "luascript/script/componet/commonDialog"
bindingAccountDialog=commonDialog:new()

function bindingAccountDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.Account=nil
	self.password=nil
	self.passwordAgain=nil
	self.inviterId=nil
    return nc
end

--设置对话框里的tableView
function bindingAccountDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-230))
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2+20))
	
	local passwordMiniLength=6
	local labelTab={"realMailAccount","passwordAccount","passwordconfirm","inviterId"}
	for i=1,SizeOfTable(labelTab) do
	    local changePwLabel=GetTTFLabel(getlocal(labelTab[i]),30)
		changePwLabel:setAnchorPoint(ccp(0,0))
	    changePwLabel:setPosition(ccp(25,self.panelLineBg:getContentSize().height-140*i+70))
	    self.panelLineBg:addChild(changePwLabel,2)
		
	    local function callBackPasswordHandler(fn,eB,str)
			if str==nil then
				str=""
			end
			if i==1 then
                if platCfg.platRayJoyAccountPrefix[G_curPlatName()]~=nil then
                    self.Account=platCfg.platRayJoyAccountPrefix[G_curPlatName()]["rj"]..str
                else
                    self.Account=str
                end
			elseif i==2 then
				self.password=str
			elseif i==3 then
				self.passwordAgain=str
			elseif i==4 then
				self.inviterId=str
			end
	    end

	    local function cellClick(hd,fn,idx)
	    end
	    local passwordBox=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10,10,5,5),cellClick)
		passwordBox:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width-50,70))
	    passwordBox:setIsSallow(false)
	    passwordBox:setTouchPriority(-(self.layerNum-1)*20-4)
	    passwordBox:setAnchorPoint(ccp(0.5,0))
		passwordBox:setPosition(ccp(self.panelLineBg:getContentSize().width/2,self.panelLineBg:getContentSize().height-140*i-0))
		
	    local passwordLabel=GetTTFLabel("",30)
		passwordLabel:setAnchorPoint(ccp(0,0.5))
	    passwordLabel:setPosition(ccp(10,passwordBox:getContentSize().height/2))

		local customEditBox=customEditBox:new()
		local length
		local inputMode=CCEditBox.kEditBoxInputModeUrl
		local inputFlag
		if i==1 then
			length=30
		else
			length=12
			if i==2 or i==3 then
				inputFlag=CCEditBox.kEditBoxInputFlagPassword
			end
		end
		customEditBox:init(passwordBox,passwordLabel,"mail_input_bg.png",nil,-(self.layerNum-1)*20-4,length,callBackPasswordHandler,inputFlag,inputMode)
	    self.panelLineBg:addChild(passwordBox)
		
		if i<4 then
			local tipLabel=GetTTFLabel(getlocal("limitLength",{length}),20)
			tipLabel:setAnchorPoint(ccp(0,1))
		    tipLabel:setPosition(ccp(25,self.panelLineBg:getContentSize().height-140*i-5))
		    self.panelLineBg:addChild(tipLabel,2)
			tipLabel:setColor(G_ColorRed)
		end
	end

	local bindAwardLabel=GetTTFLabelWrap(getlocal("bindAward"),30,CCSizeMake(30*18, 30*5),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	bindAwardLabel:setAnchorPoint(ccp(0,1))
	bindAwardLabel:setPosition(ccp(30,150))
	bindAwardLabel:setColor(G_ColorYellow)
	self.panelLineBg:addChild(bindAwardLabel,2)
	
	local function bindHandler(tag,object)
        PlayEffect(audioCfg.mouseClick)
		local tipStr=nil
		local isFull,AccountStr=G_checkBind()
		if isFull==false then
			tipStr=getlocal("bindFull",{AccountStr})
		elseif self.Account==nil or self.Account=="" then
			tipStr=getlocal("wrongMail")
		--elseif self:isChar(self.Account)==true or string.len(self.Account)<3 or string.find(self.Account,"@")==nil then
		elseif self:isRightEmail(self.Account)==false then
			tipStr=getlocal("wrongMail")
		elseif self.password==nil or string.find(self.password,"%s")~=nil then
			tipStr=getlocal("passwordWrong")
		elseif string.len(self.password)<passwordMiniLength then
			tipStr=getlocal("wrongPasswordLength")
		elseif self.passwordAgain==nil or self.passwordAgain~=self.password then
			tipStr=getlocal("wrongPasswordCf")
		end
		if tipStr then
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),tipStr,nil,5)
		else

                     ------以下调用http绑定账号
                    local cuname=G_getTankUserName()
                    local cuid=playerVoApi:getUid()
                    local zoneid
                    if(tonumber(base.curOldZoneID)~=nil and tonumber(base.curOldZoneID)>0)then
                    	zoneid=base.curOldZoneID
                    else
                    	zoneid=base.curZoneID
                    end
                    -- local curlStr=serverCfg.baseUrl..serverCfg.serverBindCountUrl.."?uid="..cuid.."&username="..self.Account.."&password="..self.password.."&oldpassword="..G_getTankUserPassWord().."&oldusername="..cuname.."&zoneid="..zoneid
                    local curlStr=serverCfg.baseUrl..serverCfg.serverBindCountUrl.."?uid="..cuid.."&username="..self.Account.."&password="..HttpRequestHelper:URLEncode(self.password).."&oldpassword="..HttpRequestHelper:URLEncode(G_getTankUserPassWord()).."&oldusername="..HttpRequestHelper:URLEncode(cuname).."&zoneid="..zoneid

                    print("请求地址是什么",curlStr)
                    local retData=G_sendHttpRequest(curlStr,"")
                    if retData=="" then
                        do
                            return
                        end
                    end
                    local ret,retTb=base:checkServerData(retData,false)  
                    if ret==true then
                             
                          print("http绑定请求成功")
                          local result=retTb.ret
                                if result==0 then
                                    G_setLocalTankUserName(self.Account)
                                    if G_loginType==2  then
                                         base.loginAccountType=1
                                    end
                                    G_setLocalTankPwd(self.password)
                                    
                            CCUserDefault:sharedUserDefault():setStringForKey("rayjoyAccountLastLoginType",1)--记录最后一次登录的账号类型
                            CCUserDefault:sharedUserDefault():setStringForKey("rayjoyAccountUname",self.Account)
                            CCUserDefault:sharedUserDefault():setStringForKey("rayjoyAccountPwd",self.password)
                            G_saveHistoryAccount({self.Account, self.password, base.serverTime})
                            CCUserDefault:sharedUserDefault():flush()
                                    

                                    G_setTankIsguest("0")
                                    playerVoApi:setIsGuest("0")
                                    --CCUserDefault:sharedUserDefault():setStringForKey(G_local_guestAccount,"")
                                    --CCUserDefault:sharedUserDefault():flush()
                                    local function bindCallBack(fn,sdata)
                                        base:checkServerData(sdata) 
                                        
                                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("congratulation")..getlocal("bindSuccess",{self.Account}),nil,5)
                                        self:close(false) 
                                    end
                                    socketHelper:bindingAccount(bindCallBack)
                                    
                                end

                    else --发生错误
                          
                          do
                             return
                          end
                    end
            ------以上调用http获取uid和token
			--socketHelper:bindingAccount(self.Account,self.password,bindingAccountCallback)
            
		end
	end
	local bindItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",bindHandler,nil,getlocal("bindText"),30)
    local bindItemMenu=CCMenu:createWithItem(bindItem)
    bindItemMenu:setPosition(ccp(self.bgLayer:getContentSize().width/4*1,80))
    bindItemMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(bindItemMenu,2)
	
	local function cancelHandler(tag,object)
        PlayEffect(audioCfg.mouseClick)
		self:close()
	end
	local cancelItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",cancelHandler,nil,getlocal("cancel"),30)
    local cancelItemMenu=CCMenu:createWithItem(cancelItem)
    cancelItemMenu:setPosition(ccp(self.bgLayer:getContentSize().width/4*3,80))
    cancelItemMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(cancelItemMenu,2)
end
--[[
function bindingAccountDialog:isChar(str)
    local len = #str;
    local left = len;
	local isChar=false
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
        if tmp>=192 then
			isChar=true
			break
        end
    end
    return isChar
end
]]

--检测邮箱格式:
--1. 首字符必须用字母，而且其它的字符只能用26个大小写字母、0~9及_.@符号
--2. 必须包含一个并且只有一个符号“@”
--3. @后必须包含至少一个至多三个符号“.”
--4. 第一个字符不得是“@”或者“.”(第一步已检查过了)
--5. 不允许出现“@.”或者.@
--6. 结尾不得是字符“@”或者“.”
function bindingAccountDialog:isRightEmail(str)
    if string.len(str or "") < 6 then return false end
    local b,e = string.find(str or "", '@')
    local bstr = ""
    local estr = ""
    if b then
        bstr = string.sub(str, 1, b-1)
        estr = string.sub(str, e+1, -1)
    else
        do return false end
    end

    -- check the string before '@'
    local p1,p2 = string.find(bstr, "[%w_]+")
    if (p1 ~= 1) or (p2 ~= string.len(bstr)) then return false end
    
    -- check the string after '@'
    if string.find(estr, "^[%.]+") then return false end
    if string.find(estr, "%.[%.]+") then return false end
    if string.find(estr, "@") then return false end
    if string.find(estr, "[%.]+$") then return false end

    local _,count = string.gsub(estr, "%.", "")
    if (count < 1 ) or (count > 3) then
        do return false end
    end
	
	--检测空格
	if string.find(str, "%s")~=nil then
		do return false end
	end
	
	--检测符号,   除 @_. 以外的符号
	local nStr=str
	while string.find(nStr, "%p")~=nil do
		local index=string.find(nStr, "%p")
		local tStr=string.sub(nStr,index,index)
		if tStr~="." and tStr~="@" and tStr~="_" then
			do return false end
		end
		nStr=string.gsub(nStr, "%p", "", 1)
	end
	
    return true
end

function bindingAccountDialog:dispose()
	self.Account=nil
	self.password=nil
	self.passwordAgain=nil
	self.inviterId=nil
    self=nil
end
