acShengdankuanghuanTab2={
	
}

function acShengdankuanghuanTab2:new(  )
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.tv=nil
	self.bgLayer=nil
	self.layerNum=nil

    self.sixGift={}
	self.awaredData=nil
	self.state=nil   --状态


	return nc
end

function acShengdankuanghuanTab2:init(layerNum)

	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum

	self:initTableView()
	return self.bgLayer
end

function acShengdankuanghuanTab2:initTableView( )
    local headtitle,headLb,contentLb,tip1,tip2,tip3,titleIcon
    if acShengdankuanghuanVoApi:getVersion()~=nil and acShengdankuanghuanVoApi:getVersion() ==3 then
      headtitle ="activity_munitionsSacles_titleLb"
      headLb ="activity_munitionsSacles_Label"
      contentLb ="activity_munitionsSacles_content"
      tip1 ="activity_munitionsSacles_tip1"
      tip2 ="activity_munitionsSacles_tip2"
      tip3 ="activity_munitionsSacles_tip3"
      titleIcon="arsenalIcon.png"
    else
      headtitle="activity_shengdankuanghuan_eggHeaderLabel_1"
      headLb ="activity_shengdankuanghuan_eggHeaderLabel_2"
      contentLb ="activity_shengdankuanghuan_ChristmasTree_content"
      tip1 ="activity_shengdankuanghuan_ChristmasTreeTip1"
      tip2 ="activity_shengdankuanghuan_ChristmasTreeTip2"
      tip3 ="activity_shengdankuanghuan_ChristmasTreeTip3"
      titleIcon="ChristmasTreeIcon.png"   
    end
	  local headBs=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
    headBs:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,200))
    headBs:setAnchorPoint(ccp(0.5,1))
    headBs:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height - 165))
    self.bgLayer:addChild(headBs,4)

    local leftIcon = CCSprite:createWithSpriteFrameName(titleIcon)
    leftIcon:setPosition(ccp(20,headBs:getContentSize().height/2))
    leftIcon:setAnchorPoint(ccp(0,0.5))
    headBs:addChild(leftIcon,5)

    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),25)
    actTime:setPosition(ccp(headBs:getContentSize().width/2,headBs:getContentSize().height-20))
    headBs:addChild(actTime,5)
    actTime:setColor(G_ColorGreen)

    local acVo = acShengdankuanghuanVoApi:getAcVo()
    if acVo then
    	local timeStr = activityVoApi:getActivityTimeStr(acVo.st,acVo.et)
    	local timeLabel = GetTTFLabel(timeStr,25)
    	timeLabel:setPosition(ccp(headBs:getContentSize().width/2,headBs:getContentSize().height-20-actTime:getContentSize().height))
    	headBs:addChild(timeLabel,5)
    end
    local labeSize =25
    if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="ru" then
        labeSize = 23
    end

    local yellowLabel = GetTTFLabelWrap(getlocal(headtitle),labeSize,CCSizeMake(headBs:getContentSize().width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    yellowLabel:setPosition(ccp(leftIcon:getContentSize().width+30,90))
    yellowLabel:setAnchorPoint(ccp(0,0))
    yellowLabel:setColor(G_ColorYellow)
    headBs:addChild(yellowLabel,5)

    local desc1 = G_LabelTableView(CCSize(headBs:getContentSize().width-leftIcon:getContentSize().width-50,70),getlocal(headLb),25,kCCTextAlignmentLeft)
    desc1:setPosition(ccp(leftIcon:getContentSize().width+30,15))
    desc1:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    desc1:setAnchorPoint(ccp(0,1))
    headBs:addChild(desc1,2)
    desc1:setMaxDisToBottomOrTop(50)

    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
        adaH = 40
    end
   	local smalTitl = GetTTFLabel(getlocal("activity_fbReward_con"),26)
   	smalTitl:setAnchorPoint(ccp(0,0.5))
    smalTitl:setPosition(ccp(30,self.bgLayer:getContentSize().height-headBs:getContentSize().height-200-adaH))
   	smalTitl:setColor(G_ColorGreen)
   	self.bgLayer:addChild(smalTitl,5)

   	local desc2 = G_LabelTableView(CCSize(self.bgLayer:getContentSize().width-smalTitl:getContentSize().width-60,66),getlocal(contentLb),26,kCCTextAlignmentLeft)
   	desc2:setPosition(ccp(30+smalTitl:getContentSize().width,self.bgLayer:getContentSize().height-445-adaH))
   	desc2:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
   	desc2:setAnchorPoint(ccp(0,1))
   	desc2:setMaxDisToBottomOrTop(50)
   	self.bgLayer:addChild(desc2,5)

    local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSP:setAnchorPoint(ccp(0.5,0.5))
    lineSP:setScaleX(G_VisibleSizeWidth/lineSP:getContentSize().width)
    lineSP:setScaleY(1.2)
    lineSP:setPosition(ccp(G_VisibleSizeWidth/2,self.bgLayer:getContentSize().height-460-adaH*3/2))
    self.bgLayer:addChild(lineSP,2)

    self.pointLb = GetTTFLabelWrap("",25,CCSizeMake(self.bgLayer:getContentSize().width/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    self.pointLb:setAnchorPoint(ccp(0,1))
    self.pointLb:setPosition(40,self.bgLayer:getContentSize().height-470-adaH*3)
    self.bgLayer:addChild(self.pointLb)

    local function tipTouch( ... )
      PlayEffect(audioCfg.mouseClick)
      local tabStr={};
      local tabColor ={};
      local td=smallDialog:new()
      local dialog
          tabStr = {"\n",getlocal(tip2,{FormatNumber(tostring(acShengdankuanghuanVoApi:getResourceVate())),1}),"\n",getlocal(tip1,{acShengdankuanghuanVoApi:getGoldVate(),1}),"\n"}
           dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,nil,nil,nil,nil})
      sceneGame:addChild(dialog,self.layerNum+1)
    end
    --说明图标
    local tableItem=GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",tipTouch,3,nil,0)
    tableItem:setAnchorPoint(ccp(0.5,1))
    local tableBtn=CCMenu:createWithItem(tableItem)
    tableBtn:setTouchPriority(-(self.layerNum-1)*20-5)
    tableBtn:setPosition(ccp(self.bgLayer:getContentSize().width-80,self.bgLayer:getContentSize().height-470-adaH*2))
    self.bgLayer:addChild(tableBtn)
  --说明TTF
    local sbLbSize = 27
    if G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() == "de" then
      sbLbSize = 22
    end
    local tableLb = GetTTFLabelWrap(getlocal("shuoming"), sbLbSize,CCSizeMake(110,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    tableLb:setAnchorPoint(ccp(0.5,1))
    -- tableLb:setColor(G_ColorYellowPro)
    tableLb:setPosition(ccp(self.bgLayer:getContentSize().width-80, self.bgLayer:getContentSize().height-540-adaH*2))
    self.bgLayer:addChild(tableLb)

     local function rechange()
      PlayEffect(audioCfg.mouseClick)
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      activityAndNoteDialog:closeAllDialog()
      vipVoApi:showRechargeDialog(self.layerNum+1)
    end

    local rechangeBtn =GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rechange,nil,getlocal("recharge"),25)
    rechangeBtn:setAnchorPoint(ccp(0.5,0.5))
    local rechangeMenu =CCMenu:createWithItem(rechangeBtn)
    rechangeMenu:setPosition(self.bgLayer:getContentSize().width/2+150,70)
    rechangeMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bgLayer:addChild(rechangeMenu)

    local function rewardHandler()
      PlayEffect(audioCfg.mouseClick)
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      activityAndNoteDialog:closeAllDialog()
      mainUI:changeToWorld()

    end

    self.rewardBtn =GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",rewardHandler,nil,getlocal("activity_shengdankuanghuan_CollectMaterial"),25)
    self.rewardBtn:setAnchorPoint(ccp(0.5,0.5))
    local rewardMenu =CCMenu:createWithItem(self.rewardBtn)
    rewardMenu:setPosition(self.bgLayer:getContentSize().width/2-150,70)
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bgLayer:addChild(rewardMenu)
end

function acShengdankuanghuanTab2:refreshTv()
  if self.tv == nil then
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
      adaH = 80
    end
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-630-adaH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(30,110))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
  else
    self.tv:reloadData()
  end
  
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acShengdankuanghuanTab2:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize =CCSizeMake(self.bgLayer:getContentSize().width-60,500)
       return  tmpSize
       
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       cell:autorelease()


        local rewardLabelH = 20
        local rewardBtnH = 0
        local barH = 90
        local totalH  -- 总高度
        local acArsenalPics = acShengdankuanghuanVoApi:getV3ArPic( )
        local acCfg = acShengdankuanghuanVoApi:getRewardCfg()
        if acCfg ~= nil and acCfg ~= nil then
          totalH = barH * SizeOfTable(acCfg)
        else
          totalH = barH
        end

        local totalW = G_VisibleSizeWidth - 20
        local leftW = totalW * 0.4
        local rightW = totalW * 0.7
----    
        local verSion = acShengdankuanghuanVoApi:getVersion()
        if verSion~=nil and verSion ==3 then
            local arsenalPic =CCSprite:createWithSpriteFrameName("arsenalPic.png");
            arsenalPic:setAnchorPoint(ccp(0.5,0))
            arsenalPic:setPosition(totalW * 0.4+130,barH/4)
            arsenalPic:setScaleX(1.1)
            arsenalPic:setScaleY(1.1)
            cell:addChild(arsenalPic,4)
        end

----         
        
        local nowPoint = acShengdankuanghuanVoApi:getNowPoint()


        local per = 0
        local perWidth = 0
        local addContinue = true
        if acCfg ~= nil and acCfg ~= nil then
          local rewardLen = SizeOfTable(acCfg)
          if rewardLen ~= nil and rewardLen > 0 then
              for i=1,rewardLen do

                local h = barH * (rewardLen - i) + rewardBtnH -- 每条奖励信息的y坐标起始位置

                local award=FormatItem(acShengdankuanghuanVoApi:getRewardById(i),true)
                
                
                local addW = (rewardLen-i)*55/2
                if award ~= nil then
                   for k,v in pairs(award) do
                    local icon
                    local iconScale
                    local scale = 0.6
                    icon,iconScale = G_getItemIcon(v,100,true,self.layerNum,nil,self.tv)
                    icon:setScale(scale)
                    icon:ignoreAnchorPointForPosition(false)
                    icon:setAnchorPoint(ccp(0,0.5))
                    if verSion ==3 then
                        if i ==1 then
                          icon:setPosition(ccp(10+(k-1)*60 + leftW + addW - 15,h+barH+5))
                        elseif i ==2 then
                          icon:setPosition(ccp(10+(k-1)*62 + leftW + addW+25 ,h+barH+5))
                        elseif i ==3 then
                          icon:setPosition(ccp(10+(k-1)*62 + leftW + addW-10 ,h+barH+10))
                        elseif i ==4 then
                          icon:setPosition(ccp(10+(k-1)*62 + leftW + addW-25 ,h+barH+10))
                        end
                    else
                        icon:setPosition(ccp(10+(k-1)*60 + leftW + addW ,h+barH))
                    end
                    icon:setIsSallow(false)
                    icon:setTouchPriority(-(self.layerNum-1)*20-3)
                    cell:addChild(icon,10)
                    icon:setTag(k)
                    if i== 1 then
                      G_addRectFlicker(icon,1.5,1.5)
                    end

                    if tostring(v.name)~=getlocal("honor") then
                      local numLabel=GetTTFLabel("x"..v.num,25)
                      numLabel:setAnchorPoint(ccp(1,0))
                      numLabel:setPosition(icon:getContentSize().width-10,0)
                      icon:addChild(numLabel,1)
                      numLabel:setScale(1/scale)
                    end
                  end
                end
                
                local treeSp
                local canReward = acShengdankuanghuanVoApi:checkIfCanRewardById(i)
                if canReward == true then
                  local hadReward = acShengdankuanghuanVoApi:checkIfHadRewardById(i)
                  if hadReward == true then 
                    local offPic
                    if acShengdankuanghuanVoApi:getVersion()~=nil and acShengdankuanghuanVoApi:getVersion() ==3 then
                      offPic = acArsenalPics[i][1]
                    else
                      offPic ="ChristmasTreeParts1.png"
                    end
                    treeSp = CCSprite:createWithSpriteFrameName(offPic) 
                    local hadLabel = GetTTFLabelWrap(getlocal("activity_hadReward"),20,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    hadLabel:setAnchorPoint(ccp(0,0))
                    hadLabel:setPosition(ccp(70,h+barH))
                    cell:addChild(hadLabel,1)
                    hadLabel:setColor(G_ColorGreen)
                  else
                    local offPic
                    if acShengdankuanghuanVoApi:getVersion()~=nil and acShengdankuanghuanVoApi:getVersion() ==3 then
                      offPic = acArsenalPics[i][1]
                    else
                      offPic ="ChristmasTreeParts1.png"
                    end                    
                    treeSp = CCSprite:createWithSpriteFrameName(offPic) 
                    local function rewardHandler()
                      if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end
                        
                        local function treeRewardCallback(fn,data)
                          local ret,sData=base:checkServerData(data)
                          if ret then
                            for k,v in pairs(award) do
                              G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                            end
                            G_showRewardTip(award, true)
                            acShengdankuanghuanVoApi:addHadTreeRewardByID(i)
                            if self.tv then
                              self.tv:reloadData()
                            end
                            acShengdankuanghuanVoApi:updateShow()
                          end
                        end
                        socketHelper:activityShengdankuanghuanTreeReward(i,treeRewardCallback)
                      end
                        
                    end
                     local rewardBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardHandler,nil,getlocal("daily_scene_get"),25)
                      rewardBtn:setScale(0.6)
                      rewardBtn:setAnchorPoint(ccp(0,0))
                      local rewardMenu=CCMenu:createWithItem(rewardBtn)
                      --rewardMenu:setAnchorPoint(ccp(0,0))
                      rewardMenu:setPosition(ccp(70,h+barH))
                      rewardMenu:setTouchPriority(-(self.layerNum-1)*20-3)
                      cell:addChild(rewardMenu)
                    end

                else
                  if verSion==nil or verSion ~=3 then
                    treeSp = CCSprite:createWithSpriteFrameName("ChristmasTreeParts.png") 
                  end
                  
                  local score
                  if acShengdankuanghuanVoApi:getVersion()~=nil and acShengdankuanghuanVoApi:getVersion() ==3 then
                      score ="activity_munitionsSacles_score"
                  else
                      score ="activity_shengdankuanghuan_TreeNeedPoint"
                  end
                  local noLabel = GetTTFLabelWrap(getlocal(score,{acShengdankuanghuanVoApi:getNeedPointById(i)}),20,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                  noLabel:setAnchorPoint(ccp(0,0))
                  noLabel:setPosition(ccp(70,h+barH))
                  cell:addChild(noLabel,9)
                  noLabel:setColor(G_ColorYellow)
                end

          --       尺寸： 1. 224  167
          -- 2 275  208
          -- 3.329  250
          -- 4.394   295
              if treeSp then
                if verSion ~=3 or verSion ==nil then
                    if i==1 then
                      treeSp:setScaleX(1)
                      treeSp:setScaleY(1)
                    elseif i==2 then
                      treeSp:setScaleX(275/224)
                      treeSp:setScaleY(208/167)
                    elseif i==3 then
                      treeSp:setScaleX(329/224)
                      treeSp:setScaleY(250/167)
                    elseif i==4 then
                      treeSp:setScaleX(394/224)
                      treeSp:setScaleY(295/167)
                    end
                    treeSp:setPosition(leftW+130,h+barH/4)
                else
                    if i==1 then
                      treeSp:setScaleX(1.1)
                      treeSp:setScaleY(1.08)
                      treeSp:setPosition(leftW+120,h+barH/4-22)
                    elseif i==2 then
                      treeSp:setScaleX(290/263)
                      treeSp:setScaleY(148/140)
                      treeSp:setPosition(leftW+155,h+barH/4-2)
                    elseif i==3 then
                      treeSp:setScaleX(261/235)
                      treeSp:setScaleY(110/102)
                      treeSp:setPosition(leftW+118,h+barH/4+28)
                    elseif i==4 then
                      treeSp:setScaleX(300/272)
                      treeSp:setScaleY(110/98)
                      treeSp:setPosition(leftW+120,h+barH/4)
                    end
                end                  
                treeSp:setAnchorPoint(ccp(0.5,0))

                cell:addChild(treeSp,rewardLen-i+5)
              end
                --箭头
              local capInSet = CCRect(9, 6, 1, 1);
              local function touchClick(hd,fn,idx)
                   
               end
               local arrowWidth=(totalW - 80)/2
               local arrowSp1 =LuaCCScale9Sprite:createWithSpriteFrameName("heroArrowRight.png",capInSet,touchClick)
               arrowSp1:setContentSize(CCSizeMake(arrowWidth, 16))
               arrowSp1:setAnchorPoint(ccp(0.5,0.5))
               arrowSp1:setPosition(ccp((totalW + 80)/4,h+barH))
               arrowSp1:setIsSallow(false)
               arrowSp1:setTouchPriority(-(self.layerNum-1)*20-2)
               cell:addChild(arrowSp1,3)
               arrowSp1:setRotation(180)

                -- local lineSprite = CCSprite:createWithSpriteFrameName("LineEntity.png")
                -- lineSprite:setScaleX((totalW - 150)/2/lineSprite:getContentSize().width)
                -- lineSprite:setScaleY(3)
                -- lineSprite:setPosition(ccp((totalW + 30)/4,h+barH/2))
                -- cell:addChild(lineSprite,5)

              end
          end

          local programH = barH -- -5
          for j=1,rewardLen do
            local needPoint = acShengdankuanghuanVoApi:getNeedPointById(rewardLen-j+1) -- 当前需要的金币
            if addContinue == true then
              if tonumber(nowPoint) >= tonumber(needPoint) then
                perWidth = perWidth + programH
              else
                local lastPoint
                if (rewardLen-j+1) == rewardLen then
                  lastPoint = 0
                else
                  lastPoint = acShengdankuanghuanVoApi:getNeedPointById(rewardLen-j+2)
                end

                perWidth = perWidth + programH * ((nowPoint - lastPoint) / (needPoint - lastPoint))
                addContinue = false
              end
            end
          end

        end    

        if acShengdankuanghuanVoApi:getVersion() ~=nil and acShengdankuanghuanVoApi:getVersion()~=3 then
            local merryIcon=CCSprite:createWithSpriteFrameName("mainBtnGift.png")
            merryIcon:setAnchorPoint(ccp(0.5,0))
            merryIcon:setPosition(ccp(totalW/2-100,10))
            merryIcon:setScale(1.2)
            cell:addChild(merryIcon,5)
            local merryIcon1=CCSprite:createWithSpriteFrameName("mainBtnGift.png")
            merryIcon1:setAnchorPoint(ccp(0.5,0))
            merryIcon1:setPosition(ccp(totalW/2-100,50))
            merryIcon1:setScale(1.2)
            cell:addChild(merryIcon1)
            local merryIcon2=CCSprite:createWithSpriteFrameName("mainBtnGift.png")
            merryIcon2:setAnchorPoint(ccp(0.5,0))
            merryIcon2:setPosition(ccp(totalW-80,10))
            merryIcon2:setScale(1.2)
            cell:addChild(merryIcon2,5)
            local merryIcon3=CCSprite:createWithSpriteFrameName("mainBtnGift.png")
            merryIcon3:setAnchorPoint(ccp(0.5,0))
            merryIcon3:setPosition(ccp(totalW-80,50))
            merryIcon3:setScale(1.2)
            cell:addChild(merryIcon3)
        end

        local barWidth = totalH + rewardBtnH -- - SizeOfTable(acCfg)*5
        print(perWidth,barWidth)
        -- local function click(hd,fn,idx)
        -- end
        -- local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("HelpBgBottom.png", CCRect(20,20,1,1),click)
        -- barSprie:setContentSize(CCSizeMake(barWidth, 50))
        -- barSprie:setRotation(90)
        -- barSprie:setPosition(ccp(50,barWidth/2))
        -- cell:addChild(barSprie,1)

        AddProgramTimer(cell,ccp(40,barWidth/2),111,12,nil,"VipIconYellowBarBg.png","VipIconYellowBar.png",131,1,1)
        local per = tonumber(perWidth)/tonumber(barWidth) * 100
        local timerSpriteLv = cell:getChildByTag(111)
        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
        timerSpriteLv:setPercentage(per)
        timerSpriteLv:setRotation(-90)
        timerSpriteLv:setScaleX(barWidth/timerSpriteLv:getContentSize().width)
        local bg = cell:getChildByTag(131)
        -- bg:setVisible(false)
        bg:setRotation(-90)
        bg:setScaleX(barWidth/bg:getContentSize().width)

       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end
function acShengdankuanghuanTab2:updateNowPoint()
  if self and self.pointLb then
    local nowScore
    if acShengdankuanghuanVoApi:getVersion()~=nil and acShengdankuanghuanVoApi:getVersion() ==3 then
        nowScore="activity_munitionsSacles_scoreNow"
    else
        nowScore="activity_shengdankuanghuan_TreeNowPoint"
    end
    self.pointLb:setString(getlocal(nowScore,{acShengdankuanghuanVoApi:getNowPoint()}))
  end
end

function acShengdankuanghuanTab2:update()
  local function CallBack(fn,data)
    local ret,sData=base:checkServerData(data)
    if ret then
      if sData and sData.data.shengdankuanghuan then
        acShengdankuanghuanVoApi:setNowPoint(sData.data.shengdankuanghuan.num)
        self:updateNowPoint()
        self:refreshTv()
        acShengdankuanghuanVoApi:updateShow()
      end
    end
  end
  socketHelper:activityShengdankuanghuanTreePoint(CallBack)
end

function acShengdankuanghuanTab2:dispose( ... )

end