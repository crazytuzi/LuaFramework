--[[
    文件名: JianghuKillLetter.lua
    描述: 江湖杀密信页面
    创建人: yanghongsheng
    创建时间: 2018.09.20
-- ]]
local JianghuKillLetter = class("JianghuKillLetter", function(params)
	return display.newLayer(params and params.color4B or cc.c4b(0, 0, 0, 128))
end)

--[[
	params:
]]
function JianghuKillLetter:ctor(params)
	self.mIsOpen = false  	-- 状态，是否点击打开了
	--屏蔽下层触控
	ui.registerSwallowTouch({node = self})

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self:initUI()

	self:executeGuide()
end

function JianghuKillLetter:initUI()
	self:createNotOpenLetter()
end

-- 创建未打开的信
function JianghuKillLetter:createNotOpenLetter()
	self.mParentLayer:removeAllChildren()
	-- 收到密信
	local blackSize = cc.size(450, 45)
	local blackBg = ui.newScale9Sprite("c_25.png", blackSize)
	blackBg:setAnchorPoint(cc.p(0.5, 0.5))
	blackBg:setPosition(320, 908)
	self.mParentLayer:addChild(blackBg)

	local hintLabel = ui.newLabel({
    		text = TR("您收到一封密信"),
    		color = Enums.Color.eWhite,
    		outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    	})
	hintLabel:setPosition(blackSize.width*0.5, blackSize.height*0.5)
	blackBg:addChild(hintLabel)

	-- 卷轴
	local tempSprite = ui.newSprite("jhs_18.png")
	tempSprite:setPosition(320, 620)
	self.mParentLayer:addChild(tempSprite)

	-- 点击拆开
	local clickOpenBtn = ui.newButton({
			normalImage = "jhs_19.png",
			clickAction = function ()
				self:createOpenLetter()
				self:executeGuide()
			end
		})
	clickOpenBtn:setPosition(320, 610)
	self.mParentLayer:addChild(clickOpenBtn)
	self.mClickOpenBtn = clickOpenBtn
end

-- 创建打开了的信
function JianghuKillLetter:createOpenLetter()
	self.mParentLayer:removeAllChildren()

	-- 卷轴
	local tempSprite = ui.newSprite("jhs_16.png")
	tempSprite:setPosition(320, 620)
	self.mParentLayer:addChild(tempSprite)

	-- 点击继续
	local clickContinueBtn = ui.newButton({
			normalImage = "jhs_17.png",
			clickAction = function ()
				LayerManager.addLayer({name = "jianghuKill.JianghuKillSelectForceLayer", data = {isRecomReward = true}})
			end
		})
	clickContinueBtn:setPosition(320, 370)
	self.mParentLayer:addChild(clickContinueBtn)
	self.mClickContinueBtn = clickContinueBtn
end

-- ========================== 新手引导 ===========================

-- 执行新手引导
function JianghuKillLetter:executeGuide()
    Guide.helper:executeGuide({
        -- 箭头指向卷轴
        [902] = {clickNode = self.mClickOpenBtn},
        -- 点击继续
        [903] = {clickNode = self.mClickContinueBtn},
    })
end

return JianghuKillLetter