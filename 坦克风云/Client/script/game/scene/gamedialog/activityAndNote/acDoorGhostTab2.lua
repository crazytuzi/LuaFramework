acDoorGhostTab2={

}

function acDoorGhostTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    return nc
end

function acDoorGhostTab2:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum

    self:initTableView()
    return self.bgLayer
end



function acDoorGhostTab2:initTableView()

  local totalGhost = acDoorGhostVoApi:getTotalGhost()
  self.ghostNumLb =  GetTTFLabelWrap(getlocal("activity_doorGhost_hadGhostNum",{totalGhost}),30,CCSizeMake(self.bgLayer:getContentSize().width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  self.ghostNumLb:setAnchorPoint(ccp(0,0.5))
  self.ghostNumLb:setPosition(ccp(40,self.bgLayer:getContentSize().height-200))
  self.bgLayer:addChild(self.ghostNumLb)
  self.ghostNumLb:setColor(G_ColorGreen)

  local function callBack(...)
     return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSizeHeight-270),nil)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setPosition(ccp(10,40))
  self.bgLayer:addChild(self.tv)
  self.tv:setMaxDisToBottomOrTop(120)
end

function acDoorGhostTab2:updateView()
  if self.ghostNumLb then
    self.ghostNumLb:setString(getlocal("activity_doorGhost_hadGhostNum",{acDoorGhostVoApi:getTotalGhost()}))
  end
  if self.tv then
    self.tv:reloadData()
  end

end

function acDoorGhostTab2:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    local acCfg = acDoorGhostVoApi:getAcGhostRewardCfg()
    if acCfg ~= nil then
      return  CCSizeMake(G_VisibleSizeWidth - 20,120 * SizeOfTable(acCfg) + 20)
    end
    return  CCSizeMake(G_VisibleSizeWidth - 20,120)

  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    
    local rewardLabelH = 20
    local rewardBtnH = 0
    local barH = 120

    local totalH  -- 总高度

    local acCfg = acDoorGhostVoApi:getAcGhostRewardCfg()
    if acCfg ~= nil then
      totalH = barH * SizeOfTable(acCfg)
    else
      totalH = barH
    end

    local totalW = G_VisibleSizeWidth - 20
    local leftW = totalW * 0.3
    local rightW = totalW * 0.7
     
    
    local totalGhost = acDoorGhostVoApi:getTotalGhost()

    local per = 0
    local perWidth = 0
    local addContinue = true
    if acCfg ~= nil  then
      local rewardLen = SizeOfTable(acCfg)
      if rewardLen ~= nil and rewardLen > 0 then
          for i=1,rewardLen do

            local h = barH * (rewardLen - i) + rewardBtnH -- 每条奖励信息的y坐标起始位置

            local rewardCfg = acDoorGhostVoApi:getRewardById(rewardLen - i + 1)

            local award=FormatItem(rewardCfg.reward,true)
            
            if award ~= nil then
               for k,v in pairs(award) do
                local icon, iconScale = G_getItemIcon(v, 100, true, self.layerNum)

                icon:ignoreAnchorPointForPosition(false)
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(ccp(10+(k-1)*110 + leftW-50 ,h+barH/2))
                icon:setIsSallow(false)
                icon:setTouchPriority(-(self.layerNum-1)*20-2)
                cell:addChild(icon,1)
                icon:setTag(k)

                if tostring(v.name)~=getlocal("honor") then
                  local numLabel=GetTTFLabel("x"..v.num,25)
                  numLabel:setAnchorPoint(ccp(1,0))
                  numLabel:setPosition(icon:getContentSize().width-10,0)
                  icon:addChild(numLabel,1)
                  numLabel:setScaleX(1/iconScale)
                  numLabel:setScaleY(1/iconScale)
                end
              end
            end

            local function rewardHandler()

              if G_checkClickEnable()==false then
                do
                    return
                end
              end

              if newGuidMgr:isNewGuiding()==true then --新手引导
                  do
                    return
                  end
              end
              PlayEffect(audioCfg.mouseClick)
              if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then

                local nowHadReawrd = acDoorGhostVoApi:getHadRewardId()
                if ((rewardLen - i+1)-nowHadReawrd)>1 then
                  smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("growingPlanWarning"),nil,self.layerNum+1)
                  do return end
                end

                  local function getRewardHandler(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret == true then
                      acDoorGhostVoApi:afterGetReward(i)
                      for k,v in pairs(award) do
                        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                      end
                      G_showRewardTip(award)
                      if self.tv then
                        local recordPoint = self.tv:getRecordPoint()
                        self.tv:reloadData()
                        self.tv:recoverToRecordPoint(recordPoint)
                      end
                    end
                  end
                  socketHelper:activityDoorGhostReward(getRewardHandler)
               end

            end

            local rewardBtn = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",rewardHandler,nil,getlocal("daily_scene_get"),25)
            rewardBtn:setScale(0.8)
            local rewardMenu=CCMenu:createWithItem(rewardBtn)
        		rewardMenu:setAnchorPoint(ccp(0.5,0.5))
        		rewardMenu:setPosition(ccp(totalW - 110,h+barH/2))
        		rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        		cell:addChild(rewardMenu)

            local canReward = acDoorGhostVoApi:checkIfCanRewardById(rewardLen - i + 1)
            if canReward == true then
              local hadReward = acDoorGhostVoApi:checkIfHadRewardById(rewardLen - i + 1)
              if hadReward == true then 
              	rewardMenu:setVisible(false)
                local rightIcon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
                rightIcon:setAnchorPoint(ccp(1,0.5))
                rightIcon:setPosition(ccp(totalW - 50,h+barH/2))
                cell:addChild(rightIcon,1)
              else
              	rewardMenu:setVisible(true)
				        rewardBtn:setEnabled(true)
               end

            else
            	rewardBtn:setEnabled(false)
            end

            local needGhost = acDoorGhostVoApi:getNeedGhostById(rewardLen - i + 1)
      			local needGhostlb=GetTTFLabelWrap(getlocal("activity_doorGhost_ghostNum",{needGhost}),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
      			needGhostlb:setColor(G_ColorGreen)
            needGhostlb:setAnchorPoint(ccp(0.5,0.5))
            needGhostlb:setPosition(ccp(leftW+160,h+barH/2))
            cell:addChild(needGhostlb,2)
            

            local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSprite:setScaleX((totalW + 30)/lineSprite:getContentSize().width)
            lineSprite:setPosition(ccp((totalW + 30)/2 + 30,h + barH))
            cell:addChild(lineSprite,5)
            if i == rewardLen then
              local lineSprite2 = CCSprite:createWithSpriteFrameName("LineCross.png")
              lineSprite2:setScaleX((totalW + 30)/lineSprite:getContentSize().width)
              lineSprite2:setPosition(ccp((totalW + 30)/2 + 30,h))
              cell:addChild(lineSprite2,5)
            end

         end
      end

      for j=1,rewardLen do
        local ghost = acDoorGhostVoApi:getNeedGhostById(j) -- 当前需要的金币
        if addContinue == true then
          if tonumber(totalGhost) >= tonumber(ghost) then
            perWidth = perWidth + barH
          else
            local lastghost
            if j == 1 then
              lastghost = 0
            else
              lastghost = acDoorGhostVoApi:getNeedGhostById(j - 1)
            end
            perWidth = perWidth + barH * ((totalGhost - lastghost) / (ghost - lastghost))
            addContinue = false
          end
        end
      end

    end    

    local barWidth = totalH + rewardBtnH
    local function click(hd,fn,idx)
    end
    local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("HelpBgBottom.png", CCRect(20,20,1,1),click)
    barSprie:setContentSize(CCSizeMake(barWidth, 50))
    barSprie:setRotation(90)
    barSprie:setPosition(ccp(50,barWidth/2))
    cell:addChild(barSprie,1)

    AddProgramTimer(cell,ccp(50,barWidth/2),11,12,nil,"AllBarBg.png","AllXpBar.png",13,1,1)
    local per = tonumber(perWidth)/tonumber(barWidth) * 100
    local timerSpriteLv = cell:getChildByTag(11)
    timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
    timerSpriteLv:setPercentage(per)
    timerSpriteLv:setRotation(-90)
    timerSpriteLv:setScaleX(barWidth/timerSpriteLv:getContentSize().width)
    local bg = cell:getChildByTag(13)
    bg:setVisible(false)
    -- bg:setRotation(-90)
    -- bg:setScaleX(barWidth/bg:getContentSize().width)


    local verticalLine = CCSprite:createWithSpriteFrameName("LineCross.png")
    verticalLine:setScaleX(totalH/verticalLine:getContentSize().width)
    verticalLine:setRotation(90)
    verticalLine:setPosition(ccp(110 ,totalH/2 + rewardBtnH))
    cell:addChild(verticalLine,2)


    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end


function acDoorGhostTab2:tick()

end

function acDoorGhostTab2:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    self = nil
end
