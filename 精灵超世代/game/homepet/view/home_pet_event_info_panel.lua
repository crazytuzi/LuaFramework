--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年7月1日
-- @description    : 
        -- 萌宠事件信息界面
---------------------------------
HomePetEventInfoPanel = HomePetEventInfoPanel or BaseClass(BaseView)

local controller = HomepetController:getInstance()
local model = controller:getModel()

function HomePetEventInfoPanel:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("homepet_eventinfo", "homepet_eventinfo"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_proto_line"), type = ResourcesType.single}
    }
    self.layout_name = "homepet/home_pet_event_info_panel"
end

function HomePetEventInfoPanel:open_callback(  )
      self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    
    self:playEnterAnimatianByObj(self.main_container , 2) 
    self.title_img = self.main_container:getChildByName("title_img")

    local res = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_proto_bg", false)
    if self.record_title_img_res == nil or self.record_title_img_res ~= res then
        self.record_title_img_res = res
        self.item_load_title_img_res = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load_title_img_res) 
    end 


    --信息事件内容
    self.line_img_1 = self.main_container:getChildByName("line_img_1")
    self.line_img_2 = self.main_container:getChildByName("line_img_2")
    self.line_img_3 = self.main_container:getChildByName("line_img_3")
    self.title_name = self.main_container:getChildByName("title_name")
    self.content_label =  createRichLabel(26, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,1), cc.p(65,423), 22, nil, 550)
    self.main_container:addChild(self.content_label)
    --相片事件内容
    self.proto_img = self.main_container:getChildByName("proto_img")
    self.proto_border = self.main_container:getChildByName("proto_border")
    self.ssr_bg = self.main_container:getChildByName("ssr_bg")
    self.ssr_img = self.main_container:getChildByName("ssr_img")

    --通用
    self.tips_label = self.main_container:getChildByName("tips_label")
    self.tips_label:setString(TI18N("可在收藏中再次查阅"))
    self.remove_btn = self.main_container:getChildByName("remove_btn")
    self.save_btn = self.main_container:getChildByName("save_btn")
    self.save_btn:setVisible(false)
    self.close_btn = self.main_container:getChildByName("close_btn")

    self.btn_goto = self.main_container:getChildByName("btn_goto")
    self.btn_goto:getChildByName("label"):setString(TI18N("设为空间背景"))
end

function HomePetEventInfoPanel:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    registerButtonEventListener(self.close_btn, function() self:onClosedBtn() end ,true, 2)
    registerButtonEventListener(self.remove_btn, function() self:onRemoveBtn() end ,true, 1)
    registerButtonEventListener(self.btn_goto, function() self:onGotoBtn() end ,true, 1)
end

--确定
function HomePetEventInfoPanel:onClosedBtn()
    controller:openHomePetEventInfoPanel(false)
end

--前往
function HomePetEventInfoPanel:onGotoBtn()
    if not self.item_config then return end
    RoleController:getInstance():openRoleDecorateView(true, 5, {id = self.item_config.id})
end

function HomePetEventInfoPanel:onRemoveBtn()
    if not self.item_config then return end
    if not self.id then return end
    local confirm_handler = function()
        controller:sender26113(self.item_config.type, self.id)
    end
    CommonAlert.show(TI18N("确定要删除吗？"),TI18N("删除"),confirm_handler,TI18N("取消"))
end

--setting.evt_id = 事件id (协议 26105的的唯一事件id) 有值表示需要发送 26106协议
--setting.item_id --明信片或者信件id(必传)
--setting.id --物品的唯一id
function HomePetEventInfoPanel:openRootWnd(setting)
    local setting = setting or {}
    self.evt_id = setting.evt_id
    self.item_id = setting.item_id or 0
    self.id = setting.id --物品的唯一id
    self.item_config = Config.ItemData.data_get_data(self.item_id)
    if not self.item_config then return end

    if self.item_config.type == BackPackConst.item_type.HOME_PET_PHOTO then--萌宠明信片
        self:setProtoEvent()
    else -- BackPackConst.item_type.HOME_PET_LITTER --萌宠日记
        self:setInfoEvent()
        self.btn_goto:setVisible(false)
    end

    if not self.evt_id then
        self.tips_label:setVisible(false)
    else
        self.btn_goto:setVisible(false)
        self.remove_btn:setVisible(false)
    end
end

--设置日记事件
function HomePetEventInfoPanel:setInfoEvent()
    local res = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_proto_line", false)
    for i=1,3 do
        if self["line_img_"..i] then
            loadSpriteTexture(self["line_img_"..i], res, LOADTEXT_TYPE)
        end
    end
    if self.item_config ~= nil then
        self.title_name:setString(self.item_config.use_desc)
        self.content_label:setString(self.item_config.desc )
    end
end

--设置相片事件
function HomePetEventInfoPanel:setProtoEvent()
    self.proto_border:setVisible(true)
    self.ssr_bg:setVisible(true)
    self.ssr_img:setVisible(true)
    self.proto_img:setVisible(true)

    if self.item_config ~= nil then
        local res = PathTool.getPlistImgForDownLoad("homepet_item", self.item_config.icon, true)
        if self.record_proto_img_res == nil or self.record_proto_img_res ~= res then
            self.record_proto_img_res = res
            self.item_load_proto_img_res = loadSpriteTextureFromCDN(self.proto_img, res, ResourcesType.single, self.item_load_proto_img_res) 
        end 

        local res_name = model:getHomepetResNameByQuality(self.item_config.quality)
        local ssr_res = PathTool.getResFrame("homepet_eventinfo","homepet_eventinfo_"..res_name)
        if self.record_ssr_res == nil or self.record_ssr_res ~= ssr_res then
            self.record_ssr_res = ssr_res
            loadSpriteTexture(self.ssr_img, ssr_res, LOADTEXT_TYPE_PLIST)
        end
    end
end


function HomePetEventInfoPanel:close_callback()

    if self.item_load_title_img_res then
        self.item_load_title_img_res:DeleteMe()
        item_load_title_img_res = nil
    end

    if self.item_load_proto_img_res then
        self.item_load_proto_img_res:DeleteMe()
        item_load_proto_img_res = nil
    end

    if self.evt_id then
        controller:sender26106(self.evt_id)
        controller:setWaitNextEvent(false)
    end
    self.evt_id = nil
    -- GlobalEvent:getInstance():Fire(HomepetEvent.HOME_PET_CHECK_TRIGGER_EVENT)

    controller:openHomePetEventInfoPanel(false)
end