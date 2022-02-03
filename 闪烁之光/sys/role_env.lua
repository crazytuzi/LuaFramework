-- --------------------------------------------------+
-- 环境变量
-- @author whjing2011@gmail.com
-- --------------------------------------------------*/

RoleEnv = RoleEnv or BaseClass(SysEnv)
local filepath = cc.FileUtils:getInstance():getWritablePath().."role_env/"

-- 需要保存的键值数据
-- RoleEnv:getInstance():set(RoleEnv.keys.rid, 1)
-- RoleEnv:getInstance():get(RoleEnv.keys.rid)
RoleEnv.keys = {
    guide_step_list = "guide_step_list",                -- 保存引导需要的
    guide_over_step = "over",                           -- 引导是否完成
    godbattle_form = "godbattle_form",                  -- 众神之战本地缓存
    guild_war_form = "guild_war_form",                  -- 联盟战布阵缓存
    chief_war_show_form = "chief_war_show_form",        -- 首席争霸是否自动弹出布阵界面
    item_source_key = "item_source_key",                -- 物品扫荡类型
    barrage_type_key = "barrage_type_key",              -- 弹幕的类型
	undertown_dun_type = "undertown_dun_type",          -- 地下城难度的类型
    bigworld_personal_log = "bigworld_personal_log",    -- 大世界个人日志事件
    assistant_key = "assistant_key",                    -- 是否出现过小助手
    artifact_count_tips = "artifact_count_tips",        -- 符文数量提示
}

function RoleEnv:getInstance()
    if not self.is_init then 
        self.is_init = true
    end
    return self
end

function RoleEnv:updateEventKey(key, val)
end

-- 获取所有key
function RoleEnv:getKeys()
    return RoleEnv.keys
end

-- 获取文件名
function RoleEnv:filepath()
    local roleVo = RoleController:getInstance():getRoleVo()
    if roleVo == nil then return end
    if not cc.FileUtils:getInstance():isDirectoryExist(filepath) then
        cc.FileUtils:getInstance():createDirectory(filepath)
    end
    -- return string.format("%srole_env_%s_%d.lua", filepath, roleVo.srv_id, roleVo.rid)
    return string.format("%srole_env_%d_%s_%d.lua", filepath, roleVo.reg_time, roleVo.srv_id, roleVo.rid)
end
