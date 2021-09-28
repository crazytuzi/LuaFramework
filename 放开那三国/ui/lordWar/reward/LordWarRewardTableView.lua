-- Filename: LordWarRewardTableView.lua
-- Author: DJN
-- Date: 2014-08-04
-- Purpose: 跨服赛奖励tableView

module("LordWarRewardTableView", package.seeall)

require "db/DB_Kuafu_challengereward"
require "script/ui/item/ItemUtil"
require "script/model/utils/ActivityConfig"
require "script/ui/item/ItemSprite"

local _ServerTag = nil
local _TableInfo = nil
local _stage = nil
local _cellNum = 0
local _isItemTag = nil --用于标识一个icon是否为item类型 是item类型的图标创建方法与其他有所不同
----存放每个cell的标题，用的行数做索引
-- local titleStr = {GetLocalizeStringBy("djn_14"),GetLocalizeStringBy("djn_15"),GetLocalizeStringBy("djn_16"),GetLocalizeStringBy("djn_17"),
--                   GetLocalizeStringBy("djn_18"),GetLocalizeStringBy("djn_19")}
--  分解表中物品字符串数据
function setCellNum( ... )
   _cellNum = table.count(_TableInfo)
    -- print("cellNum行数~~~~~~~~~~~~~~~~~~~~~~")
    -- print(_cellNum)
end
--将数据表中的奖励 **，**，**转换成table的形式
function analyzeGoodsTabStr( goodsStr )
    if(goodsStr == nil)then
        return
    end
    local goodsData = {}
    local goodTab = string.split(goodsStr, ",")
    local tableCount = table.count(goodTab)
    for i = 1,tableCount do
        local tab = string.split(goodTab[i],"|")
        table.insert(goodsData,tab)
    end
    return goodsData
end

--[[
    @des   :用stage作为表格的下标的索引，设置当前显示的是“傲视群雄”还是“初出茅庐”的奖励
    @param : stage:  2--傲视群雄  1-- 初出茅庐
    return :
--]]
function setStage(stage)
    _stage = stage
    _TableInfo = _ServerTag[_stage]
end

--[[
    @des    :创建tableView
    @param  :（1，1）跨服傲视群雄 （1，2）跨服初出茅庐（2，1）服内傲视群雄 （2，2）服内初出茅庐 
    @return :创建好的tableView
--]]
function createTableView(server,stage)
    require "script/ui/lordWar/LordWarData"
    local info = LordWarData.getLordInfo()
    --判断欲取的数据是服内还是跨服的数据
    if(server == 1)then
        -- print("输出跨服奖励")
        -- print_t(ActivityConfig.ConfigCache.lordwar.data[1].rewardPreviewOut.."123")
        -- print_t(ActivityConfig.ConfigCache.lordwar.data[1].outScoreRewardId)
        _ServerTag = analyzeGoodsTabStr(ActivityConfig.ConfigCache.lordwar.data[1].rewardPreviewOut)
        -- require "db/DB_Kuafu_personchallenge"
        -- print_t(DB_Kuafu_personchallenge.getDataById(1).outScoreRewardId)
        -- _ServerTag = analyzeGoodsTabStr(DB_Kuafu_personchallenge.getDataById(1).outScoreRewardId)
        -- print("输出跨服奖励")
        -- print_t(_ServerTag)
        
    elseif (server == 2)then 
        -- print("输出服内奖励")
        -- print_t(ActivityConfig.ConfigCache.lordwar.data[1].rewardPreviewIn.."123")
        _ServerTag = analyzeGoodsTabStr(ActivityConfig.ConfigCache.lordwar.data[1].rewardPreviewIn)
        --  print("输出服内奖励")
        -- print_t(_ServerTag)
    else
        --print("奖励预览传入的服务器参数错误")
    end 
    setStage(stage)
   
    setCellNum()
    local h = LuaEventHandler:create(function(fn,table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(575, 210)
        elseif fn == "cellAtIndex" then
            --用a1+1做下标创建cell
            a2 = createPreviewCell(_cellNum - a1)
            r = a2
        elseif fn == "numberOfCells" then
            r = _cellNum
        else
            print("other function")
        end

        return r
    end)

    return LuaTableView:createWithHandler(h, CCSizeMake(575, 661))
end

--[[
    @des    :创建奖励预览cell
    @param  :奖励的位置，从1开始（即a1+1的值）
    @return :创建好的cell
--]]
function createPreviewCell(p_pos)
    local tCell = CCTableViewCell:create()

    --背景
    local cellBgSprite = CCScale9Sprite:create("images/reward/cell_back.png")
    cellBgSprite:setContentSize(CCSizeMake(555,200))
    cellBgSprite:setAnchorPoint(ccp(0,0))
    cellBgSprite:setPosition(ccp(10,10))
    tCell:addChild(cellBgSprite)

    --标题背景
    local titleBgSprite = CCScale9Sprite:create("images/sign/sign_bottom.png")
    titleBgSprite:setContentSize(CCSizeMake(270,60))
    titleBgSprite:setAnchorPoint(ccp(0,1))
    titleBgSprite:setPosition(ccp(0,cellBgSprite:getContentSize().height))
    cellBgSprite:addChild(titleBgSprite)

    --标题名称
    local titleLabel = CCRenderLabel:create(DB_Kuafu_challengereward.getDataById(tonumber(_TableInfo[p_pos])).des,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke) 
    -- if(p_pos <= table.count(titleStr))then
    --    titleLabel = CCRenderLabel:create(titleStr[p_pos],g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke) 
    -- else
    --    titleLabel = CCRenderLabel:create("",g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    -- end
    titleLabel:setColor(ccc3(0xff,0xf6,0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp(titleBgSprite:getContentSize().width/2,titleBgSprite:getContentSize().height/2))
    titleBgSprite:addChild(titleLabel)

    --二级白色背景
    local whiteBgSprite = CCScale9Sprite:create("images/recycle/reward/rewardbg.png")
    whiteBgSprite:setContentSize(CCSizeMake(520,130))
    whiteBgSprite:setAnchorPoint(ccp(0.5,0))
    whiteBgSprite:setPosition(ccp(cellBgSprite:getContentSize().width/2,15))
    cellBgSprite:addChild(whiteBgSprite)

    --tableView嵌套tableView
    local innerTableView = createInnerTableView(p_pos)
    innerTableView:setAnchorPoint(ccp(0,0))
    innerTableView:setPosition(ccp(0,0))
    require "script/ui/lordWar/reward/LordWarRewardLayer"
    innerTableView:setTouchPriority(LordWarRewardLayer.getTouchPriority() - 1)
    innerTableView:setDirection(kCCScrollViewDirectionHorizontal)
    innerTableView:reloadData()
    whiteBgSprite:addChild(innerTableView)

    return tCell
end

--[[
    @des    :创建内部tableView
    @param  :奖励条目
    @return :创建好的tableView
--]]
function createInnerTableView(p_innerPos)
    
    local dataAfterDeal = ItemUtil.getItemsDataByStr(DB_Kuafu_challengereward.getDataById(tonumber(_TableInfo[p_innerPos])).reward)
    local tagArray = analyzeGoodsTabStr(DB_Kuafu_challengereward.getDataById(tonumber(_TableInfo[p_innerPos])).reward)
   
    local h = LuaEventHandler:create(function(fn,table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(130,130)
        elseif fn == "cellAtIndex" then
            if(tonumber(tagArray[a1+1][1]) == 6 or tonumber(tagArray[a1+1][1]) == 7)then
                _isItemTag = true
                --这个奖励是物品，在创建图标的时候与其他有所不用，_isItemTag记录当前图标是否是item
            else
                _isItemTag = false
            end
            a2 = createItemCell(dataAfterDeal[a1+1])
            r = a2
        elseif fn == "numberOfCells" then
            r = #dataAfterDeal
        else
            --print("other function")
        end
        return r
    end)

    return LuaTableView:createWithHandler(h, CCSizeMake(520,130))
end

--[[
    @des    :创建内部cell
    @param  :当前的奖励信息
    @return :创建好的cell
--]]
function createItemCell(p_dataInfo)
    local prizeViewCell = CCTableViewCell:create()
    local itemSprite
    if(_isItemTag == false)then
        --创建一个普通的图标，不带回调
        itemSprite =  ItemUtil.createGoodsIcon(p_dataInfo)
    else
        --item物品 图标需要做成带有点击回调的形式
        itemSprite = ItemSprite.getItemSpriteById(tonumber(p_dataInfo.tid), nil,itemDelegateAction, nil, -600,1000 )

        if(tonumber(p_dataInfo.num) ~= 1) then
            local numberLabel =  CCRenderLabel:create("" .. p_dataInfo.num, g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
            -- local numberLabel = CCLabelTTF:create("" .. cellValues.reward_values, g_sFontName,21)
            numberLabel:setColor(ccc3(0x00,0xff,0x18))
            numberLabel:setAnchorPoint(ccp(0,0))
            local width = itemSprite:getContentSize().width - numberLabel:getContentSize().width - 6
            numberLabel:setPosition(ccp(width,5))
            itemSprite:addChild(numberLabel)
            
            local itemData = ItemUtil.getItemById(tonumber(p_dataInfo.tid))
            iconName = itemData.name
            nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
            local descLabel = CCRenderLabel:create("" .. iconName , g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
            descLabel:setColor(nameColor)
            descLabel:setAnchorPoint(ccp(0.5,0.5))
            descLabel:setPosition(ccp(itemSprite:getContentSize().width*0.5 ,-itemSprite:getContentSize().height*0.1-2))
            itemSprite:addChild(descLabel)
        end
    end
        
    itemSprite:setAnchorPoint(ccp(0.5,0.5))
    itemSprite:setPosition(ccp(65,75))
    prizeViewCell:addChild(itemSprite)
    

    return prizeViewCell
end

function itemDelegateAction( )
    MainScene.setMainSceneViewsVisible(true, true, true)
end