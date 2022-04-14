--- Created by Admin.
--- DateTime: 2019/11/18 14:37

PackMallItem = PackMallItem or class("PackMallItem" ,Node)
local this = PackMallItem

function PackMallItem:ctor(obj, data, index, allprice)
    self.transform = obj.transform
    self.gameObject = self.transform.gameObject;
    self.config = data;
    self.index = index
    self.transform_find = self.transform.Find;
    self.events = {}
	self.money = 0
	self.model = ShopModel.GetInstance()
	self.is_buy= true
	self.times = 0
	self.allprice = allprice
    self:Init();
end

function PackMallItem:dctor()
    if self.item then
		self.item:destroy()
	end
	self.is_buy= true
	self.times = 0
end


function PackMallItem:Init()
    self.is_loaded = true;
    self.nodes = {
		"name","pos","price/price","price1/price1","Button"
	  }
    self:GetChildren(self.nodes);
	
	self.nameTex = GetText(self.name)
    self.priceTex = GetText(self.price)
	self.price2Tex = GetText(self.price1)	
	self.btnImg = GetImage(self.Button)

	self:AddEvents()
	self:InitItem()
end

function PackMallItem:AddEvents()
     local function  call_back()
		local count = RoleInfoModel:GetInstance():GetMainRoleData()[Constant.GoldType.Gold] or 0;
		if count >= self.money then
			if self.is_buy then
				local all = self.model.curallPrice - self.money
				local function  call_back()
					ShopController:GetInstance():RequestBuyGoods(self.config.id, 1)
				end
				local str 
				if all > self.allprice then
					 str = "Buy out all items so you will enjoy more discounts. Keep buying?"
				else
					 str = "You will no longer be able to buy out all items after buying this item."
				end	
				Dialog.ShowTwo("Tip", str, "Confirm", call_back, nil, "Cancel", nil, nil)
			end
		else
			local str = "You don't have enough diamonds, top-up now?"
			local function call_back()
				GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
				GlobalEvent:Brocast(ShopEvent.ClosePackMallByItem)
			end
			Dialog.ShowTwo("Tip", str, "Confirm", call_back, nil, "Cancel", nil, nil)
		end	
	 end
     AddClickEvent(self.Button.gameObject, call_back)
end

function PackMallItem:InitItem()
	local p = String2Table(self.config.original_price)
	local p1 = self.config.price
	self.priceTex.text = p[2]
	self.price2Tex.text = p1[90010003]
	self.money = p1[90010003]
	self.nameTex.text = self.config.name

	self.item = GoodsIconSettorTwo(self.pos.transform)
	local t = String2Table(self.config.item)
	local param = {}
	param["item_id"] = t[1][1];
	param["num"] = t[1][2];
	param["can_click"] = t[1][3];
	self.item:SetIcon(param)
	
end

function PackMallItem:GetPrice()
	return self.money * self.config.limit_num
end

function PackMallItem:GetCurPrice()
	return self.money *  (self.config.limit_num - self.times)
end

function PackMallItem:GetID()
	return self.config.id
end

function PackMallItem:UpdateData()
	local times = self.model:GetGoodsBoRecordById(self.config.id)
	if times then
		self.times = times
		if times >= self.config.limit_num then
			SetGray(self.btnImg, true)
			self.is_buy = false
		end		
	end
end

