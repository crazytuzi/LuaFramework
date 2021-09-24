allianceCityHelpDialog=commonDialog:new()

function allianceCityHelpDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function allianceCityHelpDialog:initTableView()
    self.panelLineBg:setVisible(false)

    self.tvWidth,self.tvHeight=G_VisibleSize.width-30,G_VisibleSize.height-140
    self.helpConf={9,9,6,8}
    self.argsCfg={
        arg_3_1={GetTimeStr(allianceCityVoApi:getMaintainLeftTime())},
        arg_3_4={math.ceil(allianceCityCfg.restartCity/60)},
        arg_4_6={allianceCityCfg.lostRate[1]*100,allianceCityCfg.lostRate[2]*100},
    }
    self.cellNum=SizeOfTable(self.helpConf)
    self.cellHeightTb={}
    self:getCellHeight()
    self:initHelpLayer()
end

function allianceCityHelpDialog:initHelpLayer()
    local function eventHandler(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(eventHandler)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setAnchorPoint(ccp(15,0))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp((G_VisibleSize.width-self.tvWidth)/2,30))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceCityHelpDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.tvWidth,self.cellHeightTb[idx+1])
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellWidth=self.tvWidth-20
        local cellHeight=self.cellHeightTb[idx+1]

        local titleStr=getlocal("alliancecity_help_title"..(idx+1))
        local titleLb,lheight=self:getTitleLb(titleStr)
        titleLb:setAnchorPoint(ccp(0,1))
        titleLb:setColor(G_ColorYellowPro)
        titleLb:setPosition(0,cellHeight)
        cell:addChild(titleLb)
        local wzposY=cellHeight-lheight
        local num=self.helpConf[idx+1]
        for i=1,num do
            local argKey=(idx+1).."_"..i
            local arg=self.argsCfg["arg_"..argKey] or {}
            local contentKey="alliancecity_help_content_"..argKey
            local contentLb,lbheight=self:getContentLb(getlocal(contentKey,arg))
            contentLb:setAnchorPoint(ccp(0,1))
            contentLb:setPosition(0,wzposY)
            cell:addChild(contentLb)
            wzposY=wzposY-lbheight

            if argKey=="3_1" then
                self.maintainLb=contentLb
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

function allianceCityHelpDialog:getCellHeight()
    for i=1,self.cellNum do
        if self.cellHeightTb[i]==nil then
            local height=0
            local titleKey="alliancecity_help_title"..i
            local titleLb,lbheight=self:getTitleLb(getlocal(titleKey))
            height=height+lbheight
            local num=self.helpConf[i]
            for k=1,num do
                local argKey=i.."_"..k
                local arg=self.argsCfg["arg_"..argKey] or {}
                local contentKey="alliancecity_help_content_"..argKey
                local contentLb,lbheight=self:getContentLb(getlocal(contentKey,arg))
                height=height+lbheight
            end
            self.cellHeightTb[i]=height+20
        end
    end
end

function allianceCityHelpDialog:getTitleLb(title)
  local showMsg=title or ""
  local width=self.tvWidth
  local messageLabel=GetTTFLabelWrap(showMsg,26,CCSizeMake(width,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  local height=messageLabel:getContentSize().height+20
  return messageLabel,height
end

function allianceCityHelpDialog:getContentLb(content)
  local showMsg=content or ""
  local width=self.tvWidth
  local messageLabel=GetTTFLabelWrap(showMsg,24,CCSizeMake(width,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  local height=messageLabel:getContentSize().height
  return messageLabel,height
end

function allianceCityHelpDialog:tick()
    if self.maintainLb then
        self.maintainLb:setString(getlocal("alliancecity_help_content_3_1",{GetTimeStr(allianceCityVoApi:getMaintainLeftTime())}))
    end
end

function allianceCityHelpDialog:dispose()
    self.cellHeightTb={}
    self.helpConf={}
    self.argsCfg={}
    self.cellNum=0
end