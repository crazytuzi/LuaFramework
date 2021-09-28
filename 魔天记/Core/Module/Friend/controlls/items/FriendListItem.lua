FriendListItem = class("FriendListItem", UIItem);

function FriendListItem:New()
	self = {};
	setmetatable(self, {__index = FriendListItem});
	return self
end

function FriendListItem:Init(gameObject)
	
	self.gameObject = gameObject
	
	self.selectIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "selectIcon");
	self.heroIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "heroIcon");
	self.strangerIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "strangerIcon");
	self.ntipIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "ntipIcon");
	
	self.name_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "name_txt");
	self.powerTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "powerTxt");
	self.lv_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "lv_txt");
	self.lv_txt.text = "0";
	
	self.vipIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "vipIcon");
	self._imgLevelBg = UIUtil.GetChildByName(self.gameObject, "UISprite", "lvBg")
	self.clickHandler = function(go) self:ClickHandler(self) end
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self.clickHandler);
	
	self:SetSelect(false);
	
	self.strangerIcon.gameObject:SetActive(false);
	self.enble = false;
	
	self.vipIcon.gameObject:SetActive(false);
	
end

function FriendListItem:SetSelect(v)
	self.selectIcon.gameObject:SetActive(v);
	
	if self.curr_data ~= nil then
		self.curr_data.selected = v;
		
		if FriendNotes.firend_curr_select_classify == FriendNotes.classify_btnNew and v then
			FriendDataManager.curr_select_stranger_id = self.curr_data.id .. "";
		end
		
		FriendDataManager.SetHasNewChatMsg(self.curr_data.id);
		self:CheckChatTip();
	end
	
end

function FriendListItem:ClickHandler()
	MessageManager.Dispatch(FriendNotes, FriendNotes.MESSAGE_FRIENDLISTITEM_SELECTED, self);
end

function FriendListItem:SetActive(v)
	self.enble = v;
	self.gameObject.gameObject:SetActive(v);
end

--  S <-- 11:57:36.480, 0x1202, 12, {"l":[{"level":0,"kind":0,"sex":0,"is_online":1,"id":"10100014","type":1,"name ":"路华丰"
-- {"is_online":1,"id":"10100224","id":"204","type":1,"name ":"江小铃"}
function FriendListItem:SetData(data, i)
	
	self.selectIcon.gameObject:SetActive(false);
	
	
	self.curr_data = data;
	
	if self.curr_data ~= nil then
		
		self.name_txt.text = self.curr_data.name .. "";
		self.powerTxt.text = self.curr_data.fight .. "";
		self.lv_txt.text = GetLv(self.curr_data.level) .. "";
		self._imgLevelBg.spriteName = self.curr_data.level <= 400 and "levelBg1" or "levelBg2"
		self._imgLevelBg:MakePixelPerfect()
		self.heroIcon.spriteName = data.kind .. "";
		
		local is_online = self.curr_data.is_online;
		
		if is_online == 1 then
			ColorDataManager.UnSetGray(self.heroIcon);
		else
			ColorDataManager.SetGray(self.heroIcon);
		end
		
		if FriendNotes.firend_curr_select_classify == FriendNotes.classify_btnNew then
			if(self.curr_data.id .. "") == FriendDataManager.curr_select_stranger_id then
				self:ClickHandler();
			end
		else
			if self.curr_data.selected then
				self:ClickHandler();
			end
		end
		
		---------------- vip  ------------------------------------------------
		local vip = data.vip;
		
--		if vip ~= nil and vip > 0 then
--			self.vipIcon.gameObject:SetActive(true);
--			self.vipIcon.spriteName = VIPManager.GetVipIconByVip(vip);
--		else
--			self.vipIcon.gameObject:SetActive(false);
--		end
        self.vipIcon.gameObject:SetActive(false)
	    local vc = ColorDataManager.Get_Vip(data.vip)	
	    self.name_txt.text = vc .. self.name_txt.text
		
		
		-----------------------------------------------------------------------------------------------------------------
		self:SetActive(true);
		
		local type = self.curr_data.type;
		
		local t_id = self.curr_data.id;
		local myfd = FriendDataManager.GetFriend(t_id);
		
		-- if type == FriendDataManager.type_friend or type == FriendDataManager.type_enemy then
		if myfd ~= nil then
			self.strangerIcon.gameObject:SetActive(false);
		else
			self.strangerIcon.gameObject:SetActive(true);
		end
		
		self:CheckChatTip();
	end
	
end


function FriendListItem:CheckChatTip()
	
	if self.enble and self.curr_data ~= nil then
		
		local id = self.curr_data.id;
		local b = FriendDataManager.GetNeedShowTip(id);
		
		if b then
			
			self:NtipIconEnbel(true);
		else
			self:NtipIconEnbel(false);
		end
		
	end
	
end



function FriendListItem:NtipIconEnbel(v)
	
	self.ntipIcon.gameObject:SetActive(v);
	self.ntipIconEnbel = v;
	
end


function FriendListItem:_Dispose()
	
	
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self.clickHandler = nil;
	
	self.gameObject = nil;
	
	self.selectIcon = nil;
	self.heroIcon = nil;
	self.strangerIcon = nil;
	self.ntipIcon = nil;
	
	self.name_txt = nil;
	self.powerTxt = nil;
	self.lv_txt = nil;
	
	
end 