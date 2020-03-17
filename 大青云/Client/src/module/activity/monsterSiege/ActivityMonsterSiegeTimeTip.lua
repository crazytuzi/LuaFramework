--[[
	2015年9月10日, PM 08:37:48
	wangyanwei
	波数提示
]]

_G.UIMonsterSiegeTimeTip = BaseUI:new('UIMonsterSiegeTimeTip');

local monsterSiegeWave;

function UIMonsterSiegeTimeTip:Create()
	self:AddSWF('monsterSiegeTimeTip.swf',true,'bottom');
end

function UIMonsterSiegeTimeTip:OnLoaded(objSwf)
	objSwf.mc_wave.num_wave.onLoadComplete = function ()
		objSwf.mc_wave.num_wave._x = objSwf.mc_wave._width / 2 - objSwf.mc_wave.num_wave._width / 2 ;
		objSwf.mc_wave.num_wave._y = objSwf.mc_wave._heighy / 2 - objSwf.mc_wave.num_wave._heighy / 2 ;
	end
end

function UIMonsterSiegeTimeTip:OnShow()
	self:StartTime();
	self:LoadNumPic();
end

function UIMonsterSiegeTimeTip:Open(wave)
	if not wave then return end
	monsterSiegeWave = wave;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UIMonsterSiegeTimeTip:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer( self.timeKey );
		self.timeKey = nil;
	end
end

function UIMonsterSiegeTimeTip:LoadNumPic()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	objSwf.mc_wave.num_wave.num = monsterSiegeWave or 0;
end

function UIMonsterSiegeTimeTip:StartTime()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer( function()
		self:Hide();
	end, 5000, 1 );
end