CompositionItemInfo = BaseClass(LuaUI)
function CompositionItemInfo:__init( ... )
	self.URL = "ui://qr7fvjxisdush";
	self:__property(...)
	self:Config()
end

-- Set self property
function CompositionItemInfo:SetProperty( ... )
end

-- start
function CompositionItemInfo:Config()
	self:InitData()
	self:InitEvent()
end

-- wrap UI to lua
function CompositionItemInfo:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Composition","CompositionItemInfo");

	self.bg0 = self.ui:GetChild("bg0")
	self.bg1 = self.ui:GetChild("bg1")
	self.labelName = self.ui:GetChild("labelName")
	self.richLabelEffect0 = self.ui:GetChild("richLabelEffect0")
	self.richLabelEffect1 = self.ui:GetChild("richLabelEffect1")
end

-- Combining existing UI generates a class
function CompositionItemInfo.Create( ui, ...)
	return CompositionItemInfo.New(ui, "#", {...})
end

function CompositionItemInfo:InitData()
	self.model = CompositionModel:GetInstance()
end

function CompositionItemInfo:InitEvent()
	local function HanleSelectItem(pkgCellData)
		self:SetUI(pkgCellData)
	end
	self.handler0 = self.model:AddEventListener(CompositionConst.SelectItem , HanleSelectItem)
end

function CompositionItemInfo:CleanData()
	if self.model then
		self.model = nil
	end
end

function CompositionItemInfo:CleanEvent()
	if self.model then
		self.model:RemoveEventListener(self.handler0)
	end
end

function CompositionItemInfo:SetUI(pkgCellData)
	if not TableIsEmpty(pkgCellData) then
		local itemName , itemDesc = self:GetItemInfo(pkgCellData.bid)
		local playerLv = SceneModel:GetInstance():GetMainPlayer().level
		local str = ""
		if playerLv and pkgCellData.cfg.level and playerLv < pkgCellData.cfg.level then
			str = StringFormat("[color=#ff3300]({0}级后可用)[/color]", pkgCellData.cfg.level)

		end
		self.labelName.text = itemName..str
		self.richLabelEffect0.text = itemDesc
	end
end

function CompositionItemInfo:GetItemInfo(bid)
	local rtnItemDesc = ""
	local rtnItemName = ""
	if bid then
		local starImgURL = UIPackage.GetItemURL("Common" , "zhuangshi1")
		if starImgURL then rtnItemDesc = StringFormat("<img src='{0}'/>", starImgURL) end
		local itemCfg = GetCfgData("item"):Get(bid)
		if itemCfg then
			rtnItemDesc = StringFormat("{0}{1}" , rtnItemDesc , itemCfg.des)
			rtnItemName = itemCfg.name
		end
	end
	return rtnItemName , rtnItemDesc
end

function CompositionItemInfo:__delete()
	self:CleanEvent()
	self:CleanData()
end