-- Filename: WheelRankTableView.lua
-- Author: DJN
-- Date: 2015-03-31
-- Purpose: 积分轮盘排行榜tableView

module("WheelRankTableView", package.seeall)
require "script/ui/item/ItemUtil"
require "script/ui/rechargeActive/scoreWheel/ScoreWheelData"

-- local _ServerTag = nil
local _TableInfo = {}
local _stage = nil
--local _isItemTag = nil --用于标识一个icon是否为item类型 是item类型的图标创建方法与其他有所不同

local _RankTag   = 101  --排行榜的tag
local _RewardTag = 102  --排行奖励的tag
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
    @des   :用stage作为表格的下标的索引，设置当前显示的是“积分排行”还是“排行奖励”
    @param : stage:  2--排行奖励  1-- 积分排行
    return :
--]]
function setStage(stage)
    --print("给人家set什么stage",stage)
    _stage = tonumber(stage)
end
function setTableInfo( p_stage)
    --print("要我table哪个stage",p_stage)
    local stage = tonumber(p_stage)
    if(stage == _RankTag)then
        --print("是排行的啦")
        _TableInfo = ScoreWheelData.getRankList()
    elseif(stage == _RewardTag)then
        --print("是奖励的啦")
        _TableInfo = ScoreWheelData.getRewardList()
    end
end
--[[
    @des    :创建tableView
    @param  :_RankTag / _RewardTag
    @return :创建好的tableView
--]]
function createTableView(p_stage)
    setStage(p_stage)
    setTableInfo(p_stage)
    local h = LuaEventHandler:create(function(fn,p_table,a1,a2)
        local r
        local cellNum = table.count(_TableInfo)

        --print("cellNum",cellNum)
        if fn == "cellSize" then
            if(_stage == _RankTag)then
                r = CCSizeMake(575, 122)
            elseif(_stage == _RewardTag)then
                r = CCSizeMake(575, 210)
            end
        elseif fn == "cellAtIndex" then
            --用a1+1做下标创建cell
            a2 = createPreviewCell(a1+1)
            r = a2
        elseif fn == "numberOfCells" then
            r = cellNum
        else
            --print("other function")
        end

        return r
    end)
    local tableViewResult = LuaTableView:createWithHandler(h, CCSizeMake(575, 501))
    tableViewResult:setVerticalFillOrder(kCCTableViewFillTopDown)
    return tableViewResult
end

--[[
    @des    :创建奖励预览cell
    @param  :奖励的位置，从1开始（即a1+1的值）
    @return :创建好的cell
--]]
function createPreviewCell(p_pos)
   -- print("_stage",_stage)
    if(_stage == _RankTag)then
        return createRankCell(p_pos)
    elseif(_stage == _RewardTag)then
        return createRewardcell(p_pos)
    end
   
end
function createRankCell(p_pos)
    -- 创建cell
    local cell = CCTableViewCell:create()
    local tCellValue = ScoreWheelData.getRankList()[p_pos]
    -- 获取名字颜色、cell背景、名次背景
    local name_color,cellBg,rank_font= getHeroNameColor( tCellValue )

    -- cell背景
    cellBg:setAnchorPoint(ccp(0,0))
    cellBg:setPosition(ccp(0,0))
    --cell:setScale(g_fScaleX)
    cell:addChild(cellBg)

    -- 名次不在前三的情况
    if( rank_font == nil )then
        -- 排名
        local rank_data = tonumber(tCellValue.rank)
        rank_font = CCRenderLabel:create( rank_data, g_sFontPangWa, 50, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        rank_font:setColor(ccc3(0xff, 0xf6, 0x00))
    end
    rank_font:setAnchorPoint(ccp(0.5,0.5))
    rank_font:setPosition(ccp(53,cellBg:getContentSize().height*0.5))
    cellBg:addChild(rank_font)

    --“名”汉字
    local ming = CCSprite:create("images/match/ming.png")
    ming:setAnchorPoint(ccp(0,0))
    ming:setPosition(ccp(90,20))
    cellBg:addChild(ming)
    -- 按钮
    -- local menu = BTSensitiveMenu:create()
    -- if(menu:retainCount()>1)then
    --     menu:release()
    --     menu:autorelease()
    -- end
    -- menu:setPosition(ccp(0,0))
    -- cellBg:addChild(menu)

    local icon_bg = CCSprite:create("images/match/head_bg.png")
        icon_bg:setAnchorPoint(ccp(0,0.5))
        icon_bg:setPosition(ccp(138,cellBg:getContentSize().height*0.5))
        cellBg:addChild(icon_bg)
        local iconMenu = CCMenu:create()
        iconMenu:setTouchPriority(-555)
        iconMenu:setPosition(ccp(0,0))
        icon_bg:addChild(iconMenu)
        require "script/model/utils/HeroUtil"
        local dressId = nil
        local genderId = nil
        if( not table.isEmpty(tCellValue.dressInfo) and (tCellValue.dressInfo["1"])~= nil and tonumber(tCellValue.dressInfo["1"]) > 0 )then
            dressId = tCellValue.dressInfo["1"]
            genderId = HeroModel.getSex(tCellValue.htid)
        end

         --vip 特效
        local vip = tCellValue.vip or 0
        local heroIcon = HeroUtil.getHeroIconByHTID(tCellValue.htid, dressId, dressId,vip)
        heroIcon:setAnchorPoint(ccp(0.5,0.5))
        heroIcon:setPosition(ccp(icon_bg:getContentSize().width*0.5,icon_bg:getContentSize().height*0.5))
        icon_bg:addChild(heroIcon)
        -- lv.
        local lv_sprite = CCSprite:create("images/common/lv.png")
        lv_sprite:setAnchorPoint(ccp(0,1))
        lv_sprite:setPosition(ccp(320,cellBg:getContentSize().height-10))
        cellBg:addChild(lv_sprite)
        -- 等级
        local lvStr = tCellValue.level or " "
        local lv_data = CCRenderLabel:create( lvStr , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        lv_data:setAnchorPoint(ccp(0,1))
        lv_data:setColor(ccc3(0xff, 0xf6, 0x00))
        lv_data:setPosition(ccp(lv_sprite:getPositionX()+lv_sprite:getContentSize().width+5,cellBg:getContentSize().height-4))
        cellBg:addChild(lv_data)
        -- 名字
        local nameStr = tCellValue.name or " "
        local name = CCRenderLabel:create( nameStr , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        name:setColor(name_color)
        name:setAnchorPoint(ccp(0.5,0))
        name:setPosition(ccp(361,42))
        cellBg:addChild(name)
        -- 军团名字
        if(tCellValue.guild_name ~= nil )then
            local guildStr = tCellValue.guild_name
            local guildname = CCRenderLabel:create("("..guildStr..")" , g_sFontPangWa, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            guildname:setColor(ccc3(0xff, 0xf6, 0x00))
            guildname:setAnchorPoint(ccp(0.5,0))
            guildname:setPosition(ccp(361,10))
            cellBg:addChild(guildname)
        end

        -- 积分
        local scoreDesc = CCRenderLabel:create(GetLocalizeStringBy("djn_86"), g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        scoreDesc:setColor(ccc3(0xff, 0xf6, 0x00))
        scoreDesc:setAnchorPoint(ccp(0.5,1))
        scoreDesc:setPosition(ccp(520,cellBg:getContentSize().height-20))
        cellBg:addChild(scoreDesc)
        local scoreData = tCellValue.integeral or " "
        local scoreLabel= CCRenderLabel:create(scoreData, g_sFontPangWa, 23, 1, ccc3(0x00,0x00,0x00), type_stroke)
        scoreLabel:setAnchorPoint(ccp(0.5,0))
        scoreLabel:setColor(ccc3(0x70,0xff,0x18))
        scoreLabel:setPosition(ccp(520,23))
        cellBg:addChild(scoreLabel)
    return cell
end

function createRewardcell( p_pos)
    --print("创建奖励的cell",p_pos)
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
    local titleLabel = CCRenderLabel:create(_TableInfo[p_pos].title,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke) 
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
    innerTableView:setTouchPriority(WheelRankLayer.getTouchPriority() - 1)
    innerTableView:setDirection(kCCScrollViewDirectionHorizontal)
    innerTableView:reloadData()
    whiteBgSprite:addChild(innerTableView)

    return tCell
end
--获取 军团长名字颜色、cell背景、名次背景
function getHeroNameColor( tCellValue )
    local cellBg = nil
    local name_color = nil
    local rank_font = nil
    local rank = tCellValue.rank

    if( tonumber(rank) == 1 )then
        cellBg = CCSprite:create("images/rank/bg_1.png")
        name_color= ccc3(0xf9,0x59,0xff)
        rank_font = CCSprite:create("images/match/one.png")
    elseif( tonumber(rank) == 2 )then
        cellBg = CCSprite:create("images/rank/bg_2.png")
        name_color= ccc3(0x00,0xe4,0xff)
        rank_font = CCSprite:create("images/match/two.png")
    elseif( tonumber(rank) == 3 )then
        cellBg = CCSprite:create("images/rank/bg_3.png")
        name_color= ccc3(0x70, 0xff, 0x18)
        rank_font = CCSprite:create("images/match/three.png")
    else
        cellBg = CCSprite:create("images/rank/bg_4.png")
        name_color= ccc3(0xff,0xff,0xff)
    end

    return name_color, cellBg , rank_font
end
--[[
    @des    :创建内部tableView
    @param  :奖励条目
    @return :创建好的tableView
--]]
function createInnerTableView(p_innerPos)
   
    local dataAfterDeal = ItemUtil.getItemsDataByStr(ScoreWheelData.getRewardList()[p_innerPos].reward)

    local h = LuaEventHandler:create(function(fn,table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(130,130)
        elseif fn == "cellAtIndex" then
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
    local itemSprite = ItemUtil.createGoodsIcon(p_dataInfo, WheelRankLayer.getTouchPriority()-30
                       , WheelRankLayer.getZOrder()+10, WheelRankLayer.getTouchPriority()-40,itemDelegateAction )
        
    itemSprite:setAnchorPoint(ccp(0.5,0.5))
    itemSprite:setPosition(ccp(65,75))
    prizeViewCell:addChild(itemSprite)
    return prizeViewCell
end

function itemDelegateAction( )
    MainScene.setMainSceneViewsVisible(true, true, true)
end