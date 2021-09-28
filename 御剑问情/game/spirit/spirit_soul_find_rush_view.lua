SoulQuickFlushView = SoulQuickFlushView or BaseClass(BaseView)

local COLUMN = 2
local SELECT_COLOR = {
	[1] = SOUL_SPECIAL_COLOR.RED,
	[2] = SOUL_SPECIAL_COLOR.ORANGE
}

function SoulQuickFlushView:__init(  )
	self.full_screen = false-- 是否是全屏界面
	self.ui_config = {"uis/views/spiritview_prefab", "SoulQuickFlushView"}
	self.play_audio = true
end

function SoulQuickFlushView:__delete(  )
	
end

function SoulQuickFlushView:LoadCallBack(  )
	self.item = {}
	self.rush_item = {}
	self.select_index = -1
	for i=1,2 do
		self.item[i] = self:FindObj("item" .. i)
		self.rush_item[i] = SoulQuickFlushItem.New(self.item[i])
		self.rush_item[i]:SetData(i)
		self.rush_item[i]:SetParent(self)

	end
	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow,self))
	self:ListenEvent("ClickStart",BindTool.Bind(self.ClickStart,self))
end

function SoulQuickFlushView:ReleaseCallBack()
	self.item = nil

	for k,v in pairs(self.rush_item) do
		v:DeleteMe()
	end
	self.rush_item = nil
	self.select_index = -1
end

function SoulQuickFlushView:CloseCallBack()
	self:FlushAllHL(-1)
end

function SoulQuickFlushView:CloseWindow()
	self:Close()
end

function SoulQuickFlushView:ClickStart()
	local gold_enough = SpiritData.Instance:SoulGoldIsEnough()
	if not gold_enough then
		TipsCtrl.Instance:ShowLackDiamondView()
		return 
	end

	if self.select_index == -1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SoulSelectSeqColor)
		return
	end

	local state = QUICK_FLUSH_STATE.REQUIRE_START
	local soul_bag_info = SpiritData.Instance:GetSpiritSoulBagInfo()
	local color = soul_bag_info and soul_bag_info.liehun_color
	local select_color = SELECT_COLOR[self.select_index]
	if color and color == select_color then
		state = QUICK_FLUSH_STATE.GAI_MING_ZHONG
	end

	SpiritData.Instance:SetQuickChangeLifeState(state)
	SpiritCtrl.Instance:SoulQuickFlushAction()
	self:Close()
end

function SoulQuickFlushView:FlushAllHL(index)
	if self.select_index == index then return end

	self.select_index = index or -1
	for k,v in pairs(self.rush_item) do
		v:IsShowHL(self.select_index)
	end
end

--------------------------------------------------------------------------

SoulQuickFlushItem = SoulQuickFlushItem or BaseClass(BaseRender)

function SoulQuickFlushItem:__init(  )
	self.text = self:FindVariable("text")
	self.show_hl = self:FindVariable("ShowHL")
	self:ListenEvent("OnToggle",BindTool.Bind(self.OnClick,self))
end

function SoulQuickFlushItem:__delete()
	if self.cell then
		self.cell:DeleteMe()
	end
	self.item_cell = nil
	self.image = nil
	self.parent = nil
end

function SoulQuickFlushItem:SetData(data)
	self.index = data
	local name = Language.JingLing.SoulQuickFlushItemTitle[self.index] or ""
	self.text:SetValue(name)
end

function SoulQuickFlushItem:SetParent(parent)
	self.parent = parent
end

function SoulQuickFlushItem:IsShowHL(index)
	self.show_hl:SetValue(index == self.index)
end

function SoulQuickFlushItem:OnClick()
	self.parent:FlushAllHL(self.index)
	local color = SELECT_COLOR[self.index] or -1
	SpiritData.Instance:SetSeclectColorSeq(color)
end