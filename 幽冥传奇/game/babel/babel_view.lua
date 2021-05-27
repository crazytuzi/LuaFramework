local BabelView = BaseClass(SubView)
function BabelView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/babel.png'
	}
	self.config_tab = {
		{"babel_ui_cfg", 1, {0}},
	}
	
	--self.title_img_path = ResPath.GetWord("MeiBaShouTao")
	
	-- require("scripts/game/meiba_shoutao/hand_add_view").New(ViewDef.MeiBaShouTao.HandAdd)
	-- require("scripts/game/meiba_shoutao/hand_compose_view").New(ViewDef.MainGodEquipView.ReXueFuzhuang.MeiBaShouTao)
end

function BabelView:ReleaseCallBack()
	if self.babel_list then
		self.babel_list:DeleteMe()
		self.babel_list = nil 
	end
	if self.rank_list then
		self.rank_list:DeleteMe()
		self.rank_list = nil 
	end
	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
	if self.alert_view then
		self.alert_view:DeleteMe()
		self.alert_view = nil 
	end
	-- if self.num_bar then
	-- 	self.num_bar:DeleteMe()
	-- 	self.num_bar = nil 
	-- end
	if self.data_event then
		GlobalEventSystem:UnBind(self.data_event)
		self.data_event = nil 
	end

	if self.ranking_data_event then
		GlobalEventSystem:UnBind(self.ranking_data_event)
		self.ranking_data_event = nil 
	end
end

function BabelView:LoadCallBack(index, loaded_times)
	BabelCtrl.Instance:SendOpeateBabel(OperateType.ReqRankingList)
	self:CreateBabelList()
	self:CreateCell()
	-- self:CreateNumbar()
	XUI.AddClickEventListener(self.node_t_list.img_zhanwen.node, BindTool.Bind1(self.OpenZhanWenView, self))
	XUI.AddClickEventListener(self.node_t_list.img_zhuanpan.node, BindTool.Bind1(self.OpenZhuanPanView, self))
	XUI.AddClickEventListener(self.node_t_list.btn_sweep.node, BindTool.Bind1(self.SweepFuben, self))
	XUI.AddClickEventListener(self.node_t_list.btn_fight.node, BindTool.Bind1(self.BtnFightFuben, self))
	XUI.AddClickEventListener(self.node_t_list.btn_tips.node, BindTool.Bind1(self.OpenTipsView, self))
	--btn_tips
	local ph_duihuan = self.ph_list["ph_link"]
	local text = RichTextUtil.CreateLinkText(Language.Babel.BuyNum, 19, COLOR3B.GREEN)
	text:setPosition(ph_duihuan.x + 20, ph_duihuan.y + 10)
	self.node_t_list.layout_babel.node:addChild(text, 90)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnBuyNum, self, 1), true)

	self.data_event = GlobalEventSystem:Bind(BABEL_EVENET.DATA_CHANGE, BindTool.Bind1(self.OnBabelDataChange,self))

	self.ranking_data_event = GlobalEventSystem:Bind(BABEL_EVENET.RANKING_DATA_CHANGE, BindTool.Bind1(self.OnBabelRankingEventChange,self))
end

function BabelView:OnBabelDataChange()
	self:FlushBtnShow()
	self:FlushLevelShow()
	self:FlushData()

	local index =  BabelData.Instance:CurShowTopIndex()
	if self.babel_list then
		 self.babel_list:SetSelectItemToTop(index)
	end
end

function BabelView:OnBabelRankingEventChange()
	self:FlushRank()
end

function BabelView:OnBuyNum()
	if BabelData.Instance:GetBuyNum() >= #BabelTowerFubenConfig.BuyConsume then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Babel.TipsHadBuyNum)
		return
	end
	local had_buy_num =  BabelData.Instance:GetBuyNum()
	local comsume_cfg = BabelTowerFubenConfig.BuyConsume[had_buy_num + 1]
	if comsume_cfg == nil then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Babel.TipsHadBuyNum)
		return
	end
	--PrintTable(comsume_cfg)
	if self.alert_view == nil then
		self.alert_view = Alert.New()
	end
	self.alert_view:SetOkString(Language.Common.Confirm)
    self.alert_view:SetCancelString(Language.Common.Cancel)
    local text = string.format(Language.Babel.BuyTips, comsume_cfg.consume[1].count)
    self.alert_view:SetLableString5(text, RichVAlignment.VA_CENTER)
    -- self.alert_view:SetLableString4(consume_data.btn_top_desc_rich, RichVAlignment.VA_CENTER)
    self.alert_view:SetOkFunc(function ()
    	if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) >= comsume_cfg.consume[1].count then
    		BabelCtrl.Instance:SendOpeateBabel(OperateType.BuyNum)
    	else
    		ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
    	end
    end)
    self.alert_view:Open()
end

function BabelView:OpenTipsView()
	DescTip.Instance:SetContent(Language.DescTip.BabelTowerContent, Language.DescTip.BableTowerTitle)
end 


function BabelView:BtnFightFuben()
	BabelCtrl.Instance:SendOpeateBabel(OperateType.Fighting)
end

function BabelView:SweepFuben()
	BabelCtrl.Instance:SendOpeateBabel(OperateType.Sweep)
end


function BabelView:CreateNumbar()
	if self.num_bar == nil then
		local ph = self.ph_list.ph_number1
		self.num_bar = NumberBar.New()
		self.num_bar:SetGravity(NumberBarGravity.Center)
	    self.num_bar:Create(ph.x + 20, ph.y - 15, 0, 0, ResPath.GetCommon("num_133_"))
	    self.num_bar:SetSpace(-8)
	    self.node_t_list.layout_babel.node:addChild(self.num_bar:GetView(), 101)
	 end
end

function BabelView:OpenZhanWenView()
	ViewManager.Instance:OpenViewByDef(ViewDef.BattleFuwen)
end

function BabelView:OpenZhuanPanView()
	ViewManager.Instance:OpenViewByDef(ViewDef.BabelTurnTable)
end


function BabelView:CreateBabelList()
	if self.babel_list == nil then
		local ph = self.ph_list.ph_list--获取区间列表
		self.babel_list = ListView.New()
		self.babel_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, BabelListItem, nil, nil, self.ph_list.ph_list_item)
		self.babel_list:SetItemsInterval(-45)--格子间距
		self.babel_list:SetMargin(0)
		self.babel_list:SetRefreshIsAsc(false)
		--self.babel_list:SetJumpDirection(ListView.Button)--置顶
		self.node_t_list.layout_babel.node:addChild(self.babel_list:GetView(), 20)
		--self.babel_list:SetSelectCallBack(BindTool.Bind(self.SelectEquipListCallback, self))
		self.babel_list:GetView():setAnchorPoint(0, 0)
	end


	if self.rank_list == nil then
		local ph = self.ph_list.ph_ranking_list--获取区间列表
		self.rank_list = ListView.New()
		self.rank_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, BabelRankingListItem, nil, nil, self.ph_list.ph_ranking_list_item)
		self.rank_list:SetItemsInterval(10)--格子间距
		self.rank_list:SetMargin(10)
		self.rank_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_babel.node:addChild(self.rank_list:GetView(), 20)
		--self.rank_list:SetSelectCallBack(BindTool.Bind(self.SelectEquipListCallback, self))
		self.rank_list:GetView():setAnchorPoint(0, 0)
	end
end

function BabelView:CreateCell( ... )
	self.cell_list = {}
	for i=1,3 do
		local ph = self.ph_list["ph_cell_"..i]
		local cell = BaseCell.New()
		cell:GetView():setPosition(ph.x, ph.y)
		self.node_t_list.layout_babel.node:addChild(cell:GetView(), 99)
		self.cell_list[i] = cell
	end
end

function BabelView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BabelView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BabelView:ShowIndexCallBack(index)
	self:Flush(index)
end


function BabelView:OnFlush()
	self:FlushRank()
	self:FlushBtnShow()
	self:FlushLevelShow()
	self:FlushData()

	local index =  BabelData.Instance:CurShowTopIndex()
	if self.babel_list then
		 self.babel_list:SetSelectItemToTop(index)
	end
end

function BabelView:FlushRank()
	local my_rank = BabelData.Instance:GetMyRank() or 0
	local text = my_rank
	if my_rank <= 0 then
		text = Language.RankingList.MyRanking
	end 
	--print("ssss", text)
	local my_ranling_text = string.format(Language.Babel.MyRanking, text)
	self.node_t_list.text_my_rank.node:setString(my_ranling_text)

	local data =  BabelData.Instance:GetRanlikListData()
	self.rank_list:SetDataList(data)
end


function BabelView:FlushBtnShow()
	local remain_num, totol_num = BabelData.Instance:GetRemianNum()
	local color = remain_num > 0 and "00fff00" or "ff0000" 
	local text = string.format(Language.Babel.FightNumTip, color, remain_num .. "/" .. totol_num)
	
	RichTextUtil.ParseRichText(self.node_t_list.rich_desc.node, text)

	XUI.SetButtonEnabled(self.node_t_list.btn_fight.node, remain_num > 0)

end

function BabelView:FlushLevelShow()
	local level = BabelData.Instance:GetTongguangLevel()
	local num =  BabelData.Instance:GetRecondmonsFs(level)
	-- self.num_bar:SetNumber(num)
	local next_level = level + 1
	if next_level > #BabelTowerFubenConfig.layerlist then
		next_level = #BabelTowerFubenConfig.layerlist
	end
	local text = string.format(Language.Babel.CurLevelShow, next_level)
	self.node_t_list.text_level.node:setString(text)

	local sweep_reward = BabelData.Instance:GetSweepRewardByLevel(level)
	for k, v in pairs(sweep_reward) do
		local cell = self.cell_list[k]
		if cell then
			cell:SetData({item_id = v.id, num = v.count, is_bind = v.bind})
		end
	end
	local vis = true
	if level <= 0 then
		vis = false
	end
	self.node_t_list.btn_sweep.node:setVisible(vis)
	local sweep_num = BabelData.Instance:GetSweepNum()
	local bool = true
	local text = Language.Babel.BtnTiTleText[1]
	if sweep_num > 0 then
		bool = false
		text = Language.Babel.BtnTiTleText[2]
	end
	self.node_t_list.btn_sweep.node:setTitleText(text)
	XUI.SetButtonEnabled(self.node_t_list.btn_sweep.node, bool)

	local vis_point1 = BabelData.Instance:GetCanSweep()

	local vis_point2 = BabelData.Instance:GetRemianChoujiangNum() > 0 and true or false

	self.node_t_list.img_saodang_point.node:setVisible(vis_point1)
	self.node_t_list.img_choujiang_point.node:setVisible(vis_point2)
end


function BabelView:FlushData()
	local data = BabelData.Instance:GetDataList()
	self.babel_list:SetDataList(data)
end



BabelListItem = BabelListItem or BaseClass(BaseRender)
function BabelListItem:__init()
	-- body
end

function BabelListItem:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil 
	end
	if self.level_num_bar then
		self.level_num_bar:DeleteMe()
		self.level_num_bar = nil 
	end
end


function BabelListItem:CreateChild()
	BaseRender.CreateChild(self)
	if self.cell == nil then
		local ph = self.ph_list.ph_cell
		self.cell = BaseCell.New()
		self.cell:GetView():setPosition(ph.x, ph.y- 10)
		self.view:addChild(self.cell:GetView(), 99)
	end
	self.cell:SetVisible(false)
	if self.level_num_bar == nil then
		local ph = self.ph_list.ph_number2
		self.level_num_bar = NumberBar.New()
		self.level_num_bar:SetGravity(NumberBarGravity.Center)
	    self.level_num_bar:Create(ph.x, ph.y - 15, 0, 0, ResPath.GetCommon("num_133_"))
	    self.level_num_bar:SetSpace(-8)
	  	self.view:addChild(self.level_num_bar:GetView(), 101)
	 end
	 self.node_tree.img_select.node:setVisible(false)
end

function BabelListItem:OnFlush()
	if self.data == nil then
		return
	end
	local vis = true
	if #self.data.awards <= 0 then
		vis = false
	end
	self.cell:SetVisible(vis)
	if self.data.awards[1] then
		self.cell:SetData({item_id = self.data.awards[1].id, num = self.data.awards[1].count, is_bind = self.data.awards[1].bind or 0})
	end
	self.level_num_bar:SetNumber(self.data.index)
	local max_level = BabelData.Instance:GetTongguangLevel()
	local vis1 = false
	local path = ResPath.GetBabelPath("gua_guan_bg")
	local vis3 = false
	if max_level >= self.data.index then
		vis1 =true
	elseif max_level + 1 == self.data.index then
		vis1 = true
		vis3 = true
		path = ResPath.GetBabelPath("gua_guan_bg2")
	end
	self.node_tree.img_gguoguan.node:setVisible(vis1)
	self.node_tree.img_gguoguan.node:loadTexture(path)
	local vis2 = false 
	if max_level == self.data.index then
		vis2 = true
	end
	self.node_tree.img_max_level.node:setVisible(vis2)
	self.node_tree.img_select.node:setVisible(vis3)

	self:SetGrey(not vis1)
end

function BabelListItem:SetGrey(boolean)
	self.cell:MakeGray(boolean)
	self.node_tree.img_bg.node:setGrey(boolean)
	self.node_tree.img_floor.node:setGrey(boolean)
	self.level_num_bar:SetGrey(boolean)
	
	local path = boolean and  ResPath.GetBigPainting("tongtianta_grey", false) or ResPath.GetBigPainting("tongtianta_light", false)
	self.node_tree.img_bg2.node:loadTexture(path)
end

function BabelListItem:CreateSelectEffect()
	
end


BabelRankingListItem = BabelRankingListItem or BaseClass(BaseRender)
function BabelRankingListItem:__init()
	-- body
end

function BabelRankingListItem:__delete()
	-- body
end

function BabelRankingListItem:CreateChild()
	BaseRender.CreateChild(self)
end

function BabelRankingListItem:OnFlush()
	if self.data == nil then
		return
	end
	local vis = false
	local text = self.index
	if self.index <= 3 then
		vis = true
		self.node_tree.img_rank.node:loadTexture(ResPath.GetBabelPath("rank_".. self.index))
		text =""
	end
	self.node_tree.img_rank.node:setVisible(vis)
	self.node_tree.text_rank.node:setString(text)
	self.node_tree.text_name.node:setString(self.data.name)
	self.node_tree.text_level.node:setString(self.data.floor.."层")
end

function BabelRankingListItem:CreateSelectEffect()
	
end

return BabelView