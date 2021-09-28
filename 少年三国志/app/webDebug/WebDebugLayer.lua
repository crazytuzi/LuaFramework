
local WebDebugLayer = class("WebDebugLayer", UFCCSModelLayer)

function WebDebugLayer.show()
   local layer = WebDebugLayer.new("ui_layout/common_WebDebug.json", require("app.setting.Colors").modelColor)
   uf_notifyLayer:getDebugNode():addChild(layer, 10)
end

function WebDebugLayer:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)

    self._list1 = {}
    self._list2 = {}
    self._nameList = G_WebDebug:getModelList()
    self._logLIst = {}
    self._checkedIndex = 0

    G_WebDebug:setStepCallBack(function ( data )
    	local str = data and "sending "..data or "send end"
    	table.insert(self._logLIst,#self._logLIst+1,str)
    	self:updateList2()
    end)

    self:registerBtnClickEvent("Button_checkAll", function(widget)
    	table.insert(self._logLIst,#self._logLIst+1,"start check all")
    	self:updateList2()
	G_WebDebug:startDebugAll(function ( data )
		local info = G_WebDebug.analyzeCheckResult(data)
		for k , v in pairs(info) do 
			table.insert(self._logLIst,#self._logLIst+1,v)
		end
		self:updateList2()
	end)
    end)
    self:registerBtnClickEvent("Button_checkOne", function(widget)
    	table.insert(self._logLIst,#self._logLIst+1,"start check "..self._nameList[self._checkedIndex+1])
    	self:updateList2()
	G_WebDebug:startDebug(self._nameList[self._checkedIndex+1],function ( data )
		local info = G_WebDebug.analyzeCheckResult(data)
		for k , v in pairs(info) do 
			table.insert(self._logLIst,#self._logLIst+1,v)
		end
		self:updateList2()
	end)
    end)
    self:registerBtnClickEvent("Button_checkEmpty", function(widget)
    	table.insert(self._logLIst,#self._logLIst+1,"start check empty "..self._nameList[self._checkedIndex+1])
    	self:updateList2()
	G_WebDebug:startTimeOutDebug(self._nameList[self._checkedIndex+1],function ( data )
		local info = G_WebDebug.analyzeEmptyResult(data)
		for k , v in pairs(info) do 
			table.insert(self._logLIst,#self._logLIst+1,v)
		end
		self:updateList2()
	end)
    end)
    self:registerBtnClickEvent("Button_checkJuHua", function(widget)
    	table.insert(self._logLIst,#self._logLIst+1,"start check juhua")
    	self:updateList2()
	G_WebDebug:checkJuHua(function ( data )
		local info = G_WebDebug.analyzeJuHuaResult(data)
		for k , v in pairs(info) do 
			table.insert(self._logLIst,#self._logLIst+1,v)
		end
		self:updateList2()
	end)
    end)
    self:registerBtnClickEvent("Button_close", function(widget)
        	self:close()
    end)

    self:initList1()
    self:initList2()
end

function WebDebugLayer:onLayerEnter( ... )
    
end

function WebDebugLayer:initList1( )
	if self._listView1 == nil then
	    self._listView1 = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_list1"), LISTVIEW_DIR_VERTICAL)
	    self._listView1:setCreateCellHandler(function ( list, index)
	        local cell = require("app.webDebug.WebDebugNameListCell").new(list, index)
	        return cell
	    end)
	    self._listView1:setUpdateCellHandler(function ( list, index, cell)
	        if  index < #self._nameList then
	           cell:updateData(self._nameList[index+1],index,self._checkedIndex,function ( _index)
	           		self._checkedIndex = _index
	           		self._listView1:refreshAllCell()
	           end) 
	        end
	    end)
	    self._listView1:initChildWithDataLength( #self._nameList)
	end
end

function WebDebugLayer:initList2( )
	if self._listView2 == nil then
	    self._listView2 = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_list2"), LISTVIEW_DIR_VERTICAL)
	    self._listView2:setCreateCellHandler(function ( list, index)
	        return require("app.webDebug.WebDebugLogListCell").new(list, index)
	    end)
	    self._listView2:setUpdateCellHandler(function ( list, index, cell)
	        if  index < #self._logLIst then
	           cell:updateData(self._logLIst[index+1]) 
	        end
	    end)
	    self._listView2:initChildWithDataLength( #self._logLIst)
	end
end

function WebDebugLayer:updateList1( )
    self._listView1:reloadWithLength(#self._nameList)
end

function WebDebugLayer:updateList2( )
    self._listView2:reloadWithLength(#self._logLIst,#self._logLIst)
    self._listView2:scrollToShowCell(#self._logLIst,0)
end

function WebDebugLayer:onLayerExit( ... )
    
end

return WebDebugLayer