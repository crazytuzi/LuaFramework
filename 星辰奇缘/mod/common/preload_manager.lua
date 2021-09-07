-- 资源预加载
PreloadManager = PreloadManager or BaseClass()

function PreloadManager:__init()
    if PreloadManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    PreloadManager.Instance = self;

    self.resources = {
        -- loadType属性只能这里用
        {file = AssetConfig.base_textures, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.basecompress_textures, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.font, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.slot_res, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        -- ,{file = AssetConfig.headother_textures, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        -- ,{file = AssetConfig.headother_textures2, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.heads, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.animation, type = AssetType.Main, loadType = AssetLoadType.Cache}
        -- ,{file = AssetConfig.headanimation_male, type = AssetType.Main, loadType = AssetLoadType.Cache}
        -- ,{file = AssetConfig.headanimation_female, type = AssetType.Main, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.combat_functioniconPath, type = AssetType.Main, loadType = AssetLoadType.Cache}
        -- ,{file = AssetConfig.combat_map, type = AssetType.Main}
        ,{file = AssetConfig.skill_shout, type = AssetType.Dep}
        ,{file = AssetConfig.combat_skillareaPath, type = AssetType.Main}
        ,{file = AssetConfig.sound_effect_path, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.sound_battle_path, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.face_res, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.face_special_res, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.bubble_icon, type = AssetType.Dep}
        ,{file = "textures/materials/grey.unity3d", type = AssetType.Main}
        ,{file = "textures/materials/uimask.unity3d", type = AssetType.Main}
        ,{file = AssetConfig.shader_effects, type = AssetType.Dep}
        ,{file = AssetConfig.shader_unlittexturehead, type = AssetType.Dep}
        ,{file = AssetConfig.shader_unlittexturemap, type = AssetType.Dep}
        ,{file = AssetConfig.shader_unlittexturenpc, type = AssetType.Dep}
        ,{file = AssetConfig.shader_unlittexturerole, type = AssetType.Dep}
        ,{file = AssetConfig.shader_unlittexturesurbase, type = AssetType.Dep}
        ,{file = AssetConfig.shader_unlittextureweapon, type = AssetType.Dep}
        ,{file = AssetConfig.shader_unlittexturewing, type = AssetType.Dep}
        ,{file = AssetConfig.shader_unlittextureride, type = AssetType.Dep}
        ,{file = AssetConfig.shader_unlittexturemasker,type = AssetType.Dep}

        ,{file = AssetConfig.honor_img, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.maxnumber_3, type = AssetType.Dep}
        ,{file = AssetConfig.maxnumber_4, type = AssetType.Dep}
        ,{file = AssetConfig.maxnumber_5, type = AssetType.Dep}
        ,{file = AssetConfig.maxnumber_6, type = AssetType.Dep}
        ,{file = AssetConfig.maxnumber_7, type = AssetType.Dep}
        ,{file = AssetConfig.maxnumber_8, type = AssetType.Dep}
        ,{file = AssetConfig.maxnumber_9, type = AssetType.Dep}
        ,{file = AssetConfig.maxnumber_12, type = AssetType.Dep}
        ,{file = AssetConfig.maxnumber_14, type = AssetType.Dep}
        ,{file = AssetConfig.maxnumber_str, type = AssetType.Dep}
        ,{file = AssetConfig.crossvoiceimgtexture, type = AssetType.Dep}


        -- 头像图集
        -- ,{file = AssetConfig.head_custom_face, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        -- ,{file = AssetConfig.head_custom_hair, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.head_custom_face_male_1, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.head_custom_face_female_1, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.head_custom_face_male_2, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.head_custom_face_female_2, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.head_custom_hair_male, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.head_custom_hair_female_1, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.head_custom_hair_female_2, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.head_custom_bg, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.head_custom_wear1, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.head_custom_wear2, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        -- ,{file = AssetConfig.head_custom_wear2, type = AssetType.Dep, loadType = AssetLoadType.Cache}

        ,{file = AssetConfig.head_custom_photoframe, type = AssetType.Dep, loadType = AssetLoadType.Cache}

        ,{file = AssetConfig.slot_skill, type = AssetType.Main, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.rolelev_frame, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.headride, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        ,{file = AssetConfig.mainui_textures, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        -- ,{file = AssetConfig.skillIcon_pet, type = AssetType.Dep, loadType = AssetLoadType.Cache}
        -- ,{file = AssetConfig.skillIcon_pet2, type = AssetType.Dep, loadType = AssetLoadType.Cache}
    }

    -- 第二字体现在不用了，安卓直接把第一字体改为静态，ios就独立用动态
    -- if Application.platform == RuntimePlatform.Android
    --         or Application.platform == RuntimePlatform.WindowsEditor
    --         or Application.platform == RuntimePlatform.WindowsPlayer
    --     then
    --     table.insert(self.resources, {file = AssetConfig.font_android, type = AssetType.Dep, loadType = AssetLoadType.Cache})
    -- end


    if BaseUtils.IsVerify then
        table.insert(self.resources, {file = AssetConfig.verify_textures, type = AssetType.Dep})
    end
    

    self.assetWrapper = nil
    self.finish = false

    self.total = #self.resources
    self.progress = 0
end

function PreloadManager:__delete()
end

function PreloadManager:PreLoad(callback)
    ctx.LoadingPage:Show(TI18N("预加载文件(0%)"))
    if self.assetWrapper == nil then
        local cbfunc = function()
            self.finish = true;
            callback()
        end
        self.assetWrapper = AssetBatchWrapper.New()
        local progressCall = function(file)
            self:UpdateProgress(file)
        end
        self.assetWrapper:LoadAssetBundle(self.resources, cbfunc, progressCall)
    else
        Log.Error("PreloadManager不可以重复加载")
    end
end

function PreloadManager:UpdateProgress(file)
    self.progress = self.progress + 1
    if self.progress > self.total then
        self.progress = self.total
    end

    if BaseUtils.IsVerify then  
        -- 审核服的话，进度条只跑一次，预加载的进度条从60%开始跑
        local percent = (self.progress / self.total) * 100 * 0.4 + 60
        ctx.LoadingPage:Progress(TI18N("预加载文件"), percent)
    else
        local percent = (self.progress / self.total) * 100
        ctx.LoadingPage:Progress(string.format(TI18N("预加载文件(%0.1f%%)"), tostring(percent)), percent)
    end
end

function PreloadManager:GetMainAsset(file)
    if not self.finish then
        Log.Error("预加载文件还没加载完")
    end
    if self.assetWrapper ~= nil then
        return self.assetWrapper:GetMainAsset(file)
    else
        return nil
    end
end

function PreloadManager:GetSprite(file, name)
    if not self.finish then
        Log.Error("预加载文件还没加载完")
    end
    if self.assetWrapper ~= nil then
        return self.assetWrapper:GetSprite(file, name)
    else
        return nil
    end
end

function PreloadManager:GetSubAsset(file, name)
    if not self.finish then
        Log.Error("预加载文件还没加载完")
    end
    if self.assetWrapper ~= nil then
        return self.assetWrapper:GetSubAsset(file, name)
    else
        return nil
    end
end

function PreloadManager:GetTextures(file, name)
    if not self.finish then
        Log.Error("预加载文件还没加载完")
    end
    if self.assetWrapper ~= nil then
        return self.assetWrapper:GetTextures(file, name)
    else
        return nil
    end
end

-- 由于道具图标图集过大，现在已经按照id段分开了多张图集
-- 这里提供了图道具图标的统一接口，传入图标id就可以了
function PreloadManager:GetItemSprite(iconId)
    return nil
    -- local path = ""
    -- if iconId < 20000 then
    --     path = AssetConfig.equipicon
    -- elseif iconId < 20800 then
    --     path = AssetConfig.itemicon
    -- elseif iconId < 22400 then
    --     path = AssetConfig.itemicon2
    -- elseif iconId < 23590 then
    --     path = AssetConfig.itemicon3
    -- elseif iconId < 28000 then
    --     path = AssetConfig.itemicon4
    -- elseif iconId <= 50000 then
    --     path = AssetConfig.itemicon5
    -- elseif iconId < 60000 then
    --     path = AssetConfig.itemicon6
    -- elseif iconId < 90000 then
    --     path = AssetConfig.itemicon7
    -- else
    --     path = AssetConfig.itemicon8
    -- end
    -- return self:GetSprite(path, tostring(iconId))
end

function PreloadManager:GetPetSprite(iconId)
     local path = AssetConfig.headother_textures
    if tonumber(iconId) > 10025 then
        path = AssetConfig.headother_textures2
    end
    return self:GetSprite(path, tostring(iconId))
end

function PreloadManager:GetClassesSprite(classes)
    return self:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(classes))
end

function PreloadManager:GetClassesHeadSprite(classes, sex)
    return self:GetSprite(AssetConfig.heads, classes .. "_" .. sex)
end

-- 获取主UI图标sprite
function PreloadManager:GetMainUiIconSprite(iconId)
    return self:GetSprite(AssetConfig.mainui_textures, tostring(iconId))
end

-- -- 获取宠物图标sprite
-- function PreloadManager:GetPetSkillSprite(iconId)
--     local resPath
--     if iconId ~= nil and tonumber(iconId) < 60130 then
--         resPath = AssetConfig.skillIcon_pet
--     else
--         resPath = AssetConfig.skillIcon_pet2
--     end
--     return self:GetSprite(resPath, tostring(iconId))
-- end
