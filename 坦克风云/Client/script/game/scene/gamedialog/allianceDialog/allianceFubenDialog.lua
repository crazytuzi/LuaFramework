allianceFubenDialog=commonDialog:new()

function allianceFubenDialog:new(fid,isBoss)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.fid=fid
    self.challengeBtn=nil

    self.useBtnTab={}
    self.cancelBtnTab={}
    self.usePropTab={}
    self.isBossFu=false
    if isBoss then
        self.isBossFu=isBoss
    end
    self.cellHeightTb={}
    self.allianceBossSp=nil
    self.allianceBossHp=0
    self.damageChangedListener=nil
    self.bossHpProcessSp=nil
    self.bossHpLb=nil
    self.timeLb=nil
    self.degreeLb=nil

    return nc
end

--[[
--设置或修改每个Tab页签
function allianceFubenDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(self.bgSize.width/2-tabBtnItem:getContentSize().width/2,self.bgSize.height-tabBtnItem:getContentSize().height/2)
         elseif index==1 then
         tabBtnItem:setPosition(self.bgSize.width/2+tabBtnItem:getContentSize().width/2,self.bgSize.height-tabBtnItem:getContentSize().height/2)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end
]]

--设置对话框里的tableView
function allianceFubenDialog:initTableView()

    spriteController:addPlist("public/nbSkill2.plist")
    spriteController:addTexture("public/nbSkill2.png")

    local function damageChanged(event,data)
        if self then
            if data==nil or (data and data.changeType==1)then
                -- self:showBossDamageChangeLabel()
            end
            self:refreshBossDamage()
            self.allianceBossHp=allianceFubenVoApi:getAllianceBossHp()
            if self.challengeBtn then
                local attackMaxNum=allianceFubenVoApi:getDailyAttackNum()
                local fubenVo=allianceFubenVoApi:getFuben()

                if self.isBossFu==true and tonumber(self.allianceBossHp)<=0 or (fubenVo.attackCount>=attackMaxNum) then
                    self.challengeBtn:setEnabled(false)
                else
                    self.challengeBtn:setEnabled(true)
                end
            end
        end
    end
    self.damageChangedListener=damageChanged
    eventDispatcher:addEventListener("allianceBossFuben.damageChanged",damageChanged)

    self.allianceBossHp=allianceFubenVoApi:getAllianceBossHp()
    -- self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-180))
    -- self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2)) 

    if self.panelLineBg then
        self.panelLineBg:setVisible(false)
    end
    if self.panelTopLine then
        self.panelTopLine:setVisible(false)
    end
    
    -- 去渐变线
    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,2)
    self.bgLayer:addChild(panelBg)

    local function touch( ... )
        -- body
    end
    local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-180))
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setPosition(ccp(10,95))
    self.bgLayer:addChild(backSprie)


    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-190),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,95))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)

    self:doUserHandler()

    G_AllianceDialogTb["allianceFubenDialog"]=self
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function allianceFubenDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        if self.isBossFu==true then
            return 2
        end
        return 3
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if self.cellHeightTb[idx+1]==nil then
            local height=50
            if idx==0 then
                if self.isBossFu==true then
                    height=200
                else
                    height=450
                end
            elseif idx==1 then
                if self.isBossFu==true then
                    height=450
                else
                    height=200
                end
            elseif idx==2 then
                height=760
            end
            self.cellHeightTb[idx+1]=height
        end
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-20,self.cellHeightTb[idx+1])
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellHeight=self.cellHeightTb[idx+1]
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        return self:cellClick(idx)
        end
        local headSprie=LuaCCSprite:createWithSpriteFrameName("believerTitleBg.png",cellClick)
        headSprie:ignoreAnchorPointForPosition(false)
        headSprie:setAnchorPoint(ccp(0.5,0))
        headSprie:setIsSallow(false)
        headSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        cell:addChild(headSprie)
        headSprie:setPosition(ccp((self.bgLayer:getContentSize().width-20)/2,cellHeight-headSprie:getContentSize().height))

        local headLabel
        if self.isBossFu==true then
            if idx==0 then
                headLabel=GetTTFLabel(getlocal("alliance_challenge_award_title"),30)
                local rewards,addexp=allianceFubenVoApi:getBossFubenRewards()
                local lbExp=GetTTFLabel(getlocal("alliance_challenge_exp",{addexp}),25)
                lbExp:setAnchorPoint(ccp(0.5,0))
                lbExp:setPosition(self.bgLayer:getContentSize().width/2,90)
                cell:addChild(lbExp)
    
                rewards=FormatItem(rewards)
                local rewardsStr=G_showRewardTip(rewards,false,true)
                local rewardsContentLb= GetTTFLabelWrap(getlocal("alliance_all_members")..":"..rewardsStr,25,CCSizeMake(self.bgLayer:getContentSize().width-150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                rewardsContentLb:setAnchorPoint(ccp(0.5,1))
                rewardsContentLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,80))
                cell:addChild(rewardsContentLb)
            elseif idx==1 then
                headLabel=GetTTFLabel(getlocal("alliance_challenge_enemy_info"),30)
                local contentW=self.bgLayer:getContentSize().width-60
                local capInSet = CCRect(20, 20, 10, 10) 
                local function touch()
                end
                local tankBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(20,20,10,10),touch)
                tankBg:setContentSize(CCSizeMake(contentW,250))
                tankBg:ignoreAnchorPointForPosition(false)
                tankBg:setAnchorPoint(ccp(0.5,1))
                tankBg:setPosition(ccp((self.bgLayer:getContentSize().width-20)/2-10,cellHeight-headSprie:getContentSize().height-20))
                tankBg:setIsSallow(false)
                tankBg:setTouchPriority(-(self.layerNum-1)*20-2)
                cell:addChild(tankBg)

                local barHeight=40
                local hpSprite=AddProgramTimer(tankBg,ccp(tankBg:getContentSize().width/2,tankBg:getContentSize().height-barHeight/2),110,nil,nil,"AllBarBg.png","xpBar.png",824)
                hpSprite:setScaleX((contentW-5)/hpSprite:getContentSize().width)
                hpSprite:setScaleY((barHeight-10)/hpSprite:getContentSize().height)
                local progressSp=tolua.cast(tankBg:getChildByTag(824),"CCSprite")
                progressSp:setScaleX(contentW/progressSp:getContentSize().width)
                progressSp:setScaleY(barHeight/progressSp:getContentSize().height)
                local curHp=allianceFubenVoApi:getAllianceBossHp()
                local maxHp=allianceFubenVoApi:getBossMaxHp()
                local percent=0
                if maxHp>0 then
                    percent=(curHp/maxHp)*100
                    percent=string.format("%4.2f",percent)
                end
                hpSprite:setPercentage(percent)
                local hpLb = GetTTFLabel(percent.."%",25)
                hpLb:setScaleX(1/hpSprite:getScaleX())
                hpLb:setScaleY(1/hpSprite:getScaleY())
                hpLb:setPosition(ccp(hpSprite:getContentSize().width/2,hpSprite:getContentSize().height/2))
                hpSprite:addChild(hpLb)
                self.bossHpProcessSp=hpSprite
                self.bossHpLb=hpLb

                local txtSize=22
                local rect = CCRect(0, 0, 50, 50)
                local capInSet = CCRect(60, 20, 1, 1)
                local function touch(hd,fn,idx)
                end
                local bossTankIcon=CCSprite:createWithSpriteFrameName("t99999_1.png")
                bossTankIcon:setScale(0.3)
                bossTankIcon:setAnchorPoint(ccp(0,0.5))
                bossTankIcon:setPosition(10,tankBg:getContentSize().height/2-10)
                tankBg:addChild(bossTankIcon)
                self.allianceBossSp=bossTankIcon              
                local tankW=bossTankIcon:getContentSize().width*bossTankIcon:getScaleX()
                local tankH=bossTankIcon:getContentSize().height*bossTankIcon:getScaleY()

                local textPosX=bossTankIcon:getPositionX()+tankW+20
                local nameLable = GetTTFLabelWrap(getlocal("alliance_boss_name"),35,CCSizeMake((self.bgLayer:getContentSize().width-100)/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                nameLable:setPosition(ccp(textPosX,bossTankIcon:getPositionY()+20))
                nameLable:setAnchorPoint(ccp(0,0))
                nameLable:setColor(G_ColorGreen)
                tankBg:addChild(nameLable,1)
                local lv=allianceFubenVoApi:getAllianceBossKillCount()
                local degreeLb = GetTTFLabelWrap(getlocal("alliance_boss_degree",{getlocal("alliance_boss_checkpoint",{lv+1})}),25,CCSizeMake((self.bgLayer:getContentSize().width-100)/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                degreeLb:setPosition(ccp(textPosX,bossTankIcon:getPositionY()-40))
                degreeLb:setAnchorPoint(ccp(0,0))
                tankBg:addChild(degreeLb,1)
                self.degreeLb=degreeLb

                local state,lefttime=allianceFubenVoApi:getFubenBossState()
                local timeLb=GetTTFLabelWrap(getlocal("alliance_boss_back",{lefttime.."s"}),25,CCSizeMake((self.bgLayer:getContentSize().width-100)/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                timeLb:setAnchorPoint(ccp(0,1))
                timeLb:setPosition(ccp(textPosX,degreeLb:getPositionY()-20))
                tankBg:addChild(timeLb,1)
                timeLb:setColor(G_ColorYellowPro)
                timeLb:setVisible(false)
                self.timeLb=timeLb
                if state==2 and tonumber(lefttime)>0 then
                    timeLb:setVisible(true)
                end
            end
        else
            local sectionCfg=allianceFubenVoApi:getSectionCfg()[self.fid]
            local fubenVo=allianceFubenVoApi:getFuben()
            local tankNumTab=fubenVo.tank[self.fid] or {}
            
            if idx==0 then
                headLabel=GetTTFLabel(getlocal("alliance_challenge_use_prop_title"),25)

                for i=1,2 do
                    local pid
                    if i==1 then
                        pid=17
                    elseif i==2 then
                        pid=18
                    end
                    local item=shopVoApi:getShopItemBySid(pid)
                    local itemNum=bagVoApi:getItemNumId(pid)
                    local hSpace=10

                    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
                    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, (cellHeight-headSprie:getContentSize().height)/2))
                    backSprie:ignoreAnchorPointForPosition(false)
                    backSprie:setAnchorPoint(ccp(0.5,0))
                    backSprie:setIsSallow(false)
                    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
                    cell:addChild(backSprie)
                    backSprie:setOpacity(0)
                    backSprie:setPosition(ccp((self.bgLayer:getContentSize().width-20)/2,(cellHeight-headSprie:getContentSize().height)/2*(i-1)+2))

                    local function nilFunc( ... )
                        -- body
                    end
                    local adaH = 0
                    if i == 2 then
                        adaH = 15
                    end
                    local titleSpire = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),nilFunc)
                    titleSpire:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20-150,32))
                    titleSpire:setAnchorPoint(ccp(0,0.5))
                    backSprie:addChild(titleSpire)
                    titleSpire:setPosition(ccp(5,backSprie:getContentSize().height-20-adaH))

                    local lbName=GetTTFLabel(getlocal(item.name),26)
                    lbName:setColor(G_ColorYellowPro2)
                    lbName:setPosition(15,titleSpire:getContentSize().height/2)
                    lbName:setAnchorPoint(ccp(0,0.5));
                    titleSpire:addChild(lbName,2)

                    local lbNum=GetTTFLabel(getlocal("propOwned")..itemNum,22)
                    lbNum:setPosition(backSprie:getContentSize().width-80,backSprie:getContentSize().height-60)
                    lbNum:setAnchorPoint(ccp(0.5,1));
                    backSprie:addChild(lbNum,2)

                    local sprite = CCSprite:createWithSpriteFrameName(item.icon);
                    sprite:setAnchorPoint(ccp(0,0.5));
                    sprite:setPosition(20,80+hSpace)
                    backSprie:addChild(sprite,2)

                    local labelSize = CCSize(250, 0);
                    local lbDescription=GetTTFLabelWrap(getlocal(item.description),22,labelSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    lbDescription:setPosition(150,80+hSpace)
                    lbDescription:setAnchorPoint(ccp(0,0.5));
                    backSprie:addChild(lbDescription,2)

                    local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
                    lineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, 2))
                    lineSp:setPosition(backSprie:getContentSize().width/2-18,10)
                    backSprie:addChild(lineSp, 2)

                    --[[
                    local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
                    gemIcon:setPosition(ccp(480,100+hSpace));
                    backSprie:addChild(gemIcon,2)

                    local lbPrice=GetTTFLabel(item.gemCost,24)
                    lbPrice:setPosition(ccp(560,100+hSpace))
                    lbPrice:setAnchorPoint(ccp(1,0.5));
                    backSprie:addChild(lbPrice,2)
                    ]]  

                    local function usePropHandler(tag,object)
                        if self.tv:getIsScrolled()==true then
                            do return end
                        end
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end         
                        PlayEffect(audioCfg.mouseClick)

                        if itemNum<=0 then

                            local function touchBuy()
                                local function callbackBuyprop(fn,data)
                                    --local retTb=OBJDEF:decode(data)
                                    if base:checkServerData(data)==true then
                                        --统计购买物品
                                        statisticsHelper:buyItem("p"..item.sid,item.gemCost,1,item.gemCost)
                                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("buyPropPrompt",{getlocal(item.name)}),28)
                                        self.usePropTab["p"..tag]=1
                                        self.tv:reloadData()
                                    end
                                end
                                socketHelper:buyProc(tag,callbackBuyprop)
                            end
                            if playerVoApi:getGems()<tonumber(item.gemCost) then
                                local num=tonumber(item.gemCost)-playerVoApi:getGems()
                                GemsNotEnoughDialog(nil,nil,num,self.layerNum+1,tonumber(item.gemCost))
                            else
                                local smallD=smallDialog:new()
                                smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("prop_buy_tip",{item.gemCost,getlocal(item.name)}),nil,self.layerNum+1)
                            end

                            do return end
                        end

                        --tag:pid 17,18
                        -- if self.usePropTab["p"..tag]==1 then
                        --     self.usePropTab["p"..tag]=nil
                        --     tolua.cast(self.useBtnTab[i]:getChildByTag(100+i),"CCLabelTTF"):setString(getlocal("use"))
                        -- else
                        --     self.usePropTab["p"..tag]=1
                        --     tolua.cast(self.useBtnTab[i]:getChildByTag(100+i),"CCLabelTTF"):setString(getlocal("cancel"))
                        -- end

                        self.usePropTab["p"..tag]=1
                        self.useBtnTab[i]:setVisible(false)
                        self.useBtnTab[i]:setEnabled(false)
                        self.cancelBtnTab[i]:setVisible(true)
                        self.cancelBtnTab[i]:setEnabled(true)

                        -- local isUse=false
                        -- for k,v in pairs(self.usePropTab) do
                        --     if v==tag then
                        --         isUse=true
                        --         table.remove(self.usePropTab,k)
                        --         tolua.cast(self.useBtnTab[i]:getChildByTag(100+i),"CCLabelTTF"):setString(getlocal("use"))
                        --     end
                        -- end
                        -- if isUse==false then
                        --     table.insert(self.usePropTab,tag)
                        --     tolua.cast(self.useBtnTab[i]:getChildByTag(100+i),"CCLabelTTF"):setString(getlocal("cancel"))
                        -- end
                    end
                    local menuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",usePropHandler,pid,getlocal("use"),30,100+i)
                    local scale=0.7
                    menuItem:setScale(scale)
                    local menu=CCMenu:createWithItem(menuItem)
                    menu:setPosition(ccp(self.bgLayer:getContentSize().width-menuItem:getContentSize().width/2*scale-50,backSprie:getContentSize().height/2-30))
                    menu:setTouchPriority(-(self.layerNum-1)*20-2)
                    backSprie:addChild(menu,6)
                    table.insert(self.useBtnTab,i,menuItem)

                    local function cancelPropHandler(tag,object)
                        if self.tv:getIsScrolled()==true then
                            do return end
                        end
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end         
                        PlayEffect(audioCfg.mouseClick)

                        --tag:pid 17,18
                        -- if self.usePropTab["p"..tag]==1 then
                        --     self.usePropTab["p"..tag]=nil
                        --     tolua.cast(self.useBtnTab[i]:getChildByTag(100+i),"CCLabelTTF"):setString(getlocal("use"))
                        -- else
                        --     self.usePropTab["p"..tag]=1
                        --     tolua.cast(self.useBtnTab[i]:getChildByTag(100+i),"CCLabelTTF"):setString(getlocal("cancel"))
                        -- end
                        self.usePropTab["p"..tag]=nil
                        self.useBtnTab[i]:setVisible(true)
                        self.useBtnTab[i]:setEnabled(true)
                        self.cancelBtnTab[i]:setVisible(false)
                        self.cancelBtnTab[i]:setEnabled(false)
                    end
                    local menuItem1=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn.png",cancelPropHandler,pid,getlocal("cancel"),30,100+i)
                    local scale=0.7
                    menuItem1:setScale(scale)
                    local menu1=CCMenu:createWithItem(menuItem1)
                    menu1:setPosition(ccp(self.bgLayer:getContentSize().width-menuItem1:getContentSize().width/2*scale-50,backSprie:getContentSize().height/2-30))
                    menu1:setTouchPriority(-(self.layerNum-1)*20-2)
                    backSprie:addChild(menu1,6)
                    table.insert(self.cancelBtnTab,i,menuItem1)
                    menuItem1:setEnabled(false)
                    menuItem1:setVisible(false)

                    if self.usePropTab then
                        for k,v in pairs(self.usePropTab) do
                            if ("p"..pid)==k then
                                if v and tonumber(v) and tonumber(v)>0 then
                                    menuItem:setEnabled(false)
                                    menuItem:setVisible(false)
                                    menuItem1:setEnabled(true)
                                    menuItem1:setVisible(true)
                                end
                            end
                        end

                    end
                end
            elseif idx==1 then
                headLabel=GetTTFLabel(getlocal("alliance_challenge_award_title"),30)


                local lbExp=GetTTFLabel(getlocal("alliance_challenge_exp",{sectionCfg.AllianceExp}),25,true)
                lbExp:setAnchorPoint(ccp(0.5,0))
                lbExp:setPosition((G_VisibleSizeWidth-20)/2,90)
                cell:addChild(lbExp,2)

                local lbBox=GetTTFLabel(getlocal("alliance_challenge_box",{sectionCfg.boxstar}),25,true)
                lbBox:setAnchorPoint(ccp(0.5,0))
                lbBox:setPosition((G_VisibleSizeWidth-20)/2,40)
                cell:addChild(lbBox,2)
            elseif idx==2 then
                headLabel=GetTTFLabel(getlocal("alliance_challenge_enemy_info"),30)
                
                local tankTab=FormatItem(sectionCfg.tank,nil,true)

                local sizeLb=190*2+130
                for k=1,6 do
                    local width = self.bgLayer:getContentSize().width-(math.ceil(k/3))*300-30
                    local height = sizeLb-((k-1)%3)*190


                    local capInSet = CCRect(20, 20, 10, 10) 
                    local function touch()
                    end
                    local tankBg =LuaCCScale9Sprite:createWithSpriteFrameName("nbSkillBorder.png",CCRect(116, 58, 1, 1),touch)
                    tankBg:setContentSize(CCSizeMake((self.bgLayer:getContentSize().width-60)/2,180))
                    tankBg:ignoreAnchorPointForPosition(false)
                    tankBg:setAnchorPoint(ccp(0,0))
                    tankBg:setPosition(ccp(width,height))
                    tankBg:setIsSallow(false)
                    tankBg:setTouchPriority(-(self.layerNum-1)*20-2)
                    cell:addChild(tankBg)


                    local rect = CCRect(0, 0, 50, 50)
                    local capInSet = CCRect(60, 20, 1, 1)
                    local function touch(hd,fn,idx)

                    end
                    local nameSp =LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",capInSet,touch)
                    nameSp:setContentSize(CCSizeMake(tankBg:getContentSize().width, 40))
                    nameSp:ignoreAnchorPointForPosition(false)
                    nameSp:setAnchorPoint(ccp(0.5,1))
                    nameSp:setIsSallow(false)
                    nameSp:setOpacity(0)
                    nameSp:setTouchPriority(-(self.layerNum-1)*20-2)
                    nameSp:setPosition(ccp(tankBg:getContentSize().width/2,tankBg:getContentSize().height-3))
                    tankBg:addChild(nameSp)

                    local bgScale=120/150
                    local function touchClick(hd,fn,idx)
                    end
                    local bgSp =LuaCCScale9Sprite:createWithSpriteFrameName("BgEmptyTank.png",CCRect(10, 10, 20, 20),touchClick)
                    bgSp:setContentSize(CCSizeMake(150,150))
                    bgSp:ignoreAnchorPointForPosition(false)
                    bgSp:setAnchorPoint(ccp(0.5,0.5))
                    bgSp:setIsSallow(false)
                    bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
                    bgSp:setPosition(ccp(10+bgSp:getContentSize().width/2*bgScale,10+bgSp:getContentSize().height/2*bgScale))
                    tankBg:addChild(bgSp,1)
                    bgSp:setScale(bgScale)

                    
                    local tankNum=0
                    if tankNumTab[k] and tankNumTab[k][2] then
                        tankNum=tonumber(tankNumTab[k][2])
                    end
                    local tank=tankTab[k]
                    local txtSize=22
                    if tank and tank.name and tank.pic and tank.num then
                        local nameLable = GetTTFLabelWrap(tank.name,txtSize,CCSizeMake((self.bgLayer:getContentSize().width-60)/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
                        nameLable:setAnchorPoint(ccp(0,0.5))
                        nameLable:setPosition(ccp(20,nameSp:getContentSize().height/2))
                        nameSp:addChild(nameLable,1)
                        nameLable:setColor(G_ColorYellowPro2)
                
                        local icon = CCSprite:createWithSpriteFrameName(tank.pic)
                        icon:setPosition(getCenterPoint(bgSp))
                        bgSp:addChild(icon,2)
                        
                        local numLable = GetTTFLabel("("..tankNum.."/"..tank.num..")",txtSize)
                        numLable:setAnchorPoint(ccp(0.5,0))
                        numLable:setPosition(ccp(icon:getContentSize().width/2,10))
                        icon:addChild(numLable,2)

                        if tank.id and tankCfg[tank.id] then
                            tankTotalCfg=tankCfg[tank.id]
                            local spSize=50
                            local attackSp = CCSprite:createWithSpriteFrameName("pro_ship_attack.png")
                            local iconScale= spSize/attackSp:getContentSize().width
                            local propWidth=icon:getContentSize().width*bgScale+20+spSize/2
                            attackSp:setAnchorPoint(ccp(0.5,0.5))
                            attackSp:setPosition(propWidth,100)
                            tankBg:addChild(attackSp,2)
                            attackSp:setScale(iconScale)

                            local attLb=GetTTFLabel(math.ceil(tankTotalCfg.attack*sectionCfg.attributeUp.attack),20)
                            attLb:setAnchorPoint(ccp(0,0.5))
                            attLb:setPosition(ccp(propWidth+spSize/2+10,100))
                            tankBg:addChild(attLb)


                            local lifeSp = CCSprite:createWithSpriteFrameName("pro_ship_life.png")
                            lifeSp:setAnchorPoint(ccp(0.5,0.5))
                            lifeSp:setPosition(propWidth,42)
                            tankBg:addChild(lifeSp,2)
                            lifeSp:setScale(iconScale)
                            
                            local lifeLb=GetTTFLabel(math.ceil(tankTotalCfg.life*sectionCfg.attributeUp.life),20)
                            lifeLb:setAnchorPoint(ccp(0,0.5))
                            lifeLb:setPosition(ccp(propWidth+spSize/2+10,40))
                            tankBg:addChild(lifeLb)
                        end
                    end
                end
            end
        end
        headLabel:setColor(G_ColorYellowPro2)
        headLabel:setPosition(getCenterPoint(headSprie))
        headSprie:addChild(headLabel,1)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

--点击tab页签 idx:索引
function allianceFubenDialog:tabClick(idx)
    -- for k,v in pairs(self.allTabs) do
    --     if v:getTag()==idx then
    --         v:setEnabled(false)
    --         self.selectedTabIndex=idx
    --         self.tv:reloadData()
    --         self:doUserHandler()
    --     else
    --         v:setEnabled(true)
    --     end
    -- end
end

--用户处理特殊需求,没有可以不写此方法
function allianceFubenDialog:doUserHandler()
    local function challengeHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        self:close()

        require "luascript/script/game/scene/gamedialog/warDialog/tankStoryDialog"
        local td
        if self.isBossFu==true then
            td=tankStoryDialog:new(nil,0,nil,nil,nil,nil,nil,nil,true) --攻打副本boss不使用道具
        else
            td=tankStoryDialog:new(nil,self.fid,self.usePropTab)
        end
        if td then
            local tbArr={getlocal("fleetCard"),getlocal("dispatchCard"),getlocal("repair")}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("goFighting"),true,7)
            sceneGame:addChild(dialog,7)
        end      
    end

    local attackMaxNum=allianceFubenVoApi:getDailyAttackNum()
    local fubenVo=allianceFubenVoApi:getFuben()

    if self.challengeBtn==nil then
        self.challengeBtn = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",challengeHandler,1,getlocal("alliance_challenge_fight"),25)
        local spScale=0.8
        self.challengeBtn:setScale(spScale)
        local challengeMenu = CCMenu:createWithItem(self.challengeBtn)
        challengeMenu:setPosition(ccp(self.bgLayer:getContentSize().width-self.challengeBtn:getContentSize().width/2*spScale-10,self.challengeBtn:getContentSize().height/2+10))
        challengeMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(challengeMenu,1)
    end
    if fubenVo.attackCount>=attackMaxNum then
        self.challengeBtn:setEnabled(false)
    else
        self.challengeBtn:setEnabled(true)
    end

    if self.degreeLb then
        local lv=allianceFubenVoApi:getAllianceBossKillCount()
        self.degreeLb:setString(getlocal("alliance_boss_degree",{getlocal("alliance_boss_checkpoint",{lv+1})}))
    end

    if self.isBossFu==true and tonumber(self.allianceBossHp)<=0 then
        self.challengeBtn:setEnabled(false)
    end
    if self.attackNumLabel==nil then
        self.attackNumLabel=GetTTFLabel(getlocal("alliance_fuben_attack_num",{fubenVo.attackCount,attackMaxNum}),25,true)
        self.attackNumLabel:setAnchorPoint(ccp(0,0.5))
        self.attackNumLabel:setPosition(ccp(20,self.challengeBtn:getContentSize().height/2+10))
        self.bgLayer:addChild(self.attackNumLabel,1)
    else
        self.attackNumLabel:setString(getlocal("alliance_fuben_attack_num",{fubenVo.attackCount,attackMaxNum}))
    end
end

function allianceFubenDialog:showBossDamageChangeLabel()
    if self and self.allianceBossSp then
      local tankWidth = self.allianceBossSp:getContentSize().width
      local tankHeight = self.allianceBossSp:getContentSize().height

      local bossNowHp = allianceFubenVoApi:getAllianceBossHp()
      if bossNowHp<self.allianceBossHp then
        local damage = self.allianceBossHp-bossNowHp
        self.allianceBossHp = bossNowHp
        local subLifeLb=GetBMLabel(-damage,G_FontSrc,20)
        subLifeLb:setAnchorPoint(ccp(0.5,0.5))
        subLifeLb:setPosition(tankWidth/2,tankHeight/2)
        self.allianceBossSp:addChild(subLifeLb)
        local function subMvEnd()
          if subLifeLb then
            subLifeLb:removeFromParentAndCleanup(true)
            subLifeLb=nil
          end
        end
        local subMvTo=CCMoveTo:create(0.2,ccp(tankWidth/2,tankHeight/2))
        local delayTime=CCDelayTime:create(0.3)
        local subMvTo2=CCMoveTo:create(0.4,ccp(tankWidth/2,tankHeight))
        local  subfunc=CCCallFuncN:create(subMvEnd)
        local fadeOut=CCFadeTo:create(0.4,0)
        local fadeArr=CCArray:create()
        fadeArr:addObject(subMvTo2)
        fadeArr:addObject(fadeOut)
        local spawn=CCSpawn:create(fadeArr)
        local acArr=CCArray:create()
        acArr:addObject(subMvTo)
        local wzScaleTo=CCScaleTo:create(0.2,1.5)
        local wzScaleBack=CCScaleTo:create(0.2,1.1)
        acArr:addObject(wzScaleTo)
        acArr:addObject(wzScaleBack)
        acArr:addObject(delayTime)
        acArr:addObject(spawn)
        acArr:addObject(subfunc)
        local  subseq=CCSequence:create(acArr)
        subLifeLb:runAction(subseq)
      end
    end
end

function allianceFubenDialog:refreshBossDamage()
    if self and self.bossHpLb and self.bossHpProcessSp then
        local curHp=allianceFubenVoApi:getAllianceBossHp()
        local maxHp=allianceFubenVoApi:getBossMaxHp()
        local percent=0
        if maxHp>0 then
            percent=(curHp/maxHp)*100
            percent=string.format("%4.2f",percent)
        end
        self.bossHpProcessSp:setPercentage(percent)
        self.bossHpLb:setString(percent.."%")
    end
end

function allianceFubenDialog:tick()
    if self and self.bgLayer then
        if allianceFubenVoApi:getFlag(2)==0 or allianceFubenVoApi:isRefreshData()==true then
            if self.tv then
                self.tv:reloadData()
            end
            self:doUserHandler()
            allianceFubenVoApi:setFlag(2,1)
        end
        --处理副本boss复活
        local state,lefttime=allianceFubenVoApi:getFubenBossState()
        if self.timeLb then
            if state==2 and tonumber(lefttime)>0 then
                self.timeLb:setVisible(true)
                self.timeLb:setString(getlocal("alliance_boss_back",{lefttime.."s"}))
            else
                self.timeLb:setVisible(false)
            end
        end
    end
end

--点击了cell或cell上某个按钮
function allianceFubenDialog:cellClick(idx)

end

function allianceFubenDialog:dispose()
    eventDispatcher:removeEventListener("allianceBossFuben.damageChanged",self.damageChangedListener)
    G_AllianceDialogTb["allianceFubenDialog"]=nil
    self.useBtnTab=nil
    self.cancelBtnTab=nil
    self.usePropTab=nil
    self.challengeBtn=nil
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.isBossFu=false
    self.allianceBossSp=nil
    self.allianceBossHp=0
    self.damageChangedListener=nil
    self.bossHpProcessSp=nil
    self.bossHpLb=nil
    self.timeLb=nil
    self.degreeLb=nil
    self=nil
    spriteController:removePlist("public/nbSkill2.plist")
    spriteController:removeTexture("public/nbSkill2.png")
end








