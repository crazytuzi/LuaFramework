--[[
奇遇副本 factory
2015年7月30日17:20:55
haohu
]]
--------------------------------------------------------------

_G.RandomDungeonFactory = {}

-- RandomDungeonConsts.Type_Collect        = 1  -- 刷新采集物
-- RandomDungeonConsts.Type_Monster        = 2  -- 杀怪
-- RandomDungeonConsts.Type_Answer         = 3  -- 答题
-- RandomDungeonConsts.Type_Clue           = 4  -- 采集找线索
-- RandomDungeonConsts.Type_Zazen          = 5  -- 多倍打坐效果
-- RandomDungeonConsts.Type_Resource       = 6  -- 采集加资源

-- @ tid: t_qiyu id
function RandomDungeonFactory:CreateDungeon( tid )
	local cfg = _G.t_qiyu[tid]
	if not cfg then
		Error( string.format( "wrong random dungeon id:%s", tid ) ) 
		return
	end
	local dType = cfg.type
	Debug("进入副本类型：" .. dType)
	local class
	if dType == RandomDungeonConsts.Type_Collect then
		class = RandomDungeonCollect
	elseif dType == RandomDungeonConsts.Type_Monster then
		class = RandomDungeonMonster
	elseif dType == RandomDungeonConsts.Type_Answer then
		class = RandomDungeonAnswer
	elseif dType == RandomDungeonConsts.Type_Clue then
		class = RandomDungeonClue
	elseif dType == RandomDungeonConsts.Type_Zazen then
		class = RandomDungeonZazen
	elseif dType == RandomDungeonConsts.Type_Resource then
		-- class = RandomDungeonResource
		class = RandomDungeonCollect
	else
		_debug:throwException( string.format( "wrong random dungeon type:%s", dType ) );
		return
	end
	return class:new(tid)
end

