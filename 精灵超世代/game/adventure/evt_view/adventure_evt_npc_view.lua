-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--     npc对话框
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
AdventureEvtNpcView = AdventureEvtNpcView or BaseClass(BaseView)

local controller = AdventureController:getInstance()

function AdventureEvtNpcView:__init(data)
    self.win_type = WinType.Big
    self.is_full_screen = false
    self.btn_list ={}
    self.data = data
    self.config = data.config
    self.is_use_csb = false
    
    self.layout_name = "adventure/adventure_evt_npc_view"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("adventure", "adventure"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_18"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_45"), type = ResourcesType.single },
    }
    self.title_str = TI18N("npc对话框")
    self.role_vo = RoleController:getInstance():getRoleVo()
end

function AdventureEvtNpcView:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("root")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.title_label = self.main_container:getChildByName("title_label")
    self.role_bg = self.main_container:getChildByName("role_bg")
    self.bg = self.main_container:getChildByName("bg")
    loadSpriteTexture(self.role_bg,PathTool.getPlistImgForDownLoad("bigbg", "bigbg_45"), LOADTEXT_TYPE)
    self.bg:loadTexture(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_18"), LOADTEXT_TYPE)
    self.tips_desc_label = createRichLabel(26, 175, cc.p(0.5,1), cc.p(self.main_container:getContentSize().width / 2, 680), nil, nil, 610)
    self.main_container:addChild(self.tips_desc_label)
    self.tips_desc_label:setVisible(true)
    self.item_bg = self.main_container:getChildByName("item_bg")
end

function AdventureEvtNpcView:updateData(data)
    if self.config and data then
        local npc_answer_config = Config.AdventureData.data_adventure_npc_data[data.evt_id][data.id]
      
        local btn_size = cc.size(604,87)
        local count = 0
        table.sort(npc_answer_config,function (a,b)
            return  a.num < b.num
        end)
        if npc_answer_config then
            self.tips_desc_label:setString(npc_answer_config[1].lable_desc)

            local list = {[1] = "a", [2] = "b", [3] = "c" }
            local answer_list = {}
            local num = 0
            local answer_abcd = {[1] = "", [2] = "", [3] = "", [4] = "",}
            for i = 1, tableLen(npc_answer_config) do
                if not self.btn_list[i] then
                    local btn = createButton(self.item_bg, "", 0, 0, btn_size, PathTool.getResFrame("common", "common_1029"),26,Config.ColorData.data_color4[175],PathTool.getResFrame("common", "common_1020"))
                    btn:getRoot():setVisible(false)
                    local  tag = createSprite(PathTool.getResFrame("adventure","adventure_54"),520,btn_size.height/2,btn:getRoot())
                    tag:setVisible(false)
                    btn.i = i
                    btn.tag = tag
                    self.btn_list[i] = btn
                end
                local btn = self.btn_list[i]
                if btn then
                    btn:getRoot():setVisible(true)
                    btn:setBtnLabel(answer_abcd[i] .. npc_answer_config[i].msg)
                    btn:setPosition(self.item_bg:getContentSize().width / 2 , 230 - (btn_size.height + 5) * math.floor((i - 1)))
                    if btn then
                        btn:addTouchEventListener(function(sender, event_type)
                            if event_type == ccui.TouchEventType.began then
                                if self.btn_list then
                                    for i, btn in ipairs(self.btn_list) do
                                        if btn then
                                            btn.tag:setVisible(false)
                                        end
                                    end
                                end
                            elseif event_type == ccui.TouchEventType.ended then
                           
                                if self.data then
                                    local ext_list = { { type = 1, val = btn.i } }
                                    btn.tag:setVisible(true)
                                    controller:send20620(self.data.id, AdventureEvenHandleType.handle, ext_list)
                                end
                            elseif event_type == ccui.TouchEventType.canceled then
                                btn.tag:setVisible(false)
                            end
                        end,true)
                    end
                end
            end
        end
    end
end

function AdventureEvtNpcView:register_event()
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openEvtViewByType(false) 
            end
        end)
    end
    if not self.update_npc_info then
        self.update_npc_info = GlobalEvent:getInstance():Bind(AdventureEvent.Update_Evt_Npc_Info,function (data)
            self:updateData(data)
        end)
    end
end

function AdventureEvtNpcView:openRootWnd()
    if self.data then
        controller:send20620(self.data.id, AdventureEvenHandleType.requst, {})
    end
end

function AdventureEvtNpcView:close_callback()
    if self.update_npc_info then
        GlobalEvent:getInstance():UnBind(self.update_npc_info)
        self.update_npc_info = nil
    end
    controller:openEvtViewByType(false)
end