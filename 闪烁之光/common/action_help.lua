-- 部分动作工具类
-- author:cloud
ActionHelp = ActionHelp or {}


--移动操作
--move_node:操作节点
--size：节点尺寸
--pos_old--运动前位置
--pos_new--运动后位置
--time--运动时间
function ActionHelp.MoveAction(move_node,size,pos,time,call_back)
    if tolua.isnull(move_node) then return end
    -- if not move_node then return end
    local fun = function ()  
    end
    if not call_back then
        call_back = fun
    end
    size = size or cc.size(0,0)
    pos = pos or cc.p(0,0)
    pos_new = pos_new or cc.p(0,0)
    time = time or 0.1
    local act_move = cc.MoveTo:create(time,pos)
    local act_move1 = cc.MoveTo:create(0.1,cc.p(pos.x,pos.y+5))
    local act_move2 = cc.MoveTo:create(0.1,pos)
    move_node:runAction(cc.Sequence:create(act_move,act_move1,act_move2, cc.CallFunc:create(call_back)))
end

--放大缩小
function ActionHelp.ScaleAction(scale_node,call_back)
    if tolua.isnull(move_node) then return end
    -- if not scale_node then return end
    local fun = function ()  
    end
    if not call_back then
        call_back = fun
    end
    local action1 = cc.ScaleTo:create(0.2, 1.1)
    local action2 = cc.ScaleTo:create(0.2, 1)
    scale_node:runAction(cc.Sequence:create(action1,action2, cc.CallFunc:create(call_back)))
end

--==============================--
--desc:Item scrollview动画
--time:2020-03-17 06:46:35
--@obj:节点
--@move_x:偏移X坐标
--@move_y:偏移Y坐标
--@time:移动时间
--@return 
--==============================--
function ActionHelp.itemUpAction(obj, move_x, move_y, time)
    if obj == nil or tolua.isnull(obj) then return end
    move_x = move_x or 400
    move_y = move_y or 0
    time = time or 0.2
    local pos_x, pos_y = obj:getPosition()
    obj:setOpacity(0)
    obj:setPosition(pos_x - move_x, pos_y - move_y)
    local act_move = cc.EaseBackOut:create(cc.MoveBy:create(time,cc.p(move_x, move_y)))
    local fadeIn = cc.FadeIn:create(time - 0.05)
    obj:runAction(cc.Spawn:create(act_move, fadeIn))
end

--==============================--
--desc:Item scrollview动画
--time:2020-03-17 06:46:35
--@obj:节点
--@sscale:开始缩放
--@escale:结束缩放
--@time:移动时间
--@return 
--==============================--
function ActionHelp.itemScaleAction(obj, sscale, escale, time)
    if obj == nil or tolua.isnull(obj) then return end
    sscale = sscale or 0.3
    escale = escale or 1
    time = time or 0.3
    obj:setOpacity(0)
    obj:setScale(sscale)
    local fadeIn = cc.FadeIn:create(time - 0.1)
    local act_move = cc.EaseBackOut:create(cc.ScaleTo:create(time,escale))
    local spawn_action = cc.Spawn:create(act_move, fadeIn)
    obj:runAction(spawn_action)
end

--==============================--
--desc:Item scrollview动画
--time:2020-03-17 06:46:35
--@obj:节点
--@sOpacity:开始透明度
--@time:移动时间
--@return 
--==============================--
function ActionHelp.itemOpacityAction(obj, sOpacity, time)
    if obj == nil or tolua.isnull(obj) then return end
    sOpacity = sOpacity or 0
    time = time or 0.3
    obj:setOpacity(sOpacity)
    local fadeIn = cc.FadeIn:create(time)
    local spawn_action = cc.Spawn:create(fadeIn)
    obj:runAction(spawn_action)
end