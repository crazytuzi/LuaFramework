--**************
-- 节日活动(目前用于元宵活动)
-- --------------------------------------------------------------------
AnimateActionFestvalPanel = class("AnimateActionFestvalPanel", function()
    return ccui.Widget:create()
end)

local controller = AnimateActionController:getInstance()
local action_controller = ActionController:getInstance()
local constant = Config.HolidayLantermFestivalData.data_constant
function AnimateActionFestvalPanel:ctor(bid)
	self.holiday_bid = bid
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.festval_light_list = {}
	self:configUI()
	self:register_event()
end

function AnimateActionFestvalPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("animateaction/animate_festval_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.title_img = self.main_container:getChildByName("title_img")
    local str = "txt_cn_animateaction_1"
 
    local res = PathTool.getTargetRes("bigbg/animateaction",str,false,false)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.title_img) then
                loadSpriteTexture(self.title_img, res, LOADTEXT_TYPE)
            end
        end,self.item_load)
    end

    self.good_cons = self.main_container:getChildByName("good_cons")
    self.good_cons:setScrollBarEnabled(false)

    self.light_num = self.main_container:getChildByName("light_layer"):getChildByName("light_num")
    local count = self.role_vo:getActionAssetsNumByBid(constant.awards_expend_items.val)
    self.light_num:setString(count)

    self.btn_add = self.main_container:getChildByName("light_layer"):getChildByName("btn_add")
    self.btn_rule = self.main_container:getChildByName("btn_rule")
    self.main_container:getChildByName("time_layer"):getChildByName("Text_2"):setString(TI18N("剩余时间："))
    self.time_text = self.main_container:getChildByName("time_layer"):getChildByName("time_text")
    self.time_text:setString("")
end

function AnimateActionFestvalPanel:register_event()
	if not self.role_festval_event and self.role_vo then
        self.role_festval_event =  self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ACTION_ASSETS, function(id, value) 
            if id and id == constant.awards_expend_items.val and self.role_vo then 
                local count = self.role_vo:getActionAssetsNumByBid(constant.awards_expend_items.val)
	            self.light_num:setString(count)
            end
        end)
    end

	if not self.animate_festval_event then
		self.animate_festval_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function(data)
			if data.bid == self.holiday_bid then
				if data then
	                controller:getModel():setLessTime(self.time_text,data.remain_sec)
	            end
			end
		end)
	end

	if not self.festval_light_event then
		self.festval_light_event = GlobalEvent:getInstance():Bind(AnimateActionEvent.YuanZhenFestval_Linght,function(data)
            if not data or next(data) == nil then return end
			table.sort(data.award_list, function(a,b) return a.id < b.id end)
			local lenght = Config.HolidayLantermFestivalData.data_consume_num_length
			local open_num = 3

			local light_data = data.award_list or {}
			if data.award_list[lenght].flag == 1 then
				open_num = 4
				self.good_cons:setInnerContainerSize(cc.size(720,832))
				local tab = {}
				tab[1] = data.award_list[4]
				tab[2] = data.award_list[1]
				tab[3] = data.award_list[2]
				tab[4] = data.award_list[3]
				light_data = tab
			end

			local pos_y = self.good_cons:getInnerContainerSize().height
			--灯的位置
			local yuanzhen_light_pos = {{187,155},{581,300},{219,500},{561,650}}
			for i=1,open_num do
				if not self.festval_light_list[i] then
					self.festval_light_list[i] = AnimateActionFestvalPanelItem.new()
					self.good_cons:addChild(self.festval_light_list[i])
				end
				if self.festval_light_list[i] then
					self.festval_light_list[i]:setExtendData(light_data[i].flag)
					self.festval_light_list[i]:setData(light_data[i] or {})
					self.festval_light_list[i]:setPosition(yuanzhen_light_pos[i][1],pos_y - yuanzhen_light_pos[i][2])
				end
			end
		end)
	end

    registerButtonEventListener(self.btn_add, function()
    	--跳转到元宵大冒险的
    	local id = ActionRankCommonType.yuanzhen_adventure
        local tab_vo = action_controller:getActionSubTabVo(id)
        if tab_vo then
            if action_controller.action_operate then
                action_controller.action_operate:handleSelectedTab(action_controller.action_operate.tab_list[id])
            end
        end
    end ,true, 1)
    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
    	local config = constant.holiday_content_tips.desc
    	TipsManager:getInstance():showCommonTips(config, sender:getTouchBeganPosition(),nil,nil,500)
    end ,true, 1)
end

function AnimateActionFestvalPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == true then
    	action_controller:cs16603(self.holiday_bid)
    	controller:sender24801()
    end
end

function AnimateActionFestvalPanel:DeleteMe()
	doStopAllActions(self.time_text)
	if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    if self.festval_light_list then
        for i,v in pairs(self.festval_light_list) do
            v:DeleteMe()
        end
        self.festval_light_list = nil
    end
    if self.animate_festval_event then
        GlobalEvent:getInstance():UnBind(self.animate_festval_event)
        self.animate_festval_event = nil
    end
    if self.festval_light_event then
        GlobalEvent:getInstance():UnBind(self.festval_light_event)
        self.festval_light_event = nil
    end
    if self.role_festval_event then
        self.role_vo:UnBind(self.role_festval_event)
        self.role_festval_event = nil
    end
end

------------------------------------------
-- 子项
AnimateActionFestvalPanelItem = class("AnimateActionFestvalPanelItem", function()
    return ccui.Widget:create()
end)
local light_name = {TI18N("纳福灯"),TI18N("祈愿灯"),TI18N("丰登灯"),TI18N("小花灯")}
local consume_list = Config.HolidayLantermFestivalData.data_consume_num
function AnimateActionFestvalPanelItem:ctor()
	self:configUI()
	self:register_event()
end

function AnimateActionFestvalPanelItem:configUI()
	self.size = cc.size(180,210)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("animateaction/animate_festval_panel_item"))
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.name = main_container:getChildByName("name")
    self.light_spr = main_container:getChildByName("light_spr")

    self.consume_text = createRichLabel(22, cc.c4b(0xff,0xe1,0xa2,0xff), cc.p(0.5,0.5), cc.p(main_container:getContentSize().width/2,-3), nil, nil, 250)
	main_container:addChild(self.consume_text)
end

function AnimateActionFestvalPanelItem:register_event()
    registerButtonEventListener(self, function()
	    controller:openAnimateFestvalWindow(true,self.data.id,self.is_open)
    end,false, 1)
end
function AnimateActionFestvalPanelItem:setExtendData(flag)
	self.is_open = flag or 1
end

function AnimateActionFestvalPanelItem:setData(data)
	if not data or next(data) == nil then return end
	self.data = data

	self.name:setString(light_name[self.data.id])
	loadSpriteTexture(self.light_spr, PathTool.getResFrame("animateaction_yaunzhen","animateaction_yaunzhen_"..self.data.id), LOADTEXT_TYPE_PLIST)

	if self.is_open == 1 then
		self.consume_text:setVisible(false)
		setChildUnEnabled(false, self.light_spr)
	else
		setChildUnEnabled(true, self.light_spr)
		local item_config = Config.ItemData.data_get_data(constant.awards_expend_items.val)
	    local res = PathTool.getItemRes(item_config.icon)
		local str = string.format(TI18N("累计消耗 <img src='%s' scale=0.45 />%d个开启"),res,consume_list[self.data.id].need_num)
		self.consume_text:setString(str)
		self.consume_text:setVisible(true)
	end
end

function AnimateActionFestvalPanelItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end
