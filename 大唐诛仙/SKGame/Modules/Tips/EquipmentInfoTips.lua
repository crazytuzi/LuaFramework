EquipmentInfoTips =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function EquipmentInfoTips:__init( ... )
	self.URL = "ui://ixdopynlhb6f8";
	self:__property(...)
	self:Config()
end

-- Set self property
function EquipmentInfoTips:SetProperty( ... )
	
end

-- Logic Starting
function EquipmentInfoTips:Config()
	self.basePropLabelPrefab = UIPackage.GetItemURL("Tips", "EquipmentInfoTips_BaseItem")
	self.extraPropLabelPrefab = UIPackage.GetItemURL("Tips", "EquipmentInfoTips_ExtraItem")
	self.wakanPropLabelPrefab = UIPackage.GetItemURL("Tips", "EquipmentInfoTips_WakanItem")
	-- self.brandPropLabelPrefab = UIPackage.GetItemURL("Tips", "EquipmentInfoTips_BrandItem")
end

--初始化tips
function EquipmentInfoTips:Init(itemVo, isHide, compareItemVo)
	if itemVo == nil then return end
	self.itemVo = itemVo

	self.compareItemVo = compareItemVo
	self.compareDic = nil
	if self.compareItemVo then
		self.compareDic = {}
		local compareCfg = GoodsVo.GetEquipCfg(self.compareItemVo.bid)
		if compareCfg and #compareCfg.baseProperty > 0 then
			for i = 1, #compareCfg.baseProperty do
				local id = compareCfg.baseProperty[i][1]
				local value = compareCfg.baseProperty[i][2]
				self.compareDic[id] = value		
			end
		end
	end

	self.base.visible = false
	self.extra.visible = false
	self.wakan.visible = false
	self.brand.visible = false

	self:SetTopInfo()
	self:SetBaseProp()
	self:SetExtraProp()
	self:SetBrandInfo()
	if not isHide then
		self:SetWakanProp()
	end
	self:Layout()
end

--设置头部信息
function EquipmentInfoTips:SetTopInfo()
	self.tipsTopComp:Init(self.itemVo)
	self.equipMask.visible = false
	if self.itemVo.state == 2 then --已装备
		self.equipMask.visible = true
	end
end

--设置基础属性
function EquipmentInfoTips:SetBaseProp()
	self.baseList:RemoveChildrenToPool()
	local cfg = GoodsVo.GetEquipCfg(self.itemVo.bid)
	local precentId = {21, 22, 23}
	local function mgrValue( id, value )
		for i,v in ipairs(precentId) do
			if v == id then
				return string.format("%.1f", value*0.01).."%"
			end
		end
		return value
	end
	if cfg and #cfg.baseProperty > 0 then
		self.base.visible = true
		for i = 1, #cfg.baseProperty do
			local id = cfg.baseProperty[i][1]
			local value = cfg.baseProperty[i][2]
			local name = RoleVo.GetPropDefine(id).name
			local item = self.baseList:AddItemFromPool(self.basePropLabelPrefab)
			item:GetChild("TitleName").text = StringFormat("{0} ", name)
			if self.compareItemVo and self.compareItemVo.cfg.needJob == self.itemVo.cfg.needJob and self.compareDic and self.compareDic[id] then
				if self.compareDic[id] > value then 
					item:GetChild("CompareMask").url = PlayerInfoConst.UpORDown[2] --下降 
					item:GetChild("TitleValue").text = StringFormat("{0}    [color=#FF0000](-{1})[/color]", mgrValue( id, value ), self.compareDic[id] - value)
				elseif self.compareDic[id] < value then
					item:GetChild("CompareMask").url = PlayerInfoConst.UpORDown[1] --上升 
					item:GetChild("TitleValue").text = StringFormat("{0}    [color=#3DC476](+{1})[/color]", mgrValue( id, value ), value - self.compareDic[id])
				else
					item:GetChild("TitleValue").text = StringFormat("{0}", mgrValue( id, value ))
				end
			else
				item:GetChild("TitleValue").text = StringFormat("{0}", mgrValue( id, value ))
			end

		end
		self.baseList:ResizeToFit(self.baseList.numItems)
	end
end

--设置额外属性
function EquipmentInfoTips:SetExtraProp()
	self.extraList:RemoveChildrenToPool()
	local precentId = {21, 22, 23}
	local function mgrValue( id, value )
		for i,v in ipairs(precentId) do
			if v == id then
				return string.format("%.1f", value*0.01).."%"
			end
		end
		return value
	end
	if #self.itemVo.attrs > 0 then
		self.extra.visible = true
		for i = 1, #self.itemVo.attrs do
			local id = self.itemVo.attrs[i][1]
			local value = self.itemVo.attrs[i][2]
			local name = RoleVo.GetPropDefine(id).name
			local item = self.extraList:AddItemFromPool(self.extraPropLabelPrefab)
			item:GetChild("desc").text = "[color=#54a3d5]"..name.." +"..mgrValue( id, value ).."[/color]"
		end
		self.extraList:ResizeToFit(self.extraList.numItems)
	end
end

--设置注灵属性
function EquipmentInfoTips:SetWakanProp()
	self.wakanList:RemoveChildrenToPool()
	local wakanModel = WakanModel:GetInstance()
	local part = self.itemVo.equipType
	local level = wakanModel:GetPartWakanInfo(part)[2]
	if level > 0 then
		self.wakan.visible = true
		local curAttrInfo = WakanModel:GetInstance():GetAttrsAddByLevel_Part(level, part)
		if curAttrInfo then
			self.wakan:GetChild("name").text = StringFormat("注灵:【{0}级】", level)
			for i = 1, #curAttrInfo do
				local item = self.wakanList:AddItemFromPool(self.wakanPropLabelPrefab)
				item:GetChild("TitleValue").text = "[color=#00ff00] "..curAttrInfo[i][1].." +"..curAttrInfo[i][2].."[/color]"
			end
			self.wakanList:ResizeToFit(self.wakanList.numItems)
		end
	end
end

--设置铭文信息
function EquipmentInfoTips:SetBrandInfo()
	local godFightRuneModel = GodFightRuneModel:GetInstance()
	local skillModel = SkillModel:GetInstance()
	local inscriptionData = godFightRuneModel.inscriptionData
	local isPutOn = godFightRuneModel:IsPutOn()
	--主武器才具有铭文信息
	if isPutOn and self.itemVo.equipType == GoodsVo.EquipPos.Weapon01 and #inscriptionData > 0 then
		self.brand.visible = true
		self.brandListContentHeight = 0
		self.brandItemList = {}
		for i = 1, #inscriptionData do
			if inscriptionData[i].inscriptionId ~= 0 then
				local item = UIPackage.CreateObject("Tips","EquipmentInfoTips_BrandItem")
				local icon = item:GetChild("icon")
				local title = item:GetChild("title")
				local desc = item:GetChild("desc")
				item.y = self.brandListContentHeight
				self.brand:AddChild(item)
				table.insert(self.brandItemList, item)

				local inscriptionVo = GetCfgData("inscription"):Get(inscriptionData[i].inscriptionId)
				if inscriptionVo then
					title.text = "【"..inscriptionVo.name.."】"
					icon.url = StringFormat("Icon/Goods/{0}", inscriptionVo.icon or "")
				end
				if inscriptionData[i].effectType == GodFightRuneConst.EffectType.SwapSkill then --影响技能
					 local baseSkillId = inscriptionData[i].effectId
					 local skillIndex = inscriptionData[i].attrValue
					 local newSkillId = skillModel:GetSkillIdByBaseIdAndSkillIndex(baseSkillId, skillIndex)
					 local skillVo = SkillManager.GetStaticSkillVo(newSkillId) 
					 desc.text = skillVo.name.."：" ..skillVo.des

				elseif inscriptionData[i].effectType == GodFightRuneConst.EffectType.AddBuff then --影响属性
					local name = RoleVo.GetPropDefine(inscriptionData[i].effectId).name
					local value = inscriptionData[i].attrValue
					desc.text = StringFormat("[color=#00ff00]{0} +{1}[/color]",name,value)
				end
				self.brandListContentHeight = self.brandListContentHeight  + desc.y + desc.textHeight + 6
			end
		end
	else
		self:SetEmptyBrand()
	end
end

function EquipmentInfoTips:SetEmptyBrand()
	if self.itemVo and self.itemVo.holeNum and self.itemVo.holeNum ~= 0 then
		local hole = ""
		for i = 1, self.itemVo.holeNum do
			hole = hole..StringFormat("[img=30,30]{0}[/img]  ", UIPackage.GetItemURL("Common" , "radio"))
		end
		content = StringFormat("斗神印记：{0}", hole)
		local item = UIPackage.CreateObject("Tips", "EquipmentInfoTips_BrandEmptyItem")
		local desc = item:GetChild("desc")
		setRichTextContent(desc, content)

		self.brand.visible = true
		self.brandListContentHeight = 0
		self.brandItemList = {}
		self.brand:AddChild(item)
		table.insert(self.brandItemList, item)

		self.brandListContentHeight = self.brandListContentHeight  + desc.y + desc.textHeight + 6
	end
end

function EquipmentInfoTips:Layout()
	local totalHeight = 0
	self.base.y = self.base.y + 10
	local locateY = self.base.y + self.baseList.height
	if self.extra.visible then
		self.extra.y = locateY
		locateY = self.extra.y + self.extraList.y + self.extraList.height
	end
	if self.wakan.visible then
		self.wakan.y = locateY
		locateY = self.wakan.y + self.wakanList.y + self.wakanList.height
	end
	if self.brand.visible then
		self.brand.y = locateY
		locateY = self.brand.y + self.brandListContentHeight
	end
	self.bg.height = locateY + 30
end

-- Register UI classes to lua
function EquipmentInfoTips:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Tips","EquipmentInfoTips");

	self.bg = self.ui:GetChild("bg")
	self.tipsTopComp = self.ui:GetChild("TipsTopComp")
	self.equipMask = self.ui:GetChild("IsEquipMask")
	self.base = self.ui:GetChild("base")
	self.extra = self.ui:GetChild("extra")
	self.wakan = self.ui:GetChild("wakan")
	self.brand = self.ui:GetChild("brand")

	self.tipsTopComp = EquipmentInfoTipsTop.Create(self.tipsTopComp)
	self.baseList = self.base:GetChild("list")
	self.extraList = self.extra:GetChild("list")
	self.wakanList = self.wakan:GetChild("list")

	self.brandListContentHeight = 0
	self.brandItemList = nil
end

-- Combining existing UI generates a class
function EquipmentInfoTips.Create( ui, ...)
	return EquipmentInfoTips.New(ui, "#", {...})
end

-- Dispose use EquipmentInfoTips obj:Destroy()
function EquipmentInfoTips:__delete()
	if self.tipsTopComp then
		self.tipsTopComp:Destroy()
	end

	if self.brandItemList then
		for i = 1, #self.brandItemList do
			destroyUI(self.brandItemList[i])
		end
		self.brandItemList = nil
	end

	self.itemVo = nil
	self.baseList = nil
	self.extraList = nil
	self.wakanList = nil
	self.brandList = nil

	self.basePropLabelPrefab = nil
	self.extraPropLabelPrefab = nil
	self.wakanPropLabelPrefab = nil
	-- self.brandPropLabelPrefab = nil

	self.bg = nil
	self.tipsTopComp = nil
	self.equipMask = nil
	self.base = nil
	self.extra = nil
	self.wakan = nil
	self.brand = nil
end