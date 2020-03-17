--[[
转生开启Button
wangshuai
]]

_G.UIZhuanshOpen = BaseUI:new("UIZhuanshOpen");

function UIZhuanshOpen:Create()
	self:AddSWF("zhuanshengButton.swf",true,"bottom2");
end

function UIZhuanshOpen:OnLoaded(objSwf)
	-- objSwf.zhuansheng_mc.click = function() self:OnZhuanOpenView() end;
	-- objSwf.zhuansheng_mc.rollOver = function() self:OnZhuanOpenOver(); end
	-- objSwf.zhuansheng_mc.rollOut = function() TipsManager:Hide(); end
	objSwf.Zhuan1.zhuansheng_btn.click = function() self:OnZhuanOpenView(); end
	objSwf.Zhuan1.zhuansheng_btn.rollOver = function() self:OnZhuanOpenOver(); end
	objSwf.Zhuan1.zhuansheng_btn.rollOut = function() TipsManager:Hide(); end
	objSwf.Zhuan1.zhuan_fpx.hitTestDisable = true;
	objSwf.Zhuan1.zhuansheng_fpx.hitTestDisable = true;
	objSwf.Zhuan1.btntxt_mc.hitTestDisable = true;
	objSwf.Zhuan1.img_visi.hitTestDisable = true;



	objSwf.Zhuan2.zhuaner_btn.click = function() self:OnZhuanOpenView(); end
	objSwf.Zhuan2.zhuaner_btn.rollOver = function() self:OnZhuanOpenOver(); end
	objSwf.Zhuan2.zhuaner_btn.rollOut = function() TipsManager:Hide(); end
	objSwf.Zhuan2.isPlayMc.hitTestDisable = true;
	objSwf.Zhuan2.erzhuan_fpx.hitTestDisable = true;

	objSwf.Zhuan3.zhuansan_btn.click = function() self:OnZhuanOpenView(); end
	objSwf.Zhuan3.zhuansan_btn.rollOver = function() self:OnZhuanOpenOver(); end
	objSwf.Zhuan3.zhuansan_btn.rollOut = function() TipsManager:Hide(); end
	objSwf.Zhuan3.sanzhuan_fpx.hitTestDisable = true;
	objSwf.Zhuan3.zhuanOpen_fpx.hitTestDisable = true;




	self:ShowJianFpx(false)
	self:ShowSanZhuanFpx(false)
	objSwf.Zhuan1.zhuan_fpx.playOver = function() self:FpxOver()end;
	objSwf.Zhuan2.erzhuan_fpx.playOver = function() self:ErzhaunOver()end;
	objSwf.Zhuan3.zhuanOpen_fpx.playOver = function() self:SanZhaunFpxOver() end;

	objSwf.btn_Hide.click = function() self:SetZhuanBtnState() end;
	objSwf.btn_Hide.rollOver = function() self:BtnHideOver() end;
	objSwf.btn_Hide.rollOut  = function() TipsManager:Hide() end;
end

UIZhuanshOpen.isShowBtn = true

function UIZhuanshOpen:BtnHideOver()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if self.isShowBtn then 
		TipsManager:ShowBtnTips(StrConfig["zhuansheng022"],TipsConsts.Dir_RightDown);
	else
		TipsManager:ShowBtnTips(StrConfig["zhuansheng023"],TipsConsts.Dir_RightDown);
	end;
end;

function UIZhuanshOpen:SetZhuanBtnState()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local stype = ZhuanModel:GetZhuanType();
	stype = stype + 1;
	for i=1,3 do
		if objSwf['Zhuan'..i] then 
			if i == stype then 
				objSwf['Zhuan'..i]._visible = not self.isShowBtn;
				objSwf['Zhuan'..i].hitTestDisable = self.isShowBtn;
			end;
		end;
	end;
	self.isShowBtn = not self.isShowBtn
end;

------------------------------------------------------
------------------------通用------------------------------

function UIZhuanshOpen:GetWidth()
	return 330;
end

function UIZhuanshOpen:GetHeight()
	return 70;
end

function UIZhuanshOpen:SetZhuanBtn()
	local objSwf = self.objSwf;
	local stype = ZhuanModel:GetZhuanType();
	stype = stype + 1;
	for i=1,3 do
		if objSwf['Zhuan'..i] then 
			if i == stype then 
				objSwf['Zhuan'..i]._visible = true;
				objSwf['Zhuan'..i].hitTestDisable = false;
			else
				objSwf['Zhuan'..i]._visible = false;
				objSwf['Zhuan'..i].hitTestDisable = true;
			end;
		end;
	end;
end;

function UIZhuanshOpen:SetCanZhuan()
	local objSwf = self.objSwf;
	local stype = ZhuanModel:GetZhuanType()
	stype = stype + 1;
	local cfg = t_zhuansheng[stype];
	if not cfg then 
		print("ERROR zhuanshengType is ",stype)
		return 
	end;
	local myLevel = MainPlayerModel.humanDetailInfo.eaLevel; 
	if myLevel >= cfg.level  then 
		objSwf.Zhuan1.zhuansheng_fpx._visible =true;
		objSwf.Zhuan2.isPlayMc._visible = true;
		objSwf.Zhuan3.sanzhuan_fpx._visible = true;
	else
		objSwf.Zhuan1.zhuansheng_fpx._visible =false;
		objSwf.Zhuan2.isPlayMc._visible = false;
		objSwf.Zhuan3.sanzhuan_fpx._visible = false;
	end;
end

function UIZhuanshOpen:OnZhuanOpenOver()
	local stype = ZhuanModel:GetZhuanType()
	stype = stype + 1;
	local cfg = t_zhuansheng[stype];
	if not cfg then 
		cfg = t_zhuansheng[ZhuanModel:GetZhuanType()];
	end;
	TipsManager:ShowBtnTips(string.format(cfg.tips,cfg.addFight),TipsConsts.Dir_RightDown);
end;

function UIZhuanshOpen:OnShow()
	if self.args[1] then 
		self:PlayFpx()
	end;
	self:SetCanZhuan();
	self:SetZhuanBtn();
end

function UIZhuanshOpen:UpdataUiData()
	self:SetCanZhuan();
	self:SetZhuanBtn();
end;

function UIZhuanshOpen:OnHide()
	self:ShowJianFpx(false)
	self:ShowSanZhuanFpx(false)
end;

function UIZhuanshOpen:PlayFpx()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local stype = ZhuanModel:GetZhuanType()
	stype = stype + 1;
	if stype == 1 then 
		self:ShowJianFpx(true)
		objSwf.Zhuan1.zhuansheng_btn._visible = false;
		objSwf.Zhuan1.btntxt_mc._visible = false;
	elseif stype == 2 then 
		self:ShowErZhuanFpx(true);
	elseif stype == 3 then 
		self:ShowSanZhuanFpx(true)
	end;
end;

function UIZhuanshOpen:OnZhuanOpenView()
	if UIZhuanSheng:IsShow() then 
		UIZhuanSheng:Hide();
	else
		UIZhuanSheng:Show();
	end;
end;

	-- notifaction
function UIZhuanshOpen:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		}
end;
function UIZhuanshOpen:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then 
			self:SetCanZhuan();
		elseif body.type == enAttrType.eaZhuansheng then 
		
			self:SetCanZhuan();
		end;
	end;
end;

-------------------------------------------------
-------------------------------------------------
--1转
function UIZhuanshOpen:FpxOver()
	self:ShowJianFpx(false)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.Zhuan1.zhuansheng_btn._visible = true;
	objSwf.Zhuan1.btntxt_mc._visible = true;
end;

function UIZhuanshOpen:ShowJianFpx(bo)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if bo then --播放
		objSwf.Zhuan1.zhuan_fpx._visible = true;
		local wWidth, wHeight = UIManager:GetWinSize()
		if  wHeight > 900 then  
			objSwf.Zhuan1.zhuan_fpx:gotoAndPlay(1)
		else
			objSwf.Zhuan1.zhuan_fpx:gotoAndPlay(6)
		end;
	else
		objSwf.Zhuan1.zhuan_fpx._visible = false;
		objSwf.Zhuan1.zhuan_fpx:gotoAndStop(1)
	end;
end;

---------------二转
function UIZhuanshOpen:ShowErZhuanFpx(bo)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if bo then --播放
		objSwf.Zhuan2.erzhuan_fpx._visible = true;
		objSwf.Zhuan2.erzhuan_fpx:gotoAndPlay(2)
	else
		objSwf.Zhuan2.erzhuan_fpx._visible = false;
		objSwf.Zhuan2.erzhuan_fpx:gotoAndStop(1)
	end;
end;

function UIZhuanshOpen:ErzhaunOver()
	
	self:ShowErZhuanFpx(false)
end;

---------------------三转erzhuan_fpx
function UIZhuanshOpen:ShowSanZhuanFpx(bo)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if bo then --播放
		objSwf.Zhuan3.zhuanOpen_fpx._visible = true;
		objSwf.Zhuan3.zhuanOpen_fpx:gotoAndPlay(2)
	else
		objSwf.Zhuan3.zhuanOpen_fpx._visible = false;
		objSwf.Zhuan3.zhuanOpen_fpx:gotoAndStop(1)
	end;
end;

function UIZhuanshOpen:SanZhaunFpxOver()
	
	self:ShowSanZhuanFpx(false)
end;


