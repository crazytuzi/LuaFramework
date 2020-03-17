_G.ClientMsgPath = './bot/msg/'
_G.ClientCfgPath = './bot/config/'
_G._dofile = function(file)
	dofile(file)
end
dofile('./bot/Utils.lua')
dofile('./bot/Cfg.lua')
dofile('./bot/Bot.lua')
dofile('./bot/BotLogic.lua')
dofile('./bot/code_1425285492450_1.lua')
dofile('./data/config/MapPoint.lua')
dofile('./bot/accountlist.lua')
dofile('./bot/SmartAI.lua')
dofile('./bot/quest.lua')

dofile(ClientMsgPath .. 'Include.lua')

dofile(ClientCfgPath .. 't_quest.lua')
dofile(ClientCfgPath .. 't_position.lua')
dofile(ClientCfgPath .. 't_portal.lua')
dofile(ClientCfgPath .. 't_dailyquest.lua')
dofile(ClientCfgPath .. 't_dunstep.lua')
dofile(ClientCfgPath .. 't_activity.lua')
dofile(ClientCfgPath .. 't_manname.lua')
dofile(ClientCfgPath .. 't_mansurname.lua')
dofile(ClientCfgPath .. 't_womanname.lua')
dofile(ClientCfgPath .. 't_womansurname.lua')
