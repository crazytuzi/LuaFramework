-- --------------------------------------------------------------------
-- 
-- 
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xhj(必填, 后续维护以及修改的人员)
-- @description:
--      奇遇界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EncounterWindow = EncounterWindow or BaseClass(BaseView)

local controller = EncounterController:getInstance()
local model = controller:getModel()
local table_insert = table.insert

function EncounterWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big

    self.is_full_screen = true
    self.layout_name = "encounter/encounter_window"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("encounter","encounter"), type = ResourcesType.plist},
		{ path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_89",true), type = ResourcesType.single}
    }

    
    self.cur_id = nil
    self.cur_desc_index = 1 --当前对话
    self.max_index = 1
    self.cur_select_index = 1 --当前选中的选项
    self.is_show_btn = true --是否显示跳过和继续按钮
    self.is_show_answer = false --是否显示答案
    self.is_finish = false --是否完成
    self.is_have_answer = true --是否有答案
    self.btn_list = {}
    self.sub_tab_array = {}
    self.role_vo = RoleController:getInstance():getRoleVo()
end

function EncounterWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.main_view = self.main_panel:getChildByName("container")
    self.info_panel = self.main_view:getChildByName("info_panel")
    
    self.bg = self.info_panel:getChildByName("bg")
    self.role_img = self.info_panel:getChildByName("role_img")
    self.back_bg = self.info_panel:getChildByName("back_bg")
    self.back_bg:setOpacity(0)
    self.answer_container = self.info_panel:getChildByName("answer_container")
    self.answer_container:setVisible(false)
    self.next_btn = self.info_panel:getChildByName("next_btn") -- 点击继续
    self.next_btn_arr = self.next_btn:getChildByName("btn") --箭头
    self.next_btn_lab = self.next_btn:getChildByName("label")
    self.skip_btn = self.info_panel:getChildByName("skip_btn") -- 跳过
    self.tips_button = self.main_panel:getChildByName("tips_button")
    self.name_bg = self.info_panel:getChildByName("name_bg")
    self.role_name = self.name_bg:getChildByName("name_lab")
    
    self.close_tips = self.main_panel:getChildByName("close_tips")
    self.close_tips:setVisible(false)
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.win_title = self.main_panel:getChildByName("win_title")
    self.Image_2 = self.main_panel:getChildByName("Image_2")
    
    self.win_title:setString(TI18N("宝可梦物语"))

    self.not_tips = self.main_view:getChildByName("not_tips")
    self.not_tips:setVisible(false)
    commonShowEmptyIcon(self.not_tips, false)
    self.tips_lab = createRichLabel(22, 175, cc.p(0.5, 1), cc.p(309.5, 280),10,nil,400)
    self.not_tips:addChild(self.tips_lab)
    self.tips_lab:setString(TI18N("     暂时没有新的物语\n点击".."<div fontcolor=289b14 href=detial>前往</div>".."查看物语图鉴"))
    local function clickLinkCallBack( type, value )
        if type == "href" and value == "detial" then
            controller:send27102()
            controller:openEncounterWindow(false)
            controller:openEncounterLibraryWindow(true)
        end
    end
    self.tips_lab:addTouchLinkListener(clickLinkCallBack,{"href"})

    self.tab_container = self.main_panel:getChildByName("tab_container")
    self.tab_container:setVisible(false)
    -- if not self.sub_tab_list then
    --     local panel_size = self.tab_container:getContentSize()
    --     self.sub_tab_list = CommonSubBtnList.new(self.tab_container, cc.p(0.5, 0.5), cc.p(panel_size.width*0.5, panel_size.height*0.5), cc.size(156, 50), handler(self, self._onClickSubTabBtn))
    -- end
end 

function EncounterWindow:_onClickSubTabBtn( index )
    local isFinish = model:isFinishByid(index)
    if isFinish == true then
        self.cur_desc_index = 1
        self.cur_id = index
        self:updateInfo()
    else
        message(TI18N("暂未获得此物语"))
    end
    
end

function EncounterWindow:register_event()

    registerButtonEventListener(self.background, function (  )
        if self.is_show_btn == false and self.cur_desc_index ~= self.max_index then
            message(TI18N("请选择答案"))
            return
        end
        if self.cur_desc_index+1>self.max_index then
            if self.is_finish == false then
                controller:send27101()
            end
            controller:openEncounterWindow(false)
            return
        end
        self.cur_desc_index = self.cur_desc_index+1
		self:updateInfo()
    end, nil, 2)


    registerButtonEventListener(self.close_btn, function (  )
        if self.is_finish == false then
            if self.cur_id and self.cur_desc_index == self.max_index then
                controller:send27101()
            end
        end

		controller:openEncounterWindow(false)
    end, true, 2)

    registerButtonEventListener(self.info_panel, function (  )
        if self.is_show_btn == false and self.cur_desc_index ~= self.max_index then
            message(TI18N("请选择答案"))
            return
        end
        if self.cur_desc_index+1>self.max_index then
            if self.is_finish == false then
                controller:send27101()
            end
            controller:openEncounterWindow(false)
            return
        end
        self.cur_desc_index = self.cur_desc_index+1
		self:updateInfo()
    end, false, 1)

    registerButtonEventListener(self.skip_btn, function (  )
        if self.is_finish == false then
            local msg = TI18N("是否跳过对话领取奖励")
            CommonAlert.show(msg, TI18N("确定"),function() 
                controller:send27101()
                controller:openEncounterWindow(false)
            end, TI18N("取消"))
            return
        end
        local msg = TI18N("是否跳过对话")
        CommonAlert.show(msg, TI18N("确定"),function() 
            controller:openEncounterWindow(false)
        end, TI18N("取消"))
    end, true, 1)
    
    if self.tips_button then
        self.tips_button:addTouchEventListener(function (sender,event_type)
            if ccui.TouchEventType.ended == event_type then
                playButtonSound()
                local config = Config.EncounterData.data_encounter_const.rules
                if config then
                    TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)    
                end
            end
        end)
    end
end

function EncounterWindow:updateInfo()
    if not self.cur_id then
        self.info_panel:setVisible(false)
        commonShowEmptyIcon(self.not_tips, true, {text = "",pos = cc.p(309.5, 360)})
        self.not_tips:setVisible(true)
        return
    end
    
    local cfg = Config.EncounterData.data_encounter_info[self.cur_id]
    if not cfg then return end
    
    if self.is_have_answer == true and cfg.answer and cfg.answer[1] and cfg.answer[1] == 0 then
        self.is_have_answer = false
    end
    
    local descCfg = cfg.dialogue[self.cur_desc_index];
    if not descCfg then return end

    self.max_index = #cfg.dialogue
    --名字
    if descCfg[1] == "" then
        self.role_name:setString(self.role_vo.name)
    else
        self.role_name:setString(descCfg[1])
    end
    
    --阴影
    local actionFade = cc.FadeOut:create(0.2)
    if descCfg[3] == 1 then
        actionFade = cc.FadeIn:create(0.2)
        self.name_bg:setPosition(140,187.00)
    else
        self.name_bg:setPosition(477.5,187.00)
    end
    doStopAllActions(self.back_bg)
    self.back_bg:runAction(actionFade)

    --对话 
    if not self.desc_name then
        self.desc_name = createRichLabel(22, cc.c3b(65, 32, 23), cc.p(0,1), cc.p(40, 150), 5, 0, 540)
        self.info_panel:addChild(self.desc_name)
    end

    
    
    --立绘
    if descCfg[4] ~= self.cur_hero_id then
        self.cur_hero_id = descCfg[4]
        local bust_res = PathTool.getPartnerBustRes(descCfg[4])
        if self.bust_load then
            self.bust_load:DeleteMe()
        end
        self.bust_load = nil

        if not self.bust_load then
            self.bust_load = createResourcesLoad(bust_res, ResourcesType.single, function()
                if self.role_img then
                    
                    local action1 = cc.FadeOut:create(0.2)
                    local action2 = cc.FadeIn:create(0.2)
                    doStopAllActions(self.role_img)
                    self.role_img:runAction(cc.Sequence:create(action1, cc.CallFunc:create(function()
                        if self.role_img then
                            self.role_img:loadTexture(bust_res,LOADTEXT_TYPE)
                        end
                    end),action2))
                end
            end,self.bust_load)
        end
    end
    

    if self.btn_list then
        for i, btn in ipairs(self.btn_list) do
            if btn then
                btn:getRoot():setVisible(false)
            end
        end
    end

    if descCfg[2] == 1 then
        self.is_show_btn = false;
        local btn_size = cc.size(333, 48)
        local num = #cfg.answer
        for i=1,num do
            if not self.btn_list[i] then
                local btn = createButton(self.answer_container, "", 0, 0, btn_size, PathTool.getResFrame("encounter", "encounter_1004"), 22, Config.ColorData.data_color4[175], PathTool.getResFrame("encounter", "encounter_1004"))
                btn:setCapInsets(cc.rect(18, 20, 1, 1))
                btn:getRoot():setVisible(false)    
                local answer = createLabel(22, cc.c3b(64, 32, 23), nil, 166.5, 24, "", btn:getRoot(), nil, cc.p(0.5, 0.5))
                btn.answer = answer
                btn.index = i
                self.btn_list[i] = btn
            end

            local btn = self.btn_list[i]
            if btn then
                btn:getRoot():setVisible(true)
                btn.answer:setString(cfg.answer[i][2])
                btn:setPosition(self.answer_container:getContentSize().width/2, self.answer_container:getContentSize().height-(btn_size.height+40)*i)
                if btn then
                    btn:addTouchEventListener(function(sender, event_type)
                        if event_type == ccui.TouchEventType.ended then
                            self.cur_select_index = btn.index;
                            if self.is_finish == false then
                                controller:send27104(self.cur_select_index)
                            end
                            
                            if self.cur_desc_index+1>self.max_index then
                                controller:openEncounterWindow(false)
                                return
                            end
                            self.cur_desc_index = self.cur_desc_index+1
                            self:updateInfo()
                        end
                    end, true)
                end
            end
        end
        self.is_show_answer = true
    else
        self.is_show_answer = false
        self.answer_container:setVisible(false)
    end
    self.next_btn:setVisible(self.is_show_btn)
    self.skip_btn:setVisible(self.is_show_btn)
    
    if self.cur_desc_index == self.max_index then
        self.next_btn:setVisible(false)
        
        if self.is_finish == true then
            self.close_tips:setVisible(true)
        else
            self.next_btn_lab:setString(TI18N("结束并领取奖励"))
            self.next_btn:setPosition(490,37)
            self.next_btn_arr:setVisible(false)
        end
    end

    local index = string.find(descCfg[5], "&&")
    if index then
        local descArr= string.split(descCfg[5], "&&")
        if descArr and #descArr > 0 then
            self:showStr(descArr[self.cur_select_index])
        end
    else
        self:showStr(descCfg[5])
    end

    if self.is_finish == false then
        model:setEncounterPage(self.cur_desc_index)
        controller:send27103(self.cur_id,self.cur_desc_index)
    end
end

--打字机效果
function EncounterWindow:showStr(str)
    doStopAllActions(self.info_panel)
    local list,len = StringUtil.splitStr(str)
    local temp_str = ""
    for i, v in ipairs(list) do
        delayRun(self.info_panel,0.05 * i,function ()
            temp_str = temp_str .. v.char
            self.desc_name:setString(temp_str)
            if self.is_show_answer == true and i>=#list then
                self.answer_container:setVisible(true)
            end
            if i>=#list and self.is_finish == false and self.cur_desc_index == self.max_index then
                self.next_btn:setVisible(true)
                self.next_btn:setOpacity(0)
                self.next_btn:setScale(0)
                local action1 = cc.FadeIn:create(0.2)
                local action2 = cc.ScaleTo:create(0.2,1)
                doStopAllActions(self.next_btn)
                self.next_btn:runAction(cc.Sequence:create(action1,action2))
            end
        end)
    end
end

-- 获取默认的组id列表
-- function EncounterWindow:getEncounterIdList( partner_bid )
-- 	local tempArr = {}
--     for k,v in pairs(Config.EncounterData.data_encounter_info) do
--         if v.partner_bid == partner_bid then
--             local status = model:isFinishByid(v.id)
--             table_insert(tempArr,{index = v.id,title = v.name,status = status,tips = TI18N("暂未获得此物语")})   
--         end
-- 	end
-- 	return tempArr
-- end

function EncounterWindow:openRootWnd(id)
    local curID = model:getEncounterId()
    -- local is_update_pos = false
    if curID ~= id or id == 0 then
        self.is_finish = true
        
        -- local cfg = Config.EncounterData.data_encounter_info[id]
        -- if cfg then 
        --     local arr = self:getEncounterIdList(cfg.partner_bid)
        --     self.sub_tab_array = arr
        -- end
        -- if #self.sub_tab_array<=1 then
        --     self.tab_container:setVisible(false)
        -- else
        --     table.sort(self.sub_tab_array, function(a, b) return a.index < b.index end)
        --     self.sub_tab_list:setData(self.sub_tab_array, id)
        --     self.tab_container:setVisible(true)
        --     is_update_pos = true
        -- end
    else
        local page = model:getEncounterPage()
        if page == nil or page<1 then
            page = 1
        end
        self.cur_desc_index = page
        -- self.tab_container:setVisible(false)
    end

    -- if is_update_pos == true then
    --     self.main_panel:setContentSize(cc.size(676,749))
    --     self.main_view:setContentSize(cc.size(644,709))
    --     self.close_btn:setPosition(662,731)
    --     self.win_title:setPosition(338,749)
    --     self.Image_2:setPosition(335,743)
        
    -- end
    
    
    if id and id>0 then
        self.cur_id = id
    else
        self.cur_id = nil
    end
    
    self:updateInfo();
end


function EncounterWindow:close_callback()
    controller:openEncounterWindow(false)
    doStopAllActions(self.info_panel)
    doStopAllActions(self.back_bg)
    doStopAllActions(self.role_img)
    doStopAllActions(self.next_btn)
    if self.bust_load then
        self.bust_load:DeleteMe()
    end
    self.bust_load = nil

end
