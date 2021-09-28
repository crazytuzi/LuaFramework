require "Core.Module.Common.UIItem"


WildBossItem = class("WildBossItem", UIItem);

function WildBossItem:New(transform)
	self = {};
	setmetatable(self, {__index = WildBossItem});
	
	if(transform) then		
		self:Init(transform);
	end
	return self
end

function WildBossItem:_Init()
	self:_InitReference();
	self:_InitListener();
	self:UpdateItem(self.data)
end

function WildBossItem:_InitReference()
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
	self._txtMapName = UIUtil.GetChildByName(self.transform, "UILabel", "mapName")	
	self._txtlevel = UIUtil.GetChildByName(self.transform, "UILabel", "level")
	self._txtTime = UIUtil.GetChildByName(self.transform, "UILabel", "time")
	self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
	self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")

	self._txtIsRec = UIUtil.GetChildByName(self.transform, "UILabel", "txtIsRec")
	if self._txtIsRec then
		self._txtIsRec.gameObject:SetActive(false);
	end

	self._timer = Timer.New(function(val) self:_OnTimerHandler(val) end, 1, - 1);
	self._timer:Start()
end

local jingxingzhong = "[" .. ColorDataManager.ConventToColorCode(ColorDataManager.Get_green()) .. "]" .. LanguageMgr.Get("WildBossItem/jinxingzhong") .. "[-]"
local levelNotEnough = LanguageMgr.Get("WildBossItem/levelNotEnough")
local red = "[" .. ColorDataManager.ConventToColorCode(ColorDataManager.Get_red()) .. "]"
local downtime = red .. LanguageMgr.Get("WildBossItem/downtime")
function WildBossItem:_OnTimerHandler(val)
	local time = GetTime()
	if self.data.rt then
		if(time > self.data.rt) then
			self._txtTime.text = jingxingzhong
			self._timer:Pause(true)
	        ColorDataManager.UnSetGray(self._imgIcon)
		else		
			self._txtTime.text = downtime .. GetTimeByStr1((self.data.rt - time)) .. "[-]"
		end
	end
end

function WildBossItem:_InitListener()
	self._onClick = function(go) self:_OnClick(self) end
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);
end

function WildBossItem:_OnClick()
	MessageManager.Dispatch(WildBossNotes, WildBossNotes.EVENT_SELECT_BOSS, self.data);
end

function WildBossItem:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function WildBossItem:_DisposeListener()
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClick = nil;
end

function WildBossItem:_DisposeReference()
	self._txtName = nil
	self._txtMapName = nil
	self._txtlevel = nil
	self._txtTime = nil
	self._imgIcon = nil	
	
	if(self._timer) then
		self._timer:Stop()
		self._timer = nil
	end
end

function WildBossItem:SetToggleActive(enable)
	self._toggle.value = enable
	if(enable) then
		self:_OnClick()
	end
end


function WildBossItem:UpdateItem(data)
	self.data = data
	
	if(self.data) then
		
		self.gameObject.name = self.data.id;

		local lv = PlayerManager.GetPlayerLevel();

		self._txtName.text = self.data.name
		self._txtlevel.text = GetLvDes(self.data.monsterInfo.level)

		local vipFlag = false;
		if self.data.isVip and VIPManager.GetSelfVIPLevel() < self.data.mapInfo.vip_level then
			vipFlag = true;
		end
		local lvFlag = (lv < self.data.mapInfo.level);

		if lvFlag or vipFlag then
			if lvFlag then
				self._txtTime.text = red .. self.data.mapInfo.level .. levelNotEnough .. "[-]"
			else
				self._txtTime.text = LanguageMgr.GetColor("r", LanguageMgr.Get("WildBossItem/vip", {vip = self.data.mapInfo.vip_level}) );
			end
			
			self._timer:Pause(true)
			ColorDataManager.SetGray(self._imgIcon)			
		else
			ColorDataManager.SetGray(self._imgIcon)
			self._txtTime.text = "";            
			self:_OnTimerHandler()
			self._timer:Pause(false)	
		end
		self._imgIcon.spriteName = self.data.monsterInfo.icon_id
		self._txtMapName.text = self.data.mapInfo.name	

		if self._txtIsRec then
			local showRec = lv >= self.data.rec_level_lower and lv <= self.data.rec_level_upper;
			self._txtIsRec.gameObject:SetActive(showRec);
		end	
	end
end 

function WildBossItem:UpdateStatus(data)
	self:_OnTimerHandler()
end