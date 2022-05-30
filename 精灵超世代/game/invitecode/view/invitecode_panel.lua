--**************************
--我的邀请码
--**************************
local InviteCodeConst = {
    mySelf = 1,
    myFriend = 2,
    returnFriend = 3,
}
local controller = InviteCodeController:getInstance()
local model = controller:getModel()
InviteCodePanel = class("InviteCodePanel", function()
    return ccui.Widget:create()
end)

function InviteCodePanel:ctor()
    self.cur_index = nil
    self.view_list = {} --视图
    self:configUI()
    self:register_event()
end

function InviteCodePanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/invitecode_panel"))
    self:addChild(self.root_wnd)
    self:setPosition(-40,-84)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    local bg = self.main_container:getChildByName("bg")
    loadSpriteTexture(bg, PathTool.getPlistImgForDownLoad("bigbg/action","action_invitecode"), LOADTEXT_TYPE)

    self.btn_tips = self.main_container:getChildByName("btn_tips")
    self.btn_copy = self.main_container:getChildByName("btn_copy")
    self.btn_shard = self.main_container:getChildByName("btn_shard")
    self.invite_code = self.main_container:getChildByName("Image_17"):getChildByName("invite_code")
    self.invite_code:setString("")
    self.text_invitecode = self.main_container:getChildByName("text_invitecode")
    self.text_invitecode:setString("")
    local title_text = {TI18N("我的推荐码"),TI18N("已推荐好友"),TI18N("老友召回")}
    self.tab_title = {}
    for i=1,3 do
        local tab = {}
        tab.btn = self.main_container:getChildByName("tab_"..i)
        tab.normal = tab.btn:getChildByName("normal")
        tab.select = tab.btn:getChildByName("select")
        tab.select:setVisible(false)
        tab.title = tab.btn:getChildByName("title")
        tab.title:setTextColor(CommonButton_Color[1])
        tab.title:enableOutline(CommonButton_Color[4], 2)
        tab.title:setFontSize(24)
        tab.title:setString(title_text[i])
        tab.redpoint = tab.btn:getChildByName("redpoint")
        tab.redpoint:setVisible(false)
        tab.index = i
        self.tab_title[i] = tab
    end
    --判断回归活动是否开启
    local returnaction_isopen = ReturnActionController:getInstance():getModel():getActionIsOpen()
    if returnaction_isopen == 0 then
        self.tab_title[3].btn:setVisible(false)
    end

    self:tabChangeView(1)
    controller:requestProto()
end
function InviteCodePanel:tabChangeView(index)
    index = index or 1
    if self.cur_index == index then return end
    if self.cur_tab ~= nil then
        self.cur_tab.select:setVisible(false)
        self.cur_tab.title:setTextColor(CommonButton_Color[1])
    end
    self.cur_index = index

    self.cur_tab = self.tab_title[self.cur_index]
    if self.cur_tab ~= nil then
        self.cur_tab.select:setVisible(true)
        self.cur_tab.title:setTextColor(CommonButton_Color[2])
    end

    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(false)
        end
    end

    self.pre_panel = self:createSubPanel(self.cur_index)
    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(true)
        end
    end
end
function InviteCodePanel:createSubPanel(index)
    local panel = self.view_list[index]
    if panel == nil then
        if index == InviteCodeConst.mySelf then
            panel = InviteCodeMyPanel.new()
        elseif index == InviteCodeConst.myFriend then
            panel = InviteCodeFriendPanel.new()
        elseif index == InviteCodeConst.returnFriend then
            panel = InviteCodeReturnFriendPanel.new()
        end
        local size = self.main_container:getContentSize()
        panel:setPosition(cc.p(size.width/2,352))
        self.main_container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end
function InviteCodePanel:getInviteCodeData()
    local invite_code = model:getInviteCode()
    if invite_code then
        self.invite_code:setString(invite_code)
    else
        message(TI18N("获取邀请码失败"))
    end
end
--邀请人数
function InviteCodePanel:getAlreadyFriendNum()
    if self.text_invitecode then
        local num = model:getFirendNum()
        local str = string.format(TI18N("已邀请好友：%d人"),num or 0)
        self.text_invitecode:setString(str)
    end
end
function InviteCodePanel:register_event()
    if not self.get_invite_code_event then
        self.get_invite_code_event = GlobalEvent:getInstance():Bind(InviteCodeEvent.Get_InviteCode_Event,function()
            self:getInviteCodeData()
        end)
    end
    if not self.invite_code_bind_event then
        self.invite_code_bind_event = GlobalEvent:getInstance():Bind(InviteCodeEvent.InviteCode_BindRole_Event,function()
            self:getAlreadyFriendNum()
        end)
    end
    if not self.update_number_event then
        self.update_number_event = GlobalEvent:getInstance():Bind(InviteCodeEvent.InviteCode_BindRole_Updata_Event,function()
            self:getAlreadyFriendNum()
        end)
    end

    --老友回归红点
    if not self.return_redpoint_event then
        self.return_redpoint_event = GlobalEvent:getInstance():Bind(InviteCodeEvent.Return_InviteCode_Event,function()
            local status = model:getReturnRedPoint()
            if self.tab_title[3] and self.tab_title[3].redpoint then
                self.tab_title[3].redpoint:setVisible(status)
            end
        end)
    end
    --邀请红点
    if not self.updata_my_redpoint_event then
        self.updata_my_redpoint_event = GlobalEvent:getInstance():Bind(InviteCodeEvent.InviteCode_My_Event,function()
            local status = model:inviteRedPoint()
            if self.tab_title[1] and self.tab_title[1].redpoint then
                self.tab_title[1].redpoint:setVisible(status)
            end
        end)
    end
    -----------------------------------

    registerButtonEventListener(self.btn_tips, function(param,sender, event_type)
        local config = Config.InviteCodeData.data_const.tips.desc
        TipsManager:getInstance():showCommonTips(config, sender:getTouchBeganPosition(),nil,nil,500)
    end,false, 1)
    registerButtonEventListener(self.btn_copy, function()
        self:copyCode()
    end,true, 1)
    registerButtonEventListener(self.btn_shard, function()
        if FINAL_CHANNEL == "syios_smzhs" then
            message(TI18N("暂不支持"))
            return
        end
        self:setShardGame()

    end,true, 1)

    for i,v in pairs(self.tab_title) do
        registerButtonEventListener(v.btn, function()
            self:tabChangeView(v.index)
        end,false, 1)
    end
end
function InviteCodePanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end

--分享游戏下载和邀请码
function InviteCodePanel:setShardGame()
    if not IS_IOS_PLATFORM and callFunc("checkWrite") == "false" then return end
    -- 如果存在不处理
    if self.sp then return end
    controller:sender10929()
    local container = ViewManager:getInstance():getLayerByTag( ViewMgrTag.LOADING_TAG )
    self.sp = createSprite("", SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5, container, cc.p(0.5, 0.5))

    self.layout = ccui.Layout:create()
    self.layout:setContentSize(cc.size(720, 150))
    self.layout:setAnchorPoint(cc.p(0.5, 0))
    self.layout:setPosition(360, display.getBottom())
    -- showLayoutRect(self.layout, 155)
    container:addChild(self.layout)

    local role_vo = RoleController:getInstance():getRoleVo()
    local apk_data = RoleController:getInstance():getApkData()
    
    local res = PathTool.getWelfareBannerRes("txt_cn_welfare_bg2")
    self.sprite_load = createResourcesLoad(res, ResourcesType.single, function()
        if not tolua.isnull(self.sp) then
            loadSpriteTexture(self.sp, res , LOADTEXT_TYPE)
            self.sp:setScale(display.getMaxScale())

            if IS_NEED_SHOW_LOGO ~= false then
                local logo_spr = createSprite(PathTool.getLogoRes(), 570*display.getMinScale(), 1200,self.sp,cc.p(0.5, 0.5),LOADTEXT_TYPE)
                logo_spr:setScale(0.45)    
            end
            
            self.head = PlayerHead.new(PlayerHead.type.circle)
            self.head:setAnchorPoint(0.5,0.5)
            self.head:setPosition(102,67)
            self.head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
            self.layout:addChild(self.head)

            local role_name = createLabel(30,cc.c4b(0xff,0xe4,0xba,0xff),nil,161,89,TI18N(role_vo.name),self.layout,2, cc.p(0,0.5))
    
            local server_name = createLabel(27,cc.c4b(0xf6,0xc9,0x8d,0xff),nil,161,40,TI18N("服务器: ")..role_vo.srv_id,self.layout,2, cc.p(0,0.5))
            local login_data = LoginController:getInstance():getModel():getLoginData()
            if login_data then
                server_name:setString(TI18N("服务器: ")..login_data.srv_name)
            end

            local shard_text = createLabel(27,cc.c4b(0xf6,0xc9,0x8d,0xff),nil,SCREEN_WIDTH-50,40,TI18N("我的分享码: "),self.layout,2, cc.p(1,0.5))
            local invite_code = InviteCodeController:getInstance():getModel():getInviteCode()
            shard_text:setString(string.format(TI18N("我的分享码: %s"),invite_code))

            local erweima_res = PathTool.getWelfareBannerRes("txt_cn_welfare_bg3")
            local erweima_bg = createSprite(erweima_res, 220*display.getMaxScale(), 270, self.sp, cc.p(0.5, 0.5),LOADTEXT_TYPE)
      
            self.er_wei_ma = createSprite(nil, 218*display.getMaxScale(), 260, self.sp, cc.p(0.5, 0.5))
            if PLATFORM_NAME == "demo" then
                loadSpriteTexture(self.er_wei_ma, PathTool.getWelfareBannerRes("txt_cn_welfare_bg4"), LOADTEXT_TYPE)
                local size = self.er_wei_ma:getContentSize()
                local scale = 220/size.width
                self.er_wei_ma:setScale(scale)
            end
            if apk_data then
                download_qrcode_png(apk_data.message.qrcode_url,function(code, filepath)
                    if not tolua.isnull(self.er_wei_ma) then
                        if code == 0 then
                            loadSpriteTexture(self.er_wei_ma, filepath, LOADTEXT_TYPE)
                            local size = self.er_wei_ma:getContentSize()
                            local scale = 220/size.width
                            self.er_wei_ma:setScale(scale)
                        end
                    end
                end)
            end

            local fileName = cc.FileUtils:getInstance():getWritablePath().."GameShard.png"
            delayOnce(function()
                cc.utils:captureScreen(function(succeed)
                    if succeed then
                        saveImageToPhoto(fileName,1)
                    else
                        message(TI18N("保存失败"))
                    end
                    if self.head then
                        self.head:DeleteMe()
                        self.head = nil
                    end
                    if not tolua.isnull(self.sp) then
                        self.sp:removeFromParent()
                        self.sp = nil
                    end
                    if not tolua.isnull(self.layout) then
                        self.layout:removeFromParent()
                        self.layout = nil
                    end
                end, fileName)
            end, 1.5)
        end
    end,self.sprite_load)
end
--复制邀请码
function InviteCodePanel:copyCode()
    local invite_code = model:getInviteCode()
    if invite_code then
        if cc.Device.copyText then
            cc.Device:copyText(invite_code)
            message(TI18N("推荐码已复制成功"))
        else
            message(TI18N("复制失败"))
        end 
    else
        message(TI18N("复制推荐码失败"))
    end
end

function InviteCodePanel:DeleteMe()
    if self.sprite_load then
        self.sprite_load:DeleteMe()
    end
    self.sprite_load = nil 

    if not tolua.isnull(self.sp) then
        self.sp:removeFromParent()
        self.sp = nil
    end
    if not tolua.isnull(self.layout) then
        self.layout:removeFromParent()
        self.layout = nil
    end
    for i,v in pairs(self.view_list) do 
        if v and v["DeleteMe"] then
            v:DeleteMe()
        end
    end
    self.view_list = nil
    if self.get_invite_code_event then
        GlobalEvent:getInstance():UnBind(self.get_invite_code_event)
        self.get_invite_code_event = nil
    end
    if self.invite_code_bind_event then
        GlobalEvent:getInstance():UnBind(self.invite_code_bind_event)
        self.invite_code_bind_event = nil
    end
    if self.update_number_event then
        GlobalEvent:getInstance():UnBind(self.update_number_event)
        self.update_number_event = nil
    end

    if self.return_redpoint_event then
        GlobalEvent:getInstance():UnBind(self.return_redpoint_event)
        self.return_redpoint_event = nil
    end
    if self.updata_return_redpoint_event then
        GlobalEvent:getInstance():UnBind(self.updata_return_redpoint_event)
        self.updata_return_redpoint_event = nil
    end
    if self.updata_my_redpoint_event then
        GlobalEvent:getInstance():UnBind(self.updata_my_redpoint_event)
        self.updata_my_redpoint_event = nil
    end
end