--[[
飞图标
lizhuangzhuang
2014年11月5日12:14:03
]]

_G.FlyManager = {};

--飞一个图标
--[[
FlyVO:
	url:图标路径(必须参数)
	startPos:起点(默认鼠标位置)
	endPos:终点(必须参数)
	time:飞行时间(默认1.5S)
	onStart:开始回调(UILoader)
	onComplete:完成回调
	onUpdate:update回调(UILoader)
	tweenParam:缓动的其他参数
]]
function FlyManager:FlyIcon(vo)
	if not vo.url then return; end
	if not vo.endPos then return; end
	if not vo.startPos then
		vo.startPos = _sys:getRelativeMouse();
	end
	if not vo.time then
		vo.time = 1.5;
	end
	UIFly:Open(vo);
end

--飞图标队列
--@param list 队列
--@param interval 队列中飞行间隔,毫秒
function FlyManager:FlyIconList(list,interval)
	if #list <=0 then return; end
	if interval and interval>0 then
		TimerManager:RegisterTimer(function()
			local vo = table.remove(list,1);
			if vo then
				self:FlyIcon(vo);
			end
		end,interval,#list);
	else
		for i,vo in ipairs(list) do
			self:FlyIcon(vo);
		end
	end
end

--飞特效
function FlyManager:FlyEffect(vo)
	if not vo.url then return; end
	if not vo.endPos then return; end
	if not vo.startPos then
		vo.startPos = _sys:getRelativeMouse();
	end
	if not vo.time then
		vo.time = 1.5;
	end
	if not vo.onStart then
		vo.onStart = function(loader)
			local effect = loader.content.effect;
			if not effect then return; end
			effect._x = 0;
			effect._y = 0;
			if effect.toString then
				local effectClz = effect:toString();
				if effectClz=="UIEffect" or effectClz=="SwfEffect" then
					effect:playEffect(0);
					return;
				end
			end
			effect:gotoAndPlay(1);
		end
	end
	UILoaderManager:LoadList({vo.url},function()
		UIFly:Open(vo);
	end);
end

--飞特效队列
function FlyManager:FlyEffectList(list,interval)
	if #list <= 0 then return; end
	if interval and interval>0 then
		TimerManager:RegisterTimer(function()
			local vo = table.remove(list,1);
			if vo then
				self:FlyEffect(vo);
			end
		end,interval,#list);
	else
		for i,vo in ipairs(list) do
			self:FlyEffect(vo);
		end
	end
end