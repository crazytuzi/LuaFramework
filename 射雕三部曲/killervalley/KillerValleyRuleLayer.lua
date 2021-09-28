--[[
    文件名：KillerValleyRuleLayer.lua
	描述：绝情谷规则界面
	创建人：yanghongsheng
	创建时间：2018.1.29
-- ]]

local KillerValleyRuleLayer = class("KillerValleyRuleLayer", function()
	return display.newLayer()
end)

local RuleDescTag = {
	ePictureDesc = 1,	-- 图片描述页签tag
	eTextDesc = 2,		-- 文字描述页签tag
}

-- 图片滑动修改小点状态事件
local PointChangeEvent = "PointChangeEvent"

function KillerValleyRuleLayer:ctor(params)
	-- 屏蔽下层事件
    ui.registerSwallowTouch({node = self})

    -- 背景大小
    self.mBgSize = cc.size(550, 740)

    local popBgLayer = require("commonLayer.PopBgLayer").new({
		bgSize = self.mBgSize,
		title = TR("规则"),
		closeAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self:addChild(popBgLayer)

	-- 背景对象
	self.mBgSprite = popBgLayer.mBgSprite

    -- 初始化UI
    self:initUI()
end

function KillerValleyRuleLayer:initUI()
	self:createTabLayer()
end

-- 创建页签控件
function KillerValleyRuleLayer:createTabLayer()
	local tabList = {
		{
			text = TR("图文规则"),
			tag = RuleDescTag.ePictureDesc,
		},
		{
			text = TR("文字规则"),
			tag = RuleDescTag.eTextDesc,
		},
	}

	local tabViewLayer = ui.newTabLayer({
			btnInfos = tabList,
			viewSize = cc.size(self.mBgSize.width*0.92, 80),
			onSelectChange = function (selectBtnTag)
				self:refreshTabLayer(selectBtnTag)
			end,
		})
	tabViewLayer:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-100)
	self.mBgSprite:addChild(tabViewLayer)
end

-- 点击页签切换页面
function KillerValleyRuleLayer:refreshTabLayer(selectTag)
	if self.mCurLayer then
		self.mCurLayer:setVisible(false)
	end

	if selectTag == RuleDescTag.ePictureDesc then
		self.mCurLayer = self:createPictrueLayer()
	elseif selectTag == RuleDescTag.eTextDesc then
		self.mCurLayer = self:createTextLayer()
	end
end

-- 创建图片描述页签
function KillerValleyRuleLayer:createPictrueLayer()
	-- 判断是否创建过，不在重复创建（页面不刷新）
	if not self.mPictrueLayer or tolua.isnull(self.mPictrueLayer) then
		self.mPictrueLayer = cc.Node:create()
		self.mPictrueLayer:setPosition(0, 0)
		self.mBgSprite:addChild(self.mPictrueLayer)

		-- 页面显示的图
		local showTextureList = {
			{
				texture = "gg_12.png",
				title = TR("技能释放"),
				text = TR("触摸右下角的飞刀或冰魄银针按钮，会有小圈出现，向相应方向滑动手指可以释放飞刀，若不想释放飞刀，则滑动手指到取消施放处。"),
			},
			{
				texture = "gg_13.png",
				title = TR("小地图"),
				text = TR("白色小点表示侠客自己，小地图上面会有红色和蓝色两个圈，蓝圈表示情花瘴即将蔓延的区域，红圈表示情花瘴已经蔓延的区域，注意仔细观察小地图上面的情花毒圈，小心中毒哦！"),
			},
			{
				texture = "gg_14.png",
				title = TR("移动"),
				text = TR("触摸地图上空白位置，触发触控按钮，滑动小白圈控制侠客移动。"),
			},
		}

		-- 初始化索引控制
		self.curPictrueIndex = 1

		-- 创建滑动窗口控件
		local itemSize = cc.size(self.mBgSize.width*0.92, self.mBgSize.height*0.78)
		local spriteView = ui.newSliderTableView({
				width = itemSize.width,
				height = itemSize.height,
				isVertical = false,
				selItemOnMiddle = true,
				selectIndex = self.curPictrueIndex-1,
				itemCountOfSlider = function(sliderView)
					return #showTextureList
				end,
				itemSizeOfSlider = function(sliderView)
				    return itemSize.width, itemSize.height
				end,
				sliderItemAtIndex = function(sliderView, itemNode, index)
		        	-- 模板
		    		local stencilNode = cc.LayerColor:create(cc.c4b(255, 0, 0, 255))
		    		stencilNode:setIgnoreAnchorPointForPosition(false)
		    		stencilNode:setAnchorPoint(cc.p(0.5, 0.5))
		    		stencilNode:setContentSize(itemSize)
		    		stencilNode:setPosition(itemSize.width*0.5, itemSize.height*0.5)
		    		-- 裁剪节点
		    		local clipNode = cc.ClippingNode:create()
		    		clipNode:setContentSize(itemSize)
		    		clipNode:setAlphaThreshold(1.0)
		    		clipNode:setStencil(stencilNode)
		    		itemNode:addChild(clipNode)
		    		-- 显示图
					local descSprite = ui.newSprite(showTextureList[index+1].texture)
					descSprite:setPosition(itemSize.width*0.5, itemSize.height*0.5)
					clipNode:addChild(descSprite)
					-- 题目
					local titleLabel = ui.newLabel({
							text = showTextureList[index+1].title,
							color = Enums.Color.eWhite,
							outlineColor = Enums.Color.eOutlineColor,
						})
					titleLabel:setAnchorPoint(cc.p(0, 1))
					titleLabel:setPosition(3, descSprite:getContentSize().height*0.44)
					descSprite:addChild(titleLabel)
					-- 介绍文字
					local descLabel = ui.newLabel({
							text = showTextureList[index+1].text,
							color = Enums.Color.eWhite,
							outlineColor = Enums.Color.eOutlineColor,
							dimensions = cc.size(descSprite:getContentSize().width-20, 0),
						})
					descLabel:setAnchorPoint(cc.p(0, 1))
					descLabel:setPosition(10, descSprite:getContentSize().height*0.38)
					descSprite:addChild(descLabel)
				end,
				selectItemChanged = function(sliderView, selectIndex)
					-- 更新索引
					self.curPictrueIndex = selectIndex + 1

					-- 更新小点状态
					for i = 1, #showTextureList do
						Notification:postNotification(PointChangeEvent..i)
					end
				end,
			})
		spriteView:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.42+5)
		self.mPictrueLayer:addChild(spriteView)

		-- 小点节点的参数
		local space = 30	-- 点间间隔
		local length = (#showTextureList - 1) * space
		local ctrlSize = cc.size(length, 20)
		-- 创建小点父节点
		local ctrlPointParent = cc.Node:create()
		ctrlPointParent:setAnchorPoint(cc.p(0.5, 0.5))
		ctrlPointParent:setContentSize(ctrlSize)
		ctrlPointParent:setPosition(itemSize.width*0.5, itemSize.height*0.05)
		spriteView:addChild(ctrlPointParent)
		-- 创建小点函数
		local function createCtrlPoint(index)
			-- 小点是按钮控件
			local pointBtn = ui.newButton({
					normalImage = index == self.curPictrueIndex and "jqg_21.png" or "jqg_23.png",
					clickAction = function ()
						if self.curPictrueIndex == index then
							return
						end
						-- 点击小点刷新图片显示
						spriteView:setSelectItemIndex(index-1, true)
					end,
				})
			pointBtn:setPosition((index-1)*space, 0)
			ctrlPointParent:addChild(pointBtn)

			-- 小点修改状态图函数
			local function changeState()
				if self.curPictrueIndex == index then
					pointBtn:loadTextures("jqg_21.png", "jqg_21.png")
				else
					pointBtn:loadTextures("jqg_23.png", "jqg_23.png")
				end
			end

			-- 注册小点状态改变事件
			Notification:registerAutoObserver(pointBtn, changeState, PointChangeEvent..index)
		end

		-- 循环创建小点
		for i = 1, #showTextureList do
			createCtrlPoint(i)
		end

	end

	-- 显示图片页面
	self.mPictrueLayer:setVisible(true)

	return self.mPictrueLayer
end

-- 创建文字描述页签
function KillerValleyRuleLayer:createTextLayer()
	-- 判断是否创建过，不在重复创建（页面不刷新）
	if not self.mTextLayer or tolua.isnull(self.mTextLayer) then
		self.mTextLayer = cc.Node:create()
		self.mTextLayer:setPosition(0, 0)
		self.mBgSprite:addChild(self.mTextLayer)

		-- 文字描述列表
		local textList = {
			TR("1.点击选择侠客选择一名侠客与你一同进入绝情谷，每次比赛结束都会重新选择侠客。"),
			TR("2.点击开始匹配进入绝情谷。"),
			TR("3.绝情谷可以根据每日获得的积分领取每日奖励。"),
			TR("4.排行榜根据玩家胜场数排行，若胜场数相同，则根据积分排名。"),
			TR("5.点击战绩可以查看你每局的战绩。"),
			TR("6.使用情花可以在商店购买道具，情花从每日奖励和排行奖励获得。"),
			TR("7.绝情谷一名侠客代表一条生命，招募更多的探子你在绝情谷中才会更加安全。"),
			TR("8.绝情谷道具种类："),
			TR("①飞刀：命中玩家损失一条生命。"),
			TR("②冰魄银针：命中玩家损失两条生命"),
			TR("③情花刺：陷阱，放置之后玩家触发损失一条生命。"),
			TR("④九花玉露丸：回满侠客血量。"),
			TR("⑤强体丸：使用之后40秒内攻击防御翻倍。"),
			TR("⑥夜行衣：隐身15秒。"),
			TR("9.绝情谷中有情花瘴不停的蔓延，情花瘴中侠客会中毒，持续损失血量。"),
			TR("10.开局一把刀，搜集更多侠客，更多的道具，击败其他9名侠客才能取得胜利。"),
			TR("11.每周为一个赛季，每周一凌晨1点20发奖。"),
		}

		local listSize = cc.size(self.mBgSize.width*0.8, self.mBgSize.height*0.75)
		-- 列表背景
		local bgSprite = ui.newScale9Sprite("c_17.png", cc.size(listSize.width+40, listSize.height+24))
		bgSprite:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.43)
		self.mTextLayer:addChild(bgSprite)
		-- 创建列表控件
		local textListView = ccui.ListView:create()
		textListView:setDirection(ccui.ScrollViewDir.vertical)
		textListView:setBounceEnabled(true)
		textListView:setItemsMargin(5)
		textListView:setContentSize(listSize)
		textListView:setAnchorPoint((cc.p(0.5, 0.5)))
		textListView:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.42)
		self.mTextLayer:addChild(textListView)

		local maxHeight = 0	-- 记录列表内容总长度
		-- 填充列表
		for _, text in ipairs(textList) do
			local cellItem = ccui.Layout:create()
			textListView:pushBackCustomItem(cellItem)

			-- 描述文字
			local descLabel = ui.newLabel({
					text = text,
					color = cc.c3b(0x46, 0x22, 0x0d),
	                dimensions = cc.size(listSize.width, 0),
				})
			descLabel:setAnchorPoint(cc.p(0, 0.5))

			-- 获取大小
			local labelSize = descLabel:getContentSize()
			cellItem:setContentSize(labelSize)

			-- 设置文字位置
			descLabel:setPosition(0, labelSize.height / 2)
            cellItem:addChild(descLabel)

            maxHeight = maxHeight + labelSize.height
		end

		if maxHeight < listSize.height then
            textListView:setTouchEnabled(false)
        end
	end

	self.mTextLayer:setVisible(true)

	return self.mTextLayer
end

return KillerValleyRuleLayer