--[[
	家园任务
	wangshuai
]]

_G.UIHomesMainQuest = BaseUI:new("UIHomesMainQuest")

UIHomesMainQuest.tabButton = {};

function UIHomesMainQuest:Create()
	self:AddSWF("homesteadMianQuestPanel.swf",true,nil)

	self:AddChild(UIHomesQuestIng,"ing");
	self:AddChild(UIHomesQuestList,"list");
end;

function UIHomesMainQuest:OnLoaded(objSwf)
	self:GetChild("ing"):SetContainer(objSwf.childPanel);
	self:GetChild("list"):SetContainer(objSwf.childPanel);

	--objSwf.close_btn.click = function() self:Hide()end;

	self.tabButton["ing"] = objSwf.questing_btn;
	self.tabButton["list"] = objSwf.questlist_btn;
	--self.tabButton["rod"] = objSwf.rodquest_btn;

	for name,btn in pairs(self.tabButton) do 
		btn.click = function() self:OnTabButtonClick(name);end;
	end;
end;

function UIHomesMainQuest:OnShow()
		--显示参数
	HomesteadController:ZongmengInfo()
	if self.args and #self.args > 0 then
		self:OnTabButtonClick(self.args[1].."")
	else
		self:OnTabButtonClick("list")
	end

end;

function UIHomesMainQuest:OnHide()

end;

function UIHomesMainQuest:OnTabButtonClick(name)
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
-- function UIHomesMainQuest:AutoSetPos()
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

