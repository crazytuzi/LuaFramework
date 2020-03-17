g_bot = {}

function BotNew(CRobot, acc)
	local bot = 
	{
		owner = CRobot,
		account = acc,
		co = coroutine.create(BotCoroutine),
		isonline = false,
		isconn = false,
		logic = {},
		userdata = {},
	}
	bot.autotask = Setting.autoTask
	bot.test = Setting.Test
	bot.logic = randlogic()
	bot = Bot:Init(bot)
	g_bot[CRobot] = bot
	return bot.co
end

function BotConn(owner, guid)
	local bot = g_bot[owner]
	if bot ~= nil then
		bot.isconn = true
		coroutine.resume(bot.co,bot)
	end
end

function BotLogin(owner, guid)
	local bot = g_bot[owner]
	if bot ~= nil then
		bot.isonline = true
		--coroutine.resume(bot.co,bot)
	end
end

function BotInfo(owner, guid, prof)
	local bot = g_bot[owner]
	bot.guid = readGuid(guid, 1)
	bot.prof = prof
	bot.info = {}
	Debug("call from c ", bot.guid, bot.prof)
end

function BotChangePos(owner)

	--Debug("BotChangePos call from c ")
end

function BotLogout(owner)
	local bot = g_bot[owner]
	if bot ~= nil then
		bot.isconn = false
		bot.isonline = false
		coroutine.resume(bot.co,bot)
	end
end

function BotExit(owner)
	local bot = g_bot[owner]
	if bot ~= nil then
		g_bot[owner] = nil
	end
end

function BotTimer(owner)
	local bot = g_bot[owner]
	if bot ~= nil then
		
	end
end

function BotResp(owner, msgId, data)
	local bot = g_bot[owner]
	if bot ~= nil then
		--Debug('BotResp msgId = ' .. msgId)
		local msgClass = MsgMap[msgId]
		if msgClass ~= nil then
			local msg = msgClass:new()
			msg:ParseData(data);
			--Debug(Utils.dump(msg))
			if bot.autotask then
				bot:process(msg)
			else
				bot.logic.process(bot, msg)
			end

			bot:myprocess(msg)	
		end
	end
end

function BotCoroutine(bot)
	
	while true do
		if not bot.isconn then
			coroutine.yield(bot.co)
		end
		if bot.autotask then 
			bot:script()
		else
			bot.logic.script(bot);
		end
	end	
end
