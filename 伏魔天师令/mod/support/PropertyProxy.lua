local PropertyProxy = classGc(function(self)
    self.m_lpMainPlay = nil --主人物
    self.m_lpChallengePanePlayInfo = nil -- 逐鹿台PK人物

    self.m_lpPlayList = {} --其他人物列表
    self.m_lpPartnerList = {} --伙伴列表
    self.m_lpMonsterList = {} --怪物列表
    self.m_lpHookList = {} --陷阱列表

    self.m_mediator=require("mod.support.PropertyProxyMediator")(self)
end)

function PropertyProxy.mediatorFunction(self,_funName,_data)
    if self.m_mediator[_funName]~=nil then
        self.m_mediator[_funName](self.m_mediator,_data)
    end
end

function PropertyProxy.resetMainPlay(self)
    if self.m_lpMainPlay==nil then return end
    local newproperty={}
    local mt = getmetatable(self.m_lpMainPlay)
    setmetatable(newproperty, mt)
    for i,v in pairs(self.m_lpMainPlay) do
        newproperty[i] = v
    end
    newproperty.attr=newproperty.attr:clone()
    self.m_lpMainPlay=newproperty
    self.m_lpPlayList[newproperty:getUid()]=newproperty
end

-- {初始化主角}
function PropertyProxy.initMainPlay( self, _uid )
    if self.m_lpMainPlay~=nil then
        self:removePlayer(self.m_lpMainPlay:getUid())
        self.m_lpMainPlay=nil
    end
    
    self.m_lpMainPlay=require("mod.support.Property")()
    self.m_lpMainPlay:setUid( _uid )
    self:addOne( self.m_lpMainPlay, _G.Const.CONST_PLAYER )

    self.m_mediator.m_mainUid=_uid
end

function PropertyProxy.getMainPlay( self )
    return self.m_lpMainPlay
end

function PropertyProxy.getChallengePanePlayInfo( self )
    return self.m_lpChallengePanePlayInfo
end
function PropertyProxy.setChallengePanePlayInfo( self, _info )
    self.m_lpChallengePanePlayInfo = _info
end

-- {获取人物属性}
function PropertyProxy.getOneByUid( self, _uid, _characterType )
    if _uid == 0 then
        return self.m_lpMainPlay
    else
        if _G.Const.CONST_PLAYER == _characterType then
            return self.m_lpPlayList[_uid]
        elseif _G.Const.CONST_PARTNER == _characterType then
            return self.m_lpPartnerList[tostring(_uid)]
        elseif _G.Const.CONST_MONSTER == _characterType then
            return self.m_lpMonsterList[_uid]
        elseif _G.Const.CONST_HOOK == _characterType or _G.Const.CONST_GOODS_MONSTER == _characterType or _G.Const.CONST_TRAP == _characterType then
            return self.m_lpHookList[_uid]
        end
    end
end

-- {清空人物内存}
function PropertyProxy.cleanUp( self )
    print("PropertyProxy.cleanUp: 清除人物属性缓存")

    self.m_lpPlayList = {}
    if self.m_lpMainPlay ~= nil then
        print("PropertyProxy.cleanUp: 保存主角人物属性UID:"..tostring(self.m_lpMainPlay : getUid()))
        local mainPlayUid = self.m_lpMainPlay : getUid()
        self.m_lpPlayList[mainPlayUid] = self.m_lpMainPlay
        if self.m_lpChallengePanePlayInfo ~= nil then
            print("保存在竞技场里面对手UID："..tostring(self.m_lpChallengePanePlayInfo : getUid()))
            local pkPlayUid = self.m_lpChallengePanePlayInfo : getUid()
            if pkPlayUid ~= nil then
                print("~!@#$^&: 保存对手人物属性")
                self.m_lpPlayList[pkPlayUid] = self.m_lpChallengePanePlayInfo
            end
        end
    end
    self.m_lpMonsterList = {}

    local list = {}
    for uid,info in pairs(self.m_lpPartnerList) do
        print("伙伴主人UID:"..tostring(info : getUid()).." 伙伴Index: "..tostring(uid))

        if info : getUid() == self.m_lpMainPlay : getUid() then
            print("保存主角伙伴属性index: "..tostring(uid).." 主人UID: "..tostring(self.m_lpMainPlay : getUid()))
            list[uid] = info
        end
        if self.m_lpChallengePanePlayInfo ~= nil then
            if info : getUid() == self.m_lpChallengePanePlayInfo : getUid() then
                print("保存对手伙伴属性index: "..tostring(uid).." 对手UID: "..tostring( self.m_lpChallengePanePlayInfo : getUid()))
                list[uid] = info
            end
        end
    end
    self.m_lpPartnerList = list
end

-- {添加某一个}
function PropertyProxy.addOne( self, _characterProperty, _characterType )
    -- print("PropertyProxy.addOne",_characterProperty,_characterType)
    if _G.Const.CONST_PLAYER==_characterType then
        self.m_lpPlayList[_characterProperty:getUid()] = _characterProperty
    elseif _G.Const.CONST_PARTNER == _characterType then
        local index      = tostring( _characterProperty : getUid())..tostring(_characterProperty : getPartner_idx())
        self.m_lpPartnerList[index] = _characterProperty
    elseif _G.Const.CONST_MONSTER == _characterType then
        self.m_lpMonsterList[_characterProperty : getUid()] = _characterProperty
    elseif _G.Const.CONST_HOOK == _characterType or _G.Const.CONST_GOODS_MONSTER == _characterType or _G.Const.CONST_TRAP == _characterType then
        self.m_lpHookList[_characterProperty : getUid()] = _characterProperty
    end
end

-- {移除某一个.主角除外}
function PropertyProxy.removeOne( self, _uid, _characterType )
    print( " PropertyProxy.removeOne:", _uid, _characterType)
    if _G.Const.CONST_PLAYER == _characterType then
        self:removePlayer(_uid)
    elseif _G.Const.CONST_PARTNER == _characterType then
        self:removePartner(_uid)
    elseif _G.Const.CONST_MONSTER == _characterType then
        self:removeMonster(_uid)
    end
end
function PropertyProxy.removePlayer(self,_uid)
    if _uid==self.m_lpMainPlay:getUid() then return end
    self.m_lpPlayList[_uid]=nil
end
function PropertyProxy.removePartner(self,_uid)
    self.m_lpPartnerList[_uid]=nil
end
function PropertyProxy.removeMonster(self,_uid)
    self.m_lpMonsterList[_uid]=nil
end

function PropertyProxy.resetMainPlayHp( self )
    local mainHp = self.m_lpMainPlay : getAttr() : getNowMaxHp()
    self.m_lpMainPlay : getAttr() : setHp(mainHp)
    local warPartner=self.m_lpMainPlay:getWarPartner()
    if warPartner~=nil then
        local partnerIdx=warPartner:getPartner_idx()
        local index=tostring(self.m_lpMainPlay:getUid())..tostring(partnerIdx)
        local partnerProperty=self:getOneByUid(index,_G.Const.CONST_PARTNER)
        if partnerProperty~=nil then
            local partnerMaxHp=partnerProperty:getAttr():getNowMaxHp()
            partnerProperty:getAttr():setHp(partnerMaxHp)
        end
    end
end

function PropertyProxy.setAutoPKSceneId(self,autoPKSceneId)
    self.autoPKSceneId=autoPKSceneId
end

function PropertyProxy.getAutoPKSceneId(self)
    return self.autoPKSceneId
end

return PropertyProxy