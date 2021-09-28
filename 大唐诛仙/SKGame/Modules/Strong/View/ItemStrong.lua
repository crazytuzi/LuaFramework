ItemStrong = BaseClass(LuaUI)
function ItemStrong:__init( ... )
	self.URL = "ui://vgwyw6jpreao6";
	self:__property(...)
	self:Config()
	self:AddEvent()
end
-- Set self property
function ItemStrong:SetProperty( ... )
end
-- start
function ItemStrong:Config()
	
end

function ItemStrong:AddEvent()
	-- self.handler0 = self.model:AddEventListener(StrongConst.HideEffect, function()
	-- 	self:CleanEffect()
	-- end)
end

-- wrap UI to lua
function ItemStrong:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Strong","ItemStrong");

	self.effect = self.ui:GetChild("effect")
	self.icon = self.ui:GetChild("icon")
	self.title = self.ui:GetChild("title")
	self.des = self.ui:GetChild("des")
	self.btnGo = self.ui:GetChild("btnGo")
	self.isUpIcon = self.ui:GetChild("isUpIcon")
	self.isUpText = self.ui:GetChild("isUpText")

	self.model = StrongModel:GetInstance()
end

function ItemStrong:SetData(data)
	self:CleanEffect()
	self.icon.url = StringFormat("Icon/Strong/{0}", data[1])
	self.title.text = data[2]
	self.isUpIcon.visible = false
	self.isUpText.visible = false
	-- if data[1] == 2013 or data[1] == 2011 or data[1] == 2014 then 
	-- 	self.btnGo.visible = false
	-- else
	-- 	self.btnGo.visible = true
	-- end
	self.btnGo.visible = true
	local wakenlv = self.model.wakenAverageLv
	local skilllv = self.model.skillAverageLv
	local equiplv = self.model.equipAverageLv
	if data[3] == 1 then
		self.des.text = "平均等级："..wakenlv
	elseif data[3] == 2 then
		self.des.text = "平均等级："..skilllv
	elseif data[3] == 3 then
		self.des.text = "平均品质："..equiplv
	else
		self.des.text = data[3]
	end
	self.btnGo.onClick:Add(function()
		StrongCtr:GetInstance():GoLink(data[4])
	end)
	if data[1] == 2013 then
		self.isUpText.visible = self.model.wakenIsred
		self.btnGo.visible = not self.model.wakenIsFull
		self.isUpIcon.visible = self.model.wakenIsFull
	end
	if data[1] == 2011 then
		self.isUpText.visible = self.model.skillIsred
		self.btnGo.visible = not self.model.skillIsFull
		self.isUpIcon.visible = self.model.skillIsFull
	end

	if data[1] == 2013 and self.model.wakenIsred or data[1] == 2011 and self.model.skillIsred or
	  data[1] == 2014 and self.model.equipIsred then 
		local function LoadCallBack(effect)
			if effect then
				if self.effect == nil then
					destroyImmediate(effect)
					return
				end
				local effectObj = GameObject.Instantiate(effect)
				effectObj.transform.localPosition = Vector3.New(-180, 7 , 0)
				effectObj.transform.localScale = Vector3.New(1.2,1.3,1)
		 		effectObj.transform.localRotation = Quaternion.Euler(0, 0, 0)
				self.effect:SetNativeObject(GoWrapper.New(effectObj))
				self.effectObj = effectObj
			end
		end
	end
end

function ItemStrong:CleanEffect()
	if self.effectObj then
		destroyImmediate(self.effectObj)
	end
	self.effectObj = nil
end

-- Combining existing UI generates a class
function ItemStrong.Create( ui, ...)
	return ItemStrong.New(ui, "#", {...})
end
function ItemStrong:__delete()
	-- if self.model then
	-- 	self.model:RemoveEventListener(self.handler0)
	-- end
	self:CleanEffect()
end