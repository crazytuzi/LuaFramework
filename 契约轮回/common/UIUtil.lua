--
-- Author: LaoY
-- Date: 2018-06-30 16:18:46
--


--[[
	C#导出lua特有方法，使用起来比较习惯
	lua直接获取或者操作Vector3代价很大
--]]

-- @Module Transform
--[[
	@Function SetPosition
	transform:SetPosition(x,y) = transform.localPosition = new UnityEngine.Vector3(x, y, transform.localPosition.z);
	transform:SetPosition(x,y,z) = transform.localPosition = new UnityEngine.Vector3(x, y, z);

	@Function GetPosition()
	@return transform.localPosition = new UnityEngine.Vector3(x, y, z);
--]]


-- @Module GameObject
--[[
	@Function SetPosition
	gameObject:SetPosition(x,y) = gameObject.transform.localPosition = new UnityEngine.Vector3(x, y, gameObject.transform.localPosition.z);
	gameObject:SetPosition(x,y,z) = gameObject.transform.localPosition = new UnityEngine.Vector3(x, y, z);

	@Function GetPosition()
	@return gameObject.transform.localPosition.x,gameObject.transform.localPosition.y,gameObject.transform.localPosition.z
--]]

local LuaEventListener = LuaFramework.LuaEventListener
local LuaClickListener = LuaFramework.LuaClickListener
local LuaValueChangeListener = LuaFramework.LuaValueChangeListener
local LuaButtonListener = LuaFramework.LuaButtonListener
-- local LuaOverClickListener = LuaFramework.LuaOverClickListener
local LuaDragListener = LuaFramework.LuaDragListener

local event_call_back_tab = {}

--[[
	@author LaoY
    @des    按钮点击事件，会放大缩小等
	@param	sound_id  默认会有点击按钮的声音，等于0，不播放声音
    @param  deltaTime 两次点击间隔
	@return number
--]]
function AddButtonEvent(target, call_back, sound_id, scale, deltaTime)
    if target then
        deltaTime = deltaTime or 0.05
        local function call_back_2(...)
            if event_call_back_tab.call_back == call_back and event_call_back_tab.time and Time.time - event_call_back_tab.time < deltaTime then
                return
            end
            event_call_back_tab.call_back = call_back
            event_call_back_tab.time = Time.time

            GlobalEvent:Brocast(GuideEvent.OnClick, ...)
            call_back(...)
            AutoTaskManager:GetInstance():SetLastOperateTime()

            sound_id = sound_id or 7
            if sound_id > 0 then
                SoundManager:GetInstance():PlayById(sound_id)
            end
        end
        -- if use_sound then
        --     LuaButtonListener.Get(target).onClick = call_back_2
        -- else

        --     LuaButtonListener.Get(target).onClick = call_back_2
        -- end
        LuaButtonListener.Get(target).onClick = call_back_2
        if scale then
            LuaButtonListener.Get(target).scale = scale
        end
    end
end

function RemoveButtonEvent(target)
    if target then
        LuaButtonListener.Remove(target)
    end
end

--[[
	@author LaoY
	@des	点击事件，点击没表现反馈
	@param  sound_id  默认会有点击按钮的声音，等于0，不播放声音
    @param  deltaTime 两次点击间隔
	@return number
--]]
function AddClickEvent(target, call_back, sound_id, deltaTime)
    if target then
        deltaTime = deltaTime or 0.2
        local function call_back_2(...)
            if event_call_back_tab.call_back == call_back and event_call_back_tab.time and Time.time - event_call_back_tab.time < deltaTime then
                return
            end
            event_call_back_tab.call_back = call_back
            event_call_back_tab.time = Time.time

            GlobalEvent:Brocast(GuideEvent.OnClick, ...)
            call_back(...)

            AutoTaskManager:GetInstance():SetLastOperateTime()

            sound_id = sound_id or 7
            if sound_id > 0 then
                SoundManager:GetInstance():PlayById(sound_id)
            end
        end
        -- if use_sound then
        --     LuaClickListener.Get(target).onClick = call_back_2
        -- else
        --     LuaClickListener.Get(target).onClick = call_back_2
        -- end
        LuaClickListener.Get(target).onClick = call_back_2
    end
end

function RemoveClickEvent(target)
    if target then
        LuaClickListener.Remove(target)
    end
end

function AddValueChange(target, call_back)
    if target then
        LuaValueChangeListener.AddListener(target, call_back);
    end
end

--手动调用click
function TargetClickCall(target)
    local Listener = LuaClickListener.Get(target, true) or LuaButtonListener.Get(target, true)
    -- local Listener = LuaClickListener.Get(target,true)
    -- if IsNil(Listener) then
    --     Listener = LuaButtonListener.Get(target,true)
    -- end
    Listener:Call()
end

--添加按下事件
function AddDownEvent(target, callback, use_sound)
    if target then
        local function call_back(...)
            callback(...)
            AutoTaskManager:GetInstance():SetLastOperateTime()
        end
        if use_sound then
            local function call_back_2(target, ...)
                EventSystem.Fire(GlobalEventSystem, EventName.PLAY_UI_EFFECT_SOUND, use_sound)
                call_back(target, ...)
            end

            LuaEventListener.Get(target).onDown = call_back_2
        else
            LuaEventListener.Get(target).onDown = call_back
        end
    end
end

function RemoveEvent(target)
    if target then
        LuaEventListener.Remove(target)
    end
end

--添加进入事件
function AddEnterEvent(target, call_back)
    if target then
        LuaEventListener.Get(target).onEnter = call_back
    end
end

--添加离开事件
function AddExitEvent(target, call_back)
    if target then
        LuaEventListener.Get(target).onExit = call_back
    end
end

--添加松开事件
function AddUpEvent(target, call_back)
    if target then
        LuaEventListener.Get(target).onUp = call_back
    end
end

--添加拖拽事件
function AddDragEvent(target, call_back)
    if target then
        local function callback(...)
            call_back(...)
            AutoTaskManager:GetInstance():SetLastOperateTime()
        end
        LuaDragListener.Get(target).onDrag = callback
    end
end

--添加拖拽开始事件
function AddDragBeginEvent(target, call_back)
    if target then
        local function callback(...)
            call_back(...)
            AutoTaskManager:GetInstance():SetLastOperateTime()
        end
        LuaDragListener.Get(target).onDragBegin = callback
    end
end

--添加拖拽结束事件
function AddDragEndEvent(target, call_back)
    if target then
        local function callback(...)
            call_back(...)
            AutoTaskManager:GetInstance():SetLastOperateTime()
        end
        LuaDragListener.Get(target).onDragEnd = callback
    end
end

-- 具体方法在c#还没实现，用到再加
-- function RemoveDragEvent(target)
-- 	if target then
-- 		LuaDragListener.Remove(target) 
-- 	end
-- end

function GetComponentChildByName(transform, name)
    if not CheckErrRef(transform) then
        return UIHelp.GetComponentChildByName(transform, name)
    else
        return nil
    end
end

--设置position位置
--直接操作transform.position 比较慢，放在C#要快40%
--[[
function SetGlobalPosition(transform, x, y, z)
	if not CheckErrRef(transform) then
		-- 以下的三木运算符很慢
		-- x = x or transform.position.x
		-- y = y or transform.position.y
		-- z = z or transform.position.z
		transform.position = Vector3(x, y, z)
	end
end
--]]
function SetGlobalPosition(transform, x, y, z)
    if not CheckErrRef(transform) then
        UIHelp.SetPosition(transform, x, y, z)
    end
end

function SetGlobalPositionX(transform, x)
    if not CheckErrRef(transform) then
        x = x or 0
        UIHelp.SetPositionX(transform, x)
    end
end

function SetGlobalPositionY(transform, y)
    if not CheckErrRef(transform) then
        y = y or 0
        UIHelp.SetPositionY(transform, y)
    end
end

function SetGlobalPositionZ(transform, z)
    if not CheckErrRef(transform) then
        z = z or 0
        UIHelp.SetPositionZ(transform, z)
    end
end

--[[
	@author LaoY
	@des	直接返回 Vector3 效率很慢
	@para1 	transform
	@return x,y,z
--]]
function GetGlobalPosition(transform)
    if CheckErrRef(transform) then
        return
    end
    local x, y, z
    return UIHelp.GetPosition(transform, x, y, z)
end

function GetGlobalPositionX(transform)
    if CheckErrRef(transform) then
        return
    end
    return UIHelp.GetPositionX(transform)
end

function GetGlobalPositionY(transform)
    if CheckErrRef(transform) then
        return
    end
    return UIHelp.GetPositionY(transform)
end

--[[
	@author LaoY
	@des	获取指定父节点的绝对local position
--]]
function GetParentPosition(transform, parent)
    local x, y = GetLocalPosition(transform)
    local _parent = transform.parent
    while (_parent) do
        if parent == _parent then
            break
        end
        local _x, _y = GetLocalPosition(_parent)
        x = x + _x
        y = y + _y
        _parent = _parent.parent
    end
    return x, y
end

function GetGlobalPositionZ(transform)
    return UIHelp.GetPositionZ(transform)
end

--设置localPosition位置
function SetLocalPosition(transform, x, y, z)
    if not CheckErrRef(transform) then
        x = x or 0
        y = y or x
        z = z or x
        UIHelp.SetLocalPosition(transform, x, y, z)
    end
end

--设置localPosition位置
function SetLocalPositionXY(transform, x, y)
    if not CheckErrRef(transform) then
        x = x or 0
        y = y or x
        UIHelp.SetLocalPositionXY(transform, x, y)
    end
end

function SetLocalPositionX(transform, x)
    if not CheckErrRef(transform) then
        x = x or 0
        UIHelp.SetLocalPositionX(transform, x)
    end
end

function SetLocalPositionY(transform, y)
    if not CheckErrRef(transform) then
        y = y or 0
        UIHelp.SetLocalPositionY(transform, y)
    end
end

function SetLocalPositionZ(transform, z)
    if not CheckErrRef(transform) then
        z = z or 0
        UIHelp.SetLocalPositionZ(transform, z)
    end
end

--[[
	@author LaoY
	@des	直接返回 Vector3 效率很慢
	@para1 	transform
	@return x,y,z
--]]
function GetLocalPosition(transform)
    if CheckErrRef(transform) then
        return
    end
    local x, y, z
    return UIHelp.GetLocalPosition(transform, x, y, z)
end

function GetLocalPositionX(transform)
    if CheckErrRef(transform) then
        return
    end
    return UIHelp.GetLocalPositionX(transform)
end

function GetLocalPositionY(transform)
    return UIHelp.GetLocalPositionY(transform)
end

function GetLocalPositionZ(transform)
    return UIHelp.GetLocalPositionZ(transform)
end

function SetAnchoredPosition(transform, x, y)
    if not CheckErrRef(transform) then
        UIHelp.SetAnchoredPosition(transform, x, y)
    end
end

function GetAnchoredPosition(transform)
    if not CheckErrRef(transform) then
        local x, y
        return UIHelp.GetAnchoredPosition(transform, x, y)
    end
end

function SetParent(transform, parent)
    if not CheckErrRef(transform) then
        transform:SetParent(parent);
    end
end


--设置localscale
function SetLocalScale(transform, x, y, z)
    if not CheckErrRef(transform) then
        x = x or 1
        y = y or x
        z = z or x
        UIHelp.SetLocalScale(transform, x, y, z)
    end
end

function GetLocalScale(transform)
    if not CheckErrRef(transform) then
        local x, y, z
        return UIHelp.GetLocalScale(transform, x, y, z)
    end
end

--获取包围盒的大小
function GetRenderBoundsSize(render)
    if render then
        local x, y, z
        return UIHelp.GetRenderBoundsSize(render, x, y, z)
    end
end

--模型大小
function GetObjectSize(transform)
    if not CheckErrRef(transform) then
        local x, y, z
        return UIHelp.GetObjectSize(transform, x, y, z)
    end
end

function SetSkinnedColor(render)
    if render then
        UIHelp.SetSkinnedColor(render)
    end
end

-- 设置localRotation
-- 不设置W，直接设置欧拉角
function SetLocalRotation(transform, x, y, z)
    if not CheckErrRef(transform) then
        x = x or 0
        y = y or x
        z = z or x
        UIHelp.SetLocalRotation(transform, x, y, z)
    end
end

function GetLocalRotation(transform)
    if not CheckErrRef(transform) then
        local x, y, z
        return UIHelp.GetLocalRotation(transform, x, y, z)
    end
end

function SetRotation(transform, x, y, z)
    if not CheckErrRef(transform) then
        x = x or 0
        y = y or 0
        z = z or 0
        return UIHelp.SetRotation(transform, x, y, z)
    end
end

function GetRotation(transform)
    if not CheckErrRef(transform) then
        return UIHelp.GetRotation(transform, nil, nil, nil)
    end
end

--设置rotate
function SetRotate(transform, x, y, z)
    if not CheckErrRef(transform) then
        x = x or 0
        y = y or 0
        z = z or 0
        UIHelp.SetRotate(transform, x, y, z)
    end
end

function SetSizeDelta(transform, x, y)
    if not CheckErrRef(transform) then
        UIHelp.SetSizeDelta(transform, x, y)
    end
end

function SetSizeDeltaX(transform, x)
    if not CheckErrRef(transform) then
        UIHelp.SetSizeDeltaX(transform, x)
    end
end

function SetSizeDeltaY(transform, y)
    if not CheckErrRef(transform) then
        UIHelp.SetSizeDeltaY(transform, y)
    end
end

function GetSizeDeltaX(transform)
    if not CheckErrRef(transform) then
        return UIHelp.GetSizeDeltaX(transform)
    end
end

function GetSizeDeltaY(transform)
    if not CheckErrRef(transform) then
        return UIHelp.GetSizeDeltaY(transform)
    end
end

--[[
	@author LaoY
	@para1 	transform or gameObject
	@para2	layer int
--]]
function SetChildLayer(transform, layer)
    if not CheckErrRef(transform) then
        UIHelp.SetChildLayer(transform, layer)
    end
end

function Translate(transform, x, y, z, speed, time)
    if not CheckErrRef(transform) then
        UIHelp.Translate(transform, x, y, z, speed, time)
    end
end

function SetVisible(transform, flag)
    flag = toBool(flag);
    if not CheckErrRef(transform) then
        transform.gameObject:SetActive(flag)
    end
end

function SetAsLastSibling(transform)
    if not CheckErrRef(transform) then
        transform.transform:SetAsLastSibling()
    end
end

function SetAsFirstSibling(transform)
    if not CheckErrRef(transform) then
        transform.transform:SetAsFirstSibling()
    end
end


--[[
	@author LaoY
	@des	设置特效播放速度
	@param1 gameObject
	@param2 speed number
--]]
function SetParticleSpeed(gameObject, speed)
    if not CheckErrRef(gameObject) then
        UIHelp.SetParticleSpeed(gameObject, speed)
    end
end

--[[
	@author LaoY
	@des	设置特效是否循环
	@param1 gameObject
	@param2 falg bool
--]]
function SetParticleLoop(gameObject, falg)
    if not CheckErrRef(gameObject) then
        UIHelp.SetParticleLoop(gameObject, falg)
    end
end

--[[
	@author LaoY
	@des	返回特效的状态，int效率高;这个需要每帧触发，选择用int交互
	@param1 gameObject
	@return 
			true  播放完
			fasle 正在播放
--]]
function GetParticlePlayState(gameObject)
    if not CheckErrRef(gameObject) then
        --0播放完&& 1正在播放
        local state = UIHelp.GetParticlePlayState(gameObject)
        return state ~= 1
    end
end

--[[
	@author LaoY
	@des	返回特效的时间长度
	@param1 gameObject or transform
	@return tiem number
--]]
function GetParticleSystemLength(gameObject)
    if not CheckErrRef(gameObject) then
        return UIHelp.GetParticleSystemLength(gameObject)
    end
end

--[[
	@author LaoY
	@des	特效播放
	@param1 gameObject
	@param2 flag 		true播放；false停止
--]]
function PlayParticle(gameObject, flag)
    if not CheckErrRef(gameObject) then
        return UIHelp.PlayParticle(gameObject, flag)
    end
end

--[[
	@author LaoY
	@des	设置文字、图片颜色
	@param1 transform
	@param2 r 0~255
	@param3 g 0~255
	@param4 b 0~255
	@param4 a 0~255 可以不填
--]]
function SetColor(transform, r, g, b, a)
    if not CheckErrRef(transform) then
        UIHelp.SetColor(transform, r, g, b, a or 255)
    end
end

--[[
	@des	设置Shader Key的颜色
	@param1 transform
	@param2 key Shader_Key
	@param3 r 0~255
	@param4 g 0~255
	@param5 b 0~255
	@param6 a 0~255 可以不填
--]]
function SetMaterialColor(material, key, r, g, b, a)
    if (material) then
        UIHelp.SetMaterialColor(material, key, r, g, b, a or 255)
    end
end

--[[
	@des	设置Shader Key的Float值
	@param1 transform
	@param2 key Shader_Key
	@param3 v float
--]]
function SetMaterialFloat(material, key, v)
    if (material) then
        UIHelp.SetMaterialFloat(material, key, v)
    end
end

--[[
	@author LaoY
	@des	设置文字描边颜色
	@param1 transform
	@param2 r 0~255
	@param3 g 0~255
	@param4 b 0~255
	@param4 a 0~255 可以不填
--]]
function SetOutLineColor(transform, r, g, b, a)
    if not CheckErrRef(transform) then
        UIHelp.SetOutLineColor(transform, r, g, b, a or 255)
    end
end

--[[
	@author LaoY
	@des	获取透明度 目前只有image text有
	@param1 param1
	@return number
--]]
function GetAlpha(transform)
    if not CheckErrRef(transform) then
        return UIHelp.GetAlpha(transform)
    end
end

--[[
	@author LaoY
	@des	设置透明度 目前只有image text有
	@param1 param1
	@return number
--]]
function SetAlpha(transform, a)
    if not CheckErrRef(transform) then
        UIHelp.SetAlpha(transform, a)
    end
end



--[[
	@author LaoY
	@des	获取动作时间（裁剪、融合的时间也能正确获取）
	@param1 animator
	@param1 action_name
	@return number
--]]
function GetClipLength(animator, action_name)
    if animator then
        return UIHelp.GetClipLength(animator, action_name)
    end
end

--UI便捷操作部份
--设置GameObject Active
function SetGameObjectActive(obj, bool)
    if not CheckErrRef(obj) then
        bool = toBool(bool)
        obj.gameObject:SetActive(bool)
    end
end
--传入的btn参数需要是一个按钮
function SetButtonEnable(btn, enable)
    local img = GetImage(btn);
    enable = toBool(enable)
    if img then
        btn.enabled = enable;--由于是AddClickListener.所以这句没用,要手动去除事件
        if enable then
            ShaderManager:GetInstance():SetImageNormal(img);
        else
            ShaderManager:GetInstance():SetImageGray(img);
        end

    end
end

function CheckErrRef(gameObject)
    if not gameObject then
        print('--CheckErrRef gameObject is nil--')
        traceback()
        return true
    end

    --[[
    if isClass(gameObject) then
        -- if AppConfig then
        --     logError("type of gameObject is error,is a class,must be userdata")
        -- end
        return gameObject.is_dctored
    end
    if IsNil(gameObject) then
        -- logError("[error_ref] CheckErrRef gameObject c# is nil")
        return true
    end
    --]]
    return false
end

function GetText(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("Text");
end

function GetAndSetText(component)
    if not component then
        return nil
    end
    component = component.gameObject:GetComponent("Text")
    return component;
end

function GetToggle(gameObject)
    if CheckErrRef(gameObject) then
        logError("GetAndSetText is nil")
        return nil
    end
    return gameObject.gameObject:GetComponent("Toggle");
end

function GetToggleGroup(gameObject)
    if CheckErrRef(gameObject) then
        logError("GetToggleGroup gameObject is nil")
        return nil
    end
    return gameObject.gameObject:GetComponent("ToggleGroup");
end

function GetInputField(gameObject)
    if CheckErrRef(gameObject) then
        logError("GetInputField gameObject is nil")
        return nil
    end
    return gameObject.gameObject:GetComponent("InputField");
end

function GetButton(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("Button");
end

function GetSlider(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("Slider");
end

function GetScrollbar(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("Scrollbar");
end

function GetImage(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("Image");
end

function GetRawImage(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("RawImage");
end

function GetSprite(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("Sprite");
end

function GetScrollRect(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("ScrollRect");
end

function GetDropDown(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("Dropdown");
end

function GetRectTransform(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("RectTransform")
end

function GetLinkText(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("LinkImageText")
end

function GetCamera(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("Camera")
end

function GetCanvasGroup(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("CanvasGroup")
end

function GetGridLayoutGroup(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("GridLayoutGroup")
end

function GetOutLine(gameObject)
    if CheckErrRef(gameObject) then
        return nil
    end
    return gameObject.gameObject:GetComponent("Outline");
end

--给UI加一个半透黑色背景层
function AddBgMask(gameObject, r, g, b, a)
    local go = GameObject("mask_bg");
    local image = go:AddComponent(typeof(UnityEngine.UI.Image));--UnityEngine.UI.Image

    go.transform:SetParent(gameObject.transform);
    SetLocalScale(go.transform, 100, 100, 1);
    SetLocalPosition(go.transform, 0, 0, 0);
    SetColor(image, r or 20, g or 20, b or 20, a or 100);
    image.transform:SetAsFirstSibling();
    return image;
end

function GetChild(transform, childName)
    if not CheckErrRef(transform) then
        return transform.transform:Find(childName);
    end
end

--[[
    @author LaoY
    @des    html颜色字符串转化成rgba值
    @param1 colorStr  "#ffffff"
    一定要确认字符串有#号开始,不然转不了
--]]
function HtmlColorStringToColor(colorStr)
    if colorStr and not colorStr:find("#") then
        colorStr = "#" .. colorStr
    end
    local r, g, b, a
    r, g, b, a = UIHelp.HtmlColorStringToColor(colorStr, r, g, b, a)
    return r, g, b, a
end

--[[
    @author LaoY
    @des    rgba值转化成html颜色字符串
    @return string  "#ffffff"
--]]
function ColorToHtmlColorString(r, g, b, a)
    return UIHelp.ColorToHtmlColorString(r, g, b, a)
end

function SetHorizontalLayoutGroupSpacing(transform, spacing)
    if not CheckErrRef(transform) then
        UIHelp.SetHorizontalLayoutGroupSpacing(transform, spacing)
    end
end

-- 设置变灰
function SetGray(transform, flag, StencilId, StencilType)
    if flag then
        ShaderManager:GetInstance():SetImageGray(transform, StencilId, StencilType)
        print("变灰")
    else
        ShaderManager:GetInstance():SetImageNormal(transform)
        print("变灰还原")
    end
end


--              if (abName.Equals(AppConst.StreamingAssets))
--             {
--                 return abName;
--             }

--             abName = abName.ToLower();
--             if (!abName.EndsWith(AppConst.ExtName))
--             {
--                 abName += AppConst.ExtName;
--             }

--             if (abName.Contains(AppConst.MapAssetDir))
--                 return abName;
--             if (!abName.Contains(AppConst.AssetDir))
--                 abName = AppConst.AssetDir + abName;
--             return abName;

function GetRealAssetPath(abName)
    if not abName then
        return
    end
    abName = abName:lower(abName)
    if not abName:find(AssetsBundleExtName) then
        abName = abName .. AssetsBundleExtName
    end
    if abName:find("mapasset/") then
        return abName
    end
    if not abName:find("asset/") then
        abName = "asset/" .. abName
    end
    return abName
    -- return resMgr:GetRealAssetPath(abName)
end

local Stencil = {}
Stencil.id = 10
function Stencil:GetId()
    Stencil.id = Stencil.id + 1

    return Stencil.id
end

---新的镂空Id
function GetFreeStencilId()
    return Stencil:GetId()
end

---添加Stencil Mask
function AddRectMask3D(gameObject)
    local mask = gameObject.gameObject:GetComponent("Mask")
    if (mask) then
        destroy(mask)
    end

    local shader = ShaderManager.GetInstance():GetShaderByName(ShaderManager.ShaderNameList.Stencil_Mask)
    mask = gameObject.gameObject:AddComponent(typeof(RectMask3DForStencil))
    mask:SetMaterial(shader)
    if not PlatformManager:GetInstance():IsMobile() then
        local go = gameObject.transform:Find("Mask3D")
        go:GetComponent("MeshRenderer").material.shader = ShaderManager.GetInstance():GetShaderByName(ShaderManager.ShaderNameList.Default)
        go:GetComponent("MeshRenderer").material.shader = Shader.Find("Unlit/StencilMask")
    end
    return mask
end


--[[
    @author LaoY
    @des    返回父节点（溯源找到带canvas为父节点）
    @param1 gameObject
    @return transform,index
--]]
function GetParentOrderIndex(gameObject)
    local transform
    local index
    return UIDepth.GetParentOrderIndex(gameObject,transform,index)
end

function SetOrderIndex(gameObject,is_ui,index)
    if not CheckErrRef(gameObject) then
        UIDepth.SetOrderIndex(gameObject,is_ui,index)
    end
end

function SetCacheState(gameObject,cacheState)
    if not CheckErrRef(gameObject) then
        if AppConfig.engineVersion >=5 then
            local animator_flag = SetAnimatorActive(gameObject,not cacheState)
            local animation_flag = SetAnimationActive(gameObject,not cacheState)
            -- return UIHelp.SetCacheState(gameObject,cacheState)
            return animator_flag or animation_flag
        else
            return SetAnimationActive(gameObject,not cacheState) or
            SetAnimatorActive(gameObject,not cacheState)
        end
    end
end

function SetAnimationActive(gameObject,active)
    if not CheckErrRef(gameObject) then
        if AppConfig.engineVersion >=5 then
            return UIHelp.SetAnimationActive(gameObject,active)
        else

        end
    end
    return false
end

function SetAnimatorActive(gameObject,active)
    if not CheckErrRef(gameObject) then
        if AppConfig.engineVersion >=5 then
            return UIHelp.SetAnimatorActive(gameObject,active)
        else

        end
    end
    return false
end

function CreateRenderTexture()
    return RenderTexture.GetTemporary(Constant.RT.RtWidth, Constant.RT.RtHeight, Constant.RT.RtDepth)
end

function ReleseRenderTexture(rt)
    RenderTexture.ReleaseTemporary(rt)
    rt = nil
end