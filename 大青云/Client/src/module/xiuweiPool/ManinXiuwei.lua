--[[
修为池--主界面
]]
_G.UIMainXiuweiPool = BaseUI:new("UIMainXiuweiPool")
UIMainXiuweiPool.isDanyao = false
function UIMainXiuweiPool:Create()
	self:AddSWF("mainXiuweiPool.swf",true,'interserver')
end;

function UIMainXiuweiPool:OnLoaded(objSwf)
	objSwf.touch._visible = false
	objSwf.mcNum._visible = false
	objSwf.xiuweiChi_pro._visible = false
	objSwf.precent._visible = false
	objSwf.xiuweiChi_pro.fullEffect1._visible = false
	objSwf.xiuweiChi_pro.fullEffect2._visible = false
	objSwf.touch.click = function() self:OnBtnTouchClick() end;
	objSwf.touch.rollOver = function() self:RuleTips() end;
	objSwf.touch.rollOut = function() TipsManager:Hide() end;
end;

function UIMainXiuweiPool:OnShow()
	self:IsShow()
	self:UpdataUI();
	self:InintRedPoint();
	self:RegisterTimes();
end;

UIMainXiuweiPool.timekey = nil;
function UIMainXiuweiPool:RegisterTimes( )
	self.timekey = TimerManager:RegisterTimer(function()
		self:InintRedPoint()
	end,1000,0); 
end

function UIMainXiuweiPool:InintRedPoint( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	--可炼丹次数
	local cfg = t_xiuwei[1];
	if not cfg then 
		return 
	end;

	local curVal = XiuweiPoolModel:GetXiuwei();
	local decrease = cfg.decrease;
	local full = cfg.full;
	--单次境界修为的储存上限，要根据境界的阶进行提升
	local jjCfg = t_jingjie[RealmModel.realmOrder]
	if not jjCfg then 
		return 
	end;
	local maxVal = jjCfg.save_xiuweizhi;
	local precentFin1 = curVal/maxVal
	local precentFin = math.floor(precentFin1*100)
	objSwf.precent.htmlText =  string.format(StrConfig['xiuweiPool22'],precentFin)
	
	
	if curVal >= full and XiuweiPoolController:IsOpen() then
		objSwf.mcNum._visible = true
		if RealmUtil:GetIsFullProgress() == true then
			objSwf.mcNum._visible = false
		end
	else
		objSwf.mcNum._visible = false
	end
end
function UIMainXiuweiPool:IsShow()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if XiuweiPoolController:IsOpen() then
		objSwf.touch._visible = true
		objSwf.xiuweiChi_pro._visible = true
		objSwf.precent._visible = true
	else
	end
end;

-- 修为球的悬浮tips
function UIMainXiuweiPool:RuleTips()
	local cfg = t_xiuwei[1];
	if not cfg then 
		return 
	end;
	--单次境界修为的储存上限，要根据境界的阶进行提升
	local jjCfg = t_jingjie[RealmModel.realmOrder]
	if not jjCfg then 
		return 
	end;
	local max_current = jjCfg.save_xiuweizhi;
	local curVal = XiuweiPoolModel:GetXiuwei();
	local str = string.format( StrConfig['xiuweiPool08'], curVal,max_current)
	TipsManager:ShowTips( TipsConsts.Type_Normal, str, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end;

function UIMainXiuweiPool:UpdataUI()
	--经验池
	self:SetXiuweiChiVal();
	
end;
function UIMainXiuweiPool:OnBtnTouchClick()
	TipsManager:Hide();
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not UIRealmMainView:IsShow() then
		UIRealmMainView:Show();
	else
		UIRealmMainView:Hide();
	end
end

function UIMainXiuweiPool:OnHide()
	if self.timekey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end;

function UIMainXiuweiPool:SetXiuweiChiVal()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local cfg = t_xiuwei[1];
	if not cfg then 
		return 
	end;
	--单次境界修为的储存上限，要根据境界的阶进行提升
	local jjCfg = t_jingjie[RealmModel.realmOrder]
	if not jjCfg then 
		return 
	end;
	
	local hint_blink = cfg.hint_blink;
	local maxVal = jjCfg.save_xiuweizhi;
	local curVal = XiuweiPoolModel:GetXiuwei();
	
	--暂时屏蔽特效
	if curVal>=hint_blink then
		-- objSwf.xiuweiChi_pro.fullText._visible = true
		-- objSwf.xiuweiChi_pro.fullEffect1._visible = true
		-- objSwf.xiuweiChi_pro.fullEffect2._visible = true
	else
		-- objSwf.xiuweiChi_pro.fullText._visible = false
		objSwf.xiuweiChi_pro.fullEffect1._visible = false
		objSwf.xiuweiChi_pro.fullEffect2._visible = false
	end
	objSwf.xiuweiChi_pro.maximum = toint(maxVal)
  	objSwf.xiuweiChi_pro.value = toint(curVal);	

end;
function UIMainXiuweiPool:GetChiGlobalPos()
	local objSwf = self.objSwf;
	if not objSwf then return; end

	return UIManager:PosLtoG(objSwf, objSwf.touch._x, objSwf.touch._y);
end
------ 消息处理 ---- 
function UIMainXiuweiPool:ListNotificationInterests()
	return {
		NotifyConsts.XiuweiPoolUpdate,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.RealmProgress,
		}
end;
function UIMainXiuweiPool:HandleNotification(name,body)
	if name == NotifyConsts.XiuweiPoolUpdate or name == NotifyConsts.RealmProgress then 
		self:UpdataUI();
	elseif body.type == enAttrType.eaLevel then
		self:IsShow()
	end;
end;

function UIMainXiuweiPool:GetButton()
	if not self.objSwf then return nil; end
	return self.objSwf.touch;
end