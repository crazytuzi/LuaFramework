-- 特殊的特殊npc对话框
SpecialSpecialDialogView = SpecialSpecialDialogView or BaseClass(SpecialNpcDialogView)

function SpecialSpecialDialogView:__init()
end

function SpecialSpecialDialogView:__delete()
end

function SpecialSpecialDialogView:OnFlush(param_list, index)
	SpecialNpcDialogView.OnFlush(self, param_list, index)
	
	if self.dialog_type == NPC_DIALOG_TYPE.ZSSD_NPCDLG then
		local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		local select_index = 0
		local select_btn = nil
		for k, v in pairs(self.radio_list) do
			local radio_data = v:GetData()
			if radio_data[4] then
				local param1, param2 = string.match(radio_data[4], "(%d).-(%d)")
				if param1 and param2 then
					v:SetSelect(role_circle >= tonumber(param1) and role_circle <= tonumber(param2))
				else
					param1 = tonumber(string.match(radio_data[4], "(%d)"))
					if param1 then
						if param1 > 1 then
							v:SetSelect(role_circle >= param1)
						else
							v:SetSelect(role_circle < param1)
						end
					end
				end
			end
		end
	end
end

function SpecialSpecialDialogView:OnClickRadio(radio)
	if self.dialog_type == NPC_DIALOG_TYPE.ZSSD_NPCDLG then
		return
	end

	for k, v in pairs(self.radio_list) do
		v:SetSelect(v == radio)
	end
end
