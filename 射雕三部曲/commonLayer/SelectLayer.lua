--[[
	文件名：SelectLayer.lua
	描述：物品选择页面，特定模块选择人物、装备、神兵、内功心法、外功秘籍等物品
	创建人：peiyaoqiang
	创建时间： 2017.3.16
--]]

local SelectLayer = class("SelectLayer", function(params)
	return display.newLayer()
end)


-- 列表item向下偏移值
local itemDistence = 5
--[[
-- 参数 params 中的各项为：
	{
		selectType: 选择类型，取值定义在 Enums.lua文件的 Enums.SelectType 中定义
		resourcetypeSub: 需要选择的资源子类型，只有部分 selectType 需要使用， 取值在EnumsConfig.lua 文件的 ResourcetypeSub 中定义
		modelId: 需要选择物品的模型ID，只有部分 selectType 需要使用
		oldSelList: 原来已选择的物品列表
		oldResourcetype: 原来已选择物品的资源类型，取值在 EnumsConfig.lua 的 Resourcetype 中定义
		callback: 选中确定后的回调函数，函数原型为 callback(slectLayerObj, selectItemList, resourcetype)
		excludeIdList: 需要排除的ID列表

		-- 下面的参数用于恢复该页面时使用，调用者不需关心
		viewData: 该页面显示的数据
		listInnerPos: 显示列表当前滑动的位置
	}
]]
function SelectLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

	self.mSelectType = params.selectType
	self.mResourcetypeSub = params.resourcetypeSub
	self.mModelId = params.modelId
	self.mNeedCount = params.needCount
	self.callback = params.callback
	self.mListOldInnerPos = params.listInnerPos
	self.mExcludeIdList = params.excludeIdList

	-- 当前选择物品的资源类型
	self.mSelResourcetype = params.oldResourcetype
	-- 列表背景的大小
	self.mListSize = cc.size(600, 770)
	-- 已选择的物品列表
	self.mSelectList = {}
	for _, item in pairs(params.oldSelList or {}) do
		self.mSelectList[item.Id] = item
	end
	-- 页面显示的数据(包含所有页签显示的数据)
	if params.viewData then
		self.mViewData = params.viewData
	else
		self.mViewData = {}
		-- 整理页面的显示数据
		self:dealViewData()
	end
	-- 当前显示的物品数据列表
	self.mCurrViewData = {}

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	self:initUI()

	-- 最底部导航按钮页面(因为底部导航按钮应该显示在最上面，所以需要最后 addChild)
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
end

-- 初始化页面控件
function SelectLayer:initUI()
	-- 背景图片
	local bgSprite = ui.newSprite("c_34.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	local tempSprite = ui.newScale9Sprite("c_17.png", cc.size(610, 860))
    tempSprite:setAnchorPoint(cc.p(0.5, 1))
    tempSprite:setPosition(320, 965)
    self.mParentLayer:addChild(tempSprite, 1)

	-- 创建tab页面切换页面
	local typeNameList = {"Hero", "Equip", "Treasure", "Zhenjue", "Pet", "Zhenshou"}
	local tabBtnInfos = {}
	local firstTabType
	for _, name in ipairs(typeNameList) do
		local tempData = self.mViewData[name]
		if tempData then
			firstTabType = firstTabType or tempData.resourcetype
			if not self.mSelResourcetype and #tempData.dataList > 0 then
				self.mSelResourcetype = tempData.resourcetype
			end

			table.insert(tabBtnInfos, {
				text = tempData.tabText,
				tag = tempData.resourcetype,
			})
		end
	end
	self.mSelResourcetype = self.mSelResourcetype or firstTabType

	-- 创建列表控件
	self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(self.mListSize)
    self.mListView:setItemsMargin(5)
    self.mListView:setPosition(cc.p((640 - self.mListSize.width) / 2, 185))
    self.mParentLayer:addChild(self.mListView, 2)

	self.mTabView = ui.newTabLayer({
		btnInfos = tabBtnInfos,
		space = 5,
		viewSize = cc.size(570, 80),
		needLine = false,
		defaultSelectTag = self.mSelResourcetype,
        allowChangeCallback = function(btnTag)
        	if table.nums(self.mSelectList) > 0 then
        		-- ui.showFlashView(TR("不能选择不同类型"))
        		self.mSelectList = {}
        		return true
        	else
	        	return true
	        end
        end,
        onSelectChange = function(selectBtnTag)
        	if selectBtnTag == self.mSelResourcetype then
        		return
        	end

        	self.mSelResourcetype = selectBtnTag
        	self.mSelectList = {}
        	self:refreshList()
        end
	})
	self.mTabView:setPosition(0, 1024)
	self.mTabView:setAnchorPoint(0, 0.5)
	self.mParentLayer:addChild(self.mTabView)
	--由于滑动需求单独创建Tabview的线
	local lineSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 1002))
	lineSprite:setAnchorPoint(cc.p(0.5, 0))
	lineSprite:setPosition(320, 0)
	self.mParentLayer:addChild(lineSprite)

    --  刷新列表
    self:refreshList()
    if self.mListOldInnerPos then
    	self.mListView:forceDoLayout()
    	self.mListView:setInnerContainerPosition(self.mListOldInnerPos)
    end

    -- 确定按钮
    local mOkBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("确定"),
		clickAction = function()
			local tempList = {}
			for _, item in pairs(self.mSelectList) do
				table.insert(tempList, item)
			end
			self.callback(self, tempList, self.mSelResourcetype)
		end
	})
	if self.mSelectType ~= Enums.SelectType.ePetCompare then
		mOkBtn:setPosition(450, 145)
	else
		mOkBtn:setPosition(320, 145)
	end
	self.mParentLayer:addChild(mOkBtn, 1)

	-- 自动放入按钮
    local mSelectBtn = ui.newButton({
		normalImage = "c_33.png",
		text = TR("自动放入"),
		clickAction = function()
			for index, item in ipairs(self.mCurrViewData.dataList or {}) do
				-- 判断是否选择已满
		        if table.nums(self.mSelectList) >= self.mCurrViewData.selMaxCount then
		        	break
		        end

		        -- 顺序自动选中
		        local cellItem = self.mListView:getItem(index - 1)
		        if (cellItem ~= nil) and (cellItem.checkBox ~= nil) then
		        	-- 有些选项需要去重生，不一定有checkBox，所以要判断下
		        	local currState = cellItem.checkBox:getCheckState()
		        	if (currState == false) then
		        		self.mSelectList[item.Id] = clone(item)
		        		cellItem.checkBox:setCheckState(true)
		        	end
		        end

		    end
		end
	})
	mSelectBtn:setPosition(190, 145)
	self.mParentLayer:addChild(mSelectBtn, 2)
	mSelectBtn:setVisible(self.mSelectType ~= Enums.SelectType.ePetCompare)

	-- 返回按钮
    local mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function (pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(mCloseBtn, 2)
end

-- 获取恢复数据
function SelectLayer:getRestoreData()
	local restoreData = {
		selectType = self.mSelectType,
		resourcetypeSub = self.mResourcetypeSub,

		oldSelList = {},
		oldResourcetype = self.mSelResourcetype,
		callback = self.callback,

		viewData = self.mViewData,
		listInnerPos = cc.p(self.mListView:getInnerContainerPosition()),
	}
	for _, item in pairs(self.mSelectList) do
		table.insert(restoreData.oldSelList, item)
	end

	return restoreData
end

-- 整理列表显示的数据
function SelectLayer:dealViewData()
	if self.mSelectType == Enums.SelectType.eResolve then -- 分解: 限制6个，已经进阶和升级的显示在后面并且不可选
		self.mViewData.title = TR("分解选择")
		self.mViewData.Hero = {
			tabText = TR("侠客"),
			resourcetype = Resourcetype.eHero,
			selMaxCount = 6,
			dataList = HeroObj:getHeroList({isResolve = true}),
		}
		self:sortHeroData(self.mViewData.Hero.dataList)

		self.mViewData.Treasure = {
			tabText = TR("神兵"),
			resourcetype = Resourcetype.eTreasure,
			selMaxCount = 6,
			dataList = TreasureObj:getTreasureList({isResolve = true, resourcetypeSub = self.mResourcetypeSub}),
		}
		self:sortTreasureData(self.mViewData.Treasure.dataList)

		self.mViewData.Equip = {
			tabText = TR("装备"),
			resourcetype = Resourcetype.eEquipment,
			selMaxCount = 6,
			dataList = EquipObj:getEquipList({isRefine = true})
		}
		self:sortEquipData(self.mViewData.Equip.dataList)

		if ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenjue, false) and
	        ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eZhenjue) then
	        self.mViewData.Zhenjue = {
				tabText = TR("内功心法"),
				resourcetype = Resourcetype.eNewZhenJue,
				selMaxCount = 6,
				dataList = ZhenjueObj:getZhenjueList({isResolve = true}),
			}
			self:sortZhenjueData(self.mViewData.Zhenjue.dataList)
	    end
	    if ModuleInfoObj:moduleIsOpen(ModuleSub.ePet, false) and
	        ModuleInfoObj:moduleIsOpenInServer(ModuleSub.ePet) then
	        self.mViewData.Pet = {
				tabText = TR("外功秘籍"),
				resourcetype = Resourcetype.ePet,
				selMaxCount = 6,
				dataList = PetObj:getPetList({isResolve = true, notInFormation = true, minColorLv = 5})
			}
			self:sortPetData(self.mViewData.Pet.dataList)
	    end
	    if ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenshou, false) and
	        ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eZhenshou) then
	        self.mViewData.Zhenshou = {
				tabText = TR("珍兽"),
				resourcetype = Resourcetype.eZhenshou,
				selMaxCount = 6,
				dataList = ZhenshouObj:getZhenshouList({isResolve = true, notInFormation = true})
			}
			self:sortZhenshouData(self.mViewData.Zhenshou.dataList)
	    end
	elseif self.mSelectType == Enums.SelectType.eRebirth then -- 重生: 限制1人，升级或进阶过，不符合条件的不显示
		self.mViewData.title = TR("重生选择")
		self.mViewData.Hero = {
			tabText = TR("侠客"),
			resourcetype = Resourcetype.eHero,
			selMaxCount = 6,
			dataList = HeroObj:getHeroList({isRebirth = true})
		}
		self:sortHeroData(self.mViewData.Hero.dataList)

		self.mViewData.Equip = {
			tabText = TR("装备"),
			resourcetype = Resourcetype.eEquipment,
			selMaxCount = 6,
			dataList = EquipObj:getEquipList({
				isRebirth = true,
				resourcetypeSub = self.mResourcetypeSub
			})
		}
		self:sortEquipData(self.mViewData.Equip.dataList)

		self.mViewData.Treasure = {
			tabText = TR("神兵"),
			resourcetype = Resourcetype.eTreasure,
			selMaxCount = 6,
			dataList = TreasureObj:getTreasureList({
				isRebirth = true,
				resourcetypeSub = self.mResourcetypeSub
			}),
		}
		self:sortTreasureData(self.mViewData.Treasure.dataList)

		if ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenjue, false) and
	        ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eZhenjue) then
	        self.mViewData.Zhenjue = {
				tabText = TR("内功心法"),
				resourcetype = Resourcetype.eNewZhenJue,
				selMaxCount = 1,
				dataList = ZhenjueObj:getZhenjueList({isRebirth = true}),
			}
			self:sortZhenjueData(self.mViewData.Zhenjue.dataList)
	    end

	    if ModuleInfoObj:moduleIsOpen(ModuleSub.ePet, false) and
	        ModuleInfoObj:moduleIsOpenInServer(ModuleSub.ePet) then
	        self.mViewData.Pet = {
				tabText = TR("外功秘籍"),
				resourcetype = Resourcetype.ePet,
				selMaxCount = 6,
				dataList = PetObj:getPetList({isRebirth = true}),
			}
			self:sortPetData(self.mViewData.Pet.dataList)
	    end

	    if ModuleInfoObj:moduleIsOpen(ModuleSub.eZhenshou, false) and
	        ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eZhenshou) then
	        self.mViewData.Zhenshou = {
				tabText = TR("珍兽"),
				resourcetype = Resourcetype.eZhenshou,
				selMaxCount = 6,
				dataList = ZhenshouObj:getZhenshouList({isRebirth = true})
			}
			self:sortZhenshouData(self.mViewData.Zhenshou.dataList)
	    end
	elseif self.mSelectType == Enums.SelectType.eEquipCompare then -- 装备合成: 只有装备，限制5件，只能选择同品质
		self.mViewData.title = TR("合成选择")
		self.mViewData.Equip = {
			tabText = TR("装备"),
			resourcetype = Resourcetype.eEquipment,
			selMaxCount = 5,
			dataList = EquipObj:getEquipList({
				isEquipCompare = true,
				 maxColorLv = 6,
				 maxStep = 0,
			})
		}
		self:sortEquipData(self.mViewData.Equip.dataList)
	elseif self.mSelectType == Enums.SelectType.eTreasureCompare then -- 神兵合成: 只有神兵，限制5件，只有紫色
		self.mViewData.title = TR("合成选择")
		self.mViewData.Treasure = {
			tabText = TR("神兵"),
			resourcetype = Resourcetype.eTreasure,
			selMaxCount = 5,
			dataList = TreasureObj:getTreasureList({
				isTreasureCompare = true,
				maxStep = 0,
			})
		}
		self:sortTreasureData(self.mViewData.Treasure.dataList)
	elseif self.mSelectType == Enums.SelectType.eEquipStarUp then -- 装备升星
		local excludeId = nil
		if (self.mExcludeIdList ~= nil) and (self.mExcludeIdList[1] ~= nil) then
			excludeId = self.mExcludeIdList[1]
		end
		self.mViewData.title = TR("升星选择")
		self.mViewData.Equip = {
			tabText = TR("装备"),
			resourcetype = Resourcetype.eEquipment,
			selMaxCount = self.mNeedCount or 1,
			dataList = EquipObj:getListOfStarUp(self.mModelId, excludeId),
		}
		self:sortEquipData(self.mViewData.Equip.dataList)
	elseif self.mSelectType == Enums.SelectType.eTreasureLvUp then -- 神兵强化：强化过的可以选 进阶过的不行 不包括已上阵的
		self.mViewData.title = TR("强化选择")
		self.mViewData.Treasure = {
			tabText = TR("神兵"),
			resourcetype = Resourcetype.eTreasure,
			selMaxCount = 5,
			dataList = TreasureObj:getTreasureList({
				isTreasureLvUp = true,
				resourcetypeSub = self.mResourcetypeSub,
				excludeIdList = self.mExcludeIdList
			}),
		}
		self:sortTreasureData(self.mViewData.Treasure.dataList)
	elseif self.mSelectType == Enums.SelectType.eTreasureStepUp then -- 神兵进阶
		self.mViewData.title = TR("进阶选择")
		self.mViewData.Treasure = {
			tabText = TR("神兵"),
			resourcetype = Resourcetype.eTreasure,
			selMaxCount = 1,
			dataList = TreasureObj:getTreasureList({
				isTreasureStepUp = true,
				resourcetypeSub = self.mResourcetypeSub,
			})
		}
		self:sortTreasureData(self.mViewData.Treasure.dataList)
	elseif self.mSelectType == Enums.SelectType.ePetCompare then  -- 外功秘籍合成
		self.mViewData.title = TR("合成选择")
		self.mViewData.Pet = {
			tabText = TR("外功秘籍"),
			resourcetype = Resourcetype.ePet,
			selMaxCount = 6,
			dataList = PetObj:getPetList({isCompare = true})
		}
		self:sortPetData(self.mViewData.Pet.dataList)
	elseif self.mSelectType == Enums.SelectType.ePetRebirth then -- 外功秘籍涅槃
		self.mViewData.title = TR("散功选择")
		self.mViewData.Pet = {
			tabText = TR("外功秘籍"),
			resourcetype = Resourcetype.ePet,
			selMaxCount = 1,
			dataList = PetObj:getPetList({isRebirth = true, minColorLv = 4})
		}
		self:sortPetData(self.mViewData.Pet.dataList)
	elseif self.mSelectType == Enums.SelectType.eHeroConversion then -- 大侠之魂转化
		self.mViewData.Hero = {
			tabText = TR("侠客"),
			resourcetype = Resourcetype.eHero,
			selMaxCount = 6,
			dataList = HeroObj:getHeroList({notInFormation = true, minColorLv = 6, maxLv = 1})
		}
		self:sortHeroData(self.mViewData.Hero.dataList)
	end
end

-- 对人物数据进行排序
function SelectLayer:sortHeroData(heroList)
	table.sort(heroList, function(hero1, hero2)
		local heroModel1 = HeroModel.items[hero1.ModelId]
		local heroModel2 = HeroModel.items[hero2.ModelId]
		-- 重生类型的需要先排序颜色品质
		if self.mSelectType == Enums.SelectType.eRebirth then
			-- 按照人物品质排序
			if heroModel1.quality ~= heroModel2.quality then   -- 按照人物品质排序
				return heroModel1.quality < heroModel2.quality
			end
		end

		-- 按照突破等级排序
		if hero1.Step ~= hero2.Step then
			return hero1.Step < hero2.Step
		end
		-- 按照升级等级排序
		if hero1.Lv ~= hero2.Lv then
			return hero1.Lv < hero2.Lv
		end

		-- 其他类型的需后先排序颜色品质
		if self.mSelectType ~= Enums.SelectType.eRebirth then
			-- 按照人物品质排序
			if heroModel1.quality ~= heroModel2.quality then   -- 按照人物品质排序
				return heroModel1.quality < heroModel2.quality
			end
		end

		-- 最后把相同名字的排列在一起
		return hero1.ModelId < hero2.ModelId
	end)
end

-- 对装备数据进行排序
function SelectLayer:sortEquipData(equipList)
	table.sort(equipList, function(equip1, equip2)
		local equipModel1 = EquipModel.items[equip1.ModelId]
		local equipModel2 = EquipModel.items[equip2.ModelId]
		-- 重生类型的需要先排序颜色品质
		if self.mSelectType == Enums.SelectType.eRebirth then
			-- 按照颜色品质排序饿
			if equipModel1.quality ~= equipModel2.quality then   -- 按照人物品质排序
				return equipModel1.quality < equipModel2.quality
			end
		end

		-- 把进阶的装备排在后面
		if equip1.Step ~= equip2.Step then
			return equip1.Step < equip2.Step
		end

		-- 把进阶的装备排在后面
		if equip1.Lv ~= equip2.Lv then
			return equip1.Lv < equip2.Lv
		end

		-- 其他类型的需后先排序颜色品质
		if self.mSelectType ~= Enums.SelectType.eRebirth then
			-- 按照颜色品质排序饿
			if equipModel1.quality ~= equipModel2.quality then   -- 按照人物品质排序
				return equipModel1.quality < equipModel2.quality
			end
		end

		-- 最后把相同名字的排列在一起
		return equip1.ModelId < equip2.ModelId
	end)
end

-- 对神兵数据进行排序
function SelectLayer:sortTreasureData(treasureList)
	table.sort(treasureList, function(treasure1, treasure2)
		local treasureModel1 = TreasureModel.items[treasure1.ModelId]
		local treasureModel2 = TreasureModel.items[treasure2.ModelId]
		-- 重生类型的需要先排序颜色品质
		if self.mSelectType == Enums.SelectType.eRebirth then
			-- 按照颜色品质排序饿
			if treasureModel1.quality ~= treasureModel2.quality then   -- 按照人物品质排序
				return treasureModel1.quality < treasureModel2.quality
			end
		end

		-- 把进阶的装备排在后面
		if treasure1.Step ~= treasure2.Step then
			return treasure1.Step < treasure2.Step
		end

		-- 把强化的装备排在后面
		if treasure1.Lv ~= treasure2.Lv then
			return treasure1.Lv < treasure2.Lv
		end

		-- 其他类型的需后先排序颜色品质
		if self.mSelectType ~= Enums.SelectType.eRebirth then
			-- 按照颜色品质排序饿
			if treasureModel1.quality ~= treasureModel2.quality then   -- 按照人物品质排序
				return treasureModel1.quality < treasureModel2.quality
			end
		end

		-- 最后把相同名字的排列在一起
		return treasure1.ModelId < treasure2.ModelId
	end)
end

-- 对内功心法数据进行排序
function SelectLayer:sortZhenjueData(zhenjueList)
	table.sort(zhenjueList, function(zhenjue1, zhenjue2)
		local model1 = ZhenjueModel.items[zhenjue1.ModelId]
		local model2 = ZhenjueModel.items[zhenjue2.ModelId]

		-- 比较品质
		if model1.colorLV ~= model2.colorLV then
			return model1.colorLV < model2.colorLV
		end
		-- 比较洗炼记录
		if zhenjue1.UpAttrRecord ~= zhenjue2.UpAttrRecord then
			return zhenjue1.UpAttrRecord < zhenjue2.UpAttrRecord
		end

		-- 比较类型
		if model1.typeID ~= model2.typeID then
			return model1.typeID < model2.typeID
		end

		-- 比较模型Id
		return model1.ID < model2.ID
	end)
end

-- 对外功秘籍数据进行排序
function SelectLayer:sortPetData(petList)
	table.sort(petList, function(pet1, pet2)
		local model1 = PetModel.items[pet1.ModelId]
		local model2 = PetModel.items[pet2.ModelId]

		-- 比较品质
		if model1.quality ~= model2.quality then
			return model1.quality < model2.quality
		end

		-- 比较等级
		if pet1.Lv ~= pet2.Lv then
			return pet1.Lv < pet2.Lv
		end

		-- 比较类型
		if model1.petType ~= model2.petType then
			return model1.petType < model2.petType
		end

		-- 比较模型Id
		return pet1.ModelId < pet2.ModelId
	end)
end

-- 对珍兽数据进行排序
function SelectLayer:sortZhenshouData(zhenshouList)
	table.sort(zhenshouList, function(zhenshou1, zhenshou2)
		local model1 = ZhenshouModel.items[zhenshou1.ModelId]
		local model2 = ZhenshouModel.items[zhenshou2.ModelId]

		-- 比较品质
		if model1.quality ~= model2.quality then
			return model1.quality < model2.quality
		end

		-- 比较等级
		if zhenshou1.Lv ~= zhenshou2.Lv then
			return zhenshou1.Lv < zhenshou2.Lv
		end

		-- 比较模型Id
		return zhenshou1.ModelId < zhenshou2.ModelId
	end)
end

-- 刷新列表
function SelectLayer:refreshList()
	self.mListView:removeAllItems()

	-- 资源类型于字段名称映射表
	local typeNameMap = {
		[Resourcetype.eHero] = "Hero",
		[Resourcetype.eEquipment] = "Equip",
		[Resourcetype.eTreasure] = "Treasure",
		[Resourcetype.eNewZhenJue] = "Zhenjue",
		[Resourcetype.ePet] = "Pet",
		[Resourcetype.eZhenshou] = "Zhenshou",
	}
	-- 当前显示列表对应的数据
	local tempStr = typeNameMap[self.mSelResourcetype] or ""
	self.mCurrViewData = self.mViewData[tempStr] or {}

	if self.mEmptySprite then
		self.mEmptySprite:removeFromParent()
		self.mEmptySprite = nil
	end
	if not self.mCurrViewData.dataList or #self.mCurrViewData.dataList == 0 then
		local tempStr = ""
		if self.mSelResourcetype == Resourcetype.eHero then -- 侠客
			tempStr = TR("没有满足条件的侠客！")
		elseif self.mSelResourcetype == Resourcetype.eEquipment then -- 装备
			tempStr = TR("没有满足条件的装备！")
		elseif self.mSelResourcetype == Resourcetype.eTreasure then -- 神兵
			tempStr = TR("没有满足条件的神兵！")
		elseif self.mSelResourcetype == Resourcetype.eNewZhenJue then -- 内功心法
			tempStr = TR("没有满足条件的内功心法！")
		elseif self.mSelResourcetype == Resourcetype.ePet then -- 外功秘籍
			tempStr = TR("没有满足条件的外功秘籍！")
		elseif self.mSelResourcetype == Resourcetype.eZhenshou then -- 珍兽
			tempStr = TR("没有满足条件的珍兽！")
		end
		self.mEmptySprite = ui.createEmptyHint(tempStr)
        self.mEmptySprite:setPosition(320, 650)
        self.mParentLayer:addChild(self.mEmptySprite, 2)

        -- 去获取功能
        local emptySize = self.mEmptySprite:getContentSize()
    	local grabBtn = ui.newButton({
    	    text = self.mSelResourcetype == Resourcetype.eTreasure and TR("去锻造") or TR("去获取"),
    	    normalImage = "c_28.png",
    	    clickAction = function()
				if self.mSelResourcetype == Resourcetype.eHero then -- 侠客
    	            LayerManager.showSubModule(ModuleSub.eRecruit)
				elseif self.mSelResourcetype == Resourcetype.eEquipment then -- 装备
    	            LayerManager.showSubModule(ModuleSub.ePracticeBloodyDemonDomain)
				elseif self.mSelResourcetype == Resourcetype.eTreasure then -- 神兵
    	            LayerManager.showSubModule(ModuleSub.eChallengeGrab)
				elseif self.mSelResourcetype == Resourcetype.eNewZhenJue then -- 内功心法
                	LayerManager.showSubModule(ModuleSub.eTeambattle)
				elseif self.mSelResourcetype == Resourcetype.ePet then -- 外功秘籍
                	LayerManager.showSubModule(ModuleSub.eExpedition)
                elseif self.mSelResourcetype == Resourcetype.eZhenshou then -- 珍兽
                	LayerManager.showSubModule(ModuleSub.eZhenshouLaoyu)
				end
    	    end
    	    })
    	grabBtn:setPosition(emptySize.width/2 - 33, emptySize.height/2 - 140)
    	self.mEmptySprite:addChild(grabBtn)
        return
	end

	-- 列表中每个条目的显示显示大小
	local cellSize = cc.size(self.mListSize.width, 120)
	for index, item in ipairs(self.mCurrViewData.dataList or {}) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mListView:pushBackCustomItem(lvItem)

		-- 根据资源类型创建每个条目具体的显示信息
		if self.mSelResourcetype == Resourcetype.eHero then -- 人物
			self:createHeroCell(lvItem, cellSize, item)
		elseif self.mSelResourcetype == Resourcetype.eEquipment then -- 装备
			self:createEquipCell(lvItem, cellSize, item)
		elseif self.mSelResourcetype == Resourcetype.eTreasure then -- 神兵
			self:createTreasureCell(lvItem, cellSize, item)
		elseif self.mSelResourcetype == Resourcetype.eNewZhenJue then -- 内功心法
			self:createZhenjueCell(lvItem, cellSize, item)
		elseif self.mSelResourcetype == Resourcetype.ePet then -- 外功秘籍
			self:createPetCell(lvItem, cellSize, item)
		elseif self.mSelResourcetype == Resourcetype.eZhenshou then -- 外功秘籍
			self:createZhenshouCell(lvItem, cellSize, item)
		end
    end
end

-- 创建列表的人物数据
function SelectLayer:createHeroCell(cellItem, cellSize, heroInfo)
    -- 创建单个条目的背景
    local tempSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width - 20, cellSize.height))
	tempSprite:setPosition(cellSize.width / 2, cellSize.height / 2 - itemDistence)
	cellItem:addChild(tempSprite)

	-- 创建人物头像卡牌
	local tempCard = CardNode:create({allowClick = true,})
	tempCard:setPosition(80, cellSize.height / 2 - itemDistence)
	tempCard:setHero(heroInfo, {CardShowAttr.eBorder, CardShowAttr.eLevel, CardShowAttr.eStep, CardShowAttr.eMedicine})
	cellItem:addChild(tempCard)

	-- 人物的模型数据
	local tempModel = HeroModel.items[heroInfo.ModelId]
	local illusionModel = IllusionModel.items[heroInfo.IllusionModelId]
	local colorLv = Utility.getQualityColorLv(tempModel.quality)

	-- 创建卡牌的名称
	local nameLabel = ui.newLabel({
		text = illusionModel and illusionModel.name or tempModel.name,
		color = Utility.getColorValue(colorLv, 1),
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
	})
	nameLabel:setAnchorPoint(cc.p(0, 0.5))
	nameLabel:setPosition(160, cellSize.height - 25 - itemDistence)
	cellItem:addChild(nameLabel)

	-- 创建卡牌的资质
	local qualityLabel = ui.newLabel({
		text = TR("资质:%s%d", Enums.Color.eBlackH, tempModel.quality),
		color = Enums.Color.eBrown,
	})
	qualityLabel:setAnchorPoint(cc.p(0, 0.5))
	qualityLabel:setPosition(160, cellSize.height * 0.5 - itemDistence)
	cellItem:addChild(qualityLabel)

	-- 创建卡牌的星级
	local starLabel = ui.newLabel({
		text = TR("称号:%s%s", Enums.Color.eBlackH, Utility.getHeroColorName(tempModel.quality)),
		color = Enums.Color.eBrown,
	})
	starLabel:setAnchorPoint(cc.p(0, 0.5))
	starLabel:setPosition(160, 25 - itemDistence)
	cellItem:addChild(starLabel)

	-- 创建选择框
	if heroInfo.Step == 0 or self.mSelectType == Enums.SelectType.eRebirth then
		local checkBox = ui.newCheckbox({
	        normalImage = "c_60.png",
	        selectImage = "c_61.png",
	        callback = function(isSelected)
	        	if isSelected then
	        		if self.mCurrViewData.selMaxCount <= table.nums(self.mSelectList) then
	        			if self.mCurrViewData.selMaxCount == 1 then
	        				local oldSelId = table.keys(self.mSelectList)[1]
	        				local oldItem = self.mSelectList[oldSelId]
	        				local oldCellIndex
	        				for index, item in pairs (self.mCurrViewData.dataList or {}) do
	        					if item.Id == oldSelId then
	        						oldCellIndex = index
	        						break
	        					end
	        				end
	        				if oldCellIndex then
	        					self.mSelectList = {}
	        					local lvItem = self.mListView:getItem(oldCellIndex - 1)
	        					lvItem:removeAllChildren()
	        					self:createHeroCell(lvItem, cellSize, oldItem)
	        				end
	        			else
	        				cellItem.checkBox:setCheckState(false)
	        				ui.showFlashView(TR("每次只能选择%d个", self.mCurrViewData.selMaxCount))
		        			return
	        			end
	        		end

	        		self.mSelectList[heroInfo.Id] = heroInfo
	        	else
	        		self.mSelectList[heroInfo.Id] = nil
	        	end
	        end
	    })
	    if self.mSelectList[heroInfo.Id] then
	    	checkBox:setCheckState(true)
	    else
	    	checkBox:setCheckState(false)
	    end
	    checkBox:setPosition(cc.p(cellSize.width - 80, cellSize.height / 2 - itemDistence))
	    cellItem:addChild(checkBox)
	    cellItem.checkBox = checkBox
	else
		-- 需要重生的标识
		local rebirthLabel = ui.newLabel({
			text = TR("需重生"),
			color = Enums.Color.eRed,
		})
		rebirthLabel:setAnchorPoint(cc.p(0.5, 0.5))
		rebirthLabel:setPosition(cellSize.width - 80, cellSize.height / 2 - itemDistence)
		cellItem:addChild(rebirthLabel)
	end
end

-- 创建列表的装备数据
function SelectLayer:createEquipCell(cellItem, cellSize, equipInfo)
	-- 创建单个条目的背景
    local tempSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width - 20, cellSize.height))
	tempSprite:setPosition(cellSize.width / 2, cellSize.height / 2 - itemDistence)
	cellItem:addChild(tempSprite)

	-- 创建人物头像卡牌
	local tempCard = CardNode:create({allowClick = true,})
	tempCard:setPosition(80, cellSize.height / 2 - itemDistence)
	tempCard:setEquipment(equipInfo, {CardShowAttr.eBorder, CardShowAttr.eLevel, CardShowAttr.eStep})
	cellItem:addChild(tempCard)

	-- 模型数据
	local tempModel = EquipModel.items[equipInfo.ModelId]

	-- 创建卡牌的名称
	local nameLabel = ui.newLabel({
		text = tempModel.name,
		color = Utility.getQualityColor(tempModel.quality, 1),
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
	})
	nameLabel:setAnchorPoint(cc.p(0, 0.5))
	nameLabel:setPosition(160, cellSize.height - itemDistence - 40)
	cellItem:addChild(nameLabel)

	-- 创建卡牌的星级
	Figure.newEquipStarLevel({
		parent = cellItem,
		anchorPoint = cc.p(0, 0.5),
        position = cc.p(160, cellSize.height - 80 - itemDistence),
        guid = equipInfo.Id,
	})

	-- 创建选择框
	if equipInfo.Star == 0 or self.mSelectType == Enums.SelectType.eRebirth then
		local colorLv = Utility.getQualityColorLv(tempModel.quality)
		local checkBox = ui.newCheckbox({
	        normalImage = "c_60.png",
	        selectImage = "c_61.png",
	        callback = function(isSelected)
	        	if isSelected then
	        		-- 装备合成只能选择相同颜色的装备
	        		if self.mSelectType == Enums.SelectType.eEquipCompare then
	        			local oldSelId, oldSelItem = next(self.mSelectList)
	        			if oldSelItem then
	        				local tempColorLv = Utility.getQualityColorLv(EquipModel.items[oldSelItem.ModelId].quality)
	        				if colorLv ~= tempColorLv then
	        					cellItem.checkBox:setCheckState(false)
		        				ui.showFlashView(TR("合成只能选择相同颜色的装备"))
		        				return
	        				end
	        			end
	        		end

	        		-- 只能选择一个的情况
	        		if self.mCurrViewData.selMaxCount <= table.nums(self.mSelectList) then
	        			if self.mCurrViewData.selMaxCount == 1 then
	        				local oldSelId = table.keys(self.mSelectList)[1]
	        				local oldItem = self.mSelectList[oldSelId]
	        				local oldCellIndex
	        				for index, item in pairs (self.mCurrViewData.dataList or {}) do
	        					if item.Id == oldSelId then
	        						oldCellIndex = index
	        						break
	        					end
	        				end
	        				if oldCellIndex then
	        					self.mSelectList = {}
	        					local lvItem = self.mListView:getItem(oldCellIndex - 1)
	        					lvItem:removeAllChildren()
	        					self:createEquipCell(lvItem, cellSize, oldItem)
	        				end
	        			else
	        				cellItem.checkBox:setCheckState(false)
		        			ui.showFlashView(TR("每次只能选择%d个", self.mCurrViewData.selMaxCount))
		        			return
	        			end
	        		end

	        		self.mSelectList[equipInfo.Id] = equipInfo
	        	else
	        		self.mSelectList[equipInfo.Id] = nil
	        	end
	        end
	    })
	    if self.mSelectList[equipInfo.Id] then
	    	checkBox:setCheckState(true)
	    else
	    	checkBox:setCheckState(false)
	    end
	    checkBox:setPosition(cc.p(cellSize.width - 80, cellSize.height / 2 - itemDistence))
	    cellItem:addChild(checkBox)
	    cellItem.checkBox = checkBox
	else
		-- 需要重生的标识
		local rebirthLabel = ui.newLabel({
			text = TR("需重生"),
			color = Enums.Color.eRed,
		})
		rebirthLabel:setAnchorPoint(cc.p(0.5, 0.5))
		rebirthLabel:setPosition(cellSize.width - 80, cellSize.height / 2 - itemDistence)
		cellItem:addChild(rebirthLabel)
	end
end

-- 创建列表的神兵数据
function SelectLayer:createTreasureCell(cellItem, cellSize, treasureInfo)
	-- 创建单个条目的背景
    local tempSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width - 20, cellSize.height))
	tempSprite:setPosition(cellSize.width / 2, cellSize.height / 2 - itemDistence)
	cellItem:addChild(tempSprite)

	-- 创建人物头像卡牌
	local tempCard = CardNode:create({allowClick = true,})
	tempCard:setPosition(80, cellSize.height / 2 - itemDistence)
	tempCard:setTreasure(treasureInfo, {CardShowAttr.eBorder, CardShowAttr.eLevel, CardShowAttr.eStep})
	cellItem:addChild(tempCard)

	-- 人物的模型数据
	local tempModel = TreasureModel.items[treasureInfo.ModelId]
	local colorLv = Utility.getQualityColorLv(tempModel.quality)

	-- 创建卡牌的名称
	local nameLabel = ui.newLabel({
		text = tempModel.name,
		color = Utility.getColorValue(colorLv, 1),
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
	})
	nameLabel:setAnchorPoint(cc.p(0, 0.5))
	nameLabel:setPosition(160, cellSize.height - 30 - itemDistence)
	cellItem:addChild(nameLabel)

	-- 创建卡牌的资质
	local qualityLabel = ui.newLabel({
		text = TR("资质:%s%d", Enums.Color.eBlackH, tempModel.quality),
		color = Enums.Color.eBrown,
	})
	qualityLabel:setAnchorPoint(cc.p(0, 0.5))
	qualityLabel:setPosition(160, cellSize.height - 60 - itemDistence)
	cellItem:addChild(qualityLabel)

	-- 创建卡牌的星级
	local tempNode = ui.newStarLevel(colorLv)
	tempNode:setAnchorPoint(cc.p(0, 0.5))
	tempNode:setPosition(160, cellSize.height - 90 - itemDistence)
	cellItem:addChild(tempNode)

	-- 创建选择框
	if treasureInfo.Step == 0 or self.mSelectType == Enums.SelectType.eRebirth then
		local checkBox = ui.newCheckbox({
	        normalImage = "c_60.png",
	        selectImage = "c_61.png",
	        callback = function(isSelected)
	        	if isSelected then
	        		if self.mCurrViewData.selMaxCount <= table.nums(self.mSelectList) then
	        			if self.mCurrViewData.selMaxCount == 1 then
	        				local oldSelId = table.keys(self.mSelectList)[1]
	        				local oldItem = self.mSelectList[oldSelId]
	        				local oldCellIndex
	        				for index, item in pairs (self.mCurrViewData.dataList or {}) do
	        					if item.Id == oldSelId then
	        						oldCellIndex = index
	        						break
	        					end
	        				end
	        				if oldCellIndex then
	        					self.mSelectList = {}
	        					local lvItem = self.mListView:getItem(oldCellIndex - 1)
	        					lvItem:removeAllChildren()
	        					self:createTreasureCell(lvItem, cellSize, oldItem)
	        				end
	        			else
	        				cellItem.checkBox:setCheckState(false)
	        				ui.showFlashView(TR("每次只能选择%d个", self.mCurrViewData.selMaxCount))
		        			return
	        			end
	        		end

	        		self.mSelectList[treasureInfo.Id] = treasureInfo
	        	else
	        		self.mSelectList[treasureInfo.Id] = nil
	        	end
	        end
	    })
	    if self.mSelectList[treasureInfo.Id] then
	    	checkBox:setCheckState(true)
	    else
	    	checkBox:setCheckState(false)
	    end
	    checkBox:setPosition(cc.p(cellSize.width - 80, cellSize.height / 2 - itemDistence))
	    cellItem:addChild(checkBox)
	    cellItem.checkBox = checkBox
	else
		-- 需要重生的标识
		local rebirthLabel = ui.newLabel({
			text = TR("需重生"),
			color = Enums.Color.eRed,
		})
		rebirthLabel:setAnchorPoint(cc.p(0.5, 0.5))
		rebirthLabel:setPosition(cellSize.width - 80, cellSize.height / 2 - itemDistence)
		cellItem:addChild(rebirthLabel)
	end
end

-- 创建列表的内功心法数据
function SelectLayer:createZhenjueCell(cellItem, cellSize, zhenjueInfo)
	-- 创建单个条目的背景
    local tempSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width - 20, cellSize.height))
	tempSprite:setPosition(cellSize.width / 2, cellSize.height / 2 - itemDistence)
	cellItem:addChild(tempSprite)

	-- 创建人物头像卡牌
	local tempCard = CardNode:create({allowClick = true,})
	tempCard:setPosition(80, cellSize.height / 2 - itemDistence)
	tempCard:setZhenjue(zhenjueInfo, {CardShowAttr.eBorder, CardShowAttr.eStep})
	cellItem:addChild(tempCard)

	-- 人物的模型数据
	local tempModel = ZhenjueModel.items[zhenjueInfo.ModelId]
	local colorLv = tempModel.colorLV

	-- 创建卡牌的名称
	local nameLabel = ui.newLabel({
		text = tempModel.name,
		color = Utility.getColorValue(colorLv, 1),
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
	})
	nameLabel:setAnchorPoint(cc.p(0, 0.5))
	nameLabel:setPosition(160, cellSize.height - 30 - itemDistence)
	cellItem:addChild(nameLabel)

	-- 创建卡牌的星级
	local tempNode = ui.newStarLevel(colorLv)
	tempNode:setAnchorPoint(cc.p(0, 0.5))
	tempNode:setPosition(160, cellSize.height - 90 - itemDistence)
	cellItem:addChild(tempNode)

	-- 创建选择框
	local checkBox = ui.newCheckbox({
        normalImage = "c_60.png",
        selectImage = "c_61.png",
        callback = function(isSelected)
        	if isSelected then
        		if self.mCurrViewData.selMaxCount <= table.nums(self.mSelectList) then
        			if self.mCurrViewData.selMaxCount == 1 then
        				local oldSelId = table.keys(self.mSelectList)[1]
        				local oldItem = self.mSelectList[oldSelId]
        				local oldCellIndex
        				for index, item in pairs (self.mCurrViewData.dataList or {}) do
        					if item.Id == oldSelId then
        						oldCellIndex = index
        						break
        					end
        				end
        				if oldCellIndex then
        					self.mSelectList = {}
        					local lvItem = self.mListView:getItem(oldCellIndex - 1)
        					lvItem:removeAllChildren()
        					self:createZhenjueCell(lvItem, cellSize, oldItem)
        				end
        			else
        				cellItem.checkBox:setCheckState(false)
        				ui.showFlashView(TR("每次只能选择%d个", self.mCurrViewData.selMaxCount))
	        			return
        			end
        		end
        		self.mSelectList[zhenjueInfo.Id] = zhenjueInfo
        	else
        		self.mSelectList[zhenjueInfo.Id] = nil
        	end
        end
    })
    if self.mSelectList[zhenjueInfo.Id] then
    	checkBox:setCheckState(true)
    else
    	checkBox:setCheckState(false)
    end
    checkBox:setPosition(cc.p(cellSize.width - 80, cellSize.height / 2 - itemDistence))
    cellItem:addChild(checkBox)
    cellItem.checkBox = checkBox
end

-- 创建列表的外功秘籍数据
function SelectLayer:createPetCell(cellItem, cellSize, petInfo)
	-- 创建单个条目的背景
    local tempSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width - 20, cellSize.height))
	tempSprite:setPosition(cellSize.width / 2, cellSize.height / 2 - itemDistence)
	cellItem:addChild(tempSprite)

	-- 创建人物头像卡牌
	local tempCard = CardNode.createCardNode({
            resourceTypeSub = ResourcetypeSub.ePet,
            instanceData = petInfo,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eLevel, CardShowAttr.eStep},
        })
	tempCard:setPosition(80, cellSize.height / 2 - itemDistence)
	cellItem:addChild(tempCard)


	-- 外功秘籍的模型数据
	local tempModel = PetModel.items[petInfo.ModelId]
	local colorLv = Utility.getQualityColorLv(tempModel.quality)

	-- 显示名称
	local nameLabel = ui.newLabel({
		text = tempModel.name,
		color = Utility.getColorValue(colorLv, 1),
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
	})
	nameLabel:setAnchorPoint(cc.p(0, 0.5))
	nameLabel:setPosition(140, cellSize.height / 2 + 30 - itemDistence)
	cellItem:addChild(nameLabel)

	local petAttrInfo = Utility.getPetAttrs(PetObj:getPet(petInfo.Id))
    local tempToPercent = {}
    for k,v in pairs(petAttrInfo) do
        table.insert(tempToPercent, k , v)
        local needPercent = ConfigFunc:fightAttrIsPercentByValue(k)
        if needPercent then
            local tempV = tostring(tonumber(v) / 100) .. "%"
            table.insert(tempToPercent, k , tempV)
        end
    end

 	local attrLabelList = {}
    local startPosX = 140
    local startPosY = 60
    local stepPosY = 25
    if table.nums(tempToPercent) > 9 then
    	posx, posy = nameLabel:getPosition()
		nameLabel:setPosition(posx, posy + 12)
		startPosY = 73
		stepPosY = 21
    end
    for i,v in pairs(tempToPercent) do
    	local attrLabel = ui.newLabel({
    		text = TR("%s +%s%s",FightattrName[i], Enums.Color.eDarkGreenH, v),
    		color = Enums.Color.eBlack,
            size = 18,
    		})
    	attrLabel:setAnchorPoint(0, 0.5)
    	table.insert(attrLabelList, attrLabel)
    	cellItem:addChild(attrLabel)
    end

    for i,v in ipairs(attrLabelList) do
        if i%3 == 1 then
            startPosX  = 140
            if i ~= 1 then
                startPosY = startPosY - stepPosY*(i%3)
            end
		elseif i%3 == 2 then
            startPosX  = startPosX + 120
        elseif i%3 == 0 then
            startPosX  = startPosX + 120
		end
    	v:setPosition(startPosX, startPosY)
    end

	-- 创建选择框
	local checkBox = ui.newCheckbox({
        normalImage = "c_60.png",
        selectImage = "c_61.png",
        callback = function(isSelected)
        	if isSelected then
        		if self.mCurrViewData.selMaxCount <= table.nums(self.mSelectList) then
        			if self.mCurrViewData.selMaxCount == 1 then
        				local oldSelId = table.keys(self.mSelectList)[1]
        				local oldItem = self.mSelectList[oldSelId]
        				local oldCellIndex
        				for index, item in pairs (self.mCurrViewData.dataList or {}) do
        					if item.Id == oldSelId then
        						oldCellIndex = index
        						break
        					end
        				end
        				if oldCellIndex then
        					self.mSelectList = {}
        					local lvItem = self.mListView:getItem(oldCellIndex - 1)
        					lvItem:removeAllChildren()
        					self:createPetCell(lvItem, cellSize, oldItem)
        				end
        			else
        				cellItem.checkBox:setCheckState(false)
        				ui.showFlashView(TR("每次只能选择%d个", self.mCurrViewData.selMaxCount))
	        			return
        			end
        		end
        		self.mSelectList[petInfo.Id] = petInfo
        	else
        		self.mSelectList[petInfo.Id] = nil
        	end
        end
    })
    if self.mSelectList[petInfo.Id] then
    	checkBox:setCheckState(true)
    else
    	checkBox:setCheckState(false)
    end
    checkBox:setPosition(cc.p(cellSize.width - 50, cellSize.height / 2 - itemDistence))
    cellItem:addChild(checkBox)
    cellItem.checkBox = checkBox
end

function SelectLayer:createZhenshouCell(cellItem, cellSize, zhenshouInfo)
	-- 创建单个条目的背景
    local tempSprite = ui.newScale9Sprite("c_18.png", cc.size(cellSize.width - 20, cellSize.height))
	tempSprite:setPosition(cellSize.width / 2, cellSize.height / 2 - itemDistence)
	cellItem:addChild(tempSprite)

	-- 创建人物头像卡牌
	local tempCard = CardNode:create({allowClick = true,})
	tempCard:setPosition(80, cellSize.height / 2 - itemDistence)
	tempCard:setZhenshou(zhenshouInfo, {CardShowAttr.eBorder, CardShowAttr.eLevel, CardShowAttr.eStep, CardShowAttr.eMedicine})
	cellItem:addChild(tempCard)

	-- 人物的模型数据
	local tempModel = ZhenshouModel.items[zhenshouInfo.ModelId]
	local colorLv = Utility.getQualityColorLv(tempModel.quality)

	-- 创建卡牌的名称
	local nameLabel = ui.newLabel({
		text = tempModel.name,
		color = Utility.getColorValue(colorLv, 1),
		outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
	})
	nameLabel:setAnchorPoint(cc.p(0, 0.5))
	nameLabel:setPosition(160, cellSize.height - 25 - itemDistence)
	cellItem:addChild(nameLabel)

	-- 创建卡牌的资质
	local qualityLabel = ui.newLabel({
		text = TR("资质:%s%d", Enums.Color.eBlackH, tempModel.quality),
		color = Enums.Color.eBrown,
	})
	qualityLabel:setAnchorPoint(cc.p(0, 0.5))
	qualityLabel:setPosition(160, cellSize.height * 0.5 - itemDistence)
	cellItem:addChild(qualityLabel)

	-- 创建卡牌的星级
	local tempNode = ui.newStarLevel(colorLv)
	tempNode:setAnchorPoint(cc.p(0, 0.5))
	tempNode:setPosition(160, cellSize.height - 90 - itemDistence)
	cellItem:addChild(tempNode)

	-- 创建选择框
	if zhenshouInfo.Step == 0 or self.mSelectType == Enums.SelectType.eRebirth then
		local checkBox = ui.newCheckbox({
	        normalImage = "c_60.png",
	        selectImage = "c_61.png",
	        callback = function(isSelected)
	        	if isSelected then
	        		if self.mCurrViewData.selMaxCount <= table.nums(self.mSelectList) then
	        			if self.mCurrViewData.selMaxCount == 1 then
	        				local oldSelId = table.keys(self.mSelectList)[1]
	        				local oldItem = self.mSelectList[oldSelId]
	        				local oldCellIndex
	        				for index, item in pairs (self.mCurrViewData.dataList or {}) do
	        					if item.Id == oldSelId then
	        						oldCellIndex = index
	        						break
	        					end
	        				end
	        				if oldCellIndex then
	        					self.mSelectList = {}
	        					local lvItem = self.mListView:getItem(oldCellIndex - 1)
	        					lvItem:removeAllChildren()
	        					self:createHeroCell(lvItem, cellSize, oldItem)
	        				end
	        			else
	        				cellItem.checkBox:setCheckState(false)
	        				ui.showFlashView(TR("每次只能选择%d个", self.mCurrViewData.selMaxCount))
		        			return
	        			end
	        		end

	        		self.mSelectList[zhenshouInfo.Id] = zhenshouInfo
	        	else
	        		self.mSelectList[zhenshouInfo.Id] = nil
	        	end
	        end
	    })
	    if self.mSelectList[zhenshouInfo.Id] then
	    	checkBox:setCheckState(true)
	    else
	    	checkBox:setCheckState(false)
	    end
	    checkBox:setPosition(cc.p(cellSize.width - 80, cellSize.height / 2 - itemDistence))
	    cellItem:addChild(checkBox)
	    cellItem.checkBox = checkBox
	else
		-- 需要重生的标识
		local rebirthLabel = ui.newLabel({
			text = TR("需重生"),
			color = Enums.Color.eRed,
		})
		rebirthLabel:setAnchorPoint(cc.p(0.5, 0.5))
		rebirthLabel:setPosition(cellSize.width - 80, cellSize.height / 2 - itemDistence)
		cellItem:addChild(rebirthLabel)
	end
end

return SelectLayer
