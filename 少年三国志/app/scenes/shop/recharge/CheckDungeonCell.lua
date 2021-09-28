require("app.cfg.item_info")

require("app.cfg.dungeon_info")
require("app.cfg.dungeon_info_config")
require("app.cfg.dungeon_info_holiday")
require("app.cfg.dungeon_chapter_info")
local KnightPic = require("app.scenes.common.KnightPic")
local CheckDungeonCell = class("CheckDungeonCell",function()
    return CCSItemCellBase:create("ui_layout/shop_ShopGiftbagItem_0.json")
end)

function CheckDungeonCell:ctor()
    self._knightNode = nil
    self:getPanelByName("Panel_knight"):setScale(0.5)
end


function CheckDungeonCell:updateCell(item,_type)
    local dungeonInfo = nil
    if _type == 1  then
        dungeonInfo = dungeon_info.get(item.value)
    elseif _type == 2 then
        dungeonInfo = dungeon_info_holiday.get(item.value)
    else
        dungeonInfo = dungeon_info_config.get(item.value)
    end
    for i=1,6 do
        self:showWidgetByName("ImageView_item_bg0"..i,false)
        local key_type = "item" .. i .. "_type"
        local key_value = "item" .. i .. "_value"
        local key_size = "item" .. i .. "_size"
        if dungeonInfo[key_type] > 0 then
            self:showWidgetByName("ImageView_item_bg0"..i,true)
            local good = G_Goods.convert(dungeonInfo[key_type],dungeonInfo[key_value],dungeonInfo[key_size])
            self:getImageViewByName("ImageView_item0"..i):loadTexture(good.icon)
            self:getButtonByName("Button_item0"..i):loadTextureNormal(G_Path.getEquipColorImage(good.quality,good.type,good.value))
            self:getButtonByName("Button_item0"..i):loadTexturePressed(G_Path.getEquipColorImage(good.quality,good.type,good.value))
            self:showTextWithLabel("Label_num0"..i,"x" .. good.size)
            self:getLabelByName("Label_num0"..i):createStroke(Colors.strokeBrown,1)
        end
    end    
    local chapterInfo = dungeon_chapter_info.get(item.chapter_id)
    self:showTextWithLabel("Label_guanka",G_lang:get("LANG_HARD_RIOT_CHAPTER_NUM",{num=item.chapter_id}) .. ":" .. chapterInfo.name)
    self:showTextWithLabel("Label_name",item.name)
    if dungeonInfo.difficulty == 2 then
        self:getLabelByName("Label_name"):setColor(Colors.qualityColors[4])
    elseif dungeonInfo.difficulty == 3 then
        self:getLabelByName("Label_name"):setColor(Colors.qualityColors[5])
    else
        self:getLabelByName("Label_name"):setColor(Colors.qualityColors[1])
    end
    self:getLabelByName("Label_name"):createStroke(Colors.strokeBrown,1)

    self:showTextWithLabel("Label_desc",dungeonInfo.talk)

    if self._knightNode ~= nil then
        self._knightNode:removeFromParentAndCleanup(true)
        self._knightNode = nil
    end
    self._knightNode = KnightPic.createKnightPic( item.image, self:getPanelByName("Panel_knight"), "hero",true)
end

return CheckDungeonCell





