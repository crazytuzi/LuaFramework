--[[
	文件名:EquipDetailView.lua
	描述：装备详细信息页面
	创建人：peiyaoqiang
	创建时间：2017.03.12
--]]

local EquipDetailView = class("EquipDetailView", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
	{
		viewSize: 显示大小
		equipInfo: 装备实例Id，如果不传入该参数，那么只展示一类的装备的信息
		ModelId: 装备模型Id, 如果equipInfo 为有效值，则该参数失效
	}
]]
function EquipDetailView:ctor(params)
	params = params or {}
	-- 显示大小
	self.mViewSize = params.viewSize

	self:setContentSize(self.mViewSize)
	self:setIgnoreAnchorPointForPosition(false)

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

    --
	self:initUINoParam()
	self:setEquip(params.equipInfo, params.equipModelId)
end

-- 初始化数据
function EquipDetailView:initData(equipInfo, equipModelId)
	if equipInfo ~= nil then
		self.mEquipItem = equipInfo
		self.mEquipModelId = self.mEquipItem.ModelId
	else
		self.mEquipItem = nil
		self.mEquipModelId = equipModelId
	end
	self.mEquipModel = EquipModel.items[self.mEquipModelId]
end

-- 重新设置显示的装备
function EquipDetailView:setEquip(equipInfo, equipModelId)
	self:initUI()
	self:initData(equipInfo, equipModelId)

	-- 创建基本属性
    self:createBaseAttr()
    -- 创建与主角搭配属性
    self:createMainHeroAttr()
    -- 创建进阶属性
    self:createStepAttr()
    -- 创建羁绊属性
    self:createEquipPr()
    -- 创建套装属性
    self:createGroupAttr()
    -- 创建装备介绍
    self:createIntroAttr()
end
function EquipDetailView:initUI()
	-- 存在列表就移除
	if self.mListView then
		self.mListView:removeFromParent()
		self.mListView = nil
	end
	-- 创建滑动列表
	self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(self.mViewSize)
    self.mListView:setItemsMargin(6)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(self.mViewSize.width / 2, 0)
    self:addChild(self.mListView)

end
-- 初始化页面控件(没有传入装备id)
function EquipDetailView:initUINoParam()
	-- 创建滑动列表
	self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(self.mViewSize)
    self.mListView:setItemsMargin(6)
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setPosition(cc.p(self.mViewSize.width, self.mViewSize.height))
    self:addChild(self.mListView)
end

-- 创建属性的背景
function EquipDetailView:createAtrrBg(titleText, bgSize)
	local custom_item = ccui.Layout:create()
    custom_item:setIgnoreAnchorPointForPosition(false)
    
	local tmpBgSprite = ui.newNodeBgWithTitle(custom_item, bgSize, titleText)
	local tmpBgSize = tmpBgSprite:getContentSize()

	custom_item:setContentSize(tmpBgSize)
	custom_item:setAnchorPoint(cc.p(0.5, 0.5))
    custom_item:setPosition(cc.p(tmpBgSize.width/2, tmpBgSize.height/2))
    tmpBgSprite:setPosition(cc.p(tmpBgSize.width/2, tmpBgSize.height/2))

	return custom_item
end

-- 显示等级 资质
function EquipDetailView:getBaseArr(equipModelID,tableData)
	local ret = {}
	local retName  = {TR("等级"), TR("资质")}
	local retValue = {string.format("%s/%s",self.mEquipItem and self.mEquipItem.Lv or 0, PlayerAttrObj:getPlayerInfo().Lv * 2), EquipModel.items[equipModelID].quality}
	for i=1,2 do
		local temp = {}
		temp.name  = retName[i]
		temp.value = retValue[i]
		if tableData then
			table.insert(tableData, temp)
		else
			table.insert(ret, temp)
		end
	end
	return tableData and tableData or ret
end
-- 创建基本属性
function EquipDetailView:createBaseAttr()
	local width  = 595
	local height = 60
	-- 处理数据
	local tempData = {}
	self:getBaseArr(self.mEquipModelId,tempData)
	local data = ConfigFunc:getEquipBaseViewItem(self.mEquipModelId, self.mEquipItem and self.mEquipItem.Lv or 0)
	for k,v in pairs(data) do
		table.insert(tempData, v)
	end
	-- 没有数据就不显示
	if not tempData or not next(tempData) then
		return
	end

	-- 根据数据计算高度
	local lengh = #tempData
	local num = math.ceil(lengh/2) - 1 
	num = num < 0 and 0 or num
	num = num + 1
	height = 35 + 40 * num
	local bgSprite = self:createAtrrBg(TR("基础属性"), cc.size(width, height))
	self.mListView:pushBackCustomItem(bgSprite)

	-- 添加属性文字
	for i,v in ipairs(tempData) do
		-- 判断锚点 高度
		local mark = i%2 
		mark = mark ~= 0 and 0 or 1
		local posY = math.ceil(i/2)
		-- 文字
		local label = ui.newLabel({
			text = string.format("%s: %s%s", v.name, Enums.Color.eNormalGreenH, v.value),
			color = cc.c3b(0x46, 0x22, 0x0d),
		}) 
		label:setAnchorPoint(cc.p(0,1))
		label:setPosition(cc.p((width / 2) * mark + 30, height - 45 - (posY - 1) * 35 ))
		bgSprite:addChild(label)
	end
end

-- 创建与主角搭配属性
function EquipDetailView:createMainHeroAttr()
	local width  = 595
	local height = 60
	local tempData = ConfigFunc:getEquipBaseHeroViewItem(self.mEquipModelId)
	-- 没有就不显示
	if not tempData or not next(tempData) then
		return
	end
	-- 处理数据
	local lengh = #tempData
	local num = math.ceil(lengh/2) - 1 
	num = num < 0 and 0 or num
	num = num + 1
	height = 35 + 40 * num
	local bgSprite = self:createAtrrBg(TR("与主角搭配"),cc.size(width, height))
	self.mListView:pushBackCustomItem(bgSprite)

	-- 添加属性文字
	for i,v in ipairs(tempData) do
		-- 判断锚点 高度
		local mark = i%2 
		mark = mark ~= 0 and 0 or 1
		local posY = math.ceil(i/2)
		-- 文字
		local label = ui.newLabel({
			text = string.format("%s: %s%s", v.name, Enums.Color.eNormalGreenH, v.value),
			color = cc.c3b(0x46, 0x22, 0x0d),
			}) 
		label:setAnchorPoint(cc.p(0,1))
		label:setPosition(cc.p((width / 2) * mark + 30, height - 45 - (posY - 1) * 35 ))
		bgSprite:addChild(label)
	end

end

-- 创建进阶属性
function EquipDetailView:createStepAttr()
	local width  = 595
	local height = 115
	-- 获取数据
	local currStep = ConfigFunc:getEquipStepViewItem(self.mEquipModelId, self.mEquipItem and self.mEquipItem.Step or 0)
	local nextStep = ConfigFunc:getEquipStepViewItem(self.mEquipModelId, self.mEquipItem and self.mEquipItem.Step + 1 or 1)
	local tempData = nextStep or currStep
	-- 没有进阶属性就不显示
	if not tempData or not next(tempData) then
		return
	end
	local bgSprite = self:createAtrrBg(TR("进阶属性"),cc.size(width, height))
	self.mListView:pushBackCustomItem(bgSprite)

	-- 添加属性文字
	for i,v in ipairs(tempData) do
		-- 判断锚点 高度
		local mark = i%2 
		mark = mark ~= 0 and 0 or 1

		-- 文字
		local label = ui.newLabel({
			text = string.format("%s: %s%s", v.name, Enums.Color.eNormalGreenH, v.value),
			color = cc.c3b(0x46, 0x22, 0x0d),
			}) 
		label:setAnchorPoint(cc.p(0,1))
		label:setPosition(cc.p((width / 2) * mark + 30, height - 45 - (math.ceil(i/2) - 1) * 35 ))
		bgSprite:addChild(label)
	end
end

-- 创建套装属性
function EquipDetailView:createEquipPr()
	-- 没有羁绊属性就不显示
	local prHeroModel = self.mEquipModel.prHeroModelIds
	if not prHeroModel or not next(prHeroModel) then
		return
	end

	--
	local width  = 595
	local height = 225
	-- 确定背景显示大小
	local bgSprite = self:createAtrrBg(TR("羁绊"),cc.size(width, height))
	self.mListView:pushBackCustomItem(bgSprite)

	-- 获取上阵人物信息
	local formationHero = {}
	for key, item in pairs(FormationObj.mSlotHeros) do
        if key ~= "count" then
            formationHero[item.Id] = item
        end
    end

    -- 文字显示
	local font = ui.newLabel({
		text = TR("该装备可与以下侠客形成羁绊"),
		color = cc.c3b(0x46, 0x22, 0x0d),
		size = 23,
	})
	font:setAnchorPoint(cc.p(0.5, 1))
	font:setPosition(cc.p(width * 0.5, 175))
	bgSprite:addChild(font)
	
	-- 添加羁绊人物表
	local card = {}
	local cardIndex = {}
	for k,v in ipairs(prHeroModel) do
		local card_ = {}
		local formationHeroId = 0
		
		card_.modelId = v
		card_.num = 1
		card_.resourceTypeSub = ResourcetypeSub.eHero
		card_.cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eName,
        }

        -- 判断人物是否在阵容
		for i,format in pairs(formationHero) do
			if format.HeroModelId == v then
				card_.cardShowAttrs = {
		            CardShowAttr.eBorder,
		            CardShowAttr.eName,
		            CardShowAttr.eSelected,
		        }
				formationHeroId = v
			end
		end
		local heroModel = HeroModel.items[v]
		-- 主角显示在第一个
		if heroModel.specialType == Enums.HeroType.eMainHero then
			if v == formationHeroId then
				table.insert(card,1,card_)
			end
		else
			table.insert(card,card_)
		end
	end
	-- 显示列表
	local cardList = ui.createCardList({
			maxViewWidth = width, -- 显示的最大宽度
        	space = 10, -- 卡牌之间的间距, 默认为 10
        	cardDataList = card,
        })
	cardList:setAnchorPoint(cc.p(0.5, 1.0))
	cardList:setPosition(cc.p(width * 0.5, 135))
	bgSprite:addChild(cardList)
	
	-- 已经上阵的英雄 增加闪光效果
	local cardListItem = cardList.getCardNodeList()
	for k,v in pairs(cardListItem) do
		local attr = v:getAttrControl() 
		if attr[CardShowAttr.eSelected] then
			ui.newEffect({
                parent = v,
                effectName = "effect_ui_liubian",
                position = cc.p(v:getContentSize().width / 2, v:getContentSize().height / 2),
                loop = true,
                endRelease = true,
                speed = 1,
            })
		end
	end
end

-- 创建套装属性
function EquipDetailView:createGroupAttr()
	local width  = 595
	local height = 180 -- 初始化高度
	local isUp, slotId = FormationObj:equipInFormation(self.mEquipItem and self.mEquipItem.Id or 0)

	-- 获取套装信息
	local dataSlotEquip = {}
	if slotId then
		dataSlotEquip = FormationObj:getSlotEquip(slotId)
	end

	-- 处理数据
	local info = self.mEquipModel
	local groupList = {}
    local data = ConfigFunc:getGroupModelIds(self.mEquipModelId)
    local EquipModelItems = EquipModel.items
    for k,v in pairs(data) do
    	local equip = EquipModelItems[v]
    	table.insert(groupList,equip)
    end

    -- 已经上阵，没有套装属性，不显示
    if not next(groupList) then
    	return
    end

	-- 计算该套装装备是否已经上阵，若上阵，添加一个标记属性（显示的时候不置灰）
	local groupIndex = 0
    for i,v in pairs(groupList) do
    	local tempGroup = {}
    	local id = v.ID
    	local isGroup = true
    	local instanceID = nil
    	for k,slot in pairs(dataSlotEquip) do
    		local equip = EquipModel.items[slot.modelId] or {}
    		if next(equip) and v.equipGroupID == equip.equipGroupID and v.typeID == equip.typeID then
    			groupIndex = groupIndex + 1
    			isGroup = false
    			instanceID = slot.Id
    		end
		end
		v.isGroup = isGroup
		v.instanceID = instanceID
    end

    -- 获取套装属性
    local groupInfo = ConfigFunc:getEquipGroupIntro(info.equipGroupID)
	-- 将套装的模型id提取出来，以便显示
    local card = {}
    for k,v in ipairs(groupList) do
		local card_ = {}
		card_.modelId = v.ID
		card_.num = 1
		card_.needGray = v.isGroup or false 
		card_.resourceTypeSub = v.typeID
		card_.instanceData = {Id = v.instanceID, ModelID = v.ID}
		card_.cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eName,
        }
		table.insert(card,card_)
	end
    
    -- 拼凑label
    local textSrc = {}
    for _,v in ipairs(groupInfo) do
    	local nNeedNum = v.needNum
    	textSrc[nNeedNum] = TR("%s件效果 |", nNeedNum)
    	for i,j in pairs(v.introList) do
    		textSrc[nNeedNum] = textSrc[nNeedNum]..string.format("%s|",j)
    	end
    end

    local newTextSrc = {}
    for k,v in pairs(textSrc) do
    	table.insert(newTextSrc, {needNum = k, str = clone(v)})
    end
    table.sort(newTextSrc, function (a, b)
    		return a.needNum < b.needNum
    	end)

    -- 需要显示的加成属性个数 方便计算高度
    local textLengh = 1
    -- 套装属性
    local textInfoTable = {}
    -- 套装属性条数
    local itemNum = {}
	for k,v in pairs(newTextSrc) do
		local t = string.splitBySep(v.str, "|")
		textLengh = #t
		table.insert(textInfoTable, k, {strList = t, needNum = v.needNum})
		textLengh = textLengh - 1
		table.insert(itemNum, k, textLengh)
	end

	-- 计算总高度
	for _, item in ipairs(itemNum) do
		height = height + math.ceil(item / 2) * 35 + 20
	end

	-- 确定背景显示大小
	local bgSprite = self:createAtrrBg(TR("套装属性"),cc.size(width, height))
	self.mListView:pushBackCustomItem(bgSprite)
	-- 显示套装图标
    local cardList = ui.createCardList({
		viewHeight = 140,
		maxViewWidth = 550, -- 显示的最大宽度
    	space = 10, -- 卡牌之间的间距, 默认为 10
    	cardDataList = card,
    	isSwallow = false,
    })
	cardList:setAnchorPoint(cc.p(0.5, 1.0))
	cardList:setPosition(cc.p(275 + 18, height - 50))
	bgSprite:addChild(cardList)

    -- 创建每一个套装效果layer
	function createInfoLayer(textInfo, idx, fontColor)
    	local widthInfo  = 595
    	local heightInfo = 60
    	local infoLayer = ccui.Layout:create()
   		infoLayer:setIgnoreAnchorPointForPosition(false)
        infoLayer:setAnchorPoint(cc.p(0.5, 1.0))
        -- 高度
        heightInfo = math.ceil(itemNum[idx] / 2) * 35
        infoLayer:setContentSize(cc.size(widthInfo, heightInfo))

        -- 将信息显示出来
        for i,v in ipairs(textInfo) do
        	if i == 1 then 
        		-- 套装效果  如2件效果等
    			local label = ui.newLabel({
	        		text = textInfo[1],
	        		color = fontColor,
	        		})
        		label:setAnchorPoint(cc.p(0, 1))
        		label:setPosition(cc.p(20, heightInfo - 17))
        		infoLayer:addChild(label)
        	else
        		-- 属性加成
        		--处理字符串
        		local temp = string.splitBySep(v, ":")
        		local label = ui.newLabel({
					text = string.format("%s:%s", temp[1], temp[2]),
					color = fontColor,
				})
        		label:setAnchorPoint(cc.p(0, 1))
        		local index = math.floor(i / 2)
        		local temp = (i % 2 == 0) and 1 or 2
        		label:setPosition(cc.p(width * temp / 3 + 20 - 50, heightInfo - index * 17 - (index - 1) * label:getContentSize().height))
        		infoLayer:addChild(label)
        	end
        end
        return infoLayer
    end
    -- 标记当前上阵的套装数量，以便下面计算显示颜色
    groupIndex = (groupIndex == 0) and 1 or groupIndex
    -- 添加叠加效果显示文字
    local y = height - 170
    for i,v in ipairs(textInfoTable) do
    	local index = v.needNum
    	-- 未形成套装的，显示棕色
    	local tmpColor = Enums.Color.eNotPrColor
    	if groupIndex >= v.needNum then
    		tmpColor = Enums.Color.ePrColor
    	end
    	-- 添加layer
		local layer = createInfoLayer(v.strList, i, tmpColor)
		layer:setAnchorPoint(0.5, 1)
		layer:setIgnoreAnchorPointForPosition(false)
    	layer:setPosition(cc.p(width / 2 , y))
    	bgSprite:addChild(layer)

    	y = y - math.ceil(itemNum[i] / 2) * 35 - 20
    end
end

-- 创建装备介绍
function EquipDetailView:createIntroAttr()
	local introText = EquipModel.items[self.mEquipModelId].intro or ""
	local introLabel = ui.newLabel({
			text = introText,
			color = cc.c3b(0x46, 0x22, 0x0d),
			dimensions = cc.size(550, 0)
		})
	local introBgSize = cc.size(595, introLabel:getContentSize().height + 87)
	local bgSprite = self:createAtrrBg(TR("装备简介"), introBgSize)

	introLabel:setAnchorPoint(cc.p(0.5, 1))
	introLabel:setPosition(cc.p(introBgSize.width / 2, introBgSize.height - 55))
	self.mListView:pushBackCustomItem(bgSprite)
	bgSprite:addChild(introLabel)
end

return EquipDetailView