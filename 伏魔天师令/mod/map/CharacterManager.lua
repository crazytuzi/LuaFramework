local CharacterManager=classGc(function(self)
    self:init()
end)

function CharacterManager.init( self )
    self.m_lpPlayerArray = {}
    self.m_lpPartnerArray = {}
    self.m_lpMonsterArray = {}
    self.m_lpNpcArray = {}
    self.m_lpPetArray = {}
    self.m_lpTransportArray = {}
    self.m_lpVitroArray = {}
    self.m_lpCharacterArray = {}
    self.m_lpNoHookArray = {}
    self.m_lpGoodsArray={}
    self.m_lpGoodsMonsterArray={}
    self.m_lpdiaoxiangMonsterArray={}
    self.m_lpBoxMonsterArray={}
    self.m_lpHookArray={}
    self.m_lpTrapArray={}
    self.m_lpCorpseArray={}
    self.m_lpHireArray={}

    self[_G.Const.CONST_PLAYER] = self.m_lpPlayerArray    -- [1]玩家 -- 系统
    self[_G.Const.CONST_PARTNER] = self.m_lpPartnerArray    -- [2]伙伴 -- 系统
    self[_G.Const.CONST_MONSTER] = self.m_lpMonsterArray    -- [3]怪物 -- 系统
    self[_G.Const.CONST_NPC] = self.m_lpNpcArray    -- [4]NPC -- 系统
    self[_G.Const.CONST_PET] = self.m_lpPetArray    -- [5]宠物 -- 系统
    self[_G.Const.CONST_TRANSPORT] = self.m_lpTransportArray   -- [6]传送点
    self[_G.Const.CONST_VITRO] = self.m_lpVitroArray   -- [7]离体攻击
    self[_G.Const.CONST_GOODS] = self.m_lpGoodsArray   -- [8]物品
    self[_G.Const.CONST_GOODS_MONSTER] = self.m_lpGoodsMonsterArray   -- [9]物品怪物
    self[_G.Const.CONST_DEFENSE] = self.m_lpdiaoxiangMonsterArray -- [10] 雕像怪物
    self[_G.Const.CONST_BOX_MONSTER] = self.m_lpBoxMonsterArray  --  [11]盒子怪兽
    self[_G.Const.CONST_HOOK] = self.m_lpHookArray  --  [12]陷阱
    self[_G.Const.CONST_TRAP] = self.m_lpTrapArray  --  [13]滚动陷阱
    self[_G.Const.CONST_TEAM_HIRE] = self.m_lpHireArray  --  [14]雇佣兵
    
end

function CharacterManager.getCharacter( self )
    return self.m_lpCharacterArray
end
function CharacterManager.getNoHookCharacter( self )
    return self.m_lpNoHookArray
end
function CharacterManager.getNpc( self )
    return self.m_lpNpcArray
end
function CharacterManager.getMonster( self )
    return self.m_lpMonsterArray
end
function CharacterManager.getTransport( self )
    return self.m_lpTransportArray
end
function CharacterManager.getPlayer( self )
    return self.m_lpPlayerArray
end

function CharacterManager.getGoods( self )
    return self.m_lpGoodsArray
end

function CharacterManager.getBoxMonster( self )
    return self.m_lpBoxMonsterArray
end

function CharacterManager.getHook( self )
    return self.m_lpHookArray
end
function CharacterManager.getTrap( self )
    return self.m_lpTrapArray
end

function CharacterManager.isMonsterEmpty( self )
    local teamID=_G.GPropertyProxy:getMainPlay():getTeamID()
    for k,v in pairs(self.m_lpMonsterArray) do
        -- print("isMonsterEmpty===>>>",v:getProperty())
        if v:getProperty():getTeamID()~=teamID then
            return false
        end
    end
    return true
    -- return next(self.m_lpMonsterArray)==nil
end

function CharacterManager.isGoodsEmpty( self )
    for k,v in pairs(self.m_lpGoodsArray) do
        if not v:isOthers() then
            return false
        end
    end
    return true
end

function CharacterManager.add( self, _lpCharater )
    -- print("aaaaaaaaa add---->",_lpCharater.onUpdateMove,_lpCharater.m_nType)
    if self[_lpCharater.m_nType] then
        table.insert( self.m_lpCharacterArray, _lpCharater)
        if not(_lpCharater.m_nType == _G.Const.CONST_HOOK 
            or _lpCharater.m_nType == _G.Const.CONST_TRAP
            -- or _lpCharater.m_nType == _G.Const.CONST_GOODS_MONSTER
            ) then
            table.insert( self.m_lpNoHookArray, _lpCharater)
        end
        self[_lpCharater.m_nType][_lpCharater.m_nID] = _lpCharater
    end
end

function CharacterManager.addCorpse( self, _lpCharater )
    self.m_lpCorpseArray[_lpCharater.m_nID] = _lpCharater
end

function CharacterManager.remove( self, _lpCharater )
    -- print("remove----->",debug.traceback())
    local _nCharacterType = _lpCharater.m_nType

    if self[_nCharacterType] then
        self[_nCharacterType][_lpCharater.m_nID] = nil
    end

    for index, character in pairs(self.m_lpCharacterArray) do
        if character == _lpCharater then
            self.m_lpCharacterArray[index] = nil
            break
        end
    end
    if not(_lpCharater.m_nType == _G.Const.CONST_HOOK 
            or _lpCharater.m_nType == _G.Const.CONST_TRAP
            -- or _lpCharater.m_nType == _G.Const.CONST_GOODS_MONSTER
            ) then
        for index, character in pairs(self.m_lpNoHookArray) do
            if character == _lpCharater then
                self.m_lpNoHookArray[index] = nil
                return
            end
        end
    end
end

function CharacterManager.removeNoHookArray( self,_lpCharater )
    for index, character in pairs(self.m_lpNoHookArray) do
        if character == _lpCharater then
            self.m_lpNoHookArray[index] = nil
            return
        end
    end
end
function CharacterManager.checkNoHookArray( self,_lpCharater )
    for index, character in pairs(self.m_lpNoHookArray) do
        if character == _lpCharater then
            return true
        end
    end
    return false
end

function CharacterManager.getMonsterCount(self)
    local nCount=0
    for k,monster in pairs(self.m_lpMonsterArray) do
        if monster.m_nHP>0 then
            nCount=nCount+1
        end
    end
    return nCount
end

function CharacterManager.getPartnerCount(self)
    local nCount=0
    for k,partner in pairs(self.m_lpPartnerArray) do
        if partner.m_nHP>0 then
            nCount=nCount+1
        end
    end
    return nCount
end

function CharacterManager.getPlayerByID( self, _nID )
    return self.m_lpPlayerArray[_nID]
end
function CharacterManager.getCorpseByID( self, _nID )
    return self.m_lpCorpseArray[_nID]
end
function CharacterManager.removeCorpseByID( self, _nID )
    self.m_lpCorpseArray[_nID]=nil
end
function CharacterManager.getCharacterByTypeAndID( self, _nCharacterType, _nID )
    if self[_nCharacterType] then
        return self[_nCharacterType][_nID]
    end
end

function CharacterManager.getColliderList( self, _lpCharater,_characterArray,_collider,_characterTeamId,num)
    local vX, vY, _, vWidth, vHeight = _lpCharater : getConvertCollider(_collider)
    if not vX or not vY or not vWidth or not vHeight then
        print("CharacterManager.getColliderList ",vX, vY, vWidth, vHeight, "id＝",_lpCharater:getID())
        return nil
    end
    -- CCLOG("attacker  _collider= vX=%d,vY=%d,vZ=%d, vWidth=%d,vHeight=%d,id=%d,skinId=%d",vX, vY,vZ, vWidth, vHeight,_lpCharater:getID(),_lpCharater.m_SkinId)
    local selfRect=cc.rect(vX, vY, vWidth, vHeight)
    --发生碰撞的生物表
    local characterArray = {}
    local characterCount = 0
    local teamArray = {}
    local teamCount = 0
    local isCheckHeight = false
    local minHeight,maxHeight=0,0
    if _collider.vRange~=0 then
        isCheckHeight=true
        minHeight=_collider.offsetZ
        maxHeight=_collider.offsetZ+_collider.vRange
    end
    for _,character in pairs(_characterArray) do
        local charProperty = character.m_property

        local isCanBeTarget = false
        local isSameTeam = false
        if charProperty and character ~= _lpCharater then

            -- print("CharacterManager.getColliderList charProperty : getTeamID()=",charProperty : getTeamID(),"_characterTeamId=",_characterTeamId)
            if charProperty:getTeamID()==_characterTeamId then
                if not(character.m_nType==_G.Const.CONST_VITRO 
                    or character.m_nType==_G.Const.CONST_TRAP 
                    or character.m_nType==_G.Const.CONST_HOOK) then
                    isSameTeam=true
                end
            elseif not (
                    -- charProperty:getTeamID()==_characterTeamId or
                    -- characterType == _G.Const.CONST_NPC or
                    -- (characterType == _G.Const.CONST_MONSTER and _lpCharater.m_nType == _G.Const.CONST_MONSTER) or
                    -- character.m_nStatus==_G.Const.CONST_BATTLE_STATUS_FALL or
                    (character.m_nType==_G.Const.CONST_GOODS_MONSTER and _lpCharater.m_nType==_G.Const.CONST_MONSTER) or
                    -- character.m_nType == _G.Const.CONST_TRANSPORT or
                    character.m_noBeTarget == true
                    -- or
                    -- character:getHP() <= 0
                )
                -- or (character.m_nType==_G.Const.CONST_HOOK and _lpCharater.m_nType==_G.Const.CONST_PLAYER)
                then
                isCanBeTarget=true
                if character.m_nStatus==_G.Const.CONST_BATTLE_STATUS_FALL then
                    if _G.g_SkillDataManager:getSkillData(_lpCharater.m_nSkillID).type~=_G.Const.CONST_SKILL_ARMOR_SKILL then
                        isCanBeTarget=false
                        -- if character.m_fallMove~=true then
                        --     character.m_fallMove=true
                        --     local move1=cc.MoveBy:create(0.1,cc.p(0,-5))
                        --     local move2=cc.MoveBy:create(0.1,cc.p(0,5))
                        --     local function c()
                        --         character.m_fallMove=nil
                        --     end
                        --     local fun=cc.CallFunc:create(c)
                        --     local seq=cc.Sequence:create(cc.Repeat:create(cc.Sequence:create(move1,move2),2),fun)
                        --     character.m_lpMovieClip:runAction(seq)
                        -- end

                    end
                end
            end
        elseif character.m_nType==_G.Const.CONST_DEFENSE and _lpCharater.m_nType==_G.Const.CONST_MONSTER then
            isCanBeTarget=true
        elseif character.m_nType==_G.Const.CONST_GOODS_MONSTER and character.teamID~=nil and character.teamID~=_characterTeamId and not character.m_noBeTarget then
            isCanBeTarget=true
        end

        if isCanBeTarget then
            if num~=nil and characterCount>=num then return characterArray,teamArray end
                local chX,chY,chWidth,chHeight=character:getWorldCollider()
                if chX and chY and chWidth and chHeight then
                -- CCLOG("character:_collider=%d chX=%d,chY=%d,chZ=%d,chWidth=%d,chHeight=%d,id=%d,skinId=%d",character.currentColliderId,chX, chY,chZ, chWidth, chHeight,character:getID(),character.m_SkinId)
                    local otherRect = cc.rect(chX, chY, chWidth, chHeight)
                    if cc.rectIntersectsRect(selfRect,otherRect) then
                        if isCheckHeight then
                            if character:getLocationZ()>=minHeight and character:getLocationZ()<=maxHeight then
                                characterCount=characterCount+1
                                characterArray[characterCount]=character                                      
                            end                                
                        else
                            characterCount=characterCount+1
                            characterArray[characterCount]=character                                
                        end
                    end
                end  

        end
        if isSameTeam then
            if num~=nil and teamCount>num then return characterArray,teamArray end
                local chX,chY,chWidth,chHeight=character:getWorldCollider()
                if chX and chY and chWidth and chHeight then
                 -- CCLOG("character:_collider=%d chX=%d,chY=%d,chZ=%d,chWidth=%d,chHeight=%d,id=%d,skinId=%d",character.currentColliderId,chX, chY,chZ, chWidth, chHeight,character:getID(),character.m_SkinId)
                    local otherRect = cc.rect(chX, chY, chWidth, chHeight)
                    if cc.rectIntersectsRect(selfRect,otherRect) then
                        if isCheckHeight then
                            if character:getLocationZ()>=minHeight and character:getLocationZ()<=maxHeight then
                                teamCount=teamCount+1
                                teamArray[teamCount]=character                                      
                            end                             
                        else
                            teamCount=teamCount+1
                            teamArray[teamCount]=character                            
                        end
                    end
                end 
            end

    end
    return characterArray,teamArray
end

--{传入自己.和其他人碰撞}
function CharacterManager.getCharacterByVertex( self, _lpCharater ,_collider, _characterTeamId,num)
    return self:getColliderList(_lpCharater, self.m_lpCharacterArray, _collider,_characterTeamId,num)
end

--{传入一个人物.和另一个传入人物  做碰撞}
function CharacterManager.checkColliderByCharacter( self, _lpCharater, _collider , _lpCharater2, _isFlip)
    local vX, vY,_,vWidth, vHeight = _lpCharater : getConvertCollider(_collider,_isFlip)
    if not vX or not vY or not vWidth or not vHeight then
        print("CharacterManager.checkColliderByCharacter",vX, vY, vWidth, vHeight, "id",_lpCharater:getID())
        return false
    end
    local isCheckHeight = false
    local minHeight,maxHeight=0,0
    -- print("_collider.offsetZ:",_collider.offsetZ)
    if _collider.vRange~=0 and _collider.offsetZ ~= nil then
        isCheckHeight=true
        minHeight=_collider.offsetZ
        maxHeight=_collider.offsetZ+_collider.vRange
    end
    if isCheckHeight then
        if _lpCharater:getLocationZ()<minHeight and _lpCharater:getLocationZ()>maxHeight+minHeight then
            return false
        end
    end
    -- if _lpCharater:getProperty():getTeamID()==_lpCharater2:getProperty():getTeamID() then
    --     return false
    -- end
    -- print("attacker  _collider=",_lpCharater.currentColliderId," vX=",vX,",vY=",vY,",vZ=",vZ,",vWidth=",vWidth,",vHeight=",vHeight,",id=",_lpCharater:getID())
    local selfRect =  cc.rect(vX, vY, vWidth, vHeight )
    local ret = {}
    if _lpCharater2 ~= _lpCharater then
        local chX,chY,chWidth,chHeight=_lpCharater2:getWorldCollider()
        -- print("_lpCharater2:_collider=",_lpCharater2.currentColliderId," chX=",chX,",chY=",chY,",chZ=",chZ,",chWidth=",chWidth,",chHeight=",chHeight,",id=",_lpCharater2:getID())
        if chX and chY and chWidth and chHeight then
            local otherRect = cc.rect(chX, chY, chWidth, chHeight )
            if cc.rectIntersectsRect(selfRect,otherRect) then
                return true
            end
        else
            CCLOG("CharacterManager.checkColliderByCharacter 碰撞数据有空")
        end
    end
    return false
end

function CharacterManager.checkObstacleLimits(self)
    for k,v in pairs(self.m_lpPlayerArray) do
        v:checkObstacleLimit()
    end
    for k,v in pairs(self.m_lpPartnerArray) do
        v:checkObstacleLimit()
    end
    for k,v in pairs(self.m_lpMonsterArray) do
        v:checkObstacleLimit()
    end
end

_G.CharacterManager = CharacterManager()