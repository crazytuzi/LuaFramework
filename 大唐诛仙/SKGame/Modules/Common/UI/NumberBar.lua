-- fuiobj -> NumberBar.Create(fui)
-- obj -> NumberBar.New()
-- 简单数字控件 +-max

-- 使用前，先初始化对象后再 SetMax( max ) 设置最大值 SetStep( step )与增减值 SetTypeCallback(cb) 回调点击结果值
-- 实现长按与单点
NumberBar = BaseClass(LuaUI)
function NumberBar:__init(...)
	self.URL = "ui://0tyncec1x0conk2"
	self:__property(...)
	self:Config()
end
function NumberBar:SetProperty(...)
end

-- 设置最大值
function NumberBar:SetMax( max )
	self.max = max or 99
end
-- 设置 +- 每次增加或减少值
function NumberBar:SetStep( step )
	self.step = math.min(step or 1, 1)
end
-- 设置回调输入结果
function NumberBar:SetTypeCallback( callback )
	self.callback = callback
end
-- 设置初始值
function NumberBar:SetValue( v )
	self.tmpInput = v or 0
	self:Update()
end

function NumberBar:Config()
	self.step = 1
	self.max = 99
	self.tmpInput = 0
	self:InitEvent()
end

function NumberBar:InitEvent()
	local function Add()
		self.tmpInput = math.min(self.tmpInput + self.step, self.max)
		self:Update()
	end
	local function Sub()
		self.tmpInput = math.max(self.tmpInput - self.step, 0)
		self:Update()
	end
	local function Max()
		self.tmpInput = self.max
		self:Update()
	end
	longPress( self.btnSub, Sub, 0.3, nil)
	--++
	self.btnSub.onTouchBegin:Add(function ()
		Sub()
	end)
	--++
	longPress( self.btnAdd, Add, 0.3, nil)
	--++
	self.btnAdd.onTouchBegin:Add(function ()
		Add()
	end)
	--++

	self.btnMax.onClick:Add(Max)
	self.title.onChanged:Add(function ()
		local t = tonumber(self.title.text) or self.tmpInput
		if t < 0 then t=0 end
		if t > self.max then t=self.max end
		self.tmpInput = t
		self.title.text = t
		if self.callback then self.callback(self.tmpInput) end
	end)
end
function NumberBar:Update()
	if self.title.text == tostring(self.tmpInput) then return end
	self.title.text = self.tmpInput
	if self.callback then
		self.callback(self.tmpInput)
	end
end

function NumberBar:Lock()
	self.btnSub.grayed = true
	self.btnSub.enabled = false

	self.btnAdd.grayed = true
	self.btnAdd.enabled = false

	self.btnMax.grayed = true
	self.btnMax.enabled = false
end

function NumberBar:UnLock()
	self.btnSub.grayed = false
	self.btnSub.enabled = true

	self.btnAdd.grayed = false
	self.btnAdd.enabled = true

	self.btnMax.grayed = false
	self.btnMax.enabled = true
end

function NumberBar:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Common","NumberBar")

	self.btnSub = self.ui:GetChild("btnSub")
	self.btnAdd = self.ui:GetChild("btnAdd")
	self.btnMax = self.ui:GetChild("btnMax")
	self.title = self.ui:GetChild("title")
end
function NumberBar.Create(ui, ...)
	return NumberBar.New(ui, "#", {...})
end
function NumberBar:__delete()
end