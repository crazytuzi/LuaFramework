--require "luascript/script/componet/commonDialog"
prestigeDialog=commonDialog:new()

function prestigeDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.itemsTable={}
    self.isPrestige=false;
    self.layerNum=layerNum
    self.honorsLv=nil --用户声望等级
    self.playerHonors=nil --玩家当前声望值
    self.nextHonorsEx=nil --玩家下一级声望用的经验
    self.maxLevel=nil --当前服 最大等级
    self.maxHonors=nil --当前服 声望最大值
    return nc
end

--设置或修改每个Tab页签
function prestigeDialog:resetTab()
    --self:judgeIsPrestige()
end

function prestigeDialog:judgeIsPrestige()
    --[[
    local today = os.date("*t")
    local weeTs = os.time({year=today.year, month=today.month, day=today.day, hour=0,min=0,sec=0})
    if base.userInfoDaily_honors>weeTs then
        self.isPrestige=true
    end
    ]]
    if G_isToday(base.userInfoDaily_honors) then
         self.isPrestige=true
    else
         self.isPrestige=false
    end
    self.tv:reloadData()
    
end

--设置对话框里的tableView
function prestigeDialog:initTableView()
    self.honorsLv,self.playerHonors,self.nextHonorsEx =playerVoApi:getHonorInfo() --用户当前的声望值
    self.maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
    local honTb =Split(playerCfg.honors,",")
    self.maxHonors =honTb[self.maxLevel] --当前服 最大声望值
    print("用户当前的声望值,最大等级,最大声望值",self.playerHonors,self.maxLevel,self.maxHonors)
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-180),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-0)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    
    self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-240))
    
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-100))
    
    local nameLb = GetTTFLabelWrap(getlocal("reputation_scene_info"),32,CCSizeMake(32*15,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
    nameLb:setAnchorPoint(ccp(0.5,0.5));
    nameLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-140));
    self.bgLayer:addChild(nameLb,2);
    
    if self.isPrestige==true then
        local acceptLb = GetTTFLabel(getlocal("reputation_scene_have_accept"),32);
        acceptLb:setAnchorPoint(ccp(0.5,0.5));
        acceptLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-160));
        self.bgLayer:addChild(acceptLb,2);
        acceptLb:setColor(G_ColorRed)
    end
    self:judgeIsPrestige()

end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function prestigeDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
   
        return 4;

   elseif fn=="tableCellSizeForIndex" then
    
       local tmpSize=CCSizeMake(400,150)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()
       local rect = CCRect(0, 0, 50, 50);
       local capInSet = CCRect(20, 20, 10, 10);
       local function cellClick(hd,fn,idx)
           --return self:cellClick(idx)
       end
       
       local hei=150-4

       local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
       backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, hei))
       backSprie:ignoreAnchorPointForPosition(false);
       backSprie:setAnchorPoint(ccp(0,0));
       backSprie:setTag(1000+idx)
       backSprie:setIsSallow(false)
       backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
       cell:addChild(backSprie,1)
       if idx==0 then
       
          local photoSp = CCSprite:createWithSpriteFrameName("Icon_prompt_1.png");
          photoSp:setAnchorPoint(ccp(0,0.5));
          photoSp:setPosition(ccp(10,backSprie:getContentSize().height/2));
          cell:addChild(photoSp,2);

          local desLb1 = GetTTFLabelWrap(getlocal("reputation_scene_medal_info_3"),28,CCSizeMake(380,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter);
          desLb1:setAnchorPoint(ccp(0,1));
          desLb1:setPosition(ccp(110,135));
          cell:addChild(desLb1,2);
          
          local desLb2 = GetTTFLabel(getlocal("reputation_scene_medal_info_4"),28);
          desLb2:setAnchorPoint(ccp(0,0.5));
          desLb2:setPosition(ccp(110,40));
          cell:addChild(desLb2,2);
          
          local function touch1()
                if self.tv:getIsScrolled()==true then
                    return
                end
                PlayEffect(audioCfg.mouseClick)
                local function touchAddPrestige()
                    
                    local function serverDailyHonors(fn,data)
                        --local retTb=OBJDEF:decode(data)
                        if base:checkServerData(data)==true then
                            prestigeDialog:showTips(20)
                            -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("reputation_prompt_success",{20}),28)
                            self:judgeIsPrestige()
                            
                        end
                    end
                    socketHelper:dailyHonors(1,serverDailyHonors)

                end
                
                if playerVoApi:getGold()>=1000 then
                    
                    local smallD=smallDialog:new()
                     smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchAddPrestige,getlocal("dialog_title_prompt"),getlocal("reputation_scene_prompt_0"),nil,self.layerNum+1)
                else
                     smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage108"),nil,self.layerNum+1)

                end

                
          end
          local menuItem1 = GetButtonItem("BtnUp.png","BtnUp_Down.png","BtnUp_Down.png",touch1,10,nil,nil)
          local menu1 = CCMenu:createWithItem(menuItem1);
          menu1:setPosition(ccp(520,70));
          menu1:setTouchPriority(-(self.layerNum-1)*20-2);
          cell:addChild(menu1,3);
          
          if self.isPrestige==true then
            menuItem1:setEnabled(false)
          
          end

       elseif idx==1 then
          local photoSp = CCSprite:createWithSpriteFrameName("Icon_prompt_2.png");
          photoSp:setAnchorPoint(ccp(0,0.5));
          photoSp:setPosition(ccp(10,backSprie:getContentSize().height/2));
          cell:addChild(photoSp,2);

          local desLb1 = GetTTFLabelWrap(getlocal("reputation_scene_medal_info_5"),28,CCSizeMake(380,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter);
          desLb1:setAnchorPoint(ccp(0,1));
          desLb1:setPosition(ccp(110,135));
          cell:addChild(desLb1,2);
          
          local desLb2 = GetTTFLabel(getlocal("reputation_scene_medal_info_6"),28);
          desLb2:setAnchorPoint(ccp(0,0.5));
          desLb2:setPosition(ccp(110,40));
          cell:addChild(desLb2,2);
          
          local function touch1()
                PlayEffect(audioCfg.mouseClick)
                if self.tv:getIsScrolled()==true then
                    return
                end
                
                local function buyGems()
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    end
                vipVoApi:showRechargeDialog(self.layerNum+1)

                end
                if playerVo.gems<10 then
                    local num=10-playerVo.gems
                    local smallD=smallDialog:new()
                         smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{10,playerVo.gems,num}),nil,self.layerNum+1)
                else
                        local function touchAddPrestige()
                        local function serverDailyHonors(fn,data)
                        --local retTb=OBJDEF:decode(data)
                        if base:checkServerData(data)==true then
                                self:showTips(80)
                                -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("reputation_prompt_success",{80}),28)
                                self:judgeIsPrestige()
                                
                            end
                        end
                        socketHelper:dailyHonors(2,serverDailyHonors)

                            


                        end

                        local smallD=smallDialog:new()
                         smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchAddPrestige,getlocal("dialog_title_prompt"),getlocal("reputation_scene_prompt_1"),nil,self.layerNum+1)

                end

                
          end
          local menuItem1 = GetButtonItem("BtnUp.png","BtnUp_Down.png","BtnUp_Down.png",touch1,10,nil,nil)
          local menu1 = CCMenu:createWithItem(menuItem1);
          menu1:setPosition(ccp(520,70));
          menu1:setTouchPriority(-(self.layerNum-1)*20-2);
          cell:addChild(menu1,3);
          
          if self.isPrestige==true then
            menuItem1:setEnabled(false)
          
          end
          
       elseif idx==2 then
          local photoSp = CCSprite:createWithSpriteFrameName("Icon_prompt_3.png");
          photoSp:setAnchorPoint(ccp(0,0.5));
          photoSp:setPosition(ccp(10,backSprie:getContentSize().height/2));
          cell:addChild(photoSp,2);

          local desLb1 = GetTTFLabelWrap(getlocal("reputation_scene_medal_info_7"),28,CCSizeMake(380,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter);
          desLb1:setAnchorPoint(ccp(0,1));
          desLb1:setPosition(ccp(110,135));
          cell:addChild(desLb1,2);
          
          local desLb2 = GetTTFLabel(getlocal("reputation_scene_medal_info_8"),28);
          desLb2:setAnchorPoint(ccp(0,0.5));
          desLb2:setPosition(ccp(110,40));
          cell:addChild(desLb2,2);
          
          local function touch1()
                if self.tv:getIsScrolled()==true then
                    return
                end
                PlayEffect(audioCfg.mouseClick)
                
                local function buyGems()
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    end
                   vipVoApi:showRechargeDialog(self.layerNum+1)

                end
                if playerVo.gems<40 then
                    local num=40-playerVo.gems
                    local smallD=smallDialog:new()
                         smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{40,playerVo.gems,num}),nil,self.layerNum+1)
                else

                    local function touchAddPrestige()
                        local function serverDailyHonors(fn,data)
                            --local retTb=OBJDEF:decode(data)
                            if base:checkServerData(data)==true then
                                -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("reputation_prompt_success",{400}),28)
                                self:showTips(400)
                                self:judgeIsPrestige()
                            end
                        end
                        socketHelper:dailyHonors(3,serverDailyHonors)


                    end
                        
                    local smallD=smallDialog:new()
                         smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchAddPrestige,getlocal("dialog_title_prompt"),getlocal("reputation_scene_prompt_2"),nil,self.layerNum+1)
                end
                
          end
          local menuItem1 = GetButtonItem("BtnUp.png","BtnUp_Down.png","BtnUp_Down.png",touch1,10,nil,nil)
          local menu1 = CCMenu:createWithItem(menuItem1);
          menu1:setPosition(ccp(520,70));
          menu1:setTouchPriority(-(self.layerNum-1)*20-2);
          cell:addChild(menu1,3);
          if self.isPrestige==true then
            menuItem1:setEnabled(false)
          
          end
          
        elseif idx==3 then
          local photoSp = CCSprite:createWithSpriteFrameName("Icon_prompt_4.png");
          photoSp:setAnchorPoint(ccp(0,0.5));
          photoSp:setPosition(ccp(10,backSprie:getContentSize().height/2));
          cell:addChild(photoSp,2);

          local desLb1 = GetTTFLabelWrap(getlocal("reputation_scene_medal_info_9"),28,CCSizeMake(380,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter);
          desLb1:setAnchorPoint(ccp(0,1));
          desLb1:setPosition(ccp(110,135));
          cell:addChild(desLb1,2);
          
          local desLb2 = GetTTFLabel(getlocal("reputation_scene_medal_info_10"),28);
          desLb2:setAnchorPoint(ccp(0,0.5));
          desLb2:setPosition(ccp(110,40));
          cell:addChild(desLb2,2);
          
          local function touch1()
                if self.tv:getIsScrolled()==true then
                    return
                end
                PlayEffect(audioCfg.mouseClick)
                
                local function buyGems()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                end
                   vipVoApi:showRechargeDialog(self.layerNum+1)

                end
                if playerVo.gems<90 then
                    local num=90-playerVo.gems
                    local smallD=smallDialog:new()
                         smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{90,playerVo.gems,num}),nil,self.layerNum+1)
                else

                    local function touchAddPrestige()
                        local function serverDailyHonors(fn,data)
                            --local retTb=OBJDEF:decode(data)
                            if base:checkServerData(data)==true then
                                -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("reputation_prompt_success",{1000}),28)
                                self:showTips(1000)
                                self:judgeIsPrestige()
                            end
                        end
                        socketHelper:dailyHonors(4,serverDailyHonors)


                    end
                        
                    local smallD=smallDialog:new()
                         smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchAddPrestige,getlocal("dialog_title_prompt"),getlocal("reputation_scene_prompt_3"),nil,self.layerNum+1)
                end
                
          end
          local menuItem1 = GetButtonItem("BtnUp.png","BtnUp_Down.png","BtnUp_Down.png",touch1,10,nil,nil)
          local menu1 = CCMenu:createWithItem(menuItem1);
          menu1:setPosition(ccp(520,70));
          menu1:setTouchPriority(-(self.layerNum-1)*20-2);
          cell:addChild(menu1,3);
          if self.isPrestige==true then
            menuItem1:setEnabled(false)
          
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

--点击tab页签 idx:索引
function prestigeDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)    
    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function prestigeDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function prestigeDialog:cellClick(idx)
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

function prestigeDialog:tick()
    
end

function prestigeDialog:showTips(buyedHonors)
    local playerHonors =playerVoApi:getHonors() --用户当前的总声望值
    local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
    local honTb =Split(playerCfg.honors,",")
    local maxHonors =honTb[maxLevel] --当前服 最大声望值

    if base.isConvertGems ==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
        local gems = playerVoApi:convertGems(2,buyedHonors)

      local name,pic,desc,id,index,eType,equipId,bgname = getItem("gold","u")
      local num=gems
      local award={type="u",key="gold",pic=pic,name=name,num=num,desc=desc,id=id,bgname=bgname}
      local reward={award}

        -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("isConvertGemsShowTip",{gems}),28) 
        G_showRewardTip(reward,true)       
    else 
        local name,pic,desc,id,index,eType,equipId,bgname = getItem("honors","u")
        local num=buyedHonors
        local award={type="u",key="honors",pic=pic,name=name,num=num,desc=desc,id=id,bgname=bgname}
        local reward={award}
        G_showRewardTip(reward,true)
        -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("reputation_prompt_success",{buyedHonors}),28)
    end
          
end


function prestigeDialog:dispose()
    self.expandIdx=nil
    self.honorsLv=nil --用户声望等级
    self.playerHonors=nil --玩家当前声望值
    self.nextHonorsEx=nil --玩家下一级声望用的经验
    self.maxLevel=nil --当前服 最大等级
    self.maxHonors=nil --当前服 声望最大值
    self=nil

end




