----------------------------
-- @Author: xhj
-- @Date:   2019-11-15 15:13:22
-- @Description:   充值返现
----------------------------
ActionChargeReturnPanel = class("ActionChargeReturnPanel", function()
	return ccui.Widget:create()
end)

local controller = ActionController:getInstance()
local model = controller:getModel()
local string_format = string.format

function ActionChargeReturnPanel:ctor(bid)
    self.holiday_bid = bid
	self:configUI()
	self:register_event()

	self.is_init = true --是否为初始化
end

function ActionChargeReturnPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_charge_return_panel"))
	self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setPosition(-40, -80)
	self:setAnchorPoint(0, 0)

	self.main_container = self.root_wnd:getChildByName("main_container")
	self.image_bg = self.main_container:getChildByName("image_bg")

    local str = ""
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

	self.btn_tips = self.main_container:getChildByName("btn_tips")
	self.txt_desc = self.main_container:getChildByName("txt_desc")
	self.txt_time_title = self.main_container:getChildByName("txt_time_title")
	self.txt_time_title:setString(TI18N("活动时间："))
	self.txt_time_value = self.main_container:getChildByName("txt_time_value")
	self.txt_time_value:setString("")
	self.txt_buff_title = self.main_container:getChildByName("txt_buff_title")
	self.txt_buff_title:setString(TI18N("圣洁之力剩余BUFF："))
	self.txt_buff_value = self.main_container:getChildByName("txt_buff_value")
	self.txt_buff_value:setString("")
	
	self.btn_charge = self.main_container:getChildByName("btn_charge")
	self.txt_charge = self.btn_charge:getChildByName("label")
	self.txt_charge:setString(TI18N("前往充值"))

	self.progress_panel = self.main_container:getChildByName("progress_panel")
	self.qingbao_progress = cc.ProgressTimer:create(createSprite(PathTool.getResFrame("battledrama", "battledrama_1021"), 40, 40, nil, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST))
	self.qingbao_progress:setPosition(40, 40)
	self.qingbao_progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	self.progress_panel:addChild(self.qingbao_progress)
		
	controller:cs16603(self.holiday_bid)

end

function ActionChargeReturnPanel:register_event()
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
        if self.holiday_bid == ActionRankCommonType.seven_charge then
            config = Config.HolidayClientData.data_constant.seven_charge_rules
        end
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    end ,true, 1)

    registerButtonEventListener(self.btn_charge, function()
		VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
		--MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
    end ,true, 1)

end

function ActionChargeReturnPanel:setPanelData(data)
	if not data then return end

	local str = string_format(TI18N("%s-%s"),TimeTool.getMD2(data.start_time),TimeTool.getMD2(data.end_time))
	self.txt_time_value:setString(str)

	local buffStr = string_format("%d/%d",5000,8000)
	self.txt_buff_value:setString(buffStr)
end


function ActionChargeReturnPanel:setVisibleStatus(bool)
	bool = bool or false
	self:setVisible(bool)
end

function ActionChargeReturnPanel:DeleteMe()
	if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    if self.update_holiday_common_event then
        GlobalEvent:getInstance():UnBind(self.update_holiday_common_event)
        self.update_holiday_common_event = nil
    end
    
end
