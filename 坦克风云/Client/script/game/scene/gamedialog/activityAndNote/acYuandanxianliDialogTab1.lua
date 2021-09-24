acYuandanxianliDialogTab1 = {}

function acYuandanxianliDialogTab1:new(layerNum)
	local nc = {}
	setmetatable(nc,self)
	self.__index=self

	self.bgLayer=nil
    self.playBtnBg=nil
    self.playBtn=nil
    self.rewardIconList={}
    self.halo=nil           --赌博机的光圈
    self.tickIndex=0
    self.tickInterval=5     --光圈移动的倒计时
    self.tickConst=5        --tick的间距
    self.haloPos=nil     --光圈当前在第几个图标上
    self.layerNum=nil
    self.acRoulette5Dialog=nil
    self.rewardList={}
    self.reward={}
    self.lastTime=nil
    self.touchEnabledSp=nil
    self.diffPoint=nil
    self.cellHeight=nil
    self.colorChosNum =1
    self.colorNumByTick=1
    self.receiveColorNum=1
    self.multip=1 ---默认倍数
    self.slowStart=false
    self.endIdx=0
    self.count=0
    self.isPlay =false

    self.isToday = false

	return 	nc
end

function acYuandanxianliDialogTab1:init(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self.isToday =acYuandanxianliVoApi:isToday()
	self:initDesc()
	self:initRoulette()


 return self.bgLayer
end

--初始化上半部分
function acYuandanxianliDialogTab1:initDesc( )

	local capInSet = CCRect(20, 20, 10, 10);
    local function bgClick(hd,fn,idx)
    end
    self.titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    self.titleBg:setContentSize(CCSizeMake(G_VisibleSize.width-40, G_VisibleSize.height-750))
    self.titleBg:setAnchorPoint(ccp(0,1));
    self.titleBg:setPosition(ccp(20,G_VisibleSize.height-160))
    self.bgLayer:addChild(self.titleBg,1)			--背景布

	local function showInfo()
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end 
        PlayEffect(audioCfg.mouseClick)
        local tabStr={};
        local tabColor ={};
        local td=smallDialog:new()
        tabStr = {getlocal("activity_yuandanxianli_explain4",24),"\n",getlocal("activity_yuandanxianli_explain3",24),"\n",getlocal("activity_yuandanxianli_explain2",24),"\n",getlocal("activity_yuandanxianli_explain1",24),"\n"}  --按钮内的说明信息
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25)
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setScale(0.8)
    infoItem:setAnchorPoint(ccp(1,1))
    infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-30,G_VisibleSize.height-170))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(infoBtn,5)			--右上角的按钮

    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-185))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)
    
    local acVo = acYuandanxianliVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-220))
        self.bgLayer:addChild(timeLabel,5)
    end

    local descTv=G_LabelTableView(CCSize(480,120),getlocal("activity_yuandanxianli_DescFirst"),25,kCCTextAlignmentCenter)
    descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    --descTv:setAnchorPoint(ccp(0.5,0.5))
    descTv:setPosition(ccp(self.bgLayer:getContentSize().width*0.1,self.bgLayer:getContentSize().height-355))
    self.bgLayer:addChild(descTv,5)
    descTv:setMaxDisToBottomOrTop(70)
end

--初始化赌博机
function acYuandanxianliDialogTab1:initRoulette( )
	 local rewardDate = acYuandanxianliVoApi:getRouletteCfg() ---拿到配置信息
	 --local rewardDate =rouletteCfg
	 local rewardPool =FormatItem(rewardDate,nil,true) or {} ---  ！！！等后端数据格式确定好以后，才能决定用哪种调用   （格式化数据）
	--local rewardPool=acYuandanxianliVoApi:formatItemData(rewardDate) or {} 


    local capInSet = CCRect(65, 25, 1, 1);
    local function bgClick(hd,fn,idx)
    end
    local btnBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",capInSet,bgClick)
    local iconWidth=122
    local iconHeight=136

    btnBg:setContentSize(CCSizeMake(iconWidth*2.5,260))
    btnBg:setAnchorPoint(ccp(0.5,0))
    btnBg:setPosition(ccp(G_VisibleSize.width/2,160))
    btnBg:setTouchPriority(0)
    self.bgLayer:addChild(btnBg)
    self.playBtnBg=btnBg

    local curGems = acYuandanxianliVoApi:getGems()--拿到用户的金币数量
    local oneDraw = acYuandanxianliVoApi:getOneDrawGold()
    local tenDraw = acYuandanxianliVoApi:getTenDrawGold()

	self.singleGoldIcon1=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.singleGoldIcon1:setAnchorPoint(ccp(0,0))
	self.singleGoldIcon1:setPosition(ccp(btnBg:getContentSize().width/2+10,btnBg:getContentSize().height/2+90))
	btnBg:addChild(self.singleGoldIcon1,5)

	local singleGoldIcon2=CCSprite:createWithSpriteFrameName("IconGold.png")
	singleGoldIcon2:setAnchorPoint(ccp(0,0))
	singleGoldIcon2:setPosition(ccp(btnBg:getContentSize().width/2+10,btnBg:getContentSize().height/2-30))
	btnBg:addChild(singleGoldIcon2,5)

	self.moneyCount1 = GetTTFLabel(oneDraw,30)
	self.moneyCount1:setAnchorPoint(ccp(1,0))
	self.moneyCount1:setPosition(ccp(btnBg:getContentSize().width/2,btnBg:getContentSize().height/2+90))
	self.moneyCount1:setColor(G_ColorYellow)
	btnBg:addChild(self.moneyCount1,5)

	local moneyCount2 = GetTTFLabel(tenDraw,30)
	moneyCount2:setAnchorPoint(ccp(1,0))
	moneyCount2:setPosition(ccp(btnBg:getContentSize().width/2,btnBg:getContentSize().height/2-30))
	moneyCount2:setColor(G_ColorYellow)
	btnBg:addChild(moneyCount2,5)	

	local function touch()
        PlayEffect(audioCfg.mouseClick)
        self.state=3
    end
    self.touchEnabledSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
    self.touchEnabledSp:setAnchorPoint(ccp(0,0))
    self.touchEnabledSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    self.touchEnabledSp:setIsSallow(true)
    self.touchEnabledSp:setTouchPriority(-(self.layerNum-1)*20-7)
    -- sceneGame:addChild(self.touchEnabledSp,self.layerNum)
    self.bgLayer:addChild(self.touchEnabledSp,self.layerNum)
    self.touchEnabledSp:setOpacity(0)
    self.touchEnabledSp:setPosition(ccp(10000,0))
    self.touchEnabledSp:setVisible(false)

    local function onPlay()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        local free=0              --是否是第一次免费
        if acYuandanxianliVoApi:isToday()==true then
            free=1
        end
        if free==1 and playerVoApi:getGems()<acYuandanxianliVoApi:getOneDrawGold() then
          GemsNotEnoughDialog(nil,nil,acYuandanxianliVoApi:getOneDrawGold()-playerVoApi:getGems(),self.layerNum+1,acYuandanxianliVoApi:getOneDrawGold())
          do return end
        end
        local function wheelfortuneCallback(fn,data)
            self.touchEnabledSp:setVisible(true)
            self.touchEnabledSp:setPosition(ccp(0,0))
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if self and self.bgLayer then
                    self.playBtn2:setEnabled(false)
                    self.playBtn:setEnabled(false)
                    self.playTenBtn:setEnabled(false)
                    if sData and sData.data and sData.data.yuandanxianli and sData.data.yuandanxianli.clientReward then
                      if free==1 then
                        playerVoApi:setValue("gems",playerVoApi:getGems()-acYuandanxianliVoApi:getOneDrawGold())
                      end

                        local pBen 
                        local report=sData.data.yuandanxianli.clientReward or {}
                        self.reward={}
                        for k,v in pairs(report) do
                            local pid,ptype,pnum 
                            if v then
                                ptype = v[1]
                                pid = v[2]
                                pnum = v[3]
                                pBen = v[4]

                                for m,n in pairs(rewardPool) do
                                    if ptype == n.type and pid == n.key and pnum ==n.num then
                                        n.pBen = v[4]
                                        table.insert(self.reward,n)
                                    end
                                end
                            end
                        end
                        if pBen == 1 then
                            self.receiveColorNum=1
                        elseif pBen == 2 then
                            self.receiveColorNum=2
                        elseif pBen ==5 then
                            self.receiveColorNum=3
                        elseif pBen ==10 then
                            self.receiveColorNum=4
                        end
                        for k,v in pairs(self.reward) do        ----！！！！此段逻辑需修改为抽到 重要物品 或 多倍数 然后广播
                            G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num)*v.pBen,nil,true)
                            self.multip=v.pBen
                            if v then
                                if acYuandanxianliVoApi:isReportReward(v.index,v.pBen) then
                                    local kayStr="activity_yuandanxianli_chatSystemMessage"
                                    if kayStr and kayStr~="" then
                                        local message={key=kayStr,param={playerVoApi:getPlayerName(),v.name,v.num*v.pBen}}
                                        chatVoApi:sendSystemMessage(message)
                                    end
                                end
                            end
                        end
                        if free == 0 then
                          acYuandanxianliVoApi:updateLastTime()
                          self.isToday=acYuandanxianliVoApi:isToday()
                          acYuandanxianliVoApi:updateShow()
                        end

                        self:play()

                    end
                end
            else
                if self and self.touchEnabledSp then
                    self.touchEnabledSp:setVisible(false)
                    self.touchEnabledSp:setPosition(ccp(10000,0))
                end
            end
        end

        socketHelper:activityYuandanxianli("rand",1,wheelfortuneCallback)      --！！！ 需要改函数名，参数是否变动(已改)
    end
    local textSize = 25
    if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
        textSize=20
    end

 
    self.playBtn2=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onPlay,1,getlocal("daily_lotto_tip_2"),textSize)
    self.playBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onPlay,1,getlocal("activity_wheelFortune_subTitle_1"),textSize)
  
    self.playBtn:setAnchorPoint(ccp(0.5,0))
    local playBtnMenu=CCMenu:createWithItem(self.playBtn)
    playBtnMenu:setAnchorPoint(ccp(0.5,0))
    playBtnMenu:setPosition(ccp(btnBg:getContentSize().width/2,btnBg:getContentSize().height/2+10))
    playBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    btnBg:addChild(playBtnMenu,5)
    self.playBtn:setEnabled(false)

    self.playBtn2:setAnchorPoint(ccp(0.5,0))
    local playBtnMenu=CCMenu:createWithItem(self.playBtn2)
    playBtnMenu:setAnchorPoint(ccp(0.5,0))
    playBtnMenu:setPosition(ccp(btnBg:getContentSize().width/2,btnBg:getContentSize().height/2+10))
    playBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    btnBg:addChild(playBtnMenu,5)
    self.playBtn2:setEnabled(false)


    local function onTenPlay()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        
        if playerVoApi:getGems()<acYuandanxianliVoApi:getTenDrawGold() then
          GemsNotEnoughDialog(nil,nil,acYuandanxianliVoApi:getTenDrawGold()-playerVoApi:getGems(),self.layerNum+1,acYuandanxianliVoApi:getTenDrawGold())
          do return end
        end

            local function wheelfortuneCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if self and self.bgLayer then
                        if sData and sData.data and sData.data.yuandanxianli and sData.data.yuandanxianli.clientReward then
                            playerVoApi:setValue("gems",playerVoApi:getGems()-acYuandanxianliVoApi:getTenDrawGold())
                            local reportTen=sData.data.yuandanxianli.clientReward or {}
                            local cfg=acYuandanxianliVoApi:getRouletteCfg() ---------拿十连抽的配置
                            local content={}
                            self.reward={}
                            local pBen = {}

                            for k,v in pairs(reportTen) do
                                local pid,ptype,pnum,index
                                if v then
                                    ptype = v[1]
                                    pid = v[2]
                                    pnum = v[3]

                                    for m,n in pairs(rewardPool) do
                                        if ptype == n.type and pid == n.key and pnum ==n.num then
                                            index = n.index
                                        end
                                    end
                                    local name,pic,desc,id,noUseIdx,eType,equipId=getItem(pid,ptype)
                                    table.insert(self.reward,{name=name,num=pnum,pic=pic,desc=desc,id=id,type=ptype,index=index,key=pid,eType=eType,equipId=equipId,pBen=v[4]})
                                    
                                end
                            end

                            for k,v in pairs(self.reward) do
                                local award=v or {}
                                award.num = award.num*award.pBen
                                table.insert(content,{award=award,point=0,index=award.index})
                                print(award.id,award.name,award.num)
                                G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                                if award then
                                    if acYuandanxianliVoApi:isReportReward(award.index,v.pBen) then
                                        local kayStr="activity_yuandanxianli_chatSystemMessage"
                                        if kayStr and kayStr~="" then
                                            local message={key=kayStr,param={playerVoApi:getPlayerName(),award.name,award.num}}
                                            chatVoApi:sendSystemMessage(message)
                                        end
                                    end
                                end
                            end
                            
                            if content and SizeOfTable(content)>0 then 
                                local function confirmHandler(awardIdx,pBen)
                                    if awardIdx and awardIdx>0 and pBen then
                                        self.haloPos = awardIdx
                                        local tx,ty=self.rewardIconList[awardIdx]:getPosition()
                                        self.halo:setPosition(tx,ty)
                                        if self.halo:isVisible()==false then
                                            self.halo:setVisible(true)
                                        end
                                        
                                        if pBen == 1 then
                                            self.colorChosNum=1
                                        elseif pBen == 2 then
                                            self.colorChosNum=2
                                        elseif pBen ==5 then
                                            self.colorChosNum=3
                                        elseif pBen ==10 then
                                            self.colorChosNum=4
                                        end
                                        self:haloSetColor()
                                    else
                                        local rewardT = self.reward[SizeOfTable(self.reward)]
                                        self.haloPos = rewardT.index
                                        local tx,ty=self.rewardIconList[self.haloPos]:getPosition()
                                        self.halo:setPosition(tx,ty)
                                        if self.halo:isVisible()==false then
                                            self.halo:setVisible(true)
                                        end
                                        self.colorChosNum = rewardT.pBen
                                        self:haloSetColor()
                                    end
                                end
                                smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,true)
                            end
                        end

                        self:refresh()
                    end
                end
            end
            socketHelper:activityYuandanxianli("rand",10,wheelfortuneCallback)                --！！！！ 改函数名，还有参数
    end

    self.playTenBtn = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onTenPlay,nil,getlocal("ten_roulette_btn"),textSize)
    self.playTenBtn:setAnchorPoint(ccp(0.5,0))
    local playTenBtnMenu=CCMenu:createWithItem(self.playTenBtn)
    playTenBtnMenu:setAnchorPoint(ccp(0.5,0))
    playTenBtnMenu:setPosition(ccp(btnBg:getContentSize().width/2,20))
    playTenBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    btnBg:addChild(playTenBtnMenu,5)
    self.playTenBtn:setEnabled(false)

    self:refresh()


  	local iconWidth=122
    local iconHeight=136
    local wSpace=30
    local hSpace=-10
    local xSpace=30*3
    local ySpace=30*3+20
    for k,v in pairs(rewardPool) do
        local i=k
        if v then
            local icon=self:initRewardIcon(iconBg,i,v)

            if(i<5)then
                icon:setPosition(ccp((iconWidth+wSpace)*(i-1)+xSpace,(iconHeight+hSpace)*3+hSpace+ySpace))
            elseif(i==5)then
                icon:setPosition(ccp((iconWidth+wSpace)*3+xSpace,(iconHeight+hSpace)*2+hSpace+ySpace))
            elseif(i==6)then
                icon:setPosition(ccp((iconWidth+wSpace)*3+xSpace,iconHeight+hSpace*2+ySpace))
            elseif(i<11)then
                icon:setPosition(ccp((iconWidth+wSpace)*(10-i)+xSpace,hSpace*1+ySpace))
            elseif(i==11)then
                icon:setPosition(ccp(xSpace,iconHeight+hSpace*2+ySpace))
            elseif(i==12)then
                icon:setPosition(ccp(xSpace,(iconHeight+hSpace)*2+hSpace+ySpace))
            end
            self.rewardIconList[i]=icon
            self.rewardList[i]=v

        end
    end
    local function nilFunc()
    end

    self.halo=LuaCCSprite:createWithSpriteFrameName("whiteBorder.png",nilFunc)
    --self.halo:setContentSize(CCSizeMake(100+8,100+8))
    self.halo:setAnchorPoint(ccp(0.5,0.5))
    self.halo:setTouchPriority(0)
    self.halo:setColor(G_ColorGreen)
    self.halo:setVisible(true)
   local tx,ty=self.rewardIconList[1]:getPosition()
   self.halo:setPosition(tx,ty)
   self.bgLayer:addChild(self.halo,7)
end

function acYuandanxianliDialogTab1:initRewardIcon(iconBg,i,item)

    local function showInfoHandler(hd,fn,idx)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if item and item.key and item.name and item.num then


            local isAddBg=false
            if item.key=="energy" then
                isAddBg=true
            end
            local isUseLocal=nil
            if item.type=="mm" then
                isUseLocal=true
            end
            propInfoDialog:create(sceneGame,item,self.layerNum+1,isUseLocal,isAddBg)
        end
    end
    local icon
    local v=item
    if v.type=="e" then
        if v.eType=="a" then
            icon=accessoryVoApi:getAccessoryIcon(v.id,60,80,showInfoHandler)
        elseif v.eType=="f" then
            icon=accessoryVoApi:getFragmentIcon(v.id,60,80,showInfoHandler)
            -- iconScaleX=0.8
            -- iconScaleY=0.8
        elseif v.eType=="p" then
            icon=GetBgIcon(item.pic,showInfoHandler,nil,80,80)
        end
    elseif v.type=="p" and v.equipId then
        local eType=string.sub(v.equipId,1,1)
        if eType=="a" then
            icon=accessoryVoApi:getAccessoryIcon(v.equipId,60,80,showInfoHandler)
        elseif eType=="f" then
            icon=accessoryVoApi:getFragmentIcon(v.equipId,60,80,showInfoHandler)
        else
            icon=GetBgIcon(item.pic,showInfoHandler,nil,80,80)
        end
    else
        if item.key=="energy" then
            icon = GetBgIcon(item.pic,showInfoHandler)
        else
            icon = LuaCCSprite:createWithSpriteFrameName(item.pic,showInfoHandler)
        end
    end
    local scale=100/icon:getContentSize().width
    icon:setAnchorPoint(ccp(0.5,0.5))
    -- icon:setPosition(ccp(bgSize.width/2,bgSize.height-icon:getContentSize().height/2*scale-5))
    icon:setIsSallow(false)
    icon:setTouchPriority(-(self.layerNum-1)*20-4)
    icon:setTag(123+i)
    icon:setScale(scale)
    
    if v.type=="p" and v.id and v.id>=293 and v.id<=295 then
    else
        local nameLb=GetTTFLabel("x"..item.num,22)
        nameLb:setAnchorPoint(ccp(1,0))
        nameLb:setPosition(ccp(icon:getContentSize().width-10,5))
        nameLb:setScale(1/scale)
        icon:addChild(nameLb)
    end

    -- iconBg:addChild(icon)
    self.bgLayer:addChild(icon,7)
    return icon
end

-----其他逻辑处理

function acYuandanxianliDialogTab1:play()
    self.touchEnabledSp:setPosition(ccp(0,0))
    self.touchEnabledSp:setVisible(false)


    self.tickIndex=0
    self.tickInterval=3
    self.tickConst=3
    self.intervalNum=3 --fasttick间隔 3帧一次

    self.slowStart=false
    if self.haloPos ==nil then
        self.haloPos=0
    end
    self.endIdx=0
    for k,v in pairs(self.rewardList) do  --因为测试所以注释掉
        if self.rewardList and v and v.type==self.reward[1].type and v.key==self.reward[1].key and v.num==self.reward[1].num then
            self.endIdx=k
        end
    end

    self.slowTime=4

    if self.endIdx>0 then
        self.count=12*self.tickConst --转1圈之后开始减速
        if self.endIdx>self.slowTime then
            self.slowStartIndex=self.endIdx-self.slowTime
        else
            self.count=self.count-((self.slowTime-1)*self.tickConst)
            self.slowStartIndex=self.endIdx-self.slowTime+12
        end

        self.isPlay =true
        --base:addNeedRefresh(self)
    else
        self:refresh()
    end

end

function acYuandanxianliDialogTab1:haloSetColor()
    if self.colorChosNum ==1 then
        self.halo:setColor(G_ColorGreen)
    elseif self.colorChosNum ==2 then
        self.halo:setColor(G_ColorBlue)
    elseif self.colorChosNum == 3 then
        self.halo:setColor(G_ColorPurple)
    elseif self.colorChosNum ==4 then
        self.halo:setColor(G_ColorOrange)
    end
end

function acYuandanxianliDialogTab1:fastTick()
    if self.isPlay == true then
        self.tickIndex=self.tickIndex+1
        self.tickInterval=self.tickInterval-1
        if(self.tickInterval<=0)then
            self.tickInterval=self.tickConst
            self.haloPos=self.haloPos+1
            if(self.haloPos>12)then
                self.haloPos=self.haloPos-12
                -- self.haloPos=1
            end
            local tx,ty=self.rewardIconList[self.haloPos]:getPosition()
            self.halo:setPosition(tx,ty)
            if self.halo:isVisible()==false then
                self.halo:setVisible(true)
            end

            if (self.tickIndex>=self.count) then 

                if(self.haloPos==self.slowStartIndex)then
                    self.slowStart=true
                end
                if (self.slowStart) then
                    --此处执行减速逻辑,减到一定速度(60)之后就不再减
                    -- if(self.tickIndex>self.lastTs)then
                        if (self.tickConst<self.tickConst*3) then
                            self.tickConst=self.tickConst+self.tickConst
                        elseif self.tickConst<self.intervalNum*4 then
                            self.tickConst=self.tickConst+self.tickConst*2
                        end

                end
                if self.endIdx>0 and (self.haloPos==self.endIdx) and self.tickIndex~=self.count then  --还需添加 拿到后端倍数配置与self.colorChosNum做比较
                    local function playEnd()
                        self.isPlay =false
                        self.haloPos=self.endIdx ---
                        self:sureColor()
                        --base:removeFromNeedRefresh(self)
                        self:playEndEffect()
                    end
                    --local delay=CCDelayTime:create(0.5)
                    local callFunc=CCCallFuncN:create(playEnd)
                    
                    local acArr=CCArray:create()
                    --acArr:addObject(delay)
                    acArr:addObject(callFunc)
                    local seq=CCSequence:create(acArr)
                    self.bgLayer:runAction(seq)

                    
                end
            end


        end
        if self.colorNumByTick <=self.intervalNum then

            self:haloSetColor()

            if self.colorChosNum>4 then
                self.colorChosNum=1
            else
                self.colorChosNum=self.colorChosNum+1
            end

            self.colorNumByTick=self.colorNumByTick+1
        else
            self.colorNumByTick = 0
        end

        if self.state == 3 then
            local function playEnd(  )
             
                self.state = 1
                self.isPlay =false
                self.haloPos=self.endIdx ---
                self.halo:setVisible(true)
                self:sureColor()
                local tx,ty=self.rewardIconList[self.haloPos]:getPosition()
                self.halo:setPosition(tx,ty)
                --base:removeFromNeedRefresh(self)
                self:playEndEffect()
            end

            local callFunc=CCCallFuncN:create(playEnd)
                    
            local acArr=CCArray:create()
            --acArr:addObject(delay)
            acArr:addObject(callFunc)
            local seq=CCSequence:create(acArr)
            self.bgLayer:runAction(seq)
        end
    end
    
end
function acYuandanxianliDialogTab1:sureColor(  )

    if self.receiveColorNum ==1 then
        self.halo:setColor(G_ColorGreen)
    elseif self.receiveColorNum ==2 then
        self.halo:setColor(G_ColorBlue)
    elseif self.receiveColorNum == 3 then
        self.halo:setColor(G_ColorPurple)
    elseif self.receiveColorNum ==4 then
        self.halo:setColor(G_ColorOrange)
    end

end

function  acYuandanxianliDialogTab1:playEndEffect()

    local bgSize=self.rewardIconList[self.haloPos]:getContentSize()
    local item=self.rewardList[self.haloPos]
    
    self.rewardIconBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    self.rewardIconBg:setAnchorPoint(ccp(0.5,0.5))
    local tx,ty=self.rewardIconList[self.haloPos]:getPosition()
    -- tx=tx+bgSize.width/2
    -- ty=ty+bgSize.height/2
    self.rewardIconBg:setPosition(tx,ty)


    local rewardIcon=self.rewardIconList[self.haloPos]:getChildByTag(123+self.haloPos)
    -- self.rewardIconList[self.haloPos]:removeChild(rewardIcon,true)
    if item.key=="energy" then
        rewardIcon = GetBgIcon(item.pic)
    else
        rewardIcon = CCSprite:createWithSpriteFrameName(item.pic)
    end
    rewardIcon:setAnchorPoint(ccp(0.5,0.5))
    rewardIcon:setPosition(ccp(self.rewardIconBg:getContentSize().width/2,self.rewardIconBg:getContentSize().height/2))
    self.rewardIconBg:addChild(rewardIcon)
    self.bgLayer:addChild(self.rewardIconBg,11)
    local scale=100/rewardIcon:getContentSize().width
    rewardIcon:setScale(scale)

    if self.maskSp==nil then
        local function tmpFunc()
        end
        self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
        self.maskSp:setOpacity(255)
        local size=CCSizeMake(G_VisibleSize.width-60,500)
        self.maskSp:setContentSize(size)
        self.maskSp:setAnchorPoint(ccp(0.5,0.5))
        self.maskSp:setPosition(ccp(G_VisibleSize.width/2,290))
        self.maskSp:setIsSallow(true)
        self.maskSp:setTouchPriority(-(self.layerNum-1)*20-5)
        self.bgLayer:addChild(self.maskSp,8)
    else
        self.maskSp:setVisible(true)
        self.maskSp:setPosition(ccp(G_VisibleSize.width/2,290))
    end

    if self.confirmBtn==nil then
        local function hideMask()
            if self then
                -- self.bgLayer:removeChild(self.rewardIconBg,true)
                self.rewardIconBg:removeFromParentAndCleanup(true)
                self.rewardIconBg=nil

                if self.maskSp then
                    self.maskSp:setPosition(ccp(10000,0))
                    self.maskSp:setVisible(false)
                end
                if self.confirmBtn then
                    self.confirmBtn:setEnabled(false)
                    self.confirmBtn:setVisible(false)
                end
                -- if self.halo then
                --     self.halo:setVisible(false)
                -- end
                if self.nameLb then
                    self.nameLb:setVisible(false)
                end
                if self.itemDescLb then
                    self.itemDescLb:setVisible(false)
                end
            end
        end
        self.confirmBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",hideMask,4,getlocal("confirm"),25)
        self.confirmBtn:setAnchorPoint(ccp(0.5,0.5))
        local boxSpMenu3=CCMenu:createWithItem(self.confirmBtn)
        boxSpMenu3:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2-100))
        boxSpMenu3:setTouchPriority(-(self.layerNum-1)*20-6)
        self.maskSp:addChild(boxSpMenu3,11)

        self.confirmBtn:setEnabled(false)
        self.confirmBtn:setVisible(false)
    else
        self.confirmBtn:setEnabled(false)
        self.confirmBtn:setVisible(false)
    end

    local allNum = item.num*self.multip --倍数 * 默认个数
    if self.nameLb==nil then
        self.nameLb=GetTTFLabel(item.name.." x"..allNum,25)
        self.nameLb:setAnchorPoint(ccp(0.5,1))
        self.nameLb:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2+60))
        self.maskSp:addChild(self.nameLb,11)
        self.nameLb:setVisible(false)
    else
        self.nameLb:setString(item.name.." x"..allNum)
        self.nameLb:setVisible(false)
    end

    local isShowDesc=true
    for i=1,4 do
        if item.key=="r"..i then
            isShowDesc=false
        end
    end

    local descStr
    if item.type == "mm" then
        descStr = item.desc
    else
        descStr = getlocal(item.desc)
    end
    if isShowDesc==true then
        if self.itemDescLb==nil then
            self.itemDescLb=GetTTFLabelWrap(descStr,22,CCSizeMake(G_VisibleSizeWidth-180,300),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            self.itemDescLb:setAnchorPoint(ccp(0.5,1))
            self.itemDescLb:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2+20))
            self.maskSp:addChild(self.itemDescLb,11)
            self.itemDescLb:setVisible(false)
        else
            self.itemDescLb:setString(descStr)
            self.itemDescLb:setVisible(false)
        end
    else
        if self.itemDescLb then
            self.itemDescLb:setVisible(false)
        end
    end

    local function playEndCallback()
        local str = ""
        if self.reward and SizeOfTable(self.reward)>0 then
            str = getlocal("daily_lotto_tip_10")
            for k,v in pairs(self.reward) do
                local nameStr=v.name
                if v.type=="c" then
                    nameStr=getlocal(v.name,{v.num*v.pBen})
                end
                if k==SizeOfTable(self.reward) then
                    str = str .. nameStr .. " x" .. v.num*v.pBen
                else
                    str = str .. nameStr .. " x" .. v.num*v.pBen .. ","
                end
            end
        end

        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)

        self:refresh()

        if self.confirmBtn then
            self.confirmBtn:setEnabled(true)
            self.confirmBtn:setVisible(true)
        end
        
        if self.touchEnabledSp then
            self.touchEnabledSp:setVisible(false)
            self.touchEnabledSp:setPosition(ccp(10000,0))
        end

        if self.nameLb then
            self.nameLb:setVisible(true)
        end
        if isShowDesc==true then
            if self.itemDescLb then
                self.itemDescLb:setVisible(true)
            end
        end
    end

    local delay1=CCDelayTime:create(0.3)
    local scale1=CCScaleTo:create(0.4,150/rewardIcon:getContentSize().width/scale)
    local scale2=CCScaleTo:create(0.4,100/rewardIcon:getContentSize().width/scale)
    -- local tx,ty=self.playBtnBg:getPosition()
    local tx,ty=self.maskSp:getPosition()
    local mvTo=CCMoveTo:create(0.3,ccp(tx,ty+150))
    local scale3=CCScaleTo:create(0.1,200/rewardIcon:getContentSize().width/scale)
    local scale4=CCScaleTo:create(0.2,120/rewardIcon:getContentSize().width/scale)
    local delay2=CCDelayTime:create(0.2)
    local callFunc=CCCallFuncN:create(playEndCallback)
    
    local acArr=CCArray:create()
    acArr:addObject(delay1)
    -- acArr:addObject(scale1)
    -- acArr:addObject(scale2)
    acArr:addObject(mvTo)
    acArr:addObject(scale3)
    acArr:addObject(scale4)
    acArr:addObject(delay2)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    self.rewardIconBg:runAction(seq)


    self:refresh()
    self.multip=1 --赋值默认值
end


function acYuandanxianliDialogTab1:refresh()
    if self and self.bgLayer then
        if acYuandanxianliVoApi:isToday()==false then
            self.playBtn2:setVisible(true)
            self.playBtn:setVisible(false)
            self.playBtn2:setEnabled(true)
            self.playBtn:setEnabled(false)
            self.playTenBtn:setEnabled(false)
            self.singleGoldIcon1:setVisible(false)
            self.moneyCount1:setVisible(false)
        else      --!!!需要改函数名(已改)
            self.playBtn:setEnabled(true)
            self.playBtn2:setEnabled(false)
            self.playBtn:setVisible(true)
            self.playBtn2:setVisible(false)
            self.singleGoldIcon1:setVisible(true)
            self.moneyCount1:setVisible(true)
            self.playTenBtn:setEnabled(true)

        end


        
    end
    
end

function acYuandanxianliDialogTab1:tick()

  local today = acYuandanxianliVoApi:isToday()
  if today~=self.isToday then
    self.isToday = today
    self:refresh()
  end
end




function acYuandanxianliDialogTab1:dispose()
	self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    self.isToday =nil
    self.td=nil
    self = nil
end
