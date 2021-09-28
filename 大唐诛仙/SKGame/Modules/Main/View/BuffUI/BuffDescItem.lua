BuffDescItem = BaseClass(LuaUI)

function BuffDescItem:__init( ... )
	self.URL = "ui://0042gnitio2p7a";
	self:__property(...)
	self:Config()
end

-- Set self property
function BuffDescItem:SetProperty( ... )
end

-- start
function BuffDescItem:Config()
	
end

-- wrap UI to lua
function BuffDescItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","BuffDescItem");

	self.icon = self.ui:GetChild("icon")
	self.title = self.ui:GetChild("title")
	self.desc = self.ui:GetChild("desc")
	self.time = self.ui:GetChild("time")
	self.line = self.ui:GetChild("line")
end

function BuffDescItem:SetData(buffVo)
	self.buffVo = buffVo
end

function BuffDescItem:HideLine()
	self.line.visible = false
end

function BuffDescItem:InitView(vo , cfgData)
	self.vo = vo
	self.cfgData = cfgData
	self.lifeTime = (self.vo.endTime - TimeTool.GetCurTime()) / 1000

	self.title.text = self.cfgData.name
	self.desc.text = self.cfgData.desc
	self.icon.url = "Icon/Buff/"..self.cfgData.bufficonID
	if self.vo.endTime == -1 then
		self.time.text = "(永久)"
	else
		self.time.text = "("..Mathf.Ceil(self.lifeTime).."s)"
	end
end

function BuffDescItem:Update()
	if self.cfgData and self.lifeTime > 0 then
		self.lifeTime = self.lifeTime - Time.deltaTime
		self.lifeTime = self.lifeTime <= 0 and 0 or self.lifeTime
		self.time.text = "("..Mathf.Ceil(self.lifeTime).."s)"
	end
end

function BuffDescItem:GetHeight()
	return self.desc.y + self.desc.textHeight + 2
end

-- Combining existing UI generates a class
function BuffDescItem.Create( ui, ...)
	return BuffDescItem.New(ui, "#", {...})
end

function BuffDescItem:__delete()

end

BuffDescItem.Pool = {}
BuffDescItem.Max = 25
function BuffDescItem.CreateFromPool()
	for i = 1, #BuffDescItem.Pool do
		if BuffDescItem.Pool[i].ui and BuffDescItem.Pool[i].ui.parent == nil then
			return BuffDescItem.Pool[i]
		end
	end
	if #BuffDescItem.Pool < BuffDescItem.Max then
		local item = BuffDescItem.New()
		table.insert(BuffDescItem.Pool, item)
		return item
	else
		return BuffDescItem.Pool[1]
	end
end

function BuffDescItem.DestoryPool()
	if BuffDescItem.Pool then
		for i = 1, #BuffDescItem.Pool do
			BuffDescItem.Pool[i]:Destroy()
		end
	end
	BuffDescItem.Pool = nil
	BuffDescItem.Max = nil
end