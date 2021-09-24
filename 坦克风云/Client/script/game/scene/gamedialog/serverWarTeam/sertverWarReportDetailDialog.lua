sertverWarReportDetailDialog=commonDialog:new()

function sertverWarReportDetailDialog:new(layerNum,report,chatReport)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.layerNum=layerNum
	self.report=report

 --    self.emailType=type
	-- self.target=replyTarget
	-- self.theme=replyTheme
	-- self.chatSender=chatSender
	self.chatReport=chatReport
	-- self.isAllianceEmail=isAllianceEmail

	self.replayBtn=nil
	-- self.attackBtn=nil
	-- self.writeBtn=nil
	self.deleteBtn=nil
	self.sendBtn=nil
	-- self.feedBtn=nil

	self.sendSuccess=false
	self.canSand=true
	self.txtSize=26
	self.themeBoxLabel=nil
    self.cellHight=nil
    self.awardHeight=nil
    return nc
end

--设置对话框里的tableView
function sertverWarReportDetailDialog:initTableView()
	spriteController:addPlist("public/reportyouhua.plist")
   	spriteController:addTexture("public/reportyouhua.png")
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
	--self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-230),nil)
    --self.tv:setPosition(ccp(25,140))
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
				if serverWarTeamOutScene and serverWarTeamOutScene.setVisible then
                    serverWarTeamOutScene:setVisible(false)
                end
				local isAttacker=report.isAttacker
				local serverWarTeam=1
				local data={data=report,isAttacker=isAttacker,isReport=true,serverWarTeam=serverWarTeam}
				battleScene:initData(data,nil,10)
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
	        chatContent=report.title
			if chatContent==nil then
				chatContent=""
			end
			--如果有联盟，选择联盟还是世界；没有则世界发送到世界 1为世界
			if report.report~=nil and SizeOfTable(report.report)>0 then
				local hasAlliance=allianceVoApi:isHasAlliance()
				-- local reportData=report or {}
				local reportData={}
				for k,v in pairs(report) do
					if k=="lostShip" then
						local defLost={o={}}
						local attLost={o={}}
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
						reportData[k]={}
						reportData[k]["defenderLost"]=defLost
						reportData[k]["attackerLost"]=attLost
					else
						reportData[k]=v
					end
				end
				local isAttacker=report.isAttacker
				if hasAlliance==false then
					base.lastSendTime=base.serverTime
					local senderName=playerVoApi:getPlayerName()
					local level=playerVoApi:getPlayerLevel()
					local rank=playerVoApi:getRank()
					local language=G_getCurChoseLanguage()
                    local params={subType=1,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=language,isAllianceWar=true,isAttacker=isAttacker,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),serverWarTeam=1,title=playerVoApi:getTitle()}
					--chatVoApi:addChat(1,sender,senderName,0,"",params)
                    chatVoApi:sendChatMessage(1,sender,senderName,0,"",params)
					--mainUI:setLastChat()
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
                        local params={subType=channelType,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),language=language,isAllianceWar=true,isAttacker=isAttacker,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),serverWarTeam=1,title=playerVoApi:getTitle()}
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
	--replaySpriteMenu:setScaleX(scale)
	--replaySpriteMenu:setScaleY(scale)
	
	self.sendBtn=GetButtonItem("letterBtnSend.png","letterBtnSend_Down.png","letterBtnSend_Down.png",operateHandler,16,nil,nil)
	self.sendBtn:setScaleX(scale)
	self.sendBtn:setScaleY(scale)
	local sendSpriteMenu=CCMenu:createWithItem(self.sendBtn)
	sendSpriteMenu:setAnchorPoint(ccp(0.5,0))
	sendSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	--sendSpriteMenu:setScaleX(scale)
	--sendSpriteMenu:setScaleY(scale)
	
	local height=45
	local posXScale=self.bgLayer:getContentSize().width

	self.bgLayer:addChild(replaySpriteMenu,2)
	self.bgLayer:addChild(sendSpriteMenu,2)
	replaySpriteMenu:setPosition(ccp(posXScale/4*1,height))
	sendSpriteMenu:setPosition(ccp(posXScale/4*3,height))

	if report and (report.report==nil or SizeOfTable(report.report)==0) or (report.isBomb and report.isBomb>0) then
		self.replayBtn:setEnabled(false)
		self.sendBtn:setEnabled(false)
	end
	if self.chatReport==true then
		self.sendBtn:setEnabled(false)
	end
	
	
end

function sertverWarReportDetailDialog:getReportAccessoryhight(report)
	if self.repAcceHeight==nil then
		local function cellClick()
		end
		local backSprie5 =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
	    backSprie5:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))

	    local accessory=report.accessory or {}
		local attAccData={}
		local defAccData={}
		-- local isAttacker=serverWarTeamVoApi:isAttacker(report,self.chatSender)
		-- if isAttacker==true then
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
                local contentLb
                -- if k==1 or k==6 or k==7 then
		      		contentLb=GetTTFLabelWrap(message,28,CCSizeMake((backSprie5:getContentSize().width-50)/2, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			    -- else
			    -- 	contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake((backSprie5:getContentSize().width-50)/2, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			    -- end
			    if k==1 then
			    	contentLbHight=contentLbHight+(contentLb:getContentSize().height+100)
			    	if accessoryVoApi:isUpgradeQualityRed()==true or (attTab and SizeOfTable(attTab)>=5) or (defTab and SizeOfTable(defTab)>=5) then
			    		contentLbHight=contentLbHight+40
			    	end
		    	-- elseif k==6 then
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
function sertverWarReportDetailDialog:getcellhight( ... )
	if self.cellHight==nil then
		local contentLbHight=0
		local content,color=serverWarTeamVoApi:getReportDesc(self.report)
		for k,v in pairs(content) do
			if content[k]~=nil and content[k]~="" then
				local contentMsg=content[k]
				local message=""
				local color1=color[k] or G_ColorWhite
				if type(contentMsg)=="table" then
					message=contentMsg[1]
					color1=contentMsg[2]
				else
					message=contentMsg
				end
    --             local contentLb
		  --     	local contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(self.txtSize*22, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			 --    contentLb:setAnchorPoint(ccp(0,1))
				-- contentLbHight = contentLb:getContentSize().height+contentLbHight
				local colorTab={color1,G_ColorRed}
		        local contentLb,lbHeight=G_getRichTextLabel(message,colorTab,self.txtSize,self.txtSize*22,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		        contentLbHight = contentLbHight + lbHeight
			end
	    end
		self.cellHight=contentLbHight+80
		return (contentLbHight+80)
	else
		return self.cellHight
	end
end

function sertverWarReportDetailDialog:getCellNum()
	if self.cellNum==nil then
		if self.report==nil or SizeOfTable(self.report)==0 then
			self.cellNum=0
		else
			-- local isShowHero=serverWarTeamVoApi:isShowHero()
			-- local isShowAccessory=serverWarTeamVoApi:isShowAccessory()
			-- if isShowHero==true and isShowAccessory==true then
			-- 	return 4
			-- elseif (isShowHero==true and isShowAccessory==false) or (isShowHero==false and isShowAccessory==true) then
			-- 	return 3
			-- else
			-- 	return 2
			-- end
			local num = 2

			if G_isShowPlaneInReport(self.report,6)==true then
				num=num+1
			end

			if serverWarTeamVoApi:isShowAccessory()==true then
			   num = num + 1
			end

			if serverWarTeamVoApi:isShowHero()==true then
			   num = num + 1
			end

			if serverWarTeamVoApi:isShowSuperEquip(self.report)==true then
				num = num + 1
			end
			if G_isShowAITroopsInReport(self.report)==true then
				num=num+1
			end
			if airShipVoApi:isShowAirshipInReport(self.report)==true then
				num =num+1
			end
			self.cellNum=num
		end
	end
	return self.cellNum
end
--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function sertverWarReportDetailDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self:getCellNum()
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		local width=400
		local height=30
		local report=self.report
		if idx==0 then
			height = self:getcellhight()
		elseif idx==1 or idx==2 or idx==3 or idx==4 or idx==5 or idx==6 or idx==7 then
			local showType=self:getShowType(idx)
			if showType==5 then
				height=380
			elseif showType==1 then
				height=410
			elseif showType==2 then
				height=530
			elseif showType==3 then
				height=self:getReportAccessoryhight(report)
			elseif showType==11 then
				height=G_getAITroopsReportHeight()
			elseif showType == 12 then
				height=G_getReportAirShipLayoutHeight()
			else
				local attackerLostNum=0
				local defenderLostNum=0
				local attLost={}
				local defLost={}
				if report and report.isBomb and report.isBomb>0 then
				else
					if report.lostShip.attackerLost then
						if report.lostShip.attackerLost.o then
							attackerLostNum=SizeOfTable(report.lostShip.attackerLost.o)
						else
							attackerLostNum=SizeOfTable(report.lostShip.attackerLost)
						end
					end
				end
				if report.lostShip.defenderLost then
					if report.lostShip.defenderLost.o then
						defenderLostNum=SizeOfTable(report.lostShip.defenderLost.o)
					else
						defenderLostNum=SizeOfTable(report.lostShip.defenderLost)
					end
				end
				height=(self.txtSize+10)*(4+attackerLostNum+defenderLostNum)+50
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



		local isAttacker=report.isAttacker
		local attacker
		local defender
		if isAttacker==true then
			attacker=report.selfName
			defender=report.targetName
		else
			attacker=report.targetName
			defender=report.selfName
		end
		if attacker==nil or attacker=="" then
			attacker=getlocal("fight_content_null")
		end
		if defender==nil or defender=="" then
			defender=getlocal("fight_content_null")
		end

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


			backSprie1:setPosition(ccp(0, self:getcellhight()-60))
			local titleLabel=GetTTFLabel(getlocal("fight_content_fight_info"),30)
			titleLabel:setPosition(getCenterPoint(backSprie1))
			backSprie1:addChild(titleLabel,2)

			local content,color=serverWarTeamVoApi:getReportDesc(report)

			local cellHeight = self:getcellhight()
			local contentLbHight=0
			for k,v in pairs(content) do
				if content[k]~=nil and content[k]~="" then
					local contentMsg=content[k]
					local message=""
					local color1=color[k] or G_ColorWhite
					if type(contentMsg)=="table" then
						message=contentMsg[1]
						color1=contentMsg[2]
					else
						message=contentMsg
					end
     --                local contentLb
			  --     	local contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake(self.txtSize*22, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				 --    contentLb:setAnchorPoint(ccp(0,1))
					-- if contentLbHight==0 then
					-- 	contentLbHight = cellHeight-60
					-- end
				 --    contentLb:setPosition(ccp(20,contentLbHight))
				 --    contentLbHight = contentLbHight - contentLb:getContentSize().height
				 --    cell:addChild(contentLb,1)
			  --       if color1~=nil then
				 --        contentLb:setColor(color1)
				 --    end
				    local colorTab={color1,G_ColorRed}
                    local contentLb,lbHeight=G_getRichTextLabel(message,colorTab,self.txtSize,self.txtSize*22,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    contentLb:setAnchorPoint(ccp(0,1))
                    if contentLbHight==0 then
						contentLbHight = cellHeight-60
					end
                    contentLb:setPosition(ccp(20,contentLbHight))
                    contentLbHight = contentLbHight - lbHeight
                    cell:addChild(contentLb,1)
                    if G_isShowRichLabel()==true then
                    elseif color1 then
                        contentLb:setColor(color1)
                    end
				end
		    end
		elseif idx==1 or idx==2 or idx==3 or idx==4 or idx==5 or idx==6 or idx==7 then
			local showType=self:getShowType(idx)
			if showType==5 then
				G_addReportPlane(report,cell)
			elseif showType==11 then --AI部队
				local height = G_getAITroopsReportHeight()
				G_addAITroopsReport(self.report,cell,isAttacker,self.bgLayer:getContentSize().width-50,height,self.layerNum,6)
			elseif showType == 12 then --飞艇
				local height = G_getReportAirShipLayoutHeight()
				G_getReportAirShipLayout(cell,self.bgLayer:getContentSize().width-50,height,self.report,isAttacker)
			elseif showType==1 then
				local hCellWidth=self.bgLayer:getContentSize().width-50
				local hCellHeight=410
				local equipTitleBg =LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
			    equipTitleBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50, 50))
			    equipTitleBg:ignoreAnchorPointForPosition(false)
			    equipTitleBg:setAnchorPoint(ccp(0,0))
			    equipTitleBg:setIsSallow(false)
			    equipTitleBg:setTouchPriority(-(self.layerNum-1)*20-2)
			    cell:addChild(equipTitleBg,1)
			    equipTitleBg:setPosition(ccp(0,hCellHeight-50))

			    local equipTitleLb=GetTTFLabel(getlocal("emblem_infoTitle"),30)
				equipTitleLb:setPosition(getCenterPoint(equipTitleBg))
				equipTitleBg:addChild(equipTitleLb,2)

	            local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	            lineSp:setAnchorPoint(ccp(0.5,0.5))
	            lineSp:setPosition(ccp(hCellWidth/2,(hCellHeight-50)/2))
	            lineSp:setScaleX((hCellHeight-30)/lineSp:getContentSize().width)
	            lineSp:setRotation(90)
	            cell:addChild(lineSp,1)

				local ownerEquipStr=getlocal("emblem_emailOwn")
				local enemyEquipStr=getlocal("emblem_emailEnemy")
				local myEquip,myEquipCfg,myEquipSkill,myEquipStrong
				local enemyEquip,enemyEquipCfg,enemyEquipSkill,enemyEquipStrong
				local equipData=report.superEquip or {nil,nil}
				if equipData then
					-- if isAttacker==true then
						myEquip = equipData[1] ~= 0 and equipData[1] or nil
						enemyEquip = equipData[2] ~= 0 and equipData[2] or nil
					-- else
					-- 	myEquip = equipData[2] ~= 0 and equipData[2] or nil
					-- 	enemyEquip = equipData[1] ~= 0 and equipData[1] or nil
					-- end
					-- if myEquip then
     --                    myEquipCfg = emblemVoApi:getEquipCfgById(myEquip)
     --                    myEquipSkill = myEquipCfg.skill
     --                    myEquipStrong=myEquipCfg.qiangdu
					-- end

					-- if enemyEquip then
     --                    enemyEquipCfg = emblemVoApi:getEquipCfgById(enemyEquip)
     --                    enemyEquipSkill = enemyEquipCfg.skill
     --                    enemyEquipStrong=enemyEquipCfg.qiangdu
					-- end
				end

				local ownerEquipLb=GetTTFLabelWrap(ownerEquipStr,28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				ownerEquipLb:setAnchorPoint(ccp(0.5,0.5))
				ownerEquipLb:setPosition(ccp(hCellWidth/4,hCellHeight-85))
				cell:addChild(ownerEquipLb,2)
				ownerEquipLb:setColor(G_ColorGreen)

				local enemyEquipLb=GetTTFLabelWrap(enemyEquipStr,28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				enemyEquipLb:setAnchorPoint(ccp(0.5,0.5))
				enemyEquipLb:setPosition(ccp(hCellWidth/4*3,hCellHeight-85))
				cell:addChild(enemyEquipLb,2)
				enemyEquipLb:setColor(G_ColorRed)

				local myEquipIcon
                if myEquip then
                    myEquipIcon = emblemVoApi:getEquipIcon(myEquip,nil,nil,nil,myEquipStrong)
                else
                	myEquipIcon = emblemVoApi:getEquipIconNull()
                end
                myEquipIcon:setAnchorPoint(ccp(0.5,0))
                myEquipIcon:setPosition(ccp(hCellWidth/4,60))
                cell:addChild(myEquipIcon)
                
                local enemyEquipIcon
                if enemyEquip then
                    enemyEquipIcon = emblemVoApi:getEquipIcon(enemyEquip,nil,nil,nil,enemyEquipStrong)
                else
                	enemyEquipIcon = emblemVoApi:getEquipIconNull()
                end
                enemyEquipIcon:setAnchorPoint(ccp(0.5,0))
                enemyEquipIcon:setPosition(ccp(hCellWidth/4 * 3,60))
                cell:addChild(enemyEquipIcon)

                --我方装备信息（技能+强度）
                if myEquipSkill ~= nil then
					local mySkillLb=GetTTFLabelWrap(emblemVoApi:getEquipSkillNameById(myEquipSkill[1],myEquipSkill[2]),28,CCSizeMake(hCellWidth/2-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
					mySkillLb:setAnchorPoint(ccp(0.5,0.5))
					mySkillLb:setPosition(ccp(hCellWidth/4,30))
					cell:addChild(mySkillLb,2)
				end

                --敌方装备信息（技能+强度）
                if enemyEquipSkill ~= nil then
					local enemySkillLb=GetTTFLabel(emblemVoApi:getEquipSkillNameById(enemyEquipSkill[1],enemyEquipSkill[2]),28)
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
					local adjutants = {}
					if myHero and myHero[i] then
						local myHeroArr=Split(myHero[i],"-")
						mHid=myHeroArr[1]
						mLevel=myHeroArr[2]
						mProductOrder=myHeroArr[3]
						adjutants = heroAdjutantVoApi:decodeAdjutant(myHero[i])
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
					local eadjutants = {}
					if enemyHero and enemyHero[i] then
						local enemyHeroArr=Split(enemyHero[i],"-")
						ehid=enemyHeroArr[1]
						elevel=enemyHeroArr[2]
						eproductOrder=enemyHeroArr[3]
						eadjutants = heroAdjutantVoApi:decodeAdjutant(enemyHero[i])
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
				-- local isAttacker=serverWarTeamVoApi:isAttacker(report,self.chatSender)
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
				local perSpace=self.txtSize+10

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
	                    local contentLb
	                    -- if k==1 or k==6 or k==7 then
				      		contentLb=GetTTFLabelWrap(message,28,CCSizeMake((backSprie5:getContentSize().width-50)/2, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
					    -- else
					    -- 	contentLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake((backSprie5:getContentSize().width-50)/2, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
					    -- end
					    local contentShowLb
	                    -- if k==1 or k==6 or k==7 then
				      		contentShowLb=GetTTFLabelWrap(message,28,CCSizeMake((backSprie5:getContentSize().width-50)/2, 500),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
					    -- else
					    -- 	contentShowLb=GetTTFLabelWrap(message,self.txtSize,CCSizeMake((backSprie5:getContentSize().width-50)/2, 500),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
					    -- end
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
						            -- icon:setAnchorPoint(ccp(0.5,0.5))
						            icon:setScale(scale)
						            icon:setPosition(ccp(iWidth+iSize/2,iHeight))
						            cell:addChild(icon,1)

						    		local numLb
						    		if i==1 then
						    			numLb=GetTTFLabel((attTab[n] or 0),25)
						    		else
						    			numLb=GetTTFLabel((defTab[n] or 0),25)
						    		end
						    		-- numLb:setAnchorPoint(ccp(0.5,0.5))
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
				    	-- elseif k==6 then
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

				local attackerStr=""
				local attackerLost=""
				local defenderStr=""
				local defenderLost=""
				local repairStr=""
				local content={}
				local isBomb=report.isBomb or 0
				
				local htSpace=50
				local perSpace=self.txtSize+10
				--损失的船
				local attackerLostNum=SizeOfTable(attLost)
				local defenderLostNum=SizeOfTable(defLost)
				backSprie4:setPosition(ccp(0, perSpace*(4+attackerLostNum+defenderLostNum)+10))
				
				if isBomb>0 then
					htSpace=0
				else
					--local lostStr=""
					-- local isAttacker=serverWarTeamVoApi:isAttacker(report,self.chatSender)		
					attackerStr=getlocal("fight_content_attacker",{attacker}).."\n"
					table.insert(content,{attackerStr,htSpace})
					for k,v in pairs(attLost) do
						if v and v.name and v.num then
							attackerLost=attackerLost.."    "..(v.name).." -"..tostring(v.num).."\n"
						end
					end
					table.insert(content,{attackerLost,perSpace+htSpace,G_ColorRed})
				end
				defenderStr=defenderStr..getlocal("fight_content_defender",{defender}).."\n"
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

		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

--idx:1,2,3,4,5,6,7
--return:1.军徽，2.hero，3.accessory，4.lostTanks，5.plane,11.AI部队,12.飞艇
function sertverWarReportDetailDialog:getShowType(idx)
	if self.showTypeTb==nil then
		self.showTypeTb={}
		local isShowHero=serverWarTeamVoApi:isShowHero()
		local isShowAccessory=serverWarTeamVoApi:isShowAccessory()
		local isShowSuperEquip = serverWarTeamVoApi:isShowSuperEquip(self.report)
		local isShowPlane = G_isShowPlaneInReport(self.report,6)
		local showTypeTb = {}
		if isShowPlane == true then
	        table.insert(showTypeTb,5)
		end
		if isShowSuperEquip == true then
	        table.insert(showTypeTb,1)
		end
		if isShowHero == true then
	        table.insert(showTypeTb,2)
		end
		if G_isShowAITroopsInReport(self.report)==true then
			table.insert(showTypeTb,11)
		end
		if airShipVoApi:isShowAirshipInReport(self.report) == true then
			table.insert(showTypeTb,12)
		end
		if isShowAccessory == true then
			table.insert(showTypeTb,3)
		end
	    table.insert(showTypeTb,4)
	    self.showTypeTb=showTypeTb
	end
    return self.showTypeTb[idx]

	-- local isShowHero=serverWarTeamVoApi:isShowHero()
	-- local isShowAccessory=serverWarTeamVoApi:isShowAccessory()
	-- local showType=3
	-- if idx==1 and isShowHero==true then
	-- 	showType=1
	-- else
	-- 	if isShowAccessory==true then
	-- 		if isShowHero==true then
	-- 			if idx==2 then 
	-- 				showType=2
	-- 			end
	-- 		else
	-- 			if idx==1 then
	-- 				showType=2
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- return showType
end

	
function sertverWarReportDetailDialog:dispose()
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
    self.showTypeTb=nil
    self.cellNum=nil
	spriteController:removePlist("public/reportyouhua.plist")
   	spriteController:removeTexture("public/reportyouhua.png")
end






