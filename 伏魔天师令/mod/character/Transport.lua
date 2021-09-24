CTransport = classGc(function(self,_nType)
   self.m_nType = _nType
end)

function CTransport.transportInit(self,uid, transportData,_x,_y )
    self.m_doorType =transportData.type
    self.m_transferID = transportData.transfer_id
    self.m_materialId = transportData.material_id
    self.m_nRoleEnterRadius = _G.Const.CONST_TASK_TALK_DISTANCE-8

    self.m_lpContainer = cc.Node:create() --总层

    self.m_bRoleEnter = false --玩家是否进入

    self:setLocationXY(_x,_y)
    self.m_nID =uid
    self.m_SkinId = transportData.material_id 
    self:showBody()
end

function CTransport.releaseResource( self )
    if self.m_lpContainer~=nil then
        self.m_lpContainer:removeFromParent(true)
        self.m_lpContainer=nil
    end
end

function CTransport.getProperty(self)
end

function CTransport.showBody(self)
    local spine = _G.SpineManager.createSpine(string.format("spine/%d",self.m_materialId),1)
    spine : setAnchorPoint(cc.p(0.5,0.1))
    spine : setAnimation(0,"idle",true)
    self.m_lpContainer : addChild(spine)
end

--设置生物坐标， x,y,z
function CTransport.setLocationXY( self, _x, _y)
    _x,_y = self:convertLimitPos( _x, _y)
    -- print("ssssss",_x,_y)
    self.m_nLocationX = _x
    self.m_nLocationY = _y
    self.m_lpContainer:setPosition( _x, _y)
end

function CTransport.convertLimitPos( self, _x , _y )
    local maxY,minY = _G.g_Stage:getMapLimitHeight(_x)
    maxY=maxY-30
    minY=minY

    _y=_y<=minY and minY or _y
    _y=_y>=maxY and maxY or _y

    local lx = _G.g_Stage:getMaplx()+80
    local rx = _G.g_Stage:getMaprx()-100

    _x=_x<=lx and lx or _x
    _x=_x>=rx and rx or _x
    return _x,_y
end

-- function CTransport.setStage( self, _lpStage )
-- end

function CTransport.checkZone(self,_fRoleX,_fRoleY)
    if math.abs(self.m_nLocationX - _fRoleX)>self.m_nRoleEnterRadius 
        or math.abs(self.m_nLocationY - _fRoleY)>self.m_nRoleEnterRadius then
        return false
    end
    self:goNextScene()
    return true
end

function CTransport.goNextScene(self)
    if self.m_doorType == _G.Const.CONST_MAP_DOOR_MAP then --主城 发送服务器.由服务器下发
        print("_G.Const.CONST_MAP_DOOR_MAP")
        local msg=REQ_SCENE_ENTER_FLY()
        msg:setArgs(self.m_transferID)
        _G.Network:send(msg)
        
        print("self.m_transferID=",self.m_transferID)
    elseif self.m_doorType == _G.Const.CONST_MAP_DOOR_OPEN then -- 打开界面
        print("_G.Const.CONST_MAP_DOOR_OPEN")
        -- if self.m_transferID == _G.Const.CONST_MAP_OPEN_COM_COPY then --副本界面
            _G.GLayerManager :openLayer(Cfg.UI_CCopyMapLayer)
        -- end
        _G.g_Stage:getMainPlayer():cancelMove()
    elseif self.m_doorType == _G.Const.CONST_MAP_DOOR_NEXT_COPY or self.m_doorType==5 or self.m_doorType==6 then --进入下层副本
        CCLOG("进入下个场景。。。_G.Const.CONST_MAP_DOOR_NEXT_COPY")

        local rolePlayer = _G.g_Stage.m_lpPlay
        local nextCopyHpData={}
        nextCopyHpData[1]=rolePlayer:getHP()
        nextCopyHpData[2]=_G.g_Stage:getMonsHp()

        local partnerWar = rolePlayer:getProperty():getWarPartner()
        local roleUid = rolePlayer:getProperty():getUid()

        if partnerWar~=nil then
            local partnerIdx=partnerWar:getPartner_idx()
            local indexID= tostring(roleUid)..tostring(partnerIdx)
            local tempCharacter=_G.CharacterManager:getCharacterByTypeAndID( _G.Const.CONST_PARTNER,indexID)
            if tempCharacter~=nil then
                nextCopyHpData[3]=tempCharacter:getHP()
            end
        end

        local isAutoFight =_G.g_Stage.isAutoFightMode==168 and true or nil
        local mSkillCD
        if _G.g_Stage.m_mountSkillTime~=nil then
            mSkillCD=-(_G.TimeUtil:getTotalMilliseconds()-_G.g_Stage.m_mountSkillTime)/1000
            if mSkillCD<0 then mSkillCD=0 end
        end
        if _G.g_Stage.m_artifactSkillTime~=nil then
            aSkillCD=-(_G.TimeUtil:getTotalMilliseconds()-_G.g_Stage.m_artifactSkillTime)/1000
            if aSkillCD<0 then aSkillCD=0 end
        end

        _G.g_nextCopyData={
            attributeAdds=_G.g_Stage.m_attributeAdds,
            nextCopyHpData=nextCopyHpData,
            isAutoFight=isAutoFight,
            playerMP=rolePlayer:getMP(),
            mountSkillCd=mSkillCD,
            artifactSkillCd=aSkillCD,
            parHp=rolePlayer.m_parHp and rolePlayer.m_parHp or false,
            copyPassLimitTimes=_G.g_Stage.m_copyPassLimitTimes,
            copyPassAllowTimes=_G.g_Stage.m_copyPassAllowTimes,
        }
        if _G.g_BattleView then
            if _G.g_Stage:getScenesType()==_G.Const.CONST_MAP_TYPE_COPY_NORMAL then
                _G.g_nextCopyData.preCondTimes=_G.g_BattleView:getNormalCopyRemainingTimes()
            else
                _G.g_nextCopyData.preCondTimes=_G.g_BattleView.m_conditionTimes
            end
        end

        print("CTransport.onRoleEnter ===================>>>")
        print("isAutoFight=",isAutoFight)
        for k,v in pairs(nextCopyHpData) do
            print(k,v)
        end

        local mapID=1
        if _G.g_Stage:getScenesType()==_G.Const.CONST_MAP_CLAN_WAR
            or _G.g_Stage:getScenesType()==_G.Const.CONST_MAP_CLAN_DEFENSE
            or _G.g_Stage:getScenesType()==_G.Const.CONST_MAP_TYPE_COPY_BOX then
            mapID=self.m_nID
        end
        local msg=REQ_SCENE_ENTER()
        msg:setArgs(mapID)
        _G.Network:send(msg)
        
    elseif self.m_doorType==_G.Const.CONST_MAP_DOOR_EXIT_COPY then
        CCLOG(" CTransport.onRoleEnter  走进副本出口")
        _G.g_Stage:exitCopy()
    end
end