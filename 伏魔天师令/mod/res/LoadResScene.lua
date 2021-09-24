local szCnfDir=_G.SysInfo:getDirCnf()
local __insDirector=cc.Director:getInstance()
local WINSIZE=__insDirector:getWinSize()

-- *************** LoadingScene START ***************
local LoadingScene=classGc()
function LoadingScene.__init(self)
    print("LoadingScene.__init--->>> start")
    self.m_container=cc.Node:create()
    self.m_container:retain()

    local loadNode=cc.Node:create()
    self.m_container:addChild(loadNode)

    _G.SysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)
    local bgSpr=cc.Sprite:create("ui/bg/bg_loading.jpg")
    bgSpr:setAnchorPoint(cc.p(1,0.5))
    bgSpr:setPosition(WINSIZE.width,WINSIZE.height*0.5)
    loadNode:addChild(bgSpr)
    _G.SysInfo:resetTextureFormat()

    local loadingSpr=cc.Sprite:createWithSpriteFrameName("general_loading_1.png")
    local loadSprSize=loadingSpr:getContentSize()
    loadingSpr:setAnchorPoint(cc.p(0,0))
    loadNode:addChild(loadingSpr)
    self.m_loadingSpr=loadingSpr
    self.m_percentScale=WINSIZE.width/loadSprSize.width*0.01
    self.m_loadSprSize=loadSprSize

    self.m_loadEffect=cc.Sprite:create()
    self.m_loadEffect:runAction(cc.RepeatForever:create(_G.AnimationUtil:createAnimateAction("anim/effect_load.plist","effect_load_",0.1)))
    loadNode:addChild(self.m_loadEffect,5)

    self.m_contentLabel=_G.Util:createBorderLabel("",20)
    self.m_contentLabel:setAnchorPoint(cc.p(0.5,0))
    self.m_contentLabel:setPosition(WINSIZE.width*0.5,loadSprSize.height+5)
    loadNode:addChild(self.m_contentLabel)

    self.m_updateTime=0
end
function LoadingScene.setString(self,showStr)
    self.m_contentLabel:setString(showStr)
end
function LoadingScene.setPercent(self,percent)
    percent=percent<=0 and 0.1 or percent
    self.m_loadingSpr:setScaleX(self.m_percentScale*percent)
    self.m_loadEffect:setPosition((WINSIZE.width-40)*percent*0.01+20,self.m_loadSprSize.height*0.5)
end

-- do
--     require(szCnfDir.."/unzip_desc_cnf")
--     local unzipDesc=_G.Cfg.unzip_desc[1]
--     table.remove(unzipDesc,1)
--     _G.Cfg.unzip_desc=nil
--     function LoadingScene.setPercent(self,percent)
--         self.m_loadingBar:setPercent(percent)
--         local curTime=_G.TimeUtil:getTotalSeconds()
--         if curTime-self.m_updateTime>1 then
--             math.randomseed(curTime)
--             local randomIndex=math.random(1,#unzipDesc)
--             self.m_punZipLabel:setString(tostring(unzipDesc[randomIndex]))
--         end
--     end
-- end
-- *************** LoadingScene END ***************

-- *************** LoadingCircle START ***************
local LoadingCircle={}
function LoadingCircle.__init(self)
    self.m_container=cc.Node:create()
    self.m_container:setPosition(WINSIZE.width*0.5,WINSIZE.height*0.5)
    self.m_container:retain()

    local circle=cc.Sprite:createWithSpriteFrameName("general_loading.png")
    self.m_container:addChild(circle)
    local rotaBy=cc.RotateBy:create(1,360)
    circle:runAction(cc.RepeatForever:create(rotaBy))

    -- self.m_contentLabel=_G.Util:createLabel("",20)
    -- self.m_contentLabel:setPosition(0,-50)
    -- self.m_container:addChild(self.m_contentLabel)
end
-- function LoadingCircle.setString(self,showStr)
--     self.m_contentLabel:setString(showStr)
-- end
-- *************** LoadingCircle END ***************

LoadResScene=classGc(function(self,sceneId,resType,fileList,showUI,spineList,gafList)
    self.m_sceneId=sceneId
    self.m_resType=resType
    self.m_fileList=fileList
    self.m_showUI=showUI
    self.m_spineList=spineList or {}
    self.m_spineCount=#self.m_spineList
    self.m_gafList=gafList or {}
    self.m_gafCount=#self.m_gafList

    self:showLoading()
end)
function LoadResScene.showLoading(self)
    -- print("LoadResScene.showLoading--->>> start",debug.traceback())
    __insDirector:getEventDispatcher():setEnabled(false)
    if self.m_resType==ScenesManger.sceneResType then
        if LoadResScene.loadingScene==nil then
            LoadResScene.loadingScene=LoadingScene()
            LoadResScene.loadingScene:__init()
        end
        self.loadingLayer=LoadResScene.loadingScene
        self.loadingLayer.m_container:removeFromParent(false)

        -- self.loadingLayer=LoadingScene()
        -- self.loadingLayer:__init()
        -- LoadResScene.loadingScene=self.loadingLayer

        local function nFun()
            local currentSceneView=ScenesManger.currentSceneObj
            if currentSceneView~=nil and currentSceneView.onEnterTransitionFinish then
                currentSceneView:onEnterTransitionFinish()
            end

            _G.SysInfo:setGameIntervalLow()
            _G.StageObjectPool:init()
            self:load()
        end

        local scene=cc.Scene:create()
        scene:addChild(self.loadingLayer.m_container)
        __insDirector:popToRootScene()
        __insDirector:replaceScene(scene)
        self.loadingLayer:setPercent(0)

        local descArray=_G.Cfg.unzip_desc[1]
        local szContent=descArray[math.ceil(gc.MathGc:random_0_1()*#descArray)]
        self.loadingLayer:setString(szContent)

        if _G.g_Stage then
            _G.g_Stage.isRelease=true
        end

        scene:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(nFun)))
    elseif self.m_resType==ScenesManger.layerResType then
        if LoadResScene.loadingCircle==nil then
            LoadResScene.loadingCircle=LoadingCircle
            LoadResScene.loadingCircle:__init()
        end
        
        self.loadingLayer=LoadResScene.loadingCircle
        self.loadingLayer.m_container:stopAllActions()
        self.loadingLayer.m_container:removeFromParent(false)

        local runningScene=__insDirector:getRunningScene()
        runningScene:addChild(self.loadingLayer.m_container,1000,168888)
        self.loadingLayer.m_container:setVisible(false)

        local delTime=cc.DelayTime:create(0.8)
        local show=cc.Show:create()
        self.loadingLayer.m_container:runAction(cc.Sequence:create(delTime,show))

        self:load()
    end
end
function LoadResScene.hideLoading(self)
    print("LoadResScene.showLoading--->>> end")
    if self.m_resType==ScenesManger.layerResType then
        self.loadingLayer.m_container:removeFromParent(false)
    -- else
        -- __insDirector:popScene()
    end
    __insDirector:getEventDispatcher():setEnabled(true)
end
function LoadResScene.load(self)
    print("\n准备加载资源:")

    local pFileUtil=_G.FilesUtil
    local cnfArray=_G.Cfg.ResList[_resId]
    local pRequire=require
    local pPcall=pcall
    local pFormat =string.format
    -- local nFun=function(_fileName)
    --     local szFile=pFormat("%s/%s",szCnfDir,_fileName)
    --     pRequire(szFile)
    -- end

    self.m_loadResCount=0
    self.m_loadResArray={}
    for _,fileName in pairs(self.m_fileList) do
        local searchLua=string.find(fileName,[[_cnf]])
        if searchLua then
            -- local status, msg=pcall(nFun,fileName)
            -- if not status then
            --     CCMessageBox(msg,fileName.." 表出错")
            --     __G__TRACKBACK__(msg)
            -- end
            local szFile=pFormat("%s/%s",szCnfDir,fileName)
            pRequire(szFile)
        elseif string.len(fileName)>0 then
            local cStrArray={}
            local cStrCount=0
            for noZero in string.gmatch(fileName,"[^%z]") do
                cStrCount=cStrCount+1
                cStrArray[cStrCount]=noZero
            end
            local cStr=table.concat(cStrArray)
            local searchAnimation=string.find(fileName, [[anim/]])
            if searchAnimation~=nil then
                if pFileUtil:check(fileName)==false then
                    CCMessageBox([[rescource is empyt：]]..tostring(fileName), [[rescource error]])
                end
            else
                self.m_loadResCount=self.m_loadResCount+1
                self.m_loadResArray[self.m_loadResCount]=fileName
            end
            -- CCLOG([[LoadResScene.load res file=%s]],cStr)
        end
    end

    -- for i=1,self.m_spineCount do
    --     local fileName=string.format("%s.png",self.m_spineList[i])
    --     self.m_loadResCount=self.m_loadResCount+1
    --     self.m_loadResArray[self.m_loadResCount]=fileName
    -- end

    local newList={}
    for i=1,self.m_gafCount do
        local tempData=self.m_gafList[i]
        if not tempData.isSkill then
            local fileName=string.format("%s.png",tempData.fileName)
            self.m_loadResCount=self.m_loadResCount+1
            self.m_loadResArray[self.m_loadResCount]=fileName
        else
            newList[#newList+1]=tempData.fileName
        end
    end
    self.m_gafList=newList
    self.m_gafCount=#self.m_gafList

    self.m_totleCount=self.m_loadResCount+self.m_spineCount
    GCLOG("LoadResScene.load====>>>> self.m_totleCount=%d,self.m_spineCount=%d",self.m_totleCount,self.m_spineCount)

    local normalCount=self.m_loadResCount - self.m_spineCount
    local SFCache=cc.SpriteFrameCache:getInstance()
    local TTCache=cc.Director:getInstance():getTextureCache()
    local curLoadIdx=0
    local pSysInfo=_G.SysInfo
    local tempArray=_G.Cfg.mapSpinePngNameArray
    local function nLoadRes()
        curLoadIdx=curLoadIdx+1
        if curLoadIdx>self.m_loadResCount then
            pSysInfo:resetTextureFormat()
            _G.Scheduler:unschedule(self.m_schedule)
            self:loadSpine()
            return
        end
        local fileName=self.m_loadResArray[curLoadIdx]
        local isUesDefaultFormat=true
        if string.find(fileName,[[.plist]])~=nil then
            pSysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
            SFCache:addSpriteFrames(fileName)
            isUesDefaultFormat=false
        else
            if string.find(fileName,[[.jpg]]) then
                pSysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)
                isUesDefaultFormat=false
            elseif not string.find(fileName,[[spine/]]) then
                if not tempArray[fileName] then
                    pSysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
                    isUesDefaultFormat=false
                end
            end
            TTCache:addImage(fileName)
        end
        if not isUesDefaultFormat then
            pSysInfo:resetTextureFormat()
        end

        -- print("CCCCCCCCCCCCCC=======>>>>>>>",curLoadIdx,fileName)

        if self.m_resType==ScenesManger.sceneResType then
            local percent=math.ceil(curLoadIdx*100/self.m_totleCount)
            self.loadingLayer:setPercent(percent)
        end
    end

    self.m_schedule=_G.Scheduler:schedule(nLoadRes,0.03,false)
end

function LoadResScene.loadSpine(self)
    if self.m_spineCount==0 then
        self:loadGaf()
        return
    end

    local loadCount=self.m_loadResCount
    local curLoadIdx=1
    local function nLoadSpine()
        if curLoadIdx>self.m_spineCount then
            _G.Scheduler:unschedule(self.m_schedule)
            self.m_loadResCount=self.m_loadResCount+self.m_spineCount
            self:loadGaf()
            return
        end
        local fileName=self.m_spineList[curLoadIdx]
        _G.SpineManager.addSpineCache(fileName)

        loadCount=loadCount+1

        if self.m_resType==ScenesManger.sceneResType then
            local percent=math.ceil(loadCount*100/self.m_totleCount)
            self.loadingLayer:setPercent(percent)
        end

        curLoadIdx=curLoadIdx+1
    end
    self.m_schedule=_G.Scheduler:schedule(nLoadSpine,0,false)
end

function LoadResScene.loadGaf(self)
    if self.m_gafCount==0 then
        self:finishLoad()
        return
    end

    local loadCount=self.m_loadResCount
    local curLoadIdx=1
    local function nLoadSpine()
        if curLoadIdx>self.m_gafCount then
            self:finishLoad()
            _G.Scheduler:unschedule(self.m_schedule)
            return
        end
        local fileName=self.m_gafList[curLoadIdx]
        _G.StageObjectPool:addObject(fileName,_G.Const.StagePoolTypeGaf)

        loadCount=loadCount+1

        if self.m_resType==ScenesManger.sceneResType then
            local percent=math.ceil(loadCount*100/self.m_totleCount)
            self.loadingLayer:setPercent(percent)
        end

        curLoadIdx=curLoadIdx+1
    end
    self.m_schedule=_G.Scheduler:schedule(nLoadSpine,0,false)
end

function LoadResScene.finishLoad(self)
    ScenesManger.isLoading=nil
    self:hideLoading()

    if self.m_resType==ScenesManger.sceneResType then
        self.loadingLayer:setPercent(100)
    end

    if not ScenesManger.isExitGame then
        self.m_showUI(self.m_sceneId)
    end
end

function LoadResScene.loadCnfByRes(self,_resId)
    local cnfArray=_G.Cfg.ResList[_resId]
    local pRequire=require
    local pPcall=pcall
    local pFormat =string.format
    local nFun=function(_fileName)
        local szFile=pFormat("%s/%s",szCnfDir,_fileName)
        pRequire(szFile)
    end
    for _,fileName in pairs(cnfArray) do
        local status, msg=pPcall(nFun,fileName)
        if not status then
            CCMessageBox(msg,fileName.." 表出错")
            __G__TRACKBACK__(msg)
        end
    end
end


