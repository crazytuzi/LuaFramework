-- --------------------------------------------------------------------
-- 星命塔结算前提示界面
-- 
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-4-7
-- --------------------------------------------------------------------
StarTowerTipsWindow = StarTowerTipsWindow or BaseClass(BaseView)

function StarTowerTipsWindow:__init(tower)
    self.ctrl = StartowerController:getInstance()
    self.is_full_screen = false
    self.layout_name = "startower/star_tower_tips_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("startower", "startower_bg_1"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("startower", "startower_bg_2"), type = ResourcesType.single },
    }
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.tower = tower or 0
end

function StarTowerTipsWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.background:setVisible(true)

    self.main_panel = self.root_wnd:getChildByName("main_container")
    ActionHelp.itemOpacityAction(self.main_panel,0,0.75)
    self.main_panel:setTouchEnabled(false)
    
    self.bg_img = self.main_panel:getChildByName("bg_img")
    local res = PathTool.getPlistImgForDownLoad("startower", "startower_bg_2")
    self.bg_img_load = loadSpriteTextureFromCDN(self.bg_img, res, ResourcesType.single, self.bg_img_load)

    self.bg_img_2 = self.main_panel:getChildByName("bg_img_2")
    self.bg_img_2:setOpacity(0)
    local res = PathTool.getPlistImgForDownLoad("startower", "startower_bg_1")
    self.bg_img_load_2 = loadSpriteTextureFromCDN(self.bg_img_2, res, ResourcesType.single, self.bg_img_load_2)
    
    self.tips_lab = self.main_panel:getChildByName("tips_lab")
    self.tips_lab:setOpacity(0)
    self.tips_lab:setString(TI18N("惹不起，快溜~"))
    delayOnce(function()
        if self.tips_lab and not tolua.isnull(self.tips_lab) and self.bg_img_2 and not tolua.isnull(self.bg_img_2) then
            ActionHelp.itemOpacityAction(self.tips_lab,0,0.25)
            ActionHelp.itemOpacityAction(self.bg_img_2,0,0.25)
        end
    end, 0.5)
    self.time_label = createRichLabel(22,Config.ColorData.data_color4[1],cc.p(0.5,0.5),cc.p(360,200),nil,nil,500)
    self.main_panel:addChild(self.time_label)
    self.time_label:setString(TI18N("5秒后关闭"))
end

function StarTowerTipsWindow:register_event()
 
    registerButtonEventListener(self.background, function()
        self:checkCloseBtn()
    end, false, 2)
end


function StarTowerTipsWindow:updateTimer()
    local time = 5
    local call_back = function()
        time = time - 1
        local new_time = math.ceil(time)
		local str = new_time..TI18N("秒后关闭")
		if self.time_label and not tolua.isnull(self.time_label) then
			self.time_label:setString(str)
		end
        if new_time <= 0 then
            self:checkCloseBtn()
            GlobalTimeTicket:getInstance():remove("close_starTower_tips_view")
        end
    end
    GlobalTimeTicket:getInstance():add(call_back,1, 0, "close_starTower_tips_view")
end

function StarTowerTipsWindow:openRootWnd(data)
    self.battle_data = data
    self:updateTimer()
end

function StarTowerTipsWindow:checkCloseBtn(  )
    self.ctrl:openTipsWindow(false)
    BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.StarTower, self.battle_data)
end

function StarTowerTipsWindow:close_callback()
    GlobalTimeTicket:getInstance():remove("close_starTower_tips_view")
    if self.bg_img_load then 
        self.bg_img_load:DeleteMe()
        self.bg_img_load = nil
    end

    if self.bg_img_load_2 then 
        self.bg_img_load_2:DeleteMe()
        self.bg_img_load_2 = nil
    end

    self.ctrl:openTipsWindow(false)
end







