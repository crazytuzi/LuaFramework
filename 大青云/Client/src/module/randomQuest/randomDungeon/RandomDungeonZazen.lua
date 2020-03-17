--[[
奇遇副本 多倍打坐效果
2015年7月31日21:25:24
haohu
]]
--------------------------------------------------------------

_G.RandomDungeonZazen = setmetatable( {}, {__index = RandomDungeon} )

RandomDungeonZazen.restTime = 0
RandomDungeonZazen.timerKey = nil

function RandomDungeonZazen:GetType()
	return RandomDungeonConsts.Type_Zazen
end

function RandomDungeonZazen:Init()
	local cfg = self:GetCfg()
	self.restTime = cfg.param2
	self:StopCountDown()
end

function RandomDungeonZazen:DoStep2()
	self:CloseNpcDialog()
	self:StartCountDown()
	SitController:ReqSit()
end

function RandomDungeonZazen:GetTotalCount()
	local cfg = self:GetCfg()
	return cfg.param2
end
function RandomDungeonZazen:GetProgressTxt()
	return string.format( StrConfig['randomQuest012'], DungeonUtils:ParseTime( self.restTime ) )
end

function RandomDungeonZazen:StartCountDown()
	if self.timerKey then return end
	self.timerKey = TimerManager:RegisterTimer( function()
		self:CountDown()
	end, 1000, 0 )
end

function RandomDungeonZazen:CountDown()
	self.restTime = self.restTime - 1
	if self.restTime <= 0 then
		self:StopCountDown()
	end
	Notifier:sendNotification( NotifyConsts.RandomDungeonZazenTime )
end

function RandomDungeonZazen:StopCountDown()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil
		self.restTime = 0
	end
end

function RandomDungeonZazen:GetZazenBonus()
	if self.step ~= 2 then
		return 0
	end
	local cfg = self:GetCfg()
	return cfg.param1
end

--------------------- 销毁 -----------------------
function RandomDungeonZazen:Dispose()
	self:StopCountDown()
	self:StopGuideTimer()
	self:StopQuitTimer()
	if self.subject then
		self.subject:Dispose()
	end
	self.subject = nil
end