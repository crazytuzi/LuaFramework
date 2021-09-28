--[[
    文件名：ZhenshouInfoLayer.lua
    描述：首页背景Layer的显示
    创建人：heguanghui
    创建时间：2017.3.6
-- ]]

local ZhenshouInfoLayer = class("ZhenshouInfoLayer", function(params)
	return display.newLayer()
end)

--[[
	params:
		zhenshouId: 珍兽实例Id
        modelId: 珍兽模型Id, 如果 zhenshouId 为有效值，该参数失效
]]

function ZhenshouInfoLayer:ctor(params)
	-- 珍兽模型id
	self.mZhenshouModelId = params.modelId
	local zhenshouInfo = Utility.isEntityId(params.zhenshouId) and ZhenshouObj:getZhenshou(params.zhenshouId)
	if zhenshouInfo and next(zhenshouInfo) then
		self.mZhenshouInfo = zhenshouInfo
		self.mZhenshouModelId = self.mZhenshouInfo.ModelId
	end

	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.eVIT,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.eGold
        }
    })
    self:addChild(topResource)
	-- 初始化页面控件
	self:initUI()
end

function ZhenshouInfoLayer:initUI()
	-- 背景图片
	local bgLayer = ui.newSprite("zr_18.jpg")
	bgLayer:setAnchorPoint(cc.p(0.5, 1))
	bgLayer:setPosition(320, 1136)
	self.mParentLayer:addChild(bgLayer)

	-- 创建珍兽特效
	self:createZhenshouEffect()
	
	-- 详细信息的背景
	local tempSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 578))
	tempSprite:setPosition(320, 0)
	tempSprite:setAnchorPoint(cc.p(0.5, 0))
	self.mParentLayer:addChild(tempSprite)
	-- 创建详情
	self.createZhenshouDetail({
		parent = tempSprite,
		size = cc.size(620, 460),
		zhenshouId = self.mZhenshouInfo and self.mZhenshouInfo.Id,
		modelId = self.mZhenshouModelId,
	})

	-- 获取途径按钮
	local getWayBtn = ui.newButton({
		normalImage = "tb_34.png",
		clickAction = function()
			LayerManager.addLayer({
	            name = "hero.DropWayLayer",
	            data = {
	                resourceTypeSub = Utility.getTypeByModelId(self.mZhenshouModelId),
	                modelId = self.mZhenshouModelId,
	            },
	            cleanUp = false,
	        })
		end
	})
	getWayBtn:setPosition(550, 610)
	self.mParentLayer:addChild(getWayBtn, 1)
	-- 关闭按钮
	local closeBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	closeBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
	self.mParentLayer:addChild(closeBtn)
end

-- 创建人物详细信息部分
function ZhenshouInfoLayer:createZhenshouEffect()
	local pic = Figure.newZhenshou({
		viewSize = cc.size(640, 420),
		modelId = self.mZhenshouModelId,
	})
	pic:setAnchorPoint(cc.p(0.5, 0))
	pic:setPosition(320, 600)
	self.mParentLayer:addChild(pic)

	local zhenshouModel = ZhenshouModel.items[self.mZhenshouModelId]
	-- 创建名字
    local nameLabel = ui.createSpriteAndLabel({
        imgName = "c_25.png",
        labelStr = zhenshouModel.name,
        fontSize = 24,
        fontColor = Utility.getQualityColor(zhenshouModel.quality, 1),
        outlineColor = cc.c3b(0x37, 0x30, 0x2c),
        outlineSize = 2,
    })
    nameLabel:setAnchorPoint(cc.p(0.5, 1))
    nameLabel:setPosition(320, 1080)
    self.mParentLayer:addChild(nameLabel)

end

-- 创建人物详细信息部分
--[[
	params:
		parent 		父节点
		size 		显示列表大小
		zhenshouId 	珍兽实例id
		modelId 	珍兽模型Id, 如果 zhenshouId 为有效值，该参数失效
]]
function ZhenshouInfoLayer.createZhenshouDetail(params)
	local parentSize = params.parent:getContentSize()
	local blackSize = params.size or cc.size(620, 520)

	if params.parent.tmpGraySprite and not tolua.isnull(params.parent.tmpGraySprite) then
		params.parent.tmpGraySprite:removeFromParent()
		params.parent.tmpGraySprite = nil
	end
	local tmpGraySprite = ui.newScale9Sprite("c_17.png", blackSize)
    tmpGraySprite:setAnchorPoint(0.5, 1)
    tmpGraySprite:setPosition(parentSize.width*0.5, parentSize.height-35)
    params.parent:addChild(tmpGraySprite)
    params.parent.tmpGraySprite = tmpGraySprite

	-- 详细信息滑动部分
    local detailView = ccui.ScrollView:create()
    detailView:setContentSize(cc.size(blackSize.width, blackSize.height-10))
    detailView:setDirection(ccui.ScrollViewDir.vertical)
    detailView:setAnchorPoint(cc.p(0.5, 0.5))
    detailView:setPosition(blackSize.width*0.5, blackSize.height*0.5)
    tmpGraySprite:addChild(detailView)

    -- 珍兽模型id
	local zhenshouModelId = params.modelId
	local zhenshouInfo = Utility.isEntityId(params.zhenshouId) and ZhenshouObj:getZhenshou(params.zhenshouId)
	if zhenshouInfo and next(zhenshouInfo) then
		zhenshouModelId = zhenshouInfo.ModelId
	end
	local zhenshouModel = ZhenshouModel.items[zhenshouModelId]

    -- 详细信息真正的parent
    local detailParent = ccui.Layout:create()
    detailView:addChild(detailParent)

    local parentPosY = 0
    local itemWidth = blackSize.width-20
    local function addBgSprite(tempBgSize, posY, titleText)
		return ui.newNodeBgWithTitle(detailParent, tempBgSize, titleText, cc.p(blackSize.width*0.5, posY), cc.p(0.5, 1))
    end
    ----------------------------------基础属性---------------------------------------
    local attrCol = 3
    local attrList = ZhenshouObj:getZhenshouAttrList(params.zhenshouId, zhenshouModelId)
    local listLength = (#attrList+2)
    local labelHight = 30
    local attrBgSize = cc.size(itemWidth, math.floor((listLength-1)/attrCol)*labelHight+70)
    local attrBg = addBgSprite(attrBgSize, parentPosY, TR("基础属性"))
    for i = 1, listLength do
    	local text = ""
    	if i == 1 then		-- 资质
    		text = TR("资质：%s%s", Enums.Color.eNormalGreenH, zhenshouModel.quality)
		elseif i == 2 then	-- 等级
    		text = TR("等级：%s%s", Enums.Color.eNormalGreenH, zhenshouInfo and zhenshouInfo.Lv or 0)
		else
			local attrInfo = attrList[i-2]
			text = TR("全体%s：%s%s", FightattrName[attrInfo.fightattr], Enums.Color.eNormalGreenH, Utility.getAttrViewStr(attrInfo.fightattr, attrInfo.value, false))
		end
		local attrLabel = ui.newLabel({
				text = text,
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 20,
			})
		attrLabel:setAnchorPoint(cc.p(0, 0))
		local x, y = math.floor((i-1)%attrCol), math.floor((i-1)/attrCol)
		attrLabel:setPosition(x*(itemWidth/attrCol-10)+15, attrBgSize.height-y*labelHight-70)
		attrBg:addChild(attrLabel)
	end
	-- 更新位置
	parentPosY = parentPosY - attrBgSize.height - 5
	----------------------------------技能属性---------------------------------------
	local ordinaryIntro, specialIntro = ZhenshouObj:getZhenshouSkillIntro(params.zhenshouId, zhenshouModelId)
	local skillBgHight = 70
	-- 普攻
	local ordinaryLabel = nil
	if ordinaryIntro ~= "" then
		ordinaryLabel = ui.newLabel({
				text = ordinaryIntro,
				color = Enums.Color.ePrColor,
				dimensions = cc.size(itemWidth - 100, 0),
			})
		skillBgHight = skillBgHight + ordinaryLabel:getContentSize().height + 10
	end
	-- 技攻
	local specialLabel = nil
	if specialIntro ~= "" then
		specialLabel = ui.newLabel({
				text = specialIntro,
				color = Enums.Color.ePrColor,
				dimensions = cc.size(itemWidth - 100, 0),
			})
		skillBgHight = skillBgHight + specialLabel:getContentSize().height
	end
	local skillBgSize = cc.size(itemWidth, skillBgHight)
	local skillBg = addBgSprite(skillBgSize, parentPosY, TR("技能属性"))
	local skillLabelHight = 50
	if ordinaryLabel then
		ordinaryLabel:setAnchorPoint(cc.p(0, 1))
		ordinaryLabel:setPosition(65, skillBgSize.height-skillLabelHight)
		skillBg:addChild(ordinaryLabel)

		-- 普攻图
		local ordinarySprite = ui.newSprite("c_71.png")
		ordinarySprite:setAnchorPoint(cc.p(0, 1))
		ordinarySprite:setPosition(15, skillBgSize.height-skillLabelHight)
		skillBg:addChild(ordinarySprite)

		skillLabelHight = skillLabelHight + ordinaryLabel:getContentSize().height + 10
	end
	if specialLabel then
		specialLabel:setAnchorPoint(cc.p(0, 1))
		specialLabel:setPosition(65, skillBgSize.height-skillLabelHight)
		skillBg:addChild(specialLabel)

		-- 技攻图
		local specialSprite = ui.newSprite("c_70.png")
		specialSprite:setAnchorPoint(cc.p(0, 1))
		specialSprite:setPosition(15, skillBgSize.height-skillLabelHight)
		skillBg:addChild(specialSprite)
	end
	-- 更新位置
	parentPosY = parentPosY - skillBgSize.height - 5
	----------------------------------升星天赋---------------------------------------
	local stepModelList = ZhenshouStepupModel.items[zhenshouModelId]
	local stepBgHight = 70
	local nameLabelList, stepLabelList = {}, {}
	for _, stepModel in ipairs(stepModelList) do
		if stepModel.addAttrStr ~= "" then
			local stepAttrList = Utility.analysisStrAttrList(stepModel.addAttrStr)
			local attrStrList = {}
			for _, attrInfo in pairs(stepAttrList) do
				local attrStr = TR("全体%s%s", FightattrName[attrInfo.fightattr], Utility.getAttrViewStr(attrInfo.fightattr, attrInfo.value, true))
				table.insert(attrStrList, attrStr)
			end
			local currColor = (zhenshouInfo and zhenshouInfo.Step or 0) >= stepModel.stepLv and Enums.Color.ePrColor or Enums.Color.eNotPrColor
			local stepLabel = ui.newLabel({
					text = table.concat(attrStrList, "，"),
					color = currColor,
					align = cc.TEXT_ALIGNMENT_LEFT,
		        	valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
		        	dimensions = cc.size(400, 0)
				})
			table.insert(stepLabelList, stepLabel)

			local tempLabel = ui.newLabel({
				text = TR("升星+%s", stepModel.stepLv),
				color = currColor,
				align = cc.TEXT_ALIGNMENT_LEFT,
	        	valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
			})
			tempLabel:setAnchorPoint(cc.p(0, 1))
			table.insert(nameLabelList, tempLabel)

			stepBgHight = stepBgHight + stepLabel:getContentSize().height + 10
		end
	end
	local stepBgSize = cc.size(itemWidth, stepBgHight)
	local stepBg = addBgSprite(stepBgSize, parentPosY, TR("升星天赋"))
	local label_Y = stepBgSize.height - 55
	for i = 1, #nameLabelList do
		local nameLabel = nameLabelList[i]
		local stepLabel = stepLabelList[i]

		stepBg:addChild(nameLabel)
		stepBg:addChild(stepLabel)

		nameLabel:setAnchorPoint(cc.p(0, 1))
		stepLabel:setAnchorPoint(cc.p(0, 1))

		nameLabel:setPosition(20, label_Y)
		stepLabel:setPosition(200, label_Y)

		label_Y = label_Y - stepLabel:getContentSize().height - 10
	end
	-- 更新位置
	parentPosY = parentPosY - stepBgSize.height - 5
	----------------------------------珍兽简介---------------------------------------
	local introLabel = ui.newLabel({
		text = zhenshouModel.intro,
		color = cc.c3b(0x46, 0x22, 0x0d),
		align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(itemWidth-20, 0)
	})

	local introBgSize = cc.size(itemWidth, introLabel:getContentSize().height + 70)
	local introBgSprite = addBgSprite(introBgSize, parentPosY, TR("珍兽简介"))

	introLabel:setAnchorPoint(cc.p(0.5, 1))
	introLabel:setPosition(introBgSize.width / 2, introBgSize.height - 55)
	introBgSprite:addChild(introLabel)
	parentPosY = parentPosY - introBgSize.height - 10

	-- 添加到滚动控件
	local tempSize = detailView:getContentSize()
	local tempHeight = math.max(tempSize.height, math.abs(parentPosY))
	detailParent:setPosition(0, tempHeight)
	detailView:setInnerContainerSize(cc.size(tempSize.width, tempHeight))
    detailView:jumpToTop()

    return tmpGraySprite
end

return ZhenshouInfoLayer