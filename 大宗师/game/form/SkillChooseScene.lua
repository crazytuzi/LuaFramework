--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-26
-- Time: 下午6:11
-- To change this template use File | Settings | File Templates.
--
--

local data_item_nature = require("data.data_item_nature")

local Item = class("Item", function()
    return CCTableViewCell:new()
end)

function Item:getContentSize()
    return CCSizeMake(display.width, 155)
end

function Item:ctor()

end

function Item:getTutoBtn()
    return self._rootnode["upgradeBtn"]
end

function Item:create(param)
    local _viewSize = param.viewSize
    local _listener = param.listener

    local proxy = CCBProxy:create()
    self._rootnode = {}
    local node = CCBuilderReaderLoad("equip/equip_item.ccbi", proxy, self._rootnode)
    node:setPosition(_viewSize.width / 2, self._rootnode["itemBg"]:getContentSize().height / 2)
    self:addChild(node)

    self._rootnode["upgradeBtn"]:addHandleOfControlEvent(function(eventName,sender)
        self._rootnode["upgradeBtn"]:setEnabled(false)
        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
        if _listener then
            _listener(self:getIdx())
        end
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end,
    CCControlEventTouchDown)

    self.nameLabel = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_haibao,
        size = 30,
    })
    self._rootnode["itemNameLabel"]:addChild(self.nameLabel)

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

function Item:refreshLabel(itemData)
    self.nameLabel:setString(itemData.baseData.name)
    self.nameLabel:setColor(NAME_COLOR[itemData.baseData.quality])
    self.nameLabel:setPosition(self.nameLabel:getContentSize().width / 2, 0)

    local index = 1

    for i = 1, 3 do
        self._rootnode["propLabel_" .. tostring(i)]:setVisible(false)
    end

    for i = 1, 4 do
        local prop = itemData.data.baseRate[i]
        local str = ""
        if prop > 0 then
            local nature = data_item_nature[BASE_PROP_MAPPPING[i]]
            str = nature.nature
            if nature.type == 1 then
                str = string.format("%s+%d", str, prop)
            else
                str = string.format("%s+%d%%", str, prop / 100)
            end

            self._rootnode["propLabel_" .. tostring(index)]:setString(str)
            self._rootnode["propLabel_" .. tostring(index)]:setVisible(true)
            index = index + 1
        end
    end

    self._rootnode["lvLabel"]:setString(string.format("LV.%d", itemData.data.level))
    self._rootnode["qualitySprite"]:setDisplayFrame(display.newSpriteFrame(string.format("item_board_num_%d.png", itemData.baseData.quality)))
    self.pjLabel:setString(tostring(itemData.baseData.equip_level))
    if itemData["data"]["cid"] > 0 then

        local card = ResMgr.getCardData(itemData["data"]["cid"])

        if card.id == 1 or card.id == 2 then
            self._rootnode["equipHeroName"]:setString("装备于" ..game.player:getPlayerName())
        else
            self._rootnode["equipHeroName"]:setString("装备于" ..card.name)
        end

--        self._rootnode["equipHeroName"]:setString("装备于：" .. ResMgr.getCardData(itemData["data"]["cid"]).name)
    else
        self._rootnode["equipHeroName"]:setString("")
    end
end


function Item:refresh(param)
    local _itemData = param.itemData

    ResMgr.refreshIcon({
        itemBg = self._rootnode["headIcon"],
        id = _itemData.data.resId,
        resType = ResMgr.EQUIP
    })

    self:refreshLabel(_itemData)

end


local data_item_item = require("data.data_item_item")
local SkillChooseScene = class("SkillChooseScene", function()

    return require("game.BaseScene").new({
        contentFile = "public/window_content_scene.ccbi",
        subTopFile = "formation/formation_skill_sub_top.ccbi",
        bgImage    = "ui_common/common_bg.png",
        imageFromBottom = true
    })
end)


function SkillChooseScene:ctor(param)
    local _index = param.index
    local _subIndex = param.subIndex
    local _callback = param.callback
    local _cid      = param.cid
    PostNotice(NoticeKey.UNLOCK_BOTTOM)
    game.runningScene = self
    ResMgr.createBefTutoMask(self)

    local _sz = self._rootnode["listView"]:getContentSize()
    self._rootnode["backBtn"]:addHandleOfControlEvent(function(eventName,sender)
        self._rootnode["backBtn"]:setEnabled(false)
        _callback()
        pop_scene()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    end,
        CCControlEventTouchDown)

    local function sortFunc(lh, rh)
        if lh.cid > 0 and rh.cid == 0 then
            return true
        elseif (lh.cid == 0 and rh.cid == 0) or (lh.cid > 0 and rh.cid > 0) then
            return data_item_item[lh.resId].quality > data_item_item[rh.resId].quality
        end
        return false
    end

    local _data = {}
    for k, v in ipairs(game.player:getSkills(sortFunc)) do

        if _subIndex == data_item_item[v.resId].pos then
            table.insert(_data, {
                baseData = data_item_item[v.resId],
                data = v
            })

            printf("%d   %d", v.pos, v.cid)
        end
    end

    local function putoff()
        for k, v in ipairs(_data) do
            if v.data.pos == _index and v.data.cid == _cid then
                v.data.pos = 0
                v.data.cid = 0
                break
            end
        end
    end


    self._scrollItemList = require("utility.TableViewExt").new({
        size        = CCSizeMake(_sz.width, _sz.height),
        direction   = kCCScrollViewDirectionVertical,
        createFunc  = function(idx)
            local item = Item.new()
            idx = idx + 1
            return item:create({
                viewSize = _sz,
                itemData = _data[idx],
                idx      = idx,
                listener = function(cellIdx)

                    RequestHelper.formation.putOnEquip({
                        pos = _index,
                        subpos = _subIndex,
                        id = _data[cellIdx + 1].data._id,
                        callback = function(data)

                            if string.len(data["0"]) > 0 then
                                CCMessageBox(data["0"], "Tip")
                            else

                                putoff()
                                _data[cellIdx + 1].data.pos = _index
                                _data[cellIdx + 1].data.cid = _cid

                                if _callback then
                                    _callback(data)
                                end
                                pop_scene()
                            end
                        end
                    })
                end
            })

        end,
        refreshFunc = function(cell, idx)
            idx = idx + 1
            cell:refresh({
                idx = idx,
                itemData = _data[idx]
            })
        end,
        cellNum   = #_data,
        cellSize    = Item.new():getContentSize(),

    })
    self._scrollItemList:setPosition(0, 0)
    local cell = self._scrollItemList:cellAtIndex(0)
    if cell ~= nil then
        self.tutoBtn = cell:getTutoBtn()
    end

    self._rootnode["listView"]:addChild(self._scrollItemList)
end



function SkillChooseScene:onEnter()

    TutoMgr.addBtn("zhuangbei_wuxue_btn",self.tutoBtn)
    TutoMgr.active()
end

function SkillChooseScene:onExit()
    TutoMgr.removeBtn("zhuangbei_wuxue_btn")
end

return SkillChooseScene



