serverWarLocalRewardTab1={}
function serverWarLocalRewardTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.cellWidth=616
	self.cellHeight=150
	return nc
end

function serverWarLocalRewardTab1:init(layerNum,parent)
	self.layerNum=layerNum
	self.parent=parent
	self.bgLayer=CCLayer:create()
	self:initLayer()
	return self.bgLayer
end

function serverWarLocalRewardTab1:initLayer()
    local descStr=getlocal("serverWarLocal_reward_desc")
    -- descStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local descLb=GetTTFLabelWrap(descStr,25,CCSizeMake(G_VisibleSizeWidth-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0,0.5))
    descLb:setPosition(ccp(35,G_VisibleSizeHeight-200))
    descLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(descLb)

	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,G_VisibleSizeHeight-220-50),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(12,40)
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)
	return self.bgLayer
end

function serverWarLocalRewardTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local rankRewardCfg=serverWarLocalCfg.AllianceReward
        local num=SizeOfTable(rankRewardCfg)
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize = CCSizeMake(self.cellWidth,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local rCfg=serverWarLocalCfg.AllianceReward[idx+1]

        local range
        local pic
        local titleStr=""
        local dayNum=0
        local rewardTb={}
        local point=0
        if rCfg then
            range=rCfg.range
            if rCfg.icon then
                pic=rCfg.icon
            end
            if rCfg.title then
                titleStr=getlocal(rCfg.title)
            end
            if rCfg.lastTime and rCfg.lastTime[1] then
                dayNum=tonumber(rCfg.lastTime[1])
            end

            if rCfg.reward then
                rewardTb=FormatItem(rCfg.reward)
            end
            if rCfg.point then
                point=tonumber(rCfg.point)
            end
        end

        local cellWidth=self.cellWidth
        local cellHeight=self.cellHeight
        -- if isHasServerReward==true then
        --  cellHeight=self.cellHeight1
        -- else
        --  cellHeight=self.cellHeight2
        -- end
        local scaleY=0.65
        local function touch()
        end

        local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),touch)
        headBg:setContentSize(CCSizeMake(cellWidth,cellHeight))
        headBg:setPosition(cellWidth/2,cellHeight/2)
        cell:addChild(headBg)

        local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png",CCRect(4,4,1,1),touch)
        titleBg:setContentSize(CCSizeMake(612,45))
        titleBg:setAnchorPoint(ccp(0.5,1))
        titleBg:setPosition(cellWidth/2,cellHeight)
        headBg:addChild(titleBg)

        local rankIcon
        local rankScale=0.8
        if pic then
            rankIcon=CCSprite:createWithSpriteFrameName(pic)
            rankIcon:setScale(rankScale)
            rankIcon:setAnchorPoint(ccp(0.5,0.5))
            rankIcon:setPosition(ccp(50,cellHeight-rankIcon:getContentSize().height*rankScale/2+5))
            headBg:addChild(rankIcon,1)
        end

        -- local rankList=localWarVoApi:getFeatRank(1)
        local rankVo=nil--rankList[idx+1]

        local playerName=""
        if rankVo then
            playerName=rankVo.name or ""
        end
        local rankStr=""
        local playerStr=getlocal("local_war_feat_rank_name",{playerName})
        if idx>=0 and idx<=1 then
            if idx==0 then
                rankStr=getlocal("serverwar_first_reward")
            elseif idx==1 then
                rankStr=getlocal("serverwar_second_reward")
            -- elseif idx==2 then
            --     rankStr=getlocal("serverwar_third_reward")
            end
            if rankVo and SizeOfTable(rankVo)>0 then
                rankStr=rankStr..playerStr
            end
        else
            if range and range[1] then
                local minRank=range[1]
                if range[2] then
                    local maxRank=range[2]
                    if minRank==maxRank then
                        rankStr=getlocal("serverwar_rank_reward",{minRank})
                    else
                        rankStr=getlocal("serverwar_rank_reward",{minRank.."-"..maxRank})
                    end
                else
                    rankStr=getlocal("serverwar_rank_reward",{minRank})
                end
            end
        end
        -- rankStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local rankLb=GetTTFLabelWrap(rankStr,25,CCSizeMake(cellWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        rankLb:setAnchorPoint(ccp(0.5,0.5))
        rankLb:setPosition(getCenterPoint(titleBg))
        rankLb:setColor(G_ColorYellowPro)
        titleBg:addChild(rankLb,1)
        -- if rankIcon then
        --     rankLb:setPosition(ccp(rankIcon:getContentSize().width*rankScale+10,headBg:getContentSize().height/2))
        -- end

        -- local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
        -- backSprie:setContentSize(CCSizeMake(cellWidth-10,cellHeight-headBg:getContentSize().height*scaleY))
        -- backSprie:ignoreAnchorPointForPosition(false)
        -- backSprie:setAnchorPoint(ccp(0.5,1))
        -- backSprie:setIsSallow(false)
        -- backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
        -- backSprie:setPosition(ccp(cellWidth/2,cellHeight-headBg:getContentSize().height*scaleY))
        -- cell:addChild(backSprie,1)

        local backHeight=cellHeight-headBg:getContentSize().height*scaleY
        local pointStr=getlocal("serverwar_reward_desc2",{point})
        local pointLb=GetTTFLabelWrap(pointStr,25,CCSizeMake(headBg:getContentSize().width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        pointLb:setAnchorPoint(ccp(0.5,0.5))
        pointLb:setPosition(cellWidth/2,(cellHeight-titleBg:getContentSize().height)/2)
        cell:addChild(pointLb,1)
        -- pointLb:setScaleY(1/scaleY)
        pointLb:setColor(G_ColorYellowPro) 

        -- if rewardTb and SizeOfTable(rewardTb)>0 then
        --     local iconSize=100
        --     for k,v in pairs(rewardTb) do
        --         local function callback11()
        --             if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        --                 return true
        --             end
        --         end
        --         local icon,scale=G_getItemIcon(v,iconSize,true,self.layerNum,callback11)
        --         icon:setTouchPriority(-(self.layerNum-1)*20-2)
        --         icon:setPosition(iconSize/2+50+(iconSize+20)*(k-1),backHeight/2)
        --         cell:addChild(icon,1)

        --         local numStr="x"..FormatNumber(v.num)
        --         local numLb=GetTTFLabel(numStr,25)
        --         numLb:setAnchorPoint(ccp(1,0))
        --         numLb:setPosition(ccp(icon:getContentSize().width-5,5))
        --         numLb:setScale(1/scale)
        --         icon:addChild(numLb,1)
        --     end
        -- end 

        -- local desc2=getlocal("serverwar_reward_desc2",{point})
        -- -- desc2="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        -- local descLb2=GetTTFLabelWrap(desc2,25,CCSizeMake(headBg:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        -- descLb2:setAnchorPoint(ccp(0,0.5))
        -- descLb2:setPosition(ccp(20,backHeight/2))
        -- headBg:addChild(descLb2,1)
        -- descLb2:setColor(G_ColorYellowPro) 

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    end
end


function serverWarLocalRewardTab1:tick()

end

function serverWarLocalRewardTab1:dispose()
	self.bgLayer:removeFromParentAndCleanup(true)
	self.layerNum=nil
	self.bgLayer=nil
end
