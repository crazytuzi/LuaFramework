--[[
    Created by IntelliJ IDEA.
	t_consts[313]配置了大于多少才显示
    User: Hongbin Yang
    Date: 2016/9/14
    Time: 15:26
   ]]

_G.UICurrencyFlyView = BaseUI:new("UICurrencyFlyView");

--只有三个值 enAttrType.eaBindGold	enAttrType.eaUnBindMoney	enAttrType.eaBindMoney
UICurrencyFlyView.ctype = 0;
UICurrencyFlyView.container = nil;
UICurrencyFlyView.isPlaying = false;
local targetX = 0;
local targetY = 0;
local startX = 0;
local startY = 0;
local endY = 0;
local disY = 150;

local startRangeWidth = 100;
local startRangeHeight = 20;
local endRangeHeight = 20;
function UICurrencyFlyView:Create()
	self:AddSWF("mainCurrencyFly.swf", false, "highTop");
end

function UICurrencyFlyView:InitView()
	local objSwf = self.objSwf;
	objSwf.goldPanel._visible = false;
	objSwf.moneyPanel._visible = false;
	objSwf.xiuweiPanel._visible = false;
	-- 界面加载完成后的
	if self.ctype == enAttrType.eaBindGold then
		self.container = objSwf.goldPanel;
		local pos = UIMainTop:GetGoldIconGlobalPos();
		if not pos then return; end
		targetX = pos.x + 5;
		targetY = pos.y + 5;
	elseif self.ctype == enAttrType.eaUnBindMoney or self.ctype == enAttrType.eaBindMoney then
		self.container = objSwf.moneyPanel;
		local pos = UIMainTop:GetBindMoneyIconGlobalPos();
		if not pos then return; end
		targetX = pos.x + 5;
		targetY = pos.y + 5;
	elseif self.ctype == enAttrType.eaZhenQi then
		self.container = objSwf.xiuweiPanel;
		local pos = UIMainXiuweiPool:GetChiGlobalPos()
		if not pos then return; end
		targetX = pos.x - 15;
		targetY = pos.y - 15;
	end
	self.container._visible = true;
	self:PlayAni();
end

function UICurrencyFlyView:OnShow()
	--默认显示银两
	if #self.args <=0 then
		self.ctype = enAttrType.eaBindGold;
	else
		--货币类型
		self.ctype = self.args[1];
		if #self.args > 1 then
			startX = self.args[2][1];
			startY = self.args[2][2];
		else
			local wWidth, wHeight = UIManager:GetWinSize();
			startX = wWidth / 2;
			startY = wHeight / 2 - 50;
		end

	end

	self:InitView();
end


function UICurrencyFlyView:PlayAni()
	if not self.container then return; end
	if self.isPlaying then return; end
	self.isPlaying = true;
	local list = {};
	local count = 24;
	for i = 1, count do
		local item = self.container["q"..i];
		if item then
			item._visible = false;
			table.push(list, item);
		end
	end
	endY = startY + disY;

	local delayGap = 0.1;
	local completeCount = 0;
	for k, v in pairs(list) do
		local sx = RandomUtil:int(startX - startRangeWidth, startX + startRangeWidth);
		local sy = RandomUtil:int(startY - startRangeHeight, startY + startRangeHeight);
		local ex = sx;
		local ey = RandomUtil:int(endY - endRangeHeight, endY + endRangeHeight);
		v._x = sx;
		v._y = sy;
		Tween:To(v, 0.3,{_x=ex, _y=ey, ease=Quart.easeIn, delay = delayGap},{onStart = function()
			v:gotoAndStopEffect(1);
			v._visible = true;
		end, onComplete = function()
			--飞向终点
			Tween:To(v, 0.5, {_x = targetX, _y = targetY, ease=Quart.easeIn, delay = 0.4}, {onComplete = function()
				v:playEffect(1);
				completeCount = completeCount + 1;
				if completeCount >= count then
					list = nil;
					self:Hide();
					return;
				end
			end});
		end});
		delayGap = delayGap + 0.05;
	end
end

function UICurrencyFlyView:OnHide()
	self.ctype = 0;
	self.container = nil;
	self.isPlaying = false;
end

function UICurrencyFlyView:IsTween()
	return false;
end

function UICurrencyFlyView:GetPanelType()
	return 0;
end

function UICurrencyFlyView:ESCHide()
	return false;
end

function UICurrencyFlyView:IsShowLoading()
	return false;
end

function UICurrencyFlyView:IsShowSound()
	return false;
end

function UICurrencyFlyView:NeverDeleteWhenHide()
	return true;
end