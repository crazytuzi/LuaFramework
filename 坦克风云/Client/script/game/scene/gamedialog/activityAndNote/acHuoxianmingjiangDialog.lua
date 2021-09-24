
acHuoxianmingjiangDialog = commonDialog:new()

function acHuoxianmingjiangDialog:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
  self.timeLogTb={}
  self.itemLogTb={}
  self.itemNumLogTb={}
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
  CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/sanguang.plist")
	return nc
end	

function acHuoxianmingjiangDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
    -- 初始化log数据
  self:initLogData()
   
end	

function acHuoxianmingjiangDialog:initLayer()
  

	local function bgClick()
	end
	local h = G_VisibleSizeHeight - 90
  if(G_isIphone5())then
    h = G_VisibleSizeHeight - 100
  end
	local w = G_VisibleSizeWidth - 30 -- 背景框的宽度
	local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
    backSprie:setContentSize(CCSizeMake(w, 150))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setPosition(ccp(G_VisibleSizeWidth/2, h))
    self.bgLayer:addChild(backSprie)

    local function touch(tag,object)
    	PlayEffect(audioCfg.mouseClick)
    	local tabStr = {}
    	local tabColor = {}
    	tabStr = {"\n",getlocal("activity_huoxianmingjiang_tip3"),"\n",getlocal("activity_huoxianmingjiang_tip2"),"\n",getlocal("activity_huoxianmingjiang_tip1"),"\n"}
    	tabColor = {nil, nil, nil, nil, nil,nil, nil}
    	local td=smallDialog:new()
    	local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
    	sceneGame:addChild(dialog,self.layerNum+1)

    end

    local menuItemDesc = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.8)
  	local menuDesc=CCMenu:createWithItem(menuItemDesc)
  	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
  	menuDesc:setPosition(ccp(w-20, backSprie:getContentSize().height-10))
  	backSprie:addChild(menuDesc)

  	local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),25)
  	acLabel:setAnchorPoint(ccp(0.5,1))
  	acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, backSprie:getContentSize().height-10))
  	backSprie:addChild(acLabel)
 	acLabel:setColor(G_ColorGreen)
   
 	local acVo = acHuoxianmingjiangVoApi:getAcVo()
  local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
  local messageLabel=GetTTFLabel(timeStr,25)
  messageLabel:setAnchorPoint(ccp(0.5,1))
  messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, backSprie:getContentSize().height-10-acLabel:getContentSize().height))
 	backSprie:addChild(messageLabel)
  self.timeLb=messageLabel
  self:updateAcTime()

 	local desTv, desLabel = G_LabelTableView(CCSizeMake(w-90, 70),getlocal("activity_huoxianmingjiang_desc"),25,kCCTextAlignmentLeft)
 	backSprie:addChild(desTv)
    desTv:setPosition(ccp(55,5))
    desTv:setAnchorPoint(ccp(0.5,1))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(100)  

    -- 添加星星
    self:addIconWar()
    self:refreshStar(acHuoxianmingjiangVoApi:getStar())
    self:addIconWarLabel()

    -- 添加英雄显示信息
    self:addHeroInfo()

    -- 添加抽奖记录
    self:addChoujiangjilu()

    local function touch( ... )      
    end
    local btnBg =LuaCCScale9Sprite:createWithSpriteFrameName("RankItemBg.png",CCRect(40, 40, 10, 10),touch)
    if(G_isIphone5())then
        btnBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,150))
        btnBg:setPosition(ccp(G_VisibleSizeWidth/2,30))
    else
       btnBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,120))
       btnBg:setPosition(ccp(G_VisibleSizeWidth/2,25))
    end
       
    btnBg:setAnchorPoint(ccp(0.5, 0))
    self.bgLayer:addChild(btnBg)



     local function touchTenRecruitItem()
         if G_checkClickEnable()==false then
                  do
                      return
                  end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
          end
        PlayEffect(audioCfg.mouseClick)
        local cost =  acHuoxianmingjiangVoApi:getTenCost()
        if playerVoApi:getGems()<cost then
            GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
            return
        end

        local function callback(fn,data)
            local oldHeroList3=heroVoApi:getHeroList()
            local ret,sData = base:checkServerData(data)
              if ret==true then 
                if sData.data==nil then 
                  return
                end


                if sData.data and sData.data.hero and sData.data.hero.report and self and self.bgLayer then
                    local content={}
                    local msgContent={}
                    local report=sData.data.hero.report or {}
                    local starTb=sData.data.star or {}
                    local initStar=acHuoxianmingjiangVoApi:getStar() or {0,0,0,0}

                                      
                    local numOfStar = 0
                    local addIndex=0
                    local starFlag = false
                    local startFlag = true

                    for k,v in pairs(initStar) do
                        if v==1 then
                            numOfStar=numOfStar+1
                        end
                    end

                    local startNumOfStar=numOfStar

                    for k,v in pairs(report) do

                        local addNumStar = 0
                        local indexNum = {} 
                        local star = starTb[k]

                        if startNumOfStar == 4 then 
                          initStar = {0,0,0,0}
                        end
                        for m,n in pairs(star) do
                          if k == 1 then

                               if n==1 and n-initStar[m]==1 then
                                  indexNum[m]=1
                                  addNumStar = addNumStar+1
                                  indexNum[addNumStar] = m
                                  numOfStar = numOfStar+1
                               end
                          else
                              if starFlag then 
                                starTb[k-1] = {0,0,0,0}
                              end
                               if n==1 and n-starTb[k-1][m]==1 then
                                  -- indexNum[m]=1
                                  addNumStar = addNumStar+1
                                  indexNum[addNumStar] = m
                                  numOfStar = numOfStar+1
                               end
                          end
                        end


                        local awardTb=FormatItem(v[1]) or {}

                        local award=awardTb[1]
                        local showStr=""
                        local existStr=""
                        if award.type=="h" and award.eType=="h" then
                            local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(award,oldHeroList3)
                            if heroIsExist==true then
                                if heroVoApi:heroHonorIsOpen()==true and  heroVoApi:getIsHonored(award.key)==true then
                                    existStr=","..getlocal("hero_honor_recruit_honored_hero",{addNum})
                                    if addNum and addNum>0 then
                                        local pid=heroCfg.getSkillItem
                                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                                        bagVoApi:addBag(id,addNum)
                                    end
                                else
                                    if newProductOrder then
                                        existStr=","..getlocal("hero_breakthrough_desc",{newProductOrder})
                                    else
                                        existStr=","..getlocal("alreadyHasDesc",{addNum})
                                    end
                                end
                            elseif heroIsExist==false then
                                local vo = heroVo:new()
                                vo.hid=award.key
                                vo.level=1
                                vo.points=0
                                vo.productOrder=award.num
                                vo.skill={}
                                table.insert(oldHeroList3,vo)

                                heroVoApi:getNewHeroChat(award.key)
                            end
                            showStr=getlocal("congratulationsGet",{award.name})..existStr

                            -- heroVoApi:getNewHeroChat(award.key)
                        else
                            showStr=getlocal("congratulationsGet",{award.name .. "*" .. award.num})
                            if award.type=="h" and award.eType=="s" then
                                local heroid=heroCfg.soul2hero[award.key]
                                if heroVoApi:heroHonorIsOpen()==true and  heroVoApi:getIsHonored(heroid)==true then
                                    existStr=","..getlocal("hero_honor_recruit_honored_hero",{award.num})
                                    showStr=showStr..existStr
                                    local addNum=award.num
                                    if addNum and addNum>0 then
                                        local pid=heroCfg.getSkillItem
                                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                                        bagVoApi:addBag(id,addNum)
                                    end
                                end
                            end
                        end

                       

                        if starFlag or startNumOfStar== 4 then 
                          table.insert(msgContent,{showStr,G_ColorYellowPro})
                        else
                          table.insert(msgContent,{showStr,G_ColorWhite})
                        end
                        table.insert(content,{award=award,point=0,index=(k+addIndex)})

                        if startNumOfStar== 4 then 
                           local mustgetHero = acHuoxianmingjiangVoApi:mustGetHero()
                          local hid,heroProductOrder = self:getHidandheroProductOrder(mustgetHero)
                          local showStr1=getlocal("activity_huoxianmingjiang_star_desc3",{heroProductOrder,heroVoApi:getHeroName(hid)})
                          table.insert(msgContent,{showStr1,G_ColorYellowPro})
                          local award1={pic="IconWar.png",type="",name="",desc=""}
                          table.insert(content,{award=award1,point=0,index=(k+addIndex)})
                          if numOfStar== 4 then 
                            numOfStar = addNumStar
                          end
                        end
                        

                        if starFlag then 
                           local mustgetHero = acHuoxianmingjiangVoApi:mustGetHero()
                          local hid,heroProductOrder = self:getHidandheroProductOrder(mustgetHero)
                          local showStr1=getlocal("activity_huoxianmingjiang_star_desc3",{heroProductOrder,heroVoApi:getHeroName(hid)})
                          table.insert(msgContent,{showStr1,G_ColorYellowPro})
                          local award1={pic="IconWar.png",type="",name="",desc=""}
                          table.insert(content,{award=award1,point=0,index=(k+addIndex)})
                          starFlag = false
                        end
                        


                        for i=1,addNumStar do 

                          local showStr1=getlocal("activity_huoxianmingjiang_star_desc1",{indexNum[i]})
                          addIndex=addIndex+1
                          table.insert(msgContent,{showStr1,G_ColorYellowPro})
                          local award1={pic="IconWar.png",type="",name="",desc=""}
                          table.insert(content,{award=award1,point=0,index=(k+addIndex)})
                          
                        end                       

                        if numOfStar == 4 and startNumOfStar~=4 then 
                          local mustgetHero = acHuoxianmingjiangVoApi:mustGetHero()
                          local hid,heroProductOrder = self:getHidandheroProductOrder(mustgetHero)
                          local showStr1=getlocal("activity_huoxianmingjiang_star_desc2",{heroProductOrder,heroVoApi:getHeroName(hid)})
                          table.insert(msgContent,{showStr1,G_ColorYellowPro})
                          local award1={pic="IconWar.png",type="",name="",desc=""}
                          table.insert(content,{award=award1,point=0,index=(k+addIndex)})
                          numOfStar = 0
                          starFlag = true
                        end  
                        startNumOfStar = nil            
                                       


                        G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)

                    end

                    if content and SizeOfTable(content)>0 then
                        local function confirmHandler(awardIdx)
                        end
                        smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("heroRecruitTotal"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,nil,msgContent)
                        playerVoApi:setValue("gems",playerVoApi:getGems()-cost)
                        acHuoxianmingjiangVoApi:updateData(sData.data.huoxianmingjiang)
                        self:refreshStar(acHuoxianmingjiangVoApi:getStar())
                        self:refreshLogData()
                    end
                end

              end
        end

        socketHelper:activityHuoxianmingjiangChoujiang(1,callback)
     end

      local addH1 = 0
      local addH2 = 0
      if (G_isIphone5()) then
        addH1 = 15
        addH2 = 5
      end
      local strSize = 25
      if G_getCurChoseLanguage() =="ru" then
        strSize =22
      end
     local tenRecruitItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",touchTenRecruitItem,nil,getlocal("activity_huoxianmingjiang_btnTen"),strSize)
       tenRecruitItem:setAnchorPoint(ccp(0.5,0))
       local tenRecruitBtn=CCMenu:createWithItem(tenRecruitItem);
       tenRecruitBtn:setTouchPriority(-(self.layerNum-1)*20-4);
       tenRecruitBtn:setPosition(ccp(G_VisibleSizeWidth/2+125,10+addH2))
       btnBg:addChild(tenRecruitBtn)

       local cost = acHuoxianmingjiangVoApi:getTenCost()
       local tenLabel = GetTTFLabel(tostring(cost),25)
       tenLabel:setAnchorPoint(ccp(0,0))
       tenLabel:setPosition(G_VisibleSizeWidth/2+125-tenRecruitItem:getContentSize().width/4+20, 10+tenRecruitItem:getContentSize().height+addH1)
       tenLabel:setColor(G_ColorYellowPro)
       btnBg:addChild(tenLabel)

       local tenGem = CCSprite:createWithSpriteFrameName("IconGold.png")
       tenGem:setAnchorPoint(ccp(0,0))
       tenGem:setPosition(G_VisibleSizeWidth/2+125-tenRecruitItem:getContentSize().width/4+tenLabel:getContentSize().width+20, 10+tenRecruitItem:getContentSize().height+addH1)
       btnBg:addChild(tenGem) 

       local function touchOneRecruitItem()
           if G_checkClickEnable()==false then
                  do
                      return
                  end
            else
            base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            -- 判断是不是免费
            local free = 0
            if acHuoxianmingjiangVoApi:isToday() then
              free = 1
            end


            -- 判断金币是否够
            local cost =  acHuoxianmingjiangVoApi:getOneCost()
            if playerVoApi:getGems()<cost and free==1 then
              GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
              return
            end

            local function callBack(fn,data)
              local oldHeroList=heroVoApi:getHeroList()
              local ret,sData = base:checkServerData(data)
              if ret==true then 
                if sData.data==nil then 
                  return
                end
                -- self:refresh()

                if sData.data and sData.data.hero and sData.data.hero.report then
                    self:showHero(sData.data.hero.report[1][1],oldHeroList)
                end

                local initStar=acHuoxianmingjiangVoApi:getStar() or {0,0,0,0}
                local starTb=sData.data.star or {}

                local numOfStar = 0
                local addIndex=0
                local starFlag = false
                local addNumStar = 0
                local indexNum = {} 

                for k,v in pairs(initStar) do
                    if v==1 then
                        numOfStar=numOfStar+1
                    end
                end

                if numOfStar== 4 then
                 initStar = {0,0,0,0}
                 numOfStar = 0
                end

                for k,v in pairs(starTb[1]) do
                    if v==1 and v-initStar[k]==1 then
                        addNumStar = addNumStar+1
                        indexNum[addNumStar] = k
                        numOfStar = numOfStar+1
                    end
                end
                local showStr = nil
                if addNumStar==1 then
                  showStr = getlocal("activity_huoxianmingjiang_star_desc1",{indexNum[1]})
                elseif addNumStar==2 then
                   showStr = getlocal("activity_huoxianmingjiang_star_desc4",{indexNum[1],indexNum[2]})
                elseif addNumStar==3 then
                   showStr = getlocal("activity_huoxianmingjiang_star_desc5",{indexNum[1],indexNum[2],indexNum[3]})
                elseif addNumStar==4 then
                   showStr = getlocal("activity_huoxianmingjiang_star_desc6",{indexNum[1],indexNum[2],indexNum[3],indexNum[4]})
                end

                if showStr ~= nil then 
                  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),showStr,30)
                end

              

                -- 免费的不扣用户端的金币
                if free==1 then 
                      playerVoApi:setValue("gems",playerVoApi:getGems()-cost)

                end
                self:checkOneRecruitVisible(false)
      
                acHuoxianmingjiangVoApi:updateData(sData.data.huoxianmingjiang)
                self:refreshStar(acHuoxianmingjiangVoApi:getStar())
                self:refreshLogData()
              end
            end

            socketHelper:activityHuoxianmingjiangChoujiang(0,callBack)
       end


       local oneRecruitItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",touchOneRecruitItem,nil,getlocal("activity_huoxianmingjiang_btnOne"),strSize)
       oneRecruitItem:setAnchorPoint(ccp(0.5,0))
       local oneRecruitBtn=CCMenu:createWithItem(oneRecruitItem);
       oneRecruitBtn:setTouchPriority(-(self.layerNum-1)*20-4);
       oneRecruitBtn:setPosition(ccp(G_VisibleSizeWidth/2-150,10+addH2))
       btnBg:addChild(oneRecruitBtn)

       self.oneLabel = GetTTFLabel(getlocal("activity_equipSearch_free_btn"),20)
       self.oneLabel:setAnchorPoint(ccp(0,0))
       self.oneLabel:setPosition(G_VisibleSizeWidth/2-150-oneRecruitItem:getContentSize().width/4, 10+oneRecruitItem:getContentSize().height+addH1)
       btnBg:addChild(self.oneLabel)
       self.oneLabel :setColor(G_ColorGreen)

       local oneCost = acHuoxianmingjiangVoApi:getOneCost()
       self.oneCostLabel = GetTTFLabel(tostring(oneCost),25)
       self.oneCostLabel:setAnchorPoint(ccp(0,0))
       self.oneCostLabel:setPosition(G_VisibleSizeWidth/2-150-oneRecruitItem:getContentSize().width/4+20, 10+oneRecruitItem:getContentSize().height+addH1)
       self.oneCostLabel:setColor(G_ColorYellowPro)
       btnBg:addChild(self.oneCostLabel)

       self.oneGem = CCSprite:createWithSpriteFrameName("IconGold.png")
       self.oneGem:setAnchorPoint(ccp(0,0))
       self.oneGem:setPosition(G_VisibleSizeWidth/2-150-oneRecruitItem:getContentSize().width/4+self.oneCostLabel:getContentSize().width+20, 10+oneRecruitItem:getContentSize().height+addH1)
       btnBg:addChild(self.oneGem) 
       if acHuoxianmingjiangVoApi:isToday() then 
        self:checkOneRecruitVisible(false)
       else
        self:checkOneRecruitVisible(true)
       end
       

end

function acHuoxianmingjiangDialog:initLogData()
  local function callBack(fn,data)
    local ret,sData = base:checkServerData(data)
    if ret==true then 
      if sData.data==nil then 
        return
      end
       acHuoxianmingjiangVoApi:clearLogData()
      if sData.data and sData.data.log then
       
        acHuoxianmingjiangVoApi:initLogData(sData.data.log)

      end
      self.timeLogTb,self.itemLogTb,self.itemNumLogTb = acHuoxianmingjiangVoApi:getLogList()

      self:initLayer()
    end                
  end
   socketHelper:activityHuoxianmingjiangChoujiangLog(callBack)
end

function acHuoxianmingjiangDialog:refreshLogData()
  local function callBack(fn,data)
    local ret,sData = base:checkServerData(data)
    if ret==true then 
      if sData.data==nil then 
        return
      end

      if sData.data and sData.data.log then
        acHuoxianmingjiangVoApi:clearLogData()
        acHuoxianmingjiangVoApi:initLogData(sData.data.log)
      end
      self.timeLogTb,self.itemLogTb,self.itemNumLogTb = acHuoxianmingjiangVoApi:getLogList()
      self:refreshRecentLog()
    end                
  end
   socketHelper:activityHuoxianmingjiangChoujiangLog(callBack)
end

function acHuoxianmingjiangDialog:checkOneRecruitVisible(isFree)
  if isFree and self.oneLabel then
    self.oneLabel:setVisible(true)
    self.oneCostLabel:setVisible(false)
    self.oneGem:setVisible(false)
  elseif self.oneLabel then
    self.oneLabel:setVisible(false)
    self.oneCostLabel:setVisible(true)
    self.oneGem:setVisible(true)
  end
end

function acHuoxianmingjiangDialog:showHero(reward,oldHeroList)
    if reward then
        local rewardTb=FormatItem(reward)
        local award=rewardTb[1]
        if award then
            if award.type=="h" then
                local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(award,oldHeroList)
                G_recruitShowHero(type,award,self.layerNum+1,heroIsExist,addNum,nil,newProductOrder)

                if award.eType=="h" and heroIsExist==false then
                    heroVoApi:getNewHeroChat(award.key)
                end

                if heroVoApi:heroHonorIsOpen()==true then
                    local hid
                    if award.eType=="h" then 
                        hid=award.key
                    elseif award.eType=="s" then
                        hid=heroCfg.soul2hero[award.key]
                    end 
                    if hid and heroVoApi:getIsHonored(hid)==true then
                        local pid=heroCfg.getSkillItem
                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                        bagVoApi:addBag(id,addNum)
                    end
                end
            else
                G_addPlayerAward(award.type,award.key,award.id,award.num,false,true)
                G_recruitShowHero(3,award,self.layerNum+1,nil,nil,nil)
            end
        end
    end
end

function acHuoxianmingjiangDialog:getHidandheroProductOrder(mustgetHero)
    local hid 
     local heroProductOrder
     for k,v in pairs(mustgetHero) do
       hid = Split(k,"_")[2]
       heroProductOrder = v
     end
     return hid,heroProductOrder
end

-- 添加英雄显示信息
function acHuoxianmingjiangDialog:addHeroInfo()
  local h = G_VisibleSizeHeight/2-85
   if(G_isIphone5())then
    h = G_VisibleSizeHeight/2-80
   end
  local sanguang = CCSprite:createWithSpriteFrameName("sanguang.png");
     -- sanguang:setAnchorPoint(ccp(0.5,1))
     sanguang:setScaleY(1.2)
     self.bgLayer:addChild(sanguang)
     sanguang:setPosition(G_VisibleSizeWidth/2-110,h)    
     
     local function touchHeroIcon(...)
        PlayEffect(audioCfg.mouseClick)        
        require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangHeroInfoDialog"

        local mustgetHero = acHuoxianmingjiangVoApi:mustGetHero()
        local hid,heroProductOrder = self:getHidandheroProductOrder(mustgetHero)

        local td = acHuoxianmingjiangHeroInfoDialog:new(hid,heroProductOrder)
        local dialog = td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(600,800),getlocal("report_hero_message"))
        sceneGame:addChild(dialog,self.layerNum+1)
        
     end   

     local mustgetHero = acHuoxianmingjiangVoApi:mustGetHero()
     local hid,heroProductOrder = self:getHidandheroProductOrder(mustgetHero)

     local heroIcon = heroVoApi:getHeroIcon(hid,heroProductOrder,true,touchHeroIcon,nil,nil,nil,{adjutants={}})
     heroIcon:setTouchPriority(-(self.layerNum-1)*20-2)
     heroIcon:setPosition(G_VisibleSizeWidth/2-200,h)
     heroIcon:setScale(0.8)
     self.bgLayer:addChild(heroIcon)

     local function tmpFunc()
     end
     local desBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),tmpFunc)
     desBg:setPosition(ccp(G_VisibleSizeWidth/2+120, h))
     desBg:setContentSize(CCSizeMake(355,340))
     self.bgLayer:addChild(desBg)

     local desBgSize = desBg:getContentSize()
     local heroNameLabel = GetTTFLabel(heroVoApi:getHeroName(hid),30)
     heroNameLabel:setAnchorPoint(ccp(0,1))
     heroNameLabel:setColor(heroVoApi:getHeroColor(heroProductOrder))
     heroNameLabel:setPosition(ccp(20, desBgSize.height-30))
     desBg:addChild(heroNameLabel)

     local productOrderLabel = GetTTFLabel(getlocal("hero_productOrder"),25)
     productOrderLabel:setPosition(ccp(20,desBgSize.height-90))
     productOrderLabel:setAnchorPoint(ccp(0,0.5))
     desBg:addChild(productOrderLabel)

     if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw"  then
          local xinW = productOrderLabel:getContentSize().width+50
          for i=1,5 do
              local spriteStar
               if i<=heroProductOrder then
                    spriteStar = CCSprite:createWithSpriteFrameName("StarIcon.png")
               else
                    -- spriteStar = CCSprite:createWithSpriteFrameName("gameoverstar_black.png")
                    -- spriteStar:setScale(0.36)
               end
               if spriteStar  then
                 desBg:addChild(spriteStar)
                 spriteStar:setPosition(ccp(xinW,desBgSize.height-90))
               end
               xinW = xinW+40
           end
    else
        local xinW = 40
          for i=1,5 do
              local spriteStar
               if i<=heroProductOrder then
                    spriteStar = CCSprite:createWithSpriteFrameName("StarIcon.png")
               else
                    -- spriteStar = CCSprite:createWithSpriteFrameName("gameoverstar_black.png")
                    -- spriteStar:setScale(0.36)
               end
               if spriteStar then
                 desBg:addChild(spriteStar)
                 spriteStar:setPosition(ccp(xinW,desBgSize.height-120))
               end
               xinW = xinW+40
           end
     
    end
     local desLH = desBgSize.height-130
     if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw"  then
         desLH = desBgSize.height-130
      else
          desLH = desBgSize.height-157
      end
     local heroDesLabel = GetTTFLabel(getlocal("hero_info_Introduction_title"), 25)
     heroDesLabel:setAnchorPoint(ccp(0, 0.5))
     heroDesLabel:setPosition(ccp(20, desLH))
     desBg:addChild(heroDesLabel)

     local function bgClick()
     end

     local desbgSize = CCSizeMake(310, 150)
     if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw"  then
        desbgSize = CCSizeMake(310, 150)
     else
        desbgSize = CCSizeMake(310,125)
     end


     local desBackSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
    desBackSprie:setContentSize(desbgSize)
    desBackSprie:setAnchorPoint(ccp(0,0))
    desBackSprie:setPosition(ccp(20, 30))
    desBg:addChild(desBackSprie)

     local heroDesTvSize = CCSizeMake(290, 107)
     if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw"  then
        heroDesTvSize = CCSizeMake(290, 105)
     else
        heroDesTvSize = CCSizeMake(290, 90)
     end

     local desStr
     local ver = acHuoxianmingjiangVoApi:getVersion()
     if ver <6 then
       if ver == 1 or ver == 3 then 
          desStr = getlocal("hero_info_Introduction1")
       elseif ver == 2 or ver == 4 then
          desStr = getlocal("hero_info_Introduction2")
       elseif ver ==5 then
          desStr = getlocal("active_mingjiang_hero_des")
       end
     else
       if ver ==6 then
          desStr =getlocal("active_mingjiang_hero_des4")
       elseif ver ==7 then
          desStr =getlocal("active_mingjiang_hero_des5")
       elseif ver ==8 then
          desStr =getlocal("active_mingjiang_hero_des6")
       elseif ver ==9 then
          desStr =getlocal("active_mingjiang_hero_des7")
       elseif ver ==10 then
          desStr =getlocal("active_mingjiang_hero_des8")
       elseif ver == 11 then
          desStr =getlocal("active_mingjiang_hero_des11")
       end
     end
    local heroDesTv, heroIntroduction = G_LabelTableView(heroDesTvSize,desStr,25,kCCTextAlignmentLeft)
    desBackSprie:addChild(heroDesTv)
    heroDesTv:setPosition(ccp(10,20))
    heroDesTv:setAnchorPoint(ccp(0,0))
    heroDesTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    heroDesTv:setMaxDisToBottomOrTop(100) 
end

-- 添加抽奖记录
function acHuoxianmingjiangDialog:addChoujiangjilu()
  local h = G_VisibleSizeHeight-782
   if(G_isIphone5())then
    h = G_VisibleSizeHeight-900
   end
  local function bgClick()
  end
  local logBackSprite = LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBg.png",CCRect(20, 20, 10, 10),bgClick)
    logBackSprite:setRotation(180)
    logBackSprite:setContentSize(CCSizeMake(G_VisibleSizeWidth-50, 70))
    logBackSprite:setPosition(ccp(G_VisibleSizeWidth/2, h))    
    self.bgLayer:addChild(logBackSprite)
    local eventStr = getlocal("activity_huoxianmingjiang_log_tip0")
    local color = G_ColorWhite
    if SizeOfTable(self.timeLogTb)~=0 then

      if string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)],1,1)=="h" then
        eventStr = getlocal("activity_huoxianmingjiang_log_tip1",{self.itemNumLogTb[SizeOfTable(self.timeLogTb)],heroVoApi:getHeroName(self.itemLogTb[SizeOfTable(self.timeLogTb)])})
        color = G_ColorYellow
       elseif string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)],1,1)=="s" then
       eventStr = getlocal("activity_huoxianmingjiang_log_tip2",{heroVoApi:getHeroName(heroCfg.soul2hero[self.itemLogTb[SizeOfTable(self.timeLogTb)]]),self.itemNumLogTb[SizeOfTable(self.timeLogTb)]})
         
       elseif string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)],1,1)=="p" then
        eventStr = getlocal("activity_huoxianmingjiang_log_tip3",{getlocal(propCfg[self.itemLogTb[SizeOfTable(self.timeLogTb)]].name),self.itemNumLogTb[SizeOfTable(self.timeLogTb)]})
       end
    end
  self.recentLog = GetTTFLabelWrap(eventStr, 25, CCSizeMake(450,0), kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  self.recentLog:setColor(color)
   self.recentLog:setAnchorPoint(ccp(0,0.5))
   self.bgLayer:addChild(self.recentLog)
   self.recentLog:setPosition(ccp(150, h))


  local function heroItemTouch()
     if G_checkClickEnable()==false then
                do
                    return
                end
          else
              base.setWaitTime=G_getCurDeviceMillTime()
        end
      PlayEffect(audioCfg.mouseClick)

       require "luascript/script/game/scene/gamedialog/activityAndNote/acHuoxianmingjiangLogDialog"
       local td = acHuoxianmingjiangLogDialog:new(self.timeLogTb,self.itemLogTb,self.itemNumLogTb)
       local dialog = td:init("PanelHeaderPopup.png",self.layerNum+1,CCRect(168, 86, 10, 10),CCSizeMake(600,800),getlocal("activity_customLottery_RewardRecode"))
       sceneGame:addChild(dialog,self.layerNum+1)
 
    end
    local heroInfoItem = GetButtonItem("hero_infoBtn.png","hero_infoBtn.png","hero_infoBtn.png",heroItemTouch,11,nil,nil)
    heroInfoItem:setScale(0.9)
   local heroMenu = CCMenu:createWithItem(heroInfoItem)
   heroMenu:setAnchorPoint(ccp(0,0.5))
   
   heroMenu:setTouchPriority(-(self.layerNum-1)*20-4)
   self.bgLayer:addChild(heroMenu)
    if(G_isIphone5())then
      logBackSprite:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, 70))
      heroInfoItem:setScale(1.1)
      heroMenu:setPosition(ccp(63,h-15))
      logBackSprite:setPosition(ccp(G_VisibleSizeWidth/2, h-15))
      self.recentLog:setPosition(ccp(150, h-15))
    else
      heroMenu:setPosition(ccp(58,h))
    end
end

function acHuoxianmingjiangDialog:refreshRecentLog()
  local eventStr = getlocal("activity_huoxianmingjiang_log_tip0")
    local color = G_ColorWhite
    if SizeOfTable(self.timeLogTb)~=0 then

      if string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)],1,1)=="h" then
        eventStr = getlocal("activity_huoxianmingjiang_log_tip1",{self.itemNumLogTb[SizeOfTable(self.timeLogTb)],heroVoApi:getHeroName(self.itemLogTb[SizeOfTable(self.timeLogTb)])})
        color = G_ColorYellow
       elseif string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)],1,1)=="s" then
       eventStr = getlocal("activity_huoxianmingjiang_log_tip2",{heroVoApi:getHeroName(heroCfg.soul2hero[self.itemLogTb[SizeOfTable(self.timeLogTb)]]),self.itemNumLogTb[SizeOfTable(self.timeLogTb)]})
         
       elseif string.sub(self.itemLogTb[SizeOfTable(self.timeLogTb)],1,1)=="p" then
        eventStr = getlocal("activity_huoxianmingjiang_log_tip3",{getlocal(propCfg[self.itemLogTb[SizeOfTable(self.timeLogTb)]].name),self.itemNumLogTb[SizeOfTable(self.timeLogTb)]})
       end
    end
  self.recentLog:setString(eventStr)
end

-- 添加星星
function acHuoxianmingjiangDialog:addIconWar()
   local h = G_VisibleSizeHeight-285
   if(G_isIphone5())then
    h = G_VisibleSizeHeight - 310
   end
  local w = G_VisibleSizeWidth/2-202-40
  
   local function itemTouch()
    end
    for i=1,4 do
       local item = GetButtonItem("IconWar.png","IconWar.png","IconWar.png",itemTouch,i)
       item:setAnchorPoint(ccp(0, 0.5))
       item:setEnabled(false)
       item:setTag(i)
       local menu = CCMenu:createWithItem(item)
       menu:setPosition(w, h)
       menu:setTag(i+1000)
       menu:setTouchPriority(-(self.layerNum-1)*20-1)
       self.bgLayer:addChild(menu)
       w = w + 121
    end 
end 

function acHuoxianmingjiangDialog:addIconWarLabel()

  local h = G_VisibleSizeHeight-360
   if(G_isIphone5())then
    h = G_VisibleSizeHeight - 400
   end
   local mustgetHero = acHuoxianmingjiangVoApi:mustGetHero()
     local hid,_ = self:getHidandheroProductOrder(mustgetHero)

    local xinLabel = GetTTFLabelWrap(getlocal("activity_huoxianmingjiang_xingxing",{heroVoApi:getHeroName(hid)}), 25, CCSizeMake(500,0), kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
     local xinLabelSize  = xinLabel:getContentSize()
     xinLabel:setColor(G_ColorYellowPro)
     xinLabel:setPosition(ccp(G_VisibleSizeWidth/2,h))
  
     local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
     titleBg:setContentSize(CCSizeMake(xinLabel:getContentSize().width,xinLabel:getContentSize().height+15))
     titleBg:setScaleX((G_VisibleSizeWidth-60)/xinLabelSize.width)
     titleBg:setPosition(ccp(G_VisibleSizeWidth/2,h))
     self.bgLayer:addChild(titleBg)
     self.bgLayer:addChild(xinLabel)
end

function acHuoxianmingjiangDialog:refreshStar(star)
  if star== nil then
    return
  end
  for k,v in pairs(star) do
     local menu = tolua.cast(self.bgLayer:getChildByTag(1000+k),"CCMenu")
     local item = tolua.cast(menu:getChildByTag(k),"CCMenuItem")
    if v==1 then
       
        item:setEnabled(true)
    else
        item:setEnabled(false)
    end
  end
end

function acHuoxianmingjiangDialog:initTableView()
	local function callBack(...)
       -- return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-25-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)

    self.tv:setMaxDisToBottomOrTop(120)
end

function acHuoxianmingjiangDialog:eventHandler(handler,fn,idx,cel)

end	

function acHuoxianmingjiangDialog:dispose()
	--CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("allianceWar/warMap.plist")
  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/sanguang.plist")
  self.timeLogTb=nil
  self.itemLogTb=nil
  self.itemNumLogTb=nil
  self.timeLb=nil
end

function 	acHuoxianmingjiangDialog:tick()
    local vo=acHuoxianmingjiangVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    if not acHuoxianmingjiangVoApi:isToday() then
      self:checkOneRecruitVisible(true)
    end
    self:updateAcTime()
end

function acHuoxianmingjiangDialog:updateAcTime()
  local acVo=acHuoxianmingjiangVoApi:getAcVo()
  if acVo and self.timeLb then
     G_updateActiveTime(acVo,self.timeLb)
  end
end
   


