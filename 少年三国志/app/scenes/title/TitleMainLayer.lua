-- TitleMainLayer

--------------------- NOTICE ---------------------------
-- comp 		争霸赛称号
-- rank  		排名称号
-- score 		积分称号

-- UI 布局文件中名称有点对不上
-- comp1 争霸赛
-- score 排名称号
-- competition 积分称号
--------------------- NOTICE ---------------------------

require ("app.cfg.item_info")
require ("app.cfg.title_info")

local TitleItemCell = require ("app.scenes.title.TitleItemCell")


local TitleMainLayer = class("TitleMainLayer", UFCCSNormalLayer)

function TitleMainLayer.create(itemValue, scenePack, ... )
	-- __Log("create")
	return TitleMainLayer.new("ui_layout/title_main_layer.json", itemValue, scenePack, ...)
end

function TitleMainLayer:ctor(json, itemValue, scenePack, ... )
	self.super.ctor(self, ...)	

	G_GlobalFunc.savePack(self, scenePack)

	self._itemValue = itemValue
	-- for i=1,100 do
	-- 	__Log("===============my title id============= %d", G_Me.userData:getTitleId())
	-- 	G_HandlersManager.titleHandler:sendUpdateFightValue()
	-- end
	-- 跨服PvP称号所在面板
	self._crosspvpPanel = self:getPanelByName("Panel_6")
	-- 积分称号所在面板
	self._scorePanel = self:getPanelByName("Panel_2")
	-- 排名称号所在面板
	self._rankPanel = self:getPanelByName("Panel_3")
	-- 争霸赛称号所在面板
	self._compPanel = self:getPanelByName("Panel_4")
	-- 活动称号所在面板
	self._activityPanel = self:getPanelByName("Panel_5")

	-- 外面的总面板
	self._outsidePanel = self:getPanelByName("Panel_1")

	self._crosspvpTitlesPanel = self:getPanelByName("Panel_Titles_CrossPVP")
	self._scoreTitlesPanel = self:getPanelByName("Panel_Titles")
	self._rankTitlesPanel = self:getPanelByName("Panel_Titles_0")
	self._compTitlesPanel = self:getPanelByName("Panel_Titles_1")
	self._activityTitlesPanel = self:getPanelByName("Panel_Titles_Activity")

	self._scrollView = self:getScrollViewByName("ScrollView_7")
	-- 初始尺寸默认为最大可滑动尺寸
	self._maxInnerContainerHeight = self._scrollView:getInnerContainerSize().height

	-- 4个称号区块顶端bar
	self._crosspvpBar = self:getImageViewByName("Image_CrossPVP_Bar")
	self._scoreBar = self:getImageViewByName("Image_Comp_Bar")
	self._rankBar = self:getImageViewByName("Image_Score_Bar")
	self._compBar = self:getImageViewByName("Image_Comp_1_Bar")
	self._activityBar = self:getImageViewByName("Image_Activity_Bar")

	self._isCrosspvpPanelShow = true
	self._isCompPanelShow = true
	self._isScorePanelShow = true
	self._isRankPanelShow = true
	self._isActivityPanelShow = true

	-- 展开收起动画时间
	self._animDuration = 0.3
	-- 展开收起动画移动范围
	self._animCrosspvpMoveY = 23
	self._animRankMoveY = 23
	self._animScoreMoveY = 23
	self._animCompMoveY = 23
	self._animActivityMoveY = 23

	-- 第一个称号在面板中的位置
	self._crosspvpTitleStartX = 300
	self._crosspvpTitleStartY = -50

	self._rankTitleStartX = 300
	self._rankTitleStartY = -50

	self._scoreTitleStartX = 300
	self._scoreTitleStartY = -50

	self._compTitleStartX = 300
	self._compTitleStartY = -50

	self._activityTitleStartX = 300
	self._activityTitleStartY = -50	

	-- 称号之间的间距
	self._titleOffsetX = 300
	self._titleOffsetY = 160

	self:_initTitleInfoList()

	self:_initChildren()
	self:_updateTitleStatus()
	
	-- 刷新已激活称号的倒计时
	self._timerHandler = G_GlobalFunc.addTimer(1, function()
        if self and self._refreshActiveTitleLeftTime then
	       self:_refreshActiveTitleLeftTime()
        end        
	end)

end

function TitleMainLayer:onLayerEnter(  )
	-- __Log("TitleMainLayer:onLayerEnter")
	-- 争霸赛称号收起展开按钮
	self:registerBtnClickEvent("Button_CrossPVP_Hide", function ()
		self:_crosspvpTitlesArrowBtnClicked()
	end)
	self:registerBtnClickEvent("Button_Comp_Hide", function ()
		self:_scoreTitlesArrowBtnClicked()
	end)
	self:registerBtnClickEvent("Button_Score_Hide", function ( ... )
		self:_rankTitlesArrowBtnClicked()
	end)
	self:registerBtnClickEvent("Button_Comp_1_Hide", function ()
		self:_compTitlesArrowBtnClicked()
	end)
	self:registerBtnClickEvent("Button_Activity_Hide", function ()
		self:_activityTitlesArrowBtnClicked()
	end)

	self:registerBtnClickEvent("Button_CrossPVP_Show", function ()
		self:_crosspvpTitlesArrowBtnClicked()
	end)
	self:registerBtnClickEvent("Button_Comp_Show", function ()
		self:_scoreTitlesArrowBtnClicked()
	end)
	self:registerBtnClickEvent("Button_Score_Show", function ( ... )
		self:_rankTitlesArrowBtnClicked()
	end)
	self:registerBtnClickEvent("Button_Comp_1_Show", function ()
		self:_compTitlesArrowBtnClicked()
	end)
	self:registerBtnClickEvent("Button_Activity_Show", function ()
		self:_activityTitlesArrowBtnClicked()
	end)



	-- 跨服PvP
	self:registerWidgetClickEvent("Image_CrossPVP_Bar", function ( ... )
		self:_crosspvpTitlesArrowBtnClicked()
	end)

	-- 争霸赛
	self:registerWidgetClickEvent("Image_Comp_1_Bar", function ( ... )
		self:_compTitlesArrowBtnClicked()
	end)

	-- 积分赛排名
	self:registerWidgetClickEvent("Image_Comp_Bar", function ( ... )
		self:_scoreTitlesArrowBtnClicked()
	end)

	-- 积分赛
	self:registerWidgetClickEvent("Image_Score_Bar", function ( ... )
		self:_rankTitlesArrowBtnClicked()
	end)

	-- 活动称号
	self:registerWidgetClickEvent("Image_Activity_Bar", function ( ... )
		self:_activityTitlesArrowBtnClicked()
	end)	

	-- back button
	self:registerBtnClickEvent("Button_Back", function ()
		self:_onBackButton()
	end)

	-- 注册事件
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CHANGE_TITLE, self._titleChanged, self) 
	uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_USE_ITEM, self._titleItemUsed, self)	

	-- 进来默认收起
	self:_hideCrosspvpTitlesPanelWithoutAnim()
	self:_hideCompTitlesPanelWithoutAnim()
	self:_hideScoreTitlesPanelWithoutAnim()
	self:_hideRankTitlesPanelWithoutAnim()
	self:_hideActivityTitlesPanelWithoutAnim()

	self:callAfterFrameCount(5, function ( ... )
		-- 如果从包裹道具列表进来的，则判断是否展开某个称号面板
		if self._itemValue ~= nil and self._itemValue ~= 0 then
			local titleInfo = title_info.get(self._itemValue)
			if titleInfo.type1 == 5 then
				self:_crosspvpTitlesArrowBtnClicked()
			elseif titleInfo.type1 == 4 then
				self:_activityTitlesArrowBtnClicked()
			elseif titleInfo.type1 == 3 then
				self:_compTitlesArrowBtnClicked()
			elseif titleInfo.type1 == 2 then
				self:_scoreTitlesArrowBtnClicked()
			elseif titleInfo.type1 == 1 then
				self:_rankTitlesArrowBtnClicked()
			end
		else
			-- 默认展开第一个
			self:_crosspvpTitlesArrowBtnClicked()
		end

	end)
end

-- 根据包裹中是否有称号激活道具判断可激活的称号
function TitleMainLayer:_initActivatableTitleList( ... )
	self._activatableTitleList = {}

	local propList = G_Me.bagData.propList:getList()
	for i, v in pairs(propList) do
		local item = item_info.get(v.id)
		if item.item_type == 24 then
			local titleInfo = title_info.get(item.item_value)
			table.insert(self._activatableTitleList, titleInfo)
		end
	end
end

-- 初始化已经处于激活状态的称号
function TitleMainLayer:_initActiveTitleList( ... )
	self._activeTitleList = {}
	-- 增加称号过期的判断
	for i, v in pairs(G_Me.userData.title_list) do 
		local time = G_ServerTime:getLeftSeconds(v.time)
		if time > 0 then
			table.insert(self._activeTitleList, v)
		end
	end 
end

function TitleMainLayer:getActivatableTitleList( ... )
	self:_initActivatableTitleList()
	return self._activatableTitleList
end

-- 获取各类型的称号信息
function TitleMainLayer:_initTitleInfoList( ... )
	self._crosspvpTitleInfoList = {}
	self._rankTitleInfoList = {}
	self._scoreTitleInfoList = {}
	self._compTitleInfoList = {}
	self._activityTitleInfoList = {}

	for i = 1, title_info.getLength() do 
		local titleInfo = title_info.indexOf(i)
		if titleInfo.type1 == 1 then
			table.insert(self._rankTitleInfoList, titleInfo)
		elseif titleInfo.type1 == 2 then
			table.insert(self._scoreTitleInfoList, titleInfo)
		elseif titleInfo.type1 == 3 then
			table.insert(self._compTitleInfoList, titleInfo)
		elseif titleInfo.type1 == 4 then
			table.insert(self._activityTitleInfoList, titleInfo)
		elseif titleInfo.type1 == 5 then
			table.insert(self._crosspvpTitleInfoList, titleInfo)
		end
	end

	local sortFunc = function (a, b)
		if a.quality ~= b.quality then
			return a.quality > b.quality
		end
		return a.id < b.id
	end
	-- 蛋疼。。。
	local sortFuncCrosspvp = function (a, b)
		if a.quality ~= b.quality then
			return a.quality > b.quality
		end
		return a.id > b.id
	end	

	table.sort( self._rankTitleInfoList, sortFunc )
	table.sort( self._scoreTitleInfoList, sortFunc )
	table.sort( self._compTitleInfoList, sortFunc)
	table.sort( self._activityTitleInfoList, sortFunc)
	table.sort( self._crosspvpTitleInfoList, sortFuncCrosspvp)
end

-- change layout
function TitleMainLayer:_initChildren( ... )
	-- 称号对象列表
	self._titleItemList = {}

	self:_initCrosspvpPanel()
	self:_initCompPanel()
	self:_initRankPanel()
	self:_initScorePanel()
	self:_initActivityPanel()

	self:_addChildToPanel(self._crosspvpTitleInfoList, self._crosspvpTitlesPanel, self._crosspvpTitleStartX, self._crosspvpTitleStartY)
	self:_addChildToPanel(self._compTitleInfoList, self._compTitlesPanel, self._compTitleStartX, self._compTitleStartY)
	self:_addChildToPanel(self._rankTitleInfoList, self._rankTitlesPanel, self._rankTitleStartX, self._rankTitleStartY)
	self:_addChildToPanel(self._scoreTitleInfoList, self._scoreTitlesPanel, self._scoreTitleStartX, self._scoreTitleStartY)
	self:_addChildToPanel(self._activityTitleInfoList, self._activityTitlesPanel, self._activityTitleStartX, self._activityTitleStartY)

	-- 需要最后调整可滑动区域，因为一开始什么都没有添加的时候可滑动区域是有很大部分多余的，需要减去
	self._maxInnerContainerHeight = self._maxInnerContainerHeight - 250
	local oldSize = self._scrollView:getInnerContainerSize()
	self._scrollView:setInnerContainerSize(CCSize(oldSize.width, self._maxInnerContainerHeight))

	-- 所有称号的最外层容器上移
	self._outsidePanel:setPositionY(self._outsidePanel:getPositionY() - 250)
end

function TitleMainLayer:_initCrosspvpPanel(  )
	-------------------- 跨服决战赤壁 begin --------------------------------------------------------
	self._crosspvpPanelOffsetY = 0
	self._crosspvpPanelOffsetY = self._titleOffsetY * #self._crosspvpTitleInfoList

	local oldSize = self._crosspvpTitlesPanel:getSize()
	self._crosspvpTitlesPanel:setSize(CCSizeMake(oldSize.width, oldSize.height + self._crosspvpPanelOffsetY))
	self._crosspvpTitleStartY = self._crosspvpTitleStartY + self._crosspvpPanelOffsetY

	self._crosspvpBar:setPositionY(self._crosspvpBar:getPositionY() + self._crosspvpPanelOffsetY)
	self._compPanel:setPositionY(self._compPanel:getPositionY() - self._crosspvpPanelOffsetY)

	local oldSize = self._crosspvpPanel:getSize()
	self._crosspvpPanel:setSize(CCSizeMake(oldSize.width, oldSize.height + self._crosspvpPanelOffsetY))
	self._crosspvpPanel:setPositionY(self._crosspvpPanel:getPositionY() - self._crosspvpPanelOffsetY)

	self._animCrosspvpMoveY = self._animCrosspvpMoveY + self._crosspvpPanelOffsetY

	-- 可滑动区域也要改变
	self._maxInnerContainerHeight = self._maxInnerContainerHeight + self._crosspvpPanelOffsetY
	local oldSize = self._scrollView:getInnerContainerSize()
	self._scrollView:setInnerContainerSize(CCSize(oldSize.width, self._maxInnerContainerHeight))

	-- 所有称号的最外层容器上移
	self._outsidePanel:setPositionY(self._outsidePanel:getPositionY() + self._crosspvpPanelOffsetY)
	-------------------- 跨服决战赤壁 end --------------------------------------------------------
end


function TitleMainLayer:_initCompPanel(  )
	-------------------- 争霸赛 begin --------------------------------------------------------
	self._compPanelOffsetY = 0
	self._compPanelOffsetY = self._titleOffsetY * #self._compTitleInfoList

	local oldSize = self._compTitlesPanel:getSize()
	self._compTitlesPanel:setSize(CCSizeMake(oldSize.width, oldSize.height + self._compPanelOffsetY))
	self._compTitleStartY = self._compTitleStartY + self._compPanelOffsetY

	self._compBar:setPositionY(self._compBar:getPositionY() + self._compPanelOffsetY)
	self._rankPanel:setPositionY(self._rankPanel:getPositionY() - self._crosspvpPanelOffsetY - self._compPanelOffsetY)

	local oldSize = self._compPanel:getSize()
	self._compPanel:setSize(CCSizeMake(oldSize.width, oldSize.height + self._compPanelOffsetY))
	self._compPanel:setPositionY(self._compPanel:getPositionY() - self._compPanelOffsetY)

	self._animCompMoveY = self._animCompMoveY + self._compPanelOffsetY

	-- 可滑动区域也要改变
	self._maxInnerContainerHeight = self._maxInnerContainerHeight + self._compPanelOffsetY
	local oldSize = self._scrollView:getInnerContainerSize()
	self._scrollView:setInnerContainerSize(CCSize(oldSize.width, self._maxInnerContainerHeight))

	-- 所有称号的最外层容器上移
	self._outsidePanel:setPositionY(self._outsidePanel:getPositionY() + self._compPanelOffsetY)
	-------------------- 争霸赛 end --------------------------------------------------------
end

function TitleMainLayer:_initRankPanel(  )
	-------------------- 排名称号 begin --------------------------------------------------------
	-- 默认每种称号有3个，如果多出则动态增加父控件大小
	self._rankPanelOffsetY = 0
	self._rankPanelOffsetY = self._titleOffsetY * #self._rankTitleInfoList
	
	local oldSize = self._rankTitlesPanel:getSize()
	-- 增加大小
	self._rankTitlesPanel:setSize(CCSizeMake(oldSize.width, oldSize.height + self._rankPanelOffsetY))
	-- 第一个称号默认的初始Y坐标也相应变化，上移
	self._rankTitleStartY = self._rankTitleStartY + self._rankPanelOffsetY
	-- 展开收起按钮栏上移
	self._rankBar:setPositionY(self._rankBar:getPositionY() + self._rankPanelOffsetY)
	-- 下面的板块也相应下移
	self._scorePanel:setPositionY(self._scorePanel:getPositionY() - self._crosspvpPanelOffsetY  - self._compPanelOffsetY - self._rankPanelOffsetY)

	-- 板块最外层容器（即包含self._rankTitlesPanel、self._rankBar的容器）大小与位置同样需要调整
	local oldSize = self._rankPanel:getSize()
	self._rankPanel:setSize(CCSizeMake(oldSize.width, oldSize.height + self._rankPanelOffsetY))
	self._rankPanel:setPositionY(self._rankPanel:getPositionY() - self._rankPanelOffsetY)

	-- 动画相应参数变化
	self._animRankMoveY = self._animRankMoveY + self._rankPanelOffsetY

	-- 可滑动区域也要改变
	self._maxInnerContainerHeight = self._maxInnerContainerHeight + self._rankPanelOffsetY
	local oldSize = self._scrollView:getInnerContainerSize()
	self._scrollView:setInnerContainerSize(CCSize(oldSize.width, self._maxInnerContainerHeight))

	-- 所有称号的最外层容器上移
	self._outsidePanel:setPositionY(self._outsidePanel:getPositionY() + self._rankPanelOffsetY)
	-------------------- 排名称号 end --------------------------------------------------------
end

function TitleMainLayer:_initScorePanel(  )
	-------------------- 积分称号 begin --------------------------------------------------------
	self._scorePanelOffsetY = 0
	self._scorePanelOffsetY = self._titleOffsetY * #self._scoreTitleInfoList
	
	local oldSize = self._scoreTitlesPanel:getSize()
	self._scoreTitlesPanel:setSize(CCSizeMake(oldSize.width, oldSize.height + self._scorePanelOffsetY))
	self._scoreTitleStartY = self._scoreTitleStartY + self._scorePanelOffsetY
	self._scoreBar:setPositionY(self._scoreBar:getPositionY() + self._scorePanelOffsetY)
	-- 下面的板块也相应下移
	self._activityPanel:setPositionY(self._activityPanel:getPositionY() - self._crosspvpPanelOffsetY - self._compPanelOffsetY - self._rankPanelOffsetY - self._scorePanelOffsetY)

	-- 板块最外层
	local oldSize = self._scorePanel:getSize()
	self._scorePanel:setSize(CCSizeMake(oldSize.width, oldSize.height + self._scorePanelOffsetY))
	self._scorePanel:setPositionY(self._scorePanel:getPositionY() - self._scorePanelOffsetY)

	self._animScoreMoveY = self._animScoreMoveY + self._scorePanelOffsetY

	-- 可滑动区域也要改变
	self._maxInnerContainerHeight = self._maxInnerContainerHeight + self._scorePanelOffsetY
	local oldSize = self._scrollView:getInnerContainerSize()
	self._scrollView:setInnerContainerSize(CCSize(oldSize.width, self._maxInnerContainerHeight))

	-- 所有称号的最外层容器上移
	self._outsidePanel:setPositionY(self._outsidePanel:getPositionY() + self._scorePanelOffsetY)
	-------------------- 积分称号 end --------------------------------------------------------
end

function TitleMainLayer:_initActivityPanel(  )
	-------------------- 活动称号 begin --------------------------------------------------------
	self._activityPanelOffsetY = 0
	self._activityPanelOffsetY = self._titleOffsetY * #self._activityTitleInfoList
	
	local oldSize = self._activityTitlesPanel:getSize()
	self._activityTitlesPanel:setSize(CCSizeMake(oldSize.width, oldSize.height + self._activityPanelOffsetY))
	self._activityTitleStartY = self._activityTitleStartY + self._activityPanelOffsetY
	self._activityBar:setPositionY(self._activityBar:getPositionY() + self._activityPanelOffsetY)

	-- 板块最外层
	local oldSize = self._activityPanel:getSize()
	self._activityPanel:setSize(CCSizeMake(oldSize.width, oldSize.height + self._activityPanelOffsetY))
	self._activityPanel:setPositionY(self._activityPanel:getPositionY() - self._activityPanelOffsetY)

	self._animActivityMoveY = self._animActivityMoveY + self._activityPanelOffsetY

	-- 可滑动区域也要改变
	self._maxInnerContainerHeight = self._maxInnerContainerHeight + self._activityPanelOffsetY
	local oldSize = self._scrollView:getInnerContainerSize()
	self._scrollView:setInnerContainerSize(CCSize(oldSize.width, self._maxInnerContainerHeight))

	-- 所有称号的最外层容器上移
	self._outsidePanel:setPositionY(self._outsidePanel:getPositionY() + self._activityPanelOffsetY)
	-------------------- 活动称号 end --------------------------------------------------------
end

function TitleMainLayer:_addChildToPanel( titleInfoList, parentPanel, startX, startY )
	for i = 1, #titleInfoList do
		local titleInfo = titleInfoList[i]
		-- 称号排名，用户佩戴是区别显示前三名的底座
		local rank = i
		-- __Log("rank = %d", rank)
		if rank > 3 then
			rank = 99
		end
		local titleItem = TitleItemCell.new(titleInfo, rank, self)

		parentPanel:addChild(titleItem)
		local posX = startX
		local posY = startY - (i-1) * self._titleOffsetY
		titleItem:setPosition(ccp(posX - titleItem:getSize().width / 2, posY - titleItem:getSize().height / 2))

		table.insert(self._titleItemList, titleItem)
		titleItem:updateStatus(self, 0)
	end
end

-- 根据变化更新称号的显示状态
function TitleMainLayer:_updateTitleStatus( ... )
	__Log("TitleMainLayer:_updateTitleStatus")
	-- 数据发生变化，列表需要重新获取
	self:_initActiveTitleList()	
	self:_initActivatableTitleList()

	-- 用于刷新已激活称号的时间等
	self._activeTitleItemList = {}

 	-- 可激活称号
	for i, v in pairs(self._activatableTitleList) do
		for j, k in pairs(self._titleItemList) do
			if k:getTitleId() == v.id then
				k:updateStatus(self, 1)
			end
		end
	end

	-- 已激活称号
	for i, v in pairs(self._activeTitleList) do

		for j, k in pairs(self._titleItemList) do
			if k:getTitleId() == v.id then
				__Log("v.time " .. v.time)
				
				if v.id == G_Me.userData.title_id then

					k:updateStatus(self, 3, v.time)
				else
					k:updateStatus(self, 2, v.time)
				end
				table.insert(self._activeTitleItemList, k)
			end
		end
	end
end

-- 为刚激活称号播放特效
function TitleMainLayer:_playActivateEffect( itemId )
	local item = item_info.get(itemId)
	if item.item_type == 24 then
		local titleInfo = title_info.get(item.item_value)
		for i, v in pairs(self._titleItemList) do
			if v:getTitleId() == titleInfo.id then
				v:playActivateEffect()
				return
			end
		end
	end
end

-- 刷新已激活称号的倒计时
function TitleMainLayer:_refreshActiveTitleLeftTime( ... )
	for i, v in pairs(self._activeTitleItemList) do 
		v:updateTime()
	end
end

-- 称号道具使用
function TitleMainLayer:_titleItemUsed( data )
	__Log("_titleItemUsed")
	-- dump(data)
	if data.ret == 1 then
		self:_updateTitleStatus()
		self:_playActivateEffect(data.id)
	end
end

-- 称号装备、卸下回调
function TitleMainLayer:_titleChanged( data )
	if data.ret == 1 then
		local titleId = rawget(data, "id")
		-- if titleId ~= 0 then
			self:_updateTitleStatus()
		-- end
	end
end

function TitleMainLayer:_crosspvpTitlesArrowBtnClicked( ... )
	if self._isCrosspvpPanelShow then
		self:_hideCrosspvpTitlesPanel()
	else
		self:_showCrosspvpTitlesPanel()
	end
end

function TitleMainLayer:_compTitlesArrowBtnClicked( ... )
	__Log("_compTitlesArrowBtnClicked")
	if self._isCompPanelShow then
		-- 收起
		self:_hideCompTitlesPanel()
	else
		-- 展开
		self:_showCompTitlesPanel()
	end
end

function TitleMainLayer:_rankTitlesArrowBtnClicked( ... )
	if self._isRankPanelShow then
		self:_hideRankTitlesPanel()
	else
		self:_showRankTitlesPanel()
	end
end

function TitleMainLayer:_scoreTitlesArrowBtnClicked( ... )
	__Log("bnt clicked")
	if self._isScorePanelShow then
		-- 收起
		self:_hideScoreTitlesPanel()
	else
		-- 展开
		self:_showScoreTitlesPanel()
	end
end

function TitleMainLayer:_activityTitlesArrowBtnClicked( ... )
	__Log("_activityTitlesArrowBtnClicked")
	if self._isActivityPanelShow then
		self:_hideActivityTitlesPanel()
	else
		self:_showActivityTitlesPanel()
	end
end

function TitleMainLayer:_showCrosspvpTitlesPanel( ... )
	self._isCrosspvpPanelShow = true

	local anim = CCSequence:createWithTwoActions(CCMoveBy:create(self._animDuration, ccp(0, -self._animCrosspvpMoveY)), CCCallFunc:create(function()
                self:_updateInnerContainerSize(true, self._animCrosspvpMoveY)
            end))

	-- 展开争霸赛称号面板
	self._crosspvpTitlesPanel:runAction(anim)

	self._compPanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, -self._animCrosspvpMoveY)))
	self._rankPanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, -self._animCrosspvpMoveY)))
	self._scorePanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, -self._animCrosspvpMoveY)))
	self._activityPanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, -self._animCrosspvpMoveY)))

	self:showWidgetByName("Button_CrossPVP_Show", false)
	self:showWidgetByName("Button_CrossPVP_Hide", true)
end

function TitleMainLayer:_hideCrosspvpTitlesPanel( ... )
	self._isCrosspvpPanelShow = false

	local anim = CCSequence:createWithTwoActions(CCMoveBy:create(self._animDuration, ccp(0, self._animCrosspvpMoveY)), CCCallFunc:create(function()
                self:_updateInnerContainerSize(false, -self._animCrosspvpMoveY)
            end))

	self._crosspvpTitlesPanel:runAction(anim)

	self._compPanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, self._animCrosspvpMoveY)))
	self._rankPanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, self._animCrosspvpMoveY)))
	self._scorePanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, self._animCrosspvpMoveY)))
	self._activityPanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, self._animCrosspvpMoveY)))

	self:showWidgetByName("Button_CrossPVP_Show", true)
	self:showWidgetByName("Button_CrossPVP_Hide", false)
end

function TitleMainLayer:_hideCrosspvpTitlesPanelWithoutAnim( ... )
	self._isCrosspvpPanelShow = false
	self._crosspvpTitlesPanel:setPositionY(self._crosspvpTitlesPanel:getPositionY() + self._animCrosspvpMoveY)

	self._compPanel:setPositionY(self._compPanel:getPositionY() + self._animCrosspvpMoveY)
	self._rankPanel:setPositionY(self._rankPanel:getPositionY() + self._animCrosspvpMoveY)
	self._scorePanel:setPositionY(self._scorePanel:getPositionY() + self._animCrosspvpMoveY)
	self._activityPanel:setPositionY(self._activityPanel:getPositionY() + self._animCrosspvpMoveY)

	self:_updateInnerContainerSize(false, -self._animCrosspvpMoveY)

	self:showWidgetByName("Button_CrossPVP_Show", true)
	self:showWidgetByName("Button_CrossPVP_Hide", false)
end

function TitleMainLayer:_showCompTitlesPanel( ... )
	self._isCompPanelShow = true

	local anim = CCSequence:createWithTwoActions(CCMoveBy:create(self._animDuration, ccp(0, -self._animCompMoveY)), CCCallFunc:create(function()
                self:_updateInnerContainerSize(true, self._animCompMoveY)
            end))

	-- 展开争霸赛称号面板
	self._compTitlesPanel:runAction(anim)

	self._rankPanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, -self._animCompMoveY)))
	self._scorePanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, -self._animCompMoveY)))
	self._activityPanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, -self._animCompMoveY)))

	self:showWidgetByName("Button_Comp_1_Show", false)
	self:showWidgetByName("Button_Comp_1_Hide", true)
end

function TitleMainLayer:_hideCompTitlesPanel( ... )
	self._isCompPanelShow = false

	local anim = CCSequence:createWithTwoActions(CCMoveBy:create(self._animDuration, ccp(0, self._animCompMoveY)), CCCallFunc:create(function()
                self:_updateInnerContainerSize(false, -self._animCompMoveY)
            end))

	self._compTitlesPanel:runAction(anim)

	self._rankPanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, self._animCompMoveY)))
	self._scorePanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, self._animCompMoveY)))
	self._activityPanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, self._animCompMoveY)))

	self:showWidgetByName("Button_Comp_1_Show", true)
	self:showWidgetByName("Button_Comp_1_Hide", false)
end

function TitleMainLayer:_hideCompTitlesPanelWithoutAnim( ... )
	self._isCompPanelShow = false
	self._compTitlesPanel:setPositionY(self._compTitlesPanel:getPositionY() + self._animCompMoveY)

	self._rankPanel:setPositionY(self._rankPanel:getPositionY() + self._animCompMoveY)
	self._scorePanel:setPositionY(self._scorePanel:getPositionY() + self._animCompMoveY)
	self._activityPanel:setPositionY(self._activityPanel:getPositionY() + self._animCompMoveY)

	self:_updateInnerContainerSize(false, -self._animCompMoveY)

	self:showWidgetByName("Button_Comp_1_Show", true)
	self:showWidgetByName("Button_Comp_1_Hide", false)
end

function TitleMainLayer:_showRankTitlesPanel( ... )
	self._isRankPanelShow = true

	local anim = CCSequence:createWithTwoActions(CCMoveBy:create(self._animDuration, ccp(0, -self._animRankMoveY)), CCCallFunc:create(function()
                self:_updateInnerContainerSize(true, self._animRankMoveY)
            end))

	-- 展开积分赛称号面板
	self._rankTitlesPanel:runAction(anim)

	self._scorePanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, -self._animRankMoveY)))
	self._activityPanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, -self._animRankMoveY)))

	self:showWidgetByName("Button_Score_Show", false)
	self:showWidgetByName("Button_Score_Hide", true)
end

function TitleMainLayer:_hideRankTitlesPanel( ... )
	self._isRankPanelShow = false

	local anim = CCSequence:createWithTwoActions(CCMoveBy:create(self._animDuration, ccp(0, self._animRankMoveY)), CCCallFunc:create(function()
                self:_updateInnerContainerSize(false, -self._animRankMoveY)
            end))

	self._rankTitlesPanel:runAction(anim)

	self._scorePanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, self._animRankMoveY)))
	self._activityPanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, self._animRankMoveY)))

	self:showWidgetByName("Button_Score_Show", true)
	self:showWidgetByName("Button_Score_Hide", false)
end

function TitleMainLayer:_hideRankTitlesPanelWithoutAnim( ... )
	self._isRankPanelShow = false
	self._rankTitlesPanel:setPositionY(self._rankTitlesPanel:getPositionY() + self._animRankMoveY)

	self._scorePanel:setPositionY(self._scorePanel:getPositionY() + self._animRankMoveY)
	self._activityPanel:setPositionY(self._activityPanel:getPositionY() + self._animRankMoveY)

	self:_updateInnerContainerSize(false, -self._animRankMoveY)

	self:showWidgetByName("Button_Score_Show", true)
	self:showWidgetByName("Button_Score_Hide", false)
end

function TitleMainLayer:_showScoreTitlesPanel( ... )
	self._isScorePanelShow = true

	local anim = CCSequence:createWithTwoActions(CCMoveBy:create(self._animDuration, ccp(0, -self._animScoreMoveY)), CCCallFunc:create(function()
                self:_updateInnerContainerSize(true, self._animScoreMoveY)
            end))

	-- 展开积分称号面板
	self._scoreTitlesPanel:runAction(anim)

	-- 下移活动称号整个区域
	self._activityPanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, -self._animScoreMoveY)))

	self:showWidgetByName("Button_Comp_Show", false)
	self:showWidgetByName("Button_Comp_Hide", true)
end

function TitleMainLayer:_hideScoreTitlesPanel( ... )
	self._isScorePanelShow = false

	local anim = CCSequence:createWithTwoActions(CCMoveBy:create(self._animDuration, ccp(0, self._animScoreMoveY)), CCCallFunc:create(function()
                self:_updateInnerContainerSize(false, -self._animScoreMoveY)
            end))

	-- 展开积分称号面板
	self._scoreTitlesPanel:runAction(anim)

	-- 下移活动称号整个区域
	self._activityPanel:runAction(CCMoveBy:create(self._animDuration, ccp(0, self._animScoreMoveY)))

	self:showWidgetByName("Button_Comp_Show", true)
	self:showWidgetByName("Button_Comp_Hide", false)
end

-- 用于直接收起
function TitleMainLayer:_hideScoreTitlesPanelWithoutAnim( ... )
	self._isScorePanelShow = false
	self._scoreTitlesPanel:setPositionY(self._scoreTitlesPanel:getPositionY() + self._animScoreMoveY)
	self:_updateInnerContainerSize(false, -self._animScoreMoveY)

	self._activityPanel:setPositionY(self._activityPanel:getPositionY() + self._animScoreMoveY)

	self:showWidgetByName("Button_Comp_Show", true)
	self:showWidgetByName("Button_Comp_Hide", false)
end

function TitleMainLayer:_showActivityTitlesPanel( ... )
	self._isActivityPanelShow = true

	local anim = CCSequence:createWithTwoActions(CCMoveBy:create(self._animDuration, ccp(0, -self._animActivityMoveY)), CCCallFunc:create(function()
                self:_updateInnerContainerSize(true, self._animActivityMoveY)
            end))

	-- 展开活动称号面板
	self._activityTitlesPanel:runAction(anim)

	self:showWidgetByName("Button_Activity_Show", false)
	self:showWidgetByName("Button_Activity_Hide", true)
end

function TitleMainLayer:_hideActivityTitlesPanel( ... )
	self._isActivityPanelShow = false

	local anim = CCSequence:createWithTwoActions(CCMoveBy:create(self._animDuration, ccp(0, self._animActivityMoveY)), CCCallFunc:create(function()
                self:_updateInnerContainerSize(false, -self._animActivityMoveY)
            end))

	-- 收起活动称号面板
	self._activityTitlesPanel:runAction(anim)

	self:showWidgetByName("Button_Activity_Show", true)
	self:showWidgetByName("Button_Activity_Hide", false)
end

-- 用于直接收起
function TitleMainLayer:_hideActivityTitlesPanelWithoutAnim( ... )
	self._isActivityPanelShow = false
	self._activityTitlesPanel:setPositionY(self._activityTitlesPanel:getPositionY() + self._animActivityMoveY)
	self:_updateInnerContainerSize(false, -self._animActivityMoveY)

	self:showWidgetByName("Button_Activity_Show", true)
	self:showWidgetByName("Button_Activity_Hide", false)
end

-- 动态调整scrollview可滑动区域大小以及其内部控件的坐标
-- @isShow 			操作是否为展开
-- @heightChange	操作导致的高度变化
function TitleMainLayer:_updateInnerContainerSize( isShow, heightChange )

	local scrollviewHeight = self._scrollView:getSize().height

	local size = self._scrollView:getInnerContainerSize()
	if not self._preCompensation then
		self._preCompensation = 0
	end 
	local newContainerHeight = size.height + heightChange - self._preCompensation
	-- 如果计算后的最小比scrollview的高度还小，则需要这个补偿
	local compensation = 0

	if newContainerHeight < scrollviewHeight then
		compensation = scrollviewHeight - newContainerHeight
		newContainerHeight = scrollviewHeight
	end	

	self._scrollView:setInnerContainerSize(CCSizeMake(size.width, newContainerHeight))
	local outsidePanelY = self._outsidePanel:getPositionY()
	outsidePanelY = outsidePanelY + heightChange + compensation - self._preCompensation
	self._outsidePanel:setPositionY(outsidePanelY)

	-- 上一次操作的补偿
	self._preCompensation = compensation

end

function TitleMainLayer:_onBackButton( ... )
	local packScene = G_GlobalFunc.createPackScene(self)
	if not packScene then
		packScene = require("app.scenes.mainscene.MainScene").new()
	end	
	uf_sceneManager:replaceScene(packScene)
	return true
end

function TitleMainLayer:onLayerExit( ... )
	-- __Log("onLayerExit")
end

return TitleMainLayer