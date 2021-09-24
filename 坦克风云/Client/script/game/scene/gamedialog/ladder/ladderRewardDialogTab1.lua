-- 天梯帮助面板
ladderRewardDialogTab1={}
function ladderRewardDialogTab1:new(tabType)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tabType=tabType--1是个人天梯吧，2是军团天梯榜

    return nc
end


function ladderRewardDialogTab1:init(layerNum)
    self.layerNum=layerNum
    self.bgLayer=CCLayer:create()
    self:initTableView()
    return self.bgLayer
end


--设置对话框里的tableView
function ladderRewardDialogTab1:initTableView()
    self.helpList,self.helpColorList=ladderVoApi:getHelpContentList()
    self.tvW=self.bgLayer:getContentSize().width-20
    self.tvH=self.bgLayer:getContentSize().height-210

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvW,self.tvH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,40))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(10)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function ladderRewardDialogTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local listNum = SizeOfTable(self.helpList)
        return listNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize

        if self.helpList[idx+1] and self["cellH"..idx]==nil then
            local totalH = 60
            local item = self.helpList[idx+1]
            for subTitleIndex=1,10 do
                if item["subtitle"..subTitleIndex] then
                    local subtitleLb=GetTTFLabelWrap(item["subtitle"..subTitleIndex],25,CCSizeMake(self.tvW-20-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    totalH=totalH+subtitleLb:getContentSize().height+10
                    local contentIndex = 1
                    while item["content"..subTitleIndex.."_"..contentIndex] do
                        local contentLb=GetTTFLabelWrap(item["content"..subTitleIndex.."_"..contentIndex],22,CCSizeMake(self.tvW-20-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                        
                        totalH=totalH+contentLb:getContentSize().height+10   
                        contentIndex=contentIndex+1                
                    end
                end
            end
            tmpSize=CCSizeMake(self.tvW,totalH)
            self["cellH"..idx]=totalH
        else
            if self["cellH"..idx] then
                tmpSize=CCSizeMake(self.tvW,self["cellH"..idx])
            end
        end
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellW = self.tvW-20
        local cellH = self["cellH"..idx]-40--550
        if self.helpList[idx+1] then
            local item = self.helpList[idx+1]
            local function touchHander( ... )
                
            end
            local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),touchHander)
            contentBg:setContentSize(CCSizeMake(cellW,cellH))
            contentBg:setPosition(ccp(self.tvW/2,0))
            contentBg:setAnchorPoint(ccp(0.5,0))
            cell:addChild(contentBg)

            local titleLb=GetTTFLabelWrap(item.title,30,CCSizeMake(cellW-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            titleLb:setPosition(ccp(self.tvW/2,cellH+titleLb:getContentSize().height/2))
            cell:addChild(titleLb,2)

            local function cellClick(hd,fn,idx)
            end
            
            local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(210, 20, 1, 1),cellClick)
            titleBg:setContentSize(CCSizeMake(cellW, 47))
            titleBg:setPosition(ccp(self.tvW/2,cellH+titleLb:getContentSize().height/2))
            cell:addChild(titleBg)
            local nextLbY=titleLb:getPositionY()-titleLb:getContentSize().height/2-10
            local subTitleIndex = 1
            for subTitleIndex=1,10 do
                if item["subtitle"..subTitleIndex] then
                    local subtitleLb=GetTTFLabelWrap(item["subtitle"..subTitleIndex],25,CCSizeMake(cellW-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    cell:addChild(subtitleLb)
                    subtitleLb:setAnchorPoint(ccp(0,0.5))
                    subtitleLb:setColor(G_ColorYellowPro)
                    subtitleLb:setPosition(ccp(30,nextLbY-subtitleLb:getContentSize().height/2-10))

                    nextLbY=subtitleLb:getPositionY()-subtitleLb:getContentSize().height/2


                    local contentIndex = 1
                    while item["content"..subTitleIndex.."_"..contentIndex] do
                        local contentkey = "content"..subTitleIndex.."_"..contentIndex
                        local contentLb=GetTTFLabelWrap(item[contentkey],22,CCSizeMake(cellW-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                        cell:addChild(contentLb)
                        contentLb:setAnchorPoint(ccp(0,0.5))
                        contentLb:setPosition(ccp(30,nextLbY-contentLb:getContentSize().height/2-10))
                        if self.helpColorList and self.helpColorList["content_color_"..(idx+1).."_"..subTitleIndex.."_"..contentIndex] then
                            contentLb:setColor(self.helpColorList["content_color_"..(idx+1).."_"..subTitleIndex.."_"..contentIndex])
                        end
                        nextLbY=contentLb:getPositionY()-contentLb:getContentSize().height/2    
                        contentIndex=contentIndex+1                
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
           
    elseif fn=="ccScrollEnable" then
        if newGuidMgr:isNewGuiding()==true then
            return 0
        else
            return 1
        end
    end
end

function ladderRewardDialogTab1:tick()

end

function ladderRewardDialogTab1:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
end