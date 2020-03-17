-- campbat.lua
local function my_skill(bot)
	local skills = {
		1001001,
		1002001,
		1003001,
		1004001,
		1005001,
		1006001,
	}
	local id = math.random(1, #skills)
	bot:skill( skills[id] )
end

local function run_to_monster(bot)
	local pos = {
			[1]  = {id=10000013,x=544,y=-281,dir=0},
			[2]  = {id=10000013,x=-395,y=438,dir=0},
			[3]  = {id=10000013,x=-429,y=406,dir=0},
			[4]  = {id=10000013,x=568,y=-298,dir=0},
			[5]  = {id=10000014,x=341,y=464,dir=0},
			[6]  = {id=10000014,x=449,y=447,dir=0},
			[7]  = {id=10000014,x=263,y=574,dir=0},
			[8]  = {id=10000015,x=-317,y=-421,dir=0},
			[9]  = {id=10000015,x=-557,y=-406,dir=0},
			[10] = {id=10000015,x=-346,y=-408,dir=0},
	}
	local id = math.random(1, #pos)
	bot:runto( pos[id].x, pos[id].y )
end

local function run_to_flag(bot)
	local pos = {
		[1] = {idx = 61, x = -310, y = -113 },
		[2] = {idx = 62, x = 304, y = -149},
		[3] = {idx = 71, x = -257, y = 114},
		[4] = {idx = 72, x = 278, y = 173},
		[5] = {idx = 1, x = -380, y = 400},
		[6] = {idx = 2, x = 386, y = -400},	
	}
	local camp = bot.userdata.camp
	if  camp then
		id = math.random(1, 2)
		for k,v in pairs(pos) do
			if v.idx == camp*10 + id then
				bot.userdata.flagPos = v.idx
				bot:runto( v.x, v.y )
				break
			end
		end
	else
		local id = math.random(1, #pos)
		bot.userdata.flagPos = pos[id].idx
		bot:runto( pos[id].x, pos[id].y )
	end
end

local function run_to_home(bot)
	local pos = {
		[6] = {x = -7, y = 525 },
		[7] = {x = 1, y = -532},
		
	}
	local camp = bot.userdata.camp
	if camp then
		bot:runto( pos[camp].x, pos[camp].y )
	else
		local id = math.random(1, 2)
		bot:runto( pos[5+id].x, pos[5+id].y )
	end
end

local function select_oper(bot)
	if bot.userdata.dead == true then
		bot:delay(6000)
		local revive = ReqReviveMsg:new()
		revive.reviveType = 2
		bot:sendrpc( revive, MsgType.SC_Revive )
		bot:delay(1000)
		return
	end

	if bot.userdata.status == 1 then 
		run_to_flag(bot)
		my_skill(bot)
		bot:delay(3000)
		local pick = ReqPickFlagMsg:new()
		pick.oper = 0
		pick.idx = bot.userdata.flagPos
		bot:sendrpc( pick, MsgType.SC_PickFlagResult )
	elseif bot.userdata.status == 2 then
		run_to_home(bot)
		bot:delay(3000)
		local carry = ReqPickFlagMsg:new()
		carry.oper = 1
		carry.idx = bot.userdata.flagPos
		bot:sendrpc( carry, MsgType.SC_PickFlagResult )
	elseif bot.userdata.status == 3 then
		run_to_monster(bot)
		my_skill(bot)
		bot:delay(5000)
		my_skill(bot)
		bot:delay(5000)

		local s = math.random(1, 100)
		if s > 80 then
			bot.userdata.status = 1
		else
			bot.userdata.status = 3
		end
	else
		my_skill(bot)
		bot:delay(10000)
	end
end



_G.script = function( bot )
	bot:delay( 3000 )
	bot:chat(1, '/levelup/39')
	bot:delay( 1000 )
	for i=1,1000 do
		local reqAct = ReqWorldBossMsg:new()
		bot:sendrpc( reqAct, MsgType.WC_ActivityState )
		
		if bot.userdata.lineID ~= nil then
			bot:goline(bot.userdata.lineID)
			bot:delay(3000)

			bot:chat(1, '/debugact/1')
			bot:delay( 1000 )
			
			local enter = ReqActivityEnterMsg:new()
			enter.id    = 10002
			bot:sendrpc( enter, MsgType.SC_ActivityEnter )
			for i = 1, 5000 do
				select_oper(bot)
			end
			local exit = ReqActivityQuitMsg:new()
			exit.id = 10002
			bot:sendrpc( exit, MsgType.SC_ActivityQuit )
		end
		bot:quit()
		bot:delay(3000)
	end
end

_G.process = function( bot, msg )
	if msg.msgId == MsgType.WC_ActivityState then
		for i,vo in ipairs(msg.list) do
			if vo.id == 10002 and vo.state == 1 then
				bot.userdata.lineID = vo.line
				break
			end
		end
	end
	if msg.msgId == MsgType.SC_ActivityEnter then
		if msg.result ~= 0 then
			print("Enter Err", msg.result)
			return
		end
		local s = math.random(1, 100)
		if s > 40 then
			bot.userdata.status = 1
		else
			bot.userdata.status = 3
		end
	end
	if msg.msgId == MsgType.SC_GetZhanchanginfo then
		bot.userdata.camp = msg.type
	end
	if msg.msgId == MsgType.SC_PickFlagResult then
		if msg.result == 1  then
			if msg.type == 0 then
				bot.userdata.status = 2
			end
		end

		if bot.userdata.status ~= 2 then
			local s = math.random(1, 100)
			if s > 50 then
				bot.userdata.status = 1
			else
				bot.userdata.status = 3
			end
		end
	end

	if msg.msgId == MsgType.SC_ObjDeadInfo then
		if bot.guid == msg.deadid then
			bot.userdata.dead = true
		end
	end

	if msg.msgId == MsgType.SC_Revive then
		if bot.guid == msg.roleID  and msg.result == 0 then
			bot.userdata.dead = false
		end
	end
end

