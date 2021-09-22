GUIFloatTipsManager = {}
local var  = {}

local tipsConfig = {
	["confirm"] 		= {name = "GComponentConfirm",		uif = "GComponentConfirm"},
	["alert"] 			= {name = "GComponentToast",			uif = "GComponentToast"},
	["sendCallFriend"]	= {name = "GComponentFriendStartCall",	uif = "GComponentFriendStartCall"},
	["gotCallFriend"]	= {name = "GComponentFriendCall",	uif = "GComponentFriendCall"},
	["addFriend"]		= {name = "GComponentFriend"	,	uif = "GComponentFriend"},
	["revenge"]			= {name = "GComponentAvenge"	,		uif = "GComponentAvenge"},
	["enemytrack"]		= {name = "GComponentFoe"	,	uif = "GComponentFoe"},
	["friendOperate"]	= {name = "GComponentFriendMenu",	uif = "GComponentFriendMenu"},
	["useItem"]			= {name = "GComponentItemUse",		uif = "GComponentItemUse"},
	["createGuild"]		= {name = "GComponentGuidCreate",	uif = "GComponentGuidCreate"},
	["guildMember"]		= {name = "GComponentGuidMember",	uif = "GComponentGuidMember"},
	["quickBuy"]		= {name = "GComponentBuy",		uif = "GComponentBuy"},
	["newSkill"]		= {name = "GComponentSkill",		uif = "GComponentSkill"},
	["kingcity"]		= {name = "GComponentKingDesc",	uif = "GComponentKingDesc"},
	["compose"]			= {name = "GComponentItem",		uif = "GComponentItem"},
	["welcome"]			= {name = "GComponentStartGameTips",		uif = "GComponentStartGameTips"},
	["taskFly"]			= {name = "GComponentDirectGo",			uif = "GComponentDirectGo"},
	["achieveComplete"]	= {name = "GComponentTaskEnd",uif = "GComponentTaskEnd", layerBlock = 1},
	["defendResult"]	= {name = "GComponentProtected",uif = "GComponentProtected"},
	["funOpen"]			= {name = "GComponentFunction",	uif = "GComponentFunction"},

}
local tipsCached = {}
local luafile = {}
local eventQuene = {} --消息队列

function GUIFloatTipsManager.showNextTips()
	if #eventQuene >=1 then
		GUIFloatTipsManager.showTips(eventQuene[1])
	else
		var.layerTips:hide()
	end
end

function GUIFloatTipsManager.clickGDivToast(pSender)
	if #eventQuene>=1 then
		if not tipsConfig[eventQuene[1].str].layerBlock then
			GUIFloatTipsManager.handleHideTips({str = eventQuene[1].str})
		end
	end
end

function GUIFloatTipsManager.showTips(event)
	local str = event.str or ""
	local params = tipsConfig[str]
	if params then
		local tipsfile = require_ex("gameui."..params.name)
		var.layerTips:show()
		if tipsfile then
			local self = {}
			self.str = str
			self.xmlTips = GUIAnalysis.load("ui/layout/"..params.uif..".uif") -- 布局文件统一叫xmlTips
			if self.xmlTips then
				self.xmlTips:align(display.CENTER, display.cx, display.cy)
					:setName("tips"..params.name)
					:addTo(var.layerTips)
					:setTouchEnabled(true)
					:setSwallowTouches(true)
					:show()
			end
			luafile[str] = tipsfile
			tipsCached[str] = self
			tipsfile.initView(self,event)
		end
	end
end

function GUIFloatTipsManager.handleShowTips(event)
	if type(event) ~= "table" then return end
	--预先显示最新的tips，当前的tips存到下一次显示
	if #eventQuene>= 1 then
		for k,v in pairs(tipsCached) do
			if GameUtilSenior.isObjectExist(v.xmlTips) then
				v.xmlTips:removeFromParent()
			end
			tipsCached[k] = nil
		end
	end
	table.insert(eventQuene,1,event)
	GUIFloatTipsManager.showTips(eventQuene[1])
end

function GUIFloatTipsManager.handleHideTips(event)
	if event.str then
		if tipsCached[event.str] then
			local xmlTips = tipsCached[event.str].xmlTips
			if luafile[event.str] and luafile[event.str].closeCall then
				luafile[event.str].closeCall(tipsCached[event.str])
			end
			if GameUtilSenior.isObjectExist(xmlTips) then
				xmlTips:removeFromParent()
				xmlTips = nil
			end
			tipsCached[event.str] = nil
			luafile[event.str] = nil
		end
		for i=1,#eventQuene do
			if eventQuene[i].str == event.str then
				table.remove(eventQuene,i)
				break
			end
		end
		GUIFloatTipsManager.showNextTips()
	end
end

function GUIFloatTipsManager.init()

	var.layerTips = ccui.Widget:create()
		:setContentSize(cc.size(display.width, display.height))
		:align(display.CENTER, display.cx, display.cy)
		:setTouchEnabled(true)
		:setSwallowTouches(true)
		:hide()
		:setName("layerTipsManager")
	var.layerTips:addClickEventListener(GUIFloatTipsManager.clickGDivToast)
	
	cc.EventProxy.new(GameSocket, var.layerTips)
		:addEventListener(GameMessageCode.EVENT_SHOW_TIPS, GUIFloatTipsManager.handleShowTips)
		:addEventListener(GameMessageCode.EVENT_HIDE_TIPS, GUIFloatTipsManager.handleHideTips)

	return var.layerTips
end

return GUIFloatTipsManager