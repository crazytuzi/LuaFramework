-- require "mod.character.Npc"
-- require "mod.character.Monster"
-- require "mod.character.Transport"
-- require "mod.character.Vitro"
require "mod.map.SkillManager"
-- require "mod.support.Property"
local StageXMLManager = classGc(function( self )
    self.Monster_TeamId=-164
end)

function StageXMLManager.getXMLScenes( self, _nScenesID )
    return get_scene_data(_nScenesID)
end

function StageXMLManager.getMaterialIDByScenesID( self, _nScenesID )
    local singleSceneData = self:getXMLScenes(_nScenesID)
    if singleSceneData ~= nil then
        return singleSceneData.material_id
    end
end

function StageXMLManager.getXMLScenesNPCList( self, _nScenesID )
    --NPC XML 列表
    local singleSceneData = self:getXMLScenes( _nScenesID )
    if singleSceneData ~= nil then
        return singleSceneData.npc
    end
end

function StageXMLManager.getXMLScenesCheckpointList( self, _nScenesID )
    --关卡 XML 列表
    local singleSceneData = self : getXMLScenes( _nScenesID )
    if singleSceneData ~= nil then
        return singleSceneData.checkpoint
    end
end

function StageXMLManager.getXMLScenesCheckpoint( self, _nScenesID, _nCheckPointIndex )
    --关卡 XML
    local checkpointList = self : getXMLScenesCheckpointList( _nScenesID )
    if checkpointList~=nil then
        return checkpointList[_nCheckPointIndex]
    end
end


function StageXMLManager.getXMLScenesMonsterList( self, _nScenesID, _nCheckPointIndex )
    -- 关卡怪物 XML 列表
    local checkpoint = self:getXMLScenesCheckpoint( _nScenesID, _nCheckPointIndex )
    if checkpoint==nil then
        CCLOG("config error 配置表.读取不了怪物,配置表错误")
        return
    end
    return checkpoint.monster
end

function StageXMLManager.getXMLTransportList( self, _nScenesID )
    local singleSceneData = self : getXMLScenes( _nScenesID )
    if singleSceneData ~= nil then
        return singleSceneData.door
    end
end

function StageXMLManager.addNPC( self, _nScenesID )
    --添加NPC
    local npcList = self : getXMLScenesNPCList( _nScenesID )
    if npcList == nil then
        return
    end
    
    for i,npc in ipairs(npcList) do
        local npcObject = CNpc(_G.Const.CONST_NPC)
        local npcId = npc.npc_id
        local npcPx = npc.x
        local npcPy = npc.y
        local npcSkin = 1
        --临时代码,应该做一个npc 的proxy类
        local npcName = "配置的npc"
        local npcData =_G.Cfg.scene_npc[npcId]
        if npcData ~= nil then
            npcName = npcData.npc_name
            npcSkin = npcData.skin
        end
        local uid =_G.UniqueID : getNewID()
        npcObject:npcInit (uid,npcId , npcName, npcPx , npcPy , npcSkin)
        _G.g_Stage:addCharacter(npcObject)
    end
    CCLOG("addPNC success====>>")
end

function StageXMLManager.addPlotMonsterByID( self, _monsterID, _monsterName, _pos )
    local monsterData=_G.Cfg.scene_monster[_monsterID]
    if monsterData~=nil then
        local monsterObject=CMonster( _G.Const.CONST_MONSTER )
        -- local uid = _G.UniqueID : getNewID()
        local uid =_monsterID
        monsterObject.isPlotMonster=true
        monsterObject:monsterInit(uid,_monsterID,monsterData,_pos.x,_pos.y,monsterData.skin,_monsterName)
        
        print("StageXMLManager.addPlotMonsterByID _monsterID=",_monsterID,"skinId=",monsterData.skin)
        return monsterObject
    end
    return nil
end

function StageXMLManager.addMonster( self, _nScenesID, _nCheckPointIndex, _hasPlot, _partnerArray)
    CCLOG("StageXMLManager.addMonster _nScenesID=%d,_nCheckPointIndex=%d",_nScenesID,_nCheckPointIndex)
    local monsterList = self : getXMLScenesMonsterList( _nScenesID, _nCheckPointIndex )
    print("看看数据==============",monsterList,_partnerArray)
    if monsterList == nil then
        return
    end
    if _partnerArray~=nil then
        for i=1,#_partnerArray do
            self:addProtetionCombat(_partnerArray[i]);
        end
    end
    return self:addMonsterByIDList(monsterList,_hasPlot)
end

function StageXMLManager.checkBossMonster(self,_nScenesID,_nCheckPointIndex)
    local monsterList = self : getXMLScenesMonsterList(_nScenesID,_nCheckPointIndex)
    if monsterList ~= nil then
        for _,data in pairs(monsterList) do
            local monsterData = self : getMonsterData(data[1])
            if monsterData ~= nil then
                if monsterData.steps>=_G.Const.CONST_MONSTER_RANK_BOSS_SUPER then
                    return true
                end
            end
        end
    end
end

function StageXMLManager.getMonsterData( self, monster_id )
    return _G.Cfg.scene_monster[monster_id]
end

function StageXMLManager.addMonsterByIDList( self, _monsterIDList, _hasPlot)
    local addMonsterObject = nil
    local addMonsterObjectRank = 0
    -- local hpNum = 1
    local list = {}
    
    -- print("JKJKJKJKJKJKJ====>>>",debug.traceback())
    local mainPlay=_G.g_Stage:getMainPlayer()
    local tempX,tempY=mainPlay:getLocationXY()
    for _, monsterXml in pairs(_monsterIDList) do
        if monsterXml[1] ~= nil then
            CCLOG("addMonsterByIDList monster_id=%d",monsterXml[1])
            
            local monsterXmlProperty=self:getMonsterData(monsterXml[1])
            if monsterXmlProperty~=nil then
                local monsterType=monsterXmlProperty.monster_type
                local monsterObject=nil
                local movieType
                if _hasPlot then
                    movieType=nil
                else
                    movieType=monsterXml[6]
                end
                local tX,tY=monsterXml[4],monsterXml[5]
                if monsterXml[3]==0 then
                    tX=tX+tempX
                end
                if monsterXml[2]~=0 then
                    tX=tX+math.random(-monsterXml[2],monsterXml[2])
                    tY=tY+math.random(-monsterXml[2],monsterXml[2])
                end
                local dir=tX>tempX and -1 or 1

                if monsterType==_G.Const.CONST_MONSTER_RACE_PLAYER then
                    monsterObject= self:addOnePlayerMonster(nil,monsterXmlProperty,monsterXml[1],tX, tY,dir,nil,nil,movieType)
                else
                    monsterObject= self:addOneMonster(nil,monsterXmlProperty,monsterXml[1],tX, tY,dir,nil,nil,movieType)
                end
                if monsterObject~=nil then
                    if _hasPlot then
                        monsterObject.movieType=monsterXml[6]
                    end
                    
                    local rank =monsterXmlProperty.steps
                    monsterObject : setMonsterRank(rank)
                    --遇到更高级的boss
                    -- if rank >= _G.Const.CONST_MONSTER_RANK_ELITE_LEADER and addMonsterObjectRank < rank then
                    --     addMonsterObject = monsterObject
                    --     addMonsterObjectRank = rank
                    --     -- hpNum = monsterXmlProperty.says1
                    -- end
                    if monsterXmlProperty.big_hp ~= 0 then
                        monsterObject.isMonsterBoss=true
                        monsterObject:addBigHpView(false)
                    end
                    table.insert(list, monsterObject)
                    
                    --世界boss
                    if rank == _G.Const.CONST_OVER_BOSS then
                        _G.g_Stage : setBoss( monsterObject )
                        _G.g_Stage : setBossHp( monsterObject:getHP())
                    end
                    
                    --通关boss  CONST_MONSTER_RANK_BOSS_SUPER
                    if rank>=_G.Const.CONST_MONSTER_RANK_BOSS_SUPER then
                        _G.g_Stage.isBossBattle=true
                    end
                end
            else
                CCMessageBox("怪物数据是空 monster_id:"..monsterXml[1], "Error!")
                CCLOG("StageXMLManager.addOnePlayerMonster 怪物数据是空 monster_id=%d",monsterXml[1])
            end
        end
    end
    
    -- if addMonsterObject ~= nil then
    -- end
    return list
end
function StageXMLManager.addProtetionCombat(self, _partner)
    local monsterXmlProperty=self:getMonsterData(_partner[1])
    if monsterXmlProperty~=nil then
        local monsterType=monsterXmlProperty.monster_type
        local monsterObject=nil
        local dir = _partner[2] == _G.Const.CONST_DIRECTION_WEST and -1 or 1
        local movieType
        if _hasPlot then
            movieType=nil
         else
            movieType=_partner[6]
        end            
    end
    local monsterObject=nil
    local teamId = _G.GPropertyProxy:getMainPlay():getTeamID()
    monsterObject= self:addOneMonster(nil,monsterXmlProperty,_partner[1],_partner[4], _partner[5],dir,nil,nil,movieType,nil,teamId,true)
    monsterObject:addPartnerHalo()
    if monsterObject~=nil then
        if _hasPlot then
            monsterObject.movieType=_partner[6]
        end
    end
end

function StageXMLManager.addOnePlayerMonster(self,_uid,monsterXmlProperty,monster_id,pos_x,pos_y,direction,hp,hp_max,type)
    if monsterXmlProperty ~= nil then
        local temp_play = CPlayer( _G.Const.CONST_PLAYER)--CONST_PLAYER
        local uid = _uid or -_G.UniqueID:getNewID()
        local attrXML = monsterXmlProperty.attr
        
        if attrXML~=nil then
            local szName = monsterXmlProperty.monster_name
            local pro = monsterXmlProperty.skin%10
            local lv = monsterXmlProperty.lv
            local x = pos_x
            local y = pos_y
            local skinID = monsterXmlProperty.skin
            local hp = attrXML.hp
            local hpMax = attrXML.hp
            local clanId = nil
            local clanName = nil
            local team_id = self.Monster_TeamId
            
            local property = require("mod.support.Property")()
            property : updateProperty( _G.Const.CONST_ATTR_VIP , 0 )
            property : setPro( pro )
            property : setTeamID(team_id )
            property : setClan(clanId)
            property : setClanName(clanName)
            property : setIs_guide(0)
            -- property : setTitle_msg(nil)
            
            property : updateProperty ( _G.Const.CONST_ATTR_LV ,monsterXmlProperty.lv)
            property : setUid( uid )
            property : updateProperty ( _G.Const.CONST_ATTR_SP , attrXML.sp)
            property : updateProperty ( _G.Const.CONST_ATTR_HP , attrXML.hp)
            property : updateProperty ( _G.Const.CONST_ATTR_STRONG_ATT , attrXML.strong_att)
            property : updateProperty ( _G.Const.CONST_ATTR_STRONG_DEF , attrXML.strong_def)
            property : updateProperty ( _G.Const.CONST_ATTR_DEFEND_DOWN , attrXML.wreck)
            property : updateProperty ( _G.Const.CONST_ATTR_HIT , attrXML.hit)
            property : updateProperty ( _G.Const.CONST_ATTR_DODGE , attrXML.dodge)
            property : updateProperty ( _G.Const.CONST_ATTR_CRIT , attrXML.crit)
            property : updateProperty ( _G.Const.CONST_ATTR_RES_CRIT , attrXML.crit_res)
            property : updateProperty ( _G.Const.CONST_ATTR_BONUS , attrXML.bonus)
            property : updateProperty ( _G.Const.CONST_ATTR_REDUCTION , attrXML.reduction)
            
            _G.GPropertyProxy : addOne( property ,_G.Const.CONST_MONSTER )
            
            
            temp_play : setProperty(property)
            temp_play : playerInit( uid, szName, pro, lv, skinID, 0, 0, 0, 0)
            temp_play : init( uid , szName, 100, 100, 200, 200, x, y, skinID)
            temp_play : resetNamePos()
            -- temp_play : setAI(monsterXmlProperty:getAI())
            temp_play : setMonsterPlayer(monsterXmlProperty)
            _G.g_Stage:addCharacter(temp_play)
        end
        
        return temp_play,monsterXmlProperty
    else
        CCMessageBox("怪物数据是空 monster_id:"..monster_id, "Error!")
        CCLOG("StageXMLManager.addOnePlayerMonster 怪物数据是空 monster_id=%d",monster_id)
    end
    return nil
end

function StageXMLManager.addOnePlayerMonster2(self,_uid,monsterXmlProperty,monster_id,pos_x,pos_y,direction,hp,hp_max,type)
    if monsterXmlProperty ~= nil then
        local temp_play = CPlayer( _G.Const.CONST_PLAYER)--CONST_PLAYER
        local uid = _uid or -_G.UniqueID:getNewID()
        local attrXML = monsterXmlProperty.attr
        
        if attrXML~=nil then
            local szName = monsterXmlProperty.monster_name
            local pro = monsterXmlProperty:getPro()
            local lv = monsterXmlProperty.lv
            local x = pos_x
            local y = pos_y
            local skinID = pro+10000
            local hp = attrXML.hp
            local hpMax = attrXML.hp
            local clanId = nil
            local clanName = nil
            local team_id = monsterXmlProperty:getTeamID()
            
            local property = require("mod.support.Property")()
            property : updateProperty( _G.Const.CONST_ATTR_VIP , 0 )
            property : setPro( pro )
            property : setTeamID(team_id )
            property : setClan(clanId)
            property : setClanName(clanName)
            property : setIs_guide(0)
            -- property : setTitle_msg(nil)
            
            property : updateProperty ( _G.Const.CONST_ATTR_LV ,monsterXmlProperty.lv)
            property : setUid( uid )
            property : updateProperty ( _G.Const.CONST_ATTR_SP , attrXML.sp)
            property : updateProperty ( _G.Const.CONST_ATTR_HP , attrXML.hp)
            property : updateProperty ( _G.Const.CONST_ATTR_STRONG_ATT , attrXML.strong_att)
            property : updateProperty ( _G.Const.CONST_ATTR_STRONG_DEF , attrXML.strong_def)
            property : updateProperty ( _G.Const.CONST_ATTR_DEFEND_DOWN , attrXML.wreck)
            property : updateProperty ( _G.Const.CONST_ATTR_HIT , attrXML.hit)
            property : updateProperty ( _G.Const.CONST_ATTR_DODGE , attrXML.dodge)
            property : updateProperty ( _G.Const.CONST_ATTR_CRIT , attrXML.crit)
            property : updateProperty ( _G.Const.CONST_ATTR_RES_CRIT , attrXML.crit_res)
            property : updateProperty ( _G.Const.CONST_ATTR_BONUS , attrXML.bonus)
            property : updateProperty ( _G.Const.CONST_ATTR_REDUCTION , attrXML.reduction)
            
            _G.GPropertyProxy : addOne( property ,_G.Const.CONST_MONSTER )
            
            
            temp_play : setProperty(property)
            temp_play : playerInit( uid, szName, pro, lv, skinID, 0, 0, 0, 0)
            temp_play : init( uid , szName, 100, 100, 200, 200, x, y, skinID)
            temp_play : resetNamePos()
            temp_play : setAI(monsterXmlProperty:getAI())
            -- temp_play : setMonsterPlayer(monsterXmlProperty)
            _G.g_Stage:addCharacter(temp_play)
        end
        
        return temp_play,monsterXmlProperty
    else
        CCMessageBox("怪物数据是空 monster_id:"..monster_id, "Error!")
        CCLOG("StageXMLManager.addOnePlayerMonster 怪物数据是空 monster_id=%d",monster_id)
    end
    return nil
end

function StageXMLManager.addLingYaoMonster(self,_uid,_id,_lv,_attr,_teamId,_dir,_pos)
    local partnerCnf=_G.Cfg.partner_init[_id]

    if not partnerCnf then
        print("addLingYaoMonster====>>> error _id=",_id)
        return
    end

    local uid =_uid or _G.UniqueID : getNewID()
    local idx = _id
    local property = require("mod.support.Property")()
    property : updateProperty ( _G.Const.CONST_ATTR_LV ,_lv)
    property : setUid( uid )
    property : updateProperty( _G.Const.CONST_ATTR_NAME,  partnerCnf.name)
    property : updateProperty( _G.Const.CONST_ATTR_NAME_COLOR,partnerCnf.name_color)
    property : setSkinArmor( partnerCnf.skin)
    property : setAI(partnerCnf.ai or partnerCnf.skin)
    property : setPartner_idx(idx)
    property : setPartnerId(_id)

    property : updateProperty ( _G.Const.CONST_ATTR_SP , _attr.sp)
    property : updateProperty ( _G.Const.CONST_ATTR_HP , _attr.hp)
    property : updateProperty ( _G.Const.CONST_ATTR_STRONG_ATT , _attr.att)
    property : updateProperty ( _G.Const.CONST_ATTR_STRONG_DEF , _attr.def)
    property : updateProperty ( _G.Const.CONST_ATTR_DEFEND_DOWN , _attr.wreck)
    property : updateProperty ( _G.Const.CONST_ATTR_HIT , _attr.hit)
    property : updateProperty ( _G.Const.CONST_ATTR_DODGE , _attr.dod)
    property : updateProperty ( _G.Const.CONST_ATTR_CRIT , _attr.crit)
    property : updateProperty ( _G.Const.CONST_ATTR_RES_CRIT , _attr.crit_res)
    property : updateProperty ( _G.Const.CONST_ATTR_BONUS , _attr.bonus)
    property : updateProperty ( _G.Const.CONST_ATTR_REDUCTION , _attr.reduction)

    if _teamId then
        property:setTeamID(_teamId)
    end
    _G.GPropertyProxy : addOne( property ,_G.Const.CONST_PARTNER )

    local characterPartner=CPartner(_G.Const.CONST_PARTNER)
    characterPartner:partnerInit(property)
    characterPartner:setAI(property:getAI())
    characterPartner.lingYaoCamp=partnerCnf.country
    
    if _pos then
        characterPartner:setLocationXY(_pos.x,_pos.y)
    end
    if _dir then
        characterPartner:setMoveClipContainerScalex(_dir)
    end
    _G.g_Stage:addCharacter(characterPartner)
end

function StageXMLManager.getSexByPro( self, _pro )
    local pro = tonumber( _pro )
    if pro == _G.Const.CONST_PRO_ICEGIRL or pro == _G.Const.CONST_PRO_BIGSISTER or pro == _G.Const.CONST_PRO_LOLI then
        return _G.Const.CONST_SEX_MM
    else
        return _G.Const.CONST_SEX_GG
    end
end

function StageXMLManager.addOneMonster(self,_uid,monsterXmlProperty,monster_id,pos_x,pos_y,direction,hp,hp_max,type,subject,teamId,isPartner)
    print("StageXMLManager.addOneMonster _uid=",_uid,"monster_id=",monster_id,"pos_x=",pos_x,"pos_y=",pos_y,"direction=",direction,"hp=",hp,"hp_max=",hp_max)
    monsterXmlProperty = monsterXmlProperty or self:getMonsterData(monster_id)
    if monsterXmlProperty ~= nil then
        local monsterObject = CMonster( _G.Const.CONST_MONSTER )
        monsterObject.isPartner=isPartner
        if subject~=nil then
            monsterObject.m_subject=subject
        end
        local uid =_uid or _G.UniqueID : getNewID()
        local attrXML = monsterXmlProperty.attr
        if attrXML~=nil then
            local property = require("mod.support.Property")()
            property : updateProperty ( _G.Const.CONST_ATTR_LV ,monsterXmlProperty.lv)
            property : setUid( uid )
            property : updateProperty ( _G.Const.CONST_ATTR_SP , attrXML.sp)
            property : updateProperty ( _G.Const.CONST_ATTR_HP , attrXML.hp)
            property : updateProperty ( _G.Const.CONST_ATTR_STRONG_ATT , attrXML.strong_att)
            property : updateProperty ( _G.Const.CONST_ATTR_STRONG_DEF , attrXML.strong_def)
            property : updateProperty ( _G.Const.CONST_ATTR_DEFEND_DOWN , attrXML.defend_down)
            property : updateProperty ( _G.Const.CONST_ATTR_HIT , attrXML.hit)
            property : updateProperty ( _G.Const.CONST_ATTR_DODGE , attrXML.dod)
            property : updateProperty ( _G.Const.CONST_ATTR_CRIT , attrXML.crit)
            property : updateProperty ( _G.Const.CONST_ATTR_RES_CRIT , attrXML.crit_res)
            property : updateProperty ( _G.Const.CONST_ATTR_BONUS , attrXML.bonus)
            property : updateProperty ( _G.Const.CONST_ATTR_REDUCTION , attrXML.reduction)
            
            if teamId~=nil then
                property:setTeamID(teamId)
            else
                property:setTeamID(self.Monster_TeamId)
            end
            
            
            _G.GPropertyProxy:addOne(property, _G.Const.CONST_MONSTER)
            monsterObject:setProperty(property)
            monsterObject:monsterInit(uid,monster_id,monsterXmlProperty, pos_x,pos_y,nil,nil,type,direction)
            _G.g_Stage:addCharacter(monsterObject)
            
            monsterObject.m_szName= monsterXmlProperty.monster_name
            monsterObject.m_xmlProperty = monsterXmlProperty
            if hp_max~=nil then
                monsterObject:setMaxHp(hp_max)
            end
            if hp~=nil then
                monsterObject:setHP(hp)
            end
            if monsterXmlProperty.skin_type then
                monsterObject:setBodySkinId(monsterXmlProperty.skin_type)
            end
            
        end
        
        return monsterObject,monsterXmlProperty
    else
        CCMessageBox("怪物数据是空 monster_id:"..monster_id, "Error!")
        CCLOG("StageXMLManager.addOneMonster 怪物数据是空 monster_id=%d",monster_id)
    end
    return nil
end

function StageXMLManager.addOneMonster2(self,_uid,monster_id,pos_x,pos_y,direction,hp,hp_max, addPoci, addLv)
    print("StageXMLManager.addOneMonster _uid=",_uid,"monster_id=",monster_id,"pos_x=",pos_x,"pos_y=",pos_y,"direction=",direction,"hp=",hp,"hp_max=",hp_max,"addLv=",addLv)
    
    local monsterXmlProperty =self:getMonsterData(monster_id)
    if monsterXmlProperty ~= nil then
        local monsterObject = CMonster( _G.Const.CONST_MONSTER )
        
        local uid =_uid or _G.UniqueID : getNewID()
        
        local DefMonst     = _G.Cfg.defense_sproperty
        local DefMonstinfo = DefMonst[addLv]
        local attrXML      = DefMonstinfo.attr
        local addpulsh     = ( (addPoci-1)*DefMonstinfo.value*0.0001+1 )
        if attrXML~=nil then
            local property = require("mod.support.Property")()
            property : updateProperty ( _G.Const.CONST_ATTR_LV ,monsterXmlProperty.lv)
            property : setUid( uid )
            property : updateProperty ( _G.Const.CONST_ATTR_SP , attrXML.sp)
            property : updateProperty ( _G.Const.CONST_ATTR_HP ,         addpulsh * attrXML.hp)
            property : updateProperty ( _G.Const.CONST_ATTR_STRONG_ATT , addpulsh * attrXML.strong_att)
            property : updateProperty ( _G.Const.CONST_ATTR_STRONG_DEF , addpulsh * attrXML.strong_def)
            property : updateProperty ( _G.Const.CONST_ATTR_DEFEND_DOWN ,addpulsh * attrXML.defend_down)
            property : updateProperty ( _G.Const.CONST_ATTR_HIT ,        addpulsh * attrXML.hit)
            property : updateProperty ( _G.Const.CONST_ATTR_DODGE ,      addpulsh * attrXML.dod)
            property : updateProperty ( _G.Const.CONST_ATTR_CRIT ,       addpulsh * attrXML.crit)
            property : updateProperty ( _G.Const.CONST_ATTR_RES_CRIT ,   addpulsh * attrXML.crit_res)
            property : updateProperty ( _G.Const.CONST_ATTR_BONUS ,      addpulsh * attrXML.bonus)
            property : updateProperty ( _G.Const.CONST_ATTR_REDUCTION ,  addpulsh * attrXML.reduction)
            
            property:setTeamID(self.Monster_TeamId)
            
            _G.GPropertyProxy:addOne(property, _G.Const.CONST_MONSTER)
            monsterObject:setProperty(property)
            monsterObject : monsterInit(uid,monster_id,monsterXmlProperty, pos_x,pos_y)
            _G.g_Stage:addCharacter(monsterObject)
            
            monsterObject.m_szName= monsterXmlProperty.monster_name
            if hp_max~=nil then
                monsterObject:setMaxHp(hp_max)
            end
            if hp~=nil then
                monsterObject:setHP(hp)
            end
            if monsterXmlProperty.skin_type then
                monsterObject:setBodySkinId(monsterXmlProperty.skin_type)
            end
            
            monsterObject:setMoveClipContainerScalex(direction or -1)
            
        end
        
        return monsterObject,monsterXmlProperty
    else
        CCMessageBox("怪物数据是空 monster_id:"..monster_id, "Error!")
        CCLOG("StageXMLManager.addOneMonster 怪物数据是空 monster_id=%d",monster_id)
    end
    return nil
end



function StageXMLManager.addTransport( self, _nScenesID )
    CCLOG("StageXMLManager.addTransport _nScenesID=%d",_nScenesID)
    local transportList = self : getXMLTransportList( _nScenesID )
    if transportList==nil then
        return
    end
    local currentTransportsList = _G.CharacterManager : getTransport()
    
    local mainProperty = _G.GPropertyProxy : getMainPlay()
    for _,transport in pairs(transportList) do
        if transport[4]~=nil and mainProperty : getLv()>=transport[4] then
            local currentTransport=currentTransportsList[transport[1]]
            if currentTransport==nil then
                local transportData =_G.g_CnfDataManager:getDoorData(transport[1])  
                local transportObject = CTransport(_G.Const.CONST_TRANSPORT)
                transportObject: transportInit(transport[1],transportData, transport[2],transport[3])
                _G.g_Stage : addCharacter(transportObject)
            end
        else
            local currentTransport=currentTransportsList[transport[1]]
            if currentTransport==nil then
                print("transport[1]=",transport[1])
                local transportData =_G.g_CnfDataManager:getDoorData(transport[1])  
                local transportObject = CTransport(_G.Const.CONST_TRANSPORT)
                transportObject: transportInit(transport[1],transportData, transport[2],transport[3])
                _G.g_Stage : addCharacter(transportObject)
            end
        end
    end
end

function StageXMLManager.handleSkillFrameMonster( self, _character, _currentFrame, _skill )
    if _currentFrame.call==nil or _currentFrame.call==0 then
        return
    end
    local data=_currentFrame.call
    local dataID = nil
    local isPlayer=false
    -- print("当前职业",_G.GPropertyProxy:getMainPlay():getPro(),"当前数据",data.id)
    if type(data.id)==("table") then
         dataID=data.id[_G.GPropertyProxy:getMainPlay():getPro()]
         isPlayer=true
    else
        dataID= data.id
    end    
    local monsterXmlProperty = self:getMonsterData(dataID)
    local num=0
    for _,character in pairs(_G.CharacterManager:getMonster()) do
        if character.m_monsterId==dataID and character:getProperty():getTeamID()==_character:getProperty():getTeamID() then
            num=num+1
        end
    end
    print("mmmmmmmmmmmmm",data.m,"new",data.new)

    local mackCount=data.m-num
    mackCount=mackCount>data.new and data.new or mackCount

    if mackCount<=0 then return end

    local x = _character.m_nLocationX
    local dir = _character.m_nScaleX
    x =x+data.r*dir

    local maxY,minY=_G.g_Stage:getMapLimitHeight(x)
    local tempY = (maxY - minY)/(mackCount+1)
    local tempX = 0
    local vX, vY, vWidth, vHeight
    if data.r==0 then
        local colliderData=_G.g_SkillDataManager:getAttackSkillCollider(_skill)
        vX,vY,_,vWidth,vHeight,_=_character:getConvertCollider(colliderData)
        tempX=vWidth/mackCount
    end

    local property=_character:getProperty()
    local attrXML=monsterXmlProperty.attr
    attrXML.hp        =math.ceil(data.b*property.attr.hp)           
    attrXML.strong_att=math.ceil(data.p*property.attr.strong_att)   
    attrXML.strong_def=math.ceil(data.p*property.attr.strong_def)   
    attrXML.defend_down=math.ceil(data.p*property.attr.wreck)        
    attrXML.hit       =math.ceil(data.p*property.attr.hit)          
    attrXML.dod       =math.ceil(data.p*property.attr.dodge)        
    attrXML.crit      =math.ceil(data.p*property.attr.crit)         
    attrXML.crit_res  =math.ceil(data.p*property.attr.crit_res)     
    attrXML.bonus     =math.ceil(data.p*property.attr.bonus)        
    attrXML.reduction =math.ceil(data.p*property.attr.reduction)   

    local y
    local startX=vX
    for i=1,mackCount do
        if startX~=nil then
            math.randomseed(gc.MathGc:random_0_1())
            local nY=startX+tempX
            x = math.random(startX,nY)
            y = math.random(vY,vHeight+vY)

            startX=nY
        else
            y = minY+i*tempY
        end
        
        local monsterObject = self:addOneMonster(nil,monsterXmlProperty,dataID,x,y,dir,nil,nil,data.type)
        if isPlayer then
            monsterObject:initialShaderType(14)
        end
        monsterObject:getProperty():setTeamID(_character:getProperty():getTeamID())
    end

end

function StageXMLManager.handleSkillFrameVitro( self, _character, _currentFrame )
    if _currentFrame.addvitro==nil or _character.m_lpContainer==nil then
        return
    end
    
    local masterUID = _character : getID()
    local masterType = _character : getType()
    local masterVitroID
    if masterType == _G.Const.CONST_VITRO then
        masterUID = _character : getMasterUID()
        masterType = _character : getMasterType()
        masterVitroID = _character.m_vitroId
    end
    
    for _,addVitroData in pairs(_currentFrame.addvitro) do
        
        CCLOG("addvitro id=%d",addVitroData.id)
        local vitroData =_G.g_SkillDataManager:getVitroData(addVitroData.id)
        if vitroData~=nil then
            
            local vitro = CVitro( _G.Const.CONST_VITRO)
            vitro:initVitro(vitroData,addVitroData,_character,masterUID,masterType,masterVitroID)
            if vitro.m_nID~=nil then 
                _G.g_Stage:addVitro(_character,vitro)
                vitro.m_lpContainer:setScale(_character.m_lpContainer:getScale())
            end
        else
            CCLOG("StageXMLManager.handleSkillFrameVitro vitroData==nil  id=%d",addVitroData.id)
        end
    end
end
function StageXMLManager.handleSkillFrameTrap( self, _character, _currentFrame )
    print(_currentFrame.addtrap==nil , _character.m_lpContainer==nil)
    if _currentFrame.addtrap==nil or _character.m_lpContainer==nil then
        return
    end
    
    for _,addTrapData in pairs(_currentFrame.addtrap) do
        
        CCLOG("addvitro id=%d",addTrapData.id)
        local trapData =_G.g_SkillDataManager:getTrapData(addTrapData.id)
        if trapData~=nil then
            
            local uid  = _G.UniqueID:getNewID()
            local trap = CTrap( _G.Const.CONST_TRAP)
            trap:initTrap(trapData,addTrapData,_character,uid)
            _G.g_Stage:addTrap(_character,trap)
            local property = _character:getProperty()
            local team = property:getTeamID()
            local property = require("mod.support.Property")()
            property : setUid( uid )
            property : setTeamID(team)
            print(uid,_G.Const.CONST_TRAP)
            _G.GPropertyProxy:addOne(property,_G.Const.CONST_TRAP)
            trap:setProperty(property)
        else
            CCLOG("StageXMLManager.handleSkillFrameTrap trapData==nil  id=%d",addTrapData.id)
        end
    end
end

function StageXMLManager.addGoodsMonster(self, _nScenesID, _type)
    local nType=_type or _G.Const.CONST_GOODS_MONSTER
    local singleSceneData = self:getXMLScenes(_nScenesID)
    if singleSceneData~=nil and singleSceneData.box~=nil and type(singleSceneData.box)=="table" then
        for _,boxData in pairs(singleSceneData.box) do
            local uid = _type and boxData[1] or _G.UniqueID:getNewID()
            local goodsMonster=CGoodsMonster(nType)
            goodsMonster:init(uid,boxData)
            _G.g_Stage:addCharacter(goodsMonster)
        end
    end
end

function StageXMLManager.addGoodsMonster2(self,_boxId,_skinID,_nowHp,_maxHp,_ownerUid,_ownerName,_posX,_posY,_type)
    local nType=_type or _G.Const.CONST_GOODS_MONSTER
    local uid=_boxId or _G.UniqueID:getNewID()
    local goodsMonster=CGoodsMonster(nType)
    goodsMonster:init(uid,nil,_skinID,_posX,_posY,_nowHp,_maxHp,_ownerName)
    goodsMonster:setHitData(self.Monster_TeamId)
    _G.g_Stage:addCharacter(goodsMonster)
end

function StageXMLManager.addHook(self, _nScenesID)
    local singleSceneData = self:getXMLScenes(_nScenesID)
    if singleSceneData~=nil and type(singleSceneData.hook)=="table" then
        for _,hookData in pairs(singleSceneData.hook) do
            if hookData.sec==0 then
                self:addOneHook(hookData)
            end
        end
    end
end

function StageXMLManager.addOneHook(self,hookData,trapData)
    if hookData~=nil then
        local hookType = _G.Const.CONST_HOOK
        local uid = _G.UniqueID:getNewID()
        local team = self.Monster_TeamId
        if hookData.hurt~=0 and hookData.l~=0 then
            hookType = _G.Const.CONST_GOODS_MONSTER
        end
        if hookData.m==1 then
            team = -23232
        elseif hookData.m==2 then
            local teamId=_G.GPropertyProxy : getMainPlay():getTeamID()
            team = teamId
        end
        local hook = CHook(hookType)
        hook:init(uid,hookData)
        _G.g_Stage:addCharacter(hook)
        local property = require("mod.support.Property")()
        property : setUid( uid )
        property : setTeamID(team)
        _G.GPropertyProxy:addOne(property,hookType)
        hook:setProperty(property)
    elseif trapData~=nil then
        local singleSceneData=self:getXMLScenes(_G.g_Stage:getScenesID())
        if type(singleSceneData.hook)=="table" then
            for _,data in pairs(singleSceneData.hook) do
                if data.id == trapData.id and data.sec ~= 0 then
                    if not(data.x==10002 or data.y==10002) then
                        data.x=trapData.x
                        data.y=trapData.y
                    end
                    self:addOneHook(data)
                end
            end
        end
    end
end

function StageXMLManager.setScenePkType(self,_type)
    self.m_scenePkType=_type
end
function StageXMLManager.getScenePkType(self)
    return self.m_scenePkType
end
function StageXMLManager.setServerId(self,id)
    self.m_serverId=id
end
function StageXMLManager.getServerId(self)
    return self.m_serverId
end

_G.StageXMLManager = StageXMLManager()


