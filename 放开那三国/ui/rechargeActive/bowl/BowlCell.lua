-- Filename: BowlCell.lua
-- Author: DJN
-- Date: 2015-1-12
-- Purpose: 聚宝盆奖励的单元格

require "script/ui/item/ItemUtil"
require "script/ui/rechargeActive/bowl/BowlService"
require "script/model/utils/ActivityConfigUtil"
module("BowlCell", package.seeall)

local _buyTag = nil --要领取的奖励的天数索引
--创建tableCell
function create( rewardInfo ,p_index,p_needBtn)
	-- print("传进来的奖励str",rewardInfo)
	local tableCell = CCTableViewCell:create()
    --_rewardId = rewardInfo.type
	local cellBackground = CCScale9Sprite:create("images/reward/cell_back.png")
	cellBackground:setContentSize(CCSizeMake(568, 200))
	tableCell:addChild(cellBackground)

	local cellTitlePanel = CCSprite:create("images/reward/cell_title_panel.png")
	cellTitlePanel:setAnchorPoint(ccp(0, 1))
	cellTitlePanel:setPosition(ccp(0, cellBackground:getContentSize().height))
	cellBackground:addChild(cellTitlePanel)

	local nameStr = GetLocalizeStringBy("djn_134",p_index) or ""
	local title = CCRenderLabel:create(nameStr,g_sFontName,25,1, ccc3(0,0,0))
	title:setColor(ccc3(31, 196, 19))
	title:setAnchorPoint(ccp(0.5,0.5))
	title:setPosition(ccp(cellTitlePanel:getContentSize().width*0.5,cellTitlePanel:getContentSize().height*0.5))
	cellTitlePanel:addChild(title)

	-- --内容描述
	-- local content = GetLocalizeStringBy("djn_134",p_index) or ""
	-- content = CCLabelTTF:create(content, g_sFontName, 20)
	-- content:setAnchorPoint(ccp(0, 1))
	-- content:setPosition(ccp(26, 165))
	-- content:setColor(ccc3(0x78, 0x25, 0x00))
	-- cellBackground:addChild(content)

	--创建奖励物品
	local itemback = CCScale9Sprite:create("images/reward/item_back.png")
	if p_needBtn then
		itemback:setContentSize(CCSizeMake(400, 125))
	else
		itemback:setContentSize(CCSizeMake(480, 125))
	end
	itemback:setPosition(ccp(23, 14))
	cellBackground:addChild(itemback)
    
    local rewardTable = ItemUtil.getItemsDataByStr(rewardInfo)
	

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
			itemIconBg = ItemUtil.createGoodsIcon(rewardTable[a1+1],BowlLayer.getTouchPriority()-100)
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
	local tableViewSize = nil
	if p_needBtn then
		tableViewSize = CCSizeMake(390,118)
	else
		tableViewSize = CCSizeMake(477,118)
	end

	local rewardItemTable  = LuaTableView:createWithHandler(LuaEventHandler:create(rewardItemTableCallback), tableViewSize)
	itemback:addChild(rewardItemTable)
	rewardItemTable:setBounceable(true)
	rewardItemTable:setAnchorPoint(ccp(0, 0))
	rewardItemTable:setPosition(ccp(5, 0))
	rewardItemTable:setDirection(kCCScrollViewDirectionHorizontal)
	rewardItemTable:setTouchPriority(-581)
	rewardItemTable:reloadData()
	
    if(p_needBtn)then
		local menu = CCMenu:create()
		menu:setPosition(ccp(0, 0))
		menu:setAnchorPoint(ccp(0, 0))
		menu:setTouchPriority(BowlLayer.getTouchPriority()-20) 
		cellBackground:addChild(menu)
		
		-- local reciveButton = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png","images/common/btn/btn_blue_hui.png",
  --                        CCSizeMake(120,65))
		-- menu:addChild(reciveButton)				
		-- reciveButton:registerScriptTapHandler(retriveCb)
		-- reciveButton:setTag(p_index)
		-- reciveButton:setAnchorPoint(ccp(0,0.5))
		-- reciveButton:setPosition(ccp(cellBackground:getContentSize().width*0.75,cellBackground:getContentSize().height*0.5))
		-- --“领取”字
	 --    local buyLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1715"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
	 --    buyLabel:setColor(ccc3(0xff,0xe4,0x00))
	 --    buyLabel:setAnchorPoint(ccp(0.5,0.5))
	 --    buyLabel:setPosition(ccp(reciveButton:getContentSize().width *0.5,reciveButton:getContentSize().height *0.5))
	 --    reciveButton:addChild(buyLabel)
	 --    if(tonumber(BowlData.getBowlInfo().type[tostring(BowlLayer.getSelectedTag())].reward[tostring(p_index)]) ~= 1)then
	 --        reciveButton:setEnabled(false)
	 --        buyLabel:setColor(ccc3(0x7f,0x7f,0x7f))
	 --    end


		-- 领取奖励的按钮
		local normalSp = CCSprite:create("images/sign/receive/receive_n.png")
		local selectedSp = CCSprite:create("images/sign/receive/receive_h.png")
		local disabledSp = BTGraySprite:create("images/sign/receive/receive_n.png")
		local reciveButton = CCMenuItemSprite:create(normalSp,selectedSp, disabledSp)
		menu:addChild(reciveButton)				
		reciveButton:registerScriptTapHandler(retriveCb)
		reciveButton:setTag(p_index)
		reciveButton:setAnchorPoint(ccp(0,0.5))
		reciveButton:setPosition(ccp(cellBackground:getContentSize().width*0.75,cellBackground:getContentSize().height*0.5))

		local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
		receive_alreadySp:setPosition(ccp(cellBackground:getContentSize().width*0.75,cellBackground:getContentSize().height*0.5))
		receive_alreadySp:setAnchorPoint(ccp(0,0.5))
		receive_alreadySp:setVisible(false)
		cellBackground:addChild(receive_alreadySp,0,4)
	
		local status = tonumber(BowlData.getBowlInfo().type[tostring(BowlLayer.getSelectedTag())].reward[tostring(p_index)])
		if( status == 0) then 
			reciveButton:setEnabled(false)
		elseif(status == 2) then
			receive_alreadySp:setVisible(true)
			reciveButton:setVisible(false)
		end
	end
   
	return tableCell
end

function retriveCb (tag)
	-- 判断背包是否满了
    if(ItemUtil.isBagFull() == true )then
        return
    else
    	_buyTag = tag
		BowlService.reveiveReward( BowlLayer.getSelectedTag(),_buyTag,netCb)
    end
	
end
--发送完网络请求后的回调
function netCb( ... )
	require "script/ui/item/ReceiveReward"
	local rewardInfo = ActivityConfigUtil.getDataByKey("treasureBowl").data[BowlLayer.getSelectedTag()]["BowlReward"..(_buyTag)]
	rewardInfo = ItemUtil.getItemsDataByStr(rewardInfo)
	ItemUtil.addRewardByTable(rewardInfo)
	BowlData.upBowlInfo(BowlLayer.getSelectedTag(),_buyTag)
	BowlLayer.refreshMidUI()
	ReceiveReward.showRewardWindow(rewardInfo,nil,BowlLayer.getZOrder()+1,BowlLayer.getTouchPriority()-200,nil)
end





