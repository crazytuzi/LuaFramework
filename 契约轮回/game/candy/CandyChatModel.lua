--
-- @Author: chk
-- @Date:   2019-03-13 19:42:29
--
CandyChatModel = CandyChatModel or class("CandyChatModel",BaseModel)
local CandyChatModel = CandyChatModel

function CandyChatModel:ctor()
	CandyChatModel.Instance = self
	self:Reset()
end

function CandyChatModel:Reset()
	self.channelSettors = {}
	self.inlineManagers = {}
	self.inlineManagerScps = {}
	self.msg_list_by_channel = {}
end

function CandyChatModel.GetInstance()
	if CandyChatModel.Instance == nil then
		CandyChatModel()
	end
	return CandyChatModel.Instance
end

function CandyChatModel:DeleteChannelItems(channel)
	for i, v in pairs(self.channelSettors[channel] or {}) do
		v:destroy()
	end

	self.channelSettors[channel] = {}
end

function CandyChatModel:GetChannelItemsHeight(channel)
	local height = 0
	local settors = self.channelSettors[channel] or {}
	for i, v in pairs(settors) do
		height = height + v.height
	end

	return height
end

function CandyChatModel:GetChannelItemsByChannel(channel)
	self.channelSettors[channel] = self.channelSettors[channel] or {}
	return self.channelSettors[channel]
end

function CandyChatModel:GetChannelItemsCount(channel)
	return table.nums(self.channelSettors[channel] or {})
end

function CandyChatModel:IsContainEmojiName(emojiName)
	return Config.db_emoji[emojiName] ~= nil
end