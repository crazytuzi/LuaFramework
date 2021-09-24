acTankBattleEndDialog = commonDialog:new()

function acTankBattleEndDialog:new(parent,count,point)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.height = 130
    self.touchArr={}
    self.flag1=false 
    self.flag2=false
    self.touchEnable=true
    self.parent=parent
    self.count=count
    self.point=point

    return nc
end

function acTankBattleEndDialog:resetTab()
    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 105))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 10))
    self.panelLineBg:setVisible(false)
    self.bgLayer:setOpacity(0)
    
    self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-1)
    self.closeBtn:setVisible(false)

    self:initLayer()

end

function acTankBattleEndDialog:initTableView()
end

function acTankBattleEndDialog:initLayer()
    self.clayer=CCLayerColor:create(ccc4(0,0,0,255))
    self.clayer:setPosition(0,(G_VisibleSizeHeight-640)/2)
    self.bgLayer:addChild(self.clayer) 
    self.clayer:setOpacity(180)
    self.clayer:setBSwallowsTouches(false)
    self.clayer:setTouchEnabled(true)
    self.clayer:setContentSize(CCSizeMake(640,640))
    local function tmpHandler(...)
       
    end
    self.clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-4,true)
    self.clayer:setTouchPriority(-(self.layerNum-1)*20-2)
    self.clayer:setBSwallowsTouches(true)
    self:initMap()
end

function acTankBattleEndDialog:initMap()
   
    local spriteBatch = CCSpriteBatchNode:create("public/acTankBattle.png")
    self.bgLayer:addChild(spriteBatch,2)

    local zhuanTb={ccp(198, 622),ccp(186, 622),ccp(174, 622),ccp(162, 622),ccp(150, 622),ccp(198, 550),ccp(186, 550),ccp(174, 550),ccp(162, 550),ccp(150, 550),ccp(150, 610),ccp(150, 598),ccp(150, 586),ccp(150, 574),ccp(150, 562),ccp(138, 610),ccp(138, 598),ccp(138, 586),ccp(138, 574),ccp(138, 562),ccp(209, 610),ccp(209, 598),ccp(209, 586),ccp(209, 574),ccp(209, 562),ccp(197, 610),ccp(197, 598),ccp(197, 586),ccp(197, 574),ccp(197, 562),ccp(236, 622),ccp(248, 622),ccp(236, 610),ccp(248, 610),ccp(236, 598),ccp(248, 598),ccp(236, 586),ccp(248, 586),ccp(260, 586),ccp(284, 586),ccp(296, 586),ccp(284, 574),ccp(296, 574),ccp(308, 586),ccp(296, 598),ccp(308, 598),ccp(296, 610),ccp(308, 610),ccp(296, 622),ccp(308, 622),ccp(248, 574),ccp(260, 574),ccp(272, 574),ccp(259, 562),ccp(271, 562),ccp(271, 552),ccp(283, 562),ccp(344, 622),ccp(356, 622),ccp(344, 610),ccp(356, 610),ccp(344, 598),ccp(356, 598),ccp(368, 622),ccp(380, 622),ccp(392, 622),ccp(404, 622),ccp(344, 550),ccp(356, 550),ccp(368, 550),ccp(380, 550),ccp(392, 550),ccp(404, 550),ccp(344, 586),ccp(356, 586),ccp(344, 574),ccp(356, 574),ccp(344, 562),ccp(356, 562),ccp(368, 586),ccp(380, 586),ccp(392, 586),ccp(429, 622),ccp(441, 622),ccp(453, 622),ccp(465, 622),ccp(477, 622),ccp(489, 622),ccp(477, 586),ccp(489, 586),ccp(501, 586),ccp(453, 574),ccp(465, 574),ccp(477, 574),ccp(465, 562),ccp(477, 562),ccp(489, 562),ccp(477, 550),ccp(489, 550),ccp(501, 550),ccp(489, 610),ccp(501, 610),ccp(489, 598),ccp(501, 598),ccp(429, 610),ccp(441, 610),ccp(429, 598),ccp(441, 598),ccp(429, 586),ccp(441, 586),ccp(429, 574),ccp(441, 574),ccp(429, 562),ccp(441, 562),ccp(429, 550),ccp(441, 550)}

    for k,v in pairs(zhuanTb) do
        local zhuanIcon=CCSprite:createWithSpriteFrameName("acTankBattle_zhuan.png")
        zhuanIcon:setPosition(v)
        spriteBatch:addChild(zhuanIcon)
        zhuanIcon:setScale(12/32)
        if(G_isIphone5())then
            local y=zhuanIcon:getPositionY()
            zhuanIcon:setPositionY(y+88)
        end
    end

    local caoTb={ccp(210, 737),ccp(198, 737),ccp(186, 737),ccp(174, 737),ccp(162, 737),ccp(210, 665),ccp(198, 665),ccp(210, 677),ccp(198, 677),ccp(210, 689),ccp(198, 689),ccp(186, 665),ccp(210, 701),ccp(198, 701),ccp(186, 701),ccp(174, 665),ccp(162, 665),ccp(162, 725),ccp(150, 725),ccp(150, 713),ccp(138, 713),ccp(150, 701),ccp(138, 701),ccp(150, 689),ccp(138, 689),ccp(162, 677),ccp(150, 677),ccp(261, 737),ccp(273, 737),ccp(285, 737),ccp(261, 689),ccp(273, 689),ccp(285, 689),ccp(285, 725),ccp(297, 725),ccp(249, 725),ccp(261, 725),ccp(237, 713),ccp(249, 713),ccp(237, 701),ccp(249, 701),ccp(237, 689),ccp(249, 689),ccp(297, 713),ccp(309, 713),ccp(297, 701),ccp(309, 701),ccp(297, 689),ccp(309, 689),ccp(297, 677),ccp(309, 677),ccp(297, 665),ccp(309, 665),ccp(237, 677),ccp(249, 677),ccp(237, 665),ccp(249, 665),ccp(348, 737),ccp(336, 737),ccp(348, 725),ccp(360, 725),ccp(336, 725),ccp(372, 713),ccp(384, 713),ccp(360, 713),ccp(372, 701),ccp(372, 689),ccp(384, 701),ccp(360, 701),ccp(348, 713),ccp(336, 713),ccp(348, 701),ccp(336, 701),ccp(348, 689),ccp(336, 689),ccp(348, 677),ccp(336, 677),ccp(348, 665),ccp(336, 665),ccp(408, 737),ccp(396, 737),ccp(408, 725),ccp(396, 725),ccp(384, 725),ccp(408, 713),ccp(396, 713),ccp(408, 701),ccp(396, 701),ccp(408, 689),ccp(396, 689),ccp(408, 677),ccp(396, 677),ccp(408, 665),ccp(396, 665),ccp(441, 737),ccp(453, 737),ccp(465, 737),ccp(477, 737),ccp(489, 737),ccp(501, 737),ccp(465, 665),ccp(477, 665),ccp(489, 665),ccp(501, 665),ccp(441, 725),ccp(453, 725),ccp(441, 713),ccp(453, 713),ccp(441, 701),ccp(453, 701),ccp(465, 701),ccp(477, 701),ccp(489, 701),ccp(441, 689),ccp(453, 689),ccp(441, 677),ccp(453, 677),ccp(441, 665),ccp(453, 665)}
    

    for k,v in pairs(caoTb) do
        local caoIcon=CCSprite:createWithSpriteFrameName("acTankBattle_zhuan.png")
        caoIcon:setPosition(v)
        caoIcon:setScale(12/32)
        spriteBatch:addChild(caoIcon)
        if(G_isIphone5())then
            local y=caoIcon:getPositionY()
            caoIcon:setPositionY(y+88)
        end
    end

    local function nilFunc()
    end
    local whiteLine = LuaCCScale9Sprite:createWithSpriteFrameName("acTankBattle_white.png",CCRect(1, 1, 1, 1),nilFunc)
    whiteLine:setTouchPriority(-(self.layerNum-1)*20-2)
    whiteLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,3))
    whiteLine:setAnchorPoint(ccp(0.5,0.5))
    whiteLine:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-640)/2+160)
    self.bgLayer:addChild(whiteLine)


    -- acTankBattleVoApi:getNumReward(point)
    local sid = acTankBattleVoApi:getSid()
    local heroIcon = heroVoApi:getHeroIcon(sid)
    heroIcon:setAnchorPoint(ccp(0.5,0))
    heroIcon:setScale(100/heroIcon:getContentSize().width)
    heroIcon:setPosition(self.bgLayer:getContentSize().width/2,whiteLine:getPositionY()+60)
    self.bgLayer:addChild(heroIcon)


    local num = acTankBattleVoApi:getNumReward(self.point)

    local numStr = "X" .. num
    local numlb = GetTTFLabel(numStr,25*1.5)
    heroIcon:addChild(numlb)
    numlb:setAnchorPoint(ccp(1,0))
    numlb:setPosition(heroIcon:getContentSize().width-10,7)

    local id=tonumber(sid) or tonumber(RemoveFirstChar(sid))
    local hid = "h" .. id
    local name = getlocal("heroSoul",{heroVoApi:getHeroName(hid)})

    local namelb = GetTTFLabelWrap(name,25,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    namelb:setAnchorPoint(ccp(0.5,0))
    namelb:setPosition(self.bgLayer:getContentSize().width/2,whiteLine:getPositionY()+15)
    self.bgLayer:addChild(namelb)




    self:initMenu(name,num)
end

function acTankBattleEndDialog:initMenu(name,num)
    local strSize = 25
    local function getReward()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        local function callback(fn,data)
            local ret,sData = base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.tankbattle then
                    acTankBattleVoApi:updateSpecialData(sData.data.tankbattle)
                end
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("active_lottery_reward_tank",{name,"*" .. num}),30)
                self:close()
                if self.parent then
                    self.parent:close()
                end
            end
        end
        local sid=acTankBattleVoApi:getSid()

        socketHelper:acTankBattleEnd(self.count,self.point,sid,callback)
    end
    local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",getReward,nil,getlocal("newGiftsReward"),strSize)
    local rewardBtn=CCMenu:createWithItem(rewardItem);
    rewardBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    rewardBtn:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-640)/2+100))
    self.bgLayer:addChild(rewardBtn,2)
end


function acTankBattleEndDialog:tick()
    if acTankBattleVoApi:acIsStop() == true then 
        if self then
            self:close()
            do return end
        end
    end

end

function acTankBattleEndDialog:fastTick()
end

function acTankBattleEndDialog:dispose()
end
