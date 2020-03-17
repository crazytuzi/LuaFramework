--[[
	人物受到攻击时的挨打效果
	wwangshuai 
	2014年11月20日22:03:16；
]]


_G.UIBeatenAnimation = BaseUI:new("UIBeatenAnimation");

UIBeatenAnimation.num = 30; -- 低于百分比闪动
UIBeatenAnimation.hp = 0;
UIBeatenAnimation.hpmax = nil;
UIBeatenAnimation.curspeed = 15; --当前闪现速度
UIBeatenAnimation.curstate = nil;
UIBeatenAnimation.curWidth =0;
UIBeatenAnimation.curheight = 0;
UIBeatenAnimation.setisShow = false;

UIBeatenAnimation.isShowEffect = false;

function UIBeatenAnimation:Create()
	self:AddSWF("beatenAnimation.swf",true,"top")
end
function UIBeatenAnimation:OnLoaded(objSwf)
	objSwf.Animation2._visible = false;
	objSwf.Animation._visible = false;
	objSwf.hitTestDisable = true;
end;

function UIBeatenAnimation:NeverDeleteWhenHide()
	return true;
end

function UIBeatenAnimation:OnShow()
	if self.setisShow == true then 
		self:Hide();
		return ;
	end;
	self.hpmax = MainPlayerModel.humanDetailInfo.eaMaxHp;
	self.hp = MainPlayerModel.humanDetailInfo.eaHp;

	self.curWidth,self.curheight = UIManager:GetWinSize();
	--self:OnStatec();
	self:onBeating()

end
-- true == 关闭， false == 显示
function UIBeatenAnimation:OnSetIsShow(bo)
	self.setisShow = bo
	if self.setisShow == true then 
		self:StopAnimation()
	end;
end;

function UIBeatenAnimation:OnResize(wWidth,wHeight)
	self.curWidth = wWidth;
	self.curheight = wHeight;
	-- if self.isShowEffect == true then

	local objSwf = self.objSwf;
	if not objSwf then
		return
	end
	objSwf.Animation._width = wWidth;
	objSwf.Animation._height = wHeight;

	objSwf.Animation2._width = wWidth;
	objSwf.Animation2._height = wHeight;
	-- end;

end

function UIBeatenAnimation : OnStatec()
	if self.setisShow == true then 
		return 
	end;
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local baif = (self.hp/self.hpmax)*100;
	if baif < self.num then
		self.curstate = true;
		self.isShowEffect = true;
		objSwf.Animation2:setShan(true);
		objSwf.Animation2:setstate(self.curWidth-9,self.curheight,self.curstate,self.curspeed);
		return;
	elseif self.isShowEffect == true then 
		self.isShowEffect = false;
		objSwf.Animation:init();
		objSwf.Animation2:init();
	end
end;

function UIBeatenAnimation : onBeating()
	if self.setisShow == true then 
		return ;
	end;
	local objSwf = self.objSwf;
	--self.isShowEffect = false;
	self.curstate = false;
	objSwf.Animation:setstate(self.curWidth-9,self.curheight,self.curstate,self.curspeed);
	self.curstate = nil
end

function UIBeatenAnimation:StopAnimation()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.Animation:init();
	objSwf.Animation2:init();
	self:Hide();
end;

-- 消息
function UIBeatenAnimation : ListNotificationInterests()
	return{NotifyConsts.PlayerAttrChange}
end;
function UIBeatenAnimation:HandleNotification(name,body)
	if not self.bShowState then return end;
	if name == NotifyConsts.PlayerAttrChange then 
		if body.type == enAttrType.eaHp  then 
			self.hp = MainPlayerModel.humanDetailInfo.eaHp;
			self:OnStatec();
		end;
		if body.type == enAttrType.eaMaxHp then
			self.hpmax = MainPlayerModel.humanDetailInfo.eaMaxHp;
			self:OnStatec();
		end;
	end;
end;