-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: lwc@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--  公会开始讨伐界面
-- <br/>Create: 2019年9月16日 
------------------------------------------------------------------------------
GuildsecretareaStartCrusadePanel = GuildsecretareaStartCrusadePanel or BaseClass(BaseView)


local controller = GuildsecretareaController:getInstance()
local model = controller:getModel()

function GuildsecretareaStartCrusadePanel:__init()
    self.win_type = WinType.Mini
    self.layout_name = "guildsecretarea/guildsecretarea_start_crusade_panel"
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("battle", "battle"), type = ResourcesType.plist },
    }
end


--初始化
function GuildsecretareaStartCrusadePanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)


    self.tips_label = self.container:getChildByName("tips_label")
    self.tips_label_1 = self.container:getChildByName("tips_label_1")
    self.tips_label:setString(TI18N("公会秘境讨伐已开启"))
    self.tips_label_1:setString(TI18N("请在限定时间内讨伐BOSS"))
    self.less_time = self.container:getChildByName("less_time")
    local container_size = self.container:getContentSize()

    self.comfirm_btn = self.container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("前 往"))

    self.cancel_btn = self.container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("取 消"))

    self.boss_icon = self.container:getChildByName("boss_icon")
    local bg_res = PathTool.getPlistImgForDownLoad("partner", "dakelaiyi", false)
    self.item_load_bg = loadSpriteTextureFromCDN(self.boss_icon, bg_res, ResourcesType.single, self.item_load_bg) 
end

function GuildsecretareaStartCrusadePanel:playEnterAnimatian()
    if not self.container then return end
    commonOpenActionCentreScale(self.container)
end


function GuildsecretareaStartCrusadePanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn) ,false, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
    registerButtonEventListener(self.cancel_btn, handler(self, self.onClickCloseBtn), true, REGISTER_BUTTON_SOUND_CLOSED_TYPY)

    registerButtonEventListener(self.comfirm_btn, handler(self, self.onClickComfirmBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
end

--关闭
function GuildsecretareaStartCrusadePanel:onClickCloseBtn()
    controller:openGuildsecretareaStartCrusadePanel(false)
end
--前往
function GuildsecretareaStartCrusadePanel:onClickComfirmBtn()
    MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.GuildSecretArea)
    controller:openGuildsecretareaStartCrusadePanel(false)
end

function GuildsecretareaStartCrusadePanel:openRootWnd()
    playOtherSound("1001") --1001
    local data = model.start_crusade_data
    if not data then return end
    local time = data.end_time - GameNet:getInstance():getTime()
    if time <= 0 then
        time = 0
    end
    commonCountDownTime(self.less_time, time, {callback = function(time) self:setTimeFormatString(time) end})
end

function GuildsecretareaStartCrusadePanel:setTimeFormatString(time)
    if time > 0 then
        local str = string.format(TI18N("剩余时间: %s"),TimeTool.GetTimeFormatDayIIIIII(time))
        self.less_time:setString(str)
    else
        local str = TI18N("剩余时间: 00:00")
        self.less_time:setString(str)
        -- self:onClickCloseBtn()
    end
end


--清理
function GuildsecretareaStartCrusadePanel:close_callback()

    if self.item_load_bg then
        self.item_load_bg:DeleteMe()
    end
    self.item_load_bg = nil
    controller:openGuildsecretareaStartCrusadePanel(false)
end
