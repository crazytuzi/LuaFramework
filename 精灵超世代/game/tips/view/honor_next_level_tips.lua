-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      荣誉墙 next level tips
-- <br/> 2019年6月3日
-- --------------------------------------------------------------------
HonorNextLevelTips = HonorNextLevelTips or BaseClass(BaseView)

local controller = TipsController:getInstance()

local string_format = string.format

function HonorNextLevelTips:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "tips/honor_next_level_tips"
    self.win_type = WinType.Mini   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.item_list = {}
end

function HonorNextLevelTips:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    -- self.bg = self.main_panel:getChildByName("bg")
    -- local res = PathTool.getPlistImgForDownLoad("bigbg", "txt_cn_honor_level_bg_1")
    -- self.item_load_bg = loadSpriteTextureFromCDN(self.bg, res, ResourcesType.single, self.item_load_bg)

    self.win_title = self.main_panel:getChildByName("win_title")
    self.win_title:setString(TI18N("荣誉等级"))

    self.honor_icon = self.main_panel:getChildByName("honor_icon")
    self.level_name = self.main_panel:getChildByName("level_name")

    self.player_name = self.main_panel:getChildByName("player_name")
    self.honor_point_key = self.main_panel:getChildByName("honor_point_key")
    self.honor_point_key:setString(TI18N("荣誉点数:"))
    self.collect_count_key = self.main_panel:getChildByName("collect_count_key")
    self.collect_count_key:setString(TI18N("收集数:"))

    self.honor_point_value = self.main_panel:getChildByName("honor_point_value")
    self.collect_count_value = self.main_panel:getChildByName("collect_count_value")

    self.next_honor_icon = self.main_panel:getChildByName("next_honor_icon")
    self.next_level_name = self.main_panel:getChildByName("next_level_name")
    self.next_tips = self.main_panel:getChildByName("next_tips")
    self.next_tips:setString(TI18N("下一级"))
    self.need_point = self.main_panel:getChildByName("need_point")
end

function HonorNextLevelTips:register_event()
    registerButtonEventListener(self.background, function() self:onCloseBtn()  end ,false, 2)
    -- registerButtonEventListener(self.close_btn, function() self:onCloseBtn()  end ,true, 2)

end

function HonorNextLevelTips:onCloseBtn(  )
    controller:openHonorNextLevelTips(false)
end
-- @setting.point 收集点数
-- @setting.num 收集徽章数量
-- @setting.role_data 10315协议数据 也是role_vo
-- @setting.show_type 参考 RoleConst.role_type.eOther
function HonorNextLevelTips:openRootWnd(setting)
    local setting = setting or {}

    local show_type = setting.show_type or RoleConst.role_type.eOther

    local point = setting.point or 0
    local num = setting.num or 0
    local role_data = setting.role_data or {}
    self.role_data = role_data
    local model = RoleController:getInstance():getModel()
    local name, res_id, max, next_name, next_res_id = model:getHonorPointName(point)
    self.level_name:setString(name or "")
    self.honor_point_value:setString(point)
    self.collect_count_value:setString(num)

    self.player_name:setString(role_data.name or "")

    self.next_level_name:setString(next_name or "")

    res_id = res_id or 1
    local res = PathTool.getPlistImgForDownLoad("rolehonorwall/honorwarllicon", "honor_level_"..res_id, false)
    if self.record_honor_icon_res == nil or self.record_honor_icon_res ~= res then
        self.record_honor_icon_res = res
        self.item_load_honor_icon = loadSpriteTextureFromCDN(self.honor_icon, res, ResourcesType.single, self.item_load_honor_icon) 
    end

    if show_type ==  RoleConst.role_type.eOther then
        --他人
    else
        --自己
        if max then
            if max == -1 then
                self.need_point:setString(TI18N("当前已是最高荣誉"))
            else
                self.need_point:setString(TI18N("所需荣誉点数: ")..max)
            end
        end

        next_res_id = next_res_id or 1
        local res = PathTool.getPlistImgForDownLoad("rolehonorwall/honorwarllicon", "honor_level_"..next_res_id, false)
        if self.record_honor_next_icon_res == nil or self.record_honor_next_icon_res ~= res then
            self.record_honor_next_icon_res = res
            self.item_load_next_honor_icon = loadSpriteTextureFromCDN(self.next_honor_icon, res, ResourcesType.single, self.item_load_next_honor_icon) 
        end
    end
end




function HonorNextLevelTips:close_callback()


    -- if self.item_load_bg then
    --     self.item_load_bg:DeleteMe()
    --     item_load_bg = nil
    -- end
    if self.item_load_honor_icon then
        self.item_load_honor_icon:DeleteMe()
        item_load_honor_icon = nil
    end
    if self.item_load_next_honor_icon then
        self.item_load_next_honor_icon:DeleteMe()
        item_load_next_honor_icon = nil
    end

    controller:openHonorNextLevelTips(false)
end