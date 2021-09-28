local data_item_item = require("data.data_item_item")

local COMMON_VIEW = 1
local SALE_VIEW = 2

local WEAPON_TYPE =2
local HELMENT_TYPE = 1
local ARMOUR_TYPE = 4
local EAR_TYPE = 3

local baseStateStr = {"生命","攻击","物防","法防","最终伤害","最终免伤"}

local EquipListCellVTwo = class("EquipListCellVTwo", function (param)
--    display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
--    display.addSpriteFramesWithFile("ui/ui_equipV2.plist", "ui/ui_equipV2.png")
    return CCTableViewCell:new()
end)

function EquipListCellVTwo:getContentSize()

    return CCSizeMake(display.width, 154) --sprite:getContentSize()
end

function EquipListCellVTwo:create(param)
    local changeSoldMoney = param.changeSoldMoney

    local addSellItem  = param.addSellItem
    local removeSellItem = param.removeSellItem

    self.choseTable = param.choseTable
    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("equip/equip_list_item.ccbi", proxy, self._rootnode)
    node:setPosition(display.width * 0.5, self._rootnode["itemBg"]:getContentSize().height / 2)
    self:addChild(node)

    self.cellIndex = param.id
    local createXiLian = param.createXiLianListenr
    local createQiangHuaLayer =param.createQiangHuaListener

    self.createEquipInfoLayer = param.createEquipInfoLayer

    self.bg = self._rootnode["itemBg"]--display.newSprite("#herolist_board.png")

    self.list = param.listData
    self.saleList = param.saleData
    self.nameList = param.nameData

    self.headIcon = self._rootnode["headIcon"]

    self._rootnode["head_touch_node"]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        if event.name == "began" then
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            HeroSettingModel.resetIndexByPos(self.nameList[self.pos])
            self.createEquipInfoLayer(self.cellIndex)
            return true
        end
    end)
    self._rootnode["head_touch_node"]:setTouchEnabled(true)

    self.lvNum = self._rootnode["lvNum"]
    self.tabSprite = self._rootnode["tabIcon"]

    self.EquipName = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_fzcy,
        size = 24
    })
    self._rootnode["kongfuName"]:addChild(self.EquipName)

    self.starNum = self._rootnode["starNumSprite"]

    self.equipOn = self._rootnode["equipOn"]

    self.normalBtns = self._rootnode["btns"]

    self.sellBtns = self._rootnode["sellBtns"]
    self.selIcon = self._rootnode["selIcon"]
    self.unSelIcon = self._rootnode["unSelIcon"]

    -- self._rootnode["qianghuaBtn"]:addHandleOfControlEvent(function(eventName,sender) 
    ResMgr.setControlBtnEvent(self._rootnode["qianghuaBtn"],function()
        local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.ZhuangBei_QiangHua, game.player:getLevel(), game.player:getVip()) 
        if not bHasOpen then
            show_tip_label(prompt)
        else
            createQiangHuaLayer(self.cellIndex)
        end
    end)


   ResMgr.setControlBtnEvent(self._rootnode["jinglianBtn"],function()
 
        local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.XiLian, game.player:getLevel(), game.player:getVip()) 
        if not bHasOpen then
            show_tip_label(prompt)
        else
            createXiLian(self.cellIndex)
        end
    end)


    self._rootnode["selIcon"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function(tag)
        -- GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
        self._rootnode["selIcon"]:setVisible(false)
        self._rootnode["unSelIcon"]:setVisible(true)
        removeSellItem(self.objId,self.index)
        changeSoldMoney(0-self.silver )
    end,
        CCControlEventTouchUpInside)

    self._rootnode["unSelIcon"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function(tag)

        self._rootnode["unSelIcon"]:setVisible(false)
        self._rootnode["selIcon"]:setVisible(true)
        addSellItem(self.objId,self.index)
        changeSoldMoney(self.silver )
    end,
        CCControlEventTouchUpInside)
    local hee = param.id

    self:refresh(hee,param.viewType, self.choseTable[param.id+1])
    return self
end

function EquipListCellVTwo:setStars(num)
    for i = 1,5 do
        if i > num then
            self._rootnode["star"..i]:setVisible(false)
        else
            self._rootnode["star"..i]:setVisible(true)
        end
    end
end



function EquipListCellVTwo:beTouched()

end

function EquipListCellVTwo:refresh(id,viewType,isSel)
    local curList = nil
    if viewType == COMMON_VIEW then
        curList = self.list
        self._rootnode["commonNode"]:setVisible(true)
        self._rootnode["sellNode"]:setVisible(false)
    else
        self._rootnode["commonNode"]:setVisible(false)
        self._rootnode["sellNode"]:setVisible(true)
        curList = self.saleList
    end
    self.index = id + 1

    self.cellData = curList[id+1]
    if self.cellData == nil then
        return
    end


    self.cellIndex = id
    self.objId = self.cellData["_id"]
    self.baseData = self.cellData["base"]
    self.curExp = self.cellData["curExp"]
    self.lvl = self.cellData["level"]
    self.pos = self.cellData["pos"]
    self.props = self.cellData["props"]
    self.propsWait = self.cellData["propsWait"]
    self.relation = self.cellData["relation"]
    self.resID = self.cellData["resId"]
    self.silver = self.cellData["silver"]
    self.starNumStr = self.cellData["star"]
    self.subpos = self.cellData["subpos"]
    self.cellType = self.cellData["type"]

    if(data_item_item[self.resID].polish == 0)then
        self._rootnode["jinglianBtn"]:setVisible(false)
    else
        self._rootnode["jinglianBtn"]:setVisible(true)
    end
    --
    self._rootnode["lvNum"]:setString("LV." .. tostring(self.lvl))

    self._rootnode["price"]:setString(tostring(self.silver))

    local equipStaticData = data_item_item[self.resID]
    local nameStr = equipStaticData["name"]


    self:changeStarNum(self.starNumStr)
    self.EquipName:setString(tostring(nameStr))
    self.EquipName:setColor(NAME_COLOR[self.starNumStr])
    self.EquipName:setPosition(self.EquipName:getContentSize().width / 2, 0)

    ResMgr.refreshIcon({id = self.resID,resType = ResMgr.EQUIP,itemBg = self.headIcon})

    if self.pos == 0 then
        self.equipOn:setVisible(false)
    else
        self.equipOn:setVisible(true)
        if self.pos == 1 then
            self.equipOn:setString("装备于" .. tostring(game.player:getPlayerName()))
        else
            self.equipOn:setString("装备于" .. tostring(self.nameList[self.pos]))
        end
    end


    local equipTabStr =equipStaticData["pos"]
    if equipTabStr == WEAPON_TYPE then
        self.tabSprite:setDisplayFrame(display.newSpriteFrame("equip_weapon_tab.png"))
    elseif equipTabStr == HELMENT_TYPE then
        self.tabSprite:setDisplayFrame(display.newSpriteFrame("equip_helment_tab.png"))
    elseif equipTabStr == ARMOUR_TYPE then
        self.tabSprite:setDisplayFrame(display.newSpriteFrame("equip_armour_tab.png"))
    elseif equipTabStr == EAR_TYPE then
        self.tabSprite:setDisplayFrame(display.newSpriteFrame("equip_ear_tab.png"))
    end

    local baseState = self.baseData
    for i =1,3 do
        local curTitle = self._rootnode["stateValue"..i]
        curTitle:setVisible(false)
    end
    local k = 1 --用来判断基础属性应该显示在第几行
    for i =1,#baseState do
        if baseState[i] ~= 0 and k < 4 then
            local curTitle = self._rootnode["stateValue"..k]
            curTitle:setVisible(true)
            k = k + 1
            curTitle:setString(tostring(baseStateStr[i]) .. "+" .. tostring(baseState[i]))

        end
    end

    if k > 3 then
        device.showAlert("Value overflow", "Too much value in this", {"YES", "NO"})
    end

    if isSel == true then
        self._rootnode["unSelIcon"]:setVisible(false)
        self._rootnode["selIcon"]:setVisible(true)
    else
        self._rootnode["selIcon"]:setVisible(false)
        self._rootnode["unSelIcon"]:setVisible(true)
    end
    

    local pinjiValue = equipStaticData["equip_level"]
    self._rootnode["pin_ji"]:removeAllChildren()
    if pinjiValue ~= nil then
        local pinjiFont = ui.newTTFLabelWithShadow({
            text = pinjiValue,
            font = FONTS_NAME.font_fzcy,
            shadowColor = ccc3(0,0,0),
            color = ccc3(0, 219, 52),
            size = 20,
            align = ui.TEXT_ALIGN_CENTER
        })
        pinjiFont:setPosition(self._rootnode["pin_ji"]:getContentSize().width/2,-15)
        self._rootnode["pin_ji"]:addChild(pinjiFont)
    end

    if zizhiData ~= nil then
        local zizhiValue = zizhiData[self.cls + 1]
        self._rootnode["pin_ji"]:removeAllChildren()

    end


end


function EquipListCellVTwo:changeStarNum(num)


    self.starNum:setDisplayFrame(display.newSpriteFrame(string.format("item_board_num_%d.png", num)))

end

function EquipListCellVTwo:runEnterAnim(  )
    local delayTime = self.cellIndex*0.15
    local sequence = transition.sequence({
        CCCallFuncN:create(function ( )
            self:setPosition(CCPoint((self:getContentSize().width/2 + display.width/2),self:getPositionY()))
        end),
        CCDelayTime:create(delayTime),CCMoveBy:create(0.3, CCPoint(-(self:getContentSize().width/2 + display.width/2), 0))})
    self:runAction(sequence)
end



return EquipListCellVTwo