--[[
获得称号的特效面板
2014年11月26日, AM 10:56:56
wangyanwei
]]

_G.UITitleGetTips =  BaseUI:new("UITitleGetTips");

UITitleGetTips.timeKey = nil;

function UITitleGetTips:Create()
	self:AddSWF("titleGetTips.swf",true,"center");
end

function UITitleGetTips:OnLoaded(objSwf)
	objSwf.mc.hitTestDisable = true;
	objSwf.mc.effectIcon.complete = function ()
			local mc = objSwf.mc;
			mc.effectIcon:stopEffect();
			mc.icon._visible = true;
			self:ChangeTime();
		end
end

UITitleGetTips.titleTable = {};
UITitleGetTips.idTable = {};
function UITitleGetTips:OnShow()
	local objSwf = self:GetSWF("UITitleGetTips");
	if not objSwf then return end;
	objSwf.mc._visible = false;
	self.layerNum = self.layerNum + 1;
	table.push(self.titleTable,self.titleUrl);
	table.push(self.idTable,self.titleID);
	self:OnTitleLoaded();
end

function UITitleGetTips:InitMC()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.mc._alpha = 0;
	objSwf.mc._y = objSwf.mc._y + objSwf.mc._height;
end

function UITitleGetTips:ChangeTime()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local func = function()
		self:InitMC();
		self.layerNum = self.layerNum - 1;
		if self.layerNum > 0 then
			self:OnTitleLoaded();
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		else
			self:Hide();
		end
	end
	self.timeKey = TimerManager:RegisterTimer(func,5000);
end

--open
UITitleGetTips.titleUrl = nil;
UITitleGetTips.layerNum = 0;
function UITitleGetTips:Open(iconUrl,id)
	self.titleUrl = iconUrl;
	self.titleID = id;
	self:Show();
end

function UITitleGetTips:GetWidth()
	return 1;
end

function UITitleGetTips:SetOpen(iconUrl,id)
	local objSwf = self.objSwf;
	if not objSwf then return end
	table.push(self.titleTable,iconUrl);
	table.push(self.idTable,id);
	self.layerNum = self.layerNum + 1;
end

function UITitleGetTips:OnTitleLoaded()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local titleCfg = t_title[table.remove(self.idTable,1)];
	if not titleCfg then return end
	local mc = objSwf.mc;
	-- objSwf.mc.titleLoad.source = ResUtil:GetTitleIconSwf(table.remove(self.titleTable,1));
	mc.titleLoad.loaded = function() 
	   mc.titleLoad._xscale = titleCfg.titleUIscale*100;
	   mc.titleLoad._yscale = titleCfg.titleUIscale*100;
	   mc.titleLoad._x = -toint(titleCfg.titleWidth * titleCfg.titleUIscale/2)
	   mc.titleLoad._y = -toint(titleCfg.titleHeight * titleCfg.titleUIscale/2)
	   self:OnTweenMC();
	end
	local url = table.remove(self.titleTable,1);
	UILoaderManager:LoadList({ResUtil:GetTitleIconSwf(url)},function()
		mc.titleLoad.source = ResUtil:GetTitleIconSwf(url);
	end);
end

--tween
function UITitleGetTips:OnTweenMC()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.mc._visible = true;
	local mc = objSwf.mc;
	local endX,endY = mc._x,mc._y - mc._height;
	local startX = endX ;
	local startY = mc._y;
	mc._alpha = 0;
	mc._x = startX;
	mc._y = startY;
	
	Tween:To(mc,1,{_alpha = 100,_y = endY},{onComplete = function()
		mc.effectIcon:playEffect(1);
	end})
end

function UITitleGetTips:OnHide()
	self.layerNum = 0;
	self.titleUrl = nil;
	self.titleTable = {};
	self.idTable = {};
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

local btnIndex = 1;
function UITitleGetTips:GetNewUid()
	btnIndex = btnIndex + 1;
	return "titleBtn"..btnIndex;
end