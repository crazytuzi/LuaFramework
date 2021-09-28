local TreasureRobItem = class("TreasureRobItem",function()
    return CCSItemCellBase:create("ui_layout/treasure_TreasureRobItem.json")
end)

require("app.cfg.knight_info")
local FunctionLevelConst = require("app.const.FunctionLevelConst")
local TreasureRobItemKnightItem = require("app.scenes.treasure.cell.TreasureRobItemKnightItem")
function TreasureRobItem:ctor(json,...)
	self._qangduoFunc = nil
	self._saodangFunc = nil
	-- self._scrollView = self:getScrollViewByName("ScrollView_knight")
	self._scrollView = self:getWidgetByName("ScrollView_knight")
	self._scrollView = tolua.cast(self._scrollView,"ScrollView")
	self._nameLabel = self:getLabelByName("Label_name")
	self._levelLabel = self:getLabelByName("Label_level")
	self._zhanliLabel = self:getLabelByName("Label_zhanli")
	self._imageView = self:getImageViewByName("ImageView_gailv")
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	self:registerBtnClickEvent("Button_qiangduo",function() 
		if self._qangduoFunc ~= nil then 
			self._qangduoFunc() 
		end 
		self:setClickCell()
	end) 
	self:registerBtnClickEvent("Button_qiangduo01",function() 
		if self._qangduoFunc ~= nil then 
			self._qangduoFunc() 
		end 
		self:setClickCell()
	end) 
	self:registerBtnClickEvent("Button_saodang",function()
		local isUnlock = G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TREASURE_ROB_5_TIMES)
		if isUnlock and self._saodangFunc then
			self._saodangFunc()
		end
		end)

end

function TreasureRobItem:setQiangduoBtnEvent(func)
	self._qangduoFunc = func
end

function TreasureRobItem:setSaoDangEvent(func)
	self._saodangFunc = func	
end
--[[
	user内容如下
	message TreasureFragmentRobUser {
	  required uint32 index = 1;
	  required string name = 2;
	  required uint32 level = 3;
	  required uint32 power = 4;
	  repeated uint32 knights = 5;
	  required uint32 rob_rate = 6;
	  required bool is_robot = 7;
	}
]]
function TreasureRobItem:update(user,index)
	if user == nil then return end
	self:_initScrollView(user)
	if self._scrollView ~= nil then
		self._scrollView:getInnerContainer():setPosition(ccp(0,0))
	end
	local knight = knight_info.get(user.knights[1])
	self._nameLabel:setColor(Colors.qualityColors[knight.quality])
	if IS_HEXIE_VERSION then
		--草 和谐版
		local n = (index+1)*20
		self._nameLabel:setText("NPC0"..math.random(index*20+1,(index+1)*20+1))
	else
		self._nameLabel:setText(user.name)
	end
	self._levelLabel:setText(G_lang:get("LANG_LEVEL_FORMAT_CHN",{levelValue=user.level}))

	self._zhanliLabel:setText(user.fight_value)

	if user.rob_rate <100 then 
		self._imageView:loadTexture("ui/text/txt/digailv.png",UI_TEX_TYPE_LOCAL)
	elseif user.rob_rate <200 then
		self._imageView:loadTexture("ui/text/txt/jiaodigailv.png",UI_TEX_TYPE_LOCAL)
	elseif user.rob_rate < 300 then
		self._imageView:loadTexture("ui/text/txt/yibangailv.png",UI_TEX_TYPE_LOCAL)
	elseif user.rob_rate <400 then
		self._imageView:loadTexture("ui/text/txt/jiaogaogailv.png",UI_TEX_TYPE_LOCAL)
	else 
		self._imageView:loadTexture("ui/text/txt/gaogailv.png",UI_TEX_TYPE_LOCAL)
	end
	if user.is_robot then
		-- 这里有一个特殊情况，15级时有一个夺宝的新手引导，为了不影响之，
		-- 在15级（包括15）之前，即使VIP已达到，也不显示夺5次
		local canPreviewRob5 = G_moduleUnlock:canPreviewModule(FunctionLevelConst.TREASURE_ROB_5_TIMES)
		local leastShowLevel = 16
		local showRob5 = canPreviewRob5 and G_Me.userData.level >= leastShowLevel
		if not showRob5 then
			self:showWidgetByName("Button_qiangduo",false)
			self:showWidgetByName("Button_saodang",false)
			self:showWidgetByName("Button_qiangduo01",true)
		else
			self:showWidgetByName("Button_qiangduo",true)
			self:showWidgetByName("Button_saodang",true)
			self:showWidgetByName("Button_qiangduo01",false)
		end
	else
		self:showWidgetByName("Button_qiangduo",false)
		self:showWidgetByName("Button_saodang",false)
		self:showWidgetByName("Button_qiangduo01",true)
	end

end

function TreasureRobItem:_initScrollView(user)
	local space = 5 --间隙
	local size = self._scrollView:getContentSize()
	local _knightItemWidth = 0
	if self._scrollView ~= nil then
		self._scrollView:removeAllChildrenWithCleanup(true)
	end
	for i,v in ipairs(user.knights) do
	    --因为各个玩家name不同,以它作为buttonName，避免冲突
	    local btnName = user.name .. "_" .. v

	    local dress_base = nil
	    if rawget(user,"dress_base") then
	    	dress_base = user.dress_base
	    end
	    local widget = TreasureRobItemKnightItem.new(v,btnName,dress_base)

	    _knightItemWidth = widget:getWidth()


	    widget:setPosition(ccp(_knightItemWidth*(i-1)+i*space,0))
	    --self:addChild(widget)
	    self._scrollView:addChild(widget)
	    self:registerBtnClickEvent(widget:getButtonName(),function()
	    	require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_KNIGHT, v)
	    	end)
	end
	local _scrollViewWidth = _knightItemWidth*#user.knights+space*(#user.knights+1)
	self._scrollView:setInnerContainerSize(CCSizeMake(_scrollViewWidth,size.height))
end

return TreasureRobItem
	
