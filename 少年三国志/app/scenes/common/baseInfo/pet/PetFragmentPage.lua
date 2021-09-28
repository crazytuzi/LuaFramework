--PetFragementPage.lua

local KnightPageBase = require("app.scenes.common.baseInfo.knight.KnightPageBase")
require("app.cfg.fragment_info")
require("app.setting.Goods")
require("app.cfg.way_type_info")

local PetFragementPage = class("PetFragementPage", KnightPageBase)

function PetFragementPage.create(...)
	return KnightPageBase._create_(PetFragementPage.new(...), "ui_layout/BaseInfo_PetFragment.json", ...)
end

function PetFragementPage.delayCreate(...)
	local page = KnightPageBase._create_(PetFragementPage.new(...), nil, ...)
	page:delayLoad("ui_layout/BaseInfo_PetFragment.json")

	return page
end

function PetFragementPage:ctor( baseId, fragmentId, scenePack,... )
	self.super.ctor(self, baseId, fragmentId, scenePack,...)

	self._wayIdList = {}
	self._listview = nil
	self._scenePack = scenePack
end

function PetFragementPage:afterLayerLoad( ... )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_6", Colors.strokeBrown, 2 )

	local fragmentInfo = fragment_info.get(self._fragmentId)
	assert(fragmentInfo)
	if not fragmentInfo then 
		return
	end

	local icon = self:getImageViewByName("Image_icon")
	if icon ~= nil then
		local heroPath = G_Path.getPetIcon(fragmentInfo.res_id)
    	icon:loadTexture(heroPath, UI_TEX_TYPE_LOCAL)    	  
	end

	local pingji = self:getImageViewByName("Image_pingji")
	if pingji then
    	pingji:loadTexture(G_Path.getEquipColorImage(fragmentInfo.quality, G_Goods.TYPE_FRAGMENT))  
    end

	local name = self:getLabelByName("Label_name")
	if name ~= nil then
		name:setColor(Colors.qualityColors[fragmentInfo.quality])
		name:setText(fragmentInfo.name or "Default Name")		
	end

	icon = self:getImageViewByName("Image_frag_back")
	if icon then
		icon:loadTexture(G_Path.getEquipIconBack(fragmentInfo.quality))
	end

	--[[
	local equipInfo = equipment_info.get(self._baseId)
	local label = self:getLabelByName("Label_hurt_type")
	if label then 
		if equipInfo then 
			label:setText(G_lang.getEquipNameByType(equipInfo.type))
		end
	end
	]]

	local fragment = G_Me.bagData.fragmentList:getItemByKey(fragmentInfo.id)
	if fragment then 
		self:showTextWithLabel("Label_count_title_value", fragment.num.."/"..fragmentInfo.max_num)
	else
		self:showTextWithLabel("Label_count_title_value", "0/"..fragmentInfo.max_num)
	end

	local label = self:getLabelByName("Label_desc")
	if label then 
		label:setText(fragmentInfo.directions)
	end

	self:_initAcquireWays(fragmentInfo)
end

function PetFragementPage:_initAcquireWays( fragmentInfo )
	local panel = self:getPanelByName("Panel_list")
	if not panel or not fragmentInfo then
		return 
	end

	local addWayId = function ( wayId )
        if wayId and wayId > 0 then 
            table.insert(self._wayIdList, #self._wayIdList + 1, wayId)
        end
    end

    local wayTypeInfo = way_type_info.get(G_Goods.TYPE_FRAGMENT, fragmentInfo.id)
    if wayTypeInfo then
        addWayId(wayTypeInfo.way_id1)
        addWayId(wayTypeInfo.way_id2)
        addWayId(wayTypeInfo.way_id3)
        addWayId(wayTypeInfo.way_id4)
        addWayId(wayTypeInfo.way_id5)
        addWayId(wayTypeInfo.way_id6)
        addWayId(wayTypeInfo.way_id7)
        addWayId(wayTypeInfo.way_id8)
        addWayId(wayTypeInfo.way_id9)
        addWayId(wayTypeInfo.way_id10)
        addWayId(wayTypeInfo.way_id11)
        addWayId(wayTypeInfo.way_id12)
        addWayId(wayTypeInfo.way_id13)
        addWayId(wayTypeInfo.way_id14)
        addWayId(wayTypeInfo.way_id15)
    end

    local scenePack = self._scenePack or GlobalFunc.generateScenePack()


	local flagGetChapterList = false
	self._listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    
    self._listview:setCreateCellHandler(function ( list, index)
        return require("app.scenes.common.baseInfo.equip.EquipFragmentItem").new(list, index, "ui_layout/BaseInfo_KnightFragementItem.json")
    end)
    self._listview:setUpdateCellHandler(function ( list, index, cell)
        cell._scenePack = scenePack
        flagGetChapterList = cell:initWithWayId( self._wayIdList[index + 1] ) or flagGetChapterList
    end)
    self._listview:setSelectCellHandler(function ( list, knightId, param, cell )
    	
    end)

    self._listview:reloadWithLength(#self._wayIdList, 0, 0.2)

    if #self._wayIdList < 1 then 
    	self:showWidgetByName("Label_empty_tip", true)
    	self:showTextWithLabel("Label_empty_tip", G_lang:get("LANG_WAY_FUNCTION_NOT_OPEN"))
    end

    if flagGetChapterList then 
        G_HandlersManager.dungeonHandler:sendGetChapterListMsg()
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DUNGEON_RECVCHAPTERLIST, function ( ... )
            self._listview:refreshAllCell()
        end, self)
    end
end

return PetFragementPage
