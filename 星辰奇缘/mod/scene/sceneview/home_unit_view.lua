HomeUnitView = HomeUnitView or BaseClass()

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function HomeUnitView:__init(data)
	self.gameObject = nil
	self.loadList = BaseUtils.create_queue()

    self.active = trueshadow

    self.controller = nil

    self.tpose = nil

	self.data = data

    self.isLegalPos = nil

    self.mainCamera = SceneManager.Instance.MainCamera.camera
    self.sceneModel = SceneManager.Instance.sceneModel
    self.homeElementsModel = HomeManager.Instance.homeElementsModel
    self.model = HomeManager.Instance.model
end

function HomeUnitView:__delete()
    if SceneManager.Instance.sceneElementsModel.Selected_Effect_Parent == self then
        SceneManager.Instance.sceneElementsModel:Set_Selected_Effect()
    end
    -- self:objPool_push()

    if self.Grid ~= nil then
        -- if self.grid_images ~= nil and #self.grid_images > 0 then
        --     for i = 1, #self.grid_images do
        --         self.grid_images[i].gameObject:SetActive(false)
        --     end
        -- end
        -- CombatManager.Instance.objPool:PushUnit(self.Grid, "home_grid")
        GameObject.Destroy(self.Grid)
        self.Grid = nil
    end

    if self.UnitUI ~= nil then
        -- CombatManager.Instance.objPool:PushUnit(self.UnitUI, "home_ui")
        GameObject.Destroy(self.UnitUI)
        self.UnitUI = nil
    end

	-- CombatManager.Instance.objPool:PushUnit(self.gameObject, "home_obj")
    GameObject.Destroy(self.gameObject)

    self.tposeSkinnedMeshRenderer = nil
    self.controller = nil
	self.gameObject = nil
end

function HomeUnitView:Create()
	-- self.gameObject = CombatManager.Instance.objPool:PopUnit("home_obj")
    if self.gameObject ~= nil then
        local oldTpose = self.gameObject.transform:FindChild("tpose")
        if oldTpose ~= nil then
            GameObject.Destroy(oldTpose.gameObject)
        end

        local controller = self.gameObject:GetComponent(HomeManager.Instance.LuaBehaviourName)
        if controller ~= nil then
            GameObject.Destroy(controller)
        end
    else
    	self.gameObject = GameObject.Instantiate(SceneManager.Instance.sceneElementsModel.instantiate_object_home)
    end

    self.transform = self.gameObject.transform
	local gameObject = self.gameObject
    Utils.ChangeLayersRecursively(gameObject.transform, "Model")
    gameObject.transform:SetParent(SceneManager.Instance.sceneElementsModel.scene_elements.transform)
    gameObject.name = self.data.uniqueid

    self.shadow = gameObject.transform:FindChild("Shadow").gameObject

    local ctrl = self.gameObject:AddComponent(HomeManager.Instance.LuaBehaviourName)
    self.controller = ctrl:SetClass("HomeUnitController")
    self.controller.homeUnitView = self

    table.insert(self.controller.PointerClickEvent, function(controller) self:OnPointerClick(controller) end)
    table.insert(self.controller.PointerHoldEvent, function(controller) self:OnPointerHold(controller) end)

    self.data.originDir = self.data.dir

    self:SetPosition(self.data)

    self.baseData = DataFamily.data_unit[self.data.base_id]
    self:buildTpose()

    if HomeManager.Instance.canvasInit then
        self:SetShadow()
        if HomeManager.Instance.model:CanEditHome() then
            if self.data.status == 3 then self.data.isEdit = true end
            self.controller.isEdit = self.data.isEdit
            if self.controller.isEdit then
                HomeManager.Instance.homeElementsModel:SetEditUnit(self, self.data.uniqueid)
                if self.tposeSkinnedMeshRenderer ~= nil then
                    self.tposeSkinnedMeshRenderer.material.shader = PreloadManager.Instance:GetSubAsset(AssetConfig.shader_effects, "SceneUnitAlpaha")
                end
                self:buildGrid()
                self:buildUI()
            end
        -- else
        --     print(self.data.status)
        --     print("!@#$%")print("!@#$%")print("!@#$%")print("!@#$%")print("!@#$%")print("!@#$%")print("!@#$%")print("!@#$%")print("!@#$%")print("!@#$%")print("!@#$%")print("!@#$%")print("!@#$%")print("!@#$%")
        end
    end
end

function HomeUnitView:buildTpose()
    local callback = function(tpose, animationData, poolData) self:TposeComplete(tpose, animationData, poolData) end
    HomeTposeLoader.New(self.baseData.skin, self.baseData.res, self.baseData.animation_id, 1, callback)
end

function HomeUnitView:TposeComplete(tpose, animationData, poolData)
    if self.gameObject == nil then
        if tpose ~= nil then GameObject.Destroy(tpose) end
        return
    end

    self.animationData = animationData

    if self.tpose == nil then
        self.tpose = tpose
        self:SetDir(self.data.dir)
    else
        -- self:objPool_push()

        if self.tpose ~= nil then
            self.tpose:SetActive(false)
            self.tpose.name = "Destroy_Tpose"
            GameObject.Destroy(self.tpose)
            self.tposeSkinnedMeshRenderer = nil
        end

        self.tpose = tpose
        self:SetDir(self.data.dir)
    end

    -- 存储用于对象池的使用的数据
    self.poolData = poolData

    self.tpose.name = "tpose"
    Utils.ChangeLayersRecursively(self.tpose.transform, "Model")
    self.tpose.transform:SetParent(self.gameObject.transform)
    self.tpose.transform.localPosition = Vector3.zero
    -- self.tpose.transform.localRotation = Quaternion.identity
    -- self.shadow:SetActive(true)

    self.animator = tpose:GetComponent(Animator)
    if self.animationData ~= nil then
        self.animator:Play(SceneConstData.genanimationname("Stand", self.animationData.stand_id))
    end

    local meshObject = self.tpose.transform:Find(string.format("Mesh_%s", self.poolData.modelId)).gameObject
    self.boxCollider = meshObject:AddComponent(BoxCollider)

    self.tposeSkinnedMeshRenderer = meshObject:GetComponent(SkinnedMeshRenderer)
    if HomeManager.Instance.canvasInit then
        if HomeManager.Instance.model:CanEditHome() then
            if self.controller.isEdit then
                if self.tposeSkinnedMeshRenderer ~= nil then
                    self.tposeSkinnedMeshRenderer.material.shader = PreloadManager.Instance:GetSubAsset(AssetConfig.shader_effects, "SceneUnitAlpaha")
                end
            end
        end
    end
end

function HomeUnitView:buildGrid()
    -- Mark 格子
    if HomeManager.Instance.showGrid then
        if self.Grid == nil then
            -- self.Grid = CombatManager.Instance.objPool:PopUnit("home_grid")
            if self.Grid == nil then
                self.Grid = GameObject.Instantiate(HomeManager.Instance.homeCanvasView.Grid)
            end
            self.Grid.transform:SetParent(HomeManager.Instance.homeCanvasView.GridPanel.transform)
            self.Grid.transform.localScale = Vector3(1, 1, 1)
            self.Grid.name = self.data.uniqueid

            self.grid_images = {}
            self.instantiate_grid_image = self.Grid.transform:FindChild("Image").gameObject
            self.instantiate_grid_image:SetActive(false)
        end
    end
    -- Mark 格子
    local data_unit = DataFamily.data_unit[self.data.base_id]
    if data_unit == nil then
        self.gird = nil
    else
        if self.data.dir == 1 then
            self.gird = DataFamily.data_gird[data_unit.gird_id].gird_list_1
        elseif self.data.dir == 3 then
            self.gird = DataFamily.data_gird[data_unit.gird_id].gird_list_2
        elseif self.data.dir == 5 then
            self.gird = DataFamily.data_gird[data_unit.gird_id].gird_list_3
        elseif self.data.dir == 7 then
            self.gird = DataFamily.data_gird[data_unit.gird_id].gird_list_4
        end
    end

    -- Mark 格子
    if HomeManager.Instance.showGrid then
        if self.grid_images ~= nil and #self.grid_images > 0 then
            for i = 1, #self.grid_images do
                self.grid_images[i].gameObject:SetActive(false)
            end
        end
        self.grid_images = {}

        local uiPoint = BaseUtils.ScreenToUIPoint({x = HomeManager.Instance.homeCanvasView:GetGirdSize(), y = HomeManager.Instance.homeCanvasView:GetGirdSize()})
        local girdWidth = uiPoint.x
        local girdHeight = uiPoint.y

        for i = 1, #self.gird do
            local grid_image = self.Grid.transform:FindChild(tostring(i))
            if grid_image == nil then
                grid_image = GameObject.Instantiate(self.instantiate_grid_image)
                grid_image.transform:SetParent(self.Grid.transform)
                grid_image.transform.localScale = Vector3(1, 1, 1)
            end

            grid_image:GetComponent(Image).rectTransform.sizeDelta = Vector2(girdWidth, girdHeight)
            grid_image.name = tostring(i)
            grid_image.gameObject:SetActive(true)
            self.grid_images[i] = grid_image.gameObject:GetComponent(Image)

            grid_image.transform.localPosition = Vector3(girdWidth * self.gird[i][2], girdHeight * -self.gird[i][1], 0)
        end

        self.Grid.transform.localPosition = CombatUtil.WorldToUIPoint(self.mainCamera, self.transform.position)
    end
    -- Mark 格子
end

function HomeUnitView:buildUI()
    if self.UnitUI == nil then
        -- self.UnitUI = CombatManager.Instance.objPool:PopUnit("home_ui")
        if self.UnitUI == nil then
            self.UnitUI = GameObject.Instantiate(HomeManager.Instance.homeCanvasView.UnitUI)
        end
        self.UnitUI.transform:SetParent(HomeManager.Instance.homeCanvasView.UIPanel.transform)
        self.UnitUI.transform.localScale = Vector3(1, 1, 1)
        self.UnitUI.name = self.data.uniqueid

        self.sureButton = self.UnitUI.transform:FindChild("SureButton"):GetComponent(Button)
        self.sureButton.onClick:RemoveAllListeners()
        self.sureButton.onClick:AddListener(function() self:OnSureButton() end)
        self.cancelButton = self.UnitUI.transform:FindChild("CancelButton"):GetComponent(Button)
        self.cancelButton.onClick:RemoveAllListeners()
        self.cancelButton.onClick:AddListener(function() self:OnCancelButton() end)
        self.rotateButton = self.UnitUI.transform:FindChild("RotateButton"):GetComponent(Button)
        self.rotateButton.onClick:RemoveAllListeners()
        self.rotateButton.onClick:AddListener(function() self:OnRotateButton() end)
    end
    if self.boxCollider ~= nil then
        local p = self.transform.position
        self.UnitUI.transform.localPosition = CombatUtil.WorldToUIPoint(self.mainCamera, Vector3(p.x, p.y + self.boxCollider.size.y + self.boxCollider.center.y, p.z))
    end
end

function HomeUnitView:SetShadow()
    if self.baseData.type == 9 or self.baseData.type == 13 or self.baseData.type == 15 then
        self.shadow.gameObject:SetActive(false)
    else
        self.shadow.gameObject:SetActive(true)
        if self.baseData.shadow_type ~= 0 and HomeManager.Instance.homeCanvasView ~= nil then
            self.shadow:GetComponent(MeshRenderer).material = HomeManager.Instance.homeCanvasView.home_shader_material[self.baseData.shadow_type]
        end
        self.shadow.transform.localScale = Vector3(self.baseData.shadow_x / 100, self.baseData.shadow_y / 100, 1)
        self.shadow.transform.localPosition = Vector3(0, 0, 21)
    end
end

function HomeUnitView:SetPosition(p)
    if BaseUtils.is_null(self.gameObject) then return end
    local p = self.sceneModel:transport_small_pos(p.x, p.y)
    if DataFamily.data_unit[self.data.base_id].type ~= 16 then
        self.gameObject.transform.localPosition = Vector3(p.x, p.y, p.y)
    else
        self.gameObject.transform.localPosition = Vector3(p.x, p.y, 20)
    end
end

function HomeUnitView:SetDir(dir)
    if dir > 7 then dir = dir - 8 end
    local dir = SceneConstData.UnitFaceToIndex[dir+1]
    self:FaceTo_Now(dir)

    if self.data.isEdit then self:buildGrid() end
end

function HomeUnitView:OnSureButton()
    if self.isLegalPos then
        self.UnitUI.transform.localPosition = Vector3(0, -2000, 0)
        -- Mark 格子
        if HomeManager.Instance.showGrid then
            self.Grid.transform.localPosition = Vector3(0, -2000, 0)
        end
        -- Mark 格子
        self.homeElementsModel:PutDown(self, self.data.uniqueid)

        local p = self.sceneModel:transport_big_pos(self.transform.position.x, self.transform.position.y)
        self.data.x = p.x
        self.data.y = p.y
        self.controller.originPos = self.transform.position

        self.data.originDir = self.data.dir

        self.data.status = 2

        if DataFamily.data_unit[self.data.base_id].type == 16 then
            self.transform.position = Vector3(self.transform.position.x, self.transform.position.y, 20)
        else
            self.transform.position = Vector3(self.transform.position.x, self.transform.position.y, self.transform.position.y)
        end

        local gx = self.model:GetMapGridByX(self.transform.position.x)
        local gy = self.model:GetMapGridByY(self.transform.position.y)-1

        -- print("Send11204")
        -- local str = ""
        -- local p = self.gameObject.transform.position
        -- local gx = self.model:GetMapGridByX(p.x)
        -- local gy = self.model:GetMapGridByY(p.y)-1
        -- local temp = {}
        -- for _,value in ipairs(self.gird) do
        --     str = string.format("%s, (x = %s, y = %s)", str, gx + value[2], gy - value[1])
        -- end
        -- print(str)
        -- print(self.sceneModel:transport_big_pos(self.transform.position.x, self.transform.position.y))
        -- print(self.data.x)
        -- print(self.data.y)
        -- print(gx)
        -- print(gy)

        gy = ctx.sceneManager.Map.Row - 1 - gy
        HomeManager.Instance:Send11204(self.data.id, math.floor(self.data.x+0.5), math.floor(self.data.y+0.5), gx, gy, self.data.dir)

        if self.tposeSkinnedMeshRenderer ~= nil then
            self.tposeSkinnedMeshRenderer.material.shader = PreloadManager.Instance:GetMainAsset(AssetConfig.shader_unlittexturenpc)
        end

        self:ShowEffect()


    end
end

function HomeUnitView:OnCancelButton()
    if self.edit_x ~= nil and self.edit_y ~= nil
        and (math.abs(self.edit_x - self.transform.position.x) > 0.01 or math.abs(self.edit_y - self.transform.position.y) > 0.01)
        and self.data.status == 2 then

        self.transform.position = self.controller.originPos
        local p = self.sceneModel:transport_big_pos(self.transform.position.x, self.transform.position.y)
        self.data.x = p.x
        self.data.y = p.y

        self.data.dir = self.data.originDir
        local dir = self.data.dir
        dir = SceneConstData.UnitFaceToIndex[dir+1]
        self:FaceTo_Now(dir)

        self:CheckPosition()
        if self.isLegalPos then
            self.UnitUI.transform.localPosition = Vector3(0, -2000, 0)
            -- Mark 格子
            if HomeManager.Instance.showGrid then
                self.Grid.transform.localPosition = Vector3(0, -2000, 0)
            end
            -- Mark 格子
            self.homeElementsModel:ReturnToPriginPos(self, self.data.uniqueid)
        end
        -- self:changeMap(1)
    else
        -- -- 检查繁华度是否下降
        -- if self.model:check_env_val(self.baseData) then
        --     local data = NoticeConfirmData.New()
        --     data.type = ConfirmData.Style.Normal
        --     data.content = "收回该家具<color='#ffff00'>繁华度</color>将会下降，是否确定？"
        --     data.sureLabel = "确认"
        --     data.cancelLabel = "取消"
        --     data.sureCallback = function()
        --         self.homeElementsModel:RemoveUnit(self.data.uniqueid)
        --         HomeManager.Instance:Send11207(self.data.id)
        --     end
        --     NoticeManager.Instance:ConfirmTips(data)
        -- else -- 没有下降的话就直接回收咯
            self.model:FlyIcon(self)

            self.homeElementsModel:RemoveUnit(self.data.uniqueid)
            HomeManager.Instance:Send11207(self.data.id)
        -- end
    end
    HomeManager.Instance.homeElementsModel:GetEditUnitNum()
    EventMgr.Instance:Fire(event_name.home_warehouse_update)
end

function HomeUnitView:OnRotateButton()
    self.data.dir = self.data.dir + 2
    if self.data.dir > 7 then self.data.dir = self.data.dir - 8 end
    local dir = SceneConstData.UnitFaceToIndex[self.data.dir+1]
    self:FaceTo_Now(dir)

    self:buildGrid()
end

function HomeUnitView:OnPointerClick(eventData)
    -- if not self.data.isEdit then
    --     if self.baseData.type == 5 then
    --         local npcBase = {id = self.baseData.id, name = self.baseData.name, home = true, animation_id = self.baseData.animation_id, res = self.baseData.res, skin = self.baseData.skin}
    --         npcBase.buttons = {
    --             {button_id = 0, button_args = {WindowConfig.WinID.home_window, 1, 1}, button_desc = "恢复", button_show = ""}
    --             , {button_id = 998, button_args = {}, button_desc = "返回", button_show = ""}
    --         }
    --         npcBase.plot_talk = "人是铁，饭是钢，一顿不吃饿得慌，美丽的餐桌让您吃的舒心，干净的餐桌让您吃得放心，吃饱了才有力气，而我们的餐桌，恢复饱食度绝不含糊。"
    --         MainUIManager.Instance:OpenDialog({}, {base = npcBase}, true, true)
    --         SceneManager.Instance.sceneElementsModel:Set_Selected_Effect(self.gameObject.transform, true)
    --         SceneManager.Instance.sceneElementsModel.Selected_Effect_Parent = self.gameObject.transform
    --         return
    --     elseif self.baseData.type == 10 then
    --         local npcBase = {id = self.baseData.id, name = self.baseData.name, home = true, animation_id = self.baseData.animation_id, res = self.baseData.res, skin = self.baseData.skin}
    --         npcBase.buttons = {
    --             {button_id = 0, button_args = {WindowConfig.WinID.home_window, 1, 1}, button_desc = "休息", button_show = ""}
    --             , {button_id = 998, button_args = {}, button_desc = "返回", button_show = ""}
    --         }
    --         npcBase.plot_talk = "人的一生，有三分之一的时间在床上度过，一张好的床不但能使你拥有舒适的睡眠，有益身心健康，而且还能恢复活力值哦~"
    --         MainUIManager.Instance:OpenDialog({}, {base = npcBase}, true, true)
    --         SceneManager.Instance.sceneElementsModel:Set_Selected_Effect(self.gameObject.transform, true)
    --         SceneManager.Instance.sceneElementsModel.Selected_Effect_Parent = self.gameObject.transform
    --         return
    --     elseif self.baseData.type == 11 then
    --         local npcBase = {id = self.baseData.id, name = self.baseData.name, home = true, animation_id = self.baseData.animation_id, res = self.baseData.res, skin = self.baseData.skin}
    --         npcBase.buttons = {
    --             {button_id = 0, button_args = {WindowConfig.WinID.home_window, 1, 2}, button_desc = "训练", button_show = ""}
    --             , {button_id = 998, button_args = {}, button_desc = "返回", button_show = ""}
    --         }
    --         npcBase.plot_talk = "宠物也是生命，也需要自己的家，自己的私密空间，星辰奇缘牌宠物笼，给宠物一个称心如意的家，还能训练宠物，增加宠物经验哦"
    --         MainUIManager.Instance:OpenDialog({}, {base = npcBase}, true, true)
    --         SceneManager.Instance.sceneElementsModel:Set_Selected_Effect(self.gameObject.transform, true)
    --         SceneManager.Instance.sceneElementsModel.Selected_Effect_Parent = self.gameObject.transform
    --         return
    --     elseif self.baseData.type == 8 or self.baseData.type == 7 then
    --         local npcBase = {id = self.baseData.id, name = self.baseData.name, home = true, animation_id = self.baseData.animation_id, res = self.baseData.res, skin = self.baseData.skin}
    --         npcBase.buttons = {
    --             {button_id = 0, button_args = {WindowConfig.WinID.home_window, 1, 4}, button_desc = "存储", button_show = ""}
    --             , {button_id = 998, button_args = {}, button_desc = "返回", button_show = ""}
    --         }
    --         npcBase.plot_talk = "无论是能见人的，还是见不得人的，都可以放在我这里，收纳、整理、可扩充，多功能储物柜，完美的选择"
    --         MainUIManager.Instance:OpenDialog({}, {base = npcBase}, true, true)
    --         SceneManager.Instance.sceneElementsModel:Set_Selected_Effect(self.gameObject.transform, true)
    --         SceneManager.Instance.sceneElementsModel.Selected_Effect_Parent = self.gameObject.transform
    --         return
    --     end
    -- end
    if HomeManager.Instance.model:CanEditHome() and not self.data.isEdit then
        if self.baseData.type == 10 or self.baseData.type == 11 or self.baseData.type == 8 or self.baseData.type == 7 then
            HomeManager.Instance.homeElementsModel:SetFunctionUnit(self)
            return
        end
    end
    HomeManager.Instance.homeElementsModel:SetFunctionUnit(nil)
    self.sceneModel.mapclicker:Click(Input.mousePosition)
end

function HomeUnitView:OnPointerHold()
    if not self.data.isEdit and HomeManager.Instance.model:CanEditHome() then
        HomeManager.Instance:Send11219(self.data.id)
        local p = self.sceneModel:transport_big_pos(self.transform.position.x, self.transform.position.y)
        -- print(p.x)
        -- print(p.y)
        HomeManager.Instance.homeElementsModel:SetEditUnit(self, self.data.uniqueid)
        if self.tposeSkinnedMeshRenderer ~= nil then
            self.tposeSkinnedMeshRenderer.material.shader = PreloadManager.Instance:GetSubAsset(AssetConfig.shader_effects, "SceneUnitAlpaha")
        end
        self.controller.isEdit = true
        self.data.isEdit = true
        self:buildGrid()
        self:buildUI()
        -- self:changeMap(0)

        self.isLegalPos = nil
        self.edit_x = self.transform.position.x
        self.edit_y = self.transform.position.y
    end
    HomeManager.Instance.homeElementsModel:SetFunctionUnit(nil)
end

function HomeUnitView:UpdateMove()
    if self.data.isEdit then
        self.controller:UpdateMove()
        local p = self.sceneModel:transport_big_pos(self.transform.position.x, self.transform.position.y)
        self.data.x = p.x
        self.data.y = p.y

        -- Mark 格子
        if HomeManager.Instance.showGrid then
            if self.Grid ~= nil then
                -- self.Grid.transform.localPosition = CombatUtil.WorldToUIPoint(self.mainCamera, self.transform.position)
                local p = self.mainCamera:WorldToScreenPoint(self.transform.position)
                self.Grid.transform.localPosition = BaseUtils.ScreenToUIPoint(Vector2(p.x - ctx.ScreenWidth / 2, p.y - ctx.ScreenHeight / 2))
            end
        end
        -- Mark 格子
        if self.UnitUI ~= nil and self.boxCollider ~= nil and BaseUtils.isnull(self.UnitUI) ~= true then
            local p = self.transform.position
            p = self.mainCamera:WorldToScreenPoint(Vector2(p.x, p.y + self.boxCollider.size.y + self.boxCollider.center.y))
            self.UnitUI.transform.localPosition = BaseUtils.ScreenToUIPoint(Vector2(p.x - ctx.ScreenWidth / 2, p.y - ctx.ScreenHeight / 2))
        end
    end
end

function HomeUnitView:CheckPosition()
    if self.gird == nil then return end

    local isLegalPos = true

    if self.baseData.type == 9 or self.baseData.type == 13 then
        local pos_list = {}
        local p = self.sceneModel:transport_big_pos(self.gameObject.transform.position.x, self.gameObject.transform.position.y)
        -- local girdWidth = HomeManager.Instance.homeCanvasView:GetGirdSize()
        -- local girdHeight = HomeManager.Instance.homeCanvasView:GetGirdSize()
        local girdWidth = 20
        local girdHeight = 20
        local str = ""
        for _,value in ipairs(self.gird) do
            table.insert(pos_list, { x = p.x + value[2] * girdWidth, y = p.y + value[1] * girdHeight} )
        end

        if not self.model:IsInRect(pos_list, self.data.dir) then
            isLegalPos = false
        end

        if not self.model:IsNoOtherFurniture(self.data.id, pos_list, {9, 13}) then
            isLegalPos = false
        end
    elseif self.baseData.type == 16 then
        local p = self.gameObject.transform.position
        local gx = self.model:GetMapGridByX(p.x)
        local gy = self.model:GetMapGridByY(p.y)
        local temp = {}
        for _,value in ipairs(self.gird) do
            if not self.model:Walkable(gx + value[2], gy - value[1]) then
                if self.sceneModel:GetChangeMapPos(gx + value[2] - 1, gy - value[1]) ~= 1 then
                    -- print(string.format("%s %s", gx + value[2] - 1, gy - value[1]))
                    isLegalPos = false
                    break
                end
            end
        end

        local girdWidth = 20
        local girdHeight = 20
        local pos_list = {}
        local p = self.sceneModel:transport_big_pos(self.gameObject.transform.position.x, self.gameObject.transform.position.y)
        for _,value in ipairs(self.gird) do
            table.insert(pos_list, { x = p.x + value[2] * girdWidth, y = p.y + value[1] * girdHeight} )
        end
        if not self.model:IsNoOtherFurniture(self.data.id, pos_list, {16}) then
            isLegalPos = false
        end
    else
        local p = self.gameObject.transform.position
        local gx = self.model:GetMapGridByX(p.x)+1
        local gy = self.model:GetMapGridByY(p.y)-1
        local temp = {}
        for _,value in ipairs(self.gird) do
            if not self.model:Walkable(gx + value[2], gy - value[1]) then
                -- print(string.format("%s, %s", gx + value[2], gy - value[1]))
                isLegalPos = false
                break
            end
        end
    end

    if self.isLegalPos == true and isLegalPos == false then
        self.isLegalPos = false
        -- Mark 格子
        if HomeManager.Instance.showGrid then
            for _, image in ipairs(self.grid_images) do
                image.color = Color(1, 0, 0, 0.39)
                -- image.color = Color(1, 0, 0, 1)
            end
        end
        -- Mark 格子
        if self.tposeSkinnedMeshRenderer ~= nil then
            self.tposeSkinnedMeshRenderer.material.color = Color(1, 0.192, 0.192, 1)
        end
    elseif self.isLegalPos == false and isLegalPos == true then
        self.isLegalPos = true
        -- Mark 格子
        if HomeManager.Instance.showGrid then
            for _, image in ipairs(self.grid_images) do
                image.color = Color(0, 1, 0, 0.31)
                -- image.color = Color(0, 1, 0, 1)
            end
        end
        -- Mark 格子
        if self.tposeSkinnedMeshRenderer ~= nil then
            self.tposeSkinnedMeshRenderer.material.color = Color(1, 0.965, 0.698, 1)
        end
    elseif self.isLegalPos == nil then
        if isLegalPos then
            self.isLegalPos = true
            -- Mark 格子
            if HomeManager.Instance.showGrid then
                for _, image in ipairs(self.grid_images) do
                    image.color = Color(0, 1, 0, 0.31)
                    -- image.color = Color(0, 1, 0, 1)
                end
            end
            -- Mark 格子
            if self.tposeSkinnedMeshRenderer ~= nil then
                self.tposeSkinnedMeshRenderer.material.color = Color(1, 0.965, 0.698, 1)
            end
        else
            self.isLegalPos = false
            -- Mark 格子
            if HomeManager.Instance.showGrid then
                for _, image in ipairs(self.grid_images) do
                    image.color = Color(1, 0, 0, 0.39)
                    -- image.color = Color(1, 0, 0, 1)
                end
            end
            -- Mark 格子
            if self.tposeSkinnedMeshRenderer ~= nil then
                self.tposeSkinnedMeshRenderer.material.color = Color(1, 0.192, 0.192, 1)
            end
        end
    end
end

function HomeUnitView:changeMap(flag)
    if self.gird == nil then return end
    if self.baseData.type == 9 or self.baseData.type == 13 or self.baseData.type == 15 then

    else
        local p = self.gameObject.transform.position
        local gx = self.model:GetMapGridByX(p.x)
        local gy = self.model:GetMapGridByY(p.y)
        local pos_list = {}
        for _,value in ipairs(self.gird) do
            table.insert(pos_list, { x = gx + value[2], y = gy - value[1] } )
        end
        local map_data = {}
        map_data.base_id = SceneManager.Instance:CurrentMapId()
        map_data.flag = flag
        map_data.pos = pos_list
        self.sceneModel:ChangeMap(map_data)
-- BaseUtils.dump(map_data)
-- print(self.model:Walkable(87, 37))
    end
end

function HomeUnitView:FaceTo_Now(angle)
    self:SetOrientation(angle, true)
    self.TargetOrienation = nil
end

function HomeUnitView:SetOrientation(angle, rotationFromZore)
    angle = (angle + 720) % 360
    if self.tpose ~= nil then
        if rotationFromZore then
            self.tpose.transform.rotation = Quaternion.identity
            self.tpose.transform:Rotate(Vector3(-30, 0, 0))
        end
        self.tpose.transform:Rotate(Vector3(0, angle, 0))
    end
    if self.shadow ~= nil then
        if rotationFromZore then
            self.shadow.transform.rotation = Quaternion.identity
            self.shadow.transform:Rotate(Vector3(60, 0, 0))
        end
        if angle == 45 then
            angle = 225
        elseif angle == 225 then
            angle = 45
        end
        self.shadow.transform:Rotate(Vector3(0, 0, angle))
    end
    self.orienation = angle
end

function HomeUnitView:ShowEffect()
    local fun = function(effectView)
        local effectObject = effectView.gameObject

        effectObject.transform:SetParent(self.transform)
        effectObject.transform.localScale = Vector3.one
        effectObject.transform.localPosition = Vector3(0, 0, 0)
        effectObject.transform.localRotation = Quaternion.identity

        -- Utils.ChangeLayersRecursively(effectObject.transform, "UI")
    end

    BaseEffectView.New({effectId = 10045, time = 1500, callback = fun})
end

function HomeUnitView:OpenHomeInfoWindow()
    if not self.data.isEdit then
        if self.baseData.type == 10 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.home_window, {1, 1})
            return
        elseif self.baseData.type == 11 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.home_window, {1, 2})
            return
        elseif self.baseData.type == 8 or self.baseData.type == 7 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.home_window, {1, 4})
            return
        end
    end
end

function HomeUnitView:objPool_push()
    if self.controller ~= nil then
        GameObject.Destroy(self.gameObject:GetComponent(HomeManager.Instance.LuaBehaviourName))
        self.controller = nil
    end

    if self.poolData ~= nil then
        if self.poolData.modelPath ~= nil then
            if self.boxCollider ~= nil then
                GameObject.Destroy(self.boxCollider)
                self.boxCollider = nil
            end

            CombatManager.Instance.objPool:PushUnit(self.tpose, self.poolData.modelPath)
        end
    else
        if self.tpose ~= nil then
            GameObject.Destroy(self.tpose)
            self.tpose = nil
        end
    end

    self.poolData = nil
end