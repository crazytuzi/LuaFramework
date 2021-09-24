serverWarLocalInforTab3={}

function serverWarLocalInforTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function serverWarLocalInforTab3:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    spriteController:addTexture("public/serverWarLocal/serverWarLocalMiniMap.jpg")
    self:refreshMiniMap()
    return self.bgLayer
end

function serverWarLocalInforTab3:refreshMiniMap()
    if(self.miniMap)then
        self.miniMap:removeFromParentAndCleanup(true)
        self.miniMap=nil
    end
    self.miniMap=CCLayer:create()
    self.bgLayer:addChild(self.miniMap)
    local miniMap = CCSprite:createWithTexture(spriteController:getTexture("public/serverWarLocal/serverWarLocalMiniMap.jpg"))
    miniMap:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.miniMap:addChild(miniMap)
    local posTb={a1={163.5, 486.5},a2={275.5, 486.5},a3={407.5, 486.5},a4={97.5, 419.5},a5={151.5, 442.5},a6={269.5, 442.5},a7={419.5, 431.5},a8={477.5, 431.5},a9={43.5, 392.5},a10={98.5, 380.5},a11={163.5, 392.5},a12={281.5, 392.5},a13={407.5, 392.5},a14={465.5, 380.5},a15={508.5, 392.5},a16={220.5, 339.5},a17={275.5, 327.5},a18={341.5, 327.5},a19={43.5, 282.5},a20={98.5, 270.5},a21={163.5, 259.5},a22={209.5, 282.5},a23={281.5, 270.5},a24={341.5, 270.5},a25={413.5, 270.5},a26={465.5, 259.5},a27={508.5, 270.5},a28={221.5, 210.5},a29={275.5, 210.5},a30={341.5, 210.5},a31={43.5, 161.5},a32={98.5, 149.5},a33={163.5, 149.5},a34={281.5, 149.5},a35={408.5, 149.5},a36={465.5, 161.5},a37={508.5, 149.5},a38={86.5, 105.5},a39={150.5, 117.5},a40={293.5, 105.5},a41={390.5, 106.5},a42={465.5, 93.5},a43={162.5, 59.5},a44={274.5, 59.5},a45={407.5, 47.5}}
    local map={}
    for k,v in pairs(serverWarLocalFightVoApi:getAllianceList()) do
        map[v.id]=v
    end
    for cityID,cityVo in pairs(serverWarLocalFightVoApi:getCityList()) do
        local cityPoint=CCSprite:createWithSpriteFrameName("localWar_miniMap_point.png")
        local colorTb
        if(map[cityVo.allianceID]==nil)then
            colorTb={255,255,255}
        elseif(map[cityVo.allianceID].side==1)then
            colorTb={255, 50, 50}            
        elseif(map[cityVo.allianceID].side==2)then
            colorTb={218, 30, 214}
        elseif(map[cityVo.allianceID].side==3)then
            colorTb={0, 255, 255}
        elseif(map[cityVo.allianceID].side==4)then
            colorTb={56,246,154}
        else
            colorTb={255,255,255}
        end
        cityPoint:setColor(ccc3(colorTb[1],colorTb[2],colorTb[3]))
        if(serverWarLocalFightVoApi:checkCityInWar(cityID))then
            --明暗交替
            local fadeOut=CCTintTo:create(1,50,50,50)
            local fadeIn=CCTintTo:create(1,colorTb[1],colorTb[2],colorTb[3])
            local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
            cityPoint:runAction(CCRepeatForever:create(seq))
        end
        cityPoint:setPosition(ccp(posTb[cityID][1],posTb[cityID][2]))
        miniMap:addChild(cityPoint)
    end
    for i=1,5 do
        local cityPoint=CCSprite:createWithSpriteFrameName("localWar_miniMap_point.png")
        local nameLb
        if(i<5)then
            for allianceID,allianceVo in pairs(map) do
                if(allianceVo.side==i)then
                    nameLb=GetTTFLabel(allianceVo.name,22)
                    break
                end
            end            
        else
            nameLb=GetTTFLabel(getlocal("local_war_cityStatus2"),22)
        end
        if(nameLb==nil)then
            nameLb=GetTTFLabel(getlocal("alliance_info_content"),22)
        end
        if(i<4)then
            cityPoint:setPosition(ccp(70 + (i-1)*190,160))
            nameLb:setPosition(ccp(90 + (i-1)*190,160))
        else
            cityPoint:setPosition(ccp(70 + (i-4)*190,110))
            nameLb:setPosition(ccp(90 + (i-4)*190,110))
        end
        if(i==1)then
            cityPoint:setColor(ccc3(255, 50, 50))
        elseif(i==2)then
            cityPoint:setColor(ccc3(218, 30, 214))
        elseif(i==3)then
            cityPoint:setColor(ccc3(0, 255, 255))
        elseif(i==4)then
            cityPoint:setColor(ccc3(56,246,154))
        end
        self.miniMap:addChild(cityPoint)
        nameLb:setAnchorPoint(ccp(0,0.5))
        self.miniMap:addChild(nameLb)
    end
    local descLb=GetTTFLabelWrap(getlocal("local_war_miniMapDesc"),22,CCSizeMake(520,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    descLb:setColor(G_ColorYellowPro)
    descLb:setPosition(ccp(G_VisibleSizeWidth/2,45))
    self.miniMap:addChild(descLb)
end

function serverWarLocalInforTab3:tick()
end

function serverWarLocalInforTab3:dispose()
    spriteController:removeTexture("public/serverWarLocal/serverWarLocalMiniMap.jpg")
end
