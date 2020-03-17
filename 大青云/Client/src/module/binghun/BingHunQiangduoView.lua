--[[
冰魂抢夺
wangshuai
]]

_G.UIBinghunQiangView = BaseUI:new("UIBinghunQiangView")

UIBinghunQiangView.timerKey = nil;
UIBinghunQiangView.time = 10;
UIBinghunQiangView.objUIDraw = nil

function UIBinghunQiangView:Create()
	self:AddSWF("binghuiQiangduo.swf",true,"center")
end;

function UIBinghunQiangView:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;
end;

function UIBinghunQiangView:OnShow()
	self:Initinfo();
	self:DrawBingHun();
end;

function UIBinghunQiangView:OnHide()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	if self.objUIDraw then 
		self.objUIDraw:SetUILoader(nil);
		self.objUIDraw:SetDraw(false)
	end;
end;

function UIBinghunQiangView:Initinfo()
	local objSwf = self.objSwf;
	self.time = 10;
	objSwf.lastTime_txt.htmlText = string.format(StrConfig["binghun2"],self.time)
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function()self:Ontimer()end,1000,self.time);
end;

function UIBinghunQiangView:Ontimer()
	if not self.bShowState then return; end
	self.time = self.time - 1;
	local objSwf = self.objSwf;
	objSwf.lastTime_txt.htmlText = string.format(StrConfig["binghun2"],self.time)
	if self.time <= 0 then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
		self:Hide();
	end;
end;

	
-- 显示类型为level的3d兵魂模型
-- showActive: 是否播放激活动作
local viewBingHunPort;
function UIBinghunQiangView:DrawBingHun()
	local objSwf = self.objSwf;
	local cfg = t_binghun[1];
	if not self.objUIDraw then
		if not viewBingHunPort then viewBingHunPort = _Vector2.new(1279, 732); end
		self.objUIDraw = UISceneDraw:new( "UIBinghunQiangView", objSwf.modelload, viewBingHunPort);
	end
	self.objUIDraw:SetUILoader(objSwf.modelload);

	local prof = MainPlayerModel.humanDetailInfo.eaProf
	local clist = split(cfg.qiang_sen,"#")
	local ui_sen = clist[prof]
	self.objUIDraw:SetScene( ui_sen, nil );
	self.objUIDraw:SetDraw(true)

end

function UIBinghunQiangView:GetWidth()
	return 789
end;

function UIBinghunQiangView:GetHeight()
	return 269
end;


