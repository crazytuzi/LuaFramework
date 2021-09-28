LianXuChongZhi = LianXuChongZhi or BaseClass(BaseRender)

SLIDER_LENGTH = 778
local ITEM_COUNT = 4
function LianXuChongZhi:__init()
	self.display = self:FindObj("Display")
	self.model = RoleModel.New("zhongqiulianchong_panel")

	self.model:SetDisplay(self.display.ui3d_display)
	self.lianchongchu_day = self:FindVariable("lianchongchu_day")
	self.lianchongchu_name = self:FindVariable("lianchongchu_name")
	self.lianchongchu_zhanli = self:FindVariable("lianchongchu_zhanli")
	self.today_coin_chu = self:FindVariable("today_coin_chu")
	self.day_res = self:FindVariable("day_image")
	self.type_res = self:FindVariable("type_image")
	self.reward_parent = self:FindObj("RewardList")
	self.show_button_lq = self:FindVariable("show_lingqu")
	self.show_button_cz = self:FindVariable("show_chongzhi")
	self.show_yilingqu = self:FindVariable("show_yilingqu")
	self.show_yilingqu:SetValue(false)
	self.slider_num = self:FindVariable("slider_num")
	self.gold_num = self:FindVariable("need_gold")
	self.is_show_effect = self:FindVariable("show_effect")
	self.is_show_effect:SetValue(false)
	self:ListenEvent("button_lingqu", BindTool.Bind(self.OnClickLingQu, self))
	self:ListenEvent("button_chongzhi", BindTool.Bind(self.OnClickChongZhi, self))
	self.isfoot = false
	self.cell_list = {}
	self.select_index = 1
	self:InitRewardList()   
	self:InitSlider()    --下方条
	self:FlushModel()
end

function LianXuChongZhi:__delete()
	self:CancelCountDown()
	self.lianchongchu_day = nil
	self.gold_num = nil
	self.lianchongchu_name = nil
	self.lianchongchu_zhanli = nil
	self.today_coin_chu = nil
	self.day_res = nil
	self.type_res = nil
	self.reward_parent = nil
	self.select_index = nil
	self.slider_cell_list = nil
	self.show_item_reward = nil
    self.is_show_effect = nil
    self.show_yilingqu = nil

	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end

    self.cell_list = nil	
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function LianXuChongZhi:OpenCallBack()
    self:Flush()
end

function LianXuChongZhi:ReleaseCallBack()

end

function LianXuChongZhi:InitSlider()
	self.slider_cell_list = {}
	local zhongqiulianchong_cfg = FestivalActivityData.Instance:ZhongQiuLianXuChongZhiCfg()
	if not zhongqiulianchong_cfg then 
	    return 
	end

	local num = self:GetCfgNum() or 0
	PrefabPool.Instance:Load(AssetID("uis/views/festivalactivity/autumn_prefab", "LianChong_Reward_Item"),
	function(prefab)
		if not prefab then
			return
		end

		for i = 1,num do
			local obj = GameObject.Instantiate(prefab)
			obj.transform:SetParent(self.reward_parent.transform, false)
			obj.transform:SetLocalPosition(SLIDER_LENGTH / num * i, 0 ,0)
			obj = U3DObject(obj)
			local item = AutumnSliderCell.New(obj)			
	        local data_group = zhongqiulianchong_cfg[i]
            if not data_group then 
            	PrefabPool.Instance:Free(prefab)
			    return 
			end           

	        item.parent_view = self
	        if i < num then 
	        	item:SetData(data_group.reward_item) --其他显示限时礼包
	        else
	        	local data_id = data_group.reward_item.item_id or 0
	            local data_list = ItemData.Instance:GetGiftItemList(data_id)  
                if not data_list then 
                   PrefabPool.Instance:Free(prefab)
			       return 
			    end

                item:SetData(data_list[1])  --最后的奖励显示礼包第一个  
	        end

	        item:SetIndex(i)
			self.slider_cell_list[i] = item
		end
		PrefabPool.Instance:Free(prefab)
		self:Flush()
	end)

end

function LianXuChongZhi:InitRewardList()
	self.cell_list = {}
    for i = 1, ITEM_COUNT do
        local item = ItemCell.New()
	    item:SetInstanceParent(self:FindObj("reward_" .. i))
        self.cell_list[i] = item
    end
    self.show_item_reward = self:FindVariable("show_item_reward")
    self.show_item_reward:SetValue(0)
end

function LianXuChongZhi:SetSelectIndex(index)
	self.select_index = index
end

function LianXuChongZhi:GetSelectIndex()
	return self.select_index or 1
end

function LianXuChongZhi:FlushRewardView()
	local item_id_group = FestivalActivityData.Instance:ZhongQiuLianXuChongZhiCfg()
	if not item_id_group then 
		return
	end

	local data_group = item_id_group[self.select_index]
	if not data_group or not data_group.reward_item then 
		return
    end
    
    local need_gold = data_group.need_chongzhi   --所需的充值数量
	local data_id = data_group.reward_item.item_id or 0
	local data_list = ItemData.Instance:GetGiftItemList(data_id)
    
	local index = 1
	for k,v in pairs(data_list)do
		if index > ITEM_COUNT then
			break
		end

		if v then
			self.cell_list[index]:SetData(v)
			index = index + 1
		end
	end

	self.show_item_reward:SetValue(index)
	local festival_data = FestivalActivityData.Instance

	--按钮更新
	if festival_data:GetCanFetchRewardFlagByIndex(self.select_index) == 0 then
		self.show_button_lq:SetValue(false)
		self.show_button_cz:SetValue(true)
	    self.show_yilingqu:SetValue(false)
	end

	if festival_data:GetCanFetchRewardFlagByIndex(self.select_index) == 1 then
		if festival_data:GetHasFetchRewardFlagByIndex(self.select_index) == 0 then  --未领取
			self.show_button_lq:SetValue(true)
			self.show_button_cz:SetValue(false)
	        self.show_yilingqu:SetValue(false)
		end
		if festival_data:GetHasFetchRewardFlagByIndex(self.select_index) == 1 then  --已经领取
			self.show_button_lq:SetValue(false)
			self.show_button_cz:SetValue(false)
	        self.show_yilingqu:SetValue(true)
		end
	end

	self.gold_num:SetValue(need_gold)
end

function LianXuChongZhi:FlushAllHL()
	if not self.slider_cell_list then
	    return
	end
    
    for i = 1, #self.slider_cell_list do
    	self.slider_cell_list[i]:SetHightLight(self.select_index)
    end
end

function LianXuChongZhi:FlushSlider()
	if not self.slider_cell_list then
	    return
	end

    local festival_data = FestivalActivityData.Instance
	local size = #self.slider_cell_list

	for i = 1, size do
		if festival_data:GetCanFetchRewardFlagByIndex(i) == 0 then
			if size == 1 then   --当第一个还没领取时不现实特效
				self.is_show_effect:SetValue(false)
            else
                self.is_show_effect:SetValue(true)
            end

            self.slider_num:SetValue((i - 1)/ size) 
            return                         
		elseif festival_data:GetCanFetchRewardFlagByIndex(i) == 1 and size == i then --当最后一个已经领取的时候
			self.slider_num:SetValue(1)       
			self.is_show_effect:SetValue(true)
	    end
    end
	
end

function LianXuChongZhi:OnFlush()
	local openchu_start, openchu_end = KaifuActivityData.Instance:GetActivityOpenDay(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE)

	local openchu_time = openchu_end - TimeCtrl.Instance:GetServerTime()
	self:SetRestTimeChu(openchu_time)

	local info_chu = FestivalActivityData.Instance:GetChongZhiZhongQiu()
	if nil ~= info_chu then
		self.today_coin_chu:SetValue(info_chu.today_chongzhi)
	end

    local num = self:GetCfgNum() or 0

    for i = 1, num do
		if FestivalActivityData.Instance:GetHasFetchRewardFlagByIndex(i) == 0 then  --未领取
            self.select_index = i
            break
		end
    end

	self:FlushRewardView()
	self:FlushAllHL()
	self:FlushSlider()
	self:FlushModel()
end

function LianXuChongZhi:FlushModel()
	local show_item_id, day_num, show_index = self:GetTeHuiItemChu()
	local item_cfg = ItemData.Instance:GetItemConfig(show_item_id)
	if item_cfg == nil then
		return
	end
   
	local name = item_cfg.name or ""
	local power = item_cfg.power or 0
	ItemData.ChangeModel(self.model, show_item_id)
	local cfg = ItemData.Instance:GetItemConfig(show_item_id)
	
	if cfg and cfg.is_display_role == DISPLAY_TYPE.FOOTPRINT then
		self.model:SetInteger("status", 1)
	end

	self.type_res:SetAsset(ResPath.GetOpenFestivalActivityRes("text_" .. show_index))
	self.day_res:SetAsset(ResPath.GetOpenFestivalActivityRes("day_" .. day_num))
	self.lianchongchu_name:SetValue(name)
	self.lianchongchu_zhanli:SetValue(power)
end

--获得配置数量
function LianXuChongZhi:GetCfgNum()   
    local cfg = FestivalActivityData.Instance:ZhongQiuLianXuChongZhiCfg()
    if not cfg then
        return 0
    end

    local get_cfg_num = #cfg or 0

    return get_cfg_num
end

function LianXuChongZhi:GetTeHuiItemChu()
	--local open_server_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = FestivalActivityData.Instance:ZhongQiuLianXuChongZhiCfg()
	if nil == cfg then
		return 0, 0, 0
	end
    
	local day_num = self:GetCfgNum() or 0
	if not cfg[day_num] then
	    return 0, 0, 0
	end
    
    local show_index = cfg[day_num].show_index
    local item_id = cfg[day_num].res_id or 0
    
    return item_id, day_num, show_index 
	-- for k, v in pairs(cfg) do
	-- 	if open_server_day <= v.open_server_day then
	-- 		return v.show_item, v.show_type, v.model_name, v.power, v.show_day
	-- 	end
	-- end
end

function LianXuChongZhi:SetRestTimeChu(diff_time)
	if self.count_down_chu == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(total_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down_chu ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down_chu)
					self.count_down_chu = nil
				end
				return
			end
			local time_str = ""
			local left_day = math.floor(left_time / 86400)
			if left_day > 0 then
				time_str = TimeUtil.FormatSecond(left_time, 7)
			elseif math.floor(left_time / 3600) > 0 then
				time_str = TimeUtil.FormatSecond(left_time, 1)
			else
				time_str = TimeUtil.FormatSecond(left_time, 2)
			end
			self.lianchongchu_day:SetValue(time_str)
		end
		self:CancelCountDown()
		diff_time_func(0, diff_time)
		self.count_down_chu = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function LianXuChongZhi:CancelCountDown()
	if self.count_down_chu ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down_chu)
		self.count_down_chu = nil
	end
end

function LianXuChongZhi:OnClickLingQu()
	if FestivalActivityData.Instance:GetHasFetchRewardFlagByIndex(self.select_index) == 1 then 
		return
	end

	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE, RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPEAR_TYPE_FETCH_REWARD, self.select_index)
end

function LianXuChongZhi:OnClickChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

---------------AutumnSliderCell----------------

AutumnSliderCell = AutumnSliderCell or BaseClass(BaseRender)

function AutumnSliderCell:__init()
	self.number = self:FindVariable("number")
	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self:FindObj("reward_cell"))
    self.cell:SetIsShowTips(false)
    self.show_hl = self:FindVariable("showHL")
    self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function AutumnSliderCell:__delete()
    if self.cell then
       self.cell:DeleteMe()
       self.cell = nil
    end
    self.number = nil
    self.show_hl = nil
    self.parent_view = nil
end

function AutumnSliderCell:SetHightLight(index)
	self.show_hl:SetValue(self.index == index)
	self:Flush()
end

function AutumnSliderCell:SetData(data)
	self.cell:SetData(data)
	self:Flush()
	self.data = data
end

function AutumnSliderCell:SetIndex(index)
	self.index = index
	self.number:SetValue(index)
end

function AutumnSliderCell:OnFlush()
	local festival_data = FestivalActivityData.Instance

	if festival_data:GetCanFetchRewardFlagByIndex(self.index) == 0 then
       self.cell:ShowGetEffect(false)
       self.cell:ShowHaseGet(false)	    
	end

	if festival_data:GetCanFetchRewardFlagByIndex(self.index) == 1 then
		if festival_data:GetHasFetchRewardFlagByIndex(self.index) == 0 then  --未领取
	        self.cell:ShowGetEffect(true)
	        self.cell:ShowHaseGet(false)	        
		end
		if festival_data:GetHasFetchRewardFlagByIndex(self.index) == 1 then  --已经领取
	       	self.cell:ShowGetEffect(false)
			self.cell:ShowHaseGet(true) 
		end
	end
end

function AutumnSliderCell:OnClick()
	self.cell:SetIsShowTips(true)
	self.cell:OnClickItemCell()
	self.cell:ShowHighLight(false)
	self:SetHightLight(self.index)
	self.parent_view:SetSelectIndex(self.index)
	self.parent_view:FlushRewardView()
	self.parent_view:FlushAllHL()
end
