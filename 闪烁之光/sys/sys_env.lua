-- --------------------------------------------------+
-- 环境变量
-- @author whjing2011@gmail.com
-- --------------------------------------------------*/

SysEnv = SysEnv or BaseClass()
local filepath = cc.FileUtils:getInstance():getWritablePath() .. "sys_env_data.lua"
-- 需要保存的键值数据
-- SysEnv:getInstance():set(SysEnv.keys.rid, 1)
-- SysEnv:getInstance():get(SysEnv.keys.rid)
SysEnv.keys = {
    music_volume       = "music_volume",          -- 背景音乐
    music_is_open      = "music_is_open",         -- 音乐开关
    audio_volume       = "audio_volume",          -- 音效
    audio_is_open      = "audio_is_open",         -- 音效开关
    voice_volume       = "voice_volume",          -- 语音
    voice_is_open      = "voice_is_open",         -- 语音开关
    chat_red_open      = "chat_red_open",         -- 聊天红点显示
    mission_trace      = "mission_trace",         -- 任务追踪开关
    usrName            = "usrName",               -- 记录登陆的账号
    password           = "password",              -- 记录登陆的密码
    usrNameList        = "usrNameList",           -- 最近登陆的10条账号数据
    srv_id             = "srv_id",                -- 最近登陆的角色服务器id
    rid                = "rid",                   -- 最近登陆的角色id
    cache_chat         = "cache_chat",            -- 缓存的聊天数据
    chat_greeting      = "chat_greeting",         -- 聊天常用语
    gm_eidt_list       = "gm_eidt_list",          -- GM命令
    frist_open_game    = "frist_open_game",       -- 首次启动游戏
    scene_quality      = "scene_quality",         -- 游戏品质
    message_push       = "message_push",          -- 是否开启消息推送

    auto_guild_voice   = "auto_guild_voice",      -- 自动播放联盟语音
    auto_world_voice   = "auto_world_voice",      -- 自动播放世界语音
    auto_cross_voice   = "auto_cross_voice",       -- 预留的自动播放跨服语音

    loading_png        = "loading_png_form",       -- 加载loading的资源
    resources_down_key = "resources_down_key",
    spine_down_key = "spine_down_key",

    high_quality = "high_quality",                 -- 高品质
    adventure_skip_fight = "adventure_skip_fight",  -- 冒险模式是否跳过战斗
    adventure_series_fight = "adventure_series_fight",  -- 冒险模式是否连续挑战
    adventure_mine_skip_fight = "adventure_mine_skip_fight",  -- 秘矿冒险是否跳过战斗
    arenateam_skip_fight = "arenateam_skip_fight",  -- 组队竞技场跳过战斗
    welfare_redpoint = "welfare_redpoint",          --福利的贴吧红点
    grow_fund_redpoint = "grow_fund_redpoint",          --福利的成长基金红点

    holy_sell_star_1 = "holy_sell_star_1",          -- 一键出售神装筛选 1星
    holy_sell_star_2 = "holy_sell_star_2",          -- 一键出售神装筛选 2星
    holy_sell_star_3 = "holy_sell_star_3",          -- 一键出售神装筛选 3星
    holy_sell_star_4 = "holy_sell_star_4",          -- 一键出售神装筛选 4星
    holy_sell_star_5 = "holy_sell_star_5",          -- 一键出售神装筛选 5星
    holy_sell_step_1 = "holy_sell_step_1",          -- 一键出售神装筛选 凡品
    holy_sell_step_2 = "holy_sell_step_2",          -- 一键出售神装筛选 良品
    holy_sell_step_3 = "holy_sell_step_3",          -- 一键出售神装筛选 极品

    equip_sell_all = "equip_sell_all",              -- 一键出售装备筛选 全选
    equip_sell_star_1 = "equip_sell_star_1",        -- 一键出售装备筛选 1星
    equip_sell_star_2 = "equip_sell_star_2",        -- 一键出售装备筛选 2星
    equip_sell_star_3 = "equip_sell_star_3",        -- 一键出售装备筛选 3星
    equip_sell_star_4 = "equip_sell_star_4",        -- 一键出售装备筛选 4星
    equip_sell_star_5 = "equip_sell_star_5",        -- 一键出售装备筛选 5星
    equip_sell_star_6 = "equip_sell_star_6",        -- 一键出售装备筛选 6星
    equip_sell_quality_1 = "equip_sell_quality_1",      -- 一键出售装备筛选 绿色
    equip_sell_quality_2 = "equip_sell_quality_2",      -- 一键出售装备筛选 蓝色
    equip_sell_quality_3 = "equip_sell_quality_3",      -- 一键出售装备筛选 紫色
    equip_sell_quality_4 = "equip_sell_quality_4",      -- 一键出售装备筛选 橙色
    equip_sell_quality_5 = "equip_sell_quality_5",      -- 一键出售装备筛选 红色

    holy_plan_wear_tip = "holy_plan_wear_tip",                 -- 神装方案穿戴当日不再提示
    holy_plan_save_tip = "holy_plan_save_tip",                 -- 神装方案保存当日不再提示
    elfin_plan_save_tip = "elfin_plan_save_tip",                 -- 精灵方案保存当日不再提示

    video_first_open = "video_first_open",                      -- 今日是否为首次录像馆

    login_srv_sign = "login_srv_sign",                          -- 登陆时后端发过来的sign标识
    forge_artifact_num = "forge_artifact_num",                  -- 符文合成一键添加的数量
    elfin_auto_buy_item = "elfin_auto_buy_item",                -- 精灵砸蛋自动购买锤子

    user_proto_agree = "user_proto_agree",  -- 同意用户协议
    user_proto_name_list = "user_proto_name_list",  -- 同意用户协议账号列表

    default_server_data = "default_server_data",        -- 默认注册服
    guild_first_open = "guild_first_open",        -- 今日是否为首次公会

    custom_head_info = "custom_head_info"  -- 自定义头像,本地写入了每个自定义头像的更新时间
}

-- 本地缓存文件
-- SysEnv:getInstance():savefile(SysEnv.files.test, {test1="data"})
-- local data = SysEnv:getInstance():loadfile(SysEnv.files.test)
SysEnv.files = {
}

function SysEnv:getInstance()
    if not self.is_init then 
        self:load()
        self.is_init = true
    end
    return self
end

-- 根据键取值
function SysEnv:get(key, def)
    if key == nil then return def end
    if self[key]~=nil then
        return self[key]
    else
        return def
    end
    --return self[key] or def
end

-- 获取整型
function SysEnv:getNum(key, def)
    return self:get(key, def or 0)
end

-- 获取字符串
function SysEnv:getStr(key, def)
    return self:get(key, def or '')
end

-- 获取table
function SysEnv:getTable(key, def)
    return self:get(key, def or {})
end

-- 获取布尔型
function SysEnv:getBool(key, def)
    return self:get(key, def or false)
end

-- 设置值
function SysEnv:set(key, val, save)
    if key == nil then return end
    if type(val)~="table" and self[key] and self[key] == val then return end
    self[key] = val
    self:updateEventKey(key, val)
    if save == false then return end -- 默认nil为保存
    self:save()

end

function SysEnv:updateEventKey(key, val)
    if key == SysEnv.keys.music_volume then
        AudioManager:getInstance():setMusicVolume(val/100)
    elseif key == SysEnv.keys.audio_volume then
        AudioManager:getInstance():setEffectVolume(val/100)
    elseif key == SysEnv.keys.voice_volume then
        AudioManager:getInstance():setRecordVolume(val/100)
    elseif key == SysEnv.keys.music_is_open then
        if val == false then
            AudioManager:getInstance():setMusicVolume(0)
        elseif val == true then
            AudioManager:getInstance():setMusicVolume(SysEnv:getInstance():getNum(SysEnv.keys.music_volume, 100)/100)
        end
    elseif key == SysEnv.keys.audio_is_open then
        if val == false then
            AudioManager:getInstance():setEffectVolume(0)
        elseif val == true then
            AudioManager:getInstance():setEffectVolume(SysEnv:getInstance():getNum(SysEnv.keys.audio_volume, 100)/100)
        end
    elseif key == SysEnv.keys.voice_is_open then
        if val == false then
            AudioManager:getInstance():setRecordVolume(0)
        elseif val == true then
            AudioManager:getInstance():setRecordVolume(SysEnv:getInstance():getNum(SysEnv.keys.voice_volume, 100)/100)
        end
    elseif key == SysEnv.keys.scene_quality then

    elseif key == SysEnv.keys.message_push then
    
    elseif key == SysEnv.keys.mission_trace then

    elseif key == SysEnv.keys.high_quality then
        if val == false then
            EQUIPMENT_QUALITY = 1
        elseif val == true then
            EQUIPMENT_QUALITY = 3
        end
    end
end

-- 获取所有key
function SysEnv:getKeys()
    return SysEnv.keys
end

-- 获取文件名
function SysEnv:filepath()
    return filepath
end

-- 加载数据
function SysEnv:load()
    local filepath = self:filepath()
    if not filepath then return end
    local ret = self:loadfile(filepath)
    for k, v in pairs(ret or {}) do
        self[k] = v
    end
end

-- 设置并保存值
function SysEnv:save()
    local filepath = self:filepath()
    if not filepath then return end
    local str = "return {"
    local vtype
    local keys = self:getKeys()
    for _,k in pairs(keys) do
        v = self[k]
        if v ~= nil then
            vtype = type(v)
            if vtype == "string" then
                v = "[["..v.."]]"
            elseif vtype == "table" then
                v = self:luaTable2Str(v, 1)
            else
                v = tostring(v)
            end
            str = str.."\n  "..k.."="..v..","
        end
    end
    str = str.."\n}"
    return writeBinaryFile(filepath, str)
end

-- 加载文件
function SysEnv:loadfile(filepath) 
    if cc.FileUtils:getInstance():isFileExist(filepath) then
        print("load_file===>", filepath)
        local ok, ret = pcall(function() return dofile(filepath) end)
        if ok and type(ret) == "table" then 
            return ret
        end
    end
    return {}
end

--是否存在保存文件
function SysEnv:isFileExist() 
    local filepath = self:filepath()
    if filepath and cc.FileUtils:getInstance():isFileExist(filepath) then
        return true
    end
    return false
end

-- 保存文件
function SysEnv:savefile(filepath, data)
    local str = "return "..self:luaTable2Str(data, 0)
    print("save_file===>", filepath)
    return writeBinaryFile(filepath, str)
end

function SysEnv:savefileOutKey(filepath, data)
    local str = "return "..self:otherLuaTable2Str(data, 0)
    print("save_file===>", filepath)
    return writeBinaryFile(filepath, str)
end

function SysEnv:otherLuaTable2Str(lua_table, indent)
	indent = indent or 0
	local str = "{\n"
	local szPrefix = string.rep("  ", indent)
	for k, v in pairs(lua_table) do
		if type(k) == "string" then
			k = string.format("%q", k)
		end
		TypeV = type(v)
		if TypeV == "table" then
			v = self:luaTable2Str(v, indent + 1)
		elseif TypeV == "string" then
			v = string.format("%q", v)
		else
			v = tostring(v)
		end
		str = str .. szPrefix .. "  " .. v .. ",\n"
	end
	return str .. szPrefix .. "}"
end 

function SysEnv:luaTable2Str(lua_table, indent)
    indent = indent or 0
    local str = "{\n"
    local szPrefix = string.rep("  ", indent)
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        TypeV = type(v)
        if TypeV == "table" then
            v = self:luaTable2Str(v, indent + 1)
        elseif TypeV == "string" then
            v = string.format("%q", v)
        else
            v = tostring(v)
        end
        str = str .. szPrefix.."  ["..k.."] = " .. v .. ",\n"
    end
    return str..szPrefix.."}"
end

local rank_list = {}
local form_list = {}
local big_world_list = {}
--==============================--
--desc:加载本服排行榜本地缓存数据,
--time:2017-08-24 08:01:59
--@type:排行榜类型
--@return 
--==============================--
function SysEnv:loadRankFile(type, is_cluster)
    local cluster = 0
    if is_cluster == true then
        cluster = 1
    end
    if rank_list[getNorKey(type, cluster)] ~= nil then
        return rank_list[getNorKey(type, cluster)]
    end
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "rank_env/"..cluster.."/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid,roleVo.main_srv_id)
    filepath = filepath .. str .."/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "rank_data_" .. type .. ".lua"
    rank_list[type] = self:loadfile(filepath)

    return rank_list[type]
end

--==============================--
--desc:储存新手加载资源
--time:2018-12-22 02:14:45
--@key:
--@data:
--@return 
--==============================--
function SysEnv:saveResourcesFile(data)
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "resources_env/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "resources_data.lua"
    self:savefileOutKey(filepath, data)
end

function SysEnv:loadResourcesFile()
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "resources_env/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "resources_data.lua"
	local tamp_data = self:loadfile(filepath)
	return tamp_data
end 

--==============================--
--desc:储存排行榜数据
--time:2017-08-24 08:12:18
--@type:
--@data:
--@return 
--==============================--
function SysEnv:saveRankFile(type, timestamp, data, is_cluster)
    local cluster = 0
    if is_cluster == true then
        cluster = 1
    end
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "rank_env/".. cluster .. "/" 
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid,roleVo.main_srv_id)
    filepath = filepath .. str .."/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "rank_data_" .. type .. ".lua"
    local save_data = {timestamp = timestamp, data = data}
    self:savefile(filepath, save_data)
    -- 缓存一下
    rank_list[type] = save_data
end


function SysEnv:saveFormFile(type,data)
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "form_env/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid,roleVo.main_srv_id)
    filepath = filepath .. str .."/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "form_data_" .. type .. ".lua"
    local save_data = {type = type,data = data}
    self:savefile(filepath, save_data)
    -- 缓存一下
    form_list[type] = save_data
end

function SysEnv:loadFormFile(type)
    if form_list[type] ~= nil then
        return form_list[type]
    end
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "form_env/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid,roleVo.main_srv_id)
    filepath = filepath .. str .."/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "form_data_" .. type .. ".lua"
    form_list[type] = self:loadfile(filepath)

    return form_list[type]
end

--==============================--
--desc:保存大世界出征队伍缓存
--time:2017-11-14 02:05:23
--@type:
--@data:
--@return 
--==============================--
function SysEnv:saveBigWorldFormFile(data)
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "form_env/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid,roleVo.main_srv_id)
    filepath = filepath .. str .."/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "big_world_data.lua"
    local save_data = data
    self:savefile(filepath, save_data)
    -- 缓存一下
    big_world_list = save_data
end

function SysEnv:loadBigWorldFormFile()
    if big_world_list ~= nil and next(big_world_list) ~= nil then
        return big_world_list
    end
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "form_env/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid,roleVo.main_srv_id)
    filepath = filepath .. str .."/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "big_world_data.lua"
    big_world_list = self:loadfile(filepath)
    return big_world_list
end

--读取私聊数据
--==============================--
function SysEnv:loadPrivateChatFile(role_srv_id,role_id)
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "chat_env/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid,roleVo.srv_id)
    filepath = filepath .. str .."/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "chat_"..roleVo.srv_id.."_"..roleVo.rid.."_"..role_srv_id.."_"..role_id .. ".lua"
    local chat_data = self:loadfile(filepath) or {}

    return chat_data.talk_list
end

--==============================--
--desc:保存私聊数据
--==============================--
function SysEnv:savePrivateChatFile(role_srv_id,role_id, data)
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "chat_env/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid,roleVo.srv_id)
    filepath = filepath .. str .."/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "chat_"..roleVo.srv_id.."_"..roleVo.rid.."_"..role_srv_id.."_"..role_id .. ".lua"
    local save_data = {talk_list = data}
    self:savefile(filepath, save_data)
end

--保存一下最近联系人的数据
function SysEnv:saveContactListFile( data )
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "private_chat_env/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid,roleVo.srv_id)
    filepath = filepath .. str .."/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "private_chat_"..roleVo.srv_id.."_"..roleVo.rid..".lua"
    local save_data = {contact_list = data}
    self:savefile(filepath, save_data)
end

--读取最近联系人数据
function SysEnv:loadContactListFile()
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "private_chat_env/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid,roleVo.srv_id)
    filepath = filepath .. str .."/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "private_chat_"..roleVo.srv_id.."_"..roleVo.rid..".lua"
    local chat_data = self:loadfile(filepath) or {}
    return chat_data.contact_list
end


function SysEnv:saveDramaTipsFile(data)
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "drama_tips_env/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid, roleVo.srv_id)
    filepath = filepath .. str .. "/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "drama_tips_" .. roleVo.srv_id .. "_" .. roleVo.rid .. ".lua"
    local list = {}
    if not list[data.dun_id] then
        list[data.dun_id] = {dun_id = data.dun_id}
    end
    local save_data = list
    self:savefile(filepath, save_data)
end

function SysEnv:loadDramaTipsFile()
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "drama_tips_env/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid, roleVo.srv_id)
    filepath = filepath .. str .. "/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "drama_tips_" .. roleVo.srv_id .. "_" .. roleVo.rid .. ".lua"
    local drama_data = self:loadfile(filepath) or {}
    return drama_data
end

-- 本地保存神器重铸技能锁定状态
function SysEnv:saveArtifactLockStatus( data )
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "artifact_lock_env/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid,roleVo.srv_id)
    filepath = filepath .. str .."/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "artifact_lock_"..roleVo.srv_id.."_"..roleVo.rid..".lua"
    local save_data = {lock_status = data}
    self:savefile(filepath, save_data)
end
function SysEnv:loadArtifactLockStatus(  )
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "artifact_lock_env/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid,roleVo.srv_id)
    filepath = filepath .. str .."/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "artifact_lock_"..roleVo.srv_id.."_"..roleVo.rid..".lua"
    local lock_data = self:loadfile(filepath) or {}
    return lock_data.lock_status
end

-- 本地保存公会活跃图标资源id
function SysEnv:saveGuildActiveIconId( id )
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "guild_active_env/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid,roleVo.srv_id)
    filepath = filepath .. str .."/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "guild_active_"..roleVo.srv_id.."_"..roleVo.rid..".lua"
    local save_data = {active_icon_id = id}
    self:savefile(filepath, save_data)
end
function SysEnv:loadGuildActiveIconId(  )
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "guild_active_env/"
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    local str = getNorKey(roleVo.rid,roleVo.srv_id)
    filepath = filepath .. str .."/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "guild_active_"..roleVo.srv_id.."_"..roleVo.rid..".lua"
    local active_data = self:loadfile(filepath) or {}
    if not active_data.active_icon_id then -- 如果玩家没设置过公会活跃光环，则默认选择当前活跃等级对应的光环
        local active_lev = GuildController:getInstance():getModel():getGuildActiveLev()
        local active_cfg = Config.GuildQuestData.data_lev_data[active_lev]
        if active_cfg then
            active_data.active_icon_id = active_cfg.res_id
        end
    end
    return active_data.active_icon_id or 1
end

-- 本地保存服务器列表数据
function SysEnv:saveAllServerListFile(  )
    local srv_data = LoginController:getInstance():getModel():getServerListData()
    if not srv_data then return end

    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "server_list_env/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "server_list_data.lua"
    local save_data = srv_data
    self:savefile(filepath, save_data)
end

function SysEnv:loadAllServerListFile(  )
    local filepath = cc.FileUtils:getInstance():getWritablePath() .. "server_list_env/"
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    filepath = filepath .. "server_list_data.lua"
    local srv_data = self:loadfile(filepath) or {}
    return srv_data
end