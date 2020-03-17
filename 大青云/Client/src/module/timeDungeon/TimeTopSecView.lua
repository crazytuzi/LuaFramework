--[[
	2015年4月22日, PM 06:25:33
	wangyanwei
	顶部计时
]]
_G.UITimeTopSec = BaseUI:new('UITimeTopSec');

function UITimeTopSec:Create()
	self:AddSWF("timeDungeonTopSec.swf", true, 'bottom');
end

function UITimeTopSec:OnLoaded(objSwf)
	-- objSwf.panel.txt_str.text = StrConfig['timeDungeon090'];
end

function UITimeTopSec:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	if self.txtType == 0 then
		objSwf.panel.txt_str.text = StrConfig['timeDungeon090'];
	elseif self.txtType == 1 then
		objSwf.panel.txt_str.text = StrConfig['timeDungeon090'];
	elseif self.txtType == 2 then
		objSwf.panel.txt_str.text = StrConfig['timeDungeon1024'];
	elseif self.txtType == 3 then
		objSwf.panel.txt_str.text = StrConfig['timeDungeon1025'];
	elseif self.txtType == 4 then
		objSwf.panel.txt_str.text = StrConfig['timeDungeon1026'];
	end
	self:OnTimeHandler();
end

UITimeTopSec.txtType = nil;
UITimeTopSec.startNum = nil;
function UITimeTopSec:Open(type,startNum)
	if not type then
		return
	end
	self.txtType = type
	if startNum then
		self.startNum = startNum
	end
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UITimeTopSec:OnTimeHandler()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local sec;
	if self.txtType == 0 then
		sec = 8
	elseif self.txtType == 1 then  --试用于封妖试炼副本
		sec =self.startNum or 0
	elseif self.txtType == 2 then  --试用于所有副本弹出结算界面的副本
		sec = 5
	elseif self.txtType == 3 then  --试用于刷怪出现倒计时
		sec = self.startNum or 0
	elseif self.txtType == 4 then  --试用于第一次进入场景中怪物刷新倒计时
		sec = self.startNum or 0
	end
	objSwf.panel.txt_sec.text = sec..'秒';
	local func = function ()
		sec = sec - 1;
		objSwf.panel.txt_sec.text = sec..'秒';
		if sec < 1 then 
			if self.txtType == 1 then
				QiZhanDungeonController:OpenStartTime( )
			end
			self:Hide();
		end
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
	-- func();
end

function UITimeTopSec:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.objSwf.panel.txt_sec.text = '';
end