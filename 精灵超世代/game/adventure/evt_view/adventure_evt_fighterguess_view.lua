-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      猜拳事件
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
AdventureEvtFighterGuessWindow = AdventureEvtFighterGuessWindow or BaseClass(BaseView)

local controller = AdventureController:getInstance()

function AdventureEvtFighterGuessWindow:__init(data)
    self.win_type = WinType.Mini
    self.data = data
    self.config = data.config
    self.layout_name = "adventure/adventure_finger_guessing_view"
    self.is_full_screen = false
    self.is_use_csb = false
    self.item_list = {}
    self.ext_list = {}
    self.btn_list ={}
    self.item_btn = {}
    self.cur_btn_index = nil
    self.cur_item_index = nil
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("adventure", "adventure"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_22"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_21"), type = ResourcesType.single },
    }
end

function AdventureEvtFighterGuessWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("root")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.bg = self.main_container:getChildByName("bg")
    loadSpriteTexture(self.bg, PathTool.getPlistImgForDownLoad("bigbg", "bigbg_21"), LOADTEXT_TYPE)
    self.bottom_container = self.main_container:getChildByName("bottom_container")
    self.title = self.main_container:getChildByName("window_title_label")
    self.title:setString(TI18N("猜拳"))
    self.swap_desc_label = createRichLabel(20, Config.ColorData.data_new_color4[1], cc.p(0.5,0.5), cc.p(210,750), nil, nil, 260)
    self.main_container:addChild(self.swap_desc_label)
    self.swap_desc_label:setVisible(true)
    self.desc_label = self.main_container:getChildByName("desc_label")
    self.guide_container = self.main_container:getChildByName("guide_container")
    self.guide_container_pos = cc.p(self.guide_container:getPositionX(),self.guide_container:getPositionY())
    self.guidel_label = self.guide_container:getChildByName("guide_label")
    self.guidel_label:setString(TI18N('请下注'))
    if Config.AdventureData.data_adventure_const["describe_mora"] then
        self.desc_label:setString(Config.AdventureData.data_adventure_const["describe_mora"].val)
    end
    for i = 1, 4 do
        local item_btn = self.bottom_container:getChildByName(string.format("item_button_%s", i))
        item_btn.label = item_btn:getChildByName("item_label") --tab_btn:getTitleRenderer()
        item_btn:setBright(false)
        item_btn.index = i
        self.item_btn[i] = item_btn
    end
    self:updatedata()
end

function AdventureEvtFighterGuessWindow:updatedata()
    if self.config then
        self.swap_desc_label:setString(string.format(TI18N("<div outline=2,%s>%s</div>"), Config.ColorData.data_new_color_str[6], self.config.desc))
        self:updateItemData(self.config.lose)
        self:updateGuessContainer()
    end
end

function AdventureEvtFighterGuessWindow:updateGuessContainer()
    --左边动作
    if not tolua.isnull(self.main_container) and self.left_effect == nil then 
        self.left_effect = createEffectSpine(PathTool.getEffectRes(134), cc.p(210, 606), cc.p(0.5, 0.5), true, PlayerAction.action_4)
        self.main_container:addChild(self.left_effect)
    end

    if not tolua.isnull(self.main_container) and self.right_effect == nil then 
        self.right_effect = createEffectSpine(PathTool.getEffectRes(134), cc.p(510, 606), cc.p(0.5, 0.5), true, PlayerAction.action_4)
        self.right_effect:setScaleX(-1)
        self.main_container:addChild(self.right_effect)
        setChildUnEnabled(true, self.right_effect)

    end
    
    --right
    for i = 1, 3 do
            local tab_btn = self.main_container:getChildByName(string.format("Button_%s", i))
            tab_btn.label = tab_btn:getChildByName("title") --tab_btn:getTitleRenderer()
            tab_btn:setBright(false)
            tab_btn.index = i
            self.btn_list[i] = tab_btn
    end
end

function AdventureEvtFighterGuessWindow:selectBtn(index)
    self:deleteExtlist(1)
    if self.cur_select_index == index then
        if self.cur_tab ~= nil then
            self.cur_tab:setBright(false) 
            self.cur_tab = nil
            self.cur_select_index = nil
        end
        return
    end
    if self.cur_tab ~= nil then
        self.cur_tab:setBright(false)
    end
    self.cur_select_index = index
    self.cur_tab = self.btn_list[index]
    if self.cur_tab ~= nil then
        self.cur_tab:setBright(true)
    end
    table.insert(self.ext_list, { type = 1, val = index })
    self:checkAsk()
end


function AdventureEvtFighterGuessWindow:deleteExtlist(type)
    if self.ext_list then
        for i, v in ipairs(self.ext_list) do
            if v.type == type then
                table.remove(self.ext_list, i)
            end
        end
    end
end

function AdventureEvtFighterGuessWindow:updateItemData(data)
    if data then
        for i, v in ipairs(data) do
            local label = self.item_btn[i].label
            if label then
                label:setString(v[2])
            end
 
        end 
    end
end

function AdventureEvtFighterGuessWindow:selecItem(index)
    self:deleteExtlist(2)
    if self.cur_item_index == index then
        if self.cur_item_tab ~= nil then
            self.cur_item_tab:setBright(false)
            self.cur_item_tab = nil
            self.cur_item_index = nil
        end
        self.guide_container:setVisible(true)
        self.guide_container:runAction(cc.Sequence:create(cc.MoveTo:create(0.4,cc.p(self.guide_container_pos)),cc.CallFunc:create(function ()
            self.guidel_label:setString(TI18N("请下注"))
        end)))
        return
    end
    if self.cur_item_tab ~= nil then
        self.cur_item_tab:setBright(false)
    end
    self.cur_item_index = index
    self.cur_item_tab = self.item_btn[index]
    if self.cur_item_tab ~= nil then
        self.cur_item_tab:setBright(true)
    end
    self.guide_container:setVisible(true)
    self.guide_container:runAction(cc.Sequence:create(cc.MoveTo:create(0.4,cc.p(150,390)),cc.CallFunc:create(function ()
        self.guidel_label:setString(TI18N("请出拳"))
    end)))
    table.insert(self.ext_list, { type = 2, val = index })
    self:checkAsk()
end

function AdventureEvtFighterGuessWindow:checkAsk()
    if self.data == nil then return end
    local count = 0
    for i, v in ipairs(self.ext_list) do
        count = count + 1 
    end
    if count >= 2 then
        self.guide_container:setVisible(false)
        controller:send20620(self.data.id, AdventureEvenHandleType.handle,self.ext_list)
    end
end
function AdventureEvtFighterGuessWindow:register_event()
    for k, tab_btn in pairs(self.btn_list) do
        if tab_btn then
            tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:selectBtn(tab_btn.index)
                end
            end)
        end
    end
    for k, item_btn in pairs(self.item_btn) do
        if item_btn then
            item_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:selecItem(item_btn.index)
                end
            end)
        end
    end
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openEvtViewByType(false) 
            end
        end)
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openEvtViewByType(false) 
            end
        end)
    end
    if not self.figtherguess_event then
        self.figtherguess_event = GlobalEvent:getInstance():Bind(AdventureEvent.Update_Evt_Guess_Result,function (data)
            if data then
                self:updateResult(data)
            end
        end)
    end
end

function AdventureEvtFighterGuessWindow:updateResult(data)
    if self.left_effect then
        local action_name = "action"..data.sel_val
        self.left_effect:setAnimation(0, action_name, false)
    end
    if self.right_effect then
        local action_name = "action" .. data.ret_val
        self.right_effect:setAnimation(0, action_name, false)
   
    end
    local str = ""
    if data.ret == 0 then
        str = TI18N("趁你没输，赶紧回去吧")
    elseif data.ret == 1 then
        str = TI18N("愿赌服输，你赢了")
    else
        str = TI18N("小子，回去练练再来")
    end
    delayOnce(function()
        self:showStr(str)
    end,0.8)

    delayOnce(function()
        controller:openEvtViewByType(false) 
        controller:showGetItemTips(data.items, true, data.ret) 
    end,3)
end

--打字机效果
function AdventureEvtFighterGuessWindow:showStr(str)
    local list,len = StringUtil.splitStr(str)
    local temp_str = ""
    for i, v in ipairs(list) do
        delayRun(self.root_wnd,0.1 * i,function ()
            temp_str = temp_str .. v.char
            self.swap_desc_label:setString(string.format(TI18N("<div outline=2,%s>%s</div>"), Config.ColorData.data_new_color_str[6], temp_str))
        end)
    end
end

function AdventureEvtFighterGuessWindow:openRootWnd(type)
end

function AdventureEvtFighterGuessWindow:close_callback()
    self.ext_list = {}
    if self.figtherguess_event then
        GlobalEvent:getInstance():UnBind(self.figtherguess_event)
        self.figtherguess_event = nil
    end
    controller:openEvtViewByType(false)
end