local believerReportDetailDialog=commonDialog:new()  

function believerReportDetailDialog:new(reportVo,chatReport)
    local nc={
    	reportVo=reportVo, --详情数据
		chatReport=chatReport, --是否为别人分享的战报
	    cellHeightTb={},
	    isShowGradeChange=false, --是否显示段位变化
	}
    setmetatable(nc,self)
    self.__index=self

    return nc
end

--设置对话框里的tableView
function believerReportDetailDialog:initTableView()
	if self.reportVo==nil or SizeOfTable(self.reportVo)==0 then
		self:close()
		do return end
	end

	if self.reportVo.gradeUp and self.reportVo.gradeUp>0 and self.reportVo.queueUp and self.reportVo.queueUp>0 then
		self.isShowGradeChange=true
	end
	self:computeCellHeight()

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	spriteController:addPlist("public/believer/believerMain.plist")
    spriteController:addTexture("public/believer/believerMain.png")
    spriteController:addPlist("public/squaredImgs.plist")
  	spriteController:addTexture("public/squaredImgs.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	self.panelLineBg:setVisible(false)
	if self.panelTopLine then
		self.panelTopLine:setVisible(true)
    	self.panelTopLine:setPositionY(G_VisibleSizeHeight-82)
	end

	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	local troopType=believerVoApi:getBattleType() --部队类型

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-10,G_VisibleSizeHeight-88-103),nil)
    self.tv:setPosition(ccp(5,103))
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv,1)

    local report=self.reportVo
	local function operateHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        end
        PlayEffect(audioCfg.mouseClick)
        local detail=self.reportVo.detail
        -- 播放战斗
		if tag==11 then
			--如果没有战斗
			if detail.report==nil or SizeOfTable(detail.report)==0 then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("fight_content_result_no_play"),true,self.layerNum+1)
			else
				--正在战斗
				if battleScene.isBattleing==true then
					do return end
				end
				local dataTb={}
	            dataTb.data={}
	            dataTb.data.report=detail.report
    			dataTb.landform={detail.landform,detail.landform} --敌我双方地形一致
    			-- print("detail.landform",detail.landform)
    			if dataTb.data.report and dataTb.data.report.p and dataTb.data.report.p[1] and dataTb.data.report.p[1][1] then
	            	dataTb.data.report.p[1][1]=believerVoApi:getEnemyNameStr(dataTb.data.report.p[1][1]) --对手名字
	            	-- print("dataTb.data.report.p[1][1]",dataTb.data.report.p[1][1])
	            end
	            dataTb.isReport=true
	            dataTb.battleType=troopType
	            battleScene:initData(dataTb)
			end	
		--分享战报	  
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
			local canSend=false
			if diffTime>=timeInterval then
				canSend=true
			end
			if canSend==false then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("time_limit_prompt",{timeInterval-diffTime}),true,self.layerNum+1)
				do return end
			end
			
			local sender=playerVoApi:getUid()
			local resultStr=getlocal("fight_content_result_defeat")
			if self.reportVo.isVictory>0 then
				resultStr=getlocal("fight_content_result_win")
			end
			local chatContent=getlocal("believer_record_title",{self.reportVo.enemyName,resultStr})
			--如果有联盟，选择联盟还是世界；没有则世界发送到世界 1为世界
			if detail.report~=nil and SizeOfTable(detail.report)>0 then
				local hasAlliance=allianceVoApi:isHasAlliance()
				local reportData=detail.report or {}
    			if reportData and reportData.p and reportData.p[1] and reportData.p[1][1] then
	            	reportData.p[1][1]=believerVoApi:getEnemyNameStr(reportData.p[1][1]) --对手名字
	            	-- print("reportData.p[1][1]",reportData.p[1][1])
	            end
				local isAttacker=true
				if hasAlliance==false then
					base.lastSendTime=base.serverTime
					local senderName=playerVoApi:getPlayerName()
					local level=playerVoApi:getPlayerLevel()
					local rank=playerVoApi:getRank()
					local language=G_getCurChoseLanguage()
                    local params={subType=1,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=language,isAttacker=isAttacker,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),landform=detail.landform}
                    params.battleType=troopType
                    params.brType=12
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
                        local params={subType=channelType,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),language=language,isAttacker=isAttacker,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),landform=detail.landform}
                        params.battleType=troopType
                        params.brType=12
                        local aid=playerVoApi:getPlayerAid()
                        if channelType==1 then
                        	chatVoApi:sendChatMessage(1,sender,senderName,0,"",params)
                        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
                        elseif aid then
                            chatVoApi:sendChatMessage(aid+1,sender,senderName,0,"",params)
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
                        end
                    end
                    require "luascript/script/game/scene/gamedialog/allianceDialog/allianceSmallDialog"
                    allianceSmallDialog:selectChannelDialog("PanelHeaderPopup.png",CCSizeMake(450,350),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,sendReportHandle,true)
				end
			end
		end
	end
	
    local detail=self.reportVo.detail	
	local scale=0.75
	local replayItem=GetButtonItem("letterBtnPlay_v2.png","letterBtnPlay_Down_v2.png","letterBtnPlay_Down_v2.png",operateHandler,11,nil,nil)
	replayItem:setScaleX(scale)
	replayItem:setScaleY(scale)
	local replaySpriteMenu=CCMenu:createWithItem(replayItem)
	replaySpriteMenu:setAnchorPoint(ccp(0.5,0))
	replaySpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	
	local sendItem=GetButtonItem("letterBtnSend_v2.png","letterBtnSend_Down_v2.png","letterBtnSend_Down_v2.png",operateHandler,16,nil,nil)
	sendItem:setScaleX(scale)
	sendItem:setScaleY(scale)
	local sendSpriteMenu=CCMenu:createWithItem(sendItem)
	sendSpriteMenu:setAnchorPoint(ccp(0.5,0))
	sendSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)

	local height=50
	local posXScale=self.bgLayer:getContentSize().width

	self.bgLayer:addChild(replaySpriteMenu,2)
	self.bgLayer:addChild(sendSpriteMenu,2)
	replaySpriteMenu:setPosition(ccp(posXScale/4*1,height))
	sendSpriteMenu:setPosition(ccp(posXScale/4*3,height))

	if detail.report==nil or SizeOfTable(detail.report)==0 then
		replayItem:setEnabled(false)
		sendItem:setEnabled(false)
	end
	if self.chatReport==true then
		sendItem:setEnabled(false)
	end
end

--战报基本信息
function believerReportDetailDialog:getReportContent(colorFlag)
	local enemyNameStr=getlocal("believer_battle_record_desc",{self.reportVo.enemyName}) --挑战对手昵称
	local resultStr=getlocal("fight_content_result_defeat") --挑战结果
	if self.reportVo.isVictory>0 then
		resultStr=getlocal("fight_content_result_win")
	end
	resultStr=getlocal("expeditionReportResult",{"<rayimg>"..resultStr.."<rayimg>"})
	local timeStr=getlocal("fight_content_time",{self.reportVo.timeStr}) --发生战斗的时间
	local pointStr=getlocal("believer_point",{"+"..(self.reportVo.score or 0)}) --战斗获得积分
	local weatherStr=believerVoApi:getWeatherStr(self.reportVo.detail.weather) --天气
	local landformStr=getlocal("believer_match_landform_effect_"..(self.reportVo.detail.ocean or 1)) --地形
	local content={enemyNameStr,resultStr,timeStr,pointStr,weatherStr,landformStr}
	local colorTb=nil
	if colorFlag and colorFlag==true then
		local nameStrColor={}
		local resultStrColor={}
		if self.reportVo.isVictory>0 then
			resultStrColor={nil,G_ColorGreen,nil}
		else
			resultStrColor={nil,G_ColorRed,nil}
		end
		local pointStrColor={nil,G_ColorGreen,nil}
		local weatherStrColor={nil,nil,nil,nil,G_ColorGreen,nil}
		if G_getCurChoseLanguage() == "de" then
			weatherStrColor = {nil,nil,nil,nil,nil,G_ColorGreen,nil,nil}
		end
		local landformStrColor={nil,G_ColorGreen,nil}
		colorTb={nameStrColor,resultStrColor,{},pointStrColor,weatherStrColor,landformStrColor}
	end
	return content,colorTb
end

function believerReportDetailDialog:computeCellHeight()
	local detail=self.reportVo.detail
	local cellWidth=G_VisibleSizeWidth-10
	local fontSize=25
    if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
        fontSize=22
    end
	local fontWidth=cellWidth-100
	-- 战斗信息高度
	local height=50+15+15 -- 50=标题  15=间隔
	local content=self:getReportContent()
	for k,str in pairs(content) do
		local fontLb,lbHeight=G_getRichTextLabel(str,{},fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		height=height+lbHeight+5
	end
	table.insert(self.cellHeightTb,height)

	if self.isShowGradeChange==true then
		height=50+15+190+15 --段位变化高度
		table.insert(self.cellHeightTb,height)
	end
	height=50
	if detail.kcoin and detail.kcoin>0 then
		height=height+15+100+15
	end
	table.insert(self.cellHeightTb,height)
	--部队信息高度
	height=50+15+15+200
	local troops=detail.tank --部队数据
	for k,v in pairs(troops.a) do
		height=height+60
	end
	for k,v in pairs(troops.d) do
		height=height+60
	end
	table.insert(self.cellHeightTb,height)
end

function believerReportDetailDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num=3
		if self.isShowGradeChange==true then
			num=num+1
		end
		return num
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(G_VisibleSizeWidth-10,self.cellHeightTb[idx+1])
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local fontSize=25
	    if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
	        fontSize=22
	    end

		local cellWidth=G_VisibleSizeWidth-10
		local cellHeight=self.cellHeightTb[idx+1]
			
		local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("newReportTitleBg.png",CCRect(19,0,2,47),function()end)
	    titleBg:setContentSize(CCSizeMake(cellWidth-20,47))
	    titleBg:setAnchorPoint(ccp(0.5,1))
	    titleBg:setPosition(ccp(cellWidth/2,cellHeight))
	    cell:addChild(titleBg)

	    local posX=50
	    local posY=cellHeight-titleBg:getContentSize().height-15

		if idx==0 then -- 战斗信息
			local fontWidth=cellWidth-100
			--标题
		    local titleLb=GetTTFLabelWrap(getlocal("fight_content_fight_info"),fontSize,CCSizeMake(titleBg:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			titleLb:setAnchorPoint(ccp(0.5,0.5))
			titleLb:setPosition(getCenterPoint(titleBg))
			titleBg:addChild(titleLb)

			local content,colorTb=self:getReportContent(true)
			for k,str in pairs(content) do
				local color=colorTb[k]
				local fontLb,lbHeight=G_getRichTextLabel(str,color,fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				fontLb:setAnchorPoint(ccp(0,1))
				fontLb:setPosition(posX,posY)
				cell:addChild(fontLb)
				posY=posY-lbHeight-5
			end
		else
			local detail=self.reportVo.detail
			--获取显示类型
			local showType=self:getShowType(idx)
			if showType==1 then --段位变化
				--标题
			    local titleLb=GetTTFLabelWrap(getlocal("believer_seg_change_1"),fontSize,CCSizeMake(titleBg:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				titleLb:setAnchorPoint(ccp(0.5,0.5))
				titleLb:setPosition(getCenterPoint(titleBg))
				titleBg:addChild(titleLb)

				local gradeUp,queueUp=self.reportVo.gradeUp or 0,self.reportVo.queueUp or 0
				if gradeUp>0 and queueUp>0 then
					--新旧大小段位
					local oldGrade,newGrade,newQueue,oldQueue=gradeUp,gradeUp,queueUp,queueUp
					--如果新小段位为1，则说明大段位也晋级了
					if newQueue==1 then
						oldGrade=newGrade-1
						--如果旧的大段位是青铜，则旧的小段位是1
						if oldGrade==1 then
							oldQueue=1
						else
							--否则旧的小段位为3
							oldQueue=3
						end
					else --否则大段位没变化
						oldQueue=newQueue-1
					end
					local iconWidth=130
					--旧段位
					local oldGradeSp=believerVoApi:getSegmentIcon(oldGrade,oldQueue,iconWidth)
					oldGradeSp:setPosition(ccp(posX+iconWidth/2,posY-iconWidth/2))
					cell:addChild(oldGradeSp)
					--旧名称
					local oldGradeLb=GetTTFLabelWrap(believerVoApi:getSegmentName(oldGrade,oldQueue),fontSize,CCSizeMake(iconWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
					oldGradeLb:setAnchorPoint(ccp(0.5,1))
					oldGradeLb:setPosition(ccp(oldGradeSp:getPositionX(),oldGradeSp:getPositionY()-iconWidth/2-5))
					cell:addChild(oldGradeLb)

					local directSp=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
					directSp:setAnchorPoint(ccp(0.5,0.5))
					directSp:setPosition(ccp(cellWidth/2,cellHeight/2))
					directSp:setScale(0.85)
					directSp:setRotation(180)
					cell:addChild(directSp)

					--新段位
					local newGradeSp=believerVoApi:getSegmentIcon(newGrade,newQueue,iconWidth)
					newGradeSp:setPosition(ccp(cellWidth-posX-iconWidth/2,oldGradeSp:getPositionY()))
					cell:addChild(newGradeSp)
					--新名称
					local newGradeLb=GetTTFLabelWrap(believerVoApi:getSegmentName(newGrade,newQueue),fontSize,CCSizeMake(iconWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
					newGradeLb:setAnchorPoint(ccp(0.5,1))
					newGradeLb:setPosition(ccp(newGradeSp:getPositionX(),newGradeSp:getPositionY()-iconWidth/2-5))
					cell:addChild(newGradeLb)
				end
			elseif showType==2 then --奖励
				local titleStr=getlocal("fight_award")
				if detail.kcoin==nil or detail.kcoin==0 then
					titleStr=titleStr..getlocal("fight_content_null")
				end
				--标题
			    local titleLb=GetTTFLabelWrap(titleStr,fontSize,CCSizeMake(titleBg:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				titleLb:setAnchorPoint(ccp(0.5,0.5))
				titleLb:setPosition(getCenterPoint(titleBg))
				titleBg:addChild(titleLb)

				if detail.kcoin and detail.kcoin>0 then
					local iconWidth=80
					local kCoinSp=CCSprite:createWithSpriteFrameName("believerKcoin.png")
					kCoinSp:setAnchorPoint(ccp(0.5,0.5))
					kCoinSp:setPosition(ccp(posX+65,posY-iconWidth/2))
					kCoinSp:setScale(iconWidth/kCoinSp:getContentSize().width)
					cell:addChild(kCoinSp,2)
					--名称
					local numLb = GetTTFLabelWrap("x"..detail.kcoin,fontSize,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
					numLb:setAnchorPoint(ccp(0,0.5))
					numLb:setPosition(ccp(kCoinSp:getPositionX()+iconWidth/2+10,kCoinSp:getPositionY()))
					cell:addChild(numLb)
				end

			elseif showType==3 then --部队消耗
				--标题
			    local titleLb=GetTTFLabelWrap(getlocal("fight_content_ship_lose"),fontSize,CCSizeMake(titleBg:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				titleLb:setPosition(getCenterPoint(titleBg))
				titleBg:addChild(titleLb)

				--损失的坦克
				local fleetInfo=self.reportVo.detail
				local attLost={}--当前坦克战斗完损失的数量
				local defLost={}
				local attTotal={}--当前战斗坦克的总数
				local defTotal={}
				
				--战斗损失
				local lostShip={
					attackerLost={},
					defenderLost={},
					attackerTotal={},
					defenderTotal={}
				}
				if fleetInfo.destroy then
					local attackerLost=fleetInfo.destroy.attacker
					local defenderLost=fleetInfo.destroy.defenser
					if attackerLost then
						lostShip.attackerLost=FormatItem({o=attackerLost},false)
					end
					if defenderLost then
						lostShip.defenderLost=FormatItem({o=defenderLost},false)
					end
				end
				if fleetInfo.tank then
			        local attackerTotal=fleetInfo.tank.a
			        local defenderTotal=fleetInfo.tank.d
			        if attackerTotal then
			        	lostShip.attackerTotal=FormatItem({o=attackerTotal},false)
			        end
			        if defenderTotal then
			        	lostShip.defenderTotal=FormatItem({o=defenderTotal},false)
			        end

			    end
			    if lostShip.attackerLost then
					if lostShip.attackerLost.o then
						attLost=FormatItem(lostShip.attackerLost,false)
					else
						attLost=lostShip.attackerLost
					end
				end
				if lostShip.defenderLost then
					if lostShip.defenderLost.o then
						defLost=FormatItem(lostShip.defenderLost,false)
					else
						defLost=lostShip.defenderLost
					end
				end
				if lostShip.attackerTotal then
					if lostShip.attackerTotal.o then
						attTotal=FormatItem(lostShip.attackerTotal,false)
					else
						attTotal=lostShip.attackerTotal
					end
				end
				if lostShip.defenderTotal then
					if lostShip.defenderTotal.o then
						defTotal=FormatItem(lostShip.defenderTotal,false)
					else
						defTotal=lostShip.defenderTotal
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
				local perSpace=fontSize+10

				local attackerLostNum=SizeOfTable(attLost)
				local defenderLostNum=SizeOfTable(defLost)
				local attackerTotalNum=SizeOfTable(attTotal)
				local defenderTotalNum=SizeOfTable(defTotal)
				if attackerTotalNum>0 or defenderTotalNum>0 then
					perSpace=fontSize+30
					--损失的坦克
					local armysContent={getlocal("battleReport_armysName"),getlocal("battleReport_armysNums"),getlocal("battleReport_armysLosts"),getlocal("battleReport_armysleaves")}
					local showColor={G_ColorWhite,G_ColorOrange2,G_ColorRed,G_ColorGreen}--所有需要显示的文字颜色
					local defHeight,attOrDefTotal,attOrDefLost
					for g=1,2 do 
						if g==2 then
							cellHeight=defHeight-20
						end
						if g==1 then
							personStr=getlocal("fight_content_attacker",{playerVoApi:getPlayerName()})
							attOrDefTotal=G_clone(attTotal)
							attOrDefLost=G_clone(attLost)
						elseif g==2 then
							attOrDefTotal=G_clone(defTotal)
							attOrDefLost=G_clone(defLost)
							personStr=defenderStr..getlocal("fight_content_defender",{self.reportVo.enemyName})
						end
						local attContent=GetTTFLabel(personStr,fontSize)
						attContent:setAnchorPoint(ccp(0,0.5))
						attContent:setPosition(ccp(15,cellHeight-50-(15+fontSize/2)))
						cell:addChild(attContent,2)

						if g==1 then
							attContent:setColor(G_ColorGreen)
						elseif g==2 then
							attContent:setColor(G_ColorRed)
						end

						local function sortAsc(a, b)
							if sortByIndex then
								if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
									return a.id<b.id
								end
							else
								if a.type==b.type then
									if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
										return a.id<b.id
									end
						        end
							end
					    end
						table.sort(attOrDefTotal,sortAsc)
						local lablSize=fontSize-9
						local lablSizeO=fontSize-8
						if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
							lablSize=fontSize
							lablSizeO=fontSize-3
						end
						local lbPosWIdth=6
						for k,v in pairs(armysContent) do
							local armyLb=GetTTFLabelWrap(v,lablSize,CCSizeMake(titleBg:getContentSize().width*0.1+70,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
							armyLb:setAnchorPoint(ccp(0.5,0.5))
							if k>1 then
								lbPosWIdth=7
							end
							armyLb:setPosition(ccp(cellWidth*k/lbPosWIdth-10+((k-1)*70),cellHeight-125))
						    cell:addChild(armyLb,2)
						    armyLb:setColor(showColor[k])
						end
						
						local localLeaves={}
						for i=1,4 do
							local localStr
							local pos=50
							if i ==1 then
								for k,v in pairs(attOrDefTotal) do
									if v and v.name then
										localStr=v.name
										local armyStr=GetTTFLabelWrap(localStr,lablSizeO,CCSizeMake(160,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
										armyStr:setAnchorPoint(ccp(0.5,0.5))
										armyStr:setPosition(ccp(cellWidth*i/6-10+((i-1)*70),cellHeight-125-((pos-1)*k)))
									    cell:addChild(armyStr,2)
									    armyStr:setColor(showColor[i])
						    		end
						    		if k==SizeOfTable(attOrDefTotal) then
						    			defHeight =cellHeight-125-((pos-1)*k)
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
										local armyStr=GetTTFLabelWrap(localStr,fontSize,CCSizeMake(titleBg:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
										armyStr:setAnchorPoint(ccp(0.5,0.5))
										armyStr:setPosition(ccp(cellWidth*i/7-10+((i-1)*70),cellHeight-125-((pos-1)*k)))
									    cell:addChild(armyStr,2)
									    armyStr:setColor(showColor[i])
									    
						    		end 								
								end
							end
							if i==3 then
								local lostNum
								if SizeOfTable(attOrDefLost)==0 then
									lostNum=attOrDefTotal
								elseif SizeOfTable(attOrDefLost)>0 and SizeOfTable(attOrDefLost)~=SizeOfTable(attOrDefTotal) then
									local ishere=0
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
										if ishere==1 then
											table.insert(attOrDefLost,v)
											for h,j in pairs(attOrDefLost) do
												 if j.id==v.id then
												 	j.num=0
												 end
											end
											ishere=0
										end
									end										
									lostNum=attOrDefLost
								else
									lostNum=attOrDefLost
								end
								local function sortAsc(a, b)
									if sortByIndex then
										if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
											return a.id<b.id
										end
									else
										if a.type==b.type then
											if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
												return a.id<b.id
											end
								        end
									end
							    end
								table.sort(lostNum,sortAsc)									
								for k,v in pairs(lostNum) do
									if v and v.num and SizeOfTable(attOrDefLost)>=1 then
										localStr=v.num
									else
						    			localStr=0
						    		end
										local armyStr=GetTTFLabelWrap(localStr,fontSize,CCSizeMake(titleBg:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
										armyStr:setAnchorPoint(ccp(0.5,0.5))
										armyStr:setPosition(ccp(cellWidth*i/7-10+((i-1)*70),cellHeight-125-((pos-1)*k)))
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
										local armyStr=GetTTFLabelWrap(localStr,fontSize,CCSizeMake(titleBg:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
										armyStr:setAnchorPoint(ccp(0.5,0.5))
										armyStr:setPosition(ccp(cellWidth*i/7-10+((i-1)*70),cellHeight-125-((pos-1)*k)))
									    cell:addChild(armyStr,2)
									    armyStr:setColor(showColor[i])
						    		end 								
								end
								localLeaves=nil
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
	
function believerReportDetailDialog:getShowType(idx)
	if self.isShowGradeChange==true then
		return idx
	else
		return idx+1
	end
end

function believerReportDetailDialog:dispose()
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
	end
	self.reportVo=nil
	self.chatReport=nil
    self.cellHeightTb=nil
    self.isShowGradeChange=nil
	spriteController:removePlist("public/believer/believerMain.plist")
    spriteController:removeTexture("public/believer/believerMain.png")
    spriteController:removePlist("public/squaredImgs.plist")
  	spriteController:removeTexture("public/squaredImgs.png")
end

return believerReportDetailDialog