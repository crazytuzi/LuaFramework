require("game/festivalactivity/festival_activity_item/festival_activity_toggle_item")
require("game/festivalactivity/festival_activity_qiqiu/festival_activity_fangfeiqiqiu_rank")
require("game/festivalactivity/festival_activity_qiqiu/festival_activity_chuiqiqiu_rank")
FestivalActivityView = FestivalActivityView or BaseClass(BaseView)

function FestivalActivityView:__init()
	self.ui_config = {"uis/views/festivalactivity_prefab", "FestivalActivityView"}

	self.full_screen = true
	self.is_async_load = false
	self.toggle_group = {}
	self.click_toggle_tab = 0

	self.toggle_image_info = {}
	self.is_async_load_panel = {}

	self.variable = {}
end

function FestivalActivityView:__delete()
end

function FestivalActivityView:LoadCallBack()
	--obj
	self.list_view = self:FindObj("ToggleList")
	local delegate = self.list_view.list_simple_delegate
	delegate.NumberOfCellsDel = BindTool.Bind(self.GetToggleNumber, self)
	delegate.CellRefreshDel = BindTool.Bind(self.RefreshToggleCell, self)
	self.right_content = self:FindObj("RightContent")
	--variable

	--初始化需要显示的图片的组件
	--每多一个活动，必须多加个，不能修改以前的
	local child_panel = {
		["autumn"] = {
			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION_2] = {
				prefab_1 = "uis/views/festivalactivity/autumn_prefab",
				prefab_2 = "MakeMoonCakeContent",
				view_class = MakeMoonCakeView,
				flush_paramt = {["make_moon_cake"] = true,},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION_2,
				view = nil,
			},
			[ACTIVITY_TYPE.ACTIVITY_TYPE_EQUIPMENT] = {
				prefab_1 = "uis/views/festivalactivity/autumn_prefab",
				prefab_2 = "Festivalequipment",
				view_class = FestivalequipmentView,
				flush_paramt = {["fashion"] = true},
				toggle_index = ACTIVITY_TYPE.ACTIVITY_TYPE_EQUIPMENT,
				view = nil,
			},
			[ACTIVITY_TYPE.RAND_ACTIVITY_BIANSHENBANG] = {
				prefab_1 = "uis/views/festivalactivity/autumn_prefab",
				prefab_2 = "BianShenRankContent",
				view_class = BianShenRank,
				flush_paramt = {["bianshen"] = true},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_BIANSHENBANG,
				view = nil,
				send_req_mathod = function()
					FestivalActivityBianShenCtrl.Instance:SendBianShenSeq()
				end
			},
			[ACTIVITY_TYPE.RAND_ACTIVITY_BEIBIANSHENBANG] = {
				prefab_1 = "uis/views/festivalactivity/autumn_prefab",
				prefab_2 = "BeiBianShenRankContent",
				view_class = BeiBianShenRank,
				flush_paramt = {["beibianshen"] = true},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_BEIBIANSHENBANG,
				view = nil,
				send_req_mathod = function()
					FestivalActivityBianShenCtrl.Instance:SendBeiBianShenSeq()
				end
			},
			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE] = {
				prefab_1 = "uis/views/festivalactivity/autumn_prefab",
				prefab_2 = "FestivalLeiChongView",
				view_class = FestivalLeiChongView,
				flush_paramt = {["vesleichong"] = true},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE,
				view = nil,
			},
			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE] = {
				prefab_1 = "uis/views/festivalactivity/autumn_prefab",
				prefab_2 = "FesThreePirceView",
				view_class = VersionThreePieceView,
				flush_paramt = {["jixiangsanbao"] = true},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE,
				view = nil,
			},
			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT] = {
				prefab_1 = "uis/views/festivalactivity/autumn_prefab",
				prefab_2 = "ExpenseNiceGiftContent",
				view_class = ExpenseNiceGift,
				flush_paramt = {["expensenicegift"] = true, ["Roll"] = true},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT,
				view = nil,
				send_req_mathod = function()
					FestivalActivityCtrl.Instance:SendExpenseNiceGiftInfo(RA_EXPENSE_NICE_GIFT_OPERA_TYPE.RA_EXPENSE_NICE_GIFT_OPERA_TYPE_QUERY_INFO)
				end
			},

			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE] = {
				prefab_1 = "uis/views/festivalactivity/autumn_prefab",
				prefab_2 = "LianXuChongZhi",
				view_class = LianXuChongZhi,
				flush_paramt = {["lianxuchongzhi"] = true,},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE,
				view = nil,
			},
			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2] = {
				prefab_1 = "uis/views/festivalactivity/autumn_prefab",
				prefab_2 = "AutumnHappyErnieContent",
				view_class = AutumnHappyErnieView,
				flush_paramt = {["autumnhappyerniebiew"] = true,},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2,
				view = nil,
			},
		},

		["national"] = {
			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION_2] = {
				prefab_1 = "uis/views/festivalactivity/national_prefab",
				prefab_2 = "MakeMoonCakeContent",
				view_class = MakeMoonCakeView,
				flush_paramt = {["make_moon_cake"] = true,},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION_2,
				view = nil,
			},
			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIAOFEI_RANK] = {
				prefab_1 = "uis/views/festivalactivity/national_prefab",
				prefab_2 = "XiaoFeiRankContent",
				view_class = FestivalXiaoFeiRankView,
				flush_paramt = {["xiaofeirank"] = true,},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIAOFEI_RANK,
				view = nil,
			},
			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_RANK] = {
				prefab_1 = "uis/views/festivalactivity/national_prefab",
				prefab_2 = "ChongZhiRankContent",
				view_class = FestivalChongZhiRankView,
				flush_paramt = {["chongzhirank"] = true,},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_RANK,
				view = nil,
			},
			[ACTIVITY_TYPE.ACTIVITY_TYPE_EQUIPMENT] = {
				prefab_1 = "uis/views/festivalactivity/national_prefab",
				prefab_2 = "Festivalequipment",
				view_class = FestivalequipmentView,
				flush_paramt = {["fashion"] = true},
				toggle_index = ACTIVITY_TYPE.ACTIVITY_TYPE_EQUIPMENT,
				view = nil,
			},
			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PRINT_TREE] = {
				prefab_1 = "uis/views/festivalactivity/national_prefab",
				prefab_2 = "ChuiQiQiuRankContent",
				view_class = ChuiQiQiuRank,
				flush_paramt = {["chuiqiqiu"] = true},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PRINT_TREE,
				view = nil,
				send_req_mathod = function()
					FestivalActivityQiQiuCtrl.Instance:SendActivitySeq(RA_PLANTING_TREE_OPERA_TYPE.RA_PLANTING_TREE_OPERA_TYPE_RANK_INFO,
						RA_PLANTING_TREE_RANK_TYPE.PERSON_RANK_TYPE_PLANTING_TREE_PLANTING)
				end
			},
			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANGFEI_QIQIU] = {
				prefab_1 = "uis/views/festivalactivity/national_prefab",
				prefab_2 = "FangFeiQiQiuRankContent",
				view_class = FangFeiQiQiuRank,
				flush_paramt = {["fangfeiqiqiu"] = true},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANGFEI_QIQIU,
				view = nil,
				send_req_mathod = function()
					FestivalActivityQiQiuCtrl.Instance:SendActivitySeq(RA_PLANTING_TREE_OPERA_TYPE.RA_PLANTING_TREE_OPERA_TYPE_RANK_INFO,
						RA_PLANTING_TREE_RANK_TYPE.PERSON_RANK_TYPE_PLANTING_TREE_WATERING)
				end
			},
			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE] = {
				prefab_1 = "uis/views/festivalactivity/national_prefab",
				prefab_2 = "FestivalLeiChongView",
				view_class = FestivalLeiChongView,
				flush_paramt = {["vesleichong"] = true},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE,
				view = nil,
			},
			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE] = {
				prefab_1 = "uis/views/festivalactivity/national_prefab",
				prefab_2 = "FesThreePirceView",
				view_class = VersionThreePieceView,
				flush_paramt = {["jixiangsanbao"] = true},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE_FIVE,
				view = nil,
			},
			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT] = {
				prefab_1 = "uis/views/festivalactivity/national_prefab",
				prefab_2 = "ExpenseNiceGiftContent",
				view_class = ExpenseNiceGift,
				flush_paramt = {["expensenicegift"] = true, ["Roll"] = true},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT,
				view = nil,
				send_req_mathod = function()
					FestivalActivityCtrl.Instance:SendExpenseNiceGiftInfo(RA_EXPENSE_NICE_GIFT_OPERA_TYPE.RA_EXPENSE_NICE_GIFT_OPERA_TYPE_QUERY_INFO)
				end
			},

			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE] = {
				prefab_1 = "uis/views/festivalactivity/national_prefab",
				prefab_2 = "LianXuChongZhi",
				view_class = LianXuChongZhi,
				flush_paramt = {["lianxuchongzhi"] = true,},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE,
				view = nil,
			},
			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2] = {
				prefab_1 = "uis/views/festivalactivity/national_prefab",
				prefab_2 = "AutumnHappyErnieContent",
				view_class = AutumnHappyErnieView,
				flush_paramt = {["autumnhappyerniebiew"] = true,},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2,
				view = nil,
			},

			[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LANDINGF_REWARD] = {
				prefab_1 = "uis/views/festivalactivity/national_prefab",
				prefab_2 = "LandingReward",
				view_class = LandingReward,
				flush_paramt = {["landingeward"] = true,},
				toggle_index = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LANDINGF_REWARD,
				view = nil,
				-- send_req_mathod = function()
				-- 	FestivalActivityCtrl.Instance:SendExpenseNiceGiftInfo(RA_LOGIN_ACTIVE_GIFT_REQ_TYPE.RA_LOGIN_ACTIVE_GIFT_REQ_TYPE_FETCH)
				-- end
			},
			[FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_CRAZY_GIFT] = {
				prefab_1 = "uis/views/festivalactivity/national_prefab",
				prefab_2 = "CrazyGiftContent",
				view_class = CrazyGiftView,
				flush_paramt = {["crazygiftview"] = true,},
				toggle_index = FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_CRAZY_GIFT,
				view = nil,
	        },
		}
	}

	local festival_type = FestivalActivityData.Instance:GetBgCfg()
	self.child_panel = child_panel[festival_type.str_type]

	self.variable = self:InitPanelVariable(festival_type.str_type)

    self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
    self:InitImage()
    self.list_view.scroller:ReloadData(0)
end

function FestivalActivityView:ReleaseCallBack()
	for k, v in pairs(self.child_panel) do
		if v.view then
			v.view:DeleteMe()
		end
	end

	self.click_toggle_tab = 0

	for k,v in pairs(self.toggle_group) do
		if v then
			v:UBindRedPoint()
			v:DeleteMe()
			v = nil
		end
	end

	self.toggle_group = {}

	self.is_async_load_panel = {}

	self:CancelAllTimeQuest()

	self.list_view = nil
	self.right_content = nil

	self.variable = nil
end

function FestivalActivityView:OpenCallBack()
	FestivalActivityData.Instance:SetIsOpenPanel(true)
	RemindManager.Instance:Fire(RemindName.OpenFestivalPanel)
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_RANK, RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIAOFEI_RANK, RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE.RA_VERSION_CONTINUE_CHONGZHI_OPERA_TYPE_QUERY_INFO)
	self:Flush()
end

function FestivalActivityView:CloseCallBack()
end

function FestivalActivityView:SetRendering(value)
	BaseView.SetRendering(self, value)
	self:Flush()
end

function FestivalActivityView:OnFlush(param_t)
	local cfg = self.child_panel[self.click_toggle_tab]
	if cfg and cfg.view then
		if param_t then
			for k,v in pairs(param_t) do
				if cfg.flush_paramt[k] then
					cfg.view:Flush(k)
				elseif k == "toggle" then
					self.list_view.scroller:ReloadData(0)
					self:ActivityStatusChangeClick()
				else
					cfg.view:Flush()
				end
			end
		end
	end

	if 0 == self.click_toggle_tab then
		self:OnClickTab(FestivalActivityData.Instance:GetFirstOpenActivity())
	end
end

function FestivalActivityView:ActivityStatusChangeClick()
	local cfg = FestivalActivityData.Instance:GetActivityOpenList()
	if nil == cfg then
		return
	end

	for k,v in pairs(cfg) do
		if v.act_id == self.click_toggle_tab then
			if v.status_type == ACTIVITY_STATUS.CLOSE then
				self:OnClickTab(FestivalActivityData.Instance:GetFirstOpenActivity())
			end
		end
	end
end

function FestivalActivityView:InitPanelVariable(key)
	local variable =
	{
		["autumn"] = {
			bg_rawimage = self:FindVariable("BgRawImage"),
			bg_top_left = self:FindVariable("TopLeft"),
			bg_top_right = self:FindVariable("TopRight"),
			bg_bar_left = self:FindVariable("BarLeft"),
			bg_top_bar = self:FindVariable("TopBg"),
			bg_bar_right = self:FindVariable("BarRight"),
			bg_close = self:FindVariable("Close"),
			bg_close2 = self:FindVariable("Close2"),
			bg_content = self:FindVariable("ContentBg"),
			bg_scroller = self:FindVariable("ScrollerBg"),
			bg_title = self:FindVariable("TitleBg"),
			bg_buttom_lamp = self:FindVariable("ButtomLamp"),
			bg_title_icon = self:FindVariable("TitleIcon"),
			bg_title_type = self:FindVariable("TitleTextType"),
			bg_show_dis = self:FindVariable("ShowListDis"),
			bg_buttom_right = self:FindVariable("ButtonRight"),
			bg_left_buttom = self:FindVariable("LeftButtom"),
		},
		["national"] = {
			bg_rawimage = self:FindVariable("BgRawImage"),
			bg_top_left = self:FindVariable("TopLeft"),
			bg_top_right = self:FindVariable("TopRight"),
			bg_bar_left = self:FindVariable("BarLeft2"),
			bg_top_bar = self:FindVariable("TopBg"),
			bg_bar_right = self:FindVariable("BarRight2"),
			bg_close = self:FindVariable("Close"),
			bg_close2 = self:FindVariable("Close2"),
			bg_content = self:FindVariable("ContentBg"),
			bg_scroller = self:FindVariable("ScrollerBg"),
			bg_title = self:FindVariable("TitleBg"),
			bg_buttom_lamp = self:FindVariable("ButtomLamp"),
			bg_title_icon = self:FindVariable("TitleIcon"),
			bg_title_type = self:FindVariable("TitleTextType"),
			bg_show_dis = self:FindVariable("ShowListDis"),
			bg_buttom_right = self:FindVariable("ButtonRight"),
			bg_left_buttom = self:FindVariable("LeftButtom"),
		}
	}

	return variable[key]
end

function FestivalActivityView:InitImage()
	local bg_cfg = FestivalActivityData.Instance:GetBgCfg()
	local bg_type = bg_cfg.str_type
	self.variable.bg_rawimage:SetAsset(ResPath.GetRawImage(bg_cfg.bg_rawimage .. ".png"))

	self.variable.bg_top_left:SetAsset(ResPath.GetFestivalImage(bg_type, bg_cfg.bg_top_left))
	self.variable.bg_top_right:SetAsset(ResPath.GetFestivalImage(bg_type, bg_cfg.bg_top_right))

	self.variable.bg_bar_left:SetAsset(ResPath.GetFestivalImage(bg_type, bg_cfg.bg_bar_left))
	self.variable.bg_bar_right:SetAsset(ResPath.GetFestivalImage(bg_type, bg_cfg.bg_bar_right))

	self.variable.bg_close:SetAsset(ResPath.GetFestivalImage(bg_type, bg_cfg.bg_close))
	self.variable.bg_content:SetAsset(ResPath.GetFestivalImage(bg_type, bg_cfg.bg_content))
	self.variable.bg_scroller:SetAsset(ResPath.GetFestivalImage(bg_type, bg_cfg.bg_scroller))
	self.variable.bg_title:SetAsset(ResPath.GetFestivalImage(bg_type, bg_cfg.bg_title))
	self.variable.bg_top_bar:SetAsset(ResPath.GetFestivalImage(bg_type, bg_cfg.bg_top))
	self.variable.bg_buttom_lamp:SetAsset(ResPath.GetFestivalImage(bg_type, bg_cfg.bg_buttom_lamp))
	self.variable.bg_title_icon:SetAsset(ResPath.GetFestivalImage(bg_type, bg_cfg.bg_title_icon))
	self.variable.bg_buttom_right:SetAsset(ResPath.GetFestivalImage(bg_type, bg_cfg.buttom_right))
	self.variable.bg_close2:SetAsset(ResPath.GetFestivalImage(bg_type, bg_cfg.close2))
	self.variable.bg_left_buttom:SetAsset(ResPath.GetFestivalImage(bg_type, bg_cfg.left_buttom))

	self.variable.bg_title_type:SetValue(bg_cfg.bg_title_type)
	self.variable.bg_show_dis:SetValue(1 == bg_cfg.dis)
	self.toggle_image_info = {
		bg_type = bg_type,
		btn = bg_cfg.btn,
		btn_hl = bg_cfg.btn_hl,
		text_type = bg_cfg.text_type,
	}
end

function FestivalActivityView:FlushRedPoint()
	for k, v in pairs(FestivalActivityData.REMINDE_NAME_LIST) do
		RemindManager.Instance:Fire(v.remind_name)
	end
end

function FestivalActivityView:GetToggleNumber()
	return FestivalActivityData.Instance:GetActivityOpenNum()
end

function FestivalActivityView:RefreshToggleCell(cell, data_index)
	data_index = data_index + 1
	local toggle_cell = self.toggle_group[cell]

	if nil == toggle_cell then
		toggle_cell = FestivalActivityToggleItem.New(cell)
		self.toggle_group[cell] = toggle_cell
	end
	local open_list = FestivalActivityData.Instance:GetActivityOpenListByIndex(data_index)
	if nil == open_list then
		return
	end

	local open_cfg = FestivalActivityData.Instance:GetActivityOpenCfgById(open_list.act_id)
	if nil == open_cfg then
		return
	end

	toggle_cell:SetActId(open_list.act_id)
	toggle_cell:SetImageInfo(self.toggle_image_info)
	--打开默认面板第一个
	toggle_cell:ListenClick(BindTool.Bind(self.OnClickTab, self, open_list.act_id))

	toggle_cell:SetBindRedPoint(FestivalActivityData.REMINDE_NAME_LIST[open_list.act_id])
	toggle_cell:FlushHl(self.click_toggle_tab)
	toggle_cell:SetIndex(data_index)
	toggle_cell:SetData(open_cfg)
end

function FestivalActivityView:AsyncLoadView(tab)
	local cfg = self.child_panel[tab]
	if nil == cfg then
		return
	end

	local last_view = self.child_panel[self.click_toggle_tab]
	if last_view ~= nil and nil ~= last_view.view then
		last_view.view:SetActive(false)
	end

	self.click_toggle_tab = tab

	if cfg.view == nil then
		if self.is_async_load_panel[tab] then
			return
		end

		self.is_async_load_panel[tab] = true

		UtilU3d.PrefabLoad(cfg.prefab_1, cfg.prefab_2,
		function(prefab)
			prefab.transform:SetParent(self.right_content.transform, false)
			prefab = U3DObject(prefab)
			cfg.view = cfg.view_class.New(prefab)
			cfg.view:OpenCallBack()
			if cfg.toggle_index ~= self.click_toggle_tab then
				cfg.view:SetActive(false)
			end
		end)

	else
		cfg.view:SetActive(true)
		cfg.view:Flush()
	end
end

function FestivalActivityView:OnClickTab(tab)
	if tab == self.click_toggle_tab or nil == self.child_panel[tab] then
		return
	end
	local cfg = self.child_panel[tab]
	if nil ~= cfg.send_req_mathod then
		cfg.send_req_mathod()
	end

	self:AsyncLoadView(tab)
	self:FlushHl()

	local remind_info = FestivalActivityData.REMINDE_NAME_LIST[self.click_toggle_tab]
	if remind_info and remind_info.time and remind_info.time > 0 and RemindManager.Instance:GetRemind(remind_info.remind_name) > 0 then
		RemindManager.Instance:AddNextRemindTime(remind_info.remind_name, remind_info.time)
	end
end

function FestivalActivityView:FlushHl()
	for k,v in pairs(self.toggle_group) do
		if v then
			v:FlushHl(self.click_toggle_tab)
		end
	end
end

function FestivalActivityView:CloseView()
	self:Close()
end

function FestivalActivityView:ShowIndexCallBack(tab)
	self:OnClickTab(tab)
end

function FestivalActivityView:CancelAllTimeQuest()

end

function FestivalActivityView:ExpenseViewStartRoll()
	if nil ~= self.child_panel[FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT] then
		self.child_panel[FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT].view:StartRoll()
	end
end
