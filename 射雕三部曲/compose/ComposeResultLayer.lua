--[[
    文件名: ComposeResultLayer.lua
	描述: 合成结果展示
	创建人: suntao
	修改人：chenqiang
	创建时间: 2016.7.7
--]]

local ComposeResultLayer = class("ComposeResultLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 200))
end)

--[[
-- 参数 params 中的各项为：
	{
		baseGetGameResourceList  	基础掉落数据
		resourceTypeSub				想要展示的类型
		needAction 					是否需要动画，默认为true

		parent   					上一个节点
	}
]]
function ComposeResultLayer:ctor(params)
    self.mParent = params.parent

	-- 屏蔽下层触摸事件
    ui.registerSwallowTouch({node = self})

	self.mBaseGetGameResourceList = params.baseGetGameResourceList
	self.mResourceTypeSub = params.resourceTypeSub or Resourcetype.eEquipment
	self.mNeedAction = params.needAction
	if self.mNeedAction == nil then self.mNeedAction = true end

	-- 合成返回铜币数量
	self.mGoldCount = 0
	-- 合成得到的装备列表
	self.mResList = {}
	-- 背光特效配置
	self.mBgEffectMap = {
        [2] = "effect_ui_zhuangbei_beijingguang_lv",
        [3] = "effect_ui_zhuangbei_beijingguang_lan",
        [4] = "effect_ui_zhuangbei_beijingguang_zi",
        [5] = "effect_ui_zhuangbei_beijingguang_cheng",
        [6] = "effect_ui_zhuangbei_beijingguang_huang",
        [7] = "effect_ui_zhuangbei_beijingguang_hong",
    }

	-- 初始化数据
	self:initData()

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function ComposeResultLayer:initUI()

	-- 获得的装备展示
	if #self.mResList == 1 then -- 只考虑有1件
		local resNode = self:createOneRes(self.mResList[1], 1.5)
		resNode:setPosition(320, 650)
		self.mParentLayer:addChild(resNode)
		self:playAppearEffect(resNode, self.mResList[1], 1.5)
	elseif #self.mResList > 1 then  -- 只考虑有两件
		local resNode = self:createOneRes(self.mResList[1])
		resNode:setPosition(180, 650)
		self.mParentLayer:addChild(resNode)
		self:playAppearEffect(resNode, self.mResList[1], 0.7)

		local resNode = self:createOneRes(self.mResList[2])
		resNode:setPosition(460, 650)
		self.mParentLayer:addChild(resNode)
		self:playAppearEffect(resNode, self.mResList[2], 0.7)
	end

	-- 返还铜币的提示
	if self.mGoldCount > 0 then
		-- 合成材料中包含升级过的装备 提示
		local tempLabel = ui.newLabel({
            text = TR("合成材料中包含升级过的装备"),
            size = 32,
            align = cc.TEXT_ALIGNMENT_CENTER,
        })
        tempLabel:setPosition(320, 300)
        tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
        self.mParentLayer:addChild(tempLabel)

        -- 返还铜币数量的提示
        local tempLabel = ui.newLabel({
            text = TR("返还升级消耗的铜钱:"),
            size = 32,
            align = cc.TEXT_ALIGNMENT_RIGHT,
        })
        tempLabel:setAnchorPoint(cc.p(1, 0.5))
        tempLabel:setPosition(450, 265)
        self.mParentLayer:addChild(tempLabel)

        -- 返还铜币数辆
        local glodNode = ui.createDaibiView({
			resourceTypeSub = ResourcetypeSub.eGold,
	        number = self.mGoldCount,
		})
		glodNode:setAnchorPoint(cc.p(0, 0.5))
		glodNode:setPosition(450, 265)
		self.mParentLayer:addChild(glodNode)
	end

	-- 确定按钮
	local effectTime--确定按钮延迟出现时间
	if self.mResourceTypeSub == Resourcetype.eTreasure then -- 神兵
		effectTime = 0
	else
		if Utility.getColorLvByModelId(self.mResList[1].modelId) >= 5 then
	        effectTime = 2
	    else
	        effectTime = 2
	    end
	end

	-- 创建确定按钮
    self.mOkButton = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确 定"),
        clickAction = function (pSender)
            if self.mParent then
            	if self.mParent.onResume then
            		self.mParent:onResume("compose.ComposeResultLayer")
            	end
            end

            LayerManager.removeLayer(self)
        end
    })
    self.mOkButton:setPosition(320, 192)
    self.mOkButton:setVisible(false)
    self.mParentLayer:addChild(self.mOkButton)
    Utility.performWithDelay(self.mParentLayer, function()
		self.mOkButton:setVisible(true)
	end, effectTime)
end

-- 初始化数据
function ComposeResultLayer:initData()
	for index, baseItem in pairs(self.mBaseGetGameResourceList) do
		-- 解析获得的铜币
		for _, resItem in pairs(baseItem.PlayerAttr or {}) do
			if resItem.ResourceTypeSub == ResourcetypeSub.eGold then
				self.mGoldCount = self.mGoldCount + resItem.Num
			end
		end

		-- 解析获得的装备
		local data = {}
		data[1] = {}
		local resourceTypeSub = self.mResourceTypeSub
		if Utility.isHero(resourceTypeSub) then  -- 人物
			data[1] = {Hero = baseItem.Hero}
		elseif Utility.isEquip(resourceTypeSub) then -- 装备
			data[1] = {Equip = baseItem.Equip}
		elseif Utility.isTreasure(resourceTypeSub) then -- 神兵
			data[1] = {Treasure = baseItem.Treasure}
		elseif Utility.isIllusion(resourceTypeSub) then -- 幻化
			data[1] = {Illusion = baseItem.Illusion}
		end
		table.merge(self.mResList, Utility.analysisBaseDrop(data)[1])
	end
end

-- 创建一个装备信息
function ComposeResultLayer:createOneRes(resInfo, scale)
	scale = scale or 1
	local viewSize = cc.size(400 * scale, 430 * scale)

	local retNode = cc.Node:create()
	retNode:setAnchorPoint(cc.p(0.5, 0.5))
    retNode:setIgnoreAnchorPointForPosition(false)
	retNode:setContentSize(viewSize)

	local tempModel = self:getModel(resInfo.resourceTypeSub, resInfo.modelId)
	if not tempModel then return end
	local tempColorLv = Utility.getQualityColorLv(tempModel.quality)

	-- 恭喜合成提示
	local tempLabel = ui.newLabel({
        text = TR("恭喜你合成%s!", ResourcetypeSubName[tempModel.typeID or ResourcetypeSub.eHero]),
        size = 32,
    })
    tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
    tempLabel:setPosition(viewSize.width / 2, viewSize.height - 30)
    retNode:addChild(tempLabel)

	-- 名字及背景
	local nameNode = ui.createSpriteAndLabel({
		imgName = "c_103.png",
        labelStr = tempModel.name,
        fontColor = Utility.getColorValue(tempColorLv, 1),
        outlineColor = Enums.Color.eOutlineColor,
	})
	nameNode:setPosition(viewSize.width / 2, viewSize.height - 70)
	retNode:addChild(nameNode)

	-- 创建星级
	if not Utility.isHero(resInfo.resourceTypeSub) and not Utility.isIllusion(resInfo.resourceTypeSub) then
		local starNode = ui.newStarLevel(tempColorLv)
		starNode:setPosition(viewSize.width / 2, viewSize.height - 110)
		retNode:addChild(starNode)
	end

	local picHeight = viewSize.height - 130
	local tempPosY = picHeight / 2 - 20

	-- 背光
	if not self.mNeedAction then
		if self.mBgEffectMap[tempColorLv] then
			local starlight = ui.newEffect({
	            parent = retNode,
	            effectName = self.mBgEffectMap[tempColorLv],
	            animation = "guang",
	            position = cc.p(viewSize.width / 2, tempPosY),
	            loop = true,
	            endRelease = true,
	            zorder = -1,
	            scale = scale,
	        })
		end
	else
		local effectName
		if Utility.getColorLvByModelId(resInfo.modelId) >= 5 then
	        effectName = "effect_ui_shengjiangchuchang_jin"
	    else
	        effectName = "effect_ui_shengjiangchuchang_zi"
	    end

		local guangyun = ui.newEffect({
			parent = retNode,
			effectName = effectName,
			animation = "guangyun",
			position = cc.p(viewSize.width / 2, tempPosY),
			loop = true,
			endRelease = true,
			zorder = -1,
			scale = scale,
		})
	end

	-- 图像
	local resSprite
	if Utility.isHero(resInfo.resourceTypeSub) then
		resSprite = Figure.newHero({
			heroModelID = resInfo.modelId,
			IllusionModelId = resInfo.IllusionModelId,
			needRace = true,
			scale = 0.21 * scale,
		})
		resSprite:setPosition(viewSize.width / 2, -35 + (scale-1)* 80)
	elseif Utility.isEquip(resInfo.resourceTypeSub) or Utility.isTreasure(resInfo.resourceTypeSub) then
		resSprite = ui.newSprite(tempModel.pic .. ".png")
		resSprite:setPosition(viewSize.width / 2, tempPosY)

		local height = resSprite:getContentSize().height
		--if height > picHeight then
			resSprite:setScale(picHeight / height)
		--end
	elseif Utility.isIllusion(resInfo.resourceTypeSub) then
		resSprite = Figure.newHero({
			IllusionModelId = resInfo.modelId,
			needRace = true,
			scale = 0.21 * scale,
		})
		resSprite:setPosition(viewSize.width / 2, -35 + (scale-1)* 80)
	end
	retNode:addChild(resSprite, -1)

	-- 渐变
    resSprite:setOpacity(0)
    local fadeAction = cc.FadeIn:create(2)
    resSprite:runAction(fadeAction)
	
	return retNode
end

--- =========================== 特效相关 ==================================
-- 出场特效
function ComposeResultLayer:playAppearEffect(resNode, resInfo, scale)
	if not self.mNeedAction then return end
	--
	resNode:setVisible(false)

	-- 出场的动画效果
    local effectName, animation, music = nil, nil, nil
    if Utility.getColorLvByModelId(resInfo.modelId) >= 5 then
        effectName = "effect_ui_shengjiangchuchang_jin"
        music = "renwuhecheng_01.mp3"
    else
        effectName = "effect_ui_shengjiangchuchang_zi"
        music = "renwuhecheng_01.mp3"
    end

    local x, y = resNode:getPosition()
    local effect = ui.newEffect({
        parent = self.mParentLayer,
        effectName = effectName,
        position = cc.p(x, y - 200),
        loop = false,
        endRelease = true,
        animation = "luo",
        scale = scale or 0.5,
        completeListener = function()
        	resNode:setVisible(true)
        	MqAudio.playEffect("renwuhecheng_02.mp3")
        end
    })

    -- 播放音效
    MqAudio.playEffect(music)

    return effect
end

--- =========================== 数据相关 ==================================
-- 获取模型
function ComposeResultLayer:getModel(resourceTypeSub, modelId)
	if Utility.isHero(resourceTypeSub) then  -- 人物
        local tempModel = HeroModel.items[modelId]
        return tempModel
    elseif Utility.isEquip(resourceTypeSub) then -- 装备
        local tempModel = EquipModel.items[modelId]
        return tempModel
    elseif Utility.isTreasure(resourceTypeSub) then -- 神兵
        local tempModel = TreasureModel.items[modelId]
        return tempModel
    elseif Utility.isIllusion(resourceTypeSub) then -- 幻化
        local tempModel = IllusionModel.items[modelId]
        return tempModel
    end
end

return ComposeResultLayer

