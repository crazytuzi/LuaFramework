--[[
	文件名：BagLayer.lua
	描述：包裹主界面
	创建人：yanxingrui
    修改人：lengjiazhi
	创建时间： 2016.5.6
--]]

local BagLayer = class("BagLayer", function(params)
	return display.newLayer()
end)

--[[
-- 参数 params 中的各项为:
    {
        subPageType: 子页面的类型, 取值为EnumsConfig.lua文件中 BagType 的eGoodsBag、eEquipBag、eZhenjue
        thirdSubTag: 第三层类型，比如侠客里的（侠客或碎片）
    }
]]
function BagLayer:ctor(params)
    local redDotType, redDotThird = params.subPageType, params.thirdSubTag
    -- 如有碎片合成的小红点，则自动跳入指定的界面
    if not redDotType then
        if RedDotInfoObj:isValid(ModuleSub.eBagEquipDebris) then
            redDotType = BagType.eEquipBag
            redDotThird = BagType.eEquipDebrisBag
        elseif RedDotInfoObj:isValid(ModuleSub.eBagHeroDebris) then
            redDotType = BagType.eHeroBag
            redDotThird = ModuleSub.eBagHeroDebris
        elseif RedDotInfoObj:isValid(ModuleSub.eBagZhenjueDebris) then
            redDotType = BagType.eZhenjue
        end
    end
    self.mCurType = redDotType or BagType.eGoodsBag
    self.mThirdSubTag = redDotThird or nil
    self.selectId = params.selectId or nil
    self.mViewPos = params.viewPos

    self.mDataList = {}

    -- 该页面的Parent
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 子页面的parent
    self.mSubParentLayer = ui.newStdLayer()
    self:addChild(self.mSubParentLayer)

    -- 背景图片
    local bgSprite = ui.newSprite("c_128.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    --下方白板背景
    local bottomSprtie = ui.newScale9Sprite("c_19.png", cc.size(640, 1000))
    bottomSprtie:setAnchorPoint(0.5, 0)
    bottomSprtie:setPosition(320, 0)
    self.mParentLayer:addChild(bottomSprtie)

    -- -- 包裹空间文字背景图片
    -- local countBack = ui.newScale9Sprite("c_24.png", cc.size(118, 32))
    -- countBack:setPosition(550, 940)
    -- self.mParentLayer:addChild(countBack)

    --  countLabel = ui.newLabel({
    --     text = TR("包裹空间"),
    --     color = cc.c3b(0x46, 0x22, 0x0d),
    --     -- outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
    --     size = 22,
    -- })
    -- countLabel:setAnchorPoint(cc.p(0, 0.5))
    -- countLabel:setPosition(400, 940)
    -- self.mParentLayer:addChild(countLabel)

    -- 退出按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn, 100)

    -- 创建分页
    self:showTabLayer()

    -- 创建顶部资源
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        needFAP = false,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eSTA, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(topResource)

    -- 播放音效
    MqAudio.playEffect("chuwu_open.mp3")
end

-- 创建分页
function BagLayer:showTabLayer()
    self.tabItems = {
        {
			fontSize = 22,
			outlineColor = cc.c3b(0x8b, 0x4b, 0x3b),
			outlineSize = 2,
            text = TR("道具"),
            tag = BagType.eGoodsBag,
            moduleId = ModuleSub.eBagProps,
        },
    }
    local zhenjueStatus = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eZhenjue, false) and ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eZhenjue)
    local petStatus = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.ePet, false) and ModuleInfoObj:moduleIsOpenInServer(ModuleSub.ePet)
    local fashionStatus = ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eFashion, false) and ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eFashion)
    if zhenjueStatus or petStatus or fashionStatus then
        table.insert(self.tabItems,{
            text = TR("武学"),
            fontSize = 22,
            outlineColor = cc.c3b(0x8b, 0x4b, 0x3b),
            outlineSize = 2,
            tag = BagType.eZhenjue,
            needRedDot = true,
            moduleId = Enums.ClientRedDot.eBagPetAndZhenJue,
        })
    end

    --判断服务器是不是开启阵决
    -- if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eZhenjue, false) and ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eZhenjue) then
   --      table.insert(self.tabItems,{
   --          text = TR("内功"),
			-- fontSize = 22,
			-- outlineColor = cc.c3b(0x8b, 0x4b, 0x3b),
			-- outlineSize = 2,
   --          tag = BagType.eZhenjue,
   --          needRedDot = true,
   --          moduleId = ModuleSub.eBagZhenjueDebris,
   --      })
    -- end
    -- if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.ePet, false) and ModuleInfoObj:moduleIsOpenInServer(ModuleSub.ePet) then
   --      table.insert(self.tabItems,{
   --          text = TR("外功"),
			-- fontSize = 22,
			-- outlineColor = cc.c3b(0x8b, 0x4b, 0x3b),
			-- outlineSize = 2,
   --          tag = BagType.ePetBag,
   --          needRedDot = true,
   --          moduleId = ModuleSub.eBagPets,
   --      })
    -- end

    if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBagTreasure, false) and ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eBagTreasure) then
        table.insert(self.tabItems,{
			text = TR("神兵"),
			fontSize = 22,
			outlineColor = cc.c3b(0x8b, 0x4b, 0x3b),
			outlineSize = 2,
            tag = BagType.eTreasureBag,
            moduleId = ModuleSub.eBagTreasure,
        })
    end

	--装备
	if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eEquip, false) and ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eEquip) then
		table.insert(self.tabItems,{
			text = TR("装备"),
			fontSize = 22,
			outlineColor = cc.c3b(0x8b, 0x4b, 0x3b),
			outlineSize = 2,
			needRedDot = true,
			tag = BagType.eEquipBag,
			moduleId = Enums.ClientRedDot.eBagEquipAndDebris,
		})
	end

	--装备碎片
	if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBagEquipDebris, false) and ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBagEquipDebris) then
		-- table.insert(self.tabItems,{
		-- 	text = TR("装备"),
		-- 	fontSize = 22,
		-- 	outlineColor = cc.c3b(0x8b, 0x4b, 0x3b),
		-- 	outlineSize = 2,
		-- 	needRedDot = true,
		-- 	tag = BagType.eEquipDebrisBag,
		-- 	moduleId = ModuleSub.eBagEquipDebris,
		-- })
	end

	--侠客
	if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eHero, false) and ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eHero) then
		table.insert(self.tabItems,{
			text = TR("侠客"),
			fontSize = 22,
			outlineColor = cc.c3b(0x8b, 0x4b, 0x3b),
			outlineSize = 2,
			needRedDot = true,
			tag = BagType.eHeroBag,
			moduleId = Enums.ClientRedDot.eBagHeroAndDebris,
		})
	end

    --宝石
    if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eImprint, false) and ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eImprint) then
        table.insert(self.tabItems,{
            text = TR("宝石"),
            fontSize = 22,
            outlineColor = cc.c3b(0x8b, 0x4b, 0x3b),
            outlineSize = 2,
            needRedDot = true,
            tag = BagType.eGemBag,
        })
    end

	--时装碎片eBagFashionDebris
	-- if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBagHeroDebris, false) and ModuleInfoObj:moduleIsOpenInServer(ModuleSub.eBagHeroDebris) then
	-- 	table.insert(self.tabItems,{
	-- 		text = TR("侠客"),
	-- 		fontSize = 26,
	-- 		outlineColor = cc.c3b(0x8b, 0x4b, 0x3b),
	-- 		outlineSize = 2,
	-- 		tag = BagType.eBagFashionDebris,
	-- 		moduleId = ModuleSub.eBagHeroDebris,
	-- 	})
	-- end


    -- 创建tablayer
    self.tableLayer = ui.newTabLayer({
        btnInfos = self.tabItems,
        normalImage = "lt_05.png",
        lightedImage = "lt_04.png",
        btnSize = cc.size(95, 46),
        defaultSelectTag = self.mCurType,
        space = 7,
		viewSize = cc.size(560, 80),
        onSelectChange = function (selectBtnTag)
            self:addElements(selectBtnTag)
        end,
    })
	self.tableLayer:setAnchorPoint(cc.p(0, 0.5))
    self.tableLayer:setPosition(cc.p(0, 1025))
    self.mParentLayer:addChild(self.tableLayer)
	local btnTabel = self.tableLayer:getTabBtns()
	-- for index, item in pairs(btnTabel) do
	-- 	if item.tag == BagType.eHeroDebrisBag or item.tag == BagType.eEquipDebrisBag then
	-- 		local suiSprite = ui.newSprite("c_153.png")
	-- 		suiSprite:setPosition(cc.p(item:getContentSize().width * 0.1, item:getContentSize().height * 0.8))
	-- 		item:addChild(suiSprite)
	-- 	end
	-- end



    -- 页面切换按钮的new标识
    for _, button in pairs(self.tabItems) do
        local redDotModuleId = button.moduleId
        local tagButton = self.tableLayer:getTabBtnByTag(button.tag)
        -- 添加new
        if redDotModuleId then
            local function dealNewVisible(newSprite)
                newSprite:setVisible(RedDotInfoObj:isNewValid(redDotModuleId))
            end
            ui.createAutoBubble({parent = tagButton, isNew = true, eventName = RedDotInfoObj:getNewEvents(redDotModuleId),
                refreshFunc = dealNewVisible})

            -- 添加合成小红点
            if button.needRedDot then
                local function dealRedDotVisible(redDotSprite)
                    redDotSprite:setVisible(RedDotInfoObj:isValid(redDotModuleId))
                end
                ui.createAutoBubble({parent = tagButton, eventName = RedDotInfoObj:getEvents(redDotModuleId),
                    refreshFunc = dealRedDotVisible, position = cc.p(0.9, 0.8)})
            end
        end
    end
end

-- 获取恢复该页面数据
function BagLayer:getRestoreData()
    local retData = {}

    retData.subPageType = self.mCurType
    retData.thirdSubTag = self.mThirdSubTag
    retData.selectId = self.selectId
    retData.viewPos = self.viewPos

    return retData
end

-- 根据所选择标签赋值为当前所选择类型，并刷新所选择标签的列表页面
function BagLayer:addElements(index)

	-- 清空之前的显示列表
	self.mSubParentLayer:removeAllChildren()

    if index == BagType.eGoodsBag then
        self.mCurType = BagType.eGoodsBag
        self.hadViewProp = true
        local goodsLayer = require("bag.BagGoodsLayer"):create({selectId = self.selectId})
        self.mSubParentLayer:addChild(goodsLayer)
    elseif index == BagType.eTreasureBag then
        self.mCurType = BagType.eTreasureBag
        self.hadViewEquipTreasure = true
        local equipLayer = require("bag.BagTreasureLayer"):create({selectId = self.selectId, viewPos = self.mViewPos})
        self.mSubParentLayer:addChild(equipLayer)
    elseif index == BagType.eZhenjue then --包含了内功外功
        self.mCurType = BagType.eZhenjue
        self.hadViewNewZhenJue = true
        local zhenjueLayer = require("bag.BagWuxueLayer"):create({subPageType = self.mThirdSubTag, selectId = self.selectId, viewPos = self.mViewPos, parent = self})
        self.mSubParentLayer:addChild(zhenjueLayer)
        self.mThirdSubTag = nil
	elseif index == BagType.eHeroBag then --包含碎片
		self.mCurType = BagType.eHeroBag
		self.hadViewNewHero = true
		local heroLayer = require("bag.BagHeroLayer"):create({tag = self.mThirdSubTag, viewPos = self.mViewPos, parent = self})
		self.mSubParentLayer:addChild(heroLayer)
        self.mThirdSubTag = nil
	elseif index == BagType.eEquipBag then --包含碎片
		self.mCurType = BagType.eEquipBag
		self.hadViewedEquip = true
		local equipLayer = require("bag.EquipBagLayer"):create({subPageType = self.mThirdSubTag, selectId = self.selectId, viewPos = self.mViewPos, parent = self})
		self.mSubParentLayer:addChild(equipLayer)
        self.mThirdSubTag = nil
    elseif index == BagType.eGemBag then -- 宝石
        self.mCurType = BagType.eGemBag
        self.hadViewedImprint = true
        local imprintLayer = require("bag.BagImprintLayer"):create({subPageType = self.mThirdSubTag, selectId = self.selectId, viewPos = self.mViewPos, parent = self})
        self.mSubParentLayer:addChild(imprintLayer)
        self.mThirdSubTag = nil
    end

end

-- 关闭该页面时执行函数
function BagLayer:onExit()
    if self.hadViewProp then  -- 清空新得到道具列表
        GoodsObj:getNewPropsIdObj():clearNewId()
        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagProps)
    end

    if self.hadViewEquipTreasure then -- 清空新得到装备列表和神兵列表
        TreasureObj:getNewIdObj():clearNewId()
        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagTreasure)
    end

    if self.hadViewNewZhenJue then -- 清空新得到内功心法列表
        ZhenjueObj:getNewIdObj():clearNewId()
        GoodsObj:getNewZhenjueDebrisIdObj():clearNewId()
        Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagZhenjueDebris)
    end

    -- if self.hadViewNewPet then -- 清空新得到宠物列表
    --     PetObj:getNewIdObj():clearNewId()
    --     GoodsObj:getNewZhenjueDebrisIdObj():clearNewId()
    --     Notification:postNotification(EventsName.eNewPrefix .. ModuleSub.eBagPets)
    -- end

end

return BagLayer
