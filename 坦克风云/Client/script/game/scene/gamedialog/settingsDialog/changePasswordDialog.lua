--require "luascript/script/componet/commonDialog"
changePasswordDialog=commonDialog:new()

function changePasswordDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.currentPw=nil
	self.newPw=nil
	self.repeatNewPw=nil
    return nc
end


--设置对话框里的tableView
function changePasswordDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85),nil)
    self.bgLayer:setTouchPriority(-61)
	self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-230))
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2+20))
	
    local accountLabel=GetTTFLabel(getlocal("mailAccount",{G_getTankUserName()}),30)
	accountLabel:setAnchorPoint(ccp(0,0))
    accountLabel:setPosition(ccp(25,self.panelLineBg:getContentSize().height-90))
    self.panelLineBg:addChild(accountLabel,2)
	
	local serverData=CCUserDefault:sharedUserDefault():getStringForKey(tostring(G_local_lastLoginSvr))
	local serverName=Split(serverData,",")[2]
	local serverLabel
	if serverName==nil then
		serverName=""
	end
	serverLabel=GetTTFLabel(getlocal("server",{serverName}),30)
	serverLabel:setAnchorPoint(ccp(0,0))
    serverLabel:setPosition(ccp(25,self.panelLineBg:getContentSize().height-130))
    self.panelLineBg:addChild(serverLabel,2)
	
	local passwordMiniLength=6
	local labelTab={"cpCurrentPassword","cpNewPassword","cpNewPasswordR"}
	for i=1,SizeOfTable(labelTab) do
	    local changePwLabel=GetTTFLabel(getlocal(labelTab[i]),30)
		changePwLabel:setAnchorPoint(ccp(0,0))
	    changePwLabel:setPosition(ccp(25,self.panelLineBg:getContentSize().height-150*i-60))
	    self.panelLineBg:addChild(changePwLabel,2)
		
	    local function callBackPasswordHandler(fn,eB,str)
			if str==nil then
				str=""
			end
			if i==1 then
				self.currentPw=str
			elseif i==2 then
				self.newPw=str
			elseif i==3 then
				self.repeatNewPw=str
			end
	    end
	    local function cellClick(hd,fn,idx)
	    end

	    local passwordBox=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10,10,5,5),cellClick)
		passwordBox:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width-50,70))
	    passwordBox:setIsSallow(false)
	    passwordBox:setTouchPriority(-64)
	    passwordBox:setAnchorPoint(ccp(0.5,0))
		passwordBox:setPosition(ccp(self.panelLineBg:getContentSize().width/2,self.panelLineBg:getContentSize().height-150*i-130))
		
	    local passwordLabel=GetTTFLabel("",30)
		passwordLabel:setAnchorPoint(ccp(0,0.5))
	    passwordLabel:setPosition(ccp(10,passwordBox:getContentSize().height/2))

		local customEditBox=customEditBox:new()
		local length=12
    	if(G_curPlatName()=="0")then
    	  length=100
	    end
		local inputMode=CCEditBox.kEditBoxInputModeUrl
		local inputFlag=CCEditBox.kEditBoxInputFlagPassword
		customEditBox:init(passwordBox,passwordLabel,"mail_input_bg.png",nil,-64,length,callBackPasswordHandler,inputFlag,inputMode)
	    self.panelLineBg:addChild(passwordBox)
		
	    local tipLabel=GetTTFLabel(getlocal("limitLength",{length}),20)
		tipLabel:setAnchorPoint(ccp(0,1))
	    tipLabel:setPosition(ccp(25,self.panelLineBg:getContentSize().height-150*i-135))
	    self.panelLineBg:addChild(tipLabel,2)
		tipLabel:setColor(G_ColorRed)
	end
	
	local function clickHandler(tag,object)
        PlayEffect(audioCfg.mouseClick)
		local tipStr=nil
		if self.currentPw==nil or string.len(self.currentPw)==0 then
			tipStr=getlocal("wrongPasswordLength")
		elseif self.newPw==nil or string.find(self.newPw,"%s")~=nil then
			tipStr=getlocal("passwordWrong")
		elseif string.len(self.newPw)<passwordMiniLength then
			tipStr=getlocal("cpWrongNewPasswordLength")
		elseif self.currentPw==self.newPw then
			tipStr=getlocal("cpAsSameAs")
		elseif self.repeatNewPw==nil or self.repeatNewPw~=self.newPw then
			tipStr=getlocal("wrongPasswordCf")
		end
		if tipStr then
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),tipStr,nil,5)
		else
            --[[
    		local function changePasswordCallback(fn,data)
                local success,retTb=base:checkServerData(data,false)
    			if success==true then
    				local result=retTb.ret
    				if result==0 then
    					smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("changePasswordSuccess"),nil,5)
    					--G_setTankUserPassWord(self.newPw)
                        G_changeTankUserPassWord(self.newPw)
    					self:close(false)
    				--elseif result==-104 then--"旧密码错误."
    					--smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("oldpasswordiswrong"),nil,5)
    				end
    			end
    		end
            ]]
            ------以下调用http修改密码-----
            local cuname=G_getTankUserName()
            local cuid=playerVoApi:getUid()
            local zoneID
            if(base.curOldZoneID and tonumber(base.curOldZoneID)>0)then
            	zoneID=base.curOldZoneID
            else
            	zoneID=base.curZoneID
            end
            -- local curlStr = serverCfg.baseUrl .. serverCfg.serverUpdatePwdUrl .. "?uid=" ..cuid.."&username="..cuname.."&newpassword="..self.newPw.."&oldpassword="..self.currentPw.."&zoneid="..zoneID
            local encodeCuname = cuname
            local encodeNewPw = HttpRequestHelper:URLEncode(self.newPw)
            local encodeCurrentPw = HttpRequestHelper:URLEncode(self.currentPw)
            local curlStr = serverCfg.baseUrl .. serverCfg.serverUpdatePwdUrl .. "?uid=" ..cuid.."&username="..encodeCuname.."&newpassword="..encodeNewPw.."&oldpassword="..encodeCurrentPw.."&zoneid="..zoneID
            local retData=G_sendHttpRequest(curlStr,"")
            if retData=="" then
                do
                    return
                end
            end
            local ret,retTb=base:checkServerData(retData,false)  
            if ret==true then
                     
                print("http修改密码请求成功")
                local result=retTb.ret
                if result==0 then
                    smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("changePasswordSuccess"),nil,5)
                    G_changeTankUserPassWord(self.newPw)


                    CCUserDefault:sharedUserDefault():setStringForKey("rayjoyAccountPwd",self.newPw)
                    G_saveHistoryAccount({cuname, self.newPw, base.serverTime})
                    CCUserDefault:sharedUserDefault():flush()
                    self:close(false)
                end

            else --发生错误
                  
                do
                    return
                end
            end
            ------以上调用http修改密码-----

			--socketHelper:changePassword(self.currentPw,self.newPw,changePasswordCallback)
		end
	end
	local buttonItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",clickHandler,nil,getlocal("changePasswordTTF"),30)
    local buttonMenu=CCMenu:createWithItem(buttonItem);
    buttonMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,80))
    buttonMenu:setTouchPriority(-64)
    self.bgLayer:addChild(buttonMenu,2)
end

function changePasswordDialog:dispose()
	self.currentPw=nil
	self.newPw=nil
	self.repeatNewPw=nil
    self=nil
end
