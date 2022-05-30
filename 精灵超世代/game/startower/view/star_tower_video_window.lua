-- --------------------------------------------------------------------
-- 竖版星命塔录像界面查看
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
StarTowerVideoWindow = StarTowerVideoWindow or BaseClass(BaseView)

function StarTowerVideoWindow:__init(data,tower)
    self.ctrl = StartowerController:getInstance()
    self.is_full_screen = false
    self.layout_name = "startower/star_tower_video"
    self.res_list = {
       
    }
    self.win_type = WinType.Mini   
    self.data = data 
    self.click_tower = tower
    self.first_id = 0
    self.next_id = 0
end

function StarTowerVideoWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.background:setVisible(true)

    self.main_panel = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_panel, 2)

    -- self.title_con = self.main_panel:getChildByName("title_con")
    self.title = self.main_panel:getChildByName("title_label")
    self.title:setString(TI18N("录像"))

    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.info_con = self.main_panel:getChildByName("info_con")
    self.first_btn = self.info_con:getChildByName("btn1")
    local first_btn_size = self.first_btn:getContentSize()
    self.first_btn_label = createRichLabel(26, 0, cc.p(0.5, 0.5), cc.p(first_btn_size.width/2, first_btn_size.height/2))
    self.first_btn:addChild(self.first_btn_label)
    self.first_btn_label:setString(string.format("<div fontColor=#ffffff fontsize=22 shadow=0,-3,3,%s>%s</div>", Config.ColorData.data_new_color_str[3], TI18N("查看")))
    -- self.first_btn:setTitleText(TI18N("查看"))
    -- self.first_btn.label = self.first_btn:getTitleRenderer()
    -- if self.first_btn.label ~= nil then
    --     self.first_btn.label:enableOutline(Config.ColorData.data_color4[264], 2)
    -- end
    -- local title = self.first_btn:getTitleRenderer()
    -- title:enableOutline(Config.ColorData.data_color4[264], 2)

    self.two_btn = self.info_con:getChildByName("btn2")
    local two_btn_size = self.two_btn:getContentSize()
    self.two_btn_label = createRichLabel(26, 0, cc.p(0.5, 0.5), cc.p(two_btn_size.width/2, two_btn_size.height/2))
    self.two_btn:addChild(self.two_btn_label)
    self.two_btn_label:setString(string.format("<div fontColor=#ffffff fontsize=22 shadow=0,-3,3,%s>%s</div>", Config.ColorData.data_new_color_str[3], TI18N("查看")))
    -- self.two_btn:setTitleText(TI18N("查看"))
    -- self.two_btn.label = self.two_btn:getTitleRenderer()
    -- if self.two_btn.label ~= nil then
    --     self.two_btn.label:enableOutline(Config.ColorData.data_color4[264], 2)
    -- end
    -- local title = self.two_btn:getTitleRenderer()
    -- title:enableOutline(Config.ColorData.data_color4[264], 2)


    self.my_look = self.info_con:getChildByName("btn4")
    local my_look_size = self.my_look:getContentSize()
    self.my_look_label = createRichLabel(26, 0, cc.p(0.5, 0.5), cc.p(my_look_size.width/2, my_look_size.height/2))
    self.my_look:addChild(self.my_look_label)
    self.my_look_label:setString(string.format("<div fontColor=#ffffff fontsize=22 shadow=0,-3,3,%s>%s</div>", Config.ColorData.data_new_color_str[3], TI18N("查看")))
    -- self.my_look:setTitleText(TI18N("查看"))
    -- self.my_look.label = self.my_look:getTitleRenderer()
    -- if self.my_look.label ~= nil then
    --     self.my_look.label:enableOutline(Config.ColorData.data_color4[264], 2)
    -- end
    -- local title = self.my_look:getTitleRenderer()
    -- title:enableOutline(Config.ColorData.data_color4[264], 2)

    self.share_btn = self.info_con:getChildByName("btn3") 

    -- local title_1 =self.info_con:getChildByName("qian_title_1")  
    -- title_1:setString(TI18N("最快"))

    -- local title_2 =self.info_con:getChildByName("qian_title_2")  
    -- title_2:setString(TI18N("最低"))

    self:createDesc()
end

function StarTowerVideoWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openVideoWindow(false)
        end
    end)
    self.background:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openVideoWindow(false)
        end
    end)

    self.first_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.first_id ~= 0 then
                BattleController:getInstance():csRecordBattle(self.first_id)
            end
        end
    end)

    self.two_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.next_id ~= 0 then
                BattleController:getInstance():csRecordBattle(self.next_id)
            end
        end
    end)

    self.my_look:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data and self.data.m_replay_id and self.data.m_replay_id ~= 0 then
                BattleController:getInstance():csRecordBattle(self.data.m_replay_id)
            end
        end
    end)

    self.share_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            local is_visible = true
            if self.share_panel then 
                is_visible = not self.share_panel:isVisible()
            end
            self:showSharePanel(is_visible)
        end
    end)
end

function StarTowerVideoWindow:showSharePanel(bool)
    if bool == false and not self.share_panel then return end

    
    if not self.share_panel then 
        local size = cc.size(200,160)
        self.share_panel = ccui.Widget:create()
        self.share_panel:setContentSize(size)
        self.main_panel:addChild(self.share_panel) 
        self.share_panel:setPosition(cc.p(290,170))

        local res = PathTool.getResFrame("common","common_1034")
        local bg = createImage(self.share_panel, res, size.width/2,size.height/2, cc.p(0.5,0.5), true, 0, true)
        bg:setContentSize(size)
        bg:setCapInsets(cc.rect(21,21,10,10))

        local res = PathTool.getResFrame("common","common_1017")
        local btn1 =  createButton(self.share_panel, TI18N("世界频道"), size.width/2, 120, cc.size(160,64), res, 22, Config.ColorData.data_color4[1])
        btn1:setRichText(string.format("<div fontsize=22 shadow=0,-3,3,%s>%s</div>",Config.ColorData.data_new_color_str[3], TI18N("世界频道")))
        btn1:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                if not self.data then return end
                StartowerController:sender11333(self.data.m_replay_id,1,self.click_tower)
                self:showSharePanel(false)
            end
        end)
        local btn2 =  createButton(self.share_panel, TI18N("公会频道"), size.width/2, 45, cc.size(160,64), res, 22, Config.ColorData.data_color4[1])
        btn2:setRichText(string.format("<div fontsize=22 shadow=0,-3,3,%s>%s</div>",Config.ColorData.data_new_color_str[3], TI18N("公会频道")))
        btn2:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                if not self.data then return end
                StartowerController:sender11333(self.data.m_replay_id,4,self.click_tower)
                self:showSharePanel(false)
            end
        end)
    end

    self.share_panel:setVisible(bool)
end

function StarTowerVideoWindow:createDesc()
    self.top_head = PlayerHead.new(PlayerHead.type.circle)
    self.top_head:setTouchEnabled(true)
    self.top_head:setScale(0.9)
    self.top_head:setPosition(cc.p(90,298))
    self.top_head:setAnchorPoint(cc.p(0.5,0.5))
    self.info_con:addChild(self.top_head)

    self.bottom_head = PlayerHead.new(PlayerHead.type.circle)
    self.bottom_head:setTouchEnabled(true)
    self.bottom_head:setScale(0.9)
    self.bottom_head:setPosition(cc.p(90,178))
    self.bottom_head:setAnchorPoint(cc.p(0.5,0.5))
    self.info_con:addChild(self.bottom_head)

    self.my_head = PlayerHead.new(PlayerHead.type.circle)
    self.my_head:setTouchEnabled(true)
    self.my_head:setScale(0.9)
    self.my_head:setPosition(cc.p(90,61))
    self.my_head:setAnchorPoint(cc.p(0.5,0.5))
    self.info_con:addChild(self.my_head)


    self.top_name = createLabel(24,Config.ColorData.data_new_color4[7],nil,165,300,"",self.info_con,2, cc.p(0,0))

    self.bottom_name = createLabel(24,Config.ColorData.data_new_color4[7],nil,165,183,"",self.info_con,2, cc.p(0,0))

    self.fast_desc = createRichLabel(24,Config.ColorData.data_new_color4[6],cc.p(0,1),cc.p(165,300),nil,nil,300)
    self.info_con:addChild(self.fast_desc)

    self.power_desc = createRichLabel(24,Config.ColorData.data_new_color4[6],cc.p(0,1),cc.p(165,180),nil,nil,300)
    self.info_con:addChild(self.power_desc)

    self.my_name = createLabel(24,Config.ColorData.data_new_color4[6],nil,165,60,"",self.info_con,2, cc.p(0,0))
    self.my_name:setString(TI18N("我的通关录像"))
    self.my_time = createRichLabel(24,Config.ColorData.data_new_color4[6],cc.p(0,1),cc.p(165,55),nil,nil,300)
    self.info_con:addChild(self.my_time)
    local str = string.format(TI18N("时间：<div fontColor=%s>%s</div>"),Config.ColorData.data_new_color_str[11],TimeTool.GetTimeFormat(self.data.my_time))
    self.my_time:setString(str)

    if not self.data then return end

    local list =  self.data.tower_replay_data or {}
    for i,v in pairs(list) do
        if v and v.type == 1 then 
            local str = string.format(TI18N("通关时间：<div fontColor=%s>%s</div>"),Config.ColorData.data_new_color_str[11],TimeTool.GetTimeFormat(v.time))
            self.fast_desc:setString(str)
            self.top_name:setString(v.name)
            self.top_head:setHeadRes(v.face_id, false, LOADTEXT_TYPE, v.face_file, v.face_update_time)
            -- self.top_head:setLev(v.lev)
            self.first_id = v.replay_id
        else
            local str = string.format(TI18N("最低战力：<div fontColor=%s>%s</div>"),Config.ColorData.data_new_color_str[11],v.power)
            self.power_desc:setString(str)
            self.bottom_name:setString(v.name)
            self.bottom_head:setHeadRes(v.face_id, false, LOADTEXT_TYPE, v.face_file, v.face_update_time)
            self.next_id = v.replay_id
            -- self.bottom_head:setLev(v.lev)
        end
        
    end


    local rold_vo = RoleController:getInstance():getRoleVo()
    self.my_head:setHeadRes(rold_vo.face_id, false, LOADTEXT_TYPE, rold_vo.face_file, rold_vo.face_update_time)

    if self.data.m_replay_id and self.data.m_replay_id == 0 then 
        self.my_look:setVisible(false)
        self.share_btn:setVisible(false)
        self.my_time:setString(TI18N("暂无"))
    end
end

function StarTowerVideoWindow:openRootWnd()
end

--[[
    @desc: 设置标签页面板数据内容
    author:{author}
    time:2018-05-03 21:57:09
    return
]]
function StarTowerVideoWindow:setPanelData()
end

function StarTowerVideoWindow:close_callback()
    self.ctrl:openVideoWindow(false)

    if self.bottom_head then 
        self.bottom_head:DeleteMe()
        self.bottom_head = nil
    end
    if self.my_head then 
        self.my_head:DeleteMe()
        self.my_head = nil
    end
    if self.top_head then 
        self.top_head:DeleteMe()
        self.top_head = nil
    end
end







