planeInfoDialog={}

function planeInfoDialog:new(callback)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.pageRefreshFunc=callback
	return nc
end

function planeInfoDialog:init(planeId,planeList,layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.planeId=planeId
    self.planeList=planeList
    self.nameFontSize=23
    self.desFontSize=20
    -- self:setPlaneTb()

    return self.bgLayer
end

function planeInfoDialog:setPlaneTb()
    local totalNum=SizeOfTable(self.planeList)
    local curId=tonumber(RemoveFirstChar(self.planeId))
    local priorId=curId-1
    local afterId=curId+1
    if priorId<1 then
        priorId=totalNum
    end
    if afterId>totalNum then
        afterId=1
    end
    if totalNum>=3 then
        self.planeTb={priorId,curId,afterId}
    elseif totalNum==2 then
        self.planeTb={curId,afterId}
    else
        self.planeTb={curId}
    end
end

function planeInfoDialog:initTableView()
	self.tvWidth=G_VisibleSizeWidth-300
	self.tvHeight=230
	self.normalHeight=300
    -- self.iconSpTb={}

	-- for k,pid in pairs(self.planeTb) do
	-- 	local cfg=planeVoApi:getPlaneCfgById(pid)
	-- 	if cfg then

	-- 	end
	-- 	local function touchHandler()
	-- 	end
	-- 	local pic="plane_icon_p"..pid..".png"
 --        local iconSp=LuaCCSprite:createWithSpriteFrameName(pic,touchHandler)
	--     -- iconSp:setAnchorPoint(ccp(0.5,0))
	--     iconSp:setPosition(G_VisibleSizeWidth/2+(k-2)*180,G_VisibleSizeHeight-200)
	--     self.bgLayer:addChild(iconSp)
 --        self.iconSpTb[k]=iconSp
	--     if k~=2 then
	--     	iconSp:setScale(0.7)
	--     end
	-- end
	local capInSet=CCRect(20,20,10,10)
	local function nilFunc()
	end
    local infoBg=LuaCCScale9Sprite:createWithSpriteFrameName("newTitlesDesBg.png",CCRect(50,20,1,1),nilFunc)
    infoBg:setAnchorPoint(ccp(0.5,1))
    infoBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,self.normalHeight))
    infoBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-360-60))
    self.bgLayer:addChild(infoBg)
    self.infoBg=infoBg
    local offsetX=-35
    local scale=0.6
    if self.planeId =="p1" then
        scale=0.65
        offsetX=-20
    elseif self.planeId=="p2" then
        scale=0.55
        offsetX=-50
    end
	local function touchHandler()
	end
	local pic="plane_icon_"..self.planeId..".png"
	local planeSp=LuaCCSprite:createWithSpriteFrameName(pic,touchHandler)
	planeSp:setPosition(planeSp:getContentSize().width/2+offsetX,self.normalHeight/2)
	infoBg:addChild(planeSp)
    planeSp:setScale(scale)
    self.planeSp=planeSp
	--飞机名字
	local nameStr=getlocal("plane_name_"..self.planeId)
    local nameLb=GetTTFLabelWrap(nameStr,self.nameFontSize,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    nameLb:setAnchorPoint(ccp(0,0.5))
    self.nameLb=nameLb
    local nameLb2=GetTTFLabel(nameStr,self.nameFontSize)
    local titleW=nameLb2:getContentSize().width
    if titleW>nameLb:getContentSize().width then
        titleW=nameLb:getContentSize().width
    end
    titleW=titleW+50
    local titleH=nameLb:getContentSize().height+10
    if titleH<33 then
        titleH=33
    end
    local titlesBg=LuaCCScale9Sprite:createWithSpriteFrameName("newTitlesBG.png",CCRect(35,16,1,1),nilFunc)
    titlesBg:setContentSize(CCSizeMake(titleW,titleH))
    titlesBg:setAnchorPoint(ccp(0,1))
    titlesBg:setPosition(ccp(8,infoBg:getContentSize().height-5))
    infoBg:addChild(titlesBg)
    nameLb:setPosition(ccp(10,titlesBg:getContentSize().height/2))
    titlesBg:addChild(nameLb)
    self.titlesBg=titlesBg

	--飞机强度
	local strengthV=planeVoApi:getPlaneStrengthById(self.planeId)
    local strengthLb=GetTTFLabelWrap(getlocal("skill_power",{strengthV}),self.nameFontSize,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    strengthLb:setAnchorPoint(ccp(0.5,0))
	strengthLb:setColor(G_ColorYellowPro)
	strengthLb:setPosition(ccp(planeSp:getPositionX()-10,20))
	infoBg:addChild(strengthLb)
    self.strengthLb=strengthLb

    self.cellHeightTb,self.detailTb=self:getCellHeight()

	local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(230,20))
    self.tv:setMaxDisToBottomOrTop(80)
    infoBg:addChild(self.tv)
end

function planeInfoDialog:getCellHeight()
    local cellHeight1=0
    local cellHeight2=0
    local cfg=planeVoApi:getPlaneCfgById(self.planeId)
    if cfg==nil then
        return 0
    end

    local peculiarityLb=GetTTFLabelWrap(getlocal("peculiarity",{planeVoApi:getPlanePeculiarityById(self.planeId)}),self.desFontSize,CCSizeMake(self.tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    cellHeight1=cellHeight1+peculiarityLb:getContentSize().height+10

    local restrainQue=(cfg.restrainQue*100).."%%"
    local descStr=getlocal("plane_desc_"..self.planeId,{restrainQue})
    local descLb=GetTTFLabelWrap(descStr,self.desFontSize,CCSizeMake(self.tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    cellHeight1=cellHeight1+descLb:getContentSize().height+15
    local addStr=planeVoApi:getPlaneAddStr(self.planeId)
    local addLb=GetTTFLabelWrap(getlocal("add_attribute",{addStr}),self.desFontSize,CCSizeMake(self.tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    cellHeight2=cellHeight2+addLb:getContentSize().height+20

    local energyLb=GetTTFLabelWrap(getlocal("energy_uplimit",{cfg.energy}),self.desFontSize,CCSizeMake(self.tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    local energyLb2=GetTTFLabel(getlocal("energy_uplimit",{cfg.energy}),self.desFontSize)
    local realW=energyLb2:getContentSize().width
    if realW>energyLb:getContentSize().width then
        realW=energyLb:getContentSize().width
    end
    local energyIcon=CCSprite:createWithSpriteFrameName("planeEnergy.png")
    energyIcon:setAnchorPoint(ccp(0,0.5))
    energyIcon:setPosition(realW+5,energyLb:getContentSize().height/2)
    energyLb:addChild(energyIcon)
    cellHeight2=cellHeight2+energyLb:getContentSize().height+10

    local skillNumLb=GetTTFLabelWrap(getlocal("carry_skill_uplimit",{cfg.skillSlot}),self.desFontSize,CCSizeMake(self.tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    cellHeight2=cellHeight2+skillNumLb:getContentSize().height+20

    local cellHeightTb={cellHeight1,cellHeight2}
    local detailTb={{peculiarityLb,descLb},{addLb,energyLb,skillNumLb}}
    return cellHeightTb,detailTb
end
--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function planeInfoDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
    	return 2
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.tvWidth,self.cellHeightTb[idx+1])
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellHeight=self.cellHeightTb[idx+1]
        local details=self.detailTb[idx+1]
        local descBg
        local function nilFunc()
        end
        if idx==0 then
            descBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
            descBg:setContentSize(CCSizeMake(self.tvWidth,cellHeight-5))
            local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
            pointSp1:setPosition(ccp(2,descBg:getContentSize().height/2))
            descBg:addChild(pointSp1)
            local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
            pointSp2:setPosition(ccp(descBg:getContentSize().width-2,descBg:getContentSize().height/2))
            descBg:addChild(pointSp2)
        elseif idx==1 then
            descBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20,20,1,1),nilFunc)
            descBg:setContentSize(CCSizeMake(self.tvWidth,cellHeight))
        end
        if descBg then
            descBg:setAnchorPoint(ccp(0.5,1))
            descBg:setPosition(self.tvWidth/2,cellHeight)
            cell:addChild(descBg)

            local posY=descBg:getContentSize().height-10
            if details then
                for k,strLb in pairs(details) do
                    strLb:setAnchorPoint(ccp(0,1))
                    strLb:setPosition(10,posY)
                    descBg:addChild(strLb)
                    posY=posY-strLb:getContentSize().height
                    if idx==1 then
                        posY=posY-10
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

-- function planeInfoDialog:refresh(planeId,planeList)
--     print("refreshp---------->planeId",planeId)
--     self.planeId=planeId
--     self.planeList=planeList

--     -- self:setPlaneTb()
--     -- for k,iconSp in pairs(self.iconSpTb) do
--     --     iconSp:removeFromParentAndCleanup(true)
--     --     iconSp=nil
--     -- end
--     -- self.iconSpTb={}
--     -- for k,pid in pairs(self.planeTb) do
--     --     local cfg=planeVoApi:getPlaneCfgById(pid)
--     --     if cfg then

--     --     end
--     --     local function touchHandler()
--     --     end
--     --     local pic="plane_icon_p"..pid..".png"
--     --     local iconSp=LuaCCSprite:createWithSpriteFrameName(pic,touchHandler)
--     --     -- iconSp:setAnchorPoint(ccp(0.5,0))
--     --     iconSp:setPosition(G_VisibleSizeWidth/2+(k-2)*180,G_VisibleSizeHeight-200)
--     --     self.bgLayer:addChild(iconSp)
--     --     self.iconSpTb[k]=iconSp
--     --     if k~=2 then
--     --         iconSp:setScale(0.8)
--     --     end
--     -- end
--     self.cellHeightTb,self.detailTb=self:getCellHeight()
--     if self.planeSp and self.nameLb and self.strengthLb and self.tv and self.titlesBg then
--         local pic="plane_icon_"..self.planeId..".png"
--         local nameStr=getlocal("plane_name_"..self.planeId)
--         local strengthV=planeVoApi:getPlaneStrengthById(self.planeId)
--         local strengthStr=getlocal("alliance_boss_degree",{strengthV})
--         self.planeSp:initWithSpriteFrameName(pic)
--         self.nameLb:setString(nameStr)
--         self.strengthLb:setString(strengthStr)
--         local nameLb2=GetTTFLabel(nameStr,self.nameFontSize)
--         local titleW=nameLb2:getContentSize().width
--         if titleW>self.nameLb:getContentSize().width then
--             titleW=self.nameLb:getContentSize().width
--         end
--         titleW=titleW+50
--         local titleH=self.nameLb:getContentSize().height+10
--         if titleH<33 then
--             titleH=33
--         end
--         self.titlesBg:setContentSize(CCSizeMake(titleW,titleH))

--         self.tv:reloadData()
--     end
-- end

function planeInfoDialog:dispose()
	self.bgLayer:removeFromParentAndCleanup(true)
	self.bgLayer=nil
    self.layerNum=nil
    self.planeId=nil
    self.tvWidth=nil
    self.tvHeight=nil
    self.normalHeight=nil
    -- self.iconSpTb={}
    self.tv=nil
end
