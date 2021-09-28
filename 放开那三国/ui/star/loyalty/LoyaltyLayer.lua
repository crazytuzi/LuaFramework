-- Filename:LoyaltyLayer.lua
-- Author: djn
-- Date: 2015-06-25
-- Purpose: 聚义厅主界面
module ("LoyaltyLayer", package.seeall)

require "script/ui/star/loyalty/LoyaltyService"
require "script/ui/star/loyalty/LoyaltyData"
require "script/model/utils/HeroUtil"
require "db/DB_Affix"
require "script/ui/hero/HeroPublicLua"
require "script/ui/star/loyalty/LoyaltyControler"
require "script/libs/LuaCCLabel"
require "script/ui/star/loyalty/UnionExplainLayer"
local _touchPriority
local _ZOrder
local _bgLayer
local _bgSprite  --背景大图片
local _curtype   --当前处于缘分堂还是忠义堂
local _curPage   --当前处于第几页
local _curPos    --当前处于第几个位置
local _leftTableView --左侧tableview
local _bottomTableView --下面翻页的ableview
local _bottomNode  --下面的node

local FRIEND_TYPE = 1001
local LOYAL_TYPE = 1002
local ATTR_TYPE = 1003
local _curNetInfo --当前类型的从后端获取的已经镶嵌的信息
local _curDBInfo  --当前类型的DB 表中的信息
local _closeCb    --关闭后的回调
local _rightNode  --右侧大node
local _leftNode   --左侧大node
local _cardPosX = {0.32,0.68,0.18,0.5,0.82}
local _cardPosY = {0.57,0.57,0.2,0.2,0.2}
local PAGECARD = 5 --每一页武将数量
local _cardMenu   --卡牌的menu
local _curLeftMenuItem --当前左侧被选中的menuItem
local _curBottomMenuItem --当前下面被选中的menuItem
local _bottomStr  --底部介绍那句话
local _leftTitle  --左标题

local  _leftArrow --左箭头
local _rightArrow --右箭头
local ALERTLEVEL = 101
local ALERTHERO = 102
local ALERTTREA = 103
local ALERTGOD = 104
local HEROTYPE = 1
local TREATYPE = 2
local GODTYPE = 3
--初始化
function init( ... )
    _touchPriority = nil
    _ZOrder = nil
    _bgLayer = nil
    _bgSprite = nil
    _curtype = 1001
    _curNetInfo = {}
    _curDBInfo = {}
    _closeCb = nil
    _rightNode = nil
    _leftNode = nil
    _curPage = nil
    _leftTableView = nil
    _bottomTableView = nil
    _curPos = nil
    _cardMenu = nil
    _curLeftMenuItem = nil
    _bottomNode = nil
    _curBottomMenuItem = nil
    _bottomStr = nil
    _leftTitle = nil
    _leftArrow = nil
    _rightArrow = nil
end
----------------------------------------触摸事件函数
function onTouchesHandler(eventType,x,y)
    if eventType == "began" then
       -- print("onTouchesHandler,began")
        return true
    elseif eventType == "moved" then
       --print("onTouchesHandler,moved")
    else
       -- print("onTouchesHandler,else")
    end
end
--活动说明回调

function explainCallFunc( ... )
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    require "script/ui/star/loyalty/LoyaltyIntroduce"
    LoyaltyIntroduce.showLayer(_touchPriority-20)
end
--点击左侧cell的回调
function leftCellCallback(p_tag,p_menuItem)
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    --print("左侧 p_tag",p_tag)
    if tolua.cast(_curLeftMenuItem, "CCMenuItemSprite") ~= nil then
        _curLeftMenuItem:setEnabled(true)
    end
 
    p_menuItem:setEnabled(false)

    _curLeftMenuItem = p_menuItem
    _curPos = p_tag
    refreshRightNode()
end
--羁绊详细信息弹板
function unionExplainAction(p_tag,p_menuItem)
    UnionExplainLayer.showLayer(p_tag,_touchPriority-30,_ZOrder + 10)
end
--点击下面的翻页按钮回调
function bottomBtnCb(p_tag,p_menuItem)
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    --print("下面 p_tag",p_tag)
    if tolua.cast(_curBottomMenuItem, "CCMenuItemSprite") ~= nil then
        _curBottomMenuItem:setEnabled(true)
    end
 
    p_menuItem:setEnabled(false)

    _curBottomMenuItem = p_menuItem

    _curPage = p_tag
    _curPos = 1
    refreshUI(true)
    -- body
end
--点击顶端选项卡的回调
function topBtnCb(p_tag)
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local typeList = {FRIEND_TYPE,ATTR_TYPE,LOYAL_TYPE}
    if(LoyaltyData.isLvLimitByType(typeList[p_tag]) == false)then
        AlertTip.showAlert(GetLocalizeStringBy("djn_238",LoyaltyData.getOpenLvByType(typeList[p_tag])))
        return
    end
    --print("上面 p_tag",p_tag)
    if(p_tag == 1)then
        _curtype = FRIEND_TYPE
    elseif(p_tag == 3)then
        _curtype = LOYAL_TYPE
    elseif(p_tag == 2)then
        _curtype = ATTR_TYPE
    end
    _curPage = 1
    _curPos = 1
    refreshUI(false)
    -- body
end
--关闭回调
function fnCloseBtnHandler( ... )
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if(_bgLayer)then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end
    if(_closeCb)then
        _closeCb()
    end
end

--[[
    @des    :事件注册函数
    @param  :事件
    @return :
--]]
function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
        --_bgLayer:setTouchEnabled(true)

    elseif eventType == "exit" then
        _bgLayer:unregisterScriptTouchHandler()

    end
end
-----------------------------------和controler交互数据 ----------------------
--获取当前三个标签 具体是啥 请看声明处 如果分成三个函数写实在是。。。。眼花缭乱
function getCurInfo( ... )
    return _curtype,_curPage,_curPos
end
--设置当前三个标签
function setCurInfo(p_type,p_page,p_pos)

     _curtype = tonumber(p_type) 
     _curPage = tonumber(p_page) 
     _curPos = tonumber(p_pos)
end

-----------------------------------和controler交互数据结束 -------------------
--创建左侧的tableview
function createLeftTableView( ... )
    local tableView_hight = _leftNode:getContentSize().height-85
    local tableView_width = _leftNode:getContentSize().width - 10
     
    -- 显示单元格背景的size
    local lineNum = LoyaltyData.getCellNumByType(_curtype)
    if(lineNum == 0)then
        --除数为零是SB
        lineNum = 8
    end
    local cellHeight = tableView_hight/lineNum
    local cell_bg_size = { width = tableView_width, height = cellHeight } 
    --print("LoyaltyData.getCellNumByType(_curtype)",LoyaltyData.getCellNumByType(_curtype))
    local handler = LuaEventHandler:create(function(fn, p_table, a1, a2)
        local r
        local cellNum = LoyaltyData.getCellNumByIndex(_curtype,_curPage)       
        if (fn == "cellSize") then
            r = CCSizeMake(cell_bg_size.width , cell_bg_size.height)
        elseif (fn == "cellAtIndex") then
            a2 = createLeftCell(a1+1,cell_bg_size.height)
            r=a2
        elseif (fn == "numberOfCells") then
            r =  cellNum
        elseif (fn == "cellTouched") then
        elseif (fn == "scroll") then
        else
        end
        return r
    end)

    _leftTableView = LuaTableView:createWithHandler(handler, CCSizeMake(tableView_width,tableView_hight))
    _leftTableView:ignoreAnchorPointForPosition(false)
    _leftTableView:setAnchorPoint(ccp(0, 1))
    _leftTableView:setPosition(ccp(5,_leftNode:getContentSize().height-70))
    _leftNode:addChild(_leftTableView)
    _leftTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _leftTableView:setTouchEnabled(false)
    
end
--创建一个左侧cell
function createLeftCell(p_index ,p_height)
    local cellSize = CCSizeMake(_leftNode:getContentSize().width - 10, p_height * 0.8)
    local cell = CCTableViewCell:create()
    cell:setContentSize(cellSize)
    local menu = BTSensitiveMenu:create()
    cell:addChild(menu)
    menu:setContentSize(cellSize)
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(_touchPriority - 1)

    local menuItemSize = CCSizeMake(160, p_height * 0.8)
    local normal = CCScale9Sprite:create("images/star/friend/btn_n.png")
    normal:setPreferredSize(menuItemSize)

    local selected = CCScale9Sprite:create("images/star/friend/btn_h.png")
    selected:setPreferredSize(menuItemSize)

    local disabled = CCScale9Sprite:create("images/star/friend/btn_h.png")
    disabled:setPreferredSize(menuItemSize)

    local cellItem = CCMenuItemSprite:create(normal, selected, disabled)
    menu:addChild(cellItem)
    cellItem:setAnchorPoint(ccp(0.5, 0))
    cellItem:setPosition(ccpsprite(0.5, 0, menu))
    cellItem:setTag(p_index)
    cellItem:registerScriptTapHandler(leftCellCallback)

    local DBInfo = LoyaltyData.getDBInfoByIndex(_curtype,_curPage,p_index)
    local haveNum = #LoyaltyData.getPutHeroByIndex(_curtype,_curPage,p_index) or 0
    local needNum = DBInfo.set_item
    needNum = LoyaltyData.analysisDbStr(needNum)
    needNum = #needNum

    local desStr = CCRenderLabel:create(DBInfo.name.."("..haveNum.."/"..needNum..")",g_sFontName,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    local strColor = nil
    if(haveNum >= needNum)then
        --镶嵌满了
        strColor = ccc3(0x00,0xe4,0xff)
    else
        strColor = ccc3(0xff,0xff,0xff)
    end 
    desStr:setColor(strColor)
    desStr:setAnchorPoint(ccp(0.5,0.5))
    desStr:setPosition(ccpsprite(0.5,0.5,cellItem))
    cellItem:addChild(desStr)

    --判断有没有加号提醒
    if(LoyaltyData.ifHaveRescourceByIndex(_curtype,_curPage,p_index))then
        local plusSp = CCSprite:create("images/pill/plus.png")
        plusSp:setScale(0.4)
        plusSp:setAnchorPoint(ccp(1,0))
        plusSp:setPosition(ccpsprite(1,0,cellItem))
        cellItem:addChild(plusSp)
    end
    if(p_index == _curPos)then
        cellItem:setEnabled(false)
        _curLeftMenuItem = cellItem
    end

    return cell
end
--刷新右侧五张卡
function refreshRightNode()
    if(_rightNode ~= nil)then
        _rightNode:removeFromParentAndCleanup(true)
        _rightNode = nil
    end
    local p_curtype = _curtype
    local p_curPage = _curPage
    local p_curPos = _curPos
    _rightNode = CCScale9Sprite:create("images/common/bg/9s_1.png")
    _rightNode:setContentSize(CCSizeMake(430,g_winSize.height * 0.56/g_fScaleX))
    _rightNode:setAnchorPoint(ccp(1,0))
    _rightNode:setPosition(ccpsprite(0.975,0.15,_bgSprite))
    _rightNode:setOpacity(150)
    _bgSprite:addChild(_rightNode)

    _cardMenu = CCMenu:create()
    _cardMenu:setTouchPriority(_touchPriority - 1)
    _cardMenu:setAnchorPoint(ccp(0,0))
    _cardMenu:setContentSize(_rightNode:getContentSize())
    _cardMenu:setPosition(ccp(0,0))
    _rightNode:addChild(_cardMenu,2)
    local infoInDB = LoyaltyData.getDBInfoByIndex( p_curtype,p_curPage,p_curPos)
    local infoHave = LoyaltyData.getPutHeroByIndex(p_curtype,p_curPage,p_curPos)
    -- print("infoInDB")
    -- print_t(infoInDB)

      --local DBInfo = LoyaltyData.getDBInfoByIndex(_curtype,_curPage,p_index)
    local haveNum = #infoHave or 0
    local needNum = infoInDB.set_item
    needNum = LoyaltyData.analysisDbStr(needNum)
    needNum = #needNum

    -- local nameStr = CCRenderLabel:create(infoInDB.name.."("..haveNum.."/"..needNum..")",g_sFontPangWa,24,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    -- nameStr:setColor(ccc3(0xfe,0xdb,0x1c))
    -- nameStr:setAnchorPoint(ccp(0.5,1))
    -- nameStr:setPosition(ccpsprite(0.5,0.98,_rightNode))
    -- _rightNode:addChild(nameStr)
    --描述说明
    local richInfo = {elements = {},alignment = 2,defaultType = "CCRenderLabel",}
      
        richInfo.elements[1] = {
                text = infoInDB.name.."("..haveNum.."/"..needNum..")",
                font = g_sFontPangWa,
                size = 24,
                color = ccc3(0xfe,0xdb,0x1c)}

    --判断是否达到镶可镶嵌的等级
        if(tonumber(infoInDB.level) > UserModel.getHeroLevel() )then
                --显示**级开启
            richInfo.elements[2] = { 
                text = "("..infoInDB.level..GetLocalizeStringBy("key_1526")..")",
                font = g_sFontPangWa,
                size = 24,
                color = ccc3(0xff,0x00,0x00)}
        end
    local midSp = LuaCCLabel.createRichLabel(richInfo)
    midSp:setAnchorPoint(ccp(0.5,1))
    midSp:setPosition(ccpsprite(0.5,0.98,_rightNode))
    _rightNode:addChild(midSp)

    if(infoInDB.des ~= nil)then
        local desStr = CCRenderLabel:createWithAlign(infoInDB.des,g_sFontName,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke,CCSizeMake(320,0), kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        desStr:setColor(ccc3(0xff,0xff,0xff))
        desStr:setAnchorPoint(ccp(0.5,1))
        desStr:setPosition(ccpsprite(0.5,0.9,_rightNode))
        _rightNode:addChild(desStr)
    end
    if(_curtype == ATTR_TYPE)then
        local addattr = infoInDB.attr
        addattr = LoyaltyData.analysisDbStr(addattr)
        if(not table.isEmpty(addattr))then
            local  str = CCRenderLabel:create(GetLocalizeStringBy("djn_239"),g_sFontName,18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
            str:setColor(ccc3(0xff,0xff,0xff))
            str:setAnchorPoint(ccp(0,1))
            str:setPosition(ccpsprite(0.06,0.9,_rightNode))
            _rightNode:addChild(str)

                --描述说明
               local attrRichInfo1 = {elements = {},alignment = 1,defaultType = "CCRenderLabel"}
               local attrRichInfo2 = {elements = {},alignment = 1,defaultType = "CCRenderLabel"}
               for i = 1,#addattr do
               -- for k,v in pairs(addattr) do
                    local v = addattr[i]
                    local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(v[1],v[2])
                    local line = true
                    if( i == 1 or i == 2)then
                        line = false
                    end
                    local tmp = {
                        text = affixDesc.sigleName .. "+" .. displayNum,
                        size = 18,
                        newLine = line,
                        color = ccc3(0xff,0xff,0xff)
                    }
                    if(i % 2 == 1)then
                        table.insert(attrRichInfo1.elements,tmp)
                    else
                        table.insert(attrRichInfo2.elements,tmp)
                    end
               end
                local attrSp1 = LuaCCLabel.createRichLabel(attrRichInfo1)
                attrSp1:setAnchorPoint(ccp(0,1))
                attrSp1:setPosition(ccpsprite(0.35,0.90,_rightNode))
                _rightNode:addChild(attrSp1)
                local attrSp2 = LuaCCLabel.createRichLabel(attrRichInfo2)
                attrSp2:setAnchorPoint(ccp(0,1))
                attrSp2:setPosition(ccpsprite(0.7,0.90,_rightNode))
                _rightNode:addChild(attrSp2)
            
        end


    end
    if(_curtype == FRIEND_TYPE)then
        --羁绊详情弹板按钮
        local explainButton = CCMenuItemImage:create("images/star/friend/question.png","images/star/friend/question.png")
        explainButton:setAnchorPoint(ccp(0.5, 1))
        explainButton:registerScriptTapHandler(unionExplainAction)
        explainButton:setPosition(ccpsprite(0.85,0.96,_cardMenu))
        explainButton:setScale(1.1)
        local unionId = infoInDB.union_id
        unionId = string.split(unionId,",")
        _cardMenu:addChild(explainButton,1,unionId[1])
    end

    if(table.isEmpty(infoInDB))then
        return
    end

    for i = 1,PAGECARD do 
        local cardSprite = nil
        local heroNeed = LoyaltyData.getCardInfoByIndex( _curtype,_curPage,_curPos,i)
        local cardAddFlag = false
        if(table.isEmpty(heroNeed) )then
            --这个位置表里也没配英雄 放空牌
            cardSprite = CCSprite:create("images/star/friend/back_card.png")
        else
            --判断是否达到镶可镶嵌的等级
            if(tonumber(infoInDB.level) > UserModel.getHeroLevel() )then
            --还没有到达镶嵌的等级，一张灰卡
                cardSprite = createCard(heroNeed,_curtype,false,true,i,ALERTLEVEL)
                cardAddFlag = true
            else
                --判断是否已经镶嵌
                --local cardInfo = LoyaltyData.getCardInfoByIndex(_curtype,_curPage,_curPos,i)
                if(LoyaltyData.getIfFillByIndex(_curtype,_curPage,_curPos,i)) then
                    --已经镶嵌了 英雄形象亮起来~
                    
                    cardSprite = createCard(heroNeed,_curtype,true)
                    --cardSprite:setOpacity(100)
                else
                    --判断是否拥有 
                    if(not table.isEmpty(LoyaltyData.getFitHeroByTid(heroNeed[1],heroNeed[2])))then
                        --print("检测到有一个可镶嵌")
                        cardSprite = createCard(heroNeed,_curtype,false,false,i)
                        --拥有这种英雄未镶嵌 带加号
                    else
                        --没拥有这种英雄 灰着吧
                        local needType = tonumber(heroNeed[1])
                        local alertType = nil
                        if(needType == HEROTYPE)then
                            alertType = ALERTHERO
                        elseif(needType == TREATYPE)then
                            alertType = ALERTTREA
                        elseif(needType == GODTYPE)then
                            alertType = ALERTGOD
                        end
                        cardSprite = createCard(heroNeed,_curtype,false,true,i,alertType)
                        cardAddFlag = true
                    end
                end
            end
            
            
        end
        if(cardSprite and not cardAddFlag)then
            cardSprite:setAnchorPoint(ccp(0.5,0.5))
            cardSprite:setPosition(ccpsprite(_cardPosX[i],_cardPosY[i],_rightNode))
            _rightNode:addChild(cardSprite)
        end
    end

end
--创建一张卡
--p_cardInfo 卡牌信息
--p_type 聚义厅还是忠义堂
--p_light 是否点亮卡牌
--p_show 是否有飘窗提示 （因为这个需求是后加的 之前灰卡牌并不是按钮 所以也就没有回调 后来新加了灰卡牌点击的提示 已经不适合与可镶嵌的卡牌
--                    公用一个callback了 所以分开写了）
--p_tag --对于可镶嵌的卡牌 记录卡牌位置

function createCard(p_cardInfo,p_type,p_light,p_showAlert,p_tag,p_alertTag)
    local retCard = nil
    if(table.isEmpty(p_cardInfo))then
        retCard = CCSprite:create("images/star/friend/back_card.png")
        retCard:setOpacity(100)
        return retCard
    end
    local cardName = " "
    local quality = 3
    local affixStr = " "
    local curType = tonumber(p_type)
    local cardSprite = nil
    local affixName = {}
    if(tonumber(p_cardInfo[1]) == 1)then
        --武将
        local heroInfo = HeroUtil.getHeroLocalInfoByHtid(p_cardInfo[2])
        if(not table.isEmpty(heroInfo))then
            cardName = heroInfo.name 
            quality = heroInfo.potential
            cardSprite = HeroUtil.getHeroIconByHTID(p_cardInfo[2])
            if(curType == FRIEND_TYPE)then
                affixName = heroInfo.hero_affix1
            elseif(curType == LOYAL_TYPE)then
                affixName = heroInfo.hero_affix2
            elseif(curType == ATTR_TYPE)then
                affixName = heroInfo.hero_affix1
            end
            affixName = LoyaltyData.analysisDbStr(affixName)         
        end
 
    elseif(tonumber(p_cardInfo[1]) == 2)then
        --宝物
        cardSprite = ItemSprite.getItemSpriteByItemId(p_cardInfo[2])
        local DBInfo = ItemUtil.getItemById(p_cardInfo[2])
        if(DBInfo)then
            --print("宝物的")
            quality = DBInfo.quality
            cardName = DBInfo.name
            affixName = DBInfo.affix_union
            affixName = LoyaltyData.analysisDbStr(affixName) 
            --print("宝物的信息",quality)       
        end        
    elseif(tonumber(p_cardInfo[1]) == 3)then
        --神兵
        cardSprite = ItemSprite.getItemSpriteByItemId(p_cardInfo[2])
        local DBInfo = ItemUtil.getItemById(p_cardInfo[2])
        if(DBInfo)then
            quality = 6--DBInfo.godarmrank
            cardName = DBInfo.name
            affixName = DBInfo.affix_union
            affixName = LoyaltyData.analysisDbStr(affixName)  

        end
    end
    if(not table.isEmpty(affixName))then
        local affixDBName = DB_Affix.getDataById(affixName[1][1]) or ""
        if(affixDBName)then
            affixDBName = affixDBName.sigleName
        end
        -- print("affixDBName",affixDBName)
        -- print("affixName")
        -- print_t(affixName)
        affixStr = affixDBName.."+"..affixName[1][2]
    end

    if(quality == 1)then
        quality = 2
    end
    --print("card quality",quality)
    retCard = CCSprite:create("images/star/friend/"..quality.."_bg.png")
    --头像
    cardSprite:setAnchorPoint(ccp(0.5,0.5))
    cardSprite:setPosition(ccpsprite(0.5,0.5,retCard))
    retCard:addChild(cardSprite)
    --名字
    local nameLabel = CCLabelTTF:create(cardName,g_sFontName,18)
    --nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(quality))
    nameLabel:setColor(ccc3(0xff,0xff,0xff))
    nameLabel:setAnchorPoint(ccp(0.5,0))
    nameLabel:setPosition(ccpsprite(0.5,0.85,retCard))
    retCard:addChild(nameLabel)
    --属性
    local affixLabel = CCLabelTTF:create(affixStr,g_sFontName,18)
    affixLabel:setColor(ccc3(0xff,0xf6,0x00))
    affixLabel:setAnchorPoint(ccp(0.5,0))
    affixLabel:setPosition(ccpsprite(0.5,0.08,retCard))
    retCard:addChild(affixLabel)
   
    if(p_light == false)then
        --置灰 带加号按钮
       retCard = BTGraySprite:createWithNodeAndItChild(retCard)
    end 
    if(p_showAlert)then
        local normalSp = retCard
        local lightSp = retCard
        local cardMenuItem = CCMenuItemSprite:create(normalSp,lightSp)
        cardMenuItem:setAnchorPoint(ccp(0.5,0.5))
        _cardMenu:addChild(cardMenuItem,1,p_alertTag)
        cardMenuItem:setPosition(ccp(_rightNode:getContentSize().width *_cardPosX[p_tag],
        _rightNode:getContentSize().height *_cardPosY[p_tag]))
        cardMenuItem:registerScriptTapHandler(LoyaltyControler.alertCb)
        return cardMenuItem
    end
   if(p_tag ~= nil)then
    --之前的逻辑是如果p_tag存在 必然要创建一个带加号的卡牌  但是需求改过后 灰色卡牌也可能会传p_tag 所以上面return cardMenuItem 拦截了不带加号卡牌的p_tag
    --print("创建一个加号按钮")
    --带加号按钮
       local plusMenuItem = CCMenuItemImage:create("images/pill/plus.png","images/pill/plus.png")
       LoyaltyControler.addActionToSprite(plusMenuItem)
       plusMenuItem:setAnchorPoint(ccp(0.5,0.5))
       _cardMenu:addChild(plusMenuItem,1,p_tag)
       plusMenuItem:setPosition(ccp(_rightNode:getContentSize().width *_cardPosX[p_tag],
        _rightNode:getContentSize().height *_cardPosY[p_tag]))
        plusMenuItem:registerScriptTapHandler(LoyaltyControler.cardCb)
    end
  
    return retCard
    -- body
end
-- --刷新底下那句话
-- function refreshBottomStr( ... )
--     if(_bottomStr == nil)then
--         _bottomStr = CCLabelTTF:create("",g_sFontName,18)
--         _bottomStr:setColor(ccc3(0xf5,0xda,0xab))
--         _bottomStr:setAnchorPoint(ccp(0.5,0))
--         _bottomStr:setPosition(ccpsprite(0.5,0.15,_bgSprite))
--         _bgSprite:addChild(_bottomStr)
--     end
--     local targetStr = " "
--     if(_curtype == LOYAL_TYPE)then
--         targetStr =  " "
--     elseif(_curtype == FRIEND_TYPE)then
--         local DBInfo = LoyaltyData.getDBInfoByIndex( _curtype,_curPage,_curPos)
--         if(DBInfo)then
--             targetStr  = DBInfo.des1
--         end
--     end
--     _bottomStr:setString(targetStr)
-- end

--刷新下面的翻页tableview
function createBottomTableView( ... )
    if(_bottomTableView ~= nil)then
        _bottomTableView:removeFromParentAndCleanup(true)
        _bottomTableView = nil
    end
    local pageNum = LoyaltyData.getPageNumByType(_curtype)

    local tableView_hight = 50
    local tableView_width = g_winSize.width * 0.625/g_fScaleX
     
    -- 显示单元格背景的size
    local cell_bg_size = { width = 70, height = 50 } 
    --print("LoyaltyData.getCellNumByType(_curtype)",LoyaltyData.getCellNumByType(_curtype))
    local handler = LuaEventHandler:create(function(fn, p_table, a1, a2)
        local r
        local cellNum = LoyaltyData.getPageNumByType(_curtype)
       -- print("createBottomTableView cellNum",cellNum)
        if (fn == "cellSize") then
            r = CCSizeMake(cell_bg_size.width , cell_bg_size.height)
        elseif (fn == "cellAtIndex") then
            a2 = createBottomCell(a1+1)
            r=a2
        elseif (fn == "numberOfCells") then
            r =  cellNum
        elseif (fn == "cellTouched") then
        elseif (fn == "scroll") then
        else
        end
        return r
    end)

    _bottomTableView = LuaTableView:createWithHandler(handler, CCSizeMake(tableView_width,tableView_hight))
    _bottomTableView:ignoreAnchorPointForPosition(false)
    _bottomTableView:setAnchorPoint(ccp(0.5, 0))
    _bottomTableView:setPosition(ccpsprite(0.5,0,_bottomNode))
    _bottomNode:addChild(_bottomTableView)
    _bottomTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _bottomTableView:setTouchPriority(_touchPriority - 2)
    _bottomTableView:setDirection(kCCScrollViewDirectionHorizontal)
    _bottomTableView:reloadData()
   -- _bottomTableView:setTouchEnabled(false)


    -- body
end
--创建一个下面的cell
function createBottomCell(p_index)
   -- print("createBottomCell,p_index",p_index)
    local cellSize = CCSizeMake(50, 50)
    local cell = CCTableViewCell:create()
    cell:setContentSize(cellSize)
    local menu = BTSensitiveMenu:create()
    cell:addChild(menu)
    menu:setContentSize(cellSize)
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(_touchPriority - 1)
    local normal = nil
    local selected = nil
    local disabled = nil
    if(_curtype == FRIEND_TYPE)then
        normal = CCSprite:create("images/star/friend/circle_n.png")
        selected = CCSprite:create("images/star/friend/circle_h.png")
        disabled = CCSprite:create("images/star/friend/circle_h.png")
    elseif(_curtype == LOYAL_TYPE)then
        normal = CCSprite:create("images/star/friend/circle2_n.png")
        selected = CCSprite:create("images/star/friend/circle2_h.png")
        disabled = CCSprite:create("images/star/friend/circle2_h.png")
    elseif(_curtype == ATTR_TYPE)then
        normal = CCSprite:create("images/star/friend/circle3_n.png")
        selected = CCSprite:create("images/star/friend/circle3_h.png")
        disabled = CCSprite:create("images/star/friend/circle3_h.png")
    
    end

   
    local cellItem = CCMenuItemSprite:create(normal, selected, disabled)
    menu:addChild(cellItem)
    cellItem:setAnchorPoint(ccp(0.5, 0.5))
    cellItem:setPosition(ccpsprite(0.5, 0.5, menu))
    cellItem:setTag(p_index)
    cellItem:setScale(1.2)
    cellItem:registerScriptTapHandler(bottomBtnCb)
    local numLabel = CCRenderLabel:create(p_index,g_sFontPangWa,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    numLabel:setColor(ccc3( 0xff, 0xff, 0xff))
    numLabel:setAnchorPoint(ccp(0.5,0.5))
    numLabel:setPosition(ccpsprite(0.5,0.5,cellItem))
    cellItem:addChild(numLabel)

    if(p_index == _curPage)then
        cellItem:setEnabled(false)
        _curBottomMenuItem = cellItem
    end
    return cell
end
--创建顶端标题和关闭按钮
function createTitleLayer( ... )

    local tLabel={
        text=GetLocalizeStringBy("djn_192"),
        fontsize=35,
        font = g_sFontPangWa,
        sourceColor=ccc3(0xff, 0xf0, 0x49),
        targetColor=ccc3(0xff, 0xa2, 0),
        tag=_ksTagCloseBtn,
        stroke_size=1,
        stroke_color=ccc3(0, 0, 0),
        anchorPoint=ccp(0.5, 0.4)
    }
    local csTitleBg = LuaCCSprite.createSpriteWithRenderLabel("images/common/title_bg.png", tLabel)
    local ccMenu = CCMenu:create()
    local cmiButtonClose = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    local tBgSize = csTitleBg:getContentSize()
    local tBtnSize = cmiButtonClose:getContentSize()
    cmiButtonClose:setAnchorPoint(ccp(1, 1))
    cmiButtonClose:setPosition(tBgSize.width+8, tBgSize.height+8)
    cmiButtonClose:registerScriptTapHandler(fnCloseBtnHandler)
    ccMenu:setPosition(0, 0)

    ccMenu:setTouchPriority(_touchPriority-7 or -777)
    ccMenu:addChild(cmiButtonClose)

    csTitleBg:addChild(ccMenu)

    return csTitleBg
end
--创建背景UI
function createBgUI( ... )
    require "script/ui/main/MenuLayer"  
    local menuLayerHeight = MenuLayer.getHeight()
    local bgHeiht = g_winSize.height - menuLayerHeight 

    -- 背景九宫格图
    -- local bgfullRect = CCRectMake(0, 0, 196, 198)
    -- local bginsetRect = CCRectMake(61, 80, 46, 36)
    -- local ccStarSellBG = CCScale9Sprite:create("images/hero/bg_ng.png", bgfullRect, bginsetRect)

    -- ccStarSellBG:setPreferredSize(CCSizeMake(645, bgHeiht/g_fScaleX))
    -- ccStarSellBG:ignoreAnchorPointForPosition(false)
    -- ccStarSellBG:setAnchorPoint(ccp(0.5,0))
    -- ccStarSellBG:setPosition(ccp(g_winSize.width * 0.5, menuLayerSize))
    -- ccStarSellBG:setScale(g_fScaleX)
    -- _bgLayer:addChild(ccStarSellBG)

 

    local fullRect = CCRectMake(0,0,640,405)
    local insetRect = CCRectMake(300,190,13,6)
    --创建大背景
    _bgSprite = CCScale9Sprite:create("images/star/friend/big_bg.png",fullRect, insetRect)
    _bgSprite:setContentSize(CCSizeMake(640,(bgHeiht)/g_fScaleX - 50))
    _bgSprite:setAnchorPoint(ccp(0.5,0))
    _bgSprite:setScale(g_fScaleX)
    _bgSprite:setPosition(ccp(g_winSize.width * 0.5,menuLayerHeight))
    _bgLayer:addChild(_bgSprite)

    -- 标题和关闭按钮那里
    local ccTitleLayer = createTitleLayer()
    ccTitleLayer:setAnchorPoint(ccp(0.5,1))
    ccTitleLayer:setPosition(ccp(g_winSize.width * 0.5,g_winSize.height))
    ccTitleLayer:setScale(g_fScaleX)
    _bgLayer:addChild(ccTitleLayer,2)

    --创建左侧node一枚 
    _leftNode = CCScale9Sprite:create("images/common/bg/9s_1.png")
    _leftNode:setContentSize(CCSizeMake(180,g_winSize.height * 0.56/g_fScaleX))
    _leftNode:setAnchorPoint(ccp(0,0))
    _leftNode:setPosition(ccpsprite(0.007,0.15,_bgSprite))
    _leftNode:setOpacity(150)
    _bgSprite:addChild(_leftNode)

    --创建下面的UI
    _bottomNode = CCNode:create()
    _bottomNode:setContentSize(CCSizeMake(640,50))
    _bottomNode:setAnchorPoint(ccp(0.5,0))
    _bottomNode:setPosition(ccpsprite(0.5,0.05,_bgSprite))
    _bgSprite:addChild(_bottomNode)

    local resourceList = {}
    if(LoyaltyData.isLvLimitByType(FRIEND_TYPE))then
        resourceList[1] = {normal = "images/star/friend/friend_n.png", selected = "images/star/friend/friend_h.png"}
    else
        resourceList[1] = {normal = "images/star/friend/gray_friend.png", selected = "images/star/friend/gray_friend.png"}
    end
    if(LoyaltyData.isLvLimitByType(ATTR_TYPE))then
        resourceList[2] =  {normal ="images/star/friend/attr_n.png", selected = "images/star/friend/attr_h.png"}
    else
        resourceList[2] = {normal = "images/star/friend/gray_attr.png", selected = "images/star/friend/gray_attr.png"}
    end
      if(LoyaltyData.isLvLimitByType(LOYAL_TYPE))then
        resourceList[3] = {normal = "images/star/friend/loyal_n.png", selected = "images/star/friend/loyal_h.png"}
    else
        resourceList[3] = {normal = "images/star/friend/gray_loyal.png", selected = "images/star/friend/gray_loyal.png"}
    end
    --创建顶端选项卡
    local selected_answer_index = nil
    local radio_data = {
        touch_priority  = _touchPriority - 1,
        space           = 80,
        callback        = topBtnCb,
        -- items           ={
        --     {normal = "images/star/friend/friend_n.png", selected = "images/star/friend/friend_h.png"},
        --     {normal = "images/star/friend/attr_n.png", selected = "images/star/friend/attr_h.png"},
        --     {normal = "images/star/friend/loyal_n.png", selected = "images/star/friend/loyal_h.png"},
            
        -- }
        items = resourceList
    }
    local radio_menu = LuaCCSprite.createRadioMenu(radio_data)
    _bgSprite:addChild(radio_menu)
    radio_menu:setAnchorPoint(ccp(0.5, 0.5))
    radio_menu:setPosition(ccpsprite(0.5,0.91,_bgSprite))

    local menu = CCMenu:create()
    menu:setTouchPriority(_touchPriority - 1)
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    menu:setContentSize(_bgSprite:getContentSize())
    _bgSprite:addChild(menu,2)
    --活动说明
    local explainButton = CCMenuItemImage:create("images/star/friend/note.png","images/star/friend/note.png")
    explainButton:setAnchorPoint(ccp(1, 0.5))
    explainButton:registerScriptTapHandler(explainCallFunc)
    explainButton:setPosition(ccpsprite(0.9,0.91,menu))
    explainButton:setScale(1.1)
    menu:addChild(explainButton)
    
    
    --左侧node两边的小发
    local leftFlo = CCSprite:create("images/star/friend/huabianzuo.png")
    leftFlo:setAnchorPoint(ccp(0,1))
    leftFlo:setPosition(ccpsprite(0,1,_leftNode))
    _leftNode:addChild(leftFlo)
    --右边小发
    local rightFlo = CCSprite:create("images/star/friend/huabianzupi.png")
    rightFlo:setAnchorPoint(ccp(1,1))
    rightFlo:setPosition(ccpsprite(1,1,_leftNode))
    _leftNode:addChild(rightFlo)
 

end
--刷新左侧标题
function refreshleftTitle( ... )
    if(_leftTitle == nil)then
        _leftTitle = CCSprite:create("images/star/friend/friend_title.png")
        _leftTitle:setAnchorPoint(ccp(0.5,1))
        --print("_leftNode",_leftNode)
        _leftTitle:setPosition(ccpsprite(0.5,0.985,_leftNode))
        _leftNode:addChild(_leftTitle)
    end
    local targetStr = nil
    if(_curtype == LOYAL_TYPE)then
        targetStr =  CCSpriteFrame:create("images/star/friend/loyal_title.png",CCRect(0, 0, 147, 72))
    elseif(_curtype == FRIEND_TYPE)then
        targetStr =  CCSpriteFrame:create("images/star/friend/friend_title.png",CCRect(0, 0, 146, 73))
    elseif(_curtype == ATTR_TYPE)then
        targetStr =  CCSpriteFrame:create("images/star/friend/attr_title.png",CCRect(0, 0, 146, 73))
    end
    _leftTitle:setDisplayFrame(targetStr)
end
--刷新下面UI
function refreshBottomUI( ... )
    --下面UI两边的小发
    local leftPath = nil
    if(_curtype == FRIEND_TYPE)then
        leftPath = CCSpriteFrame:create("images/star/friend/left.png",CCRect(0, 0, 36, 45))
    elseif(_curtype == LOYAL_TYPE)then
        leftPath = CCSpriteFrame:create("images/star/friend/left2.png",CCRect(0, 0, 36, 45))
    elseif(_curtype == ATTR_TYPE)then
        leftPath = CCSpriteFrame:create("images/star/friend/left3.png",CCRect(0, 0, 36, 45))
    end
    if(_leftArrow == nil)then
        -- _leftArrow = CCSprite:create("images/star/friend/left.png")
        _leftArrow = CCSprite:create()
        _leftArrow:setAnchorPoint(ccp(1,0.5))
        _leftArrow:setPosition(ccp(100,25))
        _bottomNode:addChild(_leftArrow)
    end
    _leftArrow:setDisplayFrame(leftPath)

    local rightPath = nil
    if(_curtype == FRIEND_TYPE)then
        rightPath = CCSpriteFrame:create("images/star/friend/right.png",CCRect(0, 0, 36, 45))
    elseif(_curtype == LOYAL_TYPE)then
        rightPath = CCSpriteFrame:create("images/star/friend/right2.png",CCRect(0, 0, 36, 45))
    elseif(_curtype == ATTR_TYPE)then
        rightPath = CCSpriteFrame:create("images/star/friend/right3.png",CCRect(0, 0, 36, 45))
    end
    if(_rightArrow == nil)then
        _rightArrow = CCSprite:create("images/star/friend/right.png")
        _rightArrow:setAnchorPoint(ccp(0,0.5))
        _rightArrow:setPosition(ccp(540,25))
        _bottomNode:addChild(_rightArrow)
    end
    _rightArrow:setDisplayFrame(rightPath)
end
--UI创始人老总
function createUI( ... )
    createBgUI()
    --创建左侧tableView
    createLeftTableView()
    --创建右侧node一枚 
    refreshRightNode()
    --创建下面的tableview
    createBottomTableView()
    --refreshBottomStr()
    refreshleftTitle()
    refreshBottomUI()
end
--UI刷新的创始人
function refreshUI(p_setBottomOffset )
    if(_leftTableView ~= nil)then
        _leftTableView:reloadData()
    end
    if(_bottomTableView ~= nil)then
        if(p_setBottomOffset)then
            local bottomOffset = _bottomTableView:getContentOffset()
            _bottomTableView:reloadData()
            _bottomTableView:setContentOffset(bottomOffset)
        else
            _bottomTableView:reloadData()
        end
    end
    refreshRightNode()
    --refreshBottomStr()
    refreshleftTitle()
    refreshBottomUI()
end
----------------------------------------入口函数----------------------------------------
function createLayer(p_closeCb,p_touch,p_zOr)   
    init()

    MainScene.setMainSceneViewsVisible(true, false, false) 
    _closeCb = p_closeCb 
    if(_closeCb == nil)then
        _closeCb = function ( ... )
            require "script/ui/star/StarLayer"
            local starLayer = StarLayer.createLayer()
            MainScene.changeLayer(starLayer, "starLayer")
        end
    end
    _touchPriority = p_touch or -699
    _ZOrder = p_zOr or 999

    _curtype = FRIEND_TYPE
    _curPage = 1
    _curPos = 1
    LoyaltyData.initData()
    LoyaltyData.setHaveEnter(true)
   -- LoyaltyData.setIfRedIcon(false)
    _bgLayer = CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)

    createUI()
    return _bgLayer
end

