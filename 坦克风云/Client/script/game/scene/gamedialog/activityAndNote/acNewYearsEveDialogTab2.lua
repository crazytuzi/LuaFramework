require "luascript/script/game/scene/gamedialog/activityAndNote/acNewYearsEveSubTab21"
require "luascript/script/game/scene/gamedialog/activityAndNote/acNewYearsEveSubTab22"
acNewYearsEveDialogTab2={}

function acNewYearsEveDialogTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.subTabs={}
    self.tab1=nil
    self.layerTab1=nil
    self.tab2=nil
    self.layerTab2=nil
    self.curTab=1

    return nc
end

function acNewYearsEveDialogTab2:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initSubTab()

    if acNewYearsEveVoApi:acIsStop() == true then
       if self.refreshIconTipVisible then
            self:refreshIconTipVisible(1)
            self:refreshIconTipVisible(2)
        end
    end

    return self.bgLayer
end

function acNewYearsEveDialogTab2:initSubTab()
    local tabStr={getlocal("activity_newyearseve_rank_1"),getlocal("activity_newyearseve_rank_2")}
    for k,v in pairs(tabStr) do
        local subTabBtn=CCMenu:create()
        local subTabItem=CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
        subTabItem:setAnchorPoint(ccp(0,0))
        local tipSp = CCSprite:createWithSpriteFrameName("IconTip.png");
        tipSp:setAnchorPoint(CCPointMake(1,0.5))
        tipSp:setScale(0.7)
        tipSp:setPosition(ccp(subTabItem:getContentSize().width,subTabItem:getContentSize().height-10));
        tipSp:setTag(101);
        tipSp:setVisible(false)
        subTabItem:addChild(tipSp,1)

        local function tabSubClick(idx)
            return self:switchSubTab(idx,true)
        end
        subTabItem:registerScriptTapHandler(tabSubClick)
        local adaSize = 20
        if G_getCurChoseLanguage() == "ru" then
            adaSize = 13
        end
        local lb=GetTTFLabelWrap(v,adaSize,CCSizeMake(subTabItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        lb:setPosition(CCPointMake(subTabItem:getContentSize().width/2,subTabItem:getContentSize().height/2))
        subTabItem:addChild(lb)
        self.subTabs[k]=subTabItem
        subTabBtn:addChild(subTabItem)
        subTabItem:setTag(k)
        subTabBtn:setPosition(ccp((k-1)*(subTabItem:getContentSize().width+9)+30,self.bgLayer:getContentSize().height-210))
        subTabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(subTabBtn)
    end

    local function showInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        
        local acVo=acNewYearsEveVoApi:getAcVo()
        local function getRewardStr(rewardTb)
            local rewardStr=""
            if rewardTb then
                for k,v in pairs(rewardTb) do
                    if v.reward then
                        local award = FormatItem(v.reward,false,true)
                        local awardStr=G_showRewardTip(award,false,true)
                        if v.range then
                            if v.range[1]==v.range[2] then
                                if rewardStr=="" then
                                    rewardStr=getlocal("activity_cuikulaxiu_rankToReward",{v.range[1],awardStr})
                                else
                                    rewardStr=rewardStr.."\n"..getlocal("activity_cuikulaxiu_rankToReward",{v.range[1],awardStr})
                                end
                            else
                                if rewardStr=="" then
                                    rewardStr=getlocal("activity_cuikulaxiu_rankTorankReward",{v.range[1],v.range[2],awardStr})
                                else
                                    rewardStr=rewardStr.."\n"..getlocal("activity_cuikulaxiu_rankTorankReward",{v.range[1],v.range[2],awardStr})
                                end
                            end
                        end
                    end
                end
            end
            return rewardStr
        end
        local rewardStr1=getRewardStr(acVo.perDamageRewards)
        local rewardStr2=getRewardStr(acVo.totalDamageRewards)
        -- print("rewardStr1",rewardStr1)
        -- print("rewardStr2",rewardStr2)
        local desc2key="activity_newyearseve_rank_desc2"
        local desc3key="activity_newyearseve_rank_desc3"
        if acNewYearsEveVoApi:getAcShowType()==acNewYearsEveVoApi.acShowType.TYPE_2 then
            desc2key="activity_newyearseve_rank_desc2_1"
            desc3key="activity_newyearseve_rank_desc3_1"
        end
        local tabStr={rewardStr2,"\n",getlocal("activity_newyearseve_rank_desc4",{getlocal("activity_newyearseve_rank_2")}),"\n",rewardStr1,"\n",getlocal("activity_newyearseve_rank_desc4",{getlocal("activity_newyearseve_rank_1")}),"\n","\n",getlocal(desc3key),"\n",getlocal(desc2key),"\n",getlocal("activity_newyearseve_rank_desc1"),"\n",getlocal("activity_newyearseve_rank_desc")}
        local tabColor={nil,nil,G_ColorYellow,nil,nil,nil,G_ColorYellow}
        local sizeTab={nil,nil,23,nil,nil,nil,23}
        PlayEffect(audioCfg.mouseClick)
        -- local td=smallDialog:new()
        -- local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
        -- sceneGame:addChild(dialog,self.layerNum+1)
        smallDialog:showTableViewSureWithColorTb("TankInforPanel.png",CCSizeMake(600,700),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),nil,tabStr,tabColor,true,self.layerNum+1,nil,sizeTab)
    end
    local btnInfoImage1,btnInfoImage2,btnInfoImage3="i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png"
    local infoItem = GetButtonItem(btnInfoImage1,btnInfoImage2,btnInfoImage3,showInfo,11,nil,nil)
    infoItem:setScale(0.6)
    local infoBtn = CCMenu:createWithItem(infoItem);
    infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,self.bgLayer:getContentSize().height-187))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(infoBtn)

    -- self:switchSubTab(1,false)
end

function acNewYearsEveDialogTab2:switchSubTab(type,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    if type==nil then
        type=1
    end
    local function listCallback()
        self:realSwitchSubTab(type)
    end
    acNewYearsEveVoApi:activeNewyeareva("ranklist",type,listCallback)
end

function acNewYearsEveDialogTab2:realSwitchSubTab(tabType)
    for k,v in pairs(self.subTabs) do
        if k==tabType then
            v:setEnabled(false)
            self.curTab=tabType
        else
            v:setEnabled(true)
        end
    end

    if(tabType==1)then
        if(self.tab1==nil)then
            self.tab1=acNewYearsEveSubTab21:new()
            self.layerTab1=self.tab1:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab1,1)
        elseif self.tab1.updateUI then
            self.tab1:updateUI()
        end
    elseif(tabType==2)then
        if(self.tab2==nil)then
            self.tab2=acNewYearsEveSubTab22:new()
            self.layerTab2=self.tab2:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab2,1)
        elseif self.tab2.updateUI then
            self.tab2:updateUI()
        end
    end

    for i=1,2 do
        if self["layerTab"..i] then
            if i==tabType then
                self["layerTab"..i]:setPositionX(0)
                self["layerTab"..i]:setVisible(true)
            else
                self["layerTab"..i]:setPositionX(999333)
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end

function acNewYearsEveDialogTab2:refresh()
    if self and self.curTab then
        self:switchSubTab(self.curTab,false)
    end
end

function acNewYearsEveDialogTab2:tick()
    for i=1,2 do
        if self["tab"..i]~=nil and self["tab"..i].tick then
            self["tab"..i]:tick()
        end
    end
end

function acNewYearsEveDialogTab2:refreshIconTipVisible(idx)
    if self==nil then
        do
            return 
        end
    end
    local tabBtnItem = self.subTabs[idx]
    local temTabBtnItem=tolua.cast(tabBtnItem,"CCNode")
    local tipSp=temTabBtnItem:getChildByTag(101)
    if tipSp~=nil then
        local canReward = acNewYearsEveVoApi:canRankReward(idx)
        if canReward == true then
            tipSp:setVisible(true)
        else
            tipSp:setVisible(false)
        end
    end
end

function acNewYearsEveDialogTab2:dispose()
    if(self.tab1)then
        self.tab1:dispose()
    end
    if(self.tab2)then
        self.tab2:dispose()
    end
    self.subTabs={}
    self.tab1=nil
    self.layerTab1=nil
    self.tab2=nil
    self.layerTab2=nil
    self.curTab=1
end
