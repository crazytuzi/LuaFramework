--[[
	文件名：VegetablesSeedSelLayer.lua
	描述：种菜种子选择界面
	创建人：yanghongsheng
	创建时间： 2017.12.5
--]]

local VegetablesSeedSelLayer = class("VegetablesSeedSelLayer", function(params)
	return display.newLayer()
end)

--[[
	params:
		landId:		菜地ID(必须)
		callback: 	回调
]]

function VegetablesSeedSelLayer:ctor(params)
    params = params or {}
    self.mLandId = params.landId	-- 菜地id
    self.callback = params.callback -- 回调
    -- 种子列表
    self.mSeedList = {}
    -- 选择种子id
    self.mSelectSeedId = 0
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

    self:initUI()

    -- 请求种子列表
    self:requestSeedInfo()
end

function VegetablesSeedSelLayer:initUI()
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
        text = TR("修复"),
        position = cc.p(self.mParentLayer:getContentSize().width * 0.5, 150),
        clickAction = function(pSender)
        	if not self.mLandId then
        		ui.showFlashView(TR("剑冢id错误"))
        		return
    		elseif not self.mSelectSeedId or self.mSelectSeedId == 0 then
    			ui.showFlashView(TR("请先选择一个矿石"))
    			return
    		end

            self:requestSeed()
        end
    })
    self.mParentLayer:addChild(confirmBtn)
    self.mConfirmBtn = confirmBtn

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)
end

-- 显示页签
function VegetablesSeedSelLayer:showTabLayer()
    -- 创建分页
    local buttonInfos = {
        {
            text = TR("矿石"),
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

-- 刷新界面
function VegetablesSeedSelLayer:refreshUI()
	-- 清除数据
	self.mListView:removeAllChildren()
	if self.mEmptyHint then
		self.mEmptyHint:removeFromParent()
		self.mEmptyHint = nil
	end

	-- 更新显示
    if self.mSeedList and next(self.mSeedList) then
	    for _, itemData in pairs(self.mSeedList or {}) do
	    	local item = self:createCell(itemData)
	    	self.mListView:pushBackCustomItem(item)
	    end
	else
		self.mEmptyHint = ui.createEmptyHint(TR("请在矿石商店购买矿石"))
		self.mEmptyHint:setPosition(320, 568)
		self.mParentLayer:addChild(self.mEmptyHint)

		self.mConfirmBtn:setVisible(false)
	end
end

-- 创建项
function VegetablesSeedSelLayer:createCell(itemData)
	local cellSize = cc.size(self.listViewSize.width, 130)
	local goodsInfo = GoodsModel.items[itemData.ModelId]

	local layout = ccui.Layout:create()
	layout:setContentSize(cellSize)

	local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
	bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	layout:addChild(bgSprite)

	-- 点击复选框的回调
	local function checkCallBack(newState)
		-- 取消上次选择
		self.curItem = self.curItem or layout
		self.curItem.checkBox:setCheckState(false)
		self.mSelectSeedId = 0

		-- 判断本次选择
		if newState then
			layout.checkBox:setCheckState(true)
			self.mSelectSeedId = itemData.Id
		else
			layout.checkBox:setCheckState(false)
			self.mSelectSeedId = 0
		end

		-- 更新当前选择项
		self.curItem = layout
	end

	-- 复选框
	local checkBox = ui.newCheckbox({
			callback = function (state)
				checkCallBack(state)
			end,
		})
	checkBox:setPosition(cellSize.width * 0.75, cellSize.height * 0.5)
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

	-- 卡牌头像
	local card = CardNode.createCardNode({
			instanceData = itemData,
			cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
		})
	card:setPosition(cellSize.width*0.15, cellSize.height*0.5)
	layout:addChild(card)

	-- 品质等级
	local colorLv = Utility.getQualityColorLv(goodsInfo.quality)

	-- 名字
	local nameLabel = ui.newLabel({
			text = goodsInfo.name,
			color = Utility.getColorValue(colorLv, 1),
			outlineColor = Enums.Color.eOutlineColor,
		})
	nameLabel:setAnchorPoint(cc.p(0, 0.5))
	nameLabel:setPosition(160, cellSize.height * 0.75)
	layout:addChild(nameLabel)

	-- 资质
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

--==========================网络相关=========================
-- 请求种子信息
function VegetablesSeedSelLayer:requestSeedInfo()
	HttpClient:request({
        moduleName = "TimedVegetablesInfo",
        methodName = "GetSeed",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mSeedList = response.Value.VegetablesGoods

            self:refreshUI()
        end
    })
end
-- 请求种植
function VegetablesSeedSelLayer:requestSeed()
	HttpClient:request({
        moduleName = "TimedVegetablesInfo",
        methodName = "Seed",
        svrMethodData = {self.mLandId, self.mSelectSeedId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            -- 执行回调
            if self.callback then
            	self.callback(response)
            end

            -- 关闭页面
            LayerManager.removeLayer(self)
        end
    })
end

return VegetablesSeedSelLayer