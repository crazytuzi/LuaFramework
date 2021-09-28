--[[
    文件名: ActivityDailyShareLayer.lua
	描述: 每日分享页面（又叫礼包兑换）, 模块Id为：ModuleSub.eExtraActivityDailyShare
	效果图: j精彩活动_礼包兑换.jpg
	创建人: liaoyuangang
	创建时间: 2016.6.2
--]]

local ActivityDailyShareLayer = class("ActivityDailyShareLayer", function()
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
function ActivityDailyShareLayer:ctor(params)
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

	-- 初始化页面控件
	self:initUI()

	if not self.mLayerData then  -- 证明是第一次进入该页面
		-- Todo  requestServerData 
	end
end

-- 获取恢复数据
function ActivityDailyShareLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 初始化页面控件
function ActivityDailyShareLayer:initUI()
    -- 背景
    local bg = ui.newSprite("jc_26.jpg")
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setPosition(320,568)
    self.mParentLayer:addChild(bg)

    -- title图
    local titleSprite = ui.newSprite("jc_10.png")
    titleSprite:setAnchorPoint(cc.p(0, 0.5))
    titleSprite:setPosition(0,900)
    self.mParentLayer:addChild(titleSprite)

    -- --人物
    -- local figureSprite = ui.newSprite("jc_18.png")
    -- figureSprite:setPosition(420, 500)
    -- self.mParentLayer:addChild(figureSprite)

    --提示信息背景
    local decBgSize = cc.size(520, 130)
    local decBg = ui.newScale9Sprite("c_145.png", decBgSize)
    decBg:setAnchorPoint(cc.p(0.5, 0.5))
    decBg:setPosition(cc.p(320, 650))
    self.mParentLayer:addChild(decBg)

    -- 感叹号icon
    local gantan = ui.newSprite("c_63.png")
    gantan:setPosition(decBgSize.width*0.1, decBgSize.height*0.7)
    decBg:addChild(gantan)

    -- 提示信息
    local gantanX ,gantanY = gantan:getPosition()
    local introLabel1 = ui.newLabel({
        text = TR("输入激活码可立即获得各种礼包",
            self.mNeedVipLv,
            Enums.Color.eWhiteH
        ),
        size = 24,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        outlineSize = 2,
        x = gantanX + 30,
        y = gantanY - 15,
    })
    introLabel1:setAnchorPoint(cc.p(0, 0))
    decBg:addChild(introLabel1)

    -- 输入框
    local editBox = ui.newEditBox({
        image = "c_38.png",
        size = cc.size(350, 56),
        fontSize = 26,
    })
    editBox:setPlaceHolder(TR("请输入激活码"))
    editBox:setPosition(decBgSize.width*0.5, decBgSize.height*0.3)
    decBg:addChild(editBox)

    -- 领取按钮
    local getBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("领取"),
        position = cc.p(320, 520),
        clickAction = function()
        	local text = editBox:getText()
		    if text and string.len(text) > 0 then
        		self:requestActiveGift(text)
     		else
		        ui.showFlashView({text = TR("请输入激活码")})
		    end    
        end
    })
    self.mParentLayer:addChild(getBtn)

    -- local sp1 = ui.newSprite("jchd_08.png")
    -- sp1:setPosition(cc.p(25, 280))
    -- bgSprite:addChild(sp1)

    -- local sp2 = ui.newSprite("jchd_08.png")
    -- sp2:setPosition(cc.p(25, 138))
    -- bgSprite:addChild(sp2)

    -- -- 下面描述
    -- local dec = ui.newLabel({
    --     text = TR("     打开微信———点击右上角 \"+\" 号添加朋友———输入" ..
    --             "微信号: \"%s xdzz01%s\"，关注后点击 \"礼包码\" 按提示即可领" ..
    --             "取礼包码。礼包码游戏内使用方法: " .. 
    --             "点击 \"精彩活动\" ———\"礼包兑换\"！关注微信，更多" ..
    --             "超值礼包大奖等你来拿！", "#03e3f1", "#ffffff"),
    --     dimensions = cc.size(620, 0),
    --     size = 24,
    -- })
    -- dec:setAnchorPoint(cc.p(0, 1))
    -- dec:setPosition(20, 290)
    -- bgSprite:addChild(dec)

    -- local des1 = ui.newLabel({
    --     text = TR("     关注微信, 更多超值礼包大奖等你来拿!"),
    --     size = 24,
    -- })
    -- des1:setAnchorPoint(cc.p(0, 1))
    -- --dec:setMaxLineWidth(600)
    -- des1:setPosition(20, 150)
    -- bgSprite:addChild(des1)

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

-----------------网络相关-------------------
function ActivityDailyShareLayer:requestActiveGift(text)
    HttpClient:request({
        moduleName = "ActiveGift", 
        methodName = "ActiveGift",
        svrMethodData = {text},
        callbackNode = self,
        callback = function (response)
        	--dump(response,"ssssssss")

            if not response.Value or response.Status ~= 0 then
                return
            end

        	self.mLayerData = response

        	ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
        end
	})
end

return ActivityDailyShareLayer
