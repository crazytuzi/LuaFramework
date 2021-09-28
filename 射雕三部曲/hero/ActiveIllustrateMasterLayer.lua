--[[
	文件名：ActiveIllustrateMasterLayer.lua
	描述：群侠谱升星大师激活的页面
	创建人: peiyaoqiang
	创建时间: 2017.11.15
--]]

local ActiveIllustrateMasterLayer = class("ActiveIllustrateMasterLayer", function()
	return display.newLayer()
end)

-- 构造函数
function ActiveIllustrateMasterLayer:ctor(params)
	self.mEndCallback = params.callback
	
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

    -- 显示背景
    local tmpSprite = ui.newSprite("c_93.png")
    tmpSprite:setPosition(320, 568)
	tmpSprite:setScale(0)
	self.mParentLayer:addChild(tmpSprite)
	self:showMasterUI(tmpSprite, tmpSprite:getContentSize(), params.curTab, params.masterLv)

	-- 弹出动画
	tmpSprite:runAction(cc.Sequence:create({
    	cc.ScaleTo:create(0.2, 1),
    	cc.DelayTime:create(1.5),
    	cc.FadeOut:create(0.3),
    	cc.CallFunc:create(function ()
    			closeMyself()
    		end)
    	}))

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
function ActiveIllustrateMasterLayer:showMasterUI(bgSprite, bgSize, curTab, masterLv)
	-- 显示标题
	local titleSprite = ui.newSprite("qxp_14.png")
	titleSprite:setPosition(bgSize.width * 0.5, bgSize.height - 50)
	bgSprite:addChild(titleSprite)

	-- 显示激活信息
	local tabNameList = {TR("宗师"), TR("神话"), TR("传说")}
	local textStr = TR("所有%s%s%s侠谱达到%s%s星", Enums.Color.eYellowH, tabNameList[curTab], Enums.Color.eNormalWhiteH, Enums.Color.eYellowH, (masterLv - 1))
	if masterLv > 6 then
		textStr = TR("所有%s%s%s侠谱达到%s%s月", Enums.Color.eYellowH, tabNameList[curTab], Enums.Color.eNormalWhiteH, Enums.Color.eYellowH, (masterLv - 6))
	end
	local infoLabel = ui.newLabel({
		text = textStr,
		size = 24,
		color = Enums.Color.eNormalWhite,
		outlineColor = cc.c3b(0x30, 0x30, 0x30),
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
	local currConfig = IllustratedMasterRelation.items[curTab][masterLv]
	local attrPosXList = {attrBgSize.width * 0.2, attrBgSize.width * 0.5, attrBgSize.width * 0.8}
	for i,v1 in ipairs(string.split(currConfig.currentAttr, ",")) do
		local tmpAttr = string.split(v1, "||")
        local attrList = string.split(tmpAttr[2], "|")
        local attrRange = tonumber(tmpAttr[1])
        local attrKey = tonumber(attrList[1])
        local attrValue = tonumber(attrList[2])
        local tempLabel = ui.newLabel({
            text = string.format("%s%s%s+%s", Utility.getRangeStr(attrRange), FightattrName[attrKey], "#A8FF5B", attrValue),
            --color = cc.c3b(0xa9, 0xff, 0x7f),
            size = 22,
        })
        tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
        tempLabel:setPosition(attrPosXList[i], attrBgSize.height * 0.5)
        attrBgSprite:addChild(tempLabel)
    end
end

return ActiveIllustrateMasterLayer
