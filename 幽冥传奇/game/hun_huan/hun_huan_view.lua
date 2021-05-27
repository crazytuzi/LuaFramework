HunHuanView = HunHuanView or BaseClass(BaseView)

function HunHuanView:__init()
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/hun_huan.png'
	}
	self.config_tab = {
		{"hun_huan_ui_cfg", 1, {0}},
	}
	
	-- require("scripts/game/hun_huan/name").New(ViewDef.HunHuan.name)
end

function HunHuanView:ReleaseCallBack()
	if self.list then
		self.list:DeleteMe()
	end
	self.list = nil

	if self.online_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.online_timer)
	end
	self.online_timer = nil
end

function HunHuanView:LoadCallBack(index, loaded_times)
	self.data = HunHuanData.Instance				--数据
	HunHuanData.Instance:AddEventListener(HunHuanData.INFO_CHANGE, BindTool.Bind(self.OnDataChange, self))

	self:CreateList()

	--倒计时
	self.online_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateOnlineTime, self), 1)
	self:UpdateOnlineTime()
end

--右边预览
function HunHuanView:CreateList()
	if self.list == nil then
		local ph = self.ph_list.ph_list
		self.list = ListView.New()
		self.list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, HunHuanShowRender, nil, nil, self.ph_list.ph_item)
		-- self.list:SetSelectCallBack(BindTool.Bind(self.OnSelectPreviewItemCallback, self))
		self.list:SetItemsInterval(84)
		-- self.list:SetJumpDirection(ListView.Bottom)
		self.list:SetMargin(2)
		self.node_t_list.layout_bg.node:addChild(self.list:GetView(), 300)
		self.list:SetDataList(self.data:GetDataList())
	end	
end

function HunHuanView:UpdateOnlineTime()
	self.node_t_list.lbl_space_time.node:setString("剩余时间: " .. TimeUtil.FormatSecond2Str(HunHuanData.GetSpaceTime()))
end

function HunHuanView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function HunHuanView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function HunHuanView:ShowIndexCallBack()
	self.list:SetDataList(self.data:GetDataList())
end

function HunHuanView:OnDataChange(vo)
	self.list:SetDataList(self.data:GetDataList())
end



--创建右边
HunHuanShowRender = HunHuanShowRender or BaseClass(BaseRender)
function HunHuanShowRender:__init()
end

function HunHuanShowRender:__delete()	
	if self.hero_model then
		self.hero_model:DeleteMe()
	end
	self.hero_model = nil
end

local idx2posY = {80, 110, 120}
local idx2color = {"1ED1E1", "B920BD", "C10909"}
function HunHuanShowRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_buy.node, function ()
		HunHuanCtrl.SendHunHuanBuy(self:GetIndex())
	end)

	self.hero_model = MonsterDisplay.New(self.view, -1)
	self.hero_model:SetPosition(80, idx2posY[self:GetIndex()])
	self.hero_model:SetScale(self:GetIndex() ~= 1 and 0.8 or 1)
	self.hero_model:SetMonsterVo({
		[OBJ_ATTR.ENTITY_MODEL_ID] = HeroConfig.soulRangCfg[self:GetIndex()].modelid,
	})
end


function HunHuanShowRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.lbl_attr.node:setString(string.format("战宠伤害+%s%%", HeroConfig.soulRangCfg[self:GetIndex()].attrs[1].value / 100))
	self.node_tree.lbl_attr.node:setColor(Str2C3b(idx2color[self:GetIndex()]))
	self.node_tree.lbl_gold.node:setString(self.data.consume[1].count)
	self.node_tree.btn_buy.node:setTitleText(HunHuanData.Instance:GetIsLingQuByIdx(self:GetIndex()) and "已获取" or "租 借")
end

function HunHuanShowRender:CreateSelectEffect()
end