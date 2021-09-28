--[[
    SectBookLayer.lua
    描述: 藏经阁
    创建人: yanghongsheng
    创建时间: 2017.8.26
-- ]]

local SectBookLayer = class("SectBookLayer", function()
    return display.newLayer()
end)

function SectBookLayer:ctor()
	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 当前门派id
    self.curSectId = SectObj:getPlayerSectInfo().SectId
    -- 当前声望等级
    self.curRank = SectObj:getPlayerSectInfo().SectRank
    -- 当前拥有可兑换声望
    self.curSectCoin = SectObj:getPlayerSectInfo().SectCoin
    -- 上部滑动控件大小
    self.sliderSize = cc.size(583,178)
    -- 当前买到第i个book
    self.curHaveShopOrder = 0

    -- 获取表中数据
    self:initTableData()

    -- 请求服务器数据
    self:requsetInfo()
end
 -- 获取表中数据
function SectBookLayer:initTableData()
	-- 当前门派绝学信息
	local sectInfo = SectModel.items[self.curSectId]
	local fashionInfoList = Utility.analysisStrResList(sectInfo.fashionInfo)
	-- 绝学列表
	self.fashionInfoList = {}
	for _, v in pairs(fashionInfoList) do
		local item = {}
		item.fashionId = v.resourceTypeSub						-- 绝学id
		item.needPstLv = v.modelId								-- 需求声望等级
		item.usePst = v.num										-- 消耗声望
		item.intro = FashionModel.items[v.resourceTypeSub].intro	-- 绝学简介
		item.prPic = FashionModel.items[v.resourceTypeSub].skillIcon	-- 绝学图
		item.name = FashionModel.items[v.resourceTypeSub].name	-- 绝学名
        item.RAID = FashionModel.items[v.resourceTypeSub].RAID  -- 技攻id

		table.insert(self.fashionInfoList, clone(item))
	end
	-- 商品列表
	self.shopList = {}
	for _, v in pairs(SectShopModel.items) do
		if v.sectModelID == self.curSectId then
			table.insert(self.shopList, clone(v))
		end
	end
	-- 绝学学习按钮列表
	self.learnBtnList = {}
end

function SectBookLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("mp_15.png")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 创建绝学list
	if next(self.fashionInfoList) then
		self.fashionSliderView = self:createSliderView()
		self.fashionSliderView:setPosition(320, 860)
		self.mParentLayer:addChild(self.fashionSliderView)
	end

	-- book列表背景
	local listBgSize = cc.size(578, 614)
	local listBg = ui.newScale9Sprite("c_97.png", listBgSize)
    listBg:setPosition(320, 430)
    self.mParentLayer:addChild(listBg)
    -- book列表
    local bookListView = ccui.ListView:create()
    bookListView:setDirection(ccui.ScrollViewDir.vertical)
    bookListView:setBounceEnabled(true)
    bookListView:setContentSize(cc.size(567, listBgSize.height-10))
    bookListView:setItemsMargin(6)
    bookListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    bookListView:setAnchorPoint(cc.p(0.5, 0.5))
    bookListView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
    listBg:addChild(bookListView)
    self.bookListView = bookListView

    -- 上箭头
    local upArrowSprite = ui.newSprite("c_26.png")
    upArrowSprite:setRotation(-90)
    upArrowSprite:setPosition(listBgSize.width*0.5, listBgSize.height)
    listBg:addChild(upArrowSprite)
    -- 下箭头
    local downArrowSprite = ui.newSprite("c_26.png")
    downArrowSprite:setRotation(90)
    downArrowSprite:setPosition(listBgSize.width*0.5, 0)
    listBg:addChild(downArrowSprite)

    -- 学习绝学提示
    local hintLabel = ui.newLabel({
            text = TR("学完全部招式才能学习绝学"),
            color = cc.c3b(0x46, 0x22, 0x0d),
            size = 22,
        })
    hintLabel:setAnchorPoint(cc.p(1, 0))
    hintLabel:setPosition(600, 740)
    self.mParentLayer:addChild(hintLabel)

    -- 当前可用声望
    local useCoinLabel = ui.newLabel({
            text = TR("当前可用声望: %s%d", "#258711", SectObj:getPlayerSectInfo().SectCoin),
            size = 22,
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    useCoinLabel:setAnchorPoint(cc.p(0, 0))
    useCoinLabel:setPosition(35, 740)
    self.mParentLayer:addChild(useCoinLabel)
    -- 刷新声望函数
    useCoinLabel.refreshLabel = function ()
        useCoinLabel:setString(TR("当前可用声望: %s%d", "#258711", SectObj:getPlayerSectInfo().SectCoin))
    end
    self.useCoinLabel = useCoinLabel

    -- 返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 960),
        clickAction = function ()
        	LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(closeBtn)
    -- 初始化book列表
    self:refreshShopView()
end

--创建滑动控件
function SectBookLayer:createSliderView()
    -- 滑动控件
	local fashionSliderView = ui.newSliderTableView({
		width = self.sliderSize.width,
		height = self.sliderSize.height,
		isVertical = false,
        selItemOnMiddle = true,
        selectIndex = 0,
        itemCountOfSlider = function(sliderView)
            return #self.fashionInfoList
        end,
        itemSizeOfSlider = function(sliderView)
            return self.sliderSize.width, self.sliderSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
			self:createOneFashion(itemNode, index+1)
    	end,
        selectItemChanged = function(sliderView, selectIndex)
            self:refreshItem(selectIndex + 1)
        end
	})


    return fashionSliderView
end

function SectBookLayer:createOneFashion(parent, index)
	local fashionData = self.fashionInfoList[index]
    -- 背景
    local bgSprite = ui.newScale9Sprite("mp_71.png", self.sliderSize)
    bgSprite:setPosition(self.sliderSize.width*0.5, self.sliderSize.height*0.5)
    parent:addChild(bgSprite)
    -- 图框
    local boxSprite = ui.newScale9Sprite("c_31.png", cc.size(118, 118))
    boxSprite:setPosition(self.sliderSize.width*0.15, self.sliderSize.height*0.5)
    parent:addChild(boxSprite)
	-- 绝学图
    local fashionCard = require("common.CardNode").new({
                allowClick = true,
                onClickCallback = function()
                    self:showSkillDlg(fashionData.RAID, true, cc.p(400, 920))
                end
            })
    fashionCard:setScale(1.2)
    fashionCard:setPosition(self.sliderSize.width*0.15, self.sliderSize.height*0.5)
    fashionCard:setSkillAttack({modelId = fashionData.RAID, icon = fashionData.prPic .. ".png", notShowSkill = true}, {CardShowAttr.eBorder})
    parent:addChild(fashionCard)
    -- 绝学标签
    local jueXueLabelSprite = ui.newSprite("mp_51.png")
    jueXueLabelSprite:setPosition(self.sliderSize.width*0.25, self.sliderSize.height*0.6)
    parent:addChild(jueXueLabelSprite)
	-- 绝学名
    local quality = FashionModel.items[fashionData.fashionId].quality
    local jueXueColor = Utility.getQualityColor(quality, 1)
	local nameLabel = ui.newLabel({
			text = fashionData.name,
			size = 24,
			color = jueXueColor,
            outlineColor = cc.c3b(0x17, 0x34, 0x4d),
		})
	nameLabel:setAnchorPoint(cc.p(0, 0))
	nameLabel:setPosition(self.sliderSize.width*0.52, self.sliderSize.height*0.72)
	parent:addChild(nameLabel)
	-- 绝学简介
    local infoLabel = ui.newLabel({
            text = fashionData.intro,
            size = 20,
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x17, 0x34, 0x4d),
            dimensions = cc.size(self.sliderSize.width*0.64, 0),
        })
    infoLabel:setAnchorPoint(cc.p(0, 0))
    infoLabel:setPosition(self.sliderSize.width*0.33, self.sliderSize.height*0.26)
    parent:addChild(infoLabel, 1)
	-- 消耗声望
	local usePrestigeLabel = ui.newLabel({
			text = TR("消耗%d声望", fashionData.usePst),
			size = 20,
			color = Enums.Color.eOrange, -- cc.c3b(0x25, 0x87, 0x11),
            outlineColor = cc.c3b(0x17, 0x34, 0x4d),
		})
	usePrestigeLabel:setAnchorPoint(cc.p(0, 0))
	usePrestigeLabel:setPosition(self.sliderSize.width*0.33, self.sliderSize.height*0.08)
	parent:addChild(usePrestigeLabel)
	-- 学习按钮
	local learnBtn = ui.newButton({
			text = TR("学习"),
			normalImage = "c_59.png",
			clickAction = function ()
				self:requsetExchangeFashion(self.curSectId, fashionData.fashionId, index)
			end,
		})
	learnBtn:setPosition(self.sliderSize.width*0.88, self.sliderSize.height*0.2)
	parent:addChild(learnBtn)

	-- 代币不够，禁用学习
	if self.curSectCoin < fashionData.usePst then
		learnBtn:setEnabled(false)
	end
	-- 加入绝学兑换按钮列表
	self.learnBtnList[index] = learnBtn
end
-- 创建绝学简介控件
function SectBookLayer:createFashionIntro(fashionInfo)
    -- 创建listview，用于限定显示区的大小
    local infolistView = ccui.ListView:create()
    infolistView:setDirection(ccui.ListViewDirection.vertical)
    infolistView:setBounceEnabled(true)
    infolistView:setAnchorPoint(cc.p(0, 1))
    infolistView:setContentSize(self.sliderSize.width*0.65, self.sliderSize.height*0.3)
    -- 创建列表项
    local itemLayout = ccui.Layout:create()
    -- 显示文字
    local infoLabel = ui.newLabel({
            text = fashionInfo.intro,
            size = 20,
            color = Enums.Color.eWhite,
            outlineColor = cc.c3b(0x17, 0x34, 0x4d),
            dimensions = cc.size(self.sliderSize.width*0.64, 0),
        })
    infoLabel:setAnchorPoint(cc.p(0.5, 0.5))
    local textSize = infoLabel:getContentSize()
    infoLabel:setPosition(textSize.width*0.5, textSize.height*0.5)
    itemLayout:addChild(infoLabel)
    -- 设置项大小为label大小
    itemLayout:setContentSize(textSize)
    -- 加入列表
    infolistView:pushBackCustomItem(itemLayout)
    -- 返回列表
    return infolistView
end
-- 创建时装的技能介绍框
function SectBookLayer:showSkillDlg(modelId, isSkill, pos)
    local dlgBgNode = cc.Node:create()
    self.mParentLayer:addChild(dlgBgNode, 1)

    -- 背景图
    local dlgBgSprite = ui.newSprite("zr_53.png")
    local dlgBgSize = dlgBgSprite:getContentSize()
    dlgBgSprite:setAnchorPoint(cc.p(1, 1))
    dlgBgSprite:setPosition(pos)
    dlgBgNode:addChild(dlgBgSprite)

    -- 技能图标
    local skillIcon = "c_71.png"
    if (isSkill ~= nil) and (isSkill == true) then
        skillIcon = "c_70.png"
    end
    local skillSprite = ui.newSprite(skillIcon)
    skillSprite:setAnchorPoint(cc.p(0, 0.5))
    skillSprite:setPosition(20, dlgBgSize.height - 40)
    dlgBgSprite:addChild(skillSprite)

    -- 技能名字
    local itemData = AttackModel.items[modelId] or {}
    local nameLabel = ui.newLabel({
        text = itemData.name or "",
        color = Enums.Color.eNormalYellow,
        size = 24,
    })
    nameLabel:setAnchorPoint(cc.p(0, 0.5))
    nameLabel:setPosition(58, dlgBgSize.height - 40)
    dlgBgSprite:addChild(nameLabel)

    -- 技能描述
    local attackList = string.splitBySep(itemData.intro or "", "#73430D")
    local attackText = ""
    for _,v in ipairs(attackList) do
        attackText = attackText .. Enums.Color.eNormalWhiteH .. v
    end
    local introLabel = ui.newLabel({
        text = attackText,
        color = Enums.Color.eNormalWhite,
        size = 22,
        align = ui.TEXT_ALIGN_LEFT,
        valign = ui.TEXT_VALIGN_TOP,
        dimensions = cc.size(dlgBgSize.width - 40, 0)
    })
    introLabel:setAnchorPoint(cc.p(0, 1))
    introLabel:setPosition(20, dlgBgSize.height - 70)
    dlgBgSprite:addChild(introLabel)

    -- 注册触摸关闭
    ui.registerSwallowTouch({
        node = dlgBgNode,
        allowTouch = true,
        endedEvent = function(touch, event)
            dlgBgNode:removeFromParent()
        end
        })
end
-- 更新滑动控件当前项
function SectBookLayer:refreshItem(index)
	local fashionData = self.fashionInfoList[index]
    -- 代币不够，禁用学习
	if self.curRank > fashionData.needPstLv or self.curSectCoin < fashionData.usePst then
		self.learnBtnList[index]:setEnabled(false)
	end
end
-- 更新book列表
function SectBookLayer:refreshShopView()
	-- 清除原来数据
	self.bookListView:removeAllChildren()
	-- 列数
    local colNum = 3
    -- 行数
    local rowNum = math.ceil(#self.shopList / colNum)
    -- 一项宽度
    local itemWidth = self.bookListView:getContentSize().width
    -- 一项高度
    local itmeHeight = 300
    -- 间隔
    local interval = itemWidth/colNum
    -- 遍历列表
    for i = 0, rowNum - 1 do
        -- 创建项
        local cellItem = ccui.Layout:create()
        cellItem:setContentSize(cc.size(itemWidth, itmeHeight))
        self.bookListView:pushBackCustomItem(cellItem)
        -- 背景
        local cellBg = ui.newScale9Sprite("c_96.png", cc.size(itemWidth, 80))
        cellBg:setPosition(itemWidth*0.5, -20)
        cellItem:addChild(cellBg)
        -- 道具
        for j = 1, colNum do
            -- 边界检查
            local index = i*colNum + j
            if index > #self.shopList then break end
            -- cell 数据
            local cellData = self.shopList[index]
            cellData.res = Utility.analysisStrResList(cellData.sellStr)[1]
            -- 背景
            local cellBg = ui.newSprite("mp_16.png")
            cellBg:setPosition(interval*j-100, itmeHeight*0.5)
            cellItem:addChild(cellBg)
            local cellSize = cellBg:getContentSize()
            -- 名字
            local cellName = ui.newLabel({
            		text = Utility.getGoodsName(cellData.res.resourceTypeSub, cellData.res.modelId),
            		size = 24,
            		color = Enums.Color.eWhite,
            	})
            cellName:setAnchorPoint(cc.p(0.5, 0.5))
            cellName:setPosition(cellSize.width*0.5, cellSize.height*0.88)
            cellBg:addChild(cellName)
            -- 创建卡
            local cardParams = cellData.res
            cardParams.cardShowAttrs = {CardShowAttr.eBorder}
            local card = CardNode.createCardNode(cardParams)
            card:setPosition(cellSize.width*0.5, cellSize.height*0.6)
            card:setSwallowTouches(false)
            cellBg:addChild(card)
            -- 消耗声望
            local usePstColor = "#258711"
            if self.curSectCoin <  cellData.price then
                usePstColor = Enums.Color.eRedH
            end
            local usePstLabel = ui.newLabel({
            		text = TR("消耗%s%d%s声望", usePstColor, cellData.price, "#258711"),
            		color = cc.c3b(0x25, 0x87, 0x11),
            		size = 20,
            	})
            usePstLabel:setAnchorPoint(cc.p(0.5, 0.5))
            usePstLabel:setPosition(cellSize.width*0.5, cellSize.height*0.35)
            cellBg:addChild(usePstLabel)
            -- 需要等级
            local rankColor = "#b96237"
            if self.curRank >  cellData.needRankMin then
                rankColor = Enums.Color.eRedH
            end
            local needRankLabel = ui.newLabel({
            		text = TR("%s%s%s可学习", rankColor, SectRankModel.items[cellData.needRankMin].name, "#b96237"),
            		color = cc.c3b(0xb9, 0x62, 0x37),
            		size = 20,
            	})
            needRankLabel:setAnchorPoint(cc.p(0.5, 0.5))
            needRankLabel:setPosition(cellSize.width*0.5, cellSize.height*0.25)
            cellBg:addChild(needRankLabel)
            -- 学习按钮
            local learnBtn = ui.newButton({
            		normalImage = "c_28.png",
            		text = TR("学习"),
            		clickAction = function ()
                        self:requsetExchangeBook(cellData.ID)
            		end,
            	})
            learnBtn:setScale(0.8)
            learnBtn:setPosition(cellSize.width*0.5, cellSize.height*0.1)
            cellBg:addChild(learnBtn)
            -- 是否禁用
            if (cellData.TotalBuyCount and cellData.TotalBuyCount >= 1 and cellData.ifBuyOne == 1) then
            	learnBtn:removeFromParent()
                local alreadyLearnLabel = ui.createSpriteAndLabel({
                        imgName = "c_156.png",
                        labelStr = TR("已学习"),
                        fontSize = 24,
                    })
                alreadyLearnLabel:setPosition(cellSize.width*0.5, cellSize.height*0.1)
                cellBg:addChild(alreadyLearnLabel)
            elseif self.curRank > cellData.needRankMin or self.curSectCoin < cellData.price or index > 1 then
            	learnBtn:setEnabled(false)
            end

        end
    end
end
-- 更新book数据表
function SectBookLayer:refreshShopList(serverData)
	-- 临时表（中转）
	local tempTab = {}
	-- 将book表中信息拷入
	for _, v in pairs(self.shopList) do
		tempTab[v.ID] = clone(v)
	end
	-- 清空book数据表
	self.shopList = {}
	-- 将服务器返回信息加入列表
    for _, val in pairs(serverData) do
    	local tempItem = tempTab[val.ShopId]
        if tempItem then
            -- 重填book数据表
        	tempItem.TotalBuyCount = val.TotalBuyCount
        	table.insert(self.shopList, tempItem)
            -- 找到当前购买book的最大序号
            if tempItem.TotalBuyCount >= tempItem.ifBuyOne then
                if self.curHaveShopOrder then
                    self.curHaveShopOrder = tempItem.orderNum > self.curHaveShopOrder and tempItem.orderNum or self.curHaveShopOrder
                else
                    self.curHaveShopOrder = tempItem.orderNum
                end
            end
        end
    end
    -- 是否可兑换book
    local function isCanExchang(bookData)
    	if self.curRank > bookData.needRankMin or self.curSectCoin < bookData.price then
    		return false
    	else
    		return true
    	end
    end
    -- 是否已兑换
    local function isAlreadyExchang(bookData)
        if bookData.TotalBuyCount >= bookData.ifBuyOne then
            return true
        end
        return false
    end
    -- 排序
	table.sort(self.shopList, function (item1, item2)
		-- 若没有获取到TotalBuyCount，按正常序号排序
		if not item1.TotalBuyCount then
			return item1.orderNum > item2.orderNum
		else
			-- 是否已经兑换
            local isAlreadyExchang1 = isAlreadyExchang(item1)
            local isAlreadyExchang2 = isAlreadyExchang(item2)
            if isAlreadyExchang1 ~= isAlreadyExchang2 then
                return not isAlreadyExchang1
            end
			-- 按序号排序
			return item1.orderNum < item2.orderNum
		end
	end)
end

function SectBookLayer:refreshFashionList(serverData)
	-- 临时表（中转）
	local tempTab = {}
	-- 将绝学表中信息拷入
	for _, v in pairs(self.fashionInfoList) do
		tempTab[v.fashionId] = clone(v)
	end
	-- 清空绝学表
	self.fashionInfoList = {}
	-- 将服务器返回信息加入列表
    for _, serverItem in pairs(serverData) do
    	local tempItem = tempTab[serverItem.FashionModelId]
        if tempItem then
        	tempItem.IsExchange = serverItem.IsExchange
        	table.insert(self.fashionInfoList, tempItem)
        end
    end
end

-- 播放学习特效
function SectBookLayer:playEffect(callback)
    -- 播放音效
    MqAudio.playEffect("zhaomu.mp3")
    -- 播放特效
    ui.newEffect({
            parent = self.mParentLayer,
            effectName = "effect_ui_waigongfanye",
            position = cc.p(320, 568),
            loop = false,
            endRelease = true,
            endListener = function ()
                if callback then
                    callback()
                end
            end,
        })
end

-- 去装备招式弹窗
function SectBookLayer:createSkipLayer(moduleSub, modelId)
    local name = ""
    local data = {}
    local nameColor = ""
    local hintText = ""
    if moduleSub == ModuleSub.eFashion then
        name = FashionModel.items[modelId].name
        nameColor = Utility.getColorValue(FashionModel.items[modelId].colorLV, 2)
        hintText = TR("已学习绝学%s%s%s，是否立即前往上阵？", nameColor, name, Enums.Color.eNormalWhiteH)
    elseif moduleSub == ModuleSub.eHeroChoiceTalent then
        local resStr = SectShopModel.items[modelId].sellStr
        local zhaoshiModelId = Utility.analysisStrResList(resStr)[1].modelId
        name = SectBookModel.items[zhaoshiModelId].name
        nameColor = Utility.getColorValue(SectBookModel.items[zhaoshiModelId].valueLv, 2)
        data = {selectTalentIdx = SectBookModel.items[zhaoshiModelId].TALLayerNum}
        hintText = TR("已学习招式%s%s%s，是否立即前往装备？", nameColor, name, Enums.Color.eNormalWhiteH)
        -- 如果是功法返回
        if SectBookModel.items[zhaoshiModelId].TALModelID == 0 then
            return
        end
    end

    MsgBoxLayer.addOKLayer(
        hintText,
        TR("提示"),
        {
            {
                text = TR("确定"),
                clickAction = function ()
                    LayerManager.showSubModule(moduleSub, data)
                end,
            }
        },
        {}
    )
end

--------------服务器相关-------------
-- 请求数据
function SectBookLayer:requsetInfo()
	HttpClient:request({
        moduleName = "SectInfo",
        methodName = "GetSectShopInfo",
        svrMethodData = {},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- dump(response.Value)
            -- 刷新book表数据
            self:refreshShopList(response.Value.CurrentSectShopInfo)
            -- 刷新绝学表数据
            self:refreshFashionList(response.Value.FashionInfo)
            -- 初始化界面
    		self:initUI()
        end
    })
end

-- 兑换绝学
function SectBookLayer:requsetExchangeFashion(sectId, fashionId, index)
    SectObj:requsetExchangeFashion(sectId, fashionId, function (response)
        -- 更新绝学缓存
        FashionObj:refreshFashionList()
        -- 刷新绝学表数据
        self:refreshFashionList(response.Value.FashionInfo)
        -- 更新拥有可兑换声望
        self.curSectCoin = SectObj:getPlayerSectInfo().SectCoin

        self:playEffect(function ()
            -- 飘窗显示获取绝学
            ui.ShowRewardGoods(response.Value.getGameResourceObjectList)
            -- 刷新项
            self:refreshItem(index)
            -- 刷新可兑换声望显示
            self.useCoinLabel.refreshLabel()
            -- 跳转弹窗
            self:createSkipLayer(ModuleSub.eFashion, fashionId)
        end)
    end)
	       
end

-- 兑换招式
function SectBookLayer:requsetExchangeBook(shopId)
    SectObj:requsetExchangeBook(shopId, function (response)
        self:playEffect(function ()
            -- ui.showFlashView({text = TR("学习成功")})
            -- 刷新book表数据
            self:refreshShopList(response.Value.CurrentSectShopInfo)
            -- 更新拥有可兑换声望
            self.curSectCoin = SectObj:getPlayerSectInfo().SectCoin
            -- 刷新book列表
            self:refreshShopView()
            -- 刷新可兑换声望显示
            self.useCoinLabel.refreshLabel()
            -- 跳转弹窗
            self:createSkipLayer(ModuleSub.eHeroChoiceTalent, shopId)
        end)
    end)
end

return SectBookLayer