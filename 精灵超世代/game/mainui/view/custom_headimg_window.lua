-- -------------------------------------------------
-- @author: Shiraho
--     自定义头像界面
-- <br/>Create: 2020-02-27-14:30:30
-- -------------------------------------------------
CustomHeadImgWindow = CustomHeadImgWindow or BaseClass(BaseView)

local controller = MainuiController:getInstance()
local table_insert = table.insert
local string_format = string.format

function CustomHeadImgWindow:__init(  )
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "mainui/custom_headimg_window"
    self.update_load_file = ""
end

function CustomHeadImgWindow:open_callback()
    local background = self.root_wnd:getChildByName("background")
    background:setTouchEnabled(true)
    background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 2) 
    main_container:getChildByName("title_container"):getChildByName("title_label"):setString(TI18N("自定义头像预览"))

    local head_node = main_container:getChildByName("head_node")
    self.player_head = PlayerHead.new(PlayerHead.type.circle)
    head_node:addChild(self.player_head)

    self.close_btn = main_container:getChildByName("close_btn")             -- 关闭按钮
    self.gallery_btn = main_container:getChildByName("gallery_btn")         -- 打开相册
    self.gallery_btn:getChildByName("label"):setString(TI18N("打开相册"))
    
    self.takephoto_btn = main_container:getChildByName("takephoto_btn")     -- 打开相机
    self.takephoto_btn:getChildByName("label"):setString(TI18N("打开相机"))

    self.upload_btn = main_container:getChildByName("upload_btn")           -- 确定申请
    self.upload_btn:getChildByName("label"):setString(TI18N("确定上传"))

    self.docs_label = main_container:getChildByName("Text_1")
    self.docs_label:setString(TI18N("当前你的头像"))
end

function CustomHeadImgWindow:register_event()
    -- 关闭按钮
    registerButtonEventListener(self.close_btn, function()
        controller:openCustomHeadImgWin(false)
    end, true, 1)

    -- 打开相册
    registerButtonEventListener(self.gallery_btn, function()
        local check_status_str = TencentCos:getInstance():getSecretid()
        if check_status_str and check_status_str ~= "" then
            callWebcamOpenPhotoGallery()
        else
            message(TI18N("数据异常,请关闭之后再做尝试"))
        end
    end, true, 1)

    -- 打开相机
    registerButtonEventListener(self.takephoto_btn, function()
        local check_status_str = TencentCos:getInstance():getSecretid()
        if check_status_str and check_status_str ~= "" then
            callWebcamTakePhoto()
        else
            message(TI18N("数据异常,请关闭之后再做尝试"))
        end
    end, true, 1)

    -- 提交申请
    registerButtonEventListener(self.upload_btn, function()
        -- 这个时候要通知服务端,进入审核状态,审核回来之后通知服务端审核完成
        if self.update_load_file == "" then
            message(TI18N("请选择需要上传的照片"))
        else
            if self.role_vo.custom_face_file ~= "" then
                TencentCos:getInstance():upLoadHeadFile(self.role_vo.custom_face_file, self.update_load_file)
            end
            controller:openCustomHeadImgWin(false)
        end
    end, true, 1)

    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key,value)
                if key == "face_file" or key == "face_update_time" or key == "custom_face_file" then
                    if self.player_head then
                        self.player_head:setHeadRes(self.role_vo.face_id, false, LOADTEXT_TYPE, self.role_vo.face_file, self.role_vo.face_update_time)              
                    end
                end
            end)
        end
    end
end

function CustomHeadImgWindow:openRootWnd()
    self.role_vo = RoleController:getInstance():getRoleVo()
    self.player_head:setHeadRes(self.role_vo.face_id, false, LOADTEXT_TYPE, self.role_vo.face_file, self.role_vo.face_update_time)
end

-- 更新待上传的头像,注意这个时候的头像还是系统目录的,外部调用
function CustomHeadImgWindow:updateSelectHeadImg(path)
    -- 这个时候要先移除掉当前持有的内存数据
    display.removeImage(path)

    self.docs_label:setString(TI18N("是否上传并使用该自定义头像"))
    
    self.update_load_file = path
    self.player_head:setHeadRes(path, true)
end

function CustomHeadImgWindow:close_callback()
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end
    controller:openCustomHeadImgWin(false)
end