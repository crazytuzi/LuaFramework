local VipMapCell = class ("VipMapCell", function (  )
    return CCSItemCellBase:create("ui_layout/vip_fightCell.json")
end)

require("app.cfg.dungeon_vip_info")

function VipMapCell:ctor()
    -- self.super.ctor(self)
    self._map = 0
    self._levelLabel = self:getLabelByName("Label_Level")
    self._levelLabel:createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_open"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_Day_Tag_1"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_Day_Tag_2"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_Day_Tag_3"):createStroke(Colors.strokeBrown, 1)
    self._bg = self:getImageViewByName("Image_bg")
    self._bg0 = self:getImageViewByName("Image_bg_0")

    self:registerWidgetClickEvent("Panel_all", function()
        self._callBack(self._mapId)
    end)
    
end

function VipMapCell:updateView(mapId, func)
    self._callBack = func
    self._mapId = mapId

    local dungeonInfoList = G_Me.vipData:getDailyDungeonList()
    if mapId > #dungeonInfoList then
        return
    end

    local info = dungeonInfoList[mapId]

    local open_level = info.level_1

    if info["isOpenToday"] == false then
        self:getImageViewByName("Image_hero"):loadTexture("ui/vip/fuben_weikaiqi.png")
        self._bg:setVisible(false)
        self._bg0:loadTexture("ui/vip/fuben_normal_bg.png")
        self:getPanelByName("Panel_Level_Open"):setVisible(false)
        self:getPanelByName("Panel_Weekday_Open"):setVisible(true)
        if info.dungeon_type == 1 then
            self:getLabelByName("Label_Day_Tag_1"):setText(G_lang:get("LANG_DAILY_DUNGEON_OPEN_TIPS_ODD_1"))
            self:getLabelByName("Label_Day_Tag_2"):setText(G_lang:get("LANG_DAILY_DUNGEON_OPEN_TIPS_ODD_2"))
        elseif info.dungeon_type == 2 then
            self:getLabelByName("Label_Day_Tag_1"):setText(G_lang:get("LANG_DAILY_DUNGEON_OPEN_TIPS_EVEN_1"))
            self:getLabelByName("Label_Day_Tag_2"):setText(G_lang:get("LANG_DAILY_DUNGEON_OPEN_TIPS_EVEN_2"))
        end
        self:getImageViewByName("Image_txtBg"):loadTexture("ui/vip/fubenmingzi_bg_gray.png")
    elseif G_Me.userData.level >= open_level then
        self:getImageViewByName("Image_hero"):loadTexture(G_Me.vipData:getMosterIconPic(info.pic_icon))
        self._bg:setVisible(true)
        self._bg0:loadTexture("ui/vip/fuben_normal_bg.png")
        self:getPanelByName("Panel_Level_Open"):setVisible(false)
        self:getImageViewByName("Image_txtBg"):loadTexture("ui/vip/fubenmingzi_bg.png")

        local hasBeaten = true
        local unbeatenDungeons = G_Me.vipData:getUnbeatenDungeons()
        for i=1, #unbeatenDungeons do
            if info.id == unbeatenDungeons[i] then
                hasBeaten = false
                break
            end
        end

        self:showWidgetByName("Image_Tips", not hasBeaten)
    else
        self:getImageViewByName("Image_hero"):loadTexture("ui/vip/fuben_weikaiqi.png")
        self._bg:setVisible(false)
        self._bg0:loadTexture("ui/vip/fuben_normal_bg.png")
        self:getPanelByName("Panel_Level_Open"):setVisible(true)
        self:getImageViewByName("Image_txtBg"):loadTexture("ui/vip/fubenmingzi_bg_gray.png")
        self._levelLabel:setText(G_lang:get("LANG_LEVEL_INFO_FORMAT", {levelValue = open_level}))
    end
    self:getLabelByName("Label_map"):setText(info.name)
    self:getLabelByName("Label_map"):createStroke(Colors.strokeBrown, 1)
end

function VipMapCell:checked()
    self._bg:loadTexture("ui/vip/fuben_xuanzhong.png")
    self._bg0:loadTexture("ui/vip/fuben_xuanzhong_bg.png")
end

function VipMapCell:unchecked()
    self._bg:loadTexture("ui/vip/fuben_normal.png")
    self._bg0:loadTexture("ui/vip/fuben_normal_bg.png")
end

function VipMapCell:showTips( shouldShowTips )
    self:showWidgetByName("Image_Tips", shouldShowTips)
end

return VipMapCell

