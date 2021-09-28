local RANK_TOGGLE = 1
local MINGREN_TOGGLE = 2
local MEILI_TOGGLE = 3
local QINGYUAN_TOGGLE = 4

require("game/rank/rank_content_view")
require("game/rank/meili_content_view")
require("game/rank/rank_mingren_view")
require("game/rank/qingyuan_content")

RankView = RankView or BaseClass(BaseView)
function RankView:__init()
	self.ui_config = {"uis/views/rank_prefab","RankView"}
	self.full_screen = true
	self.play_audio = true
	self.is_cell_active = false
	self.cur_toggle = RANK_TOGGLE
	self.def_index = TabIndex.rank_content
	self.RankContentCurIndex = 0
	self.RankContentCurtype = 0
end

function RankView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("AddGold", BindTool.Bind(self.AddMoneyClick, self))
	self:ListenEvent("OpenRank", BindTool.Bind(self.RankClick, self))
	self:ListenEvent("OpenMingRen", BindTool.Bind(self.OnMingRenClick, self))
	self:ListenEvent("OpenMeiLi", BindTool.Bind(self.MeiLiClick, self))
	self:ListenEvent("OpenQingYuan", BindTool.Bind(self.OpenQingYuan, self))

	self.toggle_rank = self:FindObj("ToggleRank")
	self.toggle_mingren = self:FindObj("ToggleMingRen")
	self.toggle_meili = self:FindObj("ToggleMeiLi")
	self.toggle_qingyuan = self:FindObj("ToggleQingYuan")

	-- 子面板
	self.rank_content = self:FindObj("RankContent")

	self.qingyuan = self:FindObj("QingYuanContent")

	self.mingren_content = self:FindObj("MingRenContent")

	self.meili_content = self:FindObj("MeiLiContent")

	self.gold_text = self:FindVariable("gold_text")
	self.bind_gold_text = self:FindVariable("bind_gold_text")
	self.show_ming_red_point = self:FindVariable("show_ming_red_point")

	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)

	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	RankCtrl.Instance:SendRoleCapabilityOpera()

	-- 合服后屏蔽名人堂
	if IS_MERGE_SERVER then
		self.toggle_mingren:SetActive(false)
	end
end

function RankView:ReleaseCallBack()
	if self.mingren_content_view ~= nil then
		self.mingren_content_view:DeleteMe()
		self.mingren_content_view = nil
	end

	if self.rank_content_view ~= nil then
		self.rank_content_view:DeleteMe()
		self.rank_content_view = nil
	end

	if self.meili_content_view ~= nil then
		self.meili_content_view:DeleteMe()
		self.meili_content_view = nil
	end
	-- 清理变量和对象
	self.toggle_rank = nil
	self.toggle_mingren = nil
	self.toggle_meili = nil

	self.gold_text = nil
	self.bind_gold_text = nil
	self.show_ming_red_point = nil

	self.rank_content = nil
	self.mingren_content = nil
	self.meili_content = nil
	self.qingyuan = nil
	self.toggle_qingyuan = nil

	if self.rank_qingyuan_view then
		self.rank_qingyuan_view:DeleteMe()
		self.rank_qingyuan_view = nil
	end


	PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
end

function RankView:OpenCallBack()
	self.show_ming_red_point:SetValue(RankData.Instance:GetRedPoint())
	self:Flush()
end

function RankView:OnFlush(param_list)
	if nil ~= param_list then
		for k,v in pairs(param_list) do
			if k == "flush_rank" then
				local index = self:GetShowIndex()
				if index == TabIndex.rank_content then
					self.toggle_rank.toggle.isOn = true
					if self.rank_content_view then
						self.rank_content_view:Flush("flush_rank")
					end
				elseif index == TabIndex.rank_meili then
					self.toggle_meili.toggle.isOn = true
					if self.meili_content_view then
						self.meili_content_view:Flush("flush_rank")
					end
				elseif index == TabIndex.rank_qingyuan then
					self.toggle_qingyuan.toggle.isOn = true
					if self.rank_qingyuan_view then
						self.rank_qingyuan_view:Flush("flush_rank")
					end
				end
			end
		end

		if index == TabIndex.rank_mingren then
			self.toggle_mingren.toggle.isOn = true
			if self.mingren_content_view then
				self.mingren_content_view:Flush()
			end
		end
	end
end




function RankView:InitPanel(index)
	if index == TabIndex.rank_content and not self.rank_content_view then
		UtilU3d.PrefabLoad("uis/views/rank_prefab", "RankContent",
			function(obj)
				obj.transform:SetParent(self.rank_content.transform, false)
				obj = U3DObject(obj)
				self.rank_content_view = RankContentView.New(obj)
				self.rank_content_view:SetCurIndex(self.RankContentCurIndex)
				self.rank_content_view:SetCurType(self.RankContentCurtype)
				self.rank_content_view:Flush("change_tab",{index})
			end)
	elseif index == TabIndex.rank_mingren and not self.mingren_content_view then
		UtilU3d.PrefabLoad("uis/views/rank_prefab", "MinRenContent",
			function(obj)
				obj.transform:SetParent(self.mingren_content.transform, false)
				obj = U3DObject(obj)
				self.mingren_content_view = RankMingRenView.New(obj)
				self.mingren_content_view:Flush("change_tab",{index})
			end)
	elseif index == TabIndex.rank_meili and not self.meili_content_view then
		UtilU3d.PrefabLoad("uis/views/rank_prefab", "MeiLiContent",
			function(obj)
				obj.transform:SetParent(self.meili_content.transform, false)
				obj = U3DObject(obj)
				self.meili_content_view = MeiLiContentView.New(obj)
				self.meili_content_view:Flush("change_tab",{index})
			end)
	elseif index == TabIndex.rank_qingyuan and not self.rank_qingyuan_view then
		UtilU3d.PrefabLoad("uis/views/rank_prefab", "QingYuanContent",
		function(obj)
			obj.transform:SetParent(self.qingyuan.transform, false)
			obj = U3DObject(obj)
			self.rank_qingyuan_view = QingYuanContent.New(obj)
			self.rank_qingyuan_view:Flush("change_tab",{index})
		end)
	end
end

function RankView:ShowIndexCallBack(index)
	local index = index or self:GetShowIndex()
	self:InitPanel(index)
	if index == TabIndex.rank_content and self.rank_content_view then
		self.toggle_rank.toggle.isOn = true
		self.cur_toggle = RANK_TOGGLE
		self.rank_content_view:Flush("change_tab", {index})
	elseif index == TabIndex.rank_mingren and self.mingren_content_view then
		self.toggle_mingren.toggle.isOn = true
		self.cur_toggle = MINGREN_TOGGLE
		self.mingren_content_view:Flush("change_tab", {index})
	elseif index == TabIndex.rank_meili and self.meili_content_view then
		self.toggle_meili.toggle.isOn = true
		self.cur_toggle = MEILI_TOGGLE
		self.meili_content_view:Flush("change_tab", {index})
	elseif index == TabIndex.rank_qingyuan and self.rank_qingyuan_view then
		self.toggle_qingyuan.toggle.isOn = true
		self.cur_toggle = QINGYUAN_TOGGLE
		self.rank_qingyuan_view:Flush("change_tab", {index})
	end
end
--设置排行榜初始化在哪个分页（战力、光环。。。）
function RankView:SetCurIndex(index)
	self.RankContentCurIndex = index - 1
end

function RankView:SetCurtype(index)
	self.RankContentCurtype = index
end

function RankView:AddMoneyClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function RankView:FlushRedPoint()
	self.show_ming_red_point:SetValue(RankData.Instance:GetRedPoint())
end

function RankView:RankClick()
	if RANK_TOGGLE == self.cur_toggle then
		return
	end
	self:ShowIndex(TabIndex.rank_content)
	self.cur_toggle = RANK_TOGGLE
	if self.rank_content_view then
		self.rank_content_view:Flush()
	end
end

function RankView:OnMingRenClick()
	if MINGREN_TOGGLE == self.cur_toggle then
		return
	end
	self:ShowIndex(TabIndex.rank_mingren)
	self.cur_toggle = MINGREN_TOGGLE
	--self:Flush()
end

--顶部魅力榜按钮
function RankView:MeiLiClick()
	if MEILI_TOGGLE == self.cur_toggle then
		return
	end
	self:ShowIndex(TabIndex.rank_meili)
	self.cur_toggle = MEILI_TOGGLE
	if self.meili_content_view then
		self.meili_content_view:Flush()
	end
end

function RankView:OpenQingYuan()
	if QINGYUAN_TOGGLE == self.cur_toggle then
		return
	end
	self:ShowIndex(TabIndex.rank_qingyuan)
	self.cur_toggle = QINGYUAN_TOGGLE
	if self.rank_qingyuan_view then
		self.rank_qingyuan_view:Flush()
	end
end

function RankView:CloseCallBack()
	if self.rank_content_view then
		self.rank_content_view:CloseCallBack()
	end
	if self.meili_content_view then
		self.meili_content_view:CloseCallBack()
	end
end

function RankView:GetRankContentView()
	return self.rank_content_view
end

-- 玩家钻石改变时
function RankView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.gold_text:SetValue(CommonDataManager.ConverMoney(value))
	end
	if attr_name == "bind_gold" then
		self.bind_gold_text:SetValue(CommonDataManager.ConverMoney(value))
	end
end

function RankView:SetHighLighFalse()
	-- for k,v in pairs(self.cell_list) do
	-- 	v:SetHighLigh(false)
	-- end
end
