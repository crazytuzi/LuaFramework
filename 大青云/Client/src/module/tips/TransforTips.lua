_G.UITransforTips = BaseUI:new("UITransforTips");

UITransforTips.currShow=nil;
UITransforTips.defaultId=1;
function UITransforTips:Create()
	self:AddSWF("TianShenPanelTips.swf",true,"center");
end
function UITransforTips:OnLoaded(objSwf)

	
end
function UITransforTips:SetInfo()

	local objSwf = self.objSwf;
	if not objSwf then
		return; 
	end
	
	self:DrawDummy();
	-- self:StartTimer1();
	
	-- local tipsX,tipsY = TipsUtils:GetTipsPos(self:GetWidth(),self:GetHeight(),self.tipsDir);
	-- objSwf._x = 500;
	-- objSwf._y = 500;
end
function UITransforTips:GetWidth()
	return 764
end;
function UITransforTips:GetHeight()
	return 335
end

function UITransforTips:OnShow()
	self:SetInfo();
end
function UITransforTips:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then 
	   return; 
	end
	self:DisposeDummy();
end

local viewPort = nil;
function UITransforTips:DrawDummy()
	self:DisposeDummy();

	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1800, 1200); end
		self.objUIDraw = UISceneDraw:new( "UITransforTips", self.objSwf.avatarLoader, viewPort );
	end
	self.objUIDraw:SetUILoader(self.objSwf.avatarLoader);
	
	self.objUIDraw:SetScene("v_bs_leizhenzi_tips.sen",function() self:PlayAnimal(self.defaultId); end);
	
	self.objUIDraw:SetDraw(true);
end
function UITransforTips:PlayAnimal(roldId)
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.objUIDraw then return end

	local cfg = t_bianshenmodel[roldId]
	if not cfg then return end
	
	self.objUIDraw:NodeAnimation(cfg.skn_ui, cfg.bianshen_idle)
end
function UITransforTips:DisposeDummy()
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	end
end
function UITransforTips:ShowTips(tianshen)
	
	 if not tianshen then
	 	return;
	 end
	 self.currShow = tianshen
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end
function UITransforTips:IsTween()
	return true;
end
--执行缓动
function UITransforTips:DoTweenHide()
	local endX,endY;
	-- if self.tweenStartPos then
		-- endX = self.tweenStartPos.x;
		-- endY = self.tweenStartPos.y;
	-- else
	local pos = UIMainPageTianshen:GetAreaPos();
	
	local endX = pos.x;
	local endY = pos.y;

		-- endX = 0;
		-- endY = winH/2;
	-- end
	--
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- local mc = self.swfCfg.objSwf.content;			
	Tween:To(objSwf,0.45,{_alpha=0,_width=20,_height=20,_x=endX,_y=endY},
				{onComplete=function()
					self:DoHide();
					objSwf._xscale = 100;
					objSwf._yscale = 100;
					objSwf._alpha = 100;
				end},true);
end