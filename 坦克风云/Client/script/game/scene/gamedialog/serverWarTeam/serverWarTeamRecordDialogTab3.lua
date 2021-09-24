serverWarTeamRecordDialogTab3={

}

function serverWarTeamRecordDialogTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil;
    self.tv2=nil;

    self.bgLayer=nil;
    self.layerNum=nil;
    self.allTabs={};
    
    -- self.bgLayer1=nil;
    -- self.bgLayer2=nil;

    self.selectedTabIndex=0;
    self.parentDialog=nil;

    self.cellHeightTab={}
    -- self.cellHeightTab2={}

    self.canSand=true
    self.noRecordLb=nil

    self.roundIndex=nil
    self.battleID=nil
    self.isBattle=nil
    self.page=1

    self.normalHeight=100
    self.dtype=1

    return nc;

end

function serverWarTeamRecordDialogTab3:init(layerNum,parentDialog,roundIndex,battleID,isBattle)
    self.layerNum=layerNum
    self.parentDialog=parentDialog
    self.roundIndex=roundIndex
    self.battleID=battleID
    self.isBattle=isBattle
    self.bgLayer=CCLayer:create()
    
    self:initTabLayer();

    return self.bgLayer
end

function serverWarTeamRecordDialogTab3:initTabLayer()
    -- self:resetTab()

    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    local function click(hd,fn,idx)
    end
    self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,click)
    self.tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345+15+30))
    self.tvBg:ignoreAnchorPointForPosition(false)
    self.tvBg:setAnchorPoint(ccp(0.5,0))
    --self.tvBg:setIsSallow(false)
    --self.tvBg:setTouchPriority(-(self.layerNum-1)*20-2)
    self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,100-70))
    self.bgLayer:addChild(self.tvBg)

    self.noRecordLb=GetTTFLabelWrap(getlocal("alliance_war_no_record"),30,CCSizeMake(self.tvBg:getContentSize().width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noRecordLb:setAnchorPoint(ccp(0.5,0.5))
    self.noRecordLb:setPosition(ccp(self.tvBg:getContentSize().width/2,self.tvBg:getContentSize().height/2+30))
    self.tvBg:addChild(self.noRecordLb)
    self.noRecordLb:setColor(G_ColorGray)
    self.noRecordLb:setVisible(false)

    local function getRecordTabHandler()
        if self then
            -- if self.parentDialog then
            --     self.parentDialog:updateDestroyNum()
            -- end
            self:initTableView()
            -- serverWarTeamVoApi:setRFlag(1)
        end
    end
    serverWarTeamVoApi:getRecordTabByPage(self.roundIndex,self.battleID,self.page,getRecordTabHandler,self.dtype,self.isBattle)

end

function serverWarTeamRecordDialogTab3:initTableView()
    if self.tv then
        self.cellHeightTab={}
        self.tv:reloadData()
    else
        local function callBack(...)
           return self:eventHandler(...)
        end
        local hd= LuaEventHandler:createHandler(callBack)
        local height=0;
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-345+5+30),nil)
        -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
        self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.tv:setPosition(ccp(30,100-65))
        self.bgLayer:addChild(self.tv)
        self.tv:setMaxDisToBottomOrTop(120)
    end
    self:doUserHandler()
    -- serverWarTeamVoApi:setHasNew(false)
end

function serverWarTeamRecordDialogTab3:getCellHeight(index)
    if self.cellHeightTab[index]==nil then
        local lbSize=22
        local lbWidth=self.bgLayer:getContentSize().width-70
        local lbHeight=30

        local record=serverWarTeamVoApi:getRecordByIndex(self.roundIndex,self.battleID,index,self.dtype)
        if record==nil or SizeOfTable(record)==0 then
            do return 0 end
        end

        local descStr,color=serverWarTeamVoApi:getBattleDesc(record)
        local recordDescLb=GetTTFLabelWrap(descStr,lbSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

        local cellHeight=recordDescLb:getContentSize().height+lbHeight

        self.cellHeightTab[index]=cellHeight
    end

    return self.cellHeightTab[index]
end

function serverWarTeamRecordDialogTab3:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then   
        local num=serverWarTeamVoApi:getRecordNum(self.roundIndex,self.battleID,self.page,self.dtype)
        local hasMore=serverWarTeamVoApi:hasMore(self.roundIndex,self.battleID,self.page,self.dtype)
        if hasMore then
            num=num+1
        end
        -- print("num",num)
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,100)
        local num=serverWarTeamVoApi:getRecordNum(self.roundIndex,self.battleID,self.page,self.dtype)
        local hasMore=serverWarTeamVoApi:hasMore(self.roundIndex,self.battleID,self.page,self.dtype)
        if hasMore and idx+1==num+1 then
            tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,100)
        else
            tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,self.normalHeight)
        end
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local index=idx+1
        local num=serverWarTeamVoApi:getRecordNum(self.roundIndex,self.battleID,self.page,self.dtype)        

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);

        local function getMore(hd,fn,idx)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                local function getRecordTabHandler()
                    if self then
                        self.page=self.page+1
                        -- if self.parentDialog then
                        --     self.parentDialog:updateDestroyNum()
                        -- end
                        self:refreshTableView()
                    end
                end
                serverWarTeamVoApi:getRecordTabByPage(self.roundIndex,self.battleID,self.page+1,getRecordTabHandler,self.dtype)
            end
        end

        local hasMore=serverWarTeamVoApi:hasMore(self.roundIndex,self.battleID,self.page,self.dtype)
        local backSprie
        if hasMore and index==num+1 then
            backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,getMore)
            backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 100-5))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0,0))
            backSprie:setPosition(0,5)
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:setTag(index)
            cell:addChild(backSprie,1)
            
            local moreLabel=GetTTFLabel(getlocal("showMoreTen"),30)
            moreLabel:setPosition(getCenterPoint(backSprie))
            backSprie:addChild(moreLabel,2)
            do return cell end
        end

        local record=serverWarTeamVoApi:getRecordByIndex(self.roundIndex,self.battleID,index,self.dtype)
        if record==nil or SizeOfTable(record)==0 then
            do return cell end
        end


        local function cellClick(hd,fn,idx)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                local rid=record.rid
                if record.report==nil then
                    -- local function acrossDetailreportHandler(fn,data)
                    --     local ret,sData=base:checkServerData(data)
                    --     if ret==true then
                    --         if sData.data and sData.data.detailReport then
                    --             local recordVo=serverWarTeamVoApi:formatPRecordDetailData(sData.data.detailReport,self.roundIndex,self.battleID,rid)
                    --             self:showDetailDialog(recordVo)
                    --         end
                    --     end
                    -- end
                    local bid=serverWarTeamVoApi:getServerWarId()
                    local socketHost = serverWarTeamVoApi.socketHost
                    -- socketHelper:acrossDetailreport(bid,rid,acrossDetailreportHandler)
                    -- local httpUrl="http://"..socketHost["host"].."/tank-server/public/index.php/across/detailreport/getdetailreport" 
                    local httpUrl="http://"..base.serverIp.."/tank-server/public/index.php/across/detailreport/getdetailreport" 
                    local reqTb = "rId="..rid
                    local retStr=G_sendHttpRequestPost(httpUrl,reqTb)
                    -- print("httpUrl,reqTb====> ",httpUrl,reqTb)
                    -- print("retStr ===== ",retStr)
                    if(retStr~="")then
                        local sData=G_Json.decode(retStr)
                        -- G_dayin(sData)
                        if sData and sData.ret==0 then
                            local recordVo=serverWarTeamVoApi:formatPRecordDetailData(sData.data.detailreport,self.roundIndex,self.battleID,rid)
                            self:showDetailDialog(recordVo)
                        end
                    end
                else
                    self:showDetailDialog(record)
                end
            end
        end
        -- if record.isRead==1 then
            backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgRead.png",capInSet,cellClick)
        -- else
        --     backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgNoRead.png",capInSet,cellClick)
        -- end
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight-2))
        backSprie:ignoreAnchorPointForPosition(false);
        backSprie:setAnchorPoint(ccp(0.5,0));
        backSprie:setTag(idx)
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:setPosition(ccp((self.bgLayer:getContentSize().width-60)/2,0));
        cell:addChild(backSprie,1)
        
        local emailIcon
        -- if record.isRead==1 then
            emailIcon=CCSprite:createWithSpriteFrameName("letterIconRead.png")
        -- else
        --     emailIcon=CCSprite:createWithSpriteFrameName("letterIconNoRead.png")
        -- end
        emailIcon:setPosition(ccp(50,self.normalHeight/2))
        cell:addChild(emailIcon,2)
        
        local fromToLabel=GetTTFLabel(getlocal("email_from",{getlocal("scout_content_system_email")}),25)
        fromToLabel:setAnchorPoint(ccp(0,0))
        fromToLabel:setPosition(30+emailIcon:getContentSize().width+5,65)
        cell:addChild(fromToLabel,2)
        
        -- local noticeSp
        -- local spSize=40
        -- if record.isAllianceEmail and record.isAllianceEmail==1 then
        --     noticeSp=CCSprite:createWithSpriteFrameName("Icon_warn.png")
        --     noticeSp:setAnchorPoint(ccp(0.5,0.5))
        --     noticeSp:setPosition(ccp(30+emailIcon:getContentSize().width+5+spSize/2,65))
        --     noticeSp:setScale(spSize/noticeSp:getContentSize().width)
        --     cell:addChild(noticeSp,2)

        --     fromToLabel:setPosition(30+emailIcon:getContentSize().width+5,5)
        -- end
        
        local titleStr=record.title
        -- titleStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        if titleStr and titleStr~="" then
            local lbWidth=450
            -- if noticeSp then
            --     lbWidth=lbWidth-(spSize+5)
            -- end
            local titleLabel=GetTTFLabelWrap(titleStr,25,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            titleLabel:setAnchorPoint(ccp(0,0.5))
            titleLabel:setColor(G_ColorYellow)
            cell:addChild(titleLabel,2)
            local lbx=30+emailIcon:getContentSize().width+5
            -- if noticeSp then
            --     lbx=lbx+spSize+5
            -- end
            titleLabel:setPosition(lbx,65)
            
            fromToLabel:setPosition(30+emailIcon:getContentSize().width+5,5)
        end
        
        local timeLabel=GetTTFLabel(G_getDataTimeStr(record.time),25)
        timeLabel:setAnchorPoint(ccp(0,0))
        timeLabel:setPosition(backSprie:getContentSize().width-150,5)
        cell:addChild(timeLabel,2)





        -- local cellHeight=self:getCellHeight(index)

        -- local lbSize=22
        -- local lbWidth=self.bgLayer:getContentSize().width-70
        -- local lbX=5
        -- local lbHeight=20
        -- local lbSpace=5

        -- local descStr,color=serverWarTeamVoApi:getBattleDesc(record)
        -- local recordDescLb=GetTTFLabelWrap(descStr,lbSize,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        -- recordDescLb:setAnchorPoint(ccp(0,1))
        -- recordDescLb:setPosition(ccp(lbX+5,cellHeight-10))
        -- cell:addChild(recordDescLb,1)
        -- recordDescLb:setColor(color)

        -- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        -- lineSp:setAnchorPoint(ccp(0.5,0.5))
        -- lineSp:setScaleX(G_VisibleSizeWidth/lineSp:getContentSize().width)
        -- lineSp:setPosition(ccp(lbWidth/2,10))
        -- cell:addChild(lineSp,2)

        -- local function cellClick1(hd,fn,idx)
        --     if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        --         if G_checkClickEnable()==false then
        --             do
        --                 return
        --             end
        --         else
        --             base.setWaitTime=G_getCurDeviceMillTime()
        --         end
        --         PlayEffect(audioCfg.mouseClick)
                
        --         --播放战斗动画
        --         if record and record.report and type(record.report)=="table" and SizeOfTable(record.report)>0 then
        --             if serverWarTeamOutScene and serverWarTeamOutScene.setVisible then
        --                 serverWarTeamOutScene:setVisible(false)
        --             end
        --             local serverWarTeam=1
        --             local data={data={report=record.report},isReport=true,serverWarTeam=serverWarTeam}
        --             battleScene:initData(data)
        --         end
        --     end
        -- end
        -- backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick1)
        -- backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,cellHeight))
        -- backSprie:ignoreAnchorPointForPosition(false)
        -- backSprie:setAnchorPoint(ccp(0,0))
        -- backSprie:setPosition(-5,5)
        -- backSprie:setIsSallow(false)
        -- backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        -- cell:addChild(backSprie)
        -- backSprie:setOpacity(0)




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

function serverWarTeamRecordDialogTab3:showDetailDialog(report)
    if report then
        require "luascript/script/game/scene/gamedialog/serverWarTeam/sertverWarReportDetailDialog"
        local layerNum=self.layerNum+1
        local td=sertverWarReportDetailDialog:new(layerNum,report)
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("arena_report_title"),false,layerNum)
        sceneGame:addChild(dialog,layerNum)
    end
end

function serverWarTeamRecordDialogTab3:refreshTableView()
    if self and self.tv then
        local recordPoint = self.tv:getRecordPoint()
        local oldHeight=0
        if self.cellHeightTab and SizeOfTable(self.cellHeightTab)>0 then
            for k,v in pairs(self.cellHeightTab) do
                oldHeight=oldHeight+v
            end
        end
        self.cellHeightTab={}
        self.tv:reloadData()
        local newHeight=0
        if self.cellHeightTab and SizeOfTable(self.cellHeightTab)>0 then
            for k,v in pairs(self.cellHeightTab) do
                newHeight=newHeight+v
            end
        end
        local diffHeight=newHeight-oldHeight
        -- local hasMore=serverWarTeamVoApi:hasMore(self.roundIndex,self.battleID,self.page,self.dtype)
        -- print("hasMore",hasMore)
        -- if hasMore then
            self.tv:recoverToRecordPoint(ccp(recordPoint.x,recordPoint.y-diffHeight))
        -- else
        --     self.tv:recoverToRecordPoint(ccp(recordPoint.x,recordPoint.y-diffHeight+100))
        -- end
    end
end

function serverWarTeamRecordDialogTab3:tick()
    -- if self then
    --     local rFlag=serverWarTeamVoApi:getRFlag()
    --     if rFlag==0 then
    --         self:refreshTableView()
    --         self:doUserHandler()
    --         serverWarTeamVoApi:setRFlag(1)
    --     end
    -- end
end


--用户处理特殊需求,没有可以不写此方法
function serverWarTeamRecordDialogTab3:doUserHandler()
    if self and self.noRecordLb then
        local num=serverWarTeamVoApi:getRecordNum(self.roundIndex,self.battleID,self.page,self.dtype)
        if num and num>0 then
            self.noRecordLb:setVisible(false)
        else
            self.noRecordLb:setVisible(true)
        end
    end
end

function serverWarTeamRecordDialogTab3:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    
    self.tv=nil
    -- self.tv2=nil
    self.layerNum=nil
    self.allTabs=nil
    self.cellHeightTab=nil
    self.canSand=nil
    self.noRecordLb=nil

    -- self.bgLayer1=nil
    -- self.bgLayer2=nil
    self.selectedTabIndex=nil
    self.bgLayer=nil

    self.roundIndex=nil
    self.battleID=nil
    self.isBattle=nil
    self.page=1

end
