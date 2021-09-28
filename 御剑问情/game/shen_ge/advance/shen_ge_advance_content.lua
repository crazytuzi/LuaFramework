
ShenGeAdvanceContent = ShenGeAdvanceContent or BaseClass(BaseRender)

-- 预留属性条数
local  Attr_Number = 3 
function ShenGeAdvanceContent:__init()
	self.first_init = true
	self.slot_cell_list = {}
	for i = 1, ShenGeEnum.SHENGE_SYSTEM_CUR_MAX_SHENGE_GRID do
		self.slot_cell_list[i] = AdvanceShenGeCell.New(self:FindObj("SlotCell"..i))
		self.slot_cell_list[i]:ListenClick(BindTool.Bind(self.OnClickShenGeCell, self, i - 1))
		self.slot_cell_list[i]:SetIndex(i - 1)
	end

	-- self.icon_bg = self:FindVariable("icon_bg")
	self.show_bg = {}
	for i=1,4 do
		self.show_bg[i] = self:FindVariable("ShowBg" .. i)
	end
	self.icon = self:FindVariable("icon")
	self.grade = self:FindVariable("grade")
	self.resume = self:FindVariable("resume")
	self.fight_power = self:FindVariable("fight_power")
	self.auto_buy = self:FindObj("auto_buy")
	self.is_auto_buy = self.auto_buy.toggle.isOn and 1 or 0
	self.auto_buy.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange,self))
	self.attrs = {}
	for i=1,Attr_Number do
		self.attrs[i] = {}
		self.attrs[i].base = self:FindVariable("baseattr" .. i)
		self.attrs[i].improve = self:FindVariable("improve" .. i)
		self.attrs[i].show = self:FindVariable("showattr" .. i)
	end
	self:ListenEvent("ClickStart",BindTool.Bind(self.ClickStart,self))
	self:ListenEvent("Help",BindTool.Bind(self.ClickHelp, self))

	self.scroller_list = {}
	-- local value_list = ShenGeAdvanceData.Instance:GetCellInfo(0).attr_list

	for i = 1, 3 do
		self.scroller_list[i] = {}
		self.scroller_list[i].obj = self:FindObj("Image" .. i)
		self.scroller_list[i].cell = AdvanceErnieScroller.New(self.scroller_list[i].obj)
		self.scroller_list[i].cell:SetIndex(i)
		self.scroller_list[i].cell:SetCallBack(BindTool.Bind(self.RollComplete, self))
		-- if value_list ~= nil and value_list[i] ~= nil then
		-- 	self.scroller_list[i].cell:InitData({index = value_list[i]})
		-- end
	end
	self.fight_num = self:FindVariable("FightNumber")
	
end

function ShenGeAdvanceContent:__delete()
	for _, v in pairs(self.slot_cell_list) do
		v:DeleteMe()
	end
	self.slot_cell_list = {}

	for _,v in pairs(self.scroller_list) do
		v.cell:DeleteMe()
	end
	self.scroller_list = {}

	self.is_auto_buy = 0
	self.fight_num = nil
end

function ShenGeAdvanceContent:ClickHelp()
	local tips_id = 249
 	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ShenGeAdvanceContent:ToggleChange(is_on)
	self.is_auto_buy = is_on and 1 or 0
end

function ShenGeAdvanceContent:ResetEff()
	for i = 1, 6 do
		if self.scroller_list[i] ~= nil then
			self.scroller_list[i].cell:ShowEffect(false)
		end
	end

	local data = GoddessData.Instance:GetAuraSearchListInfo()
	for i = 1, 6 do
		if self.scroller_list[i] ~= nil then
			self.scroller_list[i].cell:ShowEffect(data[i - 1] == 0)
		end
	end
end

function ShenGeAdvanceContent:FlushCell(index)
	-- 刷新全部
	if index == nil then
		for k,v in pairs(self.slot_cell_list) do
			local cfg = ShenGeAdvanceData.Instance:GetCellInfo(k - 1)
			local level = cfg.level
			local show_remind = ShenGeAdvanceData.Instance:GetRedList()[k - 1]
			if v.data ~= nil then
				v:SetOther(level, show_remind)
			else
				v:SetOther(-1, false)
			end
		end
	end
end

function ShenGeAdvanceContent:SetNextOpen()
	local list = ShenGeAdvanceData.Instance:GetOpenList()
	for k,v in pairs(list) do
		self.slot_cell_list[v + 1]:SetOpenText(v)
	end
end


function ShenGeAdvanceContent:ScrollerRoll(info,time)
    local animation_time=time or 3

	-- if self.skip_toggle.toggle.isOn then 
 --    --  animation_time=0.0001
 --    	for i = 1, 6 do
	--  		if info ~= nil and info[i - 1] ~= nil and self.scroller_list[i] ~= nil then
	-- 			self.scroller_list[i].cell:SetData({index = info[i - 1], key = "start"})
	-- 			if info[i - 1] == 0 then
	-- 				self.ling_count = self.ling_count + 1
	-- 			end
	-- 		end
 --    	end

 --    	self.is_Rolling = false
 --    	self:ShowReward(self.ling_count)
 --    	return
 --    end
    self.is_Rolling=true
    for i= 1,3 do
    	if info.attr_list[i] == 0 then
    		info.attr_list[i] = 5
    	end
      	self.scroller_list[i].cell:StartScoller(animation_time,info.attr_list[i])
    end
 end

function ShenGeAdvanceContent:RollComplete(cell)
end

function ShenGeAdvanceContent:OnFlush(param_list)
	ShenGeAdvanceData.Instance:FlushRedList()
	for k,v in pairs(param_list) do
		if k == "OnDataChange" then
			data_changed = true
		else
			data_changed = false
		end
		self:SetSlotState(data_changed)
		if k == "FlushAttr" then
			local info = ShenGeAdvanceData.Instance:GetCellInfo(self.click_index)
			self:ScrollerRoll(info, 0.5)
			self:FlushRightPanel()
			self:FlushCell()
		end
		if k == "all" then
			self:FlushCell()
			self:FlushRightPanel()
		end
	end
	self:SetNextOpen()
	local fight_power = ShenGeAdvanceData.Instance:GetAllGridPower()
	self.fight_power:SetValue(fight_power)

	--单个战力
	local fight_list = ShenGeAdvanceData.Instance:GetFightByIndex(self.click_index)
	local sigle_fight = CommonDataManager.GetCapability(fight_list)
	self.fight_num:SetValue(sigle_fight)
end

function ShenGeAdvanceContent:FlushRightPanel()
	if self.click_index then
		local quyu = math.floor(self.click_index / 4) + 1
		local info = ShenGeAdvanceData.Instance:GetCellInfo(self.click_index)
		if info then
			self.grade:SetValue(info.level)
			--通过格子id 获取格子属性
			local cfg = ShenGeAdvanceData.Instance:GetCellAttr(quyu,info.level)
			local str = ShenGeAdvanceData.Instance:GetResumeStr(cfg)
			self.resume:SetValue(str)
			self:UpdateAttr(cfg)
		 end
	end
end

function ShenGeAdvanceContent:OnDataChange(info_type, param1, param2, param3, bag_list)
	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_COMPOSE_SHENGE_INFO
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_SIGLE_CHANGE
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_BAG_INFO
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_CHOUJIANG_INFO then

		self:Flush()


	elseif info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_USING_PAGE_INDEX then
		self:Flush()

	elseif info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_SHENGE_INFO
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_SHENGE_INFO then

		self:Flush("OnDataChange")

	elseif info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_MARROW_SCORE_INFO then
		-- self.fragment:SetValue(ShenGeData.Instance:GetFragments())
	end
end

function ShenGeAdvanceContent:OnClickShenGeCell(index)
	-- 不一样的方式
	local quyu = math.floor(index / 4) + 1
	local list = ShenGeData.Instance:GetSlotStateList()
	local flag = list[index]
	if nil == flag then
		flag = false
	end
	if not flag then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.TotalLevelNoEnough)
		return
	end

	local cell_data = self.slot_cell_list[index + 1]:GetData()
	local limit = ShenGeAdvanceData.Instance:GetLimitFlag(index)
	if nil ~= cell_data and nil ~= cell_data.item_id and cell_data.item_id > 0 and limit == false then
		self.click_index = index
		local info = ShenGeAdvanceData.Instance:GetCellInfo(index)
		local value_list = info and info.attr_list
		for i = 1, 3 do
			if value_list ~= nil and value_list[i] ~= nil then
				if value_list[i] == 0 then
					self.scroller_list[i].cell:InitData({index = 5,correct_index = quyu})
				else
					self.scroller_list[i].cell:InitData({index = value_list[i],correct_index = quyu})
				end
			end
	 	end
		-- self.icon_bg:SetAsset(ResPath.GetShenGeBg(quyu))
		for i=1,4 do
			self.show_bg[i]:SetValue(i == quyu)
		end
		local item_cfg = ItemData.Instance:GetItemConfig(cell_data.item_id)
		self.icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
		local info = ShenGeAdvanceData.Instance:GetCellInfo(index)
		if info then
			self.grade:SetValue(info.level)
			-- 通过格子id 获取格子属性
			local cfg = ShenGeAdvanceData.Instance:GetCellAttr(quyu,info.level)
			local str = ShenGeAdvanceData.Instance:GetResumeStr(cfg)
			self.resume:SetValue(str)
			self:UpdateAttr(cfg)
		end
		return
	end
	if limit == true then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.NeedLevel)
		return
	end
	TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.NeedShenGe)
end

-- 内部接口
function ShenGeAdvanceContent:UpdateAttr(cfg)
	if cfg == nil then
		for i=1, 3 do
			self.attrs[i].show:SetValue(false)
		end
		return
	end

	for i=1,Attr_Number do
		local attr_key = GameEnum.AttrList[i]
		local next_cell = ShenGeAdvanceData.Instance:GetNextCell()
		if next_cell then
			self.attrs[i].show:SetValue(next_cell[attr_key] ~= 0)
		else
			self.attrs[i].show:SetValue(cfg[attr_key] ~= 0)
		end
		if cfg[attr_key] ~= 0 or (next_cell and next_cell[attr_key] ~= 0) then
			self.attrs[i].base:SetValue(cfg[attr_key])
			if next_cell then
				local num = 0
				for k,v in pairs(self.scroller_list) do
					if v.cell.is_correct then
						num = num + 1
					end
				end
				local real_attr = cfg[attr_key]
				if num > 0 then
					if num == 3 then
						num = 2
					end
					real_attr = math.floor(cfg["picture_attr_per_" .. num] * (next_cell[attr_key] - cfg[attr_key]) /10000 + cfg[attr_key])
				end
				self.attrs[i].base:SetValue(real_attr)
				self.attrs[i].improve:SetValue(next_cell[attr_key] - real_attr)
			else
				self.attrs[i].improve:SetValue(0)
			end
		end
	end
end

function ShenGeAdvanceContent:SetSlotState(data_changed)
	local cur_page = ShenGeData.Instance:GetCurPageIndex()
	local is_empty = true
	for k, v in pairs(self.slot_cell_list) do
		local limit = ShenGeAdvanceData.Instance:GetLimitFlag(k - 1)
		v:SetSlotData(ShenGeData.Instance:GetInlayData(cur_page, k - 1),data_changed,limit)
		if v:GetData() ~= nil and v:GetData().item_id ~= nil and v:GetData().item_id > 0 and limit ~= true then
			is_empty = false
		end
	end
	if self.click_index then
		local cell_data = self.slot_cell_list[self.click_index + 1]:GetData()
		if cell_data == nil or cell_data.item_id == nil or cell_data.item_id == 0 then
			self.first_init = true
		end
	end
	if self.first_init then
		for k,v in pairs(self.slot_cell_list) do
			local limit = ShenGeAdvanceData.Instance:GetLimitFlag(k - 1)
			if v:GetData() ~= nil and v:GetData().item_id ~= nil and v:GetData().item_id > 0 and limit ~= true then
				self:OnClickShenGeCell(k - 1)
				self.first_init = false
				return
	 		end
		end
		if is_empty then
			self:Reset()
		end
	else
		if is_empty then
			self:Reset()
		end
	end
end

function ShenGeAdvanceContent:Reset()
	self.click_index = nil
	self.grade:SetValue(0)
	-- self.icon_bg:SetAsset("","")
	for i=1,4 do
		self.show_bg[i]:SetValue(i == quyu)
	end
	self.icon:SetAsset("","")
	self:UpdateAttr()
	for i = 1, 3 do
		self.scroller_list[i].cell:InitData({index = 5,correct_index = -1})
	end
	self.resume:SetValue("")
end

function ShenGeAdvanceContent:ClickStart()
	if self.click_index == nil then
		return
	end
	if self.is_auto_buy == 0 then
		local info = ShenGeAdvanceData.Instance:GetCellInfo(self.click_index)
		local attr = ShenGeAdvanceData.Instance:GetCellAttr(math.floor((self.click_index) / 4) + 1, info.level)
		local flag = ShenGeAdvanceData.Instance:GetIsMaxLevel(self.click_index)
		if flag then
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.MaxLevel)
			return
		end
		local have_num = ItemData.Instance:GetItemNumInBagById(attr.stuff_id)
		local resume_num = attr.stuff_num

		if have_num < resume_num then
			local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			    MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			    if is_buy_quick then
			        self.auto_buy.toggle.isOn = true
			        self.is_auto_buy = 1
			    end
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, attr.stuff_id, nil, 1)
			return
		end
	end
	ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.XUANTU_SYSTEM_REQ_CUILIAN_ROLL,self.click_index,self.is_auto_buy)
end

-- 神格槽
AdvanceShenGeCell = AdvanceShenGeCell or BaseClass(ShenGeCell)

function AdvanceShenGeCell:__init(instance)
	self.icon = self:FindVariable("Icon")
	self.show_lock = self:FindVariable("ShowLock")
	self.level = self:FindVariable("Level")
	self.shen_ge_level = self:FindVariable("ShenGeLevel")
	self.quality = self:FindVariable("Quality")
	self.show_redmind = self:FindVariable("ShowRedmind")
	self.show_level = self:FindVariable("ShowLevel")
	self.index = 0
end

function AdvanceShenGeCell:ListenClick(handler)
	self:ListenEvent("Click", handler)
end

function AdvanceShenGeCell:SetIndex(index)
	self.index = index
end

function AdvanceShenGeCell:GetData()
	return self.data
end

function AdvanceShenGeCell:SetSlotData(data,data_changed,limit)
	if data ~= nil and (self.data == nil or data.item_id ~= self.data.item_id) and data_changed then
		GameObjectPool.Instance:SpawnAsset("effects2/prefab/ui/ui_jinengshengji_1_prefab", "UI_Jinengshengji_1", BindTool.Bind(self.LoadEffect, self))
	end
	self.data = data
	local list = ShenGeData.Instance:GetSlotStateList()
	local flag = list[self.index]
	if nil == flag then
		flag = false
	end
	self.show_lock:SetValue(not flag)
	local groove_index, next_open_level = ShenGeData.Instance:GetNextGrooveIndexAndNextGroove()

	--self.show_level:SetValue(groove_index == (self.index) and next_open_level > 0)
	if next_open_level > 0 then
		self.level:SetValue(string.format(Language.ShenGe.OpenGroove, next_open_level))
	end

	--self.show_quality:SetValue(false)
	self.show_redmind:SetValue(false)
	if limit then
		self.icon:ResetAsset()
		self.show_lock:SetValue(true)
		return
	end
	--玄图格子为空的时候 红点的判断
	if nil == data or nil == data.item_id or data.item_id <= 0 then
		self.icon:ResetAsset()
		-- local is_can_inlay = false
		-- local slot_state_list = ShenGeData.Instance:GetSlotStateList()
		-- if slot_state_list[self.index] and (nil == data or data.item_id <= 0) and #ShenGeData.Instance:GetSameQuYuDataList(math.floor(self.index / 4) + 1) > 0 then
		-- 	is_can_inlay = true
		-- end
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if nil == item_cfg then return end

	self.icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
	-- self.shen_ge_level:SetValue(data.shen_ge_data.level)
	self.quality:SetAsset(ResPath.GetRomeNumImage(data.shen_ge_data.quality))
end

function AdvanceShenGeCell:SetOther(level,is_show)
	self.shen_ge_level:SetValue(level)
	self.show_redmind:SetValue(is_show or false)
end

function AdvanceShenGeCell:LoadEffect(obj)
	if not obj then
		return
	end
	local transform = obj.transform
	transform:SetParent(self.root_node.gameObject.transform, false)
	local function Free()
		if IsNil(obj) then
			return
		end
		GameObjectPool.Instance:Free(obj)
	end
	GlobalTimerQuest:AddDelayTimer(Free, 1)
end

function AdvanceShenGeCell:SetOpenText(index)

	self.show_lock:SetValue(false)
	local level = ShenGeAdvanceData.Instance:GetLimitLevel(index)
	self.show_level:SetValue(true)
	self.level:SetValue(level .. "级开启")
end


-----------------------------------------------Scroller--------------------------------------------

AdvanceErnieScroller = AdvanceErnieScroller or BaseClass(BaseCell)

-- 每个格子的高度(边长)
local cell_hight = 85
-- 每个格子之间的间距
local distance = 0
-- DoTween移动的距离(越大表示转动速度越快)
local movement_distance = 149

local IconCount = 5

function AdvanceErnieScroller:__init(instance)
	if instance == nil then
		return
	end
	local size = cell_hight + distance
	self.rect = self:FindObj("Rect")
	self.do_tween_obj = self:FindObj("DoTween")
	self.do_tween_obj.transform.position = Vector3(0, 0, 0)
	local original_hight = self.root_node.rect.sizeDelta.y
	-- 格子起始间距
	local offset = cell_hight - (original_hight - (cell_hight + 2 * distance)) / 2
	offset = 0
	local hight = (IconCount + 2) * size + (cell_hight - offset * 2)
	self.percent = size / (hight - original_hight)

	self.rect.rect.sizeDelta = Vector2(self.rect.rect.sizeDelta.x, hight)
	self.scroller_rect = self.root_node:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.scroller_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChange, self))

	PrefabPool.Instance:Load(AssetID("uis/views/shengeview_prefab", "Icon_ShenGe"), function(prefab)
        if nil == prefab then
            return
        end
        for i = 1, IconCount + 3 do
            local obj = U3DObject(GameObject.Instantiate(prefab))
            local obj_transform = obj.transform
            obj_transform:SetParent(self.rect.transform, false)
            obj_transform.localPosition = Vector3(0, -(i - 1) * size + offset, 0)
            obj_transform.sizeDelta = Vector2(cell_hight,cell_hight)
            local res_id = i
            if res_id > IconCount then
            	res_id = res_id % IconCount
            end
            -- if res_id == 5 then
            -- 	res_id = 0
            -- end
            obj:GetComponent(typeof(UIVariableTable)):FindVariable("Icon"):SetAsset(ResPath.GetShenGeAdvance(res_id))
        end

        PrefabPool.Instance:Free(prefab)
    end)
    self.target_x = 0
    self.target = 1
    self:StartScoller(0,5)
end

function AdvanceErnieScroller:__delete()
	self:RemoveCountDown()
end

function AdvanceErnieScroller:OnValueChange(value)
	local x = value.y
end

function AdvanceErnieScroller:StartScoller(time, target)
	self:ShowEffect(false)
	if target == 5 then
		self.is_correct = false
		self:ShowEffect(false)
	end
	
	if self.is_correct then
		self:ShowEffect(true)
		return
	end
	if target == self.correct_index then
		self.is_correct = true
		self:ShowEffect(true)
	end
	self.do_tween_obj.transform.position = Vector3(self.target - 1, 0, 0)
	self.target = target or 1
	if self.target == 1 then
		self.target = IconCount + 1
	end
	self:RemoveCountDown()
	self.target_x = movement_distance + self.target
	local tween = self.do_tween_obj.transform:DOMoveX(movement_distance + self.target, time)
	tween:SetEase(DG.Tweening.Ease.InOutExpo)
	self.count_down = CountDown.Instance:AddCountDown(time, 0.01, BindTool.Bind(self.UpdateTime, self))
end

function AdvanceErnieScroller:UpdateTime(elapse_time, total_time)
	local value = self:IndexToValue(self.do_tween_obj.transform.position.x % 10)
	self.scroller_rect.normalizedPosition = Vector2(1, value)
	if elapse_time >= total_time then
		value = self:IndexToValue(self.target_x % 10)
		self.scroller_rect.normalizedPosition = Vector2(1, value)
		if self.call_back then
			self.call_back(self)
		end
	end
end

function AdvanceErnieScroller:InitData(data)
	self.correct_index = data.correct_index
	self.is_correct = false
	self:StartScoller(0,data.index)
end

function AdvanceErnieScroller:IndexToValue(index)
	return 1 - (self.percent * index % 1)
end

function AdvanceErnieScroller:SetCallBack(call_back)
	self.call_back = call_back
end

function AdvanceErnieScroller:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function AdvanceErnieScroller:ShowEffect(flag)
	if self.effect == nil then
	  	PrefabPool.Instance:Load(AssetID("effects2/prefab/ui_x/ui_zhishengyijie_002_prefab", "UI_zhishengyijie_002"), function (prefab)
			if not prefab or self.effect then return end
			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			local transform = obj.transform
			transform:SetParent(self.root_node.transform, false)
			self.effect = obj.gameObject
			self.is_loading = false
			self.effect:SetActive(flag)
		end)
	else
		self.effect:SetActive(flag)
	end
end