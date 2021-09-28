--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-7-24
-- Time: 下午5:17
-- To change this template use File | Settings | File Templates.
--




local Item = class("Item", function()
    return CCTableViewCell:new()
end)

function Item:getContentSize()
    return CCSizeMake(display.width , 155)
end

function Item:ctor()

end

function Item:create(param)

    local _viewSize = param.viewSize
    local _listener = param.listener

    local proxy = CCBProxy:create()
    self._rootnode = {}
    local node = CCBuilderReaderLoad("formation/formation_hero_item.ccbi", proxy, self._rootnode)
    node:setPosition(_viewSize.width / 2, self._rootnode["itemBg"]:getContentSize().height / 2)
    self:addChild(node)

    self.heroName = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_haibao,
        size = 30,
    })
    self._rootnode["itemNameLabel"]:addChild(self.heroName)

    self.pzLabel = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_haibao,
        size = 20,
        x = 0,
        y = self._rootnode["hjSprite"]:getContentSize().height / 2,
        align = ui.TEXT_ALIGN_CENTER
    })
    self._rootnode["hjSprite"]:addChild(self.pzLabel)

    self._rootnode["equipBtn"]:addHandleOfControlEvent(function(eventName,sender)
        self._rootnode["equipBtn"]:setEnabled(false)

        if _listener then
            _listener(self:getIdx())
        end
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    end,
        CCControlEventTouchDown)
    self:refresh(param)

    return self
end

function Item:refreshLabel(itemData)
    self.heroName:setString(itemData.baseData.name)
    self.heroName:setColor(NAME_COLOR[itemData.data.star])
    self._rootnode["lvLabel"]:setString("LV." .. tostring(itemData.data.level))
    self._rootnode["clsLabel"]:setString("+" .. tostring(itemData.data.cls))
    self.heroName:setPosition(self.heroName:getContentSize().width / 2, 0)

    if itemData.data.cls > 0 then
        self._rootnode["clsLabel"]:setVisible(true)
    else
        self._rootnode["clsLabel"]:setVisible(false)
    end
    
end

function Item:refresh(param)
    local _itemData = param.itemData


    for i = 1, 5 do
        if _itemData.baseData.star[1] >= i then
            self._rootnode["star" .. tostring(i)]:setVisible(true)
        else
            self._rootnode["star" .. tostring(i)]:setVisible(false)
        end
    end

--    if _itemData.data.pos > 0 then
--        self._rootnode["shangzhenIcon"]:setVisible(true)
--    else
--        self._rootnode["shangzhenIcon"]:setVisible(false)
--    end

    ResMgr.refreshIcon({
        itemBg = self._rootnode["headIcon"],
        id = _itemData.data.resId,
        resType = ResMgr.HERO,
        cls = _itemData.data.cls
    })

    self.pzLabel:setString(string.format("资质:%d", _itemData.baseData.arr_zizhi[_itemData.data.cls + 1]))
    self.pzLabel:setPositionX(10 + self.pzLabel:getContentSize().width / 2)
    self._rootnode["jobSprite"]:setDisplayFrame(display.newSpriteFrame(string.format("zhenrong_job_%d.png", _itemData.baseData.job)))
--    if _itemData.baseData.hero and _itemData.baseData.hero > 0 then
--        self._rootnode["hjSprite"]:setVisible(true)
--    else
--        self._rootnode["hjSprite"]:setVisible(false)
--    end

    self:refreshLabel(_itemData)
 

end



local HeroChooseScene = class("HeroChooseScene", function()
    return require("game.BaseScene").new({
        contentFile = "public/window_content_scene.ccbi",
        subTopFile = "formation/formation_hero_sub_top.ccbi",
        bgImage    = "ui_common/common_bg.png"
    })
end)


function HeroChooseScene:ctor(param)
    local _index = param.index or -1
--    local _subIndex = param.subIndex
    local _callback = param.callback
    local _closelistener = param.closelistener

    game.runningScene = self
    ResMgr.createBefTutoMask(self)

    local _sz = self._rootnode["listView"]:getContentSize()

    self._rootnode["backBtn"]:addHandleOfControlEvent(function(eventName,sender)
        self._rootnode["backBtn"]:setEnabled(false)
        pop_scene()
        if _closelistener then
            _closelistener()
        end
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
    end,
        CCControlEventTouchDown)

    local _data = {}

    local heroList = game.player:getHero()



    for i = 1,#heroList do
        if heroList[i].pos == 0 then
            _data[#_data + 1] =  {
                baseData = ResMgr.getCardData(heroList[i].resId),
                data = heroList[i]
            }
        end
    end

    local function getHeroByPos(pos)
        for i = 1,#heroList do
            if pos == heroList[i].pos then
                return heroList[i]
            end
        end
        return nil
    end

    local function getPos()
        if _index and _index > 0 then
            return tostring(_index)
        end
        return nil
    end

    local function onEquip(cellIdx)
        printf("========== hello")
        RequestHelper.formation.set({
            pos = getPos(),
            id = _data[cellIdx + 1].data._id,
            callback = function(data)
                -- dump(data)
                 PostNotice(NoticeKey.REMOVE_TUTOLAYER)
                if string.len(data["0"]) > 0 then
                    CCMessageBox(data["0"], "Tip")
                else
                    local heroPos = 0
                    for k, v in ipairs(data["1"]) do
                        if v.objId == _data[cellIdx + 1].data._id then
                            heroPos = v.pos
                        end
                    end

--                  改变装备状态
                    for _, v in ipairs(game.player:getEquipments()) do
                        if v.pos == _index then
                            v.cid = _data[cellIdx + 1].data.resId
                        end
                    end

                    for _, v in ipairs(game.player:getSpirit()) do
                        if v.pos == _index then
                            v.cid = _data[cellIdx + 1].data.resId
                        end
                    end

--                  改变英雄状态
                    local curHero = getHeroByPos(heroPos)
                    if curHero then
                        curHero.pos = 0
                        curHero.cid = 0
                    end

                    _data[cellIdx + 1].data.pos = heroPos

                    if _callback then
                        _callback(data)
                    end

                    pop_scene()
                end
            end
        })
    end

    HeroModel.sortHeroChose(_data)

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
                listener = onEquip
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
    self._rootnode["listView"]:addChild(self._scrollItemList)



    local cell = self._scrollItemList:cellAtIndex(0)
    if cell ~= nil then 
        local btn =  cell._rootnode["equipBtn"]

        TutoMgr.addBtn("zhenrong_btn_xuanzexiake_shangzhen", btn)
        
    end

    TutoMgr.active()

end



function HeroChooseScene:onEnter()
    game.runningScene = self
end

function HeroChooseScene:onExit()
    TutoMgr.removeBtn("zhenrong_btn_xuanzexiake_shangzhen")
    TutoMgr.active()
end

return HeroChooseScene



