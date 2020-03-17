--[[
问题(奇遇副本)
2015年7月30日17:20:55
haohu
]]
--------------------------------------------------------------

_G.RandomDungeonQuestion = {}

RandomDungeonQuestion.id = nil
RandomDungeonQuestion.lastQuestionRight = nil

function RandomDungeonQuestion:new(id)
	local obj = {}
	setmetatable( obj, {__index = self} )
	obj.id = id
	return obj
end

function RandomDungeonQuestion:GetCfg()
	local cfg = _G.t_qiyutiku[self.id]
	if not cfg then
		Debug( string.format( "cannot find config in t_qiyutiku. tiku ID:%s", self.id ) )
	end
	return cfg
end

function RandomDungeonQuestion:GetKey()
	local cfg = self:GetCfg()
	return cfg.key
end

function RandomDungeonQuestion:GetOptions()
	local cfg = self:GetCfg()
	local options = {}
	for i = 1, 3 do
		local option = {}
		option.answer = i
		option.label = tostring( cfg[ "options"..i ] )
		table.push( options, UIData.encode( option ) )
	end
	return options
end

function RandomDungeonQuestion:GetNpcTalkPrefix()
	local prefix = ""
	local cfg = self:GetCfg()
	if self.lastQuestionRight == true then
		prefix = cfg.rightWord
	elseif self.lastQuestionRight == false then
		prefix = cfg.wrongWord
	end
	return prefix
end

function RandomDungeonQuestion:GetNpcTalk()
	local cfg = self:GetCfg()
	local prefix = self:GetNpcTalkPrefix()
	if prefix == "" then
		return cfg.desc
	end
	return prefix .. "\n" .. cfg.desc
end

function RandomDungeonQuestion:SetLastQuestionRight(isRight)
	if self.lastQuestionRight ~= isRight then
		self.lastQuestionRight = isRight
		Notifier:sendNotification( NotifyConsts.RandomDungeonQuestionState )
	end
end

function RandomDungeonQuestion:Answer( replyIndex )
	if self:GetKey() == replyIndex then
		RandomQuestController:ReqRandomDungeonStepSubmit( replyIndex )
	else
		self:SetLastQuestionRight(false)
	end
end

function RandomDungeonQuestion:Dispose()
	-- body
end