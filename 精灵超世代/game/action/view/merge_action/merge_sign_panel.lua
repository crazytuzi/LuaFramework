-- --------------------------------------------------------------------
-- 合服签到
--
-- @author: lc(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-10-
-- --------------------------------------------------------------------
MergeSignPanel = class("MergeSignPanel", function()
    return ccui.Widget:create()
end)

function MergeSignPanel:ctor(bid,function_id)
	self.ctrl = WelfareController:getInstance()
	self.model = self.ctrl:getModel()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self:configUI()
	self.holiday_bid = bid
	self:register_event()
end

function MergeSignPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/merge_seven_goal_panel"))
	self:addChild(self.root_wnd)
	self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("background")
    self.bg_sprite = self.main_container:getChildByName("Image_bg")
    local res = PathTool.getTargetRes("bigbg/action", "txt_cn_action_merge_sign_panel", false, false)
    if not self.item_load then
        self.item_load = loadSpriteTextureFromCDN(self.bg_sprite, res, ResourcesType.single, self.item_load)
    end
    local title = self.main_container:getChildByName("title")
    title:setString(TI18N("七日登陆即可领取！"))

    local layerReward = self.main_container:getChildByName("layerReward")
    self.touchTotleDay = {}
    for i=1, 7 do
        local tab = {}
        tab.btn = layerReward:getChildByName("reward_"..i)
        tab.red_point = tab.btn:getChildByName("redpoint")
        tab.red_point:setVisible(false)
        local textDay = tab.btn:getChildByName("day")
        textDay:setString(TI18N("第")..i..TI18N("天"))

        tab.textName = tab.btn:getChildByName("name")
        tab.textName:setString("")

        tab.getImg = tab.btn:getChildByName("get")
		tab.getImg:setVisible(false)

        tab.rewardImage = tab.btn:getChildByName("rewardImage")
        tab.show_day_icon = tab.btn:getChildByName("rewardItem")
        tab.show_day_icon:setScale(0.8)
        
        tab.rewardItem = BackPackItem.new(true, true, false, 0.6)
        tab.rewardItem:setDefaultTip(true)
        tab.rewardItem:setAnchorPoint(cc.p(0.5, 0.5))
        tab.rewardItem:setPosition(cc.p(tab.rewardImage:getContentSize().width/2, tab.rewardImage:getContentSize().height/2))
        tab.rewardImage:addChild(tab.rewardItem)

        self.touchTotleDay[i] = tab
    	tab.btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                ActionController:getInstance():cs16604(self.holiday_bid, i)
            end
        end)

    end
    
    self.main_container:getChildByName("time_txt"):setString(TI18N("剩余时间: "))
    self.time_label = self.main_container:getChildByName("time_num")
    self.time_label:setString(TI18N("00:00:00"))

	
end

function MergeSignPanel:createList( data )
	commonCountDownTime(self.time_label, data.remain_sec)
 	local data_list = data.aim_list
    local finish_day = data.finish  --当前签到天数
    for k,v in ipairs(data_list) do
	    local bid = v.item_list[1].bid
        local num = v.item_list[1].num
	    self.touchTotleDay[k].rewardItem:setGoodsName(Config.ItemData.data_get_data(bid).name,cc.p(57,-77),18,274,nil,0.7,nil,cc.size(140, 35))
    	self.touchTotleDay[k].rewardItem:setBaseData(bid, num)
    	if v.status == 1 then  --0-不能领取;1-可领取;2-已领取
    		self.touchTotleDay[k].red_point:setVisible(true)
    		self.touchTotleDay[k].getImg:setVisible(false)
    	elseif v.status == 2 then
    		self.touchTotleDay[k].red_point:setVisible(false)
    		self.touchTotleDay[k].getImg:setVisible(true)
    	else
    		self.touchTotleDay[k].red_point:setVisible(false)
    		self.touchTotleDay[k].getImg:setVisible(false)
    		--self.touchTotleDay[k].btn:setTouchEnabled(false)
    	end
    end
end


function MergeSignPanel:register_event(  )
	if not self.merge_sign_even_event  then
        self.merge_sign_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
            if data.bid == self.holiday_bid then
   				self.data = data
                self:createList(data)
            end
        end)
    end
end

function MergeSignPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
	ActionController:getInstance():cs16603(self.holiday_bid)   
end

function MergeSignPanel:DeleteMe()
	if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    if self.merge_sign_even_event then
        self.merge_sign_even_event = GlobalEvent:getInstance():UnBind(self.merge_sign_even_event)
        self.merge_sign_even_event = nil
    end        


end


