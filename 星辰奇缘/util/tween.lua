-- -----------------------------------------------------
-- 对外部tween组件根据当前业务需求的二次封装
-- 1.简单暴露需求的接口
-- 2.解耦外部组件和业务逻辑
-- hosr
-- ----------------------------------------------------
--[[
关于 ltDescr 返回值的说明:
1.这是本次缓动的具体信息类
2.可以使用这个返回值，在有需要时做特殊的处理
    比如：ltDescr:setOnStart(func) --设置缓动开始时回调
          ltDescr:setOnCompleteParam(object) --设置完成后回调的参数
          ...其他小量用法查看Leantween.cs里面的LTDescr

=============缓动类型查看============
LeanTweenType{
    notUsed,
    linear,
    easeOutQuad,
    easeInQuad,
    easeInOutQuad,
    easeInCubic,
    easeOutCubic,
    easeInOutCubic,
    easeInQuart,
    easeOutQuart,
    easeInOutQuart,
    easeInQuint,
    easeOutQuint,
    easeInOutQuint,
    easeInSine,
    easeOutSine,
    easeInOutSine,
    easeInExpo,
    easeOutExpo,
    easeInOutExpo,
    easeInCirc,
    easeOutCirc,
    easeInOutCirc,
    easeInBounce,
    easeOutBounce,
    easeInOutBounce,
    easeInBack,
    easeOutBack,
    easeInOutBack,
    easeInElastic,
    easeOutElastic,
    easeInOutElastic,

    --下面几个特殊用法，详情查看LeanTween.cs
    easeSpring,
    easeShake,
    punch,
    once,
    clamp,
    pingPong,
    animationCurve
}
]]--

Tween = Tween or BaseClass()

local LuaLeanTween = LeanTween

function Tween:__init()
    if Tween.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    Tween.Instance = self
    LuaLeanTween.init(600)
end

-- ----------------------------------
-- 取消缓动
-- id = ltDescr.id 创建缓动动作时的返回标识
-- ----------------------------------
function Tween:Cancel(id)
    LuaLeanTween.cancel(id)
end

-- ----------------------------------
-- 暂停缓动
-- id = ltDescr.id 创建缓动动作时的返回标识
-- ----------------------------------
function Tween:Pause(id)
    LuaLeanTween.pause(id)
end

-- ----------------------------------
-- 继续缓动
-- id = ltDescr.id 创建缓动动作时的返回标识
-- ----------------------------------
function Tween:Resume(id)
    LuaLeanTween.resume(id)
end

-- ----------------------------------
-- 查询缓动状态
-- id = ltDescr.id 创建缓动动作时的返回标识
-- ----------------------------------
function Tween:IsTweening(id)
    return LuaLeanTween.isTweening(id)
end

-- -----------------------------------
-- 可选参数的默认设置
-- -----------------------------------
function Tween:SetOptions(descr, easeType, callback)
    easeType = easeType or LeanTweenType.linear
    if descr == nil then
        Log.Info("Tween缓存池用光直接完成")
        callback()
        return
    end
    descr:setEase(easeType)
    if callback ~= nil then
        descr:setOnComplete(callback)
    end
end

-- ----------------------------------
-- 移动缓动 Position
-- object 可传参数类型 gameObject,rectTransform
-- to 目标值
-- time 缓动时长 单位:秒
-- callback 完成回调
-- type 缓动类型   LeanTweenType 具体查看文件开头描述
-- ----------------------------------
function Tween:Move(object, to, time, callback, type)
    local ltDescr = LuaLeanTween.move(object, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

function Tween:MoveSpline(object, to, time, callback, type)
    local ltDescr = LuaLeanTween.moveSpline(object, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

function Tween:MoveX(object, to, time, callback, type)
    local ltDescr = LuaLeanTween.moveX(object, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

function Tween:MoveY(object, to, time, callback, type)
    local ltDescr = LuaLeanTween.moveY(object, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

function Tween:MoveZ(object, to, time, callback, type)
    local ltDescr = LuaLeanTween.moveZ(object, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

-- ----------------------------------
-- 移动缓动 localPosition
-- to 目标值
-- time 缓动时长 单位:秒
-- callback 完成回调
-- type 缓动类型   LeanTweenType 具体查看文件开头描述
-- ----------------------------------
function Tween:MoveLocal(gameObject, to, time, callback, type)
    local ltDescr = LuaLeanTween.moveLocal(gameObject, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

function Tween:MoveSplineLocal(gameObject, to, time, callback, type)
    local ltDescr = LuaLeanTween.moveSplineLocal(gameObject, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

function Tween:MoveLocalX(gameObject, to, time, callback, type)
    local ltDescr = LuaLeanTween.moveLocalX(gameObject, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

function Tween:MoveLocalY(gameObject, to, time, callback, type)
    local ltDescr = LuaLeanTween.moveLocalY(gameObject, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

function Tween:MoveLocalZ(gameObject, to, time, callback, type)
    local ltDescr = LuaLeanTween.moveLocalZ(gameObject, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

-- ------------------------------------
-- 缩放缓动 scale
-- to 目标值
-- time 缓动时长 单位:秒
-- callback 完成回调
-- type 缓动类型   LeanTweenType 具体查看文件开头描述
-- ------------------------------------
function Tween:Scale(object, to, time, callback, type)
    -- object 可传参数类型 gameObject,rectTransform
    -- to -> Vector3
    local ltDescr = LuaLeanTween.scale(object, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

function Tween:ScaleX(gameObject, to, time, callback, type)
    -- to -> number
    local ltDescr = LuaLeanTween.scaleX(gameObject, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

function Tween:ScaleY(gameObject, to, time, callback, type)
    -- to -> number
    local ltDescr = LuaLeanTween.scaleY(gameObject, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

function Tween:ScaleZ(gameObject, to, time, callback, type)
    -- to -> number
    local ltDescr = LuaLeanTween.scaleZ(gameObject, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

-- -------------------------------------
-- 单值变化缓动
-- 无需传人对象，传人变化更新监听回调
-- to 目标值
-- time 缓动时长 单位:秒
-- callback 完成回调
-- type 缓动类型   LeanTweenType 具体查看文件开头描述
-- updateback 值更新回调
-- -------------------------------------
function Tween:ValueChange(from, to, time, callback, type, updateback)
    local ltDescr = LuaLeanTween.value(LuaLeanTween.tweenEmpty, updateback, from, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

-- -----------------------------------
-- 旋转缓动
-- to 目标值
-- time 缓动时长 单位:秒
-- callback 完成回调
-- type 缓动类型   LeanTweenType 具体查看文件开头描述
-- -----------------------------------
function Tween:Rotate(object, to, time, callback, type)
    -- object 可传参数类型 gameObject,rectTransform
    -- object = gameobject; to = Vector3
    -- object = rectTransform; to = number
    local ltDescr = LuaLeanTween.rotate(object, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

function Tween:RotateX(gameObject, to, time, callback, type)
    --to = number
    local ltDescr = LuaLeanTween.rotateX(gameObject, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

function Tween:RotateY(gameObject, to, time, callback, type)
    --to = number
    local ltDescr = LuaLeanTween.rotateY(gameObject, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

function Tween:RotateZ(gameObject, to, time, callback, type)
    --to = number
    local ltDescr = LuaLeanTween.rotateZ(gameObject, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end

-- ----------------------------------------------
-- 透明度缓动
-- object 可传参数类型 gameObject,rectTransform
-- object=gameobject时，取gameobject.rennder进行操作
-- object=rectTransform时，取Image的color
-- to 目标值
-- time 缓动时长 单位:秒
-- callback 完成回调
-- type 缓动类型   LeanTweenType 具体查看文件开头描述
-- ----------------------------------------------
function Tween:Alpha(object, to, time, callback, type)
    local ltDescr = LuaLeanTween.alpha(object, to, time)
    self:SetOptions(ltDescr, type, callback)
    return ltDescr
end