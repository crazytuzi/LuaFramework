QualitySetting = {}
QualitySettingLevel = { low = 1, middle = 2, high = 3}
local config
local helper = SDKHelper.instance
local slower = string.lower
function QualitySetting.InitQuality()
    local cs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_HARDWARE_QUALITY)
    local pf = Util.GetPlatForm()
    if pf == 0 or pf == 7 then --mac/win editor 
        QualitySetting._SetQualityConfig(cs[#cs])
        return
    end
    local cpu
    local memory
    local mobileName
    local isAndroid = Util.GetPlatForm() == 11
    if isAndroid then
        local SystemInfo = UnityEngine.SystemInfo
        cpu = helper:GetCpuInfo()
        memory = math.round( SystemInfo.systemMemorySize / 1024)
    else
        mobileName = LogHelp.instance.device_model
    end
    local cpuRate
    local memoryRate
    local lev 
    for i = 1, 3 do
        local c = cs[i]
        if isAndroid then
            if not cpuRate then
                if QualitySetting._ContainsEqual(c.cpu, cpu) then
                    cpuRate = i
                end
            end
            if not memoryRate then
                local m = c.ram
                if m <= memory then memoryRate = i end
            end
        else
            if not lev then
                if QualitySetting._ContainsEqual(c.ios, mobileName) then
                    lev = i
                    break
                end
            end
        end
    end
    if isAndroid then
        Warning(tostring(cpu) .."_" .. tostring(memory) .. "____" ..  tostring(cpuRate) .."_" .. tostring(memoryRate))
        if not cpuRate then cpuRate = 3 end
        if not memoryRate then memoryRate = 3 end
        local rate = (cpuRate + memoryRate) / 2
        lev = math.clamp( math.round(rate), 1, 3)
    else
        Warning(tostring(mobileName) .. "____" ..  tostring(lev))
        if not lev then lev = 3 end
    end    
    local cc = cs[lev]
    if cc then QualitySetting._SetQualityConfig(cc) end
end
function QualitySetting._ContainsEqual(t, v)
    if not t or not v then return false end
    v = slower(v)
	for i = #t, 1, -1 do
		if slower(t[i]) == v then
			return true
		end
	end
	return false
end

function QualitySetting._SetQualityConfig(c)
    local QualitySettings = UnityEngine.QualitySettings
    QualitySettings.masterTextureLimit = c.texture
    -- QualitySettings.vSyncCount = c.vSync
    --QualitySettings.antiAliasing = c.aliasing --��׿������
    config = c
end

function QualitySetting.GetEffectMax()
    return config.num_effect
end
function QualitySetting.GetMonsterMax()
    return config.num_monster
end
function QualitySetting.GetPlayerMax()
    return config.num_player
end
function QualitySetting.GetRealShadowMax()
    return config.real_shadow == 1
end

QualitySetting.InitQuality()
