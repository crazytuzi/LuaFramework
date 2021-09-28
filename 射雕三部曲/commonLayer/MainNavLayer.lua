--[[
    文件名：MainNavLayer.lua
	描述：页面底部的主要导航按钮页面
	创建人：liaoyuangang
	创建时间：2016.3.30
--]]

local MainNavLayer = class("MainNavLayer", function(params)
    return display.newLayer()
end)

-- 组队副本不直接提示的界面名
local CloseHintList = {
    ["ComBattle.BattleLayer"] = true, -- 战斗页面
    ["challenge.ExpediMapLayer"] = true, -- 组队副本
    ["challenge.ExpediFightLayer"] = true, -- 组队副本
    ["shengyuan.ShengyuanWarsTeamLayer"] = true, -- 桃花岛组队
}

--[[
-- 参数
    params中的各项为：
    {
        currentLayerType:枚举类型，当前页面属于哪个模块 所有枚举在Enums.MainNav中定义
    }
--]]
function MainNavLayer:ctor(params)
    params = params or {}
    -- 导航按钮首页的key
    self.mCurrentLayerType = params.currentLayerType

    -- 导航按钮列表
    self.mNavBtnList = {}

	-- 创建导航按钮的信息列表
	self.mNavBtnInfo = {
		{ -- 首页
			normalImage = "c_12.png",
            selectImage = "c_12.png",
			position = cc.p(55, 52),
            navType = Enums.MainNav.eHome,
			clickAction = function()                    
				local topLayerName = LayerManager.getTopCleanLayerName()
				local addLayerName = "home.HomeLayer"
				if topLayerName == addLayerName then
					print("Is same layername, so retrun:", addLayerName)
					return
				end

                -- 判断是否在六大门派中
                self:isExpedTeam()

				LayerManager.addLayer({name = addLayerName, isRootLayer = true})
			end
		},
        { -- 队伍
        	normalImage = "c_11.png",
            selectImage = "c_11.png",
        	position = cc.p(160, 52),
            navType = Enums.MainNav.eFormation,
        	moduleId = ModuleSub.eFormation,
        	clickAction = function()
				local topLayerName = LayerManager.getTopCleanLayerName()
				local addLayerName = "team.TeamLayer"
				if topLayerName == addLayerName then

					print("Is same layername, so retrun:", addLayerName)
					return
				end

                -- 判断是否在六大门派中
                self:isExpedTeam()

				LayerManager.addLayer({name = addLayerName, isRootLayer = true, data = data,})
			end
        },
        { -- 江湖
        	normalImage = "c_13.png",
            selectImage = "c_13.png",
        	position = cc.p(265, 52),
            navType = Enums.MainNav.eBattle,
        	moduleId = ModuleSub.eBattle,
        	clickAction = function()
				local topLayerName = LayerManager.getTopCleanLayerName()
				local addLayerName = "battle.BattleMainLayer"
				if topLayerName == addLayerName then
					print("Is same layername, so retrun:", addLayerName)
					return
				end

                -- 判断是否在六大门派中
                self:isExpedTeam()

				LayerManager.addLayer({name = addLayerName, isRootLayer = true})
			end
        },
        { -- 挑战
        	normalImage = "c_14.png",
            selectImage = "c_14.png",
        	position = cc.p(370, 52),
            navType = Enums.MainNav.eChallenge,
        	moduleId = ModuleSub.eChallenge,
        	clickAction = function()
				local topLayerName = LayerManager.getTopCleanLayerName()
				local addLayerName = "challenge.ChallengeLayer"
				if topLayerName == addLayerName then
					print("Is same layername, so retrun:", addLayerName)
					return
				end

                -- 判断是否在六大门派中
                self:isExpedTeam()

				LayerManager.addLayer({name = addLayerName, isRootLayer = true})
			end
        },
        { -- 修炼
        	normalImage = "c_15.png",
            selectImage = "c_15.png",
        	position = cc.p(475, 52),
            navType = Enums.MainNav.ePractice,
        	moduleId = ModuleSub.ePractice,
        	clickAction = function()
				local topLayerName = LayerManager.getTopCleanLayerName()
				local addLayerName = "practice.PracticeLayer"
				if topLayerName == addLayerName then
					print("Is same layername, so retrun:", addLayerName)
					return
				end

                -- 判断是否在六大门派中
                self:isExpedTeam()

				LayerManager.addLayer({name = addLayerName, isRootLayer = true})
			end
        }
        ,
        { -- 商店
            normalImage = "c_16.png",
            selectImage = "c_16.png",
            position = cc.p(580, 52),
            navType = Enums.MainNav.eStore,
            moduleId = ModuleSub.eStore,
            clickAction = function()
                local topLayerName = LayerManager.getTopCleanLayerName()
                local addLayerName = "shop.ShopLayer"
                if topLayerName == addLayerName then
                    print("Is same layername, so retrun:", addLayerName)
                    return
                end

                -- 判断是否在六大门派中
                self:isExpedTeam()

                LayerManager.addLayer({name = addLayerName, isRootLayer = true})
            end
        }
	}

	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function MainNavLayer:initUI()
	-- 主导航按钮的背景图
	local tempSprite = ui.newSprite("sy_33.png")
	tempSprite:setAnchorPoint(cc.p(0.5, 0))
	tempSprite:setPosition(cc.p(display.cx, Adapter.BottomY))
	tempSprite:setScale(Adapter.MinScale)
	self:addChild(tempSprite)

	-- 创建导航按钮
	for _, btnInfo in pairs(self.mNavBtnInfo) do
        local isSelectBtn = btnInfo.navType == self.mCurrentLayerType
        local tempInfo = {
            normalImage = isSelectBtn and btnInfo.selectImage or btnInfo.normalImage,
            position = btnInfo.position,
            clickAction = btnInfo.clickAction
        }
		local tempBtn = ui.newButton(tempInfo)
		tempSprite:addChild(tempBtn)
        -- 保存按钮
        self.mNavBtnList[btnInfo.navType] = tempBtn

		-- 小红点是否显示逻辑
		if btnInfo.moduleId then
            local function dealRedDotVisible(redDotSprite)
                -- 商城添加特殊的道具触发事件(在RedDotInfoObj中自动处理)
                local redDotData = RedDotInfoObj:isValid(btnInfo.moduleId)
                redDotSprite:setVisible(redDotData)
            end

            -- 商城添加特殊的道具触发事件(在RedDotInfoObj中自动处理)
            local eventNames = RedDotInfoObj:getEvents(btnInfo.moduleId)
            ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = eventNames, parent = tempBtn})
		end
	end

    -- 创建首页按钮的子按钮
    self:createHomeSubBtn()
    -- 创建江湖按钮的效果
    -- Utility.performWithDelay(tempSprite, handler(self, self.createBattleEffect), 0)
end

-- 创建首页按钮的子按钮
function MainNavLayer:createHomeSubBtn()
    -- 处理子按钮的显示状态
    local function dealSubBtnViewStatus(subBtn)
        -- 初始不显示
        subBtn:setVisible(false)

        local btnImageName = ""
        if not CloseHintList[LayerManager.getTopCleanLayerName()] then
            -- 光明顶
            local expediData = PlayerAttrObj:getPlayerAttrByName("ExpedInvitData")
            -- 桃花岛
            local shengyuanInviData = PlayerAttrObj:getPlayerAttrByName("ShengyuanWarsInvitData")
            -- 守卫襄阳
            local teamBattleStatus = PlayerAttrObj:getPlayerAttrByName("TeamBattleStatus")
            if expediData and next(expediData) ~= nil then
                btnImageName = "jzthd_82.png"
            elseif shengyuanInviData and next(shengyuanInviData) ~= nil then
                btnImageName = "jzthd_81.png"
            elseif teamBattleStatus and teamBattleStatus ~= Enums.TeamBattleStatus.eNone then
                btnImageName = "jzthd_83.png"
            end

            if string.len(btnImageName) > 0 then
                subBtn:loadTextures(btnImageName, btnImageName)
                subBtn.setAction()
                -- 提示框显示
                subBtn:setVisible(true)
                MqAudio.playEffect("zuduiyaoqing.mp3")
            end
        end
    end

    -- 首页按钮
    local homeBtn = self.mNavBtnList[Enums.MainNav.eHome]
    local homeBtnSize = homeBtn:getContentSize()
    -- 创建子首页按钮
    local subBtn = ui.newButton({
        normalImage = "jzthd_81.png",
        scale = 1.5,
        clickAction = function(pSender)
            -- 光明顶
            local expediData = PlayerAttrObj:getPlayerAttrByName("ExpedInvitData")
            -- 桃花岛
            local shengyuanInviData = PlayerAttrObj:getPlayerAttrByName("ShengyuanWarsInvitData")
            -- 守卫襄阳
            local teamBattleStatus = PlayerAttrObj:getPlayerAttrByName("TeamBattleStatus")
            if expediData and next(expediData) ~= nil then
                LayerManager.addLayer({
                    name = "challenge.ExpediInvitedLayer",
                    data = {dataList = expediData},
                    cleanUp = false,
                })
            elseif shengyuanInviData and next(shengyuanInviData) ~= nil then
                LayerManager.addLayer({
                    name = "shengyuan.ShengyuanWarsInvitedLayer",
                    data = {dataList = shengyuanInviData},
                    cleanUp = false,
                })
            elseif teamBattleStatus and teamBattleStatus ~= Enums.TeamBattleStatus.eNone then
                Utility.showTeambattleInvitedLayer()
            end
            -- 点击后自动关闭
            pSender:setVisible(false)
        end,
    })
    subBtn:setAnchorPoint(1.0, 0.5)
    subBtn:setPosition(0, 568)
    homeBtn:addChild(subBtn)

    -- 默认显示的动画
    subBtn.setAction = function()
        subBtn:stopAllActions()
        local flashAct = cc.Sequence:create({cc.MoveTo:create(0.25, cc.p(288, 568)), 
            cc.DelayTime:create(10),
            cc.MoveTo:create(0.25, cc.p(0, 568)),
            cc.CallFunc:create(function()
                -- 一定时间后自动关闭
                subBtn:setVisible(false)
                -- 修改主队副本邀请的状态
                PlayerAttrObj:changeAttr({TeamBattleStatus = Enums.TeamBattleStatus.eNone})
            end), })
        subBtn:runAction(flashAct)
    end

    -- 组队副本更新事件
    local eventNames = {
        EventsName.eSocketPushPrefix .. tostring(ModuleSub.eTeambattleInvite),
        EventsName.eInviteInfoNewPrefix,  -- 组队邀请状态
        EventsName.eShengyuanWarsInvite,  -- 桃花岛组队邀请状态
    }
    Notification:registerAutoObserver(subBtn, dealSubBtnViewStatus, eventNames)
    dealSubBtnViewStatus(subBtn)
end

-- 创建江湖按钮的光圈效果
function MainNavLayer:createBattleEffect()
    local curTopLayerName = LayerManager.getTopCleanLayerName()
    local curLv = PlayerAttrObj:getPlayerAttrByName("Lv")
    local _, _, eventID = Guide.manager:getGuideInfo()
    if curLv < 20 and not string.find(curTopLayerName , "battle.") and not eventID then
        local navBtn = self.mNavBtnList[Enums.MainNav.eBattle]
        local navSize = navBtn:getContentSize()
        -- 点击提示光圈和手指
        ui.addGuideArrowEffect(navBtn, cc.p(navSize.width/2, navSize.height/2))
    end
end

-- 获取主导航按钮的高度
function MainNavLayer:getNavBgHeight()
	return 100
end

-- 根据导航按钮类型获取导航按钮对象
--[[
-- 参数
    mainNavType: 需要获取“button”的对象的导航按钮类型 所有枚举在Enums.MainNav中定义
]]
function MainNavLayer:getNavBtnObj(mainNavType)
    return self.mNavBtnList[mainNavType]
end

-- 判断是否在六大派中
function MainNavLayer:isExpedTeam()
    local isExpedTeam = PlayerAttrObj:getPlayerAttrByName("isExpedTeam")
    if isExpedTeam then 
        self:requestExitTeam()
    end 
end 

-- 退出六大门派
function MainNavLayer:requestExitTeam()
    local playerId = PlayerAttrObj:getPlayerAttrByName("PlayerId")
    HttpClient:request({
        moduleName = "ExpeditionNode",
        methodName = "ExitTeam",
        svrMethodData = {playerId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            ui.showFlashView(TR("退出队伍"))
            PlayerAttrObj:changeAttr({
                isExpedTeam = false
            })
            -- PlayerAttrObj:changeAttr({
            --     isUseDouble = false
            -- })
        end
    })
end

return MainNavLayer
