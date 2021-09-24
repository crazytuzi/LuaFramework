--require "luascript/script/componet/commonDialog"

emailDialog=commonDialog:new()

function emailDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.normalHeight=100
	self.readedAllBtn =nil
	self.writeBtn=nil
	self.deleteBtn=nil
    self.receiveAllBtn=nil
	self.unreadLabel=nil
	self.totalLabel=nil
	self.tvHeight=nil
	self.canClick=true
	self.mailClick=0
	self.noEmailLabel=nil
	
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.emailTab1=nil
    self.emailTab2=nil
    self.emailTab3=nil

    spriteController:addPlist("public/emailNewUI.plist")
    spriteController:addTexture("public/emailNewUI.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/accessoryImage.plist")
    spriteController:addPlist("public/accessoryImage2.plist")
    spriteController:addPlist("public/acThfb.plist")
    spriteController:addTexture("public/acThfb.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    return nc
end

--设置或修改每个Tab页签
function emailDialog:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1

		 local unreadNum=emailVoApi:getHasUnread(index)
		 if unreadNum>0 then
			 self:setTipsVisibleByIdx(true,index,unreadNum)
		 else
			 self:setTipsVisibleByIdx(false,index)
		 end
    end
end

--设置对话框里的tableView
function emailDialog:initTableView()
	self.panelLineBg:setVisible(false)
	self.panelTopLine:setVisible(true)

	self.tvHeight=self.bgLayer:getContentSize().height-340
	
	self.noEmailLabel=GetTTFLabel(getlocal("noEmails"),24,true)
	self.noEmailLabel:setPosition(G_VisibleSizeWidth/2,self.bgLayer:getContentSize().height-500)
	self.noEmailLabel:setColor(G_ColorGray)
	self.bgLayer:addChild(self.noEmailLabel,2)
	self.noEmailLabel:setVisible(false)
	
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,self.tvHeight+60),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    --self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(50,115))
    --self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)
end

function emailDialog:switchTag(type)
    if type==1 and self.emailTab1==nil then
        self.emailTab1=emailDialogTab1:new()
        self.layerTab1=self.emailTab1:init(self.layerNum,0,self)
        self.bgLayer:addChild(self.layerTab1)
    end
    if type==2 and self.emailTab2==nil then
        self.emailTab2=emailDialogTab2:new(self)
        self.layerTab2=self.emailTab2:init(self.layerNum,1,self)
        self.bgLayer:addChild(self.layerTab2)
    end
    if type==3 and self.emailTab3==nil then
        self.emailTab3=emailDialogTab3:new()
        self.layerTab3=self.emailTab3:init(self.layerNum,2,self)
        self.bgLayer:addChild(self.layerTab3)
    end

	if type==1 then
		if self.layerTab1 then
	        self.layerTab1:setPosition(ccp(0,0))
	        self.layerTab1:setVisible(true)
		end
		if self.layerTab2 then
	        self.layerTab2:setPosition(ccp(999333,0))
	        self.layerTab2:setVisible(false)
		end
		if self.layerTab3 then
	        self.layerTab3:setPosition(ccp(999333,0))
	        self.layerTab3:setVisible(false)
		end
	elseif type==2 then
		if self.layerTab1 then
	        self.layerTab1:setPosition(ccp(999333,0))
	        self.layerTab1:setVisible(false)
		end
		if self.layerTab2 then
	        self.layerTab2:setPosition(ccp(0,0))
	        self.layerTab2:setVisible(true)
		end
		if self.layerTab3 then
	        self.layerTab3:setPosition(ccp(999333,0))
	        self.layerTab3:setVisible(false)
		end
	elseif type==3 then
		if self.layerTab1 then
	        self.layerTab1:setPosition(ccp(999333,0))
	        self.layerTab1:setVisible(false)
		end
		if self.layerTab2 then
	        self.layerTab2:setPosition(ccp(999333,0))
	        self.layerTab2:setVisible(false)
		end
		if self.layerTab3 then
	        self.layerTab3:setPosition(ccp(0,0))
	        self.layerTab3:setVisible(true)
		end
	end
end
function emailDialog:hideEmailTabAll()
	if self.layerTab1 then
        self.layerTab1:setPosition(ccp(999333,0))
        self.layerTab1:setVisible(false)
	end
	if self.layerTab2 then
        self.layerTab2:setPosition(ccp(999333,0))
        self.layerTab2:setVisible(false)
	end
	if self.layerTab3 then
        self.layerTab3:setPosition(ccp(999333,0))
        self.layerTab3:setVisible(false)
	end
	if self.deleteBtn then
		self.deleteBtn:setEnabled(false)
	end
	if self.unreadLabel then
		self.unreadLabel:setString(getlocal("email_unread_num",{0}))
	end
	if self.totalLabel then
		self.totalLabel:setString(getlocal("email_total_num",{0}))
	end
end

function emailDialog:getDataByType(type)
	self:hideEmailTabAll()
	if type==nil then
		type=1
	end	
	local flag=emailVoApi:getFlag(type)
	local function showEmailList(fn,data)
		if base:checkServerData(data)==true then
			if self and self.bgLayer then
				self:switchTag(self.selectedTabIndex+1)
				self:refresh(self.selectedTabIndex+1)
				--self.canClick=true
			end
		end
	end
	if self.noEmailLabel then
		self.noEmailLabel:setVisible(false)
	end
	if flag==nil or flag==-1 then
		socketHelper:emailList(type,0,0,showEmailList,1,true)
		--self.canClick=false
	elseif emailVoApi:hasMore(self.selectedTabIndex+1)==false and (emailVoApi:getNotReadNumByType(self.selectedTabIndex+1)~=emailVoApi:getHasUnread(self.selectedTabIndex+1)) then
		local mineid,maxeid=emailVoApi:getMinAndMaxEid(self.selectedTabIndex+1)
		socketHelper:emailList(type,mineid,maxeid,showEmailList,nil,true)
	else
		if self and self.bgLayer then
			self:switchTag(type)
			self:doUserHandler()
		end
	end
end
	

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function emailDialog:eventHandler(handler,fn,idx,cel)
	do return end
	if fn=="numberOfCellsInTableView" then
		local hasMore=emailVoApi:hasMore(self.selectedTabIndex+1)
		local num=emailVoApi:getNumByType(self.selectedTabIndex+1)
		if hasMore then
			num=num+1
		end
		return num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(400,self.normalHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		
		local hasMore=emailVoApi:hasMore(self.selectedTabIndex+1)
		local num=emailVoApi:getNumByType(self.selectedTabIndex+1)
		local emailVoTab=emailVoApi:getEmailsByType(self.selectedTabIndex+1)
		
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
			return self:cellClick(idx)
		end
		local backSprie
		if hasMore and idx==num then
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
			backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-100, self.normalHeight-2))
			backSprie:ignoreAnchorPointForPosition(false);
			backSprie:setAnchorPoint(ccp(0.5,0));
			backSprie:setTag(idx)
			backSprie:setIsSallow(false)
			backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
			backSprie:setPosition(ccp((self.bgLayer:getContentSize().width-100)/2,0));
			cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
			cell:addChild(backSprie,1)
			
			local moreLabel=GetTTFLabel(getlocal("showMore"),24)
			moreLabel:setPosition(getCenterPoint(backSprie))
			backSprie:addChild(moreLabel,2)
			
			return cell
		end

		local emailVo=emailVoTab[idx+1]
		if emailVo.isRead==1 then
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgRead.png",capInSet,cellClick)
		else
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgNoRead.png",capInSet,cellClick)
		end
		backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-100, self.normalHeight-2))
		backSprie:ignoreAnchorPointForPosition(false);
		backSprie:setAnchorPoint(ccp(0.5,0));
		backSprie:setTag(idx)
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setPosition(ccp((self.bgLayer:getContentSize().width-100)/2,0));
		cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
		cell:addChild(backSprie,1)
		
		local emailIcon
		if emailVo.isRead==1 then
			emailIcon=CCSprite:createWithSpriteFrameName("letterIconRead.png")
		else
			emailIcon=CCSprite:createWithSpriteFrameName("letterIconNoRead.png")
		end
		emailIcon:setPosition(ccp(50,self.normalHeight/2))
		cell:addChild(emailIcon,2)
		
		local fromToLabel
    	if self.selectedTabIndex==0 or self.selectedTabIndex==1 then
        	fromToLabel=GetTTFLabel(getlocal("email_from",{emailVo.from}),20)
		elseif self.selectedTabIndex==2 then
			fromToLabel=GetTTFLabel(getlocal("email_to",{emailVo.to}),20)
		end
		fromToLabel:setAnchorPoint(ccp(0,0))
		fromToLabel:setPosition(30+emailIcon:getContentSize().width+5,65)
		cell:addChild(fromToLabel,2)
		
		local titleStr=emailVo.title
        --[[
		if self.selectedTabIndex==1 then 
			titleStr=emailVoApi:getAttackTitle(emailVo.eid)
		end
        ]]
		if titleStr and titleStr~="" then
			local titleLabel=GetTTFLabelWrap(titleStr,24,CCSizeMake(25*16,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
			titleLabel:setAnchorPoint(ccp(0,0.5))
			titleLabel:setColor(G_ColorYellow)
			cell:addChild(titleLabel,2)
			titleLabel:setPosition(30+emailIcon:getContentSize().width+5,65)
			
			fromToLabel:setPosition(30+emailIcon:getContentSize().width+5,5)
		end
		
		local timeLabel=GetTTFLabel(emailVoApi:getTimeStr(emailVo.time),20)
		timeLabel:setAnchorPoint(ccp(0,0))
		timeLabel:setPosition(backSprie:getContentSize().width-150,5)
		cell:addChild(timeLabel,2)

		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

--点击tab页签 idx:索引
function emailDialog:tabClick(idx)
	--[[
	if self.canClick~=true then
		do return end
	end
	]]
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
			--self:refresh()
			self:getDataByType(idx+1)
			--[[
			local function showEmailList(fn,data)
				if base:checkServerData(data)==true then
					self:refresh()
				end
			end
			local flag=emailVoApi:getFlag(idx+1)
			if flag==nil or flag==-1 then
				socketHelper:emailList(idx+1,0,0,showEmailList,1)
			else
				self:refresh()
			end
			]]
		else
			v:setEnabled(true)
		end
    end
end

--用户处理特殊需求,没有可以不写此方法
function emailDialog:doUserHandler()
	local strSize2Pos = 50
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2Pos =0
    end
	local function operateHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        end
        if tag ==10 then
        	local  hasUnread = emailVoApi:getHasUnread(self.selectedTabIndex+1)
        	if hasUnread and hasUnread >0 then
	        	local function callBackAllReaded(fn,data)
	        		local ret,sData = base:checkServerData(data)
	        		if ret==true then
						if (self["emailTab1"] and self["emailTab1"].refresh) then
							if self["emailTab1"].tv then
								emailVoApi:setAllReaded(1)
								local recordPoint = self["emailTab1"].tv:getRecordPoint()
								self["emailTab1"]:refresh()
								recordPoint.y=recordPoint.y
								self["emailTab1"].tv:recoverToRecordPoint(recordPoint)
							end
						end
						if (self["emailTab2"] and self["emailTab2"].refresh) then
							if self["emailTab2"].tv then
								emailVoApi:setAllReaded(2)
								local recordPoint = self["emailTab2"].tv:getRecordPoint()
								self["emailTab2"]:refresh()
								recordPoint.y=recordPoint.y
								self["emailTab2"].tv:recoverToRecordPoint(recordPoint)
							end
						end

                        -- 强制设为已读并重置红点提示
                        emailVoApi:setHasUnread(1, 0)
                        emailVoApi:setHasUnread(2, 0)
                        local index = 0
                        for k, v in pairs(self.allTabs) do
                             index = index + 1

                             local unreadNum = emailVoApi:getHasUnread(index)
                             if unreadNum > 0 then
                                 self:setTipsVisibleByIdx(true, index, unreadNum)
                             else
                                 self:setTipsVisibleByIdx(false, index)
                             end
                        end
	        		end
	        	end 
	        	socketHelper:readedAllEmail(self.selectedTabIndex+1, callBackAllReaded)
	        end
		elseif tag==11 then
			local layerNum=4
			emailVoApi:showWriteEmailDialog(layerNum,getlocal("email_write"))
		elseif tag==12 then
			local function callBack1()
				local function deleteEmailCallback(fn,data)
					local ret,sData = base:checkServerData(data)
                    if ret == true then
						emailVoApi:deleteByType(self.selectedTabIndex+1)

                        if self.selectedTabIndex <= 1 then
                            local emails=sData.data.mail
                            emailVoApi:formatData(emails)
                        end

						self:refresh(self.selectedTabIndex+1)
						local callBackStr
						if self.selectedTabIndex==0 then 
							callBackStr=getlocal("clear_email_normal")
						elseif self.selectedTabIndex==1 then
							callBackStr=getlocal("clear_email_fight")
						elseif self.selectedTabIndex==2 then
							callBackStr=getlocal("clear_email_send")
						end
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBackStr,28)
					end
				end
				socketHelper:deleteEmail(self.selectedTabIndex+1,nil,deleteEmailCallback)
			end
            local deleteTitleStr = getlocal("dialog_title_prompt")
			local deleteStr=""
			if self.selectedTabIndex==0 then 
                deleteStr=getlocal("email_clear_confirm")
			elseif self.selectedTabIndex==1 then
				deleteStr=getlocal("email_clear_report_confirm")
			elseif self.selectedTabIndex==2 then
				deleteStr=getlocal("send_clear_confirm")
			end
            if self.selectedTabIndex==0 then
                smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550,400),CCRect(0, 0, 400, 350),
                    CCRect(168, 86, 10, 10),callBack1,deleteTitleStr,deleteStr,nil,4,nil,kCCTextAlignmentCenter,nil,nil,nil,nil,nil,nil,getlocal("email_clear_confirm2"))
            else
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack1,deleteTitleStr,deleteStr,nil,4)
            end
        elseif tag==13 then
            local function touchReceiveAllMethod()
                socketHelper:allrewardEmail(function (fn,data)
                    local ret,sData = base:checkServerData(data)
                    if ret == true then
                        -- 整理奖励
                        local addType = "tAllPoint"    -- 积分的总类型
                        local addKey = "pww"    -- 世界争霸积分
                        local awardTb={}
                        local rewardAll = sData.data.reward
                        if rewardAll then
                            for sk, sv in pairs(rewardAll) do
                                if tonumber(sk) == 3 then
                                    for i,v in ipairs(sv) do
                                        -- 世界争霸积分获得
                                        local addNum = tonumber(v)
                                        local name,pic,desc,id,index,eType,equipId,bgname = getItem(addKey,addType,addNum)
                                        local item = {name=name,pic=pic,desc=desc,id=id,index=index,eType=eType,equipId=equipId,bgname=bgname,
                                            type=addType,key=addKey,num=addNum}
                                        table.insert(awardTb,item)
                                    end
                                else
                                    -- 其它
                                    local function formatRewardData(reType, rv)
                                    	for m,n in pairs(rv) do
                                            local item={}
                                            if n and type(n)=="table" then
                                                for i,j in pairs(n) do
                                                    if i=="index" then
                                                    else
                                                        local name,pic,desc,id,index,eType,equipId,bgname=getItem(i,reType)
                                                        item={name=name,num=j,pic=pic,desc=desc,id=id,type=reType,index=index,key=i,eType=eType,equipId=equipId,bgname=bgname}
                                                        table.insert(awardTb,item)
                                                    end
                                                end
                                            else
                                                local name,pic,desc,id,index,eType,equipId,bgname=getItem(m,reType)
                                                item={name=name,num=n,pic=pic,desc=desc,id=id,type=reType,index=index,key=m,eType=eType,equipId=equipId,bgname=bgname}
                                                table.insert(awardTb,item)
                                            end
                                        end
                                    end
                                    for ik,iv in pairs(sv) do
                                        for k,v in pairs(iv) do
                                            local reType=k
                                            if type(reType) == "number" then
                                            	for kk, vv in pairs(v) do
                                            		reType = kk
                                            		formatRewardData(reType, vv)
                                            	end
                                            else
                                            	formatRewardData(reType, v)
                                            end
                                        end
                                    end
                                end
                            end

                            if awardTb and SizeOfTable(awardTb)>0 then
                                for k,v in pairs(awardTb) do
                                    if v.type and v.type == addType then
                                        if v.key and v.key == addKey then
                                            worldWarVoApi:setPoint(worldWarVoApi:getPoint() + v.num)
                                        end
                                    elseif v.type and v.type ~= addType and v.num and tonumber(v.num) and tonumber(v.num)>0 then
                                        G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num), nil, true,false)
                                    end
                                end
                                G_showRewardTip(awardTb, true)
                            end

                            emailVoApi:setIsRewardAll(1)
                            emailVoApi:setReadedAllFlag(1, 0)
                            emailVoApi:setCanDeleteStateByType(1, 1)
                        end

                        -- 刷新列表
                        self:refresh(self.selectedTabIndex+1)
                    end
                end)
            end
            touchReceiveAllMethod()
		end
        PlayEffect(audioCfg.mouseClick)
	end
	
	local posX=340
	local posY=70
    if self==nil or self.bgLayer==nil then
        do return end
    end

    if self.readedAllBtn ==nil then
    	self.readedAllBtn=GetButtonItem("yh_readedAll.png","yh_readedAll_Down.png","yh_readedAll_Down.png",operateHandler,10,nil,nil)
        local readedAllBtnMenu=CCMenu:createWithItem(self.readedAllBtn)
        readedAllBtnMenu:setAnchorPoint(ccp(0,0))
        readedAllBtnMenu:setPosition(ccp(posX-self.readedAllBtn:getContentSize().width-80,posY))
        readedAllBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(readedAllBtnMenu)
    end

	if self.writeBtn==nil then
		self.writeBtn=GetButtonItem("yh_letterBtnWrite.png","yh_letterBtnWrite_Down.png","yh_letterBtnWrite_Down.png",operateHandler,11,nil,nil)
		local writeSpriteMenu=CCMenu:createWithItem(self.writeBtn)
		writeSpriteMenu:setAnchorPoint(ccp(0,0))
		writeSpriteMenu:setPosition(ccp(posX+self.writeBtn:getContentSize().width+40,posY))
		writeSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
		self.bgLayer:addChild(writeSpriteMenu,2)
	end	
	
    if self.deleteBtn==nil then
        self.deleteBtn=GetButtonItem("yh_letterBtnDelete.png","yh_letterBtnDelete_Down.png","yh_letterBtnDelete_Down.png",operateHandler,12,nil,nil)
        local deleteSpriteMenu=CCMenu:createWithItem(self.deleteBtn)
        deleteSpriteMenu:setAnchorPoint(ccp(0,0))
        deleteSpriteMenu:setPosition(ccp(posX-20,posY))
        deleteSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(deleteSpriteMenu,2)
    end

    if self.receiveAllBtn==nil then
		self.receiveAllBtn=GetButtonItem("yh_BtnReceiveAllRew.png","yh_BtnReceiveAllRew_Down.png","yh_BtnReceiveAllRew_Down.png",operateHandler,13,nil,nil)
		local receiveAllSpriteMenu=CCMenu:createWithItem(self.receiveAllBtn)
		receiveAllSpriteMenu:setAnchorPoint(ccp(0,0))
		receiveAllSpriteMenu:setPosition(ccp(posX-20,posY))
		receiveAllSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
		self.bgLayer:addChild(receiveAllSpriteMenu,2)
	end

	if self.noEmailLabel then
		self.noEmailLabel:setVisible(false)
	end
	local emailNum=emailVoApi:getNumByType(self.selectedTabIndex+1)
    if self.selectedTabIndex > 1 then
        -- 其它
        if emailNum>0 then
            self.deleteBtn:setEnabled(true)
        else
            self.deleteBtn:setEnabled(false)
            if self.noEmailLabel then
                self.noEmailLabel:setVisible(true)
            end
        end
    else
        -- 邮件和报告单独处理
        local emailDeleteState = emailVoApi:getCanDeleteStateByType(self.selectedTabIndex+1)
        if emailDeleteState > 0 then
            self.deleteBtn:setEnabled(true)
        else
            self.deleteBtn:setEnabled(false)
        end
        if self.noEmailLabel and emailNum <= 0 then
            self.noEmailLabel:setVisible(true)
        end
    end

	local groupSelf = CCSprite:createWithSpriteFrameName("groupSelf.png")
    groupSelf:setScaleY(40/groupSelf:getContentSize().height)
    groupSelf:setScaleX(5)
    groupSelf:setPosition(ccp(G_VisibleSizeWidth*0.5+20,posY+40))
    groupSelf:ignoreAnchorPointForPosition(false)
    groupSelf:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(groupSelf)

    -- 是否显示一键领取
    self.receiveAllBtn:setVisible((self.selectedTabIndex == 0))
    self.receiveAllBtn:setEnabled(emailVoApi:getReadedAllFlag(1) == 1)
    if self.selectedTabIndex == 0 then
        -- 有 按钮宽度120 间隔 40
        self.readedAllBtn:setPositionX(-40)
        self.deleteBtn:setPositionX(-73)
        self.receiveAllBtn:setPositionX(73)
        self.writeBtn:setPositionX(40)
    else
        -- 没有
        self.readedAllBtn:setPositionX(0)
        self.deleteBtn:setPositionX(0)
        self.receiveAllBtn:setPositionX(0)
        self.writeBtn:setPositionX(0)
    end

	if self.selectedTabIndex~=2 then
		--local unreadNum=emailVoApi:getNotReadNumByType(self.selectedTabIndex+1)
		local unreadNum=emailVoApi:getHasUnread(self.selectedTabIndex+1)
		if unreadNum>0 then
			self:setTipsVisibleByIdx(true,self.selectedTabIndex+1,unreadNum)
			self.readedAllBtn:setEnabled(true)
		else
			self:setTipsVisibleByIdx(false,self.selectedTabIndex+1)
			self.readedAllBtn:setEnabled(false)
		end
		
		if self.unreadLabel==nil then
			self.unreadLabel=GetTTFLabel(getlocal("email_unread_num",{unreadNum}),22)
			self.unreadLabel:setPosition(posX-90-strSize2Pos,posY+60)
			self.unreadLabel:setColor(G_ColorYellowPro)
			self.bgLayer:addChild(self.unreadLabel,2)
		else
			self.unreadLabel:setString(getlocal("email_unread_num",{unreadNum}))
		end
		self.unreadLabel:setVisible(true)
	else
		if self.unreadLabel then 
			self.unreadLabel:setVisible(false) 
			self.readedAllBtn:setEnabled(false)
		end
	end
	
	
	if self.totalLabel==nil then
		self.totalLabel=GetTTFLabel(getlocal("email_total_num",{emailVoApi:getTotalNumByType(self.selectedTabIndex+1)}),22)
		self.totalLabel:setPosition(posX+45+strSize2Pos,posY+60)
		self.bgLayer:addChild(self.totalLabel,2)
	else
		self.totalLabel:setString(getlocal("email_total_num",{emailVoApi:getTotalNumByType(self.selectedTabIndex+1)}))
	end
	if self.selectedTabIndex ==2 then
		self.totalLabel:setPosition(ccp(G_VisibleSizeWidth*0.5,posY+60))
	else
		self.totalLabel:setPosition(posX+45,posY+60)
	end
end

function emailDialog:tick()
	if self.emailTab1 then
		self.emailTab1:tick()
	end
	if self.emailTab2 then
		self.emailTab2:tick()
	end
	if self.emailTab3 then
		self.emailTab3:tick()
	end
end

function emailDialog:refresh(type)
	if self~=nil then
		if type==1 and self.emailTab1 then
			self.emailTab1:refresh()
		elseif type==2 and self.emailTab2 then
			self.emailTab2:refresh()
		elseif type==3 and self.emailTab3 then
			self.emailTab3:refresh()
		else
			self:doUserHandler()
		end
	end
end

function emailDialog:dispose()
    if self.emailTab1~=nil then
        self.emailTab1:dispose()
    end
    if self.emailTab2~=nil then
        self.emailTab2:dispose()
    end
    if self.emailTab3~=nil then
        self.emailTab3:dispose()
    end
	
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.emailTab1=nil
    self.emailTab2=nil
    self.emailTab3=nil
	
	self.mailClick=nil
	self.canClick=nil
	self.normalHeight=nil
	self.readedAllBtn =nil
	self.writeBtn=nil
    self.deleteBtn=nil
	self.receiveAllBtn=nil
	self.unreadLabel=nil
	self.totalLabel=nil
	self.tvHeight=nil
	self.noEmailLabel=nil
	
    self=nil

    spriteController:removePlist("public/emailNewUI.plist")
    spriteController:removeTexture("public/emailNewUI.png")
    spriteController:removePlist("public/acThfb.plist")
    spriteController:removeTexture("public/acThfb.png")
end






