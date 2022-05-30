-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      事件答题界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

AdventureEvtAnswerWindow = AdventureEvtAnswerWindow or BaseClass(BaseView)

local controller = AdventureController:getInstance() 

function AdventureEvtAnswerWindow:__init(data)
    self.win_type = WinType.Mini
    self.data = data
    self.config = data.config
    self.layout_name = "adventure/adventure_evt_answer_view"
    self.is_full_screen = false
    self.is_use_csb = false
    self.item_list = {}
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("adventure", "adventure"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_25"), type = ResourcesType.single },
    }
    self.btn_list = {}
    self.str = ""
end
function AdventureEvtAnswerWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("root")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.start_container = self.main_container:getChildByName("start_container")
    self.role_bg = self.main_container:getChildByName("role_bg")
    loadSpriteTexture(self.role_bg,PathTool.getPlistImgForDownLoad("bigbg", "bigbg_25"),LOADTEXT_TYPE)
    self.total_desc = self.main_container:getChildByName("total_desc")
    self.total_desc:setString(TI18N("全对奖励"))
    self.title_label = self.main_container:getChildByName("title_label")
    self.title_label:setString(TI18N("智力大乱斗"))
    self.this_desc = self.main_container:getChildByName("this_desc")
    self.this_desc:setString(TI18N("当前奖励"))
    self.item_container = self.main_container:getChildByName('item_container')
    self.base_reward_label = createRichLabel(24, 117, cc.p(0, 0.5), cc.p(315,455), nil, nil, 500)
    self.main_container:addChild(self.base_reward_label)
    self.base_reward_label:setVisible(true)
    self.talk_bg = self.main_container:getChildByName("talk_bg")
    self:updatedata()
end

function AdventureEvtAnswerWindow:updatedata()
    if self.config then
    end
end

function AdventureEvtAnswerWindow:updateBackItem(bag_base_items)
    if bag_base_items then
        local item_width = BackPackItem.Width * #bag_base_items
        local total_width = #bag_base_items * BackPackItem.Height + #bag_base_items * 5
        self.start_x = (self.item_container:getContentSize().width - total_width ) * 0.5
        for i, v in ipairs(bag_base_items) do
            if not self.item_list[i] then
                local item = BackPackItem.new(true, true)
                item:setAnchorPoint(cc.p(0,0.5))
                self.item_list[i] = item
                self.item_container:addChild(item)
            end
            local temp_item = self.item_list[i]
            if temp_item then
                temp_item:setBaseData(v.bid, v.num)
                temp_item:setDefaultTip()
                local _x = self.start_x + (i - 1) * (BackPackItem.Width + 10)
                temp_item:setPosition(_x,self.item_container:getContentSize().height/2)
            end
        end
    end
end


function AdventureEvtAnswerWindow:register_event()
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openAnswerView(false)
            end
        end)
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openAnswerView(false)
            end
        end)
    end
    if not self.update_evt_answer then
        self.update_evt_answer = GlobalEvent:getInstance():Bind(AdventureEvent.Update_Evt_Answer_Info,function (data)
            self:updateAnswerData(data)
        end)
    end
end


function AdventureEvtAnswerWindow:updateAnswerData(data)
    self.answer_data = data
    self.cur_answer_bid = data.bid
    if data.now_items and next(data.now_items or {}) ~= nil then
        self.str = ""
        for i, v in pairs(data.now_items) do
            if Config.ItemData.data_get_data(v.bid) then
                local icon = Config.ItemData.data_get_data(v.bid).icon
                local str_ = string.format("<div><img src='%s' scale=0.4 /></div><div fontcolor=#ffce0c fontsize=26>%s   </div>", PathTool.getItemRes(icon), v.num)
                self.str = self.str .. str_
            end
        end
    end
    self.base_reward_label:setString(self.str)
    self:updateBackItem(data.max_items)
    if data.ret == 0 then
        self:updateNext()
    else
        --先展示答案正确再下一题
        self.main_container:runAction(cc.Sequence:create(cc.CallFunc:create(function ()
            --展示答案
            if self.btn_list then
                for i, btn in ipairs(self.btn_list) do
                    btn.right:setVisible(false)
                    btn.fail:setVisible(false)
                    if btn and btn.index == data.sel_val then --自己选择
                        if data.ret == 1 then
                            btn.right:setVisible(true)
                        else
                            btn.fail:setVisible(true)
                        end
                    elseif btn and btn.index == data.right then --正确答案
                        if data.ret == 2 then
                            btn.right:setVisible(true)
                        end
                    end
                end
            end
        end),cc.DelayTime:create(1),cc.CallFunc:create(function ()
            if data.bid == 0 then --没有题目了
                controller:openAnswerView(false)
                message(data.ret_msg)
                if data.ret_items and next(data.ret_items or {}) ~= nil then
                    controller:showGetItemTips(data.ret_items)
                end
            else
                self:updateNext()
            end
        end)))
    end
end

function AdventureEvtAnswerWindow:updateNext()
    if not self.answer_num then
        self.answer_num = createRichLabel(26, 175, cc.p(0, 1), cc.p(345, 960))
        self.main_container:addChild(self.answer_num)
    end
    if not self.answer_desc then
        self.answer_desc = createRichLabel(26, 175, cc.p(0, 1), cc.p(345, 920), nil, nil, 325)
        self.main_container:addChild(self.answer_desc)
    end
    if self.answer_num then
        self.answer_num:setString(TI18N("第") .. self.answer_data.num .. "/" .. self.answer_data.max .. TI18N("题"))
    end
    if self.answer_data.bid ~= 0 then
    if self.btn_list then
        for i, btn in ipairs(self.btn_list) do
            if btn then
                btn:getRoot():setVisible(false)
            end
        end
    end
    local config = Config.AdventureData.data_adventure_answer[self.answer_data.bid]
    self.answer_desc:setString(config.desc)
    local answer_config = Config.AdventureData.data_adventure_kind_answer[self.answer_data.bid]
    local btn_size = cc.size(290, 87)
    local count = 0
    if answer_config then
        local list = {[1] = "a", [2] = "b", [3] = "c", [4] = "d" }
        local answer_list = {}
        local num = 0
        for i = 1, 4 do
            if answer_config[list[i]] and string.len(answer_config[list[i]]) > 0 then
                answer_list[i] = answer_config[list[i]]
                num = num + 1
            end
        end
        local answer_abcd = {[1] = "A ", [2] = "B ", [3] = "C ", [4] = "D ",}
        for i = 1, num do
            if not self.btn_list[i] then
                local btn = createButton(self.start_container, "", 0, 0, btn_size, PathTool.getResFrame("common", "common_1029"), 26, Config.ColorData.data_color4[175], PathTool.getResFrame("common", "common_1020"))
                btn:getRoot():setVisible(false)
                local tag = createSprite(PathTool.getResFrame("adventure", "adventure_50"), 55, btn_size.height / 2, btn:getRoot())
                tag:setVisible(true)
              
                local name = createLabel(33, 175, nil, 89, 45, "", btn:getRoot(), nil, cc.p(0, 0.5), "fonts/title.ttf")
                btn.name = name
                local answer = createLabel(26, 175, nil, 120, 47, "", btn:getRoot(), nil, cc.p(0, 0.5))
                btn.answer = answer
                local right = createSprite(PathTool.getResFrame("adventure", "adventure_54"), 240, btn_size.height / 2, btn:getRoot())
                right:setVisible(false)
                local fail = createSprite(PathTool.getResFrame("adventure", "adventure_47"), 240, btn_size.height / 2, btn:getRoot())
                fail:setVisible(false)
                btn.fail = fail
                btn.right = right
                btn.index = i
                self.btn_list[i] = btn
            end
            local btn = self.btn_list[i]
            if btn then
                btn:getRoot():setVisible(true)
                btn.fail:setVisible(false)
                btn.right:setVisible(false)
                btn.name:setString(answer_abcd[i])
                btn.answer:setString(answer_list[i])
                btn:setPosition(155 + (btn_size.width + 20) * ((i - 1) % 2), 160 - (btn_size.height + 20) * math.floor((i - 1) / 2))
                if btn then
                    btn:addTouchEventListener(function(sender, event_type)
                        if event_type == ccui.TouchEventType.ended then
                            if self.data then
                                local ext_list = { { type = 1, val = btn.index } }
                                controller:send20620(self.data.id, AdventureEvenHandleType.handle, ext_list)
                            end
                        end
                    end, true)
                end
            end
        end
    end
end
end


function AdventureEvtAnswerWindow:openRootWnd()
    if self.data then
        controller:send20620(self.data.id, AdventureEvenHandleType.requst, {})
    end
end

function AdventureEvtAnswerWindow:close_callback()
    for k, item in pairs(self.item_list) do
        item:DeleteMe()
    end
    self.item_list = nil
    
    if self.update_evt_answer then 
        GlobalEvent:getInstance():UnBind(self.update_evt_answer)
        self.update_evt_answer = nil
    end
    controller:openAnswerView(false)
end