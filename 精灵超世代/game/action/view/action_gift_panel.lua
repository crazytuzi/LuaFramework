-- --------------------------------------------------------------------
-- 超值礼包
--
-- @author: shuwen(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 
-- --------------------------------------------------------------------
ActionGiftPanel = class("ActionGiftPanel", function()
    return ccui.Widget:create()
end)

function ActionGiftPanel:ctor(bid,type)
	self.holiday_bid = bid
	self.type = type
	self.ctrl = ActionController:getInstance()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.can_get = 0
    self.item_list = {}
    self.tab_list = {}
    self.data = self.ctrl:getActionSubTabVo(self.holiday_bid)
    self.is_update = false
	self:configUI()
	self:register_event()
end

function ActionGiftPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_gift_panel"))
	self.root_wnd:setPosition(-40,-120)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)
    
   
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.bg = self.main_container:getChildByName("bg")
    local res_id = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_41",true)
    if not self.bg_load then
        self.bg_load = createResourcesLoad(res_id, ResourcesType.single, function()
            if not tolua.isnull(self.bg) then
                self.bg:loadTexture(res_id,LOADTEXT_TYPE)
            end
        end, self.bg_load)
        
    end

    self.mid_icon = self.main_container:getChildByName("mid_icon")
    self.label_bg = self.main_container:getChildByName("label_bg")

    self.btn = self.main_container:getChildByName("btn")
    self.btn:setTitleText(TI18N("领取大礼"))
    self.btn.label = self.btn:getTitleRenderer()
    self.red_point = self.btn:getChildByName("red_point")
    if self.btn.label ~= nil then
        self.btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    end
    self.tab_panel = self.main_container:getChildByName("tab_panel") 
    for i=1,3 do
        local btn = self.tab_panel:getChildByName("tab_btn_"..i)
        if btn then 
            local tab = {}
            tab.btn = btn
            btn:setVisible(false)
            tab.select_bg = btn:getChildByName("select_bg")
            tab.select_bg:setVisible(false)
            tab.title = btn:getChildByName("title")
            tab.title:enableOutline(Config.ColorData.data_color4[154],2)
            tab.icon = btn:getChildByName("icon")
            local res = PathTool.getPlistImgForDownLoad("actiongift", "actiongift_icon_"..i)
            tab.icon:loadTexture(res,LOADTEXT_TYPE)
            tab.index = i
            self.tab_list[i] = tab
        end
    end

    self.time_label = createRichLabel(24, 1, cc.p(0,0.5), cc.p(15,185))
    self.main_container:addChild(self.time_label)

    self:showEffect(true,250,"action",true)
end

function ActionGiftPanel:register_event(  )
	if not self.update_action_even_event  then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
            if data.bid == self.holiday_bid then  
                self.is_update = true
                self.holiday_data = data
                self:updateTabList(data)    
        	end
        end)
    end
    for i,tab in pairs(self.tab_list) do
        tab.btn:addTouchEventListener(function(sender, event_type) 
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self:changeTabIndex(tab.index)
            end
        end)
    end
    self.btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.limit_lev and self.role_vo then 
                if self.limit_lev > self.role_vo.lev then 
                    local str = TI18N("需等级达到")..self.limit_lev..TI18N("级才可购买")
                    message(str)
                    return
                end
            end
            if not self.select_btn then return end
            local vo = self.select_btn.vo 
            if not vo then return end
            if vo.status == 2 then 
                message(TI18N("您已领取过该礼包"))
                return
            end
            local function fun()    
                local vo = self.select_btn.vo 
                if not vo then return end  
                self.ctrl:cs16604(self.holiday_bid,vo.aim)
            end
            if self.reward_num >0 then
                local item_list = vo.item_list or {}
                if item_list and item_list[1] then 
                    local bid = item_list[1].bid or 0
                    local num = item_list[1].num or 0
                    local item_config = Config.ItemData.data_get_data(bid)
                    if item_config then 
                        local res = PathTool.getItemRes(item_config.icon)
                        local str = string.format(TI18N("是否花费<img src='%s' scale=0.4 />%s购买礼包？"),res,num)
                        CommonAlert.show(str,TI18N("确定"),fun,TI18N("取消"),nil,CommonAlert.type.rich,nil,nil,24)
                    end
                end
            else
                fun()
            end
		end
   	end)
end
function ActionGiftPanel:changeTabIndex(index)
    if self.is_update == false then
        if self.select_btn and self.select_btn.index == index then return end
    end
    self.is_update = false
    if self.select_btn then 
        self.select_btn.select_bg:setVisible(false)
        self.select_btn.title:enableOutline(Config.ColorData.data_color4[154],2)
    end

    self.select_btn = self.tab_list[index]
    if self.select_btn then 
        self.select_btn.select_bg:setVisible(true)
        self.select_btn.title:enableOutline(Config.ColorData.data_color4[167],2)
    end

    self:updateData()
end
function ActionGiftPanel:updateTabList(data)
    if not data then return end
    local aim_list = data.aim_list or {}
    for i=1,#aim_list do
        local vo = aim_list[i]
        if vo and self.tab_list[i] then 
            self.tab_list[i].btn:setVisible(true)
            local str = vo.aim_str or ""
            self.tab_list[i].title:setString(str)
            self.tab_list[i].vo = vo
        end
    end
    self:changeTabIndex(1)
end

function ActionGiftPanel:updateData()
    if not self.select_btn then return end
    local data = self.select_btn.vo 
    if not data then return end

    local item_list = data.item_list or {}
    local aim_args = data.aim_args or {}
    self.reward_num = 0
    self.limit_lev = 0
    for i,v in pairs(aim_args) do
        if v and v.aim_args_key ==1 then 
            self.reward_num = v.aim_args_val or 0
        elseif v and v.aim_args_key ==200 then 
            self.limit_lev = v.aim_args_val or 0
        elseif v and v.aim_args_key ==7 then 
            self.res_val = v.aim_args_val or 0
        end
    end
    local str = ""
    if self.reward_num <=0 then 
        str = TI18N("领取")
    else
        str = TI18N("抢购")
    end
    if self.holiday_data then
        local less_time = self.holiday_data.remain_sec or 0
        local time_str = string.format(TI18N("%s剩余时间：<div fontcolor=#35ff14>%s</div>"),str,TimeTool.GetTimeFormatDay(less_time))
        self.time_label:setString(time_str)
    end
    setChildUnEnabled(false,self.btn)
    self.btn.label:enableOutline(Config.ColorData.data_color4[154], 2)
    str = str..TI18N("大礼")
    self.red_point:setVisible(false)
    if data.status == 2 then 
        setChildUnEnabled(true,self.btn)
        self.btn.label:enableOutline(Config.ColorData.data_color4[151], 2)
        str = TI18N("已领取")
    elseif data.status == 1 and self.reward_num == 0 then
        self.red_point:setVisible(true)
    end
    self.btn:setTitleText(str)
    self:updateItemList(item_list)

    --更新资源
    self:updateRes()
end
function ActionGiftPanel:updateRes()
    if not self.select_btn then return end
    local vo = self.select_btn.vo
    local aim = vo.aim
    if self.mid_load then 
        self.mid_load:DeleteMe()
        self.mid_load = nil
    end
    --中央图标
    local res_id = PathTool.getPlistImgForDownLoad("actiongift", "actiongift_show_"..aim)
    if not self.mid_load then
        self.mid_load = createResourcesLoad(res_id, ResourcesType.single, function()
            if not tolua.isnull(self.mid_icon) then
                loadSpriteTexture(self.mid_icon,res_id,LOADTEXT_TYPE)
                self.mid_icon:setLocalZOrder(10)
            end
        end, self.mid_load)
        
    end

    --标题
    if self.title_load then 
        self.title_load:DeleteMe()
        self.title_load = nil
    end
    local res_id = PathTool.getPlistImgForDownLoad("actiongift", "txt_cn_actiongift_title_"..aim)
    if not self.title_load then
        self.title_load = createResourcesLoad(res_id, ResourcesType.single, function()
            if not tolua.isnull(self.label_bg) then
                loadSpriteTexture(self.label_bg,res_id,LOADTEXT_TYPE)
            end
        end, self.title_load)
        
    end

end
function ActionGiftPanel:updateItemList(item_list)
    local index = 1
    local all_num = #item_list or 0
    all_num = all_num - self.reward_num 
    local size = self.main_container:getContentSize()
    for i,v in pairs(self.item_list) do
        v:showItemEffect(false)
        v:setVisible(false)
    end
    local item_effect_list = self.holiday_data.item_effect_list or {}
    local effect_list = {}
    for i,v in pairs(item_effect_list) do
        effect_list[v.bid] = v
    end
    for i,v in pairs(item_list) do
        if self.reward_num <i then
            if not self.item_list[index] then 
                local item = BackPackItem.new(true,true,nil,0.9)
                self.main_container:addChild(item)
                item:setDefaultTip()
                self.item_list[index] = item
            end
            local offx = size.width/2-70-(all_num/2)*140+index*140
            self.item_list[index]:setPosition(cc.p(offx,290))
            local vo = {bid =v.bid,quantity =v.num}
            local config = Config.ItemData.data_get_data(v.bid)
            config.quantity = v.num
            self.item_list[index]:setData(config,true)
            self.item_list[index]:setVisible(true)
            self.item_list[index]:showItemEffect(false)
            if effect_list[v.bid] and effect_list[v.bid].effect_1 and effect_list[v.bid].effect_1==1 then 
                if config and config.quality >= 4 then
					self.item_list[index]:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
				else
					self.item_list[index]:showItemEffect(true, 263, PlayerAction.action_2, true, 1.1)
				end
                --self.item_list[index]:showItemEffect(true,165,"action",true,1.2)
            end
            index = index+1
        end
    end
end


function ActionGiftPanel:showEffect(bool,effect_id,action,is_loop)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
        if self.play_effect == nil and not tolua.isnull(self.main_container) then
            local size = self.main_container:getContentSize()
            local res = Config.EffectData.data_effect_info[effect_id]
            self.play_effect = createEffectSpine(res, cc.p(size.width/2-3,426), cc.p(0.5, 0.5), is_loop, action)
            self.main_container:addChild(self.play_effect, 1)
        end
	end
end 

function ActionGiftPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
    if bool == true then 
    	ActionController:getInstance():cs16603( self.holiday_bid)
    end
end

function ActionGiftPanel:DeleteMe()
	if self.item_list ~=nil then 
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
    self.item_list = nil
    if self.bg_load then 
        self.bg_load:DeleteMe()
        self.bg_load = nil
    end
    if self.mid_load then 
        self.mid_load:DeleteMe()
        self.mid_load = nil
    end
    if self.title_load then 
        self.title_load:DeleteMe()
        self.title_load = nil
    end
	if self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end
   self:showEffect(false)
end

