--[[
背包功能
lizhuangzhuang
2014年11月7日18:11:00
]]

_G.BagFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Bag,BagFunc);

--背包容量
BagFunc.size = nil;
--背包总容量
BagFunc.totalSize = nil;

function BagFunc:OnBtnInit()
	self.button.mcFull.visible = false;
	self.button.mcNum._visible = false;
	if self.size and self.totalSize then
		self:ShowBagEffect();
	end
end

--背包容量改变
function BagFunc:OnBagCapacityChange(size,totalSize)
	self.size = size;
	self.totalSize = totalSize;
	self:ShowBagEffect();
end

--显示背包特效
function BagFunc:ShowBagEffect()
	if not self.button then return; end
	if self.size >= self.totalSize then
		-- self.button.mcFull.visible = true;
		if not self.button.effectLoader.loaded then
			self.button.effectLoader.loaded = function()
				local effect = self.button.effectLoader.content.effect;
				effect:playEffect(0);
			end
		end
		UILoaderManager:LoadList({ResUtil:GetBagFullUrl()},function()
			if self.button.effectLoader.source ~= ResUtil:GetBagFullUrl() then
				self.button.effectLoader.source = ResUtil:GetBagFullUrl();
			end
		end);
		-- self.button.mcFull.visible = true;
		if self.button.effectLoader.content and self.button.effectLoader.content.effect then
			self.button.effectLoader.content.effect:playEffect(0);
		end
	else
		self.button.mcFull.visible = false;
		if self.button.effectLoader.content and self.button.effectLoader.content.effect then
			self.button.effectLoader.content.effect:stopEffect();
		end
	end
	local leftSize = self.totalSize - self.size;
	if leftSize>0 and leftSize<=5 then
		self.button.mcNum._visible = true;
		self.button.mcNum.textField.text = leftSize;
	else
		self.button.mcNum._visible = false;
	end
end

--上次播放拾取效果的时间
BagFunc.lastShowPickTime = 0;
BagFunc.showPickList = {};
BagFunc.showPickTimerKey = nil;
--显示拾取特效
function BagFunc:ShowPickEffect(id)
	if not self.button then return; end
	if id == enAttrType.eaZhenQi then return end
	
	local cfg = t_item[id];
	if not cfg then
		cfg = t_equip[id];
	end
	if not cfg then return; end
	local flyVO = {};
	flyVO.objName = 'FlyVO'
	flyVO.url = BagUtil:GetItemIcon(id);
	local buttonPos = UIManager:PosLtoG(self.button,10,10);
	flyVO.startPos = {};
	flyVO.startPos.x = buttonPos.x;
	flyVO.startPos.y = buttonPos.y - 100;
	flyVO.endPos = {};
	flyVO.endPos.x = buttonPos.x + 5;
	flyVO.endPos.y = buttonPos.y + 5;
	flyVO.time = 0.5;
	flyVO.tweenParam = {};
	flyVO.tweenParam._width = 20;
	flyVO.tweenParam._height = 20;
	local nowTime = GetCurTime();
	if nowTime - self.lastShowPickTime > 200 then
		FlyManager:FlyIcon(flyVO);
		self.lastShowPickTime = nowTime;
	else
		table.push(self.showPickList,flyVO);
		if not self.showPickTimerKey then
			self.showPickTimerKey = TimerManager:RegisterTimer(function()
				FlyManager:FlyIconList(self.showPickList,200);
				self.showPickList = {};
				self.showPickTimerKey = nil;
				self.lastShowPickTime = GetCurTime();
			end,200,1);
		end
	end
end