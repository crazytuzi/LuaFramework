-- -----------------------
-- 剧情控制
-- hosr
-- -----------------------
DramaModel = DramaModel or BaseClass(BaseModel)

function DramaModel:__init()
    self.buttonArea = nil
    self.normalActionModel = nil
    self.specialActionModel = nil
    self.initModel = nil
    self.dramaMask = nil
    self.dramaButton = nil
    self.singlePlotModel = nil

    self.multiUnitList = {}

    -- 记录当前执行到的剧情did
    self.currentActionId = 0

    --创建加载wrapper
    self.assetWrapper = AssetBatchWrapper.New()
    self.resList = {
        {file = AssetConfig.drama_canvas, type = AssetType.Main},
    }

    local func = function()
        if self.assetWrapper == nil then return end
        self.dramaCanvas = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.drama_canvas))
        self.dramaCanvas.name = "DramaCanvas"
        UIUtils.AddUIChild(ctx.CanvasContainer, self.dramaCanvas)
        self.dramaCanvas.transform.localPosition = Vector3(0, 0, -1000)

        self.dramaMask = DramaMask.New(self)
        self.dramaMask:Show()

        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
    self.assetWrapper:LoadAssetBundle(self.resList, func)

    self.currentDramaData = nil

    self.onSceneLoad = function() self:OnSceneLoad() end
    self.onBeginFight = function() self:BeginFight() end
    EventMgr.Instance:AddListener(event_name.scene_load, self.onSceneLoad)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.onBeginFight)

    self.hideList = {}
end

function DramaModel:__delete()
    if self.normalActionModel ~= nil then
        self.normalActionModel:DeleteMe()
        self.normalActionModel = nil
    end
    if self.specialActionModel ~= nil then
        self.specialActionModel:DeleteMe()
        self.specialActionModel = nil
    end
    if self.dramaMask ~= nil then
        self.dramaMask:DeleteMe()
        self.dramaMask = nil
    end
end

-- 登录上来初始化剧情场景
function DramaModel:InitDrama(dramaData)
    if self.initModel == nil then
        self.initModel = DramaActionModel.New(function() self:DramaInitComplete() end)
    end
    self.initModel:BeginActions(dramaData.action_list)
end

function DramaModel:DramaInitComplete()
    self.initModel:DeleteMe()
    self.initModel = nil
    DramaManager.Instance.IsInit = true
    if DramaManager.Instance.InitFlag == 0 then
        DramaManager.Instance:Send11000()
        RoleManager.Instance:send10008()
    elseif DramaManager.Instance.InitFlag == 1 then
        DramaManager.Instance:Send11000()
    elseif DramaManager.Instance.InitFlag == 2 then
        --清空剧情数据
    end
end

-- ---------------------------------
-- 剧情开始之前和结束之后处理
-- ---------------------------------
function DramaModel:HideOtherPlayer(bool)
end

function DramaModel:HidePet(bool)
end

function DramaModel:HideNpc(bool)
end

function DramaModel:HideMainUI(bool)
end

-- --------------------------------
-- 剧情开始
-- --------------------------------
function DramaModel:BeginDrama(dramaData)
    self.multiUnitList = {}
    GestureManager.Instance:SoBusy()

    DramaManager.Instance.dramaGuide = false
    if dramaData.id == 0 then
        if self.specialActionModel == nil then
            self.specialActionModel = DramaActionModel.New(function(arg) self:EndSpecialDrama(arg) end)
        end
        self.specialActionModel:BeginActions(dramaData.action_list)
    else
        self.currentDramaData = dramaData
        if self.normalActionModel == nil then
            self.normalActionModel = DramaActionModel.New(function(arg) self:EndNormalDrama(arg) end)
        end
        if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
            SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
            SceneManager.Instance.sceneElementsModel.self_data.canIdle = false
        end
        RoleManager.Instance.RoleData.drama_status = RoleEumn.DramaStatus.Running
        self.normalActionModel:BeginActions(dramaData.action_list)
    end
end

function DramaModel:HideMain()
    TipsManager.Instance.model:Closetips()
    MainUIManager.Instance:HideDialog()
    -- MainUIManager.Instance:ShowMainUI(false)
    -- ChatManager.Instance.model:HideChatMini()
    self.dramaMask.gameObject:SetActive(true)
    NoticeManager.Instance:HideAutoUse()
    -- SceneManager.Instance.sceneElementsModel:Show_Npc(false)
    -- self:HideCurrentWindow()
    self:HideOtherUI()
    SceneManager.Instance.sceneElementsModel:Show_OtherRole(false)
    SceneManager.Instance.sceneElementsModel:Show_Self(true)
end

-- -----------------------------------------------------------------------
-- 正常剧情结束,看情况是否要向服务端请求下一步
-- 或者播放缓存中的剧情(就怕他剧情播放中有来了个配置剧情)
-- -----------------------------------------------------------------------
function DramaModel:EndNormalDrama(allover)
    if not allover then
        if self.normalActionModel ~= nil and self.normalActionModel.currentActionData ~= nil then
            -- print("DramaModel:EndNormalDrama ---- request 11001")
            DramaManager.Instance:Send11001(self.normalActionModel.currentActionData.id, 0)
        else
            -- print("DramaModel:EndNormalDrama ---- action = nil go to over")
            self:EndDrama()
        end
    else
        -- print("DramaModel:EndNormalDrama ---- allover")
        self:EndDrama()
    end
end

-- -----------------------------------------------------------------------
-- ID为0的非配置的剧情结束，销毁就行了，比如任务触发创建删除单位的剧情
-- -----------------------------------------------------------------------
function DramaModel:EndSpecialDrama()
    if self.specialActionModel ~= nil then
        self.specialActionModel:DeleteMe()
        self.specialActionModel = nil
    end
end

-- -----------------------
-- 剧情播放完毕，善后处理
-- -----------------------
function DramaModel:EndDrama()
    -- 清除当前用到的动作资源
    -- print("DramaModel:EndDrama")
    if self.dramaButton ~= nil then
        self.dramaButton:DeleteMe()
        self.dramaButton = nil
    end
    if self.normalActionModel ~= nil then
        self.normalActionModel:DeleteMe()
        self.normalActionModel = nil
    end
    DramaSceneTalk.Instance:DramaEnd()
    -- DramaActionFactory.Instance:Destroy()
    RoleManager.Instance.RoleData.drama_status = RoleEumn.DramaStatus.None
    -- MainUIManager.Instance:ShowMainUI(true)
    if not DramaManager.Instance.dramaGuide then
        -- 引导的剧情，不能重开界面，因为引导要关闭界面
        -- self:ShowCurrentWindow()
    end
    self:ShowUIHided()
    -- ChatManager.Instance.model:ShowChatMini()
    self.dramaMask.gameObject:SetActive(false)
    SceneManager.Instance.sceneElementsModel:Show_Self(true)
    SceneManager.Instance.sceneElementsModel:Show_OtherRole(true)
    SceneManager.Instance.sceneElementsModel:Show_Self_Weapon(true)
    SceneManager.Instance.MainCamera.lock = false
    SceneManager.Instance.sceneElementsModel.self_data.canIdle = true
    SceneManager.Instance.sceneElementsModel:Show_Npc(true)
    -- 检查是否有自动跑的任务
    QuestManager.Instance.autoRun = true
    NoticeManager.Instance:ShowAutoUse()
    self.multiUnitList = {}

    --特殊某个剧情打开新手装备获得的弹窗 jia
    local showData = DataQuest.data_show_reward
    for _,data in pairs(showData) do
        if BaseUtils.ContainValueTable(data.plot_id,self.currentDramaData.id) then
            QuestManager.Instance.model:OpenShowEquipPanel(data.id)
        break
    end
   end
end

-- 剧本中跳过剧本
function DramaModel:CanJump()
    if self.currentDramaData ~= nil then
        self:ShowJump(self.currentDramaData.can_skip == 1)
    else
        self:ShowJump(false)
    end
end

function DramaModel:ShowJump(bool)
    if self.dramaButton == nil then
        self.dramaButton = DramaButton.New(self)
        self.dramaButton:Show(bool)
    else
        self.dramaButton:ShowJump(bool)
    end
end

-- 对话中点击下一步
function DramaModel:ClickNext()
    if true then
    end
end

-- 内心独白，不归剧情流程管
function DramaModel:Feeling(actionData)
    local func = function()
        if self.feeling ~= nil then
            self.feeling:DeleteMe()
            self.feeling = nil
        end
    end

    if self.feeling == nil then
        self.feeling = DramaFeeling.New()
    end
    self.feeling.callback = func
    self.feeling:Show(actionData)
end

function DramaModel:OnSceneLoad()
    -- 第一次进入，为进场做准备
    if LoginManager.Instance.first_enter then
        -- LoginManager.Instance.first_enter = false
        -- self:HideMain()
        -- self:JustPlayPlot(9020, function() self:FirstEnterDeal() end)
        -- local c1 = 10/255
        -- for i,a in ipairs(SceneManager.Instance:GetMapCell()) do
        --     a.sharedMaterial.color = Color(c1, c1, c1)
        -- end
        -- self.dramaMask:BlackPanel(true)
    end
end

-- 外部调用播放非剧情剧本
function DramaModel:JustPlayPlot(plotId, callback)
    if self.singlePlotModel == nil then
        self.singlePlotModel = PlotModelSingle.New(function() self:JustPlayPlotEnd(callback) end)
    end
    self.singlePlotModel:BeginPlot(plotId)
end

function DramaModel:JustPlayPlotEnd(callback)
    if self.singlePlotModel ~= nil then
        self.singlePlotModel:DeleteMe()
        self.singlePlotModel = nil
        -- DramaActionFactory.Instance:Destroy()
    end

    if callback ~= nil then
        callback()
        callback = nil
    end
end

-- 断线重连用
function DramaModel:Clear()
    if self.dramaButton ~= nil then
        self.dramaButton:DeleteMe()
        self.dramaButton = nil
    end
    if self.normalActionModel ~= nil then
        self.normalActionModel:DeleteMe()
        self.normalActionModel = nil
    end
    if self.specialActionModel ~= nil then
        self.specialActionModel:DeleteMe()
        self.specialActionModel = nil
    end
    if self.singlePlotModel ~= nil then
        self.singlePlotModel:DeleteMe()
        self.singlePlotModel = nil
    end
    if self.feeling ~= nil then
        self.feeling:DeleteMe()
        self.feeling = nil
    end
    RoleManager.Instance.RoleData.drama_status = RoleEumn.DramaStatus.None
    if self.dramaMask ~= nil then
        self.dramaMask.gameObject:SetActive(false)
    end
    QuestManager.Instance.autoRun = false
    SceneManager.Instance.MainCamera.lock = false
end

-- 临时隐藏或显示当前面板
function DramaModel:ShowCurrentWindow()
    if self.hideWindow ~= nil then
        self.hideWindow:Open()
        self.hideWindow = nil
    end
end

function DramaModel:HideCurrentWindow()
    if WindowManager.Instance.currentWin ~= nil and WindowManager.Instance.currentWin.gameObject ~= nil and WindowManager.Instance.currentWin.gameObject.activeSelf then
        self.hideWindow = WindowManager.Instance.currentWin
        self.hideWindow:Hide()
    end
end

function DramaModel:HideOtherUI()
    -- print("DramaModel:HideOtherUI")
    local len = ctx.CanvasContainer.transform.childCount
    for i = 1, len do
        local child = ctx.CanvasContainer.transform:GetChild(i - 1)
        local childObj = child.gameObject
        if childObj.name ~= "DramaCanvas" and childObj.name ~= "DramaButton" and childObj.name ~= "NoticeCanvas" and childObj.name ~= "TipsCanvas" and childObj.name ~= "MainUICanvasView" and childObj.name ~= "ChatCanvas" and childObj.activeSelf then
            childObj:SetActive(false)
            table.insert(self.hideList, childObj)
        end
    end
    ChatManager.Instance.model:ShowCanvas(false)
    MainUIManager.Instance:ShowMainUICanvas(false)
end

function DramaModel:ShowUIHided()
    -- print("DramaModel:ShowUIHided")
    for i,obj in ipairs(self.hideList) do
        if not BaseUtils.is_null(obj) then
            obj:SetActive(true)
        end
    end
    self.hideList = {}
    -- ChatManager.Instance.model.chatCanvas:SetActive(true)
    ChatManager.Instance.model:ShowCanvas(true)
    MainUIManager.Instance:ShowMainUICanvas(true)
    self.dramaMask.gameObject:SetActive(false)
end

function DramaModel:BeginFight()
    if RoleManager.Instance.RoleData.drama_status == RoleEumn.DramaStatus.Running then
        ChatManager.Instance.model:ShowChatMini()
    end
end

function DramaModel:FirstEnterDeal()
    self:EndDrama()
    GuideManager.Instance:Start(10000)
end

function DramaModel:ShowAllUnit()
    SceneManager.Instance.sceneElementsModel:Show_Self(true)
    SceneManager.Instance.sceneElementsModel:Show_OtherRole(true)
    SceneManager.Instance.sceneElementsModel:Show_Self_Weapon(true)
    SceneManager.Instance.MainCamera.lock = false
    SceneManager.Instance.sceneElementsModel.self_data.canIdle = true
    SceneManager.Instance.sceneElementsModel:Show_Npc(true)
end

function DramaModel:JumpPlot()
    if self.normalActionModel ~= nil then
        self.normalActionModel:OnJump()
    end
    for _,dramaAction in ipairs(self.multiUnitList) do
        -- 删除批量同步创建的单位
        DramaVirtualUnit.Instance:RemoveUnit(dramaAction)
    end
end

function DramaModel:AutoNextStep()
end