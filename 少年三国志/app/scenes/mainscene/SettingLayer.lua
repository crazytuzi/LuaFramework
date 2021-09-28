--SettingLayer.lua

local function _updateLabel(target, name, params)
    
    local label = target:getLabelByName(name)
    if params.stroke ~= nil then
        label:createStroke(params.stroke, 1)
    end
    
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end
    
end

local function _updateImageView(target, name, params)

    local img = target:getImageViewByName(name)
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end
    
end

local function _updateWidget(target, name, params)
    
    local widget = target:getWidgetByName(name)
    
    if params.visible ~= nil then
        widget:setVisible(params.visible)
    end
    
end

local storage = require("app.storage.storage")
local FunctionLevelConst = require("app.const.FunctionLevelConst")

local SettingLayer = class("SettingLayer", UFCCSModelLayer)
local ComSdkUtils = require("upgrade.ComSdkUtils")

SettingLayer._max_music_volume_ = 0.7
SettingLayer._max_effect_volume_ = 1
SettingLayer._show_effect_enable = true

function SettingLayer.initDefaultSetting( ... )
	

	local info = storage.load(storage.path("setting.data"))
	local back_music_enable = not (info and info.back_music_enable == 0)
	local back_effect_enable = not (info and info.back_effect_enable == 0)

	__Log("music volume:%d, effect volume:%d", back_music_enable and SettingLayer._max_music_volume_ or 0, 
		back_effect_enable and SettingLayer._max_effect_volume_ or 0)
	G_SoundManager:setMusicVolume(back_music_enable and SettingLayer._max_music_volume_ or 0)
	G_SoundManager:setSoundsVolume(back_effect_enable and SettingLayer._max_effect_volume_ or 0)

	SettingLayer._show_effect_enable = not (info and info.show_view_effect_enable == 0)
	__Log("SettingLayer._show_effect_enable:%d", SettingLayer._show_effect_enable and 1 or 0)
end

function SettingLayer.showEffectEnable( ... )
	return SettingLayer._show_effect_enable
end

function SettingLayer.setEffectEnable( enabled )
	local info = storage.load(storage.path("setting.data")) or {}
    info.show_view_effect_enable = enabled and 1 or 0
    storage.save(storage.path("setting.data"), info)
    SettingLayer._show_effect_enable = enabled and true or false
end

function SettingLayer:ctor( ... )
    self._packDownloadCell = nil
    SettingLayer.super.ctor(self, ...)

    self:getLabelByName("Label_userId"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_userId_value"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_server"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_server_value"):createStroke(Colors.strokeBrown, 1)

    
    --是否开启礼品码
    --self._showGift = (G_Setting:get("open_giftcode") == "1")
    -- 从第三方获取是否有平台中心的选项
    local function hasPlatformCenter()
            local has = ComSdkUtils.call("hasPlatformCenter", nil, "boolean") 
            if type(has) ~= "boolean" then
                    return false
            else
                    return has
            end
    end
    self._showPlatform = hasPlatformCenter()
    
    local info = storage.load(storage.path("setting.data"))
    -- 背景音乐是否开启
    self._isMusicEnable = not (info and info.back_music_enable == 0)
    -- 音效是否开启
    self._isEffectEnable = not (info and info.back_effect_enable == 0)
    -- 聊天悬浮是否开启
    local defaulsShowChat = (G_Setting:get("default_show_chat") == "1")
    local showBtn = (info and info.show_chat_enable and info.show_chat_enable == 1)
    if defaulsShowChat then 
        showBtn = not (info and info.show_chat_enable and info.show_chat_enable ~= 1 ) 
    end
    self._isShowChatBtn = showBtn
    -- 界面特效是否开启
    self._isShowViewEffectBtn = not (info and info.show_view_effect_enable == 0)
    
    -- 数据存储
    self._datas = {
        container = {
            {
                -- 背景音乐
                desc = G_lang:get("LANG_SETTING_ITEM_MUSIC_DESC"),
                desc_stroke = Colors.strokeBrown,
                icon_open = 'ui/setting/yinyue.png',
                icon_close = 'ui/setting/yinyueguanbi.png',
                item_callback = handler(self, self._onMusicClicked),
                isOpen = self._isMusicEnable,
            },
            {
                -- 音效
                desc = G_lang:get("LANG_SETTING_ITEM_SOUND_DESC"),
                desc_stroke = Colors.strokeBrown,
                icon_open = 'ui/setting/laba.png',
                icon_close = 'ui/setting/labaguanbi.png',
                item_callback = handler(self, self._onEffectClicked),
                isOpen = self._isEffectEnable,
            },
            {
                -- 特效
                desc = G_lang:get("LANG_SETTING_ITEM_EFFECT_DESC"),
                desc_stroke = Colors.strokeBrown,
                icon_open = 'ui/setting/texiao.png',
                icon_close = 'ui/setting/texiaoguanbi.png',
                item_callback = handler(self, self._onViewEffectClicked),
                isOpen = self._isShowViewEffectBtn,
            },
            {
                -- 聊天悬浮
                desc = G_lang:get("LANG_SETTING_ITEM_CHAT_BUBBLE_DESC"),
                desc_stroke = Colors.strokeBrown,
                icon_open = 'ui/setting/liaotian.png',
                icon_close = 'ui/setting/liaotianguanbi.png',
                tip = G_Me.userData.level < G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.CHAT) and G_lang:get("LANG_LEVEL_LIMIT", {level=G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.CHAT)}) or "",
                item_callback = handler(self, self._onChatClicked),
                isOpen = self._isShowChatBtn,
            },
            -- 总分享必须开着，且微博或者微信分享必有其一开着才算数
            (G_ShareService:canShare() or self:_checkShare()) and {
                -- 邀请好友
                desc = G_lang:get("LANG_SETTING_ITEM_INVITE_DESC"),
                desc_stroke = Colors.strokeBrown,
                btn_label = 'ui/text/txt-small-btn/yaoqing.png',
                item_callback = handler(self, self._enterShare),
                item_sub_callback = handler(self, self._enterShare),
                tip = G_lang:get("LANG_TENCENT_SHARE_TIPS"),
            },
            {
                -- 公告
                desc = G_lang:get("LANG_SETTING_ITEM_NOTIFICATION_DESC"),
                desc_stroke = Colors.strokeBrown,
                btn_label = 'ui/text/txt-small-btn/chakan.png',
                item_callback = handler(self, self._enterNotification),
                item_sub_callback = handler(self, self._enterNotification),
            },
            self._showPlatform and {
                -- 平台中心
                desc = G_lang:get("LANG_SETTING_ITEM_PLATFORM_CENTER_DESC"),
                desc_stroke = Colors.strokeBrown,
                btn_label = 'ui/text/txt-small-btn/jinru.png',
                item_callback = handler(self, self._enterPlatform),
                item_sub_callback = handler(self, self._enterPlatform),
            },
            {
                -- 客服中心
                desc = G_lang:get("LANG_SETTING_ITEM_CONSUMER_CENTER_DESC"),
                desc_stroke = Colors.strokeBrown,
                btn_label = 'ui/text/txt-small-btn/xiangxixinxi.png',
                tip = G_lang:get("LANG_SETTING_ITEM_CONSUMER_CENTER_PS_DESC"),
                tip_color = Colors.lightColors.TIPS_01,
                item_callback = handler(self, self._enterKefu),
                item_sub_callback = handler(self, self._enterKefu),
            },

            G_Setting:get("hd_res_download") == "1" and {
                --downloading progress
                desc = G_lang:get("LANG_SETTING_ITEM_DOWNLOAD_PROGRESS"),
                desc_stroke = Colors.strokeBrown,
                btn_label = 'ui/text/txt-small-btn/xiazai.png',
                item_callback = handler(self, self._changeDownloadStatus),
                item_sub_callback = handler(self, self._changeDownloadStatus),
                show_progress = true,
            },
        }
    }
    
    self._datas.at = function(index)
        return self._datas.container[index]
    end
    
    self._datas.count = function()
        return #self._datas.container
    end
    
    -- 剔除空数据
    local _container = {}
    for i=1, self._datas.count() do
        if self._datas.at(i) then
            _container[#_container+1] = self._datas.at(i)
        end
    end
    
    self._datas.container = _container
    
    self:showAtCenter(true)
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    
    self:registerBtnClickEvent("Button_close", function ( ... )
        self:animationToClose()
    end)
    
    self:showTextWithLabel("Label_userId_value", G_Me.userData.id)
    if G_PlatformProxy and G_PlatformProxy:getLoginServer() then 
        self:showTextWithLabel("Label_server_value", G_PlatformProxy:getLoginServer().name)
    else
        self:showTextWithLabel("Label_server_value", "未登录")
    end
    
    -- 刷新列表
    self:_updateItems()
    

end

function SettingLayer:onLayerEnter( ... )
   if G_Setting:get("hd_res_download") == "1" then 
        local AutoDownloadModule = require("app.scenes.common.AutoDownloadModule")
        uf_eventManager:addEventListener(AutoDownloadModule.DOWNLOAD_PROGRESS_UDPATE, self.onPackDownloadProgressUpdate, self)
        uf_eventManager:addEventListener(AutoDownloadModule.DOWNLOAD_STATUS_EVENT, self._updateDownloadBtn, self)
   end
end

function SettingLayer:onPackDownloadProgressUpdate( value )
    if not self._packDownloadCell or not self._packDownloadCell.getLoadingBarByName then 
        return 
    end

    if not value and G_AutoDownloadModule then 
        value = G_AutoDownloadModule:getCurDownloadProgress()
    end

    if value >= 100 then
        self:_updateDownloadBtn()
    end
    
    local progressCtrl = self._packDownloadCell:getLoadingBarByName("ProgressBar_value")
    if progressCtrl then
        progressCtrl:setPercent(value)
    end
end

function SettingLayer:_updateItems()
    
    if not self._listView then
        
        -- 创建列表
        local panel = self:getPanelByName("Panel_listview")

        local listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        self._listView = listView
        
        listView:setCreateCellHandler(function()
            return CCSItemCellBase:create("ui_layout/common_SettingItem.json")
        end)
        
        listView:setUpdateCellHandler(function(list, index, cell)
            
            local data = self._datas.at(index+1)
            
            _updateLabel(cell, "Label_item_name", {text=data.desc, stroke=data.desc_stroke})
            
            _updateWidget(cell, "Panel_item_icon", {visible=tobool(data.icon_open)})
            _updateImageView(cell, "Image_item_open", {texture=data.isOpen and data.icon_open or data.icon_close})
            
            _updateWidget(cell, "Button_item_sub", {visible=tobool(data.btn_label)})
            _updateImageView(cell, "Image_item_btn", {texture=data.btn_label})
            
            _updateLabel(cell, "Label_item_tip", {visible=tobool(data.tip), text=data.tip, color=data.tip_color})
            
            _updateImageView(cell, "Image_back", {visible = not (not data.show_progress)})
            if data.show_progress then 
                self._packDownloadCell = cell
                _updateImageView(cell, "Image_item_btn", {texture = (G_AutoDownloadModule and G_AutoDownloadModule:isDownloading()) and 
                    'ui/text/txt-small-btn/zanting.png' or 'ui/text/txt-small-btn/xiazai.png'})
                self:onPackDownloadProgressUpdate()
            else
                if self._packDownloadCell == cell then 
                    self._packDownloadCell = nil
                end
            end

            cell:registerBtnClickEvent("Button_item", function(...)
                data.item_callback(data, cell, ...)
                _updateImageView(cell, "Image_item_open", {texture=data.isOpen and data.icon_open or data.icon_close})
            end)
            cell:registerBtnClickEvent("Button_item_sub", function ( ... )
                data.item_callback(data, cell, ...)
            end )
            
        end)
        
        listView:initChildWithDataLength(self._datas.count())
        
    else
        
        self._listView:reloadWithLength(self._datas.count())
        
    end
end

function SettingLayer:_onMusicClicked(data)
	self._isMusicEnable = not self._isMusicEnable
        data.isOpen = self._isMusicEnable
	local info = storage.load(storage.path("setting.data")) or {}
	if self._isMusicEnable then 		
		G_SoundManager:setMusicVolume(SettingLayer._max_music_volume_)

		info.back_music_enable = 1
		storage.save(storage.path("setting.data"), info)
	else
		info.back_music_enable = 0

		G_SoundManager:setMusicVolume(0)

		storage.save(storage.path("setting.data"), info )
	end
end

function SettingLayer:_onEffectClicked(data)
	self._isEffectEnable = not self._isEffectEnable
        data.isOpen = self._isEffectEnable
	local info = storage.load(storage.path("setting.data")) or {}
	if self._isEffectEnable then 		
		G_SoundManager:setSoundsVolume(SettingLayer._max_effect_volume_)

		info.back_effect_enable = 1
		storage.save(storage.path("setting.data"), info)
	else
		info.back_effect_enable = 0
		G_SoundManager:setSoundsVolume(0)
		storage.save(storage.path("setting.data"), info )
	end
end

function SettingLayer:_gotoAwardClicked( ... )
	require("app.scenes.mainscene.GiftCodeLayer").show()
end

function SettingLayer:_onChatClicked(data)
	if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CHAT)  then 
		return 
	end

	self._isShowChatBtn = not self._isShowChatBtn
        data.isOpen = self._isShowChatBtn
	local info = storage.load(storage.path("setting.data")) or {}
	if self._isShowChatBtn then 		
		info.show_chat_enable = 1
		storage.save(storage.path("setting.data"), info)
	else
		info.show_chat_enable = 0
		storage.save(storage.path("setting.data"), info )
	end

	if G_topLayer then 
		G_topLayer:showChatBtn(self._isShowChatBtn)
	end
end

function SettingLayer:_enterPlatform( ... )
	ComSdkUtils.call("openPlatformCenter") 
end

function SettingLayer:_enterKefu( ... )
	MessageBoxEx.showOkMessage(nil, G_lang:get("LANG_KEFU_TIPS"), false)
end

function SettingLayer:_updateDownloadBtn( isDownloading )
    isDownloading = isDownloading or G_AutoDownloadModule:isDownloading()
    if self._packDownloadCell then
        _updateImageView(self._packDownloadCell, "Image_item_btn", {texture = isDownloading and 
            'ui/text/txt-small-btn/zanting.png' or 'ui/text/txt-small-btn/xiazai.png'})
    end
end

function SettingLayer:_changeDownloadStatus( data, cell, widget )
    if not G_AutoDownloadModule then 
        return 
    end

    if G_AutoDownloadModule:isDownloadComplete() then 
        MessageBoxEx.showOkMessage(nil, G_lang:get("LANG_SETTING_ITEM_DOWNLOAD_COMPLETE_TIP"))
    elseif G_AutoDownloadModule:isDownloading() then 
        G_AutoDownloadModule:setForceModel(false)
        self:_updateDownloadBtn()
    else
        if not G_AutoDownloadModule:isWifiNetwork() then 
            MessageBoxEx.showYesNoMessage(nil, 
                    G_lang:get("LANG_SETTING_ITEM_NO_WIFI_DOWNLOAD_TIP"), false, 
                    function ( ... )
                        G_AutoDownloadModule:setForceModel(true)
                        self:_updateDownloadBtn()
                    end)
        else
            G_AutoDownloadModule:setForceModel(true)
            self:_updateDownloadBtn()
        end
    end    
end

function SettingLayer:_enterNotification( ... )
    G_PlatformProxy:showGonggao()
end

function SettingLayer:_checkShare()
    --判断是不是应用宝
    return ( (tostring(require("upgrade.ComSdkUtils").getOpId()) == "2151") and (GAME_VERSION_NO  > 10617) )
end

--  需要另外添加查看进度按钮时用到 
-- function SettingLayer:_getShareInfo()
--     if self:_checkShare() then
--         if G_NativeProxy.platform ~= "android" then return end
--         if G_NativeProxy.isPackageNameExist("com.tencent.android.qqdownloader") then
--             G_NativeProxy.shareGame("tmast://webview?url=" .. 
--             GlobalFunc.url_encode("http://appicsh.qq.com/cgi-bin/appstage/myapp_welfare_center?tpl=1&cmd=invite&pkgname=" .. UFPlatformHelper:getPackageName())   )
--         else
--             G_MovingTip:showMovingTip(G_lang:get("LANG_NOT_EXIST_TENCENT"))
--         end
--     end
-- end

function SettingLayer:_enterShare( ... )
    if self:_checkShare() then
        if G_NativeProxy.platform ~= "android" then return end
        if G_NativeProxy.isPackageNameExist("com.tencent.android.qqdownloader") then
            G_NativeProxy.shareGame("tmast://webview?url=" .. 
            GlobalFunc.url_encode("http://gameopt.qq.com/GetMyappInviteForApp?action=getInviteList&pkgname=" .. UFPlatformHelper:getPackageName())   )
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_NOT_EXIST_TENCENT"))
        end
    else

        local _text = G_lang:getByString(G_Setting:get("invite_content"), {
            role_name = G_Me.userData.name,
            server_name = G_PlatformProxy:getLoginServer().name,
            role_id = G_Me.userData.id,
            server_id = G_PlatformProxy:getLoginServer().id
        })

        local SharingLayer = require("app.scenes.mainscene.SharingLayer")
        local detailLayer = SharingLayer.create(SharingLayer.LAYOUT_SETTING_STYLE, Colors.modelColor, {
            {"Label_share_content", {text=_text}}
        })
        uf_sceneManager:getCurScene():addChild(detailLayer)

        detailLayer:registerBtnClickEvent("Button_to_weibo", function()
            G_ShareService:weiboShareText(_text)                         
        end)

        detailLayer:registerBtnClickEvent("Button_to_wechat", function()
            G_ShareService:weixinShareText(_text)                         
        end)
        
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHARE_SUCCESS, function()
            detailLayer:animationToClose()
        end, detailLayer)

    end
    
end

function SettingLayer:_onViewEffectClicked(data)
    self._isShowViewEffectBtn = not self._isShowViewEffectBtn
    data.isOpen = self._isShowViewEffectBtn
    local info = storage.load(storage.path("setting.data")) or {}
    if self._isShowViewEffectBtn then
        info.show_view_effect_enable = 1
        storage.save(storage.path("setting.data"), info)
    else
        info.show_view_effect_enable = 0
        storage.save(storage.path("setting.data"), info )
    end

    SettingLayer._show_effect_enable = (info.show_view_effect_enable == 1)
end

function SettingLayer.showSetting(  )
	local setting = SettingLayer.new("ui_layout/common_SettingLayer.json", Colors.modelColor)
	uf_sceneManager:getCurScene():addChild(setting)
end

return SettingLayer

