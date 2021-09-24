acCjyxDialog=commonDialog:new()

function acCjyxDialog:new()
    local nc={
        layerTab1=nil,
        layerTab2=nil,

        cjyxTab1=nil,
        cjyxTab2=nil,

        isEnd=false,

        descLb=nil,
        acLabel=nil,
        timeLb=nil,
        moveBgStarStr=nil,
        url=G_downloadUrl("active/".."cjyx/".."cjyx_bg.jpg")
    }
    setmetatable(nc,self)
    self.__index=self
   
    return nc
end

function acCjyxDialog:resetTab()
    spriteController:addPlist("public/acBlessWords.plist")
    spriteController:addTexture("public/acBlessWords.png")
    spriteController:addPlist("public/acCjyx_images.plist")
    spriteController:addTexture("public/acCjyx_images.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acAnniversary.plist")
    spriteController:addTexture("public/acAnniversary.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local index=0
    for k,v in pairs(self.allTabs) do
        local  tabBtnItem=v
        if index==0 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        elseif index==1 then
            tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
        end
        if index==self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end
        index=index+1
    end
    self.isEnd=acCjyxVoApi:acIsStop()
    self:tabClick(0,false)
end

function acCjyxDialog:resetForbidLayer()
    if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
        if (self.selectedTabIndex==1) then
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-175+70))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,175+70))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,165))
        elseif (self.selectedTabIndex==0) then
            self.topforbidSp:setContentSize(CCSizeMake(0,0))
            self.bottomforbidSp:setContentSize(CCSizeMake(0,0))
        end
    end
end

function acCjyxDialog:initTableView()
    if G_getCurChoseLanguage() == "cn" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() == "tw" or G_getCurChoseLanguage() == "ja" then
    elseif self.titleLabel then
        -- self.titleLabel:setFontSize(20)
        self.titleLabel:setPositionX(self.titleLabel:getPositionX()-50)
    end
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local function callBack(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.tv:setPosition(ccp(30,165))
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    blueBg:setAnchorPoint(ccp(0.5,0))
    blueBg:setScaleX(600/blueBg:getContentSize().width)
    blueBg:setScaleY((G_VisibleSizeHeight-180)/blueBg:getContentSize().height)
    blueBg:setPosition(G_VisibleSizeWidth/2,20)
    blueBg:setOpacity(200)
    self.bgLayer:addChild(blueBg)
    
    local iconPos=ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160)
    local function onLoadIcon(fn,icon)
        if self and self.bgLayer then
            icon:setAnchorPoint(ccp(0.5,1))
            icon:setScaleX((G_VisibleSizeWidth-40)/icon:getContentSize().width)
            icon:setScaleY((G_VisibleSizeHeight-185)/icon:getContentSize().height)
            self.bgLayer:addChild(icon)
            icon:setPosition(iconPos)
        end
    end
    -- print("self.url------>",self.url)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    -- local cjyxBg=CCSprite:create("public/cjyx_bg.jpg")
    -- cjyxBg:setAnchorPoint(ccp(0.5,1))
    -- cjyxBg:setScaleX((G_VisibleSizeWidth-40)/cjyxBg:getContentSize().width)
    -- cjyxBg:setScaleY((G_VisibleSizeHeight-185)/cjyxBg:getContentSize().height)
    -- cjyxBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160)
    -- self.bgLayer:addChild(cjyxBg)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local function nilFunction()
    end
    local lineBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),nilFunction)
    lineBg:setPosition(ccp(G_VisibleSizeWidth/2,self.bgLayer:getContentSize().height/2-66))
    lineBg:setContentSize(CCSizeMake(600,G_VisibleSizeHeight-180))
    self.bgLayer:addChild(lineBg)

    if acCjyxVoApi:getMustMode()==false then
        if acCjyxVoApi:getAcShowType()==acCjyxVoApi.acShowType.TYPE_2 then
        else
            local dlongPos={180,G_VisibleSizeWidth-180}
            for i=1,2 do
                local dlongSp=CCSprite:createWithSpriteFrameName("pumpkinA22.png")
                dlongSp:setAnchorPoint(ccp(0.5,1))
                dlongSp:setPosition(ccp(dlongPos[i],G_VisibleSizeHeight+20))
                self.bgLayer:addChild(dlongSp)
                if G_getCurChoseLanguage() ~="cn" and G_getCurChoseLanguage() ~="ja" and G_getCurChoseLanguage() ~="ko" and G_getCurChoseLanguage() ~="tw "then
                    if i == 1 then
                        dlongSp:setPositionX(60)
                    else
                        dlongSp:setPositionX(G_VisibleSizeWidth -160)
                    end
                end
            end
        end
    end
    
    local function initInfo()
        local function bgClick()
        end
        local h=G_VisibleSizeHeight-160
        local w=G_VisibleSizeWidth-50 --背景框的宽度
        local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(60,24,8,2),bgClick)
        backSprie:setContentSize(CCSizeMake(w,150))
        backSprie:setAnchorPoint(ccp(0.5,1))
        backSprie:setPosition(ccp(G_VisibleSizeWidth/2,h))
        backSprie:setTouchPriority(-(self.layerNum-1)*20-4)
        backSprie:setIsSallow(true)
        self.bgLayer:addChild(backSprie,3)

        if acCjyxVoApi:getAcShowType()==acCjyxVoApi.acShowType.TYPE_2 then
        else
            local cloud1=CCSprite:createWithSpriteFrameName("snowBg_1.png")
            cloud1:setAnchorPoint(ccp(0,1))
            cloud1:setPosition(ccp(20,h+15))
            self.bgLayer:addChild(cloud1,5)

            local cloud2=CCSprite:createWithSpriteFrameName("snowBg_2.png")
            cloud2:setAnchorPoint(ccp(1,1))
            cloud2:setPosition(ccp(G_VisibleSizeWidth-20,h+15))
            self.bgLayer:addChild(cloud2,5)
        end

        local function touch(tag,object)
            PlayEffect(audioCfg.mouseClick)
            --显示活动信息
            self:showInfor()
        end

        local infoBtnImage1,infoBtnImage2,infoBtnImage3="BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png"
        if acCjyxVoApi:getAcShowType()==acCjyxVoApi.acShowType.TYPE_2 then
            infoBtnImage1,infoBtnImage2,infoBtnImage3="i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png"
        end
        local menuItemDesc=GetButtonItem(infoBtnImage1,infoBtnImage2,infoBtnImage3,touch,nil,nil,0)
        menuItemDesc:setAnchorPoint(ccp(1,1))
        menuItemDesc:setScale(0.8)
        local menuDesc=CCMenu:createWithItem(menuItemDesc)
        menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
        menuDesc:setPosition(ccp(w-20,backSprie:getContentSize().height-10))
        backSprie:addChild(menuDesc)


        local descStr1=acCjyxVoApi:getTimeStr()
        local descStr2=acCjyxVoApi:getRewardTimeStr()
        local moveBgStarStr,tab2Time1,tab2Time2=G_LabelRollView(CCSizeMake(backSprie:getContentSize().width,70),descStr1,23,kCCTextAlignmentCenter,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
        self.tab2Time1 = tab2Time1
        self.tab2Time2 = tab2Time2
        moveBgStarStr:setPosition(ccp(0,backSprie:getContentSize().height-moveBgStarStr:getContentSize().height-25))
        backSprie:addChild(moveBgStarStr)
        self.moveBgStarStr=moveBgStarStr      
        local acLabel=GetTTFLabel(getlocal("activity_timeLabel"),23)
        acLabel:setAnchorPoint(ccp(0.5,1))
        acLabel:setPosition(ccp(backSprie:getContentSize().width/2, backSprie:getContentSize().height-17))
        backSprie:addChild(acLabel)
        acLabel:setColor(G_ColorGreen)
        self.acLabel=acLabel
        local acVo=acCjyxVoApi:getAcVo()
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt-24*3600)
        local timeLb=GetTTFLabel(timeStr,23)
        timeLb:setAnchorPoint(ccp(0.5,1))
        timeLb:setPosition(ccp(backSprie:getContentSize().width/2, backSprie:getContentSize().height-15-acLabel:getContentSize().height))
        timeLb:setColor(G_ColorGreen)
        backSprie:addChild(timeLb)
        self.timeLb=timeLb
        self:updateAcTime()
        local descStr=""
        if acCjyxVoApi:getMustMode()==true then
            if acCjyxVoApi:getAcShowType()==acCjyxVoApi.acShowType.TYPE_2 then
                descStr=getlocal("activity_cjyx_korea_desc_1")
            else
                descStr=getlocal("activity_cjyx_korea_desc")
            end
        else
            if acCjyxVoApi:getAcShowType()==acCjyxVoApi.acShowType.TYPE_2 then
                descStr=getlocal("activity_cjyx_desc_1")
            else
                descStr=getlocal("activity_cjyx_desc")
            end
        end
        local desTv,desLabel=G_LabelTableView(CCSizeMake(w-30,70),descStr,25,kCCTextAlignmentLeft)
        backSprie:addChild(desTv)
        desTv:setPosition(ccp(15,5))
        desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
        desTv:setMaxDisToBottomOrTop(100)
        self.descLb=desLabel

        self:refreshInfo()
    end
    initInfo()
end
function acCjyxDialog:updateAcTime()
    local acVo=acCjyxVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb,nil,nil,nil,true)
    end

    if acVo and self.tab2Time1 and self.tab2Time2 and tolua.cast(self.tab2Time1,"CCLabelTTF") and tolua.cast(self.tab2Time2,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.tab2Time1,self.tab2Time2,nil,nil)
    end
end
function acCjyxDialog:showInfor()
    local title={getlocal("activityDescription"),G_ColorYellowPro}
    local textlist
    local buyNameStr="" --韩国绿色版购买的道具名称
    local mustModeFlag=acCjyxVoApi:getMustMode()
    if mustModeFlag==true then
        local mustRewardCfg=acCjyxVoApi:getMustReward()
        local reward1=mustRewardCfg[1]
        local reward2=mustRewardCfg[2]
        -- if reward1 and reward2 then
        --     if reward1.name~=reward2.name then
        --         buyNameStr=reward1.name..getlocal("and_text")..reward2.name
        --     else
        --         buyNameStr=reward1.name
        --     end
        -- end
    end
    if self.selectedTabIndex==0 then
        textlist={}
        for i=1,3 do
            if mustModeFlag==true then
                local mustRewardCfg=acCjyxVoApi:getMustReward()
                local reward1=mustRewardCfg[1]
                local reward2=mustRewardCfg[2]
                if i==1 then
                    text={getlocal("activity_cjyx_korea_rule"..i,{reward1.name.."x"..FormatNumber(reward1.num),reward2.name.."x"..FormatNumber(reward2.num)})}
                elseif i==3 then
                    text={getlocal("activity_cjyx_korea_rule"..i,{reward1.name.."x"..FormatNumber(reward1.num)})}
                else
                    text={getlocal("activity_cjyx_korea_rule"..i)}
                end
            else
                text={getlocal("activity_cjyx_rule"..i)}
            end
            textlist[i]=text
        end
    elseif self.selectedTabIndex==1 then
        textlist={}
        local rewards=acCjyxVoApi:getRankReward()
        local needRank=0
        for k,v in pairs(rewards) do
            local rank=v[1]
            local reward=FormatItem(v[2],false,true)
            local rewardCount=SizeOfTable(reward)
            local str=""
            for k,v in pairs(reward) do
                if k==rewardCount then
                    str=str..v.name.." x"..v.num
                else
                    str=str..v.name.." x"..v.num..","
                end
            end
            if rank[1]==rank[2] then
                str=getlocal("rank_reward_str",{rank[1],str})
            else
                str=getlocal("rank_reward_str",{rank[1].."~"..rank[2],str})
            end
            table.insert(textlist,{str})
            if tonumber(rank[2])>needRank then
                needRank=rank[2]
            end
        end
        table.insert(textlist,1,{getlocal("miaautumn_rank_rule4"),G_ColorYellowPro,nil,nil,20})
        table.insert(textlist,1,{getlocal("activity_cjyx_rankrule4",{needRank})})
        table.insert(textlist,1,{getlocal("activity_cjyx_rankrule3")})
        table.insert(textlist,1,{getlocal("activity_cjyx_rankrule2",{acCjyxVoApi:getRankLimit()})})
        if mustModeFlag==true then
            local mustRewardCfg=acCjyxVoApi:getMustReward()
            local reward1=mustRewardCfg[1]
            local reward2=mustRewardCfg[2]
            local rewardStr1=reward1.name.."x"..FormatNumber(reward1.num)
            local rewardStr2=reward2.name.."x"..FormatNumber(reward2.num)
            local rewardStr=rewardStr1..getlocal("and_text")..rewardStr2
            table.insert(textlist,1,{getlocal("activity_cjyx_korea_rankrule1",{rewardStr})})
        else
            table.insert(textlist,1,{getlocal("activity_cjyx_rankrule1")})
        end
    end
    if textlist then
        require "luascript/script/game/scene/gamedialog/textSmallDialog"
        textSmallDialog:showTextDialog("TankInforPanel.png",CCSizeMake(500,10),CCRect(130,50,1,1),title,textlist,true,true,self.layerNum+1)
    end
end

function acCjyxDialog:refreshInfo()
    -- if self.descLb then
    --     local descStr=getlocal("activity_midautumn_desc"..(self.selectedTabIndex+1))
    --     self.descLb:setString(descStr)
    -- end
    if self.acLabel and self.moveBgStarStr and self.timeLb then
        if self.selectedTabIndex==1 then
            self.moveBgStarStr:setVisible(true)
            self.acLabel:setVisible(false)
            self.timeLb:setVisible(false)
        else
            self.moveBgStarStr:setVisible(false)
            self.acLabel:setVisible(true)
            self.timeLb:setVisible(true)
        end
    end
end

function acCjyxDialog:tabClick(idx,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    local function realSwitchSubTab()
        for k,v in pairs(self.allTabs) do
            if v:getTag()==idx then
                v:setEnabled(false)
                self:getDataByIdx(idx+1)
                self.selectedTabIndex=idx
            else
                v:setEnabled(true)
            end
        end
    end
    realSwitchSubTab()
end

function acCjyxDialog:goTaskDialog()
    self.oldSelectedTabIndex=self.selectedTabIndex
    self:tabClickColor(1)
    self:tabClick(1,false)
end

function acCjyxDialog:hideTabAll()
    for i=1,2 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end
function acCjyxDialog:getDataByIdx(tabType)
    self:hideTabAll()
    if tabType==nil then
        tabType=1
    end
    self:switchTab(tabType)

    if tabType==2 then
        local flag=acCjyxVoApi:acIsStop()
        local ranklist=acCjyxVoApi:getRankList()
        if flag==false or (flag==true and ranklist==nil) then
            local function callback()
                self:switchTab(tabType)
                self["cjyxTab2"]:updateUI()
            end
            acCjyxVoApi:cjyxAcRequest("active.cjyx.rank",nil,callback)
        else
            self:switchTab(tabType)
        end
    else
        self:switchTab(tabType)
    end
end

function acCjyxDialog:switchTab(tabType)
    if tabType==nil then
        tabType=1
    end
   	if self["cjyxTab"..tabType]==nil then
   		local tab
   		if(tabType==1)then
	   		tab=acCjyxLottery:new()
	   	elseif(tabType==2)then
	   		tab=acCjyxRank:new()
	   	end
	   	self["cjyxTab"..tabType]=tab
	   	self["layerTab"..tabType]=tab:init(self.layerNum,self)
	   	self.bgLayer:addChild(self["layerTab"..tabType],10)
   	end
    for i=1,2 do
    	if(i==tabType)then
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(0,0))
    			self["layerTab"..i]:setVisible(true)
                if self["cjyxTab"..tabType].updateUI then
                    self["cjyxTab"..tabType]:updateUI()
                end
    		end
    	else
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(999333,0))
    			self["layerTab"..i]:setVisible(false)
    		end
    	end
    end
    self:refreshInfo()
end


function acCjyxDialog:tick()
    self:updateAcTime()
    if acCjyxVoApi:isEnd()==true then
        self:close()
        do return end
    end
    if self and self.bgLayer then
        for i=1,2 do
            if self["cjyxTab"..i]~=nil and self["cjyxTab"..i].tick then
                self["cjyxTab"..i]:tick()
            end
        end
    end

    if self.isEnd~=acCjyxVoApi:acIsStop() then
        self.isEnd=acCjyxVoApi:acIsStop()
    end
end

function acCjyxDialog:refreshIconTipVisible()
    if acCjyxVoApi:acIsStop()==true then
        -- local canReward1=acCjyxVoApi:canRankReward(1)
        -- local canReward2=acCjyxVoApi:canRankReward(2)
        -- if canReward1==false and canReward2==false then
        --     if self.setIconTipVisibleByIdx then
        --         self:setIconTipVisibleByIdx(false,2)
        --     end
        -- else
        --     if self.setIconTipVisibleByIdx then
        --         self:setIconTipVisibleByIdx(true,2)
        --     end
        -- end
    end
end

function acCjyxDialog:dispose()
    if self.cjyxTab1 then
        self.cjyxTab1:dispose()
    end
    if self.cjyxTab2 then
        self.cjyxTab2:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    
    self.cjyxTab1=nil
    self.cjyxTab2=nil

    self.isEnd=false
    self.descLb=nil
    self.acLabel=nil
    self.timeLb=nil
    self.moveBgStarStr=nil
    spriteController:removePlist("public/acBlessWords.plist")
    spriteController:removeTexture("public/acBlessWords.png")
    spriteController:removePlist("public/acAnniversary.plist")
    spriteController:removeTexture("public/acAnniversary.png")
    spriteController:removePlist("public/acCjyx_images.plist")
    spriteController:removeTexture("public/acCjyx_images.png")
end
