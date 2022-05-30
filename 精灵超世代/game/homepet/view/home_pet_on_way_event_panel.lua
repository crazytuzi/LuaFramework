--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年7月2日
-- @description    : 
        -- 萌宠事件界面 照片 和 日记提示的
---------------------------------
HomePetOnWayEventPanel = HomePetOnWayEventPanel or BaseClass(BaseView)

local controller = HomepetController:getInstance()

function HomePetOnWayEventPanel:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        -- {path = PathTool.getPlistImgForDownLoad("homepet_travellingbag", "homepet_travellingbag"), type = ResourcesType.plist}
    }
    self.layout_name = "homepet/home_pet_on_way_event_panel"
end

function HomePetOnWayEventPanel:open_callback(  )
      self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 

    self.title_img = self.main_container:getChildByName("title_img")
    self.name_img = self.main_container:getChildByName("name_img")

    -- self.event_content = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,1), cc.p(336,306), 8, nil, 247)
    -- self.main_container:addChild(self.event_content)

    -- self.event_btn = self.main_container:getChildByName("event_btn")
end

function HomePetOnWayEventPanel:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    -- registerButtonEventListener(self.close_btn, function() self:onClosedBtn() end ,true, 2)
    -- registerButtonEventListener(self.event_btn, function() self:onEventBtn() end ,true, 1)
end

--确定
function HomePetOnWayEventPanel:onClosedBtn()
    if self.event_data then
        local setting = {}
        setting.evt_id = self.event_data.evt_id
        if self.event_data.award and next(self.event_data.award) ~= nil then 
            setting.item_id = self.event_data.award[1].id
        end
        HomepetController:getInstance():openHomePetEventInfoPanel(true, setting)
    end
    controller:openHomePetOnWayEventPanel(false)
end

--打开对应事件内容
function HomePetOnWayEventPanel:onEventBtn()

end

--setting.event_data 事件数据 参考 协议 26105 单个事件结构
function HomePetOnWayEventPanel:openRootWnd(setting)
    local setting = setting or {}
    self.event_data = setting.event_data or {}
    if not self.event_data then return end

    local title_res = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_way_bg", false)
    if self.record_title_img_res == nil or self.record_title_img_res ~= title_res then
        self.record_title_img_res = title_res
        self.item_load_title_img_res = loadSpriteTextureFromCDN(self.title_img, title_res, ResourcesType.single, self.item_load_title_img_res) 
    end
    -- local str = TI18N("你的宝宝在旅途中给你寄来了<div fontcolor=#249003>%s</div>，真羡慕他可以坚持出去旅行！")

    self.config = Config.HomePetData.data_event_info[self.event_data.evt_sid]
    if not self.config then return end
    if self.config.type == HomepetConst.event_type.ePhoto then
        -- self.event_content:setString(string.format(str, TI18N("明信片")))
        local title_res = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_way_photo", false)
        if self.record_name_img_res == nil or self.record_name_img_res ~= title_res then
            self.record_name_img_res = title_res
            self.item_load_name_img_res = loadSpriteTextureFromCDN(self.name_img, title_res, ResourcesType.single, self.item_load_name_img_res) 
        end
    else
        -- self.event_content:setString(string.format(str, TI18N("信件")))
        local title_res = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_way_letter", false)
        if self.record_name_img_res == nil or self.record_name_img_res ~= title_res then
            self.record_name_img_res = title_res
            self.item_load_name_img_res = loadSpriteTextureFromCDN(self.name_img, title_res, ResourcesType.single, self.item_load_name_img_res) 
        end
    end
end


function HomePetOnWayEventPanel:close_callback()

    if self.item_load_title_img_res then
        self.item_load_title_img_res:DeleteMe()
        item_load_title_img_res = nil
    end
    if self.item_load_name_img_res then
        self.item_load_name_img_res:DeleteMe()
        item_load_name_img_res = nil
    end

    controller:openHomePetOnWayEventPanel(false)
end