-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      循环赛连胜buff
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaLoopChallengeBuffWindow = ArenaLoopChallengeBuffWindow or BaseClass(BaseView)

function ArenaLoopChallengeBuffWindow:__init()
    self.ctrl = ArenaController:getInstance()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.ctrl = ArenaController:getInstance()
    self.model = self.ctrl:getModel()
    self.win_type = WinType.Mini
    self.item_list = {}
    self.layout_name = "arena/arena_loop_challenge_buff_window"
end

function ArenaLoopChallengeBuffWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)
    self.close_btn = self.container:getChildByName("close_btn")

    self.effect_container = self.container:getChildByName("effect_container")
    self.title = self.effect_container:getChildByName("title")                  -- 当前效果
    self.title:setString(TI18N("当前效果"))
    self.con_win = self.effect_container:getChildByName("con_win")              -- 已连胜次数
    self.con_win:setString(string.format(TI18N("已连胜%s次"),10))

    self.explain_container = self.container:getChildByName("explain_container")
    self.explain_title = self.explain_container:getChildByName("title")
    self.explain_title:setString(TI18N("连胜效果说明"))

    self.buff_item = self.container:getChildByName("buff_item")
    self.buff_item:setVisible(false)

    self.scroll_view = self.explain_container:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
    self.scroll_size = self.scroll_view:getContentSize()
end

function ArenaLoopChallengeBuffWindow:register_event()
    self.background:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                ArenaController:getInstance():openLoopChallengeBuffWindow(false)
            end
        end
    )
    self.close_btn:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                ArenaController:getInstance():openLoopChallengeBuffWindow(false)
            end
        end
    )
end

function ArenaLoopChallengeBuffWindow:openRootWnd()
    if next(self.item_list) == nil then
        local list_size = Config.ArenaData.data_continue_list_length
        local height = 54
        local space = 8
        local max_height = list_size * height + (list_size + 1) * space
        max_height = math.max(max_height, self.scroll_size.height)
        self.scroll_view:setInnerContainerSize(cc.size(self.scroll_size.width, max_height))
        for i,v in ipairs(Config.ArenaData.data_continue_list) do
            local node = self.buff_item:clone()
            local buff_item = ArenaLoopChallengeBuffItem.new(node)
            buff_item:setData(v)
            self.scroll_view:addChild(buff_item)
            self.item_list[i] = buff_item
            local _y = max_height - (i - 1) * (height + space) - (height * 0.5 + space)
            buff_item:setPosition(self.scroll_size.width * 0.5, _y)
        end
    end
    self:setCurEffect()
end

--[[
    @desc:设置当前的连胜buff效果
    author:{author}
    time:2018-05-16 18:04:17
    return
]]
function ArenaLoopChallengeBuffWindow:setCurEffect()
    local my_data = ArenaController:getInstance():getModel():getMyLoopData()
    if my_data ~= nil then
        if my_data.cont_win > 0 then
            self.con_win:setString(string.format(TI18N("已连胜%s次"), my_data.cont_win))
            if self.my_buff_desc == nil then
                self.my_buff_desc = createRichLabel(22, cc.c3b(0xa9, 0x5f, 0x0f), cc.p(0, 0.5), cc.p(130, 30), nil, nil, 260)
                self.effect_container:addChild(self.my_buff_desc)
            end
            self.my_buff_desc:setVisible(true)

            local buff_desc = ""
            local buff_config = Config.BuffData.data_get_buff_data[my_data.buffid]
            if buff_config ~= nil then
                buff_desc = string.format("<img src=%s visible=true scale=1 /><div>%s</div>  ", PathTool.getBuffRes(buff_config.icon), buff_config.des)
            end

            local item_desc = ""
            local cont_config = Config.ArenaData.data_continue[my_data.cont_win]
            if cont_config ~= nil then
                for i,v in ipairs(cont_config.items) do
                    if item_desc ~= "" then
                        item_desc = item_desc.." "
                    end
                    item_desc = string.format("%s<img src=%s visible=true scale=0.5 /><div fontcolor=#289b14 fontsize=22>X%s</div>", item_desc, PathTool.getItemRes(v[1]), v[2])
                end
            end
            self.my_buff_desc:setString(buff_desc..item_desc)
        else
            self.con_win:setString(TI18N("暂无连胜纪录"))
            if self.my_buff_desc ~= nil then
                self.my_buff_desc:setVisible(false)
            end
        end
    end
end

function ArenaLoopChallengeBuffWindow:close_callback()
    for i,v in pairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = nil
    self.ctrl:openLoopChallengeBuffWindow(false)
end


-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      连胜效果说明单元
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaLoopChallengeBuffItem = class("ArenaLoopChallengeBuffItem", function()
    return ccui.Layout:create()
end)

function ArenaLoopChallengeBuffItem:ctor(node)
    self.node = node
    self.size = self.node:getContentSize()

    self:setContentSize(self.size)
    self:setAnchorPoint(0.5, 0.5)
    self:addChild(self.node)
    self.node:setVisible(true)
    self.node:setPosition(0,0)

    self.desc = self.node:getChildByName("desc")

    self:registerEvent()
end

function ArenaLoopChallengeBuffItem:registerEvent()

end

function ArenaLoopChallengeBuffItem:setData(data)
    if data == nil then return end
    self.data = data
    self.desc:setString(string.format(TI18N("连胜%s次"), data.num))

    if self.my_buff_desc == nil then
        self.my_buff_desc = createRichLabel(22, cc.c3b(0xa9, 0x5f, 0x0f), cc.p(0, 0.5), cc.p(130, 30), nil, nil, 260)
        self.node:addChild(self.my_buff_desc)
    end
    self.my_buff_desc:setVisible(true)

    local buff_desc = ""
    local buff_config = Config.BuffData.data_get_buff_data[data.buff]
    if buff_config ~= nil then
        buff_desc =
            string.format(
            "<img src=%s visible=true scale=1 /><div>%s</div>",
            PathTool.getBuffRes(buff_config.icon),
            buff_config.des
        )
    end

    local item_desc = ""
    local cont_config = Config.ArenaData.data_continue[data.num]
    if cont_config ~= nil then
        for i, v in ipairs(cont_config.items) do
            if item_desc ~= "" then
                item_desc = item_desc .. " "
            end
            item_desc =
                string.format(
                "%s<img src=%s visible=true scale=0.5 /><div fontcolor=#289b14 fontsize=22>X%s</div>",
                item_desc,
                PathTool.getItemRes(v[1]),
                v[2]
            )
        end
    end
    self.my_buff_desc:setString(buff_desc .. item_desc)
end

function ArenaLoopChallengeBuffItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end