-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      好友支援单项列表
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EndlessFriendHelpItem =
    class(
    "EndlessFriendHelpItem",
    function()
        return ccui.Layout:create()
    end
)

function EndlessFriendHelpItem:ctor()
    self.item_list = {}
    self.is_init = false
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("endlesstrail/endlesstrail_friend_help_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)
    local container = self.root_wnd:getChildByName("container")
    self.career_name = container:getChildByName("career_name")
    self.career_icon = container:getChildByName("career_icon")
    self.return_icon = container:getChildByName("return_icon")
    self.return_icon:setVisible(false)
    self.power_panel = container:getChildByName("power_panel")
    self.role_power = self.power_panel:getChildByName("role_power")
    self.role_name = container:getChildByName("role_name")
    self.help_button = container:getChildByName("help_button")
    self.help_label = self.help_button:getChildByName("help_label")
    self.help_label:setString(TI18N("选择"))
    self.firend_label = container:getChildByName("firend_label")
    self.firend_label:setVisible(false)
    self.lock_panel = container:getChildByName("lock_panel")
    local limit_label = self.lock_panel:getChildByName("limit_label")
    limit_label:setString(TI18N("战力超出范围"))
    self.lock_panel:setVisible(false)
    
    self.hero_icon = HeroExhibitionItem.new(1)
    self.hero_icon:setPosition(80,75)
    self.hero_icon:addCallBack(handler(self, self.onClickHeroItem))
    container:addChild(self.hero_icon)

    self:registerEvent()
end

function EndlessFriendHelpItem:onClickHeroItem( )
    if self.data then 
        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo and role_vo.rid == self.data.rid and role_vo.srv_id == self.data.srv_id then
            --自己
            local hero_vo = HeroController:getInstance():getModel():getHeroById(self.data.id)
            HeroController:getInstance():openHeroTipsPanel(true, hero_vo)
        else
            LookController:getInstance():sender11061(self.data.rid, self.data.srv_id, self.data.id)
        end
    end
end

function EndlessFriendHelpItem:registerEvent()
    if self.help_button then
        self.help_button:addTouchEventListener(function (sender,eventType)
            if eventType == ccui.TouchEventType.ended then
                if self.click_fun and self.data then
                    if self.data.select == true then
                        self.click_fun(self, self.data, self.index, false)
                    else
                        self.click_fun(self, self.data, self.index, true)
                    end
                end
            end
        end)
    end
end

function EndlessFriendHelpItem:setData(data)
    self.data = data 
    if self.data then
        self.type = self.data.type
        self.info_data = self.data.info_data
        self.index = self.data._index
        self.hero_icon:setData(self.data)

        self.firend_label:setString(TI18N("来自好友:")..self.data.name)
        self.role_power:setString(self.data.power)
        self.firend_label:setVisible(true)
        self.power_panel:setPosition(181,43)
        local config = Config.PartnerData.data_partner_base[self.data.bid]
        if config then
            self.role_name:setString(config.name)
        end
        if self.data.is_lock == true then
            self.lock_panel:setVisible(true)
            self.help_button:setVisible(false)
        else
            self.lock_panel:setVisible(false)
            self.help_button:setVisible(true)
        end

        if self.data.is_return == 1 then
            self.return_icon:setVisible(true)
        else
            self.return_icon:setVisible(false)
        end
       
        --[[if self.data.select == true and not self.is_init then
            self.click_fun(self, self.data, self.index,true,true)
            self.is_init = true
        end--]]
        self:updateBtnStatus(self.data.select)
        local res = PathTool.getCareerIcon(self.info_data.type)
        loadSpriteTexture(self.career_icon, res, LOADTEXT_TYPE_PLIST)
        local str = PartnerConst.Hero_Type[self.info_data.type] or ""
        self.career_name:setString("["..str.."]")
    end
end

function EndlessFriendHelpItem:getData(  )
    return self.data
end

function EndlessFriendHelpItem:addCallBack(click_fun)
    self.click_fun = click_fun
end

function EndlessFriendHelpItem:updateBtnStatus(status)
    if status == true then
        self.help_button:loadTextures(
                PathTool.getResFrame('common', 'common_1017'),
                PathTool.getResFrame('common', 'common_1017'),
                PathTool.getResFrame('common', 'common_1017'),
                LOADTEXT_TYPE_PLIST
            )
        self.help_label:setString(TI18N("取消选择"))
        self.help_label:enableOutline(Config.ColorData.data_color4[264],2)
    else
        self.help_button:loadTextures(
            PathTool.getResFrame("common", "common_1018"),
            PathTool.getResFrame("common", "common_1018"),
            PathTool.getResFrame("common", "common_1018"),
            LOADTEXT_TYPE_PLIST
        )

        self.help_label:setString(TI18N("选择"))
        self.help_label:enableOutline(Config.ColorData.data_color4[263],2)

    end
end

function EndlessFriendHelpItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end
