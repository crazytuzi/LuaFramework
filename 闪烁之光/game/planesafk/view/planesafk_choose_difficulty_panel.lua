-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      位面选择难度界面
-- <br/> 2020年2月12日
-- --------------------------------------------------------------------
PlanesafkChooseDifficultyPanel = PlanesafkChooseDifficultyPanel or BaseClass(BaseView)

local controller = PlanesafkController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local math_ceil = math.ceil


function PlanesafkChooseDifficultyPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "planesafk/planesafk_choose_difficulty_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("planes","planes_hard"), type = ResourcesType.plist }
    }
end

function PlanesafkChooseDifficultyPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")

    self:playEnterAnimatianByObj(self.main_container , 1)

    self.bg_tips = self.main_container:getChildByName("bg_tips")
    self.bg_tips:setString(TI18N("困难难度的奖励更丰富, 但战斗难度会更大,请勇士谨慎选择"))
    

    self.btn_rule = self.main_container:getChildByName("btn_rule")
    self.btn_rule:setVisible(false)

    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("确认选择")) 
    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("确认选择")) 

    self.left_reward_key = self.main_container:getChildByName("left_reward_key")
    self.left_reward_key:setString("奖励系数:")
    self.left_hark_key = self.main_container:getChildByName("left_hark_key")
    self.left_hark_key:setString("难度系数:")
    self.right_reward_key = self.main_container:getChildByName("right_reward_key")
    self.right_reward_key:setString("奖励系数:")
    self.right_hark_key = self.main_container:getChildByName("right_hark_key")
    self.right_hark_key:setString("难度系数:")

    local reward_rate = {1000,1000}
    local config = Config.PlanesData.data_const.planes_reward_rate
    if config then
        reward_rate = config.val
    end

    local challenge_rate = {1000,1000}
    local config = Config.PlanesData.data_const.planes_challenge_rate
    if config then
        challenge_rate = config.val
    end
    local math_floor = math.floor
    self.left_reward_value = self.main_container:getChildByName("left_reward_value")
    self.left_reward_value:setString(math_floor(reward_rate[1]/10).."%")
    self.left_hard_value = self.main_container:getChildByName("left_hard_value")
    self.left_hard_value:setString(math_floor(challenge_rate[1]/10).."%")

    self.right_reward_value = self.main_container:getChildByName("right_reward_value")
    self.right_reward_value:setString(math_floor(reward_rate[2]/10).."%")
    self.right_hard_value = self.main_container:getChildByName("right_hard_value")
    self.right_hard_value:setString(math_floor(challenge_rate[2]/10).."%") 
end

function PlanesafkChooseDifficultyPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.btn_rule, handler(self, self.onClickRuleBtn) ,true, 2)

    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnLeft) ,true, 1)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickBtnRight) ,true, 1)

end

-- 打开规则说明
function PlanesafkChooseDifficultyPanel:onClickRuleBtn(  )
    MainuiController:getInstance():openCommonExplainView(true, Config.ArenaTeamData.data_explain)
end

--关闭
function PlanesafkChooseDifficultyPanel:onClickBtnClose()
    controller:openPlanesafkChooseDifficultyPanel(false)
end

-- 确定使用
function PlanesafkChooseDifficultyPanel:onClickBtnLeft()
    if not self.floor then return end
    controller:sender28604(self.floor, 1)
    self:onClickBtnClose()
end
-- 确定使用
function PlanesafkChooseDifficultyPanel:onClickBtnRight()
  if not self.floor then return end
    controller:sender28604(self.floor, 2)
    self:onClickBtnClose()
end

function PlanesafkChooseDifficultyPanel:openRootWnd(setting)
    local setting  = setting or {}
    self.floor = setting.floor 
end


function PlanesafkChooseDifficultyPanel:close_callback()
    controller:openPlanesafkChooseDifficultyPanel(false)
end