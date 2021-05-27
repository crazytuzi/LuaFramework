GrabRedEnvelopeView =GrabRedEnvelopeView or BaseClass(BaseView)
function GrabRedEnvelopeView:__init( ... )
	self:SetModal(true)
	--self.view_cache_time = 5
	
	self.texture_path_list[1] = 'res/xui/grap_red_envlope.png'
	--self.is_any_click_close = true
	--new_fashion_ui_cfg
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"grop_godenvlope_ui_cfg", 1, {0}},
		--{"common_ui_cfg", 2, {0}, nil, 999},
	}
end


function GrabRedEnvelopeView:__delete( ... )
	-- body
end


function GrabRedEnvelopeView:ReleaseCallBack( ... )
	if self.record_list then
		self.record_list:DeleteMe()
		self.record_list = nil
	end

	if self.numbar_zs then
		self.numbar_zs:DeleteMe()
		self.numbar_zs = nil
	end

	if self.numbar_first then
		self.numbar_first:DeleteMe()
		self.numbar_first = nil
	end

	if self.numbar_second then
		self.numbar_second:DeleteMe()
		self.numbar_second = nil 
	end

	if self.grap_red_envlope then
		GlobalEventSystem:UnBind(self.grap_red_envlope)
		self.grap_red_envlope = nil
	end
	if self.recharge_change then
		GlobalEventSystem:UnBind(self.recharge_change)
		 self.recharge_change = nil
	end

	if self.effect_show1 then
		self.effect_show1:setStop()
		self.effect_show1 = nil
	end
end


function GrabRedEnvelopeView:LoadCallBack()
	GrabRedEnvelopeCtrl.Instance:SendGetChargeRedEnvlopeData()
	XUI.AddClickEventListener(self.node_t_list.layout_close.node, BindTool.Bind1(self.CloseView, self))
	XUI.AddClickEventListener(self.node_t_list.btn_tips.node, BindTool.Bind1(self.OpenTipsShow, self))
	XUI.AddClickEventListener(self.node_t_list.btn_open_develope.node, BindTool.Bind1(self.OpenDeVelope, self), true)
	self:CreateRecordList()
	self:CreteNumbar()

	self.grap_red_envlope = GlobalEventSystem:Bind(GRAP_REDENVELOPE_EVENT.GetGrapRedEnvlope, BindTool.Bind1(self.FlushViewShow,self))
	self.recharge_change = GlobalEventSystem:Bind(OtherEventType.TODAY_CHARGE_GOLD_CHANGE, BindTool.Bind1(self.FlushViewShow,self))
end

function GrabRedEnvelopeView:CreteNumbar( ... )
	if nil == self.numbar_zs then
		local ph = self.ph_list["ph_number"]
		self.numbar_zs = NumberBar.New()
		self.numbar_zs:SetRootPath(ResPath.GetGrapRedEnvlopePath("num_119_"))
		self.numbar_zs:SetPosition(ph.x, ph.y)
		self.numbar_zs:SetGravity(NumberBarGravity.Center)
		self.node_t_list["layout_red_develope"].node:addChild(self.numbar_zs:GetView(), 300, 300)
	end
	--self.numbar_zs:SetNumber(10000)

	if nil == self.numbar_first then
		local ph = self.ph_list["ph_number_first"]
		self.numbar_first = NumberBar.New()
		self.numbar_first:SetRootPath(ResPath.GetGrapRedEnvlopePath("num_120_"))
		self.numbar_first:SetPosition(ph.x + 18, ph.y - 4)
		self.numbar_first:SetGravity(NumberBarGravity.Center)
		self.node_t_list["layout_first"].node:addChild(self.numbar_first:GetView(), 300, 300)
	end

	--self.numbar_first:SetNumber(99)


	if nil == self.numbar_second then
		local ph = self.ph_list["ph_need_numbar"]
		self.numbar_second = NumberBar.New()
		self.numbar_second:SetGravity(NumberBarGravity.Center)
		self.numbar_second:SetRootPath(ResPath.GetGrapRedEnvlopePath("num_120_"))
		self.numbar_second:SetPosition(ph.x + 25, ph.y -2)
		
		self.node_t_list["layout_second"].node:addChild(self.numbar_second:GetView(), 300, 300)
	end
	--self.numbar_sceond:SetNumber(10000)
end

function GrabRedEnvelopeView:OpenDeVelope()
	local IsAllGet = GrabRedEnvelopeData.Instance:HadGetAll()
	if GrabRedEnvelopeData.Instance:GetGrapRedEnvlope() <= 0 and (not IsAllGet)  then --乳沟没有抢，才发协议过去
		GrabRedEnvelopeCtrl.Instance:SendGrapRedEnvlopeReq()
	end
	if nil == self.effect_show1 then
		--local pos_x, pos_y = self.node_t_list.btn_open_develope.node:getPosition()
	 	self.effect_show1 = AnimateSprite:create()
	 	self.effect_show1:setPosition(650, 400)
	 	self.node_t_list.layout_red_develope.node:addChild(self.effect_show1, 999)
	end
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1166)
	self.effect_show1:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
	if not IsAllGet then
		ViewManager.Instance:OpenViewByDef(ViewDef.GrapRobRedEnvelopeTip)
	end
end

function GrabRedEnvelopeView:OpenTipsShow()
	DescTip.Instance:SetContent(Language.DescTip.GrapGodEnvelopeContent, Language.DescTip.GrapGodEnvelopeTitle)
end


function GrabRedEnvelopeView:CreateRecordList()

	if nil == self.record_list then
		local ph = self.ph_list.pH_recoed_list--获取区间列表
		self.record_list = ListView.New()
		self.record_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, RecordListItem, nil, nil, self.ph_list.ph_list_item)
		self.record_list:SetItemsInterval(5)--格子间距
		self.record_list:SetMargin(3)
		self.record_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_red_develope.node:addChild(self.record_list:GetView(), 20)
		--self.record_list:SetSelectCallBack(BindTool.Bind(self.SelectEquipListCallback, self))
		self.record_list:GetView():setAnchorPoint(0, 0)
	end
	-- body
end

function GrabRedEnvelopeView:OpenCallBack()
	-- body
end


function GrabRedEnvelopeView:ShowIndexCallBack(index)
	self:Flush(index)
end

function GrabRedEnvelopeView:OnFlush( )
	self:FlushViewShow()
end

function GrabRedEnvelopeView:FlushIndex()
	self:Flush(index)
end


function GrabRedEnvelopeView:FlushViewShow()
	local level = GrabRedEnvelopeData.Instance:GetCurLevel() or 0
  	local vis2 = false 
  	if level == 1 and (not ChargeRewardData.Instance:IsShouChong()) then
  		vis2 = true
  	end
  
  	if GrabRedEnvelopeData.Instance:GetIsFirstCharge() == 1 then
  		vis2 = true
  	end
  
	self.node_t_list.layout_first.node:setVisible(vis2)

	local IsAllGet = GrabRedEnvelopeData.Instance:HadGetAll()
	local need_num = GrabRedEnvelopeData.Instance:GetNeedNum()
	local vis1 = false 
	if  GrabRedEnvelopeData.Instance:GetIsShowMoney(level) and (not IsAllGet) and ChargeRewardData.Instance:IsShouChong() and GrabRedEnvelopeData.Instance:GetIsFirstCharge() == 0 then
		vis1 = true
	end
	
	self.node_t_list.img_tip.node:setVisible(vis1)

	

	local vis = need_num > 0 and (not GrabRedEnvelopeData.Instance:GetIsShowMoney(level) and (not IsAllGet)) and true or false
	self.node_t_list.layout_second.node:setVisible(vis)
	local need_number = GrabRedEnvelopeData.Instance:GetNeedNumber()
	self.node_t_list.layout_had_get.node:setVisible(IsAllGet)

	local zs_num = GrabRedEnvelopeData.Instance:GetZuanShiNum()
	self.numbar_zs:SetNumber(zs_num)
	
	self.numbar_second:SetNumber(need_number)
	local first_number = GrabRedEnvelopeData.Instance:GetCanGetZuanSHi()
	self.numbar_first:SetNumber(first_number)

	local list = GrabRedEnvelopeData.Instance:GetRecordList()
	self.record_list:SetDataList(list)
end


function GrabRedEnvelopeView:CloseView()
	if self.is_close_effect then
		return
	end	
	self.is_close_effect = false
	local btn = ViewManager.Instance:GetUiNode("MainUi", "red_icon")
	if btn then
		local view = self.real_root_node
		local temp_posx, temp_posy = self.real_root_node:getPosition()
		self.is_close_effect = true
		view:setBackGroundColorOpacity(0)
		local size = btn:GetView():getContentSize()
		local pos = btn:GetView():convertToWorldSpace(cc.p(size.width * 0.5, size.height * 0.5))
		local life_time = cc.pGetLength(cc.pSub(pos,cc.p(temp_posx, temp_posy)))*0.00035
		local callback = cc.CallFunc:create(function()
				view:stopAllActions()
				self.is_close_effect = false
				self:CloseHelper()
				view:setPosition(temp_posx,temp_posy)
				view:setScale(1)
				view:setBackGroundColorOpacity(self.background_opacity)
		end)
		local action = cc.Spawn:create(cc.MoveTo:create(life_time + 0.2,pos),cc.ScaleTo:create(life_time+0.2, 0))
		local queue = cc.Sequence:create(action,callback)
		view:runAction(queue)

	else
		self:CloseHelper()
	end
end

function GrabRedEnvelopeView:CloseCallBack( ... )
	
end


RecordListItem = RecordListItem or BaseClass(BaseRender)
function RecordListItem:__init( ... )
	-- body
end

function RecordListItem:__delete( ... )
	-- body
end

function RecordListItem:CreateChild( ... )
	BaseRender.CreateChild(self)
end

function RecordListItem:OnFlush( ... )
	if self.data == nil then
		return 
	end
	local data = Split(self.data, "#")
	local text = string.format(Language.QiangHongBao.desc, data[1], data[2])
	RichTextUtil.ParseRichText(self.node_tree.text_desc.node, text)
end

function RecordListItem:CreateSelectEffect()
	
end