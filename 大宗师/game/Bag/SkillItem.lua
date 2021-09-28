--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-6-17
-- Time: 上午10:30
-- To change this template use File | Settings | File Templates.
--

local data_item_item = require("data.data_item_item")
local data_kongfu_kongfu = require("data.data_kongfu_kongfu")
local data_refine_refine = require("data.data_refine_refine")

local SkillItem = class("SkillItem", function()
    return CCTableViewCell:new()
end)

function SkillItem:getContentSize()
    return CCSizeMake(display.width * 0.98, 158)
end

-- 1 使用界面
-- 2 出售界面
local ITEM_TYPE_USE  = 1
local ITEM_TYPE_SALE = 2

function SkillItem:create(param)
    local _viewSize = param.viewSize
    local _useListener = param.useListener

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("bag/bag_skill_item.ccbi", proxy, self._rootnode)
    node:setPosition(_viewSize.width / 2, self._rootnode["itemBg"]:getContentSize().height / 2)
    self:addChild(node, 0)
    self.typeNode = display.newNode()
    node:addChild(self.typeNode)

    self._rootnode["qianghuaBtn"]:addHandleOfControlEvent(function()
        if _useListener then
            self._rootnode["qianghuaBtn"]:setEnabled(false)
            _useListener(self, 1)
        end
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end, CCControlEventTouchUpInside)

    self._rootnode["jinglianBtn"]:addHandleOfControlEvent(function()
        local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.NeiWaiGong_JingLian, game.player:getLevel(), game.player:getVip()) 
        if not bHasOpen then 
            show_tip_label(prompt) 
        else
            if _useListener then
                _useListener(self, 2)
            end
        end
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end, CCControlEventTouchDown)

    self._rootnode["iconSprite"]:setTouchEnabled(true)
    self._rootnode["iconSprite"]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if _useListener then
            _useListener(self, 3)
        end
    end)

    local _itemData = param.itemData 
    self.itemName = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_fzcy,
        size = 24,
        color = NAME_COLOR[_itemData.star],
    })
    self._rootnode["itemNameLabel"]:addChild(self.itemName)

    self.pjLabel = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_haibao,
        size = 20,
        color = FONT_COLOR.GREEN
    })
    self._rootnode["pjLabel"]:addChild(self.pjLabel)

    self:refresh(param)
    return self
end

function SkillItem:touch(bChoose)

    if bChoose then
        self._rootnode["itemSelectedSprite"]:setDisplayFrame(display.newSpriteFrame("item_board_selected.png"))
    else
        self._rootnode["itemSelectedSprite"]:setDisplayFrame(display.newSpriteFrame("item_board_unselected.png"))
    end

end

function SkillItem:refresh(param)
    local _itemData = param.itemData
    local _itemType = param.itemType

    self.itemName:setString(data_item_item[_itemData.resId].name)
    self.itemName:setColor(NAME_COLOR[_itemData.star])
    self.itemName:setPosition(self.itemName:getContentSize().width / 2, 0)

    self._rootnode["qianghuaBtn"]:setEnabled(true)
    for i = 1, 3 do
        self._rootnode["propLabel_" .. tostring(i)]:setString("")
    end
--
    if data_item_item[_itemData.resId].pos == 101 or
      data_item_item[_itemData.resId].pos == 102 then
        self._rootnode["propLabel_" .. tostring(1)]:setString(string.format("经验+%d", data_item_item[_itemData.resId].exp))
        self._rootnode["qianghuaBtn"]:setVisible(false)
        self._rootnode["jinglianBtn"]:setVisible(false)
    elseif data_item_item[_itemData.resId].pos == 103 or
            data_item_item[_itemData.resId].pos == 104 then
        self._rootnode["qianghuaBtn"]:setVisible(false)
        self._rootnode["jinglianBtn"]:setVisible(false)
    else
--        dump(_itemData)
        self._rootnode["qianghuaBtn"]:setVisible(true)
--        dump(data_refine_refine[_itemData.resId])
        if data_refine_refine[_itemData.resId] and data_refine_refine[_itemData.resId].Refine and data_refine_refine[_itemData.resId].Refine > 0 then
            self._rootnode["jinglianBtn"]:setVisible(true)
        else
            self._rootnode["jinglianBtn"]:setVisible(false)
        end
        self._rootnode["jinglianBtn"]:setVisible(true)
        local index = 1
        for i = 1, 4 do
            local prop = _itemData.baseRate[i]
            local str = ""
            if prop > 0 then
                local data_item_nature = require("data.data_item_nature")
                local nature = data_item_nature[BASE_PROP_MAPPPING[i]]
                str = nature.nature
                if nature.type == 1 then
                    str = str .. string.format("+%d", prop)
                else
                    str = str .. string.format("+%.2f%%", prop / 100)
                end
                self._rootnode["propLabel_" .. tostring(index)]:setString(str)
                index = index + 1
            end
        end
    end
----
    self._rootnode["lvLabel"]:setString("LV." .. tostring(_itemData.level))
    self.pjLabel:setString(tostring(data_item_item[_itemData.resId].equip_level))
    if _itemType == ITEM_TYPE_SALE then
        self._rootnode["useView"]:setVisible(false)
        self._rootnode["saleView"]:setVisible(true)

        local silver = (data_kongfu_kongfu[_itemData.level + 1].sumexp[_itemData.star] + _itemData.curExp) * 5 * (_itemData.star - 1)

        silver = silver + data_item_item[_itemData.resId].price
--        self._rootnode["silverLabel"]:setString(tostring(data_item_item[_itemData.resId].price))
        self._rootnode["silverLabel"]:setString(tostring(silver))
        self:touch(param.bChoose)
    else
        self._rootnode["useView"]:setVisible(true)
        self._rootnode["saleView"]:setVisible(false)
        self._rootnode["qualitySprite"]:setDisplayFrame(display.newSpriteFrame(string.format("item_board_num_%d.png", _itemData.star)))
        if _itemData["cid"] > 0 then

            local card = ResMgr.getCardData(_itemData["cid"])

            if card.id == 1 or card.id == 2 then
                self._rootnode["equipHeroName"]:setString("装备于" ..game.player:getPlayerName())
            else
                self._rootnode["equipHeroName"]:setString("装备于" ..card.name)
            end
        else
            self._rootnode["equipHeroName"]:setString("")
        end
    end
----
    if data_item_item[_itemData.resId].pos == 5 or data_item_item[_itemData.resId].pos == 101 then
        self._rootnode["flagSprite"]:setDisplayFrame(display.newSpriteFrame("item_board_ng.png"))
    else
        self._rootnode["flagSprite"]:setDisplayFrame(display.newSpriteFrame("item_board_wg.png"))
    end
    ResMgr.refreshIcon({
        itemBg = self._rootnode["iconSprite"],
        id = _itemData.resId,
        resType = ResMgr.EQUIP
    })

end

return SkillItem

