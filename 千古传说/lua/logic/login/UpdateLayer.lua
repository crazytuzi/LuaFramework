local UpdateLayer = class("UpdateLayer", BaseLayer)
CREATE_SCENE_FUN(UpdateLayer)
CREATE_PANEL_FUN(UpdateLayer)

local updatePath = "http://192.168.1.27:8080/update/"

local TFClientUpdate = TFClientResourceUpdate:instance()

function UpdateLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.login.UpdateLayer")
end

function UpdateLayer:initUI(ui)
    self.super.initUI(self,ui)

    self.errors = {[HL_NOENOUGH_STORAGE_ERR]=localizable.update_error_storage,
                [HL_REQUEST_VERSION_ERR]=localizable.update_error_req_ver,
                [HL_PARSE_VERSION_ERR]=localizable.update_error_parse_ver,
                [HL_FIND_VERSION_ERR]=localizable.update_error_version}

    self.txt_chat = TFDirector:getChildByPath(ui, 'txt_chat')
    local index     = 1;
    local timeCount = 1;
    local loadingStr = "";
    local function change()
        --动态显示小贴士
        timeCount = timeCount + 1
        if timeCount > 10 then
            timeCount = 1
            self:showHelpText()
        end
    end
    self.loadingTimeId = TFDirector:addTimer(500, -1, nil, change)

    self.bar_load = TFDirector:getChildByPath(ui, 'bar_load')
    self.txt_update = TFDirector:getChildByPath(ui, 'txt_update')
    self.bar_load:setPercent(0)
    self.txt_update:setText(localizable.updateLaye_check_resource)

    local function updateStateCallback(nState, nResult)
        if nResult ~= HL_NULL then
            -- 更新资源出错
            TFDirector:removeTimer(self.updateId)
            if (nResult == HL_REQUEST_VERSION_ERR) then
                restartLuaEngine("CompleteUpdate")
            else
                self:showError(nResult)
            end
        else
            if nState == HL_ENTERGAME then
                restartLuaEngine("CompleteUpdate")
            elseif nState == HL_COMPLETION then
                -- 更新完成
                TFClientUpdate:enterGame()
            elseif nState == HL_DOWNLOAD then
                local wifiType = TFDeviceInfo:getNetWorkType()
                if wifiType then
                    if wifiType == "WIFI" then
                        print("Wifi环境下直接更新")
                        self:startUpdate()
                    elseif wifiType == "NO" then
                        print("没有网络")
                        self:showNoNetwork()
                    else
                        local nTotalSize = TFClientUpdate:getTotalSize()
                        local desc = self:convertSize(nTotalSize)
                        self:showUpdateTips(desc)
                    end
                else
                    print("Windows环境下直接更新")
                    self:startUpdate()
                end
            elseif nState == HL_UNZIP then
                TFDirector:removeTimer(self.updateId)
                -- 解压更新包
                self.bar_load:setPercent(100)
                self.txt_update:setText(localizable.updatelayerNew_unZip_resource)
                local delayTimer = TFDirector:addTimer(1000,1,nil,function ()
                    TFDirector:removeTimer(delayTimer)
                    delayTimer = nil
                    TFClientUpdate:unzipFile()
                end)
            end
        end
    end

    -- 开始更新版本
    local delayUpdate = TFDirector:addTimer(1000,1,nil,function ()
        TFDirector:removeTimer(delayUpdate)
        delayUpdate = nil
        self:updateVision(updateStateCallback)
    end)
end

function UpdateLayer:removeUI()
    self.super.removeUI(self)
    TFDirector:removeTimer(self.loadingTimeId)
    TFDirector:removeTimer(self.updateId)
end

function UpdateLayer:registerEvents()
    self.super.registerEvents(self)
end

function UpdateLayer:removeEvents()
    self.super.removeEvents(self)
    ADD_KEYBOARD_CLOSE_LISTENER(self, self.ui)
end

function UpdateLayer:showHelpText()
    if self.TipsList == nil then
        self.TipsList    = require("lua.table.t_s_help_tips")
    end
    local nLen = self.TipsList:length()
    local nIndex = math.random(1, nLen)
    local content = self.TipsList:getObjectAt(nIndex).tips
    
    self.txt_chat:setText(content)
end

function UpdateLayer:updateVision(updateStateCallback)
    TFClientUpdate:checkUpdate(updatePath, updateStateCallback)
end

function UpdateLayer:restart()
    local UpdateLayer = require("lua.logic.login.UpdateLayer")
    AlertManager:changeScene(UpdateLayer:scene())
end

function UpdateLayer:startUpdate()
    local function updateHandle()
        -- 下载更新包
        local totalSize = TFClientUpdate:getTotalSize()
        local recvSize = TFClientUpdate:getReceiveSize()
        local percent = recvSize == 0 and 0 or recvSize * 100.0 / totalSize
        self.bar_load:setPercent(percent)
        percent = math.ceil(percent)
        local size1 = math.floor(recvSize/1024)
        local size2 = math.floor(totalSize/1024)
        local desc = stringUtils.format(localizable.updateLaye_update_tips, percent, size1, size2)
        self.txt_update:setText(desc)
    end
    self.updateId = TFDirector:addTimer(50, -1, nil, updateHandle)

    TFClientUpdate:startUpdate()
end

function UpdateLayer:showNoNetwork()
    local layer = self:showOperateSureLayer(
        function()
             AlertManager:closeAll()
             self:restart()
        end,
        nil,
        {
            msg = localizable.update_error_no_network,
            title = localizable.common_wrong,
            showtype = AlertManager.BLOCK_AND_GRAY,
            okText = localizable.updateLaye_update_confirm,
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure2"
        }
    )
    layer.isCanNotClose = true
end

function UpdateLayer:showError(nResult)
    local layer = self:showOperateSureLayer(
        function()
             AlertManager:closeAll()
             self:restart()
        end,
        nil,
        {
            msg = self.errors[nResult],
            title = localizable.common_wrong,
            showtype = AlertManager.BLOCK_AND_GRAY,
            okText = localizable.updateLaye_update_confirm,
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure2"
        }
    )
    layer.isCanNotClose = true
end

function UpdateLayer:showUpdateTips(desc)
    local layer = self:showOperateSureLayer(
        function()
            print("开始更新")
            self:startUpdate()
        end,
        function()
            print("取消更新")
            AlertManager:closeAll()
            toastMessage(localizable.updateLaye_update_fail)
        end,
        {
            --msg = "检测到新资源，共计".. desc .. "\n\n是否马上更新？" ,
            msg = stringUtils.format(localizable.updateLaye_update_desc, desc),
            --title = "更新资源啦",
            title = localizable.updateLaye_update_lala,
            showtype = AlertManager.BLOCK_AND_GRAY,
            --okText = "更新",
            okText = localizable.updateLaye_update_ok,
            uiconfig = "lua.uiconfig_mango_new.common.OperateSure2"
        }
    )
    layer.isCanNotClose = true
end

function UpdateLayer:showOperateSureLayer(okhandle,cancelhandle,param)
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

function UpdateLayer:convertSize(size)
    local tempSize = size / 1000000
    local desc = ""
    if tempSize >= 0.1 then
        desc = string.format(" %0.1fMB", tempSize)
    else
        desc = string.format(" %0.1fKB", tempSize * 1000)
    end
    return desc
end

return UpdateLayer