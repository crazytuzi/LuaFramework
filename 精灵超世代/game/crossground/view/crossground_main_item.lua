--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-02 16:29:39
-- @description    : 
		-- 跨服战场 item
---------------------------------
CrossgroundItem = class("CrossgroundItem", function()
    return ccui.Widget:create()
end)

local _controller = CrossgroundController:getInstance()
local _string_format = string.format
local table_insert = table.insert
local table_sort = table.sort

function CrossgroundItem:ctor()
	self:configUI()
	self:register_event()
end

function CrossgroundItem:configUI(  )
	self.size = cc.size(676, 198)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("crossground/crossground_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    container:setSwallowTouches(false)
    self.container = container

    self.item_bg = self.container:getChildByName("item_bg")
    self.open_desc = self.container:getChildByName("open_desc")
    self.open_desc:setAnchorPoint(cc.p(0, 1))
    self.open_desc:setPosition(30,135)
    self.lock_layer = self.container:getChildByName("lock_layer")
    self.title = self.container:getChildByName("title")
    self.item_scrollview = self.container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)

    self.join_desc = createRichLabel(18, Config.ColorData.data_new_color4[1], cc.p(0, 0.5), cc.p(10,32),nil,nil,300)
    self.container:addChild(self.join_desc)

    self.container_1 = self.root_wnd:getChildByName("container_1")
    if self.container_1 then
        self.item_obj_list = {}
        item_bg = self.container_1:getChildByName("item_bg")
        for i=1,2 do
            local item_obj = self.container_1:getChildByName("item"..i)
            local item = {}
            item.container = item_obj
            item.container:setSwallowTouches(false)
            item.item_bg = item_bg
            item.open_desc = item_obj:getChildByName("open_desc")
            item.open_desc:setAnchorPoint(cc.p(0, 1))
            item.open_desc:setPosition(30,135)
            item.lock_layer = item_obj:getChildByName("lock_layer")
            item.item_scrollview = item_obj:getChildByName("item_scrollview")
            item.item_scrollview:setScrollBarEnabled(false)
            item.title = item_obj:getChildByName("title")
            item.item_desBg = item_obj:getChildByName("item_desBg")
            item.item_desBg:setVisible(false)
            item.index = i
            
            if i == 2 then
                item.join_desc = createRichLabel(18, Config.ColorData.data_new_color4[1], cc.p(0, 0.5), cc.p(0,32),nil,nil,300)
                item.item_desBg:setPosition(cc.p(-25,32))
            else
                item.join_desc = createRichLabel(18, Config.ColorData.data_new_color4[1], cc.p(0, 0.5), cc.p(30,32),nil,nil,300)
                item.item_desBg:setPosition(cc.p(30-25,32))
            end

            item_obj:addChild(item.join_desc)
            self.item_obj_list[i] = item
        end 
        self.container_1:setVisible(false)
    end
end

function CrossgroundItem:register_event(  )
	self.container:addTouchEventListener(function ( sender, event_type )
		if event_type == ccui.TouchEventType.began then
			self.touch_began = sender:getTouchBeganPosition()
		elseif event_type == ccui.TouchEventType.ended then
			self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click then
            	playButtonSound2()
            	if self.open_status then
					if self.data then
						_controller:onClickCrossgroundItem(self.data.id)
					end
				end
            end
		end
	end)
    for i,item in ipairs(self.item_obj_list) do
        item.container:addTouchEventListener(function ( sender, event_type )
            if event_type == ccui.TouchEventType.began then
                item.touch_began = sender:getTouchBeganPosition()
            elseif event_type == ccui.TouchEventType.ended then
                item.touch_end = sender:getTouchEndPosition()
                local is_click = true
                if item.touch_began ~= nil then
                    is_click = math.abs(item.touch_end.x - item.touch_began.x) <= 20 and math.abs(item.touch_end.y - item.touch_began.y) <= 20
                end
                if is_click then
                    playButtonSound2()
                    if item.open_status then
                        if item.data then
                            _controller:onClickCrossgroundItem(item.data.id)
                        end
                    end
                end
            end
        end)
    end
    
end

function CrossgroundItem:setData( cross_data )
	if not cross_data then return end
    self.cross_data = cross_data
    local  list = cross_data.data
    if list and next(list) ~= nil then
        if #list == 1 then
            self.container:setVisible(true)
            self.container_1:setVisible(false)
            self:setItemData(self, list[1], true)
        else
            self.container:setVisible(false)
            self.container_1:setVisible(true)
            table_sort(list, function(a, b) return a.index < b.index end)
            self:setItemData(self.item_obj_list[1], list[1], true)
            self:setItemData(self.item_obj_list[2], list[2])
        end
    end
    self:updateRedStatus()
end

function CrossgroundItem:setItemData(item,  data, is_item_bg)
    if not item then return end
    if not data then return end
    item.data = data
    if is_item_bg then
        -- 背景
        local bg_res = PathTool.getPlistImgForDownLoad("bigbg/crossground", string.format("txt_cn_crossground_%s", data.groud))
        item.bg_load = loadImageTextureFromCDN(item.item_bg, bg_res, ResourcesType.single, item.bg_load)
    end
    
    if(data.groud == 4)then
        item.item_desBg:setVisible(true)
    end

    local res = string.format("resource/crossground/txt_crossground/txt_crossground_%s.png", data.index+2)
    loadSpriteTexture(item.title, res, LOADTEXT_TYPE)
    -- 描述
    item.join_desc:setString(data.desc)

    -- 是否开启
    local open_status = true
    local open_tips_list = {}
    local limit_name = data.open_limit[1]
    local limit_val = data.open_limit[2]
    for i,v in ipairs(data.open_limit) do
        if v[1] == "world_lev" then
            local world_lev = RoleController:getInstance():getModel():getWorldLev()
            if world_lev < v[2] then 
                open_status = false
                local str = _string_format(TI18N("世界等级达到%d级开启\n(当前为%s级)"), v[2], world_lev)
                table_insert(open_tips_list, str)
            end
        elseif v[1] == "lev" then
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo and role_vo.lev < v[2] then
                open_status = false
                local str = _string_format(TI18N("角色等级达到%d级开启"), v[2])
                table_insert(open_tips_list, str)
            end
        end
    end

    if data.id == 1002 then
        local model = ElitematchController:getInstance():getModel()
        local scdata = model:getSCData()
        if scdata.state == 0  then
            open_status = false
            table_insert(open_tips_list, TI18N("该玩法将在下周一开启"))
        end
    end

    local open_tips = ""
    if not open_status and open_tips_list[1] then 
        open_tips = open_tips_list[1]
    end
    
    item.open_status = open_status
    if open_status then
        -- 奖励数据
        local data_list = {}
        for k,bid in pairs(data.award) do
            table_insert(data_list, {bid, 1})
        end
        local setting = {}
        setting.scale = 0.65
        -- setting.max_count = item_max_count or 4
        -- setting.is_center = true
        item.item_list = commonShowSingleRowItemList(item.item_scrollview, item.item_list, data_list, setting)
        
        item.item_scrollview:setVisible(true)
        item.open_desc:setVisible(false)
        item.lock_layer:setVisible(false)
        self:updateArenaPeakInfo(item, data)
    else
        item.open_desc:setVisible(true)
        item.open_desc:setString(open_tips)
        item.item_scrollview:setVisible(false)
        item.lock_layer:setVisible(true)
    end
    
end

function CrossgroundItem:updateArenaPeakInfo(item, data)
    if not item or not data then return end
    if not item.open_status then return end
    
    if data.id == CrossgroundConst.Ground_Type.peakChampion then
        --巅峰赛加显示
        local model = ArenapeakchampionController:getInstance():getModel()
        local text = model:getMacthSingleText()
        if item.match_img == nil then
            local res = PathTool.getResFrame("crossground","crossground_1005")
            item.match_img = createSprite(res, 343 - 14, 172, item.container, cc.p(1, 0.5))
            item.match_label = createLabel(16, cc.c3b(0xff,0xff,0xff), cc.c3b(0x59,0x18,0x18), 
                325 , 173, text, item.container, 2, cc.p(1,0.5))
            
        else
            if item.match_label then
                item.match_label:setString(text)
            end
        end
        item.match_img:setScaleX(1.2)
    elseif data.id == CrossgroundConst.Ground_Type.CrossArena then
        --跨服竞技场加显示
        local model = ArenapeakchampionController:getInstance():getModel()
        local status = model:isBeforeOpenMacthTime()
        if status then
            if item.match_img == nil then
                local res = PathTool.getResFrame("crossground","crossground_1005")
                item.match_img = createImage(item.container,res,0,172,cc.p(-250,0.5),true,0,true)
                item.match_img:setFlippedX(true) --是否翻转纹理 ,设置此 不用setScale(-1)
                item.match_img:setAnchorPoint(cc.p(1,0.5)) --cocos 真是个奇葩
                item.match_img:setCapInsets(cc.rect(15,15,0,0))
                item.match_img:setContentSize(cc.size(120,33))  --设置flippedx 之后 contentSize失效
                item.match_label = createLabel(16, cc.c3b(0xff,0xff,0xff), cc.c3b(0x59,0x18,0x18), 
                    5, 173, TI18N("巅峰赛季"), item.container, 2, cc.p(0,0.5))
            else
                if item.match_img then
                    item.match_img:setVisible(true)
                end
                
                if item.match_label then
                    item.match_label:setVisible(true)
                end
            end
            -- self:showCrossArenaEffect(true, item.container)
        else
            if item.match_img then
                item.match_img:setVisible(false)
            end
            
            if item.match_label then
                item.match_label:setVisible(false)
            end
            -- self:showCrossArenaEffect(false, item.container)
        end
    end

end

function CrossgroundItem:showArenaPeakEffect(bool, container)
    if bool == true then
        if self.arenapeak_effect == nil then
            if not container then return end
            local  size = self.container:getContentSize()
            self.arenapeak_effect = createEffectSpine("E27404", cc.p(297, 172), cc.p(0.5, 0.5), true, PlayerAction.action)
            container:addChild(self.arenapeak_effect, 1)
        end    
    else
        if self.arenapeak_effect then 
            self.arenapeak_effect:setVisible(false)
            self.arenapeak_effect:removeFromParent()
            self.arenapeak_effect = nil
        end
    end
end

function CrossgroundItem:showCrossArenaEffect(bool, container)
    if bool == true then
        if self.corssarena_effect == nil then
            if not container then return end
            local  size = self.container:getContentSize()
            self.corssarena_effect = createEffectSpine("E27404", cc.p(48, 172), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.corssarena_effect:setScaleX(-1)
            container:addChild(self.corssarena_effect, 1)
        end    
    else
        if self.corssarena_effect then 
            self.corssarena_effect:setVisible(false)
            self.corssarena_effect:removeFromParent()
            self.corssarena_effect = nil
        end
    end
end

-- 红点刷新
function CrossgroundItem:updateRedStatus(  )
    if self.cross_data then
        local  list = self.cross_data.data
        if list and next(list) ~= nil then
            if #list == 1 then
                self:updateRedStatusBydata(self, list[1])
            else
                table_sort(list, function(a, b) return a.index < b.index end)
                self:updateRedStatusBydata(self.item_obj_list[1], list[1])
                self:updateRedStatusBydata(self.item_obj_list[2], list[2])
            end
        end
    end
end

function CrossgroundItem:updateRedStatusBydata(item, data)
    if data then
        local red_status = false
        if data.id == CrossgroundConst.Ground_Type.Ladder then  -- 跨服天梯
            red_status = LadderController:getInstance():getModel():checkLadderRedStatus()
        elseif data.id == CrossgroundConst.Ground_Type.EliteMatch then -- 精英大赛
            red_status = ElitematchController:getInstance():getModel():getElitematchTotalRedPoint()
        elseif data.id == CrossgroundConst.Ground_Type.CrossArena then -- 跨服竞技场
            red_status = CrossarenaController:getInstance():getModel():checkCrossarenaRedStatus()
        elseif data.id == CrossgroundConst.Ground_Type.CrossChampion then -- 跨服冠军赛
            red_status = CrosschampionController:getInstance():getModel():checkCrosschampionRedStatus()
        elseif data.id == CrossgroundConst.Ground_Type.Arenateam then -- 组队竞技场
            red_status = ArenateamController:getInstance():getModel():checkArenateamTotalRedPoint()
        elseif data.id == CrossgroundConst.Ground_Type.peakChampion then -- 巅峰冠军赛
            red_status = ArenapeakchampionController:getInstance():getModel():checkPeakChampionTotalRedPoint()
        end
        addRedPointToNodeByStatus( item.container, red_status, nil, nil, 99, 2 )
    end
end

function CrossgroundItem:DeleteMe(  )
    self:showArenaPeakEffect(false)
    self:showCrossArenaEffect(false)

	if self.award_scrollview then
		self.award_scrollview:DeleteMe()
		self.award_scrollview = nil
	end
    if self.bg_load then
        self.bg_load:DeleteMe()
        self.bg_load = nil
    end
    if self.item_list then
        for i,v in ipairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    if self.item_obj_list then
        for _,item in ipairs(self.item_obj_list) do
            if item.item_list then
                for i,v in ipairs(item.item_list) do
                    v:DeleteMe()
                end
                item.item_list = nil
            end
            if item.bg_load then
                item.bg_load:DeleteMe()
                item.bg_load = nil
            end
        end
    end

	self:removeAllChildren()
	self:removeFromParent()
end