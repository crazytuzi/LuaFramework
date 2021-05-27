local CsSuitTip = BaseClass(BaseView)

function CsSuitTip:__init()
	self:SetModal(true)
	self.config_tab = {
		{"common_small_ui", 2, {0}},
	}
	
	-- require("scripts/game/luxury_equip_tip/name").New(ViewDef.LuxuryEquipTip.name)
	self.index = 1
end

function CsSuitTip:ReleaseCallBack()
end

function CsSuitTip:LoadCallBack(index, loaded_times)
	-- self.data = LuxuryEquipTipData.Instance				--数据
	-- LuxuryEquipTipData.Instance:AddEventListener(LuxuryEquipTipData.INFO_CHANGE, BindTool.Bind(self.OnDataChange, self))
end

function CsSuitTip:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end


function CsSuitTip:ShowIndexCallBack( ... )
	self:Flush()
end

function CsSuitTip:OnFlush( ... )
	self:FlushShow()
end

function CsSuitTip:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CsSuitTip:OnDataChange(vo)
end

function CsSuitTip:SetData(data)
	self.data = data
	self:Open()
end

function CsSuitTip:FlushShow()
	local space = 8
	if self.index == 2 then
		space = 15
	elseif self.index == 3 then
		space = 18
	end
	self.node_t_list.lbl_title.node:setString(self.data.title)
	self.node_t_list.lbl_title.node:setColor(self.data.title_color or COLOR3B.WHITE)
	RichTextUtil.ParseRichText(self.node_t_list.rich_cur_text.node, self.data.curr_txt, 20)
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_cur_text.node,space)

	RichTextUtil.ParseRichText(self.node_t_list.rich_next_text.node, self.data.next_txt, 20)
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_next_text.node,space)
	
	-- v:refreshView()
	-- v:getInnerContainerSize().height

	if "" == self.data.next_txt then
		self.node_t_list.img9_bg.node:setContentWH(393, 200)
		self.node_t_list.img9_bg.node:setAnchorPoint(0.5, 0)
	end
end

return CsSuitTip