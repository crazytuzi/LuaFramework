local CheckReference = {}

function CheckReference:OnReleaseView(view)
	for k,v in pairs(view) do
		if k ~= "open_audio_id" and k ~= "close_audio_id" then
			if type(v) == "userdata" then
				local name = nil
				if view.view_name ~= nil then
					name = view.view_name
				else
					name = view.ui_config[2]
				end
				
				print_error(string.format("Do you remember release data from c#, view_name = %s, key = %s", name, k))
			elseif type(v) == "table" then
				for k2,v2 in pairs(v) do
					if type(v2) == "userdata" then
						local name = nil
						if view.view_name ~= nil then
							name = view.view_name
						else
							name = view.ui_config[2]
						end

						print_error(string.format("Do you remember release data from c#, view_name = %s, key = %s#%s", name, k, k2))
					end
				end
			end
		end
	end
end

return CheckReference