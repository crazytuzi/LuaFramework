--[[
	家园寻仙台主面板
	wangshuai
]]

_G.UIMainXunxian = BaseUI:new("UIMainXunxian")

UIMainXunxian.tabButton = {};

function UIMainXunxian:Create()
	self:AddSWF("homesteadMainXunxian.swf",true,nil)

	self:AddChild(UIHomesXunxian,"zhaomu");
	self:AddChild(UIHomesteadMyPupil,"pupil");
end;

function UIMainXunxian:OnLoaded(objSwf)
	--objSwf.close_btn.click = function() self:Hide()end;

	self:GetChild("zhaomu"):SetContainer(objSwf.childPanel);
	self:GetChild("pupil"):SetContainer(objSwf.childPanel);


	self.tabButton["zhaomu"] = objSwf.xunxian_btn;
	self.tabButton["pupil"] = objSwf.pupil_btn;
	for name,btn in pairs(self.tabButton) do 
		btn.click = function() self:OnTabButtonClick(name);end;
	end;
end;

function UIMainXunxian:OnShow()
	if self.args and #self.args > 0 then
		self:OnTabButtonClick(self.args[1][1].."")
	else
		self:OnTabButtonClick("zhaomu")
	end
	
end;

function UIMainXunxian:OnHide()

end;

function UIMainXunxian:OnTabButtonClick(name)
	if not self.tabButton[name] then
		return;
	end
	local child = self:GetChild(name);
	if not child then
		return;
	end
	self.tabButton[name].selected = true;
	self:ShowChild(name);
end;

-- -- 居中
-- function UIMainXunxian:AutoSetPos()
-- 	if self.parent == nil then return; end
-- 	if not self.isLoaded then return; end
-- 	if not self.swfCfg then return; end
-- 	if not self.swfCfg.objSwf then return; end
-- 	local objSwf = self.swfCfg.objSwf;

-- 	local Vx = toint(HomesteadConsts.MainViewWH.width / 2) - objSwf._width/2
-- 	local Vy = toint(HomesteadConsts.MainViewWH.height / 2) - objSwf._height/2
-- 	objSwf.content._x = Vx--toint(x or objSwf.content._x,  -1); 
-- 	objSwf.content._y = Vy--toint(y or objSwf.content._y, -1);
-- end;
