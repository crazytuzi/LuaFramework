--[[
	2015年11月18日00:20:10
	wangyanwei
	骑战副本提示UI
]]

_G.UIQiZhanDungeonTip = BaseUI:new('UIQiZhanDungeonTip');

function UIQiZhanDungeonTip:Create()
	self:AddSWF('qizhanDungeonTip.swf',true,'interserver');
end

function UIQiZhanDungeonTip:OnLoaded(objSwf)
	
end

function UIQiZhanDungeonTip:OnShow()
	self:TimeHandler();
end

function UIQiZhanDungeonTip:TimeHandler()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.mc_tip.txt_info.text = '';
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local num = nil;
	local timeNum = nil;
	if self.showType == 1 then
		num = 1;
		timeNum = 3000;
	elseif self.showType == 3 then
		num = 6; 
		local mapId = CPlayerMap:GetCurMapID();
		local mapCfg = t_map[mapId];
		if mapCfg then
			num = mapCfg.relive_time + 1
		end

		timeNum = 1000;	
	else
		num = 11;
		timeNum = 1000;
	end
	local func = function(count)
		if self.showType == 1 then
			objSwf.mc_tip.txt_info.text = StrConfig['qizhanDungeon5001'];
		elseif self.showType == 3 then
			if count then
				objSwf.mc_tip.txt_info.htmlText = string.format(StrConfig['qizhanDungeon7004'],num - count);
			end
		else
			if count then
				objSwf.mc_tip.txt_info.htmlText = string.format(StrConfig['qizhanDungeon5002'],num - count);
			end
		end
		self:TweenMc();
		if count then
			if count >= num then
				self:Hide();
			end
		end
	end
	self.timeKey = TimerManager:RegisterTimer(func,timeNum,num);
	if self.showType == 1 then
		func();
	end
end

function UIQiZhanDungeonTip:TweenMc()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local endX,endY = 0,0;
	local startX = objSwf._width / 4 ;
	local startY = endY + objSwf.mc_tip._height/2 + objSwf.mc_tip._height*30/100/2;
	objSwf.mc_tip._x = startX;
	objSwf.mc_tip._y = startY;
	objSwf.mc_tip._xscale = 50;
	objSwf.mc_tip._yscale = 50;
	Tween:To(objSwf.mc_tip,0.2,{_x = endX ,_y = endY,_xscale = 100,_yscale = 100},{onComplete = function()
		
	end})
end

function UIQiZhanDungeonTip:GetWidth()
	return 700
end

function UIQiZhanDungeonTip:GetHeight()
	return 44
end

function UIQiZhanDungeonTip:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

function UIQiZhanDungeonTip:ShowTypeData()
	
end

UIQiZhanDungeonTip.showType = nil
function UIQiZhanDungeonTip:Open(_type)
	if not _type then return end
	self.showType = _type;
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end