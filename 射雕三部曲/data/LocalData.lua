

--[[
    文件名：LocalData.lua
	描述：保存游戏状态数据，包括玩家设置，登录信息等等
	创建人：liaoyuangang
	创建时间：2014.03.10
-- ]]

-- 缺少文件资源的处理函数，该函数由C++代码调用
function DealMissingFile(filename)
    print("lua DealMissingFile:", filename)
    LocalData:addMissingFile(filename)
end

-- base64编码时用的key
local base64EncodeKey = "" -- moqikaka-base64-encode-key

local loginDataFile = "LoginData.txt"       -- 保存玩家登录信息的文件
local versionDataFile = "versionData.txt" --游戏版本号
local userSettingFile = "UserSetting.txt"   -- 保存玩家设置信息的文件
local rechargeFile = "RechargeLog.txt"       -- 充值订单记录，只记录失败的信息，供下次再次尝试
local newTimedActivityFile = "newTimedActivity.txt" -- 新限时活动相关信息
local chatBaseDataFile = "ChatBaseData.txt"  -- 记录玩家聊天基本信息的文件
local enemyDataFile = "EnemyData.txt" -- 保存黑名单数据信息的文件
local onlineNotifyFile = "OnlineNotifyData.txt" -- 保存上线提醒数据信息的文件

--- ============================ 纪录各种类型数据公用的函数 =======================
LocalData = {}
-- 初始化本地文件数据对象
function LocalData:initLocalData()
    self.mAutoLogin = true --默认自动登录第三方SDK

    self.mEncodeClass = CommunicationDataEncodeClass:new()
    self.mEncodeClass:SetKey(base64EncodeKey)

    -- 使保存在文件中的用户设置生效
    self:takeEffectUserSetting()
end

-- 读取文件的数据到内存
--[[
-- 参数：
    filename: 保存文件的文件名
    defaultRet: 如果文件不存在或为空，默认的返回值，如果改参数为nil，则返回 {}
 ]]
function LocalData:readFileData(filename, defaultRet)
    local fileUtils = cc.FileUtils:getInstance()
    local tempPath = fileUtils:getWritablePath() .. filename
    print("LocalData:readFileData:", tempPath)
    defaultRet = clone(defaultRet) or {}
    if io.exists(tempPath) then
        local content = io.readfile(tempPath)

        local function checkContent(aData)
            -- 简单判断数据是否为json字符串
            local ret = string.trim(aData or "")
            local tempLen = string.len(ret)
            if tempLen < 2 then
                return
            end
            local firstChar, endChar = string.sub(ret, 1, 1), string.sub(ret, -1)
            if firstChar ~= "{" and firstChar ~= "[" or endChar ~= "}" and endChar ~= "]" then
                return
            end

            return ret
        end
        local data = checkContent(content)
        if not data then
            -- 兼容加密存储的版本
            content = self.mEncodeClass:DecryptDataWithBase64(content)
            data = checkContent(content)
            if not data then
                return defaultRet
            end
        end
        if not json then
            require "cocos.cocos2d.json"
        end

        return json.decode(data) or defaultRet
    end
    return defaultRet
end

-- 保存内存中的数据到文件中
function LocalData:saveDataToFile(filename, data)
    data = data or {}
    local fileUtils = cc.FileUtils:getInstance()
    local tempPath = fileUtils:getWritablePath() .. filename

    if not json then
        require "cocos.cocos2d.json"
    end

    -- 存储文件改为明文存储，这里不存在信息安全大问题。
    local content = json.encode(data)
    io.writefile(tempPath, content)
end

--- ============================= 玩家登录信息相关接口 ========================

-- 保存用户登录信息
function LocalData:saveLoginAccount(loginInfo)
    -- 如果 self.mLoginData为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mLoginData then
        self.mLoginData = self:readFileData(loginDataFile)
    end

    self.mLoginData.AccountInfo = self.mLoginData.AccountInfo or {}
    self.mLoginData.AccountInfo.account = loginInfo.account
    self.mLoginData.AccountInfo.verify = loginInfo.verify

    self:saveDataToFile(loginDataFile, self.mLoginData)
end

function LocalData:getLoginAccount()
    -- 如果 self.mLoginData为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mLoginData then
        self.mLoginData = self:readFileData(loginDataFile)
    end

    return self.mLoginData.AccountInfo
end

--- ============================= 版本号相关接口  ===========================
-- 保存游戏版本号相关信息到本地文件
--[[
-- 参数 versionInfo
    {
        clientVersion: 客户端版本号
        gameVersion: 游戏与服务器通信版本号
    }
 ]]
function LocalData:saveVersion(versionInfo)
    -- 如果 self.mVersionData 为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mVersionData then
        self.mVersionData = self:readFileData(versionDataFile)
    end

    for key, value in pairs(versionInfo or {}) do
        self.mVersionData[key] = value
    end
    self:saveDataToFile(versionDataFile, self.mVersionData)
end

-- 获取资源版本
function LocalData:getResourceName()
    if not self.mResourceName then
        -- 加载资源版本号
        local MANIFEST_FILE = "project.manifest"
        local STORAGE_PATH = cc.FileUtils:getInstance():getWritablePath() .. "Download/"
        local am_ = require("login.AssetsMgr").new{
            manifest = MANIFEST_FILE,
            storage  = STORAGE_PATH,
        }
        self.mResourceName = am_:getLocalManifest():getVersion()
        am_:release()
    end

    return self.mResourceName or ""
end

-- 获取游戏客户端版本号
function LocalData:getClientVersion()
    -- 如果 self.mVersionData 为 nil 表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mVersionData then
        self.mVersionData = self:readFileData(versionDataFile)
    end

    return self.mVersionData.clientVersion or ""
end

-- 获取保存在文件中的游戏到版本号，用于和当前版本比较，如果不相同，则需要删除原来的更新文件。
function LocalData:getGameVersion()
    -- 如果 self.mVersionData 为 nil 表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mVersionData then
        self.mVersionData = self:readFileData(versionDataFile)
    end

    return self.mVersionData.gameVersion or 0
end

--- ============================= 玩家设置信息相关接口 ==========================

-- 获取默认用户设置
local function getDefaultUserSetting()
    local default = {
        musicEnabled = true,    -- 是否打开背景音乐，默认为 true
        effectEnabled = true,   -- 是否打开音效，默认为 true
        pushEnabled = true,     -- 是否打开消息推送，默认为 true
        musicVolume = 80,       -- 背景音乐音量，默认为 80
        effectVolume = 80,      -- 音效音量，默认为 80
    }
    return default
end

-- 恢复系统设置为默认值
function LocalData:restoreSetting()
    -- 如果 self.mUserSetting为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mUserSetting then
        self.mUserSetting = self:readFileData(userSettingFile)
    end

    -- 把最新设置在游戏中表现出来
    MqAudio.resumeMusic()  -- 唤醒背景音乐音效
    MqAudio.setMusicVolume(0.8) -- 设置背景音乐音效音量大小
    -- 把最新设置存到文件
    self.mUserSetting.musicEnabled = true
    self.mUserSetting.effectEnabled = true
    self.mUserSetting.pushEnabled = true
    self.mUserSetting.musicVolume = 80
    self.mUserSetting.effectVolume = 80
    self:saveDataToFile(userSettingFile, self.mUserSetting)
end

-- 返回系统设置
--[[
-- 返回值：
    {
        musicEnabled = true,    -- 是否打开背景音乐，默认为 true
        effectEnabled = true,   -- 是否打开音效，默认为 true
        pushEnabled = true,     -- 是否打开消息推送，默认为 true
        musicVolume = 80,       -- 背景音乐音量，默认为 80
        effectVolume = 80,      -- 音效音量，默认为 80
    }
 ]]
function LocalData:getSetting()
    -- 如果 self.mUserSetting为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mUserSetting then

        self.mUserSetting = self:readFileData(userSettingFile, getDefaultUserSetting())
    end

    return self.mUserSetting
end

-- 获取用户设置的背景音乐是否打开
function LocalData:getMusicEnabled()
    -- 如果 self.mUserSetting为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mUserSetting then
        self.mUserSetting = self:readFileData(userSettingFile, getDefaultUserSetting())
    end

    return self.mUserSetting.musicEnabled
end

-- 系统设置背景音乐开关
function LocalData:setMusicEnabled(enable)
    -- 如果 self.mUserSetting为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mUserSetting then
        self.mUserSetting = self:readFileData(userSettingFile, getDefaultUserSetting())
    end
    self.mUserSetting.musicEnabled = enable
    self:saveDataToFile(userSettingFile, self.mUserSetting)

    if enable then
        MqAudio.resumeMusic()
    else
        MqAudio.pauseMusic()
    end
end

-- 获取用户设置的音效是否打开
function LocalData:getEffectEnabled()
    -- 如果 self.mUserSetting为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mUserSetting then
        self.mUserSetting = self:readFileData(userSettingFile, getDefaultUserSetting())
    end

    return self.mUserSetting.effectEnabled
end

-- 系统设置音效开关
function LocalData:setEffectEnabled(enable)
    -- 如果 self.mUserSetting为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mUserSetting then
        self.mUserSetting = self:readFileData(userSettingFile, getDefaultUserSetting())
    end
    self.mUserSetting.effectEnabled = enable
    self:saveDataToFile(userSettingFile, self.mUserSetting)
end

-- 获取用户设置的消息推送是否打开
function LocalData:getPushEnabled()
    -- 如果 self.mUserSetting为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mUserSetting then
        self.mUserSetting = self:readFileData(userSettingFile, getDefaultUserSetting())
    end

    return self.mUserSetting.pushEnabled
end

-- 系统设置消息推送开关
function LocalData:setPushEnabled(enable)
    -- 如果 self.mUserSetting为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mUserSetting then
        self.mUserSetting = self:readFileData(userSettingFile, getDefaultUserSetting())
    end
    self.mUserSetting.pushEnabled = enable
    self:saveDataToFile(userSettingFile, self.mUserSetting)
end

-- 获取用户设置的背景音乐音量
function LocalData:getMusicVolume()
    -- 如果 self.mUserSetting为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mUserSetting then
        self.mUserSetting = self:readFileData(userSettingFile, getDefaultUserSetting())
    end

    return self.mUserSetting.musicVolume
end

-- 系统设置背景音乐音量
function LocalData:setMusicVolume(volume)
    -- 如果 self.mUserSetting为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mUserSetting then
        self.mUserSetting = self:readFileData(userSettingFile, getDefaultUserSetting())
    end
    self.mUserSetting.musicVolume = volume
    self:saveDataToFile(userSettingFile, self.mUserSetting)
    --
    MqAudio.setMusicVolume(volume/100.0)
end

-- 获取用户设置的音效音量
function LocalData:getEffectVolume()
    -- 如果 self.mUserSetting为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mUserSetting then
        self.mUserSetting = self:readFileData(userSettingFile, getDefaultUserSetting())
    end

    return self.mUserSetting.effectVolume
end

-- 系统设置音效音量
function LocalData:setEffectVolume(volume)
    -- 如果 self.mUserSetting为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mUserSetting then
        self.mUserSetting = self:readFileData(userSettingFile, getDefaultUserSetting())
    end
    self.mUserSetting.effectVolume = volume
    self:saveDataToFile(userSettingFile, self.mUserSetting)
    --
    MqAudio.setEffectVolume(volume/100.0)
end

-- 使历史纪录文件中保存的用户设置生效
function LocalData:takeEffectUserSetting()
    -- 如果 self.mUserSetting为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mUserSetting then
        self.mUserSetting = self:readFileData(userSettingFile, getDefaultUserSetting())
    end

    self:setMusicVolume(self.mUserSetting.musicVolume or 80)
    self:setEffectVolume(self.mUserSetting.effectVolume or 80)
end

-- 保存游戏变量
function LocalData:saveGameDataValue(key, value)
    self.mUserSetting.gameData = self.mUserSetting.gameData or {}
    if type(key)=="string" then
        self.mUserSetting.gameData[key] = value
    else
        print("LocalData:saveLocalValue key must be string!!!")
    end
    -- 保存游戏数据
    self:saveDataToFile(userSettingFile, self.mUserSetting)
end

-- 获取游戏保存的变量(可能返回nil)
function LocalData:getGameDataValue(key)
    return self.mUserSetting.gameData and self.mUserSetting.gameData[key]
end

--- ================================ 充值订单日志 ===================================
function LocalData:saveRechargeLog(data)
    print("saveRechargeLog beg")
    if not self.mRechargeLog then
        self.mRechargeLog = {}
    end
    table.insert(self.mRechargeLog, data)
    self:saveDataToFile(rechargeFile, self.mRechargeLog)
    print("saveRechargeLog end = ", table.maxn(self.mRechargeLog))
end

function LocalData:clearRechargeLog(orderId)
    if self.mRechargeLog then
        print("clearRechargeLog beg = ", orderId)
        local index = 0
        for i = 1, table.maxn(self.mRechargeLog) do
            local v = self.mRechargeLog[i]
            if v.OrderID == orderId then
                index = i
                break
            end
        end
        if index > 0 then
            table.remove(self.mRechargeLog, index)
            --dump(self.mRechargeLog)
        end
        self:saveDataToFile(rechargeFile, self.mRechargeLog)
        print("clearRechargeLog end =", table.maxn(self.mRechargeLog))
    end
end

function LocalData:readRechargeLog()
    print("readRechargeLog")
    self.mRechargeLog = self:readFileData(rechargeFile)
    print("rechargeLog count = ", table.maxn(self.mRechargeLog))
    return self.mRechargeLog
end


--- =============================== 记录新限时活动 相关信息 ===========================
function LocalData:saveNewTimedActivity(data)
    local saveData = {}
    saveData.timeTick = data.timeTick
    saveData.timedActivity = {}
    for key, value in pairs(data and data.timedActivity or {}) do
        saveData.timedActivity[tostring(key)] = value
    end
    saveData.newTimedActivity = {}
    for key, value in pairs(data and data.newTimedActivity or {}) do
        saveData.newTimedActivity[tostring(key)] = value
    end

    self:saveDataToFile(newTimedActivityFile, saveData)
end

function LocalData:getNewTimedActivity()
    local tempData = self:readFileData(newTimedActivityFile)
    local ret = {}
    ret.timeTick = tempData.timeTick
    ret.timedActivity = {}
    for key, value in pairs(tempData and tempData.timedActivity or {}) do
        ret.timedActivity[tonumber(key)] = value
    end
    ret.newTimedActivity = {}
    for key, value in pairs(tempData and tempData.newTimedActivity or {}) do
        ret.newTimedActivity[tonumber(key)] = value
    end

    return ret
end

--- =============================== 黑名单相关信息 ===================================

--[[
]]
function LocalData:saveEnemyData(data)
    self.mEnemyData = data or {}
    self:saveDataToFile(enemyDataFile, self.mEnemyData)
end

--[[
]]
function LocalData:getEnemyData()
    -- 如果 self.mEnemyData 为 nil 表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mEnemyData then
        self.mEnemyData = self:readFileData(enemyDataFile)
    end

    return self.mEnemyData
end

--- =============================== 上线提醒相关信息 ===================================

--[[
]]
function LocalData:saveOnlineNotifyData(data)
    self.mOnlineNotifyData = data or {}
    self:saveDataToFile(onlineNotifyFile, self.mOnlineNotifyData)
end

--[[
]]
function LocalData:getOnlineNotifyData()
    -- 如果 self.mEnemyData 为 nil 表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mOnlineNotifyData then
        self.mOnlineNotifyData = self:readFileData(onlineNotifyFile)
    end

    return self.mOnlineNotifyData
end

--- =============================== 记录玩家聊天相关信息 =============================
--[[
-- 玩家聊天基本信息的结构为：
    {
        [playerId] = {
            [ChatChanne] = {
                readMaxId = 0, -- 上一次拉去服务器数据的消息Id
            },
            [Enums.ChatChanne.ePrivate] = {
                [fromPlayerId] = {
                    readMaxId = 0, -- 上一次拉去服务器数据的消息Id
                    ....
                }
            }
            ....
        }
    }
]]
function LocalData:saveReadMaxInfo(playerId, data)
    -- 如果 self.mChatBaseData 为nil表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mChatBaseData then
        self.mChatBaseData = self:readFileData(chatBaseDataFile)
    end

    local tempData = {}
    for key, value in pairs(data or {}) do
        tempData[tostring(key)] = value
    end
    self.mChatBaseData[playerId] = tempData
    self:saveDataToFile(chatBaseDataFile, self.mChatBaseData)
end

--
function LocalData:getReadMaxInfo(playerId)
    -- 如果 self.mChatBaseData 为 nil 表示还没有从文件中读取过数据，需要从文件中读取原始数据
    if not self.mChatBaseData then
        self.mChatBaseData = self:readFileData(chatBaseDataFile)
    end

    local tempData = self.mChatBaseData[playerId]
    if not tempData then
        return 
    end
    local ret = {}
    for key, value in pairs(tempData) do
        ret[tonumber(key)] = value
    end

    return ret
end

--- ================================ 不需要保存到文件中的信息 =========================

--设置和读取预加载状态
function LocalData:setPreLoadStatus(status)
    self.mIsPreLoad = status
end

function LocalData:getPreLoadStatus()
    return self.mIsPreLoad or false
end

function LocalData:isAutoLogin()
    return self.mAutoLogin
end

function LocalData:setAutoLogined()
    self.mAutoLogin = false
end

-- 初始化历史数据
LocalData:initLocalData()
