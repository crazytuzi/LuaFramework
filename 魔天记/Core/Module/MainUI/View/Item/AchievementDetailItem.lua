require "Core.Module.Common.UIItem"
require "Core.Module.Common.StarItem"

AchievementDetailItem = UIItem:New();

function AchievementDetailItem:_Init()
	self._starPhalanxInfo = UIUtil.GetChildByName(self.gameObject, "LuaAsynPhalanx", "phalanx1")
	self._starPhalanx = Phalanx:New()
	self._starPhalanx:Init(self._starPhalanxInfo, StarItem)
	self._txtNum1 = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtNum1")
	self._txtNum2 = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtNum2")
	
	self._imgIcon1 = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon1")
	self._imgIcon2 = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon2")
	
	
	self._slider = UIUtil.GetChildByName(self.gameObject, "UISlider", "1/slider")
	self._btnGet = UIUtil.GetChildByName(self.gameObject, "UIButton", "2/btnGet")
	self._txtName = UIUtil.GetChildByName(self.gameObject, "UILabel", "name")
	self._txtCondition = UIUtil.GetChildByName(self.gameObject, "UILabel", "condition")
	self._txtValue = UIUtil.GetChildByName(self.gameObject, "UILabel", "1/slider/txtValue")
	self._state = {}
	for i = 1, 3 do
		self._state[i] = UIUtil.GetChildByName(self.gameObject, tostring(i)).gameObject
	end
	self._onBtnGetClick = function(go) self:_OnBtnGetClick() end
	UIUtil.GetComponent(self._btnGet, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onBtnGetClick);
	self:UpdateItem(self.data);
end

function AchievementDetailItem:_OnBtnGetClick()
	MainUIProxy.SendGetAchievementReward(self.data.id)
end

function AchievementDetailItem:_Dispose()
	UIUtil.GetComponent(self._btnGet, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onBtnGetClick = nil
	self._state = nil
	
	if(self._starPhalanx) then
		self._starPhalanx:Dispose()
		self._starPhalanx = nil		
	end
end

function AchievementDetailItem:UpdateItem(data)
	self.data = data
	if self.data then
		local star = {}
		local curStar = self.data.star
		for i = 1, self.data.max_star do
			if(i <= curStar) then
				star[i] = true
			else
				star[i] = false
			end
		end
		self._txtName.text = self.data.name
		self._starPhalanx:Build(1, self.data.max_star, star)
		for i = 1, 3 do
			self._state[i]:SetActive(false)
		end
		
		if(self.data) then
			local count = 1
			for k, v in pairs(self.data.rewards) do
				local item = ProductManager.GetProductById(v.id)
				self["_txtNum" .. count].text = tostring(v.num)
				ProductManager.SetIconSprite(self["_imgIcon" .. count], item.icon_id)
				
				-- if(v.id == SpecialProductId.Money) then
				-- 	self._txtLingshi.text = tostring(v.num)
				-- elseif(v.id == SpecialProductId.BGold) then
				-- 	self._txtXianyu.text = tostring(v.num)
				-- end
				count = count + 1
			end
		end
		self._state[self.data.state + 1]:SetActive(true)
		
		-- 0未达到 1已达到 2已领奖
		if(self.data.state == 0) then
			self._slider.value = self.data.curNum / self.data.number
			self._txtValue.text = self.data.curNum .. "/" .. self.data.number
			local t = {["["] = "[" .. ColorDataManager.ConventToColorCode(ColorDataManager.Get_red()) .. "]", ["]"] = "[-]"}
			self._txtCondition.text = "[ceecff]" .. string.gsub(self.data.des, ".", t) .. "[-]"
		elseif(self.data.state == 1) then
			local t = {["["] = "", ["]"] = ""}
			self._txtCondition.text = ColorDataManager.GetColorText(ColorDataManager.Get_green(), string.gsub(self.data.des, ".", t))
		elseif(self.data.state == 2) then
			local t = {["["] = "", ["]"] = ""}
			self._txtCondition.text = ColorDataManager.GetColorText(ColorDataManager.Get_white(), string.gsub(self.data.des, ".", t))
		end
		
	end
end
