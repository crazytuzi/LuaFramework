-- 窗口缓存类型
CacheMode = {
    Visible = 1,	-- 关闭隐藏
	Destroy = 2	-- 关闭立即销毁
}

-- 资源类型
AssetType = {
    Main = 1
    ,Dep = 2
}

-- AXIS
BoxLayoutAxis = {
    X = 1
    ,Y = 2
}

-- Dir
BoxLayoutDir = {
    Left = 1
    ,Right = 2
    ,Top = 3
    ,Down = 4
}

-- 资源来源
AssetFrom = {
    Loader = 1
    ,Cache = 2
}

-- View类型
ViewType = {
    BaseView = 0
    ,MainUI = 1
    ,Panel = 2
    ,WIndow = 3
    ,Tips = 4
}

-- Link类型
WinLinkType = {
    Link = 1        -- 做窗口连动
    ,Single = 2     -- 不连动
}

-- 方向
LuaDirection = {
    Mid = 0
    ,Left = 1
    ,Top = 2
    ,Right = 3
    ,Buttom = 4
}

-- 模型预览类型
PreViewType = {
    Role = 1
    ,Npc = 2
    ,Pet = 3
    ,Shouhu = 4
    ,Wings = 5
    ,RoleWings = 6
    ,Weapon = 7
    ,Home = 8
    ,Ride = 9
    ,HeadSurbase = 10
}

-- 音频类型
AudioSourceType = {
    BGM = "BGM"             -- 背景音乐
    ,UI = "UI"              -- UI音效
    ,Combat = "Combat"      -- 战斗音效
    ,CombatHit = "CombatHit"      -- 战斗受击音效
    ,NPC = "NPC"            -- NPC对话
    ,Chat = "Chat"          -- 语音
}

-- 加载类型
AssetLoadType = {
    WWW = 1
    ,Cache = 2
}

-- 只比较数字和字符串
table.containValue = function(t, value)
    for k, v in pairs(t) do
        if value == v then
            return true;
        end
    end
    return false;
end

table.containKey = function(t, key)
    for k, v in pairs(t) do
        if key == k then
            return true;
        end
    end
    return false;
end
