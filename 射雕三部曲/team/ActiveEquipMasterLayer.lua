--[[
	文件名：ActiveEquipMasterLayer.lua
	描述：培养共鸣激活的页面
	创建人: peiyaoqiang
	创建时间: 2017.07.25
--]]

local ActiveEquipMasterLayer = class("ActiveEquipMasterLayer", function()
	return display.newLayer()
end)

-- 构造函数
function ActiveEquipMasterLayer:ctor(params)
	self.mEndCallback = params.callback
	self.mEquipType = params.equipType
	self.mEquipName = ResourcetypeSubName[self.mEquipType]

	-- 播放音效
	MqAudio.playEffect("hetijihuo.mp3")
	
	-- 删除当前页面
	local function closeMyself()
		if (self.mEndCallback ~= nil) then
			self.mEndCallback()
		end
		LayerManager.removeLayer(self)
	end

	-- 标准容器
	self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 添加背景图
    local activeStepLv = params.activeStepLv or 0
	local activeStarLv = params.activeStarLv or 0
	local activeSpriteList = {}
	local spriteSize = ui.getImageSize("c_93.png")
	if (activeStepLv > 0) then
		local tmpSprite = ui.newSprite("c_93.png")
		self:showStepUI(tmpSprite, spriteSize, activeStepLv)
		table.insert(activeSpriteList, tmpSprite)
	end
	if (activeStarLv > 0) then
		local tmpSprite = ui.newSprite("c_93.png")
		self:showStarUI(tmpSprite, spriteSize, activeStarLv)
		table.insert(activeSpriteList, tmpSprite)
	end
	local yPosList = (#activeSpriteList > 1) and {568 + spriteSize.height * 0.5 + 5, 568 - spriteSize.height * 0.5 - 5} or {568}
	for i,v in ipairs(activeSpriteList) do
		v:setPosition(320, yPosList[i])
		v:setScale(0)
		self.mParentLayer:addChild(v)

		-- 弹出动画
		v:runAction(cc.Sequence:create({
	    	cc.ScaleTo:create(0.2, 1),
	    	cc.DelayTime:create(1.5),
	    	cc.FadeOut:create(0.3),
	    	cc.CallFunc:create(function ()
	    			closeMyself()
	    		end)
	    	}))
	end

    -- 注册触摸关闭事件
	ui.registerSwallowTouch({
        node = self,
        allowTouch = true,
        beganEvent = function(touch, event)
            return true
        end,
        endedEvent = function(touch, event)
            closeMyself()
        end,
    })
end

-- 显示锻造共鸣的界面
function ActiveEquipMasterLayer:showStepUI(bgSprite, bgSize, stepLv)
	-- 显示标题
	local titleSprite = ui.newSprite("zb_23.png")
	titleSprite:setPosition(bgSize.width * 0.5, bgSize.height - 50)
	bgSprite:addChild(titleSprite)

	-- 显示激活信息
	local infoLabel = ui.newLabel({
		text = TR("激活%s%s%s的锻造共鸣%s%s级", "#88DCFF", self.mEquipName, Enums.Color.eNormalWhiteH, "#88DCFF", stepLv),
		size = 24,
		color = Enums.Color.eNormalWhite,
		outlineColor = Enums.Color.eOutlineColor,
	})
	infoLabel:setAnchorPoint(cc.p(0.5, 0.5))
	infoLabel:setPosition(bgSize.width * 0.5, 105)
	bgSprite:addChild(infoLabel)

	-- 显示属性背景
	local attrBgSprite = ui.newSprite("zdjs_06.png")
	local attrBgSize = attrBgSprite:getContentSize()
	attrBgSprite:setPosition(320, 50)
	bgSprite:addChild(attrBgSprite)

	-- 显示属性信息
	local currConfig = EquipStepTeamRelation.items[stepLv]
	local attrPosXList = {attrBgSize.width * 0.2, attrBgSize.width * 0.5, attrBgSize.width * 0.8}
    for i,v in ipairs(Utility.analyzeAttrAddString(currConfig.totalAttrStr)) do
        local tempLabel = ui.newLabel({
            text = string.format("%s+%s", v.name, v.value) ,
            color = cc.c3b(0xa9, 0xff, 0x7f),
            size = 22,
        })
        tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
        tempLabel:setPosition(attrPosXList[i], attrBgSize.height * 0.5)
        attrBgSprite:addChild(tempLabel)
    end
end

-- 显示升星共鸣的界面
function ActiveEquipMasterLayer:showStarUI(bgSprite, bgSize, starLv)
	-- 显示标题
	local titleSprite = ui.newSprite("zb_24.png")
	titleSprite:setPosition(bgSize.width * 0.5, bgSize.height - 50)
	bgSprite:addChild(titleSprite)

	-- 显示激活信息
	local infoLabel = ui.newLabel({
		text = TR("激活%s%s%s的升星共鸣%s%s级", "#FFB74F", self.mEquipName, Enums.Color.eNormalWhiteH, "#FFB74F", starLv),
		size = 24,
		color = Enums.Color.eNormalWhite,
		outlineColor = Enums.Color.eOutlineColor,
	})
	infoLabel:setAnchorPoint(cc.p(0.5, 0.5))
	infoLabel:setPosition(bgSize.width * 0.5, 105)
	bgSprite:addChild(infoLabel)

	-- 显示属性背景
	local attrBgSprite = ui.newSprite("zdjs_06.png")
	local attrBgSize = attrBgSprite:getContentSize()
	attrBgSprite:setPosition(320, 50)
	bgSprite:addChild(attrBgSprite)

	-- 显示属性信息
	local currConfig = nil
	for _,v in pairs(EquipStarTeamRelation.items) do
		if (v.Lv == starLv) then
			currConfig = v
			break
		end
	end
	local attrPosXList = {attrBgSize.width * 0.2, attrBgSize.width * 0.5, attrBgSize.width * 0.8}
    for i,v in ipairs(Utility.analyzeAttrAddString(currConfig.totalAttrStr)) do
        local tempLabel = ui.newLabel({
            text = string.format("%s+%s", v.name, v.value) ,
            color = cc.c3b(0xa9, 0xff, 0x7f),
            size = 22,
        })
        tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
        tempLabel:setPosition(attrPosXList[i], attrBgSize.height * 0.5)
        attrBgSprite:addChild(tempLabel)
    end
end

return ActiveEquipMasterLayer
