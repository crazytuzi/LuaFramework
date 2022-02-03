--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-11-20 17:10:31
-- @description    : 
		-- 先知殿主界面
---------------------------------
SeerpalaceMainWindow = SeerpalaceMainWindow or BaseClass(BaseView)

local controller = SeerpalaceController:getInstance()
local model = controller:getModel()

function SeerpalaceMainWindow:__init()
	self.win_type = WinType.Full
	self.is_full_screen = true
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("seerpalace", "seerpalace"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_66",true), type = ResourcesType.single },
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_67",true), type = ResourcesType.single },
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_77",false), type = ResourcesType.single },
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_78",false), type = ResourcesType.single },
	}
	self.layout_name = "seerpalace/seerpalace_main_window"
	self.panel_list = {}
	self.tab_list = {}
	self.label_list = {}


	self.role_vo = RoleController:getInstance():getRoleVo()
end

function SeerpalaceMainWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 1)

	self.close_btn = main_container:getChildByName("close_btn")
    self.explain_btn = main_container:getChildByName("explain_btn")
    self.btn_shop = main_container:getChildByName("btn_shop")
    local btn_shop_label = self.btn_shop:getChildByName("label")
    btn_shop_label:setString(TI18N("先知商店"))

    self.btn_gift = main_container:getChildByName("btn_gift")
    local btn_gift_label = self.btn_gift:getChildByName("label")
	btn_gift_label:setString(TI18N("水晶礼包"))
	
	self.btn_score_summons = main_container:getChildByName("btn_score_summons")
	self.btn_score_summons_label = self.btn_score_summons:getChildByName("label")
	self.btn_score_summon_Icon = self.btn_score_summons:getChildByName("icon")
    local item_config = Config.ItemData.data_get_data(SeerpalaceConst.Good_jifen)
    if item_config then
        local res = PathTool.getItemRes(item_config.icon)
        loadSpriteTexture(self.btn_score_summon_Icon, res, LOADTEXT_TYPE)
    end 
	local cur_num = self.role_vo.predict_point
	self.btn_score_summons_label:setString(cur_num)
    self.tips_label = main_container:getChildByName("tips_label")
    self.tips_label:setString(TI18N("随机召唤4~5星英雄或其英雄碎片"))

    local res_layout = main_container:getChildByName("res_layout")
    for i=1,3 do
    	local score_bg = res_layout:getChildByName("score_bg_" .. i)
    	if score_bg then
    		local score_label = score_bg:getChildByName("score_label")
    		local score_image = score_bg:getChildByName("score_image")
    		local cur_num = 0
    		if i == 1 then
    			cur_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(SeerpalaceConst.Good_ZhiHui)
    			local item_config = Config.ItemData.data_get_data(SeerpalaceConst.Good_ZhiHui)
    			if item_config then
    				score_image:loadTexture(PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
    			end
    		elseif i == 2 then
    			cur_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(SeerpalaceConst.Good_XianZhi)
    			local item_config = Config.ItemData.data_get_data(SeerpalaceConst.Good_XianZhi)
    			if item_config then
    				score_image:loadTexture(PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
    			end
    		elseif i == 3 then
    			cur_num = self.role_vo.recruithigh_hero
    			local item_config = Config.ItemData.data_get_data(SeerpalaceConst.Good_JieJing)
    			if item_config then
    				score_image:loadTexture(PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
    			end
    		end
    		score_label:setString(cur_num)
    		self.label_list[i] = score_label
    	end
    end

    local tab_container = main_container:getChildByName("tab_container")

    local tab_name_list = {
        [1] = TI18N("先知圣殿"),
        [2] = TI18N("英雄转换")
    }
    for i=1,2 do
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.unselect_bg:setVisible(true)
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            -- object.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
            object.lable = tab_btn:getChildByName("title")
            object.lable:setString(tab_name_list[i])
            object.tab_btn = tab_btn
            object.index = i
            self.tab_list[i] = object
        end
    end

	self.container = main_container:getChildByName("container")

	-- 适配
	local top_off = display.getTop(main_container)
    local container_size = main_container:getContentSize()

    tab_container:setPositionY(top_off - 143)
    self.tips_label:setPositionY(top_off - 190)
    res_layout:setPositionY(top_off - 143)
    self.explain_btn:setPositionY(top_off - 143)
    
    local tab_y = self.btn_shop:getPositionY()
    self.btn_shop:setPositionY(top_off - (container_size.height - tab_y))
    local tab_y = self.btn_gift:getPositionY()
	self.btn_gift:setPositionY(top_off - (container_size.height - tab_y))
	local tab_y = self.btn_score_summons:getPositionY()
	self.btn_score_summons:setPositionY(top_off - (container_size.height - tab_y))
end

function SeerpalaceMainWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), nil, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
    registerButtonEventListener(self.btn_shop, handler(self, self._onClickShopBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
	registerButtonEventListener(self.btn_gift, handler(self, self._onClickGiftBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
	registerButtonEventListener(self.btn_score_summons, handler(self, self._onScoreSummonBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    registerButtonEventListener(self.explain_btn, function(param,sender, event_type)
        local config
        if self.tab_object.index == 1 then
            config = Config.RecruitHighData.data_seerpalace_const.game_rule1
        else
            config = Config.RecruitHighData.data_seerpalace_const.game_rule2
        end
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
    end ,true, 2)

	for k, object in pairs(self.tab_list) do
		if object.tab_btn then
			object.tab_btn:addTouchEventListener(function(sender, event_type)
				if event_type == ccui.TouchEventType.ended then
					playTabButtonSound()
					self:changeSelectedTab(object.index)
				end
			end)
		end
    end

    -- 道具数量更新
    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code, data_list)
		self:refreshGoodNums(bag_code, data_list)
	end)
	self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code, data_list)
		self:refreshGoodNums(bag_code, data_list)
	end)
	self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, data_list)
		self:refreshGoodNums(bag_code, data_list)
	end)
	

    -- 积分资产更新
    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "recruithigh_hero" and self.label_list[3] then
					self.label_list[3]:setString(value)
				elseif key == "predict_point" and self.btn_score_summons_label then
					self.btn_score_summons_label:setString(value)
					self:updateBtnRed()
				elseif key == "vip_lev" then
					self:updateBtnRed()
                end
            end)
        end
    end
    -- VIP特权礼包
    self:addGlobalEvent(VipEvent.PRIVILEGE_INFO, function ( )
        self:initBtnGift()
    end)
end

-- 道具数量刷新
function SeerpalaceMainWindow:refreshGoodNums( bag_code, data_list )
	if bag_code == BackPackConst.Bag_Code.BACKPACK then
		for i,v in pairs(data_list) do
			if v and v.base_id then
				if v.base_id == SeerpalaceConst.Good_ZhiHui and self.label_list[2] then
					local cur_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(SeerpalaceConst.Good_ZhiHui)
					self.label_list[1]:setString(cur_num)
				elseif v.base_id == SeerpalaceConst.Good_XianZhi and self.label_list[3] then
					local cur_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(SeerpalaceConst.Good_XianZhi)
					self.label_list[2]:setString(cur_num)
				end
			end
		end
	end
end

-- 切换标签页
function SeerpalaceMainWindow:changeSelectedTab( index )
	if self.tab_object ~= nil and self.tab_object.index == index then return end
	if index == SeerpalaceConst.Tab_Index.Summon then --先知召唤界面显示积分召唤其他不显示
		self.btn_score_summons:setVisible(true)
		SeerpalaceController:getInstance():requestSummonOpen()
	else
		self.btn_score_summons:setVisible(false)
	end
    
    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object = nil
    end
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
    end

	if index == SeerpalaceConst.Tab_Index.Summon then
		self.tips_label:setVisible(true)
		self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_66",true), LOADTEXT_TYPE)
	elseif index == SeerpalaceConst.Tab_Index.Change then
		self.tips_label:setVisible(false)
		self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_67",true), LOADTEXT_TYPE)
	end

	if self.select_panel then
		self.select_panel:addToParent(false)
		self.select_panel = nil
	end
	self.select_panel = self.panel_list[index]
	if self.select_panel == nil then
		if index == SeerpalaceConst.Tab_Index.Summon then
			self.select_panel = SeerpalaceSummonPanel.new()
		elseif index == SeerpalaceConst.Tab_Index.Change then
			self.select_panel = SeerpalaceChangePanel.new()
		end
		if self.select_panel then
			self.container:addChild(self.select_panel)
			self.panel_list[index] = self.select_panel
		end
	end
	if self.select_panel then
		self.select_panel:addToParent(true)
	end
end

function SeerpalaceMainWindow:openRootWnd( index )
	index = index or SeerpalaceConst.Tab_Index.Summon
	self:changeSelectedTab(index)
	self:initBtnGift()
	self:updateBtnRed()
end

function SeerpalaceMainWindow:updateBtnRed()
	if self.btn_score_summons then
		addRedPointToNodeByStatus(self.btn_score_summons, model:getScoreSummonRed())
	end
end

function SeerpalaceMainWindow:initBtnGift()
    local id = 101 --先知礼包的id  一般不会改了.改了这里跳转也要跟着改 --by lwc
    local privilege = VipController:getInstance():getModel():getPrivilegeDataById(id)
	if privilege and privilege.status == 1 then
		self.btn_score_summons:setPositionY(self.btn_gift:getPositionY())
        self.btn_gift:setVisible(false)
    end
end

-----------------@ 按钮点击事件
-- 关闭
function SeerpalaceMainWindow:_onClickCloseBtn(  )
	controller:openSeerpalaceMainWindow(false)
end

-- 商店
function SeerpalaceMainWindow:_onClickShopBtn(  )
    controller:openSeerpalaceShopWindow(true)
end

-- 商店
function SeerpalaceMainWindow:_onClickGiftBtn(  )
	JumpController:getInstance():jumpViewByEvtData({7, VIPTABCONST.PRIVILEGE})
end

-- 积分召唤
function SeerpalaceMainWindow:_onScoreSummonBtn(  )
	controller:openSeerpalaceSummonScoreWindow(true)
end

function SeerpalaceMainWindow:close_callback(  )
	for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
    self.panel_list = nil

    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end

    controller:openSeerpalaceMainWindow(false)
end