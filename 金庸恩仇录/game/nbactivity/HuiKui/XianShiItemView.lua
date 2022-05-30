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
	--local node = CCBuilderReaderLoad("nbhuodong/chongzhihuikui_item.ccbi", proxy, self._rootnode)	
	--self:addChild(node)	
	--local size = node:getContentSize()	
	--self:removeSelf()
	--return size
	return cc.size(620,230)
end

function XianShiItemView:regItemIconTouch(reward_icon, itemData)
	local reward_icon_node = tolua.cast(reward_icon,"cc.Node")	
	reward_icon_node:setTouchEnabled(true)			
	reward_icon_node:setNodeEventEnabled(true)	
	reward_icon_node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)	
		if event.name == "began" then
           if tonumber(itemData.type) == 6 then
                local endFunc = function()
                    CCDirector:sharedDirector():getRunningScene():removeChildByTag(1111)
                    print("click------")
                end
                if not CCDirector:sharedDirector():getRunningScene():getChildByTag(1111) then 
                    local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, {resId = tonumber(itemData.id)},nil,endFunc)
                    CCDirector:sharedDirector():getRunningScene():addChild(descLayer, 1000,1111)
                    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
                end             
            end
			return true
        elseif event.name == "ended" then		
            if tonumber(itemData.type) ~= 6 then
                local endFunc = function()
                    CCDirector:sharedDirector():getRunningScene():removeChildByTag(1111)
                    print("click------")
                end
                if not CCDirector:sharedDirector():getRunningScene():getChildByTag(1111) then 
                    local itemInfo = require("game.Huodong.ItemInformation").new({
                                id = itemData.id,
                                type = itemData.type, 
                                name = data_item_item[tonumber(itemData.id)].name, 
                                describe = data_item_item[tonumber(itemData.id)].describe,
                                endFunc = endFunc
                                })
                    CCDirector:sharedDirector():getRunningScene():addChild(itemInfo,10000,1111)
                end  
            end
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))			
			return true	
        end
    end)
end	

function XianShiItemView:refreshItem(param)
	self:removeAllChildrenWithCleanup(true)
		
	self.id = param.itemData.id	
    local _viewSize = param.viewSize
    local proxy = CCBProxy:create()
    self._rootnode = {}	
	local node = CCBuilderReaderLoad("nbhuodong/chongzhihuikui_item.ccbi", proxy, self._rootnode)
	self:addChild(node)

    local itemData = {
        iconType = ResMgr.getResType(data_item_item[param.itemData.itemid].type),
        type     = data_item_item[param.itemData.itemid].type,
        num = param.itemData.itemnum,
        id = param.itemData.itemid
    }
	
	self:regItemIconTouch(self._rootnode["reward_icon"], itemData)	
	
	local itemData = param.itemData
    local confirmFunc = param.confirmFunc

    local titleDis = {"全服活动期间限量","全服每日限量"}

    local title01 = {"剩余总量:","今日剩余总量:"}
    local title02 = {"可购买数量:","今日可购买数量:"}


    self._rootnode["title_01"]:setString(title01[itemData.sale])
    self._rootnode["title_02"]:setString(title02[itemData.sale])

    local titleName = ui.newTTFLabelWithOutline({  text = titleDis[itemData.sale], 
                                            size = 22, 
                                            color = cc.c3b(255,210,0),
                                            outlineColor = cc.c3b(0,0,0),
                                            align= ui.TEXT_ALIGN_CENTE,
                                            font = FONTS_NAME.font_fzcy 
                                            })
    titleName:setPosition(cc.p(self._rootnode["titlename"]:getContentSize().width / 2,self._rootnode["titlename"]:getContentSize().height / 2))
    self._rootnode["titlename"]:setString("")
    self._rootnode["titlename"]:removeAllChildren()
    self._rootnode["titlename"]:addChild(titleName)

    local priceLabel = ui.newTTFLabelWithOutline({  text = "200", 
                                            size = 20, 
                                            color = cc.c3b(255,210,0),
                                            outlineColor = cc.c3b(0,0,0),
                                            align= ui.TEXT_ALIGN_CENTE,
                                            font = FONTS_NAME.font_fzcy 
                                            })											
	self._rootnode["price"]:setString("")
    self._rootnode["price"]:removeAllChildren()	
	priceLabel:align(display.BOTTOM_LEFT, - 10, 0)
	:addTo(self._rootnode["price"])		
	
	local vipFont = ui.newBMFontLabel({
            text = "2",
            font = "fonts/font_vip.fnt",
            align = ui.TEXT_ALIGN_LEFT
        })
    self._rootnode["viptag"]:removeAllChildren()
    vipFont:setPosition(cc.p(50,2))
    self._rootnode["viptag"]:addChild(vipFont)


	local itemData = {
        iconType = ResMgr.getResType(param.itemData.type),
        type     = param.itemData.type,
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
            numLblColor = cc.c3b(0, 255, 0), 
            numLblOutColor = cc.c3b(0, 0, 0) 
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

        local tag
        -- 装备碎片
        if tonumber(itemData.type) == 3 then
            tag = display.newSprite("#sx_suipian.png")
        elseif tonumber(itemData.type) == 5 then
            -- 残魂(武将碎片)
            tag = display.newSprite("#sx_canhun.png")
        end
        if tag then
            self._rootnode["reward_icon"]:addChild(tag)
            tag:setRotation(-20)
            tag:setPosition(cc.p(40,75))
        end

        local nameKey = "reward_name"

        local nameColor = cc.c3b(255, 255, 255)
        if itemData.iconType == ResMgr.ITEM or itemData.iconType == ResMgr.EQUIP then 
            nameColor = ResMgr.getItemNameColor(itemData.id)
        elseif itemData.iconType == ResMgr.HERO then 
            nameColor = ResMgr.getHeroNameColor(itemData.id)
        end

        local nameLbl = ui.newTTFLabelWithShadow({
            text = require("data.data_item_item")[itemData.id].name,
            size = 20,
            color = nameColor,
            shadowColor = display.COLOR_BLACK,
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
        })
		
		local nameLblTemp = self._rootnode[nameKey]
		local px, py = nameLblTemp:getPosition()		
		nameLbl:align(display.BOTTOM_LEFT, px, py)
		:addTo(nameLblTemp:getParent())
		nameLblTemp:setVisible(false)		
	else
        self._rootnode["reward_icon"]:setDisplayFrame(display.newSprite("ui/ui_empty.png"):getDisplayFrame())
        self._rootnode["reward_icon"]:removeAllChildrenWithCleanup(true)
        self._rootnode["reward_icon"]:addChild(require("game.Spirit.SpiritIcon").new({
            resId = itemData.id,
            bShowName = true
        }))
        require("game.Spirit.SpiritCtrl").clear()
        self._rootnode["reward_icon"]:setPositionY(100)
    end
    

    local closeFun = function()
        print("click")
        if confirmFunc then
            confirmFunc(param.index,self)    
        end
    end
    self._rootnode["rewardBtn"]:addHandleOfControlEvent(closeFun,CCControlEventTouchUpInside)
    
    local vip = game.player:getVip()
    local numTotal
    if vip < param.itemData.vip then
        numTotal = data_xianshishangdian_xianshishangdian[param.itemData.id].arr_sum2[param.itemData.vip + 1]
    else
        numTotal = data_xianshishangdian_xianshishangdian[param.itemData.id].arr_sum2[vip + 1]
    end

    self._rootnode["timeleft"]:setString(param.itemData.leftNum.."/"..data_xianshishangdian_xianshishangdian[param.itemData.id].sum1)
    self._rootnode["timeleft1"]:setString(param.itemData.canBuyNum)
    self._rootnode["timeleftall"]:setString("/"..numTotal)

    if param.itemData.sale == 1 then 
        self._rootnode["timeleft"]:setPosition(cc.p(self._rootnode["timeleft"]:getPositionX() - 28,self._rootnode["timeleft"]:getPositionY() - 3))
        self._rootnode["timeleft1"]:setPositionX(self._rootnode["timeleft1"]:getPositionX() - 50)
        self._rootnode["timeleftall"]:setPositionX(self._rootnode["timeleftall"]:getPositionX() - 50)
    else
        self._rootnode["timeleft"]:setPosition(cc.p(self._rootnode["timeleft"]:getPositionX() + 20,self._rootnode["timeleft"]:getPositionY() - 3))
        self._rootnode["timeleft1"]:setPositionX(self._rootnode["timeleft1"]:getPositionX())
        self._rootnode["timeleftall"]:setPositionX(self._rootnode["timeleftall"]:getPositionX())
    end




    priceLabel:setString(param.itemData.price)
    vipFont:setString(data_xianshishangdian_xianshishangdian[param.itemData.id].vip)

    if vip >= data_xianshishangdian_xianshishangdian[param.itemData.id].vip then
        vipFont:setVisible(false)
        self._rootnode["viptag"]:setVisible(false)
        self._rootnode["buy_tag"]:setVisible(false)
        
    else
        self._rootnode["rewardBtn"]:setEnabled(false)
    end

    if param.itemData.canBuyNum == 0 or param.itemData.leftNum == 0 then 
        self._rootnode["rewardBtn"]:setEnabled(false)
    end

    self._rootnode["rewardBtn"]:setZOrder(10000)
end

function XianShiItemView:create(param)
	self:refreshItem(param)	
	return self
end

function XianShiItemView:refresh(param)
	self:refreshItem(param)
end


return XianShiItemView
