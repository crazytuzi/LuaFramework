local LoadView = classGc(view,function(self)
    -- self.visibleSize = cc.Director:getInstance():getVisibleSize()
    -- self.origin      = cc.Director:getInstance():getVisibleOrigin()

    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/ui_login.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/ui_login32.plist")
    self.m_winSize=cc.Director:getInstance():getWinSize()

    self.m_gcLuaType=_G.SysInfo:getGcLuaType()
    self.m_isUpdateOpen=self.m_gcLuaType==_G.Const.kResTypeZIP
end)

function LoadView.show(self)
    self:create()

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(self.m_scene)
    else
        cc.Director:getInstance():runWithScene(self.m_scene)
    end
end

function LoadView.create(self)
    self.m_scene=cc.Scene:create()

    _G.GLoginEffect=require("mod.login.LoginEffect")()
    self.m_scene:addChild(_G.GLoginEffect:getNode())

    self:init()
end

function LoadView.init(self)
    self:initView()
    -- 播放背景音乐
    -- self:playBgMusic()

    if _G.GRebootLuaScrite then
        -- 直接先登录
        self:delayLoadCnf()
        _G.GRebootLuaScrite=nil
    else
        -- 解压
        self:startConvert()
    end
end

function LoadView.initView(self)
    self.m_loadNode=cc.Node:create()
    self.m_loadNode:setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
    self.m_scene:addChild(self.m_loadNode)

    local gameIcon=cc.Sprite:create("ui/logo.png")
    gameIcon:setPosition(-270,150)
    self.m_loadNode:addChild(gameIcon)

    local wordBg=cc.Sprite:createWithSpriteFrameName("general_loading_tip_bg.png")
    wordBg:setPosition(0,-175)
    self.m_loadNode:addChild(wordBg)

    local wordBgSize=wordBg:getContentSize()
    self.m_contentLabel=_G.Util:createLabel("初始化中......",20)
    self.m_contentLabel:setPosition(wordBgSize.width/2,wordBgSize.height/2)
    wordBg:addChild(self.m_contentLabel)

    local barSize=cc.size(816,8)
    local loadBarBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_loading_1.png",cc.rect(9,4,1,1))
    loadBarBg:setPreferredSize(barSize)
    loadBarBg:setPosition(0,-225)
    self.m_loadNode:addChild(loadBarBg)

    local loadingBar=ccui.LoadingBar:create()
    loadingBar:loadTexture("general_loading_2.png",ccui.TextureResType.plistType)
    loadingBar:setPosition(barSize.width/2,barSize.height/2)
    loadBarBg:addChild(loadingBar)
    self.m_loadingBar=loadingBar

    self:setLoadPercent(0)
end

function LoadView.runLoadingBar(self,_fun)
    if self.m_barScheduler then return end
    
    local function lv_progress()
        local curPercent=self.m_loadingBar:getPercent()
        if curPercent>=90 then
            self:stopLoadingBar()
            if _fun then
                _fun()
            end
            return
        end
        self:setLoadPercent(curPercent+2)
    end
    self.m_barScheduler=_G.Scheduler:schedule(lv_progress,0,false)
end

function LoadView.stopLoadingBar(self)
    if self.m_barScheduler~=nil then
        _G.Scheduler:unschedule(self.m_barScheduler)
        self.m_barScheduler=nil
    end
end

function LoadView.setLoadPercent(self,_percent)
    self.m_loadingBar:setPercent(_percent)

    -- local realPercent=self.m_loadingBar:getPercent()
    -- local barSize=self.m_loadingBar:getContentSize()

    -- if self.m_barEffect==nil then
    --     self.m_barEffect=cc.Sprite:createWithSpriteFrameName("ui/global/chat_btn.png")
    --     self.m_loadingBar:addChild(self.m_barEffect)
    -- end
    -- local res=realPercent/100
    -- self.m_barEffect:setPosition(res*barSize.width,barSize.height/2)
end

function LoadView.playBgMusic(self)
    local bgMusicPath = cc.FileUtils:getInstance():fullPathForFilename("bg/intro.mp3") 
    cc.SimpleAudioEngine:getInstance():playMusic(bgMusicPath, true)
end

function LoadView:startConvert()
    gcprint("startConvert=====>>>>>")
    self:setLoadPercent(0)
    self.m_contentLabel:setString("检查解压......")
    self:runLoadingBar()
    
    local resConvert=gc.ResConvert:create()
    resConvert:retain()

    local function convertCallBack(eventName,fileName,iNowCount,iTotalCount)
        gcprint("convertCallBack-->>",eventName,fileName,iNowCount,iTotalCount)
        if eventName=="ConvertError" then
            local szMsg=""
            if fileName=="ERROR_01" then
                szMsg="压缩版本文件丢失,请重新启动游戏!"
            elseif fileName=="ERROR_02" then
                szMsg="压缩版本文件丢失,请重新启动游戏!"
            end
            self:stopLoadingBar()
            self:setLoadPercent(100)
            self.m_contentLabel:setString(szMsg)
        elseif eventName=="ConvertEnd" then
            resConvert:release()
            self:startUpdate()
        elseif eventName=="ConvertIng" then
            self:stopLoadingBar()

            iTotalCount=iTotalCount<=0 and 1 or iTotalCount
            local iPercent=iNowCount/iTotalCount*100
            self:setLoadPercent(iPercent)
            self.m_contentLabel:setString(string.format("解压: %s[%d,%d]",fileName,iNowCount,iTotalCount))
        end
    end

    local handler = gc.ScriptHandlerControl:create(convertCallBack)
    resConvert:registerScriptHandler(handler)
    resConvert:checkDefault()
end

function LoadView:startUpdate()
    if not self.m_isUpdateOpen then
        self:delayLoadCnf()
        return
    end
    self.m_contentLabel:setString("检查更新......")
    self:stopLoadingBar()
    self:setLoadPercent(0)
    self:runLoadingBar()

    local resUpdate=gc.ResUpdate:create()
    resUpdate:retain()
    _G.SysInfo:initXmlVersion()

    local function checkUpdateAgain()
        local updateXml_url=_G.SysInfo:urlUpdateXml()
        -- local updateXml_url="http://xm-api.gamecore.cn:89/api/Phone/UpdateXml?cid=158&mac=swqr&uuid=72449&versions=1&os=ios&os_ver=4&res=1&res_ver=1&source=1&source_sub=1&screen=1024&language=cn&referrer=sdfaf&time=1422512226&sign=9900b7ed73d750288a5fe1af15c9b180&upgrade=ee"
        resUpdate:checkResUpdate(updateXml_url)
    end
    local function updateNow()
        resUpdate:startUpdate()
    end
    local function exitGame()
        cc.Director:getInstance():endToLua()
    end

    local function updateCallBack(eventName,tempStr,nowDownload,totalDownload)
        gcprint("updateCallBack-->>",eventName,tempStr,nowDownload,totalDownload)
        if eventName=="UpdateEnvironment" then
            local szMsg="Undefine"
            local sureFun=nil
            local cancelFun=nil
            if tempStr=="CheckResUpdateAgain" then
                szMsg="检查更新失败,请检查网络!"
                sureFun=checkUpdateAgain
                cancelFun=exitGame
            elseif tempStr=="ResUpdate" then
                szMsg="有资源更新,是否立即下载?"
                sureFun=updateNow
                cancelFun=exitGame
            elseif tempStr=="HttpError" then
                szMsg=string.format("下载资源失败!请检查网络!(%d)",nowDownload)
                sureFun=checkUpdateAgain
                cancelFun=exitGame
            elseif tempStr=="NoUpdate" then
                self:loadCnf()
                return
            end
            self:stopLoadingBar()
            self:setLoadPercent(100)
            self.m_contentLabel:setString(szMsg)

            _G.Util:showTipsBox(szMsg,sureFun,cancelFun)

        elseif eventName=="UpdateProgress" then
            totalDownload=totalDownload<=0 and 1 or totalDownload
            local iPercent=nowDownload/totalDownload*100
            self:setLoadPercent(iPercent)

            nowDownload=nowDownload<1048576 and string.format("%.2fKB",nowDownload/1024) or string.format("%.2fMB",nowDownload/1024/1024)
            totalDownload=totalDownload<1048576 and string.format("%.2fKB",totalDownload/1024) or string.format("%.2fMB",totalDownload/1024/1024)

            self.m_contentLabel:setString(string.format("下载: %s(%s/%s)",tempStr,nowDownload,totalDownload))
        elseif eventName=="ConvertProgress" then
            totalDownload=totalDownload<=0 and 1 or totalDownload
            local iPercent=nowDownload/totalDownload*100
            self:setLoadPercent(iPercent)
            self.m_contentLabel:setString(string.format("解压: %s[%d/%d]",tempStr,nowDownload,totalDownload))
        elseif eventName=="UpdateEnd" then
            resUpdate:release()
            if gc.App:getInstance().resetLuaZip==nil then
                local szMsg="更新成功,请重启游戏"
                self.m_contentLabel:setString(szMsg)
                _G.Util:showTipsBox(szMsg,exitGame,exitGame)
            else
                local resetView=require("mainReset")
                resetView:mainReset()
            end
        elseif eventName=="UpdateFailed" then
            local fileName=tempStr
            local szMsg=string.format("下载文件出错(%s)\n是否重新下载?",fileName)
            _G.Util:showTipsBox(szMsg,checkUpdateAgain,exitGame)
        end
    end

    local updateXml_url=_G.SysInfo:urlUpdateXml()
    -- local updateXml_url="http://xm-api.gamecore.cn:89/api/Phone/UpdateXml?cid=158&mac=swqr&uuid=72449&versions=1&os=ios&os_ver=4&res=1&res_ver=1&source=1&source_sub=1&screen=1024&language=cn&referrer=sdfaf&time=1422512226&sign=9900b7ed73d750288a5fe1af15c9b180&upgrade=ee"
    gcprint("updateXml_url---->>>",updateXml_url)

    local handler=gc.ScriptHandlerControl:create(updateCallBack)
    resUpdate:registerScriptHandler(handler)
    resUpdate:checkResUpdate(updateXml_url)
end

function LoadView.delayLoadCnf(self)
    local function f()
        self:loadCnf(true)
    end
    self.m_contentLabel:setString("初始化数据......")
    self:stopLoadingBar()
    self:setLoadPercent(100)

    performWithDelay(self.m_scene,f,1)
end

function LoadView.loadCnf(self,_isDelay)
    local cnfArray=_G.Cfg.ResList[_G.Cfg.CNF_FirstGame]
    local pRequire=require
    local pFormat =string.format
    local szCnfDir=_G.SysInfo:getDirCnf()

    if not _isDelay then
        self.m_contentLabel:setString("初始化数据......")
        self:stopLoadingBar()
        self:setLoadPercent(100)
    end

    for _,fileName in pairs(cnfArray) do
        local szFile=pFormat("%s/%s",szCnfDir,fileName)
        pRequire(szFile)
    end
    self:startSdkLogin()
    _G.GNoUnloadArray=nil
end

function LoadView.startSdkLogin(self)
    GCLOG("startSdkLogin=====>>>>>")
    -- self.m_loadingBar:setVisible(false)
    -- self.m_loadingBg:setVisible(false)
    -- self.m_contentLabel:setString("等待登录")

    if self.m_loadNode~=nil then
        self.m_loadNode:removeFromParent(true)
        self.m_loadNode=nil
        self.m_loadingBar=nil
        self.m_contentLabel=nil
    end

    local loginView=require("mod.login.LoginView")()
    self.m_loginLayer=loginView:create()
    self.m_scene:addChild(self.m_loginLayer)
end

return LoadView

