-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      位面通关显示
-- <br/>2020年2月17日
--
-- --------------------------------------------------------------------
PlanesafkResultPanel = PlanesafkResultPanel or BaseClass(BaseView)

local controller = PlanesafkController:getInstance()
local model = GuildbossController:getInstance():getModel()
local string_format = string.format

function PlanesafkResultPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Tips
    self.is_full_screen = false
    self.effect_cache_list = {}
    self.layout_name = "planesafk/planesafk_result_panel"
    
    self.res_list = {
        -- {path = PathTool.getPlistImgForDownLoad("guildboss", "guildboss"), type = ResourcesType.plist}
    }
    self.fight_type = BattleConst.Fight_Type.GuildDun
end

function PlanesafkResultPanel:open_callback()
    playOtherSound("b_win", AudioManager.AUDIO_TYPE.BATTLE) 
    
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")

    self.title_container = self.root_wnd:getChildByName("title_container") 
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    self.pass_bg = self.container:getChildByName("pass_bg")
    local x, y = self.pass_bg:getPosition()
    self.pass_tip = createRichLabel(24, cc.c3b(0x86,0xd5,0x4e), cc.p(0.5, 0.5), cc.p(x,y),nil, nil, 10000)
    self.container:addChild(self.pass_tip)
    self.tips = self.container:getChildByName("tips")

    self.tips:setString(TI18N("恭喜完成本次副本探险"))

    self.comfirm_btn = self.container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("结束探索"))
end

function PlanesafkResultPanel:onCloseBtn()
    controller:openPlanesafkResultPanel(false)
end

function PlanesafkResultPanel:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self:onCloseBtn()
        end
    end) 
    registerButtonEventListener(self.comfirm_btn, handler(self, self.onCloseBtn), true)
end


function PlanesafkResultPanel:openRootWnd()
    self:handleEffect(true)

    local planes_feat_list = {46800,46810,46820,46830,46840}
    local config = Config.PlanesData.data_const.planes_feat_list
    if config then
        planes_feat_list = config.val
    end

    local cur_data =nil
    local task_model = TaskController:getInstance():getModel()
    for i,id in ipairs(planes_feat_list) do
        local data = task_model:getTaskExpListById(id)
        if data and (data.finish == TaskConst.task_status.finish or data.finish == TaskConst.task_status.un_finish) then
            --未完成和已完成未领取的
            cur_data = data
            break
        end
    end
    if cur_data then
        local target_val = 0
        local value = 0
        if cur_data.progress[1] then
            target_val = cur_data.progress[1].target_val
            value = cur_data.progress[1].value
        end
        
        self.pass_tip:setString(str)
        if cur_data.finish == TaskConst.task_status.finish then
            --完成
            local res = PathTool.getResFrame("common", "common_1043")
            local str = string_format("<img src='%s' scale=0.8 />%s(%s/%s)",res ,cur_data.config.desc, MoneyTool.GetMoneyString(value), MoneyTool.GetMoneyString(target_val))
            self.pass_tip:setString(str)
        else
            local str = string_format("<div fontcolor=#FFE8B7>%s(%s/%s)</div>",cur_data.config.desc, MoneyTool.GetMoneyString(value), MoneyTool.GetMoneyString(target_val))
            self.pass_tip:setString(str)
        end
    else
        self.pass_bg:setVisible(false)
        self.pass_tip:setVisible(false)
        self.tips:setPositionY(210)
    end
end



function PlanesafkResultPanel:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine("E51026", cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action_1, function()
                if self and self.play_effect and not self.is_update_ani  then
                    self.is_update_ani = true
                    self.play_effect:setAnimation(0, PlayerAction.action_2, true)
                end
            end)
            self.title_container:addChild(self.play_effect, 1)
        end
    end
end 

function PlanesafkResultPanel:close_callback()
    self.container:stopAllActions()

    self:handleEffect(false)
    if self.item_list then
        for i,v in ipairs(self.item_list) do
            if v then
                v:DeleteMe()
            end
        end
    end
    controller:openPlanesafkResultPanel(false)
end 