local ActStatusModel  = {}

ActStatusModel.status = nil

function ActStatusModel.sendRes(param)
    RequestHelper.getActStatus({
        callback = function(data)
            print("getActStatus")
            dump(data)
            ActStatusModel.status = data
            param.callback()
        end
        })
end

function ActStatusModel.getIsActOpen(id)
	if ActStatusModel.status[tostring(id)] == 1 then
		return true
	else
		return false
	end
end

return ActStatusModel 