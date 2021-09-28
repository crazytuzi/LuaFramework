--[[
    文件名：Guide.TalkView.TalkLayer.lua
    描述：新手引导对话场景配置
    创建人：大杨科
    创建时间：2015.9.30
-- ]]

require("Guide.TalkView.Init")
require("common.SkeletonAnimation")
require("common.MqAudio")
require("common.Utf8")

local DEF = TalkView.DEF

local TalkLayer = class("TalkLayer", function(params)
    return display.newLayer(cc.c4b(22, 70, 0, 0))
end)


--[[
params:
{
    map
    pickedCB(已弃用)     -- function(pickedID, cb) 点击选项后回调
    closedCB            -- function(isSkip)  页面关闭后回调
    closeCurtainCB(已弃用)      -- function(isSkip, model_id)  闭幕时回调
    autoRemove          -- 是否自删除 默认true
    canSkip
    isGuide             -- 是否新手引导
}
--]]
function TalkLayer:ctor(params)
    if LayerManager.changeMusicSwitch then
        LayerManager.changeMusicSwitch(true)
    end

    self.mMapId = params.map
    -- 降低背景音乐音量
    self.originMusicVolume = MqAudio.getMusicVolume()
    if self.originMusicVolume then
        MqAudio.setMusicVolume(self.originMusicVolume * 0.65)
    end

    self:enableNodeEvents()

    -- self:enableNodeEvents()
    params = clone(params)
    self.params = params

    if params.canSkip == nil then
        params.canSkip = true
    end

    ui.registerSwallowTouch({
        node       = self,
        beganEvent = function()
            if next(self.onClickProc_) then
                local data = self.onClickProc_[1]
                table.remove(self.onClickProc_, 1)
                data[2]()
            end

            return true
        end,
    })

    -- 点击响应
    self.clikcProcTag_ = 1
    self.onClickProc_ = {}

    -- 事件监听
    self.action2cb = {}

    -- 初始化界面
    self:createUI(self.params)

    -- 保存model
    self.model = {
        ["__scene__"] = {
            tag = "__scene__",
            node = self.container,
        },
    }

    -- 读取地图数据
    self.actionHead = require("Guide.TalkView.TalkLoader"):load(params.map)

    if self.btnSkip then
        self.btnSkip:setVisible(true)
    end
end


function TalkLayer:pushClickProc(proc)
    table.insert(self.onClickProc_, {self.clikcProcTag_, proc})

    self.clikcProcTag_ = self.clikcProcTag_ + 1
    return self.clikcProcTag_ - 1
end

function TalkLayer:triggerClickProc(tag)
    for k, v in pairs(self.onClickProc_) do
        if v[1] == tag then
            table.remove(self.onClickProc_, k)
            v[2]()
            return true
        end
    end
end

function TalkLayer:removeClickProc(tag)
    for k, v in pairs(self.onClickProc_) do
        if v[1] == tag then
            table.remove(self.onClickProc_, k)
            return true
        end
    end
end


function TalkLayer:onEnterTransitionFinish()
    if not self.mOnEnterTransitionFinished_ then
        self.mOnEnterTransitionFinished_ = true

        -- 执行第一个动作
        self:doStep(self.actionHead)

        if false and AutoFightObj:getAutoFight() then
            local layer = display.newLayer(cc.c4b(0, 0, 0, 120))

            -- 提示文字
            local label = ui.newLabel{
                text = TR(""),
                x    = display.cx,
                y    = display.cy,
                size = 28 * Adapter.MinScale,
            }
            label:setAnchorPoint(cc.p(0.5, 0.5))
            layer:addChild(label)

            local cnt = self.params.autoSkipCount or 5
            layer:runAction(cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.CallFunc:create(function()
                        if cnt == 0 then
                            layer:setVisible(false)
                            self:skip()
                        elseif cnt > 0 then
                            label:setString(string.format(TR("挂机中，%s秒后自动跳过剧情，点击取消"), cnt))
                            label:setAnchorPoint(cc.p(0.5, 0.5))
                            label:setPosition(display.cx, display.cy)
                        else -- 小于0
                            label:setString(TR("正在跳过剧情"))
                        end
                        cnt = cnt -1
                    end),
                    cc.DelayTime:create(1)
                )
            ))

            ui.registerSwallowTouch{
                node       = layer,
                endedEvent = function()
                    layer:stopAllActions()
                    layer:removeFromParent(true)
                end,
            }

            self:addChild(layer, 200)
        end
    end
end


-- 提前创建一些控件
function TalkLayer:createUI(params)
    local container = ccui.Widget:create()
    container:setContentSize(cc.size(DEF.WIDTH, DEF.HEIGHT))
    container:setPosition(display.cx, display.cy)
    container:setScale(Adapter.MinScale)
    self:addChild(container)
    self.container = container

    ------- 左右填充
    local viewSize = self.params.viewSize
    for i = 0, 1 do
        -- local bg = ui.newSprite("c_274.jpg")
        -- bg:setPosition(display.cx + Adapter.MinScale * (viewSize.width / 2 - viewSize.width*i)
        --         , display.cy)
        -- bg:setScale(math.max(Adapter.WidthScale, Adapter.HeightScale))
        -- bg:setAnchorPoint(cc.p(i, 0.5))
        -- bg:setFlippedX(i == 1)
        -- container:addChild(bg)

        -- self["bg" .. tostring(i)] = bg
    end

    if self.params.canSkip then
        -- 跳过剧情按钮
        self.btnSkip = ui.newButton{
            normalImage = "xsyd_04.png",
            -- text        = TR("跳过剧情>>"),
            position    = cc.p(540, DEF.HEIGHT - 165),
            clickAction = function()
                return self:skip()
            end,
        }
        self.container:addChild(self.btnSkip, 255)

        self.btnSkip:setOpacity(150)
        -- 执行动画
        local array = {
            cc.Spawn:create({
                cc.ScaleTo:create(0.6, params.actionScale or 1.1),
                cc.FadeTo:create(0.6, 255)
            }),
            cc.Spawn:create({
                cc.ScaleTo:create(0.6, 1),
                cc.FadeTo:create(0.6, 150)
            }),
        }
        self.btnSkip:runAction(cc.RepeatForever:create(cc.Sequence:create(array)))
    end
end


-- 跳过剧情
function TalkLayer:skip()
    self.btnSkip:setVisible(false)
    self.skipping = true
    self:stopSound()

    local curPtr = self.curPtr
    local function checkEnd()
        if curPtr then
            if curPtr.act_ == "game" then
                Guide.manager:getGift({
                    eventID = curPtr.data_.id * 10 + 1,
                })
            elseif curPtr.act_ == "gift" then
                Guide.manager:getGift({
                    eventID = curPtr.data_.id,
                })
            end

            if curPtr.act_ == "pick" then
                dump(string.format("默认选择[%s]", curPtr.data_[1].text))
                curPtr = curPtr.data_[1].next_
            else
                curPtr = curPtr.next_
            end

            return checkEnd()
        elseif not tolua.isnull(self) then
            return self:onStepEnd(true)
        end
    end
    checkEnd()
end


-- @播放音效
function TalkLayer:playSound(file, sync)
    if sync then
        self:stopSound()
    end

    if file then
        file = Utility.getMusicFile(tonumber(file)) or file

        self.soundID_ = MqAudio.playEffect(file)
        return self.soundID_
    end
end

-- @停止音效
function TalkLayer:stopSound(id)
    local sid = id or self.soundID_

    if not id then
        self.soundID_ = nil
    end

    MqAudio.stopEffect(sid)
end


--------------------------------------------------------------------------------
-- @执行步骤
function TalkLayer:doStep(ptr, force)
    if self.skipping and (not force) then -- 正在跳过
        return
    end

    if not ptr then
        return self:onStepEnd()
    end

    -- action name
    local act = ptr.act_

    -- do action
    local proc_name = "act_" .. act
    local proc = self[proc_name]
    if proc then
        self.curPtr = ptr
        proc(self, ptr)
    else
        dump(string.format("uninstantiated action %s.", act), "error")
        return self:doStep(ptr.next_)
    end
end


-- @所有动作结束时调用
function TalkLayer:onStepEnd(isSkip)
    if LayerManager.changeMusicSwitch then
        LayerManager.changeMusicSwitch(false)
    end
    -- 剧情跳过时，打点
    HttpClient:hitPoint(self.mMapId, isSkip and 1 or 0)

    -- 还原背景音乐音量
    if self.originMusicVolume then
        MqAudio.setMusicVolume(self.originMusicVolume)
    end

    if self.btnSkip then
        self.btnSkip:setVisible(false)
    end

    local cb = self.params.closedCB
    local remove = self.params.autoRemove ~= false
    Utility.performWithDelay(self, function()
        if remove then
            self:removeFromParent()
        end
        return cb and cb(isSkip)
    end, 0)
end


-- @create a model
function TalkLayer:act_model(config)
    local data = config.data_
    local type = data.type

    local sp
    if data.tag then
        sp = self.model[data.tag]
        sp = sp and sp.node
    end

    if not sp then
        if type == DEF.PIC then
            sp = self:createPicModel(config.data_)
        elseif type == DEF.FIGURE then
            sp = self:createFigureModel(config.data_)
        elseif type == DEF.LABEL then
            sp = self:createLabelModel(config.data_, function()
                self:doStep(config.next_)
            end)
        elseif type == DEF.ROLE then
            sp = self:createRoleModel(config.data_)
        elseif type == DEF.BUTTON then
            sp = self:createButtonModel(config.data_)
        elseif type == DEF.LIGHT then
            sp = self:createLightModel(config.data_)
        elseif type == DEF.WINDOW then
            sp = self:createWindowModel(config.data_)
            -- 保存model-window-tag
            self.windowTag_ = config.data_.tag
        elseif type == DEF.CURTAIN then
            sp = self:createCurtainModel(config.data_)
            -- 保存model-curtain-tag
            self.curtainTag_ = config.data_.tag
        elseif type == DEF.CLIPPING then
            sp = self:createClippingModel(config.data_)
        elseif type == DEF.CC then
            sp = self:createCCModel(config.data_)
            if sp.setIgnoreAnchorPointForPosition then
                sp:setIgnoreAnchorPointForPosition(false)
                sp:setAnchorPoint(cc.p(0.5, 0.5))
            end
            if config.data_.size then
                sp:setContentSize(config.data_.size)
            end
        end

        if sp then
            local parent
            if data.parent then
                local info = self.model[data.parent]
                parent = (info and info.node) or self.container
            else
                parent = self.container
            end
            parent:addChild(sp, data.order or 0)

            if data.tag then
                self.model[data.tag] = {
                    node = sp,
                    data = data,
                    type = data.type,
                }
            end

            if data.name then
                self:setProperty(sp, config)

                if not data.tag then
                    self.model['__tmp__'] = {
                        node = sp,
                        data = data,
                        type = data.type,
                    }
                    data.tag = '__tmp__'
                end

                self:createModelName(config)
                return -- 直接返回
            end
        else
            error("failed to create model <" .. data.tag .. ">")
        end
    end

    if sp then
        self:setProperty(sp, config)
    end

    if type ~= DEF.LABEL then
        -- 执行下一个动作
        self:doStep(config.next_)
    end
end

function TalkLayer:setProperty(sp, config)
    if sp then
        -- 设定其他参数
        local data = config.data_
        if data.pos then
            sp:setPosition(data.pos)
        end

        if data.scale then
            sp:setScale(data.scale)
        end

        if data.scaleX then
            sp:setScaleX(data.scaleX)
        end

        if data.scaleY then
            sp:setScaleY(data.scaleY)
        end

        if data.rotation then
            sp:setRotation(data.rotation)
        end

        -- if data.skew then
        --     sp:setRotationSkewY(180)
        -- end

        if data.rotation3D then
            sp:setRotation3D(data.rotation3D)
        end

        if data.opacity then
            sp:setOpacity(data.opacity)
        end

        if data.anchor then
            sp:setAnchorPoint(data.anchor)
        end

        if data.speed then
            SkeletonAnimation.update({
                skeleton = sp,
                speed    = data.speed,
            })
        end
    end
end


-- #创建名字
function TalkLayer:createModelName(config)
    local parent = self.model[config.data_.tag].node
    local parentSize = parent:getContentSize()

    if config.data_.namePos then
        if config.data_.namePos.x > 0 and config.data_.namePos.x < 1
            and config.data_.namePos.x > 0 and config.data_.namePos.x < 1 then

            config.data_.namePos = cc.p(parentSize.width * config.data_.namePos.x
                                    , parentSize.height * config.data_.namePos.y)
        end
    end

    local insert_ = {
        act_  = "model",
        data_ = {
            parent = config.data_.tag,
            type   = DEF.PIC,
            file   = config.data_.nameBg or "jq_27.png",
            pos    = config.data_.namePos,
            order  = config.data_.nameOrder,
            skew   = config.data_.skew,
            scale  = 1 / (config.data_.scale or 1),
        },
        next_ = {
            act_  = "model",
            data_ = {
                parent = config.data_.tag,
                type   = DEF.LABEL,
                text   = config.data_.name,
                pos    = config.data_.namePos,
                order  = config.data_.nameOrder,
                skew   = config.data_.skew,
                rotation3D = config.data_.skew and cc.vec3(0, 180, 0),
                name_  = true,
                size   = (config.data_.nameSize or 22) / (config.data_.scale or 1),
                color  = config.data_.nameColor,
            },
            next_ = config.next_,
        },
    }
    self:doStep(insert_)
end


-- #create model-pic
function TalkLayer:createPicModel(data)
    return cc.Sprite:create(data.file)
end

-- #create model-figure
function TalkLayer:createFigureModel(data)
    local figure = SkeletonAnimation.create({
        file     = data.file,
        zorder   = data.order,
        position = data.pos,
        scale    = data.scale,
    })

    SkeletonAnimation.action({
        skeleton = figure,
        action   = data.animation,
        loop     = data.loop,
    })

    if data.speed then
        SkeletonAnimation.update({
            skeleton = figure,
            speed    = data.speed,
        })
    end

    return figure
end

-- #create model-label
function TalkLayer:createLabelModel(data, cb)
    local label = ui.newLabel({
        text       = data.text,
        position   = data.pos,
        scale      = data.scale,
        size       = data.size,
        color      = data.color,
        align      = cc.TEXT_ALIGNMENT_LEFT,
        -- valign     = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
        dimensions = data.maxWidth and cc.size(data.maxWidth, 0),
    })

    local labelSize = label:getContentSize()
    label:setContentSize(labelSize)
    -- label:setDimensions(labelSize.width, 0)

    label:setString("A")
    local singleLineSize = label:getContentSize()
    label:setString(data.text)


    if data.name_ then
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setPosition(data.pos)
    else
        label:setAnchorPoint(cc.p(0, 1))
        if data.pos then
            label:setPosition(data.pos.x - (labelSize.width / 2), data.pos.y)
            data.pos = nil
        end
    end

    -- 字符串长度
    local len = string.utf8len(data.colorText or data.text)
    local sound = data.sound

    -- 有音效时播放音效，保存ID
    local soundID = sound and self:playSound(sound)

    -- typer 逐字显示效果
    if len > 1 and data.showTime and data.showTime > 0 then
        -- label:setString("")

        local soundFuncTag
        local tag = self:pushClickProc(function()
            if not tolua.isnull(label) then
                label:unscheduleUpdate()
            end

            if soundID then
                self:stopSound(soundID)
            end

            return  data.sync and cb()
        end)

        local duration = 0
        label:scheduleUpdateWithPriorityLua(function(delay)
            duration = duration + delay

            local i = math.floor(duration * len / data.time)
            if i > 0 then
                if i > len and duration > data.showTime then
                    -- 为了i == len时可以显示，延迟删除
                    self:triggerClickProc(tag)
                end
            end
        end, 0)

        if data.sync then
            return label
        end
    end

    if not data.sync then
        label:runAction(cc.Sequence:create(
            cc.DelayTime:create(0),
            cc.CallFunc:create(cb)
        ))
    end

    return label
end

-- #create model-button
function TalkLayer:createButtonModel(data)
    return ui.newButton({
        normalImage = data.file,
        text        = data.text,
        fontSize    = data.fontSize,
        textColor   = data.color,
        clickAudio  = data.clickAudio,
        position    = data.pos,
    })
end

-- #create model-window
function TalkLayer:createWindowModel(data)
    local stencilNode = cc.LayerColor:create(cc.c4b(1, 0, 0, 255))
    stencilNode:setIgnoreAnchorPointForPosition(false)
    stencilNode:setAnchorPoint(0.5, 0.5)
    stencilNode:setPosition(data.pos)
    stencilNode:setContentSize(data.size)

    -- 裁剪节点
    local clipping = cc.ClippingNode:create(stencilNode)
    clipping:setInverted(true) -- 倒置显示，未被裁剪下来的剩余部分
    -- setAlphaThreshold
    clipping:setAnchorPoint(cc.p(0.5, 0.5))
    clipping:setContentSize(cc.size(DEF.WIDTH, DEF.HEIGHT))

    -- 添加黑色层作为边框
    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
    layer:setContentSize(cc.size(DEF.WIDTH, DEF.HEIGHT))
    clipping:addChild(layer)

    data.pos = cc.p(DEF.WIDTH / 2, DEF.HEIGHT / 2)
    return clipping
end

-- #create model-light
function TalkLayer:createLightModel(data)
    local stencilNode =  cc.DrawNode:create()
    stencilNode:setContentSize(data.radius, data.radius)
    stencilNode:setPosition(data.pos)
    stencilNode:drawSolidCircle(cc.p(0, 0), data.radius, 1, 30, cc.c4b(0, 0, 0, 180))

    -- 裁剪节点
    local clipping = cc.ClippingNode:create(stencilNode)
    clipping:setInverted(true) -- 倒置显示，未被裁剪下来的剩余部分
    -- clipping:setAlphaThreshold(0.001)
    clipping:setAnchorPoint(cc.p(0.5, 0.5))
    clipping:setPosition(DEF.WIDTH / 2, DEF.HEIGHT / 2)
    clipping:setContentSize(cc.size(DEF.WIDTH, DEF.HEIGHT))

    -- 添加黑色层作为边框
    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, data.alpha or 200))
    layer:setContentSize(cc.size(DEF.WIDTH, DEF.HEIGHT))
    clipping:addChild(layer)

    data.pos = cc.p(DEF.WIDTH / 2, DEF.HEIGHT / 2)
    return clipping
end

-- #create model-curtain
function TalkLayer:createCurtainModel(data)
    local tmp = {
        pos  = cc.p(DEF.WIDTH / 2, DEF.HEIGHT / 2),
        size = cc.size(DEF.WIDTH, data.height or 0),
    }

    local curtain = self:createWindowModel(tmp)
    if data.height then
        curtain:getStencil():setContentSize(DEF.WIDTH, data.height)
    end

    data.pos = cc.p(DEF.WIDTH / 2, DEF.HEIGHT / 2)
    return curtain
end


-- #create model-role
function TalkLayer:createRoleModel(data)
    local sp = require("map.MapRole").new({
        animationName = type(data.id) == "string" and data.id or nil,
    })

    if data.skew then
        data.skew = nil

        if data.pos then
            sp:getRoleMoveDirection(data.pos, cc.p(data.pos.x + 9999999, data.pos.y - 9999999))
        end
    end

    return sp
end

-- #create clipping node
function TalkLayer:createClippingModel(data)
    local fname = data.file .. ".skel"
    if cc.FileUtils:getInstance():isFileExist(fname) then
        sentil = ui.newEffect({
            effectName = fname,
            animation = data.animation,
        })
    elseif data.file == "" and data.size then
        sentil = cc.LayerColor:create(cc.c3b(100, 100, 0))
        sentil:setIgnoreAnchorPointForPosition(false)
        sentil:setContentSize(data.size)
        sentil:setAnchorPoint(cc.p(0.5, 0.5))
    else
        sentil = cc.Sprite:create(data.file)
    end

    local clip = cc.ClippingNode:create(sentil)
    clip:setAlphaThreshold(0.5)
    return clip
end

-- #create model-cc
function TalkLayer:createCCModel(data)
    -- Todo: 暂时不需要支持
    return data.params and cc[data.class]:create(data.params) or cc[data.class]:create()
end


-- @延时
function TalkLayer:act_delay(config)
    self.container:runAction(cc.Sequence:create(
        cc.DelayTime:create(config.data_.time),
        cc.CallFunc:create(function()
            self:doStep(config.next_)
        end)
    ))
end


-- @执行动作
function TalkLayer:act_action(config)
    local info = self.model[config.data_.tag]
    if info then
        if info.type == DEF.ROLE then
            return self:actionRole(config)
        elseif info.type == DEF.CURTAIN then
            return self:actionCurtain(config)
        elseif info.type == DEF.WINDOW then
            return self:actionWindow(config)
        elseif info.type == DEF.LIGHT then
            return self:actionLight(config)
        elseif config.data_.what then
            -- @执行cocos动作
            self:doCocosAction(config)
        end
    else
        dump(string.format("model was not found <%s>", config.data_.tag))
        self:doStep(config.next_)
    end
end


-- #地图角色动作
function TalkLayer:actionRole(config)
    local data = config.data_
    local info = self.model[data.tag]
    local node = info.node

    if data.pos then
        node:moveRole(data.pos, data.time, function()
            if data.sync then
                self:doStep(config.next_)
            end
        end)

        if not data.sync then
            self:doStep(config.next_)
        end
    else
        self:doStep(config.next_)
    end
end

-- #执行cocos动作
function TalkLayer:doCocosAction(config)
    local data = config.data_
    local info = self.model[data.tag]
    local node = info.node

    local opacity = node:getOpacity()
    local rotation = node:getRotation3D()
    local pos = cc.p(node:getPosition())
    local scaleX = node:getScaleX()
    local scaleY = node:getScaleY()

    local action = next(data.what)

    local create
    create = function(action, params)
        if action == "sequence" then
            local arr = {}
            for k, v in ipairs(params) do
                table.insert(arr, create(next(v), v[next(v)]))
            end
            return cc.Sequence:create(arr)
        elseif action == "spawn" then
            local arr = {}
            for k, v in ipairs(params) do
                table.insert(arr, create(next(v), v[next(v)]))
            end
            return cc.Spawn:create(arr)
        elseif action == "repeat" then
            return cc.Repeat:create(
                create(next(params.action), params.action[next(params.action)])
                , params.time)
        elseif action == "loop" then
            return cc.RepeatForever:create(
                create(next(params), params[next(params)])
            )
        elseif action == "move" then
            if params.to then
                pos = params.to
                return cc.MoveTo:create(params.time, params.to)
            elseif params.by then
                pos.x = pos.x + tonumber(params.by.x)
                pos.y = pos.y + tonumber(params.by.y)
                return cc.MoveBy:create(params.time, params.by)
            end
        elseif action == "scale" then
            if params.to then
                if type(params.to) == "number" or type(params.to) == "string" then
                    params.to = cc.p(tonumber(params.to), tonumber(params.to))
                end
            elseif params.by then
                if type(params.by) == "number" then
                    params.by = cc.p(tonumber(params.by), tonumber(params.by))
                end
            end

            if params.to then
                scaleX = params.to.x
                scaleY = params.to.y
                return cc.ScaleTo:create(params.time, params.to.x, params.to.y)
            elseif params.by then
                scaleX = scaleX * params.by.x
                scaleY = scaleY * params.by.y
                return cc.ScaleBy:create(params.time, params.by.x, params.by.y)
            end
        elseif action == "delay" then
            return cc.DelayTime:create(params.time)
        elseif action == "rotate" then
            if params.to then
                if type(params.to) == "number" then
                    rotation.x = params.to
                elseif type(params.to) == "table" then
                    if params.to.x then
                        rotation.x = params.to.x
                    end
                    if params.to.y then
                        rotation.y = params.to.y
                    end
                    if params.to.z then
                        rotation.z = params.to.z
                    end
                end
                rotation = params.to
                return cc.RotateTo:create(params.time, params.to)
            elseif params.by then
                if type(params.to) == "number" then
                    rotation.x = rotation.x + params.by
                elseif type(params.to) == "table" then
                    if params.to.x then
                        rotation.x = rotation.x + params.by.x
                    end
                    if params.to.y then
                        rotation.y = rotation.y + params.by.y
                    end
                    if params.to.z then
                        rotation.z = rotation.z + params.by.z
                    end
                end
                return cc.RotateBy:create(params.time, params.by)
            end
        elseif action == "fadein" then
            opacity = 255
            return cc.FadeIn:create(params.time)
        elseif action == "fadeout" then
            opacity = 0
            return cc.FadeOut:create(params.time)
        elseif action == "blink" then
            return cc.Blink:create(params.time, params.count)
        elseif action == "jump" then
            if params.to then
                pos = params.to
            elseif params.by then
                pos.x = pos.x + tonumber(params.by.x)
                pos.y = pos.y + tonumber(params.by.y)
            end

            if params.to then
                return cc.JumpTo:create(params.time, params.to, params.height or 100, params.times or 1)
            elseif params.by then
                return cc.JumpBy:create(params.time, params.by, params.height or 100, params.times or 1)
            end
        elseif action == "bezier" then
            if params.to then
                return cc.BezierTo:create(params.time, {
                    params.control[1],
                    params.control[2],
                    params.to,
                })
            elseif params.by then
                return cc.BezierBy:create(params.time, {
                    params.control[1],
                    params.control[2],
                    params.by,
                })
            end
        end
    end

    local actObj = create(action, data.what[action])
    if action == "loop" then
        data.sync = nil
        node:runAction(actObj)
    else
        local tag = self:pushClickProc(function()
            -- if not tolua.isnull(node) then
            --     node:stopAllActions()

            --     node:setScaleX(scaleX)
            --     node:setScaleY(scaleY)
            --     node:setRotation3D(rotation)
            --     node:setOpacity(opacity)
            --     node:setPosition(pos)
            -- end

            -- if data.sync then
            --     Utility.performWithDelay(self, function()
            --         self:doStep(config.next_)
            --     end, 0)
            -- end
        end)

        node:runAction(cc.Sequence:create(
            actObj,
            cc.CallFunc:create(function()
                self:removeClickProc(tag)

                if data.sync then
                    self:doStep(config.next_)
                end
            end)
        ))
    end

    if not data.sync then
        self:doStep(config.next_)
    end
end

-- #幕布动作
function TalkLayer:actionCurtain(config)
    if config.next_ == nil then
        config.data_.sync = true
    end

    local data = {
        tag  = config.data_.tag,
        time = config.data_.time,
        sync = config.data_.sync,
        size = cc.size(DEF.WIDTH, config.data_.height),
    }
    self:actionClippingWindow(data, config.next_)
end

-- #窗口动作
function TalkLayer:actionWindow(config)
    self:actionClippingWindow(config.data_, config.next_)
end

-- #追光灯动作
function TalkLayer:actionLight(config)
    local data = config.data_
    if data.pos then
        local clippingInfo = self.model[data.tag]
        local clippingNode = clippingInfo.node
        -- 裁剪区域结点
        local stencil = clippingNode:getStencil()
        clippingNode:stopAllActions()

        local tag = self:pushClickProc(function()
            if not tolua.isnull(stencil) then
                stencil:setPosition(data.pos)
            end
            self:doStep(config.next_)
        end)
        if data.time and data.time > 0 then
            local action = cc.Sequence:create(
                cc.MoveTo:create(data.time, data.pos),
                cc.CallFunc:create(function()
                    self:triggerClickProc(tag)
                end)
            )
            stencil:runAction(action)
        else
            self:triggerClickProc(tag)
        end
    else
        self:doStep(config.next_)
    end
end

-- #执行幕布和窗口动作
function TalkLayer:actionClippingWindow(data, next)
    local clippingInfo = self.model[data.tag]
    local clippingNode = clippingInfo.node
    -- 裁剪区域结点
    local stencil = clippingNode:getStencil()
    clippingNode:unscheduleUpdate()

    -- 当前状态
    local curSize = stencil:getContentSize()
    local curPos = cc.p(stencil:getPosition())
    local curRotation = stencil:getRotationSkewX()

    -- 最终状态
    local targetSize = data.size
    local targetPos = data.pos
    local targetRotaion = data.rotation

    -- 添加点击响应
    -- local tag = self:pushClickProc(function()
    --     if not tolua.isnull(clippingNode) then
    --         clippingNode:unscheduleUpdate()
    --         if targetSize then
    --             stencil:setContentSize(targetSize)
    --         end
    --         if targetPos then
    --             stencil:setPosition(targetPos)
    --         end
    --         if targetRotaion then
    --             stencil:setRotation(targetRotaion)
    --         end
    --     end
    --     if data.sync then
    --         self:doStep(next)
    --     end
    -- end)

    if data.time and data.time > 0 then
        local offsetWidth, offsetHeight
        if targetSize then
            offsetHeight = targetSize.height - curSize.height
            offsetWidth = targetSize.width - curSize.width
        end

        local offsetY, offsetX
        if targetPos then
            offsetY = targetPos.y - curPos.y
            offsetX = targetPos.x - curPos.x
        end

        local offsetR = targetRotaion and (targetRotaion - curRotation)

        local duration = 0
        clippingNode:scheduleUpdateWithPriorityLua(function(delay)
            duration = duration + delay

            if duration >= data.time then
                clippingNode:unscheduleUpdate()
                if not tolua.isnull(clippingNode) then
                    clippingNode:unscheduleUpdate()
                    if targetSize then
                        stencil:setContentSize(targetSize)
                    end
                    if targetPos then
                        stencil:setPosition(targetPos)
                    end
                    if targetRotaion then
                        stencil:setRotation(targetRotaion)
                    end
                end

                if data.sync then
                    self:doStep(next)
                end
                return
            end

            -- 计算当前状态
            local d = duration / data.time

            if targetSize then
                -- 调整大小
                stencil:setContentSize(curSize.width + d*offsetWidth
                                        , curSize.height + d*offsetHeight)
            end

            if targetPos then
                -- 调整位置
                stencil:setPosition(curPos.x + d * offsetX
                                        , curPos.y + d*offsetY)
            end

            if targetRotaion then
                -- 调整角度
                stencil:setRotation(curRotation + d*offsetR)
            end
        end, 0)
    else
        -- self:triggerClickProc(tag)
    end

    if not data.sync then
        self:doStep(next)
    end
end


-- @删除model
function TalkLayer:act_remove(config)
    if config.data_.model then
        for _, v in pairs(config.data_.model) do
            local info = self.model[v]
            if info and (not tolua.isnull(info.node)) then
                info.node:stopAllActions()
                info.node:unscheduleUpdate()
                info.node:setVisible(false)
                Utility.performWithDelay(info.node, function()
                    info.node:removeFromParent()
                end, 0)
            end
            self.model[v] = nil
        end
    end

    return self:doStep(config.next_)
end


-- @创建多个选项
function TalkLayer:act_pick(config)
    if config.data_ and #config.data_ > 0 then
        local clicked = false
        local action
        for i, v in ipairs(config.data_) do
            local btn = self:createButtonModel(v)
            if i == 1 then
                action = cc.Sequence:create(
                    cc.DelayTime:create(1),
                    cc.CallFunc:create(function()
                        btn:setTitleText(string.format("%s (%d)", v.text, 3))
                    end),
                    cc.DelayTime:create(1),
                    cc.CallFunc:create(function()
                        btn:setTitleText(string.format("%s (%d)", v.text, 2))
                    end),
                    cc.DelayTime:create(1),
                    cc.CallFunc:create(function()
                        btn:setTitleText(string.format("%s (%d)", v.text, 1))
                    end),
                    cc.DelayTime:create(1),
                    cc.CallFunc:create(function()
                        btn:mClickAction()
                    end)
                )
                btn:runAction(action)
            end

            if btn then
                btn:setClickAction(function()
                    if clicked then
                        return
                    end
                    clicked = true
                    if i == 1 then
                        btn:stopAction(action)
                    end
                    -- 执行点击事件
                    self:doStep(v.click)
                end)

                local data = v
                if data.pos then
                    btn:setPosition(data.pos)
                end

                if data.scale then
                    btn:setScale(data.scale)
                end

                if data.rotation then
                    btn:setRotation(data.rotation)
                end

                if data.rotation3D then
                    btn:setRotation3D(data.rotation3D)
                end

                -- if data.skew then
                --     btn:setRotationSkewY(180)
                -- end

                if data.opacity then
                    btn:setOpacity(data.opacity)
                end

                self.container:addChild(btn, data.order or 0)

                if data.tag then
                    self.model[data.tag] = {
                        node = btn,
                        data = data,
                        type = data.type,
                    }
                end
            else
                dump("model was not create.", v.tag)
            end
        end
    else
        return self:doStep(config.next_)
    end
end


-- @播放一段音效
function TalkLayer:act_sound(config)
    local soundID = self:playSound(config.data_.file)
    if soundID and config.data_.sync and config.data_.time then
        local tag = self:pushClickProc(function()
            self:stopSound(soundID)
            self:doStep(config.next_)
        end)

        Utility.performWithDelay(self, function()
            self:triggerClickProc(tag)
        end, config.data_.time)
    else
        return self:doStep(config.next_)
    end
end


-- @切换背景音乐
function TalkLayer:act_music(config)
    MqAudio.playMusic(config.data_.file)
    return self:doStep(config.next_)
end


-- @setColor
function TalkLayer:act_color(config)
    local info = self.model[config.data_.tag]
    if info then
        if not tolua.isnull(info.node) then
            info.node:setColor(config.data_.color)
        end
    else
        dump(string.format("model was not found <%s>", config.data_.tag))
    end
    return self:doStep(config.next_)
end


-- @get gift
function TalkLayer:act_gift(config)
    if config.data_.id then
        Guide.manager:getGift({
            eventID = config.data_.id,
            callback = function()
                self:doStep(config.next_)
            end,
        })
    else
        return self:doStep(config.next_)
    end
end


-- @game
function TalkLayer:act_game(config)
    local data = config.data_
    local id_2_game = {
        [6611] = "smallGame.CarGameLayer",
        [6621] = "smallGame.CarGameLayer",
        [6631] = "smallGame.CarGameLayer",
        [6641] = "smallGame.CarGameLayer",
        [6651] = "smallGame.CarGameLayer",
        [6661] = "smallGame.CarGameLayer",
        [6671] = "smallGame.CarGameLayer",
        [6681] = "smallGame.CarGameLayer",
        [6721] = "smallGame.CarGameLayer",
        [6711] = "smallGame.CarGameLayer",
    }
    local isGame = id_2_game[data.id]
    if isGame then
        local layer
        layer = LayerManager.addLayer({
            name    = "smallGame.GameStartLayer",
            zOrder  = Enums.ZOrderType.eNewbieGuide,
            cleanUp = false,
            data    = {
                gameId   = data.id,
                isGuide  = self.params.isGuide or false,
                callback = function(_, gamelayer, rl)
                    LayerManager.removeLayer(rl)
                    LayerManager.removeLayer(gamelayer)
                    LayerManager.removeLayer(layer)

                    self:doStep(config.next_)
                end,
            },
        })
    else
        dump(string.format("没有找到对应的小游戏:<%s>", data.id))
        self:doStep(config.next_)
    end
end


return TalkLayer
