--------------------------------------------
-- @Author  : htp
-- @Editor  : xhj
-- @Date    : 2020-02-19 15:36:39
-- @description    : 
		-- 精灵孵化界面
---------------------------------
ElfinHatchPanel = class("ElfinHatchPanel",function()
    return ccui.Layout:create()
end)

local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _table_sort = table.sort
local _string_format = string.format

function ElfinHatchPanel:ctor(sub_type)
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("hero/hero_elfin_hatch_panel"))

    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    -- 初始化数据
    self:initElfinData()

    -- 资源加载
    local res_list = {}
    _table_insert(res_list, {path = PathTool.getPlistImgForDownLoad("elfin", "elfin"), type = ResourcesType.plist})
    if self.init_res_load then
        self.init_res_load:DeleteMe()
        self.init_res_load = nil
    end
    self.init_res_load = ResourcesLoad.New()
    self.init_res_load:addAllList(res_list, function()
        if not tolua.isnull(self.root_wnd) then
            self:loadResListCompleted(sub_type)
        end
    end)
end

function ElfinHatchPanel:loadResListCompleted( sub_type )
	self:initView()
    self:registerEvent()
    self:updateElfinPrivileg()
end



-- 初始化数据
function ElfinHatchPanel:initElfinData(  )
    

    self.egg_list = {} --灵窝列表

end

-- 初始化界面
function ElfinHatchPanel:initView(  )
	self.container = self.root_wnd:getChildByName("container")
    self.elfin_book_txt = createRichLabel(22, Config.ColorData.data_new_color4[13], cc.p(1, 0.5), cc.p(710, 650))
    self.container:addChild(self.elfin_book_txt, 2)
    self.elfin_book_txt:setString(_string_format(TI18N("<div href=xxx >精灵图鉴 </div><img src='%s'/>"), PathTool.getResFrame("common","common_90017")))
    self.elfin_book_txt:addTouchEventListener(function (  )
        _controller:openElfinBookWindow(true)
    end)
    -- 孵化ji
    self.hatch_panel = self.container:getChildByName("hatch_panel")
    self.hatch_panel:setLocalZOrder(1)
    self.hatch_bg = self.hatch_panel:getChildByName("hatch_bg")
    self.hatch_bg:ignoreContentAdaptWithSize(true)

    -- 灵窝背景
    local hatch_bg_res = PathTool.getPlistImgForDownLoad("elfin","elfin_hatch_bg")
    self.hatch_bg_load = loadImageTextureFromCDN(self.hatch_bg, hatch_bg_res, ResourcesType.single, self.hatch_bg_load)
    self.hatch_bg:setVisible(true)

    self.vip_btn = self.hatch_panel:getChildByName("vip_btn")
    self.vip_btn:getChildByName("label"):setString(TI18N("精灵特权"))
    self.time_lab = self.vip_btn:getChildByName("time_lab")
    self.time_lab:setString("")

    for i=1,6 do
    	local egg = self.hatch_panel:getChildByName("egg_"..i)
		local item = ElfinHatchItem.new()
		item:setData(i)
    	egg:addChild(item)
    	self.egg_list[i] = item
    end

end

function ElfinHatchPanel:registerEvent(  )
    
    registerButtonEventListener(self.vip_btn, function (  )
        _controller:openElfinPrivilegeWindow(true)
	end, true)

    if self.update_hatch_event == nil then
        self.update_hatch_event = GlobalEvent:getInstance():Bind(VipEvent.PRIVILEGE_INFO, function()
            self:updateElfinPrivileg()
        end)
    end
end

function ElfinHatchPanel:updateElfinPrivileg()
    local privilege_data = RoleController:getInstance():getModel():getPrivilegeDataById(5)
    if privilege_data and privilege_data.expire_time and privilege_data.status == 1 then --已激活
        local cur_time = GameNet:getInstance():getTime()
        local less_time = privilege_data.expire_time - cur_time
        setChildUnEnabled(false, self.vip_btn)
        self.time_lab:setString(TimeTool.GetTimeFormatDayIIIIII(less_time))
        
    else
        setChildUnEnabled(true, self.vip_btn)
        self.time_lab:setString("")
    end
end


function ElfinHatchPanel:DeleteMe(  )
  
	if self.init_res_load then
        self.init_res_load:DeleteMe()
        self.init_res_load = nil
    end
    
    if self.hatch_bg_load then
        self.hatch_bg_load:DeleteMe()
        self.hatch_bg_load = nil
    end
  
 
    
    if self.update_hatch_event then
        GlobalEvent:getInstance():UnBind(self.update_hatch_event)
        self.update_hatch_event = nil
    end


    for k,v in pairs(self.egg_list) do
		if v then
			v:DeleteMe()
		end
	end

    self.egg_list = nil
end


-- --------------------------------------------------------------------
-- @author: xhj(必填, 创建模块的人员)
-- @editor: (必填, 后续维护以及修改的人员)
-- @description:
--      精灵孵化item
-- Create: 2020-02-19
-- --------------------------------------------------------------------
ElfinHatchItem = class("ElfinHatchItem", function()
    return ccui.Widget:create()
end)

function ElfinHatchItem:ctor()
	self.ctrl = ActionController:getInstance()
	self.model = self.ctrl:getModel()

	self:configUI()
	self:register_event()
    self.cur_hatch_index = 1 -- 当前灵窝的下标
    self.cur_hatch_vo = nil  -- 当前显示的灵窝数据
    self.cur_hatch_status = nil -- 当前精灵窝的状态
    self.all_hatch_data = {} -- 所有灵窝数据（包括未解锁的）
end

function ElfinHatchItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("elfin/elfin_hatch_iten"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(100,120))
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.egg_icon = self.main_container:getChildByName("egg_icon")
    self.egg_icon:ignoreContentAdaptWithSize(true)
    self.hatch_lock_sp = self.main_container:getChildByName("hatch_lock_sp")
    self.hatch_lock_sp:setVisible(false)
    self.egg_home_sp = self.main_container:getChildByName("egg_home_sp")
    self.name_bg = self.main_container:getChildByName("name_bg")
    
    self.add_egg_btn = self.main_container:getChildByName("add_egg_btn")
    
    self.egg_name = self.main_container:getChildByName("egg_name")
    self.egg_name:setString(TI18N("培育仓"))

    self.tip_lab = self.main_container:getChildByName("tip_lab")
    self.tip_lab:setString(TI18N("可放入"))

    local size = cc.size(143, 19)
    local res = PathTool.getResFrame("common","common_90005")
    local res1 = PathTool.getResFrame("common","common_90006")
    local bg,comp_bar = createLoadingBar(res, res1, size, self.main_container, cc.p(0.5,0.5), 100, 208, true, true)
    self.comp_bar_bg = bg
    self.comp_bar = comp_bar

    local text_color = cc.c3b(255,255,255)
    local line_color = cc.c3b(0,0,0)
    self.comp_bar_label = createLabel(16, text_color, line_color, size.width/2, size.height/2, "", self.comp_bar, 2, cc.p(0.5, 0.5))

    self.comp_bar_bg:setVisible(false)
    self.comp_bar:setVisible(false)
    self.comp_bar_label:setVisible(false)

    self.open_lab = createLabel(18,Config.ColorData.data_new_color4[15],Config.ColorData.data_new_color4[16],100,100,"",self.main_container,2, cc.p(0.5,0.5))

    
end

function ElfinHatchItem:register_event(  )
	
    registerButtonEventListener(self.add_egg_btn, function (  )
        self:onClickAddEggBtn()
    end, true)


    registerButtonEventListener(self.egg_icon, function (  )
        self:onClickEggIcon()
    end, false)

    -- 所有孵化器数据
    if not self.get_hatch_data_event then
        self.get_hatch_data_event = GlobalEvent:getInstance():Bind(ElfinEvent.Get_Elfin_Hatch_Data_Event, function (  )
            self.all_hatch_data = _model:getElfinHatchList()
            _table_sort(self.all_hatch_data, SortTools.KeyLowerSorter("sort"))
            
            self:setHatchData()
        end)
    end

    -- 红点
    if not self.update_red_status_event then
        self.update_red_status_event = GlobalEvent:getInstance():Bind(ElfinEvent.Update_Elfin_Red_Event, function ( bid, status )
            self:updateElfinRedInfo()
        end)
    end
end


-- 添加蛋
function ElfinHatchItem:onClickAddEggBtn(  )
    local setting = {}
    setting.view_type = ElfinConst.Select_Type.Egg
    setting.hatch_id = self.cur_hatch_vo.id
    _controller:openElfSelectItemWindow(true, setting)
end

-- 点击灵蛋
function ElfinHatchItem:onClickEggIcon(  )
    -- 当前灵窝为未解锁的特权灵窝，则打开特权弹窗
    if self.cur_hatch_vo and self.cur_hatch_vo.is_open == 0 or self.cur_hatch_vo.is_open == 2 then
        local hatch_cfg = Config.SpriteData.data_hatch_data[self.cur_hatch_vo.id]
        if hatch_cfg and hatch_cfg.res_id == 2 then
            _controller:openElfinPrivilegeWindow(true)
        else
            _controller:openElfinHatchUnlockPanel(true,self.cur_hatch_vo)
        end
    elseif self.cur_hatch_vo and self.cur_hatch_vo.state == ElfinConst.Hatch_Status.Hatch then
        message(TI18N("正在孵化中，请耐心等待"))
    end
end

-- 设置当前灵窝数据
function ElfinHatchItem:setHatchData(  )
    if self.cur_hatch_vo ~= nil then
        if self.update_self_event ~= nil then
            self.cur_hatch_vo:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
    end

    if not self.cur_hatch_index or not self.all_hatch_data then return end
    self.cur_hatch_vo = self.all_hatch_data[self.cur_hatch_index]
    if not self.cur_hatch_vo then return end

    if self.update_self_event == nil then
        self.update_self_event = self.cur_hatch_vo:Bind(ElfinEvent.Update_Elfin_Hatch_Vo_Event, function()
            self:updateHatchInfo()
        end)
    end
    self:updateHatchInfo()
    self:updateElfinRedInfo()
end

-- 更新孵化界面
function ElfinHatchItem:updateHatchInfo(  )
    if not self.cur_hatch_vo then return end
    self.cur_hatch_status = self.cur_hatch_vo.state

    -- 灵窝等级相关配置数据
    if self.cur_hatch_vo.lev then
        self.cur_hatch_lev_cfg = Config.SpriteData.data_hatch_lev[self.cur_hatch_vo.lev]
        self.next_hatch_lev_cfg = Config.SpriteData.data_hatch_lev[self.cur_hatch_vo.lev+1]
    end

    -- 灵窝中的蛋的配置数据
    if self.cur_hatch_vo.do_id and self.cur_hatch_vo.do_id ~= 0 then
        self.cur_hatch_egg_cfg = Config.SpriteData.data_hatch_egg[self.cur_hatch_vo.do_id]
    else
        self.cur_hatch_egg_cfg = nil
    end

    -- 灵窝名称，未放置灵蛋，则显示灵窝的名称，否则显示为灵蛋的名称
    local hatch_cfg = Config.SpriteData.data_hatch_data[self.cur_hatch_vo.id]
    if self.cur_hatch_egg_cfg then
        local egg_item_cfg = Config.ItemData.data_get_data(self.cur_hatch_egg_cfg.item_bid)
        if egg_item_cfg then
            self.egg_name:setString(egg_item_cfg.name)
        end
    elseif hatch_cfg then
        self.egg_name:setString(hatch_cfg.name)
        self.open_lab:setString(hatch_cfg.desc1)
        
    else
        self.egg_name:setString(TI18N("培育仓"))
    end

    -- 特权灵窝显示提示
    if hatch_cfg and hatch_cfg.res_id == 2 then
        loadSpriteTexture(self.egg_home_sp, PathTool.getResFrame("elfin", "elfin_1046"), LOADTEXT_TYPE_PLIST)
        loadSpriteTexture(self.name_bg, PathTool.getResFrame("elfin", "elfin_1053"), LOADTEXT_TYPE_PLIST)
        --self.egg_name:setTextColor(cc.c4b(0xFF,0xF7,0xC9,0xff))
        --self.egg_name:setPositionY(28)

    else
        --self.egg_name:setTextColor(cc.c4b(0x64,0x32,0x23,0xff))
        --self.egg_name:setPositionY(38.4)
        loadSpriteTexture(self.egg_home_sp, PathTool.getResFrame("elfin", "elfin_1047"), LOADTEXT_TYPE_PLIST)
        loadSpriteTexture(self.name_bg, PathTool.getResFrame("elfin", "elfin_1053"), LOADTEXT_TYPE_PLIST)
    end

    self.egg_icon:setVisible(true)
    self.egg_icon:setOpacity(0)
    self.egg_icon:setTouchEnabled(false)
    self.add_egg_btn:setVisible(false)
    self.tip_lab:setVisible(false)
    self:showEggHatchSuccessAni(false)
    doStopAllActions(self.comp_bar_label)
    local egg_path = PathTool.getPlistImgForDownLoad("elfin","elfin_egg_icon")
    local egg_scale = 1
    --local egg_y = 38.8
    if self.cur_hatch_status == ElfinConst.Hatch_Status.Open and self.cur_hatch_vo.is_open == 0 then -- 空闲且未激活才显示为锁住
        loadSpriteTexture(self.hatch_lock_sp, PathTool.getResFrame("elfin","elfin_1064"), LOADTEXT_TYPE_PLIST)
        --self.hatch_lock_sp:setScale(0.8)
        self.hatch_lock_sp:setVisible(true)
        self.open_lab:setTextColor(Config.ColorData.data_new_color4[15])
        self.open_lab:enableOutline(Config.ColorData.data_new_color4[16], 2)
        self.open_lab:setVisible(true)
        self.egg_icon:setTouchEnabled(true)
        self.comp_bar_bg:setVisible(false)
        self.comp_bar:setVisible(false)
        self.comp_bar_label:setVisible(false)
    elseif self.cur_hatch_status == ElfinConst.Hatch_Status.Open and self.cur_hatch_vo.is_open == 2 then -- 空闲且待激活才显示为可开锁
        loadSpriteTexture(self.hatch_lock_sp, PathTool.getResFrame("elfin", "elfin_1049"), LOADTEXT_TYPE_PLIST)
        --self.hatch_lock_sp:setScale(1)
        self.hatch_lock_sp:setVisible(true)
        

        self.open_lab:setTextColor(Config.ColorData.data_new_color4[7])
        self.open_lab:enableOutline(cc.c4b(0x19,0x3b,0x17,0xff), 2)
        self.open_lab:setString(TI18N("可解锁"))
        self.open_lab:setVisible(true)
        self.egg_icon:setTouchEnabled(true)
        self.comp_bar_bg:setVisible(false)
        self.comp_bar:setVisible(false)
        self.comp_bar_label:setVisible(false)
    elseif self.cur_hatch_status == ElfinConst.Hatch_Status.Hatch or self.cur_hatch_status == ElfinConst.Hatch_Status.Over then -- 孵化中或孵化完成待领取
        self.hatch_lock_sp:setVisible(false)
        self.open_lab:setVisible(false)
        self.egg_icon:setOpacity(255)
         -- 孵化总时间
         local need_all_time = self.cur_hatch_vo.all_end_time - GameNet:getInstance():getTime()
         if need_all_time>0 then
             commonCountDownTime(self.comp_bar_label, need_all_time)
         else
             self.comp_bar_label:setString(TI18N("已完成"))
         end

        -- 蛋的资源
        local percent = 0
        if self.cur_hatch_egg_cfg then
            egg_path = PathTool.getElfinEggRes(self.cur_hatch_egg_cfg.res_id)
            egg_scale = 1
            --egg_y = 45
            self:showEggAction(true)
            local hatch_rate = Config.SpriteData.data_const["hatch_rate"]
			if hatch_rate then
                local sumTime = self.cur_hatch_egg_cfg.need_piont*hatch_rate.val
				percent = (sumTime-need_all_time)/sumTime*100
			end
        end
        self.comp_bar_bg:setVisible(true)
        self.comp_bar:setVisible(true)
        self.comp_bar_label:setVisible(true)
        self.comp_bar:setPercent(percent)
        
        if self.cur_hatch_status ~= ElfinConst.Hatch_Status.Hatch then
            self:showEggHatchSuccessAni(true)
        else
            self.egg_icon:setTouchEnabled(true)
        end
    elseif self.cur_hatch_status == ElfinConst.Hatch_Status.Open then -- 已开启，但未孵化
        self.hatch_lock_sp:setVisible(false)
        self.open_lab:setVisible(false)
        self.add_egg_btn:setVisible(true)
        self.tip_lab:setVisible(true)
        self.comp_bar_bg:setVisible(false)
        self.comp_bar:setVisible(false)
        self.comp_bar_label:setVisible(false)
    end
    if not self.cur_egg_path or self.cur_egg_path ~= egg_path then
        self.cur_egg_path = egg_path
        self.egg_icon:setScale(egg_scale)
        --self.egg_icon:setPositionY(egg_y)
        self.egg_img_load = loadImageTextureFromCDN(self.egg_icon, egg_path, ResourcesType.single, self.egg_img_load)
    end
end


-- 显示灵蛋孵化成功的特效
function ElfinHatchItem:showEggHatchSuccessAni( status )
    if status == true then
        self.cur_ani_hatch_id = self.cur_hatch_vo.id -- 记录一下当前播放孵化成功特效的灵窝id，避免播放过程中点击切换到其他灵窝产生的问题
        self:handleEggEffect(true)
    else
        if self.egg_effect then
            self.egg_effect:setVisible(false)
        end
        self.cur_ani_hatch_id = nil
    end
end

function ElfinHatchItem:onEndEggAniCallBack(  )
    self.egg_effect:setVisible(false)
    self.is_show_egg_effect = false
    --[[-- 请求领取孵出的精灵
    if self.cur_ani_hatch_id and self.cur_ani_hatch_id == self.cur_hatch_vo.id then
        _controller:sender26506(self.cur_hatch_vo.id)
    end--]]
end

function ElfinHatchItem:handleEggEffect( status )
    doStopAllActions(self.main_container)
    self.is_show_egg_effect = status -- 是否正在播放蛋孵化成功的特效，过程中不给切换灵窝和tab按钮
    if status == false then
        if self.egg_effect then
            self.egg_effect:clearTracks()
            self.egg_effect:removeFromParent()
            self.egg_effect = nil
        end
    else
        -- 孵化成功的音效
        playOtherSound("c_hatchegg")
        self:showEggAction(false)
        if not tolua.isnull(self.main_container) and self.egg_effect == nil then
            local icon_size = self.egg_icon:getContentSize()
            self.egg_effect = createEffectSpine(Config.EffectData.data_effect_info[1353], cc.p(self.main_container:getContentSize().width/2-10, self.main_container:getContentSize().height/2-50), cc.p(0.5, 0.5), false, PlayerAction.action, handler(self, self.onEndEggAniCallBack))
            self.egg_effect:setScale(0.6)
            self.main_container:addChild(self.egg_effect)
        elseif self.egg_effect then
            self.egg_effect:setVisible(true)
            self.egg_effect:setToSetupPose()
            self.egg_effect:setAnimation(0, PlayerAction.action, false)
        end

        -- 请求领取孵出的精灵
        local function reqReceiveElfinCallBack(  )
            if self.cur_ani_hatch_id and self.cur_ani_hatch_id == self.cur_hatch_vo.id then
                _controller:sender26506(self.cur_hatch_vo.id)
            end
        end
        local delay_time = 2
        if Config.SpriteData.data_const["end_time"] then
            delay_time = Config.SpriteData.data_const["end_time"].val/1000
        end
        self.main_container:runAction(cc.Sequence:create(cc.DelayTime:create(delay_time), cc.CallFunc:create(reqReceiveElfinCallBack)))

        -- 播放孵化成功特效过程中，隐藏一些东西
        if self.smash_crack_icon then
            self.smash_crack_icon:stopAllActions()
            self.smash_crack_icon:setVisible(false)
            self.is_smash_crack_ani = false
        end
        self.egg_icon:runAction(cc.Sequence:create( cc.DelayTime:create(delay_time), cc.CallFunc:create(function (  )
            self.egg_icon:setVisible(false)
        end)))
    end
end

function ElfinHatchItem:setData( index )
    self.cur_hatch_index = index
	if index == 1 then
        -- 引导需要
        self.add_egg_btn:setName("guide_add_btn")

	end
	
end


------------------@ 红点
function ElfinHatchItem:updateElfinRedInfo()
    local status = false
    if self.cur_hatch_vo then
        if self.cur_hatch_vo.state == ElfinConst.Hatch_Status.Open and self.cur_hatch_vo.is_open == 2 then
            status = true
        end

        if status == false and self.cur_hatch_vo.is_open == 1 and self.cur_hatch_vo.state == ElfinConst.Hatch_Status.Open then
            local all_egg_list = BackpackController:getInstance():getModel():getBackPackItemListByType(BackPackConst.item_type.ELFIN_EGG)
            if #all_egg_list > 0 then
                status = true
            end
        end

        if status == false and self.cur_hatch_vo.state == ElfinConst.Hatch_Status.Over then
            status = true
        end
        
    end
    
    addRedPointToNodeByStatus(self.main_container, status, -50, -50)
end

-- 积分按钮抖动效果
function ElfinHatchItem:showEggAction( status )
    if status == true then
        --self.egg_icon:setRotation(0)
        --self.egg_icon:stopAllActions()
        --local act_1 = cc.RotateBy:create(0.05, -2)
        --local act_2 = cc.RotateBy:create(0.1, 4)
        --local act_3 = cc.RotateBy:create(0.05, -2)
        --local delay = cc.DelayTime:create(2)
        --local actions = {}
        --for i=1,5 do
        --    _table_insert(actions, act_1)
        --    _table_insert(actions, act_2)
        --    _table_insert(actions, act_3)
        --end
        --_table_insert(actions, delay)
        --local sequence = cc.Sequence:create(unpack(actions))
        --self.egg_icon:runAction(cc.RepeatForever:create(sequence))
        self.egg_icon:runAction(cc.RepeatForever:create(CCRotateBy:create(2, 360)))
    else
        self.egg_icon:setRotation(0)
        self.egg_icon:stopAllActions()
    end
end

function ElfinHatchItem:DeleteMe()
    self:showEggAction(false)
    self:handleEggEffect(false)
    doStopAllActions(self.comp_bar_label)
    doStopAllActions(self.main_container)
    if self.egg_img_load then
    	self.egg_img_load:DeleteMe()
    	self.egg_img_load = nil
    end

    if self.cur_hatch_vo ~= nil then
        if self.update_self_event ~= nil then
            self.cur_hatch_vo:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
    end

    if self.get_hatch_data_event then
        GlobalEvent:getInstance():UnBind(self.get_hatch_data_event)
        self.get_hatch_data_event = nil
    end

    if self.update_red_status_event then
        GlobalEvent:getInstance():UnBind(self.update_red_status_event)
        self.update_red_status_event = nil
    end
end