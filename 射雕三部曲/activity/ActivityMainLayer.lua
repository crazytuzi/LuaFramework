--[[
    文件名: ActivityMainLayer.lua
	描述: 活动主页, 精彩活动、限时活动、通用活动、节日活动 ....
	创建人: liaoyuangang
	创建时间: 2016.6.2
--]]

local ActivityMainLayer = class("ActivityMainLayer", function()
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为:
	{
		moduleId: 主模块Id(精彩活动、限时活动、通用活动、节日活动 ....), 默认为精彩活动
		showSubModelId: 默认显示的子页面模块Id, 默认为nil

		-- 主要用于恢复页面时使用，普通调用者一般不会使用该参数
		showIndex: 默认显示页面在列表中的index
	}
]]
function ActivityMainLayer:ctor(params)
	params = params or {}
	-- 主模块Id
	self.mModuleId = params.moduleId or ModuleSub.eExtraActivity

	-- 该活动的当前数据
	self.mActivityInfoList = {}
	-- 当前显示的子页面对象
	self.mSubLayer = nil
	-- 顶部列表的显示大小
	self.mListSize = cc.size(530, 145)
	-- 顶部列表中单个条目的大小
	self.mCellSize = cc.size(110, 110)
	-- 初始化页面信息
	self:initData(params)
	-- 恢复页面的情况下，设置当前需要显示的页面Index

	-- 在showSubModelId有效的情况下，优先跳转到对应子页面
	-- self.mSelIndex为空意味着,跳转到该页面未指定showSubModelId，或者showSubModelId无效
	if not self.mSelIndex then
		self.mSelIndex = params.showIndex and params.showIndex <= #self.mActivityInfoList and params.showIndex or 1
	end

    -- 子页面的parent
    self.mSubLayerParent = cc.Node:create()
    self:addChild(self.mSubLayerParent)

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 创建底部导航和顶部玩家信息部分
	self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    -- 初始化页面控件
	self:initUI()

	-- 切换页面
	self:changePage(self.mSelIndex)
end

-- 初始化页面信息
function ActivityMainLayer:initData(params)
	-- 活动配置信息
	require("activity.ActivityConfig")
	local configData = ActivityConfig[self.mModuleId]

	-- 相同类型的活动需要在同一个页面显示的活动类型列表
	local shareActivity = ActivityConfig.ShareLayerActivity
	-- 福利多多类型活动需要显示到一个页面中
	local welfareActivity = ActivityConfig.Welfare
	-- 福利多多活动列表
	local welfareList = {}

	-- 处理一个配置Item
	local function dealOneConfigItem(moduleSub, item)
		if not item.moduleFile or item.moduleFile == "" then
			return
		end
		--
		local commonItem = {
			subLayerData = nil,
			moduleIdList = {moduleSub},
			navImg = item.navImg,
			moduleFile = item.moduleFile,
		}
		if self.mModuleId == ModuleSub.eExtraActivity then
			-- -- QQ分享只有QQ登录才显示
			-- if moduleSub == ModuleSub.ePrivilege then
			--     local loginType = PlayerAttrObj:getPlayerAttrByName("LoginType")
			--     if loginType == 1 or loginType == 2 then
			--     	local tempItem = clone(commonItem)
	  --               tempItem.name = item.name
	  --               table.insert(self.mActivityInfoList, tempItem)
			--     end
			if ModuleInfoObj:moduleIsOpen(moduleSub, false) then
                local tempItem = clone(commonItem)
                tempItem.name = item.name
                table.insert(self.mActivityInfoList, tempItem)
			end
		else
			local tempData = ActivityObj:getActivityItem(moduleSub)
			if not tempData then
				return
			end

			if welfareActivity[moduleSub] then  -- 福利多多活动，需要显示在一个页面中
				welfareList[moduleSub] = tempData
			elseif shareActivity[moduleSub] then
				local tempItem = clone(commonItem)
				tempItem.activityList = tempData
				tempItem.name = tempData[1].Name
				table.insert(self.mActivityInfoList, tempItem)
			else

				for _, dataItem in pairs(tempData or {}) do
					local tempItem = clone(commonItem)
					tempItem.activityList = {dataItem}
					tempItem.name = dataItem.Name
					tempItem.navImg = tempItem.navImg --前端ActivityConfig里面的图标
					table.insert(self.mActivityInfoList, tempItem)
				end
			end
		end
	end
	for moduleSub, item in pairs(configData) do
		dealOneConfigItem(moduleSub, item)
	end

	-- 添加福利多多
	local tempItem = {
		subLayerData = nil,
		moduleIdList = {},
		navImg = "",
		moduleFile = "",
		activityList = {}
	}
	for moduleSub, item in pairs(welfareList) do
		if #tempItem.moduleIdList == 0 then
			local configItem = configData[moduleSub]
			tempItem.name = TR("翻倍收益")
			tempItem.navImg = configItem.navImg
			tempItem.moduleFile = configItem.moduleFile
		end

		table.insert(tempItem.moduleIdList, moduleSub)
		for _, activityItem in pairs(item) do
			activityItem.ModuleId = moduleSub
			table.insert(tempItem.activityList, activityItem)
		end
	end
	if #tempItem.activityList > 0 then
		table.insert(self.mActivityInfoList, tempItem)
	end

	-- 排序
    table.sort(self.mActivityInfoList, function(item1, item2)
        -- 精彩活动有小红点的放在前面
        if self.mModuleId == ModuleSub.eExtraActivity then
            local reddot1 = 0
            for _, moduleId in pairs(item1.moduleIdList) do
                reddot1 = RedDotInfoObj:isValid(moduleId) and 1 or 0
                if reddot1 > 0 then
                    break
                end
            end
            local reddot2 = 0
            for _, moduleId in pairs(item2.moduleIdList) do
                reddot2 = RedDotInfoObj:isValid(moduleId) and 1 or 0
                if reddot2 > 0 then
                    break
                end
            end

            if reddot1 ~= reddot2 then
                return reddot1 > reddot2
            end
        else
            -- 非精彩活动，按照Xssx排序
            if item1.activityList and item2.activityList then
                return item1.activityList[1].Xssx < item2.activityList[1].Xssx
            end
        end

    	if item1.activityList and item2.activityList then
    		-- 按照活动实体Id排序
    		local activity1, activity2 = item1.activityList[1], item2.activityList[1]
    		if activity1.ActivityId ~= activity2.ActivityId then
        		return activity1.ActivityId < activity2.ActivityId
    		end
        else
        	if item1.moduleIdList[1] ~= item2.moduleIdList[1] then
        		return item1.moduleIdList[1] < item2.moduleIdList[1]
        	end
    	end

    	return true
    end)

    -- 设置当前需要选中的页面
    if params.showSubModelId and params.showSubModelId > 0 then
	    for index, item in pairs(self.mActivityInfoList) do
	    	if item.moduleIdList[1] == params.showSubModelId then
	    		self.mSelIndex = index
	    		break
	    	end
	    end
    end
end

-- 获取恢复数据
function ActivityMainLayer:getRestoreData()
	local retData = {
		moduleId = self.mModuleId,
		showIndex = self.mSelIndex,
	}

	return retData
end

-- 初始化页面控件
function ActivityMainLayer:initUI()
	local topPosY = 1136 - self.mListSize.height / 2 - self.mCommonLayer:getTopInfoHeight()+10
	--顶部背景
	local topSprite = ui.newScale9Sprite("c_69.png", cc.size(590, self.mListSize.height))
	topSprite:setPosition(320, topPosY)
	self.mParentLayer:addChild(topSprite)

	-- 左箭头
	local leftSprite = ui.newSprite("c_26.png")
	leftSprite:setPosition(cc.p(20, topPosY))
	leftSprite:setScaleX(-1)
	self.mParentLayer:addChild(leftSprite)

	-- 右箭头
	local rightSprite = ui.newSprite("c_26.png")
	rightSprite:setPosition(cc.p(620, topPosY))
	rightSprite:setScaleX(1)
	self.mParentLayer:addChild(rightSprite)

    -- 活动列表
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.horizontal)
    self.mListView:setBounceEnabled(true)
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setContentSize(self.mListSize)
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setPosition(320, topPosY)
    self.mParentLayer:addChild(self.mListView)

    -- 刷新活动列表
    self:refreshListView()

    -- 调整选中Item的位置
    ui.setListviewItemShow(self.mListView, self.mSelIndex)
end

-- 刷新活动列表
function ActivityMainLayer:refreshListView()
	self.mListView:removeAllItems()
	for index, item in ipairs(self.mActivityInfoList) do
		local lvItem = ccui.Layout:create()
        lvItem:setContentSize(self.mCellSize)
        self.mListView:pushBackCustomItem(lvItem)

        self:refreshListItem(index)
	end
end

-- 刷新列表中的一个Cell
function ActivityMainLayer:refreshListItem(index)
	local lvItem = self.mListView:getItem(index - 1)
    if not lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(self.mCellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
    end
    lvItem:removeAllChildren()

    -- 该条目的数据
    local tempData = self.mActivityInfoList[index]

    -- 选中框
    if self.mSelIndex == index then
    	local tempSprite = ui.newSprite("c_116.png")
    	tempSprite:setPosition(self.mCellSize.width / 2, self.mCellSize.height / 2 + 10)
    	lvItem:addChild(tempSprite)
    end

    -- 点击按钮
    local tempBtn = ui.newButton({
    	normalImage = string.isImageFile(tempData.navImg) and tempData.navImg or "c_02.png",
    	text = tempData.name,
    	fontSize = 22,
    	textColor = Enums.Color.eWhite,			-- #fbea08
    	outlineColor = cc.c3b(0x0b, 0x0b, 0x0b), 		-- #804715
    	outlineSize = 2,
    	fixedSize = true,
    	titlePosRateY = 0.2,
    	clickAction = function()
    		-- 删除该条目的new标记
    		for _, moduleId in pairs(tempData.moduleIdList) do
	        	ActivityObj:deleteNewActivity(moduleId)
		    end

    		if self.mSelIndex == index then
    			return
    		end
    		self:changePage(index)

    	end
    })
    tempBtn:setPosition(self.mCellSize.width / 2, self.mCellSize.height / 2)
    lvItem:addChild(tempBtn)

    -- 按钮的大小
    local btnSize = tempBtn:getContentSize()

    -- 处理new标识是否显示的函数
    do
	    local function dealNewVisible(newSprite)
	        local haveNew = false
	        for _, moduleId in pairs(tempData.moduleIdList) do
	        	haveNew = ActivityObj:activityIsNew(moduleId)
	        	if haveNew then
				    if self.mSelIndex == index then
				    	-- 删除该条目的new标记
				    	ActivityObj:deleteNewActivity(moduleId)
				    else
	        			break
				    end
	        	end
		    end
	        newSprite:setVisible(haveNew and self.mSelIndex ~= index)
	    end
	    -- new 标识的事件名称
        local eventNames = {}
        for _, moduleId in pairs(tempData.moduleIdList) do
            table.insert(eventNames, EventsName.eNewPrefix .. tostring(moduleId))
        end
        ui.createAutoBubble({parent = tempBtn, isNew = true, refreshFunc = dealNewVisible,
            eventName = eventNames})
   	end

    -- 小红点逻辑
    do
	    local function dealRedDotVisible(redDotSprite)
	    	local redDotData = false
	    	for _, moduleId in pairs(tempData.moduleIdList) do
	    		redDotData = RedDotInfoObj:isValid(moduleId)
	    		if redDotData then
	    			break
	    		end
	    	end
	        redDotSprite:setVisible(redDotData)
	    end
	    -- 事件名
	    local eventNames = {}
	    for _, moduleId in pairs(tempData.moduleIdList) do
	    	table.insert(eventNames, EventsName.eRedDotPrefix .. tostring(moduleId))
	    end
        ui.createAutoBubble({parent = tempBtn, eventName = eventNames, refreshFunc = dealRedDotVisible})
   	end
end

-- 切换页面
function ActivityMainLayer:changePage(index)
	local oldIndex = self.mSelIndex
	self.mSelIndex = index
	if oldIndex ~= self.mSelIndex then
		-- 刷新列表显示
		self:refreshListItem(oldIndex)
		self:refreshListItem(self.mSelIndex)
	end

	-- 删除老页面
	if not tolua.isnull(self.mSubLayer) then
		local oldItemData = self.mActivityInfoList[oldIndex]
		oldItemData.subLayerData = self.mSubLayer:getRestoreData()
		self.mSubLayer:removeFromParent()
		self.mSubLayer = nil
	end

	-- 创建新页面
	local itemData = self.mActivityInfoList[self.mSelIndex]
	if itemData then
		local subLayerParams = itemData.subLayerData
		if not subLayerParams then
			local tempIdList = {}
			for _, Id in ipairs(itemData.activityList or {}) do
				table.insert(tempIdList, Id)
			end

			subLayerParams = {
				activityIdList = tempIdList,
				parentModuleId = self.mModuleId
			}
		end
		print("itemData.moduleFile:", itemData.moduleFile)
		--dump(subLayerParams, "subLayerParams:")
		self.mSubLayer = require(itemData.moduleFile):create(subLayerParams)
		self.mSubLayerParent:addChild(self.mSubLayer)
	end
end

return ActivityMainLayer
