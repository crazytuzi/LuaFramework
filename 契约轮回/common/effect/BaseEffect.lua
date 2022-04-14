-- 
-- @Author: LaoY
-- @Date:   2018-07-19 15:44:54
-- 
BaseEffect = BaseEffect or class("BaseEffect", Node)
local BaseEffect = BaseEffect

function BaseEffect:ctor(parent, abName)
    self.parent = parent
    self.abName = abName
    self.assetName = abName
    self.config = nil
    self.speed = 1
    self.is_play = false
    self.is_loaded = false
    self.is_hide_clean = true

    self.is_ui = false
end

function BaseEffect:dctor()
    self.material_block = nil
end

function BaseEffect:ResetParent(parent)
	self.parent = parent
    if not self.transform then
        return
    end
    self.transform:SetParent(self.parent)
end

function BaseEffect:DestyoyGameObject()
    if self.gameObject then
        if not poolMgr:AddGameObject(self.abName, self.assetName, self.gameObject) then
            destroy(self.gameObject)
        end
        self.gameObject = nil
    end
end

function BaseEffect:Load()
    local function call_back(objs, is_cache)
        local function step()
            self:CreateObject(objs, is_cache)
        end
        GlobalSchedule:StartOnce(step,0)
    end
    lua_resMgr:LoadPrefab(self, self.abName, self.assetName, call_back, nil, Constant.LoadResLevel.High, true)
end

-- function BaseEffect:SetOrderIndex(index)
--     self.order_index = index
--     if self.gameObject then
--         UIDepth.SetOrderIndex(self.gameObject, false, index)
--     end
-- end

function BaseEffect:CreateObject(objs, is_cache)
    -- 父节点删除或者自身类删除
    if IsNil(self.parent) or self.is_dctored or not objs or not objs[0] then
        return
    end

    local new_call_back = function(obj)
        if self.is_dctored then
            if not poolMgr:AddGameObject(self.abName, self.assetName, obj) then
                destroy(obj)
            end
            return
        end
        self.is_loaded = true
        self.is_play = true;
        --self.gameObject = newObject(objs[0])
        self.gameObject = obj;

        self.transform = self.gameObject.transform
        self.transform:SetParent(self.parent)

        SetLocalScale(self.transform)
        SetLocalRotation(self.transform, 0, 0, 0)
        if self.position ~= nil then
            self:SetPosition(self.position.x, self.position.y)
        else
            self:SetPosition(0, 0)
        end

        -- 不用这个
        -- self.particle = self.transform:GetComponent('ParticleSystem')

        -- self:SetVisible(false)
        -- self:SetVisible(true)
        if self.is_need_set_play ~= nil then
            self:PlayEffect(self.is_need_set_play)
        else
            if is_cache then
            end
            self:PlayEffect(true)
        end

        if self.order_index ~= nil then
            self:SetOrderIndex(self.order_index)
        end
        --
        -----------
        --local curTrans = self.gameObject.transform.parent
        --local myCanvas
        --while(curTrans) do
        --	myCanvas = curTrans:GetComponent("Canvas")
        --	if myCanvas then
        --		self.CanvasSortingOrder = LayerManager:GetInstance():GetLayerOrderByName(myCanvas.name)
        --		break
        --	else
        --		curTrans = curTrans.parent
        --	end
        --end
        -----------------

        self:LoadCallBack()
    end

    if is_cache then
        local function call_back()
            new_call_back(objs[0])
        end
        GlobalSchedule:StartOnce(call_back, 0)
    else
        lua_resMgr:GetPrefab("", "", objs[0], new_call_back);
    end
    --print2("BaseEffect new object" .. self.abName .. "__" .. self.assetName);
end

function BaseEffect:PlayCallBack()
    if IsNil(self.gameObject) then
        return
    end
    self:destroy()
end

function BaseEffect:SetSpeed(speed)
    SetParticleSpeed(self.gameObject, speed)
end

function BaseEffect:SetLoop(is_loop)
    SetParticleLoop(self.gameObject, is_loop)
end

function BaseEffect:ClearChildEffect()
    if self.parent then
        for i = 0, self.parent.childCount - 1 do
            self:PlayEnd(self.parent:GetChild(i).gameObject)
        end
    end
end

function BaseEffect:SetEffectStencil()
    if not self.config.stencilId then
        return
    end
    -- local is_use_block = AppConfig.engineVersion > 5
    local is_use_block = false
    if is_use_block then
        if not self.material_block then
            self.material_block = MaterialPropertyBlock()
        end
    end
    local renders = self.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer))
    for i = 0, renders.Length - 1 do
        if is_use_block then
            local render = renders[i]
            render:GetPropertyBlock(self.material_block)
            self.material_block:SetInt("_ID", self.config.stencilId);
            self.material_block:SetInt("_StencilComp", self.config.stencilType);
            render:SetPropertyBlock(self.material_block)
        else
            local mats = renders[i].materials
            for j = 0, mats.Length - 1 do
                mats[j]:SetInt("_ID", self.config.stencilId);
                mats[j]:SetInt("_StencilComp", self.config.stencilType);
            end
        end
    end
end

function BaseEffect:SetEffectMask()
    local renders = self.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer))
    for i = 0, renders.Length - 1 do
        local mats = renders[i].materials
        for j = 0, mats.Length - 1 do
            mats[j]:SetFloat("_Stencil", 1)
        end
    end
    local curTrans = self.gameObject.transform.parent
    local maskImage
    while (curTrans and curTrans.name ~= "Canvas") do
        maskImage = curTrans:GetComponent("Mask")
        if maskImage then
            break
        else
            curTrans = curTrans.parent
        end
    end
    if maskImage then
        local canvas = curTrans:GetComponent("Canvas")
        if canvas then
            UIDepth.SetOrderIndex(obj, false, canvas.sortingOrder + 1)
        end
    end
end

function BaseEffect:PlayEffect(flag)
    flag = toBool(flag)
    self.is_play = flag
    if not self.gameObject or IsGameObjectNull(self.gameObject) then
        return
    else
        self.is_need_set_play = flag
    end
    -- PlayParticle(self.gameObject,flag)

    if self.particle then
        if flag then
            self.is_play = true
            self.particle:Play()
        else
            self.is_play = false
            self.particle:Pause()
        end
    else
        PlayParticle(self.gameObject, flag)
    end
end

function BaseEffect:IsPlay()
    return self.is_play
end

function BaseEffect:PlayEnd(gameObject)
    if gameObject then
        destroy(gameObject)
    end
end

-- overwrite
function BaseEffect:LoadCallBack()
    logWarn(string.format("%s 特效要重写 LoadCallBack方法", self.assetName))
end