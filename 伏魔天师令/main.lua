-- cc.FileUtils:getInstance():addSearchPath("src")
-- cc.FileUtils:getInstance():addSearchPath("res")
-- _G.GNoUnloadArray={}
-- for k,v in pairs(_G.package.loaded) do
--     _G.GNoUnloadArray[k]=true
-- end

local searchPaths=cc.FileUtils:getInstance():getSearchPaths()
local newPaths={}
local allPaths={}
for i=1,#searchPaths do
    local pathName=searchPaths[i]
    if not allPaths[pathName] then
        allPaths[pathName]=true
        if string.find(pathName,[[/data/data/]]) then
            table.insert(newPaths,1,pathName)
        else
            newPaths[#newPaths+1]=pathName
        end
    end
end
cc.FileUtils:getInstance():setSearchPaths(newPaths)
for i=1,#newPaths do
    print("main.lua===>> SearchPath=======>",i,newPaths[i])
end

-- CC_USE_DEPRECATED_API = true
require("cocos.init")
-- CCLOG,发布版本不输出
function CCLOG(...)
    print(string.format(...))
end
function GCLOG(...)
    gcprint(string.format(...))
end

function LOG_CLOSE()
    local pGolbal=_G
    if pGolbal.__print then return end
    pGolbal.__print=pGolbal.print
    pGolbal.__CCLOG=pGolbal.CCLOG
    pGolbal.__gcprint=pGolbal.gcprint
    pGolbal.__GCLOG=pGolbal.GCLOG
    local nFun=function() end
    pGolbal.print=nFun
    pGolbal.CCLOG=nFun
    pGolbal.gcprint=nFun
    pGolbal.GCLOG=nFun
end
function LOG_OPEN()
    local pGolbal=_G
    if not pGolbal.__print then return end
    pGolbal.print=pGolbal.__print
    pGolbal.CCLOG=pGolbal.__CCLOG
    pGolbal.gcprint=pGolbal.__gcprint
    pGolbal.GCLOG=pGolbal.__GCLOG
    pGolbal.__print=false
    pGolbal.__CCLOG=false
    pGolbal.__gcprint=false
    pGolbal.__GCLOG=false
end

-- for CCLuaEngine traceback
local tempLog=gcprint
function __G__TRACKBACK__(msg)
    tempLog("----------------------------------------")
    tempLog("LUA ERROR: " .. tostring(msg) .. "\n")
    tempLog(debug.traceback())
    tempLog("----------------------------------------")
    return msg
end

local function __goSdkLogin()
    GCLOG("main.lua=========>>>>> __goSdkLogin...")
    local tempView=require("mod.login.SdkLogin")()
    tempView:loginSdk()
end
local function main()
    GCLOG("main.lua=========>>>>> STARTA...")

    -- collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause",   100)
    collectgarbage("setstepmul", 200)
   
    -- 策划配制
    _G.Cfg={}
    -- 字体
    _G.FontName = {
        -- Heiti = "ui/fonts/simhei.ttf",
        
        Heiti = "ui/fonts/mnjyhei.TTF",
        Arial = "Arial"
    }
    
    _G.Util=require("util.Util")()

    local runningScene=cc.Director:getInstance():getRunningScene()
    local updateScene=tolua.cast(runningScene,"gc.UpdateScene")
    if updateScene==nil then return end

    local loadSchedule=nil
    local index,loadType=0,1
    local resList=_G.Cfg.ResList[Cfg.UI_NeverRelease]
    local cnfArray=_G.Cfg.ResList[_G.Cfg.CNF_FirstGame]
    local pRequire=require
    local pFormat =string.format
    local szCnfDir=_G.SysInfo:getDirCnf()
    local tolCount=#resList+#cnfArray
    local curPercent,onePercent=0,100/tolCount

    updateScene:setContentString("加载资源...")
    updateScene:setLoadBarPercent(0)

    cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_AUTO)

    local function onSchedule()
        index=index+1
        if loadType==2 then
            local fileName=resList[index]
            if fileName==nil then
                updateScene:getLoadNode():runAction(cc.Sequence:create(
                                                    cc.MoveBy:create(0.05,cc.p(0,15)),
                                                    cc.MoveBy:create(0.4,cc.p(0,-250)),
                                                    cc.CallFunc:create(__goSdkLogin)))
                updateScene:getContentLabel():runAction(cc.Sequence:create(
                                                    cc.MoveBy:create(0.05,cc.p(0,15)),
                                                    cc.MoveBy:create(0.4,cc.p(0,-250))))
                
                _G.Scheduler:unschedule(loadSchedule)
                _G.SpineManager.initNoRelease()
                _G.SpineManager.initRoleCache()
                RESET_GAME_DATA()
                return
            end
            local searchPlist=string.find(fileName,[[.plist]])
            if searchPlist then
                cc.SpriteFrameCache:getInstance():addSpriteFrames(fileName)
                gc.ResLoader:getInstance():savePlistLongTime(fileName)
            else
                local isUesDefaultFormat=true
                if string.find(fileName,[[.jpg]]) then
                    _G.SysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)
                    isUesDefaultFormat=false
                end
                local t=cc.Director:getInstance():getTextureCache():addImage(fileName)
                if t~=nil then
                    t:retain()
                end

                if not isUesDefaultFormat then
                    cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_AUTO)
                end
            end
        else
            local fileName=cnfArray[index]
            if fileName==nil then
                index=0
                loadType=2

                if not _G.Cfg.spine_res then
                    _G.Cfg.spine_res={}
                end
                return
            end

            local szFile=pFormat("%s/%s",szCnfDir,fileName)
            pRequire(szFile)
        end
        curPercent=curPercent+onePercent
        updateScene:setLoadBarPercent(curPercent)
    end
    loadSchedule=_G.Scheduler:schedule(onSchedule,0)
end

function LOAD_LOGIN_RES(_fun)
    local tempT={}
    tempT.show=function()
        _fun()
    end

    local fileList={}
    local fileCount=0
    for _,v in pairs(_G.Cfg.player_init) do
        for _,v in pairs(v.login_skill) do
            if _G.Cfg.skill[v] then
                for _,v in pairs(_G.Cfg.skill[v].effect_id) do
                    if v.id~=0 then
                        if v.class==1 then
                            fileCount=fileCount+1
                            fileList[fileCount]=string.format("spine/%d.png",v.id)
                        elseif v.class==3 then
                            fileCount=fileCount+1
                            fileList[fileCount]=string.format("gaf/%d.png",v.id)
                        end
                    end
                end
                for _,v in pairs(_G.Cfg.skill[v].effect_id2) do
                    if v.id~=0 then
                        if v.class==1 then
                            fileCount=fileCount+1
                            fileList[fileCount]=string.format("spine/%d.png",v.id)
                        elseif v.class==3 then
                            fileCount=fileCount+1
                            fileList[fileCount]=string.format("gaf/%d.png",v.id)
                        end
                    end
                end
            end
        end
    end
    BaseLayer.loadResources(tempT,Cfg.UI_SelectSeverScene,fileList)
end

local isRestartGameIng=false
local function __release()
    _G.Util:initLog()
    _G.Util:getLogsView():initMarquee()

    if _G.g_SmallChatView~=nil then
        _G.g_SmallChatView:getLayer():release()
        _G.g_SmallChatView=nil
    end

    if _G.CharacterManager~=nil then
        _G.CharacterManager:init()
    end

    _G.SpineManager.resetPlayerMountRes()
    _G.SpineManager.resetPlayerWeaponRes()
    _G.SpineManager.resetPlayerFeatherRes()
    _G.SpineManager.resetPreCityRes()
    _G.SpineManager.releaseAllSpine()
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    RESET_GAME_DATA()

    print("切换角色(帐号) 释放资源完毕~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    print(cc.Director:getInstance():getTextureCache():getCachedTextureInfo().."\n")
end
function RESTART_GAME(_type,_data)
    if isRestartGameIng then return end
    isRestartGameIng=true

    if _G.controller==nil then
        return
    end
    local mgscommand=CGotoSceneCommand()
    _G.controller:sendCommand(mgscommand)
    _G.controller:unMediatorAll()
    _G.controller.m_isCanNotConnect=true
    _G.Network:disconnect()

    _G.ScenesManger.releaseForChangeRole()
    _G.Scheduler:unAllschedule()

    cc.SimpleAudioEngine:getInstance():stopMusic(true)

    if _G.g_Stage then
        _G.g_Stage.isRelease=true
    end

    local function lFun2()
        __release()

        if _type==_G.Const.kResetGameTypeChuangAccount then
            _G.SysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
            local tempScene=gc.UpdateScene:create()
            tempScene:hideLoadNode()
            tempScene:hideContentLabel()
            _G.SysInfo:resetTextureFormat()

            local function nDelayFun()
                isRestartGameIng=false
                __goSdkLogin()
            end

            tempScene:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(nDelayFun)))

            local tempScene2=cc.TransitionCrossFade:create(0.35,tempScene)
            cc.Director:getInstance():replaceScene(tempScene2)
        else

            local function nFun()
                isRestartGameIng=false

                if _type==_G.Const.kResetGameTypeChuangServer then
                    require("mod.login.LoginServerView")(true)
                else
                    require("mod.login.LoginRoleView")(_data,true)
                end
            end

            LOAD_LOGIN_RES(nFun)
        end
    end

    local function lFun1()
        local tempScene=cc.Scene:create()
        cc.Director:getInstance():replaceScene(tempScene)
        tempScene:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(lFun2)))
    end

    local runningScene=cc.Director:getInstance():getRunningScene()
    local layer=cc.LayerColor:create(cc.c4b(0,0,0,0))
    runningScene:addChild(layer,9999999)

    local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)
    layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,layer)

    layer:runAction(cc.Sequence:create(cc.FadeTo:create(0.2,255),cc.CallFunc:create(lFun1)))
end
function RESET_GAME_DATA()
    _G.controller.m_aiState=nil
    _G.GCopyProxy=nil
    _G.g_Stage=nil

    require("mod.character.BuffManager")
    if _G.GLoginPoxy then
        -- 切换角色需要用到服务器列表
        _G.GLoginPoxy:resetGameData()
    else
        _G.GLoginPoxy=require("mod.login.LoginProxy")()
    end

    _G.GSystemProxy  =require("mod.support.SystemProxy")()
    _G.GPropertyProxy=require("mod.support.PropertyProxy")()
    _G.GBagProxy     =require("mod.support.BagProxy")()
    _G.GTaskProxy    =require("mod.support.TaskProxy")()
    _G.GOpenProxy    =require("mod.support.OpenProxy")()
    _G.GFriendProxy  =require("mod.support.FriendProxy")()
    _G.GChatProxy    =require("mod.chat.ChatProxy")()
    _G.GGuideManager =require("mod.support.GuideManager")()

    _G.GChatProxy:handleSystemNetworkMsg(string.format("欢迎来到%s！现在，动起你的指尖，感受惊奇的世界吧！",_G.Lang.gameName))
end

function get_scene_data(_sceneId)
    if _sceneId>=20000 and _sceneId<=39999 then
        return _G.Cfg.scene1[_sceneId]
    else
        return _G.Cfg.scene2[_sceneId]
    end
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
