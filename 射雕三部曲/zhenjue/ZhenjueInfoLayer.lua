--[[
	文件名:ZhenjueInfoLayer.lua
	描述：内功心法详细信息页面
	创建人: peiyaoqiang
	创建时间: 2017.04.05
--]]

local ZhenjueInfoLayer = class("ZhenjueInfoLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
	{
		zhenjueInfo: 内功心法的详情，如果不传入该参数，那么只展示modelId对应的内功心法基础信息
		modelId: 内功心法模型Id, 如果 zhenjueInfo 为有效值，该参数失效
	}
]]
function ZhenjueInfoLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})
	
	-- 处理参数
	params = params or {}
	self.mZhenjueItem = params.zhenjueInfo
	if self.mZhenjueItem then
		self.mModelId = self.mZhenjueItem.ModelId
	else
		self.mModelId = params.modelId or params.ModelId
	end
	self.mModel = ZhenjueModel.items[self.mModelId]

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 
	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function ZhenjueInfoLayer:initUI()
	-- 背景图片
	local bgSprite = ui.newSprite("ng_17.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	local pic = Figure.newZhenjue({
		modelId = self.mModelId,
		needAction = true,
	})
	pic:setAnchorPoint(cc.p(0.5, 0))
	pic:setPosition(320, 620)
	self.mParentLayer:addChild(pic)

	-- 面板背景
	local bgSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 570))
	bgSprite:setAnchorPoint(cc.p(0.5, 0))
	bgSprite:setPosition(320, 0)
	self.mParentLayer:addChild(bgSprite)

	-- 灰色背景
    local tmpGraySprite = ui.newScale9Sprite("c_17.png", cc.size(620, 520))
    tmpGraySprite:setAnchorPoint(0.5, 1)
    tmpGraySprite:setPosition(320, 527)
    bgSprite:addChild(tmpGraySprite)

	-- 显示名字和星级
	local hColor = Utility.getColorValue(self.mModel.colorLV, 2)
	local strName = string.format("%s[%s]%s", hColor, Utility.getZhenjueViewInfo(self.mModel.typeID).typeName, self.mModel.name)
	if (self.mZhenjueItem ~= nil) and (self.mZhenjueItem.Step ~= nil) and (self.mZhenjueItem.Step > 0) then
		strName = strName .. "+" .. self.mZhenjueItem.Step
	end
	Figure.newNameAndStar({
		parent = bgSprite,
		position = cc.p(320, 1120),
		nameText = strName,
		starCount = self.mModel.colorLV,
	})

	-- 创建滑动列表
	self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(640, 505))
    self.mListView:setItemsMargin(6)
    self.mListView:setAnchorPoint(cc.p(0.5, 0))
    self.mListView:setPosition(320, 15)
    bgSprite:addChild(self.mListView)

	self:createBaseInfo()
	self:createUpAttrInfo()
	self:createSkillInfo()
	self:createZhenjuePr()
	self:createIntro()
	
	-- 获取途径
	local getZhenjue = ui.newButton({
		normalImage = "tb_34.png",
		clickAction = function()
			LayerManager.addLayer({name = "teambattle.TeambattleShop",})
		end
	})
	getZhenjue:setPosition(580, 610)
	self.mParentLayer:addChild(getZhenjue)
	
	-- 关闭按钮
	local mCloseBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	mCloseBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
	self.mParentLayer:addChild(mCloseBtn)
end

--基本属性
function ZhenjueInfoLayer:createBaseInfo()
	-- 基本属性
	local baseAttr = Utility.analysisStrAttrList(self.mModel.initAttrStr)
	local baseSize = cc.size(600, 150)
	local baseAttrSprite = self:createAtrrBg(TR("基础属性"), baseSize)
	self.mListView:pushBackCustomItem(baseAttrSprite)

	local nStepTimes = ZhenjueObj:getTimesOfStep(self.mZhenjueItem)
	for index = 1,#baseAttr do
		local label = ui.newLabel({
			text = string.format("%s: %s%d", FightattrName[baseAttr[index].fightattr], "#D17B00", math.floor(baseAttr[index].value * nStepTimes)),
			color = cc.c3b(0x46, 0x22, 0x0d),
		})
		label:setAnchorPoint(cc.p(0, 0.5))
		label:setPosition(cc.p((index - 1) % 2 * 350 + 80, baseSize.height - 70 - math.floor((index - 1) / 2) * 40))
		baseAttrSprite:addChild(label)
	end
end

-- 洗炼属性
function ZhenjueInfoLayer:createUpAttrInfo()
	-- 洗炼属性
	if self.mZhenjueItem and self.mZhenjueItem.UpAttrData then
		local attachSize = cc.size(600, 150)
		local attachAttrSprite = self:createAtrrBg(TR("洗炼属性"), attachSize)
		self.mListView:pushBackCustomItem(attachAttrSprite)

		local pos = 1
		for index, value in pairs(self.mZhenjueItem.UpAttrData) do
			local label = ui.newLabel({
				text = string.format("%s: %s%d", FightattrName[tonumber(index)], "#D17B00", value),
				color = cc.c3b(0x46, 0x22, 0x0d),
			})
			label:setAnchorPoint(cc.p(0, 0.5))
			label:setPosition(cc.p((pos - 1) % 2 * 350 + 80, attachSize.height - 70 - math.floor((pos - 1) / 2) * 40))
			attachAttrSprite:addChild(label)
			pos = pos + 1
		end
	end
end

--技能说明
function ZhenjueInfoLayer:createSkillInfo()
	local talSize = cc.size(600, 110)
	local talSprite = self:createAtrrBg(TR("技能说明"), talSize)
	self.mListView:pushBackCustomItem(talSprite)

	if self.mModel.colorLV >= 5 then
		local talLabel = ui.newLabel({
			text = string.format("%s:%s%s", TalModel.items[self.mModel.talModelID].name, "#D17B00", TalModel.items[self.mModel.talModelID].intro),
			color = cc.c3b(0x46, 0x22, 0x0d),
			dimensions = cc.size(500, 0),
		})
		talLabel:setPosition(talSize.width / 2 + 25, 43)
		talSprite:addChild(talLabel)
	else
		local lab = ui.newLabel({
			text = TR("橙色或更高品质的内功心法才能触发内功心法技能"),
			color = cc.c3b(0x46, 0x22, 0x0d),
		})
		lab:setPosition(talSize.width / 2+25, 40)
		talSprite:addChild(lab)
	end
end

-- 创建神兵羁绊属性
function ZhenjueInfoLayer:createZhenjuePr()
	local prHeroModel = ZhenjueModel.items[self.mModelId].prHeroModelIds

	-- 没有羁绊属性就不显示
	if not prHeroModel or not next(prHeroModel) then
		return
	end
	local bgSize = cc.size(600, 225)
	local bgSprite = self:createAtrrBg(TR("羁绊"), bgSize)
	self.mListView:pushBackCustomItem(bgSprite)

	-- 获取上阵人物信息
	local formationHero = {}
	for key, item in pairs(FormationObj.mSlotHeros) do
        if key ~= "count" then
            formationHero[item.Id] = item
        end
    end
    -- 判断是否需要包含江湖后援团
    for key, item in pairs(FormationObj.mMateHeros) do
        if key ~= "count" then
            formationHero[item.Id] = item
        end
    end
    
	-- 文字显示
	local font = ui.newLabel({
			text = TR("该内功心法可与以下侠客形成羁绊"),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 23,
		})
	font:setAnchorPoint(cc.p(0.5, 1))
	font:setPosition(cc.p(320, 150 + 25))
	bgSprite:addChild(font)
	-- 添加羁绊人物表
	local card = {}
	local isMianHeroMale = 0
	local isMianHeroFeMale = 0
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
			maxViewWidth = 550, -- 显示的最大宽度
        	space = 10, -- 卡牌之间的间距, 默认为 10
        	cardDataList = card,
        })
	cardList:setAnchorPoint(cc.p(0.5, 1.0))
	cardList:setPosition(cc.p(320, 100 + 10 + 25))
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

-- 创建内功简介
function ZhenjueInfoLayer:createIntro()
	local introSize = cc.size(600, 120)
	local introSprite = self:createAtrrBg(TR("内功心法简介"), introSize)
	self.mListView:pushBackCustomItem(introSprite)

	local introLabel = ui.newLabel({
			text = self.mModel.intro,
			color = cc.c3b(0x46, 0x22, 0x0d),
			dimensions = cc.size(540, 0)
		})
	introLabel:setPosition(introSize.width / 2 + 25, 40)
	introSprite:addChild(introLabel)
end

-- 创建每一个属性背景
function ZhenjueInfoLayer:createAtrrBg(titleText, bgSize)
	local custom_item = ccui.Layout:create()
    custom_item:setIgnoreAnchorPointForPosition(false)
    
	local tmpBgSprite = ui.newNodeBgWithTitle(custom_item, bgSize, titleText)
	local tmpBgSize = tmpBgSprite:getContentSize()

	custom_item:setContentSize(tmpBgSize)
	custom_item:setAnchorPoint(cc.p(0.5, 0.5))
    custom_item:setPosition(cc.p(320, tmpBgSize.height/2))
    tmpBgSprite:setPosition(cc.p(320, tmpBgSize.height/2))

	return custom_item
end

return ZhenjueInfoLayer