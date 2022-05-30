--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年7月2日
-- @description    : 
        -- 萌宠零花钱
---------------------------------
HomePetInteractionTipsPanel = HomePetInteractionTipsPanel or BaseClass(BaseView)

local controller = HomepetController:getInstance()
local model = controller:getModel()

local string_format = string.format

function HomePetInteractionTipsPanel:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        -- {path = PathTool.getPlistImgForDownLoad("homepet_travellingbag", "homepet_travellingbag"), type = ResourcesType.plist}
    }
    self.layout_name = "homepet/home_pet_interaction_tips_panel"
end

function HomePetInteractionTipsPanel:open_callback(  )
      self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 


    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("提 示"))

    self.close_btn = main_panel:getChildByName("close_btn")

    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("取 消"))
    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("确 定"))
    
    self.tips_name = createRichLabel(26, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5,0.5), cc.p(339, 239), 6, nil, 900)
    self.main_container:addChild(self.tips_name)
    self.tips_cost = createRichLabel(26, cc.c4b(0x95,0x53,0x22,0xff), cc.p(0.5,0.5), cc.p(339, 194), 6, nil, 900)
    self.main_container:addChild(self.tips_cost)
end

function HomePetInteractionTipsPanel:register_event(  )
    registerButtonEventListener(self.close_btn, function() controller:openHomePetInteractionTipsPanel(false) end ,true, 2)

    registerButtonEventListener(self.left_btn, function() controller:openHomePetInteractionTipsPanel(false) end ,true, 1)
    registerButtonEventListener(self.right_btn, function() self:onRightBtn()  end ,true, 1)


    if self.homepet_vo then
        if self.home_pet_vo_attt_event == nil then
            self.home_pet_vo_attt_event = self.homepet_vo:Bind(HomepetEvent.HOME_PET_VO_ATTR_EVENT, function(key, value)
                if key == "vigor" then
                    self:updateVigor()
                end
            end)
        end
    end
end

--确定
function HomePetInteractionTipsPanel:onRightBtn(sender)
    controller:sender26104()
end

function HomePetInteractionTipsPanel:openRootWnd(setting)
    self.homepet_vo = model:getHomePetVo()
    if not self.homepet_vo then return end
    local setting = setting or {}
    local id = setting.id or 1

    local config = Config.HomePetData.data_interaction_info[id]
    if not config then return end
    if config.type == 1 then return end
    local str1 = string_format( TI18N("准备给<div fontcolor=#d95014>%s</div>准备点零花钱吗？"), self.homepet_vo:getPetName())
    self.tips_name:setString(str1)

    if next(config.expend) ~= nil then
        local val = config.expend[1]
        local item_config  = Config.ItemData.data_get_data(val[1])
        local msg = string.format(TI18N("零花钱：<img src=%s scale=0.3 visible=true /> %s (随机)"), PathTool.getItemRes(item_config.icon), val[2])
        self.tips_cost:setString(msg)
    end
end



function HomePetInteractionTipsPanel:close_callback()
    controller:openHomePetInteractionTipsPanel(false)
end