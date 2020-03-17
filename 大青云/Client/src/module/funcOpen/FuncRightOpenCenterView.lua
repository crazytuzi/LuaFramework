--[[
功能即将开启中间展示
lizhuangzhuang
2015年9月14日16:35:11
]]

_G.UIFuncRightOpenCenter = BaseUI:new("UIFuncRightOpenCenter");

UIFuncRightOpenCenter.funcId = nil;
UIFuncRightOpenCenter.modelDraw = nil;

function UIFuncRightOpenCenter:Create()
	self:AddSWF("funcRightOpenCenter.swf",true,"top");
end

function UIFuncRightOpenCenter:OnLoaded(objSwf)
	objSwf.centerPanel.hitTestDisable = true;
end

function UIFuncRightOpenCenter:GetWidth()
	return 613;
end

function UIFuncRightOpenCenter:GetHeight()
	return 612;
end

function UIFuncRightOpenCenter:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.args[1] then return; end
	self.funcId = self.args[1];
	local func = FuncManager:GetFunc(self.funcId);
	if not func then
		return;
	end
	if self.modelDraw then
		self.modelDraw:ExitCenter();
		self.modelDraw = nil;
	end
	if func:GetCfg().rightOpenModel == "" then return; end
	if _G[func:GetCfg().rightOpenModel] then
		self.modelDraw = _G[func:GetCfg().rightOpenModel];
		self.modelDraw:EnterCenter(objSwf.centerPanel)
	end
end

function UIFuncRightOpenCenter:OnHide()
	if self.modelDraw then
		self.modelDraw:ExitCenter();
		self.modelDraw = nil;
	end
	self.funcId = nil;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.centerPanel.nameloader:unload();
	objSwf.centerPanel.name2loader:unload();
end

