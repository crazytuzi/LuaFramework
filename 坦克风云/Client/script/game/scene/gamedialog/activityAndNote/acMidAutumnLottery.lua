acMidAutumnLottery=commonDialog:new()

function acMidAutumnLottery:new()
	local nc={}
    nc.bgLayer=nil
    nc.forbidLayer=nil
    nc.showList={}
    nc.cellNum=0
    nc.cellHeight=110
    nc.blessPropCost={}
    nc.costLb={}
    nc.isEnd=false
    nc.onceBlessBtn=nil
    nc.tenBlessBtn=nil
    nc.infoHeight=150
    nc.effectPosTb={{123,81,89,218,173,252},{300,81,289,174,329,231},{477,81,494,227,369,258}}
    nc.effectEndPos={246,292}
    nc.midautumnNode=nil
    nc.flick=nil
    nc.lotteryCallBack=nil
    nc.actionNode=nil
    nc.propSize=80
    nc.url=G_downloadUrl("active/".."midautumn/".."acmidautumn_bg.jpg")
    nc.version=acMidAutumnVoApi:getVersion()
	setmetatable(nc, self)
	self.__index=self

	return nc
end	

function acMidAutumnLottery:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent

    self:initTableView()
    self:initLayer()

    return self.bgLayer
end

function acMidAutumnLottery:initTableView()
    self.showList=acMidAutumnVoApi:getRewardShowList()
    self.cellNum=SizeOfTable(self.showList)
    self.blessPropCost=acMidAutumnVoApi:getOnceBlessPropCost()
    self.isEnd=acMidAutumnVoApi:acIsStop()
    self.flick=acMidAutumnVoApi:getFlick()
    if G_isIphone5()==true then
        self.propSize=100
    end
end

function acMidAutumnLottery:eventHandler(handler,fn,idx,cel)
     if fn=="numberOfCellsInTableView" then     
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.cellNum*self.propSize+(self.cellNum-1)*10+20,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local iconSize=self.propSize
        local flickScale=1.3
        for k,v in pairs(self.showList) do
            local icon,iconScale
            if v.type == "p" and (v.key == "p1357" or v.key == "p4944") then
                icon,iconScale=G_getItemIcon(v,iconSize,false,self.layerNum,function ()
                    propInfoDialog:create(sceneGame,v,self.layerNum+1)
                end,self.tv)
            else
                icon,iconScale=G_getItemIcon(v,iconSize,true,self.layerNum,nil,self.tv)
            end
            icon:setTouchPriority(-(self.layerNum-1)*20-4)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(10+(k-1)*(iconSize+10),self.cellHeight/2)
            cell:addChild(icon)

            local num=GetTTFLabel("x"..FormatNumber(v.num),20/iconScale)
            num:setAnchorPoint(ccp(1,0))
            num:setPosition(icon:getContentSize().width-10,10)
            icon:addChild(num)

            if self.flick[k] and self.flick[k]==1 then
                if v.type == "h" and v.eType == "s" then
                    flickScale=1.94
                else
                    flickScale=1.3
                end
                G_addRectFlicker(icon,flickScale,flickScale,ccp(icon:getContentSize().width/2,icon:getContentSize().height/2))
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

function acMidAutumnLottery:resetTab()
    -- self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight-100))
    -- self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
end

function acMidAutumnLottery:initLayer()
    local strSize=25
    if G_getCurChoseLanguage()=="ru" then
        strSize=22
    end
    local backSprite=CCNode:create()
    backSprite:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-340))
    backSprite:setAnchorPoint(ccp(0.5,0))
    backSprite:setPosition(ccp(G_VisibleSizeWidth/2,30))
    self.bgLayer:addChild(backSprite,1)
    local bgSize=backSprite:getContentSize()

    local showH=140
    local showAddH=0
    local offsetH=0
    if G_isIphone5()==true then
        showH=180
        offsetH=40
        showAddH=-20
    end
    local function nilFunc()
    end
    local showbg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),nilFunc)
    showbg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,showH))
    showbg:setAnchorPoint(ccp(0.5,1))
    showbg:setPosition(ccp(bgSize.width/2,bgSize.height+showAddH))
    backSprite:addChild(showbg)
    local showbgSize=showbg:getContentSize()
    local titleTb={getlocal("spread"),25,G_ColorYellow}
    local titleLbSize=CCSizeMake(300,0)
    local titleBg,titleL,subHeight=G_createNewTitle(titleTb,titleLbSize,nil,true)
    titleBg:setPosition(showbgSize.width/2,showbgSize.height - 40)
    showbg:addChild(titleBg)
    self.cellHeight=showbg:getContentSize().height-titleBg:getContentSize().height*titleBg:getScaleY()

    local function callback( ... )
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(showbg:getContentSize().width-80,self.cellHeight),nil)
    self.tv:setPosition(ccp(40,0))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    showbg:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

    local midautumnNode=CCNode:create()
    midautumnNode:setAnchorPoint(ccp(0.5,1))
    midautumnNode:setContentSize(CCSizeMake(600,379))
    midautumnNode:setPosition(ccp(showbg:getContentSize().width/2,showbg:getPositionY()-showbgSize.height-5-offsetH))
    backSprite:addChild(midautumnNode,5)
    self.midautumnNode=midautumnNode
    local midautumnNodeSize=midautumnNode:getContentSize()

    local iconPos=ccp(showbg:getContentSize().width/2,showbg:getPositionY()-showbgSize.height-5-offsetH)
    local function onLoadIcon(fn,icon)
        if self and self.midautumnNode then
            if backSprite then
                icon:setAnchorPoint(ccp(0.5,1))
                backSprite:addChild(icon)
                icon:setPosition(iconPos)
            end
        end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local moonSp=CCSprite:createWithSpriteFrameName("acmidautumn_moon1.png")
    moonSp:setPosition(ccp(self.effectEndPos[1],self.effectEndPos[2]))
    midautumnNode:addChild(moonSp)

    local function rewardRecordsHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:recordHandler()
    end
    local recordBtn=GetButtonItem("hero_infoBtn.png","hero_infoBtn.png","hero_infoBtn.png",rewardRecordsHandler,11,nil,nil)
    recordBtn:setScale(0.8)
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setAnchorPoint(ccp(0,1))
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(50,midautumnNodeSize.height-60))
    midautumnNode:addChild(recordMenu)
    local recordBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    recordBg:setAnchorPoint(ccp(0.5,1))
    recordBg:setContentSize(CCSizeMake(100,40))
    recordBg:setPosition(ccp(recordBtn:getContentSize().width/2,0))
    recordBg:setScale(1/recordBtn:getScale())
    recordBtn:addChild(recordBg)
    local recordLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setPosition(recordBg:getContentSize().width/2,recordBg:getContentSize().height/2)
    recordLb:setColor(G_ColorYellowPro)
    recordBg:addChild(recordLb)

    local blessPointStr=getlocal("bless_point").."："..acMidAutumnVoApi:getBlessPoint()
    local blessPointLb=GetTTFLabelWrap(blessPointStr,25,CCSize(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    local tempLb=GetTTFLabel(blessPointStr,25)
    local lbW=tempLb:getContentSize().width
    if lbW>blessPointLb:getContentSize().width then
        lbW=blessPointLb:getContentSize().width
    end
    local pointBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    pointBg:setAnchorPoint(ccp(1,1))
    pointBg:setContentSize(CCSizeMake(lbW+40,blessPointLb:getContentSize().height+20))
    pointBg:setPosition(ccp(midautumnNodeSize.width-20,midautumnNodeSize.height-30))
    midautumnNode:addChild(pointBg)

    blessPointLb:setPosition(pointBg:getContentSize().width/2,pointBg:getContentSize().height/2)
    pointBg:addChild(blessPointLb)
    self.blessPointLb=blessPointLb

    local btnAddH=0
    if G_isIphone5()==true then
        btnAddH=20
    end
    local function onceBlessHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:blessHandler(1)
    end
    local onceblessStr = self.version == 3 and getlocal("once_bless_v2") or getlocal("once_bless")
    local onceBlessBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onceBlessHandler,nil,onceblessStr,strSize/0.7,11)
    onceBlessBtn:setAnchorPoint(ccp(0.5,0))
    onceBlessBtn:setScale(0.7)
    local onceBlessMenu=CCMenu:createWithItem(onceBlessBtn)
    onceBlessMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    onceBlessMenu:setPosition(ccp(bgSize.width/2-150,10+btnAddH))
    backSprite:addChild(onceBlessMenu)
    self.onceBlessBtn=onceBlessBtn

    local function tenBlessHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:blessHandler(2)
    end
    local tenBlessBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",tenBlessHandler,nil,getlocal("ten_bless"),strSize/0.7,11)
    tenBlessBtn:setAnchorPoint(ccp(0.5,0))
    tenBlessBtn:setScale(0.7)
    local tenBlessMenu=CCMenu:createWithItem(tenBlessBtn)
    tenBlessMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    tenBlessMenu:setPosition(ccp(bgSize.width/2+150,10+btnAddH))
    backSprite:addChild(tenBlessMenu)
    self.tenBlessBtn=tenBlessBtn
    if self.isEnd==true then
        self.onceBlessBtn:setEnabled(false)
        self.tenBlessBtn:setEnabled(false)
    end

    local propCount=SizeOfTable(self.blessPropCost)
    for k,prop in pairs(self.blessPropCost) do
        local function callback()
            --跳转到任务标签
            local function goHandler()
                if self.parent and self.parent.goTaskDialog then
                    self.parent:goTaskDialog()
                end
            end
            propInfoDialog:create(sceneGame,prop,self.layerNum+1,nil,true,nil,nil,nil,nil,nil,nil,nil,getlocal("propInfoCostNum", {prop.num}),nil,getlocal("accessory_get"),goHandler)
        end
        local posX=self.effectPosTb[k][1]
        local posY=self.effectPosTb[k][2]
        local icon,iconScale=G_getItemIcon(prop,100,false,self.layerNum,callback)
        icon:setTouchPriority(-(self.layerNum-1)*20-5)
        icon:setPosition(posX,posY)
        self.midautumnNode:addChild(icon)
        local num=bagVoApi:getItemNumId(prop.id)
        local numLb=GetTTFLabel("x"..FormatNumber(num),25/iconScale)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(icon:getContentSize().width-5,5)
        icon:addChild(numLb)

        self.costLb[prop.key]=numLb
    end
end

function acMidAutumnLottery:blessHandler(blessType)
    local multiplier
    local num=1
    if tonumber(blessType)==1 then
        multiplier=1
        num=1
    elseif tonumber(blessType)==2 then
        multiplier=acMidAutumnVoApi:getMultiplier()
        num=10
    end
    if multiplier==nil then
        do return end
    end
    local function realLottery(lotteryType,cost,costProp)
        local function callback(lotteryFlag,report,oldHeroList)
            if lotteryFlag==false then
                self:removeForbidLayer()
                do return end
            end
            if report and type(report)=="table" then
                local rewardlist = {}
                local addStrTb = {}
                local content={}
                local msgContent={}
                local heroExistStr=""
                local allPoint=0
                for k,v in pairs(report) do
                    local reward=FormatItem(v[1])[1]
                    local point=tonumber(v[2])
                    allPoint=allPoint+point
                    table.insert(content,{award=reward})
                    local tempReward=FormatItem(v[1],nil,true)[1]
                    table.insert(rewardlist,tempReward)
                    table.insert(addStrTb,getlocal("midautumn_bless_point",{point or 0}))
                    local existStr=""
                    local showStr=""
                    local color=G_ColorWhite

                    if reward.type=="h" then
                        local type,heroIsExist,addNum,newProductOrder=heroVoApi:getNewHeroData(reward,oldHeroList)
                        if heroIsExist==true then
                            if heroVoApi:heroHonorIsOpen()==true and  heroVoApi:getIsHonored(reward.key)==true then
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
                            heroExistStr=getlocal("congratulationsGet",{reward.name})..existStr
                        elseif heroIsExist==false then
                            local tmp_eType = string.sub(reward.key,1,1)
                            if tmp_eType == "s" then
                                -- 将魂
                                heroVoApi:addSoul(reward.key, reward.num)
                            else
                                -- 将领
                                local vo=heroVo:new()
                                vo.hid=reward.key
                                vo.level=1
                                vo.points=0
                                vo.productOrder=reward.num
                                vo.skill={}
                                table.insert(oldHeroList,vo)

                                if vo.productOrder and vo.productOrder>=2 then
                                    local star=heroVoApi:getHeroStars(vo.productOrder)
                                    local name=heroVoApi:getHeroName(vo.hid)
                                    local message={key="activity_mjpy_notice",param={playerVoApi:getPlayerName(),getlocal("activity_mingjiangpeiyang_title"),star,name}}
                                    chatVoApi:sendSystemMessage(message)
                                end
                            end
                        end
                        showStr=getlocal("congratulationsGet",{reward.name})..existStr
                        color=G_ColorYellowPro
                    else
                        showStr=getlocal("congratulationsGet",{reward.name .. "*" .. FormatNumber(reward.num)})
                    end
                    showStr=showStr.."，"..getlocal("midautumn_lottery_bless_prompt2",{point})
                    table.insert(msgContent,{showStr,color})
                    G_addPlayerAward(reward.type,reward.key,reward.id,reward.num,nil,true)
                end
                if cost and tonumber(cost)>0 then
                    playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(cost))
                end
                if costProp then
                    for k,v in pairs(costProp) do
                        bagVoApi:useItemNumId(v.propId,v.cost)
                    end
                end
                local function showRewards()
                    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
                    local onceblessStr = self.version == 3 and getlocal("once_bless_v2") or getlocal("once_bless")
                    local titleStr=onceblessStr..getlocal("award")
                    local titleStr2 = self.version == 3 and getlocal("midautumn_lottery_bless_prompt_v2",{allPoint}) or getlocal("midautumn_lottery_bless_prompt",{allPoint})
                    local function showEndHandler()
                    end
                    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,rewardlist,showEndHandler,titleStr,titleStr2,addStrTb,nil,"")
                    self:removeForbidLayer()
                    self.lotteryCallBack=nil
                    self.actionNode=nil
                end
                self.lotteryCallBack=showRewards
                -- showRewards()
                self:playeLotteryEffect(showRewards)
                self:refresh()
            end
        end
        acMidAutumnVoApi:midAutumnRequest(4,lotteryType,callback)
        local function speedUp()
            self:removeLotteryEffect()
            if self.lotteryCallBack then
                self.lotteryCallBack()
            end
        end
        self:addForbidLayer(speedUp)
    end
    local islack=false
    local lackPropStr="" --缺少的道具
    local costGems=0
    local costProp={}
    local propCount=SizeOfTable(self.blessPropCost)
    for k,prop in pairs(self.blessPropCost) do
        local propNum=bagVoApi:getItemNumId(prop.id)
        local costNum=prop.num*multiplier
        local lackNum=costNum-propNum
        if lackNum>0 then
            local nameStr=prop.name
            if prop.type=="c" then
                nameStr=getlocal(prop.name,{lackNum})
            end
            if k==propCount then
                lackPropStr=lackPropStr..nameStr.." x"..lackNum
            else
                lackPropStr=lackPropStr..nameStr.." x"..lackNum.."，"
            end
            costGems=costGems+lackNum*propCfg[prop.key].gemCost
            islack=true
            costNum=propNum
        end
        table.insert(costProp,{propId=prop.id,cost=costNum})
    end
    if lackPropStr~="" and islack==true then
        local title=getlocal("dialog_title_prompt")
        local promptStr=getlocal("bless_lack_propStr",{lackPropStr,costGems})
        local function callBack()
            if playerVoApi:getGems()<costGems then
                GemsNotEnoughDialog(nil,nil,costGems-playerVoApi:getGems(),self.layerNum+1,costGems)
                do return end
            else
                realLottery(num,costGems,costProp)
            end
        end
        local lackDialog=smallDialog:new()
        lackDialog:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,title,promptStr,nil,self.layerNum+1)
    else
        realLottery(num,0,costProp)
    end
end

function acMidAutumnLottery:recordHandler()
    local function callback(hasLog,log)
        local function showNoRecord()
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_huoxianmingjiang_log_tip0"),30)
        end
        if hasLog==false or log==nil then
            showNoRecord()
            do return end
        end
        local record={}
        for k,v in pairs(log) do
            reward=v[1]
            reward=FormatItem(reward)
            local rtype=v[3] or 0
            local colorTb={}
            local desc
            if rtype==10 then
                desc=self.version == 3 and getlocal("ten_bless_v2") or getlocal("ten_bless")
                colorTb={G_ColorYellowPro}
            else
                desc=self.version == 3 and getlocal("once_bless_v2") or getlocal("once_bless")
            end
            -- table.insert(record,{award=reward,time=v[2],desc=desc,colorTb=colorTb})

            -- 多个奖励
            local rewardlist = {}
            for rk,rv in pairs(reward) do
                table.insert(rewardlist,rv)
            end
            table.insert(record,{time=v[2],title={desc},content={{rewardlist}},ts=v[2]})
        end
        local function sortFunc(a,b)
            if a and b and a.time and b.time then
                return tonumber(a.time)>tonumber(b.time)
            end
        end
        table.sort(record,sortFunc)
        local recordCount=SizeOfTable(record)
        if recordCount==0 then
            showNoRecord()
            do return end
        end
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
        acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_customLottery_RewardRecode"),G_ColorWhite},record,false,self.layerNum+1,nil,true,10,true,true)
    end
    acMidAutumnVoApi:midAutumnRequest(5,nil,callback)
end

function acMidAutumnLottery:refresh()
    if self.costLb then
        for k,v in pairs(self.costLb) do
            local id=RemoveFirstChar(k)
            local num=bagVoApi:getItemNumId(tonumber(id))
            v:setString("x"..num)
        end
    end
    if self.blessPointLb then
        local point=acMidAutumnVoApi:getBlessPoint()
        local blessPointStr=getlocal("bless_point").."："..point
        self.blessPointLb:setString(blessPointStr)
    end
end

function acMidAutumnLottery:addForbidLayer(touchCallBack)
    local function touch()
       if touchCallBack then
            touchCallBack()
       end
    end
    if self.forbidLayer==nil then
        self.forbidLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touch)
        self.forbidLayer:setTouchPriority(-(self.layerNum-1)*20-8)
        self.forbidLayer:setContentSize(G_VisibleSize)
        self.forbidLayer:setOpacity(0)
        self.forbidLayer:setPosition(getCenterPoint(self.bgLayer))
        self.bgLayer:addChild(self.forbidLayer,10);
    end
end

function acMidAutumnLottery:updateUI()
    self:refresh()
end

function acMidAutumnLottery:removeForbidLayer()
    if self.forbidLayer then
        self.forbidLayer:removeFromParentAndCleanup(true)
        self.forbidLayer=nil
    end
end

function acMidAutumnLottery:playeLotteryEffect(endCallback)
    if self.actionNode then
        do return end
    end
    local endX=self.effectEndPos[1]
    local endY=self.effectEndPos[2]
    local lightTime=1
    local actionNodeSize=self.midautumnNode:getContentSize()
    local actionNode=CCNode:create()
    actionNode:setAnchorPoint(ccp(0.5,0.5))
    actionNode:setContentSize(actionNodeSize)
    actionNode:setPosition(ccp(actionNodeSize.width/2,actionNodeSize.height/2))
    actionNode:setTag(1001)
    self.midautumnNode:addChild(actionNode,5)
    self.actionNode=actionNode
    for k,v in pairs(self.blessPropCost) do
        local startX=self.effectPosTb[k][1]
        local startY=self.effectPosTb[k][2]
        local control_x1=self.effectPosTb[k][3]
        local control_y1=self.effectPosTb[k][4]
        local control_x2=self.effectPosTb[k][5]
        local control_y2=self.effectPosTb[k][6]

        local lightSp=CCSprite:createWithSpriteFrameName("acmidautumn_light.png")
        lightSp:setPosition(ccp(startX,startY))
        -- lightSp:setScale(150/lightSp:getContentSize().width)
        actionNode:addChild(lightSp)
        local bezier=ccBezierConfig()
        bezier.controlPoint_1=ccp(control_x1,control_y1)
        bezier.controlPoint_2=ccp(control_x2,control_y2)
        bezier.endPosition=ccp(endX,endY)
        local bezierEffect=CCBezierTo:create(lightTime,bezier)
        local function clearLight()
            if lightSp then
                lightSp:removeFromParentAndCleanup(true)
                lightSp=nil
            end
        end
        local funcCall=CCCallFuncN:create(clearLight)
        local acArrary=CCArray:create()
        local scaleTo=CCScaleTo:create(lightTime,180/lightSp:getContentSize().width)
        local reduceAc=CCScaleTo:create(lightTime,80/lightSp:getContentSize().width)
        local spwanArr=CCArray:create()
        spwanArr:addObject(bezierEffect)
        spwanArr:addObject(reduceAc)
        local swpanAc=CCSpawn:create(spwanArr)
        local delay=CCDelayTime:create(0.5)
        acArrary:addObject(scaleTo)
        acArrary:addObject(delay)
        acArrary:addObject(swpanAc)
        acArrary:addObject(funcCall)
        local acseq=CCSequence:create(acArrary)
        lightSp:runAction(acseq)
    end
    local moonSp
    local haloSp
    local nodeSize=self.midautumnNode:getContentSize()
    local clipper=CCClippingNode:create()
    clipper:setAnchorPoint(ccp(0.5,0.5))
    clipper:setContentSize(CCSizeMake(nodeSize.width,nodeSize.height-40))
    clipper:setPosition(ccp(nodeSize.width/2,nodeSize.height/2))
    local stencil=CCDrawNode:getAPolygon(CCSizeMake(nodeSize.width,nodeSize.height-40),1,1)
    clipper:setStencil(stencil)
    actionNode:addChild(clipper,6)
    local function actionEndHandler()
        if endCallback then
            if self.actionNode then
                self.actionNode:removeFromParentAndCleanup(true)
                self.actionNode=nil
            end
            endCallback()
        end
    end
    local function callback()
        if moonSp then
            moonSp:removeFromParentAndCleanup(true)
            moonSp=nil
        end
        if haloSp then
            haloSp:removeFromParentAndCleanup(true)
            haloSp=nil
        end
        if clipper then
            clipper:removeFromParentAndCleanup(true)
            clipper=nil
        end
    end
    local function createMoon()
       moonSp=CCSprite:createWithSpriteFrameName("acmidautumn_moon2.png")
       -- moonSp:setScale(120/moonSp:getContentSize().width)
       moonSp:setPosition(ccp(endX,endY))
       actionNode:addChild(moonSp,8)
    end
    local function playHalo()
        haloSp=CCSprite:createWithSpriteFrameName("acmidautumn_light2.png")
        haloSp:setOpacity(98)
        haloSp:setPosition(ccp(endX,endY-20))
        clipper:addChild(haloSp)

        local acArr1=CCArray:create()
        local scaleTo=CCScaleTo:create(0.8,15)
        local effect=CCEaseBounceInOut:create(scaleTo)
        local funcCall=CCCallFuncN:create(callback)
        acArr1:addObject(effect)
        acArr1:addObject(funcCall)
        local subseq1=CCSequence:create(acArr1)
        haloSp:runAction(subseq1)
    end
    local acArr=CCArray:create()
    local delay=CCDelayTime:create(2*lightTime+0.5)
    local funcCall1=CCCallFuncN:create(createMoon)
    local funcCall2=CCCallFuncN:create(playHalo)
    local funcCall3=CCCallFuncN:create(actionEndHandler)
    local delay2=CCDelayTime:create(lightTime)

    acArr:addObject(delay)
    acArr:addObject(funcCall1)
    acArr:addObject(funcCall2)
    acArr:addObject(delay2)
    acArr:addObject(funcCall3)
   
    local subseq=CCSequence:create(acArr)
    self.midautumnNode:runAction(subseq)
end

function acMidAutumnLottery:removeLotteryEffect()
    if self.midautumnNode and self.actionNode then
        self.actionNode:stopAllActions()
        self.actionNode:removeFromParentAndCleanup(true)
        self.actionNode=nil
        self.midautumnNode:stopAllActions()
    end
end

function acMidAutumnLottery:dispose()
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.forbidLayer=nil
    self.showList={}
    self.cellNum=0
    self.cellHeight=110
    self.blessPropCost={}
    self.costLb={}
    self.onceBlessBtn=nil
    self.tenBlessBtn=nil
    self.infoHeight=150
    self.midautumnNode=nil
    self.flick=nil
    self.lotteryCallBack=nil
    self.actionNode=nil
    self.propSize=80
end

function acMidAutumnLottery:tick()
    local isEnd=acMidAutumnVoApi:acIsStop()
    if isEnd~=self.isEnd and isEnd==true then
        self.isEnd=isEnd
        if self.onceBlessBtn and self.tenBlessBtn then
            self.onceBlessBtn:setEnabled(false)
            self.tenBlessBtn:setEnabled(false)  
        end
    end
end