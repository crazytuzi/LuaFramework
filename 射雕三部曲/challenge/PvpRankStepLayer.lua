--[[
    文件名：PvpRankStepLayer.lua
    描述：竞技场阶段展示页面
    创建人：lengjiazhi
    创建时间：2017.5.18
-- ]]
local PvpRankStepLayer = class("PvpRankStepLayer", function(params)
	return display.newLayer()
end)
local btnInfoList = {
	[1] = {
			point = cc.p(462, 360),
			image = "hslj_17.png",
		},
	[2] = {
			point = cc.p(143, 472),
			image = "hslj_18.png",
		},
	[3] = {
			point = cc.p(293, 658),
			image = "hslj_19.png",
		},
	[4] = {
			point = cc.p(48, 760),
			image = "hslj_16.png",
	},
	[5] = {
			point = cc.p(558, 857),
			image = "hslj_15.png",
		},
	[6] = {
			point = cc.p(200, 953),
			image = "hslj_14.png",
		},
}

function PvpRankStepLayer:ctor(params)
	self.mNowStep = params.step or 5
	self.mNeedFlash = params.isFirst

	ui.registerSwallowTouch({node = self})
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

 	self.mBgSprite = ui.newSprite("hslj_06.jpg")
	self.mBgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(self.mBgSprite)

	local backBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
		})
	backBtn:setPosition(578, 998)
	self.mBgSprite:addChild(backBtn)
	backBtn:setVisible(not self.mNeedFlash)


    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {
            ResourcetypeSub.eSTA,
            ResourcetypeSub.eDiamond,
            ResourcetypeSub.ePVPCoin,
        }
    })
    self:addChild(topResource, Enums.ZOrderType.eDefault + 4)

	self:initUI()
end
function PvpRankStepLayer:initUI()
	self.mButtonList = {}
	for i = 1, 6 do
		local stepBtn = ui.newButton({
			normalImage = btnInfoList[i].image,
			position = btnInfoList[i].point,
			clickAudio = "huashanlunjian.mp3",
			clickAction = function()

			end
			})
		self.mBgSprite:addChild(stepBtn)
		-- stepBtn:setEnabled(false)
		table.insert(self.mButtonList, stepBtn)
	end
	local nowStepTip = ui.newSprite("hslj_08.png")
	nowStepTip:setPosition(btnInfoList[self.mNowStep].point.x + 3, btnInfoList[self.mNowStep].point.y + 85)
	self.mBgSprite:addChild(nowStepTip)

	ui.newEffect({
		parent = self.mBgSprite,
        effectName = "effect_ui_huashanlunjian",
        position = cc.p(btnInfoList[self.mNowStep].point.x + 10, btnInfoList[self.mNowStep].point.y + 20),
        loop = true,
        animation = nil,
        endRelease = true,
		})

	for i,v in ipairs(self.mButtonList) do
		-- if i ~= self.mNowStep then
			v:setClickAction(function()
				LayerManager.addLayer({
	            	name = "challenge.PvpOtherStepLayer",
	            	data = {step = i},
	            	})
			end)
		-- else
		-- 	v:setClickAction(function()
		-- 		LayerManager.removeLayer(self)
		-- 	end)
		-- end
	end

	if self.mNeedFlash then
		self:schedule()
	end

end

function PvpRankStepLayer:schedule()
	local unTouchLayer = cc.Layer:create()
	self:addChild(unTouchLayer)
	ui.registerSwallowTouch({node = unTouchLayer})


	local time = 0
	self:scheduleUpdate(function (dt)
		time = time + dt
		if time >= 0.6 then
			self.mBgSprite:runAction(self:action())
			self:unscheduleUpdate()
		end
	end)
end
function PvpRankStepLayer:action()
	local callFun = cc.CallFunc:create(function ()
		local tempPos = btnInfoList[self.mNowStep].point
		self.mBgSprite:setAnchorPoint(tempPos.x / 640, tempPos.y / 1136)
		self.mBgSprite:setPosition(tempPos)
	end)
	local scale = cc.ScaleTo:create(1, 1.5)
	-- local fade = cc.FadeTo:create(2, 100)
	-- local callFunBtn = cc.CallFunc:create(function()
	-- 	for k,v in pairs(self.mButtonList) do
	-- 		local fadeBtn = cc.FadeTo:create(2, 100)
	-- 		v:runAction(fadeBtn)
	-- 	end
	-- end)
	local sp = cc.Spawn:create(scale)
	local callFun2 = cc.CallFunc:create(function()
		LayerManager.removeLayer(self)
	end)
	local sq = cc.Sequence:create(callFun, sp, callFun2)
	return sq
end

return PvpRankStepLayer