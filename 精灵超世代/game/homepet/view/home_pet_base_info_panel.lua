--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年7月2日
-- @description    : 
        -- 萌宠基本信息
---------------------------------
HomePetBaseInfoPanel = HomePetBaseInfoPanel or BaseClass(BaseView)

local controller = HomepetController:getInstance()
local model = controller:getModel()

local string_format = string.format

function HomePetBaseInfoPanel:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("homepet_travellingbag", "homepet_travellingbag"), type = ResourcesType.plist}
    }
    self.layout_name = "homepet/home_pet_base_info_panel"

    self.item_list= {}

    self.homepet_vo = model:getHomePetVo()
end

function HomePetBaseInfoPanel:open_callback(  )
      self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 

    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("宠物详细"))

    self.close_btn = main_panel:getChildByName("close_btn")
    self.look_btn = main_panel:getChildByName("look_btn")


    self.change_btn = self.main_container:getChildByName("change_btn")
    
    self.main_container:getChildByName("energy_key"):setString(TI18N("精力值:"))

    self.pet_name = self.main_container:getChildByName("pet_name")
    self.energy_value = self.main_container:getChildByName("energy_value")

    self.item_scrollview = self.main_container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    self.item_scrollview:setSwallowTouches(false)
    self.item_scrollview_size = self.item_scrollview:getContentSize()


      --tips面板
    self.tips_panel = self.main_container:getChildByName("tips_panel")
    self.tips_panel:setZOrder(3)
    self.tips_panel_bg = self.tips_panel:getChildByName("bg")
    self.tips_panel_bg_size = self.tips_panel_bg:getContentSize()
    self.tips_time = self.tips_panel:getChildByName("time")
    self:onShowTipsPanel(false)

    --宠物形象
    self.dog_img = createSprite(nil,152,338, self.main_container,cc.p(0.5,0.5))
    if self.dog_img and self.item_load_dog == nil then
        local get_res = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_dog", false)
        self.item_load_dog = loadSpriteTextureFromCDN(self.dog_img, get_res, ResourcesType.single, self.item_load_dog) 
    end
end

function HomePetBaseInfoPanel:register_event(  )
    registerButtonEventListener(self.background, function() 
        if self.is_tips_show then
            self:onShowTipsPanel(false)  
        else
            controller:openHomePetBaseInfoPanel(false)
        end
    end,false, 2)
    registerButtonEventListener(self.close_btn, function() controller:openHomePetBaseInfoPanel(false) end ,true, 2)
    registerButtonEventListener(self.main_container, function() self:onShowTipsPanel(false)  end ,false)

    registerButtonEventListener(self.look_btn, function() self:onShowTipsPanel(true) end ,true, 1)
    registerButtonEventListener(self.change_btn, function() self:onChangeBtn()  end ,true, 1)


    if self.homepet_vo then
        if self.home_pet_vo_attt_event == nil then
            self.home_pet_vo_attt_event = self.homepet_vo:Bind(HomepetEvent.HOME_PET_VO_ATTR_EVENT, function(key, value)
                if key == "vigor" then
                    self:updateVigor()
                elseif key == "vigor_time" then
                    self:updateVigorTime()
                elseif key == "state" then
                    self:updateVigorTime()
                end
            end)
        end
    end
end

--改名
function HomePetBaseInfoPanel:onChangeBtn(sender)
    if isQingmingShield and isQingmingShield() then
        return
    end
    if not self.homepet_vo then return end
    local function confirm_callback(str)
        if str == nil or str == "" then
            message(TI18N("名字不合法"))
            return
        end
        -- if not self.role_vo then return end
        local text = string.gsub(str, "\n", "")
        controller:sender26102(text)
        --self.set_name_alert关闭在名字改变成功后
    end

    -- local msg
    -- if self.homepet_vo.rename_count == 0 then
    --     msg = TI18N("首次更改免费哦~")
    -- else
    local rename_cost = Config.HomePetData.data_const.rename_cost
    local item_id = Config.ItemData.data_assets_label2id.gold
    local item_config  = Config.ItemData.data_get_data(item_id)
    local msg = string.format(TI18N("<div fontcolor=#a95f0f>改名需消耗%s <img src=%s scale=0.3 visible=true /></div>"), rename_cost.val, PathTool.getItemRes(item_config.icon))
    -- end
    self.set_name_alert = CommonAlert.showInputApply(msg, TI18N("请输入名字(限制6字)"), TI18N("确 定"), 
        confirm_callback, TI18N("取 消"), nil, true, nil, 20, CommonAlert.type.rich, FALSE,
        cc.size(270,50), 12, {off_y=-15})
    self.set_name_alert.alert_txt:setPositionY(20)
    self.set_name_alert.line:setVisible(false)
    local label = createLabel(26,Config.ColorData.data_color4[175],nil,75,75,TI18N("名字："),self.set_name_alert.alert_panel)
end
function HomePetBaseInfoPanel:closeSetNameAlert( )
    self.pet_name:setString(self.homepet_vo:getPetName())
    if self.set_name_alert then
        self.set_name_alert:close()
        self.set_name_alert = nil
    end
end


function HomePetBaseInfoPanel:openRootWnd(setting)
    if not self.homepet_vo then return end
    local setting = setting or {}
    self:updateList()

    self.pet_name:setString(self.homepet_vo:getPetName())

   
    self:updateVigor()

    -- self:showPetSpine(true)
end

function HomePetBaseInfoPanel:updateVigor()
    local config = Config.HomePetData.data_const.power_upper_limit
    local max_vigor = 100
    if config then
        max_vigor = config.val
    end
    local vigor = self.homepet_vo:getPetVigor()
    self.energy_value:setString(string_format("%s/%s", vigor, max_vigor))
    self:showProgress(true, vigor*100/max_vigor)
end


function HomePetBaseInfoPanel:updateList()
    self.show_list = {}
    self.show_list[1] = {text = "性格："..Config.HomePetData.data_const.pet_character.desc}
    self.show_list[2] = {text = "爱好："..Config.HomePetData.data_const.pet_interest.desc}
    self.show_list[3] = {text = "故事：\n　　"..Config.HomePetData.data_const.pet_story.desc}


    for i,v in ipairs(self.item_list) do
        v:setVisible(false)
    end
    local lenght = #self.show_list
    local x = 2
    local y = 10
    local offset_y = 20 -- y方向的间隔

    for i=1,lenght do
        local show_data = self.show_list[i]
        if self.item_list[i] == nil then
            self.item_list[i] = createRichLabel(24, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,1), cc.p(-10000,0), 6, nil, 320)
            self.item_scrollview:addChild(self.item_list[i])
        else
            self.item_list[i]:setVisible(true)
        end
        self.item_list[i]:setString(show_data.text)
        local size = self.item_list[i]:getContentSize()
        show_data.y = y
        -- self.item_list[i]:setPosition(x, y)
        y = y + size.height + offset_y
    end
    local total_height = y - offset_y


    local max_height = math.max(self.item_scrollview_size.height, total_height)
    self.item_scrollview:setInnerContainerSize(cc.size(self.item_scrollview_size.width,max_height))
    
    for i=1,lenght do
        local show_data = self.show_list[i]
        y = show_data.y or 0
        self.item_list[i]:setPosition(x, max_height - y)
    end

    if max_height == self.item_scrollview_size.height then
        self.item_scrollview:setTouchEnabled(false)
    else
        self.item_scrollview:setTouchEnabled(true)
    end
end


--进度条
function HomePetBaseInfoPanel:showProgress(status, percent)
    if status then
        if self.comp_bar == nil then
            local size = cc.size(240, 19)
            local res = PathTool.getResFrame("common","common_90005")
            local res1 = PathTool.getResFrame("common","common_90006")
            local bg,comp_bar = createLoadingBar(res, res1, size, self.main_container, cc.p(0.5,0.5), 155, 48, true, true)
            self.comp_bar_bg = bg
            self.comp_bar = comp_bar
        else
            self.comp_bar_bg:setVisible(true)
        end

        self.comp_bar:setPercent(percent) 
    else
        if self.comp_bar_bg then
            self.comp_bar_bg:setVisible(false)
        end
    end
end

function HomePetBaseInfoPanel:onShowTipsPanel(status)
    if not self.tips_panel then return end
    if status then 
        self.is_tips_show = true
        self.tips_panel:setPositionX(308)
        if self.tips_label == nil then
            local y = 220
            self.tips_label = createRichLabel(20, cc.c4b(0xe0,0xbf,0x98,0xff), cc.p(0, 1), cc.p(25, y), nil, nil, 470)
            self.tips_panel:addChild(self.tips_label)
            local config = Config.HomePetData.data_const.pet_tips
            if config then
                self.tips_label:setString(config.desc)
            else
                self.tips_label:setString(TI18N("宠物tips说明"))
            end

            local height1 = self.tips_panel_bg_size.height - y
            local size = self.tips_label:getContentSize()
            local  height = height1 + size.height + 40
            self.tips_panel_bg:setContentSize(cc.size(self.tips_panel_bg_size.width, height))

            self.tips_time:setPositionY(y - size.height - 20)
        end
        self:updateVigorTime()
       
    else
        self.is_tips_show = false
        self.tips_panel:setPositionX(-10000)
    end
end


function HomePetBaseInfoPanel:updateVigorTime()
    if self.is_tips_show and self.homepet_vo and self.tips_time then
        local config = Config.HomePetData.data_const.power_upper_limit
        local vigor = self.homepet_vo:getPetVigor()
        if config and vigor >= config.val then
            doStopAllActions(self.tips_time)
            self.tips_time:setString("精力值已满")
            return
        end

        local state = self.homepet_vo:getPetState()
        if state == HomepetConst.state_type.eNotActive or 
            state == HomepetConst.state_type.eOnWay then --未激活  和 在旅行中
            doStopAllActions(self.tips_time)
            self.tips_time:setString("萌宠出行时，精力值不自动恢复。")
            return
        end

        local setting = {}
        setting.callback = function(time) self:setTimeFormatString(time) end
        local time = self.homepet_vo:getPetVigorTime()
        commonCountDownTime(self.tips_time, time, setting)
    end
end


function HomePetBaseInfoPanel:setTimeFormatString(time)
    if not self.tips_time then return end
    if time < 0 then
         self.tips_time:setString(TI18N("精力值恢复: 00:00"))
    else
        local timeStr = TimeTool.GetTimeForFunction(time)
        self.tips_time:setString(TI18N("精力值恢复: "..timeStr))
    end
    
end

function HomePetBaseInfoPanel:showPetSpine(status)
    if status then
        if self.pet_spine == nil then
            -- self.pet_spine = createEffectSpine( "H60001", cc.p(154, 242), cc.p(0.5, 0), true, PlayerAction.idle)
            -- self.pet_spine:setScale(0.6) -- test
            self.main_container:addChild(self.pet_spine, 1)
        end
    else
        if self.pet_spine then
            -- self.pet_spine:clearTracks()
            -- self.pet_spine:removeFromParent()
            self.pet_spine = nil
        end
    end    
end

function HomePetBaseInfoPanel:close_callback()

    if self.item_load_dog then
        self.item_load_dog:DeleteMe()
        item_load_dog = nil
    end 

    if self.homepet_vo then
        if self.home_pet_vo_attt_event ~= nil then 
            self.homepet_vo:UnBind(self.home_pet_vo_attt_event)
            self.home_pet_vo_attt_event = nil
        end
        self.homepet_vo = nil
    end

    -- self:showPetSpine(false)
    doStopAllActions(self.tips_time)
    controller:openHomePetBaseInfoPanel(false)
end