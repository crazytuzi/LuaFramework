--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年7月1日
-- @description    : 
        -- 萌宠奖励
---------------------------------
HomePetRewardPanel = HomePetRewardPanel or BaseClass(BaseView)

local controller = HomepetController:getInstance()

function HomePetRewardPanel:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        -- {path = PathTool.getPlistImgForDownLoad("homepet_travellingbag", "homepet_travellingbag"), type = ResourcesType.plist}
        -- {path = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_reward_item_bg"), type = ResourcesType.single},
        -- {path = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_reward_closed"), type = ResourcesType.single},
        -- {path = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_reward_open"), type = ResourcesType.single},
        -- {path = PathTool.getPlistImgForDownLoad("bigbg/homepet", "txt_cn_home_pet_get_world"), type = ResourcesType.single}
    }
    self.layout_name = "homepet/home_pet_reward_panel"

    self.cache_list = {}
end

function HomePetRewardPanel:open_callback(  )
      self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container_size = self.main_container:getContentSize()
    self.title_img = self.main_container:getChildByName("title_img")
    self.title_tips = self.main_container:getChildByName("title_tips")
    self.title_tips:setString(TI18N("收到了礼物，点击领取"))
    self.txt_cn_common_notice_1 = self.main_container:getChildByName("txt_cn_common_notice_1")
    self.txt_cn_common_notice_1:setVisible(false)
    self.click_btn = self.main_container:getChildByName("click_btn")
end

function HomePetRewardPanel:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    registerButtonEventListener(self.click_btn, function() self:onClickBtn() end ,false, 1)
end

--确定
function HomePetRewardPanel:onClosedBtn()
    if not self.is_show then
        return
    end
    controller:openHomePetRewardPanel(false)
end

--点击了
function HomePetRewardPanel:onClickBtn()
    if not self.is_show then
        self:showOpenEffect()
    end
end

--setting.title_res --标题的图片路径 (出行.回来的)
--setting.title_name --标题名字
function HomePetRewardPanel:openRootWnd(setting)
    local setting = setting or {}
     self.event_data = setting.event_data
    if not self.event_data then return end

    local title_res = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_reward_closed", false)
    self:setTitleImg(title_res, true)
end

function HomePetRewardPanel:setTitleImg(title_res, is_action, is_pos)
    if self.record_title_img_res == nil or self.record_title_img_res ~= title_res then
        self.record_title_img_res = title_res
         self.item_load_title_img_res = createResourcesLoad(title_res, ResourcesType.single, function()
            if not tolua.isnull(self.title_img) then
                loadSpriteTexture(self.title_img, title_res, LOADTEXT_TYPE)
                if is_action and not self.is_show then
                    --执行动作
                    self:runImgAction(self.title_img)
                end
                if is_pos then
                    self.title_img:setPositionY(199.62)
                end
            end
        end,self.item_load_title_img_res)
    end 
end

function HomePetRewardPanel:runImgAction(title_img)
    local rotato1 = cc.RotateTo:create(0.2, 30)  
    local rotato2 = cc.RotateTo:create(0.2, -30)
    local rotato3 = cc.RotateTo:create(0.2, 20)
    local rotato4 = cc.RotateTo:create(0.2, -20)
    local rotato5 = cc.RotateTo:create(0.3, 15)
    local rotato6 = cc.RotateTo:create(0.3, -15)
    local rotato7 = cc.RotateTo:create(0.3, 0)

    title_img:runAction(cc.RepeatForever:create(cc.Sequence:create(rotato1, rotato2, rotato3, rotato4, rotato5, rotato6, rotato7)))
end


function HomePetRewardPanel:showOpenEffect()
    local title_res = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_reward_open", false)
    self.title_tips:setVisible(false)
    self.txt_cn_common_notice_1:setVisible(true)
    doStopAllActions(self.title_img)
    self.title_img:setRotation(0)
    self:setTitleImg(title_res, nil, true)

    self.show_list = {}
    if self.event_data and self.event_data.award and next(self.event_data.award) ~= nil then
        self.show_list = self.event_data.award
        table.sort( self.show_list, function(a, b) return a.id < b.id end )
    end
    self.is_show = true
    
    self:playOpenEffect(true)
    -- for i=1,4 do
    --     table.insert(self.show_list, i)
    -- end
    delayRun(self.root_wnd, 0.2, function() 
        self:showItemEffect()
    end)
  
end

function HomePetRewardPanel:playOpenEffect(status)
    if status == false then
        if self.item_effect then
            self.item_effect:clearTracks()
            self.item_effect:removeFromParent()
            self.item_effect = nil
        end
    else
        if self.item_effect == nil then
            self.item_effect = createEffectSpine("E24801", cc.p(333, 228), cc.p(0.5, 0.5), false, PlayerAction.action)
            self.main_container:addChild(self.item_effect, 1)
        end
    end
end

function HomePetRewardPanel:showItemEffect( )
    local start_x = 40
    local start_y = 680

    local width = self.main_container_size.width - start_x * 2
    local height = 320

    local col = 4 --一排最多5咯
    local item_width = width / col
    local item_height = 160

    local lenght = #self.show_list
    if lenght <= 4 then
        start_y = 600
    end
    local math_floor = math.floor
    self.action_effect = {}

    local x = start_x + item_width * 0.5
    for i=1,lenght do
        local data = self.show_list[i]
        delayRun(self.root_wnd, i*0.15, function() 
            local function one_fun()
                if self.action_effect[i] then
                    self.action_effect[i]:runAction(cc.RemoveSelf:create(true)) 
                    self.action_effect[i] = nil
                end
            end

            local cur_row = math_floor((i-1)/col)
            local cur_col = (i-1)%col
            if cur_col == 0 then
                --每一个新的行都要重新算已start 
                if lenght - i < col then --没有满足col 才需要算
                    local new_x = (width - item_width * (lenght - i + 1)) * 0.5
                    x = start_x + new_x + item_width * 0.5
                end
            end

            local _x = x + item_width * cur_col
            local _y = start_y - cur_row * item_height
    
            local effect_id = Config.EffectData.data_effect_info[156]
            local action = PlayerAction.action_3
            self.action_effect[i] = createEffectSpine(effect_id, cc.p(_x, _y), cc.p(0.5, 0.5), false, action, one_fun, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
            self.main_container:addChild(self.action_effect[i], 1)
            
            local function animationEventFunc(event)
                if event.eventData.name == "appear" then
                    local item = ShowItemObj.new(i)
                    item:setData(data)
                    item:setPosition(cc.p(_x, _y))
                    self.main_container:addChild(item)
                    table.insert(self.cache_list, item)
                end
            end
            self.action_effect[i]:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)
        end)
    end
end

function HomePetRewardPanel:close_callback()
    if self.cache_list then
        for i,v in ipairs(self.cache_list) do
            v:DeleteMe()
        end
    end
    self.cache_list = nil

    if self.item_load_title_img_res then
        self.item_load_title_img_res:DeleteMe()
        item_load_title_img_res = nil
    end 
    doStopAllActions(self.root_wnd)
    doStopAllActions(self.title_img)
    if self.action_effect then
        for k,v in pairs(self.action_effect) do
            v:clearTracks()
            v:removeFromParent() 
        end
    end
    self.action_effect = nil

    if self.event_data and self.event_data.evt_id then
        controller:sender26106(self.event_data.evt_id)
        controller:setWaitNextEvent(false)
    end
    self:playOpenEffect(false)
    controller:openHomePetRewardPanel(false)
end


--显示item
ShowItemObj = ShowItemObj or class("ShowItemObj", function()
    return ccui.Widget:create()
end)

ShowItemObj.WIDTH = 119
ShowItemObj.HEIGHT = 119
function ShowItemObj:ctor()
    self.is_play = true
    self.size = cc.size(ShowItemObj.WIDTH , ShowItemObj.HEIGHT)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)
    self:setCascadeOpacityEnabled(true)
    --self.item_name_label = createLabel(24, cc.c4b(0xff,0xe8,0xff,0xff),nil, self.size.width*0.5, -20,"", self,nil, cc.p(0.5, 0.5))
    self:registerEvent()
end

function ShowItemObj:registerEvent()
    self:registerScriptHandler(function(event)
        if "enter" == event then
            if self.is_play == true then
                self:setOpacity(0)
                self:setScale(2)
                local fadeIn = cc.FadeIn:create(0.1)
                local scaleTo = cc.ScaleTo:create(0.1, 1)
                self:runAction(cc.Spawn:create(fadeIn, scaleTo))
            end
        elseif "exit" == event then

        end 
    end)
end
 
function ShowItemObj:setData(data,extend)
   self:showItemUI(data,extend)
end

--道具ui
function ShowItemObj:showItemUI(data, extend)
    if not data then return end
    local item_bid = data.id
    local quality,name = nil, nil, nil
    local item_config = Config.ItemData.data_get_data(item_bid)
    if item_config == nil then return end

    if item_config ~= nil then
        quality = item_config.quality
        name = item_config.name
        if not self.item then
            self.item = BackPackItem.new(true, false)
            -- self.item:setDefaultTip(true)
            self.item:setPosition(0,0)
            self.item:setAnchorPoint(cc.p(0, 0))
            self:addChild(self.item)
        end
        self.item:setBaseData(data.id,data.num)
        -- local res = PathTool.getPlistImgForDownLoad("bigbg/homepet", "home_pet_reward_item_bg")
        -- self.item.background:loadTexture(res, LOADTEXT_TYPE)
    end 
    if quality ~= nil and name ~= nil and self.item then
        -- self.item:setExtendDesc(true, name, BackPackConst.quality_color_id[quality])
        self.item:setExtendDesc(true, name, 275, 2, false, 24)
    end
end

function ShowItemObj:DeleteMe()
    self:stopAllActions()
    if self.item then
        self.item:DeleteMe()
        self.item = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end