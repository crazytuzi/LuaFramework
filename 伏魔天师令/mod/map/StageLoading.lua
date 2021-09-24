local LoadingScene = classGc(function(self)
    self:loadResources()
end)

function LoadingScene.onEnterTransitionFinish(self)
    if self.isComeFromSelectServerScene then
        ScenesManger.releaseLoginResource()
    else
        local lastFileList=Cfg.ResList.GetList(self.m_lastResourceId)
        for _,fileName in pairs(lastFileList) do
            ScenesManger.releaseFile(fileName)
        end
    end

    -- self:retainRes()

    -- unbindAllImageAsync
    local nSpineMan=_G.SpineManager
    nSpineMan.releaseAllSpine(self.m_skeletonDataList)
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    print("资源清理完毕~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    -- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo().."\n")

    -- print("需要加载的图片资源:")
    -- for k,v in pairs(self.m_loadFileArray) do
    --     print("file====> "..k)
    -- end
    -- print(".........\n")

    -- print("需要加载的骨骼:")
    -- for k,v in pairs(self.m_skeletonDataList) do
    --     print("skeleton==> "..k)
    -- end
    -- print(".........\n")

    -- print("预加载骨骼==========>>>>>>>")
    -- for skeName,scale in pairs(self.m_skeletonDataList) do
    --     nSpineMan.addSpineCache(skeName)
    -- end
end

function LoadingScene.show(self)
    ScenesManger.isLoading=true
    ScenesManger.subResList={}

    -- self.resType=ScenesManger.sceneResType
    
    -- LoadResScene.showLoading(self)
    self.m_extraLoadCount=0

    local function fun()
        self:update()
    end
    self.m_schedule=_G.Scheduler:schedule(fun,0,false)

    print("资源加载完毕~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    -- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo().."\n")
end

function LoadingScene.update(self)
    -- local key,ccbiName = next(self.m_characterFileList)

    print("LoadingScene.update==========>>>")

    if self.hasRun==nil then  -- ccbiName~=nil then
        self.hasRun=true

        LoadResScene.loadingScene:setPercent(100)
    else

        self.m_extraLoadCount=self.m_extraLoadCount+1
        if self.enterSceneData==nil then
            self.enterSceneData={}
            self.enterSceneData.mbg=self.m_sceneMbg
            _G.g_Stage:getStageMediator():finishGotScene(self.enterSceneData)
        elseif self.m_extraLoadCount>5 then
            _G.Scheduler:unschedule(self.m_schedule)

            ScenesManger.isLoading=nil
            LoadResScene.hideLoading(self)

            _G.g_Stage:getStageMediator():enterStageScene(self.enterSceneData)
            self:releaseRes()
        end
    end
end

function LoadingScene.retainRes(self)
    local loadPicArray={}
    for fileName,v in pairs(self.m_loadFileArray) do
        local searchPng=string.find(fileName,[[.png]])
        local searchJpn=string.find(fileName,[[.jpg]])
        if searchPng or searchJpn then
            loadPicArray[fileName]=fileName
        end
    end
    for fileName,v in pairs(self.m_skeletonDataList) do
        loadPicArray[fileName..".png"]=fileName
    end
    for fileName,v in pairs(self.m_gafFileList) do
        loadPicArray[string.gsub(fileName,".gaf",".png")]=fileName
    end

    self.m_retainArray={}
    local tCache=cc.Director:getInstance():getTextureCache()
    for resName,fileName in pairs(loadPicArray) do
        local r=tCache:getTextureForKey(resName)
        if r then
            r:retain()
            self.m_retainArray[fileName]=resName
            print("PPPPPPPPPPPPPPP=======>>>>>",resName)
        end
    end
end
function LoadingScene.releaseRes(self)
    if not self.m_retainArray then return end

    local tCache=cc.Director:getInstance():getTextureCache()
    for _,resName in pairs(self.m_retainArray) do
        local r=tCache:getTextureForKey(resName)
        if r then
            r:release()
            -- print("PPPPPPPPPPPPPPP=======>>>>>",resName)
        else
            print("lua error...., LoadingScene.releaseRes, resName",resName)
        end
    end
end

function LoadingScene.loadResources(self)
    self.sceneData=_G.g_Stage:getStageMediator().sceneData
    self.lastScenesData=_G.g_Stage:getStageMediator().lastScenesData
    CCLOG("LoadingScene.loadMapResources  self.m_nMapID=%d",self.sceneData.material_id)

    local mapData=_G.MapData[self.sceneData.material_id]
    local fileList={}
    self.m_characterFileList={}
    self.m_skeletonDataList={}
    self.m_gafFileList={}
    self.m_saveResList={}

    local nCount=#self.sceneData.mbg
    local nIndex=math.floor((gc.MathGc:random_0_1()*nCount+1))
    local nextMbg=self.sceneData.mbg[nIndex]
    if nextMbg~=nil and nextMbg~=0 then
        if _G.GSystemProxy:isBgMusicOpen() then
            _G.Util:preloadBgMusic(nextMbg)
        else
            _G.Util:releasePreBgMusic()
        end
        self.m_sceneMbg=nextMbg
    end

    self:getMapResList(mapData,fileList,self.m_skeletonDataList)


    -- print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo().."\n")
    _G.g_Stage:releaseCharacterResource()

    --进入城市
    if self.sceneData.scene_type==1 then
        print("切换到城市==========================================================================>>>>")
        _G.SpineManager.resetPreCityRes(self.m_skeletonDataList)
        self.m_resourceId=Cfg.UI_StageResources
        self.m_lastResourceId=Cfg.UI_BattleStageResources
        self:getNPCResList(self.sceneData,self.m_skeletonDataList)

        --城市切换城市
        if self.lastScenesData.lastScenesType==1 then
            self:getStageTypeRes(self.m_resourceId,self.m_saveResList)
        end
    else
        print("切换到战斗==========================================================================>>>>")
        self.m_resourceId=Cfg.UI_BattleStageResources
        self.m_lastResourceId=Cfg.UI_StageResources

        local roleSkinId=nil
        local roleProperty=_G.GPropertyProxy:getMainPlay()
        local isLoadSceneMonster=nil

        if self.sceneData.scene_type==_G.Const.CONST_MAP_CLAN_DEFENSE then
            print("门派守卫,资源注册加载。。。。")
            local file = "ui/ui_clan.plist"
            local swcnf= "defense_sproperty_cnf"
            fileList[file]=file
            fileList[swcnf]=swcnf

        elseif self.sceneData.scene_type==_G.Const.CONST_MAP_TYPE_CHALLENGEPANEL then
            if self.sceneData.scene_id == _G.Const.CONST_ARENA_JJC_WARLORDS_ID then
                local file = "grade_up_cnf"
                fileList[file]=file
            end
            local pkPlayInfo=_G.GPropertyProxy:getChallengePanePlayInfo()
            self:getPlayerBattleResList(roleProperty,self.m_characterFileList,self.m_skeletonDataList)
            self:getPlayerBattleResList(pkPlayInfo,self.m_characterFileList,self.m_skeletonDataList)
            self.m_skeletonDataList["spine/shengli"]=true

        elseif self.sceneData.scene_type==_G.Const.CONST_MAP_TYPE_BOSS or
            self.sceneData.scene_type==_G.Const.CONST_MAP_TYPE_CLAN_BOSS or
            self.sceneData.scene_type==_G.Const.CONST_MAP_CLAN_WAR then

            local skinIDs = {10001,10002}
            for i=1,#skinIDs do
                self:getPlayerAllResList(self.m_characterFileList,skinIDs[i],self.m_skeletonDataList,true)
            end
            -- fileList["UI/WorldBoss.plist"]="UI/WorldBoss.plist"

        elseif self.sceneData.scene_type==_G.Const.CONST_MAP_TYPE_CITY_BOSS then
            local skinIDs = {10001,10002}
            for i=1,#skinIDs do
                self:getPlayerAllResList(self.m_characterFileList,skinIDs[i],self.m_skeletonDataList,true)
            end
            isLoadSceneMonster=true

        elseif self.sceneData.scene_type==_G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
            local mediator = _G.g_Stage:getStageMediator()
            if mediator.m_playerResLoadDatas~=nil and #mediator.m_playerResLoadDatas.msg_skins>0 then
                -- print("self.sceneData.scene_type==_G.Const.CONST_MAP_TYPE_COPY_MULTIPLAYER")
                local collectskinIds = {}
                local collectSkillIds = {}

                for _,v in pairs(mediator.m_playerResLoadDatas.msg_skins) do
                    collectskinIds[v.skin]=v.skin
                    local skillInitData = _G.Cfg.player_init[v.skin%10]
                    for _,sv in pairs(v.msg_skills) do
                        if skillInitData.big_skill~=sv.skill_id then
                            collectSkillIds[sv.skill_id]=sv.skill_id
                        end
                    end
                end

                for _,skinId in pairs(collectskinIds) do
                    self:getPlayerBaseResList(self.m_characterFileList,skinId)
                end
                for _,skillId in pairs(collectSkillIds) do
                    self:getSkillResArray(skillId,self.m_characterFileList,self.m_skeletonDataList)
                end
            end

            isLoadSceneMonster=true
            self.m_skeletonDataList["spine/boss"]=true
            self.m_skeletonDataList["spine/shengli"]=true

            -- print("==========================================================================>>>>5")

        elseif self.sceneData.scene_type==_G.Const.CONST_MAP_TYPE_KOF then
            self:getPlayerBattleResList(roleProperty,self.m_characterFileList,self.m_skeletonDataList)
            self.m_skeletonDataList["spine/shengli"]=true
            -- fileList["Icon/drop_icon.plist"]=nil
            -- fileList["anim/take_pill_effect.plist"]=nil
            -- print("==========================================================================>>>>6")
        
        elseif self.sceneData.scene_type==_G.Const.CONST_MAP_TYPE_THOUSAND then
            --3个角色以及他们前三个技能
            local file = "thousand_role_cnf" 
            local swcnf= "thousand_jifen_cnf"
            fileList[file]=file
            fileList[swcnf]=swcnf
            local skinIDs = {10001,10002}
            for _,skinId in ipairs(skinIDs) do
                self:getPlayerAllResList(self.m_characterFileList,skinId,self.m_skeletonDataList)
            end
            --选中的3个技能加载
            local mediator = _G.g_Stage:getStageMediator()
            if mediator.m_playerResLoadDatas~=nil and #mediator.m_playerResLoadDatas.msg_skins>0 then
                local m_data = mediator.m_playerResLoadDatas.msg_skins[1]
                _G.g_Stage:setIkkiTousenWarData(m_data)
                if m_data ~=nil and  m_data.msg_skills ~= nil then
                    for k,_v in pairs(m_data.msg_skills) do
                        print("~~skill_id==",_v.skill_id)
                        self:getSkillResArray(_v.skill_id,self.m_characterFileList,self.m_skeletonDataList)
                    end
                end
            end
            print("一骑当千技能加载完毕~~~")
        elseif self.sceneData.scene_type==_G.Const.CONST_MAP_TYPE_COPY_BOX then
            local mibaoArrayCnf=_G.Cfg.mibao
            local curMibaoCnf=nil
            for i=1,#mibaoArrayCnf do
                local sceneArray=mibaoArrayCnf[i].map_ids
                for j=1,#sceneArray do
                    if sceneArray[j]==self.sceneData.scene_id then
                        curMibaoCnf=mibaoArrayCnf[i]
                    end
                end
            end
            local resName="icon/dropicon.plist"
            local cnfName="icon_drop_cnf"
            fileList[resName]=resName
            fileList[cnfName]=cnfName
            if curMibaoCnf then
                local fileName=string.format("spine/%d",curMibaoCnf.skin_id)
                self.m_characterFileList[fileName..".png"]=fileName
                self.m_skeletonDataList[fileName]=fileName
            end
            local skinIDs = {10001,10002}
            for i=1,#skinIDs do
                self:getPlayerAllResList(self.m_characterFileList,skinIDs[i],self.m_skeletonDataList,true)
            end
        elseif self.sceneData.scene_type==_G.Const.CONST_MAP_TYPE_PK_LY then
            fileList["ui/battle_lingyao.plist"]="ui/battle_lingyao.plist"
            fileList["ui/ui_partner.plist"]="ui/ui_partner.plist"
            self:loadAllLingYaoResList(self.m_characterFileList,self.m_skeletonDataList)
        else
            if self.sceneData.scene_id==_G.Const.CONST_COPY_FIRST_COPY then
                -- 新手副本
                local myPro=_G.GPropertyProxy:getMainPlay():getPro()
                local skillArray=_G.Cfg.firstGameUseSkill[myPro]
                if skillArray then
                    -- 普通技能
                    for i=1,#skillArray do
                        self:getSkillResArray(skillArray[i],self.m_characterFileList,self.m_skeletonDataList)
                    end
                    -- 坐骑技能
                    self:getSkillResArray(_G.Cfg.firstGameUseSkill.mount_skill,self.m_characterFileList,self.m_skeletonDataList)
                end
                -- 大招
                self:getSkillResArray(_G.Cfg.player_init[myPro].big_skill,self.m_characterFileList,self.m_skeletonDataList)
            end
            self:getPlayerBattleResList(roleProperty,self.m_characterFileList,self.m_skeletonDataList,true)
  
            isLoadSceneMonster=true
            self.m_skeletonDataList["spine/boss"]=true
            self.m_skeletonDataList["spine/shengli"]=true
            -- print("==========================================================================>>>>7")
        end

        if mapData.id==10402 then
            self.m_skeletonDataList["map/10402_tsp_02"]=true
        end

        if isLoadSceneMonster then
            self:getAllMonsterResList(self.m_characterFileList,self.m_skeletonDataList,self.sceneData.scene_id)

            -- if self.sceneData.box~=nil and type(self.sceneData.box)=="table" then
            --     local boxIds = {}
            --     for _,boxData in pairs(self.sceneData.box) do
            --         if boxData.id~=nil and boxData.id~=0 then
            --             if _G.Cfg.goods_box~=nil and _G.Cfg.goods_box[boxData.id]~=nil then
            --                 local boxId = _G.Cfg.goods_box[boxData.id].goods_icon
            --                 boxIds[boxId]=boxId
            --             end
            --         end
            --     end

            --     for _,boxId in pairs(boxIds) do
            --         local plistName = "anim/"..boxId.."_idle.plist"
            --         fileList[plistName]=plistName
            --     end
            -- end
        end

        --城市切换战斗
        if self.lastScenesData.lastScenesType~=1 and self.lastScenesData.lastScenesType~=nil then
            self:getStageTypeRes(self.m_resourceId,self.m_saveResList)
        end
    end

    for k,v in pairs(self.m_characterFileList) do
        fileList[k]=v
    end
    for k,v in pairs(self.m_saveResList) do
        fileList[k]=nil
    end

    print("【需要带到下个场景的资源】=========>>>>>>>>")
    for k,v in pairs(self.m_saveResList) do
        print("=====>>",k)
    end
    print(".............")

    if ScenesManger.currentSceneId==Cfg.UI_SelectSeverScene then
        self.isComeFromSelectServerScene=true
    end

    self.m_loadFileArray=fileList

    self:retainRes()
    local newSpineArray={}
    local newSpineCount=0
    for szName,nScale in pairs(self.m_skeletonDataList) do
        if not self.m_retainArray[szName] then
            newSpineCount=newSpineCount+1
            newSpineArray[newSpineCount]=szName
        end
    end

    local newGafArray={}
    local newGafCount=0
    for fileName,v in pairs(self.m_gafFileList) do
        newGafCount=newGafCount+1
        newGafArray[newGafCount]={isSkill=v,fileName=fileName}
    end

    local function onDelayLoadScene()
        ScenesManger.loadScene(self,self.m_resourceId,fileList,ScenesManger.sceneResType,nil,newSpineArray,newGafArray)
    end
    _G.Scheduler:performWithDelay(0.01, onDelayLoadScene)
    _G.g_Stage.m_finallyInitialize=nil
end

function LoadingScene.getMapResList(self,mapData,fileList,skeletonList)
    if mapData==nil or mapData.data==nil then return end

    local tempArray=_G.Cfg.mapSpinePngNameArray
    if mapData.data.topside~=nil then
        for _,v in pairs(mapData.data.topside) do
            if v.type==[[spine]] then
                local skeletonName=string.format("map/%s",v.name)
                skeletonList[skeletonName]=true
                tempArray[skeletonName..".png"]=true
            elseif v.type==[[gaf]] then
                local fileName=string.format("map/%s.gaf",v.name)
                self.m_gafFileList[fileName]=false
                tempArray[string.format("map/%s.png",v.name)]=true
            end
        end
    end
    if mapData.data.before~=nil then
        for _,v in pairs(mapData.data.before) do
            if v.type==[[spine]] then
                local skeletonName=string.format("map/%s",v.name)
                skeletonList[skeletonName]=true
                tempArray[skeletonName..".png"]=true
            elseif v.type==[[gaf]] then
                local fileName=string.format("map/%s.gaf",v.name)
                self.m_gafFileList[fileName]=false
                tempArray[string.format("map/%s.png",v.name)]=true
            end
        end
    end
    if mapData.data.map~=nil then
        for _,v in pairs(mapData.data.map) do
            if v.type==[[png]] or v.type==[[jpg]] then
                local path="map/"..v.name.."."..v.type
                fileList[path]=path
            elseif v.type==[[spine]] then
                local skeletonName=string.format("map/%s",v.name)
                skeletonList[skeletonName]=true
                tempArray[skeletonName..".png"]=true
            elseif v.type==[[gaf]] then
                local fileName=string.format("map/%s.gaf",v.name)
                self.m_gafFileList[fileName]=false
                tempArray[string.format("map/%s.png",v.name)]=true
            end
        end
    end
    if mapData.data.bg~=nil then
        for _,v in pairs(mapData.data.bg) do
            if v.type==[[png]] or v.type==[[jpg]] then
                local path="map/"..v.name.."."..v.type
                fileList[path]=path
            elseif v.type==[[spine]] then
                local skeletonName=string.format("map/%s",v.name)
                skeletonList[skeletonName]=true
                tempArray[skeletonName..".png"]=true
            elseif v.type==[[gaf]] then
                local fileName=string.format("map/%s.gaf",v.name)
                self.m_gafFileList[fileName]=false
                tempArray[string.format("map/%s.png",v.name)]=true
            end
        end
    end

    tempArray["map/10402_bf_02.png"]=nil
end

function LoadingScene.getNPCResList(self,sceneData,skeletonList)
    for _,v in pairs(sceneData.npc) do
        local npcData=_G.Cfg.scene_npc[v.npc_id]
        if npcData~=nil then
            local skeletonName=string.format("spine/%d",npcData.skin)
            skeletonList[skeletonName]=true
        end
    end
end

function LoadingScene.getPlayerBaseResList(self,fileList,skinId)
    local fileList =fileList or {}
    local skillIdToId = nil
    if skinId~=nil and skinId>0 then
        local fileName=string.format("spine/%d.png",skinId)
        fileList[fileName]=fileName
    end
    return fileList
end

function LoadingScene.getPlayerAllResList(self,fileList,skinId,skeletonList,isUseNormalSkill,loadBigSkill)
    local fileList =fileList or {}
    local skillIdToId = nil
    if skinId~=nil and skinId>0 then
        local fileName=string.format("spine/%d.png",skinId)
        fileList[fileName]=fileName

        local skillInitData = _G.Cfg.player_init[skinId%10]
        for _,skillId in ipairs(skillInitData.skill_none) do
            self:getSkillResArray(skillId,fileList,skeletonList)
        end
        if isUseNormalSkill then
            for i=1,4 do
                local skillId=skillInitData.skill_learn[i]
                self:getSkillResArray(skillId,fileList,skeletonList)
            end
            if loadBigSkill then
                self:getSkillResArray(skillInitData.big_skill,fileList,skeletonList)
            end
        end
    end
    return fileList
end

function LoadingScene.getAllMonsterResList(self,fileList,skeletonList,sceneId)
    local monsterIdsList={}
    local monsterIdCount=0
    local checkPoints=_G.StageXMLManager:getXMLScenesCheckpointList(sceneId)
    if checkPoints~=nil then
        for _,checkPoint in pairs(checkPoints) do
            for _,oneMonster in pairs(checkPoint.monster) do
                local monsterData=_G.Cfg.scene_monster[oneMonster[1]]
                local skin = monsterData.skin
                local skinData = _G.g_SkillDataManager:getSkinData(skin)
                if monsterData~=nil and skinData~=nil then
                    monsterIdCount=monsterIdCount+1
                    monsterIdsList[monsterIdCount]=oneMonster[1]
                    local skeletonName=string.format("spine/%d",monsterData.skin)
                    skeletonList[skeletonName]=true

                    local skillArray=_G.g_CnfDataManager:getAISkillArray(monsterData.ai)
                    for skillId,_ in pairs(skillArray) do
                        self:getSkillResArray(skillId,fileList,skeletonList)
                    end
                end
            end
        end
    end
    return fileList
end

-- function LoadingScene.getMonsterResArray(self,monsterId,fileList,skeletonList)
--     local monsterData=_G.Cfg.scene_monster[monsterId]
--     if monsterData~=nil and monsterData.skill~=nil then
--         for i=1,#monsterData.skill do
--             local skillId=monsterData.skill[i].id
--             self:getSkillResArray(skillId,fileList,skeletonList)
--         end
--     end
-- end
function LoadingScene.getSkillResArray(self,skillId,fileList,skeletonList)
    local effectIdArray1,effectIdArray2=_G.g_SkillDataManager:getSkillEffectIdArray(skillId)
    for effectId,_ in pairs(effectIdArray1) do
        local skeletonName=string.format("spine/%d",effectId)
        skeletonList[skeletonName]=true
    end
    for effectId,_ in pairs(effectIdArray2) do
        -- local fileName=string.format("gaf/%d.png",effectId)
        -- fileList[fileName]=fileName
        local fileName=string.format("gaf/%d.gaf",effectId)
        self.m_gafFileList[fileName]=true
    end
end

function LoadingScene.getPlayerBattleResList(self,roleProperty,playerFileList,skeletonList,loadBigSkill)
    if roleProperty==nil then return end

    local skillIds={}
    local skillCount=0
    roleSkinId=roleProperty:getSkinArmor()
    if roleSkinId==nil then return end

    if roleSkinId~=0 then
        local sKillInitData =_G.g_SkillDataManager:getSkillInitData(roleSkinId)
        if sKillInitData~=nil then
            -- 普通技能
            for _,skillId in pairs(sKillInitData.skill_none) do
                skillCount=skillCount+1
                skillIds[skillCount]=skillId
            end
        end
    end

    local skillData=roleProperty:getSkillData()
    if skillData~=nil then
        skillData.skill_equip_list=skillData.skill_equip_list or {}
        for _,skill_equip in pairs(skillData.skill_equip_list) do
            local selectSkillId = skill_equip.skill_id
            if selectSkillId~=nil and selectSkillId>0 then
                if skill_equip.equip_pos<5 then
                    skillCount=skillCount+1
                    skillIds[skillCount]=selectSkillId
                elseif skill_equip.equip_pos==5 and loadBigSkill then
                    skillCount=skillCount+1
                    skillIds[skillCount]=selectSkillId
                end
            end
        end
    end

    for i=1,skillCount do
        local skillId=skillIds[i]
        self:getSkillResArray(skillId,playerFileList,skeletonList)
    end

    -- local roleSpine=string.format("spine/%d.png",roleSkinId)
    -- playerFileList[roleSpine]=roleSpine
end

function LoadingScene.getStageTypeRes(self,_resType,_fileList)
    local resArray=_G.Cfg.ResList.GetList(_resType)
    for _,fileName in pairs(resArray) do
        local searchLua=string.find(fileName,[[_cnf]])
        if not searchLua then
            _fileList[fileName]=fileName
        end
    end
end

function LoadingScene.loadAllLingYaoResList(self,fileList,skeletonList)
    local lyData=_G.g_lingYaoPkData
    if not lyData then return end

    local idArray={}
    for i=1,#lyData.lingyao_data do
        local tempId=lyData.lingyao_data[i].id
        idArray[tempId]=true
    end
    for i=1,#lyData.lingyao_data2 do
        local tempId=lyData.lingyao_data2[i].id
        idArray[tempId]=true
    end

    for lyId,_ in pairs(idArray) do
        local tempCnf=_G.Cfg.partner_init[lyId]
        if tempCnf then
            local szName=string.format("spine/%d",tempCnf.skin)
            skeletonList[szName]=true

            for i=1,#tempCnf.all_skill do
                local skillId=tempCnf.all_skill[i][1]
                if skillId and skillId>0 then
                    self:getSkillResArray(skillId,fileList,skeletonList)
                end
            end
        end
    end
end

return LoadingScene
