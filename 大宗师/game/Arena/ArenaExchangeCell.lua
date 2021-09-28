--[[
 --
 -- add by vicky
 -- 2014.10.06
 --
 --]]

 local ArenaExchangeCell = class(ArenaExchangeCell, function()
 	return CCTableViewCell:new()
 end)
 local ARENA_EXCHANGE_TYPE = 1
local HUASHAN_SHOP_TYPE = 2

 function ArenaExchangeCell:getContentSize()
    if self.Cntsize ~= nil then

    else
        local proxy = CCBProxy:create()
        local rootnode = {}
        local node = CCBuilderReaderLoad("arena/exchange_item.ccbi", proxy, rootnode)
        self.Cntsize = node:getContentSize()
    end

    return self.Cntsize
 end

 function ArenaExchangeCell:ctor(cellType)
    self.cellType = cellType or ARENA_EXCHANGE_TYPE
 end

function ArenaExchangeCell:resetByCellType()
    if self.cellType == ARENA_EXCHANGE_TYPE then
        self._rootnode["shengwang_icon"]:setVisible(true)
        self._rootnode["lingshi_icon"]:setVisible(false)   
        
    else
        self._rootnode["shengwang_icon"]:setVisible(false)
        self._rootnode["lingshi_icon"]:setVisible(true)
        self._rootnode["propLabel_1"]:setString("灵石:")
    end
end

 function ArenaExchangeCell:create(param)
 	local viewSize = param.viewSize 
 	local informationFunc = param.informationFunc 
 	self._exchangeFunc = param.exchangeFunc 
    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("arena/exchange_item.ccbi", proxy, self._rootnode)
    node:setPosition(viewSize.width/2, 0) 
    self:addChild(node)

    self:resetByCellType()

    self:updateItem(param.itemData) 

    self._rootnode["exchangeBtn"]:addHandleOfControlEvent(function()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
       	if self._exchangeFunc ~= nil then 
            self:updateExchangeBtn(false) 
       		self._exchangeFunc(self) 
       	end 
    end, CCControlEventTouchUpInside) 

    local rewardIcon = self._rootnode["itemIcon"]
	rewardIcon:setTouchEnabled(true) 
	rewardIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)  
        if (event.name == "began") then
        	return true  
        elseif (event.name == "ended") then 
        	informationFunc(self)
        end
    end)

 	return self 
 end 


 function ArenaExchangeCell:updateExchangeBtn(bEnabled)
    self._rootnode["exchangeBtn"]:setEnabled(bEnabled) 
 end 


 function ArenaExchangeCell:updateExchangeNum(limitNum, had)
    self._itemData.limitNum = limitNum or self._itemData.limitNum 
    self._itemData.had = had or self._itemData.had 

    -- 更新按钮状态
    if self._itemData.limitNum == 0 then 
        self:updateExchangeBtn(false) 
    else 
        self:updateExchangeBtn(true) 
    end 

    -- 可兑换次数 
    if self._itemData.limitNum == -1 then 
        self._rootnode["exchange_num_lbl"]:setVisible(false)
    else
        self._rootnode["exchange_num_lbl"]:setVisible(true)

        if self._itemData.type1 == 1 then 
            self._rootnode["exchange_num_lbl"]:setString("（总共可兑换" .. tostring(self._itemData.limitNum) .. "次）")
        else
            self._rootnode["exchange_num_lbl"]:setString("（今日可兑换" .. tostring(self._itemData.limitNum) .. "次）")
        end 
    end 
 end


 function ArenaExchangeCell:updateItem(itemData)
    self._itemData = itemData 
    self:updateExchangeNum(self._itemData.limitNum, self._itemData.had)

 	-- 图标
	local rewardIcon = self._rootnode["itemIcon"]
	rewardIcon:removeAllChildrenWithCleanup(true) 
	-- ResMgr.refreshIcon({id = self._itemData.id, resType = self._itemData.iconType, itemBg = rewardIcon}) 
    ResMgr.refreshIcon({
        id = self._itemData.id, 
        resType = self._itemData.iconType, 
        itemBg = rewardIcon, 
        iconNum = self._itemData.num, 
        isShowIconNum = false, 
        numLblSize = 22, 
        numLblColor = ccc3(0, 255, 0), 
        numLblOutColor = ccc3(0, 0, 0) 
    })

	-- 属性图标
	local canhunIcon = self._rootnode["reward_canhun"]
	local suipianIcon = self._rootnode["reward_suipian"] 
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)

	if self._itemData.type == 3 then
		-- 装备碎片
		suipianIcon:setVisible(true) 
	elseif self._itemData.type == 5 then
		-- 残魂(武将碎片)
		canhunIcon:setVisible(true) 
	end 



	-- 名称
	local nameColor = ccc3(255, 255, 255)
	if self._itemData.iconType == ResMgr.ITEM or self._itemData.iconType == ResMgr.EQUIP then 
		nameColor = ResMgr.getItemNameColor(self._itemData.id)
	elseif self._itemData.iconType == ResMgr.HERO then 
		nameColor = ResMgr.getHeroNameColor(self._itemData.id)
	end

	local nameLbl = ui.newTTFLabelWithShadow({
        text = self._itemData.name,
        size = 24,
        color = nameColor,
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_haibao,
        align = ui.TEXT_ALIGN_CENTER 
        })

	nameLbl:setPosition(nameLbl:getContentSize().width/2, 0)
	self._rootnode["itemNameLbl"]:removeAllChildren()
    self._rootnode["itemNameLbl"]:addChild(nameLbl) 

    -- 描述
    self._rootnode["itemDesLbl"]:setString(self._itemData.describe) 

	-- 需要的等级 
    if game.player:getLevel() >= self._itemData.needLevel then 
        self._rootnode["tag_level_node"]:setVisible(false) 
    else 
        self._rootnode["tag_level_node"]:setVisible(true)  
        self._rootnode["dengji_num"]:setString(self._itemData.needLevel) 
    end 

	-- 需要的声望
	self._rootnode["shengwang_num"]:setString(self._itemData.needReputation)
 end


 function ArenaExchangeCell:refresh(itemData)

 	self:updateItem(itemData) 
 end



 return ArenaExchangeCell 
