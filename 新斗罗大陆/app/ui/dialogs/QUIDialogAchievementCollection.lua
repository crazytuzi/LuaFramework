-- @Author: liaoxianbo
-- @Date:   2020-07-03 14:56:31
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-14 18:48:45
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogAchievementCollection = class("QUIDialogAchievementCollection", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetAchievementCollectionBtn = import("..widgets.QUIWidgetAchievementCollectionBtn")
local QUIWidgetAchievementCollectionCell = import("..widgets.QUIWidgetAchievementCollectionCell")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogAchievementCollection:ctor(options)
	local ccbFile = "ccb/Dialog_Achievement_collection.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggershare", 	callback = handler(self, self._onTriggershare)},
		{ccbCallbackName = "onTriggerShouji",	callback = handler(self,self._onTriggerShouji)},
    }

    QUIDialogAchievementCollection.super.ctor(self, ccbFile, callBacks, options)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end
    if page.setBackBtnVisible then page:setBackBtnVisible(true) end
    if page.setHomeBtnVisible then page:setHomeBtnVisible(true) end    

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local nodeScale = CalculateUIBgSize(self._ccbOwner.sp_bg)
	self._ccbOwner.node_puzzle:setScale(nodeScale)

	q.setButtonEnableShadow(self._ccbOwner.btn_share)
	self._shoujiHide = false
	self._getAwardsFlag = false
    self._curSelectBtnIndex = 1
    self._allAchieveCollections = remote.achievementCollege:getAllAchieveCollections()

	self._ccbOwner.sp_layout_bg:setContentSize(CCSize(238, display.height - 60))
	self._ccbOwner.sp_layout_b:setContentSize(CCSize(345, display.height - 60))
	self._ccbOwner.sheet_menu:setContentSize(CCSize(230,display.height - 70))
	self._ccbOwner.sheet_menu:setPositionY(-(display.height - 70))
    self:initBtnListView()
end

function QUIDialogAchievementCollection:viewDidAppear()
	QUIDialogAchievementCollection.super.viewDidAppear(self)
	self:addBackEvent(true)
    self._achievementCollegeProxy = cc.EventProxy.new(remote.achievementCollege)
    self._achievementCollegeProxy:addEventListener(remote.achievementCollege.UPDATE_COLLEGE_STATE, handler(self, self.showAcievementCollectionCell))	
end

function QUIDialogAchievementCollection:viewWillDisappear()
  	QUIDialogAchievementCollection.super.viewWillDisappear(self)
  	self:removeBackEvent()

    if self._achievementCollegeProxy ~= nil then 
        self._achievementCollegeProxy:removeAllEventListeners()
        self._achievementCollegeProxy = nil
    end

end

function QUIDialogAchievementCollection:initBtnListView(  )
    -- body
    if not self._btnListView then
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = self._allAchieveCollections[index]
	            if not item then
	                item = QUIWidgetAchievementCollectionBtn.new()
	                isCacheNode = false
	            end
	            item:setInfo(data,self)
	            info.item = item
	            info.size = item:getContentSize()

	            list:registerBtnHandler(index, "btn_click", handler(self, self.onClickBtnItem))
	            if self._curSelectBtnIndex == index then
	            	self._curSelectBtnIndex = index
	                item:setSelect(true)
	                self._chooseInfo = data
	                self:showAcievementCollectionCell()
	            else
	                item:setSelect(false)
	            end
	            return isCacheNode
	        end,
	        headIndex = self._curSelectBtnIndex,
	        enableShadow = false,
	        ignoreCanDrag = false,
	        spaceY = 4,
	        totalNumber = #self._allAchieveCollections,
	    }  
	    self._btnListView = QListView.new(self._ccbOwner.sheet_menu,cfg)
	else   
		self._btnListView:reload({totalNumber = #self._allAchieveCollections})
	end
end

function QUIDialogAchievementCollection:onClickBtnItem( x, y, touchNode, listView )
    app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)

    if self._curSelectBtnIndex and self._curSelectBtnIndex ~= touchIndex then
        local oldItem = listView:getItemByIndex(self._curSelectBtnIndex)
        if oldItem then
            oldItem:setSelect(false)
        end
    end

    if self._curSelectBtnIndex ~= touchIndex then
        self._curSelectBtnIndex = touchIndex
    end

    if item then
        item:setSelect(true)
        self._chooseInfo = item:getInfo()
        self:showAcievementCollectionCell()
    end

end

function QUIDialogAchievementCollection:showAcievementCollectionCell()
	if q.isEmpty(self._chooseInfo) then return end
	self._awardsRecived = remote.achievementCollege:checkAchievementIsGetAwards(self._chooseInfo.id)
	self._haveFinsh,self._finshNum = remote.achievementCollege:checkAchievementIsFinash(self._chooseInfo.id)

	self._allCellCollections = remote.achievementCollege:analyzeColletionCondition(self._chooseInfo.conditions)

	self:updateProgress()
	self:updateBackground()
	self:initCellListView()
	self:updateAwards()
	self:checkAwardList()
end

function QUIDialogAchievementCollection:updateProgress( )
	local nodes = {}
	self._ccbOwner.node_progress:removeAllChildren()

    local xiePath = "ui/update_soultower/zi_slt_s_xie.png"
    local zi_xie = CCSprite:create(xiePath)
    zi_xie:setAnchorPoint(ccp(0.0, 0.5))
    self._ccbOwner.node_progress:addChild(zi_xie)

    local createNum = function(processNum)
	    local strLen = string.len(processNum)
	    for i = 1, strLen, 1 do
	        local num = tonumber(string.sub(processNum, i, i))
	        if num == 0 then num = 10 end
	        local paths = QResPath("soul_tower_small_num")
	        local spNum = CCSprite:create(paths[num])
	        spNum:setAnchorPoint(ccp(0.0, 0.5))
	        self._ccbOwner.node_progress:addChild(spNum)
		    table.insert(nodes,spNum)
	    end	
    end
    if self._haveFinsh then
    	createNum(self._chooseInfo.num)
    else
    	createNum(self._finshNum or 0)
    end
    table.insert(nodes,zi_xie)

    createNum(self._chooseInfo.num)

    q.autoLayerNode(nodes,"x",-5) 	

end

function QUIDialogAchievementCollection:updateBackground()
	-- app:cleanTextureCache()
	if self._chooseInfo and self._chooseInfo.icon then
		QSetDisplaySpriteByPath(self._ccbOwner.sp_bg,self._chooseInfo.icon)
	end

	self._ccbOwner.node_puzzle:removeAllChildren()
	for _,conditionInfo in pairs(self._allCellCollections) do
	    if not remote.achievementCollege:checkMyCellCondtionState(conditionInfo.id) then
		    local puzzlePath = conditionInfo.icon
		    local spPuzzle = CCSprite:create(puzzlePath)
		    spPuzzle:setPositionX(conditionInfo.posx)
		    spPuzzle:setPositionY(conditionInfo.posy)
		    self._ccbOwner.node_puzzle:addChild(spPuzzle)
	    end		
	end

end

function QUIDialogAchievementCollection:initCellListView()
	if self._cellListView then
		self._cellListView:clear()
	end
	
    -- body
    if not self._cellListView then
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = self._allCellCollections[index]
	            if not item then
	                item = QUIWidgetAchievementCollectionCell.new()
	                isCacheNode = false
	            end
	            item:setInfo(data,self)
	            info.item = item
	            info.size = item:getContentSize()
	            return isCacheNode
	        end,
	        enableShadow = false,
	        ignoreCanDrag = false,
	        spaceY = 1,
	        totalNumber = #self._allCellCollections,
	    }  
	    self._cellListView = QListView.new(self._ccbOwner.sheet_cell,cfg)
	else   
		self._cellListView:reload({totalNumber = #self._allCellCollections})
	end
end

function QUIDialogAchievementCollection:updateAwards( )
	if self._awardsListview then
		self._awardsListview:clear()
	end

	self._awardsData = remote.achievementCollege:analyzeColletionAwards(self._chooseInfo.awards)

	if not self._awardsListview then
		local function showItemInfo(x, y, itemBox, listView)
			app.tip:itemTip(itemBox._itemType, itemBox._itemID)
		end
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._awardsData[index]
	            local item = list:getItemFromCache()
	            if not item then
	            	item = QUIWidgetQlistviewItem.new()
	            	isCacheNode = false
	            end
	            self:setItemInfo(item,itemData,index)

	            info.item = item
	            info.size = item._ccbOwner.parentNode:getContentSize()

	            list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)
	            return isCacheNode
	        end,
	        enableShadow = false,
	        isVertical = false,
	        totalNumber = #self._awardsData,
	        autoCenter = true,
		}
		self._awardsListview = QListView.new(self._ccbOwner.sheet_award,cfg)
	else
		self._awardsListview:reload({totalNumber = #self._awardsData})
	end	
end

function QUIDialogAchievementCollection:setItemInfo( item, data ,index)
	if not item._itemBox then
		item._itemBox = QUIWidgetItemsBox.new()
		item._itemBox:setScale(0.7)
		item._itemBox:setPosition(ccp(35, 35))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(70, 70))

	end
	item._itemBox:setGoodsInfo(data.id,data.typeName,data.count)
	item._itemBox:showIsGetAwards(self._awardsRecived)
end

function QUIDialogAchievementCollection:checkAwardList( )
	makeNodeFromGrayToNormal(self._ccbOwner.node_btn_share)
	self._ccbOwner.btn_share:setEnabled(true)
	self._ccbOwner.node_btn_effect:setVisible(false)
	self._ccbOwner.node_btn_share:setVisible(true)
	if not self._awardsRecived then
		self._getAwardsFlag = true
		self._ccbOwner.tf_share:setString("领 取")
		if not self._haveFinsh then
			self._ccbOwner.btn_share:setEnabled(false)
			makeNodeFromNormalToGray(self._ccbOwner.node_btn_share)
		end
		self._ccbOwner.node_btn_effect:setVisible(self._haveFinsh)
    else
    	if remote.shareSDK:checkIsOpen() then
	    	self._getAwardsFlag = false
	    	self._ccbOwner.tf_share:setString("分 享")
	    else
	    	self._ccbOwner.node_btn_share:setVisible(false)
	    end
	end
end

function QUIDialogAchievementCollection:_onTriggershare( )
	if self._getAwardsFlag then
        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
        options = {awards = self._awardsData,callBack = function()
            remote.achievementCollege:getCollectRewardRequest(self._chooseInfo.id)
        end}},{isPopCurrentDialog = false} )
        dialog:setTitle("恭喜你获得成就收集奖励")			
	else
		if remote.shareSDK:checkIsOpen() then 
		    local shareInfo = remote.shareSDK:getShareConfigById(self._chooseInfo.id,remote.shareSDK.COLLECT)
		    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogShareSDK", 
		        options = {shareInfo = shareInfo}}, {isPopCurrentDialog = false}) 
		else
			app.tip:floatTip("敬请期待")
		end  
	end
end

function QUIDialogAchievementCollection:_onTriggerShouji()
	if self._moveAction then return end
	self._shoujiHide = not self._shoujiHide
	self._moveAction = true
	local arrleft = CCArray:create()
	if self._shoujiHide then	
		arrleft:addObject(CCMoveBy:create(0.2, ccp(255,0)))	
		arrleft:addObject(CCCallFunc:create(function () 
    		if self:safeCheck() then
    			self._moveAction = false
    			self._ccbOwner.node_content:setVisible(false)
    			self._ccbOwner.sp_jiantou:setScaleX(-1)
			end
        end))
	else
		self._ccbOwner.node_content:setVisible(true)
		arrleft:addObject(CCMoveBy:create(0.2, ccp(-255,0)))	
		arrleft:addObject(CCCallFunc:create(function () 
    		if self:safeCheck() then
				self._moveAction = false
				self._ccbOwner.sp_jiantou:setScaleX(1)
			end
        end))
	end

	self._ccbOwner.node_right:stopAllActions()
	self._ccbOwner.node_right:runAction(CCSequence:create(arrleft))

end

function QUIDialogAchievementCollection:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogAchievementCollection
