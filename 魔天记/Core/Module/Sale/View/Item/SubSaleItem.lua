require "Core.Module.Common.UIItem"
local SaleIconItem = require "Core.Module.Sale.View.Item.SaleIconItem"
SubSaleItem = class("SubSaleItem", UIItem);

function SubSaleItem:New()
	self = {};
	setmetatable(self, {__index = SubSaleItem});
	return self
end


function SubSaleItem:_Init()
	self:_InitReference();
	self:_InitListener();
	self._productInfo = ProductInfo:New();
	self:UpdateItem(self.data)
end

function SubSaleItem:_InitReference()
	self._baseIconItem = SaleIconItem:New()
	self._baseIconItem:Init(self.gameObject)
	
	-- self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
	-- self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
	self._tip = UIUtil.GetChildByName(self.transform, "UISprite", "tip")
	self._goDisable = UIUtil.GetChildByName(self.transform, "disable").gameObject
	self._goUnUseTag = UIUtil.GetChildByName(self.transform, "unUse").gameObject
	self._txtCount = UIUtil.GetChildByName(self.transform, "UILabel", "count")
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
	self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "level")
	self._txtPrice = UIUtil.GetChildByName(self.transform, "UILabel", "sale")
	self._btnBuy = UIUtil.GetChildByName(self.transform, "UIButton", "buy")
end

function SubSaleItem:_InitListener()
	self._onClickBtnBuy = function(go) self:_OnClickBtnBuy() end
	UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnBuy);
	-- self._onClickIcon = function(go) self:_OnClickIcon() end
	-- UIUtil.GetComponent(self._imgIcon, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickIcon);
end

function SubSaleItem:_OnClickIcon()
	ProductCtrl.ShowProductTip(self.data.configData.id, ProductCtrl.TYPE_FROM_OTHER, 1, ProductManager.ST_TYPE_IN_OTHER)	
end

function SubSaleItem:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	
end

function SubSaleItem:_OnClickBtnBuy()
	ModuleManager.SendNotification(SaleNotes.OPEN_SALEBUYITEMPANEL, self.data)
end

function SubSaleItem:_DisposeReference()
	self._imgIcon = nil
	self._imgQuality = nil
	self._baseIconItem:Dispose()
	self._baseIconItem = nil
	self._productInfo = nil
	self._goDisable = nil
	self._goUnUseTag = nil
end

function SubSaleItem:_DisposeListener()
	UIUtil.GetComponent(self._btnBuy, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnBuy = nil;
	-- UIUtil.GetComponent(self._imgIcon, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickIcon = nil;
end

function SubSaleItem:UpdateItem(data)
	self.data = data
	if(self.data) then
		self._baseIconItem:UpdateItem(self.data.configData)
		-- ProductManager.SetIconSprite(self._imgIcon, self.data.configData.icon_id)
		-- self._imgQuality.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
		self._txtName.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
		self._txtName.text = self.data.configData.name
		self._txtCount.text = tostring(self.data.num)
		self._txtPrice.text = tostring(self.data.price)
		self._txtLevel.text = tostring(self.data.configData.lev)
		
		if(self.data.configData.type == ProductManager.type_1) then
			self._productInfo:Init({spId = self.data.configData.id, am = 1})
			local kind = self.data.configData.kind;
			local eqbagInfo = EquipDataManager.GetProductByKind(kind);
			
			if(self._productInfo:IsFitMyCareer()) then
				if eqbagInfo == nil then
					self._tip.spriteName = "up";
					self._tip.gameObject:SetActive(true);
				else
					
					-- 获取在背包中的 属性
					-- local eq_bag_att = ProductCtrl.GetEquipAllAtt(eqbagInfo, false);
					-- 对应装备栏里的总 战斗力
					local eq_bag_fight = eqbagInfo:GetFight();
					-- 背包中的 属性
					-- local bag_att = ProductCtrl.GetEquipAllAtt(self._productInfo, false);
					local bag_fight = self._productInfo:GetFight();
					
					-- log("----_fight-------- "..eq_bag_fight.. "  "..bag_fight);
					if bag_fight > eq_bag_fight then
						self._tip.spriteName = "up";
						self._tip.gameObject:SetActive(true);
					elseif bag_fight < eq_bag_fight then
						self._tip.spriteName = "down";
						self._tip.gameObject:SetActive(true);
					else
						self._tip.gameObject:SetActive(false);
					end					
				end		
				self._goDisable:SetActive(false)
				self._goUnUseTag:SetActive(PlayerManager.GetPlayerLevel() < self.data.configData.req_lev)		
			else
				self._tip.gameObject:SetActive(false)
				self._goDisable:SetActive(true)		
				self._goUnUseTag:SetActive(true)						
			end		
			
		else
			self._tip.gameObject:SetActive(false)
			self._goDisable:SetActive(false)
			self._goUnUseTag:SetActive(false)	
		end
	end
end 