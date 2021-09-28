--[[
    文件名: QuickExpMeetLayer.lua
	描述: 奇遇主界面
	创建人: yanghongsheng
	创建时间: 2017.4.10
--]]

require("Config.EnumsConfig")

QuickExpConfig = {}

-- 所有奇遇信息
QuickExpConfig = {
    -- 云游商人
    [ModuleSub.eQuickExpMeetBuy] = {
        moduleFile = "quickExp.MeetShangrenLayer", -- 实现该奇遇的字页面文件名
    },
    -- 金庸考题
    [ModuleSub.eQuickExpMeetQa] = {
        moduleFile = "quickExp.MeetJinyongLayer", -- 实现该奇遇的字页面文件名
    },
    -- 钓鱼
    [ModuleSub.eQuickExpMeetCompare] = {
        moduleFile = "quickExp.MeetDiaoyuLayer", -- 实现该奇遇的字页面文件名
    },
    -- 天降财神
    [ModuleSub.eQuickExpMeetDiamond] = {
        moduleFile = "quickExp.MeetCaishenLayer", -- 实现该奇遇的字页面文件名
    },
    -- 切磋武功
    [ModuleSub.eQuickExpMeetChallenge] = {
        moduleFile = "quickExp.MeetQiecuoLayer", -- 实现该奇遇的字页面文件名
    },
    -- 密室寻宝
    [ModuleSub.eQuickExpMeetBreak] = {
        moduleFile = "quickExp.MeetXunbaoLayer", -- 实现该奇遇的字页面文件名
    },
}

--[[
    params =  {
        meetInfo    :    奇遇数据
        showMeetId  :    选中界面ID(可选参数)
        selIndex    :    选中页索引(可选参数)
        notUpdateData:    是否更新数据(可选参数)
    }
]]

-- 主页面
local QuickExpMeetLayer = class("QuickExpMeetLayer", function()
    return display.newLayer()
end)

function QuickExpMeetLayer:ctor(params)
    -- 奇遇数据
    self.mMeetInfo = params.meetInfo
    self.meetId = params.showMeetId
    self.notUpdateData = params.notUpdateData
    -- 默认页
    self.mSelIndex = params.selIndex or 1
	-- 当前显示的子页面对象
	self.mSubLayer = nil
	-- 顶部列表的显示大小
	self.mListSize = cc.size(530, 110)
	-- 顶部列表中单个条目的大小
	self.mCellSize = cc.size(110, 110)
	-- 奇遇列表
	self.mMeetList = {}

	-- 创建底部导航和顶部玩家信息部分
	self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer, 1)

    -- 子页面的parent
    self.mSubLayerParent = cc.Node:create()
    self:addChild(self.mSubLayerParent)

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化页面信息
    self:initData()

    -- 初始化页面控件
    self:initUI()
end

function QuickExpMeetLayer:initData()
    if not self.notUpdateData then
        -- 剔除已完成奇遇
        local temTable = {}
        for i, v in ipairs(self.mMeetInfo) do
            if not v.IsDone then
                table.insert(temTable, v)
            end
        end
        self.mMeetInfo = temTable
    end
    -- 当前选中奇遇
    for i, v in ipairs(self.mMeetInfo) do
        if v.Id == self.meetId then
            self.mSelIndex = i
        end
    end
    -- 如果没有未完成的奇遇
    if not next(self.mMeetInfo) then
        ui.showFlashView(TR("还没新的奇遇"))
        LayerManager.removeLayer(self)
        -- 让界面初始化失败

        return
    end
	-- 初始化奇遇列表
	for i = 1, #self.mMeetInfo do
		self.mMeetList[i] = QuickexpMeetModel.items[self.mMeetInfo[i].TypeId]
		self.mMeetList[i].moduleFile = QuickExpConfig[self.mMeetList[i].modeID].moduleFile
	end
end

function QuickExpMeetLayer:initUI()
	local topPosY = 1136 - self.mListSize.height / 2 - self.mCommonLayer:getTopInfoHeight()
	--顶部背景
	local topSprite = ui.newScale9Sprite("c_69.png", cc.size(590, 145))
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

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 930),
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)
    self.closeBtn = closeBtn

    -- 奇遇列表
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.horizontal)
    self.mListView:setBounceEnabled(true)
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setContentSize(self.mListSize)
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setPosition(320, topPosY)
    self.mParentLayer:addChild(self.mListView)

    -- 刷新奇遇列表
    self:refreshListView()

    -- 调整选中Item的位置
    ui.setListviewItemShow(self.mListView, self.mSelIndex)
end

--[[
	描述：刷新顶部奇遇列表
]]
function QuickExpMeetLayer:refreshListView()
	self.mListView:removeAllItems()
	for index, item in ipairs(self.mMeetList) do
		local lvItem = ccui.Layout:create()
        lvItem:setContentSize(self.mCellSize)
        self.mListView:pushBackCustomItem(lvItem)

        self:refreshListItem(index)
	end
end

--[[
	描述：绘制奇遇列表一项
]]
function QuickExpMeetLayer:refreshListItem(index)
	local lvItem = self.mListView:getItem(index - 1)
    if not lvItem then
        lvItem = ccui.Layout:create()
        lvItem:setContentSize(self.mCellSize)
        self.mListView:insertCustomItem(lvItem, index - 1)
    end
    lvItem:removeAllChildren()

    -- 该条目的数据
    local tempData = self.mMeetList[index]

    -- -- 选中框
    -- if self.mSelIndex == index then
    -- 	local tempSprite = ui.newSprite("c_113.png")
    -- 	tempSprite:setPosition(self.mCellSize.width / 2, self.mCellSize.height / 2)
    -- 	lvItem:addChild(tempSprite)
    -- end

    -- 点击按钮
    local tempBtn = ui.newButton({
    	normalImage = string.isImageFile(tempData.pic..".png") and tempData.pic..".png" or "c_02.png",
    	--text = tempData.name,
    	fontSize = 22,
    	textColor = cc.c3b(251, 234, 8),			-- #fbea08
    	outlineColor = cc.c3b(128, 71, 21), 		-- #804715
    	outlineSize = 2,
    	fixedSize = true,
    	titlePosRateY = 0.2,
    	clickAction = function()
    		if self.mSelIndex == index then
    			return
    		end
    		self:changePage(index)

    	end
    })

    -- 按钮上的小红点
    local btnSize = tempBtn:getContentSize()
    local redDotSprite = ui.createBubble({position = cc.p(btnSize.width * 0.85, btnSize.height * 0.8)})
    tempBtn:addChild(redDotSprite)
    self.mMeetInfo[index].redDotSprite = redDotSprite

    if self.mMeetInfo[index].IsDone then
        redDotSprite:setVisible(false)
    end


    tempBtn:setPosition(self.mCellSize.width / 2, self.mCellSize.height / 2)
    lvItem:addChild(tempBtn)
end

--[[
	描述：切换不同奇遇页
	参数：奇遇页索引
]]
function QuickExpMeetLayer:changePage(index)
	local oldIndex = self.mSelIndex
	self.mSelIndex = index
	if oldIndex ~= self.mSelIndex then
		-- 刷新列表显示
		self:refreshListItem(oldIndex)
		self:refreshListItem(self.mSelIndex)
	end

	-- 删除老页面
	if not tolua.isnull(self.mSubLayer) then
		self.mSubLayer:removeFromParent()
		self.mSubLayer = nil
	end

	-- 创建新页面
	local itemData = self.mMeetList[self.mSelIndex]
	if itemData then
        local subLayerParams = {
            meetInfo = self.mMeetInfo,
            showMeetId = self.mMeetInfo[self.mSelIndex].Id,
            selIndex = self.mSelIndex,
            parent = self, -- 传入父结点
        }
        print("self.mSelIndex", self.mSelIndex)
		self.mSubLayer = require(itemData.moduleFile):create(subLayerParams)
		self.mSubLayerParent:addChild(self.mSubLayer)

        LayerManager.setRestoreData("quickExp.QuickExpMeetLayer", subLayerParams)
	end
end

-- 页面进入后自动选中第一个
function QuickExpMeetLayer:onEnterTransitionFinish()
    -- 切换页面
    Utility.performWithDelay(self.mParentLayer, function () 
            self:changePage(self.mSelIndex)
        end, 0.1)
end

return QuickExpMeetLayer
