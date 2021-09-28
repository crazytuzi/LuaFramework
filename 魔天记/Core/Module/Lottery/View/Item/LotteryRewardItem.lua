require "Core.Module.Common.UIItem"
local EquipQualityEffect = require "Core.Module.Common.EquipQualityEffect"

LotteryRewardItem = class("LotteryRewardItem", UIItem)
local popTime = 0.25
local showDelay = 0.5

function LotteryRewardItem:_Init()
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
	self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
	self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
	self._imgBg = UIUtil.GetChildByName(self.transform, "UISprite", "bg")
	self._txtNum = UIUtil.GetChildByName(self.transform, "UILabel", "num")
	self._starEffect = UIEffect:New()
	self._starEffect:Init(self._imgIcon.transform, self._imgBg, 1, "ui_treasury1")
	-- self._qualityEffect = UIEffect:New()
	-- self._qualityEffect:Init(self.transform, self._imgBg, 0, "ui_treasury2")
	self._qualityEffect = UIUtil.GetChildByName(self.transform, "UI_LotteryEffect").gameObject
	
	self._eqQualityspecEffect = EquipQualityEffect:New();
	self._uiEffect = UIUtil.GetChildByName(self.transform, "UISprite", "uiEffect");
	if self._uiEffect ~= nil then
		self._uiEffect.gameObject:SetActive(false);
	end
	
	
	self:UpdateItem(self.data);
end

function LotteryRewardItem:UpdateItem(data)
	self.data = data
	if(self.data == nil) then return end
	if(self._txtNum) then
		self._txtNum.text =(self.data.am > 0) and tostring(self.data.am) or ""
	end
	self._starEffect:Stop()
	self._qualityEffect:SetActive(fasle)
	
	self._txtName.text = self.data.configData.name
	self._txtName.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
	if(self._imgBg) then
		if(self.data.configData.quality <= 4) then
			self._imgBg.spriteName = "bg1"
		else
			self._imgBg.spriteName = "bg2"
		end
	end
	
	if(self.data) then
		local quality = self.data.configData.quality;
		local type = self.data.configData.type;
		if self._uiEffect == nil then
			self._eqQualityspecEffect:TryCheckEquipQualityEffect(self._imgQuality.transform, self._imgQuality, type, quality);
		else
			self._eqQualityspecEffect:TryCheckEquipQualityEffectForUISprite(self._uiEffect, type, quality);
		end
	else
		self._eqQualityspecEffect:StopEffect()
	end
	
	
	self._imgQuality.color = ColorDataManager.GetColorByQuality(self.data.configData.quality)
	
	ProductManager.SetIconSprite(self._imgIcon, self.data.configData.icon_id)
	self:ShowEffect()
end

function LotteryRewardItem:ShowEffect()
	self.index = self.index or 1
	self.transform.localScale = Vector3.one * 0.01
	local func = function() self:Show() end
	if(self._timer) then
		self._timer:Stop()
	end
	
	if(self._corutine) then
		coroutine.stop(self._corutine)
		self._corutine = nil
	end
	
	self._timer = Timer.New(func, self.index * showDelay, 1)
	self._timer:Start()
end

function LotteryRewardItem:Show()
	self._timer:Stop()
	self._timer = nil
	self.transform.localScale = Vector3.one * 0.01
	self.time = 0
	if(self.index > 10 and self.index % 10 == 1) then
		ModuleManager.SendNotification(LotteryNotes.UPDATE_SCROLLVIEW)
	end
	UISoundManager.PlayUISound(UISoundManager.ui_compose)
	
	
	self._corutine = coroutine.start(self._Showing, self)
end

function LotteryRewardItem:_Showing()
	while self.time < popTime do
		coroutine.step();
		self.time = self.time + Timer.deltaTime;
		self.scale = EaseUtil.easeInQuad(0.1, 1, self.time / popTime)
		self.transform.localScale = Vector3.New(self.scale, self.scale, 1);
	end
	self.transform.localScale = Vector3.one;
	self._starEffect:Play()
	if(self.data.configData.quality > 4) then
		self._qualityEffect:SetActive(true)				
	end
	
	
end

function LotteryRewardItem:_Dispose()
	-- UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	-- self._onClickItem = nil;
	if(self._corutine) then
		coroutine.stop(self._corutine)
		self._corutine = nil
	end
	if self._timer then self._timer:Stop() self.timer = nil end
	
	self._starEffect:Dispose()
	
	self._eqQualityspecEffect:Dispose()
	self._eqQualityspecEffect = nil
	
	self._qualityEffect:SetActive(fasle)
	
	self._starEffect = nil
	self._qualityEffect = nil	
	self._imgBg = nil
	self._imgQuality = nil
	self._imgIcon = nil
end

function LotteryRewardItem:_OnClickItem()
	ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, {info = self.data, type = ProductCtrl.TYPE_FROM_OTHER});
end

