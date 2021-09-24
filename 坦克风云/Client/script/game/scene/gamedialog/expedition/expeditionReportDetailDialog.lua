expeditionReportDetailDialog=commonDialog:new()

function expeditionReportDetailDialog:new(layerNum,report,chatReport)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.layerNum=layerNum
	self.report=report

	self.chatReport=chatReport

	self.replayBtn=nil
	self.deleteBtn=nil
	self.sendBtn=nil

	self.sendSuccess=false
	self.canSand=true
	self.txtSize=26
	self.themeBoxLabel=nil
    self.cellHight=nil
    self.awardHeight=nil
    return nc
end

--设置对话框里的tableView
function expeditionReportDetailDialog:initTableView()
	if self.report==nil or SizeOfTable(self.report)==0 then
		do return end
	end

	local report=self.report

	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-36))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-98))

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-180),nil)
    self.tv:setPosition(ccp(25,90))
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)


	local function operateHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        end
        PlayEffect(audioCfg.mouseClick)

		if tag==11 then
			--如果没有战斗
			if report.report==nil or SizeOfTable(report.report)==0 then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("fight_content_result_no_play"),true,self.layerNum+1)
			else
				local isAttacker=false
				if report.type==1 then
					isAttacker=true
				end
				local data={data=report,isAttacker=isAttacker,isReport=true}
				battleScene:initData(data)
			end
		elseif tag==14 then
			local function deleteCallback(fn,data)
				if base:checkServerData(data)==true then
					expeditionVoApi:deleteReport(report.rid)
					self.sendSuccess=true
					expeditionVoApi:setFlag(0)
					base:tick()
					self:close(false)
				end
			end
			if self.sendSuccess==false then
				socketHelper:expeditionDelete(report.rid,deleteCallback)
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
			if diffTime>=timeInterval then
				self.canSand=true
			end
			if self.canSand==nil or self.canSand==false then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("time_limit_prompt",{timeInterval-diffTime}),true,self.layerNum+1)
				do return end
			end
			self.canSand=false
			
			local sender=playerVoApi:getUid()
			local chatContent
			-- if report.type==1 then
				if report.isVictory==1 then
	            	chatContent=getlocal("expeditionReportWin",{report.place,report.enemyName})
	            else
	            	chatContent=getlocal("expeditionReportLose",{report.place,report.enemyName})
	            end
	        -- else
	        -- 	if report.isVictory==1 then
	        --     	chatContent=getlocal("arena_report_chat_msg2",{report.enemyName})
	        --     else
	        --     	chatContent=getlocal("arena_report_chat_msg3",{report.enemyName})
	        --     end
	        -- end
			if chatContent==nil then
				chatContent=""
			end
			--如果有联盟，选择联盟还是世界；没有则世界发送到世界 1为世界
			if report.report~=nil and SizeOfTable(report.report)>0 then
				local hasAlliance=allianceVoApi:isHasAlliance()
				local reportData=report.report or {}
				-- local reportData={}
				-- for k,v in pairs(report) do
				-- 	if k=="resource" then
				-- 		local resData={u={}}
				-- 		if v and SizeOfTable(v)>0 then
				-- 			for m,n in pairs(v) do
				-- 				if resData.u[m]==nil then
				-- 					resData.u[m]={}
				-- 				end
				-- 				resData.u[m][n.key]=n.num
				-- 			end
				-- 		end
				-- 		reportData[k]=resData
				-- 	elseif k=="award" then
				-- 		reportData[k]={}
				-- 		if report.report and report.report.r and type(report.report.r)=="table" then
				-- 			reportData[k]=report.report.r
				-- 		end
				-- 	elseif k=="lostShip" then
				-- 		local defLost={o={}}
				-- 		local attLost={o={}}
				-- 		if v and v.defenderLost then
				-- 			for m,n in pairs(v.defenderLost) do
				-- 				if defLost.o[m]==nil then
				-- 					defLost.o[m]={}
				-- 				end
				-- 				defLost.o[m][n.key]=n.num
				-- 			end
				-- 		end
				-- 		if v and v.attackerLost then
				-- 			for m,n in pairs(v.attackerLost) do
				-- 				attLost.o[m]={}
				-- 				if attLost.o[m]==nil then
				-- 					attLost.o[m]={}
				-- 				end
				-- 				attLost.o[m][n.key]=n.num
				-- 			end
				-- 		end
				-- 		reportData[k]={}
				-- 		reportData[k]["defenderLost"]=defLost
				-- 		reportData[k]["attackerLost"]=attLost
				-- 	else
				-- 		reportData[k]=v
				-- 	end
				-- end
				local isAttacker
				if report.type==1 then
					isAttacker=true
				else
					isAttacker=false
				end
				if hasAlliance==false then
					base.lastSendTime=base.serverTime
					local senderName=playerVoApi:getPlayerName()
					local level=playerVoApi:getPlayerLevel()
					local rank=playerVoApi:getRank()
					local language=G_getCurChoseLanguage()
                    local params={subType=1,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=language,isExpedition=true,isAttacker=isAttacker,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle()}
					chatVoApi:sendChatMessage(1,sender,senderName,0,"",params)
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
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
                        local params={subType=channelType,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),language=language,isExpedition=true,isAttacker=isAttacker,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle()}
                        local aid=playerVoApi:getPlayerAid()
                        if channelType==1 then
                        	chatVoApi:sendChatMessage(1,sender,senderName,0,"",params)
                        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
                        elseif aid then
                            chatVoApi:sendChatMessage(aid+1,sender,senderName,0,"",params)
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
                        end
                    end
                    allianceSmallDialog:selectChannelDialog("PanelHeaderPopup.png",CCSizeMake(450,350),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,sendReportHandle)
				end
			end
		end
	end
	
	local scale=0.75
	self.replayBtn=GetButtonItem("letterBtnPlay.png","letterBtnPlay_Down.png","letterBtnPlay_Down.png",operateHandler,11,nil,nil)
	self.replayBtn:setScaleX(scale)
	self.replayBtn:setScaleY(scale)
	local replaySpriteMenu=CCMenu:createWithItem(self.replayBtn)
	replaySpriteMenu:setAnchorPoint(ccp(0.5,0))
	replaySpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)

	self.deleteBtn=GetButtonItem("letterBtnDelete.png","letterBtnDelete_Down.png","letterBtnDelete_Down.png",operateHandler,14,nil,nil)
	self.deleteBtn:setScaleX(scale)
	self.deleteBtn:setScaleY(scale)
	local deleteSpriteMenu=CCMenu:createWithItem(self.deleteBtn)
	deleteSpriteMenu:setAnchorPoint(ccp(0.5,0))
	deleteSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	
	self.sendBtn=GetButtonItem("letterBtnSend.png","letterBtnSend_Down.png","letterBtnSend_Down.png",operateHandler,16,nil,nil)
	self.sendBtn:setScaleX(scale)
	self.sendBtn:setScaleY(scale)
	local sendSpriteMenu=CCMenu:createWithItem(self.sendBtn)
	sendSpriteMenu:setAnchorPoint(ccp(0.5,0))
	sendSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)

	local height=45
	local posXScale=self.bgLayer:getContentSize().width

	self.bgLayer:addChild(replaySpriteMenu,2)
	self.bgLayer:addChild(deleteSpriteMenu,2)
	self.bgLayer:addChild(sendSpriteMenu,2)
	replaySpriteMenu:setPosition(ccp(posXScale/4*1,height))
	deleteSpriteMenu:setPosition(ccp(posXScale/4*2,height))
	sendSpriteMenu:setPosition(ccp(posXScale/4*3,height))

	if report and report.report==nil or SizeOfTable(report.report)==0 then
		self.replayBtn:setEnabled(false)
		self.sendBtn:setEnabled(false)
	end
	if self.chatReport==true then
		self.deleteBtn:setEnabled(false)
		self.sendBtn:setEnabled(false)
	end
	
	
end

function expeditionReportDetailDialog:getReportAccessoryhight(report)
	if self.repAcceHeight==nil then
		local function cellClick()
		end
		local backSprie5 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
	    backSprie5:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))

	    local accessory=report.accessory or {}
		local attAccData={}
		local defAccData={}
		-- if report.type==1 then
			attAccData=accessory[1] or {}
			defAccData=accessory[2] or {}
		-- else
		-- 	attAccData=accessory[2] or {}
		-- 	defAccData=accessory[1] or {}
		-- end
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
                local contentLb=GetTTFLabelWrap(message,28,CCSizeMake((backSprie5:getContentSize().width-50)/2, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
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
function expeditionReportDetailDialog:getcellhight( ... )
	-- body
	if self.cellHight==nil then
		local time=self.report.time or 0
		local enemyName=self.report.enemyName
		local isVictory=self.report.isVictory
		local place=self.report.place
		-- local isAttacker
		-- if self.report.type==1 then
		-- 	isAttacker=true
		-- else
		-- 	isAttacker=false
		-- end

		local contentLbHight=0
		
		local titleLabel
		local msgStr1=""
		local msgStr2=""
		local msgStr3=""
		
		local color=G_ColorWhite
		-- if isAttacker==true then
			msgStr1=getlocal("expeditionReportDesc",{place,enemyName})
		-- else
		-- 	msgStr1=getlocal("expeditionReportDesc",{place,enemyName})
		-- end
		msgStr2=getlocal("fight_content_time",{G_getDataTimeStr(time)})
		if isVictory==1 then
			msgStr3=getlocal("expeditionReportResult",{getlocal("fight_win")})
		else
			msgStr3=getlocal("expeditionReportResult",{getlocal("fight_defeated")})
		end
		local content={msgStr1,msgStr2,msgStr3}
		
		for k,v in pairs(content) do
			if content[k]~=nil and content[k]~="" then
				local contentMsg=content[k]
				local message=""
				if type(contentMsg)=="table" then
					message=contentMsg[1]
				else
					message=contentMsg
				end
                local contentLb
                local contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(self.txtSize*22, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			    contentLb:setAnchorPoint(ccp(0,1))
				contentLbHight = contentLb:getContentSize().height+contentLbHight
			end
	    end
		self.cellHight=contentLbHight+80
		return (contentLbHight+80)
	else
		return self.cellHight
	end
end
--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function expeditionReportDetailDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if self.report==nil or SizeOfTable(self.report)==0 then
			return 0
		else
			local num=2
			local isShowHero=expeditionVoApi:isShowHero()
			local isShowAccessory=expeditionVoApi:isShowAccessory()
			local isShowEmblem=expeditionVoApi:isShowEmblem(self.report)
			local isShowPlane=G_isShowPlaneInReport(self.report,3)
			if(isShowPlane)then
				num=num + 1
			end
			if(isShowHero)then
				num=num + 1
			end
			if(isShowAccessory)then
				num=num + 1
			end
			if(isShowEmblem)then
				num=num + 1
			end
			return num
		end
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		local width=400
		local height=30
		local report=self.report
		if idx==0 then
			height = self:getcellhight()
		elseif idx==1 or idx==2 or idx==3 or idx==4 or idx==5 then
			local showType=self:getShowType(idx)
			if(showType==5)then
				height=380
			elseif(showType==1)then
				height=410
			elseif showType==2 then
				height=530
			elseif showType==3 then
				height=self:getReportAccessoryhight(report)
			else
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
				-- local attackerLostNum=0
				-- local defenderLostNum=0
				-- local attLost={}
				-- local defLost={}
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
				-- height=(self.txtSize+30)*(4+attackerTotalNum+defenderTotalNum)+50
				if attackerTotalNum>0 or defenderTotalNum>0 then
					height=(self.txtSize+30)*(4+attackerTotalNum+defenderTotalNum)+50
				else
					height=(self.txtSize+10)*(4+attackerLostNum+defenderLostNum)+50
				end
			end
		end
		tmpSize=CCSizeMake(width,height)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local report=self.report
		if report==nil or SizeOfTable(report)==0 then
			do return end
		end
		local cell=CCTableViewCell:new()
		cell:autorelease()


		local time=report.time or 0
		local enemyName=report.enemyName
		local isVictory=report.isVictory
		local place=report.place
		-- local isAttacker
		local attacker
		local defender
		-- if report.type==1 then
		-- 	isAttacker=true
			attacker=report.name
			defender=enemyName
		-- else
		-- 	isAttacker=false
		-- 	attacker=enemyName
		-- 	defender=report.name
		-- end


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


			local titleLabel
			local msgStr1=""
			local msgStr2=""
			local msgStr3=""
			local content={}

			backSprie1:setPosition(ccp(0, self:getcellhight()-60))
			titleLabel=GetTTFLabel(getlocal("fight_content_fight_info"),30)
			
			-- if isAttacker==true then
				msgStr1=getlocal("expeditionReportDesc",{place,enemyName})
			-- else
			-- 	msgStr1=getlocal("expeditionReportDesc",{place,enemyName})
			-- end
			msgStr2=getlocal("fight_content_time",{G_getDataTimeStr(time)})
			local color
			if isVictory==1 then
				msgStr3=getlocal("expeditionReportResult",{getlocal("fight_win")})
				color=G_ColorGreen
			else
				msgStr3=getlocal("expeditionReportResult",{getlocal("fight_defeated")})
				color=G_ColorRed
			end
			content={msgStr1,msgStr2,{msgStr3,color}}

			titleLabel:setPosition(getCenterPoint(backSprie1))
			backSprie1:addChild(titleLabel,2)

			local cellHeight = self:getcellhight()

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
			      	local contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(self.txtSize*22, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				    contentLb:setAnchorPoint(ccp(0,1))
					if contentLbHight==0 then
						contentLbHight = cellHeight-60
					end
				    contentLb:setPosition(ccp(20,contentLbHight))
				    contentLbHight = contentLbHight - contentLb:getContentSize().height
				    cell:addChild(contentLb,1)
			        if color~=nil then
				        contentLb:setColor(color)
				    end
				end
		    end
		elseif idx==1 or idx==2 or idx==3 or idx==4 or idx==5 then
			local showType=self:getShowType(idx)
			print("showType",showType)
			if(showType==5)then
				G_addReportPlane(report,cell)
			elseif(showType==1)then
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

				local emblemTitleLb=GetTTFLabel(getlocal("emblem_infoTitle"),30)
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
				local isAttacker=false
				if report.type==1 then
					isAttacker=true
				end
				if emblemData then
					myEmblem = emblemData[1] ~= 0 and emblemData[1] or nil
					enemyEmblem = emblemData[2] ~= 0 and emblemData[2] or nil

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

				local ownerEmblemLb=GetTTFLabelWrap(ownerEmblemStr,28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				ownerEmblemLb:setAnchorPoint(ccp(0.5,0.5))
				ownerEmblemLb:setPosition(ccp(hCellWidth/4,hCellHeight-85))
				cell:addChild(ownerEmblemLb,2)
				ownerEmblemLb:setColor(G_ColorGreen)

				local enemyEmblemLb=GetTTFLabelWrap(enemyEmblemStr,28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
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
					local mySkillLb=GetTTFLabelWrap(emblemVoApi:getEquipSkillNameById(myEmblemSkill[1],myEmblemSkill[2]),25,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					mySkillLb:setAnchorPoint(ccp(0.5,0.5))
					mySkillLb:setPosition(ccp(hCellWidth/4,30))
					cell:addChild(mySkillLb,2)
				end
                
                --敌方装备信息（技能+强度）
                if enemyEmblemSkill ~= nil then
					local enemySkillLb=GetTTFLabel(emblemVoApi:getEquipSkillNameById(enemyEmblemSkill[1],enemyEmblemSkill[2]),25)
					enemySkillLb:setAnchorPoint(ccp(0.5,0.5))
					enemySkillLb:setPosition(ccp(hCellWidth/4*3,30))--85
					cell:addChild(enemySkillLb,2)
				end
			elseif showType==2 then
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

			    local titleLabel6=GetTTFLabel(getlocal("report_hero_message"),30)
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
				if heroData then
					-- if isAttacker==true then
						if heroData[1] then
							myHero=heroData[1][1] or {}
							myScore=heroData[1][2] or 0
						end
						if heroData[2] then
							enemyHero=heroData[2][1] or {}
							enemyScore=heroData[2][2] or 0
						end
					-- else
					-- 	if heroData[1] then
					-- 		enemyHero=heroData[1][1] or {}
					-- 		enemyScore=heroData[1][2] or 0
					-- 	end
					-- 	if heroData[2] then
					-- 		myHero=heroData[2][1] or {}
					-- 		myScore=heroData[2][2] or 0
					-- 	end
					-- end
				end

				local ownerHeroLb=GetTTFLabelWrap(ownerHeroStr,28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				ownerHeroLb:setAnchorPoint(ccp(0.5,0.5))
				ownerHeroLb:setPosition(ccp(hCellWidth/4,hCellHeight-85))
				cell:addChild(ownerHeroLb,2)
				ownerHeroLb:setColor(G_ColorGreen)

				local enemyHeroLb=GetTTFLabelWrap(enemyHeroStr,28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
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
                    local adjutants={}
					if myHero and myHero[i] then
						local myHeroArr=Split(myHero[i],"-")
						mHid=myHeroArr[1]
						mLevel=myHeroArr[2]
						mProductOrder=myHeroArr[3]
						adjutants=heroAdjutantVoApi:decodeAdjutant(myHero[i])
					end
					local myIcon=heroVoApi:getHeroIcon(mHid,mProductOrder,false,nil,nil,nil,nil,{adjutants=adjutants,showAjt=true})
					if myIcon then
						myIcon:setScale(iconSize/myIcon:getContentSize().width)
						myIcon:setPosition(ccp(posX,posY))
						cell:addChild(myIcon,2)
					end

					local ehid=nil
					local elevel=nil
					local eproductOrder=nil
                    local eadjutants={}
					if enemyHero and enemyHero[i] then
						local enemyHeroArr=Split(enemyHero[i],"-")
						ehid=enemyHeroArr[1]
						elevel=enemyHeroArr[2]
						eproductOrder=enemyHeroArr[3]
                        eadjutants=heroAdjutantVoApi:decodeAdjutant(enemyHero[i])	
					end
					posX=hCellWidth/4*3+iconSize/2+wSpace/2-math.floor((i-1)/3)*(iconSize+wSpace)
					local enemyIcon=heroVoApi:getHeroIcon(ehid,eproductOrder,false,nil,nil,nil,nil,{adjutants=eadjutants,showAjt=true})
					if enemyIcon then
						enemyIcon:setScale(iconSize/myIcon:getContentSize().width)
						enemyIcon:setPosition(ccp(posX,posY))
						cell:addChild(enemyIcon,2)
					end
				end

				local scoreLb1=GetTTFLabelWrap(scoreStr,28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				scoreLb1:setAnchorPoint(ccp(0.5,0.5))
				scoreLb1:setPosition(ccp(hCellWidth/4,85))
				cell:addChild(scoreLb1,2)
				scoreLb1:setColor(G_ColorGreen)

				local scoreLb2=GetTTFLabelWrap(scoreStr,28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				scoreLb2:setAnchorPoint(ccp(0.5,0.5))
				scoreLb2:setPosition(ccp(hCellWidth/4*3,85))
				cell:addChild(scoreLb2,2)
				scoreLb2:setColor(G_ColorGreen)

				local myScoreLb=GetTTFLabel(myScore,28)
				myScoreLb:setAnchorPoint(ccp(0.5,0.5))
				myScoreLb:setPosition(ccp(hCellWidth/4,40))
				cell:addChild(myScoreLb,2)

				local enemyScoreLb=GetTTFLabel(enemyScore,28)
				enemyScoreLb:setAnchorPoint(ccp(0.5,0.5))
				enemyScoreLb:setPosition(ccp(hCellWidth/4*3,40))
				cell:addChild(enemyScoreLb,2)
			elseif showType==3 then
				local backSprie5 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
			    backSprie5:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
			    backSprie5:ignoreAnchorPointForPosition(false)
			    backSprie5:setAnchorPoint(ccp(0,0))
			    backSprie5:setIsSallow(false)
			    backSprie5:setTouchPriority(-(self.layerNum-1)*20-2)
			    cell:addChild(backSprie5,1)

			    local titleLabel5=GetTTFLabel(getlocal("report_accessory_compare"),30)
				titleLabel5:setPosition(getCenterPoint(backSprie5))
				backSprie5:addChild(titleLabel5,2)

				local accessory=report.accessory or {}
				local attAccData={}
				local defAccData={}
				-- if isAttacker==true then
					attAccData=accessory[1] or {}
					defAccData=accessory[2] or {}
				-- else
				-- 	attAccData=accessory[2] or {}
				-- 	defAccData=accessory[1] or {}
				-- end
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
				local perSpace=self.txtSize+30

				local cellHeight=self:getReportAccessoryhight(report)
				local lbHeight=cellHeight-htSpace
				local lbWidth=backSprie5:getContentSize().width/2+10

				backSprie5:setPosition(ccp(0,lbHeight))

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
	                    local contentLb=GetTTFLabelWrap(message,28,CCSizeMake((backSprie5:getContentSize().width-50)/2, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
					    local contentShowLb=GetTTFLabelWrap(message,28,CCSizeMake((backSprie5:getContentSize().width-50)/2, 500),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
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
					    	if i==1 then
				    			accNum=SizeOfTable(attTab)
				    		else
				    			accNum=SizeOfTable(defTab)
				    		end
				    		if accNum>0 then
						    	for n=1,accNum do
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
						            icon:setScale(scale)
						            icon:setPosition(ccp(iWidth+iSize/2,iHeight))
						            cell:addChild(icon,1)

						    		local numLb
						    		if i==1 then
						    			numLb=GetTTFLabel((attTab[n] or 0),25)
						    		else
						    			numLb=GetTTFLabel((defTab[n] or 0),25)
						    		end
						    		numLb:setPosition(ccp(iWidth+iSize+15,iHeight))
						            cell:addChild(numLb,1)
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
			else
			    local backSprie4 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
			    backSprie4:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
			    backSprie4:ignoreAnchorPointForPosition(false)
			    backSprie4:setAnchorPoint(ccp(0,0))
			    backSprie4:setIsSallow(false)
			    backSprie4:setTouchPriority(-(self.layerNum-1)*20-2)
			    cell:addChild(backSprie4,1)
			
				local titleLabel4=GetTTFLabel(getlocal("fight_content_ship_lose"),30)
				titleLabel4:setPosition(getCenterPoint(backSprie4))
				backSprie4:addChild(titleLabel4,2)

				local attLost={}
				local defLost={}
				local attTotal = {}
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
				
				local htSpace=50
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
					backSprie4:setPosition(ccp(0, perSpace*(4+attackerTotalNum+defenderTotalNum)+10))
					local hCellWidth = self.bgLayer:getContentSize().width-50
					local cellHeight =backSprie4:getPositionY()
					--local cellHeight=perSpace*(4+attackerLostNum+defenderLostNum)+htSpace
					local armysContent = {getlocal("battleReport_armysName"),getlocal("battleReport_armysNums"),getlocal("battleReport_armysLosts"),getlocal("battleReport_armysleaves")}

					local showColor = {G_ColorWhite,G_ColorOrange2,G_ColorRed,G_ColorGreen}--所有需要显示的文字颜色
					local defHeight,attOrDefTotal,attOrDefLost --
					for g=1,2 do --
						if g==2 then
							if defHeight then
								cellHeight = defHeight-20
							end
						end
						if g==1 then
							personStr=getlocal("fight_content_attacker",{attacker})
							attOrDefTotal =G_clone(attTotal)
							attOrDefLost =G_clone(attLost)
						elseif g==2 then
							attOrDefTotal =G_clone(defTotal)
							attOrDefLost =G_clone(defLost)
							local defendName=defender
							personStr=defenderStr..getlocal("fight_content_defender",{defendName}).."\n"
							-- if hasHelpDefender==true then
							-- 	defendName=helpDefender
							-- end
							-- if isAttacker==true then
							-- 	if report.islandType==6 then
							-- 		personStr=defenderStr..getlocal("fight_content_defender",{defendName})
							-- 	else
							-- 		if report.islandOwner>0 then
							-- 			personStr=defenderStr..getlocal("fight_content_defender",{defendName})
							-- 		else
							-- 			personStr=defenderStr..getlocal("fight_content_defender",{G_getIslandName(islandType)})
							-- 		end
							-- 	end
							-- else
							-- 	personStr=defenderStr..getlocal("fight_content_defender",{defendName})
							-- end
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
									    localLeaves[k].num=localLeaves[k].num-localStr
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
							end						
						end						
					end
					if SizeOfTable(attOrDefTotal) >=1 then
						repairStr=getlocal("fight_content_tip_1")
						local repairLb =GetTTFLabelWrap(repairStr,25,CCSizeMake(backSprie4:getContentSize().width-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
						repairLb:setPosition(ccp(10,defHeight-70))
						repairLb:setAnchorPoint(ccp(0,0.5))
						cell:addChild(repairLb,2)
						repairLb:setColor(G_ColorOrange2)
					end
				else
					--损失的船
					local attackerLostNum=SizeOfTable(attLost)
					local defenderLostNum=SizeOfTable(defLost)
					backSprie4:setPosition(ccp(0, perSpace*(4+attackerLostNum+defenderLostNum)+10))
					
					attackerStr=getlocal("fight_content_attacker",{attacker}).."\n"
					table.insert(content,{attackerStr,htSpace})
					for k,v in pairs(attLost) do
						if v and v.name and v.num then
							attackerLost=attackerLost.."    "..(v.name).." -"..tostring(v.num).."\n"
						end
					end
					table.insert(content,{attackerLost,perSpace+htSpace,G_ColorRed})
					local defendName=defender
					defenderStr=defenderStr..getlocal("fight_content_defender",{defendName}).."\n"
					table.insert(content,{defenderStr,perSpace*attackerLostNum+perSpace+htSpace})
						for k,v in pairs(defLost) do
						if v and v.name and v.num then
							defenderLost=defenderLost.."    "..(v.name).." -"..tostring(v.num).."\n"
						end
					end
					table.insert(content,{defenderLost,perSpace*attackerLostNum+perSpace*2+htSpace,G_ColorRed})
					repairStr=getlocal("fight_content_tip_1")

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

--idx:1,2,3,4
--return: 1.emblem 2.hero，3.accessory，4.lostTanks，5.plane
function expeditionReportDetailDialog:getShowType(idx)
	local isShowHero=expeditionVoApi:isShowHero()
	local isShowAccessory=expeditionVoApi:isShowAccessory()
	local isShowEmblem = expeditionVoApi:isShowEmblem(self.report)
	local isShowPlane=G_isShowPlaneInReport(self.report,3)
	local showTypeTb={}
	if(isShowPlane)then
		table.insert(showTypeTb,5)
	end
	if(isShowEmblem)then
		table.insert(showTypeTb,1)
	end
	if(isShowHero)then
		table.insert(showTypeTb,2)
	end
	if(isShowAccessory)then
		table.insert(showTypeTb,3)
	end
	table.insert(showTypeTb,4)
	return showTypeTb[idx]
end

	
function expeditionReportDetailDialog:dispose()
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
end






