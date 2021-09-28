require "Core.Module.Common.UIItem"
local SaleIconItem = require "Core.Module.Sale.View.Item.SaleIconItem"

SubMySaleItem = class("SubMySaleItem", UIItem);
function SubMySaleItem:New()
	self = {};
	setmetatable(self, {__index = SubMySaleItem});
	return self
end


function SubMySaleItem:_Init()
	self:_InitReference();
	self:_InitListener();
	self:UpdateItem(self.data)
end

function SubMySaleItem:_InitReference()
	self._baseIconItem = SaleIconItem:New()
	self._baseIconItem:Init(self.gameObject)
	
	-- self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
	-- self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
	self._txtCount = UIUtil.GetChildByName(self.transform, "UILabel", "num")
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
	self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "level")
	self._txtPrice = UIUtil.GetChildByName(self.transform, "UILabel", "price")
	self._txtTotalPrice = UIUtil.GetChildByName(self.transform, "UILabel", "totalPrice")
	self._goOverdueTag = UIUtil.GetChildByName(self.transform, "overdue").gameObject
	self._tip = UIUtil.GetChildByName(self.transform, "UISprite", "tip")
	self._goDisable = UIUtil.GetChildByName(self.transform, "disable").gameObject
	self._goUnUseTag = UIUtil.GetChildByName(self.transform, "unUse").gameObject
	
	self._btnReGrounding = UIUtil.GetChildByName(self.transform, "UIButton", "btnReGrounding")
	self._btnUnGrounding = UIUtil.GetChildByName(self.transform, "UIButton", "btnUnGrounding")
	self._gotip = UIUtil.GetChildByName(self._btnUnGrounding, "tip").gameObject
	self._productInfo = ProductInfo:New();
end

function SubMySaleItem:_InitListener()
	self._onClickBtnReGrounding = function(go) self:_OnClickBtnReGrounding() end
	UIUtil.GetComponent(self._btnReGrounding, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReGrounding);
	self._onClickBtnUnGrounding = function(go) self:_OnClickBtnUnGrounding() end
	UIUtil.GetComponent(self._btnUnGrounding, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnUnGrounding);
end

function SubMySaleItem:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function SubMySaleItem:_OnClickBtnReGrounding()
	SaleProxy.SendReGrounding(self.data.id)
end

function SubMySaleItem:_OnClickBtnUnGrounding()
	SaleProxy.SendUnGrounding(self.data.id)
end

function SubMySaleItem:_DisposeReference()
	-- self._imgIcon = nil
	-- self._imgQuality = nil
	self._baseIconItem:Dispose()
	self._baseIconItem = nil
	self._btnReGrounding = nil
	self._btnUnGrounding = nil
	self._productInfo = nil
end

function SubMySaleItem:_DisposeListener()
	UIUtil.GetComponent(self._btnReGrounding, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnReGrounding = nil;
	UIUtil.GetComponent(self._btnUnGrounding, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnUnGrounding = nil;
end

function SubMySaleItem:UpdateItem(data)
	self.data = data
	if(self.data) then
		self._productInfo:Init({spId = self.data.configData.id, am = 1})
		-- ProductManager.SetIconSprite(self._imgIcon, self.data.configData.icon_id)
		-- self._imgQuality.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
		self._baseIconItem:UpdateItem(self.data.configData)
		self._txtName.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
		self._txtName.text = self.data.configData.name
		self._txtCount.text = tostring(self.data.num)
		self._txtPrice.text = tostring(self.data.price)
		self._txtTotalPrice.text = tostring(self.data.price * self.data.num)
		self._txtLevel.text = tostring(self.data.configData.lev)
		local time = GetTimeMillisecond()
		if(time > self.data.et) then
			self._gotip:SetActive(true)
			self._goOverdueTag:SetActive(true)
			self._btnReGrounding.gameObject:SetActive(true)
		else
			self._gotip:SetActive(false)			
			self._goOverdueTag:SetActive(false)
			self._btnReGrounding.gameObject:SetActive(false)
		end
		
		
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