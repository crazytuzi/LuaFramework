--[[
	文件名：DlgPetBookLayer.lua
	描述：外功招式的目录对话框
	创建人: peiyaoqiang
	创建时间: 2017.08.07
--]]

local DlgPetBookLayer = class("DlgPetBookLayer", function()
	return display.newLayer(cc.c4b(0, 0, 0, 128))
end)

-- 构造函数
function DlgPetBookLayer:ctor(params)
	self.nodeList = params.nodeList
	self.mCTalList = params.mCTalList
    self.callback = params.callback

	-- 背景图
	local bgSprite = ui.newSprite("wgcw_30.png")
	bgSprite:setScale(Adapter.MinScale)
	bgSprite:setPosition(display.cx - 8 * Adapter.MinScale, display.cy - 20 * Adapter.MinScale)
	self:addChild(bgSprite)
	self.bgSprite = bgSprite
	self.bgSize = bgSprite:getContentSize()
	self.centerPosX = self.bgSize.width * 0.5 + 25

	-- 目录标题
	local titleSprite = ui.newSprite("wgcw_25.png")
	titleSprite:setAnchorPoint(cc.p(0, 1))
	titleSprite:setPosition(80, self.bgSize.height - 30)
	bgSprite:addChild(titleSprite)

	-- 上下箭头
	local upSprite = ui.newSprite("c_43.png")
    local downSprite = ui.newSprite("c_43.png")
    upSprite:setPosition(self.centerPosX, self.bgSize.height + 15)
    downSprite:setPosition(self.centerPosX, 20)
    upSprite:setRotation(180)
    bgSprite:addChild(upSprite)
    bgSprite:addChild(downSprite)

	-- 拖动列表
	local listViewSize = cc.size(self.bgSize.width - 200, self.bgSize.height - 100)
	local mListView = ccui.ListView:create()
    mListView:setDirection(ccui.ScrollViewDir.vertical)
    mListView:setBounceEnabled(true)
    mListView:setContentSize(listViewSize)
    mListView:setGravity(ccui.ListViewGravity.centerVertical)
    mListView:setAnchorPoint(cc.p(0.5, 1))
    mListView:setPosition(self.centerPosX + 30, self.bgSize.height - 35)
    mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    bgSprite:addChild(mListView)

    for i, nodeItem in ipairs(self.nodeList) do
        -- 处理数据
    	local activeTalItem = nil
        local activeTalInfo = nil
        for _, v in pairs(nodeItem) do
            local tmpTalInfo = self.mCTalList[v.ID]
    		if tmpTalInfo then
                activeTalItem = clone(v)
                activeTalInfo = clone(tmpTalInfo)
    			break
    		end
    	end

        -- 背景
    	local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cc.size(listViewSize.width, 60))
        mListView:pushBackCustomItem(lvItem)

        -- 透明按钮
        local bgButton = ui.newButton({
        	normalImage = "c_83.png",
        	size = cc.size(listViewSize.width, 56),
        	position = cc.p(listViewSize.width * 0.5, 30),
        	clickAction = function()
        		if self.callback then
        			self.callback(i)
        		end
        		LayerManager.removeLayer(self)
	        end
        })
        lvItem:addChild(bgButton)

        -- 标题
        local titleImg = "wgcw_28.png"
        local titleColor = cc.c3b(0x77, 0x75, 0x70)
        local strTalName = TR("暂未参悟任何招式")
        if (activeTalItem ~= nil) then
        	titleImg = "wgcw_24.png"
        	titleColor = cc.c3b(0x9e, 0x26, 0x19)
        	strTalName = activeTalItem.name .. string.format(" (%s/%s)", (activeTalInfo.TalentNum or 0), activeTalItem.totalNum)
        end
        local titleBgSprite = ui.newSprite(titleImg)
        titleBgSprite:setAnchorPoint(cc.p(0, 0.5))
        titleBgSprite:setPosition(20, 30)
        lvItem:addChild(titleBgSprite)

        -- 层数
        local titleLabel = ui.newLabel({
	        text = TR("第%d层", i),
	        color = Enums.Color.eNormalWhite,
	        outlineColor = titleColor,
	        size = 24,
	        anchorPoint = cc.p(0, 0.5)
	    })
	    titleLabel:setPosition(45, 30)
	    lvItem:addChild(titleLabel)

        -- 文字
        local nameLabel = ui.newLabel({
	        text = strTalName,
	        color = titleColor,
	        size = 24,
	        anchorPoint = cc.p(0.5, 0.5)
	    })
	    nameLabel:setPosition(280, 30)
	    lvItem:addChild(nameLabel)
    end

	-- 添加触摸控制
	ui.registerSwallowTouch({node = bgSprite,
		beganEvent = function (touch, event)
			return true
		end,
		endedEvent = function (touch, event)
			local touchPos = bgSprite:convertTouchToNodeSpace(touch)
			if (touchPos.y >= self.bgSize.height) or (touchPos.y <= 40) then
				LayerManager.removeLayer(self)
			end
		end})
end

return DlgPetBookLayer
