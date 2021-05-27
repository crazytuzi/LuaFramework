------------------------------------------------------------
--钻石回收View
------------------------------------------------------------
DiamondBackView = DiamondBackView or BaseClass(BaseView)

function DiamondBackView:__init()
	-- self.title_img_path = ResPath.GetWord("word_dia_back")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
	}
	self.config_tab = {
		{"diamond_back_ui_cfg", 1, {0}},
		{"diamond_back_ui_cfg", 7, {0}, nil, 999},
	}

	self.btn_info = {
		ViewDef.DiamondBackView.OneEquipLimitView,
		ViewDef.DiamondBackView.BossFirstKillView,
		ViewDef.DiamondBackView.SuitLimitBackView,
		ViewDef.DiamondBackView.OneForeverBackView,
		ViewDef.DiamondBackView.BackRecordView,
	}

	require("scripts/game/diamond_back/one_equip_limit").New(ViewDef.DiamondBackView.OneEquipLimitView, self)
	require("scripts/game/diamond_back/suit_limit_back").New(ViewDef.DiamondBackView.SuitLimitBackView, self)
	require("scripts/game/diamond_back/one_forever_back").New(ViewDef.DiamondBackView.OneForeverBackView, self)
	require("scripts/game/diamond_back/boss_kill_info").New(ViewDef.DiamondBackView.BossFirstKillView, self)
	require("scripts/game/diamond_back/back_record").New(ViewDef.DiamondBackView.BackRecordView, self)
end

function DiamondBackView:__delete()
end

function DiamondBackView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function DiamondBackView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
    	self:InitTabbar()

    	-- XUI.AddClickEventListener(self.node_t_list.btn_ques4.node,  BindTool.Bind(self.OpenTips, self), true)
    end
end

function DiamondBackView:InitTabbar()
	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	local ph = self.ph_list["ph_tabbar"] or {x = 0, y = 0, w = 10, h = 10}
	self.tabbar = Tabbar.New()
	-- self.tabbar:SetTabbtnTxtOffset(2, 12)
	self.tabbar:SetClickItemValidFunc(function(index)
		return ViewManager.Instance:CanOpen(self.btn_info[index]) 
	end)
	self.tabbar:CreateWithNameList(self.node_t_list["layout_bg"].node, ph.x, ph.y, BindTool.Bind(self.SelectTabCallback, self),
		name_list, true, ResPath.GetCommon("toggle_120"))
	DiamondBackCtrl.Instance:SendBackData(1)

	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:CanOpen(v) then
			self.tabbar:SelectIndex(k)
			break
		end
	end
end

-- function DiamondBackView:OpenTips( ... )
-- 	DescTip.Instance:SetContent(Language.DescTip.ZuanshiRecycleContent, Language.DescTip.ZuanshiRecycleTitle)
-- end

--选择标签回调
function DiamondBackView:SelectTabCallback(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])

	self.node_t_list.txt_name.node:setString(Language.DiamondBack.LblName[index])
	self.node_t_list.txt_price.node:setString(Language.DiamondBack.LblPrice[index])
	self.node_t_list.txt_rem_num.node:setString(Language.DiamondBack.LblNum[index])
	self.node_t_list.txt_fun.node:setString(Language.DiamondBack.LblState[index])
	self.node_t_list["lbl_tip"].node:setString(Language.DiamondBack.DiamondBackTip[index])

	local index_list = {1,4,2,3,5} -- 修复功能更改顺序后未正确请求
	DiamondBackCtrl.Instance:SendBackData(index_list[index])

	local path_list = {
		ResPath.GetBigPainting("diamond_back_bg1"),
		ResPath.GetBigPainting("diamond_back_bg2"),
		ResPath.GetBigPainting("diamond_back_bg3"),
		ResPath.GetBigPainting("diamond_back_bg3"),
	}
	local path = path_list[index]
	if path then
		self.node_t_list["img_bg"].node:loadTexture(path)
	end
end

function DiamondBackView:OpenCallBack()
	if self.tabbar then
		for k, v in pairs(self.btn_info) do
			if ViewManager.Instance:CanOpen(v) then
				self.tabbar:SelectIndex(k)
				ViewManager.Instance:OpenViewByDef(self.btn_info[k])
				break
			end
		end	
	end
end

function DiamondBackView:ShowIndexCallBack(index)
	self:FlushBtns()
end

function DiamondBackView:OnFlush(param_t, index)
end

function DiamondBackView:CloseCallBack()
end

function DiamondBackView:FlushBtns()
	for k, v in pairs(self.btn_info) do
		-- if ViewManager.Instance:IsOpen(v) then
		-- 	self.tabbar:ChangeToIndex(k)
		-- end

		local vis = (ViewManager.Instance:CanOpen(v))
		self.tabbar:SetToggleVisible(k, vis)
	end
end