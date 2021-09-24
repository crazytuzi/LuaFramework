upgradeRequire={}
function upgradeRequire:new()
    local nc={
            container,
            require4={}, --4个需求
            pp4={}, --4个对号
            have4={},  --4个当前拥有
            id,
            type,
            isCommanderCenter,
          }
    setmetatable(nc,self)
    self.__index=self
    return nc
end
--container:父容器 category:build,skill等 id:ID type:type
function upgradeRequire:create(container,category,id,type)
    local requireResult=false
    self.id=id
    self.type=type
    self.container=container
    if category=="build" then
          local typeLb=GetTTFLabel(getlocal("resourceType"),20)
          typeLb:setAnchorPoint(ccp(0.5,1))
          typeLb:setPosition(ccp(150,container:getContentSize().height-30))
          container:addChild(typeLb)
          
          local resourceLb=GetTTFLabel(getlocal("resourceRequire"),20)
          resourceLb:setAnchorPoint(ccp(0.5,1))
          resourceLb:setPosition(ccp(300,container:getContentSize().height-30))
          container:addChild(resourceLb)
          
          local haveLb=GetTTFLabelWrap(getlocal("resourceOwned"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
          haveLb:setAnchorPoint(ccp(0.5,1))
          haveLb:setPosition(ccp(450,container:getContentSize().height-30))
          container:addChild(haveLb)
          --四个名称
          local bvo=buildingVoApi:getBuildiingVoByBId(self.id)
          self.isCommanderCenter=0
          if bvo.type==-1 then
             if self.type==7 then
                self.isCommanderCenter=1
             end
          else
             if bvo.type==7 then
                self.isCommanderCenter=1
             end
          end

          local commandCenterLb=GetTTFLabel(getlocal("commandCenter"),20)
          commandCenterLb:setAnchorPoint(ccp(0.5,0.5))
          commandCenterLb:setPosition(ccp(150,container:getContentSize().height-100))
          container:addChild(commandCenterLb)
          if self.isCommanderCenter==1 then
             commandCenterLb:setVisible(false)
          end
          
          local metalLb=GetTTFLabelWrap(getlocal("metal"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
          metalLb:setAnchorPoint(ccp(0.5,0.5))
          metalLb:setPosition(ccp(150,container:getContentSize().height-170+70*self.isCommanderCenter))
          container:addChild(metalLb)
          
          local oilLb=GetTTFLabelWrap(getlocal("oil"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
          oilLb:setAnchorPoint(ccp(0.5,0.5))
          oilLb:setPosition(ccp(150,container:getContentSize().height-240+70*self.isCommanderCenter))
          container:addChild(oilLb)
          
          local siliconLb=GetTTFLabelWrap(getlocal("silicon"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
          siliconLb:setAnchorPoint(ccp(0.5,0.5))
          siliconLb:setPosition(ccp(150,container:getContentSize().height-310+70*self.isCommanderCenter))
          container:addChild(siliconLb)
          
          --三个图片
          local metalSp=CCSprite:createWithSpriteFrameName("resourse_normal_metal.png")
          metalSp:setAnchorPoint(ccp(0.5,0.5))
          metalSp:setPosition(ccp(40,container:getContentSize().height-170+70*self.isCommanderCenter))
          metalSp:setScale(0.5)
          container:addChild(metalSp)
          
          local oilSp=CCSprite:createWithSpriteFrameName("resourse_normal_oil.png")
          oilSp:setAnchorPoint(ccp(0.5,0.5))
          oilSp:setScale(0.5)
          oilSp:setPosition(ccp(40,container:getContentSize().height-240+70*self.isCommanderCenter))
          container:addChild(oilSp)
          
          local siliconSp=CCSprite:createWithSpriteFrameName("resourse_normal_silicon.png")
          siliconSp:setAnchorPoint(ccp(0.5,0.5))
          siliconSp:setScale(0.5)
          siliconSp:setPosition(ccp(40,container:getContentSize().height-310+70*self.isCommanderCenter))
          container:addChild(siliconSp)
          
          --四个需求
          local reTb=buildingVoApi:getUpgradeBuildRequire(id,type)
          
          local commandCenterValueLb=GetTTFLabel(getlocal("uper_level").." "..tostring(reTb[1]),20)
          commandCenterValueLb:setAnchorPoint(ccp(0.5,0.5))
          commandCenterValueLb:setPosition(ccp(150*2,container:getContentSize().height-100))
          container:addChild(commandCenterValueLb)
          self.require4[1]={commandCenterValueLb}
          if self.isCommanderCenter==1 then
            commandCenterValueLb:setVisible(false)
          end
          local metalValueLb=GetTTFLabel(FormatNumber(reTb[2]),20)
          metalValueLb:setAnchorPoint(ccp(0.5,0.5))
          metalValueLb:setPosition(ccp(150*2,container:getContentSize().height-170+70*self.isCommanderCenter))
          container:addChild(metalValueLb)
          self.require4[2]={metalValueLb}
          local oilValueLb=GetTTFLabel(FormatNumber(reTb[3]),20)
          oilValueLb:setAnchorPoint(ccp(0.5,0.5))
          oilValueLb:setPosition(ccp(150*2,container:getContentSize().height-240+70*self.isCommanderCenter))
          container:addChild(oilValueLb)
          self.require4[3]={oilValueLb}
          local siliconValueLb=GetTTFLabel(FormatNumber(reTb[4]),20)
          siliconValueLb:setAnchorPoint(ccp(0.5,0.5))
          siliconValueLb:setPosition(ccp(150*2,container:getContentSize().height-310+70*self.isCommanderCenter))
          container:addChild(siliconValueLb)
          self.require4[4]={siliconValueLb}

          self:updateAcDis()

          --四个对号 衩号 四个当前拥有
          local result,results,have=buildingVoApi:checkUpgradeRequire(id,type)
          requireResult=result
          for k=1,4 do

              local p1Sp
              if results[k]==true then
                 p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
                 if self.container:getChildByTag(k+10) then
                    self.container:getChildByTag(k+10):removeFromParentAndCleanup(true)
                 end
              else
                 p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")

                 if k~=1 then
                   local function callBack()
                      smallDialog:showBuyResDialog(k-1,7)
                   end
                   local icon=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",callBack)
                   icon:setTag(k+10)
                   icon:setTouchPriority(-(6-1)*20-1)
                   icon:setPosition(ccp(510,self.container:getContentSize().height-100-(k-1)*70+70*self.isCommanderCenter))
                   self.container:addChild(icon)

                   local iconTouch=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",callBack)
                   iconTouch:setScale(1.2)                   
                   iconTouch:setTouchPriority(-(6-1)*20-2)
                   iconTouch:setPosition(getCenterPoint(icon))
                   icon:addChild(iconTouch)
                   --iconTouch:setVisible(false)
                 end

              end
              p1Sp:setAnchorPoint(ccp(0.5,0.5))
              
              if k==1 and self.isCommanderCenter==1 then
                   p1Sp:setVisible(false)
              end
              
              p1Sp:setPosition(ccp(400,container:getContentSize().height-100-(k-1)*70+70*self.isCommanderCenter))
              
              container:addChild(p1Sp)
              self.pp4[k]={results[k],p1Sp}
              local haveLb
              if k==1 then
                 haveLb=GetTTFLabel(getlocal("uper_level")..tostring(have[k]),20)
                 if self.isCommanderCenter==1 then
                     haveLb:setVisible(false)
                 end
              else
                 haveLb=GetTTFLabel(FormatNumber(have[k]),20)
              end
              haveLb:setAnchorPoint(ccp(0.5,0.5))
              haveLb:setPosition(ccp(450,container:getContentSize().height-100-(k-1)*70+70*self.isCommanderCenter))
              container:addChild(haveLb)
              self.have4[k]={haveLb:getString(),haveLb}
          end
    elseif category=="tech" then
          local typeLb=GetTTFLabel(getlocal("resourceType"),20)
          typeLb:setAnchorPoint(ccp(0.5,1))
          typeLb:setPosition(ccp(150,container:getContentSize().height-30))
          container:addChild(typeLb)
          
          local resourceLb=GetTTFLabel(getlocal("resourceRequire"),20)
          resourceLb:setAnchorPoint(ccp(0.5,1))
          resourceLb:setPosition(ccp(300,container:getContentSize().height-30))
          container:addChild(resourceLb)
          
          local haveLb=GetTTFLabelWrap(getlocal("resourceOwned"),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
          haveLb:setAnchorPoint(ccp(0.5,1))
          haveLb:setPosition(ccp(450,container:getContentSize().height-30))
          container:addChild(haveLb)
          --五个名称
          
          local require=technologyVoApi:getUpgradeRequire(id)

          local techCenterLb=GetTTFLabel(getlocal("technologyBuilding"),20)
          techCenterLb:setAnchorPoint(ccp(0.5,0.5))
          techCenterLb:setPosition(ccp(150,container:getContentSize().height-100))
          container:addChild(techCenterLb)
          
          local honorRank=GetTTFLabel(getlocal("honor"),20)
          honorRank:setAnchorPoint(ccp(0.5,0.5))
          honorRank:setPosition(ccp(150,container:getContentSize().height-170))
          container:addChild(honorRank)
          

          for kk=3,SizeOfTable(require) do
              local resLb=GetTTFLabelWrap(getlocal(require[kk][1]),20,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
              resLb:setAnchorPoint(ccp(0.5,0.5))
              resLb:setPosition(ccp(150,container:getContentSize().height-170-70*(kk-2)))
              container:addChild(resLb)
          end


          --四个图片
          
          for kk=2,SizeOfTable(require) do
              local icoName
              if kk==2 then
                 icoName="Icon_prestige.png"
              else
                 icoName=require[kk][1]
              end
              if icoName=="money" then
                icoName="gold"
              end
              local icoSp;
              if kk==2 then
                icoSp=CCSprite:createWithSpriteFrameName(icoName)
              else
                icoSp=CCSprite:createWithSpriteFrameName("resourse_normal_"..icoName..".png")
              end
              --local icoSp=CCSprite:createWithSpriteFrameName("resourse_normal_"..icoName..".png")
              icoSp:setPosition(ccp(40,container:getContentSize().height-100-70*(kk-1)))
              icoSp:setScale(0.5)
              container:addChild(icoSp)
          end
          
          --五个需求
          for kk=1,SizeOfTable(require) do
             local rLb
             if kk<=2 then
                rLb=GetTTFLabel(getlocal("uper_level").." "..tostring(require[kk]),20)
             else 
                rLb=GetTTFLabel(FormatNumber(require[kk][2]),20)
             end
             rLb:setAnchorPoint(ccp(0.5,0.5))
             rLb:setPosition(ccp(150*2,container:getContentSize().height-100-70*(kk-1)))
             self.require4[kk]={rLb}
             container:addChild(rLb)
          end
          
          local lineSprite2 = CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSprite2:setAnchorPoint(ccp(0.5,0.5))
            lineSprite2:setPosition(ccp(container:getContentSize().width/2,135))
            container:addChild(lineSprite2,1)
            lineSprite2:setScaleX(0.8)
            
          local tecSp= CCSprite:createWithSpriteFrameName(techCfg[id].icon)
          tecSp:setScale(0.5)
          tecSp:setAnchorPoint(ccp(0.5,0.5))
          tecSp:setPosition(ccp(40,100))
          container:addChild(tecSp,40)


          local descLb=GetTTFLabelWrap(getlocal(techCfg[id].description),20,CCSize(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,0.5))
            descLb:setPosition(ccp(tecSp:getPositionX()+tecSp:getContentSize().width/2,tecSp:getPositionY()))
            container:addChild(descLb)

          --五个对号 衩号 五个当前拥有
          local result,results,have=technologyVoApi:checkUpgradeRequire(id)
          requireResult=result
          for k=1,SizeOfTable(require) do

              local p1Sp
              if results[k]==true then
                 p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
                 
              else
                 p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")


              end
              p1Sp:setAnchorPoint(ccp(0.5,0.5))
              
              if k==1 and self.isCommanderCenter==1 then
                   p1Sp:setVisible(false)
              end
              
              p1Sp:setPosition(ccp(400,container:getContentSize().height-100-(k-1)*70))
              
              container:addChild(p1Sp)
              self.pp4[k]={results[k],p1Sp}
              local haveLb
              if k==1 or k==2 then
                 haveLb=GetTTFLabel(getlocal("uper_level").." "..tostring(have[k]),20)
              else
                 haveLb=GetTTFLabel(FormatNumber(have[k]),20)
              end
              haveLb:setAnchorPoint(ccp(0.5,0.5))
              haveLb:setPosition(ccp(450,container:getContentSize().height-100-(k-1)*70))
              container:addChild(haveLb)
              self.have4[k]={haveLb:getString(),haveLb}
              

          end

          
    end
    return requireResult  --满足条件返回true,否则返回false
end

function upgradeRequire:updateAcDis()
  if self.id ~= 1 then -- 只有指挥中心才走
    do
      return
    end
  end

  local canDis = false
  local desVate = 1
  local levelVo = activityVoApi:getActivityVo("leveling")
  if levelVo ~= nil and activityVoApi:isStart(levelVo) == true then
    canDis = true
    desVate = acLevelingVoApi:getDesVate()
  end
  local level2Vo = activityVoApi:getActivityVo("leveling2")
  if level2Vo ~= nil and activityVoApi:isStart(level2Vo) == true then
    if acLeveling2VoApi:checkIfDesVate() == true then
      canDis = true
      desVate = acLeveling2VoApi:getDesVate()
    end
  end
  if canDis == true then
    local reTb=buildingVoApi:getUpgradeBuildRequire(self.id,self.type)
    local lb = nil
    for i=2,4 do
      lb = self.require4[i][1]
      if lb ~= nil then
        if self.require4[i][2] == nil or self.require4[i][3] == nil then
          local line = CCSprite:createWithSpriteFrameName("redline.jpg")
          line:setScaleX((lb:getContentSize().width  + 30) / 4)
          line:setPosition(getCenterPoint(lb))
          lb:addChild(line)
          self.require4[i][2] = line

          local valueLb=GetTTFLabel(FormatNumber(math.ceil(reTb[i] * desVate)),20)
          valueLb:setAnchorPoint(ccp(0.5,0.5))
          valueLb:setPosition(ccp(lb:getContentSize().width/2,-lb:getContentSize().height/2))
          valueLb:setColor(G_ColorGreen)
          lb:addChild(valueLb)
          self.require4[i][3] = valueLb
        else
        self.require4[i][2]:setScaleX((lb:getContentSize().width  + 30) / 4)
        self.require4[i][3]:setString(FormatNumber(math.ceil(reTb[i] * desVate)))
        end
      end
    end
  elseif self ~= nil then-- 活动结束
    for i=2,4 do
      if self.require4[i][2] ~= nil then
        self.require4[i][2]:removeFromParentAndCleanup(true)
        self.require4[i][2] = nil
      end
      if self.require4[i][3] ~= nil then
        self.require4[i][3]:removeFromParentAndCleanup(true)
        self.require4[i][3] = nil
      end
    end
  end
end

function upgradeRequire:tick()
    --四个需求
    local reTb=buildingVoApi:getUpgradeBuildRequire(self.id,self.type)

    self.require4[1][1]:setString(getlocal("uper_level").." "..tostring(reTb[1]))
    self.require4[2][1]:setString(FormatNumber(reTb[2]))
    self.require4[3][1]:setString(FormatNumber(reTb[3]))
    self.require4[4][1]:setString(FormatNumber(reTb[4]))

    self:updateAcDis()
    
    local result,results,have=buildingVoApi:checkUpgradeRequire(self.id,self.type)
    for k,v in pairs(self.pp4) do
         if results[k]~=self.pp4[k][1] then
              local p1Sp
              if results[k]==true then
                 p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
                 if self.container:getChildByTag(k+10) then
                    self.container:getChildByTag(k+10):removeFromParentAndCleanup(true)
                 end
                 
              else
                 p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
                 if k~=1 then
                   local function callBack()
                      smallDialog:showBuyResDialog(k-1,7)
                   end
                   local icon=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",callBack)
                   icon:setTag(k+10)
                   icon:setTouchPriority(-(6-1)*20-1)
                   icon:setPosition(ccp(510,self.container:getContentSize().height-100-(k-1)*70+70*self.isCommanderCenter))
                   self.container:addChild(icon)

                   local iconTouch=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",callBack)
                   iconTouch:setScale(1.2)                   
                   iconTouch:setTouchPriority(-(6-1)*20-2)
                   iconTouch:setPosition(getCenterPoint(icon))
                   icon:addChild(iconTouch)
                   iconTouch:setOpacity(0)

                 end
              end
              if k==1 and self.isCommanderCenter==1 then
                p1Sp:setVisible(false)
              end
              p1Sp:setAnchorPoint(ccp(0.5,0.5))
              
              p1Sp:setPosition(ccp(400,self.container:getContentSize().height-100-(k-1)*70+70*self.isCommanderCenter))
              
              self.container:addChild(p1Sp)
              self.pp4[k][2]:removeFromParentAndCleanup(true)
              self.pp4[k]=nil
              self.pp4[k]={results[k],p1Sp}
         end
    end
    
    for k,v in pairs(self.have4) do
        local lb=self.have4[k][2]
        if k==1 then
            lb:setString(getlocal("uper_level")..tostring(have[k]))
        else
            lb:setString(FormatNumber(have[k]))
        end
    end
    
    

    return result  --满足条件返回true,否则返回false
end

function upgradeRequire:dispose() --释放方法

    self.container=nil
    for k,v in pairs(self.pp4) do
         k=nil
         v=nil
    end
    self.pp4=nil
        for k,v in pairs(self.have4) do
         k=nil
         v=nil
    end
    self.have4=nil
end
