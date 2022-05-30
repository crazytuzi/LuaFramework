-- --------------------------------------------------------------------
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      精灵窝解锁界面
-- <br/> 2020年2月22日
-- --------------------------------------------------------------------
ElfinHatchUnlockPanel = ElfinHatchUnlockPanel or BaseClass(BaseView)

local controller = ElfinController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format

function ElfinHatchUnlockPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "elfin/elfin_hatch_unlock_panel"

    self.res_list = {
    }

end

function ElfinHatchUnlockPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N(""))
    self.Text_2 = self.main_container:getChildByName("Text_2")
    self.Text_2:setString(TI18N("消耗："))
    

    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn_lab = self.right_btn:getChildByName("label")
    self.right_btn_lab:setString(TI18N("开  启"))

    self.tips_lab = self.main_container:getChildByName("tips_lab")
    self.tips_lab:setString(TI18N("开启条件"))
    self.icon_img = self.main_container:getChildByName("icon_img")
    self.con_num = self.main_container:getChildByName("con_num")


    self.close_btn = self.main_container:getChildByName("close_btn")

    
	self.elfin_list = self.main_container:getChildByName("elfin_list")
	local scroll_view_size = self.elfin_list:getContentSize()
    local list_setting = {
        start_x = 0,
        space_x = 0,
        start_y = 0,
        space_y = 10,
        item_width = 600,
        item_height = 50,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.elfin_list_view = CommonScrollViewSingleLayout.new(self.elfin_list, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    -- self.elfin_list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell

end


function ElfinHatchUnlockPanel:createNewCell(  )
	local cell = ElfinHatchUnlockItem.new(self.data)
    return cell
end

function ElfinHatchUnlockPanel:numberOfCells(  )
	if not self.elfin_data_list then return 0 end
	return #self.elfin_data_list
end

function ElfinHatchUnlockPanel:updateCellByIndex( cell, index )
	cell.index = index
    local item_vo = self.elfin_data_list[index]
    if item_vo then
    	cell:setData(item_vo)
    end
end

function ElfinHatchUnlockPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self._onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.right_btn, handler(self, self._onClickBtnRight) ,true, 2)
end

--关闭
function ElfinHatchUnlockPanel:_onClickBtnClose()
    controller:openElfinHatchUnlockPanel(false)
end

--确认消耗
function ElfinHatchUnlockPanel:_onClickBtnRight()
    if not self.data then
        return
    end
    
    if self.data.is_open == 0 then
        message(TI18N("解锁条件未达成"))
        return
    end

    local hatch_cfg = Config.SpriteData.data_hatch_data[self.data.id]
    if hatch_cfg then
        for i,v in ipairs(hatch_cfg.expend) do
            local item_bid = v[1]
            local item_num = v[2]
            local count = BackpackController:getInstance():getModel():getItemNumByBid(item_bid)
            if count< item_num then
                local item_cfg = Config.ItemData.data_get_data(item_bid)
                if item_cfg then
                    if item_bid == Config.ItemData.data_assets_label2id.gold then
                        if FILTER_CHARGE then
                            message(TI18N("钻石不足"))
                        else
                            local function fun()
                                VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
                            end
                            local str = string.format(TI18N('%s不足，是否前往充值？'), item_cfg.name)
                            CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
                        end
                    else
                        BackpackController:getInstance():openTipsSource(true, item_cfg)
                    end
                end
                return
            end
        end
    end

    controller:sender26535(self.data.id)
end

--@
function ElfinHatchUnlockPanel:openRootWnd(data)
    self.data = data
   self:setData()
    
end


function ElfinHatchUnlockPanel:setData()
    if not self.data then return end
    
    local hatch_cfg = Config.SpriteData.data_hatch_data[self.data.id]
    if not hatch_cfg then return end
    self.title:setString(hatch_cfg.name)
    self.elfin_data_list = {{cond = hatch_cfg.hatch_cond,desc = hatch_cfg.desc2}}
   
    self.elfin_list_view:reloadData()
    for i,v in ipairs(hatch_cfg.expend) do
		local item_bid = v[1]
		local item_num = v[2]
		local item_cfg = Config.ItemData.data_get_data(item_bid)
        if item_cfg then
            self.con_num:setString(tostring(item_num))
            loadSpriteTexture(self.icon_img, PathTool.getItemRes(item_cfg.icon), LOADTEXT_TYPE)
		end
    end
end


function ElfinHatchUnlockPanel:close_callback()
    if self.elfin_list_view then
		self.elfin_list_view:DeleteMe()
		self.elfin_list_view = nil
	end

    controller:openElfinHatchUnlockPanel(false)
end

--------------------------@ item
ElfinHatchUnlockItem = class("ElfinHatchUnlockItem", function()
    return ccui.Widget:create()
end)

function ElfinHatchUnlockItem:ctor(data)
    self.cur_info = data
	self:configUI()
end

function ElfinHatchUnlockItem:configUI(  )
	self.size = cc.size(600, 50)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

    self.lock_desc = createLabel(22,Config.ColorData.data_new_color4[6],nil,0,self.size.height/2,"",self,nil, cc.p(0,0.5))
    self.lock_desc:setDimensions(400, 50)
    self.lock_desc:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    self.status_tips = createLabel(18,Config.ColorData.data_new_color4[6],nil,600,self.size.height/2,"",self,nil, cc.p(1,0.5))
end


function ElfinHatchUnlockItem:setData( data )
    if not data or not self.cur_info then
        return
    end
    self.status_tips:setString(TI18N("未达成"))
    local curnum = data.cond[2]
    local neednum = data.cond[2]
    if data.cond[1] == "has_any_sprite" then
        curnum = 1
        neednum = 1
    end
    
    local isLock = false
    if self.cur_info.is_open == 0 and data.cond then
        curnum = 0
        if data.cond[1] == "lev" then
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo then
                curnum = role_vo.lev
                if role_vo.lev < data.cond[2] then
                    isLock = true
                end
                
            end
        elseif data.cond[1] == "sprite_tree_break" then -- 古树X阶解锁
            local tree_data = model:getElfinTreeData()
            if tree_data then
                curnum = tree_data.break_lev
                if tree_data.break_lev < data.cond[2] then
                    isLock = true
                end
            end
        elseif data.cond[1] == "sprite_tree_lv" then -- 古树X级解锁
            local tree_data = model:getElfinTreeData()
            if tree_data then
                curnum = tree_data.lev
                if tree_data.lev < data.cond[2] then
                    isLock = true
                end
            end
        elseif data.cond[1] == "has_any_sprite" then --[所有3星橙色精灵的bid]}
            local is_num = false
            for k,v in pairs(data.cond[2]) do
                local num =  BackpackController:getInstance():getModel():getBackPackItemNumByBid(v)
                if num and num>0 then
                    is_num = true
                    curnum = num
                    break
                end
            end
            neednum = 1
            if is_num == false then
                isLock = true
            end
            
        elseif data.cond[1] == "sprite_tree_power" then --古树战力达到X解锁
            local tree_data = model:getElfinTreeData()
            if tree_data then
                curnum = tree_data.power
                if tree_data.power < data.cond[2] then
                    isLock = true
                end
                
            end
        elseif data.cond[1] == "sprite_power" then --精灵战力达到X解锁
            local tree_data = model:getElfinTreeData()
            if tree_data then
                for k,v in pairs(tree_data.sprites) do
                    local elfin_cfg = Config.SpriteData.data_elfin_data(v.item_bid)
                    if elfin_cfg then
                        curnum = curnum + elfin_cfg.power
                    end
                end

                if curnum < data.cond[2] then
                    isLock = true
                end
                
            end
        end
    end
    if curnum > neednum then
        curnum = neednum
    end 
    self.lock_desc:setString(string_format("%s(%d/%d)",data.desc,curnum,neednum))
    if isLock == true then
        self.lock_desc:setTextColor(Config.ColorData.data_new_color4[11])
        self.status_tips:setTextColor(Config.ColorData.data_new_color4[11])
        self.status_tips:setString(TI18N("未达成"))
    else
        self.lock_desc:setTextColor(Config.ColorData.data_new_color4[12])
        self.status_tips:setTextColor(Config.ColorData.data_new_color4[12])
        self.status_tips:setString(TI18N("达成"))
    end

end


function ElfinHatchUnlockItem:DeleteMe(  )
	
end