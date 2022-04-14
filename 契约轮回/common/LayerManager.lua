-- 
-- @Author: LaoY
-- @Date:   2018-07-20 20:00:41
-- 

LayerManager = LayerManager or class("LayerManager", BaseManager)
local this = LayerManager

-- 项目规划分层
LayerManager.LayerNameList = {
    CacheLayer = "CacheLayer", --缓存层

    SceneObj = "SceneObj", --场景对象 角色、怪物、NPC
    SceneObjCache = "SceneObjCache", --场景对象 角色、怪物、NPC
    SceneOtherObj = "SceneOtherObj", --细分层级 和主角区分开来 场景对象 角色、怪物、NPC
    SceneEffect = "SceneEffect", --场景特效
    SceneText       = "SceneText", --角色名字
    SceneDamageText = "SceneDamageText", --伤害飘字等 由于场景对象是3D，可以旋转等。名字放到另外一个层
    SceneImage = "SceneImage", --脚底阴影等
    Map = "SceneContainer",
    MapSkyBox = "MapSkyBox",
    MapLayer = "MapLayer",
    GameManager = "GameManager", --

    -- UI
    Layer = "layer", --UI层根节点
    Scene = "Scene", --场景事件 	需要在 InitLayer 特殊处理
    Bottom = "Bottom", --UI底层  	需要在 InitLayer 特殊处理
    UI = "UI", --UI层 		需要在 InitLayer 特殊处理
    Top = "Top", --UI上层 	需要在 InitLayer 特殊处理
    Max = "Max", --UI上层     需要在 InitLayer 特殊处理
}

LayerManager.LayerOrderInLayer = {
    Scene = 0,
    Bottom = 100,
    UI = 400,
    Top = 1000,
}

LayerManager.LayerOrderIndex = {

}

LayerManager.UsedUILayer = {};

function LayerManager.GetUnUseUIModelLayer()
    for i = 4, 15, 1 do
        if not LayerManager.UsedUILayer[i] then
            LayerManager.UsedUILayer[i] = true;
            return i;
        end
    end
    LayerManager.UsedUILayer = {};
    return 4;
end

function LayerManager.RecycleUnUseUIModelLayer(layer)
    LayerManager.UsedUILayer[tonumber(layer)] = nil;
end

-- unity layer
LayerManager.BuiltinLayer = {
    Default = 0,
    TransparentFX = 1,
    IgnoreRaycast = 2,
    Water = 4,
    UI = 5,
    Terria = 8,
    Model = 10,
}

--[[
	@author LaoY
	@des	越大越靠近摄像机
--]]
LayerManager.SceneObjectDepth = {
    Object = 5000,
    Text = 8000,
}

function LayerManager:ctor()
    LayerManager.Instance = self
    self.layer_list = {}

    self.touch_begin_pos = { x = 0, y = 0 }
    self.touch_end_pos = { x = 0, y = 0 }

    self.layer_tree = Tree(nil,"tree_top_node")

	
    self:InitLayer()
    self:AddEvent()

	self:Reset()
    if AppConfig.Debug then
        UpdateBeat:Add(self.Update,self,4,50)
    end
end

function LayerManager:Reset()
    self.last_touch_time = Time.time
    self:InitLayerTreeNode()
end

function LayerManager.GetInstance()
    if LayerManager.Instance == nil then
        LayerManager()
    end
    return LayerManager.Instance
end

function LayerManager:AddEvent()
    local scene = self:GetLayerByName(LayerManager.LayerNameList.Scene)
    local function call_back(target, x, y)
        self:OnTouchenBengin(x, y)
    end
    AddDownEvent(scene.gameObject, call_back)

    local function call_back(target, x, y)
        self:OnTouchenEnd(x, y)
    end
    AddUpEvent(scene.gameObject, call_back)

    
end

function LayerManager:OnTouchenBengin(x, y)
    self.touch_begin_pos.x = x
    self.touch_begin_pos.y = y
    -- GlobalEvent:Brocast(SceneEvent.TouchBegin,x,y)
end

--[[
	@author LaoY
	@des	触摸场景事件
	优先级判断排序：
			特殊场景
			寻路
			上下坐骑
			点击选中怪物/npc或者其他场景对象
			主角点击走路/战斗滑步等
--]]
function LayerManager:OnTouchenEnd(x, y)
    local  scene_data = SceneManager:GetInstance():GetSceneInfo()
    if ArenaModel:GetInstance():IsArenaFight(scene_data.scene) then
        return
    end
    self.touch_end_pos.x = x
    self.touch_end_pos.y = y
    -- Notify.ShowText("111")

    -- GlobalEvent:Brocast(SceneEvent.TouchEnd,x,y)
    local main_role = SceneManager:GetInstance():GetMainRole()
    if main_role and main_role:IsJumping() then
        return
    end
    local scene_pos = self:ScreenToSceneWorldPos(self.touch_end_pos.x, self.touch_end_pos.y)
    local list = SceneManager:GetInstance():GetTouchTargetList(scene_pos.x, scene_pos.y)
    local touch_target = list and list[1]
    if touch_target and  touch_target:OnClick() then
        return
    end

    local abs_x = math.abs(self.touch_end_pos.x - self.touch_begin_pos.x)
    local abs_y = math.abs(self.touch_end_pos.y - self.touch_begin_pos.y)
    if abs_y > abs_x and abs_y > 100 then
        if self.touch_end_pos.y > self.touch_begin_pos.y then
            if main_role and not main_role:IsRiding() then
                main_role:OnClickPlayMount()
            end
        else
            if main_role and main_role:IsRiding() then
                main_role:PlayDismount()
            end
        end
        return
    end
    local mask = OperationManager:GetInstance():GetMask(scene_pos.x, scene_pos.y)
    if BitState.StaticContain(mask, SceneConstant.MaskBitList.Block) or BitState.StaticContain(mask, SceneConstant.MaskBitList.JumpPath) then
        if self.is_hide_ui then
            self:HideUI(false)
        end
        return
    end

    if not RoleInfoModel:GetInstance():CanUseRocker() then
        return
    end

    if AutoFightManager:GetInstance().auto_state == AutoFightManager.AutoState.Auto then
        if Time.time - self.last_touch_time <= 1 then
            AutoFightManager:GetInstance():TemAutoFight()
            
        else
            self.last_touch_time = Time.time
            return
        end
        self.last_touch_time = Time.time
    -- 临时状态点击 重新计算时间
    elseif AutoFightManager:GetInstance().auto_state == AutoFightManager.AutoState.Tem then
        AutoFightManager:GetInstance():TemAutoFight()
    end

    EffectManager:GetInstance():PlayPositionEffect("effect_dimiandianji", scene_pos)
    if main_role then
        
        local bo = OperationManager:GetInstance():TryMoveToPosition(nil, main_role:GetPosition(), scene_pos)
        if bo then
        	TaskModel:GetInstance():PauseTask(false)
        end
        --[[
        -- main_role:SetMovePosition(scene_pos)
        if main_role:IsAttacking() then
            -- main_role:SetMovePosition(scene_pos)

            -- 先屏蔽
            -- main_role:PlaySlip(scene_pos,main_role.move_speed)
            OperationManager:GetInstance():TryMoveToPosition(nil, main_role:GetPosition(), scene_pos)
        else
            OperationManager:GetInstance():TryMoveToPosition(nil, main_role:GetPosition(), scene_pos)
        end
        ]]
    end
end

--[[
	@author LaoY
	@des	特殊的层级要特殊处理，UI层级
--]]
function LayerManager:InitLayer()
    local layer = self:GetLayerByName(LayerManager.LayerNameList.Layer)
    if layer then
        local ui_layer_list = { LayerManager.LayerNameList.Scene, LayerManager.LayerNameList.Bottom, LayerManager.LayerNameList.UI, LayerManager.LayerNameList.Top }
        for i, name in pairs(ui_layer_list) do
            local go = layer:Find(name)
            if go then
                self.layer_list[name] = go.transform
            end
        end
    end

    local map = self:GetLayerByName(LayerManager.LayerNameList.Map)
    if map then
        local map_layer_list = { LayerManager.LayerNameList.MapSkyBox, LayerManager.LayerNameList.MapLayer }
        for i = 1, #map_layer_list do
            local layer_name = map_layer_list[i]
            local go = GameObject(layer_name)
            self.layer_list[layer_name] = go.transform
            self.layer_list[layer_name]:SetParent(map)
        end
    end

    local cacheLayer = self:GetLayerByName(LayerManager.LayerNameList.CacheLayer)
    SetLocalPosition(cacheLayer,-30000,-30000)
    SetVisible(cacheLayer,true)

    local layer_name = LayerManager.LayerNameList.SceneObjCache
    local go = GameObject(layer_name)
    self.layer_list[layer_name] = go.transform
    -- SetGlobalPosition(self.layer_list[layer_name], -1000, -1000, 1000)
    self.layer_list[layer_name]:SetParent(self:GetLayerByName(LayerManager.LayerNameList.SceneObj))
    SetLocalPosition(self.layer_list[layer_name],-20000,-20000)
    go:SetActive(true)

    local layer_name = LayerManager.LayerNameList.SceneOtherObj
    local go = GameObject(layer_name)
    self.layer_list[layer_name] = go.transform
    -- SetGlobalPosition(self.layer_list[layer_name], -1000, -1000, 1000)
    self.layer_list[layer_name]:SetParent(self:GetLayerByName(LayerManager.LayerNameList.SceneObj))


    -- 复制一个文本层，和名字层分开。
    local go = newObject(self:GetLayerByName(LayerManager.LayerNameList.SceneText))
    local transform = go.transform
    transform.name = LayerManager.LayerNameList.SceneDamageText
    self.layer_list[LayerManager.LayerNameList.SceneDamageText] = transform

    local ui_transform = self:GetLayerByName(LayerManager.LayerNameList.UI)
    local go = newObject(ui_transform)
    local transform = go.transform
    transform.name = LayerManager.LayerNameList.Max
    self.layer_list[LayerManager.LayerNameList.Max] = transform
    transform:SetParent(ui_transform.parent)
    SetOrderIndex(go,true,1500)
end

function LayerManager:InitLayerTreeNode()
    self.layer_tree.top_node:clear()
    
    for key,order_index in pairs(LayerManager.LayerOrderInLayer) do
        local layer = self.layer_list[key]
        if layer then
            self:AddLayerNode(nil,layer,order_index)
            SetOrderIndex(layer,true,order_index)
        end
    end
end

--[[
	@author LaoY
	@des	获取layer，lua获取后保存一份。不用频繁调用C#方法
	@param1 name string
--]]
function LayerManager:GetLayerByName(name)
    if not self.layer_list[name] then
        -- local go =  GameObject.FindWithTag(name)
        local go = GameObject.Find(name)
        if go then
            self.layer_list[name] = go.transform
        end
    end
    return self.layer_list[name]
end

function LayerManager:GetLayerOrderByName(name)
    return self.LayerOrderInLayer[name] or nil
end

function LayerManager:SetLayerVisible(name, bo)
    self.layer_visible_list = self.layer_visible_list or {}
    if self.layer_visible_list[name] == bo then
        return
    end
    self.layer_visible_list[name] = bo
    local layer = self:GetLayerByName(name)
    SetVisible(layer, bo)

    if bo then
        self:ResetLayerOrderIndex(name)
    end
end

function LayerManager:ScreenToSceneWorldPos(x, y)
    if not MapManager:GetInstance().sceneCamera then
        return Vector3(x, y, 0)
    end
    local vec3 = MapManager:GetInstance().sceneCamera:ScreenToWorldPoint(Vector3(x, y, 0))
    return vec3 * SceneConstant.PixelsPerUnit
end

function LayerManager:SceneWorldToScreenPoint(x, y)
    if not MapManager:GetInstance().sceneCamera then
        return Vector3(x, y, 0)
    end
    local vec3 = MapManager:GetInstance().sceneCamera:WorldToScreenPoint(Vector3(x, y, 0))
    return vec3
end

function LayerManager:ScreenToUIPos(x, y)
    if not MapManager:GetInstance().uiCamera then
        return Vector3(x, y, 0)
    end
    local vec3 = MapManager:GetInstance().uiCamera:ScreenToWorldPoint(Vector3(x, y, 0))
    return vec3
end

function LayerManager:UIWorldToScreenPoint(x, y)
    if not MapManager:GetInstance().uiCamera then
        return Vector3(x, y, 0)
    end
    local vec3 = MapManager:GetInstance().uiCamera:WorldToScreenPoint(Vector3(x, y, 0))
    return vec3
end

function LayerManager:UIWorldToViewportPoint(x, y, z)
    if not MapManager:GetInstance().uiCamera then
        return Vector3(x, y, 0)
    end
    local vec3 = MapManager:GetInstance().uiCamera:WorldToViewportPoint(Vector3(x, y, z))
    return vec3
end

function LayerManager:UIScreenToViewportPoint(x, y, z)
    if not MapManager:GetInstance().uiCamera then
        return Vector3(x, y, 0)
    end
    local vec3 = MapManager:GetInstance().uiCamera:ScreenToViewportPoint(Vector3(x, y, z))
    return vec3
end

function LayerManager:UIViewportToWorldPoint(x, y)
    if not MapManager:GetInstance().uiCamera then
        return Vector3(x, y, 0)
    end
    local vec3 = MapManager:GetInstance().uiCamera:ViewportToWorldPoint(Vector3(x, y, 0))
    return vec3
end

function LayerManager:UIRectangleContainsScreenPoint(rect, x, y)
    if not MapManager:GetInstance().uiCamera then
        return false
    end

    local r = RectTransformUtility.RectangleContainsScreenPoint(rect, Vector2(x, y), MapManager:GetInstance().uiCamera)
    return r
end

function LayerManager:GetUiCameraSize()
    local h = MapManager:GetInstance().uiCamera.orthographicSize
    local resRatio = Screen.height / Screen.width
    local height = h * 2 * 100
    local width = height / resRatio
    return { width = width, height = height }
end

--[[
	@author LaoY
	@des	根据Y轴坐标值 计算深度
	@param1 y number unity世界坐标
	@return number
--]]
function LayerManager:GetSceneObjectDepth(y)
    y = y or 0
    local depth = (LayerManager.SceneObjectDepth.Object - y * 0.2)
    return -depth
end

--[[
	@author LaoY
	@des	据Y轴坐标值 计算深度
	@return number 返回的是local坐标
--]]
function LayerManager:GetSceneDamageTextDepth(y)
    y = y or 0
    local depth = (LayerManager.SceneObjectDepth.Text - y * 0.01)
    return -depth * 100
end

-- 添加到层级管理 管理 order_index
function LayerManager:AddLayerNode(parent_transform,transform,order_index,is_ui)
    local node = self.layer_tree:findnode(nil,transform)
    if is_ui == nil then
        is_ui = true
    end
    if not node then
        local parent_node
        if parent_transform then
            parent_node = self.layer_tree:findnode(nil,parent_transform)
        end
        local data = {order_index = order_index , is_ui = is_ui}
        -- 如果 parent_node 不存在，直接挂在 top_node 下面
        return self.layer_tree:addnode(parent_node,transform,data)
    else
        node.data.order_index = order_index
        node.data.is_ui = is_ui
        return node
    end
end

function LayerManager:RemoveLayerByTransform(transform)
    local node = self.layer_tree:findnode(nil,transform)
    if node then
        self:RemoveLayerNode(node)
    end
end

function LayerManager:RemoveLayerNode(node)
    if not node then
        return
    end
    if isClass(node) then
        self.layer_tree:removenode(node)
    else
        self.layer_tree:remove(nil,node)
    end
end

function LayerManager:ResetPanelOrderIndex(transform,new_order_index)
    local cur_index,panel_node = LayerManager:GetInstance():GetTransformOrderIndex(transform)    
    -- 不存在 或者 前后两次相等不处理
    if not panel_node or new_order_index == cur_index then
        return
    end
    local offset = new_order_index - cur_index
    local function call_back(node)
        node.data.order_index = node.data.order_index + offset
        SetOrderIndex(node.pos,node.data.is_ui,node.data.order_index)
    end
    call_back(panel_node)
    panel_node:walk(call_back,true)
end

function LayerManager:ResetLayerOrderIndex(layer_name)
    local layer = self.layer_list[layer_name]
    if not layer  then
        return
    end
    local cur_index,layer_node = LayerManager:GetInstance():GetTransformOrderIndex(layer)
    local function call_back(node)
        if tostring(node.pos) == "null" then
            local cname = node.data and node.data.cls and node.data.cls.__cname
            Yzprint('--LaoY LayerManager.lua,line 453--',cname)
        end
        SetOrderIndex(node.pos,node.data.is_ui,node.data.order_index)
    end
    call_back(layer_node)
    layer_node:walk(call_back,true)
end

function LayerManager:GetTransformOrderIndex(transform)
    local node = self.layer_tree:findnode(nil,transform)
    if node then
        return node.data.order_index,node
    end
    return nil
end

function LayerManager:GetMaxOrderIndex(transform)
    local order_index,parent_node = self:GetTransformOrderIndex(transform)
    if not parent_node then
        return nil
    end
    local max_order_index = parent_node.data.order_index
    local function call_back(node)
        if node.data.order_index > max_order_index then
            max_order_index = node.data.order_index
        end
    end
    parent_node:walk(call_back,false)
    return max_order_index
end


--[[
    @author LaoY
    @des    所有设置OrderIndex 必须通过这里设置
            ps：必须注意设置OrderIndex的时候，父节点不能为隐藏状态，否则设置层级会失败。（根节点UI、Bottom、Top的隐藏已经额外处理）
            cls如果是继承Node及派生类，可以用 
                SetOrderByParentAuto()
                SetOrderByParentMax()
            外部统一用该接口
    @param1 cls
    @param2 transform
    @param3 parent_transform    带canvas父节点。可不填，会自动去查找
    @param4 is_ui               是否为UI，不填默认是
    @param5 order_index         order_index。可不填，不填改值与 is_max,offset有关。见下面说明
    @param6 is_max              是否读取父节点中所有子节点最高的order_index值，不填默认读取父节点的order_index值
    @param7 offset              偏移值，不填默认是 1
    @return number
--]]
function LayerManager:AddOrderIndexByCls(cls,transform,parent_transform,is_ui,order_index,is_max,offset)
    if is_ui == nil then
        is_ui = true
    end
    self.cls_order_index_list = self.cls_order_index_list or {}
    self.cls_order_index_list[cls] = self.cls_order_index_list[cls] or {}
    if self.cls_order_index_list[cls][transform] then
        local node = self.layer_tree:findnode(nil,transform)
        if node and order_index and node.data.order_index ~= order_index then
            node.data.order_index = order_index
            node.data.is_ui = is_ui
            SetOrderIndex(transform,is_ui,order_index)
            return node
        end
    end
    local _parent_transform,_parent_order_index
    if not parent_transform then
        _parent_transform,_parent_order_index = GetParentOrderIndex(transform)
        parent_transform = _parent_transform
    end
    if not order_index then
        if not _parent_order_index then
            _parent_transform,_parent_order_index = GetParentOrderIndex(transform)
        end
        if is_max then
            _parent_order_index = LayerManager:GetInstance():GetMaxOrderIndex(parent_transform)
        end
        if _parent_order_index then
            offset = offset or 1
            order_index = _parent_order_index + offset
        end
    end

    if not parent_transform or not order_index then
        logError("设置层级参数错误",tostring(parent_transform),tostring(order_index))
        return
    end

    local node = self:AddLayerNode(parent_transform,transform,order_index,is_ui)
    SetOrderIndex(transform,is_ui,order_index)
    self.cls_order_index_list[cls][transform] = node
    if node then
        node.data.cls = cls
    end
    return node
end

function LayerManager:RemoveOrderIndexByCls(cls)
    self.cls_order_index_list = self.cls_order_index_list or {}
    if not self.cls_order_index_list[cls] then
        return
    end
    if cls.__cname == "FactionBattleDungeonPanel" then
        Yzprint('--LaoY LayerManager.lua,line 550--',data)
        Yzprint('--LaoY LayerManager.lua,line 551--',data)
    end
    for transform,node in pairs(self.cls_order_index_list[cls]) do
        -- self:RemoveLayerByTransform(transform)
        self:RemoveLayerNode(node)
    end
    self.cls_order_index_list[cls] = nil
end

local last_print_time = 0
-- AppConfig.Debug 状态才会执行这个
function LayerManager:Update(deltaTime)
    if Time.time - last_print_time >= 5 then
        last_print_time = Time.time
        logWarn('当前lua内存===>',GetLuaMemory(),"，时间：",Time.time)
    end
    if self.cls_order_index_list then
        local del_tab
        for cls,v in pairs(self.cls_order_index_list) do
            if cls.is_dctored then
                del_tab = del_tab or {}
                del_tab[#del_tab+1] = cls
            end
        end
        if del_tab then
            for k,cls in pairs(del_tab) do
                self:RemoveOrderIndexByCls(cls)
            end
        end
    end
end

function LayerManager:HideUI(flag)
    local tab = {
        LayerManager.LayerNameList.Bottom,
        LayerManager.LayerNameList.UI,
        LayerManager.LayerNameList.Top,
        LayerManager.LayerNameList.Max,
    }
    self.is_hide_ui = flag
    if flag then
        local panel_list = lua_panelMgr:GetPanelListByLayer(LayerManager.LayerNameList.UI)
        for panel,v in pairs(panel_list) do
            panel:Close()
        end
    end
    for k,layerName in pairs(tab) do
        local tr = self:GetLayerByName(layerName)
        SetVisible(tr,not flag)
    end
end

function LayerManager:GetDamageLayerByFont(font_name)
    if not self.layer_list[font_name] then
        local go = newObject(self:GetLayerByName(LayerManager.LayerNameList.SceneText))
        local damage_text_transform = self:GetLayerByName(LayerManager.LayerNameList.SceneDamageText)
        local transform = go.transform
        transform.name = font_name
        transform:SetParent(damage_text_transform)
        self.layer_list[font_name] = transform
    end
    
    return self.layer_list[font_name]
end