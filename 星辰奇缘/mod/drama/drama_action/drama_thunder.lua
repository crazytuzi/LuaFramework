-------------------------------------
--进场雷电
-- 1.隐藏UI，隐藏自己并黑掉地图
-- 2.播雷电特效
-- 3.一段时间后显示自己，并开始逐渐变亮地图
-- 4.显示UI，结束
-------------------------------------
DramaThunder = DramaThunder or BaseClass()

function DramaThunder:__init(callback)
    self.callback = callback
    self.path = "prefabs/effect/30025.unity3d"
    self.c1 = 10/255
    self.c2 = 1
    self.effect = nil
    self.step = 0
    self.timeId = 0
    self.tweenDesc = nil

    self:Ready()
    --创建加载wrapper
    self.resList = {{file = self.path, type = AssetType.Main}}
    self.assetWrapper = AssetBatchWrapper.New()

    local func = function()
        if self.assetWrapper == nil then
            return
        end
        self.effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.path))
        self.effect:SetActive(false)
        self.effect.transform.localScale = Vector3.one
        self.effect.transform.localRotation = Quaternion.identity
        local p = SceneManager.Instance.sceneModel:transport_small_pos(1900, 390)
        self.effect.transform.localPosition = Vector3(p.x, p.y, p.y)
        self.effect.transform:Rotate(Vector3.zero)

        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil

        self:Show()
    end
    self.assetWrapper:LoadAssetBundle(self.resList, func)
end

function DramaThunder:__delete()
    self:Over()
    GameObject.DestroyImmediate(self.effect)
end

function DramaThunder:Show()
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    self.step = self.step + 1
    if self.step == 1 then
        --播放闪电
        DramaManager.Instance.model.dramaMask:BlackPanel(false)
        self:Playeffect()
    elseif self.step == 2 then
        --人物出现,点亮地图
        SceneManager.Instance.MainCamera.lock = true
        self:Lightup()
    else
        self:Over()
        if self.callback ~= nil then
            self.callback()
        end
    end
end

function DramaThunder:Over()
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end
    if self.tweenDesc ~= nil then
        Tween.Instance:Cancel(self.tweenDesc)
    end
    self.step = 0
    self:Updatecolor(self.c2)
    SceneManager.Instance.MainCamera.lock = false
    SceneManager.Instance.sceneElementsModel.self_view.animator.cullingMode = AnimatorCullingMode.BasedOnRenderers
end

function DramaThunder:Ready()
    for i,a in ipairs(SceneManager.Instance:GetMapCell()) do
        a.sharedMaterial.color = Color(self.c1, self.c1, self.c1)
    end
    SceneManager.Instance.sceneElementsModel:Show_Self(false)
    SceneManager.Instance.sceneElementsModel:Show_OtherRole(false)
    SceneManager.Instance.sceneElementsModel:Show_Self_Weapon(false)
end

function DramaThunder:Playeffect()
    self.effect:SetActive(true)
    self.timeId = LuaTimer.Add(1200, function() self:Show() end)
end

function DramaThunder:Lightup()
    SceneManager.Instance.sceneElementsModel:Show_Self(true)
    SceneManager.Instance.sceneElementsModel:Show_Self_Weapon(true)
    SceneManager.Instance.sceneElementsModel.self_view.animator.cullingMode = AnimatorCullingMode.AlwaysAnimate
    SceneManager.Instance.sceneElementsModel.self_view.action_callback = function() self:ActionTimeout() end
    SceneManager.Instance.sceneElementsModel.self_view:play_action_name("Begin1", false)
    self.tweenDesc = Tween.Instance:ValueChange(self.c1, self.c2, 1.5, function() self:Colorover() end, nil, function(val) self:Updatecolor(val) end).id
end

function DramaThunder:Updatecolor(val)
    for i,map in ipairs(SceneManager.Instance:GetMapCell()) do
        map.sharedMaterial.color = Color(val, val, val)
    end
end

function DramaThunder:Colorover()
    for i,map in ipairs(SceneManager.Instance:GetMapCell()) do
        map.sharedMaterial.color = Color(self.c2, self.c2, self.c2)
    end
    self.timeId = LuaTimer.Add(1000, function() self:Show() end)
end

function DramaThunder:ActionTimeout()
    SceneManager.Instance.sceneElementsModel.self_view:PlayAction(SceneConstData.UnitAction.Stand)
end
