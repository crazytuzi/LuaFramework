PkModel =BaseClass(LuaUI)

PkModel.Type =
{
	Peace = 1,		--和平
	GoodEvil = 2,	--善恶
	Clan = 3,	    --帮派	
	Family = 4,		--家族
	All = 5,		--全体
}

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function PkModel:__init( ... )
	self.URL = "ui://0042gnitnv56d6";
	self:__property(...)
	self:Config()
end

-- Set self property
function PkModel:SetProperty( ... )
	
end

-- Logic Starting
function PkModel:Config()
	
end

-- Register UI classes to lua
function PkModel:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","PkModel");

	self.n0 = self.ui:GetChild("n0")
	self.modelTxt = self.ui:GetChild("modelTxt")
	self.smallBtn = self.ui:GetChild("smallBtn")

	self:InitEvent()
end

function PkModel:InitEvent()
	self.handler = GlobalDispatcher:AddEventListener(EventName.PkModelChange, function ( data )
		self:OnModelChangeHandler(data)
	end)
end

function PkModel:RemoveEvent()
	GlobalDispatcher:RemoveEventListener(self.handler)
end

function PkModel:OnModelChangeHandler(data)
	local modelType = data[1]
 	self:ShowByType(modelType)
end

function PkModel:ShowByType(modelType)
	local data = GetCfgData("pkmodel"):Get(modelType)
 	if data then
	 	self.modelTxt.color = newColorByString("#"..data.color)
	 	self.modelTxt.text = data.name
 	end
end

-- Combining existing UI generates a class
function PkModel.Create( ui, ...)
	return PkModel.New(ui, "#", {...})
end

-- Dispose use PkModel obj:Destroy()
function PkModel:__delete()
	self:RemoveEvent()
	
	self.n0 = nil
	self.modelTxt = nil
	self.smallBtn = nil
end