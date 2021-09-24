expeditionReportDialog=commonDialog:new()

function expeditionReportDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
	self.normalHeight=120
	-- self.writeBtn=nil
	-- self.deleteBtn=nil
	-- self.unreadLabel=nil
	-- self.totalLabel=nil
	self.tvHeight=nil
	self.canClick=false
	self.mailClick=0
	self.noEmailLabel=nil
	
    self.bgLayer=nil
    self.layerNum=nil

	spriteController:addPlist("serverWar/serverWar.plist")
	spriteController:addTexture("serverWar/serverWar.pvr.ccz")
	spriteController:addPlist("public/emailNewUI.plist")
   	spriteController:addTexture("public/emailNewUI.png")
	
    return nc
end

-- function expeditionReportDialog:init(layerNum,selectedTabIndex,emailDialog)
--     self.bgLayer=CCLayer:create()
--     self.layerNum=layerNum
-- 	self.selectedTabIndex=selectedTabIndex
-- 	self.emailDialog=emailDialog
--     self:initTableView()
    
--     return self.bgLayer
-- end

--设置对话框里的tableView
function expeditionReportDialog:initTableView()
	self.tvWidth=G_VisibleSizeWidth-40
	self.tvHeight=self.bgLayer:getContentSize().height-215+80

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
	self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,30))
	self.tvBg:setOpacity(0)
	self.bgLayer:addChild(self.tvBg)
	
	self.noEmailLabel=GetTTFLabel(getlocal("alliance_war_no_record"),30)
	self.noEmailLabel:setPosition(getCenterPoint(self.tvBg))
	self.noEmailLabel:setColor(G_ColorGray)
	self.tvBg:addChild(self.noEmailLabel,2)
	self.noEmailLabel:setVisible(false)

	local flag=expeditionVoApi:getFlag()
	-- local listNum=expeditionVoApi:getNum()
	-- local totalNum=expeditionVoApi:getTotalNum()
	-- if totalNum>listNum then
	if flag==-1 then
		local function expeditionGetlogHandler(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
            	if sData.data and sData.data.expeditionlog then
            		expeditionVoApi:deleteAll()
	        		expeditionVoApi:addReport(sData.data.expeditionlog)
	        		if(self.tvWidth and self.tvHeight)then
			        	self:initTv()
			        end
		            if expeditionVoApi:getNum()==0 and self.noEmailLabel then
						self.noEmailLabel:setVisible(true)
					end
					expeditionVoApi:setFlag(1)
				end
	        end
	    end
	    socketHelper:expeditionGetlog(expeditionGetlogHandler)
	else
		self:initTv()
		if expeditionVoApi:getNum()==0 and self.noEmailLabel then
			self.noEmailLabel:setVisible(true)
		end
	end

end

function expeditionReportDialog:initTv()
	local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp((G_VisibleSizeWidth-self.tvWidth)/2,35))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)
end

-- function expeditionReportDialog:getDataByType(type)
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
function expeditionReportDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num=expeditionVoApi:getNum()
		-- local hasMore=expeditionVoApi:hasMore()
		-- if hasMore then
		-- 	num=num+1
		-- end
		return num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.tvWidth,self.normalHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		
		-- local hasMore=expeditionVoApi:hasMore()
		-- local num=expeditionVoApi:getNum()

		local rect = CCRect(0, 0, 50, 50)
		local capInSet = CCRect(20, 20, 10, 10)
		local capInSetNew=CCRect(20, 20, 10, 10)
		local function cellClick(hd,fn,idx)
			return self:cellClick(idx)
		end
		local backSprie
		-- if hasMore and idx==num then
		-- 	backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
		-- 	backSprie:setContentSize(CCSizeMake(self.tvWidth,self.normalHeight-2))
		-- 	backSprie:ignoreAnchorPointForPosition(false);
		-- 	backSprie:setAnchorPoint(ccp(0,0));
		-- 	backSprie:setTag(idx)
		-- 	backSprie:setIsSallow(false)
		-- 	backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		-- 	backSprie:setPosition(ccp(0,0));
		-- 	-- cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
		-- 	cell:addChild(backSprie,1)
			
		-- 	local moreLabel=GetTTFLabel(getlocal("showMoreTen"),30)
		-- 	moreLabel:setPosition(getCenterPoint(backSprie))
		-- 	backSprie:addChild(moreLabel,2)
			
		-- 	return cell
		-- end

		local list=expeditionVoApi:getReportList()
		local reportVo=list[idx+1] or {}
		local time=reportVo.time
		local enemyName=reportVo.enemyName
		local enemyLevel=reportVo.enemyLevel
		local place=reportVo.place
		local isVictory=reportVo.isVictory
		local isAttacker=reportVo.type

		-- if isVictory==1 then
			backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("newReadBg.png",CCRect(5,5,1,1),cellClick)
		-- else
		-- 	backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgNoRead.png",capInSet,cellClick)
		-- end
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
		
		-- local emailIcon
		-- if isRead==1 then
		-- 	emailIcon=CCSprite:createWithSpriteFrameName("letterIconRead.png")
		-- else
		-- 	emailIcon=CCSprite:createWithSpriteFrameName("letterIconNoRead.png")
		-- end
		-- emailIcon:setPosition(ccp(50,bgHeight/2))
		-- backSprie:addChild(emailIcon,2)

		local placeBg=CCSprite:createWithSpriteFrameName("HeaderBg.png")
		placeBg:setAnchorPoint(ccp(0,1))
		placeBg:setPosition(ccp(10,bgHeight-10))
		backSprie:addChild(placeBg,2)
		local placeLb=GetTTFLabelWrap(getlocal("expeditionReportIndex",{place}),22,CCSizeMake(placeBg:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		placeLb:setAnchorPoint(ccp(0.5,0.5))
		placeLb:setPosition(ccp(placeBg:getContentSize().width/2-15,placeBg:getContentSize().height/2))
		placeBg:addChild(placeLb,2)
		placeLb:setColor(G_ColorYellowPro)


		local timeStr=G_getDataTimeStr(time)
		local timeLabel=GetTTFLabel(timeStr,22)
		timeLabel:setAnchorPoint(ccp(0.5,0.5))
		timeLabel:setPosition(260,bgHeight-30)
		backSprie:addChild(timeLabel,2)
		
		-- local rankStr=""
		-- local color=G_ColorWhite
		-- if rankChange==0 then
		-- 	rankStr=getlocal("arena_rank_no_change")
		-- elseif rankChange>0 then
		-- 	rankStr=getlocal("arena_rank_up",{rankChange})
		-- 	color=G_ColorGreen
		-- else
		-- 	rankStr=getlocal("arena_rank_down",{0-rankChange})
		-- 	color=G_ColorRed
		-- end
		-- local rankChangeLabel=GetTTFLabelWrap(rankStr,22,CCSizeMake(bgWidth/3,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		-- rankChangeLabel:setAnchorPoint(ccp(0.5,0.5))
		-- rankChangeLabel:setColor(color)
		-- cell:addChild(rankChangeLabel,2)
		-- rankChangeLabel:setPosition(bgWidth-260,bgHeight-30)

		
		local holdLabel=GetTTFLabel(getlocal("expeditionHold"),22)
		holdLabel:setAnchorPoint(ccp(0,0.5))
		cell:addChild(holdLabel,2)
		holdLabel:setPosition(20,30)
		local nameLabel=GetTTFLabelWrap("【"..enemyName.."】"..G_LV()..enemyLevel,22,CCSizeMake(bgWidth/3*2-holdLabel:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		nameLabel:setAnchorPoint(ccp(0,0.5))
		cell:addChild(nameLabel,2)
		nameLabel:setPosition(holdLabel:getContentSize().width+20,30)
		nameLabel:setColor(G_ColorGreen)


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
			local function realShow(reportVo)
				if reportVo.report==nil or SizeOfTable(reportVo.report)==0 then
					smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("fight_content_result_no_play"),true,self.layerNum+1)
				else
					local isAttacker=false
					if reportVo.type==1 then
						isAttacker=true
					end
					local data={data=reportVo,isAttacker=isAttacker,isReport=true}
					battleScene:initData(data)
				end
			end
			if reportVo.isRead==true then
				realShow(reportVo)
			else
				expeditionVoApi:readReport(reportVo.rid,realShow)
			end
		end
		local resultSp
		local scale=1
		if isVictory==1 then
			resultSp=LuaCCSprite:createWithSpriteFrameName("winnerMedal.png",showBattle)
		else
			resultSp=LuaCCSprite:createWithSpriteFrameName("loserMedal.png",showBattle)
		end
		resultSp:setScale(scale)
    	resultSp:setPosition(ccp(bgWidth-resultSp:getContentSize().width/2*scale-10,bgHeight/2))
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
function expeditionReportDialog:cellClick(idx)
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

		local num=expeditionVoApi:getNum()
		if self.mailClick==0 then
			self.mailClick=1
			local reportVoTab=expeditionVoApi:getReportList()
			local reportVo=reportVoTab[idx+1]
			if reportVo==nil then
				do return end
			end
			local function realShow(reportVo)
				self:showDetailDialog(reportVo)
			end
			if reportVo.isRead==true then
				realShow(reportVo)
			else
				expeditionVoApi:readReport(reportVo.rid,realShow)
			end
		end
    end
end

function expeditionReportDialog:showDetailDialog(report)
	if report then
		-- require "luascript/script/game/scene/gamedialog/expedition/expeditionReportDetailDialog"
		require "luascript/script/game/scene/gamedialog/arenaDialog/reportDetailNewDialog"
		local layerNum=self.layerNum+1
		-- local td=expeditionReportDetailDialog:new(layerNum,report)
		local td=reportDetailNewDialog:new(layerNum,report,nil,nil,3)
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("arena_report_title"),false,layerNum)
		sceneGame:addChild(dialog,layerNum)
	end
end

function expeditionReportDialog:tick()
	if self.mailClick>0 then
		self.mailClick=0
	end
	local flag=expeditionVoApi:getFlag()
	if flag==0 then
		self:refresh()
		expeditionVoApi:setFlag(1)
	end
end

function expeditionReportDialog:refresh()
	if self~=nil then
		if self.noEmailLabel then
			if expeditionVoApi:getNum()==0 then
				self.noEmailLabel:setVisible(true)
			else
				self.noEmailLabel:setVisible(false)
			end
		end
		if self.tv~=nil then
			self.tv:reloadData()
		end
	end
end

function expeditionReportDialog:dispose()
	self.mailClick=nil
	self.canClick=nil
	self.normalHeight=nil
	-- self.writeBtn=nil
	-- self.deleteBtn=nil
	-- self.unreadLabel=nil
	-- self.totalLabel=nil
	self.tvHeight=nil
	self.noEmailLabel=nil
	
    self.bgLayer=nil
    self.layerNum=nil

	spriteController:removePlist("serverWar/serverWar.plist")
	spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
	spriteController:removePlist("public/emailNewUI.plist")
  	spriteController:removeTexture("public/emailNewUI.png")
end






