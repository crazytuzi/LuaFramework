--[[
奇遇副本 答题类
2015年7月30日17:08:14
haohu
]]
--------------------------------------------------------------

_G.RandomDungeonAnswer = setmetatable( {}, {__index = RandomDungeon} )

-- t_qiyu tid
function RandomDungeonAnswer:GetType()
	return RandomDungeonConsts.Type_Answer
end

function RandomDungeonAnswer:GetProgressTxt()
	local progress   = self:GetProgress()
	local totalCount = self:GetTotalCount()
	return string.format( StrConfig['randomQuest004'], progress, totalCount )
end

function RandomDungeonAnswer:GetDialog()
	-- 检查是否全部正确
	if self.step == 3 then
		return StrConfig['randomQuest005']
	end
	-- 有答题优先返回答题对话
	if self.subject then
		return self.subject:GetNpcTalk()
	end
	local cfg = self:GetCfg()
	return cfg.dialog
end

function RandomDungeonAnswer:GetOptions()
	-- 检查是否全部正确
	if self.step == 3 then
		return { UIData.encode( { label = StrConfig['randomQuest006'] } ) }
	end
	-- 有答题优先返回答题选项
	if self.subject then
		return self.subject:GetOptions()
	end
	local answer = self:GetAnswerStr()
	local option = { label = answer }
	return { UIData.encode( option ) }
end

function RandomDungeonAnswer:DoStep2()
	self:RunToNpc()
end

function RandomDungeonAnswer:GetTotalCount()
	local cfg = self:GetCfg()
	return cfg.param1
end

function RandomDungeonAnswer:GetSubject()
	return self.subject
end

function RandomDungeonAnswer:SetSubject(subject)
	if self.subject ~= nil then
		-- 非第一次收到题，设置上一道题答对状态为true
		subject:SetLastQuestionRight( true )
	end
	self.subject = subject
end