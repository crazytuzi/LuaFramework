-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      微信礼包
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
WeiXinGiftPanel = class("WeiXinGiftPanel", function()
    return ccui.Widget:create()
end)

function WeiXinGiftPanel:ctor()
	self.ctrl = WelfareController:getInstance()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.update_list = {}
	self:configUI()
end

function WeiXinGiftPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/weixin_gift_panel"))
    self:addChild(self.root_wnd)
    -- self:setCascadeOpacityEnabled(true)
    self:setPosition(-40,-45)
    self:setAnchorPoint(0,0)
    
    self.bg = self.root_wnd:getChildByName("bg")
    self.title = self.root_wnd:getChildByName("title")

    self:loadResources()
    
end

function WeiXinGiftPanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_weixin"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","txt_cn_welfare_weixin_title"), type = ResourcesType.single },
    } 
    self.resources_load = ResourcesLoad.New(true) 
    self.resources_load:addAllList(self.res_list, function()
        if self.loadResListCompleted then
            self:loadResListCompleted()
        end
    end)
end

function WeiXinGiftPanel:loadResListCompleted()
    loadSpriteTexture(self.bg, PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_weixin"), LOADTEXT_TYPE)
    loadSpriteTexture(self.title, PathTool.getPlistImgForDownLoad("bigbg/welfare","txt_cn_welfare_weixin_title"), LOADTEXT_TYPE)
    self:createList()
end

function WeiXinGiftPanel:createList()
    local config = Config.HolidayClientData.data_info[WelfareIcon.weixin_gift]
    if config and config.items then
        -- 这里只有3个.所以只显示3个
        local pos_list = {{140, 564}, {227,372}, {140, 186}}
        for i,v in ipairs(config.items) do
            local bid = v[1]
            local num = v[2]
            if bid and num then
                local item_conifg = Config.ItemData.data_get_data(bid)
                if item_conifg and pos_list[i] then
                    local item_img = createSprite(PathTool.getItemRes(item_conifg.icon), 0, 0, self.root_wnd, cc.p(0.5,0.5), LOADTEXT_TYPE)
                    item_img:setPosition(pos_list[i][1], pos_list[i][2])
                    local item_label = createLabel(24,1,cc.c4b(0x16,0x32,0x84,0xff),pos_list[i][1], pos_list[i][2] - 70, item_conifg.name, self.root_wnd, nil, cc.p(0.5, 0.5))
                end
            end 
        end
    end
end

function WeiXinGiftPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)    
end

function WeiXinGiftPanel:DeleteMe()
    if self.resources_load then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
end