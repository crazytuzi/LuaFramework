--------------------------------------------
-- @Author  : htp
-- @Editor  : lwc
-- @Date    : 2020年3月22日
-- @description    : 
        -- 保存精灵套装提示
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert

ElfinFightPlanSaveTips = ElfinFightPlanSaveTips or BaseClass(BaseView)

function ElfinFightPlanSaveTips:__init()
    self.is_full_screen = false  
    self.win_type = WinType.Mini 
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "hero/hero_holy_save_plan_tips"
    self.res_list = {
        -- {path = PathTool.getPlistImgForDownLoad("hero", "hero"), type = ResourcesType.plist},
    }

    self.item_node_list = {}
    self.enter_status = false --进入时勾选框状态
end

function ElfinFightPlanSaveTips:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 2)

    local title_container = self.main_panel:getChildByName("title_container")
    title_container:getChildByName("title_label"):setString(TI18N("提示"))

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.confirm_btn = self.main_panel:getChildByName("confirm_btn")
    self.confirm_btn:getChildByName("label"):setString(TI18N("确 定"))
    self.cancel_btn = self.main_panel:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("取 消"))
    self.box_btn = self.main_panel:getChildByName("box_btn")
    self.box_btn:getChildByName("name"):setString(TI18N("今日不再提示"))

    self.tips_label = createRichLabel(24, 274, cc.p(0.5, 0.5), cc.p(325, 374), 5, nil, 594)
    self.main_panel:addChild(self.tips_label)
end

function ElfinFightPlanSaveTips:register_event()
    registerButtonEventListener(self.background, handler(self, self.handleCbSelectStatus), true, 2)

    registerButtonEventListener(self.close_btn, handler(self, self.handleCbSelectStatus), true, 2)

    registerButtonEventListener(self.confirm_btn, function() self:onConfirmBtn() end, true, 1)

    registerButtonEventListener(self.cancel_btn, handler(self, self.handleCbSelectStatus), true, 1)

    self.box_btn:addEventListener(function(sender,event_type)
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.elfin_plan_save_tip, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.elfin_plan_save_tip, false, false) 
        end
    end)
end

function ElfinFightPlanSaveTips:onConfirmBtn()
    if self.callback then
        self.callback()
    end
    SysEnv:getInstance():save() --点确定才保存勾选框状态
    _controller:openElfinFightPlanSaveTips(false)
end

--放弃当前勾选框修改的状态
function ElfinFightPlanSaveTips:handleCbSelectStatus()
    local status = SysEnv:getInstance():getBool(SysEnv.keys.elfin_plan_save_tip, false)
    if status ~= self.enter_status then
        SysEnv:getInstance():set(SysEnv.keys.elfin_plan_save_tip, self.enter_status, false)
    end
    _controller:openElfinFightPlanSaveTips(false)
end

--因为保存的问题用callback 方式
--setting.same_list --显示列表
--setting.callback 回调方法
function ElfinFightPlanSaveTips:openRootWnd(setting)
    local setting = setting or {}
    self.same_list = setting.same_list
    self.callback = setting.callback

    self:setData()
end

function ElfinFightPlanSaveTips:setData()
    self.tips_label:setString(TI18N("应用此装配方案，会将以下精灵从对应队伍中卸下，是否继续?"))

    local status = SysEnv:getInstance():getBool(SysEnv.keys.elfin_plan_save_tip, false)
    self.box_btn:setSelected(status)
    self.enter_status = status

    table.sort(self.same_list, function(a, b) return a.team < b.team end)
    local item_bid_list = {}
    for i,v in ipairs(self.same_list) do
        if v.item_bid ~= 0 then
            _table_insert(item_bid_list, v.item_bid)
        end
    end
    local item_count = #item_bid_list
    if item_count > 0 then
        local start_x = 102
        if item_count < 4 then
            start_x = start_x + (4 - item_count) * 75
        end
        for i=1,item_count do
            local item = self.item_node_list[i]
            if not item then
                item = ElfinSaveItem.new()
                self.main_panel:addChild(item)
                self.item_node_list[i] = item
            end
            item:setData(self.same_list[i])
            item:setPosition(cc.p(start_x + (i-1)*(138+10), 230))
        end
    end
end

function ElfinFightPlanSaveTips:close_callback( )
    for k,v in pairs(self.item_node_list) do
        v:DeleteMe()
        v = nil
    end
    _controller:openElfinFightPlanSaveTips(false)
end

-----------------------------@ item
ElfinSaveItem = class("ElfinSaveItem", function()
    return ccui.Widget:create()
end)

function ElfinSaveItem:ctor()
    self:config()
    self:layoutUI()
end

function ElfinSaveItem:config()
    self.size = cc.size(138, 211)
    self:setContentSize(self.size)
end

function ElfinSaveItem:layoutUI()
    self.container = ccui.Layout:create()
    self.container:setContentSize(self.size)
    self:addChild(self.container)

    local sp_line = createSprite(PathTool.getResFrame("common","common_90097"), self.size.width/2, 63, self.container, cc.p(0.5, 0.5))

    self.item_node = SkillItem.new(true, true, true, 1, true)
    self.item_node:setPosition(cc.p(self.size.width/2, self.size.height - BackPackItem.Height/2 - 15))
    self.container:addChild(self.item_node)

    local name_bg = createImage(self.container, PathTool.getResFrame("common","common_90096"), self.size.width/2, 32, cc.p(0.5, 0.5), true, nil, true)
    name_bg:setContentSize(cc.size(138, 30))

    self.name_label = createLabel(20, 274, nil, self.size.width/2, 32, "", self.container, nil, cc.p(0.5, 0.5))
end

function ElfinSaveItem:setData(data)
    if not data then return end
    
    if data.item_bid then
        local elfin_cfg = Config.SpriteData.data_elfin_data(data.item_bid)
        if elfin_cfg then
            local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
            if skill_cfg then
                self.item_node:setData(skill_cfg)
            end
        end
        local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
    end
    if data.team then
        self.name_label:setString(_string_format(TI18N("队伍%s"),StringUtil.numToChinese(data.team)))
    end
end

function ElfinSaveItem:DeleteMe()
    if self.item_node then
        self.item_node:DeleteMe()
        self.item_node = nil
    end
end