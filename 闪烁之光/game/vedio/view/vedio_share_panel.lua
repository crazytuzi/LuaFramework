-- --------------------------------------------------------------------
-- @author: lwcd@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      分享按钮
-- <br/>Create: 2019年3月22日
-- --------------------------------------------------------------------
VedioSharePanel = VedioSharePanel or BaseClass(BaseView)

local controller = VedioController:getInstance()

function VedioSharePanel:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "vedio/vedio_share_panel"
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }
end

function VedioSharePanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    if self.background ~= nil then
        self.background:setSwallowTouches(false)
    end
    self.share_panel = self.root_wnd:getChildByName("share_panel")

    self.share_bg = self.share_panel:getChildByName("share_bg")
    self.btn_guild = self.share_bg:getChildByName("btn_guild")
    self.btn_world = self.share_bg:getChildByName("btn_world")
    self.btn_cross = self.share_bg:getChildByName("btn_cross")
    self.btn_guild:getChildByName("label"):setString(TI18N("分享到公会频道"))
    self.btn_world:getChildByName("label"):setString(TI18N("分享到世界频道"))
    self.btn_cross:getChildByName("label"):setString(TI18N("分享到跨服频道"))
end

function VedioSharePanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn) ,false, 1)
     -- 分享到公会
    registerButtonEventListener(self.btn_guild, handler(self, self.onClickGuildBtn) ,true, 2)
    registerButtonEventListener(self.btn_world, handler(self, self.onClickWorldBtn) ,true, 2)
    registerButtonEventListener(self.btn_cross, handler(self, self.onClickCrossBtn) ,true, 2)
end

--关闭
function VedioSharePanel:onClickCloseBtn()
    controller:openVedioSharePanel(false)
end

-- 分享到公会
function VedioSharePanel:onClickGuildBtn()
    if not self.replay_id then return end
    if RoleController:getInstance():getRoleVo():isHasGuild() == false then
        message(TI18N("您暂未加入公会"))
        return
    end
    controller:requestShareVedio(self.replay_id, ChatConst.Channel.Gang, self.srv_id, self.combat_type)
    if self.callback then
        self.callback(VedioConst.Share_Btn_Type.eGuildBtn)
    end
    self.replay_id = nil
    self:onClickCloseBtn()
end

-- 分享到世界
function VedioSharePanel:onClickWorldBtn()
    if not self.replay_id then return end
    controller:requestShareVedio(self.replay_id, ChatConst.Channel.World, self.srv_id, self.combat_type)
    if self.callback then
        self.callback(VedioConst.Share_Btn_Type.eWorldBtn)
    end
    self.replay_id = nil
    self:onClickCloseBtn()
end

-- 分享到跨服
function VedioSharePanel:onClickCrossBtn(  )
    local cross_config = Config.MiscData.data_const["cross_level"]
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo.lev < cross_config.val then
        message(string.format(TI18N("%d级开启跨服频道"), cross_config.val))
        return
    end
    if not self.replay_id then return end
    controller:requestShareVedio(self.replay_id, ChatConst.Channel.Cross, self.srv_id, self.combat_type)
    if self.callback then
        self.callback(VedioConst.Share_Btn_Type.eCrossBtn)
    end
    self.replay_id = nil
    self:onClickCloseBtn()
end

--replay_id 
-- 1 表示 录像分享
function VedioSharePanel:openRootWnd(replay_id, world_pos, callback, srv_id, combat_type)
    if not replay_id then return end
    self.replay_id = replay_id
    -- self.share_type = share_type
    self.callback = callback
    self.srv_id = srv_id
    self.combat_type = combat_type

    local node_pos = self.share_panel:convertToNodeSpace(world_pos)
    if node_pos then
        self.share_bg:setPosition(cc.p(node_pos.x-38, node_pos.y+70))
    end
end

function VedioSharePanel:close_callback()
    controller:openVedioSharePanel(false)
end