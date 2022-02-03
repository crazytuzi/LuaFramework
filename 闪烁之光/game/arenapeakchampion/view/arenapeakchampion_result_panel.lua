-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: lwc@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--  巅峰冠军赛结算
-- <br/>Create: 2019年11月24日
------------------------------------------------------------------------------
ArenapeakchampionResultPanel = ArenapeakchampionResultPanel or BaseClass(BaseView)


local controller = ArenapeakchampionController:getInstance()
local model = controller:getModel()

function ArenapeakchampionResultPanel:__init()
    self.win_type = WinType.Mini
    self.layout_name = "arenapeakchampion/arenapeakchampion_result_panel"
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("arenapeakchampion", "arenapeakchampion_result"), type = ResourcesType.plist },
    }
end


--初始化
function ArenapeakchampionResultPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)


    self.win_title = self.container:getChildByName("win_title")
    self.win_title:setString(TI18N("巅峰冠军赛结算"))
    self.match_count_key = self.container:getChildByName("match_count_key")
    self.match_count_key:setString(TI18N("比赛次数"))
    self.win_count_key = self.container:getChildByName("win_count_key")
    self.win_count_key:setString(TI18N("胜利场数"))

    self.win_tips = self.container:getChildByName("win_tips")
    self.win_tips:setString(TI18N("获得以上成就"))

    self.rank_label = CommonNum.new(22, self.container, 0, - 2, cc.p(0.5, 0.5))
    self.rank_label:setPosition(294, 427)

    self.match_count = self.container:getChildByName("match_count")
    self.win_count = self.container:getChildByName("win_count")
    self.win_name = self.container:getChildByName("win_name")

    self.bg_img = self.container:getChildByName("bg_img")
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/arenapeakchampion", "arenapeakchampion_result", false)
    self.item_load_bg = loadSpriteTextureFromCDN(self.bg_img, bg_res, ResourcesType.single, self.item_load_bg) 
end

function ArenapeakchampionResultPanel:playEnterAnimatian()
    if not self.container then return end
    commonOpenActionCentreScale(self.container)
end


function ArenapeakchampionResultPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn) ,false, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
end

--关闭
function ArenapeakchampionResultPanel:onClickCloseBtn()
    controller:openArenapeakchampionResultPanel(false)
end


function ArenapeakchampionResultPanel:openRootWnd(data)
    playOtherSound("b_win", AudioManager.AUDIO_TYPE.BATTLE) 

    self.rank_label:setNum(data.rank or 1)
    self.match_count:setString(data.cnum or 0)
    self.win_count:setString(data.win or 0)
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo then
        self.win_name:setString(TI18N("恭喜 ")..role_vo.name)
    end
end

--清理
function ArenapeakchampionResultPanel:close_callback()

    if self.item_load_bg then
        self.item_load_bg:DeleteMe()
    end
    self.item_load_bg = nil
    controller:openArenapeakchampionResultPanel(false)
end
