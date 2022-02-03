--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年6月5日
-- @description    : 
        -- 荣誉墙徽章解锁界面
---------------------------------
RoleHonorUnlockPanel = RoleHonorUnlockPanel or BaseClass(BaseView)

local controller = RoleController:getInstance()

function RoleHonorUnlockPanel:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace", "txt_cn_role_honor_title", false), type = ResourcesType.single}
    }
    self.is_csb_action = true
    self.layout_name = "roleinfo/role_honor_unlock_panel"
end

function RoleHonorUnlockPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    
    self.main_container = self.root_wnd:getChildByName("main_container")
    -- self:playEnterAnimatianByObj(self.main_container , 2)
    self.title_icon_effect = self.main_container:getChildByName("title_icon_effect")
    self.title_width = self.title_icon_effect:getContentSize().width
    self.title_height = self.title_icon_effect:getContentSize().height
    local title_sprite = self.main_container:getChildByName("title_sprite")
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace", "txt_cn_role_honor_title")
    if not self.load_title then
        self.load_title = loadSpriteTextureFromCDN(title_sprite, bg_res, ResourcesType.single, self.load_title)
    end

    self.item_node = self.main_container:getChildByName("item_node")
    self.honor_item = RoleHonorItem.new(1)
    self.item_node:addChild(self.honor_item)
    self.name = self.main_container:getChildByName("name")

    self.close_btn = self.main_container:getChildByName("close_btn")
    self.close_btn:getChildByName("label"):setString(TI18N("关 闭"))
    self.share_btn = self.main_container:getChildByName("share_btn")
    self.share_btn:getChildByName("label"):setString(TI18N("分 享"))

    local size = self.main_container:getContentSize()
    self.desc = createRichLabel(18, cc.c3b(255,232,183), cc.p(0.5, 0.5), cc.p(size.width * 0.5, 166), nil, nil, 500)
    self.main_container:addChild(self.desc)
end

function RoleHonorUnlockPanel:register_event(  )
    registerButtonEventListener(self.background, function()
        controller:openRoleHonorUnlockPanel(false)
    end,false, 2)
    registerButtonEventListener(self.close_btn, function() controller:openRoleHonorUnlockPanel(false) end ,true, 2)
    registerButtonEventListener(self.share_btn, function(param, sender) self:onShareBtn(sender)  end ,true, 1)
end

--分享
function RoleHonorUnlockPanel:onShareBtn(sender)
    if not self.config then return end
    local setting = {}
    setting.world_pos = sender:convertToWorldSpace(cc.p(0.5, 0.5))
    setting.callback = function(share_type) self:shareCallback(share_type) end
    TaskController:getInstance():openTaskSharePanel(true, setting)
end

function RoleHonorUnlockPanel:shareCallback(share_type)
    if not self.config then return end
    if share_type == VedioConst.Share_Btn_Type.eWorldBtn then --分享到世界
        RoleController:getInstance():send25815(self.config.id, ChatConst.Channel.World)
    elseif share_type == VedioConst.Share_Btn_Type.eGuildBtn then --分享公会
        RoleController:getInstance():send25815(self.config.id, ChatConst.Channel.Gang)
    elseif share_type == VedioConst.Share_Btn_Type.eCrossBtn then --跨服分享
        RoleController:getInstance():send25815(self.config.id, ChatConst.Channel.Cross)
    end
end


function RoleHonorUnlockPanel:openRootWnd(setting)
    local setting = setting or {}
    local id = setting.id
    if not id then return end

    local config = Config.RoomFeatData.data_honor_icon_info[id]
    if not config then return end
    self.config = config
    playOtherSound("c_get")
    self.honor_item:setData({config = config})
    self.honor_item:setShowEffect(true)

    self.name:setString(config.name)

    self:handleEffect(true)
    self.desc:setString(string.format("<div outline=2,#000000>%s</div>",config.desc2))

    self:runmoveAction(self.honor_item, 0.2)
    self:runmoveAction(self.name, 0.2)
    self:runmoveAction(self.desc, 0.3)
end

function RoleHonorUnlockPanel:runmoveAction(node, delay)
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

function RoleHonorUnlockPanel:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        if not tolua.isnull(self.title_icon_effect) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(1306), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.title_icon_effect:addChild(self.play_effect, 1)
            self.play_effect:setOpacity(0)
            local fadeIn = cc.FadeIn:create(0.5)
            self.play_effect:runAction(fadeIn)
        end
    end
end 

function RoleHonorUnlockPanel:close_callback()
    doStopAllActions(self.name)
    doStopAllActions(self.desc)
    self:handleEffect(false)
    if self.load_title then
        self.load_title:DeleteMe()
    end
    self.load_title = nil
    if self.honor_item then
        self.honor_item:DeleteMe()
        self.honor_item = nil
    end
    controller:openRoleHonorUnlockPanel(false)
end