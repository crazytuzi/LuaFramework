
require('TFFramework.net.TFClientUpdate')
local UpdateLayer_new = class("UpdateLayer_new", BaseLayer)
CREATE_SCENE_FUN(UpdateLayer_new)
CREATE_PANEL_FUN(UpdateLayer_new)

-- 外网更新地址
 local versionPath   = "http://192.168.10.107:8080/mhqx/test/"
 local filePath      = "http://192.168.10.107:8080/mhqx/test/source/"

-- local versionPath   = "http://10.10.16.108:8080/qx/download/hunfu/ios/"
-- local filePath      = "http://7road-2031-w.7road.com:8080/qx/download/hunfu/ios/source/"

if VERSION_DEBUG == true then

    -- -- --本地
    versionPath = "http://192.168.10.115/mhqx/"
    filePath    = "http://192.168.10.115/mhqx/source/"

    ---------测试外网
    versionPath = "http://112.74.111.206/mhqx/beta/"
    filePath    = "http://112.74.111.206/mhqx/beta/source/"

else
    -- -- -- ---------黑桃外网
    -- versionPath = "http://120.131.3.218/mhqx/heitao/"
    -- filePath    = "http://120.131.3.218/mhqx/heitao/source/"
    local system = ""-- pc
    if CC_TARGET_PLATFORM == CC_PLATFORM_IOS then
        system = "ios"
    elseif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        system = "android"
    end

    versionPath = "http://120.131.3.218/mhqx/" .. system .."/"
    filePath    = "http://120.131.3.218/mhqx/" .. system .."/source/"


    -- 版本为Q侠大乱斗
    if TFPlugins.GAME_TYPE == TFPlugins.Enum_GAME_TYPE_QXIA then
        versionPath = "http://120.131.3.218/mhqx/qxdld/" .. system .."/"
        filePath    = "http://120.131.3.218/mhqx/qxdld/" .. system .."/source/"
    end

    -- appstore 正式渠道
    if TFPlugins.GAME_TYPE == TFPlugins.Enum_GAME_TYPE_APPStore then
        ---------Appstore 正式更新的内容
        versionPath = "http://120.131.3.218/mhqx/appstore/"
        filePath    = "http://120.131.3.218/mhqx/appstore/source/"
    end

end


versionPath = TFPlugins.zipCheckPath       --更新文件检测地址
filePath    = TFPlugins.zipCheckPath       --zip下载地址


local TFClientUpdate =  TFClientResourceUpdate:GetClientResourceUpdate()

function UpdateLayer_new:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.login.UpdateLayer")
end

function UpdateLayer_new:initUI(ui)
    self.super.initUI(self,ui)
    self.ui = ui
    
    self.bar_update     = TFDirector:getChildByPath(ui, 'bar_update')
    self.bar_update_bg  = TFDirector:getChildByPath(ui, 'bg_bar')
    self.bar_update:setPercent(0);

    self.txt_update     = TFDirector:getChildByPath(ui, 'txt_update')
    self.txt_loading    = TFDirector:getChildByPath(ui, 'txt_loading')
    self.txt_chat       = TFDirector:getChildByPath(ui, 'txt_chat')
    self.img_bg         = TFDirector:getChildByPath(ui, 'bg')
    self.img_title      = TFDirector:getChildByPath(ui, 'img_title')
    self.txt_version    = TFDirector:getChildByPath(ui, 'txt_version')

    if self.img_title then
        self.img_title:setVisible(false)
    end

    self.bar_update_bg:setVisible(false)
    self.txt_update:setVisible(true)
    -- self.img_point:setVisible(false)
    self.bar_update:setVisible(false)

    self.bar_load = TFDirector:getChildByPath(ui, 'bar_load')
    self.bar_load:setVisible(true)

    local index     = 1;
    local timeCount = 1;
    local loadingStr = "";

        self.bar_update_bg:setVisible(true)
        self.bar_load:setPercent(0)

    function change()
        --省略号动起来
        loadingStr = loadingStr .. ".";
        index = index + 1;
        if index > 5 then
            loadingStr = "";
            index = 1;
        end

        self.txt_loading:setText(loadingStr)

        --动态显示小贴士
        timeCount = timeCount + 1
        if timeCount > 10 then
            timeCount = 1
            self:showHelpText()
        end
    end

    self.loadingTimeId = TFDirector:addTimer(500, -1, nil, change)
    self.txt_loading:setText("")

    --self.txt_update:setText("正在检测最新资源")
    self.txt_update:setText(localizable.updateLaye_check_resource)

    self:playEffect()
    
    self:LoadingEffect()

    -- 显示小贴士
    self:showHelpText()
    -- 开始更新版本
    self:updateVision()

    local wifiType = TFDeviceInfo:getNetWorkType()

    print("--------------------网络类型     =", wifiType)
end

function UpdateLayer_new:removeUI()
    self.super.removeUI(self)
    TFDirector:removeTimer(self.loadingTimeId);
end

function UpdateLayer_new:registerEvents()
    self.super.registerEvents(self)
end

function UpdateLayer_new:removeEvents()
    self.super.removeEvents(self)

    ADD_KEYBOARD_CLOSE_LISTENER(self, self.ui)
end


function UpdateLayer_new:showHelpText()
    if self.TipsList == nil then
        self.TipsList    = require("lua.table.t_s_help_tips")
    end
    local nLen = self.TipsList:length()
    local nIndex = math.random(1, nLen)
    local content = self.TipsList:getObjectAt(nIndex).tips
    
    self.txt_chat:setText(content)
end

function UpdateLayer_new:updateVision()
    local function downloadingRecvData(downloadingSize, totalSize)
        local size1 = math.floor(downloadingSize/1024)
        local size2 = math.floor(totalSize/1024)

        local nRate = (size1 / size2)*100
        if nRate > 100 then
            nRate = 100
        end
        
        nRate  = math.floor(nRate)

        self.bar_load:setPercent(nRate)

        --local desc  = string.format("正在更新，已下载%d%%  (%dKB/%dKB)", nRate, size1, size2)
        local desc  = stringUtils.format(localizable.updateLaye_update_tips, nRate, size1, size2)
        
        self.txt_update:setText(desc)
    end

    local function startUpdate()
        TFClientUpdate:startDownloadZip(downloadingRecvData)
    end

    -- self.bar_update:setPercent(0);
    local function checkNewVersionCallBack()
        local version       =  TFClientUpdate:getCurVersion()
        local LatestVersion =  TFClientUpdate:getLatestVersion()
        local Content       =  TFClientUpdate:GetUpdateContent()
        local totalSize     =  TFClientUpdate:GetTotalDownloadFileSize()

        print("===========find new version===========")
        print("version          = ", version)
        print("LatestVersion    = ", LatestVersion)
        print("Content          = ", Content)
        print("totalSize        = ", totalSize)
        print("=============== end ==================")
        -- TFClientUpdate:startDownloadZip(downloadingRecvData)

        local nTotalSize  = totalSize
        nTotalSize = nTotalSize/1000000
        local desc = "";
        if nTotalSize >= 0.1 then
            desc = string.format(" %0.1fMB", nTotalSize);
        else
            desc = string.format(" %0.1fKB", nTotalSize * 1000);
        end

        --local title = "检测到有新的更新内容，共"..desc
        local title =stringUtils.format(localizable.updatelayerNew_check_new_resource,desc)
        self:OpenUpdateComfirmDiag(title, Content, startUpdate)
    end

    local function StatusUpdateHandle(ret)
        -- body
        print("ret --- ",ret)
        -- 更新完成，或者当前版本已经是最新的了
        if ret == 0 then
            local version       =  TFClientUpdate:getCurVersion()
            local LatestVersion =  TFClientUpdate:getLatestVersion()        
            print("version          = ", version)
            print("LatestVersion    = ", LatestVersion)
            print("---------------更新完成")
            restartLuaEngine("CompleteUpdate")
            return

        elseif ret == 1 then
            print("---------------下载完成准备解压资源")
            --local desc  = "下载完成解压资源"
            local desc = localizable.updatelayerNew_unZip_resource
            self.txt_update:setText(desc)

        elseif ret < 0 then
            print("---------------更新出错")
            self:showFailDiag(1)
        end

    end

    -- versionPath = "http://112.74.111.206/mhqx/beta/newupdate/"       --更新文件检测地址
    -- filePath   = "http://112.74.111.206/mhqx/beta/newupdate/"       --zip下载地址

    print("new--------------------versionPath  = ", versionPath)
    print("new--------------------filePath     = ", filePath)
    TFClientUpdate:CheckUpdate(versionPath, filePath, checkNewVersionCallBack, StatusUpdateHandle)

    local version  =  TFClientUpdate:getCurVersion()
    if  self.txt_version ~= nil then
        --self.txt_version:setText("当前版本:"..version)
        self.txt_version:setText(stringUtils.format(localizable.updatelayerNew_curr_version, version))
    end
end

function UpdateLayer_new:showOperateSureLayer(okhandle,cancelhandle,param)
    param = param or {}

    param.showtype = param.showtype or AlertManager.BLOCK_AND_GRAY_CLOSE;
    param.tweentype = param.tweentype or AlertManager.TWEEN_1;

    param.uiconfig = param.uiconfig or "lua.uiconfig_mango_new.common.OperateSure";


    -- local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.common.OperateSure",param.showtype,param.tweentype);
    local layer = AlertManager:addLayerByFile("lua.logic.common.OperateSure",param.showtype,param.tweentype);
    layer.toScene = Public:currentScene();

    layer:setUIConfig(param.uiconfig);

    layer:setBtnHandle(okhandle, cancelhandle);
    layer:setData(param.data);
    layer:setTitle(param.title);
    layer:setMsg(param.msg);
    layer:setTitleImg(param.titleImg);

    layer:setBtnOkText(param.okText);
    layer:setBtnCancelText(param.cancelText);

    AlertManager:show()

    return layer;
end

-- type == 1检查失败 type == 2 更新失败
function UpdateLayer_new:showFailDiag(errorType)
    --local displayTitle   = "检查资源更新"
    local displayTitle   = localizable.updateLaye_check_resource_update
    --local displayContent = "检查资源更新失败，是否重试"
    local displayContent = localizable.updateLaye_check_resource_update_fail
    
    if errorType and errorType == 2 then
        --displayTitle   = "更新失败"
        displayTitle   = localizable.updateLaye_update_fail

        --displayContent = "资源更新失败，请检查你的网络后重试"
        displayContent = localizable.updateLaye_update_fail_check_net

    end

    local function restart()
        local UpdateLayer_new   = require("lua.logic.login.UpdateLayer_new")
        AlertManager:changeScene(UpdateLayer_new:scene())
    end

    local layer = self:showOperateSureLayer(
                function()
                    AlertManager:closeAll()
                    self.bShowFailDaig = false

                    restart()
                end,
                function()
                    AlertManager:closeAll()
                    self.bShowFailDaig = false
                end,
                {
                    msg = displayContent,
                    showtype = AlertManager.BLOCK_AND_GRAY,
                    title = displayTitle,
                    --okText = "重试",
                    okText = localizable.updateLaye_reset,
                    
                    uiconfig = "lua.uiconfig_mango_new.common.OperateSure2"
                }
    )
    layer.isCanNotClose = true
end

function UpdateLayer_new:EnterGame()


    restartLuaEngine("CompleteUpdate")

end

function UpdateLayer_new:CompleteUpdate()
    if self.timeId == nil then
        local function update(delta)
            me.Director:getScheduler():unscheduleScriptEntry(self.timeId)
            self.timeId = nil
            self:EnterGame()
        end
        self.timeId = me.Scheduler:scheduleScriptFunc(update, 0.5, false)
    end
end

function UpdateLayer_new:playEffect()

    if not self.img_bg then
        return
    end
    if 1 then
        return
    end
    if self.ChooseEffect == nil then
        local resPath = "effect/logineffect.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("logineffect_anim")

        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(self.img_bg:getSize().width/2,self.img_bg:getSize().height/2))

        self.img_bg:addChild(effect, 1)

       
        effect:addMEListener(TFARMATURE_COMPLETE,function()
            -- effect:removeMEListener(TFARMATURE_COMPLETE) 
            -- effect:removeFromParent()
            -- self.ChooseEffect:playByIndex(1, -1, -1, 1)
        end)

        self.ChooseEffect = effect
    end

    self.ChooseEffect:playByIndex(0, -1, -1, 1)
end

function UpdateLayer_new:LoadingEffect()

    if not self.img_bg then
        return
    end

    if self.loading == nil then
        local resPath = "effect/loading.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("loading_anim")

        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(self.img_bg:getSize().width/2, 250))

        -- self.img_bg:addChild(effect, 1)

        self.img_bg:getParent():addChild(effect, 1)

        effect:addMEListener(TFARMATURE_COMPLETE,function()
            -- effect:removeMEListener(TFARMATURE_COMPLETE)
            -- effect:removeFromParent()
            -- self.loading:playByIndex(1, -1, -1, 1)
        end)

        self.loading = effect
    end

    self.loading:playByIndex(0, -1, -1, 1)
    self.loading:setVisible(true)
end

function UpdateLayer_new:OpenUpdateComfirmDiag(title, content, btnHandle)

    print("txt_title = ", title)
    local layer = AlertManager:addLayerByFile("lua.logic.login.UpdateNotice", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)
    layer:setTitle(title)
    layer:setcontent(content)
    layer:setBtnHandle(btnHandle)
    AlertManager:show()
end


return UpdateLayer_new

    -- require('lua.table.TFMapArray')
    -- AlertManager        = require('lua.public.AlertManager')
    -- Public              = require("lua.public.Public")
    -- BaseLayer           = require('lua.logic.BaseLayer')
    -- BaseScene           = require('lua.logic.BaseScene')
    -- SceneType           = require('lua.logic.SceneType');
    -- GameConfig          = require('lua.logic.common.GameConfig');
    -- LoadingLayer        = require("lua.logic.common.AudioFun")
    -- LoadingLayer        = require("lua.logic.common.LoadingLayer")
