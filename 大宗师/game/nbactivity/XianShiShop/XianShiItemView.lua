--
-- Author: Your Name
-- Date: 2015-03-16 13:08:39
--
local data_item_item = require("data.data_item_item")
local data_xianshishangdian_xianshishangdian = require("data.data_xianshishangdian_xianshishangdian")
local XianShiItemView = class("JifenRewordItem", function()
	return CCTableViewCell:new()
end)


function XianShiItemView:getContentSize()

	return CCSizeMake(620,230)
end


function XianShiItemView:refreshItem(param)

	local itemData = param.itemData
    local confirmFunc = param.confirmFunc

    local titleName = ui.newTTFLabelWithOutline({  text = data_xianshishangdian_xianshishangdian[itemData.id].name, 
                                            size = 20, 
                                            color = ccc3(255,210,0),
                                            outlineColor = ccc3(0,0,0),
                                            align= ui.TEXT_ALIGN_CENTE,
                                            font = FONTS_NAME.font_fzcy 
                                            })
    self._rootnode["titlename"]:setString("")
    self._rootnode["titlename"]:removeAllChildren()
    self._rootnode["titlename"]:addChild(titleName)

    local priceLabel = ui.newTTFLabelWithOutline({  text = "200", 
                                            size = 20, 
                                            color = ccc3(255,210,0),
                                            outlineColor = ccc3(0,0,0),
                                            align= ui.TEXT_ALIGN_CENTE,
                                            font = FONTS_NAME.font_fzcy 
                                            })
    self._rootnode["price"]:setString("")
    self._rootnode["price"]:removeAllChildren()
    priceLabel:setPosition(-20,- 5)
    self._rootnode["price"]:addChild(priceLabel)

    local vipFont = ui.newBMFontLabel({
            text = "2",
            font = "fonts/font_vip.fnt",
            align = ui.TEXT_ALIGN_LEFT
        })
    self._rootnode["viptag"]:removeAllChildren()
    vipFont:setPosition(cc.p(50,2))
    self._rootnode["viptag"]:addChild(vipFont)


	local itemData = {
        iconType = ResMgr.getResType(data_item_item[param.itemData.itemid].type),
        type     = data_item_item[param.itemData.itemid].type,
        num = param.itemData.itemnum,
        id = param.itemData.itemid
    } 
	local rewardIcon = self._rootnode["reward_icon"]
	rewardIcon:removeAllChildrenWithCleanup(true)
    if itemData.type ~= 6 then
        ResMgr.refreshIcon({
            id = itemData.id, 
            resType = itemData.iconType, 
            itemBg = rewardIcon, 
            iconNum = itemData.num, 
            isShowIconNum = false, 
            numLblSize = 22, 
            numLblColor = ccc3(0, 255, 0), 
            numLblOutColor = ccc3(0, 0, 0) 
        })
        local canhunIcon = self._rootnode["reward_canhun"]
        local suipianIcon = self._rootnode["reward_suipian"]
        if itemData.type == 3 then
            -- 装备碎片
            suipianIcon:setVisible(true)
        elseif itemData.type == 5 then
            -- 残魂(武将碎片)
            canhunIcon:setVisible(true)
        end
        local nameKey = "reward_name"

        local nameColor = ccc3(255, 255, 255)
        if itemData.iconType == ResMgr.ITEM or itemData.iconType == ResMgr.EQUIP then 
            nameColor = ResMgr.getItemNameColor(itemData.id)
        elseif itemData.iconType == ResMgr.HERO then 
            nameColor = ResMgr.getHeroNameColor(itemData.id)
        end

        local nameLbl = ui.newTTFLabelWithShadow({
            text = require("data.data_item_item")[itemData.id].name,
            size = 20,
            color = nameColor,
            shadowColor = ccc3(0,0,0),
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
        })

        nameLbl:setPosition(-nameLbl:getContentSize().width/2, nameLbl:getContentSize().height/2 - 15)
        self._rootnode[nameKey]:removeAllChildren()
        self._rootnode[nameKey]:addChild(nameLbl)
    else
        self._rootnode["reward_icon"]:setDisplayFrame(display.newSprite("ui/ui_empty.png"):getDisplayFrame())
        self._rootnode["reward_icon"]:removeAllChildrenWithCleanup(true)
        self._rootnode["reward_icon"]:addChild(require("game.Spirit.SpiritIcon").new({
            resId = itemData.id
        }))
        require("game.Spirit.SpiritCtrl").clear()
    end
    

    local closeFun = function()
        print("click")
        if confirmFunc then
            confirmFunc(param.index,self)    
        end
    end
    self._rootnode["rewardBtn"]:addHandleOfControlEvent(closeFun,CCControlEventTouchUpInside)
    
    local vip = game.player:getVip()
    local numTotal = data_xianshishangdian_xianshishangdian[param.itemData.id].arr_sum2[vip]
    self._rootnode["timeleft"]:setString(param.itemData.leftNum)
    self._rootnode["timeleft1"]:setString(param.itemData.canBuyNum)
    self._rootnode["timeleftall"]:setString("/"..numTotal)
    priceLabel:setString(param.itemData.price)
    vipFont:setString(vip)
end

function XianShiItemView:create(param)
    local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("nbhuodong/xianshishop_item.ccbi", proxy, self._rootnode)
	node:setAnchorPoint(cc.p(0,0))
	self:addChild(node)

    local itemData = {
        iconType = ResMgr.getResType(data_item_item[param.itemData.itemid].type),
        type     = data_item_item[param.itemData.itemid].type,
        num = param.itemData.itemnum,
        id = param.itemData.itemid
    } 
    addTouchListener(self._rootnode["reward_icon"], function(sender,eventType)
        if eventType == EventType.began then
            sender:setScale(0.9)
        elseif eventType == EventType.ended then
            if itemData.type ~= 6 then
                local itemInfo = require("game.Huodong.ItemInformation").new({
                                id = itemData.id,
                                type = itemData.type, 
                                name = data_item_item[tonumber(itemData.id)].name, 
                                describe = data_item_item[tonumber(itemData.id)].describe
                                })
                CCDirector:sharedDirector():getRunningScene():addChild(itemInfo,10000)
            else
                local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, {resId = tonumber(itemData.id)},nil,closeFunc)
                CCDirector:sharedDirector():getRunningScene():addChild(descLayer, 10000000)
            end 
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        elseif eventType == EventType.cancel then
            sender:setScale(1)
        end
    end)

	self:refreshItem(param)

	return self
end

function XianShiItemView:refresh(param)
	self:refreshItem(param)
end


return XianShiItemView
