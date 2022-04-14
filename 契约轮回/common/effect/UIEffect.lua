-- 
-- @Author: LaoY
-- @Date:   2018-07-19 16:04:54
--

UIEffect = UIEffect or class("UIEffect", BaseEffect)

function UIEffect:ctor(parent, effectId, is_old_delete_effect, layer, end_call_back)
    self.layer = layer
    self.config = nil
    self.is_play = false
    self.is_loaded = false
    self.end_call_back = end_call_back

    self.is_recursion_show = true
    if is_old_delete_effect then
        self:ClearChildEffect()
    end

    if Config.db_effect[effectId] then
        self.effectConfig = Config.db_effect[effectId]
    else
        return
    end

    --兼容父类调用方法
    self.abName = self.effectConfig.name
    self.assetName = self.effectConfig.name
    self.is_loop = self.effectConfig.isLoop == 1

    UIEffect.super.Load(self)
end

function UIEffect:dctor()
    EffectManager:GetInstance():RemoveEffectCallBack(self)
end

function UIEffect:SetEffectOrder()
    if self.order_index == nil then
        --local order
        --if (self.layer) then
        --    order = LayerManager:GetInstance():GetLayerOrderByName(self.layer)
        --end
        --self:SetOrderIndex((order or 200) + 1)
        self:SetOrderByParentAuto()
    end
end

function UIEffect:LoadCallBack()
    self.is_play = true
    SetChildLayer(self.transform, LayerManager.BuiltinLayer.UI)
    SetLocalScale(self.transform, 100, 100, 100)
    ---- UIDepth.SetOrderIndex(self.gameObject,false,201)
    --    --if self.order_index == nil then
    --    --    self:SetOrderIndex(201)
    --    --end
    self:SetEffectOrder()
    self:PlayEffect(true)

    if self.is_need_setConfig then
        self:ApplyConfig()
    end

    self:SetLoop(self.is_loop)

    if (not self.is_loop) then
        local function end_call_back()
            self:PlayCallBack()
            if self.end_call_back then
                self.end_call_back()
            end
        end
        EffectManager:GetInstance():AddEffectCallBack(self, end_call_back)
    end
end

function UIEffect:ApplyConfig()

    if self.config.pos then
        local pos = self.config.pos
        self:SetPosition(pos.x, pos.y, pos.z)
    end

    if self.config.scale then
        local scale = self.config.scale
        if type(scale) == "number" then
            SetLocalScale(self.transform, scale * 100, scale * 100, scale * 100)
        elseif type(scale) == "table" then
            if scale.z == nil then
                scale.z = 1
            end
            -- local effects = self.gameObject:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem))
            -- for i = 0, effects.Length - 1 do
            --     local effect = effects[i]
            --     effect.main.scalingMode = UnityEngine.ParticleSystemScalingMode.IntToEnum(1)
            --     SetLocalScale(effect.transform, scale.x, scale.y, scale.z)
            -- end
            SetLocalScale(self.transform, scale.x * 100, scale.y * 100, scale.z * 100)
        else
            SetLocalScale(self.transform, 100, 100, 100)
        end
    end

    if self.config.speed then
        local speed = self.config.speed or self.speed
        self:SetSpeed(speed)
    end

    if self.config.useMask then
        -- self:SetEffectMask()
    else
        -- todo set layer
    end

    if self.config.useStencil then
        self:SetEffectStencil()
    end

    if self.config.is_loop then
        self.is_loop = self.config.is_loop
    end

    if self.config.orderOffset then
        self.auto_order_count = self.config.orderOffset
        self:SetOrderByParentAuto()
        --local CanvasSortingOrder = LayerManager:GetInstance():GetLayerOrderByName(self.layer)
        --self:SetOrderIndex(CanvasSortingOrder + self.config.orderOffset)
    end

    if self.config.rotation then
        SetLocalRotation(self.transform,self.config.rotation.x,self.config.rotation.y,self.config.rotation.z)
    end
end


--[[
	@author LaoY
	@des	
	@param  config 	table
	@param1 pos		Vector3
	@param2 scale 	number or Vector3
	@param3 useMask bool
	@param4 is_loop bool
--]]
function UIEffect:SetConfig(config)

    self.config = config or self.config
    if not self.config then
        return
    end

    if self.is_loaded then
        self.is_need_setConfig = false
        self:ApplyConfig()
    else
        self.is_need_setConfig = true
    end
end