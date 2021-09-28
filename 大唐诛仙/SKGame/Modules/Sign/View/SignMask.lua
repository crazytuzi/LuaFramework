--[[
	加在SignPanel的grid上的mask 
]]

SignMask = BaseClass(LuaUI)

function SignMask:__init(...)
	self.URL = "ui://of7roaz1bcb6l";
	self:__property(...)
	self:Config()
	self:RefreshUI()
end

function SignMask:SetProperty(...)
	
end

function SignMask:Config()
	
end

function SignMask:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Sign","SignMask");

	self.img_zhezhao = self.ui:GetChild("n3")
	self.img_select = self.ui:GetChild("n1")
	self.img_buqian = self.ui:GetChild("n4")
	self.img_double = self.ui:GetChild("n5")
	self.effectConn = self.ui:GetChild("n6")
end

function SignMask.Create(ui, ...)
	return SignMask.New(ui, "#", {...})
end

function SignMask:__delete()
	self:CleanEffect()
	self.effectConn = nil
end

function SignMask:LoadEffect(posVet3)
	local function LoadCallBack(effect)
		if effect then
			if self.effectConn == nil then
				destroyImmediate(effect)
				return
			end
			local effectObj = GameObject.Instantiate(effect)
			-- effectObj.transform.localPosition = Vector3.New(3 ,-5 , 0)
			effectObj.transform.localPosition = Vector3.New(4, -5 , 0)
			effectObj.transform.localScale = posVet3
	 		effectObj.transform.localRotation = Quaternion.Euler(0, 0, 0)
	 		self.effectConn.visible = true
			self.effectConn:SetNativeObject(GoWrapper.New(effectObj))
			self.effectObj = effectObj
		end
	end
	self.effectConn.visible = false

	-- 延迟一帧加载,否则有个诡异的位置偏移...
	DelayCall(function()
		if not self.effectConn then return end
		LoadEffect("ui_tbhuanrao_dc",LoadCallBack)
	end, 0.3)
end

function SignMask:CleanEffect()
	if self.effectObj then
		destroyImmediate(self.effectObj)
	end
	self.effectObj = nil
end

function SignMask:SetDouble(isDouble)
	self.img_double.visible = isDouble
end

function SignMask:RefreshUI(state)
	self.effectConn.visible = false
	state = state or SignConst.STATE_GRID.CANNOT_BUQIAN
	--self:CleanEffect()

	if state == SignConst.STATE_GRID.CANNOT_BUQIAN then
		self.effectConn.visible = false
		self.img_select.visible = false
		self.img_zhezhao.visible = false
		self.img_buqian.visible = false
	elseif state == SignConst.STATE_GRID.YILINGQU then
		self.effectConn.visible = false
		self.img_select.visible = true
		self.img_zhezhao.visible = true
		self.img_buqian.visible = false
	elseif state == SignConst.STATE_GRID.CAN_LINGQU then
		self.effectConn.visible = true
		if not self.effectObj then
			self:LoadEffect(Vector3.New(0.9, 0.9, 0.9))
		end
		self.img_select.visible = false
		self.img_zhezhao.visible = false
		self.img_buqian.visible = false
	elseif state == SignConst.STATE_GRID.CAN_BUQIAN then
		self.effectConn.visible = false
		self.img_select.visible = false
		self.img_zhezhao.visible = false
		self.img_buqian.visible = true
	end
end