local function my_quest(bot)
	local quests = {
         1002040,
         1002041,
         1002042,
         1002043,
         1002044,
         1002045,
         1002046,
         1002047,
         1002048,
         1002049,
		 1002050,
         1002051,
         1002052,
         1102001,
		 1102002,
         1102003,
    }
end

_G.script = function( bot )
	bot:delay( 3000 )
    
    for i,questInfo in pairs(bot.userdata.quests) do
		local quest_id = questInfo.id
        if quest_id > 0 then
			local msg = ReqFinishQuestMsg:new()
			msg.id = quest_id
			bot:sendrpc( msg, MsgType.SC_FinishQuestResult )
		end
	end
    
    local currentId = 0
    while true do
    	if bot.userdata.questId ~=nil then
    		local id = bot.userdata.questId
    		if id > 0 and id ~= currentId then
    			if id > 1000 then
    				local acceptCmd = "/acceptquest/" .. tostring(id)
		    		local finishCmd = "/finishquest/" .. tostring(id)
		    		bot:chat(1, acceptCmd)
		    		bot:chat(1, finishCmd)
    			else
    				local dailyCmd = "/finishdaily/" .. tostring(id)
    				bot:chat(1, dailyCmd)
    			end
	    		currentId = id
    		end
        end
        bot:delay(2000)
    end
    bot:quit()
end

_G.process = function( bot, msg )
	print("quest process: ", msg.msgId, msg)
	if msg.msgId == MsgType.SC_QueryQuestResult then
		bot.userdata.dailyAutoStar = msg.dailyAutoStar
		bot.userdata.quests = {}
		bot.userdata.quests = msg.quests
	elseif msg.msgId == MsgType.SC_QuestAdd then
		--bot.userdata.questId = msg.id
		bot.userdata.questId = my_quest(bot)
		bot.userdata.state = 2
		bot:rtrace('request add....' .. msg.id)
	end
end