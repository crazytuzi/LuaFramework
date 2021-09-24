--require "luascript/script/componet/commonDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar/allianceWarBidDialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar/allianceWarTab1Dialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar/allianceWarTab2Dialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar/allianceWarTab3Dialog"
allianceWarDialog=commonDialog:new()

function allianceWarDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.layerNum=layerNum
    
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.playerTab1=nil
    self.playerTab2=nil
    self.playerTab3=nil
    self.recordNewsIcon=nil
    self.timerSprite1=nil
    self.timerSprite2=nil
    self.timerLb1=nil
    self.timerLb2=nil
    self.getTime=0
    base.pauseSync=true
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
    return nc
end

--设置或修改每个Tab页签
function allianceWarDialog:resetTab()

    local index=0
    local tabHeight=80
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         
         local numHeight=25
			local iconWidth=36
			local iconHeight=36
	   	    local capInSet1 = CCRect(17, 17, 1, 1)
	   	    local function touchClick()
	   	    end
	        self.newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
	        self.newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
	   		self.newsIcon:ignoreAnchorPointForPosition(false)
	   		self.newsIcon:setAnchorPoint(CCPointMake(1,0.5))
        self.newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width,tabBtnItem:getContentSize().height-15))
			self.newsIcon:setTag(10)
	   		self.newsIcon:setVisible(false)
		    tabBtnItem:addChild(self.newsIcon)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    
    self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-260))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-66-40))
    
    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(40, 40, 10, 10);
    local capInSetNew=CCRect(20, 20, 10, 10)
    local function cellClick1(hd,fn,idx)
        local td=warRecordDialog:new()
        local tbArr={getlocal("alliance_war_record_title"),getlocal("alliance_war_stats")}
        -- local tbSubArr={getlocal("alliance_war_personal"),getlocal("alliance_list_scene_name")}
        local tbSubArr={}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,tbSubArr,nil,getlocal("alliance_war_battle_stats"),true,self.layerNum+1)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankSelfItemBg.png",capInSetNew,cellClick1)
    backSprie:setContentSize(CCSizeMake(600, 70))
    backSprie:setAnchorPoint(ccp(0.5,0.5))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-4)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-125))
    self.bgLayer:addChild(backSprie,1)
    
    local redIcon=CCSprite:createWithSpriteFrameName("IconWarRedFlage.png")
    redIcon:setAnchorPoint(ccp(0,0.5))
    redIcon:setPosition(5,backSprie:getContentSize().height/2)
    backSprie:addChild(redIcon)
    
    local blueIcon=CCSprite:createWithSpriteFrameName("IconWarBlueFlage.png")
    blueIcon:setAnchorPoint(ccp(1,0.5))
    blueIcon:setPosition(backSprie:getContentSize().width-5,backSprie:getContentSize().height/2)
    backSprie:addChild(blueIcon)
    blueIcon:setFlipX(true)
    
    local fadeOut=CCTintTo:create(0.5,130,130,130)
    local fadeIn=CCTintTo:create(0.5,255,255,255)
    local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
    local repeatForever=CCRepeatForever:create(seq)
    if allianceWarVoApi.targetState==1 then
        redIcon:runAction(repeatForever)
    elseif allianceWarVoApi.targetState==2 then
        blueIcon:runAction(repeatForever)

    end

    
    local function record()
    
    end
    local bgIconSp=LuaCCSprite:createWithSpriteFrameName("WarVS_BG.png",record)
    bgIconSp:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2))
    backSprie:addChild(bgIconSp,5)

    local vSp=LuaCCSprite:createWithSpriteFrameName("v.png",record)
    local sSp=LuaCCSprite:createWithSpriteFrameName("s.png",record)
    vSp:setScale(0.5)
    sSp:setScale(0.5)
    vSp:setPosition(ccp(backSprie:getContentSize().width/2-vSp:getContentSize().width/4+5,backSprie:getContentSize().height/2))
    sSp:setPosition(ccp(backSprie:getContentSize().width/2+sSp:getContentSize().width/4-5,backSprie:getContentSize().height/2))
    backSprie:addChild(vSp,6)
    backSprie:addChild(sSp,6)
    
    local fadeOut=CCTintTo:create(0.5,255,97,0)
    local fadeIn=CCTintTo:create(0.5,255,255,255)
    local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
    local repeatForever=CCRepeatForever:create(seq)
    vSp:runAction(repeatForever)
    
    local fadeOut=CCTintTo:create(0.5,255,97,0)
    local fadeIn=CCTintTo:create(0.5,255,255,255)
    local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
    local repeatForever=CCRepeatForever:create(seq)
    sSp:runAction(repeatForever)
    
    local function callback(fn,data)
        if base:checkServerData(data)==true then
            self.playerTab1=allianceWarTab1Dialog:new(self)
            self.layerTab1=self.playerTab1:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab1);
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)

            self.playerTab2=allianceWarTab2Dialog:new()
            self.layerTab2=self.playerTab2:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab2);
            self.layerTab2:setPosition(ccp(10000,0))
            self.layerTab2:setVisible(false)

            self.playerTab3=allianceWarTab3Dialog:new(self)
            self.layerTab3=self.playerTab3:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab3);
            self.layerTab3:setPosition(ccp(10000,0))
            self.layerTab3:setVisible(false)
            G_isShowTip=true

        end
    end
    socketHelper:alliancewarGet(allianceWarVoApi:getTargetCity(),callback)


    
    self:addProgram(backSprie)

    local iconWidth=36
    local iconHeight=36
    local capInSet1 = CCRect(17, 17, 1, 1)
    local function touchClick()
    end
    self.recordNewsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
    self.recordNewsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
    self.recordNewsIcon:ignoreAnchorPointForPosition(false)
    self.recordNewsIcon:setAnchorPoint(CCPointMake(0.5,0.5))
    self.recordNewsIcon:setPosition(ccp(backSprie:getContentSize().width/2+60,backSprie:getContentSize().height-iconHeight/2))
    self.recordNewsIcon:setTag(111)
    self.recordNewsIcon:setScale(0.7)
    self.recordNewsIcon:setVisible(false)
    backSprie:addChild(self.recordNewsIcon,7)
    self.recordNewsIcon:setVisible(false)

    -- local maxNum=allianceWarRecordVoApi:getPersonMaxNum()
    -- local personRecordTab=allianceWarRecordVoApi:getPersonRecordTab()
    -- if maxNum and personRecordTab then
    --     if maxNum>0 and allianceWarRecordVoApi:getRFlag()==-1 then
    --         self.recordNewsIcon:setVisible(true)
    --     end
    -- end

    if allianceWarRecordVoApi:getHasNew()==true then
        self.recordNewsIcon:setVisible(true)
    end

end

function allianceWarDialog:setPoint()
    local pointTb = allianceWarVoApi:getPoint()
    if pointTb~=nil then
        local per1=pointTb[1]/allianceWarCfg.winPointMax*100
        local per2=pointTb[2]/allianceWarCfg.winPointMax*100
        self.timerSprite1=tolua.cast(self.timerSprite1,"CCProgressTimer")
        self.timerSprite1:setPercentage(per1);
        self.timerSprite2=tolua.cast(self.timerSprite2,"CCProgressTimer")
        self.timerSprite2:setPercentage(per2);
        self.timerLb1=tolua.cast(self.timerLb1,"CCLabelTTF")
        self.timerLb1:setString(pointTb[1])
        self.timerLb2=tolua.cast(self.timerLb2,"CCLabelTTF")
        self.timerLb2:setString(pointTb[2])

    end
end

function allianceWarDialog:addProgram(backSprie)

    local psSprite1 = CCSprite:createWithSpriteFrameName("WarHaemalStrand_02.png");
    self.timerSprite1 = CCProgressTimer:create(psSprite1);
    self.timerSprite1:setBarChangeRate(ccp(1, 0));
    self.timerSprite1:setType(kCCProgressTimerTypeBar);
    self.timerSprite1:setTag(101);

    local rY=17
    
    local point1=ccp(145,backSprie:getContentSize().height/2-1-rY)
    local point2=ccp(150,backSprie:getContentSize().height/2-rY)

    self.timerSprite1:setPosition(point1);
    backSprie:addChild(self.timerSprite1, 2);
    local loadingBk = CCSprite:createWithSpriteFrameName("WarHaemalStrand_01.png");
    loadingBk:setPosition(point2);
    loadingBk:setTag(102);
    psSprite1:setFlipX(true)
    loadingBk:setFlipX(true)
    self.timerSprite1:setMidpoint(ccp(1,0));
    backSprie:addChild(loadingBk,1);

    self.timerSprite1:setPercentage(0);
    
    local psSprite3 = CCSprite:createWithSpriteFrameName("WarHaemalStrand_02.png");
    self.timerSprite2 = CCProgressTimer:create(psSprite3);
    self.timerSprite2:setMidpoint(ccp(0,1));
    self.timerSprite2:setBarChangeRate(ccp(1, 0));
    self.timerSprite2:setType(kCCProgressTimerTypeBar);
    self.timerSprite2:setTag(103);
    
    local point3=ccp(450,backSprie:getContentSize().height/2-1-rY)
    local point4=ccp(445,backSprie:getContentSize().height/2-rY)

    self.timerSprite2:setPosition(point3);
    backSprie:addChild(self.timerSprite2, 2);
    local loadingBk2 = CCSprite:createWithSpriteFrameName("WarHaemalStrand_01.png");
    loadingBk2:setPosition(point4);
    loadingBk2:setTag(104);
    backSprie:addChild(loadingBk2,1);
    
    local pointTb = allianceWarVoApi:getPoint()
    if pointTb~=nil then
        local per1=pointTb[1]/allianceWarCfg.winPointMax*100
        local per2=pointTb[2]/allianceWarCfg.winPointMax*100
        self.timerSprite1:setPercentage(per1);
        self.timerSprite2:setPercentage(per2);
    end
    self.timerLb1=GetTTFLabel("",26)
    self.timerLb1:setAnchorPoint(ccp(0.5,0.5))
    self.timerLb1:setPosition(getCenterPoint(self.timerSprite1))
    self.timerSprite1:addChild(self.timerLb1)
    
    self.timerLb2=GetTTFLabel("",26)
    self.timerLb2:setAnchorPoint(ccp(0.5,0.5))
    self.timerLb2:setPosition(getCenterPoint(self.timerSprite2))
    self.timerSprite2:addChild(self.timerLb2)
    
    self.timerLb1:setString(pointTb[1])
    self.timerLb2:setString(pointTb[2])


    local nameTb=allianceWarVoApi:getAllianceNameTb()
    local nameLb1=GetTTFLabel(nameTb[1].name,26)
    nameLb1:setAnchorPoint(ccp(0,0.5))
    nameLb1:setPosition(ccp(63,backSprie:getContentSize().height/2+rY))
    backSprie:addChild(nameLb1, 2)

    local nameLb2=GetTTFLabel(nameTb[2].name,26)
    nameLb2:setAnchorPoint(ccp(1,0.5))
    nameLb2:setPosition(ccp(532,backSprie:getContentSize().height/2+rY))
    backSprie:addChild(nameLb2, 2)



end


--设置对话框里的tableView
function allianceWarDialog:initTableView()
    
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setVisible(false)

    self.tv:setMaxDisToBottomOrTop(120)

    G_AllianceWarDialogTb["allianceWarDialog"]=self
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceWarDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       if self.selectedTabIndex==0 then
           return 4
       elseif self.selectedTabIndex==1 then
            return SizeOfTable(skillVoApi:getAllSkills())
       elseif self.selectedTabIndex==2 then
            return SizeOfTable(self.dataSource)
       end

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize

        if self.selectedTabIndex==0 then
            if idx==0 then
                tmpSize=CCSizeMake(400,180)
            
            else
                tmpSize=CCSizeMake(400,150)
            end
        elseif self.selectedTabIndex==1 then
            tmpSize=CCSizeMake(400,150)

        else
            tmpSize=CCSizeMake(400,150)
        end
         
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end
       
       
       local hei =0
       if self.selectedTabIndex==0 then
           if idx==0 then
                    hei=180
                else
                    hei=150
                end
       else
       
            hei=150     
       
       end
       local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
       backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, hei))
       backSprie:ignoreAnchorPointForPosition(false);
       backSprie:setAnchorPoint(ccp(0,0));
       backSprie:setTag(1000+idx)
       backSprie:setIsSallow(false)
       backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
       cell:addChild(backSprie,1)
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

--点击tab页签 idx:索引
function allianceWarDialog:tabClick(idx)
        if newGuidMgr:isNewGuiding() then --新手引导
              if newGuidMgr.curStep==39 and idx~=1 then
                    do
                        return
                    end
              end
        end
        PlayEffect(audioCfg.mouseClick)
        
        for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:tabClickColor(idx)
            self:doUserHandler()
            self:getDataByType(idx)
            
         else
            v:setEnabled(true)
         end
    end
    
    if idx==0 then
        self.layerTab1:setVisible(true)
        self.layerTab1:setPosition(ccp(0,0))
        
        self.layerTab2:setVisible(false)
        self.layerTab2:setPosition(ccp(99930,0))

        self.layerTab3:setVisible(false)
        self.layerTab3:setPosition(ccp(99930,0))
    elseif idx==1 then
        self.layerTab1:setVisible(false)
        self.layerTab1:setPosition(ccp(10000,0))
        
        self.layerTab2:setVisible(true)
        self.layerTab2:setPosition(ccp(0,0))

        self.layerTab3:setVisible(false)
        self.layerTab3:setPosition(ccp(99930,0))
    
    elseif idx==2 then
        self.layerTab1:setVisible(false)
        self.layerTab1:setPosition(ccp(99930,0))
        
        self.layerTab2:setVisible(false)
        self.layerTab2:setPosition(ccp(99930,0))

        self.layerTab3:setVisible(true)
        self.layerTab3:setPosition(ccp(0,0))
        self.playerTab3:clearTouchSp()
        self.playerTab3:refreshAtk()
    end

    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function allianceWarDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function allianceWarDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,120)
        else
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,800)
        end
    end
end

function allianceWarDialog:tick()
    self:setPoint()
    self.getTime=self.getTime+1
    local isInWar = allianceWarVoApi:getStatus(allianceWarVoApi.targetCity)
    if self.getTime%10==0 and G_isRefreshGetpoint and (isInWar==30 or isInWar==40) then
        local function callback(fn,data)
            local cresult,retTb=base:checkServerData(data)
            if cresult==true then
                if retTb.data~=nil and retTb.data.alliancewar~=nil and retTb.data.alliancewar.isover==1 and G_isRefreshGetpoint then
                    self:close()
                end
            end
        end
        socketHelper:alliancewarGetwarpoint(allianceWarVoApi:getTargetCity(),callback,false)
    end
    if tankVoApi:checkIsIconShow() then
        self.newsIcon:setVisible(true)
    else
        self.newsIcon:setVisible(false)
    end


    if self.selectedTabIndex==0 and self.playerTab1~=nil then
        self.playerTab1:tick()

    elseif self.selectedTabIndex==1 and self.playerTab2~=nil then
        self.playerTab2:tick()

    elseif self.selectedTabIndex==2 and self.playerTab3~=nil then
        self.playerTab3:tick()

    end
    
    if self.recordNewsIcon then
        if self.recordNewsIcon:isVisible()==true then
            self.recordNewsIcon:setVisible(false)
        end
        -- local maxNum=allianceWarRecordVoApi:getPersonMaxNum()
        -- local personRecordTab=allianceWarRecordVoApi:getPersonRecordTab()
        -- if maxNum and personRecordTab then
        --     if allianceWarRecordVoApi:getRFlag()==-1 and  then
        --         self.recordNewsIcon:setVisible(true)
        --     end
        -- end
        if allianceWarRecordVoApi:getHasNew()==true then
            self.recordNewsIcon:setVisible(true)
        end
    end


end

function allianceWarDialog:dispose()
    self.expandIdx=nil
    if self.playerTab1~=nil then
        self.playerTab1:dispose()
    end
    if self.playerTab2~=nil then
        self.playerTab2:dispose()
    end
    if self.playerTab3~=nil then
        self.playerTab3:dispose()
    end
    self.recordNewsIcon=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.playerTab1=nil
    self.playerTab2=nil
    self.playerTab3=nil
    self=nil
    base.pauseSync=false
    G_isShowTip=false
    G_AllianceWarDialogTb["allianceWarDialog"]=nil
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("allianceWar/warMap.plist")
end




