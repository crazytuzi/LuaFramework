--[[
******帮派战-奖励预览*******

	-- by quanhuan
	-- 2016/2/24
	
]]

local FactionFightReward = class("FactionFightReward",BaseLayer)

function FactionFightReward:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.FactionFightReward")
end

function FactionFightReward:initUI( ui )

	self.super.initUI(self, ui)

    self.btn_close = TFDirector:getChildByPath(ui, "btn_close")

    self.img_di2 = TFDirector:getChildByPath(ui, "img_di2")

    self.cellModel = TFDirector:getChildByPath(ui, 'bg_1')
    self.cellModel:setVisible(false)
    --创建TabView
    local tabViewUI = TFDirector:getChildByPath(ui,"panel_reward")
    local tabView =  TFTableView:create()
    tabView:setTableViewSize(tabViewUI:getContentSize())
    tabView:setDirection(TFTableView.TFSCROLLVERTICAL)    
    tabView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tabView.logic = self
    tabViewUI:addChild(tabView)
    self.tabViewUI = tabViewUI
    tabView:setPosition(ccp(0,0))
    self.tabView = tabView
end


function FactionFightReward:removeUI()
	self.super.removeUI(self)
end

function FactionFightReward:onShow()
    self.super.onShow(self)
end

function FactionFightReward:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)

    self.tabView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable)
    self.tabView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    self.tabView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex)
    self.tabView:addMEListener(TFTABLEVIEW_SCROLL, self.tableScroll)
    self.tabView.logic = self
    self.tabView:reloadData()

    self.registerEventCallFlag = true 
end

function FactionFightReward:removeEvents()

    self.super.removeEvents(self)

    self.tabView:removeMEListener(TFTABLEVIEW_SIZEFORINDEX)
    self.tabView:removeMEListener(TFTABLEVIEW_SIZEATINDEX)
    self.tabView:removeMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW)
    self.tabView:removeMEListener(TFTABLEVIEW_SCROLL)

    self.registerEventCallFlag = nil  
end

function FactionFightReward:dispose()
	self.super.dispose(self)
end

function FactionFightReward.cellSizeForTable(table,idx)
    return 130,630
end

function FactionFightReward.numberOfCellsInTableView(table)
    return 5
end

function FactionFightReward.tableCellAtIndex(table, idx)

    local self = table.logic
    
    local cell = table:dequeueCell()
    local panel = nil
    if cell == nil then
        cell = TFTableViewCell:create()
        panel = self.cellModel:clone()
        panel:setPosition(ccp(0,0))
        cell:addChild(panel)
        panel:setTag(10086)
        panel:setVisible(true)
    else
        panel = cell:getChildByTag(10086)
    end
    idx = idx + 1

    local rank = {1,2,3,5,9}
    local data = ChampionsAwardData:getRewardData(3, rank[idx])
    local rewardList = data:getReward()

    local fanrongNode = TFDirector:getChildByPath(panel, 'txt_fanrong')
    local txtFanrong = TFDirector:getChildByPath(fanrongNode, 'txt2')
    txtFanrong:setText(data.boom)

    for i=1,4 do
        local imgBgNode = TFDirector:getChildByPath(panel, 'img_bg_'..i)
        imgBgNode:setVisible(false)
        local imgBgNodeSize = imgBgNode:getContentSize()

        local txtNumber = TFDirector:getChildByPath(panel, 'txt_number_'..i)
        txtNumber:setZOrder(100)

        local item = rewardList[i]
        local rewardInfo = {}
        rewardInfo.type = item.type
        rewardInfo.itemId = item.itemid
        rewardInfo.number = 1
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        local reward_item =  Public:createIconNumNode(_rewardInfo)
        reward_item:setScale(0.6)
        reward_item:setZOrder(1)
        local x = imgBgNode:getPositionX()-- - imgBgNodeSize.width/2
        local y = imgBgNode:getPositionY()-- - imgBgNodeSize.height/2
        reward_item:setPosition(ccp(x-5,y-5))        
        imgBgNode:getParent():addChild(reward_item)

        txtNumber:setText('X'..item.number)
    end

    local img_shunxu = TFDirector:getChildByPath(panel,'img_shunxu')
    img_shunxu:setTexture('ui_new/faction/fight/img_paiming'..idx..'.png')
    
    return cell
end

function FactionFightReward.tableScroll(table)
    local self = table.logic
    local currPosY = self.tabView:getContentOffset().y
    local sizeHeight = self.tabViewUI:getContentSize().height
    local initY = sizeHeight - 130*5 + 2

    -- print('initY = ',initY)
    -- print('currPosY = ',currPosY)
    if currPosY < initY then
        self.img_di2:setVisible(false)
    else
        self.img_di2:setVisible(true)
    end
end

return FactionFightReward