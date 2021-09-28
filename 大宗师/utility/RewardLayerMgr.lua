--[[
 --
 -- add by vicky
 -- 2014.11.29 
 --
 --]]

 RewardLayerMgrType = {
 	chat = 1, 			-- 聊天 
 	dailyLogin = 2, 	-- 签到 
 	kaifuReward = 3, 	-- 开服礼包 
 	levelReward = 4, 	-- 等级礼包 
 	onlineReward = 5, 	-- 在线礼包 
 	rewardCenter = 6, 	-- 奖励中心 
 	dailyTask = 7, 		-- 每日任务(成长之路) 

 }


 local RewardLayerMgr = {} 

 function RewardLayerMgr.createLayerByType(layerType, parent, zorder, tag) 

 	local ZOrder = zorder or 0 
 	local Tag = tag or 0 
 	
 	if layerType == RewardLayerMgrType.chat then 
 		RequestHelper.chat.getList({
	 		type = "1", 
	 		name = game.player:getPlayerName(), 
	 		callback = function(data)
	 			dump(data)
	 			if data["0"] ~= "" then
	 				dump(data["0"]) 
	 			else 
	 				local layer = require("game.Chat.ChatLayer").new(data)  
	 				parent:addChild(layer, ZOrder, Tag) 
	 			end
	 		end 
 		}) 

 	elseif layerType == RewardLayerMgrType.dailyLogin then 
 		RequestHelper.dailyLoginReward.getInfo({
	        callback = function(data)
	            dump(data)
		       	if data["0"] ~= "" then 
		       		dump(data["0"]) 
		       	else 
		            local layer = require("game.Huodong.dailyLogin.DailyLoginLayer").new(data) 
	 				parent:addChild(layer, ZOrder, Tag) 
		        end
		    end 
        })

    elseif layerType == RewardLayerMgrType.kaifuReward then 
    	RequestHelper.kaifuReward.getInfo({
	        callback = function(data)
	            dump(data)
	            if data["0"] ~= "" then 
			        dump(data["0"]) 
			    else
			    	local layer = require("game.Huodong.kaifuReward.KaifuRewardLayer").new(data) 
	 				parent:addChild(layer, ZOrder, Tag) 
			    end
	        end
        })

    elseif layerType == RewardLayerMgrType.levelReward then 
    	RequestHelper.levelReward.getInfo({
	        callback = function(data)
	            dump(data)
	            if string.len(data["0"]) > 0 then 
	                CCMessageBox(data["0"], "Tip")
	            else
	                local layer = require("game.Huodong.levelReward.LevelRewardLayer").new(data) 
	                parent:addChild(layer, ZOrder, Tag) 
	            end 
	        end
        })

    elseif layerType == RewardLayerMgrType.onlineReward then 
    	RequestHelper.onlineReward.getRewardList({
	        callback = function(data)
	            dump(data)
	            if data["0"] ~= "" then 
	            	dump(data["0"]) 
	            else 
		            local layer = require("game.Huodong.onlineReward.OnlineRewardLayer").new(data) 
	                parent:addChild(layer, ZOrder, Tag) 
		        end
	        end
        })

	elseif layerType == RewardLayerMgrType.rewardCenter then 
		RequestHelper.rewardCenter.getInfo({
	        callback = function(data)
	        	-- dump(data) 
	        	if data["0"] ~= "" then 
	            	dump(data["0"]) 
	            else 
		            local layer = require("game.Huodong.rewardCenter.RewardCenterLayer").new(data) 
	                parent:addChild(layer, ZOrder, Tag) 
		        end
	        end
        })

    elseif layerType == RewardLayerMgrType.dailyTask then 
        RequestHelper.dialyTask.getTaskList({
            callback = function(data)
                -- dump(data)
                if data["0"] ~= "" then
                    dump(data["0"]) 
                else 
                    -- local layer = require("game.DialyTask.TaskPopup").new(data,self) 
                    local layer = require("game.DialyTask.TaskPopup").new(data, parent) 
                    parent:addChild(layer, ZOrder, Tag) 
                end
            end 
        })
 	
 	end 
 end 


 return RewardLayerMgr 
