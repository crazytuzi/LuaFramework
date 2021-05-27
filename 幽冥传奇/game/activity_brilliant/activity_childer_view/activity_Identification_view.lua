IdentificationView = IdentificationView or BaseClass(ActBaseView)

function IdentificationView:__init(view, parent, act_id)
    self:LoadView(parent)
    self.auto_up_ident = false
end

function IdentificationView:__delete()
    if self.spare_89_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_89_time)
		self.spare_89_time = nil
    end
    if self.auto_btn_ident ~= nil then
        GlobalTimerQuest:CancelQuest(self.auto_btn_ident)
        self.auto_btn_ident = nil
    end
    if self.Ident_grade_list then
        self.Ident_grade_list:DeleteMe()
        self.Ident_grade_list = nil
    end
    if self.draw_record_list then
        self.draw_record_list:DeleteMe()
        self.draw_record_list = nil
    end
end

function IdentificationView:InitView()
    self:Show()
    self:CreateSpareFFTimer()
    self:RecordList()

    XUI.AddClickEventListener(self.node_t_list.layout_act_auto_draw_hook.btn_nohint_checkbox.node, function ()
        local vis = self.node_t_list.layout_act_auto_draw_hook.img_hook.node:isVisible()
        self.node_t_list.layout_act_auto_draw_hook.img_hook.node:setVisible(not vis)
    end, true)
    self.node_t_list.layout_act_auto_draw_hook.img_hook.node:setVisible(false)

    self.node_t_list.btn_automatic.node:setTitleText("自动鉴宝")
end

function IdentificationView:CloseCallBack()
    self.auto_up_ident = false
    if self.auto_btn_ident ~= nil then
        GlobalTimerQuest:CancelQuest(self.auto_btn_ident)
        self.auto_btn_ident = nil
    end
end

function IdentificationView:RefreshView(param_list)
    local bless_count = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.BSJD).config.nMaxBless
    local nConsume = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.BSJD).config.Reel.yb
    local bless_num = ActivityBrilliantData.Instance:GetBlessValue()
    local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.BSJD)
    local num = BagData.Instance:GetItemNumInBagById(cfg.config.Reel.id)
    self.node_t_list.lbl_pay_thing.node:setString(string.format(Language.ActivityBrilliant.IdentPay, num, cfg.config.Reel.count))
    self.node_t_list.lbl_num_count.node:setString(string.format("%d/%d", bless_num, bless_count))
    self.draw_record_list:SetData(ActivityBrilliantData.Instance:GetIdentRecord())
    self.node_t_list.prog9_sign_in.node:setPercent( bless_num / bless_count * 100 )
    XUI.AddClickEventListener(self.node_t_list.btn_to_fight.node, BindTool.Bind(self.OnClickFigthBtn, self), false)
    XUI.AddClickEventListener(self.node_t_list.btn_one_to.node, BindTool.Bind(self.OnClickOnceBtn, self), false)
    XUI.AddClickEventListener(self.node_t_list.btn_automatic.node, BindTool.Bind(self.AuthOnClickBtn,self),false)

    self.node_t_list.lbl_gold_tip.node:setString(string.format("材料不足,%s钻石代替", nConsume))
end

function IdentificationView:OnClickFigthBtn()
    ViewManager.Instance:OpenViewByDef(ViewDef.NewlyBossView.Wild)
    ActivityBrilliantCtrl.Instance:CloseView(self.act_id)
end

function IdentificationView:OnClickOnceBtn()
    local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.BSJD)
    local num = BagData.Instance:GetItemNumInBagById(cfg.config.Reel.id)

    local vis = self.node_t_list.layout_act_auto_draw_hook.img_hook.node:isVisible()
    if not (num < cfg.config.Reel.count and not vis) then
        ActivityBrilliantCtrl.ActivityReq(4,ACT_ID.BSJD)
    else
        SysMsgCtrl.Instance:FloatingTopRightText("材料不足")
        self.auto_up_ident = false
        if self.auto_btn_ident ~= nil then
            GlobalTimerQuest:CancelQuest(self.auto_btn_ident)
            self.auto_btn_ident = nil
            self.node_t_list.btn_automatic.node:setTitleText("自动鉴宝")
        end
    end
end

function IdentificationView:Show()
    local show_list = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.BSJD).config.exhibition
    local data_list = {}
    local temp_list = {}
    local cell = ActBaseCell.New()
    local ph_x,ph_y = self.node_t_list.img_show_one.node:getPosition()
    cell:SetPosition(ph_x, ph_y)
    cell:SetAnchorPoint(0.5,0.5)
    self.node_t_list.layout_Identification.node:addChild(cell:GetView(), 300)
    cell:SetData({item_id = show_list[1].id, num = show_list[1].count,is_bind = 0})
	for k, v in pairs(show_list) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
    end
    for i = 0, (#data_list - 1) do
		temp_list[i] = data_list[i+2]
	end
    if nil == self.Ident_grade_list then
		local ph = self.ph_list.ph_show_list
		self.Ident_grade_list = BaseGrid.New()
		local grid_node = self.Ident_grade_list:CreateCells({w=ph.w, h=ph.h, cell_count = #temp_list + 1, col=4, row=2, itemRender = ActBaseCell})
		grid_node:setPosition(ph.x,ph.y)
		grid_node:setAnchorPoint(0.5,0.5)
		self.node_t_list.layout_Identification.node:addChild(grid_node, 100)
        self.Ident_grade_list:SetDataList(temp_list)
	end
end

function IdentificationView:UpdateSpareFFTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.BSJD)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.lbl_time_ident.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function IdentificationView:CreateSpareFFTimer()
	self.spare_89_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateSpareFFTime, self), 1)
end

function IdentificationView:AuthOnClickBtn()
    self.auto_up_ident = not self.auto_up_ident
    if self.auto_up_ident == true then
        self.auto_btn_ident = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnClickOnceBtn, self), 0.5)
        self.node_t_list.btn_automatic.node:setTitleText("取消自动")
    else
        if self.auto_btn_ident ~= nil then
            GlobalTimerQuest:CancelQuest(self.auto_btn_ident)
            self.auto_btn_ident = nil
            self.node_t_list.btn_automatic.node:setTitleText("自动鉴宝")
        end
    end
end

function IdentificationView:RecordList()
	if nil == self.draw_record_list then
		local ph = self.ph_list.ph_render_list
		self.draw_record_list = ListView.New()
		self.draw_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, IBDrawRecordRender, nil, nil, nil)
		self.draw_record_list:GetView():setAnchorPoint(0.5, 0.5)
		self.draw_record_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_Identification.node:addChild(self.draw_record_list:GetView(), 100)
	end
end

IBDrawRecordRender = IBDrawRecordRender or BaseClass(BaseRender)
function IBDrawRecordRender:__init(w, h, list_view)	
	self.view_size = cc.size(310, 24)
	self.view:setContentSize(self.view_size)
	self.list_view = list_view
end

function IBDrawRecordRender:__delete()	
end

function IBDrawRecordRender:CreateChild()
	BaseRender.CreateChild(self)
	self.rich_text = RichTextUtil.ParseRichText(nil, "", 20, nil, 0, 0, self.view_size.width, self.view_size.height)
	self.rich_text:setAnchorPoint(0, 0)
	self.view:addChild(self.rich_text, 9)
end

function IBDrawRecordRender:OnFlush()
	if self.data == nil then return end
	local content = string.format(Language.ActivityBrilliant.AuthValueRecord,self.data.name,self.data.item_name)
	RichTextUtil.ParseRichText(self.rich_text, content, 18)
	self.rich_text:refreshView()
	local inner_size = self.rich_text:getInnerContainerSize()
	local size = {
		width = math.max(inner_size.width, self.view_size.width),
		height = math.max(inner_size.height, self.view_size.height),
	}
	self.rich_text:setContentSize(size)
	self.view:setContentSize(size)
	self.list_view:requestRefreshView()
end

function IBDrawRecordRender:CreateSelectEffect()
end


