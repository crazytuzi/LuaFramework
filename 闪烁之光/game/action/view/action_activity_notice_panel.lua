--
-- @Author: lc
-- @Date:   2019-09-26 
-- @description:	活动预告
--
ActionActivityNoticePanel = class("ActionActivityNoticePanel", function()
	return ccui.Widget:create()
end)

local controller = ActionController:getInstance()
local model = ActionController:getInstance():getModel()
local string_format = string.format

function ActionActivityNoticePanel:ctor(bid)
	self.holiday_bid = bid
	self:configUI()
	self:register_event()
    self.sur_time = 0
end

function ActionActivityNoticePanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_activity_notice_panel"))
	self.root_wnd:setPosition(-40,-80)
	self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setAnchorPoint(0, 0)

    -- 背景
	self.background = self.root_wnd:getChildByName("bg") 
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/activitynotice", "txt_cn_activity_notice_bg")
    if not self.background_load then
        self.background_load = loadSpriteTextureFromCDN(self.background, bg_res, ResourcesType.single, self.background_load)
    end


    self.main_container = self.root_wnd:getChildByName("main_container")
    local main_container_size = self.main_container:getContentSize()    
    self.reward_btn = self.main_container:getChildByName("reward")

    self:upDate_reward_btn(0)
    
    self.list = {
            {val = 1, is_up = true},{val = 2, is_up = false},
            {val = 3, is_up = true},{val = 4, is_up = false},
            {val = 5, is_up = true},{val = 6, is_up = false} }
    if not self.scrollview then
        local setting = {
            item_class = ActionActivityNoticeItem,
            start_x = 15,
            space_x = 15,
            start_y = 0,
            space_y = 0,
            item_width = ActionActivityNoticeItem.Width,
            item_height = ActionActivityNoticeItem.Height + 80,
            row = 1,
            col = 1,
            scale = 1
        }
        self.scrollview = CommonScrollViewLayout.new(self.main_container, cc.p(0,-160) , ScrollViewDir.horizontal, ScrollViewStartPos.top, main_container_size, setting) 
    end
    
end

function ActionActivityNoticePanel:showMove()
    local now_time = GameNet:getInstance():getTime()
    --设置时间来偏移   预览
    --local  start_time1  =  os.time{year = 2019, month = 10, day = 1, hour = 00, min = 00, sec = 00}
    --local  start_time2  =  os.time{year = 2019, month = 10, day = 3, hour = 23, min = 59, sec = 59}
    --local  start_time3  =  os.time{year = 2019, month = 10, day = 6, hour = 23, min = 59, sec = 59}
    local  end_time4  =  os.time{year = 2019, month = 10, day = 9, hour = 23, min = 59, sec = 59}
    self.sur_time = end_time4 - now_time
    if self.sur_time <= 259200 and self.sur_time > 0  then -- 结束时间少于3天(10.7~10.9)
        self.scrollview:jumpToMove(cc.p(-360,0), 0.6)
    elseif self.sur_time <= 518400 then  -- 结束时间少于6天(10.4~10.6)
        self.scrollview:jumpToMove(cc.p(-180,0), 0.3)
    end
end


function ActionActivityNoticePanel:upDate_reward_btn( status )
    if self.box_effect then
        self.box_effect:clearTracks()
        self.box_effect:removeFromParent()
        self.box_effect = nil
    end
    if status == 0 then
        if not tolua.isnull(self.reward_btn) and self.box_effect == nil then
            self.box_effect = createEffectSpine(PathTool.getEffectRes(110), cc.p(40, 22), cc.p(0, 0), true, PlayerAction.action_2)
            self.reward_btn:addChild(self.box_effect)
        end
    else
        if not tolua.isnull(self.reward_btn) and self.box_effect == nil then
            self.box_effect = createEffectSpine(PathTool.getEffectRes(110), cc.p(40, 22), cc.p(0, 0), true, PlayerAction.action_3)
            self.reward_btn:addChild(self.box_effect)
        end
    end
end

function ActionActivityNoticePanel:setVisibleStatus( bool )
    bool = bool or false
    self:setVisible(bool) 
    if bool == true then 
        ActionController:getInstance():cs16603(self.holiday_bid)
        self.scrollview:setData(self.list)
        self:showMove()
    end
    
end
function ActionActivityNoticePanel:register_event()
    registerButtonEventListener(self.reward_btn, function() 
            controller:cs16604(self.holiday_bid,0)
    end, false, 1)
    if not self.update_action_activitynotice_event then
        self.update_action_activitynotice_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
            if not data then return end
            if data.bid == self.holiday_bid then
                if data.aim_list[1].status == 2 then   --已领取
                    self:upDate_reward_btn(1)
                end
            end
        end)
    end
end


function ActionActivityNoticePanel:DeleteMe()
    if self.background_load then 
        self.background_load:DeleteMe()
        self.background_load = nil
    end
    if self.box_effect then
        self.box_effect:clearTracks()
        self.box_effect:removeFromParent()
        self.box_effect = nil
    end
    if self.scrollview then
        self.scrollview:DeleteMe()
        self.scrollview = nil
    end
    if self.update_action_activitynotice_event then
        self.update_action_activitynotice_event = GlobalEvent:getInstance():UnBind(self.update_action_activitynotice_event)
        self.update_action_activitynotice_event = nil
    end

end

-- 预告 子项
--
-- @author: lc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
ActionActivityNoticeItem = class("ActionActivityNoticeItem", function()
    return ccui.Widget:create()
end)

ActionActivityNoticeItem.Width = 165
ActionActivityNoticeItem.Height = 542

function ActionActivityNoticeItem:ctor()
    self.ctrl = ActionController:getInstance()
    self:configUI()
    self:register_event()
end

function ActionActivityNoticeItem:configUI(  )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_activity_notice_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)
    self:setContentSize(cc.size(ActionActivityNoticeItem.Width,ActionActivityNoticeItem.Height))

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.sprite = self.main_container:getChildByName("Sprite")
end

function ActionActivityNoticeItem:setData( data )
    self.data = data
    local res_image = PathTool.getPlistImgForDownLoad("bigbg/activitynotice", "txt_cn_activity_notice_"..self.data.val,false)
    if not self.load_sprite then
        self.load_sprite = loadSpriteTextureFromCDN(self.sprite, res_image, ResourcesType.single, self.load_sprite)
    end
    if self.data.is_up == true then
        self:setPositionY(self:getPositionY()+60)
    end
end

function ActionActivityNoticeItem:register_event(  )
    
end


function ActionActivityNoticeItem:DeleteMe()
    if self.load_sprite then 
        self.load_sprite:DeleteMe()
        self.load_sprite = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end




