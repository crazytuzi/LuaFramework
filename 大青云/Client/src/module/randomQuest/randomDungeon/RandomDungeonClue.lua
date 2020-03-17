--[[
奇遇副本 采集找线索
2015年7月31日21:25:24
haohu
]]
--------------------------------------------------------------

_G.RandomDungeonClue = setmetatable( {}, {__index = RandomDungeonCollect} )

RandomDungeonClue.beforeQuitTimer = nil

function RandomDungeonClue:GetType()
	return RandomDungeonConsts.Type_Clue
end

function RandomDungeonClue:GetProgressTxt()
	local txtResult = (self.step == 3) and StrConfig['randomQuest007'] or StrConfig['randomQuest008'] -- 找到后，读秒退出的步骤显示已找到，其他显示未找到
	return string.format( StrConfig['randomQuest009'], txtResult )
end

function RandomDungeonClue:SetProgress(progress)
	if self.progress ~= progress then
		self.progress = progress
		UIRandomDungeonPrompt:Prompt( StrConfig['randomQuest104'] )
		return true
	end
	UIRandomDungeonPrompt:Prompt( StrConfig['randomQuest105'] )
	return false
end

function RandomDungeonClue:DoStep3()
	if self.beforeQuitTimer then return end
	self.beforeQuitTimer = TimerManager:RegisterTimer( function()
		self:StartQuitTimer()
		self.beforeQuitTimer = nil
	end, 2000, 1)
end