-- --------------------------------------------------------------------
-- 竖版星命塔挑战主界面
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
StarTowerMainWindow = StarTowerMainWindow or BaseClass(BaseView)
local table_insert = table.insert
function StarTowerMainWindow:__init(data)
    self.ctrl = StartowerController:getInstance()
    self.is_full_screen = false
    self.layout_name = "startower/star_tower_main"
    self.cur_type = 0
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("startower","startower"), type = ResourcesType.plist },
        -- { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_26"), type = ResourcesType.single },
    }
   self.data = data
   local title = data.name or ""
   self.title_str = title
   self.item_list = {}
   self.win_type = WinType.Big
end

function StarTowerMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")    
    self:playEnterAnimatianByObj(self.main_panel, 1)

    self._dianmond = self.main_panel:getChildByName("dianmond")
    self._dianmond:setVisible(false)
    self.title = self.main_panel:getChildByName("title")
    self.title:setString(self.title_str)

    self.top_panel = self.main_panel:getChildByName("top_panel")
    self.award_panel = self.main_panel:getChildByName("award_panel")

    -- 引导需要
    self.fight_btn = self.main_panel:getChildByName("btn1")
    self.fight_btn:setTitleText(TI18N("挑战"))
    local title = self.fight_btn:getTitleRenderer()   
    title:enableOutline(Config.ColorData.data_color4[264], 2)
    
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.clean_btn = self.main_panel:getChildByName("btn2")
    local title_1 = self.clean_btn:getTitleRenderer()   
    title_1:enableOutline(Config.ColorData.data_color4[263], 2)
    self.clean_btn:setTitleText("")
    local size = self.clean_btn:getContentSize()
    self.clean_label = createRichLabel(26,1, cc.p(0.5,0.5),cc.p(size.width * 0.5 , size.height * 0.5))
    self.clean_btn:addChild(self.clean_label)

    self:changeClearTitleText()

    self.video_btn = self.top_panel:getChildByName("video_btn")
    local label = self.video_btn:getChildByName("label")
    label:setString(TI18N("通关录像"))

    local label  =self.award_panel:getChildByName("label")
    label:setString(TI18N("挑战奖励"))

    self.no_label =  createLabel(24,Config.ColorData.data_color4[175],nil,435,55,"",self.main_panel,nil,cc.p(0,0))
    self.no_label:setString(TI18N("挑战成功可进行扫荡"))
    self.no_label:setVisible(false)
    self.main_panel:runAction(
        cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()
            if self and self.updateModel then
                self:updateModel(self.data)
            end
    end)))

    if self.data then
        self.ctrl:sender11325(self.data.lev)
    end
    self:updateDesc()
    self:updateGoodsList()
end
--改变扫荡按钮的状态
function StarTowerMainWindow:changeClearTitleText()
    --已购买次数
    local buyCount = self.ctrl:getModel():getBuyCount() or 0
    --剩余挑战次数
    local count = self.ctrl:getModel():getTowerLessCount()
    --最大塔数
    local tower = self.ctrl:getModel():getNowTowerId() or 0

    if count > 0 then
        self.clean_label:setString(TI18N("<div outline=2,#2B610D>扫荡</div>"))
    else
        local buy_data = Config.StarTowerData.data_tower_buy[buyCount + 1]
        if buy_data then
            local item_data = Config.ItemData.data_get_data(buy_data.expend[1][1])
            local str = string.format(TI18N("<img src=%s scale=0.45 visible=true /><div outline=2,#2B610D>%s%s</div>"),PathTool.getItemRes(item_data.icon), buy_data.expend[1][2],TI18N("扫荡"))
            self.clean_label:setString(str)
        else
            --容错的
            self.clean_label:setString(TI18N("<div outline=2,#2B610D>扫荡</div>"))
        end
    end
end
function StarTowerMainWindow:updateModel(data)
    if not data then return end
    if not self.partner_model then 
        self.partner_model = BaseRole.new(BaseRole.type.unit, data.unit_id)
        self.partner_model:setAnimation(0,PlayerAction.show,true) 
        self.top_panel:addChild(self.partner_model)
        self.partner_model:setPosition(cc.p(313,310))
    end
end

function StarTowerMainWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openStarTowerMainView(false)
        end
    end)
    self.background:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openStarTowerMainView(false)
        end
    end)
    self.fight_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if not self.data then return end
            local tower = self.data.lev or 0
            HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.Startower, {tower_lev = tower})
        end
    end)
    self.clean_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if not self.data then return end

            local count = self.ctrl:getModel():getTowerLessCount() or 0
            if count <= 0 then 
                self:openBuyCountPanel()
                return
            end

            local tower = self.data.lev or 0
            self.ctrl:sender11324(tower)
        end
    end)

    self.video_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if not self.video_data then return end
            if not self.video_data.tower_replay_data or next(self.video_data.tower_replay_data) ==nil then 
                message(TI18N("暂时没有玩家通过此关，努力成为第一名吧！"))
                return
            end
            self.ctrl:openVideoWindow(true,self.video_data,self.data.lev)
        end
    end)
    if not self.video_data_event then 
        self.video_data_event = GlobalEvent:getInstance():Bind(StartowerEvent.Video_Data_Event,function(data)
            self.video_data = data
            self:updateVideoData(data)
        end)
    end

    if not self.fight_success_event then 
        self.fight_success_event =  GlobalEvent:getInstance():Bind(StartowerEvent.Fight_Success_Event,function()
            --挑战完成请求一下录像，可能自己破记录了
            if self.data then
                self.ctrl:sender11325(self.data.lev)
            end
            self:updateGoodsList()
        end)
    end

    if not self.clear_title_change_event then 
        self.clear_title_change_event =  GlobalEvent:getInstance():Bind(StartowerEvent.Count_Change_Event,function( )
            self:changeClearTitleText()
        end)
    end
end
--次数不足弹开购买次数界面
function StarTowerMainWindow:openBuyCountPanel()
    local free_count = Config.StarTowerData.data_tower_const["free_times"].val
    local have_buycount = self.ctrl:getModel():getBuyCount() or 0
    local role_vo = RoleController:getInstance():getRoleVo()
    local config = Config.StarTowerData.data_tower_vip[role_vo.vip_lev]
    local function fun()
        local tower = self.data.lev or 0
        self.ctrl:sender11324(tower)
    end
    if config and config.buy_count then 
        if have_buycount >= config.buy_count then
            message(TI18N("本日扫荡次数已达上限"))
        else
            local buy_config = Config.StarTowerData.data_tower_buy[have_buycount+1]
            if buy_config and buy_config.expend and buy_config.expend[1] and buy_config.expend[1][1] then 
                local item_id = buy_config.expend[1][1]
                local num = buy_config.expend[1][2] or 0
                local item_config = Config.ItemData.data_get_data(item_id)
                if item_config and item_config.icon then
                    local res = PathTool.getItemRes(item_config.icon)
                    local str = string.format( TI18N("是否花费<img src='%s' scale=0.3 />%s购买一次挑战次数？"),res, num)
                    CommonAlert.show(str,TI18N("确定"),fun,TI18N("取消"),nil,CommonAlert.type.rich,nil,nil,24)
                end
            end
        end
    end
end
function StarTowerMainWindow:updateVideoData(data)
    if not data then return end

    if not self.fast_desc then 
        self.fast_desc = createRichLabel(24,Config.ColorData.data_color4[175],cc.p(0,1),cc.p(20,-12),nil,nil,300)
        self.top_panel:addChild(self.fast_desc)
    end

    if not self.power_desc then 
        self.power_desc = createRichLabel(24,Config.ColorData.data_color4[175],cc.p(0,1),cc.p(20,-52),nil,nil,300)
        self.top_panel:addChild(self.power_desc)
    end
    self.fast_desc:setString(TI18N("最快通关：暂无"))
    self.power_desc:setString(TI18N("最低战力：暂无"))
    local list = data.tower_replay_data or {}
    for i,v in pairs(list) do
        if v and v.type == 1 then 
            local str = string.format(TI18N("最快通关：%s"),v.name)
            self.fast_desc:setString(str)
        else
            local str = string.format(TI18N("最低战力：%s"),v.name)
            self.power_desc:setString(str)
        end
    end
end
function StarTowerMainWindow:updateDesc()
    if not self.data then return end
    --boss描述
    self.boss_desc = createRichLabel(24,Config.ColorData.data_color4[175],cc.p(0,1),cc.p(20,110),nil,nil,620)
    self.top_panel:addChild(self.boss_desc)
    --推荐战力
    self.boss_power =createRichLabel(24,Config.ColorData.data_color4[175],cc.p(0,0),cc.p(20,15),nil,nil,620)
    self.top_panel:addChild(self.boss_power)

    local desc = self.data.desc or ""
    self.boss_desc:setString(TI18N("怪物特点：")..desc)

    local power = self.data.recommend or 0
    local str = string.format(TI18N("推荐战力：<div fontcolor=#289b14>%s</div>"),power)
    self.boss_power:setString(str)
end

function StarTowerMainWindow:openRootWnd()
end

--更新物品消耗
function StarTowerMainWindow:updateGoodsList()
    if not self.data then return end
    for i,v in pairs(self.item_list) do 
        v:setVisible(false)
    end
    local expend_list = {}
    
    local now_id = self.ctrl:getModel():getNowTowerId() or 0
    if now_id < self.data.lev then 
        local first_id  = 0
        local num = 0
        if self.data.first_show[1] and self.data.first_show[1][1] and self.data.first_show[1][2] then
            first_id = self.data.first_show[1][1]
            num = self.data.first_show[1][2]
        end
        table_insert(expend_list,{[1]=first_id,[2]=num,[3]=true})
    end

    for i,v in pairs( self.data.award) do
        table_insert(expend_list,v)
    end

    local index  =1
    local size = self.award_panel:getContentSize()
    for i,v in pairs(expend_list) do 
        if not self.item_list[index] then 
            local item = BackPackItem.new(true,true,nil,0.9)
            item:setDefaultTip()
            self.award_panel:addChild(item)
            self.item_list[index] = item
        end

        self.item_list[index]:setPosition(cc.p(90+150*(index-1),70))
        local config = Config.ItemData.data_get_data(v[1])
        if config then
            self.item_list[index]:setData(config)
            self.item_list[index]:setVisible(true)
            self.item_list[index]:setNum(v[2])
        end
        self.item_list[index]:showBiaoQian(false)
        if v and v[3] and v[3] == true then 
            self.item_list[index]:showBiaoQian(true,TI18N("首通"))
        end
        index = index +1
    end

    local now_tower = self.ctrl:getModel():getNowTowerId() or 0
    if self.data.lev > now_tower then 
        self.clean_btn:setVisible(false)
        self.fight_btn:setPosition(cc.p(338,78))
        self.no_label:setVisible(true)
    else
        self.clean_btn:setVisible(true)
        self.no_label:setVisible(false)
        self.fight_btn:setPosition(cc.p(178,78))
    end
end

--[[
    @desc: 切换标签页
    author:{author}
    time:2018-05-03 21:58:15
    --@type: 
    return
]]

--[[
    @desc: 设置标签页面板数据内容
    author:{author}
    time:2018-05-03 21:57:09
    return
]]
function StarTowerMainWindow:setPanelData()
end

function StarTowerMainWindow:close_callback()
    self.ctrl:openStarTowerMainView(false)
    if self.partner_model then 
        self.partner_model:runAction(cc.Sequence:create( cc.CallFunc:create(function()
		    doStopAllActions(self.partner_model)
            self.partner_model:removeFromParent()
            self.partner_model = nil
    end)))
    end
    for i,v in pairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = nil
    if self.video_data_event then
        GlobalEvent:getInstance():UnBind(self.video_data_event)
        self.video_data_event = nil
    end
    if self.fight_success_event then 
        GlobalEvent:getInstance():UnBind(self.fight_success_event)
        self.fight_success_event = nil
    end
    if self.count_change_event then 
        GlobalEvent:getInstance():UnBind(self.count_change_event)
        self.count_change_event = nil
    end
    if self.clear_title_change_event then
        GlobalEvent:getInstance():UnBind(self.clear_title_change_event)
        self.clear_title_change_event = nil
    end
end
