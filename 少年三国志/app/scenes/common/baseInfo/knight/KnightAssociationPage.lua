--KnightInfoPage.lua

local KnightPageBase = require("app.scenes.common.baseInfo.knight.KnightPageBase")
require("app.cfg.association_info")
require("app.cfg.knight_info")
require("app.cfg.equipment_info")
require("app.cfg.treasure_info")

local KnightAssociationPage = class("KnightAssociationPage", KnightPageBase)

function KnightAssociationPage.create(...)
	return KnightPageBase._create_(KnightAssociationPage.new(...), "ui_layout/BaseInfo_KnightAssociation.json", ...)
end

function KnightAssociationPage.delayCreate(...)
	local page = KnightPageBase._create_(KnightAssociationPage.new(...), nil, ...)
	page:delayLoad("ui_layout/BaseInfo_KnightAssociation.json")
	return page
end

function KnightAssociationPage:ctor( baseId, fragmentId, scenePack, ... )
	self.super.ctor(self, baseId, fragmentId, scenePack, ...)
	self._listview = nil
	self._wayIdList = {}

	self._scenePack = scenePack
end

function KnightAssociationPage:afterLayerLoad( ... )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_6", Colors.strokeBrown, 2 )

	local knightInfo = knight_info.get(self._baseId)
	if not knightInfo then 
		return
	end

	local icon = self:getImageViewByName("Image_icon")
	if icon ~= nil then
		local heroPath = G_Path.getKnightIcon(knightInfo.res_id)
    	icon:loadTexture(heroPath, UI_TEX_TYPE_LOCAL)    	  
	end

	local pingji = self:getImageViewByName("Image_pingji")
	if pingji then
    	pingji:loadTexture(G_Path.getAddtionKnightColorImage(knightInfo.quality))  
    end

	local name = self:getLabelByName("Label_name")
	if name ~= nil then
		name:setColor(Colors.qualityColors[knightInfo.quality])
		name:setText(knightInfo.name or "Default Name")		
	end

	local label = self:getLabelByName("Label_hurt_type")
	if label then 
		label:setText(G_lang.getKnightTypeStr(knightInfo.character_tips or 1))
	end

	local curAssociationIndex = 1
	local addJipanContent = function ( associationId, isActive )
		local associationInfo = association_info.get(associationId)
		if associationInfo == nil then
			return 
		end
		
		local label = self:getLabelByName("Label_ass_"..curAssociationIndex)
		if label then 
			label:setColor(isActive and Colors.activeSkill or Colors.inActiveSkill)
			label:setText(associationInfo.name)
		end
		curAssociationIndex = curAssociationIndex + 1
	end

	addJipanContent(knightInfo.association_1)
	addJipanContent(knightInfo.association_2)
	addJipanContent(knightInfo.association_3)
	addJipanContent(knightInfo.association_4)
	addJipanContent(knightInfo.association_5)
	addJipanContent(knightInfo.association_6)
	addJipanContent(knightInfo.association_7)
	addJipanContent(knightInfo.association_8)
	for loopi = curAssociationIndex, 8 do 
		self:showWidgetByName("Image_ass_"..loopi, false)
	end 

	self:_initAcquireWays(knightInfo)
end

function KnightAssociationPage:_generateAssociationList( knightInfo )
	local calcAssociation = function ( associtionId )
		local associtionInfo = association_info.get(associtionId) 
		if not associtionInfo then 
			return 
		end

		if associtionInfo.info_value_1 > 0 then 
			table.insert(self._wayIdList, #self._wayIdList + 1, 
				{id = associtionId, typeId = associtionInfo.info_type, value = associtionInfo.info_value_1})
		end
		if associtionInfo.info_value_2 > 0 then 
			table.insert(self._wayIdList, #self._wayIdList + 1, 
				{id = associtionId, typeId = associtionInfo.info_type, value = associtionInfo.info_value_2})
		end
		if associtionInfo.info_value_3 > 0 then 
			table.insert(self._wayIdList, #self._wayIdList + 1, 
				{id = associtionId, typeId = associtionInfo.info_type, value = associtionInfo.info_value_3})
		end
		if associtionInfo.info_value_4 > 0 then 
			table.insert(self._wayIdList, #self._wayIdList + 1, 
				{id = associtionId, typeId = associtionInfo.info_type, value = associtionInfo.info_value_4})
		end
		if associtionInfo.info_value_5 > 0 then 
			table.insert(self._wayIdList, #self._wayIdList + 1, 
				{id = associtionId, typeId = associtionInfo.info_type, value = associtionInfo.info_value_5})
		end
	end

	if not knightInfo then 
		return 
	end

	self._wayIdList = {}
	calcAssociation(knightInfo.association_1)
	calcAssociation(knightInfo.association_2)
	calcAssociation(knightInfo.association_3)
	calcAssociation(knightInfo.association_4)
	calcAssociation(knightInfo.association_5)
	calcAssociation(knightInfo.association_6)
	calcAssociation(knightInfo.association_7)
	calcAssociation(knightInfo.association_8)

	local sortAssociation = function ( asso1, asso2 )
		if not asso1 then 
			return false
		end
		if not asso2 then 
			return true 
		end

		if asso1.typeId ~= asso2.typeId then 
			return asso1.typeId < asso2.typeId 
		end

		local itemInfo1 = nil
		local itemInfo2 = nil
		if asso1.typeId == 1 then 
			itemInfo1 = knight_info.get(asso1.value)
			itemInfo2 = knight_info.get(asso2.value)
		elseif asso1.typeId == 2 then 
			itemInfo1 = equipment_info.get(asso1.value)
			itemInfo2 = equipment_info.get(asso2.value)
		elseif asso1.typeId == 3 then 
			itemInfo1 = treasure_info.get(asso1.value)
			itemInfo2 = treasure_info.get(asso2.value)
		end

		if not itemInfo1 then 
			return false
		end
		if not itemInfo2 then 
			return true 
		end

		return itemInfo1.quality > itemInfo2.quality
	end

	table.sort(self._wayIdList, sortAssociation)
end

function KnightAssociationPage:_initAcquireWays( knightInfo )
	local panel = self:getPanelByName("Panel_list")
	if not panel or not knightInfo then
		return 
	end

	self:_generateAssociationList(knightInfo)

	self._listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    self._listview:setCreateCellHandler(function ( list, index)
        return require("app.scenes.common.baseInfo.knight.KnightAssociationItem").new(list, index)
    end)
    self._listview:setUpdateCellHandler(function ( list, index, cell)
    	cell._scenePack = self._scenePack
        cell:updateItem( self._wayIdList[index + 1] )
    end)
    self._listview:setSelectCellHandler(function ( list, knightId, param, cell )
    	
    end)

    self._listview:reloadWithLength(#self._wayIdList)
end

return KnightAssociationPage
