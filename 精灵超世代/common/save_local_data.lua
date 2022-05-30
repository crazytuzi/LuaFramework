-- Created by IntelliJ IDEA.
-- User: lfl 1204825992@qq.com
-- Date: 2014/7/25
-- Time: 13:49
-- 文件功能：用来保存本地数据的一个工具类

SaveLocalData = SaveLocalData or BaseClass()

--以后保存数据的可以，请亲们尽量在这个地方写，以后查找比较方便
SaveLocalData.key_value =
{
    last_login_accounts = "last_login_accounts",                     -- 保存上一次登录的账号
    last_login_ip = "last_login_ip",                                 -- 保存上次登录的ip
    is_auto = "is_auto",                                             -- 保存上次登录的ip
    chat_greeting = "chat_greeting",                                 -- 聊天常用问候语

    usrName = "usrName",                                             -- 最近登录的玩家账户名
    usrNameList = "usrNameList",                                     -- 最近登录的玩家账户名
    password = "password",                                           -- 最近登录的玩家密码
    srv_id = "srv_id",                                               -- 最近上的服务器ID
    rid = "rid",                                                     -- 最近上的服务器ID
   
    isTourist = "isTourist", -- 是否为游客身份
   
    gm_cmd = "gm_cmd",   -- gm命令排序规则
    gm_eidt_list = "gm_eidt_list",   -- 命名记录

    loginMode = "loginMode",-- 登录模式

    stupid = "stupid",   --新手引导步骤
    voice = "voice", --语音翻译

    photo_id = "photo_id",     --系统设置的数据部分
    achieve_list = "achieve_list",  --成就的列表
    notice_version = "notice_version", --公告通知版本
    lead_mission = "lead_mission", --所有引导任务

    setting = "setting",     --系统设置的数据部分
    refuse_add_friend = "refuse_add_friend",
    need_check_friend = "need_check_friend",
    is_normal_smooth = "is_normal_smooth",
    refuse_stranger_chat = "refuse_stranger_chat",
    hide_other_player = "hide_other_player",
    is_auto_team_voice = "is_auto_team_voice",
    is_auto_guild_voice = "is_auto_guild_voice",
    is_auto_world_voice = "is_auto_world_voice",
    is_auto_cross_voice = "is_auto_cross_voice",
    is_show_scene_effect = "is_show_scene_effect",
    audio_volume = "audio_volume",
    voice_volume = "voice_volume",
    music_volume = "music_volume",
    is_team_channel = "is_team_channel",
    is_now_channel = "is_now_channel",
    is_world_channel = "is_world_channel",
    is_guild_channel = "is_guild_channel",
}

function SaveLocalData:getInstance()
    if not self.is_init then 
        self.user_default = cc.UserDefault:getInstance()
        self.is_init = true
    end
    return self
end

--外部调用的接口
function SaveLocalData:writeLuaData(key, tab_value)
    if key == nil then
        return
    end
    local Type = type(tab_value)
    --防止电脑端同时写操作读取不到userdefault.xml
    delayRun(ViewManager:getInstance():getLayerByTag( ViewMgrTag.MSG_TAG ), math.random(1,100)/100, function()     
        if Type == "table" then
            local str = self:writeLuaTable(tab_value, 0)
            self.user_default:setStringForKey(key, str)
            self.user_default:flush()
        elseif Type == "string" then
            self.user_default:setStringForKey(key, tab_value)
            self.user_default:flush()
        elseif Type == "number" then
            self.user_default:setFloatForKey(key, tab_value)
            self.user_default:flush()
        elseif Type == "boolean" then
            self.user_default:setBoolForKey(key, tab_value)
            self.user_default:flush()
        end
    end)
end

--内部使用的接口
--把table写成字符串的格式
function SaveLocalData:writeLuaTable(lua_table, indent)
    indent = indent or 0
    local final_str = ""
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        TypeV = type(v)
        if TypeV == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep(" ", indent)
        formatting = szPrefix.."["..k.."]".." = "..szSuffix
        if TypeV == "table" then
            final_str = final_str .. formatting .. "\n"
            final_str = final_str .. SaveLocalData:writeLuaTable(v, indent + 1)
            final_str = final_str .. szPrefix .. "},\n"
        else
            local szValue = ""
            if TypeV == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
           final_str = final_str  .. formatting .. szValue .. ",\n"
        end
    end
    return final_str
end

--按照格式读取存入的数据
function SaveLocalData:readStringForKey(key)
    if key == nil then
        return
    end
   return self.user_default:getStringForKey(key)
end

function SaveLocalData:readNumberForKey(key)
    if key == nil then
        return
    end
    return self.user_default:getFloatForKey(key)
end

function SaveLocalData:readBooleanForKey(key)
    if key == nil then
        return
    end
    return self.user_default:getBoolForKey(key)
end

--按照格式读取存入table的数据
function SaveLocalData:readTableForKey(key)
    if key == nil then
        return
    end
    local tab = self:readStringForKey(key)
    if tab == "" or #tab == 0 then
        return {}
    else
        local t = loadstring("return {"..tab.."}")
        if t == nil then
            return {}
        else
            return t()
        end
    end
end

--根据一级和二级菜单读取制定值
function SaveLocalData:readNumber(key, sub_key)
    local key_list = self:readTableForKey(key)
    if key_list == nil or next(key_list) == nil then 
        return 0
    end

    for k,v in pairs(key_list) do
        if k == sub_key then
            return v
        end
    end
    return 0
end

------------------------------------------------
--具体的功能实现，可以写在这个地方，好让以后写代码的做参考
SaveLocalData.vision = "format.1.0"
--写入站位数据
function SaveLocalData:write_hero_stand_table (lua_table, indent)
    indent = indent or 0
    local temp_str = ""
    if indent == 0 then
        temp_str = temp_str .. "Hero_Format_data = Hero_Format_data or {} \n"
        temp_str = temp_str .. "Hero_Format_data.version = " .. string.format("%q",SaveLocalData.vision) .. "\n"
        temp_str = temp_str .. "Hero_Format_data.data_list = { " .. "\n"
        -- local player = GameData:getInstance():getHero()
        local id = player.srv_id .. "_" .. player.rid
        temp_str = temp_str .. "[" .. string.format("%q", id) .. "] = { \n"
    end
    temp_str = temp_str .. self:writeLuaTable(lua_table)
    if indent == 0 then
        temp_str = temp_str .. "\n" .. "}"
        temp_str = temp_str .. "\n" .. "}"
    end
    self.user_default:setStringForKey(SaveLocalData.key_value.hero_stand_data,temp_str)
    self.user_default:flush()
end

--读出站位数据
function SaveLocalData:read_hero_stand_table()
    local temp = self:readTableForKey(SaveLocalData.key_value.hero_stand_data)
    if type(temp) == "table" and #temp == 0 then
        -- print("----------------")
        return {}
    end
    if Hero_Format_data.version ~= SaveLocalData.vision then
        return {}
    end
    -- print("========================")
    if Hero_Format_data ~= nil and Hero_Format_data.data_list ~= nil then
        -- local player = GameData:getInstance():getHero()
        local id = player.srv_id .. "_" .. player.rid
        if Hero_Format_data.data_list[id] ~= nil then
            local temp_tab = Hero_Format_data.data_list[id]
            return deepCopy(temp_tab)
        else
            return {}
        end
    end
end