SuperAfterVipData = SuperAfterVipData or BaseClass()

function SuperAfterVipData:__init()
	if SuperAfterVipData.Instance then
		ErrorLog("[SuperAfterVipData]:Attempt to create singleton twice!")
	end
	SuperAfterVipData.Instance = self
end

function SuperAfterVipData:__delete()
	SuperAfterVipData.Instance = nil
end

