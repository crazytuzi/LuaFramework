--CCBTableViewCellUF.lua


local  CCBTableViewCellUF = class ("CCBTableViewCellUF", function ( ccbfile )
	return CCTableViewCellEx:create(ccbfile)
end)


function CCBTableViewCellUF:ctor()
	self:registerNodeEvent()
	self:_onCellLoad()
end

function CCBTableViewCellUF:_onCellLoad(  )
	self:onCellLoad()
end

function CCBTableViewCellUF:registerNodeEvent()
    local handler = function(event, param1, param2)
        if event == "enter" then
            self:onCellEnter()
        elseif event == "exit" then
            self:onCellExit()
        elseif event == "cleanup" then
            self:onCellUnload()
        end
    end

    self:registerScriptHandler(handler)
end

function CCBTableViewCellUF:unregisterNodeEvent()
    self:unregisterScriptHandler()
end

function CCBTableViewCellUF:onCellLoad(  )
end

function CCBTableViewCellUF:onCellEnter(  )
end

function CCBTableViewCellUF:onCellExit(  )
end

function CCBTableViewCellUF:onCellUnload(  )
end

return CCBTableViewCellUF