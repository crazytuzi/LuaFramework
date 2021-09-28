 --[[
 --
 -- @authors shan 
 -- @date    2014-06-17 19:37:34
 -- @version 
 --
 --]]

require("utility.RequestHelper")
require("network.RequestHelperV2")

require("utility.Func")
require("utility.BottomBtnEvent")

KHEART_TIME = 5 * 60 


game = {
    player = require("game.Player").new(), 
    heartTime = KHEART_TIME, 
    broadcast = require("game.Broadcast").new(), 	-- 广播 
    urgencyBroadcast = require("game.UrgencyBroadcast").new() 	-- 紧急广播 
}

game.broadcast:retain()
game.urgencyBroadcast:retain() 


function heart()
	if game.player.m_isShowOnlineReward then
		if game.player.m_onlineRewardTime > 0 then
			game.player.m_onlineRewardTime = game.player.m_onlineRewardTime - 1
		end
	end

	if game.player._biwuCollTime then
		if game.player._biwuCollTime > 0 then
			game.player._biwuCollTime = game.player._biwuCollTime - 1
		end
	end

	if game.player._yaBiaoCollTime then
		if game.player._yaBiaoCollTime > 0 then
			game.player._yaBiaoCollTime = game.player._yaBiaoCollTime - 1
		end
	end

	if game.heartTime > 0 then
		game.heartTime = game.heartTime - 1
	end

	if game.heartTime <= 0 then
		game.heartTime = KHEART_TIME 
		if(not CSDKShell.isLogined()) then
			return
		end
		GameRequest.Broadcast.updateList({
	 		callback = function(data)
		 		-- game.heartTime = KHEART_TIME 	
	 			if(data ~= nil) then
	 				print("hearttttttttt")
		 			-- dump(data)
		 			GameModel.updateData(data["5"])
		 			if data["0"] ~= "" then 
		 				dump(data["0"]) 
		 			else
		 				-- 紧急广播内容
		 				local urgencyList = data["2"] 
		 				if urgencyList ~= nil and type(urgencyList) == "table" and #urgencyList > 0 then 
		 					game.urgencyBroadcast:cleanList() 
			 				game.urgencyBroadcast:addToUrgencyBroadcast(urgencyList) 
			 			end 
			 			-- 编辑当前的广播 
		 				game.broadcast:addBroadStrFromSever(data) 

		 				-- 玩家体力、耐力值 
		 				local playerInfo = data["3"] 
		 				if playerInfo ~= nil and type(playerInfo) == "table" and #playerInfo > 0 then 
		 					if game.player ~= nil then 
		 						game.player:updateMainMenu({tili = playerInfo[1], naili = playerInfo[2]}) 
		 						PostNotice(NoticeKey.MainMenuScene_Update) 
		 						PostNotice(NoticeKey.CommonUpdate_Label_Naili) 
		 						PostNotice(NoticeKey.CommonUpdate_Label_Tili) 
		 					end 
		 				end 

		 				-- 邮件提示
		 				local mailTip = data["4"]
		 				if(mailTip ~= nil) then
		 					game.player:setMailTip(mailTip)
		 					PostNotice(NoticeKey.MAIL_TIP_UPDATE)
		 				end
		 			end 
		 		else 
		 			dump("heart msg is nil")
		 		end
			end
	 		})
	end
end

GameStateManager = require("game.GameStateManager")
NormalButton = require("utility.NormalButton")

heartFunc = require("framework.scheduler").scheduleGlobal(heart, 1, false)
