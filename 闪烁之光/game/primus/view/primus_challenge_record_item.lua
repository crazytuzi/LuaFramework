

PrimusChallengeRecordItem = class("PrimusChallengeRecordItem", function()
    return ccui.Widget:create()
end)

function PrimusChallengeRecordItem:ctor()
    self.ctrl = GuildwarController:getInstance()
    self.item_list = {}

    self:configUI()
    self:register_event()
end

function PrimusChallengeRecordItem:configUI(  )
    self.size = cc.size(616,218)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("primus/primus_challenge_record_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.name_label = self.container:getChildByName("name_label")
    self.time_label = self.container:getChildByName("time_label")
    self.attk_label = self.container:getChildByName("attk_label")
    self.magic_label = self.container:getChildByName("magic_label")
    local result_node = self.container:getChildByName("result_node")
    self.result_label = createRichLabel(22, 1, cc.p(1,0.5), cc.p(0,0))
    result_node:addChild(self.result_label)
    
    self.vedio_btn = self.container:getChildByName("vedio_btn")
    self.role_list = self.container:getChildByName("role_list")
    self.role_list:setTouchEnabled(false)

    local scrollCon_size = self.role_list:getContentSize()
    self.scroll_view_size = cc.size(scrollCon_size.width - 10, scrollCon_size.height)
    self.scroll_view = createScrollView(self.scroll_view_size.width,self.scroll_view_size.height,8,0,self.role_list,ccui.ScrollViewDir.horizontal)
    self.scroll_view:setSwallowTouches(false)
end

function PrimusChallengeRecordItem:register_event(  )
    self.vedio_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data and self.data.replay_id then
                BattleController:getInstance():csRecordBattle(self.data.replay_id)
            end
        end
    end)
end

function PrimusChallengeRecordItem:setData( data )
    self.data = data
    self.name_label:setString(string.format(TI18N("挑战者：%s"), data.name))
    self.attk_label:setString(string.format(TI18N("战力：%d"), data.power))
    self.time_label:setString(TimeTool.getYMDHMS(data.time))

    local form_data = Config.FormationData.data_form_data[data.formation_type]
    if form_data then
        self.magic_label:setString(form_data.name)
    end
    local num = data.num or 0
    self.result_label:setString(string.format(TI18N("<div fontColor=#A95F0F>挑战进化<div fontcolor=#249003>%s次</div>成功</div>"), data.num))

    -- 阵容
    local temp_partner_vo = {}
    for k,v in pairs(data.partner_list) do
        local vo = HeroVo.New()
        vo:updateHeroVo(v)
        table.insert(temp_partner_vo,vo)
    end

    local scale = 0.8
    local width = HeroExhibitionItem.Width
    local p_list_size = #temp_partner_vo
    local total_width = p_list_size * width*scale + (p_list_size - 1) * 6
    local start_x = 0
    local max_width = math.max(total_width,self.scroll_view_size.width) 
    self.scroll_view:setInnerContainerSize(cc.size(max_width,self.scroll_view_size.height))

    for i,v in ipairs(temp_partner_vo) do
        delayRun(self.container, i*4/60, function() 
            local partner_item = HeroExhibitionItem.new(scale, false)
            partner_item:setPosition(start_x+width*scale*0.5+(i-1)*(width*scale+6), self.scroll_view_size.height*0.5)
            partner_item:setData(v,nil,is_spec)
            self.scroll_view:addChild(partner_item)
            table.insert(self.item_list, partner_item)
        end)
    end
end

function PrimusChallengeRecordItem:DeleteMe(  )
    doStopAllActions(self.container)
    if self.item_list then
        for k,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
end