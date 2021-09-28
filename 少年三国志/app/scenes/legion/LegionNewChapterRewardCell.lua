-- 成就奖励列表cell

local LegionNewChapterRewardCell = class("LegionNewChapterRewardCell", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_DungeonNewAwardListItem.json")
end)

function LegionNewChapterRewardCell:ctor()
	self._listPanel = self:getPanelByName("Panel_award")
end

function LegionNewChapterRewardCell:updateCell( chapterInfo )

	self:getLabelByName("Label_chapter"):setText(G_lang:get("LANG_NEW_LEGION_CHAPTER_AWARD_TITLE", {chapterIndex = chapterInfo.id,chapterName=chapterInfo.name}))
	self:getLabelByName("Label_chapter"):createStroke(Colors.strokeBrown, 1)
	
	self:updateList(chapterInfo)
	local info = G_Me.legionData:getNewChapterInfo(chapterInfo.id)
	-- local notWin = info and info.hp>0
	if not chapterInfo.gotAward and chapterInfo.id <= G_Me.legionData:getMaxFinishDungeon() then
		self:showWidgetByName("Image_Not_Achieve", false)
		self:showWidgetByName("Image_Already_Get", false)
		self:showWidgetByName("Button_Get", true)
	elseif chapterInfo.gotAward == true then
		self:showWidgetByName("Image_Not_Achieve", false)
		self:showWidgetByName("Image_Already_Get", true)
		self:showWidgetByName("Button_Get", false)
	else
		self:showWidgetByName("Image_Not_Achieve", true)
		self:showWidgetByName("Image_Already_Get", false)
		self:showWidgetByName("Button_Get", false)
	end

	self:registerBtnClickEvent("Button_Get",function (  widget, param )
		G_HandlersManager.legionHandler:sendGetNewChapterAward(chapterInfo.id)
	end)
end

function LegionNewChapterRewardCell:updateList(info)
    local award = {}
    for i = 1 , 3 do 
        table.insert(award,#award+1,{type=info["award_type"..i],value=info["award_value"..i],size=info["award_size"..i]})
    end
    if not self._iconList then
        self._iconList = GlobalFunc.createIconInPanel({panel=self._listPanel,award=award,click=true,left=true,offset=5})
    else
        GlobalFunc.refreshIcon({iconList=self._iconList,award=award})
    end
end

return LegionNewChapterRewardCell