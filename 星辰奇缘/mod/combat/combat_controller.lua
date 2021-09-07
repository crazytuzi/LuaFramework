-- 战斗控制器
CombatController = CombatController or BaseClass()

local GameObject = UnityEngine.GameObject
function CombatController:__init(combatID)
    MemoryCheckTable[self] = Time.time
    self.combatID = combatID
    self.combatMgr = CombatManager.Instance
    self.combatMgr.controller = self
    self.assetWrapper = self.combatMgr.assetWrapper

    self.enterData = self.combatMgr.enterData
    self.selfData = nil
    self.selfPetData = nil
    self.selfFighter = nil
    self.selfPet = nil
    self.accountInfo = RoleManager.Instance.RoleData
    self.transform = nil
    self.combatCamera = nil
    self.brocastCtx = BrocastContext.New(self)
    self.mainPanel = CombatMainPanel.New()
    self.mainPanel.controller = self
    self.mainUITransform = {}
    self.map = nil
    self.SceneElements = nil
    self.SceneLoaded = false
    self.loadstatus = true -- 战斗初始化异常标志 false 为出错

    self.eastFighterList = {}
    self.westFighterList = {}
    -- GameObject
    self.MiddleWestPoint = nil
    self.MiddleEastPoint = nil

    self.skillareaPath = AssetConfig.combat_skillareaPath
    self.headinfoareaPath = AssetConfig.combat_headinfoareaPath
    self.counterinfoareaPath = AssetConfig.combat_counterinfoareaPath
    self.mixareaPath = AssetConfig.combat_mixareaPath
    self.functioniconPath = AssetConfig.combat_functioniconPath
    self.mainPanelPath = AssetConfig.combat_mainPanelPath
    self.extendPath = AssetConfig.combat_extend_path

    self.resources = nil

    self.roleTemp = nil
    self.npcTemp = nil

    self.transition = nil

    self.keepUiList = {"MainUICanvasView", "ChatCanvas", "MainUIIconView", "FPS", "MainUIIconView", "MainuiTracePanel", "TipsCanvas", "NoticeCanvas"}
    self.hideUiList = {
    "MapInfoView",
    "RoleInfoView",
    "ButtonPanel3",
    "ButtonPanel2",
    "PetInfoView",
    "PlayerInfoView",
    -- "MainuiNoticeView",
    "BaseCanvas",
    "Console",
    "DramaCanvas",
    "DramaButton",
    "TreasuremapCompassView",
    "GuildDungeonBossTitle",
    }
    if BaseUtils.IsVerify then
        table.insert( self.hideUiList, "ChatCanvas")
    end

    self.forceSwitch = {
    "MapInfoView",
    "RoleInfoView",
    "PetInfoView",
    }
    
    -- self.combatMgr.isFighting = true
    self.teamquestPanel = nil

    self.mainCamera = nil
    self.mainCameraPos = nil

    self.fightResult = 0 -- 0 失败; 1 成功
    self.combatMgr.FireEndFightScene = false

    -- 战斗类型
    self.CombatFightType = CombatFightType.PVE

    self.npcResCacheList = {}
    self.uiResCacheList = {}
    self.rubbishList = {}

    self.combatSceneGo = {}

    self.guidenceStr = nil

    self.creatTime = os.clock()
    self:AfterInit()

    self.isdestroying = false
end

function CombatController:__delete()
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
        self.combatMgr.assetWrapper = nil
    end
    if self.brocastCtx ~= nil then
        self.brocastCtx:DeleteMe()
        self.brocastCtx = nil
    end
    if self.mainPanel ~= nil then
        self.mainPanel:DeleteMe()
        self.mainPanel = nil
    end
    self.combatMgr.controller = nil
end

function CombatController:Show(combatID)
    self.combatID = combatID
    self.combatMgr = CombatManager.Instance
    self.combatMgr.controller = self
    self.assetWrapper = self.combatMgr.assetWrapper

    self.enterData = self.combatMgr.enterData
    self.selfData = nil
    self.selfPetData = nil
    self.selfFighter = nil
    self.selfPet = nil
    self.accountInfo = RoleManager.Instance.RoleData
    self.transform = nil
    self.brocastCtx = BrocastContext.New(self)
    self.mainPanel.controller = self

    self.mainUITransform = {}
    self.SceneLoaded = false

    self.eastFighterList = {}
    self.westFighterList = {}
    -- GameObject
    -- self.MiddleWestPoint = nil
    -- self.MiddleEastPoint = nil

    self.skillareaPath = AssetConfig.combat_skillareaPath
    self.headinfoareaPath = AssetConfig.combat_headinfoareaPath
    self.counterinfoareaPath = AssetConfig.combat_counterinfoareaPath
    self.mixareaPath = AssetConfig.combat_mixareaPath
    self.functioniconPath = AssetConfig.combat_functioniconPath
    self.mainPanelPath = AssetConfig.combat_mainPanelPath
    self.extendPath = AssetConfig.combat_extend_path

    self.resources = nil

    -- self.roleTemp = nil
    -- self.npcTemp = nil

    -- self.transition = nil

    self.keepUiList = {"MainUICanvasView", "ChatCanvas", "MainUIIconView", "FPS", "MainUIIconView", "MainuiTracePanel", "TipsCanvas", "NoticeCanvas"}
    self.hideUiList = {
    "MapInfoView",
    "RoleInfoView",
    "ButtonPanel3",
    "ButtonPanel2",
    "PetInfoView",
    "PlayerInfoView",
    -- "MainuiNoticeView",
    "BaseCanvas",
    "Console",
    "DramaCanvas",
    "DramaButton",
    "TreasuremapCompassView",
    "GuildDungeonBossTitle",
    }
    if BaseUtils.IsVerify then
        table.insert( self.hideUiList, "ChatCanvas")
    end

    self.forceSwitch = {
    "MapInfoView",
    "RoleInfoView",
    "PetInfoView",
    }

    self.fightResult = 0 -- 0 失败; 1 成功
    self.combatMgr.FireEndFightScene = false

    -- 战斗类型
    self.CombatFightType = CombatFightType.PVE

    self.npcResCacheList = {}
    self.uiResCacheList = {}
    self.rubbishList = {}

    self.combatSceneGo = {}

    self.guidenceStr = nil

    self.creatTime = os.clock()
    self.CombatScene:SetActive(true)
    self:AfterInit()
    self.isdestroying = false
end

function CombatController:AfterInit()
    self:CreatCombatScene()
    self.transform = Vector3(1000,1000,0)
    local success = self:InitSelfData()
    if not success then
        self.SceneLoaded = true
        self:EndOfCombat()
        return
    end

    self.combatCameraPosition = self.combatCamera.gameObject.transform.position
    if self.MiddleWestPoint == nil then
    self.MiddleWestPoint = GameObject()
        GameObject.DontDestroyOnLoad(self.MiddleWestPoint)
        table.insert(self.combatSceneGo, self.MiddleWestPoint)
        self.MiddleWestPoint.name = "MiddleWestPoint"
        self.MiddleWestPoint.transform.localScale = Vector3(1, 1, 1)
        self.MiddleWestPoint.transform.position = Vector3(0, 0, 0)
        self.MiddleEastPoint = GameObject()
        GameObject.DontDestroyOnLoad(self.MiddleEastPoint)
        self.MiddleEastPoint.name = "MiddleEastPoint"
        table.insert(self.combatSceneGo, self.MiddleEastPoint)
        self.MiddleEastPoint.transform.localScale = Vector3(1, 1, 1)
        self.MiddleEastPoint.transform.position = Vector3(0, 0, 0)

        local WestPointTmp = CombatUtil.GridToPosition(CombatUtil.WestPoint()[8].pos[1], CombatUtil.WestPoint()[8].pos[2])
        local EastPointTmp = CombatUtil.GridToPosition(CombatUtil.EastPoint()[8].pos[1], CombatUtil.EastPoint()[8].pos[2])
        self.MiddleWestPoint.transform.position = CombatUtil.GetBehindPoint2(EastPointTmp, WestPointTmp, FighterLayout.WEST, (500 / 1000))
        self.MiddleEastPoint.transform.position = CombatUtil.GetBehindPoint2(WestPointTmp, EastPointTmp, FighterLayout.EAST, (500 / 1000))
        CombatUtil.FaceTo(self.MiddleWestPoint, self.MiddleEastPoint.transform.position)
        self.MiddleWestPoint.transform:Rotate(Vector3(0, 180, 0))
        CombatUtil.FaceTo(self.MiddleEastPoint, self.MiddleWestPoint.transform.position)
        self.MiddleEastPoint.transform:Rotate(Vector3(0, 180, 0))
        self.MiddleWestPoint.transform:SetParent(self.CombatScene.transform, true)
        self.MiddleEastPoint.transform:SetParent(self.CombatScene.transform, true)
    end

    -- local totem = GameObject.Instantiate(ctx.ResourcesManager:GetMainAsset(AssetConfig.combat_totem))

    self.mainCamera = Camera.main
    self.mainCameraPos = self.mainCamera.transform.position
    local mPos = Camera.main.transform.position
    -- self.map.transform.position = Vector3 (mPos.x, mPos.y, 0)
    -- self.map.transform.localRotation = Quaternion.identity
    local org = 1.871345
    local real = ctx.ScreenWidth / ctx.ScreenHeight
    -- self.map.transform.localScale = Vector3 (org * 2 * real + 0.6, org * 2 + 0.6, 1)



    -- ctx.DramaLayer:SetActive(false)
    local ui_container = GameObject.Find("CanvasContainer")
    ui_container:SetActive(true)
    local count = ui_container.transform.childCount

    for i = 0, count - 1 do
        local t = ui_container.transform:GetChild(i)
        local name = t.gameObject.name
        if (t.gameObject.activeSelf or table.containValue(self.forceSwitch, name)) and table.containValue(self.hideUiList, name) then
            t.gameObject:SetActive(false)
            table.insert(self.mainUITransform, t)
        else
            if name == "MainUICanvasView" then
                -- t.gameObject:SetActive(true)
                MainUIManager.Instance:ShowMainUICanvas(true)
                local count2 = t.gameObject.transform.childCount
                for j = 0, count2 -1 do
                    local bicon = t.gameObject.transform:GetChild(j)
                    if bicon.gameObject.activeSelf and table.containValue(self.hideUiList, bicon.gameObject.name) then
                        bicon.gameObject:SetActive(false)
                        table.insert(self.mainUITransform, bicon)
                    -- elseif bicon.gameObject.name == "ChatCanvas" then
                    --     bicon:Find("ChatMini").gameObject:SetActive(true)
                    elseif bicon.gameObject.name == "MainUIIconView" then
                        local bfi = bicon.gameObject
                        local count3 = bfi.transform.childCount
                        for k = 0, count3-1 do
                            local bfichild = bfi.transform:GetChild(k)
                            if bfichild.name ~= "ButtonPanel1" and bfichild.name ~= "ButtonPanel6" and bfichild.name ~= "ButtonPanel7" then
                                bfichild.gameObject:SetActive(false)
                                table.insert(self.mainUITransform, bfichild)
                            end
                        end
                    elseif bicon.gameObject.name == "MainuiTracePanel" then
                        self.teamquestPanel = bicon.gameObject
                        print("追踪面板："..tostring(self.combatMgr.isAutoFighting))
                        self.teamquestPanel:SetActive(self.combatMgr.isAutoFighting)
                        MainUIManager.Instance.mainuitracepanel:TweenHiden()
                    end
                end
            elseif name == "ChatCanvas" then
                ChatManager.Instance.model:ShowCanvas(true)
                -- t.gameObject:SetActive(true)
            else
                -- t.gameObject:SetActive(true)
            end
        end
    end
    if self.transition == nil then
        self.transition = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.transition))
        UIUtils.AddUIChild(self.combatMgr.combatCanvas, self.transition)
    end
    self:ChangeTransitionAmount(1)
    self:Start()
end

function CombatController:Start()
    -- Application.targetFrameRate = 60

    self.combatMgr.cacheData = nil
    self.combatMgr.isFighting = true
    self:OnUiLoadedCompleted()
end

function CombatController:Destroy()
    -- Application.targetFrameRate = 60
    for k,v in pairs(self.brocastCtx.fighterDict) do
        v:DeleteMe()
    end
    self.brocastCtx.fighterDict = {}
    self.brocastCtx.fighterResDict = {} -- 无节操小包新增，保证只调用一次SubpackageManager.Instance:RoleResources替代资源方法，避免两次调用之间资源下载完成导致报错
    self.combatMgr.danmakuHistory = {}
    CombatManager.Instance.currRecData = nil
    DanmakuManager.Instance.model:ClearDanmaku()
    DanmakuManager.Instance.model:Show()
    self.combatSceneGo = {}
    for k, v in ipairs(self.mainUITransform) do
        if (not BaseUtils.is_null(v)) and (not BaseUtils.is_null(v.gameObject)) then
            v.gameObject:SetActive(true)
        end
    end
    for k,v in pairs(self.npcResCacheList) do
        -- self.combatMgr.objPool:PushUnit(v.go, v.path)
        if v["isSelfGroup"] ~= nil and v.isSelfGroup == true then
            -- GoPoolManager.Instance:Return(v.go, v.path, v.type)
        end
    end
    self.npcResCacheList = {}

    CombatUtil.DestroyChildActive(self.MiddleWestPoint, true)
    CombatUtil.DestroyChildActive(self.MiddleEastPoint, true)
    -- for k,v in pairs(self.uiResCacheList) do
    --     self.combatMgr.objPool:Push(v.go, v.id)
    -- end
    -- self.uiResCacheList = {}

    for k,v in pairs(self.rubbishList) do
        if not BaseUtils.isnull(v) then
            if v.id == "roleTemp" then
                GoPoolManager.Instance:Return(v.go, "role_obj", GoPoolType.BoundRoleCombat)
            elseif v.id == "npcTemp" then
                GoPoolManager.Instance:Return(v.go, "npc_obj", GoPoolType.BoundNpcCombat)
            else
                GameObject.Destroy(v.go)
            end
        end
    end
    self.rubbishList = {}
    if self.teamquestPanel ~= nil then
        self.teamquestPanel:SetActive(true)
        MainUIManager.Instance.mainuitracepanel:TweenShow()
    end


    if self.mainPanel ~= nil then
        self.combatMgr.isAutoFighting = self.mainPanel.isAutoFighting
        self.mainPanel:Hide()
    end

    self.combatMgr.isFighting = false
    RoleManager.Instance.RoleData.status = RoleEumn.Status.Normal


    MainUIManager.Instance.MainUIIconView:showbaseicon(true)
    MainUIManager.Instance.MainUIIconView:hidebaseicon4()
    self.map:SetActive(false)
    self.combatMapCamera.gameObject:SetActive(false)
    self.combatCamera.gameObject:SetActive(false)
    self.effectCamera.gameObject:SetActive(false)

    GoPoolManager.Instance:ReleaseOnEndCombat()
    -- self.combatMgr:DoFireEndFight()
    -- if self.brocastCtx ~= nil then
    --     self.brocastCtx:DeleteMe()
    --     self.brocastCtx = nil
    -- end
end

function CombatController:OnUiLoadedCompleted()
    -- 初始化UI
    -- ctx.ResourcesManager:LoadAll(AssetConfig.combat_uires)

    self.mainPanel:OnUiLoadedCompleted()
    self.roleTemp = self.SceneElements.transform:FindChild("InstantiateObject/Role").gameObject
    self.npcTemp = self.SceneElements.transform:FindChild("InstantiateObject/NPC").gameObject
    -- -- 初始模型
    local resList = self:GetFighterResList(self.enterData.fighter_list)
    local resources = {}
    local tempList = {}
    -- for k, v in ipairs(resList) do
    --     table.insert(resources, {file = v, type = AssetType.Main,callback = nil})
    -- end
    -- for i,v in ipairs(resList) do
    --     if tempList[v] == nil then
    --         tempList[v] = 1
    --     else
    --         tempList[v] = tempList[v] + 1
    --     end
    -- end
    -- for id, num in pairs(tempList) do
    --     if self.combatMgr.objPool:EnoughGo(k,v) == false then
    --         table.insert(resources, {file = id, type = AssetType.Main,callback = nil})
    --     end
    -- end
    for _, data in pairs(resList) do
        table.insert(resources, {file = data, type = AssetType.Main,callback = nil})
    end
    -- BaseUtils.dump(resources,"资源列表")
    if self.modelassetWrapper ~= nil then
        self.modelassetWrapper:DeleteMe()
        self.modelassetWrapper = nil
    end
    if self.modelassetWrapper == nil then
        self.modelassetWrapper = AssetBatchWrapper.New()
    end
    -- BaseUtils.dump(resources)
    self.modelassetWrapper:LoadAssetBundle(resources, function () self:OnModelLoadedCompleted() end)

    self:ShowGuidence()
end

function CombatController:ShowGuidence()
    local fighterList = self.enterData.fighter_list
    for k, fighter in ipairs(fighterList) do
        if DataCombatUtil.data_guidance[fighter.base_id] ~= nil and RoleManager.Instance.RoleData.lev <= DataCombatUtil.data_guidance[fighter.base_id].lev then
            self.guidenceStr = DataCombatUtil.data_guidance[fighter.base_id].str
        end
    end
    if self.enterData.combat_type == 52 then
        self.guidenceStr = TI18N("<color='#ffff00'>使用雪球将对手全部<color='#00ff00'>打成雪人</color>即可获胜！</color>")
    elseif self.enterData.combat_type == 60 then
        for _,fighter in pairs(self.brocastCtx.fighterDict) do
            if fighter.is_die ~= 1 and DataCombatUtil.data_guidance[fighter.fighterData.base_id] ~= nil and RoleManager.Instance.RoleData.lev <= DataCombatUtil.data_guidance[fighter.fighterData.base_id].lev then
                self.guidenceStr = DataCombatUtil.data_guidance[fighter.fighterData.base_id].str
            end
        end
    end
    self.mainPanel.extendPanel:ShowGuidence()
end

function CombatController:OnModelLoadedCompleted()
    if self.brocastCtx == nil or self.modelassetWrapper == nil or self.modelassetWrapper.ResLoaded == false then
        self.SceneLoaded = true
        self:EndOfCombat()
        return
    end
    self.loadstatus = true
    self.loadModelIng = true
    -- Log.Info("战斗单位开始加载")
    local fighterList = self.enterData.fighter_list
    self.brocastCtx.fighterDict = {}
    self.fighterNum = #fighterList
    local selfGroup = self.selfData.group
    for k, fighter in ipairs(fighterList) do
        if self.loadstatus == false then
            NoticeManager.Instance:FloatTipsByString(TI18N("战斗加载出现异常，如果再次出现清尝试清除游戏缓存"))
            Log.Error("战斗加载出现异常")
            self.SceneLoaded = true
            self:OnReConnect()
            return
        end
        if fighter.type == FighterType.Role or fighter.type == FighterType.Cloner then
            self:CreateRoleFighter(fighter, selfGroup, self.modelassetWrapper)
        elseif fighter.type == FighterType.Unit then
            local npcData = self.combatMgr:GetNpcBaseData(fighter.base_id)
            if npcData ~= nil and npcData.res_type == 5 then
                fighter.type = FighterType.Role
                self:CreateRoleFighter(fighter, selfGroup, self.modelassetWrapper)
            else
                self:CreateNpcFighter(fighter, selfGroup, self.modelassetWrapper)
            end
        elseif fighter.type == FighterType.Pet then
            self:CreateNpcFighter(fighter, selfGroup, self.modelassetWrapper)
            if fighter.master_fid == self.selfData.id then
                self.selfPetData = fighter
                if self.mainPanel ~= nil then
                    self.mainPanel:InitPetHeadPanel(fighter)
                end
            end
        elseif fighter.type == FighterType.Child then
            self:CreateNpcFighter(fighter, selfGroup, self.modelassetWrapper)
            if fighter.master_fid == self.selfData.id then
                self.selfPetData = fighter
                if self.mainPanel ~= nil then
                    self.mainPanel:InitPetHeadPanel(fighter)
                end
            end
        elseif fighter.type == FighterType.Guard then
            self:CreateNpcFighter(fighter, selfGroup, self.modelassetWrapper)
        else
            self:CreateNpcFighter(fighter, selfGroup, self.modelassetWrapper)
        end
    end
    RoleManager.Instance.RoleData.status = RoleEumn.Status.Fight
    local currID = self.combatID
    local finalfunc = function ()
        if self.mainPanel == nil or currID ~= self.combatID then return end
        self.mainPanel:InitUiPanel()
        local data10731 = self:BuildSelectSkillData(self.enterData)
        -- print("<color='#00ff00'>等待时间</color>:"..tostring(self.enterData.wait_time))
        if self.combatMgr.isBrocasting and self.enterData.wait_time > 0 and not self.combatMgr.isWatching and not self.combatMgr.isWatchRecorder then
            self.brocastCtx:SetEndData(data10731)
        else
            -- print("OnModelLoadedCompleted的10733")
            self.mainPanel:OnBeginFighting(data10731)
        end
    end
    -- if self.enterData.enter_type == 0 then
        self:DealMutiny(finalfunc)
    -- else
        -- finalfunc()
    -- end
    self.SceneLoaded = true
    if self.modelassetWrapper ~= nil then
        self.modelassetWrapper:DeleteMe()
        self.modelassetWrapper = nil
    end
    -- Log.Info("战斗单位加载完成")
    self.loadModelIng = false
end

function CombatController:OnReConnect()
    self.combatMgr.isBrocasting = false
    self:EndOfCombat()
    local enterData = BaseUtils.copytab(self.enterData)
    LuaTimer.Add(2000, function() CombatManager.Instance:Send10711() end)
end

function CombatController:CreateRoleFighter(data, selfGroup, selfassetWrapper, issummon)
    if selfassetWrapper == nil or selfassetWrapper.ResLoaded == false then
        self.SceneLoaded = true
        self:EndOfCombat()
        return
    end
    local pos = data.formation_pos
    if pos == 0 then return end -- 死亡飞走不再创建
    -- BaseUtils.dump(data.looks,"外观啊啊啊啊啊啊啊啊啊啊啊")
    local npcData = self.combatMgr:GetNpcBaseData(data.base_id)
    if npcData ~= nil and npcData.res_type == 5 then
        data.type = FighterType.Role
    end
    local pointDict = CombatUtil.WestPoint()
    local faceDict = CombatUtil.EastPoint()
    local midPoint = self.MiddleWestPoint
    local isSelfGroup = false
    if data.group == selfGroup then
        pointDict = CombatUtil.EastPoint()
        faceDict = CombatUtil.WestPoint()
        midPoint = self.MiddleEastPoint
        isSelfGroup = true
    end
    local row = pointDict[pos].pos[1]
    local column = pointDict[pos].pos[2]
    -- local fighter = GameObject.Instantiate(self.roleTemp)
    local fighter = GoPoolManager.Instance:Borrow("role_obj", GoPoolType.BoundRoleCombat)
    if fighter == nil then
        fighter = GameObject.Instantiate(self.roleTemp)
    end
    table.insert(self.rubbishList, {id = "roleTemp", go = fighter})
    fighter.transform:SetParent(self.CombatScene.transform, true)
    table.insert(self.combatSceneGo, fighter)
    GameObject.DontDestroyOnLoad(fighter)

    local modelPath = self:GetResPath("Model", data)
    local ctrlPath = self:GetResPath("Ctrl", data)
    local skinPath = self:GetResPath("Skin", data)

    local headModel = self:GetResPath("HeadModel", data)
    local headCtrlPath = self:GetResPath("HeadCtrl", data)
    local headSkinPath = self:GetResPath("HeadSkin", data)

    local weaponEffectPath = self:GetResPath("WeaponEffect", data)
    local wingmodelPath = self:GetResPath("WingModel", data)
    local beltmodelPath = self:GetResPath("BeltModel", data)
    local HeadSurbaseModelPath = self:GetResPath("HeadSurbaseModel", data)
    -- modelPath, skinPath, headModel, headSkinPath = self:RoleSubPackPrase(modelPath, skinPath, headModel, headSkinPath, data.classes, data.sex)
    modelPath, skinPath, headModel, headSkinPath = self:GetRoleResources(data.id) -- 无节操小包新增，保证只调用一次SubpackageManager.Instance:RoleResources替代资源方法，避免两次调用之间资源下载完成导致报错

    -- local tpose = self.combatMgr.objPool:PopUnit(modelPath)
    -- local tpose = GoPoolManager.Instance:Borrow(modelPath, GoPoolType.Role)
    local tpose = nil
    if tpose == nil then
        tpose = GameObject.Instantiate(selfassetWrapper:GetMainAsset(modelPath).transform:FindChild("tpose").gameObject)
        local ctrl = selfassetWrapper:GetMainAsset(ctrlPath)
        tpose:GetComponent(Animator).runtimeAnimatorController = ctrl;
        tpose:GetComponent(Animator).applyRootMotion = false;
        --清空可能残留的头饰背饰
        local Bip_Head = tpose.transform:Find("Bip_Head")
        local bp_wing = tpose.transform:Find("bp_wing")
        for i=0, Bip_Head.childCount-1 do
            GameObject.Destroy(Bip_Head:GetChild(i).gameObject)
        end
        for i=0, bp_wing.childCount-1 do
            GameObject.Destroy(bp_wing:GetChild(i).gameObject)
        end
    end
    table.insert(self.npcResCacheList, {path = modelPath, go = tpose, type = GoPoolType.Role, isSelfGroup = isSelfGroup})
    tpose.name = "tpose"
    -- local headTpose = self.combatMgr.objPool:PopUnit(headModel)
    -- local headTpose = GoPoolManager.Instance:Borrow(headModel, GoPoolType.Head)
    local headTpose = nil
    if headTpose == nil then
        headTpose = GameObject.Instantiate(selfassetWrapper:GetMainAsset(headModel).transform:FindChild("tpose").gameObject)
        local headctrl = selfassetWrapper:GetMainAsset(headCtrlPath)
        headTpose.name = "headTpose"
        headTpose:GetComponent(Animator).runtimeAnimatorController = headctrl;
        headTpose:GetComponent(Animator).applyRootMotion = false;
    end
    table.insert(self.npcResCacheList, {path = headModel, go = headTpose, type = GoPoolType.Head, isSelfGroup = isSelfGroup})


    local skin = selfassetWrapper:GetMainAsset(skinPath)
    local meshNode = self:GetRoleMeshNode(tpose, "Model", data)
    BaseUtils.ChangeShaderForOldVersion(meshNode.renderer.material)
    meshNode.renderer.material.mainTexture = skin

    local headSkin = selfassetWrapper:GetMainAsset(headSkinPath)
    local headMeshNode = self:GetRoleMeshNode(headTpose, "headModel", data)
    BaseUtils.ChangeShaderForOldVersion(headMeshNode.renderer.material)
    headMeshNode.renderer.material.mainTexture = headSkin

    if BaseUtils.isnull(fighter) then
        GameObject.Destroy(tpose)
    else
        tpose.transform:SetParent(fighter.transform)
        tpose.transform.localPosition = Vector3(0, 0, 0)
        tpose.transform.localScale = Vector3(1, 1, 1)
    end
    local path = BaseUtils.GetChildPath(tpose.transform, "Bip_Head")
    if BaseUtils.isnull(tpose) then
        GameObject.Destroy(headTpose)
    else
        local mounter = tpose.transform:Find(path)
        headTpose.transform:SetParent(mounter)
        headTpose.transform.localPosition = Vector3(0, 0, 0)
        headTpose.transform.localScale = Vector3(1, 1, 1)
        headTpose.transform.localRotation = Quaternion.identity
        headTpose.transform:Rotate(Vector3(90, 0, 0))
    end


    fighter.name = data.name
    Utils.ChangeLayersRecursively(fighter.transform, "CombatModel")
    fighter.transform.position = CombatUtil.GridToPosition (row, column);
    local fctrl = fighter:AddComponent(LuaBehaviourDownUpBase)
    local fighterController = fctrl:SetClass("FighterController")
    local winglooks = nil
    for k, v in pairs(data.looks) do
        if v.looks_type == SceneConstData.looktype_wing then -- 翅膀
            winglooks = v.looks_val
        end
    end
    
    if wingmodelPath ~= nil and CombatUtil.IsShowWing(self.enterData.combat_type) then
        -- local wingT = self.combatMgr.objPool:PopUnit(wingmodelPath..tostring(winglooks))
        -- local wingT = GoPoolManager.Instance:Borrow(wingmodelPath..tostring(winglooks), GoPoolType.Weapon)
        local wingT = nil
        local callback = function(wingtpose)
            if BaseUtils.isnull(tpose) then
                GameObject.Destroy(wingtpose)
                return
            end
            local path = BaseUtils.GetChildPath(tpose.transform, "bp_wing")
            local bind = tpose.transform:Find(path)
            if bind ~= nil then
                local t = wingtpose:GetComponent(Transform)
                t:SetParent(bind)
                t.localPosition = Vector3(0, 0, 0)
                t.localRotation = Quaternion.identity
                t:Rotate(Vector3(90, 270, 0))
                t.localScale = Vector3(1, 1, 1)
                if data.is_die == 1 then
                    wingtpose.gameObject:SetActive(false)
                end
            end
            LuaTimer.Add(150, function() if not BaseUtils.is_null(wingtpose) then Utils.ChangeLayersRecursively(wingtpose.transform, "CombatModel") end end)

            fighterController.wingTpose = wingtpose.gameObject
            table.insert(self.npcResCacheList, {path = wingmodelPath..tostring(winglooks), go = wingtpose.gameObject, type = GoPoolType.Wing, isSelfGroup = isSelfGroup})
        end
        if wingT ~= nil then
            callback(wingT)
        else
            local wingLoader = WingTposeLoader.New(data.looks, callback)
        end
    end

    if beltmodelPath ~= nil then
        -- local beltT = self.combatMgr.objPool:PopUnit(beltmodelPath)
        -- local beltT = GoPoolManager.Instance:Borrow(beltmodelPath, GoPoolType.Surbase)
        local beltT = nil
        local callback = function(belttpose)
            if BaseUtils.isnull(tpose) then
                GameObject.Destroy(belttpose)
                return
            end
            local path = BaseUtils.GetChildPath(tpose.transform, "bp_wing")
            local bind = tpose.transform:Find(path)
            if bind ~= nil then
                local t = belttpose:GetComponent(Transform)
                t:SetParent(bind)
                t.localPosition = Vector3(0, 0, 0)
                t.localRotation = Quaternion.identity
                t:Rotate(Vector3(90, 270, 0))
                t.localScale = Vector3(1, 1, 1)
            end
            LuaTimer.Add(150, function() if not BaseUtils.is_null(belttpose) then Utils.ChangeLayersRecursively(belttpose.transform, "CombatModel") end end)

            fighterController.beltTpose = belttpose.gameObject
            table.insert(self.npcResCacheList, {path = beltmodelPath, go = belttpose, type = GoPoolType.Surbase, isSelfGroup = isSelfGroup})
        end
        if beltT ~= nil then
            callback(beltT)
        else
            BeltTposeLoader.New(data.looks, callback)
        end
        -- local beltLoader = HeadSurbaseTposeLoader.New(data.looks, callback)

    end
    if HeadSurbaseModelPath ~= nil then
        -- local headsurbaseT = self.combatMgr.objPool:PopUnit(HeadSurbaseModelPath)
        -- local headsurbaseT = GoPoolManager.Instance:Borrow(HeadSurbaseModelPath, GoPoolType.Surbase)
        local headsurbaseT = nil
        local callback = function(headsurbasetpose)
            if BaseUtils.isnull(tpose) then
                GameObject.Destroy(headsurbasetpose)
                return
            end
            local path = BaseUtils.GetChildPath(tpose.transform, "Bip_Head")
            local bind = tpose.transform:Find(path)
            if bind ~= nil then
                local t = headsurbasetpose:GetComponent(Transform)
                t:SetParent(bind)
                t.localPosition = Vector3(0, 0, 0)
                t.localRotation = Quaternion.identity
                t:Rotate(Vector3(90, 0, 0))
                t.localScale = Vector3(1, 1, 1)
            end
            LuaTimer.Add(150, function() if not BaseUtils.is_null(headsurbasetpose) then Utils.ChangeLayersRecursively(headsurbasetpose.transform, "CombatModel") end end)

            fighterController.headsurbasetpose = headsurbasetpose.gameObject
            table.insert(self.npcResCacheList, {path = HeadSurbaseModelPath, go = headsurbasetpose, type = GoPoolType.Surbase, isSelfGroup = isSelfGroup})
        end
        if headsurbaseT ~= nil then
            callback(headsurbaseT)
        else
            HeadSurbaseTposeLoader.New(data.looks, callback)
        end
    end

    fighterController.fighterData = data
    fighterController.headTpose = headTpose.transform
    fighterController:InitAnimationData()
    fighterController:InitHeadInfo()
    table.insert(fighterController.PointerClickEvent, function(fdata) self:OnPointerClick(fdata) end)
    table.insert(fighterController.PointerHoldEvent, function(fdata) self:OnPointerHold(fdata) end)
    self.brocastCtx.fighterDict[data.id] = fighterController
    if data.group == selfGroup then
        table.insert(self.eastFighterList, FighterCombo.New(data.id, fighter, data))
        fighterController.layout = FighterLayout.EAST
    else
        table.insert(self.westFighterList, FighterCombo.New(data.id, fighter, data))
        fighterController.layout = FighterLayout.WEST
    end
    if data.id == self.selfData.id then
        self.selfFighter = fighter
    end
    local faceToPoint = CombatUtil.GridToPosition(faceDict[pos].pos[1], faceDict[pos].pos[2])
    fighterController:FaceTo(faceToPoint)
    fighterController.originFaceToPos = faceToPoint
    fighterController.regionalPoint = midPoint

    fighterController:CreateFighterUI(self.mainPanel)
    fighterController.buffCtrl:InitBuffUI()
    if self.enterData.combat_type ~= 52 then
        -- 大雪球模式不创建武器
        xpcall(function() self:BindWeapon(tpose, data, fighterController, weaponEffectPath, selfassetWrapper) end,
            function()  Log.Error(debug.traceback()) end )
    end

    self:DealInitBuff(data.id, data.buff_infos)
    fighterController:PlayAction(FighterAction.BattleStand)
    fighterController:DealLooksTransformer()
end

function CombatController:CreateNpcFighter(data, selfGroup, selfassetWrapper, issummon)
    if selfassetWrapper == nil or selfassetWrapper.ResLoaded == false then
        self.SceneLoaded = true
        self:EndOfCombat()
        return
    end

    local npcData = nil
    if data.type == FighterType.Pet then
        npcData = self.combatMgr:GetPetBaseData(data.base_id)
        npcData.effects = {}
        for k,v in pairs(data.looks) do
            if v.looks_type == SceneConstData.looks_type_unreal_skin then -- 先处理幻化
                if npcData.skin_id_0 == v.looks_val then
                    npcData.effects = npcData.effects_0
                elseif npcData.skin_id_1 == v.looks_val then
                    npcData.effects = npcData.effects_1
                elseif npcData.skin_id_2 == v.looks_val then
                    npcData.effects = npcData.effects_2
                elseif npcData.skin_id_3 == v.looks_val then
                    npcData.effects = npcData.effects_3
                elseif npcData.skin_id_s0 == v.looks_val then
                    npcData.effects = npcData.effects_s0
                elseif npcData.skin_id_s1 == v.looks_val then
                    npcData.effects = npcData.effects_s1
                elseif npcData.skin_id_s2 == v.looks_val then
                    npcData.effects = npcData.effects_s2
                elseif npcData.skin_id_s3 == v.looks_val then
                    npcData.effects = npcData.effects_s3
                end
                break
            end
        end
        if #npcData.effects == 0 then
            for k,v in pairs(data.looks) do
                if v.looks_type == SceneConstData.looktype_pet_skin then -- 再处理皮肤
                    if npcData.skin_id_0 == v.looks_val then
                        npcData.effects = npcData.effects_0
                    elseif npcData.skin_id_1 == v.looks_val then
                        npcData.effects = npcData.effects_1
                    elseif npcData.skin_id_2 == v.looks_val then
                        npcData.effects = npcData.effects_2
                    elseif npcData.skin_id_3 == v.looks_val then
                        npcData.effects = npcData.effects_3
                    elseif npcData.skin_id_s0 == v.looks_val then
                        npcData.effects = npcData.effects_s0
                    elseif npcData.skin_id_s1 == v.looks_val then
                        npcData.effects = npcData.effects_s1
                    elseif npcData.skin_id_s2 == v.looks_val then
                        npcData.effects = npcData.effects_s2
                    elseif npcData.skin_id_s3 == v.looks_val then
                        npcData.effects = npcData.effects_s3
                    end
                    break
                end
            end
        end
    end
    local pos = data.formation_pos
    local group = data.group
    local realgroup = data.group
    local master_name = ""
    for k,v in pairs(data.looks) do
        if v.looks_type == SceneConstData.looks_type_combat_order then -- 初始站位
            -- pos = v.looks_val
            group = v.looks_mode
            master_name = v.looks_str
            -- local temp = BaseUtils.copytab(data)
            -- temp.pos = pos
            -- temp.group = group
            -- if realgroup == selfGroup then
            --     self.combatMgr:ChangeFighterPos(self.enterData.dfd_formation, self.enterData.dfd_formation_lev, temp)
            --     data.realpos = CombatUtil.GetOriginPos(self.enterData.atk_formation, self.enterData.atk_formation_lev, data.pos)
            -- else
            --     data.realpos = CombatUtil.GetOriginPos(self.enterData.dfd_formation, self.enterData.dfd_formation_lev, data.pos)
            --     self.combatMgr:ChangeFighterPos(self.enterData.atk_formation, self.enterData.atk_formation_lev, temp)
            -- end
            -- pos = temp.pos
            -- data.looks[k].looks_val = temp.pos
            -- data.looks[k].looks_mode = temp.group
            break
        end
    end
    if pos == 0 then return end
    local pointDict = CombatUtil.WestPoint()
    local faceDict = CombatUtil.EastPoint()
    local midPoint = self.MiddleWestPoint
    local isSelfGroup = false
    if group == selfGroup then
        pointDict = CombatUtil.EastPoint()
        faceDict = CombatUtil.WestPoint()
        midPoint = self.MiddleEastPoint
        isSelfGroup = realgroup == selfGroup
    end
    local row = pointDict[pos].pos[1]
    local column = pointDict[pos].pos[2]
    local fighter = GoPoolManager.Instance:Borrow("npc_obj", GoPoolType.BoundNpcCombat)
    if fighter == nil then
        fighter = GameObject.Instantiate(self.npcTemp)
    end
    table.insert(self.rubbishList, {id = "npcTemp", go = fighter})
    fighter.transform:SetParent(self.CombatScene.transform, true)
    table.insert(self.combatSceneGo, fighter)
    GameObject.DontDestroyOnLoad(fighter)
    local modelPath = self:GetResPath("Model", data)
    local ctrlPath = self:GetResPath("Ctrl", data)
    local skinPath = self:GetResPath("Skin", data)
    local effpath = self:GetResPath("WeaponEffect", data)
    local modelId = self:GetNpcModelInfo(data)
    local usePack = false
    -- modelPath, ctrlPath, skinPath, modelId = self:NPCSubPackPrase(modelPath, ctrlPath, skinPath, modelId)
    modelPath, ctrlPath, skinPath, modelId, usePack = self:GetNPCResources(data.id) -- 无节操小包新增，保证只调用一次SubpackageManager.Instance:RoleResources替代资源方法，避免两次调用之间资源下载完成导致报错

    local scale = self:GetNpcScale(data)
    -- local tpose = self.combatMgr.objPool:PopUnit(modelPath)
    -- local tpose = GoPoolManager.Instance:Borrow(modelPath, GoPoolType.Npc)
    local tpose = nil
    if tpose == nil then
        self.loadstatus = xpcall(function() tpose = GameObject.Instantiate(selfassetWrapper:GetMainAsset(modelPath).transform:FindChild("tpose").gameObject) end,
            function(err) Log.Error("[战斗]创建模型出错:" .. tostring(err)) end )
        if not self.loadstatus then
            Log.Error("[战斗]创建模型出错, modelPath:" .. modelPath)
            return
        end
        local ctrl = selfassetWrapper:GetMainAsset(ctrlPath)
        tpose:GetComponent(Animator).runtimeAnimatorController = ctrl;
    end
     -- 宠物幻化优先级高，在这处理
    if data.type == FighterType.Pet then
        for k,v in pairs(data.looks) do
            if v.looks_type == SceneConstData.looktype_pet_trans and v.looks_val ~= 0  then
                local transfData = DataTransform.data_transform[v.looks_val];
                if transfData ~= nil then
                      npcData.effects = transfData.effects
                     break
                end
            end
        end
     end
    if npcData ~= nil and #npcData.effects > 0 then
        local effectData = DataEffect.data_effect[npcData.effects[1].effect_id]
        if CombatUtil.IsHasEffect(tpose, effectData) == false then
            local callback = function() Utils.ChangeLayersRecursively(tpose.transform, "CombatModel") end
            TposeEffectLoader.New(tpose, tpose, npcData.effects, callback)
        end
    end
    table.insert(self.npcResCacheList, {path = modelPath, go = tpose.gameObject, type = GoPoolType.Npc, isSelfGroup = isSelfGroup})
    -- BaseUtils.dump(data, "CreateNpcFighter")
    local skin = selfassetWrapper:GetMainAsset(skinPath)
    local meshNode = self:GetRoleMeshNode(tpose, "Model", data)
    BaseUtils.ChangeShaderForOldVersion(meshNode.renderer.material)
    local wpEffect = nil
    tpose.name = "tpose"
    tpose:GetComponent(Animator).applyRootMotion = false;
    if BaseUtils.isnull(fighter) then
        GameObject.Destroy(tpose)
    else
        tpose.transform:SetParent(fighter.transform)
        tpose.transform.localPosition = Vector3(0, 0, 0)
        tpose.transform.localScale = Vector3(scale, scale, scale)
        tpose.transform:FindChild(string.format("Mesh_%s", modelId)).renderer.material.mainTexture = skin
    end
    fighter.name = data.name
    if master_name ~= "" then
        data.master_name = master_name
        fighter.name = string.format("%s的%s", master_name, data.name)
    end

    Utils.ChangeLayersRecursively(fighter.transform, "CombatModel")
    fighter.transform.position = CombatUtil.GridToPosition (row, column);
    local fctrl = fighter:AddComponent(LuaBehaviourDownUpBase)
    local fighterController = fctrl:SetClass("FighterController")
    fighterController.fighterData = data
    fighterController:InitAnimationData(usePack)
    table.insert(fighterController.PointerClickEvent, function(fdata) self:OnPointerClick(fdata) end)
    table.insert(fighterController.PointerHoldEvent, function(fdata) self:OnPointerHold(fdata) end)
    self.brocastCtx.fighterDict[data.id] = fighterController
    if realgroup == selfGroup then
        table.insert(self.eastFighterList, FighterCombo.New(data.id, fighter, data))
        fighterController.layout = FighterLayout.EAST
    else
        table.insert(self.westFighterList, FighterCombo.New(data.id, fighter, data))
        fighterController.layout = FighterLayout.WEST
    end
    if data.id == self.selfData.id then
        self.selfFighter = fighter
    elseif data.master_fid == self.selfData.id then
        self.selfPet = fighter
    end
    local faceToPoint = CombatUtil.GridToPosition(faceDict[pos].pos[1], faceDict[pos].pos[2])
    fighterController:FaceTo(faceToPoint)
    fighterController.originFaceToPos = faceToPoint
    fighterController.regionalPoint = midPoint
    fighterController:CreateFighterUI(self.mainPanel)
    fighterController.buffCtrl:InitBuffUI()
    fighterController.modelId = modelId
    fighterController.defaultScale = scale
    fighterController.isSummon = issummon
    self:DealInitBuff(data.id, data.buff_infos)
    fighterController:PlayAction(FighterAction.BattleStand)
    fighterController:DealLooksTransformer()
end

function CombatController:InitSelfData()
    local fighterList = self.enterData.fighter_list
    local ac = self.accountInfo
    local roleGroupTable = {}
    local roleGroupList = {}
    for k, fighter in ipairs(fighterList) do
        if fighter.type == FighterType.Role then
            if (fighter.rid == ac.id and fighter.zone_id == ac.zone_id and fighter.platform == ac.platform) then
                self.selfData = fighter
                if fighter.is_auto == 1 then
                    self.mainPanel.isAutoFighting = true
                else
                    self.mainPanel.isAutoFighting = false
                end
            end
            if roleGroupTable["group" .. fighter.group] == nil then
                roleGroupTable["group" .. fighter.group] = true
                table.insert(roleGroupList, fighter.group)
            end
        end
    end
    if self.selfData == nil then
        for k, fighter in ipairs(fighterList) do
            if fighter.type == FighterType.Role then
                if (fighter.rid == ac.id and fighter.zone_id == ac.zone_id and fighter.platform == ac.platform) or (self.combatMgr.isWatching and fighter.group == self.enterData.enter_view)or (self.combatMgr.isWatchRecorder and fighter.group == 0) then
                    self.selfData = fighter
                    if fighter.is_auto == 1 then
                        self.mainPanel.isAutoFighting = true
                    else
                        self.mainPanel.isAutoFighting = false
                    end
                end
            end
            if roleGroupTable["group" .. fighter.group] == nil then
                roleGroupTable["group" .. fighter.group] = true
                table.insert(roleGroupList, fighter.group)
            end
        end
    end
    if #roleGroupList > 1 then
        self.CombatFightType = CombatFightType.PVP
        self.combatMgr.isAutoFighting = false
    end

    if self.selfData == nil then
        local nameList = ""
        for i,v in ipairs(fighterList) do
            nameList = string.format("%s, %s", nameList, tostring(v.name))
        end
        Log.Error("初始个人数据出错：FighterList没有匹配的信息 : "..nameList)
        Log.Error("self.selfData is nil：isWatching:" .. tostring(self.combatMgr.isWatching) .. "<>" .. tostring(self.combatMgr.isWatchRecorder) .. "<>" .. tostring(#fighterList) .. "<>" .. self.enterData.enter_view)
        return false
    end
    return true
end

function CombatController:GetFighterResList(fighterList)
    local resList = {}
    local keyTable = {}
    for k, v in ipairs(fighterList) do
        if BaseUtils.IsVerify then

            -- 如果不是玩家的话，改成玩家类型，然后给他个职业性别
            if v.type ~= FighterType.Role and v.type ~= FighterType.Pet then
                v.type = FighterType.Role
                if v.classes == 0 then v.classes = math.random(1, 7) end
                if v.sex == 2 then v.sex = math.random(0, 1) end
            end

            -- 现在人物不用变身了，直接给他一个时装
            local dressLook, hairLook = KvData.RandomRoleLook(self.selfData.id == v.id)
            local isHasDress = false
            local isHasHair = false
            for lookIndex,lookData in ipairs(v.looks) do
                if lookData.looks_type == SceneConstData.looktype_dress then -- 身上时装
                    v.looks[lookIndex] = dressLook
                    isHasDress = true
                elseif lookData.looks_type == SceneConstData.looktype_hair then -- 头上时装
                    v.looks[lookIndex] = hairLook
                    isHasHair = true
                end
            end
            if not isHasDress then
                table.insert(v.looks, dressLook)
            end
            if not isHasHair then
                table.insert(v.looks, hairLook)
            end
        end

        local fRes = self:ParseFighterRes(v)
        if fRes ~= nil then
            for rk, rv in ipairs(fRes) do
                table.insert(resList, rv)
            end
        end
    end
    return resList
end

function CombatController:ParseFighterRes(fighter)
    local npcData = self.combatMgr:GetNpcBaseData(fighter.base_id)
    if npcData ~= nil and npcData.res_type == 5 then
        fighter.type = FighterType.Role
    end
    if fighter.type == FighterType.Role or fighter.type == FighterType.Cloner then
        local temp = {}
        local body = self:GetResPath("Model", fighter)
        local ctrl = self:GetResPath("Ctrl", fighter)
        local skin = self:GetResPath("Skin", fighter)

        local headModel = self:GetResPath("HeadModel", fighter)
        local headCtrl = self:GetResPath("HeadCtrl", fighter)
        local headSkin = self:GetResPath("HeadSkin", fighter)

        local weaponPath = self:GetResPath("Weapon", fighter)
        local weaponEffectPath = self:GetResPath("WeaponEffect", fighter)

        local beltPath = self:GetResPath("BeltModel", fighter)
        local beltEffectPath = self:GetResPath("BeltEffect", fighter)

        local headsurbasePath = self:GetResPath("HeadSurbaseModel", fighter)
        local headsurbaseEffectPath = self:GetResPath("HeadSurbaseEffect", fighter)

        -- local roleRes = {bodyModelPath = body, bodySkinPath = skin, headModelPath = headModel, headSkinPath = headSkin}
        -- roleRes = SubpackageManager.Instance:RoleResources(roleRes, true)
        -- BaseUtils.dump(roleRes, "哈！！！！！！？？？")
        body, skin, headModel, headSkin = self:RoleSubPackPrase(body, skin, headModel, headSkin, fighter.classes, fighter.sex)
        -- body = roleRes.bodyModelPath
        -- skin = roleRes.bodySkinPath
        -- headModel = roleRes.headModelPath
        -- headSkin = roleRes.headSkinPath

        table.insert(temp, body)
        table.insert(temp, skin)
        table.insert(temp, headModel)
        table.insert(temp, headSkin)

        table.insert(temp, ctrl)
        table.insert(temp, headCtrl)
        table.insert(temp, weaponPath)
        table.insert(temp, weaponEffectPath)
        -- table.insert(temp, beltPath)
        -- table.insert(temp, beltEffectPath)
        -- table.insert(temp, headsurbasePath)
        -- table.insert(temp, headsurbaseEffectPath)
        self.brocastCtx.fighterResDict[fighter.id] = { body = body, skin = skin, headModel = headModel, headSkin = headSkin, classes = fighter.classes, sex = fighter.sex }
        return temp
    elseif fighter.type == FighterType.Unit or fighter.type == FighterType.Child or fighter.type == FighterType.Pet or fighter.type == FighterType.Guard then
        local body = self:GetResPath("Model", fighter)
        local ctrl = self:GetResPath("Ctrl", fighter)
        local skin = self:GetResPath("Skin", fighter)
        local usePack = false
        -- local npcRes = {modelPath = body, ctrlPath = ctrl, skinPath = skin}
        -- npcRes = SubpackageManager.Instance:NpcResources(npcRes, true)
        -- BaseUtils.dump(npcRes, "哈！！！！！！？？？")
        local modelId = self:GetNpcModelInfo(fighter)
        body, ctrl, skin, modelId, usePack = self:NPCSubPackPrase(body, ctrl, skin, modelId)
        -- body = npcRes.modelPath
        -- skin = npcRes.skinPath
        -- ctrl = npcRes.ctrlPath

        local weaponEffect = self:GetResPath("WeaponEffect", fighter)

        self.brocastCtx.fighterResDict[fighter.id] = { body = body, ctrl = ctrl, skin = skin, modelId = modelId, weaponEffect = weaponEffect, usePack = usePack }
        return {body, ctrl, skin, weaponEffect}
    end
    return nil
end

function CombatController:GetResPath(rType, fighter)
    -- Role
    local npcData = self.combatMgr:GetNpcBaseData(fighter.base_id)
    if npcData ~= nil and npcData.res_type == 5 then
        fighter.type = FighterType.Role
    end
    if rType == "Model" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_dress then
                return string.format(CombatUtil.playerBodyPath, BaseUtils.ConvertInvalidDressModel(fighter.classes, fighter.sex, v.looks_val))
            end
        end
        local looksVal = BaseUtils.default_dress(fighter.classes, fighter.sex);
        return string.format(CombatUtil.playerBodyPath, looksVal)
    elseif rType == "Skin" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_dress then
                return string.format(CombatUtil.playerSkinPath, BaseUtils.ConvertInvalidDressSkin(fighter.classes, fighter.sex, v.looks_mode))
            end
        end
        local looksVal = BaseUtils.default_dress_skin(fighter.classes, fighter.sex);
        return string.format(CombatUtil.playerSkinPath, looksVal)
    elseif rType == "Weapon" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        local looks = fighter.looks
        for _, look in ipairs(looks) do
            if look.looks_type == SceneConstData.looktype_weapon then
                return string.format(CombatUtil.playerWeaponPath, look.looks_val)
            end
        end
        local looksVal = BaseUtils.default_weapon(fighter.classes, fighter.sex);
        return string.format(CombatUtil.playerWeaponPath, looksVal)
    elseif rType == "Ctrl" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        return string.format(CombatUtil.playerCtrlPath, (fighter.sex == 0 and "female" or "male"))
    elseif rType == "WingSkin" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        local looks = fighter.looks
        for _, look in ipairs(looks) do
            if look.looks_type == SceneConstData.looktype_wing then
                local wingdata = DataWing.data_base[look.looks_val]
                local skinPath = string.format("prefabs/wing/skin/%s.unity3d", wingdata.map_id)
                return skinPath
            end
        end
    elseif rType == "WingModel" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        local looks = fighter.looks
        for _, look in ipairs(looks) do
            if look.looks_type == SceneConstData.looktype_wing then
                local wingdata = DataWing.data_base[look.looks_val]
                local modelPath = string.format("prefabs/wing/model/%s.unity3d", wingdata.model_id)
                return modelPath
            end
        end
    elseif rType == "WingCtrl" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        local looks = fighter.looks
        for _, look in ipairs(looks) do
            if look.looks_type == SceneConstData.looktype_wing then
                local wingdata = DataWing.data_base[look.looks_val]
                local animationData = DataAnimation.data_wing_data[wingdata.act_id]
                local ctrlPath = string.format("prefabs/wing/animation/%s.unity3d", animationData.controller_id)
                return ctrlPath
            end
        end
    elseif rType == "WeaponEffect" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        local looks = fighter.looks
        for _, look in ipairs(looks) do
            if look.looks_type == SceneConstData.looktype_weapon then
                if look.looks_mode ~= 0 then
                    local effectData = DataEffect.data_effect[look.looks_mode]
                    if effectData == nil then
                        -- print(string.format("<color='#00ff00'>effect_data 这个武器特效id数据没有啊 %s</color>", look.looks_mode))
                    else
                        return string.format(AssetConfig.effect, effectData.res_id)
                    end
                end
            end
        end
    elseif rType == "BeltModel" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.lookstype_belt then
                local belData = DataFashion.data_base[v.looks_val]
                if belData == nil then
                    -- print(string.format("<color='#00ff00'>fashion_data 这个时装id数据没有啊 %s</color>", v.looks_val))
                else
                    return string.format(CombatUtil.playerBeltPath, belData.model_id)
                end
            end
        end
    elseif rType == "HeadSurbaseModel" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.lookstype_headsurbase then
                local headSurbaseData = DataFashion.data_base[v.looks_val]
                if headSurbaseData == nil then
                    -- print(string.format("<color='#00ff00'>fashion_data 这个时装id数据没有啊 %s</color>", v.looks_val))
                else
                    return string.format(SceneConstData.looksdefiner_headsurbasepath, headSurbaseData.model_id)
                end
            end
        end
    elseif rType == "BeltEffect" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        local looks = fighter.looks
        for _, look in ipairs(looks) do
            if look.looks_type == SceneConstData.lookstype_belt then
                if look.looks_mode ~= 0 then
                    local effectData = DataEffect.data_effect[look.looks_mode]
                    if effectData == nil then
                        -- print(string.format("<color='#00ff00'>effect_data 这个武器特效id数据没有啊 %s</color>", look.looks_mode))
                    else
                        return string.format(AssetConfig.effect, effectData.res_id)
                    end
                end
            end
        end
    elseif rType == "HeadSurbaseEffect" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        local looks = fighter.looks
        for _, look in ipairs(looks) do
            if look.looks_type == SceneConstData.lookstype_headsurbase then
                if look.looks_mode ~= 0 then
                    local effectData = DataEffect.data_effect[look.looks_mode]
                    if effectData == nil then
                        -- print(string.format("<color='#00ff00'>effect_data 这个特效id数据没有啊 %s</color>", look.looks_mode))
                    else
                        self.effectPath = string.format(AssetConfig.effect, effectData.res_id)
                        self.effectData = effectData
                    end
                end
            end
        end
    -- Head
    elseif rType == "HeadModel" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_hair then
                return string.format(CombatUtil.headModelPath, BaseUtils.ConvertInvalidHeadModel(fighter.classes, fighter.sex, v.looks_val))
            end
        end
        local looksVal = BaseUtils.default_head(fighter.classes, fighter.sex);
        return string.format(CombatUtil.headModelPath, looksVal)
    elseif rType == "HeadSkin" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_hair then
                return string.format(CombatUtil.headSkinPath, BaseUtils.ConvertInvalidHeadSkin(fighter.classes, fighter.sex, v.looks_mode))
            end
        end
        local looksVal = BaseUtils.default_head_skin(fighter.classes, fighter.sex);
        return string.format(CombatUtil.headSkinPath, looksVal)
    elseif rType == "HeadCtrl" and (fighter.type == FighterType.Role or fighter.type == FighterType.Cloner) then
        return string.format(CombatUtil.headctrlpath, (fighter.sex == 0 and "female" or "male"))
    -- Npc
    elseif rType == "Model" and fighter.type == FighterType.Unit then
        local npcData = self.combatMgr:GetNpcBaseData(fighter.base_id)
        if npcData == nil then
            Log.Error("[战斗]缺少单位基础信息():[NpcBaseId:" .. fighter.base_id .. "]")
        end
        return string.format(CombatUtil.npcModelPath, npcData.res)
    elseif rType == "Ctrl" and fighter.type == FighterType.Unit then
        local npcData = self.combatMgr:GetNpcBaseData(fighter.base_id)
        -- local animationData = data_animation.data_npc_data[npcData.animation_id]
        local animationData = self.combatMgr:GetAnimationData(npcData.animation_id)
        if animationData == nil then
            Log.Error("[战斗]缺少动作基础信息(animation_data):[AnimationId:" .. npcData.animation_id .. "][NpcBaseId:" .. fighter.base_id .. "]")
        end
        if animationData.controller_id == 99999 then
            return string.format(CombatUtil.playerCtrlPath, (fighter.sex == 0 and "female" or "male"))
        else
            return string.format(CombatUtil.npcAnimationPath, animationData.controller_id)
        end
    elseif rType == "Skin" and fighter.type == FighterType.Unit then
        local npcData = self.combatMgr:GetNpcBaseData(fighter.base_id)
        return string.format(CombatUtil.npcSkinPath, npcData.skin)

    -- Pet
    elseif rType == "Model" and fighter.type == FighterType.Pet then
        local petData = self.combatMgr:GetPetBaseData(fighter.base_id)
        local modelId = petData.model_id
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looks_type_unreal_skin and v.looks_mode ~= 0 then -- 先检查幻化
                return string.format(CombatUtil.npcModelPath, v.looks_mode)
            end
        end

        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_pet_skin and v.looks_mode ~= 0 then -- 再检查皮肤
                return string.format(CombatUtil.npcModelPath, v.looks_mode)
            end
        end
        return string.format(CombatUtil.npcModelPath, modelId)
    elseif rType == "Ctrl" and fighter.type == FighterType.Pet then
        local petData = self.combatMgr:GetPetBaseData(fighter.base_id)
        -- local animationData = data_animation.data_npc_data[petData.animation_id]
        --宠物变身更换动作
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_pet_trans and v.looks_val ~= 0 then
                local transfData = DataTransform.data_transform[v.looks_val];
                if transfData ~= nil then
                    return string.format(CombatUtil.npcAnimationPath, self.combatMgr:GetAnimationData(transfData.animation_id).controller_id)
                end
            end
        end
        local animationData = self.combatMgr:GetAnimationData(petData.animation_id)
        return string.format(CombatUtil.npcAnimationPath, animationData.controller_id)
    elseif rType == "Skin" and fighter.type == FighterType.Pet then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looks_type_unreal_skin then -- 先检查幻化
                return string.format(CombatUtil.npcSkinPath, v.looks_val)
            end
        end

        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_pet_skin then -- 再检查皮肤
                return string.format(CombatUtil.npcSkinPath, v.looks_val)
            end
        end
        local petData = self.combatMgr:GetPetBaseData(fighter.base_id)
        return string.format(CombatUtil.npcSkinPath, petData.skin_id_0)
    elseif rType == "WeaponEffect" and (fighter.type == FighterType.Pet) then
        local petData = self.combatMgr:GetPetBaseData(fighter.base_id)
        petData.effects = {}
        for k,v in pairs(fighter.looks) do
            if v.looks_type == SceneConstData.looks_type_unreal_skin then -- 先检查幻化
                for i, cfg in pairs(DataPet.data_pet_skin) do
                    if cfg.skin_id == v.looks_val and cfg.model_id == v.looks_mode then
                        petData.effects = cfg.effects
                        break
                    end
                end
                if petData.skin_id_0 == v.looks_val then
                    petData.effects = petData.effects_0
                elseif petData.skin_id_1 == v.looks_val then
                    petData.effects = petData.effects_1
                elseif petData.skin_id_2 == v.looks_val then
                    petData.effects = petData.effects_2
                elseif petData.skin_id_3 == v.looks_val then
                    petData.effects = petData.effects_3
                elseif petData.skin_id_s0 == v.looks_val then
                    petData.effects = petData.effects_s0
                elseif petData.skin_id_s1 == v.looks_val then
                    petData.effects = petData.effects_s1
                elseif petData.skin_id_s2 == v.looks_val then
                    petData.effects = petData.effects_s2
                elseif petData.skin_id_s3 == v.looks_val then
                    petData.effects = petData.effects_s3
                end
                break
            end
        end

        if #petData.effects == 0 then
            for k,v in pairs(fighter.looks) do
                if v.looks_type == SceneConstData.looktype_pet_skin then -- 再检查皮肤
                    for i, cfg in pairs(DataPet.data_pet_skin) do
                        if cfg.skin_id == v.looks_val and cfg.model_id == v.looks_mode then
                            petData.effects = cfg.effects
                            break
                        end
                    end
                    if petData.skin_id_0 == v.looks_val then
                        petData.effects = petData.effects_0
                    elseif petData.skin_id_1 == v.looks_val then
                        petData.effects = petData.effects_1
                    elseif petData.skin_id_2 == v.looks_val then
                        petData.effects = petData.effects_2
                    elseif petData.skin_id_3 == v.looks_val then
                        petData.effects = petData.effects_3
                    elseif petData.skin_id_s0 == v.looks_val then
                        petData.effects = petData.effects_s0
                    elseif petData.skin_id_s1 == v.looks_val then
                        petData.effects = petData.effects_s1
                    elseif petData.skin_id_s2 == v.looks_val then
                        petData.effects = petData.effects_s2
                    elseif petData.skin_id_s3 == v.looks_val then
                        petData.effects = petData.effects_s3
                    end
                    break
                end
            end
        end
        if #petData.effects ~= 0 then
            local resid = DataEffect.data_effect[petData.effects[1].effect_id].res_id
            local psth = string.format("prefabs/effect/%s.unity3d", tostring(resid))
            -- BaseUtils.dump(fighter.looks, "宠物外观！！！！！！！！！")
            return string.format("prefabs/effect/%s.unity3d", tostring(resid))
        end
    -- elseif rType == "WeaponEffect" and (fighter.type == FighterType.Unit) then
    --     local npcData = self.combatMgr:GetNpcBaseData(fighter.base_id)

    --     if #npcData.effects ~= 0 then
    --         local resid = DataEffect.data_effect[npcData.effects[1].effect_id].res_id
    --         local psth = string.format("prefabs/effect/%s.unity3d", tostring(resid))
    --         -- BaseUtils.dump(fighter.looks, "宠物外观！！！！！！！！！")
    --         return string.format("prefabs/effect/%s.unity3d", tostring(resid))
    --     end
    -- Child 孩子资源
    elseif rType == "Model" and fighter.type == FighterType.Child then
        local childData = self.combatMgr:GetChildBaseData(fighter.base_id)
        local modelId = childData.model_id
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_pet_skin and v.looks_mode ~= 0 then
                return string.format(CombatUtil.npcModelPath, v.looks_mode)
            end
        end
        return string.format(CombatUtil.npcModelPath, modelId)
    elseif rType == "Ctrl" and fighter.type == FighterType.Child then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_child_animation then
                local animationData = self.combatMgr:GetAnimationData(v.looks_val)
                return string.format(CombatUtil.npcAnimationPath, animationData.controller_id)
            end
        end

        local childData = self.combatMgr:GetChildBaseData(fighter.base_id)
        -- local animationData = data_animation.data_npc_data[childData.animation_id]
        local animationData = self.combatMgr:GetAnimationData(childData.animation_id)
        return string.format(CombatUtil.npcAnimationPath, animationData.controller_id)
    elseif rType == "Skin" and fighter.type == FighterType.Child then
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_pet_skin then
                return string.format(CombatUtil.npcSkinPath, v.looks_val)
            end
        end
        local childData = self.combatMgr:GetChildBaseData(fighter.base_id)
        return string.format(CombatUtil.npcSkinPath, childData.skin_id_0)
    elseif rType == "WeaponEffect" and (fighter.type == FighterType.Child) then
        local childData = self.combatMgr:GetChildBaseData(fighter.base_id)
        childData.effects = {}
        for k,v in pairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_pet_skin then
                if childData.skin_id_0 == v.looks_val then
                    childData.effects = childData.effects_0
                elseif childData.skin_id_1 == v.looks_val then
                    childData.effects = childData.effects_1
                elseif childData.skin_id_2 == v.looks_val then
                    childData.effects = childData.effects_2
                elseif childData.skin_id_3 == v.looks_val then
                    childData.effects = childData.effects_3
                elseif childData.skin_id_s0 == v.looks_val then
                    childData.effects = childData.effects_s0
                elseif childData.skin_id_s1 == v.looks_val then
                    childData.effects = childData.effects_s1
                elseif childData.skin_id_s2 == v.looks_val then
                    childData.effects = childData.effects_s2
                elseif childData.skin_id_s3 == v.looks_val then
                    childData.effects = childData.effects_s3
                end
                break
            end
        end
        if #childData.effects ~= 0 then
            local resid = DataEffect.data_effect[childData.effects[1].effect_id].res_id
            local psth = string.format("prefabs/effect/%s.unity3d", tostring(resid))
            -- BaseUtils.dump(fighter.looks, "宠物外观！！！！！！！！！")
            return string.format("prefabs/effect/%s.unity3d", tostring(resid))
        end
    -- Guard
    elseif rType == "Model" and fighter.type == FighterType.Guard then
        local guardData = self.combatMgr:GetGuardBaseData(fighter.base_id)
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == 70 and v.looks_mode ~= 0 then
                return string.format(CombatUtil.npcModelPath, v.looks_mode)
            end
        end
        return string.format(CombatUtil.npcModelPath, guardData.res_id)
    elseif rType == "Ctrl" and fighter.type == FighterType.Guard then
        local guardData = self.combatMgr:GetGuardBaseData(fighter.base_id)
        local animationData = self.combatMgr:GetAnimationData(guardData.animation_id)
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == 71 and v.looks_mode ~= 0 then
                if v.looks_mode == 99999 then
                    return string.format(CombatUtil.playerCtrlPath, (fighter.sex == 0 and "female" or "male"))
                else
                    animationData = self.combatMgr:GetAnimationData(v.looks_mode)
                end
            end
        end
        if animationData == nil then
            Log.Error("[战斗]缺少动作基础信息(animation_data):[AnimationId:" .. npcData.animation_id .. "][NpcBaseId:" .. fighter.base_id .. "]")
        end
        if animationData.controller_id == 99999 then
            return string.format(CombatUtil.playerCtrlPath, (fighter.sex == 0 and "female" or "male"))
        else
            return string.format(CombatUtil.npcAnimationPath, animationData.controller_id)
        end
    elseif rType == "Skin" and fighter.type == FighterType.Guard then
        local guardData = self.combatMgr:GetGuardBaseData(fighter.base_id)
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == 70 and v.looks_val ~= 0 then
                return string.format(CombatUtil.npcSkinPath, v.looks_val)
            end
        end
        return string.format(CombatUtil.npcSkinPath, guardData.paste_id)
    end
    return nil
end

function CombatController:GetNpcModelInfo(fighter)
    if fighter.type == FighterType.Unit then
        local npcData = self.combatMgr:GetNpcBaseData(fighter.base_id)
        return npcData.res
    elseif fighter.type == FighterType.Pet then
        local petData = self.combatMgr:GetPetBaseData(fighter.base_id)
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looks_type_unreal_skin and v.looks_mode ~= 0 then -- 先取幻化
                return v.looks_mode
            end
        end

        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_pet_skin and v.looks_mode ~= 0 then -- 再取皮肤
                return v.looks_mode
            end
        end
        return petData.model_id
    elseif fighter.type == FighterType.Child then
        local childData = self.combatMgr:GetChildBaseData(fighter.base_id)
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == SceneConstData.looktype_pet_skin and v.looks_mode ~= 0 then
                return v.looks_mode
            end
        end
        return childData.model_id
    elseif fighter.type == FighterType.Guard then
        local guardData = self.combatMgr:GetGuardBaseData(fighter.base_id)
        for k, v in ipairs(fighter.looks) do
            if v.looks_type == 70 and v.looks_mode ~= 0 then
                return v.looks_mode
            end
        end
        return guardData.res_id
    end
    return nil
end

function CombatController:GetNpcScale(fighter)
    if fighter.type == FighterType.Unit then
        local npcData = self.combatMgr:GetNpcBaseData(fighter.base_id)
        return npcData.scale / 100
    elseif fighter.type == FighterType.Pet then
        if #fighter.looks > 0 then
            for k, v in ipairs(fighter.looks) do
                if v.looks_type == SceneConstData.looktype_pet_trans and v.looks_val ~= 0 then
                    local transfData = DataTransform.data_transform[v.looks_val];
                    if transfData ~= nil then
                        return transfData.scale / 100
                    end
                end
            end
        end
        local petData = self.combatMgr:GetPetBaseData(fighter.base_id)
        return petData.scale / 100
    elseif fighter.type == FighterType.Child then
        local childData = self.combatMgr:GetChildBaseData(fighter.base_id)
        return childData.scale / 100
    elseif fighter.type == FighterType.Guard then
        local guardData = self.combatMgr:GetGuardBaseData(fighter.base_id)
        return guardData.scale / 100
    else
        return 1
    end
end

-- On10720
function CombatController:OnFighting(data)
    -- BaseUtils.dump(data, "10720===================：")
    if self.combatMgr.isBrocasting or self.SceneLoaded == false then
        self.brocastCtx:SetNextBrocastData(data)
        print("播报中，等待下次播报")
        return
    end
    if data.combat_result == 1 then
        self.brocastCtx.islastRound = true
    end

    self.combatMgr.RecorderSkip = false
    self.combatMgr.isBrocasting = true
    self.combatMgr.FireEndFightBroad = false
    self.mainPanel.selectState = CombatSeletedState.Idel
    self.mainPanel:OnFighting10720(data)
    self.brocastCtx:Release()
    self.brocastCtx.brocastData = data
    if self.mainPanel.autoaction ~= nil then
        self.mainPanel.autoaction:OnActionEnd()
    end
    if next(self.mainPanel.RguideAction) ~= nil then
        for k,v in pairs(self.mainPanel.RguideAction) do
            v:OnActionEnd()
        end
        for k,v in pairs(self.mainPanel.PguideAction) do
            v:OnActionEnd()
        end
        self.mainPanel.RguideAction = {}
        self.mainPanel.PguideAction = {}
    end
    local syncSupporter = SyncSupporter.New(self.brocastCtx)
    syncSupporter:AddAction(SummonBrocastAction.New(self.brocastCtx))
    syncSupporter:AddEvent(CombatEventType.End, self.PlayBrocast, self)
    syncSupporter:Play()
end

function CombatController:PlayBrocast()
    if self.brocastCtx == nil then
        return
    end
    self.brocastCtx:AddEndEvent(function() if self.mainPanel ~= nil then self.mainPanel:OnPlayEnd() end end)
    self.brocastCtx:Parse()
    self.brocastCtx:Play()
end

function CombatController:BindWeapon(tpose, fighterData, fighterController, weaponEffectPath, selfassetWrapper)

    local callback = function(wtpose, wtpose2, pathdata)
        if BaseUtils.is_null(tpose) then
            if wtpose ~= nil then GameObject.Destroy(wtpose) end
            if wtpose2 ~= nil then GameObject.Destroy(wtpose2) end
            return
        end

        local weaponTpose = wtpose
        local weaponTpose2 = wtpose2

        if weaponTpose ~= nil then
            Utils.ChangeLayersRecursively(weaponTpose.transform, "CombatModel")
        end

        if weaponTpose2 ~= nil then
            Utils.ChangeLayersRecursively(weaponTpose2.transform, "CombatModel")
        end

        local point = nil
        if fighterData.classes == CombatClasses.Ranger or fighterData.classes == CombatClasses.Devine then
            point = BaseUtils.GetChildPath(tpose.transform, "Bip_L_Weapon")
        else
            point = BaseUtils.GetChildPath(tpose.transform, "Bip_R_Weapon")
        end

        local t = weaponTpose:GetComponent(Transform)
        weaponTpose.name = "Mesh_Weapon"
        t:SetParent(tpose.transform:Find(point))
        t.localPosition = Vector3.zero
        t.localRotation = Quaternion.identity
        t.localScale = Vector3.one
        table.insert(self.npcResCacheList, {path = pathdata.weaponPath, go = wtpose, type = GoPoolType.Weapon})
        table.insert(self.npcResCacheList, {path = pathdata.weaponEffectPath, go = pathdata.weaponEffect, type = GoPoolType.Effect})

        if weaponTpose2 ~= nil then
            local point = BaseUtils.GetChildPath(tpose.transform, "Bip_L_Weapon")
            local t2 = weaponTpose2:GetComponent(Transform)
            weaponTpose2.name = "Mesh_Weapon"
            t2:SetParent(tpose.transform:Find(point))
            t2.localPosition = Vector3.zero
            t2.localRotation = Quaternion.identity
            t2.localScale = Vector3.one
            table.insert(self.npcResCacheList, {path = pathdata.weaponPath, go = wtpose2, type = GoPoolType.Weapon})
            if pathdata.weaponEffectPath2 ~= nil then
                table.insert(self.npcResCacheList, {path = pathdata.weaponEffectPath2, go = pathdata.weaponEffect2, type = GoPoolType.Effect})
            else
                table.insert(self.npcResCacheList, {path = pathdata.weaponEffectPath, go = pathdata.weaponEffect2, type = GoPoolType.Effect})
            end
        end
    end
    local weaponLoader = WeaponTposeLoader.New(fighterData.classes, fighterDatasex, fighterData.looks, callback)
end


function CombatController:UpdateSelfHpBar()
    if self.mainPanel == nil then
        return
    end
    self.mainPanel.headInfoPanel:UpdateRoleInfo(self.selfData)
    if self.selfPetData ~= nil then
        self.mainPanel.headInfoPanel:UpdatePetInfo(self.selfPetData)
    end
end

function CombatController:ChangeTransitionAmount(val)
    if not BaseUtils.is_null(self.transition) then
        self.transition:SetActive(true)
        self.transition:GetComponent(Image).material:SetFloat("_Amount", val)
        if val > 0.07 then
            LuaTimer.Add(20, function() self:ChangeTransitionAmount(val - 0.06) end)
        else
            self.transition:SetActive(false)
        end
    end
end

-- On10721
function CombatController:PlayBuff(data)
    if self.combatMgr.isFighting == false then
        return
    end
    if self.brocastCtx == nil then
        return
    end
    self.brocastCtx:ReleaseBuff()
    self.brocastCtx:SetBuffBroadData(data)
    self.brocastCtx:ParseBuffBroad()
    self.brocastCtx:PlayBuffBroad()
end

-- On10722
function CombatController:PlaySpecial(data)
    if self.brocastCtx == nil then
        return
    end
    self.brocastCtx:ReleaseSpecial()
    self.brocastCtx:SetSpecialData(data.fighter_changes)
    self.brocastCtx:ParseSpecial()
    self.brocastCtx:PlaySpecial()
end

-- 点击事件
function CombatController:OnPointerClick(fighterData)
    if fighterData.group ~= self.selfData.group then
        self.mainPanel:OnFighterClick(fighterData)
    end
end

-- 长按事件
function CombatController:OnPointerHold(fighterData)
    if self.mainPanel == nil then
        return
    end
    self.mainPanel:OnPointerHold(fighterData)
end

-- 战斗结束
function CombatController:OnEndFighting(result, msg, gl_list)
    if self.combatMgr.isBrocasting and self.combatMgr.isWatching == false then
        self.combatMgr.lastCombatType = 0
        print(self.combatMgr.isWatching)
        print("播报中，等待播报完结算")
        self.brocastCtx:AddEndEvent(function()
            DanmakuManager.Instance.model:ClearDanmaku()
            DanmakuManager.Instance.model:Show()
            self.mainPanel:ShowFinalPanel(result, msg, gl_list)
        end)
    elseif self.combatMgr.isWatching or self.combatMgr.isWatchRecorder then
        self:EndOfCombat()
        if self.combatMgr.isWatching then
            self.combatMgr.lastCombatType = 1
        end
        self.combatMgr.isWatching = false
        self.combatMgr.isWatchRecorder = false
    else
        self.mainPanel:ShowFinalPanel(result, msg, gl_list)
    end
end

-- 处理buff信息
function CombatController:DealInitBuff(fighterId, buffList)
    if buffList ~= nil then
        for _, data in ipairs(buffList) do
            local buffInitAction = BuffInitAction.New(self.brocastCtx, buffList, fighterId)
            buffInitAction:Play()
        end
    end
end

-- 战斗指挥功能
function CombatController:OnCommandClick(num)
    if num == 8 then
        self.combatMgr:OpenCmdSetting()
        -- NoticeManager.Instance:FloatTipsByString(TI18N("自定义指挥暂未开放，敬请期待！"))
    end
    if self.mainPanel.selectID ~= nil then
        self.combatMgr:Send10741(self.mainPanel.selectID, num)
    end
end

function CombatController:SetCommand(CommandID)
    if self.mainPanel ~= nil then
        self.mainPanel.mixPanel:CreatOrGetCommand(self.mainPanel.selectID,CommandID)
    end
end

function CombatController:ExitWatching()
    if self.combatMgr.isWatching then
        self.combatMgr:Send10706()
    else
        self.combatMgr:Send10746()
        self:EndOfCombat(1,"")
    end
end

-- 处理战斗内队友说话(由聊天逻辑过来)
function CombatController:ShowMemberMsg(id, platform, zone_id, msg, BubbleID)
    if id == 0 then
        return
    end
    local ctr = self.brocastCtx:FindFighterByUid(id, platform, zone_id)
    if ctr ~= nil and ctr.fighterData.type == FighterType.Role then
        local talkAction = TalkBubbleAction.New(self.brocastCtx, ctr.fighterData.id, msg, BubbleID)
        talkAction:Play()
    end
end

-- 组装选择技能数据
function CombatController:BuildSelectSkillData(data)
    local dataTable = {}
    dataTable.round = data.round
    dataTable.time = data.time
    dataTable.skill_cooldown_list = data.skill_cooldown_list
    dataTable.skill_cooldown_list_pet = data.skill_cooldown_list_pet
    dataTable.backup_pets = data.backup_pets
    dataTable.backup_childs = data.backup_childs
    dataTable.summon_num = data.summon_num
    dataTable.use_item_num = data.use_item_num
    dataTable.items = data.items
    dataTable.guide = data.guide
    return dataTable
end

function CombatController:BuildBuffUpdateData(data)
    local dataTable = {}
    dataTable.buff_list = data.buff_list
    dataTable.buff_play_list = data.buff_play_list2
    dataTable.fighter_status_list = data.fighter_status_list
    return dataTable
end

function CombatController:CreatCombatScene()
    if self.CombatScene == nil then
        local CombatScene = GameObject.Find("CombatElements") or GameObject("CombatElements")
        GameObject.DontDestroyOnLoad(CombatScene)
        self.CombatScene = CombatScene
        -- local lastObj_num = CombatScene.transform.childCount
        -- if lastObj_num > 0 then
        --     for i = 1, lastObj_num do
        --         local child = CombatScene.transform:GetChild(i-1)
        --         print(child.gameObject.name)
        --         GameObject.Destroy(child.gameObject)
        --     end
        -- end

        -- 新增了战斗地图专用摄像机
        local camera = GameObject("CombatMapCamera")
        GameObject.DontDestroyOnLoad(camera)
        table.insert(self.combatSceneGo, camera)
        camera.transform.position = Vector3(1000,1000,1000)
        -- camera:SetActive(false)
        camera.layer = 10
        local cameraCom = camera:AddComponent(Camera)
        camera:AddComponent(EventSystems.PhysicsRaycaster)
        -- cameraCom.cullingMask = 2 ^ LayerMask.NameToLayer("TransparentFX")
        cameraCom.cullingMask = 2
        self.combatMapCamera = cameraCom
        cameraCom.clearFlags = CameraClearFlags.Depth;
        cameraCom.orthographic = true
        cameraCom.orthographicSize = 1.871345;
        cameraCom.nearClipPlane = -20;
        cameraCom.depth = 2
        camera.transform:SetParent(CombatScene.transform, true)

        local angle = CombatUtil.camera_angle
        local z = CombatUtil.camera_z
        local y = math.tan(angle / 180 * math.pi) * math.abs(z)
        local cct = self.combatMapCamera.transform
        cct.position = Vector3(0, y, z)
        cct.rotation  = Quaternion.identity
        cct:Rotate(Vector3(angle, 0, 0))

        camera = GameObject("CombatCamera")
        GameObject.DontDestroyOnLoad(camera)
        table.insert(self.combatSceneGo, camera)
        camera.transform.position = Vector3(1000,1000,1000)
        -- camera:SetActive(false)
        camera.layer = 10
        local cameraCom = camera:AddComponent(Camera)
        camera:AddComponent(EventSystems.PhysicsRaycaster)
        cameraCom.cullingMask = -6968
        self.combatCamera = cameraCom
        cameraCom.clearFlags = CameraClearFlags.Depth;
        cameraCom.orthographic = true
        cameraCom.orthographicSize = 1.871345;
        cameraCom.nearClipPlane = -20;
        cameraCom.depth = 2
        camera.transform:SetParent(CombatScene.transform, true)

        angle = CombatUtil.camera_angle
        z = CombatUtil.camera_z
        y = math.tan(angle / 180 * math.pi) * math.abs(z)
        cct = self.combatCamera.transform
        cct.position = Vector3(0, y, z)
        cct.rotation  = Quaternion.identity
        cct:Rotate(Vector3(angle, 0, 0))


        local CombatEffectCamera = GameObject.Instantiate(camera) -- 创建覆盖特效摄像机
        CombatEffectCamera.gameObject.name = "CombatEffectCamera"
        GameObject.DontDestroyOnLoad(CombatEffectCamera)
        self.effectCamera = CombatEffectCamera.gameObject:GetComponent(Camera)
        self.effectCamera.cullingMask = -7988
        self.effectCamera.depth = 3
        table.insert(self.combatSceneGo, CombatEffectCamera)
        CombatEffectCamera.transform:SetParent(CombatScene.transform, true)


        local combatCanvas = GameObject("CombatCanvas")
        GameObject.DontDestroyOnLoad(combatCanvas)
        table.insert(self.combatSceneGo, combatCanvas)
        local canvas = combatCanvas:AddComponent(Canvas)
        canvas.renderMode = RenderMode.ScreenSpaceCamera
        canvas.worldCamera = GameObject.Find("UICamera"):GetComponent(Camera)
        canvas.planeDistance = 1
        canvas.sortingOrder = -1
        local canvasScaler = combatCanvas:AddComponent(CanvasScaler)
        canvasScaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize
        canvasScaler.referenceResolution = Vector2(960, 540)
        canvasScaler.matchWidthOrHeight = 0.5
        canvasScaler.referencePixelsPerUnit = 1
        Utils.ChangeLayersRecursively(camera.transform, "CombatModel")
        self.combatMgr.combatCanvas = combatCanvas
        combatCanvas.transform:SetParent(CombatScene.transform, true)

        self.SceneElements = GameObject.Find("SceneElements")
        SceneManager.Instance:SetSceneActive(false)
    else
        -- 这里被坑了，加了个不销毁摄像机，算个数要加1
        local num = self.CombatScene.transform.childCount
        if num>7 then
            local temp = {}
            for i=7, num -1 do
                table.insert(temp, self.CombatScene.transform:GetChild(i).gameObject)
            end
            for i,v in ipairs(temp) do
                if not BaseUtils.is_null(v) then
                    GameObject.Destroy(v)
                end
            end
        end
    end

    if self.map == nil then
        local mapPath = self.combatMgr.mapPath
        local combatMap = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.combat_mapui))
        GameObject.DontDestroyOnLoad(combatMap)
        self.map = combatMap
        self.mapPath = mapPath
        local sprite = self.assetWrapper:GetMainAsset(mapPath)
        combatMap.gameObject.renderer.sharedMaterial.mainTexture = sprite
        table.insert(self.combatSceneGo, combatMap)

        -- local spriteCom = combatMap:AddComponent(SpriteRenderer)
        -- spriteCom.sprite = sprite
        local cmt = combatMap.transform
        cmt:SetParent(self.combatCamera.transform)
        cmt.localPosition = Vector3(0,0,100)
        cmt.localScale = CombatUtil.map_scale
        -- Utils.ChangeLayersRecursively(cmt, "CombatModel")
        -- 新增了地面遮罩特效类型，战斗地面单独用一个layer
        Utils.ChangeLayersRecursively(cmt, "TransparentFX")
        combatMap.transform:SetParent(nil)
        combatMap.transform:SetParent(self.CombatScene.transform, true)

        self:AdaptWideScreen()
    else
        self.map:SetActive(true)
        self.combatMapCamera.gameObject:SetActive(true)
        self.combatCamera.gameObject:SetActive(true)
        self.effectCamera.gameObject:SetActive(true)
        local mapPath = self.combatMgr.mapPath
        if mapPath ~= self.mapPath or self.map.gameObject.renderer.sharedMaterial.mainTexture == nil then
            self.mapPath = mapPath
            local sprite = self.assetWrapper:GetMainAsset(mapPath)
            if sprite ~= nil then
                self.map.gameObject.renderer.sharedMaterial.mainTexture = sprite
            end
        end
    end
    self.map.gameObject.renderer.sharedMaterial.color = Color.white
    if BaseUtils.IsVerify then
        self.map.gameObject:GetComponent(Renderer).sharedMaterial.color = BaseUtils.GetVerifyColor()
    end
    SceneManager.Instance:SetSceneActive(false)

    if self.enterData.combat_type == 60 then
        GloryManager.Instance:ShowFightPanel()
    end
    if self.enterData.combat_type == 62 and not (self.combatMgr.isWatching or self.combatMgr.isWatchRecorder) then
        StarChallengeManager.Instance:ShowFightPanel()
        StarChallengeManager.Instance:ShowFightRewardPanel()
    end
    if self.enterData.combat_type == 70 and not (self.combatMgr.isWatching or self.combatMgr.isWatchRecorder) then
        ApocalypseLordManager.Instance:ShowFightPanel()
        ApocalypseLordManager.Instance:ShowFightRewardPanel()
    end
end

function CombatController:EndOfCombat()
    if self.isdestroying or self.SceneLoaded == false then
        return
    end
    self.combatMgr.RecorderSkip = false
    self.SceneLoaded = false
    self.isdestroying = true
    local st = os.clock()
    local func1 = function()
        print("<color='#ff0000'>开始战斗删除场景</color>")
        SceneManager.Instance:SetSceneActive(true)
        -- if self.assetWrapper ~= nil then
        --     self.assetWrapper:DeleteMe()
        --     self.assetWrapper = nil
        --     self.combatMgr.assetWrapper = nil
        -- end
        if self.modelassetWrapper ~= nil then
            self.modelassetWrapper:DeleteMe()
            self.modelassetWrapper = nil
        end
    end
    local func2 = function()
        self.combatMgr.isBrocasting = false
        self.combatMgr.FireEndFightScene = true
        SceneManager.Instance.sceneModel:PlayBGM()

        self:Destroy()
        self.combatMgr:DoFireEndFight(self.fightResult)
        -- self:DeleteMe()
    end
    local func3 = function()
        print("<color='#00ff00'>删除场景完毕</color>"..tostring(os.clock()-st))
        Connection.Instance:CloseCach()
        Connection.Instance:CloseCachSend()
    end

    local dealFunc1 = function()
        local status, err = xpcall(
            function()
                func1()
            end
            ,function(err) Log.Error("删除战斗用assetWrapper出错:" .. tostring(err)); Log.Error(debug.traceback()) end)
        if not status then
            self.combatMgr.assetWrapper = nil
            Log.Error("结束战斗出错！删除战斗用assetWrapper出错")
        end
    end
    local dealFunc2 = function()
        local status, err = xpcall(
            function()
                func2()
            end
            ,function(err) Log.Error("删除CombatController出错:" .. tostring(err)); Log.Error(debug.traceback()) end)
        if not status then
            Log.Error("结束战斗出错！删除CombatController出错")
            CombatManager.Instance.controller = nil
        end
    end
    local dealFunc3 = function()
        local status, err = xpcall(
            function()
                func3()
            end
            ,function(err) Log.Error("协议缓存释放出错:" .. tostring(err)); Log.Error(debug.traceback()) end)
        if not status then
            Log.Error("结束战斗出错！协议缓存释放出错")
        end
    end
    dealFunc1()
    dealFunc2()
    dealFunc3()

end

function CombatController:GetRoleMeshNode(tpose, resType, fighter)
    local tcc = tpose.transform.childCount
    for i = 1, tcc do
        local child = tpose.transform:GetChild(i - 1)
        if string.match(child.gameObject.name, "Mesh_") ~= nil then
            return child
        end
    end
    local mesh = tpose.transform:Find(string.format("Mesh_%s", CombatUtil.GetResID(resType, fighter)))
    if mesh ~= nil then
        return mesh
    end
    Log.Error("战斗创建角色单位找不到Mech_信息:" .. path)
    return nil
end

function CombatController:RoleSubPackPrase(body, skin, headModel, headSkin, classes, sex)
    local roleRes = {bodyModelPath = body, bodySkinPath = skin, headModelPath = headModel, headSkinPath = headSkin, classes = classes, sex = sex}
        roleRes = SubpackageManager.Instance:RoleResources(roleRes, true)
    return roleRes.bodyModelPath, roleRes.bodySkinPath, roleRes.headModelPath, roleRes.headSkinPath, roleRes.classes, roleRes.sex
end

function CombatController:NPCSubPackPrase(body, ctrl, skin, modelId)
    local npcRes = {modelPath = body, ctrlPath = ctrl, skinPath = skin, modelId = modelId}
    npcRes = SubpackageManager.Instance:NpcResources(npcRes, true)
    return npcRes.modelPath, npcRes.ctrlPath, npcRes.skinPath, npcRes.modelId, npcRes.usePack
end

function CombatController:GetRoleResources(id)
    local roleRes = self.brocastCtx.fighterResDict[id]
    if roleRes == nil then
        return 
    else
        return roleRes.body, roleRes.skin, roleRes.headModel, roleRes.headSkin, roleRes.classes, roleRes.sex
    end
end

function CombatController:GetNPCResources(id)
    local npcRes = self.brocastCtx.fighterResDict[id]
    if npcRes == nil then
        return 
    else
        return npcRes.body, npcRes.ctrl, npcRes.skin, npcRes.modelId, npcRes.usePack
    end
end

-- 处理是否有叛变播报
function CombatController:DealMutiny(callback)
    local has_mutiny = false
    local fighterList = self.enterData.fighter_list
    -- for _,fighter in pairs(fighterList) do
    --     for k,v in pairs(fighter.looks) do
    --         if v.looks_type == 72 then
    --             has_mutiny = true
    --             break
    --         end
    --     end
    --     if has_mutiny then
    --         break
    --     end
    -- end
    -- if has_mutiny then
        local action = MutinyAction.New(self.brocastCtx, self.enterData)
        action:AddEvent(CombatEventType.End, callback)
        action:Play()
    -- else
        -- callback()
    -- end
end

function CombatController:BeforeTurnBegin()
    if self.enterData.combat_type == 60 then -- 爵位挑战
        self:ShowGuidence()
    end
end

function CombatController:AdaptWideScreen()
    if BaseUtils.IsWideScreen() then
        self.map.transform.localScale = CombatUtil.map_scale_widescreen
    else
        self.map.transform.localScale = CombatUtil.map_scale
    end
end


-----------------------------------------------------------
-----------------------------------------------------------
FighterCombo = FighterCombo or BaseClass()
function FighterCombo:__init(fighterId, fighter, fighterData)
    self.fighterId = fighterId
    self.fighter = fighter
    self.fighterData = fighterData
    self.halo = nil
end

