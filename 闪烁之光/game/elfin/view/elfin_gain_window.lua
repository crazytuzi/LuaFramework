--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-08-13 21:46:40
-- @description    : 
		-- 获得精灵界面
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

ElfinGainWindow = ElfinGainWindow or BaseClass(BaseView)

function ElfinGainWindow:__init()
	self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "elfin/elfin_gain_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("elfin", "elfin"), type = ResourcesType.plist},
	}
end

function ElfinGainWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)
	self.con_size = self.container:getContentSize()

	self.cancel_btn = self.container:getChildByName("cancel_btn")
	self.cancel_btn:getChildByName("label"):setString(TI18N("关  闭"))
	self.confirm_btn = self.container:getChildByName("confirm_btn")
	self.confirm_btn:getChildByName("label"):setString(TI18N("前往查看"))

	self.quality_icon = self.container:getChildByName("quality_icon")
	self.quality_txt = self.container:getChildByName("quality_txt")
	self.elfin_name_txt = self.container:getChildByName("elfin_name_txt")
	self.elfin_desc_txt = self.container:getChildByName("elfin_desc_txt")
	self.container:getChildByName("score_title"):setString(TI18N("评分："))
	self.power_label = CommonNum.new(1, self.container, 1, - 2, cc.p(0, 0))
    self.power_label:setPosition(cc.p(630, 223))
    self.power_label:setNum(0)
	self.power_label:setScale(0.8)
end

function ElfinGainWindow:register_event(  )
	registerButtonEventListener(self.cancel_btn, handler(self, self.onClickCloseBtn), true)

	registerButtonEventListener(self.confirm_btn, handler(self, self.onClickCheckBtn), true)
end

function ElfinGainWindow:onClickCloseBtn(  )
	_controller:openElfGainWindow(false)
end

-- 前往查看
function ElfinGainWindow:onClickCheckBtn(  )
	MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.backpack, BackPackConst.item_tab_type.ELFIN)
	_controller:openElfGainWindow(false)
end

function ElfinGainWindow:openRootWnd( data )
	playOtherSound("c_get")
	self:handleTopEffect(true)
	self:setData(data)
end

function ElfinGainWindow:setData( data )
	if not data then return end

	local elfin_cfg
	local elfin_name = ""
	local elfin_quality = 0
	local elfin_desc = ""
	local extra_awards = {}
	for k,v in pairs(data) do
		local item_cfg = Config.ItemData.data_get_data(v.item_bid)
		if item_cfg then
			if BackPackConst.checkIsElfin(item_cfg.type) then
				elfin_name = item_cfg.name
				elfin_quality = item_cfg.quality
				elfin_desc = item_cfg.use_desc
				elfin_cfg = Config.SpriteData.data_elfin_data(v.item_bid)
			else
				local item_info = {}
				item_info.item_num = v.item_num
				item_info.item_cfg = item_cfg
				_table_insert(extra_awards, item_info)
			end
		end
	end

	-- 特点
	if elfin_desc and elfin_desc ~= "" then
		self.elfin_desc_txt:setString(elfin_desc)
	end

	-- 地板特效
	self:showBottomEffect(true, elfin_quality)

	-- 精灵
	if elfin_cfg then
		if self.power_label then
			self.power_label:setNum(elfin_cfg.power)
		end
		
		-- 延迟一点时间创建精灵
		delayRun(
            self.container, 0.3, function()
                local effect_id = elfin_cfg.effect_id or "E70001"
				if not self.elfin_spine then
					local offset_y = tonumber(elfin_cfg.offset_y) or 0
					self.elfin_spine = createEffectSpine( effect_id, cc.p(self.con_size.width*0.5, self.con_size.height*0.5-45+offset_y), cc.p(0.5, 0.5), false, PlayerAction.action_1, handler(self, self.onAniEndCallBack) )
					self.container:addChild(self.elfin_spine)
				end
				if elfin_cfg.scale_val and elfin_cfg.scale_val > 0 then
					self.elfin_spine:setScale(elfin_cfg.scale_val)
				end
            end
        )
	end

	self.elfin_name_txt:setString(elfin_name)
	self.elfin_name_txt:setTextColor(BackPackConst.getBlackQualityColorC4B(elfin_quality))
	self.elfin_desc_txt:setTextColor(BackPackConst.getBlackQualityColorC4B(elfin_quality))
	if ElfinConst.Elfin_Quality_Res[elfin_quality] then
		local quality_res = PathTool.getResFrame("elfin", ElfinConst.Elfin_Quality_Res[elfin_quality])
		self.quality_icon:loadTexture(quality_res, LOADTEXT_TYPE_PLIST)
	end
	if ElfinConst.Elfin_Quality_Name[elfin_quality] then
		self.quality_txt:setString(ElfinConst.Elfin_Quality_Name[elfin_quality])
		if ElfinConst.Elfin_Quality_Outline[elfin_quality] then
			self.quality_txt:enableOutline(ElfinConst.Elfin_Quality_Outline[elfin_quality], 2)
		end
	end

	-- 额外奖励
	if extra_awards and next(extra_awards) ~= nil then
		if not self.extra_txt then
			self.extra_txt = createRichLabel(24, cc.p(255,232,183,255), cc.p(0.5, 0.5), cc.p(360, 32))
			self.container:addChild(self.extra_txt)
		end
		local txt_str = TI18N("<div fontcolor=#ffe8b7>同时获得</div>")
		for i,item_info in ipairs(extra_awards) do
			local item_res = PathTool.getItemRes(item_info.item_cfg.icon)
			txt_str = txt_str .. _string_format("<div fontcolor=#ffe8b7>+</div> <img src='%s' scale=0.3 /> <div fontcolor=#ffe8b7>%d</div>", item_res, item_info.item_num)
		end
		self.extra_txt:setString(txt_str)
	end
end

function ElfinGainWindow:onAniEndCallBack(  )
	if not self.ani_flag and self.elfin_spine then
		self.ani_flag = true
		self.elfin_spine:setToSetupPose()
	    self.elfin_spine:setAnimation(0, PlayerAction.stand, true)
	end
end

-- 顶部孵化成功特效
function ElfinGainWindow:handleTopEffect( status )
	if status == false then
		if self.top_effect then
			self.top_effect:clearTracks()
			self.top_effect:removeFromParent()
			self.top_effect = nil
		end
    else
        if not tolua.isnull(self.container) and self.top_effect == nil then
            self.top_effect = createEffectSpine(Config.EffectData.data_effect_info[1352], cc.p(self.con_size.width*0.5, 410), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.container:addChild(self.top_effect)
        end
    end
end

-- 底盘特效
function ElfinGainWindow:showBottomEffect( status, quality )
	if status == false then
        if self.bottom_effect then
            self.bottom_effect:clearTracks()
            self.bottom_effect:removeFromParent()
            self.bottom_effect = nil
        end
    else
    	local action = PlayerAction.action_1
    	quality = quality or 0
    	if quality >= BackPackConst.quality.orange then
    		action = PlayerAction.action_3
    	elseif quality == BackPackConst.quality.purple then
    		action = PlayerAction.action_2
    	end
        if not tolua.isnull(self.container) and self.bottom_effect == nil then
            self.bottom_effect = createEffectSpine(Config.EffectData.data_effect_info[1354], cc.p(self.con_size.width*0.5, 110), cc.p(0.5, 0), true, action)
            self.container:addChild(self.bottom_effect)
        end
    end
end

function ElfinGainWindow:close_callback(  )
	doStopAllActions(self.container)
	if self.power_label then
        self.power_label:DeleteMe()
        self.power_label = nil
	end

	if self.elfin_spine then
		self.elfin_spine:clearTracks()
		self.elfin_spine:removeFromParent()
		self.elfin_spine = nil
	end
	self:handleTopEffect(false)
	self:showBottomEffect(false)
	_controller:openElfGainWindow(false)
end