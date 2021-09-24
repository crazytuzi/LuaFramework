allianceDonate={}
function allianceDonate:new()
    local nc={
            container,
            require5={}, --5个需求
            pp5={}, --5个对号
            have5={},  --5个当前拥有
            donate5={},--
            exp5={},--
            sid,
            isCommanderCenter,
            layerNum,
            tableView,
          }
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function allianceDonate:create(container,idx,layerNum,tableView)
    self.layerNum=layerNum
    self.sid=idx
    self.container=container
    self.tableView=tableView
    local capInSet = CCRect(60, 20, 1, 1);
    local function cellClick(hd,fn,idx)
    end
    local yy=container:getContentSize().height-24
    local reYY=15
    local yy1=container:getContentSize().height-100+reYY
    local yy2=container:getContentSize().height-170+reYY+5
    local yy3=container:getContentSize().height-240+reYY+10
    local yy4=container:getContentSize().height-310+reYY+15
    local yy5=container:getContentSize().height-380+reYY+20
    local yy6=container:getContentSize().height-30+reYY

    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzNameBg.png",CCRect(4, 4, 1, 1),function () end)
    backSprie:setContentSize(CCSizeMake(container:getContentSize().width, 40))
    backSprie:ignoreAnchorPointForPosition(false);
    backSprie:setAnchorPoint(ccp(0.5,1));
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:setPosition(ccp(container:getContentSize().width/2,container:getContentSize().height));
    container:addChild(backSprie)
    self.everyHeight = 65


    for i=1,5,1 do
        if i%2 == 0 then
            local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function ()end)
            grayBgSp:setContentSize(CCSizeMake(container:getContentSize().width-10,self.everyHeight))
            grayBgSp:setAnchorPoint(ccp(0.5,0.5))
            grayBgSp:setPosition(ccp(container:getContentSize().width/2,yy6-self.everyHeight *i))
            container:addChild(grayBgSp) 
        end
    end
    

    local lbX1=40
    local lbX2=120
    local lbX3=220
    local lbX4=320
    local lbX5=400
    local lbX6=520
    
    local titleColor=G_ColorYellowPro2

    local typeLb=GetTTFLabel(getlocal("resourceType"),20,true)
    typeLb:setAnchorPoint(ccp(0.5,0.5))
    typeLb:setPosition(ccp(lbX1,yy))
    container:addChild(typeLb)
    typeLb:setColor(titleColor)

    local resourceLb=GetTTFLabelWrap(getlocal("resourceRequire"),20,CCSizeMake(80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    resourceLb:setAnchorPoint(ccp(0.5,0.5))
    resourceLb:setPosition(ccp(lbX2,yy))
    container:addChild(resourceLb)
    resourceLb:setColor(titleColor)
  
    local haveLb=GetTTFLabelWrap(getlocal("resourceOwned"),20,CCSizeMake(85,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    haveLb:setAnchorPoint(ccp(0.5,0.5))
    haveLb:setPosition(ccp(lbX3,yy))
    container:addChild(haveLb)
    haveLb:setColor(titleColor)
    
    local rGoldSp=CCSprite:createWithSpriteFrameName("resourse_normal_gold.png")
    rGoldSp:setAnchorPoint(ccp(0.5,0.5))
    rGoldSp:setPosition(ccp(lbX1,yy1))
    rGoldSp:setScale(0.5)
    container:addChild(rGoldSp)
    
    local r1Sp=CCSprite:createWithSpriteFrameName("resourse_normal_metal.png")
    r1Sp:setAnchorPoint(ccp(0.5,0.5))
    r1Sp:setPosition(ccp(lbX1,yy2))
    r1Sp:setScale(0.5)
    container:addChild(r1Sp)
    
    
    local r2Sp=CCSprite:createWithSpriteFrameName("resourse_normal_oil.png")
    r2Sp:setAnchorPoint(ccp(0.5,0.5))
    r2Sp:setPosition(ccp(lbX1,yy3))
    r2Sp:setScale(0.5)
    container:addChild(r2Sp)
    
    local r3Sp=CCSprite:createWithSpriteFrameName("resourse_normal_silicon.png")
    r3Sp:setAnchorPoint(ccp(0.5,0.5))
    r3Sp:setPosition(ccp(lbX1,yy4))
    r3Sp:setScale(0.5)
    container:addChild(r3Sp)
    
    local r4Sp=CCSprite:createWithSpriteFrameName("resourse_normal_uranium.png")
    r4Sp:setAnchorPoint(ccp(0.5,0.5))
    r4Sp:setPosition(ccp(lbX1,yy5))
    r4Sp:setScale(0.5)
    container:addChild(r4Sp)


    --需要
    for i=1,5,1 do
        local count=allianceVoApi:getDonateCount(i)+1
        if count>allianceVoApi:getDonateMaxNum() then
            count=allianceVoApi:getDonateMaxNum()
        end
        local needR1Lb=GetTTFLabel(FormatNumber(playerCfg["allianceDonateResources"][count]),20,true)
        needR1Lb:setAnchorPoint(ccp(0.5,0.5))
        needR1Lb:setPosition(ccp(lbX2,yy6-self.everyHeight *i))
        container:addChild(needR1Lb)
        self.require5[i]=needR1Lb
    end
    --经验
    for i=1,5,1 do
        local count=allianceVoApi:getDonateCount(i)+1
        if count>allianceVoApi:getDonateMaxNum() then
            count=allianceVoApi:getDonateMaxNum()
        end
        local addStr = "+"..playerCfg["allianceDonate"][count][1]
        if idx==SizeOfTable(allianceSkillCfg) then
            addStr="+0"
        end
        local needR1Lb=GetTTFLabel(addStr,20,true)
        needR1Lb:setAnchorPoint(ccp(0.5,0.5))
        needR1Lb:setPosition(ccp(lbX4,yy6-self.everyHeight *i))
        container:addChild(needR1Lb)
        self.exp5[i]=needR1Lb
    end
    --贡献
    for i=1,5,1 do
        local count=allianceVoApi:getDonateCount(i)+1
        if count>allianceVoApi:getDonateMaxNum() then
            count=allianceVoApi:getDonateMaxNum()
        end
        local needR1Lb=GetTTFLabel("+"..playerCfg["allianceDonate"][count][2],20,true)
        needR1Lb:setAnchorPoint(ccp(0.5,0.5))
        needR1Lb:setPosition(ccp(lbX5,yy6-self.everyHeight *i))
        container:addChild(needR1Lb)
        self.donate5[i]=needR1Lb
    end
    
    local xxxadd=20

    local haveRGoldLb=GetTTFLabel(FormatNumber(playerVoApi:getGold()),20,true)
    haveRGoldLb:setAnchorPoint(ccp(0.5,0.5))
    haveRGoldLb:setPosition(ccp(lbX3+xxxadd,yy1+5))
    container:addChild(haveRGoldLb)

    local haveR1Lb=GetTTFLabel(FormatNumber(playerVoApi:getR1()),20,true)
    haveR1Lb:setAnchorPoint(ccp(0.5,0.5))
    haveR1Lb:setPosition(ccp(lbX3+xxxadd,yy2+5))
    container:addChild(haveR1Lb)
    
    local haveR2Lb=GetTTFLabel(FormatNumber(playerVoApi:getR2()),20,true)
    haveR2Lb:setAnchorPoint(ccp(0.5,0.5))
    haveR2Lb:setPosition(ccp(lbX3+xxxadd,yy3+5))
    container:addChild(haveR2Lb)
    
    local haveR3Lb=GetTTFLabel(FormatNumber(playerVoApi:getR3()),20,true)
    haveR3Lb:setAnchorPoint(ccp(0.5,0.5))
    haveR3Lb:setPosition(ccp(lbX3+xxxadd,yy4+5))
    container:addChild(haveR3Lb)
    
    local haveR4Lb=GetTTFLabel(FormatNumber(playerVoApi:getR4()),20,true)
    haveR4Lb:setAnchorPoint(ccp(0.5,0.5))
    haveR4Lb:setPosition(ccp(lbX3+xxxadd,yy5+5))
    container:addChild(haveR4Lb)
    self.have5[1]=haveRGoldLb
    self.have5[2]=haveR1Lb
    self.have5[3]=haveR2Lb
    self.have5[4]=haveR3Lb
    self.have5[5]=haveR4Lb
    
    local result,results,have=allianceVoApi:checkAllianceDonate(self.sid)
    --满足条件的对错号
    for i=1,5,1 do
        local p1Sp;
        if results[i]==true then
            p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
        else
            p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
        end
        self.pp5[i]={results[i],p1Sp}
        p1Sp:setAnchorPoint(ccp(0.5,0.5))
      
        p1Sp:setPosition(ccp(lbX3-30,yy6-self.everyHeight *i))

        container:addChild(p1Sp)
    end

    
    --经验
    local expLb=GetTTFLabel(getlocal("alliance_skill"),20,true)
    expLb:setAnchorPoint(ccp(0.5,0.5))
    expLb:setPosition(ccp(lbX4,yy))
    container:addChild(expLb)
    expLb:setColor(titleColor)
    
    --贡献
    local contributionLb=GetTTFLabel(getlocal("alliance_contribution"),20,true)
    contributionLb:setAnchorPoint(ccp(0.5,0.5))
    contributionLb:setPosition(ccp(lbX5+10,yy))
    container:addChild(contributionLb)
    contributionLb:setColor(titleColor)
    
    --操作
    local operatorLb=GetTTFLabel(getlocal("alliance_list_scene_operator"),20,true)
    operatorLb:setAnchorPoint(ccp(0.5,0.5))
    operatorLb:setPosition(ccp(lbX6,yy))
    container:addChild(operatorLb)
    operatorLb:setColor(titleColor)
    
    
    local function donate(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if self.tableView and self.tableView:getScrollEnable()==true and self.tableView:getIsScrolled()==false then
            local function showDonateSmallDialog()
                allianceSmallDialog:allianceDonateDialog("PanelHeaderPopup.png",CCSizeMake(600,680+100),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,nil,tag,self.sid)
            end
            local sid = 0
            if allianceSkillCfg[self.sid] then
                sid = tonumber(allianceSkillCfg[self.sid].sid)
            end
            if sid==22 or sid==23 then --军团城市和城市护盾科技，需要在有军团城市时才可以捐献
                if base.allianceCitySwitch==0 then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26000"),28)    
                    do return end
                end
                local function checkCanDonate()
                    local hasCityFlag=allianceCityVoApi:hasCity()
                    if hasCityFlag==false then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("noCityDonateDisable"),28)
                        do return end
                    end
                    showDonateSmallDialog()
                end
                local getFlag=allianceCityVoApi:hasGetCity()
                if getFlag==false then
                  allianceCityVoApi:initCity(checkCanDonate)
                else
                  checkCanDonate()
                end
            else
                showDonateSmallDialog()
            end
        end
    end
    for i=1,5,1 do
        local buttonName1="creatRoleBtn.png"
        local buttonName2="creatRoleBtn_Down.png"
    
        local donateItem = GetButtonItem(buttonName1,buttonName1,buttonName2,donate,i,getlocal("donateTTF"),28)
        donateItem:setScale(0.6)
        local donateMenu=CCMenu:createWithItem(donateItem);
        donateMenu:setPosition(ccp(lbX6,yy6-i*self.everyHeight ))
        donateMenu:setTouchPriority(-(self.layerNum-1)*20-2);
        container:addChild(donateMenu)
        if idx~=0 then
            if tonumber(allianceSkillCfg[idx].allianceUnlockLevel)>allianceVoApi:getSelfAlliance().level then
                donateItem:setEnabled(false)
            end
        end
    end

    if base.isDonateall == 1 then 
        -- 一键捐献按钮
        local oneKeyItem = GetButtonItem("newGreenBtn.png", "newGreenBtn_down.png", "newGreenBtn.png", function (tag, object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            if self.tableView and self.tableView:getScrollEnable()==true and self.tableView:getIsScrolled()==false then
                require "luascript/script/game/scene/gamedialog/allianceDialog/allianceOneKeyDonateDialog"
                local td = allianceOneKeyDonateDialog:new()
                local dialog = td:init(self.layerNum + 1, self.sid, self.tableView)
                sceneGame:addChild(dialog, self.layerNum + 1)
            end
        end, 101, getlocal("oneKeyDonate"), 25/0.7)
        oneKeyItem:setScale(0.7)
        local oneKeyMenu = CCMenu:createWithItem(oneKeyItem)
        oneKeyMenu:setPosition(ccp(container:getContentSize().width/2, 50))
        oneKeyMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 2)
        container:addChild(oneKeyMenu)

        if idx ~= 0 then
            if tonumber(allianceSkillCfg[idx].allianceUnlockLevel) > allianceVoApi:getSelfAlliance().level then
                oneKeyItem:setEnabled(false)
            end
        end
    end
end

function allianceDonate:tick()
    --四个需求
    local reTb1,reTb2,reTb3=allianceVoApi:getAllianceDonateRequire(self.sid)
    --[[
    tolua.cast(self.require5[1],"CCLabelTTF"):setString(FormatNumber(reTb1[1]))
    tolua.cast(self.require5[2],"CCLabelTTF"):setString(FormatNumber(reTb1[2]))
    tolua.cast(self.require5[3],"CCLabelTTF"):setString(FormatNumber(reTb1[3]))
    tolua.cast(self.require5[4],"CCLabelTTF"):setString(FormatNumber(reTb1[4]))
    tolua.cast(self.require5[5],"CCLabelTTF"):setString(FormatNumber(reTb1[5]))
    ]]
    for k,v in pairs(self.require5) do
        local requireLb=tolua.cast(v,"CCLabelTTF")
        if requireLb~=nil and reTb1 and reTb1[k] then
            requireLb:setString(FormatNumber(reTb1[k]))
        end
    end
    for k,v in pairs(self.exp5) do
        local haveLb=tolua.cast(v,"CCLabelTTF")
        if haveLb~=nil and reTb2 and reTb2[k] then
            haveLb:setString("+"..reTb2[k])
        end
    end
    for k,v in pairs(self.donate5) do
        local haveLb=tolua.cast(v,"CCLabelTTF")
        if haveLb~=nil and reTb3 and reTb3[k] then
            haveLb:setString("+"..reTb3[k])
        end
    end
    
    local result,results,have=allianceVoApi:checkAllianceDonate(self.sid)
    for k,v in pairs(self.pp5) do
         if results[k]~=self.pp5[k][1] then
              local p1Sp
              if results[k]==true then
                 p1Sp=CCSprite:createWithSpriteFrameName("IconCheck.png")
              else
                 p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
              end
              p1Sp:setAnchorPoint(ccp(0.5,0.5))
              local reYY=15
              local yy6=self.container:getContentSize().height-30+reYY
              p1Sp:setPosition(ccp(220-30,yy6-65*k))
              self.container:addChild(p1Sp)
              if self.pp5[k][2]~=nil then
                  self.pp5[k][2]:removeFromParentAndCleanup(true)
                  self.pp5[k]=nil
                  self.pp5[k]={results[k],p1Sp}
              end
         end
    end
    
    for k,v in pairs(self.have5) do
        local haveLb=tolua.cast(v,"CCLabelTTF")
        if haveLb~=nil and have and have[k] then
            haveLb:setString(FormatNumber(have[k]))
        end
    end

end

function allianceDonate:dispose() --释放方法

    self.container=nil
    for k,v in pairs(self.pp5) do
         k=nil
         v=nil
    end
    self.pp5=nil
    for k,v in pairs(self.have5) do
         k=nil
         v=nil
    end
    self.have5=nil
    for k,v in pairs(self.require5) do
        v=nil
    end
    self.require5=nil
    for k,v in pairs(self.donate5) do
        v=nil
    end
    self.donate5=nil
    for k,v in pairs(self.exp5) do
        v=nil
    end
    self.exp5=nil
    self=nil
end
