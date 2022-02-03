----------------------------
-- @Author: yuanqi@shiyue.com
-- @Date:   2019-12-12 14:52:22
-- @Description:   嘉年华报告活动
----------------------------
ActionCarnivalReportPanel = class("ActionCarnivalReportPanel", function()
	return ccui.Widget:create()
end)

local controller = ActionController:getInstance()
local model = controller:getModel()
local string_format = string.format

function ActionCarnivalReportPanel:ctor(bid)
    self.holiday_bid = bid
	self:configUI()
	self:register_event()

	self.reward_item_list = {} --奖励
end

function ActionCarnivalReportPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_carnival_report_panel"))
	self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setPosition(-40, -80)
	self:setAnchorPoint(0, 0)

	self.main_container = self.root_wnd:getChildByName("main_container")
	self.image_bg = self.main_container:getChildByName("image_bg")

    local str = "txt_cn_action_carnival_report"
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.reward_title ~= "" and tab_vo.reward_title then
        str = tab_vo.reward_title
    end

    local res = PathTool.getPlistImgForDownLoad("bigbg/action", str)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.image_bg) then
                self.image_bg:loadTexture(res,LOADTEXT_TYPE)
            end
        end,self.item_load)
    end
	self.txt_time_title = self.main_container:getChildByName("txt_time_title")
	self.txt_time_title:setString(TI18N("剩余时间："))
	self.txt_time_value = self.main_container:getChildByName("txt_time_value")
	self.txt_time_value:setString("")
	self.btn_get_reward = self.main_container:getChildByName("btn_get_reward")
	local btn_label = self.btn_get_reward:getTitleRenderer()
    if btn_label ~= nil then
        btn_label:enableOutline(Config.ColorData.data_color4[277], 2)
    end
	self.btn_tips = self.main_container:getChildByName("btn_tips")

	self.reward_con = self.main_container:getChildByName("reward_con")
	--嘉年华报告入口
	self.goto_report_label = createRichLabel(24, cc.c3b(77, 24, 114), cc.p(0, 0.5), cc.p(0, 0))
    self.goto_report_label:setString(string_format("<div href=xxx>%s</div>", TI18N("点击查看")))
    self.goto_report_label:addTouchLinkListener(function(type, value, sender, pos)
        self:getHttpPath()
    end, { "click", "href" })
	self.main_container:addChild(self.goto_report_label)
	self.goto_report_label:setPosition(193, 180)

	-- 礼包码输入框
	self.key_editbox = createEditBox(self.open_button, PathTool.getResFrame("common", "common_1021"), cc.size(350, 45), cc.c4b(0x7f,0x7f,0x7f,0xff), 24, cc.c4b(0x7f,0x7f,0x7f,0xff), 24, "输入我的礼包码", nil, nil, LOADTEXT_TYPE_PLIST)
	self.main_container:addChild(self.key_editbox)
	self.key_editbox:setPosition(245, 110)

	local function editBoxTextEventHandle(strEventName,pSender)
		if strEventName == "return" or strEventName == "ended" then
			self.input_text = ""
			local str = pSender:getText()
			if str ~= "" and str ~= self.input_text then
				self.input_text = str
			end

        end
    end
	self.key_editbox:registerScriptEditBoxHandler(editBoxTextEventHandle)
	controller:cs16603(self.holiday_bid)
	controller:sender16666(self.holiday_bid)
end

function ActionCarnivalReportPanel:register_event()
	if not self.update_holiday_common_event then
		self.update_holiday_common_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
			if not data then return end
            if data.bid == self.holiday_bid then
                self:setPanelData(data)
            end
        end)
	end
	
    registerButtonEventListener(self.btn_tips, function(param, sender, event_type)
        local config
        if self.holiday_bid == ActionRankCommonType.carnival_report then
            config = Config.HolidayClientData.data_constant.carnival_report_rules
		end
		if config and config.desc then 
			TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
		end
    end ,true, 1)

	registerButtonEventListener(self.btn_get_reward, function()
		if self.input_text ~= nil and self.input_text ~= "" then
			controller:sender16695(self.input_text)
		end
    end ,true, 1)
end

function ActionCarnivalReportPanel:setPanelData(data)
	if not data then return end
	--倒计时
	local time = data.remain_sec or 0
	commonCountDownTime(self.txt_time_value, time)
	local pos_x = self.txt_time_value:getPositionX() - self.txt_time_value:getContentSize().width
	self.txt_time_title:setPositionX(pos_x + 5)
	self:updateRewardItem(data)
end

--设置奖励数据
function ActionCarnivalReportPanel:updateRewardItem(data)
	if data == nil or next(data) == nil then return end
	--创建奖励item
	if self.reward_item_list == nil or next(self.reward_item_list) == nil then
		self.reward_item_list = self.reward_item_list or {}
		for i=1, 5 do
			local item_par = self.reward_con:getChildByName("item_par" .. i)
			local item = BackPackItem.new(true, true, false, 1, true, true)
			local size = item_par:getContentSize()
			item_par:addChild(item)
			item:setAnchorPoint(cc.p(0.5, 0.5))
			item:setPosition(cc.p(size.width / 2, size.height / 2))
			item:setScale(0.8)
			self.reward_item_list[i] = item
		end
	end
	
	local item_data = data.aim_list
	if item_data == nil or next(item_data) == nil then return end;
	--设置奖励数据
	for k, v in ipairs(item_data) do
		if self.reward_item_list[k] ~= nil then
			if v.item_list and v.item_list[1].bid and v.item_list[1].num then
				self.reward_item_list[k]:setBaseData(v.item_list[1].bid, v.item_list[1].num, true)
			end
			self.reward_item_list[k]:setReceivedIcon1(v.status == 2)
		end
	end
end

function ActionCarnivalReportPanel:getHttpPath()
    local https_path = "https://sszg.shiyue.com/m/carnival.html"
    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" or PLATFORM_NAME == "release2" then
    	https_path = "http://test-cms-sszg.shiyue.com/m/carnival.html"
    end

    local string_format = string.format
    local role_vo = RoleController:getInstance():getRoleVo()
    local platform, sid = unpack(Split(role_vo.srv_id, "_"))
    local carnival_data = RoleController:getInstance():getModel():getGrowthWayCarnivalData()
    -- 这里要获取一下成长之路最高获得英雄信息 partner = 伙伴id,星级,名称   Config.PartnerData.data_partner_name2bid Config.RoomGrowData.data_carnival
    local partner_str = string_format("partner=0,0,0&name=%s", role_vo.name)
    if carnival_data ~= nil and carnival_data.id ~= 0 and carnival_data.name ~= "" then
    	local star = Config.RoomGrowData.data_carnival[carnival_data.id]
    	local bid = Config.PartnerData.data_partner_name2bid[carnival_data.name]
    	if bid and star then
            partner_str = string_format("partner=%s,%s,%s&name=%s", bid, star, carnival_data.name, role_vo.name)
    	end
    end

    local result_str = string_format("%s%s%s%s%s", role_vo.rid, PLATFORM_NAME, sid, GameNet:getInstance():getTime(), "He952ae2a6ea8cdG7410j6T42d7ce32")
    result_str = cc.CCGameLib:getInstance():md5str(result_str)
    result_str = string_format("role_id=%s&platform=%s&zone_id=%s&ctime=%s&flag=%s&%s", role_vo.rid, PLATFORM_NAME, sid, GameNet:getInstance():getTime(), result_str, partner_str)
    result_str = encodeBase64(result_str)
    result_str = string_format("%s?%s", https_path, result_str)    
    if IS_IOS_PLATFORM == true then
        sdkCallFunc("openSyW", result_str)
    else
        sdkCallFunc("openUrl", result_str)
    end
end

function ActionCarnivalReportPanel:DeleteMe()
	if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
	doStopAllActions(self.txt_time_value)
    if self.update_holiday_common_event then
        GlobalEvent:getInstance():UnBind(self.update_holiday_common_event)
        self.update_holiday_common_event = nil
    end
    if self.reward_item_list then
        for i,v in pairs(self.reward_item_list) do
            v:DeleteMe()
        end
        self.reward_item_list = nil
    end
    doStopAllActions(self.cur_reward_scrollview)
end