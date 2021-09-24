tankAnimationBySelf={
	
   container,
   sprite,--坦克图片
   tankBarrelSP,--坦克炮管
   lightSp,--开火闪光
   tid,
   isSpace,--坦克站位，因为此位置没有坦克
   area, --坦克所在区域（左边还是右边）
   pos,
   tankPosition=nil,
   randMoveDirect=1, --1:前进 -1:后退
   randMove=false,
   tickIndex=0,
   layerNum=nil,

   lTankFireNeedPosX=nil,--左边某坦克炮火偏移位置
   lTankFireNeedPosY=nil,
   rTankFireNeedPosX=nil,--右边
   rTankFireNeedPosX=nil,
   lTankBarrelNeedPosX=nil,--左边某坦克炮管偏移位置
   lTankBarrelNeedPosY=nil,
   rTankBarrelNeedPosX=nil,--右边
   rTankBarrelNeedPosY=nil,
   --每种坦克炮管帧动画数20种坦克
   tankBarrelFrameCount={[10001]=5,[10002]=5,[10003]=5,[10004]=5,[10005]=5,[10011]=5,[10012]=5,[10013]=5,[10014]=5,[10015]=5,[10021]=5,[10022]=5,[10023]=5,[10024]=5,[10025]=5,[10031]=0,[10032]=0,[10033]=0,[10034]=0,[10035]=0,[10041]=5,[10042]=5,[10043]=5,[10044]=5,[10045]=5,[10051]=5,[10052]=5,[10053]=5,[10054]=5,[10055]=5,[10061]=0,[10062]=0,[10063]=0,[10064]=5,[10065]=0,[10071]=5,[10072]=5,[10073]=5,[10074]=5,[10075]=5,[10081]=0,[10082]=0,[10083]=0,[10084]=0,[10085]=0,[10006]=5,[10016]=5,[10026]=5,[10036]=0,[10093]=5,[10103]=0,[10113]=0,[10123]=0,[10007]=5,[10017]=5,[10027]=5,[10037]=0},   --每种坦克炮管帧动画数20种坦克
   --每种坦克履开火帧动画数20种坦克
   tankFireFrameCount={ [10001]=7,[10002]=7,[10003]=7,[10004]=7,[10005]=7,[10011]=10,[10012]=10,[10013]=10,[10014]=10,[10015]=10,[10021]=9,[10022]=9,[10023]=9,[10024]=9,[10025]=9,[10031]=11,[10032]=11,[10033]=11,[10034]=11,[10035]=11,[10041]=7,[10042]=7,[10043]=7,[10044]=7,[10045]=7,[10051]=7,[10052]=7,[10053]=7,[10054]=7,[10055]=7,[10061]=7,[10062]=7,[10063]=7,[10064]=7,[10065]=7,[10071]=7,[10072]=7,[10073]=7,[10074]=7,[10075]=7,[10081]=11,[10082]=11,[10083]=11,[10084]=11,[10085]=11,[10006]=7,[10016]=10,[10026]=9,[10036]=11,[10093]=7,[10103]=10,[10113]=10,[10123]=7,[10007]=7,[10017]=10,[10027]=9,[10037]=11},   --每种坦克履开火帧动画数20种坦克
	--右边坦克开火动画位置
   rtankFirePos={ [10001]=ccp(-70,-20),[10002]=ccp(-70,-20),[10003]=ccp(-70,-20),[10004]=ccp(-70,-20),[10005]=ccp(-70,-20),[10011]=ccp(-70,-20),[10012]=ccp(-70,-20),[10013]=ccp(-70,-20),[10014]=ccp(-70,-20),[10015]=ccp(-70,-20),[10021]=ccp(-70,30),[10022]=ccp(-70,40),[10023]=ccp(-70,40),[10024]=ccp(-70,40),[10025]=ccp(-70,40),[10031]=ccp(-15,35),[10032]=ccp(-25,25),[10033]=ccp(-19,25),[10034]=ccp(-55,15),[10035]=ccp(-50,25),[10041]=ccp(-70,-20),[10042]=ccp(-70,-20),[10043]=ccp(-70,-20),[10044]=ccp(-70,-20),[10045]=ccp(-70,-20),[10051]=ccp(-70,-20),[10052]=ccp(-70,-20),[10053]=ccp(-70,-20),[10054]=ccp(-70,-20),[10055]=ccp(-70,-20),[10061]=ccp(-70,10),[10062]=ccp(-70,10),[10063]=ccp(-70,10),[10064]=ccp(-70,10),[10065]=ccp(-70,10),[10071]=ccp(-70,-20),[10072]=ccp(-70,-20),[10073]=ccp(-70,-20),[10074]=ccp(-70,-20),[10075]=ccp(-70,-20),[10081]=ccp(-70,-20),[10082]=ccp(-50,10),[10083]=ccp(-70,-20),[10084]=ccp(-70,-20),[10085]=ccp(-70,-20),[10006]=ccp(-70,-20),[10016]=ccp(-70,-20),[10026]=ccp(-70,40),[10036]=ccp(-50,25),[10093]=ccp(-70,-20),[10103]=ccp(-70,-20),[10113]=ccp(-70,-20),[10123]=ccp(-70,-20),[10007]=ccp(-70,-20),[10017]=ccp(-70,-20),[10027]=ccp(-70,40),[10037]=ccp(-50,25)},--右边坦克开火动画位置
	--左边坦克开火偏移位置
   ltankFirePos={[10043]=ccp(60,-15),[10113]=ccp(60,-10),[10063]=ccp(80,-5),},
	--左边坦克炮管偏移位置
   ltankBarrelPos={[10043]=ccp(4,0),[10113]=ccp(0,0),[10063]=ccp(0,0),},
   	--右边坦克开火偏移位置
   	rtankFirePos={[10053]=ccp(-90,-20),[10123]=ccp(-70,-15),[10073]=ccp(-80,-10),},
   	--右边坦克炮管偏移位置
   	rtankBarrelPos={[10053]=ccp(0,0),[10123]=ccp(0,0),[10073]=ccp(0,0),},

	r_tankBulletRotate={ [10001]=-150,  [10002]=-150,  [10003]=-150,  [10004]=-150,  [10005]=-150,  [10011]=-150,  [10012]=-150,  [10013]=-150,  [10014]=-150,  [10015]=-150,  [10021]=180,   [10022]=185,   [10023]=190,   [10024]=190,   [10025]=190,   [10031]=180,   [10032]=190,   [10033]=190,   [10034]=190,   [10035]=190,   [10041]=-150,  [10042]=-150,  [10043]=-150,  [10044]=-150,  [10045]=-150,  [10051]=-150,  [10052]=-150,  [10053]=-150,  [10054]=-150,  [10055]=-150,  [10061]=180,   [10062]=180,   [10063]=180,   [10064]=180,   [10065]=180,   [10071]=-150,  [10072]=-150,  [10073]=-150,  [10074]=-150,  [10075]=-150,  [10081]=180,   [10082]=190,   [10083]=190,   [10084]=190,   [10085]=190,[10006]=-150,[10016]=-150, [10026]=190,[10036]=190,[10093]=-150, [10103]=-150,[10113]=-150,[10123]=-150,[10007]=-150,[10017]=-150, [10027]=190,[10037]=190},
    r_tankBulletRotate={ [10001]=-150,  [10002]=-150,  [10003]=-150,  [10004]=-150,  [10005]=-150,  [10011]=-150,  [10012]=-150,  [10013]=-150,  [10014]=-150,  [10015]=-150,  [10021]=180,   [10022]=185,   [10023]=190,   [10024]=190,   [10025]=190,   [10031]=180,   [10032]=190,   [10033]=190,   [10034]=190,   [10035]=190,   [10041]=-150,  [10042]=-150,  [10043]=-150,  [10044]=-150,  [10045]=-150,  [10051]=-150,  [10052]=-150,  [10053]=-150,  [10054]=-150,  [10055]=-150,  [10061]=180,   [10062]=180,   [10063]=180,   [10064]=180,   [10065]=180,   [10071]=-150,  [10072]=-150,  [10073]=-150,  [10074]=-150,  [10075]=-150,  [10081]=180,   [10082]=190,   [10083]=190,   [10084]=190,   [10085]=190,[10006]=-150,[10016]=-150, [10026]=190,[10036]=190,[10093]=-150, [10103]=-150,[10113]=-150,[10123]=-150,[10007]=-150,[10017]=-150, [10027]=190,[10037]=190},

   r_missleTankPC={[10031]={{0,0},{-15,8},{-30,16},{0,0},{-15,8},{-30,16}},
   [10032]={{-40,6},{-20,3},{0,0},{-40,6},{-20,3},{0,0}},
   [10033]={{0,0},{-15,8},{-30,16},{0,0},{-15,8},{-30,16}},
   [10034]={{0,0},{-15,8},{-30,16},{0,0},{-15,8},{-30,16}},
   [10035]={{0,0},{-15,8},{-30,16},{0,0},{-15,8},{-30,16}},
   [10036]={{0,0},{-15,8},{-30,16},{0,0},{-15,8},{-30,16}},
   [10082]={{0,0},{-15,8},{-30,16},{0,0},{-15,8},{-30,16}}},
}
--实例化一个坦克 tid:坦克类型(1-20), pos:默认置1 就可以  area:坦克所在的区域 1：左边 2:右边
function tankAnimationBySelf:new(tid,pos,isSpace,area,layerNum)

    local nc={

    }
    setmetatable(nc,self)
    self.__index=self
    nc.tid=tid
    nc.pos=pos
    nc.area=area
    nc.isSpace=isSpace
    nc.layerNum=layerNum
    nc.tickIndex=pos*7+(pos+13)*20
    nc:init()
    return nc
end

function tankAnimationBySelf:dispose( )
    self.container=nil
   self.sprite=nil --坦克图片
   self.shellSp=nil --子弹
   self.tankBarrelSP=nil --坦克炮管
   self.tankPedrellSp=nil --坦克履带
   self.ltankDustSp=nil --坦克履带烟雾（左）
   self.rtankDustSp=nil --坦克履带烟雾（右）
   self.lightSp=nil --开火闪光
   
   self.pos=nil
   self.area=nil
   self.tankBarrelFrameCount=nil --每种坦克炮管帧动画数 20种坦克
   self.tankPedrellFrameCount=nil --每种坦克履带帧动画数 20种坦克
   self.tankDustFrameCount=nil --每种坦克履带烟雾帧动画数 20种坦克
   self.tankFireFrameCount=nil --每种坦克履开火帧动画数 20种坦克
   self.leftDownPos=nil
   self.rightTopPos=nil
   self.leftDownShellStartPos=nil
   
   self.leftDownShellEndPos=nil --左方每个坦克的子弹终点值,6个
   self.rightTopShellStartPos=nil --每个坦克子弹相对坦克本身的坐标偏移
   
   self.rightTopShellEndPos=nil --右方每个坦克的子弹终点值,6个
   self.r_rtankDustPos=nil --右边坦克右侧履带烟雾位置
   self.r_ltankDustPos=nil --右边坦克左侧履带烟雾位置
   self.l_rtankDustPos=nil --左边坦克右侧履带烟雾位置
   self.l_ltankDustPos=nil --左边坦克左侧履带烟雾位置    
   self.tankPosition=nil
   self.randMoveDirect=nil
   self.randMove=nil
   self.tickIndex=nil
   self.randPosition=nil
   self.tankFireSp=nil
   self.rtankFirePos=nil
   self.ltankFirePos=nil
   self.rtankMuzzlePos=nil
   self.ltankMuzzlePos=nil
   self.needShock=nil
   self.shockIndex=nil
   self.inBattle=nil
   self.tankBulletCfg=nil
   self.fyBufPosWidth=nil
   self.bufPicDataTb=nil--显示坦克buf debuf 图片的 数据信息（存放sp,buf的key,排列位置）
   self.bufAllTb=nil--保存当前坦克所拥有的所有buf,debuf的key
   self.bufShowMask=nil--显示buf图片的容器
   self.moreBufShow =nil
   
   self.bufSmallDialog =nil
   self.sameBuffNum=nil
    -- print("self.tid---in dispose--->",self.tid)
    local str = "ship/newTank/t"..self.tid.."newTank.plist"
    local str2 = "ship/newTank/t"..self.tid.."newTank.png"
    spriteController:removePlist(str)
    spriteController:removeTexture(str2)
   self.tid=nil
   self=nil
end


function tankAnimationBySelf:init()
   	self.tankId=tonumber(RemoveFirstChar(self.tid))
   	self.tid=GetTankOrderByTankId(tonumber(RemoveFirstChar(self.tid)))

  local str = "ship/newTank/t"..self.tid.."newTank.plist"
  local str2 = "ship/newTank/t"..self.tid.."newTank.png"
  spriteController:addPlist(str)
  spriteController:addTexture(str2)
   -- print("tid------>",self.tid)
	if self.area ==1 then
	   self.lTankFireNeedPosX=self.ltankFirePos[self.tankId].x
	   self.lTankFireNeedPosY=self.ltankFirePos[self.tankId].y
	   self.lTankBarrelNeedPosX=self.ltankBarrelPos[self.tankId].x
	   self.lTankBarrelNeedPosY=self.ltankBarrelPos[self.tankId].y
	elseif self.area ==2 then
	   self.rTankFireNeedPosX=self.rtankFirePos[self.tankId].x--右边
	   self.rTankFireNeedPosY=self.rtankFirePos[self.tankId].y
	   self.rTankBarrelNeedPosX=self.rtankBarrelPos[self.tankId].x--右边
	   self.rTankBarrelNeedPosY=self.rtankBarrelPos[self.tankId].y
	end
	self.container=CCNode:create()
	local rarea=1
	local tankFrameName="t"..self.tid.."_"..rarea..".png" --第5层
   	local tankBarrel="t"..self.tid.."_"..rarea.."_1.png"  --炮管 第6层

   	-- print("tankFrameName===",tankFrameName)

	self.sprite=CCSprite:createWithSpriteFrameName(tankFrameName)
	self.sprite:setPosition(self.isSpace)
	self.container:addChild(self.sprite,5) --坦克本身
    self.container:setScale(1)

  --local tankID = self.tankId
  local function showTankInfo( ... )
  	tankInfoDialog:create(nil,self.tankId,self.layerNum+1, nil)
  end

	local firstBorder = LuaCCSprite:createWithSpriteFrameName("BlackAlphaBg.png",showTankInfo)
	firstBorder:setScaleX(self.sprite:getContentSize().width/firstBorder:getContentSize().width)
	firstBorder:setScaleY(self.sprite:getContentSize().height/firstBorder:getContentSize().height)
	firstBorder:setAnchorPoint(ccp(0.5,0.5))
	firstBorder:setPosition(self.isSpace)
	firstBorder:setTouchPriority(-(self.layerNum-1)*20-5)
	firstBorder:setVisible(false)
	self.container:addChild(firstBorder,9)

	if self.tankBarrelFrameCount[self.tankId]>0 then
	    self.tankBarrelSP=CCSprite:createWithSpriteFrameName(tankBarrel)
	    self.container:addChild(self.tankBarrelSP,6) --炮管
	end
	if self.area==1 then
		self.sprite:setFlipX(true)
		if self.tankBarrelSP then
	    	self.tankBarrelSP:setFlipX(true)
	    	self.tankBarrelSP:setPosition(ccp(self.sprite:getPositionX()+self.lTankBarrelNeedPosX,self.sprite:getPositionY()+self.lTankBarrelNeedPosY))
	    end
	elseif self.area==2 then
		if self.tankBarrelSP then
			self.tankBarrelSP:setPosition(ccp(self.sprite:getPositionX()+self.rTankBarrelNeedPosX,self.sprite:getPositionY()+self.rTankBarrelNeedPosY))
		end
    end
    self.tankPosition=self.isSpace
    self.randPosition=self.isSpace
    self.fireNum=100

end


--rate:开火动画频率 fireNum:开火次数
function tankAnimationBySelf:fire(rate,fireNum,norecord)
    local tankTypeIndex=1
    if tankCfg[self.tankId].type=="1" then
       --PlayEffect(audioCfg.tank_1)
       tankTypeIndex=1
    elseif tankCfg[self.tankId].type=="2" then
       --PlayEffect(audioCfg.tank_2)
       tankTypeIndex=2
    elseif tankCfg[self.tankId].type=="4" then
       --PlayEffect(audioCfg.tank_3)
       tankTypeIndex=3
    elseif tankCfg[self.tankId].type=="8" then
       --PlayEffect(audioCfg.tank_4)
       tankTypeIndex=4
    end

    if tankCfg[self.tankId].type=="8" then
        self:fireForMissile(rate,fireNum,norecord)
        do
            return
        end
    end
    if norecord==nil then
        if fireNum==nil then
            self.fireNum=1
        else
            self.fireNum=fireNum
        end
    end
    self.needShock=true
    self.shockIndex=1
    --************以下代码是开火动画
    if self.tankFireSp~=nil then
      -- print("here removeFromParentAndCleanup~~~~~~~1111122222")
       self.tankFireSp:stopAllActions()
       self.tankFireSp:removeFromParentAndCleanup(true)
       self.tankFireSp=nil
    end
   local tankFireFrameName="fire"..tankTypeIndex.."_1.png" --开火动画
   self.tankFireSp=CCSprite:createWithSpriteFrameName(tankFireFrameName)
   if self.area ==1 then
   	self.tankFireSp:setFlipX(true)
   end
   local fireArr=CCArray:create()
    for kk=1,self.tankFireFrameCount[self.tankId] do
        local nameStr="fire"..tankTypeIndex.."_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        fireArr:addObject(frame)
   end
   local animation=CCAnimation:createWithSpriteFrames(fireArr)

   if rate==nil then
     animation:setDelayPerUnit(0.05)
   else
     animation:setDelayPerUnit(rate)
   end

   local animate=CCAnimate:create(animation)

   self.tankFireSp:setPosition(ccp(0,0))
   self.container:addChild(self.tankFireSp,7) --开火动画

   if self.area==1 then
        self.tankFireSp:setPosition(ccp(self.sprite:getPositionX()+self.lTankFireNeedPosX,self.sprite:getPositionY()+self.ltankFirePos[self.tankId].y))
        local brato=210-(self.r_tankBulletRotate[self.tankId]<0 and (360+self.r_tankBulletRotate[self.tankId]) or self.r_tankBulletRotate[self.tankId])
        self.tankFireSp:setRotation(brato)
        if acMoscowGamblingGaiVoApi:getVersion() == 2 then
        	self.tankFireSp:setRotation(brato-80)
        end
   elseif  self.area==2 then --右边坦克
        --self.tankFireSp:setRotation(ccp(self.sprite:getPositionX()+self.rTankFireNeedPosX,self.sprite:getPositionY()+self.rtankFirePos[self.tankId].y))----
        self.tankFireSp:setPosition(ccp(self.sprite:getPositionX()+self.rTankFireNeedPosX,self.sprite:getPositionY()+self.rtankFirePos[self.tankId].y))
        local brato=210-(self.r_tankBulletRotate[self.tankId]<0 and (360+self.r_tankBulletRotate[self.tankId]) or self.r_tankBulletRotate[self.tankId])
        self.tankFireSp:setRotation(brato)
        --self.tankFireSp:setRotation(180)
   end

   local function removeFireSp()
    -- print("here removeFromParentAndCleanup~~~~~~~1111133333")
       self.tankFireSp:removeFromParentAndCleanup(true)
       self.tankFireSp=nil
   end
   local  ffunc=CCCallFuncN:create(removeFireSp)
   local  fseq=CCSequence:createWithTwoActions(animate,ffunc)
   self.tankFireSp:runAction(fseq)
   --************以上代码是开火动画
   self:showBarrelSPAction()
 
   self:showShock()
end

function tankAnimationBySelf:showBarrelSPAction()

   if self.tankBarrelFrameCount[self.tankId]>0 then
       local fireArr=CCArray:create()
        for kk=1,self.tankBarrelFrameCount[self.tankId] do
        	local reare = 1
            -- print("self.tid---22222-->",self.tid)
            local nameStr="t"..self.tid.."_"..reare.."_"..kk..".png"
            -- print("nameStr------>",nameStr)
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            fireArr:addObject(frame)
       end
       local animation=CCAnimation:createWithSpriteFrames(fireArr)
       animation:setDelayPerUnit(0.06)
       local animate=CCAnimate:create(animation)
       self.tankBarrelSP:runAction(animate)
   end
end

function tankAnimationBySelf:showShock()
    local curTankPos=ccp(self.container:getPosition())
    local aimPos
    if self.area==1 then --左方
          aimPos=  ccp(curTankPos.x-6,curTankPos.y+3.5)
    elseif self.area ==2 then
          aimPos=  ccp(curTankPos.x+6,curTankPos.y+3.5)
    end
    self.container:setPosition(aimPos)
end

function tankAnimationBySelf:tick()
    if self.inBattle==false then
         return
    end
    self.tickIndex=self.tickIndex+1
    if self.needShock==true then
        self.shockIndex=self.shockIndex+1
        if self.shockIndex==6 then
            self.needShock=false
        end
    end
    local fireRate=1
    if tankCfg[self.tankId].type=="8" then
        fireRate=8
    end
    if self.tickIndex%fireRate==0 then

        if self.fireNum>0 then
            self:fire(0.04,0,true)
        end
    end
    if self.randMove==false then
            self.randMove=true
            self.container:stopAllActions()
            if (math.floor(self.tickIndex/60))%3==0 then
                self.randMoveDirect=-1
            else
                self.randMoveDirect=1
            end

			local mvTo
			if self.container:getPosition() ~= self.randPosition then
				if self.area ==1 then
					mvTo = CCMoveTo:create(0.5,ccp(6,-3.5))
				elseif self.area ==2 then
					mvTo = CCMoveTo:create(0.5,ccp(-6,-3.5))
				end
			end

            local function moveEnd()
                self.container:stopAllActions()
                if self.randPosition.x~=self.tankPosition.x or self.randPosition.y~=self.tankPosition.y then --返回原位置
                    self.randPosition=self.tankPosition
                    local fmv=CCMoveTo:create(1,self.tankPosition)
                    local  ffunc=CCCallFuncN:create(moveEnd)
                    local  fseq=CCSequence:createWithTwoActions(fmv,ffunc)
                    self.container:runAction(fseq)
                else
                    self.randMove=false
                end
            end
            local  func=CCCallFuncN:create(moveEnd);
            local  seq=CCSequence:createWithTwoActions(mvTo,func)
            self.container:runAction(seq)
    end

end

function tankAnimationBySelf:fireForMissile(rate,fireNum,norecord)
    if norecord==nil then
         self.fireNum=6
    end
    --self.needShock=true
    --self.shockIndex=1
    --************以下代码是开火动画

   local tankFireFrameName="fire4_1.png" --开火动画
   local m_tankFireSp=CCSprite:createWithSpriteFrameName(tankFireFrameName)

   local fireArr=CCArray:create()
    for kk=1,self.tankFireFrameCount[self.tankId] do
        local nameStr="fire4_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        fireArr:addObject(frame)
   end
   local animation=CCAnimation:createWithSpriteFrames(fireArr)
   if rate==nil then
     animation:setDelayPerUnit(0.05)
   else
     animation:setDelayPerUnit(rate)
   end
   local animate=CCAnimate:create(animation)
   m_tankFireSp:setPosition(ccp(0,0))
   self.container:addChild(m_tankFireSp,7) --开火动画
   local missleTankP=self.tankId
   -- if self.tid>15 and self.tid<=20 then
   --     missleTankP=self.tid-15
   -- elseif self.tid>40 and self.tid<=45 then
   --     missleTankP=self.tid-40
   -- end
   
   if self.area==1 then
        
        local tfSPoint=self.rtankFirePos[self.tankId]
        local tmpSPoint=ccp(0,0)
        tmpSPoint.x=tfSPoint.x+self.r_missleTankPC[missleTankP][6-self.fireNum+1][1]
        tmpSPoint.y=tfSPoint.y+self.r_missleTankPC[missleTankP][6-self.fireNum+1][2]
        
        m_tankFireSp:setPosition(tmpSPoint)
        local brato=210-(self.r_tankBulletRotate[self.tankId]<0 and (360+self.r_tankBulletRotate[self.tankId]) or self.r_tankBulletRotate[self.tankId])
        m_tankFireSp:setRotation(brato)
   elseif  self.area==2 then --左方坦克
        local tfSPoint=self.ltankFirePos[self.tankId]
        local tmpSPoint=ccp(0,0)
        tmpSPoint.x=tfSPoint.x+self.l_missleTankPC[missleTankP][6-self.fireNum+1][1]
        tmpSPoint.y=tfSPoint.y+self.l_missleTankPC[missleTankP][6-self.fireNum+1][2]
        m_tankFireSp:setRotation(self.l_tankBulletRotate[self.tankId])
        m_tankFireSp:setPosition(tmpSPoint)
        local brato=210-(self.r_tankBulletRotate[self.tankId]<0 and (360+self.r_tankBulletRotate[self.tankId]) or self.r_tankBulletRotate[self.tankId])
        m_tankFireSp:setRotation(brato)
        m_tankFireSp:setRotation(180)
   end
   local function removeFireSp()
      -- print("here removeFromParentAndCleanup~~~~~~~11111")
       m_tankFireSp:removeFromParentAndCleanup(true)
       m_tankFireSp=nil
   end
   local  ffunc=CCCallFuncN:create(removeFireSp)
   local  fseq=CCSequence:createWithTwoActions(animate,ffunc)
   m_tankFireSp:runAction(fseq)
   --************以上代码是开火动画
   self:showBarrelSPAction()
end



