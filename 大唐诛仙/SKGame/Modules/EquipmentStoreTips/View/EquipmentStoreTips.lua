EquipmentStoreTips = BaseClass(LuaUI)
function EquipmentStoreTips:__init( ... )
	self.URL = "ui://yalu98wx8y9r7";
	self:__property(...)
	self:Config()
end

-- Set self property
function EquipmentStoreTips:SetProperty( ... )
end

-- start
function EquipmentStoreTips:Config()
	self:InitEvent()
	self:InitUI()
end

-- wrap UI to lua
function EquipmentStoreTips:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("EquipmentStoreTipsUI","EquipmentStoreTips");

	self.mask = self.ui:GetChild("mask")
	self.imageTips = self.ui:GetChild("imageTips")
	self.labelDate = self.ui:GetChild("labelDate")
	self.btnEquipBoxOpen = self.ui:GetChild("btnEquipBoxOpen")
	self.btnClose = self.ui:GetChild("btnClose")
	self.loaderBG = self.ui:GetChild("loaderBG")
end

-- Combining existing UI generates a class
function EquipmentStoreTips.Create( ui, ...)
	return EquipmentStoreTips.New(ui, "#", {...})
end

function EquipmentStoreTips:__delete()
	GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.EquipmentStoreTips, show = false, isClose = true})
end

function EquipmentStoreTips:InitEvent()
	self.btnClose.onClick:Add(function()
		UIMgr.HidePopup(self.ui)
	end)

	self.btnEquipBoxOpen.onClick:Add(function()
		UIMgr.HidePopup(self.ui)
		MallController:GetInstance():OpenMallPanel(nil, 0 , 7)
	end)
end

function EquipmentStoreTips:InitUI()
	local _ , _ , startTime , endTime = EquipmentStoreTipsModel:GetInstance():GetStartEndTime(1)
	self.labelDate.text = StringFormat("活动时间:{0}-{1}" , startTime , endTime)
	self.loaderBG.url = "Icon/EquipmentStoreTips/di"
end
