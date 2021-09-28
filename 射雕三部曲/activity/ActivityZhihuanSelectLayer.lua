--[[
	文件名：ActivityZhihuanSelectLayer.lua
	描述：幻化置换选择界面
	创建人：yanghongsheng
	创建时间：2019.02.21
--]]

local ActivityZhihuanSelectLayer = class("ActivityZhihuanSelectLayer", function(params)
	return display.newLayer()
end)

--[[
	params:
		displaceList 	-- 可置换列表
		isMySelf		-- 是否选自己拥有的
		leftModelId		-- 左边已选的排除
		callback 		-- 回调
]]

function ActivityZhihuanSelectLayer:ctor(params)
	self.mDisplaceList = params.displaceList or {}
	self.mIsMySelf = params.isMySelf
	self.mLeftModelId = params.leftModelId
	self.mCallback = params.callback

	self.mCurModelId = 0
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

    --创建底部和顶部的控件
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

	-- 初始化页面控件
	self:initUI()
end

function ActivityZhihuanSelectLayer:initUI()
	-- 背景图
    local bgSprite = ui.newSprite("hhzh_01.jpg")
    bgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(bgSprite)

    -- 背景图
	local bgSprite = ui.newSprite("c_128.jpg")
	bgSprite:setAnchorPoint(cc.p(0.5, 1))
	bgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(bgSprite)

	-- 子背景
    local subBgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 950))
    subBgSprite:setAnchorPoint(cc.p(0.5, 1))
    subBgSprite:setPosition(cc.p(self.mParentLayer:getContentSize().width * 0.5, 1000))
    self.mParentLayer:addChild(subBgSprite)

    -- 显示页签
    self:showTabLayer()

    -- 列表背景
    local listBgSize = cc.size(618, 760)
	local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
	listBg:setAnchorPoint(cc.p(0.5, 1))
	listBg:setPosition(320, 970)
	self.mParentLayer:addChild(listBg)

	-- 列表
	self.listViewSize = cc.size(listBgSize.width-20, listBgSize.height-20)
	local listView = ccui.ListView:create()
	listView:setContentSize(self.listViewSize)
    listView:setDirection(ccui.ListViewDirection.vertical)
    listView:setGravity(ccui.ListViewGravity.centerHorizontal)
    listView:setItemsMargin(10)
    listView:setBounceEnabled(true)
    listView:setAnchorPoint(0.5, 0.5)
    listView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
    listBg:addChild(listView)
    self.mListView = listView

	-- 确认按钮
    local confirmBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确定"),
        position = cc.p(self.mParentLayer:getContentSize().width * 0.5, 150),
        clickAction = function(pSender)
        	if self.mCurModelId == 0 then
        		ui.showFlashView("请先选择幻化侠客")
        		return
        	end
            if self.mCallback then
            	self.mCallback(self.mCurModelId)
            end
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(confirmBtn)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)

    self:refreshList()
end

-- 显示页签
function ActivityZhihuanSelectLayer:showTabLayer()
    -- 创建分页
    local buttonInfos = {
        {
            text = TR("幻化"),
            tag = 1,
        },
    }
    -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
    })

    tabLayer:setPosition(Enums.StardardRootPos.eTabView)
    self.mParentLayer:addChild(tabLayer)
end

-- 更新列表
function ActivityZhihuanSelectLayer:refreshList()
	local heroList = self.mDisplaceList
	if self.mIsMySelf then
		heroList = {}
		for _, modelId in pairs(self.mDisplaceList) do
			if IllusionObj:getCountByModelId(modelId, {notInFormation = true}) > 0 then
				table.insert(heroList, modelId)
			end
		end
	else
		local index = table.indexof(heroList, self.mLeftModelId)
		if index then
			table.remove(heroList, index)
		end
	end

	if next(heroList) then
		for _, modelId in pairs(heroList) do
			local item = self:createCell(modelId)
			self.mListView:pushBackCustomItem(item)
		end
	else
		local emptyHint = ui.createEmptyHint(TR("没有可置换的幻化侠客"))
		emptyHint:setPosition(320, 568)
		self.mParentLayer:addChild(emptyHint)
	end
end

-- 创建项
function ActivityZhihuanSelectLayer:createCell(modelId)
	local cellSize = cc.size(self.listViewSize.width, 130)
	local illusionInfo = IllusionModel.items[modelId]

	local layout = ccui.Layout:create()
	layout:setContentSize(cellSize)

	local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
	bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	layout:addChild(bgSprite)

	-- 点击复选框的回调
	local function checkCallBack(newState)
		if newState then
			self.mCurModelId = modelId
			if self.beforeCheckBox then
				self.beforeCheckBox:setCheckState(false)
			end
			layout.checkBox:setCheckState(true)
			self.beforeCheckBox = layout.checkBox
		end
	end

	-- 复选框
	local checkBox = ui.newCheckbox({
			callback = function (state)
				checkCallBack(state)
			end,
		})
	checkBox:setPosition(cellSize.width * 0.65, cellSize.height * 0.5)
	layout:addChild(checkBox)
	layout.checkBox = checkBox

	-- 透明按钮（点击选项空白也可以改变复选状态）
	local itemBtn = ui.newButton({
			normalImage = "c_83.png",
			size = cellSize,
			clickAction = function ()
				checkCallBack(not layout.checkBox:getCheckState())
			end
		})
	itemBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	layout:addChild(itemBtn)

	-- 头像卡牌
	local card = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eIllusion,
			modelId = modelId,
			num = self.mIsMySelf and IllusionObj:getCountByModelId(modelId, {notInFormation = true}) or 1,
			cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
		})
	card:setPosition(cellSize.width*0.15, cellSize.height*0.5)
	layout:addChild(card)

	-- 名字
	local nameLabel = ui.newLabel({
			text = illusionInfo.name,
			color = Utility.getColorValue(illusionInfo.colorLV, 1),
			outlineColor = Enums.Color.eOutlineColor,
		})
	nameLabel:setAnchorPoint(cc.p(0, 0.5))
	nameLabel:setPosition(160, cellSize.height * 0.75)
	layout:addChild(nameLabel)

	-- 资质
	local qualityLabel = ui.newLabel({
			text = TR("资质:%s%d", Enums.Color.eBlackH, illusionInfo.quality),
			color = Enums.Color.eBrown,
		})
	qualityLabel:setAnchorPoint(cc.p(0, 0.5))
	qualityLabel:setPosition(160, cellSize.height * 0.5)
	layout:addChild(qualityLabel)

	-- 星数
	local starNode = ui.newStarLevel(illusionInfo.colorLV)
	starNode:setAnchorPoint(cc.p(0, 0.5))
	starNode:setPosition(160, cellSize.height * 0.25)
	layout:addChild(starNode)

	return layout
end


return ActivityZhihuanSelectLayer