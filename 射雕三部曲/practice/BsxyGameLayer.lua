--[[
	文件名：BsxyGameLayer.lua
	描述：拜师学艺小游戏
	创建人：heguanghui
	创建时间：2017.6.9
--]]
local BsxyGameLayer = class("BsxyGameLayer", function ()
	return display.newLayer()
end)

--构造函数
--[[
	参数：
        teacherId: 师傅Id，用于请求接口
		gameId: 游戏次数，决定时长，默认为1
--]]
function BsxyGameLayer:ctor(params)
	-- 游戏进行次数，决定游戏时间
	self.mGameId = params.gameId or 1
    self.mTeacherId = params.teacherId
	--页面父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 创建底部导航和顶部玩家信息部分
    -- local tempLayer = require("commonLayer.CommonLayer"):create({
    --     needMainNav = true,
    --     currentLayerType = Enums.MainNav.ePractice,
    --     topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    -- })
    -- self:addChild(tempLayer)

    --背景图
	local bgSprite = ui.newSprite("c_34.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

    -- 关闭按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            self.gameRunning = false
            local msgBox = MsgBoxLayer.addOKLayer(
                TR("退出当前挑战？"),
                nil,
                {{
                    text = TR("确定"),
                    clickAction = function()
                        LayerManager.removeLayer(self)
                    end
                }},
                {
                    clickAction = function (layerObj)
                        self.gameRunning = true
                        LayerManager.removeLayer(layerObj)
                    end
                }
            )

        end
    })
    closeBtn:setPosition(580, 1050)
    self.mParentLayer:addChild(closeBtn)

    -- 添加定时更新事件
    self.mRefreshHandle = nil
    bgSprite:registerScriptHandler(function (event)
        local scheduler = cc.Director:getInstance():getScheduler()
        if event == "enter" then
            self.mRefreshHandle = scheduler:scheduleScriptFunc(handler(self, self.updateGame), 0, false)
        elseif event == "exit" then
            scheduler:unscheduleScriptEntry(self.mRefreshHandle)
        end
    end)
    
    -- 初始化游戏数据
    self:gameInitialize()
    -- 添加划动触摸事件
    self:addTouchEvent()
end

-- 创建基本UI
function BsxyGameLayer:updateGame(delay)
    if self.gameRunning then
        if #self.curSwordList == 0 then
            -- 游戏结束
            self:gameOver()
        else
            -- 更新剑的位置
            for i,v in ipairs(self.curSwordList) do
                v.time = v.time + delay
                if v.time > v.info.time then

                    local x, y = v.point:getPosition()
                    local mx = x + v.dir.x * delay * v.info.speed
                    local my = y + v.dir.y * delay * v.info.speed
                    local isInScreen = (mx > 0 and mx < 640 and my > 0 and my < 1136)
                    if v.inScreen == true and not isInScreen then
                        -- 如移到屏幕外，则游戏结束
                        ui.newEffect({
                            parent = self.mParentLayer,
                            effectName = "effect_ui_biaoxue",
                            position = cc.p(mx, my),
                            -- scale  = 
                            loop = false,
                            -- animation = ,
                            endListener = function ()
                                
                            end,
                            })
                        self:gameOver(cc.p(x, y))
                        break
                    elseif v.inScreen == nil and isInScreen then
                        -- 标记已在屏幕中
                        v.inScreen = isInScreen
                    end
                    local angle = 180/(math.pi/math.acos(v.dir.x))

                    if v.dir.x <= 0 and v.dir.y >= 0 then
                        angle = 90 - angle
                    elseif v.dir.x <= 0 and v.dir.y <= 0 then
                        angle = angle + 90
                    elseif v.dir.x >= 0 and v.dir.y <= 0 then
                        angle = angle - 270
                    else
                        angle = angle - 30
                    end

                    v.point:setPosition(mx, my)
                    v.point:setRotation(angle)
                    v.point:setVisible(true)
                    -- v.sword:setPosition(mx, my)
                    -- v.sword:setRotation(angle)
                end
            end
        end
    end
end

function BsxyGameLayer:createSword(index)
    -- 开始出现新的剑
    -- local swordIndex = math.random(1, #TeacherGameRelation.items)
   
    local swordModel = TeacherGameRelation.items[self.mGameId][index]

    -- 创建剑位置
    local swordPoint = ccui.Scale9Sprite:create("bsxy_28.png", cc.rect(0, 0, 34, 63), cc.rect(26, 35.5, 10, 10))
    self.mParentLayer:addChild(swordPoint)
    swordPoint:setAnchorPoint(0.5, 0.95)
    swordPoint:setContentSize(31, 530)
    swordPoint:setVisible(false)

    local startPos = Utility.analysisPoints(swordModel.coordinateA)
    local endPos = Utility.analysisPoints(swordModel.coordinateB)
    local pt = cc.p(endPos.x - startPos.x, endPos.y - startPos.y)
    local length = math.sqrt( pt.x * pt.x + pt.y * pt.y )
    local direction = cc.p(pt.x/length, pt.y/length)
    swordPoint:setPosition(startPos)
    if self.mGameId == 1 and index == 1 then
        local eff = ui.newEffect({
            parent = swordPoint,
            effectName = "effect_ui_huadongzhiying",
            position = cc.p(15, 520),
            -- scale  = 
            -- speed = 1.5,
            loop = true,
            -- animation = ,
            endListener = function ()
                
            end,
        })
    end

    local delayConTime = 0

    table.insert(self.curSwordList, {point=swordPoint, dir=direction, info = swordModel, time = delayConTime})
end

-- 划动事件
function BsxyGameLayer:addTouchEvent()
    -- 添加touch事件
    local touchStreak = nil
    ui.registerSwallowTouch({
        node = self.mParentLayer,
        allowTouch = false,
        beganEvent = function (touch, event)
            if touchStreak then
                touchStreak:removeFromParent()
                touchStreak = nil
            end
            local curPos = touch:getLocation()
            local parentPos = self.mParentLayer:convertToNodeSpace(curPos)
            touchStreak = cc.MotionStreak:create(0.5, 1.0, 35.0, cc.c3b(255, 255, 255), "bsxy_30.png")
            touchStreak:setPosition(parentPos)
            self.mParentLayer:addChild(touchStreak)
            return true
        end,
        movedEvent = function (touch, event)
            local curPos = touch:getLocation()
            touchStreak:setPosition(curPos)
            local parentPos = self.mParentLayer:convertToNodeSpace(curPos)
            touchStreak:setPosition(parentPos)
            -- 和每支剑碰撞检测
            for i = #self.curSwordList, 1, -1 do
                local v = self.curSwordList[i]
                local mx, my = v.point:getPosition()
                local pt = cc.p(mx - parentPos.x, my - parentPos.y)
                local distance = math.sqrt( pt.x * pt.x + pt.y * pt.y )
                if distance < 40 then
                    -- 自动消失
                    local itemV = v
                    local CallFunc = cc.CallFunc:create(function ()
                        ui.newEffect({
                            parent = self.mParentLayer,
                            effectName = "effect_ui_jiansui",
                            position = cc.p(mx, my),
                            -- scale  = 
                            -- speed = 1.5,
                            loop = false,
                            -- animation = ,
                            endListener = function ()
                                
                            end,
                            })
                    end)
                    itemV.point:runAction(cc.Sequence:create({
                        cc.Spawn:create(CallFunc, cc.FadeOut:create(0.5)),       
                        cc.CallFunc:create(function()
                            itemV.point:removeFromParent()
                            -- itemV.sword:removeFromParent()
                            end),
                        }))
                    -- 从列表中删除
                    MqAudio.playEffect("bsxy_break.mp3", false)
                    table.remove(self.curSwordList, i)
                end
            end
        end,
    })
end

-- 游戏结束
-- point: 游戏结束时位置，如为空则表示全通关
function BsxyGameLayer:gameOver(point)
    self.gameRunning = false
    -- 游戏结束
    if point then
        self:showTips(false)
        print("游戏失败")
    else
        self:showTips(true)
        print("游戏过关")
    end
end

function BsxyGameLayer:gameInitialize()
    -- self.curTurn = self.gameCount * 5
    self.gameRunning = true
    if self.curSwordList then
        for i,v in ipairs(self.curSwordList) do
            v.point:removeFromParent()
            -- v.sword:removeFromParent()
        end
    end
    self.curSwordList = {}
    for i = 1, #TeacherGameRelation.items[self.mGameId] do
        self:createSword(i)
    end
end

function BsxyGameLayer:showTips(isWin)

    if isWin then
        local msgBox = MsgBoxLayer.addOKLayer(
            TR("恭喜完成学习"),
            nil,
            {{
                text = TR("退出"),
                clickAction = function()
                    self:requestGetAttr()
                end
            }}
        )
    else
        MqAudio.playEffect("bsxy_fail.mp3", false)
        local msgBox = MsgBoxLayer.addOKCancelLayer(
            TR("很遗憾，就差一点就能学会了"),
            nil,
            {
                text = TR("退出"),
                clickAction = function()
                    LayerManager.removeLayer(self)
                end
            },
            {
                text = TR("重新练习"),
                clickAction = function(layerObj)
                    self:gameInitialize()
                    LayerManager.removeLayer(layerObj)
                end
            },
            nil,
            false
        )
    end
end

---------------------------网络相关----------------------
function BsxyGameLayer:requestGetAttr()
    HttpClient:request{
        moduleName = "TeacherInfo",
        methodName = "GetAttr",
        svrMethodData = {self.mTeacherId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            LayerManager.removeLayer(self)
        end,
    }
end

return BsxyGameLayer