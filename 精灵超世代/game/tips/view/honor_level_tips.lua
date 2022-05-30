-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      荣誉墙 level tips
-- <br/> 2019年6月3日
-- --------------------------------------------------------------------
HonorLevelTips = HonorLevelTips or BaseClass(BaseView)

local controller = TipsController:getInstance()

local string_format = string.format

function HonorLevelTips:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "tips/honor_level_tips"
    self.win_type = WinType.Mini   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.item_list = {}
end

function HonorLevelTips:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    -- self.bg = self.main_panel:getChildByName("bg")
    -- local res = PathTool.getPlistImgForDownLoad("bigbg", "txt_cn_honor_level_bg")
    -- self.item_load_bg = loadSpriteTextureFromCDN(self.bg, res, ResourcesType.single, self.item_load_bg)

    self.honor_icon = self.main_panel:getChildByName("honor_icon")
    self.level_name = self.main_panel:getChildByName("level_name")

    self.player_name = self.main_panel:getChildByName("player_name")
    self.honor_point_key = self.main_panel:getChildByName("honor_point_key")
    self.honor_point_key:setString(TI18N("荣誉点数:"))
    self.collect_count_key = self.main_panel:getChildByName("collect_count_key")
    self.collect_count_key:setString(TI18N("收集数:"))

    self.honor_point_value = self.main_panel:getChildByName("honor_point_value")
    self.collect_count_value = self.main_panel:getChildByName("collect_count_value")

    self.next_label = createRichLabel(20, cc.c4b(0x95,0x53,0x22,0xff), cc.p(0.5,1), cc.p(227,66), nil, nil, 900)
    self.main_panel:addChild(self.next_label)

    self.btn_label = createRichLabel(22,cc.c3b(36, 144, 3), cc.p(0.5,0.5),cc.p(366, 53))
    self.btn_label:setString(string_format("<div href=xxx>%s</div>", TI18N("前往查看")))
    self.main_panel:addChild(self.btn_label)

    self.btn_label:addTouchLinkListener(function(type, value, sender, pos)
        self:onCloseBtn()
        if not self.role_data then return end
        local role_vo = RoleController:getInstance():getRoleVo()
        if not role_vo then return end

        if self.role_data.rid == role_vo.rid and self.role_data.srv_id == role_vo.srv_id then
            --是自己: 直接打开
            RoleController:getInstance():openRolePersonalSpacePanel(true, {index = RoleConst.Tab_type.eHonorWall})
        else
            RoleController:getInstance():requestRoleInfo( self.role_data.rid,self.role_data.srv_id, {form_type = RoleConst.Other_Form_Type.eHonorLevelTips})
        end
        
    end, { "click", "href" })

end

function HonorLevelTips:register_event()
    registerButtonEventListener(self.background, function() self:onCloseBtn()  end ,false, 2)
    -- registerButtonEventListener(self.close_btn, function() self:onCloseBtn()  end ,true, 2)

end

function HonorLevelTips:onCloseBtn(  )
    controller:openHonorLevelTips(false)
end
-- @setting.point 收集点数
-- @setting.num 收集徽章数量
-- @setting.role_data 10315协议数据 也是role_vo
-- @setting.show_type 参考 RoleConst.role_type.eOther
-- @setting.is_hide_btn_label 是否隐藏按钮
function HonorLevelTips:openRootWnd(setting)
    local setting = setting or {}

    local show_type = setting.show_type or RoleConst.role_type.eOther

    local is_hide_btn_label = setting.is_hide_btn_label or false

    local point = setting.point or 0
    local num = setting.num or 0
    local role_data = setting.role_data or {}
    self.role_data = role_data
    local model = RoleController:getInstance():getModel()
    local name, res_id, max = model:getHonorPointName(point)
    self.level_name:setString(name)
    self.honor_point_value:setString(point)
    self.collect_count_value:setString(num)

    self.player_name:setString(role_data.name or "")

    res_id = res_id or 1
    local res = PathTool.getPlistImgForDownLoad("rolehonorwall/honorwarllicon", "honor_level_"..res_id, false)
    if self.record_honor_icon_res == nil or self.record_honor_icon_res ~= res then
        self.record_honor_icon_res = res
        self.item_load_honor_icon = loadSpriteTextureFromCDN(self.honor_icon, res, ResourcesType.single, self.item_load_honor_icon) 
    end

    if show_type ==  RoleConst.role_type.eOther then
        --他人
        if is_hide_btn_label then
            self.btn_label:setVisible(false)
        else
            self.btn_label:setVisible(true)
        end
    else
        self.btn_label:setVisible(false)
        --自己
        if max then
            if max == -1 then
                self.next_label:setString(TI18N("当前已是最高荣誉"))
            else
                self.next_label:setString(TI18N("下一级荣誉所需点数:")..max)
            end
        end
    end
end




function HonorLevelTips:close_callback()


    -- if self.item_load_bg then
    --     self.item_load_bg:DeleteMe()
    --     item_load_bg = nil
    -- end
    if self.item_load_honor_icon then
        self.item_load_honor_icon:DeleteMe()
        item_load_honor_icon = nil
    end

    controller:openHonorLevelTips(false)
end