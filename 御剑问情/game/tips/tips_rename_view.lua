TipsRenameView = TipsRenameView or BaseClass(BaseView)

function TipsRenameView:__init()
	self.ui_config = {"uis/views/tips/renametip_prefab", "RenamePopupTip"}
	self.view_layer = UiLayer.Pop

	self.data = nil
	self.name = ""
	self.callback = nil
	self.is_need_pro = false
	self.play_audio = true
end

function TipsRenameView:__delete()
end

function TipsRenameView:LoadCallBack()
	self.chat_input = self:FindObj("chat_input")
	self.show_need_pro = self:FindVariable("Is_need_pro")
	self.pro_name = self:FindVariable("pro_name")
	self.is_show_des = self:FindVariable("is_show_des")
	self.des_text = self:FindVariable("des")
	self.des_text_2 = self:FindVariable("des_2")
	self.title = self:FindVariable("Title")
	self.show_des_2 = self:FindVariable("show_des_2")
	self:ListenEvent("rename",BindTool.Bind(self.RenameOnChange, self))
	self:ListenEvent("sure_btn",BindTool.Bind(self.SureBtnOnClick, self))
	self:ListenEvent("cancel_btn",BindTool.Bind(self.CancelBtnOnClick, self))
	self:ListenEvent("ValueChange",BindTool.Bind(self.OnInputChange, self))
end

function TipsRenameView:ReleaseCallBack()
	-- 清理变量和对象
	self.chat_input = nil
	self.show_need_pro = nil
	self.pro_name = nil
	self.is_show_des = nil
	self.des_text = nil
	self.des_text_2 = nil
	self.title = nil
	self.show_des_2 = nil
end

function TipsRenameView:OpenCallBack()
	self.name = ""
	self.chat_input.input_field.text = self.name
	if self.des ~= nil then
		self.is_show_des:SetValue(true)
		self.des_text:SetValue(self.des)
		if self.des_2 ~= nil then
			self.des_text_2:SetValue(self.des_2)
		end
	else
		self.is_show_des:SetValue(false)
	end
	self.show_des_2:SetValue(self.des_2 ~= nil)
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	if self.callback then
		self:Flush()
	end
end

function TipsRenameView:CloseCallBack()
	self.item_id = nil
	self.callback = nil
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.des = nil
	self.des_2 = nil
end

function TipsRenameView:RenameOnChange()
	local text = self.chat_input.input_field.text
	self.name = text
end

function TipsRenameView:SureBtnOnClick()
	if ChatFilter.Instance:IsIllegal(self.name, true) or ChatFilter.Instance:IsEmoji(self.name) then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.IllegalContent)
		return
	end
	if self.is_need_pro then
		if ItemData.Instance:GetItemNumInBagById(self.item_id) <= 0 then
			local price_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
			if price_cfg.bind_gold == 0 then
				TipsCtrl.Instance:ShowShopView(self.item_id, 2)
				return
			end
			local callback = function(item_id, item_num, is_bind, is_use)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			end
			TipsCtrl.Instance:ShowCommonBuyView(callback, self.item_id, nil)
			return
		end
	end
	if self.callback ~= nil then
		self.callback(self.name)
		self.callback = nil
	end
	self:Close()
end

function TipsRenameView:CancelBtnOnClick()
	self:Close()
end

function TipsRenameView:SetCallback(callback, is_need_pro)
	self.callback = callback
	self.is_need_pro = is_need_pro or false
end

function TipsRenameView:SetItemId(item_id)
	self.item_id = item_id
end

function TipsRenameView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if item_id == self.item_id then
		self:Flush()
	end
end

function TipsRenameView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "all" then
			if self.show_need_pro ~= nil then
				if v.item_id then self.item_id = v.item_id end
				self.show_need_pro:SetValue(self.is_need_pro or nil ~= self.item_id)
				local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
				if v.item_id and v.item_id == 27582 then
					self.title:SetValue(Language.Common.ZuiZongLing)
					self.callback = function(name)
						--当前场景无法传送
						local scene_type = Scene.Instance:GetSceneType()
						if scene_type ~= SceneType.Common then
							SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
							return
						end
						PlayerCtrl.Instance:SendSeekRoleWhere(name)
					end
				else
					self.title:SetValue(Language.Common.ChongMingMing)
				end
				if item_cfg then
					local bag_num = ItemData.Instance:GetItemNumInBagById(self.item_id)
					local str = item_cfg.name..":<color=#0000f1> "..bag_num.."</color> / 1"
					if bag_num < 1 then
						str = item_cfg.name..":<color=#fe3030> "..bag_num.."</color> / 1"
					end
					self.pro_name:SetValue(str)
				end
			end
		end
	end
end

function TipsRenameView:SetDes(des, des_2)
	self.des = des
	self.des_2 = des_2
end

function TipsRenameView:OnInputChange()
	local role_name = self.chat_input.input_field.text
	if role_name == "" then
		return
	end
	if ChatFilter.Instance:IsEmoji(role_name) then
		self.chat_input.input_field.text = ""
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.IllegalContent)
	end
end