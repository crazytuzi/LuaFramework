
local PageMemoModel = {}

PageMemoModel.memoTable = {}


PageMemoModel.bigMapID = 0
function PageMemoModel.saveOffset(name,tableView)
    if name ~= nil and tableView ~= nil then
        PageMemoModel.memoTable[name] = tableView:getContentOffset()
    end
end

PageMemoModel.isAllowRecord = true

function PageMemoModel.saveOffsetByNum(name,offset)
	if PageMemoModel.isAllowRecord  == true then
	    PageMemoModel.memoTable[name] = offset
	end
end

function PageMemoModel.clear(name)
    if name ~= nil then
        PageMemoModel.memoTable[name] = nil
    end
end

function PageMemoModel.resetOffset(name,tableView)

	if tableView == nil then
		return
	end
    
    local curOffset = PageMemoModel.memoTable[name] 
    local maxOffset = tableView:maxContainerOffset()
    local minOffset = tableView:minContainerOffset()

    local curDir    = tableView:getDirection()

    if curOffset ~= nil then
        local curValue 
        local tableMin
        local tableMax

        if curDir == kCCScrollViewDirectionHorizontal then
            curValue = curOffset.x
            tableMin = minOffset.x
            tableMax = maxOffset.x
        else
            curValue = curOffset.y
            tableMin = minOffset.y
            tableMax = maxOffset.y
        end

        -- if curValue < tableMin then
        --     curOffset = minOffset
        -- elseif curValue > tableMax then
        --     curOffset = maxOffset
        -- end

        tableView:setContentOffset(curOffset)
    end
end

function PageMemoModel.Reset(  )
    PageMemoModel.bigMapID = 0
    PageMemoModel.memoTable = {}
end

return PageMemoModel