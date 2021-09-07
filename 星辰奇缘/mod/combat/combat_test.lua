-- 测试模块
combat_test = combat_test or BaseClass()


function combat_test:__init()
    -- 模型全局变更
    combat_test.Instance = self

    self.main_panel = nil
    self.enter_proto = nil

    self.load_listener = function(file)
        self:resources_load_completed(file)
    end
    self.load_finish = function()
        -- -- print("============================combat_test 1 load_finish ======")
    end
    self.load_finish2 = function()
        -- -- print("============================combat_test 2 load_finish ======")
    end
    self.px = 0
end

function combat_test:test_load_assets()
    local resources = {
        {file = "prefabs/ui/combat/combatfunctioniconarea.unity3d", callback = self.load_listener}
        ,{file = "prefabs/ui/combat/combatmixarea.unity3d", callback = self.load_listener}
        ,{file = "prefabs/ui/combat/combatheadinfoarea.unity3d", callback = self.load_listener}
    }
    local resources2 = {
        {file = "prefabs/ui/combat/combatfunctioniconarea.unity3d", callback = self.load_listener}
        ,{file = "prefabs/ui/combat/combatmixarea.unity3d", callback = self.load_listener}
        ,{file = "prefabs/ui/combat/combatheadinfoarea.unity3d", callback = self.load_listener}
    }
    local obj1 = batch_asset_loader.New(ctx, resources, self.load_finish)
    local obj2 = batch_asset_loader.New(ctx, resources2, self.load_finish2)
end

function combat_test:resources_load_completed(file)
    -- print("load completed file:" .. file)
end


function combat_test:test_load_model()
    local resources = {
        {file = "prefabs/roles/female/51004.unity3d", callback = nil}
        ,{file = "prefabs/roles/animation/female.unity3d", callback = nil}
    }

    local resources2 = {
        {file = "prefabs/roles/male/51003.unity3d", callback = nil}
        ,{file = "prefabs/roles/animation/male.unity3d", callback = nil}
    }

    local do_build_model = function()
        self:build_model()
    end
    local do_build_model2 = function()
        self:build_model2()
    end
    -- -- print("==========build_model load resources==============")
    batch_asset_loader.New(ctx, resources, do_build_model)
    batch_asset_loader.New(ctx, resources2, do_build_model2)
end

function combat_test:build_model()
    local role = GameObject.Instantiate(ctx.ResourcesManager:GetPrefab("prefabs/roles/female/51004.unity3d"))
    local runtimectrl = ctx.ResourcesManager:GetAnimatorController("prefabs/roles/animation/female.unity3d")
    role.transform.position = Vector3(self.px, 0, 1)
    self.px = self.px + 0.5
    role.transform:FindChild("tpose"):GetComponent(Animator).runtimeAnimatorController = runtimectrl
    local roleCtrl = role:AddComponent(OOUPointerBridge)
    roleCtrl.luaPath = "mod/combat/combat_fighter_ctrl"
    roleCtrl.className = "combat_fighter_ctrl"
    -- roleCtrl:CheckInit()

end
function combat_test:build_model2()
    local role = GameObject.Instantiate(ctx.ResourcesManager:GetPrefab("prefabs/roles/male/51003.unity3d"))
    local runtimectrl = ctx.ResourcesManager:GetAnimatorController("prefabs/roles/animation/male.unity3d")
    role.transform.position = Vector3(self.px, 0, 1)
    self.px = self.px + 0.5
    role.transform:FindChild("tpose"):GetComponent(Animator).runtimeAnimatorController = runtimectrl
    local roleCtrl = role:AddComponent(OOUPointerBridge)
    roleCtrl.luaPath = "mod/combat/combat_fighter_ctrl"
    roleCtrl.className = "combat_fighter_ctrl"
    -- roleCtrl:CheckInit()
end

function combat_test:TestLoadNpcModel()
    local skinId = 30016
    local modelId = 30016
    local animationId = 3001601
    local scale = 1
    local px = -2.3
    local py = 1.2
    local callback = function(tpose, animationData)
        local npcObj = GameObject()
        npcObj.name = "我是冰熊" .. px
        -- print("=======================npcObj.name:" .. npcObj.name)
        npcObj.transform.position = Vector3(px, py, 1)
        tpose.transform:SetParent(npcObj.transform)
        tpose.transform.localPosition = Vector3(0, 0, 0)
        tpose.transform.localScale = Vector3(1, 1, 1)
        px = px + 0.5
        if px > 2.3 then
            px = -2.3
            py = py - 0.5
        end
    end

    for i =1, 5 do
        npc_tpose_loader.New(skinId, modelId, animationId, scale, callback)
    end

    skinId = 30116
    modelId = 30016
    animationId = 3001601
    for i =1, 5 do
        npc_tpose_loader.New(skinId, modelId, animationId, scale, callback)
    end
end

function combat_test:TestModelPreview()
    local data = data_unit.data_unit[30016]
    local callback = function(texture, modelDataList)
        ModelPreview.Instance:RemoveListener(callback)
        local gameObject = GameObject.Find("Canvas/UIContainer/RawImage")
        local rawimage = gameObject:GetComponent(RawImage)
        rawimage.rectTransform.sizeDelta = Vector2 (1024, 512)
        rawimage.texture = texture
        ModelPreview.Instance:AddController(gameObject)

        for _, data in ipairs(modelDataList) do
            local pos = data.tpose.transform.position
            if data.index == 1 then
                data.tpose.transform.position = Vector3(pos.x - 2, pos.y, pos.z)
            elseif data.index == 3 then
                data.tpose.transform.position = Vector3(pos.x + 2, pos.y, pos.z)
            end
        end
    end
    ModelPreview.Instance:AddListener(callback)
    local list = {
        {basedata = data, type = ModelType.Npc}
        ,{basedata = data, type = ModelType.Npc}
        ,{basedata = data, type = ModelType.Npc}
    }
    ModelPreview.Instance:SetSize(1024, 512)
    ModelPreview.Instance:BatchRequestPreview(list)
end

