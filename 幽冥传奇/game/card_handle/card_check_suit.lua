CardCheckSuit = CardCheckSuit or BaseClass(BaseView)

function CardCheckSuit:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.texture_path_list = {
		--'res/xui/luxury_equip_tip.png'
	}
	self.config_tab = {
		{"card_handlebook_ui_cfg", 5, {0}},
	}
end

function CardCheckSuit:ReleaseCallBack()
	
end

function CardCheckSuit:LoadCallBack(index, loaded_times)
	
end

function CardCheckSuit:OpenCallBack()

end


function CardCheckSuit:SetType(type)
	self.type = type
end

function CardCheckSuit:ShowIndexCallBack()
	self:Flush()
end

function CardCheckSuit:OnFlush()
	self:FlushShow()
end

function CardCheckSuit:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CardCheckSuit:FlushShow()
	local data = CardHandlebookData.Instance:GetCardAddtionStringDataByIdx(self.type)

	local rich_text = RichTextUtil.ParseRichText(self.node_t_list.rich_cur_text.node, data[3], 20, COLOR3B.OLIVE)
	rich_text:setVerticalSpace(10)

	local rich_text = RichTextUtil.ParseRichText(self.node_t_list.rich_next_text.node, data[4], 20, COLOR3B.GRAY)
	rich_text:setVerticalSpace(10)
end


