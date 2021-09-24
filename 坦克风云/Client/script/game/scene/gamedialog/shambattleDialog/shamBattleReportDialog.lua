shamBattleReportDialog = commonDialog:new()

function shamBattleReportDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
	self.normalHeight=120
	self.writeBtn=nil
	self.deleteBtn=nil
	self.unreadLabel=nil
	self.totalLabel=nil
	self.tvHeight=nil
	self.canClick=false
	self.mailClick=0
	self.noEmailLabel=nil
	
    self.bgLayer=nil
    self.layerNum=nil

    spriteController:addPlist("public/emailNewUI.plist")
   	spriteController:addTexture("public/emailNewUI.png")
	
    return nc
end

-- function shamBattleReportDialog:init(layerNum,selectedTabIndex,emailDialog)
--     self.bgLayer=CCLayer:create()
--     self.layerNum=layerNum
-- 	self.selectedTabIndex=selectedTabIndex
-- 	self.emailDialog=emailDialog
--     self:initTableView()
    
--     return self.bgLayer
-- end

--设置对话框里的tableView
function shamBattleReportDialog:initTableView()
	self.tvWidth=G_VisibleSizeWidth-40
	self.tvHeight=self.bgLayer:getContentSize().height-240

	self.panelLineBg:setContentSize(CCSizeMake(self.tvWidth+40,G_VisibleSize.height-110))
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))

	if self.panelLineBg then
		self.panelLineBg:setVisible(false)
	end
	if self.panelTopLine then
		self.panelTopLine:setVisible(true)
    	self.panelTopLine:setPositionY(G_VisibleSizeHeight-82)
	end

	local rect = CCRect(0, 0, 50, 50);
	local capInSet = CCRect(20, 20, 10, 10);
	local function click(hd,fn,idx)
	end
	self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,click)
	self.tvBg:setContentSize(CCSizeMake(self.tvWidth,self.tvHeight+10))
	self.tvBg:ignoreAnchorPointForPosition(false)
	self.tvBg:setAnchorPoint(ccp(0.5,0))
	--self.tvBg:setIsSallow(false)
	--self.tvBg:setTouchPriority(-(self.layerNum-1)*20-2)
	self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-92-self.tvBg:getContentSize().height+5))
	self.tvBg:setOpacity(0)
	self.bgLayer:addChild(self.tvBg)
	
	self.noEmailLabel=GetTTFLabel(getlocal("alliance_war_no_record"),30)
	self.noEmailLabel:setPosition(getCenterPoint(self.tvBg))
	self.noEmailLabel:setColor(G_ColorGray)
	self.tvBg:addChild(self.noEmailLabel,2)
	self.noEmailLabel:setVisible(false)

	local flag=arenaReportVoApi:getFlag()
	-- local listNum=arenaReportVoApi:getNum()
	-- local totalNum=arenaReportVoApi:getTotalNum()
	-- if totalNum>listNum then
	if flag==-1 then
		local function militaryGetlogCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
            	if sData.data and sData.data.userarenalog then
	        		arenaReportVoApi:addReport(sData.data.userarenalog)
		        	self:initTv()
		            if arenaReportVoApi:getNum()==0 and self.noEmailLabel then
						self.noEmailLabel:setVisible(true)
					end
					arenaReportVoApi:setFlag(1)
				end
	        end
	    end
	    local isPage=nil
	    -- local minrid,maxrid=arenaReportVoApi:getMinAndMaxRid()
	    -- if minrid>0 or maxrid>0 then
	    -- 	isPage=true
	    -- end
	    local minrid,maxrid=0,0
	    socketHelper:militaryGetlog(minrid,maxrid,isPage,militaryGetlogCallback,nil,1)
	else
		self:initTv()
		if arenaReportVoApi:getNum()==0 and self.noEmailLabel then
			self.noEmailLabel:setVisible(true)
		end
	end

	local groupSelf = CCSprite:createWithSpriteFrameName("groupSelf.png")
    groupSelf:setScaleY(40/groupSelf:getContentSize().height)
    groupSelf:setScaleX(5)
    groupSelf:setPosition(ccp(G_VisibleSizeWidth*0.5+20,120))
    groupSelf:ignoreAnchorPointForPosition(false)
    self.bgLayer:addChild(groupSelf)

    local textWidth,textFontSize = 120,24
    if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage()=="ko" then
    	textWidth,textFontSize=180,20
    end
    --未读条目
    local noReadNumLb = GetTTFLabelWrap("",textFontSize,CCSizeMake(textWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noReadNumLb:setPosition(G_VisibleSizeWidth/2-textWidth/2-30,groupSelf:getPositionY())
    noReadNumLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(noReadNumLb,2)
    --总条目数
    local totalNumLb = GetTTFLabelWrap("",textFontSize,CCSizeMake(textWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    totalNumLb:setPosition(G_VisibleSizeWidth/2+textWidth/2+30,groupSelf:getPositionY())
    self.bgLayer:addChild(totalNumLb,2)
    self.noReadNumLb=noReadNumLb
    self.totalNumLb=totalNumLb

    local btnScale,priority,btnPosY = 1,-(self.layerNum-1)*20-4,60
    --一键读取
    local function onceReadHandler()
    	local function callback(fn,data)
    		local ret,sData = base:checkServerData(data)
    		if ret==true then
    			arenaReportVoApi:setIsAllRead()
    			self:refresh()
    		end
    	end
    	socketHelper:shamBattleReportReadAll(callback)
    end
    self.onceReadItem=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/2-130,btnPosY),nil,"yh_readedAll.png","yh_readedAll_Down.png","yh_readedAll_Down.png",onceReadHandler,btnScale,priority)
    --一键删除已读
    local function onceDeleteHandler()
    	local function confirm()
	    	local function callback(fn,data)
	    		local ret,sData = base:checkServerData(data)
	    		if ret==true then
	    			arenaReportVoApi:deleteAllReadReport()
	    			self:refresh()
	    		end
	    	end
	    	socketHelper:shamBattleReportDeleteAll(callback)
    	end
    	G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("email_clear_report_confirm"),false,confirm)
    end
    self.onceDeleteItem=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/2+130,btnPosY),nil,"yh_letterBtnDelete.png","yh_letterBtnDelete_Down.png","yh_letterBtnDelete_Down.png",onceDeleteHandler,btnScale,priority)

    self:refreshAllReportState()
end

function shamBattleReportDialog:refreshAllReportState()
	local tnum = arenaReportVoApi:getTotalNum()
	local urnum = arenaReportVoApi:getUnreadNum()
	if self.noReadNumLb and self.totalNumLb then
		self.noReadNumLb:setString(getlocal("email_unread_num",{urnum}))
		self.totalNumLb:setString(getlocal("email_total_num",{tnum}))
	end
	if self.onceReadItem and self.onceDeleteItem then
		if tonumber(urnum)>0 then
			self.onceReadItem:setEnabled(true)
		else
			self.onceReadItem:setEnabled(false)
		end
		if tonumber(tnum)-tonumber(urnum)>0 then
			self.onceDeleteItem:setEnabled(true)
		else
			self.onceDeleteItem:setEnabled(false)
		end
	end
end

function shamBattleReportDialog:initTv()
	local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp((G_VisibleSizeWidth-self.tvWidth)/2,G_VisibleSizeHeight-92-self.tvHeight))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)
end

-- function shamBattleReportDialog:getDataByType(type)
-- 	if type==nil then
-- 		type=1
-- 	end	
-- 	local flag=emailVoApi:getFlag(type)
-- 	local function showEmailList(fn,data)
-- 		if base:checkServerData(data)==true then
-- 		      self:refresh()										
-- 		end
-- 	end
-- 	if self.noEmailLabel then
-- 		self.noEmailLabel:setVisible(false)
-- 	end
-- 	if flag==nil or flag==-1 then
-- 		socketHelper:emailList(type,0,0,showEmailList,1)
-- 	else
-- 		self:refresh()
-- 	end
-- end


--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function shamBattleReportDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num=arenaReportVoApi:getNum()
		local hasMore=arenaReportVoApi:hasMore()
		if hasMore then
			num=num+1
		end
		return num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.tvWidth,self.normalHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		
		local hasMore=arenaReportVoApi:hasMore()
		local num=arenaReportVoApi:getNum()

		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
			return self:cellClick(idx)
		end
		local backSprie
		if hasMore and idx==num then
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
			backSprie:setContentSize(CCSizeMake(self.tvWidth,self.normalHeight-2))
			backSprie:ignoreAnchorPointForPosition(false);
			backSprie:setAnchorPoint(ccp(0,0));
			backSprie:setTag(idx)
			backSprie:setIsSallow(false)
			backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
			backSprie:setPosition(ccp(0,0));
			-- cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
			cell:addChild(backSprie,1)
			
			local moreLabel=GetTTFLabel(getlocal("showMoreTen"),30)
			moreLabel:setPosition(getCenterPoint(backSprie))
			backSprie:addChild(moreLabel,2)
			
			return cell
		end

		local list=arenaReportVoApi:getReportList()
		local reportVo=list[idx+1] or {}
		local time=reportVo.time
		local enemyName=reportVo.enemyName
		local isRead=reportVo.isRead
		local rankChange=reportVo.rankChange
		local isVictory=reportVo.isVictory
		local isAttacker=reportVo.type

		
		if isRead==1 then
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("newReadBg.png",CCRect(5,5,1,1),cellClick)
		else
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("newUnReadBg.png",CCRect(5,23,1,1),cellClick)
		end
		backSprie:setContentSize(CCSizeMake(self.tvWidth,self.normalHeight-2))
		backSprie:ignoreAnchorPointForPosition(false);
		backSprie:setAnchorPoint(ccp(0,0));
		backSprie:setTag(idx)
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:setPosition(ccp(0,0));
		-- cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
		cell:addChild(backSprie,1)

		local bgWidth=backSprie:getContentSize().width
		local bgHeight=backSprie:getContentSize().height
		
		local emailIconBg,emailIcon,typeIconName
		if isRead==1 then
			emailIconBg=LuaCCScale9Sprite:createWithSpriteFrameName("emailNewUI_readIconBg.png",CCRect(16,16,2,2),function()end)
			emailIcon=CCSprite:createWithSpriteFrameName("emailNewUI_readIcon.png")
			typeIconName="emailNewUI_fight0.png"
		else
			emailIconBg=LuaCCScale9Sprite:createWithSpriteFrameName("newChat_head_shade.png",CCRect(16,16,2,2),function()end)
			emailIcon=CCSprite:createWithSpriteFrameName("emailNewUI_unReadIcon.png")
			typeIconName="emailNewUI_fight1.png"
		end
		emailIconBg:setContentSize(CCSizeMake(backSprie:getContentSize().height,backSprie:getContentSize().height))
		emailIconBg:setAnchorPoint(ccp(0,0.5))
		emailIconBg:setPosition(0,backSprie:getContentSize().height/2)
		backSprie:addChild(emailIconBg)

		emailIcon:setPosition(getCenterPoint(emailIconBg))
		emailIconBg:addChild(emailIcon)

		if typeIconName then
			local typeIcon=CCSprite:createWithSpriteFrameName(typeIconName)
			typeIcon:setPosition(getCenterPoint(emailIconBg))
			if isRead==1 then
				typeIcon:setPositionY(typeIcon:getPositionY()-10)
			end
			emailIconBg:addChild(typeIcon)
		end

		local timeStr=G_getDataTimeStr(time)
		local timeLabel=GetTTFLabel(timeStr,22)
		timeLabel:setAnchorPoint(ccp(0,0.5))
		timeLabel:setPosition(emailIconBg:getPositionX()+emailIconBg:getContentSize().width+10,bgHeight-35)
		backSprie:addChild(timeLabel,2)
		
		local rankStr=""
		local color=G_ColorWhite
		if rankChange==0 then
			rankStr=getlocal("arena_rank_no_change")
		elseif rankChange>0 then
			rankStr=getlocal("arena_rank_up",{rankChange})
			color=G_ColorGreen
		else
			rankStr=getlocal("arena_rank_down",{0-rankChange})
			color=G_ColorRed
		end
		local rankChangeLabel=GetTTFLabelWrap(rankStr,22,CCSizeMake(bgWidth/3,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		rankChangeLabel:setAnchorPoint(ccp(0.5,0.5))
		rankChangeLabel:setColor(color)
		cell:addChild(rankChangeLabel,2)
		rankChangeLabel:setPosition(bgWidth-240,bgHeight-35)

		
		local challengeStr=""
		if isAttacker==1 then
			challengeStr=getlocal("arena_rank_challenge",{enemyName})
		else
			challengeStr=getlocal("arena_rank_defense",{enemyName})
		end
		local challengeLabel=GetTTFLabelWrap(challengeStr,22,CCSizeMake(bgWidth/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		challengeLabel:setAnchorPoint(ccp(0,0.5))
		cell:addChild(challengeLabel,2)
		challengeLabel:setPosition(timeLabel:getPositionX(),35)


		local function showBattle()
			if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
			if battleScene.isBattleing==true then
				do return end
			end

			local function fightAction()
				if reportVo.report==nil or SizeOfTable(reportVo.report)==0 then
					smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("fight_content_result_no_play"),true,self.layerNum+1)
				else
					local isAttacker=false
					if reportVo.type==1 then
						isAttacker=true
					end
					local data={data=reportVo,isAttacker=isAttacker,isReport=true}
					data.battleType=5
					battleScene:initData(data)
				end
			end

			if reportVo.initReport==false then
				local function callback(fn,data)
					local ret,sData=base:checkServerData(data)
					if ret==true then
						if sData and sData.data and sData.data.content then
							arenaReportVoApi:addReportHeroAccesoryAndLostship(reportVo.rid,sData.data.content)

							local reportVoTab=arenaReportVoApi:getReportList()
							local reportVo=reportVoTab[idx+1]
							if reportVo==nil then
								do return end
							end
							fightAction()
						end
					end
				end
				socketHelper:militaryGetContent(reportVo.rid,callback)
			else
				fightAction()
			end

			
		end
		local resultSp
		local scale=0.3
		if isVictory==1 then
			resultSp=LuaCCSprite:createWithSpriteFrameName("SuccessHeader.png",showBattle)
		else
			resultSp=LuaCCSprite:createWithSpriteFrameName("LoseHeader.png",showBattle)
		end
		resultSp:setScale(scale)
    	resultSp:setPosition(ccp(bgWidth-resultSp:getContentSize().width/2*scale-10,bgHeight/2+5))
    	resultSp:setTouchPriority(-(self.layerNum-1)*20-2)
		resultSp:setIsSallow(true)
    	cell:addChild(resultSp,2)


		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

--点击了cell或cell上某个按钮
function shamBattleReportDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
		if battleScene.isBattleing==true then
			do return end
		end
        PlayEffect(audioCfg.mouseClick)
		local num=arenaReportVoApi:getNum()
		local hasMore=arenaReportVoApi:hasMore()
		local nextHasMore=false
		if hasMore and tostring(idx)==tostring(num) then
			local function militaryGetlogCallback(fn,data)
				local ret,sData=base:checkServerData(data)
	            if ret==true then
	            	if sData.data and sData.data.userarenalog then
		        		arenaReportVoApi:addReport(sData.data.userarenalog)
		        	end

					self.canClick=true
					local newNum=arenaReportVoApi:getNum()
					local diffNum=newNum-num
					local nextHasMore=arenaReportVoApi:hasMore()
					if nextHasMore then
						diffNum=diffNum+1
					end
					local recordPoint = self.tv:getRecordPoint()
					self:refresh()
					recordPoint.y=-(diffNum-1)*self.normalHeight+recordPoint.y
					self.tv:recoverToRecordPoint(recordPoint)
					-- emailVoApi:setFlag(self.selectedTabIndex+1,1)
					arenaReportVoApi:setFlag(1)
					self.canClick=false
				end
			end
			if self.canClick==false then
				local minrid,maxrid=arenaReportVoApi:getMinAndMaxRid()
				local isPage=nil
			    if minrid>0 or maxrid>0 then
			    	isPage=true
			    end
	    		socketHelper:militaryGetlog(minrid,maxrid,isPage,militaryGetlogCallback,nil,1)
				-- socketHelper:emailList(type,mineid,maxeid,emailListCallback,1,true)
			end
		else
			if self.mailClick==0 then
				self.mailClick=1
				local reportVoTab=arenaReportVoApi:getReportList()
				local reportVo=reportVoTab[idx+1]
				if reportVo==nil then
					do return end
				end

				if reportVo.initReport==false then
					local function callback(fn,data)
						local ret,sData=base:checkServerData(data)
						if ret==true then
							if sData and sData.data and sData.data.content then
								arenaReportVoApi:addReportHeroAccesoryAndLostship(reportVo.rid,sData.data.content)

								local reportVoTab=arenaReportVoApi:getReportList()
								local reportVo=reportVoTab[idx+1]
								if reportVo==nil then
									do return end
								end
								self:checkIsRead(reportVo)
							end
						end
					end
					socketHelper:militaryGetContent(reportVo.rid,callback)
				else
					self:checkIsRead(reportVo)
				end

				-- self:showDetailDialog(reportVo)
				-- if reportVo.isRead==0 then
				-- 	local function militaryReadCallback(fn,data)
	   --                  local ret,sData=base:checkServerData(data)
	   --                  if ret==true then
	   --     --              	if sData.data and sData.data.report then
				-- 				-- local battleReport=sData.data.report
				-- 				-- arenaReportVoApi:addBattleReport(reportVo.rid,battleReport)
				-- 				-- self:showDetailDialog(reportVo)
				-- 				-- if reportVo.isRead==0 then
				-- 					arenaReportVoApi:setIsRead(reportVo.rid)
				-- 					if self==nil or self.tv==nil then
				-- 						do return end
				-- 					end
				-- 					local recordPoint = self.tv:getRecordPoint()
				-- 					self:refresh()
				-- 					self.tv:recoverToRecordPoint(recordPoint)
				-- 					self:showDetailDialog(reportVo)
				-- 			-- 	end
				-- 			-- end
				-- 		end
				-- 	end
				-- 	socketHelper:militaryRead(reportVo.rid,militaryReadCallback)
				-- else
				-- 	self:showDetailDialog(reportVo)
				-- end


				-- if (reportVo and reportVo.initReport==false) then
				-- 	local function militaryReadCallback(fn,data)
	   --                  local ret,sData=base:checkServerData(data)
	   --                  if ret==true then
	   --                  	if sData.data and sData.data.report then
				-- 				local battleReport=sData.data.report
				-- 				arenaReportVoApi:addBattleReport(reportVo.rid,battleReport)
				-- 				self:showDetailDialog(reportVo)
				-- 				if reportVo.isRead==0 then
				-- 					arenaReportVoApi:setIsRead(reportVo.rid)
				-- 					if self==nil or self.tv==nil then
				-- 						do return end
				-- 					end
				-- 					local recordPoint = self.tv:getRecordPoint()
				-- 					self:refresh()
				-- 					self.tv:recoverToRecordPoint(recordPoint)
				-- 				end
				-- 			end
				-- 		end
				-- 	end
				-- 	socketHelper:militaryRead(reportVo.rid,militaryReadCallback)
				-- else
				-- 	self:showDetailDialog(reportVo)
				-- 	if reportVo.isRead==0 then
				-- 		arenaReportVoApi:setIsRead(reportVo.rid)
				-- 		if self==nil or self.tv==nil then
				-- 			do return end
				-- 		end
				-- 		local recordPoint = self.tv:getRecordPoint()
				-- 		self:refresh()
				-- 		self.tv:recoverToRecordPoint(recordPoint)
				-- 	end
				-- end
			end
		end
    end
end

function shamBattleReportDialog:checkIsRead(reportVo)
	if reportVo.isRead==0 then
		local function militaryReadCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
--              	if sData.data and sData.data.report then
					-- local battleReport=sData.data.report
					-- arenaReportVoApi:addBattleReport(reportVo.rid,battleReport)
					-- self:showDetailDialog(reportVo)
					-- if reportVo.isRead==0 then
						arenaReportVoApi:setIsRead(reportVo.rid)
						if self==nil or self.tv==nil then
							do return end
						end
						local recordPoint = self.tv:getRecordPoint()
						self:refresh()
						self.tv:recoverToRecordPoint(recordPoint)
						self:showDetailDialog(reportVo)
				-- 	end
				-- end
			end
		end
		socketHelper:militaryRead(reportVo.rid,militaryReadCallback)
	else
		self:showDetailDialog(reportVo)
	end
end


function shamBattleReportDialog:showDetailDialog(report)
	if report then
		local layerNum=self.layerNum+1
		-- local td=reportDetailDialog:new(layerNum,report,nil,5)
		local td=reportDetailNewDialog:new(layerNum,report,nil,5)
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("arena_report_title"),false,layerNum)
		sceneGame:addChild(dialog,layerNum)
	end
end

function shamBattleReportDialog:tick()
	if self.mailClick>0 then
		self.mailClick=0
	end
	local flag=arenaReportVoApi:getFlag()
	if flag==0 then
		self:refresh()
		arenaReportVoApi:setFlag(1)
	end
end

function shamBattleReportDialog:refresh()
	if self~=nil then
		if self.noEmailLabel then
			if arenaReportVoApi:getNum()==0 then
				self.noEmailLabel:setVisible(true)
			else
				self.noEmailLabel:setVisible(false)
			end
		end
		if self.tv~=nil then
			self.tv:reloadData()
		end
		self:refreshAllReportState()
	end
end

function shamBattleReportDialog:dispose()
	self.mailClick=nil
	self.canClick=nil
	self.normalHeight=nil
	self.writeBtn=nil
	self.deleteBtn=nil
	self.unreadLabel=nil
	self.totalLabel=nil
	self.tvHeight=nil
	self.noEmailLabel=nil
	
    self.bgLayer=nil
    self.layerNum=nil

    spriteController:removePlist("public/emailNewUI.plist")
  	spriteController:removeTexture("public/emailNewUI.png")

end






