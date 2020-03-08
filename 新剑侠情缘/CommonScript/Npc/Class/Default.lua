
-- Npc默认模板（也是基础模板）

-- 从Npc模板库中找到此模板，如不存在会自动建立新模板并返回
-- 提示：npc.lua 已经在 preload.lua 中前置，这里无需再Require
local tbDefault	= Npc:GetClass("default");

--npc被创建
function tbDefault:OnCreate()
end

-- 定义对话事件
function tbDefault:OnDialog()
end

-- 定义死亡事件
function tbDefault:OnDeath(pNpcKiller)
end

-- 定义死亡事件
function tbDefault:OnEarlyDeath(pNpcKiller)
end