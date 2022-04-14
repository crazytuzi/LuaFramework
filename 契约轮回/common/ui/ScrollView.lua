-- 
-- @Author: chk
-- @Date:   2018-08-19 12:32:38
-- 
ScrollView = ScrollView or class("ScrollView")
local ScrollView = ScrollView


function ScrollView:ctor(param)
	ScrollView.Instance = self

	self.beginIdx = param["begIdx"]  or 1                    --下标从哪个数字开始(哪个格子开始算位置)
	self.beginPos = param["begPos"]                      --第一个格子在scroll view中的开始位置
	self.cellClass = param["cellClass"]                  --初始cell信息的类
	self.scrollRect = param["scrollRect"]                --scroll Rect 脚本
	self.contenRectTra = param["contenRectTra"]          --scroll view 的content的 RectTransform 脚本
	self.cellParent = param["cellParent"]                --cell的父节点
	self.instanceObj = param["instanceObj"]              --
	self.cellSize = param["cellSize"]                    --格子的尺寸Vector2类型
	self.spanX = param["spanX"]                          --x轴间隙
	self.spanY = param["spanY"]                          --y轴间隙
	self.createCellCB = param["createCellCB"]
	self.updateCellCB = param["updateCellCB"]            --创建(更新)格子的回调
	self.cellCount = param["cellCount"]                  --要创建的格子数
	self.clone_gameObject = param.gameObject
	self.isHorizontal = self.scrollRect.horizontal


	self.totalRow = param["totalRow"] or 0              -- 总行数
	self.needLoadRow = 0           -- 要加载的行数
	self.totalColumn = param["totalColumn"] or 0           -- 列数
	self.needLoadColumn = 0        -- 要加载的列数
	self.loadedCellObjs = {}       -- 已经加载的格子对象
	self.outLoadCells = {}
	self.additionIdx = {}

	self.wait_load_data = {}  --分帧实例化需要的信息列表
	self.separate_frame_schedule_id = nil  --分帧实例化定时器id

	self:SetRowColumnContent()
	self:CreateCells()
	self:AddEvent()
end

function ScrollView:OnDestroy()
	if self.loadedCellObjs ~= nil then
		for k,v in pairs(self.loadedCellObjs) do
			v:destroy()
		end

		self.loadedCellObjs = {}
	end

	if self.separate_frame_schedule_id then
		GlobalSchedule:Stop(self.separate_frame_schedule_id)
		self.separate_frame_schedule_id = nil
	end
end


function ScrollView:AddEvent()
	self.scrollRect.onValueChanged:AddListener(handler(self,self.scrollChange))
end

 function ScrollView:scrollChange  ()

		self.outLoadCells = {}
		self.additionIdx = {}
		if self.isHorizontal then
			local fromColumn = math.floor((-self.contenRectTra.anchoredPosition.x + self.spanX) / (self.cellSize.width + self.spanX))
			if fromColumn < 1 then
				fromColumn = 1
			end


			local fromEndIdx = {}
			local fromIdx = (fromColumn - 1) * self.totalRow + 1
			local endIdx  = fromIdx + self.needLoadColumn * self.totalRow - 1
			if endIdx >= self.cellCount then
				endIdx = self.cellCount
			end

			if self.beginIdx > 1 and fromIdx == 1 then
				fromIdx = self.beginIdx
			end
			--把要加载的下标存入列表
			for i=fromIdx,endIdx do
				table.insert(fromEndIdx,i)
			end

			local loadedCellIdx = {}
			local outLoadCells = {}
			for i,v in ipairs(self.loadedCellObjs) do
				if v.__item_index < fromIdx or v.__item_index > endIdx then  --找出超出范围的格子

					table.insert(outLoadCells,v)
					Chkprint('--越界-- v=',v.__item_index,fromIdx,endIdx)
			
				else                                                       --把在范围内的格子下标存起来
					loadedCellIdx[v.__item_index] = v.__item_index
				end
			end



			for i=#fromEndIdx ,1 , -1 do
				if fromEndIdx[i] and loadedCellIdx[fromEndIdx[i]] then    --判断要加载的是否已经加载了，否则踢除,剩下的就是要改变位置的
					table.remove(fromEndIdx,i)
				end
			end

			local index = 1
			for i,v in pairs(fromEndIdx) do        --改变位置
				-- print('--chk ScrollView.lua,line 114-- v=',v)
				if outLoadCells[index] then
					local row,column = self:GetRowColumnByIdx(v)


					local x = self.beginPos.x + (column - 1) * (self.cellSize.width + self.spanX)
					local y = self.beginPos.y - (row - 1) * (self.cellSize.height + self.spanY)
					outLoadCells[index]:SetPosition(x,y)
					outLoadCells[index]:SetTransformName(tonumber(v))
					outLoadCells[index].__item_index = v
					self.updateCellCB(outLoadCells[index])

                    --Chkprint('--chk ScrollView.lua,line 114-- v=',v)

				end

				index = index + 1
			end


			---------------

			-- local fromIdx = (fromColumn - 1) * self.totalRow + 1
			-- local endIdx = fromIdx + self.needLoadColumn * self.totalRow - 1
			-- if endIdx >= self.cellCount then
			-- 	endIdx = self.cellCount
			-- end

			-- local idx = fromIdx
			-- for i,v in ipairs(self.loadedCellObjs) do
			-- 	local numName = v.__item_index
			-- 	if numName < fromIdx or numName > endIdx then
			-- 		local row,column = self:GetRowColumnByIdx(idx)
			-- 		local x = self.beginPos.x + (column - 1) * (self.cellSize.width + self.spanX)
			-- 		local y = self.beginPos.y - (row - 1) * (self.cellSize.height + self.spanY)
			-- 		v:SetPosition(x,y)
			-- 		v.__item_index = idx
			-- 		-- v.transform.name = tostring(idx)

			-- 		idx = idx + 1
			-- 	end
			-- end

		else
			local fromRow = math.floor((self.contenRectTra.anchoredPosition.y + self.spanY) / (self.cellSize.height + self.spanY))
			if fromRow < 1 then
				fromRow = 1
			end



			local fromEndIdx = {}
			local fromIdx = (fromRow - 1) * self.totalColumn + 1
			local endIdx  = fromIdx + self.needLoadRow * self.totalColumn - 1
			if endIdx >= self.cellCount then
				endIdx = self.cellCount
			end

			if self.beginIdx > 1 and fromIdx == 1 then
				fromIdx = self.beginIdx
			end
			--把要加载的下标存入列表
			for i=fromIdx,endIdx do
				table.insert(fromEndIdx,i)
			end

			local loadedCellIdx = {}
			local outLoadCells = {}
			for i,v in ipairs(self.loadedCellObjs) do
				if v.__item_index < fromIdx or v.__item_index > endIdx then  --找出超出范围的格子

					table.insert(outLoadCells,v)
					Chkprint('--越界-- v=',v.__item_index,fromIdx,endIdx)
			
				else                                                       --把在范围内的格子下标存起来
					loadedCellIdx[v.__item_index] = v.__item_index
				end
			end



			for i=#fromEndIdx ,1 , -1 do
				if fromEndIdx[i] and loadedCellIdx[fromEndIdx[i]] then    --判断要加载的是否已经加载了，否则踢除,剩下的就是要改变位置的
					table.remove(fromEndIdx,i)
				end
			end

			local index = 1
			for i,v in pairs(fromEndIdx) do        --改变位置
				-- print('--chk ScrollView.lua,line 114-- v=',v)
				if outLoadCells[index] then
					local row,column = self:GetRowColumnByIdx(v)


					local x = self.beginPos.x + (column - 1) * (self.cellSize.width + self.spanX)
					local y = self.beginPos.y - (row - 1) * (self.cellSize.height + self.spanY)
					outLoadCells[index]:SetPosition(x,y)
					outLoadCells[index]:SetTransformName(tonumber(v))
					outLoadCells[index].__item_index = v
					self.updateCellCB(outLoadCells[index])

                    --Chkprint('--chk ScrollView.lua,line 114-- v=',v)

				end

				index = index + 1
			end
		end


	end

function ScrollView:DelItemByIndex(index)
	for i, v in pairs(self.loadedCellObjs) do
		if v.__item_index == index then
			v:destroy()
			table.removebyvalue(self.loadedCellObjs,v)
		end
	end
end

function ScrollView:GetScrollItemByIdx(idx)
	for i, v in pairs(self.loadedCellObjs) do
		if v.__item_index == idx then
			return v
		end
	end
end

function ScrollView:GetRowColumnByIdx(idx)
	local row =0
	local column = 0
	if self.isHorizontal then
		row = idx % self.totalRow
		if row == 0 then
			row = self.totalRow
		end

		column = math.ceil(idx / self.totalRow)
		if column > self.totalColumn then
			column = self.totalColumn
		end
	else
		row = math.ceil(idx / self.totalColumn)
		if row > self.totalRow then
			row = self.totalRow
		end

		column = idx % self.totalColumn
		if column == 0 then
			column = self.totalColumn
		end
	end


	return row,column
end


function ScrollView:ResetContentSize(cellCount)
	self.cellCount = cellCount
	self:SetRowColumnContent()
end

function ScrollView:Update()
	self:scrollChange()
end

function ScrollView:ForceUpdate()
    for i, v in pairs(self.loadedCellObjs) do
        self.updateCellCB(v);
    end
end

function ScrollView:CreateCells()
	local count = 1

	if self.isHorizontal then   -- 横向移动，行数固定,遂列显示
		for c=1,self.needLoadColumn do
			local rc = 1
			for r=1,self.totalRow do
				if count <= self.cellCount then
					local x = self.beginPos.x + (c - 1) * (self.cellSize.width + self.spanX)
					local y = self.beginPos.y - (rc - 1) * (self.cellSize.height + self.spanY)

					local data = {}
					data.x = x
					data.y = y
					data.count = count
					table.insert( self.wait_load_data, data )

					--[[ local cell =  nil
					if self.instanceObj ~= nil then
						cell = self.cellClass(newObject(self.instanceObj))
						cell.transform:SetParent(self.cellParent)
						SetLocalScale(cell.transform, 1, 1, 1)
						SetLocalPositionZ(cell.transform,0)
					elseif self.clone_gameObject ~= nil then
						cell =  self.cellClass(self.clone_gameObject,self.cellParent)
					else
						cell = self.cellClass(self.cellParent)
					end
					
					cell.__item_index = count
					cell:SetPosition(x,y)
					cell:SetTransformName(tostring(count))
					self.createCellCB(cell)
					table.insert(self.loadedCellObjs,cell) ]]



					count = count + 1
					rc = rc + 1
				end
			end
		end
	else                        --纵向移动，列数固定

		for r=1,self.needLoadRow do
			local cc = 1
			for c=1,self.totalColumn do
				if cc > self.totalColumn then
					break
				end

				if count <= self.cellCount then
					if self.beginIdx > 1 and r == 1 and c==1 then
						cc = self.beginIdx
						count = self.beginIdx
					end


					local x = self.beginPos.x + (cc - 1) * (self.cellSize.width + self.spanX)
					local y = self.beginPos.y - (r - 1) * (self.cellSize.height + self.spanY)

					local data = {}
					data.x = x
					data.y = y
					data.count = count
					table.insert( self.wait_load_data, data )

					--[[ local cell =  nil
					if self.instanceObj ~= nil then
						cell = self.cellClass(newObject(self.instanceObj))
						cell.transform:SetParent(self.cellParent)
						SetLocalScale(cell.transform, 1, 1, 1)
						SetLocalPositionZ(cell.transform,0)
					elseif self.clone_gameObject ~= nil then
						cell =  self.cellClass(self.clone_gameObject,self.cellParent)
					else
						cell = self.cellClass(self.cellParent)
					end

					cell.__item_index = count
					cell:SetPosition(x,y)
					cell:SetTransformName(tostring(count))
					self.createCellCB(cell)
					table.insert(self.loadedCellObjs,cell) ]]
					
					count = count + 1
					cc = cc + 1
				end
			end
		end
	end


	--开始分帧实例化
	self:SeparateFrameInstantia()
end

--分帧实例化
function ScrollView:SeparateFrameInstantia()
	local num = #self.wait_load_data
    if num <= 0 then
		return
	end

	local function op_call_back(cur_frame_count,cur_all_count)
		local data = self.wait_load_data[cur_all_count]
		 
		local cell =  nil

		if self.instanceObj ~= nil then
			cell = self.cellClass(newObject(self.instanceObj))
			cell.transform:SetParent(self.cellParent)
			SetLocalScale(cell.transform, 1, 1, 1)
			SetLocalPositionZ(cell.transform,0)
		elseif self.clone_gameObject ~= nil then
			cell =  self.cellClass(self.clone_gameObject,self.cellParent)
		else
			cell = self.cellClass(self.cellParent)
		end
		cell.__item_index = data.count
		cell:SetPosition(data.x,data.y)
		cell:SetTransformName(tostring(data.count))
		self.createCellCB(cell)
		table.insert(self.loadedCellObjs,cell)

		--logError("分帧实例化，count:"..cur_all_count)
	end
	local function all_frame_op_complete()
		self:SeparateFrameInstantiaComplete()
	end

	--一帧实例化一个 保证不卡

	self.separate_frame_schedule_id =  SeparateFrameUtil.SeparateFrameOperate(op_call_back,nil,1,num,nil,all_frame_op_complete)
end

--分帧实例化完毕
function ScrollView:SeparateFrameInstantiaComplete(  )
	self.separate_frame_schedule_id = nil
	self.wait_load_data = {}
end

function ScrollView:SetRowColumnContent()
	local rectTra = self.scrollRect:GetComponent("RectTransform")
	if self.isHorizontal then
        if self.totalRow and self.totalRow == 0 then
            self.totalRow = math.ceil((rectTra.rect.height - self.beginPos.y) / (self.cellSize.height + self.spanY))
        end

		self.totalColumn = math.ceil(self.cellCount / self.totalRow)
		local vec = Vector2(self.totalColumn * self.cellSize.width + (self.totalColumn - 1) * self.spanX - self.beginPos.x,
				self.contenRectTra.sizeDelta.y - self.beginPos.y)
		
		self.contenRectTra.sizeDelta = vec
		self.needLoadColumn = math.ceil(rectTra.rect.width / ( self.cellSize.width + self.spanX)) + 2  -- 可视范围内加多2列
		if self.needLoadColumn > self.totalColumn then   -- 加载的列数大于总的列数
			self.needLoadColumn = self.totalColumn
		end
	else
        if self.totalColumn and self.totalColumn == 0 then
            self.totalColumn = math.ceil((rectTra.rect.width - self.beginPos.x) / (self.cellSize.width + self.spanX))
        end

		self.totalRow = math.ceil(self.cellCount / self.totalColumn)
		self.contenRectTra.sizeDelta = Vector2(self.contenRectTra.sizeDelta.x - self.beginPos.x,
				self.totalRow * self.cellSize.height + (self.totalRow - 1) * self.spanY - self.beginPos.y)

		self.needLoadRow = math.ceil(rectTra.rect.height / (self.cellSize.height + self.spanY)) + 2       --可视范围内加多2行

		if self.needLoadRow > self.totalRow then             -- 加载的行数大于总行数
			self.needLoadRow = self.totalRow
		end
	end
end

function ScrollView:ResetItemIndex()
	for i, v in pairs(self.loadedCellObjs) do
		v.__item_index = i
	end
end

--重新设置位置
--needUpdate是否要更新格子的信息
function ScrollView:ResetPosition(needUpdate)
	for i, v in pairs(self.loadedCellObjs) do
		local row,column = self:GetRowColumnByIdx(v.__item_index)

		local x = self.beginPos.x + (column - 1) * (self.cellSize.width + self.spanX)
		local y = self.beginPos.y - (row - 1) * (self.cellSize.height + self.spanY)
		self.loadedCellObjs[i]:SetPosition(x,y)
		self.loadedCellObjs[i]:SetTransformName(tonumber(v.__item_index))
		self.loadedCellObjs[i].__item_index = v.__item_index

		if needUpdate then
			self.updateCellCB(self.loadedCellObjs[v.__item_index])
		end
	end

end

-- 有瑕疵  有其他用到的在改
function ScrollView:SetIndexPos(posIndex)
    self.outLoadCells = {}
    self.additionIdx = {}

	if self.isHorizontal then
        local count =  posIndex - (self.needLoadColumn / 2)
        local fromColumn = count > 1 and count  or 1
        local fromEndIdx = {}
        local fromIdx = (fromColumn - 1) * self.totalRow + 1
        local endIdx  = fromIdx + self.needLoadColumn * self.totalRow - 1
        if endIdx >= self.cellCount then
            endIdx = self.cellCount
        end

        if self.beginIdx > 1 and fromIdx == 1 then
            fromIdx = self.beginIdx
        end
        --把要加载的下标存入列表
        for i=fromIdx,endIdx do
            table.insert(fromEndIdx,i)
        end

        local loadedCellIdx = {}
        local outLoadCells = {}
        for i,v in ipairs(self.loadedCellObjs) do
            if v.__item_index < fromIdx or v.__item_index > endIdx then  --找出超出范围的格子

                table.insert(outLoadCells,v)
                Chkprint('--越界-- v=',v.__item_index,fromIdx,endIdx)

            else                                                       --把在范围内的格子下标存起来
                loadedCellIdx[v.__item_index] = v.__item_index
            end
        end



        for i=#fromEndIdx ,1 , -1 do
            if fromEndIdx[i] and loadedCellIdx[fromEndIdx[i]] then    --判断要加载的是否已经加载了，否则踢除,剩下的就是要改变位置的
                table.remove(fromEndIdx,i)
            end
        end

        local index = 1
        for i,v in pairs(fromEndIdx) do        --改变位置
            -- print('--chk ScrollView.lua,line 114-- v=',v)
            if outLoadCells[index] then
                local row,column = self:GetRowColumnByIdx(v)


                local x = self.beginPos.x + (column - 1) * (self.cellSize.width + self.spanX)
                local y = self.beginPos.y - (row - 1) * (self.cellSize.height + self.spanY)
                outLoadCells[index]:SetPosition(x,y)
                outLoadCells[index]:SetTransformName(tonumber(v))
                outLoadCells[index].__item_index = v
                self.updateCellCB(outLoadCells[index])

                --Chkprint('--chk ScrollView.lua,line 114-- v=',v)

            end

            index = index + 1
        end

        SetLocalPositionX(self.contenRectTra.transform, -posIndex * (self.cellSize.width + self.spanX))
	else
	end
end