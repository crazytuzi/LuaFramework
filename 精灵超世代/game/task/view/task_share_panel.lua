-- --------------------------------------------------------------------
-- @author: lwcd@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      分享按钮
-- <br/>Create: 2019年3月22日
-- --------------------------------------------------------------------
TaskSharePanel = TaskSharePanel or BaseClass(BaseView)

local controller = TaskController:getInstance()

function TaskSharePanel:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "vedio/vedio_share_panel"
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }
end

function TaskSharePanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setSwallowTouches(false)
    end
    self.share_panel = self.root_wnd:getChildByName("share_panel")    

    self.share_bg = self.share_panel:getChildByName("share_bg")
    self.btn_guild = self.share_bg:getChildByName("btn_guild")
    self.btn_world = self.share_bg:getChildByName("btn_world")
    self.btn_cross = self.share_bg:getChildByName("btn_cross")
    local lblAlliacne =self.btn_guild:getChildByName("label")
    lblAlliacne:setString(TI18N("分享到公会频道"))
    lblAlliacne:setFontSize(14)
    local lblWorld = self.btn_world:getChildByName("label")
    lblWorld:setString(TI18N("分享到世界频道"))
    lblWorld:setFontSize(14)
    local lblCross = self.btn_cross:getChildByName("label")
    lblCross:setString(TI18N("分享到公会频道"))
    lblCross:setFontSize(14)
    -- self.btn_guild:getChildByName("label"):setString(TI18N("分享到公会频道"))
    -- self.btn_world:getChildByName("label"):setString(TI18N("分享到世界频道"))
    self.btn_cross:getChildByName("label"):setString(TI18N("分享到跨服频道"))
end

function TaskSharePanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn) ,false, 1)
     -- 分享到公会
    registerButtonEventListener(self.btn_guild, handler(self, self.onClickGuildBtn) ,true, 2)
    registerButtonEventListener(self.btn_world, handler(self, self.onClickWorldBtn) ,true, 2)
    registerButtonEventListener(self.btn_cross, handler(self, self.onClickCrossBtn) ,true, 2)
end

--关闭
function TaskSharePanel:onClickCloseBtn()
    controller:openTaskSharePanel(false)
end

-- 分享到公会
function TaskSharePanel:onClickGuildBtn()
    if RoleController:getInstance():getRoleVo():isHasGuild() == false then
        message(TI18N("您暂未加入公会"))
        return
    end
    if self.callback then
        self.callback(VedioConst.Share_Btn_Type.eGuildBtn)
    end
    self:onClickCloseBtn()
end

-- 分享到世界
function TaskSharePanel:onClickWorldBtn()
    if self.callback then
        self.callback(VedioConst.Share_Btn_Type.eWorldBtn)
    end
    self.replay_id = nil
    self:onClickCloseBtn()
end

-- 分享到跨服
function TaskSharePanel:onClickCrossBtn(  )
    local cross_config = Config.MiscData.data_const["cross_level"]
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo.lev < cross_config.val then
        message(string.format(TI18N("%d级开启跨服频道"), cross_config.val))
        return
    end
    if self.callback then
        self.callback(VedioConst.Share_Btn_Type.eCrossBtn)
    end
    self:onClickCloseBtn()
end

--replay_id 
-- 1 表示 录像分享
function TaskSharePanel:openRootWnd(setting , callback)
    -- self.share_type = share_type
    local setting = setting or {}
    local world_pos = setting.world_pos
    self.callback = setting.callback
    local x = setting.x or 0
    local y = setting.y or 0

    local node_pos = self.share_panel:convertToNodeSpace(world_pos)
    if node_pos then
        self.share_bg:setPosition(cc.p(node_pos.x - 38 + x, node_pos.y + 70 + y))
    end
end

function TaskSharePanel:close_callback()
    controller:openTaskSharePanel(false)
end
