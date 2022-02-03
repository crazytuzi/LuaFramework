__spine_list = {}
__down_spine_list = {}
spSkeletonAnimationCreate = function(js_path, atlas_path, pixelformal)
    pixelformal = pixelformal or cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444
    -- 跑新手时候统计加载资源
    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" or PLATFORM_NAME == "release2" then 
        local args = Split(js_path, "/")
        if __down_spine_list[args[2]] == nil then
            __down_spine_list[args[2]] = args[2]
        end
    end

    if not js_path or not atlas_path or js_path == "" or atlas_path == "" 
            or not PathTool.isFileExist(js_path)
            or not PathTool.isFileExist(atlas_path) then 
        js_path, atlas_path = PathTool.defaultSpine()
    end
    local spine__ = nil
    if string.find(js_path, ".skel") ~= nil then
        spine__ = sp.SkeletonAnimation:createBinary(js_path, atlas_path, 1, pixelformal)
    else
        spine__ = sp.SkeletonAnimation:create(js_path, atlas_path, 1, pixelformal)-- setTimeScale
    end
    return spine__
end


--==============================--
--desc:创建模型,这里主要是模型类的.H打头的
--time:2018-07-22 10:44:11
--@spine_name:模型id,对应文件夹名字
--@action_name:动作id,对应资源名
--@root:
--@zorder:
--@scale:
--@pixelformal:使用的纹理格式
--@return 
--==============================--
function createSpineByName(spine_name, action_name, root, zorder, scale, pixelformal)
    spine_name = spine_name or "H99999"
    local frist_letter = string.sub(spine_name, 1, 1)
    if frist_letter == "H" and pixelformal == nil then
        pixelformal = getPixelFormat(spine_name)     
    end
    local js_path, atlas_path, png_path = PathTool.getSpineByName(spine_name, action_name)
    local armature = spSkeletonAnimationCreate(js_path, atlas_path, pixelformal)
    if not tolua.isnull(root) then
         root:addChild(armature, zorder or 0)
    end
    if scale and type(scale) == "number" then
    	armature:setScale(scale)
	end
	return armature
end


--==============================--
--desc:创建特效
--time:2018-01-04 03:01:57
--@effectName:
--@pos:
--@arPos:
--@loop:
--@action:
--@call_back:
--@pixelformal:外部设置不用,直接在内部充足
--@not_play_action: 是否播放动作,只要有值,就不播放动作了
--@return 
--==============================--
function createEffectSpine( effectName, pos, arPos, loop, action, call_back, pixelformal, not_play_action )
    if loop == nil then loop = true end
    effectName = effectName  or "E88888"
    local skel_path, atlas_path, png_path, spine_path, return_name = PathTool.getSpineByName(effectName)
    if pixelformal == nil then
        pixelformal = getPixelFormat(effectName)
    end
    local spine = spSkeletonAnimationCreate(skel_path, atlas_path, pixelformal)
    spine:setPosition(pos or cc.p(0, 0))
    action = action or PlayerAction.action
    if not_play_action == nil then
        spine:setAnimation(0, action, loop)
    end
    spine:setAnchorPoint(arPos or cc.p(0.5, 0.5))
    if call_back then
        spine:registerSpineEventHandler(call_back, sp.EventType.ANIMATION_COMPLETE)
    end
    return spine
end

--==============================--
--desc:创建富文本
--time:2018-07-22 10:45:14
--@fontsize:
--@textcolor:
--@ap:
--@pos:
--@lineSpace:
--@charSpace:
--@max_width:
--@return 
--==============================--
function createRichLabel(fontsize, textcolor, ap, pos, lineSpace, charSpace, max_width)
    local RichLabel = require("common.richlabel.RichLabel")
    if type(textcolor) == "number" then
        textcolor = Config.ColorData.data_color3[textcolor]
    end
    -- 文字信息
    local rich_label = RichLabel.new {
        fontName = DEFAULT_FONT,
        fontSize = fontsize,
        fontColor = textcolor or cc.c3b(255, 255, 255),
        maxWidth = max_width or 300,
        lineSpace = lineSpace or 0,
        charSpace = charSpace or 0,
        anchorPoint = ap or cc.p(0, 0)
    }
    rich_label:setAnchorPoint(ap or cc.p(0, 0))
    rich_label:setPosition(pos or cc.p(0, 0))
    return rich_label
end

--==============================--
--desc:创建csb节点
--time:2018-07-22 10:45:30
--@csb_name:
--@return 
--==============================--
function createCSBNote(csb_name)
    -- cc.CSLoader:setCsbPlistFlag(true)
    local node = cc.CSLoader:createNode(csb_name)
    -- cc.CSLoader:setCsbPlistFlag(false)
    return node
end

--==============================--
--desc:创建系统文字
--time:2018-07-22 10:45:43
--@word:
--@args:
--@return 
--==============================--
function createWithSystemFont(word, ...)
    word = word or ""
    return cc.Label:createWithTTF(word, ...)
end

--==============================--
--desc:创建一个普通文本
--time:2018-07-22 10:46:03
--@font_size:
--@text_color:
--@line_color:
--@x:
--@y:
--@text_content:
--@parent_wnd:
--@line_num:
--@anchorpoint:
--@font:
--@return 
--==============================--
function createLabel(font_size,text_color,line_color,x,y,text_content,parent_wnd,line_num, anchorpoint,font)
    font_size = font_size
    local label = createWithSystemFont("",  font or DEFAULT_FONT , font_size)
    if type(text_color) == "number" then
        text_color = Config.ColorData.data_color4[text_color]
    end
    label:setTextColor(text_color or Config.ColorData.data_color4[1])
    label:setAnchorPoint(anchorpoint or cc.p(0,0))
    if line_color then
        if type(line_color) == "number" then
            line_color = Config.ColorData.data_color4[line_color]
        end
        label:enableOutline(line_color, line_num or 1)
    end
    if x and y then
        label:setPosition(cc.p(x, y))
    end
    if text_content then
        label:setString(text_content)
    end
    if not tolua.isnull(parent_wnd) then
        parent_wnd:addChild(label)
    end
    return label
end

--==============================--
--desc:创建自定义按钮
--time:2018-07-22 10:46:22
--@conatiner:
--@label:
--@x:
--@y:
--@size:
--@normal_res:普通状态资源
--@fontsize:
--@label_color:
--@press_res:
--@disable_res:
--@load_type:
--@return 
--==============================--
function createButton(conatiner, label, x, y, size, normal_res, fontsize, label_color, press_res, disable_res, load_type,font_type)
    label = label or ""
    load_type = load_type or LOADTEXT_TYPE_PLIST
    local btn = CustomButton.New(conatiner, normal_res, press_res, disable_res, load_type,font_type)
    if fontsize == nil then
        btn:setLabelSize(30)
    else
        btn:setLabelSize(fontsize)
    end
    label_color = label_color or Config.ColorData.data_color4[1]
    btn:setBtnLableColor(label_color)
    btn:setBtnLabel(label,font_type)
    btn:setOffsetPos(2, 2)
    x = x or 0
    y = y or 0
    btn:setPosition(cc.p(x, y))
    if size ~= nil then
        btn:setSize(size)
    end
    return btn
end

--==============================--
--desc:创建image
--time:2018-07-22 10:46:58
--@parent:
--@res:
--@x:
--@y:
--@anchorPoint:
--@usePlist:
--@zorder:
--@is_Scale9:
--@return 
--==============================--
function createImage(parent, res, x, y, anchorPoint, usePlist, zorder, is_Scale9)
    local image = ccui.ImageView:create()
    if res ~= nil then
        if usePlist == true then
            image:loadTexture(res, LOADTEXT_TYPE_PLIST)
        else
            image:loadTexture(res,LOADTEXT_TYPE)
        end
    end
    if anchorPoint == nil then
        image:setAnchorPoint(cc.p(0.5, 0.5))
    else
        image:setAnchorPoint(anchorPoint)
    end

    if is_Scale9 == true then
        image:setScale9Enabled(true)
    end

    if x ~= nil and y ~= nil then
        image:setPosition(cc.p(x , y))
    end
    if not tolua.isnull(parent) then
        parent:addChild(image, zorder or 0)
    end
    return image
end

--==============================--
--desc:创建一张九宫格资源
--time:2018-07-22 10:47:13
--@res:
--@x:
--@y:
--@type:
--@parent:
--@return 
--==============================--
function createScale9Sprite(res, x, y, type, parent)
    type = type or LOADTEXT_TYPE_PLIST
    local sprite = ccui.Scale9Sprite:create()
    if res ~= nil then
        loadScale9SpriteTexture(sprite, res, type)
    end

    if x ~= nil and y ~= nil then
        sprite:setPosition(cc.p(x, y))
    end
    if not tolua.isnull(parent) then
        parent:addChild(sprite)
    end
    return sprite
end



--==============================--
--desc:创建一个精灵单位
--time:2017-05-31 10:55:18
--@res:
--@x:
--@y:
--@container:
--@anchorPoint:
--@type:
--@zorder:
--return 
--==============================--
function createSprite(res, x, y, container, anchorPoint, type, zorder)
    x = x or 0
    y = y or 0
    type = type or LOADTEXT_TYPE_PLIST
    local sprite = cc.Sprite:create()
    if res ~= nil and res ~= "" then
        loadSpriteTexture(sprite, res, type)
    end
    sprite:setPosition(cc.p(x, y))
    if not tolua.isnull(container) then
        container:addChild(sprite, zorder or 0)
    end
    if anchorPoint ~= nil then
        sprite:setAnchorPoint(anchorPoint)
    end
    return sprite
end

--==============================--
--desc:给一张九宫格资源设置纹理
--time:2018-07-22 10:48:02
--@sprite:
--@res:
--@type:
--@return 
--==============================--
function loadScale9SpriteTexture(sprite, res, type)
    type = type or ccui.TextureResType.plistType
    if type == ccui.TextureResType.localType then
        sprite:initWithFile(res)
    else
        sprite:initWithSpriteFrameName(res)
    end
end

--==============================--
--desc:给普通sprite设置纹理资源
--time:2018-07-22 10:48:17
--@sprite:
--@res:
--@res_type:
--@return 
--==============================--
function loadSpriteTexture(sprite, res, res_type)
    if not sprite then return end
	if not res then return end
    if res_type == ccui.TextureResType.localType then
        sprite:setTexture(res)
    else
		if type(res) == "string" and string.len(res) > 0 then
			sprite:setSpriteFrame(res)
		end
    end
end

--==============================--
--desc:创建输入文本
--time:2018-07-22 10:48:33
--@parent:
--@ui_res:
--@size:
--@font_color:
--@font_size:
--@placeholder_color:
--@placeholder_size:
--@placeholder_str:
--@pos:
--@max_len:
--@load_type:
--@input_model:
--@input_flag:
--@input_return:
--@return 
--==============================--
function createEditBox(parent, ui_res, size, font_color, font_size, placeholder_color, placeholder_size, placeholder_str, pos, max_len, load_type, input_model, input_flag, input_return)
    size = size or cc.size(100,30)
    load_type = load_type or LOADTEXT_TYPE
    local editBox = ccui.EditBox:create(size, ui_res, load_type)
    input_model = input_model or cc.EDITBOX_INPUT_MODE_SINGLELINE
    input_flag = input_flag or cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD
    input_return = input_return or cc.KEYBOARD_RETURNTYPE_DEFAULT
    editBox:setInputMode(input_model)
    editBox:setInputFlag(input_flag)
    editBox:setReturnType(input_return)
    if pos then
        editBox:setPosition(pos)
    end

    placeholder_str = placeholder_str or ""
    editBox:setPlaceHolder(placeholder_str)

    placeholder_size = placeholder_size or 20
    editBox:setPlaceholderFontSize(placeholder_size)

    placeholder_color = placeholder_color or Config.ColorData.data_color3[5]
    editBox:setPlaceholderFontColor(placeholder_color)

    font_size = font_size or 20
    editBox:setFont(DEFAULT_FONT,font_size)

    font_color = font_color or Config.ColorData.data_color3[1]
    editBox:setFontColor(font_color)

    if max_len then
        editBox:setMaxLength(max_len)
    end
    
    if parent then
        parent:addChild(editBox,10)
    end

    return editBox
end

--==============================--
--desc:滚动容器
--time:2018-07-22 10:48:48
--@width:
--@height:
--@x:
--@y:
--@parent_wnd:
--@type:
--@return 
--==============================--
function createScrollView(width,height,x,y,parent_wnd,type)
    local scroll_view = ccui.ScrollView:create()
    scroll_view:setBounceEnabled(true)
    scroll_view:setScrollBarEnabled(false)
    if type == ccui.ScrollViewDir.horizontal then
        scroll_view:setDirection(ccui.ScrollViewDir.horizontal)
    else
        scroll_view:setDirection(ccui.ScrollViewDir.vertical)
    end
    
    scroll_view:setTouchEnabled(true)
    scroll_view:setContentSize(cc.size(width, height))
    scroll_view:setInnerContainerSize(scroll_view:getContentSize())
    scroll_view:setPosition(cc.p(x, y))
    if not tolua.isnull(parent_wnd) then
        parent_wnd:addChild(scroll_view)
    end
    return scroll_view
end

--==============================--
--desc:创建一个进度条
--time:2018-07-22 10:49:43
--@bg_res:
--@progress_res:
--@size:
--@parent:
--@ap:
--@x:
--@y:
--@usePlist:
--@is_Scale9:
--@return 
--==============================--
function createLoadingBar(bg_res, progress_res, size, parent, ap, x, y, usePlist,is_Scale9)
    local load_type = usePlist and LOADTEXT_TYPE_PLIST or LOADTEXT_TYPE
    local is_Scale9 = is_Scale9 or true
    local bg = createScale9Sprite(bg_res, x, y, load_type, parent)
    bg:setContentSize(size)
    bg:setCascadeOpacityEnabled(true)
    bg:setAnchorPoint(ap)

    local progress = ccui.LoadingBar:create()
    progress:setAnchorPoint(cc.p(0, 0.5))
    progress:setScale9Enabled(is_Scale9)
    progress:setCascadeOpacityEnabled(true)
    progress:loadTexture(progress_res,load_type)
    progress:setContentSize(cc.size(size.width-4, size.height-4))
    progress:setPosition(cc.p(1, size.height/2))
    bg:addChild(progress)
    return bg, progress
end

--==============================--
--desc:可点击对象回调
--time:2018-07-22 10:50:13
--@touch_obj:
--@call_back:
--@return 
--==============================--
function handleTouchEnded(touch_obj, call_back)
    touch_obj:addTouchEventListener(function(sender, event)
        if ccui.TouchEventType.ended == event then
            call_back()
        end
    end)
end

--==============================--
--desc:转换色码
--time:2018-07-22 10:50:26
--@color_code:
--@return 
--==============================--
function tranformC3bTostr(color_code)
    local color = Config.ColorData.data_color3[color_code]
    return c3bToStr(color)
end

--==============================--
--desc:给Layout显示一个透明度的背景
--time:2018-07-22 10:50:38
--@layout:
--@value:
--@return 
--==============================--
function showLayoutRect( layout, value )
    if tolua.isnull(layout) then return end
    layout:setBackGroundColor(cc.c3b(0,0,0))
    layout:setBackGroundColorOpacity(value or 216)
    layout:setBackGroundColorType(1)
end

--==============================--
--desc:延迟执行
--time:2018-07-22 10:51:14
--@func:
--@time:
--@return 
--==============================--
function delayOnce(func, time)
    local timer_id 
    timer_id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
        if timer_id then    -- 撤销定时器
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer_id)
            timer_id = nil
        end
        func()
    end, time, false)
end

--==============================--
--desc: 设置对象变灰,递归下去
--time:2017-05-20 02:37:43
--@bool: 是否变灰
--@parent: 
--@color: 这个数值主要是针对label的颜色,变灰之后,字体的颜色需要指定色度,不填可以默认
--return 
--==============================--
function setChildUnEnabled(bool, parent, color)
    if tolua.isnull(parent) then return end
    local shader_path = PathTool.getShaderRes("grey_shader")
    setAllChildFilter(parent, bool, shader_path, color)
end

-- 设置模糊效果
function setChildBlurShader(bool, parent)
    if tolua.isnull(parent) then return end
    local shader_path = PathTool.getShaderRes("blur_shader")
    setAllChildFilter(parent, bool, shader_path)
end

--==============================--
--desc: 递归对象变暗
--time:2017-05-20 02:38:50
--@bool:
--@parent:
--@color: 针对label的颜色变换
--return 
--==============================--
function setChildDarkShader(bool, parent, color)
    if tolua.isnull(parent) then return end
    local shader_path = PathTool.getShaderRes("darkness_shader")
    setAllChildFilter(parent, bool, shader_path, color)
end

--==============================--
--desc:设置描边效果
--time:2017-06-30 05:59:38
--@bool:
--@parent:
--@outline_size:
--@outlin_color:
--@size:
--@return 
--==============================--
function setOutlineStatus(bool, parent, outline_size, outlin_color, size)
    if tolua.isnull(parent) then return end
    local shader_path = PathTool.getShaderRes("stroke_shader")
    if parent.setOutlineStatus then
        if bool == false then
            parent:setOutlineStatus(bool)
        else
            outline_size = outline_size or 0.8
            if outlin_color and  type(outlin_color) == "number" then
                outlin_color = Config.ColorData.data_color3[outlin_color]
            end
            outlin_color = outlin_color or Config.ColorData.data_color3[169]
            size = size or parent:getContentSize()
            parent:setOutlineStatus(bool, outline_size, outlin_color, size, shader_path)
        end
    end
end

--==============================--
--desc:冰冻效果
--time:2017-06-07 03:59:03
--@bool:
--@parent:
--@color:
--return 
--==============================--
function setChildFrozenShader(bool, parent, color)
    if tolua.isnull(parent) then return end
    local shader_path = PathTool.getShaderRes("frozen_shader")
    setAllChildFilter(parent, bool, shader_path, color)
end

function delayRun(obj, delay_time, fun)
    if not tolua.isnull(obj) then
        obj:runAction(cc.Sequence:create(cc.DelayTime:create(delay_time), cc.CallFunc:create(
            function()
                if not tolua.isnull(obj) and fun ~= nil then
                    fun()
                end
            end
        )))
    end
end

_effect_once = _effect_once or {}
--==============================--
--desc:只播放一次特效
--time:2018-07-22 10:51:41
--@effect_name:
--@x:
--@y:
--@parent:
--@finish_call:
--@isgore_playing:
--@ignore_battle:
--@delay_play:
--@action_name:
--@scale:
--@return 
--==============================--
function playEffectOnce(effect_name, x, y, parent, finish_call, isgore_playing, ignore_battle, delay_play, action_name, scale, force)
    action_name = action_name or PlayerAction.action 
    if _effect_once_playing and not isgore_playing then
        if _effect_once_last ~= effect_name or force == true then
            table.insert(_effect_once, {effect_name, x, y, parent, finish_call, isgore_playing, ignore_battle})
        end
    else
        _effect_once_playing = true
        if not _G["GlobalTimeTicket"] then
            require "sys/global_time_ticket"
        end
        GlobalTimeTicket:getInstance():remove("play_effect_timeout")
        GlobalTimeTicket:getInstance():add(function()
            _effect_once_playing = false
        end, 1, 1, "play_effect_timeout")
        _effect_once_last = effect_name

        local js_path, atlas_path, png = PathTool.getSpineByName(effect_name)
        local remove_fun = function()
            if finish_call then
                finish_call()
            end
            if #_effect_once > 0 then 
                local data = _effect_once[1]
                _effect_name, _x, _y, _parent, _finish_call, _isgore_playing, _ignore_battle = data[1], data[2], data[3], data[4], data[5], data[6], data[7]
                table.remove(_effect_once, 1)
                playEffectOnce(_effect_name, _x, _y, _parent, _finish_call, _isgore_playing, _ignore_battle)
            end
        end

        local call_back = function(spine)
            if type(parent) == "table" then
                if not tolua.isnull(parent[1]) then
                    parent[1]:addChild(spine, parent[2])
                else
                    remove_fun()
                    return
                end
            elseif not tolua.isnull(parent) then
                parent:addChild(spine, 99)
            else
                remove_fun()
                return
            end 
            local finish_func = function( event)
                if event.animation == action_name then
                    _effect_once_playing = false
                    spine:runAction(cc.RemoveSelf:create(true)) 
                    _effect_once_last = nil
                    remove_fun()
                end
            end
            -- 有一些时候还在播放途中,就停掉了 这时候是不会切换会播放状态就有问题了
            if force == true then
                spine:registerScriptHandler(function(event)
                    if "enter" == event then
                    elseif "exit" == event then
                        _effect_once_playing = false
                    end 
                end)
            end

            spine:setPosition(x, y)
            spine:registerSpineEventHandler(finish_func, sp.EventType.ANIMATION_COMPLETE)
            spine:setAnimation(0, action_name or PlayerAction.action, false)
            scale = scale or 1
            spine:setScale(scale)
        end
        call_back(createSpineByName(effect_name)) 
    end
end

--==============================--
--desc:统一释放
--time:2018-07-22 10:52:16
--@cobj:
--@return 
--==============================--
function doRelease(cobj)
    if not tolua.isnull(cobj) and cobj:getReferenceCount() > 1 then
        cobj:release()
    end
end

--==============================--
--desc:安全判定
--time:2018-07-22 10:52:26
--@cobj:
--@return 
--==============================--
function doRemoveFromParent(cobj)
    if not tolua.isnull(cobj) then
        cobj:removeFromParent()
    end
end


function safeCallFunc(func)
    xpcall(func, 
    function(msg)
        local trace = debug.traceback()
        local ver_code = cc.UserDefault:getInstance():getIntegerForKey("local_version")
        print_log(string.format("[%s,%s,%s]%s\n%s", ver_code, PLATFORM, PLATFORM_NAME, msg, trace))
        if buglyReportLuaException then 
            buglyReportLuaException(string.format("[%s,%s,%s]%s", ver_code, PLATFORM, PLATFORM_NAME, msg), trace)
        end
    end)
end

--==============================--
--desc:区分服务器名称
--time:2018-07-22 10:52:50
--@name:
--@srv_id:
--@return 
--==============================--
function transformNameByServ(name, srv_id)
    local tmpName = name
    if srv_id == nil or name == nil then return tmpName end
    if name then
        if string.find(tmpName,"【") then
            return tmpName
        end 
    end
    if not RoleController:getInstance():isTheSameSvr(srv_id) then
        local vo = RoleController:getInstance():getRoleVo()
        if vo then
            local listOr = Split(srv_id, "_")
            local listMe = Split(vo.srv_id, "_")
            if listOr[2] and listMe[1] and listOr[1]~=listMe[1] then
                tmpName = string.format(TI18N("[异域]%s"), tmpName)
            elseif #listOr > 1 then
                tmpName = string.format("[S%s]%s", listOr[#listOr], tmpName)
            end
            if srv_id == "robot_1" or srv_id == "robot" then --代表机器人
                tmpName = name
            end
        end
    end
    return tmpName
end

--==============================--
--desc:获取服务器名字
--time:2018-07-22 10:54:30
--@str:
--@return 
--==============================--
function getServerName(srv_id)
    if srv_id == nil then 
        return "" 
    end
    local tmpName = ""
    local vo = RoleController:getInstance():getRoleVo()
    if vo then
        local listOr = Split(srv_id, "_")
        local listMe = Split(vo.srv_id, "_")
        if listOr[2] and listMe[1] and listOr[1]~=listMe[1] then
            tmpName = TI18N("异域")
        elseif #listOr > 1 then
            tmpName = string.format("S%s", listOr[#listOr])
        end
        if srv_id == "robot_1" then --代表机器人
            tmpName = name
        end
    end
    return tmpName
end
--==============================--
--desc:获取服务器索引
--time:2018-07-22 10:54:30
--@str:
--@return index, is_local 
--index == 0 表示 机器 或者 异域(就是无法知道是那个服的)
--is_local : 表示是否本服
--==============================--
function getServerIndex( srv_id )
    if srv_id == nil then 
        return "" 
    end
    if srv_id == "robot_1" or srv_id == "robot" then --代表机器人
        return 0
    end
    local vo = RoleController:getInstance():getRoleVo()
    if vo then
        local listOr = Split(srv_id, "_")
        local listMe = Split(vo.srv_id, "_")
        if listOr[2] and listMe[1] and listOr[1]~=listMe[1] then
            return 0
        elseif #listOr > 1 then
            -- 传过来的服务器id 跟角色的 服务器id 或者 主服务器id(合服后用) 一致 算本服
            if srv_id == vo.srv_id or srv_id == vo.main_srv_id then
                return listOr[#listOr], true
            else
                return listOr[#listOr]
            end
        end
    end
    return 0
end

--==============================--
--desc:预留处理暂时没用了
--time:2018-07-22 10:54:30
--@str:
--@return 
--==============================--
function _T(str)
    return str
end

--==============================--
--desc:安全判定
--time:2018-07-22 10:55:04
--@cobj:
--@page:
--@return 
--==============================--
function doScrollToPage(cobj, page)
    if not tolua.isnull(cobj) then 
        cobj:scrollToPage(page or 0)
    end
end

--==============================--
--desc:两个对象最排列显示
--time:2018-07-22 10:55:47
--@target:
--@obj:
--@offX:
--@offY:
--@return 
--==============================--
function appendToTarget( target, obj, offX, offY)
    offX = offX or 0
    offY = offY or 0
    if target ~= nil and obj ~= nil then
        local _x, _y = target:getPosition() 
        if true then
            obj:setPosition(cc.p(_x + target:getContentSize().width + offX, _y + offY))
        end
        obj:setPosition(cc.p(_x + target:getContentSize().width + offX, _y + offY))
    end
end

--==============================--
--desc:通用点击状态显示(先放大再缩小)
--time:2018-07-22 10:56:16
--@sender:
--@event_type:
--@scale:
--@return 
--==============================--
function customClickAction(sender, event_type, scale)
    if tolua.isnull(sender) then return end
    scale = scale or 1
    if event_type == ccui.TouchEventType.began then
        sender:stopAllActions()
        sender:runAction(cc.ScaleTo:create(0.05, 1.1*scale))
    elseif event_type == ccui.TouchEventType.ended  then
        sender:stopAllActions()
        sender:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0.95*scale), cc.ScaleTo:create(0.1, 1*scale)))
    elseif event_type == ccui.TouchEventType.canceled then
        sender:stopAllActions()
        sender:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0.95*scale), cc.ScaleTo:create(0.1, 1*scale)))
    end
end

-- 通用点击状态显示（先缩小再放大）
function customClickAction_2(sender, event_type, scale)
    if tolua.isnull(sender) then return end
    scale = scale or 1
    if event_type == ccui.TouchEventType.began then
        sender:stopAllActions()
        sender:runAction(cc.ScaleTo:create(0.05, 0.95*scale))
    elseif event_type == ccui.TouchEventType.ended  then
        sender:stopAllActions()
        sender:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1*scale), cc.ScaleTo:create(0.1, 1*scale)))
    elseif event_type == ccui.TouchEventType.canceled then
        sender:stopAllActions()
        sender:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1*scale), cc.ScaleTo:create(0.1, 1*scale)))
    end
end

--==============================--
--desc:通用点击状态显示
--time:2018-07-22 10:56:16
--@sender:
--@event_type:
--@scale_x, scale_y x y坐标不一样的时候
--@return 
--==============================--
function customClickActionByXY(sender, event_type, scale_x, scale_y)
    if tolua.isnull(sender) then return end
    local scale_x = scale_x or 1
    local scale_y = scale_y or 1
    if event_type == ccui.TouchEventType.began then
        sender:stopAllActions()
        sender:runAction(cc.ScaleTo:create(0.05, 0.95*scale_x, 0.95*scale_y))
    elseif event_type == ccui.TouchEventType.ended  then
        sender:stopAllActions()
        sender:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1*scale_x, 1.1*scale_y), cc.ScaleTo:create(0.1, 1*scale_x, 1*scale_y)))
    elseif event_type == ccui.TouchEventType.canceled then
        sender:stopAllActions()
        sender:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.1*scale_x, 1.1*scale_y), cc.ScaleTo:create(0.1, 1*scale_x, 1*scale_y)))
    end
end

--==============================--
--desc:配置格式装换
--time:2018-07-22 10:56:41
--@content:配置的格式为 {X:OOOOOO}, 其中X 对应的 Config.ColorData里面的id
--@return 
--==============================--
function splitDataStr(content)
    local result = content
    if result ~= nil and result ~= "" then
        while string.find(result,"{") ~= nil do
            local i,j = string.find(result,"{")
            local n,m = string.find(result,"}")   
            local temp = string.sub(result, i, m)
            local target = string.sub(temp, 2, #temp-1)
            local list = Split(target, ":")
            local str = string.format("<div fontcolor=%s>%s</div>",tranformC3bTostr(tonumber(list[1])),list[2])
            result = string.gsub(result, temp, str,1) 
        end
    end
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo ~= nil then
        result = string.gsub(result,"~n",role_vo.name)
    end
    return result
end

--==============================--
--desc:节点进出场处理
--time:2018-07-22 10:57:34
--@node:
--@enterCallBack:
--@removeCallBack:
--@return 
--==============================--
function registerRemmovePointer(node, enterCallBack, removeCallBack)
    local function onNodeEvent(event)
        if "enter" == event then  --进场
            if enterCallBack then
                enterCallBack()
            end
        elseif "exit" == event then --离场
            if removeCallBack then
                removeCallBack()
            end
            --当忘记销毁根节点的时候，这个地方帮助吧根节点销毁
            node = nil
        end
    end
end   

--==============================--
--desc:只有主界面图标.主UI下面7个按钮以及主城建筑泡泡
--time:2017-08-07 07:40:52
--@return 
--==============================--
function playButtonSound()
    if AudioManager then
        AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON,"c_002")
    end
end

--==============================--
--desc:标签页声音
--time:2017-08-07 07:40:52
--@return
--==============================--
function playTabButtonSound()
    AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON, "c_002")
end

--==============================--
--desc:非主界面图标的可点击控件的按钮省
--time:2017-08-07 07:38:19
--@return
--==============================--
function playButtonSound2()
    if AudioManager then
        AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON, "c_button1")
    end
end

--==============================--
--desc:关闭是的声音
--time:2018-07-22 10:58:07
--@return 
--==============================--
function playCloseSound()
    if AudioManager then
        AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON,"c_close")
    end  
end

--==============================--
--desc:播放伙伴配音
--time:2018-07-22 11:01:29
--@sound_id:
--@return 
--==============================--
function playPartnerSound(sound_id)
     if AudioManager then
        AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.DUBBING,sound_id,false)
    end
end

--==============================--
--desc:点击特殊音效的统一接口
--time:2018-07-22 11:01:41
--@sound_id:
--@type:
--@return 
--==============================--
function playOtherSound(sound_id, type)
    type = type or AudioManager.AUDIO_TYPE.COMMON 
	AudioManager:getInstance():playEffect(type, sound_id)
end

--==============================--
--desc:模拟点击坐标
--time:2017-06-06 12:10:13
--@x:
--@y:
--return 
--==============================--
function touchPoint(x, y)
    -- x = x or 0
    -- y = y or 0 
    -- x = (x - (SCREEN_WIDTH - VISIBLE_WIDTH)/2) / VISIBLE_WIDTH * SIZE_BASE.width
    -- y =  y / SCREEN_HEIGHT * SIZE_BASE.height
    -- local msg = string.format("tap %s %s", x, SIZE_BASE.height - y)
    
    -- cc.Director:getInstance():getConsole():commandTouch(0, msg)
end

--==============================--
--desc:递归根据tag查找某个节点
--time:2017-06-06 03:06:25
--@node:
--@tag:
--return 
--==============================--
function findNodeByTag(node,tag)     
    if tolua.isnull(node) == nil then return end   
    if node == nil then return end
    if node and node.getTag and node:getTag() == tag then return node end 

    local children = {node:getChildren()}
    local index = 0  
    while index < #children do  
        index = index + 1  
        for k,v in pairs(children[index]) do
            if not tolua.isnull(v) then
                if v.getTag and v:getTag() == tag then  
                    return v   
                end  
                if v.getChildren then  
                    table.insert(children,v:getChildren())  
                end
            end
        end  
    end  
    return nil  
end

--==============================--
--desc:递归根据名字查找某个节点
--time:2017-06-06 03:07:31
--@node:
--@name:
--return 
--==============================--
function findNodeByName(node, name)
    if tolua.isnull(node) == nil then return end
    if node == nil then return end
    if node and node.getName and node:getName() == name then return node end 

    local children = {node:getChildren()}
    local index = 0  
    while index < #children do  
        index = index + 1  
        for k,v in pairs(children[index]) do
            if not tolua.isnull(v) then
                if v.getName and v:getName() == name then  
                    return v   
                end  
                if v.getChildren then  
                    table.insert(children,v:getChildren())  
                end
            end
        end  
    end  
    return nil  
end

-- 获取当前版本号
function now_ver()
    local ver = cc.UserDefault:getInstance():getIntegerForKey("local_version") or 0
    if cc.UserDefault:getInstance():getBoolForKey("is_enter_try_srv") then -- 是否进入优先体验服
        ver = cc.UserDefault:getInstance():getIntegerForKey("local_try_version") or ver
    end
    return math.max(ver, NOW_VERSION)
end

-- 检查当前需求最小版本号 当前版本小于此版本时 理应强制热更(restart)
function check_min_ver(Fun, is_force)
    local is_win_mac = PLATFORM == cc.PLATFORM_OS_WINDOWS or PLATFORM == cc.PLATFORM_OS_MAC
    if not is_force and ((not WIN_UPDATE and is_win_mac) or UPDATE_SKIP) then return end
    local url = string.format("%s/min_version2.txt?ts=%s", URL_PATH.update, os.time())
    if cc.UserDefault:getInstance():getBoolForKey("is_enter_try_srv") then -- 是否进入优先体验服
        url = string.format("%s/min_tryver.txt?ts=%s", URL_PATH.update, os.time())
    end
    print("get_min_ver_url==>", url)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", url)
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            Fun(now_ver(), tonumber(xhr.response))
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
    return true
end

--==============================--
--desc:统一选中的动态效果(策划要求的呼吸发光效果
--time:2017-07-15 11:48:33
--@obj:
--@return 
--==============================--
function breatheShineAction(obj, in_time, out_time)
    in_time = in_time or 0.7
    out_time = out_time or 0.4
    if obj == nil or tolua.isnull(obj) then return end
	local fadein = cc.FadeIn:create(in_time)
	local fadeout = cc.FadeOut:create(out_time)
	obj:runAction(cc.RepeatForever:create(cc.Sequence:create(fadein,fadeout)))
end

--==============================--
--desc:
--time:2017-08-10 07:29:38
--@obj:
--@delay_time:延迟时间
--@remain_tiem:停留时间
--@in_time:
--@out_time:
--@return 
--==============================--
function breatheShineAction2(obj, delay_time,remain_time,in_time, out_time)
    in_time = in_time or 0.7
    out_time = out_time or 0.4
    delay_time = delay_time or 10
    remain_time = remain_time or 5
    if obj == nil or tolua.isnull(obj) then return end
    obj:setOpacity(0)
	local fadein = cc.FadeIn:create(in_time)
	local fadeout = cc.FadeOut:create(out_time)
    local delay_time = cc.DelayTime:create(delay_time)
    local remain_time = cc.DelayTime:create(remain_time)
	obj:runAction(cc.RepeatForever:create(cc.Sequence:create(delay_time,fadein,remain_time,fadeout)))
end


--==============================--
--desc:放大缩小的强化效果
--time:2017-09-18 03:35:24
--@obj:
--@scale:
--@scale_time:
--@return 
--==============================--
function breatheShineAction3(obj, scale, scale_time)
    scale = scale or 1.05
    scale_time = scale_time or 0.6
    if obj == nil or tolua.isnull(obj) then return end
	local scale_open = cc.ScaleTo:create(scale_time,scale)
	local scale_close = cc.ScaleTo:create(scale_time,1)
	obj:runAction(cc.RepeatForever:create(cc.Sequence:create(scale_open,scale_close)))
end

function breatheShineAction4(obj, move_time, off_y)
    if tolua.isnull(obj) then return end
    move_time = move_time or 0.5
    off_y = off_y or 10
    local move_by_1 = cc.MoveBy:create(move_time, cc.p(0, -off_y))
    local move_by_2 = cc.MoveBy:create(move_time * 2, cc.p(0, 2 * off_y))
    local move_by_3 = cc.MoveBy:create(move_time, cc.p(0, -off_y))
	obj:runAction(cc.RepeatForever:create(cc.Sequence:create(move_by_1,move_by_2, move_by_3)))
end


--通用进入动画 左边进入
function commonOpenActionLeftMove(obj)
    if obj == nil or tolua.isnull(obj) then return end
    doStopAllActions(obj)
    local y = obj:getPositionY()
    obj:setPosition(0, y)
    obj:setOpacity(0)

    local moveto = cc.EaseBackOut:create(cc.MoveTo:create(0.3,cc.p(360, y))) 
    local fadeIn = cc.FadeIn:create(0.25)
    local spawn_action = cc.Spawn:create(moveto, fadeIn)
    obj:runAction(spawn_action)
end

--通用进入动画 右边进入
function commonOpenActionRightMove(obj)
    if obj == nil or tolua.isnull(obj) then return end
    doStopAllActions(obj)
    local y = obj:getPositionY()
    obj:setPosition(720, y)
    obj:setOpacity(0)

    local moveto = cc.EaseBackOut:create(cc.MoveTo:create(0.3,cc.p(360, y))) 
    local fadeIn = cc.FadeIn:create(0.25)
    local spawn_action = cc.Spawn:create(moveto, fadeIn)
    obj:runAction(spawn_action)
end



--通用打开面板动画 缩小放大
function commonOpenActionCentreScale(obj)
    if obj == nil or tolua.isnull(obj) then return end
    doStopAllActions(obj)
    obj:setPositionX(360)
    obj:setOpacity(0)
    obj:setScale(0.3)
    local fadeIn = cc.FadeIn:create(0.25)
    local scaleTo = cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 1))
    local spawn_action = cc.Spawn:create(scaleTo, fadeIn)
    obj:runAction(spawn_action)
end




--==============================--
--desc:消耗红钻的时候统一接口,callback处理具体事项(比如发送协议等)
--time:2017-12-29 10:50:51
--@need_value:
--@callback:
--@return 
--==============================--
function checkGoldIsEnough(need_value, callback)
    if callback == nil then return end
    callback()
end

--==============================--
--desc:动态加载资源的接口.适应小包处理
--time:2018-07-22 11:05:34
--@path:
--@type:
--@callback:
--@load:
--@lock:
--@return 
--==============================--
function createResourcesLoad(path, type, callback, load, lock)
    if load ~= nil then
        load:DeleteMe()
        load = nil
    end
    local load = ResourcesLoad.New()
    load:addDownloadList(path, type, function() 
        callback()
    end)

    return load
end

--==============================--
--desc:动态加载资源的接口.适应小包处理
--time:2018-07-22 11:05:34
--@node:显示对象,只针对sprite
--@path:路径
--@type:
--@load:
--@delete_time 自定移除时间
--@return 
--==============================--
function loadSpriteTextureFromCDN(node, path, type, load, delete_time, load_callback)
    if load ~= nil then
        load:DeleteMe()
        load = nil
    end

    if tolua.isnull(node) then return end
    
    local load = ResourcesLoad.New()
    load:addDownloadList(path, type, function() 
        if not tolua.isnull(node) then
            loadSpriteTexture(node, path, LOADTEXT_TYPE)
            if load_callback then
                load_callback()
            end
        end
    end, delete_time)
    return load
end

--==============================--
--desc:动态加载资源的接口.适应小包处理
--time:2018-07-22 11:05:34
--@node:显示对象,只针对Image
--@path:路径
--@type:
--@load:
--@delete_time 自定移除时间
--@return 
--==============================--
function loadImageTextureFromCDN(node, path, type, load, delete_time, load_callback)
    if load ~= nil then
        load:DeleteMe()
        load = nil
    end

    if tolua.isnull(node) then return end
    
    local load = ResourcesLoad.New()
    load:addDownloadList(path, type, function() 
        if not tolua.isnull(node) then
            node:loadTexture(path,LOADTEXT_TYPE)
            if load_callback then
                load_callback()
            end
        end
    end, delete_time)
    return load
end

function TI18N(msg)
    return msg
end

--==============================--
--desc:创建战斗模型
--time:2018-07-22 11:06:07
--@spine_name:
--@action_name:
--@return 
--==============================--
function createArmature(spine_name, action_name)
    local armature = nil
    if string.find(spine_name, "E") == nil then
        spine_name = spine_name or "H99999"
        armature = createSpineByName(spine_name, action_name)
    else
        armature = createSpineByName(spine_name)
    end
    local time_scale = 1
    if not BattleController:getInstance():getIsNoramalBattle() then
        time_scale = BattleController:getInstance():getModel():getTimeScale()
    end
    armature:setTimeScale(time_scale)
    armature:setAnchorPoint(cc.p(0.5, 0))
    return armature
end


local tolua_isnull = tolua.isnull
--==============================--
--desc:安全判定
--time:2018-07-22 11:06:21
--@node:
--@return 
--==============================--
function doStopAllActions(node)
    if tolua_isnull(node) then return end
    node:stopAllActions()
end

--==============================--
--desc:是否是全面屏  cc.PLATFORM_OS_ANDROID 
--time:2018-07-21 11:42:46
--@return 
--==============================--
function hasNotchInScreen()
    if NOTICE_IN_SCREEN == nil then
        local notch_in_screen = false
        local has_notch = device.hasNotchInScreen()
        if has_notch == "yes" then
            notch_in_screen = true
        else
            local tmp_factor = 2.01
            local device_name = device.getDeviceName()
            if device_name == "HONOR_HWTNY(TNY-AL00)" or device_name == " HONOR_HWPCT(PCT-AL10)" or 
                device_name == " HUAWEI_HWVCE(VCE-AL00)" or device_name == " HONOR_HWOXF(OXF-AN00)" or 
                device_name == "HONOR_HWOXF(OXF-AN10)" or device_name == "xiaomi_sakura(Redmi 6 Pro)" or 
                device_name == "OPPO_OP4ADD(PDCM00)" or device_name == "Xiaomi_tucana(MI CC9 Pro)" or device_name == "samsung_a8sqltechn(SM-G8870)" then
                notch_in_screen = true
            else
                if string.find(device_name, "dipper") ~= nil then
                    notch_in_screen = true
                elseif string.find(device_name, "sirius") ~= nil then
                    notch_in_screen = true
                elseif string.find(device_name, "equuleus") ~= nil then
                    notch_in_screen = true
                elseif string.find(device_name, "ursa") ~= nil then
                    notch_in_screen = true
                elseif string.find(device_name, "platina") ~= nil then
                    notch_in_screen = true
                elseif string.find(device_name, "cepheus") ~= nil then
                    notch_in_screen = true
                    tmp_factor = 2.1
                elseif string.find(device_name, "grus") ~= nil then
                    notch_in_screen = true
                elseif string.find(device_name, "WLZ-AL10") ~= nil then
                    notch_in_screen = true
                elseif string.find(device_name, "WLZ-AN00") ~= nil then
                    notch_in_screen = true
                elseif string.find(device_name, "OXF-AN00") ~= nil then
                    notch_in_screen = true
                elseif string.find(device_name, "JNY-AL10") ~= nil then
                    notch_in_screen = true
                elseif string.find(device_name, "begonia") ~= nil then   --Redmi Note 8 Pro
                    notch_in_screen = true
                end
            end
            local factor = display.height / display.width
            notch_in_screen = notch_in_screen and factor > tmp_factor
        end
        NOTICE_IN_SCREEN = notch_in_screen
    end
    return NOTICE_IN_SCREEN
end

-- 根据文字内容获取对应的背景大小(大致)
--[[
    textStr: 字符内容
    topMargin: 顶部边距
    bottomMargin: 底部边距
    horMargin: 左右边距
    textMaxWidth: 字符最大宽度
    textFontSize: 字符大小
    textLineSpace: 字符行间距
    textCharSpace: 字符间距
]]
function getTextBgSizeByTextContent( textStr, topMargin, bottomMargin, horMargin, textMaxWidth, textFontSize, textLineSpace, textCharSpace)
    local bgSizeWidth = 0
    local bgSizeHeight = 0
    topMargin = topMargin or 30
    bottomMargin = bottomMargin or 30
    horMargin = horMargin or 30
    textMaxWidth = textMaxWidth or 100
    textFontSize = textFontSize or 20
    textLineSpace = textLineSpace or 0
    textCharSpace = textCharSpace or 0
    if textStr and textStr ~= "" then
        local textLen = StringUtil.getStrLen(textStr)
        local charNum = math.ceil(textLen/2)
        if charNum*(textFontSize+textCharSpace) < textMaxWidth then --文字内容不足一行
            bgSizeWidth = horMargin*2 + charNum*(textFontSize+textCharSpace)
            bgSizeHeight = textFontSize + topMargin + bottomMargin
        else
            local row = math.ceil(charNum*(textFontSize+textCharSpace)/textMaxWidth)
            bgSizeWidth = horMargin*2 + textMaxWidth
            bgSizeHeight = row*textFontSize + (row-1)*textLineSpace +  topMargin + bottomMargin
        end
    end
    return cc.size(bgSizeWidth, bgSizeHeight)
end

-- 给节点添加红点
--[[
    node:红点父节点
    status:是否显示
    offset_x:红点x轴偏移
    offset_y:红点y轴偏移
    zorder:红点层级
]]
function addRedPointToNodeByStatus( node, status, offset_x, offset_y, zorder, red_type )
    if node and not tolua.isnull(node) then
        if status == true then
            if not node.red_point then
                offset_x = offset_x or 0
                offset_y = offset_y or 0
                zorder = zorder or 10
                local red_res = PathTool.getResFrame("common","common_1014")
                --红点从 common 图集 和 main_ui图集里面 通用用common 需要转大小
                local scale = 25/35  
                if red_type and red_type == 2 then
                    -- red_res = PathTool.getResFrame("common","common_1014")
                    scale = 1
                end
                local red_point = createSprite(red_res,0,0,node,cc.p(1,1),LOADTEXT_TYPE_PLIST,zorder)
                local node_size = node:getContentSize()
                local pos_x = node_size.width + offset_x
                local pos_y = node_size.height + offset_y
                red_point:setPosition(cc.p(pos_x, pos_y))
                red_point:setScale(scale)
                node.red_point = red_point
            end
            node.red_point:setVisible(true)
        elseif node.red_point then
            node.red_point:setVisible(false)
        end
    end
end

-- 注册按钮点击事件
--[[
    button_node:
    clickCallBack:点击回调函数
    showClickAction:是否添加显示缩放动画 默认为false
    soundType:点击音效，1为普通按钮，2为关闭按钮 3为标签页 默认为1
    param:回调参数
    scale: 按钮的倍率
    clickDelay:点击延迟
    clickScroll: 滚动点击( 用于scrollview里面的按钮)
]]

--注册按钮声音类型 --by lwc
REGISTER_BUTTON_SOUND_BUTTON_TYPY = 1 --按钮类型
REGISTER_BUTTON_SOUND_CLOSED_TYPY = 2 -- 关闭
REGISTER_BUTTON_SOUND_TAB_BUTTON_TYPY = 3 --页签
function registerButtonEventListener(button_node, clickCallBack, showClickAction, soundType, param, scale, clickDelay, clickScroll)
    if tolua.isnull(button_node) then return end
    local showClickAction = showClickAction or false
    local soundType = soundType or 1
    local clickDelay = clickDelay or 0

    button_node:addTouchEventListener(function(sender, event_type)
        if showClickAction then
            customClickAction(sender, event_type, scale)
        end
        if clickScroll then
            if event_type == ccui.TouchEventType.began then
                button_node.touch_began = sender:getTouchBeganPosition()
            end    
        end
        if event_type == ccui.TouchEventType.ended then
            if clickScroll then
                local touch_began = button_node.touch_began
                local touch_end = sender:getTouchEndPosition()
                if touch_began and touch_end and (math.abs(touch_end.x - touch_began.x) > 20 or math.abs(touch_end.y - touch_began.y) > 20) then 
                    --移动大于20了..表示本点击无效
                    return
                end 

            end
            -- 点击间隔
            if clickDelay > 0 and button_node.last_time and math.abs(GameNet:getInstance():getTimeFloat() - button_node.last_time) < clickDelay then
                return
            end
            button_node.last_time = GameNet:getInstance():getTimeFloat()
            if soundType == REGISTER_BUTTON_SOUND_BUTTON_TYPY then
                playButtonSound2()
            elseif soundType == REGISTER_BUTTON_SOUND_CLOSED_TYPY then
                playCloseSound()
            elseif soundType == REGISTER_BUTTON_SOUND_TAB_BUTTON_TYPY then
                playTabButtonSound()
            end
            if clickCallBack then
                clickCallBack(param, sender, event_type)
            end
        end
    end)
end

--==============================--
--desc:获取纹理格式
--time:2019-01-09 10:09:19
--@spine_name:spine的命
--@return 
--==============================--
function getPixelFormat(spine_name)
    if spine_name == nil then 
        return cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444 
    end
    local pf = cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444 

    local frist_letter = string.sub(spine_name, 1, 1)
    if frist_letter == "E" and Config.SpecialSpineData then 
        local pf_value = Config.SpecialSpineData.data_effect[spine_name]
        if pf_value == 1 then
            pf = cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888
        end
    end
    if EQUIPMENT_QUALITY == 3 then
        pf = cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888 
    end
    return pf
end

--==============================--
--desc:获取随机名字
--time:2019-01-26 12:03:54
--@return 
--==============================-- 
function getRandomSaveName()
	local function randomName(str)	
		local result = str
		local a = string.char(math.random(65, 90))
		local b = string.char(math.random(97, 122))
		local c = string.char(math.random(48, 57))
		if math.random(3) % 3 == 0 then
			result = result..a
		elseif  math.random(3) % 2 == 0 then
			result = result..b
		else
			result = result..c
		end
		if StringUtil.getStrLen(result)<12 then
			result = randomName(result)
		end
		return result
	end

	local usr = randomName("")
    return "sy"..usr
end

--通用显示单行道具列表
--@ item_scrollview scrollview 对象
--@ item_list BackPackItem的对象列表 (注意: 需要在那边手动移除)
--@ data_list 数据列表 结构{{道具id, 数量, 道具名字},...} 就是策划填表的奖励道具结构
--@setting 
--@setting.scale 缩小参数 默认 1 
--@setting.start_x 两边对应道具的间隔
--@setting.space_x 道具之间的间隔
--@setting.max_count item_scrollview最大能显示item数量..用于判断是否可以左右滑动  不填则可以移动
--@setting.is_center 是否不满就居中 max_count必须有值
--@setting.show_effect_id =特效id 显示对应特效 默认无
--@setting.is_tip 是否弹通用tips 默认nil
--@setting.is_show_action 是否有显示放大缩小的动作
--@setting.is_get_status 是否显示已领取
--@setting.get_status_res 已领取特殊资源
--@setting.is_show_bg 是否显示bg框
function commonShowSingleRowItemList(item_scrollview, item_list, data_list, setting)
    if not item_scrollview then 
        -- print("对象 item_scrollview 不能为空")
        return
    end
    if not data_list then 
        -- print("data_list不能为空!")
        return
    end
    local item_list = item_list

    if item_list then
        --隐藏物品
        for i,v in ipairs(item_list) do
            v:setVisible(false)
        end
    end

    if item_list == nil then 
        item_list = {}
    end

    if  #data_list == 0 then
        return 
    end
    --道具列表
    local setting = setting or {}
    local scale = setting.scale or 1
    local start_x = setting.start_x or 5
    local space_x = setting.space_x or 5
    local max_count = setting.max_count
    local item_width = setting.item_width or BackPackItem.Width
    local lock = setting.lock or false
    local lock_pos = setting.lock_pos or nil
    local is_show_action = setting.is_show_action or false
    --点击返回回调函数
    local is_tip = setting.is_tip
    local callback = setting.callback or false
    local is_get_status = setting.is_get_status or false
    local get_status_res = setting.get_status_res or nil
    local is_show_bg = setting.is_show_bg
    local is_show_got = setting.is_show_got
    
    local item_count = #data_list
    item_width = item_width * scale

    local total_width =  start_x * 2 + item_width * item_count + space_x * (item_count - 1)
    local item_scrollview_size = item_scrollview:getContentSize()
    local max_width = math.max(item_scrollview_size.width, total_width)
    item_scrollview:setInnerContainerSize(cc.size(max_width, item_scrollview_size.height))
    if max_count and item_count <= max_count then
        item_scrollview:setTouchEnabled(false)
        if setting.is_center then
            start_x = (item_scrollview_size.width - total_width) * 0.5
            if start_x < 0 then
                start_x = 0
            end
        end
    else
        item_scrollview:setTouchEnabled(true)
    end
    item_scrollview:stopAllActions()

    local function _setItemData(item, v, i)
        item:setVisible(true)
        local _x = start_x + (i - 1) * (item_width + space_x)
        item:setPosition(_x, item_scrollview_size.height * 0.5)
        item:setBaseData(v[1], v[2], true)
        item:showOrderWarLock(lock,lock_pos)
        item:IsGetStatus(is_get_status,nil,get_status_res)
        if callback then
            item:addCallBack(function()
                callback()
            end)
        end
        if v[3] then
            item:setGoodsName(v[3],nil,24,nil)
        end
        item:setDefaultTip(is_tip)
        if setting.show_effect_id then
            item:showItemEffect(true, setting.show_effect_id, PlayerAction.action_1, true, 1.1)
        end
        
        if is_show_bg ~= nil then
            item:setIsShowBackground(is_show_bg)
        end

        if is_show_got ~= nil then
            item:setGotIcon(is_show_got)
        end
    end
    local item = nil
    local size = #item_list 
    for i, v in ipairs(data_list) do
        item = item_list[i]
        if item then
            _setItemData(item, v, i)
        else
            local dealey = i - size
            if dealey <= 0 then
                dealey = 1
            end
            local time = 0
            if is_show_action then
                time = 0.1 * dealey
            else
                time = dealey / display.DEFAULT_FPS
            end
            delayRun(item_scrollview, time, function ()
                if not item_list[i] then
                    item = BackPackItem.new(true, true)
                    item:setAnchorPoint(0, 0.5)
                    item:setScale(scale)
                    item:setSwallowTouches(false)
                    item_scrollview:addChild(item)
                    item_list[i] = item
                    _setItemData(item, v, i)
                    if is_show_action then
                        item:setScale(scale * 1.3)
                        item:runAction(cc.ScaleTo:create(0.1, scale))
                    end
                end
            end)
        end
    end
    return item_list
end

--获取属性对应信息 
-- @attr_id  策划定义属性id 参考表attr_data.xml
-- @attr_val  对应值..如果是百分比 传过来的是千分比
--return 属性icon路径, 属性名字, 属性值
function commonGetAttrInfoByIDValue(attr_id, attr_val)
    if not attr_id or not attr_val then return end
    local attr_key = Config.AttrData.data_id_to_key[attr_id]
    return commonGetAttrInfoByKeyValue(attr_key, attr_val)
end

--获取属性对应信息 
-- @attr_key  策划定义属性key 参考表attr_data.xml
-- @attr_val  对应值..如果是百分比 传过来的是千分比
--return 属性icon路径, 属性名字, 属性值
function commonGetAttrInfoByKeyValue(attr_key, attr_val)
    if not attr_key or not attr_val then return end
    local attr_name = Config.AttrData.data_key_to_name[attr_key]
    if attr_name then
        local icon = PathTool.getAttrIconByStr(attr_key)
        local is_per = PartnerCalculate.isShowPerByStr(attr_key)
        if is_per == true then
            attr_val = (attr_val/10).."%"
        end
        local res = PathTool.getResFrame("common", icon)
        
        return res, attr_name, attr_val
    end
end

--通用显示空白
--@parent 父类
--@bool 显示状态 true 显示 , false 不显示
--@setting 配置信息
--setting.text  文本内容 默认: 暂无数据
--setting.pos  icon显示位置  默认 父类的中心点
--setting.scale  icon缩放大小  默认 1
--setting.offset_y 因图标缩放导致文本的位置需要调整 偏移量调整 默认是 -10
--setting.font_size 文本大小 默认 26
--setting.label_color 文本颜色 默认 Config.ColorData.data_color4[175]
function commonShowEmptyIcon(parent, bool, setting)
    if not parent then return end
    if bool then
        local setting = setting or {}
        local text = setting.text or TI18N("暂无数据")

        if not parent.empty_con then
            local parent_size = parent:getContentSize()    
            local pos = setting.pos or cc.p(parent_size.width * 0.5, parent_size.height * 0.5 + 10)
            local scale = setting.scale or 1
            local offset_y = setting.offset_y or -10
            local label_color = setting.label_color or Config.ColorData.data_color4[175]
            local font_size   = setting.font_size or 26
            local size = cc.size(200, 200)    
            parent.empty_con = ccui.Widget:create()
            parent.empty_con:setContentSize(size)
            parent.empty_con:setAnchorPoint(cc.p(0.5, 0.5))
            parent.empty_con:setPosition(pos)

            parent:addChild(parent.empty_con, 10)
            local res = PathTool.getPlistImgForDownLoad('bigbg', 'bigbg_3')
            local bg = createImage(parent.empty_con, res, size.width / 2, size.height / 2, cc.p(0.5, 0.5), false)
            bg:setScale(scale)
            parent.empty_label = createLabel(font_size, label_color, nil, size.width / 2, offset_y, '', parent.empty_con, 0, cc.p(0.5, 0)) 
        else
            parent.empty_con:setVisible(true)
        end
        parent.empty_label:setString(text)
    else
        if parent.empty_con then
            parent.empty_con:setVisible(false)
        end
    end
end

--通用设置倒计时 时间格式默认   TimeTool.GetTimeForFunction 此方法返回格式(需要其他的 在callback 自行处理)
--注意: 关闭panel的时候记得 doStopAllActions(label) 否则会报错
--@label 倒计时对象 label 
--@less_time 剩余时间 
--@setting 配置信息
--setting.label_type  文本类型(参考 CommonAlert.type.rich) ..注意:需要增加标题 和 时间颜色 才设置这个(否则没意义)
--setitng.time_title  时间标题  eg: 剩余时间:
--setitng.time_color  时间颜色 格式: #ffffff 富文本下 需要变的颜色..(在is_rich_label == true下 必填)
--setting.callback 回调函数  如果_setTimeFormatString 不能满足需求 自己用回调函数处理
--setting.end_callback 结束回调函数  在time<=0 的时候会调用此方法
function commonCountDownTime(label, less_time, setting)
    if tolua.isnull(label) then return end
    local setting = setting or {}
    local callback = setting.callback --回调函数 
    local end_callback = setting.end_callback --回调函数 
    local label_type = setting.label_type --文本类型
    local end_title = setting.end_title or ""
    local time_title = setting.time_title or ""
    local time_color
    local string_format = string.format
    if label_type and label_type == CommonAlert.type.rich then
        time_color = setting.time_color
    end 

    local _setTimeFormatString = function(time)
        if tolua.isnull(label) then return end
        if callback then
            callback(time)
            return 
        end
        if label_type and label_type == CommonAlert.type.rich and time_color then
            if time > 0 then 
                label:setString(string_format("%s <div fontcolor=%s>%s</div>%s", time_title, time_color, TimeTool.GetTimeForFunction(time), end_title ))
            else
                doStopAllActions(label)
                label:setString(string_format("%s <div fontcolor=%s>00:00:00</div>%s", time_title, time_color, end_title ))
                if end_callback then
                    end_callback(time)
                end
            end
        else
            if time > 0 then
                label:setString(time_title .. TimeTool.GetTimeForFunction(time) .. end_title)
            else
                doStopAllActions(label)
                label:setString(time_title .. "00:00:00" .. end_title)
                if end_callback then
                    end_callback(time)
                end
            end
        end
    end
    doStopAllActions(label)
    if less_time > 0 then
        _setTimeFormatString(less_time)
        label:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
             _setTimeFormatString(less_time)
        end))))
    else
        _setTimeFormatString(less_time)
    end
end

--******** 设置倒计时
function setCountDownTime(node,less_time)
    if tolua.isnull(node) then return end
    doStopAllActions(node)

    local setTimeFormatString = function(time)
        if tolua.isnull(node) then return end
        if time > 0 then
            node:setString(TimeTool.GetTimeFormatDayII(time))
        else
            doStopAllActions(node)
            node:setString("00:00:00")
        end
    end
    if less_time > 0 then
        setTimeFormatString(less_time)
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(node)
                node:setString("00:00:00")
            else
                setTimeFormatString(less_time)
            end
        end))))
    else
        setTimeFormatString(less_time)
    end
end

-- 给阵营图标加上数量标识
function addCountForCampIcon( node, num_data )
    num_data = num_data or {}
    local top_num = num_data[1]
    local bottom_num = num_data[2]
    local bottom_num2 = num_data[3]
    if top_num and top_num > 0 then
        if not node.top_num_txt then
            local node_size = node:getContentSize()
            node.top_sp = createSprite(PathTool.getResFrame("common","common_90088"), node_size.width/2, node_size.height-15, node, cc.p(0.5, 0.5))
            node.top_num_txt = createLabel(20, cc.c4b(255,249,242,255), nil, node_size.width/2-1, node_size.height-15, top_num, node, nil, cc.p(0.5, 0.5))
        else
            node.top_num_txt:setString(top_num)
            node.top_num_txt:setVisible(true)
            node.top_sp:setVisible(true)
        end
    elseif node.top_num_txt then
        node.top_num_txt:setVisible(false)
        node.top_sp:setVisible(false)
    end
    if bottom_num and bottom_num > 0 then
        if not node.bottom_num_txt then
            local node_size = node:getContentSize()
            node.bottom_sp = createSprite(PathTool.getResFrame("common","common_90089"), node_size.width/2, 15, node, cc.p(0.5, 0.5))
            node.bottom_num_txt = createLabel(20, cc.c4b(255,249,242,255), nil, node_size.width/2-1, 15, bottom_num, node, nil, cc.p(0.5, 0.5))
        else
            node.bottom_num_txt:setString(bottom_num)
            node.bottom_num_txt:setVisible(true)
            node.bottom_sp:setVisible(true)
        end
    elseif node.bottom_num_txt then
        node.bottom_num_txt:setVisible(false)
        node.bottom_sp:setVisible(false)
    end

    if bottom_num2 and bottom_num2 > 0 then
        if not node.bottom_num_txt2 then
            local node_size = node:getContentSize()
            node.bottom_sp2 = createSprite(PathTool.getResFrame("common","common_90089"), 64, 22, node, cc.p(0.5, 0.5))
            node.bottom_sp2:setRotation(-45)
            node.bottom_num_txt2 = createLabel(20, cc.c4b(255,249,242,255), nil, 63, 21, bottom_num2, node, nil, cc.p(0.5, 0.5))
        else
            node.bottom_num_txt2:setString(bottom_num2)
            node.bottom_num_txt2:setVisible(true)
            node.bottom_sp2:setVisible(true)
        end
        if node.bottom_num_txt then
            local node_size = node:getContentSize()
            node.bottom_sp:setRotation(45)
            node.bottom_sp:setPosition(22, 22)
            node.bottom_num_txt:setPosition(20, 21)
        end

    elseif node.bottom_num_txt2 then
        node.bottom_num_txt2:setVisible(false)
        node.bottom_sp2:setVisible(false)

        if node.bottom_num_txt then
            local node_size = node:getContentSize()
            node.bottom_sp:setRotation(0)
            node.bottom_sp:setPosition(node_size.width/2, 15)
            node.bottom_num_txt:setPosition(node_size.width/2-1, 15)
        end
    end
end

--通用显示滚动字符串
--使用方法..因为要切割..必须 父类 layout 选择裁剪区域. 子类是label 父类的宽度就是裁剪区域 参考 MallItem 下的self.name_panel
--label -- label 对象
--setting 配置
--setting.content --显示文本的内容...如果有传就会设置 不传不会设置  
--setting.max_width -- 显示文本的最大宽度 默认 100
--setting.dir 位移方向  默认 1 (左边往右) -1 表示右往左 目前也只实现 1
--setting.label_type  参考类型 CommonAlert.type.common
--setting.start_x 初始位置 如果在scrollveiw会执行多次此方法的..一定要传
function commonShowRollStr(label, setting)
    if not label then return end
    local setting   = setting or {}
    local content   = setting.content
    local max_width = setting.max_width or 100
    local dir       =   setting.dir or 1
    local label_type = setting.label_type or CommonAlert.type.common
    --初始位置
    local start_x = setting.start_x or label:getPositionX()

    if content ~= nil and content ~= "" then
        label:setString(content)
    end

    local size 
    if label_type == CommonAlert.type.rich then
        size = label:getSize()
    else
        size = label:getContentSize()
    end
    label:setPositionX(start_x)
    doStopAllActions(label)
    if size.width > max_width then
        local x = (size.width - max_width) * dir
        local time = x * 0.02 -- 每个长度时间 0.02秒
        local delay_time = cc.DelayTime:create(2)
        local call_func = cc.CallFunc:create(function() label:setPositionX(start_x)  end)
        local move_by = cc.MoveBy:create(time, cc.p(-x, 0))
        local delay_time_1 = cc.DelayTime:create(2)
        label:runAction(cc.RepeatForever:create(cc.Sequence:create(delay_time, call_func, move_by, delay_time_1, call_func)))
    end
end

-- 文本内容超过一定长度后显示为 ...
function transformTextToShort( text, length )
    if not text or not length then return "" end

    if StringUtil.SubStringGetTotalIndex(text) > length then
        text = StringUtil.SubStringUTF8(text, 1, length)
        text = text.."..."
    end

    return text
end

-- 统一给文本设置内容
-- root_node 为根节点（或者所有text共同的父节点）
-- txt_list = {{text名称1，内容1},{text名称2，内容2}}}
-- 注意，需要保证 text名称 的唯一性
function setTextContentList(root_node, txt_list)
    if tolua.isnull(root_node) then return end
    if not txt_list or next(txt_list) == nil then return end
	for k, info in pairs(txt_list) do
		local txt_name = info[1]
		local name_str = info[2] or ""
		local txt_node = findNodeByName(root_node, txt_name)
		if txt_node then
			txt_node:setString(TI18N(name_str))
		end
	end
end

-- 属性变化飘字提示（固定为{"atk", "hp_max", "def", "speed"}四个属性）
function showAttrChangeAni( parent_node, attr_data, zorder )
    if not parent_node or tolua.isnull(parent_node) then return end

    zorder = zorder or 2

    if not parent_node.effect_widget then
        parent_node.effect_widget = ccui.Widget:create()
        parent_node.effect_widget:setCascadeOpacityEnabled(true)
        parent_node.effect_widget:setAnchorPoint(0,0)
        parent_node:addChild(parent_node.effect_widget, zorder)
        parent_node.level_label_list = {}
        local height = 25
        local _y = 50
        for i=1,4 do
            local x, y = -40, _y - height * (i-1) - height * 0.5
            local label = createLabel(20, cc.c3b(0x48,0xf4,0x50), cc.c3b(0x00,0x00,0x00), x, y, "", parent_node.effect_widget, 2, cc.p(0,0.5))
            parent_node.level_label_list[i] = label
        end
    end

    local key_list = {"atk", "hp_max", "def", "speed"}
    for i,attr_str in ipairs(key_list) do
        local value = attr_data[attr_str]
        local name = Config.AttrData.data_key_to_name[attr_str]
        if parent_node.level_label_list[i] then
            parent_node.level_label_list[i]:setString(string.format("%s + %s", name, value))
        end
    end
    parent_node.effect_widget:setVisible(true)
    parent_node.effect_widget:stopAllActions()
    parent_node.effect_widget:setPosition(-80,0)
    parent_node.effect_widget:setOpacity(10)
    local moveto = cc.MoveTo:create(0.2,cc.p(0,0))
    local fadein = cc.FadeIn:create(0.2)

    local movetoup = cc.EaseSineOut:create(cc.MoveTo:create(0.4,cc.p(0,10)))
    local spawn = cc.Spawn:create(moveto, fadein)
    parent_node.effect_widget:runAction(cc.Sequence:create(spawn,  movetoup ,cc.CallFunc:create( function() 
        parent_node.effect_widget:setVisible(false)
    end )))
end

--- 是否是马甲包,需要判断是否使用主包资源的
function isVestPackage()
    if IS_SPECIAL_UNION_CHANNEL == true then
        return true
    elseif IS_SY_UNION_SDK == true then
        local channel = device.getChannel()
        if channel == "46_1" or channel == "47_9" or channel == "16_30" or channel == "59_1" or channel == "60_1" or channel == "61_1" or channel == "63_1" then
            return true
        end
    end
    return false
end

--- 协议加检验 time == 当前服务端时间
function signProto(time)
    local str = string.format("sszg_key_%s", time)
    return cc.CCGameLib:getInstance():logsign(str)
end

function getVersionDesc()
    local ver1 = math.floor(MAIN_VERSION / 100)
    local ver2 = math.floor((MAIN_VERSION - ver1 * 100) / 10)
    return string.format("%s.%s", ver1, ver2)
end

--检查是否显示用户协议
--@ios_show_user_proto: ios 是否显示用户协议
function checkUserProto(ios_show_user_proto)
    if IS_IOS_PLATFORM then
        if ios_show_user_proto then
            return true --ios 显示用户协议
        else
            return false --ios 不显示用户协议
        end
    end
    
    --买量服、联运一、联运二都要显示  测试服服 和 稳定服 保留此界面测试
    if PLATFORM_NAME == "symlf" or PLATFORM_NAME == "symix" or PLATFORM_NAME == "symix2" or PLATFORM_NAME == "demo" or PLATFORM_NAME == "release2" then
        return true
    end
    return false
end

--打印配置信息
function commonDumpConfigData(table_name, sheet_name)
    -- Config.PartnerData.data_partner_star_table = {
    --     ["10201_2"] = [[{10201, 2, "H30018", 10201, 1000, 1000, 1000, 1000, {}, {}, {}, {}, {}, {{1,258001},{2,258101},{3,258201}}, 50, 0, 1, {{"等级上限:","50","50"}}, "", "", {}}]],
    --     ["10101_1"] = [[{10101, 1, "H30012", 10101, 1000, 1000, 1000, 1000, {}, {}, {}, {}, {}, {{1,259001},{2,259101}}, 40, 0, 1, {{"等级上限:","40","40"}}, "", "", {}}]]
    -- }
    -- Config.PartnerData.data_partner_brach = {
    --     ["4_101_0"] = {break_id=101, type=4, count=0, lev_max=30, add_hp=1000, add_atk=1000, add_def=1000, add_speed=1000, all_attr={}, skill_num=2, expend={{1,10000},{10001,50}}, get_item={}, limit={}},
    --     ["4_101_1"] = {break_id=101, type=4, count=1, lev_max=40, add_hp=1160, add_atk=1160, add_def=1000, add_speed=1000, all_attr={{'hp_max',200},{'atk',40},{'def',16},{'speed',10}}, skill_num=2, expend={{1,20000},{10001,100}}, get_item={{1,10000},{10001,50}}, limit={}}
    -- }
    table_name = "CombatHaloData"
    local string_format = string.format
    if Config[table_name] then
        -- if sheet_name then

        -- end
        print("-------------打印表数据: Config."..table_name.."---------------------")
        for key , val in pairs(Config[table_name]) do
            if type(val) == "table" then
                print(string_format("Config.%s.%s = {", table_name, key)) 
                for id, data in pairs(val) do
                    if type(data) ~= "table" then
                        print(string_format("[%s] = %s"))
                    else
                        local is_table  = true
                        for _,d in pairs(data) do
                            if type(d) ~= "table" then
                                is_table = false
                                break
                            end
                        end
                        if not is_table then
                            local line_str = commonGetConfigLine(data)
                            print(string_format("[%s] = %s", id, line_str))
                        end
                    end
                end
                print("}")
            end
        end
    else
        print("找不到配置名字: "..table_name)
    end
    -- body
end

function commonGetConfigLine(data)
    local str = "{"
    for k,v in pairs(data) do
        if type(v) == "table" then
            str = str..commonGetConfigLine(v)
        else
            str = str .. k.."="..v..", "
        end
    end
    return str.."}"
end

-- 该玩家是否支持扫一扫
function canAddScannig()
    if CAN_ADD_SCANNING == true then
        local login_data = LoginController:getInstance():getModel():getLoginData()
        if login_data == nil or login_data.usrName == "" then return false end
        local canshow = Config.QrcodeData.data_acc[login_data.usrName]
        Debug.info(canshow)
        return (canshow == TRUE)
    else
        return false
    end
end

--是否清明屏蔽(因为国家要求某些活动需要而做的操作) --by lwc
function isQingmingShield(is_in)
    if is_qingming_shield then
        if not is_in then
            message("功能维护中，暂时关闭，请谅解")
        end
        return true
    else
        return false
    end
end

function setQingmingShield(is_shield)
    is_qingming_shield = is_shield
end

-- 4.4 哀悼日
function needMourning()
    -- local cur_time = os.time()
    -- if cur_time >= 1585929600 and cur_time < 1586016000 then
        return false
    -- end
    -- return false
end
