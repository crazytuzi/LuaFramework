-- --------------------------------------------------------------------
-- 边玩边下
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-8-9
-- --------------------------------------------------------------------
DownloadPanel = DownloadPanel or BaseClass(BaseView)

function DownloadPanel:__init()
    self.ctrl = MainuiController:getInstance()
    self.layout_name = "download/download_panel"
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.item_list = {}
end

function DownloadPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.size = self.main_panel:getContentSize()

    self.girl_bg = self.main_panel:getChildByName("girl_bg")
    local res = PathTool.getTargetRes("bigbg","txt_cn_bigbg_20",false,false)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.girl_bg) then
                loadSpriteTexture(self.girl_bg, res, LOADTEXT_TYPE)
            end
        end,self.item_load)
    end

    self.top_panel = self.main_panel:getChildByName("top_panel")
    self.title_label = self.top_panel:getChildByName("title_label")
    self.title_label:setString(TI18N("下载赢好礼"))

    self.begin_btn = self.main_panel:getChildByName("begin_btn")
    self.begin_btn_label = self.begin_btn:getChildByName("label")
    self.begin_btn_label:setString(TI18N("开始"))  

    self.award_btn = self.main_panel:getChildByName("award_btn")
    self.award_btn_label = self.award_btn:getChildByName("label")
    self.award_btn_label:setString(TI18N("领取奖励"))  
    self.award_btn:setTouchEnabled(false)

    --描述
    self.desc_label = createRichLabel(26, Config.ColorData.data_color4[175], cc.p(0,0), cc.p(40,260), 0, 0, 550)
    self.main_panel:addChild(self.desc_label)
    self.desc_label:setString(string.format(TI18N("下载完成可以领取以下奖励，正在下载 <div fontcolor=#249003>%s</div>"), 0).."%")

    self.progress_container = self.main_panel:getChildByName("progress_container")
    self.progress = self.progress_container:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    self.progress:setPercent(100)

    self.goods_con = self.main_panel:getChildByName("goods_con")
end

function DownloadPanel:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self.ctrl:openDownloadView(false)
        end
    end)

    self.begin_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            AUTO_DOWN_RES = not AUTO_DOWN_RES
            if AUTO_DOWN_RES == true then
                self.begin_btn_label:setString(TI18N("暂停"))  
                ResourcesLoadMgr:getInstance():downloadNext()
            else
                self.begin_btn_label:setString(TI18N("开始"))  
            end
        end
    end)

    self.award_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            local load_status = self.ctrl:getDownLoadStatus()
            if load_status == TRUE then -- 这个时候表示已经领过了 点击的时候直接移除图标
                message(TI18N("你已领取过奖励!"))
                self.ctrl:removeFunctionIconById(MainuiConst.icon.download)
                self.ctrl:openDownloadView(false)
            else
                self.ctrl:requestGetDownLoadAwards()
            end
        end
    end)

    if self.download_event == nil then
        self.download_event = GlobalEvent:getInstance():Bind(EventId.ON_SPINE_DOWNLOADED, function()
            self:updateProgress()
        end)
    end
end

function DownloadPanel:openRootWnd()
    -- 打开界面之后关闭掉红点
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.download, false)
    -- 判断是否是开始下载,按钮也不一样
    if AUTO_DOWN_RES == true then
        self.begin_btn_label:setString(TI18N("暂停"))
    else
        self.begin_btn_label:setString(TI18N("开始"))
    end
    self:createItemList()
    self:updateProgress()
end

function DownloadPanel:updateProgress()
    local down_mgr = ResourcesLoadMgr:getInstance()
    local percent_num = down_mgr:getPercentage()

    local percent = string.sub(tostring(percent_num), 1, 5)
    self.desc_label:setString(string.format(TI18N("下载完成可以领取以下奖励，正在下载 <div fontcolor=#249003>%s</div>"), percent).."%")
    
    if percent_num >= 2 then
        self.progress:setPercent(percent_num)
    end
    self.award_btn:setTouchEnabled(percent_num>=100)
    if percent_num < 100 then
        setChildUnEnabled(true, self.award_btn)
        self.award_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    else
        setChildUnEnabled(false, self.award_btn) 
        self.award_btn_label:enableOutline(Config.ColorData.data_color4[264],2)
    end
end

function DownloadPanel:createItemList()
    local item_list = self.ctrl:getDownLoadItems()
    if item_list == nil or next(item_list) == nil then return end
    for i,v in ipairs(item_list) do
        local item = BackPackItem.new(false, false, false, 0.9, false) 
        item:setPosition(cc.p((i-1)*130+95,75))
        item:setBaseData(v.bid, v.num)
        self.goods_con:addChild(item)
        table.insert(self.item_list, item)
    end
end

function DownloadPanel:close_callback()
    self.ctrl:openDownloadView(false)

    for i,v in ipairs(self.item_list) do
        if v.DeleteMe then
            v:DeleteMe()
        end
    end
    self.item_list = nil

    if self.download_event then
        GlobalEvent:getInstance():UnBind(self.download_event)
        self.download_event = nil
    end

    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
end