AutoFightManager = { }
local json = require "cjson"
AutoFightManager.defaultBaseConfig =
{
    showSkillEffect = true,
    showWing = true,
    showSkillShakeEffect = true,
    showPet = true,
    showShadow = QualitySetting.GetRealShadowMax(),
    showName = true,
    showTrump = true,
    --isMusicOpen = true,
    --isAudioOpen = true,
    musicVolume = 1.0,
    soundVolume = 1.0,
    maxPlayerCount = QualitySetting.GetPlayerMax(),
    maxPlayerSliderValue = 1,
}

AutoFightManager.BASESETTINGCHANGE = "BASESETTINGCHANGE"

AutoFightManager.restoreHP = 0.75;
AutoFightManager.restoreMP = 0.75;
AutoFightManager.attackAllArea = true;
AutoFightManager.autoGensui = true;
AutoFightManager.autoRecStMsg = true;

AutoFightManager.reliveProps = true;
AutoFightManager.awayBoss = true;
AutoFightManager.revenge = true;
AutoFightManager.castMinorSkill = true;

AutoFightManager.use_Drug_HP_id = nil; -- 自动使用 补红药品
AutoFightManager.use_Drug_MP_id = nil; -- 自动使用 补蓝药品
AutoFightManager.strengthen_eq_kind = nil; -- 自动强化 的 装备位置
AutoFightManager.strengthen_eq_quality1 = false; -- 只觉得强化 的 装备品质
AutoFightManager.strengthen_eq_quality2 = false;
AutoFightManager.strengthen_eq_quality3 = false;
AutoFightManager.strengthen_eq_quality4 = false;

AutoFightManager.skills = { };

local sm_instance = SoundManager.instance

function AutoFightManager.Init()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.LoadAutoFightConfig, AutoFightManager._CmdLoadAutoFightConfigHandler);
    SocketClientLua.Get_ins():SendMessage(CmdType.LoadAutoFightConfig, { });
    GameConfig.instance.useLight = false --AutoFightManager.GetBaseSettingConfig().showShadow
end

function AutoFightManager._FormatBoolValue(value)
    if (value == true) then
        return 1;
    end
    return 0;
end

function AutoFightManager.Save()
    local data = { };
    data.cfg = { };
    data.cfg[1] = math.round(AutoFightManager.restoreHP * 100);
    data.cfg[2] = math.round(AutoFightManager.restoreMP * 100);
    data.cfg[3] = AutoFightManager._FormatBoolValue(AutoFightManager.attackAllArea);
    data.cfg[4] = AutoFightManager._FormatBoolValue(AutoFightManager.reliveProps);
    data.cfg[5] = AutoFightManager._FormatBoolValue(AutoFightManager.awayBoss);
    data.cfg[6] = AutoFightManager._FormatBoolValue(AutoFightManager.revenge);
    data.cfg[7] = AutoFightManager._FormatBoolValue(AutoFightManager.castMinorSkill);
    data.cfg[8] = AutoFightManager.use_Drug_HP_id;
    data.cfg[9] = AutoFightManager.use_Drug_MP_id;
    data.cfg[10] = AutoFightManager.strengthen_eq_kind;

    if data.cfg[8] == nil then
        data.cfg[8] = 0;
    end

    if data.cfg[9] == nil then
        data.cfg[9] = 0;
    end

    if data.cfg[10] == nil then
        data.cfg[10] = 0;
    end

    data.cfg[11] = AutoFightManager.strengthen_eq_quality1;
    data.cfg[12] = AutoFightManager.strengthen_eq_quality2;
    data.cfg[13] = AutoFightManager.strengthen_eq_quality3;
    data.cfg[14] = AutoFightManager.strengthen_eq_quality4;

    data.cfg[11] = 0;
    data.cfg[12] = 0;
    data.cfg[13] = 0;
    data.cfg[14] = 0;

    if AutoFightManager.strengthen_eq_quality1 == true then
        data.cfg[11] = 1;
    end

    if AutoFightManager.strengthen_eq_quality2 == true then
        data.cfg[12] = 1;
    end

    if AutoFightManager.strengthen_eq_quality3 == true then
        data.cfg[13] = 1;
    end

    if AutoFightManager.strengthen_eq_quality4 == true then
        data.cfg[14] = 1;
    end


    data.cfg[15] = AutoFightManager._FormatBoolValue(AutoFightManager.autoGensui);
    data.cfg[16] = AutoFightManager._FormatBoolValue(AutoFightManager.autoRecStMsg);



    data.sks = AutoFightManager.skills;
    SocketClientLua.Get_ins():SendMessage(CmdType.SaveAutoFightConfig, data);
end

function AutoFightManager._CmdLoadAutoFightConfigHandler(cmd, data)

    if (data) then
        if (data.cfg) then
            AutoFightManager.restoreHP = data.cfg[1] / 100;
            AutoFightManager.restoreMP = data.cfg[2] / 100;
            AutoFightManager.attackAllArea =(data.cfg[3] == 1);
            AutoFightManager.reliveProps =(data.cfg[4] == 1);
            AutoFightManager.awayBoss =(data.cfg[5] == 1);
            AutoFightManager.revenge =(data.cfg[6] == 1);
            AutoFightManager.castMinorSkill =(data.cfg[7] == 1);

            AutoFightManager.use_Drug_HP_id = data.cfg[8];
            -- 自动使用 补红药品
            AutoFightManager.use_Drug_MP_id = data.cfg[9];
            -- 自动使用 补蓝药品

            AutoFightManager.strengthen_eq_kind = data.cfg[10];

            if AutoFightManager.use_Drug_HP_id == 0 then
                AutoFightManager.use_Drug_HP_id = nil;
            end

            if AutoFightManager.use_Drug_MP_id == 0 then
                AutoFightManager.use_Drug_MP_id = nil;
            end

            if AutoFightManager.strengthen_eq_kind == 0 then
                AutoFightManager.strengthen_eq_kind = nil;
            end

            AutoFightManager.strengthen_eq_quality1 = false;
            AutoFightManager.strengthen_eq_quality2 = false;
            AutoFightManager.strengthen_eq_quality3 = false;
            AutoFightManager.strengthen_eq_quality4 = false;

            if data.cfg[11] == 1 then
                AutoFightManager.strengthen_eq_quality1 = true;
            end

            if data.cfg[12] == 1 then
                AutoFightManager.strengthen_eq_quality2 = true;
            end

            if data.cfg[13] == 1 then
                AutoFightManager.strengthen_eq_quality3 = true;
            end

            if data.cfg[14] == 1 then
                AutoFightManager.strengthen_eq_quality4 = true;
            end


            AutoFightManager.autoGensui =(data.cfg[15] == 1);

            AutoFightManager.autoRecStMsg =(data.cfg[16] == 1);


        else
            AutoFightManager.restoreHP = 0.75;
            AutoFightManager.restoreMP = 0.75;
            AutoFightManager.attackAllArea = true;
            AutoFightManager.autoGensui = true;
            AutoFightManager.autoRecStMsg = true;
            AutoFightManager.reliveProps = true;
            AutoFightManager.awayBoss = true;
            AutoFightManager.revenge = true;
            AutoFightManager.castMinorSkill = true;

            AutoFightManager.use_Drug_HP_id = nil;
            -- 自动使用 补红药品
            AutoFightManager.use_Drug_MP_id = nil;
            -- 自动使用 补蓝药品

            AutoFightManager.strengthen_eq_kind = nil;

            AutoFightManager.strengthen_eq_quality1 = false;
            -- 只觉得强化 的 装备品质
            AutoFightManager.strengthen_eq_quality2 = false;
            AutoFightManager.strengthen_eq_quality3 = false;
            AutoFightManager.strengthen_eq_quality4 = false;

        end
        local sks = PlayerManager.hero.info.auto_skill1;
        if (data.sks) then
            sks = data.sks;
        end
        for i, v in pairs(sks) do
            AutoFightManager.skills[i] = v;
        end
    end
end
local baseConfigData

function AutoFightManager.InitBaseSettingConfig() 
    baseConfigData = {}
    local str = Util.GetString("baseConfig")
   
     if ((str == nil) or(str == "")) then
        baseConfigData = AutoFightManager.GetDefaultBaseSettingConfig()
    else
        baseConfigData = json.decode(str)
        if not baseConfigData.musicVolume then baseConfigData.musicVolume = 0.5 end
        --baseConfigData.musicVolume = sm_instance.musicVolume
        --baseConfigData.soundVolume = sm_instance.soundVolume
        --baseConfigData.isMusicOpen = sm_instance.isMusicOpen
        --baseConfigData.isAudioOpen = sm_instance.isAudioOpen
    end
    sm_instance.soundVolume = baseConfigData.soundVolume
    sm_instance.musicVolume = baseConfigData.musicVolume
    sm_instance.isMusicOpen = baseConfigData.musicVolume ~= 0
    sm_instance.isAudioOpen = baseConfigData.soundVolume ~= 0   
end

function AutoFightManager.GetBaseSettingConfig()
    -- local str = Util.GetString("baseConfig")
    -- local data = { }
    -- if ((str == nil) or(str == "")) then
    --     data = AutoFightManager.GetDefaultBaseSettingConfig()
    -- else
    --     data = json.decode(str)
    --     data.soundVolume = sm_instance.soundVolume
    --     data.isMusicOpen = sm_instance.isMusicOpen
    --     data.isAudioOpen = sm_instance.isAudioOpen
    -- end

    -- 这3个选项是实时保存的 所以以本地的为主,
    -- 防止修改这3个变量后没保存在本地
    if(baseConfigData == nil) then
        AutoFightManager.InitBaseSettingConfig() 
    end

    return baseConfigData
end

function AutoFightManager.SaveBaseSettingConfig(data)
    baseConfigData = data
    local str = json.encode(data)     
    Util.SetString("baseConfig", str)
end

function AutoFightManager.GetDefaultBaseSettingConfig()
    return ConfigManager.Clone(AutoFightManager.defaultBaseConfig)
end

function AutoFightManager.IsShowShadow()
    return AutoFightManager.GetBaseSettingConfig().showShadow
end

AutoFightManager.InitBaseSettingConfig() 