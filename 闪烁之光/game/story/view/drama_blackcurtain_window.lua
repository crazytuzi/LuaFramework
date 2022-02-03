--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-10-13 18:47:01
-- @description    : 
		-- 剧情黑幕
---------------------------------
DramaBlackCurtainWindow = DramaBlackCurtainWindow or BaseClass(BaseView)

local controller = StoryController:getInstance()
local story_view = controller:getView() 

function DramaBlackCurtainWindow:__init(  )
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.MSG_TAG
	self.is_full_screen = true
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("drama", "drama"), type = ResourcesType.plist},
	}
	self.layout_name = "drama/drama_blackcurtain_window"
	
    self.label_list = {}
    self.interval_time = 1.5
    self.end_time = 1
end

function DramaBlackCurtainWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")

    self.star_bg = self.container:getChildByName("star_bg")

    self.container_size = self.container:getContentSize()
end

function DramaBlackCurtainWindow:register_event(  )
	self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.label_index <= #self.label_list then
                self:openDramaActionTimer(false)
                local label_next = self.label_list[self.label_index+1]
                if label_next then
                    local label_cur = self.label_list[self.label_index]
                    if label_cur then
                        label_cur:stopAllActions()
                        label_cur:setOpacity(255)
                    end

                    for i=1,(#self.label_list-self.label_index) do
                        local show_next = self.label_list[self.label_index+1]
                        self.label_index = self.label_index + 1
                        if show_next then
                            show_next:runAction(cc.FadeIn:create(1.5))
                        end
                    end
                    self.label_index = #self.label_list
                    -- self:openDramaActionTimer(true)
                else
                    self.container:runAction(cc.Sequence:create(cc.FadeOut:create(1), cc.CallFunc:create(function()
                        story_view:showBlackCurtain(false)
                        GlobalEvent:getInstance():Fire(StoryEvent.PLAY_NEXT_ACT)
                    end)))
                end
            else
                self.container:runAction(cc.Sequence:create(cc.FadeOut:create(1), cc.CallFunc:create(function()
                    story_view:showBlackCurtain(false)
                    GlobalEvent:getInstance():Fire(StoryEvent.PLAY_NEXT_ACT)
                end)))
            end    
        end
    end)
end

function DramaBlackCurtainWindow:showDramaMsg( msg_data ,interval_time, end_time)
    msg_data = msg_data or ""
    self.interval_time = interval_time or 1.5
    self.end_time = end_time or 1.5
    
    local msg_list = {}
    while string.find(msg_data, '&') do
        local index = string.find(msg_data, '&')
        local temp_str = string.sub(msg_data, 1, index-1)
        msg_data = string.gsub(msg_data,temp_str.."&","")

        table.insert(msg_list, temp_str)
    end
    table.insert(msg_list, msg_data)

    for k,label in pairs(self.label_list) do
    	label:stopAllActions()
    	label:removeFromParent()
    	label = nil
    end

    local num = #msg_list

    local star_bg_posy = self.container_size.height/2 - (num-1)*20 - 30
    self.star_bg:setPositionY(star_bg_posy)
    for i,msg in ipairs(msg_list) do
    	local pos_y = star_bg_posy + 110 + (num - i)*50
    	local label = createLabel(26,cc.c3b(255,226,181),nil,self.container_size.width/2,pos_y,msg,self.container,nil, cc.p(0.5, 0.5))
    	label:setOpacity(0)
    	table.insert(self.label_list, label)
        if i == 1 then
            label:runAction(cc.FadeIn:create(1.5))
        end
    end

    self.label_index = 1
    self:openDramaActionTimer(true)
end

function DramaBlackCurtainWindow:openDramaActionTimer( status )
    if status == true then
        if self.dramaActionTimer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.dramaActionTimer)
            self.dramaActionTimer = nil
        end
        self.dramaActionTimer = GlobalTimeTicket:getInstance():add(function()
            self.label_index = self.label_index + 1
            if self.label_index <= #self.label_list then
                local label = self.label_list[self.label_index]
                label:runAction(cc.FadeIn:create(1.5))
            else
                self.dramaEndTimer = GlobalTimeTicket:getInstance():add(function()
                    self.container:runAction(cc.Sequence:create(cc.FadeOut:create(1), cc.CallFunc:create(function()
                        story_view:showBlackCurtain(false)
                        GlobalEvent:getInstance():Fire(StoryEvent.PLAY_NEXT_ACT)
                    end)))

                    GlobalTimeTicket:getInstance():remove(self.dramaEndTimer)
                    self.dramaEndTimer = nil
                end, self.end_time)

                GlobalTimeTicket:getInstance():remove(self.dramaActionTimer)
                self.dramaActionTimer = nil
            end
        end, self.interval_time)
    else
        if self.dramaActionTimer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.dramaActionTimer)
            self.dramaActionTimer = nil
        end

        if self.dramaEndTimer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.dramaEndTimer)
            self.dramaEndTimer = nil
        end
    end
end

function DramaBlackCurtainWindow:openRootWnd( msg_data )
	self:showDramaMsg(msg_data)
end

function DramaBlackCurtainWindow:close_callback(  )
	story_view:showBlackCurtain(false)
    self:openDramaActionTimer(false)
	self.container:stopAllActions()

	for k,label in pairs(self.label_list) do
		label:stopAllActions()
    	label:removeFromParent()
    	label = nil
    end
end