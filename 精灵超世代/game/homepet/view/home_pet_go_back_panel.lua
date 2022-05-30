--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年7月1日
-- @description    : 
        -- 萌宠出行提示界面 和回来提示界面
---------------------------------
HomePetGoBackPanel = HomePetGoBackPanel or BaseClass(BaseView)

local controller = HomepetController:getInstance()
local model = controller:getModel()

function HomePetGoBackPanel:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        -- {path = PathTool.getPlistImgForDownLoad("homepet_travellingbag", "homepet_travellingbag"), type = ResourcesType.plist}
    }
    self.layout_name = "homepet/home_pet_go_back_panel"
    self.homepet_vo = model:getHomePetVo()
end

function HomePetGoBackPanel:open_callback(  )
      self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 

    self.title_img = self.main_container:getChildByName("title_img")

    self.pet_name = self.main_container:getChildByName("pet_name")
    self.pet_desc = self.main_container:getChildByName("pet_desc")

    self.txt_cn_common_notice_1 = self.main_container:getChildByName("txt_cn_common_notice_1")
end

function HomePetGoBackPanel:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    -- registerButtonEventListener(self.close_btn, function() self:onClosedBtn() end ,true, 2)
end

--确定
function HomePetGoBackPanel:onClosedBtn()
    controller:openHomePetGoBackPanel(false)
end

--setting.title_res --标题的图片路径 (出行.回来的)
--setting.title_name --标题名字
function HomePetGoBackPanel:openRootWnd(setting)
    if not self.homepet_vo then return end
    local setting = setting or {}
    self.event_data = setting.event_data
    if not self.event_data then return end
    self.config = Config.HomePetData.data_event_info[self.event_data.evt_sid]
    if not self.config then return end
    local title_res = nil
    if self.config.s_id == 1 then --出行
        title_res = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_go_out_bg", false)
        -- self.pet_desc:setString(TI18N("已经出门啦"))
        -- self.pet_name:setPosition(156,272)
        -- self.pet_desc:setPosition(156,243)
    elseif self.config.s_id == 2 then -- 回来
        title_res = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_go_back_bg", false)
        -- self.pet_desc:setString(TI18N("地图旅行归来啦"))
        -- self.pet_name:setPosition(177,321)
        -- self.pet_desc:setPosition(177,290)
        self.txt_cn_common_notice_1:setPositionY(-25)
    end

    if title_res and self.record_title_img_res == nil or self.record_title_img_res ~= title_res then
        self.record_title_img_res = title_res
        self.item_load_title_img_res = loadSpriteTextureFromCDN(self.title_img, title_res, ResourcesType.single, self.item_load_title_img_res) 
    end 

    -- local name = self.homepet_vo:getPetName()
    -- self.pet_name:setString(name)
end


function HomePetGoBackPanel:close_callback()
    if self.item_load_title_img_res then
        self.item_load_title_img_res:DeleteMe()
        item_load_title_img_res = nil
    end
    if self.event_data and self.event_data.evt_id then
        if self.config and self.config.s_id == 1 then --出行
            controller:sender26106(self.event_data.evt_id)
            controller:setWaitNextEvent(false)
        else
            HomepetController:getInstance():openHomePetRewardPanel(true, {event_data = self.event_data})
        end
    end
    self.event_data = nil
    -- GlobalEvent:getInstance():Fire(HomepetEvent.HOME_PET_CHECK_TRIGGER_EVENT)

    controller:openHomePetGoBackPanel(false)
end