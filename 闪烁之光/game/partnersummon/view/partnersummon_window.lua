-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      召唤伙伴主界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
PartnerSummonWindow = PartnerSummonWindow or BaseClass(BaseView)

local table_insert = table.insert

function PartnerSummonWindow:__init()
    self.ctrl = PartnersummonController:getInstance()
    self.model = self.ctrl:getModel()
    self.win_type = WinType.Full
    self.layout_name = "partnersummon/partnersummon_window"
    self.item_list = { }--卡片组列表
    self.goods_list = { }--道具列表
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("partnersummon", "partnersummon"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_11",true), type = ResourcesType.single },
    }

    self.role_vo = RoleController:getInstance():getRoleVo()
end

function PartnerSummonWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_11",true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())
   
    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container , 1)
    self.main_container = self.container:getChildByName("main_container")
    
    self.close_btn = self.main_container:getChildByName("close_btn")
    self.tips_btn = self.main_container:getChildByName("tips_btn")
  
    self.partner_book_btn = self.main_container:getChildByName("partner_book_btn")
    self.book_btn_label = self.partner_book_btn:getChildByName("book_btn_label")
    self.book_btn_label:setString(TI18N("图书馆"))
    self.partner_book_btn:setVisible(false)

    self.score_btn = self.main_container:getChildByName("score_btn")
    self.progress_bg = self.main_container:getChildByName("progress_bg_1")
    self.progress_label = self.progress_bg:getChildByName("progress_label")
    self.progress_label:setLocalZOrder(3)
    local progress_bg_2 = self.progress_bg:getChildByName("progress_bg_2")
    progress_bg_2:setLocalZOrder(2)
    local progress_size = self.progress_bg:getContentSize()
    self.progress = ccui.LoadingBar:create()
    self.progress:setCascadeOpacityEnabled(true)
    self.progress:setScale9Enabled(true)
    self.progress:setContentSize(cc.size(282, 20))
    self.progress:setCapInsets(cc.rect(30, 10, 10, 1))
    self.progress:setAnchorPoint(cc.p(0, 0.5))
    self.progress:loadTexture(PathTool.getResFrame("partnersummon", "partnersummon_image_3"), LOADTEXT_TYPE_PLIST)
    self.progress:setPosition(cc.p(0, progress_size.height/2))
    self.progress:setPercent(0)
    self.progress_bg:addChild(self.progress)

    self.card_scrollview = self.main_container:getChildByName("card_scrollview")
    self.card_scrollview:setScrollBarEnabled(false)

    delayRun(self.root_wnd,0.1,function ()
        self:createRole()
    end)
end

function PartnerSummonWindow:createRole()
    if not tolua.isnull(self.main_container) and self.role_effect == nil then
        self.role_effect = createEffectSpine(PathTool.getEffectRes(116), cc.p(320, 715),cc.p(0.5, 0.5),true, PlayerAction.special_action_0)
        self.main_container:addChild(self.role_effect,-1)
    end
end

function PartnerSummonWindow:register_event()
    if self.close_btn then
        self.close_btn:addTouchEventListener(function (sender,event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self.ctrl:openPartnerSummonWindow(false)
            end
        end)
    end

    registerButtonEventListener(self.tips_btn,function(param,sender, event_type)
        -- local config = Config.RecruitData.data_partnersummon_const.game_rule
        -- TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
        MainuiController:getInstance():openCommonExplainView(true, Config.RecruitData.data_explain,TI18N("规则说明"),true)
    end)

    if self.partner_book_btn then
        self.partner_book_btn:addTouchEventListener(function (sender,event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                PokedexController:getInstance():openPokedexWindow(true)
            end
        end)
    end

    registerButtonEventListener(self.score_btn, handler(self, self._onClickScoreBtn))

    if not self.update_summon_data_event then
        self.update_summon_data_event = GlobalEvent:getInstance():Bind(PartnersummonEvent.updateSummonDataEvent,function (data)
            self:updateData()
        end)
    end

    -- 积分更新
    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "recruit_hero" then
                    local cur_score = value
                    local max_score = self.model:getScoreSummonNeedCount()
                    local percent = (cur_score/max_score)*100
                    self.progress:setPercent(percent)
                    self.progress_label:setString(string.format("%d/%d", cur_score, max_score))
                    self:showScoreFullAction(cur_score>=max_score)
                end
            end)
        end
    end
end

function PartnerSummonWindow:_onClickScoreBtn(  )
    if self.role_vo then
        local total_score = self.role_vo.acc_recruit_hero
        local need_score = self.model:getScoreSummonNeedCount()
        if total_score >= need_score then
            self.ctrl:openPartnerSummonScoreWindow(true)
        else
            message(string.format(TI18N("满%d积分开启积分召唤"), need_score))
        end
    end
end

-- 积分按钮抖动效果
function PartnerSummonWindow:showScoreFullAction( status )
    if status == true then
        self.score_btn:setRotation(0)
        self.score_btn:stopAllActions()
        local act_1 = cc.RotateBy:create(0.05, -10)
        local act_2 = cc.RotateBy:create(0.1, 20)
        local act_3 = cc.RotateBy:create(0.05, -10)
        local delay = cc.DelayTime:create(0.7)
        local actions = {}
        for i=1,5 do
            table_insert(actions, act_1)
            table_insert(actions, act_2)
            table_insert(actions, act_3)
        end
        table_insert(actions, delay)
        local sequence = cc.Sequence:create(unpack(actions))
        self.score_btn:runAction(cc.RepeatForever:create(sequence))
    else
        self.score_btn:setRotation(0)
        self.score_btn:stopAllActions()
    end
end

-- 刷新进度条相关信息
function PartnerSummonWindow:refreshProgressInfo(  )
    if self.role_vo then
        local cur_score = self.role_vo.recruit_hero
        local max_score = self.model:getScoreSummonNeedCount()
        local percent = (cur_score/max_score)*100
        self.progress:setPercent(percent)
        self.progress_label:setString(string.format("%d/%d", cur_score, max_score))
        self:showScoreFullAction(cur_score>=max_score)
    end
end

-- 更新卡库列表
function PartnerSummonWindow:updateData( )
    local temp_list = self.model:getSummonGroupData()
    local item_height = (tableLen(temp_list or {})) * PartnerSummonItem.HEIGHT
    local max_height = math.max(self.card_scrollview:getContentSize().height,item_height)
    self.card_scrollview:setInnerContainerSize(cc.size(self.card_scrollview:getContentSize().width,max_height))
    local offset_y = 7
    for k, v in ipairs(temp_list) do
        local item = self.item_list[k] 
        if not item then
            delayRun(self.main_container, 4 * k/display.DEFAULT_FPS,function ()
                item = self.item_list[k]
                -- 可能在创建之前，又进来updateData了，就可能重复创建
                if not item then
                    item = PartnerSummonItem.new(k)
                    item:setData(k, v)
                    item:setPosition(0, max_height - (PartnerSummonItem.HEIGHT+offset_y) * (k - 1))
                    self.card_scrollview:addChild(item)
                    self.item_list[k] = item
                else
                    item:setData(k, v)
                    item:setPosition(0, max_height - (PartnerSummonItem.HEIGHT+offset_y) * (k - 1))
                end
            end)
        else
            item:setData(k, v)
            item:setPosition(0, max_height - (PartnerSummonItem.HEIGHT+offset_y) * (k - 1))
        end
    end
    -- TODO红点
    --self.ctrl:getModel():updateRedPoint()
end

function PartnerSummonWindow:openRootWnd()
    self:updateData()
    self:refreshProgressInfo()
end

function PartnerSummonWindow:close_callback()
    self.main_container:stopAllActions()
    for i, item in pairs(self.item_list) do
        if item then
            item:DeleteMe()
        end
    end
    if self.role_effect then
        self.role_effect:clearTracks()
        self.role_effect:removeFromParent()
        self.role_effect = nil
    end
    if self.update_summon_data_event then
        GlobalEvent:getInstance():UnBind(self.update_summon_data_event)
        self.update_summon_data_event = nil
    end
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end
    self:showScoreFullAction(false)
    self.ctrl:openPartnerSummonWindow(false)
end