--
-- @Author: LaoY
-- @Date:   2018-09-30 10:50:18
--

local _, LuaDebuggee = pcall(require, 'LuaDebuggee')
if LuaDebuggee and LuaDebuggee.StartDebug then
    LuaDebuggee.StartDebug('127.0.0.1', 9826)
else
    print('Please read the FAQ.pdf')
end

if LuaFramework.LuaHelper.GetSDKManager().platform == 2 and LuaFramework.Util.IsAndroid64bit() then
    if jit then
        jit.off()
        jit.flush()
    end
end

-- 简单的计时
local Time = {
    time = 0,
    deltaTime = 0,
    frameCount = 0,
}

UpdateManager = {}
local self = UpdateManager

local LuaClickListener = LuaFramework.LuaClickListener
local Application = UnityEngine.Application
local RenderTexture = UnityEngine.RenderTexture
local function concat(...)
    local param = { ... }
    if #param == 0 then
        return ""
    elseif #param == 1 then
        return tostring(param[1])
    else
        local t = {}
        for i, v in ipairs(param) do
            t[i] = tostring(v)
        end
        return table.concat(t, " ")
    end
end

local function SetSizeDelta(transform, x, y)
    if transform then
        LuaFramework.UIHelp.SetSizeDelta(transform, x, y)
    end
end

local function GetCamera(gameObject)
    if not gameObject then
        return nil
    end
    return gameObject.gameObject:GetComponent("Camera")
end

local function GetRawImage(gameObject)
    if not gameObject then
        return
    end
    return gameObject.gameObject:GetComponent("RawImage");
end

--设置GameObject Active
local function SetGameObjectActive(obj, bool)
    if obj and obj.gameObject then
        bool = bool and true or false;
        obj.gameObject:SetActive(bool);
    end
end

local function AddClickEvent(target, call_back)
    if target then
        LuaClickListener.Get(target).onClick = call_back
    end
end

local function GetChild(transform, childName)
    if transform then
        return transform.transform:Find(childName);
    end
end

local function SetLocalPositionX(transform, x)
    if transform then
        --print2("aaaaa3" .. x);
        x = x or 0
        LuaFramework.UIHelp.SetLocalPositionX(transform, x)
    end
end

local function newrandomseed()
    -- local ok, socket = pcall(function()
    --     return require("socket")
    -- end)

    -- if ok then
    --     math.randomseed(socket.gettime() * 1000)
    -- else
    --     math.randomseed(os.time())
    -- end
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    math.random()
    math.random()
    math.random()
    math.random()
end

local log
local function print(...)
    if not log then
        if LuaFramework and LuaFramework.Util and LuaFramework.Util.LogWarning then
            log = LuaFramework.Util.LogWarning
        end
    end
    if log then
        local str = concat(...)
        log(str)
    end
end

local MessageEnum = {
    -- 暂时没用
    CopyStart = "CopyStart", -- 解包开始
    CopyState = "CopyState", -- 解包开始

    UPDATEStart = "UPDATEStart", -- 热更开始
    UpdateState = "UpdateState", -- 热更状态
    UpdateMessage = "UpdateMessage",
    UpdateExtract = "UpdateExtract",
    UpdateDownload = "UpdateDownload",
    UpdateProgress = "UpdateProgress",
}

function UpdateManager.Init(gameObject)
    self.is_dctor = false;
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.updateview = self.transform:GetComponent('UpdateView');
    self.go = self.updateview.go;
    local loadingText = GetChild(self.transform, "loadingText");
    self.loadingText = loadingText.gameObject:GetComponent("Text");--typeof(UnityEngine.UI.Text)
    local progress_bar = GetChild(self.transform, "progress/progress_bar");
    self.progress_bar = progress_bar.gameObject:GetComponent("Image");--typeof(UnityEngine.UI.Text)
    self.loadingText.text = "";

    self.desText = GetChild(self.transform, "desText")
    if self.desText then
        self.desText.gameObject:SetActive(false)
    end
    self.progress_bar.fillAmount = 0;
    self.effectCon = GetChild(self.transform, "effectCon");

    self.Camera = GetChild(self.effectCon, "Camera")
    SetGameObjectActive(self.effectCon, false);

    self.rawimage = GetRawImage(self.effectCon);
    self.Camera = GetCamera(self.Camera)

    if self.rawimage and self.Camera then
        self.rt = RenderTexture.GetTemporary(1024, 1024, 24);
        self.rawimage.texture = self.rt;
        self.Camera.targetTexture = self.rt;
        SetSizeDelta(self.rawimage.transform, 1024, 1024)
    end

    self.light_img = GetChild(self.transform, "progress/light");
    --print2(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    --print2(self.light_img);
    self.uiInitX = -555;
    --网络状态判断
    local reach = tostring(Application.internetReachability);
    print2("网络状态: " .. tostring(reach));
    --"ReachableViaCarrierDataNetwork"
    --"ReachableViaLocalAreaNetwork"
    if reach == "ReachableViaCarrierDataNetwork" or reach == "ReachableViaLocalAreaNetwork" then
        print2("network is ok");
    else
        local tip_panel = GetChild(self.transform, "tip_panel");
        if tip_panel then
            --显示无网络UI
            SetGameObjectActive(tip_panel, true);

            local exitFun = function()
                Application.Quit();
            end

            local sure = GetChild(tip_panel, "sure");
            if sure and sure.gameObject then
                AddClickEvent(sure.gameObject, exitFun);
            end
        end
    end
    --local bg = GetChild(self.go.transform , "bg");
    --self.bg = bg.gameObject:GetComponent("Image");
    -- local imgs = { "preloading_1", "preloading_2", "preloading_3", };
    -- newrandomseed();
    -- local imgNum = string.format("%d", math.random(1, #imgs));
    -- print2(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    -- print2(imgNum);
    -- local img = imgs[tonumber(imgNum)];
    -- print2(img);
    self.updateview:SetImageRes("image/loading.png");

    self.is_can_hot_update = true

    self.down_load_speed = math.random(1024) + 200
    self.total_size = 0
    self.had_down_load_value = 0
    self.last_str = ""

    self.start_time = 0
    self.start_value = 0

    self.updateview:SetText("Retrieving server info")

    self.is_start_update = false
    print('--LaoY UpdateManager.lua,line 139--', self.effectCon)
    print('--LaoY UpdateManager.lua,line 139--', self.light_img)
end

function UpdateManager.GetMessage(message_name, message_body)
    if self.is_dctor then
        return ;
    end
    local str = ""
    if message_name == MessageEnum.UPDATEStart then
        if message_body == "can_hot_update" then
            self.is_can_hot_update = true
        elseif message_body == "can_not_hot_update" then
            self.is_can_hot_update = false
        else
            self.total_size = message_body
            self.is_start_update = true
        end
        str = "Retrieving server info"
    elseif message_name == MessageEnum.UpdateMessage then
        if message_body == "compare_ness_file" or message_body == "start_update" then
            str = "Comparing file with server"
        elseif message_body == "compare_update_file" then
            str = "Initializing configuration table..."
        elseif message_body == "update_ok" then
            str = "Initialization successful"
        elseif message_body == "init_game" then
            str = "Entering game"
            self.destroyTime = Time.time + 1.0
        else
            self.start_time = Time.time
            self.start_value = self.had_down_load_value

            if type(message_body) == "number" then
                self.had_down_load_value = self.had_down_load_value + message_body;

                print("===========>", self.had_down_load_value, self.total_size)
            end

        end
    elseif message_name == MessageEnum.UpdateExtract then
        return
    elseif message_name == MessageEnum.UpdateDownload then
        return
    elseif message_name == MessageEnum.UpdateProgress then
        self.down_load_speed = message_body
    end

    if tonumber(self.had_down_load_value) >= tonumber(self.total_size) then
        self.had_down_load_value = self.total_size
    end

    local cur_per = self.total_size > 0 and math.ceil(self.had_down_load_value / self.total_size * 100) or 20

    if not self.is_can_hot_update then
        if cur_per <= 25 then
            str = "Retrieving server info"
        elseif cur_per <= 50 then
            str = "Comparing file with server"
        elseif cur_per <= 70 then
            str = "You are using the latest version"
        else
            str = "Initializing configuration table..."
        end
        self.updateview:SetText(str)
    end

    self.last_str = str
end

function UpdateManager:SetEffconPos()
    local targetx = self.uiInitX - 10 + (20 * self.fillAmount) + self.fillAmount * 1102;
    if self.effectCon then
        SetLocalPositionX(self.effectCon.transform, targetx)
    end
    if self.light_img then
        SetLocalPositionX(self.light_img.transform, targetx - 18)
    end
end

local lastSameTime
local math_floor = math.floor
function UpdateManager:UpdateInfo()
    if self.destroyTime and Time.time > self.destroyTime then
        self:destroy()
        return
    end

    local percent = 0
    if not self.is_start_update then
    elseif self.total_size == 0 or not self.start_value then
        self.not_hot_update_time = self.not_hot_update_time or Time.time
        percent = (Time.time - self.not_hot_update_time) / 1.95
    else
        local t = (Time.time - self.start_time) / 0.5
        local start_value = self.last_value or self.start_value
        local newValue = start_value + (self.had_down_load_value - start_value) * t
        self.last_value = newValue
        percent = newValue / self.total_size
    end

    if (percent ~= 0 and percent < 1 and self.fillAmount < 1 and percent <= self.fillAmount) then
        if lastSameTime and (Time.time - lastSameTime > 0.01) then
            percent = self.fillAmount + 0.0001
            lastSameTime = Time.time
        else
            return
        end
    else
        lastSameTime = Time.time
    end

    percent = percent < 0 and 0 or percent
    percent = percent > 1 and 1 or percent

    if self.fillAmount ~= percent and self.fillAmount ~= 1 then
        -- 进度条
        self.fillAmount = percent
        self.progress_bar.fillAmount = self.fillAmount

        -- 特效位置
        self:SetEffconPos()

        -- 进度百分比
        self.updateview:SetLoadingText((self.fillAmount * 100) .. "/100")
        -- 下载内容进度
        if self.is_can_hot_update and self.total_size ~= 0 then
            local str = string.format("Updating: %s/%s kb (%.2f%%)", math_floor(self.total_size * self.fillAmount), self.total_size, self.fillAmount * 100)
            self:SetText(str)
        else
            self:SetText(self.last_str)
        end
    end
end

function UpdateManager:SetText(text)
    if self.lastText == text then
        return
    end
    -- self.lastText = text
    self.updateview:SetText(text)
end

function UpdateManager.Update(time)
    if self.is_dctor then
        return
    end

    if Time.deltaTime == 0 then
        Time.deltaTime = 0.02
    else
        Time.deltaTime = time - Time.deltaTime
    end
    Time.time = time
    Time.frameCount = Time.frameCount + 1
    self:UpdateInfo()
end

function UpdateManager.OnDestroy()
    self:destroy()
end

function UpdateManager:destroy()
    self.is_dctor = true;
    self.gameObject = nil;
    self.transform = nil
    self.updateview = nil;
    self.go = nil;
    self.loadingText = nil;
    self.progress_bar = nil;
    self.effectCon = nil;
    if self.Camera then
        self.Camera.targetTexture = nil
    end
    if self.rawimage then
        self.rawimage.texture = nil
    end
    if self.rt then
        -- self.rt.texture = nil
        RenderTexture.ReleaseTemporary(self.rt)
        -- destroy(self.rt)
        self.rt = nil
    end
    self = nil
end
