--
-- Author: Daneil
-- Date: 2015-03-06 14:27:27
--

local SuijiCell = class("SuijiCell", function()
	return display.newLayer()
end)


function SuijiCell:getContentSize()

	return CCSizeMake(105, 120)
end


function SuijiCell:refreshItem(param)

	local itemData = param.itemData

	-- 图标
	local rewardIcon = self._rootnode["reward_icon"]
	rewardIcon:removeAllChildrenWithCleanup(true)


	-- 属性图标 
	local canhunIcon = self._rootnode["reward_canhun"]
	local suipianIcon = self._rootnode["reward_suipian"]
	canhunIcon:setVisible(false)
	suipianIcon:setVisible(false)

    --真气动画
    if itemData.type == 6 then
        self._rootnode["reward_icon"]:setDisplayFrame(display.newSprite("ui/ui_empty.png"):getDisplayFrame())
        self._rootnode["reward_icon"]:removeAllChildrenWithCleanup(true)
        self._rootnode["reward_icon"]:addChild(require("game.Spirit.SpiritIcon").new({
            resId = itemData.id
        }))
        require("game.Spirit.SpiritCtrl").clear()
    else
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

        if itemData.type == 3 then
            -- 装备碎片
            suipianIcon:setVisible(true)
        elseif itemData.type == 5 then
            -- 残魂(武将碎片)
            canhunIcon:setVisible(true)
        end

        if itemData.hideCorner then
            canhunIcon:setVisible(false)
            suipianIcon:setVisible(false)
        end
    end


	addTouchListener(rewardIcon, function (sender,eventType)
    	if eventType == EventType.ended then
    		local itemInfo = require("game.Huodong.ItemInformation").new({
                        id = itemData.id, 
                        type = itemData.type, 
                        name = itemData.name, 
                        describe = require("data.data_item_item")[itemData.id].dis
                        })

        	CCDirector:sharedDirector():getRunningScene():addChild(itemInfo, 100000)
    	end
    end)

	-- 名称
	local nameKey = "reward_name"
	local nameColor = ccc3(255, 255, 255)
	if itemData.iconType == ResMgr.ITEM or itemData.iconType == ResMgr.EQUIP then 
		nameColor = ResMgr.getItemNameColor(itemData.id)
	elseif itemData.iconType == ResMgr.HERO then 
		nameColor = ResMgr.getHeroNameColor(itemData.id)
	end

    local nameLbl = ui.newTTFLabelWithShadow({
        text = itemData.name,
        size = 20,
        color = nameColor,
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
    })

    nameLbl:setPosition(-nameLbl:getContentSize().width/2, nameLbl:getContentSize().height/2)
    self._rootnode[nameKey]:removeAllChildren()
    self._rootnode[nameKey]:addChild(nameLbl)

end


function SuijiCell:create(param)
    local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}

	local node = CCBuilderReaderLoad("reward/reward_item.ccbi", proxy, self._rootnode)
	local contentSize = self._rootnode["reward"]:getContentSize()
	node:setPosition(self:getContentSize().width * 0.5, _viewSize.height * 0.5)
	self:addChild(node)

	self:refreshItem(param)

	return self
end

function SuijiCell:refresh(param)
	self:refreshItem(param)
end


return SuijiCell