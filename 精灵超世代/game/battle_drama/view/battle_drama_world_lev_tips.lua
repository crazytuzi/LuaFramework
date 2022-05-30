-- --------------------------------------------------------------------
-- @author: whjing@syg.com(必填, 创建模块的人员)
-- @description:
--      命格tips,这个主要包含了左右移动按钮的处理
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------

BattleDramaWorldLevTips = BattleDramaWorldLevTips or BaseClass(BaseView)
local _controller = BattleDramaController:getInstance() 

function BattleDramaWorldLevTips:__init()
    self.is_full_screen = false
    self.win_type = WinType.Tips
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.layout_name = "battledrama/battle_drama_world_lev_tips"
end

function BattleDramaWorldLevTips:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background ~= nil then
		self.background:setScale(display.getMaxScale())
	end 
    self.container = self.root_wnd:getChildByName("main_panel")
    self.close_btn = self.container:getChildByName("close_btn")
    self.cur_label = self.container:getChildByName("cur_label")
    self.lev_label = self.container:getChildByName("lev_label")
    self.title_label = self.container:getChildByName("title_label")
    self.desc = createRichLabel(22, 175, cc.p(0, 0), cc.p(48,190), 6, nil, 320)
    self.container:addChild(self.desc)
    self.desc2 = createRichLabel(22, 178, cc.p(0, 1), cc.p(48,145), 8, nil, 320)
    self.container:addChild(self.desc2)
end

function BattleDramaWorldLevTips:register_event()
    self.background:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            _controller:openWorldLevTips(false)
        end
    end)
    self.close_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            _controller:openWorldLevTips(false)
        end
    end)
end

function BattleDramaWorldLevTips:openRootWnd()
    self.desc:setString(Config.WorldLevData.data_const.world_lev_desc.desc)
    local lev = RoleController:getInstance():getRoleVo().lev
    local world_lev = RoleController:getInstance():getModel():getWorldLev()
    local world_config = Config.WorldLevData.data_get(math.max(0, world_lev - lev)) or {}
    self.lev_label:setString(string.format(TI18N("%s等级"), world_lev))
    if world_config.exp_ratio and world_config.exp_ratio > 0 then
        self.desc2:setString(string.format(TI18N("您当前低于世界等级%s级，获得角色经验加%s%s，额外加速作战次数%s次"), world_lev - lev, world_config.exp_ratio / 10, "%", world_config.dun_quick_combat))
    end
end

function BattleDramaWorldLevTips:close_callback()
end
