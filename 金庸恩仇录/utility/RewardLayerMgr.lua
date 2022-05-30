local RewardLayerMgr = {}
function RewardLayerMgr.createLayerByType(layerType, parent, zorder, tag)
	local ZOrder = zorder or 0
	local Tag = tag or 0
	if layerType == RewardLayerMgrType.chat or layerType == RewardLayerMgrType.chatGuild then
		do
			local chatType = CHAT_TYPE.world
			local guildId
			if layerType == RewardLayerMgrType.chatGuild then
				chatType = CHAT_TYPE.guild
				guildId = game.player:getGuildInfo().m_id
			end
			RequestHelper.chat.getList({
			type = tostring(chatType),
			name = game.player:getPlayerName(),
			lasttime = game.player:getChatLastTime(chatType),
			callback = function (data)
				dump(data)
				if data["0"] ~= "" then
					dump(data["0"])
				else
					local layer = require("game.Chat.ChatLayer").new({
					data = data,
					chatType = chatType,
					guildId = guildId
					})
					parent:addChild(layer, ZOrder, Tag)
				end
			end
			})
		end
	elseif layerType == RewardLayerMgrType.dailyLogin then
		RequestHelper.dailyLoginReward.getInfo({
		callback = function (data)
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
		callback = function (data)
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
		callback = function (data)
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
		callback = function (data)
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
		callback = function (data)
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
		callback = function (data)
			local layer = require("game.DialyTask.TaskPopup").new(data, parent)
			parent:addChild(layer, ZOrder, Tag)
			
		end,
		missionType = 1
		})
	end
end

return RewardLayerMgr