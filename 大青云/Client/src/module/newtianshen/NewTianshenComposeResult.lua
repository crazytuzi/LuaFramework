--[[
	新天神
]]

_G.UINewTianshenComposeResult = BaseUI:new('UINewTianshenComposeResult');

UINewTianshenComposeResult.selectList = {}
UINewTianshenComposeResult.nMaxCount = 10
function UINewTianshenComposeResult:Create()
	self:AddSWF("NewTanshenComResult.swf", true, "center");
end

function UINewTianshenComposeResult:OnLoaded(objSwf)
	objSwf.btnClose.click = function()
		self:Hide()
	end
	objSwf.btnConfirm.click = function()
		self:Hide()
	end
	objSwf.item1.rollOver = function()
		if not self.item then
			return
		end
		TipsManager:ShowBagTips(BagConsts.BagType_Tianshen,self.item.pos) 
	end
	objSwf.item1.rollOut = function() TipsManager:Hide(); end
end

function UINewTianshenComposeResult:OnShow()
	local vo = {};
	vo.hasItem = true;
	EquipUtil:GetDataToItemUIVO(vo,self.item)
	self.objSwf.item1:setData(UIData.encode(vo))
	if self.type == 0 then
		self.objSwf.icon1._visible = true
		self.objSwf.icon2._visible = false
		self.objSwf.tfContent.text = StrConfig['newtianshen18']
	else
		self.objSwf.icon1._visible = false
		self.objSwf.icon2._visible = true
		if NewTianshenUtil:GetQualityByZizhi(self.item:GetParam()) == 0 then
			self.objSwf.tfContent.htmlText = StrConfig['newtianshen17']
		else
			self.objSwf.tfContent.htmlText = StrConfig['newtianshen41']
		end
	end
end

function UINewTianshenComposeResult:Open(id, type)
	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen)
	if not bag then return end
	self.item = bag:GetItemById(id)
	if not self.item then
		return
	end
	self.type = type
	if self:IsShow() then
		self:Top()
		self:OnShow()
	else
		self:Show()
	end
end