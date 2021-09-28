--[[
    文件名：KillerValleyUiHelper.lua
    描述：绝情谷的UI助手，封装一些通用的UI显示
    创建人：peiyaoqiang
    创建时间：2018.1.25
-- ]]
KillerValleyUiHelper = {}


-- 游戏结束退出战场
--[[
    reEnter : 是否重新进入绝情谷首页，默认为false，只在比赛结束的时候才设为true，否则进入绝情谷首页后又会自动进入战场
--]]
function KillerValleyUiHelper:exitGame(reEnter)
    local autoParams = nil
    if (reEnter ~= nil) and (reEnter == true) then
        autoParams = ModuleSub.eKillerValley
    end
    LayerManager.addLayer({
        name = "challenge.ChallengeLayer",
        data = {autoOpenModule = autoParams}
    })
end

----------------------------------------------------------------------------------------------------
-- UI相关的接口

-- 创建道具头像
--[[
params = {
    ModelId = 1,            -- 模型ID，从 KillervalleyGoodsModel 读取配置
    showName = false,       -- 是否显示名字，默认为false
    showSelected = false,   -- 是否显示选中框，默认为false
    onClickCallback = nil,  -- 点击事件，默认弹出查看道具的对话框（暂未实现，后面再做）
}
--]]
function KillerValleyUiHelper:createPropHeader(params)
    local borderImg = "c_08.png"
    local nodeSize = ui.getImageSize(borderImg)
    local retNode = ccui.Layout:create()
    retNode:setIgnoreAnchorPointForPosition(false)
    retNode:setContentSize(nodeSize)

    -- 点击处理
    local defaultCardClick = nil

    -- 设置信息
    retNode.setData = function (target, tmpParams)
        target:removeAllChildren()

        -- 读取参数
        if (tmpParams == nil) or (tmpParams.ModelId == nil) then
            return
        end
        local propModel = KillervalleyGoodsModel.items[tmpParams.ModelId]
        if (propModel == nil) then
            return
        end

        -- 显示边框
        local borderSprite = ui.newSprite(borderImg)
        borderSprite:setPosition(nodeSize.width * 0.5, nodeSize.height * 0.5)
        target:addChild(borderSprite)

        -- 显示道具图
        local propSprite = ui.newSprite(propModel.pic .. ".png")
        propSprite:setPosition(nodeSize.width * 0.5, nodeSize.height * 0.5)
        target:addChild(propSprite)

        -- 显示名字
        if (tmpParams.showName ~= nil) and (tmpParams.showName == true) then
            local nameLabel = ui.newLabel({
                text = propModel.name,
                size = 18,
                color = Utility.getQualityColor(15, 1),
                outlineColor = Enums.Color.eBlack,
                x = nodeSize.width / 2,
                y = -5,
            })
            nameLabel:setAnchorPoint(cc.p(0.5, 1))
            target:addChild(nameLabel)
        end

        -- 点击事件
        defaultCardClick = function ()
            if (tmpParams.onClickCallback ~= nil) then
                tmpParams.onClickCallback(target)
            end
        end
    end
    retNode:setData(params)

    -- 设置选中
    retNode.setSelected = function (target, state)
        if (target.selectSprite == nil) then
            local tempSprite = ui.newSprite("c_31.png")
            tempSprite:setPosition(cc.p(nodeSize.width / 2, nodeSize.height / 2))
            tempSprite:setVisible(false)
            target:addChild(tempSprite, 99)
            target.selectSprite = tempSprite
        end
        if (target.selectState == nil) then
            target.selectState = false
        end
        if (target.selectState ~= state) then
            target.selectState = state
            target.selectSprite:setVisible(state)
        end
    end
    retNode:setSelected(((params.showSelected ~= nil) and (params.showSelected == true)))

    -- 增加点击处理
    local beginPos
    retNode:setTouchEnabled(true)
    retNode:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            beginPos = sender:getTouchBeganPosition()
        elseif eventType == ccui.TouchEventType.ended then
            local endPos = sender:getTouchEndPosition()
            local distance = math.sqrt(math.pow(endPos.x - beginPos.x, 2) + math.pow(endPos.y - beginPos.y, 2))
            if distance < (20 * Adapter.MinScale) then
                if (defaultCardClick ~= nil) then
                    defaultCardClick()
                end
            end
        end
    end)

    return retNode
end

-- 毒圈效果shader
function KillerValleyUiHelper:getCavityCircleShader()
    local cache = cc.GLProgramCache:getInstance()
    local name = "MQ_ShaderCavityCircle"
    local shader = cache:getGLProgram(name)

    if not shader then
        shader = cc.GLProgram:createWithByteArrays(
            -- vertex shader
            [[
                attribute vec4 a_position;
                attribute vec2 a_texCoord;
                attribute vec4 a_color;

                #ifdef GL_ES
                varying lowp vec4 v_fragmentColor;
                varying mediump vec2 v_texCoord;
                #else
                varying vec4 v_fragmentColor;
                varying vec2 v_texCoord;
                #endif

                void main()
                {
                    gl_Position = CC_PMatrix * a_position;
                    v_fragmentColor = a_color;
                    v_texCoord = a_texCoord;
                }
            ]],
            -- fragment shader
            [[
                #ifdef GL_ES
                precision lowp float;
                #endif
                varying vec4 v_fragmentColor;
                varying vec2 v_texCoord;
                uniform vec2 u_centerPos;
                uniform float u_radius;
                uniform float u_annulus;

                void main()
                {
                    float texDis = distance(v_texCoord, u_centerPos);
                    if (u_annulus > 0.001) {
                        // 环形仅显示纯色
                        float half_annulus = u_annulus/2.0;
                        if (texDis >= (u_radius - half_annulus) && texDis <= (u_radius + half_annulus)) {
                            gl_FragColor = v_fragmentColor;
                        }
                        else {
                            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
                        }
                    }
                    else {
                        // 非圆环外围显示图片颜色
                        if (texDis > u_radius) {
                            gl_FragColor = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);  
                        }
                        else {
                            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
                        }
                    }
                }
            ]]
        )
        cache:addGLProgram(shader, name)
    end

    return shader
end

-- 创建毒圈覆盖界面
-- centerPos: 透明中心点(x,y均在0-1范围内)
-- radius: 透明区域半径
-- duration: 动画时间
-- annlus: 圆环宽度, 默认为0
function KillerValleyUiHelper:createCavityCircleSprite(imageName, centerPos, radius, duration, annlus)
    local cavitySprite = ui.newSprite(imageName)
    -- 创建cavity program
    local cavityShader = self:getCavityCircleShader()
    local programState = cc.GLProgramState:create(cavityShader)
    cavitySprite.centerLocation = gl.getUniformLocation(cavityShader:getProgram(), "u_centerPos")
    cavitySprite.radiusLocation = gl.getUniformLocation(cavityShader:getProgram(), "u_radius")
    local annulusLocation = gl.getUniformLocation(cavityShader:getProgram(), "u_annulus")
    programState:setUniformFloat(annulusLocation, annlus or 0)
    cavitySprite:setGLProgramState(programState)

    -- 添加改变半径和中心点的方法
    cavitySprite.setCavity = function (pSender, pos, r)
        local programS = pSender:getGLProgramState()
        programS:setUniformVec2(pSender.centerLocation, cc.p(pos.x, 1 - pos.y))
        programS:setUniformFloat(pSender.radiusLocation, r)
        -- 保存当前的中心点和半径
        pSender.centerPos = pos
        pSender.radius = r
    end
    cavitySprite:setCavity(centerPos, radius * 1.5)

    -- 显示缩小动画
    cavitySprite.actionCavity = function (pSender, pos, r, duration)
        local function deleteActionSheduler(pNode)
            if pNode.poisonShrinkSheduler then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(pNode.poisonShrinkSheduler)
                pNode.poisonShrinkSheduler = nil
            end
        end
        -- 删除定时器事件和node绑定
        pSender:onNodeEvent("cleanup", deleteActionSheduler)
        -- 初始化数据
        deleteActionSheduler(pSender)
        pSender.totalPoisonTime = duration
        pSender.curPosionTime = 0
        pSender.secondPosDis = cc.p((pos.x - pSender.centerPos.x ) / pSender.totalPoisonTime, (pos.y - pSender.centerPos.y ) / pSender.totalPoisonTime)
        pSender.secondRadiusDis = (pSender.radius - r) / pSender.totalPoisonTime
        -- 开启心跳倒计时
        pSender.poisonShrinkSheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
            pSender.curPosionTime = pSender.curPosionTime + dt
            if pSender.curPosionTime > pSender.totalPoisonTime then
                -- 设置最终的毒圈范围
                pSender:setCavity(pos, r)
                -- 删除此定时器
                deleteActionSheduler(pSender)
            else
                -- 设置毒圈每帧范围
                local curCenterPos = cc.p(pSender.centerPos.x + dt * pSender.secondPosDis.x, pSender.centerPos.y + dt * pSender.secondPosDis.y)
                local curCenterRadius = pSender.radius - dt * pSender.secondRadiusDis
                pSender:setCavity(curCenterPos, curCenterRadius)
            end
        end, 0, false)
    end
    cavitySprite:actionCavity(centerPos, radius, duration)
    return cavitySprite
end
----------------------------------------------------------------------------------------------------