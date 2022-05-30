-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      星河神殿 战斗结算界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
PrimusChallengeResultWindow = PrimusChallengeResultWindow or BaseClass(BaseView) 

local controller = PrimusController:getInstance()

function PrimusChallengeResultWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Tips
    self.layout_name = "primus/primus_challenge_result_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
    }
end

function PrimusChallengeResultWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    -- self:playEnterAnimatianByObj(self.main_container , 1)
    self.title_container = self.main_container:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    self.title_img = self.main_container:getChildByName("title_img")
    self.harm_btn = self.main_container:getChildByName("harm_btn")
    self.harm_btn:setVisible(false)
    self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))

    self.list_view = self.root_wnd:getChildByName("list_view")
    local size = self.list_view:getContentSize()
    local setting = {
        item_class = PrimusChallengeResultItem,
        start_x = 0,
        space_x = 0,
        start_y = 8,
        space_y = 12,
        item_width = 720,
        item_height = 43,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewLayout.new(self.list_view, nil, nil, nil, size, setting)

    self.item = self.root_wnd:getChildByName("item")

    self.goto_btn = self.main_container:getChildByName("goto_btn")
    self.goto_btn:getChildByName("label"):setString(TI18N("前往装备称号"))
    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("确 定"))
end

function PrimusChallengeResultWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type) 
        playCloseSound()
        if event_type == ccui.TouchEventType.ended then
            controller:openPrimusChallengeResultWindow(false)
        end
    end)

    registerButtonEventListener(self.goto_btn, handler(self, self._onGoToEquipTitle) ,false, 2)
    registerButtonEventListener(self.comfirm_btn, function() controller:openPrimusChallengeResultWindow(false) end ,false, 2)
    registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
end

function PrimusChallengeResultWindow:_onClickHarmBtn(  )
    if self.data and next(self.data) ~= nil then
        BattleController:getInstance():openBattleHarmInfoView(true, self.data)
    end
end

--前往装备称号
function PrimusChallengeResultWindow:_onGoToEquipTitle()
    controller:openPrimusChallengeResultWindow(false)
    RoleController:getInstance():openRoleDecorateView(true, 4)
end

function PrimusChallengeResultWindow:openRootWnd(data)
    playOtherSound("c_get") 
    self:handleEffect(true)
    if data then
        self.data = data
        self.harm_btn:setVisible(true)
    end

    self.local_data = Config.PrimusData.data_upgrade[data.pos]
    if self.local_data then
        local honor_data =Config.HonorData.data_title[self.local_data.honor_id]
        self.scroll_view:setData(honor_data.attr, nil, nil, self.item)    

        if honor_data and self.title_img then
            local res = PathTool.getTargetRes("honor","txt_cn_honor_"..honor_data.res_id,false,false)
            self.item_load = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load)
        end 
    end
end

function PrimusChallengeResultWindow:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        local effect_id = 274
        local action = PlayerAction.action_3
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(effect_id), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, action)
            self.title_container:addChild(self.play_effect, 1)
        end
    end
end 

function PrimusChallengeResultWindow:close_callback()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
    end
    self.scroll_view  = nil

    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    controller:openPrimusChallengeResultWindow(false)
end



-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      收益物品展示
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
PrimusChallengeResultItem = class("PrimusChallengeResultItem", function()
    return ccui.Layout:create()
end)

function PrimusChallengeResultItem:ctor()
    self.is_completed = false
end

function PrimusChallengeResultItem:setExtendData(node)
    if not tolua.isnull(node) and self.root_wnd == nil then
        self.is_completed = true
        local size = node:getContentSize()
        self:setAnchorPoint(cc.p(0.5, 0.5))
        self:setContentSize(size)

        self.root_wnd = node:clone()
        self.root_wnd:setVisible(true)
        self.root_wnd:setAnchorPoint(0.5, 0.5)
        self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5) 
        self.root_wnd:setCascadeOpacityEnabled(true)
        self:addChild(self.root_wnd)

        self.init_pos_y = self.root_wnd:getPositionY()

        self.item_name = self.root_wnd:getChildByName("item_name")

        self.item_num = self.root_wnd:getChildByName("item_num")

        self:playEnterActions()
    end
end

function PrimusChallengeResultItem:playEnterActions()
    self.root_wnd:setPositionX(200)
    self.root_wnd:setOpacity(0)

    local move_to = cc.MoveTo:create(0.2, cc.p(460, self.init_pos_y))
    local fade_in = cc.FadeIn:create(0.2)
    local move_to_1 = cc.MoveTo:create(0.1, cc.p(360, self.init_pos_y))

    self.root_wnd:runAction(cc.Sequence:create(cc.Spawn:create(move_to,fade_in), move_to_1))
end

function PrimusChallengeResultItem:setData(data)
    self.data = data
    if data then
        local atrr_name = Config.AttrData.data_key_to_name[data[1]]
        self.item_name:setString(atrr_name)

        if PartnerCalculate.isShowPerByStr(data[1]) then
            local value = data[2]/10
            self.item_num:setString(value.."%")
        else
            self.item_num:setString(changeBtValueForPower(data[2]))
        end
    end
end

function PrimusChallengeResultItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end 