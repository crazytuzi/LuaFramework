--[[
    文件名: ActivityDinnerLayer.lua
	描述: 体力便当页面, 模块Id为：ModuleSub.eExtraActivityDinner
	效果图: j精彩活动_至尊盛宴.jpg
	创建人: liaoyuangang
	创建时间: 2016.6.2
--]]

local ActivityDinnerLayer = class("ActivityDinnerLayer", function()
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
function ActivityDinnerLayer:ctor(params)
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
function ActivityDinnerLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 初始化页面控件
function ActivityDinnerLayer:initUI()
	-- 背景图
    local bgSprite = ui.newSprite("jc_30.jpg") 
    bgSprite:setPosition(320,568) 
    self.mParentLayer:addChild(bgSprite)

    --说明背景
    local decBgSize = cc.size(520, 96)
    local decBg = ui.newScale9Sprite("c_145.png", decBgSize)
    decBg:setPosition(cc.p(280, 920))
    decBg:setAnchorPoint(cc.p(0.5,0.5))
    self.mParentLayer:addChild(decBg)

    -- 文字
    local textLabel = ui.newLabel({
        text = TR("每天%s12~18%s点和%s18~21%s点%s21~24%s点均可享用至尊盛宴补充体力",
            Enums.Color.eGoldH, 
            Enums.Color.eWhiteH, 
            Enums.Color.eGoldH, 
            Enums.Color.eWhiteH, 
            Enums.Color.eGoldH,
            Enums.Color.eWhiteH
        ),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
        outlineSize = 2,
        size = 22,
        dimensions = cc.size(500, 0),
    })
    textLabel:setPosition(300, 920)
    self.mParentLayer:addChild(textLabel)

    -- -- 人物
    -- local figureSprite = ui.newSprite("jc_18.png")
    -- figureSprite:setPosition(350, 350)
    -- bgSprite:addChild(figureSprite)

    -- 盘子
    local tray = ui.newSprite("jc_31.png")
    tray:setAnchorPoint(cc.p(0.5, 0))
    tray:setPosition(320, 70)
    bgSprite:addChild(tray)

   	-- 领取按钮
    self.mGetBtn = ui.newButton({
        normalImage = "jc_32.png",
        --disabledImage = "jchd_25.png",
        clickAction = function()
        	-- 领取奖励
        	self:requestPlayerVIT()
        end
    })
    self.mGetBtn:setAnchorPoint(cc.p(0.5, 0))
    self.mGetBtn:setPosition(320, 70)
    bgSprite:addChild(self.mGetBtn)

    -- 特效
    local getBtnSize = self.mGetBtn:getContentSize()
    local effect = ui.newEffect({
            parent = self.mGetBtn,
            effectName = "effect_ui_zuixianlou",
            position = cc.p(getBtnSize.width*0.5, getBtnSize.height*0.5),
            loop = true,
        })

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

    self.mGetBtn:setVisible(RedDotInfoObj:isValid(ModuleSub.eExtraActivityDinner))
end

-------------------------网络相关-----------------------------------------
-- 领取体力
function ActivityDinnerLayer:requestPlayerVIT()
    HttpClient:request({
        moduleName = "PlayerVIT",
        methodName = "ReceiveVIT",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
            if not response.Value or response.Status ~= 0 then
                return
            end
            -- 飘窗显示获得的资源
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            self.mGetBtn:setVisible(false)
	    end
	})
end

return ActivityDinnerLayer

