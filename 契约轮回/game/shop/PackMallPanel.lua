--- Created by Admin.
--- DateTime: 2019/11/18 11:19

PackMallPanel = PackMallPanel or class("PackMallPanel" , BasePanel)

local PackMallPanel = PackMallPanel

function PackMallPanel:ctor()
    self.abName = "packmall"
    self.assetName = "PackMallPanel"
	self.use_background = true
    self.layer = "UI"
	
	self.panel_type = 2

	self.items = {}
	self.itemList = {}
	self.events = {}
	self.itemData = {}
	self.is_buy = true

    self.model = ShopModel.GetInstance()
end

function PackMallPanel:dctor()
	destroyTab(self.itemList);
	self.itemList = nil
	self.items = nil
	GlobalEvent:RemoveTabListener(self.events)	
	if self.effect then
		self.effect:destroy()
		self.effect = nil
	end
end

function PackMallPanel:Open()
    PackMallPanel.super.Open(self)
end

function PackMallPanel:OpenCallBack()
end

function PackMallPanel:LoadCallBack()
    self.nodes = {
	"closebtn","time","bg","left/modelcon2",
	"left/name","left/power","left/price","left/price2","left/modelcon","left/buyBtn",
	"mid/item/item1","mid/buy/buyAllBtn","mid/buy/allprice","mid/buy/allprice2",
	"mid/item/item2","mid/item/item3","mid/item/item4","mid/item/item5","left/leftImg",
		"left",
    }
    self:GetChildren(self.nodes)
    self.priceTex = GetText(self.price)
	self.price2Tex = GetText(self.price2)
	self.allpriceTex = GetText(self.allprice)
	self.allprice2Tex = GetText(self.allprice2)
	self.powerTex = GetText(self.power)
	self.nameImg = GetImage(self.name)
	self.buyImg = GetImage(self.buyBtn)
	self.bgImg = GetImage(self.bg)
	self.leftImg = GetImage(self.leftImg)
	self.buyAllImg = GetImage(self.buyAllBtn)
	
	self.items[2] = self.item1
	self.items[3] = self.item2
	self.items[4] = self.item3
	self.items[5] = self.item4
	self.items[6] = self.item5
	
	local res = "packmall_bg";
	lua_resMgr:SetImageTexture(self, self.bgImg, "iconasset/icon_big_bg_" .. res, res, false);
	
	ShopController:GetInstance():RequestActItems(self.model.packmallId)
    self:AddEvent()

end

function PackMallPanel:AddEvent()
	local function call_back()
		self:Close()
	end
	AddClickEvent(self.closebtn.gameObject, call_back)
	
	local function call_back()
		local count = RoleInfoModel:GetInstance():GetMainRoleData()[Constant.GoldType.Gold] or 0;
		if count >= self.fristneedprice then
			if self.is_buy then
				local all = self.model.curallPrice - self.fristneedprice
				local function  call_back()
					ShopController:GetInstance():RequestBuyGoods(self.itemData[1].id, 1)
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
				self:Close()
			end
			Dialog.ShowTwo("Tip", str, "Confirm", call_back, nil, "Cancel", nil, nil)
		end	
	end
	AddClickEvent(self.buyBtn.gameObject, call_back)
	
	local function call_back()
		local have = RoleInfoModel:GetInstance():GetMainRoleData()[Constant.GoldType.Gold] or 0
		if have >= self.allprice then
			if self.model.is_allBuy then
				local function call_back()
					ShopController.GetInstance():HandleBuyInfo(self.model.packmallId)
				end
				Dialog.ShowTwo("Tip", "Use quick buy?", "Confirm", call_back, nil, "Cancel", nil, nil)
			else
				if self.model.curallPrice == 0 then
					Notify.ShowText("Purchased");
				else
					Notify.ShowText("Not enough storage, fail to flash purchase");
				end

			end
		else
			local str = "You don't have enough diamonds, top-up now?"
			local function call_back()
				GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
				self:Close()
			end
			Dialog.ShowTwo("Tip", str, "Confirm", call_back, nil, "Cancel", nil, nil)
		end
		
	end
	AddClickEvent(self.buyAllBtn.gameObject,  call_back)
	
	local function call_back()
		--ShopController:GetInstance():RequestSlotGoods()
	end
	self.events[#self.events + 1] = GlobalEvent:AddListener(ShopEvent.SuccessToBuyGoodsInShop, call_back)
	
	local function call_back()
		self:UpdateView() 
	end
	self.events[#self.events + 1] = GlobalEvent:AddListener(ShopEvent.HandelShopBoughtList, call_back)

	self.events[#self.events + 1] = GlobalEvent:AddListener(ShopEvent.HandleActItems, handler(self, self.HandleActItems))
	self.events[#self.events + 1] = GlobalEvent:AddListener(ShopEvent.ClosePackMallByItem, handler(self, self.Close))

end

function PackMallPanel:InitPanel()
	local config = self.itemData[1]
	if config then
		self.priceTex.text = String2Table(config.original_price)[2]
		self.price2Tex.text = config.price[90010003]
		self.fristneedprice = config.price[90010003]

		local res = "packmall_" .. self.model.packmallId;
		local function call_back(sp)
			self.nameImg.sprite = sp
			self.nameImg:SetNativeSize()
		end
		lua_resMgr:SetImageTexture(self, self.nameImg, "packmall_image" , res, true, call_back, false);

		self.config = OperateModel.GetInstance():GetConfig(self.model.packmallId)
		local reqs = String2Table(self.config.reqs)

		if reqs[2][1] == 6 then
			local id ={}
			id[1] = reqs[2][2]
			id[2] = reqs[2][3]
			self.pet_model = UIModelManager:GetInstance():InitModel(6, id, self.modelcon, nil, false, 1)
		elseif reqs[2][1] == 99 then
			SetVisible(self.leftImg, true)
			local id = reqs[2][2]
			local res = "pack_".. id
			lua_resMgr:SetImageTexture(self, self.leftImg, "packmall_image" , res, true, nil, false)
			
			if not self.effect then
			   self.effect = UIEffect(self.left, 10311, false)
			--self.effect:SetOrderIndex(101)
			   local cfg = {}
			   cfg.scale = 1.25
			   cfg.pos = {x= -348, y=-50,z=0}
			   self.effect:SetConfig(cfg)
			end
			
			local action = cc.MoveTo(1, -348, 100)
			action = cc.Sequence(action, cc.MoveTo(1, -348, 85))
			action = cc.Repeat(action, 4)
			action = cc.RepeatForever(action)
			cc.ActionManager:GetInstance():addAction(action, self.leftImg.transform)
		elseif reqs[2][1] == 3 then
		    self.pet_model = UIMountCamera(self.modelcon2, nil, "model_mount_".. reqs[2][2], nil, nil);
		    local config = {};
		    config.rotate = { x = 0, y = 135, z = 0 };
		    config.offset = { x = 4000, y = 0, z = 0 };
			config.cameraPos = { x = 3990, y = -980, z = 0 };
		    config.offset = { x = 6000, y = -940, z = -550 };
			config.scale = { x = 40, y = 40, z = 40 };
		    self.pet_model:SetConfig(config)
		else
			self.pet_model =  UIModelCommonCamera(self.modelcon2, nil, reqs[2][1],nil , false)
			if reqs[4] and reqs[4][1] == 'pos' then
				local pos =reqs[4][2]
				SetLocalPositionXY(self.modelcon2.transform, pos[1],pos[2])
				SetLocalRotation(self.modelcon2.transform, 0, 0, pos[3])
				
				local action = cc.MoveTo(1, -70, 22.99981)
				action = cc.Sequence(action, cc.MoveTo(1, -70, 6.99981))
				action = cc.Repeat(action, 4)
				action = cc.RepeatForever(action)
				cc.ActionManager:GetInstance():addAction(action, self.modelcon2.transform)

			else
				SetLocalPositionXY(self.modelcon2.transform,-314, 145)
			end
		end

		self.powerTex.text = reqs[3][2]
		self.allprice2Tex.text = reqs[1][2][2]
		self.allprice = tonumber(reqs[1][2][2])

	end
	
	local count = 0
	for i = 2, 6 do
        local config = self.itemData[i] --original_price
		self.itemList[i] = PackMallItem(self.items[i].gameObject, config, i, self.allprice)
		count = count + String2Table(config.original_price)[2]		
	end
	
	self.allpriceTex.text = "Total Price:"..(String2Table(config.original_price)[2] + count) 
	self:ShowTime()
	self:UpdateView()
end

function PackMallPanel:UpdateView()
    self:UpdateFrist()
	local count = self.fristPrice
	for i = 2, 6 do
		self.itemList[i]:UpdateData()
		count = count + self.itemList[i]:GetCurPrice()
	end
	self.model.curallPrice = count
	
	self.model.is_allBuy = count > self.allprice

	if self.model.is_allBuy then
		ShaderManager.GetInstance():SetImageNormal(self.buyAllImg)
	else
		ShaderManager:GetInstance():SetImageGray(self.buyAllImg)
	end
end


function PackMallPanel:ShowTime()
	local act_info = OperateModel.GetInstance():GetAct(self.model.packmallId)
	if not self.countdown_item then
		local param = {}
		param["duration"] = 0.3
		param["isChineseType"] =  true
		param["isShowDay"] = true
		param["isShowHour"] = true
		self.countdown_item = CountDownText(self.time, param)
		local function end_func()
			self:Close()
		end
		self.countdown_item:StartSechudle(act_info.act_etime, end_func)
	end
end


function PackMallPanel:UpdateFrist()
	self.fristPrice = 0
	local config = self.itemData[1]
	local times = self.model:GetGoodsBoRecordById(config.id)
	if times then
		if times >= config.limit_num then
			SetGray(self.buyImg,true)
			self.is_buy = false
		else
			self.fristPrice = (config.limit_num - times) * config.price[90010003]
		end
	else
		self.fristPrice = config.limit_num  *  config.price[90010003]
	end
end
function PackMallPanel:HandleActItems(data)
	if data.act_id == self.model.packmallId then
		local tab = data.items
		table.sort(tab, function(a, b)
				return a.order < b.order 
			end)
		self.itemData = tab
		self:InitPanel()
	end
end


function PackMallPanel:CloseCallBack()
	if self.countdown_item then
		self.countdown_item:destroy()
		self.countdown_item = nil
	end
	if self.pet_model then
		self.pet_model:destroy()
	end
	self.pet_model = nil
end
