CGoods = classGc(function(self,_nType)
    self.m_nType=_nType
end)

function CGoods.init(self,uid,ackGoodsData)
    self.m_nID = uid 
    local goodsId = ackGoodsData.goods_id
    CCLOG("CGoods.init  goodsId=%d",goodsId)

    self.ackGoodsData=ackGoodsData
    self.m_lpContainer=cc.Node:create() --总层
    self.m_lpContainer:setTag(168)
    self.m_lpContainer:setPosition(ackGoodsData.pos_x,ackGoodsData.pos_y)

    local dropCnf=_G.g_CnfDataManager:getDropGoodsData(goodsId)
    local dropSkin,goodsName
    if dropCnf then
        dropSkin=dropCnf.skin_id
        goodsName=dropCnf.icon_name
    else
        dropSkin=0
        goodsName="不存在"
    end

    -- local goodsData=_G.g_CnfDataManager:getGoodsData(goodsId)

    local szImg=_G.ImageAsyncManager:getDropIconPath(dropSkin)
    local tempSpr=cc.Sprite:createWithSpriteFrameName(szImg)
    local tempSize=tempSpr:getContentSize()
    tempSpr:setPosition(0,tempSize.height*0.5)
    -- tempSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(0,10)),cc.MoveBy:create(0.5,cc.p(0,-10)))))
    self.m_lpContainer:addChild(tempSpr)

    -- local lpShadow=cc.Sprite:createWithSpriteFrameName("general_shadow.png")
    -- self.m_lpContainer:addChild(lpShadow,-10)
    
    self.m_goodsName=goodsName
    self.m_goodsNameLabel=_G.Util:createBorderLabel(goodsName,16)
    self.m_goodsNameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GREEN))
    self.m_goodsNameLabel:setPosition(tempSize.width*0.5,tempSize.height+10)
    tempSpr:addChild(self.m_goodsNameLabel)

    

    self.speed = 300
    self.delayInterval=1
    self.lastRecordTime=_G.TimeUtil:getNowMilliseconds()

    self.m_nLocationX,self.m_nLocationY=ackGoodsData.pos_x,ackGoodsData.pos_y
    self:setZOrder(-ackGoodsData.pos_y)

    self.worldCollider={}
    self.worldCollider.width=200
    self.worldCollider.height=110
    self.worldCollider.x=ackGoodsData.pos_x-self.worldCollider.width/2
    self.worldCollider.y=ackGoodsData.pos_y-self.worldCollider.height/2
    
    self.m_SkinId=0

    self:jumpEffect()

    CCLOG("success CGoods.init")
end

function CGoods.jumpEffect(self)
    local function onActionCallFunc()
        self.m_isCanPickup=true

        self.m_lpContainer:setPosition(cc.p(self:convertLimitPos(self.m_lpContainer:getPosition())))
    end
    local rolePlayer = _G.g_Stage.m_lpPlay
    local sign = 1
    if self.ackGoodsData.pos_x<rolePlayer.m_nLocationX then
        sign=-1
    end

    local act1=cc.MoveBy:create(0.17,cc.p(30*sign,120))
    local act2=cc.MoveBy:create(0.1,cc.p(10*sign,0))
    local act3=cc.MoveBy:create(0.15,cc.p(25*sign,-120))
    local act4=cc.CallFunc:create(onActionCallFunc)
    local sequence=cc.Sequence:create(act1,act2,act3,act4)

    self.m_lpContainer:runAction(sequence)
end

function CGoods.convertLimitPos(self, x , y )
    local lx = _G.g_Stage:getMaplx()
    local rx = _G.g_Stage:getMaprx()
    x=x<=lx and lx or x
    x=x>=rx and rx or x

    local maxY,minY = _G.g_Stage:getMapLimitHeight(x)
    y=y<=minY and minY or y
    y=y>=maxY and maxY or y
    return x,y
end

function CGoods.getID( self )
    return self.m_nID
end

function CGoods.getType( self )
    return self.m_nType
end

function CGoods.getProperty(self)
    -- body
end

CGoods.onUpdate=nil
CGoods.onUpdateMove=nil

function CGoods.getLocationXY( self )
    return self.m_nLocationX, self.m_nLocationY
end

function CGoods.setLocationXY( self,x,y )
    self.m_lpContainer:setPosition(x,y)
end

function CGoods.setZOrder( self, _z )
    self.m_lpContainer:setLocalZOrder( _z )
end

function CGoods.onRoleEnter(self, mainPlayer)
    if self.m_isCanPickup~=true then
        return false
    end

    local goodsRect=cc.rect(self.worldCollider.x, self.worldCollider.y, self.worldCollider.width, self.worldCollider.height)
    if cc.rectContainsPoint(goodsRect,cc.p(mainPlayer:getLocationXY())) then
        return true
    end
    return false
end

function CGoods.releaseResource( self )
    if self.m_lpContainer~=nil then
        self.m_lpContainer:removeFromParent(true)
        self.m_lpContainer=nil
    end
    GCLOG("CGoods.releaseResource====>>>>self.m_nID=%d",self.m_nID)
end

function CGoods.getContainer( self )
    return self.m_lpContainer
end

function CGoods.getWorldCollider(self)
    return self.worldCollider
end

function CGoods.pickUp(self,rolePlayer)
    if self.m_lpContainer==nil then 
        return 
    end

    if _G.g_Stage:getScenesType()==_G.Const.CONST_MAP_TYPE_COPY_BOX then
        local msg=REQ_MIBAO_GOODS_GET()
        msg:setArgs(self.m_nID)
        _G.Network:send(msg)
        return
    else
        local msg=REQ_SCENE_GET_GOODS()
        msg:setArgs(self.ackGoodsData.goods_id,self.ackGoodsData.count)
        _G.Network:send(msg)
    end

    self:showPickUpOkAction()
end

function CGoods.showPickUpOkAction(self,_tempPlayer,_isShowTips)
    if self.m_isHasDestroy then
        return
    end

    local function actionCallFunc()
        _G.g_Stage:removeCharacter(self)
    end
    
    _G.CharacterManager:remove(self)

    _tempPlayer = _tempPlayer or _G.g_Stage:getMainPlayer()
    local act1=cc.MoveTo:create(0.2,cc.p(_tempPlayer:getLocationXY()))
    local act2=cc.CallFunc:create(actionCallFunc)
    local sequence=cc.Sequence:create(act1,act2)
    self.m_lpContainer:runAction(sequence)

    if _isShowTips then
        local szMsg=string.format("%s *%d",self.m_goodsName,self.ackGoodsData.count)
        local command=CErrorBoxCommand(szMsg)
        command.color=_G.Const.CONST_COLOR_GREEN
        _G.controller:sendCommand(command)
    end

    -- _G.Util:playAudioEffect("money_gather")

    self.m_isHasDestroy=true
end

function CGoods.setOwnerInfo(self,_ownerUid,_szName)
    local mainUid=_G.GPropertyProxy:getMainPlay():getUid()
    if _ownerUid==nil or _ownerUid==0 or mainUid==_ownerUid then
        self.m_goodsNameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GREEN))
        self.m_isOrtherGoods=false
    else
        self.m_goodsNameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
        self.m_isOrtherGoods=true
    end
    self.m_ownerUid=_ownerUid
end
function CGoods.isOthers(self)
    return self.m_isOrtherGoods
end
function CGoods.getOwnerUid(self)
    return self.m_ownerUid
end