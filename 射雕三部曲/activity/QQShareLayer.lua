--[[
	文件名:QQShareLayer.lua
	描述：QQ分享界面
	创建人：yanghongsheng
    创建时间：2018.04.13
--]]

local QQShareLayer = class("QQShareLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：
	{
		activityIdList: 活动实体Id列表
		parentModuleId: 该活动的主模块Id

		cacheData: 该页面的缓存信息，主要用于恢复该页面时使用，普通调用者一般不会使用该参数
	}
]]

function QQShareLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

	-- 创建页面控件
	self:initUI()

	-- 请求服务器
	self:requestInfo()
end

-- 获取恢复数据
function QQShareLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

function QQShareLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("qq_01.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 奖励面板
	local rewardBgSize = cc.size(593, 284)
	local rewardBg = ui.newScale9Sprite("jc_48.png", rewardBgSize)
	rewardBg:setPosition(320, 312)
	self.mParentLayer:addChild(rewardBg)

	-- title
	local posY = rewardBgSize.height-30
	local posX = rewardBgSize.width*0.5
	local space = 20
	local titleLabel = ui.newLabel({
			text = TR("成功分享游戏可获得以下奖励"),
			color = Enums.Color.eWhite,
			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
		})
	titleLabel:setPosition(posX, posY)
	rewardBg:addChild(titleLabel)

	local leftSprite = ui.newSprite("jc_49.png")
	leftSprite:setRotationSkewY(-180)
	local rightSprite = ui.newSprite("jc_49.png")

	rewardBg:addChild(leftSprite)
	rewardBg:addChild(rightSprite)

	leftSprite:setAnchorPoint(cc.p(0, 0.5))
	rightSprite:setAnchorPoint(cc.p(0, 0.5))

	leftSprite:setPosition(posX - (titleLabel:getContentSize().width*0.5 + space), posY)
	rightSprite:setPosition(posX + (titleLabel:getContentSize().width*0.5 + space), posY)

	-- 奖励背景
	local cardBgSize = cc.size(rewardBgSize.width-10, 134)
	local cardBg = ui.newScale9Sprite("c_17.png", cardBgSize)
	cardBg:setPosition(rewardBgSize.width*0.5, rewardBgSize.height*0.52)
	rewardBg:addChild(cardBg)

	-- 奖励
	local rewardList = Utility.analysisStrResList(PrivilegeModel.items[1].shareReward)
	local cardList = ui.createCardList({
			maxViewWidth = cardBgSize.width*0.95,
			cardDataList = rewardList,
		})
	cardList:setAnchorPoint(cc.p(0.5, 0.5))
	cardList:setPosition(cardBgSize.width*0.5, cardBgSize.height*0.5)
	cardBg:addChild(cardList)

	-- “仅限领取一次”
	local hintLabel = ui.newLabel({
			text = TR("每週可領取一次"),
			color = Enums.Color.eRed,
		})
	hintLabel:setAnchorPoint(cc.p(0, 0.5))
	hintLabel:setPosition(cardBgSize.width*0.65, 50)
	rewardBg:addChild(hintLabel)

	-- 分享到
	local shareSprite = ui.newSprite("qq_07.png")
	shareSprite:setAnchorPoint(cc.p(1, 0.5))
	shareSprite:setPosition(470, 504)
	self.mParentLayer:addChild(shareSprite)

	-- QQ空间按钮
	local qqSpaceBtn = ui.newButton({
			normalImage = "qq_09.png",
			clickAction = function ()
				local shareFBData = {
						url = "http://xln.gamedreamer.com/"
					}

				local jstr = json.encode(shareFBData)

				IPlatform:getInstance():invoke("ShareToFB",jstr, function(jsonStr)
					local data = cjson.decode(jsonStr)
					if data["ret"] == "0" then
						--分享成功
						ui.showFlashView(TR("分享成功"))
	                    self.mLayerData.isShare = true
	                    self:refreshLayer()
					else
						--分享失败
						ui.showFlashView(TR("分享失败"))
					end
				end)
			end
		})
	qqSpaceBtn:setPosition(520, 504)
	self.mParentLayer:addChild(qqSpaceBtn)
	
	-- 领取
	local getBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("领取"),
			clickAction = function ()
				self:requestReward(3)
			end,
		})
	getBtn:setPosition(320, 215)
	self.mParentLayer:addChild(getBtn)
	self.mGetBtn = getBtn

	--返回按钮
	local closeBtn = ui.newButton({
	    normalImage = "c_29.png",
	    position = cc.p(594, 930),
	    clickAction = function(pSender)
	        LayerManager.addLayer({
	            name = "home.HomeLayer"
	        })
	    end
	})
	self.mCloseBtn = closeBtn
	self.mParentLayer:addChild(closeBtn)
end

function QQShareLayer:refreshLayer()
	-- 刷新列表
	self.mGetBtn:setEnabled(self.mLayerData.CanReceiveShareReward and self.mLayerData.isShare)
end

-----------------------网络相关---------------------
-- 请求信息
function QQShareLayer:requestInfo()
	HttpClient:request({
        moduleName = "PrivilegeRecord",
        methodName = "GetInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mLayerData = response.Value
            self:refreshLayer()
        end
	})
end

-- 领取奖励
function QQShareLayer:requestReward(rewardType)
	HttpClient:request({
        moduleName = "PrivilegeRecord",
        methodName = "ReceiveReward",
        svrMethodData = {rewardType},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mLayerData = response.Value
            self:refreshLayer()

            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
        end
	})
end

return QQShareLayer