function CCMessageBox(_szContent,_szTitle)
    gc.App:getInstance():showMessageBox(_szContent,_szTitle)
end
function performWithDelay(node, callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    node:runAction(sequence)
    return sequence
end
function classGc(base, ctor)
    local c = {}
    if not ctor and type(base) == 'function' then
        ctor = base
        base = nil
    elseif type(base) == 'table' then
        for i,v in pairs(base) do
            c[i] = v
        end
        c._base = base
    end
    c.__index = c
    local mt = {}
    mt.__call = function(class_tbl, ...)
        local obj = {}
        setmetatable(obj,c)

        if ctor then
            ctor(obj,...)
        else
            if base and base.ctor then
                base.ctor(obj, ...)
            end
        end
        return obj
    end
    c.ctor = ctor
    -- c.is = function(self, klass)
    --     local m = getmetatable(self)
    --     while m do 
    --         if m == klass then return true end
    --         m = m._base
    --     end
    --     return false
    -- end
    setmetatable(c, mt)
    return c
end

require("cfg.Const")
require("cfg.ConstGc")
require("mvc.view")
require("mvc.mediator")
require("mvc.command")
require("mvc.commandMsg")
require("util.ColorUtil")
require("util.ShaderUtil")

_G.SysInfo   = require("util.SysInfo")()
_G.FilesUtil = require("util.FilesUtil")()
_G.Scheduler = require("util.Scheduler")()

_G.UniqueID  = require("util.UniqueID")()
_G.Network   = require("util.Network")()
_G.TimeUtil  = require("util.TimeUtil")()
_G.controller= require("mvc.controller")()
_G.TipsUtil  = require("mod.general.TipsUtil")()
_G.AnimationUtil = require("util.AnimationUtil")()

_G.MapData={}
require("config@cn.material_cnf")
require("cfg.Lang")
require("mod.res.ScenesManger")
require("mod.res.BaseScene")
require("util.ImageAsyncManager")

local __MM_COLOR=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_WHITE)
local __MB_COLOR=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_PSTROKE)
local __winSize=cc.Director:getInstance():getWinSize()
local __fonsName=_G.FontName.Heiti
local Util = classGc(function(self)
    

    self.m_log=require("mod.logs.Logs")()
    self.m_tUtil=_G.TimeUtil
    -- self.m_tUtil:correctionServTimePHP()
    self:update()

    self.m_audioCurMusicPath=cc.FileUtils:getInstance():fullPathForFilename("bg/10001.mp3")
    self.m_audioEffectArray={}
    self.m_mp3PathArray={}
    self.m_battleEffect={}

    gc.CButton:setOutlineNormalColor(cc.c4b(141,109,95,255))
    gc.CButton:setTitleTextNomalColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_WHITE))
    gc.CButton:setOutlineEnableColor(cc.c4b(141,109,95,255))
    gc.CButton:setTitleTextEnableColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_WHITE))
end)

function Util:update()
    local function u(t)
        -- self.m_tUtil:reset()
        -- local nowTime = self.m_tUtil:getNowMilliseconds()
        -- self.m_tUtil:heartBeat(nowTime)
        -- self.m_log:show(nowTime)

        local nowTime=self.m_tUtil:addBySecond(t)
        self.m_log:show(nowTime)

    end
    self.m_logScheduler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(u, 0, false)
end
function Util:initLog()
    self.m_log:init()
end
function Util:regLogMediatorAgain()
    self.m_log:regMediatorAgain()
end
function Util:getLogsView()
    return self.m_log
end

-- 去string前后空格(有问题 不能用)
function Util:trim(s)
    assert(type(s)=="string")
    return string.match(s,"^%s*(.*?)%s?$")
end

function Util:random_0_1()
    -- return CMath:random_0_1()
    return math.random(0,1)
end

function Util:getAttrPower(_attrArray)
    local totalPower=0
    for nType,nValue in pairs(_attrArray) do
        if nType==_G.Const.CONST_ATTR_HP then
            totalPower=totalPower+math.floor(nValue/10)
        elseif nType==_G.Const.CONST_ATTR_STRONG_ATT
            or nType==_G.Const.CONST_ATTR_STRONG_DEF
            or nType==_G.Const.CONST_ATTR_DEFEND_DOWN then
            totalPower=totalPower+nValue
        elseif nType==_G.Const.CONST_ATTR_HIT
            or nType==_G.Const.CONST_ATTR_DODGE then
            totalPower=totalPower+nValue
        elseif nType==_G.Const.CONST_ATTR_CRIT
            or nType==_G.Const.CONST_ATTR_RES_CRIT then
            totalPower=totalPower+nValue
        elseif nType==_G.Const.CONST_ATTR_BONUS
            or nType==_G.Const.CONST_ATTR_REDUCTION then
            totalPower=totalPower+math.floor(nValue*5)
        end
    end
    return totalPower
end

function Util:createLabel(_szStr,_size,_backColor)
    -- _backColor = _backColor or __MB_COLOR
    local tempLb=cc.Label:createWithTTF(_szStr or "nil",__fonsName,_size)
    -- tempLb:enableOutline(_backColor,1)
    return tempLb
end
function Util:createBorderLabel(_szStr,_size,_backColor)
    _backColor = _backColor or __MB_COLOR
    local tempLb=cc.Label:createWithTTF(_szStr or "nil",__fonsName,_size)
    tempLb:enableOutline(_backColor,1)
    return tempLb
end
function Util:CreateTraceLabel( _str, _fontSize, _lineWidth, _mainColor, _backColor )
    local mainColor = _mainColor or cc.c3b(255,255,0)
    local backColor = _backColor or cc.c4b(0,0,0,255)
    local lineWidth = _lineWidth or 2

    local tempLabel=cc.Label:createWithTTF(_str or "nil",__fonsName,_fontSize)
    tempLabel:enableOutline(backColor,lineWidth)
    tempLabel:setTextColor(mainColor)

    return tempLabel
end

function Util:preloadBgMusic(_mp3Name)
    local szFile=string.format("bg/%s.mp3",tostring(_mp3Name))
    local szFullFile=cc.FileUtils:getInstance():fullPathForFilename(szFile)
    local isFullPath=cc.FileUtils:getInstance():isAbsolutePath(szFullFile)
    if isFullPath then
        cc.SimpleAudioEngine:getInstance():preloadMusic(szFullFile)
    end
end
function Util:releasePreBgMusic()
    if self.m_audioCurMusicPath==nil then return end

    local isFullPath=cc.FileUtils:getInstance():isAbsolutePath(self.m_audioCurMusicPath)
    if isFullPath then
        cc.SimpleAudioEngine:getInstance():stopMusic(true)
    end

    self.m_audioCurMusicPath=nil
end
--播放背景声音
function Util:playAudioMusic(_mp3Name,_isReleasePre,_isForce)
    -- do return end
    if _G.GSystemProxy:isBgMusicOpen() or _isForce then
        local szFile=self.m_mp3PathArray[_mp3Name]
        if szFile==nil then
            szFile=string.format("bg/%s.mp3",tostring(_mp3Name))
            local pFileUtils=cc.FileUtils:getInstance()
            local szFullFile=pFileUtils:fullPathForFilename(szFile)
            local isFullPath=pFileUtils:isAbsolutePath(szFullFile)
            if isFullPath then
                if self.m_audioCurMusicPath~=nil and self.m_audioCurMusicPath~=szFullFile then
                    -- 是否之前的背景音乐
                    cc.SimpleAudioEngine:getInstance():stopMusic(true)
                end
                cc.SimpleAudioEngine:getInstance():playMusic(szFullFile,true)
                self.m_audioCurMusicPath=szFullFile
                self.m_mp3PathArray[_mp3Name]=szFullFile
            else
                CCMessageBox("音效不存在:"..szFile, "错误提示")
                cc.SimpleAudioEngine:getInstance():stopMusic(true)
            end
        else
            if self.m_audioCurMusicPath~=nil and self.m_audioCurMusicPath~=szFile then
                -- 是否之前的背景音乐
                cc.SimpleAudioEngine:getInstance():stopMusic(true)
            end
            cc.SimpleAudioEngine:getInstance():playMusic(szFile,true)
            self.m_audioCurMusicPath=szFile
        end
    else
        cc.SimpleAudioEngine:getInstance():stopMusic(true)
    end
end
--播放一次音效
function Util:playAudioEffect(_mp3Name,_bLoop,_force)
    -- do return end
    if _G.GSystemProxy:isEffectSoundOpen() or _force then
        local szFile=self.m_mp3PathArray[_mp3Name]
        if szFile==nil then
            szFile=string.format("bg/%s.mp3",tostring(_mp3Name))
            local pFileUtils=cc.FileUtils:getInstance()
            local szFullFile=pFileUtils:fullPathForFilename(szFile)
            local isFullPath=pFileUtils:isAbsolutePath(szFullFile)
            if isFullPath then
                cc.SimpleAudioEngine:getInstance():playEffect(szFullFile,_bLoop)
                self.m_audioEffectArray[szFullFile]=_mp3Name
                self.m_mp3PathArray[_mp3Name]=szFullFile
            else
                -- CCMessageBox("音效不存在:"..szFile, "错误提示")
                local command=CErrorBoxCommand("音效不存在:"..szFile)
                controller:sendCommand(command)
            end
        else
            cc.SimpleAudioEngine:getInstance():playEffect(szFile,_bLoop)
        end
    end
end
--战斗音效
function Util:playBattleEffect(_mp3Name)
    if not self.m_battleEffect[_mp3Name] then
        self.m_battleEffect[_mp3Name]=true
        self:playAudioEffect(_mp3Name)
        local function delayFun()
            self.m_battleEffect[_mp3Name]=nil
        end
        _G.Scheduler:performWithDelay(0.2,delayFun)
    end
end
-- 释放音效
function Util:unlouadAudioEffect(_mp3Name)
    if _G.Cfg.SoundEffectNoUnLoad[_mp3Name] then return end
    local szFile=string.format("bg/%s.mp3",tostring(_mp3Name))
    local pFileUtils=cc.FileUtils:getInstance()
    local szFullFile=pFileUtils:fullPathForFilename(szFile)
    local isFullPath=pFileUtils:isAbsolutePath(szFullFile)
    if isFullPath then
        cc.SimpleAudioEngine:getInstance():unloadEffect(szFullFile)
        self.m_audioEffectArray[szFullFile]=nil
    end
end
-- 释放所有音效
function Util:unloadAllAudioEffect()
    for fullName,fileName in pairs(self.m_audioEffectArray) do
        if not _G.Cfg.SoundEffectNoUnLoad[fileName] then
            cc.SimpleAudioEngine:getInstance():unloadEffect(fullName)
        end
    end
    self.m_audioEffectArray={}
end

function Util:CreateLine(width,height,color4B)
    color4B=color4B or cc.c4b(255,255,255,255)
    local lineColor = cc.LayerColor:create(color4B,width,height)
    return lineColor
end

function Util:showLoadCir()
    local __Director=cc.Director:getInstance()
    local runningScene=__Director:getRunningScene()
    if self:isShowLoadCir(runningScene) then return end

    local circle=cc.Sprite:createWithSpriteFrameName("general_loading.png")
    runningScene:addChild(circle,100000,90608)

    local rotaBy=cc.RotateBy:create(1,360)
    circle:runAction(cc.RepeatForever:create(rotaBy))

    circle:setPosition(cc.p(__winSize.width*0.5,__winSize.height*0.5))

    __Director:getEventDispatcher():setEnabled(false)
end
function Util:hideLoadCir(_scene)
    local runningScene=_scene or cc.Director:getInstance():getRunningScene()
    if self:isShowLoadCir(runningScene) then
        runningScene:removeChildByTag(90608)
    end

    if not self:isShowOffLineLoadCir() then
        cc.Director:getInstance():getEventDispatcher():setEnabled(true)
    end
end
function Util:isShowLoadCir(_scene)
    local runningScene=_scene or cc.Director:getInstance():getRunningScene()
    if runningScene:getChildByTag(90608) then
        return true
    end
    return false
end

function Util:showOffLineLoadCir()
    local __Director=cc.Director:getInstance()
    local runningScene=__Director:getRunningScene()
    if self:isShowOffLineLoadCir(runningScene) then return end

    local tempNode=cc.LayerColor:create(cc.c4b(0,0,0,255*0.3))
    runningScene:addChild(tempNode,100001,90609)

    local rotaBy=cc.RotateBy:create(1,360)
    local circle=cc.Sprite:createWithSpriteFrameName("general_loading.png")
    circle:runAction(cc.RepeatForever:create(rotaBy))
    circle:setPosition(__winSize.width*0.5,__winSize.height*0.5)
    tempNode:addChild(circle)

    local noticLabel=self:createLabel("重新连接服务器...",20)
    noticLabel:setPosition(__winSize.width*0.5,__winSize.height*0.5-40)
    tempNode:addChild(noticLabel)

    local dituSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_title_hongbao.png")
    dituSpr:setContentSize(cc.size(250,100))
    dituSpr:setPosition(__winSize.width*0.5,__winSize.height*0.5-15)
    tempNode:addChild(dituSpr,-1)

    __Director:getEventDispatcher():setEnabled(false)
end
function Util:hideOffLineLoadCir(_scene)
    local runningScene=_scene or cc.Director:getInstance():getRunningScene()
    if self:isShowOffLineLoadCir(runningScene) then
        runningScene:removeChildByTag(90609)
    end

    self:hideLoadCir()
    cc.Director:getInstance():getEventDispatcher():setEnabled(true)
end
function Util:isShowOffLineLoadCir(_scene)
    local runningScene=_scene or cc.Director:getInstance():getRunningScene()
    if runningScene:getChildByTag(90609) then
        return true
    end
    return false
end

function Util:showTipsBox(_szMsg,_funSure,_funCancel)
    local view=require("mod.general.TipsBox")()
    local layer=view:create(_szMsg,_funSure,_funCancel)
    cc.Director:getInstance():getRunningScene():addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC)
    return view
end
function Util:showErrorTips(_code)
    local command=CErrorBoxCommand(_code or 0)
    _G.controller:sendCommand(command)
end


function Util:getServerNameArray(_serverArray,_callBack)
    local nameArray={}
    local serverNameList=_G.GLoginPoxy:getServerNameList()
    local tempArray={}

    for i=1,#_serverArray do
        local sid=_serverArray[i]
        if serverNameList[sid] then
            nameArray[sid]=serverNameList[sid]
        else
            tempArray[#tempArray+1]=sid
        end
    end

    if #tempArray==0 then
        if _callBack then _callBack(nameArray) end
        return
    end

    local szUrl = _G.SysInfo:urlServName(tempArray)
    local xhrRequest = cc.XMLHttpRequest:new()
    xhrRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhrRequest:open("GET", szUrl)

    local function http_handler()
        if xhrRequest.readyState == 4 and (xhrRequest.status >= 200 and xhrRequest.status < 207) then
            local response = xhrRequest.response

            print("getServerNameArray response11="..response)
            local output=json.decode(response,1)

            local tempData=output.data or {}
            for k,v in pairs(tempData) do
                local sid=tonumber(k)
                nameArray[sid]=v
                _G.GLoginPoxy.addServerName(sid,v)
            end

            if _callBack then _callBack(nameArray) end
        else
            local function nFun()
                self:httpRequestServer()
            end
            self:getServerNameArray(_serverArray)
        end
    end

    xhrRequest:registerScriptHandler(http_handler)
    xhrRequest:send()
end
return Util
