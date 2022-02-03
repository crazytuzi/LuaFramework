-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      循环赛查看待挑战者信息面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaLoopChallengeCheckWindow = ArenaLoopChallengeCheckWindow or BaseClass(BaseView)

local table_insert = table.insert

function ArenaLoopChallengeCheckWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.ctrl = ArenaController:getInstance()
    self.model = self.ctrl:getModel()
    self.win_type = WinType.Mini
    self.item_list = {}
    self.layout_name = "arena/arena_loop_challenge_check_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arena", "arenaloop"), type = ResourcesType.plist}
    }
end

function ArenaLoopChallengeCheckWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    
    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    self.close_btn = container:getChildByName("close_btn")

    self.scroll_view = container:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
    self.scroll_size = self.scroll_view:getContentSize()

    self.challenge_btn = container:getChildByName("challenge_btn")
    self.challenge_btn_label = self.challenge_btn:getChildByName("label")
    self.challenge_btn_label:setString(TI18N("挑 战"))

    self.role_name = container:getChildByName("role_name")
    self.role_score = container:getChildByName("role_score")
    self.score_title = container:getChildByName("score_title")
    -- self.score_title:setString(TI18N("段位经验："))
    self.score_title:setString(TI18N("竞技场积分："))

    self.fight_label = CommonNum.new(20, container, 99999, -2, cc.p(0, 0.5))
    self.fight_label:setPosition(460, 280)

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(94, 323)
    container:addChild(self.role_head)

    self.container = container
end

function ArenaLoopChallengeCheckWindow:register_event()
    self.background:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                ArenaController:getInstance():openCheckLoopChallengeRole(false)
            end
        end
    )
    self.close_btn:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                ArenaController:getInstance():openCheckLoopChallengeRole(false)
            end
        end
    )
    self.challenge_btn:addTouchEventListener(
        function(sender, event_type)
            customClickAction(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.data ~= nil then
                    ArenaController:getInstance():openCheckLoopChallengeRole(false)
                    ArenaController:getInstance():requestFightWithLoopChallenge(self.data.rid, self.data.srv_id)
                end
            end
        end
    )
end

function ArenaLoopChallengeCheckWindow:openRootWnd(data)
    self.data = data
    if self.data ~= nil then
        self.role_name:setString(self.data.name)
        self.fight_label:setNum(self.data.power)
        self.role_head:setHeadRes(self.data.face, false, LOADTEXT_TYPE, self.data.face_file, self.data.face_update_time)
        self.role_head:setLev(self.data.lev)
        self.role_score:setString(self.data.score)
    end
    self:setCheckRoleHero()
end

--[[
    @desc:设置伙伴列表
    author:{author}
    time:2018-05-14 19:16:39
    return
]]
function ArenaLoopChallengeCheckWindow:setCheckRoleHero()
    if self.data == nil or self.data.p_list == nil then return end
    local p_list_size = #self.data.p_list
    local total_width = p_list_size * 104 + (p_list_size - 1) * 6
    local start_x = ( self.scroll_size.width - total_width ) / 2 
    local partner_item = nil
    for i,v in ipairs(self.data.p_list) do
        delayRun(self.container, 4*i/60, function() 
            partner_item = HeroExhibitionItem.new(0.8, true)
            partner_item:setPosition(start_x+104*0.5+(i-1)*(104+6), self.scroll_size.height*0.5)
            partner_item:setData(v)
            partner_item:addCallBack(function()
                if(self.data) then
                    ArenaController:getInstance():requestRabotInfo(self.data.rid, self.data.srv_id, v.pos)
                end
            end)
            self.scroll_view:addChild(partner_item)
            table_insert( self.item_list, partner_item)
        end)
    end
end

function ArenaLoopChallengeCheckWindow:close_callback()
    doStopAllActions(self.container)
    if self.fight_label then
        self.fight_label:DeleteMe()
        self.fight_label = nil
    end
    for k, v in pairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = nil
    self.ctrl:openCheckLoopChallengeRole(false)
end