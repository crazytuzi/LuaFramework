local DailyPvpTopTxtCell = class ("DailyPvpTopTxtCell", function (  )
	return CCSItemCellBase:create("ui_layout/dailypvp_PaiHangTxtCell.json")
end)
local MergeEquipment = require("app.data.MergeEquipment")
require("app.cfg.daily_crosspvp_rank_title")

function DailyPvpTopTxtCell:ctor(list, index)
    self._bgImg = self:getImageViewByName("Image_bg")
    self._titlelabel = self:getLabelByName("Label_title")
    self._attrlabel1 = self:getLabelByName("Label_attr1")
    self._attrlabel2 = self:getLabelByName("Label_attr2")
    self._attrlabel3 = self:getLabelByName("Label_attr3")
    self._needRanklabel = self:getLabelByName("Label_needRank")
    self._needRongyulabel = self:getLabelByName("Label_needRongyu")
end

function DailyPvpTopTxtCell:updateData(data)
    local imgName = data.id%2 == 1 and "ui/vip/fubentiaozhan_list1.png" or "ui/vip/fubentiaozhan_list2.png"
    self._bgImg:loadTexture(imgName)
    self._titlelabel:setText(data.text)
    self._titlelabel:setColor(Colors.qualityColors[data.quality])
    self._titlelabel:createStroke(Colors.strokeBrown, 1)
    self._needRanklabel:setText(data.low_rank>0 and data.low_rank or G_lang:get("LANG_WUSH_NO"))
    self._needRongyulabel:setText(data.low_value)

    local loadString = function ( label,_type,_value )
        if _type > 0 then
            local _,_,typeStr,valueStr = MergeEquipment.convertAttrTypeAndValue(_type, _value)
            label:setText(typeStr.."+"..valueStr)
            label:setVisible(true)
        else
            label:setVisible(false)
        end
    end

    if data.add_type2 > 0 then
        self._attrlabel1:setVisible(true)
        self._attrlabel2:setVisible(true)
        self._attrlabel3:setVisible(false)
        loadString(self._attrlabel1,data.add_type1,data.add_value1)
        loadString(self._attrlabel2,data.add_type2,data.add_value2)
    else
        self._attrlabel1:setVisible(false)
        self._attrlabel2:setVisible(false)
        self._attrlabel3:setVisible(true)
        loadString(self._attrlabel3,data.add_type1,data.add_value1)
    end

    if data.add_type1 == 0 then
        self._attrlabel3:setText(G_lang:get("LANG_WUSH_NO"))
        self._attrlabel3:setVisible(true)
    end
end

return DailyPvpTopTxtCell

