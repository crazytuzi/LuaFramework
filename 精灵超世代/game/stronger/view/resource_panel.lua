-- --------------------------------------------------------------------
-- 变强 获取资源面板
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
ResourcePanel = class("ResourcePanel", function()
    return ccui.Widget:create()
end)

local offset_y = 5

function ResourcePanel:ctor()
	self.ctrl = StrongerController:getInstance()
	self.model = self.ctrl:getModel()
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.item_list = {}

	self:configUI()
	self:register_event()
end

function ResourcePanel:configUI(  )
	self.root_wnd = ccui.Layout:create()
	self.root_wnd:setContentSize(cc.size(620,770))
	self.root_wnd:setAnchorPoint(0,0)
	self:addChild(self.root_wnd)

	-- local res = PathTool.getResFrame("common", "common_1034")
	-- self.bg = createScale9Sprite(res, self.root_wnd:getContentSize().width/2,self.root_wnd:getContentSize().height/2, LOADTEXT_TYPE_PLIST, self.root_wnd)
	-- self.bg:setContentSize(cc.size(617,772))
	-- self.bg:setAnchorPoint(0.5,0.5)

	-- self.scroll = createScrollView(self.bg:getContentSize().width,self.bg:getContentSize().height-15,1,10,self.bg,ccui.ScrollViewDir.vertical)
	self.scroll = createScrollView(617,772-15,1,10,self.root_wnd,ccui.ScrollViewDir.vertical)

	self:createItemList()
end

function ResourcePanel:createItemList(  )
	local list = Config.StrongerData.data_resource_one --PartnerController:getModel():getAllPartnerList()
	if list == nil then return end
	-- 为了跟我要变强那边一直,这样处理
	for i,v in ipairs(list) do
		if v.final_sub_list == nil then
			v.final_sub_list = {}
			for _, id in ipairs(v.sub_list) do
				table.insert(v.final_sub_list, id)
			end
		end
	end
	table.sort(list,SortTools.KeyLowerSorter("sort"))
	self.max_height = math.max((133+offset_y)*#list,self.scroll:getContentSize().height)
	self.scroll:setInnerContainerSize(cc.size(self.scroll:getContentSize().width,self.max_height))

	for k,v in pairs(list) do
		delayRun(self.scroll,0.05*k,function (  )
			local item = StrongerItem.new(2)
			item:setData(v)
			self.scroll:addChild(item)
			item:hideBg()
			item:setPosition(5,self.max_height-3-(133+offset_y)*(k-1))
			self.item_list[k] = item

			item:setBtnCallBack(function ( cell )
				if self.cur_select ~= nil and (self.cur_index and self.cur_index~=k) then 
					self.cur_select:setSelect(false)
					self.cur_select:showMessagePanel(false)
				end
				self.cur_select = cell
				self.cur_index = k
				local status = self.cur_select:getIsShow()
				if status then 
					--位置缩回去
					self.scroll:setInnerContainerSize(cc.size(self.scroll:getContentSize().width,self.max_height))
					--local height = self.max_height
					for k,v in pairs(self.item_list) do
						v:setPosition(5,self.max_height-3-(133+offset_y)*(k-1))
					end
					self.cur_select:setSelect(false)
					self.cur_select:showMessagePanel(false)
				else
					self.cur_select:setSelect(true)
					self.cur_select:showMessagePanel(true)
					self.cur_select:hideBgII()
					self.height = self.cur_select:getMsgPanleSize().height
					self:adjustPos()
				end

				--调整一下scrollview位置
				local percent = 0
				local scroll_height = self.max_height
				if self.height then 
					scroll_height = self.max_height+self.height
				end
				if self.cur_select then
					-- percent = self.cur_select:getPositionY()/scroll_height * 100
					-- --print("======percent====",percent,100-percent,self.cur_select:getPositionY(),scroll_height)
					-- self.scroll:jumpToPercentVertical(100-percent)

					-- -- local temp = ((133+(133/2)*(self.cur_index-1))*(self.cur_index-1))/scroll_height * 100
					-- -- self.scroll:jumpToPercentVertical(temp)


					-- local top = scroll_height-self.scroll:getContentSize().height
					-- local temp = (self.cur_select:getPositionY()-top)/self.scroll:getContentSize().height * 100 

					-- local total = self.cur_select:getPositionY()/scroll_height * 100
					-- local top = (self.cur_select:getPositionY() - (scroll_height-self.scroll:getContentSize().height))*100
					-- local temp = total - top

					-- print("=====temp===",temp)
					-- self.scroll:jumpToPercentVertical(temp)

				-- 	local temp = (scroll_height-3-self.cur_select:getPositionY())/scroll_height*100
				-- 	print("=====temp===",temp)
				-- 	self.scroll:jumpToPercentVertical(temp)

					-- local offset = (self.cur_index-1)*133
					-- local temp = offset/self.max_height * 100
					-- self.scroll:jumpToPercentVertical(math.ceil(temp))


					 local offset_height = (self.cur_index - 1) * 136
				     percent = (self.cur_select:getPositionY())/scroll_height * 100
				     local temp_percent = offset_height / self.max_height * 100
				     if self.height then
				      offset_height = (self.cur_index - 1) * 190
				      temp_percent = offset_height / scroll_height * 100
				     end
				     --print("======percent====",percent,100-percent,self.cur_select:getPositionY(),scroll_height)
				     --self.scroll:scrollToTop(0.1,true)
				     self.scroll:jumpToPercentVertical(math.ceil(temp_percent))
				end
			end)
		end)
	end


end

function ResourcePanel:adjustPos(  )
	if self.cur_select ~= nil then 
		self.scroll:setInnerContainerSize(cc.size(self.scroll:getContentSize().width,self.max_height+self.height))
		local height = self.max_height+self.height
		for k,v in pairs(self.item_list) do
			if k<=self.cur_index then 
				v:setPosition(5,height-3-(133+offset_y)*(k-1))
			else
				v:setPosition(5,height-self.height-3-(133+offset_y)*(k-1))
			end
		end
	end
end

function ResourcePanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)    
end

function ResourcePanel:register_event(  )
end

function ResourcePanel:DeleteMe()
	doStopAllActions(self.scroll)

	if self.item_list and self.item_list ~= nil then 
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
end