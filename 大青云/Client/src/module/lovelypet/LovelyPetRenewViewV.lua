--[[萌宠续费面板
zhangshuhui
2015年6月22日11:41:11
]]

_G.UILovelyPetRenewViewV = BaseUI:new("UILovelyPetRenewViewV")

UILovelyPetRenewViewV.timerKey = nil;

UILovelyPetRenewViewV.lovelypetid = 0;

UILovelyPetRenewViewV.lovelypettime = 0;

function UILovelyPetRenewViewV:Create()
	self:AddSWF("lovelypetRenewPanelV.swf", true, "top")
end

function UILovelyPetRenewViewV:OnLoaded(objSwf,name)
	--关闭
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	
	--续费
	objSwf.btnrenew.click = function() self:OnBtnRenewClick() end
	
	--取消
	objSwf.btncancel.click = function() self:OnBtnCancelClick() end
	
	objSwf.btnRadioTool.rollOver = function() self:OnBtnToolRollOver(); end
	objSwf.btnRadioTool.rollOut  = function() TipsManager:Hide(); end
end

function UILovelyPetRenewViewV:OnShow(name)
	--初始化数据
	self:InitData();
	--计时器
	self:StartTimer();
	--显示
	self:ShowLovelyPetRenewInfo();
end

function UILovelyPetRenewViewV:OnHide()
	self:DelTimerKey();
	
	self.posX 		= nil;
	self.posY		= nil;
end

function UILovelyPetRenewViewV:GetWidth()
	return 277;
end

--点击关闭按钮
function UILovelyPetRenewViewV:OnBtnCloseClick()
	self:Hide();
end

--点击续费按钮
function UILovelyPetRenewViewV:OnBtnRenewClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local lovelypetcfg = t_lovelypet[self.lovelypetid];
	if not lovelypetcfg then
		return;
	end
	
	local renewtype = 0;
	
	local constomList = split(lovelypetcfg.renewconstom,"#");
	for i,constomStr in ipairs(constomList) do
		local constomvo = split(constomStr,",");
		local type = tonumber(constomvo[1]);
		local itemid = tonumber(constomvo[2]);
		local count = tonumber(constomvo[3]);
		
		--元宝
		if objSwf.btnRadioMoney.selected == true and type == 1 then
			renewtype = 1;
			local playerinfo = MainPlayerModel.humanDetailInfo;
			if playerinfo.eaUnBindMoney < count then
				FloatManager:AddNormal( StrConfig["lovelypet9"], objSwf.btnrenew);
				return;
			end
		--道具
		elseif objSwf.btnRadioTool.selected == true and type == 2 then
			renewtype = 2;
			local intemNum = BagModel:GetItemNumInBag(itemid);
			if intemNum < count then
				FloatManager:AddNormal( StrConfig["lovelypet8"], objSwf.btnrenew);
				return;
			end
		end		
	end
	
	if renewtype == 0 then
		return;
	end
	
	LovelyPetController:ReqRenewLovelyPet(self.lovelypetid, renewtype);
	self:Hide();
end

--点击取消按钮
function UILovelyPetRenewViewV:OnBtnCancelClick()
	self:Hide();
end

function UILovelyPetRenewViewV:OnBtnToolRollOver()
	local lovelypetcfg = t_lovelypet[self.lovelypetid];
	if not lovelypetcfg then
		return;
	end
	
	local constomList = split(lovelypetcfg.renewconstom,"#");
	for i,constomStr in ipairs(constomList) do
		local constomvo = split(constomStr,",");
		local type = tonumber(constomvo[1]);
		local itemid = tonumber(constomvo[2]);
		local count = tonumber(constomvo[3]);
		
		if type == 2 then
			TipsManager:ShowItemTips(itemid);
			break;
		end
	end
end

function UILovelyPetRenewViewV:InitData()
	self.lovelypettime = 0;
	
	--非战斗状态不倒计时
	local id, state = LovelyPetUtil:GetCurLovelyPetState(self.lovelypetid);
	if state == LovelyPetConsts.type_fight then
		local lovelypettime,servertime = LovelyPetUtil:GetLovelyPetTime(self.lovelypetid);
		self.lovelypettime = lovelypettime - (GetServerTime()-servertime);
	elseif state == LovelyPetConsts.type_rest then
		local lovelypettime,servertime = LovelyPetUtil:GetLovelyPetTime(self.lovelypetid);
		self.lovelypettime = lovelypettime;
	end
end

function UILovelyPetRenewViewV:Open()
	if self:IsShow() then
		self:InitData();
		self:ShowLovelyPetRenewInfo();
	else
		self:Show();
	end
end

--显示信息
function UILovelyPetRenewViewV:ShowLovelyPetRenewInfo()
	self:ShowRemainTime();
	self:ShowRenewInfo();
	self:ShowRenewToolInfo();
end

--显示续费道具
function UILovelyPetRenewViewV:ShowRenewToolInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local lovelypetcfg = t_lovelypet[self.lovelypetid];
	if not lovelypetcfg then
		return;
	end
	
	local constomList = split(lovelypetcfg.renewconstom,"#");
	for i,constomStr in ipairs(constomList) do
		local constomvo = split(constomStr,",");
		local type = tonumber(constomvo[1]);
		local itemid = tonumber(constomvo[2]);
		local count = tonumber(constomvo[3]);
		
		--元宝
		if type == 1 then
			local playerinfo = MainPlayerModel.humanDetailInfo;
			if playerinfo.eaUnBindMoney < count then
				objSwf.btnmoney.htmlLabel = string.format( StrConfig["lovelypet23"], count);
			else
				objSwf.btnmoney.htmlLabel = string.format( StrConfig["lovelypet22"], count);
			end
			objSwf.btnRadioMoney.htmlLabel = "";
		--道具
		elseif type == 2 then
			local itemvo = t_item[itemid];
			local intemNum = BagModel:GetItemNumInBag(itemid);
			if intemNum < count then
				objSwf.btntool.htmlLabel = string.format( StrConfig["lovelypet15"], itemvo.name.."*"..count);
			else
				objSwf.btntool.htmlLabel = string.format( StrConfig["lovelypet14"], itemvo.name.."*"..count);
			end
			objSwf.btnRadioTool.htmlLabel = "";
		end
	end
end

--显示续费时间
function UILovelyPetRenewViewV:ShowRenewInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.tftime.text = "";
	
	local lovelypetvo = t_lovelypet[self.lovelypetid];
	if not lovelypetvo then
		return;
	end
	
	objSwf.tftime.text = string.format( StrConfig["lovelypet7"], lovelypetvo.renew_time / 60 / 24);
end

--显示剩余时间
function UILovelyPetRenewViewV:ShowRemainTime()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.tfpasstime._visible = false;
	objSwf.tftimetitle._visible = false;
	objSwf.tfdaojishi.text = "";
	
	local state = LovelyPetUtil:GetLovelyPetState(self.lovelypetid);
	if state == LovelyPetConsts.type_notactive then
		return;
	elseif state == LovelyPetConsts.type_passtime then
		objSwf.tfpasstime._visible = true;
		return;
	end
	
	objSwf.tftimetitle._visible = true;
	local str = "";
	local day,t,s,m  = self:GetTime(self.lovelypettime);
	local daynum = toint(day);
	if daynum > 0 then
		if daynum >= 10 then
			str = string.format( StrConfig["lovelypet24"], day,t,s);
		else
			str = string.format( StrConfig["lovelypet6"], day,t,s,m);
		end
	else
		str = string.format( StrConfig["lovelypet3"], t,s,m);
	end
	objSwf.tfdaojishi.text = str;
end


function UILovelyPetRenewViewV:StartTimer()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.OnTimer,1000,0);
end

function UILovelyPetRenewViewV:DelTimerKey()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil;
	end
end

--计时器
function UILovelyPetRenewViewV:OnTimer()
	--非战斗状态不倒计时
	local state = LovelyPetUtil:GetLovelyPetState(UILovelyPetRenewViewV.lovelypetid);
	if state ~= LovelyPetConsts.type_fight then
		return;
	end
	
	UILovelyPetRenewViewV.lovelypettime = UILovelyPetRenewViewV.lovelypettime - 1;
	
	if UILovelyPetRenewViewV.lovelypettime < 0 then
		UILovelyPetRenewViewV.lovelypettime = 0;
	end
	
	UILovelyPetRenewViewV:ShowRemainTime();
end;

function UILovelyPetRenewViewV:GetTime(time)
	if not time then return end;
	if time <= 0 then return "00","00","00","00" end;
	local ti = time / 60 -- 分
	local tim = (ti % 1)*60 + 0.1
	local m = toint(tim)
	if m < 10 then 
		m = "0"..m
	end;
	local s = toint(ti)
	local t = 0;
	local day = 0;
	if s >= 60 then 
		t = toint(s/60);
		s = s%60;
		if t > 24 then
			day = toint(t/24);
			t = toint(t%24);
		end
	end;

	if s < 10 then 
		s = "0"..s
	end;

	if t < 10 then 
		t = "0"..t;
	end;

	return day,t,s,m
end;

function UILovelyPetRenewViewV:Update( interval )
	if not self.bShowState then return; end
	if not self.parent then return; end
	if not self.parent:IsShow() then
		self:Hide();
		return;
	end
	
	local posX, posY = self.parent:GetPos();
	if self.posX ~= posX or self.posY ~= posY then
		self.posX, self.posY = posX, posY;
		self:SetPos(0, 0);
		self:Top();
	end
end

--处理消息
function UILovelyPetRenewViewV:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.BagItemNumChange then
		self:ShowRenewToolInfo();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaUnBindMoney then
			self:ShowRenewToolInfo();
		end
	elseif name == NotifyConsts.LovelyPetStateUpdata then
		self:ShowRemainTime();
	end
end

--监听消息
function UILovelyPetRenewViewV:ListNotificationInterests()
	return {NotifyConsts.BagItemNumChange,NotifyConsts.PlayerAttrChange,
			NotifyConsts.LovelyPetStateUpdata};
end
