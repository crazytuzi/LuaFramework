-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      荣誉墙 icon tips
-- <br/> 2019年6月3日
-- --------------------------------------------------------------------
HonorIconTips = HonorIconTips or BaseClass(BaseView)

local controller = TipsController:getInstance()

function HonorIconTips:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "tips/honor_icon_tips"
    self.win_type = WinType.Mini   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.item_list = {}
end

function HonorIconTips:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.bg = self.main_panel:getChildByName("bg")

    self.quality_bg = self.main_panel:getChildByName("quality_bg")
    self.item_node = self.main_panel:getChildByName("item_node")
    self.honor_item = RoleHonorItem.new(0.6)
    self.item_node:addChild(self.honor_item)

    self.honor_name = self.main_panel:getChildByName("honor_name")
    self.have_time = self.main_panel:getChildByName("have_time")

    self.label_desc1 = createRichLabel(24, cc.c4b(0xe0,0xbf,0x90,0xff), cc.p(0,1), cc.p(16,185), nil, nil, 388)
    self.main_panel:addChild(self.label_desc1)

    self.have_name = createRichLabel(24, cc.c4b(0xe0,0xbf,0x90,0xff), cc.p(0,1), cc.p(16,118), nil, nil, 388)
    self.main_panel:addChild(self.have_name)

    self.Image_3 = self.main_panel:getChildByName("Image_3")
    self.label_desc2 = createRichLabel(20, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0,1), cc.p(16,68), nil, nil, 388)
    self.main_panel:addChild(self.label_desc2)


    self.share_btn = self.main_panel:getChildByName("share_btn")

    -- self.close_btn = self.main_panel:getChildByName("close_btn")
end

function HonorIconTips:register_event()
    registerButtonEventListener(self.background, function() self:onCloseBtn()  end ,false, 2)
    -- registerButtonEventListener(self.close_btn, function() self:onCloseBtn()  end ,true, 2)
    registerButtonEventListener(self.share_btn, function(param, sender) self:onShareBtn(sender)  end ,true, 1)

end

function HonorIconTips:onCloseBtn(  )
    controller:openHonorIconTips(false)
end
--分享
function HonorIconTips:onShareBtn(sender)
    if not self.config then return end
    local setting = {}
    setting.world_pos = sender:convertToWorldSpace(cc.p(0.5, 0.5))
    setting.callback = function(share_type) self:shareCallback(share_type) end
    TaskController:getInstance():openTaskSharePanel(true, setting)
end

function HonorIconTips:shareCallback(share_type)
    if not self.config then return end
    if share_type == VedioConst.Share_Btn_Type.eWorldBtn then --分享到世界
        RoleController:getInstance():send25815(self.config.id, ChatConst.Channel.World)
    elseif share_type == VedioConst.Share_Btn_Type.eGuildBtn then --分享公会
        RoleController:getInstance():send25815(self.config.id, ChatConst.Channel.Gang)
    elseif share_type == VedioConst.Share_Btn_Type.eCrossBtn then --跨服分享
        RoleController:getInstance():send25815(self.config.id, ChatConst.Channel.Cross)
    end
end

--@setting
--setting.config = Config.RoomFeatData.data_honor_icon_info配置文件
--setting.id 徽章id 参考表:Config.RoomFeatData.data_honor_icon_info
--setting.show_type 参考 RoleConst.role_type.eOther
--setting.have_time --拥有时间 (如果 nil 表示不解锁)
--setting.have_name --拥有者名字 (自己的不用传)
function HonorIconTips:openRootWnd(setting)
    local setting = setting or {}
    self.config = setting.config
    if self.config == nil then
        local id = setting.id or 0
        self.config = Config.RoomFeatData.data_honor_icon_info[id]
    end
    if not self.config then return end
    
    self.show_type = setting.show_type or RoleConst.role_type.eMySelf

    local have_time = setting.have_time 
    if have_time then
        self.have_time:setString(TimeTool.getYMD(have_time))
    else
        self.have_time:setString("")
    end

    self.honor_item:setData({config = self.config})

    self.honor_name:setString(self.config.name)
    self.honor_name:setColor(BackPackConst.getBlackQualityColorC4B(self.config.quality))

    local background_res = PathTool.getResFrame("tips", "tips_"..self.config.quality)
    if self.record_background_res == nil or self.record_background_res ~= background_res then
        self.record_background_res = background_res
        self.quality_bg:loadTexture(background_res,LOADTEXT_TYPE_PLIST)
    end

    self.label_desc1:setString(self.config.desc1)

    if self.show_type == RoleConst.role_type.eMySelf then
        local name = string.format(TI18N("荣誉点数: <div fontcolor=#65df74>%s</div>"), self.config.point)
        self.have_name:setString(name)
        if have_time == nil then
            self.honor_item:setShowLock(true)
            self.share_btn:setVisible(false)
        else
            self.share_btn:setVisible(true)
            self.honor_item:setShowEffect(true)
        end
    else
        local have_name = setting.have_name or ""
        local name = string.format(TI18N("持有者: <div fontcolor=#65df74>%s</div>"), have_name)
        self.have_name:setString(name)
        self.share_btn:setVisible(false)
        self.honor_item:setShowEffect(true)
    end

    if self.config.desc2 == "" then
        --说明下面要隐藏
        self.Image_3:setVisible(false)
        self.bg:setContentSize(cc.size(420,285))
    else
        self.label_desc2:setString(self.config.desc2)
    end
end




function HonorIconTips:close_callback()

    controller:openHonorIconTips(false)
end