---
--- Created by R2D2.
--- DateTime: 2019/3/12 14:30
---
HardwareController = HardwareController or class("HardwareController", BaseController)
local this = HardwareController

function HardwareController:ctor()
    HardwareController.Instance = self

    self.events = {}

    self:Init()
    self:AddEvents()
    self:SetResLevel()
    --self:Test()
end

function HardwareController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function HardwareController:AddEvents()
    self.events[#self.events + 1] = GlobalEvent:AddListener(SettingEvent.Screen_Resolution_Event, handler(self, self.OnScreenResolution))
end

function HardwareController:OnScreenResolution(level)
    print("-------------> OnScreenResolution = " .. level)
    if(type(level) == "number") then
        self:SetScreen(level)
    end
end

function HardwareController:GetInstance()
    if not HardwareController.Instance then
        HardwareController.new()
    end
    return HardwareController.Instance
end

function HardwareController:Init()

    self.ScreenWidth = UnityEngine.Screen.width
    self.ScreenHeight = UnityEngine.Screen.height
    self.ScreenLevel = {1, 0.6, 0.4}

    self.graphicsDeviceName = SystemInfo.graphicsDeviceName
    self.graphicsMemorySize = SystemInfo.graphicsMemorySize

    if Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer then

    elseif Application.platform == UnityEngine.RuntimePlatform.Android then
        self:SetAndroidLevel()
    else
        self.HardwareLevel = 3
        print("非移动平台上，默认评级 =" .. self.HardwareLevel)
    end

end
--
--function HardwareController:Test()
--    self.graphicsDeviceName =  "Mali-G76"
--    self:SetAndroidLevel()
--end

function HardwareController:SetScreen(quality)

    local quality = math.floor(quality)
    local rate = 1

    if (quality > #self.ScreenLevel) then
        rate = self.ScreenLevel[#self.ScreenLevel]
    elseif quality < 1 then
        rate = 1
    else
        rate = self.ScreenLevel[quality]
    end

    local width = math.floor(self.ScreenWidth * rate)
    local height = math.floor(self.ScreenHeight * rate)

    UnityEngine.Screen.SetResolution(width, height, true)
end

function HardwareController:SetAndroidLevel()
    local dName = self:RemoveTm(self.graphicsDeviceName)
    local splitName = self:SplitMulti(dName, "-", " ")
    local key = table.concat(splitName, "-")

    if (#splitName == 2) then

        for _, v in pairs(Config.db_phone_gpu) do
            if (v.Key2 == key) then
                self.GPU = v
                print("找到[Key2]显卡配置，ID =" .. self.GPU.id .. ", 评级 =" .. self.GPU.classify)
                break
            end
        end

    elseif (#splitName == 3) then

        for _, v in pairs(Config.db_phone_gpu) do
            if (v.Key3 == key) then
                self.GPU = v
                print("找到[Key3]显卡配置，ID =" .. self.GPU.id .. ", 评级 =" .. self.GPU.classify)
                break
            end
        end
    end

    if (not self.GPU) then
        self.HardwareLevel = 2
        print("未找相应显卡配置，Name =" .. self.graphicsDeviceName .. ", 默认评级 =" .. self.HardwareLevel)
    end
end

---部分Android的显卡上面会有(TM)要移除，合并空格
function HardwareController:RemoveTm(input)

    local str = string.gsub(string.lower(input), "%(tm%)", "")
    str = string.gsub(str, "  ", " ")
    return str
end

---用多个分切符分割字符串，不支持中文
function HardwareController:SplitMulti(input, ...)
    input = tostring(input)
    local delimiters = { ... }
    local allPos = {}

    ---取出所有查找到的位置
    for i = 1, #delimiters do
        local pos = 0
        local delimiter = delimiters[i]

        if (delimiter ~= "") then
            for _, e in function()
                return string.find(input, delimiter, pos, true)
            end do
                table.insert(allPos, e)
                pos = e + 1
            end
        end
    end

    ---按大小排列顺序
    table.sort(allPos, function(a, b)
        return a < b
    end
    )

    ---从0开始按次分割原字符串
    local sp = {}
    local strStart, strEnd = 0, 0

    for i = 1, #allPos do
        strStart = strEnd + 1
        strEnd = allPos[i]

        table.insert(sp, string.sub(input, strStart, strEnd - 1))
    end

    ---如End之后仍有字符，直接加入
    if (strEnd < #input) then
        table.insert(sp, string.sub(input, strEnd + 1))
    end

    return sp
end

-- 等级越高 机子越好
function HardwareController:GetLevel()
    if (self.GPU) then
        return self.GPU.classify
    else
        if self.HardwareLevel then
            return self.HardwareLevel
        end
        return 2
    end
end

function HardwareController:SetResLevel()
    -- 低端机帧数 改低
    local device_lv = HardwareController:GetInstance():GetLevel()
    if PlatformManager:GetInstance():IsIos() then
        device_lv = 3
    end
    self:SetLevel(device_lv)
    if device_lv == 1 then
        AppConfig.coroutine_count = 12
        Constant.AllEffectCount = 8
    elseif device_lv == 2 then
        AppConfig.coroutine_count = 10
        Constant.AllEffectCount = 14
    elseif device_lv == 3 then
        AppConfig.coroutine_count = 12
        Constant.AllEffectCount = 20
    end

    -- Constant.AllEffectCount = 20

    -- if AppConfig.engineVersion and AppConfig.engineVersion > 1 then
    --     UnityEngine.QualitySettings.vSyncCount = 2
    -- end
    -- AppConfig.coroutine_count = 4
    
    -- if device_lv == 1 then
    --     LuaResourceManager.ExecuteFrequence = 1
    --     LuaResourceManager.LowExecuteFrequence = 2
    --     Application.targetFrameRate = 30
    -- -- 中端机
    -- elseif device_lv == 2 then
    --     LuaResourceManager.ExecuteFrequence = 1
    --     LuaResourceManager.LowExecuteFrequence = 2
    --     Application.targetFrameRate = 30
    -- else
    --     LuaResourceManager.ExecuteFrequence = 1
    --     LuaResourceManager.LowExecuteFrequence = 2
    --     Application.targetFrameRate = 45
    -- end 
end


function HardwareController:SetLevel(level)
    -- 低端机帧数 改低
    if level == 1 then
        LuaResourceManager.ExecuteFrequence = 1
        LuaResourceManager.LowExecuteFrequence = 1
        Application.targetFrameRate = 30
        if AppConfig.engineVersion and AppConfig.engineVersion > 1 then
            UnityEngine.QualitySettings.vSyncCount = 2
        end
        AppConfig.coroutine_count = 14
        -- 中端机
    elseif level == 2 then
        LuaResourceManager.ExecuteFrequence = 1
        LuaResourceManager.LowExecuteFrequence = 1
        Application.targetFrameRate = 30
        if AppConfig.engineVersion and AppConfig.engineVersion > 1 then
            UnityEngine.QualitySettings.vSyncCount = 2
        end
        AppConfig.coroutine_count = 16
    else
        LuaResourceManager.ExecuteFrequence = 1
        LuaResourceManager.LowExecuteFrequence = 1
        Application.targetFrameRate = 60
        AppConfig.coroutine_count = 12

        Constant.AllEffectCount = 40

        if AppConfig.engineVersion and AppConfig.engineVersion > 1 then
            UnityEngine.QualitySettings.vSyncCount = 1
        end
    end
end
