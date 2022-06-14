
-- uiaction的一些通用效果的集中定义
uiaction = {};

-- 绕x轴翻转效果, window1 是最终消失的window, window2 是显示的, theta是夹角
function uiaction.flipTwoWindowX(window1, window2, theta, time)
	if not window1 or not window2 then
		return;
	end
	
	-- 转弧度
	theta = math.rad(theta);
	local windowSize = window1:GetPixelSize();
	local halfHeight = windowSize.y / 2;
	local halfTheta = theta / 2;
	
	local radius = halfHeight * math.tan(halfTheta);
	-- window1 3/2 pi -> pi/2+theta ----递减
	-- window2 1/2 pi - theta - > - 1/2 pi
	
	local step = -math.rad(5);
	local begin1 = 3*math.pi/2;
	local end1 = math.pi/2+theta;
	
	local action1 = LORD.GUIAction:new();
	for fai=begin1, end1, step do
		local rotate = -(begin1 - fai);
		rotate = math.deg(rotate);
		local y = radius * math.cos(fai);
		local z = radius + radius * math.sin(fai);
		local t = time * (fai-begin1) / (end1 - begin1);
		action1:addKeyFrame(LORD.Vector3(0, y, z), LORD.Vector3(rotate, 0, 0), LORD.Vector3(1, 1, 1), 1, t);
		
		--print("action1 fai "..fai.." y "..y.." z "..z.." t "..t);
	end

	local begin2 = math.pi/2 - theta;
	local end2 = -math.pi/2;
	
	local action2 = LORD.GUIAction:new();
	for fai=begin2, end2, step do
		local rotate = math.pi - theta - begin2 + fai;
		rotate = math.deg(rotate);
		local y = radius * math.cos(fai);
		local z = radius + radius * math.sin(fai);
		local t = time * (fai-begin2) / (end2 - begin2);
		action2:addKeyFrame(LORD.Vector3(0, y, z), LORD.Vector3(rotate, 0, 0), LORD.Vector3(1, 1, 1), 1, t);
		--print("action1 fai "..fai.." y "..y.." z "..z.." t "..t.." rotate "..rotate);
	end
	
	function onflipTwoWindowXEnd1(args)
		local window = LORD.toWindowEventArgs(args).window;
		window:SetVisible(false);
	end
	
	function onflipTwoWindowXEnd2(args)
		local window = LORD.toWindowEventArgs(args).window;
		window:SetVisible(true);
	end
	
	window1:playAction(action1);
	window1:subscribeEvent("UIActionEnd", "onflipTwoWindowXEnd1");
	window2:playAction(action2);
	window2:subscribeEvent("UIActionEnd", "onflipTwoWindowXEnd2");
end

-- 翻牌效果转过来
function uiaction.turnaround(window, time)
	if not window then
		return;
	end
	local action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, -180, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, time);
	
	window:removeEvent("UIActionEnd");
	window:playAction(action);
end

-- 翻牌效果转过去
function uiaction.turnback(window, time)
	if not window then
		return;
	end
	
	function onUIActionTurnBackEnd(args)
		local window = LORD.toWindowEventArgs(args).window;
		window:SetVisible(false);
	end
	
	local action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 180, 0), LORD.Vector3(1, 1, 1), 1, time);
	window:removeEvent("UIActionEnd");
	window:subscribeEvent("UIActionEnd", "onUIActionTurnBackEnd");
	window:playAction(action);
		
end

-- 移动效果，翻页
function uiaction.move(window, startPos, endPos, time)
	if not window then
		return;
	end	
	local action = LORD.GUIAction:new();
	action:addKeyFrame(startPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(endPos, LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, time);
	window:playAction(action);
end

-- 弹出效果
function uiaction.popup(window)
	if window then
		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(0.9, 0.9, 0.9), 0.0, 0);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1.1, 1.1, 1.1), 0.5, 100);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
		window:playAction(action);
	end
end

-- 收回去的效果
function uiaction.goback(window, layout, callback)
	
	function onUIActionGoBackEnd()
		layout:Close();
		if callback then
			callback();
		end
	end
	
	if window and layout then
		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1.1, 1.1, 1.1), 0.5, 100);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(0.5, 0.5, 0.5), 0, 200);
		window:playAction(action);
		window:subscribeEvent("UIActionEnd", "onUIActionGoBackEnd");
	end
end

-- 淡入
function uiaction.fadeIn(window, time)
	if window then
		local alpha = window:GetAlpha();
		local action = LORD.GUIAction:new();
		
		--print("alpha "..alpha);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), alpha, 0);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, time * (1 - alpha));
		window:playAction(action);
	end
end

-- 淡出
function uiaction.fadeOut(window, time)
	if window then
		local action = LORD.GUIAction:new();
		local alpha = window:GetAlpha();
		
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), alpha, 0);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 0, time * alpha);
		window:playAction(action);
	end
end

-- 震动
function uiaction.shake(window)
	if window then
		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(LORD.Vector3(5, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 25);
		action:addKeyFrame(LORD.Vector3(-5, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 75);
		action:addKeyFrame(LORD.Vector3(5, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 75);
		action:addKeyFrame(LORD.Vector3(-5, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 125);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 150);
		
		window:playAction(action);		
	end
end

-- 缩放
function uiaction.scale(window, scale)
	
	scale = scale or 1.5;
			
	if window then
		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(scale, scale, scale), 1, 100);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);				
		window:playAction(action);		
	end
	
end
