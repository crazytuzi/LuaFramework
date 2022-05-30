-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      公会技能升级
-- <br/>2020年4月12日
--
-- --------------------------------------------------------------------
GuildskillLevelSuccessPanel = GuildskillLevelSuccessPanel or BaseClass(BaseView)

local controller = GuildskillController:getInstance()
local model = controller:getModel()
local string_format = string.format

function GuildskillLevelSuccessPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Tips
    self.layout_name = "guildskill/guildskill_level_success_panel"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
    }
    -- self.is_csb_action = true
    self.lev_list = {}
    self.item_list = {}
    self.can_touch = false
    self.auto_limit_time = 5
end 

function GuildskillLevelSuccessPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.back_panel = self.main_container:getChildByName("back_panel")
    self.title_container = self.main_container:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    self.skill_item = SkillItem.new(true,false,false,nil,nil,false)
    self.skill_item:setPosition(360, 394)
    self.main_container:addChild(self.skill_item)

    self.item_1 = self.main_container:getChildByName("item_1")

    self.left_lev = self.item_1:getChildByName("last_lev")
    self.right_lev = self.item_1:getChildByName("now_lev")

    self.tips_label = self.main_container:getChildByName("tips_label")
    self.tips_label:setString(TI18N("技能等级已提升"))

    self:runmoveAction(self.skill_item, 0.1)
    self:runmoveAction(self.item_1, 0.2)
    self:runmoveAction(self.tips_label, 0.3)
end

function GuildskillLevelSuccessPanel:runmoveAction(node, delay)
    if delay <= 0 then
        delay = 1
    end
    local x, y = node:getPosition()
    node:setPosition(x -300, y)
    node:setOpacity(0)

    local moveto = cc.EaseBackOut:create(cc.MoveTo:create(0.4,cc.p(x, y))) 
    local fadeIn = cc.FadeIn:create(0.4)
    local spawn_action = cc.Spawn:create(moveto, fadeIn)
    node:runAction(cc.Sequence:create(cc.DelayTime:create(delay), spawn_action))
end


function GuildskillLevelSuccessPanel:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if self.can_touch  == true then
                self:onClickClose()
            end
        end
    end)
end

function GuildskillLevelSuccessPanel:onClickClose()
    controller:openGuildskillLevelSuccessPanel(false)
end

function GuildskillLevelSuccessPanel:openRootWnd(career)
    playOtherSound("c_get") 
    self:handleEffect(true)
    self:starTimeTicket()


    local pvp_career_data = model:getPvpskillInfoByCareer(career)
    if not pvp_career_data then return end
    self.left_lev:setString("Lv."..(pvp_career_data.skill_lev - 1))
    self.right_lev:setString("Lv."..(pvp_career_data.skill_lev))

     local key = getNorKey(career, pvp_career_data.skill_lev)
    local pvp_skill_config = Config.GuildSkillData.data_pvp_skill_info(key)
    if pvp_skill_config then
        local skill_config = Config.SkillData.data_get_skill(pvp_skill_config.skill_id)
        if skill_config then
            self.skill_item:setData(skill_config)
            -- self.skill_item:showName(true,skill_config.name,nil,22,false,cc.c4b(0xff,0xe8,0xb7,0xff),nil,cc.size(168,31))            
            self.skill_item:showName(true,skill_config.name,nil,22,false,Config.ColorData.data_new_color4[6],nil,cc.size(168,31))
        end
    end
end

function GuildskillLevelSuccessPanel:starTimeTicket()
    self.cut_time = 0
    if self.time_ticket == nil then
        self.time_ticket = GlobalTimeTicket:getInstance():add(function() 
            self.cut_time = self.cut_time + 0.5
            if self.cut_time > 0.5 then
                self.can_touch = true
            end
            if self.cut_time >= self.auto_limit_time then
                self:onClickClose()
            end
        end, 0.5)
    end
end

function GuildskillLevelSuccessPanel:clearTimeticket()
    if self.time_ticket then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end

function GuildskillLevelSuccessPanel:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        local effect_id = 274
        local action = PlayerAction.action_2
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(effect_id), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, action)
            self.title_container:addChild(self.play_effect, 1)
        end
    end
end 

function GuildskillLevelSuccessPanel:close_callback()
    self:handleEffect(false)
    self:clearTimeticket()

    if self.skill_item then
        self.skill_item:DeleteMe()
        self.skill_item = nil
    end
    controller:openGuildskillLevelSuccessPanel(false)
end