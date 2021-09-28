PlayerItem = class("PlayerItem");


function PlayerItem:New()
	self = {};
	setmetatable(self, {__index = PlayerItem});
	return self
end


function PlayerItem:Init(gameObject)
	
	self.gameObject = gameObject
	
	
	self.selectIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "selectIcon");
	self.hasAddIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "hasAddIcon");
	self.heroIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "heroIcon");
	
	self.name_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "name_txt");
	self.powerTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "powerTxt");
	self.lv_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "lv_txt");
	self._imgLevelBg = UIUtil.GetChildByName(self.gameObject, "UISprite", "lvBg")
	self.addBt = UIUtil.GetChildByName(self.gameObject, "UIButton", "addBt");
	
	self.vipIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "vipIcon");
	
	
	self.addBtHandler = function(go) self:AddBtHandler(self) end
	UIUtil.GetComponent(self.addBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self.addBtHandler);
	
	
	
	self:SetSelect(false);
	self:SetHasAdd(false)
	
end



function PlayerItem:AddBtHandler()
	
	
	AddFriendsProxy.TryAddFriend(self.data.id, self)
end


function PlayerItem:AddFriendSuccessResult()
	
	self:SetHasAdd(true)
	self.addBt.gameObject:SetActive(false);
end

function PlayerItem:SetData(data)
	
	self.data = data;
	
	if data == nil then
		
		self:SetActive(false);
	else
		
		self.name_txt.text = data.name;
		self.powerTxt.text = data.fight;
		self.lv_txt.text = GetLv(data.level);
		self._imgLevelBg.spriteName = data.level <= 400 and "levelBg1" or "levelBg2"
		self._imgLevelBg:MakePixelPerfect()
		self.heroIcon.spriteName = data.kind;
		
		self:SetHasAdd(false)
		self.addBt.gameObject:SetActive(true);
		self:SetActive(true);
		
		local vip = data.vip;
		if vip == nil then
			vip = 0;
		end
		
		
		if vip ~= nil and vip > 0 then
			self.vipIcon.gameObject:SetActive(true);
			self.vipIcon.spriteName = VIPManager.GetVipIconByVip(vip);
		else
			self.vipIcon.gameObject:SetActive(false);
		end
		
		
	end
	
end

function PlayerItem:SetActive(v)
	self.gameObject.gameObject:SetActive(v);
end

function PlayerItem:SetSelect(v)
	self.selectIcon.gameObject:SetActive(v);
end

function PlayerItem:SetHasAdd(v)
	self.hasAddIcon.gameObject:SetActive(v);
end


function PlayerItem:Dispose()
	
	UIUtil.GetComponent(self.addBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self.addBtHandler = nil;
	
	self.gameObject = nil;
	
	self.selectIcon = nil;
	self.hasAddIcon = nil;
	self.heroIcon = nil;
	
	self.name_txt = nil;
	self.powerTxt = nil;
	self.lv_txt = nil;
	
	self.addBt = nil;
	
	self.addBtHandler = nil;
	
end 