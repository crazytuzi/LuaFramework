-- Filename: GodRewardCell.lua
-- Author: DJN
-- Date: 2014-12-23
-- Purpose: 神兵排行奖励tableView

module("GodRewardCell", package.seeall)

require "db/DB_Overcome_reward"
require "script/utils/extern"
require "script/utils/LuaUtil"
require "script/ui/item/ItemUtil"


--创建tableCell
function create( rewardInfo )
    local tableCell = CCTableViewCell:create()
    --_rewardId = rewardInfo.type
    print("rewardInfo")
    print_t(rewardInfo)
    local cellBackground = CCScale9Sprite:create("images/reward/cell_back.png")
    cellBackground:setContentSize(CCSizeMake(568, 207))
    tableCell:addChild(cellBackground)

    local cellTitlePanel = CCScale9Sprite:create("images/reward/cell_title_panel.png")
    cellTitlePanel:setContentSize(CCSizeMake(297, 55))
    cellTitlePanel:setAnchorPoint(ccp(0, 1))
    cellTitlePanel:setPosition(ccp(0, cellBackground:getContentSize().height))
    cellBackground:addChild(cellTitlePanel)

    local nameStr = rewardInfo.desc or ""
    local title = CCRenderLabel:create(nameStr,g_sFontPangWa,30,1, ccc3(0,0,0))
    title:setColor(ccc3(0xff,0xfb,0xd9))
    title:setAnchorPoint(ccp(0.5,0.5))
    title:setPosition(ccp(cellTitlePanel:getContentSize().width*0.5,cellTitlePanel:getContentSize().height*0.5))
    cellTitlePanel:addChild(title)

    --创建奖励物品
    local itemback = CCScale9Sprite:create("images/reward/item_back.png")
    itemback:setContentSize(CCSizeMake(530, 130))
    itemback:setAnchorPoint(ccp(0.5,0))
    itemback:setPosition(ccp(cellBackground:getContentSize().width*0.5, 19))
    cellBackground:addChild(itemback)
    
    local rewardTable = ItemUtil.getItemsDataByStr(rewardInfo.items)
    
    
    local function rewardItemTableCallback( fn, p_table, a1, a2 )
        --print(fn)
        local r
        local length = table.count(rewardTable)
        if fn == "cellSize" then
            r = CCSizeMake(110, 115)
            -- print("cellSize", a1, r)
        elseif fn == "cellAtIndex" then
            -- if not a2 then
            a2 = CCTableViewCell:create()
            local itemIconBg = nil
            local itemIcon   = nil
           
            itemIconBg = ItemUtil.createGoodsIcon(rewardTable[a1+1],GodRewardPreview.getTouchPriority()-50,nil,nil,showDownMenu)
            a2:addChild(itemIconBg)             
            itemIconBg:setAnchorPoint(ccp(0, 0))
            itemIconBg:setPosition(ccp(10, 30))         
            r = a2
            -- print("cellAtIndex", a1, r)
        elseif fn == "numberOfCells" then           
            r = length
        elseif fn == "cellTouched" then
        end
        return r
    end

    local tableViewSize = CCSizeMake(397,118)

    local rewardItemTable  = LuaTableView:createWithHandler(LuaEventHandler:create(rewardItemTableCallback),tableViewSize)
    itemback:addChild(rewardItemTable)
    rewardItemTable:setBounceable(true)
    rewardItemTable:setAnchorPoint(ccp(0, 0))
    rewardItemTable:setPosition(ccp(5, 0))
    rewardItemTable:setDirection(kCCScrollViewDirectionHorizontal)
    rewardItemTable:setTouchPriority(GodRewardPreview.getTouchPriority()-30)
    rewardItemTable:reloadData()
    
    return tableCell
end


function showDownMenu()
    MainScene.setMainSceneViewsVisible(false,false,false)
end