-- local CScrollCell = import("app.ui.CScrollCell")
-- local SubMapScrollCell = class("SubMapScrollCell",CScrollCell)


local SubMapScrollCell = class("SubMapScrollCell", function ()
    display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
    return CCTableViewCell:new()
end)

function SubMapScrollCell:getContentSize()

    if self._sz then

    else
        local proxy = CCBProxy:create()
        local rootnode = {}

        local node = CCBuilderReaderLoad("ccbi/fuben/sub_map_item.ccbi", proxy, rootnode)
        self._sz = rootnode["itemBg"]:getContentSize()

        self:addChild(node)
        node:removeSelf()
    end

    return self._sz
end

function SubMapScrollCell:create(param)
    local _itemData = param.itemData
    local _viewSize = param.viewSize
    local _subMapInfo = param.mapInfo
    local _onBtn  = param.onBtn 

    local proxy = CCBProxy:create()
    self._rootnode = {}

--    dump(_itemData)
--    dump(_subMapInfo)
    local node = CCBuilderReaderLoad("ccbi/fuben/sub_map_item.ccbi", proxy, self._rootnode)
        node:setPosition(_viewSize.width / 2, self._rootnode["itemBg"]:getContentSize().height / 2)
    self:addChild(node) 

    -- boss 头像
    local headIcon = ResMgr.getLevelBossIcon( _itemData.baseInfo.icon, _itemData.baseInfo.type )
    headIcon:setPosition(self._rootnode["headIcon"]:getContentSize().width/2, self._rootnode["headIcon"]:getContentSize().height/2)
    self._rootnode["headIcon"]:addChild(headIcon,1,100)

    self._rootnode["okBtn"]:addHandleOfControlEvent(function()
        if _onBtn then
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            -- print("mamamaamamamam")
            ResMgr.createMaskLayer()
            _onBtn(self:getIdx())
            ResMgr.removeMaskLayer()

        end
    end, CCControlEventTouchUpInside)


    self._sz = self._rootnode["itemBg"]:getContentSize()

    self.titleLabel = ui.newTTFLabelWithOutline({
        text = "",
        font = FONTS_NAME.font_haibao,
        size = 26,
        color = FONT_COLOR.LEVEL_NAME,
        -- outlineColor = ccc3(100,17,2),
        align = ui.TEXT_ALIGN_CENTER,
        -- x = self._rootnode["nameLabel"]:getContentSize().width/2,
        -- y = self._rootnode["nameLabel"]:getContentSize().height/2,
        })
    self.titleLabel:setAnchorPoint(ccp(0,0.5))
    self._rootnode["nameLabel"]:addChild(self.titleLabel)
    self:refresh(param)
    return self
end

function SubMapScrollCell:getBtn()
    return self._rootnode["okBtn"]
end

function SubMapScrollCell:refresh(param) 
    local _subMapInfo = param.mapInfo 
    local _itemData = param.itemData 
    -- self._rootnode["nameLabel"]:setString(_itemData.baseInfo.name) 
    self.titleLabel:setString(_itemData.baseInfo.name)
    self.titleLabel:setPosition(self.titleLabel:getContentSize().width/2,self._rootnode["nameLabel"]:getContentSize().height/2)


    -- dump(_subMapInfo["1"][tostring(_itemData.baseInfo.id)].cnt)
    -- dump(_itemData.baseInfo.number)

    local totalLbl = self._rootnode["challenge_total_num_lbl"] 
    local curNumLbl = self._rootnode["challenge_cur_num_lbl"] 
    curNumLbl:setString(tostring(_subMapInfo["1"][tostring(_itemData.baseInfo.id)].cnt)) 
    totalLbl:setString("/" .. tostring(_itemData.baseInfo.number)) 
    totalLbl:setPositionX(curNumLbl:getPositionX() + curNumLbl:getContentSize().width) 

    self._rootnode["star_3"]:setVisible(true)
    self._rootnode["star_2"]:setVisible(true)
    self._rootnode["star_3"]:setVisible(true)

    if(_itemData.baseInfo.star == 2) then
        self._rootnode["star_3"]:setVisible(false)
    elseif(_itemData.baseInfo.star == 1) then
        self._rootnode["star_2"]:setVisible(false)
        self._rootnode["star_3"]:setVisible(false)
    end

    self._rootnode["star_" .. tostring(3)]:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
    self._rootnode["star_" .. tostring(2)]:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
    self._rootnode["star_" .. tostring(1)]:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
    
    self._rootnode["headIcon"]:removeChildByTag(100)
    local headIcon = ResMgr.getLevelBossIcon( _itemData.baseInfo.icon, _itemData.baseInfo.type )
    headIcon:setPosition(self._rootnode["headIcon"]:getContentSize().width/2, self._rootnode["headIcon"]:getContentSize().height/2)
    self._rootnode["headIcon"]:addChild(headIcon,1,100)

    if _itemData.star > 0 then 
        for i = 1, _itemData.star do 
            if i > 3 then
                break 
            end
            self._rootnode["star_" .. tostring(i)]:setDisplayFrame(display.newSpriteFrame("submap_star_light.png"))
        end
    else
        -- self._rootnode["star_" .. tostring(3)]:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
        -- self._rootnode["star_" .. tostring(2)]:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
        -- self._rootnode["star_" .. tostring(1)]:setDisplayFrame(display.newSpriteFrame("submap_star_dark.png"))
    end
end


return SubMapScrollCell
