--[[
奇遇副本 刷高经验怪物类
2015年7月30日17:08:14
haohu
]]
--------------------------------------------------------------

_G.RandomDungeonMonster = setmetatable( {}, {__index = RandomDungeon} )

RandomDungeonMonster.monsterId = nil

function RandomDungeonMonster:GetType()
	return RandomDungeonConsts.Type_Monster
end

function RandomDungeonMonster:GetProgressTxt()
	local progress   = self:GetProgress()
	local totalCount = self:GetTotalCount()
	return string.format( StrConfig['randomQuest011'], progress, totalCount )
end

function RandomDungeonMonster:Init()
	local level = MainPlayerModel.humanDetailInfo.eaLevel
	local levelCfg = _G.t_qiyulevel[ level ]
	if not levelCfg then
		Error( string.foramt( "cannot find config in t_qiyulevel, level : %s", level ) )
	end
	local cfg = self:GetCfg()
	local configKey = "monster_id" .. cfg.param1
	self.monsterId = levelCfg[configKey]
	Debug( string.format( "monster id is : %s", self.monsterId ) )
end

function RandomDungeonMonster:DoStep2()
	self:CloseNpcDialog()
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle()
	end
	completeFuc()
	-- MainPlayerController:DoAutoRun( mapId, _Vector3.new( point.x, point.y, 0 ), completeFuc )
end

function RandomDungeonMonster:GetMonsterPos()
	-- body
end

function RandomDungeonMonster:GetTotalCount()
	local cfg = self:GetCfg()
	return cfg.param2
end