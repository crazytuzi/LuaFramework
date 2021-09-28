--[[
	文件名：ZhenYuanLvUpLayer.lua
	描述：真元升级界面
	创建人：yanghongsheng
	创建时间： 2017.12.16
--]]

local ZhenYuanLvUpLayer = class("ZhenYuanLvUpLayer", function()
	return display.newLayer()
end)

--[[
-- 参数 params 中的各项为:
	{
		zhenyuanList: 	要升级的真元实例id列表(必须)
		currIndex:		当前选择真元的索引(默认 1)
	}
]]

function ZhenYuanLvUpLayer:ctor(params)
	-- 真元实例id列表
	self.mZhenyuanList = params.zhenyuanList
	self.currIndex = params.currIndex or 1
	-- 选择列表(要用来消耗升级当前真元的列表)
	self.mSelectList = {}
	-- 屏蔽下层触摸
	ui.registerSwallowTouch({node = self})
	-- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {ResourcetypeSub.eHeroCoin, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
    self.mCommonLayer_ = tempLayer

    -- 初始化
    self:initUI()
end

function ZhenYuanLvUpLayer:initUI()
	local bgSprite = ui.newSprite("zy_16.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 添加黑底
	local decBgSize = cc.size(640, 160)
	local decBg = ui.newScale9Sprite("c_73.png", decBgSize)
	decBg:setPosition(cc.p(320, 1070))
	self.mParentLayer:addChild(decBg)

	-- 显示升级页签
	self:showTabLayer()

	-- 下面背景
	local downBg = ui.newScale9Sprite("c_19.png", cc.size(640, 620))
	downBg:setAnchorPoint(cc.p(0.5, 0))
	downBg:setPosition(320, 0)
	self.mParentLayer:addChild(downBg)

	-- 创建真元大图滑窗
	self:createZhenyuanView()

	-- 初始化真元信息
	self:refreshZhenyuanInfo()

	-- 初始化真元列表
	self:refreshGrid()

	-- 创建界面按钮
	self:createBtnList()

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
function ZhenYuanLvUpLayer:showTabLayer()
    -- 创建分页
    local buttonInfos = {
        {
            text = TR("聚气"),
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

-- 整理选择数据与一键选择匹配
function ZhenYuanLvUpLayer:dealSelectBox()
	if not self.mSelectList then return end

	for id, isSelect in pairs(self.mSelectList) do
		if isSelect then
			local zhenyuanInfo = ZhenyuanObj:getZhenyuan(id)
			local zhenyuanModel = ZhenyuanModel.items[zhenyuanInfo.ModelId]
			local valueLv = Utility.getQualityColorLv(zhenyuanModel.quality)

			if zhenyuanModel.type == 0 then	-- 经验真元
				self.mSelectStatus[1] = true
				self.mBoxSelectList[1] = self.mBoxSelectList[1] or {}
				table.insert(self.mBoxSelectList[1], id)
			else
				self.mSelectStatus[valueLv] = true
				self.mBoxSelectList[valueLv] = self.mBoxSelectList[valueLv] or {}
				table.insert(self.mBoxSelectList[valueLv], id)
			end
		end
	end
end

-- 创建品质选择盒
function ZhenYuanLvUpLayer:oneKeyBox()
    --保存菜单选择状态
    self.mSelectStatus = {
        [1] = false, 	-- 经验
        [2] = false,    -- 绿色
        [3] = false,    -- 蓝色
        [4] = false,    -- 紫色
        [5] = false,    -- 橙色
        [6] = false,    -- 红色
        [7] = false,    -- 金色
    }
    -- 保存一键选择的真元id
    self.mBoxSelectList = {}
    -- 整理选择数据与一键选择匹配
    self:dealSelectBox()
    -- 是否已打开选择盒
    if self.isOpenBox then return end
    self.isOpenBox = true
    -- 添加一个当前最上层的层
    local touchLayer = ui.newStdLayer()
    self:addChild(touchLayer, 999)
    -- 添加选择盒背景
    local selBgSprite = ui.newScale9Sprite("gd_01.png", cc.size(100, 100))
    selBgSprite:setAnchorPoint(0.5, 0)
    selBgSprite:setPosition(200, 170)
    selBgSprite:setScale(0.1)
    touchLayer:addChild(selBgSprite)
    -- 播放变大动画
    local scale = cc.ScaleTo:create(0.3, 1)
    selBgSprite:runAction(scale)
    -- 关闭选择盒
    local function closeBox()
        local callfunDelete = cc.CallFunc:create(function()
            touchLayer:removeFromParent()
            self.isOpenBox = false
        end)
        local scale = cc.ScaleTo:create(0.3, 0.1)
        selBgSprite:runAction(cc.Sequence:create(scale, callfunDelete))
    end
    -- 注册触摸监听关闭选择盒
    ui.registerSwallowTouch({
        node = touchLayer,
        allowTouch = true,
        endedEvent = function(touch, event)
            closeBox()
        end
    })

    -- 创建选择列表
    local function createCheckBoxList(cellSize)
        -- 列表view
        local selectList = ccui.ListView:create()
        selectList:setDirection(ccui.ScrollViewDir.vertical)
        -- 列表高度计数
        local listHight = 0

        for key, _ in pairs(self.mSelectStatus) do
            local layout = ccui.Layout:create()
            layout:setContentSize(cellSize)

            local cellSprite = ui.newScale9Sprite("zl_09.png", cc.size(cellSize.width, cellSize.height-5))
            cellSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            layout:addChild(cellSprite)

            local color = Utility.getColorValue(key, 1)
            local text = key == 1 and TR("经验真元") or TR("%s品质",Utility.getColorName(key))
            local checkBtn = ui.newCheckbox({
                text = text,
                isRevert = true,
                textColor = color,
                outlineColor = Enums.Color.eBlack,
                outlineSize = 2,
                callback = function(pSenderC)
                    layout.cancelOrSelect(not self.mSelectStatus[key], key)
                end
                })
            checkBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            layout:addChild(checkBtn)
            checkBtn:setCheckState(self.mSelectStatus[key])
            layout.checkBtn = checkBtn
            
            -- 透明按钮（点击列表项改变复选框状态）
            local touchBtn = ui.newButton({
                normalImage = "c_83.png",
                size = cellSize,
                clickAction = function()
                    layout.cancelOrSelect(not self.mSelectStatus[key], key)
                end
            })
            touchBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            cellSprite:addChild(touchBtn)

            -- 选择或取消
		    layout.cancelOrSelect = function (isSelect, valueLv)
				self.mBoxSelectList[valueLv] = self.mBoxSelectList[valueLv] or {}
				if isSelect then
					self.mBoxSelectList[valueLv] = self:oneKeyValueLvSelect(valueLv)
					if self.mBoxSelectList[valueLv] and next(self.mBoxSelectList[valueLv]) then
						layout.checkBtn:setCheckState(true)
						self.mSelectStatus[key] = true
						-- 更新显示
						self:refreshProgShow()
					else
						layout.checkBtn:setCheckState(false)
					end
				else
					layout.checkBtn:setCheckState(false)
					self.mSelectStatus[key] = false

					if self.mBoxSelectList[valueLv] then
						for _, zhenyuanId in pairs(self.mBoxSelectList[valueLv]) do
							self.mSelectList[zhenyuanId] = nil
						end

						self.mBoxSelectList[valueLv] = nil

						-- 更新显示
						self:refreshProgShow()
					end
				end

				
			end
            
            -- 加入列表
            selectList:pushBackCustomItem(layout)
            -- 列表长度计数
            listHight = listHight + cellSize.height
        end
        -- 设置列表大小
        selectList:setContentSize(cellSize.width, listHight+10)

        return selectList
    end
    -- 创建列表
    local selectListView = createCheckBoxList(cc.size(200, 50))
    local listSize = selectListView:getContentSize()
    -- 重设背景图大小
    local bgSize = cc.size(listSize.width+40, listSize.height+100)
    selBgSprite:setContentSize(bgSize)
    -- 设置列表位置
    selectListView:setAnchorPoint(cc.p(0.5, 0))
    selectListView:setPosition(bgSize.width*0.5, 60)
    selBgSprite:addChild(selectListView)

    -- 关闭按钮
    local closeButton = ui.newButton({
        normalImage = "zl_10.png",
        clickAction = function()
            touchLayer:removeFromParent()
            self.isOpenBox = false
        end
    })
    closeButton:setPosition(bgSize.width * 0.87, bgSize.height-25)
    selBgSprite:addChild(closeButton)

    -- 确定按钮
    local confirmButton = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确认"),
        clickAction = function()
            -- 关闭选择盒
            closeBox()
        end
    })
    confirmButton:setScale(0.9)
    confirmButton:setPosition(bgSize.width * 0.5, 40)
    selBgSprite:addChild(confirmButton)
end

function ZhenYuanLvUpLayer:createBtnList()
	local btnList = {
		-- 获取途径
        {
            normalImage = "tb_34.png",
            position = cc.p(590, 650),
			clickAction = function()
				local ModelId = ZhenyuanObj:getZhenyuan(self.mZhenyuanList[self.currIndex]).ModelId
				LayerManager.addLayer({
		            name = "hero.DropWayLayer",
		            data = {
		                resourceTypeSub = ResourcetypeSub.eZhenYuan,
		                modelId = ModelId,
		            },
		            cleanUp = false,
		        })
			end
        },
        -- 一键选择
        {
            normalImage = "c_28.png",
            text = TR("一键选择"),
            position = cc.p(200, 145),
            clickAction = function ()
                -- self:oneKeySelect()
                self:oneKeyBox()
            end,
        },
        -- 聚气
        {
            normalImage = "c_28.png",
            text = TR("聚气"),
            position = cc.p(450, 145),
            clickAction = function ()
            	-- 判断是否满级
            	local zhenyuanInfo = ZhenyuanObj:getZhenyuan(self.mZhenyuanList[self.currIndex])
            	if not ZhenyuanLvUpRelation.items[zhenyuanInfo.Lv+1] then
            		ui.showFlashView({text = TR("已满级")})
            		return
            	end
            	-- 消耗真元列表
            	local zhenyuanIdList = {}
            	for Id, isSelected in pairs(self.mSelectList) do
            		if isSelected then
            			table.insert(zhenyuanIdList, Id)
            		end
            	end
            	-- 检查是否有紫色及以上品质真元进行提示，并请求升级
                self:checkQualityHint(zhenyuanIdList, 10)
            end,
        },
	}
	-- 创建按钮
	for _, btnInfo in pairs(btnList) do
		local tempBtn = ui.newButton(btnInfo)
		self.mParentLayer:addChild(tempBtn)
	end
end

-- 创建真元大图显示滑窗
function ZhenYuanLvUpLayer:createZhenyuanView()
	local viewSize = cc.size(640, 380)
	self.mZhenyuanView = ui.newSliderTableView({
        width = viewSize.width,
        height = viewSize.height,
        isVertical = false,
        selItemOnMiddle = true,
        selectIndex = self.currIndex-1,
        itemCountOfSlider = function(sliderView)
        	return #self.mZhenyuanList
        end,
        itemSizeOfSlider = function(sliderView)
            return viewSize.width, viewSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
        	-- 创建真元大图
        	local zhenyuanFigure = Figure.newZhenyuan({
        			zhenyuanId = self.mZhenyuanList[index+1],
        			needAction = true,
        			viewSize = viewSize,
        		})
        	zhenyuanFigure:setPosition(viewSize.width*0.5, viewSize.height*0.5)
        	itemNode:addChild(zhenyuanFigure)
        end,
        selectItemChanged = function(sliderView, selectIndex)
        	-- 更新索引
        	self.currIndex = selectIndex+1
        	-- 更新真元信息
        	self:refreshZhenyuanInfo()
        	-- 清空真元选择表
        	self.mSelectList = {}
        	-- 更新可吞噬真元显示网格
        	self:refreshGrid()
        end
    })

	self.mZhenyuanView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mZhenyuanView:setPosition(320, 800)
    self.mParentLayer:addChild(self.mZhenyuanView)
end

-- 创建并刷新真元信息（包含等级，名字，装备于）
function ZhenYuanLvUpLayer:refreshZhenyuanInfo()
	local zhenyuanInfo = ZhenyuanObj:getZhenyuan(self.mZhenyuanList[self.currIndex])
	local zhenyuanModel = ZhenyuanModel.items[zhenyuanInfo.ModelId]

	-- 真元名字
	if not self.nameLabel then
		local nameLabel = ui.newLabel({
				text = "",
				size = 24,
				color = cc.c3b(0xff, 0xfb, 0xde),
				outlineColor = cc.c3b(0x37, 0x30, 0x2c),
			})
		self.nameLabel = nameLabel
		-- 名字背景
		local labelSize = nameLabel:getContentSize()
		local labelBgSize = cc.size(labelSize.width+100, 54)
		local labelBg = ui.newScale9Sprite("c_25.png", labelBgSize)
		labelBg:setPosition(320, 960)
		self.mParentLayer:addChild(labelBg)
		nameLabel:setPosition(labelBgSize.width*0.5, labelBgSize.height*0.5)
		labelBg:addChild(nameLabel)
	end
	local nameText = TR("等级%d  %s%s  #9BFF6A%s",
						zhenyuanInfo.Lv, Utility.getQualityColor(zhenyuanModel.quality, 2),
						zhenyuanModel.name,
						zhenyuanInfo.Step and zhenyuanInfo.Step > 0 and "+"..zhenyuanInfo.Step or "")
	self.nameLabel:setString(nameText)

	-- 装备于
	if not self.wearHint then
		self.wearHint = ui.newLabel({
				text = "",
				color = cc.c3b(0xff, 0xfb, 0xde),
				size = 22,
				outlineColor = cc.c3b(0x37, 0x30, 0x2c),
			})
		self.wearHint:setAnchorPoint(cc.p(0, 0.5))
		self.wearHint:setPosition(10, 630)
		self.mParentLayer:addChild(self.wearHint)
	end
	local isIn, slotId = FormationObj:zhenyuanInFormation(self.mZhenyuanList[self.currIndex])
	if isIn then
		local slotInfo = FormationObj:getSlotInfoBySlotId(slotId)
		local heroInfo = FormationObj:getSlotHeroInfo(slotInfo.HeroId)
		local heroModel = HeroModel.items[heroInfo.ModelId]
		local colorValue = Utility.getQualityColor(heroModel.quality, 2)
        local tempName = heroModel.name
        if heroInfo.IllusionModelId and heroInfo.IllusionModelId > 0 then 
            tempName = IllusionModel.items[heroInfo.IllusionModelId] and IllusionModel.items[heroInfo.IllusionModelId].name or ""
        end
		self.wearHint:setString(TR("装备于%s%s", colorValue, tempName))
	else
		self.wearHint:setString("")
	end

	-- 当前攻击加成
	if not self.curAttrLabel then
		self.curAttrLabel = ui.newLabel({
				text = TR("加成"),
				color = cc.c3b(0x46, 0x22, 0x0d),
			})
		self.curAttrLabel:setAnchorPoint(cc.p(0, 0.5))
		self.curAttrLabel:setPosition(10, 580)
		self.mParentLayer:addChild(self.curAttrLabel)
	end
	local attStr = self:getZhenyuanAttrStr(zhenyuanInfo)
	self.curAttrLabel:setString(attStr)

	-- 下一级攻击加成
	if not self.nextAttrLabel then
		self.nextAttrLabel = ui.newLabel({
				text = TR("下一级加成"),
				color = cc.c3b(0x46, 0x22, 0x0d),
			})
		self.nextAttrLabel:setAnchorPoint(cc.p(0, 0.5))
		self.nextAttrLabel:setPosition(310, 580)
		self.mParentLayer:addChild(self.nextAttrLabel)
	end
	local attStr = self:getZhenyuanAttrStr(zhenyuanInfo, true)
	if attStr and attStr ~= "" then
		self.nextAttrLabel:setString(TR("下一级:%s", attStr))
	-- 经验真元
	elseif attStr == "" then
		self.nextAttrLabel:setString(TR("经验#249029+%d", zhenyuanModel.exp))
	else
		self.nextAttrLabel:setString(TR("已满级"))
	end

	-- 经验预进度条
	if not self.preExpProgress then
		self.preExpProgress = require("common.ProgressBar"):create({
			bgImage = "zr_14.png",
			barImage = "zr_37.png",
			currValue = 0,
			maxValue = 100,
			barType = ProgressBarType.eHorizontal,
		})
		self.preExpProgress:setAnchorPoint(cc.p(0.5, 0.5))
		self.preExpProgress:setPosition(320, 545)
		self.mParentLayer:addChild(self.preExpProgress)
	end
	local _, curLvExp = self:getZhenyuanNeedExp(zhenyuanInfo)
	self.preExpProgress:setMaxValue(curLvExp)
	self.preExpProgress:setCurrValue(zhenyuanInfo.Exp)

	-- 经验进度条
	if not self.expProgress then
		self.expProgress = require("common.ProgressBar"):create({
			bgImage = "zr_14.png",
			barImage = "zr_15.png",
			needHideBg = true,
			currValue = 0,
			maxValue = 100,
			barType = ProgressBarType.eHorizontal,
		})
		self.expProgress:setAnchorPoint(cc.p(0.5, 0.5))
		self.expProgress:setPosition(320, 545)
		self.mParentLayer:addChild(self.expProgress)
	end
	self.expProgress:setMaxValue(curLvExp)
	self.expProgress:setCurrValue(zhenyuanInfo.Exp)

    -- 进度的提示信息
    if not self.progLabel then
	    self.progLabel = ui.newLabel({
			text = "",
			size = 18,
			outlineColor = Enums.Color.eOutlineColor,
			outlineSize = 2,
		})
		local progSize = self.expProgress:getContentSize()
		self.progLabel:setPosition(progSize.width*0.5, progSize.height*0.5)
		self.progLabel:setAnchorPoint(cc.p(0.5, 0.5))
		self.expProgress:addChild(self.progLabel)
	end
	self:refeshProgLabel(zhenyuanInfo.Exp)
end

-- 获取真元的属性列表
--[[
	params:
		zhenyuanInfo 				-- 真元信息
		isNextLvAttr 				-- 是否返回下一等级的属性列表
	返回：
		属性字符串
--]]
function ZhenYuanLvUpLayer:getZhenyuanAttrStr(zhenyuanInfo, isNextLvAttr)
	-- 等级
	local curLv = zhenyuanInfo.Lv
	if isNextLvAttr then
		curLv = curLv + 1
	end
	-- 是否满级
	if not ZhenyuanLvUpRelation.items[curLv] then return end

	-- 属性列表
	local attrList = ConfigFunc:getZhenyuanLvAttr(zhenyuanInfo.ModelId, curLv)

	-- 将属性信息转化为字符串
	local attrStrList = {}
	for _, attr in pairs(attrList) do
		local text = "#46220d"..FightattrName[attr.fightattr].."#249029"..Utility.getAttrViewStr(attr.fightattr, attr.value)
		table.insert(attrStrList, text)
	end

	return table.concat(attrStrList, ",")
end

-- 获取真元当前需要升级经验
--[[
	params:
		zhenyuanInfo 				-- 真元信息
	返回：
		needExp 					-- 还需要的经验
		needLvExp					-- 该等级需要的总经验
--]]
function ZhenYuanLvUpLayer:getZhenyuanNeedExp(zhenyuanInfo)
	local zhenyuanModel = ZhenyuanModel.items[zhenyuanInfo.ModelId]
	local lvExp = ZhenyuanLvUpRelation.items[zhenyuanInfo.Lv].perExp
	local needLvExp = zhenyuanModel.upUseR*lvExp
	local needExp = needLvExp - zhenyuanInfo.Exp

	return needExp, needLvExp
end

-- 获取真元当前携带的总经验
--[[
	params:
		zhenyuanInfo 				-- 真元信息
--]]
function ZhenYuanLvUpLayer:getZhenyuanAllExp(zhenyuanInfo)
	local zhenyuanModel = ZhenyuanModel.items[zhenyuanInfo.ModelId]
	local allLvExp = 0
	for i = 0, zhenyuanInfo.Lv-1 do
		local lvExp = ZhenyuanLvUpRelation.items[i].perExp*zhenyuanModel.upUseR
		allLvExp = allLvExp + lvExp
	end

	return allLvExp+zhenyuanModel.exp+zhenyuanInfo.Exp
end

-- 获取列表大小
--[[
	params:
		list 				-- table列表
--]]
function ZhenYuanLvUpLayer:getListSize(list)
	local count = 0
	for _, item in pairs(list) do
		if item then
			count = count + 1
		end
	end

	return count
end

-- 刷新可吞噬真元显示网格
function ZhenYuanLvUpLayer:refreshGrid()
	-- 获取可吞噬真元数据列表
	local allZhenyuanList = clone(ZhenyuanObj:getZhenyuanList({
			excludeIdList = self.mZhenyuanList,
			notInFormation = true,
			includeExpModel = true,
		}))
	-- 排序
	table.sort(allZhenyuanList, function (item1, item2)
		-- 按品质（从低到高）
		local zhenyuanModel1 = ZhenyuanModel.items[item1.ModelId]
		local zhenyuanModel2 = ZhenyuanModel.items[item2.ModelId]

		-- 经验真元放前面
		if (zhenyuanModel1.type == 0) ~= (zhenyuanModel2.type == 0) then
			return zhenyuanModel1.type == 0
		end

		if zhenyuanModel1.quality ~= zhenyuanModel2.quality then
			return zhenyuanModel1.quality < zhenyuanModel2.quality
		end
		
		-- 有等级的放后面
		if (item1.Lv > 0) ~= (item2.Lv > 0) then
			return not (item1.Lv > 0)
		end

		-- 按模型id
		if item1.ModelId ~= item2.ModelId then
			return item1.ModelId < item2.ModelId
		end
	end )
	-- 保存能吞噬的真元
	self.mCanUseZhenyuanList = allZhenyuanList
	-- 清空之前的显示列表
	if self.mGridView and not tolua.isnull(self.mGridView) then
	    self.mGridView:removeFromParent()
	    self.mGridView = nil
	end
	-- 隐藏空提示
	if self.mEmptyHint then
		self.mEmptyHint:setVisible(false)
	end
	-- 创建列表背景
	if not self.gridBg then
		self.gridBg = ui.newScale9Sprite("zy_17.png", cc.size(620, 340))
		self.gridBg:setPosition(320, 350)
		self.mParentLayer:addChild(self.gridBg)
	end
	-- 创建显示网格
	if allZhenyuanList and next(allZhenyuanList) then
		self.mGridView = require("common.GridView"):create({
		    viewSize = cc.size(600, 330),
		    colCount = 4,
		    celHeight = 120,
		    getCountCb = function()
		        return #allZhenyuanList
		    end,
		    createColCb = function(itemParent, colIndex, isSelected)
		    	local bgSize = itemParent:getContentSize()
		    	-- 改变选择状态
		    	local function changeState()
		    		local zhenyuanInfo = ZhenyuanObj:getZhenyuan(self.mZhenyuanList[self.currIndex])
		    		-- 经验真元
		    		local selectExp = self:getSelectExp()
		    		local needExp = self:getZhenyuanNeedExp(zhenyuanInfo)
		    		if selectExp == 0 and needExp <= 0 then
		    			ui.showFlashView({text = TR("该真元不能聚气或已满级")})
		    			itemParent.checkBox:setCheckState(self.mSelectList[allZhenyuanList[colIndex].Id])
		    			return
		    		end
		    		-- 能升到满级
		    		if self.canGetLv and self.canGetLv == ZhenyuanLvUpRelation.items_count-1 and not self.mSelectList[allZhenyuanList[colIndex].Id] then
		    			ui.showFlashView({text = TR("已选中的真元数量足够升至满级")})
		    			itemParent.checkBox:setCheckState(self.mSelectList[allZhenyuanList[colIndex].Id])
		    			return
		    		end
		    		-- 选择的数量是否超过限制
		    		if self:getListSize(self.mSelectList) >= 255 and not self.mSelectList[allZhenyuanList[colIndex].Id] then
		    			ui.showFlashView({text = TR("真元选择数量已达上限")})
		    			itemParent.checkBox:setCheckState(self.mSelectList[allZhenyuanList[colIndex].Id])
		    			return
		    		end
		    		-- 改变是否勾选显示状态
		    		self.mSelectList[allZhenyuanList[colIndex].Id] = not self.mSelectList[allZhenyuanList[colIndex].Id]
		    		itemParent.checkBox:setCheckState(self.mSelectList[allZhenyuanList[colIndex].Id])
		    		-- 改变进度条状态
		    		local curExp = self.preExpProgress:getCurrValue()
		    		local zhenyuanExp = self:getZhenyuanAllExp(ZhenyuanObj:getZhenyuan(allZhenyuanList[colIndex].Id))
		    		if self.mSelectList[allZhenyuanList[colIndex].Id] then
		    			curExp = curExp + zhenyuanExp
		    		else
		    			curExp = curExp - zhenyuanExp
		    		end
		    		self.preExpProgress:setCurrValue(curExp)
		    		self:refeshProgLabel(curExp)
		    	end
		    	-- 创建真元显示卡
		    	local card = CardNode.createCardNode({
		    			cardShape = Enums.CardShape.eCircle,
		    			resourceTypeSub = ResourcetypeSub.eZhenYuan,
		    			cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eLevel},
		    			instanceData = allZhenyuanList[colIndex],
		    			onClickCallback = function ()
		    				changeState()
		    			end,
		    		})
		    	card:setPosition(bgSize.width*0.5, bgSize.height*0.5+10)
		    	itemParent:addChild(card)
		    	-- 创建复选框
		    	local checkBox = ui.newCheckbox({
		    			normalImage = "c_83.png",
		    			selectImage = "zy_19.png",
		    			callback = function ()
		    				changeState()
		    			end,
		    		})
		    	checkBox:setScale(1.1)
		    	checkBox:setCheckState(self.mSelectList[allZhenyuanList[colIndex].Id])
		    	checkBox:setPosition(bgSize.width*0.5, bgSize.height*0.6)
		    	itemParent:addChild(checkBox)
		    	itemParent.checkBox = checkBox
		    end,
		})

		self.mGridView:setPosition(320, 350)
		self.mParentLayer:addChild(self.mGridView)
	else
		-- 创建空提示
		if not self.mEmptyHint then
			self.mEmptyHint = ui.createEmptyHint(TR("暂无真元"))
			self.mEmptyHint:setPosition(320, 400)
			self.mParentLayer:addChild(self.mEmptyHint)
		end
		self.mEmptyHint:setVisible(true)
	end
end

function ZhenYuanLvUpLayer:getSelectExp()
	local selectExp = 0
	-- 减去已选择真元的经验
	for Id, isSelected in pairs(self.mSelectList) do
		if isSelected then
			local zhenyuanInfo = ZhenyuanObj:getZhenyuan(Id)
			local zhenyuanAllExp = self:getZhenyuanAllExp(zhenyuanInfo)
			selectExp = selectExp + zhenyuanAllExp
		end
	end
	return selectExp
end

-- 一键品质选择
function ZhenYuanLvUpLayer:oneKeyValueLvSelect(valueLv)
	-- 获取当前需要的经验值
	local curZhenyuanInfo = ZhenyuanObj:getZhenyuan(self.mZhenyuanList[self.currIndex])
	local needExp = self:getZhenyuanNeedExp(curZhenyuanInfo)
	local selectExp = self:getSelectExp()
	local hadSelectNum = self:getListSize(self.mSelectList)
	-- 经验真元
	if needExp <= 0 and selectExp == 0 then
		ui.showFlashView({text = TR("该真元不能聚气或已满级")})
		return
	end
	-- 是否有多余真元选择
	if not self.mCanUseZhenyuanList or not next(self.mCanUseZhenyuanList) then
		ui.showFlashView({text = TR("没有可以选择的真元")})
		return
	end
	-- 选择的数量是否超过限制
	if hadSelectNum >= 255 then
		ui.showFlashView({text = TR("真元选择数量最大为255")})
		return
	end

	local selectZhenyuanList = {}
	-- 从低品质到高品质选择
	for _, zhenyuanInfo in pairs(self.mCanUseZhenyuanList) do
		-- 数量达上限
		if hadSelectNum >= 255 then
			ui.showFlashView({text = TR("真元选择数量最大为255")})
			break
		end

		-- 等级达上限
		if self.canGetLv and self.canGetLv == ZhenyuanLvUpRelation.items_count-1 then
			ui.showFlashView(TR("该真元提升等级已达上限"))
			break
		end

		local zhenyuanModel = ZhenyuanModel.items[zhenyuanInfo.ModelId]

		-- 经验真元
		if valueLv == 1 then
			if zhenyuanModel.type == 0 then
				local zhenyuanAllExp = self:getZhenyuanAllExp(zhenyuanInfo)
				if not self.mSelectList[zhenyuanInfo.Id] then
					self.mSelectList[zhenyuanInfo.Id] = true
					selectExp = selectExp + zhenyuanAllExp
					hadSelectNum = hadSelectNum + 1

					table.insert(selectZhenyuanList, zhenyuanInfo.Id)
				end
			end
		-- 其他品质真元
		else
			if zhenyuanModel.valueLv == valueLv and zhenyuanModel.type ~= 0 then
				local zhenyuanAllExp = self:getZhenyuanAllExp(zhenyuanInfo)
				if not self.mSelectList[zhenyuanInfo.Id] then
					self.mSelectList[zhenyuanInfo.Id] = true
					selectExp = selectExp + zhenyuanAllExp
					hadSelectNum = hadSelectNum + 1

					table.insert(selectZhenyuanList, zhenyuanInfo.Id)
				end
			end
		end
		
		-- 刷新可升到的等级
		self:refeshProgLabel(curZhenyuanInfo.Exp + selectExp)
	end

	return selectZhenyuanList
end

-- 更新显示
function ZhenYuanLvUpLayer:refreshProgShow()
	-- 获取当前需要的经验值
	local curZhenyuanInfo = ZhenyuanObj:getZhenyuan(self.mZhenyuanList[self.currIndex])
	local selectExp = self:getSelectExp()

	local haveExp = curZhenyuanInfo.Exp + selectExp
	-- 更新文字进度显示
	self:refeshProgLabel(haveExp)
	-- 更新进度条
	self.preExpProgress:setCurrValue(haveExp)
	-- 刷新网格
	if self.mGridView then
		self.mGridView:reloadData()
	end
end

-- 一键选择
function ZhenYuanLvUpLayer:oneKeySelect()
	-- 获取当前需要的经验值
	local curZhenyuanInfo = ZhenyuanObj:getZhenyuan(self.mZhenyuanList[self.currIndex])
	local needExp = self:getZhenyuanNeedExp(curZhenyuanInfo)
	local selectExp = self:getSelectExp()
	local hadSelectNum = self:getListSize(self.mSelectList)
	-- 减去已选择真元的经验
	needExp = needExp - selectExp
	-- 经验真元
	if needExp <= 0 and selectExp == 0 then
		ui.showFlashView({text = TR("该真元不能聚气或已满级")})
		return
	end
	-- 如果已经足够返回
	if needExp <= 0 then
		ui.showFlashView({text = TR("升级需要的真元数量已足够")})
		return
	end
	-- 是否有多余真元选择
	if not self.mCanUseZhenyuanList or not next(self.mCanUseZhenyuanList) then
		ui.showFlashView({text = TR("没有可以选择的真元")})
		return
	end
	-- 选择的数量是否超过限制
	if hadSelectNum >= 255 then
		ui.showFlashView({text = TR("真元选择数量已达上限")})
		return
	end
	-- 从低品质到高品质选择
	for _, zhenyuanInfo in pairs(self.mCanUseZhenyuanList) do
		if needExp <= 0 or hadSelectNum >= 255 then break end
		local zhenyuanAllExp = self:getZhenyuanAllExp(zhenyuanInfo)
		if not self.mSelectList[zhenyuanInfo.Id] then
			self.mSelectList[zhenyuanInfo.Id] = true
			needExp = needExp - zhenyuanAllExp
			selectExp = selectExp + zhenyuanAllExp
			hadSelectNum = hadSelectNum + 1
		end
	end

	-- 更新显示
	self:refreshProgShow()
end

-- 更新文字进度显示
--[[
	hadExp: 	当前选中经验值+原有经验值
]]
function ZhenYuanLvUpLayer:refeshProgLabel(hadExp)
	-- 真元信息
	local zhenyuanInfo = ZhenyuanObj:getZhenyuan(self.mZhenyuanList[self.currIndex])
	local zhenyuanModel = ZhenyuanModel.items[zhenyuanInfo.ModelId]

	-- 当前等级需要的总经验
	local curLvExp = ZhenyuanLvUpRelation.items[zhenyuanInfo.Lv].perExp*zhenyuanModel.upUseR
	-- 当前已有经验的百分比
	local currCount = zhenyuanInfo.Exp <=0 and 0 or zhenyuanInfo.Exp/curLvExp*100
	if curLvExp <= 0 then
		currCount = 0
	end
	-- 可以升到的等级（初始化为当前等级）
	local canGetLv = zhenyuanInfo.Lv
	-- 勾选真元的总经验
	local selectExp = hadExp - zhenyuanInfo.Exp

	-- 获取可以升到的等级
	local hadExpCount = hadExp
	-- 循环初始当前等级，上限最高等级
	for i = canGetLv, ZhenyuanLvUpRelation.items_count-1 do
		-- 可拥有经验为小于等于0时跳出循环
		if hadExpCount <= 0 then break end
		-- 计算等级
		local lvExp = ZhenyuanLvUpRelation.items[i].perExp*zhenyuanModel.upUseR
		hadExpCount = hadExpCount - lvExp
		canGetLv = i
	end

	-- 刷新显示字符串
	if selectExp > 0 then
		if canGetLv > zhenyuanInfo.Lv then
			self.progLabel:setString(TR("当前经验: %.2f%%%s(可升至%d级)", currCount, Enums.Color.eYellowH, canGetLv))
			self.canGetLv = canGetLv
		else
			local nextCount = math.floor(hadExp/curLvExp*100)
			self.progLabel:setString(TR("当前经验: %.2f%%%s(可升至%d%%)", currCount, Enums.Color.eYellowH, nextCount))
			self.canGetLv = nil
		end
	else
		self.progLabel:setString(TR("当前经验: %.2f%%", currCount))
		self.canGetLv = nil
	end
end

-- 检查选择的品质是否需要提示
--[[
	zhenyuanIdList: 	真元消耗列表
	quality:			需要提示的品质及以上
]]
function ZhenYuanLvUpLayer:checkQualityHint(zhenyuanIdList, quality)
	if #zhenyuanIdList <= 0 then
		ui.showFlashView({text = TR("没有选中的真元")})
		return
	end
	-- 查找大于等于紫色品质的真元
	local hintStr = ""
	local hintStrList = {}
	for _, Id in pairs(zhenyuanIdList) do
		local zhenyuanInfo = ZhenyuanObj:getZhenyuan(Id)
		local zhenyuanModel = ZhenyuanModel.items[zhenyuanInfo.ModelId]
		-- 不是经验真元且达到需要提醒的品质
		if zhenyuanModel.quality >= quality and zhenyuanModel.type ~= 0 then
			local colorValue = Utility.getQualityColor(zhenyuanModel.quality, 2)
			local nameStr = colorValue..zhenyuanModel.name
			table.insert(hintStrList, nameStr)
		end
		hintStr = table.concat(hintStrList, "、")
	end
	-- 创建提示弹窗（有需要提示品质时创建弹窗）
	if hintStr ~= "" then
		local function DIYfunc(boxRoot, bgSprite, bgSize)
			local listSize = cc.size(bgSize.width*0.9-10, bgSize.height-180)
			local listView = ccui.ListView:create()
		    listView:setDirection(ccui.ScrollViewDir.vertical)
		    listView:setContentSize(listSize)
		    listView:setGravity(ccui.ListViewGravity.centerHorizontal)
		    listView:setAnchorPoint(cc.p(0.5, 0))
		    listView:setPosition(bgSize.width*0.5, 105)
		    bgSprite:addChild(listView)

		    local hintLabel = ui.newLabel({
		    		text = TR("选中的真元中包含%s%s是否确定吞噬？", hintStr, Enums.Color.eNormalWhiteH),
		    		color = Enums.Color.eNormalWhite,
		    		outlineColor = Enums.Color.eOutlineColor,
		   			dimensions = cc.size(listSize.width*0.95, 0),
		    	})

		    local labelSize = hintLabel:getContentSize()
		    local layout = ccui.Layout:create()
		    layout:setContentSize(cc.size(listSize.width, listSize.height > labelSize.height and listSize.height or labelSize.height))

		    hintLabel:setAnchorPoint(cc.p(0.5, 0.5))
		    hintLabel:setPosition(layout:getContentSize().width*0.5, layout:getContentSize().height*0.5)
		    layout:addChild(hintLabel)

		    listView:pushBackCustomItem(layout)
		end
		self.hintBox = LayerManager.addLayer({
			name = "commonLayer.MsgBoxLayer", 
			data = {
				title = TR("提示"),
				btnInfos = {
					{
						text = TR("确定"),
						clickAction = function ()
							self:requestZhenyuanLvUp(zhenyuanIdList)
							LayerManager.removeLayer(self.hintBox)
						end
					},
					{text = TR("取消"),},
				},
				DIYUiCallback = DIYfunc,
				closeBtnInfo = {},
			}, 
		    cleanUp = false,
		})
	else
		-- 请求升级
		self:requestZhenyuanLvUp(zhenyuanIdList)
	end
end

--=========================服务器相关============================
-- 聚气
function ZhenYuanLvUpLayer:requestZhenyuanLvUp(zhenyuanIdList)
	HttpClient:request({
        moduleName = "Zhenyuan",
        methodName = "LvUp",
        svrMethodData = {self.mZhenyuanList[self.currIndex], zhenyuanIdList},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
            -- 修改真元缓存信息
            ZhenyuanObj:modifyZhenyuanItem(response.Value.ZhenYuanInfo)
            -- 删除消耗真元
            for _, Id in pairs(zhenyuanIdList) do
            	ZhenyuanObj:deleteZhenyuanById(Id, true)
            end
            -- 清空选择列表
            self.mCanUseZhenyuanList = {}
        	self.mSelectList = {}
        	self.mSelectStatus = nil
        	self.mBoxSelectList = nil
        	-- 刷新界面
        	self:refreshZhenyuanInfo()
        	self:refreshGrid()
        end
    })
end


return ZhenYuanLvUpLayer