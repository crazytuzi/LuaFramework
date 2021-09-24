require "mod.character.Pet"

CPlayer = classGc(CMonster,function(self,_nType)
    self.m_nType=_nType --人物／npc 4
    self.m_stageView=_G.g_Stage
    self:initAI()
end)

--AI相关参数
function CPlayer.initAI( self )
    self.m_fTraceDistance = 600     --追踪距离
    self.m_fLastThinkTime = 0       --上次反应时间,秒
    self.m_fLastAttackTime = 0      --上次攻击时间,秒

    self.m_fLastTraceTime=0
    self.m_fTraceInterval=500
end

function CPlayer.playerInit(self, _nUID, _szName, _nPro, _nLv, _skinID, _mountSkinId,_wingSkinId,_fashionSkinId,_magicSkinId,_mountTX)
    self.m_nID = _nUID --玩家ID
    self.m_szName = _szName
    self.m_nSex  = _nSex
    self.m_nPro = _nPro -- 职业
    self.m_nLv = _nLv
    self.m_nCountry = _nCountry --阵营
    self.m_isRedName = _isRedName
    self.m_SkinId = _skinID --人物皮肤

    self.m_nClan = _clanId
    self.m_szClanName = _clanName
    self.m_titleId = 0

    self.m_mountSkinId=_mountSkinId or 0
    self.m_mountTx=_mountTX or 0
    self.m_PetId=0
    self.m_wingSkinId=_wingSkinId or 0
    self.m_fashionSkinId=_fashionSkinId or 0
    self.m_magicSkinId=_magicSkinId or 0

    self.m_onUpdateStartTime=0
    self.m_onUpdateSpTime=0
    self.m_lastUpdatePosTime=0
    self.m_targetCount=0
    
    self.m_playerInitData =_G.g_SkillDataManager:getSkillInitData(_skinID)
    self.m_changeSkin=self.m_playerInitData.change_skin
    if self.m_playerInitData == nil then
        self.m_playerInitData =_G.g_SkillDataManager:getSkillInitData(10002)
    end
    self.m_lpGoodsCollisionCallBackPos={x=0,y=0}

    -- self.m_skeletonHeight = self.m_playerInitData.nameH
    self.m_mountHeight = 0
    self.m_normalSkills={}
    if not self.m_stageView.m_isCity then
        if self.m_playerInitData~=nil then
            for k,skillId in pairs(self.m_playerInitData.skill_none) do
                self.m_normalSkills[skillId]=skillId
            end
            self.m_bigSkillId=self.m_playerInitData.big_skill
        end
    end

    self.m_scale = self.m_playerInitData.suofang*0.0001
    local property = self:getProperty()
    if property ~= nil then
        property:setAI(self.m_playerInitData.ai)
        self:setWarAttr(property:getAttr())
        
    end
    self:showStarSkill()
    print("_nUID=",_nUID, "_szName=",_szName, "_nLv=",_nLv,"_nCountry=", _nCountry,"_isRedName=",_isRedName,"_skinID=",_skinID)
    print("_mountSkinId=",_mountSkinId, "_wingSkinId=", _wingSkinId, "_fashionSkinId=",_fashionSkinId,"_magicSkinId=",_magicSkinId)
end
function CPlayer.showStarSkill( self )
    self.m_spUP=_G.Const.CONST_BATTLE_ADD_SP_SPEED
    self.m_goldUP=1
    self.m_expUP=1
    self.m_critHurt=1
    self.m_hpUP=nil
    self.m_parHp=nil
    self.m_playHp=nil
    self.m_nMoveSpeedX = self.m_playerInitData.speedx-50
    self.m_nMoveSpeedY = self.m_playerInitData.speedy
    local property = self:getProperty()
    local starID=self.m_wingSkinId
    if starID and starID~=0 then
        local skill=_G.Cfg.wing_des[starID].skill[1]
        local skillDate=_G.Cfg.wing_link[skill]
        local skillType=skillDate.type
        if skillType==_G.Const.CONST_WING_YIDONG_SUDU then
            local speed=skillDate.basics/10000+skillDate.plus/10000*(property:getWingLv()-1)
            self.m_nMoveSpeedX=self.m_nMoveSpeedX*(1+speed)
            self.m_nMoveSpeedY=self.m_nMoveSpeedY*(1+speed)
        elseif skillType==_G.Const.CONST_WING_BAOSHANG_JIACHENG then
            local critHurt=skillDate.basics/10000+skillDate.plus/10000*(property:getWingLv()-1)
            self.m_critHurt=1+critHurt
        elseif skillType==_G.Const.CONST_WING_LANTIAO_HUIFU then
            local spUP=skillDate.basics/10000+skillDate.plus/10000*(property:getWingLv()-1)
            self.m_spUP=(1+spUP)*_G.Const.CONST_BATTLE_ADD_SP_SPEED
        elseif skillType==_G.Const.CONST_WING_XUELIANG_HUIFU then
            local hpUP=skillDate.basics/10000+skillDate.plus/10000*(property:getWingLv()-1)
            self.m_hpUP=hpUP
        elseif skillType==_G.Const.CONST_WING_FUHUO_WUJIANG then
            -- local partnerHp=skillDate.basics/10000+skillDate.plus/10000*(property:getWingLv()-1)
            -- self.m_parHp=partnerHp
            self.m_starBuff=305
            self.m_starBuffCD=skillDate.basics*10-(property:getWingLv()-1)*skillDate.plus*10
            self.m_onUpdateStartTime=_G.TimeUtil:getTotalMilliseconds()
        elseif skillType==_G.Const.CONST_WING_FUHUO_ZHUJUE then
            local playerHp=skillDate.basics/10000+skillDate.plus/10000*(property:getWingLv()-1)
            self.m_playHp=playerHp
        elseif skillType==_G.Const.CONST_WING_TONGQIAN_JIACHENG then
            local goldUP=skillDate.basics/10000+skillDate.plus/10000*(property:getWingLv()-1)
            self.m_goldUP=1+goldUP
        elseif skillType==_G.Const.CONST_WING_JINGYAN_JIACHENG then
            local expUP=skillDate.basics/10000+skillDate.plus/10000*(property:getWingLv()-1)
            self.m_expUP=1+expUP
        end
    end
end
-- 383689
-- 348808
function CPlayer.setMonsterPlayer( self, _xml )
    self.m_nMaxProtect =_xml.toughness
    -- self.m_nNoProTime=_xml.buffs
    -- self.m_drop_goods=_xml.drop_goods
    self.m_patrolRatio=_xml.xunluo

    self.m_fThinkInterval = _xml.fanying*1000
    self.m_fAttackInterval = _xml.jiange*1000

    local lMonster = CMonster(_G.Const.CONST_MONSTER)
    self.runTheAI=lMonster.runTheAI
    self.gotoFight=lMonster.gotoFight
    self.findNearTarget=lMonster.findNearTarget
    self.evade=lMonster.evade
    self.m_monsterId=_xml.id
end

function CPlayer.setFeatherProperty(self,_id,_lv)
    if self.m_stageView.m_isCity then return end
    if _id==nil or _id==0 then return end

    if self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_NORMAL
        or self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_HERO
        or self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_FIEND
        or self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_FIGHTERS then

        self.m_featherId=_id

        if not _G.Cfg.feather_quality[self.m_featherId] then
            self.m_featherId=nil
        elseif not _lv or _lv==0 then
            self.m_featherId=nil
        else
            self.m_featherLv=_lv
        end
    end
    print("CPlayer.setFeatherProperty====>>>>",self.m_featherId,self.m_featherLv,_id,_lv)
end

function CPlayer.setShowState(self,isShowState)
    self.m_isShowState=isShowState
end

function CPlayer.setTitleSpr( self )
    if self.m_lpContainer==nil then return end
    local property  = self:getProperty()
    local titleList = {}
    local nCount=0

    for i=1,#property.title_msg do
        nCount=nCount+1
        titleList[nCount]=property.title_msg[i].title_id
    end
    if property.is_guide == 1 then
        nCount=nCount+1
        titleList[nCount]=1
    end

    if self.m_lpTitleNode~=nil then
        self.m_lpTitleNode:removeFromParent(true)
        self.m_lpTitleNode=nil
    end

    if nCount==0 then return end

    if nCount>1 then
        table.sort(titleList)
    end

    local nameSize=self.m_lpName:getContentSize()
    local nHeight=nameSize.height*0.5
    if self.m_lpClanName~=nil then
        nHeight=nHeight+self.m_lpClanName:getContentSize().height+2
    end

    self.m_lpTitleNode=cc.Node:create()
    self.m_lpTitleNode:setPosition(0,nHeight)
    self.m_lpNameContainer:addChild(self.m_lpTitleNode)

    for i=1,nCount do
        if i>2 then return end
        -- if (math.floor(titleList[i]/100)-10 == 3) or (math.floor(titleList[i]/100)-10 == 5) then return end
        local szFile=string.format("title_%d.png",titleList[i])
        local spriteFrame=cc.SpriteFrameCache:getInstance():getSpriteFrame(szFile)

        local tempY=22+(i-1)*30
        if spriteFrame==nil then
            szFile="title_1101.png"
            local tempLabel=_G.Util:createLabel(string.format("称号:%d没图片",titleList[i]),22)
            tempLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
            tempLabel:setPosition(0,tempY)
            self.m_lpTitleNode:addChild(tempLabel)
        else
            local id = titleList[i]
            local num_1 = math.floor(id/100)-10
            local num_2 = id%10
            print(num_1,num_2)
            local effectID = _G.Cfg.title[num_1][num_2][id]
            print("effectID:",effectID)
            local tempGafAsset=gaf.GAFAsset:create(string.format("gaf/ch_%d.gaf",effectID.te))
            local titleGaf=tempGafAsset:createObject()
            local nPos=cc.p(0,tempY)
            titleGaf:setLooped(true,true)
            titleGaf:start()
            titleGaf:setPosition(nPos)
            self.m_lpTitleNode : addChild(titleGaf,1000)

            -- local tempSpr=cc.Sprite:createWithSpriteFrame(spriteFrame)
            -- tempSpr:setPosition(0,tempY)
            -- self.m_lpTitleNode:addChild(tempSpr,1)

            
			-- local effect=_G.SpineManager.createSpine(string.format("spine/%d",effectID.te),1)
			-- effect:setAnimation(0,"idle",true)
			-- effect:setPosition(tempSpr:getContentSize().width/2,tempSpr:getContentSize().height/2)
			-- if effectID.pai==1 then
			-- 	tempSpr:addChild(effect,-1)
			-- else
			-- 	tempSpr:addChild(effect)
			-- end
            
            -- local nTimes=1
            -- tempSpr=cc.Sprite:createWithSpriteFrame(spriteFrame)
            -- tempSpr:setPosition(0,tempY)
            
            -- self.m_lpTitleNode:addChild(tempSpr)
            -- _G.ShaderUtil:shaderNormalById(tempSpr,11)
        end
    end

end

function CPlayer.setClanName( self )
    print("setClanName======>>>  11")
    if self.m_lpContainer==nil then return end

    local property=self:getProperty()
    self.m_nClan=property.clan
    self.m_szClanName=property.clan_name

    local nameSize=self.m_lpName:getContentSize()
    if self.m_szClanName==nil or self.m_nClan==nil or self.m_nClan==0 then
        if self.m_lpClanName~=nil then
            self.m_lpClanName:removeFromParent(true)
            self.m_lpClanName=nil

            if self.m_lpTitleNode~=nil then
                self.m_lpTitleNode:setPosition(0,nameSize.height*0.5)
            end
        end
        return
    end
    
    local szTemp=string.format("[%s]",self.m_szClanName)
    if self.m_lpClanName~=nil then
        self.m_lpClanName:setString(szTemp)
    else
        self.m_lpClanName  = _G.Util:CreateTraceLabel(szTemp,21,1)
        local clanNameSize = self.m_lpClanName:getContentSize()
        self.m_lpClanName :setPosition(0,nameSize.height*0.5+clanNameSize.height*0.5+2)
        self.m_lpClanName :setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
        self.m_lpNameContainer:addChild(self.m_lpClanName)

        if self.m_lpTitleNode~=nil then
            self.m_lpTitleNode:setPosition(0,nameSize.height*0.5+clanNameSize.height+2)
        end
    end
end

function CPlayer.setVipSpr( self )
    if self.m_lpContainer==nil then return end

    if self.m_vipname~=nil then
        self.m_vipname:removeFromParent(true)
        self.m_vipname=nil
    end

    local property = self:getProperty()
    local nameSize = self.m_lpName:getContentSize()
    --设置vip图标
    if property~=nil then
        if property:getVipLv()~=nil and property:getVipLv()>0 then
            local vipSpr=cc.Sprite:createWithSpriteFrameName(string.format("general_headvip_%d.png",property:getVipLv()))
            local vipSprSize=vipSpr:getContentSize()
            vipSpr:setPosition(-vipSprSize.width*0.5-nameSize.width*0.5,2)
            self.m_lpNameContainer:addChild(vipSpr)
            self.m_vipname=vipSpr
        end
    end
end

function CPlayer.setName( self, _szName )
    if _szName==nil then
        return
    end
    self.m_szName=_szName
    if self.m_lpNameContainer==nil or self.m_lpName~=nil then
        return
    end
    
    local color = nil
    if self.m_nID==_G.GLoginPoxy:getUid() then
        color = _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN )
    else
        if self.m_stageView.m_sceneType==_G.Const.CONST_MAP_CLAN_WAR then
            local myClanId=_G.GPropertyProxy:getMainPlay():getClan()
            local heClanId=self:getProperty():getClan()
            if myClanId==heClanId then
                color =  _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE)
            else
                color =  _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED)
            end
        elseif self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_CHALLENGEPANEL or
            self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_KOF then
            color =  _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED)

        elseif self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_CITY_BOSS
            or (self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_BOX and self.m_stageView.m_isCanAttackOrther) then
            local myClanId=_G.GPropertyProxy:getMainPlay():getClan()
            local heClanId=self:getProperty():getClan()

            print("CPlayer.setName teamId=",myClanId,"property:getTeamID()=",heClanId)

            if myClanId==heClanId and heClanId~=0 then
                color =  _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE)
            else
                color =  _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED)
            end
        elseif self.m_nType==_G.Const.CONST_MONSTER then
            color =  _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED)
        else
            color =  _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE)
        end
    end

    print("更改名字yes＝＝＝＝",_szName)
    self.m_lpName=_G.Util:CreateTraceLabel(_szName,23,1,color)
    self.m_lpNameContainer:addChild(self.m_lpName)
    self:resetNamePos()

    self:setVipSpr()
    self:setClanName()
    self:setTitleSpr()
end

function CPlayer.setNameColor(self, color)
    print("CPlayer.setNameColor=======>>1")
    self.m_lpName:setColor(color)
end
function CPlayer.setNameString(self,_szName)
    self.m_szName=_szName or "ERROR"
    self.m_lpName:setString(_szName)

    self:setVipSpr()
end

function CPlayer.removeName( self )
    self.m_lpNameContainer:removeAllChildren(true)
    self.m_lpName = nil
    self.m_vipname = nil
    self.m_lpClanName = nil
    self.m_lpTitleNode = nil
end

function CPlayer.resetNamePos( self )
    self.m_lpNameContainer:setPositionY(self:getLocationZ()+self.m_skeletonHeight+15+self.m_mountHeight)
end
function CPlayer.resetStarPos( self )
    if self.m_star~=nil and self.m_star.m_data.fly==1 then
        self.m_star.m_lpMovieClipContainer:setPositionY(self:getLocationZ()+self.m_skeletonHeight+15+self.m_mountHeight)
    end
end

function CPlayer.setFashionSkinId(self, fashionSkinId)
    -- print("CPlayer.setFashionSkinId fashionSkinId=",fashionSkinId,"self.m_fashionSkinId=",self.m_fashionSkinId)
    -- fashionSkinId=fashionSkinId or 0
    -- if self.m_fashionSkinId==fashionSkinId then return end
    -- self.m_fashionSkinId = fashionSkinId

    -- self.m_nStatus = -100
    -- self:setStatus( _G.Const.CONST_BATTLE_STATUS_IDLE )
end

function CPlayer.getFashionSkinId(self)
    return self.m_fashionSkinId
end

function CPlayer.setPetId( self, _petId )
    if not self.m_stageView.m_isCity then
        return
    end
    _petId=_petId or 0

    print("CPlayer.setPetId  self.m_PetId=",self.m_PetId,",_petId=",_petId)

    self:removePet()
    self.m_PetId=_petId

    if self.m_PetId>0 then
        self.m_pet=CPet(_G.Const.CONST_PET)
        self.m_pet:petInit(_G.UniqueID:getNewID(),self.m_nLocationX,self.m_nLocationY,_petId,self)
        self.m_pet:setMovePos(self.m_nLocationX,self.m_nLocationY,self.m_nScaleX)
        self.m_stageView:addCharacter(self.m_pet)
    end
end

function CPlayer.removePet(self)
    if self.m_pet then
        _G.CharacterManager:remove(self.m_pet)
        self.m_pet:releaseResource()
        self.m_pet=nil
    end
end

function CPlayer.removeMount(self)
    if self.m_mountNode~=nil then
        self.m_mountNode:remove()
        self.m_mountNode=nil
    end

    self.m_mountResArray=nil
end
--坐骑皮肤
function CPlayer.setMountSkinId( self, _mountSkinId, _mountTX )
    print("CPlayer.setMountSkinId _mountSkinId=",_mountSkinId,_mountTX)
    if not self.m_stageView.m_isCity then return end

    _mountSkinId=_mountSkinId or 0
    if self.m_mountSkinId~=_mountSkinId or (_mountTX~=nil and _mountTX~=0) then
        print( "改变坐骑或者特效！" )
        
        self:removeMount()

        self.m_mountSkinId=_mountSkinId
        self.m_mountTx=_mountTX
    end
    if _mountSkinId==0 then
        self.m_lpMovieClipContainer:setPosition(0,0)
        self.m_mountHeight=0
        self:setShadowScale(1.5*self.m_nScaleXPer)

        self:resetNamePos()
        self:resetStarPos()

        self.m_touchSize=cc.size(95,200)
    else
        self:setShadowScale(3*self.m_nScaleXPer)
    end

    self.m_nStatus = -100
    self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
end

function CPlayer.showMount(self)
    if self.m_mountSkinId==0 or not self.m_lpContainer then
        return
    end

    local mountData
    if self.m_mountNode==nil then
        self.m_mountNode=require("mod.general.MountNode")(self.m_SkinId,self.m_mountSkinId,self.m_mountTx,self)

        mountData=self.m_mountNode:getMountData()

        local tempSpine=self.m_mountNode:create()
        self.m_lpCharacterContainer:addChild(tempSpine)
        self.m_touchSize=cc.size(200,250+mountData.idle_y)
        self.m_mountHeight=mountData.height
        self:resetNamePos()
        self:resetStarPos()

        self.m_mountResArray=self.m_mountNode:getMountResArray()
    else
        mountData=self.m_mountNode:getMountData()
    end

    local characterX,characterY
    if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_IDLE then
        characterX,characterY=mountData.idle_x,mountData.idle_y
        self.m_mountNode:runIdle()
    elseif self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_MOVE then
        characterX,characterY=mountData.move_x,mountData.move_y
        self.m_mountNode:runMove()
    end
    if characterX and characterY then
        self.m_lpMovieClipContainer:setPosition(characterX,characterY)
    end
end

function CPlayer.showBody(self,_skinID)
    if self.m_lpContainer==nil or _skinID==nil or _skinID==0 then return end

    local skinIdStr
    if self.m_stageView.m_isCity and not self.m_isShowState then
        if not self.m_isShowState then
            if self.m_mountSkinId>0 then
                self:showMount()
            end
        end
        skinIdStr=string.format("spine/%d",(_skinID%10)*1000+10010)
    else
        skinIdStr=string.format("spine/%d",(_skinID%10)*1000+10020)
    end

    -- if _skinID~=10001 and _skinID~=10002 then
    --     skinIdStr="spine/".._skinID
    -- end

    local function onCallFunc(event)
        self:animationCallFunc(event.type,event.animation,event)
    end

    self.m_lpMovieClip=_G.SpineManager.createSpine(skinIdStr,self.m_skinScale)
    if self.m_lpMovieClip==nil then
        print("lua error CPlayer.showBody self.m_normalName=",skinIdStr)
        self.m_lpMovieClip=_G.SpineManager.createSpine("spine/10001",self.m_skinScale)
        self.m_isNoRes=true
    end
    self.m_lpMovieClip:registerSpineEventHandler(onCallFunc,2)
    self.m_lpMovieClip:registerSpineEventHandler(onCallFunc,3)
    self.m_lpMovieClip:setSkin("A")
    self.m_lpMovieClipContainer:addChild(self.m_lpMovieClip)

    self:resetFeatherSkin()
    self:showStarBody()
    self:resetWeaponSkin()

    CCLOG("CPlayer.loadMovieClip success")
end
function CPlayer.resetFeatherSkin(self)
    if not self.m_stageView.m_isCity then return end
    
    local featherId=self.m_property:getSkinFeather()
    if featherId==self.m_nowEquipFeatherId then return end

    self.m_nowEquipFeatherId=featherId
    
    if self.m_spineFeather~=nil then
        self.m_spineFeather:removeFromParent(true)
        self.m_spineFeather=nil
        self.m_featherResName=nil
        self.m_featherHeight=0

        if not featherId or featherId==0 then
            self:resetNamePos()
            return
        end
    end

    if not featherId or featherId==0 then
        return
    else
        self.m_featherResName=string.format("spine/%d",featherId)
        self.m_spineFeather=_G.SpineManager.createSpine(self.m_featherResName,self.m_skinScale)

        if self.m_spineFeather then
            self.m_featherHeight=_G.Cfg.feather_pos[self.m_SkinId][featherId] or 0
            self.m_lpMovieClipContainer:addChild(self.m_spineFeather,-10)
            self:resetNamePos()
        end
        
        if self.m_nStatus then
            self:setStatus(self.m_nStatus,true)
        end
    end
end
function CPlayer.resetWeaponSkin(self)
    do return end
    if self.m_lpMovieClip then
        local weapon=self.m_property:getSkinWeapon()
        if not weapon or weapon==0 then
            self.m_lpMovieClip:setSkin("0")

            if self.m_wuqiSpine then
                self.m_wuqiSpine:removeFromParent(true)
                self.m_wuqiSpine=nil
            end
        elseif self.m_wuqiSpine==nil then
            -- if self.m_stageView.m_isCity then
                local pro=self.m_property:getPro()
                local zOrder=pro==_G.Const.CONST_PRO_ICEGIRL and 1 or -1
                self.m_wuqiSpine=_G.SpineManager.createSpine(string.format("spine/wq_%d0101",pro),self.m_skinScale)
                -- _G.ShaderUtil:shaderSpineById(self.m_wuqiSpine,7)
                -- self.m_wuqiSpine:setPosition(350,0)

                if not self.m_wuqiSpine then return end
                self.m_lpMovieClipContainer:addChild(self.m_wuqiSpine,zOrder)
            -- end

            self.m_lpMovieClip:setSkin("101")

            local nType=self.m_nStatus or _G.Const.CONST_BATTLE_STATUS_IDLE
            self:setStatus(nType,true)
        end
    end
end

function CPlayer.setWingSkinId(self, _wingSkinId)
    print("CPlayer.setWingSkinId  _wingSkinId=",_wingSkinId)

    _wingSkinId = _wingSkinId or 0
    if _wingSkinId~=0 and self.m_wingSkinId==_wingSkinId then
        return
    end
    self:removeWing()
    self.m_wingSkinId=_wingSkinId
    self:showStarBody()
end

function CPlayer.showStarBody(self)
    local property = _G.GPropertyProxy:getMainPlay()
    if self.m_stageView:isMultiStage() and property:getUid()~=self.m_property:getUid() then
        return
    end

    print("CPlayer.setWingSkinId  _wingSkinId=",self.m_wingSkinId)
    if self.m_wingSkinId==0 or not self.m_lpContainer then
        return
    end
    self:removeWing()
    if self.m_star==nil then
        self.m_star=CPet(_G.Const.CONST_PET)
        self.m_star:petInit(_G.UniqueID:getNewID(),self.m_nLocationX,self.m_nLocationY,self.m_wingSkinId,self)
        self.m_star:setMovePos(self.m_nLocationX,self.m_nLocationY,self.m_nScaleX)
        self.m_stageView:addCharacter(self.m_star)
        self:resetStarPos()
    end
end

function CPlayer.removeWing(self)
    if self.m_star then
        _G.CharacterManager:remove(self.m_star)
        self.m_star:releaseResource()
        self.m_star=nil
    end
end

function CPlayer.showSkillAction( self, _nSkillID)
    local askillId=_G.g_SkillDataManager:getAskillId(_nSkillID)

    if askillId==nil or askillId==0 then
        if self.m_SkinId==10003 then
            askillId=13010
        elseif self.m_SkinId==10005 then
            askillId=15060
        end
        local animationFunc=self.onAnimationCompleted
        self.onAnimationCompleted=function()
            self.m_lpMovieClip:setAnimation(0,"idle",true)
        end
        local function c()
            self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
            self.onAnimationCompleted=animationFunc
        end
        self.m_lpMovieClip:setToSetupPose()
        self.m_lpMovieClip:setAnimation(0,askillId,false)
        local data=_G.g_SkillDataManager:getSkillEffect(_nSkillID)
        local time=data.frame[#data.frame].time
        self.m_lpMovieClip:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(c)))
        return
    end

    -- if askillId < 12000 then
    --     askillId = askillId + 1000
    -- end
    -- if askillId < 12000 then
    --     self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
    --     return
    -- end
    local movieClip = self:getMovieClip()
    if movieClip~=nil then

        if self.m_isMountBattle then
            local attackInv=_G.Cfg.mount_attack[askillId]
            if attackInv~=nil then
                self.m_isMoveAndSkill=true
                local function nFun()
                    if self.m_lpMovePos then
                        self.m_nStatus=_G.Const.CONST_BATTLE_STATUS_MOVE
                    else
                        self.m_nStatus=_G.Const.CONST_BATTLE_STATUS_IDLE
                    end
                    self.m_nSkillDuration=0
                    self.m_nSkillID=0
                end
                self.m_lpMovieClip:runAction(cc.Sequence:create(cc.DelayTime:create(attackInv),cc.CallFunc:create(nFun)))
                self.m_isMoveAndSkill=true
                return
            end
        end

        self.m_isMoveAndSkill=nil

        -- if self.m_SkinId~=10002 then
            -- movieClip:setToSetupPose()
        -- end
        -- self.m_lpMovieClip:setAnimation(0,"skill_"..askillId,false)
        if self.m_isMountBattle then
            self.m_lpMovieClip:setAnimation(0,"skill_"..askillId,false)
            self.m_mountMovieClip:setAnimation(0,"skill_"..askillId,false)
        else
            movieClip:setToSetupPose()
            self.m_lpMovieClip:setAnimation(0,"skill_"..askillId,false)
        end
        return true
    end
end

function CPlayer.showBigSkillEffect( self )
    if self.m_bigSkillShowSprite==nil then
        local node=cc.Node:create()
        local mySpine = cc.Sprite:create(string.format("painting/1000%d_full.png",self.m_nPro))
        -- mySpine       : setFlippedX(true)
        mySpine       : setScale(1.4)
        mySpine       : setAnchorPoint(cc.p(0.5,0))
        mySpine       : setPosition(cc.p(0,0))
        mySpine       : setTag(1)
        node          : addChild(mySpine)

        -- local leg     = cc.Sprite:create(string.format("painting/1000%dleg.png",self.m_nPro))
        -- -- leg           : setFlippedX(true)
        -- leg           : setScale(1.4)
        -- leg           : setAnchorPoint(cc.p(0.5,1))
        -- leg           : setPosition(cc.p(0,130))
        -- leg           : setTag(2)
        -- node          : addChild(leg)
        
        _G.g_Stage.m_lpKOFContainer:addChild(node)
        self.m_bigSkillShowSprite=node
    end
    local size=self.m_stageView.winSize
    local x,y,moveX,moveY=0,0,0,0
    if self.m_nScaleX<1 then
        x=size.width-100
        moveX=100
        self.m_bigSkillShowSprite:setScaleX(1)
    else
        x=100
        moveX=size.width-100
        self.m_bigSkillShowSprite:setScaleX(-1)
    end
    self.m_bigSkillShowSprite:setPosition(cc.p(x,y))

    local move=cc.MoveTo:create(0.3,cc.p(moveX,moveY))
    local fadi=cc.FadeTo:create(0.2,255)
    local hide=cc.Hide:create()
    local time=cc.DelayTime:create(0.6)
    local fado=cc.FadeTo:create(0.2,0)
    local time2=cc.DelayTime:create(0.4)

    local spr=self.m_bigSkillShowSprite:getChildByTag(1)
    -- local leg=self.m_bigSkillShowSprite:getChildByTag(2)
    self.m_bigSkillShowSprite:stopAllActions()
    -- spr:stopAllActions()
    -- leg:stopAllActions()
    spr:runAction(cc.Sequence:create(fadi,time2,fado))
    -- leg:runAction(cc.Sequence:create(fadi:clone(),time2:clone(),fado:clone()))
    self.m_bigSkillShowSprite:setVisible(true)
    self.m_bigSkillShowSprite:runAction(cc.Sequence:create(move,time,hide))
end

function CPlayer.showTakePillEffect(self)
    local takePillSprite = CCSprite:create()
    takePillSprite:setPosition(0, 100)
    self.m_lpCharacterContainer:addChild(takePillSprite, 100)

    local function onActionCallback()
        takePillSprite:removeFromParent(true)
    end

    local animation=genarelAnimation("anim/take_pill_effect.plist","take_pill_effect_")

    local actionsArray = CCArray :create()
    actionsArray:addObject(CCAnimate:create(animation))
    actionsArray:addObject(CCCallFuncN:create(onActionCallback))
    takePillSprite:runAction(CCSequence:create(actionsArray))
end

function CPlayer.releaseResource(self)
    if not self.m_stageView.m_isCity then
        self.m_stageView:removeCurRightHpView(self)
    else
        self:removeMount()
        self:removePet()
        self:removeWing()
    end
    if self.m_lpNameContainer~=nil then
        self.m_lpNameContainer:removeFromParent(true)
        self.m_lpNameContainer=nil
    end

    self:removeAllClones()
    
    if self.m_lpContainer~=nil then
        self:releaseSkillResource()
        if self.m_isCorpse then return end
        self.m_lpContainer:removeFromParent(true)
        self.m_lpContainer=nil
    end
    GCLOG("CPlayer.releaseResource====>>>>self.m_nID=%d",self.m_nID)
end

function CPlayer.getMovieClip( self )
    return self.m_lpMovieClip
end

function CPlayer.setStatus(self, _nStatus, _isReset, _hurtType)
    if _nStatus == self.m_nStatus and not _isReset then
        return
    end
    -- print(_nStatus,"setStatus=========",debug.traceback())
    
    if self.m_lpContainer==nil then return end
    
    local addMovieClip = self.m_lpMovieClip
    local actionName = nil
    local loop = nil
    local index = 0
    if self.m_flySpr~=nil then
        if _nStatus~=_G.Const.CONST_BATTLE_STATUS_MOVE then
            self.m_flySpr:setAnimation(0,"idle",true)
        else
            self.m_flySpr:setAnimation(0,"move",true)
        end
    end
    if _nStatus == _G.Const.CONST_BATTLE_STATUS_IDLE then --站立,循环
        -- self:hideEskillEffect()
        if self.m_isMountBattle then
            -- actionName = "m_idle"..self.m_mountSkinId
        elseif self.m_stageView.m_isCity and not self.m_isShowState then
            actionName = "idle"
        else
            actionName = "idle2"
        end
        loop=true
    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_MOVE then --移动,循环
        if self.m_isMountBattle then
            -- actionName = "m_move"..self.m_mountSkinId
        elseif self.moveActionName~=nil then
            actionName = self.moveActionName
        else
            actionName = "move"
        end
        loop=true
    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_HURT then --受击,循环
        -- self:hideEskillEffect()
        self.m_noHurtSound=nil

        if _hurtType==2 then
            actionName = "hurt2"
        else
            actionName = "hurt"
        end
        self:startHurtVibrate()
        -- if self.m_preHurtName == "hurt" then
        --     actionName = "hurt2"
        -- else
        --     actionName = "hurt"
        -- end
        -- self.m_preHurtName = actionName
        self:cancelTSpeed()
    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_FALL then --倒地,循环
        actionName = "fall"
        self:AshShow()
        -- self:cancelTSpeed()

    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_CRASH then --击飞,循环
        -- self:hideEskillEffect()
        self:removeVitro()
        actionName = "crash"
    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_DEAD then --死亡,非循环
        self : removeAllBuff()
        self:setAI(0)
        actionName = "dead"
        -- self:cancelTSpeed()
    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_USESKILL then --使用技能时,因技能ID不同,外部调用其播放动画
        self.m_nStatus = _nStatus
        -- self :setColliderXml( self.m_nStatus, self.m_SkinId )    --默认职业为 1 先
        if self.m_wuqiSpine then
            self.m_wuqiSpine:setVisible(false)
        end
        return
    end

    self.m_nStatus=_nStatus
    if self.m_stageView.m_isCity then
        if self.m_mountSkinId~=0 and self.m_mountSkinId~=nil then
            self:showMount()
            actionName = "m_"..actionName..self.m_mountSkinId
        end
    end
    if self.m_isMountBattle then
        self:setBattleMountStatus(_nStatus,true)
        return
    end

    self.m_nSkillID = 0
    if addMovieClip~=nil then
        if actionName~=nil then
            if not self.m_stageView.m_isCity and not self.m_isMountBattle then -- self.m_SkinId~=10002 and
                addMovieClip:setToSetupPose()
            end
            addMovieClip:setAnimation(index,actionName,loop)
            if self.m_wuqiSpine then
                self.m_wuqiSpine:setVisible(true)
                self.m_wuqiSpine:setToSetupPose()
                self.m_wuqiSpine:setAnimation(index,actionName,loop)
            end
            if self.m_spineFeather then
                self.m_spineFeather:setToSetupPose()
                self.m_spineFeather:setAnimation(index,string.format("%s_%d",actionName,self.m_SkinId),loop)
            end
        end
    end
end
function CPlayer.setBattleMountStatus(self, _nStatus, _isReset)
    if self.m_nMountStatus==_nStatus and not _isReset then
        return
    end

    self.m_nMountStatus=_nStatus
    self.m_mountMovieClip:setToSetupPose()
    if _nStatus==_G.Const.CONST_BATTLE_STATUS_IDLE then
        self.m_lpMovieClip:setAnimation(0,"m_idle"..self.m_mountSkinId,true)
        self.m_mountMovieClip:setAnimation(0,"idle1",true)
    elseif _nStatus==_G.Const.CONST_BATTLE_STATUS_MOVE then
        self.m_lpMovieClip:setAnimation(0,"m_move"..self.m_mountSkinId,true)
        self.m_mountMovieClip:setAnimation(0,"move",true)
    elseif _nStatus == _G.Const.CONST_BATTLE_STATUS_DEAD then
        self.m_lpMovieClip:setAnimation(0,"dead"..self.m_mountSkinId,false)
        self.m_mountMovieClip:setAnimation(0,"dead",false)
    end
end

--使用技能
function CPlayer.useSkill(self, _nSkillID, _isNetWork)
    -- print("start CPlayer.useSkill _nSkillID=",_nSkillID,"self.m_SkinId=",self.m_SkinId,self.m_nSkillID)
    if self.m_isMountBattle and self.m_isMountBattleEnd then
        return
    end

    if _nSkillID==nil 
        or _nSkillID==0 
        or self.m_isNoRes 
        or self.m_lpContainer==nil then
        return
    end
    if  self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_CRASH
       or (self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_FALL and not self.m_reborning)
       or self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_FROZEN)
       or self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_DIZZY)
       or self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_DEAD then
        return
    end
    if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_HURT and _nSkillID~=self.m_bigSkillId then
        return
    end
    if _nSkillID == self.m_nSkillID and
        self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_USESKILL then
        return
    end

    if self.isMainPlay and self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_KOF and not _isNetWork then
        self:sendToServerUseSkill(_nSkillID)
        return
    end

    if self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_INVINCIBLE) and not self.m_reborning 
        and self.m_buff[_G.Const.CONST_BATTLE_BUFF_INVINCIBLE].id~=499 then
        self:removeBuff(_G.Const.CONST_BATTLE_BUFF_INVINCIBLE)
    end
    -- self:addMP(100)

    if self.m_cutTime~=0 and self.m_nSkillDuration>self.m_cutTime then
        self.m_nNextSkillID=nil
        self.m_nNextSkillID2=nil
        self.m_nNextSkillID3=nil
        self.m_cutSkill=true
    end
    if self.m_nSkillID==0 or (self.m_cutSkill and _nSkillID~=self.m_property:getMountID()) then
        local skillEffectData=_G.g_SkillDataManager:getSkillData(_nSkillID)

        if not self.m_isShowState then
            if skillEffectData==nil then
                CCLOG("CPlayer.useSkill skillEffectData==nil  _nSkillID=%d",_nSkillID)
                return
            end
            local sp = skillEffectData.sp
            if _nSkillID~=self.m_bigSkillId then
                if not self:canSubSp(-sp) then
                    return
                end
                self:addSP(-sp)
            else
                if not self:canSubMp(-sp) then
                    return
                end
                self:addMP(-sp)

                if self.isMainPlay then
                    self:showBigSkillEffect()
                end
            end
        end
        if self.m_isJoyStickPress or self.m_netScalex then
            if self.m_nextScalex then
                self.m_nStatus = nil
                self:setMoveClipContainerScalex(self.m_nextScalex)
            end
        end
        self.m_nextScalex=nil
        self.m_cutSkill=nil
        self.m_iscollider=nil
        self.m_noHurtSound=true

        if self.isMainPlay then
             self.m_stageView:setSkillCD(_nSkillID, skillEffectData.cd)
        end
        self:setSkillCD(_nSkillID,skillEffectData.cd)
        self:setStatus( _G.Const.CONST_BATTLE_STATUS_USESKILL)
        if skillEffectData.type == _G.Const.CONST_SKILL_CHANGE_SKILL then
            self:changeBody()
            return
        end

        if _nSkillID==11900 or _nSkillID==12900 or _nSkillID==13900 or _nSkillID==14900 or _nSkillID==15900 then
            self:hideEskillEffect()
        end

        self.m_beAttackers={}
        self.m_attackTimes=nil
        self.m_attackFrame=nil

        self.m_nSkillDuration = 0
        self.m_skillIndex = 1
        self.m_cutTime = skillEffectData.action_cancle
        self.m_nSkillID = _nSkillID
        -- self:hideEskillEffect()
        self:showSkillAction(_nSkillID)
        self:showSkillEffect(_nSkillID)

        self.m_skillBuffIndex=nil
        if self.m_featherId~=nil then
            local data=_G.g_SkillDataManager:getSkillEffect(_nSkillID)
            local len=#data.frame
            for i=len,1,-1 do
                if data.frame[i].damage==1 then
                    -- self.m_skillBuffIndex=i

                    local data=_G.Cfg.feather_quality[self.m_featherId][self.m_featherLv]
                    if data~=nil then
                        local num=gc.MathGc:random_0_1()
                        if num<data.odds then
                            self.m_skillBuffIndex=i
                        end
                    end
                    break
                end
            end
        end

        self.m_addMpSkillId=nil

        if _nSkillID==self.m_nNextSkillID then
            self.m_nNextSkillID=nil
        end

        if self.m_isShowState then
            return 
        end
    else
        -- CCLOG("CPlayer.useSkill self.m_nNextSkillID  _nSkillID=%d",_nSkillID)

        if self.m_bigSkillId==self.m_nNextSkillID then
            return
        end

        self.m_nNextSkillID = _nSkillID
        return
    end

    if not _isNetWork and self.m_enableBroadcastSkill then
        self:sendToServerUseSkill(_nSkillID)
    end
    -- print("end CPlayer.useSkill _nSkillID=",_nSkillID,"self.m_SkinId=",self.m_SkinId)
end

function CPlayer.think( self, _now )
    if not self.m_nAI or self.m_nAI == 0 then
        return
    end
    --判断是否有反应
    if _now - self.m_fLastThinkTime < self.m_fThinkInterval then   
        return
    end
    self.m_fLastThinkTime = _now

    if self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CHALLENGEPANEL or 
        self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_KOF then
        self:runTheAI(_now)
        return
    end

    if self.m_stageView.isGoingNextCheckPoint or _G.CharacterManager:isMonsterEmpty() then

        if not _G.CharacterManager:isGoodsEmpty() then
            local goodsList = _G.CharacterManager:getGoods()
            for _,goods in pairs(goodsList) do
                local deltaX = math.abs(self.m_nLocationX-goods.m_nLocationX)
                local deltaY = math.abs(self.m_nLocationY-goods.m_nLocationY)
                if deltaX>50 or deltaY>50 then
                    self:setMovePos({x=goods.m_nLocationX,y=goods.m_nLocationY})
                else
                    self.m_stageView:checkCollisionGoods(self,goods.m_nLocationX,goods.m_nLocationY)
                end
                self.m_fLastThinkTime = _now+2000
                return
            end
        elseif self.m_isFinishBattle then
            local transportList = _G.CharacterManager:getTransport()
            if self.m_stageView.m_sceneType==_G.Const.CONST_MAP_CLAN_DEFENSE then
                local table={}
                for k,v in pairs(transportList) do
                    table[{}]=v
                end
                transportList=table
            end
            for _,transporCharacter in pairs(transportList) do
                if math.ceil(self.m_nLocationX)==math.ceil(transporCharacter.m_nLocationX) 
                    and math.ceil(self.m_nLocationY)==math.ceil(transporCharacter.m_nLocationY) then
                    self:setMovePos({x=transporCharacter.m_nLocationX-400,y=transporCharacter.m_nLocationY})
                    return
                end
                self:setMovePos({x=transporCharacter.m_nLocationX,y=transporCharacter.m_nLocationY})
                
                if self.m_stageView.m_sceneType==_G.Const.CONST_MAP_CLAN_DEFENSE
                    and self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_MOVE then
                    self.m_fLastThinkTime = _now+10000
                else
                    self.m_fLastThinkTime = _now+2000
                end
                return
            end
        end

        if self.m_stageView.m_nMapBornX then
            if self.m_nLocationX<self.m_stageView.m_nMapBornX+10 then
                self:setMovePos({x=self.m_stageView.m_nMapBornX+20,y=180})
            end
            return
        end
    end

    self:runTheAI(_now)
end

function CPlayer.runTheAI( self, _now )
    if not self.m_property then
        return
    end

    if _now - self.m_fLastAttackTime < self.m_fAttackInterval then
        return
    end

    if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_DEAD then
        self.m_nAI=nil
        return
    elseif self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_FALL or
        self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_CRASH then
        return
    elseif self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_USESKILL or
        (self.m_nSkillID and self.m_nSkillID>0) then
        local tempBuff=self.m_buff[_G.Const.CONST_BATTLE_BUFF_SKILL_MOVE]
        if tempBuff then
            self:runSkillMoveAI(tempBuff)
        end
        return
    end

    -- if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_MOVE then
    --     
    --     return
    -- end

    if not self.m_nTarget then
        self.m_nTarget = self:findNearTarget()
    elseif self.m_nTarget.m_nStatus == _G.Const.CONST_BATTLE_STATUS_FALL then
        if self.m_targetCount>2 then
            self.m_nTarget = self:findNearTarget()
        end
    elseif self.m_nTarget:getHP() == 0 then
        self.m_nTarget = self:findNearTarget()

        self.m_nNextSkillID = 0
        -- self.m_nNextSkillID2 = 0
        -- self.m_nNextSkillID3 = 0
    end

    if not self.m_nTarget then
        if self.m_nTarget==false then
            self.m_nTarget=nil
            return
        end
        self:evade()
        return
    end

    -- if (self.m_nSkillID and self.m_nSkillID > 0) or
    --     self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_USESKILL then
    --     return
    -- end

    -- CCLOG("CPlayer.runTheAI 找到目标  IA=%d",self.m_nAI)


    if not self.m_attackSkillDatas then
        self:produceAttackSkillDatas()
        if not self.m_attackSkillDatas then
            return
        end
    end
    if self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CHALLENGEPANEL then
        if math.abs(self.m_nLocationX-self.m_nTarget.m_nLocationX)<80 and
            math.abs(self.m_nLocationY-self.m_nTarget.m_nLocationY)<60 and
            _now-self.m_fLastTraceTime>self.m_fTraceInterval then

            self.m_fLastTraceTime=_now

            local directTarget = self:adjustDirect(self.m_nTarget)
            if directTarget>0 then
                local lx = self.m_stageView:getMaplx()
                local moveX = 0
                if self.m_nLocationX<lx+100 then
                    moveX = self.m_nLocationX+math.random(0,150)+100
                else
                    moveX = self.m_nLocationX-100
                end
                self:setMovePos({x=moveX,y=self.m_nLocationY})
            else
                local rx = self.m_stageView:getMaprx()
                local moveX = 0
                if self.m_nLocationX>rx-100 then
                    moveX = self.m_nLocationX-math.random(0,150)-100
                else
                    moveX = self.m_nLocationX+100
                end
                self:setMovePos({x=moveX,y=self.m_nLocationY})
            end
            return
        end
    end

    self:gotoFight(_now)
end

function CPlayer.findNearTarget(self)
    local property = self:getProperty()
    self.m_targetCount=0
    local charList = _G.CharacterManager:getNoHookCharacter()
    local target = nil
    local minDist = 100000000

    for k,char in pairs(charList) do
        local charProperty = char.m_property
        local isCanBeTarget = nil
        if charProperty~=nil and 
            not(charProperty:getTeamID() == property:getTeamID() 
                or char.m_nStatus==_G.Const.CONST_BATTLE_STATUS_DEAD 
                or char.m_nStatus==_G.Const.CONST_BATTLE_STATUS_FALL
                or char.m_noBeTarget==true
                ) then
            self.m_targetCount=self.m_targetCount+1
            isCanBeTarget=true
        -- elseif char.m_nType == _G.Const.CONST_GOODS then
        --     if self.m_stageView.m_nMaprx>char.m_nLocationX then
        --         isCanBeTarget=true
        --     end
        elseif char.m_nType == _G.Const.CONST_GOODS_MONSTER  then --and char.m_hurtTimes<_G.Const.CONST_COPY_BOX_HIT
            if self.m_stageView.m_nMaprx>char.m_nLocationX then
                isCanBeTarget=true
            end
        end

        if isCanBeTarget then
            -- 改
            if self.m_stageView:getScenesType() == _G.Const.CONST_MAP_TYPE_CITY_BOSS then
                if char.m_nType == _G.Const.CONST_MONSTER then
                    target = char
                    break
                end
            end
            local deltaX = self.m_nLocationX  - char.m_nLocationX
            local deltaY = self.m_nLocationY - char.m_nLocationY
            local dist =deltaX*deltaX + deltaY*deltaY
            if dist < minDist then
                minDist = dist
                target = char
            end
        end
    end

    -- if target~=nil and target.m_nType == _G.Const.CONST_GOODS then
    --     if minDist > 900 then
    --         self:setMovePos({x=target.m_nLocationX,y=target.m_nLocationY})
    --     else
    --         self.m_stageView:checkCollisionGoods(self,target.m_nLocationX,target.m_nLocationY)
    --     end
    --     self.m_targetCount=0
    --     return false
    -- end
    return target
end

function CPlayer.evade(self)
    if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_MOVE then return end
    if self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_CHALLENGEPANEL then
        return
    end
    local lx = self.m_stageView:getMaplx()
    local rx = self.m_stageView:getMaprx()
    if self.m_nLocationX > rx - 100 then
        self:setMoveClipContainerScalex(-1)
    else
        self:setMoveClipContainerScalex(1)
    end
    -- print(self.m_nLocationX > rx - 100 ,self.m_nScaleX,"player.evade")
    local x = math.random(500,1000) * self.m_nScaleX
    local moveX = self.m_nLocationX+x
    local maxY,minY = self.m_stageView:getMapLimitHeight(moveX)
    local moveY
    if self.m_nLocationY > (maxY - minY)/2 then
        moveY = minY
    else
        moveY = maxY
    end
    self:setMovePos({x=moveX,y=moveY})
    return true
end

function CPlayer.gotoFight(self,_now)
    local availableAttackSkillDatas = {}
    local availableAttackSkillCount = 0
    for skillId,attackSkillData in pairs(self.m_attackSkillDatas) do
        if skillId~=1 then
            if self:canSubSp(-attackSkillData.sp) and not self:isSkillCD(skillId) then
                availableAttackSkillCount=availableAttackSkillCount+1
                availableAttackSkillDatas[availableAttackSkillCount]=attackSkillData
            end
        end
    end

    local normalAttackSkillData
    if self.m_isMountBattle then
        normalAttackSkillData=availableAttackSkillDatas[1]
    else
        normalAttackSkillData=self.m_attackSkillDatas[1]
        if normalAttackSkillData~=nil then
            availableAttackSkillCount=availableAttackSkillCount+1
            availableAttackSkillDatas[availableAttackSkillCount]=normalAttackSkillData
        end
    end

    if self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_CHALLENGEPANEL then
        local ranIndex=math.random(1,availableAttackSkillCount)
        local data = availableAttackSkillDatas[1]
        availableAttackSkillDatas[1]=availableAttackSkillDatas[ranIndex]
        availableAttackSkillDatas[ranIndex]=data
    end

    local directTarget= self:adjustDirect(self.m_nTarget)

    local startI,endI,addI
    if math.random(1,10)<5 then
        startI,endI,addI=1,availableAttackSkillCount,1
    else
        startI,endI,addI=availableAttackSkillCount,1,-1
    end
    for i=startI,endI,addI do
        local attackSkillData=availableAttackSkillDatas[i]
        local nCollider=attackSkillData.attackCollider
        local attack_skill=attackSkillData.attack_skill

        -- print(_G.CharacterManager:checkColliderByCharacter(self, nCollider, self.m_nTarget),attack_skill[1])

        if _G.CharacterManager:checkColliderByCharacter(self, nCollider, self.m_nTarget) then
            self:setAIBlockWithCollider(nCollider)
            
            self:cancelMove()
            self.m_fLastAttackTime = _now

            self.m_nNextSkillID  = attack_skill[2]
            self.m_nNextSkillID2 = attack_skill[3]
            self.m_nNextSkillID3 = attack_skill[4]

            self:useSkill(attack_skill[1])
            return
        end
    end
    if not normalAttackSkillData or not normalAttackSkillData.traceCollider then
        return
    end
    
    if _now-self.m_fLastTraceTime<self.m_fTraceInterval then
        return
    end
    self.m_fLastTraceTime=_now

    if self.m_stageView.m_sceneType ~= _G.Const.CONST_MAP_TYPE_CHALLENGEPANEL then
        
        if self.m_targetCount~=nil and self.m_targetCount>2 then
            if self.m_chaseTarget==nil then
                self.m_chaseTarget=self.m_nTarget
            else
                if self.m_chaseTarget==self.m_nTarget then
                    self.m_chaseTarget=nil
                    self.m_nTarget=self:findNearTarget()
                    if not self.m_nTarget then
                        self.m_nTarget=nil
                        return
                    end
                else
                    self.m_chaseTarget=self.m_nTarget
                end
            end
        end
    end

    local selfx,selfy= self:getLocationXY()
    local targetx,targety = self.m_nTarget:getLocationXY()
    -- print(selfx,selfy,targetx,targety,"@#$@%@%@")

    if self.m_nTarget.m_nStatus==_G.Const.CONST_BATTLE_STATUS_MOVE then
        if directTarget>0 then
            if self.m_nTarget.m_nScaleX>0 then
                selfx=selfx+80
            end
        else
            if self.m_nTarget.m_nScaleX<0 then
                selfx=selfx-80
            end
        end
    end

    local chX,chY,chWidth,chHeight=self.m_nTarget:getWorldCollider()
    if not chX or not chY or not chWidth or not chHeight then
        print("lua error CPlayer.gotoFight m_nTarget:getWorldCollider==nil m_SkinId=",self.m_nTarget.m_SkinId)
        self.m_nTarget=nil
        return
    end
    
    local nCollider =normalAttackSkillData.traceCollider
    self:setAIBlockWithCollider(nCollider,true)
    
    local cX, cY,_,cWidth, cHeight = self:getConvertCollider(nCollider)
    if not cX or not cY or not cWidth or not cHeight then
        print("lua error CPlayer.gotoFight getConvertCollider(nCollider)==nil m_SkinId=",self.m_SkinId)
        self.m_nTarget=nil
        return
    end
    local targetCenterX =chX+chWidth*0.5
    local targetCenterY = chY+chHeight*0.5

    local seftCenterX = cX+cWidth*0.5
    local seftCenterY = cY+cHeight*0.5

    local deltaX = math.abs(seftCenterX-targetCenterX)
    deltaX= deltaX==0 and 0.000001 or deltaX
    local deltaY =math.abs(seftCenterY-targetCenterY)
    local targetSlope =chHeight/chWidth
    local selfSlope = deltaY/deltaX

    local moveDelta  = 0
    local moveXDelta = 0
    local moveYDelta = 0

    -- local distane = math.sqrt(deltaX*deltaX+deltaY*deltaY)
    -- print(selfSlope,targetSlope,"YYWEYWYE")
    -- if selfSlope>targetSlope then
    --     moveYDelta = deltaY-(chHeight+cHeight)*0.5
    --     moveDelta = distane*moveYDelta/deltaY

    --     moveXDelta=deltaX*moveDelta/distane
    -- elseif selfSlope<targetSlope then
    --     print("YYYYYY")
    --     moveXDelta=deltaX-(chWidth+cWidth)*0.5
    --     print(moveXDelta)
    --     moveXDelta=deltaX-(chWidth+cWidth+cX)*0.5
    --     print(moveXDelta)

    --     moveDelta=distane*moveXDelta/deltaX

    --     moveYDelta=deltaY*moveDelta/distane
    -- else
    --     moveXDelta=deltaX-(chWidth+cWidth)*0.5+15
    --     moveDelta=distane*moveXDelta/deltaX

    --     moveYDelta=deltaY*moveDelta/distane
    -- end
    moveXDelta=deltaX-(chWidth+cWidth)/2
    
    if cY + cHeight < chY or chY + chHeight < cY then
        moveYDelta = deltaY-(chHeight+cHeight)/2
    end
    if seftCenterX>=targetCenterX then
        moveXDelta=-moveXDelta
    end

    if seftCenterY>=targetCenterY then
        moveYDelta=-moveYDelta
    end

    local moveX = selfx+moveXDelta
    local moveY = selfy+moveYDelta
    -- print("movese",moveX,moveY)
    self:setMovePos({x=moveX,y=moveY})

end

function CPlayer.runSkillMoveAI(self,_buff)
    if not self.m_nTarget then
        self.m_nTarget=self:findNearTarget()
        if not self.m_nTarget then return end
    end

    local nPosX,nPosY=self.m_nTarget:getLocationXY()
    local tempX,tempY
    if _buff.data==1 then
        -- 能转向
        tempX=math.random(nPosX-100,nPosX+100)
    else
        if self.m_nLocationX>nPosX then
            tempX=math.random(nPosX+50,nPosX+100)
        else
            tempX=math.random(nPosX-100,nPosX-50)
        end
    end
    tempY=math.random(nPosY-100,nPosY+100)
    
    tempX,tempY=self:convertLimitPos(tempX,tempY)
    self:setMovePos({x=tempX,y=tempY})

    local tempScaleX=tempX>self.m_nLocationX and 1 or -1
    self:setMoveClipContainerScalex(tempScaleX)
end

function CPlayer.setLocation( self, _x, _y, _z )
    _z = _z<0 and 0 or _z

    _x=math.floor(_x)
    _y=math.floor(_y)
    _z=math.floor(_z)

    if not self.unlimitPosition then
        _x,_y = self:convertLimitPos( _x, _y)

        local subX=self.m_nLocationX
        if self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
            if self.m_stageView.m_lpPlay~=nil and self.m_stageView.m_lpPlay.m_lpContainer==nil then
                if self.m_stageView.m_survival==nil or self.m_stageView.m_survival.m_lpContainer==nil then
                    self.m_stageView.m_survival=self
                end
            --     if self.m_stageView.m_survival==self then
            --         self.m_stageView:moveArea(_x,_y,self.m_nLocationX,self.m_nScaleX)
            --     end
            -- else
            --     if self.isMainPlay then
            --         self.m_stageView:moveArea(_x,_y,self.m_nLocationX,self.m_nScaleX)
            --     end
            end
        -- else
        --     if self.isMainPlay then
        --         self.m_stageView:moveArea(_x,_y,self.m_nLocationX,self.m_nScaleX)
        --     end
        end
    end

    self.m_nLocationX = _x
    self.m_nLocationY = _y
    self.m_nLocationZ = _z

    -- self.m_lpContainer:setScale(1-math.abs(_y)/100*0.06)
    self.m_lpContainer:setPosition(_x, _y)
    self.m_lpCharacterContainer:setPosition(0,_z)
    self:onUpdateZOrder()
    self:resetSkillEffectObjectPos()
end

function CPlayer.convertLimitPos( self, _x , _y )
    local stage = self.m_stageView
    if stage ~= nil and stage:getCanControl() == true then
        local lx = stage:getMaplx()
        local rx = stage:getMaprx()

        if self.m_obstacleLimitLx ~= nil then
            lx = self.m_obstacleLimitLx
        end
        if self.m_obstacleLimitRx ~= nil then
            rx = self.m_obstacleLimitRx
        end

        lx = lx + 80
        rx = rx - 80
        local isCancelMove = false
        if _x <= lx then
            _x=lx
            isCancelMove=true
        elseif _x >= rx then
            _x=rx
            isCancelMove=true
        end

        local maxY,minY = stage:getMapLimitHeight(_x)

        if _y <= minY then
            _y=minY+1
            isCancelMove=true
        elseif _y >= maxY then
            _y=maxY-1
            isCancelMove=true
            -- if self.isMainPlay and self.m_stageView.m_isCity then
            --     if self.m_lpMovePos~=nil then
            --         self.m_lpMovePos.radian=nil
            --     end
            -- end
        end

        -- if isCancelMove and self.m_nAI and self.m_nAI~=0 then
        --     self:cancelMove()
        -- end
    end
    return _x,_y
end


function CPlayer.setMovePos(self,_movePos,_isNetWork)
    if _movePos and self.m_lpContainer~=nil then

        if self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_USESKILL then
            if self.m_isJoyStickPress then
                if self.m_nLocationX<=_movePos.x then
                    self.m_nextScalex=1
                else
                    self.m_nextScalex=-1
                end
            end
            if not self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_SKILL_MOVE) and not self.m_isMoveAndSkill then
                return
            end
        else
            self.m_nextScalex=nil
            if (self.m_nStatus~=_G.Const.CONST_BATTLE_STATUS_IDLE and self.m_nStatus~=_G.Const.CONST_BATTLE_STATUS_MOVE) then
                return
            end
        end

        if self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_FROZEN)
            or self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_DIZZY) then
            return
        end

        local limitPosX,limitPosY=self:convertLimitPos(_movePos.x, _movePos.y)

        if self.isMainPlay then
            local deltaX=self.m_nLocationX-limitPosX
            local deltaY=self.m_nLocationY-limitPosY
            local characterDistance=deltaX*deltaX+deltaY*deltaY
            if characterDistance<1 then
                -- local tempCount=0
                -- for k,v in pairs(_G.CharacterManager.m_lpMonsterArray) do
                --     tempCount=tempCount+1
                --     print("KKKKK====>>>",v.m_nLocationX,v.m_nLocationY)
                -- end
                -- print("XXXX 1===>>",self.m_nLocationX,self.m_nLocationY)
                -- print("XXXX 2===>>",_movePos.x, _movePos.y)
                -- print("XXXX 3===>>",limitPosX, limitPosY)
                -- print("XXXX 3===>>",tempCount)
                return
            end
        end

        if self.isMainPlay and self.m_stageView.m_sceneType==_G.Const.CONST_MAP_TYPE_KOF then
            -- if not _isNetWork then
                local dir=limitPosX>self.m_nLocationX and 1 or 0
                self.m_stageView:onRoleMove(self, _movePos.x, _movePos.y,dir, false)
                -- return
            -- end
        elseif self.m_enableBroadcastMove then
            self.m_lastMovePos=_movePos
            -- self.m_stageView:onRoleMove(self, _movePos.x, _movePos.y,self.m_nScaleX, false)
        end

        -- if self.m_enableBroadcastMove then
        --     self.m_stageView:onRoleMove(self, _movePos.x, _movePos.y,self.m_nScaleX, false)
        -- end

        self.m_lpMovePos={x=limitPosX,y=limitPosY}

        if self.m_nLocationX<=self.m_lpMovePos.x then
            self:setMoveClipContainerScalex(1)
        else
            self:setMoveClipContainerScalex(-1)
        end

        if self.m_nStatus == _G.Const.CONST_BATTLE_STATUS_IDLE then
            self:setStatus(_G.Const.CONST_BATTLE_STATUS_MOVE)
        elseif self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_USESKILL then
            if self.m_isMoveAndSkill then
                self:setBattleMountStatus(_G.Const.CONST_BATTLE_STATUS_MOVE)
            end
        end

        if self.m_pet then
            self.m_pet:setMovePos(self.m_lpMovePos.x,self.m_lpMovePos.y,self.m_nScaleX)
        end
        if self.m_star then
            self.m_star:setMovePos(self.m_lpMovePos.x,self.m_lpMovePos.y,self.m_nScaleX)
        end
        -- if self.isMainPlay and self.m_stageView.m_isCity then
        --     _G.SysInfo:setGameIntervalHigh()
        -- end
    end

end

function CPlayer.cancelMove( self )
    -- if self.m_lpMovePos ~= nil then
        -- print(self.m_lpMovePos.x,self.m_lpMovePos.y,self.m_nLocationX,self.m_nLocationY,"werwererwerer",debug.traceback())
    -- end
    self.m_lpMovePos=nil
    if self.m_nStatus==Const.CONST_BATTLE_STATUS_MOVE then
        self:setStatus(Const.CONST_BATTLE_STATUS_IDLE)
    elseif self.m_nStatus==Const.CONST_BATTLE_STATUS_IDLE then
        return
    elseif self.m_nStatus==Const.CONST_BATTLE_STATUS_USESKILL then
        if self.m_isMoveAndSkill then
            self:setBattleMountStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
        end
        return
    end

    if self.m_enableBroadcastMove then
        self.m_lastMovePos=nil
        self.m_stageView:onRoleMove(self, self.m_nLocationX, self.m_nLocationY, self.m_nScaleX, true)
        self.m_lastUpdatePosTime=_G.TimeUtil:getTotalMilliseconds()
    end

    if self.isMainPlay then
        local isEnterNpc=false
        if self.taskTargetNpcId then
            isEnterNpc=self.m_stageView:checkNPCZone(self.taskTargetNpcId,self.m_nLocationX,self.m_nLocationY,self.isUserTouch)
            self.taskTargetNpcId=nil
            self.isUserTouch=nil
        end
        if not isEnterNpc then
            self.m_enterTransportTimes=self.m_enterTransportTimes or 0
            local curTime=_G.TimeUtil:getTotalMilliseconds()
            if self.m_enterTransportTimes+1000>curTime then return end
            local isEnterTransport=self.m_stageView:checkTransportZone(self.m_nLocationX,self.m_nLocationY)
            if isEnterTransport then
                self.m_enterTransportTimes=curTime
            end
        end
    end

    self:mapAreaStop()

    -- if self.isMainPlay and self.m_stageView.m_isCity then
    --     _G.SysInfo:setGameIntervalLow()
    -- end

    if self.m_star then
        self.m_star:setMovePos(self.m_nLocationX,self.m_nLocationY,self.m_nScaleX,true)
    end

    if self.m_pet then
        self.m_pet:setMovePos(self.m_nLocationX,self.m_nLocationY,self.m_nScaleX)
    end
end

function CPlayer.cancelTSpeed(self)
    -- print("self.m_TSpeed~=nil",self.m_TSpeed~=nil)
    if self.m_TSpeed~=nil then
        self.m_TSpeed=nil
        self:mapAreaStop()
        if self.m_star and self.m_star.m_lpMovePos==nil then
            self.m_star:setMovePos(self.m_nLocationX,self.m_nLocationY,self.m_nScaleX,true)
        end
    end
end

function CPlayer.mapAreaStop(self)
    if self.unlimitPosition then return end
    if self.m_stageView.m_sceneType == _G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
        if self.m_stageView.m_lpPlay~=nil and self.m_stageView.m_lpPlay.m_lpContainer==nil then
            if self.m_stageView.m_survival==nil or self.m_stageView.m_survival.m_lpContainer==nil then
                self.m_stageView.m_survival=self
            end
        --     if self.m_stageView.m_survival==self then
        --         self.m_stageView:moveAreaGradually(self.m_nLocationX,self.m_nLocationY,self.m_nScaleX)
        --     end
        -- else
        --     if self.isMainPlay then
        --         self.m_stageView:moveAreaGradually(self.m_nLocationX,self.m_nLocationY,self.m_nScaleX)
        --     end
        end
    -- else
    --     if self.isMainPlay then
    --         self.m_stageView:moveAreaGradually(self.m_nLocationX,self.m_nLocationY,self.m_nScaleX)
    --     end
    end
end

function CPlayer.onUpdate( self, _duration, _nowTime )
    if self.isMainPlay then
        self:updateMainPlayer(_nowTime)
    end

    self:onUpdateSkillEffectObject(_duration)
    self:onUpdateUseSkill(_duration)
    self:onUpdateBuff(_duration)
    self:onUpdateDead(_nowTime)
end
function CPlayer.updateMainPlayer(self,_nowTime)
    -- print("updateMainPlayer======>>>")
    self:onUpdateGoodsCollision()

    -- print(self.m_enableBroadcastMove,_nowTime,self.m_lastUpdatePosTime)
    if self.m_enableBroadcastMove then
        if _nowTime-self.m_lastUpdatePosTime>1000 then
            -- print("self.m_lastMovePos~=nil",self.m_lastMovePos~=nil)
            if self.m_lastMovePos~=nil then
                self.m_stageView:onRoleMove(self, self.m_lastMovePos.x, self.m_lastMovePos.y,self.m_nScaleX, false)
                self.m_lastUpdatePosTime=_nowTime
                self.m_lastMovePos=nil
            elseif not self.m_stageView.m_isCity and self.m_nHP>0 then
                if self.m_nStatus~=_G.Const.CONST_BATTLE_STATUS_MOVE and self.m_nStatus~=_G.Const.CONST_BATTLE_STATUS_IDLE then
                    self.m_lastUpdatePosTime=_nowTime
                    self.m_stageView:onRoleMove(self, self.m_nLocationX, self.m_nLocationY, self.m_nScaleX, false)
                end
            end
        end
    end
end

--更新生物与NPC的碰撞
function CPlayer.onUpdateGoodsCollision( self )
    if not self.m_lpMovePos then
        return
    end

    if self.m_lpGoodsCollisionCallBackPos.x==self.m_nLocationX and self.m_lpGoodsCollisionCallBackPos.y==self.m_nLocationY then
        return
    end
    self.m_stageView:checkCollisionGoods(self, self.m_nLocationX, self.m_nLocationY)
    self.m_lpGoodsCollisionCallBackPos.x = self.m_nLocationX
    self.m_lpGoodsCollisionCallBackPos.y = self.m_nLocationY
end

function CPlayer.onUpdateDead( self,_nowTime)
    if self.m_nHP>0 then
        if self.m_onUpdateSpTime+1000>_nowTime then
            return
        end
        self.m_onUpdateSpTime=_nowTime
        self:addSP(self.m_spUP)

        if self.m_starBuff and self.m_starBuffCD then
            if self.m_onUpdateStartTime+self.m_starBuffCD>_nowTime then
                return
            end
            local invBuff=_G.GBuffManager:getBuffNewObject(self.m_starBuff,0)
            self:addBuff(invBuff)
        elseif self.m_hpUP then
            if self.m_onUpdateStartTime+30000>_nowTime then
                return
            end

            self.m_star:setStatus(_G.Const.CONST_BATTLE_STATUS_USESKILL)
            self:showSkillEffect(49300)
            self:addHP(math.ceil(self.m_nMaxHP*self.m_hpUP))
        end
        self.m_onUpdateStartTime=_nowTime
        return
    end

    if self.m_nLocationZ>0 then
        return
    end
    
    if self.m_nStatus~=_G.Const.CONST_BATTLE_STATUS_CRASH then
        self:setStatus(_G.Const.CONST_BATTLE_STATUS_DEAD)
    end
end

function CPlayer.addHP( self,_nHP,_crit,_bleed)
    local currentHP=self.m_nHP+_nHP
    self:setHP(currentHP)
    if _nHP<0 then
        if _crit then
            self:showCritHurtNumber(-_nHP)
        else
            if _bleed then
                self:showBleedHurtNumber(-_nHP)
            else
                self:showNormalHurtNumber(-_nHP)
            end
        end
        if self.isMainPlay then
            currentHP=currentHP>0 and currentHP or 1
            if currentHP/self.m_nMaxHP <=0.3 then
                self.m_stageView:showPlayerLowHP()
            end            
        end

        self:addMP(_G.Const.CONST_BATTLE_HURT_ADD_MP)
    elseif _nHP>0 then
        self:showAddHpNumber(_nHP,1)
    end
end

function CPlayer.canSubMp( self, _nMP )
    return self.m_nMP>=-_nMP
end
function CPlayer.getMP(self)
    return self.m_nMP
end

function CPlayer.setMP(self,_nMP)
    -- print("CPlayer.setMP  _nMP=",_nMP,"self.m_nMaxMP=",self.m_nMaxMP)
    if self.m_unableBigSkill then
        return
    end
    
    _nMP=_nMP <=0 and 0 or _nMP
    self.m_nMaxMP=100
    _nMP=_nMP >= self.m_nMaxMP and self.m_nMaxMP or _nMP

    self.m_nMP=_nMP
    -- if self.m_lpBigHp~=nil then
    --     self.m_lpBigHp:setMPValue(self.m_nMP,self.m_nMaxMP)
    -- end

    if self.isMainPlay and self.m_stageView.m_keyBoard~=nil then
        -- if self.m_nMP==self.m_nMaxMP then
            -- self.m_stageView.m_keyBoard:showBigSkillBtn()
        -- else
            -- self.m_stageView.m_keyBoard:hideBigSkillBtn()
        -- end
        self.m_stageView.m_keyBoard:updateSkillBtn(self.m_nMP,self.m_nMaxMP)
    end
end

function CPlayer.addMP(self, _nMP)
    self:setMP(self.m_nMP+_nMP)
end

function CPlayer.findTaskNPC(self,_movePos,_npcId,_isUserTouch)
    self.taskTargetNpcId=_npcId
    self.isUserTouch=_isUserTouch
    self:setMovePos(_movePos)
end

function CPlayer.getSkinID( self )
    return self.m_SkinId
end

function CPlayer.setPro( self, _pro )
    self.m_nPro = _pro
end
function CPlayer.getPro( self )
    return self.m_nPro
end

-- function CPlayer.setIsWar( self, _isWar )
--     self.m_bIsWar = _isWar
-- end
-- function CPlayer.getIsWar( self )
--     return self.m_bIsWar
-- end

-- function CPlayer.setLeaderUID( self, _leaderUid )
--     self.m_nLeaderUid = _leaderUid
-- end
-- function CPlayer.getLeaderUID( self )
--     return self.m_nLeaderUid
-- end

function CPlayer.setClan( self, _clan )
    self.m_nClan = _clan
end
function CPlayer.getClan( self )
    return self.m_nClan
end

function CPlayer.setClanPost( self, _clanPost )
    self.m_szClanPost = _clanPost
end
function CPlayer.getClanPost( self )
    return self.m_szClanPost
end

function CPlayer.enableAI(self,_enableAI)
    if _enableAI==true then
        if not self.m_attackSkillDatas then
            if self.m_isMountBattle then
                local mountId=_G.Cfg.mount_battle[self.m_mountSkinId].id
                local mountAI=_G.Cfg.mount_des[mountId].ai
                self : setAI(mountAI)
                self : getAllAttackSkill()
            else
                self : setAI(self.m_preAi or self:getProperty():getAI())
                self : produceAttackSkillDatas()
            end
        else
            self : setAI(self.m_preAi or self:getProperty():getAI())
        end
    else
        self : setAI(0)
    end
end

function CPlayer.initTouchSelf( self )
    if self.isMainPlay then return end

    if not self.m_mountNode then
        self.m_touchSize=cc.size(95,200)
    else
        self.m_touchSize=cc.size(200,250+self.m_mountNode:getMountData().idle_y)
    end
end

local ranPosX1=cc.Director:getInstance():getWinSize().width*0.5
local ranPosX2=-ranPosX1
function CPlayer.onGetItem(self, _itemId)
    if self.m_lpContainer==nil then return end
    
    local itemNode = _G.Cfg.goods[_itemId]
    local iconSprite = _G.ImageAsyncManager:createGoodsSpr(itemNode)
    iconSprite:setPosition(math.random(ranPosX2,ranPosX1),640)
    self.m_lpContainer:addChild(iconSprite,100)
    local function onMovedCallback()
        self.m_lpContainer:removeChild(iconSprite, true)
    end
    local act1=cc.MoveTo:create(2, cc.p(0,50))
    local act2=cc.CallFunc:create(onMovedCallback)
    iconSprite:runAction(cc.Sequence:create(act1,act2))
    iconSprite:runAction(cc.ScaleTo:create(2,0.2))
end
function CPlayer.showStar(self)
    if self.m_star~=nil then
        self.m_star.m_lpContainer:setVisible(true)
    end
end
function CPlayer.hideStar(self)
    if self.m_star~=nil then
        self.m_star.m_lpContainer:setVisible(false)
    end
end
function CPlayer.showSoul( self )
    self.setHP=function ( self,_nHP ) end
    local property = _G.GPropertyProxy:getMainPlay()
    if property.soulStatus~=true then return end
    self.m_lpMovieClip:setOpacity(90)
    self.m_noBeTarget=true
    self.m_enableBroadcastMove=nil
    self.dodge=function (  ) end
    self.m_stageView:removeKeyBoard()
end
function CPlayer.reborn( self,_nHP)
    -- if self.m_isMountBattle then
    --     self:chuangeToPlayerBattle(true)
    -- end

    self.m_nHP=1
    self.m_isRebornYet=true
    self.m_playHp=nil
    self.m_property.m_isReborn=true
    local invBuff= _G.GBuffManager:getBuffNewObject(407, 0)
    self:addBuff(invBuff)

    if self.m_isMountBattle then
        self:setStatus( _G.Const.CONST_BATTLE_STATUS_DEAD)
        local showSkillActionf=self.showSkillAction
        self.animationFunc=self.onAnimationCompleted

        self.showSkillAction=function (  ) end
        self.onAnimationCompleted=function ( self, eventType, _animationName )
            if _animationName=="dead" then
                self.m_reborning=true
                self.m_nNextSkillID = 0
                -- self.m_nNextSkillID2 = 0
                if self.m_star~=nil then
                    self.m_star:setStatus(_G.Const.CONST_BATTLE_STATUS_USESKILL)
                end
                self:useSkill(49200)
                local function c()
                    self.onAnimationCompleted=self.animationFunc
                    self.showSkillAction=showSkillActionf
                    self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
                    self:setHP(math.ceil(_nHP))
                    self.m_reborning=nil
                end
                self.m_lpContainer:runAction(cc.Sequence:create(cc.DelayTime:create(1.3),cc.CallFunc:create(c)))
                return
            end
        end
    else
        local _Angle=_G.Const.CONST_BATTLE_DEAD_ANGLE
        if self.m_nScaleX>0 then
            _Angle = math.abs(_Angle)-180
        end
        self:thrust( _G.Const.CONST_BATTLE_DEAD_SPEED, _Angle , _G.Const.CONST_BATTLE_DEAD_ACCELERATION )
        self:setStatus( _G.Const.CONST_BATTLE_STATUS_CRASH)
        
        local showSkillActionf=self.showSkillAction
        self.animationFunc=self.onAnimationCompleted
        self.showSkillAction=function (  ) end
        self.onAnimationCompleted=function ( self, eventType, _animationName )
            if _animationName=="fall" then
                self.m_reborning=true
                self.m_nNextSkillID = 0
                -- self.m_nNextSkillID2 = 0
                if self.m_star~=nil then
                    self.m_star:setStatus(_G.Const.CONST_BATTLE_STATUS_USESKILL)
                end
                self:useSkill(49200)
                local function c()
                    self.onAnimationCompleted=self.animationFunc
                    self.showSkillAction=showSkillActionf
                    self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
                    self:setHP(math.ceil(_nHP))
                    self.m_reborning=nil
                end
                self.m_lpContainer:runAction(cc.Sequence:create(cc.DelayTime:create(1.3),cc.CallFunc:create(c)))
                return
            end
        end
    end
end
function CPlayer.cancelReborn( self )
    self.onAnimationCompleted=self.animationFunc
    self.animationFunc=nil
    self.m_lpContainer:stopAllActions()
end
function CPlayer.showAddHpNumber( self,_nHP,sybol )

    local leftPoint=cc.p(0,0.5)
    local tempNode=cc.Node:create()

    local tempWidth=0
    local sybolSpr=cc.Sprite:createWithSpriteFrameName(string.format("chat_attr_sybol%d.png",sybol))
    sybolSpr:setAnchorPoint(leftPoint)
    sybolSpr:setPosition(tempWidth,0)
    tempNode:addChild(sybolSpr)

    tempWidth=tempWidth+21
    _nHP=math.floor(_nHP)
    local strValue=tostring(_nHP)
    local numSprArray={}
    for i=1,string.len(strValue) do
        local num=string.sub(strValue,i,i)
        local szNum=string.format("chat_attr_num%d_%s.png",sybol,num)
        local numSpr=cc.Sprite:createWithSpriteFrameName(szNum)
        numSpr:setAnchorPoint(leftPoint)
        numSpr:setPosition(tempWidth,0)
        tempNode:addChild(numSpr)

        numSprArray[i]=numSpr
        tempWidth=tempWidth+19
    end
    numSprArray[#numSprArray+1]=attrSpr
    numSprArray[#numSprArray+1]=sybolSpr

    local endOffX=math.random(0,100)
    local endOffY=math.random(0,40)+80
    endOffX=math.random()<0.5 and -endOffX or endOffX
    endOffY=sybol==_G.Const.CONST_LOGS_DEL and -endOffY or endOffY

    local function nFun2()
        tempNode:removeFromParent(true)
    end
    local function nFun1()
        local nTimes=0.3
        for i=1,#numSprArray do
            numSprArray[i]:runAction(cc.FadeTo:create(nTimes,0))
        end
        local nOffX=endOffX*0.1
        tempNode:runAction(cc.Sequence:create(cc.ScaleTo:create(nTimes,1.5),cc.CallFunc:create(nFun2)))
        tempNode:runAction(cc.MoveBy:create(nTimes,cc.p(nOffX,0)))
    end
    local nTimes=0.6
    tempNode:runAction(cc.Sequence:create(cc.MoveBy:create(nTimes,cc.p(endOffX,endOffY)),
                                          cc.CallFunc:create(nFun1)))
    tempNode:runAction(cc.ScaleTo:create(nTimes,1.3))

    if self.m_attrContainer~=nil then
        tempNode:setPosition(-tempWidth*0.5,0)
        self.m_attrContainer:addChild(tempNode)
        return
    end

    local posX,poxY=self:getLocationXY()
    tempNode:setPosition(posX-tempWidth*0.5,poxY+100)
    _G.g_Stage.m_lpCharacterContainer:addChild(tempNode,10)
end
function CPlayer.removeVitro( self )
    for _,v in pairs(_G.CharacterManager.m_lpVitroArray) do
        if v.m_nMasterID==self.m_nID then
            self.m_stageView:removeVitro(v)
        end
    end
end
function CPlayer.dodge( self, x, y )
    if self.m_isMountBattle then return end

    if self.m_stageView.m_isCity or self.m_rollIngFun~=nil
        or self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_FROZEN) 
        or self:isHaveBuff(_G.Const.CONST_BATTLE_BUFF_DIZZY)
        or self.m_nSkillID==self.m_bigSkillId
        or (self.m_nSkillID==self.m_property:getMountID() and self.m_nSkillID~=0)
        or self:getSP()<_G.Const.CONST_WAR_ROLL_MP
          then
        return
    end
    local canDodge
    if self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_USESKILL then
        self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE)
        if x>0 then
            self:setMoveClipContainerScalex(1)
        else
            self:setMoveClipContainerScalex(-1)
        end
        -- self:setStatus(_G.Const.CONST_BATTLE_STATUS_USESKILL)
        canDodge=true
    elseif self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_IDLE then
        if x>0 then
            self:setMoveClipContainerScalex(1)
        else
            self:setMoveClipContainerScalex(-1)
        end
        -- self:setStatus(_G.Const.CONST_BATTLE_STATUS_USESKILL)
        canDodge=true
    end
    if canDodge==true then
        self:useSkill(10900+1000*self.m_nPro)
        self.m_stageView.joyCdTimes=_G.TimeUtil:getTotalMilliseconds()
    end
    -- if self.m_nStatus==_G.Const.CONST_BATTLE_STATUS_USESKILL then
    --     self.m_rollIngFun=self.setStatus
    --     self.setStatus=function (  )end
    --     self:addSP(-_G.Const.CONST_WAR_ROLL_MP)
    --     self.m_lpMovieClip:setAnimation(0,"roll",false)
    --     local skinRoll=string.format("spine/%d_roll",self.m_SkinId)
    --     --闪避声音
    --     _G.Util:playAudioEffect(string.format("1%d004",self.m_nPro))
    --     self.m_lpRollMovieClip=_G.SpineManager.createSpine(skinRoll,self.m_skinScale*2)
    --     self.m_lpRollMovieClip:setAnimation(0,"idle",false)
    --     self.m_lpMovieClip:addChild(self.m_lpRollMovieClip)
    --     self.m_noBeTarget=true
    --     self:Translation(_G.Const.CONST_WAR_ROLL_SPEED,_G.Const.CONST_WAR_ROLL_X,0)
    --     self.m_nSkillID=9918
    --     self.m_nSkillDuration = 0
    --     self.m_skillIndex = 1
    --     self.m_cutTime=0
    -- end
end
-- function CPlayer.cancelDodge(self)
--     if self.m_rollIngFun~=nil then
--         self:onAnimationCompleted(_,"roll")
--     end
-- end
function CPlayer.quickDead( self )
    if self.m_stageView.m_isCity then return end
    self.m_isCorpse=true
    self.m_noBeTarget=true
    self.m_nHP=0
    self.m_lpBigHp:setHpValue(0, self.m_nMaxHP, true)
    self:setStatus(_G.Const.CONST_BATTLE_STATUS_DEAD)
end
function CPlayer.changeBody( self )
    -- self:setStatus(_G.Const.con)
    local function c(  )
        if self.m_changeSkin==0 or self.m_changeSkin==nil then return end
        self.m_lpMovieClip:removeFromParent(false)
        self:showBody(self.m_changeSkin)
        self:setStatus(_G.Const.CONST_BATTLE_STATUS_IDLE,true)
        self:resetNamePos()
        self.m_stageView.m_keyBoard:changeSkillButton(self.m_SkinId,self.m_changeSkin)
        local skinId=self.m_SkinId
        self.m_SkinId=self.m_changeSkin
        self.m_changeSkin=skinId
        self.m_AttackSkillIds=nil
    end
    performWithDelay(self.m_lpContainer,c,0.1)
end


function CPlayer.chuangToMountBattle(self)
    if self.m_isMountBattle then return end

    if not self.m_mountPlayerMovieClip then
        local function onCallFunc(event)
            self:animationCallFunc(event.type,event.animation,event)
        end

        local szName=string.format("spine/%d",(self.m_SkinId%10)*1000+10030)
        self.m_mountPlayerMovieClip=_G.SpineManager.createSpine(szName,self.m_skinScale)
        if not self.m_mountPlayerMovieClip then
            return
        end
        
        self.m_lpCharacterContainer:addChild(self.m_mountPlayerMovieClip)

        szName=string.format("spine/%d",self.m_mountSkinId)
        local nScale=_G.g_SkillDataManager:getSkinData(self.m_mountSkinId).scale*0.0001
        local mountData=_G.Cfg.mount_pos[self.m_SkinId][self.m_mountSkinId]
        self.m_mountMovieClip=_G.SpineManager.createSpine(szName,nScale)
        self.m_mountMovieClip:registerSpineEventHandler(onCallFunc,2)
        self.m_mountMovieClip:registerSpineEventHandler(onCallFunc,3)
        self.m_lpCharacterContainer:addChild(self.m_mountMovieClip,mountData.zorder)
    else
        self.m_mountPlayerMovieClip:setVisible(true)
        self.m_mountMovieClip:setVisible(true)

        _G.ShaderUtil:resetSpineShader(self.m_mountPlayerMovieClip)
        _G.ShaderUtil:resetSpineShader(self.m_mountMovieClip)

        self.m_mountPlayerMovieClip:setColor(cc.c3b(255,255,255))
        self.m_mountMovieClip:setColor(cc.c3b(255,255,255))
    end

    _G.Util:playAudioEffect("4800")

    local mountData=_G.Cfg.mount_pos[self.m_SkinId][self.m_mountSkinId]
    self.m_mountHeight=mountData.height
    self:resetNamePos()

    self.m_mainPlayerMovieClip=self.m_lpMovieClip
    self.m_lpMovieClip=self.m_mountPlayerMovieClip

    self.m_mainPlayerMovieClip:setVisible(false)

    self.m_nNextSkillID=0
    self.m_nNextSkillID2=0
    self.m_nNextSkillID3=0

    self.m_isMountBattle=true
    self.m_isMountBattleEnd=false
    self:setStatus(self.m_nStatus,true)

    -- AI
    self.m_attackSkillDatas=nil
    if self.m_nAI and self.m_nAI>0 then
        self:enableAI(true)
    end

    local buffId=_G.Cfg.mount_battle[self.m_mountSkinId].buff
    local invBuff=_G.GBuffManager:getBuffNewObject(buffId,0)
    self:addBuff(invBuff)

    print("chuangToMountBattle========>>>>>")
end
function CPlayer.chuangeToPlayerBattle(self,_isReborn)
    if not self.m_isMountBattle then return end

    if not _isReborn and self:getHP()<=0 then
        return
    end

    if self.m_mountPlayerMovieClip then
        self.m_mountPlayerMovieClip:setVisible(false)
    end
    if self.m_mountMovieClip then
        self.m_mountMovieClip:setVisible(false)
    end

    self.m_lpMovieClip=self.m_mainPlayerMovieClip
    self.m_lpMovieClip:setVisible(true)

    self.m_mountHeight=0
    self:resetNamePos()

    _G.ShaderUtil:resetSpineShader(self.m_lpMovieClip)
    self.m_lpMovieClip:setColor(cc.c3b(255,255,255))

    self.m_nNextSkillID=0
    self.m_nNextSkillID2=0
    self.m_nNextSkillID3=0

    self.m_isMountBattle=false
    self.m_isMountBattleEnd=false
    self:setStatus(self.m_nStatus,true)

    -- AI
    self.m_attackSkillDatas=nil
    self.m_preAi=nil
    if self.m_nAI and self.m_nAI>0 then
        self:enableAI(true)
    end

    -- self:removeBuff(_G.Const.CONST_BATTLE_BUFF_ENDUCE)
    self:removeAllBuff()

    print("chuangeToPlayerBattle========>>>>>")
end