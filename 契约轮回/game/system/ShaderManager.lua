--
-- @Author: LaoY
-- @Date:   2018-08-13 15:21:06
--
ShaderManager = ShaderManager or class("ShaderManager", BaseManager)
local this = ShaderManager

ShaderManager.ShaderNameList = {
    Default = "Unlit/Texture",
    Color = "Color",
    AlphaBlending_Fresnel_fog = "AlphaBlending_Fresnel_fog",
    Alpha_shader = "Alpha_shader",
    Gray_shader = "MyShaderGray",
    Gray_shader1 = "MyShaderGray1",
    Default_shader = "Sprites-Default",
    ScrollMask = "MyShader/UI_ScrollMask",
    Outline2 = "outline2",
    Stencil_Mask = "stencil mask",
    Fresnel     = "fresnel",
}

function ShaderManager:ctor()
    ShaderManager.Instance = self
    self.shader_list = {}
    self.mat_stencil = {}
    self.shader_list[ShaderManager.ShaderNameList.Default] = Shader.Find(ShaderManager.ShaderNameList.Default)
    self:Reset()
    self:AddEvent()
end

function ShaderManager:Reset()
end

function ShaderManager.GetInstance()
    if ShaderManager.Instance == nil then
        ShaderManager()
    end
    return ShaderManager.Instance
end

function ShaderManager:AddEvent()
    local function call_back()
        self:LoadShader()
        if self.event_id_1 then
            GlobalEvent:RemoveListener(self.event_id_1)
            self.event_id_1 = nil
        end
    end
    self.event_id_1 = GlobalEvent:AddListener(EventName.HotUpdateSuccess, call_back)
end

function ShaderManager:LoadShader()
    local list = {
        ShaderManager.ShaderNameList.Color,
        ShaderManager.ShaderNameList.AlphaBlending_Fresnel_fog,
        ShaderManager.ShaderNameList.Alpha_shader,
        ShaderManager.ShaderNameList.Gray_shader,
        ShaderManager.ShaderNameList.Gray_shader1,
        ShaderManager.ShaderNameList.Default_shader,
        ShaderManager.ShaderNameList.Outline2,
        ShaderManager.ShaderNameList.Stencil_Mask,
        ShaderManager.ShaderNameList.Fresnel,
    }

    for k, name in pairs(list) do
        local function load_call_back(objs)
            if objs and objs[0] then
                self:InitShader(name, objs[0])
            end
        end
        -- resMgr:LoadShader("shader",name, load_call_back)
        -- self:InitShader(name,Shader.Find(name))
        lua_resMgr:LoadShader(self, "shader", name, load_call_back)
    end
end

function ShaderManager:InitShader(name, shader)
    -- if name == ShaderManager.ShaderNameList.Fresnel_fog or
    -- 	name == ShaderManager.ShaderNameList.AlphaBlending_Fresnel_fog then
    -- end
    self.shader_list[name] = shader
end

function ShaderManager:GetShaderByName(name)
    -- return newObject(self.shader_list[name])
    return self.shader_list[name]
end

function ShaderManager:FindShaderByName(shaderName)
    return Shader.Find(shaderName);
end
--obj 支持 Button(要获取成image),Image,SpriteRenderer等等
--
--
--
--@ling或者在这里保存旧的shader
function ShaderManager:SetImageGray(obj, _StencilId, _StencilIype)
    local shader = self:GetShaderByName("MyShaderGray")
    --if PlatformManager:GetInstance().cur_platform_type == PlatformManager.RuntimePlatform.Android then
    --    shader = self:GetShaderByName("MyShaderGray1")
    --end
    if _StencilId then
        if not self.mat_stencil[_StencilId] then
            self.mat_stencil[_StencilId] = Material(shader)
        end
        mat = self.mat_stencil[_StencilId]
    else
        if not self.mat then
            self.mat = Material(shader)
        end
        mat = self.mat
    end
    if _StencilId then
        mat:SetInt("_Stencil", _StencilId)
    else
        mat:SetInt("_Stencil", 0)
    end
    if _StencilIype then
        mat:SetInt("_StencilComp", _StencilIype)
    else
        mat:SetInt("_StencilComp", 8)
    end

    if obj and shader then
        obj.material = mat
    else
        print2("img is nil")
    end
end
--@ling,可能要加入运行平台判断,因为如果你不做,可能会在安卓端或者IOS端出问题
function ShaderManager:SetImageNormal(obj)
    if obj then
        --local mat = obj.material;
        obj.material = nil
        --destroy(mat);
    end
    --local shader = self:GetShaderByName("Sprites-Default");
    --if obj and shader then
    --    local mat = Material(shader);
    --    obj.material = nil;
    --else
    --    print2("img is nil");
    --end
end
--function ShaderManager:SetImageNormal(obj)
--    local shaderf = Shader.Find("Sprites-Default");
--    print2(shaderf);
--    if shaderf then
--        print2(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
--
--        if obj then
--            local mat = Material(shaderf);
--            print()
--            obj.material = mat;
--        end
--    else
--        print2("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
--
--        local shader = self:GetShaderByName("Sprites-Default");
--        if obj and shader then
--            local mat = Material(shader);
--            obj.material = mat;
--        else
--            print2("img is nil");
--        end
--    end
--end

---ScrollRect遮罩Material
function ShaderManager:GetScrollRectMaskMaterial()

	--logError("ShaderManager:GetScrollRectMaskMaterial is " .. tostring(self.scrollRectMaskMaterial ))

    if not self.scrollRectMaskMaterial then
        local s = Shader.Find(self.ShaderNameList.ScrollMask)
        if s then
            self.scrollRectMaskMaterial = Material(s)
        else
            print2("Not Scroll Mask Shader")
            return nil
        end
    end

    return self.scrollRectMaskMaterial
end


-- 添加+
function ShaderManager:AddShadow()

end

function ShaderManager:RemoveShadow()

end

ShaderManager.FresnelMatName = "FresnelMat"
function ShaderManager:GetFresnelMat()
    local shader = self:GetShaderByName(ShaderManager.ShaderNameList.Fresnel)
    --if PlatformManager:GetInstance().cur_platform_type == PlatformManager.RuntimePlatform.Android then
    --    shader = self:GetShaderByName("MyShaderGray1")
    --end
    if shader then
        local mat = Material(shader)
        mat.name = ShaderManager.FresnelMatName
        return mat
    end
    return nil
end