--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年8月3日
-- @description    : 
        -- 共鸣精炼  后端 锋林 策划 康阶 
---------------------------------
HeroResonateExtractPanel = HeroResonateExtractPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()

--背包
local backpack_model = BackpackController:getInstance():getModel()
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
local math_ceil = math.ceil

local role_vo = RoleController:getInstance():getRoleVo()

function HeroResonateExtractPanel:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        -- {path = PathTool.getPlistImgForDownLoad("homepet_travellingbag", "homepet_travellingbag"), type = ResourcesType.plist}
    }
    self.layout_name = "hero/hero_resonate_extract_panel"

    --精炼生成的id
    self.extract_item_id = 10301
    local config = Config.ResonateData.data_const.alchemy_goods
    if config then
        self.extract_item_id = config.val
    end
    self.extract_item_config = Config.ItemData.data_get_data(self.extract_item_id)
    
    --花费的
    local config = Config.ResonateData.data_const.single_refine_consume
    if config and next(config.val) ~= nil then
        self.cost_item_id = config.val[1][1]
        self.single_cost_count = config.val[1][2]
    else
        self.cost_item_id = Config.ItemData.data_assets_label2id.hero_exp
        self.single_cost_count = 10000
    end
    self.cost_item_config = Config.ItemData.data_get_data(self.cost_item_id)
end

function HeroResonateExtractPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)  

    local main_panel = self.main_container:getChildByName("main_panel")
    self.main_panel = main_panel
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("魔液炼金"))

    self.close_btn = main_panel:getChildByName("close_btn")
    self.look_btn = self.main_container:getChildByName("look_btn")
    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("获取魔液"))

    self.recovery_btn = self.main_container:getChildByName("recovery_btn")
    self.recovery_btn_label = self.recovery_btn:getChildByName("label")
    self.recovery_btn_label:setString(TI18N("放入"))

    self.spine_node = self.main_container:getChildByName("spine_node")
    local bg = self.main_container:getChildByName("bg")

    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/resonate", "hero_resonate_bg3", false)
    self.item_load_bg = loadSpriteTextureFromCDN(bg, bg_res, ResourcesType.single, self.item_load_bg) 

    self.item_right_node = self.main_container:getChildByName("item_right_node")

    --经验值数据
    self.coin = self.main_container:getChildByName("coin")
    self.count = self.main_container:getChildByName("count")
     

    self.right_item = BackPackItem.new(true,true,nil,1,false)
    self.right_item:setDefaultTip()
    self.item_right_node:addChild(self.right_item)

    local progress_container = self.main_container:getChildByName("progress_container")
    self.progress = progress_container:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    -- local progress_container_size = progress_container:getContentSize()
    self.progress:setPercent(0)

    self.progress_time = progress_container:getChildByName("time")
    self.progress_time:setString("")

    self.total_time = self.main_container:getChildByName("total_time")
    self.total_time:setString("")

    self.level_key = self.main_container:getChildByName("level_key")
    self.level_key:setString(TI18N("提炼等级:"))
    self.level_value = self.main_container:getChildByName("level_value")

    self.txt_key_1 = self.main_container:getChildByName("txt_key_1")
    self.txt_key_1:setString(TI18N("提炼效率:"))
    self.txt_key_2 = self.main_container:getChildByName("txt_key_2")
    self.txt_key_2:setString(TI18N("转换效率:"))
    self.txt_key_3 = self.main_container:getChildByName("txt_key_3")
    self.txt_key_3:setString(TI18N("剩余经验:"))
    self.txt_key_4 = self.main_container:getChildByName("txt_key_4")
    self.txt_key_4:setString(TI18N("剩余时间:"))

    self.txt_value_1 = createRichLabel(20, Config.ColorData.data_new_color4[15], cc.p(0,0.5),cc.p(200, 963),nil,nil,1900)
    self.txt_value_2 = createRichLabel(20, Config.ColorData.data_new_color4[15], cc.p(0,0.5),cc.p(200, 934),nil,nil,1900)
    self.txt_value_3 = self.main_container:getChildByName("txt_value_3")

    self.main_container:addChild(self.txt_value_1)
    self.main_container:addChild(self.txt_value_2)
    -- --剩余经验
    -- self.less_exp_label = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5),cc.p(175, 190),nil,nil,1900)
    -- self.main_container:addChild(self.less_exp_label)
    -- self.less_exp_label:setString(TI18N("剩余经验: xxx万"))

    -- --提炼效率
    -- self.refine_effect_label = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5),cc.p(333, 260),nil,nil,1900)
    -- self.main_container:addChild(self.refine_effect_label)
    -- self.refine_effect_label:setString(TI18N("提炼效率: xxx"))

    -- --已提炼
    -- self.refined_label = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5),cc.p(520, 230),nil,nil,1900)
    -- self.main_container:addChild(self.refined_label)
    -- self.refined_label:setString(TI18N("已提炼: xxx"))

end

function HeroResonateExtractPanel:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    registerButtonEventListener(self.close_btn, function() self:onClosedBtn() end ,true, 2)
    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn()  end ,true, 1)
    registerButtonEventListener(self.recovery_btn, function() self:onRecoveryBtn()  end ,false, 1)

    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        local config = Config.ResonateData.data_const.extract_rule
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
    end ,true, 1)

    --精炼信息返回
    self:addGlobalEvent(HeroEvent.Hero_Resonate_Extract_Event, function(data)
        if not data then return end
        self:setData(data)
    end)
    

    -- --     --道具增加
    -- self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
    --     if bag_code == BackPackConst.Bag_Code.PETBACKPACK then 
    --         if self.tab_object then 
    --             self:updateList(self.tab_object.index)
    --         end
    --     end
    -- end)
    -- --物品道具删除 
    -- self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code,temp_add)
    --     if bag_code == BackPackConst.Bag_Code.PETBACKPACK then 
    --         if self.tab_object then 
    --             self:updateList(self.tab_object.index)
    --         end
    --     end
    -- end)
    -- --物品道具变化
    -- self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_add)
    --     if bag_code == BackPackConst.Bag_Code.PETBACKPACK then 
    --         if self.tab_object then 
    --             self:updateList(self.tab_object.index)
    --         end
    --     end
    -- end)

    if role_vo ~= nil then
        if self.role_lev_event == nil then
            self.role_lev_event =  role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, lev) 
                if key == "hero_exp" then
                    self:updateIconInfo()
                end
            end)
        end
    end
end

function HeroResonateExtractPanel:updateIconInfo()
    if not self.cost_item_config then return end
    local item_bid = self.cost_item_config.id
    if self.record_item_bid == nil or self.record_item_bid ~= item_bid then
        self.record_item_bid = item_bid
        loadSpriteTexture(self.coin, PathTool.getItemRes(self.cost_item_config.icon), LOADTEXT_TYPE)
    end

    local count = MoneyTool.GetMoneyString(BackpackController:getInstance():getModel():getItemNumByBid(item_bid))
    self.count:setString(count)
end


--关闭
function HeroResonateExtractPanel:onClosedBtn()
    controller:openHeroResonateExtractPanel(false)
end

--收获材料
function HeroResonateExtractPanel:onComfirmBtn()
    if not self.scdata then return end
    controller:sender26413()
end

--回收
function HeroResonateExtractPanel:onRecoveryBtn()
    if not self.scdata then return end
    if self.scdata.all_num == 0 then
        local setting = {}
        setting.limit_count = self.limit_num
        setting.target_item_id = self.extract_item_id
        setting.cost_item_id = self.cost_item_id
        setting.price = self.single_cost_count
        controller:openHeroResonateSelectExpPanel(true, setting)
    else
        local count = self.scdata.all_num - (self.scdata.do_num + self.scdata.get_num)
        if count <= 0 then
            message(TI18N("已提炼完成,请收获材料"))
            return
        end
        local less_count = self.single_cost_count * count
        local icon_src = PathTool.getItemRes(self.cost_item_config.icon) 
        local str = string_format(TI18N("当前剩余经验<img src='%s' scale=0.3 /><div fontcolor=#289b14> %s </div>，未完成提炼，是否取回？"),icon_src, less_count)
        local callback = function()
            controller:sender26412()
        end
        CommonAlert.show(str, TI18N("确定"), callback, TI18N("取消"),nil, CommonAlert.type.rich, nil, {timer = 3, timer_for = true, title = TI18N("经验取回")}) 
    end
end

function HeroResonateExtractPanel:openRootWnd(setting)
    local setting = setting or {}

    local resonate_stone_level =  model.resonate_stone_level or 0
    self.config_level_up = Config.ResonateData.data_level_up(resonate_stone_level)
    if not self.config_level_up then return end

    self.single_cost_time = self.config_level_up.need_time or 3600
    self.limit_num = self.config_level_up.limit_num or 5
    if model:isResonateExtractRedpoint() then
        controller:sender26414()
    end
    controller:sender26410()
    self:updateIconInfo()

    self.level_value:setString(resonate_stone_level..TI18N("级"))
    local icon_src = PathTool.getItemRes(self.extract_item_config.icon) 
    local str = string_format(TI18N("<img src='%s' scale=0.3 />1=%s秒"),icon_src, self.single_cost_time)
    self.txt_value_1:setString(str)

    local icon_src_exp = PathTool.getItemRes(self.cost_item_config.icon)  --self.single_cost_count
    local str = string_format(TI18N("<img src='%s' scale=0.3 />%s=<img src='%s' scale=0.3 />1"),icon_src_exp, self.single_cost_count,icon_src)
    self.txt_value_2:setString(str)
end


function HeroResonateExtractPanel:setData(data)
    if not self.single_cost_time then return end
    if self.scdata then
        if self.scdata.get_num - data.get_num > 0 then
            if self.extract_item_config then 
                local item_color = BackPackConst.getBlackQualityColorStr(self.extract_item_config.quality)
                local msg = string_format(TI18N("获得<div fontcolor=%s>%s</div>"), item_color, self.extract_item_config.name)
                showAssetsMsg(msg)
            end
        end
    end
    self.scdata = data

    if self.scdata.all_num == 0 then
        self.right_item:setBaseData(self.extract_item_id, 1)
        self.right_item:setSpecialNum(0)
        doStopAllActions(self.progress_time)
        doStopAllActions(self.total_time)
        self.progress_time:setString(TI18N("点击瓶子放入经验"))
        self.total_time:setString("0")
        self.progress:setPercent(0)
        self:showBottleEffect1(0)
        self.recovery_btn_label:setString(TI18N("放入"))

        self.txt_value_3:setString(0)
    else
        self.recovery_btn_label:setString(TI18N("取回"))
        self.right_item:setBaseData(self.extract_item_id, self.scdata.do_num)
        self.right_item:setSpecialNum(self.scdata.do_num)
        local cur_time = GameNet:getInstance():getTime()
        local callback = function(time) self:setTimeFormatString(time) end
        local time = self.scdata.do_end_time - cur_time
        commonCountDownTime(self.progress_time, time, {callback = callback})

        --总时间
        local count = self.scdata.all_num - (self.scdata.do_num + self.scdata.get_num) - 1
        if count < 0 then
            coutn = 0
        end
        local total_time = self.single_cost_time * count + time
        commonCountDownTime(self.total_time, total_time)

        self.txt_value_3:setString(MoneyTool.GetMoneyString((count + 1) * self.single_cost_count))
    end
end


function HeroResonateExtractPanel:setTimeFormatString(time)
    if not self.progress_time then return end
    if not self.progress then return end
    if not self.single_cost_time then return end
    if time <= 0 then
        time = 0
        self.progress_time:setString("00:00")
            --发送更新的协议
        doStopAllActions(self.progress_time)
    else
        local timeStr = TimeTool.GetTimeForFunction(time)
        self.progress_time:setString(timeStr)
    end

    if time >=  self.single_cost_time then
        self.progress:setPercent(0)
        self:showBottleEffect1(0)
    else
        local have_time = self.single_cost_time - time
        local per = have_time * 100/self.single_cost_time
        self.progress:setPercent(per)
        self:showBottleEffect1(per)
    end
end


function HeroResonateExtractPanel:showBottleEffect1(per)
    local index = math_ceil(per/20)
    if index < 0 then
        index = 0
    elseif index > 5 then
        index = 5
    end

    local action = PlayerAction["action_"..index]
    if action == nil or index == 0 then
        action = PlayerAction["action_6"] 
    end --
    if self.record_action == nil or self.record_action ~= index then
        self.record_action = index
        --if self.girl_effect == nil then
        --    self.girl_effect = createEffectSpine("E24123", cc.p(188, -88), cc.p(0.5, 0.5), true, action)
        --    self.spine_node:addChild(self.girl_effect, 3)
        --else
        --    self.girl_effect:setAnimation(0, action, true)
        --end
    end

    -- local size = cc.size(100, 100)
    -- if self.clipNode == nil then
    --     local mask_res = PathTool.getResFrame("common", "common_1032") 
    --     self.mask = createSprite(mask_res, size.width * 0.5, size.height * 0.5, nil, cc.p(0.5, 0.5))

    --     self.clipNode = cc.ClippingNode:create(self.mask)
    --     self.clipNode:setAnchorPoint(cc.p(0.5,0.5))
    --     self.clipNode:setContentSize(size)
    --     self.clipNode:setCascadeOpacityEnabled(true)
    --     self.clipNode:setPosition(181, 336)
    --     self.clipNode:setAlphaThreshold(0)
    --     self.main_container:addChild(self.clipNode,2)

    --     if self.bottle_effect == nil then
    --         self.bottle_effect = createEffectSpine("E31322", cc.p(181, 336), cc.p(0.5, 0.5), true, PlayerAction.action)
    --         self.main_container:addChild(self.bottle_effect, 3) 
    --     end
    --     if self.bottle_effect1 == nil then
    --         self.bottle_effect1 = createEffectSpine("E31323", cc.p(size.width * 0.5, 50), cc.p(0.5, 0.5), true, PlayerAction.action)
    --         self.clipNode:addChild(self.bottle_effect1, 3) 
    --     end
    -- end
    -- if self.bottle_effect1 then
    --     -- self.bottle_effect1:setPositionY( size.height * per/100)
    --     -- self.bottle_effect1:setPositionY( 50)
    -- end
end

function HeroResonateExtractPanel:close_callback()

    --if self.girl_effect then
    --    self.girl_effect:clearTracks()
    --    self.girl_effect:removeFromParent()
    --    self.girl_effect = nil
    --end
    if self.bottle_effect then
        self.bottle_effect:clearTracks()
        self.bottle_effect:removeFromParent()
        self.bottle_effect = nil
    end
    if self.bottle_effect1 then
        self.bottle_effect1:clearTracks()
        self.bottle_effect1:removeFromParent()
        self.bottle_effect1 = nil
    end


    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    self.item_list = {}

    if self.right_item then
        self.right_item:DeleteMe()
        self.right_item = nil
    end

    if self.item_load_bg then
        self.item_load_bg:DeleteMe()
    end
    self.item_load_bg = nil

    if role_vo then
        if self.role_lev_event then
            role_vo:UnBind(self.role_lev_event)
            self.role_lev_event = nil
        end
    end

    doStopAllActions(self.progress_time)
    controller:openHeroResonateExtractPanel(false)
end