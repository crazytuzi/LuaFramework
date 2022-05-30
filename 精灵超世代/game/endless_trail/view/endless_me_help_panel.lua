-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      无尽试炼我的支援界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EndlessMeHelpPanel = class("EndlessMeHelpPanel", function()
    return ccui.Layout:create()
end)

local controller = Endless_trailController:getInstance()
local model = Endless_trailController:getInstance():getModel() 

function EndlessMeHelpPanel:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("endlesstrail/endlesstrail_me_help_panel"))
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5 - 10, self.size.height * 0.5 - 40)
    self:addChild(self.root_wnd)

    --local container = self.root_wnd:getChildByName("container")
    local scroll_container = self.root_wnd:getChildByName("scroll_container")
    local desc_title = scroll_container:getChildByName("desc_title")
    desc_title:setString(TI18N("可选宝可梦"))
    local desc_label = scroll_container:getChildByName("desc_label")
    desc_label:setString(TI18N("每日派遣支援宝可梦可得奖励，若宝可梦被使用自己将获得友情点"))
    -- self.comfirm_button = scroll_container:getChildByName("comfirm_button")
    -- self.comfirm_label = self.comfirm_button:getChildByName("comfirm_label")
    -- self.comfirm_label:setString(TI18N("确定"))
    local scroll_size = scroll_container:getContentSize()
    local size = cc.size(scroll_size.width - 4, scroll_size.height - 13)
    local setting = {
        item_class = EndlessFriendHelpItem2,
        start_x = 0,
        space_x = 0,
        start_y = 0,
        space_y = 10,
        item_width = 600,
        item_height = 124,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewLayout.new(scroll_container, cc.p(4, 7), nil, nil, size, setting)
    local my_container = self.root_wnd:getChildByName("my_container")
    self.item_container = my_container:getChildByName("item_container")
    self.item_container:setVisible(false)
    self.career_icon = self.item_container:getChildByName("career_icon")
    self.role_name = self.item_container:getChildByName("role_name")
    self.career_name = self.item_container:getChildByName("career_name")
    self.role_power = self.item_container:getChildByName("role_power")
    self.has_label = self.item_container:getChildByName("has_label")
    self.has_label:setString(TI18N("已派遣支援"))
    local my_desc_title = my_container:getChildByName("my_desc_title")
    my_desc_title:setString(TI18N("当前已选"))
    local Image_11 = my_container:getChildByName("Image_11")
    setLabelAutoScale(my_desc_title,Image_11)

    self.no_label = my_container:getChildByName("no_label")
    self.no_label:setString(TI18N("暂无派遣支援宝可梦,快快选择宝可梦帮助好友吧"))

    self.no_label:setVisible(false)
    self.hero_icon = HeroExhibitionItem.new(0.8)
    self.hero_icon:setPosition(65, 64)
    self.hero_icon:addCallBack(handler(self, self.onClickHeroItem))
    self.item_container:addChild(self.hero_icon)

    self:registerEvent()
end

function EndlessMeHelpPanel:onClickHeroItem( )
    if self.send_role_data then 
        local hero_vo = HeroController:getInstance():getModel():getHeroById(self.send_role_data.id)
        HeroController:getInstance():openHeroTipsPanel(true, hero_vo)
    end
end

function EndlessMeHelpPanel:registerEvent()
    -- if self.comfirm_button then
    --     self.comfirm_button:addTouchEventListener(function(sender,event_type)
    --         if event_type == ccui.TouchEventType.ended then
    --             if self.select_vo then
    --                 if self.select_vo.info_data and self.select_vo.info_data.partner_id then
    --                     controller:send23908(self.select_vo.info_data.partner_id)
    --                     if self.select_item then
    --                         self.select_item:updateBtnStatus(false)
    --                         self.select_item = nil
    --                         self.select_vo = nil
    --                     end
    --                 end
    --             end
    --         end
    --     end)
    -- end
    if not self.update_send_partner_event then
        self.update_send_partner_event = GlobalEvent:getInstance():Bind(Endless_trailEvent.UPDATA_SENDPARTNER_DATA,function(data)
            self:updateListData(data)
        end)
    end
    if not self.update_send_partner_sucess_event then
        self.update_send_partner_sucess_event = GlobalEvent:getInstance():Bind(Endless_trailEvent.UPDATA_SENDPARTNER_SUCESS_DATA,function(data)
            if data.code == 1 then
                if self.select_item then
                    self.select_item:updateBtnStatus(false)
                    self.select_item = nil
                    self.select_vo = nil
                end
            end
        end)
    end
    
end


function EndlessMeHelpPanel:updateListData(data)
    if data then
        self.send_data = data
        if self.send_data.list and next(self.send_data.list or {}) == nil then
            self.item_container:setVisible(false)
            self.no_label:setVisible(true)
        else
            if self.send_data.list[1] then
                self.item_container:setVisible(true)
                self.no_label:setVisible(false)
                self.send_role_data = self.send_data.list[1]

                if self.send_role_data then
                    self.hero_icon:setData(self.send_role_data)
                    self.role_power:setString(self.send_role_data.power)
                    local partner_config = Config.PartnerData.data_partner_base[self.send_role_data.bid]
                    if partner_config then
                        local res = PathTool.getCareerIcon(partner_config.type)
                        loadSpriteTexture(self.career_icon, res, LOADTEXT_TYPE_PLIST)
                        local str = PartnerConst.Hero_Type[partner_config.type] or ""
                        self.career_name:setString("[" .. str .. "]")
                        self.role_name:setString(partner_config.name)
                    end
                end
            end
        end
        local index = 1
        local list = {}

        local model = HeroController:getInstance():getModel()
        local data = model:getAllHeroArray()
        local dic_resonate_five_hero_vo =  model:getDicResonateFiveHeroVo() or {}
        local cystal_pre_lev_limit = model:getCystalPreLevLimit()

        data:UpperSortByParams("power", "quality", "star", "lev", "sort_order")
        for i = 1, data:GetSize() do
            local info = data:Get(i - 1)
            if self.send_role_data and self.send_role_data.id and self.send_role_data.id == info.id then
            else
                if info.isResonateCrystalHero and info:isResonateCrystalHero() then
                    --原力水晶上的宝可梦有限制
                    if dic_resonate_five_hero_vo[info.id] then
                        list[index] = {info_data = info, type = Endless_trailEvent.helptype.me}
                        index = index + 1  
                    end 
                else
                    list[index] = {info_data = info, type = Endless_trailEvent.helptype.me}
                    index = index + 1    
                end
            end
        end
        local function callback(item, vo, index)
            if vo and next(vo) ~= nil then
                self:clickFun(item,vo,index)
            end
        end
        self.scroll_view:setData(list, callback)
    end
end

function EndlessMeHelpPanel:setNodeVisible(status)
	self:setVisible(status)
end 

function EndlessMeHelpPanel:addToParent()
    controller:send23905()
end

function EndlessMeHelpPanel:clickFun(item,vo,index)
    if self.select_item and self.select_item.index == index then
        self.select_item:updateBtnStatus(false)
        self.select_item = nil
        self.select_vo = nil
        return
    end

    if vo and vo.info_data and vo.info_data.checkResonateHero and vo.info_data:checkResonateHero() then
        return
    end

    if vo and vo.info_data and vo.info_data.isResonateCrystalHero and vo.info_data:isResonateCrystalHero() then

        local cystal_pre_lev_limit = 340
        local config = Config.ResonateData.data_const.cystal_pre_lev_limit
        if config then
            cystal_pre_lev_limit = config.val
        end

        --策划要求如果是共鸣宝可梦 但是等级超过 340 又能上阵的了
        if vo.info_data.lev < cystal_pre_lev_limit then
             message(TI18N("该宝可梦在原力水晶槽位中已上阵"))
            return    
        end
    end

    if self.select_item then
        self.select_item:updateBtnStatus(false)
    end
    self.select_item = item
    self.select_vo = vo
    self.select_item:updateBtnStatus(true)
    if self.select_vo.info_data and self.select_vo.info_data.partner_id then
        controller:send23908(self.select_vo.info_data.partner_id)
    end
end

function EndlessMeHelpPanel:DeleteMe()
    if self.update_send_partner_event then
        GlobalEvent:getInstance():UnBind(self.update_send_partner_event)
        self.update_send_partner_event = nil
    end
    if self.update_send_partner_sucess_event then
        GlobalEvent:getInstance():UnBind(self.update_send_partner_sucess_event)
        self.update_send_partner_event = nil
    end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end


