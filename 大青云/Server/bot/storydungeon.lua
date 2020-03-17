_G.script = function( bot )
   bot:delay( 1000 )
   
   bot:chat(1, '/levelup/40')
   local msg = ReqEnterDungeonMsg:new()
   msg.flag = 1
   msg.dungeonId = 101
   bot:sendrpc( msg, MsgType.SC_EnterDungeonResult )

   bot.userdata.curStepId = 0
   while true do
   	   if bot.userdata.result == 0 then break end
   	   if bot.userdata.stepId~=nil then
	   	   local step_id = bot.userdata.stepId
		   if step_id==nil or step_id==bot.userdata.curStepId then 
		   	  return
		   end
		   if step_id == 101001 or step_id==101005 or step_id==101015 then
			   local msg = ReqDungeonNpcTalkEndMsg:new()
			   msg.step = step_id
			   bot:sendrpc( msg, MsgType.SC_StoryStep )
			else
				local storyCmd = "/storyfinish/" .. tostring(step_id)
				bot:chat(1, storyCmd)
				bot:rtrace('story step....' .. step_id)
		   end
		   bot.userdata.curStepId = step_id
		   bot:delay( 2000 )
		end
   	end
   	bot:quit()
end

_G.process = function( bot, msg )
   if msg.msgId == MsgType.SC_EnterDungeonResult then
   	  bot.userdata.dungeonId = msg.dungeonId
   	  bot.userdata.stepId = msg.stepId
   	elseif msg.msgId == MsgType.SC_StoryStep then
      bot.userdata.stepId = msg.stepId
    elseif msg.msgId == MsgType.SC_StoryEndResult then
      bot.userdata.result = msg.result
   end
end
