--威望
PrestigeView = PrestigeView or BaseClass(BaseView)

function PrestigeView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetWord("word_prestige")
	self.texture_path_list[1] = 'res/xui/prestige.png'
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"prestige_ui_cfg", 1, {0}},
		{"prestige_ui_cfg", 2, {0},false},
		{"common_ui_cfg", 2, {0}},
	}

	self.prestige_name_list = {}
	self.role_list = {}
	self.zhan_gu_duihuan_list = nil
end

function PrestigeView:__delete()
end

function PrestigeView:ReleaseCallBack()
	if self.prestige_preview_list ~= nil then
		self.prestige_preview_list:DeleteMe()
		self.prestige_preview_list = nil
	end

	if self.prog ~= nil then
		self.prog:DeleteMe()
		self.prog = nil
	end
	self.prestige_name_list = {}
	self.role_list = {}

	if self.zhan_gu_duihuan_list ~= nil then
		self.zhan_gu_duihuan_list:DeleteMe()
		self.zhan_gu_duihuan_list = nil
	end
	if self.changeEvent then
		GlobalEventSystem:UnBind(self.changeEvent)
		self.changeEvent = nil
	end

	if self.cur_attr_list then
		self.cur_attr_list:DeleteMe()
		self.cur_attr_list = nil
	end

	if self.next_attr_list then
		self.next_attr_list:DeleteMe()
		self.next_attr_list = nil
	end

	if self.delay_flush_timer then
		GlobalTimerQuest:CancelQuest(self.delay_flush_timer)
		self.delay_flush_timer = nil
	end
end

function PrestigeView:OpenCallBack()
end

function PrestigeView:LoadCallBack(index, loaded_times)
	-- if(loaded_times <= 1) then

		
	-- end

	-- 请求威望排行榜数据
	RankingListCtrl.Instance:SendRankingListReq(4)

	self:GetPrestigePreviewList()
	
	self:CreateRoleDisplay()
	self:CreateZhanGuDuiHuanList()
	self:CreateAttrList()
	self:CreateNextAttrList()
	self:GetNowPrestigeData()
	-- 按钮点击事件
	self.node_t_list.btn_prestige_rank.node:addClickEventListener(BindTool.Bind(self.OnOpenPrestigeRank, self))
	-- :addClickEventListener(BindTool.Bind(self.ReturnZhanGu, self))
	self.node_t_list.btn_prestige_tip.node:addClickEventListener(BindTool.Bind(self.OnTipBtn, self))
	XUI.AddClickEventListener(self.node_t_list.btn_return1.node, BindTool.Bind(self.ReturnZhanGu, self), true)
	self.node_t_list.btn_return1.node:setLocalZOrder(999)
    if IS_AUDIT_VERSION then
        self.node_t_list.btn_prestige_rank.node:setVisible(false)
    end
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_PRESTIGE_VALUE, BindTool.Bind(self.OnActorArestigeValue, self))
	EventProxy.New(RankingListData.Instance, self):AddEventListener(RankingListData.PRESTIGE_LIST_CHANGE, BindTool.Bind(self.OnPrestigeListChange, self))
	self.changeEvent = GlobalEventSystem:Bind(ZHANGUDUIHUANEVENT.RESULT,BindTool.Bind1(self.OnFlushList, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

function PrestigeView:ItemDataListChangeCallback( ... )
	self:FlushPoint()
end

function PrestigeView:ShowIndexCallBack(index)
	self:FlushProgressBar()
	self:Flush(index)
	self:FlushValueShow()
end

function PrestigeView:OnFlush()
	self:FlushList()
	
	RichTextUtil.ParseRichText(self.node_t_list.text_desc.node, Language.Prestige.desc)
	self:FlushPoint()
end

function PrestigeView:FlushPoint( ... )
	local num = PrestigeData.Instance:GetCanDuiHuan()
	self.node_t_list.img_point.node:setVisible(num >= 1)
end

----------视图函数------------

function PrestigeView:GetNowPrestigeData()--获取当前威望数据
	self.all_data = PrestigeData.Instance:GetAllPrestigeCfg()
	self.prestige_data = PrestigeData.Instance:GetPrestigeCfg()
	self.now_prestige_data = PrestigeData.Instance:GetNowPrestigeByTotalValue()
	if self.now_prestige_data == nil and self.prestige_data == nil and self.all_data == nil then return end
	
	self.node_t_list.img_now_prestige_title.node:loadTexture(ResPath.GetPrestigeResPath("prestige_title_" .. (self.now_prestige_data.index or 0)))
	--self.node_t_list.lbl_now_desc.node:setString(string.format(Language.Prestige.Recycle_Prestige,(self.all_data.zeroDelRate / 100) .. "%"))
	self.node_t_list.lbl_beat_desc.node:setString(string.format(Language.Prestige.Promote_Damage,(self.all_data.attackAddRate / 100) .. "%"))
	self.node_t_list.lbl_beat_desc2.node:setString(string.format(Language.Prestige.Promote_Damage,(self.all_data.attackAddRate / 100) .. "%"))
	--属性值
	local length = table.getn(self.prestige_data)
	local now_attr = PrestigeData.Instance:GetNowPrestigeAttributeByJob()
	local next_attr = nil
	if (self.now_prestige_data.index or 1) >= length then
		next_attr = "已经最高了"
		RichTextUtil.ParseRichText(self.node_t_list.rich_next_attr.node, next_attr, 18, COLOR3B.GREEN)
		self.node_t_list.rich_next_attr.node:setPosition(400, 150)
	else
		next_attr = PrestigeData.Instance:GetNextPrestigeAttributeByJob()
		RichTextUtil.ParseRichText(self.node_t_list.rich_next_attr.node, RoleData.FormatAttrContent(next_attr), 18, COLOR3B.GREEN)
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_cur_attr.node, RoleData.FormatAttrContent(now_attr), 18, COLOR3B.GRAY2)
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_cur_attr.node,5)
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_next_attr.node,5)
	-- self.node_t_list.rich_cur_attr.node:setVerticalSpace(-2) --设置垂直间隔
 --    self.node_t_list.rich_next_attr.node:setVerticalSpace(-2)
	--预览值
	self.prestige_preview_list:SetDataList(self.prestige_data)
	
	--进度值
	self.prog = ProgressBar.New()
	self.prog:SetView(self.node_t_list.prog9_prestige_exp.node)
	self.prog:SetTailEffect(991, nil, true)
	self.prog:SetEffectOffsetX(-20)

	-- 获取威望
	self.link_stuff = RichTextUtil.CreateLinkText("查看战魂值", 20, COLOR3B.GREEN)
	self.link_stuff:setPosition(500, 30)
	self.node_t_list.layout_prestige_show.node:addChild(self.link_stuff, 99)
	XUI.AddClickEventListener(self.link_stuff, function()
			local can_open_rankinglist = GameCondMgr.Instance:GetValue("CondId71")
			if not can_open_rankinglist then
				SysMsgCtrl.Instance:FloatingTopRightText(Language.Prestige.OpenTips)
			else
				ViewManager.Instance:OpenViewByDef(ViewDef.RankingList.Prestige)
			end
	end, true)
	
end

function PrestigeView:GetPrestigePreviewList()--威望预览列表
	local ph = self.ph_list.ph_prestige_title_list--获取区间列表
	self.prestige_preview_list = ListView.New()
	self.prestige_preview_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, PrestigeViewCell, nil, nil, self.ph_list.ph_prestige_title_item)
	self.prestige_preview_list:SetItemsInterval(5)--格子间距
	self.prestige_preview_list:SetJumpDirection(ListView.Top)--置顶
	self.node_t_list.layout_prestige_show.node:addChild(self.prestige_preview_list:GetView(), 20)
	self.prestige_preview_list:GetView():setAnchorPoint(0, 0)
	--self.title_list:GetView():setAnchorPoint(0, 0)
end

function PrestigeView:FlushProgressBar()
	-- 威望值显示
	local prestige_total_value = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PRESTIGE_VALUE)--总威望值
	local needtotalvalue = 0

	local prestige_cfg_data = PrestigeData.Instance:GetPrestigeCfg()--所有威望数据
	self.now_prestige_data = {}
	for k, v in pairs(prestige_cfg_data) do
		if prestige_total_value < v.NeedTotalValue then
			needtotalvalue = v.NeedTotalValue
			break
		end
	end

	-- 设置进度条文本
	local text = prestige_total_value .. "/" .. needtotalvalue
	self.node_t_list.lbl_prestige_prog.node:setString(text)

	-- 设置进度条
	local percent = 0
	if needtotalvalue ~= 0 then
		percent = prestige_total_value / needtotalvalue * 100
		percent = percent >= 100 and 100 or percent
	end
	self.prog:SetPercent(percent)
end

-- 创建角色显示
function PrestigeView:CreateRoleDisplay()
	for i = 1, 3 do
		local ph = self.ph_list["ph_role_display"]
		self.role_list[i] = RoleDisplay.New(self.node_t_list["layout_display_role_" .. i].node, 1, false, false, true, true)
		self.role_list[i]:SetPosition(ph.x, ph.y)
	end
end

-- 设置角色数据
function PrestigeView:SetRoleData(protocol)
	for k, v in pairs(self.prestige_name_list) do
		if v == protocol.vo.name then
			self.role_list[k]:SetRoleVo(protocol.vo)
			self.role_list[k]:SetVisible(true)
			self.role_list[k]:SetScale(0.7)
			self.node_t_list["txt_role_name_" .. k].node:setString(v)
			XUI.EnableOutline(self.node_t_list["txt_role_name_" .. k].node)
			break
		end
	end
end



--战鼓兑换
function PrestigeView:ReturnZhanGu()
	self.node_t_list.layout_zhangu_exchange.node:setVisible(false)
	self.node_t_list.layout_prestige_show.node:setVisible(true)
end

function PrestigeView:CreateZhanGuDuiHuanList( )
	
	if nil == self.zhan_gu_duihuan_list then
		local ph = self.ph_list.ph_list--获取区间列表
		self.zhan_gu_duihuan_list = ListView.New()
		self.zhan_gu_duihuan_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, DuiHuanZhanGuCell, nil, nil, self.ph_list.ph_list_item)
		self.zhan_gu_duihuan_list:SetItemsInterval(0)--格子间距
		self.zhan_gu_duihuan_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_zhangu_exchange.node:addChild(self.zhan_gu_duihuan_list:GetView(), 20)
		self.zhan_gu_duihuan_list:GetView():setAnchorPoint(0, 0)
	end
	self:FlushList()
end

function PrestigeView:OnFlushList()
	if self.delay_flush_timer then
		GlobalTimerQuest:CancelQuest(self.delay_flush_timer)
		self.delay_flush_timer = nil
	end
	
	self.delay_flush_timer =  GlobalTimerQuest:AddDelayTimer(function ()
		self:FlushList()
		self:FlushPoint()
	end, 0.2)
	--PrintTable(PrestigeData.Instance:GetCfgList())
end


function PrestigeView:FlushList()
	local list = PrestigeData.Instance:GetCfgList()
	self.zhan_gu_duihuan_list:SetDataList(list)
end


function PrestigeView:CreateAttrList()
	if nil == self.cur_attr_list then
		local ph = self.ph_list.ph_attr_list--获取区间列表
		self.cur_attr_list = ListView.New()
		self.cur_attr_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, ZhanGuAttrItem, nil, nil, self.ph_list.ph_role_attr_item1)
		self.cur_attr_list:SetItemsInterval(5)--格子间距
		self.cur_attr_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_zhangu_exchange.node:addChild(self.cur_attr_list:GetView(), 20)
		self.cur_attr_list:GetView():setAnchorPoint(0, 0)
	end
end


function PrestigeView:CreateNextAttrList( ... )
	if nil == self.next_attr_list then
		local ph = self.ph_list.ph_special_attr_list--获取区间列表
		self.next_attr_list = ListView.New()
		self.next_attr_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, ZhanGuAttrItem, nil, nil, self.ph_list.ph_role_attr_item2)
		self.next_attr_list:SetItemsInterval(5)--格子间距
		self.next_attr_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_zhangu_exchange.node:addChild(self.next_attr_list:GetView(), 20)
		self.next_attr_list:GetView():setAnchorPoint(0, 0)
	end
end


function PrestigeView:FlushValueShow( ... )
	self.all_data = PrestigeData.Instance:GetAllPrestigeCfg()
	self.prestige_data = PrestigeData.Instance:GetPrestigeCfg()
	self.now_prestige_data = PrestigeData.Instance:GetNowPrestigeByTotalValue()

	
	--属性值
	local length = table.getn(self.prestige_data)
	local now_attr = PrestigeData.Instance:GetNowPrestigeAttributeByJob()
	local attr = RoleData.FormatRoleAttrStr(now_attr)
	self.cur_attr_list:SetDataList(attr)

	local vis = false
	if (self.now_prestige_data.index or 1) >= length then
		self.next_attr_list:SetDataList({})
		vis = true
	else
		vis = false
		local next_attr = PrestigeData.Instance:GetNextPrestigeAttributeByJob()
		local next_attr_list = RoleData.FormatRoleAttrStr(next_attr)
		self.next_attr_list:SetDataList(next_attr_list)
	end
	self.node_t_list.labl_show.node:setVisible(false)
end

-----------end-----------

-- "提示按钮"点击回调
function PrestigeView:OnTipBtn()
	-- 显示提示内容
	DescTip.Instance:SetContent(CLIENT_GAME_GLOBAL_CFG.prestige_tip_content, Language.Prestige.TipTab)
end

function PrestigeView:OnOpenPrestigeRank()
	self.node_t_list.layout_prestige_show.node:setVisible(false)
	self.node_t_list.layout_zhangu_exchange.node:setVisible(true)
end

function PrestigeView:OnActorArestigeValue()
	self:FlushProgressBar()
	self:FlushValueShow()
end


function PrestigeView:OnPrestigeListChange()
	self.prestige_name_list = RankingListData.Instance:GetPrestigeName()
	
	if nil ~= next(self.role_list) then
		BrowseCtrl.Instance:BrowRoleInfo(self.prestige_name_list[1], 0, BindTool.Bind(self.SetRoleData, self))
		BrowseCtrl.Instance:BrowRoleInfo(self.prestige_name_list[2], 0, BindTool.Bind(self.SetRoleData, self))
		BrowseCtrl.Instance:BrowRoleInfo(self.prestige_name_list[3], 0, BindTool.Bind(self.SetRoleData, self))
	end
end

-----------------------------------------------------------------------------------------------------------
DuiHuanZhanGuCell = DuiHuanZhanGuCell or BaseClass(BaseRender)--威望预览

function DuiHuanZhanGuCell:__init()
	
end

function DuiHuanZhanGuCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil 
	end
	
end

function DuiHuanZhanGuCell:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.btn_duihuan.node:addClickEventListener(BindTool.Bind(self.DuiHuanZhanGU, self))
end

function DuiHuanZhanGuCell:OnFlush()
	if self.data == nil then return end
	--local text = 
	local text1 = string.format(Language.Prestige.desc1, self.data.award[1].count)

	self.node_tree.rich_get.node:setString(text1)

	local remian_time = self.data.limit- self.data.had_times

	local text2 = string.format(Language.Prestige.desc2, remian_time)
	-- print(text2)
	RichTextUtil.ParseRichText(self.node_tree.remian_time.node, text2)
	self.node_tree.remian_time.node:setVisible(self.data.is_can_duihuan <= 0)
	self.node_tree.btn_duihuan.node:setVisible(self.data.is_can_duihuan > 0)
	local color = self.data.is_can_duihuan > 0 and "00ff00" or "ff0000"
	
	local text =string.format(Language.Prestige.desc3, self.data.desc, color, self.data.can_duihuan_count, self.data.needCount)
	
	RichTextUtil.ParseRichText(self.node_tree.rich_desc.node, text)
	self.node_tree.img_bg.node:setVisible(self.index % 2 ~= 1 )
end

function DuiHuanZhanGuCell:CreateSelectEffect()

end

function DuiHuanZhanGuCell:DuiHuanZhanGU()
	local times = self.data.can_duihuan_count
	local remian_time = self.data.limit- self.data.had_times
	local can_use_time = remian_time >= times and times or remian_time
	local data = {}
	for k,v in pairs(self.data.itemIdList) do
		local list = BagData.Instance:GetDataByItemId(v)
		for k1,v1 in pairs(list) do
			if(#data <= can_use_time) then
				
				table.insert(data, v1.series)
			end
		end
	end 
	if (#data <= 0) then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Prestige.tips4)
	else
		PrestigeCtrl.Instance:SendGetPrestigeTaskAward(self.data.order, can_use_time, data)	
	end
	--self.node_t_list.img_bg.node:setVisible(self.index % 2 == 1 )
end


PrestigeViewCell = PrestigeViewCell or BaseClass(BaseRender)--威望预览

function PrestigeViewCell:__init()
	
end

function PrestigeViewCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil 
	end
	
end

function PrestigeViewCell:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_item_cell
	if  nil == self.item_cell then
		self.item_cell = BaseCell.New()
		self.item_cell:GetView():setPosition(ph.x, ph.y)
		self.view:addChild(self.item_cell:GetView(), 99)  
	end
end

function PrestigeViewCell:OnFlush()
	if self.data == nil then return end
	self.node_tree.img_prestige_title.node:loadTexture(ResPath.GetPrestigeResPath("prestige_title_" .. self.index))
	self.node_tree.lbl_prestige_value.node:setString( "所需战魂值:" .. self.data.NeedTotalValue)
	self.item_cell:SetData({item_id = self.data.virtual_item_id, count = 1, is_bind = 0})


end

function PrestigeViewCell:CreateSelectEffect()

end



ZhanGuAttrItem = ZhanGuAttrItem or BaseClass(BaseRender)--威望预览

function ZhanGuAttrItem:__init()
	
end

function ZhanGuAttrItem:__delete()
	
	
end

function ZhanGuAttrItem:CreateChild()
	BaseRender.CreateChild(self)
	
end

function ZhanGuAttrItem:OnFlush()
	if self.data == nil then return end
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str.."：")
	self.node_tree.lbl_attr_value.node:setString(self.data.value_str)

end

function ZhanGuAttrItem:CreateSelectEffect()

end

return PrestigeView
