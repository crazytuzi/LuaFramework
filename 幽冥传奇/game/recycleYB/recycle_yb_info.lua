RecycleYBInfoView = RecycleYBInfoView or BaseClass()

function RecycleYBInfoView:__init()
	self.view = nil
	self.page = nil	
end

function RecycleYBInfoView:__delete()
	self:RemoveEvent()
	if self.recycle_YB_list then
		self.recycle_YB_list:DeleteMe()
		self.recycle_YB_list = nil
	end
	self.page = nil
	self.view = nil
	self.end_time = 0
end

function RecycleYBInfoView:RemoveEvent()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	if self.recycle_info then
		GlobalEventSystem:UnBind(self.recycle_info)
		self.recycle_info = nil
	end	
end
function RecycleYBInfoView:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreatRecycleYBInfoList()
	self:InitEvent()
	self:OnOpenDataChange()
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_longtect.node,Language.RecycleYB. Txt_LongTxt, 21)
	local shift_day = OpenServiceAcitivityData.GetServerCfg(OPEN_SERVER_CFGS_NAME[8]).endDay

	
	local h = tonumber(os.date("%H",OtherData.Instance.open_server_time))
	local m = tonumber(os.date("%M",OtherData.Instance.open_server_time))
	local s = tonumber(os.date("%S",OtherData.Instance.open_server_time))

	local time = OtherData.Instance.open_server_time - h * 60 * 60 - m * 60 - s
	self.end_time = time + shift_day * 24 * 3600
	XUI.AddClickEventListener(self.view.node_t_list.btn_qyesion.node, BindTool.Bind1(self.OnQuetion, self), true)
	
end	
--初始化事件
function RecycleYBInfoView:InitEvent()
		self.recycle_info = GlobalEventSystem:Bind(OpenServerActivityEventType.OPENSERVER_Recycle_YB, BindTool.Bind(self.OnOpenDataChange, self))
		self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.OverTime, self, -1),  1)
end

function RecycleYBInfoView:UpdateData(data)
	RecycleYBCtrl.SendRecycleInfoReq()
	self:OverTime()

end	

function RecycleYBInfoView:OnQuetion()
	DescTip.Instance:SetContent(Language.RecycleYB.DescContent, Language.RecycleYB.TipTitle)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RecycleYBInfoView:CreatRecycleYBInfoList()
	if nil == self.recycle_YB_list then
		self.recycle_YB_list = ListView.New()
		local ph = self.view.ph_list.ph_recycle_list
		self.recycle_YB_list:Create(ph.x, ph.y,ph.w,ph.h, nil, RecycleYBInfoRender, nil, nil, self.view.ph_list.ph_list_recycle)
		self.view.node_t_list.layout_recycleYB.node:addChild(self.recycle_YB_list:GetView(), 100)
		self.recycle_YB_list:SetSelectCallBack(BindTool.Bind(self.SelectCallItemBack, self))
		self.recycle_YB_list:SetJumpDirection(ListView.Top)
	end
end

function RecycleYBInfoView:SelectCallItemBack(item, index)
	if item == nil or item:GetData() == nil then return end
	local tmp_data = item:GetData()
end
function RecycleYBInfoView:OnOpenDataChange()
	local cfg = RecycleYBData.Instance:CurRecycleData()
	local cur_data = {}
	local opsever_time = OtherData.Instance:GetOpenServerDays()
	for i,v in ipairs(cfg) do
		if cfg[i].openDay ~= nil and cfg[i].endDay ~= nil and cfg[i].endDay >= opsever_time then
			table.insert( cur_data, cfg[i] )
		elseif cfg[i].openDay == nil and cfg[i].endDay == nil  then
			table.insert( cur_data, cfg[i] )
		end
	end
	self.recycle_YB_list:SetData(cur_data)
end
function RecycleYBInfoView:OverTime()
	local cur_time = TimeCtrl.Instance:GetServerTime() or os.time()
	local remain_time = self.end_time - cur_time
	local time_str = ""
	if remain_time > 0 then
		time_str = TimeUtil.Format2TableDHMS(remain_time)
	end
	local cur_str = 0
	if time_str and time_str.s~= nil  then
		if time_str.day ~= 0 then
			cur_str = string.format(Language.RecycleYB.TimeList[1],time_str.day).. Language.Common.TimeList.d..string.format(Language.RecycleYB.TimeList[2],time_str.hour).. Language.Common.TimeList.h..string.format(Language.RecycleYB.TimeList[3],time_str.min).. Language.Common.TimeList.min..string.format(Language.RecycleYB.TimeList[4],time_str.s).. Language.Common.TimeList.s
		elseif time_str.hour ~= 0 and time_str.day == 0 then
			cur_str = string.format(Language.RecycleYB.TimeList[2],time_str.hour).. Language.Common.TimeList.h..string.format(Language.RecycleYB.TimeList[3],time_str.min).. Language.Common.TimeList.min..string.format(Language.RecycleYB.TimeList[4],time_str.s).. Language.Common.TimeList.s
		elseif time_str.min ~= 0 and time_str.hour == 0 and time_str.day == 0 then
			cur_str =string.format(Language.RecycleYB.TimeList[3],time_str.min).. Language.Common.TimeList.min..string.format(Language.RecycleYB.TimeList[4],time_str.s).. Language.Common.TimeList.s
		elseif time_str.min == 0 and time_str.hour == 0 and time_str.day == 0 and time_str.s ~= 0 then
			cur_str =string.format(Language.RecycleYB.TimeList[4],time_str.s).. Language.Common.TimeList.s
		end
		RichTextUtil.ParseRichText(self.view.node_t_list.open_sever_time.node, Language.OpenServiceAcitivity.OpenSerTimeInfo..cur_str, 20)
	end
end

RecycleYBInfoRender = RecycleYBInfoRender or BaseClass(BaseRender)
function RecycleYBInfoRender:__init()
end

function RecycleYBInfoRender:__delete()
	

end

function RecycleYBInfoRender:CreateChild()
	BaseRender.CreateChild(self)
	self.on_count = 0
	XUI.AddClickEventListener(self.node_tree.txt_state.node, BindTool.Bind1(self.QuickLinks, self), true)
end

function RecycleYBInfoRender:OnFlush()
	if self.data == nil then return end
	RichTextUtil.ParseRichText(self.node_tree.txt_equipname.node, self.data.desc, 24)
   	XUI.RichTextSetCenter(self.node_tree.txt_equipname.node)
   	RichTextUtil.ParseRichText(self.node_tree.txt_exp.node, self.data.showAwards[1].count..Language.RecycleYB.RecycleYBExp, 25,cc.c3b(0x9e, 0x8a, 0x6f))
   	self.node_tree.txt_yb.node:setString(self.data.showAwards[2].count)
   	self.node_tree.txt_num.node:setString(self.data.rest_cnt)
   	local state_string = nil
   	local is_state = false
   	for i,v in ipairs(self.data.idList) do
   		local is_hasitem = ItemData.Instance:GetItem(v)
   		if is_hasitem then
   		 	is_state = true
   		 	break
   		 end
   	end
	if self.data.rest_cnt == 0  then
		state_string= Language.RecycleYB.RecycleTxt[4]
		self.node_tree.txt_state.node:setEnabled(false)
		self.node_tree.img_btn.node:setVisible(false)		
	else
		if self.data.state == 0 then
			if is_state then
				state_string= Language.RecycleYB.RecycleTxt[2]
	   			self.node_tree.txt_state.node:setEnabled(true)
	   			self.node_tree.img_btn.node:setVisible(true)
	   		else
	   			state_string= Language.RecycleYB.RecycleTxt[1]
	   			self.node_tree.txt_state.node:setEnabled(false)
	   			self.node_tree.img_btn.node:setVisible(false)
			end
		else
   			state_string= Language.RecycleYB.RecycleTxt[3]
   			self.node_tree.txt_state.node:setEnabled(false)
   			self.node_tree.img_btn.node:setVisible(false)	 	
		end
	end
  
   	RichTextUtil.ParseRichText(self.node_tree.txt_state.node, state_string, 24)
   	XUI.RichTextSetCenter(self.node_tree.txt_state.node)

end
function RecycleYBInfoRender:QuickLinks()
	RecycleYBCtrl.SendRecycleYBReq(self.data.re_index)
	
end