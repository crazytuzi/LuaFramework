require "Core.Module.Common.UIItem"
PetAddExpItem = class("PetAddExpItem", UIItem);
local notice = LanguageMgr.Get("Pet/PetAddExpItem/levelUpNotice")
local notEnought = LanguageMgr.Get("Pet/PetAddExpItem/notEnought")

function PetAddExpItem:New(transform)
	self = {};
	setmetatable(self, {__index = PetAddExpItem});
	return self
end
local timeInterval = 0.5
function PetAddExpItem:_Init()
	
	self._canNotAdd = false
	self._timeRate = 0.2
	self._useCount = 0;
	self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "itemIcon");
	self._lastime = os.clock()
	self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "itemQuality");	
	self._txtCount = UIUtil.GetChildByName(self.transform, "UILabel", "txtCount")
	self._goTip = UIUtil.GetChildByName(self.transform, "tip").gameObject
	self._timer = Timer.New(function() self:_OnTickHandler(false) end, 0.1, - 1, false);
	self._timer:Start()
	self._timer:Pause(true)
	self._onClickBtnItem = function(go, isPress) self:_OnClickBtnItem(isPress) end
	UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RegisterDelegate("OnPress", self._onClickBtnItem);
	self._itemCount = 0;
	self._timeInterval = timeInterval
	self._isUpdate = false
	self:UpdateItem(self.data);
	MessageManager.AddListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, PetAddExpItem.SetRedPoint, self)
end

function PetAddExpItem:SetRedPoint()
	 
	if(self._isUpdate) then
		self._isUpdate = false
		local pet = PetManager.GetCurrentPetdata()
		local isMax = pet:GetIsMaxLevel()
		local count = BackpackDataManager.GetProductTotalNumBySpid(self.data)
		 
		self._goTip:SetActive(not isMax and(count > 0))
	end
end

function PetAddExpItem:_OnTickHandler(isFirst)
	
	if(not isFirst) then
		if(self._timeInterval > 0) then
			self._timeInterval = self._timeInterval - 0.1
			return
		end
	end
	
	if(isFirst) then
		local t = os.clock()
		local interval = t - self._lastime	
		if(interval < 0.1) then			
			return
		end
		self._lastime = t
	end
	self._useCount = self._useCount + 1
	
	if(((self._useCount * self._itemExp) > self._expLimit)) then
		self._timer:Pause(true);
		if(self._useCount > self._itemCount) then
			self._useCount = self._itemCount
		end
		local suc = false
		if(self._useCount > 0) then
			suc =	PetProxy.SendPetUpdateLevel(self.data, self._useCount)
		end
		
		if(suc) then		
			self._txtCount.text = self._itemCount - self._useCount
		end
		self._useCount = 0
		return
	else
		if(self._useCount > self._itemCount) then
			self._timer:Pause(true);
			self._useCount = self._itemCount
			
			if(PetProxy.SendPetUpdateLevel(self.data, self._useCount)	) then				
				self._txtCount.text = self._itemCount - self._useCount
			end
			self._useCount = 0
			return
		end
	end
	
	self._txtCount.text = self._itemCount - self._useCount	
end

function PetAddExpItem:UpdateItem(data)
	 
	self.data = data
	if(data == nil) then return end
	
	self._isUpdate = true
	self._itemData = ProductManager.GetProductById(self.data)
	
	if(self._itemData == nil) then
		return
	end
	
	ProductManager.SetIconSprite(self._imgIcon, self._itemData.icon_id)
	self._imgQuality.color = ColorDataManager.GetColorByQuality(self._itemData.quality)
	local pet = PetManager.GetCurrentPetdata()
	local isMax = pet:GetIsMaxLevel()
	local count = BackpackDataManager.GetProductTotalNumBySpid(self.data)
	 
	self._txtCount.text = count .. ""
	self._goTip:SetActive(not isMax and(count > 0))
end

function PetAddExpItem:_OnClickBtnItem(isPress)
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PET_LVUP_CLICK);
	
	if(isPress) then
		self._itemCount = BackpackDataManager.GetProductTotalNumBySpid(self.data)
		if(self._itemCount == 0) then
			MsgUtils.ShowTips(nil, nil, nil, notEnought);
			ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL,
			{id = self._itemData.id, msg = PetNotes.CLOSE_PETPANEL, updateNote = PetNotes.UPDATE_PETPANEL})
			return
		end
		local currentPet = PetManager.GetCurrentPetdata()
		local level = currentPet:GetLevel()
		if(level >= PetManager.MAXPETLEVEL) then
			log("已经达到最高等级")	
			return
		end
		
		if(level >= PlayerManager.GetPlayerInfo().level) then			
			MsgUtils.ShowTips(nil, nil, nil, notice);		
			return
		end
		
		self._itemExp = tonumber(self._itemData.fun_para[1])
		self._expLimit = 0 --
		local maxLevel = math.min(PlayerManager.GetPlayerInfo().level, PetManager.MAXPETLEVEL)
		
		
		if(level == maxLevel) then
			self._expLimit = 0
			self._useCount = 0
		else
			for i = maxLevel - 1, level, - 1 do
				self._expLimit = self._expLimit + PetManager.GetPetUpdateConfig(i).levelup_cost
			end
			
			self._expLimit = math.max(self._expLimit - currentPet:GetExp(), 0)--计算出经验上线
			
			self:_OnTickHandler(true)
			if(self._itemCount > 0) then
				self._timer:Pause(false)
			end
		end
	else
		self._timer:Pause(true)
		self._timeInterval = timeInterval
		
		if(self._useCount > 0) then			
			if(PetProxy.SendPetUpdateLevel(self.data, self._useCount)) then			
				self._txtCount.text = self._itemCount - self._useCount
			end
			self._useCount = 0
		end
		
	end
end

function PetAddExpItem:_Dispose()
	MessageManager.RemoveListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, PetAddExpItem.SetRedPoint, self)
	
	UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnPress");
	self._onClickBtnItem = nil;
	if(self._timer ~= nil) then
		self._timer:Stop();
		self._timer = nil
	end
end


