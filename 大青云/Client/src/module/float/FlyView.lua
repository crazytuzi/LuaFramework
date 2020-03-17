--[[
飞图标
lizhuangzhuang
2014年11月5日12:27:04
]]

_G.UIFly = BaseUI:new("UIFly");

UIFly.list = {};

function UIFly:Create()
	self:AddSWF("fly.swf",true,"float");
end

function UIFly:OnLoaded(objSwf)
	
end

function UIFly:Open(flyVO)
	if self:IsShow() then
		self:Fly(flyVO);
	else
		table.push(self.list,flyVO);
		self:Show();
	end
end

function UIFly:OnShow()
	for i,flyVO in ipairs(self.list) do
		self:Fly(flyVO);
	end
	self.list = {};
end

local tweenVec = _Vector2.new();
local tweenMat = _Matrix2D.new();
function UIFly:Fly(flyVO)
	if not self.objSwf then return; end
	local objSwf = self.objSwf;
	local depth = objSwf:getNextHighestDepth();
	local loader = objSwf:attachMovie("UILoader",self:GetMcName(),depth);
	loader.source = flyVO.url;
	loader._x = flyVO.startPos.x;
	loader._y = flyVO.startPos.y;
	local vars = {};
	vars._x = flyVO.endPos.x;
	vars._y = flyVO.endPos.y;
	if flyVO.tweenParam then
		for k,param in pairs(flyVO.tweenParam) do
			vars[k] = param;
		end
	end
	--
	local callbackVars = {};
	if flyVO.onUpdate then
		callbackVars.onUpdate = function()
			flyVO.onUpdate(loader);
		end
	end
	callbackVars.onComplete = function()
		loader.source = nil;
		loader:removeMovieClip();
		--print("我是大主宰++++++++++++")
		if flyVO.onComplete then
			flyVO.onComplete();
		end
		flyVO.onComplete = nil;
		flyVO.onUpdate = nil;
		flyVO.onStart = nil;
		flyVO.startPos = nil;
		flyVO.endPos = nil;
	end
	--
	loader.loaded = function()
		if flyVO.onStart then
			flyVO.onStart(loader);
		end
		Tween:To(loader,flyVO.time,vars,callbackVars);
	end
end


UIFly.mcIndex = 0;
function UIFly:GetMcName()
	self.mcIndex = self.mcIndex + 1;
	return self.mcIndex;
end