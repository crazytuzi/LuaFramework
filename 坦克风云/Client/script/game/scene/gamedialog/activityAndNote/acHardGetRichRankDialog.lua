acHardGetRichRankDialog=commonDialog:new()

function acHardGetRichRankDialog:new(parent,layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.layerNum=layerNum
    self.cellHeight=100
    self.parent=parent

    return nc
end

function acHardGetRichRankDialog:setType(type)
  print("type=",type)
  self.type=type

end

--设置或修改每个Tab页签
function acHardGetRichRankDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-100))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-34))
    local function callback(fn,data)
      local ret,sData=base:checkServerData(data)
      --"ranklist":{}
      if ret==true then
          if sData~=nil and sData.data~=nil and sData.data.ranklist~=nil then
              acHardGetRichVoApi:initResRank(self.type,sData.data.ranklist)
          end
          local function callback1(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData.data.res then
                  acHardGetRichVoApi:setResRank(sData.data.res)
                end
                self:initLayer()

            end
          end


          socketHelper:activeGethardgetrich(callback1)
          

      end
    end
    
    socketHelper:activeHardgetrichrank(self.type,callback)


end

function acHardGetRichRankDialog:initLayer()
    local function callback( ... )

    end
    local menuItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",callback,11,getlocal("activity_hadReward"),25)
    self.menu1 = CCMenu:createWithItem(menuItem);
    menuItem:setAnchorPoint(ccp(0.5,0.5))
    self.menu1:setPosition(ccp(self.bgLayer:getContentSize().width/2+10000,55));
    self.menu1:setTouchPriority(-(self.layerNum-1)*20-5);
    menuItem:setEnabled(false)
    self.bgLayer:addChild(self.menu1,3);

    if acHardGetRichVoApi:getIsRewardRByKey(self.type)==true then
        self.menu1:setPosition(ccp(self.bgLayer:getContentSize().width/2,55));
    else
      local function callbackRank()
          local function callback()
                
          end
          local function callback(fn,data)
              local ret,sData=base:checkServerData(data)
              if ret==true then
                  local idx=0
                  local rank=tonumber(acHardGetRichVoApi:getSelfRankByKey(self.type))
                  if rank==1 then
                     idx=1
                  elseif rank==2 then
                     idx=2
                  elseif rank==3 then
                     idx=3
                  elseif rank>=4 and rank<=5 then
                     idx=4
                  elseif rank>=6 and rank<=10 then
                     idx=5
                  elseif rank>=11 and rank<=30 then
                     idx=6
                  end
                  local award=FormatItem(acHardGetRichVoApi:getRankReward()[idx]) or {}
                  for k,v in pairs(award) do
                    G_addPlayerAward(v.type,v.key,v.id,v.num)
                  end
                  G_showRewardTip(award, true)
                  local acvo=activityVoApi:getActivityVo("hardGetRich")
                  acHardGetRichVoApi:setIsRewardR(self.type)
                  activityVoApi:updateShowState(acvo)
                  self.menu1:setPosition(ccp(self.bgLayer:getContentSize().width/2,55));
                  self.menu2:setPosition(ccp(self.bgLayer:getContentSize().width/2+100000,55));
              end
          end
          local rank=tonumber(acHardGetRichVoApi:getSelfRankByKey(self.type))
          socketHelper:activeHardgetrichRank(self.type,rank,callback)
              
      end
      local menuItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",callbackRank,11,getlocal("newGiftsReward"),25)
      self.menu2 = CCMenu:createWithItem(menuItem);
      menuItem:setAnchorPoint(ccp(0.5,0.5))
      self.menu2:setPosition(ccp(self.bgLayer:getContentSize().width/2,55));
      self.menu2:setTouchPriority(-(self.layerNum-1)*20-5);
      self.bgLayer:addChild(self.menu2,3);
      if acHardGetRichVoApi:isCanRewardRank(self.type)==false then
         menuItem:setVisible(false)
      end
    end
    

    if SizeOfTable(acHardGetRichVoApi:getResRankByKey(self.type))==0 then
      local nameLb=GetTTFLabel(getlocal("activity_getRich_norank"),32)
      nameLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2))
      self.bgLayer:addChild(nameLb,5);
    end
    

    self:initTableView1()
    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    local function cellClick(hd,fn,idx)

    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight-4))
    backSprie:ignoreAnchorPointForPosition(false);
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-140));
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer:addChild(backSprie,3)

    local acVo = acHardGetRichVoApi:getAcVo()
    local nameLb=GetTTFLabel(getlocal("activity_getRich_curRank",{acHardGetRichVoApi:getSelfRankByKey(self.type)}),27)
    nameLb:setAnchorPoint(ccp(0,0.5))
    nameLb:setPosition(ccp(40,backSprie:getContentSize().height*3/4))
    backSprie:addChild(nameLb,5);
    local res=acHardGetRichVoApi:getResTb()[self.type]
    local nameLb=GetTTFLabel(getlocal("activity_getRich_curRec",{res}),27)
    nameLb:setAnchorPoint(ccp(0,0.5))
    nameLb:setPosition(ccp(40,backSprie:getContentSize().height/4))
    backSprie:addChild(nameLb,5);

    local function touchInfo()
        local td=smallDialog:new()
        local award1=FormatItem(acHardGetRichVoApi:getRankReward()[1])
        local award2=FormatItem(acHardGetRichVoApi:getRankReward()[2])
        local award3=FormatItem(acHardGetRichVoApi:getRankReward()[3])
        local award4=FormatItem(acHardGetRichVoApi:getRankReward()[4])
        local award5=FormatItem(acHardGetRichVoApi:getRankReward()[5])
        local award6=FormatItem(acHardGetRichVoApi:getRankReward()[6])
        local awardStr1=G_showRewardStr(award1)
        local awardStr2=G_showRewardStr(award2)
        local awardStr3=G_showRewardStr(award3)
        local awardStr4=G_showRewardStr(award4)
        local awardStr5=G_showRewardStr(award5)
        local awardStr6=G_showRewardStr(award6)
        
        local str=getlocal("activity_getRich_rankdes");
        local str1=getlocal("activity_getRich_rankdes1",{awardStr1});
        local str2=getlocal("activity_getRich_rankdes2",{awardStr2});
        local str3=getlocal("activity_getRich_rankdes3",{awardStr3});
        local str4=getlocal("activity_getRich_rankdes4",{awardStr4});
        local str5=getlocal("activity_getRich_rankdes5",{awardStr5});
        local str6=getlocal("activity_getRich_rankdes6",{awardStr6});
        tabStr={" ",str6,str5,str4,str3,str2,str1,str," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    
    local menuItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem);
    menu:setPosition(ccp(520,backSprie:getContentSize().height/2));
    menu:setTouchPriority(-(self.layerNum-1)*20-4);
    backSprie:addChild(menu,3);

    


end

function acHardGetRichRankDialog:initTableView()

end

--设置对话框里的tableView
function acHardGetRichRankDialog:initTableView1()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-85-192),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(30,90))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acHardGetRichRankDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return SizeOfTable(acHardGetRichVoApi:getResRankByKey(self.type))

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.cellHeight)
         
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)

       end
       local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
       backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.cellHeight-4))
       backSprie:ignoreAnchorPointForPosition(false);
       backSprie:setAnchorPoint(ccp(0,0));
       backSprie:setTag(1000+idx)
       backSprie:setIsSallow(false)
       backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
       cell:addChild(backSprie)

       local rankLb=GetTTFLabel(idx+1,27)
       rankLb:setAnchorPoint(ccp(0,0.5))
       rankLb:setPosition(ccp(40,backSprie:getContentSize().height/2))
       backSprie:addChild(rankLb,5);

       local acTb = acHardGetRichVoApi:getResRankByKey(self.type)

       local nameLb=GetTTFLabel(acTb[idx+1][1],27)
       nameLb:setAnchorPoint(ccp(0,0.5))
       nameLb:setPosition(ccp(140,backSprie:getContentSize().height/2))
       backSprie:addChild(nameLb,5);

       local num=FormatNumber(acTb[idx+1][2])
       local resLb=GetTTFLabel(num,27)
       resLb:setAnchorPoint(ccp(0,0.5))
       resLb:setPosition(ccp(420,backSprie:getContentSize().height/2))
       backSprie:addChild(resLb,5);



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
function acHardGetRichRankDialog:tabClick(idx)

end

--用户处理特殊需求,没有可以不写此方法
function acHardGetRichRankDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function acHardGetRichRankDialog:cellClick(idx)
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

function acHardGetRichRankDialog:tick()

end

function acHardGetRichRankDialog:dispose()
    self.expandIdx=nil
    self=nil
end




