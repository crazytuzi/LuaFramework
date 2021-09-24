dailyAnswerTab2 = {}

function dailyAnswerTab2:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.normalHeight=80
    self.timer=nil--活动当前时间
    self.timeState=nil --{1:未结束 2:已结束}
    self.award=nil --{nil:未领取 有值:已领取}
    self.highScore=nil --最高排名
    self.flag=nil
    self.allList=nil --所有人的
    self.atList=nil
    self.score=nil
    self.tv=nil
    self.point=nil
	return nc
end

function dailyAnswerTab2:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self:initLayer()

	return self.bgLayer
end

function dailyAnswerTab2:initLayer()
    self.highRankStr = meiridatiCfg.rewardlimit.."+"
    local capInSet = CCRect(20, 20, 10, 10);
    local function bgClick(hd,fn,idx)
    end
    local descContentWidth,descContentHeight= G_VisibleSize.width-60,0
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    titleBg:setAnchorPoint(ccp(0,1));
    self.bgLayer:addChild(titleBg,1)
    self.titleBg=titleBg

    if dailyAnswerVoApi:getRank() == nil or dailyAnswerVoApi:getRank() ==0  then 	--
    	self.highScore={self.highRankStr}
    else
        self.highScore={dailyAnswerVoApi:getRank()}
    end
    self.descLb=GetTTFLabel(getlocal("dailyAnswer_rankingSelf",self.highScore),25)
    self.descLb:setAnchorPoint(ccp(0,1));
    titleBg:addChild(self.descLb,2);

    local rankers = meiridatiCfg.rewardlimit
    self.descLb1=GetTTFLabelWrap(getlocal("dailyAnswer_rankList",{rankers}),25,CCSizeMake(descContentWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    self.descLb1:setAnchorPoint(ccp(0,1));
    titleBg:addChild(self.descLb1,2);

    local rankLimitLb=GetTTFLabelWrap(getlocal("dailyanswer_rankLimit",{(meiridatiCfg.rankNeedPoint or 0)}),25,CCSizeMake(descContentWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    rankLimitLb:setAnchorPoint(ccp(0,1));
    titleBg:addChild(rankLimitLb,2);
    local descContentHeight = self.descLb:getContentSize().height+self.descLb1:getContentSize().height+rankLimitLb:getContentSize().height+20+4
    titleBg:setPosition(ccp(30,G_VisibleSize.height-160))
    titleBg:setContentSize(CCSizeMake(descContentWidth, descContentHeight))
    self.descLb:setPosition(ccp(15,titleBg:getContentSize().height-10));
    self.descLb1:setPosition(ccp(15,self.descLb:getPositionY()-self.descLb:getContentSize().height-2));
    rankLimitLb:setPosition(ccp(15,self.descLb1:getPositionY()-self.descLb1:getContentSize().height-2));

    local function onClickDesc()
        local sd=smallDialog:new()
        local rankRewardStr = ""
        local cfg=meiridatiCfg.rankReward
        local rewardStrTab={}
        for k,v in pairs(cfg) do
            local rank = v[1] or {}
            local award=FormatItem(v[2],nil,true)
            local str=""
            for k,v in pairs(award) do
                if k==SizeOfTable(award) then
                    str = str .. v.name .. " x" .. v.num
                else
                    str = str .. v.name .. " x" .. v.num .. ","
                end
            end
            if SizeOfTable(rank)>1 then
                rankRewardStr=rankRewardStr.."("..k..")"..getlocal("dailyanswer_rank_rewardlimit2",{rank[1],rank[2],str}).."\n"
            else
                rankRewardStr=rankRewardStr.."("..k..")"..getlocal("dailyanswer_rank_rewardlimit1",{rank[1],str}).."\n"
            end
        end

        local strTab={" ",rankRewardStr,getlocal("activity_equipSearch_rank_tip_3"),getlocal("dailyAnswer_rank2"),getlocal("dailyAnswer_rank1")," "}
        local colorTab={}
        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTab,25,colorTab)
        sceneGame:addChild(dialogLayer,self.layerNum+1)
        dialogLayer:setPosition(ccp(0,0))
    end
    local descBtnItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",onClickDesc)
    descBtnItem:setAnchorPoint(ccp(0,0.5))
    local descBtn=CCMenu:createWithItem(descBtnItem)
    descBtn:setAnchorPoint(ccp(0,0.5))
    descBtn:setPosition(ccp(titleBg:getContentSize().width-descBtnItem:getContentSize().width-30,titleBg:getContentSize().height/2))
    descBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    titleBg:addChild(descBtn,2)

    self.flag =dailyAnswerVoApi:getFlag()
    self.timer=base.serverTime
    local  openTime = meiridatiCfg.openTime[1][1]

    if self.timer<G_getWeeTs(self.timer)+openTime*60*60+meiridatiCfg.openTime[1][2]*60   then
        self.timeState=3
    elseif self.timer >=G_getWeeTs(self.timer)+openTime*60*60+meiridatiCfg.openTime[1][2]*60+20*(meiridatiCfg.choiceTime+meiridatiCfg.resultTime) then
        self.timeState=2
    else
        self.timeState=1
    end
    if self.timeState == 1 then
        if self.noOpenLb then
            self.noOpenLb:setVisible(false)
        end
        self.waitLb = GetTTFLabelWrap(getlocal("dailyAnswer_rank_noRe"),35,CCSizeMake(self.bgLayer:getContentSize().width-125,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        self.waitLb:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.5))
        self.bgLayer:addChild(self.waitLb,1)
        self.waitLb:setColor(G_ColorYellow)
    elseif self.timeState ==2 then
        self:getRankList()
        if self.waitLb then
            self.waitLb:setVisible(false)
        end
        if self.noOpenLb then
            self.noOpenLb:setVisible(false)
        end       
    elseif self.timeState ==3 then
        if self.waitLb then
            self.waitLb:setVisible(false)
        end
        self.noOpenLb=GetTTFLabelWrap(getlocal("dailyAnswer_rank_noOpenTime"),35,CCSizeMake(self.bgLayer:getContentSize().width-125,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        self.noOpenLb:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.5))
        self.bgLayer:addChild(self.noOpenLb,1)
        self.noOpenLb:setColor(G_ColorYellow)

    end
    self:updataTable()
end

function dailyAnswerTab2:FormatItem(tabl)

	local formatData={}	
	local num=0
	local name=""
	local pic=""
	local desc=""
    local id=0
	local index=0
    local eType=""
    local noUseIdx=0 --无用的index 只是占位
    local equipId
	if tabl then
		for k,v in pairs(tabl) do
			if k then
				for m,n in pairs(v) do
					if m~=nil and n~=nil then
						--local key,type1,num=m,k,n
						local type1 = m
						local key,num
						if type(n)=="table" then
							for p,q in pairs(n) do
								if type(q)=="table" then
									for i,j in pairs(q) do
										if i=="index" then
											index=j
										else
											key=i
											num=j
										end
									end
								end
								if sortByIndex then
									name,pic,desc,id,noUseIdx,eType,equipId=getItem(key,type1)
								else
									name,pic,desc,id,index,eType,equipId=getItem(key,type1)
								end
								if name and name~="" then
									if includeZore==false then
										if num>0 then
											--index=index+1
											table.insert(formatData,{name=name,num=num,pic=pic,desc=desc,id=id,type=k,index=index,key=key,eType=eType,equipId=equipId})
										end
									else
										--index=index+1
										table.insert(formatData,{name=name,num=num,pic=pic,desc=desc,id=id,type=k,index=index,key=key,eType=eType,equipId=equipId})
									end
								end
							end
						end

					end
				end
			end
		end
	end
	if formatData and SizeOfTable(formatData)>0 then
		local function sortAsc(a, b)
			if sortByIndex then
				if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
					return a.index < b.index
				end
			else
				if a.type==b.type then
					if a.index and b.index and tonumber(a.index) and tonumber(b.index) then
						return a.index < b.index
					end
		        end
			end
	    end
		table.sort(formatData,sortAsc)
	end
	return formatData
end

function dailyAnswerTab2:updataTable()
    if self.timeState ==3 then
        if self.noOpenLb then
            self.noOpenLb:setVisible(true)
        end
        if self.waitLb then
        self.waitLb:setVisible(false)
        end        
    elseif self.timeState == 1 then
        if self.waitLb then
            self.waitLb:setVisible(true)
        else
        self.waitLb = GetTTFLabelWrap(getlocal("dailyAnswer_rank_noRe"),35,CCSizeMake(self.bgLayer:getContentSize().width-125,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        self.waitLb:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.5))
        self.bgLayer:addChild(self.waitLb,1)
        self.waitLb:setColor(G_ColorYellow)
        end
        if self.noOpenLb then
            self.noOpenLb:setVisible(false)
        end
    elseif self.timeState == 2 then
        if self.waitLb then
            self.waitLb:setVisible(false)
        end
        if self.noOpenLb then
            self.noOpenLb:setVisible(false)
        end
        self:getRankList()
    end
end

function dailyAnswerTab2:getRankList( )
    local function recRankList(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret ==true then 
            if sData and sData.data and sData.data.meiridati and sData.data.meiridati.rank then
                -- self.allList=sData.data.meiridati.rank
                self.allList={}
                for k,v in pairs(sData.data.meiridati.rank) do
                    if dailyAnswerVoApi:isRank(v[4])==true and tonumber(v[3])<=meiridatiCfg.rewardlimit then --是否达到上榜条件
                        table.insert(self.allList,v)
                    end
                end
                local playerUid = playerVoApi:getUid()
                local playerName = playerVoApi:getPlayerName()
                for k,v in pairs(self.allList) do
                    if v[1] ==playerName and v[2] ==playerUid then
                        self.atList=v[3]
                    end
                end
                if self.tv ==nil then
                    self:initTableView()
                else
                    self.tv:reloadData()
                end
            end
        end
    end

    socketHelper:dailyAnswerAllRankList(recRankList)
end

--设置对话框里的tableView
function dailyAnswerTab2:initTableView()
	local height=self.bgLayer:getContentSize().height-self.titleBg:getContentSize().height-160-15
	local widthSpace=80

	local rankLabel=GetTTFLabel(getlocal("RankScene_rank"),22)--排名
	rankLabel:setPosition(widthSpace,height)
	self.bgLayer:addChild(rankLabel,2)
	rankLabel:setColor(G_ColorGreen)
	
	local nameLabel=GetTTFLabel(getlocal("RankScene_name"),22)--姓名
	nameLabel:setPosition(G_VisibleSize.width*0.5,height)
	self.bgLayer:addChild(nameLabel,2)
	nameLabel:setColor(G_ColorGreen)
	
	local pointsLabel=GetTTFLabel(getlocal("serverwar_point"),22)--积分
	pointsLabel:setPosition(G_VisibleSize.width-100,height)
	self.bgLayer:addChild(pointsLabel,2)
	pointsLabel:setColor(G_ColorGreen)

	self.tvHeight=height-rankLabel:getContentSize().height-30

	local capInSet = CCRect(20, 20, 10, 10);
    local function bgClick(hd,fn,idx)
    end
    local backBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    backBg:setContentSize(CCSizeMake(G_VisibleSize.width-60, self.tvHeight+10))
    backBg:setAnchorPoint(ccp(0,0))
    backBg:setPosition(ccp(30,30))
    self.bgLayer:addChild(backBg)


    local function rewardHandler()
        local function selfRankCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if self.atList~=self.highRankStr and self.atList ~= nil then
                    local rankReward = meiridatiCfg.rankReward
                    local selfReward = {}
                    local str={}
                    for k,v in pairs(rankReward) do
                        if self.atList>=v[1][1] and self.atList<=v[1][2] then
                            selfReward=FormatItem(v[2])
                            for k,v in pairs(selfReward) do
                                G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
                            end
                            G_showRewardTip(selfReward, true)
                            if self.rewardBtn then
                                self.rewardBtn:setEnabled(false)
                            end
                            self.award = 1
                            if self.rewardBtn then
                                tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
                            end
                        end
                    end
                end
            end
        end
        socketHelper:dailyAnswerSelfRank(selfRankCallback)
    end
    self.rewardBtn = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rewardHandler,nil,getlocal("newGiftsReward"),25,11)
    self.rewardBtn:setAnchorPoint(ccp(0.5,0))
    local rewardMenu=CCMenu:createWithItem(self.rewardBtn)
    rewardMenu:setPosition(ccp(backBg:getContentSize().width/2,15))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    backBg:addChild(rewardMenu,2)
    self.award=dailyAnswerVoApi:getFlag()
    if self.award ==nil then
        tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("newGiftsReward"))
    else
        self.rewardBtn:setEnabled(false)
        tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
    end

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.tvHeight-90),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,40+90))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)	

    if self.timeState == 1 then
        self.rewardBtn:setEnabled(false)
    elseif self.timeState ==2 then
        local uid = playerVoApi:getUid()
        if self.atList~=self.highRankStr and self.award==nil and dailyAnswerVoApi:isCanReward(self.atList)==true then 
            self.rewardBtn:setEnabled(true)
            self.timeState=1
        else
            self.rewardBtn:setEnabled(false)
        end
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function dailyAnswerTab2:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num=1
        if self.allList and SizeOfTable(self.allList)>0 then
            num=num+SizeOfTable(self.allList)
        end
        return num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-70,self.normalHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
    	local cell=CCTableViewCell:new()
		cell:autorelease()
        
        local rank  --排名
        local name  --姓名
        local point --积分

		
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick(hd,fn,idx)
		end

        if idx==0 then
            if self.atList == nil then
                rank=self.highRankStr
            else
                rank =self.atList
            end
        	--rank=self.atList or self.highRankStr
        	name=playerVoApi:getPlayerName()
            if rank==self.highRankStr then
                point =dailyAnswerVoApi:getScore()
            else
                if self.allList[self.atList] and self.atList ~=self.highRankStr then
                    point=self.allList[self.atList][4]--playerVoApi:getPlayerLevel()
                else 
                    point = 0
                end
            end

			local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
			bgSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.normalHeight/2-5));
			bgSp:setScaleY(self.normalHeight/bgSp:getContentSize().height)
			bgSp:setScaleX(1000/bgSp:getContentSize().width)
			cell:addChild(bgSp)
        else
            name=self.allList[idx][1] or ""
            rank=self.allList[idx][3] or 0
            point=self.allList[idx][4] or 0
		end
		
		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
		lineSp:setAnchorPoint(ccp(0,1));
		lineSp:setPosition(ccp(0,self.normalHeight));
		cell:addChild(lineSp,1)

        local lbSize=25
        local lbHeight=35
        local lbWidth=50

        local rankLb=GetTTFLabel(rank,lbSize)
        rankLb:setPosition(ccp(lbWidth,lbHeight))
        cell:addChild(rankLb)
        rankLb:setColor(G_ColorYellow)

        local rankSp
		if tonumber(rank)==1 then
			rankSp=CCSprite:createWithSpriteFrameName("top1.png")
		elseif tonumber(rank)==2 then
			rankSp=CCSprite:createWithSpriteFrameName("top2.png")
		elseif tonumber(rank)==3 then
			rankSp=CCSprite:createWithSpriteFrameName("top3.png")
		end
		if rankSp then
	      	rankSp:setPosition(ccp(lbWidth,lbHeight))
			cell:addChild(rankSp,2)
			rankLb:setVisible(false)
		end

        local nameLb=GetTTFLabel(name,lbSize)
        nameLb:setPosition(ccp(G_VisibleSize.width*0.5-30,lbHeight))
        cell:addChild(nameLb)

        local pointLb=GetTTFLabel(point,lbSize)
        pointLb:setPosition(ccp(G_VisibleSize.width-130,lbHeight))
        cell:addChild(pointLb)
        
    	return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function dailyAnswerTab2:tick()
end

function dailyAnswerTab2:refreshHighScore( )
    local function needHighScore(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then
            if sData.data==nil then 
                return                                
            end
        end
        if ret ==true then
            if sData and sData.data.meiridati and sData.data.meiridati.info then
                if sData.data.meiridati.info.rank then
                    local rankUpdata = sData.data.meiridati.info.rank
                    if rankUpdata ~= 0 then
                        self.highScore = {rankUpdata}
                        tolua.cast(self.descLb,"CCLabelTTF"):setString(getlocal("dailyAnswer_rankingSelf",self.highScore))
                    end
                end
                if sData.data.meiridati.info.info.flag then
                    local flagUpdata = sData.data.meiridati.info.info.flag
                    dailyAnswerVoApi:setFlag(flagUpdata)
                end
                if sData.data.meiridati.info.score then
                    dailyAnswerVoApi:setScore(sData.data.meiridati.info.score)
                end
            end
        end
        -- base.servertime
        dailyAnswerVoApi:setTime(sData.ts)
        self:updataTable()
    end
    self.point =dailyAnswerVoApi:getScore()
    socketHelper:dailyAnswerGetUserStatus(needHighScore) 
end
function dailyAnswerTab2:refresh()
    self:refreshHighScore()
    self.timer=base.serverTime--dailyAnswerVoApi:getTime()
    self.award=dailyAnswerVoApi:getFlag()

    local  openTime = meiridatiCfg.openTime[1][1]
    if self.timer<G_getWeeTs(self.timer)+openTime*60*60+meiridatiCfg.openTime[1][2]*60 then
        self.timeState=3
    elseif self.timer >=G_getWeeTs(self.timer)+openTime*60*60+meiridatiCfg.openTime[1][2]*60+20*(meiridatiCfg.choiceTime+meiridatiCfg.resultTime) then
        self.timeState=2

    else
        self.timeState=1
    end
    self.rewardBtn=nil    


    if self.rewardBtn then
        if self.award ==nil then
            tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("newGiftsReward"))
        else
            self.rewardBtn:setEnabled(false)
            tolua.cast(self.rewardBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("activity_hadReward"))
        end
    end
end
function dailyAnswerTab2:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.normalHeight=80
    self.timer=nil
    self.timeState=nil 
    self.award=nil 
    self.highScore=nil
    self.flag=nil
    self.allList=nil 
    self.atList=nil
    self.score=nil
    self.tv =nil
end
