-- --------------------------------------------------------------------
--
-- @author: yuanqi@shiyue.com(必填, 创建模块的人员)
-- @description:
--
-- <br/>Create: 2020-03-16
-- --------------------------------------------------------------------
ActivePushWindow = ActivePushWindow or BaseClass(BaseView)
local config = Config.HolidayRolePushData

local controller = RoleController:getInstance()

function ActivePushWindow:__init()
    self.view_tag = ViewMgrTag.TOP_TAG
    self.win_type = WinType.Mini
    self.is_full_screen = true
    self.layout_name = "action/action_active_push"

    self.res_list = {
        -- {path = PathTool.getPlistImgForDownLoad("activepush", "activepush_bg1", false), type = ResourcesType.single},
        -- {path = PathTool.getPlistImgForDownLoad("activepush", "activepush_bg2", false), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("activepush", "activepush_bg3", false), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("activepush", "activepush_bg4", false), type = ResourcesType.single}
    }
end

function ActivePushWindow:openRootWnd(push_id_list)
    if push_id_list == nil or next(push_id_list) == nil then
        return
    end
    self.push_id_list = push_id_list
    local push_id_data = table.remove(self.push_id_list)
    if push_id_data and push_id_data.id then
        self.push_id = push_id_data.id
        local str = "activepush_bg" .. self.push_id
        local bg_res = PathTool.getPlistImgForDownLoad("activepush", str)
        if not self.background_load then
            self.background_load = loadSpriteTextureFromCDN(self.image_bg, bg_res, ResourcesType.single, self.background_load)
        end
        self:initUI()
    end
end

function ActivePushWindow:initUI()
    if self.push_id and self.close_btn and self.close_btn.loadTexture and self.goto_btn and self.goto_btn.loadTexture then
        if self.push_id == 1 then
            self.close_btn:loadTexture(PathTool.getResFrame("welfare", "welfare_close"), LOADTEXT_TYPE_PLIST)
            self.close_btn:setPosition(605, 857)
            self.goto_btn:loadTexture(PathTool.getResFrame("common", "common_1018"), LOADTEXT_TYPE_PLIST)
            self.goto_btn:setPositionY(0)
            self.goto_btn_label:enableOutline(cc.c4b(0x29,0x4A,0x15,0xff), 2)
            self.goto_btn_label:setString(TI18N("前 往"))
        elseif self.push_id == 2 then
            self.close_btn:loadTexture(PathTool.getResFrame("welfare", "welfare_close_1"), LOADTEXT_TYPE_PLIST)
            self.close_btn:setPosition(640, 905)
            self.goto_btn:loadTexture(PathTool.getResFrame("common", "common_1017"), LOADTEXT_TYPE_PLIST)
            self.goto_btn:setPositionY(-25)
            self.goto_btn_label:enableOutline(cc.c4b(0x76,0x45,0x19,0xff), 2)
            self.goto_btn_label:setString(TI18N("立即前往"))
        elseif self.push_id == 3 then
            self.close_btn:loadTexture(PathTool.getResFrame("welfare", "welfare_close"), LOADTEXT_TYPE_PLIST)
            self.close_btn:setPosition(640, 870)
            self.goto_btn:loadTexture(PathTool.getResFrame("common", "common_1017"), LOADTEXT_TYPE_PLIST)
            self.goto_btn:setPositionY(-50)
            self.goto_btn_label:enableOutline(cc.c4b(0x76,0x45,0x19,0xff), 2)
            self.goto_btn_label:setString(TI18N("立即前往"))
        elseif self.push_id == 3 or self.push_id == 4 then
            self.close_btn:loadTexture(PathTool.getResFrame("welfare", "welfare_close"), LOADTEXT_TYPE_PLIST)
            self.close_btn:setPosition(585, 815)
            self.goto_btn:loadTexture(PathTool.getResFrame("common", "common_1017"), LOADTEXT_TYPE_PLIST)
            self.goto_btn:setPositionY(-45)
            self.goto_btn_label:enableOutline(cc.c4b(0x76,0x45,0x19,0xff), 2)
            self.goto_btn_label:setString(TI18N("立即前往"))
        end
    end
end

function ActivePushWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.image_bg = self.main_container:getChildByName("image_bg")

    self.close_btn = self.main_container:getChildByName("close_btn")
    self.goto_btn = self.main_container:getChildByName("goto_btn")
    self.goto_btn_label = self.goto_btn:getChildByName("label")
    self.goto_btn_label:setString(TI18N("前 往"))
    self:register_event()
end

function ActivePushWindow:register_event()
    registerButtonEventListener(
        self.close_btn,
        function()
            controller:openActivePushWindow(false)
        end,
        true,
        2
    )
    registerButtonEventListener(
        self.background,
        function()
            controller:openActivePushWindow(false)
        end,
        false,
        2
    )
    registerButtonEventListener(
        self.goto_btn,
        function()
            self:onGotoBtn()
        end,
        true,
        2
    )
end

function ActivePushWindow:onGotoBtn()
    if self.push_id and config and config.data_push_list and config.data_push_list[self.push_id] then
        local jump_id = config.data_push_list[self.push_id].jump_id
        if jump_id then
            if jump_id == 1 then
                self:enterActive(ActionRankCommonType.select_elite_summon)
            elseif jump_id == 2 then
                JumpController:getInstance():jumpViewByEvtData({76})
            elseif jump_id == 3 then
                self:enterActive(ActionRankCommonType.FortuneBagDraw)
            elseif jump_id == 4 then
                self:enterActive(ActionRankCommonType.select_elite_summon)
            else
                ActionController:getInstance():openActionMainPanel(true, MainuiConst.icon.festival)
            end
        else
            ActionController:getInstance():openActionMainPanel(true, MainuiConst.icon.festival)
        end
    end
    controller:openActivePushWindow(false)
end

function ActivePushWindow:enterActive(holiday_bid)
    if holiday_bid then
        local controller = ActionController:getInstance()
        local tab_vo = controller:getActionSubTabVo(holiday_bid)
        if tab_vo then
            controller:openActionMainPanel(true, nil, tab_vo.bid) 
        else
            message(TI18N("该活动已结束"))
        end
    else
        message(TI18N("该活动已结束"))
    end
end

function ActivePushWindow:close_callback()
    if self.background_load then
        self.background_load:DeleteMe()
        self.background_load = nil
    end
    controller:openActivePushWindow(false)
end
