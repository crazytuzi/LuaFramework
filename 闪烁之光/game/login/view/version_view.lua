--[[
   游戏版本号信息UI
   @author cloud
   @date 2017.1.6
--]]
VersionView = class("VersionView", function()
	return ccui.Widget:create()
end)

function VersionView:ctor()
	self.size = cc.size(SCREEN_WIDTH, SCREEN_HEIGHT)
    self:setContentSize(self.size)
    
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("login/login_version_view"))
    self:addChild(self.root_wnd)
    -- 这里是下方更新提示
    self.progress_bg = self.root_wnd:getChildByName("progeass_container")

    self.notice_title = self.progress_bg:getChildByName("notice_title")
    self.notice_content = self.progress_bg:getChildByName("notice_content")

    self.bg_img = self.progress_bg:getChildByName("bg_img")
    local tmp_size = self.bg_img:getContentSize()
    self.bg_img:setContentSize(cc.size(SCREEN_WIDTH, tmp_size.height))

    self.progress = self.progress_bg:getChildByName("progress")
	self.progress:setScale9Enabled(true)
    local tmp_size = self.progress:getContentSize()
    self.progress:setPercent(0)
    self.progress:setContentSize(cc.size(SCREEN_WIDTH, tmp_size.height))

    self.particle_ui = self.progress:getChildByName("particle_ui")
    self.txt_progress = self.progress:getChildByName("txt_progress")

    -- 随机提示语
    self.desc_label = self.progress_bg:getChildByName("desc_label")
    math.randomseed(os.time())
	local desc_rand_num = math.random(1,Config.LoadingDescData.data_desc_length)
	self.desc_label:setString(Config.LoadingDescData.data_desc[desc_rand_num])

    -- 这里是wifi更新提示
    self.notice_bg = self.root_wnd:getChildByName("notice_bg")
    self.update_notice_wifi = self.notice_bg:getChildByName("update_notice_wifi")
    self.update_notice_wifi:setString(TI18N("(建议您在wifi状态下更新游戏)"))

    self.notice_label = self.notice_bg:getChildByName("notice_label")
    self.notice_label:setTextAreaSize(cc.size(self.notice_bg:getContentSize().width-self.notice_label:getPositionX()*2, 130))
    local real_label = self.notice_label:getVirtualRenderer()
    if real_label then
        real_label:setLineSpacing(10)
    end

    self.cancel_btn = self.notice_bg:getChildByName("cancel_btn")
    self.notice_btn = self.notice_bg:getChildByName("notice_btn")
    local btn_label = self.cancel_btn:getChildByName("label") 
    if btn_label then
        btn_label:setString(TI18N("取消")) 
    end
    btn_label = self.notice_btn:getChildByName("label") 
    if btn_label then
        btn_label:setString(TI18N("确定")) 
    end

    -- 新增的
    local notice_title = self.notice_bg:getChildByName("win_title")
    if notice_title then
        notice_title:setString(TI18N("下载更新"))
    end
    self.close_btn = self.notice_bg:getChildByName("close_btn")

    self.notice_bg:setPositionY(display.cy)
    self.notice_bg:setVisible(false)

    -- 提审特殊需求
    self.bg_img:setVisible(false)
    self.progress:setVisible(false)
    self.desc_label:setVisible(false)

    -- 设置健康公告显示
    if self.notice_title then
        self.notice_title:setString(TI18N("健康游戏忠告"))
        self.notice_content:setString(TI18N("抵制不良游戏，拒绝盗版游戏．注意自我保护，谨防受骗上当．\n适度游戏益脑，沉迷游戏伤身．合理安排时间，享受健康生活．"))
    end
end

function VersionView:update(percent, str)
    self:checkIsMakeLiftBetter()
    
    str = str or ""
	self.percent = percent
	self.progress:setPercent(self.percent)
	self.particle_ui:setPositionX((self.percent/100)*SCREEN_WIDTH+7)
	self.txt_progress:setString(str.."  "..self.percent.."%")
end

function VersionView:checkIsMakeLiftBetter()
    local need_show = false
    if MAKELIFEBETTER == true then
        need_show = false
    else
        need_show = true
    end
    if self.need_show ~= need_show then
        self.need_show = need_show
        if self.need_show == false then
            self.bg_img:setVisible(false)
            self.progress:setVisible(false)
            self.desc_label:setVisible(false)
            self.desc_label:setPositionY(11)
            if self.notice_title then
                self.notice_title:setVisible(false)
                self.notice_content:setVisible(false)
            end
        else
            self.bg_img:setVisible(true)
            self.progress:setVisible(true)
            self.desc_label:setVisible(true)
            self.desc_label:setPositionY(47)
            if self.notice_title then
                self.notice_title:setVisible(true)
                self.notice_content:setVisible(true)
            end
        end
    end
end

-- 设置提示
function VersionView:setTips(str)
    self.txt_progress:setString(str)
end

-- 设置版本提示
function VersionView:setVersionTips(str)
    if self.is_set_version then
    end
    self.is_set_version = true
    self.txt_progress:setString(str)
end

-- 显示
function VersionView:showNotice(callback,all_size)
	if all_size and all_size < 8 then
        callback()
        return
    end
	self.notice_bg:setVisible(true)
	if all_size and all_size ~= 0 and not tolua.isnull(self.notice_label) then
		self.notice_label:setString(string.format(TI18N("    检查到游戏当前版本需要更新,本次更新的文件大小约为:%.2fMB,点击确认即可进行下载更新,点击取消退出游戏。"), all_size/1024))
 	end

    self.notice_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            callback()
            self.notice_bg:setVisible(false)
        end
    end)

	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	self.cancel_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.began then
			if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_ANDROID == targetPlatform) then
				device.sdkCallFunc("sdkExit")
			elseif cc.PLATFORM_OS_WINDOWS  == targetPlatform then
				cc.Director:getInstance():endToLua()
			end
		end
	end)

    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.began then
                if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_ANDROID == targetPlatform) then
                    device.sdkCallFunc("sdkExit")
                elseif cc.PLATFORM_OS_WINDOWS  == targetPlatform then
                    cc.Director:getInstance():endToLua()
                end
            end
        end)
    end
end

-- 设置魂灵显隐
function VersionView:setSpineVisible(bool)
end

-- 销毁
function VersionView:DeleteMe(  )
end

function deepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end

        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-- 捕获输出
if not is_change_print then
    local cclog = deepCopy(print)
    is_change_print = true
    function print( ... )
        if not DEBUG_MODE and PLATFORM_NAME ~= "demo" then return end
        cclog(...)
    end
end
