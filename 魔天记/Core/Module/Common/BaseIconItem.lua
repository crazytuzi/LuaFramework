require "Core.Module.Common.UIItem"
local EquipQualityEffect = require "Core.Module.Common.EquipQualityEffect"

local BaseIconItem = class("BaseIconItem", UIItem);

function BaseIconItem:New()
	self = {};
	setmetatable(self, {__index = BaseIconItem});
	return self
end

function BaseIconItem:_Init()
	self._onClickType = 1
	self:_InitReference();
	self:_InitListener();
	self:_InitOther()
	self:UpdateItem(self.data)
end

function BaseIconItem:_InitReference()
	self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon");
	self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality");

    self._eqQualityspecEffect = EquipQualityEffect:New();
    self._uiEffect = UIUtil.GetChildByName(self.transform, "UISprite", "uiEffect");
    if self._uiEffect ~= nil then
        self._uiEffect.gameObject:SetActive(false);
    end

end

function BaseIconItem:_InitListener()
	self._onClickIcon = function(go) self:_OnClickIcon() end
	UIUtil.GetComponent(self._imgIcon, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickIcon);
end

--没有设置默认打开物品简介
function BaseIconItem:_OnClickIcon()
	if(self._handler) then
		self._handler()
	else	
		if(self._onClickType == 1)	then
			ProductCtrl.ShowProductTip(self.data.id, ProductCtrl.TYPE_FROM_OTHER, 1, ProductManager.ST_TYPE_IN_OTHER)			
		elseif self._onClickType == 2 then
			ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL, {id = self.data.id, updateNote = self._updateNotice})
		end
	end
end

function BaseIconItem:_InitOther()
	
       

end

function BaseIconItem:_Dispose()

     self._eqQualityspecEffect:Dispose()
    self._eqQualityspecEffect = nil

	self._handler = nil
	UIUtil.GetComponent(self._imgIcon, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickIcon = nil;
	self:_DisposeOther()
end

function BaseIconItem:_DisposeOther()
	
end

--data为配置表数据
function BaseIconItem:UpdateItem(data)
	self.data = data
	if(self.data) then	
		ProductManager.SetIconSprite(self._imgIcon, self.data.icon_id)
		self._imgQuality.color = ColorDataManager.GetColorByQuality(self.data.quality)
	end

     if (self.data) then
        local quality = self.data.quality;
        local type = self.data.type;
        if self._uiEffect == nil then
            self._eqQualityspecEffect:TryCheckEquipQualityEffect(self._imgQuality.transform, self._imgQuality, type, quality);
        else
            self._eqQualityspecEffect:TryCheckEquipQualityEffectForUISprite(self._uiEffect, type, quality);
        end
    else
        self._eqQualityspecEffect:StopEffect()
    end


	self:_UpdateOther()
end

function BaseIconItem:_UpdateOther()
	
end

function BaseIconItem:SetOnClickIconHandler(handler)
	self._handler = handler
end

function BaseIconItem:SetActive(enable)
	self._imgIcon.gameObject:SetActive(enable)
	self._imgQuality.gameObject:SetActive(enable)	

     if self._uiEffect ~= nil then
       if self._eqQualityspecEffect.active then
          self._uiEffect.gameObject:SetActive(enable);
       end 
       
    end
end

function BaseIconItem:SetOnClickType(v,updateNotice)
	self._onClickType = v
	self._updateNotice = updateNotice
end

function BaseIconItem:SetUpdateNotice()
	
end

return BaseIconItem 