local LoginEffect=classGc(view)

function LoginEffect.getNode(self)
    if self.m_rootLayer==nil then
        self:create()
    elseif self.m_rootLayer:getParent()~=nil then
        self.m_rootLayer:removeFromParent(false)
    end
    return self.m_rootLayer
end

function LoginEffect.releaseResources(self)
    if self.m_rootLayer~=nil then
        if self.m_rootLayer:getParent()~=nil then
            self.m_rootLayer:removeFromParent(true)
        end
        self.m_rootLayer:release()
    end
    -- 释放资源
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function LoginEffect.create(self)
    local function onNodeEvent(event)
        if "enter" == event then
            self:__onEnter()
        elseif "exit" == event then
            self:__onExit()
        end
    end
	self.m_rootLayer=cc.Layer:create()
    self.m_rootLayer:retain()
    self.m_rootLayer:registerScriptHandler(onNodeEvent)
	self:__initView()
	return self.m_rootLayer
end

local FAR=1
local FLOOR=2
local NEAR=3
function LoginEffect.__initView(self)
	local winSize=cc.Director:getInstance():getWinSize()

    self.m_mapNodeArray={}
    self.m_mapPosXArray={}
    for i=1,NEAR do
        local zOrder=i*100
        local node=cc.Node:create()
        self.m_rootLayer:addChild(node,zOrder)
        self.m_mapNodeArray[i]=node
        self.m_mapPosXArray[i]=0
    end
    self.m_roleNode=cc.Node:create()
    self.m_rootLayer:addChild(self.m_roleNode,FLOOR*100+50)

	local posY=175
	local szName,iScale,posX
	szName="spine/10126_walk"
	iScale=0.45
    posX=winSize.width/2-300
	local wkSpine=_G.SpineManager.createSpine(szName,iScale)
    wkSpine:setPosition(posX,posY)
    wkSpine:setAnimation(0,"walk",true)
    self.m_roleNode:addChild(wkSpine)
    local shadowSpr1=cc.Sprite:createWithSpriteFrameName("general_shadow.png")
    shadowSpr1:setPosition(posX,posY)
    self.m_roleNode:addChild(shadowSpr1,-10)

    szName="spine/10131_zbj"
	iScale=0.45
    posX=winSize.width/2+50
	local bjSpine=_G.SpineManager.createSpine(szName,iScale)
    bjSpine:setPosition(posX,posY)
    bjSpine:setAnimation(0,"walk",true)
    self.m_roleNode:addChild(bjSpine)
    local shadowSpr2=cc.Sprite:createWithSpriteFrameName("general_shadow.png")
    shadowSpr2:setPosition(posX,posY)
    self.m_roleNode:addChild(shadowSpr2,-10)

    szName="spine/10141_walk"
	iScale=0.45
    posX=winSize.width/2-150
	local tcSpine=_G.SpineManager.createSpine(szName,iScale)
    tcSpine:setPosition(posX,posY)
    tcSpine:setAnimation(0,"walk",true)
    self.m_roleNode:addChild(tcSpine)
    local shadowSpr3=cc.Sprite:createWithSpriteFrameName("general_shadow.png")
    shadowSpr3:setPosition(posX,posY)
    self.m_roleNode:addChild(shadowSpr3,-10)

    szName="spine/10136_walk"
	iScale=0.45
    posX=winSize.width/2+300
	local szSpine=_G.SpineManager.createSpine(szName,iScale)
    szSpine:setPosition(posX,posY)
    szSpine:setAnimation(0,"walk",true)
    self.m_roleNode:addChild(szSpine)
    local shadowSpr4=cc.Sprite:createWithSpriteFrameName("general_shadow.png")
    shadowSpr4:setPosition(posX,posY)
    self.m_roleNode:addChild(shadowSpr4,-10)

    self.m_mapData=_G.MapData[10521]
    if self.m_mapData==nil then
        _G.Util:showTipsBox("_G.MapData[10521] 为空!")
        return
    end

    self.m_mapWidth=self.m_mapData.mapWidth
    for i,v in pairs(self.m_mapData.data.bg) do
        self:createSpriteByType(v.type,v.name,v.x,v.y,self.m_mapNodeArray[FAR])
    end
    for i,v in pairs(self.m_mapData.data.map) do
        self:createSpriteByType(v.type,v.name,v.x,v.y,self.m_mapNodeArray[FLOOR])
    end
    for i,v in pairs(self.m_mapData.data.topside) do
        self:createSpriteByType(v.type,v.name,v.x,v.y,self.m_mapNodeArray[NEAR])
    end

    self.m_speedArray={}
    self.m_speedArray[FLOOR]=100
    self.m_speedArray[FAR]=self.m_speedArray[FLOOR]*self.m_mapData.data.bg_translationSpeed
    self.m_speedArray[NEAR]=self.m_speedArray[FLOOR]*0.5
    self.m_maxPosX=2048
end

function LoginEffect.createSpriteByType(self,_type,_szName,_x,_y,_node)
    if _type=="png" or _type=="jpg" then
        _szName=string.format("map/%s.%s",tostring(_szName),_type)
        if _G.FilesUtil:check(_szName) then
            local tempSpr1=cc.Sprite:create(_szName)
            tempSpr1:setAnchorPoint(cc.p(0,0))
            tempSpr1:setPosition(cc.p(_x,_y))
            _node:addChild(tempSpr1)

            local tempSpr2=cc.Sprite:create(_szName)
            tempSpr2:setAnchorPoint(cc.p(0,0))
            tempSpr2:setPosition(cc.p(_x+self.m_mapWidth,_y))
            _node:addChild(tempSpr2)
        end
    end
end
function LoginEffect.setMapLocationX(self,_type,_x)
    self.m_mapPosXArray[_type]=_x
    self.m_mapNodeArray[_type]:setPosition(cc.p(_x,0))
end
function LoginEffect.__onEnter(self)
    local function onEnterFrame(_duration)
        -- print("onEnterFrame=============>>>>",_duration)
        for i=1,NEAR do
            local node=self.m_mapNodeArray[i]
            local speed=self.m_speedArray[i]
            local curX=self.m_mapPosXArray[i]
            local distance=speed*_duration
            local newX=curX+distance
            if newX>0 then
                newX=-self.m_maxPosX
            end
            self:setMapLocationX(i,newX)
        end
    end
    print("__onEnter=============>>>>")
    self.m_scheduler=_G.Scheduler:schedule(onEnterFrame,0)
end
function LoginEffect.__onExit(self)
    print("__onExit=============>>>>")
    if self.m_scheduler~=nil then
        _G.Scheduler:unschedule(self.m_scheduler)
        self.m_scheduler=nil
    end
end

return LoginEffect