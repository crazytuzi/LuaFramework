--[[
UI特效管理
lizhuangzhuang
2014年7月17日15:51:55
]]
_G.classlist['UIEffectManager'] = 'UIEffectManager'
_G.UIEffectManager = {}
_G.UIEffectManager.objName = 'UIEffectManager'
UIEffectManager.effectIndex = 0;
--特效
UIEffectManager.effectMap = {};

--播放特效
function UIEffectManager:PlayEffect(url,pos,onComplete,layer)
	local vo = {};
	vo.url = url;
	vo.pos = pos;
	vo.times = 1;
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
	if not layer then layer = "effect"; end
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
function UIEffectManager:PlayEffectByVO(vo,layerName)
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
						effect:playEffect(vo.times);
					else
						effect.init = function()
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
function UIEffectManager:StopEffect(id)
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
function UIEffectManager:RemoveEffect(id)
	if not self.effectMap[id] then return; end
	self:StopEffect(id);
	local loader = self.effectMap[id];
	loader.source = nil;
	loader:removeMovieClip();
	self.effectMap[id] = nil;
end

--获取一个新特效id
function UIEffectManager:GetNewEffectId()
	self.effectIndex = self.effectIndex + 1;
	return self.effectIndex;
end
