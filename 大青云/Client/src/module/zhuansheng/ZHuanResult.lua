--[[
转生退出
wangshuai
]]

_G.UIZhuanResult = BaseUI:new("UIZhuanResult");

UIZhuanResult.timerKey = nil;
UIZhuanResult.time = 30;

function UIZhuanResult:Create()
	self:AddSWF("zhuanshengResult.swf",true,"center")
end;

function UIZhuanResult:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;
end;

function UIZhuanResult:OnShow()
	self:Initinfo();
	self:SetAtb();
	local objSwf = self.objSwf;
	objSwf.wan_fpx:gotoAndPlay(1);
	self:SetZhuanChengMc();
	self:SetCloseBtnTxt();
end;

function UIZhuanResult:SetCloseBtnTxt()
	local objSwf  = self.objSwf;
	local stype = ZhuanModel:GetZhuanType()
	if stype == 0  then stype = 1 end;
	objSwf.closebtn.label = StrConfig["zhuansheng01"..stype + 2]
end;

function UIZhuanResult:OnHide()
	ZhuanContoller:OutZhuan()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil; 
	end;
end;

function UIZhuanResult:SetZhuanChengMc()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local stype = ZhuanModel:GetZhuanType()
	if stype == 0  then stype = 1 end;
	objSwf.zhuanshengDesc_mc:gotoAndStop(stype)
end

function UIZhuanResult:GetWidth()
	return 940;
end

function UIZhuanResult:GetHeight()
	return 400;
end

function UIZhuanResult:Initinfo()
	local objSwf = self.objSwf;
	self.time = 30
	objSwf.outTime_txt.htmlText = string.format(StrConfig["zhuansheng006"],self.time)
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function()self:Ontimer()end,1000,self.time);

end;

function UIZhuanResult:Ontimer()
	if not self.bShowState then return; end
	self.time = self.time - 1;
	local objSwf = self.objSwf;
	objSwf.outTime_txt.htmlText = string.format(StrConfig["zhuansheng006"],self.time)
	if self.time <= 0 then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
		self:Hide();
	end;
end;

function UIZhuanResult:SetAtb()
	local objSwf = self.objSwf;
	local stype = ZhuanModel:GetZhuanType()
	if stype == 0 then stype = 1 end;
	--print(stype,'---------------')
	local atb = t_zhuansheng[stype];
	objSwf.fight.num = atb.addFight
	local str = AttrParseUtil:Parse(atb.attr);
	local html0 = "";
	local html1 = "";
	for i,info in pairs(str) do 
		local name = enAttrTypeName[info.type]; 
		local val = i % 2;
		if val == 0 then 
			html0 =  html0.."<font color='#D5B772'>"..name.."<font/><font color='#29cc00'>+ "..info.val.."</font><br/>"
		else
			html1 =  html1.."<font color='#D5B772'>"..name.."<font/><font color='#29cc00'>+ "..info.val.."</font>         "
		end;
	end;
	objSwf.atb_txt0.htmlText = html0;
	objSwf.atb_txt1.htmlText = html1;
end;

