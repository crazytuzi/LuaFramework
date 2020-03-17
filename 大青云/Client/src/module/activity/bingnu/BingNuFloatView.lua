--[[
解救冰奴奖励漂浮
zhangshuhui
2015年3月5日11:16:01
]]

_G.UIBingNuFloat = BaseUI:new("UIBingNuFloat");

UIBingNuFloat.centerStartPos = 0;

function UIBingNuFloat:Create()
	self:AddSWF("bingnuFloat.swf",true,"float");
end

function UIBingNuFloat:OnLoaded(objSwf)
	objSwf.top.hitTestDisable = true;
	objSwf.bottom.hitTestDisable = true;
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.bottom._y = wHeight;
end

function UIBingNuFloat:OnResize(wWidth,wHeight)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.top._y = 100;
	objSwf.bottom._y = wHeight;
end

function UIBingNuFloat:GetWidth()
	return 700;
end

--显示屏幕中央的漂浮文字
function UIBingNuFloat:ShowCenter(text)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local wWidth,wHeight = UIManager:GetWinSize();
		
	local pos = {x=250,y=wHeight/2-100};
	local depth = objSwf.top:getNextHighestDepth();
	local mc = objSwf.top:attachMovie("bingnucenter",self:GetMcName(),depth);
	mc.tf.htmlText = text;
	mc._x = pos.x;
	mc._y = pos.y;
	mc._y = mc._y + self.centerStartPos*20;
	self.centerStartPos = self.centerStartPos + 1;
	
	if self.centerStartPos >= 3 then
		self.centerStartPos = 0;
	end
	Tween:To(mc,0.4,{_y=mc._y-20},{
		onComplete = function()
			TimerManager:RegisterTimer(function()
				Tween:To(mc,0.5,{_y=mc._y-80,_alpha=0},{
					onComplete = function()
						mc:removeMovieClip();
						mc = nil;
						self.centerStartPos = 0;
					end});
			end,500,1);
		end});
end

--显示小 大 小 公告
function UIBingNuFloat:ShowSBSActivity(text,time)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local depth = objSwf.bottom:getNextHighestDepth();
	local mc = objSwf.bottom:attachMovie("activityInfo",self:GetMcName(),depth);
	mc.tf.htmlText = text;
	mc.tf._height = mc.tf.textHeight + 5;
	--
	local scale = 30;
	local endX,endY = 0,-300;
	local startX = 0;
	local startY = endY;
	--
	mc._x = startX;
	mc._y = startY;
	mc._alpha = 50;
	mc._xscale = scale;
	mc._yscale = scale;
	--
	Tween:To(mc,0.4,{_alpha = 100,_xscale=200,_yscale=200,_x=endX,_y=endY,ease=Back.easeInOut},{
		onComplete = function()
			Tween:To(mc,0.4,{_alpha = 100,_xscale=100,_yscale=100,_x=endX,_y=endY,ease=Back.easeInOut},{
				onComplete = function()
					TimerManager:RegisterTimer(function()
						Tween:To(mc,0.1,{_alpha=0},{
							onComplete = function()
								mc:removeMovieClip();
								mc = nil;
							end});
					end,500*time,1);
				end});
		end});
end

--显示活动内公告
function UIBingNuFloat:ShowActivity(text,time)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local depth = objSwf.bottom:getNextHighestDepth();
	local mc = objSwf.bottom:attachMovie("activityInfo",self:GetMcName(),depth);
	mc.tf.htmlText = text;
	mc.tf._height = mc.tf.textHeight + 5;
	--
	local scale = 30;
	local endX,endY = 0,-300;
	local startX = 0;
	local startY = endY + mc._height/2 + mc._height*scale/100/2;
	--
	mc._x = startX;
	mc._y = startY;
	mc._alpha = 50;
	mc._xscale = scale;
	mc._yscale = scale;
	--
	Tween:To(mc,0.3,{_alpha = 100,_xscale=200,_yscale=200,_x=endX,_y=endY,ease=Back.easeInOut},{
		onComplete = function()
			TimerManager:RegisterTimer(function()
				Tween:To(mc,0.2,{_alpha=0},{
					onComplete = function()
						mc:removeMovieClip();
						mc = nil;
					end});
			end,500*time,1);
		end});
end

UIBingNuFloat.mcIndex = 0;
function UIBingNuFloat:GetMcName()
	self.mcIndex = self.mcIndex + 1;
	return self.mcIndex;
end






UIBingNuFloat.effectIndex = 0;
--特效
UIBingNuFloat.effectMap = {};

--播放特效
function UIBingNuFloat:PlayEffect(url,pos,num,onComplete,layer)
	local vo = {};
	vo.url = url;
	vo.pos = pos;
	vo.times = 1;
	vo.num = num;
	local id = nil;
	vo.completeCallBack = function()
		if id then
			self:RemoveEffect(id);
		end
		if onComplete then
			onComplete();
			onComplete = nil
		end
	end
	if not layer then layer = "float"; end
	id = self:PlayEffectByVO(vo,layer);
end

--第几轮特效
function UIBingNuFloat:PlayDiJiLunEffect(num,onComplete,layer)
	local winW,winH = UIManager:GetWinSize();
	local pos = {};
	pos.x = winW/2;
	pos.y = winH/2 - 100;
	local vo = {};
	vo.url = ResUtil:GetDiJiLunUrl();
	vo.pos = pos;
	vo.times = 1;
	vo.num = num;
	local id = nil;
	vo.completeCallBack = function()
		if id then
			self:RemoveEffect(id);
		end
		if onComplete then
			onComplete();
			onComplete = nil
		end
	end
	if not layer then layer = "float"; end
	id = self:PlayEffectByVO(vo,layer);
end


--根据VO播放特效
--[[
VO:
	url:特效路径
	pos:播放位置(全局坐标)
	times:播放次数
	completeCallBack:完成回调
]]
--@return 特效标示,特效UILoader
function UIBingNuFloat:PlayEffectByVO(vo,layerName)
	if not vo.url then return; end
	if not vo.pos then return; end
	if not vo.times then
		vo.times = 1;
	end
	local layer = UIManager:GetLayer(layerName);
	if not layer then
		print("Error:Error layer to play effect!");
		return;
	end
	local depth = layer:getNextHighestDepth();
	local id = self:GetNewEffectId();
	local loader = layer:attachMovie("UILoader",id,depth);
	UILoaderManager:LoadList({vo.url},function()
		loader.source = vo.url;
		loader._x = vo.pos.x;
		loader._y = vo.pos.y;
		loader.loaded = function()
			local effect = loader.content.effect;
			if not effect then return; end
			if effect._x~=0 then effect._x=0; end
			if effect._y~=0 then effect._y=0; end
			if effect.toString then
				local effectClz = effect:toString();
				if effectClz=="UIEffect" or effectClz=="SwfEffect" then
					if vo.completeCallBack then
						if not effect.complete then
							effect.complete = function()
								vo.completeCallBack();
								vo.completeCallBack = nil
							end
						end
					end
					if effect.initialized then
						effect.numpanel.numloader.num = vo.num;
						effect:playEffect(vo.times);
					else
						effect.init = function()
							effect.numpanel.numloader.num = vo.num;
							effect:playEffect(vo.times);
						end
					end
					return;
				end
			end
			effect:gotoAndPlay(1);
			print('Waring:未知的特效文件,url:',vo.url);
		end
	end);
	self.effectMap[id] = loader;
	return id,loader;
end

--停止特效
function UIBingNuFloat:StopEffect(id)
	if self.effectMap[id] then
		local loader = self.effectMap[id];
		local effect = loader.content.effect;
		if not effect then return; end
		if effect.StopEffect then
			effect:StopEffect();
		end
	end
end

--移除特效
function UIBingNuFloat:RemoveEffect(id)
	if not self.effectMap[id] then return; end
	self:StopEffect(id);
	local loader = self.effectMap[id];
	loader.source = nil 
	loader:removeMovieClip();
	self.effectMap[id] = nil;
end

--获取一个新特效id
function UIBingNuFloat:GetNewEffectId()
	self.effectIndex = self.effectIndex + 1;
	return self.effectIndex;
end