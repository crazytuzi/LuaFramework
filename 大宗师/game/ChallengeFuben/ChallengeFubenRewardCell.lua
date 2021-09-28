--[[
 --
 -- add by vicky
 -- 2015.03.13 
 --
 --]]


local ChallengeFubenRewardCell = class("ChallengeFubenRewardCell", function()
    return CCTableViewCell:new()
end)


function ChallengeFubenRewardCell:getContentSize() 
    local proxy = CCBProxy:create()
    local rootNode = {}

    local node = CCBuilderReaderLoad("challenge/challengeFuben_reward_item.ccbi", proxy, rootNode) 
    local size = rootNode["itemBg"]:getContentSize()
    self:addChild(node)
    node:removeSelf()
    return size
end


-- 更新奖励图标、名称、数量
function ChallengeFubenRewardCell:updateItem(itemData)
    -- dump(itemData, "奖励数据", 8)
    self._rootnode["title_icon"]:setDisplayFrame(display.newSprite("#cfb_reward_title_" .. itemData.iconName .. ".png"):getDisplayFrame()) 

    for i, v in ipairs(itemData.cellDatas) do 
        local reward = self._rootnode["reward_" ..tostring(i)]
        reward:setVisible(true)

        -- 图标
        local rewardIcon = self._rootnode["reward_icon_" ..tostring(i)]
        rewardIcon:removeAllChildrenWithCleanup(true) 
        ResMgr.refreshIcon({
            id = v.id, 
            resType = v.iconType, 
            itemBg = rewardIcon, 
            iconNum = v.num, 
            isShowIconNum = false, 
            numLblSize = 22, 
            numLblColor = ccc3(0, 255, 0), 
            numLblOutColor = ccc3(0, 0, 0) 
        }) 

        -- 属性图标
        local canhunIcon = self._rootnode["reward_canhun_" .. i]
        local suipianIcon = self._rootnode["reward_suipian_" .. i]
        canhunIcon:setVisible(false)
        suipianIcon:setVisible(false)

        if v.type == 3 then
            -- 装备碎片
            suipianIcon:setVisible(true) 
        elseif v.type == 5 then
            -- 残魂(武将碎片)
            canhunIcon:setVisible(true) 
        end

        -- 名称
        local nameKey = "reward_name_" .. tostring(i)
        local nameColor = ccc3(255, 255, 255)
        if v.iconType == ResMgr.ITEM or v.iconType == ResMgr.EQUIP then 
            nameColor = ResMgr.getItemNameColor(v.id)
        elseif v.iconType == ResMgr.HERO then 
            nameColor = ResMgr.getHeroNameColor(v.id)
        end

        local nameLbl = ui.newTTFLabelWithShadow({
            text = v.name,
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

    -- 道具类型达不到4个时，剩余的道具框隐藏
    local count = #itemData.cellDatas
    while (count < 5) do
        self._rootnode["reward_" ..tostring(count + 1)]:setVisible(false)
        count = count + 1
    end
end


function ChallengeFubenRewardCell:getIcon(index)
    return self._rootnode["reward_icon_" ..tostring(index)]
end


function ChallengeFubenRewardCell:create(param)
    
    local viewSize = param.viewSize 
    local itemData = param.itemData 
    local rewardListener = param.rewardListener
    local informationListener = param.informationListener

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("challenge/challengeFuben_reward_item.ccbi", proxy, self._rootnode)
    node:setPosition(viewSize.width * 0.5, 0)
    self:addChild(node) 

    self:updateItem(itemData) 

    return self
end


function ChallengeFubenRewardCell:refresh(itemData)
    self:updateItem(itemData)
end




return ChallengeFubenRewardCell

