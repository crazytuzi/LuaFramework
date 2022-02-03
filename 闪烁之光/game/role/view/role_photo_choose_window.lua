--**********文件说明************
 -- @Author:      hyx 
 -- @description: 
 -- @DateTime:    2020-02-28 17:27:34
 --***************************** 
RolePhotoChooseWindow = RolePhotoChooseWindow or BaseClass(BaseView)

function RolePhotoChooseWindow:__init(  )
    self.win_type = WinType.Tips
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "face/face_photo_choose"
end

function RolePhotoChooseWindow:open_callback()
    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 2)
    main_container:getChildByName("title_container"):getChildByName("title_label"):setString(TI18N("操作提示"))

    self.close_btn = main_container:getChildByName("close_btn")             -- 关闭按钮
    self.gallery_btn = main_container:getChildByName("gallery_btn")         -- 打开相册
    self.gallery_btn:getChildByName("label"):setString(TI18N("打开相册"))
    self.takephoto_btn = main_container:getChildByName("takephoto_btn")     -- 打开相机
    self.takephoto_btn:getChildByName("label"):setString(TI18N("打开照相机"))
end

function RolePhotoChooseWindow:register_event()
	-- 关闭按钮
    registerButtonEventListener(self.close_btn, function()
        RoleController:getInstance():openRolePhotoChooseWindow(false) 
    end, true, 1)
    --打开相册
    registerButtonEventListener(self.gallery_btn, function()
        local check_status_str = TencentCos:getInstance():getSecretid()
        if check_status_str and check_status_str ~= "" then
            callWebcamOpenPhotoGallery()
        else
            message(TI18N("数据异常,请关闭之后再做尝试"))
        end
    end, true, 1)
    --打开照相机
    registerButtonEventListener(self.takephoto_btn, function()
        local check_status_str = TencentCos:getInstance():getSecretid()
        if check_status_str and check_status_str ~= "" then
            callWebcamTakePhoto()
        else
            message(TI18N("数据异常,请关闭之后再做尝试"))
        end
    end, true, 1)

end
function RolePhotoChooseWindow:openRootWnd()

end
function RolePhotoChooseWindow:close_callback()
   RoleController:getInstance():openRolePhotoChooseWindow(false) 
end