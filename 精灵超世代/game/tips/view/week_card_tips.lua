--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 周卡的 tips
-- @DateTime:    2019-05-09 17:15:48
-- *******************************
-- --------------------------------------------------------------------
WeekCardTips = WeekCardTips or BaseClass(BaseView)

local controller = TipsManager:getInstance()

function WeekCardTips:__init()
    self.is_full_screen = false
    self.layout_name = "tips/week_card_tips"
    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }
    self.item_list = {}
end

function WeekCardTips:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background ~= nil then
		self.background:setScale(display.getMaxScale())
	end
	self.main_panel = self.root_wnd:getChildByName("main_panel")
	local week_card_spr = self.main_panel:getChildByName("week_card_spr")
	week_card_spr:setLocalZOrder(10)

	self.text_name = self.main_panel:getChildByName("text_name")
	self.text_name:setString("")
	self.main_panel:getChildByName("name_0"):setString(TI18N("类型："))
	self.text_type = self.main_panel:getChildByName("text_type")
	self.text_type:setString("")

	self.main_panel:getChildByName("Text_1"):setString(TI18N("立即获取"))
	self.main_panel:getChildByName("Text_1_0"):setString(TI18N("持续七天，每天登录领取"))
	self.btn_close = self.main_panel:getChildByName("btn_close")

	--标题说明
	self.tips_desc = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0,0.5), cc.p(15,378), nil, nil, 400)
    self.main_panel:addChild(self.tips_desc)
end

function WeekCardTips:register_event()
	registerButtonEventListener(self.background, function()
        controller:showWeekCardTips(false)
    end,false, 2)
    registerButtonEventListener(self.btn_close, function()
        controller:showWeekCardTips(false)
    end,false, 2)
end

function WeekCardTips:openRootWnd(data)
	if not data then end
	self:setData(data)
end

function WeekCardTips:setData(data)
	local name = data.name or ""
	local type_desc = data.type_desc or ""
	self.text_name:setString(name)
	self.text_type:setString(type_desc)
	
	self:setShowItem(data)
end

--显示物品
function WeekCardTips:setShowItem(data)
	--主物品
	if data.id then
		self.goods_tips =  BackPackItem.new(true,true,nil,1,false)
	    self.goods_tips:setPosition(cc.p(78,483))
	    self.main_panel:addChild(self.goods_tips)
	    self.goods_tips:setBaseData(data.id)
	
		local weekcard_data = Config.GiftData.data_week_card_data
		if not weekcard_data then return end
		local temp_data = weekcard_data[data.id]
		if temp_data then
			self.tips_desc:setString(temp_data.weekcard_desc)
			--立即获取
			if temp_data.reward and temp_data.reward[1] and temp_data.reward[1][1] then
				local num = temp_data.reward[1][2] or 1
				self:setGoodsData(1,temp_data.reward[1][1], num, cc.p(128,229), {188,228})
			end
			--邮件获取
			if temp_data.mail_reward and temp_data.mail_reward[1] and temp_data.mail_reward[1][1] then
				local num = temp_data.mail_reward[1][2] or 1
				self:setGoodsData(2,temp_data.mail_reward[1][1], num, cc.p(128,66), {188,62})
			end
		end
	end
end
--[[
bid: 奖励我物品id
num: 数量
pos: 物品的位置
text_pos: 数量文字的位置
]]
function WeekCardTips:setGoodsData(index, bid, num, pos, text_pos)
	if not self.item_list[index] then
		self.item_list[index] = BackPackItem.new(true,true,nil,0.8,false)
	    self.item_list[index]:setPosition(pos)
	    self.main_panel:addChild(self.item_list[index])
	end
    self.item_list[index]:setBaseData(bid,num)

    local name_text = createLabel(22,Config.ColorData.data_new_color4[6],nil,text_pos[1],text_pos[2],"",self.main_panel,nil, cc.p(0,0.5))
    local item_config = Config.ItemData.data_get_data(bid)
    name_text:setString(item_config.name.." x "..num)
end

function WeekCardTips:close_callback()
	if self.goods_tips then 
		self.goods_tips:DeleteMe()
	end
	self.goods_tips = nil

	if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    controller:showWeekCardTips(false)
end
