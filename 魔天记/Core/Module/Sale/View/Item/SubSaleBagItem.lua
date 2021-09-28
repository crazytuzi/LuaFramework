require "Core.Module.Common.UIItem"
local SaleIconItem = require "Core.Module.Sale.View.Item.SaleIconItem"

SubSaleBagItem = class("SubSaleBagItem", UIItem);
function SubSaleBagItem:New()
	self = {};
	setmetatable(self, {__index = SubSaleBagItem});
	return self
end


function SubSaleBagItem:_Init()
	self:_InitReference();
	self:_InitListener();
	self:UpdateItem(self.data)
end

function SubSaleBagItem:_InitReference()
	-- self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
	-- self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
	self._baseIconItem = SaleIconItem:New()
	self._baseIconItem:Init(self.gameObject)
	self._txtNum = UIUtil.GetChildByName(self.transform, "UILabel", "num")
	self._tip = UIUtil.GetChildByName(self.transform, "UISprite", "tip")
	-- self._tip = UIUtil.GetChildByName(self.transform, "UISprite", "tip")
	self._goDisable = UIUtil.GetChildByName(self.transform, "disable").gameObject
	self._goUnUseTag = UIUtil.GetChildByName(self.transform, "unUse").gameObject
	
end

function SubSaleBagItem:_InitListener()
	self._onClickItem = function() self:_OnClickItem() end	
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end

function SubSaleBagItem:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function SubSaleBagItem:_DisposeReference()
	-- self._imgIcon = nil
	-- self._imgQuality = nil
	self._baseIconItem:Dispose()
	self._baseIconItem = nil	
end

function SubSaleBagItem:_DisposeListener()
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickItem = nil;
end

function SubSaleBagItem:UpdateItem(data)
	self.data = data
	if(self.data) then
		self._baseIconItem:SetActive(true)
		self._baseIconItem:UpdateItem(self.data.configData)
		
		-- self._imgQuality.gameObject:SetActive(true)
		-- self._imgIcon.gameObject:SetActive(true)
		-- self._imgQuality.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
		-- ProductManager.SetIconSprite(self._imgIcon, self.data.configData.icon_id)
		self._txtNum.text = tostring(self.data.am)
		
		if(self.data.configData.type == ProductManager.type_1) then
			
			local kind = self.data.configData.kind;
			local eqbagInfo = EquipDataManager.GetProductByKind(kind);
			
			if(self.data:IsFitMyCareer()) then
				if eqbagInfo == nil then
					self._tip.spriteName = "up";
					self._tip.gameObject:SetActive(true);
				else
					
					-- 获取在背包中的 属性
					-- local eq_bag_att = ProductCtrl.GetEquipAllAtt(eqbagInfo, false);
					-- 对应装备栏里的总 战斗力
					local eq_bag_fight = eqbagInfo:GetFight()
					-- 背包中的 属性
					-- local bag_att = ProductCtrl.GetEquipAllAtt(self.data, false);
					local bag_fight = self.data:GetFight();
					
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
				
			else-- 不属于自己的职业
				self._tip.gameObject:SetActive(false)
				self._goDisable:SetActive(true)	
				self._goUnUseTag:SetActive(true)	
			end		
			
		else --不是装备
			self._tip.gameObject:SetActive(false)
			self._goDisable:SetActive(false)
			self._goUnUseTag:SetActive(false)				
			
		end
	else--没有数据
		self._tip.gameObject:SetActive(false)
		self._goDisable:SetActive(false)
		self._goUnUseTag:SetActive(false)	
		self._baseIconItem:SetActive(false)
		self._txtNum.text = ""
	end
end

function SubSaleBagItem:_OnClickItem()
	
	if(self.data) then
		SaleProxy.SendGetRecentPrice(self.data.configData.id)
		SaleManager.SetCurSelectItem(self.data)
		ModuleManager.SendNotification(SaleNotes.UPDATE_SELECT_ITEM)
	end
end 