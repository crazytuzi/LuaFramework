require "Core.Module.Common.UIComponent"

SubNewTrumpRefineItem = class("SubNewTrumpRefineItem", UIItem);
local stateColor =
{
	[1] = {["bc"] = Color.New(190 / 255, 190 / 255, 190 / 255), ["tc"] = Color.New(1, 1, 1), ["ec"] = Color.New(48 / 255, 48 / 255, 48 / 255)},
	[2] = {["bc"] = Color.New(133 / 255, 219 / 255, 1), ["tc"] = Color.New(228 / 255, 249 / 255, 1), ["ec"] = Color.New(79 / 255, 101 / 255, 254 / 255, 34 / 255)},
}
function SubNewTrumpRefineItem:New()
	self = {};
	setmetatable(self, {__index = SubNewTrumpRefineItem});
	return self
end


function SubNewTrumpRefineItem:_Init()
	self:_InitReference();
	self:_InitListener();
	self:UpdateItem(self.data)
end

function SubNewTrumpRefineItem:_InitReference()
	self._txt1 = UIUtil.GetChildByName(self.gameObject, "UILabel", "txt1");
	self._txt2 = UIUtil.GetChildByName(self.gameObject, "UILabel", "txt2");
	self._txtName = UIUtil.GetChildByName(self.gameObject, "UILabel", "name");
	self._txtValue1 = UIUtil.GetChildByName(self.gameObject, "UILabel", "slider1/value1");
	self._txtValue2 = UIUtil.GetChildByName(self.gameObject, "UILabel", "slider2/value2");
	self._slider1 = UIUtil.GetChildByName(self.gameObject, "UISlider", "slider1")
	self._slider2 = UIUtil.GetChildByName(self.gameObject, "UISlider", "slider2")
	self._toggle = UIUtil.GetComponent(self.gameObject, "UIToggle")
	self._goTip = UIUtil.GetChildByName(self.gameObject, "tip").gameObject
	self._effect = UIEffect:New()	
	
	self._effect:Init(self.transform, self._slider1.foregroundWidget, 0, "ui_refining_3")
 
end

function SubNewTrumpRefineItem:_OnClickItem()	
	NewTrumpManager.SetSelectRefineLevel(self.data.level)
	ModuleManager.SendNotification(NewTrumpNotes.UPDATE_NEWTRUMPSELECTREFINEINFO)
end

function SubNewTrumpRefineItem:SetToggleActive(enable)
	self._toggle.value = enable
	self:_OnClickItem()
end

function SubNewTrumpRefineItem:_InitListener()
	self._onClickItem = function(go) self:_OnClickItem() end
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end

function SubNewTrumpRefineItem:_Dispose()
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickItem = nil;
	
	self:_DisposeReference();
end

function SubNewTrumpRefineItem:_DisposeReference()
	self._effect:Dispose()
	self._effect = nil
 
	self._txt1 = nil;
	self._txt2 = nil;
	self._txtName = nil
	self._slider1 = nil
	self._slider2 = nil
	self._txtValue1 = nil
	self._txtValue2 = nil
	self._tip = nil
	self._goTip = nil
end

function SubNewTrumpRefineItem:UpdateItem(data)
	self.data = data
	if(self.data) then
		self._txtName.text = self.data.name
		local p = self.data.curAttr:GetPropertyAndDes()
		if(self.data.state == 0) then
			self._txtName.effectColor = stateColor[1].ec
			self._txtName.gradientTop = stateColor[1].tc
			self._txtName.gradientBottom = stateColor[1].bc
			for k, v in ipairs(p) do
				local value = v.property / self.data.maxAttr[v.key]
				local c = ColorDataManager.Get_white()
				self["_txt" .. k].color = c
				self["_txt" .. k].text = v.des
				self["_slider" .. k].value = value
				self["_slider" .. k].foregroundWidget.color = c
				self["_txtValue" .. k].text = v.property .. "/" .. self.data.maxAttr[v.key]
			end
		elseif self.data.state == 1 then
			self._txtName.effectColor = stateColor[2].ec
			self._txtName.gradientTop = stateColor[2].tc
			self._txtName.gradientBottom = stateColor[2].bc
			for k, v in ipairs(p) do
				local value = v.property / self.data.maxAttr[v.key]
				local c = self:GetColor(value)
				self["_txt" .. k].color = c
				self["_txt" .. k].text = v.des
				self["_slider" .. k].value = value
				self["_slider" .. k].foregroundWidget.color = c
				self["_txtValue" .. k].text = v.property .. "/" .. self.data.maxAttr[v.key]
			end
		end
		local enable =(MoneyDataManager.Get_money() >= self.data.reqMoney)
		enable = enable and(BackpackDataManager.GetProductTotalNumBySpid(self.data.condition[1].itemId) >= self.data.condition[1].itemCount)
		enable = enable and NewTrumpManager.GetCurrentSelectTrump():GetLastLevelIsActive(self.data.level)	
		enable = enable and(HeroController.GetInstance().info.level >= self.data.req_lev)
		self._goTip:SetActive(enable)
		
	end
end

function SubNewTrumpRefineItem:GetColor(v)
	local c = ColorDataManager.GetColorByQuality(0)
	if(v <= 0.25) then
		c = ColorDataManager.GetColorByQuality(1)
	elseif(v <= 0.5) then
		c = ColorDataManager.GetColorByQuality(2)
	elseif(v <= 0.75) then
		c = ColorDataManager.GetColorByQuality(3)
	else
		c = ColorDataManager.GetColorByQuality(4)
	end
	return c
end

function SubNewTrumpRefineItem:PlayUIEffect()
	if(self._effect) then
		self._effect:Play()		
	end
end
