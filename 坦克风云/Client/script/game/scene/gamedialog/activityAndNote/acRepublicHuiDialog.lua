acRepublicHuiDialog=commonDialog:new()

function acRepublicHuiDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.isToday=nil
    self.rewardIconList={}
    self.rewardList={}
    self.flickerList={}
    self.reward={}

    self.showRowNum= false
    self.dicePlay=false
    self.flickerPlay=false
    self.btnShow=true
    self.playStart=false
    self.isLottery=false

    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acRepublicHui.plist")
    return nc
end

function acRepublicHuiDialog:initTableView()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-95))
    self.isToday=acRepublicHuiVoApi:isRouletteToday()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSizeHeight-400),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(20,20))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)

    self.arrowIndex=60
    base:addNeedRefresh(self)
    
    local function touch()
        local td=smallDialog:new()
        local str1=getlocal("activity_republicHui_tip1");
        local str2=getlocal("activity_republicHui_commonBtn");
        local str3=getlocal("activity_republicHui_tip2");
        local str4=getlocal("activity_republicHui_superBtn");
        local str5=getlocal("activity_republicHui_tip3");
        local str6=getlocal("activity_republicHui_tipNote");
        tabStr={" ",str6,"\n",str5,"\n",str4,"\n",str3,"\n",str2,"\n",str1," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{nil,G_ColorRed,nil,nil,nil,G_ColorGreen,nil,nil,nil,G_ColorGreen,nil,nil,nil})
        sceneGame:addChild(dialog,self.layerNum+1)
    end

    local menuItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem);
    menu:setPosition(ccp(self.bgLayer:getContentSize().width-100,self.bgLayer:getContentSize().height-140));
    menu:setTouchPriority(-(self.layerNum-1)*20-5);
    self.bgLayer:addChild(menu,5);
    
    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-105))
    self.bgLayer:addChild(actTime,5);
    actTime:setColor(G_ColorGreen)

    local acVo = acRepublicHuiVoApi:getAcVo()
    if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        local timeLabel=GetTTFLabel(timeStr,26)
        --timeLabel:setAnchorPoint(ccp(0,0))
        timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-140))
        self.bgLayer:addChild(timeLabel)
        self.timeLb=timeLabel
        G_updateActiveTime(acVo,self.timeLb)
    end

    local function touch()
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local descBg =LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png",capInSet,touch)
    descBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,200))
    descBg:setAnchorPoint(ccp(0,1))
    descBg:setPosition(ccp(15,G_VisibleSize.height-180))
    self.bgLayer:addChild(descBg,1)

    self.aid,self.tankID,self.needPieceNum,self.needComposeTankNum= acRepublicHuiVoApi:getTankIDAndNeedPartNum()

    local function showInfoHandler()
        tankInfoDialog:create(nil,self.tankID,self.layerNum+1, nil)
    end
    local tankIcon = LuaCCSprite:createWithSpriteFrameName(tankCfg[self.tankID].icon,showInfoHandler)
    tankIcon:setTouchPriority(-(self.layerNum-1)*20-5)
    tankIcon:setAnchorPoint(ccp(0,0.5))
    tankIcon:setPosition(ccp(10,descBg:getContentSize().height/2))
    descBg:addChild(tankIcon)

    local tankName = getlocal(tankCfg[self.tankID].name)
    local descTv=G_LabelTableView(CCSize(250,180),getlocal("activity_republicHui_tankDesc",{tankName}),25,kCCTextAlignmentCenter)
 	descTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    descTv:setPosition(ccp(20+tankIcon:getContentSize().width,10))
    descBg:addChild(descTv,2)
    descTv:setMaxDisToBottomOrTop(50)

    local posX = descBg:getContentSize().width-100

    local pieceNumDescLb = GetTTFLabelWrap(getlocal("activity_republicHui_pieceNum"),27,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    pieceNumDescLb:setAnchorPoint(ccp(0.5,0.5))
    pieceNumDescLb:setPosition(ccp(posX,descBg:getContentSize().height-50))
    pieceNumDescLb:setColor(G_ColorGreen)
    descBg:addChild(pieceNumDescLb)

    self.hadPieceNum = acRepublicHuiVoApi:getHadPieceNum()

    self.pieceNumLb=GetTTFLabel(getlocal("scheduleChapter",{self.hadPieceNum,self.needPieceNum}),27)
    self.pieceNumLb:setAnchorPoint(ccp(0.5,0.5))
    self.pieceNumLb:setPosition(ccp(posX,descBg:getContentSize().height/2+10))
    descBg:addChild(self.pieceNumLb)
    self.pieceNumLb:setColor(G_ColorYellow)

    local function onClickCompose()
		local function callback()
			self:refresh()
		end
		acRepublicHuiVoApi:compose(callback)
	end
	self.composeItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickCompose,nil,getlocal("compose"),25)
	self.composeItem:setAnchorPoint(ccp(0,0))
	if acRepublicHuiVoApi:canComposeTank()==false then
		self.composeItem:setEnabled(false)
	else
		self.composeItem:setEnabled(true)
	end
	local composeBtn=CCMenu:createWithItem(self.composeItem)
	composeBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	composeBtn:setAnchorPoint(ccp(0.5,0))
	composeBtn:setPosition(ccp(posX-80,10))
	descBg:addChild(composeBtn)

end



function acRepublicHuiDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,700)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local iconWidth=110
        local iconHeight=136
        local wSpace=10
		local hSpace=-10
		local xSpace=30*4
		local ySpace=30*3+130
        self.flickerPosition=acRepublicHuiVoApi:getflickerPosition()

        local rewardCfg = acRepublicHuiVoApi:getRouletteCfg()
		if rewardCfg ~= nil then
            local index =1
		    for k,v in pairs(rewardCfg) do
                local item = {}
                local icon, iconScale
                if v then
                    for m,n in pairs(v) do
                        if m~=nil and n~=nil then
                            local key,type1,num=m,k,n
                            if type(n)=="table" then
                                for i,j in pairs(n) do
                                    if i=="index" then
                                        index=j
                                    else
                                        key=i
                                        num=j
                                    end
                                    
                                end
                            end

                            if k=="mm" then
                                local pCfg = activityCfg.republicHui[key]
                                item = {type="mm",key=key,name = getlocal(pCfg.name), pic= pCfg.icon, num = num, desc = pCfg.des,index=index}
                            else
                                local name,pic,desc,id,noUseIdx,eType,equipId=getItem(key,type1)
                                item={name=name,num=num,pic=pic,desc=desc,id=id,type=k,index=index,key=key,eType=eType,equipId=equipId}
                            end
                    
                           
                            icon,iconScale= G_getItemIcon(item, 100, true, self.layerNum)
                            if icon and item and item.num then
                                icon:ignoreAnchorPointForPosition(false)
                                icon:setAnchorPoint(ccp(0.5,0.5))
                                icon:setIsSallow(false)
                                icon:setTouchPriority(-(self.layerNum-1)*20-3)
                                cell:addChild(icon,1)

                                local numLabel=GetTTFLabel("x"..item.num,25)
                                numLabel:setAnchorPoint(ccp(1,0))
                                numLabel:setPosition(icon:getContentSize().width-10,0)
                                icon:addChild(numLabel,1)
                                numLabel:setScaleX(1/iconScale)
                                numLabel:setScaleY(1/iconScale)

                                self.rewardIconList[index]=icon
                                self.rewardList[index]=item
                                if(index<5)then
                                    icon:setPosition(ccp((iconWidth+wSpace)*(index-1)+xSpace,(iconHeight+hSpace)*3+hSpace+ySpace))
                                elseif(index==5)then
                                    icon:setPosition(ccp((iconWidth+wSpace)*3+xSpace,(iconHeight+hSpace)*2+hSpace+ySpace))
                                elseif(index==6)then
                                    icon:setPosition(ccp((iconWidth+wSpace)*3+xSpace,iconHeight+hSpace*2+ySpace))
                                elseif(index<11)then
                                    icon:setPosition(ccp((iconWidth+wSpace)*(10-index)+xSpace,hSpace*1+ySpace))
                                elseif(index==11)then
                                    icon:setPosition(ccp(xSpace,iconHeight+hSpace*2+ySpace))
                                elseif(index==12)then
                                    icon:setPosition(ccp(xSpace,(iconHeight+hSpace)*2+hSpace+ySpace))
                                end
                                if index==self.flickerPosition then
                                    self:showFlicker(index)
                                end
                            end
                           
                        end
                    end
                    
                end
                
               
                
            end

		end

        local topArrowY = 670
        local buttomArrowY = 120
        local leftArrowX = 30
        local rightArrowX = self.bgLayer:getContentSize().width-70
        local arrowY = nil
        local single = 30
        for i=1,4 do
            arrowY = 440 - single * (i - 1)
            local leftArrow
            local rightArrow
            local topArrow
            local buttomArrow
            leftArrow= CCSprite:createWithSpriteFrameName("SlotArow.png")
            rightArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
            topArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
            buttomArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")

            -- if i==1 or i==3 then
            --     leftArrow= CCSprite:createWithSpriteFrameName("SlotArowRed.png")
            --     rightArrow = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
            --     topArrow = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
            --     buttomArrow = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
            -- else
            --     leftArrow= CCSprite:createWithSpriteFrameName("SlotArow.png")
            --     rightArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
            --     topArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
            --     buttomArrow = CCSprite:createWithSpriteFrameName("SlotArow.png")
            -- end

            leftArrow:setPosition(ccp(leftArrowX,arrowY))
            leftArrow:setRotation(180)
            cell:addChild(leftArrow)

            rightArrow:setPosition(ccp(rightArrowX,arrowY))
            cell:addChild(rightArrow)

            arrowX = (self.bgLayer:getContentSize().width-40)/2-40+single * (i - 1)
            topArrow:setPosition(ccp(arrowX,topArrowY))
            topArrow:setRotation(270)
            cell:addChild(topArrow)

            buttomArrow:setPosition(ccp(arrowX,buttomArrowY))
            buttomArrow:setRotation(90)
            cell:addChild(buttomArrow)
        end

        self.leftIcon1 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.leftIcon1:setPosition(ccp(leftArrowX,410))
        self.leftIcon1:setVisible(true)
        self.leftIcon1:setRotation(180)
        cell:addChild(self.leftIcon1)
        self.leftIcon2 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.leftIcon2:setPosition(ccp(leftArrowX,350))
        self.leftIcon2:setVisible(true)
        self.leftIcon2:setRotation(180)
        cell:addChild(self.leftIcon2)

        self.rightIcon1 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.rightIcon1:setPosition(ccp(rightArrowX,440))
        self.rightIcon1:setVisible(true)
        cell:addChild(self.rightIcon1)
        self.rightIcon2 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.rightIcon2:setPosition(ccp(rightArrowX,380))
        self.rightIcon2:setVisible(true)
        cell:addChild(self.rightIcon2)

        self.topIcon1 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.topIcon1:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2-40,670))
        self.topIcon1:setVisible(true)
        self.topIcon1:setRotation(270)
        cell:addChild(self.topIcon1)
        self.topIcon2 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.topIcon2:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2+20,670))
        self.topIcon2:setVisible(true)
        self.topIcon2:setRotation(270)
        cell:addChild(self.topIcon2)

        self.buttomIcon1 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.buttomIcon1:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2-10,120))
        self.buttomIcon1:setVisible(true)
        self.buttomIcon1:setRotation(90)
        cell:addChild(self.buttomIcon1)
        self.buttomIcon2 = CCSprite:createWithSpriteFrameName("SlotArowRed.png")
        self.buttomIcon2:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2+50,120))
        self.buttomIcon2:setVisible(true)
        self.buttomIcon2:setRotation(90)
        cell:addChild(self.buttomIcon2)

        self.playStart=true

        local function touch()
        end
        local capInSet = CCRect(20, 20, 10, 10)
        self.backSprite=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
        self.backSprite:setContentSize(CCSizeMake(220,220))
        self.backSprite:setAnchorPoint(ccp(0.5,0.5))
        self.backSprite:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2,400))
        cell:addChild(self.backSprite,1)
        if self.dice1Num==nil and self.dice2Num==nil then
            self.dice1Num,self.dice2Num = acRepublicHuiVoApi:getDiceNum()
        end

        self.dice1Sp=CCSprite:createWithSpriteFrameName("Dice"..self.dice1Num..".png")
        self.dice1Sp:setAnchorPoint(ccp(0.5,0.5))
        self.dice1Sp:setPosition(ccp(self.backSprite:getContentSize().width/4,self.backSprite:getContentSize().height/2))
        self.backSprite:addChild(self.dice1Sp,2)
        self.dice2Sp=CCSprite:createWithSpriteFrameName("Dice"..self.dice2Num..".png")
        self.dice2Sp:setAnchorPoint(ccp(0.5,0.5))
        self.dice2Sp:setPosition(ccp(self.backSprite:getContentSize().width/4*3,self.backSprite:getContentSize().height/2))
        self.backSprite:addChild(self.dice2Sp,2)

        self.diceNumSp=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,touch)
        self.diceNumSp:setAnchorPoint(ccp(0.5,0.5))
        self.diceNumSp:setPosition(ccp(self.backSprite:getContentSize().width/2,self.backSprite:getContentSize().height/2))
        self.diceNumSp:setContentSize(CCSizeMake(120,120))
        self.backSprite:addChild(self.diceNumSp,100)

        self.diceNumLb=GetTTFLabel(self.dice1Num+self.dice2Num,60)
        self.diceNumLb:setPosition(ccp(self.diceNumSp:getContentSize().width/2,self.diceNumSp:getContentSize().height/2))
        self.diceNumLb:setAnchorPoint(ccp(0.5,0.5))
        self.diceNumSp:addChild(self.diceNumLb)
        self.diceNumLb:setColor(G_ColorYellow)
        if self.showRowNum== false then
            self.diceNumSp:setVisible(false)
        end

        local vo=acRepublicHuiVoApi:getAcVo()

            local free=0                            --是否是第一次免费
            if acRepublicHuiVoApi:isRouletteToday()==true then
                free=1
            end
            local gemCost=acRepublicHuiVoApi:getLotteryCommonCost()--cfg.serverreward.gemCost
            local oneGems=gemCost               --一次抽奖需要金币
            local tenGems=acRepublicHuiVoApi:getLotterySuperCost()          --十次抽奖需要金币

             local leftPosX=self.bgLayer:getContentSize().width/2-170
            local rightPosX=self.bgLayer:getContentSize().width/2+130

            local lbY=80
            self.goldSp1=CCSprite:createWithSpriteFrameName("Ticket.png")
            self.goldSp1:setAnchorPoint(ccp(1,0.5))
            self.goldSp1:setPosition(ccp(leftPosX-10,lbY))
            cell:addChild(self.goldSp1)
            self.goldSp1:setScale(0.5)

            self.gemsLabel1=GetTTFLabel(oneGems,25)
            self.gemsLabel1:setAnchorPoint(ccp(0,0.5))
            self.gemsLabel1:setPosition(ccp(leftPosX,lbY))
            cell:addChild(self.gemsLabel1,1)

            local goldSp2=CCSprite:createWithSpriteFrameName("Ticket.png")
            goldSp2:setAnchorPoint(ccp(1,0.5))
            goldSp2:setPosition(ccp(rightPosX-10,lbY))
            cell:addChild(goldSp2)
            goldSp2:setScale(0.5)

            local gemsLabel2=GetTTFLabel(tenGems,25)
            gemsLabel2:setAnchorPoint(ccp(0,0.5))
            gemsLabel2:setPosition(ccp(rightPosX,lbY))
            cell:addChild(gemsLabel2,1)
            local function btnCallback(tag,object)
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end 

                PlayEffect(audioCfg.mouseClick)

                self.tag=tag
                if acRepublicHuiVoApi:isRouletteToday()==true then
                    free=1
                end
                self.flickerPosition=acRepublicHuiVoApi:getflickerPosition()
                if self.rewardIconList and SizeOfTable(self.rewardIconList)>0 then
                    for k,v in pairs(self.rewardIconList) do
                        if k and v and k~=self.flickerPosition then
                            self:hideFlicker(k)
                        end
                    end
                end
                --self.tv:reloadData()
                

                local function lotteryCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData.data==nil then
                            do return end
                        end
                        if sData.numTab and type(sData.numTab)=="table" and sData.numTab[1]~=nil and sData.numTab[2]~=nil
                            then

                            self.dice1Num,self.dice2Num=sData.numTab[1],sData.numTab[2]
                        end
                        local rowNum = self.dice1Num+self.dice2Num
                        self.reward={}
                        if tag==1 then
                            if free==1 then
                                playerVoApi:setValue("gems",playerVoApi:getGems()-oneGems)
                            end
                            if (rowNum+self.flickerPosition)>12 then 
                                table.insert(self.reward,self.rewardList[(rowNum+self.flickerPosition)-12])
                            else
                                table.insert(self.reward,self.rewardList[rowNum+self.flickerPosition])
                            end
                        elseif tag==2 then
                            playerVoApi:setValue("gems",playerVoApi:getGems()-tenGems)
                            for i=(self.flickerPosition+1),(self.flickerPosition+rowNum) do
                                local pos = i
                                if pos >12 then
                                    pos = pos-12
                                end
                                table.insert(self.reward,self.rewardList[pos])
                            end
                        end

                       for k,v in pairs(self.reward) do
                            if v.type=="mm" then
                                acRepublicHuiVoApi:updatePartNum(v.num,v.key)
                            else
                                 G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
                            end
                        end
                        if free==0 and sData.ts then
                            acRepublicHuiVoApi:setLastListTime(sData.ts)
                            self.isToday=acRepublicHuiVoApi:isRouletteToday()
                        end
                        if sData.location then 
                            acRepublicHuiVoApi:setflickerPosition(sData.location)
                        end
                        self.dicePlay=true
                        self:dicePlayTick()
                        self.btnShow=false
                        if self.btnShow==false then
                            self.lotteryOneBtn:setEnabled(false)
                            self.lotteryTenBtn:setEnabled(false)
                        end
                        if free==0 then
                            self.goldSp1:setVisible(true)
                            self.gemsLabel1:setString(oneGems)
                            self.gemsLabel1:setPosition(leftPosX,lbY)
                        end

                    end

                   
                end

                if tag==1 and free==0 then
                    socketHelper:activityRepublicHuiReward((tag-1),lotteryCallback)
                else
                    if self.isLottery==true then
                        do return end
                    end
                    self.isLottery=true
                    local needPro
                    if tag==1 then
                        needPro=oneGems
                    else
                        needPro=tenGems
                    end
                    local function cancleCallBack( ... )
                        self.isLottery=false
                    end
                    local function touchBuy( ... )
                        if tag==1 then
                            if free==1 and playerVoApi:getGems()<oneGems then
                                self.isLottery=false
                                GemsNotEnoughDialog(nil,nil,oneGems-playerVoApi:getGems(),self.layerNum+1,oneGems)
                                do return end
                            end
                            
                        elseif tag==2 then
                            if playerVoApi:getGems()<tenGems then
                                self.isLottery=false
                                GemsNotEnoughDialog(nil,nil,tenGems-playerVoApi:getGems(),self.layerNum+1,tenGems)
                                do return end
                            end
                    
                         end
                        socketHelper:activityRepublicHuiReward((tag-1),lotteryCallback)
                    end 

                    local smallD=smallDialog:new()
                    smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("activity_republicHui_notEnough",{needPro,needPro,getlocal("activity_republicHui_propName")}),nil,self.layerNum+1,nil,nil,cancleCallBack)
                end
                
                
                
            end


           
            local btnY=20
            self.lotteryOneBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",btnCallback,1,getlocal("activity_republicHui_commonBtn"),25)
            self.lotteryOneBtn:setAnchorPoint(ccp(0.5,0.5))
            local lotteryMenu=CCMenu:createWithItem(self.lotteryOneBtn)
            lotteryMenu:setPosition(ccp(leftPosX,btnY))
            lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
            cell:addChild(lotteryMenu,2)

            self.lotteryTenBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",btnCallback,2,getlocal("activity_republicHui_superBtn"),25)
            self.lotteryTenBtn:setAnchorPoint(ccp(0.5,0.5))
            local lotteryMenu1=CCMenu:createWithItem(self.lotteryTenBtn)
            lotteryMenu1:setPosition(ccp(rightPosX,btnY))
            lotteryMenu1:setTouchPriority(-(self.layerNum-1)*20-3)
            cell:addChild(lotteryMenu1,2)

            if free==0 then
                self.goldSp1:setVisible(false)
                self.lotteryTenBtn:setEnabled(false)
                self.gemsLabel1:setString(getlocal("daily_lotto_tip_2"))
                self.gemsLabel1:setPosition(leftPosX-25,lbY)
            else
                self.goldSp1:setVisible(true)
                self.lotteryTenBtn:setEnabled(true)
                self.gemsLabel1:setString(oneGems)
                self.gemsLabel1:setPosition(leftPosX,lbY)
            end
            if self.btnShow==false then
                self.lotteryOneBtn:setEnabled(false)
                self.lotteryTenBtn:setEnabled(false)
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
function acRepublicHuiDialog:dicePlayTick()
    local pzArr1=CCArray:create()
    local pzArr2=CCArray:create()
    for kk=1,6 do
        local nameStr="DicePlay0"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        pzArr1:addObject(frame)
        pzArr2:addObject(frame)
    end
    local animation=CCAnimation:createWithSpriteFrames(pzArr1)
    animation:setDelayPerUnit(0.1)
    local animate=CCAnimate:create(animation)
    local repeatForever=CCRepeatForever:create(animate)
    self.dice1Sp:runAction(repeatForever)

    local animation2=CCAnimation:createWithSpriteFrames(pzArr2)
    animation2:setDelayPerUnit(0.1)
    local animate2=CCAnimate:create(animation2)
    local repeatForever2=CCRepeatForever:create(animate2)
    self.dice2Sp:runAction(repeatForever2)

    --self.tickIndex=5
    self.diceEnd=0
    --base:addNeedRefresh(self)
end
function acRepublicHuiDialog:play()
    self.tickInterval=30
    self.tickConst=30
    self.intervalNum=5--fasttick间隔 3帧一次
    self.haloPos=self.flickerPosition
    self.showRowNum= true
    self.diceNumSp:setVisible(true)
    self.rowNum=self.dice1Num+self.dice2Num
    self.diceNumLb:setString(self.rowNum)
    if (self.dice1Num+self.dice2Num+self.haloPos)>12 then
        self.endIdx =tonumber((self.dice1Num+self.dice2Num+self.haloPos)-12)
    else
        self.endIdx =tonumber(self.dice1Num+self.dice2Num+self.haloPos)
    end
    -- if self.endIdx then
    --     base:addNeedRefresh(self)
    -- -- else
    -- --     self:refresh()
    -- --     self.tv:reloadData()
    -- end

end

function acRepublicHuiDialog:fastTick()

    if self.playStart==true then
        self.arrowIndex=self.arrowIndex-1
        if self.arrowIndex<=0 then 
            self.arrowIndex=60
            if self.ArrowPlay==false then 
                self.ArrowPlay=true
                self.leftIcon1:setPosition(ccp(30,410))
                self.leftIcon2:setPosition(ccp(30,350))
                self.rightIcon1:setPosition(ccp(self.bgLayer:getContentSize().width-70,440))
                self.rightIcon2:setPosition(ccp(self.bgLayer:getContentSize().width-70,380))
                self.topIcon1:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2-40,670))
                self.topIcon2:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2+20,670))
                self.buttomIcon1:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2-10,120))
                self.buttomIcon2:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2+50,120))
            else
                self.ArrowPlay=false
                self.leftIcon1:setPosition(ccp(30,440))
                self.leftIcon2:setPosition(ccp(30,380))
                self.rightIcon1:setPosition(ccp(self.bgLayer:getContentSize().width-70,410))
                self.rightIcon2:setPosition(ccp(self.bgLayer:getContentSize().width-70,350))
                self.topIcon1:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2-10,670))
                self.topIcon2:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2+50,670))
                self.buttomIcon1:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2-40,120))
                self.buttomIcon2:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2+20,120))
            end
        end
    end
    

    
    if self.dicePlay== true then
        --self.tickIndex=self.tickIndex-1
        self.diceEnd=self.diceEnd+1
       -- if self.tickIndex<=0 then
       --     self.tickIndex=5
       --      local random1 = math.random(1,6)
       --      local random2 = math.random(1,6)

       --      self.dice1Sp:removeFromParentAndCleanup(true)
       --      self.dice2Sp:removeFromParentAndCleanup(true)
       --      self.dice1Sp=CCSprite:createWithSpriteFrameName("Dice"..random1..".png")
       --      self.dice1Sp:setAnchorPoint(ccp(0.5,0.5))
       --      self.dice1Sp:setPosition(ccp(self.backSprite:getContentSize().width/4,self.backSprite:getContentSize().height/2))
       --      self.dice2Sp=CCSprite:createWithSpriteFrameName("Dice"..random2..".png")
       --      self.dice2Sp:setAnchorPoint(ccp(0.5,0.5))
       --      self.dice2Sp:setPosition(ccp(self.backSprite:getContentSize().width/4*3,self.backSprite:getContentSize().height/2))

       --      self.backSprite:addChild(self.dice1Sp)
       --      self.backSprite:addChild(self.dice2Sp)


            

            if self.diceEnd==60 then 
                local function playEndCallback()
                    self.dice1Sp:removeFromParentAndCleanup(true)
                    self.dice2Sp:removeFromParentAndCleanup(true)
                    self.dice1Sp=CCSprite:createWithSpriteFrameName("Dice"..self.dice1Num..".png")
                    self.dice1Sp:setAnchorPoint(ccp(0.5,0.5))
                    self.dice1Sp:setPosition(ccp(self.backSprite:getContentSize().width/4,self.backSprite:getContentSize().height/2))
                    self.dice2Sp=CCSprite:createWithSpriteFrameName("Dice"..self.dice2Num..".png")
                    self.dice2Sp:setAnchorPoint(ccp(0.5,0.5))
                    self.dice2Sp:setPosition(ccp(self.backSprite:getContentSize().width/4*3,self.backSprite:getContentSize().height/2))

                    self.backSprite:addChild(self.dice1Sp)
                    self.backSprite:addChild(self.dice2Sp)
                    self.dicePlay=false
                    --base:removeFromNeedRefresh(self)
                    local function playDelayEnd()
                        self.flickerPlay=true
                        self:play()
                    end
                    local delay=CCDelayTime:create(0.5)
                    local callFunc=CCCallFuncN:create(playDelayEnd)
                
                    local acArr=CCArray:create()
                    acArr:addObject(delay)
                    acArr:addObject(callFunc)
                    local seq=CCSequence:create(acArr)
                    self.bgLayer:runAction(seq) 
                    
                end
                local delay=CCDelayTime:create(0.5)
                local callFunc=CCCallFuncN:create(playEndCallback)
                
                local acArr=CCArray:create()
                acArr:addObject(delay)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)
                self.bgLayer:runAction(seq) 
            end

            
        --end
    elseif self.flickerPlay==true then
        if self.rowNum==nil or (self.rowNum and self.rowNum<=0) then
            do return end
        end
        -- self.tickIndex=self.tickIndex+1
        self.tickInterval=self.tickInterval-1
        if(self.tickInterval<=0)then
            self.tickInterval=self.tickConst
            self.rowNum= self.rowNum-1
            self.diceNumLb:setString(self.rowNum)
            self.haloPos=self.haloPos+1
            local pos = self.haloPos
            if(pos>12)then
                pos=pos-12
            end
            if self.tag ==1 then
                if pos==1 then
                    self:hideFlicker(12)
                else
                    self:hideFlicker(pos-1)
                end

                self:showFlicker(pos)
            elseif self.tag==2 then
                if (self.haloPos-1)==self.flickerPosition then
                    self:hideFlicker(self.flickerPosition)
                end
                self:showFlicker(pos)
            end

            if self.rowNum==1 then
                local function playEnd()
                    self.flickerPlay=false
                    --base:removeFromNeedRefresh(self)
                    self:playEndEffect()
                end
                local delay=CCDelayTime:create(0.5)
                local callFunc=CCCallFuncN:create(playEnd)
                
                local acArr=CCArray:create()
                acArr:addObject(delay)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)
                self.bgLayer:runAction(seq) 
            end


        end
    end
    
end
function acRepublicHuiDialog:playEndEffect( ... )
    self.flickerPosition = acRepublicHuiVoApi:getflickerPosition()
    local partTable={}
    local str = ""
    if self.reward and SizeOfTable(self.reward)>0 then
        str = getlocal("daily_lotto_tip_10")
        for k,v in pairs(self.reward) do
            if v.type=="mm" then
                partTable[k]=v
            end
            if k==SizeOfTable(self.reward) then
                str = str .. v.name .. " x" .. v.num
            else
                str = str .. v.name .. " x" .. v.num .. ","
            end
        end
    end
    if str and str~="" then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)
    end

    for k,v in pairs(partTable) do
        if v then
            local pieceSp=CCSprite:createWithSpriteFrameName("BattleParts1.png")
            local icon = self.rewardIconList[v.index]
            pieceSp:setAnchorPoint(ccp(0.5,0.5))
            pieceSp:setPosition(ccp(icon:getPositionX()+50,icon:getPositionY()+50))
            self.bgLayer:addChild(pieceSp,1000)

            local function playEndCallback1()
                pieceSp:removeFromParentAndCleanup(true)
                pieceSp=nil
                self:refresh()

            end
            local callFunc=CCCallFuncN:create(playEndCallback1)

            local function hideLight()
            end
            local callFunc1=CCCallFuncN:create(hideLight)

            local delay=CCDelayTime:create(0.5)
            local mvTo0=CCMoveTo:create(0.5,ccp(self.bgLayer:getContentSize().width-100,G_VisibleSize.height-270))
            local scaleTo=CCScaleTo:create(0.2,2)
            local scaleTo1=CCScaleTo:create(0.3,0.2)

            local acArr=CCArray:create()
            acArr:addObject(delay)
            acArr:addObject(callFunc1)
            acArr:addObject(mvTo0)

            acArr:addObject(scaleTo)
            acArr:addObject(scaleTo1)
            acArr:addObject(callFunc)
            local seq=CCSequence:create(acArr)
            pieceSp:runAction(seq)
        end
    end
    self.isLottery=false
    self.showRowNum= false
    self.diceNumSp:setVisible(false)
    self.btnShow=true
    if self.btnShow==true then
        self.lotteryOneBtn:setEnabled(true)
        self.lotteryTenBtn:setEnabled(true)
    end
    --activityVoApi:updateShowState(vo)
    
    --self.tv:reloadData()
end

function acRepublicHuiDialog:showFlicker(i)
    if newGuidMgr:isNewGuiding() then
        do return end
    end
    local icon = self.rewardIconList[i]
    if icon then
        local iconSize=100
        local flicker = icon:getChildByTag(501)
        if flicker==nil then
            local pzFrameName="RotatingEffect1.png"
            flicker=CCSprite:createWithSpriteFrameName(pzFrameName)
            local m_iconScaleX=(iconSize+8)/flicker:getContentSize().width
            local m_iconScaleY=(iconSize+8)/flicker:getContentSize().height
            local pzArr=CCArray:create()
            for kk=1,20 do
                local nameStr="RotatingEffect"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
            end
            local animation=CCAnimation:createWithSpriteFrames(pzArr)
            animation:setDelayPerUnit(0.1)
            local animate=CCAnimate:create(animation)
            flicker:setAnchorPoint(ccp(0.5,0.5))
            flicker:setScaleX(m_iconScaleX)
            flicker:setScaleY(m_iconScaleY)
            flicker:setPosition(ccp(icon:getContentSize().width/2,icon:getContentSize().height/2))
            icon:addChild(flicker,501)
            local repeatForever=CCRepeatForever:create(animate)
            flicker:runAction(repeatForever)
            -- flicker=G_addRectFlicker(icon,m_iconScaleX,m_iconScaleY)
            self.flickerList[i]=flicker
        else
            flicker:setPosition(ccp(icon:getContentSize().width/2,icon:getContentSize().height/2))
            if flicker:isVisible()==false then
                flicker:setVisible(true)
                local pzArr=CCArray:create()
                for kk=1,20 do
                    local nameStr="RotatingEffect"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    pzArr:addObject(frame)
                end
                local animation=CCAnimation:createWithSpriteFrames(pzArr)
                animation:setDelayPerUnit(0.1)
                local animate=CCAnimate:create(animation)
                local repeatForever=CCRepeatForever:create(animate)
                flicker:runAction(repeatForever)
            end
        end
    end
end
function acRepublicHuiDialog:hideFlicker(i)
    if self and self.flickerList then
        for k,v in pairs(self.flickerList) do
            if k==i and v then 
                local sp = tolua.cast(v,"CCSprite")
                if sp then
                    sp:setVisible(false)
                end
            end
        end
    end
end


function acRepublicHuiDialog:refresh( ... )
	self.hadPieceNum = acRepublicHuiVoApi:getHadPieceNum()
    -- self.needPieceNum,selfTankNum = acRepublicHuiVoApi:getNeedPieceNum()
    if self.pieceNumLb then
    	self.pieceNumLb:setString(getlocal("scheduleChapter",{self.hadPieceNum,self.needPieceNum}))
    end
    if acRepublicHuiVoApi:canComposeTank()==false then
		self.composeItem:setEnabled(false)
	else
		self.composeItem:setEnabled(true)
	end
end

function acRepublicHuiDialog:tick()
    local vo=acRepublicHuiVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    local today=acRepublicHuiVoApi:isRouletteToday()
    if self.isToday~=today then
        self.isToday=today
        self.tv:reloadData()
    end
    if self.timeLb then
        G_updateActiveTime(vo,self.timeLb)
    end
end

function acRepublicHuiDialog:dispose()
    self.rewardIconList={}
    self.rewardList={}
    self.flickerList={}
    self.isToday=nil
    self.showRowNum= false
    self.dicePlay=false
    self.flickerPlay=false
    self.btnShow=true
    self.playStart=false
    self.isLottery=false
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acRepublicHui.plist")
end

