--[[
	新天神
]]

_G.UINewTianshenCardGet = BaseUI:new('UINewTianshenCardGet');

UINewTianshenCardGet.selectList = {}
UINewTianshenCardGet.nMaxCount = 10
function UINewTianshenCardGet:Create()
	self:AddSWF("newTianshenCardGet.swf", true, "center");
end

function UINewTianshenCardGet:OnLoaded(objSwf)
	objSwf.item1.rollOver = function()
		if not self.item then
			return
		end
		TipsManager:ShowBagTips(BagConsts.BagType_Tianshen,self.item.pos) 
	end
	objSwf.item1.rollOut = function() TipsManager:Hide(); end
end

function UINewTianshenCardGet:OnShow()
	local vo = {};
	vo.hasItem = true;
	EquipUtil:GetDataToItemUIVO(vo,self.item)
	self.objSwf.item1:setData(UIData.encode(vo))
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	local func = function()
		local startPos = UIManager:PosLtoG(self.objSwf.item1,70,17);
		RewardManager:FlyIcon(RewardManager:ParseToVO(self.item:GetTid() .. ",0,0"),startPos,5,true,60)
		self:Hide()
		return
	end
	self.timerKey = TimerManager:RegisterTimer(func, 1500,1);
	local pos = UIMainSkill:GetItemNinePos()
	if pos then
		self.objSwf._x = pos.x
		self.objSwf._y = pos.y
	end
end

function UINewTianshenCardGet:OnHide()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
end

function UINewTianshenCardGet:Open(id)
	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen)
	if not bag then return end
	self.item = bag:GetItemById(id)
	if self.item:GetCfg().sub == BagConsts.SubT_TianshenJY then
		return
	end
	if not self.item then
		return
	end
	if self:IsShow() then
		self:Top()
		self:OnShow()
	else
		self:Show()
	end
end