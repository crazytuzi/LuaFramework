WakanSelectItem = BaseClass(LuaUI)

WakanSelectItem.CurSelectItem = nil
function WakanSelectItem:__init(...)
	self.URL = "ui://jh3vd6rknkol1j";
	self:__property(...)
	self:Config()
end

function WakanSelectItem:SetProperty(...)
	
end

function WakanSelectItem:Config()
	
end

function WakanSelectItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Wakan","WakanSelectItem");

	self.n0 = self.ui:GetChild("n0")
	self.select = self.ui:GetChild("select")
	self.n4 = self.ui:GetChild("n4")
	self.levelTxt = self.ui:GetChild("levelTxt")
	self.downEft = self.ui:GetChild("downEft")
	self.icon = self.ui:GetChild("icon")
	self.upEft = self.ui:GetChild("upEft")

	self.data = nil
	self.level = -1
	self.part = 0

	self.eftIds = {}

	self:AddEvent()
	self:Reset()
end

function WakanSelectItem:__delete()
	self:RemoveEvent()
	self.data = nil

	self:ClearEft(true)
end

function WakanSelectItem.Create(ui, ...)
	return WakanSelectItem.New(ui, "#", {...})
end

function WakanSelectItem:AddEvent()
	self.ui.onClick:Add(self.OnClickHandler, self)

	self.handler2 = WakanModel:GetInstance():AddEventListener(WakanConst.WakanDataUpdate, function ( data ) self:Refresh() end)
end

function WakanSelectItem:RemoveEvent()
	self.ui.onClick:Remove(self.OnClickHandler, self)

	WakanModel:GetInstance():RemoveEventListener(self.handler2)
end

function WakanSelectItem:Reset()
	self:UnSelect()
end

function WakanSelectItem:OnClickHandler()
	if WakanSelectItem.CurSelectItem then
		WakanSelectItem.CurSelectItem:UnSelect()
	end
	self:Select()
	if self.part == 7 then
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end
end

function WakanSelectItem:Select()
	self.select.visible = true
	WakanSelectItem.CurSelectItem = self
	WakanModel:GetInstance():DispatchEvent(WakanConst.SelectWakanItem, self)
end

function WakanSelectItem:UnSelect()
	self.select.visible = false
end

function WakanSelectItem:Update(part)
	self.part = part
	self:Refresh()
end

function WakanSelectItem:Refresh()
	local wakaninfo = WakanModel:GetInstance():GetPartWakanInfo(self.part)
	if wakaninfo and self.level ~= wakaninfo[2] then
		self:ClearEft()
		self.level = wakaninfo[2]
		self.data = WakanModel:GetInstance():GetWakanDataByLevel(self.level)
		self.icon.url = WakanConst.WakanIcon[self.part]
		self.levelTxt.text = StringFormat("{0}级", self.level)
		local index = 0
		if self.level > 0 then
			index = math.ceil((self.level + 1) / 5)
		else
			index = 1
		end
		self.downEftEntity = nil
		local downId = WakanConst.downEfts[index]
		if downId ~= nil then
			local eftId = EffectMgr.AddToUI(downId, self.downEft, nil, pos, scale, eulerAngles, id, function(eft)
				end)	
			self:AddEftId(eftId)		
		end

		self.upEftEntity = nil
		local upId = WakanConst.upEfts[index]
		if upId ~= nil then
			local eftId = EffectMgr.AddToUI(upId, self.upEft, nil, pos, scale, eulerAngles, id, function(eft)
				end)	
				self:AddEftId(eftId)		
		end
	end
end

function WakanSelectItem:AddEftId(eftId)
	table.insert(self.eftIds, eftId)
end

function WakanSelectItem:ClearEft(destroy)
	for i = 1, #self.eftIds do
		EffectMgr.RealseEffect(self.eftIds[i])
	end
	if destroy then
		self.eftIds = nil
	else
		self.eftIds = {}
	end
end
