-- @Author: lwj
-- @Date:   2019-07-15 21:40:32
-- @Last Modified time: 2019-07-15 21:40:34

RoleIcon = RoleIcon or class("RoleIcon", BaseWidget)
local RoleIcon = RoleIcon

function RoleIcon:ctor(parent_node, layer)
    self.abName = "system"
    self.assetName = "RoleIcon"
    self.layer = layer

    self.default_title = "img_role_head_"
    self.default_sex = RoleInfoModel.GetInstance():GetSex()
    self.is_first_in = true
    self.is_full_cut = false
    self.defa_boy_name = 11
    self.defa_girl_name = 21

    local pnode = parent_node
    local str = ""
    while not IsNil(pnode) do
        str = string.format("%s/%s", pnode.name, str)
        pnode = pnode.parent
    end
    self.path_str = str

    BaseWidget.Load(self)
end

function RoleIcon:dctor()
    if self.update_frame_event_id then
        GlobalEvent:RemoveListener(self.update_frame_event_id)
        self.update_frame_event_id = nil
    end
    AvatarManager:GetInstance():RemoveTakePhotoRef(self)
    AvatarManager:GetInstance():RemoveGetOssImageRef(self)
    if self.event_id ~= nil then
        RoleInfoModel.GetInstance():GetMainRoleData():RemoveListener(self.event_id)
        self.event_id = nil
    end

    self:ClearSprite()
end

function RoleIcon:LoadCallBack()
    self.nodes = {
        "c_mask/c_role_icon", "frame", "c_mask", "s_mask/s_role_icon", "s_mask",
    }
    self:GetChildren(self.nodes)
    self.c_icon = GetImage(self.c_role_icon)
    self.s_icon = GetImage(self.s_role_icon)
    self.frame = GetImage(self.frame)
    self.c_mask_rect = GetRectTransform(self.c_mask)
    self.s_mask_rect = GetRectTransform(self.s_mask)
    self.c_icon_rect = GetRectTransform(self.c_role_icon)
    self.s_icon_rect = GetRectTransform(self.s_role_icon)
    self.frame_rect = GetRectTransform(self.frame)

    self.c_mask_img = GetImage(self.c_mask)
    self.s_mask_img = GetImage(self.s_mask)
end

--[[
    size______________________图标大小，默认120(实际上这是Mask的大小)
    is_squared________________是不是方的，默认圆的
    is_hide_mask______________是否不使用遮罩
    role_data:___________________角色数据，默认用自己的role_data
    outside_set_img_cb________设置好图片后执行（只有自定义头像设置时）
    uploading_cb______________通知服务器成功时执行（只是设置头像的时候需要传）
    is_hide_frame_____________是否隐藏框体
    is_show_defa_frame________是否只显示默认样式的框体，不显示自定义的头像框
    frame_ab_name_____________头像框体的ab_name,目前只支持圆形
    is_can_click______________能否点击（必须传点击事件:click_fun）
    cut_size__________________裁剪出来的图片大小,default_size:300
    is_set_frame_scale________头像框是否需要自适应缩放,
    high_quality______________显示 有半个身体的头像

    function:
    GetIcon()_______________下载自定义头像,这里开始的时候会执行一次执行
    SetIcon()_______________上传头像
--]]
function RoleIcon:SetData(param)
    self.size = param["size"] or 120
    local temp_role_data = param['role_data'] or RoleInfoModel.GetInstance():GetMainRoleData()
    self.role_data = clone(temp_role_data)
    self.role_data.id = self.role_data.id or self.role_data.uid
    self.outside_set_img_cb = param['set_img_cb']
    self.uploading_cb = param['uploading_cb']
    self.is_squared = param.is_squared
    self.frame_ab_name = param['frame_ab_name']
    self.frame_res_name = param['frame_res_name']
    self.is_hide_frame = param['is_hide_frame']
    self.is_show_defa_frame = param['is_show_defa_frame']
    self.is_can_click = param['is_can_click']
    self.click_fun = param['click_fun']
    self.is_set_frame_scale = param["is_set_frame_scale"]
    self.cut_size = param.cut_size or 300
    self.high_quality = param.high_quality
    self.is_hide_mask = param.is_hide_mask
    self:InitPanel()
    self:AddEvent()
end

function RoleIcon:AddEvent()
    if not self.is_first_in then
        return
    end
    self.is_first_in = false
    if self.is_can_click then
        if not self.click_fun then
            Notify.ShowText("No tapping event has been uploaded")
            return
        end
        AddClickEvent(self.icon.gameObject, self.click_fun)
    end

    local function callback()
        self:CheckItemExist()
        if not self.is_self_icon or not self.is_loaded then
            return
        end
        local temp_role_data = RoleInfoModel.GetInstance():GetMainRoleData()
        self.role_data = clone(temp_role_data)
        self:InitIconShow()
        self:SetIconSize()
    end
    self.event_id = RoleInfoModel.GetInstance():GetMainRoleData():BindData("icon", callback)

    local function callback(frame_id)
        self:CheckItemExist()
        local role_id = RoleInfoModel.GetInstance():GetMainRoleId()
        if role_id ~= self.role_data.id or self.is_show_defa_frame then
            return
        end
        --local icon_id = self.role_data.icon.frame == 0 and 110000 or self.role_data.icon.frame
        local icon_id = frame_id
        --if self.role_data.icon.frame ~= 0 then
        lua_resMgr:SetImageTexture(self, self.frame, "iconasset/icon_chatframe", icon_id, true, nil, false)
        self:UpdateFrameShow(frame_id)
        --end
    end
    self.update_frame_event_id = GlobalEvent:AddListener(RoleInfoEvent.UpdateRoleIconFrame, callback)
end

function RoleIcon:InitPanel()
    self.default_sex = self.role_data.gender
    local id = RoleInfoModel.GetInstance():GetMainRoleId()
    self.is_self_icon = true
    if id ~= self.role_data.id then
        self.is_self_icon = false
    end
    self.hide_mask = self.is_squared and self.c_mask or self.s_mask
    SetVisible(self.hide_mask, false)
    self.icon = self.is_squared and self.s_icon or self.c_icon

    --有自定义头像的 先加载默认男女头像
    local icon_name = self.role_data.gender == 2 and self.defa_girl_name or self.defa_boy_name

    local function callBack(sprite)
        self.icon.sprite = sprite

        self:InitIconShow()
        self:SetIconSize()
    end
    lua_resMgr:SetImageTexture(self, self.icon, "main_image", icon_name .. "", true,callBack)

    self.icon_rect = self.is_squared and self.s_icon_rect or self.c_icon_rect
    self.mask_rect = self.is_squared and self.s_mask_rect or self.c_mask_rect
    --是否使用遮罩
    local using_img = self.is_squared and self.s_mask_img or self.c_mask_img
    using_img.enabled = not self.is_hide_mask
end

function RoleIcon:InitIconShow()
    self:CheckItemExist()
    if not self.role_data.icon or self.role_data.icon.pic == "" then
        --没有自定义头像
        self.role_data.icon = {}
        self.role_data.icon.pic = self.role_data.gender == 2 and self.defa_girl_name or self.defa_boy_name
        self.role_data.icon.md5 = ""
    end
    local pic = self.role_data.icon.pic
    local len = string.len(pic)
    --文件名位数小于15（本地头像）
    if len < 15 then
        --加载默认头像
        self.file_name = string.gsub(pic, "%.png", "")
        local head_str = ""
        if self.high_quality then
            head_str = "high_quality_"
        end
        local head_res = self.file_name
        lua_resMgr:SetImageTexture(self, self.icon, "main_image", head_str .. head_res, true)
    else
        self.is_full_cut = true
        -- self.file_name = self.role_data.id
        self.file_name = pic
        self:GetIcon()
    end
end

function RoleIcon:SetIconSize()
    --if self.is_squared then
    self.is_full_cut = true
    --end
    local size = self.size
    local frame_size = (size * 28) / 11
    SetSizeDelta(self.frame_rect, frame_size, frame_size)
    --else
    local p_icon = self.role_data.icon
    if self.is_squared then
        --有头像框
        local frame = 110000
        local role_id = self.role_data.id
        local is_fake = faker.GetInstance():is_fake(role_id)
        if is_fake then
            local opdays = LoginModel.GetInstance():GetOpenTime()
            local cf = Config.db_robot_deco[opdays]
            if cf then
                local icon_list = String2Table(cf.icon)
                local list_num = #icon_list
                local idx = math.random(list_num)
                frame = icon_list[idx]
            end
        else
            frame = p_icon.frame == 0 and 110000 or p_icon.frame
            frame = self.is_show_defa_frame and 110000 or p_icon.frame
        end
        frame = frame == 0 and 110000 or frame
        lua_resMgr:SetImageTexture(self, self.frame, "iconasset/icon_chatFrame", frame, true, nil, false)
        self:UpdateFrameShow(p_icon.frame)
    else
        if self.frame_ab_name then
            if not self.frame_res_name then
                Notify.ShowText("Rame_res_name fail to send")
                return
            end
            lua_resMgr:SetImageTexture(self, self.frame, self.frame_ab_name, self.frame_res_name, true, nil, false)
        end
    end
    SetVisible(self.frame, not self.is_hide_frame)
    --self.mask_img.enabled = not self.is_squared
    --local mask_ab_name = self.is_squared and "role_squared_mask" or "role_icon_mask"
    --lua_resMgr:SetImageTexture(self, self.mask_img, "main_image", mask_ab_name, true, nil, false)
    local icon_size = size
    if not self.is_full_cut then
        icon_size = (size * 5) / 4
    end
    SetSizeDelta(self.mask_rect, size, size)
    SetSizeDelta(self.icon_rect, icon_size, icon_size)
end

function RoleIcon:GetIcon()
    AvatarManager:GetInstance():GetOssImage(self, handler(self, self.SetImgCallBack), self.file_name, self.role_data.icon.md5)
end

function RoleIcon:ClearSprite()
    if self.role_icon_texture then
        destroy(self.role_icon_texture)
        self.role_icon_texture = nil
    end
    if self.role_icon_sprite then
        destroy(self.role_icon_sprite)
        self.role_icon_sprite = nil
    end
end

function RoleIcon:SetImgCallBack(sprite,texture)
    if self.is_dctored then
        return
    end

    self:ClearSprite()
    self.role_icon_texture = texture
    self.role_icon_sprite = sprite

    if sprite then
        if not self.icon then
            self.icon = self.is_squared and self.s_icon or self.c_icon
        end
        self.icon.sprite = sprite
    end
    if self.outside_set_img_cb then
        self.outside_set_img_cb(sprite)
    end
end

function RoleIcon:UploadingCallBack(file_name, md5)
    RoleInfoController.GetInstance():RequestSetIcon(file_name, md5)
    if self.uploading_cb then
        self.uploading_cb(file_name, md5)
    end
end

--上传自定义头像
function RoleIcon:SetIcon()
    self.file_name = self.role_data.id
    local channel_id = LoginModel:GetInstance():GetChannelId()
    local channel_id_dir = channel_id .. "_"
    local file_name = channel_id_dir .. self.file_name
    AvatarManager:GetInstance():TakePhoto(self, handler(self, self.SetImgCallBack), handler(self, self.UploadingCallBack), 2, file_name .. ".png", self.cut_size, self.cut_size)
end

--设置本地头像
--图片id即可，不带后缀
function RoleIcon:SetLocalIcon(pic_name)
    RoleInfoController.GetInstance():RequestSetIcon(pic_name .. ".png", "")
end

--头像置灰/恢复正常
function RoleIcon:SetIconGray(is_gray)
    if is_gray then
        ShaderManager:GetInstance():SetImageGray(self.c_icon)
        ShaderManager:GetInstance():SetImageGray(self.s_icon)
    else
        ShaderManager:GetInstance():SetImageNormal(self.c_icon)
        ShaderManager:GetInstance():SetImageNormal(self.s_icon)
    end
end

function RoleIcon:UpdateFrameShow(id)
    local show_cf = FrameShowConfig.IconFrame[id]
    if show_cf then
        local x = show_cf.pos_x or 0
        local y = show_cf.pos_y or 0
        SetLocalPosition(self.frame.transform, x, y, 0)
    end
end

function RoleIcon:CheckItemExist()
    if IsGameObjectNull(self.gameObject) then
        logError(string.format("未释放的RoleIocn:%s", self.path_str))
        self:destroy();
        return
    end
end