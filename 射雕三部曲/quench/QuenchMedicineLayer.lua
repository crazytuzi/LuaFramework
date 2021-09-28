--[[
	文件名：QuenchMedicineLayer.lua
	描述：药材包裹界面
	创建人：yanghongsheng
	创建时间： 2017.12.5
--]]

local QuenchMedicineLayer = class("QuenchMedicineLayer", function(params)
	return display.newLayer()
end)

function QuenchMedicineLayer:ctor(params)
    params = params or {}
    -- 药材丹药列表
    self.mPelletList = params.pelletList
    -- 选中药材列表
    self.mSelectPelletList = params.selectPelletList
    -- 选择丹药上限
    self.mNeedHerbsNum = params.needHerbsNum
    -- 选择表
    self.mSelectList = {}
    -- 当前品质
    self.mQuality = nil
    -- 当前还需要的丹药
    self.curNeedNum = 0
	-- 屏蔽下层触摸
	ui.registerSwallowTouch({node = self})
	-- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {ResourcetypeSub.eSTA, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
    self.mCommonLayer_ = tempLayer

    self:initData()
    -- 初始化
    self:initUI()
end

function QuenchMedicineLayer:initData()
	-- 计数
	local count = 0
	-- 序列化列表
	local tempList = {}
	for _, value in pairs(self.mSelectPelletList) do
		if value then
			count = count + 1
			self.mQuality = GoodsModel.items[value.ModelId].quality
			table.insert(tempList, value)
		end
	end
	self.mSelectPelletList = tempList
	-- 初始化当前需要的药材数
	self.curNeedNum = self.mNeedHerbsNum - count
end

function QuenchMedicineLayer:initUI()
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

	-- 确认按钮
    local confirmBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确定"),
        position = cc.p(self.mParentLayer:getContentSize().width * 0.5, 150),
        clickAction = function(pSender)
            self:closeLayer()
        end
    })
    self.mParentLayer:addChild(confirmBtn)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            self:closeLayer()
        end
    })
    self.mParentLayer:addChild(closeBtn)

    if self.mPelletList and next(self.mPelletList) then
	    for _, itemData in pairs(self.mPelletList or {}) do
	    	local item = self:createCell(itemData)
	    	listView:pushBackCustomItem(item)
	    end
	else
		local emptyHint = ui.createEmptyHint(TR("请前往光明顶获取药材"))
		emptyHint:setPosition(320, 568)
		self.mParentLayer:addChild(emptyHint)

		local tranBtn = ui.newButton({
				text = TR("立即前往"),
				normalImage = "c_28.png",
				clickAction = function ()
					LayerManager.showSubModule(ModuleSub.eExpedition)
				end,
			})
		tranBtn:setPosition(320, 400)
		self.mParentLayer:addChild(tranBtn)

		confirmBtn:setVisible(false)
	end
end

-- 显示页签
function QuenchMedicineLayer:showTabLayer()
    -- 创建分页
    local buttonInfos = {
        {
            text = TR("药材"),
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

-- 关闭页面
function QuenchMedicineLayer:closeLayer()
	for ModelId, num in pairs(self.mSelectList) do
		for i = 1, num do
			table.insert(self.mSelectPelletList, {ModelId = ModelId})
		end
	end
	LayerManager.setRestoreData("quench.QuenchAlchemyLayer", {
			selectPelletList = self.mSelectPelletList,
		})
	LayerManager.removeLayer(self)
end

-- 创建项
function QuenchMedicineLayer:createCell(itemData)
	local cellSize = cc.size(self.listViewSize.width, 130)
	local goodsInfo = GoodsModel.items[itemData.ModelId]

	local layout = ccui.Layout:create()
	layout:setContentSize(cellSize)

	local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
	bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	layout:addChild(bgSprite)

	local morenNum = 1 -- 默认初始数量
	local morenAdd = 1 -- 默认增量
	-- 点击复选框的回调
	local function checkCallBack(newState)
		if newState then
			if self.curNeedNum <= 0 then
				layout.checkBox:setCheckState(not newState)
				ui.showFlashView({text = TR("已有足够药材")})
				return
			elseif self.mQuality and self.mQuality ~= GoodsModel.items[itemData.ModelId].quality then
				layout.checkBox:setCheckState(not newState)
				ui.showFlashView({text = TR("需要相同品质的药材")})
				return
			elseif itemData.Num < morenNum then
				layout.checkBox:setCheckState(not newState)
				ui.showFlashView({text = TR("药材数量不足")})
				return
			end
			self.mQuality = GoodsModel.items[itemData.ModelId].quality
			self.mSelectList[itemData.ModelId] = morenNum
			self.curNeedNum = self.curNeedNum - morenNum
			layout.numSelectParent:setVisible(true)
			layout.numSelectParent.numLabel:setString(self.mSelectList[itemData.ModelId])
		else
			self.curNeedNum = self.curNeedNum + self.mSelectList[itemData.ModelId]
			self.mSelectList[itemData.ModelId] = nil
			layout.numSelectParent:setVisible(false)
			if self.curNeedNum == self.mNeedHerbsNum then
				self.mQuality = nil
			end
		end
		layout.checkBox:setCheckState(newState)
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

	-- 数量选择
	local numSelectParent = cc.Node:create()
	numSelectParent:setPosition(cellSize.width * 0.7, cellSize.height * 0.5)
	layout:addChild(numSelectParent)
	numSelectParent:setVisible(false)
	layout.numSelectParent = numSelectParent

	-- 数量显示
	local numLabel = ui.newLabel({
			text = tostring(morenNum),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 22,
		})
	numLabel:setPosition(70, 0)
	numSelectParent:addChild(numLabel)
	numSelectParent.numLabel = numLabel

	-- 减按钮
	local subtractBtn = ui.newButton({
			normalImage = "gd_28.png",
			clickAction = function ()
				if self.mSelectList[itemData.ModelId] and self.mSelectList[itemData.ModelId] > morenNum then
					self.mSelectList[itemData.ModelId] =  self.mSelectList[itemData.ModelId] - morenAdd
					numLabel:setString(self.mSelectList[itemData.ModelId])
					self.curNeedNum = self.curNeedNum + morenAdd
				end
			end
		})
	subtractBtn:setPosition(30, 0)
	numSelectParent:addChild(subtractBtn)

	-- 加按钮
	local subtractBtn = ui.newButton({
			normalImage = "c_21.png",
			clickAction = function ()
				if self.mSelectList[itemData.ModelId] and self.curNeedNum > 0 and itemData.Num - self.mSelectList[itemData.ModelId] > 0 then
					self.mSelectList[itemData.ModelId] =  self.mSelectList[itemData.ModelId] + morenAdd
					numLabel:setString(self.mSelectList[itemData.ModelId])
					self.curNeedNum = self.curNeedNum - morenAdd
				end
			end
		})
	subtractBtn:setPosition(120, 0)
	numSelectParent:addChild(subtractBtn)
	-- 药材头像卡牌
	local card = CardNode.createCardNode({
			instanceData = itemData,
			cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
		})
	card:setPosition(cellSize.width*0.15, cellSize.height*0.5)
	layout:addChild(card)

	-- 药材品质等级
	local colorLv = Utility.getQualityColorLv(goodsInfo.quality)

	-- 药材名字
	local nameLabel = ui.newLabel({
			text = goodsInfo.name,
			color = Utility.getColorValue(colorLv, 1),
			outlineColor = Enums.Color.eOutlineColor,
		})
	nameLabel:setAnchorPoint(cc.p(0, 0.5))
	nameLabel:setPosition(160, cellSize.height * 0.75)
	layout:addChild(nameLabel)

	-- 药材资质
	local qualityLabel = ui.newLabel({
			text = TR("资质:%s%d", Enums.Color.eBlackH, goodsInfo.quality),
			color = Enums.Color.eBrown,
		})
	qualityLabel:setAnchorPoint(cc.p(0, 0.5))
	qualityLabel:setPosition(160, cellSize.height * 0.5)
	layout:addChild(qualityLabel)

	-- 星数
	local starNode = ui.newStarLevel(colorLv)
	starNode:setAnchorPoint(cc.p(0, 0.5))
	starNode:setPosition(160, cellSize.height * 0.25)
	layout:addChild(starNode)

	return layout
end

return QuenchMedicineLayer