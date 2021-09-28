--[[
	文件名：QFashionRefineView.lua
	描述：时装分解页面
	创建人: 杨宏生
	创建时间: 2018.05.04
--]]

local QFashionRefineView = class("QFashionRefineView", function()
	return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
	{
		viewSize: 显示大小，必选参数
		callback: 回调接口
	}
]]

-- 构造函数
function QFashionRefineView:ctor(params)
	-- 读取参数
	self.viewSize = params.viewSize
	self.callback = params.callback

	-- 时装分解选择列表
	self.fashionSeleList = {}
	
	-- 初始化
	self:setContentSize(self.viewSize)
	
	-- 显示界面
	self:initUI()

	-- 刷新页面
	self:refreshUI()
end

-- 初始化界面
function QFashionRefineView:initUI()
	-- 黑背景
	local bgSize = self.viewSize--cc.size(self.viewSize.width-30, self.viewSize.height-30)
	local blackBg = ui.newScale9Sprite("c_17.png", bgSize)
	blackBg:setPosition(self.viewSize.width*0.5, self.viewSize.height+7)
	blackBg:setAnchorPoint(cc.p(0.5, 1))
	self:addChild(blackBg)

	-- 列表
	self.mRefineListView = ccui.ListView:create()
	self.mRefineListView:setDirection(ccui.ScrollViewDir.vertical)
	self.mRefineListView:setBounceEnabled(true)
	self.mRefineListView:setContentSize(cc.size(bgSize.width, bgSize.height-100))
	self.mRefineListView:setItemsMargin(5)
	self.mRefineListView:setGravity(ccui.ListViewGravity.centerHorizontal)
	self.mRefineListView:setAnchorPoint(cc.p(0.5, 1))
	self.mRefineListView:setPosition(bgSize.width*0.5, bgSize.height-15)
	blackBg:addChild(self.mRefineListView)

	-- 空提示
	self.mEmptyHint = ui.createEmptyHint(TR("没有可分解的时装"))
	self.mEmptyHint:setPosition(self.viewSize.width*0.5, self.viewSize.height*0.5)
	self:addChild(self.mEmptyHint)

	-- 分解按钮
	self.mRefineBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("分解"),
			clickAction = function ()
				self:requestRefine()
			end,
		})
	self.mRefineBtn:setPosition(self.viewSize.width*0.5, 50)
	self:addChild(self.mRefineBtn)
end

-- 创建列表项
function QFashionRefineView:createCell(fashionInfo)
	local cellSize = cc.size(self.mRefineListView:getContentSize().width-30, 120)
	local layout = ccui.Layout:create()
	layout:setContentSize(cellSize)

	-- 背景
	local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
	bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	layout:addChild(bgSprite)

	-- 头像
	local headCard = CardNode.createCardNode({
			resourceTypeSub = ResourcetypeSub.eShiZhuang,
			instanceData = fashionInfo,
			cardShowAttrs = {CardShowAttr.eBorder},
		})
	headCard:setPosition(80, cellSize.height*0.5)
	layout:addChild(headCard)
	-- 名字
	local fashionModel = ShizhuangModel.items[fashionInfo.ModelId]
	local colorLv = Utility.getColorLvByModelId(fashionInfo.ModelId)
	local name = ui.newLabel({
			text = fashionModel.name,
			color = Utility.getColorValue(colorLv, 1),
			outlineColor = Enums.Color.eOutlineColor,
		})
	name:setAnchorPoint(cc.p(0, 0))
	name:setPosition(150, cellSize.height*0.55)
	layout:addChild(name)
	-- 品质
	local quality = ui.newLabel({
			text = TR("品质:%s%d", Enums.Color.eBlackH, fashionModel.quality),
			color = Enums.Color.eBrown,
		})
	quality:setAnchorPoint(cc.p(0, 0))
	quality:setPosition(150, cellSize.height*0.25)
	layout:addChild(quality)
	-- 复选框
	local checkbox = ui.newCheckbox()
	checkbox:setPosition(cellSize.width*0.8, cellSize.height*0.5)
	layout:addChild(checkbox)
	-- 透明按钮
	local clickBtn = ui.newButton({
			normalImage = "c_83.png",
			size = cellSize,
			clickAction = function ()
				layout.changeState()
			end,
		})
	clickBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	layout:addChild(clickBtn)
	-- 改变选择状态（默认改变当前状态，可以给一个指定状态）
	layout.changeState = function (isSelect)
		local oldState = checkbox:getCheckState()
		local newState = isSelect ~= nil and isSelect or not oldState

		-- 修改选择列表
		self.fashionSeleList[fashionInfo.Id] = newState or nil
		-- 更新复选框显示
		checkbox:setCheckState(newState)
	end

	return layout
end

-- 刷新界面
function QFashionRefineView:refreshUI()
	-- 清空列表
	self.mRefineListView:removeAllChildren()
	
	-- 分解时装列表
	local refineFashionList = QFashionObj:getRefineFashionList()

	-- 有可分解项，添加到显示列表
	if refineFashionList and next(refineFashionList) then
		-- 添加到显示列表
		for _, fashionInfo in pairs(refineFashionList) do
			local item = self:createCell(fashionInfo)
			self.mRefineListView:pushBackCustomItem(item)
		end
	else

	end

	-- 显示／隐藏空提示
	self.mEmptyHint:setVisible((not refineFashionList) or (not next(refineFashionList)))

	-- 显示／隐藏分解按钮
	self.mRefineBtn:setVisible(refineFashionList and next(refineFashionList) and true or false)
end

----------------------网络相关---------------------
-- 分解时装
function QFashionRefineView:requestRefine()
	local fashionIdList = {}
	for Id, _ in pairs(self.fashionSeleList) do
		table.insert(fashionIdList, Id)
	end
	-- 空列表判断
	if #fashionIdList <= 0 then
		ui.showFlashView(TR("请选择要分解的绝学"))
		return
	end
	
	HttpClient:request({
        moduleName = "Shizhuang",
        methodName = "Decompose",
        svrMethodData = {fashionIdList},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            -- 清空选择列表
            self.fashionSeleList = {}
            -- 掉落
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            -- 更新缓存
            QFashionObj:updateFashionList(response.Value.ShiZhuangInfo)
            -- 刷新
			self:refreshUI()
        end,
    })
end

return QFashionRefineView