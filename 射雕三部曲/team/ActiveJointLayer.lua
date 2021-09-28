--[[
	文件名：ActiveJointLayer.lua
	描述：合体技激活的页面
	创建人: peiyaoqiang
	创建时间: 2017.07.08
--]]

local ActiveJointLayer = class("ActiveJointLayer", function()
	return display.newLayer()
end)

-- 构造函数
function ActiveJointLayer:ctor(params)
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

    -- 添加背景图
    local bgSprite = ui.newSprite("zr_21.png")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

	-- 显示合体内容并弹出动画
	self:initUI(bgSprite, bgSprite:getContentSize(), (params.jointId or 0))
	bgSprite:setScale(0)
    bgSprite:runAction(cc.Sequence:create({
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

function ActiveJointLayer:initUI(bgSprite, bgSize, jointId)
	local jointModel = HeroJointModel.items[jointId]
	if (jointModel == nil) then
		return
	end
	local attackModel = AttackModel.items[jointModel.jointSkillID]
	if (attackModel == nil) then
		return
	end
	
	-- 显示人物头像
	local function addHeader(heroModelId, posX)
		local tempCard = require("common.CardNode").new({
        	allowClick = false,
			onClickCallback = function()
			end
		})
		tempCard:setPosition(posX, 172)
		if (heroModelId == 0) then
			-- 副将为0表示主角
			local tempSlot = FormationObj:getSlotInfoBySlotId(1)
			local tempHero = clone(HeroObj:getHero(tempSlot.HeroId))
			tempHero.FashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId")
			tempCard:setHero(tempHero, {CardShowAttr.eBorder, CardShowAttr.eName})
		else
			tempCard:setHero({ModelId = heroModelId, IllusionModelId = heroModelId}, {CardShowAttr.eBorder, CardShowAttr.eName})
		end
		bgSprite:addChild(tempCard)
	end
	addHeader(jointModel.mainHeroID, bgSize.width / 2 + 100)
	addHeader(jointModel.aidHeroID, bgSize.width / 2 - 100)

	-- 显示技能名字图标
	local skillSprite = ui.newSprite("c_146.png")
	skillSprite:setAnchorPoint(cc.p(1, 1))
	skillSprite:setPosition(50, 77)
	bgSprite:addChild(skillSprite)

	-- 显示技能名字和描述
	local strIntro = string.format("【%s】", attackModel.name)
	for _,v in ipairs(string.splitBySep(attackModel.intro, "#73430D")) do
		strIntro = strIntro .. Enums.Color.eNormalWhiteH .. v
	end

	-- 替换属性的特殊颜色
	local strText = ""
	for _,v in ipairs(string.splitBySep(strIntro, "#249029")) do
		strText = strText .. v .. "#A8FF5B"
	end
	local introLabel = ui.newLabel({
		text = strText,
		size = 22,
		color = cc.c3b(0xff, 0xad, 0x65),
		align = cc.TEXT_ALIGNMENT_LEFT,
        valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = cc.size(bgSize.width - 80, 0)
	})
	introLabel:setAnchorPoint(cc.p(0.5, 1))
	introLabel:setPosition(bgSize.width * 0.5 + 20, 75)
	bgSprite:addChild(introLabel)
end

return ActiveJointLayer
