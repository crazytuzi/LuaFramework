acTankBattleDialog = commonDialog:new()

function acTankBattleDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.touchArr={}
    self.touchEnable=true
    self.multTouch=false
    self.point=ccp(0,0)

    self.isEnd=false
    self.count=0
    self.score = 0
    self.tankNum=0
    self.tankTb={} -- {{}} v[1]:anemy v[2]:血量
    self.bulletTb={}
    self.lastBulletTime=0
    self.lastDirection=0
    self.countDownNum=5
    


    return nc
end

function acTankBattleDialog:resetTab()
    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 105))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))

    self.closeBtn:setEnabled(false)
    self.closeBtn:setVisible(false)
    self.limit1={G_VisibleSizeWidth/2,G_VisibleSizeHeight-50-(G_VisibleSizeHeight-640)/2}
    self.limit2={G_VisibleSizeWidth/2,50+(G_VisibleSizeHeight-640)/2}
    self.limit3={50,G_VisibleSizeHeight/2}
    self.limit4={G_VisibleSizeWidth-50,G_VisibleSizeHeight/2}

    self:initLayer()

end

function acTankBattleDialog:initTableView()
end

function acTankBattleDialog:initLayer()
    self.clayer=CCLayerColor:create(ccc4(0,0,0,255))
    self.bgLayer:addChild(self.clayer,5)

    local function nilFunc()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-9)
    local rect=CCSizeMake(640,640)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setAnchorPoint(ccp(0,0))
    touchDialogBg:setPosition(0,(G_VisibleSizeHeight-640)/2)
    self.bgLayer:addChild(touchDialogBg,10)
    self.touchDialogBg=touchDialogBg

    local CtipLb = GetTTFLabelWrap(getlocal("activity_tankbattle_operateTip"),30,CCSizeMake(540,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    CtipLb:setAnchorPoint(ccp(0.5,0.5))
    CtipLb:setPosition(ccp(touchDialogBg:getContentSize().width/2,touchDialogBg:getContentSize().height/2+80))
    touchDialogBg:addChild(CtipLb,2)
    CtipLb:setColor(G_ColorYellowPro)

    local headbg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),nilFunc);
    headbg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(500,CtipLb:getContentSize().height+20)
    headbg:setContentSize(rect)
    headbg:setOpacity(180)
    headbg:setPosition(ccp(touchDialogBg:getContentSize().width/2,touchDialogBg:getContentSize().height/2+80))
    touchDialogBg:addChild(headbg,1)

    local countDownLb=GetTTFLabel(self.countDownNum,45)
    countDownLb:setPosition(ccp(touchDialogBg:getContentSize().width/2,touchDialogBg:getContentSize().height/2-20))
    touchDialogBg:addChild(countDownLb)
    self.countDownLb=countDownLb


    self.timeTb={10,25,40,55,70,85,100,115,130,145,160,175,190,205,220,235,250,265,280,295,310,325,340,355,370,385,400}

    self:initUpAdnDown()
    
    self.clayer:setBSwallowsTouches(false)
    self.clayer:setTouchEnabled(true)
    local function tmpHandler(...)
       return self:touchEvent(...)
    end
    self.clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-4,true)
    self.clayer:setTouchPriority(-(self.layerNum-1)*20-4)

    self:initMap()
    

end

function acTankBattleDialog:initUpAdnDown()
    local height=160
    if(G_isIphone5())then
        height=160+88
    end

    local function nilFunc()
    end
    local downBg = LuaCCScale9Sprite:createWithSpriteFrameName("acTankBattle_gray.png",CCRect(1,1,1,1),nilFunc)
    downBg:setContentSize(CCSizeMake(640,height))
    downBg:setAnchorPoint(ccp(0,0))
    downBg:setPosition(ccp(0,0))
    self.clayer:addChild(downBg)

    local tipLb=GetTTFLabelWrap(getlocal("activity_tankbattle_operateTip2"),25,CCSizeMake(560,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    tipLb:setAnchorPoint(ccp(0.5,0.5))
    tipLb:setPosition(ccp(downBg:getContentSize().width/2,downBg:getContentSize().height/2))
    downBg:addChild(tipLb)



    local function nilFunc()
    end
    local upBg = LuaCCScale9Sprite:createWithSpriteFrameName("acTankBattle_gray.png",CCRect(1,1,1,1),nilFunc)
    upBg:setContentSize(CCSizeMake(640,height))
    upBg:setAnchorPoint(ccp(0,1))
    upBg:setPosition(ccp(0,G_VisibleSize.height))
    self.clayer:addChild(upBg)

    local scoreStr = getlocal("activity_tankbattle_score") .. ":" ..  self.score
    local scoreLb=GetTTFLabelWrap(scoreStr,25,CCSizeMake(560,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    scoreLb:setPosition(ccp(upBg:getContentSize().width/2,upBg:getContentSize().height/2))
    upBg:addChild(scoreLb)
    self.scoreLb=scoreLb
end

function acTankBattleDialog:initMap()
    
    local spriteBatch = CCSpriteBatchNode:create("public/acTankBattle.png")
    self.clayer:addChild(spriteBatch)
    self.spriteBatch=spriteBatch

    local gangTb={ccp(240,560),ccp(208,560),ccp(176,560),ccp(144,560),ccp(112,560),ccp(80,560),ccp(48,560),ccp(16,560),ccp(624,560),ccp(592,560),ccp(560,560),ccp(528,560),ccp(496,560),ccp(464,560),ccp(432,560),ccp(400,560),ccp(624,400),ccp(592,400),ccp(560,400),ccp(528,400),ccp(496,400),ccp(464,400),ccp(432,400),ccp(400,400),ccp(240,400),ccp(208,400),ccp(176,400),ccp(144,400),ccp(112,400),ccp(80,400),ccp(48,400),ccp(16,400),ccp(240,592),ccp(240,624),ccp(240,656),ccp(240,688),ccp(240,720),ccp(240,752),ccp(240,784),ccp(400,592),ccp(400,624),ccp(400,656),ccp(400,688),ccp(400,720),ccp(400,752),ccp(400,784),ccp(400,176),ccp(400,208),ccp(400,240),ccp(400,272),ccp(400,304),ccp(400,336),ccp(400,368),ccp(240,176),ccp(240,208),ccp(240,240),ccp(240,272),ccp(240,304),ccp(240,336),ccp(240,368)}
    for k,v in pairs(gangTb) do
        local gangIcon=CCSprite:createWithSpriteFrameName("acTankBattle_gang.png")
        gangIcon:setPosition(v)
        spriteBatch:addChild(gangIcon)
        if(G_isIphone5())then
            local y=gangIcon:getPositionY()
            gangIcon:setPositionY(y+88)
        end
    end

    local haiTb={ccp(80,592),ccp(560,272),ccp(624,336),ccp(624,208),ccp(624,240),ccp(624,272),ccp(624,304),ccp(592,240),ccp(592,272),ccp(592,304),ccp(80,368),ccp(112,368),ccp(144,368),ccp(112,336),ccp(144,336),ccp(144,304),ccp(144,272),ccp(80,624),ccp(80,656),ccp(80,688),ccp(80,720),ccp(80,752),ccp(48,592),ccp(48,624),ccp(48,656),ccp(48,688),ccp(48,720),ccp(48,752),ccp(16,592),ccp(16,624),ccp(16,656),ccp(16,688),ccp(16,720),ccp(16,752),ccp(528,752),ccp(528,720),ccp(528,688),ccp(496,720),ccp(496,688),ccp(560,720),ccp(560,688),ccp(528,624),ccp(528,592),ccp(496,624),ccp(496,592),ccp(560,624),ccp(560,592)}
    for k,v in pairs(haiTb) do
        local haiIcon=CCSprite:createWithSpriteFrameName("acTankBattle_ocean.png")
        haiIcon:setPosition(v)
        spriteBatch:addChild(haiIcon)
        if(G_isIphone5())then
            local y=haiIcon:getPositionY()
            haiIcon:setPositionY(y+88)
        end
        
    end

    local zhuanTb={ccp(208,784),ccp(176,784),ccp(144,784),ccp(112,784),ccp(144,752),ccp(112,752),ccp(144,720),ccp(112,720),ccp(144,688),ccp(112,688),ccp(144,656),ccp(112,656),ccp(144,624),ccp(112,624),ccp(144,592),ccp(112,592),ccp(80,752),ccp(80,720),ccp(80,688),ccp(80,656),ccp(80,624),ccp(80,592),ccp(48,368),ccp(16,368),ccp(48,336),ccp(16,336),ccp(48,304),ccp(16,304),ccp(48,272),ccp(16,272),ccp(48,240),ccp(16,240),ccp(48,208),ccp(16,208),ccp(48,176),ccp(112,304),ccp(80,304),ccp(144,240),ccp(112,272),ccp(112,240),ccp(16,176),ccp(464,368),ccp(432,368),ccp(464,336),ccp(432,336),ccp(464,304),ccp(432,304),ccp(464,272),ccp(432,272),ccp(464,240),ccp(432,240),ccp(464,208),ccp(432,208),ccp(464,176),ccp(432,176),ccp(208,368),ccp(176,368),ccp(208,336),ccp(176,336),ccp(208,304),ccp(176,304),ccp(208,272),ccp(176,272),ccp(208,240),ccp(176,240),ccp(208,208),ccp(176,208),ccp(208,176),ccp(176,176),ccp(464,592),ccp(432,592),ccp(464,624),ccp(432,624),ccp(464,656),ccp(432,656),ccp(464,688),ccp(432,688),ccp(464,720),ccp(432,720),ccp(496,752),ccp(464,752),ccp(624,368),ccp(592,368),ccp(592,336),ccp(560,336),ccp(560,304),ccp(528,304),ccp(528,272),ccp(496,272),ccp(560,240),ccp(528,240),ccp(592,208),ccp(560,208),ccp(624,176),ccp(592,176),ccp(592,752),ccp(560,752),ccp(624,592),ccp(592,592),ccp(624,624),ccp(592,624),ccp(624,656),ccp(592,656),ccp(624,688),ccp(592,688),ccp(624,720),ccp(592,720),ccp(80,784),ccp(48,784),ccp(16,784),ccp(80,336),ccp(144,208),ccp(560,784),ccp(528,784),ccp(496,784),ccp(560,656),ccp(528,656),ccp(496,656)}

    for k,v in pairs(zhuanTb) do
        local zhuanIcon=CCSprite:createWithSpriteFrameName("acTankBattle_zhuan.png")
        zhuanIcon:setPosition(v)
        spriteBatch:addChild(zhuanIcon)
        if(G_isIphone5())then
            local y=zhuanIcon:getPositionY()
            zhuanIcon:setPositionY(y+88)
        end
    end

    local caoTb={ccp(208,592),ccp(496,368),ccp(528,368),ccp(496,336),ccp(496,304),ccp(496,240),ccp(496,208),ccp(496,176),ccp(528,336),ccp(528,208),ccp(528,176),ccp(560,368),ccp(560,176),ccp(80,272),ccp(80,240),ccp(80,208),ccp(112,208),ccp(112,176),ccp(80,176),ccp(144,176),ccp(432,752),ccp(432,784),ccp(624,752),ccp(624,784),ccp(464,784),ccp(592,784),ccp(208,624),ccp(208,656),ccp(208,688),ccp(208,720),ccp(208,752),ccp(176,592),ccp(176,624),ccp(176,656),ccp(176,688),ccp(176,720),ccp(176,752)}

    for k,v in pairs(caoTb) do
        local caoIcon=CCSprite:createWithSpriteFrameName("acTankBattle_grass.png")
        caoIcon:setPosition(v)
        spriteBatch:addChild(caoIcon)
        if(G_isIphone5())then
            local y=caoIcon:getPositionY()
            caoIcon:setPositionY(y+88)
        end
    end


    local tankIcon=CCSprite:createWithSpriteFrameName("acTankBattle_self.png")
    tankIcon:setPosition(G_VisibleSize.width/2,G_VisibleSize.height/2)
    self.clayer:addChild(tankIcon)
    -- tankIcon:setScale(100/tankIcon:getContentSize().width)
    self.tankIcon=tankIcon

    

end


function acTankBattleDialog:touchEvent(fn,x,y,touch)

    if fn=="began" then
        if self.touchEnable==false or SizeOfTable(self.touchArr)>=1 then
             return 0
        end
        self.isMoved=false
        self.touchArr[touch]=touch
        self.point=ccp(x,y)
        -- local point = touch:getLocation()

        if SizeOfTable(self.touchArr)>1 then
            self.multTouch=true
        else
            self.multTouch=false
        end
        return 1
    elseif fn=="moved" then
        if self.touchEnable==false then
             do
                return
             end
        end
        self.isMoved=true
        if self.multTouch==true then --双点触摸

        else --单点触摸

        end
    elseif fn=="ended" then
        if self.touchEnable==false then
             do
                return
             end
        end

        if self.multTouch==true then --双点触摸

        elseif self.isEnd==false and G_getCurDeviceMillTime()>=self.lastBulletTime then --单点触摸
            
            local temTouch= tolua.cast(self.touchArr[touch],"CCTouch")
            local point = temTouch:getLocation()

            -- local 
            local delX = x-self.point.x
            local delY = y-self.point.y
            
            local direction = 0
            if math.abs(delX)-math.abs(delY)>=0 and delX>=15 then
                self.tankIcon:setRotation(90)
                -- print("end+++++++++++you")
                direction=4
            elseif math.abs(delX)-math.abs(delY)>=0 and delX<-15 then
                self.tankIcon:setRotation(-90)
                -- print("end+++++++++++zuo")
                direction=3
            elseif math.abs(delX)-math.abs(delY)<=-0 and delY>=15 then
                self.tankIcon:setRotation(0)
                -- print("end+++++++++++shang")
                direction=1
            elseif math.abs(delX)-math.abs(delY)<=-0 and delY<-15 then
                self.tankIcon:setRotation(180)
                -- print("end+++++++++++xia")
                direction=2
            end

            if direction~=0 then
               self.lastBulletTime=G_getCurDeviceMillTime()+100
               self:addBullte(direction)
            end
            
            
        end

        self.touchArr=nil
        self.touchArr={}
    end
end

function acTankBattleDialog:addBullte(direction)
    local bullteSp=CCSprite:createWithSpriteFrameName("acTankBattle_bullet.png")
    bullteSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.spriteBatch:addChild(bullteSp)
    table.insert(self.bulletTb,bullteSp)

    self:addBullteAnimy(bullteSp,direction)
end

function acTankBattleDialog:addBullteAnimy(bullteSp,direction)
    local ritchPos = ccp(0,0)
    if direction==1 then
        ritchPos=ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-50-(G_VisibleSizeHeight-640)/2)
        -- bullteSp:setRotation(180) 
    elseif direction==2 then
        ritchPos=ccp(G_VisibleSizeWidth/2,50+(G_VisibleSizeHeight-640)/2)
        bullteSp:setRotation(180)
    elseif direction==3 then
        ritchPos=ccp(50,G_VisibleSizeHeight/2)
        bullteSp:setRotation(-90) 
    else
        ritchPos=ccp(G_VisibleSizeWidth-50,G_VisibleSizeHeight/2)
        bullteSp:setRotation(90) 
    end

    local function callback()
    end

    local moveTo =CCMoveTo:create(0.7,ritchPos)
    local callFunc = CCCallFunc:create(callback)
    local acArr=CCArray:create()
    acArr:addObject(moveTo)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    bullteSp:runAction(seq)

end




function acTankBattleDialog:tick()
    if acTankBattleVoApi:acIsStop() == true then
        if self then
            self:close()
            do return end
        end
    end


    self.countDownNum=self.countDownNum-1
    if self.countDownNum>0 then
        self.countDownLb:setString(self.countDownNum)
        return 
    elseif self.countDownNum==0 then
            self.countDownLb:setString(getlocal("activity_tankbattle_go"))
            local acMove = CCMoveTo:create(0.5,ccp(-650,(G_VisibleSizeHeight-640)/2))
            self.touchDialogBg:runAction(acMove)
            return
    elseif self.countDownNum==-1 then
        return
    end

    if self.touchEnable and self.isEnd==false then
        if self.count<20 then
            if self.count%2==0 then
                self:preduceAction()
            end
        elseif self.count<50 then
            if self.count%2==0 then
                self:preduceAction()
                self:preduceAction()
            end
        else
            if self.count%1==0 then
                self:preduceAction()
                self:preduceAction()
            end
        end
        self.count=self.count+1
    end 
end

function acTankBattleDialog:preduceAction()
    local tankType = math.random(10)
    local direction = math.random(4)
    if self.lastDirection==direction then
        while true do
            direction = math.random(4)
            if direction==self.lastDirection then
            else
                break
            end
        end
    end
    self.lastDirection=direction


    local pzFrameName="acTankBattle_smallStar.png"
    local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
    self.spriteBatch:addChild(metalSp)
    self:RedressTankPos(metalSp,direction)

    local pzArr=CCArray:create()
    for kk=1,4 do
        local nameStr = "acTankBattle_smallStar.png"
        if kk%2==0 then
            nameStr = "acTankBattle_bigStar.png"
        end
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        pzArr:addObject(frame)
    end
    local animation=CCAnimation:createWithSpriteFrames(pzArr)
    animation:setDelayPerUnit(0.1)
    local animate=CCAnimate:create(animation)
    local function callback()
        metalSp:removeFromParentAndCleanup(true)
        self:preduceAnemyTank(tankType,direction)
    end
    local callFunc=CCCallFunc:create(callback)
    local seq=CCSequence:createWithTwoActions(animate,callFunc)
    metalSp:runAction(seq)


end

-- direction 1:上 2：下 3：左 4:右
-- tankType <=3:2血  其它：1血
function acTankBattleDialog:preduceAnemyTank(tankType,direction)
    -- local tankType = math.random(10)
    -- local direction = math.random(4)
    local life
    local tankSp
    if tankType<=3 then
        tankSp=CCSprite:createWithSpriteFrameName("acTankBattle_anemy2.png")
        life=2
    else
        tankSp=CCSprite:createWithSpriteFrameName("acTankBattle_anemy1.png")
        life=1
    end
    self.spriteBatch:addChild(tankSp)
    -- tankSp:setScale(100/tankSp:getContentSize().width)
    table.insert(self.tankTb,{tankSp,life,life})
    self:RedressTankPos(tankSp,direction)

    self:addMoveAnimy(tankSp)
end

function acTankBattleDialog:RedressTankPos(tankSp,direction)
    if direction==1 then
        tankSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-50-(G_VisibleSizeHeight-640)/2)
        tankSp:setRotation(180)
    elseif direction==2 then
        tankSp:setPosition(G_VisibleSizeWidth/2,50+(G_VisibleSizeHeight-640)/2)
        -- tankSp:setRotation(180)
    elseif direction==3 then
        tankSp:setPosition(50,G_VisibleSizeHeight/2)
        tankSp:setRotation(90)
    else
        tankSp:setPosition(G_VisibleSizeWidth-50,G_VisibleSizeHeight/2)
        tankSp:setRotation(-90)
    end
end

function acTankBattleDialog:addMoveAnimy(tankSp)

    local time=self.timeTb[#self.timeTb]
    for k,v in pairs(self.timeTb) do
        if self.count<v then
            time=220/(v+80)
            break
        end
    end

    local moveTo=CCMoveTo:create(time,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
    tankSp:runAction(moveTo)
end

function acTankBattleDialog:fastTick()
    if self.isEnd then
        return
    end
    if self.countDownNum>=0 then
        return 
    end
    self:checkCollision()
end

function acTankBattleDialog:checkCollision()
    -- print("∑∑0",G_getCurDeviceMillTime())
    -- 坦克与敌坦克碰撞
    -- local tankRect = self.tankIcon:boundingBox()
    for k,v in pairs(self.tankTb) do
        -- local reck = v[1]:boundingBox()
        -- if reck:intersectsRect(tankRect) then
        if self:isTankCllision(self.tankIcon,v[1]) then
            self.isEnd=true
            self.touchEnable=false
            base.pauseSync=false
            -- self:endAction()
            self:tankDead(self.tankIcon,true)
            self.tankIcon:removeFromParentAndCleanup(true)
            return
        end
    end
    -- print("∑∑1",G_getCurDeviceMillTime())

    for i=#self.bulletTb,1,-1 do
        local v=self.bulletTb[i]
        if(v==nil)then
            break
        end
        local x,y = v:getPosition()
        if ((x==self.limit1[1] and y==self.limit1[2]) or (x==self.limit2[1] and y==self.limit2[2]) or (x==self.limit3[1] and y==self.limit3[2]) or (x==self.limit4[1] and y==self.limit4[2])) then
            v:removeFromParentAndCleanup(true)
            table.remove(self.bulletTb,i)
        end
    end
    -- print("∑∑2",G_getCurDeviceMillTime())


    -- 子弹与敌坦克碰撞
    for i=#self.bulletTb,1,-1 do
        local v=self.bulletTb[i]
        if(v==nil)then
            break
        end
        for j=#self.tankTb,1,-1 do
            local vv=self.tankTb[j]
            if(vv==nil)then
                break
            end
            local x,y = v:getPosition()
            local pos=ccp(x,y)
            local reck = vv[1]:boundingBox()
            -- if reck:containsPoint(pos) then
            if self:isBulletCllision(vv[1],v) then
                v:removeFromParentAndCleanup(true)
                table.remove(self.bulletTb,i)
                if vv[2]==2 then
                    vv[2]=1
                    self:subLife(vv[1])
                else
                    self:tankDead(vv[1])
                    vv[1]:removeFromParentAndCleanup(true)
                    self:setScorePoint(vv[3])
                    table.remove(self.tankTb,j)
                end
                break
            end
        end
    end
    -- print("∑∑3",G_getCurDeviceMillTime())

end

function acTankBattleDialog:isTankCllision(sp1,sp2)
    local x1,y1 = sp1:getPosition()
    local x2,y2 = sp2:getPosition()
    local rotate1 = sp1:getRotation()
    local rotate2 = sp2:getRotation()
    -- print("++++++++rotate1,rotate2",rotate1,rotate2)
    if math.abs(rotate1-rotate2)==90 and math.abs(x1-x2)+math.abs(y1-y2)<=60 then
        -- print("++++++111111")
        return true
    elseif math.abs(rotate1-rotate2)~=90 and math.abs(x1-x2)+math.abs(y1-y2)<=73 then
        -- print("++++++22222")
        return true
    end
    return false
end

function acTankBattleDialog:isBulletCllision(sp1,sp2)
    local x1,y1 = sp1:getPosition()
    local x2,y2 = sp2:getPosition()
    if math.abs(x1-x2)+math.abs(y1-y2)<=40 then
        return true
    end
    return false
end

function acTankBattleDialog:subLife(sp1)
    local sp2=GraySprite:createWithSpriteFrameName("acTankBattle_anemy1.png")
    sp2:setPosition(sp1:getContentSize().width/2,sp1:getContentSize().height/2)
    sp1:setOpacity(0)
    sp1:addChild(sp2)

end

function acTankBattleDialog:tankDead(sp1,flag)
    local x1,y1 = sp1:getPosition()

    local sp2=CCSprite:createWithSpriteFrameName("acTankBattle_bomb.png")
    sp2:setPosition(x1,y1)
    self.spriteBatch:addChild(sp2)

    local function removeBomb()
        sp2:removeFromParentAndCleanup(true)
        if flag==true then
            self:endAction()
        end
    end
    local callFunc=CCCallFunc:create(removeBomb)
    local delay=CCDelayTime:create(0.05)
    local acArr=CCArray:create()
    acArr:addObject(delay)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    sp2:runAction(seq)


end

function acTankBattleDialog:endAction()
    acTankBattleVoApi:showTankBattleEndDialog(self.layerNum+1,self,self.count,self.score)
    for k,v in pairs(self.bulletTb) do
        v:stopAllActions()
    end
    for k,v in pairs(self.tankTb) do
        v[1]:stopAllActions()
    end
end

function acTankBattleDialog:setScorePoint(life)
    local tpointTb = acTankBattleVoApi:getTPoint( )
    local point = tpointTb[life] or life
    self.score = self.score + point
    local scoreStr = getlocal("activity_tankbattle_score") .. ":" ..  self.score
    self.scoreLb:setString(scoreStr)

    self.tankNum=self.tankNum+1
end

function acTankBattleDialog:dispose()
    self.touchArr={}
    self.touchEnable=nil
    self.spriteBatch=nil
    self.tankTb=nil
    self.bulletTb=nil
    self.lastBulletTime=0

end
