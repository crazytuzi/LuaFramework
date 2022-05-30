-- --------------------------------------------------------------------
-- 竖版邮件
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
MailWindow = MailWindow or BaseClass(BaseView)

local controller = MailController:getInstance()
local model = MailController:getInstance():getModel()

function MailWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full              	
    self.title_str = TI18N("邮箱")
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("mail","mail"), type = ResourcesType.plist },
    }
    self.tab_info_list = {
        {label=TI18N("邮件"), index=1, status=true},
        {label=TI18N("公告"), index=2, status=true},
    }
    self.cur_index = nil
end

function MailWindow:open_callback()
	self.mail_root = createCSBNote(PathTool.getTargetCSB("mail/mail_window"))
    self.mail_root:setPosition(10,30)

    self.container:addChild(self.mail_root)

    self.main_container = self.mail_root:getChildByName("main_container")
    self.del_btn = self.main_container:getChildByName("del_btn")
    local del_btn_size = self.del_btn:getContentSize()
    self.del_btn_label = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(del_btn_size.width/2, del_btn_size.height/2))
    self.del_btn:addChild(self.del_btn_label)
    self.del_btn_label:setString(string.format(TI18N("<div fontcolor=#ffffff shadow=0,-2,2,%s>删除已读</div>"), Config.ColorData.data_new_color_str[2]))
    -- self.del_btn:setTitleText(TI18N("删除已读"))
    -- self.del_btn.label = self.del_btn:getTitleRenderer()
    -- if self.del_btn.label ~= nil then
    --     self.del_btn.label:enableOutline(Config.ColorData.data_color4[263], 2)
    -- end
    self.get_btn = self.main_container:getChildByName("get_btn")
    local get_btn_size = self.get_btn:getContentSize()
    self.get_btn_label = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(get_btn_size.width/2, get_btn_size.height/2))
    self.get_btn:addChild(self.get_btn_label)
    self.get_btn_label:setString(string.format(TI18N("<div fontcolor=#ffffff shadow=0,-2,2,%s>一键领取</div>"), Config.ColorData.data_new_color_str[3]))
    -- self.get_btn:setTitleText(TI18N("一键领取"))
    -- self.get_btn.label = self.get_btn:getTitleRenderer()
    -- if self.get_btn.label ~= nil then
    --     self.get_btn.label:enableOutline(Config.ColorData.data_color4[264], 2)
    -- end

    self.scrollCon = self.main_container:getChildByName("scrollCon")
    local scroll_view_size = self.scrollCon:getContentSize()
    self.good_cons = self.main_container:getChildByName("good_cons")
    self.emptyTips = createImage(self.main_container,PathTool.getEmptyMark(),scroll_view_size.width/2,505,cc.p(0.5,1))
    self.emptyTips:setVisible(false)
    self.empty_label = createLabel(22,Config.ColorData.data_new_color4[6],nil,self.emptyTips:getContentSize().width/2,-35,TI18N("暂时没有邮件"),self.emptyTips,0, cc.p(0.5,0))
    local setting = {
        item_class = MailCell,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 6,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 616,               -- 单元的尺寸width
        item_height = 124,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1                        -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.good_cons, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, self.good_cons:getContentSize(), setting)
end

function MailWindow:register_event()
	if self.get_btn then
        self.get_btn:addTouchEventListener(function ( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                controller:getAllGoods()
            end
        end)
    end

    if self.del_btn then
    	self.del_btn:addTouchEventListener(function ( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
            	local list = model:getHasReadNonRewardList()
                controller:deletMailSend(list)
            end
        end)
    end

    -- 更新邮件
    self:addGlobalEvent(MailEvent.UPDATE_ITEM, function()
        if self.cur_index == 1 then
    		self:selectedTabCallBack(self.cur_index)
        end
    end)

    -- 更新红点状态
    self:addGlobalEvent(MailEvent.UPDATEREDSTATUS, function(bid, num) 
        self:updateRedStatus(bid, num)
    end)

    -- 读取一封邮件的返回
    self:addGlobalEvent(MailEvent.READ_MAIL_INFO, function(key) 
        if self.select_cellitem then
            local data = self.select_cellitem:getData()
            if data then
                local item_key = getNorKey(data.id or 0, data.srv_id or "")
                if item_key == key then
                    self.select_cellitem:updateIconStatus()
                end
            end
        end
    end)

    --读取一封公告
    self:addGlobalEvent(MailEvent.READ_INFO_NOTICE, function(id)
        local notice_msg = model:getNoticeMessage(id)
        if notice_msg then
            controller:openMailInfo(true, notice_msg)
        end
    end)
    --更新公告
    self:addGlobalEvent(MailEvent.UPDATE_NOTICE, function()
        if self.cur_index == 2 then
            self:selectedTabCallBack(self.cur_index)
        end
    end)

end

function MailWindow:openRootWnd(index)
    index = index or 1
    self:setSelecteTab(index,true)

    self:updateRedStatus()
end

--==============================--
--desc:更新红点
--time:2019-02-16 01:23:29
--@bid:
--@num:
--@return 
--==============================--
function MailWindow:updateRedStatus(bid, num)
    if bid == nil then
        -- 邮件,公告
        for i=1,2 do
            local count = model:getRedSum(i)
            if count == nil then
                count = 0
            end
            self:setTabTipsII(count, i)
        end
    else
        bid = bid or 1
        num = num or 0
        self:setTabTipsII(num, bid) 
    end
end

function MailWindow:selectedTabCallBack(index)
	self.cur_index = index
    local list = {}
	if index == 1 then
		list = MailController:getData():getAllMailArray()
		self.get_btn:setVisible(true)
		self.del_btn:setVisible(true)
        -- self.scrollCon:setContentSize(cc.size(622,711))
        -- self.good_cons:setContentSize(cc.size(615,696))
        self.scrollCon:setContentSize(cc.size(622,691))
        self.good_cons:setContentSize(cc.size(615,676))
        self.item_scrollview:resetSize(self.good_cons:getContentSize())
        self.empty_label:setString(TI18N("暂时没有邮件")) 
	elseif index == 2 then
		list = model:getNoticeArray()
		self.get_btn:setVisible(false)
		self.del_btn:setVisible(false)
        -- self.scrollCon:setContentSize(cc.size(622,775))
        -- self.good_cons:setContentSize(cc.size(615,761))
        self.scrollCon:setContentSize(cc.size(622,755))
        self.good_cons:setContentSize(cc.size(615,741))
        self.item_scrollview:resetSize(self.good_cons:getContentSize())
        self.empty_label:setString(TI18N("暂时没有公告")) 
	end
    self.emptyTips:setVisible(#list == 0) 

    if #list > 0 then
        if self.item_scrollview then
            self.item_scrollview:setVisible(true)
        end
        self.item_scrollview:setData(list, function(cell)
            if index == 1 then
                self:selectMailItem(cell)
            elseif index == 2 then
                self:selectNoticeItem(cell)
            end
        end) 
    else
        if self.item_scrollview then
            self.item_scrollview:setVisible(false)
        end
    end
end

--==============================--
--desc:点击cellitem 邮件的
--time:2019-02-16 10:29:52
--@cell:
--@return 
--==============================--
function MailWindow:selectMailItem(cell)
    self.select_cellitem = cell
    local data = cell:getData()
    if data then
        controller:requireMailItem(data.id, data.srv_id)
    end
end

--点击公告的
function MailWindow:selectNoticeItem(cell)
    self.select_cellitem = cell
    local data = cell:getData()
    if data then
        controller:readNotice(data.id)
    end
end

function MailWindow:close_callback()
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
	controller:openMailPanel(false)
end