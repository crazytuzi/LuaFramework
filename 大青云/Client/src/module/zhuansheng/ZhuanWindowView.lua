--[[
转生
wangshuai
]]

_G.UIZhuanWindow = BaseUI:new("UIZhuanWindow")

UIZhuanWindow.isAutoing = false;
UIZhuanWindow.timerKey = nil;

function UIZhuanWindow:Create()
	self:AddSWF("zhuanshengWindopanel.swf",true,"center")
end;

function UIZhuanWindow:OnLoaded(objSwf)
	objSwf.gobtn.click = function() self:GuajiClick();end;
	--objSwf.guaji_btn.click = function() self:GuajiClick()end;
	objSwf.out_btn.click = function() self:OutClick()end;
end;


function UIZhuanWindow:Initinfo()
	local objSwf = self.objSwf;
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(function()self:Ontimer()end,5000,1);

end;

function UIZhuanWindow:SetbgStype()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local stype = ZhuanModel:GetZhuanType()
	stype = stype + 1;
	objSwf.bg:gotoAndStop(stype);
end;

function UIZhuanWindow:SetProXy()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local stype = ZhuanModel:GetZhuanType()
	stype = stype + 1;
	objSwf.pro_mc._y = ZhuanModel.proXylist[stype].y;
end;

function UIZhuanWindow:Ontimer()
	self:GuajiClick();
end;

function UIZhuanWindow:OnShow()
	local objSwf = self.objSwf;
	self:SetAtb();
	self:UpdataStep();
	self.isAutoing = false;
	--objSwf.guaji_btn.label = StrConfig['zhuansheng004'] 
	self:Initinfo();
	-- self:SetbgStype()
	-- self:SetProXy();
end;

function UIZhuanWindow:OnHide()
	self.isAutoing = false;
	if UIDungeonDialogBox:IsShow() then 
		UIDungeonDialogBox:Hide();
	end;
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
end;

function UIZhuanWindow:OutClick()
	ZhuanZhiController:AskOutDup()
end;

function UIZhuanWindow:GuajiClick()
	self.isAutoing = true
	self:GoStepClick()
end;

function UIZhuanWindow:GoStepClick()
	local id = ZhuanModel:GetZhuanCopyid()
	local cfg = t_dunstep[id];
	local pcfg = split(cfg.goals1,",");
	local leng = #pcfg
	local pos = t_position[toint(pcfg[leng])].pos;
	local mapid = CPlayerMap:GetCurMapID();
	local point = split(pos,",");
	local completeFuc = function()
		if cfg.type == 2 then 
			AutoBattleController:OpenAutoBattle();
		elseif cfg.type == 3 then 
			UIDungeonDialogBox:Open( toint(pcfg[1]),  id,self.isAutoing)
		elseif cfg.type == 4 then 
			AutoBattleController:CloseAutoHang()
			local id = toint(pcfg[1])
			CollectionController:Collect(id)
		elseif cfg.type == 8 then 
		end;
	end
	MainPlayerController:DoAutoRun(mapid,_Vector3.new(point[2],point[3],0),completeFuc);

end;

function UIZhuanWindow:UpdataStep()
	local objSwf = self.objSwf;
	local id = ZhuanModel:GetZhuanCopyid()
	local cfg = t_dunstep[id];
	if not cfg then 
		self:Hide();
	end;
	local html = '';
	html = html .."<u>".. cfg.trackInfo2 .."</u></br>";
	local numCfg = AttrParseUtil:ParseAttrToMap(cfg.targetNum)
	for i,info in pairs(numCfg) do 
		local num = ZhuanModel:GetMonsterNum(i);
		if num then 
			local mCfg = t_monster[i]
			local name = '';
			if mCfg then 
				name = mCfg.name;
			end;
			local str = ""
			if num >= info then 
				--29cc
				str = "<font color='#29cc00'>"..name.. "(" .. num .."/".. info ..")</font></br>"
			else
				--ff
				str = "<font color='#ff0000'>"..name.. "(" .. num .."/".. info ..")</font></br>"
			end;
			html = html .. str;
		end;
	end;
	local num = numCfg[2];
	local monsCfg = t_monster[numCfg[1]];

	objSwf.desc_txt.htmlText = html;

	objSwf.pro_mc.maximum = 100
	--print(cfg.process,'--------------哈哈哈哈哈')
	objSwf.pro_mc.value = cfg.process;
end;

function UIZhuanWindow:SetAtb()
	local objSwf = self.objSwf;
	local stype = ZhuanZhiModel:GetLv()
	stype = stype + 1;
	--if stype == 0 then stype = 1 end;
	--print(stype,'---------------')
	local atb = t_transferattr[stype];
	if not atb then
		return
	end
	--objSwf.fight.num = atb.addFight
	local html0 = "";
	local html1 = "";
	if atb.attr then
		local str = AttrParseUtil:Parse(atb.attr);
		for i,info in pairs(str) do 
			local name = enAttrTypeName[info.type]; 
			local val = i % 2;
			if val == 0 then 
				html0 =  html0.."<font color='#D5B772'>"..name.."<font/><font color='#29cc00'>+ "..info.val.."</font><br/>"
			else
				html1 =  html1.."<font color='#D5B772'>"..name.."<font/><font color='#29cc00'>+ "..info.val.."</font><br/>"
			end;
		end;
	end
	objSwf.atb_txt0.htmlText = html0;
	objSwf.atb_txt1.htmlText = html1;
end;



function UIZhuanWindow:GetWidth()
	return 300
end

function UIZhuanWindow:GetHeight()
	return 300
end