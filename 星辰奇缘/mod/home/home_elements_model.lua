HomeElementsModel = HomeElementsModel or BaseClass(BaseModel)

local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2

function HomeElementsModel:__init()
    self.HomeUnitView_List = {}

    self.WaitForCreateUnitData_List = {}

    self.Edit_List = {}

    self.tickCount = 0

    self.removeOutView = true

    self.flower_action = nil

    self.functionUnit = nil

    self.createTick = SceneManager.Instance.sceneElementsModel.createTick
    self.createTposeTick = SceneManager.Instance.sceneElementsModel.createTposeTick

    self._home_canvas_inited = function()
        self:home_canvas_inited()
    end

    self._bean_data_update = function(data)
        self:bean_data_update(data)
    end
    EventMgr.Instance:AddListener(event_name.home_canvas_inited, self._home_canvas_inited)
    EventMgr.Instance:AddListener(event_name.home_bean_info_update, self._bean_data_update)

    self._map_click = function()
        self:map_click()
    end
    EventMgr.Instance:AddListener(event_name.map_click, self._map_click)

    self.childPlantUpdate = function()
        self:CreateChildPlant()
    end
    QuestManager.Instance.childPlantUpdate:AddListener(self.childPlantUpdate)
end

function HomeElementsModel:__delete()

end

function HomeElementsModel:SetSceneActive(active)
    if active then

    end
end

-- FixedUpdate 驱动所有场景单位(主要是移动)
function HomeElementsModel:FixedUpdate()
    for k,v in pairs(self.Edit_List) do
        v:UpdateMove()
    end

    if HomeManager.Instance.canvasInit then
        if self.functionUnit ~= nil then
            local p = self.functionUnit.transform.position
            if self.functionUnit.boxCollider ~= nil then
                p = Vector3(p.x, p.y + self.functionUnit.boxCollider.size.y + self.functionUnit.boxCollider.center.y, p.z)
            end
            HomeManager.Instance.homeCanvasView.functionButton.transform.localPosition = CombatUtil.WorldToUIPoint(SceneManager.Instance.MainCamera.camera, p)
        end
    end
end

-- OnTick 每0.2秒执行一次
function HomeElementsModel:OnTick()
    self.tickCount = self.tickCount + 1
    if self.tickCount % self.createTick == 0 then
        self:CreateUnits()
    end
    -- if self.tickCount % self.createTposeTick == 0 then
    --     self:CreateTpose()
    -- end
    if self.tickCount % 5 == 0 then
        self:RemoveOutViewUnits()
    end
    -- if self.tickCount % 11 == 0 then
    --     self:SubCreateCount()
    --     self:SubCreateTposeCount()
    -- end
    self:CheckUnitPosition()
    self:CheckTeleporter()
    self:FlowerAction()
    self:CreateChildPlant()
end

function HomeElementsModel:CleanElements()
    for k,v in pairs(self.HomeUnitView_List) do
        self:RemoveUnit(k)
    end
    self.WaitForCreateUnitData_List = {}

    self.flower_action = nil
    self.functionUnit = nil
end

-- 更新家园家具
function HomeElementsModel:UpdateUnitList(data_list, noCreate)
    local mapId = SceneManager.Instance:CurrentMapId()
    if mapId == 30012 or mapId == 30013 then
        for k, v in pairs(data_list) do
            local id = v.id
            local battleid = v.battle_id
            local uniquenpcid = BaseUtils.get_unique_npcid(id, battleid)
            local home
            home = self.WaitForCreateUnitData_List[uniquenpcid]
            if home == nil then
                local hv = self.HomeUnitView_List[uniquenpcid]
                if hv ~= nil then
                    home = hv.data
                end
            end

            if home ~= nil then
                local update_scene_mark = false
                local update_dir_mark = false

                if v.x ~= nil and v.y ~= nil and (home.x ~= v.x or home.y ~= v.y) then update_scene_mark = true end
                if home.dir ~= v.dir then update_dir_mark = true end

                home:update_data(v)
                local hv = self.HomeUnitView_List[uniquenpcid]
                if hv ~= nil then
                    if update_scene_mark then
                        hv:SetPosition(home)
                    end
                    if update_dir_mark then
                        hv:SetDir(home.dir)
                    end
                end
            elseif not noCreate then
                -- BaseUtils.dump(v, "------------")
                if DataFamily.data_unit[v.base_id] ~= nil and DataFamily.data_unit[v.base_id].type ~= 15 then -- 如果是地板则忽略
                    home = HomeData.New()
                    home:update_data(v)
                    self.WaitForCreateUnitData_List[uniquenpcid] = home

                    self:CreateUnit(uniquenpcid, home)
                end
            end
        end
    end
end

-- 创建缓存的单位
function HomeElementsModel:CreateUnits()
    local mapId = SceneManager.Instance:CurrentMapId()
    if mapId == 30012 or mapId == 30013 then
        for k,v in pairs(self.WaitForCreateUnitData_List) do -- 优先加载npc
            if DataFamily.data_unit[v.base_id] ~= nil and DataFamily.data_unit[v.base_id].type ~= 15 then -- 如果是地板则忽略
                self:CreateUnit(k, v)
            end
        end
    end
end

-- 移除视野外的单位
function HomeElementsModel:RemoveOutViewUnits()
    if not self.removeOutView then return end

    local removeList = {}
    for k,v in pairs(self.HomeUnitView_List) do
        if not BaseUtils.is_null(v.gameObject) then
            local p = v.gameObject.transform.position
            if not v.data.exclude_outofview and SceneManager.Instance.MainCamera:OutView(p.x, p.y, 1.5)  then
                removeList[k] = v
            end
        end
    end

    for k,v in pairs(removeList) do
        self:RemoveUnit(k)
        self.WaitForCreateUnitData_List[k] = v.data
    end
end

function HomeElementsModel:CreateUnit(uniqueid, unitData)
    if self.HomeUnitView_List[uniqueid] == nil then
        if ( (unitData.exclude_outofview or SceneManager.Instance.MainCamera:InView_big(unitData.x, unitData.y, 1.5))
            )
         and SceneManager.Instance.sceneModel.map_loaded

            then
            -- 开始创建
            local hv = HomeUnitView.New(unitData)
            self.HomeUnitView_List[uniqueid] = hv
            self.WaitForCreateUnitData_List[uniqueid] = nil
            hv:Create()

            return true
        else
            self.WaitForCreateUnitData_List[uniqueid] = unitData
            return false
        end
    else
        -- print(string.format("%s %s", TI18N("家园单位已存在"), uniqueid))
        self.WaitForCreateUnitData_List[uniqueid] = nil
        return false
    end
end

function HomeElementsModel:RemoveUnit(uniqueid)
	local hv = self.HomeUnitView_List[uniqueid]
    if hv ~= nil then -- 已创建的
        hv:DeleteMe()
        self.HomeUnitView_List[uniqueid] = nil
        self.WaitForCreateUnitData_List[uniqueid] = nil
        self.Edit_List[uniqueid] = nil
    else -- 未创建的
        self.WaitForCreateUnitData_List[uniqueid] = nil
    end

    if HomeManager.Instance.canvasInit then
        if self.functionUnit ~= nil and self.functionUnit.data.uniqueid == uniqueid then
            self:SetFunctionUnit()
        end
    end
end

function HomeElementsModel:SetEditUnit(homeUnitView, uniqueid)
	self.Edit_List[uniqueid] = homeUnitView
	homeUnitView.controller.isEdit = true
    homeUnitView.data.isEdit = true

    homeUnitView.transform.position = Vector3(homeUnitView.transform.position.x, homeUnitView.transform.position.y, homeUnitView.transform.position.y - 5)

    HomeManager.Instance.model:ShowEditPanel()
    self:GetEditUnitNum()
end

function HomeElementsModel:GetEditUnitNum()
    local num = 0
    for k,v in pairs(self.Edit_List) do
        num = num + 1
    end
    EventMgr.Instance:Fire(event_name.home_eidt_num_update, num)
    return num
end

function HomeElementsModel:CheckUnitPosition()
    for k,v in pairs(self.Edit_List) do
        v:CheckPosition()
    end
end

function HomeElementsModel:PutDown(homeUnitView, uniqueid)
    self.Edit_List[uniqueid] = nil
    homeUnitView.controller.isEdit = false
    homeUnitView.data.isEdit = false
    self:GetEditUnitNum()
end

function HomeElementsModel:ReturnToPriginPos(homeUnitView, uniqueid)
    self.Edit_List[uniqueid] = nil
    homeUnitView.controller.isEdit = false
    homeUnitView.data.isEdit = false
end

function HomeElementsModel:home_canvas_inited()
    if HomeManager.Instance.canvasInit then
        for k,v in pairs(self.HomeUnitView_List) do
            if v.data.status == 3 then
                self:SetEditUnit(v, v.data.uniqueid)
                v:buildGrid()
                v:buildUI()
            end
            v:SetShadow()
        end
    end
end

-- 设置豌豆模型开花
function HomeElementsModel:SetFlowerAction(flower_action)
    self.flower_action = flower_action
end

-- 豌豆模型开花
function HomeElementsModel:FlowerAction()
    local uniqueid = "20081_".. tostring(HomeManager.Instance.model.battle_id)
    if self.flower_action ~= nil then
        local npc = SceneManager.Instance.sceneElementsModel.WaitForCreateUnitData_List[uniqueid]
        if npc ~= nil then
            if npc.tposecallback == nil then
                npc.tposecallback = function(npcView)
                        self:DoFlowerAction(npcView)
                    end
            end
        else
            local npcView = SceneManager.Instance.sceneElementsModel.NpcView_List[uniqueid]
            if npcView ~= nil and npcView.tpose ~= nil then
                self:DoFlowerAction(npcView)
            end
        end
    end
    self:CreateReweardBox()
end

-- 执行豌豆开花的具体操作
function HomeElementsModel:DoFlowerAction(npcView)
    if npcView.FlowerEffectnum == nil or npcView.FlowerEffectnum ~= self.flower_action then
        self:SetFlowerEffect(npcView.tpose, self.flower_action, npcView.FlowerEffectnum)
        npcView.FlowerEffectnum = self.flower_action
    end
end

function HomeElementsModel:bean_data_update(data)
    local bdata = HomeManager.Instance.model.bean_data
    if bdata == nil then
        return
    end
    local num = 0

    if bdata.wake_time > BaseUtils.BASE_TIME and bdata.growth == 0 and bdata.flower_num == 0 then
        num = 5
    else
        num = bdata.flower_num
    end
    self:SetFlowerAction(num)
end

-- 检测家园传送区域
function HomeElementsModel:CheckTeleporter()
    local homeModel = HomeManager.Instance.model
    local home_data = DataFamily.data_home_data[homeModel.home_lev]
    local self_view = SceneManager.Instance.sceneElementsModel.self_view
    if home_data ~= nil and self_view ~= nil and self_view.gameObject ~= nil then
        local teleporterArea = homeModel.teleporterArea[home_data.map_id]
        if teleporterArea ~= nil then
            local p = self_view:GetCachedTransform().localPosition
            p = SceneManager.Instance.sceneModel:transport_big_pos(p.x, p.y)
            -- print(p)
            if (p.x > teleporterArea[1] and p.x < teleporterArea[3] and p.y > teleporterArea[2] and p.y < teleporterArea[4])
                or (p.x > teleporterArea[5] and p.x < teleporterArea[7] and p.y > teleporterArea[6] and p.y < teleporterArea[8])
                or (p.x > teleporterArea[9] and p.x < teleporterArea[11] and p.y > teleporterArea[10] and p.y < teleporterArea[12]) then
                -- print("Ok")
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
                HomeManager.Instance:ExitHome()
            end
        end
    end
end

-- 根据id设置家具为编辑状态
function HomeElementsModel:SetEditById(id)
    local uniqueid = BaseUtils.get_unique_npcid(id, 998)
    if self.HomeUnitView_List[uniqueid] ~= nil then
        self.HomeUnitView_List[uniqueid]:OnPointerHold()
    end
    if self.WaitForCreateUnitData_List[uniqueid] ~= nil then
        self.WaitForCreateUnitData_List[uniqueid].status = 3
    end
end

function HomeElementsModel:SetFlowerEffect(tpose, num, current)
    local effectList = {
        [1] = {effect_id = 101280},
        [2] = {effect_id = 101281},
        [3] = {effect_id = 101282},
        [4] = {effect_id = 101283},
        [5] = {effect_id = 101320},
    }
    if current == nil then
        current = 0
    end
    local temp = {}
    if num ~= nil then
        for i=1, 5 do
            if i<=num then
                table.insert(temp, effectList[i])
            end
        end
    end
    for i=1, 5 do
        local childname = string.format("bp_star_0%s", i)
        local childgo = tpose.transform:Find(childname)
        if childgo ~= nil and childgo.childCount > 0 then
            GameObject.Destroy(childgo:GetChild(0).gameObject)
        end
    end
    TposeEffectLoader.New(tpose, tpose, temp, function()end)
end

function HomeElementsModel:CreateReweardBox()
    local bdata = HomeManager.Instance.model.bean_data
    if HomeManager.Instance.model:CanEditHome() and HomeManager.Instance:IsAtHome() and bdata.beans_rewards ~= nil then
        for i,v in ipairs(bdata.beans_rewards) do
            if v.blid == RoleManager.Instance.RoleData.id and v.blplatform == RoleManager.Instance.RoleData.platform and RoleManager.Instance.RoleData.zone_id == v.blzone_id then
                local uniqueid = BaseUtils.get_unique_npcid(v.id, SceneConstData.battle_id_home_box)
                if SceneManager.Instance.sceneElementsModel.VirtualUnitData_List[uniqueid] == nil then
                    local npcdata = NpcData.New()
                    npcdata.baseid = 20082
                    npcdata.id = v.id
                    npcdata.uniqueid = uniqueid
                    npcdata.x = v.pos_x
                    npcdata.y = v.pos_y
                    npcdata.battleid = SceneConstData.battle_id_home_box
                    npcdata.unittype = SceneConstData.unittype_pick
                    npcdata.name = string.format("%s%s", v.giver_name, TI18N("赠送的宝箱"))
                    SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(uniqueid, npcdata, nil)
                end
            end
        end
    else

    end
end

function HomeElementsModel:CreateChildPlant()
    if HomeManager.Instance.model:CanEditHome() and HomeManager.Instance:IsAtHome() then
            local uniqueid = BaseUtils.get_unique_npcid(76200, 0)
        if QuestManager.Instance.childPlantData ~= nil and QuestManager.Instance.childPlantData.unit_id ~= 0 then
            if SceneManager.Instance.sceneElementsModel.VirtualUnitData_List[uniqueid] == nil then
                local npcdata = NpcData.New()
                npcdata.baseid = QuestManager.Instance.childPlantData.unit_id
                npcdata.id = 76200
                npcdata.uniqueid = uniqueid
                if SceneManager.Instance:CurrentMapId() == 30012 then
                    npcdata.x = 1529
                    npcdata.y = 1089
                else
                    npcdata.x = 2324
                    npcdata.y = 1445
                end
                npcdata.battleid = 0
                npcdata.no_facetopoint = true
                npcdata.unittype = SceneConstData.unittype_npc
                npcdata.name = DataUnit.data_unit[QuestManager.Instance.childPlantData.unit_id].name
                SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(uniqueid, npcdata, nil)
            else
                if SceneManager.Instance.sceneElementsModel.VirtualUnitData_List[uniqueid].baseid ~= QuestManager.Instance.childPlantData.unit_id then
                    local npcdata = NpcData.New()
                    npcdata.baseid = QuestManager.Instance.childPlantData.unit_id
                    npcdata.id = 76200
                    npcdata.uniqueid = uniqueid
                    if SceneManager.Instance:CurrentMapId() == 30012 then
                        npcdata.x = 1529
                        npcdata.y = 1089
                    else
                        npcdata.x = 2324
                        npcdata.y = 1445
                    end
                    npcdata.battleid = 0
                    npcdata.no_facetopoint = true
                    npcdata.unittype = SceneConstData.unittype_npc
                    npcdata.name = DataUnit.data_unit[QuestManager.Instance.childPlantData.unit_id].name
                    SceneManager.Instance.sceneElementsModel:CreateVirtual_Unit(uniqueid, npcdata, nil)
                end
            end
        elseif SceneManager.Instance.sceneElementsModel.VirtualUnitData_List[uniqueid] ~= nil then
            local uniqueid = BaseUtils.get_unique_npcid(76200, 0)
            SceneManager.Instance.sceneElementsModel:RemoveVirtual_Unit(uniqueid)
        end
    else

    end
end

-- 设置选中的功能单位
function HomeElementsModel:SetFunctionUnit(home_unit_view)
    if home_unit_view ~= nil then
        self.functionUnit = home_unit_view
    elseif self.functionUnit ~= nil then
        self.functionUnit = nil
        if HomeManager.Instance.homeCanvasView ~= nil then
            HomeManager.Instance.homeCanvasView.functionButton.transform.localPosition = Vector3(-2000, 0, 0)
        end
    end
end

function HomeElementsModel:functionButtonClick()
    if self.functionUnit ~= nil then
        self.functionUnit:OpenHomeInfoWindow()
    end
end

function HomeElementsModel:map_click()
    self:SetFunctionUnit(nil)
end