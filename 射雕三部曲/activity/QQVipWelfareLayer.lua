--[[
	文件名:QQVipWelfareLayer.lua
	描述：QQ会员特权界面
	创建人：yanghongsheng
    创建时间：2018.04.13
--]]

local QQVipWelfareLayer = class("QQVipWelfareLayer", function(params)
    return display.newLayer()
end)

local RewardType = {
	eQQVipReward = 1,
	eQQSVipReward = 2,
}

function QQVipWelfareLayer:ctor()
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(616, 760),
        title = TR("超级VIP特权"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 领取按钮列表
    self.mGetBtnList = {}
	-- 创建页面控件
	self:initUI()

	-- 请求服务器
	self:requestInfo()
end

function QQVipWelfareLayer:initUI()
	-- 创建特权说明
	self:welfareDesList()
	-- 创建礼包领取
	self:welfareRewardList()
	-- 开通超级会员
	local openBtn = ui.newButton({
			normalImage = "c_28.png",
			size = cc.size(200, 51),
			text = TR("开通超级VIP"),
			clickAction = function ()

				IPlatform:getInstance():invoke("PayQQSvip","", function()
					-- 刷新界面
					self:requestInfo()
				end)
			end,
		})
	openBtn:setPosition(self.mBgSize.width*0.5, 60)
	self.mBgSprite:addChild(openBtn)
end

function QQVipWelfareLayer:welfareDesList()
	-- 黑背景
	local blackSize = cc.size(555, 230)
	local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
	blackBg:setAnchorPoint(cc.p(0.5, 1))
	blackBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-80)
	self.mBgSprite:addChild(blackBg)
	-- 框
	local listBgSize = cc.size(536, 210)
	local listBg = ui.newScale9Sprite("c_54.png", listBgSize)
	listBg:setPosition(blackSize.width*0.5, blackSize.height*0.5)
	blackBg:addChild(listBg)
	-- tilte
	local titleLabel = ui.newLabel({
			text = TR("{qq_02.png}超级VIP特权"),
			size = 27,
			outlineColor = Enums.Color.eOutlineColor,
		})
	titleLabel:setPosition(listBgSize.width*0.5, listBgSize.height-20)
	listBg:addChild(titleLabel)
	-- 说明
	local posY = listBgSize.height - 55
	local space = -30
	local function createDes (num, text)
		local posX = 20
		-- 特权图片
		local tequanSprite = ui.newSprite("qq_03.png")
		tequanSprite:setAnchorPoint(cc.p(0, 1))
		tequanSprite:setPosition(posX, posY)
		listBg:addChild(tequanSprite)
		-- 特权数字
		local tequanNum = ui.newNumberLabel({
				text = tostring(num),
				imgFile = "c_49.png",
			})
		tequanNum:setAnchorPoint(cc.p(0, 0))
		tequanNum:setPosition(tequanSprite:getContentSize().width+10, 0)
		tequanSprite:addChild(tequanNum)
		-- 特权描述
		local desLabel = ui.newLabel({
				text = text,
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 24,
				dimensions = cc.size(440, 0),
			})
		desLabel:setAnchorPoint(cc.p(0, 1))
		desLabel:setPosition(posX+100, posY)
		listBg:addChild(desLabel)

		posY = posY + space
	end
	createDes(1, TR("VIP每日福利铜币奖励+20%"))
	createDes(2, TR("江湖宝箱奖励元宝+20%"))
	createDes(3, TR("超级VIP专属新手礼包"))
	createDes(4, TR("超级VIP开通或续费礼包"))
end

function QQVipWelfareLayer:welfareRewardList()
	-- 黑背景
	local blackSize = cc.size(555, 341)
	local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
	blackBg:setAnchorPoint(cc.p(0.5, 0.5))
	blackBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.35)
	self.mBgSprite:addChild(blackBg)
	-- 奖励
	local posY = blackSize.height - 10
	local space = -167
	local function createReward (rewardType, text, rewardStr, hintText)
		-- 背景
		local cellSize = cc.size(535, 159)
		local bgSprite = ui.newScale9Sprite("c_18.png", cellSize)
		bgSprite:setAnchorPoint(cc.p(0.5, 1))
		bgSprite:setPosition(blackSize.width*0.5, posY)
		blackBg:addChild(bgSprite)
		-- 描述
		local desLabel = ui.newLabel({
				text = text,
			})
		desLabel:setAnchorPoint(cc.p(0, 0))
		desLabel:setPosition(20, cellSize.height-30)
		bgSprite:addChild(desLabel)
		-- 奖励
		local rewardList = Utility.analysisStrResList(rewardStr)
		local cardList = ui.createCardList({
				maxViewWidth = 370,
				space = -5,
				cardDataList = rewardList,
			})
		cardList:setAnchorPoint(cc.p(0, 0.5))
		cardList:setPosition(10, cellSize.height*0.4)
		bgSprite:addChild(cardList)
		-- 领取
		local getBtn = ui.newButton({
				normalImage = "c_28.png",
				text = TR("领取"),
				clickAction = function ()
		        	self:requestReward(rewardType)
				end
			})
		getBtn:setPosition(450, cellSize.height*0.5)
		bgSprite:addChild(getBtn)
		-- 提示(只限领取一次)
		local hintLabel = ui.newLabel({
				text = hintText,
				color = Enums.Color.eRed,
				size = 22,
			})
		hintLabel:setPosition(450, cellSize.height*0.15)
		bgSprite:addChild(hintLabel)

		self.mGetBtnList[rewardType] = getBtn

		posY = posY + space
	end
	createReward(RewardType.eQQVipReward, TR("#FF4A46超级VIP#46220d专属新手礼包"), PrivilegeModel.items[1].QQVipReward, TR("只限领取一次"))
	createReward(RewardType.eQQSVipReward, TR("#FF4A46超级VIP#46220d开通／续费礼包"), PrivilegeModel.items[1].QQSVipReward, TR("每月领取一次"))
end


function QQVipWelfareLayer:refreshLayer()
	-- 刷新列表
	self.mGetBtnList[RewardType.eQQVipReward]:setEnabled(self.mData.CanReceiveQQVipReward)
	self.mGetBtnList[RewardType.eQQSVipReward]:setEnabled(self.mData.CanReceiveQQSVipReward)

end

-----------------------网络相关---------------------
-- 请求信息
function QQVipWelfareLayer:requestInfo()
	HttpClient:request({
        moduleName = "PrivilegeRecord",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mData = response.Value
            self:refreshLayer()
        end
	})
end

-- 领取奖励
function QQVipWelfareLayer:requestReward(rewardType)
		HttpClient:request({
	        moduleName = "PrivilegeRecord",
	        methodName = "ReceiveReward",
	        svrMethodData = {rewardType},
	        callback = function(response)
	            if not response or response.Status ~= 0 then
	                return
	            end
	            self.mData = response.Value
	            self:refreshLayer()

	            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
	        end
		})
end

return QQVipWelfareLayer