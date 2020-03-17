
_G.datas = {}

_G.my_dofile = function( file )
	dofile(file)
	val = {}
	val.script = script
	val.process = process
	table.insert(datas, val)
end

_G.randlogic = function()
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
	local id = math.random(1, #datas)
	return datas[id];
end

_G.Setting = {
	autoTask = true,
}
--my_dofile('./bot/script1.lua')
--my_dofile('./bot/script2.lua')
--my_dofile('./bot/guild_creator.lua')
--my_dofile('./bot/guild_joiner.lua')
--my_dofile('./bot/arena.lua')
--my_dofile('./bot/campbat.lua')
--my_dofile('./bot/quest.lua')
--my_dofile('./bot/storydungeon.lua')
--my_dofile('./bot/WorldBoss.lua')
--my_dofile('./bot/Babel.lua')
--my_dofile('./bot/activationcode.lua')
--my_dofile('./bot/extremdugeon.lua')
--my_dofile('./bot/beichangjie.lua')
--my_dofile('./bot/team.lua')
--my_dofile('./bot/teamdungeon.lua')
--my_dofile('./bot/teamdungeon_joiner.lua')
--my_dofile('./bot/actpet.lua')
--my_dofile('./bot/addfriend.lua')
my_dofile('./bot/weishi.lua')
my_dofile('./bot/account.lua')

