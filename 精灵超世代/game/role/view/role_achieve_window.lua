--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 隐藏成就
-- @DateTime:    2019-06-10 16:27:15
-- *******************************
RoleAchieveWindow = RoleAchieveWindow or BaseClass(BaseView)

local controller = RoleController:getInstance()

function RoleAchieveWindow:__init(view_tag)
    self.win_type = WinType.Mini
    self.view_tag = view_tag or ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace", "txt_cn_task_achieve", false), type = ResourcesType.single}
    }
    self.is_csb_action = true
    self.layout_name = "roleinfo/role_achieve_window"
end

function RoleAchieveWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    
    local main_container = self.root_wnd:getChildByName("main_container")
    -- self:playEnterAnimatianByObj(main_container , 2)
    local bg = main_container:getChildByName("bg")
    bg:setScale(1.5)
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace", "txt_cn_task_achieve")
    if not self.load_bg then
        self.load_bg = loadSpriteTextureFromCDN(bg, bg_res, ResourcesType.single, self.load_bg)
    end
    self.action_1 = self.root_wnd:getChildByName("action_1")
    self.action_1:setPositionY(695)

    self.name = main_container:getChildByName("name")
    self.name:setString("")
    self.desc = main_container:getChildByName("desc")
    self.desc:setString("")
    self.share_btn = main_container:getChildByName("share_btn")
    self.share_btn_label = self.share_btn:getChildByName("label")
    self.share_btn_label:setString(TI18N("分享"))
    self.close_btn = main_container:getChildByName("close_btn")
    self.close_btn:getChildByName("label"):setString(TI18N("关闭"))
end
function RoleAchieveWindow:register_event(  )
    -- registerButtonEventListener(self.background, function()
    --     controller:openRoleAchieveWindow(false)
    -- end,false, 2)
    registerButtonEventListener(self.close_btn, function()
    	controller:openRoleAchieveWindow(false)
    end,true, 2)
    registerButtonEventListener(self.share_btn, function(param, sender)
    	self:onShareBtn(sender)
    end,true, 1)
end
--分享
function RoleAchieveWindow:onShareBtn(sender)
    if not self.config then return end
    if self.is_home_world_feat then
        TaskController:getInstance():openTaskMainWindow(true, TaskConst.type.exp)
    else
        local setting = {}
        setting.world_pos = sender:convertToWorldSpace(cc.p(0.5, 0.5))
        setting.callback = function(share_type) self:shareCallback(share_type) end
        TaskController:getInstance():openTaskSharePanel(true, setting)
    end
end

function RoleAchieveWindow:shareCallback(share_type)
    if not self.config then return end
    if share_type == VedioConst.Share_Btn_Type.eWorldBtn then --分享到世界
        RoleController:getInstance():send25817(self.config.id, ChatConst.Channel.World)
    elseif share_type == VedioConst.Share_Btn_Type.eGuildBtn then --分享公会
        RoleController:getInstance():send25817(self.config.id, ChatConst.Channel.Gang)
    elseif share_type == VedioConst.Share_Btn_Type.eCrossBtn then --跨服分享
        RoleController:getInstance():send25817(self.config.id, ChatConst.Channel.Cross)
    end
end

function RoleAchieveWindow:openRootWnd(data)
    if not data then return end
	local id = data.id or 1
	local config = Config.RoomFeatData.data_exp_info[id]
    if not config then return end
    self.config = config
    playOtherSound("c_get")
    self.name:setString(self.config.name)
    self.desc:setString(self.config.desc)

    self:runmoveAction(self.name, 0.2)
    self:runmoveAction(self.desc, 0.3)
    self:handleEffect(true)

    local config = Config.RoomFeatData.data_const.home_world_feat
    if config and config.val == self.config.id then
        self.is_home_world_feat = true
        self.share_btn_label:setString(TI18N("前往"))
    end
end

function RoleAchieveWindow:runmoveAction(node, delay)
    if delay <= 0 then
        delay = 1
    end
    local x, y = node:getPosition()
    node:setOpacity(0)
    local fadeIn = cc.FadeIn:create(0.4)
    node:runAction(cc.Sequence:create(cc.DelayTime:create(delay), fadeIn))
end

function RoleAchieveWindow:handleEffect(status)
    if status == false then
        if self.play_effect1 then
            self.play_effect1:clearTracks()
            self.play_effect1:removeFromParent()
            self.play_effect1 = nil
        end
        if self.play_effect2 then
            self.play_effect2:clearTracks()
            self.play_effect2:removeFromParent()
            self.play_effect2 = nil
        end
    else
        if not tolua.isnull(self.action_1) and self.play_effect1 == nil then
            self.play_effect1 = createEffectSpine(PathTool.getEffectRes(1307), cc.p(50, 50), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.action_1:addChild(self.play_effect1, 2)
        end
        if not tolua.isnull(self.action_1) and self.play_effect2 == nil then
            self.play_effect2 = createEffectSpine(PathTool.getEffectRes(1307), cc.p(50, 50), cc.p(0.5, 0.5), true, PlayerAction.action_2)
            self.action_1:addChild(self.play_effect2, 1)
        end
    end
end
function RoleAchieveWindow:close_callback()
    doStopAllActions(self.name)
    doStopAllActions(self.desc)
    self:handleEffect(false)
    if self.load_bg then
        self.load_bg:DeleteMe()
    end
    self.load_bg = nil

    
    if self.is_home_world_feat and self.config then
        controller:sender25813(self.config.id)
    end

    controller:openRoleAchieveWindow(false)
end
