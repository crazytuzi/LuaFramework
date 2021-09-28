--[[
    文件名：KillerValleyPlayer.lua
    描述：绝情谷玩家对象
    创建人：heguanghui
    创建时间：2018.1.22
-- ]]

local KillerValleyPlayer = class("KillerValleyPlayer", function(params)
    return display.newNode()
end)

--[[
    -- playerInfo: 玩家数据
    -- astarWorld: 障碍地图
--]]

function KillerValleyPlayer:ctor(params)
    self.mPlayerInfo = params.playerInfo
    -- dump(self.mPlayerInfo, "playerInfo")
    self.mAstarWorld = params.astarWorld

    self.mHpBarList = {} --血条对象列表
    self.mEffectList = {} --特效列表

    -- 判断是否玩家自己
    self.mIsSelf = (self.mPlayerInfo.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId"))
    -- local qRelation = HeroQimageRelation.items[self.mPlayerInfo.ModelId]
    local positivePic, backPic = QFashionObj:getQFashionLargePic(self.mPlayerInfo.ShiZhuangModelId)
    local effectNames = {positivePic, backPic}
    self.playerSpines = {}
    -- 创建正面和背面的形象
    for _, effectName in ipairs(effectNames) do
        local pSpine = ui.newEffect({
            parent = self,
            anchorPoint = cc.p(0.5, 0.5),
            effectName = effectName,
            loop = true,
            endRelease = true,
            scale = 0.6
        })
        -- pSpine:setVisible(false)
        pSpine:setAnimation(0, "daiji", true)

        table.insert(self.playerSpines, pSpine)
    end
    self.mAnimation = "daiji"

    -- 添加自己进出半透结点的事件
    Notification:registerAutoObserver(self, function (node)
        if not self.mIsSelf then
            self:refreshPlayerOpacity()
        end
    end, {KillerValleyHelper.Events.eInOutNode})

    --血量事件节点
    local tempHpNode = cc.Node:create()
    self:addChild(tempHpNode)

    -- 添加血量改变的事件
    Notification:registerAutoObserver(tempHpNode, function (node, data)
        if data.PlayerId == self.mPlayerInfo.PlayerId then
            self:changeHpBar()
        end
    end, {KillerValleyHelper.Events.eHPChanged})

    --特效事件节点
    local tempEffNode = cc.Node:create()
    self:addChild(tempEffNode)

    -- 添加特效改变的事件
    Notification:registerAutoObserver(tempEffNode, function (node, data) 
        if data.playerId == self.mPlayerInfo.PlayerId then  
            self:playEffect(data.status, data.visible)
        end
    end, {KillerValleyHelper.Events.ePlayerStatus})

    self:createTopView()
end

-- 设置人物的显示位置及透明度变化
function KillerValleyPlayer:setPlayerPosition(pos)
    local oldCollusion = self.mAstarWorld:getPixelCollusion(cc.p(self:getPosition()))
    self:setPosition(pos)
    -- 设置人物的透明度
    local collusion = self:refreshPlayerOpacity()
    -- 通知其它玩家的半透明状态改变
    if self.mIsSelf and oldCollusion ~= collusion then
        KillerValleyHelper:setSelfVisible(collusion == 0)
        Notification:postNotification(KillerValleyHelper.Events.eInOutNode)
    end

    -- 设置zorder，底下的人物先显示
    self:setLocalZOrder(4080 - pos.y)
end

-- 设置人物的透明度变化
function KillerValleyPlayer:refreshPlayerOpacity()
    -- 判断是否使用了隐身衣
    local selfData = KillerValleyHelper:getPlayerData(self.mPlayerInfo.PlayerId)
    local hidingTime = selfData.UseGoodsValidTime and selfData.UseGoodsValidTime["6"]
    local isHiding = hidingTime and hidingTime > 0

    local collusion = self.mAstarWorld:getPixelCollusion(cc.p(self:getPosition()))
    if self.mIsSelf then
        -- 自己仅仅是透明度不同
        for _, pSpine in ipairs(self.playerSpines) do
            pSpine:setOpacity((collusion == 1 or isHiding) and 127 or 255)
        end
    else
        if isHiding then
            -- 如使用隐身衣，则直接不显示
            self:setVisible(false)
        else
            -- 其它玩家
            if KillerValleyHelper.selfVisible then
                -- 自己未隐藏时, 其它玩家隐藏时不可见
                self:setVisible(collusion == 0)
                for _, pSpine in ipairs(self.playerSpines) do
                    pSpine:setOpacity(255)
                end
            else
                -- 自己隐藏时，其它玩家都可见，透明度会变化
                self:setVisible(true)
                for _, pSpine in ipairs(self.playerSpines) do
                    pSpine:setOpacity(collusion == 0 and 255 or 127)
                end
            end
        end
    end
    return collusion
end

-- 设置人物的移动方向(-1表示停止移动)
function KillerValleyPlayer:setRunAngle(angle)
    local faceDirection --判断左右方向
    local isUp          --判断上下方向
    local animation = "daiji"  --动作名

    if angle == -1 then
        if self.mAnimation ~= animation then
            self.playerSpines[1]:setToSetupPose()
            self.playerSpines[1]:setAnimation(0, animation, true)
            self.playerSpines[2]:setToSetupPose()
            self.playerSpines[2]:setAnimation(0, animation, true)
            self.mAnimation = animation 
        end
        return 
    end

    --根据角度以1位单位距离计算下一个点坐标，判断上下左右的方向
    local lastPos = cc.p(self:getPosition())
    local nextPos = cc.p(lastPos.x+math.cos(math.rad(angle))*1, lastPos.y + math.sin(math.rad(angle))*1)
    local offset = cc.pSub(lastPos, nextPos)
    faceDirection = offset.x == 0 and false or offset.x > 0     --没有偏移量默认朝向右
    isUp = offset.y == 0 and false or offset.y > 0              --没有偏移量默认朝向上
    animation = "zou"

    if faceDirection then   --判断左右方向
        self.playerSpines[1]:setRotationSkewY(-180)
        self.playerSpines[2]:setRotationSkewY(-180)
    else
        self.playerSpines[1]:setRotationSkewY(0)
        self.playerSpines[2]:setRotationSkewY(0)  
    end

    if isUp then    --判断上下方向
        self.playerSpines[1]:setVisible(true)
        self.playerSpines[2]:setVisible(false)
    else
        self.playerSpines[1]:setVisible(false)
        self.playerSpines[2]:setVisible(true)
    end

    if self.mAnimation ~= animation then --如果动作改变则重新设置动作
        self.playerSpines[1]:setToSetupPose()
        self.playerSpines[1]:setAnimation(0, animation, true)
        self.playerSpines[2]:setToSetupPose()
        self.playerSpines[2]:setAnimation(0, animation, true)

        self.mAnimation = animation    
    end

end

--创建头顶信息
function KillerValleyPlayer:createTopView()
    --名字
    local nameLabel = ui.newLabel({
        text = self.mPlayerInfo.Name,
        size = 20,
        color = self.mIsSelf and Enums.Color.eGreen or Enums.Color.eRed,
        outlineColor = Enums.Color.eOutlineColor,
        })
    nameLabel:setPosition(0, 165)
    self:addChild(nameLabel)

    -- 创建或刷新血条
    self:changeHpBar()
    -- 后面的按钮其它人不再需要
    if self.mIsSelf then
        return
    end

    --近战按钮
    local fightBtn = ui.newButton({
        normalImage = "c_83.png",
        size = cc.size(80, 60),
        position = cc.p(0, 180),
        clickAction = function()
            if self.mIsSelf == false then
                KillerValleyHelper:fightWithEnemy(self.mPlayerInfo.PlayerId, function ()
                    end)
            end
        end
        })
    self:addChild(fightBtn)

    --可以近战特效
    local fightEff = ui.newEffect({
            parent = fightBtn,
            effectName = "effect_ui_jiaochadao",
            position = cc.p(40, 30),
            scale = 0.5,
            loop = true,
            -- animation = "guangquan",
            endRelease = true,
        })
    self.mFightBtn = fightBtn

    --人物身体按钮
    local checkBtn = ui.newButton({
        normalImage = "c_83.png",
        size = cc.size(60, 120),
        position = cc.p(0, 60),
        clickAction = function()
            LayerManager.addLayer({name = "killervalley.DlgSetCampLayer", data = {playerId = self.mPlayerInfo.PlayerId}, cleanUp = false})
        end
        })
    self:addChild(checkBtn)
    self.mCheckBtn = checkBtn
end

--受伤特效
--参数：1:受伤特效 2：陷阱特效 3：回血特效
function KillerValleyPlayer:playEffect(effType, state)
    if effType == KillerValleyHelper.HeroStatus.eHurt then --受伤特效
        ui.newEffect({
            parent = self,
            -- zorder = 2,
            effectName = "effect_ui_jqg_xue",
            position = cc.p(0, 50),
            animation = "xue_hei",
            -- scale = 1,
            loop = false,
            endRelease = true,
        })
    elseif effType == KillerValleyHelper.HeroStatus.eTrap then --中陷阱掉血特效
        ui.newEffect({
            parent = self,
            -- zorder = 2,
            effectName = "effect_ui_jqg_qinghuaci",
            position = cc.p(0, 0),
            -- scale = 1,
            loop = false,
            endRelease = true,
        })
    elseif effType == KillerValleyHelper.HeroStatus.eBlood then --回血特效
        ui.newEffect({
            parent = self,
            -- zorder = 2,
            effectName = "effect_ui_jqg_huiqidan",
            position = cc.p(0, 0),
            -- scale = 1,
            loop = false,
            animation = "dipan",
            endRelease = true,
        })
        ui.newEffect({
            parent = self,
            -- zorder = 2,
            effectName = "effect_ui_jqg_huiqidan",
            position = cc.p(0, 50),
            -- scale = 1,
            loop = false,
            animation = "shang",
            endRelease = true,
        })
    elseif effType == KillerValleyHelper.HeroStatus.ePoison then --中毒特效
        if state then
            if not self.mEffectList[KillerValleyHelper.HeroStatus.ePoison] then
                local tempEff = ui.newEffect({
                    parent = self,
                    -- zorder = 2,
                    effectName = "effect_ui_jqg_qinghuadu",
                    position = cc.p(0, 50),
                    -- scale = 1,
                    loop = true,
                    endRelease = true,
                })
                self.mEffectList[KillerValleyHelper.HeroStatus.ePoison] = tempEff
            end
        else
            if self.mEffectList[KillerValleyHelper.HeroStatus.ePoison] then
                self.mEffectList[KillerValleyHelper.HeroStatus.ePoison]:removeFromParent()
                self.mEffectList[KillerValleyHelper.HeroStatus.ePoison] = nil
            end
        end
    elseif effType == KillerValleyHelper.HeroStatus.eHiding then --隐身特效
        if state then
            if not self.mEffectList[KillerValleyHelper.HeroStatus.eHiding] then
                local tempEff = ui.newEffect({
                    parent = self,
                    zorder = -1,
                    effectName = "effect_ui_jqg_yexingyi",
                    position = cc.p(0, 40),
                    -- scale = 1,
                    loop = true,
                    endRelease = true,
                })
                self.mEffectList[KillerValleyHelper.HeroStatus.eHiding] = tempEff
            end
        else
            if self.mEffectList[KillerValleyHelper.HeroStatus.eHiding] then
                self.mEffectList[KillerValleyHelper.HeroStatus.eHiding]:removeFromParent()
                self.mEffectList[KillerValleyHelper.HeroStatus.eHiding] = nil
            end
        end
    elseif effType == KillerValleyHelper.HeroStatus.eAttrDouble then --攻防翻倍特效
        if state then
            if not self.mEffectList[KillerValleyHelper.HeroStatus.eAttrDouble] then
                local tempEff = ui.newEffect({
                    parent = self,
                    -- zorder = 2,
                    effectName = "effect_ui_jqg_nuhuo",
                    position = cc.p(0, 0),
                    -- scale = 1,
                    loop = true,
                    endRelease = true,
                })
                self.mEffectList[KillerValleyHelper.HeroStatus.eAttrDouble] = tempEff
            end
        else
            if self.mEffectList[KillerValleyHelper.HeroStatus.eAttrDouble] then
                self.mEffectList[KillerValleyHelper.HeroStatus.eAttrDouble]:removeFromParent()
                self.mEffectList[KillerValleyHelper.HeroStatus.eAttrDouble] = nil
            end
        end
    end
end

--控制攻击按钮是否显示
function KillerValleyPlayer:setFightEff(state)
    if self.mIsSelf then
        return
    end
    self.mFightBtn:setVisible(state)
    if state then
        self.mCheckBtn:setClickAction(function()
            if self.mIsSelf == false then
                KillerValleyHelper:fightWithEnemy(self.mPlayerInfo.PlayerId, function ()
                    end)
            end
        end)
    else
        self.mCheckBtn:setClickAction(function()
            ui.showFlashView(TR("距离目标太远"))
        end)
    end
end

--血条改变
function KillerValleyPlayer:changeHpBar()
    local function createOneHpBar()
        local hpBar = require("common.ProgressBar"):create({
            bgImage = "jqg_45.png",
            barImage = "jqg_13.png",
            barType = ProgressBarType.eVertical,
            currValue = 100,
            maxValue = 100,
            needLabel = false,
        })
        hpBar:setAnchorPoint(cc.p(0.5, 0.5))
        self:addChild(hpBar)
        return hpBar
    end

    self.mHpBarList = self.mHpBarList or {}
    local oldHpBarCount = #self.mHpBarList
    local curHeorNum = 0
    local curHeroHpList = {}
    for i = 1, 6 do --6代表6个阵容位置，排除第7个佣兵位置
        if self.mPlayerInfo.HPs[i] > 0 and self.mPlayerInfo.Formations[i] > 0 then
            curHeorNum = curHeorNum + 1
            -- 保存当前血量百分比
            local curHeroModelId = self.mPlayerInfo.Formations[i]
            local heroMaxHp = KillervalleyHeroModel.items[curHeroModelId].HP
            table.insert(curHeroHpList, self.mPlayerInfo.HPs[i] / heroMaxHp * 100)
        end
    end
    local diffNum = curHeorNum - oldHpBarCount
    if diffNum > 0 then
        -- 添加新增的血条
        for i=1,diffNum do
            table.insert(self.mHpBarList, createOneHpBar())
        end
    elseif diffNum < 0 then
        -- 删除多余的血条
        for i=1,-diffNum do
            self.mHpBarList[1]:removeFromParent()
            table.remove(self.mHpBarList, 1)
        end
    end
    -- 更新血条的位置及数值
    local startPos = nil
    if curHeorNum%2 == 1 then
        startPos = math.floor(curHeorNum/2) * (-30)
    else
        startPos = math.floor(curHeorNum/2) * (-30) + 15
    end
    for i,bar in ipairs(self.mHpBarList) do
        bar:setPosition(startPos + 30*(i-1), 135)
        bar:setCurrValue(curHeroHpList[i])
    end
end

-- 设置持续效果的显示状态
function KillerValleyPlayer:setLongEffStatus(effType, state)
    self.longStatusList = self.longStatusList or {}
    -- 1. 当前为true, 以前为空或false, 需要创建
    -- 2. 当前为false, 以前为true, 需要删除
    if (self.longStatusList[effType] ~= state and state) or
        (self.longStatusList[effType] and not state) then
        self:playEffect(effType, state)
    end
    -- 保存当前状态
    self.longStatusList[effType] = state
end

return KillerValleyPlayer