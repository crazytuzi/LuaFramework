-- ----------------------------
-- 剧情
-- hosr
-- ----------------------------
DramaManager = DramaManager or BaseClass(BaseManager)

function DramaManager:__init()
    if DramaManager.Instance then
        return
    end
    DramaManager.Instance = self

    DramaVirtualUnit.New()
    DramaManagerCli.New()
    DramaSceneTalk.New()
    -- DramaActionFactory.New()

    self.model = DramaModel.New()

    self:AddHandler()

    -- 是否初始化
    self.IsInit = false
    -- 初始化标志
    self.InitFlag = 0

    self.listener = function() self:OnSelfLoad() end
    self.listener1 = function() self:OnSceneLoad() end

    self.dramaData = DramaData.New()

    -- 是引导剧情
    self.dramaGuide = false

    EventMgr.Instance:AddListener(event_name.begin_fight, function() self:OnBeginFight() end)
    EventMgr.Instance:AddListener(event_name.end_fight, function() self:OnEndFight() end)

    --- 战斗中触发的剧情缓存，暂时只有开启功能会有
    self.inFightDrama = nil

    self.onceDic = {}
end

function DramaManager:__delete()
end

function DramaManager:AddHandler()
    self:AddNetHandler(11000, self.On11000)
    self:AddNetHandler(11001, self.On11001)
    self:AddNetHandler(11002, self.On11002)
    self:AddNetHandler(11003, self.On11003)
    self:AddNetHandler(11004, self.On11004)
    self:AddNetHandler(11005, self.On11005)
    self:AddNetHandler(11006, self.On11006)
    self:AddNetHandler(11007, self.On11007)
    self:AddNetHandler(11010, self.On11010)
    self:AddNetHandler(11020, self.On11020)
    self:AddNetHandler(11023, self.On11023)
    self:AddNetHandler(11024, self.On11024)
end

function DramaManager:Clear()
    self.IsInit = false
    self.onceDic = {}
    DramaVirtualUnit.Instance:Clear()
    self.model:Clear()
end

function DramaManager:RequestInitData()
    self:Clear()
    -- if not LoginManager.Instance.first_enter then
        -- self:Clear()
    -- end
    -- LoginManager.Instance.first_enter = false

    if not self.IsInit then
        if SceneManager.Instance.sceneElementsModel:Get_Self_Loaded() then
            EventMgr.Instance:AddListener(event_name.scene_load, self.listener1)
        else
            EventMgr.Instance:AddListener(event_name.self_loaded, self.listener)
        end
    end
    self:Send11024()
end

function DramaManager:OnSelfLoad()
    EventMgr.Instance:RemoveListener(event_name.self_loaded, self.listener)
    if not self.IsInit then
        self:Send11005()
    end
end

function DramaManager:OnSceneLoad()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.listener1)
    if not self.IsInit then
        self:Send11005()
    end
end

-- -------------------------------------------
-- 协议处理
-- -------------------------------------------

-- 剧情播放准备就绪，开始播放剧情
function DramaManager:Send11000()
    self:Send(11000, {})
end

function DramaManager:On11000(dat)
end

-- 继续剧情
function DramaManager:Send11001(id, val)
    self:Send(11001, {id = id, val = val})
end

function DramaManager:On11001(dat)
end

-- 跳过剧情
function DramaManager:Send11002()
    self:Send(11002, {})
end

function DramaManager:On11002(dat)
end

-- 请求角色隐藏状态
function DramaManager:Send11003()
    self:Send(11003, {})
end

function DramaManager:On11003(dat)
end

-- 剧情单位操作
function DramaManager:Send11004(id, type)
    self:Send(11004, {id = id, type = type})
end

function DramaManager:On11004(dat)
end

-- 场境加载完成, 剧情初始化
function DramaManager:Send11005()
    self:Send(11005, {})
end

function DramaManager:On11005(dat)
    self.InitFlag = dat.flag
end

-- 完成指引
function DramaManager:Send11006(id)
    self:Send(11006, {id = id})
end

function DramaManager:On11006(dat)
end

-- 重置剧情场景，并继续播放剧情
function DramaManager:Send11007()
    self:Send(11007, {})
end

function DramaManager:On11007(dat)
end

-- 剧情播放
function DramaManager:On11010(dat)
    self.dramaData:SetData(dat)
    --BaseUtils.dump(self.dramaData, "剧情数据>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    if DramaManager.Instance.IsInit then
        if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight then
            self.inFightDrama = self.dramaData
        else
            self.model:BeginDrama(self.dramaData)
        end
    else
        self.model:InitDrama(self.dramaData)
    end
end

-- 播放剧本
function DramaManager:On11020(dat)
end

-- 触发剧情时，都由服务端处理的剧情，突然发了个结束剧情的动作给我，蛋疼啊
function DramaManager:Check(dat)
    if self.dramaData ~= nil and self.dramaData.id ~= dat.id then
        if #dat.action_list == 1 then
            if dat.action_list[1].type == DramaEumn.ActionType.Endplot then
                return false
            end
        end
    end
    return true
end

function DramaManager:OnBeginFight()
end

function DramaManager:OnEndFight()
    if self.inFightDrama ~= nil then
        self.model:BeginDrama(self.inFightDrama)
        self.inFightDrama = nil
    end
end


function DramaManager:Send11023(id)
    self:Send(11023, {id = id})
end

function DramaManager:On11023(dat)
    -- BaseUtils.dump(dat, "11023")
end

function DramaManager:Send11024()
    self:Send(11024, {})
end

function DramaManager:On11024(dat)
    -- BaseUtils.dump(dat, "11024")
    self.onceDic = {}
    for i,v in ipairs(dat.list) do
        self.onceDic[v.id] = v.num
    end
end

function DramaManager:Test()
    local action = DramaAction.New()
    action.val = 10000
    local a = DramaGetPetNew.New()
    a.callback = function ()
        -- body
        a:DeleteMe()
        a = nil
    end
    a:Show(action)
end