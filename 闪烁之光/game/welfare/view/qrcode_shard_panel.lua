--
-- 二维码分享
--
QRcodeShardPanel = class("QRcodeShardPanel", function()
    return ccui.Widget:create()
end)

function QRcodeShardPanel:ctor()
	self.er_wei_ma = nil
	self.copyData = nil
    self.qrCodeImage = nil
    self:configUI()
	self:register_event()
end

function QRcodeShardPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/qrcode_shard_panel"))
    self:addChild(self.root_wnd)
    self:setPosition(-40,-161)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.savePhoto = self.main_container:getChildByName("savePhoto")
    self.savePhoto:setPosition(204,355)
    self.savePhoto:setVisible(true)
    if SAVE_IMAGE_PHOTO == true then
        self.savePhoto:setVisible(true)
    end
	self.savePhoto:getChildByName("Text_2"):setString(TI18N("保存至相册"))
	self.copyURL = self.main_container:getChildByName("copyURL")
    self.copyURL:setPosition(613,175)
	self.copyURL:getChildByName("Text_2"):setString(TI18N("复制链接"))

    self.bg = self.main_container:getChildByName("bg")
    local res = PathTool.getWelfareBannerRes("txt_cn_welfare_bg1")
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.bg) then
    			loadSpriteTexture(self.bg, res , LOADTEXT_TYPE)
    		end
    	end,self.item_load)
    end
    if IS_NEED_SHOW_LOGO ~= false then
        local logo_spr = createSprite(PathTool.getLogoRes(), 100, 869,self.main_container,cc.p(0.5, 0.5),LOADTEXT_TYPE)
        logo_spr:setScale(0.4)
    end
    self.er_wei_ma = createSprite(nil, 193, 545, self.main_container, cc.p(0.5, 0.5))
    if PLATFORM_NAME == "demo" then
        loadSpriteTexture(self.er_wei_ma, PathTool.getWelfareBannerRes("txt_cn_welfare_bg4"), LOADTEXT_TYPE)
        local size = self.er_wei_ma:getContentSize()
        local scale = 260/size.width
        self.er_wei_ma:setScale(scale)
    end
    local apk_data = RoleController:getInstance():getApkData()
    if apk_data then
        download_qrcode_png(apk_data.message.qrcode_url,function(code, filepath)
            if not tolua.isnull(self.er_wei_ma) then
                if code == 0 then
                    loadSpriteTexture(self.er_wei_ma, filepath, LOADTEXT_TYPE)
                    self.qrCodeImage = filepath
                end

                local size = self.er_wei_ma:getContentSize()
                local scale = 260/size.width
                self.er_wei_ma:setScale(scale)
            end
        end)
    end

    local url_panel = self.main_container:getChildByName("url_panel")
    self.textURL = url_panel:getChildByName("textURL")

    get_apk_url(function(data)
        if not tolua.isnull(self.textURL) then
        	self.copyData = data
            if data and data.success == true and data.message then
                if SHOW_APK_URL then
                    self.copyData.message.url = SHOW_APK_URL
                end
                if data.message.url then
                    self.textURL:setString(data.message.url)
                end
            else
            	self.textURL:setString(TI18N("获取链接失败"))
            end
        end
    end)
end

function QRcodeShardPanel:register_event()
    registerButtonEventListener(self.savePhoto, function()
        if FINAL_CHANNEL == "syios_smzhs" then
            message(TI18N("暂不支持"))
            return
        end
        self:setShardGame()
    end,true, 1)

    registerButtonEventListener(self.copyURL, function()
        if self.copyData and self.copyData.success == true and self.copyData.message and self.copyData.message.url then
            local copyStr = self.copyData.message.url
            if cc.Device.copyText then
                cc.Device:copyText(copyStr)
                message(TI18N("下载地址已复制成功"))
            else
                message(TI18N("复制失败"))
            end 
        else
            message(TI18N("复制链接失败"))
        end
    end,true, 1)
end
--分享游戏下载和邀请码
function QRcodeShardPanel:setShardGame()
    if PLATFORM_NAME == "demo" then
        self.qrCodeImage = PathTool.getWelfareBannerRes("txt_cn_welfare_bg4")
    end
    if not self.qrCodeImage then
        message(TI18N("二维码正在生成中......"))
        return
    end
    if not IS_IOS_PLATFORM and callFunc("checkWrite") == "false" then return end
    -- 如果存在不处理
    if self.sp then return end
    local container = ViewManager:getInstance():getLayerByTag( ViewMgrTag.LOADING_TAG )
    self.sp = createSprite("", SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5, container, cc.p(0.5, 0.5))
    self.sp:setScale(display.getMaxScale())

    self.layout = ccui.Layout:create()
    self.layout:setContentSize(cc.size(720, 150))
    self.layout:setAnchorPoint(cc.p(0.5, 0))
    self.layout:setPosition(360, display.getBottom())
    -- showLayoutRect(self.layout, 155)
    container:addChild(self.layout)

    local role_vo = RoleController:getInstance():getRoleVo()
    self.head = PlayerHead.new(PlayerHead.type.circle)
    self.head:setAnchorPoint(0.5,0.5)
    self.head:setPosition(102,67)
    self.head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
    self.layout:addChild(self.head)
    self.head:setVisible(false)

    local border_res = PathTool.getWelfareBannerRes("txt_cn_welfare_bg3")

    local role_name = createLabel(30,cc.c4b(0xff,0xe4,0xba,0xff),nil,161,89,TI18N(role_vo.name),self.layout,2, cc.p(0,0.5))
    role_name:setVisible(false)
    local server_name = createLabel(27,cc.c4b(0xf6,0xc9,0x8d,0xff),nil,161,40,TI18N("服务器: ")..role_vo.srv_id,self.layout,2, cc.p(0,0.5))
    server_name:setVisible(false)
    local login_data = LoginController:getInstance():getModel():getLoginData()
    if login_data then
        server_name:setString(TI18N("服务器: ")..login_data.srv_name)
    end

    local shard_text = createLabel(27,cc.c4b(0xf6,0xc9,0x8d,0xff),nil,SCREEN_WIDTH-50,40,TI18N("我的分享码: "),self.layout,2, cc.p(1,0.5))
    shard_text:setVisible(false)
    local invite_code = InviteCodeController:getInstance():getModel():getInviteCode()
    shard_text:setString(string.format(TI18N("我的分享码: %s"),invite_code))

    local res = PathTool.getWelfareBannerRes("txt_cn_welfare_bg2")
    self.sprite_load = createResourcesLoad(res, ResourcesType.single, function()
        if not tolua.isnull(self.sp) then
            loadSpriteTexture(self.sp, res , LOADTEXT_TYPE)

            if IS_NEED_SHOW_LOGO ~= false then
                local logo_spr = createSprite(PathTool.getLogoRes(), 570*display.getMinScale(), 1200,self.sp,cc.p(0.5, 0.5),LOADTEXT_TYPE)
                logo_spr:setScale(0.5)
            end
            self.head:setVisible(true)
            role_name:setVisible(true)
            server_name:setVisible(true)
            shard_text:setVisible(true)

            local erweima_bg = createSprite(border_res, 220*display.getMaxScale(), 270, self.sp, cc.p(0.5, 0.5),LOADTEXT_TYPE)
            
            local erweima = createSprite(self.qrCodeImage, 218*display.getMaxScale(), 260, self.sp, cc.p(0.5, 0.5),LOADTEXT_TYPE)
            local size = erweima:getContentSize()
            local scale = 220/size.width
            erweima:setScale(scale)

            local fileName = cc.FileUtils:getInstance():getWritablePath().."GameShard.png"
            delayOnce(function()
                cc.utils:captureScreen(function(succeed)
                    if succeed then
                        saveImageToPhoto(fileName,2)
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

function QRcodeShardPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == true then
        InviteCodeController:getInstance():sender19800()
    end 
end

function QRcodeShardPanel:DeleteMe()
    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil

    if not tolua.isnull(self.layout) then
        self.layout:removeFromParent()
        self.layout = nil
    end

    if self.sprite_load then
        self.sprite_load:DeleteMe()
    end
    self.sprite_load = nil

    if not tolua.isnull(self.sp) then
        self.sp:removeFromParent()
        self.sp = nil
    end
end

