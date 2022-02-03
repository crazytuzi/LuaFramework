-- --------------------------------------------------------------------
-- z物品tips
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BackpackTips = BackpackTips or BaseClass(BaseView)

local table_insert = table.insert
function BackpackTips:__init()
    self.ctrl = BackpackController:getInstance()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "tips/backpack_tips"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.btn_list = {}
end

function BackpackTips:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")

    self.container = self.main_panel:getChildByName("container")            -- 背景,需要动态设置尺寸
    self.container_init_size = self.container:getContentSize()

    -- 基础属性,名字,类型和评分等
    self.base_panel = self.container:getChildByName("base_panel")
    self.goods_item =  BackPackItem.new(true,true,nil,1,false)
    self.goods_item:setPosition(cc.p(72,68))
    self.base_panel:addChild(self.goods_item)
    self.name = self.base_panel:getChildByName("name")
    self.equip_type = self.base_panel:getChildByName("equip_type")
    self.extend_desc = createRichLabel(22,cc.c4b(0xff,0xee,0xdd,0xff),cc.p(0,0),cc.p(146,10),nil,nil,500)
    self.base_panel:addChild(self.extend_desc)

    -- 作用描述
    self.usedesc_panel = self.container:getChildByName("usedesc_panel")
    self.use_desc = self.usedesc_panel:getChildByName("desc")
    self.usedesc_panel_height = self.usedesc_panel:getContentSize().height

    -- 描述部分
    self.desc_panel = self.container:getChildByName("desc_panel")
    self.desc_panel_size = self.desc_panel:getContentSize()
    self.scroll_view = self.desc_panel:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
    self.scroll_size = self.scroll_view:getContentSize()
    self.desc_label = createRichLabel(22, cc.c4b(0xa1,0x97,0x8b,0xff), cc.p(0, 1), cc.p(20, 100), 8, nil, 380) 
    self.scroll_view:addChild(self.desc_label)

    -- 按钮部分
    self.tab_panel = self.container:getChildByName("tab_panel")
    self.tab_panel_height = self.tab_panel:getContentSize().height
    for i=1, 3 do
        local btn = self.tab_panel:getChildByName("tab_btn_"..i)
        if btn then
            local object = {}
            object.btn = btn
            object.label = btn:getTitleRenderer()
            self.btn_list[i] = object
        end
    end

    self.close_btn = self.main_panel:getChildByName("close_btn")
end

function BackpackTips:register_event()
    if self.background then 
        self.background:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                self:close()
            end
        end)
    end
    if self.close_btn then 
        self.close_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                self:close()
            end
        end)
    end
end

function BackpackTips:clickBtn(index)
    if not self.item_config then return end
    if index == BackPackConst.tips_btn_type.source then --来源
        if #self.item_config.source >0 then
            self.ctrl:openTipsSource(true,self.data)
        else
            message(TI18N("暂时没有来源"))
        end
    elseif index == BackPackConst.tips_btn_type.sell then --金币市场道具出售
        if self.data.quantity <=1 then
            MarketController:getInstance():sender23502( self.data.id,self.data.quantity )
        else
            if not self.sell_vo then return end
            BackpackController:getInstance():openBatchUseItemView(true, self.data, ItemConsumeType.sell,{type=1,value_list=self.sell_vo})
        end
    elseif index == BackPackConst.tips_btn_type.goods_use then --普通物品使用
        local use_type = self.item_config.use_type or 1
        if self.data and self.data.id and use_type == BackPackConst.item_use_type.BATCH_USE then 
            local quantity = self.data.quantity or 0
            if self.item_config.type == BackPackConst.item_type.FREE_GIFT then 
                self.ctrl:openGiftSelectPanel(self.data)
            elseif quantity ==1 then 
                self.ctrl:sender10515(self.data.id or 0,quantity)
            else
                self.ctrl:openBatchUseItemView(true,self.data)
            end
        end
    elseif index == BackPackConst.tips_btn_type.boss_source then --跳转世界boss界面 
    
    elseif index == BackPackConst.tips_btn_type.drama_new_source then --跳转剧情副本最新的关卡页面 
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.drama_scene)
    elseif index == BackPackConst.tips_btn_type.drama_source then --跳转剧情副本界面 
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.drama_scene)
    elseif index == BackPackConst.tips_btn_type.hero_source then --跳转英雄信息界面 
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.partner)
    elseif index == BackPackConst.tips_btn_type.skill_source then --跳转英雄技能界面 
        HeroController:getInstance():openHeroBagWindow(true)
    elseif index == BackPackConst.tips_btn_type.form_source then --跳转编队阵法界面 
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.partner)
    elseif index == BackPackConst.tips_btn_type.call_source then --跳转召唤界面 
        PartnersummonController:getInstance():openPartnerSummonWindow(true)
    elseif index == BackPackConst.tips_btn_type.artifact_source then

    elseif index == BackPackConst.tips_btn_type.seerpalace_summon then --先知召唤
        SeerpalaceController:getInstance():openSeerpalaceMainWindow(true, SeerpalaceConst.Tab_Index.Summon) 
    elseif index == BackPackConst.tips_btn_type.seerpalace_change then --先知转换
       SeerpalaceController:getInstance():openSeerpalaceMainWindow(true, SeerpalaceConst.Tab_Index.Change) 
    elseif index == BackPackConst.tips_btn_type.hecheng2 then --神器合成,统一一个合成窗口了
        local config = self.data.config 
        if config and config.effect and config.effect[1] and config.effect[1].effect_type == 24 then 
            local item_id = config.effect[1].val or 0
            BackpackController:getInstance():openBackPackComposeWindow(true, {bid=item_id})
        end
    elseif index == BackPackConst.tips_btn_type.fenjie then --英雄碎片分解
        local list = {}
        table_insert(list, {id = self.data.id, bid =self.data.base_id, num =self.data.quantity})
        BackpackController:getInstance():openBatchUseItemView(true, self.data, ItemConsumeType.resolve)
    elseif index == BackPackConst.tips_btn_type.redbag then --公会红包
        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo and role_vo.gid ~=0 and role_vo.gsrid ~="" then
            local id = 1 --默认这个跳转1
            if self.data and self.data.config and self.data.config.client_effect and next(self.data.config.client_effect or {}) ~= nil and self.data.config.client_effect[1] then
                id = self.data.config.client_effect[1]
            end
            RedbagController:getInstance():openMainView(true,id)
        else
            message(TI18N("未加入公会不能发红包哦！"))
        end
    elseif index == BackPackConst.tips_btn_type.head then --个人设置头像
        -- RoleController:getInstance():openRoleDecorateView( true,2)
        local config = self.data.config
        if config then
            local setting = {}
            setting.id = self.data.config.id
            RoleController:getInstance():openRoleDecorateView( true, 2, setting)
        end
    elseif index == BackPackConst.tips_btn_type.chenghao then --个人设置称号
        RoleController:getInstance():openRoleDecorateView( true,4)
    elseif index == BackPackConst.tips_btn_type.partner_character then --跳转个人形形象设置
        local config = self.data.config 
        if config then
            local setting = {}
            setting.id = self.data.config.id
            RoleController:getInstance():openRoleDecorateView( true, 3, setting)
        end
    elseif index == BackPackConst.tips_btn_type.arena_source then --跳转竞技场
         ArenaController:getInstance():requestOpenArenaLoopMathWindow(true)
    elseif index == BackPackConst.tips_btn_type.stone_upgrade then --跳转宝石升级界面
       
    elseif index == BackPackConst.tips_btn_type.upgrade_star then       -- 伙伴直升卡,升星

    elseif index == BackPackConst.tips_btn_type.low_treasure then --跳转幸运探宝
        ActionController:getInstance():openLuckyTreasureWin(true)
    elseif index == BackPackConst.tips_btn_type.high_treasure then --跳转高级探宝
        ActionController:getInstance():openLuckyTreasureWin(true,2)
    elseif index == BackPackConst.tips_btn_type.halidom then --跳转圣物
        local open_cfg = Config.HalidomData.data_const["halidom_open_lev"]
        local role_vo = RoleController:getInstance():getRoleVo()
        if open_cfg and role_vo and role_vo.lev >= open_cfg.val then
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.partner, HeroConst.BagTab.eHalidom)
        elseif open_cfg then
            message(open_cfg.desc)
        end
    elseif index == BackPackConst.tips_btn_type.heaven_book then --神装图鉴
        HeroController:getInstance():openHeroClothesLustratWindow(true)
    elseif index == BackPackConst.tips_btn_type.heaven_shop then --神装商店
        SuitShopController:getInstance():openSuitShopMainView(true)
    elseif index == BackPackConst.tips_btn_type.item_sell then --道具出售 --目前是符石
        BackpackController:getInstance():openItemSellPanel(true, self.data, BackPackConst.Bag_Code.BACKPACK)
    elseif index == BackPackConst.tips_btn_type.hero_reset then --道具出售 --目前是符石
        --跳转英雄重生界面 活动基础id :93030 
        local action_id = 93030 --写死 --by lwc
         local is_exist = ActionController:getInstance():CheckActionExistByActionBid(action_id)
        if is_exist then
            ActionController:getInstance():openActionMainPanel(true, nil, action_id)
        else
            message(TI18N("活动未开启"))
        end
    elseif index == BackPackConst.tips_btn_type.heaven_dial_1 then --天界祈祷
        JumpController:getInstance():jumpViewByEvtData({48, 1})
    elseif index == BackPackConst.tips_btn_type.heaven_dial_2 then --天界祈祷
        JumpController:getInstance():jumpViewByEvtData({48, 2})
    elseif index == BackPackConst.tips_btn_type.heaven_dial_3 then --天界祈祷
        JumpController:getInstance():jumpViewByEvtData({48, 3})
    elseif index == BackPackConst.tips_btn_type.heaven_dial_4 then --天界祈祷
        JumpController:getInstance():jumpViewByEvtData({48, 4})
    elseif index == BackPackConst.tips_btn_type.heaven_dial_5 then --天界祈祷
        JumpController:getInstance():jumpViewByEvtData({48, 5})
    elseif index == BackPackConst.tips_btn_type.resonate then --共鸣
        JumpController:getInstance():jumpViewByEvtData({55})
    elseif index == BackPackConst.tips_btn_type.elfin_hatch then --精灵孵化
        JumpController:getInstance():jumpViewByEvtData({60, ElfinConst.Tab_Index.Hatch})
    elseif index == BackPackConst.tips_btn_type.elfin_rouse then --精灵古树
        JumpController:getInstance():jumpViewByEvtData({60, ElfinConst.Tab_Index.Rouse})
    elseif index == BackPackConst.tips_btn_type.elfin_summon then --精灵召唤
        JumpController:getInstance():jumpViewByEvtData({60, ElfinConst.Tab_Index.Summon})
    elseif index == BackPackConst.tips_btn_type.petard then --花火大会
        JumpController:getInstance():jumpViewByEvtData({64})
    elseif index == BackPackConst.tips_btn_type.return_action then --回归活动
        local call_back = function ()
            if self.data and self.data.id then 
                local quantity = self.data.quantity or 0
                if quantity ==1 then 
                    self.ctrl:sender10515(self.data.id or 0,quantity)
                else
                    self.ctrl:openBatchUseItemView(true,self.data)
                end
            end
        end
        if ReturnActionController:getInstance():getModel():isCanGetRedbag() == true then
            call_back()
        else
            if self.alert then
                self.alert:close()
                self.alert = nil
            end
            
            local str = TI18N("您今天可领取红包次数已达上限 确定继续使用？")
            if not self.alert then
                self.alert = CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
            end
        end 
    elseif index == BackPackConst.tips_btn_type.herosoul_shop then --英魂商店
        JumpController:getInstance():jumpViewByEvtData({71}) 
    elseif index == BackPackConst.tips_btn_type.elfin_egg_synthetic then --精灵蛋合成
        if self.item_config and self.item_config.id then
            ElfinController:getInstance():openElfinEggSyntheticPanel(true,self.item_config.id)
        end
        
    end
    self:close()
end

--引入 setting 
--setting.is_market_place 是否宝库显示
function BackpackTips:openRootWnd(item_bid,is_show_btn,is_special_source, setting)
    if not item_bid then return end

    self.setting = setting or {}

    self.is_show_btn = is_show_btn or false
    self.is_special_source = is_special_source

    if type(item_bid) == "number" then
        local config = Config.ItemData.data_get_data(item_bid)
        if not config then return end
        self.data = config
        self.item_config = config
    else
        self.data = item_bid
        if self.data.config then
            self.item_config = self.data.config
        else
            self.item_config = item_bid
        end
    end

    -- 设置按钮显示
    if is_show_btn == true then
        self:updateBtnList()
    end
    self:setBaseInfo()
    --限购INXS
    self:initLimitBuyInfo()
end

--限购信息
--data.limit_total_num = 限购最大数量
--data.limit_day  每日限购数量
--data.其他限购未加入
function BackpackTips:initLimitBuyInfo()
    if not self.data then return end
    if self.data.limit_day then --每日限购
        local total_count = self.data.limit_total_num or 0
        local label = self:getLimitBuytLabel()
        if label then
            label:setString(string.format(TI18N("每日限购<div fontcolor=#68c74b>%s/%s</div>个"), self.data.limit_day, total_count))
        end
    end
end

function BackpackTips:getLimitBuytLabel()
    if self.limit_buy_label == nil then
        local y = self.show_limit_y or 0
        self.limit_buy_label = createRichLabel(22, cc.c4b(0xff,0xee,0xdd,0xff), cc.p(0, 0.5), cc.p(16, y) ,nil,nil,1000)
        self.container:addChild(self.limit_buy_label)
    end
    return self.limit_buy_label
end
-- 调整位置和坐标
function BackpackTips:adjustContentSizeAndPos(  )
    local target_height = self.container_init_size.height 

    if not self.is_show_btn then            -- 是否显示按钮列
        self.tab_panel:setVisible(false)
        target_height = target_height - self.tab_panel_height
    end

    local show_limit_info = false
    if self.data and  self.data.limit_day then --每日限购
        show_limit_info = true
        target_height = target_height + 30
    end

    local show_use_desc = true
    if self.item_config.use_desc == nil or self.item_config.use_desc == "" then
        show_use_desc = false
        target_height = target_height - self.usedesc_panel_height
        self.usedesc_panel:setVisible(false)
    end

    if self.desc_label then
        local label_size = self.desc_label:getContentSize()
        if label_size.height > self.scroll_size.height then
            local add_height = label_size.height - self.scroll_size.height
            add_height = math.min(add_height, 220)
            target_height = target_height + add_height
            self.desc_panel:setContentSize(cc.size(self.desc_panel_size.width, self.desc_panel_size.height + add_height))
        end
    end
    --宝库时间位置
    if self.setting.is_market_place and self.market_time_label then
        local size = self.market_time_label:getContentSize()
        target_height = target_height + size.height + 5
    end
    

    self.container:setContentSize(cc.size(self.container_init_size.width, target_height))
    local y = target_height-4
    self.base_panel:setPositionY(y)
    y = y - self.base_panel:getContentSize().height

    if show_limit_info then
        self.show_limit_y = y - 23
        y = y - 30
    end

    if show_use_desc == true then
        self.usedesc_panel:setPositionY(y - 2) 
        self.desc_panel:setPositionY(self.usedesc_panel:getPositionY()-self.usedesc_panel:getContentSize().height)
    else
        self.desc_panel:setPositionY(y - 2) 
    end
    self.scroll_view:setPositionY(self.desc_panel:getContentSize().height-16)

    self.tab_panel:setPositionY(self.desc_panel:getPositionY()-self.desc_panel:getContentSize().height)

    --宝库时间位置
    if self.setting.is_market_place and self.market_time_label then
        self.market_time_label:setPositionY(self.desc_panel:getPositionY()-self.desc_panel:getContentSize().height + 15)
    end
end

--==============================--
--desc:设置按钮显示
--time:2018-10-22 10:29:52
--@return 
--==============================--
function BackpackTips:updateBtnList()
	--按钮
	if not self.item_config then return end
	local type = self.item_config.type or 0

    for k, object in pairs(self.btn_list) do
        if object.btn then
            object.btn:setVisible(false)
        end
    end

    local tips_btn = {}
    if self.is_special_source then -- 强制显示某一些按钮
        if self.is_special_source == 1 then -- 强制只显示来源
            table_insert(tips_btn, BackPackConst.tips_btn_type.source)
        elseif self.is_special_source == 2 then -- 强制显示神装图鉴
            table_insert(tips_btn, BackPackConst.tips_btn_type.heaven_book)
        end
    else
        tips_btn = self.item_config.tips_btn or {}
    end

    local btn_sum = tableLen(tips_btn)
    if btn_sum == 1 then        -- 如果只有1个按钮,按钮1移到按钮3的位置
        local object_1 = self.btn_list[1]
        local object_3 = self.btn_list[3] 
        if object_1.btn and object_3.btn then
            object_1.btn:setPositionX(object_3.btn:getPositionX())
        end
    end

	local index = 1
	for i, v in ipairs(tips_btn) do
		if index > 3 then break end
        local object = self.btn_list[i]
        if object and object.btn then
			local title = BackPackConst.tips_btn_title[v] or ""
            object.label:setString(title)
            object.btn:setVisible(true)
			object.btn:addTouchEventListener(function(sender, event_type)
				if event_type == ccui.TouchEventType.ended then
					self:clickBtn(v)
				end
			end)
        end
		index = index + 1
	end
	self:checkRedPoint()
end 

--==============================--
--desc:监测红点,不知道干啥的暂时屏蔽掉
--time:2018-10-22 10:44:11
--@return 
--==============================--
function BackpackTips:checkRedPoint()
	-- local artifact_const = Config.PartnerArtifactData.data_artifact_const
	-- if not artifact_const then return end
	-- local bid_list = {}
	-- bid_list[1] = artifact_const["main_shenqi"].val
	-- bid_list[2] = artifact_const["assistant_shenqi"].val
	-- if self.data.bid and self.self.data.bid ~= bid_list[1] and self.self.data.bid ~= bid_list[2] then return end
	-- local bool = false
	-- for i = 1, 2 do
		
	-- 	local config = Config.PartnerArtifactData.data_artifact_data[bid_list[i]]
	-- 	if config and config.compound_expend and config.compound_expend[1] then
	-- 		local bid = config.compound_expend[1] [1]
	-- 		local num = config.compound_expend[1] [2]
	-- 		local count = self.ctrl:getModel():getBackPackItemNumByBid(bid)
	-- 		if count >= num then
	-- 			bool = true
	-- 		end
	-- 	end
	-- end
	-- if bool == false and not self.red_point then
	-- 	return
	-- end
	-- local he_btn
	-- for i, v in pairs(self.btn_list) do
	-- 	if v and v.tips_index and v.tips_index == BackPackConst.tips_btn_type.hecheng2 then
	-- 		he_btn = v
	-- 	end
	-- end
	-- if not he_btn then return end
	-- if not self.red_point then
	-- 	local res = PathTool.getResFrame("common", "common_1014")
	-- 	self.red_point = createImage(nil, res, 112, 39, cc.p(0, 0), true)
	-- 	he_btn:addChild(self.red_point, 10)
	-- end
	-- self.red_point:setVisible(bool)
end 

--==============================--
--desc:设置基础属性
--time:2018-10-22 10:18:13
--@return 
--==============================--
function BackpackTips:setBaseInfo()
    if self.data == nil or self.item_config == nil then return end
    local data = self.data

    self.extend_desc:setString("")
    self.goods_item:setBaseData(self.item_config.id)
    if self.item_config.type == BackPackConst.item_type.HERO_HUN then
        --英魂需要显示多一点ui
        --碎片星数
        self.goods_item:createStar(self.item_config.eqm_jie)
        --显示阵营
        if self.item_config.camp_type ~= 0 then
            self.goods_item:initCamp(self.item_config.camp_type)
        end
    end

    local quality = 0
    if self.item_config.quality >= 0 and self.item_config.quality <= 5 then
        quality = self.item_config.quality
    end
    local color = BackPackConst.quality_color[quality]
    self.name:setTextColor(color) 
    self.name:setString(self.item_config.name)

    self.equip_type:setString(TI18N("类型：")..self.item_config.type_desc)
    if self.item_config.type == 100 then --神装显示星数
        self.goods_item:createStar(self.item_config.eqm_jie)
    end

    if self.item_config.open_type then --祈祷特殊处理神装显示图标
        local icon_res = PathTool.getItemRes(self.item_config.icon)
        self.goods_item:setItemIcon(icon_res)
        self.goods_item:setSelfBackground(self.item_config.quality)
    end

    self.use_desc:setString(self.item_config.use_desc or "")

    -- 描述
    self.desc_label:setString(self.item_config.desc)
    -- self.desc_label:setString("维尔奥古斯丁嘎斯多噶世界观空哦啊所经历的卡估计卡拉是见到过了哭敬斯丁嘎斯多噶世界观空哦啊所经历的卡估计卡拉是见到过了哭敬斯丁嘎斯多噶世界观空哦啊所经历的卡估计卡拉是见到过了哭敬斯丁嘎斯多噶世界观空哦啊所经历的卡估计卡拉是见到过了哭敬爱是考虑到该敬爱是啊见识到了卡估计阿卡是单个阿婶经典款干虑到该敬爱是啊见识到了卡估计阿卡是单个阿婶经典款干虑到该敬爱是啊见识到了卡估计阿卡是单个阿婶经典款干虑到该敬爱是啊见识到了卡估计阿卡是单个阿婶经典款干虑到该敬爱是啊见识到了卡估计阿卡是单个阿婶经典款干辣椒三锻钢戟")
    local label_size = self.desc_label:getContentSize()
    local max_height = math.max(label_size.height, self.scroll_size.height)
    self.scroll_view:setContentSize(cc.size(self.scroll_size.width, math.min(max_height, 320))) -- 600 - 252 - 32
    self.scroll_view:setInnerContainerSize(cc.size(self.scroll_size.width, max_height))
    self.desc_label:setPositionY(max_height)


    --显示公会宝库过期时间
    if self.setting.is_market_place then
        if self.data.end_time and next( self.data.end_time) ~= nil then
            self.market_time_label = createRichLabel(24, cc.c4b(0xff,0x9b,0x1e,0xff), cc.p(0, 1), cc.p(17, -10000), 8, nil, 1000) 
            self.container:addChild(self.market_time_label)
            local time = self.data.end_time[1].end_unixtime or 0
            local count = self.data.end_time[1].end_num or 1
            local str 
            local time = time - GameNet:getInstance():getTime()
            if time < 0 then
                time = 0
            end
            if time <= 0 then
                str = string.format(TI18N("%s个物品已过期"), count)
            else
                str = string.format(TI18N("%s个物品于<div fontcolor=#249003>%s</div>后过期"), count, TimeTool.GetTimeFormatDayIIIIII(time))    
            end 
            self.market_time_label:setString(str)
        end
    end

    self:adjustContentSizeAndPos()

    --过期时间
    if self.data and self.data.expire_time and self.data.expire_time ~=0 then 
        if self.less_timer then 
            GlobalTimeTicket:getInstance():remove(self.less_timer)
            self.less_timer = nil
        end
        local less_time = self.data.expire_time or 0
        less_time = less_time-GameNet:getInstance():getTime()
        local str = ""
        if self.data and self.data.expire_type == 1 or self.data.expire_type == 2 then
            str = TI18N("后过期")
        elseif self.data and self.data.expire_type == 4 or self.data.expire_type == 3 then
            str = TI18N("后可用")
        end
        self.extend_desc:setString(TimeTool.GetTimeFormatDayII(less_time)..str)
        if less_time <=0 then
            self.extend_desc:setString("")
            return
        end
        if not self.less_timer then 
            self.less_timer = GlobalTimeTicket:getInstance():add(function()
                if less_time >=0 then
                    self.extend_desc:setString(TimeTool.GetTimeFormatDayII(less_time)..str)
                else
                    self.extend_desc:setString("")
                end
                less_time = less_time -1
            end,1)
        end
    end

    
end


function BackpackTips:setPanelData()
end

function BackpackTips:close_callback()
    if self.goods_item then 
        self.goods_item:DeleteMe()
    end
   self.goods_item = nil
   if self.less_timer then 
        GlobalTimeTicket:getInstance():remove(self.less_timer)
        self.less_timer = nil
    end
end
