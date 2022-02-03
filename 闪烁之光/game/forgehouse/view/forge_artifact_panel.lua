--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-15 17:41:24
-- @description    : 
		-- 符文锻造
---------------------------------
ForgeArtifactPanel = class("ForgeArtifactPanel", function()
    return ccui.Widget:create()
end)

local _table_insert = table.insert
local _table_sort = table.sort
local _string_format = string.format

function ForgeArtifactPanel:ctor()
	self.artifact_items = {}
	self.com_artifact_id = 0 -- 当前合成的符文bid(0为未选择)
	self.chose_item_list = {} -- 当前已选择的符文id
	self.is_show_effect = false -- 是否正在播放合成特效
	self.cur_auto_num = SysEnv:getInstance():getNum(SysEnv.keys.forge_artifact_num, 5)  -- 一键合成时添加的符文数量

    self:layoutUI()
    self:registerEvents()
    self:updataZhufuInfo()
end

function ForgeArtifactPanel:registerEvents(  )
	registerButtonEventListener(self.skill_btn, handler(self, self._onClickSkillBtn))
	registerButtonEventListener(self.explain_btn, handler(self, self._onClickExplainBtn))
	registerButtonEventListener(self.quick_add_btn, handler(self, self._onClickQuickAddBtn))
	registerButtonEventListener(self.compound_btn, handler(self, self._onClickCompoundBtn))
	registerButtonEventListener(self.get_zhufu, handler(self, self._onClickGetZhufu))

	registerButtonEventListener(self.btn_redu, function (  )
		self:onChangeAutoForgeNum(1)
	end, true)

	registerButtonEventListener(self.btn_add, function (  )
		self:onChangeAutoForgeNum(2)
	end, true)

	-- 祝福值更新
	if not self.lucky_update_evt then
        self.lucky_update_evt = GlobalEvent:getInstance():Bind(HeroEvent.Artifact_Lucky_Event, function( )
            self:updataZhufuInfo()
        end)
    end

    -- 合成操作成功
    if not self.compound_update_evt then
    	self.compound_update_evt = GlobalEvent:getInstance():Bind(HeroEvent.Artifact_Compound_Event, function( flag )
            self.com_artifact_id = 0 
			self.chose_item_list = {}
			self:updateChoseArtifactItems()
        end)
    end

    -- 选择符文返回
    if not self.chose_update_evt then
    	self.chose_update_evt = GlobalEvent:getInstance():Bind(HeroEvent.Artifact_Chose_Event, function ( item_list )
    		self.chose_item_list = item_list
			self:updateChoseArtifactItems()
    	end)
    end
end

-- 增加/减少一键添加的数量 flag:1减少 否则增加
function ForgeArtifactPanel:onChangeAutoForgeNum( flag )
	if flag == 1 then
		self.cur_auto_num = self.cur_auto_num - 1
		self.num_txt:setString(self.cur_auto_num)
	else
		self.cur_auto_num = self.cur_auto_num + 1
		self.num_txt:setString(self.cur_auto_num)
	end
	if self.cur_auto_num <= 2 then
		self.btn_redu:setTouchEnabled(false)
		setChildUnEnabled(true, self.btn_redu)
	elseif self.cur_auto_num >= 5 then
		self.btn_add:setTouchEnabled(false)
		setChildUnEnabled(true, self.btn_add)
	else
		self.btn_redu:setTouchEnabled(true)
		setChildUnEnabled(false, self.btn_redu)
		self.btn_add:setTouchEnabled(true)
		setChildUnEnabled(false, self.btn_add)
	end
end

function ForgeArtifactPanel:layoutUI(  )
	self.size = cc.size(720, 1280)
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0,0))

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("forgehouse/forge_artifact_panel"))
	self.root_wnd:setPosition(0, 0)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)

	self.main_container = self.root_wnd:getChildByName("main_container")

	self.skill_btn = self.main_container:getChildByName("skill_btn")
	self.rate_txt = self.main_container:getChildByName("rate_txt")
	self.rate_txt:setVisible(false)
	self.level_txt = self.main_container:getChildByName("level_txt")
	self.level_txt:setVisible(false)
	self.explain_btn = self.main_container:getChildByName("explain_btn")
	self.quick_add_btn = self.main_container:getChildByName("quick_add_btn")
	self.quick_add_btn:getChildByName("label"):setString(TI18N("一键添加"))
	self.compound_btn = self.main_container:getChildByName("compound_btn")
	self.compound_btn:getChildByName("label"):setString(TI18N("合成"))
	self.btn_redu = self.main_container:getChildByName("btn_redu")
	self.btn_add = self.main_container:getChildByName("btn_add")
	self.num_txt = self.main_container:getChildByName("num_txt")
	self.num_txt:setString(self.cur_auto_num)
	if self.cur_auto_num <= 2 then
		self.btn_redu:setTouchEnabled(false)
		setChildUnEnabled(true, self.btn_redu)
	elseif self.cur_auto_num >= 5 then
		self.btn_add:setTouchEnabled(false)
		setChildUnEnabled(true, self.btn_add)
	end

	local tips_txt = self.main_container:getChildByName("tips_txt")
	tips_txt:setString(TI18N("同类低阶符文可合成高阶符文"))

	-- 消耗材料显示
	local temp_pos_x = self.rate_txt:getPositionX()
	local temp_pos_y = self.rate_txt:getPositionY() 
	self.cost_txt = createRichLabel(20, 273, cc.p(0.5, 1), cc.p(temp_pos_x, temp_pos_y - 16))
	self.main_container:addChild(self.cost_txt) 

	-- 祝福相关
	local zhufu_title = self.main_container:getChildByName("zhufu_title")
	zhufu_title:setString(TI18N("熔炼值"))
	self.zhufu_txt = self.main_container:getChildByName("zhufu_txt")
	self.get_zhufu = self.main_container:getChildByName("get_zhufu")
	self.zhufu_tips = self.main_container:getChildByName("zhufu_tips")
	local zhufu_icon = self.main_container:getChildByName("zhufu_icon")
	local gift_cfg = Config.PartnerArtifactData.data_artifact_const["change_gift"]
	if gift_cfg then
		local bid = gift_cfg.val[1][1]
		if bid then
			loadSpriteTexture(zhufu_icon, PathTool.getItemRes(bid), LOADTEXT_TYPE)
		end
	end

	self.progress_panel = self.main_container:getChildByName("progress_panel")
	self.progress_bar = cc.ProgressTimer:create(createSprite(PathTool.getResFrame("artifact","artifact_1002"), 0, 0, nil, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST))
    self.progress_bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.progress_bar:setMidpoint(cc.p(0.5, 0))
    self.progress_bar:setBarChangeRate(cc.p(0, 1))
    self.progress_bar:setAnchorPoint(cc.p(0, 0))
    self.progress_bar:setPosition(cc.p(0, 0))
    self.progress_bar:setPercentage(0)
    self.progress_panel:addChild(self.progress_bar)
    self:handleProgressEffect(true)

	self.pos_node = self.main_container:getChildByName("pos_node")

	for i=1,5 do
		delayRun(self.main_container, i*4/60, function ()
			local pos_node = self.main_container:getChildByName("pos_node_" .. i)
			local item = BackPackItem.new(false, true, false, nil, true, false)
			item:addCallBack(handler(self, self._onClickItemCallBack))
			item:showAddIcon(true)
			item:setIsShowBackground(false)
			pos_node:addChild(item)
			self.artifact_items[i] = item
		end)
	end
end

function ForgeArtifactPanel:_onClickItemCallBack(  )
	local param = {}
	param.bid = self.com_artifact_id
    param.max_num = 5
    param.chose_list = self.chose_item_list or {}
    HeroController:getInstance():openArtifactChoseWindow(true, param)
end

-- 合成成功的特效
function ForgeArtifactPanel:handleComEffect( status )
	if status == true then
		-- AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON, "c_equipment_forging")
		self.is_show_effect = true
		if not tolua.isnull(self.pos_node) and self.com_effect == nil then
            self.com_effect = createEffectSpine(Config.EffectData.data_effect_info[661], cc.p(0, 0), cc.p(0.5, 0.5), false, PlayerAction.action, handler(self, self.requestCompoundArtifact))
            self.pos_node:addChild(self.com_effect)
        elseif self.com_effect then
        	self.com_effect:setToSetupPose()
        	self.com_effect:setAnimation(0, PlayerAction.action, false)
        end
	else
		if self.com_effect then
            self.com_effect:clearTracks()
            self.com_effect:removeFromParent()
            self.com_effect = nil
        end
	end
end

-- 刷新选择的符文
function ForgeArtifactPanel:updateChoseArtifactItems(  )
	self.com_artifact_id = 0
	for i,item in ipairs(self.artifact_items) do
		local id = self.chose_item_list[i]
		if id then
			local item_data = BackpackController:getModel():getBackPackItemById(id)
			if item_data then
				if self.com_artifact_id == 0 then
					local artifact_cfg = Config.PartnerArtifactData.data_artifact_data[item_data.config.id]
					self.com_artifact_id = artifact_cfg.com_artifact
				end
				item:setData(item_data)
				if not item.chose_effect then
					item.chose_effect = createEffectSpine(Config.EffectData.data_effect_info[662], cc.p(BackPackItem.Width/2, BackPackItem.Height/2), cc.p(0.5, 0.5), true, PlayerAction.action)
					item:addChild(item.chose_effect)
				end
				item.chose_effect:setVisible(true)
				item:showAddIcon(false)
			else
				item:setData({})
				item:showAddIcon(true)
				if item.chose_effect then
					item.chose_effect:setVisible(false)
				end
			end
		else
			item:setData({})
			item:showAddIcon(true)
			if item.chose_effect then
				item.chose_effect:setVisible(false)
			end
		end
	end

	-- 目标符文
	if not self.target_item then
		self.target_item = BackPackItem.new(false, true, false, nil, true, false)
		self.target_item:addCallBack(handler(self, self._onClickTargetCallBack))
		self.target_item:setIsShowBackground(false)
		self.pos_node:addChild(self.target_item)
	end
	if self.com_artifact_id ~= 0 then
		self.target_item:setBaseData(self.com_artifact_id)
		local art_com_cfg = Config.PartnerArtifactData.data_artifact_compound[self.com_artifact_id]
		local art_base_cfg = Config.PartnerArtifactData.data_artifact_data[self.com_artifact_id]
		local role_vo = RoleController:getInstance():getRoleVo()
		if art_com_cfg and art_com_cfg[#self.chose_item_list] then
			local rate = art_com_cfg[#self.chose_item_list].rate or 0
			self.rate_txt:setString(TI18N("成功率 ") .. rate/10 .. "%")
			self.rate_txt:setTextColor(cc.c3b(112, 206, 50))
			self.rate_txt:setVisible(true)

			-- 设置消耗
			self:updateCostInfo(art_com_cfg[#self.chose_item_list].other_expend)
		else
			self.rate_txt:setTextColor(cc.c3b(206, 164, 120))
			self.rate_txt:setString(TI18N("需2个同类符文"))
			self.rate_txt:setVisible(true)
			self.cost_txt:setVisible(false)
		end
		if art_base_cfg and art_base_cfg.limit_lv > role_vo.lev then
			self.level_txt:setString(_string_format(TI18N("需达到%d级"), art_base_cfg.limit_lv))
			self.level_txt:setVisible(true)
			self.cost_txt:setVisible(false)
		else
			self.level_txt:setVisible(false)
		end
	else
		self.target_item:setData({})
		self.rate_txt:setVisible(false)
		self.level_txt:setVisible(false)
		self.cost_txt:setVisible(false)
	end
end

function ForgeArtifactPanel:updateCostInfo(expend)
	if expend == nil or next(expend) == nil then return end
	self.cost_txt:setVisible(true)
	local str = ""
	for i,v in ipairs(expend) do
		local bid = v[1]
		local num = v[2]
		local item_config = Config.ItemData.data_get_data(bid)
		if item_config then
			if str ~= "" then
				str = str..","
			end
			str = string.format("%s<img src='%s' scale=0.3 />%s", str, PathTool.getItemRes(item_config.icon), MoneyTool.GetMoneyString(num))
		end
	end
	self.cost_txt:setString(TI18N("     消耗\n")..str)
end

-- 祝福值刷新
function ForgeArtifactPanel:updataZhufuInfo(  )
	local cur_lucky = HeroController:getInstance():getModel():getArtifactLucky()
	local max_lucky = 0
	local lucky_cfg = Config.PartnerArtifactData.data_artifact_const["change_condition"]
	if lucky_cfg and lucky_cfg.val then
		max_lucky = lucky_cfg.val
	end
	local percent = cur_lucky/max_lucky*100
	self.progress_bar:setPercentage(percent)
	self.zhufu_txt:setString(cur_lucky)

	local red_status = HeroController:getInstance():getModel():getArtifactLuckyRedStatus()
	self.zhufu_tips:setVisible(red_status)

	-- 特效位置
	if self.progress_effect then
		local pos_y = percent/100*324
		if pos_y < 3 then
			pos_y = 3
		end
		self.progress_effect:setPositionY(pos_y)
	end
end

-- 进度条特效
function ForgeArtifactPanel:handleProgressEffect( status )
	if status == false then
        if self.progress_effect then
            self.progress_effect:clearTracks()
            self.progress_effect:removeFromParent()
            self.progress_effect = nil
        end
    else
        if not tolua.isnull(self.progress_panel) and self.progress_effect == nil then
            self.progress_effect = createEffectSpine(Config.EffectData.data_effect_info[660], cc.p(24.5, 0), cc.p(0, 1), true, PlayerAction.action)
            self.progress_panel:addChild(self.progress_effect)
        end
    end
end

-- 点击目标符文
function ForgeArtifactPanel:_onClickTargetCallBack(  )
	if self.com_artifact_id ~= 0 then
		HeroController:getInstance():openArtifactComTipsWindow(true, self.com_artifact_id)
	end
end

-- 点击技能展示按钮
function ForgeArtifactPanel:_onClickSkillBtn(  )
	HeroController:getInstance():openArtifactSkillWindow(true)
end

-- 规则说明
function ForgeArtifactPanel:_onClickExplainBtn( param, sender )
	local config = Config.PartnerArtifactData.data_artifact_const.artifact_rule
    if config then
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
    end
end

-- 一键添加
function ForgeArtifactPanel:_onClickQuickAddBtn(  )
	local all_item_data = BackpackController:getInstance():getModel():getBackPackItemListByType(BackPackConst.item_type.ARTIFACTCHIPS)
	-- 按照品质从低到高排序
	_table_sort(all_item_data, SortTools.tableLowerSorter({"quality", "id"}))
	local qua_item_list = {} -- 按照品质存
	for i, vo in pairs(all_item_data) do
		if not qua_item_list[vo.quality] then
			qua_item_list[vo.quality] = {}
			qua_item_list[vo.quality].quality = vo.quality
			qua_item_list[vo.quality].bid = vo.config.id
		end
	end
	local add_flag = false
	for i = 0, BackPackConst.quality.red do
		if qua_item_list[i] then
			local bid = qua_item_list[i].bid
			local art_base_cfg = Config.PartnerArtifactData.data_artifact_data[bid]
			if art_base_cfg and art_base_cfg.com_artifact ~= 0 then
				local target_cfg = Config.PartnerArtifactData.data_artifact_data[art_base_cfg.com_artifact]
				local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
				-- 背包中数量满足合成条件
				if target_cfg and have_num >= target_cfg.limit_num then
					local all_use_item = BackpackController:getInstance():getModel():getBackPackItemIdListByBid(bid)
					if not add_flag then -- 把最低品质的满足最低合成条件的保存一下，可能出现所有品质都不满足玩家选择数量的情况，这时选择最低品质满足最低合成条件的
						add_flag = true
						self.chose_item_list = all_use_item
					end
					-- 大于等于玩家选择的数量
					if have_num >= self.cur_auto_num then
						self.chose_item_list = {}
						if have_num > self.cur_auto_num then
							for i,id in ipairs(all_use_item) do
								if i <= self.cur_auto_num then
									_table_insert(self.chose_item_list, id)
								else
									break
								end
							end
						else
							self.chose_item_list = all_use_item
						end
						break
					end
				end
			end
		end
	end

	if next(self.chose_item_list) == nil then
		message(TI18N("暂无可作为材料的符文"))
	else
		self:updateChoseArtifactItems()
	end
end

-- 合成
function ForgeArtifactPanel:_onClickCompoundBtn(  )
	if self.is_show_effect == true then return end
	if self.com_artifact_id == 0 or next(self.chose_item_list) == nil then
		message(TI18N("请先放入合成材料"))
	elseif #self.chose_item_list < 2 then
		message(TI18N("至少需要放入2个同类符文"))
	else
		--10455是闪烁符文的id 策划要求如果合成闪烁符文的要拦截数量不足5个的 --by lwc
		if self.com_artifact_id == 10455 and #self.chose_item_list < 5 then
			local str = TI18N("当前所放置材料高级符文不足5个，继续合成将有概率失败，是否确定合成？")                
            CommonAlert.show( str, TI18N("确定"), function()
               self:handleComEffect(true)
            end, TI18N("取消"))
        else
        	self:handleComEffect(true)
		end
		
	end
end

-- 请求合成协议(特效播放完毕)
function ForgeArtifactPanel:requestCompoundArtifact(  )
	local expends = {}
	for k,id in pairs(self.chose_item_list) do
		local temp = {}
		temp.artifact_id = id
		_table_insert(expends, temp)
	end
	HeroController:getInstance():sender11036( self.com_artifact_id, expends )
	self.is_show_effect = false
end

-- 领取祝福奖励
function ForgeArtifactPanel:_onClickGetZhufu(  )
	HeroController:getInstance():openArtifactAwardWindow(true)
end

function ForgeArtifactPanel:DeleteMe(  )
	-- 与本地缓存不一致时才写入本地
	if SysEnv:getInstance():getNum(SysEnv.keys.forge_artifact_num) ~= self.cur_auto_num then
		SysEnv:getInstance():set(SysEnv.keys.forge_artifact_num, self.cur_auto_num)
	end

	local artifact_count_tips = RoleEnv:getInstance():getStr(RoleEnv.keys.artifact_count_tips)
	local timeStr = os.date("%m_%d")
	if artifact_count_tips ~= timeStr then
		RoleEnv:getInstance():set(RoleEnv.keys.artifact_count_tips, timeStr, true) 	
	end
	PromptController:getInstance():getModel():removePromptDataByTpye(PromptTypeConst.Artifact_Count_tips)
	
    

	for k,item in pairs(self.artifact_items) do
		if item.chose_effect then
			item.chose_effect:clearTracks()
            item.chose_effect:removeFromParent()
            item.chose_effect = nil
		end
		item:DeleteMe()
		item = nil
	end
	self:handleComEffect(false)
	self:handleProgressEffect(false)
	if self.target_item then
		self.target_item:DeleteMe()
		self.target_item = nil
	end
	if self.lucky_update_evt then
		GlobalEvent:getInstance():UnBind(self.lucky_update_evt)
        self.lucky_update_evt = nil
	end
	if self.compound_update_evt then
		GlobalEvent:getInstance():UnBind(self.compound_update_evt)
        self.compound_update_evt = nil
	end
	if self.chose_update_evt then
		GlobalEvent:getInstance():UnBind(self.chose_update_evt)
		self.chose_update_evt = nil
	end
end
