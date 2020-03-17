--[[
UI上绘制3D模型的管理器
lizhuangzhuang
2014年7月21日11:28:49
]]
_G.classlist['UIDrawManager'] = 'UIDrawManager'
_G.UIDrawManager = {};
_G.objName = 'UIDrawManager'
--渲染器列表
UIDrawManager.setAllUIDraw ={};

UIDrawManager.tick = 0;

--添加一个渲染器
function UIDrawManager:AddUIDraw(objUIDraw) 
	self.setAllUIDraw[objUIDraw.name] = objUIDraw;
end;

--移除一个渲染器
function UIDrawManager:RemoveUIDraw(objUIDraw)
	if self.setAllUIDraw[objUIDraw.name] then
		self.setAllUIDraw[objUIDraw.name]:Destroy();
		self.setAllUIDraw[objUIDraw.name] = nil;
	end
end

--获取渲染器
function UIDrawManager:GetUIDraw(name) 
	return self.setAllUIDraw[name];
end
 
--每帧渲染
function UIDrawManager:Update(dwInterval)
	local doP = false;
	local pNum = 0;
	if isDebug then
		self.tick = self.tick + dwInterval;
		if self.tick > 3000 then
			doP = true;
			self.tick = 0;
		end
	end
	if doP then
		print("==========================");
		print("Print:Current UIDraw List.");
	end
	for I,Draw in pairs(self.setAllUIDraw) do
		if Draw.bIsRender then
			Draw:Render(dwInterval);
			if doP then
				print(Draw.name);
				pNum = pNum + 1;
			end
		end
	end
	if doP then
		print("totalNum:",pNum);
		print("==========================");
	end
end

function UIDrawManager:Destroy()
	for name,drawObj in pairs(self.setAllUIDraw) do
		drawObj:Destroy();
	end
	self.setAllUIDraw = nil;
end 