-- 离线挂机 配置 LogoutGuajiConfig

local OfflineView = OfflineView or BaseClass(SubView)

function OfflineView:__init()
	self.config_tab = {
		{"offline_ui_cfg", 1, {0}},
	}
	
	self.is_offline_stop = false
	self.select_map_index = 1
end

function OfflineView:ReleaseCallBack()
	if self.cell_grid_scroll then
		self.cell_grid_scroll:DeleteMe()
		self.cell_grid_scroll = nil
	end

	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
	
	self.select_map_index = 1
end

function OfflineView:LoadCallBack(index, loaded_times)
	self.data = OfflineData.Instance:GetData()

	self:InitTipTexts()
	self:InitCellList()
	self:InitSceneList()

	self.node_t_list["btn_1"].node:setTitleText(Language.Offline.GuajiButton[1])


	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnBtn, self))

	EventProxy.New(OfflineData.Instance, self):AddEventListener(OfflineData.OFFLINE_DATA_CHANGE, BindTool.Bind(self.OnOfflineDataChange, self))
end

function OfflineView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end


function OfflineView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.select_map_index = 1
end

function OfflineView:ShowIndexCallBack()
	self:Flush()
end

function OfflineView:OnFlush(param_t, index)
	local index = 1
	if self.data.offline_index > 0 then
		index = self.data.offline_index
	else
		local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		local scene_cfg = LogoutGuajiConfig and LogoutGuajiConfig.gjscene or {}
		for i,v in ipairs(scene_cfg) do
			if lv >= v.level then
				index = i
			end
		end
	end
	self.scene_grid_scroll:SelectItemByIndex(index)

	self:OnOfflineDataChange()
end

function OfflineView:InitTipTexts()
	local tip_texts = LogoutGuajiConfig and LogoutGuajiConfig.tip or {}
	local y1, y2
	local h = 0
	local space = 7
	for i,v in ipairs(tip_texts) do
		local rich = self.node_t_list["rich_tip_" .. i].node
		local point = self.node_t_list["img_point_" .. i].node
		if rich then
			rich = RichTextUtil.ParseRichText(rich, v, 18, COLOR3B.OLIVE)
			rich:refreshView()

			-- 调整图片和文本位置
			if y1 then
				rich:setPositionY(y1 - h)
			end
			if y2 then
				point:setPositionY(y2 - h)
			end
			y1 = rich:getPositionY()
			y2 = point:getPositionY()
			h = rich:getInnerContainerSize().height + space
		end
	end
end

function OfflineView:InitCellList()
	local parent = self.node_t_list["layout_offline_exp"].node
	local ph = self.ph_list["ph_award_list"]
	local ph_item = {x = 40, y = 40, w = 80, h = 80}
	grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 4, ph_item.h, BaseCell, ScrollDir.Vertical, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 100)

	local list = OfflineData.Instance:GetAwardList()
	grid_scroll:SetDataList(list)

	self.cell_grid_scroll = grid_scroll
end

function OfflineView:InitSceneList()
	local parent = self.node_t_list["layout_offline_exp"].node
	local ph = self.ph_list["ph_scene_list"]
	local ph_item = self.ph_list["ph_scene_item"]
	grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h + 5, self.SceneItem, ScrollDir.Vertical, false, ph_item)
	grid_scroll:SetSelectCallBack(BindTool.Bind(self.OnSelectMap, self))
	parent:addChild(grid_scroll:GetView(), 100)

	local data_list = LogoutGuajiConfig and LogoutGuajiConfig.gjscene or {}
	grid_scroll:SetDataList(data_list)
	grid_scroll:JumpToTop()
	self.scene_grid_scroll = grid_scroll
end


function OfflineView:OnOfflineDataChange()
	if self.data.offline_index > 0 then
		self.scene_grid_scroll:SelectItemByIndex(self.data.offline_index)
	end
	if self.data.results == 1 then
		self.node_t_list["btn_1"].node:setTitleText(Language.Offline.GuajiButton[2])
	elseif self.data.results == 0 then
		if self.data.offline_index > 0 and (not self.is_offline_stop) then
			self.is_offline_stop = false
			self.node_t_list["btn_1"].node:setTitleText(Language.Offline.GuajiButton[3])
		else
			self.node_t_list["btn_1"].node:setTitleText(Language.Offline.GuajiButton[1])
		end
	end

	local list = OfflineData.Instance:GetAwardList()
	self.cell_grid_scroll:SetDataList(list)
	self.offline_time = self.data.offline_time - self.data.offline_time % 60
	local time = TimeUtil.FormatHM(self.offline_time)
	time = time == "" and "0分" or time
	self.node_t_list["lbl_offline_time"].node:setString(Language.Offline.Text1 .. time)
end

function OfflineView:OnSelectMap(item)
	self.select_map_index = item:GetIndex()
end

function OfflineView:OnBtn()
	local text = self.node_t_list["btn_1"].node:getTitleText()
	if text == Language.Offline.GuajiButton[1] then
		self.is_offline_stop = false
		OfflineCtrl.SendOfflineBeginReq(self.select_map_index)
	elseif text == Language.Offline.GuajiButton[2] then
		if nil == self.alert then
			self.alert = Alert.New()
			self.alert:SetOkString(Language.Offline.AlertBtnText[1])
			self.alert:SetCancelString(Language.Offline.AlertBtnText[2])
			self.alert:SetOkFunc(function()
				OfflineCtrl.SendOfflineReward(1)
			end)
			self.alert:SetCancelFunc(function()
				OfflineCtrl.SendOfflineReward(0)
			end)
		end
		local ratio = LogoutGuajiConfig and LogoutGuajiConfig.Money or 1
		local money = self.offline_time / 60 * ratio
		self.alert:SetLableString(string.format(Language.Offline.AlertText, Language.Common.Diamond .. "*" .. money))
		self.alert:Open()
	elseif text == Language.Offline.GuajiButton[3] then
		self.is_offline_stop = true
		OfflineCtrl.SendOfflineStopReq()
	end
end

----------------------------------------
-- 场景列表Item
----------------------------------------
OfflineView.SceneItem = BaseClass(BaseRender)
local SceneItem = OfflineView.SceneItem
function SceneItem:__init()
end

function SceneItem:__delete()
end

function SceneItem:CreateChild()
	BaseRender.CreateChild(self)
end

function SceneItem:OnFlush()
	if nil == self.data then return end
	local scene_name = self.data.name or ""
	local lv_cfg = self.data.level or 0
	local lv_text = "(" .. lv_cfg .. Language.Common.Ji .. ")"

	local vip_lv = self.data.vipLv or 0
	local conditions_text = "VIP" .. vip_lv
	
	self.node_tree["lbl_scene_name"].node:setString(scene_name .. lv_text)
	self.node_tree["lbl_conditions"].node:setString(conditions_text)

	local money = 0
	local award = self.data.award or {}
	for i,v in ipairs(award) do
		if v.type == 5 then
			money = v.count
		end
	end
	local max_time = LogoutGuajiConfig.maxTime or 0
	money = money * (max_time / 60) -- 最大绑元收益
	self.node_tree["lbl_money"].node:setString(money)
end

return OfflineView