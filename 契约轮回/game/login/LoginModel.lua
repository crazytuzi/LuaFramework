--
-- Author: LaoY
-- Date: 2018-07-11 16:49:57
--
LoginModel = LoginModel or class("LoginModel", BaseModel)
-- local LoginModel = LoginModel

LoginModel.DefaultChannelId = "develop"
LoginModel.DefaultGameId = ""

LoginModel.ZoneID = 1000001
LoginModel.ZoneName = 1000001


LoginModel.IP   = nil
LoginModel.Port = nil

-- 游戏进入后台时执行该方法 pause为true 切换回前台时pause为false
function LoginModel.OnApplicationPause(pause)
    -- 这里可以不用处理 处理焦点即可
end

-- 处理焦点即可
-- 游戏失去焦点也就是进入后台时 focus为false 切换回前台时 focus为true
function LoginModel.OnApplicationFocus(focus)
    if focus then
        GlobalEvent:Brocast(EventName.OnResume)
    else
        GlobalEvent:Brocast(EventName.OnPause)
    end
end

function LoginModel:ctor()
    LoginModel.Instance = self
    self.isOutServer = false
    --只播放一次选中动画
    self.is_showed_one_off_anim = true
    --AppConfig.isOutServer = false;
    --gameMgr.isGameRelease = false;
    if gameMgr.isGameRelease == true then
        self.ip_list = {
            { name = "Test服", ip = "39.108.239.119:9001:develop:0" },
            default = 1,
        }
    else
        -- if AppConst.UpdateMode and AppConst.appConfig.isOutServer then
        if AppConfig.isOutServer then
            self.ip_list = {
                { name = "外服", ip = "39.108.239.119:9002:develop:0" },
                default = 1,
            }
            self.isOutServer = true
        else
            self.ip_list = {
                { name = "", ip = "192.168.31.100:10001:develop:0" },
                { name = "Test服", ip = "192.168.31.100:10005:develop:0" },
                { name = "Test服2", ip = "192.168.31.100:10006:develop:0" },
                { name = "体验服", ip = "192.168.31.100:10002:develop:0" },
                { name = "钟华", ip = "192.168.31.200:9310:develop:0" },
                { name = "杰林", ip = "192.168.31.100:9330:develop:0" },
                { name = "陈荣", ip = "192.168.31.195:9001:develop:0" },
                { name = "外服", ip = "39.108.239.119:9005:111648:207" },
                { name = "稳定服", ip = "47.106.78.222:9002:develop:0" },
                { name = "小米外服", ip = "120.79.93.201:9001:112215:207" },
                { name = "先行服", ip = "120.79.93.201:9001:112404:207" },
                { name = "模拟外服", ip = "192.168.31.100:10007:112404:207" },
                default = 1,
            }
        end
    end

    self.ip_list.default = AppConfig.defauleServerIndex or self.ip_list.default

    --self.ip_list = {
    --    { name = "外服", ip = "39.108.239.119:9003" },
    --    default = 1,
    --}

    self.sdk_login_info = {}

    self.login_server_info = nil
    self:Reset()
end

function LoginModel:Reset()
    self:StopHeart()
    self:StopTime()
    self:StopReconnect()
    self.heart_time_id = nil
    self.login_role_list = {}
    self.sdk_login_info = {}
    self.quit_game = nil

    -- 是否创建角色 进入游戏
    self.is_create_role = false
    self.open_time_stamp = 0

    self.is_connect = false
    self.is_reconnect = false
    self.last_heart_time = TimeManager:GetInstance():GetClient()

end

function LoginModel.GetInstance()
    if LoginModel.Instance == nil then
        LoginModel.Instance = LoginModel()
    end
    return LoginModel.Instance
end

-- 开始心跳包
function LoginModel:StartHeart()
    if self.heart_time_id then
        return
    end
    local function func()
        LoginController:GetInstance():RequestHeart()
    end
    func()
    self.heart_time_id = GlobalSchedule:Start(func, 15)
end

function LoginModel:StopHeart()
    if self.heart_time_id then
        GlobalSchedule:Stop(self.heart_time_id)
        self.heart_time_id = nil
    end
end

function LoginModel:StartTime()
    if self.server_time_id then
        return
    end
    local function func()
        LoginController:GetInstance():RequestTime()
        if AppConfig.Debug then
            LoginController:GetInstance():RequestClientTime()
        end
    end
    func()
    self.server_time_id = GlobalSchedule:Start(func, 5)
end

function LoginModel:StopTime()
    if self.server_time_id then
        GlobalSchedule:Stop(self.server_time_id)
        self.server_time_id = nil
    end
end

function LoginModel:IsShowError(error_no)
    for k, v in pairs(Config.ignore_error) do
        if error_no == v then
            return false
        end
    end
    return true
end

function LoginModel:SetIp(ip, port)
    self.ip = ip
    self.port = port
end

function LoginModel:SetAccount(account)
    self.account = account
end

function LoginModel:SetIsChangeRole(flag)
    self.is_change_role = flag
end

function LoginModel:GetIsChangeRole()
    return self.is_change_role
end

function LoginModel:SetToken(token)
    self.token = token
end

function LoginModel:SetOpenTime(stamp)
    self.open_time_stamp = stamp
end

--返回开服第几天
function LoginModel:GetOpenTime()
    local differ = os.time() - self.open_time_stamp
    if differ <= 0 then
        --Notify.ShowText("开服天数为0")
        return 0
    end
    local time = TimeManager.GetInstance():GetServerDifDay(self.open_time_stamp, os.time()) + 1
    -- local time2 = TimeManager.GetInstance():GetServerDifDay(self.open_time_stamp, os.time()) + 1
    -- local time1 = TimeManager.GetInstance():GetDifDay(self.open_time_stamp, os.time()) + 1

    -- local date = TimeManager:GetInstance():GetTimeDate(self.open_time_stamp)
    -- local serverDate = TimeManager:GetInstance():ServerTimeDate(self.open_time_stamp)
    -- logError("====GetOpenTime====",time1,time2,self.open_time_stamp,Table2String(date),Table2String(serverDate))
    return time
end

--获得开服时间戳
function LoginModel:GetOpenStamp()
    return self.open_time_stamp
end

function LoginModel:SetReConnect()
    self.is_reconnect = true
end

function LoginModel:StopReconnect()
    if self.reconnect_time_id then
        GlobalSchedule:Stop(self.reconnect_time_id)
        self.reconnect_time_id = nil
    end
end

--设置为退出状态
function LoginModel:SetQuit(number)
    self.quit_number = number
end

function LoginModel:IsQuit()
    return self.quit_number ~= nil
end

-- SDK登录成功返回的信息，由于自己服务器登录验证
function LoginModel:SetSDKLoginInfo(info)
    self.sdk_login_info = info
end

function LoginModel:GetSDKLoginInfo()
    return self.sdk_login_info
end

function LoginModel:GetToken()
    --if table.isempty(self.sdk_login_info) then
    return self.token
    --[[	else
            if not self.sdk_login_info.loginInfo then
                return self.token
            else
                return self.sdk_login_info.loginInfo.access_token
            end
        end--]]
end

function LoginModel:GetGameId()
    return self.sdk_login_info.loginInfo and self.sdk_login_info.loginInfo.game_id
end

function LoginModel:SetNftToken(token)
    self.sdk_login_info.loginInfo = {
        token = token,
        uid = "",
    }
end

function LoginModel:Login()
    local game_channel_id = self:GetChannelId()
    if table.isempty(self.sdk_login_info) then
        LoginController:GetInstance():RequestLoginVerify(self.account, AppConfig.pack_name, LoginModel.DefaultChannelId)
    else
        local info = self.sdk_login_info.loginInfo
        if info then
            LoginController:GetInstance():RequestLoginVerify(info.uid, AppConfig.pack_name, game_channel_id, info.token)
        end
    end
end

function LoginModel:GetChannelId()
    -- return self.sdk_login_info.loginInfo and self.sdk_login_info.loginInfo.game_channel_id or LoginModel.DefaultChannelId
    local channelId = PlatformManager:GetInstance():GetChannelID()
    if channelId and channelId ~= "" then
        return channelId
    end
    return self.sdk_login_info.loginInfo and self.sdk_login_info.loginInfo.game_channel_id or LoginModel.DefaultChannelId
    -- return "111693"
end

function LoginModel:GetChannelNameById()
    local game_channel_id = self:GetChannelId()
    return "xwgame-" .. game_channel_id
end

function LoginModel:HotUdpateConfig(config_name)
    local function call_back(cf_str)
        local str = cf_str
        str = string.gsub(str, "Config = Config or {}", "")
        local ingore_str = string.format("Config.%s = ", config_name)
        str = string.gsub(str, ingore_str, "")
        local tab = LuaString2Table(str)
        if not table.isempty(tab) then
            Config[config_name] = tab
            GlobalEvent:Brocast(EventName.HotUpdateConfig, config_name)
        end
    end
    HttpManager:GetInstance():ResponseGetText(AppConfig.HotUpdateConfigCDN .. config_name .. ".lua", call_back)
end


--[[
    @author LaoY
    @des    是否第一次登陆
--]]
function LoginModel:InitFirstLanding()
    local role_id = RoleInfoModel:GetInstance():GetMainRoleId()
    role_id = role_id or "00"
    local key = Constant.EarliestLandingTimeCacheKey .. role_id
    local last_record_landing_time = CacheManager:GetInt(key, 0)
    local last_zero_time = last_record_landing_time > 0 and TimeManager:GetZeroTime(last_record_landing_time) or last_record_landing_time
    local cur_time = os.time()
    local cur_zero_time = TimeManager:GetZeroTime(cur_time)
    local oldState = Constant.IsFirstLanding
    Constant.IsFirstLanding = cur_zero_time > last_zero_time
    local isUpdate = oldState ~= Constant.IsFirstLanding
    Constant.EarliestLandingTime = cur_time
    if Constant.IsFirstLanding then
        CacheManager:SetInt(key, cur_time)
        Constant.EarliestLandingTime = last_record_landing_time
    end

    if isUpdate then
        GlobalEvent:Brocast(EventName.FirstLanding, Constant.IsFirstLanding)
    end
end

LoginModel.IsIOSExamine = false
function LoginModel:CheckExamine()
    if not PlatformManager:GetInstance():IsIos() then
        LoginModel.IsIOSExamine = false
        return
    end
    if not SelectServerModel:GetInstance().curSer then
        LoginModel.IsIOSExamine = false
        return
    end

    -- LoginModel.IsIOSExamine = LoginModel.IP == "39.108.239.119" and LoginModel.Port >= 9011 and LoginModel.Port <= 9020
    -- LoginModel.IsIOSExamine = LoginModel.IP == "47.244.209.228" and LoginModel.Port >= 9011 and LoginModel.Port <= 9020
    LoginModel.IsIOSExamine = SelectServerModel:GetInstance().curSer.issh
end

function LoginModel:GetFirstSceneResID(scene_res_id)
    if not LoginModel.IsIOSExamine then
        return scene_res_id
    end
    local tab = {
        [1] = "77771",
        [2] = "77772",
        [3] = "77773",
        [4] = "77774",
    }
    -- return tab[LoginModel.ResID] or scene_res_id
    return scene_res_id
end

function LoginModel:AutoEnterGame()
    if LoginModel.IsIOSExamine then
        LoginController:GetInstance():RequestCreateName(self.auto_enter_game_gender or 2)
    end
end

function LoginModel:SetLoginServerInfo(value)
    self.login_server_info = value
end

function LoginModel:GetLoginServerInfo()
    return self.login_server_info
end