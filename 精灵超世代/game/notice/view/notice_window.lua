-- --------------------------------------------------------------------
-- 游戏公告
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-8-8 
-- --------------------------------------------------------------------
NoticeWindow = NoticeWindow or BaseClass(BaseView)

function NoticeWindow:__init( url)
    self.url = url
    self.view_tag = ViewMgrTag.DEBUG_TAG
    self.ctrl = NoticeController:getInstance()
    self.layout_name = "notice/notice_window"
    self.win_type = WinType.Mini
    self.dengluMgr = LoginController:getInstance():getModel()
    self.title_height = 0
    self.title = ""
end

function NoticeWindow:open_callback()
    local background = self.root_wnd:getChildByName("background")
    background:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel , 2)
    self.close_btn = self.main_panel:getChildByName("close_btn")

    local win_title = self.main_panel:getChildByName("win_title")
    win_title:setString(TI18N("公告"))

    self.ok_btn = self.main_panel:getChildByName("ok_btn")
    self.ok_btn_label = self.ok_btn:getChildByName("label")
    self.ok_btn_label:setString(TI18N("确定"))
    self.ok_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)

    self.container = self.main_panel:getChildByName('container')

    self.txt_container = self.container:getChildByName("txt_container")

    self.txt_title = self.txt_container:getChildByName("txt_title")
    self.notice_scroll = self.txt_container:getChildByName("notice_scroll")
    self.notice_scroll:setScrollBarEnabled(false)
    self.container_size = self.notice_scroll:getContentSize()

    self:layoutWebView()
    self.notice_scroll:getChildByName("Text_1"):setString("")
    self:setMessage(self.url)
    --local txt = "    I miss the days of fighting and exploring together.\n    Adventurous and challenging sky tower? You grow up, and they are still there, waiting for you in silence. Today, they come to call you to become a powerful adventurer."
    --self.notice_scroll:getChildByName("Text_1"):setString(txt)

end

-- 分离处理webview，如果有问题可以只修改局部代码
function NoticeWindow:layoutWebView()
    if self.url and self.url ~= "" and ccexp.WebView then
        self.main_panel:getChildByName("win_title"):setString("vip")
        self.web_view = ccexp.WebView:create()
        self.web_view:setAnchorPoint(0.5, 0.5)
        self.web_view:setPosition(self.container_size.width * 0.5 + 10, self.container_size.height * 0.5)
        self.web_view:setContentSize(self.container_size.width + 20, 740)
        self.web_view:setScalesPageToFit(true)
        self.web_view:setVisible(false)
        self.container:addChild(self.web_view, 99)
        self.txt_container:setVisible(false)
    end
end

function NoticeWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self.ctrl:closeNoticeView()
        end
    end)
    self.ok_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self.ctrl:closeNoticeView()
        end
    end)
end

function NoticeWindow:setMessage(url)
    if not tolua.isnull(self.web_view) then
        self.web_view:setVisible(false)         -- webview要特殊处理setvisible
    end
    if url then
        self:setWebViewUrl(url)
    else
        self.ok_btn:setVisible(true)
        self.notice_content = self.ctrl:getNoticeContent()
        if self.notice_content == nil then
            local loginData = serverData or self.dengluMgr:getLoginData()
            local svrTime = loginData.open_time or 0
            local svrDays = 0
            if svrTime ~= 0 and svrTime ~= nil then
                svrDays = math.ceil((os.time() - svrTime)/TimeTool.day2s())
            end
            local srvurl = get_notice_url(svrDays, loginData)
            if srvurl then
                function OnFileDownloadResult(state, name)
                    print("OnFileDownloadResult")
                    if self.root_wnd == nil or tolua.isnull(self.root_wnd) then return end
                    local f = assert(io.open(string.format("%sassets/src/%s", cc.FileUtils:getInstance():getWritablePath(), name), "r"))
                    local str = f:read("*all")
                    local str_table = loadstring("return "..str)
                    if str_table == nil then
                        str_table = {}
                    else
                        str_table = str_table()
                    end
                    f:close()
                    local str
                    if str_table and str_table.data and str_table.data[1] and str_table.data[1].content then 
                        str = str_table.data[1].content or ""
                    end
                    if not str then return end
                    str = string.gsub(str, "&lt;", "<")
                    str = string.gsub(str, "&gt;", ">")
                    str = string.gsub(str, "&#039;", "'")
                    str = string.gsub(str, "&quot;", '"')  
                    str = string.gsub(str, "\9", '    ')                     
                    str = WordCensor:getInstance():relapceFaceIconTag(str)[2]

                    self.notice_content = str
                    NoticeController:getInstance():setNoticeContent(str)        -- 缓存一下这一次的公告

                    local list = Split(str, "|")
                    self:addNoticeContent(list)
                end
                cc.FmodexManager:getInstance():downloadOtherFile(srvurl, "notice.txt")
            end
        else
            local list = Split(self.notice_content, "|")
            self:addNoticeContent(list)
        end
    end
end

function NoticeWindow:setWebViewUrl(url)
    if not self.web_view then return end
    if not tolua.isnull(self.web_view) then
        self.web_view:setVisible(true) 
    end
    self.web_view:loadURL(url)
    self.ok_btn:setVisible(false)
end

function NoticeWindow:addNoticeContent(list)
	if list == nil or #list == 0 then return end
	-- 更新先情况,防止加载不到文件时候多次加载
	self.notice_scroll:removeAllChildren()
	self.notice_scroll:stopAllActions()
	local len = #list
	local vo = nil
	local curY = 6
	local idx = 1
	local contentList = {}

    -- 取出第一个用于称谓显示
    local first_txt = table.remove( list, 1 )
    self.txt_title:setString(first_txt or "")

    for i,vo in ipairs(list) do
        delayRun(self.notice_scroll, i/60, function() 
			local sub = self:createSubContent(2, 0, vo, self.container_size.width-4, 6)
			curY = curY + sub:getContentSize().height + 3
			table.insert(contentList, sub)

			local maxY = math.max(curY, self.container_size.height)
			local size = cc.size(self.container_size.width, maxY)
			self.notice_scroll:setInnerContainerSize(size)

			for i, obj in ipairs(contentList) do
				obj:setPositionY(maxY-10)
				maxY = maxY - (obj:getContentSize().height + 3)
			end
        end)
    end
end

function NoticeWindow:createSubContent(x, y, content, width, linespace)
	local label = createRichLabel(22, Config.ColorData.data_color4[274], nil, cc.p(0, 1), linespace, nil, width)
    print("content",content)
	label:setString(content)
	label:setAnchorPoint(0, 1)
	self.notice_scroll:addChild(label)
	label:setPosition(x, y)
    local function clickLinkCallBack( type, value )
        if type == "href"  then
            sdkCallFunc("openUrl", value)
        end
    end
    label:addTouchLinkListener(clickLinkCallBack,{"href"})
	return label
end

function NoticeWindow:close_callback()
    doStopAllActions(self.notice_scroll)
    self.url = nil
    self.ctrl:closeNoticeView()
end