-- FileName: GuildWarPromotionUtil.lua 
-- Author: bzx
-- Date: 15-1-21 
-- Purpose:  跨服军团战16进4和4进1的界面工具类

module("GuildWarPromotionUtil", package.seeall)

require "script/ui/guildWar/promotion/GuildWarPromotionController"

BtnStatus = {
    cheerDisabled   = 1, -- 助威不可点击
    cheer           = 2, -- 助威
    lookDisabled    = 3, -- 查看不可点击
    look            = 4, -- 查看
    notVisible      = 5, -- 按钮不可见
}

local _topNode 								-- 上部UI
local _addWinCountItem						-- 增加连胜
local _addWinCountTipNode 					-- 增加连胜按钮下面的提示
local _topNodeTouchPriority					-- 上部UI的按钮优先级
local _bottomNodeTouchPriority				-- 底部UI的按钮优先级

--[[
	@desc:									创建4强和冠军界面上面的UI
	@param:		number	p_touchPriority   	按钮优先级
	@return:	CCNode
--]]
function createTopNode(p_layerName, p_touchPriority)
	_topNodeTouchPriority = p_touchPriority
    _topNode = CCNode:create()
    _topNode:setContentSize(CCSizeMake(640, 256))
    
    -- test
    --_title = LordWarUtil.createTitleSprite()
    local title = GuildWarUtil.getGuildWarNameSprite()
    _topNode:addChild(title)
    title:setAnchorPoint(ccp(0.5, 0.5))
    title:setPosition(ccp(320, 224))
    
    local roundTitle = GuildWarUtil.getRoundTitle()
    _topNode:addChild(roundTitle)
    roundTitle:setAnchorPoint(ccp(0.5, 0.5))
    roundTitle:setPosition(ccp(320, 180))
    
    local timeTitleNode = GuildWarUtil.getTimeTitle()
    _topNode:addChild(timeTitleNode)
    timeTitleNode:setAnchorPoint(ccp(0.5, 0.5))
    timeTitleNode:setPosition(320, 128)
    
    local menu = CCMenu:create()
    _topNode:addChild(menu)
    menu:setAnchorPoint(ccp(0, 0))
    menu:setPosition(ccp(0, 0))
    menu:setContentSize(_topNode:getContentSize())
    menu:setTouchPriority(p_touchPriority)
    -- 说明
    local descItem = CCMenuItemImage:create("images/recharge/card_active/btn_desc/btn_desc_n.png","images/recharge/card_active/btn_desc/btn_desc_h.png")
    menu:addChild(descItem)
    descItem:setAnchorPoint(ccp(0.5, 0.5))
    descItem:setPosition(ccp(56, 199))
    descItem:registerScriptTapHandler(GuildWarPromotionController.descCallback)
    -- 返回
    local backItem = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
    menu:addChild(backItem)
    backItem:setAnchorPoint(ccp(0.5, 0.5))
    backItem:setPosition(ccp(588, 213))
    if p_layerName == "GuildWar16Layer" then
        backItem:registerScriptTapHandler(GuildWarPromotionController.back16Callback)
    else
        backItem:registerScriptTapHandler(GuildWarPromotionController.back4Callback)
    end
    --增加连胜
    _addWinCountItem = CCMenuItemImage:create("images/citybattle/addnormal.png", "images/citybattle/addselected.png")
	menu:addChild(_addWinCountItem)
    local addWinCountItemDisabled = BTGraySprite:create("images/citybattle/addnormal.png")
    _addWinCountItem:setDisabledImage(addWinCountItemDisabled)
	_addWinCountItem:setAnchorPoint(ccp(0.5, 0.5))
	_addWinCountItem:setPosition(ccp(570, 100))
	_addWinCountItem:registerScriptTapHandler(GuildWarPromotionController.addWinCountCallback)
	_addWinCountTipNode = nil
    refreshAddWinCountItem()
    -- 分割线
    local line = CCSprite:create("images/common/separator_top.png")
    line:setPosition(ccp(320, 0))
    line:setAnchorPoint(ccp(0.5, 0.5))
    _topNode:addChild(line)
    return _topNode
end

--[[
	@desc:				刷新增加连胜按钮
	@return:	nil
--]]
function refreshAddWinCountItem( ... )
    if not tolua.cast(_topNode, "CCNode") then
        return
    end
    local addCount = GuildWarMainData.getMaxWinNum()
    local costInfo = parseField(ActivityConfig.ConfigCache.guildwar.data[1].WinCost, 1)
    print("addCount====", addCount)
    print_t(costInfo)
    local maxAddCount = #costInfo
    local richInfo = {}
    richInfo.defaultType = "CCRenderLabel"
    richInfo.defaultRenderType = type_shadow
    richInfo.labelDefaultSize = 21
    richInfo.lineAlignment = 2
    if addCount >= maxAddCount then
        _addWinCountItem:setEnabled(false)
        richInfo.elements = {
            {   
                ["text"]        = GetLocalizeStringBy("key_8512"),
                ["color"]       = ccc3(0x00, 0xff, 0x18),
            }
        }
    else
        _addWinCountItem:setEnabled(true)
        richInfo.elements = {
            {
                ["type"] = "CCSprite",
                ["image"] = "images/common/gold.png"
            },
            {
                ["text"] = GuildWarPromotionData.getBuyMaxWinNumCost(),
                ["color"]= ccc3(0xff, 0xf6, 0x00)

            }
        }
    end
    if _addWinCountTipNode ~= nil then
        _addWinCountTipNode:removeFromParentAndCleanup(true)
    end
    _addWinCountTipNode = LuaCCLabel.createRichLabel(richInfo)
    _topNode:addChild(_addWinCountTipNode)
    _addWinCountTipNode:setAnchorPoint(ccp(0.5, 0.5))
    _addWinCountTipNode:setPosition(ccp(570, 30))
end

--[[
	@desc:										创建4强和冠军界面底部UI
	@param:		string		p_layerName 		创建层的名字
	@param:		number		p_touchPriority 	按钮优先级
	@return:	CCNode
--]]
function createBottomNode(p_layerName, p_touchPriority)
	_bottomNodeTouchPriority = p_touchPriority
	local bottomNode = CCNode:create()
    bottomNode:setContentSize(CCSizeMake(640, 95))
    local line = CCSprite:create("images/common/separator_top.png")
    bottomNode:addChild(line)
    line:setScaleY(-1)
    line:setPosition(ccp(320, bottomNode:getContentSize().height))
    line:setAnchorPoint(ccp(0.5, 0.5))

    local menu = CCMenu:create()
    bottomNode:addChild(menu)
    menu:setContentSize(bottomNode:getContentSize())
    menu:setPosition(ccp(0, 0))
    menu:setTouchPriority(p_touchPriority)
    

    local itemsInfo = {
    	["items"] = {
    		{	
    			name = GetLocalizeStringBy("key_8513"),
 				callback = GuildWarPromotionController.guildResultCallback,
 			},
 			{
 				name = GetLocalizeStringBy("key_8514"),
 				callback = GuildWarPromotionController.fightInfoCallback,
 			},
 			{
 				name = GetLocalizeStringBy("key_8515"),
 				callback = GuildWarPromotionController.mySupporterCallback,
 			},
 			{
 				name = GetLocalizeStringBy("key_8516"),
 				callback = GuildWarPromotionController.reviewWarCallback
 			}
    	},
 		["GuildWar16Layer"] = {
 			itemSize = CCSizeMake(210, 73),
 			items = {
 				{
 					id = 1,
 					position = ccp(100, 48)
 				},
 				{
 					id = 2,
 					position = ccp(320, 48)
 				},
 				{
 					id = 3,
 					position = ccp(540, 48)
 				}
 			}
 		},
 		["GuildWar4Layer"] = {
 			itemSize = CCSizeMake(165, 73),
 			items = {
 				{
 					id = 1,
 					position = ccp(80, 48),
 				},
 				{
 					id = 2,
 					position = ccp(240, 48),
 				},
 				{
 					id = 3,
 					position = ccp(400, 48),
 				},
 				{
 					id = 4,
 					position = ccp(560, 48)
 				}
 			}
 		}
    }

    local curItemsInfo = itemsInfo[p_layerName]
    for i = 1, #curItemsInfo.items do
    	local itemInfo = curItemsInfo.items[i]
    	local itemBaseInfo = itemsInfo.items[itemInfo.id]
    	local item = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png", curItemsInfo.itemSize, itemBaseInfo.name, ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	    menu:addChild(item)
	    item:setAnchorPoint(ccp(0.5, 0.5))
	    item:setPosition(itemInfo.position)
	    item:registerScriptTapHandler(itemBaseInfo.callback)
	end
    return bottomNode
end

--[[
    @desc:                              得到增加连胜的提示面板
    @param:    function     p_callback  购买成功的回调
    @return:   RichAlertTip
--]]
function showAddWinCountTipAlert( p_callback )
    require "script/ui/tip/RichAlertTip"
    local richInfo = {}
    richInfo.elements = {}
    local element = {}
    element.text = GuildWarPromotionData.getBuyMaxWinNumCost()
    table.insert(richInfo.elements, element)
    element = {}
    element.type = "CCSprite"
    element.image = "images/common/gold.png"
    table.insert(richInfo.elements, element)
    element = {}
    local curMaxWinCount = GuildWarMainData.getMaxWinNum() + tonumber(ActivityConfig.ConfigCache.guildwar.data[1].defaultWin)
    element.text = curMaxWinCount
    table.insert(richInfo.elements, element)
    element = {}
    element.text = curMaxWinCount + 1
    table.insert(richInfo.elements, element)
    local newRichInfo = GetNewRichInfo("key_8517", richInfo)
    RichAlertTip.showAlert(newRichInfo, GuildWarPromotionController.addWinCountAlertCallback, true, nil, GetLocalizeStringBy("key_2864"))
end

--[[
    @desc:                                  显示晋级线条
    @param:     CCNode      p_node          线条的父节点
    @param:     table       p_lineData      线条的位置等信息
    @param:     number      p_rank          轮次
    @param:     number      p_index         指定轮次的位置
    @return:    nil
--]]
function loadLine(p_node, p_lineData, p_rank, p_index)
    local guildTrapeziumInfo = GuildWarPromotionData.getGuildTrapeziumInfo(p_rank, p_index)
    local lineIsLight = guildTrapeziumInfo ~= nil and guildTrapeziumInfo.guildStatus == GuildWarDef.kGuildWin
    local lineImage = nil  
    if lineIsLight then
        lineImage = "images/olympic/line/horizontalLine_light.png"
    else
        lineImage = "images/olympic/line/horizontalLine_gray.png"
    end
    local lineSprite = CCSprite:create(lineImage)
    p_node:addChild(lineSprite, 1)
    lineSprite:setPosition(p_lineData.position)
    lineSprite:setAnchorPoint(ccp(0.5, 0.5))
    if p_lineData.rotation ~= nil then
        lineSprite:setRotation(p_lineData.rotation)
    end
    if p_lineData.scaleX ~= nil then
        lineSprite:setScaleX(p_lineData.scaleX)
    end
    if p_lineData.scaleY ~= nil then
        lineSprite:setScaleY(p_lineData.scaleY)
    end
end

--[[
    @desc:                                  显示助威/查看按钮
    @param:     CCMenu      p_node          按钮的父节点
    @param:     table       btnPosition     按钮的位置
    @param:     number      p_rank          轮次
    @param:     number      p_index         指定轮次的位置
    @return:    nil
--]]
function loadBtn(p_menu, p_btnPosition, p_rank, p_index)
    local btnStatus = getBtnStatus(p_rank)
    local normal = nil
    local selected = nil
    local disabled = nil
    local callback = nil
    if btnStatus == BtnStatus.look then
        normal = CCSprite:create("images/olympic/checkbutton/check_btn_h.png")
        selected = CCSprite:create("images/olympic/checkbutton/check_btn_n.png")
        --disabled = BTGraySprite:create("images/olympic/checkbutton/check_btn_h.png")
        callback = GuildWarPromotionController.lookCallback
    else
        normal = CCSprite:create("images/olympic/cheer_up/cheer_n.png")
        selected = CCSprite:create("images/olympic/cheer_up/cheer_h.png")
        --disabled = BTGraySprite:create("images/olympic/cheer_up/cheer_n.png")
        callback = GuildWarPromotionController.cheerCallback
    end
    local btn = CCMenuItemSprite:create(normal, selected, disabled)
    p_menu:addChild(btn)
    btn:setTag(p_rank * 1000 + p_index)
    btn:setPosition(p_btnPosition)
    btn:setAnchorPoint(ccp(0.5, 0.5))
    btn:registerScriptTapHandler(callback)
    local remainTime = nil
    if btnStatus == BtnStatus.notVisible then
        btn:setVisible(false)
        local rankRound = GuildWarPromotionData.getRoundByRank(p_rank * 2)
        local curTime = TimeUtil.getSvrTimeByOffset()
        local roundEndTime = GuildWarMainData.getEndTime(rankRound)
        remainTime = roundEndTime - curTime
    elseif btnStatus == BtnStatus.cheer then
        local curTime = TimeUtil.getSvrTimeByOffset()
        local supportEndTime = GuildWarSupportData.getSupportEndTime(p_rank)
        remainTime = supportEndTime - curTime
    end
    if remainTime ~= nil then
        local actions = CCArray:create()
        remainTime = remainTime < 0 and 0 or remainTime
        actions:addObject(CCDelayTime:create(remainTime))
        local refreshBtn = function ( ... )
            btn:removeFromParentAndCleanup(true)
            loadBtn(p_menu, p_btnPosition, p_rank, p_index)
        end
        actions:addObject(CCCallFunc:create(refreshBtn))
        btn:runAction(CCSequence:create(actions))
    end
end

--[[
    @desc:                      获取按钮状态
    @param:     number  p_rank  轮次
    @return:    number          按钮状态
--]]
function getBtnStatus(p_rank)
    local btnStatus = nil
    local rankRound = GuildWarPromotionData.getRoundByRank(p_rank)
    local curRound = GuildWarMainData.getRound()
    local curStatus = GuildWarMainData.getStatus()
    local curTime = TimeUtil.getSvrTimeByOffset()
    print("getBtnStatus=====", p_rank, rankRound, curRound, curStatus, curTime)
    local supportEndTime = GuildWarSupportData.getSupportEndTime(p_rank)
    if curRound < rankRound - 1 or curRound == rankRound - 1 and curStatus < GuildWarDef.END then
        btnStatus = BtnStatus.notVisible
    elseif curRound == rankRound - 1 and curStatus == GuildWarDef.END then
        if curTime < supportEndTime then
            btnStatus = BtnStatus.cheer
        else
            btnStatus = BtnStatus.look
        end
    else
        btnStatus = BtnStatus.look
    end
    return btnStatus
    --return BtnStatus.cheer
end

--[[
    @desc:                                  显示助威/查看按钮
    @param:     CCMenu      p_node          按钮的父节点
    @param:     table       p_btnData       按钮的位置等信息
    @param:     number      p_rank          轮次
    @param:     number      p_index         指定轮次的位置
    @param:     string      p_layerName     创建层的名字
    @return:    nil
--]]
function loadGuildIcon(p_node, p_iconPosition, p_rank, p_index, p_layerName)
    local guildTrapeziumInfo = GuildWarPromotionData.getGuildTrapeziumInfo(p_rank, p_index)
    local guildSprite = GuildWarGuildPromotionSprite:createByGuildData(guildTrapeziumInfo, p_rank, p_layerName)
    p_node:addChild(guildSprite, 2)
    guildSprite:setAnchorPoint(ccp(0.5, 0.5))
    guildSprite:setPosition(p_iconPosition)
end


--[[
	@desc:					得到上部UI的按钮优先级
	@return:	number
--]]
function getTopNodeTouchPriority( ... )
	return _topNodeTouchPriority
end

--[[
	@desc:					得到底部UI的按钮优先级
	@return:	number
--]]
function getBottomNodeTouchPriority( ... )
	return _bottomNodeTouchPriority
end