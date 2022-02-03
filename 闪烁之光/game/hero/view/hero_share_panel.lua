-- --------------------------------------------------------------------
-- @author: lwcd@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      英雄界面分享.. 段位赛分享也用这个
-- <br/>Create: 2019年4月9日
-- --------------------------------------------------------------------
HeroSharePanel = HeroSharePanel or BaseClass(BaseView)

local controller = HeroController:getInstance()

function HeroSharePanel:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "hero/hero_share_panel"
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }
end

function HeroSharePanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")

    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
        -- self.background:setSwallowTouches(false)
    end
    self.share_panel = self.root_wnd:getChildByName("share_panel")

    self.share_bg = self.share_panel:getChildByName("share_bg")


    local btn_type_list = {
        [1] = HeroConst.ShareBtnType.eHeroShareCross,
        [2] = HeroConst.ShareBtnType.eHeroShareWorld,
        [3] = HeroConst.ShareBtnType.eHeroShareGuild
    }
    local btn_name_list = {
        [HeroConst.ShareBtnType.eHeroShareCross] = TI18N("跨服频道"),
        [HeroConst.ShareBtnType.eHeroShareWorld] = TI18N("世界频道"),
        [HeroConst.ShareBtnType.eHeroShareGuild] = TI18N("公会频道")
    }
    self.btn_list = {}
    for i,btn_type in ipairs(btn_type_list) do
        local btn_data = {}
        btn_data.btn = self.share_bg:getChildByName("btn_"..i)
        btn_data.label = btn_data.btn:getChildByName("label")
        btn_data.label:setString(btn_name_list[btn_type])
        self.btn_list[btn_type] = btn_data
    end
end

function HeroSharePanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn) ,false, 1)

    for btn_type,btn_data in pairs(self.btn_list) do
        registerButtonEventListener(btn_data.btn, function() self:onClickBtnByIndex(btn_type) end ,true, 2)    
    end
end

--关闭
function HeroSharePanel:onClickCloseBtn()
    controller:openHeroSharePanel(false)
end



-- 分享到公会
function HeroSharePanel:onClickBtnByIndex(btn_type)
    local is_call_back = false
    if btn_type == HeroConst.ShareBtnType.eHeroShareCross then
        --跨服频道
        is_call_back = true
    elseif btn_type == HeroConst.ShareBtnType.eHeroShareWorld then
        --世界频道
        is_call_back = true
    elseif btn_type == HeroConst.ShareBtnType.eHeroShareGuild then
        --公会频道
        if RoleController:getInstance():getRoleVo():isHasGuild() == false then
            message(TI18N("您暂未加入公会"))
        else
            is_call_back = true
        end
    end
    if is_call_back and self.callback then
        self.callback(btn_type, self.setting)
    end
    self:onClickCloseBtn()
end

--@world_pos 世界坐标位置
--@callback 回调函数 返回时候自行处理自己的函数
--@setting 配置文件.也会从callback原路返回
function HeroSharePanel:openRootWnd(world_pos, callback, setting)
    if not world_pos then return end
    self.callback = callback
    local setting = setting or {}
    self.setting = setting
    self.callback = callback
    local node_pos = self.share_panel:convertToNodeSpace(world_pos)
    if node_pos then
        local offsetx = setting.offsetx or 0
        local offsety = setting.offsety or 0
        self.share_bg:setPosition(cc.p(node_pos.x + offsetx, node_pos.y + offsety))
    end
end

function HeroSharePanel:close_callback()
    controller:openHeroSharePanel(false)
end