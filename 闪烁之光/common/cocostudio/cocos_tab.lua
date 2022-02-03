-- --------------------------------------------------------------------
-- cocostudio负责布局，这里负责控制逻辑
--
-- @author: lsj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-09-30
-- --------------------------------------------------------------------

CocosTab = CocosTab or class("CocosTab")

--tab_list:按钮列表
--tab_type_list:按钮样式，{普通样式，选择样式}
--select_index:选择的索引
function CocosTab:ctor(tab_list, tab_type_list, default_index)
    self.tab_list = tab_list  --编辑器中按钮ui
	self.tab_type_list = tab_type_list or {}
	self.default_index = default_index or 0
	self:config()
	self:addEventListener()
end

function CocosTab:config()
    self.select_index = 0
	self.tab_btn_list = {}
	self.select_cb = nil			--改变索引的回调
end

function CocosTab:addEventListener()
	for index, v in ipairs(self.tab_list) do
	    table.insert(self.tab_btn_list, v)
		v:addTouchEventListener(handler(self, self.clickTabHandler))
		v:setTag(index)
	end
	
end

function CocosTab:clickTabHandler(sender, event_type)
    if event_type ~= ccui.TouchEventType.ended then return end
	local index = sender:getTag()
	if index == self.selec_index then return end
	self:selectIndex(index)
end

function CocosTab:selectIndex(new_index)
	local old_index = self.select_index
	self.select_index = new_index
    for index, v in ipairs(self.tab_btn_list) do
        if index == new_index then
			self:loadBtnTexture(v, true)
			if self.stypeSelectedCb then self.stypeSelectedCb(v) end
        else
			self:loadBtnTexture(v, false)
			if self.stypeUnSelectedCb then self.stypeUnSelectedCb(v) end
        end
    end
	if self.select_cb then
	    self.select_cb(self.select_index, old_index)
	end
end

function CocosTab:setSelectCallback(cb)
    self.select_cb = cb
	if self.default_index ~= 0 then
		self:selectIndex(self.default_index)
	end
end

function CocosTab:loadBtnTexture(button, is_select)
    if button == nil then return end
	if #self.tab_type_list < 2 then return end
	if is_select then
		button:loadTextureNormal(self.tab_type_list[2], LOADTEXT_TYPE_PLIST)
	else
		button:loadTextureNormal(self.tab_type_list[1], LOADTEXT_TYPE_PLIST)
	end
end

--选中的tab按钮的样式
function CocosTab:setTabStypeCb(cb1, cb2)
	self.stypeSelectedCb = cb1
	self.stypeUnSelectedCb = cb2
	if self.select_index ~= 0 then
		for index,v in ipairs(self.tab_btn_list) do
			if index == self.select_index then
				if self.stypeSelectedCb then
					self.stypeSelectedCb(v)
				end
			else
				if self.stypeUnSelectedCb then
					self.stypeUnSelectedCb(v)
				end
			end
		end
	end
end


function CocosTab:deleteMe()
    self.tab_list = nil
	self.tab_btn_list = nil
	self.tab_type_list = nil
	self.select_cb = nil
end
--endregion
