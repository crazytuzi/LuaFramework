--[[
	家园 选择view
	wangshuai
]]

_G.UIHomesteadSeleceView = BaseUI:new("UIHomesteadSeleceView")

UIHomesteadSeleceView.curVo = {};
UIHomesteadSeleceView.curBtnLenght = 4;
UIHomesteadSeleceView.vx = 0;
UIHomesteadSeleceView.vy = 0;
UIHomesteadSeleceView.namelist = {};


function UIHomesteadSeleceView:Create()
	self:AddSWF("homesteadSelectToolsView.swf",true,nil)
end;

function UIHomesteadSeleceView:OnLoaded(objSwf)
	for i=1,self.curBtnLenght do 
		objSwf["btn"..i].click = function() self:OnBtnClick(i) end;
	end;
end;

function UIHomesteadSeleceView:OnShow()
	self:UpdataUI();
end;

function UIHomesteadSeleceView:OnHide()

end;

function UIHomesteadSeleceView:UpdataUI()
	local objSwf = self.objSwf;
	for i,info in pairs(self.namelist) do 
		objSwf['btn'..i].label = info;
	end;
	for i=1,self.curBtnLenght do 
		local func = self.curVo.backList[i]
		if not func then 
			objSwf["btn"..i]._visible = false;
		else
			objSwf["btn"..i]._visible = true;
		end;
	end;

	objSwf._x = self.vx;
	objSwf._y = self.vy;
end;

function UIHomesteadSeleceView:OnBtnClick(type)
	local func = self.curVo.backList[type];
	func();
	self:Hide();
end;

--回调list
function UIHomesteadSeleceView:Open(backList,vx,vy,namelist)
	self.curVo = {};
	self.curVo.backList = backList;

	self.vx = vx;
	self.vy = vy;

	self.namelist = namelist;

	if self:IsShow() then 
		self:UpdataUI();
	else
		self:Show();
	end;
end;
