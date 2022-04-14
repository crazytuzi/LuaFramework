--
-- Author: LaoY
-- Date: 2018-07-02 09:54:48
--

BasePanel = BasePanel or class("BasePanel", Node)

function BasePanel:ctor()
    self.order_parent_transform = self.parent_node
    self.auto_order_count = 20

    local function call_back()
        self:Close()
    end
    self.open_login_scene_event_id = GlobalEvent:AddListener(LoginEvent.OpenLoginScene, call_back)
end

function BasePanel:dctor()
    -- self:Close()
    if self.background then
        if not poolMgr:AddGameObject("system","EmptyImage",self.background) then
            destroy(self.background)
        end
        self.background = nil
    end

    if self.loading_res then
        self.loading_res:destroy()
        self.loading_res = nil
    end
    self:StopAction()

    if self.open_login_scene_event_id then
        GlobalEvent:RemoveListener(self.open_login_scene_event_id)
        self.open_login_scene_event_id = nil
    end
end

function BasePanel:initDefault()
    return {
        abName = "", -- ab包名字
        assetName = "", -- 资源名字
        layer = "UI", -- 所在层级
        isTop = "", -- 是否在最上层
        is_exist_always = false, -- 是否常驻
        use_background = false, -- 使用半透明黑色背景
        use_camerablur = false, -- 使用高斯模糊 如果只继承 BasePanel,默认会use_background=true
        click_bg_close = false, -- 点击背景关闭
        playSounds = true, -- 播放音乐
        is_loaded = false, -- 是否完成异步加载
        isShow = false, -- 是否要显示
        is_singleton = true, -- 是否为单例界面，是的话，放入LuaPanelManager管理(大部分界面都是单例界面)
        is_hide_other_panel = false, -- 是否隐藏本界面之下的其他界面。只针对layer是"UI"有效
        gameObject = false, -- 根对象
        transform = false, -- 根对象
        transform_find = false, -- transform.Find

        panel_type = 4, -- 界面类型，根据大小排序， 1全屏大界面 2非全屏大界面 3二级界面 4小界面 panel_type == 4,不隐藏主UI

        logout_close = true, -- 切换账号 是否关闭 默认是关闭重新打开

        use_open_sound = true, --是否播放打开界面声音

        is_show_open_action = false, -- 显示打开界面的动画

        auto_order_count = 20,

        is_hide_model_effect = true,
    }
end

-- 打开界面有这个接口
function BasePanel:Open()
    if self.isShow then
        if self.is_loaded then
            self:ResetOrderIndex()
            self:AfterOpen()
        end
        return
    end
    self.isShow = true

    if not self.parent_node then
        self.parent_node = LayerManager:GetInstance():GetLayerByName(self.layer)
    end


    lua_panelMgr:ToOpenPanel(self)
    if self.is_exist_always and self.is_loaded then
        self:SetVisibleInside(true)
        self:OpenPanelAction()
        self:ResetOrderIndex()
        self:AfterOpen()
        return
    end
    if not self.is_loaded then
        local time_id
        local function load_call_back(obj)
            if time_id then
                GlobalSchedule:Stop(time_id)
                time_id = nil
            end 

            if self.loading_res then
                self.loading_res:destroy()
                self.loading_res = nil
            end

            if self.is_dctored then
                return
            end
            -- self:CreatePanel(obj[0])

            if AppConfig.Debug then
                self:CreatePanel(obj[0])
            else
                -- 如果打开界面报错，直接把界面关闭了。防止出现卡死的情况
                local status, err = pcall(self.CreatePanel, self, obj[0])
                if not status then
                    logError(err)
                    self:Close()
                end
            end
        end

        local function step()
            if AppConfig.Debug and PlatformManager and not PlatformManager:GetInstance():IsMobile() then
                self:Close()
            else
                -- 外服10秒界面未打开直接关闭也用安全模式，避免卡死
                local status, err = pcall(self.Close, self)
                if not status then
                    logError(err)
                end
            end

            if self.loading_res then
                self.loading_res:destroy()
                self.loading_res = nil
            end

            local function call_back()
                
            end
            if not IsIOSExamine() and not LoginModel.IsIOSExamine then
                Dialog.ShowOne("Tip","Network is unstable, please check your network","Confirm",call_back)
                DebugLog(self.abName .. " open fail========")
            end

            if time_id then
                GlobalSchedule:Stop(time_id)
                time_id = nil
            end 
        end

        if self.__cname ~= "PreLoadingPanel"  then
            time_id = GlobalSchedule:StartOnce(step,10)
        end
        
        if AppConst.isLoadLocalRes then
            local delay_local_call_back = function()
                --lua_resMgr:LoadPrefab(self, self.abName .. "_prefab", self.assetName, load_call_back)
                lua_resMgr:LoadPrefab(self, self.abName .. "_prefab", self.assetName, load_call_back, nil, Constant.LoadResLevel.Best)
            end
            --延迟1秒容易出事
            GlobalSchedule.StartFunOnce(delay_local_call_back , 0.1)

        else
            lua_resMgr:LoadPrefab(self, self.abName .. "_prefab", self.assetName, load_call_back, nil, Constant.LoadResLevel.Best)
        end
         --local function step()
         --    if self.is_dctored then
         --        return
         --    end
         --
         --    if AppConst.isLoadLocalRes then
         --        lua_resMgr:LoadPrefab(self, self.abName .. "_prefab", self.assetName, load_call_back, nil, Constant.LoadResLevel.Best)
         --    else
         --        lua_resMgr:LoadPrefab(self, self.abName .. "_prefab", self.assetName, load_call_back, nil, Constant.LoadResLevel.Best)
         --    end
         --end
         --GlobalSchedule:StartOnce(step,3.0)

        if self.__cname ~= "PreLoadingPanel" and  lua_resMgr:IsInDownLoadList(GetRealAssetPath(self.abName .. "_prefab")) then
           -- logError(self.__cname)
             self.loading_res = LoadingResItem(self.parent_node)
             self.loading_res:SetCloseCallBack(handler(self,self.Close),self.__cname)
             DebugLog("===LoadingResItem" .. self.loading_res._id)
         end

        --
    else
        -- 
        self:SetVisibleInside(true)
        self:OpenPanelAction()
        self:ResetOrderIndex()
        self:AfterOpen()
    end

end

function BasePanel:CreatePanel(obj)
    if obj == nil then
        self:destroy()
        return
    end
    if self.gameObject then
        return
    end
    logWarn("===>打开界面：", self.__cname)

    if self.use_open_sound then
        SoundManager:GetInstance():PlayById(6)
    end

    self.is_loaded = true
    self.gameObject = newObject(obj)
    self.transform = self.gameObject.transform
    self.transform_find = self.transform.Find

    self.gameObject.name = self.assetName
    SetChildLayer(self.transform, LayerManager.BuiltinLayer.UI)
    --local layer = LayerManager:GetInstance():GetLayerByName(self.layer)
    self.transform:SetParent(self.parent_node)

    -- C#那边已经初始化默认 scale rotation localposition
    SetLocalPosition(self.transform, 0, 0, 0)
    SetLocalScale(self.transform, 1)
    SetLocalRotation(self.transform, 0, 0, 0)


    -- bg con
    self.bg_con_gameObject = GameObject("bg_con_con")
    self.bg_con_transform = self.bg_con_gameObject.transform
    self.bg_con_transform:SetParent(self.transform)
    SetLocalPosition(self.bg_con_transform, 0, 0, 0)
    SetLocalScale(self.bg_con_transform)
    self.bg_con_transform:SetAsFirstSibling()

    self.child_gameObject = GameObject("child_con")
    self.child_transform = self.child_gameObject.transform
    self.child_transform:SetParent(self.transform)
    SetLocalPosition(self.child_transform, 0, 0, 0)
    SetLocalScale(self.child_transform)
    self.child_transform:SetAsLastSibling()

    if self.use_background or self.use_camerablur then
        self.background = PreloadManager:GetInstance():CreateWidget("system", "EmptyImage")
        self.background_transform = self.background.transform
        -- self.background_transform:SetParent(self.bg_con_transform)
        self.background_transform:SetParent(self.transform)
        self.background_transform:SetAsFirstSibling()
        self.background_img = self.background_transform:GetComponent('Image')
        SetSizeDelta(self.background_transform, ScreenWidth + 20, ScreenHeight + 20)-- 扩大点
        -- SetColor(self.background_img, 0, 0, 0, 127.5)
        SetLocalPosition(self.background_transform, 0, 0, 0)
        SetLocalScale(self.background_transform)

        local function call_back()
            -- 打开界面动画过程中不能点击关闭
            if self.open_panel_action and not self.open_panel_action:isDone() then
                return
            end
            self:Close()
        end
        if self.click_bg_close then
            AddButtonEvent(self.background, call_back)
        end
    end

    if not self.isShow then
        self:SetVisibleInside(false)
        return
    end

    if self.use_camerablur then
        self:SetCameraBlur()
    end

    if self.layer == LayerManager.LayerNameList.UI then
        -- local index = lua_panelMgr:GetPanelOrderIndex(self)
        lua_panelMgr:SortUIPanel()
    end

    -- if self.isVisible ~= nil then
    --     self:SetVisible(self.isVisible)
    -- end

    -- self:SetOrderByParentMax()

    -- if self.order_index ~= nil then
    --     self:SetOrderIndex(self.order_index)
    -- end

    self:ResetOrderIndex()

    local function step()
        if self.is_dctored then
            return
        end
        self:OpenPanelAction()
        self:AfterCreate()
        self:AfterOpen()
    end
    step()

    -- time_id = GlobalSchedule:StartOnce(step,0)
end

function BasePanel:GetOpenPanelActionConfig()
    return {
        {
            action_name = "CallFunc",
            param = function()
                if self.background_img then
                    SetAlpha(self.background_img, 0)
                end
            end,
        },
        {
            action_name = "ScaleTo",
            param = { 0.05, 1.02 },
        },
        {
            action_name = "ScaleTo",
            param = { 0.05, 0.96 },
        },
        {
            action_name = "ScaleTo",
            param = { 0.05, 1 },
        },
        {
            action_name = "DelayTime",
            param = 0,
        },
        {
            action_name = "CallFunc",
            param = function()
                if self.background_img then
                    SetAlpha(self.background_img, 1)
                end
            end,
        },
    }
end

function BasePanel:OpenPanelAction()
    if not self.is_show_open_action and self.panel_type ~= 3 then
        return
    end
    local config = self:GetOpenPanelActionConfig()
    if not config then
        return
    end
    self:StopAction()
    local action
    local len = #config
    for i = 1, len do
        local cf = config[i]
        local cur_action
        if type(cf.param) == "table" then
            cur_action = cc[cf.action_name](unpack(cf.param))
        else
            cur_action = cc[cf.action_name](cf.param)
        end
        if not action then
            action = cur_action
        else
            action = cc.Sequence(action, cur_action)
        end
    end
    self.open_panel_action = action
    cc.ActionManager:GetInstance():addAction(action, self.transform)
end

function BasePanel:ClosePanelAction()
    self:StopAction()
end

function BasePanel:StopAction()
    if self.transform then
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
    end
    self.open_panel_action = nil
end

function BasePanel:AfterCreate()
    self:LoadCallBack()
end

function BasePanel:AfterOpen()
    self:OpenCallBack()
end

function BasePanel:SetCameraBlur()
    if self.background_transform then
        -- lua_panelMgr:CameraBlur(self,self.background_transform)
    end
end

-- 关闭界面用这个接口
-- 背包等频繁打开的界面自行重载这个方法，关闭不销毁，只是隐藏界面
function BasePanel:Close()
    if self.is_dctored then
        return
    end
    lua_panelMgr:ToClosePanel(self)
    if not self.is_exist_always then
        self.isShow = false
        self:CloseCallBack()
        -- lua_panelMgr:ToClosePanel(self)
        self:destroy()
    else
        self.isShow = false
        self:SetVisibleInside(false)
    end
end

-- 内部使用的方法，外部千万不要用
function BasePanel:SetVisibleInside(flag)
    if self.is_loaded then
        if IsNil(self.gameObject) then
            return
        end
        if self.gameObject.activeSelf == flag then
            return
        end
        self.gameObject:SetActive(flag)
        if flag then
            self:OnEnable()
        else
            self:OnDisable()
        end
    end
end

-- 显示子窗口
function BasePanel:PopUpChild(node)
    if node then
        if self.child_node ~= nil and self.child_node ~= node then
            self.child_node:SetVisible(false)
        end
        self.child_node = node
        self.child_node:SetVisible(true)
    end
end

function BasePanel:ResetOrderIndex()
    -- if self.__cname == "WakePanel" then
    --     return
    -- end
    if not self.transform then
        return
    end
    local new_order_index = lua_panelMgr:GetPanelOrderIndex(self)
    local cur_index, node = LayerManager:GetInstance():GetTransformOrderIndex(self.transform)
    if node and cur_index == new_order_index then
        return
    end
    if not node then
        if not self.order_parent_transform then
            local parent_transform, parent_order_index = self:GetParentOrderIndex()
            self.order_parent_transform = parent_transform
        end
        self:SetOrderIndex(new_order_index)
        return
    end
    LayerManager:GetInstance():ResetPanelOrderIndex(self.transform, new_order_index)
end

function BasePanel:SetPositionZ(z)
    if self.is_loaded then
        SetLocalPositionZ(self.transform, z)
    end
end

-- overwrite
function BasePanel:LoadCallBack()
    logWarn(string.format("%s 界面要重写 LoadCallBack方法", self.assetName))
end

-- overwrite
function BasePanel:OpenCallBack()
    logWarn(string.format("%s 界面要重写 OpenCallBack方法", self.assetName))
end

-- overwrite
function BasePanel:CloseCallBack()
    logWarn(string.format("%s 界面要重写 CloseCallBack方法", self.assetName))
end

function BasePanel:GetNode(node)
    return self[node]
end
