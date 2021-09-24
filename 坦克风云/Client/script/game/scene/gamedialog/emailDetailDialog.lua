--require "luascript/script/componet/commonDialog"

emailDetailDialog=commonDialog:new()

function emailDetailDialog:new(layerNum,type,eid,replyTarget,replyTheme,chatSender,chatReport,isAllianceEmail,headlinesData,receiverUid)
    local nc={
		layerNum=layerNum,
		eid=eid,
	    emailType=type,
		target=replyTarget,
		theme=replyTheme,
		chatSender=chatSender,
		chatReport=chatReport,
		isAllianceEmail=isAllianceEmail,
		emailReceiverUId = tonumber(receiverUid),--邮件接收者Uid,用于给某人发邮件使用（之前只有接受者名字，改名后没法发送）
		headlinesData=headlinesData, 	--头条信息
		replayBtn=nil,
		attackBtn=nil,
		writeBtn=nil,
		deleteBtn=nil,
		sendBtn=nil,
		feedBtn=nil,
		--textField=nil,
		--cursorSprite=nil,
		sendSuccess=false,
		canSand=true,
		txtSize=24,
		themeBoxLabel=nil,
	    cellHight=nil,
	    awardHeight=nil,
	    output=nil, --矿点资源
	    cellHeightTb={},
	}
    setmetatable(nc,self)
    self.__index=self

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    local JidongbuduiVo = activityVoApi:getActivityVo("jidongbudui")
	if JidongbuduiVo  then
        if G_curPlatName()=="21" or G_curPlatName()=="androidarab" then
          CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/arabTurkeyImage.plist")
        end
        
        if G_curPlatName()=="13" or G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("koImage/koAcIconImage.plist")

        end

        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acJidongbudui.plist")
    end
    spriteController:addPlist("public/allianceWar2/allianceWar2.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/iconLevel.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/dailyNews.plist")
    spriteController:addTexture("public/dailyNews.png")
    spriteController:addPlist("public/accessoryImage.plist")
    spriteController:addPlist("public/accessoryImage2.plist")
    spriteController:addPlist("public/acThfb.plist")
    spriteController:addTexture("public/acThfb.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    return nc
end
--[[
playerisnotexist="目标玩家不存在,请重新输入收件人姓名。",
read_email_report_share_sucess="已成功发送战报到聊天频道",
]]

function emailDetailDialog:showReportDetailDialog(report)
	if self.panelLineBg then
		self.panelLineBg:setVisible(false)
	end
	if self.panelTopLine then
		self.panelTopLine:setVisible(true)
    	self.panelTopLine:setPositionY(G_VisibleSizeHeight-82)
	end
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.reportDialog,self.reportLayer=nil,nil
    if report.type==1 then --战斗报告
		local battleReportDialog=G_requireLua("game/scene/gamedialog/battleReportDialog")
		self.reportDialog=battleReportDialog:new(report,self.chatSender)
		self.reportLayer=self.reportDialog:initReportLayer(self.layerNum)
    elseif report.type==2 or report.type==5 or report.type==6 then --2.侦查报告/5.搜索雷达报告/6.间谍卫星报告
		local scoutReportDialog=G_requireLua("game/scene/gamedialog/scoutReportDialog")
		self.reportDialog=scoutReportDialog:new(report,self.chatSender)
		self.reportLayer=self.reportDialog:initReportLayer(self.layerNum)
	elseif report.type==3 or report.type==4 or report.type==7 or report.type==8 or report.type==9 or report.type==10 then --3.返回战报/4.采集报告/7.进攻军团城市返回/8.驻防军团城市返回报告/9.进攻方击飞奖励报告/10.被击飞玩家击飞报告
		-- self:showReturnReportDetail() --显示返回战报详情
		local returnReportDialog=G_requireLua("game/scene/gamedialog/returnReportDialog")
		self.reportDialog=returnReportDialog:new(report)
		self.reportLayer=self.reportDialog:initReportLayer(self.layerNum)
	end
	if self.reportLayer then
		self.bgLayer:addChild(self.reportLayer)
	end
end


--设置对话框里的tableView
function emailDetailDialog:initTableView()
	local emailVo=nil
	if self.eid and self.emailType then
		emailVo=emailVoApi:getEmailByEid(self.emailType,self.eid)
	end
	local report
	if self.chatReport then
		report=self.chatReport
	elseif emailVo then
		report=emailVoApi:getReport(emailVo.eid)
	end

	local hd
	if report and self.emailType==2 then
		local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
	    panelBg:setAnchorPoint(ccp(0.5,0))
	    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
	    panelBg:setPosition(G_VisibleSizeWidth/2,5)
	    self.bgLayer:addChild(panelBg)
	    
		self:showReportDetailDialog(report)
	else
	    local function callBack(...)
	       return self:eventHandler(...)
	    end
	    hd= LuaEventHandler:createHandler(callBack)
	    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)

		self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-36))
		self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-98))
		
		self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-180),nil)
	    self.tv:setPosition(ccp(25,90))
		--self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-230),nil)
	    --self.tv:setPosition(ccp(25,140))
		self.tv:setAnchorPoint(ccp(0,0))
		self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	end

	
	
	-- print("self.emailType,report.type------>>>>???",self.emailType,report.type)
	if report and self.emailType==2 then
		if report.type==3 then
			--[[local returnStr=""
			local allianceName=""
			if report.allianceName and report.allianceName~="" then
				allianceName=getlocal("report_content_alliance",{report.allianceName})
			end
			if report.returnType==1 then
				if report.islandType and report.islandType==8 then
					returnStr=getlocal("return_content_protected_tip2",{report.name,report.place.x,report.place.y})
				else
					returnStr=getlocal("return_content_protected_tip",{report.name..allianceName,report.place.x,report.place.y})
				end
			elseif report.returnType==2 then
				if report.islandType and report.islandType==8 then
					returnStr=getlocal("return_content_moved_tip2",{report.place.x,report.place.y})
				else
					returnStr=getlocal("return_content_moved_tip",{report.place.x,report.place.y})
				end
			elseif report.returnType==3 then
				returnStr=getlocal("return_content_tip",{G_getIslandName(report.islandType),report.level,report.place.x,report.place.y})
			elseif report.returnType==4 then
				returnStr=getlocal("return_content_tip_1",{G_getIslandName(report.islandType),report.level,report.place.x,report.place.y})
            elseif report.returnType==5 then
                returnStr=getlocal("return_content_tip_2",{report.name..allianceName,report.place.x,report.place.y})
            elseif report.returnType==6 then
                returnStr=getlocal("return_content_tip_3")
            elseif report.returnType==7 then
                returnStr=getlocal("return_content_tip_4")
            elseif report.returnType==8 then
                returnStr=getlocal("return_content_tip_5")
            elseif report.returnType==9 then
            	local rebel=report.rebel or {}
            	local rebelLv,rebelID=rebel.rebelLv or 1,rebel.rebelID or 1
            	local target=G_getIslandName(report.islandType,nil,rebelLv,rebelID,nil,rebel.rpic)
                returnStr=getlocal("return_content_tip_9",{target,report.place.x,report.place.y})
			end
			local msgLabel=GetTTFLabelWrap(returnStr,24,CCSizeMake(self.bgLayer:getContentSize().width-50, 30*10),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			msgLabel:setAnchorPoint(ccp(0,1))
			msgLabel:setPosition(ccp(25,self.bgLayer:getContentSize().height-110))
			self.bgLayer:addChild(msgLabel,2)]]
			self.target=report.name
		else
			--[[local isAttacker=emailVoApi:isAttacker(report,self.chatSender)
			if ((isAttacker and report.isVictory==1 and report.islandType==6) or (isAttacker==false and report.isVictory~=1)) and self.chatSender==nil then
				if G_isShowShareBtn() then
					self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-230),nil)
				    self.tv:setPosition(ccp(25,140))
					self.tv:setAnchorPoint(ccp(0,0))
					self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
				end
			end
		    self.bgLayer:addChild(self.tv,2)
		    self.tv:setMaxDisToBottomOrTop(120)]]
			
			if report.type==2 then
				self.target=report.defender.name
			elseif report.type==1 then
				selfId=playerVoApi:getUid()
				if selfId==report.defender.id then
					self.target=report.attacker.name
					self.emailReceiverUId=report.attacker.id
				elseif selfId==report.attacker.id then
					if report.islandType==6 or report.islandType==8 then
						self.target=report.defender.name
						self.emailReceiverUId=report.defender.id
					elseif report.islandType<6 then
						if report.islandOwner>0 then
							self.target=report.defender.name
							self.emailReceiverUId=report.defender.id
						end
					end
				end
			end
		end
	else
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function touch1(hd,fn,idx)

		end
		local headSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch1)
	    headSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 120))
	    headSprie:ignoreAnchorPointForPosition(false)
	    headSprie:setAnchorPoint(ccp(0,0))
	    headSprie:setIsSallow(false)
	    headSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		headSprie:setPosition(ccp(20, self.bgLayer:getContentSize().height-215))
	    self.bgLayer:addChild(headSprie,1)
		
		local function touch2(hd,fn,idx)
			--if self.tv:getIsScrolled()==false and self.textField then
			--if self.tv:getIsScrolled()==false then
				PlayEffect(audioCfg.mouseClick)
				--self.textField:attachWithIME()
				if self.eid and (self.emailType==1 or self.emailType==3) then
				else
				if self.editBox then
			        self.editBox:setVisible(true)
					self.editBox:setText(textValue)
				end
				end
				--[[
				if ifNotShowBoxBg then
					textLabel:setVisible(false)
				end
				]]
			--end
		end
		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,touch2)
	    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, self.bgLayer:getContentSize().height-285))
	    backSprie:ignoreAnchorPointForPosition(false)
	    backSprie:setAnchorPoint(ccp(0,0))
	    backSprie:setIsSallow(false)
	    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		backSprie:setPosition(ccp(20, 75))
	    self.bgLayer:addChild(backSprie,1)
		
		if self.eid==nil then
			--输入框--------------------------------
			local textLabel=GetTTFLabelWrap("",24,CCSizeMake(backSprie:getContentSize().width-20,backSprie:getContentSize().height-20),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			textLabel:setAnchorPoint(ccp(0,1))
			textLabel:setPosition(ccp(10,backSprie:getContentSize().height-10))
			backSprie:addChild(textLabel,2)

			self.textValue=textLabel:getString()
			if self.textValue==nil then
				self.textValue=""
			end
			local function tthandler()
		
		    end
		    local function callBackHandler(fn,eB,str,type)
				--if type==0 then  --开始输入
					--eB:setText(textValue)
				if type==1 then  --检测文本内容变化
					if str==nil then
						self.textValue=""
					else
						self.textValue=str
						if changeCallback then
							local txt=changeCallback(fn,eB,str,type)
							if txt then
								self.textValue=txt
								eB:setText(self.textValue)
							end
						end
					end
		            textLabel:setString(self.textValue)
				elseif type==2 then --检测文本输入结束
					eB:setVisible(false)
					--屏蔽字
					self.textValue=keyWordCfg:keyWordsReplace(self.textValue)
					textLabel:setString(self.textValue)
					eB:setText(self.textValue)
				end
		    end
			
		    local winSize=CCEGLView:sharedOpenGLView():getFrameSize()
		    local xScale=winSize.width/640
		    local yScale=winSize.height/960
			local size=CCSizeMake(backSprie:getContentSize().width,50)
			local xBox=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler)
		    self.editBox=CCEditBox:createForLua(size,xBox,nil,nil,callBackHandler)
			self.editBox:setFont(textLabel.getFontName(textLabel),yScale*textLabel.getFontSize(textLabel)/2)
			self.editBox:setMaxLength(300)
			self.editBox:setText(self.textValue)
			self.editBox:setAnchorPoint(ccp(0,0))
			self.editBox:setPosition(ccp(0,220))

			self.editBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsSentence)
			self.editBox:setInputMode(CCEditBox.kEditBoxInputModeSingleLine)

		    self.editBox:setVisible(false)
		    backSprie:addChild(self.editBox,3)


			----------------------------------

			if self.headlinesData and SizeOfTable(self.headlinesData)>0 then
				self.editBox:setMaxLength(100)
				self:addHeadlines(backSprie,backSprie:getContentSize().height-250,backSprie:getContentSize().height-240,self.headlinesData)
			end
		elseif emailVo and emailVo.headlinesData and SizeOfTable(emailVo.headlinesData)>0 then
			if (emailVo.sender==1 or emailVo.sender==0) then
				self:addHeadlines(backSprie,backSprie:getContentSize().height-20,backSprie:getContentSize().height-10,emailVo.headlinesData)
			else
				self:addHeadlines(backSprie,backSprie:getContentSize().height-250,backSprie:getContentSize().height-240,emailVo.headlinesData)
			end
		end
		

        local function showMailList()
			require "luascript/script/game/scene/gamedialog/chatDialog/mailListDialog"
            local vrd=mailListDialog:new()
            local vd = vrd:init(2,self,self.layerNum+1)
		end
		local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",showMailList,nil,"",25)
		local okBtn=CCMenu:createWithItem(okItem)
		okBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		okBtn:setPosition(ccp(60,85))
		headSprie:addChild(okBtn)
		okItem:setScale(0.6)
        
        local targetLabel=GetTTFLabelWrap(getlocal("email_receiver"),24,CCSizeMake(110,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		if emailVo and self.emailType==1 then
			targetLabel=GetTTFLabelWrap(getlocal("email_sender"),24,CCSizeMake(110,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		end
		targetLabel:setPosition(getCenterPoint(okItem))
		okItem:addChild(targetLabel,2)
        if self.isAllianceEmail==true then
        	okItem:setVisible(false)
        	okItem:setEnabled(false)
        	local targetLabel2=GetTTFLabelWrap(getlocal("email_receiver"),24,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        	targetLabel2:setPosition(ccp(60,85))
        	headSprie:addChild(targetLabel2,2)
        end
		
		local themeLabel=GetTTFLabel(getlocal("email_theme"),24)
		themeLabel:setPosition(60,35)
		headSprie:addChild(themeLabel,2)
		
	    local function tthandler()
	    end
		if self.eid==nil then
		    local function callBackTargetHandler(fn,eB,str)
				if str==nil then
					self.target=""
					do return end
				end
			 	self.target=str
		    end
		    local editTargetBox=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10,10,5,5),tthandler)
			if self.isAllianceEmail==true then
				editTargetBox:setContentSize(CCSizeMake(headSprie:getContentSize().width/4*3-80,50))
		    	editTargetBox:setPosition(ccp(headSprie:getContentSize().width/2+40-40,85))
		    	local num=allianceVoApi:getSendEmailNum() or 0
		    	local maxNum=allianceVoApi:getSendEmailMaxNum() or 0
		    	local aEmailNumLb=GetTTFLabel(num.."/"..maxNum,24)
		    	aEmailNumLb:setAnchorPoint(ccp(0,0.5))
		    	aEmailNumLb:setPosition(ccp(110+editTargetBox:getContentSize().width+20,85))
		    	headSprie:addChild(aEmailNumLb,2)
		    	aEmailNumLb:setColor(G_ColorYellowPro)
		    else
		    	editTargetBox:setContentSize(CCSizeMake(headSprie:getContentSize().width/4*3,50))
		    	editTargetBox:setPosition(ccp(headSprie:getContentSize().width/2+40,85))
		    end
		    editTargetBox:setIsSallow(false)
		    editTargetBox:setTouchPriority(-(self.layerNum-1)*20-4)
		    self.targetBoxLabel=GetTTFLabel("",24)
			self.targetBoxLabel:setAnchorPoint(ccp(0,0.5))
		    self.targetBoxLabel:setPosition(ccp(10,editTargetBox:getContentSize().height/2))
			if self.target then
				self.targetBoxLabel:setString(self.target)
                for k,v in pairs(GM_Name) do
                    if v == self.target then
                        self.targetBoxLabel:setColor(G_ColorYellowPro)
                        do break end
                    end
                end
			end
			local customEditBox=customEditBox:new()
			local length=12
			local function clickCanWriteTarget()
				if self.isAllianceEmail then
					return true	--军团邮件收件人不能编辑
				end
				return false
			end
			customEditBox:init(editTargetBox,self.targetBoxLabel,"mail_input_bg.png",nil,-(self.layerNum-1)*20-4,length,callBackTargetHandler,nil,nil,nil,clickCanWriteTarget)
		    headSprie:addChild(editTargetBox,2)
			
			
		    local function callBackThemeHandler(fn,eB,str)
				if str==nil then
					self.theme=""
					do return end
				end
			 	self.theme=str
		    end
		    local editThemeBox=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10,10,5,5),tthandler)
			editThemeBox:setContentSize(CCSizeMake(headSprie:getContentSize().width/4*3,50))
		    editThemeBox:setIsSallow(false)
		    editThemeBox:setTouchPriority(-(self.layerNum-1)*20-4)
			editThemeBox:setPosition(ccp(headSprie:getContentSize().width/2+40,35))
		    self.themeBoxLabel=GetTTFLabel("",24)
			self.themeBoxLabel:setAnchorPoint(ccp(0,0.5))
		    self.themeBoxLabel:setPosition(ccp(10,editThemeBox:getContentSize().height/2))
			if self.theme then
                self.theme=getlocal("email_receiver_reply")..self.theme
                self.themeBoxLabel:setString(self.theme)
			end
			local customEditBox=customEditBox:new()
			local length=12
			customEditBox:init(editThemeBox,self.themeBoxLabel,"mail_input_bg.png",nil,-(self.layerNum-1)*20-4,length,callBackThemeHandler,nil,nil)
		    headSprie:addChild(editThemeBox,2)
			
			local bHeight=self.bgLayer:getContentSize().height-220
			backSprie:setTouchPriority(-(self.layerNum-1)*20-4)
		else
			if self.eid and (self.emailType==1 or self.emailType==3) then
				if self.emailType==1 and emailVo and emailVo.gift and emailVo.gift>=1 then
					local hSpace=260
					self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-300-hSpace),nil)
				    self.tv:setPosition(ccp(25,82+hSpace))


				    local capInSet = CCRect(20, 20, 10, 10)
				    local function touch(hd,fn,idx)

				    end
			        local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,touch)
			        headBg:setContentSize(CCSizeMake(backSprie:getContentSize().width,50))
			        headBg:ignoreAnchorPointForPosition(false)
			        headBg:setAnchorPoint(ccp(0,1))
			        headBg:setIsSallow(false)
			        headBg:setTouchPriority(-(self.layerNum-1)*20-1)
			        headBg:setPosition(ccp(0,hSpace))
			        backSprie:addChild(headBg,3)

			        local giftLb=GetTTFLabel(getlocal("gift_box"),24)
			        giftLb:setAnchorPoint(ccp(0,0.5))
			        giftLb:setPosition(ccp(10,headBg:getContentSize().height/2))
			        headBg:addChild(giftLb)

			        local iconSize=100
			        local space=15
			        local rewardTb={}
			        local awardTb={}
			        local worldWarPoint=emailVo.worldWarPoint
			        if emailVo.gift==3 and worldWarPoint and worldWarPoint>0 then
			        	local pointLb=GetTTFLabelWrap(getlocal("world_war_rank_reward_point",{worldWarPoint}),24,CCSizeMake(backSprie:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
						pointLb:setAnchorPoint(ccp(0.5,0.5))
						pointLb:setPosition(backSprie:getContentSize().width/2,145)
						backSprie:addChild(pointLb,2)
			        else
				        if emailVo.reward then
				        	local isSort=false
				        	for k,v in pairs(emailVo.reward) do
				        		local reType=k
				        		local iconNum=SizeOfTable(v)
				        		for m,n in pairs(v) do
				        			local item={}
				        			local isFlick=0
				        			if emailVo.flick and emailVo.flick[m] and tonumber(emailVo.flick[m]) and tonumber(emailVo.flick[m])>0 then
				        				isFlick=1
				        			end
				        			local sortId=0
				        			if n and type(n)=="table" then
				        				if n.index then
				        					isSort=true
				        					sortId=n.index
				        				end
					        			for i,j in pairs(n) do
					        				if i=="index" then
					        				else
					        					local name,pic,desc,id,index,eType,equipId,bgname=getItem(i,reType)
					        					item={name=name,num=j,pic=pic,desc=desc,id=id,type=reType,index=index,key=i,eType=eType,equipId=equipId,bgname=bgname}
					        					table.insert(awardTb,item)
					        					table.insert(rewardTb,{item=item,isFlick=isFlick,sortId=sortId})
					        				end
					        			end
					        		else
					        			local name,pic,desc,id,index,eType,equipId,bgname=getItem(m,reType)
			        					item={name=name,num=n,pic=pic,desc=desc,id=id,type=reType,index=index,key=m,eType=eType,equipId=equipId,bgname=bgname}
			        					table.insert(awardTb,item)
			        					table.insert(rewardTb,{item=item,isFlick=isFlick})
					        		end
				        		end
				        	end

				        	-- local rewardTab=FormatItem(emailVo.reward)
				        	local iconNum=SizeOfTable(rewardTb)
				        	if isSort==true and iconNum>0 then
				        		local function sortAsc1(a, b)
									if a.sortId and b.sortId then
										return a.sortId < b.sortId
									end
							    end
								table.sort(rewardTb,sortAsc1)
				        	end

				        	local iconTvSize, iconTvData = nil, nil
				        	local iconTotalWidth = iconSize * iconNum + (iconNum - 1) * space
				        	if iconTotalWidth > backSprie:getContentSize().width then
				        		iconTvSize = CCSizeMake(backSprie:getContentSize().width - 10, iconSize + 10)
				        		iconTvData = {}
				        	end

				        	for k,v in pairs(rewardTb) do
				        		local item=v.item
				        		local isFlick=v.isFlick
				        		local canClick=true
				        		local hideNum
				        		if item.type=="u" then
				        			canClick=false
				        		end
				        		if item.num and item.num>0 then
				        		else
				        			hideNum=true
				        		end
				        		local function showNewPropInfo()
					                G_showNewPropInfo(self.layerNum+1,true,true,nil,item)
					                return false
					            end
				        		local icon,iconScale=G_getItemIcon(item,iconSize,canClick,self.layerNum+1,showNewPropInfo,nil,nil,nil,hideNum)
				        		icon:setTouchPriority(-(self.layerNum-1)*20-4)
				        		if iconTvData then
				        			table.insert(iconTvData, {icon, item})
				        		else
					        		local firstPosX=backSprie:getContentSize().width/2-(iconSize+space)/2*(iconNum-1)
					        		icon:setPosition(ccp(firstPosX+(iconSize+space)*(k-1),150))
					        		backSprie:addChild(icon,3)
					        	end
					        	if emailVo.gift == 4 then --限制惊喜活动礼包
					        		if iconTvData == nil then
					        			local numLb = GetTTFLabel("x" .. FormatNumber(item.num), 20)
						                local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
						                numBg:setAnchorPoint(ccp(0, 1))
						                numBg:setRotation(180)
						                numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
						                numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
						                numBg:setPosition(icon:getPositionX() + iconSize / 2 - 5, icon:getPositionY() - iconSize / 2 + 5)
						                icon:getParent():addChild(numBg, 4)
						                numLb:setAnchorPoint(ccp(1, 0))
						                numLb:setPosition(numBg:getPosition())
						                icon:getParent():addChild(numLb, 4)
					        		end
					        	else
					        		if (item.type=="u" or item.type=="r" or item.type=="p" or item.type=="e") and item.num>0 then
					        			local numLb=GetTTFLabel("x"..FormatNumber(item.num),24)
					        			numLb:setAnchorPoint(ccp(1,0))
					        			numLb:setPosition(ccp(icon:getContentSize().width-5,5))
					        			icon:addChild(numLb,1)
					        			numLb:setScale(1/iconScale)
					        		end
					        	end

				        		if isFlick and isFlick==1 then
				        			G_addRectFlicker(icon,1.4*1/iconScale,1.4*1/iconScale)
				        		end
				        	end

				        	if iconTvData then
				        		local iconTv = G_createTableView(iconTvSize, iconNum, CCSizeMake(iconSize + space, iconTvSize.height), function(cell, cellSize, idx, cellNum)
				        			local icon = iconTvData[idx + 1][1]
				        			local item = iconTvData[idx + 1][2]
				        			icon:setPosition(ccp(cellSize.width / 2, cellSize.height / 2))
				        			cell:addChild(icon)
				        			local numLb = GetTTFLabel("x" .. FormatNumber(item.num), 20)
					                local numBg = CCSprite:createWithSpriteFrameName("newBlackFadeBar.png")
					                numBg:setAnchorPoint(ccp(0, 1))
					                numBg:setRotation(180)
					                numBg:setScaleX((numLb:getContentSize().width + 15) / numBg:getContentSize().width)
					                numBg:setScaleY(numLb:getContentSize().height / numBg:getContentSize().height)
					                numBg:setPosition(icon:getPositionX() + iconSize / 2 - 5, icon:getPositionY() - iconSize / 2 + 5)
					                cell:addChild(numBg, 1)
					                numLb:setAnchorPoint(ccp(1, 0))
					                numLb:setPosition(numBg:getPosition())
					                cell:addChild(numLb, 1)
				        		end, true)
				        		iconTv:setPosition(ccp((backSprie:getContentSize().width - iconTvSize.width) / 2, 150 - iconTvSize.height / 2))
				        		iconTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
				        		backSprie:addChild(iconTv,3)
				        	end
				        end
				    end

			        local function rewardHandler()
			        	if G_checkClickEnable()==false then
				            do
				                return
				            end
				        else
				            base.setWaitTime=G_getCurDeviceMillTime()
				        end
				        PlayEffect(audioCfg.mouseClick)
			        	if emailVo.isReward~=1 then
					        local function rewardCallback(fn,data)
								local ret,sData=base:checkServerData(data)
								if ret==true then
									if emailVo.gift==3 and worldWarPoint and worldWarPoint>0 then
								    	worldWarVoApi:setPoint(worldWarVoApi:getPoint()+worldWarPoint)
								    	local str=getlocal("world_war_rank_reward_point_tip",{worldWarPoint})
								    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
								    else
								    	if awardTb and SizeOfTable(awardTb)>0 then
								        	for k,v in pairs(awardTb) do
								        		if v.num and tonumber(v.num) and tonumber(v.num)>0 then
					      							G_addPlayerAward(v.type, v.key, v.id,tonumber(v.num), nil, true,false)
					      						end
								        	end
								        	G_showRewardTip(awardTb, true)
								        end
								    end

									emailVoApi:setFlag(self.emailType,0)
						        	emailVoApi:setIsReward(self.emailType,emailVo.eid)

						        	if self.rewardBtn then
						        		self.rewardBtn:setEnabled(false)
						        		local lb=tolua.cast(self.rewardBtn:getChildByTag(12),"CCLabelTTF")
										lb:setString(getlocal("activity_hadReward"))
						        	end
								end
							end
							local mid=emailVo.eid
							socketHelper:mailReward(self.emailType, mid,rewardCallback)
				        end
			        end
			        local itemStr=getlocal("daily_scene_get")
			        if emailVo.isReward==1 then
			        	itemStr=getlocal("activity_hadReward")
			        end
			        self.rewardBtn=GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",rewardHandler,11,itemStr,25,12)
					local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
					rewardMenu:setAnchorPoint(ccp(0.5,0.5))
					rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
					rewardMenu:setPosition(ccp(backSprie:getContentSize().width/2,50))
					backSprie:addChild(rewardMenu,3)
					if emailVo.isReward==1 then
						self.rewardBtn:setEnabled(false)
					end

				else
					self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-300),nil)
				    self.tv:setPosition(ccp(25,82))
				end
				self.tv:setAnchorPoint(ccp(0,0))
				self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)

			    self.bgLayer:addChild(self.tv,2)
			    self.tv:setMaxDisToBottomOrTop(120)
			end

			local isShowTip=false
			if self.emailType==1 and (tostring(emailVo.sender)~="0" and tostring(emailVo.sender)~="1" and tostring(emailVo.sender)~="2") and allianceVoApi:isHasAlliance()==true and allianceMemberVoApi:getMemberByName(emailVo.from)==nil then
				isShowTip=true
			end
			local function tipClickHandler(tag,object)
				if isShowTip==true then
			        if G_checkClickEnable()==false then
	                    do
	                        return
	                    end
			        end
			        PlayEffect(audioCfg.mouseClick)

			        -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("email_not_same_alliance"),30)
			        local tabStr={}
			        local tabColor ={}
			        local td=smallDialog:new()
			        tabStr = {"\n",getlocal("email_not_same_alliance"),"\n"}
			        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,G_ColorRed,nil})
			        sceneGame:addChild(dialog,self.layerNum+1)
			    end
		    end
			local targetSprie=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10, 10, 5, 5),tipClickHandler)
		    --targetSprie:setAnchorPoint(ccp(0,0.5))
		    targetSprie:setContentSize(CCSize(self.bgLayer:getContentSize().width/2+10,50))
		    targetSprie:setPosition(headSprie:getContentSize().width/2-25,85)
		    targetSprie:setTouchPriority(-(self.layerNum-1)*20-4)
			targetSprie:setIsSallow(false)
		    headSprie:addChild(targetSprie)

			local noticeSp
			local spSize=50
			if emailVo.isAllianceEmail and emailVo.isAllianceEmail==1 then
				noticeSp=CCSprite:createWithSpriteFrameName("Icon_warn.png")
				noticeSp:setAnchorPoint(ccp(0.5,0.5))
			    noticeSp:setScale(spSize/noticeSp:getContentSize().width)
				noticeSp:setPosition(ccp(headSprie:getContentSize().width/2-25-targetSprie:getContentSize().width/2+spSize/2,35))
				headSprie:addChild(noticeSp,3)
			end
		
			local themeSprie=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10, 10, 5, 5),tthandler)
		    --themeSprie:setAnchorPoint(ccp(0,0.5))
		    if noticeSp then
		    	themeSprie:setContentSize(CCSize(self.bgLayer:getContentSize().width/2+10-spSize,50))
			    themeSprie:setPosition(headSprie:getContentSize().width/2-25+spSize/2,35)
		    else
			    themeSprie:setContentSize(CCSize(self.bgLayer:getContentSize().width/2+10,50))
			    themeSprie:setPosition(headSprie:getContentSize().width/2-25,35)
		    end
		    themeSprie:setTouchPriority(-(self.layerNum-1)*20-2)
			themeSprie:setIsSallow(false)
		    headSprie:addChild(themeSprie)
			
			local targetLabel
			if self.emailType==1 then
				targetLabel=GetTTFLabel(emailVo.from,24)
				self.target=emailVo.from
				self.emailReceiverUId=emailVo.sender
				for k,v in pairs(GM_Name) do
	                if v == emailVo.from then
	                    targetLabel:setColor(G_ColorYellowPro)
	                    do break end
	                end
	            end
			else
				targetLabel=GetTTFLabel(emailVo.to,24)
				self.target=emailVo.to
				for k,v in pairs(GM_Name) do
	                if v == emailVo.to then
	                    targetLabel:setColor(G_ColorYellowPro)
	                    do break end
	                end
	            end
			end
			
			targetLabel:setAnchorPoint(ccp(0,0.5))
			targetLabel:setPosition(headSprie:getContentSize().width/2-20-targetSprie:getContentSize().width/2,85)
			headSprie:addChild(targetLabel,2)
			
			local themeLbWidth=30*10
			local themeLbPosX=headSprie:getContentSize().width/2-20-targetSprie:getContentSize().width/2
			if noticeSp then
				themeLbWidth=themeLbWidth-spSize
				themeLbPosX=themeLbPosX+spSize
			end
			local themeSize =24
			if G_getCurChoseLanguage() =="ru" then
				themeSize =22
			end
			local themeLabel=GetTTFLabelWrap(emailVo.title,themeSize,CCSizeMake(themeLbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			themeLabel:setAnchorPoint(ccp(0,0.5))
			themeLabel:setPosition(themeLbPosX,35)
			headSprie:addChild(themeLabel,2)
			if emailVo.title then
				self.theme=emailVo.title
			end
			
			local timeLabel
			if emailVo and emailVo.time then
				timeLabel=GetTTFLabel(emailVoApi:getTimeStr(emailVo.time),24)
			else
				timeLabel=GetTTFLabel(emailVoApi:getTimeStr(base.serverTime),24)
			end
			timeLabel:setPosition(headSprie:getContentSize().width-80,60)
			headSprie:addChild(timeLabel,2)
			--[[
			local msg=""
			if emailVo and emailVo.content then msg=emailVo.content end
			while string.find(msg,"\\n")~=nil do
				local startIdx,endIdx=string.find(msg,"\\n")
				msg=string.sub(msg,1,startIdx-1).."\n"..string.sub(msg,endIdx+1)
			end
			local contentLabel=GetTTFLabelWrap(msg,30,CCSizeMake(backSprie:getContentSize().width-20,backSprie:getContentSize().height-20),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			contentLabel:setAnchorPoint(ccp(0,1))
			contentLabel:setPosition(ccp(10,backSprie:getContentSize().height-10))
			backSprie:addChild(contentLabel,2)
			]]

			--非公会成员添加tip提示
			if isShowTip==true then
				local scale=0.75
				local tipBtn=GetButtonItem("IconTip.png","IconTip.png","IconTip.png",tipClickHandler,11,nil,nil)
				tipBtn:setScale(scale)
				local tipMenu=CCMenu:createWithItem(tipBtn)
				tipMenu:setAnchorPoint(ccp(0.5,0.5))
				tipMenu:setTouchPriority(-(self.layerNum-1)*20-4)
				local lbx,lby=targetLabel:getPosition()
				tipMenu:setPosition(ccp(lbx+targetLabel:getContentSize().width+tipBtn:getContentSize().width/2*scale+5,lby))
	            headSprie:addChild(tipMenu,4)
	        end
		end
	end
	
	local function operateHandler(tag,object)
        if G_checkClickEnable()==false then
                    do
                        return
                    end
        end
        PlayEffect(audioCfg.mouseClick)
		if tag==11 then
			--如果没有战斗
			if report.report==nil then
				--smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("fight_content_result_no_play"),30)
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("fight_content_result_no_play"),true,self.layerNum+1)
			else
				local isAttacker=emailVoApi:isAttacker(report,self.chatSender)
				local landform={0,0}
				if report.aLandform then
					landform[1]=report.aLandform
				end
				if report.dLandform then
					landform[2]=report.dLandform
				end
				local data={data=report,isAttacker=isAttacker,isReport=true,landform=landform,}
				battleScene:initData(data)
			end
		elseif tag==12 then
			if report then
				local type=report.islandType
				if type==7 then
					local place=report.place
					if place and place.x and place.y then
                        for k,v in pairs(base.commonDialogOpened_WeakTb) do
                            local dialog = base.commonDialogOpened_WeakTb[k]
                            if dialog~=nil and dialog~=self and dialog.close then
                                dialog:close()
                            end
                        end
                        self:close()
                        mainUI:changeToWorld()
                        worldScene:focus(place.x,place.y)
                    end
				else
	                self:close()
					local isAttacker=emailVoApi:isAttacker(report,self.chatSender)
					local place=report.place
					if report.type==1 and isAttacker==false then
						if report.attackerPlace~=nil then
							type=6
							place=report.attackerPlace
						end
					end
	                require "luascript/script/game/scene/gamedialog/warDialog/tankAttackDialog"
					local island={type=type,x=place.x,y=place.y}
		            local td=tankAttackDialog:new(type,island,self.layerNum+1)
		            local tbArr={getlocal("AEFFighting"),getlocal("dispatchCard"),getlocal("repair")}
		            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("AEFFighting"),true,self.layerNum+1)
		            sceneGame:addChild(dialog,self.layerNum+1)
		        end
			end
		elseif tag==13 then
			-- print("self.emailType,self.eid----1",self.emailType,self.eid)
			local lyNum=5
			if emailVo and emailVo.headlinesData and SizeOfTable(emailVo.headlinesData)>0 and (emailVo.sender==1 or emailVo.sender==0) then
				emailVoApi:showWriteEmailDialog(lyNum,getlocal("email_write"),nil,nil,nil,nil,emailVo.headlinesData,self.emailReceiverUId)
			else
				-- print("self.target,self.theme----",self.target,self.theme)
				if report~=nil and ((report.islandType and report.islandType<6 and report.islandOwner==0) or report.islandType==7) then
					do return end
				end
				-- self:close(false)
				emailVoApi:showWriteEmailDialog(lyNum,getlocal("email_write"),self.target,self.theme,nil,nil,nil,self.emailReceiverUId)
			end
		elseif tag==14 then
			-- print("self.emailType,self.eid----2",self.emailType,self.eid)
			local function deleteEmailCallback(fn,data)
				--local retTb=OBJDEF:decode(data)
				if base:checkServerData(data)==true then
					emailVoApi:deleteByEid(self.emailType,self.eid)
					self.sendSuccess=true
					base:tick()
					self:close(false)
				end
			end
			if self.sendSuccess==false then
				if emailVo and emailVo.headlinesData and SizeOfTable(emailVo.headlinesData)>0 and (emailVo.sender==1 or emailVo.sender==0) then
					local function onConfirm()
	                    socketHelper:deleteEmail(self.emailType,self.eid,deleteEmailCallback)
					end
					smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("dailyNews_delete_desc"),nil,self.layerNum+1)
				elseif emailVo and emailVo.gift and emailVo.gift>=1 and emailVo.isReward and emailVo.isReward~=1 then
					local function onConfirm()
	                    socketHelper:deleteEmail(self.emailType,self.eid,deleteEmailCallback)
					end
					smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("delete_confim"),nil,self.layerNum+1)
				else
					socketHelper:deleteEmail(self.emailType,self.eid,deleteEmailCallback)
				end
			end
		elseif tag==15 then
			local name=self.target
			local content=""
			--[[
			if self.textField then
				content=self.textField:getString()
			end
			]]
			if self.textValue then
				content=self.textValue
			end
			local theme=""
			-- if self.theme then
			-- 	theme=self.theme
			-- end
			if self.themeBoxLabel then
				theme=self.themeBoxLabel:getString()
			end
			local hasEmjoy=G_checkEmjoy(theme)
	        if hasEmjoy==false then
	            do return end
	        end
			local selfName=playerVoApi:getPlayerName()
			if self.isAllianceEmail then
				if content==nil or content=="" then
					smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("email_Content_null"),true,self.layerNum+1)
				else
					local function sendAllianceEmailCallback(fn,data)
						local success,mailData=base:checkServerData(data)
						if success==true and mailData~=nil then
							local eid=mailData.data.eid
							local ts=mailData.ts
							local email={{eid=eid,sender=playerVoApi:getUid(),from=selfName,to=name,title=theme,content=content,ts=ts,isRead=true,gift=-1}}
							emailVoApi:addEmail(3,email)
	                        allianceVoApi:setSendEmailNum()
							self.sendSuccess=true
							base:tick()
							self:close(false)
							smallDialog:showTipsDialog("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_scene_email_send_success"),30)
							local alliance=allianceVoApi:getSelfAlliance()
							if alliance and alliance.aid then								
				                local params={uid=playerVoApi:getUid()}
				                chatVoApi:sendUpdateMessage(34,params,alliance.aid+1)
				            end
						end
					end
					if self.sendSuccess==false then
						if allianceVoApi:isHasAlliance() then
							local alliance=allianceVoApi:getSelfAlliance()
							socketHelper:allianceMail(alliance.aid,theme,content,sendAllianceEmailCallback)
						end
					end
				end
			else
				if name==nil or name=="" then
					--smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("email_receiver_null"),30)
					smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("email_receiver_null"),true,self.layerNum+1)
				elseif content==nil or content=="" then
					--smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("email_Content_null"),30)
					smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("email_Content_null"),true,self.layerNum+1)
				elseif (self.emailReceiverUId==nil and name==selfName) or (self.emailReceiverUId and tonumber(self.emailReceiverUId)==playerVoApi:getUid()) then
					--smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("email_cant_send_self"),30)
					smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("email_cant_send_self"),true,self.layerNum+1)
				else
					if self.headlinesData and SizeOfTable(self.headlinesData)>0 then
						content={headlinesData=self.headlinesData,content=content}
					end
					local function sendEmailCallback(fn,data)
						local success,mailData=base:checkServerData(data)
						if success==true and mailData~=nil then
							local eid=mailData.data.eid
							local ts=mailData.ts
							local email={{eid=eid,sender=playerVoApi:getUid(),from=selfName,to=name,title=theme,content=content,ts=ts,isRead=true}}
							emailVoApi:addEmail(3,email)
							self.sendSuccess=true
							base:tick()
							self:close(false)
							smallDialog:showTipsDialog("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("email_send_sucess"),30)
						end
					end
					if self.sendSuccess==false then
						local data={name=name,title=theme,content=content,type=1}
						if self.emailReceiverUId ~= nil and type(self.emailReceiverUId)=="number" and self.emailReceiverUId ~= 0 then
						    data={name=name,title=theme,content=content,type=1,receiverId=tonumber(self.emailReceiverUId)}
						end
						socketHelper:sendEmail(data,sendEmailCallback)
					end
				end	
			end				  
		elseif tag==16 then
			--检测是否被禁言
			if chatVoApi:canChat(self.layerNum)==false then
				do return end
			end
			
            local playerLv=playerVoApi:getPlayerLevel()
            local timeInterval=playerCfg.chatLimitCfg[playerLv] or 0
			local diffTime=0
			if base.lastSendTime then
				diffTime=base.serverTime-base.lastSendTime
			end
			--[[
			if diffTime>0 and diffTime<timeInterval then
				--smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("time_limit_prompt",{timeInterval-diffTime}),30)
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("time_limit_prompt",{timeInterval-diffTime}),true,self.layerNum+1)
				do return end
			end
			]]
			if diffTime>=timeInterval then
				self.canSand=true
			end
			if self.canSand==nil or self.canSand==false then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("time_limit_prompt",{timeInterval-diffTime}),true,self.layerNum+1)
				do return end
			end
			self.canSand=false
			
			local sender=playerVoApi:getUid()
            local chatContent=emailVo.title
			if chatContent==nil then
				chatContent=""
			end
			--如果有联盟，选择联盟还是世界；没有则世界发送到世界 1为世界
			local hasAlliance=allianceVoApi:isHasAlliance()
			local reportData={}
			local brType
			if emailVo and emailVo.headlinesData and SizeOfTable(emailVo.headlinesData)>0 then
				local headlinesData=emailVo.headlinesData
				reportData=headlinesData

				local newsContent=headlinesData.content
				chatContent=getlocal("dailyNews_chat_headlines",{newsContent})

				brType=17
			else
				for k,v in pairs(report) do
					-- print("k,v",k,v)
					if k=="resource" then
						local resData={u={}}
						if v and SizeOfTable(v)>0 then
							local index1,index2=1,1
							for m,n in pairs(v) do
								if n.type=="u" then
									if resData.u[index1]==nil then
										resData.u[index1]={}
									end
									resData.u[index1][n.key]=n.num
									index1=index1+1
								elseif n.type=="r" then
									if resData.r==nil then
										resData.r={}
									end
									if resData.r[index2]==nil then
										resData.r[index2]={}
									end
									resData.r[index2][n.key]=n.num
									index2=index2+1
								end
							end
						end
						reportData[k]=resData
					elseif k=="award" then
						reportData[k]={}
						if report.islandType==7 then
							reportData[k]=report.award
						else
							if report.report and report.report.r and type(report.report.r)=="table" then
								reportData[k]=report.report.r
							end
						end
					elseif k=="lostShip" then
						local defLost={o={}}
						local attLost={o={}}
						local attTotal={o={}}
						local defTotal={o={}}
						if v and v.defenderLost then
							for m,n in pairs(v.defenderLost) do
								if defLost.o[m]==nil then
									defLost.o[m]={}
								end
								defLost.o[m][n.key]=n.num
							end
						end
						if v and v.attackerLost then
							for m,n in pairs(v.attackerLost) do
								attLost.o[m]={}
								if attLost.o[m]==nil then
									attLost.o[m]={}
								end
								attLost.o[m][n.key]=n.num
							end
						end
						if v and v.attackerTotal then
							for m,n in pairs(v.attackerTotal) do
								attTotal.o[m]={}
								if attTotal.o[m]==nil then
									attTotal.o[m]={}
								end
								attTotal.o[m][n.key]=n.num
							end
						end
						if v and v.defenderTotal then
							for m,n in pairs(v.defenderTotal) do
								defTotal.o[m]={}
								if defTotal.o[m]==nil then
									defTotal.o[m]={}
								end
								defTotal.o[m][n.key]=n.num
							end
						end
						reportData[k]={}
						reportData[k]["defenderLost"]=defLost
						reportData[k]["attackerLost"]=attLost
						reportData[k]["attackerTotal"]=attTotal
						reportData[k]["defenderTotal"]=defTotal
					else
						reportData[k]=v
					end
				end
			end
			if G_checkShare()==false then --10秒内视为频繁分享
			    do return end
			end
			if hasAlliance==false then
				base.lastSendTime=base.serverTime
				--local chatContent=emailVoApi:getAttackTitle(emailVo.eid)
				
				local senderName=playerVoApi:getPlayerName()
				local level=playerVoApi:getPlayerLevel()
				local rank=playerVoApi:getRank()
				local language=G_getCurChoseLanguage()
                local params={subType=1,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),hfid=playerVoApi:getHfid(),report=reportData,ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=language,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle()}
                if brType then
                	params.brType=brType
                end
				--chatVoApi:addChat(1,sender,senderName,0,"",params)
                chatVoApi:sendChatMessage(1,sender,senderName,0,"",params)
				--mainUI:setLastChat()
				if brType==17 then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("daily_news_send_success",{getlocal("dailyNews_my_headlines"),getlocal("report_to_world")}),28)
				else
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
				end
				G_syncShareTime()
			else
                local function sendReportHandle(tag,object)
                    base.lastSendTime=base.serverTime
                    local channelType=tag or 1
                    
                    local senderName=playerVoApi:getPlayerName()
                    local level=playerVoApi:getPlayerLevel()
                    local rank=playerVoApi:getRank()
                    local allianceName
			        local allianceRole
			        if allianceVoApi:isHasAlliance() then
			            local allianceVo=allianceVoApi:getSelfAlliance()
			            allianceName=allianceVo.name
			            allianceRole=allianceVo.role
			        end
			        local language=G_getCurChoseLanguage()
                    local params={subType=channelType,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),hfid=playerVoApi:getHfid(),report=reportData,ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),language=language,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle()}
                    if brType then
	                	params.brType=brType
	                end
                    local aid=playerVoApi:getPlayerAid()
                    if channelType==1 then
                    	chatVoApi:sendChatMessage(1,sender,senderName,0,"",params)
                    	if brType==17 then
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("daily_news_send_success",{getlocal("dailyNews_my_headlines"),getlocal("report_to_world")}),28)
						else
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
						end
                    elseif aid then
                        chatVoApi:sendChatMessage(aid+1,sender,senderName,0,"",params)
                        if brType==17 then
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("daily_news_send_success",{getlocal("dailyNews_my_headlines"),getlocal("alliance_list_scene_name")}),28)
						else
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
						end
                        G_syncShareTime()
                    end
                end
                allianceSmallDialog:selectChannelDialog("PanelHeaderPopup.png",CCSizeMake(450,350),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,sendReportHandle)
			end
		elseif tag==17 then
			local function sendFeedCallback()
				local function feedsawardHandler(fn,data)
					if base:checkServerData(data)==true then
                        if G_curPlatName()=="12" or G_curPlatName()=="androidzhongshouyouru" or G_curPlatName()=="0" then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shareSuccess"),28)
                        end
					end
				end
				if(G_isKakao()==false)then
					socketHelper:feedsaward(1,feedsawardHandler)
				end
			end
			G_sendFeed(2,sendFeedCallback)
		end
	end
	
	local scale=0.75
	self.replayBtn=GetButtonItem("letterBtnPlay_v2.png","letterBtnPlay_Down_v2.png","letterBtnPlay_Down_v2.png",operateHandler,11,nil,nil)
	self.replayBtn:setScaleX(scale)
	self.replayBtn:setScaleY(scale)
	local replaySpriteMenu=CCMenu:createWithItem(self.replayBtn)
	replaySpriteMenu:setAnchorPoint(ccp(0.5,0))
	replaySpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	--replaySpriteMenu:setScaleX(scale)
	--replaySpriteMenu:setScaleY(scale)
	
	self.attackBtn=GetButtonItem("attackBtn_v2.png","attackBtnDown_v2.png","attackBtnDown_v2.png",operateHandler,12,nil,nil)
	self.attackBtn:setScaleX(scale)
	self.attackBtn:setScaleY(scale)
	local attackSpriteMenu=CCMenu:createWithItem(self.attackBtn)
	attackSpriteMenu:setAnchorPoint(ccp(0.5,0))
	attackSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	--attackSpriteMenu:setScaleX(scale)
	--attackSpriteMenu:setScaleY(scale)
	
	self.writeBtn=GetButtonItem("yh_letterBtnWrite.png","yh_letterBtnWrite_Down.png","yh_letterBtnWrite_Down.png",operateHandler,13,nil,nil)
	self.writeBtn:setScaleX(scale)
	self.writeBtn:setScaleY(scale)
	local writeSpriteMenu=CCMenu:createWithItem(self.writeBtn)
	writeSpriteMenu:setAnchorPoint(ccp(0.5,0))
	writeSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	--writeSpriteMenu:setScaleX(scale)
	--writeSpriteMenu:setScaleY(scale)
	
	self.deleteBtn=GetButtonItem("yh_letterBtnDelete.png","yh_letterBtnDelete_Down.png","yh_letterBtnDelete_Down.png",operateHandler,14,nil,nil)
	self.deleteBtn:setScaleX(scale)
	self.deleteBtn:setScaleY(scale)
	local deleteSpriteMenu=CCMenu:createWithItem(self.deleteBtn)
	deleteSpriteMenu:setAnchorPoint(ccp(0.5,0))
	deleteSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	--deleteSpriteMenu:setScaleX(scale)
	--deleteSpriteMenu:setScaleY(scale)

	local pingbiSpriteMenu
	if self.emailType==1 and base.mailBlackList==1 then
		local function callback()
		end
		if emailVo then
			if emailVo.sender and emailVo.sender>10 and emailVo.from and emailVo.from~="" then
				local function 	addBlackList()
					if G_checkClickEnable()==false then
			                    do
			                        return
			                    end
			        end
			        PlayEffect(audioCfg.mouseClick)

					local uid=emailVo.sender
					local name= emailVo.from
					local blackList=G_getBlackList()
					if blackList and SizeOfTable(blackList)>0 then
						for k,v in pairs(blackList) do
							if tonumber(uid)==tonumber(v.uid) and tostring(name)==tostring(v.name) then
								smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shieldSuccess",{name}),28)
								do return end
							end
						end
					end
					if SizeOfTable(G_getBlackList())>=G_blackListNum then
				         smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("blackListMax"),28)
				        do return end
				    end
					local function confirmHandler()
	                    local function saveBlackCallback()
	                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shieldSuccess",{name}),28)
	                    end
						local toBlackTb={uid=uid,name=name}
						local isSuccess=G_saveNameAndUidInBlackList(toBlackTb,saveBlackCallback)
						-- if isSuccess==true then
						-- 	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shieldSuccess",{name}),28)
						-- end
					end
					smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),confirmHandler,getlocal("dialog_title_prompt"),getlocal("shieldDesc1",{name}),nil,self.layerNum+2)
				end
				callback=addBlackList
			end
		end
		self.pingbiBtn=GetButtonItem("forbid_btn.png","forbid_btn_Down.png","forbid_btn_Down.png",callback,14,nil,nil)
		self.pingbiBtn:setScaleX(scale)
		self.pingbiBtn:setScaleY(scale)
		pingbiSpriteMenu=CCMenu:createWithItem(self.pingbiBtn)
		pingbiSpriteMenu:setAnchorPoint(ccp(0.5,0))
		pingbiSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
		if emailVo then
			if emailVo.sender and emailVo.sender>10 and emailVo.from and emailVo.from~="" then
			else
				self.pingbiBtn:setEnabled(false)
			end
		end
	end

	
	self.sendBtn=GetButtonItem("letterBtnSend_v2.png","letterBtnSend_Down_v2.png","letterBtnSend_Down_v2.png",operateHandler,15,nil,nil)
	self.sendBtn:setScaleX(scale)
	self.sendBtn:setScaleY(scale)
	local sendSpriteMenu=CCMenu:createWithItem(self.sendBtn)
	sendSpriteMenu:setAnchorPoint(ccp(0.5,0))
	sendSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	--sendSpriteMenu:setScaleX(scale)
	--sendSpriteMenu:setScaleY(scale)
	
	--self.feedBtn=GetButtonItem("letterBtnSend.png","letterBtnSend_Down.png","letterBtnSend_Down.png",operateHandler,17,nil,nil)
    local btnTextSize = 30
    if G_getCurChoseLanguage()=="ru" then
        btnTextSize = 25
    end
	self.feedBtn=GetButtonItem("cin_newShareBtn.png","cin_newShareBtn_Down.png","cin_newShareBtn.png",operateHandler,17)
	-- self.feedBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",operateHandler,17,getlocal("feedBtn"),btnTextSize)
	self.feedBtn:setScaleX(scale)
	self.feedBtn:setScaleY(scale)
	local feedSpriteMenu=CCMenu:createWithItem(self.feedBtn)
	feedSpriteMenu:setAnchorPoint(ccp(0.5,0))
	feedSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	--feedSpriteMenu:setScaleX(scale)
	--feedSpriteMenu:setScaleY(scale)
	
	local height=45
	local posXScale=self.bgLayer:getContentSize().width
	
	if self.emailType==2 and report~=nil then
		if report.type==1 then
			local isAttacker=emailVoApi:isAttacker(report,self.chatSender)
			if isAttacker==true then
				self.bgLayer:addChild(replaySpriteMenu,2)
				self.bgLayer:addChild(writeSpriteMenu,2)
				self.bgLayer:addChild(deleteSpriteMenu,2)
				self.bgLayer:addChild(sendSpriteMenu,2)
				replaySpriteMenu:setPosition(ccp(posXScale/5*1,height))
				writeSpriteMenu:setPosition(ccp(posXScale/5*2,height))
				deleteSpriteMenu:setPosition(ccp(posXScale/5*3,height))
				sendSpriteMenu:setPosition(ccp(posXScale/5*4,height))
				self.sendBtn:setTag(16)
				--[[
				self.bgLayer:addChild(replaySpriteMenu,2)
				self.bgLayer:addChild(writeSpriteMenu,2)
				self.bgLayer:addChild(deleteSpriteMenu,2)
				replaySpriteMenu:setPosition(ccp(posXScale/4*1,height))
				writeSpriteMenu:setPosition(ccp(posXScale/4*2,height))
				deleteSpriteMenu:setPosition(ccp(posXScale/4*3,height))
				]]
				if report.report==nil or SizeOfTable(report.report) < 2 then --[SizeOfTable(report.report) < 2  :   因为在report字段内新加了一个bm字段，用于繁荣度的显示，所以为了防止只有bm的情况下 replayBtn不置灰，特做如上修正]
					self.replayBtn:setEnabled(false)
				end
				if (report.islandType and report.islandType<6 and report.islandOwner==0) or report.islandType==7 then --如果防守方不是玩家的话对于进攻方来说不可以写邮件
					self.writeBtn:setEnabled(false)
				end
				local itStrSize = 24
				if G_getCurChoseLanguage() =="it" then
					itStrSize = 20
				end
				if report.isVictory==1 and self.chatSender==nil and report.islandType==6 then
					if G_isShowShareBtn() then
						if(G_isKakao()==false)then
							-- local feedDescLable = GetTTFLabelWrap(getlocal("feedDesc"),itStrSize,CCSizeMake(25*16,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					  --       feedDescLable:setAnchorPoint(ccp(0,0))
					  --       feedDescLable:setPosition(ccp(posXScale/5*1-self.replayBtn:getContentSize().width/2,self.feedBtn:getContentSize().height+15))
							-- self.bgLayer:addChild(feedDescLable,2)
						end
						
						self.bgLayer:addChild(feedSpriteMenu,2)
						-- feedSpriteMenu:setPosition(ccp(posXScale/5*4,height+self.sendBtn:getContentSize().height-15))

						replaySpriteMenu:setPosition(ccp(posXScale/6*1-30,height))
						writeSpriteMenu:setPosition(ccp(posXScale/6*2-15,height))
						deleteSpriteMenu:setPosition(ccp(posXScale/6*3,height))
						sendSpriteMenu:setPosition(ccp(posXScale/6*4+15,height))
						feedSpriteMenu:setPosition(ccp(posXScale/6*5+30,height))
					end
				end
			else
				self.bgLayer:addChild(replaySpriteMenu,2)
				self.bgLayer:addChild(attackSpriteMenu,2)
				self.bgLayer:addChild(writeSpriteMenu,2)
				self.bgLayer:addChild(deleteSpriteMenu,2)
				self.bgLayer:addChild(sendSpriteMenu,2)
				replaySpriteMenu:setPosition(ccp(posXScale/6*1-30,height))
				attackSpriteMenu:setPosition(ccp(posXScale/6*2-15,height))
				writeSpriteMenu:setPosition(ccp(posXScale/6*3,height))
				deleteSpriteMenu:setPosition(ccp(posXScale/6*4+15,height))
				sendSpriteMenu:setPosition(ccp(posXScale/6*5+30,height))
				self.sendBtn:setTag(16)
				--[[
				self.bgLayer:addChild(replaySpriteMenu,2)
				self.bgLayer:addChild(attackSpriteMenu,2)
				self.bgLayer:addChild(writeSpriteMenu,2)
				self.bgLayer:addChild(deleteSpriteMenu,2)
				replaySpriteMenu:setPosition(ccp(posXScale/5*1-30,height))
				attackSpriteMenu:setPosition(ccp(posXScale/5*2-15,height))
				writeSpriteMenu:setPosition(ccp(posXScale/5*3,height))
				deleteSpriteMenu:setPosition(ccp(posXScale/5*4+15,height))
				]]
				if report.report==nil or SizeOfTable(report.report) < 2 then
					self.replayBtn:setEnabled(false)
				end
				local itStrSize = 24
				if G_getCurChoseLanguage() =="it" then
					itStrSize = 10
				end
				if report.isVictory~=1 and self.chatSender==nil then
					if G_isShowShareBtn() then
						if(G_isKakao()==false)then
							-- local feedDescLable = GetTTFLabelWrap(getlocal("feedDesc"),itStrSize,CCSizeMake(25*16,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					  --       feedDescLable:setAnchorPoint(ccp(0,0))
					  --       feedDescLable:setPosition(ccp(posXScale/6*1-30,self.feedBtn:getContentSize().height+15))
							-- self.bgLayer:addChild(feedDescLable,2)
						end
						
						self.bgLayer:addChild(feedSpriteMenu,2)
						-- feedSpriteMenu:setPosition(ccp(posXScale/6*5+30,height+self.sendBtn:getContentSize().height-15))

						replaySpriteMenu:setPosition(ccp(posXScale/6*1-30,height))
						writeSpriteMenu:setPosition(ccp(posXScale/6*2-15,height))
						deleteSpriteMenu:setPosition(ccp(posXScale/6*3,height))
						sendSpriteMenu:setPosition(ccp(posXScale/6*4+15,height))
						feedSpriteMenu:setPosition(ccp(posXScale/6*5+30,height))
					end
				end
			end
		elseif report.type==2 then
			if report.allianceName and allianceVoApi:isSameAlliance(report.allianceName) then
				self.bgLayer:addChild(deleteSpriteMenu,2)
				deleteSpriteMenu:setPosition(ccp(posXScale/2,height))
			else
				self.bgLayer:addChild(attackSpriteMenu,2)
				self.bgLayer:addChild(deleteSpriteMenu,2)
				attackSpriteMenu:setPosition(ccp(posXScale/3*1,height))
				deleteSpriteMenu:setPosition(ccp(posXScale/3*2,height))
			end
		elseif report.type==3 then
			self.bgLayer:addChild(deleteSpriteMenu,2)
			deleteSpriteMenu:setPosition(ccp(posXScale/2,height))
		elseif report.type==4 then
			self.bgLayer:addChild(deleteSpriteMenu,2)
			deleteSpriteMenu:setPosition(ccp(posXScale/2,height))
		elseif report.type==5 then
			-- local function gotoMapHandler( ... )
			-- 	if report and report.place then
			-- 		local mapx,mapy
			-- 		if report.place[1] and report.place[2] then
			-- 			mapx,mapy=report.place[1],report.place[2]
			-- 		elseif report.place.x and report.place.y then
			-- 			mapx,mapy=report.place.x,report.place.y
			-- 		end
			-- 		if mapx and mapy then
			-- 			self:close()
			-- 			if(base and base.commonDialogOpened_WeakTb and #base.commonDialogOpened_WeakTb>0)then
			-- 				for k,v in pairs(base.commonDialogOpened_WeakTb) do
			-- 					if v and v.close then
			-- 						v:close()
			-- 					end
			-- 				end
			-- 	        end
			-- 	        if(G_SmallDialogDialogTb and SizeOfTable(G_SmallDialogDialogTb)>0)then
			-- 				for k,v in pairs(G_SmallDialogDialogTb) do
			-- 					if v and v.close then
			-- 						v:close()
			-- 					end
			-- 				end
			-- 	        end
			-- 			mainUI:changeToWorld()
			-- 			worldScene:focus(mapx,mapy)
			-- 		end
			-- 	end
			-- end
			-- local gotoMapBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",gotoMapHandler,20,getlocal("go_to_map_btn"),25)
			-- gotoMapBtn:setScaleX(scale)
			-- gotoMapBtn:setScaleY(scale)
			-- local gotoMapMenu=CCMenu:createWithItem(gotoMapBtn)
			-- gotoMapMenu:setAnchorPoint(ccp(0.5,0))
			-- gotoMapMenu:setTouchPriority(-(self.layerNum-1)*20-4)
			-- self.bgLayer:addChild(gotoMapMenu,2)
			-- gotoMapMenu:setPosition(ccp(posXScale/4*1,height))
			-- if playerVoApi:getPlayerLevel()<3 then
			-- 	gotoMapBtn:setEnabled(false)
			-- end
			self.bgLayer:addChild(deleteSpriteMenu,2)
			-- deleteSpriteMenu:setPosition(ccp(posXScale/2,height))
			deleteSpriteMenu:setPosition(ccp(posXScale/3*1,height))
			self.sendBtn:setTag(16)
			self.bgLayer:addChild(sendSpriteMenu,2)
			-- sendSpriteMenu:setPosition(ccp(posXScale/4*3,height))
			sendSpriteMenu:setPosition(ccp(posXScale/3*2,height))
		elseif report.type==6 then
			self.bgLayer:addChild(deleteSpriteMenu,2)
			deleteSpriteMenu:setPosition(ccp(posXScale/2,height))
			local searchtype=report.searchtype
			if searchtype and searchtype==1 then
				self.sendBtn:setTag(16)
				self.bgLayer:addChild(attackSpriteMenu,2)
				self.bgLayer:addChild(sendSpriteMenu,2)
				attackSpriteMenu:setPosition(ccp(posXScale/4*1,height))
				sendSpriteMenu:setPosition(ccp(posXScale/4*3,height))
			end
		elseif report.type==8 or report.type==7 then
			self.bgLayer:addChild(deleteSpriteMenu,2)
			deleteSpriteMenu:setPosition(ccp(posXScale/2,height))
		end
		-- if emailVo and emailVo.sender==1 and emailVo.sender==1 then
		-- 	self.writeBtn:setEnabled(false)
		-- end
	elseif emailVo==nil then
		self.bgLayer:addChild(sendSpriteMenu,2)
		sendSpriteMenu:setPosition(ccp(posXScale/2,height))
	elseif self.emailType==1 then
		self.bgLayer:addChild(writeSpriteMenu,2)
		self.bgLayer:addChild(deleteSpriteMenu,2)


		if emailVo and emailVo.headlinesData and SizeOfTable(emailVo.headlinesData)>0 and (emailVo.sender==1 or emailVo.sender==0) then
			writeSpriteMenu:setPosition(ccp(posXScale/4*1-20,height))
			deleteSpriteMenu:setPosition(ccp(posXScale/4*3+20,height))

			self.bgLayer:addChild(sendSpriteMenu,2)
			sendSpriteMenu:setPosition(ccp(posXScale/4*2,height))
			self.sendBtn:setTag(16)
		else
			if base.mailBlackList==1 then
				writeSpriteMenu:setPosition(ccp(posXScale/4*2,height))
				deleteSpriteMenu:setPosition(ccp(posXScale/4*3+20,height))

				self.bgLayer:addChild(pingbiSpriteMenu,2)
				pingbiSpriteMenu:setPosition(ccp(posXScale/4*1-20,height))
			else
				writeSpriteMenu:setPosition(ccp(posXScale/3*1,height))
				deleteSpriteMenu:setPosition(ccp(posXScale/3*2,height))
			end

			if emailVo and (emailVo.sender==1 or emailVo.sender==0) then
				self.writeBtn:setEnabled(false)
			end
		end
	elseif self.emailType==3 then
		self.bgLayer:addChild(deleteSpriteMenu,2)
		deleteSpriteMenu:setPosition(ccp(posXScale/2,height))
	end
	
	if self.chatSender~=nil then
		self.attackBtn:setEnabled(false)
		self.writeBtn:setEnabled(false)
		self.deleteBtn:setEnabled(false)
		self.sendBtn:setEnabled(false)
	end
end

function emailDetailDialog:addHeadlines(parent,bgHeight,bgPy,headlinesData)
	if parent and bgHeight and bgPy then
		local bgWidth=parent:getContentSize().width
		local function maskTouch2()
		end
		local headTvBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),maskTouch2)
	    headTvBg:setContentSize(CCSizeMake(bgWidth,bgHeight))
	    headTvBg:ignoreAnchorPointForPosition(false)
	    headTvBg:setAnchorPoint(ccp(0,1))
	    headTvBg:setIsSallow(true)
	    headTvBg:setTouchPriority(-(self.layerNum-1)*20-5)
		headTvBg:setPosition(ccp(0,bgPy))
	    parent:addChild(headTvBg)
	    headTvBg:setOpacity(0)

    	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setScale((headTvBg:getContentSize().width-20)/lineSp:getContentSize().width)
		lineSp:setPosition(ccp(headTvBg:getContentSize().width/2,headTvBg:getContentSize().height+5))
		headTvBg:addChild(lineSp)

		require "luascript/script/game/scene/gamedialog/dailyNews/dailyNewsHeadlines"
		-- local headlinesBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function ()end)
		local dhDialog=dailyNewsHeadlines:new()
	    local headlinesBg=dhDialog:init(self.layerNum,nil,true,headlinesData)
		local cellWidth,cellHeight,tvHeight=bgWidth,headlinesBg:getContentSize().height+110,headTvBg:getContentSize().height
		local function tvCallBack(handler,fn,idx,cel)
		    if fn=="numberOfCellsInTableView" then
		        return 1
		    elseif fn=="tableCellSizeForIndex" then
		        local tmpSize=CCSizeMake(cellWidth,cellHeight)
		        return tmpSize
		    elseif fn=="tableCellAtIndex" then
		        local cell=CCTableViewCell:new()
		        cell:autorelease()

		        local posx=38
			    -- local dnDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("dailyNewsDialogBg.png",CCRect(154, 110, 1, 1),function ()end)
				-- dnDialogBg:setContentSize(CCSizeMake(308,cellHeight/2))
				-- dnDialogBg:setScale(2)
				local dnDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("dailyNewsDialogBg2.png",CCRect(47, 44, 1, 1),function ()end)
				dnDialogBg:setContentSize(CCSizeMake(308*2-40,cellHeight))
				dnDialogBg:setAnchorPoint(ccp(0.5,1))
				dnDialogBg:setPosition(ccp(cellWidth/2,cellHeight))
				cell:addChild(dnDialogBg)

		        local posy=cellHeight-60--130
				if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" then
					local titlePx=180-20
					for i=1,4 do
						local titlePic
						if i==1 then
							titlePic="mei_cn.png"
						elseif i==2 then
							titlePic="ri_cn.png"
						elseif i==3 then
							titlePic="jie_cn.png"
						else
							titlePic="bao_cn.png"
						end
						if titlePic then
							local titleSp=CCSprite:createWithSpriteFrameName(titlePic)
							if titleSp then
								titleSp:setScale(2)
								titleSp:setAnchorPoint(ccp(0,0.5))
								titleSp:setPosition(ccp(titlePx,posy))
								cell:addChild(titleSp,1)
								titlePx=titlePx+titleSp:getContentSize().width*2+5
							end
						end
					end
				else
					local titleSp=CCSprite:createWithSpriteFrameName("newsTitle_en.png")
					titleSp:setScale(2)
					titleSp:setAnchorPoint(ccp(0.5,0.5))
					titleSp:setPosition(ccp(cellWidth/2,posy))
					cell:addChild(titleSp,1)
				end

				posy=posy-35
				local lineSp=CCSprite:createWithSpriteFrameName("lineWhite.png")
				lineSp:setScaleX((cellWidth-posx*2+8)/lineSp:getContentSize().width)
				lineSp:setScaleY(4)
				lineSp:setPosition(ccp(cellWidth/2-3,posy-8))
				cell:addChild(lineSp,1)
				lineSp:setColor(G_ColorBlack)
				
				local numLb=GetTTFLabelWrap(getlocal("dailyNews_journals_num",{headlinesData.journalsNum or 0}),16,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
				numLb:setAnchorPoint(ccp(0,0))
				numLb:setPosition(ccp(posx,posy))
				cell:addChild(numLb,1)
				numLb:setColor(G_ColorBlack)
				local dateLb=GetTTFLabel(G_getDateStr(headlinesData.journalsDate or base.serverTime,true,true),16)
				dateLb:setAnchorPoint(ccp(1,0))
				dateLb:setPosition(ccp(cellWidth-posx,posy))
				cell:addChild(dateLb,1)
				dateLb:setColor(G_ColorBlack)

		        if headlinesBg then
					headlinesBg:setAnchorPoint(ccp(0.5,1))
					headlinesBg:setPosition(ccp(cellWidth/2,posy))
					cell:addChild(headlinesBg)
					headlinesBg:setOpacity(0)
		        end
		        
		        return cell
		    elseif fn=="ccTouchBegan" then
		        isMoved=false
		        return true
		    elseif fn=="ccTouchMoved" then
		        isMoved=true
		    elseif fn=="ccTouchEnded"  then

		    end
		end
		local hd=LuaEventHandler:createHandler(tvCallBack)
		local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,tvHeight),nil)
		tv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
		tv:setPosition(ccp(0,0))
		headTvBg:addChild(tv,2)
		tv:setMaxDisToBottomOrTop(120)
	end
end

function emailDetailDialog:getReportAccessoryhight(report)
	if self.repAcceHeight==nil then
		local function cellClick()
		end
		local backSprie5 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
	    backSprie5:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))

	    local accessory=report.accessory or {}
		local attAccData={}
		local defAccData={}
		local isAttacker=emailVoApi:isAttacker(report,self.chatSender)
		if isAttacker==true then
			attAccData=accessory[1] or {}
			defAccData=accessory[2] or {}
		else
			attAccData=accessory[2] or {}
			defAccData=accessory[1] or {}
		end
		local attScore=attAccData[1] or 0
		local defScore=defAccData[1] or 0
		local attTab=attAccData[2] or {0,0,0}
		local defTab=defAccData[2] or {0,0,0}

	    for i=1,2 do
			local content={}
			content[i]={}

			local campStr=""
			local scoreStr=getlocal("report_accessory_score")
			local score=0

			if i==1 then
				campStr=getlocal("report_accessory_owner")
				score=attScore

			elseif i==2 then
				campStr=getlocal("report_accessory_enemy")
				score=defScore

			end

			table.insert(content[i],{campStr,G_ColorGreen})
			table.insert(content[i],{scoreStr,G_ColorGreen})
			table.insert(content[i],{score,G_ColorWhite})

			local contentLbHight=60
			for k,v in pairs(content[i]) do
				local contentMsg=v
				local message=""
				local color
				if type(contentMsg)=="table" then
					message=contentMsg[1]
				else
					message=contentMsg
				end
                local contentLb
                contentLb=GetTTFLabelWrap(message,24,CCSizeMake((backSprie5:getContentSize().width-50)/2, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			    if k==1 then
			    	contentLbHight=contentLbHight+(contentLb:getContentSize().height+100)
			    	if accessoryVoApi:isUpgradeQualityRed()==true or (attTab and SizeOfTable(attTab)>=5) or (defTab and SizeOfTable(defTab)>=5) then
			    		contentLbHight=contentLbHight+40
			    	end
		    	elseif k==2 then
		    		contentLbHight=contentLbHight+(contentLb:getContentSize().height+5)
		    	else
		    		contentLbHight=contentLbHight+(contentLb:getContentSize().height+25)
		    	end
			end
			contentLbHight=contentLbHight+30
			if self.repAcceHeight~=nil and tonumber(self.repAcceHeight)~=nil then
				if tonumber(self.repAcceHeight)<contentLbHight then
					self.repAcceHeight=contentLbHight
				end
			else
				self.repAcceHeight=contentLbHight
			end
		end
	end
	return self.repAcceHeight
end
function emailDetailDialog:getcellhight( ... )
	-- body
	if self.cellHight==nil then
		if self.eid and (self.emailType==1 or self.emailType==3) then
			local emailVo=nil
			if self.eid and self.emailType then
				emailVo=emailVoApi:getEmailByEid(self.emailType,self.eid)
			end
			local msg=""
			if emailVo and emailVo.content then 
				if type(emailVo.content)=="table" and emailVo.content.content then
					msg=emailVo.content.content
				else
					msg=emailVo.content
				end
			end
			-- msg="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"	
			while string.find(msg,"\\n")~=nil do
				local startIdx,endIdx=string.find(msg,"\\n")
				msg=string.sub(msg,1,startIdx-1).."\n"..string.sub(msg,endIdx+1)
			end

			local isHasUrl=false
			local messageTb={}
			if self.emailType==1 and (tostring(emailVo.sender)=="0" or tostring(emailVo.sender)=="1" or tostring(emailVo.sender)=="2") then 
				local strLen=string.len(msg)
				local wz=msg
				local endMsg=""
				while string.find(wz,"#(.-)#")~=nil do
					isHasUrl=true
					local startIdx,endIdx=string.find(wz,"#(.-)#")

					local firstStr=""
					local endStr=""
					if startIdx>1 then
						firstStr=string.sub(wz,1,startIdx-1)
					end
					if endIdx<strLen then
						endStr=string.sub(wz,endIdx+1)
					end
					if endIdx-startIdx>1 then
			            local newKey=string.sub(wz,startIdx+1,endIdx-1)
			            -- wz=firstStr..getlocal(newKey)..endStr
			            table.insert(messageTb,{firstStr,0})
						table.insert(messageTb,{newKey,1})
					-- else
					-- 	wz=firstStr..endStr
					end
					wz=endStr
					endMsg=endStr
				end
				if endMsg and endMsg~="" then
					table.insert(messageTb,{endMsg,0})
				end
			end

			local height1=0
			if isHasUrl==true and messageTb and SizeOfTable(messageTb)>0 then
				for k,v in pairs(messageTb) do
					local msgStr=v[1]
					local isUrl=v[2]
					if isUrl and isUrl==1 then
						local function jumpToHandler()
						end
						local contentLabel=GetTTFLabelWrap(msgStr,24,CCSizeMake(self.txtSize*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
					    local meunItem = CCMenuItemLabel:create(contentLabel)
					    height1=height1+meunItem:getContentSize().height
					else
						local contentLabel=GetTTFLabelWrap(msgStr,24,CCSizeMake(self.txtSize*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
						height1=height1+contentLabel:getContentSize().height
					end
				end
			else
				local contentLabel=GetTTFLabelWrap(msg,24,CCSizeMake(self.txtSize*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				height1=contentLabel:getContentSize().height
			end

			-- local contentLabel=GetTTFLabelWrap(msg,25,CCSizeMake(self.txtSize*23,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			-- contentLabel:setAnchorPoint(ccp(0,1))

			-- local height1=contentLabel:getContentSize().height+200
			self.cellHight=height1+400
			do return self.cellHight end
		end
		local contentLbHight=0
		local report=emailVoApi:getReport(self.eid)
		if self.chatReport then
			report=self.chatReport
		end
		if report==nil then
			do return end
		end
		local rtype=report.type
		if rtype==3 then
			do return end
		end

		local islandType,attacker,defender,attackerAllianceName,defenderAllianceName,helpDefender,helpDefenderAllianceName,hasHelpDefender,aLandform,dLandform,landform=reportVoApi:formatReportData(report)
		local content=reportVoApi:getReportContent(report,self.chatSender)

		for k,v in pairs(content) do
			if content[k]~=nil and content[k]~="" then
				-- local contentMsg=content[k]
				-- local message=""
				-- if type(contentMsg)=="table" then
				-- 	message=contentMsg[1]
				-- else
				-- 	message=contentMsg
				-- end
    --             local contentLb
    --             --contentLb = GetTTFLabel(message,self.txtSize)
		  --     	contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(self.txtSize*22, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			 --    contentLb:setAnchorPoint(ccp(0,1))
				-- --local height = cellHeight-((k-1)*35)-60
				-- contentLbHight = contentLb:getContentSize().height+contentLbHight
				local contentMsg=content[k]
				local message=""
				local color
				if type(contentMsg)=="table" then
					message=contentMsg[1]
					color=contentMsg[2]
				else
					message=contentMsg
				end
				local contentLb
                local msgHeight=0
                if color and type(color)=="table" then
					contentLb,msgHeight=G_getRichTextLabel(message,color,self.txtSize,self.txtSize*22,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                else
                	contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(self.txtSize*22, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                	msgHeight=contentLb:getContentSize().height
                end
			    contentLb:setAnchorPoint(ccp(0,1))
			    contentLbHight = contentLbHight + msgHeight
			end
	    end
		self.cellHight=contentLbHight+80
		if report.resource and SizeOfTable(report.resource)>4 then
	    	self.cellHight=contentLbHight+80+45
	    end
	    if rtype==2 and report.islandType==7 then
	    	self.cellHight=self.cellHight-50
	    end
		return self.cellHight
	else
		return self.cellHight
	end
end
--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function emailDetailDialog:eventHandler(handler,fn,idx,cel)
	if (self.eid~=nil or self.chatReport) then
	else
		do return end
	end
	if fn=="numberOfCellsInTableView" then--rtype 1 战斗 2 侦查 3 返回报告 4 金矿采集返回报告 5 搜索雷达报告 6 间谍卫星报告
		if self.eid and (self.emailType==1 or self.emailType==3) then
			do return 1 end
		end
		local report=emailVoApi:getReport(self.eid)
		if self.chatReport then
			report=self.chatReport
		end
		if report==nil then
			do return end
		end
		local rtype=report.type
		local islandType=report.islandType
		if rtype==3 then
			do return end
		end
		if rtype==2 then
			if islandType==7 then
				return 2
			else
				return 3
			end
		elseif rtype==1 then
			if islandType==7 then
				return 4
			else
				local num=4
				if base.isGlory== 1 and report.report and report.report.bm then--繁荣度开启	
					num=num + 1
				end
				if emailVoApi:isShowHero(report) then
					num=num + 1
				end
				if emailVoApi:isShowAccessory(report) then
					num=num + 1
				end
				if emailVoApi:isShowEmblem(report)== true then
					num = num + 1
				end
				if G_isShowPlaneInReport(report,1)== true then
					num = num + 1
				end
				return num
			end
		elseif rtype==4 then
			return 2
		elseif rtype==5 then
			return 1
		elseif rtype==6 then
			local searchtype=report.searchtype
			if searchtype and searchtype==1 then
				return 2
			else
				return 1
			end
		elseif rtype==7 or rtype==8 then
			return 2
		end
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		local width=400
		local height=30
		if self.eid and (self.emailType==1 or self.emailType==3) then
			height = self:getcellhight()
			tmpSize=CCSizeMake(width,height)
			do return tmpSize end
		end
		local report=emailVoApi:getReport(self.eid)
		if self.chatReport then
			report=self.chatReport
		end
		if report==nil then
			do return end
		end
		local gloryBm = {} --取到攻守双方的繁荣度值
		if base.isGlory ==1 and report.report and report.report.bm then
			gloryBm =report.report.bm
		end
		local rtype=report.type
		if rtype==3 then
			do return end
		end
		if idx==0 then
			height = self:getcellhight()
		elseif idx==1 then
			if rtype==2 then
				if report.islandType==7 then --叛军侦查报告
					if base.landFormOpen==1 and base.richMineOpen==1 and report.richLevel and report.richLevel>0 and base.alien==1 then
						height=770+50
					else
						height=770
					end
					self.cellHeightTb[idx+1]=height
				elseif report.islandType==6 then
					-- height=80*5-30+50
					-- height=420
					local resCount=SizeOfTable(report.resource)
					if resCount>0 then
						height=resCount*60+(resCount-1)*10+90
					else
						height=50
					end
					self.cellHeightTb[idx+1]=height
				elseif report.islandType<6 then
					self.output=worldBaseVoApi:getMineResContent(report.islandType,report.level,report.richLevel,report.goldMineLv,false)
					local resCount=SizeOfTable(self.output)
					local addHeight=0
					local textSize=45
					if resCount%2==0 then
						addHeight=(resCount/2)*45
					else
						addHeight=(resCount/2+1)*45
					end
					if report.islandOwner>0 then
						local collectCount=SizeOfTable(report.resource)
						local resHeight=0
						if collectCount%2==0 then
							resHeight=(collectCount/2)*45
						else
							resHeight=(collectCount/2+1)*45
						end
						addHeight=addHeight+resHeight
						textSize=textSize*2
					end
					if resCount>0 then
						height=50+textSize+addHeight
					else
						height=50
					end
					self.cellHeightTb[idx+1]=height
				end
			elseif rtype==4 then --采集资源部队返回	
				local resCount=SizeOfTable(report.resource)
				local addHeight=0
				if resCount%2==0 then
					addHeight=(resCount/2)*80
				else
					addHeight=(resCount/2+1)*80
				end
				height=190+addHeight
				self.cellHeightTb[idx+1]=height
			elseif rtype==6 then --间谍卫星报告
				height=550
				self.cellHeightTb[idx+1]=height
			elseif rtype==1 and report.islandType==7 then --攻打世界叛军战斗报告
				height=235+20
				local rebelData=report.rebel or {}
				local attNum=rebelData.attNum or 0
				if attNum and attNum>0 then
					local lbx=(self.bgLayer:getContentSize().width-50)/2
	            	local buff=rebelCfg.attackBuff*100*attNum
	            	local buffLb=GetTTFLabel(getlocal("worldRebel_comboBuff",{buff.."%%"}),24)
		            local attNumStr=getlocal("email_report_rebel_attack_num",{attNum})
		            -- attNumStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
					local colorTab={G_ColorWhite,G_ColorGreen,G_ColorWhite}
					local attNumLb,lbHeight=G_getRichTextLabel(attNumStr,colorTab,25,(self.bgLayer:getContentSize().width-60)/2,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
					height=height+buffLb:getContentSize().height+lbHeight+50-20
				end
				self.cellHeightTb[idx+1]=height
			else
				if report.award or report.acaward then
					local award={}
					if report.award.u or report.award.p then
						award=FormatItem(report.award,false)
					else
						award=report.award
					end

                    local acaward = {}
					if report.acaward ~= nil then
						acaward = report.acaward
					end
					if self.awardHeight==nil then
						self.awardHeight=math.floor((SizeOfTable(award)+SizeOfTable(acaward)+1)/2)*110+50
					end
					height=self.awardHeight
				else
					height=50
				end
				self.cellHeightTb[idx+1]=height
			end
		elseif idx==2 then
			if rtype==1 and report.islandType==7 then
				if report.award then
					local award={}
					if report.award.u or report.award.p then
						award=FormatItem(report.award,false)
					else
						award=report.award
					end

                    local acaward = {}
					if report.acaward ~= nil then
						acaward = report.acaward
					end
					if self.awardHeight==nil then
						self.awardHeight=math.floor((SizeOfTable(award)+SizeOfTable(acaward)+1)/2)*110+50
					end
					height=self.awardHeight
				else
					height=50
				end
				self.cellHeightTb[idx+1]=height
			elseif rtype==2 then
				if base.landFormOpen==1 and base.richMineOpen==1 and report.richLevel and report.richLevel>0 and base.alien==1 then
					height=770+50
				else
					height=770
				end
				self.cellHeightTb[idx+1]=height
			else
				-- height=80*5-10+50
				if base.isGlory ==1 and SizeOfTable(gloryBm) > 0 then
					height = 220
				else
					if report.resource.u or report.resource.r then
						report.resource=FormatItem(report.resource)
					end
					local resCount=SizeOfTable(report.resource)
					if resCount>0 then
						height=resCount*70+80
					else
						height=50
					end
				end
				self.cellHeightTb[idx+1]=height
			end
		elseif idx==3 or idx==4 or idx==5 or idx ==6 or idx==7 or idx==8 then
			--return:1.glory繁荣度，2.军徽，3.hero，4.accessory，5.lostTanks，6.侦查地方部队信息，7.战斗掠夺资源，8.飞机
			if rtype==1 then
				local showType=self:getShowType(report,idx)
				if showType==1 then
					if report.resource.u or report.resource.r then
						report.resource=FormatItem(report.resource)
					end
					local resCount=SizeOfTable(report.resource)
					if resCount>0 then
						height=resCount*70+80
					else
						height=50
					end
				elseif showType==2 then
					height=410
				elseif showType==3 then
					height=530
				elseif showType==4 then
					height=self:getReportAccessoryhight(report)
				elseif showType==5 then
					local attackerLostNum=0
					local defenderLostNum=0
					local attackerTotalNum=0
					local defenderTotalNum=0
					local attLost={}
					local defLost={}
					if report.lostShip.attackerTotal then
						if report.lostShip.attackerTotal.o then
							attackerTotalNum=SizeOfTable(report.lostShip.attackerTotal.o)
						else
							attackerTotalNum=SizeOfTable(report.lostShip.attackerTotal)
						end
					end
					if report.lostShip.defenderTotal then
						if report.lostShip.defenderTotal.o then
							defenderTotalNum=SizeOfTable(report.lostShip.defenderTotal.o)
						else
							defenderTotalNum=SizeOfTable(report.lostShip.defenderTotal)
						end
					end
					if report.lostShip.attackerLost then
						if report.lostShip.attackerLost.o then
							attackerLostNum=SizeOfTable(report.lostShip.attackerLost.o)
						else
							attackerLostNum=SizeOfTable(report.lostShip.attackerLost)
						end
					end
					if report.lostShip.defenderLost then
						if report.lostShip.defenderLost.o then
							defenderLostNum=SizeOfTable(report.lostShip.defenderLost.o)
						else
							defenderLostNum=SizeOfTable(report.lostShip.defenderLost)
						end
					end
					-- if report.lostShip.attackerLost then
					-- 	attackerLostNum=SizeOfTable(report.lostShip.attackerLost)
					-- end
					-- if report.lostShip.defenderLost then
					-- 	defenderLostNum=SizeOfTable(report.lostShip.defenderLost)
					-- end
					-- height=(self.txtSize+30)*(4+attackerTotalNum+defenderTotalNum)+50
					if attackerTotalNum>0 or defenderTotalNum>0 then
						height=(self.txtSize+30)*(4+attackerTotalNum+defenderTotalNum)+50
					else
						height=(self.txtSize+10)*(4+attackerLostNum+defenderLostNum)+50
					end
				elseif showType==8 then
					height=380
				end
				self.cellHeightTb[idx+1]=height
			end
		end
		tmpSize=CCSizeMake(width,height)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		if self.eid and (self.emailType==1 or self.emailType==3) then

			local cell=CCTableViewCell:new()
			cell:autorelease()

			local emailVo
			if self.eid and self.emailType then
				emailVo=emailVoApi:getEmailByEid(self.emailType,self.eid)
			end
			local msg=""
			if emailVo and emailVo.content then 
				if type(emailVo.content)=="table" and emailVo.content.content then
					msg=emailVo.content.content
				else
					msg=emailVo.content
				end
			end
			-- msg="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
			while string.find(msg,"\\n")~=nil do
				local startIdx,endIdx=string.find(msg,"\\n")
				msg=string.sub(msg,1,startIdx-1).."\n"..string.sub(msg,endIdx+1)
			end
			local height1 = self:getcellhight()

			local isHasUrl=false
			local messageTb={}

			if self.emailType==1 and (tostring(emailVo.sender)=="0" or tostring(emailVo.sender)=="1" or tostring(emailVo.sender)=="2") then 
				local strLen=string.len(msg)			
				local wz=msg
				local endMsg=""
				while string.find(wz,"#(.-)#")~=nil do
					isHasUrl=true
					local startIdx,endIdx=string.find(wz,"#(.-)#")

					local firstStr=""
					local endStr=""
					if startIdx>1 then
						firstStr=string.sub(wz,1,startIdx-1)
					end
					if endIdx<strLen then
						endStr=string.sub(wz,endIdx+1)
					end
					if endIdx-startIdx>1 then
			            local newKey=string.sub(wz,startIdx+1,endIdx-1)
			            -- wz=firstStr..getlocal(newKey)..endStr
			            table.insert(messageTb,{firstStr,0})
						table.insert(messageTb,{newKey,1})
					-- else
					-- 	wz=firstStr..endStr
					end
					wz=endStr
					endMsg=endStr
				end
				if endMsg and endMsg~="" then
					table.insert(messageTb,{endMsg,0})
				end
			end

			local posY=height1-5
			if isHasUrl==true and messageTb and SizeOfTable(messageTb)>0 then
				for k,v in pairs(messageTb) do
					local msgStr=v[1]
					local isUrl=v[2]
					if isUrl and isUrl==1 then
						local function jumpToHandler()
							local tmpTb={}
				            tmpTb["action"]="openUrl"
				            tmpTb["parms"]={}
				            tmpTb["parms"]["url"]=msgStr
				            local cjson=G_Json.encode(tmpTb)
				            G_accessCPlusFunction(cjson)
						end
						local contentLabel=GetTTFLabelWrap(msgStr,24,CCSizeMake(self.txtSize*23-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
					    contentLabel:setColor(G_ColorOrange2)
					    local meunItem = CCMenuItemLabel:create(contentLabel)
					    meunItem:setAnchorPoint(ccp(0,1))
					    meunItem:registerScriptTapHandler(jumpToHandler)
					    local menu = CCMenu:createWithItem(meunItem)
					    menu:setAnchorPoint(ccp(0,1))
					    menu:setPosition(5,posY)
					    cell:addChild(menu,2)
					    posY=posY-meunItem:getContentSize().height
					else
						local contentLabel=GetTTFLabelWrap(msgStr,24,CCSizeMake(self.txtSize*23-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
						contentLabel:setAnchorPoint(ccp(0,1))
						contentLabel:setPosition(ccp(5,posY))
						cell:addChild(contentLabel,2)
						posY=posY-contentLabel:getContentSize().height
					end
				end
			else
				local contentLabel=GetTTFLabelWrap(msg,24,CCSizeMake(self.txtSize*23-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				contentLabel:setAnchorPoint(ccp(0,1))
				contentLabel:setPosition(ccp(5,height1-5))
				cell:addChild(contentLabel,2)
			end

			do return cell end
		end

		local report=emailVoApi:getReport(self.eid)
		if self.chatReport then
			report=self.chatReport
		end
		if report==nil then
			do return end
		end
		local gloryBm = {} --取到攻守双方的繁荣度值
		if base.isGlory ==1 and report.report and report.report.bm then
			gloryBm =report.report.bm
			-- print("SizeOfTable-->gloryBm-->",SizeOfTable(gloryBm))
		end

		local rtype=report.type
		if rtype==3 then
			do return end
		end
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local function addAward(repData,cell1,bg,titleLb)
			local report1=repData
			local award={}
			local acAward = {}
			if report1.award.u or report1.award.p then
				award=FormatItem(report1.award,false) or {}
			else
				award=report1.award or {}
			end
			if report1.acaward ~= nil then
				acAward = report1.acaward or {}
			end
            
            local acAwardLen = SizeOfTable(acAward)

			-- if SizeOfTable(award)==0 then
			if SizeOfTable(award) + acAwardLen == 0 then
				if rtype==8 then
					titleLb=GetTTFLabel(getlocal("def_content_target_reward")..getlocal("fight_content_null"),24)
				else
					titleLb=GetTTFLabel(getlocal("fight_content_fight_award")..getlocal("fight_content_null"),24)
				end
			else
				if rtype==8 then
					titleLb=GetTTFLabel(getlocal("def_content_target_reward"),24)
				else
					titleLb=GetTTFLabel(getlocal("fight_content_fight_award"),24)
				end
			end

			local hnum=math.floor((SizeOfTable(award)+ acAwardLen+1)/2)--math.floor((SizeOfTable(award)+1)/2)
			local sizeLb=hnum*110

			local i = 1

			-- for k,v in pairs(award) do
			-- 	if v and v.pic and v.name and v.num then
			-- 		local width = 20+((k-1)%2)*280
			-- 		local height = sizeLb-(math.floor((k+1)/2))*100+5
			-- 		local icon = CCSprite:createWithSpriteFrameName(v.pic)
			--         icon:setAnchorPoint(ccp(0,0))
			--       	icon:setPosition(ccp(width,height))
			-- 		cell1:addChild(icon,2)
			-- 		if icon:getContentSize().width>100 then
			-- 			icon:setScaleX(100/150)
			-- 			icon:setScaleY(100/150)
			-- 		end
			-- 		icon:setScaleX(0.75)
			-- 		icon:setScaleY(0.75)

			-- 		local nameLable = GetTTFLabelWrap((v.name),24,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			--         nameLable:setAnchorPoint(ccp(0,0.5))
			--         nameLable:setPosition(ccp(width+icon:getContentSize().width,height+15))
			-- 		cell1:addChild(nameLable,2)

			-- 		local numLable = GetTTFLabel(v.num,24)
			--         numLable:setAnchorPoint(ccp(0,0))
			--         numLable:setPosition(ccp(width+icon:getContentSize().width,height+50))
			-- 		cell1:addChild(numLable,2)
			-- 		i = i + 1
			-- 	end
			-- end
			local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
            local expTb =Split(playerCfg.level_exps,",")
            local maxExp = expTb[maxLevel] --当前服 最大经验值
            local playerExp = playerVoApi:getPlayerExp() --用户当前的经验值
            local isShowGems = false --用于满级后的水晶数量

            local iSize=75
			for k,v in pairs(award) do
				if v and v.pic and v.name and v.num then
					if v.name ==getlocal("sample_general_exp") and base.isConvertGems==1 and tonumber(playerExp) >=tonumber(maxExp) then
						isShowGems =true
					else
						isShowGems =false
					end

					local width = 20+((k-1)%2)*280
					local height = sizeLb-(math.floor((k+1)/2))*100+5
					local icon =nil
					if isShowGems then
						icon =CCSprite:createWithSpriteFrameName("resourse_normal_gold.png")
					elseif v.type =="t" then
						icon = G_getItemIcon(v,100,false) --万圣节活动使用
					else
						-- icon = CCSprite:createWithSpriteFrameName(v.pic)
						icon = G_getItemIcon(v,100,false)
					end

			        icon:setAnchorPoint(ccp(0,0))
			      	icon:setPosition(ccp(width,height))
					cell1:addChild(icon,2)
					-- if icon:getContentSize().width>100 then
					-- 	icon:setScaleX(100/150)
					-- 	icon:setScaleY(100/150)
					-- end
					-- icon:setScaleX(0.75)
					-- icon:setScaleY(0.75)
					icon:setScaleX(iSize/icon:getContentSize().width)
	                icon:setScaleY(iSize/icon:getContentSize().height)

					local nameLable 
					if isShowGems then
						nameLable = GetTTFLabelWrap(getlocal("money"),24,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
					else
						nameLable = GetTTFLabelWrap((v.name),24,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
					end
			        nameLable:setAnchorPoint(ccp(0,0.5))
			        nameLable:setPosition(ccp(width+iSize+20,height+15))
					cell1:addChild(nameLable,2)

					local numLable
					if isShowGems then
						numLable = GetTTFLabel(playerVoApi:convertGems(1,v.num),24)
					else
						numLable = GetTTFLabel(v.num,24)
					end
			        numLable:setAnchorPoint(ccp(0,0))
			        numLable:setPosition(ccp(width+iSize+20,height+50))
					cell1:addChild(numLable,2)
					i = i + 1
				end
			end
			
			for k1,v1 in pairs(acAward) do
				local width = 20+((i-1)%2)*280
				local height = sizeLb-(math.floor((i+1)/2))*100+5
				local pCfg = nil
                local icon
                if string.sub(k1,1,1) == "s" and k1 ~= "stormFortressMissile" then
                    pCfg = acMiBaoVoApi:getPieceCfgForShowBySid(k1)
                    icon = CCSprite:createWithSpriteFrameName(pCfg.icon)

				end
				if k1 =="stormFortressMissile" then
					pCfg = acStormFortressVoApi:getTurkeyCfgForShow()
					icon= CCSprite:createWithSpriteFrameName("Icon_BG.png")
					-- acStormFortressVoApi:setCurrentBullet(nil,1)
					local function timeIconClick( ... )
                    end
                    local addIcon = LuaCCSprite:createWithSpriteFrameName(pCfg.icon,timeIconClick)
                    addIcon:setPosition(getCenterPoint(icon))
                    icon:addChild(addIcon)
                elseif k1=="jidongbudui_mm_m1" then
                    pCfg = acJidongbuduiVoApi:getTurkeyCfgForShow()
                    icon= CCSprite:createWithSpriteFrameName("Icon_BG.png")
                    
                    local function timeIconClick( ... )
                    end
                    local addIcon = LuaCCSprite:createWithSpriteFrameName(pCfg.icon,timeIconClick)
                    addIcon:setPosition(getCenterPoint(icon))
                    icon:addChild(addIcon)
                end

		        icon:setAnchorPoint(ccp(0,0))
		      	icon:setPosition(ccp(width,height))
				cell1:addChild(icon,2)
				-- if icon:getContentSize().width>100 then
				-- 	icon:setScaleX(100/150)
				-- 	icon:setScaleY(100/150)
				-- end
                
                icon:setScaleX(iSize/icon:getContentSize().width)
                icon:setScaleY(iSize/icon:getContentSize().height)

				local nameLable = GetTTFLabelWrap(getlocal(pCfg.name),24,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		        nameLable:setAnchorPoint(ccp(0,0.5))
		        nameLable:setPosition(ccp(width+iSize+20,height+15))
				cell1:addChild(nameLable,2)

				local numLable = GetTTFLabel(v1,24)
		        numLable:setAnchorPoint(ccp(0,0))
		        numLable:setPosition(ccp(width+iSize+20,height+50))
				cell1:addChild(numLable,2)
				i = i + 1
			end
			if bg then
				bg:setPosition(ccp(0, sizeLb))
			end
			return titleLb
		end

		local islandType,attacker,defender,attackerAllianceName,defenderAllianceName,helpDefender,helpDefenderAllianceName,hasHelpDefender,aLandform,dLandform,landform=reportVoApi:formatReportData(report)

		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
		end
		if idx==0 then
            local backSprie1=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
		    backSprie1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
		    backSprie1:ignoreAnchorPointForPosition(false)
		    backSprie1:setAnchorPoint(ccp(0,0))
		    backSprie1:setIsSallow(false)
		    backSprie1:setTouchPriority(-(self.layerNum-1)*20-2)
		    cell:addChild(backSprie1,1)
			print("rtype",rtype)
			local titleLabel
			local content=reportVoApi:getReportContent(report,self.chatSender)
			local cellHeight = self:getcellhight()
			if rtype==2 then
				backSprie1:setPosition(ccp(0, cellHeight-60))
				titleLabel=GetTTFLabel(getlocal("scout_content_target_info"),24)
			elseif rtype==1 then
				backSprie1:setPosition(ccp(0, cellHeight-60))
				titleLabel=GetTTFLabel(getlocal("fight_content_fight_info"),24)
			elseif rtype==4 or rtype==5 or rtype==7 then
				backSprie1:setPosition(ccp(0, cellHeight-60))
				titleLabel=GetTTFLabel(getlocal("scout_content_target_info"),24)
			elseif rtype==6 then
				backSprie1:setPosition(ccp(0, cellHeight-60))
				titleLabel=GetTTFLabel(getlocal("forceInformation"),24)

				local searchtype=report.searchtype
				if searchtype==1 then
					if report.resource and SizeOfTable(report.resource)>0 then
						if report.resource.u or report.resource.r then
							report.resource=FormatItem(report.resource)
						end
						local resourceTab={}
						for k,v in pairs(report.resource) do
							if v and v.num and v.num>0 then
								table.insert(resourceTab,v)
							end
						end
						local resNum=SizeOfTable(resourceTab)
						if resNum>0 then
							for k,v in pairs(resourceTab) do
								local px,py
								if resNum>4 then
									px,py=140+((k-1)%4)*130,110-50*((math.ceil(k/4))-1)
								else
									px,py=140+((k-1)%4)*130,65
								end
								local resIcon=G_getNoBgResIcon(v)
								if resIcon then
						    		resIcon:setPosition(ccp(px-30,py))
						    		cell:addChild(resIcon,1)
						    		local resNumLb=GetTTFLabel(FormatNumber(v.num),24)
						    		resNumLb:setPosition(ccp(px+20,py))
						    		cell:addChild(resNumLb,1)
						    	end
					    	end
						end
					end
				else
					backSprie1:setVisible(false)
					titleLabel:setVisible(false)
				end
			elseif rtype==8 then
				backSprie1:setPosition(ccp(0, cellHeight-60))
				titleLabel=GetTTFLabel(getlocal("def_content_target_info"),30)
			end
			if titleLabel then
				titleLabel:setPosition(getCenterPoint(backSprie1))
				backSprie1:addChild(titleLabel,2)
			end
			local contentLbHight=0
			for k,v in pairs(content) do
				if content[k]~=nil and content[k]~="" then
					local contentMsg=content[k]
					local message=""
					local color
					if type(contentMsg)=="table" then
						message=contentMsg[1]
						color=contentMsg[2]
					else
						message=contentMsg
					end
                    local contentLb
                    local msgHeight=0
                    if color and type(color)=="table" then
						contentLb,msgHeight=G_getRichTextLabel(message,color,self.txtSize,self.txtSize*22,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    else
                    	contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(self.txtSize*22, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    	msgHeight=contentLb:getContentSize().height
                    	if color~=nil then
					        contentLb:setColor(color)
					    end
                    end
				    contentLb:setAnchorPoint(ccp(0,1))
					if contentLbHight==0 then
						contentLbHight = cellHeight-60
					end
				    contentLb:setPosition(ccp(20,contentLbHight))
				    contentLbHight = contentLbHight - msgHeight
				    cell:addChild(contentLb,1)
				end
		    end
		elseif idx==1 then
            local backSprie2=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
		    backSprie2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
		    backSprie2:ignoreAnchorPointForPosition(false)
		    backSprie2:setAnchorPoint(ccp(0,0))
		    backSprie2:setIsSallow(false)
		    backSprie2:setTouchPriority(-(self.layerNum-1)*20-2)
		    cell:addChild(backSprie2,1)

			local titleLabel2
			if rtype==2 then
				if report.islandType==7 then
					titleLabel2=GetTTFLabel(getlocal("alliance_challenge_enemy_info"),24)
					backSprie2:setPosition(ccp(0, self.cellHeightTb[idx+1]-backSprie2:getContentSize().height))
					local sizeLb=self.cellHeightTb[idx+1]-backSprie2:getContentSize().height-110
					local shipTab=report.defendShip
					for k=1,6 do
						local width = self.bgLayer:getContentSize().width-(math.ceil(k/3))*280
						local height = sizeLb-(((k-1)%3)*220+60)

						local function touchClick(hd,fn,idx)
						end
						local bgSp =LuaCCScale9Sprite:createWithSpriteFrameName("BgEmptyTank.png",CCRect(10, 10, 20, 20),touchClick)
						bgSp:setContentSize(CCSizeMake(150, 150))
						bgSp:ignoreAnchorPointForPosition(false)
						bgSp:setAnchorPoint(ccp(0,0))
						bgSp:setIsSallow(false)
						bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
						bgSp:setPosition(ccp(width,height))
						cell:addChild(bgSp,1)
						
						local v
						if shipTab then
							v=shipTab[k]
						end
						if v and v.pic and v.name and v.num then
							local icon = CCSprite:createWithSpriteFrameName(v.pic)
							icon:setPosition(getCenterPoint(bgSp))
							bgSp:addChild(icon,2)

							if G_pickedList(tonumber(RemoveFirstChar(v.key))) ~= tonumber(RemoveFirstChar(v.key)) then
					             local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
					            icon:addChild(pickedIcon)
					            pickedIcon:setPosition(icon:getContentSize().width*0.7,icon:getContentSize().height*0.5-10)
					        end
							
							local str=(v.name).."("..FormatNumber(v.num)..")"
							local descLable = GetTTFLabelWrap(str,self.txtSize,CCSizeMake(self.txtSize*10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
					        descLable:setAnchorPoint(ccp(0.5,1))
							descLable:setPosition(ccp(width+bgSp:getContentSize().width/2,height))
							cell:addChild(descLable,2)
						end
					end
				elseif report.islandType==6 then
					titleLabel2=GetTTFLabel(getlocal("fight_content_resource_info"),24)
					local sizeLb=self.cellHeightTb[idx+1]-backSprie2:getContentSize().height-20
					local resource=report.resource
					for k,v in pairs(resource) do
						if v and v.pic and v.name and v.num then
							local width = 30
							local height = sizeLb-k*60
							local icon = CCSprite:createWithSpriteFrameName(v.pic)
					        icon:setAnchorPoint(ccp(0,0))
					      	icon:setPosition(ccp(width,height-(k-1)*10))
							cell:addChild(icon,2)
							if icon:getContentSize().width>100 then
								icon:setScaleX(100/150)
								icon:setScaleY(100/150)
							end
							icon:setScaleX(0.6)
							icon:setScaleY(0.6)
						
							local str=getlocal("scout_content_player_plunder",{(v.name),FormatNumber(v.num)})
							local numLable=GetTTFLabelWrap(str,self.txtSize,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
					        numLable:setAnchorPoint(ccp(0,0.5))
					        numLable:setScaleX(1/0.6)
					        numLable:setScaleY(1/0.6)
					        numLable:setPosition(ccp(icon:getContentSize().width+15,icon:getContentSize().height/2))
							icon:addChild(numLable,2)
						end
					end
					backSprie2:setPosition(ccp(0, self.cellHeightTb[idx+1]-backSprie2:getContentSize().height))
				elseif report.islandType>0 and report.islandType<6 then
					titleLabel2=GetTTFLabel(getlocal("fight_content_resource_info"),24)	
					backSprie2:setPosition(ccp(0,self.cellHeightTb[idx+1]-backSprie2:getContentSize().height))				
					--显示资源列表
				    local posY=self.cellHeightTb[idx+1]-backSprie2:getContentSize().height-20
					local function initResInfo(showType,picName,resName,value,posX,posY,scale)
				        local resSp = CCSprite:createWithSpriteFrameName(picName)
				        resSp:setScale(scale)
				        resSp:setPosition(ccp(posX,posY))
				        cell:addChild(resSp)

				        local resNameLb=GetTTFLabel(resName.."：",24)
				        resNameLb:setAnchorPoint(ccp(0,0.5))
				        resNameLb:setPosition(ccp(posX+30,resSp:getPositionY()))
				        cell:addChild(resNameLb)
				        local valueStr
				        if showType==1 then
				        	valueStr=FormatNumber(value).."/h"
				        else
				        	valueStr=FormatNumber(value)
				        end
				        if valueStr then
				        	valueStr=replaceIllegal(valueStr)
				        	local resCountLb=GetTTFLabel(valueStr,24)
					        resCountLb:setAnchorPoint(ccp(0,0.5))
					        resCountLb:setPosition(ccp(resNameLb:getPositionX()+resNameLb:getContentSize().width-10,resNameLb:getPositionY()))
					        cell:addChild(resCountLb)
				        end
					end

					local function showResources(showType,resTb)
						if resTb==nil then
							do return end
						end
						local resIdx=0
						local posX=0
						local resCount=SizeOfTable(resTb)
						for k,v in pairs(resTb) do
							resIdx=resIdx+1
							if resIdx%2==0 then
								posX=320
							else
								posX=20
							end
							local scale=1
							if v.type=="u" then
								scale=1.2
							elseif v.type=="r" then
								scale=0.5
							end
							if showType==1 then
								initResInfo(showType,v.pic,v.name,v.speed,posX,posY,scale)
							else
								initResInfo(showType,v.pic,v.name,v.num,posX,posY,scale)
							end
							if resIdx%2==0 and resIdx~=resCount then
								posY=posY-45
							end
						end
					end

					local proStr
					local strColor=G_ColorWhite
					if (base.wl==1 and base.goldmine==1 and report.goldMineLv and report.goldMineLv>0) then
						proStr=getlocal("goldmine_output_effect")
						strColor=G_ColorYellowPro
					elseif (base.landFormOpen==1 and base.richMineOpen==1 and report.richLevel and report.richLevel>0) then
						proStr=getlocal("richmine_output_effect")
						strColor=worldBaseVoApi:getRichMineColorByLv(report.richLevel)
					else
						proStr=getlocal("custom_output_effect")
					end
					if proStr then
					    local mineResLb=GetTTFLabel(proStr,24)
				        mineResLb:setAnchorPoint(ccp(0,0.5))
				        mineResLb:setColor(strColor)
				        mineResLb:setPosition(ccp(10,posY))
				        cell:addChild(mineResLb)
					end		
			        posY=posY-40
					showResources(1,self.output)
			        posY=posY-30


					if report.islandOwner>0 then
				        local gatherLb=GetTTFLabel(getlocal("gather_output_defend"),24)
				        gatherLb:setAnchorPoint(ccp(0,1))
				        gatherLb:setPosition(ccp(10,posY))
				        gatherLb:setColor(G_ColorYellowPro)
				        cell:addChild(gatherLb)
				        posY=posY-55
						showResources(2,report.resource)
					end
				end
			elseif rtype==1 then
				if report.islandType==7 then
					backSprie2:setPosition(ccp(0,self.cellHeightTb[idx+1]-backSprie2:getContentSize().height))		
					titleLabel2=GetTTFLabel(getlocal("fight_content_fight_info"),24)

					local rebelData=report.rebel or {}
					local pic=rebelData.pic or 1
					local multiNum=rebelData.multiNum or 0
					local rebelLv=rebelData.rebelLv or 1
					local rebelID=rebelData.rebelID or 1
					local rebelTotalLife=rebelData.rebelTotalLife or 0
					local rebelLeftLife=rebelData.rebelLeftLife or 0
					local reduceLife=rebelData.reduceLife or 0
					local attNum=rebelData.attNum or 0
					local tankId=rebelVoApi:getRebelIconTank(rebelLv,rebelID)
					local rpic=rebelData.rpic or 1

					local lby=0
					if attNum and attNum>0 then
		            	local lbx=(self.bgLayer:getContentSize().width-50)/2
		            	local buff=rebelCfg.attackBuff*100*attNum
		            	local buffLb=GetTTFLabel(getlocal("worldRebel_comboBuff",{buff.."%%"}),24)
		            	lby=buffLb:getContentSize().height+10
		            	buffLb:setAnchorPoint(ccp(0.5,1))
					    buffLb:setPosition(ccp(lbx,lby))
					    buffLb:setColor(G_ColorGreen)
						cell:addChild(buffLb,1)
		            	
			            local attNumStr=getlocal("email_report_rebel_attack_num",{attNum})
			            -- attNumStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
						local colorTab={G_ColorWhite,G_ColorGreen,G_ColorWhite}
						local attNumLb,lbHeight=G_getRichTextLabel(attNumStr,colorTab,25,(self.bgLayer:getContentSize().width-60)/2,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
						-- print("lbHeight",lbHeight)
						lby=lby+buffLb:getContentSize().height/2+lbHeight-10
		                attNumLb:setAnchorPoint(ccp(0.5,1))
		                attNumLb:setPosition(ccp(lbx,lby))
		                cell:addChild(attNumLb,1)

		                lby=lby+10
			            local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
						lineSp:setScale((self.bgLayer:getContentSize().width-50)/lineSp:getContentSize().width)
						lineSp:setPosition(ccp(lbx,lby))
						cell:addChild(lineSp,1)
					end

					local poy=105+lby
					local vsSp=CCSprite:createWithSpriteFrameName("awVS.png")
				    vsSp:setPosition(ccp((self.bgLayer:getContentSize().width-50)/2,poy))
				    cell:addChild(vsSp,1)

				    local iconSize=100
				    local lpx=140
					local photoName=playerVoApi:getPersonPhotoName(pic)
					local photoSp=playerVoApi:GetPlayerBgIcon(photoName,nil,nil,nil,iconSize)
					photoSp:setPosition(ccp(lpx,poy))
					cell:addChild(photoSp,1)
					if multiNum and multiNum>1 then
						local numStr=getlocal("email_report_rebel_multiple_num",{multiNum})
						-- numStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
						local colorTab={G_ColorWhite,G_ColorGreen,G_ColorWhite}
						local numLb,lbHeight=G_getRichTextLabel(numStr,colorTab,25,(self.bgLayer:getContentSize().width-60)/2,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		                numLb:setAnchorPoint(ccp(0.5,1))
		                numLb:setPosition(ccp(lpx,poy-75+lbHeight/2))
	                    cell:addChild(numLb,1)
	                end

	                if tankId then
	                	local rebelSp
        	          	local rpx=(self.bgLayer:getContentSize().width-50)/2+150
	                	local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
	                	if rpic and rpic>=100 then
	                		local picName=rebelVoApi:getSpecialRebelPic(rpic)
	                		if picName then
	                			rebelSp=CCSprite:createWithSpriteFrameName(picName)
	                		end
	                	end
	                	if rebelSp==nil then
		                	rebelSp=tankVoApi:getTankIconSp(tid,nil,nil,false)--CCSprite:createWithSpriteFrameName(tankCfg[tid].icon)
	                	end
	                	if rebelSp then
        				    rebelSp:setScale(iconSize/rebelSp:getContentSize().width)
						    rebelSp:setAnchorPoint(ccp(0.5,0.5))
						    rebelSp:setPosition(ccp(rpx,poy))
						    cell:addChild(rebelSp,1)
	                	end
					    local lvTipBg=CCSprite:createWithSpriteFrameName("rebelIconLevel.png")
	                    -- lvTipBg:setPosition(ccp(rpx-85,poy+70))
	                    cell:addChild(lvTipBg,2)
	                    local lvLb=GetTTFLabel(rebelLv,24)
	                    lvLb:setPosition(getCenterPoint(lvTipBg))
	                    lvTipBg:addChild(lvLb)


					    local scalex=0.5
					    local leftPer=(rebelLeftLife/rebelTotalLife)*100
	                    local scheduleStr=""
	                    if leftPer>0 and leftPer<1 then
	                        scheduleStr="1%"
	                    else
	                    	-- scheduleStr=math.floor(leftPer).."%"
	                    	scheduleStr=G_keepNumber(leftPer,0).."%"
	                    end
	                    -- local scheduleStr=FormatNumber(rebelLeftLife).."/"..FormatNumber(rebelTotalLife)
					    AddProgramTimer(cell,ccp(rpx+lvTipBg:getContentSize().width/2-5,poy+70),11,12,scheduleStr,"rebelProgressBg.png","rebelProgress.png",13,scalex,1,nil,nil,20)
				        local per=(rebelLeftLife/rebelTotalLife)*100
				        local timerSpriteLv=cell:getChildByTag(11)
				        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
				        timerSpriteLv:setPercentage(per)
				        local lb=tolua.cast(timerSpriteLv:getChildByTag(12),"CCLabelTTF")
				        lb:setScaleX(1/scalex)
				        -- lb:setString(rebelLeftLife.."/"..rebelTotalLife)
				        local reducePer=(reduceLife/rebelTotalLife)*100
				        reducePer=string.format("%.2f", reducePer)
				        local perLb=GetTTFLabel("-"..reducePer.."%",24)
				        perLb:setAnchorPoint(ccp(0.5,0.5))
					    perLb:setPosition(ccp(rpx,poy-75))
					    perLb:setColor(G_ColorRed)
						cell:addChild(perLb,1)

	                    -- lvTipBg:setPosition(ccp(rpx-85,poy+70))
	                    lvTipBg:setPosition(ccp(rpx-timerSpriteLv:getContentSize().width/2*scalex-5,poy+70))
		            end
		        else
					titleLabel2=addAward(report,cell,backSprie2,titleLabel2)
				end
			elseif rtype==4 then
				backSprie2:setPosition(ccp(0,self.cellHeightTb[idx+1]-backSprie2:getContentSize().height))		
				titleLabel2=GetTTFLabel(getlocal("resource_gather_pro"),24)
				
			    local posY=backSprie2:getPositionY()-backSprie2:getContentSize().height-20
				local function initResInfo(picName,resName,value,posX,posY,scale)
			        local resSp = CCSprite:createWithSpriteFrameName(picName)
			        resSp:setScale(scale)
			        resSp:setPosition(ccp(posX,posY))
			        resSp:setAnchorPoint(ccp(0,0.5))
			        cell:addChild(resSp)

			        local resNameLb=GetTTFLabel(resName.."：",24)
			        resNameLb:setAnchorPoint(ccp(0,1))
			        resNameLb:setPosition(ccp(posX+resSp:getContentSize().width+10,posY+resSp:getContentSize().height*resSp:getScaleY()/2))
			        cell:addChild(resNameLb)
	
		        	local resCountLb=GetTTFLabel(FormatNumber(value),24)
			        resCountLb:setAnchorPoint(ccp(0,1))
			        resCountLb:setPosition(ccp(resNameLb:getPositionX(),resNameLb:getPositionY()-resNameLb:getContentSize().height-20))
			        cell:addChild(resCountLb)		       
				end

				local function showResources()
					local resIdx=0
					local posX=0
					for k,v in pairs(report.resource) do
						if v.num>0 then
							resIdx=resIdx+1
						end
						if resIdx%2==0 then
							posX=320
						else
							posX=20
						end
						if v.num>0 then
							initResInfo(v.pic,v.name,v.num,posX,posY,1)
						end
						if resIdx%2==0 then
							posY=posY-120
						end
					end
				end
				showResources()
			elseif rtype==6 then
				backSprie2:setPosition(ccp(0,self.cellHeightTb[idx+1]-backSprie2:getContentSize().height))		
				titleLabel2=GetTTFLabel(getlocal("search_fleet_report_sub_title2"),24)
				
				local shipTab=report.defendShip or {}
				-- G_dayin(shipTab)
				local tankX=445
	            local tankY=130
				for i=0,1,1 do
			        for j=0,2,1 do
			        	local inedx=((j+1)+(i*3))
						local function touch( ... )
						end
						local emptyTankSp=CCSprite:createWithSpriteFrameName("emptyTank.png")
			            local touchSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
			            touchSp:setTag(inedx)
			            touchSp:setIsSallow(true)
			            touchSp:setContentSize(CCSizeMake(emptyTankSp:getContentSize().width,emptyTankSp:getContentSize().height))
			            local selectTankBg1=CCSprite:createWithSpriteFrameName("selectTankBg1.png")
			            selectTankBg1:setPosition(ccp(touchSp:getContentSize().width/2,touchSp:getContentSize().height/2+10))
			            touchSp:addChild(selectTankBg1)
			            local selectTankBg2=CCSprite:createWithSpriteFrameName("selectTankBg2.png")
			            selectTankBg2:setAnchorPoint(ccp(0.5,0))
			            selectTankBg2:setPosition(ccp(touchSp:getContentSize().width/2,15))
			            touchSp:addChild(selectTankBg2)
			            local posSp=CCSprite:createWithSpriteFrameName("tankPos"..inedx..".png")
			            posSp:setPosition(ccp(touchSp:getContentSize().width/2,touchSp:getContentSize().height/2-10))
			            touchSp:addChild(posSp)
			            touchSp:setPosition(tankX-300*i,backSprie2:getContentSize().height-tankY-150*j)
			            backSprie2:addChild(touchSp,1)

			            if shipTab and shipTab[inedx] then
			            	local tankItem=shipTab[inedx]
			            	if tankItem.key and tankItem.num and tankItem.num>0 then
				            	local tankId=tankItem.key 
				            	local num=tankItem.num
				            	local id=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
					            local capInSet = CCRect(20, 20, 10, 10)
							    local tankBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
							    tankBg:setContentSize(CCSizeMake(touchSp:getContentSize().width, touchSp:getContentSize().height))
							    tankBg:setPosition(getCenterPoint(touchSp))
							    -- tankBg:setTouchPriority(-(layerNum-1)*20-5)
							    -- tankBg:setIsSallow(true)
							    touchSp:addChild(tankBg,2)
							    print("tankCfg[id].icon=",tankCfg[id].icon)
							    local spAdd=CCSprite:createWithSpriteFrameName(tankCfg[id].icon)
							    spAdd:setScale(0.6)
							    spAdd:setAnchorPoint(ccp(0,0.5));
							    spAdd:setPosition(ccp(5,touchSp:getContentSize().height/2))
							    touchSp:addChild(spAdd,2)
							    local cnOrDeTheightPos = nil
							    local cnOrDeTNumheiPos = nil
							    if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" then
							        cnOrDeTheightPos=55
							        cnOrDeTNumheiPos=40
							    else
							        cnOrDeTheightPos=50
							        cnOrDeTNumheiPos=30
							    end
							    local soldiersLbName = GetTTFLabelWrap(getlocal(tankCfg[id].name),20,CCSizeMake(170,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop);
							    soldiersLbName:setAnchorPoint(ccp(0,1));
							    soldiersLbName:setPosition(ccp(spAdd:getContentSize().width*0.6+5,touchSp:getContentSize().height/2+cnOrDeTheightPos));
							    touchSp:addChild(soldiersLbName,2);
							    local soldiersLbNum = GetTTFLabel(num,20);
							    soldiersLbNum:setAnchorPoint(ccp(0,0.5));
							    soldiersLbNum:setPosition(ccp(spAdd:getContentSize().width*0.6+10,touchSp:getContentSize().height/2-cnOrDeTNumheiPos));
							    touchSp:addChild(soldiersLbNum,2);
							end
						end
			        end
				end
			elseif rtype==7 or rtype==8 then
				titleLabel2=addAward(report,cell,backSprie2,titleLabel2)
			end
			titleLabel2:setPosition(getCenterPoint(backSprie2))
			backSprie2:addChild(titleLabel2,2)
		elseif idx==2 or idx==3 or idx==4 or idx==5 or idx==6 or idx==7 or idx==8 then
			if idx==2 and rtype==1 and report.islandType==7 then
				local backSprie3 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
			    backSprie3:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
			    backSprie3:ignoreAnchorPointForPosition(false)
			    backSprie3:setAnchorPoint(ccp(0,0))
			    backSprie3:setIsSallow(false)
			    backSprie3:setTouchPriority(-(self.layerNum-1)*20-2)
			    cell:addChild(backSprie3,1)
			    local titleLb3
				titleLb3=addAward(report,cell,backSprie3,titleLb3)
				titleLb3:setPosition(getCenterPoint(backSprie3))
				backSprie3:addChild(titleLb3,2)
				do return cell end
			end
			
			--return:1.军徽, 2.hero，3.accessory，4.lostTanks，5.glory繁荣度，6.侦查地方部队信息，7.战斗掠夺资源 

			--return:1.glory繁荣度，2.军徽，3.hero，4.accessory，5.lostTanks，6.侦查地方部队信息，7.战斗掠夺资源
			local showType=self:getShowType(report,idx)
		-- elseif idx ==2 and base.isGlory ==1 and SizeOfTable(gloryBm) > 0  then
			if showType==1 then
				local needHeight = 220
				local backSprie3 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
			    backSprie3:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
			    backSprie3:ignoreAnchorPointForPosition(false)
			    backSprie3:setAnchorPoint(ccp(0,1))
			    backSprie3:setIsSallow(false)
			    backSprie3:setPosition(ccp(0,needHeight))
			    backSprie3:setTouchPriority(-(self.layerNum-1)*20-2)
			    cell:addChild(backSprie3,1)

			    local pLevel = {report.attacker.name,report.defender.name}
			    local titleStr = {"attStr","defStr"}
			    for i=1,2 do
			    	local buildPic = playerVoApi:getPlayerBuildPic(gloryBm[i][4])
			    	local buildIcon = CCSprite:createWithSpriteFrameName(buildPic)
				    buildIcon:setScale(1)
				    buildIcon:setAnchorPoint(ccp(0,0))
				    buildIcon:setPosition(ccp(backSprie3:getContentSize().width*0.5*(2-i)-15,25))
				    cell:addChild(buildIcon)

				    if gloryBm[i][5] and gloryBm[i][5]==1 then
				    	self:fireBuildingAction(buildIcon)
				    end

				    local titleStrLb= GetTTFLabel(getlocal(titleStr[3-i]),24)
				    titleStrLb:setPosition(ccp(backSprie3:getContentSize().width*(0.42*(3-i))-(i-1)*40,needHeight-backSprie3:getContentSize().height-10))
				    titleStrLb:setAnchorPoint(ccp(0.5,1))
					cell:addChild(titleStrLb,2)

					local nameStr = GetTTFLabel(pLevel[3-i],24)
				    nameStr:setPosition(ccp(backSprie3:getContentSize().width*(0.42*(3-i))-(i-1)*40,needHeight-backSprie3:getContentSize().height-50))
				    nameStr:setAnchorPoint(ccp(0.5,1))
				    nameStr:setColor(G_ColorYellowPro)
					cell:addChild(nameStr,2)

					local newNum =gloryBm[i][1]+gloryBm[i][2]

					if newNum > gloryBm[i][3] then
						newNum =gloryBm[i][3]
					elseif newNum <0 then
						newNum =0
					end
					local gloryInfoStr = GetTTFLabel(math.ceil(newNum).."/"..gloryBm[i][3],24)
				    gloryInfoStr:setPosition(ccp(backSprie3:getContentSize().width*(0.42*(3-i))-(i-1)*40,needHeight-backSprie3:getContentSize().height-80))
				    gloryInfoStr:setAnchorPoint(ccp(0.5,1))
					cell:addChild(gloryInfoStr,2)

					local addSubGlory = math.ceil(gloryBm[i][2])
					local gloryStr = GetTTFLabel(addSubGlory,25)
				    gloryStr:setPosition(ccp(backSprie3:getContentSize().width*(0.42*(3-i))-(i-1)*40,needHeight-backSprie3:getContentSize().height-120))
				    gloryStr:setAnchorPoint(ccp(0.5,1))
					cell:addChild(gloryStr,2)
					if i ==2 and addSubGlory>0 then
						gloryStr:setColor(G_ColorGreen)
					elseif i ==1 and addSubGlory < 0 then
						gloryStr:setColor(G_ColorRed)
					end
			    end


			    local titleLabel3=GetTTFLabel(getlocal("gloryAndCity"),24)
			    titleLabel3:setPosition(getCenterPoint(backSprie3))
				backSprie3:addChild(titleLabel3,2)

		-- elseif (idx==2 and (base.isGlory ==0 or SizeOfTable(gloryBm) ==0)) or (idx ==3 and base.isGlory ==1 and SizeOfTable(gloryBm) > 0 ) then
			elseif showType==6 or showType==7 then
			    local backSprie3 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
			    backSprie3:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
			    backSprie3:ignoreAnchorPointForPosition(false)
			    backSprie3:setAnchorPoint(ccp(0,0))
			    backSprie3:setIsSallow(false)
			    backSprie3:setTouchPriority(-(self.layerNum-1)*20-2)
			    cell:addChild(backSprie3,1)

				local titleLabel3
				-- if rtype==2 then
				if showType==6 then
					titleLabel3=GetTTFLabel(getlocal("alliance_challenge_enemy_info"),24)
					-- local posHeightBs=220*3+10
					-- if G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="de" then
					-- 	posHeightBs =posHeightBs-30
					-- end
					backSprie3:setPosition(ccp(0, self.cellHeightTb[idx+1]-backSprie3:getContentSize().height))
					
					local sizeLb=self.cellHeightTb[idx+1]-backSprie3:getContentSize().height-110
					local shipTab=report.defendShip
					
					for k=1,6 do
						--local width = 80+((k-1)%2)*280
						--local height = sizeLb-(math.floor((k+1)/2))*220
						local width = self.bgLayer:getContentSize().width-(math.ceil(k/3))*280
						local height = sizeLb-(((k-1)%3)*220+60)

						local function touchClick(hd,fn,idx)
						end
						local bgSp =LuaCCScale9Sprite:createWithSpriteFrameName("BgEmptyTank.png",CCRect(10, 10, 20, 20),touchClick)
						bgSp:setContentSize(CCSizeMake(150, 150))
						bgSp:ignoreAnchorPointForPosition(false)
						bgSp:setAnchorPoint(ccp(0,0))
						bgSp:setIsSallow(false)
						bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
						bgSp:setPosition(ccp(width,height))
						cell:addChild(bgSp,1)
						
						local v
						if shipTab then
							v=shipTab[k]
						end
						if v and v.pic and v.name and v.num then
							local icon = CCSprite:createWithSpriteFrameName(v.pic)
							icon:setPosition(getCenterPoint(bgSp))
							bgSp:addChild(icon,2)

							if G_pickedList(tonumber(RemoveFirstChar(v.key))) ~= tonumber(RemoveFirstChar(v.key)) then
					             local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
					            icon:addChild(pickedIcon)
					            pickedIcon:setPosition(icon:getContentSize().width*0.7,icon:getContentSize().height*0.5-10)
					        end
							
							local str=(v.name).."("..FormatNumber(v.num)..")"
							local descLable = GetTTFLabelWrap(str,self.txtSize,CCSizeMake(self.txtSize*10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
					        descLable:setAnchorPoint(ccp(0.5,1))
							descLable:setPosition(ccp(width+bgSp:getContentSize().width/2,height))
							cell:addChild(descLable,2)
						end
					end
				-- elseif rtype==1 then
				elseif showType==7 then
					backSprie3:setPosition(ccp(0,self.cellHeightTb[idx+1]-backSprie3:getContentSize().height))
					
					local isAttacker=emailVoApi:isAttacker(report,self.chatSender)

					local resource={}
					if report.resource.u or report.resource.r then
						resource=FormatItem(report.resource)
					else
						resource=report.resource
					end
					local titleStr=getlocal("fight_content_resource_info")		
					if resource==nil or SizeOfTable(resource)==0 then
						titleStr=getlocal("fight_content_resource_info")..getlocal("fight_content_null")
					end
					titleLabel3=GetTTFLabel(titleStr,24)
					local sizeLb=backSprie3:getPositionY()
					for k,v in pairs(resource) do
						if v and v.pic and v.name and v.num then
							local width = 30
							local height = sizeLb-k*70
							local icon = CCSprite:createWithSpriteFrameName(v.pic)
					        icon:setAnchorPoint(ccp(0,0))
					      	icon:setPosition(ccp(width,height-10))
							cell:addChild(icon,2)
							if icon:getContentSize().width>100 then
								icon:setScaleX(100/150)
								icon:setScaleY(100/150)
							end
							icon:setScaleX(0.6)
							icon:setScaleY(0.6)
							
							local addStr=" "
							local numLable
							if tonumber(v.num)==0 then
								numLable = GetTTFLabel((v.name)..addStr..FormatNumber(v.num),self.txtSize)
							else
								if v.key=="gems" then
									addStr=" +"
									numLable = GetTTFLabel((v.name)..addStr..FormatNumber(v.num),self.txtSize)
									numLable:setColor(G_ColorGreen)
								else
									if isAttacker==true then
										if report.isVictory==1 then
											addStr=" +"
											numLable = GetTTFLabel((v.name)..addStr..FormatNumber(v.num),self.txtSize)
											numLable:setColor(G_ColorGreen)
										else
											addStr=" -"
											numLable = GetTTFLabel((v.name)..addStr..FormatNumber(v.num),self.txtSize)
											numLable:setColor(G_ColorRed)
										end
									else
										if report.isVictory==1 then
											addStr=" -"
											numLable = GetTTFLabel((v.name)..addStr..FormatNumber(v.num),self.txtSize)
											numLable:setColor(G_ColorRed)
										else
											addStr=" +"
											numLable = GetTTFLabel((v.name)..addStr..FormatNumber(v.num),self.txtSize)
											numLable:setColor(G_ColorGreen)
										end
									end
								end
							end
					        numLable:setAnchorPoint(ccp(0,0))
					        numLable:setPosition(ccp(width+icon:getContentSize().width/2+15,height))
							cell:addChild(numLable,2)
						end
					end
				end
				titleLabel3:setPosition(getCenterPoint(backSprie3))
				backSprie3:addChild(titleLabel3,2)
		-- elseif ((idx==3 or idx==4 or idx==5) and (base.isGlory ==0 or SizeOfTable(gloryBm) ==0)) or ((idx==4 or idx ==5 or idx ==6)and base.isGlory==1 and SizeOfTable(gloryBm) > 0 ) then
			elseif rtype==1 then
				-- local showType=self:getShowType(report,idx)
				if(showType==2)then
					local hCellWidth=self.bgLayer:getContentSize().width-50
					local hCellHeight=410
					local emblemTitleBg =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
				    emblemTitleBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
				    emblemTitleBg:ignoreAnchorPointForPosition(false)
				    emblemTitleBg:setAnchorPoint(ccp(0,0))
				    emblemTitleBg:setIsSallow(false)
				    emblemTitleBg:setTouchPriority(-(self.layerNum-1)*20-2)
				    cell:addChild(emblemTitleBg,1)
				    emblemTitleBg:setPosition(ccp(0,hCellHeight-50))

				    local emblemTitleLb=GetTTFLabel(getlocal("emblem_infoTitle"),24)
					emblemTitleLb:setPosition(getCenterPoint(emblemTitleBg))
					emblemTitleBg:addChild(emblemTitleLb,2)

		            local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		            lineSp:setAnchorPoint(ccp(0.5,0.5))
		            lineSp:setPosition(ccp(hCellWidth/2,(hCellHeight-50)/2))
		            lineSp:setScaleX((hCellHeight-30)/lineSp:getContentSize().width)
		            lineSp:setRotation(90)
		            cell:addChild(lineSp,1)

					local ownerEmblemStr=getlocal("emblem_emailOwn")
					local enemyEmblemStr=getlocal("emblem_emailEnemy")
					local myEmblem,myEmblemCfg,myEmblemSkill,myEmblemStrong
					local enemyEmblem,enemyEmblemCfg,enemyEmblemSkill,enemyEmblemStrong
					
					local emblemData=report.emblemID or {nil,nil}
					local isAttacker=emailVoApi:isAttacker(report,self.chatSender)
					if emblemData then
						if isAttacker==true then
							myEmblem = emblemData[1] ~= 0 and emblemData[1] or nil
							enemyEmblem = emblemData[2] ~= 0 and emblemData[2] or nil
						else
							myEmblem = emblemData[2] ~= 0 and emblemData[2] or nil
							enemyEmblem = emblemData[1] ~= 0 and emblemData[1] or nil
						end
						if myEmblem then
                            myEmblemCfg = emblemVoApi:getEquipCfgById(myEmblem)
                            myEmblemSkill = myEmblemCfg.skill
                            myEmblemStrong=myEmblemCfg.qiangdu
						end

						if enemyEmblem then
                            enemyEmblemCfg = emblemVoApi:getEquipCfgById(enemyEmblem)
                            enemyEmblemSkill = enemyEmblemCfg.skill
                            enemyEmblemStrong=enemyEmblemCfg.qiangdu
						end
					end

					local ownerEmblemLb=GetTTFLabelWrap(ownerEmblemStr,24,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					ownerEmblemLb:setAnchorPoint(ccp(0.5,0.5))
					ownerEmblemLb:setPosition(ccp(hCellWidth/4,hCellHeight-85))
					cell:addChild(ownerEmblemLb,2)
					ownerEmblemLb:setColor(G_ColorGreen)

					local enemyEmblemLb=GetTTFLabelWrap(enemyEmblemStr,24,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					enemyEmblemLb:setAnchorPoint(ccp(0.5,0.5))
					enemyEmblemLb:setPosition(ccp(hCellWidth/4*3,hCellHeight-85))
					cell:addChild(enemyEmblemLb,2)
					enemyEmblemLb:setColor(G_ColorRed)

					local myEmblemIcon
                    if myEmblem then
	                    myEmblemIcon = emblemVoApi:getEquipIcon(myEmblem,nil,nil,nil,myEmblemStrong)
	                else
	                	myEmblemIcon = emblemVoApi:getEquipIconNull()
	                end
	                myEmblemIcon:setAnchorPoint(ccp(0.5,0))
                    myEmblemIcon:setPosition(ccp(hCellWidth/4,60))
                    cell:addChild(myEmblemIcon)
                    
                    local enemyEmblemIcon
                    if enemyEmblem then
	                    enemyEmblemIcon = emblemVoApi:getEquipIcon(enemyEmblem,nil,nil,nil,enemyEmblemStrong)
	                else
	                	enemyEmblemIcon = emblemVoApi:getEquipIconNull()
	                end
	                enemyEmblemIcon:setAnchorPoint(ccp(0.5,0))
                    enemyEmblemIcon:setPosition(ccp(hCellWidth/4 * 3,60))
                    cell:addChild(enemyEmblemIcon)

                    --我方装备信息（技能+强度）
                    if myEmblemSkill ~= nil then
						local mySkillLb=GetTTFLabelWrap(emblemVoApi:getEquipSkillNameById(myEmblemSkill[1],myEmblemSkill[2]),24,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
						mySkillLb:setAnchorPoint(ccp(0.5,0.5))
						mySkillLb:setPosition(ccp(hCellWidth/4,30))
						cell:addChild(mySkillLb,2)
					end

                    --敌方装备信息（技能+强度）
                    if enemyEmblemSkill ~= nil then
						local enemySkillLb=GetTTFLabel(emblemVoApi:getEquipSkillNameById(enemyEmblemSkill[1],enemyEmblemSkill[2]),24)
						enemySkillLb:setAnchorPoint(ccp(0.5,0.5))
						enemySkillLb:setPosition(ccp(hCellWidth/4*3,30))--85
						cell:addChild(enemySkillLb,2)
					end
				elseif showType==3 then
					-- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
					local hCellWidth=self.bgLayer:getContentSize().width-50
					local hCellHeight=530
					local backSprie6 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
				    backSprie6:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
				    backSprie6:ignoreAnchorPointForPosition(false)
				    backSprie6:setAnchorPoint(ccp(0,0))
				    backSprie6:setIsSallow(false)
				    backSprie6:setTouchPriority(-(self.layerNum-1)*20-2)
				    cell:addChild(backSprie6,1)
				    backSprie6:setPosition(ccp(0,hCellHeight-50))

				    local titleLabel6=GetTTFLabel(getlocal("report_hero_message"),24)
					titleLabel6:setPosition(getCenterPoint(backSprie6))
					backSprie6:addChild(titleLabel6,2)

		            local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		            lineSp:setAnchorPoint(ccp(0.5,0.5))
		            lineSp:setPosition(ccp(hCellWidth/2,(hCellHeight-50)/2))
		            lineSp:setScaleX((hCellHeight-30)/lineSp:getContentSize().width)
		            lineSp:setRotation(90)
		            cell:addChild(lineSp,1)

					local ownerHeroStr=getlocal("report_hero_owner")
					local enemyHeroStr=getlocal("report_hero_enemy")
					local scoreStr=getlocal("report_hero_score")
					-- ownerHeroStr=str
					-- enemyHeroStr=str
					-- scoreStr=str
					local myHero={}
					local enemyHero={}
					local myScore=0
					local enemyScore=0
					local heroData=report.hero or {{{},0},{{},0}}
					local isAttacker=emailVoApi:isAttacker(report,self.chatSender)
					if heroData then
						if isAttacker==true then
							if heroData[1] then
								myHero=heroData[1][1] or {}
								myScore=heroData[1][2] or 0
							end
							if heroData[2] then
								enemyHero=heroData[2][1] or {}
								enemyScore=heroData[2][2] or 0
							end
						else
							if heroData[1] then
								enemyHero=heroData[1][1] or {}
								enemyScore=heroData[1][2] or 0
							end
							if heroData[2] then
								myHero=heroData[2][1] or {}
								myScore=heroData[2][2] or 0
							end
						end
					end

					local ownerHeroLb=GetTTFLabelWrap(ownerHeroStr,24,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					ownerHeroLb:setAnchorPoint(ccp(0.5,0.5))
					ownerHeroLb:setPosition(ccp(hCellWidth/4,hCellHeight-85))
					cell:addChild(ownerHeroLb,2)
					ownerHeroLb:setColor(G_ColorGreen)

					local enemyHeroLb=GetTTFLabelWrap(enemyHeroStr,24,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					enemyHeroLb:setAnchorPoint(ccp(0.5,0.5))
					enemyHeroLb:setPosition(ccp(hCellWidth/4*3,hCellHeight-85))
					cell:addChild(enemyHeroLb,2)
					enemyHeroLb:setColor(G_ColorGreen)


					for i=1,6 do
						local wSpace=20
						local hSpace=10
						local iconSize=90
						local posX=hCellWidth/4+iconSize/2+wSpace/2-math.floor((i-1)/3)*(iconSize+wSpace)
						local posY=hCellHeight-iconSize/2-((i-1)%3)*(iconSize+hSpace)-120
						
						local mHid=nil
						local mLevel=nil
						local mProductOrder=nil
						if myHero and myHero[i] then
							local myHeroArr=Split(myHero[i],"-")
							mHid=myHeroArr[1]
							mLevel=myHeroArr[2]
							mProductOrder=myHeroArr[3]
						end
						local myIcon=heroVoApi:getHeroIcon(mHid,mProductOrder,false)
						if myIcon then
							myIcon:setScale(iconSize/myIcon:getContentSize().width)
							myIcon:setPosition(ccp(posX,posY))
							cell:addChild(myIcon,2)
						end

						local ehid=nil
						local elevel=nil
						local eproductOrder=nil
						if enemyHero and enemyHero[i] then
							local enemyHeroArr=Split(enemyHero[i],"-")
							ehid=enemyHeroArr[1]
							elevel=enemyHeroArr[2]
							eproductOrder=enemyHeroArr[3]
						end
						posX=hCellWidth/4*3+iconSize/2+wSpace/2-math.floor((i-1)/3)*(iconSize+wSpace)
						local enemyIcon=heroVoApi:getHeroIcon(ehid,eproductOrder,false)
						if enemyIcon then
							enemyIcon:setScale(iconSize/myIcon:getContentSize().width)
							enemyIcon:setPosition(ccp(posX,posY))
							cell:addChild(enemyIcon,2)
						end
					end

					local scoreLb1=GetTTFLabelWrap(scoreStr,24,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					scoreLb1:setAnchorPoint(ccp(0.5,0.5))
					scoreLb1:setPosition(ccp(hCellWidth/4,85))
					cell:addChild(scoreLb1,2)
					scoreLb1:setColor(G_ColorGreen)

					local scoreLb2=GetTTFLabelWrap(scoreStr,24,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					scoreLb2:setAnchorPoint(ccp(0.5,0.5))
					scoreLb2:setPosition(ccp(hCellWidth/4*3,85))
					cell:addChild(scoreLb2,2)
					scoreLb2:setColor(G_ColorGreen)

					local myScoreLb=GetTTFLabel(myScore,24)
					myScoreLb:setAnchorPoint(ccp(0.5,0.5))
					myScoreLb:setPosition(ccp(hCellWidth/4,40))
					cell:addChild(myScoreLb,2)

					local enemyScoreLb=GetTTFLabel(enemyScore,24)
					enemyScoreLb:setAnchorPoint(ccp(0.5,0.5))
					enemyScoreLb:setPosition(ccp(hCellWidth/4*3,40))
					cell:addChild(enemyScoreLb,2)

				elseif showType==4 then
					local backSprie5 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
				    backSprie5:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
				    backSprie5:ignoreAnchorPointForPosition(false)
				    backSprie5:setAnchorPoint(ccp(0,0))
				    backSprie5:setIsSallow(false)
				    backSprie5:setTouchPriority(-(self.layerNum-1)*20-2)
				    cell:addChild(backSprie5,1)

				    local titleLabel5=GetTTFLabel(getlocal("report_accessory_compare"),24)
					titleLabel5:setPosition(getCenterPoint(backSprie5))
					backSprie5:addChild(titleLabel5,2)

					local accessory=report.accessory or {}
					local attAccData={}
					local defAccData={}
					local isAttacker=emailVoApi:isAttacker(report,self.chatSender)
					if isAttacker==true then
						attAccData=accessory[1] or {}
						defAccData=accessory[2] or {}
					else
						attAccData=accessory[2] or {}
						defAccData=accessory[1] or {}
					end
					local attScore=attAccData[1] or 0
					local defScore=defAccData[1] or 0
					local attTab=attAccData[2] or {0,0,0,0}
					local defTab=defAccData[2] or {0,0,0,0}
					if accessoryVoApi:isUpgradeQualityRed()==true then
						if attTab[5]==nil then
							attTab[5]=0
						end
						if defTab[5]==nil then
							defTab[5]=0
						end
					end

					local htSpace=50
					local perSpace=self.txtSize+10

					local cellHeight=self:getReportAccessoryhight(report)
					local lbHeight=cellHeight-htSpace
					local lbWidth=backSprie5:getContentSize().width/2+10

					backSprie5:setPosition(ccp(0,self.cellHeightTb[idx+1]-backSprie5:getContentSize().height))

					local function tipTouch()
				        local sd=smallDialog:new()
				        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,{" ",getlocal("report_accessory_desc")," "},25)
				        sceneGame:addChild(dialogLayer,self.layerNum+1)
				        dialogLayer:setPosition(ccp(0,0))
				    end
				    local tipItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,11,nil,nil)
				    local spScale=0.7
				    tipItem:setScale(spScale)
				    local tipMenu = CCMenu:createWithItem(tipItem)
				    tipMenu:setPosition(ccp(backSprie5:getContentSize().width-tipItem:getContentSize().width/2*spScale+10,cellHeight-50-tipItem:getContentSize().height/2*spScale+55))
				    tipMenu:setTouchPriority(-(self.layerNum-1)*20-2)
				    cell:addChild(tipMenu,1)

					for i=1,2 do
						local content={}
						content[i]={}

						local campStr=""
						local scoreStr=getlocal("report_accessory_score")
						local score=0

						if i==1 then
							campStr=getlocal("report_accessory_owner")
							score=attScore
						elseif i==2 then
							campStr=getlocal("report_accessory_enemy")
							score=defScore
						end

						table.insert(content[i],{campStr,G_ColorGreen})
						table.insert(content[i],{scoreStr,G_ColorGreen})
						table.insert(content[i],{score,G_ColorWhite})

						local contentLbHight=0
						for k,v in pairs(content[i]) do
							local contentMsg=v
							local message=""
							local color
							if type(contentMsg)=="table" then
								message=contentMsg[1]
								color=contentMsg[2]
							else
								message=contentMsg
							end
		                    local contentLb
		                    contentLb=GetTTFLabelWrap(message,24,CCSizeMake((backSprie5:getContentSize().width-50)/2, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
						    local contentShowLb
					      	contentShowLb=GetTTFLabelWrap(message,24,CCSizeMake((backSprie5:getContentSize().width-50)/2, 500),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
						    contentShowLb:setAnchorPoint(ccp(0,1))
							if contentLbHight==0 then
								contentLbHight=cellHeight-60
							end
							if i==1 then
						    	contentShowLb:setPosition(ccp(10,contentLbHight))
						    else
						    	contentShowLb:setPosition(ccp(lbWidth,contentLbHight))
						    end
						    if k==1 then
						    	local accNum=0
						    	local accTab={}
						    	if i==1 then
					    			accNum=SizeOfTable(attTab)
					    			accTab=attTab
					    		else
					    			accNum=SizeOfTable(defTab)
					    			accTab=defTab
					    		end
					    		if accNum>0 then
							    	for n=1,accNum do
							    		-- if n<accNum or (n==accNum and accTab[n] and accTab[n]>0) then
								    		local iWidth
								    		if i==1 then
								    			iWidth=10+((n+1)%2)*100
								    		else
								    			iWidth=lbWidth+((n+1)%2)*100
								    		end
								    		local iHeight=contentLbHight-contentLb:getContentSize().height-25-math.floor((n-1)/2)*45

								    		local iSize=30
								    		
								    		local icon=CCSprite:createWithSpriteFrameName("uparrow"..n..".png")
								    		local scale=iSize/icon:getContentSize().width
								            -- icon:setAnchorPoint(ccp(0.5,0.5))
								            icon:setScale(scale)
								            icon:setPosition(ccp(iWidth+iSize/2,iHeight))
								            cell:addChild(icon,1)

								    		local numLb
								    		if i==1 then
								    			numLb=GetTTFLabel((attTab[n] or 0),24)
								    		else
								    			numLb=GetTTFLabel((defTab[n] or 0),24)
								    		end
								    		-- numLb:setAnchorPoint(ccp(0.5,0.5))
								            numLb:setPosition(ccp(iWidth+iSize+15,iHeight))
								            cell:addChild(numLb,1)
								        -- end
							    	end
							    end
						    end
						    if k==1 then
						    	contentLbHight=contentLbHight-(contentLb:getContentSize().height+100)
						    	if accessoryVoApi:isUpgradeQualityRed()==true or (attTab and SizeOfTable(attTab)>=5) or (defTab and SizeOfTable(defTab)>=5) then
						    		contentLbHight=contentLbHight-40
						    	end
					    	elseif k==2 then
					    		contentLbHight=contentLbHight-(contentLb:getContentSize().height+5)
					    	else
					    		contentLbHight=contentLbHight-(contentLb:getContentSize().height+25)
					    	end
						    cell:addChild(contentShowLb,1)
					        if color~=nil then
						        contentShowLb:setColor(color)
						    end

						end

					end
				elseif showType==5 then
				    local backSprie4 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
				    backSprie4:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
				    backSprie4:ignoreAnchorPointForPosition(false)
				    backSprie4:setAnchorPoint(ccp(0,0))
				    backSprie4:setIsSallow(false)
				    backSprie4:setTouchPriority(-(self.layerNum-1)*20-2)
				    cell:addChild(backSprie4,1)
					
					local titleLabel4=GetTTFLabel(getlocal("fight_content_ship_lose"),24)
					titleLabel4:setPosition(getCenterPoint(backSprie4))
					backSprie4:addChild(titleLabel4,2)

					local attLost={}--当前坦克战斗完损失的数量
					local defLost={}
					local attTotal = {}--当前战斗坦克的总数
					local defTotal = {}
					if report.lostShip.attackerLost then
						if report.lostShip.attackerLost.o then
							attLost=FormatItem(report.lostShip.attackerLost,false)
						else
							attLost=report.lostShip.attackerLost
						end
					end

					if report.lostShip.defenderLost then
						if report.lostShip.defenderLost.o then
							defLost=FormatItem(report.lostShip.defenderLost,false)
						else
							defLost=report.lostShip.defenderLost
						end
					end

					if report.lostShip.attackerTotal then
						if report.lostShip.attackerTotal.o then
							attTotal=FormatItem(report.lostShip.attackerTotal,false)
						else
							attTotal=report.lostShip.attackerTotal
						end
					end
					if report.lostShip.defenderTotal then
						if report.lostShip.defenderTotal.o then
							defTotal=FormatItem(report.lostShip.defenderTotal,false)
						else
							defTotal=report.lostShip.defenderTotal
						end
					end		

					local attackerStr=""
					local attackerLost=""
					local defenderStr=""
					local defenderLost=""
					local attackerTotal = ""
					local defenderTotal = ""
					local repairStr=""
					local content={}
					
					local htSpace=0
					local perSpace=self.txtSize+10

					local attackerLostNum=SizeOfTable(attLost)
					local defenderLostNum=SizeOfTable(defLost)
					local attackerTotalNum = SizeOfTable(attTotal)
					local defenderTotalNum = SizeOfTable(defTotal)
					if attackerTotalNum>0 or defenderTotalNum>0 then
						perSpace=self.txtSize+30
						--损失的船
						-- local attackerLostNum=SizeOfTable(attLost)
						-- local defenderLostNum=SizeOfTable(defLost)
						-- local attackerTotalNum = SizeOfTable(attTotal)
						-- local defenderTotalNum = SizeOfTable(defTotal)
						-- backSprie4:setPosition(ccp(0, perSpace*(4+attackerTotalNum+defenderTotalNum)+10))
						backSprie4:setPosition(ccp(0,self.cellHeightTb[idx+1]-backSprie4:getContentSize().height))
						local hCellWidth = self.bgLayer:getContentSize().width-50
						local cellHeight =backSprie4:getPositionY()
						--local cellHeight=perSpace*(4+attackerLostNum+defenderLostNum)+htSpace
						local armysContent = {getlocal("battleReport_armysName"),getlocal("battleReport_armysNums"),getlocal("battleReport_armysLosts"),getlocal("battleReport_armysleaves")}

						local showColor = {G_ColorWhite,G_ColorOrange2,G_ColorRed,G_ColorGreen}--所有需要显示的文字颜色
						local defHeight,attOrDefTotal,attOrDefLost --
						for g=1,2 do --
							if g==2 then
								cellHeight = defHeight-20
							end
							if g==1 then
								personStr=getlocal("fight_content_attacker",{attacker})
								attOrDefTotal =G_clone(attTotal)
								attOrDefLost =G_clone(attLost)
							elseif g==2 then
								local isAttacker=emailVoApi:isAttacker(report,self.chatSender)
								attOrDefTotal =G_clone(defTotal)
								attOrDefLost =G_clone(defLost)
								local defendName=defender
								if hasHelpDefender==true then
									defendName=helpDefender
								end
								if isAttacker==true then
									if report.islandType==7 then
										local rebelData=report.rebel or {}
										local rebelLv=rebelData.rebelLv or 1
										local rebelID=rebelData.rebelID or 1
										personStr=defenderStr..getlocal("fight_content_defender",{G_getIslandName(islandType,nil,rebelLv,rebelID,true,rebelData.rpic)})
									elseif report.islandType==6 or report.islandType==8 then
										personStr=defenderStr..getlocal("fight_content_defender",{defendName})
									else
										if report.islandOwner>0 then
											personStr=defenderStr..getlocal("fight_content_defender",{defendName})
										else
											personStr=defenderStr..getlocal("fight_content_defender",{G_getIslandName(islandType)})
										end
									end
								else
									personStr=defenderStr..getlocal("fight_content_defender",{defendName})
								end
							end
							local attContent=GetTTFLabel(personStr,self.txtSize)
							attContent:setAnchorPoint(ccp(0,0.5))
							attContent:setPosition(ccp(10,cellHeight-40))
							cell:addChild(attContent,2)

							if g==1 then
								attContent:setColor(G_ColorGreen)
							elseif g==2 then
								attContent:setColor(G_ColorRed)
							end

							local function sortAsc(a, b)
								if sortByIndex then
									if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
										return a.id < b.id
									end
								else
									if a.type==b.type then
										if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
											return a.id < b.id
										end
							        end
								end
						    end
							table.sort(attOrDefTotal,sortAsc)
							local lablSize = self.txtSize-9
							local lablSizeO	= self.txtSize -8
							if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
								lablSize =self.txtSize
								lablSizeO =self.txtSize-3
							end
							local lbPosWIdth = 6
							for k,v in pairs(armysContent) do
								local armyLb=GetTTFLabelWrap(v,lablSize,CCSizeMake(backSprie4:getContentSize().width*0.1+70,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
								armyLb:setAnchorPoint(ccp(0.5,0.5))
								if k >1 then
									lbPosWIdth =7
								end
								armyLb:setPosition(ccp(hCellWidth*k/lbPosWIdth+((k-1)*70),cellHeight-90))
							    cell:addChild(armyLb,2)
							    armyLb:setColor(showColor[k])
							end
							
							local localLeaves = {}
							for i=1,4 do
								local localStr
								local pos = 50
								if i ==1 then
									for k,v in pairs(attOrDefTotal) do
										if v and v.name then
											localStr=v.name
											local armyStr =GetTTFLabelWrap(localStr,lablSizeO,CCSizeMake(backSprie4:getContentSize().width*0.1+70,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
											armyStr:setAnchorPoint(ccp(0.5,0.5))
											armyStr:setPosition(ccp(hCellWidth*i/6+((i-1)*70),cellHeight-90-((pos-1)*k)))
										    cell:addChild(armyStr,2)
										    armyStr:setColor(showColor[i])
							    		end
							    		if tankCfg[v.id].isElite==1 then
											local pickedSp = CCSprite:createWithSpriteFrameName("picked_icon1.png")
									        -- pickedSp:setScale()
									        pickedSp:setAnchorPoint(ccp(0.5,0.5))
									        pickedSp:setPosition(ccp(15,cellHeight-90-(49*k)))
									        cell:addChild(pickedSp,2)
									    end
							    		if k == SizeOfTable(attOrDefTotal) then
							    			defHeight =cellHeight-90-((pos-1)*k)
										end
									end
								end
								if i==2 then
									for k,v in pairs(attOrDefTotal) do
										table.insert(localLeaves,{num=v.num})
										-- G_dayin(localLeaves)
									end
									for k,v in pairs(attOrDefTotal) do
										if v and v.num then
											localStr=v.num
											local armyStr =GetTTFLabelWrap(localStr,self.txtSize,CCSizeMake(backSprie4:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
											armyStr:setAnchorPoint(ccp(0.5,0.5))
											armyStr:setPosition(ccp(hCellWidth*i/7+((i-1)*70),cellHeight-90-((pos-1)*k)))
										    cell:addChild(armyStr,2)
										    armyStr:setColor(showColor[i])
										    
							    		end 								
									end
								end
								if i==3 then
									local lostNum
									if SizeOfTable(attOrDefLost) ==0 then
										lostNum =attOrDefTotal
									elseif SizeOfTable(attOrDefLost) >0 and SizeOfTable(attOrDefLost) ~=SizeOfTable(attOrDefTotal) then
										local ishere =0
										for k,v in pairs(attOrDefTotal) do
											for m,n in pairs(attOrDefLost) do
												if m then
													if v.id ==n.id then
														ishere =0
														break
													else
														ishere =1
													end
												end
											end
											if ishere ==1 then
												table.insert(attOrDefLost,v)
												for h,j in pairs(attOrDefLost) do
													 if j.id ==v.id then
													 	j.num =0
													 end
												end
												ishere =0
											end
										end										
										lostNum =attOrDefLost
									else
										lostNum =attOrDefLost
									end
									local function sortAsc(a, b)
										if sortByIndex then
											if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
												return a.id < b.id
											end
										else
											if a.type==b.type then
												if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
													return a.id < b.id
												end
									        end
										end
								    end
									table.sort(lostNum,sortAsc)									
									for k,v in pairs(lostNum) do
										if v and v.num and SizeOfTable(attOrDefLost) >=1 then
											localStr=v.num
										else
							    			localStr=0
							    		end
											local armyStr =GetTTFLabelWrap(localStr,self.txtSize,CCSizeMake(backSprie4:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
											armyStr:setAnchorPoint(ccp(0.5,0.5))
											armyStr:setPosition(ccp(hCellWidth*i/7+((i-1)*70),cellHeight-90-((pos-1)*k)))
										    cell:addChild(armyStr,2)
										    armyStr:setColor(showColor[i])
										    if localLeaves and localLeaves[k] and localLeaves[k].num then
											    localLeaves[k].num=localLeaves[k].num-localStr
											end
									end
								end
								if i==4 then
									for k,v in pairs(localLeaves) do
										if v and v.num then
											localStr=v.num
											local armyStr =GetTTFLabelWrap(localStr,self.txtSize,CCSizeMake(backSprie4:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
											armyStr:setAnchorPoint(ccp(0.5,0.5))
											armyStr:setPosition(ccp(hCellWidth*i/7+((i-1)*70),cellHeight-90-((pos-1)*k)))
										    cell:addChild(armyStr,2)
										    armyStr:setColor(showColor[i])
							    		end 								
									end
									localLeaves =nil
								end						
							end						
						end
						if SizeOfTable(attOrDefTotal) >=1 then
							repairStr=getlocal("fight_content_tip_1")
							local repairLb =GetTTFLabelWrap(repairStr,24,CCSizeMake(backSprie4:getContentSize().width-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
							repairLb:setPosition(ccp(10,defHeight-70))
							repairLb:setAnchorPoint(ccp(0,0.5))
							cell:addChild(repairLb,2)
							repairLb:setColor(G_ColorOrange2)
						end
					else
						--损失的船
						-- local attackerLostNum=SizeOfTable(attLost)
						-- local defenderLostNum=SizeOfTable(defLost)
						-- backSprie4:setPosition(ccp(0, perSpace*(4+attackerLostNum+defenderLostNum)+10))
						backSprie4:setPosition(ccp(0,self.cellHeightTb[idx+1]-backSprie4:getContentSize().height))
						
						--local lostStr=""
						local isAttacker=emailVoApi:isAttacker(report,self.chatSender)		
						attackerStr=getlocal("fight_content_attacker",{attacker}).."\n"
						table.insert(content,{attackerStr,htSpace})
						for k,v in pairs(attLost) do
							if v and v.name and v.num then
								attackerLost=attackerLost.."    "..(v.name).." -"..tostring(v.num).."\n"
							end
						end
						table.insert(content,{attackerLost,perSpace+htSpace,G_ColorRed})
						local defendName=defender
						if hasHelpDefender==true then
							defendName=helpDefender
						end
						if isAttacker==true then
							if report.islandType==7 then
								local rebelData=report.rebel or {}
								local rebelLv=rebelData.rebelLv or 1
								local rebelID=rebelData.rebelID or 1
								defenderStr=defenderStr..getlocal("fight_content_defender",{G_getIslandName(islandType,nil,rebelLv,rebelID,nil,rebelData.rpic)}).."\n"
							elseif report.islandType==6 or report.islandType==8 then
								defenderStr=defenderStr..getlocal("fight_content_defender",{defendName}).."\n"
							else
								if report.islandOwner>0 then
									defenderStr=defenderStr..getlocal("fight_content_defender",{defendName}).."\n"
								else
									defenderStr=defenderStr..getlocal("fight_content_defender",{G_getIslandName(islandType)}).."\n"
								end
							end
						else
							--defenderStr=defenderStr..getlocal("fight_content_defender",{playerVoApi:getPlayerName()}).."\n"
							defenderStr=defenderStr..getlocal("fight_content_defender",{defendName}).."\n"
						end
						table.insert(content,{defenderStr,perSpace*attackerLostNum+perSpace+htSpace})
						for k,v in pairs(defLost) do
							if v and v.name and v.num then
								defenderLost=defenderLost.."    "..(v.name).." -"..tostring(v.num).."\n"
							end
						end
						table.insert(content,{defenderLost,perSpace*attackerLostNum+perSpace*2+htSpace,G_ColorRed})
						repairStr=getlocal("fight_content_tip_1")
						table.insert(content,{repairStr,perSpace*(2+attackerLostNum+defenderLostNum)+htSpace})

						local cellHeight=perSpace*(4+attackerLostNum+defenderLostNum)+htSpace
						for k,v in pairs(content) do
							if v~=nil and v~="" then
								local contentMsg=content[k]
								local message=""
								local pos=0
								local color
								if type(contentMsg)=="table" then
									message=contentMsg[1]
									pos=contentMsg[2]
									color=contentMsg[3]
								else
									message=contentMsg
								end
								if message~=nil and message~="" then
							        local contentLb=GetTTFLabel(message,self.txtSize)
									if k==2 then
							    		contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(backSprie4:getContentSize().width-10,60*attackerLostNum),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
									elseif k==4 then
										contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(backSprie4:getContentSize().width-10,60*defenderLostNum),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
									elseif k==5 then
										contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(backSprie4:getContentSize().width,60*1.5),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
									end
									contentLb:setAnchorPoint(ccp(0,1))
									contentLb:setPosition(ccp(10,cellHeight-pos))
								    cell:addChild(contentLb,2)
							        if color~=nil then
								        contentLb:setColor(color)
								    end
								end
							end
					    end
				    end
				elseif showType==8 then
					local isAttacker=emailVoApi:isAttacker(report,self.chatSender)
					G_addReportPlane(report,cell,isAttacker)
				end

			end
		end

		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

--idx:2,3,4,5,6,7,8
--return:1.glory繁荣度，2.军徽，3.hero，4.accessory，5.lostTanks，6.侦查地方部队信息，7.战斗掠夺资源，8.飞机
function emailDetailDialog:getShowType(report,idx)
	local showType=0
	local rtype=report.type
	local islandType=report.islandType
	if idx==2 then
		if rtype==1 then
			showType=7
		elseif rtype==2 then
			showType=6
		end
		do return showType end
	end
	if idx==3 and rtype==1 and islandType==7 then
		do return 5 end
	end
	--idx:3,4,5,6,7,8
	local isGloryBm = false --取到攻守双方的繁荣度值
	if base.isGlory ==1 and report.report and report.report.bm and SizeOfTable(report.report.bm) >0 then
		isGloryBm =true
	end
	local isShowHero=emailVoApi:isShowHero(report)
	local isShowAccessory=emailVoApi:isShowAccessory(report)
	local isShowEmblem=emailVoApi:isShowEmblem(report)
	local isShowPlane=G_isShowPlaneInReport(report,1)
	local showTypeTb={0,0}
	if base.isGlory ==1 and isGloryBm == true then
		table.insert(showTypeTb,1)
	end
	if(isShowPlane)then
		table.insert(showTypeTb,8)
	end
	if(isShowEmblem)then
		table.insert(showTypeTb,2)
	end
	if(isShowHero)then
		table.insert(showTypeTb,3)
	end
	if(isShowAccessory)then
		table.insert(showTypeTb,4)
	end
	table.insert(showTypeTb,5)
	return showTypeTb[idx]
end

--[[
function emailDetailDialog:getRect()
	return  CCRectMake(0, -size.height / 2, inputFrameWidth, size.height)
end

function emailDetailDialog:isInTextField(pTouch)
    return getRect().containsPoint(convertTouchToNodeSpaceAR(pTouch))
end
]]
function emailDetailDialog:initCursorSprite(sprie,height)
    --初始化光标
	--[[
    local column = 4
    local nHeight = mHeight
	local pixels = {}
	for i=0,nHeight do
		for j=0,column do
			table.insert(pixels, 0xffffffff)
		end
	end
    local texture = CCTexture2D:initWithData(pixels, kCCTexture2DPixelFormat_RGB888, 1, 1, CCSizeMake(column, nHeight))
	self.cursorSprite = CCSprite:createWithTexture(texture)
	]]
	
	--[[
	self.cursorSprite = CCSprite:createWithSpriteFrameName("IconTip.png")
    local m_cursorPos = ccp(0, height-self.cursorSprite:getContentSize().height/2)
    self.cursorSprite:setPosition(m_cursorPos)
    sprie:addChild(self.cursorSprite)
    self.cursorSprite:setVisible(false)
	
	local fadeOut=CCFadeOut:create(0.25)
	local fadeIn=CCFadeIn:create(0.25)
	local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
	self.cursorSprite:runAction(CCRepeatForever:create(seq))
	]]
end 
function emailDetailDialog:setName(name,uid)
    self.target=name
    self.emailReceiverUId=tonumber(uid)
    self.targetBoxLabel:setString(self.target)
    for k,v in pairs(GM_Name) do
        if v == name then
            self.targetBoxLabel:setColor(G_ColorYellowPro)
            do break end
        end
    end
end
	
function emailDetailDialog:fireBuildingAction( buildIcon)
        buildIcon:setColor(ccc3(136,136,136))
        local pzFrameName="bf1.png"
        local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
        metalSp:setAnchorPoint(ccp(0.5,0.5))
        metalSp:setTag(881)
        metalSp:setScale(buildIcon:getContentSize().width*0.9/metalSp:getContentSize().width)
        metalSp:setPosition(ccp(buildIcon:getContentSize().width*0.55,buildIcon:getContentSize().height*0.38))
        local pzArr=CCArray:create()
        for kk=1,11 do
            local nameStr="bf"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local animation=CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.08)
        local animate=CCAnimate:create(animation)
        local repeatForever=CCRepeatForever:create(animate)
        local x = 1
        metalSp:runAction(repeatForever)
        buildIcon:addChild(metalSp)

        -- local redBgShow = CCSprite:createWithSpriteFrameName("redMaskT.png")
        -- redBgShow:setAnchorPoint(ccp(0.5,0.5))
        -- redBgShow:setScale((metalSp:getContentSize().width+10)/redBgShow:getContentSize().width)
        -- redBgShow:setPosition(ccp(metalSp:getContentSize().width*0.45,metalSp:getContentSize().height*0.6))
        -- metalSp:addChild(redBgShow)
        -- local fadeIn = CCFadeIn:create(1)
        -- local fadeInUn = fadeIn:reverse()
        -- local acArr = CCArray:create()
        -- acArr:addObject(fadeIn)
        -- acArr:addObject(fadeInUn)
        -- local seq = CCSequence:create(acArr)
        -- local repeatForever = CCRepeatForever:create(seq)
        -- redBgShow:runAction(repeatForever)
end



function emailDetailDialog:dispose()
	if self.reportDialog and self.reportDialog.dispose then
		self.reportDialog:dispose()
		self.reportDialog=nil
		self.reportLayer=nil
	end
	self.sendSuccess=nil
	self.layerNum=nil
	self.eid=nil
    self.emailType=nil
	self.target=nil
	self.theme=nil
	self.replayBtn=nil
	self.attackBtn=nil
	self.writeBtn=nil
	self.deleteBtn=nil
	self.sendBtn=nil
	self.feedBtn=nil
	self.chatSender=nil
	self.chatReport=nil
	self.canSand=nil
	self.txtSize=nil
	self.themeBoxLabel=nil
    self.cellHight=nil
    self.awardHeight=nil
    self.output=nil --侦察报告中矿点资源
	--[[
	if self.textField then
		self.textField:detachWithIME()
	end
	self.textField=nil
	]]
	--self.cursorSprite=nil

 --    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
    
 --    if G_isCompressResVersion()==true then
	-- 	CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.png")
	-- else
	-- 	CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.pvr.ccz")
	-- end
    local JidongbuduiVo = activityVoApi:getActivityVo("jidongbudui")
	if JidongbuduiVo  then
        if G_curPlatName()=="21" or G_curPlatName()=="androidarab" then
          CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/arabTurkeyImage.plist")
          CCTextureCache:sharedTextureCache():removeTextureForKey("public/arabTurkeyImage.pvr.ccz")
        end
        
        if G_curPlatName()=="13" or G_curPlatName()=="androidzhongshouyouko" or G_curPlatName()=="androidzsykonaver" or G_curPlatName()=="androidzsykoolleh" or G_curPlatName()=="androidzsykotstore" then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("koImage/koAcIconImage.plist")
        CCTextureCache:sharedTextureCache():removeTextureForKey("koImage/koAcIconImage.pvr.ccz")
        end

        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acJidongbudui.plist")
        
        if G_isCompressResVersion()==true then
        	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acJidongbudui.png")
        else
        	CCTextureCache:sharedTextureCache():removeTextureForKey("public/acJidongbudui.pvr.ccz")
        end
    end
    spriteController:removePlist("public/allianceWar2/allianceWar2.plist")
    spriteController:removePlist("public/dailyNews.plist")
    spriteController:removeTexture("public/dailyNews.png")
    spriteController:removePlist("public/acThfb.plist")
    spriteController:removeTexture("public/acThfb.png")
    self.cellHeightTb={}
    self.headlinesData=nil
	self=nil
end






