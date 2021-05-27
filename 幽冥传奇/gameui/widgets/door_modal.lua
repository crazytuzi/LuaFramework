-- 模态激活门
DoorModal = DoorModal or BaseClass()

DoorModal.STATE = {
    NOT_CREATED = 0, -- 未创建
    OPENED = 1, -- 打开的
    CLOSED = 2, -- 关闭的
    OPENING = 3, -- 打开中
}

function DoorModal:__init()
    self.parent_node = nil
    self.click_act_btn_func = nil
    self.is_created = false
    self.is_show = false
    self.door_state = DoorModal.NOT_CREATED
end

function DoorModal:__delete()
    self.click_act_btn_func = nil
    self:Release()
end

-- 释放节点
function DoorModal:Release()
    if nil ~= self.view then
        self.view:removeFromParent()
        self.view = nil
    end

    self.door_state = DoorModal.NOT_CREATED
    self.is_created = false
    self.is_show = false

    self.left_door = nil
    self.right_door = nil
    self.act_btn = nil
    self.parent_node = nil

    self.is_guideing = false
end

-- 创建门的节点
function DoorModal:CreateDoor()
    if self.is_created or nil == self.parent_node then
        return
    end
    self.is_created = true

    self.view = XUI.CreateLayout(598, 400, 936, 680)
    self.parent_node:addChild(self.view, 800)
    self.view:setClippingEnabled(true)
    -- self.view:setTouchEnabled(true)
    local size = self.view:getContentSize()
    self.left_door = XUI.CreateImageView(0, 0, ResPath.GetBigPainting("door_left_img", false))
    self.left_door:setTouchEnabled(true)
    self.left_door:setAnchorPoint(0, 0)
    self.left_door:setIsHittedScale(false)
    self.right_door = XUI.CreateImageView(size.width, 0, ResPath.GetBigPainting("door_right_img", false))
    self.right_door:setTouchEnabled(true)
    self.right_door:setAnchorPoint(1, 0)
    self.right_door:setIsHittedScale(false)
    self.act_btn = XUI.CreateImageView(size.width / 2 + 3, size.height / 2-58, ResPath.GetCommon("btn_act"))
    XUI.AddClickEventListener(self.act_btn, BindTool.Bind(self.OnClickAckBtn, self), true)
    self.view:addChild(self.left_door, 10)
    self.view:addChild(self.right_door, 10)
    self.view:addChild(self.act_btn, 20)

    self:CloseTheDoor() -- 创建好后默认进入关闭状态
end

function DoorModal:FlushArrowGuide(o_x, o_y)
    if self.is_guideing then
        return
    end
    self:FlushArrow(o_x or 0, o_y or 0)
end

function DoorModal:FlushArrow(o_x, o_y)
    if nil == self.view then
        return
    end

    self.is_guideing = true
    self.arrow = "down"
    local arrow_root = cc.Node:create()
    self.view:addChild(arrow_root, 999)
    arrow_root:setPosition(470 + o_x, 360 + o_y)
    local arrow_node = cc.Node:create()
    arrow_root:addChild(arrow_node)
    local arrow_frame = XButton:create(ResPath.GetGuide("arrow_frame"), "", "")
    arrow_frame:setTitleFontSize(25)
    arrow_frame:setTouchEnabled(false)
    arrow_node:addChild(arrow_frame)
    arrow_frame:setTitleFontName(COMMON_CONSTS.FONT)
    local label = arrow_frame:getTitleLabel()
    if label then
        label:setColor(COLOR3B.G_Y)
        label:enableOutline(cc.c4b(0, 0, 0, 100), 1.5)
        label:setString("点击激活")
    end
    local arrow_point = XUI.CreateImageView(0, 0, ResPath.GetGuide("arrow_point"))
    arrow_point:setAnchorPoint(1, 0.5)
    arrow_node:addChild(arrow_point)

    local offset_x = 35
    local rotation, anc_x, anc_y, x, y = -90, 0.5, 1, 0, -offset_x
    local move1, move2 = nil, nil
    if self.arrow == "up" then
        rotation, anc_x, anc_y, x, y = -90, 0.5, 1, 0, -offset_x
        move1 = cc.MoveTo:create(0.5, cc.p(0, -10))
        move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
    elseif self.arrow == "down" then
        rotation, anc_x, anc_y, x, y = 90, 0.5, 0, 0, offset_x
        move1 = cc.MoveTo:create(0.5, cc.p(0, 10))
        move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
    elseif self.arrow == "left" then
        rotation, anc_x, anc_y, x, y = 180, 0, 0.5, offset_x, 0
        move1 = cc.MoveTo:create(0.5, cc.p(10, 0))
        move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
    else
        rotation, anc_x, anc_y, x, y = 0, 1, 0.5, -offset_x, 0
        move1 = cc.MoveTo:create(0.5, cc.p(-10, 0))
        move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
    end

    arrow_point:setRotation(rotation)
    arrow_frame:setAnchorPoint(anc_x, anc_y)
    arrow_frame:setPosition(x, y)
    local action = cc.RepeatForever:create(cc.Sequence:create(move1, move2))
    arrow_node:stopAllActions()
    arrow_node:runAction(action)
end

function DoorModal:GetView()
    return self.view
end

-- 是否显示门，如果门还未创建则创建
function DoorModal:SetVis(vis, parent_node)
    if self.is_show == vis then
        return
    end
    self.is_show = vis
    self.parent_node = parent_node

    if self.is_show and not self.is_created then
        self:CreateDoor()
    else
        self.view:setVisible(self.is_show)
    end

end

-- 关门 无动作
function DoorModal:CloseTheDoor()
    if not self.is_created then
        return
    end
    self.door_state = DoorModal.CLOSED

    local size = self.view:getContentSize()
    self.left_door:stopAllActions()
    self.right_door:stopAllActions()
    self.act_btn:stopAllActions()

    self.left_door:setPosition(0, 0)
    self.right_door:setPosition(size.width, 0)
    self.act_btn:setVisible(true)
end

-- 开门 有动作 并隐藏激活按钮
function DoorModal:OpenTheDoor()
    if not self.is_created then
        return
    end
    self.door_state = DoorModal.OPENING

    local size = self.view:getContentSize()
    self.act_btn:setVisible(false)
    local end_func = cc.CallFunc:create(BindTool.Bind(self.OnDoorOpenEnd, self))
    self.left_door:runAction(cc.MoveTo:create(0.8, cc.p(- size.width / 2, 0)))
    self.right_door:runAction(cc.Sequence:create(cc.MoveTo:create(0.8, cc.p(size.width + size.width / 2, 0)), end_func))

    local size = self.view:getContentSize()
    RenderUnit.PlayEffectOnce(309, self.view, 999, size.width / 2, size.height / 2 + 24, true, nil, FrameTime.Effect * 0.7)
end

function DoorModal:OnDoorOpenEnd()
    self.door_state = DoorModal.OPENED
    self:SetVis(false)
end

function DoorModal:OnClickAckBtn()
    if nil ~= self.click_act_btn_func then
        self.click_act_btn_func()
    end
end

-- 绑定激活按钮点击方法
function DoorModal:BindClickActBtnFunc(func)
    self.click_act_btn_func = func
end

function DoorModal:GetActBtnNode()
    return self.act_btn
end
