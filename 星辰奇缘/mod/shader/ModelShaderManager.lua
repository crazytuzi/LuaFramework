-- 全局shader管理
ModelShaderManager = ModelShaderManager or BaseClass()

function ModelShaderManager:__init()
    if ModelShaderManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    ModelShaderManager.Instance = self;

    self.unitAlpahaShader = nil
    self.unlitTextureShader = nil
    self.isNewVersion = true 
end

function ModelShaderManager:__delete()
end

function ModelShaderManager:InitShader()
    self.unitAlpahaShader = PreloadManager.Instance:GetSubAsset(AssetConfig.shader_effects, "SceneUnitAlpaha")
    self.unlitTextureShader = PreloadManager.Instance:GetSubAsset(AssetConfig.shader_effects, "UnlitTexture")

    local curVer = BaseUtils.CSVersionToNum()
    if Application.platform == RuntimePlatform.Android then
        if curVer < 10206 then
            self.isNewVersion = false 
        else
            self.isNewVersion = true 
        end
    elseif Application.platform == RuntimePlatform.IPhonePlayer then
        if CSVersion.platform == "jailbreak" then
            if curVer < 10400 then
                self.isNewVersion = false  
            else
                self.isNewVersion = true
            end
        else
            if curVer < 10601 then
                self.isNewVersion = false
            else
                self.isNewVersion = true
            end
        end
    else
        self.isNewVersion = true
    end
end

function ModelShaderManager:ChangeShaderForOldVersion(material)
    if not self.isNewVersion then
        material.shader = self.unitAlpahaShader
    end
end
